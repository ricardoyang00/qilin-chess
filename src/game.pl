:- consult('menu.pl').
:- consult('board.pl').
:- consult('utils.pl').

forall(Condition, Action) :-
    \+ (Condition, \+ Action).

% Debug function to see board.
display_board(game_state(Board, _, [RedCount, BlackCount], _)) :-
    write('Current Board State: '),
    % forall(member(Pos-Cell, Board), (write(Pos), write('-'), write(Cell), write(', '))),
    nl,
    write('Pieces left: '), nl,
    write('Red: '), write(RedCount), nl,
    write('Black: '), write(BlackCount), nl, nl.


% play/0 - Main predicate to start the game and display the menu
play :- 
    display_menu,
    read(Option),
    skip_line,
    handle_option(Option).

% handle_option/1 - Handles the user's menu choice
handle_option(1) :- start_game(red, black).
handle_option(2) :- write('Human vs Computer mode is not implemented yet.'), nl, play.
handle_option(3) :- display_rules.
handle_option(0) :- write('Exiting the game.'), nl, !.
handle_option(_) :- write('Invalid option. Please try again.'), nl, play.

% start_game/2 - Starts the game with the given player types
start_game(Player1, Player2) :-
    initial_state([Player1, Player2], GameState),
    first_stage_loop(GameState).

% initial_state/2 - Sets up the initial game state with 18 pieces per player
% Initial state changed for debugging issues
initial_state([Player1, Player2], game_state(Board, Player1, [7, 7], [])) :-
    % Initialize the board with empty positions
    Board = [
        a1-red, d1-red, g1-black, 
        b2-black, d2-black, f2-red, 
        c3-red, d3-black, e3-empty,
        a4-black, b4-red, c4-black, e4-red, f4-black, g4-red, 
        c5-red, d5-black, e5-red,
        b6-black, d6-empty, f6-red, 
        a7-black, d7-red, g7-black
    ].

% first_stage_loop/1 - Main game loop
first_stage_loop(GameState) :-
    GameState = game_state(Board, CurrentPlayer, Pieces, Lines),
    display_game(GameState),
    display_board(GameState),
    first_stage_over(GameState, Transition),
    !,
    Transition.

first_stage_loop(GameState) :-
    choose_move(GameState, Move),
    move(GameState, Move, GameStateAfterMove, AllowPressCount),
    handle_press_down_move(GameStateAfterMove, AllowPressCount).

% handle_press_down_move/2 - Handles whether to perform a press down move or continue the game loop
handle_press_down_move(GameStateAfterMove, AllowPressCount) :-
    AllowPressCount > 0,
    display_game(GameStateAfterMove),
    display_board(GameStateAfterMove),
    write('Moves left to press down: '), write(AllowPressCount), nl,
    press_down(GameStateAfterMove, GameStateAfterPress, AllowPressCount),
    NewAllowPressCount is AllowPressCount - 1,
    handle_press_down_move(GameStateAfterPress, NewAllowPressCount).

handle_press_down_move(GameStateAfterMove, 0) :-
    % After all press down moves are handled, continue to the game loop
    first_stage_loop(GameStateAfterMove).

% choose_move/3 - Chooses a move for the human player
choose_move(game_state(Board, _, _, _), Move) :-
    read_move(Board, Move).

% valid_move/2 - Checks if a move is valid
valid_move(Board, Position) :-
    memberchk(Position-empty, Board).

% read_move/2 - Reads a move from the human player
read_move(Board, Move) :-
    write('Enter your move (e.g., a1): '),
    read(Move),
    skip_line,
    valid_position(Move),
    valid_move(Board, Move),
    !.

read_move(Board, Move) :-
    write('Invalid move. Please try again.'), nl,
    read_move(Board, Move).

% move/3 - Validates and executes a move
move(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), Move, game_state(NewBoard, NextPlayer, [NewRedCount, NewBlackCount], NewLines), AllowPressCount) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    check_lines_formed(NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    AllowPressCount = NewLineCount,
    AllowPressCount \= 0,
    NextPlayer = CurrentPlayer.

move(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), Move, game_state(NewBoard, NextPlayer, [NewRedCount, NewBlackCount], NewLines), AllowPressCount) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    check_lines_formed(NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    AllowPressCount = NewLineCount,
    AllowPressCount == 0,
    next_player(CurrentPlayer, NextPlayer).

% press_down/3 - Allows the current player to press down an opponent's piece
press_down(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), game_state(NewBoard, NextPlayer, [NewRedCount, NewBlackCount], Lines), AllowPressCount) :-
    write('You formed a line! Choose an opponent\'s piece to press down: '),
    read(PressMove),
    skip_line,
    valid_position(PressMove),
    memberchk(PressMove-Opponent, Board),
    Opponent \= CurrentPlayer,
    Opponent \= empty,
    Opponent \= pressed,
    update_board(Board, PressMove, pressed, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    (   
        AllowPressCount = 1, % Switch player when count is 1 so when it enters game loop with all press down moves handled the game state has the next player stored, not 0 because this function won't be called
        next_player(CurrentPlayer, NextPlayer)
    ; 
        AllowPressCount \= 1,
        NextPlayer = CurrentPlayer
    ),
    !.

press_down(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), SameGameState, AllowPressCount) :-
    write('Invalid press down move. Please try again.'), nl,
    press_down(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), SameGameState, AllowPressCount).

% update_board/4 - Updates the board with the player's move or maintains the state if no update
update_board([], _, _, []). % Base case: empty board

% Matching position, update to the new state
update_board([Position-_|Rest], Position, NewState, [Position-NewState|NewRest]) :-
    update_board(Rest, Position, NewState, NewRest).

% No match, keep the current state and process the rest
update_board([Other|Rest], Position, NewState, [Other|NewRest]) :-
    update_board(Rest, Position, NewState, NewRest).

% decrement_piece_count/4 - Decrements the piece count for the current player
decrement_piece_count(red, RedCount, BlackCount, NewRedCount, NewBlackCount) :-
    NewRedCount is RedCount - 1,
    NewBlackCount = BlackCount.

decrement_piece_count(black, RedCount, BlackCount, NewRedCount, NewBlackCount) :-
    NewBlackCount is BlackCount - 1,
    NewRedCount = RedCount.

% check_lines_formed/4 - Finds newly formed lines and updates the Lines list
check_lines_formed(Board, Player, ExistingLines, UpdatedLines, NewLineCount) :-
    straight_lines(AllPossibleLines),
    findall(Line, (
        member(Line, AllPossibleLines),     % Select a possible straight line.
        \+ member(Line, ExistingLines),     % Ensure the line is not already in ExistingLines.
        all_in_line(Board, Line, Player)    % Check that all positions in the line belong to the Player.
    ), NewLines),

    % Debug: If any new lines are found, print them
    (NewLines \= [] -> 
        write('New line(s) formed by '), write(Player), write(': '), write(NewLines), nl
    ; 
        write('No new lines formed by '), write(Player), nl
    ),

    length(NewLines, NewLineCount),         % Count how many new lines were formed
    write('NewLineCount: '), write(NewLineCount), nl,
    append(ExistingLines, NewLines, UpdatedLines).

% all_in_line/3 - Checks if all positions in a line are occupied by the same player
all_in_line(Board, [Pos1, Pos2, Pos3], Player) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-Player, Board),
    !.

% next_player/2 - Switches to the next player
next_player(red, black).
next_player(black, red).

% first_stage_over/2 - Checks if the stage 1 is over and identifies the winner
first_stage_over(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), second_stage_loop(NewGameState)) :-
    \+ memberchk(_-empty, Board),
    write('Play Stage complete. Transitioning game to Move Stage.'), nl,
    
    % Replace pressed pieces with empty ones using recursion
    remove_all_pressed(Board, BoardWithoutPressed, PressedFound),

    (   
        % Case 1: No pressed pieces found, allow each player to remove one piece
        PressedFound = false,
        write('No pressed pieces. Each side will remove one piece.'), nl,
        choose_piece_to_remove(Board, red, BoardAfterRedRemoval),
        display_game(game_state(BoardAfterRedRemoval, black, [RedCount, BlackCount], Lines)),
        choose_piece_to_remove(BoardAfterRedRemoval, black, FinalBoard),
        count_pieces(BoardAfterRedRemoval, red, NewRedCount),
        count_pieces(FinalBoard, black, NewBlackCount)
    ;   
        % Case 2: Pressed pieces found, update the board and counts
        PressedFound = true,
        write('Removing pressed pieces...'), nl,
        FinalBoard = BoardWithoutPressed,
        count_pieces(BoardWithoutPressed, red, NewRedCount),
        count_pieces(BoardWithoutPressed, black, NewBlackCount)
    ),

    % Prepare the game state for the second stage
    NewGameState = game_state(FinalBoard, CurrentPlayer, [NewRedCount, NewBlackCount], []).

% remove_all_pressed/3 - Recursively replaces pressed pieces with empty
remove_all_pressed([], [], false). % Base case: empty board, no pressed pieces found

remove_all_pressed([Position-pressed | Rest], [Position-empty | NewRest], true) :-
    remove_all_pressed(Rest, NewRest, _). % At least one pressed piece was found

remove_all_pressed([Other | Rest], [Other | NewRest], PressedFound) :-
    remove_all_pressed(Rest, NewRest, PressedFound).

% choose_piece_to_remove/3 - Allows a player to choose one piece to remove
choose_piece_to_remove(Board, Player, NewBoard) :-
    write(Player), write(', choose a piece to remove (e.g., a1): '), nl,
    read(Position),
    skip_line,
    valid_removal(Board, Position, Player),
    update_board(Board, Position, empty, NewBoard).

choose_piece_to_remove(Board, Player, NewBoard) :-
    write('Invalid choice. Please try again.'), nl,
    choose_piece_to_remove(Board, Player, NewBoard).

% valid_removal/3 - Checks if the chosen piece can be removed
valid_removal(Board, Position, Player) :-
    memberchk(Position-Player, Board).

% count_pieces/3 - Recursively counts the number of pieces of a given player on the board
count_pieces([], _, 0). % Base case: empty board, count is 0

count_pieces([_-Player | Rest], Player, Count) :-
    count_pieces(Rest, Player, RestCount),
    Count is RestCount + 1.

count_pieces([_ | Rest], Player, Count) :-
    count_pieces(Rest, Player, Count).

% second_stage_loop/1 - Placeholder for the second stage game loop
second_stage_loop(GameState) :-
    write('Entering the second stage (test loop).'), nl,
    write('Game state: '), write(GameState), nl,
    display_game(GameState),
    display_board(GameState).