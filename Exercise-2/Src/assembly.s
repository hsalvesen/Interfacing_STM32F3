.syntax unified
.thumb

.global assemblyFunction

// Clock registers
.equ RCC, 0x40021000
.equ AHBENR, 0x14
.equ myData,0x100000
@.equ Ascii, 'c'
// Relevant bits to enable GPIO
.equ Anticlockwise, 0x1000
.equ Clockwise, 0x1000
.equ GPIOA_ENABLE, 17
.equ GPIOE_ENABLE, 21

// Port A & E base address and mode selection
.equ GPIOA_BASE, 0x48000000
.equ GPIOE_BASE, 0x48001000
.equ MODER, 0x00

// Input and output registers for GPIO ports
.equ IDR, 0x10
.equ ODR, 0x14

// Define variables
.data
.align

String: .asciz "ababab"

// Define code
.text

assemblyFunction:

	// Prereqs to use GPIO pins
	BL enableClocks
	BL setupGPIO

	// R0 will always hold Port A's base address
	LDR R0, =GPIOA_BASE
	LDR R1, =4 @Change this to anticlockwise for anticlockwise spinning
	LDR R2, =3@Change this for the number of lights moving


	 @Change this for lights

	// R6 will always hold Port E's base address
	LDR R6, =GPIOE_BASE
	LDRB R3, =0b00000001 @edit this to change which LEDs are on or off
	LSL R3, R3,R2
	SUB R3, R3, #1@ Adjusting R3 to add the extra LEDs being on.


	CMP R1, Anticlockwise
	BEQ anticlockwise
	BL clockwise

anticlockwise:
	LDRB R1, [R0, #IDR] // Get the input register values of Port A
	ANDS R1, #0x01 // Check if the first bit is set. S is added for condition to branch
	BNE ModeSwitch@ If button pressed, then mode is changed.

	STRB R3, [R6, #ODR + 1] // Store the value in ODR [15:8]
	//Adding a slight delay so that the changes in lights are easily visible
	delay:
	   LDR R5, =myData
	loop:
	   SUBS R5, R5, #1
	   BNE loop
	LDR R8, =0b00000001
	AND R4,R3,R8
	CMP R4, #0x01 @Checking if R3 is pushing a '1' out right
	BEQ WrapAroundAnti
	LSR R3, R3, #1


	BL anticlockwise

clockwise:
	LDRB R1, [R0, #IDR] // Get the input register values of Port A
	ANDS R1, #0x01 // Check if the first bit is set. S is added for condition to branch
	BNE ModeSwitch

	STRB R3, [R6, #ODR + 1] // Store the value in ODR [15:8]
	delay1:
	   LDR R5, =myData
	loop1:
	   SUBS R5, R5, #1
	   BNE loop1
	LDR R8, =0b10000000 @Checking if R3 is pushing a '1' out right
	AND R4,R3,R8
	CMP R4, #0b10000000
	BEQ WrapAroundClockwise
	LSL R3, R3, #1



	BL clockwise

ModeSwitch:

	LDR R4, =String    @ Load the address of the string into r0
    MOV R1, #0      @ Initialize a counter in r1 to 0
    LDRB R5, [R4], #1   @ Load a byte from the string into r2 and increment r0

	BL waitForButton

waitForButton:

	LDRB R1, [R0, #IDR] // Get the input register values of Port A
	ANDS R1, #0x01 // Check if the first bit is set. S is added for condition to branch


	BEQ waitForButton

waitForUnpress:
	LDRB R1, [R0, #IDR] // Get the input register values of Port A
	ANDS R1, #0x01 // Check if the first bit is set. S is added for condition to branch
	BEQ pressed
	BL waitForUnpress
pressed:

	STRB R5, [R6, #ODR + 1] // Store the value in ODR [15:8]
	LDRB R5, [R4], #1   @ Load a byte from the string into R5 and increment R5
	CMP R5, #0//If null terminator found, then revert back to the start of the string
	BEQ revert
	BL waitForButton // Return from function call

revert://Reverts back to the start of the string
	LDR R4, =String
	BL waitForButton

WrapAroundAnti: @Wraps the pushed out bit around to the right
	LSR R3, R3, #1 @Pushes out the bit
	LDR R7, =0b10000000
	ORR R3, R7 @Brings the bit back
	BL anticlockwise
WrapAroundClockwise:@Wraps the pushed out bit around to the left
	LSL R3, R3, #1@Pushes out the bit
	LDR R7, =0b00000001
	ORR R3, R7@Brings the bit back
	BL clockwise


enableClocks:
	LDR R0, =RCC // Load register with clock base adderss
	LDR R1, [R0, #AHBENR] // Load R1 with peripheral clock register's values
	ORR R1, 1 << GPIOA_ENABLE | 1 << GPIOE_ENABLE // Set relevant bits to enable clocks for Port A and E
	STR R1, [R0, #AHBENR] // Store the valye back into the preipheral clock register
	BX LR // Return from function

setupGPIO:

	// LEDs
	LDR R0, =GPIOE_BASE // Load base address of Port E's GPIO
	LDRH R2, =0x5555 // value to set 8 pins (the LEDs) to output
	STRH R2, [R0, #MODER+2] // Actually set the values in the high 16 bits of the mode register


	// Push button
	LDR R0, =GPIOA_BASE // Load register 0 with GPIOA address
	LDRB R1, [R0, #MODER] // Load register 1 with the lowest byte in R0 offset by 0
	AND R1, #0b11111100 // Clear bits for PA0, but leave the rest as they are
	STRB R1, [R0, #MODER] // Store result in GPIOA's low byte

	BX LR // Return from function
