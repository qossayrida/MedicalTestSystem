.data
nextNodeIs: .asciiz "\n\tThe next node is:\t"
	
patientIDLabel: .asciiz "\t- Patient ID: "
testNameLabel: .asciiz "\t test name: "
testYearLabel: .asciiz "\t test date: "
firstResultLabel: .asciiz "\t result: "
secondResultLabel: .asciiz "\t second result: "

.text

# Returns:
#   $S0 - address for linked list if not exist
#   $V0 - address for new node
AddNewNode:
    beq $s0, $zero, CreateList  # If head is null, create list

    # Allocate memory for new node
    li $v0, 9          	# syscall to allocate memory
    li $a0, 32          # 32 bytes needed 
    syscall                    
    sw $zero, 28($v0)   # Set next pointer to null

    # Traverse the linked list to find the last node
    move $t1, $s0               # Start from the head of the list
    find_last:
        lw $t2, 28($t1)         # Load the 'next' pointer of the current node
        beq $t2, $zero, append  # If 'next' is null, current node is the last node
        move $t1, $t2           # Move to the next node in the list
        j find_last             # Continue searching

    # Append the new node at the end of the list
    append:
        sw $v0, 28($t1)         # Set the next pointer of the last node to new node address
        jr $ra                  # Return to caller

    CreateList:
	li $v0, 9		# syscall to allocating memory	
	li $a0, 32		# 28 bytes needed 
	syscall				
	move $s0, $v0		# store this address as the head
	sw $zero, 28($s0)	# Set next pointer to null
	jr $ra					


# Arguments:
#   $a0 - address of the node to print it 
printNode:
	move $t4,$a0		# Copy address of the node to $t4
	
	la $a0, patientIDLabel	# Print patient ID label			
	li $v0, 4				
	syscall	
	move $a0, $t4		# Print patient ID value		
	li $v0, 4				
	syscall	
	
	addi $t4,$t4,8		# Move to the next data field (test name)
	lw $t5,0($t4)		# Load test name to check if has tow result
	
	la $a0, testNameLabel	# Print test name label			
	li $v0, 4				
	syscall	
	move $a0, $t4		# Print test name value		
	li $v0, 4				
	syscall	
	
	addi $t4,$t4,4		# Move to the next data field (test year)
	
	la $a0, testYearLabel	# Print test year label			
	li $v0, 4				
	syscall	
	move $a0, $t4		# Print test year value		
	li $v0, 4				
	syscall	
	
	addi $t4,$t4,8		# Move to the next data field (first test result)
	
	la $a0, firstResultLabel	# Print first test result label				
	li $v0, 4				
	syscall	
	lwc1 $f12,0($t4) 		# Load and print first test result value		
	li $v0, 2				
	syscall	

	# Check if there is a second test result available
	li $t6, 12			# Load test label index
    	lw $t7,testLabels($t6)		# Load test label from predefined labels array
	bne $t5,$t7,FinishPrintNode	# Compare test label with current test name

	la $a0, secondResultLabel	# If the test label matches, print second test result label			
	li $v0, 4				
	syscall	
	lwc1 $f12,4($t4) 		# Load and print second test result value
    	li $v0,2
    	syscall	
	
    FinishPrintNode:
	jr $ra


# Arguments:
#   $a1 - address of the node to delete it 
#   $a2 - address of the previes node
deleteNode:
    move $t0, $a1               # Copy address of the node to be deleted to $t0
    move $t1, $a2               # Copy address of the previous node to $t1
    
    # Check if the node to be deleted is the head of the list
    beq $s0, $t0, UpdateHead    # If it is, update the head of the list
    
    # If it's not the head, we need to update the previous node's 'next' pointer
    lw $t2, 28($t0)             # Load the 'next' pointer of the node to be deleted
    sw $t2, 28($t1)             # Update the 'next' pointer of the previous node
    
    j DeleteFinish              # Finish deleting the node
       
    UpdateHead:
        lw $t3, 28($s0)         # Load the 'next' pointer of the head node
        move $s0, $t3           # Update the head to the next node
        j DeleteFinish           # Finish deleting the node
    
    DeleteFinish:
        jr $ra
        
# Arguments:
#   $a1 - address of the node to update it 
updateNode:
    move $t0, $a1               # Copy address of the node to be update to $t0
