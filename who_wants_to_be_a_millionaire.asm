org 100h

.data
	usr1	db "ghazzawi"
	pwd1	db "naruto123"
	usrlen1	dw 8
	pwdlen1	dw 9
	
	usr2	db "yasseen"
	pwd2	db "furiousfarooq"
	usrlen2	dw 7
	pwdlen2	dw 13
	
	usr3	db "kathem"
	pwd3	db "layla"
	usrlen3	dw 6
	pwdlen3	dw 5
	
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
	
	usr_to_check db 0
	access_limit db 3
.code
	jmp start
	
	clear_terminal proc
		mov ah, 06h        ; Scroll up function
		mov al, 0          ; Scroll 0 lines → clear entire area
		mov bh, 07h        ; Text attribute (white on black)
		mov cx, 0      ; Top-left corner: row 0, col 0
		mov dx, 184Fh      ; Bottom-right: row 24, col 79 (25x80 screen)
		int 10h

		ret
	clear_terminal endp
	
	zero_cursor proc
		mov ah, 2     ; Set cursor position
		mov dh, 0       ; Row = 0
		mov dl, 0       ; Column = 0
		int 10h
		
		mov dl, ' '  ; print a space
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
			lea dx, check_fail_msg ; print sign-in message.
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
			inc dh 			; reset the cursor.
			mov dl, 0
			mov ah, 02h
			mov bh, 0
			int 10h
			
			mov ah, 09h		; type new message with default settings.
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
		lea dx, sign_in_msg ; print sign-in message.
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
			lea dx, check_fail_msg ; print sign-in message.
			int 21h
			call usr_sign_in
			ret
	authenticate_usr_plus endp
	
	timer proc
		; Input: AL = number of seconds
		; Output: AL = key pressed if any, else 0
	
		push ax
		push bx
		push cx
		push dx
		push si

		mov bl, al         ; BL = countdown number
		mov si, 1          ; SI = first_time flag

		call clear_line    ; Optional: move to a new line

		count_loop:
			; Erase previous number (not first time)
			cmp si, 1
			je skip_erase

			; backspace + space + backspace to erase digit
			mov dl, 8
			mov ah, 02h
			int 21h
			mov dl, ' '
			int 21h
			mov dl, 8
			int 21h

		skip_erase:
			mov si, 0          ; next time we erase

			; Check for keypress
			mov ah, 01h
			int 16h
			jnz key_pressed

			; Convert BL to ASCII and print it
			mov al, bl
			add al, '0'
			mov dl, al
			mov ah, 02h
			int 21h

			; Wait ~1 second
			mov ah, 00h
			int 1Ah
			mov si, dx

		wait_tick:
			mov ah, 00h
			int 1Ah
			sub dx, si
			cmp dx, 18
			jb wait_tick

			dec bl
			cmp bl, 0
			jne count_loop

			; Time expired
			mov al, 0
			jmp done

		key_pressed:
			mov ah, 00h
			int 16h
			; AL now holds key

		done:
			pop si
			pop dx
			pop cx
			pop bx
			pop ax
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
		;jbe to_lower
		
		add al, 32
		
		accept_input:
		cmp al, 122
		ja invalid
		
		cmp al, 96
		jbe invalid
		
		jmp valid
		
		invalid:
			;mov ah, 09h
			;lea dx, invalid_char
			;int 21h
			mov ah, 01h
			int 21h
			call lower
			
		valid:
			ret
		
	lower endp
	
	start:
		mov ax, 0700h
		mov ds, ax    
		
		mov ax, 2000h
		mov es, ax
		
		call usr_sign_in
		call clear_terminal
		call zero_cursor
		call pwd_sign_in
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
		mov ah, 01h
		int 21h
		
		call lower
		call terminate_access
		
		;mov al, 5	; # of seconds (works up to 9).
		;call timer
		
	
	end start
	
	;mov ah, 01h
	;int 21h
	; result is in AL
