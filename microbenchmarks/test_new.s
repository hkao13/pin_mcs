	.file	"test_new.c"
	.text
	.globl	start_instrumentation
	.type	start_instrumentation, @function
start_instrumentation:
.LFB34:
	.cfi_startproc
	rep
	ret
	.cfi_endproc
.LFE34:
	.size	start_instrumentation, .-start_instrumentation
	.globl	main
	.type	main, @function
main:
.LFB35:
	.cfi_startproc
	movl	$131072, %eax
.L3:
	subl	$1, %eax
	jne	.L3
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE35:
	.size	main, .-main
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
