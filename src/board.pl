:- consult('utils.pl').

% display_game/1 - Displays the current game state
display_game(game_state(_PlayerTypes, Stage, Board, CurrentPlayer, _Pieces, _Lines, _AllowRewardMoveCount)) :-
    nl,
    draw_stage_box(Stage),
    nl,
    write('7  '), print_cell(Board, a7), write('------------------------'), print_cell(Board, d7), write('------------------------'), print_cell(Board, g7), nl,
    write('   | +                      |                      + |   '), nl,
    write('   |   +                    |                    +   |   '), nl,
    write('   |     +                  |                  +     |   '), nl,
    write('6  |       '), print_cell(Board, b6), write('----------------'), print_cell(Board, d6), write('----------------'), print_cell(Board, f6), write('       |   '), nl,
    write('   |       |  +             |             +  |       |   '), nl,
    write('   |       |    +           |           +    |       |   '), nl,
    write('   |       |      +         |         +      |       |   '), nl,
    write('5  |       |        '), print_cell(Board, c5), write('-------'), print_cell(Board, d5), write('-------'), print_cell(Board, e5), write('        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('4  '), print_cell(Board, a4), write('-------'), print_cell(Board, b4), write('--------'), print_cell(Board, c4), write('               '), print_cell(Board, e4), write('--------'), print_cell(Board, f4), write('-------'), print_cell(Board, g4), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('   |       |        |               |        |       |   '), nl,
    write('3  |       |        '), print_cell(Board, c3), write('-------'), print_cell(Board, d3), write('-------'), print_cell(Board, e3), write('        |       |   '), nl,
    write('   |       |      +         |         +      |       |   '), nl,
    write('   |       |    +           |           +    |       |   '), nl,
    write('   |       |  +             |             +  |       |   '), nl,
    write('2  |       '), print_cell(Board, b2), write('----------------'), print_cell(Board, d2), write('----------------'), print_cell(Board, f2), write('       |   '), nl,
    write('   |     +                  |                  +     |   '), nl,
    write('   |   +                    |                    +   |   '), nl,
    write('   | +                      |                      + |   '), nl,
    write('1  '), print_cell(Board, a1), write('------------------------'), print_cell(Board, d1), write('------------------------'), print_cell(Board, g1), nl, 
    nl,
    write('   a       b        c       d       e        f       g   '), nl,
    nl,
    draw_current_player_box(CurrentPlayer),
    nl.

% print_cell/2 - Helper predicate to print a cell's content
print_cell(Board, Position) :-
    memberchk(Position-Cell, Board),
    print_cell_content(Cell).

% print_cell_content/1 - Prints the content of a cell
print_cell_content(empty) :-
    write('#').

print_cell_content(red) :-
    write_colored_text(red, 'R').

print_cell_content(black) :-
    write_colored_text(green, 'B').

print_cell_content(pressed) :-
    write_colored_text(yellow, 'P').

% draw_stage_box/1 - Draws the box for the current game stage
draw_stage_box(Stage) :-
    put_code(9556), % Draw the top-left corner
    draw_horizontal_line(52), % Draw the horizontal line
    put_code(9559), nl, % Draw the top-right corner
    draw_vertical_lines(3, Stage), % Draw the vertical lines
    put_code(9562), % Draw the bottom-left corner
    draw_horizontal_line(52), % Draw the horizontal line
    put_code(9565), nl. % Draw the bottom-right corner

% draw_current_player_box/1 - Draws the box for the current player
draw_current_player_box(CurrentPlayer) :-
    put_code(9556), 
    draw_horizontal_line(52), 
    put_code(9559), nl,
    draw_vertical_lines(3, CurrentPlayer),
    put_code(9562),
    draw_horizontal_line(52),
    put_code(9565), nl.

% draw_horizontal_line/1 - Draws a horizontal line with the specified length
draw_horizontal_line(0) :- !.
draw_horizontal_line(N) :-
    N > 0,
    put_code(9552),
    N1 is N - 1,
    draw_horizontal_line(N1).

% draw_vertical_lines/2 - Draws vertical lines with the specified height and prints the text in the middle
draw_vertical_lines(Height, Text) :-
    Middle is (Height + 1) // 2,
    draw_vertical_lines(Height, Text, Middle).

draw_vertical_lines(0, _Text, _Middle) :- !.

draw_vertical_lines(N, Text, Middle) :-
    N > 0,
    N = Middle,
    draw_middle_line(Text),
    N1 is N - 1,
    draw_vertical_lines(N1, Text, Middle).

draw_vertical_lines(N, Text, Middle) :-
    N > 0,
    N < Middle,   % This ensures N is not equal to Middle and it's less than Middle
    draw_regular_line,
    N1 is N - 1,
    draw_vertical_lines(N1, Text, Middle).

draw_vertical_lines(N, Text, Middle) :-
    N > 0,
    N > Middle,   % This handles the case where N is greater than Middle
    draw_regular_line,
    N1 is N - 1,
    draw_vertical_lines(N1, Text, Middle).

% draw_middle_line/1 - Draws the middle line with the text
draw_middle_line(first_stage) :-
    put_code(9553), % Draw the left vertical line
    draw_spaces(14),
    write('First Stage (Play Stage)'),
    draw_spaces(14),
    put_code(9553), nl. % Draw the right vertical line

draw_middle_line(second_stage) :-
    put_code(9553),
    draw_spaces(13),
    write('Second Stage (Move Stage)'),
    draw_spaces(14),
    put_code(9553), nl.

draw_middle_line(transition_stage) :-
    put_code(9553),
    draw_spaces(18),
    write('Transition Stage'),
    draw_spaces(18),
    put_code(9553), nl.

draw_middle_line(red) :-
    put_code(9553),
    draw_spaces(15),
    write('Current Player => '), write_colored_text(red, 'Red'),
    draw_spaces(16),
    put_code(9553), nl.

draw_middle_line(black) :-
    put_code(9553),
    draw_spaces(14),
    write('Current Player => '), write_colored_text(green, 'Black'),
    draw_spaces(15),
    put_code(9553), nl.

% draw_regular_line/0 - Draws a regular line without the text in the middle
draw_regular_line :-
    put_code(9553), % Draw the left vertical line
    draw_spaces(52),
    put_code(9553), nl. % Draw the right vertical line

% draw_spaces/1 - Draws a specified number of spaces
draw_spaces(0) :- !.
draw_spaces(N) :-
    N > 0,
    write(' '),
    N1 is N - 1,
    draw_spaces(N1).

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

% adjacency_list/1 - Defines the adjacency relationships for second stage moves
adjacency_list([
    [a1, a4, b2, d1], [d1, a1, d2, g1], [g1, d1, f2, g4],
    [b2, a1, b4, c3, d2], [d2, b2, d3, d1, f2], [f2, d2, e3, f4, g1],
    [c3, b2, c4, d3], [d3, c3, d2, e3], [e3, d3, e4, f2],
    [a4, a7, a1, b4], [b4, a4, b6, b2, c4], [c4, b4, c5, c3],
    [e4, e5, e3, f4], [f4, e4, f6, f2, g4], [g4, f4, g7, g1],
    [c5, b6, c4, d5], [d5, c5, d6, e5], [e5, d5, e4, f6],
    [b6, a7, b4, c5, d6], [d6, b6, d7, d5, f6], [f6, d6, e5, f4, g7],
    [a7, a4, b6, d7], [d7, a7, d6, g7], [g7, d7, f6, g4]
]).

% adjacent_position/2 - Checks if two positions are adjacent
adjacent_position(Pos1, Pos2) :-
    adjacency_list(AdjList),
    member([Pos1 | Rest], AdjList),
    member(Pos2, Rest).
    