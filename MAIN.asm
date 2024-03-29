;Binary 16-bit real-mode adder
;by Tatarinov Vladimir
;Public DOMAIN, 2019
;Absolutely NO WARRANTY
;Use FASM
org 7c00h      ; set location counter.
STARTUP:
CLI
MOV AX, CS
CMP AX,0
JNZ NO_START
MOV DS,AX
MOV ES,AX
MOV SS,AX
MOV SP, 07C00h
MOV BP, 07C00h
LEA AX, [OVERFLOW]
MOV DI, 00H
MOV [DI], AX
MOV DI, 10H
MOV [DI], AX
XOR AX, AX
MOV DI, 02H
MOV [DI], AX
MOV DI, 12H
MOV [DI],AX
STI
MAIN:
LEA SI, [MSG]
CALL CLS
CALL PRINT_STR
HANG:
LEA DI, [NUMBER]
XOR AX, AX
MOV [DI], AX
LEA SI,[INPUT_MSG]
CALL PRINT_STR
CALL NUM_INPUT
LEA SI, [NUMBER]
LEA DI, [NUMBER_2]
MOV AX, [SI]
MOV [DI], AX
LEA DI, [NUMBER]
XOR AX, AX
MOV [DI], AX
LEA SI,[INPUT_MSG]
CALL PRINT_STR
CALL NUM_INPUT
LEA SI, [NUMBER]
MOV AX, [SI]
LEA SI, [NUMBER_2]
MOV BX, [SI]
ADD AX, BX
LEA DI, [NUMBER]
MOV [DI], AX
CALL NUM_OUT
JMP HANG

CLS:
XOR BX, BX
MOV AH, 00H
MOV AL, 03H
INT 10H
RET


PRINT_STR: MOV AH, 0EH
MOV AL, [SI]
XOR BX,BX
CMP AL, 0
JZ PRINT_STR_EXIT
INT 10H
INC SI
JMP PRINT_STR
PRINT_STR_EXIT: RET

READ_KEY:
MOV AH, 00H
INT 16H
RET

NUM_INPUT:
CALL READ_KEY
CMP AL, 13;ENTER - ?
JZ NUM_INPUT_EXIT
CMP AL, 8 ;BACKSPACE - ?
JZ NUM_INPUT
CMP AL, 7Fh ;DELETE - ?
JZ NUM_INPUT
CMP AH, 83
JZ NUM_INPUT
CMP AL, 20h ;SPACE - ?
JZ NUM_INPUT
CMP AL, 9
JZ NUM_INPUT
LEA DI, [BYTE_OUT]
LEA SI, [BYTE_OUT]
MOV [DI], AL
pusha
CALL PRINT_STR
popa
LEA DI, [NUMBER]
LEA SI, [NUMBER]
sub AL, '0'
cmp AL, 9
JA NOT_A_NUMBER
;AL - NUMBER FROM KEYBOARD
MOV CL, AL
MOV AX, [SI]
MOV BX, 10
MUL BX
MOV CH, 0
ADD AX, CX
MOV [DI], AX
JMP NUM_INPUT
NUM_INPUT_EXIT:
LEA SI, [END_LINE]
CALL PRINT_STR
RET

NUM_OUT:
LEA SI, [NUMBER]
MOV AX, [SI]
XOR CX,CX
PUSH CX
NUM_OUT_LOOP:
XOR DX,DX
MOV BX, 10
DIV BX
XOR CH, CH
MOV CL, '0'
ADD DX, CX
push dx
CMP AX, 0
JZ NUM_OUT_EXIT
JMP NUM_OUT_LOOP
NUM_OUT_EXIT:
POP AX
CMP AX,0
JZ NUM_OUT_RET
XOR BX,BX
MOV AH, 0EH
INT 10H
JMP NUM_OUT_EXIT
NUM_OUT_RET:LEA SI, [END_LINE]
CALL PRINT_STR
RET

OVERFLOW:   
LEA SI, [OVF_MSG]
CALL PRINT_STR
POP AX
LEA AX, [CLEAR_STACK]
PUSH AX
IRET

CLEAR_STACK:
CLI
MOV SP, 07C00h
MOV BP, 07C00h
STI
JMP HANG

NOT_A_NUMBER:
LEA SI, [NAN_MSG]
CALL PRINT_STR
JMP CLEAR_STACK

NO_START:
CLI
HLT
JMP NO_START

MSG: DB 13,10,'16-BIT ADDER',13,10,'By Tatarinov V.',13,10,'PUBLIC DOMAIN, 2019',13,10,0
INPUT_MSG: DB 'INPUT NUMBER> ',0
BYTE_OUT: DB ' ',0
END_LINE: DB 13,10,0
NUMBER DW 0
NUMBER_2 DW 0
OVF_MSG: DB 13,10,'OVERFLOW!',13,10,0
NAN_MSG: DB 13,10,'NOT A NUMBER!',13,10,0