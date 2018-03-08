	.file	"simple.c"
	.text
.Ltext0:
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB35:
	.file 1 "simple.c"
	.loc 1 16 0
	.cfi_startproc
	.loc 1 18 0
	movl	$1, temp(%rip)
	.loc 1 20 0
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE35:
	.size	INSTRUMENT_ON, .-INSTRUMENT_ON
	.globl	INSTRUMENT_OFF
	.type	INSTRUMENT_OFF, @function
INSTRUMENT_OFF:
.LFB36:
	.loc 1 22 0
	.cfi_startproc
	.loc 1 24 0
	movl	$0, temp(%rip)
	.loc 1 26 0
	movl	$0, %eax
	ret
	.cfi_endproc
.LFE36:
	.size	INSTRUMENT_OFF, .-INSTRUMENT_OFF
	.globl	getNewVal
	.type	getNewVal, @function
getNewVal:
.LFB37:
	.loc 1 28 0
	.cfi_startproc
.LVL0:
	pushq	%rbx
.LCFI0:
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movq	%rdi, %rbx
	.loc 1 29 0
	movq	(%rdi), %rdi
.LVL1:
	call	free
	.loc 1 30 0
	movq	$0, (%rbx)
	.loc 1 31 0
	movl	$4, %edi
	call	malloc
.LVL2:
	.loc 1 32 0
	movl	$1, (%rax)
	.loc 1 34 0
	popq	%rbx
.LCFI1:
	.cfi_def_cfa_offset 8
.LVL3:
	ret
	.cfi_endproc
.LFE37:
	.size	getNewVal, .-getNewVal
	.globl	updaterThread
	.type	updaterThread, @function
updaterThread:
.LFB38:
	.loc 1 36 0
	.cfi_startproc
.LVL4:
	pushq	%rbx
.LCFI2:
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	.loc 1 38 0
	movl	$0, %eax
	call	INSTRUMENT_ON
.LVL5:
	movl	$10, %ebx
.LVL6:
.L5:
.LBB4:
	.loc 1 42 0 discriminator 2
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 43 0 discriminator 2
	movl	$shrdPtr, %edi
	call	getNewVal
.LVL7:
	.loc 1 44 0 discriminator 2
	movq	%rax, shrdPtr(%rip)
	.loc 1 45 0 discriminator 2
	movl	$lock, %edi
	call	pthread_mutex_unlock
.LVL8:
.LBE4:
	.loc 1 41 0 discriminator 2
	subl	$1, %ebx
	jne	.L5
	.loc 1 48 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 50 0
	popq	%rbx
.LCFI3:
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE38:
	.size	updaterThread, .-updaterThread
	.globl	swizzle
	.type	swizzle, @function
swizzle:
.LFB39:
	.loc 1 52 0
	.cfi_startproc
.LVL9:
	pushq	%rbx
.LCFI4:
	.cfi_def_cfa_offset 16
	.cfi_offset 3, -16
	movq	%rdi, %rbx
	.loc 1 54 0
	movl	$lock, %edi
.LVL10:
	call	pthread_mutex_lock
	.loc 1 55 0
	movq	shrdPtr(%rip), %rax
	testq	%rax, %rax
	je	.L8
	.loc 1 58 0
	movl	(%rax), %eax
	addl	%eax, (%rbx)
.L8:
	.loc 1 61 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 63 0
	popq	%rbx
.LCFI5:
	.cfi_def_cfa_offset 8
.LVL11:
	ret
	.cfi_endproc
.LFE39:
	.size	swizzle, .-swizzle
	.globl	accessorThread
	.type	accessorThread, @function
accessorThread:
.LFB40:
	.loc 1 65 0
	.cfi_startproc
.LVL12:
	pushq	%rbp
.LCFI6:
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	pushq	%rbx
.LCFI7:
	.cfi_def_cfa_offset 24
	.cfi_offset 3, -24
	subq	$8, %rsp
.LCFI8:
	.cfi_def_cfa_offset 32
	.loc 1 67 0
	movl	$4, %edi
.LVL13:
	call	malloc
	movq	%rax, %rbx
.LVL14:
	.loc 1 68 0
	movl	$0, (%rax)
	.loc 1 70 0
	movl	$0, %eax
.LVL15:
	call	INSTRUMENT_ON
	.loc 1 72 0
	cmpl	$99, (%rbx)
	jg	.L10
.LBB5:
	.loc 1 74 0
	movl	$1374389535, %ebp
.L12:
	.loc 1 73 0
	movq	%rbx, %rdi
	call	swizzle
	.loc 1 74 0
	call	rand
	movl	%eax, %edi
	imull	%ebp
	sarl	$5, %edx
	movl	%edi, %eax
	sarl	$31, %eax
	subl	%eax, %edx
	imull	$100, %edx, %edx
	subl	%edx, %edi
	addl	$10, %edi
	movl	$0, %eax
	call	usleep
.LBE5:
	.loc 1 72 0
	cmpl	$99, (%rbx)
	jle	.L12
.L10:
	.loc 1 77 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 79 0
	movq	%rbx, %rdi
	call	pthread_exit
	.cfi_endproc
.LFE40:
	.size	accessorThread, .-accessorThread
	.section	.rodata.str1.1,"aMS",@progbits,1
.LC0:
	.string	"Final value of res was %d\n"
	.text
	.globl	main
	.type	main, @function
main:
.LFB41:
	.loc 1 82 0
	.cfi_startproc
.LVL16:
	subq	$56, %rsp
.LCFI9:
	.cfi_def_cfa_offset 64
	.loc 1 84 0
	movl	$0, 44(%rsp)
.LVL17:
	.loc 1 85 0
	movl	$4, %edi
.LVL18:
	call	malloc
.LVL19:
	movq	%rax, shrdPtr(%rip)
	.loc 1 86 0
	movl	$1, (%rax)
	.loc 1 88 0
	movl	$0, %esi
	movl	$lock, %edi
	call	pthread_mutex_init
	.loc 1 91 0
	movq	shrdPtr(%rip), %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rsp, %rdi
	call	pthread_create
	.loc 1 92 0
	leaq	8(%rsp), %rdi
	movq	shrdPtr(%rip), %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	call	pthread_create
	.loc 1 93 0
	leaq	16(%rsp), %rdi
	movq	shrdPtr(%rip), %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	call	pthread_create
	.loc 1 94 0
	leaq	24(%rsp), %rdi
	movq	shrdPtr(%rip), %rcx
	movl	$accessorThread, %edx
	movl	$0, %esi
	call	pthread_create
	.loc 1 95 0
	movq	shrdPtr(%rip), %rcx
	movl	$updaterThread, %edx
	movl	$0, %esi
	leaq	32(%rsp), %rdi
	call	pthread_create
	.loc 1 97 0
	movl	$0, %esi
.LVL20:
	movq	32(%rsp), %rdi
	call	pthread_join
	.loc 1 98 0
	leaq	44(%rsp), %rsi
	movq	(%rsp), %rdi
	call	pthread_join
	.loc 1 99 0
	leaq	44(%rsp), %rsi
	movq	8(%rsp), %rdi
	call	pthread_join
	.loc 1 100 0
	leaq	44(%rsp), %rsi
	movq	16(%rsp), %rdi
	call	pthread_join
	.loc 1 101 0
	leaq	44(%rsp), %rsi
	movq	24(%rsp), %rdi
	call	pthread_join
.LVL21:
.LBB6:
.LBB7:
	.file 2 "/usr/include/x86_64-linux-gnu/bits/stdio2.h"
	.loc 2 98 0
	movl	44(%rsp), %ecx
	movl	$.LC0, %edx
	movl	$1, %esi
	movq	stderr(%rip), %rdi
	movl	$0, %eax
	call	__fprintf_chk
.LVL22:
.LBE7:
.LBE6:
	.loc 1 103 0
	addq	$56, %rsp
.LCFI10:
	.cfi_def_cfa_offset 8
	ret
	.cfi_endproc
.LFE41:
	.size	main, .-main
	.comm	temp,4,4
	.comm	lock,40,32
	.comm	shrdPtr,8,8
.Letext0:
	.file 3 "/usr/lib/gcc/x86_64-linux-gnu/4.6.1/include/stddef.h"
	.file 4 "/usr/include/x86_64-linux-gnu/bits/types.h"
	.file 5 "/usr/include/stdio.h"
	.file 6 "/usr/include/libio.h"
	.file 7 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x729
	.value	0x2
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF86
	.byte	0x1
	.long	.LASF87
	.long	.LASF88
	.quad	.Ltext0
	.quad	.Letext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.long	.LASF7
	.byte	0x3
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
	.byte	0x4
	.byte	0x8d
	.long	0x69
	.uleb128 0x2
	.long	.LASF9
	.byte	0x4
	.byte	0x8e
	.long	0x69
	.uleb128 0x5
	.byte	0x8
	.uleb128 0x6
	.byte	0x8
	.long	0x8e
	.uleb128 0x3
	.byte	0x1
	.byte	0x6
	.long	.LASF10
	.uleb128 0x2
	.long	.LASF11
	.byte	0x5
	.byte	0x31
	.long	0xa0
	.uleb128 0x7
	.long	.LASF41
	.byte	0xd8
	.byte	0x6
	.value	0x10f
	.long	0x26d
	.uleb128 0x8
	.long	.LASF12
	.byte	0x6
	.value	0x110
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0
	.uleb128 0x8
	.long	.LASF13
	.byte	0x6
	.value	0x115
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x8
	.uleb128 0x8
	.long	.LASF14
	.byte	0x6
	.value	0x116
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x10
	.uleb128 0x8
	.long	.LASF15
	.byte	0x6
	.value	0x117
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x18
	.uleb128 0x8
	.long	.LASF16
	.byte	0x6
	.value	0x118
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x20
	.uleb128 0x8
	.long	.LASF17
	.byte	0x6
	.value	0x119
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x28
	.uleb128 0x8
	.long	.LASF18
	.byte	0x6
	.value	0x11a
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x30
	.uleb128 0x8
	.long	.LASF19
	.byte	0x6
	.value	0x11b
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x38
	.uleb128 0x8
	.long	.LASF20
	.byte	0x6
	.value	0x11c
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x40
	.uleb128 0x8
	.long	.LASF21
	.byte	0x6
	.value	0x11e
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x48
	.uleb128 0x8
	.long	.LASF22
	.byte	0x6
	.value	0x11f
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x50
	.uleb128 0x8
	.long	.LASF23
	.byte	0x6
	.value	0x120
	.long	0x88
	.byte	0x2
	.byte	0x23
	.uleb128 0x58
	.uleb128 0x8
	.long	.LASF24
	.byte	0x6
	.value	0x122
	.long	0x2ab
	.byte	0x2
	.byte	0x23
	.uleb128 0x60
	.uleb128 0x8
	.long	.LASF25
	.byte	0x6
	.value	0x124
	.long	0x2b1
	.byte	0x2
	.byte	0x23
	.uleb128 0x68
	.uleb128 0x8
	.long	.LASF26
	.byte	0x6
	.value	0x126
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0x70
	.uleb128 0x8
	.long	.LASF27
	.byte	0x6
	.value	0x12a
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0x74
	.uleb128 0x8
	.long	.LASF28
	.byte	0x6
	.value	0x12c
	.long	0x70
	.byte	0x2
	.byte	0x23
	.uleb128 0x78
	.uleb128 0x8
	.long	.LASF29
	.byte	0x6
	.value	0x130
	.long	0x46
	.byte	0x3
	.byte	0x23
	.uleb128 0x80
	.uleb128 0x8
	.long	.LASF30
	.byte	0x6
	.value	0x131
	.long	0x54
	.byte	0x3
	.byte	0x23
	.uleb128 0x82
	.uleb128 0x8
	.long	.LASF31
	.byte	0x6
	.value	0x132
	.long	0x2b7
	.byte	0x3
	.byte	0x23
	.uleb128 0x83
	.uleb128 0x8
	.long	.LASF32
	.byte	0x6
	.value	0x136
	.long	0x2c7
	.byte	0x3
	.byte	0x23
	.uleb128 0x88
	.uleb128 0x8
	.long	.LASF33
	.byte	0x6
	.value	0x13f
	.long	0x7b
	.byte	0x3
	.byte	0x23
	.uleb128 0x90
	.uleb128 0x8
	.long	.LASF34
	.byte	0x6
	.value	0x148
	.long	0x86
	.byte	0x3
	.byte	0x23
	.uleb128 0x98
	.uleb128 0x8
	.long	.LASF35
	.byte	0x6
	.value	0x149
	.long	0x86
	.byte	0x3
	.byte	0x23
	.uleb128 0xa0
	.uleb128 0x8
	.long	.LASF36
	.byte	0x6
	.value	0x14a
	.long	0x86
	.byte	0x3
	.byte	0x23
	.uleb128 0xa8
	.uleb128 0x8
	.long	.LASF37
	.byte	0x6
	.value	0x14b
	.long	0x86
	.byte	0x3
	.byte	0x23
	.uleb128 0xb0
	.uleb128 0x8
	.long	.LASF38
	.byte	0x6
	.value	0x14c
	.long	0x2d
	.byte	0x3
	.byte	0x23
	.uleb128 0xb8
	.uleb128 0x8
	.long	.LASF39
	.byte	0x6
	.value	0x14e
	.long	0x62
	.byte	0x3
	.byte	0x23
	.uleb128 0xc0
	.uleb128 0x8
	.long	.LASF40
	.byte	0x6
	.value	0x150
	.long	0x2cd
	.byte	0x3
	.byte	0x23
	.uleb128 0xc4
	.byte	0
	.uleb128 0x9
	.long	.LASF89
	.byte	0x6
	.byte	0xb4
	.uleb128 0xa
	.long	.LASF42
	.byte	0x18
	.byte	0x6
	.byte	0xba
	.long	0x2ab
	.uleb128 0xb
	.long	.LASF43
	.byte	0x6
	.byte	0xbb
	.long	0x2ab
	.byte	0x2
	.byte	0x23
	.uleb128 0
	.uleb128 0xb
	.long	.LASF44
	.byte	0x6
	.byte	0xbc
	.long	0x2b1
	.byte	0x2
	.byte	0x23
	.uleb128 0x8
	.uleb128 0xb
	.long	.LASF45
	.byte	0x6
	.byte	0xc0
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0x10
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x274
	.uleb128 0x6
	.byte	0x8
	.long	0xa0
	.uleb128 0xc
	.long	0x8e
	.long	0x2c7
	.uleb128 0xd
	.long	0x38
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x26d
	.uleb128 0xc
	.long	0x8e
	.long	0x2dd
	.uleb128 0xd
	.long	0x38
	.byte	0x13
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x2e3
	.uleb128 0xe
	.long	0x8e
	.uleb128 0x6
	.byte	0x8
	.long	0x62
	.uleb128 0x3
	.byte	0x8
	.byte	0x5
	.long	.LASF46
	.uleb128 0x2
	.long	.LASF47
	.byte	0x7
	.byte	0x32
	.long	0x38
	.uleb128 0xa
	.long	.LASF48
	.byte	0x10
	.byte	0x7
	.byte	0x3d
	.long	0x329
	.uleb128 0xb
	.long	.LASF49
	.byte	0x7
	.byte	0x3f
	.long	0x329
	.byte	0x2
	.byte	0x23
	.uleb128 0
	.uleb128 0xb
	.long	.LASF50
	.byte	0x7
	.byte	0x40
	.long	0x329
	.byte	0x2
	.byte	0x23
	.uleb128 0x8
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x300
	.uleb128 0x2
	.long	.LASF51
	.byte	0x7
	.byte	0x41
	.long	0x300
	.uleb128 0xa
	.long	.LASF52
	.byte	0x28
	.byte	0x7
	.byte	0x4e
	.long	0x3a9
	.uleb128 0xb
	.long	.LASF53
	.byte	0x7
	.byte	0x50
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0
	.uleb128 0xb
	.long	.LASF54
	.byte	0x7
	.byte	0x51
	.long	0x4d
	.byte	0x2
	.byte	0x23
	.uleb128 0x4
	.uleb128 0xb
	.long	.LASF55
	.byte	0x7
	.byte	0x52
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0x8
	.uleb128 0xb
	.long	.LASF56
	.byte	0x7
	.byte	0x54
	.long	0x4d
	.byte	0x2
	.byte	0x23
	.uleb128 0xc
	.uleb128 0xb
	.long	.LASF57
	.byte	0x7
	.byte	0x58
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0x10
	.uleb128 0xb
	.long	.LASF58
	.byte	0x7
	.byte	0x5a
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0x14
	.uleb128 0xb
	.long	.LASF59
	.byte	0x7
	.byte	0x5b
	.long	0x32f
	.byte	0x2
	.byte	0x23
	.uleb128 0x18
	.byte	0
	.uleb128 0xf
	.byte	0x28
	.byte	0x7
	.byte	0x4c
	.long	0x3d3
	.uleb128 0x10
	.long	.LASF60
	.byte	0x7
	.byte	0x65
	.long	0x33a
	.uleb128 0x10
	.long	.LASF61
	.byte	0x7
	.byte	0x66
	.long	0x3d3
	.uleb128 0x10
	.long	.LASF62
	.byte	0x7
	.byte	0x67
	.long	0x69
	.byte	0
	.uleb128 0xc
	.long	0x8e
	.long	0x3e3
	.uleb128 0xd
	.long	0x38
	.byte	0x27
	.byte	0
	.uleb128 0x2
	.long	.LASF63
	.byte	0x7
	.byte	0x68
	.long	0x3a9
	.uleb128 0x3
	.byte	0x8
	.byte	0x7
	.long	.LASF64
	.uleb128 0xa
	.long	.LASF65
	.byte	0x4
	.byte	0x1
	.byte	0x8
	.long	0x40e
	.uleb128 0x11
	.string	"a"
	.byte	0x1
	.byte	0x9
	.long	0x62
	.byte	0x2
	.byte	0x23
	.uleb128 0
	.byte	0
	.uleb128 0x12
	.byte	0x1
	.long	.LASF73
	.byte	0x2
	.byte	0x60
	.byte	0x1
	.long	0x62
	.byte	0x3
	.byte	0x1
	.long	0x439
	.uleb128 0x13
	.long	.LASF66
	.byte	0x2
	.byte	0x60
	.long	0x439
	.uleb128 0x13
	.long	.LASF67
	.byte	0x2
	.byte	0x60
	.long	0x2dd
	.uleb128 0x14
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x95
	.uleb128 0x15
	.byte	0x1
	.long	.LASF68
	.byte	0x1
	.byte	0x10
	.long	0x62
	.quad	.LFB35
	.quad	.LFE35
	.byte	0x2
	.byte	0x77
	.sleb128 8
	.uleb128 0x15
	.byte	0x1
	.long	.LASF69
	.byte	0x1
	.byte	0x16
	.long	0x62
	.quad	.LFB36
	.quad	.LFE36
	.byte	0x2
	.byte	0x77
	.sleb128 8
	.uleb128 0x16
	.byte	0x1
	.long	.LASF70
	.byte	0x1
	.byte	0x1c
	.byte	0x1
	.long	0x4bf
	.quad	.LFB37
	.quad	.LFE37
	.long	.LLST0
	.long	0x4bf
	.uleb128 0x17
	.string	"old"
	.byte	0x1
	.byte	0x1c
	.long	0x4c5
	.long	.LLST1
	.uleb128 0x18
	.long	.LASF72
	.byte	0x1
	.byte	0x1f
	.long	0x4bf
	.byte	0x1
	.byte	0x50
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x3f5
	.uleb128 0x6
	.byte	0x8
	.long	0x4bf
	.uleb128 0x16
	.byte	0x1
	.long	.LASF71
	.byte	0x1
	.byte	0x24
	.byte	0x1
	.long	0x86
	.quad	.LFB38
	.quad	.LFE38
	.long	.LLST2
	.long	0x52e
	.uleb128 0x17
	.string	"arg"
	.byte	0x1
	.byte	0x24
	.long	0x86
	.long	.LLST3
	.uleb128 0x19
	.string	"i"
	.byte	0x1
	.byte	0x28
	.long	0x62
	.long	.LLST4
	.uleb128 0x1a
	.quad	.LBB4
	.quad	.LBE4
	.uleb128 0x1b
	.long	.LASF72
	.byte	0x1
	.byte	0x2b
	.long	0x4bf
	.long	.LLST5
	.byte	0
	.byte	0
	.uleb128 0x1c
	.byte	0x1
	.long	.LASF74
	.byte	0x1
	.byte	0x34
	.byte	0x1
	.quad	.LFB39
	.quad	.LFE39
	.long	.LLST6
	.long	0x55f
	.uleb128 0x1d
	.long	.LASF75
	.byte	0x1
	.byte	0x34
	.long	0x2e8
	.long	.LLST7
	.byte	0
	.uleb128 0x16
	.byte	0x1
	.long	.LASF76
	.byte	0x1
	.byte	0x41
	.byte	0x1
	.long	0x86
	.quad	.LFB40
	.quad	.LFE40
	.long	.LLST8
	.long	0x5c4
	.uleb128 0x17
	.string	"arg"
	.byte	0x1
	.byte	0x41
	.long	0x86
	.long	.LLST9
	.uleb128 0x1b
	.long	.LASF75
	.byte	0x1
	.byte	0x43
	.long	0x2e8
	.long	.LLST10
	.uleb128 0x1a
	.quad	.LBB5
	.quad	.LBE5
	.uleb128 0x1e
	.byte	0x1
	.long	.LASF90
	.byte	0x1
	.byte	0x4a
	.long	0x62
	.byte	0x1
	.uleb128 0x14
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x16
	.byte	0x1
	.long	.LASF77
	.byte	0x1
	.byte	0x52
	.byte	0x1
	.long	0x62
	.quad	.LFB41
	.quad	.LFE41
	.long	.LLST11
	.long	0x65f
	.uleb128 0x1d
	.long	.LASF78
	.byte	0x1
	.byte	0x52
	.long	0x62
	.long	.LLST12
	.uleb128 0x1d
	.long	.LASF79
	.byte	0x1
	.byte	0x52
	.long	0x65f
	.long	.LLST13
	.uleb128 0x1f
	.string	"res"
	.byte	0x1
	.byte	0x54
	.long	0x62
	.byte	0x2
	.byte	0x91
	.sleb128 -20
	.uleb128 0x1f
	.string	"acc"
	.byte	0x1
	.byte	0x5a
	.long	0x665
	.byte	0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x1f
	.string	"upd"
	.byte	0x1
	.byte	0x5a
	.long	0x2f5
	.byte	0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x20
	.long	0x40e
	.quad	.LBB6
	.quad	.LBE6
	.byte	0x1
	.byte	0x66
	.uleb128 0x21
	.long	0x42c
	.byte	0xa
	.byte	0x3
	.quad	.LC0
	.byte	0x9f
	.uleb128 0x22
	.long	0x421
	.byte	0
	.byte	0
	.uleb128 0x6
	.byte	0x8
	.long	0x88
	.uleb128 0xc
	.long	0x2f5
	.long	0x675
	.uleb128 0xd
	.long	0x38
	.byte	0x3
	.byte	0
	.uleb128 0x23
	.long	.LASF80
	.byte	0x5
	.byte	0xa5
	.long	0x2b1
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF81
	.byte	0x5
	.byte	0xa6
	.long	0x2b1
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF82
	.byte	0x5
	.byte	0xa7
	.long	0x2b1
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF83
	.byte	0x1
	.byte	0xa
	.long	0x4bf
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF84
	.byte	0x1
	.byte	0xc
	.long	0x3e3
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF85
	.byte	0x1
	.byte	0xe
	.long	0x62
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF80
	.byte	0x5
	.byte	0xa5
	.long	0x2b1
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF81
	.byte	0x5
	.byte	0xa6
	.long	0x2b1
	.byte	0x1
	.byte	0x1
	.uleb128 0x23
	.long	.LASF82
	.byte	0x5
	.byte	0xa7
	.long	0x2b1
	.byte	0x1
	.byte	0x1
	.uleb128 0x24
	.long	.LASF83
	.byte	0x1
	.byte	0xa
	.long	0x4bf
	.byte	0x1
	.byte	0x9
	.byte	0x3
	.quad	shrdPtr
	.uleb128 0x24
	.long	.LASF84
	.byte	0x1
	.byte	0xc
	.long	0x3e3
	.byte	0x1
	.byte	0x9
	.byte	0x3
	.quad	lock
	.uleb128 0x24
	.long	.LASF85
	.byte	0x1
	.byte	0xe
	.long	0x62
	.byte	0x1
	.byte	0x9
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
	.uleb128 0x1
	.uleb128 0x10
	.uleb128 0x6
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
	.uleb128 0x5
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
	.uleb128 0x5
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x38
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x9
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
	.uleb128 0xa
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
	.uleb128 0xb
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
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0xc
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xd
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xe
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xf
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
	.uleb128 0x10
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
	.uleb128 0x11
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
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x20
	.uleb128 0xb
	.uleb128 0x34
	.uleb128 0xc
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x13
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
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x15
	.uleb128 0x2e
	.byte	0
	.uleb128 0x3f
	.uleb128 0xc
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
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x16
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0x6
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x17
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
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x18
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
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x19
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
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x1a
	.uleb128 0xb
	.byte	0x1
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
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
	.uleb128 0x2
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x1c
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x27
	.uleb128 0xc
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x40
	.uleb128 0x6
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x1d
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
	.uleb128 0x6
	.byte	0
	.byte	0
	.uleb128 0x1e
	.uleb128 0x2e
	.byte	0x1
	.uleb128 0x3f
	.uleb128 0xc
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x3a
	.uleb128 0xb
	.uleb128 0x3b
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x3c
	.uleb128 0xc
	.byte	0
	.byte	0
	.uleb128 0x1f
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
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x20
	.uleb128 0x1d
	.byte	0x1
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x11
	.uleb128 0x1
	.uleb128 0x12
	.uleb128 0x1
	.uleb128 0x58
	.uleb128 0xb
	.uleb128 0x59
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x21
	.uleb128 0x5
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.uleb128 0x2
	.uleb128 0xa
	.byte	0
	.byte	0
	.uleb128 0x22
	.uleb128 0x5
	.byte	0
	.uleb128 0x31
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x23
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
	.uleb128 0xc
	.uleb128 0x3c
	.uleb128 0xc
	.byte	0
	.byte	0
	.uleb128 0x24
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
	.uleb128 0xc
	.uleb128 0x2
	.uleb128 0xa
	.byte	0
	.byte	0
	.byte	0
	.section	.debug_loc,"",@progbits
.Ldebug_loc0:
.LLST0:
	.quad	.LFB37-.Ltext0
	.quad	.LCFI0-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	.LCFI0-.Ltext0
	.quad	.LCFI1-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 16
	.quad	.LCFI1-.Ltext0
	.quad	.LFE37-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	0
	.quad	0
.LLST1:
	.quad	.LVL0-.Ltext0
	.quad	.LVL1-.Ltext0
	.value	0x1
	.byte	0x55
	.quad	.LVL1-.Ltext0
	.quad	.LVL3-.Ltext0
	.value	0x1
	.byte	0x53
	.quad	0
	.quad	0
.LLST2:
	.quad	.LFB38-.Ltext0
	.quad	.LCFI2-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	.LCFI2-.Ltext0
	.quad	.LCFI3-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 16
	.quad	.LCFI3-.Ltext0
	.quad	.LFE38-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	0
	.quad	0
.LLST3:
	.quad	.LVL4-.Ltext0
	.quad	.LVL5-1-.Ltext0
	.value	0x1
	.byte	0x55
	.quad	0
	.quad	0
.LLST4:
	.quad	.LVL5-.Ltext0
	.quad	.LVL6-.Ltext0
	.value	0x2
	.byte	0x30
	.byte	0x9f
	.quad	0
	.quad	0
.LLST5:
	.quad	.LVL7-.Ltext0
	.quad	.LVL8-1-.Ltext0
	.value	0x1
	.byte	0x50
	.quad	0
	.quad	0
.LLST6:
	.quad	.LFB39-.Ltext0
	.quad	.LCFI4-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	.LCFI4-.Ltext0
	.quad	.LCFI5-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 16
	.quad	.LCFI5-.Ltext0
	.quad	.LFE39-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	0
	.quad	0
.LLST7:
	.quad	.LVL9-.Ltext0
	.quad	.LVL10-.Ltext0
	.value	0x1
	.byte	0x55
	.quad	.LVL10-.Ltext0
	.quad	.LVL11-.Ltext0
	.value	0x1
	.byte	0x53
	.quad	0
	.quad	0
.LLST8:
	.quad	.LFB40-.Ltext0
	.quad	.LCFI6-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	.LCFI6-.Ltext0
	.quad	.LCFI7-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 16
	.quad	.LCFI7-.Ltext0
	.quad	.LCFI8-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 24
	.quad	.LCFI8-.Ltext0
	.quad	.LFE40-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 32
	.quad	0
	.quad	0
.LLST9:
	.quad	.LVL12-.Ltext0
	.quad	.LVL13-.Ltext0
	.value	0x1
	.byte	0x55
	.quad	0
	.quad	0
.LLST10:
	.quad	.LVL14-.Ltext0
	.quad	.LVL15-.Ltext0
	.value	0x1
	.byte	0x50
	.quad	.LVL15-.Ltext0
	.quad	.LFE40-.Ltext0
	.value	0x1
	.byte	0x53
	.quad	0
	.quad	0
.LLST11:
	.quad	.LFB41-.Ltext0
	.quad	.LCFI9-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	.LCFI9-.Ltext0
	.quad	.LCFI10-.Ltext0
	.value	0x3
	.byte	0x77
	.sleb128 64
	.quad	.LCFI10-.Ltext0
	.quad	.LFE41-.Ltext0
	.value	0x2
	.byte	0x77
	.sleb128 8
	.quad	0
	.quad	0
.LLST12:
	.quad	.LVL16-.Ltext0
	.quad	.LVL18-.Ltext0
	.value	0x1
	.byte	0x55
	.quad	0
	.quad	0
.LLST13:
	.quad	.LVL16-.Ltext0
	.quad	.LVL19-1-.Ltext0
	.value	0x1
	.byte	0x54
	.quad	0
	.quad	0
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
.LASF25:
	.string	"_chain"
.LASF7:
	.string	"size_t"
.LASF49:
	.string	"__prev"
.LASF62:
	.string	"__align"
.LASF31:
	.string	"_shortbuf"
.LASF70:
	.string	"getNewVal"
.LASF61:
	.string	"__size"
.LASF19:
	.string	"_IO_buf_base"
.LASF64:
	.string	"long long unsigned int"
.LASF50:
	.string	"__next"
.LASF72:
	.string	"newval"
.LASF46:
	.string	"long long int"
.LASF4:
	.string	"signed char"
.LASF26:
	.string	"_fileno"
.LASF14:
	.string	"_IO_read_end"
.LASF90:
	.string	"usleep"
.LASF84:
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
.LASF71:
	.string	"updaterThread"
.LASF65:
	.string	"wonk"
.LASF85:
	.string	"temp"
.LASF42:
	.string	"_IO_marker"
.LASF68:
	.string	"INSTRUMENT_ON"
.LASF3:
	.string	"unsigned int"
.LASF73:
	.string	"fprintf"
.LASF66:
	.string	"__stream"
.LASF0:
	.string	"long unsigned int"
.LASF57:
	.string	"__kind"
.LASF17:
	.string	"_IO_write_ptr"
.LASF60:
	.string	"__data"
.LASF44:
	.string	"_sbuf"
.LASF69:
	.string	"INSTRUMENT_OFF"
.LASF2:
	.string	"short unsigned int"
.LASF21:
	.string	"_IO_save_base"
.LASF80:
	.string	"stdin"
.LASF87:
	.string	"simple.c"
.LASF32:
	.string	"_lock"
.LASF27:
	.string	"_flags2"
.LASF39:
	.string	"_mode"
.LASF81:
	.string	"stdout"
.LASF55:
	.string	"__owner"
.LASF83:
	.string	"shrdPtr"
.LASF18:
	.string	"_IO_write_end"
.LASF89:
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
.LASF30:
	.string	"_vtable_offset"
.LASF11:
	.string	"FILE"
.LASF76:
	.string	"accessorThread"
.LASF54:
	.string	"__count"
.LASF53:
	.string	"__lock"
.LASF74:
	.string	"swizzle"
.LASF86:
	.string	"GNU C 4.6.1"
.LASF10:
	.string	"char"
.LASF43:
	.string	"_next"
.LASF9:
	.string	"__off64_t"
.LASF15:
	.string	"_IO_read_base"
.LASF23:
	.string	"_IO_save_end"
.LASF67:
	.string	"__fmt"
.LASF63:
	.string	"pthread_mutex_t"
.LASF88:
	.string	"/home/henry/pin/source/tools/pin_mcs/microbenchmarks/multi_thread"
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
.LASF82:
	.string	"stderr"
.LASF79:
	.string	"argv"
.LASF56:
	.string	"__nusers"
.LASF22:
	.string	"_IO_backup_base"
.LASF58:
	.string	"__spins"
.LASF78:
	.string	"argc"
.LASF59:
	.string	"__list"
.LASF77:
	.string	"main"
.LASF16:
	.string	"_IO_write_base"
.LASF75:
	.string	"result"
	.ident	"GCC: (Ubuntu/Linaro 4.6.1-9ubuntu3) 4.6.1"
	.section	.note.GNU-stack,"",@progbits
