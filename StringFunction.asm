#################### PARSE LINE ####################
# parse 1 string to 2 array
.macro parse_line (%address, %length)
.text
	store_all_t_register
	la $t3, (%length)
	la $t2, (%address)
	li $t0, 0  # is negative = false
	li $t1, 0  # should be operator = false
	li $t4, 0 # current = 0
	li $t5, 0 # i = 0
	li $s2, 0
	
	j parse_condition
parse_loop:
	add $t6, $t2, $t5
	lb $t6, ($t6)
	move $t7, $t6
	sub $t6, $t6, 48 # if <0 or >9 => operator
	bltz $t6, parse_operator
	sub $t6, $t6, 9
	bgtz $t6, parse_operator
	add $t6, $t6, 9
parse_num:
	li $t7, 10
	mult $t4, $t7	
	mflo $t4
	add $t4, $t4, $t6 # current = current * 10 + a
	move $t6, $t4
	beqz $t0, parse_save_num 
	neg $t6, $t6 # negation if isNegative is true
parse_save_num:
	sll $t7, $s2, 2
	add $t7, $t7, $s0
	sw $t6, ($t7) 	# store data[s2]
	sll $t7, $s2, 2
	add $t7, $t7, $s1
	li $t6, 0 	# store isOp[s2] = false
	sw $t6, ($t7)
	li $t1, 1  # should be operator = true
	j parse_increase
parse_operator:
	# t7 is op
	li $t6, '+'
	beq $t6, $t7, parse_plus
	li $t6, '-'
	beq $t6, $t7, parse_minus
	li $t6, '*'
	beq $t6, $t7, parse_mul
	li $t6, '/'
	beq $t6, $t7, parse_div
	li $t6, '('
	beq $t6, $t7, parse_open
	li $t6, ')'
	beq $t6, $t7, parse_close
	j parse_increase
parse_plus:
	jal parse_skip_if_current
	li $t6, 1
	li $t1, 0  # should be operator = false
	j parse_save_operator
parse_minus:
	beqz $t1, parse_minus_operand
parse_minus_operator:
	jal parse_skip_if_current
	li $t6, 2
	li $t1, 0  # should be operator = false
	j parse_save_operator
parse_minus_operand:
	xori $t0, $t0, 1
	j parse_increase
parse_mul:
	jal parse_skip_if_current
	li $t6, 3
	li $t1, 0  # should be operator = false
	j parse_save_operator
parse_div:
	jal parse_skip_if_current
	li $t6, 4
	li $t1, 0  # should be operator = false
	j parse_save_operator
parse_open:
	jal parse_skip_if_current
	li $t6, 5
	j parse_save_operator
parse_close:
	jal parse_skip_if_current
	li $t6, 6
	j parse_save_operator
parse_save_operator:
	sll $t7, $s2, 2
	add $t7, $t7, $s0
	sw $t6, ($t7) 	# store data[s2]
	sll $t7, $s2, 2
	add $t7, $t7, $s1
	li $t6, 1 	# store isOp[s2] = true
	sw $t6, ($t7)
	addi $s2, $s2, 1 # increase s2
	li $t0, 0  # is negative = false
	
	j parse_increase
parse_increase:
	addi $t5, $t5, 1
parse_condition:
	bne $t5, $t3, parse_loop
	jal parse_skip_if_current
	load_all_t_register
	j exit
parse_skip_if_current:
	beqz $t4, parse_skip_return
	addi $s2, $s2, 1
	li $t4, 0 # current = 0
	li $t0, 0  # is negative = false
parse_skip_return:
	jr $ra
exit:
.end_macro
####################################################
