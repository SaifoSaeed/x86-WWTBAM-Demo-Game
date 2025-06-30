org 100h

.data
	usr1	db "ghazzawi"
	pwd1	db "naruto123"
	usrlen1	dw 8
	pwdlen1	dw 9
	score_1 dw 0
	
	usr2	db "yasseen"
	pwd2	db "furiousfarooq"
	usrlen2	dw 7
	pwdlen2	dw 13
	score_2 dw 1
	
	usr3	db "kathem"
	pwd3	db "layla"
	usrlen3	dw 6
	pwdlen3	dw 5
	score_3 dw 3
	
	scoreboard dw score_1, score_2, score_3
	users dw usr1, usr2, usr3
	
	welcome_msg1 db 13, 10, 13, 10, "   Welcome to this episode of "
				 db "$"
				
			
	welcome_msg2 db "Who Wants to be a Millionaire?", 0
	
	welcome_msg3 db 13, 10, "   My name is George Qurdahi, your host for today. Are you ready? (Y/n)$"
					
	sign_in_msg	db "   Please enter a valid username.", 13, 10, 13, 10, "   Username:   "
				db "$"
				
	sign_in2_msg db  "   Please enter a valid password.", 13, 10, 13, 10, "   Password:   "
				 db "$"
	
	buffer db 15, ?, 15 dup(?)
	clean_buffer db 15, ?, 15 dup(?)
	
	terminate_msg db 13, 10, "   Too many invalid login attempts.", 13, 10, "   Program terminated."
				  db "$"
	
	check_fail_msg db "   Incorrect. Try again.", 13, 10, "$"
	
	invalid_char db "   Invalid Character. Try again.", 13, 10, "$"
	
	q0 db "   How many Arab countries have the official currency of Riyal?", 13, 10
		db "   A: Two   B: Four   C: Three   D: Five"
		db "$"
		
	ans0 db "b"
	
	q1 db "   What do you call someone who exaggerates his traits and finds himself of all humans supreme?", 13, 10
		db "   A: Humble   B: Egotistical   C: Generous   D: Honourable"
		db "$"
	
	ans1 db "b"
	
	
	q2 db "   What is the plural of 'Fish'?", 13, 10
		db "   A: Fish   B: Fishies   C: Parliament of Fish   D: Fish's"
		db "$"
		
	ans2 db "a"
		
	q3 db "   Continue: 'Find wisdom in the words of ____?", 13, 10
		db "   A: Barbers   B: Artists   C: Astrologers   D: The Mad"
		db "$"
	
	ans3 db "d"
		
	q4 db "   Your father is her grandpa, and your brother is her uncle. You're her mother's husband. Who is she?", 13, 10
		db "   A: Your Aunt   B: Your Mother   C: Your Daughter   D: Your Sister"
		db "$"

	ans4 db "c"
	
	correct_ans_msg db 13, 10, "   Correct!$"
	
	wrong_ans_msg db 13, 10, "   Incorrect!$"
	
	congrats_msg db 13, 10, "   Congrats! You now have 1000 Saudi Riyals.$"
	
	results_msg_0 db 13, 10, "   You scored "
				db "$"
				
	results_msg_1 db "/5 in this quiz.", 13, 10
				db "$"
	
	restart_msg db "   Play again? (Y/n)$"
	
	end_game_msg db 13, 10, "   Thanks for playing!$"
	
	continue_msg db 13, 10, "   Continue to scoreboard? (Y/n)$"
	
	usr_to_check db 0
	access_limit db 3
	correct_count db 0
	seed dw 0
	
	question_table dw question0, question1, question2, question3, question4
	
	
.code
	jmp start
	
	clear_terminal proc
		mov ah, 06h        ;scroll up function
		mov al, 0          ;scroll 0 lines to clear entire area
		mov bh, 07h
		push cx
		mov cx, 0
		mov dx, 184Fh
		int 10h
		
		pop cx

		ret
	clear_terminal endp
	
	zero_cursor proc
		mov ah, 2     ;set cursor
		mov dh, 0     ;row = 0
		mov dl, 0     ;column = 0
		int 10h
		
		mov dl, ' '
		int 21h
		
		mov ah, 02h
		mov bh, 0
		mov dh, 0
		mov dl, 0
		int 10h

		ret
	zero_cursor endp
	
	terminate_access proc
		mov ah, 4Ch
		int 21h
	terminate_access endp
	
	authenticate_pwd proc
		cld
		mov di, 0
		and cx, 0
		or cl, [buffer +1]
		
		cmp usr_to_check, 1
		je check_pwd1
		
		cmp usr_to_check, 2
		je check_pwd2
		
		cmp usr_to_check, 3
		je check_pwd3
		
		jmp pwd_fail ; it should be impossible to get here.
		
		check_pwd1:
			mov si, offset pwd1
			repe cmpsb
			jz pwd_success
			jmp pwd_fail
			
		check_pwd2:
			mov si, offset pwd2
			repe cmpsb
			jz pwd_success
			jmp pwd_fail
			
		check_pwd3:
			mov si, offset pwd3
			repe cmpsb
			jz pwd_success
			jmp pwd_fail
			
		pwd_success:
			ret
		
		pwd_fail:
			dec access_limit
			call clear_terminal
			call zero_cursor
			mov ah, 09h
			lea dx, check_fail_msg
			int 21h
			call usr_sign_in
			call clear_terminal
			call zero_cursor
			call pwd_sign_in
			ret
	authenticate_pwd endp
	
	pwd_sign_in proc
		
		mov ah, 09h
		lea dx, sign_in2_msg
		int 21h
		
		mov ah, 0Ah
		mov dx, offset buffer
		int 21h

		mov cl, [buffer+1]
		and ch, 0
		mov si, offset buffer + 2
		mov di, 0
		cld
		rep movsb
		
		call authenticate_pwd
		ret
	pwd_sign_in endp
	
	welcome proc
		call clear_terminal
		call zero_cursor

		mov ah, 09h
		lea dx, welcome_msg1
		int 21h
		
		mov si, offset welcome_msg2

		mov dl, 15
		mov dh, 4
		
		welcome2_next_char:
			lodsb
			cmp al, 0
			je welcome3

			; Set cursor
			mov ah, 02h
			mov bh, 0
			int 10h

			; Print char with color
			mov ah, 09h
			mov bh, 0
			mov bl, 1Eh
			mov cx, 1
			int 10h

			; Move cursor right
			inc dl
			jmp welcome2_next_char

		welcome3:
			inc dh 			
			mov dl, 0
			mov ah, 02h
			mov bh, 0
			int 10h
			
			mov ah, 09h		;type new message with default settings.
			lea dx, welcome_msg3
			int 21h
		
	welcome endp
	
	setz_al proc
		
		push bx
		jz setz_true
		jmp setz_false
		
		setz_true:
			xor al,ah
			
		setz_false:
			shl ah,1
			pop bx
			ret
	setz_al endp
	
	usr_sign_in proc
		cmp access_limit, 0
		jz bad_access
		mov ah, 09h
		lea dx, sign_in_msg ;print sign-in message.
		int 21h
		
		mov ah, 0Ah
		mov dx, offset buffer
		int 21h

		mov cl, [buffer+1]
		and ch, 0
		mov si, offset buffer + 2
		mov di, 0
		cld
		rep movsb
		
		call authenticate_usr
		ret
		
		bad_access:
			call clear_terminal
			call zero_cursor
			mov ah, 09h
			lea dx, terminate_msg
			int 21h
			call terminate_access
		
	usr_sign_in endp
	
	authenticate_usr proc
		mov al, 0
		mov ah, 1
		
		mov bl, [buffer + 1]
		and bh, 0
		
		cmp bx, usrlen1
		call setz_al
		
		cmp bx, usrlen2
		call setz_al
		
		cmp bx, usrlen3
		call setz_al
		
		call authenticate_usr_plus
			
		ret
			
	authenticate_usr endp
		
	
	authenticate_usr_plus proc
		cmp al, 0
		jz mismatched
	
		cld
		mov di, 0
		and cx, 0
		or cl, [buffer +1]
		
		cmp al, 1
		jz auth_usr1
		
		cmp al, 2
		jz auth_usr2
		
		cmp al, 4
		jz auth_usr3
		
		auth_usr1:
			mov si, offset usr1
			repe cmpsb
			mov [usr_to_check], 1
			jz matched
			jmp mismatched
			
		auth_usr2:
			mov si, offset usr2
			repe cmpsb
			mov [usr_to_check], 2
			jz matched
			jmp mismatched
			
		auth_usr3:
			mov si, offset usr3
			repe cmpsb
			mov [usr_to_check], 3
			jz matched
			jmp mismatched
			
		matched:
			ret
			
		mismatched:
			dec access_limit
			call clear_terminal
			call zero_cursor
			mov ah, 09h
			lea dx, check_fail_msg
			int 21h
			call usr_sign_in
			ret
	authenticate_usr_plus endp
	
	timer proc
		;al is the number of seconds.
		push si

		mov bl, al         
		mov si, 1          

		call clear_line

		count_loop:
			
			cmp si, 1
			je skip_erase

			mov dl, 8
			mov ah, 02h
			int 21h
			mov dl, ' '
			int 21h
			mov dl, 8
			int 21h

		skip_erase:
			mov si, 0        

			mov ah, 01h
			int 16h
			jnz key_pressed

			mov al, bl
			add al, '0'
			mov dl, al
			mov ah, 02h
			int 21h

			mov ah, 00h
			push cx
			int 1Ah
			pop cx
			mov si, dx

		wait_tick:
			mov ah, 00h
			push cx
			int 1Ah
			pop cx
			sub dx, si
			cmp dx, 18
			jb wait_tick

			dec bl
			cmp bl, 0
			jne count_loop

			mov al, 'g'
			jmp done

		key_pressed:
			mov ah, 00h
			int 16h

		done:
			pop si
			ret

		clear_line:
			mov dl, 13
			mov ah, 02h
			int 21h
			mov dl, 10
			int 21h
			mov dl, 32
			int 21h
			int 21h
			int 21h
			ret

	timer endp
	
	lower proc
		cmp al, 97
		jae accept_input
		
		add al, 32
		
		accept_input:
		cmp al, 122
		ja invalid
		
		cmp al, 96
		jbe invalid
		
		jmp valid
		
		invalid:
			mov ah, 01h
			int 21h
			call lower
			
		valid:
			ret
		
	lower endp
	
	quiz_start proc
		mov cx, 5          ;# of q's.
		mov si, seed
		;shl si, 1
		ask_loop:
			mov bx, offset return_addr_quiz
			push bx
			call clear_terminal
			call zero_cursor
			
			mov bx, offset question_table
			jmp [bx + si]
			
			return_addr_quiz:

			inc si
			inc si
			cmp si, 10
			jb skip_wrap
			mov si, 0

		skip_wrap:
			loop ask_loop
		
		ret
	quiz_start endp
	
	question0 proc
		mov ah, 09h
		lea dx, q0
		int 21h
		
		mov al, 8
		call timer
		
		validation_0:
		call lower
		
		cmp al, ans0
		je correct_0
		jmp incorrect_0
		
		incorrect_0:
			mov ah, 09h
			lea dx, wrong_ans_msg
			int 21h
			
			call wrong_beep
			
			ret
			
		correct_0:
			mov ah, 09h
			lea dx, correct_ans_msg
			int 21h
			
			inc correct_count
			
			ret
	question0 endp
	
	question1 proc
	
		mov ah, 09h
		lea dx, q1
		int 21h
		
		mov al, 8
		call timer
		
		validation_1:
		call lower
		
		cmp al, ans1
		je correct_1
		jmp incorrect_1
		
		incorrect_1:
			mov ah, 09h
			lea dx, wrong_ans_msg
			int 21h
			
			call wrong_beep
			
			ret
			
		correct_1:
			mov ah, 09h
			lea dx, correct_ans_msg
			int 21h
			
			inc correct_count
			
			ret
	
	question1 endp
	
	question2 proc
	
		mov ah, 09h
		lea dx, q2
		int 21h
		
		mov al, 8
		call timer
		
		validation_2:
		call lower
		
		cmp al, ans2
		je correct_2
		jmp incorrect_2
		
		incorrect_2:
			mov ah, 09h
			lea dx, wrong_ans_msg
			int 21h
			
			call wrong_beep
			
			ret
			
		correct_2:
			mov ah, 09h
			lea dx, correct_ans_msg
			int 21h
			
			inc correct_count
			ret
	
	question2 endp
	
	question3 proc
	
		mov ah, 09h
		lea dx, q3
		int 21h
		
		mov al, 8
		call timer
		
		validation_3:
		call lower
		
		cmp al, ans3
		je correct_3
		jmp incorrect_3
		
		incorrect_3:
			mov ah, 09h
			lea dx, wrong_ans_msg
			int 21h
			
			call wrong_beep
			
			ret
			
		correct_3:
			mov ah, 09h
			lea dx, correct_ans_msg
			int 21h
			
			inc correct_count
			
			ret
	
	question3 endp
	
	question4 proc
	
		mov ah, 09h
		lea dx, q4
		int 21h
		
		mov al, 8
		call timer
		
		validation_4:
		call lower
		
		cmp al, ans4
		je correct_4
		jmp incorrect_4
		
		incorrect_4:
			mov ah, 09h
			lea dx, wrong_ans_msg
			int 21h
			
			call wrong_beep
			
			ret
			
		correct_4:
			mov ah, 09h
			lea dx, correct_ans_msg
			int 21h
			
			inc correct_count
			
			ret
	
	question4 endp
	
	results proc
		mov ah, 09h
		lea dx, results_msg_0
		int 21h
		
		mov dl, correct_count
		add dl, 48
		mov ah, 02h
		int 21h
		
		mov ah, 09h
		lea dx, results_msg_1
		int 21h
		
		cmp correct_count, 5
		jne end_results
		
		lea dx, congrats_msg
		int 21h
		
		end_results:
			lea dx, continue_msg
			int 21h
			
			mov ah, 01h
			int 21h
			
			cmp al, 'y'
			je continuing
			cmp al, 'n'
			je not_continuing
			
			
			continuing:
				call scoreboarding
				
			not_continuing:
			mov ah, 09h
			lea dx, restart_msg
			int 21h
			ret
	results endp
	
	scoreboarding proc
		call clear_terminal
		call zero_cursor
		
		call adjust_scores
		call print_scoreboard
		
		ret
	scoreboarding endp
	
	adjust_scores proc
		mov bx, offset scoreboard
		and dx, 0
		mov dl, usr_to_check
		dec dl
		shl dl, 1
		mov si, dx
		
		mov bx, [bx + si]
		
		mov dl, correct_count
		
		cmp dx, [bx]
		ja change_high_score
		
		ret
		
		change_high_score:
			mov dl, correct_count
			mov [bx + si], dx
			
			ret
	adjust_scores endp
	
	print_scoreboard proc
		ret
		
	print_scoreboard endp
	
	end_game proc
		call clear_terminal
		call zero_cursor
		
		mov ah, 09h
		lea dx, end_game_msg
		int 21h
		
		mov ah, 4Ch
		int 21h
		
	end_game endp
	
	wrong_beep proc
		mov ah, 02h
		mov dl, 7
		int 21h
		int 21h
		ret
	wrong_beep endp
	
	start:
		mov ax, 0700h
		mov ds, ax    
		
		mov ax, 2000h
		mov es, ax
		
		restart:
			mov correct_count, 0
			call clear_terminal
			call zero_cursor
			call usr_sign_in
			call clear_terminal
			call zero_cursor
			call pwd_sign_in
			mov access_limit, 3
			call welcome
			mov dl, 13
			mov ah, 02h
			int 21h
			mov dl, 10
			int 21h
			mov dl, 32
			int 21h
			int 21h
			int 21h

			validation_start:
			mov ah, 01h
			int 21h
			call lower
			
			cmp al, 'y'
			je start_quiz
			cmp al, 'n'
			je terminate_program
			
			jmp validation_start
			
			start_quiz:
				call clear_terminal
				call zero_cursor
				call quiz_start
				call results
				
				mov ah, 01h
				int 21h
				call lower
				
				cmp al, 'y'
				je restart
				cmp al, 'n'
				je terminate_program
				
				jmp restart
				
			terminate_program:
				call end_game
	
	end start
