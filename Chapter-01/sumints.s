	.section	__TEXT,__text,regular,pure_instructions
	.macosx_version_min 10, 12
	.globl	_main
_main:                                  ## @main
Lfunc_begin0:
	.file	1 "sumints.c"
	.loc	1 5 0                   ## sumints.c:5:0
	.cfi_startproc
## BB#0:
	pushq	%rbp
Ltmp0:
	.cfi_def_cfa_offset 16
Ltmp1:
	.cfi_offset %rbp, -16
	movq	%rsp, %rbp
Ltmp2:
	.cfi_def_cfa_register %rbp
	pushq	%r15
	pushq	%r14
	pushq	%rbx
	pushq	%rax
Ltmp3:
	.cfi_offset %rbx, -40
Ltmp4:
	.cfi_offset %r14, -32
Ltmp5:
	.cfi_offset %r15, -24
	##DEBUG_VALUE: main:argc <- %EDI
	##DEBUG_VALUE: main:argv <- %RSI
	movq	%rsi, %r14
Ltmp6:
	##DEBUG_VALUE: main:argv <- %R14
	movl	%edi, %r15d
Ltmp7:
	##DEBUG_VALUE: main:numIter <- 1000
	##DEBUG_VALUE: main:max <- 1000
	##DEBUG_VALUE: main:argc <- %R15D
	movl	$1000, %ecx             ## imm = 0x3E8
	.loc	1 9 7 prologue_end      ## sumints.c:9:7
Ltmp8:
	cmpl	$2, %r15d
	movl	$1000, %ebx             ## imm = 0x3E8
	jl	LBB0_4
Ltmp9:
## BB#1:
	##DEBUG_VALUE: main:argc <- %R15D
	##DEBUG_VALUE: main:argv <- %R14
	.loc	1 10 16                 ## sumints.c:10:16
	movq	8(%r14), %rdi
	.loc	1 10 11 is_stmt 0       ## sumints.c:10:11
	callq	_atol
	movq	%rax, %rbx
Ltmp10:
	##DEBUG_VALUE: main:numIter <- %RBX
	movl	$1000, %ecx             ## imm = 0x3E8
Ltmp11:
	.loc	1 12 7 is_stmt 1        ## sumints.c:12:7
	cmpl	$3, %r15d
	jl	LBB0_3
Ltmp12:
## BB#2:
	##DEBUG_VALUE: main:numIter <- %RBX
	##DEBUG_VALUE: main:argc <- %R15D
	##DEBUG_VALUE: main:argv <- %R14
	.loc	1 13 12                 ## sumints.c:13:12
	movq	16(%r14), %rdi
	.loc	1 13 7 is_stmt 0        ## sumints.c:13:7
	callq	_atol
	movq	%rax, %rcx
Ltmp13:
	##DEBUG_VALUE: main:max <- %RCX
LBB0_3:
	##DEBUG_VALUE: main:numIter <- %RBX
	##DEBUG_VALUE: main:argc <- %R15D
	##DEBUG_VALUE: main:argv <- %R14
	##DEBUG_VALUE: main:totalSum <- 0
	##DEBUG_VALUE: main:k <- 0
	xorl	%edx, %edx
	.loc	1 16 2 is_stmt 1        ## sumints.c:16:2
Ltmp14:
	testq	%rbx, %rbx
                                        ## implicit-def: %RSI
	jle	LBB0_6
Ltmp15:
LBB0_4:
	##DEBUG_VALUE: main:argc <- %R15D
	##DEBUG_VALUE: main:argv <- %R14
	leaq	-1(%rcx), %rax
	leaq	-2(%rcx), %rdx
	mulq	%rdx
	shldq	$63, %rax, %rdx
	leaq	-1(%rdx,%rcx,2), %rax
	xorl	%edi, %edi
	xorl	%edx, %edx
Ltmp16:
LBB0_5:                                 ## =>This Inner Loop Header: Depth=1
	testq	%rcx, %rcx
	.loc	1 19 2                  ## sumints.c:19:2
Ltmp17:
	movq	%rax, %rsi
	cmovleq	%rdi, %rsi
Ltmp18:
	.loc	1 22 11                 ## sumints.c:22:11
	addq	%rsi, %rdx
Ltmp19:
	##DEBUG_VALUE: main:totalSum <- %RDX
	.loc	1 16 2                  ## sumints.c:16:2
	decq	%rbx
	jne	LBB0_5
Ltmp20:
LBB0_6:
	.loc	1 37 2                  ## sumints.c:37:2
	leaq	L_.str(%rip), %rdi
	xorl	%eax, %eax
	callq	_printf
	.loc	1 38 2                  ## sumints.c:38:2
	xorl	%eax, %eax
	addq	$8, %rsp
	popq	%rbx
	popq	%r14
	popq	%r15
	popq	%rbp
	retq
Ltmp21:
Lfunc_end0:
	.cfi_endproc

	.section	__TEXT,__cstring,cstring_literals
L_.str:                                 ## @.str
	.asciz	"%ld (total: %ld)\n"

	.section	__DWARF,__debug_str,regular,debug
Linfo_string:
	.asciz	"Apple LLVM version 8.0.0 (clang-800.0.38)" ## string offset=0
	.asciz	"sumints.c"             ## string offset=42
	.asciz	"/Users/marcel/Documents/Writing/CocoaOptimizationBook/test-programs" ## string offset=52
	.asciz	"main"                  ## string offset=120
	.asciz	"int"                   ## string offset=125
	.asciz	"argc"                  ## string offset=129
	.asciz	"argv"                  ## string offset=134
	.asciz	"char"                  ## string offset=139
	.asciz	"numIter"               ## string offset=144
	.asciz	"long int"              ## string offset=152
	.asciz	"max"                   ## string offset=161
	.asciz	"totalSum"              ## string offset=165
	.asciz	"k"                     ## string offset=174
	.asciz	"i"                     ## string offset=176
	.asciz	"sum"                   ## string offset=178
	.section	__DWARF,__debug_loc,regular,debug
Lsection_debug_loc:
Ldebug_loc0:
Lset0 = Lfunc_begin0-Lfunc_begin0
	.quad	Lset0
Lset1 = Ltmp7-Lfunc_begin0
	.quad	Lset1
	.short	3                       ## Loc expr size
	.byte	85                      ## super-register DW_OP_reg5
	.byte	147                     ## DW_OP_piece
	.byte	4                       ## 4
Lset2 = Ltmp7-Lfunc_begin0
	.quad	Lset2
Lset3 = Ltmp16-Lfunc_begin0
	.quad	Lset3
	.short	3                       ## Loc expr size
	.byte	95                      ## super-register DW_OP_reg15
	.byte	147                     ## DW_OP_piece
	.byte	4                       ## 4
	.quad	0
	.quad	0
Ldebug_loc1:
Lset4 = Lfunc_begin0-Lfunc_begin0
	.quad	Lset4
Lset5 = Ltmp6-Lfunc_begin0
	.quad	Lset5
	.short	1                       ## Loc expr size
	.byte	84                      ## DW_OP_reg4
Lset6 = Ltmp6-Lfunc_begin0
	.quad	Lset6
Lset7 = Ltmp16-Lfunc_begin0
	.quad	Lset7
	.short	1                       ## Loc expr size
	.byte	94                      ## DW_OP_reg14
	.quad	0
	.quad	0
Ldebug_loc2:
Lset8 = Ltmp7-Lfunc_begin0
	.quad	Lset8
Lset9 = Ltmp10-Lfunc_begin0
	.quad	Lset9
	.short	3                       ## Loc expr size
	.byte	17                      ## DW_OP_consts
	.byte	232                     ## 1000
	.byte	7                       ## 
Lset10 = Ltmp10-Lfunc_begin0
	.quad	Lset10
Lset11 = Ltmp15-Lfunc_begin0
	.quad	Lset11
	.short	1                       ## Loc expr size
	.byte	83                      ## DW_OP_reg3
	.quad	0
	.quad	0
Ldebug_loc3:
Lset12 = Ltmp7-Lfunc_begin0
	.quad	Lset12
Lset13 = Ltmp13-Lfunc_begin0
	.quad	Lset13
	.short	3                       ## Loc expr size
	.byte	17                      ## DW_OP_consts
	.byte	232                     ## 1000
	.byte	7                       ## 
Lset14 = Ltmp13-Lfunc_begin0
	.quad	Lset14
Lset15 = Ltmp13-Lfunc_begin0
	.quad	Lset15
	.short	1                       ## Loc expr size
	.byte	82                      ## DW_OP_reg2
	.quad	0
	.quad	0
Ldebug_loc4:
Lset16 = Ltmp13-Lfunc_begin0
	.quad	Lset16
Lset17 = Ltmp19-Lfunc_begin0
	.quad	Lset17
	.short	2                       ## Loc expr size
	.byte	17                      ## DW_OP_consts
	.byte	0                       ## 0
Lset18 = Ltmp19-Lfunc_begin0
	.quad	Lset18
Lset19 = Ltmp20-Lfunc_begin0
	.quad	Lset19
	.short	1                       ## Loc expr size
	.byte	81                      ## DW_OP_reg1
	.quad	0
	.quad	0
	.section	__DWARF,__debug_abbrev,regular,debug
Lsection_abbrev:
	.byte	1                       ## Abbreviation Code
	.byte	17                      ## DW_TAG_compile_unit
	.byte	1                       ## DW_CHILDREN_yes
	.byte	37                      ## DW_AT_producer
	.byte	14                      ## DW_FORM_strp
	.byte	19                      ## DW_AT_language
	.byte	5                       ## DW_FORM_data2
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	16                      ## DW_AT_stmt_list
	.byte	6                       ## DW_FORM_data4
	.byte	27                      ## DW_AT_comp_dir
	.byte	14                      ## DW_FORM_strp
	.ascii	"\341\177"              ## DW_AT_APPLE_optimized
	.byte	12                      ## DW_FORM_flag
	.byte	17                      ## DW_AT_low_pc
	.byte	1                       ## DW_FORM_addr
	.byte	18                      ## DW_AT_high_pc
	.byte	1                       ## DW_FORM_addr
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	2                       ## Abbreviation Code
	.byte	46                      ## DW_TAG_subprogram
	.byte	1                       ## DW_CHILDREN_yes
	.byte	17                      ## DW_AT_low_pc
	.byte	1                       ## DW_FORM_addr
	.byte	18                      ## DW_AT_high_pc
	.byte	1                       ## DW_FORM_addr
	.byte	64                      ## DW_AT_frame_base
	.byte	10                      ## DW_FORM_block1
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	58                      ## DW_AT_decl_file
	.byte	11                      ## DW_FORM_data1
	.byte	59                      ## DW_AT_decl_line
	.byte	11                      ## DW_FORM_data1
	.byte	39                      ## DW_AT_prototyped
	.byte	12                      ## DW_FORM_flag
	.byte	73                      ## DW_AT_type
	.byte	19                      ## DW_FORM_ref4
	.byte	63                      ## DW_AT_external
	.byte	12                      ## DW_FORM_flag
	.ascii	"\341\177"              ## DW_AT_APPLE_optimized
	.byte	12                      ## DW_FORM_flag
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	3                       ## Abbreviation Code
	.byte	5                       ## DW_TAG_formal_parameter
	.byte	0                       ## DW_CHILDREN_no
	.byte	2                       ## DW_AT_location
	.byte	6                       ## DW_FORM_data4
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	58                      ## DW_AT_decl_file
	.byte	11                      ## DW_FORM_data1
	.byte	59                      ## DW_AT_decl_line
	.byte	11                      ## DW_FORM_data1
	.byte	73                      ## DW_AT_type
	.byte	19                      ## DW_FORM_ref4
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	4                       ## Abbreviation Code
	.byte	52                      ## DW_TAG_variable
	.byte	0                       ## DW_CHILDREN_no
	.byte	2                       ## DW_AT_location
	.byte	6                       ## DW_FORM_data4
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	58                      ## DW_AT_decl_file
	.byte	11                      ## DW_FORM_data1
	.byte	59                      ## DW_AT_decl_line
	.byte	11                      ## DW_FORM_data1
	.byte	73                      ## DW_AT_type
	.byte	19                      ## DW_FORM_ref4
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	5                       ## Abbreviation Code
	.byte	52                      ## DW_TAG_variable
	.byte	0                       ## DW_CHILDREN_no
	.byte	28                      ## DW_AT_const_value
	.byte	13                      ## DW_FORM_sdata
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	58                      ## DW_AT_decl_file
	.byte	11                      ## DW_FORM_data1
	.byte	59                      ## DW_AT_decl_line
	.byte	11                      ## DW_FORM_data1
	.byte	73                      ## DW_AT_type
	.byte	19                      ## DW_FORM_ref4
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	6                       ## Abbreviation Code
	.byte	52                      ## DW_TAG_variable
	.byte	0                       ## DW_CHILDREN_no
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	58                      ## DW_AT_decl_file
	.byte	11                      ## DW_FORM_data1
	.byte	59                      ## DW_AT_decl_line
	.byte	11                      ## DW_FORM_data1
	.byte	73                      ## DW_AT_type
	.byte	19                      ## DW_FORM_ref4
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	7                       ## Abbreviation Code
	.byte	36                      ## DW_TAG_base_type
	.byte	0                       ## DW_CHILDREN_no
	.byte	3                       ## DW_AT_name
	.byte	14                      ## DW_FORM_strp
	.byte	62                      ## DW_AT_encoding
	.byte	11                      ## DW_FORM_data1
	.byte	11                      ## DW_AT_byte_size
	.byte	11                      ## DW_FORM_data1
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	8                       ## Abbreviation Code
	.byte	15                      ## DW_TAG_pointer_type
	.byte	0                       ## DW_CHILDREN_no
	.byte	73                      ## DW_AT_type
	.byte	19                      ## DW_FORM_ref4
	.byte	0                       ## EOM(1)
	.byte	0                       ## EOM(2)
	.byte	0                       ## EOM(3)
	.section	__DWARF,__debug_info,regular,debug
Lsection_info:
Lcu_begin0:
	.long	217                     ## Length of Unit
	.short	2                       ## DWARF version number
Lset20 = Lsection_abbrev-Lsection_abbrev ## Offset Into Abbrev. Section
	.long	Lset20
	.byte	8                       ## Address Size (in bytes)
	.byte	1                       ## Abbrev [1] 0xb:0xd2 DW_TAG_compile_unit
	.long	0                       ## DW_AT_producer
	.short	12                      ## DW_AT_language
	.long	42                      ## DW_AT_name
Lset21 = Lline_table_start0-Lsection_line ## DW_AT_stmt_list
	.long	Lset21
	.long	52                      ## DW_AT_comp_dir
	.byte	1                       ## DW_AT_APPLE_optimized
	.quad	Lfunc_begin0            ## DW_AT_low_pc
	.quad	Lfunc_end0              ## DW_AT_high_pc
	.byte	2                       ## Abbrev [2] 0x2f:0x8e DW_TAG_subprogram
	.quad	Lfunc_begin0            ## DW_AT_low_pc
	.quad	Lfunc_end0              ## DW_AT_high_pc
	.byte	1                       ## DW_AT_frame_base
	.byte	86
	.long	120                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	4                       ## DW_AT_decl_line
	.byte	1                       ## DW_AT_prototyped
	.long	189                     ## DW_AT_type
	.byte	1                       ## DW_AT_external
	.byte	1                       ## DW_AT_APPLE_optimized
	.byte	3                       ## Abbrev [3] 0x4f:0xf DW_TAG_formal_parameter
Lset22 = Ldebug_loc0-Lsection_debug_loc ## DW_AT_location
	.long	Lset22
	.long	129                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	4                       ## DW_AT_decl_line
	.long	189                     ## DW_AT_type
	.byte	3                       ## Abbrev [3] 0x5e:0xf DW_TAG_formal_parameter
Lset23 = Ldebug_loc1-Lsection_debug_loc ## DW_AT_location
	.long	Lset23
	.long	134                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	4                       ## DW_AT_decl_line
	.long	196                     ## DW_AT_type
	.byte	4                       ## Abbrev [4] 0x6d:0xf DW_TAG_variable
Lset24 = Ldebug_loc2-Lsection_debug_loc ## DW_AT_location
	.long	Lset24
	.long	144                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	7                       ## DW_AT_decl_line
	.long	213                     ## DW_AT_type
	.byte	4                       ## Abbrev [4] 0x7c:0xf DW_TAG_variable
Lset25 = Ldebug_loc3-Lsection_debug_loc ## DW_AT_location
	.long	Lset25
	.long	161                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	7                       ## DW_AT_decl_line
	.long	213                     ## DW_AT_type
	.byte	4                       ## Abbrev [4] 0x8b:0xf DW_TAG_variable
Lset26 = Ldebug_loc4-Lsection_debug_loc ## DW_AT_location
	.long	Lset26
	.long	165                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	7                       ## DW_AT_decl_line
	.long	213                     ## DW_AT_type
	.byte	5                       ## Abbrev [5] 0x9a:0xc DW_TAG_variable
	.byte	0                       ## DW_AT_const_value
	.long	174                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	6                       ## DW_AT_decl_line
	.long	213                     ## DW_AT_type
	.byte	6                       ## Abbrev [6] 0xa6:0xb DW_TAG_variable
	.long	176                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	7                       ## DW_AT_decl_line
	.long	213                     ## DW_AT_type
	.byte	6                       ## Abbrev [6] 0xb1:0xb DW_TAG_variable
	.long	178                     ## DW_AT_name
	.byte	1                       ## DW_AT_decl_file
	.byte	7                       ## DW_AT_decl_line
	.long	213                     ## DW_AT_type
	.byte	0                       ## End Of Children Mark
	.byte	7                       ## Abbrev [7] 0xbd:0x7 DW_TAG_base_type
	.long	125                     ## DW_AT_name
	.byte	5                       ## DW_AT_encoding
	.byte	4                       ## DW_AT_byte_size
	.byte	8                       ## Abbrev [8] 0xc4:0x5 DW_TAG_pointer_type
	.long	201                     ## DW_AT_type
	.byte	8                       ## Abbrev [8] 0xc9:0x5 DW_TAG_pointer_type
	.long	206                     ## DW_AT_type
	.byte	7                       ## Abbrev [7] 0xce:0x7 DW_TAG_base_type
	.long	139                     ## DW_AT_name
	.byte	6                       ## DW_AT_encoding
	.byte	1                       ## DW_AT_byte_size
	.byte	7                       ## Abbrev [7] 0xd5:0x7 DW_TAG_base_type
	.long	152                     ## DW_AT_name
	.byte	5                       ## DW_AT_encoding
	.byte	8                       ## DW_AT_byte_size
	.byte	0                       ## End Of Children Mark
	.section	__DWARF,__debug_ranges,regular,debug
Ldebug_range:
	.section	__DWARF,__debug_macinfo,regular,debug
Ldebug_macinfo:
Lcu_macro_begin0:
	.byte	0                       ## End Of Macro List Mark
	.section	__DWARF,__apple_names,regular,debug
Lnames_begin:
	.long	1212240712              ## Header Magic
	.short	1                       ## Header Version
	.short	0                       ## Header Hash Function
	.long	1                       ## Header Bucket Count
	.long	1                       ## Header Hash Count
	.long	12                      ## Header Data Length
	.long	0                       ## HeaderData Die Offset Base
	.long	1                       ## HeaderData Atom Count
	.short	1                       ## DW_ATOM_die_offset
	.short	6                       ## DW_FORM_data4
	.long	0                       ## Bucket 0
	.long	2090499946              ## Hash in Bucket 0
	.long	LNames0-Lnames_begin    ## Offset in Bucket 0
LNames0:
	.long	120                     ## main
	.long	1                       ## Num DIEs
	.long	47
	.long	0
	.section	__DWARF,__apple_objc,regular,debug
Lobjc_begin:
	.long	1212240712              ## Header Magic
	.short	1                       ## Header Version
	.short	0                       ## Header Hash Function
	.long	1                       ## Header Bucket Count
	.long	0                       ## Header Hash Count
	.long	12                      ## Header Data Length
	.long	0                       ## HeaderData Die Offset Base
	.long	1                       ## HeaderData Atom Count
	.short	1                       ## DW_ATOM_die_offset
	.short	6                       ## DW_FORM_data4
	.long	-1                      ## Bucket 0
	.section	__DWARF,__apple_namespac,regular,debug
Lnamespac_begin:
	.long	1212240712              ## Header Magic
	.short	1                       ## Header Version
	.short	0                       ## Header Hash Function
	.long	1                       ## Header Bucket Count
	.long	0                       ## Header Hash Count
	.long	12                      ## Header Data Length
	.long	0                       ## HeaderData Die Offset Base
	.long	1                       ## HeaderData Atom Count
	.short	1                       ## DW_ATOM_die_offset
	.short	6                       ## DW_FORM_data4
	.long	-1                      ## Bucket 0
	.section	__DWARF,__apple_types,regular,debug
Ltypes_begin:
	.long	1212240712              ## Header Magic
	.short	1                       ## Header Version
	.short	0                       ## Header Hash Function
	.long	3                       ## Header Bucket Count
	.long	3                       ## Header Hash Count
	.long	20                      ## Header Data Length
	.long	0                       ## HeaderData Die Offset Base
	.long	3                       ## HeaderData Atom Count
	.short	1                       ## DW_ATOM_die_offset
	.short	6                       ## DW_FORM_data4
	.short	3                       ## DW_ATOM_die_tag
	.short	5                       ## DW_FORM_data2
	.short	4                       ## DW_ATOM_type_flags
	.short	11                      ## DW_FORM_data1
	.long	0                       ## Bucket 0
	.long	-1                      ## Bucket 1
	.long	1                       ## Bucket 2
	.long	-1880351968             ## Hash in Bucket 0
	.long	193495088               ## Hash in Bucket 2
	.long	2090147939              ## Hash in Bucket 2
	.long	Ltypes1-Ltypes_begin    ## Offset in Bucket 0
	.long	Ltypes0-Ltypes_begin    ## Offset in Bucket 2
	.long	Ltypes2-Ltypes_begin    ## Offset in Bucket 2
Ltypes1:
	.long	152                     ## long int
	.long	1                       ## Num DIEs
	.long	213
	.short	36
	.byte	0
	.long	0
Ltypes0:
	.long	125                     ## int
	.long	1                       ## Num DIEs
	.long	189
	.short	36
	.byte	0
	.long	0
Ltypes2:
	.long	139                     ## char
	.long	1                       ## Num DIEs
	.long	206
	.short	36
	.byte	0
	.long	0
	.section	__DWARF,__apple_exttypes,regular,debug
Lexttypes_begin:
	.long	1212240712              ## Header Magic
	.short	1                       ## Header Version
	.short	0                       ## Header Hash Function
	.long	1                       ## Header Bucket Count
	.long	0                       ## Header Hash Count
	.long	12                      ## Header Data Length
	.long	0                       ## HeaderData Die Offset Base
	.long	1                       ## HeaderData Atom Count
	.short	7                       ## DW_ATOM_ext_types
	.short	6                       ## DW_FORM_data4
	.long	-1                      ## Bucket 0

.subsections_via_symbols
	.section	__DWARF,__debug_line,regular,debug
Lsection_line:
Lline_table_start0:
