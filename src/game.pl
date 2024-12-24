:- consult('menu.pl').
:- consult('board.pl').

% play/0 - Main predicate to start the game and display the menu
play :- 
    display_menu,
    read(Option),
    handle_option(Option).

% start_game/2 - Starts the game with the given player types
start_game(Player1, Player2) :-
    initial_state([Player1, Player2], GameState),
    display_game(GameState).

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