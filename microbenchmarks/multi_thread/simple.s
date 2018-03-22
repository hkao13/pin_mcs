	.file	"simple.c"
	.text
.Ltext0:
	.comm	shrdPtr,8,8
	.comm	lock,40,32
	.comm	temp,4,4
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB2:
	.file 1 "simple.c"
	.loc 1 16 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 18 0
	movl	$1, temp(%rip)
	.loc 1 19 0
	movl	$0, %eax
	.loc 1 20 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE2:
	.size	INSTRUMENT_ON, .-INSTRUMENT_ON
	.globl	INSTRUMENT_OFF
	.type	INSTRUMENT_OFF, @function
INSTRUMENT_OFF:
.LFB3:
	.loc 1 22 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 24 0
	movl	$0, temp(%rip)
	.loc 1 25 0
	movl	$0, %eax
	.loc 1 26 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	INSTRUMENT_OFF, .-INSTRUMENT_OFF
	.globl	getNewVal
	.type	getNewVal, @function
getNewVal:
.LFB4:
	.loc 1 28 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 29 0
	movq	-24(%rbp), %rax
	movq	(%rax), %rax
	movq	%rax, %rdi
	call	free
	.loc 1 30 0
	movq	-24(%rbp), %rax
	movq	$0, (%rax)
	.loc 1 31 0
	movl	$4, %edi
	call	malloc
	movq	%rax, -8(%rbp)
	.loc 1 32 0
	movq	-8(%rbp), %rax
	movl	$1, (%rax)
	.loc 1 33 0
	movq	-8(%rbp), %rax
	.loc 1 34 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE4:
	.size	getNewVal, .-getNewVal
	.globl	updaterThread
	.type	updaterThread, @function
updaterThread:
.LFB5:
	.loc 1 36 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 38 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 41 0
	movl	$0, -12(%rbp)
	jmp	.L8
.L9:
.LBB2:
	.loc 1 42 0 discriminator 3
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 43 0 discriminator 3
	movl	$shrdPtr, %edi
	call	getNewVal
	movq	%rax, -8(%rbp)
	.loc 1 44 0 discriminator 3
	movq	-8(%rbp), %rax
	movq	%rax, shrdPtr(%rip)
	.loc 1 45 0 discriminator 3
	movl	$lock, %edi
	call	pthread_mutex_unlock
.LBE2:
	.loc 1 41 0 discriminator 3
	addl	$1, -12(%rbp)
.L8:
	.loc 1 41 0 is_stmt 0 discriminator 1
	cmpl	$9, -12(%rbp)
	jle	.L9
	.loc 1 48 0 is_stmt 1
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 50 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	updaterThread, .-updaterThread
	.globl	swizzle
	.type	swizzle, @function
swizzle:
.LFB6:
	.loc 1 52 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$16, %rsp
	movq	%rdi, -8(%rbp)
	.loc 1 54 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 55 0
	movq	shrdPtr(%rip), %rax
	testq	%rax, %rax
	je	.L11
	.loc 1 58 0
	movq	-8(%rbp), %rax
	movl	(%rax), %edx
	movq	shrdPtr(%rip), %rax
	movl	(%rax), %eax
	addl	%eax, %edx
	movq	-8(%rbp), %rax
	movl	%edx, (%rax)
.L11:
	.loc 1 61 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 63 0
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE6:
	.size	swizzle, .-swizzle
	.globl	accessorThread
	.type	accessorThread, @function
accessorThread:
.LFB7:
	.loc 1 65 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$32, %rsp
	movq	%rdi, -24(%rbp)
	.loc 1 67 0
	movl	$4, %edi
	call	malloc
	movq	%rax, -8(%rbp)
	.loc 1 68 0
	movq	-8(%rbp), %rax
	movl	$0, (%rax)
	.loc 1 70 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 72 0
	jmp	.L13
.L14:
.LBB3:
	.loc 1 73 0
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	swizzle
	.loc 1 74 0
	call	rand
	movl	%eax, %ecx
	movl	$1374389535, %edx
	movl	%ecx, %eax
	imull	%edx
	sarl	$5, %edx
	movl	%ecx, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	movl	%edx, %eax
	imull	$100, %eax, %eax
	subl	%eax, %ecx
	movl	%ecx, %eax
	addl	$10, %eax
	movl	%eax, %edi
	movl	$0, %eax
	call	usleep
.L13:
.LBE3:
	.loc 1 72 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	cmpl	$99, %eax
	jle	.L14
	.loc 1 77 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 79 0
	movq	-8(%rbp), %rax
	movq	%rax, %rdi
	call	pthread_exit
	.cfi_endproc
.LFE7:
	.size	accessorThread, .-accessorThread
	.section	.rodata
.LC0:
	.string	"Final value of res was %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB8:
	.loc 1 82 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$80, %rsp
	movl	%edi, -68(%rbp)
	movq	%rsi, -80(%rbp)
	.loc 1 82 0
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	.loc 1 84 0
	movl	$0, -60(%rbp)
	.loc 1 85 0
	movl	$4, %edi
	call	malloc
	movq	%rax, shrdPtr(%rip)
	.loc 1 86 0
	movq	shrdPtr(%rip), %rax
	movl	$1, (%rax)
	.loc 1 88 0
	movl	$0, %esi
	movl	$lock, %edi
	call	pthread_mutex_init
	.loc 1 91 0
	movq	shrdPtr(%rip), %rdx
	leaq	-48(%rbp), %rax
	movq	%rdx, %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 92 0
	movq	shrdPtr(%rip), %rax
	leaq	-48(%rbp), %rdx
	leaq	8(%rdx), %rdi
	movq	%rax, %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	call	pthread_create
	.loc 1 93 0
	movq	shrdPtr(%rip), %rax
	leaq	-48(%rbp), %rdx
	leaq	16(%rdx), %rdi
	movq	%rax, %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	call	pthread_create
	.loc 1 94 0
	movq	shrdPtr(%rip), %rax
	leaq	-48(%rbp), %rdx
	leaq	24(%rdx), %rdi
	movq	%rax, %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	call	pthread_create
	.loc 1 95 0
	movq	shrdPtr(%rip), %rdx
	leaq	-56(%rbp), %rax
	movq	%rdx, %rcx
	movl	$updaterThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 97 0
	movq	-56(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 98 0
	movq	-48(%rbp), %rax
	leaq	-60(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 99 0
	movq	-40(%rbp), %rax
	leaq	-60(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 100 0
	movq	-32(%rbp), %rax
	leaq	-60(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 101 0
	movq	-24(%rbp), %rax
	leaq	-60(%rbp), %rdx
	movq	%rdx, %rsi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 102 0
	movl	-60(%rbp), %edx
	movq	stderr(%rip), %rax
	movl	$.LC0, %esi
	movq	%rax, %rdi
	movl	$0, %eax
	call	fprintf
	.loc 1 103 0
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L16
	call	__stack_chk_fail
.L16:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE8:
	.size	main, .-main
.Letext0:
	.file 2 "/usr/lib/gcc/x86_64-linux-gnu/4.9/include/stddef.h"
	.file 3 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 4 "/usr/include/libio.h"
	.file 5 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.file 6 "/usr/include/stdio.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x5d6
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF81
	.byte	0x1
	.long	.LASF82
	.long	.LASF83
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.long	.LASF7
	.byte	0x2
	.byte	0xd4
	.long	0x38
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x3
	.byte	0x1
	.byte	0x8
	.long	.LASF1
	.uleb128 0x3
	.byte	0x2
	.byte	0x7
	.long	.LASF2
	.uleb128 0x3
	.byte	0x4
	.byte	0x7
	.long	.LASF3
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x3
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x4
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF6
	.uleb128 0x2
	.long	.LASF8
	.byte	0x3
	.byte	0x83
	.long	0x69
	.uleb128 0x2
	.long	.LASF9
	.byte	0x3
	.byte	0x84
	.long	0x69
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF10
	.uleb128 0x5
	.byte	0x8
	.uleb128 0x6
	.byte	0x8
	.long	0x95
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF11
	.uleb128 0x7
	.long	.LASF41
	.byte	0xd8
	.byte	0x4
	.byte	0xf5
	.long	0x21c
	.uleb128 0x8
	.long	.LASF12
	.byte	0x4
	.byte	0xf6
	.long	0x62
	.byte	0
	.uleb128 0x8
	.long	.LASF13
	.byte	0x4
	.byte	0xfb
	.long	0x8f
	.byte	0x8
	.uleb128 0x8
	.long	.LASF14
	.byte	0x4
	.byte	0xfc
	.long	0x8f
	.byte	0x10
	.uleb128 0x8
	.long	.LASF15
	.byte	0x4
	.byte	0xfd
	.long	0x8f
	.byte	0x18
	.uleb128 0x8
	.long	.LASF16
	.byte	0x4
	.byte	0xfe
	.long	0x8f
	.byte	0x20
	.uleb128 0x8
	.long	.LASF17
	.byte	0x4
	.byte	0xff
	.long	0x8f
	.byte	0x28
	.uleb128 0x9
	.long	.LASF18
	.byte	0x4
	.value	0x100
	.long	0x8f
	.byte	0x30
	.uleb128 0x9
	.long	.LASF19
	.byte	0x4
	.value	0x101
	.long	0x8f
	.byte	0x38
	.uleb128 0x9
	.long	.LASF20
	.byte	0x4
	.value	0x102
	.long	0x8f
	.byte	0x40
	.uleb128 0x9
	.long	.LASF21
	.byte	0x4
	.value	0x104
	.long	0x8f
	.byte	0x48
	.uleb128 0x9
	.long	.LASF22
	.byte	0x4
	.value	0x105
	.long	0x8f
	.byte	0x50
	.uleb128 0x9
	.long	.LASF23
	.byte	0x4
	.value	0x106
	.long	0x8f
	.byte	0x58
	.uleb128 0x9
	.long	.LASF24
	.byte	0x4
	.value	0x108
	.long	0x254
	.byte	0x60
	.uleb128 0x9
	.long	.LASF25
	.byte	0x4
	.value	0x10a
	.long	0x25a
	.byte	0x68
	.uleb128 0x9
	.long	.LASF26
	.byte	0x4
	.value	0x10c
	.long	0x62
	.byte	0x70
	.uleb128 0x9
	.long	.LASF27
	.byte	0x4
	.value	0x110
	.long	0x62
	.byte	0x74
	.uleb128 0x9
	.long	.LASF28
	.byte	0x4
	.value	0x112
	.long	0x70
	.byte	0x78
	.uleb128 0x9
	.long	.LASF29
	.byte	0x4
	.value	0x116
	.long	0x46
	.byte	0x80
	.uleb128 0x9
	.long	.LASF30
	.byte	0x4
	.value	0x117
	.long	0x54
	.byte	0x82
	.uleb128 0x9
	.long	.LASF31
	.byte	0x4
	.value	0x118
	.long	0x260
	.byte	0x83
	.uleb128 0x9
	.long	.LASF32
	.byte	0x4
	.value	0x11c
	.long	0x270
	.byte	0x88
	.uleb128 0x9
	.long	.LASF33
	.byte	0x4
	.value	0x125
	.long	0x7b
	.byte	0x90
	.uleb128 0x9
	.long	.LASF34
	.byte	0x4
	.value	0x12e
	.long	0x8d
	.byte	0x98
	.uleb128 0x9
	.long	.LASF35
	.byte	0x4
	.value	0x12f
	.long	0x8d
	.byte	0xa0
	.uleb128 0x9
	.long	.LASF36
	.byte	0x4
	.value	0x130
	.long	0x8d
	.byte	0xa8
	.uleb128 0x9
	.long	.LASF37
	.byte	0x4
	.value	0x131
	.long	0x8d
	.byte	0xb0
	.uleb128 0x9
	.long	.LASF38
	.byte	0x4
	.value	0x132
	.long	0x2d
	.byte	0xb8
	.uleb128 0x9
	.long	.LASF39
	.byte	0x4
	.value	0x134
	.long	0x62
	.byte	0xc0
	.uleb128 0x9
	.long	.LASF40
	.byte	0x4
	.value	0x136
	.long	0x276
	.byte	0xc4
	.byte	0
	.uleb128 0xa
	.long	.LASF84
	.byte	0x4
	.byte	0x9a
	.uleb128 0x7
	.long	.LASF42
	.byte	0x18
	.byte	0x4
	.byte	0xa0
	.long	0x254
	.uleb128 0x8
	.long	.LASF43
	.byte	0x4
	.byte	0xa1
	.long	0x254
	.byte	0
	.uleb128 0x8
	.long	.LASF44
	.byte	0x4
	.byte	0xa2
	.long	0x25a
	.byte	0x8
	.uleb128 0x8
	.long	.LASF45
	.byte	0x4
	.byte	0xa6
	.long	0x62
	.byte	0x10
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x223
	.uleb128 0x6
	.byte	0x8
	.long	0x9c
	.uleb128 0xb
	.long	0x95
	.long	0x270
	.uleb128 0xc
	.long	0x86
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x21c
	.uleb128 0xb
	.long	0x95
	.long	0x286
	.uleb128 0xc
	.long	0x86
	.byte	0x13
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x62
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF46
	.uleb128 0x2
	.long	.LASF47
	.byte	0x5
	.byte	0x3c
	.long	0x38
	.uleb128 0x7
	.long	.LASF48
	.byte	0x10
	.byte	0x5
	.byte	0x4b
	.long	0x2c3
	.uleb128 0x8
	.long	.LASF49
	.byte	0x5
	.byte	0x4d
	.long	0x2c3
	.byte	0
	.uleb128 0x8
	.long	.LASF50
	.byte	0x5
	.byte	0x4e
	.long	0x2c3
	.byte	0x8
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x29e
	.uleb128 0x2
	.long	.LASF51
	.byte	0x5
	.byte	0x4f
	.long	0x29e
	.uleb128 0x7
	.long	.LASF52
	.byte	0x28
	.byte	0x5
	.byte	0x5c
	.long	0x341
	.uleb128 0x8
	.long	.LASF53
	.byte	0x5
	.byte	0x5e
	.long	0x62
	.byte	0
	.uleb128 0x8
	.long	.LASF54
	.byte	0x5
	.byte	0x5f
	.long	0x4d
	.byte	0x4
	.uleb128 0x8
	.long	.LASF55
	.byte	0x5
	.byte	0x60
	.long	0x62
	.byte	0x8
	.uleb128 0x8
	.long	.LASF56
	.byte	0x5
	.byte	0x62
	.long	0x4d
	.byte	0xc
	.uleb128 0x8
	.long	.LASF57
	.byte	0x5
	.byte	0x66
	.long	0x62
	.byte	0x10
	.uleb128 0x8
	.long	.LASF58
	.byte	0x5
	.byte	0x68
	.long	0x5b
	.byte	0x14
	.uleb128 0x8
	.long	.LASF59
	.byte	0x5
	.byte	0x69
	.long	0x5b
	.byte	0x16
	.uleb128 0x8
	.long	.LASF60
	.byte	0x5
	.byte	0x6a
	.long	0x2c9
	.byte	0x18
	.byte	0
	.uleb128 0xd
	.byte	0x28
	.byte	0x5
	.byte	0x5a
	.long	0x36b
	.uleb128 0xe
	.long	.LASF61
	.byte	0x5
	.byte	0x7d
	.long	0x2d4
	.uleb128 0xe
	.long	.LASF62
	.byte	0x5
	.byte	0x7e
	.long	0x36b
	.uleb128 0xe
	.long	.LASF63
	.byte	0x5
	.byte	0x7f
	.long	0x69
	.byte	0
	.uleb128 0xb
	.long	0x95
	.long	0x37b
	.uleb128 0xc
	.long	0x86
	.byte	0x27
	.byte	0
	.uleb128 0x2
	.long	.LASF64
	.byte	0x5
	.byte	0x80
	.long	0x341
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF65
	.uleb128 0x7
	.long	.LASF66
	.byte	0x4
	.byte	0x1
	.byte	0x8
	.long	0x3a4
	.uleb128 0xf
	.string	"a"
	.byte	0x1
	.byte	0x9
	.long	0x62
	.byte	0
	.byte	0
	.uleb128 0x10
	.long	.LASF67
	.byte	0x1
	.byte	0x10
	.long	0x62
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x10
	.long	.LASF68
	.byte	0x1
	.byte	0x16
	.long	0x62
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0x11
	.long	.LASF69
	.byte	0x1
	.byte	0x1c
	.long	0x41c
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x41c
	.uleb128 0x12
	.string	"old"
	.byte	0x1
	.byte	0x1c
	.long	0x422
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x13
	.long	.LASF71
	.byte	0x1
	.byte	0x1f
	.long	0x41c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x38d
	.uleb128 0x6
	.byte	0x8
	.long	0x41c
	.uleb128 0x11
	.long	.LASF70
	.byte	0x1
	.byte	0x24
	.long	0x8d
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x484
	.uleb128 0x12
	.string	"arg"
	.byte	0x1
	.byte	0x24
	.long	0x8d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x14
	.string	"i"
	.byte	0x1
	.byte	0x28
	.long	0x62
	.uleb128 0x2
	.byte	0x91
	.sleb128 -28
	.uleb128 0x15
	.quad	.LBB2
	.quad	.LBE2-.LBB2
	.uleb128 0x13
	.long	.LASF71
	.byte	0x1
	.byte	0x2b
	.long	0x41c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.byte	0
	.uleb128 0x16
	.long	.LASF85
	.byte	0x1
	.byte	0x34
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.long	0x4b0
	.uleb128 0x17
	.long	.LASF72
	.byte	0x1
	.byte	0x34
	.long	0x286
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.byte	0
	.uleb128 0x11
	.long	.LASF73
	.byte	0x1
	.byte	0x41
	.long	0x8d
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.long	0x50d
	.uleb128 0x12
	.string	"arg"
	.byte	0x1
	.byte	0x41
	.long	0x8d
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x13
	.long	.LASF72
	.byte	0x1
	.byte	0x43
	.long	0x286
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x15
	.quad	.LBB3
	.quad	.LBE3-.LBB3
	.uleb128 0x18
	.long	.LASF86
	.byte	0x1
	.byte	0x4a
	.long	0x62
	.uleb128 0x19
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x11
	.long	.LASF74
	.byte	0x1
	.byte	0x52
	.long	0x62
	.quad	.LFB8
	.quad	.LFE8-.LFB8
	.uleb128 0x1
	.byte	0x9c
	.long	0x579
	.uleb128 0x17
	.long	.LASF75
	.byte	0x1
	.byte	0x52
	.long	0x62
	.uleb128 0x3
	.byte	0x91
	.sleb128 -84
	.uleb128 0x17
	.long	.LASF76
	.byte	0x1
	.byte	0x52
	.long	0x579
	.uleb128 0x3
	.byte	0x91
	.sleb128 -96
	.uleb128 0x14
	.string	"res"
	.byte	0x1
	.byte	0x54
	.long	0x62
	.uleb128 0x3
	.byte	0x91
	.sleb128 -76
	.uleb128 0x14
	.string	"acc"
	.byte	0x1
	.byte	0x5a
	.long	0x57f
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x14
	.string	"upd"
	.byte	0x1
	.byte	0x5a
	.long	0x293
	.uleb128 0x3
	.byte	0x91
	.sleb128 -72
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x8f
	.uleb128 0xb
	.long	0x293
	.long	0x58f
	.uleb128 0xc
	.long	0x86
	.byte	0x3
	.byte	0
	.uleb128 0x1a
	.long	.LASF77
	.byte	0x6
	.byte	0xaa
	.long	0x25a
	.uleb128 0x1b
	.long	.LASF78
	.byte	0x1
	.byte	0xa
	.long	0x41c
	.uleb128 0x9
	.byte	0x3
	.quad	shrdPtr
	.uleb128 0x1b
	.long	.LASF79
	.byte	0x1
	.byte	0xc
	.long	0x37b
	.uleb128 0x9
	.byte	0x3
	.quad	lock
	.uleb128 0x1b
	.long	.LASF80
	.byte	0x1
	.byte	0xe
	.long	0x62
	.uleb128 0x9
	.byte	0x3
	.quad	temp
	.byte	0
	.section	.debug_abbrev,"",@progbits
.Ldebug_abbrev0:
	.uleb128 0x1
	.uleb128 0x11
	.byte	0x1
	.uleb128 0x25
	.uleb128 0xe
	.uleb128 0x13
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x1b
	.uleb128 0xe
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x10
	.uleb128 0x17
	.byte	0
	.byte	0
	.uleb128 0x2
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x3
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0xe
	.byte	0
	.byte	0
	.uleb128 0x4
	.uleb128 0x24
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3e
	.uleb128 0xb
	.uleb128 0x3
	.uleb128 0x8
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x6
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x7
	.uleb128 0x13
	.byte	0x1
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x8
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x9
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x16
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x17
	.byte	0x1
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xf
	.uleb128 0xd
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x10
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2117
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x11
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x13
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0x8
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0x19
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x7
	.uleb128 0x40
	.uleb128 0x18
	.uleb128 0x2116
	.uleb128 0x19
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x17
	.uleb128 0x5
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x18
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x19
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x3c
	.uleb128 0x19
	.byte	0
	.byte	0
	.uleb128 0x1b
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_aranges,"",@progbits
	.long	0x2c
	.value	0x2
	.long	.Ldebug_info0
	.byte	0x8
	.byte	0
	.value	0
	.value	0
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.quad	0
	.quad	0
	.section	.debug_line,"",@progbits
.Ldebug_line0:
	.section	.debug_str,"MS",@progbits,1
.LASF8:
	.string	"__off_t"
.LASF13:
	.string	"_IO_read_ptr"
.LASF81:
	.string	"GNU C 4.9.2 -mtune=generic -march=x86-64 -g -O0 -fstack-protector-strong"
.LASF7:
	.string	"size_t"
.LASF49:
	.string	"__prev"
.LASF63:
	.string	"__align"
.LASF31:
	.string	"_shortbuf"
.LASF69:
	.string	"getNewVal"
.LASF62:
	.string	"__size"
.LASF19:
	.string	"_IO_buf_base"
.LASF65:
	.string	"long long unsigned int"
.LASF50:
	.string	"__next"
.LASF71:
	.string	"newval"
.LASF46:
	.string	"long long int"
.LASF4:
	.string	"signed char"
.LASF26:
	.string	"_fileno"
.LASF14:
	.string	"_IO_read_end"
.LASF86:
	.string	"usleep"
.LASF79:
	.string	"lock"
.LASF6:
	.string	"long int"
.LASF12:
	.string	"_flags"
.LASF20:
	.string	"_IO_buf_end"
.LASF29:
	.string	"_cur_column"
.LASF28:
	.string	"_old_offset"
.LASF33:
	.string	"_offset"
.LASF51:
	.string	"__pthread_list_t"
.LASF52:
	.string	"__pthread_mutex_s"
.LASF70:
	.string	"updaterThread"
.LASF66:
	.string	"wonk"
.LASF80:
	.string	"temp"
.LASF42:
	.string	"_IO_marker"
.LASF67:
	.string	"INSTRUMENT_ON"
.LASF3:
	.string	"unsigned int"
.LASF0:
	.string	"long unsigned int"
.LASF57:
	.string	"__kind"
.LASF17:
	.string	"_IO_write_ptr"
.LASF61:
	.string	"__data"
.LASF44:
	.string	"_sbuf"
.LASF68:
	.string	"INSTRUMENT_OFF"
.LASF59:
	.string	"__elision"
.LASF2:
	.string	"short unsigned int"
.LASF21:
	.string	"_IO_save_base"
.LASF82:
	.string	"simple.c"
.LASF32:
	.string	"_lock"
.LASF27:
	.string	"_flags2"
.LASF39:
	.string	"_mode"
.LASF55:
	.string	"__owner"
.LASF10:
	.string	"sizetype"
.LASF78:
	.string	"shrdPtr"
.LASF18:
	.string	"_IO_write_end"
.LASF84:
	.string	"_IO_lock_t"
.LASF41:
	.string	"_IO_FILE"
.LASF48:
	.string	"__pthread_internal_list"
.LASF45:
	.string	"_pos"
.LASF24:
	.string	"_markers"
.LASF47:
	.string	"pthread_t"
.LASF1:
	.string	"unsigned char"
.LASF5:
	.string	"short int"
.LASF25:
	.string	"_chain"
.LASF30:
	.string	"_vtable_offset"
.LASF83:
	.string	"/home/henry/HostShare/ubuntu15VM_share/pin/source/tools/pin_mcs/microbenchmarks/multi_thread"
.LASF73:
	.string	"accessorThread"
.LASF54:
	.string	"__count"
.LASF53:
	.string	"__lock"
.LASF85:
	.string	"swizzle"
.LASF11:
	.string	"char"
.LASF43:
	.string	"_next"
.LASF9:
	.string	"__off64_t"
.LASF15:
	.string	"_IO_read_base"
.LASF23:
	.string	"_IO_save_end"
.LASF64:
	.string	"pthread_mutex_t"
.LASF34:
	.string	"__pad1"
.LASF35:
	.string	"__pad2"
.LASF36:
	.string	"__pad3"
.LASF37:
	.string	"__pad4"
.LASF38:
	.string	"__pad5"
.LASF40:
	.string	"_unused2"
.LASF77:
	.string	"stderr"
.LASF76:
	.string	"argv"
.LASF56:
	.string	"__nusers"
.LASF22:
	.string	"_IO_backup_base"
.LASF58:
	.string	"__spins"
.LASF75:
	.string	"argc"
.LASF60:
	.string	"__list"
.LASF74:
	.string	"main"
.LASF16:
	.string	"_IO_write_base"
.LASF72:
	.string	"result"
	.ident	"GCC: (Ubuntu 4.9.2-10ubuntu13) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
