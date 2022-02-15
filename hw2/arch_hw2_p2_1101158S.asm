.data
str1:		.asciiz "Round "
str2:		.asciiz " start...\n"
str3:		.asciiz "Please places a bet:\n"
str4:		.asciiz "Now, even(0) or odd(1)? \n"
str5:		.asciiz "correct!\n"
str6:		.asciiz "incorrect!\n"
str7:		.asciiz " marbles\n"
str8:		.asciiz "you have "
str9:		.asciiz " marbels now!\n"
str10:		.asciiz "you win!\n"
str11:		.asciiz " marbels!\n"
str12: 		.asciiz "You have "
str13:		.asciiz "you lose!\n"
str14:		.asciiz "Your enemy have more marbles\n"
str15:		.asciiz "You have more merbles\n"
str16:		.asciiz	"After three rounds, "
str17:		.asciiz "both you two are lose!\n"
str18:		.asciiz"Incorrect input!, you only have "

.text

#########DONOT MODIFY HERE###########
#Setup initial marbles
addi $t0, $zero, 10	# your marbles
addi $t1, $zero, 10	# your emeny's marbles
addi $t2, $zero, 1	#round
########################################## 

######How to generate random number?######## 
#addi $a1, $zero, 10 # int range(1, 10)
#addi $v0, $zero, 42  #syscall for generating random int into $a0
#syscall
#move $t3, $a0 
#addi $t3, $t3, 1
##########################################

##########How to check odd/even?############ 
#addi $t5, $zero, 2    # Store 2 in $t0
#div $t5, $t4, $t5     # Divide input by 2
#mfhi $s1              # Save remainder in $s1
#if s1 = 1, it's odd
#if s1 = 0, it's even
##########################################

#Game start!      	
_Start:
Round:	

	#check wether game still within 3 round 
	sgt $t6, $t2, 3		
	beq $t6, 1, threeround	#if over three round then jump


	la $a0, str1	 # load address of string to print "Round"
	li $v0, 4	 # ready to print string
	syscall	         # print
	
	li $v0, 1        # ready to print int "round number"
	move $a0, $t2    # load int value to $a0
	syscall	         # print
	
	la $a0, str2	 # load address of string to print "Start.."
	li $v0, 4	 # ready to print string
	syscall	         # print

	#get user's bet
	la $a0, str3	 # load address of string to print "Please place a bet:\n"
	li $v0, 4	 # ready to print string
	syscall	 

	li $v0, 5 	#scanf get bet number
	syscall
	move $s1, $v0
	
	#check whether the input is valid
	
	slt $t6, $t0, $s1 # check wether user bet over his total amount 1 = bet over
	beq $t6, 0, getguess
	
	#warn the user
	la $a0, str18 	# load address of string to print "Incorrect input!, you only have "
	li $v0, 4	# ready to print string
	syscall
	
	move $a0, $t0 	# load int to print marbles' number
	li $v0, 1	# ready to print int
	syscall
	
	la $a0, str7	# load address of string to print "marbels!"
	li $v0, 4	# ready to print string
	syscall
	
	j Round 	# go back to the beginning
	
getguess:
	#get user's guess
	la $a0, str4	 # load address of string to print "even or odd""
	li $v0, 4	 # ready to print string
	syscall	 

	li $v0, 5 	#scanf get bet number
	syscall
	move $s2, $v0
 
	

	
correctinputs:
	#Generate random number
	add $a1, $zero, $t1 # rand int, set max bound to enemy's left marble
	addi $v0, $zero, 42  #syscall for generating random int into $a0
	syscall
	move $t4, $a0 
	addi $t4, $t4, 1 #rand int min bound
	
	#print ramdom number
	#li $v0, 1        # ready to print int
	#move $a0, $t4    # load int value to $a0
	#syscall	         # print
	
	#check odd/even
	addi $t5, $zero, 2    # Store 2 in $t0
    	div $t5, $t4, $t5     # Divide input by 2
    	mfhi $s3              # Save remainder in $s1
	
	#print odd/even
	#li $v0, 1        # ready to print int
	#move $a0, $s1    # load int value to $a0
	#syscall	         # print
	
	
	bne $s3, $s2, incorrect  #check player's guess with answer
	
	# player guess is correct
	la $a0, str5	 # load address of string to print "correct"
	li $v0, 4	 # ready to print string
	syscall	         # print
	
	add $t0, $t0, $s1 #add player's bet to player's marble
	sub $t1, $t1, $s1 #sub enemy's marble
	
	la $a0, str8 	# load address of string to print "you have"
	li $v0, 4	# ready to print string
	syscall
	
	move $a0, $t0 	# load int to print marbles' number
	li $v0, 1	# ready to print int
	syscall
	
	la $a0, str9	# load address of string to print "marbels now!"
	li $v0, 4	# ready to print string
	syscall
	
	j checkwinner
	
incorrect:	
	#player's guess is not correct
	la $a0, str6	 # load address of string to print "incorrect"
	li $v0, 4	 # ready to print string
	syscall	         # print
	
	add $t1, $t1, $t4 #add enemy's bet to enemy's marble
	sub $t0, $t0, $t4 #sub player's marble
	
	la $a0, str8 	# load address of string to print "you have"
	li $v0, 4	# ready to print string
	syscall
	
	move $a0, $t0 	# load int to print marbles' number
	li $v0, 1	# ready to print int
	syscall
	
	la $a0, str9	# load address of string to print "marbels now!"
	li $v0, 4	# ready to print string
	syscall
	
	
	j checkwinner


checkwinner:
	#check each still have marble
	slti $t6, $t0, 1  #check player
	beq $t6, 1, loseInThree
	
	slti $t6, $t1, 1  #check enemy
	
	addi $t2, $t2, 1 #add round number
	
	
	bne $t6, 1, Round
	
	#player win within three round
	la $a0, str10 	# load address of string to print "you win!"
	li $v0, 4	# ready to print string
	syscall
	
	la $a0, str12 	# load address of string to print "You have"
	li $v0, 4	# ready to print string
	syscall
	
	move $a0, $t0 	# load int to print marbles' number
	li $v0, 1	# ready to print int
	syscall
	
	la $a0, str7	# load address of string to print "marbels"
	li $v0, 4	# ready to print string
	syscall
	
	j _Exit
loseInThree:
	#player lose within three round
	la $a0, str13 	# load address of string to print "you lose!"
	li $v0, 4	# ready to print string
	syscall
	
	la $a0, str12 	# load address of string to print "You have"
	li $v0, 4	# ready to print string
	syscall
	
	move $a0, $t0 	# load int to print marbles' number
	li $v0, 1	# ready to print int
	syscall
	
	la $a0, str7	# load address of string to print "marbels!"
	li $v0, 4	# ready to print string
	syscall
	
	j _Exit
	



threeround:
	
	la $a0, str16 	# load address of string to print "After three round, "
	li $v0, 4	# ready to print string
	syscall
	
	slt $t6, $t0, $t1 #check if player have fewer
	beq $t6, 1, playerlose
	
	slt $t6, $t1, $t0 #check if enemy have fewer
	beq $t6, 1, playerwin
	
	la $a0, str17 	# load address of string to print "Both you two are lose"
	li $v0, 4	# ready to print string
	syscall
	j _Exit

playerlose:
	la $a0, str13 	# load address of string to print "you lose!"
	li $v0, 4	# ready to print string
	syscall
	
	la $a0, str14 	# load address of string to print "your enemy have more marbles!"
	li $v0, 4	# ready to print string
	syscall
	
	j _Exit
playerwin:
	la $a0, str10 	# load address of string to print "you lose!"
	li $v0, 4	# ready to print string
	syscall
	
	la $a0, str15 	# load address of string to print "your enemy have more marbles!"
	li $v0, 4	# ready to print string
	syscall
	j _Exit

#terminated	
_Exit:
	li   $v0, 10
  	syscall
