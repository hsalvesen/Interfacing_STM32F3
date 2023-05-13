// Some code borrowed from Khit's notion

.syntax unified
.thumb

.global assembly_function

// Clock Registers
.equ RCC, 0x40021000   // Reset clock control. Base clock regiser
.equ AHBENR, 0x14      // Enable GPIO clocks
.equ APB2ENR, 0x18     // Enable USART1

// Addresses and offsets for USART1
.equ USART1,0x40013800 // Base address for USART1
.equ USART_CR1, 0x00   // Control register 1
.equ USART_BRR, 0x0C   // Baud rate register
.equ USART_ISR, 0x1C   // Status Register
.equ USART_TDR, 0x28   // Transmit data register

// GPIO
.equ GPIOC, 0x48000800  // GPIO Port C base address
.equ GPIO_MODER, 0x00   // Mode selection
.equ GPIO_OSPEEDR, 0x08 // Speed selection
.equ GPIO_AFRL, 0x20    // Alternate function specification
.equ GPIOC_ENABLE, 19   // Bit to enable clock for Port C (For UART4)

// UART
.equ USART1_ENABLE, 14  // Bit to enable USART1 clock
.equ UART_TXE, 7        // Transmit data register empty bit
.equ UART_TE, 3         // Bit to enable transmission
.equ UART_RE, 2         // Bit to enable receive
.equ UART_UE, 0         // Bit to enable USART1 submodule


@ Clock setting register (base address and offsets)
.equ RCC, 0x40021000	@ base register for resetting and clock settings
.equ TIM2, 0x40000000 @ address to TIM2
.equ TIMx_CNT, 0x24 @ address offset for TIMx_CNT
.equ TIMx_CR1, 0x0 @ offset for TIMx_CR1
.equ TIMx_PSC, 0x28 @ offset for TIMx_PSC (prescale value)
.equ TIMx_ARR, 0x2C @ offset address for TIMx_ARR (Auto reload)
.equ TIMx_SR, 0x10 @ offset address for TIMx_SR (Event flags)

.equ AHBENR, 0x14  @ enable peripherals
.equ APB1ENR, 0x1C @ offset off RCC to APB1 peripheral clock enable register

@ Clock enable
.equ TIMER2_ENABLE, 0
.equ CEN_ENABLE, 0
.equ ARPE_ENABLE, 7
.equ UIF_DISABLE, 0


@ prescaler and delay
.equ PRESCALER, 7999
.equ DELAY, 1000 @ in ms

.data

.align

txString: .asciz "Hello4\r\n"
txLength: .byte 6

.text

// Entry point
assembly_function:

	BL enableGPIOClocks
	BL enableUSART
	BL config_clock


	infinite_loop:
		B delay_function

enableGPIOClocks:
	LDR R0, =RCC              // Load register with clock base adderss
	LDR R1, [R0, #AHBENR]     // Load R1 with peripheral clock register's values
	ORR R1, 1 << GPIOC_ENABLE // Set relevant bits to enable clock for Port C
	STR R1, [R0, #AHBENR]     // Store value back in register to enable clock
	BX LR

enableUSART:

	// Step 1: Choose pin mode
	LDR R0, =GPIOC
	LDR R1, =0xA00
	STR R1, [R0, #GPIO_MODER]

	// Step 2: Set specific alternate function
	MOV R1, 0x77
	STRB R1, [R0, #GPIO_AFRL + 2]

	// Step 3: High clock speed and enable USART1 clock
	LDR R1, =0xF00
	STR R1, [R0, #GPIO_OSPEEDR]

	LDR R0, =RCC
	LDR R1, [R0, #APB2ENR]
	ORR R1, 1 << USART1_ENABLE
	STR R1, [R0, #APB2ENR]

	// Step 4: Baud rate and enable USART1 (both transmit and receive)
	MOV R1, #0x46
	LDR R0, =USART1
	STRH R1, [R0, #USART_BRR]

	LDR R0, =USART1
	LDR R1, [R0, #USART_CR1]
	ORR R1, 1 << UART_TE | 1 << UART_RE | 1 << UART_UE
	STR R1, [R0, #USART_CR1]

	BX LR

transmit_string:
	// Expects a pointer to a null-terminated string in R1
	// Will use R0, R4, and R5

	LDR R5, =USART1 					// Load the USART1 memory address into R5

	transmit_next_char:					// Inner function to transmit one character

		wait_until_ready:				// Function to repeat until USART is ready to transmit

			LDR R4, [R5, #USART_ISR]	// Load the USART1 status register into R4
			ANDS R4, 1 << UART_TXE		// Check if USART is ready to transmit

			BEQ wait_until_ready		// If not ready, loop until is ready

		LDRB R0, [R1], #1				// Load byte from R1 into R0, then increment
		STRB R0, [R5, #USART_TDR]		// Send byte over serial by storing in memory address

		CMP R0, #0						// Compare with null terminator
		BNE transmit_next_char			// If not null, run function again

	BX LR								// When finished, return

delay_function:

	LDR R8, =TIM2 @ sets R0 as TIM2 address


check_timer:
	@ isolate UIF flag
	LDR R2, [R8, #TIMx_SR]

	LDR R3, =0b1
	AND R3, R2


	CMP R3, 0b1 @ detect if flag is set
	BNE check_timer @ restart if threshold hasnt been reached

	@ delay passed -> change LED pattern
	LDR R1, =txString
	BL transmit_string

	@ disable flag
	LDR R2, [R8, #TIMx_SR]
	AND R2, 0 << UIF_DISABLE
	STR R2, [R8, #TIMx_SR]

	B delay_function

	@ loops infinitely
inf_loop:
	B inf_loop






config_clock:

	@ turn on timer 1
	LDR R0, =RCC @ load RCC address to R0
	LDR R1, [R0, #APB1ENR] @ load R1 with APB1ENR address
	ORR R1, 1 << TIMER2_ENABLE @ set 0th bit to 1 (turn on TIMER2)
	STR R1, [R0, #APB1ENR]  @ Store new settings to APB1ENR address

	@ set prescaler
	LDR R0, =TIM2 @ load TIM2 address to R0
	LDR R1, =PRESCALER @ load prescaler into register
	STR R1, [R0, #TIMx_PSC] @ Set address to equal prescaler

	@ enable counter and ARPE
	LDR R1, [R0, #TIMx_CR1] @ load R1 with TIM2_CR1 address
	ORR R1, 1 << CEN_ENABLE | 1 << ARPE_ENABLE @ set 0th bit to 1 for CEN and 7th bit for ARPE
	STR R1, [R0, #TIMx_CR1]  @ Store new settings to TIM2_CR1 address

	@ configure ARPE and cycle counter to enable prescaler
	LDR R2, =0 @ set timer to almost overflow
	STR R2, [R0, #TIMx_CNT]
	LDR R2, =DELAY
	STR R2, [R0, #TIMx_ARR]

	@ cycle counter to enable prescaler
	LDR R2, =0b11111111111111111111111111111110 @ set timer to overflow
	STR R2, [R0, #TIMx_CNT]
	LDR R2, [R0, #TIMx_SR]
	AND R2, 0 << UIF_DISABLE
	STR R2, [R0, #TIMx_SR]

	BX LR @ return from function call
