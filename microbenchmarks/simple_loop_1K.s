	.file	"simple_loop_1K.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	movl	$0, %eax
.L2:
	addl	%eax, a(,%rax,4)
	addq	$1, %rax
	cmpq	$1024, %rax
	jne	.L2
	rep
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.comm	e,4096,32
	.comm	d,4096,32
	.comm	c,4096,32
	.comm	b,4096,32
	.comm	a,4096,32
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
