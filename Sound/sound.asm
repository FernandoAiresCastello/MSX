.org	4000h
.rom
.bios
.start	MAIN

MAIN:
	CALL	INIT32
	LD		HL, STR_HELLO
	LD		DE, 1800h
	LD		BC, 12
	CALL	LDIRVM
	
	CALL	START_PSG_A
	LD		HL, SONG_1
	CALL	PLAY_PSG_A
	CALL	STOP_PSG_A

END:
	JR		END
	
; Play tone sequence through channel A
; Entry: HL = Seq address
PLAY_PSG_A:
	LD		A, [HL]
	CP		'C'
	JR		Z, @@PLAY_C
	CP		'D'
	JR		Z, @@PLAY_D
	CP		'E'
	JR		Z, @@PLAY_E
	JP		@@PLAY_UNDEFINED
@@PLAY_C:
	LD		BC, 0100h
	JP		@@PLAY_OK
@@PLAY_D:
	LD		BC, 0200h
	JP		@@PLAY_OK
@@PLAY_E:
	LD		BC, 0300h
	JP		@@PLAY_OK
@@PLAY_UNDEFINED:
	LD		BC, 0
	JP		@@PLAY_OK
@@PLAY_OK:
	CALL	SET_PSG_FREQ_A
	
	LD		BC, 3000h
	CALL	DELAY_SHORT

	INC		HL
	XOR		A
	AND		[HL]
	RET		Z

	JR		PLAY_PSG_A

; Initialize channel A tone
START_PSG_A:
	XOR		B
	XOR		C
	CALL	SET_PSG_FREQ_A
	; Enable channel A tone
	LD		A, 7
	OUT		[0A0h], A
	LD		A, 10111110b
	OUT		[0A1h], A
	; Set channel A amplitude
	LD		A, 8
	OUT		[0A0h], A
	LD		A, 00001011b
	OUT		[0A1h], A
	RET

; Disable channel A tone
STOP_PSG_A:
	LD		A, 7
	OUT		[0A0h], A
	LD		A, 10111111b
	OUT		[0A1h], A
	RET

; Set channel A tone frequency
; Entry: BC	= freq
SET_PSG_FREQ_A:
	LD		A, 0
	OUT		[0A0h], A
	LD		A, C	; LSB
	OUT		[0A1h], A
	LD		A, 1
	OUT		[0A0h], A
	LD		A, B	; MSB
	OUT		[0A1h], A
	RET

; Short delay loop
; Entry: BC = length
DELAY_SHORT:
	NOP
	DEC		BC
	LD		A, B
	OR		C
	RET		Z
	JR		DELAY_SHORT
	
STR_HELLO:
	DB		"Hello World!"
	
SONG_1:
	DB		"CDE"
