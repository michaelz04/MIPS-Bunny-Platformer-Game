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

.eqv 	BASE_ADDRESS 0x10008000

.text

main:
	li $t0, BASE_ADDRESS
	addi $t3, $t0, 10000
	
MAINLOOP: #main loop for game 
	
	li $t0, BASE_ADDRESS
	addi $t3, $t0, 10000
	
	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x70, EXIT #if key = p, exit
	beq $t8, 0x77, UP #if key = w, go up
	beq $t8, 0x73, DOWN #if key = s, go down
	beq $t8, 0x61, LEFT #if key = w, go up
	beq $t8, 0x64, RIGHT #if key = s, go down
	
	li $t1, 0x000000 # $t1 stores the black colour code
	li $t2, 0xffffff # $t2 stores the white colour code
	j DRAW_BUNNY
	
	#sleep
	li $v0, 32
	li $a0, 20 # Wait 40ms
	syscall

	j MAINLOOP
	
	#draw bunny facing left
	#start from bottom right, to left
	#$t3 will contain the bottom right corner address of bunny sprite

DRAW_BUNNY:	
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
	
	j MAINLOOP

UP:
	subi $t0, $t0, 512
	sw $zero 4($t9)
	j MAINLOOP
DOWN:
	addi $t0, $t0, 512
	sw $zero 4($t9)
	j MAINLOOP

LEFT:
	subi $t0, $t0, 4
	sw $zero 4($t9)
	j MAINLOOP
RIGHT:
	addi $t0, $t0, 4
	sw $zero 4($t9)
	j MAINLOOP
	
EXIT:
	#exit
	li $v0, 10
	syscall
