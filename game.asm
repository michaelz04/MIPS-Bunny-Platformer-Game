#####################################################################
#
# CSCB58 Summer 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Michael Zhou, Student Number, 1009262637, michaelz.zhou@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 4 (update this as needed)
# - Unit height in pixels: 4 (update this as needed)
# - Display width in pixels: 512 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 3 (choose the one the applies)
#
# Which approved features have been implemented for milestone 3?
# (See the assignment handout for the list of additional features)
# 1. (fill in the feature, if any)
# 2. (fill in the feature, if any)
# 3. (fill in the feature, if any)
# ... (add more if necessary)
#
# Link to video demonstration for final submission:
# - (insert YouTube / MyMedia / other URL here). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - yes / no / yes, and please share this project github link as well!
#
# Any additional information that the TA needs to know:
# - (write here, if any)
#
#####################################################################

.data
MOVING_PLATFORM_COUNTER: 0
MOVING_PLATFORM_CHECK: 0

SCORE_COUNTER: 0

CARROT_ONE: 0
CARROT_TWO: 0
CARROT_THREE: 0

CARROT_DIRECTION: 0
CARROT_MOVE_COUNTER: 0

.globl main

.eqv 	BASE_ADDRESS 	0x10008000
.eqv 	SLEEP_MS 	30

.eqv 	BORDER_HEIGHT	500
.eqv	BORDER_WIDTH	500
.eqv	DISPLAY_WIDTH	512
.eqv	DISPLAY_HEIGHT	63
.eqv	BUNNY_WIDTH	14
.eqv 	BUNNY_HEIGHT	13
.eqv	BUNNY_MAX_HEIGHT	7220  #14 * 512 + 13*4
.eqv	BUNNY_MIN_HEIGHT	31744  #62 * 512

.eqv 	OFFSET_BOTTOM_LEFT	56    # $s0 - OFFSET_BOTTOM_LEFT is bottom left pixel address of sprite
.eqv 	OFFSET_TOP_LEFT		6200  # $s0 - OFFSET_TOP_LEFT is top left pixel address of sprite
.eqv 	OFFSET_TOP_RIGHT	6144  # $s0 - OFFSET_TOP_RIGHT is top right pixel address of sprite

.eqv	RED	0xff0000
.eqv	WHITE	0xffffff
.eqv	BLACK	0x000000
.eqv	GREEN	0x008000
.eqv	ORANGE	0xFFA500
.eqv	BLUE	0x0000FF 

.eqv	CARROT_1_START 		17460
.eqv	CARROT_1_END 		19508
.eqv	CARROT_2_START 		29632
.eqv	CARROT_2_END 		31680
.eqv	CARROT_3_START 		7268
.eqv	CARROT_3_END 		9316
.text

# IMPORTANT $s REGISTERS:
# $s0: bottom right pixel address of sprite
# $s1: if sprite jumping = 1, otherwise 0
# $s2: if sprite facing left = 1, otherwise 0
# $s3: jumping frame counter
# $s4: tracks net sprite position change
# $s5: timer
# $s6: keeps track of double jump (1 if double jump allowed, 0 otherwise)
# $s7: tracks if sprite is in the air = 1, ie not standing on platform

main:
	START_MAIN:
	#initialize $s registers
	li $s0, BASE_ADDRESS
	addi $s0, $s0, 30000	#################   $s0 stores bottom left pixel address of sprite
	
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s7, 1
	li $s6, 1
	li $s5, 0
	
	li $t9, 0xffff0000
	sw $zero 4($t9) #reset keyboard input
	
	jal CLEAR_SCREEN
	li $t4 1 #t4 stores if arrow is on start (1) or on exit (0)
START_MENU_LOOP:

	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x77, GO_TO_START #if key = w, go up
	beq $t8, 0x73, GO_TO_EXIT #if key = s, go down
	beq $t8, 0x20, SELECT_OPTION #if key = space, go select option
	j SKIP_SELECT_OPTION
	SELECT_OPTION:
	beq $t4 1 END_START_MENU
	beq $t4 0 EXIT
	
	GO_TO_START:
	li $t4 1
	j SKIP_EXIT
	GO_TO_EXIT:
	li $t4 0
	SKIP_EXIT:
	SKIP_SELECT_OPTION:
	
	jal DRAW_START_MENU
	jal DRAW_ARROW
	jal CLEAR_ARROW
	
	j START_MENU_LOOP
	
END_START_MENU:	
	jal CLEAR_SCREEN
	#draw bottom platform

	li $t8, DISPLAY_WIDTH
	li $t9, DISPLAY_HEIGHT
	li $t0, BASE_ADDRESS
	mult $t8 $t9
	mflo $t8
	add $t8 $t0 $t8
	
	li $t1, RED 
	
	li $t9, 0
	BOTTOM_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	beq $t9, 128, BOTTOM_DRAWN
	j BOTTOM_PLATFORM_LOOP
	BOTTOM_DRAWN:	
	
	
	#draw platforms
	li $t9 0
	li $t8 10240
	addi $t8 $t8 BASE_ADDRESS
	
	TOP_LEFT_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	beq $t9, 30, TOP_LEFT_DRAWN
	j TOP_LEFT_PLATFORM_LOOP
	TOP_LEFT_DRAWN:	
	
	li $t9 0
	li $t8 20480
	addi $t8 $t8 BASE_ADDRESS
	
	MIDDLE_LEFT_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	beq $t9, 15, MIDDLE_LEFT_DRAWN
	j MIDDLE_LEFT_PLATFORM_LOOP
	MIDDLE_LEFT_DRAWN:	
	
	li $t9 0
	li $t8 24424
	addi $t8 $t8 BASE_ADDRESS
	
	BOTTOM_RIGHT_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	beq $t9, 30, BOTTOM_RIGHT_DRAWN
	j BOTTOM_RIGHT_PLATFORM_LOOP
	BOTTOM_RIGHT_DRAWN:
	
	
	#draw borders
	li $t9 0
	li $t8 0
	addi $t8 $t8 BASE_ADDRESS
	LEFT_BORDER_LOOP:
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 512
	beq $t9, 126, LEFT_BORDER_DRAWN
	j LEFT_BORDER_LOOP
	LEFT_BORDER_DRAWN:	
	
	li $t9 0
	li $t8 508
	addi $t8 $t8 BASE_ADDRESS
	RIGHT_BORDER_LOOP:
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 512
	beq $t9, 126, RIGHT_BORDER_DRAWN
	j RIGHT_BORDER_LOOP
	RIGHT_BORDER_DRAWN:	
	
	#draw score box
	li $t9 0
	li $t8 6504
	addi $t8 $t8 BASE_ADDRESS
	
	SCORE_BOX_BOTTOM_LOOP:
	sw $t1, -4($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	blt $t9 38 SCORE_BOX_BOTTOM_LOOP
	
	li $t9 0
	li $t8 360
	addi $t8 $t8 BASE_ADDRESS
	
	SCORE_BOX_SIDE_LOOP:
	sw $t1, -8($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 512
	blt $t9 13 SCORE_BOX_SIDE_LOOP
	
	
	#draw ceiling
	li $t9, 0
	li $t8 0
	addi $t8 $t8 BASE_ADDRESS
	CEILING_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	blt $t9, 128, CEILING_LOOP
	
	#draw carrot score icon
	li $a0 5540
	addi $a0 $a0 BASE_ADDRESS
	jal DRAW_CARROT
	
	#initialize .data variables with 0
	li $t3 0
	
	la $t0 MOVING_PLATFORM_COUNTER #t0 holds address of variable
	sw $t3 0($t0)
	la $t0 MOVING_PLATFORM_CHECK
	sw $t3 0($t0)
	la $t0 SCORE_COUNTER
	sw $t3 0($t0)
	la $t0 CARROT_ONE
	sw $t3 0($t0)
	la $t0 CARROT_TWO
	sw $t3 0($t0)
	la $t0 CARROT_THREE
	sw $t3 0($t0)
	la $t0 CARROT_DIRECTION
	sw $t3 0($t0)
	la $t0 CARROT_MOVE_COUNTER
	sw $t3 0($t0)
	
	
	
	
MAIN_LOOP: #main loop for game 
	
	
	#draw moving platform in middle
	la $t0 MOVING_PLATFORM_COUNTER #t0 holds address of variable
	lw $t3 0($t0) #t3 holds current index between 1 and 10
	la $t4 MOVING_PLATFORM_CHECK
	lw $t5 0($t4) #t5 holds 1 or 0 whether platform should move left or right
	
	beq $t5 0 MOVING_RIGHT
	#else moving left
	bne $t3 0 SKIP_CHANGE_DIRECTION_RIGHT
	li $t5 0
	SKIP_CHANGE_DIRECTION_RIGHT:
	subi $t3 $t3 1
	j MOVING_PLATFORM_END
	MOVING_RIGHT:
	bne $t3 30 SKIP_CHANGE_DIRECTION_LEFT
	li $t5 1
	SKIP_CHANGE_DIRECTION_LEFT:
	addi $t3 $t3 1
	
	MOVING_PLATFORM_END:
	sw $t3 0($t0)
	sw $t5 0($t4)
	
	li $t1, RED 
	li $t2, BLACK
	li $t9 0
	sll $t3 $t3 2
	li $t8 14000
	addi $t8 $t8 BASE_ADDRESS
	
	li $t9 0
	li $t8 14000
	addi $t8 $t8 BASE_ADDRESS
	add $t8 $t8 $t3
	
	beq $t5 1 SKIP_MOVE_RIGHT
	sw $t2, -4($t8)
	
	j MIDDLE_PLATFORM_LOOP
	
	SKIP_MOVE_RIGHT:
	sw $t2, 80($t8)
	
	MIDDLE_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	blt $t9, 20, MIDDLE_PLATFORM_LOOP
	
	
	#timer check
	beq $s5 2220 EXIT #2000 is 1 min
	addi $s5 $s5 1
	
	jal PRINT_TIMER
	
	#score check
	la $t0 SCORE_COUNTER
	la $t1 CARROT_ONE
	lw $t2 0($t1)
	la $t1 CARROT_TWO
	lw $t3 0($t1)
	la $t1 CARROT_THREE
	lw $t4 0($t1)
	
	div $t2 $t2 2
	div $t3 $t3 2
	div $t4 $t4 2
	
	add $t6 $t2 $t3
	add $t6 $t6 $t4
	
	sw $t6 0($t0)
	
	li $t0 2408
	addi $t0 $t0 BASE_ADDRESS
	bne $t6 0 SKIP_DRAW_ZERO
	jal DRAW_ZERO
	j SCORE_DRAW_DONE
	SKIP_DRAW_ZERO:
	
	jal CLEAR_NUMBER
	bne $t6 1 SKIP_DRAW_ONE
	li $t0 2408
	addi $t0 $t0 BASE_ADDRESS
	jal DRAW_ONE
	j SCORE_DRAW_DONE
	SKIP_DRAW_ONE:
	bne $t6 2 SKIP_DRAW_TWO
	li $t0 2408
	addi $t0 $t0 BASE_ADDRESS
	jal DRAW_TWO
	j SCORE_DRAW_DONE
	SKIP_DRAW_TWO:
	bne $t6 3 SKIP_DRAW_THREE
	li $t0 2408
	addi $t0 $t0 BASE_ADDRESS
	jal DRAW_THREE
	j SCORE_DRAW_DONE
	SKIP_DRAW_THREE:
	
	SCORE_DRAW_DONE:
	
	li $s4 0 #load net position change
	
	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x70, START_MAIN #if key = p, exit
	
	beq $s6 0 SKIP_W_PRESS
	beq $t8, 0x77, UP #if key = w, go up
	SKIP_W_PRESS:
	beq $t8, 0x73, DOWN #if key = s, go down
	beq $t8, 0x61, LEFT #if key = a, go left
	beq $t8, 0x64, RIGHT #if key = d, go right
	
	#check for collisions
	#check if on ground for now
	#check bottom right pixel
	move $t1 $s0
	addi $t1 $t1 512
	lw $t1 4($t1)
	beq $t1 RED ON_GROUND
	#check bottom left pixel
	move $t1 $s0
	addi $t1 $t1 512
	subi $t1 $t1 OFFSET_BOTTOM_LEFT
	lw $t1 4($t1)
	beq $t1 RED ON_GROUND
	#set to in air
	li $s7 1
	j SKIP_ON_GROUND
	ON_GROUND:
	li $s7 0
	li $s6 1
	
	SKIP_ON_GROUND:
	#if jumping
	beq $s1 1 JUMPING
	j SKIP_JUMPING
	JUMPING:
	#check if above is platform
#	move $t1 $s0
#	subi $t1 $t1 512
#	subi $t1 $t1 OFFSET_TOP_LEFT
#	lw $t1 4($t1)
#	beq $t1 RED RESET_JUMP
	#check top left/right pixel
#	move $t1 $s0
#	subi $t1 $t1 512
#	subi $t1 $t1 OFFSET_TOP_RIGHT
#	lw $t1 4($t1)
#	beq $t1 RED RESET_JUMP
	
	
	###
	move $t1 $s0
	subi $t1 $t1 512
	subi $t1 $t1 OFFSET_TOP_LEFT
	
	li $t9 0
	ABOVE_PLATFORM_CHECK_LOOP:
	lw $t2 4($t1)
	addi $t1 $t1 4
	beq $t2 RED RESET_JUMP
	addi $t9 $t9 1
	blt $t9 14 ABOVE_PLATFORM_CHECK_LOOP
	###
	
	
	#above not platform
	subi $s0, $s0, 512
	#jump delay
	#li $v0, 32
	#li $a0, 30
	#syscall	
	#check number of jumping frames
	beq $s3 20 RESET_JUMP
	j SKIP_RESET_JUMP

	RESET_JUMP:
	li $s3 0
	li $s1 0
	
	SKIP_RESET_JUMP:	
	addi $s3 $s3 1
	j SKIP_FALLING
	
	SKIP_JUMPING:
	#gravity
	beq $s7 1 FALLING
	j SKIP_FALLING
	FALLING:
	addi $s0, $s0, 512	
	#li $v0, 32
	#li $a0, 30
	#syscall
	
	SKIP_FALLING:
	AFTER_KEY_PRESS:
	
	
	### 
	la $t0 CARROT_DIRECTION
	lw $t7 0($t0)
	la $t0 CARROT_MOVE_COUNTER
	lw $t8 0($t0)
	
	bne $t7 0 CARROT_DOWN
	beq $t8 -3 CARROT_DIRECTION_DOWN
	move $t6 $t8
	subi $t8 $t8 1
	sw $t8 0($t0)
	j DONE_CARROT_OFFSET
	CARROT_DIRECTION_DOWN:
	la $t0 CARROT_DIRECTION
	li $t7 1
	sw $t7 0($t0)
	
	CARROT_DOWN:
	beq $t8 0 CARROT_DIRECTION_UP
	move $t6 $t8
	
	addi $t8 $t8 1
	la $t0 CARROT_MOVE_COUNTER
	sw $t8 0($t0)
	j DONE_CARROT_OFFSET
	CARROT_DIRECTION_UP:
	la $t0 CARROT_DIRECTION
	li $t7 0
	sw $t7 0($t0)
	la $t0 CARROT_MOVE_COUNTER
	lw $t8 0($t0)
	move $t6 $t8
	subi $t8 $t8 1
	sw $t8 0($t0)
	
	DONE_CARROT_OFFSET:
	mul $t6 $t6 512
	###
	
	
	
	#draw carrot 1
	
	
	la $t0 CARROT_ONE
	lw $t1 0($t0)
	
	li $a0 CARROT_1_END
	addi $a0 $a0 BASE_ADDRESS
	add $a0 $a0 $t6
	
	beq $t1 0 DRAW_CARROT_ONE
	beq $t1 2 SKIP_DRAW_CARROT_ONE
	jal CLEAR_CARROT
	li $t3 2
	la $t0 CARROT_ONE
	sw $t3 0($t0)
	j SKIP_DRAW_CARROT_ONE
	
	DRAW_CARROT_ONE:
	li $a0 CARROT_1_END
	addi $a0 $a0 BASE_ADDRESS
	jal CLEAR_CARROT
	li $a0 CARROT_1_END
	addi $a0 $a0 BASE_ADDRESS
	add $a0 $a0 $t6
	jal DRAW_CARROT

	SKIP_DRAW_CARROT_ONE:
	
	#draw carrot 2
	la $t0 CARROT_TWO
	lw $t1 0($t0)
	
	li $a0 CARROT_2_END
	addi $a0 $a0 BASE_ADDRESS
	
	beq $t1 0 DRAW_CARROT_TWO
	beq $t1 2 SKIP_DRAW_CARROT_TWO
	jal CLEAR_CARROT
	li $t3 2
	la $t0 CARROT_TWO
	sw $t3 0($t0)
	j SKIP_DRAW_CARROT_TWO
	
	DRAW_CARROT_TWO:
	li $a0 CARROT_2_END
	addi $a0 $a0 BASE_ADDRESS
	jal CLEAR_CARROT
	li $a0 CARROT_2_END
	addi $a0 $a0 BASE_ADDRESS
	add $a0 $a0 $t6
	jal DRAW_CARROT

	SKIP_DRAW_CARROT_TWO:
	
	#draw carrot 3
	la $t0 CARROT_THREE
	lw $t1 0($t0)
	
	li $a0 CARROT_3_END
	addi $a0 $a0 BASE_ADDRESS
	
	beq $t1 0 DRAW_CARROT_THREE
	beq $t1 2 SKIP_DRAW_CARROT_THREE
	jal CLEAR_CARROT
	li $t3 2
	la $t0 CARROT_THREE
	sw $t3 0($t0)
	j SKIP_DRAW_CARROT_THREE
	
	DRAW_CARROT_THREE:
	li $a0 CARROT_3_END
	addi $a0 $a0 BASE_ADDRESS
	jal CLEAR_CARROT
	li $a0 CARROT_3_END
	addi $a0 $a0 BASE_ADDRESS
	add $a0 $a0 $t6
	jal DRAW_CARROT_BLUE

	SKIP_DRAW_CARROT_THREE:
	
	
	#sleep
	li $v0, 32
	li $a0, SLEEP_MS
	syscall
	
	j DRAW_BUNNY
	
	j MAIN_LOOP
	
UP:
	sw $zero 4($t9)
	beq $s7 0 ENABLE_DOUBLE_JUMP
	beq $s6 1 ENABLE_DOUBLE_JUMP
	j AFTER_KEY_PRESS
	ENABLE_DOUBLE_JUMP:
	li $s1 1
	li $s6 0
	li $s3 0
	j AFTER_KEY_PRESS
	
	
DOWN:
	jal CLEAR_BUNNY
	sw $zero 4($t9)
	#check bottom right pixel
	move $t1 $s0
	addi $t1 $t1 512
	lw $t1 4($t1)
	beq $t1 RED AFTER_KEY_PRESS
	#check bottom left pixel
	move $t1 $s0
	addi $t1 $t1 512
	subi $t1 $t1 OFFSET_BOTTOM_LEFT
	lw $t1 4($t1)
	beq $t1 RED AFTER_KEY_PRESS
	#if in air
	addi $s4, $s4, 512
	j DRAW_BUNNY

	j AFTER_KEY_PRESS
	

LEFT:
	
	sw $zero 4($t9)
	#check bottom left pixel
	move $t1 $s0
	subi $t1 $t1 4
	subi $t1 $t1 OFFSET_TOP_LEFT
	lw $t1 4($t1)
	beq $t1 RED AFTER_KEY_PRESS
	#if not touching border wall
	 
	

	
	
	jal CLEAR_BUNNY
	subi $s4, $s4, 4
	li $s2 1
	
	beq $a1 1 CHANGE_FRAME_LEFT
	li $a1 1
	j SKIP_CHANGE_FRAME_LEFT
	CHANGE_FRAME_LEFT:
	li $a1 0
	
	SKIP_CHANGE_FRAME_LEFT:
	j DRAW_BUNNY
	j AFTER_KEY_PRESS
RIGHT:
	sw $zero 4($t9)
	#check bottom right pixel
	move $t1 $s0
	addi $t1 $t1 4
	lw $t1 4($t1)
	beq $t1 RED AFTER_KEY_PRESS
	#if not touching border wall
	jal CLEAR_BUNNY
	addi $s4, $s4, 4
	li $s2 0
	j DRAW_BUNNY
	j AFTER_KEY_PRESS

DRAW_BUNNY:
	
	#if invalid draw, dont update position
	jal DRAW_BUNNY_HITBOX
	jal CLEAR_BUNNY
	add $s0 $s0 $s4
	INVALID_DRAW:
	
	DRAW_BUNNY_STANDING:
	beq $s2 1 DRAW_BUNNY_LEFT
	j DRAW_BUNNY_RIGHT
	
#draw bunny facing left
#start from bottom right, to left
#$s0 will contain the bottom right corner address of bunny sprite
DRAW_BUNNY_LEFT:

	beq $a1 1 DRAW_BUNNY_LEFT_RUNNING
	
	li $t1, BLACK # $t1 stores the black colour code
	li $t2, WHITE # $t2 stores the white colour code
	move $t3, $s0
	#row 1
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -36($t3) 
	sw $t1, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 2
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 
	sw $t1, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 3
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t1, -40($t3) 
	
	subi $t3, $t3, 512
	#row 4
	sw $t1, 0($t3) 
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 5
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 6
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t1, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 7
	sw $t1, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t1, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 8
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 9
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 10
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 11
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 12
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 13
	sw $t1, -32($t3) 
	sw $t1, -40($t3) 
	
	
	j MAIN_LOOP


#PROBABLY NOT USING AND DELETING
DRAW_BUNNY_LEFT_RUNNING:
	
	li $a1 0
	
	li $t1, BLACK # $t1 stores the black colour code
	li $t2, WHITE # $t2 stores the white colour code
	move $t3, $s0
	#row 1
	sw $t1, 0($t3) 
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -40($t3) 
	sw $t1, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 2
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 3
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 
	sw $t1, -32($t3)
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 4
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t1, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 5
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 6
	sw $t1, 0($t3) 
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3)
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 7
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t1, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 8
	sw $t1, 0($t3) 
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t1, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 9 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 10
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t1, -48($t3)  
	#row 11
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 12
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 13
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t1, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 14
	sw $t1, -32($t3) 
	sw $t1, -40($t3) 
	
	
	
	j MAIN_LOOP
	
DRAW_BUNNY_RIGHT:
	li $t1, BLACK # $t1 stores the black colour code
	li $t2, WHITE # $t2 stores the white colour code
	move $t3, $s0
	#row 1
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -28($t3) 
	sw $t1, -32($t3) 
	sw $t1, -36($t3) 
	sw $t1, -40($t3) 
	sw $t1, -44($t3) 
	
	subi $t3, $t3, 512
	#row 2
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 3
	sw $t1, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t1, -32($t3) 
	sw $t1, -36($t3) 
	sw $t1, -40($t3) 
	sw $t2, -44($t3) 
	sw $t1, -48($t3)
	
	subi $t3, $t3, 512
	#row 4
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t2, -44($t3) 
	sw $t1, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 5
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	sw $t2, -48($t3) 
	sw $t1, -52($t3) 
	
	subi $t3, $t3, 512
	#row 6
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t1, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t2, -40($t3) 
	sw $t1, -44($t3) 
	sw $t1, -48($t3) 
	
	subi $t3, $t3, 512
	#row 7
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t1, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t2, -24($t3) 
	sw $t2, -28($t3) 
	sw $t2, -32($t3) 
	sw $t2, -36($t3) 
	sw $t1, -40($t3) 
	
	subi $t3, $t3, 512
	#row 8
	sw $t1, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 
	sw $t1, -32($t3) 
	sw $t1, -36($t3) 
	
	subi $t3, $t3, 512
	#row 9
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 
	sw $t2, -16($t3) 
	sw $t2, -20($t3) 
	sw $t1, -24($t3) 
	
	subi $t3, $t3, 512
	#row 10
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t1, -16($t3) 
	sw $t2, -20($t3) 
	sw $t1, -24($t3) 
	
	subi $t3, $t3, 512
	#row 11
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t1, -16($t3) 
	sw $t2, -20($t3) 
	sw $t1, -24($t3) 
	
	subi $t3, $t3, 512
	#row 12
	sw $t1, -8($t3) 
	sw $t2, -12($t3) 
	sw $t1, -16($t3) 
	sw $t2, -20($t3) 
	sw $t1, -24($t3) 
	
	subi $t3, $t3, 512
	#row 13
	sw $t1, -12($t3) 
	sw $t1, -20($t3) 
	
	j MAIN_LOOP
	
CLEAR_BUNNY:
	li $t1, 0x000000 # $t1 stores the black colour code
	move $t3, $s0
	
	li $t8 0
	CLEAR_BUNNY_LOOP:
	sw $t1, 0($t3) 
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 
	sw $t1, -32($t3) 
	sw $t1, -36($t3) 
	sw $t1, -40($t3) 
	sw $t1, -44($t3) 
	sw $t1, -48($t3) 
	sw $t1, -52($t3) 
	subi $t3, $t3, 512
	addi $t8 $t8 1
	blt $t8 13 CLEAR_BUNNY_LOOP
	
	jr $ra
	
DRAW_BUNNY_HITBOX:

	#t3 contains current pixel address after movement, starting from bottom right
	move $t3, $s0
	add $t3 $t3 $s4
	li $t8 0
	HITBOX_BUNNY_LOOP:
	lw $t4 0($t3)
	beq $t4 RED INVALID_DRAW
	bne $t4 ORANGE SKIP_UPDATE_CARROT_TWO
	la $t0 CARROT_TWO
	li $t5 1
	sw $t5 0($t0)
	
	SKIP_UPDATE_CARROT_TWO:
	
	
	lw $t4 -56($t3)
	beq $t4 RED INVALID_DRAW
	bne $t4 BLUE SKIP_UPDATE_CARROT_THREE
	la $t0 CARROT_THREE
	li $t5 1
	sw $t5 0($t0)
	
	SKIP_UPDATE_CARROT_THREE:
	bne $t4 GREEN SKIP_UPDATE_CARROT_ONE
	la $t0 CARROT_ONE
	li $t5 1
	sw $t5 0($t0)
	
	SKIP_UPDATE_CARROT_ONE:
	subi $t3, $t3, 512
	addi $t8 $t8 1
	blt $t8 13 HITBOX_BUNNY_LOOP

	jr $ra
	
DRAW_CARROT:
	li $t1, ORANGE # $t1 stores the orange colour code
	li $t2, GREEN # $t2 stores the green colour code
	move $t3, $a0 # $t3 stores the bottom right pixel of carrot
	#row 1
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 		
	subi $t3, $t3, 512
	
	#row 2 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 	
	sw $t1, -32($t3) 	
	subi $t3, $t3, 512
	
	#row 3 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 		
	subi $t3, $t3, 512
	
	#row 4 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 	
	subi $t3, $t3, 512
	
	#row 5
	sw $t2, -4($t3) 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	subi $t3, $t3, 512
	
	#row 6
	sw $t2, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 	
	subi $t3, $t3, 512
	
	#row 7
	sw $t2, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 	
	subi $t3, $t3, 512
	
	#row 8
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 	
	subi $t3, $t3, 512
	
	#row 9
	sw $t2, -8($t3) 
	subi $t3, $t3, 512
	
	jr $ra

DRAW_CARROT_BLUE:
	li $t1, ORANGE # $t1 stores the orange colour code
	li $t2, BLUE # $t2 stores the green colour code
	move $t3, $a0 # $t3 stores the bottom right pixel of carrot
	#row 1
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 		
	subi $t3, $t3, 512
	
	#row 2 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 	
	sw $t1, -32($t3) 	
	subi $t3, $t3, 512
	
	#row 3 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 
	sw $t1, -28($t3) 		
	subi $t3, $t3, 512
	
	#row 4 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	sw $t1, -24($t3) 	
	subi $t3, $t3, 512
	
	#row 5
	sw $t2, -4($t3) 
	sw $t1, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 
	sw $t1, -20($t3) 
	subi $t3, $t3, 512
	
	#row 6
	sw $t2, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t1, -12($t3) 
	sw $t1, -16($t3) 	
	subi $t3, $t3, 512
	
	#row 7
	sw $t2, 0($t3) 
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 
	sw $t2, -12($t3) 	
	subi $t3, $t3, 512
	
	#row 8
	sw $t2, -4($t3) 
	sw $t2, -8($t3) 	
	subi $t3, $t3, 512
	
	#row 9
	sw $t2, -8($t3) 
	subi $t3, $t3, 512
	
	jr $ra
	
CLEAR_CARROT:
	li $t0 BLACK
	move $t3, $a0
	
	li $t9 0
	CLEAR_CARROT_LOOP:
	sw $t0, 0($t3) 
	sw $t0, -4($t3) 
	sw $t0, -8($t3) 
	sw $t0, -12($t3) 
	sw $t0, -16($t3) 
	sw $t0, -20($t3) 
	sw $t0, -24($t3) 
	sw $t0, -28($t3) 
	sw $t0, -28($t3) 	
	sw $t0, -32($t3) 
	subi $t3, $t3, 512
	addi $t9 $t9 1
	blt $t9 13 CLEAR_CARROT_LOOP
	
	jr $ra
	
DRAW_START_MENU:
	li $t2, WHITE # $t2 stores the white colour code
	li $t0, BASE_ADDRESS
	
	#draw START
	addi $t0 $t0 10436 #t0 holds top left pixel address of START
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 24($t0) 
	sw $t2, 28($t0) 
	sw $t2, 32($t0) 
	sw $t2, 36($t0) 
	sw $t2, 40($t0) 
	sw $t2, 52($t0) 
	sw $t2, 68($t0) 
	sw $t2, 72($t0) 
	sw $t2, 76($t0) 
	sw $t2, 80($t0) 
	sw $t2, 92($t0) 
	sw $t2, 96($t0) 
	sw $t2, 100($t0) 
	sw $t2, 104($t0) 
	sw $t2, 108($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	sw $t2, 32($t0) 
	sw $t2, 48($t0) 
	sw $t2, 56($t0) 
	sw $t2, 68($t0) 
	sw $t2, 84($t0) 
	sw $t2, 100($t0) 
	
	addi $t0, $t0, 512
	#row 3
	sw $t2, 0($t0) 
	sw $t2, 32($t0) 
	sw $t2, 48($t0) 
	sw $t2, 56($t0) 
	sw $t2, 68($t0) 
	sw $t2, 84($t0) 
	sw $t2, 100($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 32($t0) 
	sw $t2, 44($t0) 
	sw $t2, 60($t0) 
	sw $t2, 68($t0) 
	sw $t2, 72($t0) 
	sw $t2, 76($t0) 
	sw $t2, 80($t0) 
	sw $t2, 100($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 16($t0) 
	sw $t2, 32($t0) 
	sw $t2, 44($t0) 
	sw $t2, 48($t0) 
	sw $t2, 52($t0) 
	sw $t2, 56($t0) 
	sw $t2, 60($t0) 
	sw $t2, 68($t0) 
	sw $t2, 76($t0) 
	sw $t2, 100($t0) 

	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0)  
	sw $t2, 16($t0) 
	sw $t2, 32($t0) 
	sw $t2, 44($t0) 
	sw $t2, 60($t0) 
	sw $t2, 68($t0) 
	sw $t2, 80($t0) 
	sw $t2, 100($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 32($t0) 
	sw $t2, 44($t0) 
	sw $t2, 60($t0) 
	sw $t2, 68($t0) 
	sw $t2, 84($t0) 
	sw $t2, 100($t0)
	
	#draw EXIT
	li $t0, BASE_ADDRESS
	addi $t0 $t0 23236 #t0 holds top left pixel address of EXIT

	#row 1
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	sw $t2, 24($t0) 
	sw $t2, 40($t0) 
	sw $t2, 48($t0) 
	sw $t2, 52($t0) 
	sw $t2, 56($t0) 
	sw $t2, 64($t0) 
	sw $t2, 68($t0) 
	sw $t2, 72($t0) 
	sw $t2, 76($t0) 
	sw $t2, 80($t0)
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 24($t0) 
	sw $t2, 40($t0) 
	sw $t2, 52($t0) 
	sw $t2, 72($t0) 
	
	addi $t0, $t0, 512
	#row 3
	sw $t2, 0($t0) 
	sw $t2, 28($t0) 
	sw $t2, 36($t0) 
	sw $t2, 52($t0) 
	sw $t2, 72($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 32($t0) 
	sw $t2, 52($t0) 
	sw $t2, 72($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 0($t0) 
	sw $t2, 28($t0) 
	sw $t2, 36($t0) 
	sw $t2, 52($t0) 
	sw $t2, 72($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 24($t0) 
	sw $t2, 40($t0) 
	sw $t2, 52($t0) 
	sw $t2, 72($t0) 
	
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	sw $t2, 24($t0) 
	sw $t2, 40($t0) 
	sw $t2, 48($t0) 
	sw $t2, 52($t0) 
	sw $t2, 56($t0) 
	sw $t2, 72($t0) 
	
	jr $ra
	
DRAW_ARROW:
	li $t2, WHITE # $t2 stores the white colour code
	li $t0, BASE_ADDRESS
	
	beq $t4 1 DRAW_ON_START
	addi $t0 $t0 23848
	j DRAW_ON_EXIT
	
	DRAW_ON_START:
	addi $t0 $t0 11076
	
	DRAW_ON_EXIT:
	
	#row 1
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 4($t0) 
	
	addi $t0, $t0, 512
	#row 3
	sw $t2, 0($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 4($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	
	jr $ra
	
CLEAR_ARROW:
	li $t2, 0x000000 # $t2 stores the black colour code
	li $t0, BASE_ADDRESS
	
	beq $t4 0 DRAW_ON_START_CLEAR
	addi $t0 $t0 23848
	j DRAW_ON_EXIT_CLEAR
	
	DRAW_ON_START_CLEAR:
	addi $t0 $t0 11076
	
	DRAW_ON_EXIT_CLEAR:
	
	#row 1
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 4($t0) 
	
	addi $t0, $t0, 512
	#row 3
	sw $t2, 0($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 4($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	
	jr $ra

PRINT_TIMER:
	
	move $t8 $ra
	
	#load address of first and second digit
	
	li $t0, BASE_ADDRESS
	addi $t0 $t0 1976 #t0 holds top left pixel address of number
	
	blt $s5 370 DRAW_FIVE_J
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 1976
	blt $s5 740 DRAW_FOUR_J
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 1976
	blt $s5 1110 DRAW_THREE_J
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 1976
	blt $s5 1480 DRAW_TWO_J
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 1976
	blt $s5 1850 DRAW_ONE_J
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 1976
	blt $s5 2220 DRAW_ZERO_J
	
	DRAW_FIVE_J:
	jal DRAW_FIVE
	move $t4 $s5
	j DRAW_SECOND_DIGIT
	DRAW_FOUR_J:
	jal DRAW_FOUR
	sub $t4 $s5 370
	j DRAW_SECOND_DIGIT
	DRAW_THREE_J:
	jal DRAW_THREE
	sub $t4 $s5 740
	j DRAW_SECOND_DIGIT
	DRAW_TWO_J:
	jal DRAW_TWO
	sub $t4 $s5 1110
	j DRAW_SECOND_DIGIT
	DRAW_ONE_J:
	jal DRAW_ONE
	sub $t4 $s5 1480
	j DRAW_SECOND_DIGIT
	DRAW_ZERO_J:
	jal DRAW_ZERO
	sub $t4 $s5 1850
	j DRAW_SECOND_DIGIT
	
	
	DRAW_SECOND_DIGIT:
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	
	
	blt $t4 37 DRAW_NINE_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 74 DRAW_EIGHT_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 111 DRAW_SEVEN_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 148 DRAW_SIX_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 185 DRAW_FIVE_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 222 DRAW_FOUR_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 259 DRAW_THREE_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 296 DRAW_TWO_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 333 DRAW_ONE_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	blt $t4 368 DRAW_ZERO_J2
	jal CLEAR_NUMBER
	li $t0, BASE_ADDRESS
	addi $t0 $t0 2008
	
	
	DRAW_NINE_J2:
	jal DRAW_NINE
	j END_TIMER
	DRAW_EIGHT_J2:
	jal DRAW_EIGHT
	j END_TIMER
	DRAW_SEVEN_J2:
	jal DRAW_SEVEN
	j END_TIMER
	DRAW_SIX_J2:
	jal DRAW_SIX
	j END_TIMER
	DRAW_FIVE_J2:
	jal DRAW_FIVE
	j END_TIMER
	DRAW_FOUR_J2:
	jal DRAW_FOUR
	j END_TIMER
	DRAW_THREE_J2:
	jal DRAW_THREE
	j END_TIMER
	DRAW_TWO_J2:
	jal DRAW_TWO
	j END_TIMER
	DRAW_ONE_J2:
	jal DRAW_ONE
	j END_TIMER
	DRAW_ZERO_J2:
	jal DRAW_ZERO
	j END_TIMER
	
	END_TIMER:
	jr $t8

CLEAR_NUMBER:
	li $t2, BLACK # $t2 stores the black colour code
	
	li $t9 0
	CLEAR_NUMBER_LOOP:
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	addi $t0, $t0, 512
	addi $t9 $t9 1
	blt $t9 7 CLEAR_NUMBER_LOOP
	
	jr $ra
	
DRAW_ONE:
	li $t2, WHITE # $t2 stores the white colour code
	
	
	#draw 1
	
	
	#row 1
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	
	jr $ra
DRAW_TWO:
	
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 4($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	
	jr $ra
DRAW_THREE:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	jr $ra
DRAW_FOUR:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 4($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 0($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 12($t0) 
	
	jr $ra
DRAW_FIVE:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 0($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	jr $ra
DRAW_SIX:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 0($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	jr $ra
DRAW_SEVEN:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 8($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 4($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 0($t0) 
	
	jr $ra
DRAW_EIGHT:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	jr $ra
DRAW_NINE:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	jr $ra
DRAW_ZERO:
	li $t2, WHITE # $t2 stores the white colour code
	
	#row 1
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	addi $t0, $t0, 512
	#row 2
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 3 
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 4
	sw $t2, 0($t0) 
	sw $t2, 8($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 5
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 6
	sw $t2, 0($t0) 
	sw $t2, 16($t0) 
	
	addi $t0, $t0, 512
	#row 7
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	
	jr $ra

CLEAR_SCREEN:
	#clear screen
	li $t9, BASE_ADDRESS
	addi $t9 $t9 131072
	li $t1, 0x000000 #load black colour
	li $t8, BASE_ADDRESS
	CLEAR_SCREEN_LOOP:
	sw $t1, 0($t8) 
	bgt $t8 $t9 CLEAR_DONE	
	addi $t8 $t8 4
	j CLEAR_SCREEN_LOOP
	CLEAR_DONE:
	jr $ra
	
EXIT:
	jal CLEAR_SCREEN
	#exit
	li $v0, 10
	syscall

