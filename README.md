Original e-Reader GBA run
==========================

Run ./run.sh to get a working raw file (boots to black screen)


Z80/8080 Format

The e-Reader doesn’t support the following Z80 opcodes:
```
  CB [Prefix]     E0 RET PO   E2 JP PO,nn   E4 CALL PO,nn   27 DAA    76 HALT
  ED [Prefix]     E8 RET PE   EA JP PE,nn   EC CALL PE,nn   D3 OUT (n),A
  DD [IX Prefix]  F3 DI       08 EX AF,AF'  F4 CALL P,nn    DB IN A,(n)
  FD [IY Prefix]  FB EI       D9 EXX        FC CALL M,nn    xx RST 00h..38h
```
That is leaving not more than six supported Z80 opcodes (DJNZ, JR, JR c/nc/z/nz), everything else are 8080 opcodes. Custom opcodes are:
```
  76 WAIT A frames, D3 WAIT n frames, and C7/CF RST 0/8 used for API calls.
```
The load address and entrypoint are at 0100h in the emulated Z80 address space. The Z80 doesn’t have direct access to the GBA hardware, instead video/sound/joypad are accessed via API functions, invoked via RST 0 and RST 8 opcodes, followed by an 8bit data byte, and with parameters in the Z80 CPU registers. For example, “ld a,02h, rst 8, db 00h” does return to the e-Reader BIOS.

The Z80/8080 emulation is incredibly inefficient, written in HLL code, developed by somebody whom knew nothing about emulation nor about ARM nor about Z80/8080 processors.
Running GBA-code on Japanese/Original e-Reader

Original e-Reader supports Z80 code only, but can be tweaked to run GBA-code:
```
  retry:
   ld bc,data // ld hl,00c8h      ;src/dst
  lop:
   ld a,[bc] // inc bc // ld e,a  ;lsb
   ld a,[bc] // inc bc // ld d,a  ;msb
   dw 0bcfh ;aka rst 8 // db 0bh  ;[4000000h+hl]=de (DMA registers)
   inc hl // inc  hl // ld a,l
   cp a,0dch // jr nz,lop
  mod1 equ $+1
   dw 37cfh ;aka rst 8 // db 37h  ;bx 3E700F0h
  ;below executed only on jap/plus... on jap/plus, above 37cfh is hl=[400010Ch]
   ld a,3Ah // ld [mod1],a                  ;bx 3E700F0h (3Ah instead 37h)
   ld hl,1 // ld [mod2],hl // ld [mod3],hl  ;base (0200010Ch instead 0201610Ch)
   jr retry
  data:
  mod2 equ $+1
   dd loader         ;40000C8h dma2sad (loader)            ;\
   dd 030000F0h      ;40000CCh dma2dad (mirrored 3E700F0h) ; relocate loader
   dd 8000000ah      ;40000D0h dma2cnt (copy 0Ah x 16bit)  ;/
  mod3 equ $+1
   dd main           ;40000D4h dma3sad (main)              ;\prepare main reloc
   dd 02000000h      ;40000D8h dma3dad (2000000h)          ;/dma3cnt see loader
   .align 2          ;alignment for 16bit-halfword
  org $+201600ch     ;jap/plus: adjusted to org $+200000ch
  loader:
   mov r0,80000000h  ;(dma3cnt, copy 10000h x 16bit)
   mov r1,04000000h  ;i/o base
   strb r1,[r1,208h] ;ime=0 (better disable ime before moving ram)
   str r0,[r1,0DCh]  ;dma3cnt (relocate to 2000000h)
   mov r15,2000000h  ;start relocated code at 2000000h in ARM state
  main:
   ;...insert/append whatever ARM code here...
   end
```
