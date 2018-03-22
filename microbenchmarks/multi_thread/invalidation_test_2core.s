	.file	"invalidation_test_2core.c"
	.text
.Ltext0:
	.comm	temp,4,4
	.comm	lock,40,32
	.globl	semaphore
	.data
	.align 4
	.type	semaphore, @object
	.size	semaphore, 4
semaphore:
	.long	1
	.comm	wonk_array,64,64
	.text
	.globl	INSTRUMENT_ON
	.type	INSTRUMENT_ON, @function
INSTRUMENT_ON:
.LFB2:
	.file 1 "invalidation_test_2core.c"
	.loc 1 20 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 22 0
	movl	$1, temp(%rip)
	.loc 1 23 0
	movl	$0, %eax
	.loc 1 24 0
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
	.loc 1 26 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	.loc 1 28 0
	movl	$0, temp(%rip)
	.loc 1 29 0
	movl	$0, %eax
	.loc 1 30 0
	popq	%rbp
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE3:
	.size	INSTRUMENT_OFF, .-INSTRUMENT_OFF
	.globl	accessorThreadRead1
	.type	accessorThreadRead1, @function
accessorThreadRead1:
.LFB4:
	.loc 1 32 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	.loc 1 37 0
	movq	-40(%rbp), %rax
	movq	%rax, -16(%rbp)
	.loc 1 39 0
	movq	-16(%rbp), %rax
	movq	%rax, -8(%rbp)
	.loc 1 43 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 44 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 45 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 46 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 47 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 49 0
	nop
.L6:
	.loc 1 49 0 is_stmt 0 discriminator 1
	movl	semaphore(%rip), %eax
	testl	%eax, %eax
	jne	.L6
	.loc 1 53 0 is_stmt 1
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 54 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 55 0
	movq	-8(%rbp), %rax
	movl	4(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 56 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 57 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 60 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 61 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 62 0
	movq	-8(%rbp), %rax
	movl	4(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 63 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 64 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 66 0
	movl	$0, %edi
	call	pthread_exit
	.cfi_endproc
.LFE4:
	.size	accessorThreadRead1, .-accessorThreadRead1
	.globl	accessorThreadRead2
	.type	accessorThreadRead2, @function
accessorThreadRead2:
.LFB5:
	.loc 1 70 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	.loc 1 75 0
	movq	-40(%rbp), %rax
	movq	%rax, -16(%rbp)
	.loc 1 77 0
	movq	-16(%rbp), %rax
	movq	%rax, -8(%rbp)
	.loc 1 81 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 82 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 83 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 84 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 85 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 87 0
	nop
.L8:
	.loc 1 87 0 is_stmt 0 discriminator 1
	movl	semaphore(%rip), %eax
	testl	%eax, %eax
	jne	.L8
	.loc 1 91 0 is_stmt 1
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 92 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 93 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 94 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 95 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 98 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 99 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 100 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 101 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 102 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 104 0
	movl	$0, %edi
	call	pthread_exit
	.cfi_endproc
.LFE5:
	.size	accessorThreadRead2, .-accessorThreadRead2
	.globl	accessorThreadWrite
	.type	accessorThreadWrite, @function
accessorThreadWrite:
.LFB6:
	.loc 1 107 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movq	%rdi, -40(%rbp)
	.loc 1 112 0
	movq	-40(%rbp), %rax
	movq	%rax, -16(%rbp)
	.loc 1 114 0
	movq	-16(%rbp), %rax
	movq	%rax, -8(%rbp)
	.loc 1 118 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 119 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 120 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 121 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 122 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 124 0
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
	addl	$100, %eax
	movl	%eax, %edi
	movl	$0, %eax
	call	usleep
	.loc 1 127 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 128 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 129 0
	movq	-8(%rbp), %rax
	movl	$65535, (%rax)
	.loc 1 130 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 131 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 133 0
	movl	$0, semaphore(%rip)
	.loc 1 136 0
	movl	$lock, %edi
	call	pthread_mutex_lock
	.loc 1 137 0
	movl	$0, %eax
	call	INSTRUMENT_ON
	.loc 1 138 0
	movq	-8(%rbp), %rax
	movl	(%rax), %eax
	movl	%eax, -20(%rbp)
	.loc 1 139 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 140 0
	movl	$lock, %edi
	call	pthread_mutex_unlock
	.loc 1 142 0
	movl	$0, %edi
	call	pthread_exit
	.cfi_endproc
.LFE6:
	.size	accessorThreadWrite, .-accessorThreadWrite
	.globl	main
	.type	main, @function
main:
.LFB7:
	.loc 1 145 0
	.cfi_startproc
	pushq	%rbp
	.cfi_def_cfa_offset 16
	.cfi_offset 6, -16
	movq	%rsp, %rbp
	.cfi_def_cfa_register 6
	subq	$48, %rsp
	movl	%edi, -36(%rbp)
	movq	%rsi, -48(%rbp)
	.loc 1 145 0
	movq	%fs:40, %rax
	movq	%rax, -8(%rbp)
	xorl	%eax, %eax
	.loc 1 147 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 151 0
	movl	$0, %esi
	movl	$lock, %edi
	call	pthread_mutex_init
	.loc 1 153 0
	movl	$43947, wonk_array(%rip)
	.loc 1 155 0
	leaq	-32(%rbp), %rax
	movl	$wonk_array, %ecx
	movl	$accessorThreadWrite, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 156 0
	leaq	-32(%rbp), %rax
	addq	$8, %rax
	movl	$wonk_array, %ecx
	movl	$accessorThreadRead1, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 157 0
	leaq	-32(%rbp), %rax
	addq	$16, %rax
	movl	$wonk_array, %ecx
	movl	$accessorThreadRead2, %edx
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_create
	.loc 1 158 0
	movq	-32(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 159 0
	movq	-24(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 160 0
	movq	-16(%rbp), %rax
	movl	$0, %esi
	movq	%rax, %rdi
	call	pthread_join
	.loc 1 162 0
	movl	$lock, %edi
	call	pthread_mutex_destroy
	.loc 1 164 0
	movl	$0, %eax
	call	INSTRUMENT_OFF
	.loc 1 168 0
	movl	$0, %eax
	.loc 1 170 0
	movq	-8(%rbp), %rdx
	xorq	%fs:40, %rdx
	je	.L12
	call	__stack_chk_fail
.L12:
	leave
	.cfi_def_cfa 7, 8
	ret
	.cfi_endproc
.LFE7:
	.size	main, .-main
.Letext0:
	.file 2 "/usr/include/x86_64-linux-gnu/bits/pthreadtypes.h"
	.section	.debug_info,"",@progbits
.Ldebug_info0:
	.long	0x3c1
	.value	0x4
	.long	.Ldebug_abbrev0
	.byte	0x8
	.uleb128 0x1
	.long	.LASF44
	.byte	0x1
	.long	.LASF45
	.long	.LASF46
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
	.long	.LASF12
	.byte	0x2
	.byte	0x3c
	.long	0x2d
	.uleb128 0x7
	.long	.LASF14
	.byte	0x10
	.byte	0x2
	.byte	0x4b
	.long	0xb8
	.uleb128 0x8
	.long	.LASF10
	.byte	0x2
	.byte	0x4d
	.long	0xb8
	.byte	0
	.uleb128 0x8
	.long	.LASF11
	.byte	0x2
	.byte	0x4e
	.long	0xb8
	.byte	0x8
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x93
	.uleb128 0x6
	.long	.LASF13
	.byte	0x2
	.byte	0x4f
	.long	0x93
	.uleb128 0x7
	.long	.LASF15
	.byte	0x28
	.byte	0x2
	.byte	0x5c
	.long	0x136
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
	.long	0xbe
	.byte	0x18
	.byte	0
	.uleb128 0x9
	.byte	0x28
	.byte	0x2
	.byte	0x5a
	.long	0x160
	.uleb128 0xa
	.long	.LASF24
	.byte	0x2
	.byte	0x7d
	.long	0xc9
	.uleb128 0xa
	.long	.LASF25
	.byte	0x2
	.byte	0x7e
	.long	0x160
	.uleb128 0xa
	.long	.LASF26
	.byte	0x2
	.byte	0x7f
	.long	0x5e
	.byte	0
	.uleb128 0xb
	.long	0x74
	.long	0x170
	.uleb128 0xc
	.long	0x65
	.byte	0x27
	.byte	0
	.uleb128 0x6
	.long	.LASF27
	.byte	0x2
	.byte	0x80
	.long	0x136
	.uleb128 0x2
	.byte	0x8
	.byte	0x7
	.long	.LASF28
	.uleb128 0x7
	.long	.LASF29
	.byte	0x20
	.byte	0x1
	.byte	0xe
	.long	0x199
	.uleb128 0xd
	.string	"a"
	.byte	0x1
	.byte	0xf
	.long	0x199
	.byte	0
	.byte	0
	.uleb128 0xb
	.long	0x57
	.long	0x1a9
	.uleb128 0xc
	.long	0x65
	.byte	0x7
	.byte	0
	.uleb128 0xe
	.long	.LASF30
	.byte	0x1
	.byte	0x14
	.long	0x57
	.quad	.LFB2
	.quad	.LFE2-.LFB2
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xe
	.long	.LASF31
	.byte	0x1
	.byte	0x1a
	.long	0x57
	.quad	.LFB3
	.quad	.LFE3-.LFB3
	.uleb128 0x1
	.byte	0x9c
	.uleb128 0xf
	.long	.LASF34
	.byte	0x1
	.byte	0x20
	.long	0x6c
	.quad	.LFB4
	.quad	.LFE4-.LFB4
	.uleb128 0x1
	.byte	0x9c
	.long	0x23b
	.uleb128 0x10
	.string	"arg"
	.byte	0x1
	.byte	0x20
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0x11
	.long	.LASF32
	.byte	0x1
	.byte	0x24
	.long	0x23b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x11
	.long	.LASF33
	.byte	0x1
	.byte	0x26
	.long	0x7b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x12
	.string	"i"
	.byte	0x1
	.byte	0x28
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x182
	.uleb128 0xf
	.long	.LASF35
	.byte	0x1
	.byte	0x46
	.long	0x6c
	.quad	.LFB5
	.quad	.LFE5-.LFB5
	.uleb128 0x1
	.byte	0x9c
	.long	0x299
	.uleb128 0x10
	.string	"arg"
	.byte	0x1
	.byte	0x46
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0x11
	.long	.LASF32
	.byte	0x1
	.byte	0x4a
	.long	0x23b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x11
	.long	.LASF33
	.byte	0x1
	.byte	0x4c
	.long	0x7b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x12
	.string	"i"
	.byte	0x1
	.byte	0x4e
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.byte	0
	.uleb128 0xf
	.long	.LASF36
	.byte	0x1
	.byte	0x6b
	.long	0x6c
	.quad	.LFB6
	.quad	.LFE6-.LFB6
	.uleb128 0x1
	.byte	0x9c
	.long	0x2fe
	.uleb128 0x10
	.string	"arg"
	.byte	0x1
	.byte	0x6b
	.long	0x6c
	.uleb128 0x2
	.byte	0x91
	.sleb128 -56
	.uleb128 0x11
	.long	.LASF32
	.byte	0x1
	.byte	0x6f
	.long	0x23b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -32
	.uleb128 0x11
	.long	.LASF33
	.byte	0x1
	.byte	0x71
	.long	0x7b
	.uleb128 0x2
	.byte	0x91
	.sleb128 -24
	.uleb128 0x12
	.string	"i"
	.byte	0x1
	.byte	0x73
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -36
	.uleb128 0x13
	.long	.LASF47
	.byte	0x1
	.byte	0x7c
	.long	0x57
	.uleb128 0x14
	.byte	0
	.byte	0
	.uleb128 0xf
	.long	.LASF37
	.byte	0x1
	.byte	0x91
	.long	0x57
	.quad	.LFB7
	.quad	.LFE7-.LFB7
	.uleb128 0x1
	.byte	0x9c
	.long	0x34a
	.uleb128 0x15
	.long	.LASF38
	.byte	0x1
	.byte	0x91
	.long	0x57
	.uleb128 0x2
	.byte	0x91
	.sleb128 -52
	.uleb128 0x15
	.long	.LASF39
	.byte	0x1
	.byte	0x91
	.long	0x34a
	.uleb128 0x2
	.byte	0x91
	.sleb128 -64
	.uleb128 0x12
	.string	"acc"
	.byte	0x1
	.byte	0x95
	.long	0x350
	.uleb128 0x2
	.byte	0x91
	.sleb128 -48
	.byte	0
	.uleb128 0x5
	.byte	0x8
	.long	0x6e
	.uleb128 0xb
	.long	0x88
	.long	0x360
	.uleb128 0xc
	.long	0x65
	.byte	0x1
	.byte	0
	.uleb128 0x16
	.long	.LASF40
	.byte	0x1
	.byte	0x9
	.long	0x57
	.uleb128 0x9
	.byte	0x3
	.quad	temp
	.uleb128 0x16
	.long	.LASF41
	.byte	0x1
	.byte	0xa
	.long	0x170
	.uleb128 0x9
	.byte	0x3
	.quad	lock
	.uleb128 0x16
	.long	.LASF42
	.byte	0x1
	.byte	0xc
	.long	0x57
	.uleb128 0x9
	.byte	0x3
	.quad	semaphore
	.uleb128 0xb
	.long	0x182
	.long	0x3af
	.uleb128 0xc
	.long	0x65
	.byte	0x1
	.byte	0
	.uleb128 0x16
	.long	.LASF43
	.byte	0x1
	.byte	0x12
	.long	0x39f
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
	.uleb128 0x12
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
	.uleb128 0x13
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
	.uleb128 0x14
	.uleb128 0x18
	.byte	0
	.byte	0
	.byte	0
	.uleb128 0x15
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
	.uleb128 0x16
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
.LASF34:
	.string	"accessorThreadRead1"
.LASF35:
	.string	"accessorThreadRead2"
.LASF46:
	.string	"/home/henry/HostShare/ubuntu15VM_share/pin/source/tools/pin_mcs/microbenchmarks/multi_thread"
.LASF31:
	.string	"INSTRUMENT_OFF"
.LASF24:
	.string	"__data"
.LASF12:
	.string	"pthread_t"
.LASF15:
	.string	"__pthread_mutex_s"
.LASF47:
	.string	"usleep"
.LASF18:
	.string	"__owner"
.LASF44:
	.string	"GNU C 4.9.2 -mtune=generic -march=x86-64 -g -O0 -fstack-protector-strong"
.LASF20:
	.string	"__kind"
.LASF42:
	.string	"semaphore"
.LASF32:
	.string	"thread_data"
.LASF25:
	.string	"__size"
.LASF1:
	.string	"unsigned char"
.LASF43:
	.string	"wonk_array"
.LASF0:
	.string	"long unsigned int"
.LASF40:
	.string	"temp"
.LASF2:
	.string	"short unsigned int"
.LASF33:
	.string	"array"
.LASF14:
	.string	"__pthread_internal_list"
.LASF22:
	.string	"__elision"
.LASF37:
	.string	"main"
.LASF3:
	.string	"unsigned int"
.LASF27:
	.string	"pthread_mutex_t"
.LASF28:
	.string	"long long unsigned int"
.LASF36:
	.string	"accessorThreadWrite"
.LASF21:
	.string	"__spins"
.LASF45:
	.string	"invalidation_test_2core.c"
.LASF38:
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
.LASF39:
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
.LASF41:
	.string	"lock"
.LASF29:
	.string	"wonk"
	.ident	"GCC: (Ubuntu 4.9.2-10ubuntu13) 4.9.2"
	.section	.note.GNU-stack,"",@progbits
