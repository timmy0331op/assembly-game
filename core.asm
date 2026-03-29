#initial
lw $s1, 0($s0) #ambulance localtion
lw $s2, 4($s0) #grandma localtion
lw $s3, 8($s0) #injured1 localtion
lw $s4, 12($s0) #injured2 localtion
lw $s5, 16($s0) #injured3 localtion
lw $s6, 20($s0) #num of injured in ambulance
lw $s7, 24($s0) #num of injured in hospital
lw $t9, 28($s0) #rounds

grandma_loop:
    sub $s1, $t0, $zero
    andi $t2, $t0, 1
#enter or re-enter the direction
    jal	move_direction				# jump to target and save position to $ra
    
#check traffic light
    beq $t8, $zero ambulance_loop #if grandma don't move, skip to next player
    beq $t2, $zero, 16
    subi $t1, $t8, 1
    beq $t1, $zero, -20
    subi $t1, $t8, -1
    beq $t1, $zero, -28
    bne $t2, $zero, 16
    subi $t1, $t8, 16
    beq $t1, $zero, -40
    subi $t1, $t8, -16
    beq $t1, $zero, -48
    add $t0, $t8, $s2
    ori $t1, $t0, 0b01110111 #boundary test
    subi $t1, $t1, 0b01110111
    bne $t1, $zero, -60
    beq $t0, $s1, -64
    beq $t0, $s3, -68
    beq $t0, $s4, -72
    beq $t0, $s5, -76
    sub $s2, $t0, $zero
    j ambulance_loop # jump to target

ambulance_loop:
    addi $t2, $zero, 1
#enter or re-enter the direction
    j move_direction #call move_direction to get the offset
#
    add $t0, $s1, $t8
    ori $t1, $t9, 0b01110111 #boundary test
    subi $t1, $t1, 0b01110111
    bne $t1, $zero, -16
    beq $t0, $s2, -24
    bne $s6, $zero, 40
    bne $t0, $s3, 8
    addi $s6, $s6, 1
    ori $s3, $s3, 0b11111111
    bne $t0, $s4, 8
    addi $s6, $s6, 1
    ori $s4, $s4, 0b11111111
    bne $t0, $s5, 8
    addi $s6, $s6, 1
    ori $s5, $s5, 0b11111111
    addi $t9, $t9, 1
    j grandma_loop	# jump to target
    ori $t1, $t0, 17 #check if in the hospital area
    subi $t1, $t1, 17
    bne $t1, $zero, -16
    subi $s6, $s6, 1
    addi $s7, $s7, 1
    subi $t3, $s7 3
    beq $t3, $zero,  ambulance_win
    subi $t2, $t2, 1
    bne $t2, $zero, -100 #if not zero, it means that the ambulance still have one step(it can walk twice)
    addi $t9, $t9, 1 #round+1
    subi $t2, $t9 30
    beq $t2, $zero, grandma_win
    j grandma_loop

move_direction:
    # get the direction from the user
    li $v0, 5 # syscall for reading an integer
    syscall
    move $t8, $v0 # store the direction in $t8
    # return to the caller
    jr $ra