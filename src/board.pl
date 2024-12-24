% display_game/1 - Displays the current game state
display_game(game_state(Board, CurrentPlayer)) :-
    nl,
    write('Current Player: '), write(CurrentPlayer), nl,
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
    nl.

% print_cell/2 - Helper predicate to print a cell's content
print_cell(Board, Position) :-
    memberchk(Position-Cell, Board),
    ( 
        Cell = empty,
        write('#')
    ; 
        Cell \= empty,
        write(Cell)
    ).