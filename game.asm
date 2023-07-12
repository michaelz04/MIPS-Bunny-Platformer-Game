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
	
MAINLOOP: #main loop for game 
	
	#check keyboard input
	li $t9, 0xffff0000
	lw $t8, 4($t9)
	beq $t8, 0x70, EXIT #if key = p, exit
	beq $t8, 0x77, UP #if key = w, go up
	beq $t8, 0x73, DOWN #if key = s, go down
	
	li $t1, 0xff0000 # $t1 stores the red colour code
	li $t2, 0x00ff00 # $t2 stores the green colour code
	li $t3, 0x0000ff # $t3 stores the blue colour code
	
	sw $t1, 0($t0) # paint the first (top-left) unit red.
	sw $t2, 128($t0) # paint the second unit on the first row green. Why $t0+4?
	sw $t3, 512($t0) # paint the first unit on the second row blue. Why +256?
	
	addi $t0, $t0, 4
	
	#sleep
	li $v0, 32
	li $a0, 40 # Wait 40ms
	syscall

	j MAINLOOP

UP:
	addi $t0, $t0, 4
	j MAINLOOP
DOWN:
	addi $t0, $t0, 4
	li $t8, 0 #reset input
	j MAINLOOP
	
	
EXIT:
	#exit
	li $v0, 10
	syscall
