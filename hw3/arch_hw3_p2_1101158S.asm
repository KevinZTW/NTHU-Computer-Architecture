.data
ia:      .asciiz "input a: "
ib:      .asciiz "input b: "
ic:      .asciiz "input c: "
ans: .asciiz "ans: "
newline: .asciiz "\n"

.text



_Start:
	#get input a, b

	la $a0, ia # load address of string to print input a: 
	li $v0, 4 
	syscall	

	li $v0, 5 	# scanf get input a
	syscall	
	move $s0, $v0	# put a to s0

	la $a0, ib # load address of string to print input b: 
	li $v0, 4
	syscall	

	li $v0, 5 	#scanf get input b
	syscall	
	move $s1, $v0	#put b to s1
	
	# set argument and call fn(a, b)
	move $a0, $s0
	move $a1, $s1
	
	jal Fn
	move $s2, $v0 #store value of c

	# print fn outcome
	la $a0, ans
	li $v0, 4 
	syscall
	
	add $a0,$s2, $zero
	li $v0, 1
	syscall

	#print new line
	la $a0, newline
	li $v0, 4 
	syscall

	#set argument for re(x)
	move $a0, $s0
	jal Re
	add $s2, $s2, $v0 #add re(a) to c
	
	
	# print fn outcome
	la $a0, ans
	li $v0, 4 
	syscall
	
	
	add $a0,$s2, $zero
	li $v0, 1
	syscall

	la $a0, newline
	li $v0, 4 
	syscall
	
	j _Exit
	


Fn:	
	move $t0, $a0
	move $t1, $a1
	
	# store argument & $ra to stack
	addi $sp, $sp, -16
	sw $t0, 0($sp) # store x
	sw $t1, 4($sp) # store y
	sw $ra, 8($sp) # store return address
	
	# if x <= 0
	slt $t3, $zero, $t0 # t3 is 1 if x > 0, 0 if x <= 0
	beq $t3, 0, Fn1
	
	# if y <= 0
	slt $t3, $zero, $t1 
	beq $t3, 0, Fn1
	
	# if x < y 
	slt $t3, $t0, $t1 # t3 is 1 if x < y
	beq $t3, 1, Fn2



	# load argument for fn(x - 1, y)
	addi $a0, $t0, -1
	jal Fn # recursive call
	sw $v0, 12($sp) # store result on stack

	# load argument for fn(x,y + 2) 
	lw $a0, 0($sp)
	lw $a1, 4($sp)
	addi $a1,$a1 ,2 # argumnet y+2
	jal Fn # recursive call
	
	# calcualte and return 	
	move $t4, $v0
	mul $t4, $t4, 2 # fn(x,y + 2) *2
	
	
	lw $t3,  4($sp)
	add $t4, $t4, $t3 # fn(x,y + 2) *2+y
	
	
	
	lw $t3,  12($sp)
	add $t4, $t4, $t3 # return fn(x - 1, y) fn(x,y + 2) *2+y

	lw $ra, 8($sp)
	addi $sp, $sp, 16 	# clean up stack
	move $v0, $t4
	jr $ra
	

Fn1:
	li $v0, 0 # set return value to 0
	lw $ra, 8($sp)
	addi $sp, $sp, 16 	# clean up stack
	jr $ra
	
Fn2:
	li $v0, 1 #set return value to 1
	lw $ra, 8($sp)
	addi $sp, $sp, 16 	# clean up stack
	jr $ra
	
	
Re:
	move $t0, $a0
	addi $sp, $sp, -8
	sw $t0, 0($sp)
	sw $ra, 4($sp)
	#test x <= 0 
	slt $t2, $zero, $a0 # t2 = 1 if x > 0
	beq $t2, 0, Re1
	
	addi $a0, $a0, -1
	
	jal Re
	move $t3, $v0
	addi $t3, $t3, 1
	move $v0, $t3 #set return value
	lw $ra, 4($sp) # load return address back 
	addi $sp, $sp, 8 	# clean up stack
	jr $ra
	
	
Re1:
	li $v0, 0 # set return value to 0
	lw $ra, 4($sp)
	addi $sp, $sp, 8 	# clean up stack
	jr $ra	
	

#terminated	
_Exit:
	li   $v0, 10
  	syscall

