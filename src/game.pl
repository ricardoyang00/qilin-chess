:- consult('menu.pl').
:- consult('board.pl').
:- consult('utils.pl').

forall(Condition, Action) :-
    \+ (Condition, \+ Action).

% Debug function to see board.
display_board(game_state(Board, _, [RedCount, BlackCount], _)) :-
    write('Current Board State: '),
    forall(member(Pos-Cell, Board), (write(Pos), write('-'), write(Cell), write(', '))),
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
handle_option(0) :- write('Exiting the game.'), nl, !.
handle_option(_) :- write('Invalid option. Please try again.'), nl, play.

% start_game/2 - Starts the game with the given player types
start_game(Player1, Player2) :-
    initial_state([Player1, Player2], GameState),
    game_loop(GameState).

% initial_state/2 - Sets up the initial game state with 18 pieces per player
% Initial state changed for debugging issues
initial_state([Player1, Player2], game_state(Board, Player1, [14, 14], [])) :-
    % Initialize the board with empty positions
    Board = [
        a1-red, d1-black, g1-black, 
        b2-empty, d2-black, f2-black, 
        c3-empty, d3-empty, e3-empty,
        a4-red, b4-empty, c4-empty, e4-empty, f4-empty, g4-empty, 
        c5-red, d5-empty, e5-empty,
        b6-red, d6-empty, f6-empty, 
        a7-empty, d7-empty, g7-empty
    ].

% game_loop/1 - Main game loop
game_loop(GameState) :-
    GameState = game_state(Board, CurrentPlayer, Pieces, Lines),
    display_game(GameState),
    display_board(GameState),
    game_over(GameState, Winner),
    !,
    write('Game over! Winner: '), write(Winner).

game_loop(GameState) :-
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
    game_loop(GameStateAfterMove).

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
    (   AllowPressCount = 1, % Switch player when count is 1 so when it enters game loop with all press down moves handled the game state has the next player stored, not 0 because this function won't be called
        next_player(CurrentPlayer, NextPlayer)
    ; 
        AllowPressCount \= 1,
        NextPlayer = CurrentPlayer
    ),
    !.

press_down(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), SameGameState, AllowPressCount) :-
    write('Invalid press down move. Please try again.'), nl,
    press_down(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), SameGameState, AllowPressCount).

% update_board/4 - Updates the board with the player's move
update_board([], _, _, []).

% red move
update_board([Position-empty|Rest], Position, red, [Position-red|NewRest]) :-
    update_board(Rest, Position, red, NewRest).

% black move
update_board([Position-empty|Rest], Position, black, [Position-black|NewRest]) :-
    update_board(Rest, Position, black, NewRest).

% presse down move
update_board([Position-_|Rest], Position, pressed, [Position-pressed|NewRest]) :-
    update_board(Rest, Position, pressed, NewRest).

% no match, process the rest
update_board([Other|Rest], Position, Player, [Other|NewRest]) :-
    update_board(Rest, Position, Player, NewRest).

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

% temporary game over as board filled
% game_over/2 - Checks if the game is over and identifies the winner
game_over(game_state(Board, _, _, _), testgameover) :-
    \+ memberchk(_-empty, Board).
