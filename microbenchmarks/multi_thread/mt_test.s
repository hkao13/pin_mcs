	.file	"mt_test.c"
	.text
.Ltext0:
	.comm	temp,4,4
	.comm	wonk_array,64,64
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB2:
	.file 1 "mt_test.c"
	.loc 1 17 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 19 0
	movl	$1, temp(%rip)
	.loc 1 20 0
	movl	$0, %eax
	.loc 1 21 0
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
	.loc 1 23 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 25 0
	movl	$0, temp(%rip)
	.loc 1 26 0
	movl	$0, %eax
	.loc 1 27 0
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
	.loc 1 29 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	.loc 1 35 0
	movq	-40(%rbp), %rax
	movq	%rax, -16(%rbp)
	.loc 1 37 0
	movq	-16(%rbp), %rax
	movq	%rax, -8(%rbp)
	.loc 1 42 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 43 0
	movl	$0, -20(%rbp)
	jmp	.L6
.L7:
	.loc 1 45 0 discriminator 3
	movl	-20(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rdx
	movq	-8(%rbp), %rax
	addq	%rax, %rdx
	movl	-20(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rcx
	movq	-8(%rbp), %rax
	addq	%rcx, %rax
	movl	(%rax), %ecx
	movl	-20(%rbp), %eax
	cltq
	leaq	0(,%rax,4), %rsi
	movq	-8(%rbp), %rax
	addq	%rsi, %rax
	movl	(%rax), %eax
	imull	%ecx, %eax
	movl	%eax, (%rdx)
	.loc 1 46 0 discriminator 3
	movl	temp(%rip), %eax
	leal	1(%rax), %edx
	movl	%edx, temp(%rip)
	movl	%eax, temp(%rip)
	.loc 1 43 0 discriminator 3
	addl	$1, -20(%rbp)
.L6:
	.loc 1 43 0 is_stmt 0 discriminator 1
	cmpl	$7, -20(%rbp)
	jle	.L7
	.loc 1 49 0 is_stmt 1
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 51 0
	movl	$0, %edi
	call	pthread_exit
	.cfi_endproc
.LFE4:
	.size	accessorThread, .-accessorThread
	.section	.rodata
.LC0:
	.string	"mt_test.c"
.LC1:
	.string	"wonk_array[0].a[i] == i * i"
	.text
	.globl	main
	.type	main, @function
main:
.LFB5:
	.loc 1 54 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$64, %rsp
	movl	%edi, -52(%rbp)
	movq	%rsi, -64(%rbp)
	.loc 1 54 0
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	.loc 1 56 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 62 0
	movl	$0, -36(%rbp)
	jmp	.L9
.L10:
	.loc 1 63 0 discriminator 3
	movl	-36(%rbp), %eax
	cltq
	movl	-36(%rbp), %edx
	movl	%edx, wonk_array(,%rax,4)
	.loc 1 62 0 discriminator 3
	addl	$1, -36(%rbp)
.L9:
	.loc 1 62 0 is_stmt 0 discriminator 1
	cmpl	$7, -36(%rbp)
	jle	.L10
	.loc 1 66 0 is_stmt 1
	leaq	-32(%rbp), %rax
	movl	$wonk_array, %ecx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 67 0
	leaq	-32(%rbp), %rax
	addq	$8, %rax
	movl	$wonk_array, %ecx
	movl	$accessorThread, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 69 0
	movq	-32(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 70 0
	movq	-24(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 72 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 74 0
	movl	$0, -36(%rbp)
	jmp	.L11
.L13:
	.loc 1 75 0
	movl	-36(%rbp), %eax
	cltq
	movl	wonk_array(,%rax,4), %edx
	movl	-36(%rbp), %eax
	imull	-36(%rbp), %eax
	cmpl	%eax, %edx
	je	.L12
	.loc 1 75 0 is_stmt 0 discriminator 1
	movl	$__PRETTY_FUNCTION__.3251, %ecx
	movl	$75, %edx
	movl	$.LC0, %esi
	movl	$.LC1, %edi
	call	__assert_fail
.L12:
	.loc 1 74 0 is_stmt 1 discriminator 2
	addl	$1, -36(%rbp)
.L11:
	.loc 1 74 0 is_stmt 0 discriminator 1
	cmpl	$7, -36(%rbp)
	jle	.L13
	.loc 1 78 0 is_stmt 1
	movl	$0, %eax
	.loc 1 80 0
	movq	-8(%rbp), %rcx
	xorq	%fs:40, %rcx
	je	.L15
	call	__stack_chk_fail
.L15:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE5:
	.size	main, .-main
	.section	.rodata
	.type	__PRETTY_FUNCTION__.3251, @object
	.size	__PRETTY_FUNCTION__.3251, 5
__PRETTY_FUNCTION__.3251:
	.string	"main"
	.text
.Letext0:
	.file 2 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x228
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF21
	.byte	0x1
	.long	.LASF22
	.long	.LASF23
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
	.uleb128 0x5
	.byte	0x8
	.long	0x57
	.uleb128 0x2
	.byte	0x8
	.byte	0x5
	.long	.LASF9
	.uleb128 0x6
	.long	.LASF24
	.byte	0x2
	.byte	0x3c
	.long	0x2d
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF10
	.uleb128 0x7
	.long	.LASF25
	.byte	0x20
	.byte	0x1
	.byte	0xb
	.long	0xb1
	.uleb128 0x8
	.string	"a"
	.byte	0x1
	.byte	0xc
	.long	0xb1
	.byte	0
	.byte	0
	.uleb128 0x9
	.long	0x57
	.long	0xc1
	.uleb128 0xa
	.long	0x65
	.byte	0x7
	.byte	0
	.uleb128 0xb
	.long	.LASF11
	.byte	0x1
	.byte	0x11
	.long	0x57
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xb
	.long	.LASF12
	.byte	0x1
	.byte	0x17
	.long	0x57
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xc
	.long	.LASF15
	.byte	0x1
	.byte	0x1d
	.long	0x6c
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x153
	.uleb128 0xd
	.string	"arg"
	.byte	0x1
	.byte	0x1d
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0xe
	.long	.LASF13
	.byte	0x1
	.byte	0x21
	.long	0x153
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0xe
	.long	.LASF14
	.byte	0x1
	.byte	0x24
	.long	0x7b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0xf
	.string	"i"
	.byte	0x1
	.byte	0x27
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x9a
	.uleb128 0xc
	.long	.LASF16
	.byte	0x1
	.byte	0x36
	.long	0x57
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x1c6
	.uleb128 0x10
	.long	.LASF17
	.byte	0x1
	.byte	0x36
	.long	0x57
	.uleb128 0x3
	.byte	0x91
	.sleb128 -68
	.uleb128 0x10
	.long	.LASF18
	.byte	0x1
	.byte	0x36
	.long	0x1c6
	.uleb128 0x3
	.byte	0x91
	.sleb128 -80
	.uleb128 0xf
	.string	"acc"
	.byte	0x1
	.byte	0x3a
	.long	0x1cc
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.uleb128 0xf
	.string	"i"
	.byte	0x1
	.byte	0x3c
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -52
	.uleb128 0x11
	.long	.LASF26
	.long	0x1ec
	.uleb128 0x9
	.byte	0x3
	.quad	__PRETTY_FUNCTION__.3251
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x6e
	.uleb128 0x9
	.long	0x88
	.long	0x1dc
	.uleb128 0xa
	.long	0x65
	.byte	0x1
	.byte	0
	.uleb128 0x9
	.long	0x74
	.long	0x1ec
	.uleb128 0xa
	.long	0x65
	.byte	0x4
	.byte	0
	.uleb128 0x12
	.long	0x1dc
	.uleb128 0x13
	.long	.LASF19
	.byte	0x1
	.byte	0x9
	.long	0x57
	.uleb128 0x9
	.byte	0x3
	.quad	temp
	.uleb128 0x9
	.long	0x9a
	.long	0x216
	.uleb128 0xa
	.long	0x65
	.byte	0x1
	.byte	0
	.uleb128 0x13
	.long	.LASF20
	.byte	0x1
	.byte	0xf
	.long	0x206
	.uleb128 0x9
	.byte	0x3
	.quad	wonk_array
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
	.uleb128 0xf
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
	.uleb128 0x10
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
	.uleb128 0x11
	.uleb128 0x34
	.byte	0
	.uleb128 0x3
	.uleb128 0xe
	.uleb128 0x49
	.uleb128 0x13
	.uleb128 0x34
	.uleb128 0x19
	.uleb128 0x2
	.uleb128 0x18
	.byte	0
	.byte	0
	.uleb128 0x12
	.uleb128 0x26
	.byte	0
	.uleb128 0x49
	.uleb128 0x13
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
.LASF12:
	.string	"INSTRUMENT_OFF"
.LASF21:
	.string	"GNU C 4.9.2 -mtune=generic -march=x86-64 -g -O0 -fstack-protector-strong"
.LASF26:
	.string	"__PRETTY_FUNCTION__"
.LASF13:
	.string	"thread_data"
.LASF24:
	.string	"pthread_t"
.LASF1:
	.string	"unsigned char"
.LASF20:
	.string	"wonk_array"
.LASF0:
	.string	"long unsigned int"
.LASF19:
	.string	"temp"
.LASF2:
	.string	"short unsigned int"
.LASF22:
	.string	"mt_test.c"
.LASF14:
	.string	"array"
.LASF16:
	.string	"main"
.LASF3:
	.string	"unsigned int"
.LASF10:
	.string	"long long unsigned int"
.LASF15:
	.string	"accessorThread"
.LASF23:
	.string	"/home/henry/HostShare/ubuntu15VM_share/pin/source/tools/pin_mcs/microbenchmarks/multi_thread"
.LASF17:
	.string	"argc"
.LASF7:
	.string	"sizetype"
.LASF9:
	.string	"long long int"
.LASF8:
	.string	"char"
.LASF5:
	.string	"short int"
.LASF11:
	.string	"INSTRUMENT_ON"
.LASF18:
	.string	"argv"
.LASF6:
	.string	"long int"
.LASF4:
	.string	"signed char"
.LASF25:
	.string	"wonk"
	.ident	"GCC: (Ubuntu 4.9.2-10ubuntu13) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
