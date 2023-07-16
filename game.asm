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
# - Display width in pixels: 256 (update this as needed)
# - Display height in pixels: 256 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# (See the assignment handout for descriptions of the milestones)
# - Milestone 1/2/3 (choose the one the applies)
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

.globl main

.eqv 	BASE_ADDRESS 	0x10008000
.eqv 	SLEEP_MS 	40

.eqv 	BORDER_HEIGHT	500
.eqv	BORDER_WIDTH	500
.eqv	DISPLAY_WIDTH	512
.eqv	DISPLAY_HEIGHT	63
.eqv	BUNNY_WIDTH	14
.eqv 	BUNNY_HEIGHT	13
.eqv	BUNNY_MAX_HEIGHT	7220  #14 * 512 + 13*4
.eqv	BUNNY_MIN_HEIGHT	31744  #62 * 512

.eqv 	OFFSET_BOTTOM_LEFT	-56    # $s0 + OFFSET_BOTTOM_LEFT is bottom left pixel address of sprite
.eqv 	OFFSET_TOP_LEFT		-6712  # $s0 + OFFSET_TOP_LEFT is top left pixel address of sprite
.eqv 	OFFSET_TOP_RIGHT	-6656  # $s0 + OFFSET_TOP_RIGHT is top right pixel address of sprite


.text

# IMPORTANT $S REGISTERS:
# $s0: bottom right pixel address of sprite
# $s1: if sprite jumping = 1, otherwise 0
# $s2: if sprite facing left = 1, otherwise 0
# $s3: jumping frame counter
# $s4: tracks net sprite position change
# $s5
# $s6
# $s7: tracks if sprite is in the air = 1, ie not standing on platform

main:
	#initialize $s registers
	li $s0, BASE_ADDRESS
	addi $s0, $s0, BUNNY_MAX_HEIGHT	#################   $s0 stores bottom left pixel address of sprite
	
	li $s1, 0
	li $s2, 0
	li $s3, 0
	li $s7, 0
	
	jal CLEAR_SCREEN
	li $t4 1 #t4 stores if arrow is on start (1) or on exit (0)
START_MENU_LOOP:

	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x70, EXIT #if key = p, exit
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
	
	li $t1, 0xff0000 # $t1 stores the green colour code
	li $t2, 0xffffff # $t2 stores the white colour code
	
	li $t9, 0
	BOTTOM_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	beq $t9, 128, BOTTOM_DRAWN
	j BOTTOM_PLATFORM_LOOP
	BOTTOM_DRAWN:	
	
	


MAIN_LOOP: #main loop for game 
	
	li $s4 0 #load net position change
	
	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x70, EXIT #if key = p, exit
	beq $t8, 0x77, UP #if key = w, go up
	beq $t8, 0x73, DOWN #if key = s, go down
	beq $t8, 0x61, LEFT #if key = a, go left
	beq $t8, 0x64, RIGHT #if key = d, go right
	
	AFTER_KEY_PRESS:
	
	#check for collisions
	
	#check if on ground for now
	
	
	#if jumping
	beq $s1 1 JUMPING
	j SKIP_JUMPING
	JUMPING:
	subi $s4, $s4, 512
	li $v0, 32
	li $a0, 30
	syscall	
	#check number of jumping frames
	beq $s3 20 RESET_JUMP
	j SKIP_RESET_JUMP

	RESET_JUMP:
	li $s1 0
	li $s3 0
	
	SKIP_RESET_JUMP:	
	addi $s3 $s3 1
	j SKIP_FALLING
	
	SKIP_JUMPING:
	#gravity
	li $t8, BUNNY_MIN_HEIGHT
	addi $t8, $t8, BASE_ADDRESS
	blt $s0, $t8, FALLING
	j SKIP_FALLING
	FALLING:
	addi $s0, $s0, 512	
	li $v0, 32
	li $a0, 30
	syscall
	
	SKIP_FALLING:
	
	
	
	j DRAW_BUNNY
	

	
	#sleep
	li $v0, 32
	li $a0, SLEEP_MS
	syscall

	j MAIN_LOOP
	
	



UP:
	sw $zero 4($t9)
	beq $s1 1 AFTER_KEY_PRESS
	li $s1 1
	j AFTER_KEY_PRESS
DOWN:
	sw $zero 4($t9)
	addi $s4, $s4, 512
	#check if bunny is in boundaries
	li $t8, BUNNY_MIN_HEIGHT
	addi $t8, $t8, BASE_ADDRESS
	bgt $s4, $t8, SUB_DOWN
	j SKIP_SUB_DOWN
	SUB_DOWN: subi $s4, $s4, 512
	SKIP_SUB_DOWN:
	
	j AFTER_KEY_PRESS

LEFT:
	jal CLEAR_BUNNY
	sw $zero 4($t9)
	subi $s4, $s4, 4
	li $s2 1
	j DRAW_BUNNY
	j AFTER_KEY_PRESS
RIGHT:
	jal CLEAR_BUNNY
	sw $zero 4($t9)
	addi $s4, $s4, 4
	li $s2 0
	j DRAW_BUNNY
	j AFTER_KEY_PRESS


BUNNY_STATE:
	

DRAW_BUNNY:
	#jal VALID_DRAW_BUNNY
	
	add $s0 $s0 $s4
	beq $s2 1 DRAW_BUNNY_LEFT
	j DRAW_BUNNY_RIGHT
	
VALID_DRAW_BUNNY:
	li $t8, BUNNY_MIN_HEIGHT
	addi $t8, $t8, BASE_ADDRESS
	add $t9 $s0 $s4 
	bgt $t9, $t8, MAIN_LOOP
	
	jr $ra
	
	
	
#draw bunny facing left
#start from bottom right, to left
#$s0 will contain the bottom right corner address of bunny sprite
DRAW_BUNNY_LEFT:	
	li $t1, 0x000000 # $t1 stores the black colour code
	li $t2, 0xffffff # $t2 stores the white colour code
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

DRAW_BUNNY_RIGHT:
	li $t1, 0x000000 # $t1 stores the black colour code
	li $t2, 0xffffff # $t2 stores the white colour code
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
	
	
DRAW_START_MENU:
	li $t2, 0xffffff # $t2 stores the white colour code
	li $t0, BASE_ADDRESS
	
	#draw START
	addi $t0 $t0 10436 #t0 holds top left pixel address of START
	#row 1
	#sw $t2, 0($t0) 
	sw $t2, 4($t0) 
	sw $t2, 8($t0) 
	sw $t2, 12($t0) 
	#sw $t2, 16($t0) 
	#sw $t2, 20($t0) 
	sw $t2, 24($t0) 
	sw $t2, 28($t0) 
	sw $t2, 32($t0) 
	sw $t2, 36($t0) 
	sw $t2, 40($t0) 
	#sw $t2, 44($t0) 
	#sw $t2, 48($t0) 
	sw $t2, 52($t0) 
	#sw $t2, 56($t0) 
	#sw $t2, 60($t0) 
	#sw $t2, 64($t0) 
	sw $t2, 68($t0) 
	sw $t2, 72($t0) 
	sw $t2, 76($t0) 
	sw $t2, 80($t0) 
	#sw $t2, 84($t0) 
	#sw $t2, 88($t0) 
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
	li $t2, 0xffffff # $t2 stores the white colour code
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

