.data
ia:      .asciiz "input a: "
ib:      .asciiz "input b: "
ic:      .asciiz "input c: "
result: .asciiz "result = "
divisor: .asciiz "divisor = "
newline: .asciiz "\n"

.text



_Start:
	#get input a, b, c

	la $a0, ia # load address of string to print input a: 
	li $v0, 4
	syscall	

	li $v0, 5 	#scanf get input a
	syscall	
	move $s0, $v0	#put a to s0

	la $a0, ib # load address of string to print input b: 
	li $v0, 4
	syscall	

	li $v0, 5 	#scanf get input b
	syscall	
	move $s1, $v0	#put b to s1
	
	
	la $a0, ic # load address of string to print input c: 
	li $v0, 4
	syscall	

	li $v0, 5 	#scanf get input c
	syscall	
	move $s2, $v0	#put c to s2

	
	#add a and b 
	add $a0, $s0, $zero	
	add $a1, $s1, $zero	
	jal Add
	move $a0, $v0 #load argument a+b
	move $a1, $s2 # load argument c
	
	jal Mmod
	move $t0, $v0
	
	####print outcome
	la $a0, result
	li $v0, 4 
	syscall
	
	add $a0, $t0, $zero
	li $v0, 1
	syscall

	la $a0, newline
	li $v0, 4 
	syscall
	
	j _Exit
	
Add: 	
	li $v0, 0 # reset return register
	add $v0, $a0, $a1#set add outcome x+y
	jr $ra	#return

	
Pow: 	
	#pow(x, p)
	#if equal 0 return 1
	#else if >1, a = a*a  return a
	
	add $t0, $a0, $zero #load first argument, number
	add $t1, $a1, $zero #load second argument, power
	beq $t1, 0, Powzero

Powcheck:
	beq $t1, 1, Powend
	mul $t0, $t0, $a0 #multiply result and x
	addi $t1, $t1, -1
	j Powcheck	
	
Powend:
	li $v0, 0 # reset return register
	add $v0, $t0, $zero #set return value as $t0
	jr $ra
	
	#if power by 0 return 1
Powzero:
	li $v0, 1 #set return value 1
	jr $ra

Mmod: 
	move $t0, $a0
	move $t1, $a1
	
	#save $ra, $t0, $t1
	
	addi $sp, $sp, -12
	sw $ra, 0($sp)
	sw $t0, 4($sp) #save x
	sw $t1, 8($sp) #save y
	
	slt $t4, $t2, $t1  #check y < x :1
	beq $t4, 0, mod2
	
	#x>y
	#get divisor
	li $a0, 2
	and $a1, $t1, 3
	jal Pow
	move $t3, $v0
	
	#get dividen
	lw $t0, 4($sp)
	
	#calculate result
	addi $t3, $t3, -1 
	and  $v0, $t0, $t3
	
	lw $ra, 0($sp)#load return address
	
	#pop stack
	addi $sp, $sp, 12
	jr $ra
		
mod2:
	#y >= x
	#get divisor
	li $a0, 2
	and $a1, $t0, 3 #set argument as pow(2, x%4)
	jal Pow
	move $t3, $v0
	
	

	
	
	
	
	
	#get dividen
	lw $t1, 8($sp)
	
	#calculate result
	addi $t3, $t3, -1 
	and  $v0, $t1, $t3
	
	lw $ra, 0($sp)#load return address
	
	#pop stack
	addi $sp, $sp, 12
	jr $ra






#terminated	
_Exit:
	li   $v0, 10
  	syscall

