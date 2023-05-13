**Exercise 3** functions focused on the use of UART communication on the STM32 microcontroller. (UART 3, 4)
___
Function A (transmit_string) sends a string of characters over UART, using the memory-mapped UART_TX register to store each byte. 
- Uses a null terminator to indicate the end of the string, and can be modified to include a terminating character feature as shown in function C.
___

```
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
```
    
___
___
Function B (receive_string) receives a string of characters over UART and stores them in a buffer pointed to by R1. 
- Uses the memory-mapped UART_RX register to read each byte, and also uses a null terminator to indicate the end of the string. 
- It can also be modified to include a terminating character feature as shown in function C.
___

```
receive_string: 
	mov r3, #0                	@ Initialise buffer index to 0 
loop: 
	ldrb r2, [UART_RX]        	@ Load byte from UART RX register 
					@ Here, UART_RX is a memory-mapped register representing the UART receive data register.
	cmp r2, #0                	@ Compare byte with null terminator 
	beq end_receive           	@ Branch to end_receive if byte is a null terminator 
	strb r2, [r1, r3]         	@ Store byte to buffer pointed to by R1 and indexed by R3 
	add r3, r3, #1            	@ Increment buffer index 
	b loop                    	@ Branch to beginning of function to receive next byte 
end_receive: 
	strb r2, [r1, r3]         	@ Store null terminator to end of buffer 
	bx lr                     	@ Return from function
```
	
___
Function C (transmit string) Include a terminating character feature. 
- Can modify the above functions to check for the terminating character before sending/receiving the byte.
___

```
transmit_string:
    ldrb r2, [r1], #1     		@ Load byte from address pointed to by R1, and increment R1 by 1
    cmp r2, #0            		@ Compare byte with null terminator
    beq end_transmit      		@ Branch to end_transmit if byte is a null terminator
    strb r2, [UART_TX]    		@ Store byte to UART TX register
    b transmit_string     		@ Branch to beginning of function to send next byte
end_transmit:
    mov r2, #'\0'         		@ Send terminating character
    strb r2, [UART_TX]
    bx lr                 		@ Return from function
    
receive_string:
    mov r3, #0            		@ Initialise buffer index to 0
loop:
    ldrb r2, [UART_RX]    		@ Load byte from UART RX register
    cmp r2, #0            		@ Compare byte with null terminator
    beq end_receive       		@ Branch to end_receive if byte is a null terminator
    strb r2, [r1, r3]     		@ Store byte to buffer pointed to by R1 and indexed by R3
    add r3, r3, #1       		@ Increment buffer index
    b loop                		@ Branch to beginning of function to receive next byte
end_receive:
    mov r2, #'\0'         		@ Store null terminator at end of buffer
    strb r2, [r1, r3]
    bx lr                 		@ Return from function
```
    
___
Function D (port_forward) connects two UARTs and forwards incoming characters from one UART to the other UART. 
- It uses the memory-mapped registers UART4_RX and UART5_TX to read and write bytes respectively.
- Uses one UART to listen for incoming characters, and resends them on the other UART.
___

```
port_forward:
	ldr r2, =UART4_RX 		@ Load address of UART4 receive data register
	ldr r3, =UART5_TX 		@ Load address of UART5 transmit data register
loop:
	ldrb r0, [r2]     		@ Load byte from UART4 RX register
	strb r0, [r3]     		@ Store byte to UART5 TX register
	b loop            		@ Branch to beginning of function to continue forwarding

					@ Here, UART4_RX and UART5_TX are memory-mapped registers representing the UART receive and transmit @ data registers for UART4 and UART5, respectively.
```

___
