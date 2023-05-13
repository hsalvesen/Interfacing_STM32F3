# Testing Process for Exercise 1

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





# Testing Process for exercise 2

To test the correctness of exercise 2a, all the possible combinations of anticlockwise and the lights 1-7 were tested, with every single testcase working.

To test the correctness of exercise 2c, a range of different strings were tested. It was assumed that each character's ASCII value was converted to 8 bit binary, and then displayed in the 8 light circle, until the null termination character.

