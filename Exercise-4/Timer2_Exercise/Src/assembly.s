.syntax unified
.thumb

.global assembly_function


@GPIO base register addresses
.equ GPIOE, 0x48001000	@ base register for GPIOE (pe8-15 are the LEDs)
.equ GPIOE_ENABLE, 21 @ GPIOE enable offset
.equ GPIOA, 0x48000000	@ base register for GPIOA (pa0 is the button)
.equ GPIOA_ENABLE, 17


@ GPIO register offsets
.equ ODR, 0x14	@ GPIO output register
.equ IDR, 0x10
.equ MODER, 0x00	@ register for setting the port mode (in/out/etc)


@ Clock setting register (base address and offsets)
.equ RCC, 0x40021000	@ base register for resetting and clock settings
.equ TIM2, 0x40000000 @ address to TIM2
.equ TIMx_CNT, 0x24 @ address offset for TIMx_CNT
.equ TIMx_CR1, 0x0 @ offset for TIMx_CR1
.equ TIMx_PSC, 0x28 @ offset for TIMx_PSC
.equ TIMx_CCR1, 0x34 @ offset address for CCR1

.equ AHBENR, 0x14  @ enable peripherals
.equ APB1ENR, 0x1C @ offset off RCC to APB1 peripheral clock enable register

@ Clock enable
.equ TIMER2_ENABLE, 0
.equ CEN_ENABLE, 0



@ prescaler
.equ PRESCALER, 3999

.data
	@ define variables

.text
	@ define code

assembly_function:

	@ enables clock and begins counting
	BL config_clock

	@ initialise GPIOE
	BL enable_peripheral_clocks

	@ initialise discovery board
	BL initialise_discovery_board

	LDR R1, =5000 @ sets delay value (ms)

	@ sets initial pattern of LEDs
	LDR R5, =0b11110000 @ load a pattern for the set of LEDs (every second one is on)

delay_function:

	LDR R0, =TIM2 @ sets R0 as TIM2 address
	LDR R2, [R0, #TIMx_CNT] @ records current time in R2
	ADD R2, R1 @ adds current time with delay
	STR R2, [R0, #TIMx_CCR1] @ saves delay + clock time to flag later


check_timer:

	@ Check if button is pressed
	LDR R6, =GPIOA @ load GPIOA
	LDRB R7, [R6, #IDR] // Get the input register values of Port A
	ANDS R7, #0x01 // Check if the first bit is set. S is added for condition to branch
	BNE pressed // If it is set, branch to another subroutine

	@ loads initial pattern of LEDs
	LDR R4, =GPIOE  @ load the address of the GPIOE register into R0
	STRB R5, [R4, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

	@ check timer progress
	LDR R3, [R0, #TIMx_CNT]

	CMP R3, R2 @ compare current time to saved time
	BLE check_timer @ restart if threshold hasnt been reached



	@ delay passed -> change LED pattern
	EOR R5, #0xFF	@ toggle all of the bits in the byte (1->0 0->1)
	STRB R5, [R4, #ODR + 1]   @ store this to the second byte of the ODR (bits 8-15)

	B delay_function

	@ loops infinitely
inf_loop:
	B inf_loop


pressed:
	@ check if button is released

	@ Check if button is released
	LDR R6, =GPIOA @ load GPIOA
	LDRB R7, [R6, #IDR] // Get the input register values of Port A
	ANDS R7, #0x01 // Check if the first bit is set. S is added for condition to branch
	BNE pressed // If it is set, branch back to beginning

unpressed:
	@ change prescaler
	LDR R0, =TIM2 @ load TIM2 address to R0
	LDR R2, [R0, #TIMx_PSC] @ load prescaler into register
	ADD R2, 4000 @ add to prescaler
	STR R2, [R0, #TIMx_PSC] @ Set address to equal prescaler

	@ cycle counter to enable prescaler
	LDR R2, =0b11111111111111111111111111111110 @ set timer to almost overflow
	STR R2, [R0, #TIMx_CNT]

	B delay_function


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

	@ enable counter
	LDR R1, [R0, #TIMx_CR1] @ load R1 with TIM2_CR1 address
	ORR R1, 1 << CEN_ENABLE @ set 0th bit to 1 (turn on count)
	STR R1, [R0, #TIMx_CR1]  @ Store new settings to TIM2_CR1 address

	@ cycle counter to enable prescaler
	LDR R2, =0b11111111111111111111111111111110 @ set timer to almost overflow
	STR R2, [R0, #TIMx_CNT]

	BX LR @ return from function call



enable_peripheral_clocks:

	LDR R0, =RCC  @ load the address of the RCC address boundary (for enabling the IO clock)
	LDR R1, [R0, #AHBENR]  @ load the current value of the peripheral clock registers
	ORR R1, 1 << GPIOA_ENABLE | 1 << GPIOE_ENABLE  @ 21st bit is enable GPIOE clock
	STR R1, [R0, #AHBENR]  @ store the modified register back to the submodule
	BX LR @ return from function call

initialise_discovery_board:

	@ LEDs
	LDR R0, =GPIOE 	@ load the address of the GPIOE register into R0
	LDR R1, =0x5555  @ load the binary value of 01 (OUTPUT) for each port in the upper two bytes
	STRH R1, [R0, #MODER + 2]   @ store the new register values in the top half word representing
								@ the MODER settings for pe8-15

	// Push button
	LDR R0, =GPIOA // Load register 0 with GPIOA address
	LDRB R1, [R0, #MODER] // Load register 1 with the lowest byte in R0 offset by 0
	AND R1, #0b11111100 // Clear bits for PA0, but leave the rest as they are
	STRB R1, [R0, #MODER] // Store result in GPIOA's low byte

	BX LR @ return from function call

