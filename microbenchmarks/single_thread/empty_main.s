	.file	"empty_main.c"
	.comm	temp,4,4
	.comm	fasdf,4,4
	.comm	temp2,4,4
	.text
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	INSTRUMENT_ON, .-INSTRUMENT_ON
	.globl	INSTRUMENT_OFF
	.type	INSTRUMENT_OFF, @function
INSTRUMENT_OFF:
.LFB1:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE1:
	.size	INSTRUMENT_OFF, .-INSTRUMENT_OFF
	.globl	main
	.type	main, @function
main:
.LFB2:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, %eax
	call	INSTRUMENT_ON
	movl	temp2(%rip), %eax
	movl	%eax, temp(%rip)
	movl	$0, %eax
	call	INSTRUMENT_OFF
	movl	$0, %eax
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
