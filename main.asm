# Title: 			
# Filename:
# Author: 			
# Date:
# Description:
################# Data segment #####################
.data
filename: .asciiz "D:\\University\\Year 3 semester 2\\ENCS4370\\FirstProject\\testfile.txt" 

optionTable:  # Hold the function addresses
	.word AddNewUser      		# Function address for 'A' input
	.word SerchByPatientID    	# Function address for 'B' input
	.word UnNormalTests      	# Function address for 'C' input
	.word Average      		# Function address for 'D' input
	.word UpdateResult      	# Function address for 'E' input
	.word DeleteTest      		# Function address for 'F' input
	.word WriteDataAndExit  	# Function address for 'G' input
	
optionTableForSerchByPatientID:  # Hold the function addresses
	.word ShowAllTest      		# Function address for 'A' input
	.word ShowAllUnormalTest    	# Function address for 'B' input
	.word SpesificPeriod      	# Function address for 'C' input
	.word MenuLoop      		# Function address for 'D' input
	
################# Code segment #####################

.text
.globl main
main: 
    	 
    la $a0, filename
    jal ReadFile
			
MenuLoop:
	jal PrintMenu
	
	li $v0, 12	# syscall to  get data from user		
	syscall
	
	# Check for valid range ('A' = 65 and 'G' = 71)
	slti $t1, $v0, 65        	# $t1 = 1 if $v0 < 'A'
	slti $t2, $v0, 72        	# $t2 = 1 if $v0 < 'H'
	subu $t3, $t2, $t1       	# $t3 = 1 if 'A' <= $v0 < 'H', else 0
	beq $t3, $zero, MenuLoop     	# Repeat loop if not valid input

	subu $t0, $v0, 65        	# Convert 'A'-'G' to 0-6
	sll $t0, $t0, 2          	# Multiply index by 4 to convert to word offset

	la $t1, optionTable     	# Load base address of the option table
	addu $t1, $t1, $t0       	# Get the address of the function to call
	lw $t1, 0($t1)           	# Load the function address
	jalr $t1                 	# Jump and link to the function
	j MenuLoop                   	# Return to the main loop

Exit:
    li $v0, 10
    syscall

.include "functions.asm"  	# Include functions.asm file 
.include "list.asm"  		# Include list.asm file 
