.syntax unified
.thumb

.global assembly_function

// Clock Registers
.equ RCC, 0x40021000   // Reset clock control. Base clock regiser
.equ AHBENR, 0x14      // Enable GPIO clocks
.equ APB2ENR, 0x18     // Enable peripheral clock for USART1
.equ APB1ENR, 0x1C	   // Enable peripheral clock for other USART ports

// Addresses and offsets for USART
.equ USART1,0x40013800 // Base address for USART1
.equ USART3,0x40004800 // Base address for USART3
.equ USART_CR1, 0x00   // Control register 1
.equ USART_CR2, 0x04   // Control register 2
.equ USART_BRR, 0x0C   // Baud rate register
.equ USART_ISR, 0x1C   // Status Register
.equ USART_TDR, 0x28   // Transmit data register
.equ USART_RDR, 0x24   // Receive data register

// GPIO
.equ GPIOC, 0x48000800  // GPIO Port C base address
.equ GPIO_MODER, 0x00   // Mode selection
.equ GPIO_OSPEEDR, 0x08 // Speed selection
.equ GPIO_AFRL, 0x20    // Alternate function specification (low byte)
.equ GPIO_AFRH, 0x24    // Alternate function specification (high byte)
.equ GPIOC_ENABLE, 19   // Bit to enable clock for Port C (For USART1 and USART3)

// UART
.equ USART1_ENABLE, 14  // Bit to enable USART1 clock
.equ USART3_ENABLE, 18	// Bit to enable USART3 clock
.equ UART_TXE, 7        // Transmit data register empty bit
.equ UART_RXNE, 5		// Recieve data register not empty bit
.equ UART_TE, 3         // Bit to enable transmission
.equ UART_RE, 2         // Bit to enable receive
.equ UART_UE, 0         // Bit to enable USART1 submodule

.data

.align

rxBuffer: .space 100	// Create a buffer of 100 empty characters to store the received string in

.text

// Entry point
assembly_function:

	BL enableGPIOClocks 	// Enable the GPIO clocks required to run USART
	BL enableUSART			// Configure USART1 and USART3

	inf_loop:

		LDR R0, =USART1		// The port to receive on. Set to USART1 to receive from PC. Set to USART3 to receive over wires
		LDR R1, =rxBuffer	// Load the address of the buffet string
		BL receive_string	// Receive a string from USART into rxBuffer

		// Transmit the string in rxBuffer over USART1. String should be null-terminated
		LDR R0, =USART1
		LDR R1, =rxBuffer
		BL transmit_string

		// Transmit the string in rxBuffer over USART3. String should be null-terminated
		LDR R0, =USART3
		LDR R1, =rxBuffer
		BL transmit_string

		B inf_loop

enableGPIOClocks:
	LDR R0, =RCC              // Load register with clock base adderss
	LDR R1, [R0, #AHBENR]     // Load R1 with peripheral clock register's values
	ORR R1, 1 << GPIOC_ENABLE // Set relevant bits to enable clock for Port C
	STR R1, [R0, #AHBENR]     // Store value back in register to enable clock
	BX LR

enableUSART:

	// USART1 and USART3 (GPIOC) - Pins PC4, PC5, PC10, PC11

	// Set pin modes to AF (Alternate Function)
	LDR R0, =GPIOC
	LDR R1, =0x00A00A00 // 0000 0000 1010 0000 0000 1010 0000 0000 ('10' is the code for alternate function)
	STR R1, [R0, #GPIO_MODER]

	// Step 2: Set specific AF to 7
	LDR R1, =0x77
	STRH R1, [R0, #GPIO_AFRL + 2]
	LDR R1, =0x77
	STRB R1, [R0, #GPIO_AFRH + 1]

	// Step 3: High clock speed and enable USART clock
	LDR R1, =0x00F00F00 // 00F00F00
	STR R1, [R0, #GPIO_OSPEEDR]

	LDR R0, =RCC
	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << USART1_ENABLE
	STR R1, [R0, #APB2ENR]

	LDR R0, =RCC
	LDR R1, [R0, #APB1ENR]
	ORR R1, 1 << USART3_ENABLE
	STR R1, [R0, #APB1ENR]

	// Step 4: Baud rate and enable USART1&3 (both transmit and receive)
	MOV R1, #0x46
	LDR R0, =USART1
	STRH R1, [R0, #USART_BRR]

	MOV R1, #0x46
	LDR R0, =USART3
	STRH R1, [R0, #USART_BRR]

	LDR R0, =USART1
	LDR R1, [R0, #USART_CR1]
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE
	STR R1, [R0, #USART_CR1]

	LDR R0, =USART3
	LDR R1, [R0, #USART_CR1]
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE
	STR R1, [R0, #USART_CR1]

	BX LR

transmit_string:
	// Load USART1 or USART3 into R0
	// Load address of first char of string (null-terminated) into R1
	// Uses R2 and R3

	transmit_one_char:
		// Load next character of string into R2 and increment pointer
		LDRB R2, [R1], #1

		wait_until_TX_ready:
			LDR R3, [R0, #USART_ISR]	// Load the status register into R3
			ANDS R3, 1 << UART_TXE		// Check if the transmission data register is empty
			BEQ wait_until_TX_ready

		STRB R2, [R0, #USART_TDR] 		// Transmit the character

		CMP R2, #0						// If char is 0 then the string is over
		BNE transmit_one_char

	BX LR

receive_string:
	// Load USART1 or USART3 into R0
	// Load starting address of string into R1. This will be filled by a null-terminated string
	// If this functino is receiving data over USART1 (the USB port), a '\r' (enter) will be replaced by '\r\n' and a null terminator
	// Uses R2, R3, R4

	LDR R4, =#0							// R4 is the counter register to prevent overflows

	receive_one_char:

		wait_until_RX_ready:
			LDR R3, [R0, #USART_ISR]	// Load status register into R3
			ANDS R3, 1 << UART_RXNE		// Check if receive data register is not empty
			BEQ wait_until_RX_ready

		LDRB R2, [R0, #USART_RDR]		// Load the received byte into R2
		STRB R2, [R1], #1				// Store this byte into the buffer string and increment pointer

		ADD R4, R4, #1					// Increment the counter register

		CMP R2, #0						// Check if character is 0 (null-terminator)
		BEQ if_zero
		CMP R2, #'\r'					// Check if character is '\r' (pressed enter key)
		BEQ if_slash_r

		CMP R4, #97						// Make sure the counter is not above 96
		BLT not_overflow

		LDR R2, =#0						// If overflow has occured, append null and return from function
		STRB R2, [R1], #1
		BX LR

		not_overflow:
			B receive_one_char			// If not null, not '\r', and not overflow, go back to beginning of loop

		if_zero:
			BX LR						// Return if character is null-terminator

		if_slash_r:
			LDR R3, =USART1				// If the character is '\r' and it is receiving on USART1, instead append '\r', '\n', 0 to make a newline and then terminate the string
			CMP R0, R3
			BNE receive_one_char

			LDR R2, =#'\n'
			STRB R2, [R1], #1
			LDR R2, =#0
			STRB R2, [R1], #1
			BX LR
