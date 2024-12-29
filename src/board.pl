:- consult('utils.pl').

% display_game/1 - Displays the current game state
display_game(game_state(Stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount)) :-
    nl,
    write('   a       b        c       d       e        f       g   '), nl,
    nl,
    write('1  '), print_cell(Board, a1), write('------------------------'), print_cell(Board, d1), write('------------------------'), print_cell(Board, g1), nl,
    write('   | +                      |                      + |   '), nl,
    write('   |   +                    |                    +   |   '), nl,
    write('   |     +                  |                  +     |   '), nl,
    write('2  |       '), print_cell(Board, b2), write('----------------'), print_cell(Board, d2), write('----------------'), print_cell(Board, f2), write('       |   '), nl,
    write('   |       |  +             |             +  |       |   '), nl,
    write('   |       |    +           |           +    |       |   '), nl,
    write('   |       |      +         |         +      |       |   '), nl,
    write('3  |       |        '), print_cell(Board, c3), write('-------'), print_cell(Board, d3), write('-------'), print_cell(Board, e3), write('        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('4  '), print_cell(Board, a4), write('-------'), print_cell(Board, b4), write('--------'), print_cell(Board, c4), write('               '), print_cell(Board, e4), write('--------'), print_cell(Board, f4), write('-------'), print_cell(Board, g4), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('5  |       |        '), print_cell(Board, c5), write('-------'), print_cell(Board, d5), write('-------'), print_cell(Board, e5), write('        |       |   '), nl,
    write('   |       |      +         |         +      |       |   '), nl,
    write('   |       |    +           |           +    |       |   '), nl,
    write('   |       |  +             |             +  |       |   '), nl,
    write('6  |       '), print_cell(Board, b6), write('----------------'), print_cell(Board, d6), write('----------------'), print_cell(Board, f6), write('       |   '), nl,
    write('   |     +                  |                  +     |   '), nl,
    write('   |   +                    |                    +   |   '), nl,
    write('   | +                      |                      + |   '), nl,
    write('7  '), print_cell(Board, a7), write('------------------------'), print_cell(Board, d7), write('------------------------'), print_cell(Board, g7), nl, 
    nl,
    print_current_player(CurrentPlayer).

% print_cell/2 - Helper predicate to print a cell's content
print_cell(Board, Position) :-
    memberchk(Position-Cell, Board),
    ( 
        Cell = empty,
        write('#')
    ; 
        Cell == red,
        write_colored_text(red, 'R')
    ;
        Cell == black,
        write_colored_text(green, 'B')
    ;
        Cell == pressed,
        write_colored_text(magenta, 'P')
    ).

print_current_player(CurrentPlayer) :-
    write('Current Player: '), 
    (
        CurrentPlayer == red,
        write_colored_text(red, 'Red')
    ;
        CurrentPlayer == black,
        write_colored_text(green, 'Black')
    ), nl.

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

% straight_lines/0 - Define all possible straight lines on the board
straight_lines([
    % Horizontal
    [a1, d1, g1], [b2, d2, f2], [c3, d3, e3],
    [a4, b4, c4], [e4, f4, g4], [c5, d5, e5], 
    [b6, d6, f6], [a7, d7, g7],

    % Vertical
    [a1, a4, a7], [b2, b4, b6], [c3, c4, c5],
    [d1, d2, d3], [d5, d6, d7], [e3, e4, e5], 
    [f2, f4, f6], [g1, g4, g7],    

    % Diagonal
    [a1, b2, c3], [g1, f2, e3],
    [a7, b6, c5], [g7, f6, e5]
]).