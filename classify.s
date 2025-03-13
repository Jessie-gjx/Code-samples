.globl classify

.text
# =====================================
# COMMAND LINE ARGUMENTS
# =====================================
# Args:
#   a0 (int)        argc
#   a1 (char**)     argv
#   a1[1] (char*)   pointer to the filepath string of m0
#   a1[2] (char*)   pointer to the filepath string of m1
#   a1[3] (char*)   pointer to the filepath string of input matrix
#   a1[4] (char*)   pointer to the filepath string of output file
#   a2 (int)        silent mode, if this is 1, you should not print
#                   anything. Otherwise, you should print the
#                   classification and a newline.
# Returns:
#   a0 (int)        Classification
# Exceptions:
#   - If there are an incorrect number of command line args,
#     this function terminates the program with exit code 31
#   - If malloc fails, this function terminates the program with exit code 26
#
# Usage:
#  main.s <M0_PATH> <M1_PATH> <INPUT_PATH> <OUTPUT_PATH>0
classify:
    li t0 5
    bne a0 t0 Ex31
    addi sp sp -56
    
    sw a0 0(sp)
    sw a1 4(sp)
    sw a2 8(sp)
    sw ra 12(sp)
    sw s0 16(sp)
    sw s1 20(sp)
    sw s2 24(sp)
    sw s3 28(sp)
    sw s4 32(sp)
    sw s5 36(sp)
    sw s6 40(sp)
    sw s7 44(sp)
    sw t6 48(sp) # why store
    sw t1 52(sp) # why store
    
    # Read pretrained m0
    li a0 4
    jal ra, malloc
    beq a0 x0 Ex26
    mv a1, a0 
    
    li a0 4
    addi sp sp -4
    sw a1 0(sp)
    jal ra, malloc
    lw a1 0(sp)
    addi sp sp 4
    beq a0 x0 Ex26
    mv a2, a0
    
    lw t1 4(sp)
    lw a0 4(t1) #file_name
    addi sp sp -8
    sw a1 0(sp)
    sw a2 4(sp)
    jal ra, read_matrix
    lw a1 0(sp)
    lw a2 4(sp)
    addi sp sp 8
    mv s0 a0 #pointer to m0
    lw s1 0(a1)
    lw s2 0(a2)
    
    addi sp sp -4
    sw a2 0(sp)
    mv a0 a1 
    jal ra, free
    lw a2 0(sp)
    addi sp sp 4
    
    mv a0 a2 
    jal ra, free
    
  
    

    # Read pretrained m1
    li a0 4
    jal ra, malloc
    beq a0 x0 Ex26
    mv a1, a0 
   
    li a0 4   
    addi sp sp -4
    sw a1 0(sp)
    jal ra, malloc
    lw a1 0(sp)
    addi sp sp 4
    beq a0 x0 Ex26
    mv a2, a0
   
    lw t1 4(sp)
    lw a0 8(t1)
    # save s0-s2
    
   
    addi sp sp -8
    sw a1 0(sp)
    sw a2 4(sp)
    jal ra, read_matrix
    lw a1 0(sp)
    lw a2 4(sp)
    addi sp sp 8
  
 

    mv s3 a0 #m1
    lw s4 0(a1)
    lw s5 0(a2)
    
    addi sp sp -4
    sw a2 0(sp)
    mv a0 a1
    jal ra, free
    lw a2 0(sp)
    addi sp sp 4
    
    mv a0 a2 
    jal ra, free


    # Read input matrix
    li a0 4
    jal ra, malloc
    beq a0 x0 Ex26
    mv a1, a0 
   

   
    li a0 4
    addi sp sp -4
    sw a1 0(sp)
    jal ra, malloc
    lw a1 0(sp)
    addi sp sp 4
    beq a0 x0 Ex26
    mv a2 a0
   




    lw t1 4(sp)
    lw a0 12(t1)
    
    # save s0-s5
    

    addi sp sp -8
    sw a1 0(sp)
    sw a2 4(sp)
    jal ra, read_matrix
    lw a1 0(sp)
    lw a2 4(sp)
    addi sp sp 8

 
    
    mv s6 a0 #input
    lw s7 0(a1)
    lw t6 0(a2) # store the col of input
    
    addi sp sp -8
    sw a2 0(sp)
    sw t6 4(sp)
    mv a0 a1
    jal ra, free
    lw a2 0(sp)
    lw t6 4(sp)
    addi sp sp 8
   
    addi sp sp -4
    sw t6 0(sp)
    mv a0 a2 
    jal ra, free
    lw t6 0(sp)
    addi sp sp 4

    ## Compute h = matmul(m0, input)
    addi sp sp -4
    sw t6 0(sp)
    
    li t3 4
    mul t3 t3 t6
    mul t3 t3 s1
    mv a0 t3 #open the array for h
    
    jal ra, malloc
    beq a0 x0 Ex26
    lw t6 0(sp)
    addi sp sp 4
    mv a6, a0 
    # load the argument of func
    mv a0 s0
    mv a1 s1
    mv a2 s2
    mv a3 s6
    mv a4 s7
    mv a5 t6
    
    # save s0-s7ï¼t6 #9 numbers

    sw t6 48(sp)
    
    addi sp sp -4
    sw a6 0(sp)
    jal ra, matmul #a6 store the pointer to h, row of h is s1, col of h is t6
    lw a6 0(sp)
    addi sp sp 4


    lw t6 48(sp)
    

    # Compute h = relu(h)
    mv a0 a6
    mul a1 s1 t6
    # save s0-s7ï¼t6 #9 numbers

    sw t6 48(sp)
    
    addi sp sp -4
    sw a0 0(sp)
    jal ra, relu
    lw a0 0(sp)
    addi sp sp 4

    lw t6 48(sp)
    

    ## Compute o = matmul(m1, h) row of o is s4, col of o is t6
    
    mv t1 a0 # a0 store the pointer to h->t1
    addi sp sp -8
    sw t6 0(sp)
    sw t1 4(sp)
    
    li t3 4
    mul t3 t3 s4
    mul t3 t3 t6
    mv a0 t3
    jal ra, malloc
    beq a0 x0 Ex26
    
    lw t6 0(sp)
    lw t1 4(sp)
    addi sp sp 8

    mv a6, a0 
    # load the argument of func
    mv a0 s3
    mv a1 s4
    mv a2 s5
    mv a3 t1
    mv a4 s1
    mv a5 t6
    
    # save s0-s7ï¼t6 #9 numbers
   

    sw t6 48(sp)
    sw t1 52(sp)

    addi sp sp -4
    sw a6 0(sp)
    jal ra, matmul #a6 store the pointer to o
    lw a6 0(sp)
    addi sp sp 4


    lw t6 48(sp)
    lw t1 52(sp)
    

    addi sp sp -8
    sw a6 0(sp)
    sw t6 4(sp)
    mv a0 t1
    jal ra, free #free the h
    lw a6 0(sp)
    lw t6 4(sp)
    addi sp sp 8

    # Write output matrix o
    lw t1 4(sp)
    lw a0 16(t1)

    mv s1 a6 # prepare for free of o
    mv a1 a6 # a6 store the address to o
    mv a2 s4
    mv a3 t6
    
    #save first?
    addi sp sp -8
    sw a6 0(sp)
    sw t6 4(sp)
    jal ra, write_matrix 
    lw a6 0(sp)
    lw t6 4(sp)
    addi sp sp 8

    # Compute and return argmax(o)
    addi sp sp -4
    sw a6 0(sp)
    
    mv a0 a6
    mul t0 s4 t6
    mv a1 t0
    jal ra, argmax
    # a0 store the out put of argmax(o)
    mv t3 a0 # t3 ,rv
    lw a6 0(sp)
    addi sp sp 4
    
    # If enabled, print argmax(o) and newline
    lw t2 8(sp)
    li t0 1
    mv s4 a0
    beq t2 t0 freenow
    
    jal ra, print_int 
    li a0, '\n'         
    jal ra, print_char          
    
    
    
    j freenow
freenow:
    mv a0 s1 #free the o
    jal ra, free
    mv a0 s0 
    jal ra, free
    
    mv a0 s3 
    jal ra, free
    
    mv a0 s6 
    jal ra, free
    


    
    j slient
slient:
    mv a0 s4
    lw ra 12(sp)
    lw s0 16(sp)
    lw s1 20(sp)
    lw s2 24(sp)
    lw s3 28(sp)
    lw s4 32(sp)
    lw s5 36(sp)
    lw s6 40(sp)
    lw s7 44(sp)
    addi sp sp 56
    jr ra
Ex26:
    li a0 26
    j exit
Ex31:
    li a0 31
    j exit
