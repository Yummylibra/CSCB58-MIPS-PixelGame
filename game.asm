#####################################################################
#
# CSCB58 Winter 2023 Assembly Final Project
# University of Toronto, Scarborough
#
# Student: Qiushi Chen, Student Number: 1007622306, UTorID: chenq160, official email:johnsonqiu.chen@mail.utoronto.ca
#
# Bitmap Display Configuration:
# - Unit width in pixels: 8
# - Unit height in pixels: 8
# - Display width in pixels: 512
# - Display height in pixels: 512 (update this as needed)
# - Base Address for Display: 0x10008000 ($gp)
#
# Which milestones have been reached in this submission?
# 
# - Milestone 1,milestone 2 and milestone 3.
#	for milestone 1, I draw a 64*64 frambuffer, 6 platform with 4 steady lightblue platform, 1 moving green platform, and 1 "vanishing"
#	platform. The player can stand on lightblue, green and purple platform, but cannot stand on the vanished platform when it turns grey
#	there are 3 objects in total. 2 enemies(green&red) and a moving fire wheel
#	for milestone 2, the player can move left, right and upwards, and automatically falls down when in the air
#	player can step on steady lightblue platform, moving green platform, purple platform when it is not grey
#	when player collision with red wheel and enemy and the red_hell at the bottom of the screen, the player would get hurt.
#	player will change colour and deduce 1 heart. 
#	For milestone 3, i completed:
#	A. heart shown at the left bottome of the screen and would update
#	B. the game will fail when player run out of all heart
#	C. the game will win if player reached to the yellow-blue door at the top-left of the screen
#	D. the enemy will move <- and  -> when they are not "knocked off" by the player
#	E. the green platform will move <- and  ->
#	F. The purple platform will "disappear", which is turn grey and is no longer able to sustain the player.
#	K. the player is able to do 1 more jump in the air, but will not keep jumping infinitely. The player can jump at max twice.(double jump)
#	M.start menu. when entering the game, the player can choose wether "start" or "exit" the game by using w and s
#	P. when player jumps onto the head of the enemies, the enemies would be knocked off and turn grey&white. During which time,
#	they will not move and will do no harm to the player

# Link to video demonstration for final submission:
# - (https://play.library.utoronto.ca/watch/d0a6a61c303ab77f3366ce5009cbffc4). Make sure we can view it!
#
# Are you OK with us sharing the video with people outside course staff?
# - no, I changed my mind. I will not share the video nor code.
#
# Any additional information that the TA needs to know:
# -PLZ give full mark~~ thank you
#
#####################################################################

# defined CONSTANTS
.eqv	DISPLAY_FIRST_ADDRESS	0x10008000					#$gp THE FIRST DISPLAY ADDRESS
# width = 64, height = 64
.eqv	DISPLAY_LAST_ADDRESS	0x1000bFFC					# update this given the values below shift +(64*63+63)*4
.eqv	PLAYER_LAST_ADDRESS	0x1000baf8					# set the lase address the player
# entity initial coordinate
.eqv	DOOR			0x10008c0c					#set the coordinate of the door of victory
.eqv	UPPER_BLUE		0x10009400					#set the coordinate of the upper steady platform
.eqv	LOWER_BLUE		0x1000b200					#set the coordinate of the lower steady platform
.eqv	WHEEL_UP		0x10008e50					#set the uppermose position of the fire wheel
.eqv	WHEEL_LOW		0x1000a350					#set the lowest position of the fire wheel
.eqv	GREEN_LEFT		0x1000a378					# set the leftmost position of the dynamic platform
.eqv	GREEN_RIGHT		0x1000a3c8					#set the rightmost position of the dynamic platform
.eqv	HELL			0x1000bb00					#set the position of the ocean of fire
.eqv	VANISH_WALL		0x1000b2d4					#set the position of the purple=grey wall
.eqv	ENEMY_A_LEFT		0x10009078					#set the rightmost position of the enemyA
.eqv	ENEMY_A_RIGHT		0x100090A0
.eqv	ENEMY_B_LEFT		0x1000AE78
.eqv	ENEMY_B_RIGHT		0x1000aea0
.eqv	INITIAL_PLAYER		0x1000ae10					#set the initial position of the player
.eqv	LIVE_POSITION		0x1000bd0c					#set the position where the heart of player is drawed
.eqv	YOU_POSITION		0x10008C38					#set the position where YOU is printed
.eqv	WIN_POSITION		0x1000a340					#set the position where WIN is printed
.eqv	LOSE_POSITION		0x1000A33C					#set the position where LOSE is printed
# last address shifts
.eqv	SHIFT_NEXT_ROW		256						# next row shift = width*4 = 64*4

# moving statics
.eqv	GRAVITY			256						#speed change 1 unit per tick when falling



# Colors
.eqv	RED		0xff0000
.eqv	GREEN		0x00ff00
.eqv	BLUE		0x0000ff
.eqv	LIGHTBLUE	0x00f4ff
.eqv	BLACK		0x000000
.eqv	YELLOW		0xe3ff00
.eqv	PURPLE		0X9500ff
.eqv	GREY		0x676767
.eqv	WHITE		0xffffff
.eqv	PINK		0xfa00ff

#start-exit menu variables
.data
STARTOREXIT:	.word 1 #1 for start, 0 for exit
EXECUTEMENU:	.word 0 # 0 for not jump 1 for jump

# game_scene variables
TICK:	.word 0 # max value is 100, after reaching to 100, set to 0 on next update

PLATFORMVANISH:		.word 1 #0 for platform can be stand on, 1 for disappeared
PLATFORMGORIGHT:		.word 4 #4 for going right, -4 for going left
WHEELGOUP:		.word -SHIFT_NEXT_ROW #-SHIFT_NEXT_ROW for going up, SHIFT_NEXT_ROW for going down

ENEMYADOWN:		.word 0 # 0 for enemy A is active, 1 for enemy is sleeping
ENEMYBDOWN:		.word 0 # 0 for enemy B is active, 1 for enemy is sleeping
ENEMYASLEEPTIME:	.word 10# when A is sleeping, it sleep for 10 times of updates
ENEMYBSLEEPTIME:	.word 10# when B is sleeping, it sleep for 10 times of updates
ENEMYAGORIGHT:		.word 4 #4 for enemy A is moving right,-4 for enemy A is moving left
ENEMYBGORIGHT:		.word 4 #4 for enemy B is moving right, -4 for enemy B is moving left


PLAYERHURT:		.word 0 # 0 for player is not hurted, 1 for player is being hurted
PLAYERHURTTIME:		.word 18 # when player is hurted, it cannot be hurted anymore
LIVES:			.word 3 # number of lives

Y_SPEED:		.word 0 # Stands for the vertical speed of player. <= max_fall_speed
PLAYERFALL:		.word 0 # 0 for player is not falling, 1 for player is falling


PLAYERJUMP:		.word 0 # 0 for player is not jumping(asending), 1 for player is jumping
PLAYERJUMPTIME:		.word 23 #will reset once reach to 0 or player input w and jumped time <=2

JUMPEDTIME:		.word 0 # number of time player already jumped, + 1 <2

WINORLOSE:		.word -1# 1 for win, 0 for lose, -1 for neither

#global variables:
#s0:previous player position
#s1,current_player position
#s2,green_wall position
#s3,red_wheel position
#s4,upper enemy position
#s5,lower enemy position

.text
.globl initialize_menu
# ------------------------------------# ------------start menu scene------------------# ------------------------------------
initialize_menu:# clear screen
	li	$a0, DISPLAY_FIRST_ADDRESS
	li	$a1, DISPLAY_LAST_ADDRESS
	li	$a2, -SHIFT_NEXT_ROW						# negative width
	jal	clear								# jump to clear and save position to $ra

	li $a1,GREEN#draw initial menu
	jal draw_start
	li $a1,BLUE
	jal draw_exit

	la $t0,STARTOREXIT# set initial value for STARTOREXIT and EXECUTEMENU
	addi $t1,$zero,1
	sw $t1,0($t0)
	la $t0,EXECUTEMENU
	sw $zero,0($t0)
	
startmenu_loop:
	li	$a0, 0xffff0000
	lw	$t9, 0($a0)
	bne	$t9, 1, startmenu_update
	jal	menu_keypress
					# jump to keypress and save position to $ra
startmenu_update:

	la $t0,EXECUTEMENU
	lw $t1,0($t0)
	addi $t2,$zero,1
	beq $t1,$t2, execute_selection
	la $t0,STARTOREXIT
	lw $t1,0($t0)
	beq $t1,$zero, exit_selected

	start_selected:
		li $a1,GREEN
		jal draw_start
		li $a1,BLUE
		jal draw_exit
		j startmenu_sleep
	exit_selected:
		li $a1,BLUE
		jal draw_start
		li $a1,GREEN
		jal draw_exit
		j startmenu_sleep
	execute_selection:
		la $t0,STARTOREXIT
		lw $t1,0($t0)
		beq $t1,$zero,game_end
		b main_initialize


startmenu_sleep:
	# Wait one second (20 milliseconds)
	# decremennt if 
	li	$v0, 32
	li	$a0, 100
	syscall
	
	j startmenu_loop
# ------------------------------------# ---------------Main scene----------------# ------------------------------------
main_initialize:
	
	jal	clear #clear the screen
	
	li	$s0,INITIAL_PLAYER #initialize every variable
	addi	$s0,$s0,4 # because the new player will only dran when player position updates, so we manually set s0 != s1 to initialize
	li	$s1,INITIAL_PLAYER
	li	$s2,GREEN_LEFT
	li	$s3,WHEEL_UP
	li	$s4,ENEMY_A_LEFT
	li	$s5,ENEMY_B_LEFT
	
	la	$t0,TICK
	la	$t1,PLAYERHURT
	la	$t2,Y_SPEED
	la	$t3,PLAYERFALL
	la	$t4,PLAYERJUMP
	la	$t5,JUMPEDTIME
	sw	$zero,0($t0)#set tick to 0
	sw	$zero,0($t1)
	sw	$zero,0($t2)
	sw	$zero,0($t3)
	sw	$zero,0($t4)
	sw	$zero,0($t5)
	
	la	$t0,PLATFORMVANISH
	li	$t1,1
	sw	$t1,0($t0)# set platformvanish to 1
	
	li	$t0,4
	la	$t1,PLATFORMGORIGHT
	la	$t2,ENEMYAGORIGHT
	la	$t3,ENEMYBGORIGHT
	sw	$t0,0($t1)# set platformgoright to 4
	sw	$t0,0($t2)
	sw	$t0,0($t3)
	
	la	$t0,WHEELGOUP
	li	$t1,-SHIFT_NEXT_ROW
	sw	$t1,0($t0)# set wheel go up to -shiftnextrow
	
	la	$t0,ENEMYADOWN
	la	$t1,ENEMYBDOWN
	sw	$zero,0($t0)
	sw	$zero,0($t1)
	
	la	$t0,ENEMYASLEEPTIME
	la	$t1,ENEMYBSLEEPTIME
	addi	$t2,$zero,10
	sw	$t2,0($t0)
	sw	$t2,0($t1)
	
	la	$t0,PLAYERHURTTIME
	addi	$t1,$zero,18
	sw	$t1,0($t0)
	
	la	$t0,LIVES
	addi	$t1,$zero,3
	sw	$t1,0($t0)
	
	la	$t0,PLAYERJUMPTIME
	addi	$t1,$zero,23
	sw	$t1,0($t0)
	
	la	$t0,WINORLOSE
	addi	$t1,$zero,-1
	sw	$t1,0($t0)
	
	

	#draw initial scene
	jal	draw_blue_walls
	jal	draw_door
	jal	draw_hell
	jal	draw_vanish_platform
	jal	draw_green_wall
	jal	draw_enemy_A
	jal	draw_enemy_B
	jal	draw_new_player

	
main_loop:
	addi	$t0,$zero,-1
	la	$t1,WINORLOSE
	lw	$t1,0($t1)
	bne	$t1,$t0,gameover_scene # when WINORLOSE is not -1, that means gameover
	li	$a0, 0xffff0000 # this address means the input
	lw	$t9, 0($a0)
	bne	$t9, 1, main_update
	jal	main_keypress


main_update:

	jal update_green_wall		#update the position of the green wall
	jal update_wheel		#update the position of the fire wheel
	jal update_vanish_wall		#update the state of the vanish wall
	jal update_A_sleep		#check if A is knocked off by the player
	jal update_enemy_A		#update the state, position and colour of the enemy A
	jal update_B_sleep
	jal update_enemy_B
	
	jal	update_player_hurt	# update if player is hurt
	jal	update_player_lives #update lives of player
	jal	update_player_hurt_time	 #since hurted player cannot be hurted, we are updating the CD of player being hurted
	
	jal	update_player_fall	#check if player is falling
	jal	update_jumped_times	#when player has jumped, it already jumped once, update, the jumped time of player to implement double jump
	jal	update_player_asend	#when player is jumping, make player asend, update the process of asending
	jal	update_y_speed		#check if player is on the ground(set speed to 0)/in the ocean of fire(stop falling)/
					#reached the top of the screen and modify the vetical speed such that the new position = s0 + Y_speed is not "invalid"
	jal	update_y_position	#update the s1, change player's position
	
	
	jal update_tick			#some actions(movement of enemy/platform) will update with regard to the tick, update the tick
	jal update_game_over		#check if the game is over
main_render:
#render new picture of the elements
	jal	clear_old_player
	jal	draw_hell
	jal	draw_lives
	jal 	draw_blue_walls
	jal	draw_door
	jal 	draw_green_wall
	jal 	draw_red_wheel
	jal	draw_vanish_platform
	jal	draw_enemy_A
	jal	draw_enemy_B

	jal	draw_new_player

main_sleep:
	# Wait one second (20 milliseconds)

	li	$v0, 32
	li	$a0, 50
	syscall
	
	j main_loop
	
	
gameover_scene:
	la	$t0,WINORLOSE
	lw	$t0,0($t0)
	beq	$t0,$zero,lose_scene
	win_scene:
		jal	draw_you_win
		j	game_end
	lose_scene:
		jal	draw_you_lose
		j	game_end

game_end:
# End program
li $v0, 10
syscall
# ------------------------------------# ------------------------------------# ------------------------------------
# ------------------------------------# --------------MY FUNCTIONS----------# ------------------------------------
# ------------------------------------# ------------------------------------# ------------------------------------
clear:
	li	$a1, BLACK
	li	$t0,DISPLAY_FIRST_ADDRESS
	li	$t1,DISPLAY_LAST_ADDRESS
	

	clear_loop:
		bgt	$t0, $t1, clear_loop_done

		sw	$a1,0($t0)
		addi	$t0,$t0,4
		j	clear_loop						# jump to clear_loop
	clear_loop_done:
		jr	$ra							# jump to $ra


# ------------------------------------# ------------------------------------# ------------------------------------
# ------------------------------------# --------keypress functions ---------# ------------------------------------
# ------------------------------------# ------------------------------------# ------------------------------------
main_keypress:
	

	li	$a0,0xffff0000		
	lw	$t0, 4($a0)
	beq	$t0, 0x61, key_a						# ASCII code of 'a' is 0x61 or 97 in decimal
	beq	$t0, 0x77, key_w						# ASCII code of 'w' is 0x77
	beq	$t0, 0x64, key_d						# ASCII code of 'd' is 0x64
	beq	$t0, 0x70, key_p						# ASCII code of 'p' is 0x70
	b	keypress_done
	# go left
	key_a:
		# make sure ship is not in left column		# $t9 = y
		addi	$t1,$s1,-DISPLAY_FIRST_ADDRESS# address right now - first address = 4*(64*x+y)
		addi	$t2,$zero,4
		div	$t1,$t2
		mflo	$t2 #t2 = 64*x + y
		addi	$t1,$zero,64
		div	$t2,$t1
		mflo	$t8	#t8 = x
		mfhi	$t9	#t9 = y
		
		addi	$t3,$zero,2
		ble	$t9, $t3, keypress_done				# if it is in the left column, we can't go left
		addi	$s1, $s1, -8						# else, move left
		b keypress_done

	# go up
	key_w:
		# make sure ship is not in top row
		addi	$t1,$s1,-DISPLAY_FIRST_ADDRESS# address right now - first address = 4*(64*x+y)
		addi	$t2,$zero,4
		div	$t1,$t2
		mflo	$t2 #t2 = 64*x + y
		addi	$t1,$zero,64
		div	$t2,$t1
		mflo	$t8	#t8 = x
		mfhi	$t9	#t9 = y
		ble	$t8, $zero, keypress_done					# if $s1 is in the top row, don't go up
		la	$t0,JUMPEDTIME
		lw	$t1,0($t0)
		addi	$t2,$zero,1
		bge	$t1,$t2,keypress_done #if already jumped twice, cannot keep jumping
		
		la	$t0,PLAYERJUMP				# else, start to jump
		addi	$t1,$zero,1
		sw	$t1,0($t0)
		la	$t0,PLAYERJUMPTIME	
		addi	$t1,$zero,23
		sw	$t1,0($t0)
		
		la	$t0,JUMPEDTIME			#and set jumpedtime ++
		lw	$t1,0($t0)
		addi	$t1,$t1,1
		sw	$t1,0($t0)
		b keypress_done

	# go right
	key_d:
		# make sure ship is not in right column
		addi	$t1,$s1,-DISPLAY_FIRST_ADDRESS# address right now - first address = 4*(64*x+y)
		addi	$t2,$zero,4
		div	$t1,$t2
		mflo	$t2 #t2 = 64*x + y
		addi	$t1,$zero,64
		div	$t2,$t1
		mflo	$t8	#t8 = x
		mfhi	$t9	#t9 = y
		addi	$t1, $zero, 60					# need to check if the mod is the row size - 12*4 (width of plane-1)
		bge	$t9, $t1, keypress_done					# if it is in the far right column, we can't go right
		addi	$s1, $s1, 8						# else, move right
		b keypress_done


	key_p:
		# restart game
		la	$ra, main_initialize
		b keypress_done

	keypress_done:
		jr	$ra							# jump to ra
# ------------------------------------# ------------------------------------# ------------------------------------
menu_keypress:

	lw	$t0, 4($a0)

	beq	$t0, 0x77, menu_key_w						# ASCII code of 'w' is 0x77
	beq	$t0, 0x73, menu_key_s						# ASCII code of 's' is 0x73
	beq	$t0, 0x0A, menu_key_enter						# ASCII code of 'enter' is 0x70
	b menu_keypress_done


	# go up
	menu_key_w:
		# make sure ship is not in top row
		la 	$t0,STARTOREXIT #t1 = addrs(STARTOREXIT)
		lw	$t1,0($t0)
		addi	$t2,$zero,1
		beq	$t2, $t1, menu_keypress_done					# if already selected start, do nothing
		sw	$t2,0($t0)			#else set STARTOREXIT to 1
		b menu_keypress_done

	# go down
	menu_key_s:
		la 	$t0,STARTOREXIT #t1 = addrs(STARTOREXIT)
		lw	$t1,0($t0)
		beq	$t1, $zero, menu_keypress_done			# if already selected EXIT, do nothing
		sw	$zero,0($t0)	#else set STARTOREXIT to 0
		b menu_keypress_done
		
	menu_key_enter:
		la 	$t1,EXECUTEMENU #t0 = addrs(STARTOREXIT)
		addi	$t2,$zero,1
		sw	$t2,0($t1)
		b menu_keypress_done
	menu_keypress_done:
		jr	$ra							# jump to ra
# ------------------------------------# ------------------------------------# ------------------------------------
# ------------------------------------# --------update_related function-----# ------------------------------------
# ------------------------------------# ------------------------------------# ------------------------------------
update_game_over:
	la	$t0,LIVES
	lw	$t1,0($t0)
	beq	$t1,$zero,losegame
	
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	
	addi	$sp,$sp,-4
	sw	$s1,0($sp)
	
	jal	check_player_win
	
	lw	$t1,0($sp)
	addi	$sp,$sp,4
	
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	
	bne	$t1,$zero,wingame
	b	update_game_over_end
	
	wingame:
		la	$t0,WINORLOSE
		addi	$t1,$zero,1
		sw	$t1,0($t0)
		b	update_game_over_end
	losegame:
		la	$t0,WINORLOSE
		sw	$zero,0($t0)
		b	update_game_over_end
	update_game_over_end:
		jr	$ra
check_player_win:
	lw	$t0,0($sp)
	
	li	$t2,BLUE
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win

	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win#ROW 1 of player checked
	
	addi	$t0,$t0,-8
	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win# row 2 of player checked
	
	addi	$t0,$t0,-8
	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win# row 3 of player checked
	
	addi	$t0,$t0,-8
	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win
	
	addi	$t0,$t0,4
	lw	$t1,0($t0)
	beq	$t1,$t2,player_win# row 4 of player checked
	
	player_donot_win:
		addi	$t3,$zero,0
		b	check_player_win_end
	player_win:
		addi	$t3,$zero,1
	
	check_player_win_end:
		sw	$t3,0($sp)
		jr	$ra
	

# ------------------------------------# ------------------------------------# ------------------------------------
update_tick:
	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t1,$t1,1
	addi	$t2,$zero,100
	bge	$t1,$t2,reset_tick
	j tick_update_end
	
	reset_tick:
	addi	$t1,$zero,0
	
	tick_update_end:
	sw	$t1,0($t0)
	jr	$ra
# ------------------------------------# ------------------------------------
update_y_position:
	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t2,$zero,2
	div	$t1,$t2
	mfhi	$t2
	beq	$t2,$zero,update_y_position_end # update y position every 2 tick
	
	la	$t0,Y_SPEED
	lw	$t1,0($t0)
	add	$s1,$s0,$t1
	update_y_position_end:
		jr	$ra
# ------------------------------------
update_player_asend:
	la	$t0,PLAYERJUMP
	lw	$t1,0($t0)
	beq	$t1,$zero,update_asend_end # if player is not jumping, no change on playerjumptime
	player_asending:
		la	$t0,PLAYERJUMPTIME
		lw	$t1,0($t0)
		addi	$t1,$t1,-1
		ble	$t1,$zero,reset_playerjumptime # if jumptime run out, reset jumptime and stop asending
		sw	$t1,0($t0)
		b	update_asend_end
	reset_playerjumptime:
		la	$t0,PLAYERJUMPTIME
		addi	$t1,$zero,20
		sw	$t1,0($t0) # reset playerjumptime
		la	$t0,PLAYERJUMP
		sw	$zero,0($t0) # set playerjump to 0, stop asending
	update_asend_end:
		jr	$ra

# ------------------------------------
update_y_speed:
	la	$t0,PLAYERJUMP
	lw	$t0,0($t0) # t0 = player jump
	bne	$t0,$zero,player_goes_up # if t0!=0, t0 = 1, then player should be asending if no overflow the frame
	la	$t1,PLAYERFALL # if player is not jumping, check if player is falling	
	lw	$t1,0($t1) #t1 is playerfall, 1 if player is falling, else 0
	bne	$t1,$zero,player_goes_down
	b	player_not_moving
	player_goes_up:
		la	$t1,Y_SPEED
		addi	$t2,$zero,-SHIFT_NEXT_ROW
		sw	$t2, 0($t1)
		b	check_position
	player_goes_down:
		la	$t1,Y_SPEED
		addi	$t2,$zero,GRAVITY
		sw	$t2,0($t1)
		b	check_position
	player_not_moving:
		la	$t1,Y_SPEED
		sw	$zero,0($t1)
	check_position:
	
	la	$t0,Y_SPEED
	lw	$t1,0($t0) #t1 = y_speed
	add	$t3,$t1,$s1 # t3 = y speed + current position = new position
	bgt	$t3,PLAYER_LAST_ADDRESS,low_overflow #if t3 is too big, then set y speed to 0
	blt	$t3,DISPLAY_FIRST_ADDRESS,high_overflow# if player has reach top, then set y speed to 0 and reset playerjump & playerjumptime
	b	update_y_speed_end
	
	low_overflow:
		la	$t0,Y_SPEED
		sw	$zero,0($t0)
		b	update_y_speed_end
	high_overflow:
		la	$t0,Y_SPEED
		sw	$zero,0($t0)
		la	$t1,PLAYERJUMP
		sw	$zero,0($t1)
		la	$t1,PLAYERJUMPTIME
		sw	$zero,0($t1)

	update_y_speed_end:
		jr	$ra
# ------------------------------------
update_jumped_times:
	la	$t0,PLAYERFALL
	lw	$t1,0($t0)
	beq	$t1,$zero,reset_jumped_time
	b	jumped_time_update_end
	reset_jumped_time:
	la	$t0,JUMPEDTIME
	sw	$zero,0($t0)
	jumped_time_update_end:
		jr	$ra
# ------------------------------------
update_player_fall:
	addi	$t0,$s1,SHIFT_NEXT_ROW
	addi	$t0,$t0,SHIFT_NEXT_ROW
	addi	$t0,$t0,SHIFT_NEXT_ROW
	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t4,0($t0)

	li	$t1,GREEN
	li	$t2,PURPLE
	li	$t3,LIGHTBLUE
	
	beq	$t4,$t1,is_solid
	beq	$t4,$t2,is_solid
	beq	$t4,$t3,is_solid

	lw	$t4,4($t0)
	beq	$t4,$t1,is_solid
	beq	$t4,$t2,is_solid
	beq	$t4,$t3,is_solid
	
	lw	$t4,8($t0)
	beq	$t4,$t1,is_solid
	beq	$t4,$t2,is_solid
	beq	$t4,$t3,is_solid
	is_not_solid:
		la	$t0,PLAYERFALL
		addi	$t4,$zero,1
		sw	$t4,0($t0)
		b	check_solid_end
	is_solid:
		la	$t0,PLAYERFALL
		sw	$zero,0($t0)
	check_solid_end:

	jr 	$ra
	

# ------------------------------------
update_player_hurt:
	addi	$t0,$s1,0
	
	li	$t2,RED
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_got_hurt


	lw	$t1,4($t0)
	beq	$t1,$t2,player_got_hurt
	

	lw	$t1,8($t0)
	beq	$t1,$t2,player_got_hurt#ROW 1 of player checked
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_got_hurt
	
	lw	$t1,4($t0)
	beq	$t1,$t2,player_got_hurt
	
	lw	$t1,8($t0)
	beq	$t1,$t2,player_got_hurt# row 2 of player checked
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_got_hurt

	lw	$t1,4($t0)
	beq	$t1,$t2,player_got_hurt
	

	lw	$t1,8($t0)
	beq	$t1,$t2,player_got_hurt# row 3 of player checked

	addi	$t0,$t0,SHIFT_NEXT_ROW
	
	lw	$t1,0($t0)
	beq	$t1,$t2,player_got_hurt
	
	lw	$t1,4($t0)
	beq	$t1,$t2,player_got_hurt
	
	lw	$t1,8($t0)
	beq	$t1,$t2,player_got_hurt# row 4 of player checked
	
	player_donot_hurt:
		b	update_player_hurt_end
	player_got_hurt:
		la	$t0,PLAYERHURT
		addi	$t3,$zero,1
		sw	$t3,0($t0)
	
	update_player_hurt_end:
	
	jr	$ra


# ------------------------------------
update_player_hurt_time:
	la	$t0,PLAYERHURTTIME
	lw	$t1,0($t0)
	ble	$t1,$zero,reset_player_hurt_time
	addi	$t1,$t1,-1
	
	j player_hurt_time_update_end

	reset_player_hurt_time: #once reset hurt time, Player will back to normal
	addi	$t1,$zero,18
	la	$t2,PLAYERHURT
	sw	$zero,0($t2)
	
	player_hurt_time_update_end:
	sw	$t1,0($t0)
	jr	$ra
# ------------------------------------
update_player_lives:
	la	$t0,PLAYERHURT
	lw	$t1,0($t0)	#t1 = playerhurt
	la	$t0,PLAYERHURTTIME
	lw	$t2,0($t0)	#t2 = playerhurttime
	addi	$t3,$zero,1
	# if t1 == 1 && t2 == 18, lives--
	la	$t0,LIVES	#t1 = addrs(lives)
	lw	$t5,0($t0)	#t5 = lives
	
	beq	$t1,$t3,player_is_hurted
	b	live_change_done
	
	player_is_hurted:
		addi	$t4,$zero,18
		beq	$t2,$t4,deduct_lives
		b	live_change_done

	deduct_lives:
		addi	$t5,$t5,-1
		sw	$t5,0($t0)
	live_change_done:
		jr	$ra
# -----------------------------------------------------------------------------------------------------------
update_A_sleep:
	addi	$t0,$s4,0
	addi	$t0,$t0,-SHIFT_NEXT_ROW
	li	$t1,YELLOW
		
	lw	$t2,0($t0)
	lw	$t3,4($t0)
	lw	$t4,8($t0)
	
	beq	$t1,$t2,A_is_down
	beq	$t1,$t3,A_is_down
	beq	$t1,$t4,A_is_down

	b	update_A_sleep_end
	A_is_down:
		la	$t0,ENEMYADOWN
		addi	$t5,$zero,1
		sw	$t5,0($t0)
	update_A_sleep_end:
		jr	$ra

update_enemy_A:

	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t2,$zero,2
	div	$t1,$t2
	mfhi	$t2
	beq	$t2,$zero,update_enemy_A_finished # update state of enemy A once every 2 tick
	
	la	$t0,ENEMYADOWN
	lw	$t0,0($t0)
	bne	$t0,$zero,A_is_sleeping 	# if enemyadown == 1, branch to A sleep

	enemy_A_position: 
	# if enemy a down == 0, change position of A
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	update_A_position
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	b	update_enemy_A_finished	
	
	A_is_sleeping:
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	update_A_sleep_time
	lw	$ra,0($sp)
	addi	$sp,$sp,4

	update_enemy_A_finished:
	jr	$ra

update_A_position:
	li	$t2,ENEMY_A_LEFT
	li	$t3,ENEMY_A_RIGHT
	beq	$s4,$t2,A_go_right
	beq	$s4,$t3,A_go_left
	
	b	A_move_start
	
	A_go_right:
	addi	$t4,$zero,4
	la	$t5,ENEMYAGORIGHT
	sw	$t4,0($t5)
	j	A_move_start
	
	A_go_left:
	addi	$t4,$zero,-4
	la	$t5,ENEMYAGORIGHT
	sw	$t4,0($t5)
	
	A_move_start:
	la	$t3,ENEMYAGORIGHT
	lw	$t4,0($t3)
	add	$s4,$s4,$t4
	
	A_move_end:
	jr	$ra 

update_A_sleep_time:
	la	$t0,ENEMYASLEEPTIME
	lw	$t1,0($t0)
	beq	$t1,$zero,reset_A_sleep_time
	
	addi	$t1,$t1,-1
	j A_sleeptime_update_end

	reset_A_sleep_time: #once A reset sleep time, A will awake
	addi	$t1,$zero,10
	la	$t2,ENEMYADOWN
	sw	$zero,0($t2)
	
	A_sleeptime_update_end:
	sw	$t1,0($t0)
	jr	$ra

# ------------------------------------# ------------------------------------# ------------------------------------
update_B_sleep:
	addi	$t0,$s5,0
	addi	$t0,$t0,-SHIFT_NEXT_ROW
	li	$t1,YELLOW
		
	lw	$t2,0($t0)
	lw	$t3,4($t0)
	lw	$t4,8($t0)
	
	beq	$t1,$t2,B_is_down
	beq	$t1,$t3,B_is_down
	beq	$t1,$t4,B_is_down

	b	update_B_sleep_end
	B_is_down:
		la	$t0,ENEMYBDOWN
		addi	$t5,$zero,1
		sw	$t5,0($t0)
	update_B_sleep_end:
		jr	$ra
update_enemy_B:

	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t2,$zero,2
	div	$t1,$t2
	mfhi	$t2
	beq	$t2,$zero,update_enemy_B_finished # update state of enemy A once every 2 tick
	
	la	$t0,ENEMYBDOWN
	lw	$t0,0($t0)
	bne	$t0,$zero,B_is_sleeping 	# if enemyadown == 1, branch to A sleep

	enemy_B_position: 
	# if enemy a down == 0, change position of A
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	update_B_position
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	b	update_enemy_B_finished	
	
	B_is_sleeping:
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	update_B_sleep_time
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	

	update_enemy_B_finished:
	jr	$ra

update_B_position:
	li	$t2,ENEMY_B_LEFT
	li	$t3,ENEMY_B_RIGHT
	beq	$s5,$t2,B_go_right
	beq	$s5,$t3,B_go_left
	
	b	B_move_start
	
	B_go_right:
	addi	$t4,$zero,4
	la	$t5,ENEMYBGORIGHT
	sw	$t4,0($t5)
	j	B_move_start
	
	B_go_left:
	addi	$t4,$zero,-4
	la	$t5,ENEMYBGORIGHT
	sw	$t4,0($t5)
	
	B_move_start:
	la	$t3,ENEMYBGORIGHT
	lw	$t4,0($t3)
	add	$s5,$s5,$t4
	
	B_move_end:
	jr	$ra 

update_B_sleep_time:
	la	$t0,ENEMYBSLEEPTIME
	lw	$t1,0($t0)
	beq	$t1,$zero,reset_B_sleep_time
	
	addi	$t1,$t1,-1
	j B_sleeptime_update_end

	reset_B_sleep_time: #once B reset sleep time, A will awake
	addi	$t1,$zero,10
	la	$t2,ENEMYBDOWN
	sw	$zero,0($t2)
	
	B_sleeptime_update_end:
	sw	$t1,0($t0)
	jr	$ra
# ------------------------------------# ------------------------------------# ------------------------------------
update_green_wall:
	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t2,$zero,2
	div	$t1,$t2
	mfhi	$t2
	
	
	beq	$t2,$zero,green_wall_position
	b	wall_move_end
	
	green_wall_position:
	li	$t2,GREEN_LEFT
	li	$t3,GREEN_RIGHT
	beq	$s2,$t2,green_go_right
	beq	$s2,$t3,green_go_left
	
	b	wall_move_start
	
	green_go_right:
	addi	$t4,$zero,4
	la	$t5,PLATFORMGORIGHT
	sw	$t4,0($t5)
	j	wall_move_start
	
	green_go_left:
	addi	$t4,$zero,-4
	la	$t5,PLATFORMGORIGHT
	sw	$t4,0($t5)

	j	wall_move_start
	
	wall_move_start:
	la	$t3,PLATFORMGORIGHT
	lw	$t4,0($t3)
	add	$s2,$s2,$t4
	
	wall_move_end:

	
	jr	$ra 
# ------------------------------------# ------------------------------------# ------------------------------------
update_wheel:
	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t2,$zero,2
	div	$t1,$t2
	mfhi	$t2
	
	beq	$t2,$zero,wheel_position
	b	wheel_move_end
	
	wheel_position:
	li	$t2,WHEEL_UP
	li	$t3,WHEEL_LOW
	beq	$s3,$t2,wheel_go_down
	beq	$s3,$t3,wheel_go_up
	
	b	wheel_move_start
	
	wheel_go_down:
	addi	$t4,$zero,SHIFT_NEXT_ROW
	la	$t5,WHEELGOUP
	sw	$t4,0($t5)
	j	wheel_move_start
	
	wheel_go_up:
	addi	$t4,$zero,-SHIFT_NEXT_ROW
	la	$t5,WHEELGOUP
	sw	$t4,0($t5)

	j	wheel_move_start
	
	wheel_move_start:
	la	$t3,WHEELGOUP
	lw	$t4,0($t3)
	add	$s3,$s3,$t4
	
	wheel_move_end:

	jr	$ra 
# ------------------------------------
update_vanish_wall:
	la	$t0,TICK
	lw	$t1,0($t0)
	addi	$t2,$zero,30
	div	$t1,$t2
	mfhi	$t2
	
	
	beq	$t2,$zero,wall_vanish_toggle
	b	vanish_wall_end
	
	wall_vanish_toggle:
	la	$t0,PLATFORMVANISH
	lw	$t1,0($t0)
	beq	$t1,$zero,wall_is_still_here
	sw	$zero,0($t0)
	b	vanish_wall_end

	wall_is_still_here:
	addi	$t1,$zero,1
	sw	$t1,0($t0)

	vanish_wall_end:
	jr	$ra 
# ------------------------------------# ------------------------------------# ------------------------------------
# ------------------------------------# --------draw_related functions------# ------------------------------------
# ------------------------------------# ------------------------------------# ------------------------------------
clear_old_player:
	beq	$s0,$s1,clear_old_player_end #if player is not moving, then no need to claer the old player
	
	li	$a1,BLACK
	add	$t0,$s0,$zero
	
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)

	sw	$a1,8($t0)
	
	clear_old_player_end:
	jr	$ra
# ------------------------------------
draw_new_player:
	la	$t0,PLAYERHURT
	lw	$t1,0($t0)
	addi	$t0,$zero,1
	beq	$t1,$t0,player_is_hurting 	# if PLAYERHURT == 1, branch to player_is_hurting

	draw_normal_player: 
	# if PLAYERHURT == 0, draw normal player

	li	$a1,YELLOW
	li	$a2,GREEN
	li	$a3,BLACK
	

	b	new_player_draw_start
	
	player_is_hurting:

	li	$a1,PINK
	li	$a2,YELLOW
	li	$a3,BLACK
	

	new_player_draw_start:
	add	$t0,$zero,$s1
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a2,4($t0)
	sw	$a1,8($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)

	sw	$a1,8($t0)
	new_player_draw_finished:
	add	$s0,$zero,$s1 #let s0 == s1 after we draw new player
	jr	$ra
	
# ------------------------------------	

draw_enemy_A:
	la	$t0,ENEMYADOWN
	lw	$t1,0($t0)
	beq	$t1,$zero,enemy_a_active
	
	enemy_a_sleep:
	li	$a1,GREY
	li	$a2,WHITE
	b	start_draw_enemy_a
	enemy_a_active:
	li	$a1,GREEN
	li	$a2,RED
	start_draw_enemy_a:
	li	$a3,BLACK
	add	$t0,$zero,$s4
	
	sw	$a3,-4($t0)
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a3,12($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a3,-4($t0)
	sw	$a2,0($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a3,12($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a3,-4($t0)
	sw	$a2,0($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a3,12($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a3,-4($t0)
	sw	$a2,0($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a3,12($t0)
	jr	$ra
# ------------------------------------
draw_enemy_B:
	la	$t0,ENEMYBDOWN
	lw	$t1,0($t0)
	beq	$t1,$zero,enemy_b_active
	
	enemy_b_sleep:
	li	$a1,GREY
	li	$a2,WHITE
	b	start_draw_enemy_b
	enemy_b_active:
	li	$a1,GREEN
	li	$a2,RED
	start_draw_enemy_b:
	li	$a3,BLACK
	add	$t0,$zero,$s5
	
	sw	$a3,-4($t0)
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a3,12($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a3,-4($t0)
	sw	$a2,0($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a3,12($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a3,-4($t0)
	sw	$a2,0($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a3,12($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a3,-4($t0)
	sw	$a2,0($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a3,12($t0)
	jr	$ra
	
	
# ------------------------------------
draw_lives:
	li	$t0,LIVE_POSITION
	li	$a1,YELLOW
	la	$t2,LIVES
	lw	$t2,0($t2)
	draw_lives_loop:
		ble	$t2,$zero,draw_lives_end
		sw	$a1,0($t0)
		sw	$a1,8($t0)
		addi	$t1,$t0,SHIFT_NEXT_ROW
		sw	$a1,4($t1)
		addi	$t0,$t0,20
		addi	$t2,$t2,-1
		j	draw_lives_loop
	draw_lives_end:
		jr	$ra
# ------------------------------------
draw_door:
	li	$t0,DOOR
	li	$a1,YELLOW
	li	$a2,BLUE
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,20($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a2,12($t0)
	sw	$a2,16($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,20($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a2,12($t0)
	sw	$a2,16($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,20($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a2,12($t0)
	sw	$a2,16($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,20($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a2,12($t0)
	sw	$a2,16($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,20($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a2,12($t0)
	sw	$a2,16($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,20($t0)
	sw	$a2,4($t0)
	sw	$a2,8($t0)
	sw	$a2,12($t0)
	sw	$a2,16($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	jr	$ra

# ------------------------------------
draw_green_wall:
	li	$a1,GREEN
	li	$a2,BLACK
	sw	$a2,-4($s2)
	sw	$a1,0($s2)
	sw	$a1,4($s2)
	sw	$a1,8($s2)
	sw	$a1,12($s2)
	sw	$a1,16($s2)
	sw	$a1,20($s2)
	sw	$a1,24($s2)
	sw	$a1,28($s2)
	sw	$a1,32($s2)
	sw	$a1,36($s2)
	sw	$a1,40($s2)
	sw	$a2,44($s2)
	jr	$ra
## ------------------------------------
draw_red_wheel:
	li	$a1,RED
	li	$a2,BLACK
	addi	$t1,$s3,-256
	addi	$t2,$s3,SHIFT_NEXT_ROW
	addi	$t2,$t2,SHIFT_NEXT_ROW
	addi	$t2,$t2,SHIFT_NEXT_ROW
	addi	$t2,$t2,SHIFT_NEXT_ROW
	sw	$a2,4($t1)
	sw	$a2,8($t1)
	sw	$a2,12($t1)
	sw	$a2,0($s3)
	sw	$a2,16($s3)
	sw	$a2,0($t2)
	sw	$a2,16($t2)
	addi	$t2,$t2,SHIFT_NEXT_ROW
	sw	$a2,4($t2)
	sw	$a2,8($t2)
	sw	$a2,12($t2)
	
	sw	$a1,4($s3)
	sw	$a1,8($s3)
	sw	$a1,12($s3)
	addi	$t2,$s3,SHIFT_NEXT_ROW
	sw	$a1,0($t2)
	sw	$a1,4($t2)
	sw	$a1,8($t2)
	sw	$a1,12($t2)
	sw	$a1,16($t2)
	addi	$t2,$t2,SHIFT_NEXT_ROW
	sw	$a1,0($t2)
	sw	$a1,4($t2)
	sw	$a2,8($t2)
	sw	$a1,12($t2)
	sw	$a1,16($t2)
	addi	$t2,$t2,SHIFT_NEXT_ROW
	sw	$a1,0($t2)
	sw	$a1,4($t2)
	sw	$a1,8($t2)
	sw	$a1,12($t2)
	sw	$a1,16($t2)
	addi	$t2,$t2,SHIFT_NEXT_ROW
	sw	$a1,4($t2)
	sw	$a1,8($t2)
	sw	$a1,12($t2)
	jr	$ra

# ------------------------------------
draw_blue_walls:
	li	$a1,LIGHTBLUE
	
	li	$a0,UPPER_BLUE
	
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	
	addi	$a0,$a0,40
	
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	
	li	$a0,LOWER_BLUE
	
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	
	addi	$a0,$a0,40
	
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	addi	$a0,$a0,4
	sw	$a1,0($a0)
	jr	$ra
# ------------------------------------	
draw_hell:
	li	$t0,HELL
	li	$t1,DISPLAY_LAST_ADDRESS
	li	$a1,RED
	addi	$t1,$t1,1
	
	hell_draw_loop:
		bge	$t0,$t1,hell_draw_end
		sw	$a1,0($t0)
	hell_draw_update:
		addi	$t0,$t0,4
		b	hell_draw_loop
	hell_draw_end:
		jr	$ra
# ------------------------------------	
draw_vanish_platform:
	la	$t0,PLATFORMVANISH
	lw	$t1,0($t0)
	beq	$t1,$zero,platform_purple
	platform_grey:
		li	$a1,GREY
		b draw_vanish_platform_start
	platform_purple:
		li	$a1,PURPLE
	draw_vanish_platform_start:
	li	$t0,VANISH_WALL
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	sw	$a1,32($t0)
	sw	$a1,36($t0)
	sw	$a1,40($t0)
	jr	$ra
# ------------------------------------	
draw_start:
	addi $sp,$sp,-4
	sw $ra,0($sp)

	li $a0, DISPLAY_FIRST_ADDRESS
	addi $a0,$a0,3416
	jal draw_S
	
	li	$a0, DISPLAY_FIRST_ADDRESS
	addi	$a0,$a0,3432
	jal draw_T
	
	li	$a0, DISPLAY_FIRST_ADDRESS
	addi	$a0,$a0,3448
	jal draw_A

	li	$a0, DISPLAY_FIRST_ADDRESS
	addi	$a0,$a0,3468
	jal draw_R
	
	li	$a0, DISPLAY_FIRST_ADDRESS
	addi	$a0,$a0,3488
	jal draw_T
	
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
# ------------------------------------
draw_exit:
	addi $sp,$sp,-4
	sw $ra,0($sp)

	li $a0, DISPLAY_FIRST_ADDRESS
	addi $a0,$a0,5216
	jal draw_E
	
	li $a0, DISPLAY_FIRST_ADDRESS
	addi $a0,$a0,5232
	jal draw_X
	
	li $a0, DISPLAY_FIRST_ADDRESS
	addi $a0,$a0,5252
	jal draw_I
	
	li $a0, DISPLAY_FIRST_ADDRESS
	addi $a0,$a0,5268
	jal draw_T
	
	lw $ra,0($sp)
	addi $sp,$sp,4
	jr $ra
# ------------------------------------
draw_S:
		# $a0: DISPLAY_SPLASH
		# $a1: COLOUR_NUMBER

	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)

	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 8($a0)

	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	
	
	
	jr	$ra

# ------------------------------------
draw_T:

	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)

	
	jr	$ra
# ------------------------------------
draw_A:

	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	sw	$a1, 12($a0)

	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)

	
	jr	$ra
# ------------------------------------
draw_R: 
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 8($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 8($a0)
	sw	$a1, 12($a0)
	
	jr $ra
# ------------------------------------
draw_E:
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	jr	$ra
# ------------------------------------
draw_X:
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 12($a0)
	
	jr $ra
# ------------------------------------	
draw_I:
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 4($a0)
	addi	$a0, $a0, SHIFT_NEXT_ROW
	sw	$a1, 0($a0)
	sw	$a1, 4($a0)
	sw	$a1, 8($a0)
	
	jr $ra

draw_you_lose:	#I have to rewrite other than using draw_a, draw_e because the letter needs to be bigger
	li	$a1,GREY
	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	draw_you
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	
	li	$t0,LOSE_POSITION
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	sw	$a1,52($t0)
	sw	$a1,56($t0)
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	sw	$a1,132($t0)
	sw	$a1,136($t0)
	sw	$a1,140($t0)
	sw	$a1,144($t0)#row1 
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	sw	$a1,52($t0)
	sw	$a1,56($t0)
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	sw	$a1,132($t0)
	sw	$a1,136($t0)
	sw	$a1,140($t0)
	sw	$a1,144($t0)#row2
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row3
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row4
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row5
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	sw	$a1,132($t0)
	sw	$a1,136($t0)
	sw	$a1,140($t0)
	sw	$a1,144($t0)#row6
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	

	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	sw	$a1,132($t0)
	sw	$a1,136($t0)
	sw	$a1,140($t0)
	sw	$a1,144($t0)#row7
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row8
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)

	sw	$a1,64($t0)
	sw	$a1,68($t0)
	
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row9
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)

	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row10
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)

	sw	$a1,64($t0)
	sw	$a1,68($t0)
	
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row11
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)#row12
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	sw	$a1,52($t0)
	sw	$a1,56($t0)
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	sw	$a1,132($t0)
	sw	$a1,136($t0)
	sw	$a1,140($t0)
	sw	$a1,144($t0)#row13
	
	
draw_you:
	li	$t0,YOU_POSITION
	sw	$a1,0($t0)
	sw	$a1,40($t0)
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,92($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r2
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,36($t0)
	sw	$a1,40($t0)
	sw	$a1,56($t0)
	sw	$a1,60($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r3
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,36($t0)
	sw	$a1,32($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)

	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r4
	sw	$a1,12($t0)
	sw	$a1,8($t0)
	sw	$a1,28($t0)
	sw	$a1,32($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)		
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r5
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r6
	sw	$a1,20($t0)
	sw	$a1,16($t0)
	sw	$a1,24($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r7
	sw	$a1,20($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r8
	sw	$a1,20($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r9
	sw	$a1,20($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r10
	sw	$a1,20($t0)
	sw	$a1,56($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r11
	sw	$a1,20($t0)
	sw	$a1,56($t0)
	sw	$a1,60($t0)
	sw	$a1,92($t0)
	sw	$a1,96($t0)
	sw	$a1,112($t0)
	sw	$a1,148($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r12
	sw	$a1,20($t0)
	sw	$a1,64($t0)
	sw	$a1,60($t0)
	sw	$a1,92($t0)
	sw	$a1,88($t0)
	sw	$a1,112($t0)
	sw	$a1,116($t0)
	sw	$a1,144($t0)
	sw	$a1,148($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#r13
	sw	$a1,20($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	sw	$a1,88($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	sw	$a1,132($t0)
	sw	$a1,136($t0)
	sw	$a1,140($t0)
	sw	$a1,144($t0)
	jr	$ra

draw_you_win:

	li	$a1,YELLOW

	addi	$sp,$sp,-4
	sw	$ra,0($sp)
	jal	draw_you
	lw	$ra,0($sp)
	addi	$sp,$sp,4
	
	li	$t0,WIN_POSITION
	#R1
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,108($t0)
	sw	$a1,112($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R2
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,104($t0)
	sw	$a1,108($t0)
	sw	$a1,112($t0)
	sw	$a1,116($t0)
	sw	$a1,120($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R3
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R4
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)

	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)

	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R5
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)

	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R6
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)

	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R7
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)

	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R8
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)

	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R9
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)

	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R10
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	sw	$a1,32($t0)
	sw	$a1,36($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)
	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R11
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	sw	$a1,32($t0)
	sw	$a1,36($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)	
	addi	$t0,$t0,SHIFT_NEXT_ROW
	#R12
	sw	$a1,0($t0)
	sw	$a1,4($t0)
	sw	$a1,8($t0)
	sw	$a1,12($t0)
	sw	$a1,16($t0)
	sw	$a1,20($t0)
	sw	$a1,24($t0)
	sw	$a1,28($t0)
	sw	$a1,32($t0)
	sw	$a1,36($t0)
	sw	$a1,40($t0)
	sw	$a1,44($t0)
	sw	$a1,48($t0)
	
	sw	$a1,60($t0)
	sw	$a1,64($t0)
	sw	$a1,68($t0)
	sw	$a1,72($t0)
	sw	$a1,76($t0)
	sw	$a1,80($t0)
	sw	$a1,84($t0)
	
	sw	$a1,96($t0)
	sw	$a1,100($t0)
	sw	$a1,124($t0)
	sw	$a1,128($t0)	
	jr	$ra


