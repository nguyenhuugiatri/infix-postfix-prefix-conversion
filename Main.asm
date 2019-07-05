.include "Helper.asm"
.include "FileFunction.asm"
.include "ConvertData.asm"
.include "Calculate.asm"

# t0 buffer
# t1 line
# t2 length of buffer
# t3 length of line
.data
	trash: .space 10
	buffer: .space 1024
	line: .space 1024
	data: .word 0:100
	isOp: .word 0:100
	postfixdata: .word 0:100
	postfixisOp: .word 0:100
.text
	la $t0, buffer
	la $t1, line
	la $s0, data
	la $s1, isOp
	la $s3, postfixdata
	la $s4, postfixisOp
	store_all_s_register
	read_file ($t0, "input.txt")
	load_all_s_register
	move $t2, $v0
	
	li $t5, 0
	la $t7, trash
	print_string_new_file($t7, $t5, "postfix.txt")
	print_string_new_file($t7, $t5, "prefix.txt")
	print_string_new_file($t7, $t5, "result.txt")
	
	j loop_increase
	
loop_body:
	parse_line ($t1, $t3)
	
	store_all_t_register
	infix_to_postfix
	calculate_postfix
	load_all_t_register
	
	
	store_all_t_register
	print_int ($s7, "result.txt") 
	print_new_line ("result.txt")
	load_all_t_register

solve_post:
	store_all_t_register
	print_expression ($s3, $s4, $s5, "postfix.txt")
	load_all_t_register
solve_pre:
	reverse_for_prefix ($s0, $s1, $s2)
	store_all_t_register
	infix_to_postfix
	load_all_t_register
	reverse_for_prefix ($s3, $s4, $s5)
	store_all_t_register
	print_expression ($s3, $s4, $s5, "prefix.txt") 
	load_all_t_register
	j loop_increase
loop_increase:
	get_line ($t0, $t1, $t2)
	move $t3, $v0
	jal skip_line
	
loop_condition:
	bgez $t3, loop_body # if not end of file => loop
	j exit
	
skip_line:
	add $t0, $t0, $t3
	addi $t0, $t0, 1
	sub $t2, $t2, $t3
	subi $t2, $t2, 1
	jr $ra 
exit:
	
