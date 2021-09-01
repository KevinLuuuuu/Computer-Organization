main:
    addi $a0, $zero, 10 # n = 10
    jal fib          # call fib(10)
    j exit

fib:
    addi $sp, $sp, -4
    sw $ra, 0x0($sp)    # Save $ra register into stack

    #--------------------------------------#
    addi $sp, $sp, -4
    sw $a0, 0($sp)
    
    addi $t1, $a0, -1
    slt $t1, $zero, $t1
    beq $t1, 1, L1
    
    add $t0, $zero, $a0
    add $v0, $v0, $t0   

    lw $ra, 4($sp)
    addi $sp, $sp, 8
    jr $ra 
     L1:
     addi $a0, $a0, -1
     jal fib

     addi $a0, $a0, -1
     jal fib

     lw $a0, 0($sp)
     addi $sp, $sp, 4
    #--------------------------------------#

    lw $ra, 0x0($sp)    # Load $ra register from stack
    addi $sp, $sp, 4
    jr $ra

exit:
