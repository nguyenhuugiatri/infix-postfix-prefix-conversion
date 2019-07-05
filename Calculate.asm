#################### CALCULATE ####################
# $s3: array of postfix
# $s4: isOperator of postfix
# $s5: length of postfix list
# $s7: final result
# $t0: loop index
# $t1: address in array postfix
# $t2: address in isOperator array
# $t3: current value
.macro calculate_postfix ()
.data

.text
	li $t0, 0		# $t0 = 0
	move $t1, $s3	# $t1 = $s3
	move $t2, $s4	# $t2 = $s4
loop:
	slt $t7, $t0, $s5	# if $t0 < $s5 => $t7 = 1
	beq $t7, $zero, save_result	# if finish loop => call save_result
	j process_loop	# jump into loop
process_loop:
	lw $t3, 0($t1)	# load from postfix array
	lw $t4, 0($t2)	# load from isOperator array
	addi $t0, $t0, 1	# increase loop index
	addi $t1, $t1, 4	# increase memory address
	addi $t2, $t2, 4	# increase memory address
	beq $t4, $zero, process_operand	# if is operand => call process_operand
	j process_operator	# else call process_operator
process_operand:
	subi $sp, $sp, 4 # reserve 1 word in stack
	sw $t3, 0($sp)	# store operand in stack
	j loop	# continue loop
process_operator:
	lw $t5, 0($sp)	# load 1st operand from stack
	addi $sp, $sp, 4	# pop 1st operand from stack
	lw $t6, 0($sp)	# load 2nd operand from stack
	addi $sp, $sp, 4	# pop 2nd operand from stack
	slti $t7, $t3, 2 # if operator is + => $t7 = 1
	bne $t7, $zero, process_plus	# if $t3 is + => process_plus
	slti $t7, $t3, 3 # if operator is - => $t7 = 1
	bne $t7, $zero, process_minus	# if $t3 is - => process_minus
	slti $t7, $t3, 4 # if operator is * => $t7 = 1
	bne $t7, $zero, process_multiply	# if $t3 is * => process_multiply
	slti $t7, $t3, 5 # if operator is / => $t7 = 1
	bne $t7, $zero, process_divide	# if $t3 is / => process_divide
process_plus:
	add $t7, $t6, $t5	# $t7 = $t6 + $t5
	j push_stack
process_minus:
	sub $t7, $t6, $t5	# $t7 = $t6 - $t5
	j push_stack
process_multiply:
	mult $t6, $t5	# $LO = $t6 * $t5
	mflo $t7	# $t7 = result of multiplication
	j push_stack
process_divide:
	div $t6, $t5	# $LO = $t6 / $t5
	mflo $t7	# $t7 = result of division
	j push_stack
push_stack:
	subi $sp, $sp, 4	# reserve 1 word in stack
	sw $t7, 0($sp)	# push result to stack
	j loop	# jump back to loop
save_result:
	lw $s7, 0($sp)	# pop last final result from stack
	addi $sp, $sp, 4	# pop from stack
	# jr $ra	# return to caller function
.end_macro
###################################################