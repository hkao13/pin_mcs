	.file	"simple_loop_1M.c"
	.comm	a,4194304,32
	.comm	b,4194304,32
	.comm	c,4194304,32
	.comm	d,4194304,32
	.comm	e,4194304,32
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	movl	$0, -4(%rbp)
	jmp	.L2
.L3:
	movl	-4(%rbp), %eax
	cltq
	movl	b(,%rax,4), %eax
	movl	%eax, %edx
	addl	-4(%rbp), %edx
	movl	-4(%rbp), %eax
	cltq
	movl	%edx, a(,%rax,4)
	addl	$1, -4(%rbp)
.L2:
	cmpl	$1048575, -4(%rbp)
	jle	.L3
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
