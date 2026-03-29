.data
# 遊戲提示文字
prompt_grandma: .asciiz "Grandma turn: "
round:.asciiz "Round: "
x_label:.asciiz "X="
y_label:.asciiz "  Y="
Even_round: .asciiz "Even Round (a/d/n): "
Odd_round: .asciiz "Odd Round (w/s/n): "
Even_round_error:.asciiz "Even Round Only for (a/d/n): "
Odd_round_error:.asciiz "Odd Round Only for (w/s/n):  "
Boundary_error:.asciiz "Error : Move into Boundary ,move again  "
Hospital_error:.asciiz "Error : Move into Hospital ,move again  "
Ambulance_overlap:.asciiz "Error : Overlap Ambulance ,move again  "
Injured1_overlap:.asciiz "Error : Overlap Injured1 ,move again  "
Injured2_overlap:.asciiz "Error : Overlap Injured2 ,move again  "
Injured3_overlap:.asciiz "Error : Overlap Injured3 ,move again  "
Grandma_overlap:.asciiz "Error : Grandma ,move again  "
Rest_time:.asciiz "Rest move time : "
I1_get_rescue:.asciiz "Injured1 get rescue  "
I2_get_rescue:.asciiz "Injured2 get rescue  "
I3_get_rescue:.asciiz "Injured3 get rescue  "

Grandma_area:.asciiz "Ambulance bound into Grandma Area! Number of Round+1ss!"

amb:.asciiz "A"
grand:.asciiz "G"
inj1:.asciiz "1"
inj2:.asciiz "2" 
inj3:.asciiz "3" 
dot:.asciiz "."
X:.asciiz "X"


prompt_ambulance: .asciiz "Ambulance turn: "
prompt_ambulance_move: .asciiz "Ambulance Move:(w/a/s/d/n): "
Injured_on_car:.asciiz "Number of Injured on car: "
H_P_number: .asciiz "Hospital Patient Number: "

newline: .asciiz "\n"
grandma_win: .asciiz "Grandma is Winner "
ambulance_win: .asciiz "Ambulance is Winner  "
END: .asciiz "Game Finish "




# 地圖紅綠燈記憶體區域（模擬 8x8 地圖）
map_data: .space 128     # 一格 1 byte，共 64 bytes（base address = $s0）

# 遊戲狀態資訊（每格佔 4 bytes，存放在 map_status 區段）
# 初始設定：位置值等同於地圖 index（0~63）

map_status:
    .word 0   # ambulance 初始位置（假設第 17 格）
    .word 51   # grandma 初始位置（第 34 格）
    .word 82   # injured1 位置
    .word 85   # injured2 位置
    .word 37   # injured3 位置
    .word 0    # 車上傷患數 ($s6)
    .word 0    # 醫院傷患數 ($s7)
    .word 0    # 回合數     ($t9)

.text
.globl main

main:

    # 初始化 base address
    la $t0, map_data        # 地圖 base address
    la $s0, map_status      # 遊戲狀態 base address

    # 讀取初始狀態（記憶體 layout: base address = $s0）
    lw $s2, 4($s0)   # grandma location
    lw $s3, 8($s0)   # injured1 location
    lw $s4, 12($s0)  # injured2 location
    lw $s5, 16($s0)  # injured3 location
    lw $s6, 20($s0)  # injured on ambulance
    lw $s7, 24($s0)  # injured in hospital
    lw $t9, 28($s0)  # rounds

###

and $s1,$zero,$zero   # ambulance location



grandma_turn:
    addi $t4, $zero, 2
    addi $t6 ,$zero ,1
    addi $t9, $t9, 1
    #13
    jal print_map
grandma_turn_map:

    li $v0, 4
    la $a0, newline
    syscall

#########################    
    li $v0, 4
    la $a0, prompt_grandma
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    #顯示目前回合數
    li $v0, 4
    la $a0, round
    syscall
    move $a0, $t9    
    li $v0, 1        
    move $t7, $v0        
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    #XY座標
    andi $t1,$s2,7
    srl  $t2,$s2,4
    li $v0, 4
    la $a0, x_label
    syscall
    move $a0, $t1    
    li $v0, 1               
    syscall
    li $v0, 4
    la $a0, y_label
    syscall
    move $a0, $t2   
    li $v0, 1             
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    #奇偶回合判定
    andi $t5 ,$t9 ,1
    beq $t5,$zero, even_round
    bne $t5,$zero, odd_round

Gmove:
    li $v0, 12          
    syscall
    add $t7,$v0,$zero
    jal move_direction   

    #奇數回合檢查
    add $t3, $t8, $s2
    beq $t8, $zero, grandma_turn_end
    beq $t5, $zero,grandma_even_round_test
    addi $t1, $t8, -1
    beq $t1, $zero odd_round_error
    addi $t1, $t8,1
    beq $t1, $zero odd_round_error

    #偶數回合檢查
grandma_even_round_test:
    bne $t5, $zero,grandma_boundary_test 
    addi $t1, $t8, 16
    beq $t1, $zero even_round_error
    addi $t1, $t8, -16
    beq $t1, $zero even_round_error
    #28
    #邊界與碰撞檢查
grandma_boundary_test:
    ori $t1, $t3, 119 #boundary test
    addi $t1, $t1, -119
    bne $t1, $zero ,boundary_error
    ori $t1, $t3, 17 #check if in the hospital area
    addi $t1, $t1, -17
    beq $t1, $zero, hospital_error
    beq $t3, $s1 ambulance_overlap
    beq $t3, $s3 injured1_overlap
    beq $t3, $s4 injured2_overlap
    beq $t3, $s5 injured3_overlap
    
grandma_turn_end:
    # grandma 實際移動
    sub $s2, $t3, $zero
    j grandma_area_test
grandma_round_test_finish:
    addi $t6 ,$t6 ,-1
    j ambulance_turn # jump to target

#########################  

ambulance_turn:
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, prompt_ambulance
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    #顯示目前回合數
    li $v0, 4
    la $a0, round
    syscall
    move $a0, $t9    
    li $v0, 1        
    move $t7, $v0        
    syscall
    li $v0, 4
    la $a0, newline
    syscall

Amove:
    jal print_map
ambulance_turn_map:
    li $v0, 4
    la $a0, newline
    syscall
    #顯示車上人數
    li $v0, 4
    la $a0, Injured_on_car
    syscall
    move $a0, $s6    
    li $v0, 1        
    move $t7, $v0        
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    
    #顯示可移動數
    li $v0, 4
    la $a0, Rest_time
    syscall
    move $a0, $t4    
    li $v0, 1        
    move $t7, $v0        
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    #XY座標
    andi $t1,$s1,7
    srl  $t2,$s1,4
    li $v0, 4
    la $a0, x_label
    syscall
    move $a0, $t1    
    li $v0, 1               
    syscall
    li $v0, 4
    la $a0, y_label
    syscall
    move $a0, $t2   
    li $v0, 1             
    syscall
    li $v0, 4
    la $a0, newline
    syscall

    #移動
    li $v0, 4
    la $a0, prompt_ambulance_move
    syscall
    #移動輸入
    li $v0, 12           # syscall 12: read char
    syscall
    add $t7,$v0,$zero
    jal move_direction   # 根據輸入設定 $t0 為 offset

    #邊界與碰撞
    add $t3, $s1, $t8
    ori $t1, $t3, 119 #boundary test
    addi $t1, $t1, -119
    bne $t1, $zero, boundary_error_H
    beq $t3, $s2, grandma_overlap
    bne $s6, $zero, hospital

injured_1:
    bne $t3, $s3, injured_2
    addi $s6, $s6, 1
    ori $s3, $s3, 255

    #顯示患者一被接走
    li $v0, 4
    la $a0, I1_get_rescue
    syscall
    li $v0, 4
    la $a0, newline
    syscall


injured_2:
    bne $t3, $s4, injured_3
    addi $s6, $s6, 1
    ori $s4, $s4, 255

    #顯示患者二被接走
    li $v0, 4
    la $a0, I2_get_rescue
    syscall
    li $v0, 4
    la $a0, newline
    syscall

injured_3:
    bne $t3, $s5, ambulance_turn_end
    addi $s6, $s6, 1
    ori $s5, $s5, 255

    #顯示患者三被接走
    li $v0, 4
    la $a0, I3_get_rescue
    syscall
    
    li $v0, 4
    la $a0, newline
    syscall
    j ambulance_turn_end

hospital:  
    ori $t1, $t3, 17 #check if in the hospital area
    addi $t1, $t1, -17
    bne $t1, $zero, ambulance_turn_end
    addi $s6, $s6, -1
    addi $s7, $s7, 1
    addi $t1, $s7 -3

    #顯示醫院人數
    li $v0, 4
    la $a0, H_P_number
    syscall
    move $a0, $s7   
    li $v0, 1             
    syscall

    beq $t1, $zero,  Ambulance_win



ambulance_turn_end:
    sub $s1, $t3, $zero#  ambulance實際移動
    j grandma_area_test


ambulance_round_test_finish:
    srl $t4, $t4 ,1
    bne $t4 ,$zero, Amove
    j grandma_turn	# jump to target

grandma_area_test:
    addi $t1, $s1,16
    beq $t1,$s2,grandma_area
    addi $t1, $s1,-16
    beq $t1,$s2,grandma_area
    addi $t1, $s1,1
    beq $t1,$s2,grandma_area
    addi $t1, $s1,-1
    beq $t1,$s2,grandma_area
    j round_test

grandma_area:
    li $v0, 4
    la $a0, Grandma_area
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    addi $t9 ,$t9,1
    #顯示目前回合數
    li $v0, 4
    la $a0, round
    syscall
    move $a0, $t9    
    li $v0, 1        
    move $t7, $v0        
    syscall
    li $v0, 4
    la $a0, newline
    syscall
    j round_test


round_test:
    addi $t2,$zero ,32
    slt $t1 ,$t2,$t9
    bne $t1, $zero, Grandma_win
    beq $t6,$zero, ambulance_round_test_finish
    j grandma_round_test_finish
###################################

#---------------------------------------------------------
# 根據 $t7 方向 (ascii) 設定 $t0 offset: w(+16), a(-1), s(-16), d(+1)
move_direction:
    li $t0, 0
    li $t1, 'w'
    beq $t7, $t1, move_up
    li $t1, 'a'
    beq $t7, $t1, move_left
    li $t1, 's'
    beq $t7, $t1, move_down
    li $t1, 'd'
    beq $t7, $t1, move_right
    li $t1, 'n'            # ASCII 48
    beq $t7, $t1, move_none
    jr $ra                  # 如果輸入不是這些 → 不動

move_up:
    li $t8, 16
    jr $ra
move_down:
    li $t8, -16
    jr $ra
move_left:
    li $t8, -1
    jr $ra
move_right:
    li $t8, 1
    jr $ra
move_none:
    li $t8, 0               # 原地不動
    jr $ra
#---------------------------------------------------------
####################################################
even_round:
    li $v0, 4
    la $a0, Even_round
    syscall
    j Gmove
####################################################
odd_round:
    li $v0, 4
    la $a0, Odd_round
    syscall
    j Gmove
###################################################
even_round_error:
    li $v0, 4
    la $a0, Even_round_error
    syscall
    j Gmove
###################################################
odd_round_error:
    li $v0, 4
    la $a0, Odd_round_error
    syscall
    j Gmove
###################################################
boundary_error:
    li $v0, 4
    la $a0, Boundary_error
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    beq $t5 ,$zero ,even_round
    bne $t5 ,$zero ,odd_round
###################################################
hospital_error:
    li $v0, 4
    la $a0, Hospital_error
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    beq $t5 ,$zero ,even_round
    bne $t5 ,$zero ,odd_round
###################################################
ambulance_overlap:
    li $v0, 4
    la $a0, Ambulance_overlap
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    beq $t5 ,$zero ,even_round
    bne $t5 ,$zero ,odd_round
###################################################
injured1_overlap:
    li $v0, 4
    la $a0, Injured1_overlap
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    beq $t5 ,$zero ,even_round
    bne $t5 ,$zero ,odd_round
###################################################
injured2_overlap:
    li $v0, 4
    la $a0, Injured2_overlap
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    beq $t5 ,$zero ,even_round
    bne $t5 ,$zero ,odd_round
###################################################
injured3_overlap:
    li $v0, 4
    la $a0, Injured3_overlap
    syscall

    li $v0, 4
    la $a0, newline
    syscall

    beq $t5 ,$zero ,even_round
    bne $t5 ,$zero ,odd_round
###################################################
boundary_error_H:
    li $v0, 4
    la $a0, Boundary_error
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    j Amove

###################################################
grandma_overlap:
    li $v0, 4
    la $a0, Grandma_overlap
    syscall

    li $v0, 4
    la $a0, newline
    syscall
    j Amove

#####################################################
print_map:
    li $v0, 4
    la $a0, newline
    syscall

    addi $t1 , $zero,112

print_map_loop:
    beq $t1, 8, print_map_end    
    andi $t2, $t1, 8              
    addi $t2, $t2, -8 
    beq  $t2,$zero, print_map_newline

print_map_continue:

    beq $t1, $s1, print_A
    beq $t1, $s2, print_G
    beq $t1, $s3, print_1
    beq $t1, $s4, print_2
    beq $t1, $s5, print_3
    addi $t2,$s2,16
    beq $t1, $t2, print_grandma_area
    addi $t2,$s2,-16
    beq $t1, $t2, print_grandma_area
    addi $t2,$s2,1
    beq $t1, $t2, print_grandma_area
    addi $t2,$s2,-1
    beq $t1, $t2, print_grandma_area



    j print_DOT

print_A:
    li $v0, 4
    la $a0, amb
    syscall
    j print_next
    
print_G:
    li $v0, 4
    la $a0, grand
    syscall
    j print_next

print_1:
    li $v0, 4
    la $a0, inj1
    syscall
    j print_next

print_2:
    li $v0, 4
    la $a0, inj2
    syscall
    j print_next

print_3:
    li $v0, 4
    la $a0, inj3
    syscall
    j print_next

print_DOT:
    li $v0, 4
    la $a0, dot
    syscall
    j print_next

print_grandma_area:
    li $v0, 4
    la $a0, X
    syscall
    j print_next

print_next:
    addi $t1, $t1, 1
    j print_map_loop

print_map_newline:
    addi $t1 ,$t1, -24
    li $v0, 4
    la $a0, newline
    syscall
    
    j print_map_continue

print_map_end:
    li $v0, 4
    la $a0, newline
    syscall
    jr $ra
    #beq $t6 , $zero,ambulance_turn_map
    #bne $t6 , $zero,grandma_turn_map

########################################################

#---------------------------------------------------------
Ambulance_win:
    li $v0, 4
    la $a0, newline
    syscall

    li $v0, 4
    la $a0, ambulance_win
    syscall
    # 顯示勝利訊息可自行加上
    j end


Grandma_win:
    li $v0, 4
    la $a0, newline
    syscall
    li $v0, 4
    la $a0, grandma_win
    syscall
    # 顯示勝利訊息可自行加上
    j end

end:
    li $v0, 4
    la $a0,END
    syscall
    li $v0, 10
    syscall







