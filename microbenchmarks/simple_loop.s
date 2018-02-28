	.file	"simple_loop.c"
	.text
	.globl	main
	.type	main, @function
main:
.LFB0:
	.cfi_startproc
	movl	$0, %eax
.L2:
	movl	%eax, a(,%eax,4)
	addl	$1, %eax
	cmpl	$1048576, %eax
	jne	.L2
	rep
	ret
	.cfi_endproc
.LFE0:
	.size	main, .-main
	.comm	e,4194304,32
	.comm	d,4194304,32
	.comm	c,4194304,32
	.comm	b,4194304,32
	.comm	a,4194304,32
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
