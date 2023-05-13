# MSLH


This document serves to document high-level information about the practical implementation of assembly language to program a STM32F303 microcontroller to achieve specific MTRX2700 ASM Lab objectives.

___
___

## Group members, Responsibilities
1. Mansh Saxena  520425756      Exercise 2
2. Haz Salvesen  490480278      Exercise 3 & Documentation & Minutes
3. Sam Richards  520482962      Exercise 1, 5, 3
4. Luis Sanebria 510342236      Exercise 4, Test Cases
___

## Roles
MSLH functioned like a start-up, forming a lateral hierachy, where each member was responsible for their own work, and there was no one overarching lead.
___
___

## Lab Minutes
Lab minutes are recorded as READMEs, located in the corresponding "minutes" folder
___
___


# Exercise 1 - Memory and Pointers

## Overview
Exercise 1 involves working with memory and pointers with an objective to create functions that can manipulate strings stored in memory. The exercise has three tasks: 

1. A string is defined in memory, and the memory address of the string is stored in register R1.  The function E1_a then cycles through the string and based on the value stored in register R2, before converting the string to either all lowercase or all uppercase.
2. Another string is defined in memory, and its memory address is stored in register R1. The function E1_b then goes through the string and makes each vowel lowercase and each consonant uppercase.
3. A final string is defined in memory, and its memory address is stored in register R1. The function E1_c then cycles through the string and converts the first valid ASCII letter to uppercase after a full stop. It then converts all other valid ASCII characters in the string to lowercase.
___

## Modulisation
The functions are separated in an easy-to-read, intuitive, top-to-bottom ascending format, such that Exercise 1A (E1_a) is followed by E1_b and E1_c.
___

## Functions:

- E1_a: If R2=1, convert all characters in the string pointed to in R1 to uppercase. Otherwise, convert all to lowercase
- E1_a_if_R2_is_0: Convert string to lowercase
- E1_a_if_R2_is_1: Convert string to uppercase
- E1_b: Convert all vowels in the string at R1 to lowercase and all consonants to uppercase
- E1_c: Convert the first character in the string and all after a fullstop to uppercase. All others are lowercase
- E1_c_if_isnot_first: Branch based on that comparison
- E1_c_if_is_first: If the 'is_first' register is set, we then check if the character is a valid alphabetical character using 4 comparisons
- E1_c_if_is_char: If the character is alphabetical then we make it uppercase and set is_first to 0
- E1_c_if_is_fullstop: If the character is a fullstop then we set the ‘is_first’ flag.
- E1_make_upper: Check if character in R0 is lowercase. If it is, make uppercase
- E1_make_lower: Check if character in R0 is uppercase. If it is, make lowercase
___

## User Instructions:
For all functions, load the address of the string into R1. Then, call the function. Additionally, you will have to define a point for the function to return to (e.g. E1_a_return). The new string will replace the existing one.
___

## Constraints and Limitations:
The sample string is limited in size based on the amount of memory available on the device. The characters are limited to the standard ascii characters (i.e. no special characters, accents, emojis, etc.)
___

## Testing Process:
To test all parts of Exercise 1, a number of different test strings were loaded into memory and the expected outputs were compared to the actual outputs (read from the register via the debugger). The test strings were designed to cover all base and edge cases.

## Section a:

In Section a, each test case was tested with R1 = 0 and R1 = 1 to test both versions of the code.

### Test Case 1 - Upper case:
    0: ABCDE -> abcde
    1: ABCDE -> ABCDE

### Test Case 2 - Lower case:
    0: abcde -> abcde
    1: abcde -> ABCDE

### Test Case 3 - Mixed case:
    0: abCDe -> abcde
    1: abCDe -> ABCDE

### Test Case 4 - Special characters:
    0: a.Bc$D3 -> a.bc$d3
    1: a.Bc$d3 -> A.BC$D3

## Section b:

In Section b, four test cases were used to determine if the vowel-consonant case modifier worked in all circumstances

### Test Case 1 - Upper case:
    ABCDEFGHIJKLMNOPQRSTUVWXYZ -> aBCDeFGHiJKLMNoPQRSTuVWXYZ

### Test Case 2 - Lower case:
    abcdefghijklmnopqrstuvwxyz -> aBCDeFGHiJKLMNoPQRSTuVWXYZ

### Test Case 3 - Mixed case:
    aBcDEfgHijKLmnOpqRStuvWXyz -> aBCDeFGHiJKLMNoPQRSTuVWXYZ

### Test Case 4 - Special characters:
    aBcD.EfgH$ijKL%mnOpqR0Stuv@WXyz -> aBCD.eFGH$iJKL%MNoPQR0STuV@WXYZ

## Section c:

In Section c, three test cases were used to ensure that all parts of the program function properly. 

### Test Case 1 - Lower case:
    the quick.brown fox. -> The quick.Brown Fox.

### Test Case 2 - Upper case:
    THE QUICK.BROWN FOX. -> The quick.Brown fox.

### Test Case 3 - Special characters:
     hello. 12 test -> Hello. 12 Test

Once all of these test cases returned the proper expected value we were confident that the program was functioning correctly.
___
___


# Excercise 2: Digital IO 

## High Level Overview:
Exercise 2 involves programming the STM32F303 to allow for one of its buttons to manipulate the digital output of the board’s eight LEDs to provide a visualisation. The exercise consists of three tasks:

1.	The  functions anticlockwise and clockwise that "chase" an LED around the 8-LED circle. This means that only one LED should be on, and the currently on LED will move either clockwise or anticlockwise around the circle of LEDs. 
The assembly function takes a value in R1, which selects whether the LED goes clockwise or anticlockwise, and a value in R2, which selects how many LEDs should be on at the same time.

2 and 3.	Task requires the creation of a map between an ASCII character and a pattern of LEDs being on/off. The pressed function uses an ASCII value stored in R4 turns the LEDs on/off to show the pattern. The final task requires the use of the discovery board user input button to step through the characters in an ASCII string and show the LED patterns one at a time.

NB: Since the final task is an extension of this task, only the final task is shown, so R4 contains the actual string to be stepped through, whilst R5 holds each byte or character. The binary value of this register is then displayed in the 8 LEDs.
___

## Modularisation:
Numerous functions perform specific tasks, and follow an intuitive, top-to-bottom design. 
___

## Functions:
- assemblyFunction: Initialises clocks, GPIO pins and registers, and starts either the anticlockwise and clockwise spinning LEDs.
- anticlockwise: Makes the LEDs spin anticlockwise
- loop: Part of the delay function, loops and increments a value repeatedly.
- delay: Self explanatory
- clockwise: Makes LEDs spin clockwise
- delay1: Same as delay, but just kept in the function for efficiency purposes.
- loop1: Same as loop, but just kept in the function for efficiency purposes.
- ModeSwitch: Allows for mode to switch
- waitForButton: Waits for button to be pressed
- waitForUnpress: Waits for button to be unpressed
- pressed: Function that performs operation once the button pressing motion has been completed.
- revert: Reverts back to the start of the string.
- WrapAroundAnti: Wraps the binary bits around when going anticlockwise.
- WrapAroundClockwise: Wraps the binary bits around when going clockwise.
- enableClocks: Turns all GPIOA and GPIOE ports
- setupGPIO: Sets up GPIOA and GPIOE register ports
___

## User Instructions
The program starts with the rotating LEDs, either being anticlockwise or clockwise and having a predefined number of LEDs being on. If the input button is pressed, the board switches to the ASCII character stepping mode and then pressing the buttons steps through the ASCII character that is defined.
___

## Constraints & Limitations:
Limitation in scope: 
The code is specific to STM32F303 and may not be used with other hardware, limiting its adaptability.
Lack of scalability: 
The code was developed for the specific task of controlling eight LEDs, and modifications to the program will be required to handle different numbers of LEDs, restricting its scalability.
Input limitations: The program relies on a single input button to step through the ASCII characters, making it less user-friendly and less efficient in handling multiple inputs.
___

## Testing Proceedures ##:
In order to check that the anticlockwise and clockwise functions worked as expected, different inputs for R1 and R2 were provided and it wasverified that only one LED was on at a given time. The selected LED moved either clockwise or anticlockwise around the circle of LEDs.
The ASCII to LED pattern mapping was tested and verified by checking that each ASCII character in the string provided in the code generates the expected LED pattern on the board.
The string stepping functionality was tested by pressing the input button and verifying that the LED pattern changes to the next ASCII character in the string.
The wraparound functions was checked by verifying that the binary bits are wrapped around when going clockwise or anticlockwise, and that the LED pattern was still correct.
___
___


# Exercise 3 - Serial Communication:

## High Level Overview:

Exercise 3 explores UART communication on the STM32 microcontroller, where UART is an asynchronous serial communication protocol that allows two devices to communicate without sharing clock information. The exercise is divided into four tasks:

In the first task, the transmit_string function is called every second to transmit a string over USART1.
In the second task, the code uses the receive_string function to receive a null-terminated string and store it into a string with address at R1.
The third task task is the same as task 1, but implements a terminating character (\0) which terminates the string.
The final task uses the transmit_string and receive_string functions to connect the UARTS on two different STM32 boards. It listens for characters on one USART before sending it on the other USART.
___

## Modularisation
This section was designed to be modular by splitting it into multiple functions which can be individually called - e.g. the enableUSART, transmit_string, and receive_string functions.
___

## Functions
- assembly_function: The main function which gets called by the C code
- enableGPIOClocks: This function enables the clocks required to run USART
- enableUSART: This function does all the initialisation and configuration required to run USART
- transmit_string: Transmits one null-terminated string to a USART port. Requires one USART address to be loaded into R0 and the string to be loaded in R1
- receive_string: receives one null-terminated string from a USART port. Requires one USART address to be loaded into R0 and the string will be loaded into R1
___

## User Instructions
Connect the USART1 or USART3 port of the STM32 board to a computer or another STM32 board.
Open a Serial Console on your computer with a baud rate of 115200, 8 data bits, no parity, and one stop bit.

- In Task 1, the transmit_string function is called every second to transmit a string over USART1. Once the code is uploaded, the STM32 board will automatically transmit a string over USART1 every second.
- In Task 2, the code uses the receive_string function to receive a null-terminated string and store it into a string with an address at R1. 
To receive a string, type the string into the Serial Console on your computer and press enter. The string will be transmitted to the STM32 board and stored into the rxBuffer.
- Similar to Task 1, Task 3 implements a terminating character (\0) that terminates the string. 
This task is automated, and the STM32 board will automatically transmit a string over USART1 every second with a terminating character (\0).

In the final task, the transmit_string and receive_string functions are used to connect the UARTs on two different STM32 boards. 
Connect the USART1 of the first STM32 board to the USART3 of the second STM32 board and vice versa. Once the boards are connected, type a string into the Serial Console of one board, and it will be transmitted to the other board. The string will be received and printed on the Serial Console of the other board.
___

## Constraints and Limitations:
The system is constrained by the amount of USART ports available on the device, as well as the type of characters that can be sent over the USART bus. Additionally, when transmitting high amounts of data the USART protocol might not be fast enough or have enough error checking.
___

## Testing Procedure:

Since this system uses a real-time system, debugging using breakpoints is often not possible. Thus, most debugging was done by printing a lot of data to the serial port of the computer. Such as:

```
Hello40
Hello40
Hello40
Hello40
Hello40
```


This did make it quite difficult to debug when it was a serial issue, but all issues were eventually resolved. We used a list of testing strings which contained a variety of characters. We then made sure that when typed into one Serial Console, the input was mirrored in the Serial Console on the other computer.
___

# Exercise 4 - Hardware timer:

Exercise 4 focuses on the use of timers running independently in hardware to enable software to perform other tasks without needing to concern itself with measuring time. The exercise contains three tasks.

1. The first task requires a delay script that uses the hardware timer. The delay time DELAY (in milliseconds) is passed to the function through register R1.
2. The second task visualises the delay function using LEDs and demonstrates its correctness for three different timer prescaler values: 4000, 8000, 16000. Additionally, this was implemented in such a way the prescaler value could be changed with a user input button.
3. The third task uses the preload features (TIMx_ARR, and ARPE=1) to make a highly accurate delay script. the delay of which  is entirely managed in hardware.
___
## Modularisation
Sub-exercises follow the general routine:
Initialise:
- Discovery board
- External hardware timer
Set parameters
- Check hardware timer count against a user specified delay value.

## Functions:
assembly_function: Initialises hardware
delay_function: Sets variables (in registers)
check_timer: A looping function that will constantly pole a condition to see if the delay has finished.
inf_loop: infinite loop (script stopping point)
config_clock: Configures hardware timer
enable_peripheral_clocks: Enables GPIOE/GPIOA features
intialise_discovery_board: Configuring GPIOE and GPIOA
pressed: Detected when button is pressed -> checks if unpressed
unpressed: Detected button is unpressed from pressed -> restarts script with new settings
___
## User instructions:
A user can change the conditions of each delay script by changing either 2 saved values in any of the sub exercises: 
- DELAY and 
- PRESCALER. 
With a PRESCALER value of 7999 the DELAY value will be a delay in ms.
___

## Constraints and Limitations:
Both DELAY and PRESCALER values are unsigned 32 bit values (in the case of using TIMx_ARR, it can only be 32 bits using TIM_2 which is used in this exercise), as such the script will not function outside these parameters (e.g. a negative value).
___

#### Test cases:
1. Implement delay (without visual indicator)
    1. The test parameters include: a delay value of 10, prescaler of 8000. When stepping through code, code is delayed until the hardware timer CNT value exceeds 10 before proceeding with an infinite loop. This is as expected
    2. The test parameters include: a delay value of 5000, prescaler of 8000. When stepping through code, code is delayed until the hardware timer CNT value exceeds 5000 before proceeding with an infinite loop. This is as expected
    3. The test parameters include: a delay value of 0, prescaler of 8000. When stepping through code, code is not delayed and proceeds with the infinite loop. This is as expected.
2. Implement delay (without visual indicator) + button input changes prescaler value
    1. The test parameters include: a delay value of 5000, prescaler of 8000. When code is run, a pattern on LEDs turns on. After 5 seconds the pattern alternates to all on is off, all off is on. This occurs every 5 seconds. This is expected
    2. The test parameters include: a delay value of 5000, prescaler of 4000. When code is run, a pattern on LEDs turns on. After 2.5 seconds the pattern alternates to all on is off, all off is on. This occurs every 2.5 seconds. This is expected
    3. The test parameters include: a delay value of 5000, prescaler of 16000. When code is run, a pattern on LEDs turns on. After 10 seconds the pattern alternates to all on is off, all off is on. This occurs every 10 seconds. This is expected
    4. The test parameters include: a delay value of 5000, prescaler of 4000. When code is run, a pattern on LEDs turns on. Initially after 2.5 seconds the pattern alternates to all on is off, all off is on. This occurs every 2.5 seconds until a user button is pressed. The delay will then increase to 5.0 seconds. Pressing the button 2 more times on top of this increases delay to 10 seconds. This is expected.
3. Implement delay with ARPE and ARR 
    1. The test parameters include: a delay value of 5000, prescaler of 8000. When code is run, a pattern on LEDs turns on. After 5 seconds the pattern alternates to all on is off, all off is on. This occurs every 5 seconds. This is expected
    2. The test parameters include: a delay value of 5000, prescaler of 4000. When code is run, a pattern on LEDs turns on. After 2.5 seconds the pattern alternates to all on is off, all off is on. This occurs every 2.5 seconds. This is expected
    3. The test parameters include: a delay value of 5000, prescaler of 16000. When code is run, a pattern on LEDs turns on. After 10 seconds the pattern alternates to all on is off, all off is on. This occurs every 10 seconds. This is expected
___
___


# Exercise 5 - Integration: 


## High Level Overview:
Exercise 5 serves as an integration exercise, combining most of the functions created in prior exercises. The main objective is to perform a sequence of operations on three STM32 discovery boards that are connected via UARTs. The task involves are:

This task involves linking three STM32s, each performing a different task. The first USART loads a new character from a string every time a button is pressed, displays it on the inbuilt LEDs, then transmits it over USART. The second STM32 receives the character over USART, displays it to the LEDs, waits a second, before sending it to the third board. The third and final board receives the signal and displays it. The end result of this is that the first two board seem to update instantaneously when the button is pressed, then the last one updates a second later.
___

## Modularisation:
The code was split up into several functions, for example a transmit_char function and an enableUSART function. This allowed the code to be reused from previous tasks and in multiple places in code.
___

## Functions:
- assembly_function: main function which manages logic and calls the other functions
- enableClocks: Loads the peripheral clock register with the correct values to use GPIO clocks
- setupGPIO: Enable the required GPIO pins to use buttons and LEDs
- enableUSART: Configure the USART1 and USART3 ports
- enable_clock: Configure the timer for the delay function
- enable_peripheral_clocks: Enable peripheral clocks for the delay timer
- initialise_discovery_board: Set the GPIOE direction regsiter for use with delay timer
- board_x_init: Calls the relevant initialisation functions for either board 0, 1, or 2
- board_x_loop: This is the main loop for board 0, 1, and 2
___

## User Instructions:
The code requires little modification, only requiring the user to change R9 in assembly_function to select which board each is. Additionally, they must be connected correctly as per the datasheet to allow for USART communication.
___

## Constraints and Limitations:
The system is constrained as the button cannot be pressed while the delay is still occuring. This was not mentioned in the assignment notification, and it would take significant time and additional knowledge that we do not have.
___

## Testing Procedures:
To test the integration process, each board's LED patterns can be observed to see if they match the expected output. 
The UART transmission and reception can be checked by monitoring the transmitted and received characters on a computer terminal program. 
The delay function can be tested with different parameter values to ensure that the delay time is variable. 
Boards Each pair of boards (1-2, 2-3, 1-3) can be tested individually when all three are not available.
___
