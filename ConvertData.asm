#################### INFIX TO POSTFIX ####################
# convert notation from infix to postfix
# $s0: array of operands and operators
# $s1: boolean array differ operands and operators
# $s2: length of notation
# $s3: array of result
# $s4: isOperator of result
# $s5: length of result list
# $t0: loop index
# $t2: output list index

.macro infix_to_postfix ()
.data
.text 
	move $fp, $sp	# init $sp
	li $t0, 0	# $t0 = 0
	li $t2, 0	# $t2 = 0
	li $s5, 0	# $s5 = 0
loop:
	slt $t3, $t0, $s2	# check if not loop through array
	beq $t3, $zero, pop_stack	# if done call pop_stack
	j process_loop	# jump into process_loop
process_loop:
	sll $t3, $t0, 2	# $t3 = $t0 * 4
	add $t4, $s1, $t3	# address of isOperator?
	add $t3, $s0, $t3	# address of operand / operators
	addi $t0, $t0, 1	# increase loop index
	lw $t5, 0($t4)	# load isOperator
	lw $t6, 0($t3)	# load operand/operator
	sll $t3, $t2, 2	# $t3 = $t2 * 4
	add $t7, $s4, $t3	# $t3 = address of current isOperator result list position
	add $t3, $s3, $t3	# $t3 = address of current result list position
	li $t8, 1	# $t8 = 1
	bne $t5, $zero, process_operator	# if isOperator => call process_operator
	j process_operand
process_operand:
	sw $t6, 0($t3)	# append operand to result list
	sw $zero, 0($t7)	# isOperator = false
	addi $t2, $t2, 1	#increase index of output list
	j loop	# continue loop
process_operator:
	subi $t4, $t6, 6	# $t4 = $t6 - 6
	beq $t4, $zero, process_close_parenthese	# if close perenthese => call process_close_parenthese
	subi $t4, $t6, 5	# $t4 = $t6 - 5
	beq $t4, $zero, process_open_parenthese	# if open perenthese => call process_open_parenthese
	j process_basic	# call process_basic
process_basic:
	beq $sp, $fp, end_basic # if operator list is empty => call end_basic
	lw $t5, 0($sp)	# get top of operator stack
	subi $t4, $t5, 5
	beq $t4, $zero, end_basic	# if ( => end_basic
	sle $t4, $t6, $t5	# if $t6 <= $t5 => $t4 = 1
	beq $t4, $t8, next_basic
	j second_compare
second_compare:
	subi $t4, $t6, 1
	beq $t4, $zero, compare_plus
	subi $t4, $t6, 2
	beq $t4, $zero, compare_minus
	subi $t4, $t6, 3
	beq $t4, $zero, compare_multi
	subi $t4, $t6, 4
	beq $t4, $zero, compare_div
	j end_basic
compare_plus:
	subi $t4, $t5, 2
	beq $t4, $zero, next_basic
	j end_basic
compare_minus:
	subi $t4, $t5, 1
	beq $t4, $zero, next_basic
	j end_basic
compare_multi:
	subi $t4, $t5, 4
	beq $t4, $zero, next_basic
	j end_basic
compare_div:
	subi $t4, $t5, 3
	beq $t4, $zero, next_basic
	j end_basic
next_basic:
	addi $sp, $sp, 4	# pop from operator stack
	sw $t5, 0($t3)	# append operator to result list
	sw $t8, 0($t7)	# append isOperator to result list
	addi $t3, $t3, 4	# $t3 = address of next result list memory
	addi $t7, $t7, 4	# $t7 = address of next isOperator of result
	addi $t2, $t2, 1	# increase result list index
	j process_basic	# while loop of process_basic
end_basic:
	subi $sp, $sp, 4	# reserve 1 more word in stack
	sw $t6, 0($sp)	# push operator to stack
	j loop	# continue loop
process_open_parenthese:
	subi $sp, $sp, 4	# reserve 1 more word in stack
	sw $t6, 0($sp)	# push operator to stack
	j loop	# continue loop
process_close_parenthese:
	lw $t5, 0($sp)	# get top of operator stack
	addi $sp, $sp, 4	# pop from operator stack
	subi $t4, $t5, 5	# compare operator with (
	beq $t4, $zero, loop	# if ( => jump to loop
	sw $t5, 0($t3)	# append operator to result list
	sw $t8, 0($t7)	# append isOperator of result list
	addi $t3, $t3, 4	# $t3 = address of next result list memory
	addi $t7, $t7, 4	# $t7 = address of next isOperator result list memory
	addi $t2, $t2, 1	# increase result list index
	j process_close_parenthese	# while loop of process_close_parenthese
pop_stack:
	beq $sp, $fp, exit_infix_to_postfix	# if empty stack => exit
	sll $t3, $t2, 2	# $t3 = $t2 * 4
	addi $t2, $t2, 1	# $t2 = $t2 + 1
	add $t7, $s4, $t3	# address of current isOperator list memory
	add $t3, $s3, $t3	# address of current result list memory
	lw $t4, 0($sp)	# get top operator from stack
	addi $sp, $sp, 4	# pop from operator stack	
	sw $t4, 0($t3)	# append opertor to result list
	sw $t8, 0($t7)	# append isOperator to result list
	j pop_stack	# while loop of pop_stack
exit_infix_to_postfix:
	move $s5, $t2	# $s5 = $t2
	# jr $ra	# return to caller function
.end_macro
##########################################################

#################### REVERSE FOR PREFIX ####################
.macro reverse_for_prefix (%data, %isOp, %length)
.text
	store_all_t_register
	la $t0, (%data)
	la $t1, (%isOp)
	la $t2, (%length)
	sll $t2, $t2, 2
	subi $t2, $t2, 4
	add $t3, $t0, $t2 # end of data
	add $t4, $t1, $t2 # end of isOp
	j reverse_condition
reverse_loop:
	reverse_bracket($t0, $t1)
	reverse_bracket($t3, $t4)
	lw $t5, ($t0)
	lw $t6, ($t3)
	sw $t5, ($t3)
	sw $t6, ($t0)
	addi $t0, $t0, 4
	addi $t3, $t3, -4 
	lw $t5, ($t1)
	lw $t6, ($t4)
	sw $t5, ($t4)
	sw $t6, ($t1)
	addi $t1, $t1, 4
	addi $t4, $t4, -4 
reverse_condition:
	sub $t5, $t3, $t0 # t5 = end - begin
	bgtz $t5, reverse_loop
	beqz $t5, reverse_self
	j exit
reverse_self:
	reverse_bracket ($t3, $t4)
	j exit
exit:
	load_all_t_register
.end_macro
############################################################

#################### REVERSE BRACKET ####################
.macro reverse_bracket (%positionData, %positionOp)
.text
	store_all_t_register
	la $t0, (%positionData)
	la $t5, (%positionOp)
	lw $t6, ($t5)
	beqz $t6, exit # if not operator => exit
	lw $t1, ($t0)
	li $t2, 5 	# (
	li $t3, 6	# )
	beq $t1, $t2, save_close 
	beq $t1, $t3, save_open
	j exit
save_close:
	sw $t3, ($t0)
	j exit
save_open:
	sw $t2, ($t0)
	j exit
exit:
	load_all_t_register
.end_macro
#########################################################

#################### NUMBER TO STRING ####################
# convert inter to ascii array
.macro i_to_a (%x, %address)
.text
	la $a0, (%x)
	la $a1, (%address)

iToA:
	bnez $a0, iToA.non_zero  # first, handle the special case of a value of zero
  	li   $t0, '0'
  	sb   $t0, 0($a1)
  	sb   $zero, 1($a1)
  	li   $v0, 1
  	j exit
iToA.non_zero:
	addi $sp, $sp, -16
  	sw   $a0, 0($sp)
  	sw   $a1, 4($sp)
  	sw   $s0, 8($sp)
  	sw   $s1, 12($sp)
  	
  	addi $t0, $zero, 10    
  	li $v0, 0
  	bgtz $a0, iToA.goToRecurse  # now check for a negative value
  	li   $t1, '-'
  	sb   $t1, 0($a1)
  	addi $v0, $v0, 1
  	neg  $a0, $a0
iToA.goToRecurse:
	jal iToA.recurse
	j iToA.exit
iToA.recurse:
	
	addi $sp, $sp, -8 
	sw $ra, 0($sp) 
  	div  $a0, $t0       # $a0/10
  	mflo $s0            # $s0 = quotient
  	mfhi $s1            # s1 = remainder  
  	sw $s1, 4($sp) # store remainder
iToA.write:
	
	bnez $s0, recursion
get_result:
	lw $ra, 0($sp) 
	lw $s1, 4($sp) # get remainder
	addi $sp, $sp, 8 
  	add  $t1, $a1, $v0
  	addi $v0, $v0, 1    
  	addi $t2, $s1, 0x30 # convert to ASCII
  	sb   $t2, 0($t1)    # store in the buffer
  	jr $ra
recursion:
	move $a0, $s0
	jal iToA.recurse
	j get_result
  
iToA.exit:
  	lw   $a0, 0($sp)
  	lw   $a1, 4($sp)
  	lw   $s0, 8($sp)
  	lw   $s1, 12($sp)  
  	addi $sp, $sp, 16
exit:
.end_macro
##########################################################
