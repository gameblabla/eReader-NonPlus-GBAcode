    .area CODE (ABS)
    ERAPI_Exit                     = 0x00

    .globl data
    .globl loader
    .globl main
    
    .org 0x100
	; ?
    ld  de, #0
    ld  hl, #0
    rst 8
    .db 0x21

retry:

	ld bc,(data)
	
lop:
	ld a,(bc)
	ld a,(bc)
	
	.dw #0x0bcf
	
	inc hl
	cp a,#0x0dc
	
	mod1 .equ +1
	
	.dw #0x37cf
	
	ld a,#0x3A
	ld hl,#1
	jr retry
	
data:
	mod2 .equ +1
	.db 0x03, 0x00, 0x00, 0x00 ;dd loader, i fixed it at 0x300
	.db 0x03, 0x00, 0x00, 0xF0 ;dd #0x030000F0
	.db 0x80, 0x00, 0x00, 0x0A ;dd #0x8000000a
	mod3 .equ +1
	.db 0x03, 0x64, 0x00, 0x00 ;dd main, i fixed it at 0x364
	.db 0x02, 0x00, 0x00, 0x00 ;dd #0x02000000
	.db 0x000,0x00 ; .align 2

.org 0x300
loader:
	; ARM-only loader (see arm.asm)
	; mov r0,#0x80000000
	; mov r1,#0x40000000
	; strb r1,[r1,#0x208]
	; str r0,[r1,#0x0DC]
	; mov r15,#0x20000000
   .incbin "loaderarm.bin"

.org 0x364
	; Compiled Thumb game binary here
main:
	.incbin "game.bin"

main_exit:
    ; ERAPI_Exit()
    ; a = return value (1=restart 2=exit)
    ld  a, #2
    rst 8
    .db ERAPI_Exit


