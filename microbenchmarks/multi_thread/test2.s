	.file	"test2.c"
	.text
.Ltext0:
	.comm	temp,4,4
	.comm	lock,40,32
	.comm	array,131072,64
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB2:
	.file 1 "test2.c"
	.loc 1 19 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 21 0
	movl	$1, temp(%rip)
	.loc 1 22 0
	movl	$0, %eax
	.loc 1 23 0
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
	.loc 1 25 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 27 0
	movl	$0, temp(%rip)
	.loc 1 28 0
	movl	$0, %eax
	.loc 1 29 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	INSTRUMENT_OFF, .-INSTRUMENT_OFF
	.globl	accessorThread
	.type	accessorThread, @function
accessorThread:
.LFB4:
	.loc 1 31 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$24, %rsp
	.cfi_offset 3, -24
	movq	%rdi, -24(%rbp)
	.loc 1 34 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 36 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 37 0
	movl	$0, %ebx
	jmp	.L6
.L7:
	.loc 1 38 0 discriminator 3
	movslq	%ebx, %rax
	salq	$6, %rax
	addq	$array, %rax
	movl	(%rax), %edx
	movslq	%ebx, %rax
	salq	$6, %rax
	addq	$array, %rax
	movl	(%rax), %eax
	imull	%edx, %eax
	movslq	%ebx, %rdx
	salq	$6, %rdx
	addq	$array, %rdx
	movl	%eax, (%rdx)
	.loc 1 37 0 discriminator 3
	addl	$1, %ebx
.L6:
	.loc 1 37 0 is_stmt 0 discriminator 1
	cmpl	$2047, %ebx
	jle	.L7
	.loc 1 41 0 is_stmt 1
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 43 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 45 0
	movl	$0, %edi
	call	pthread_exit
	.cfi_endproc
.LFE4:
	.size	accessorThread, .-accessorThread
	.globl	main
	.type	main, @function
main:
.LFB5:
	.loc 1 48 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	pushq	%rbx
	subq	$56, %rsp
	.cfi_offset 3, -24
	movl	%edi, -52(%rbp)
	movq	%rsi, -64(%rbp)
	.loc 1 48 0
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	.loc 1 52 0
	movl	$0, %esi
	movl	$lock, %edi
	call	pthread_mutex_init
	.loc 1 55 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 56 0
	movl	$0, %ebx
	jmp	.L9
.L10:
	.loc 1 57 0 discriminator 3
	movslq	%ebx, %rax
	salq	$6, %rax
	addq	$array, %rax
	movl	%ebx, (%rax)
	.loc 1 56 0 discriminator 3
	addl	$1, %ebx
.L9:
	.loc 1 56 0 is_stmt 0 discriminator 1
	cmpl	$2047, %ebx
	jle	.L10
	.loc 1 59 0 is_stmt 1
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 61 0
	leaq	-48(%rbp), %rax
	movl	$array, %ecx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 62 0
	leaq	-48(%rbp), %rax
	addq	$8, %rax
	movl	$array, %ecx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 64 0
	movq	-48(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 65 0
	movq	-40(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 67 0
	movl	$0, %eax
	.loc 1 68 0
	movq	-24(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L12
	call	__stack_chk_fail
.L12:
	addq	$56, %rsp
	popq	%rbx
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	main, .-main
.Letext0:
	.file 2 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x2de
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF39
	.byte	0x1
	.long	.LASF40
	.long	.LASF41
	.quad	.Ltext0
	.quad	.Letext0-.Ltext0
	.long	.Ldebug_line0
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF0
	.uleb128 0x2
	.byte	0x1
	.byte	0x8
	.long	.LASF1
	.uleb128 0x2
	.byte	0x2
	.byte	0x7
	.long	.LASF2
	.uleb128 0x2
	.byte	0x4
	.byte	0x7
	.long	.LASF3
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF4
	.uleb128 0x2
	.byte	0x2
	.byte	0x5
	.long	.LASF5
	.uleb128 0x3
	.byte	0x4
	.byte	0x5
	.string	"int"
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF6
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF7
	.uleb128 0x4
	.byte	0x8
	.uleb128 0x5
	.byte	0x8
	.long	0x74
	.uleb128 0x2
	.byte	0x1
	.byte	0x6
	.long	.LASF8
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF9
	.uleb128 0x6
	.long	.LASF12
	.byte	0x2
	.byte	0x3c
	.long	0x2d
	.uleb128 0x7
	.long	.LASF14
	.byte	0x10
	.byte	0x2
	.byte	0x4b
	.long	0xb2
	.uleb128 0x8
	.long	.LASF10
	.byte	0x2
	.byte	0x4d
	.long	0xb2
	.byte	0
	.uleb128 0x8
	.long	.LASF11
	.byte	0x2
	.byte	0x4e
	.long	0xb2
	.byte	0x8
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x8d
	.uleb128 0x6
	.long	.LASF13
	.byte	0x2
	.byte	0x4f
	.long	0x8d
	.uleb128 0x7
	.long	.LASF15
	.byte	0x28
	.byte	0x2
	.byte	0x5c
	.long	0x130
	.uleb128 0x8
	.long	.LASF16
	.byte	0x2
	.byte	0x5e
	.long	0x57
	.byte	0
	.uleb128 0x8
	.long	.LASF17
	.byte	0x2
	.byte	0x5f
	.long	0x42
	.byte	0x4
	.uleb128 0x8
	.long	.LASF18
	.byte	0x2
	.byte	0x60
	.long	0x57
	.byte	0x8
	.uleb128 0x8
	.long	.LASF19
	.byte	0x2
	.byte	0x62
	.long	0x42
	.byte	0xc
	.uleb128 0x8
	.long	.LASF20
	.byte	0x2
	.byte	0x66
	.long	0x57
	.byte	0x10
	.uleb128 0x8
	.long	.LASF21
	.byte	0x2
	.byte	0x68
	.long	0x50
	.byte	0x14
	.uleb128 0x8
	.long	.LASF22
	.byte	0x2
	.byte	0x69
	.long	0x50
	.byte	0x16
	.uleb128 0x8
	.long	.LASF23
	.byte	0x2
	.byte	0x6a
	.long	0xb8
	.byte	0x18
	.byte	0
	.uleb128 0x9
	.byte	0x28
	.byte	0x2
	.byte	0x5a
	.long	0x15a
	.uleb128 0xa
	.long	.LASF24
	.byte	0x2
	.byte	0x7d
	.long	0xc3
	.uleb128 0xa
	.long	.LASF25
	.byte	0x2
	.byte	0x7e
	.long	0x15a
	.uleb128 0xa
	.long	.LASF26
	.byte	0x2
	.byte	0x7f
	.long	0x5e
	.byte	0
	.uleb128 0xb
	.long	0x74
	.long	0x16a
	.uleb128 0xc
	.long	0x65
	.byte	0x27
	.byte	0
	.uleb128 0x6
	.long	.LASF27
	.byte	0x2
	.byte	0x80
	.long	0x130
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF28
	.uleb128 0x7
	.long	.LASF29
	.byte	0x40
	.byte	0x1
	.byte	0xc
	.long	0x19d
	.uleb128 0xd
	.string	"a"
	.byte	0x1
	.byte	0xd
	.long	0x57
	.byte	0
	.uleb128 0xd
	.string	"c"
	.byte	0x1
	.byte	0xe
	.long	0x19d
	.byte	0x4
	.byte	0
	.uleb128 0xb
	.long	0x74
	.long	0x1ad
	.uleb128 0xc
	.long	0x65
	.byte	0x3b
	.byte	0
	.uleb128 0xe
	.long	.LASF30
	.byte	0x1
	.byte	0x13
	.long	0x57
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xe
	.long	.LASF31
	.byte	0x1
	.byte	0x19
	.long	0x57
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xf
	.long	.LASF32
	.byte	0x1
	.byte	0x1f
	.long	0x6c
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x222
	.uleb128 0x10
	.string	"arg"
	.byte	0x1
	.byte	0x1f
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0x11
	.string	"i"
	.byte	0x1
	.byte	0x20
	.long	0x57
	.uleb128 0x1
	.byte	0x53
	.byte	0
	.uleb128 0xf
	.long	.LASF33
	.byte	0x1
	.byte	0x30
	.long	0x57
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x27b
	.uleb128 0x12
	.long	.LASF34
	.byte	0x1
	.byte	0x30
	.long	0x57
	.uleb128 0x3
	.byte	0x91
	.sleb128 -68
	.uleb128 0x12
	.long	.LASF35
	.byte	0x1
	.byte	0x30
	.long	0x27b
	.uleb128 0x3
	.byte	0x91
	.sleb128 -80
	.uleb128 0x11
	.string	"acc"
	.byte	0x1
	.byte	0x33
	.long	0x281
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x11
	.string	"i"
	.byte	0x1
	.byte	0x35
	.long	0x57
	.uleb128 0x1
	.byte	0x53
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x6e
	.uleb128 0xb
	.long	0x82
	.long	0x291
	.uleb128 0xc
	.long	0x65
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.long	.LASF36
	.byte	0x1
	.byte	0x9
	.long	0x57
	.uleb128 0x9
	.byte	0x3
	.quad	temp
	.uleb128 0x13
	.long	.LASF37
	.byte	0x1
	.byte	0xa
	.long	0x16a
	.uleb128 0x9
	.byte	0x3
	.quad	lock
	.uleb128 0xb
	.long	0x17c
	.long	0x2cc
	.uleb128 0x14
	.long	0x65
	.value	0x7ff
	.byte	0
	.uleb128 0x13
	.long	.LASF38
	.byte	0x1
	.byte	0x11
	.long	0x2bb
	.uleb128 0x9
	.byte	0x3
	.quad	array
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
	.uleb128 0x3
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
	.uleb128 0x4
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0x5
	.uleb128 0xf
	.byte	0
	.uleb128 0xb
	.uleb128 0xb
	.uleb128 0x49
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0x6
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
	.uleb128 0xa
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
	.uleb128 0xe
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
	.uleb128 0xf
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
	.uleb128 0x10
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
	.uleb128 0x11
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
	.uleb128 0x12
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
	.uleb128 0x3f
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x14
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0x5
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
.LASF31:
	.string	"INSTRUMENT_OFF"
.LASF24:
	.string	"__data"
.LASF12:
	.string	"pthread_t"
.LASF15:
	.string	"__pthread_mutex_s"
.LASF18:
	.string	"__owner"
.LASF39:
	.string	"GNU C 4.9.2 -mtune=generic -march=x86-64 -g -O0 -fstack-protector-strong"
.LASF20:
	.string	"__kind"
.LASF27:
	.string	"pthread_mutex_t"
.LASF25:
	.string	"__size"
.LASF1:
	.string	"unsigned char"
.LASF0:
	.string	"long unsigned int"
.LASF36:
	.string	"temp"
.LASF2:
	.string	"short unsigned int"
.LASF40:
	.string	"test2.c"
.LASF38:
	.string	"array"
.LASF14:
	.string	"__pthread_internal_list"
.LASF22:
	.string	"__elision"
.LASF33:
	.string	"main"
.LASF3:
	.string	"unsigned int"
.LASF28:
	.string	"long long unsigned int"
.LASF21:
	.string	"__spins"
.LASF32:
	.string	"accessorThread"
.LASF41:
	.string	"/home/henry/HostShare/ubuntu15VM_share/pin/source/tools/pin_mcs/microbenchmarks/multi_thread"
.LASF34:
	.string	"argc"
.LASF7:
	.string	"sizetype"
.LASF9:
	.string	"long long int"
.LASF8:
	.string	"char"
.LASF26:
	.string	"__align"
.LASF19:
	.string	"__nusers"
.LASF17:
	.string	"__count"
.LASF16:
	.string	"__lock"
.LASF5:
	.string	"short int"
.LASF30:
	.string	"INSTRUMENT_ON"
.LASF10:
	.string	"__prev"
.LASF35:
	.string	"argv"
.LASF13:
	.string	"__pthread_list_t"
.LASF6:
	.string	"long int"
.LASF23:
	.string	"__list"
.LASF11:
	.string	"__next"
.LASF4:
	.string	"signed char"
.LASF37:
	.string	"lock"
.LASF29:
	.string	"wonk"
	.ident	"GCC: (Ubuntu 4.9.2-10ubuntu13) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
