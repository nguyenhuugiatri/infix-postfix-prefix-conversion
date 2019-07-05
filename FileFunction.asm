.include "StringFunction.asm"
#################### READ FILE ####################
.macro read_file(%buffer, %pathOfFile)
.data
	path: .asciiz %pathOfFile
.text
#============ Mo file o che do read-only ============
	li $v0, 13
	la $a0, path
	li $a1, 0
	li $a2, 0
	syscall
	move $s0, $v0	# Sao luu $v0 (file descriptor)
	
#============ Doc file va tra ve buffer ============
	li $v0, 14		# Gan file descriptor vao $a0
	move $a0, $s0	# Gan dia chi buffer vao $a1
	la $a1, (%buffer)	# Gan so luong ki tu duoc doc toi da vao $a1
	li $a2, 1024
	syscall
	addi $sp, $sp, -4	# Store lai thanh ghi $v0 ($v0 = so luong ki tu duoc doc)
	sw $v0, 0($sp)
	
#============ Dong file ============
	li $v0, 16
	move $a0, $s0
	syscall
	
	lw $v0, 0($sp)	# Load lai thanh ghi $v0
	addi $sp, $sp, 4
.end_macro
###################################################

#################### GET LINE ####################
.macro get_line(%buffer, %newLine, %length)
.text
	store_all_s_register
	store_all_t_register
	la $s0, (%buffer)		# Nguon vao la 1 buffer
	la $s1, (%newLine)	# Noi tra ve
	la $s2, (%length)		# Tong so luong ki tu can doc
	li $t7, 10			# Xuong hang ascii
	li $v0, 0			# So ki tu da doc
	j gl_condition
	
gl_loop:
	add $t2, $s1, $v0		# Dia chi bat dau doc
	sb $t1, 0($t2)		# Doc 1 ki tu
	addi $v0, $v0, 1		# Tang length dang doc len 1
	
gl_condition:
	beq $v0, $s2, gl_end_file	# if(so ki tu da doc == so ki tu can doc) gl_end_file
	add $t1, $v0, $s0			# else $t1 = so ki tu da doc + &buffer (Dia chi ki tu tiep theo)
	lb $t1, 0($t1) 			# Xet ki tu cuoi
	bne $t1, $t7, gl_loop		# Khong phai ki tu xuong dong thi doc tiep
	load_all_t_register
	load_all_s_register
	j gl_exit
	
gl_end_file:
	li $v0, -1
	
gl_exit:
.end_macro
##################################################

#################### PRINT STRING IN NEW FILE ####################
.macro print_string_new_file(%line, %length, %fileName)
.data
file: .asciiz %fileName	

.text
file_open:
    li $v0, 13
    la $a0, file
    li $a1, 1
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
file_write:
    move $a0, $v0  # Syscall 15 requieres file descriptor in $a0
    li $v0, 15
    la $a1, (%line)
    la $a2, (%length)
    syscall
file_close:
    li $v0, 16  # $a0 already has the file descriptor
    syscall
.end_macro
###################################################################

#################### PRINT STRING APPEND ####################
# print string append
.macro print_string_append(%address, %length, %filename)
.data
file: .asciiz %filename	# file = %filename

.text
file_open:
    li $v0, 13
    la $a0, file
    li $a1, 9 # append mode
    li $a2, 0
    syscall  # File descriptor gets returned in $v0
file_write:
    move $a0, $v0  # Syscall 15 requieres file descriptor in $a0
    li $v0, 15
    la $a1, (%address)
    la $a2, (%length)
    syscall
file_close:
    li $v0, 16  # $a0 already has the file descriptor
    syscall
.end_macro
#############################################################

#################### PRINT INT ####################
# print int
.macro print_int (%x, %filename) 
.data
newInt: .space 20
.text
	la $t1, newInt
	la $t0, (%x)
	addi $sp, $sp, -4
	sw $t1, 0($sp)
	i_to_a ($t0, $t1)
	lw $t1, 0($sp)
	addi $sp, $sp, 4
	add $t2, $zero, $v0  #length
	print_string_append ($t1, $t2, %filename)
.end_macro
###################################################

#################### PRINT NEW LINE ####################
# print new line
.macro print_new_line (%filename) 
.data
newline: .space 1
.text
	la $t1, newline
	li $t0, 10
	sb $t0, 0($t1) # save 1 to t1
	li $t2, 1 #length
	print_string_append ($t1, $t2, %filename)
.end_macro	
#######################################################

#################### PRINT EXPRESSION ####################
# print expression
.macro print_expression (%data, %isOp, %length, %filename)
.data
.text 
	la $t0, (%data) # get data
	la $t1, (%isOp)
	la $t2, (%length)
	li $t3, 0  # set i = 0
	j ex_check_loop
ex_body:
	sll $t4, $t3, 2 
	add $t4, $t4, $t0
	lw $t4, ($t4) # t4 = data[i]
	sll $t5, $t3, 2 
	add $t5, $t5, $t1
	lw $t5, ($t5) # t5 = isOp[i]
	addi $sp, $sp, -24 # store register
	sw $t0, 0($sp)
	sw $t1, 4($sp)
	sw $t2, 8($sp)
	sw $t3, 12($sp)
	sw $t4, 16($sp)
	sw $t5, 20($sp)
	bne $t5, $zero, ex_go_print_operator
ex_go_print_int:
	print_int ($t4, %filename)
	j ex_end_body
ex_go_print_operator:
	print_operator($t4, %filename)
ex_end_body:
	print_space (%filename)
	lw $t0, 0($sp)
	lw $t1, 4($sp)
	lw $t2, 8($sp)
	lw $t3, 12($sp)
	lw $t4, 16($sp)
	lw $t5, 20($sp)
	addi $sp, $sp, 24 # retrieve register
	addi $t3, $t3, 1 # i ++
ex_check_loop:
	bne $t3, $t2, ex_body # if i != n => loop
	print_new_line (%filename) 
.end_macro
##########################################################

#################### PRINT OPERATOR ####################
# print operator
.macro print_operator (%x, %filename)
.data
newchar: .space 1
.text
	la $t0, (%x)
	la $t1, newchar
	slti $t3, $t0, 2 # if operator is + 
	bne $t3, $zero, op_plus
	slti $t3, $t0, 3 # if operator is - 
	bne $t3, $zero, op_minus
	slti $t3, $t0, 4 # if operator is * 
	bne $t3, $zero, op_mul
	slti $t3, $t0, 5 # if operator is / 
	bne $t3, $zero, op_div
	slti $t3, $t0, 6 # if operator is ( 
	bne $t3, $zero, op_open
	slti $t3, $t0, 7 # if operator is ) 
	bne $t3, $zero, op_close
	j op_print
op_plus:
	li $t3, '+'
	sb $t3, 0($t1) # save char to t1
	j op_print
op_minus:
	li $t3, '-'
	sb $t3, 0($t1) # save char to t1
	j op_print
op_mul:
	li $t3, '*'
	sb $t3, 0($t1) # save char to t1
	j op_print
op_div:
	li $t3, '/'
	sb $t3, 0($t1) # save char to t1
	j op_print
op_open:
	li $t3, '('
	sb $t3, 0($t1) # save char to t1
	j op_print
op_close:
	li $t3, ')'
	sb $t3, 0($t1) # save char to t1
	j op_print
op_print:
	li $t2, 1
	print_string_append ($t1, $t2, %filename)
.end_macro
########################################################

#################### PRINT SPACE ####################
# print space
.macro print_space (%filename) 
.data
newline: .space 1
.text
	la $t1, newline
	li $t0, 32
	sb $t0, 0($t1) # save 1 to t1
	li $t2, 1 #length
	print_string_append ($t1, $t2, %filename)
.end_macro	
#####################################################