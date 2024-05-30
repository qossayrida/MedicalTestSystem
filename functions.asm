.macro StoreComma
    li $v0, 15
    move $a0,$s2 		
    la $a1, comma   
    li $a2, 1
    syscall
.end_macro

.data 

welcome: .asciiz "\n\nWelcome, Specify an action to do:"
addTest: .asciiz "\n\tA To add new medical test."
searchByPatient: .asciiz "\n\tB To search for test by patient ID."
searchByTest: .asciiz "\n\tC To search for unnormal tests."
average: .asciiz "\n\tD To calculate average for test."
update: .asciiz "\n\tE To update test result."
delete: .asciiz "\n\tF To delete test."
orTerminateWithG: .asciiz "\nOr G to terminate: "

showAllTest: .asciiz "\n\n\tA Show all test."
showUpNormalTest: .asciiz "\n\tB Show up normal test."
showTestInSpecificPeriod: .asciiz "\n\tC Show test in specific period."
orTerminateWithD: .asciiz "\nOr D to terminate: "

askForPatientID: .asciiz "\n\tEnter patient ID (7-digit integer): "
askForTestName: .asciiz "\n\tEnter test name (three char, case sensitive): "
askForTestYear: .asciiz "\n\tEnter test year (in format YYYY): "
askForTestMonth: .asciiz "\n\tEnter test month (in format MM): "
askForResult: .asciiz "\n\tEnter result (floating-point value): "
askForSecondResult: .asciiz "\n\tEnter second result (floating-point value): "
askToEnterFirstDate: .asciiz "\n\tEnter First Date (YYYY-MM):"
askToEnterSecondDate: .asciiz "\n\tEnter Second Date (YYYY-MM):"
addedSuccessfullyLabel: .asciiz "\nAdd this medical test successfully"
updatedSuccessfullyLabel: .asciiz "\nUpdated this medical test successfully"
changesOnDataNotSavedLabel: .asciiz "\nChanges on data not saved "
changesOnDataSavedSuccessfullyLabel: .asciiz "\nChanges on data saved Successfully"

askForMedicalTestName: .asciiz "\n\tEnter Medical Test Name: "
askToChooseTestToUpdate: .asciiz "\n\tChoose test to update from above test: "
askToChooseTestToDelete: .asciiz "\n\tChoose test to delete from above test: "

newLine: .asciiz "\n"
comma: .asciiz ","
equal: .asciiz "= "
maxMonth: .asciiz "13" 
multiplier: .float 100.0
buffer: .space 1  		# Space to read one character at a time
lineBuffer: .space 10  		# Buffer to store string for float
inputBuffer1: .space 8
inputBuffer2: .space 8
.align 4
inputBuffer: .space 8      	# Allocate space for 7 characters and a null terminator

# Array of labels for medical tests
testLabels:
    .asciiz "Hgb"
    .asciiz "BGT"
    .asciiz "LDL"
    .asciiz "BPT"

# Array of maximum normal range values
maxRanges:
    .float 17.2        # (Hgb)
    .float 99          # (BGT)
    .float 100         # (LDL)
    .float 120         # (BPT)

# Array of minimum normal range values
minRanges:
    .float 13.8        # (Hgb)
    .float 70          # (BGT)
    .float 0           # (LDL)
    .float 80          # (BPT)

.text

#**************************************************************************************#
#			       Read Data From file.	                	       #
#**************************************************************************************#

# Arguments:
#   $a0 - address of the string has file name
# Returns:
#   $S0 - address of the head for linked list
ReadFile:
	
    li $v0, 13			# Open the file for reading
    li $a1, 0
    syscall
    move $s2, $v0  		# File descriptor
    bgez $s2, Continue		# Check file open success
    j Exit

    Continue:
    	addi $sp, $sp, -4	
    	sw   $ra, 0($sp) 	# Store the return address at top of stack
    	
	li $t0, 12
    	lw $t5,testLabels($t0)
    	
    ReadLine:
    	beqz $v0, CloseReadFile
    	jal AddNewNode
    	move $s3,$v0
    	move $s5,$v0
    	li $t0, 20		# Number of byte remains to store at node before the float
    	li $t1, 44       	# Load immediate value 44 (comma) into $t1
    	li $t2, 32       	# Load immediate value 32 (space) into $t2
    	li $t3, 0		# Index for lineBuffer to store string for float
    	li $t4, 10         	# ASCII value for newline
    	li $t7, 1         	# Flag for two result for test 
    	
    ReadChar:
    	li $v0, 14         	# System call for reading from file
    	move $a0, $s2      	# Move file descriptor into $a0
    	la $a1, buffer     	# Load address of buffer into $a1
    	li $a2, 1      		# Move read size (1 byte) into $a2
    	syscall            	# Perform read syscall

    	beqz $v0, ProcessLine 	# If 0 bytes read (EOF), jump to end_read
   
    	lb $s4, buffer     		# Load the byte read into $s4
    	beq $s4, $t4, ProcessLine	# If (new line) byte read, jump to ProcessLine
    	blez $t0 , StoreFloat		# If store 20 byte at node go to store at lineBuffer
    	beq $s4, $t1, Increment		# If (comma) byte read, jump to Increment
    	beq $s4, $t2, ReadChar 	# If (space) byte read, get new char
    	
    	sb $s4, 0($s3) 	   		# Else store byte at the node
    	
    Increment:
    	addi $s3, $s3, 1   	# Increment node index
    	subi $t0, $t0, 1	# decrement number of byte remains to store at node
	j ReadChar
	
    StoreFloat:
    	beq $s4, $t1, ProcessLine	# If (comma) byte read, jump to Increment
	sb $s4, lineBuffer($t3)		# Store byte at lineBuffer
	addi $t3, $t3, 1		# Increment lineBuffer index
	j ReadChar
    	
     ProcessLine:
     	sb $0, lineBuffer($t3)		# Store byte at lineBuffer
	la $a0 , lineBuffer
	jal StringToFloat	# Convert lineBuffer to float value 
	swc1 $f0, 0($s3)	# Store the float at the node 
	addi $s3, $s3, 4   	# Increment node index
	li $t0,-1
	li $t4, 10         	# ASCII value for newline
	
	lw $t6,8($s5)
	bne $t5,$t6,ReadLine
	beqz $t7,ReadLine
	li $t7,0
	li $t3, 0		# Index for lineBuffer to store string for float
	j ReadChar
	
    CloseReadFile:	
    	li $v0, 16		# Close the file 
    	move $a0, $s2		# Move file descriptor to $a0 for closing
    	syscall
    	
    	lw   $ra, 0($sp)	# Load return address from stack
    	addi $sp, $sp, 4 	# Restore stack pointer
	jr $ra
	
	
#**************************************************************************************#
#				  Convert string to float	          	       #
#**************************************************************************************#

# Arguments:
#   $a0 - address of the string
# Returns:
#   $f0 - floating point result
StringToFloat:
    li $t0, 0          # Integer part accumulator
    li $t1, 0          # Fractional part accumulator
    li $t2, 1          # Multiplier for decimal places
    li $t3, 0          # Flag for fractional part

    IntLoop:
        lb $t4, 0($a0) 			# Load byte from string
        beq $t4, 46, FractionalPart 	# 46 is ASCII for '.'
        beq $t4, 0, ConvertToFloat      # End of string
        subi $t4, $t4, 48           	# Convert ASCII to integer ('0' -> 0, '9' -> 9)
        mul $t0, $t0, 10
        add $t0, $t0, $t4           	# Accumulate integer part
        addi $a0, $a0, 1            	# Move to next character
        b IntLoop

    FractionalPart:
        addi $a0, $a0, 1            # Skip over the decimal point
        li $t3, 1                   # Set fractional flag

    FracLoop:
        lb $t4, 0($a0)
        beq $t4, 0, ConvertToFloat  # End of string
        subi $t4, $t4, 48           # Convert ASCII to integer
        mul $t1, $t1, 10
        add $t1, $t1, $t4           # Accumulate fractional part
        mul $t2, $t2, 10            # Increase divisor for fractional part
        addi $a0, $a0, 1            # Move to next character
        b FracLoop

    ConvertToFloat:
        # Convert integer part
        mtc1 $t0, $f0               # Move integer part to float
        cvt.s.w $f0, $f0            # Convert to float

        # Convert fractional part if any
        beqz $t3, EndConversion     # Skip if no fractional part
        mtc1 $t1, $f1               # Move fractional part to float
        mtc1 $t2, $f2               # Move divisor to float
        cvt.s.w $f1, $f1            # Convert to float
        cvt.s.w $f2, $f2            # Convert to float
        div.s $f1, $f1, $f2         # Divide to get correct decimal
        add.s $f0, $f0, $f1         # Add fractional part to integer part

    EndConversion:
        jr $ra                     


#**************************************************************************************#
#			       Prints the menu options.	                	       #
#**************************************************************************************#

PrintMenu:

	la $a0, welcome				
	li $v0, 4				
	syscall					
	la $a0, addTest				
	syscall					
	la $a0, searchByPatient				
	syscall
	la $a0, searchByTest
	syscall
	la $a0, average
	syscall
	la $a0, update
	syscall
	la $a0, delete
	syscall
	la $a0, orTerminateWithG
	syscall
	jr $ra
		
#**************************************************************************************#
#			              Add new user.	                	       #
#**************************************************************************************#
										
AddNewUser:

    addi $sp, $sp, -4	
    sw   $ra, 0($sp) 	# Store the return address at top of stack
    jal AddNewNode
    move $s1,$v0
    move $t0,$v0
      
    EnterPatientID: 
    	move $t0,$s1
	la $a0, askForPatientID		# prompt user to enter PatientID	
	li $v0, 4			# syscall to printing string
	syscall					

    	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer      # Load address of the input buffer
    	li $a1, 8                 # Maximum number of characters to read
    	syscall

    	jal CheckValidPatientID
	beqz $v0,EnterPatientID
	
	li $t1, 0
	lw $t2, inputBuffer($t1)      # Load address of the input buffer
	sw $t2,0($s1)
	li $t1, 4
	lw $t2, inputBuffer($t1)
	sw $t2,4($s1)	
				
    EnterTestName:
    	
	la $a0, askForTestName			# prompt user to enter TestName	
	li $v0, 4				# syscall to printing string
	syscall					

	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 4                 # Maximum number of characters to read
    	syscall
    	li $t1, 0
    	
    	CompareLoopForTestName:
    	la $t2, testLabels($t1)
    	
    	# Call CompareStrings subroutine to compare input with current label
    	move $a0, $t2    	# Pass address of current label as first argument
    	la $a1, inputBuffer    	# Pass address of input string as second argument
    	jal CompareStrings
    
    	# Check if strings are equal
    	beqz $v0, MatchTestNameFound  		# If equal, jump to MatchFound
    	li $t5, 12       			# Number of byte for test labels
    	beq $t1, $t5, EnterTestName   		# If index equals number of labels, no match found

    	# Increment counter for next iteration
    	addi $t1, $t1, 4
    	j CompareLoopForTestName
    	
    	MatchTestNameFound:
    	la $t1,inputBuffer
    	lw $s2,0($t1)
    	sw $s2,8($s1)				

    EnterTestYear:
    
    	move $t0,$s1
    	addi $t0,$t0,12
    	la $a0, askForTestYear			# prompt user to enter TestName	
	li $v0, 4				# syscall to printing string
	syscall					

	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 5                 # Maximum number of characters to read
    	syscall
   
    	li $t1, 0      						# Counter for number of digit for Year
    	li $t3, 48                # ASCII value of '0'
    	li $t4, 57                # ASCII value of '9'
	LoopToCountNumberOfDigitForYear:
    	lb $t2, inputBuffer($t1)  				# Load a byte from memory into $t2
    	sb $t2, 0($t0)          			
    	beq $t2, 0, EndLoopToCountNumberOfDigitForYear    	# If the byte is null (end of string), exit loop
    	blt $t2, $t3, EndLoopToCountNumberOfDigitForYear 	# If character is not a digit
    	bgt $t2, $t4, EndLoopToCountNumberOfDigitForYear	# If character is not a digit
    	addi $t0, $t0, 1          				# Increment address to point to the next character
    	addi $t1, $t1, 1          				# Increment address to point to the next character
    	j LoopToCountNumberOfDigitForYear			# Repeat loop

	EndLoopToCountNumberOfDigitForYear:
    	# Check if input is exactly 4 characters long
    	li $t2, 4
    	bne $t1, $t2, EnterTestYear
    	
    	li $t1 , 45
    	sb $t1 , 0($t0)
    	
    EnterTestMonth:
    	move $t0,$s1
    	addi $t0,$t0,17
    	la $a0, askForTestMonth			# prompt user to enter TestName	
	li $v0, 4				# syscall to printing string
	syscall					

	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 3                 # Maximum number of characters to read
    	syscall
    	
    	li $t1, 0      						# Counter for number of digit for Year
    	li $t3, 48                # ASCII value of '0'
    	li $t4, 57                # ASCII value of '9'
	LoopToCountNumberOfDigitForMonth:
    	lb $t2, inputBuffer($t1)  				# Load a byte from memory into $t2
    	sb $t2, 0($t0)          			
    	beq $t2, 0, EndLoopToCountNumberOfDigitForMonth    	# If the byte is null (end of string), exit loop
    	blt $t2, $t3, EndLoopToCountNumberOfDigitForMonth	# If character is not a digit
    	bgt $t2, $t4, EndLoopToCountNumberOfDigitForMonth	# If character is not a digit
    	addi $t0, $t0, 1          				# Increment address to point to the next character
    	addi $t1, $t1, 1          				# Increment address to point to the next character
    	j LoopToCountNumberOfDigitForMonth			# Repeat loop

	EndLoopToCountNumberOfDigitForMonth:
    	# Check if input is exactly 2 characters long
    	li $t2, 2
    	bne $t1, $t2, EnterTestMonth
    	
    	la $a0, inputBuffer
    	la $a1, maxMonth
    	jal CompareStrings
    	bgez $v0 ,EnterTestMonth
    	
    	addi $t0, $t0, 1
  
    EnterFirstResult:  	
	la $a0, askForResult       # Load address of string askForResult
	li $v0, 52                 # syscall to read Float
	syscall
	bnez $a1,EnterFirstResult
    	swc1 $f0, 0($t0)	
    	
    	li $t6, 12				# Load test label index
    	lw $t7,testLabels($t6)			# Load test label from predefined labels array
    	bne $s2,$t7,AddedTestSuccessfully	# Compare test label with current test name
    
    EnterSecondResult:	
    	la $a0, askForSecondResult      # Load address of string askForResult
	li $v0, 52                   	# syscall to read Float
	syscall
    	bnez $a1,EnterSecondResult
    	swc1 $f0, 4($t0)
    	
    AddedTestSuccessfully:
	la $a0, addedSuccessfullyLabel		# added new medical test successfully
	li $v0, 4				# syscall to printing string
	syscall	
	
	move $a0,$s1
	jal printNode				
	
	lw   $ra, 0($sp)	# Load return address from stack
    	addi $sp, $sp, 4 	# Restore stack pointer
	jr $ra				


#**************************************************************************************#
#			           Compare two strings.	                	       #
#**************************************************************************************#

# Arguments:
#   $a0: Address of the first string
#   $a1: Address of the second string
# Returns:
#   $v0 = -1 if $a0 < $a1
#   $v0 = 0  if $a0 = $a1
#   $v0 = 1  if $a0 > $a1
CompareStrings:

    lb $t3, 0($a0)         # Load byte from str1
    lb $t4, 0($a1)         # Load byte from str2

    # Check if both strings have ended
    beqz $t3, CheckEndForSecondString
    beqz $t4, SecondStringEnded
    
    # Compare characters
    bgt $t3, $t4, FirstStringGreater
    blt $t3, $t4, FirstStringSmaller

    # Increment counters
    addi $a0, $a0, 1       # Move to next character in str1
    addi $a1, $a1, 1       # Move to next character in str2
    j CompareStrings       # Repeat loop

    FirstStringGreater:
    	li $v0, 1              # Set return value to 1 (first string greater)
    	j EndCompare

    FirstStringSmaller:
    	li $v0, -1             # Set return value to -1 (first string smaller)
    	j EndCompare

    CheckEndForSecondString:
    	# Check if only the second string has ended
    	beqz $t4, StringsAreEqual

    SecondStringEnded:
    	# Check if both strings have ended
    	beqz $t3, StringsAreEqual

    	li $v0, 1              # Set return value to 1 (first string greater)
    	j EndCompare

    	StringsAreEqual:
    	li $v0, 0              # Set return value to 0 (strings equal)
    	j EndCompare

    	EndCompare:
    	jr $ra


#**************************************************************************************#
#			      print menu for serch by patient.	                       #
#**************************************************************************************#

SerchByPatientID:

    la $a0,askForPatientID 
    li $v0,4
    syscall
    li $v0, 8                 # System call for read_str
    la $a0, inputBuffer       # Load address of the input buffer
    li $a1, 8                 # Maximum number of characters to read
    syscall
    jal CheckValidPatientID
    beqz $v0,SerchByPatientID
    la $a0, inputBuffer       # Load address of the input buffer
    move $t8,$s0
    CheckIfPatientIDExist:
        beqz $t8,MenuLoop    
        move $a1,$t8
       	jal CompareStrings
       	beqz $v0,SerchByPatientIDMenu
       	lw,$t8,28($t8)
       	la $a0, inputBuffer       # Load address of the input buffer
       	b CheckIfPatientIDExist
        
    SerchByPatientIDMenu:

    	li $v0, 4
    	la $a0, showAllTest								
    	syscall					
    	la $a0, showUpNormalTest				
    	syscall					
    	la $a0, showTestInSpecificPeriod				
    	syscall
    	la $a0, orTerminateWithD				
    	syscall
	
    	li $v0, 12	# syscall to  get data from user		
    	syscall
	
    	# Check for valid range ('A' = 65 and 'D' = 68)
    	slti $t1, $v0, 65        			# $t1 = 1 if $v0 < 'A'
    	slti $t2, $v0, 69        			# $t2 = 1 if $v0 < 'E'
    	subu $t3, $t2, $t1       			# $t3 = 1 if 'A' <= $v0 < 'E', else 0
    	beq $t3, $zero, SerchByPatientIDMenu	#Repeat loop if not valid input

    	subu $t0, $v0, 65        	# Convert 'A'-'D' to 0-3
    	sll $t0, $t0, 2          	# Multiply index by 4 to convert to word offset

    	la $t1, optionTableForSerchByPatientID     	# Load base address of the option table
    	addu $t1, $t1, $t0       			# Get the address of the function to call
    	lw $t1, 0($t1)           			# Load the function address
    	jalr $t1                 			# Jump and link to the function
    	j MenuLoop        				# Return to the main loop
 
 
ShowAllTest:
    addi $sp, $sp, -4	
    sw   $ra, 0($sp) 	# Store the return address at top of stack
    la $a0, inputBuffer
    move $a1, $s0
    la $t8,0($s0)
    li $t9,0
    
    GoToCheckTheID:
    	jal CompareStrings
    	beqz $v0,ShowThisNodeForPatientID
    	b GetNextNodeToShowAllTeseForPatientID

    ShowThisNodeForPatientID:
    	li $v0, 4           # System call for print string
    	la $a0, newLine     # Load address for new line
    	syscall
        addi $t9,$t9,1
        li $v0, 1           # System call for print integer
    	move $a0, $t9       # Move the integer to $a0
    	syscall
    	
    	la $a0,0($t8)
    	jal printNode
    	
    	
    GetNextNodeToShowAllTeseForPatientID:
    	lw $t8,28($t8)
    	la $a0, inputBuffer
    	move $a1, $t8
 	beqz $t8,EndShowAllTestForPatientID
    	b GoToCheckTheID
    	
   EndShowAllTestForPatientID:
   	lw   $ra, 0($sp)	# Load return address from stack
    	addi $sp, $sp, 4 	# Restore stack pointer
   	jr $ra
  
ShowAllUnormalTest:
       la $a0, inputBuffer
    move $a1, $s0
    move $t8, $s0

      CheckTheID:
       li $t9,0
       jal CompareStrings
       beqz $v0 FindUnormalTestForThisPatient
       b GetNextNodeToShowUnormalTeseForPatientID
       FindUnormalTestForThisPatient:
         la $t0,($t8)

         lw $s5,8($t0)
         lw $s6,testLabels($t9)
         addiu $t9,$t9,4
         bne $s6,$s5,FindUnormalTestForThisPatient
         subiu $t9,$t9,4
         lw $a0,testLabels+12
         beq $s6,$a0,ShowUnormalTestWithTWOResults
         b ShowUnormalTestWithOneResult


         ShowUnormalTestWithOneResult:
        lwc1 $f12,20($t0) 
        lwc1 $f11,maxRanges($t9) 
        c.lt.s $f11,$f12
        bc1t show
        lwc1 $f11,minRanges($t9) 
        c.lt.s $f12,$f11
        bc1t show
        b GetNextNodeToShowUnormalTeseForPatientID
        show:

        li $v0, 4           # System call for print string
            la $a0, newLine     # Load address for new line
            syscall

        la $a0,($t0)
        jal printNode
        b GetNextNodeToShowUnormalTeseForPatientID


       ShowUnormalTestWithTWOResults:
        lwc1 $f12,20($t0) 
        lwc1 $f11,maxRanges($t9) 
        c.lt.s $f11,$f12
        bc1t show
        lwc1 $f12,24($t0) 
        lwc1 $f11,minRanges($t9) 
        c.lt.s $f11,$f12
        bc1t show
        b GetNextNodeToShowUnormalTeseForPatientID



    GetNextNodeToShowUnormalTeseForPatientID:
    lw $t8,28($t8)
    move $a1,$t8


    beqz $t8,MenuLoop
    la $a0,inputBuffer
    b CheckTheID
    jr $ra
   	 	  

SpesificPeriod:
	la $a0,askToEnterFirstDate 
	li $v0,4
	syscall
	li $v0, 8                 # System call for read_str
        la $a0, inputBuffer1      # Load address of the input buffer
        li $a1, 8                 # Maximum number of characters to read
        syscall
        li $t9,0 
        la $a0,askToEnterSecondDate 
	li $v0,4
	syscall
	
	li $v0, 8                 # System call for read_str
        la $a0, inputBuffer2      # Load address of the input buffer
        li $a1, 8                 # Maximum number of characters to read
        syscall
        li $t9,0
        la $a0, inputBuffer1 
        jal CheckDateValidity
        li $t9,0
        la $a0, inputBuffer2 
        jal CheckDateValidity 
        la $a0, inputBuffer1 
        la $a1, inputBuffer2 
        jal CompareStrings
	 bgtz $v0 SpesificPeriod
  
        la $a0, inputBuffer
        move $a1, $s0
       
	move $t8, $s0
	
	CompareId:
	 
	   jal CompareStrings
	   beqz $v0 FindTestForThisPatientDuringPeriod
	   b GetNextNodeToShowTestForPatientIDDuringPeriod
	   FindTestForThisPatientDuringPeriod:
	     la $t0,($t8)
		
	     la $a0,12($t0)
	     la $a1, inputBuffer1
	     jal CompareStrings
	   bltz $v0 GetNextNodeToShowTestForPatientIDDuringPeriod
	   la $a0,12($t0)
	     la $a1, inputBuffer2
	     jal CompareStrings
	   bgtz $v0 GetNextNodeToShowTestForPatientIDDuringPeriod
	   	        
		li $v0, 4           # System call for print string
        	la $a0, newLine     # Load address for new line
        	syscall
        	
		la $a0,($t0)	
		jal printNode
		
	GetNextNodeToShowTestForPatientIDDuringPeriod:	
	lw $t8,28($t8)
	move $a1,$t8
	beqz $t8,MenuLoop
	la $a0,inputBuffer
	b CompareId
	
    CheckDateValidity:
        addiu $t9,$t9,1
        beq $t9,6,CheckMonth
        beq $t9,5 CheckSlash
        lb $a1,0($a0)
        beqz $a1,CheckDateLength
        blt $a1,48,SpesificPeriod
    	bgt $a1,57,SpesificPeriod 
    	addiu $a0,$a0,1
    	b CheckDateValidity
        CheckMonth:
        lb $a1,0($a0)
        beq $a1,49,CheckSecondDigit
        bne $a1,48,SpesificPeriod
    	 
    	addiu $a0,$a0,1
    	lb $a1,0($a0)
        blt $a1,49,SpesificPeriod
    	bgt $a1,57,SpesificPeriod
        addiu $t9,$t9,1    	
    	addiu $a0,$a0,1
    
    	b CheckDateValidity
    	CheckSecondDigit:
    	addiu $a0,$a0,1
    	lb $a1,0($a0)
        blt $a1,48,SpesificPeriod
    	bgt $a1,50,SpesificPeriod 
        addiu $t9,$t9,1    	
    	addiu $a0,$a0,1
    	b CheckDateValidity
    	
    	CheckSlash:
    	lb $a1,0($a0)
        bne $a1,45,SpesificPeriod
        addiu $a0,$a0,1
    	b CheckDateValidity
    
    	CheckDateLength:
    	 bne $t9,8,SpesificPeriod
    	 jr $ra   	 	   
    	 	   
#**************************************************************************************#
#			      	  Find Unnormal tests	                               #
#**************************************************************************************# 
  
UnNormalTests:
    
    la $a0,askForMedicalTestName 
    li $v0,4
    syscall
    li $v0, 8                 # System call for read_str
    la $a0, inputBuffer      # Load address of the input buffer
    li $a1, 4                 # Maximum number of characters to read
    syscall
    li $t9,0 
  
        LoopForTestName:
        la $t8, testLabels($t9)
        
        # Call CompareStrings subroutine to compare input with current label
        move $a1, $t8        # Pass address of current label as first argument
        la $a0, inputBuffer        # Pass address of input string as second argument
        jal CompareStrings
    
        # Check if strings are equal
        beqz $v0, TestNameFound      # If equal, jump to MatchFound
        li $t5, 12                   # Number of byte for test labels
        beq $t9, $t5, UnNormalTests           # If index equals number of labels, no match found

        # Increment counter for next iteration
        addi $t9, $t9, 4
        j LoopForTestName
        
        TestNameFound:  
     	move $t8, $s0    
        li $t9,0 
        la $a0, inputBuffer      # Load address of the input buffer
    
	FindMedicalTest:
		la $a1,testLabels($t9)
		jal CompareStrings
		addiu $t9,$t9,4
		la $a0, inputBuffer
		bnez $v0 FindMedicalTest
		subiu $t9,$t9,4
		la $a1, 8($s0)
	
	
	
       CheckEachTestMedicalType:
        	jal CompareStrings
		beqz $v0 FindUnNormalTest
		b GetNextNodeToShowUnormalTeseForMedicalTests
        
       
        
		FindUnNormalTest:
			la $t0,0($t8)

			lw $a1,testLabels+12
			lw $s6,8($t0)
			beq $a1,$s6,ShowUNormalTestWithTwoResults
			b ShowUNormalTestWithOneResults
	
			ShowUNormalTestWithOneResults:
				la $a0,($t0)
				lwc1 $f12,20($t0) 
				lwc1 $f11,maxRanges($t9) 
				c.lt.s $f11,$f12
				bc1t PirntInfo
				lwc1 $f11,minRanges($t9) 
				c.lt.s $f12,$f11
				bc1t PirntInfo
				b GetNextNodeToShowUnormalTeseForMedicalTests
	
	
	
			ShowUNormalTestWithTwoResults:
				la $a0,($t0)
				lwc1 $f12,20($t0) 
				lwc1 $f11,maxRanges($t9) 
				c.lt.s $f11,$f12
				bc1t PirntInfo
				lwc1 $f12,24($t0) 
				lwc1 $f11,minRanges($t9) 
				c.lt.s $f11,$f12
				bc1t PirntInfo
				b GetNextNodeToShowUnormalTeseForMedicalTests
				PirntInfo:
				   move $a2,$a0
				   li $v0, 4           # System call for print string
        			   la $a0, newLine     # Load address for new line
        			   syscall		
        			   move $a0,$a2
				   jal printNode
				   b GetNextNodeToShowUnormalTeseForMedicalTests
	
	GetNextNodeToShowUnormalTeseForMedicalTests:	
	lw $t8,28($t8)
	move $a1,$t8
	
	beqz $t8,MenuLoop
	la $a0,inputBuffer
	la $a1,8($a1)
	b CheckEachTestMedicalType
	jr $ra

#**************************************************************************************#
#			      		Average  	                               #
#**************************************************************************************#	
	   	 	    	 	   	 	  
Average:
 li $t9,0
 la $a0,testLabels($t9)


li $t0, 0x3f800000
mtc1 $t0, $f7
DecalreVeriablesForCalculating:
     la $a1,8($s0)
     move $t8,$s0
     li $t0, 0 
     mtc1 $t0, $f4
     mtc1 $t0, $f5
    mtc1 $t0, $f6

 ComapreTestWithANodeInTheLinkedList:

     jal CompareStrings
    beqz $v0 AddTheFirstResult
    b NextNodeToCheck



    AddTheFirstResult:

    add.s $f6,$f6,$f7
    lwc1 $f2, 9($a1)
    add.s $f4,$f4,$f2
    beq $t9,12,AddTheSecondResult
    b NextNodeToCheck
    AddTheSecondResult:

    lwc1 $f2, 13($a1)
    add.s $f5,$f5,$f2
    b NextNodeToCheck

    NextNodeToCheck:
    lw $t8,28($t8)

    beqz $t8,PrintFirstResult
    la $a0,testLabels($t9)
    la $a1,8($t8)
    b ComapreTestWithANodeInTheLinkedList

    PrintFirstResult:

    li $v0,4
    la $a0, newLine     # Load address for new line
        syscall
        la $a0,testLabels($t9)

    syscall
    la $a0, equal     # Load address for new line
        syscall

    c.lt.s $f6,$f7
    bc1t IfAverageIsZero
    div.s $f12,$f4,$f6
    li $v0,2
    syscall
    beq $t9,12,PrintSecondResult
    addiu $t9,$t9,4
    beq $t9,16,MenuLoop
    la $a0,testLabels($t9)
    b DecalreVeriablesForCalculating

    PrintSecondResult:
    li $v0,4
    la $a0, comma     # Load address for new line
        syscall
    div.s $f12,$f5,$f6
    li $v0,2
    syscall
    addiu $t9,$t9,4
    beq $t9,16,MenuLoop
    la $a0,testLabels($t9)
    b DecalreVeriablesForCalculating




    IfAverageIsZero:
    li $a0,0
    li $v0,1
    syscall
    addiu $t9,$t9,4
    beq $t9,16,MenuLoop
    la $a0,testLabels($t9)
    b DecalreVeriablesForCalculating

   	 	    	 	   	 	  
#**************************************************************************************#
#			      		Update Result	                               #
#**************************************************************************************#

UpdateResult:
    addi $sp, $sp, -4	
    sw   $ra, 0($sp) 	# Store the return address at top of stack
    
    EnterPatientIDToUpdateTest:
    	la $a0,askForPatientID 
    	li $v0,4
    	syscall
    	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 8                 # Maximum number of characters to read
    	syscall
    	jal CheckValidPatientID
    	beqz $v0,EnterPatientIDToUpdateTest
    	la $a0, inputBuffer       # Load address of the input buffer
    	move $t8,$s0
    	
    CheckIfPatientIDExistToUpdate:
        beqz $t8,MenuLoop    
        move $a1,$t8
       	jal CompareStrings
       	beqz $v0,ShowAllTeseToUpdate
       	lw,$t8,28($t8)
       	la $a0, inputBuffer       # Load address of the input buffer
       	b CheckIfPatientIDExistToUpdate
       	
    ShowAllTeseToUpdate:     	
    	jal ShowAllTest	
    
    	la $a0,askToChooseTestToUpdate 
    	li $v0,4
    	syscall
   	li $v0, 5           	# System call for read integer
    	syscall   
    	move $t1, $v0
    
    	la $a0, inputBuffer
    	move $a1,$s0
    	move $t8,$s0
    	li $t2,0
    	li $t0,0
    
    GoToCheckTheIDForUpdateNode:  	
    	jal CompareStrings
    	beqz $v0,CheckIfThisNodeSelectedToUpdate
    	b GetNextNodeToFindSelectedNodeToUpdate

    CheckIfThisNodeSelectedToUpdate:
    	addi $t2,$t2,1			# increment $t2 (the number of test found for choosen user)
	move $a1,$t8
    	beq $t2,$t1, GoToUpdateNode
    	  	
    GetNextNodeToFindSelectedNodeToUpdate:
    	lw $t8,28($t8)
    	la $a0,inputBuffer
    	move $a1,$t8
    	lw $s3,28($t8)
    	bnez $s3 , GoToCheckTheIDForUpdateNode
    	li $t0,1
    	b GoToCheckTheIDForUpdateNode
    
    GoToUpdateNode:
    # address of the node will be at $a1
    	move $s1,$a1
    	lw $s2,8($s1)
    	
    UpdateTestYear:
    
    	move $t0,$s1
    	addi $t0,$t0,12
    	la $a0, askForTestYear			# prompt user to enter TestName	
	li $v0, 4				# syscall to printing string
	syscall					

	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 5                 # Maximum number of characters to read
    	syscall
   
    	li $t1, 0      						# Counter for number of digit for Year
    	li $t3, 48                # ASCII value of '0'
    	li $t4, 57                # ASCII value of '9'
	LoopToCountNumberOfDigitForYearInUpdate:
    	lb $t2, inputBuffer($t1)  				# Load a byte from memory into $t2
    	sb $t2, 0($t0)          			
    	beq $t2, 0, EndLoopToCountNumberOfDigitForYearInUpdate    	# If the byte is null (end of string), exit loop
    	blt $t2, $t3, EndLoopToCountNumberOfDigitForYearInUpdate 	# If character is not a digit
    	bgt $t2, $t4, EndLoopToCountNumberOfDigitForYearInUpdate	# If character is not a digit
    	addi $t0, $t0, 1          					# Increment address to point to the next character
    	addi $t1, $t1, 1          					# Increment address to point to the next character
    	j LoopToCountNumberOfDigitForYearInUpdate			# Repeat loop

	EndLoopToCountNumberOfDigitForYearInUpdate:
    	# Check if input is exactly 4 characters long
    	li $t2, 4
    	bne $t1, $t2, UpdateTestYear
    	
    	li $t1 , 45
    	sb $t1 , 0($t0)
    	
    UpdateTestMonth:
    	move $t0,$s1
    	addi $t0,$t0,17
    	la $a0, askForTestMonth			# prompt user to enter TestName	
	li $v0, 4				# syscall to printing string
	syscall					

	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 3                 # Maximum number of characters to read
    	syscall
    	
    	li $t1, 0      						# Counter for number of digit for Year
    	li $t3, 48                # ASCII value of '0'
    	li $t4, 57                # ASCII value of '9'
	LoopToCountNumberOfDigitForMonthInUpdate:
    	lb $t2, inputBuffer($t1)  				# Load a byte from memory into $t2
    	sb $t2, 0($t0)          			
    	beq $t2, 0, EndLoopToCountNumberOfDigitForMonthInUpdate    	# If the byte is null (end of string), exit loop
    	blt $t2, $t3, EndLoopToCountNumberOfDigitForMonthInUpdate	# If character is not a digit
    	bgt $t2, $t4, EndLoopToCountNumberOfDigitForMonthInUpdate	# If character is not a digit
    	addi $t0, $t0, 1          					# Increment address to point to the next character
    	addi $t1, $t1, 1          					# Increment address to point to the next character
    	j LoopToCountNumberOfDigitForMonthInUpdate			# Repeat loop

	EndLoopToCountNumberOfDigitForMonthInUpdate:
    	# Check if input is exactly 2 characters long
    	li $t2, 2
    	bne $t1, $t2, UpdateTestMonth
    	
    	la $a0, inputBuffer
    	la $a1, maxMonth
    	jal CompareStrings
    	bgez $v0 ,UpdateTestMonth
    	
    	addi $t0, $t0, 1
    	
    EnterFirstResultToUpdate:
	la $a0, askForResult       # Load address of string askForResult
	li $v0, 52                  # syscall to read float 
	syscall
	bnez $a1,EnterFirstResultToUpdate
    	swc1 $f0, 0($t0)	
    	
    	li $t6, 12				# Load test label index
    	lw $t7,testLabels($t6)			# Load test label from predefined labels array
    	bne $s2,$t7,UpdatedTestSuccessfully	# Compare test label with current test name
    	
    EnterSecondResultToUpdate:	
    	la $a0, askForSecondResult      # Load address of string askForResult
	li $v0, 52                  	# syscall to print string
	syscall
	bnez $a1,EnterSecondResultToUpdate
    	swc1 $f0, 4($t0)
    	
    UpdatedTestSuccessfully:
	la $a0, updatedSuccessfullyLabel		# added new medical test successfully
	li $v0, 4				# syscall to printing string
	syscall	
	
	move $a0,$s1
	jal printNode	
    
    ExitUpdateNode:
    	lw   $ra, 0($sp)	# Load return address from stack
    	addi $sp, $sp, 4 	# Restore stack pointer
    	jr $ra
    
#**************************************************************************************#
#			      	     Delete Test	                               #
#**************************************************************************************#
    
DeleteTest:
    addi $sp, $sp, -4	
    sw   $ra, 0($sp) 	# Store the return address at top of stack
    
    EnterPatientIDToDeleteTest:
    	la $a0,askForPatientID 
    	li $v0,4
    	syscall
    	li $v0, 8                 # System call for read_str
    	la $a0, inputBuffer       # Load address of the input buffer
    	li $a1, 8                 # Maximum number of characters to read
    	syscall
    	jal CheckValidPatientID
    	beqz $v0,EnterPatientIDToDeleteTest
    	la $a0, inputBuffer       # Load address of the input buffer
    	move $t8,$s0
    	
  CheckIfPatientIDExistToDelete:
        beqz $t8,MenuLoop    
        move $a1,$t8
       	jal CompareStrings
       	beqz $v0,ShowAllTeseToDelete
       	lw,$t8,28($t8)
       	la $a0, inputBuffer       # Load address of the input buffer
       	b CheckIfPatientIDExistToDelete
       	
  ShowAllTeseToDelete:     	
       	jal ShowAllTest
       	
    	la $a0,askToChooseTestToDelete 
    	li $v0,4
    	syscall
    	li $v0, 5           	# System call for read integer
    	syscall
    	move $t1, $v0		# Number of test to delete
    
    	la $a0, inputBuffer
    	move $a1,$s0
    	move $t8,$s0
    	li $t2,0		# counter to find number of test to delete
    	li $t0,0
    	
    GoToCheckTheIDForDeleteNode:  	
    	jal CompareStrings
    	beqz $v0,CheckIfThisNodeSelectedToDelete
    	bnez $t0, ExitDeleteNode
    	b GetNextNodeToFindSelectedNodeToDelete

    CheckIfThisNodeSelectedToDelete:
    	addi $t2,$t2,1			# increment $t2 (the number of test found for choosen user)
	move $a1,$t8
	move $a2,$s4
    	beq $t2,$t1, GoToDeleteNode
    	  	
    GetNextNodeToFindSelectedNodeToDelete:
    	move $s4,$t8
    	lw $t8,28($t8)
    	la $a0,inputBuffer
    	move $a1,$t8
    	lw $s3,28($t8)
    	bnez $s3 , GoToCheckTheIDForDeleteNode
    	li $t0,1
    	b GoToCheckTheIDForDeleteNode
    
    GoToDeleteNode:
    	jal deleteNode
    
    ExitDeleteNode:
    	lw   $ra, 0($sp)	# Load return address from stack
    	addi $sp, $sp,4 	# Restore stack pointer
    	jr $ra
 
#**************************************************************************************#
#			          Check Valid Patient ID	                       #
#**************************************************************************************#		  	 	   	 	   	 	   	 	  

# Arguments:
#   $a0: Address of the input
# Returns:
#   $v0 = 1 if the input valid
#   $v0 = 0 if the input invalid
CheckValidPatientID:

    li $t4,0      # Load byte from str
    GetNewByteFromPatientID:
    addiu $t4,$t4,1
    lb $t3, 0($a0)
    blt $t4,8,CheckIftheByteIsANumber
    beqz $t3,CheckLengthForPatientID

    CheckIftheByteIsANumber:
    	blt $t3,48,ThePatientIDIsInvalid
    	bgt $t3,57,ThePatientIDIsInvalid 
    	addiu $a0,$a0,1
    	b GetNewByteFromPatientID

    CheckLengthForPatientID:
    	bne $t4,8,ThePatientIDIsInvalid
    	li $v0,1
    	jr $ra
    
    ThePatientIDIsInvalid:
    	li $v0,0
    	jr $ra	
     	  		  	 	   	 	   	 	   	 	  
#**************************************************************************************#
#			       write data at file and exit	                       #
#**************************************************************************************#

# Arguments:
#   $a0 - address of the string has file name
WriteDataAndExit:

    li $t1, 12
    lw $t9,testLabels($t1)		# $t0 has "Hbg" the test has two results
    
    li $v0, 13		# Open the file 
    la $a0, filename    # Load address of filename
    li $a1, 1
    li $a2, 0
    syscall
    move $s2, $v0  		# File descriptor
    bgez $s2, GoToWrite		# Check file open success
    j ChangesOnDataNotSaved

    
    GoToWrite:
        
	li $v0, 15
	move $a0,$s2  		
    	move $a1, $s0    
    	li $a2, 7
    	syscall
    	StoreComma
    	
    	addi $s0,$s0,8
    	lw $t8,0($s0)
    	li $v0, 15
    	move $a1, $s0
    	li $a2, 3
    	syscall
    	StoreComma
    	
    	addi $s0,$s0,4
    	li $v0, 15
    	move $a1, $s0
    	li $a2, 7
    	syscall
    	StoreComma
    	
    	addi $s0,$s0,8
    	
    	l.s $f12, 0($s0)
    	la $a1, lineBuffer
    	jal FloatToString
    	li $v0, 15
    	la $a1, lineBuffer
    	move $a2, $v1
    	syscall
    	addi $s0,$s0,4
    	
    	bne $t9,$t8,FindNextNodeToWrite
    	
    	StoreComma
    	l.s $f12, 0($s0)
    	la $a1, lineBuffer
    	jal FloatToString
    	li $v0, 15
    	la $a1, lineBuffer
    	move $a2, $v1
    	syscall
    	
    FindNextNodeToWrite:
    	lw $s0,4($s0)	
	beqz $s0,ChangesOnDataSavedSuccessfully
	li $v0, 15
    	move $a0,$s2 		
    	la $a1, newLine   
    	li $a2, 1
    	syscall
    	j GoToWrite
    	
    ChangesOnDataSavedSuccessfully:
    	li $v0, 16		# Close the file 
    	move $a0, $s2		# Move file descriptor to $a0 for closing
    	syscall
    	la $a0, changesOnDataSavedSuccessfullyLabel     # Load address of string askForResult
	li $v0, 4                  			# syscall to print string
	syscall
	j Exit
    
    ChangesOnDataNotSaved:
    	la $a0, changesOnDataNotSavedLabel      # Load address of string askForResult
	li $v0, 4                  		# syscall to print string
	syscall
	j Exit


# Convert float to string
# Arguments:
# $f12 - float value to convert
# $a1 - address of buffer to store the string
# Returns:
# $v1 = the length of string store at buffer
FloatToString:
    cvt.w.s $f0, $f12   	# Convert float in $f12 to integer in $f0
    cvt.s.w $f2,$f0
    sub.s $f1,$f12 ,$f2 
    lwc1 $f2, multiplier
    mul.s $f1, $f2, $f1  	# Subtract the truncated float from the original float to get the fraction part
    mfc1 $t0, $f0       	# Move the integer to $t0
    li $v1,0
    
    # Convert integer to string 
    li $t2, 10          # Prepare divisor
    move $t3, $a1       # Start of digits

    loopToConvertIntToString:
    	div $t0, $t2
    	mflo $t0
    	mfhi $t1            	# Remainder (digit)
    	addiu $t1, $t1, '0' 	# Convert to ASCII
    	sb $t1, 0($t3)
    	addiu $t3, $t3, 1
    	addiu $v1, $v1, 1
    	bnez $t0, loopToConvertIntToString

     	move $t4,$t3
    	# Reverse the string
    	addiu $t3, $t3, -1  # Set $t3 to last valid character
    reverseResult:
    	lbu $t1, 0($a1)     # Load byte from start
    	lbu $t2, 0($t3)     # Load byte from end
    	sb $t2, 0($a1)      # Store end at start
    	sb $t1, 0($t3)      # Store start at end
    	addiu $a1, $a1, 1
    	addiu $t3, $t3, -1
    	blt $a1, $t3, reverseResult

    	li $t1, 46
    	sb $t1, 0($t4)	
    	addiu $v1, $v1, 1	
    	
    	cvt.w.s $f1, $f1
	mfc1 $t0, $f1       	# Move the fraction to $t0
	li $t2, 10
	div $t0, $t2          	# Prepare divisor
	mflo $t0
    	mfhi $t1
    	addiu $t0, $t0, '0' 	# Convert to ASCII
    	addiu $t1, $t1, '0' 	# Convert to ASCII
    	sb $t0, lineBuffer($v1)
    	addiu $v1, $v1, 1
    	sb $t1, lineBuffer($v1)
    	addiu $v1, $v1, 1
    	
    	jr $ra              # Return to caller
    	
