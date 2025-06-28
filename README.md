# 16-bit x86 Assembly Quiz Game

This project is a "Who Wants to Be a Millionaire?" style trivia game developed entirely in 16-bit x86 assembly language. It is designed to run in a DOS environment using an 8086 emulator, such as **emu8086**. The game showcases various low-level programming techniques, including direct hardware interaction for video and keyboard input, memory management, and modular program design.

## Features

-   **User Authentication:** A secure login system requiring a valid username and password. The system locks out the user after three failed login attempts.
-   **Dynamic Welcome Screen:** An animated welcome message that uses BIOS `INT 10h` interrupts for custom cursor positioning and text coloring.
-   **Timed Multiple-Choice Quiz:** The core of the game is a quiz with five questions. Each question is presented with four possible answers (A, B, C, D).
-   **Per-Question Countdown Timer:** Each question has an 8-second countdown timer. The timer is displayed on-screen and updates in real-time. The system accepts user input at any point during the countdown.
-   **Real-Time Input Handling:** The timer mechanism uses non-blocking keyboard checks (`INT 16h`), allowing the program to process an answer immediately without waiting for the timer to expire.
-   **Score Tracking:** The game tracks the number of correct answers.
-   **High Score System:** The user's score for the session is compared against their stored high score. If the new score is higher, it is updated in memory for the duration of the runtime session.
-   **Modular Code:** The program is organized into distinct procedures for clarity and reusability, covering tasks like screen clearing, user authentication, quiz logic, and timer management.

## Technical Implementation

This program is a comprehensive demonstration of 16-bit assembly programming concepts for the Intel 8086 microprocessor.

### Environment & Architecture

Architecture:   16-bit Intel x86Environment:    DOS / emu8086Memory Model:   .com (origin at 100h)
### Core Procedures & Logic

-   **Authentication (`authenticate_usr`, `authenticate_pwd`):**
    -   Usernames and passwords are hardcoded in the `.data` segment.
    -   Authentication is a two-step process: first, the length of the input is checked, and then the content is verified using the `repe cmpsb` instruction for efficient string comparison.
    -   A counter (`access_limit`) tracks failed attempts and terminates the program if the limit is exceeded.

-   **Screen Manipulation (`clear_terminal`, `zero_cursor`, `welcome`):**
    -   The program frequently uses BIOS video services via `INT 10h`.
    -   `AH=06h` is used to clear the screen.
    -   `AH=02h` is used to set the cursor position (`DH`, `DL`).
    -   `AH=09h` (with `AL`=char, `BL`=color, `CX`=count) is used to print characters with specific color attributes.

-   **Quiz Logic (`quiz_start`, `question0`...`question4`):**
    -   A jump table (`question_table`) containing procedure offsets is used for dynamic dispatch. This allows the `quiz_start` procedure to loop through questions via an indirect jump.
    -   Each `question` procedure is self-contained: it prints the question, calls the timer, validates the answer, and updates the score (`correct_count`).

-   **Timer & Input (`timer`, `lower`):**
    -   The timer's delay is based on the system's hardware clock, accessed via `INT 1Ah`.
    -   While the timer runs, `INT 16h` with `AH=01h` checks the keyboard buffer for a keypress without halting execution (non-blocking).
    -   Input is converted to lowercase using the `lower` procedure to make answer validation case-insensitive.

### Interrupt Usage

INT 10h: BIOS Video Services (Screen Control, Cursor, Color)INT 16h: BIOS Keyboard Services (Non-blocking Input)INT 1Ah: BIOS Time-of-Day Services (Timer Tick Count)INT 21h: DOS Function Calls (Standard I/O, Program Termination)
## How to Run

1.  **Emulator:** You will need an 8086 emulator that supports DOS interrupts, such as **emu8086**.
2.  **Load:** Open the `who_wants_to_be_a_millionaire.asm` file in the emulator.
3.  **Compile & Run:** Compile the code and then run it from the emulator.
4.  **Login:** Use one of the hardcoded credentials to log in:
    -   user: `ghazzawi`, pass: `naruto123`
    -   user: `yasseen`, pass: `furiousfarooq`
    -   user: `kathem`, pass: `layla`
