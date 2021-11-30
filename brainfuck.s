.data
	arr: .skip 32768

.text
	format_chr: .asciz "%c"

.global brainfuck



# Your brainfuck subroutine will receive one argument:
# a zero termianted string containing the code to execute.
brainfuck:
	pushq %rbp
	movq %rsp, %rbp

	movq %rdi, %r12					#move string into r12 to be stored during the programme
	movq $0, %r13					#will store current char
	movq $arr, %r14					#this will be our 'vector'
	movq $0, %rbx   				#counts at which character we currently are

	movq $0, %r15					#will store how many loops are open


loopstart:
	movq $0, %r13
	movb (%r12, %rbx, 1), %r13b	#move one byte(one char) into r13
	incq %rbx




	cmp $0, %r13					#in case we reached eof, we jump past the loop
		je fini

	cmp $62, %r13
		je greaterthan_case
	cmp $60, %r13
		je lessthan_case 

	cmp $43, %r13
		je plus_case
	cmp $45, %r13
		je minus_case

	cmp $46, %r13
		je dot_case
	cmp $44, %r13
		je comma_case

	cmp $91, %r13
		je openbrack_case
	cmp $93, %r13
		je endbrack_case

	#elsecase
	jmp loopstart

greaterthan_case:
		incq %r14
		jmp loopstart

lessthan_case:
		decq %r14
		jmp loopstart

plus_case:
		incb (%r14)
		jmp loopstart

minus_case:
		decb (%r14)
		jmp loopstart

dot_case:

	movq $0, %rax
	movq $format_chr, %rdi
	movq $0, %rsi
	movb (%r14), %sil
	call printf

		jmp loopstart

comma_case:
	call getchar
	movq %rax, (%r14) 
	movq $0, %rsi
	movb (%r14), %sil
	jmp loopstart
		

openbrack_case:
		cmpb $0, (%r14)
			je go_to_match_endbrack
		pushq %rbx  					#stores the value of the next place where [ is on the stack\
		pushq %rbx
		// incq %r15
		jmp loopstart

go_to_match_endbrack:
		movq $0, %r15					#r11 will store if we meet any other [ 
	continue_match_search:
		#get next char
		movq $0, %r13
		movb (%r12, %rbx, 1), %r13b		
		andq $0xff, %r13
		incq %rbx

		cmp $91, %r13
			jne no_open_found
		incq %r15
		jmp continue_match_search

	no_open_found:

		cmp $93, %r13  					#we found the next ]
			jne continue_match_search
		cmp $0, %r15
			je loopstart

		# .else dec r11 go back
		decq %r15
		jmp continue_match_search

endbrack_case:

		popq %rax
		popq %rax
		cmpb $0, (%r14)
			je loopstart

		pushq %rax
		pushq %rax
		movq %rax, %rbx

		jmp loopstart

fini:
		
	movq %rbp, %rsp
	popq %rbp
	ret
