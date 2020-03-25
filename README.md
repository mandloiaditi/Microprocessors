# Microprocessors

Project for course CS F241 MICROPROCESSOR PROGRAMMING AND INTERFACING BITS Pilani

Problem Statement 
P11 Design a microprocessor based RAM tester. The tester should be able to test 6116 and  62256 RAM chips. 
The tester test each bit of the RAM individually. For a byte of RAM, the first bit (D0) is written as zero and read back, 
now a one is written into the bit and again it is read back. If the two read operations result in bit D0 to contain a zero
and one respectively then the bit is inferred as good. Any other result indicates a faulty bit. The test is repeated for 
all bits of a byte and for all bytes of the RAM. The results of the test along with the RAM IC number are to be displayed 
on LCD as "PASS" or "FAIL".
