.syntax unified
.thumb

.global assembly_function

.data

.align

sample_string: .asciz "ThIs Is.a SaM.pLe.5trInG" // Define a null-terminated sample string

.text

assembly_function:
	LDR R1, =sample_string // Load a pointer to sample_string into R1.

	// Below are the functions for each of the three exercises.
	// They will be turned into proper functions with regular returns once we have learned how to use the stack.
	// Uncomment them depending on which exercise you want.

	// LDR R2, =0x01
	// B E1_a
	E1_a_return:

	// B E1_b
	E1_b_return:

	B E1_c
	E1_c_return:

forever_loop:
	// Loop forever when program finishes
	B forever_loop

E1_a:
	// If R2=1, convert all characters in the string pointed to in R1 to uppercase
	// Otherwise, convert all to lowercase

	CMP R2, #0x00			// Compare the value in R2 with 0
	BEQ E1_a_if_R2_is_0		// Branch based on the result of the comparison

	E1_a_if_R2_is_1:
		// Convert string to uppercase
		LDRB R0, [R1]		// Load next character from sample_string into R0
		BL E1_make_upper	// Run the make_upper function to make it uppercase
		STRB R0, [R1]		// Store the uppercase character back into the sample_string
		ADD R1, R1, #01		// Increment the pointer regsiter (R1)
		CMP R0, #00			// Compare the character to 0 (null) to determine if the string is finished
		BNE E1_a_if_R2_is_1	// If it isn't zero go back to the beginning of the loop
		B E1_a_endif_R2		// At the end go to the end of the function

	E1_a_if_R2_is_0:
		// Convert string to lowercase
		LDRB R0, [R1]		// Load next character from sample_string into R0
		BL E1_make_lower	// Run the make_lower function to make it lowercase
		STRB R0, [R1]		// Store the lowercase character back into the sample_string
		ADD R1, R1, #01		// Increment the pointer regsiter (R1)
		CMP R0, #00			// Compare the character to 0 (null) to determine if the string is finished
		BNE E1_a_if_R2_is_0	// If it isn't zero go back to the beginning of the loop
		B E1_a_endif_R2		// At the end go to the end of the function

	E1_a_endif_R2:

	B E1_a_return

E1_b:
	// Convert all vowels in the string at R1 to lowercase and all consonants to uppercase

	LDRB R0, [R1] 			// Load the next character from sample_string into R0

	// Tests the character against all upper and lowercase vowels. Since our make_upper and make_lower functions
	// test to make sure that the character is a valid letter and is the correct case, we do not have to do any extra tests.
	CMP R0, #'A'
	BEQ E1_b_if_is_vowel
	CMP R0, #'E'
	BEQ E1_b_if_is_vowel
	CMP R0, #'I'
	BEQ E1_b_if_is_vowel
	CMP R0, #'O'
	BEQ E1_b_if_is_vowel
	CMP R0, #'U'
	BEQ E1_b_if_is_vowel
	CMP R0, #'a'
	BEQ E1_b_if_is_vowel
	CMP R0, #'e'
	BEQ E1_b_if_is_vowel
	CMP R0, #'i'
	BEQ E1_b_if_is_vowel
	CMP R0, #'o'
	BEQ E1_b_if_is_vowel
	CMP R0, #'u'
	BEQ E1_b_if_is_vowel
	B E1_b_if_is_consonant // If character is not a vowel it must be a consonant (or a special character)

	E1_b_if_is_vowel:
		BL E1_make_lower		// Call the make_lower function
		B E1_b_endif_is_vowel

	E1_b_if_is_consonant:
		BL E1_make_upper		// Call the make_upper function
		B E1_b_endif_is_vowel

	E1_b_endif_is_vowel:
		STRB R0, [R1]			// Store the modified character back into the string
		ADD R1, R1, #01			// Increment the pointer
		CMP R0, #00				// Compare the character to the null-terminator
		BNE E1_b				// If it is still a character, loop again

	B E1_b_return

E1_c:
	// Convert the first character in the string and all after a fullstop to uppercase
	// All others are lowercase
	// e.g. "my.sAmPle. 5tring" -> "My.Sample. 5Tring"

	LDR R3, =0x01 					// R3 will be our `is_first` variable to store whether we have had a fullstop.

	E1_c_loop:

		LDRB R0, [R1]				// Load the next character from sample_string into R0

		CMP R3, #01					// Compare R3 to either make uppercase or make lowercase
		BNE E1_c_if_isnot_first		// Branch based on that comparison

		E1_c_if_is_first:
			// If the `is_first` register is set, we then check if the character is a valid alphabetical character using 4 comparirons
			CMP R0, #'A'
			BLT E1_c_if_isnot_char
			CMP R0, #'z'
			BGT E1_c_if_isnot_char
			CMP R0, #'Z'
			BLE E1_c_if_is_char
			CMP R0, #'a'
			BGE E1_c_if_is_char
			B E1_c_if_isnot_char

			E1_c_if_is_char:
				// If the character is alphabetical then we make it uppercase and set is_first to 0
				BL E1_make_upper
				LDR R3, =0x00
				B E1_c_loop_end

			E1_c_if_isnot_char:

			E1_c_endif_is_char:

		E1_c_if_isnot_first:
			// If the character is not first we need to check if it is a fullstop
			CMP R0, #'.'
			BEQ E1_c_if_is_fullstop
			B E1_c_if_isnot_fullstop
			E1_c_if_is_fullstop:
				// If the character is a fullstop then we set the `is_first` flag.
				LDR R3, =0x01
				B E1_c_loop_end

			E1_c_if_isnot_fullstop:
				// If it isn't a fullstop then we make it lowercase by calling the make_lower function.
				BL E1_make_lower
				B E1_c_loop_end

			E1_c_endif_is_fullstop:

		E1_c_endif_is_first:



		E1_c_loop_end:

		// At the end we store the modified character back into sample_string
		STRB R0, [R1]			// Store the char in R0 into sample_string
		ADD R1, R1, #01			// Increment the pointer to R1
		CMP R0, #00				// Check if the character is a null-terminator
		BNE E1_c_loop			// Otherwise loop again

	B E1_c_return

E1_make_upper:
	// Check if character in R0 is lowercase
	// If it is, make uppercase
	CMP R0, #'a'
	BLT E1_make_upper_endif_lower
	CMP R0, #'z'
	BGT E1_make_upper_endif_lower

	E1_make_upper_if_lower:
		SUB R0, R0, #32				// If the character is within the lowercase range, make it uppercase by subtracting 32

	E1_make_upper_endif_lower:
	BX LR

E1_make_lower:
	// Check if character in R0 is uppercase
	// If it is, make lowercase
	CMP R0, #'A'
	BLT E1_make_lower_endif_upper
	CMP R0, #'Z'
	BGT E1_make_lower_endif_upper

	E1_make_lower_if_upper:
		ADD R0, R0, #32				// If the character is within the uppercase range, make it lowercase by adding 32

	E1_make_lower_endif_upper:
	BX LR



E1_a_convert_string:

	BX LR


