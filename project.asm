.model tiny

.data

porta equ 10h	;PORT A of 8255
portb equ 12h	;PORT B of 8255
portc equ 14h	;PORT C of 8255
cw equ 16h	;Address of control word

.code 
.startup

CALL LCD_INIT 
CALL START


LCD_INIT PROC NEAR
	push ax
	push cx
	MOV AL, 38H		;initialise line of LCD	
	CALL WRITE_COMND	
	CALL DELAY
	CALL DELAY
	CALL DELAY
	MOV AL, 0EH
	CALL WRITE_COMND
	CALL DELAY
	MOV AL,01		;Clearing the LCD
	CALL WRITE_COMND
	MOV AL,06		;Pushing the cursor right
	CALL WRITE_COMND
	CALL DELAY
	pop cx
	pop ax
	RET
LCD_INIT ENDP


CLEAR PROC
	push ax
	push cx
	MOV AL,01
	CALL WRITE_COMND
	CALL DELAY
	CALL DELAY
	pop cx
	pop ax
	RET
CLEAR ENDP

WRITE_COMND PROC
	push dx
	push ax
	push cx
	MOV DX,PORTA
	OUT DX, AL		;character sent to PORT A
	MOV DX, PORTB
	MOV AL,00000100B		;RS=0,R/W=0,E=1 for H-To-L pulse 
	OUT DX, AL		;signal enabled on next clock pulse
	NOP
	NOP
	MOV AL,00000000B		;RS=0,R/W=0,E=0 for H-To-L pulse
	OUT DX, AL		;signal disbaled on next clock pulse
	pop cx 
	pop ax
	pop dx
	RET
WRITE_COMND ENDP

WRITE_IC PROC NEAR
	PUSH AX
	PUSH DI
	MOV AX,DI
	CMP AX,0FFEH
	JNZ RAMT2
	
	RAMT1:			;Printing the IC number 6116
	MOV AX,0000H
	MOV AL,'6'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'1'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY	
	MOV AL,'1'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'6'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	JMP EOF

	RAMT2:			;Printing the IC number 62256
	MOV AX,0000H
	MOV AL,'6'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'2'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'2'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'5'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'6'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	EOF:
	POP DI
	POP AX
	RET
WRITE_IC ENDP


WRITE_PASS PROC NEAR
	push dx
	push cx
	push ax
	CALL CLEAR
	MOV AL,'P'		;Printing PASS
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'A'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL, 'S'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'S'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	pop ax
	pop cx
	pop dx
	RET
WRITE_PASS ENDP


WRITE_FAIL PROC NEAR
	push dx
	push cx
	push ax
	CALL CLEAR
	MOV AL,'F'		;Printing FAIL
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'A'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'I'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	MOV AL,'L'
	CALL WRITE_DATA
	CALL DELAY
	CALL DELAY
	pop ax
	pop cx
	pop dx
	RET
WRITE_FAIL ENDP


WRITE_DATA PROC
	PUSH DX
	push ax
	MOV DX, PORTA
	OUT DX, AL
	MOV AL, 00000101B
	MOV DX, PORTB
	OUT DX, AL
	MOV AL, 00000001B
	OUT DX, AL
	pop ax
	POP DX
	RET
WRITE_DATA ENDP


DELAY PROC
	push cx
	push ax
	MOV CX,1325	;setting counter to produce delay.
	W1:
	NOP
	NOP
	NOP
	NOP
	NOP
	LOOP W1
	pop ax
	pop cx
	RET
DELAY ENDP

READ_MEM PROC NEAR
	push dx
	push cx
	push ax
	mov ax,1000h
	mov ds,ax
	pop ax
	mov al,[si]	;Reading byte from memory
	call DELAY
	pop cx
	pop dx 
	RET

READ_MEM ENDP

LOAD_MEM PROC NEAR
	push dx
	push cx
	MOV AL,CH	;Setting bit to 0 or 1
	mov [si],al	;Pushing byte into memory

	CALL DELAY
	mov cl,al		;Printing the bit that has been added
	add al,'0'
	call WRITE_DATA
	call delay
	call delay
	call delay
	call CLEAR
	mov al,cl
	pop cx
	pop dx
	RET
LOAD_MEM ENDP
	

START PROC NEAR

	;mov ax,0000h
	;mov ds,ax

	MOV AL,10001001B		;Setting PORT C as input and PORT A,B as output
	OUT CW, AL
	IN AL, PORTC	
	AND AL,01H
	JZ RAM2

	RAM1: MOV di, 0FFEH	;If the SRAM 6116 is selected; max offset of 6116 is 0FFEH
	mov dx,0004H		;actual end is 0FFEH as stated above; this is for testing
	;mov dx, 0FFEH
	mov si,0000h
	push ax
	mov ax,2000h
	mov ds,ax
	pop ax
	JMP TESTING 
	RAM2: MOV di,0FFFEH	;If the SRAM 62256 is selected; max offset of 62256 is FFFEH
	mov dx,0004H		;actual end is 0FFFEH as stated above; This is for testing
	;mov dx,0FFFEH
	mov si,0000h
	push ax
	mov ax,1000h
	mov ds,ax
	pop ax
	TESTING:
	
	MOV BH,00H
	MOV BL,01H

	REPEAT1:
	MOV AH,08H	;Setting the counter for each byte

	REPEATING:
	mov al,00h
	MOV CH,BH	
	CALL LOAD_MEM
	CALL READ_MEM
	AND AL,BL
	mov cl,al		;Printing the bit that has been read
	add al,'0'		;Offsetting the bit with respect to '0'
	call WRITE_DATA
	call delay
	call delay
	call delay
	call CLEAR
	mov al,cl		
	CMP AL,CH	;Compare the zero loaded and read
	JNZ LAST
	
	MOV CH,BL
	CALL LOAD_MEM
	CALL READ_MEM
	AND AL, BL
	mov cl,al		;Printing the bit that has been read
	add al,'0'
	call WRITE_DATA
	call delay
	call delay
	call delay
	call CLEAR
	mov al,cl
	CMP AL,CH	;Compare the one loaded and read
	JNZ LAST

	ROL BL,01		;Shifitng the 1 in BL by 1 unit towards left
	DEC AH		;Decreasing counter
	mov al,cl		
	JNZ REPEATING

	call write_pass	;Printing PASS for every byte that is correct
	call write_ic	;Printing IC number every byte that is correct
	call CLEAR
	
	inc si
	inc si		;memory has been odd/even banked
	mov cx,ax		;Printing the last byte of si to show it is increasing
	mov ax,si		
	and ax, 000Eh
	ror al,01
	add al,'0'
	call write_data
	call delay
	call delay
	call delay
	call clear
	mov ax,cx
	mov cx,0000h
	cmp si, dx		;Comparing with final address of the SRAM chip
	JNZ TESTING
	CALL WRITE_PASS	;Printing PASS when the memory passes the test
	CALL WRITE_IC	;Printing IC number when the memory passes the test
	JMP ENP
	
	LAST: CALL WRITE_FAIL	;Printing FAIL when the memory fails the test
	CALL WRITE_IC		;Printing IC number when the memory fails the test
	ENP :			;Printing PASS to signify the end of testing
	RET
	
START ENDP

.EXIT
END
	



	