	.file	"test2.c"
	.text
.Ltext0:
	.comm	temp,4,4
	.comm	array,128000,64
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB2:
	.file 1 "test2.c"
	.loc 1 18 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 20 0
	movl	$1, temp(%rip)
	.loc 1 21 0
	movl	$0, %eax
	.loc 1 22 0
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
	.loc 1 24 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 26 0
	movl	$0, temp(%rip)
	.loc 1 27 0
	movl	$0, %eax
	.loc 1 28 0
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
	.loc 1 30 0
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
	.loc 1 33 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 34 0
	movl	$0, %ebx
	jmp	.L6
.L7:
	.loc 1 35 0 discriminator 3
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
	.loc 1 34 0 discriminator 3
	addl	$1, %ebx
.L6:
	.loc 1 34 0 is_stmt 0 discriminator 1
	cmpl	$1999, %ebx
	jle	.L7
	.loc 1 37 0 is_stmt 1
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 39 0
	movl	$0, %edi
	call	pthread_exit
	.cfi_endproc
.LFE4:
	.size	accessorThread, .-accessorThread
	.globl	main
	.type	main, @function
main:
.LFB5:
	.loc 1 42 0
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
	.loc 1 42 0
	movq	%fs:40, %rax
	movq	%rax, -24(%rbp)
	xorl	%eax, %eax
	.loc 1 48 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 49 0
	movl	$0, %ebx
	jmp	.L9
.L10:
	.loc 1 50 0 discriminator 3
	movslq	%ebx, %rax
	salq	$6, %rax
	addq	$array, %rax
	movl	%ebx, (%rax)
	.loc 1 49 0 discriminator 3
	addl	$1, %ebx
.L9:
	.loc 1 49 0 is_stmt 0 discriminator 1
	cmpl	$1999, %ebx
	jle	.L10
	.loc 1 52 0 is_stmt 1
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 54 0
	leaq	-48(%rbp), %rax
	movl	$array, %ecx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 55 0
	leaq	-48(%rbp), %rax
	addq	$8, %rax
	movl	$array, %ecx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 57 0
	movq	-48(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 58 0
	movq	-40(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 60 0
	movl	$0, %eax
	.loc 1 61 0
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
	.long	0x1e1
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF19
	.byte	0x1
	.long	.LASF20
	.long	.LASF21
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
	.long	.LASF22
	.byte	0x2
	.byte	0x3c
	.long	0x2d
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF10
	.uleb128 0x7
	.long	.LASF23
	.byte	0x40
	.byte	0x1
	.byte	0xb
	.long	0xb5
	.uleb128 0x8
	.string	"a"
	.byte	0x1
	.byte	0xc
	.long	0x57
	.byte	0
	.uleb128 0x8
	.string	"c"
	.byte	0x1
	.byte	0xd
	.long	0xb5
	.byte	0x4
	.byte	0
	.uleb128 0x9
	.long	0x74
	.long	0xc5
	.uleb128 0xa
	.long	0x65
	.byte	0x3b
	.byte	0
	.uleb128 0xb
	.long	.LASF11
	.byte	0x1
	.byte	0x12
	.long	0x57
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xb
	.long	.LASF12
	.byte	0x1
	.byte	0x18
	.long	0x57
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xc
	.long	.LASF13
	.byte	0x1
	.byte	0x1e
	.long	0x6c
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x13a
	.uleb128 0xd
	.string	"arg"
	.byte	0x1
	.byte	0x1e
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -40
	.uleb128 0xe
	.string	"i"
	.byte	0x1
	.byte	0x1f
	.long	0x57
	.uleb128 0x1
	.byte	0x53
	.byte	0
	.uleb128 0xc
	.long	.LASF14
	.byte	0x1
	.byte	0x2a
	.long	0x57
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x193
	.uleb128 0xf
	.long	.LASF15
	.byte	0x1
	.byte	0x2a
	.long	0x57
	.uleb128 0x3
	.byte	0x91
	.sleb128 -68
	.uleb128 0xf
	.long	.LASF16
	.byte	0x1
	.byte	0x2a
	.long	0x193
	.uleb128 0x3
	.byte	0x91
	.sleb128 -80
	.uleb128 0xe
	.string	"acc"
	.byte	0x1
	.byte	0x2e
	.long	0x199
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0xe
	.string	"i"
	.byte	0x1
	.byte	0x2f
	.long	0x57
	.uleb128 0x1
	.byte	0x53
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x6e
	.uleb128 0x9
	.long	0x82
	.long	0x1a9
	.uleb128 0xa
	.long	0x65
	.byte	0x1
	.byte	0
	.uleb128 0x10
	.long	.LASF17
	.byte	0x1
	.byte	0x9
	.long	0x57
	.uleb128 0x9
	.byte	0x3
	.quad	temp
	.uleb128 0x9
	.long	0x94
	.long	0x1cf
	.uleb128 0x11
	.long	0x65
	.value	0x7cf
	.byte	0
	.uleb128 0x10
	.long	.LASF18
	.byte	0x1
	.byte	0x10
	.long	0x1be
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
	.uleb128 0x9
	.uleb128 0x1
	.byte	0x1
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x1
	.uleb128 0x13
	.byte	0
	.byte	0
	.uleb128 0xa
	.uleb128 0x21
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x2f
	.uleb128 0xb
	.byte	0
	.byte	0
	.uleb128 0xb
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
	.uleb128 0xc
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
	.uleb128 0xd
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
	.uleb128 0xe
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
	.uleb128 0xf
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
	.uleb128 0x10
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
	.uleb128 0x11
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
.LASF9:
	.string	"long long int"
.LASF3:
	.string	"unsigned int"
.LASF13:
	.string	"accessorThread"
.LASF17:
	.string	"temp"
.LASF14:
	.string	"main"
.LASF16:
	.string	"argv"
.LASF0:
	.string	"long unsigned int"
.LASF10:
	.string	"long long unsigned int"
.LASF21:
	.string	"/mnt/hgfs/ubuntu15VM_share/pin/source/tools/pin_mcs/microbenchmarks/multi_thread"
.LASF19:
	.string	"GNU C 4.9.2 -mtune=generic -march=x86-64 -g -O0 -fstack-protector-strong"
.LASF1:
	.string	"unsigned char"
.LASF11:
	.string	"INSTRUMENT_ON"
.LASF8:
	.string	"char"
.LASF6:
	.string	"long int"
.LASF15:
	.string	"argc"
.LASF23:
	.string	"wonk"
.LASF18:
	.string	"array"
.LASF2:
	.string	"short unsigned int"
.LASF4:
	.string	"signed char"
.LASF12:
	.string	"INSTRUMENT_OFF"
.LASF20:
	.string	"test2.c"
.LASF5:
	.string	"short int"
.LASF7:
	.string	"sizetype"
.LASF22:
	.string	"pthread_t"
	.ident	"GCC: (Ubuntu 4.9.2-10ubuntu13) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
