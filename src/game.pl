:- consult('menu.pl').
:- consult('board.pl').

forall(Condition, Action) :-
    \+ (Condition, \+ Action).

% Debug function to see board.
display_board(Board) :-
    write('Current Board State: '),
    forall(member(Pos-Code, Board), (write(Pos), write('-'), write(Code), write(', '))),
    nl, nl.


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
initial_state([Player1, Player2], game_state(Board, Player1, [18, 18], [])) :-
    % Initialize the board with empty positions
    Board = [
        a1-empty, d1-empty, g1-empty, 
        b2-empty, d2-empty, f2-empty, 
        c3-empty, d3-empty, e3-empty,
        a4-empty, b4-empty, c4-empty, e4-empty, f4-empty, g4-empty, 
        c5-empty, d5-empty, e5-empty,
        b6-empty, d6-empty, f6-empty, 
        a7-empty, d7-empty, g7-empty
    ].

% game_loop/1 - Main game loop
game_loop(GameState) :-
    GameState = game_state(Board, CurrentPlayer, Pieces, Lines),
    display_game(GameState),
    display_board(Board),
    game_over(GameState, Winner),
    !,
    write('Game over! Winner: '), write(Winner).

game_loop(GameState) :-
    choose_move(GameState, Move),
    move(GameState, Move, NewGameState),
    game_loop(NewGameState).

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
move(game_state(Board, CurrentPlayer, [RedCount, BlackCount], Lines), Move, game_state(NewBoard, NextPlayer, [NewRedCount, NewBlackCount], NewLines)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    check_lines_formed(NewBoard, CurrentPlayer, Lines, UpdatedLines),
    ( 
        CurrentPlayer = red, NewRedCount is RedCount - 1, NewBlackCount = BlackCount 
    ; 
        CurrentPlayer = black, NewBlackCount is BlackCount - 1, NewRedCount = RedCount 
    ),

    NewLines = UpdatedLines,
    next_player(CurrentPlayer, NextPlayer).

% update_board/4 - Updates the board with the player's move
update_board([], _, _, []).

% red move
update_board([Position-empty|Rest], Position, red, [Position-red|NewRest]) :-
    update_board(Rest, Position, red, NewRest).

% black move
update_board([Position-empty|Rest], Position, black, [Position-black|NewRest]) :-
    update_board(Rest, Position, black, NewRest).

% no match, process the rest
update_board([Other|Rest], Position, Player, [Other|NewRest]) :-
    update_board(Rest, Position, Player, NewRest).

% check_lines_formed/4 - Finds newly formed lines and updates the Lines list
check_lines_formed(Board, Player, ExistingLines, UpdatedLines) :-
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

    append(ExistingLines, NewLines, UpdatedLines).

% all_in_line/3 - Checks if all positions in a line are occupied by the same player
all_in_line(Board, [Pos1, Pos2, Pos3], Player) :-
    player_code(Player, Code),
    write('Checking line: '), write([Pos1, Pos2, Pos3]), nl,
    memberchk(Pos1-Code, Board),
    memberchk(Pos2-Code, Board),
    memberchk(Pos3-Code, Board),
    !.

% player_code/2 - Maps player to their respective board codes
player_code(red, 82).  % 'R'
player_code(black, 66).  % 'B'

% next_player/2 - Switches to the next player
next_player(red, black).
next_player(black, red).

% temporary game over as board filled
% game_over/2 - Checks if the game is over and identifies the winner
game_over(game_state(Board, _), testgameover) :-
    \+ memberchk(_-empty, Board).
