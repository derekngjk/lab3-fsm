# Task 0

## Introduction to GTest

We specify test cases in GTest as follows. The statement EXPECT_EQ(add(2, 4), 6) means that we expect the two arguments, 6 and add(2, 4), to be equal. This is kind of similar to a statement like "assert 2 + 4 == 6"

![specifying a test case](images/[task0]test-case.png)

We assert 3 + 5 == 9 which will cause the test to fail, just to see the result.

![test case output](images/[task0]test-output.png)

# Task 1

## Linear Feedback Shift Register

We first want to implement a 4-bit linear feedback shift register (0-indexed). So on every clock cycle, each bit shifts to the right by one flip flop, such that bit 0 goes to bit 1, bit 1 goes to bit 2, etc. Additionally, on each clock cycle, we also want to take the value of bit 2 and bit 3 (the 2 MSBs), XOR them, and pass them back to bit 0 so bit 0 will be updated to that value on the next cycle. Hence it is a linear feedback shift register.

![LFSR circuit diagram](images/lfsr.jpg)

This is implemented in system verilog as follows. See comments for details.

![LFSR SV implementation](images/[task1]lfsr_sv.png)

We then run the tests using verify.sh which uses the verify.cpp testbench. It tests the reset signal, and additionally, it simply steps through the simulation one cycle at a time, and at each cycle, it verifies whether the data_out matches the expected value.

![LFSR SV verification](images/[task1]lfsr_verify.png)

## Extension to 7-bit LFSR

We now want to extend the linear feedback shift register to 7 bits. We want to implement the 7-bit LFSR using a primitive polynomial 1 + X^3 + X^7. This will enable the shift register to cycle over all 128 values. 

Suppose the 7-bit shift register gives the 7-bit number X[7:1] (1-indexed). X^3 indicates bit 3 i.e. X[3] and X^7 indicates X[7]. So from the primitive polynomial we have 1 + X[3] + X[7] = 0. Since this is binary addition (modulo 2), we have X[3] + X[7] = 1. We can then write 1 = X[0], such that X[0] = X[3] + X[7].

Hence, from this equation, we can implement the LFSR such that on each clock cycle, we shift bits 6:0 to 7:1, and then we XOR bit 3 and bit 7 and pass it as input to X[1], the LSB. We implement it as follows:

![LFSR-7 SV](images/[task1]lfsr_7_sv.png)

Again, we run the unit tests, which cycle over all 128 elements and check if the output is equal to the expected value.

![LFSR-7 Verify](images/[task1]lfsr_7_verify.png)

# Task 2

## Formula 1 Light Sequence FSM

We now want to implement a FSM that cycles through a sequence of states. We start from the idle state 00000000, then we go to 00000001, 00000011, 00000111 etc until we reach 11111111, and then we go back to all 0s. The Moore diagram of the state machine is shown as follows:

![F1 sequence Moore diagram](images/state_diag.jpg)

We implement the FSM in system verilog as follows. See comments for details

![F1 SV](images/[task2]fsm_sv.png)

This gives us the following test output. Again the tests is just cycling through the sequence to verify that the output matches the expected.

![F1 sequence test](images/[task2]fsm_sv_verify.png)

## Interface with VBuddy light strip

Next we want to connect the FSM to vbuddy. We want to use the switch on the rotary encoder with vbdFlag() set to mode 1 i.e. single-shot mode. Recall this is the mode where pressing the switch will set vbdFlag() to 1, then after we read it, it will immediately go back to 0. We can then use the vbdFlag() value as the en input, such that whenever we press the switch and read the flag value, the fsm will go to the next state, then afterwards vbdFlag() will go back to 0 so the FSM stays until we press the switch again.

We implement the testbench to interface with Vbuddy as follows. See comments for details

![F1 sequence testbench](images/[task2]fsm_tb.png)

This gives us the following output. When we press the switch, the lights light up one by one until all 8 are lighted up, then it goes back to no lights.

![F1 vbuddy output 1](images/[task2]vbd_out_1.jpg)
![F1 vbuddy output 2](images/[task2]vbd_out_2.jpg)
![F1 vbuddy output 3](images/[task2]vbd_out_3.jpg)
![F1 vbuddy output 4](images/[task2]vbd_out_4.jpg)