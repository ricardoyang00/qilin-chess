:- consult('menu.pl').
:- consult('board.pl').

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

% initial_state/2 - Sets up the initial game state
initial_state([Player1, Player2], game_state(Board, Player1)) :-
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

% valid_position/1 - Verifies if the position input is valid
valid_position(Position) :-
    member(Position, [
        a1, d1, g1, 
        b2, d2, f2, 
        c3, d3, e3, 
        a4, b4, c4, e4, f4, g4, 
        c5, d5, e5, 
        b6, d6, f6, 
        a7, d7, g7
    ]).

% game_loop/1 - Main game loop
game_loop(GameState) :-
    display_game(GameState),
    game_over(GameState, Winner),
    !,
    write('Game over! Winner: '), write(Winner).

game_loop(GameState) :-
    GameState = game_state(_, CurrentPlayer),
    choose_move(GameState, CurrentPlayer, Move),
    move(GameState, Move, NewGameState),
    game_loop(NewGameState).

% choose_move/3 - Chooses a move for the human player
choose_move(game_state(Board, _), _, Move) :-
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
move(game_state(Board, CurrentPlayer), Move, game_state(NewBoard, NextPlayer)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    next_player(CurrentPlayer, NextPlayer).

% update_board/4 - Updates the board with the player's move
update_board([], _, _, []).

% red move
update_board([Position-empty|Rest], Position, red, [Position-82|NewRest]) :-
    update_board(Rest, Position, red, NewRest).

% black move
update_board([Position-empty|Rest], Position, black, [Position-66|NewRest]) :-
    update_board(Rest, Position, black, NewRest).

% no match, process the rest
update_board([Other|Rest], Position, Player, [Other|NewRest]) :-
    update_board(Rest, Position, Player, NewRest).

% next_player/2 - Switches to the next player
next_player(red, black).
next_player(black, red).

% temporary game over as board filled
% game_over/2 - Checks if the game is over and identifies the winner
game_over(game_state(Board, _), testgameover) :-
    \+ memberchk(_-empty, Board).
