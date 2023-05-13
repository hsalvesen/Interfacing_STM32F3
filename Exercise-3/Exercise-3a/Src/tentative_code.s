.syntax unified
.thumb

.global tentative_assembly_function

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

.data

.align

txString: .asciz "Khit\r\n" // The r is a carraige return. The n is a new line
txLength: .byte 6

.text

// Entry point
tentative_assembly_function:

    BL enableGPIOClocks
    BL enableUSART

    B prepareTransmit

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

prepareTransmit:
    LDR R3, =txString         // Load string
    LDR R4, =txLength         // Load pointer to number of characters in string
    LDR R4, [R4]              // Dereference pointer

transmit:

    LDR R1, [R0, #USART_ISR]  // Load the status register into R1
    ANDS R1, 1 << UART_TXE    // Check if the transmission data register is empty

    BEQ transmit              // Wait (loop) until it is empty

    LDRB R5, [R3], #1         // Load the next character in the string and point to the next entry
    STRB R5, [R0, #USART_TDR] // Transmit the character
    SUBS R4, #1               // Indicate that one character has been sent out
    BGT transmit              // Keep looping until all characters are sent

    BL delayLoop              // Delay between sending strings
    B prepareTransmit         // Start all over again

delayLoop:
    LDR R9, =0xfffff

delayInner:

    SUBS R9, #1
    BGT delayInner
    BX LR
