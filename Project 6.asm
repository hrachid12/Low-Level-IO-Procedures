; Project 6    (Project 6.asm)

; Author: Hassan Rachid
; Last Modified: 3/14/20
; OSU email address: rachidh@oregonstate.edu
; Course number/section: 271 - 400
; Project Number: 6                Due Date: 3/15/20
; Description: A program that 

INCLUDE Irvine32.inc

; ------------------------------------------------------------------------------------------------------------
; getString
; A macro that receives input from the user and stores it 
; Receives: stringPrompt, strBuffer, charCount
; Returns: Nothing
; Preconditions: None
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------
getString MACRO stringPrompt, strBuffer, charCount
	
	pushad

	mov					edx, stringPrompt
	call	WriteString
	mov					edx, 0
	mov					edx, strBuffer
	mov					ecx, 13
	call	ReadString
	mov					charCount, eax

	popad
ENDM

; ------------------------------------------------------------------------------------------------------------
; displayString
; A macro that dispalys a string
; Receives: string
; Returns: Outputs the given string
; Preconditions: None
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------
displayString MACRO string:REQ

	push	edx

	mov					edx, string
	call	WriteString

	pop		edx
ENDM

; Global Constants
HI	=		2147483647
LO	=		-2147483648


.data

; Intro Prompts
creator			BYTE		"Project 6.asm - Created by Hassan Rachid", 0
description1	BYTE		"Please provide 10 signed decimal integers that can fit within a 32 bit register.", 0
description2	BYTE		"I will display the numbers in a list, along with their sum and their average.", 0


; getString variables
numPrompt		BYTE		"Please enter a signed integer: ", 0
numInput		BYTE		12 DUP(0)
charCount		SDWORD		?
errorMsg		BYTE		"Input not valid. Try again.", 0

; readVal variables
listNums		SDWORD		10 DUP(0)
positive		SWORD		+1
inRange			SWORD		+1

; writeVal variables
displayPrompt	BYTE		"You entered the following signed integers:", 0
sumPrompt		BYTE		"The sum of your integers is: ", 0
avgPrompt		BYTE		"The average of your integers is: ", 0
sum				SDWORD		?
avg				SDWORD		?
currentNum		BYTE		12 DUP(0)
comma			BYTE		", ", 0
negative		SDWORD		0

; farewell variable
goodbyeMsg		BYTE		"Hope you enjoyed! Goodbye!", 0



.code
main PROC

	push	offset creator					; Push required parameters for Introduction procedure onto the stack
	push	offset description1
	push	offset description2
	call	Introduction


	push	offset listNums					; Push required parameters for readVal procedure onto the stack
	push	offset errorMsg					
	push	charCount
	push	offset numInput
	push	offset numPrompt
	call	readVal


	push	offset comma					; Push required parameters for writeVal onto the stack
	push	offset currentNum
	push	offset listNums
	push	sum
	push	avg
	push	offset avgPrompt
	push	offset sumPrompt
	push	offset displayPrompt
	call	WriteVal
	call	Crlf
	call	Crlf

	push	offset goodbyeMsg				; Push required parameters for farewell
	call	farewell
	call	Crlf


	exit	; exit to operating system
main ENDP


; ------------------------------------------------------------------------------------------------------------
; Introduction:
; Introduces the programmer and the program to the user.
; Receives: creator, description1, and description2
; Returns: Nothing
; Preconditions: None
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------

Introduction PROC
	push	ebp									; Save the used registers
	mov					ebp, esp				
	

	displayString [ebp+16]						; Display program name and creator's name
	call	Crlf
	displayString [ebp+12]						; Displays the first set of instructions
	call	Crlf
	displayString [ebp+8]						; Displays second set of instructions
	call	Crlf
	call	Crlf
												; Restore registers
	pop		ebp
	ret		12

Introduction ENDP


; ------------------------------------------------------------------------------------------------------------
; readVal:
; Reads ten values from the user, validate them, and then places them in an array
; Receives: A prompt that asks the user to input a signed integer (numPrompt), a buffer with an 11 character
; limit (numInput), a variable to store the character size of the input integer (charCount), errorMsg,
; listNums to store the 10 valid integers the user provides
; Returns: strBuffer will hold the last integer input by the user in a string. listNums will be updated
; to have all ten signed integers in an array
; Preconditions: numInput can only be an array of size 12. Otherwise, the user may input an integer
; too large to fit the 32 bit register
; Registers Changed: None. All used registers are restored
; ------------------------------------------------------------------------------------------------------------

readVal PROC
	
	push	ebp										; Save the used registers
	mov					ebp, esp
	push	edi
	push	ecx
	push	eax

	mov					edi, [ebp+24]				; Move empty list to edi
	mov					ecx, 10

nextVal:
	mov					positive, 1
	getString [ebp+8], [ebp+12], [ebp+16]			; Call macro by passing numPrompt, numInput, and charCount as arguments


	push	[ebp+20]
	push	[ebp+12]
	push	[ebp+16]
	call	validateStr								; Validate users input

	cmp					positive, 0					; If invalid, get new input
	je		nextVal


	push	[ebp+16]
	push	[ebp+12]
	call	strToNum								; Convert string to num

	mov					[edi], ebx		

	cmp					positive, 0					; If num is not negative, skip negate process
	jne		skipNeg	
	mov					eax, [edi]					; Negate the newest value in edi
	neg		eax			
	mov					[edi], eax

skipNeg:
	add		edi, 4									; Point to next space in edi
	loop	nextVal

	pop		eax										; Restore registers
	pop		ecx
	pop		edi
	pop		ebp
	ret		20
readVal ENDP



; ------------------------------------------------------------------------------------------------------------
; validateStr:
; Checks to make sure that the value received by getString is valid
; Receives: numInput, charCount
; Returns: Nothing
; Preconditions: a value must be stored in numInput and charCount must be equal to the length of numInput
; Registers Changed: None. All registers used are restored
; ------------------------------------------------------------------------------------------------------------

validateStr PROC
	push	ebp									; Save registers that are used
	mov					ebp, esp
	push	esi
	push	ecx
	push	eax
	push	edx

	mov					eax, 0
	mov					esi, [ebp+12]			; Move numInput from stack to esi
	mov					ecx, [ebp+8]			; Move charCount from stack to loop counter
	mov					edx, 0					; Tracks which position is being checked
	cld

validate:										; Validate that each character is a +, -, or digit
	lodsb
	cmp					edx, 0
	jne		notFirstPos							; Only check for + or - when looking at first position
	cmp					al, 43
	je		valid
	cmp					al, 45
	je		valid

notFirstPos:									; Ensure each character is within range
	cmp					al, 48
	jl		notValid
	cmp					al, 57
	jg		notValid
	jmp		valid

notValid:										; Otherwise, give an error message and try again
	displayString [ebp+16]
	call	Crlf
	mov					positive, 0
	jmp		endValidate

valid:
	inc		edx
	loop	validate

endValidate:
	pop		edx									; Restore registers
	pop		eax
	pop		ecx
	pop		esi
	pop		ebp
	ret		12
validateStr ENDP


; ------------------------------------------------------------------------------------------------------------
; strToNum
; 
; Receives: numInput and charCount
; Returns: Integer form of numInput in ebx
; Preconditions: numInput must be validate and charCount must be the length of numInput
; Registers Changed: ebx
; ------------------------------------------------------------------------------------------------------------

strToNum PROC

	push	ebp									; Save used registers
	mov					ebp, esp
	
	push	esi
	push	ecx
	push	eax

	mov					esi, [ebp+8]			; Point to numInput
	mov					ebx, 0					
	mov					ecx, [ebp+12]			; Set loop counter to length of input (charCount)
	mov					inRange, 1
	cld 
	
start:
	lodsb										; Move first char into al
	cmp					al, 45					; Check if first char is + or -
	jne		pos

	mov					positive, 0

pos:
	cmp					al, 48					; Ensure char is within range
	jl		oor
	cmp					al, 57
	jg		oor


	imul	ebx, 10								; Convert char to numerical value
	sub		al, 48
	add		bl, al
	
oor:
	loop	start

	pop		eax									; Restore registers
	pop		ecx
	pop		esi
	pop		ebp
	ret		8
strToNum ENDP


; ------------------------------------------------------------------------------------------------------------
; WriteVal:
; Converts the integer values back to a string, displays all ten, calculated the sum, displays it, and
; calculates the average (rounded down) and displays it.
; Receives: displayPrompt, sumPrompt, avgPrompt, sum, avg, listNums, currentNum, comma
; Returns: Nothing
; Preconditions: listNums must be filled with 10 valid integers
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------

WriteVal PROC
	push	ebp
	mov						ebp, esp
	pushad

	mov						esi, [ebp+28]		; Point to listNums
	mov						ecx, 10				; Set loop counter to number of integers
	mov						ebx, 10				; For divison

	call	Crlf
	displayString [ebp+8]
	call	Crlf

nextNum:

	mov						eax, [esi]			; Move an integer to eax
	
	cmp						eax, 0
	jge		notNeg
	neg		eax
	mov						negative, 1

notNeg:
	mov						edi, [ebp+32]		; Point to currentNum
	push	edx									; Save edx

	cmp						negative, 1			; Subtract instead of add if integer is negative
	je		subt								
	mov						edx, [ebp+24]		; Add the number to sum
	add						edx, eax
	mov						[[ebp+24]], edx		; Save the updated sum
	pop		edx									; Restore edx
	jmp		nextChar							; Skip subtraction

subt:
	mov						edx, [ebp+24]		; Add the number to sum
	sub						edx, eax
	mov						[ebp+24], edx		; Store updated sum
	pop		edx

nextChar:
	cdq	
	idiv	ebx									; Divide value in eax by 10
	add						edx, 48				; Add 48 to remainder to convert int to character

	push	eax									; Save eax
	mov						eax, edx			; Move character to eax
	stosb										; Store it in currentNum 
	pop		eax									; Restore eax to quotient
	
	cmp						eax, 0				; If quotient is not zero, jump back to top
	jne		nextChar

		
	push	edi									; Push edi and add the correct sign to currentNum
	call	addSign

	push	[ebp+32]							; Reverse the string
	call	revString

	displayString [ebp+32]

	cmp						ecx, 1				; If this is the last integer, don't display comma
	je		noComma
	displayString [ebp+36]

noComma:
	add						esi, 4				; Point to next integer
	mov						negative, 0

	loop	nextNum								; Start process again



	mov						eax, [ebp+24]		; Calcuate the average
	cdq
	mov						ebx, 10
	idiv	ebx
	mov						[ebp+20], eax

	call	Crlf
	displayString [ebp+12]						; display sumPrompt

	push	[ebp+32]
	push	[ebp+24]
	call	numToStr							; Convert sum to string and display
	call	Crlf


	displayString [ebp+16]						; display avgPrompt

	push	[ebp+32]
	push	[ebp+20]
	call	numToStr							; Convert avg to string and display


	popad										; restore registers
	pop		ebx
	ret		32
WriteVal ENDP


; ------------------------------------------------------------------------------------------------------------
; revString:
; Reverses the string passed as a parameter
; Receives: Any string
; Returns: The reversed string in currentNum
; Preconditions: + or - MUST be at the end of the string
; Registers Changed: None. All registers are restored
; ------------------------------------------------------------------------------------------------------------

revString PROC
	push	ebp
	mov						ebp, esp
	pushad

	mov						esi, [ebp+8]		; Point to the string being reversed
	mov						ecx, 0				; Initialize character counter to 0


pushToStack:
	mov						eax, [esi]			; Move a character to eax
	push	eax									; Push to the stack
	inc		ecx									; Increase character count by 1
	inc		esi									; Point to next character
	cmp						al, 45				; If character is + or -, then stop pushing to the stack
	je		endPush
	cmp						al, 43
	je		endPush
	jmp		pushToStack
	
endPush:
	mov						esi, [ebp+8]		; Reset esi

rev:
	pop		eax									; Pop a character off the stack
	mov						[esi], al			; Overwrite esi
	inc		esi
	loop	rev

	mov						al, 0				; Add null to end of string
	mov						[esi], al


	popad
	pop		ebp
	ret		4
revString ENDP


; ------------------------------------------------------------------------------------------------------------
; addSign:
; Adds a + or - to the end of a string
; Receives: A string
; Returns: The string with a + or - at the end of the string
; Preconditions: The string must be pointing to the position where + or - will be added
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------
addSign PROC

	push	ebp
	mov						ebp, esp
	pushad

	mov						edi, [ebp+8]		; Point to the string

	cmp						negative, 1			; Add + or - based on positive or negative
	jne		addPosSign
	mov						eax, 45
	stosb
	jmp		endProc

addPosSign:
	mov						eax, 43
	stosb

endProc:
	
	popad
	pop		ebp
	ret		4
addSign ENDP



; ------------------------------------------------------------------------------------------------------------
; numToStr
; Converts a number to a string
; Receives: An integer, currentNum (a string to overwrite)
; Returns: The converted number in currentNum
; Preconditions: None
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------

numToStr PROC
	push	ebp
	mov						ebp, esp
	pushad

	mov						eax, [ebp+8]		; Point to value being converted
	mov						edi, [ebp+12]		; Point to currentNum
	mov						ebx, 10
	mov						negative, 0

	cmp						eax, 0				; Check if number is positive or negative
	jge		next								; Skips negate if positive
	neg		eax									; Negate if negative
	mov						negative, 1

next:
	cdq	
	idiv	ebx									; Divide value in eax by 10
	add						edx, 48				; Add 48 to remainder to convert int to character

	push	eax									; Save eax
	mov						eax, edx			; Move character to eax
	stosb										; Store it in currentNum 
	pop		eax
	
	cmp						eax, 0
	jne		next


	push	edi									; Add the correct sign to the number
	call	addSign

	push	[ebp+12]							; Reverse the string
	call	revString

	displayString [ebp+12]						; Display the number


	popad
	pop		ebp
	ret		8
numToStr ENDP


; ------------------------------------------------------------------------------------------------------------
; farewell
; Says goodbye to the user
; Receives: goodbyeMsg
; Returns: Nothing
; Preconditions: None
; Registers Changed: None. All registers restored
; ------------------------------------------------------------------------------------------------------------

farewell PROC
	push	ebp
	mov						ebp, esp
	pushad

	displayString [ebp+8]

	popad
	pop		ebp
	ret		4

farewell ENDP
END main
