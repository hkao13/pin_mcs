	.file	"only_reads.c"
	.text
	.globl	start_instrumentation
	.type	start_instrumentation, @function
start_instrumentation:
.LFB0:
	.cfi_startproc
	movl	$0, temp(%rip)
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE0:
	.size	start_instrumentation, .-start_instrumentation
	.globl	main
	.type	main, @function
main:
.LFB1:
	.cfi_startproc
	movl	$0, %eax
	call	start_instrumentation
	movl	$a, %eax
	movl	$a+4000, %ecx
.L3:
	movl	(%rax), %edx
	addq	$4, %rax
	cmpq	%rcx, %rax
	jne	.L3
	movl	%edx, read(%rip)
	movl	$0, %eax
	call	start_instrumentation
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE1:
	.size	main, .-main
	.comm	temp,4,4
	.comm	read,4,4
	.comm	a,4000,32
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
