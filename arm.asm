	mov r0,#0x80000000
	mov r1,#0x40000000
	strb r1,[r1,#0x208]
	str r0,[r1,#0x0DC]
	mov r15,#0x20000000
