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
.eqv 	SLEEP_MS 	33

.eqv 	BORDER_HEIGHT	500
.eqv	BORDER_WIDTH	500
.eqv	DISPLAY_WIDTH	512
.eqv	DISPLAY_HEIGHT	63
.eqv	BUNNY_WIDTH	14
.eqv 	BUNNY_HEIGHT	13
.eqv	BUNNY_MAX_HEIGHT	7220  #14 * 512 + 13*4
.eqv	BUNNY_MIN_HEIGHT	31744  #62 * 512

.text

main:
	li $t0, BASE_ADDRESS
	addi $t4, $t0, BUNNY_MAX_HEIGHT	#################   $t4 stores bottom left pixel address of sprite
	
	#clear screen
	li $t9, BASE_ADDRESS
	addi $t9 $t9 131072
	li $t1, 0x000000 #load black colour
	li $t8, BASE_ADDRESS
CLEAR_SCREEN:
	sw $t1, 0($t8) 
	bgt $t8 $t9 CLEAR_DONE	
	addi $t8 $t8 4
	j CLEAR_SCREEN	
CLEAR_DONE:
	
	#draw bottom platform

	li $t8, DISPLAY_WIDTH
	li $t9, DISPLAY_HEIGHT
	mult $t8 $t9
	mflo $t8
	add $t8 $t0 $t8
	
	li $t1, 0xff0000 # $t1 stores the green colour code
	li $t2, 0xffffff # $t2 stores the white colour code
	
	li $t9, 0
	li $t7, 128
BOTTOM_PLATFORM_LOOP:	
	sw $t1, 0($t8) 
	addi $t9, $t9, 1
	addi $t8, $t8, 4
	beq $t9, $t7, BOTTOM_DRAWN
	j BOTTOM_PLATFORM_LOOP
BOTTOM_DRAWN:	
	
	


MAINLOOP: #main loop for game 
	
	
	
	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x70, EXIT #if key = p, exit
	beq $t8, 0x77, UP #if key = w, go up
	beq $t8, 0x73, DOWN #if key = s, go down
	beq $t8, 0x61, LEFT #if key = w, go up
	beq $t8, 0x64, RIGHT #if key = s, go down
	
	#gravity
	li $t8, BUNNY_MIN_HEIGHT
	addi $t8, $t8, BASE_ADDRESS
	blt $t4, $t8, FALLING
	j SKIP_FALLING
FALLING:
	addi $t4, $t4, 512	
	li $v0, 32
	li $a0, 100
	syscall
	jal CLEAR_BUNNY
SKIP_FALLING:
	
	
	
	
	
	jal DRAW_BUNNY
	
	
	
	#sleep
	li $v0, 32
	li $a0, SLEEP_MS
	syscall

	j MAINLOOP
	
	



UP:
	sw $zero 4($t9)
	li $t8 10
	li $t9 0
	JUMP_LOOP:
	subi $t4, $t4, 512
	li $v0, 32
	li $a0, 100
	syscall
	addi $t9 $t9 1
	jal DRAW_BUNNY
	bne $t8 $t9 JUMP_LOOP
	jal CLEAR_BUNNY
	j MAINLOOP
DOWN:
	sw $zero 4($t9)
	addi $t4, $t4, 512
	#check if bunny is in boundaries
	li $t8, BUNNY_MIN_HEIGHT
	addi $t8, $t8, BASE_ADDRESS
	bgt $t4, $t8, SUB_DOWN
	j SKIP_SUB_DOWN
	SUB_DOWN: subi $t4, $t4, 512
	SKIP_SUB_DOWN:
	jal CLEAR_BUNNY
	j MAINLOOP

LEFT:
	sw $zero 4($t9)
	subi $t4, $t4, 4
	jal CLEAR_BUNNY
	j MAINLOOP
RIGHT:
	sw $zero 4($t9)
	addi $t4, $t4, 4
	#check if bunny is in boundaries
	li $t8 BUNNY_MIN_HEIGHT
	addi $t8 $t8 BASE_ADDRESS
	bgt $t4, $t8, SUB_RIGHT
	j SKIP_SUB_RIGHT
	SUB_RIGHT: subi $t4, $t4, 4
	SKIP_SUB_RIGHT:
	jal CLEAR_BUNNY
	j MAINLOOP



#draw bunny facing left
#start from bottom right, to left
#$t4 will contain the bottom right corner address of bunny sprite
DRAW_BUNNY:	
	li $t1, 0x000000 # $t1 stores the black colour code
	li $t2, 0xffffff # $t2 stores the white colour code
	move $t3, $t4
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

	
	jr $ra

CLEAR_BUNNY:
	li $t1, 0x000000 # $t1 stores the black colour code
	li $t2, 0xffffff # $t2 stores the white colour code
	move $t3, $t4
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

	
	jr $ra
EXIT:
	#exit
	li $v0, 10
	syscall
	
	
DRAWBUNNY:	
	move $t3, $t4
	#row 1
	sw $t1, 0($t3) 
	sw $t1, -8($t3) 
	
	subi $t3, $t3, 512
	#row 2
	sw $t1, -4($t3) 
	
	subi $t3, $t3, 512
	#row 3
	sw $t1, 0($t3)
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	
	subi $t3, $t3, 512
	#row 4
	sw $t1, -4($t3) 
	
	subi $t3, $t3, 512
	#row 5
	sw $t1, 0($t3)
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
	
	subi $t3, $t3, 512
	#row 6
	sw $t1, 0($t3)
	sw $t1, -4($t3) 
	sw $t2, -8($t3) 
	
	subi $t3, $t3, 512
	#row 7
	sw $t1, 0($t3)
	sw $t1, -4($t3) 
	sw $t1, -8($t3) 
