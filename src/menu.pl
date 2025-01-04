:- consult('utils.pl').

logo :-
    nl,nl,nl,nl,nl,
    write('            @@           @@     @@@             @              @@@                 @@@       @@@       @@@          '), nl,
    write('             @@@         @@     @@              @@@       @@   @@   @@@            @@        @@        @@@          '), nl,
    write('       @@@@@@@@@@@@@@    @@     @@  @             @         @@ @@  @@              @@        @@         @@          '), nl,
    write('       @@  @@          @@@@ @@@ @@@@@      @@@@@@@@@@@@@       @@                  @@     @@@@@@@@@@@@@@@@@@@@      '), nl,
    write('       @@  @@   @        @@     @@         @@  @@  @@    @@@@@@@@@@@@@@@@     @@@@@@@@@@@    @@         @@          '), nl,
    write('       @@@@@@@@@@@@@@@   @@@@@@@@@         @@  @@  @@        @@@@@@@          @    @@   @    @@         @@          '), nl,
    write('       @@  @@   @   @@   @@     @@         @@ @@@ @@@@@@   @@@ @@   @@@           @@@        @@@@@@@@@@@@@          '), nl,
    write('       @@  @@   @   @@   @@     @@         @@  @@  @  @@ @@@   @@     @@@         @@@@@      @@         @@          '), nl,
    write('       @@  @@  @@@  @@   @@     @@         @@  @@  @  @@       @@@               @@@@ @@@    @@         @@          '), nl,
    write('       @@@@@@@@@@@@@@@   @@ @@@ @@         @@@@@@@@@@@@@  @@        @@          @@ @@  @@    @@@@@@@@@@@@@          '), nl,
    write('       @@  @@   @@       @@     @@         @@ @@   @@    @@@@@@ @@@@@@@@@      @@  @@        @@         @@          '), nl,
    write('       @@  @    @@       @@     @@         @@ @@   @     @@  @@     @@       @@@   @@        @@         @@          '), nl,
    write('       @   @@@@ @@@@@@ @@@@@@@@@@@@@@@     @  @@@@ @@@@@@@   @@ @@  @@             @@   @@@@@@@@@@@@@@@@@@@@@@@     '), nl,
    write('      @@   @    @@        @@@   @         @@  @@   @   @@ @@@@@ @@  @@             @@                               '), nl,
    write('      @@   @  @ @@  @@@  @@@    @@        @@  @@   @  @     @@  @@@@@@@@@@         @@         @@@@   @@@@           '), nl,
    write('     @@   @@@@  @@@@    @@       @@@     @@   @@@  @@@@    @@       @@             @@      @@@@         @@@         '), nl,
    write('     @@    @     @    @@@          @@@             @@    @@@        @@             @@   @@@@              @@@       '), nl,
    write('                      @@                                @@         @@@             @@                               '), nl,
    write('                                                                                                                    '), nl,
    write('                                                                                                                    '), nl,
    write('                      @@@@@@  @@@@ @@      @@@@ @@@    @@      @@@@@@ @@   @@ @@@@@@@ @@@@@@@ @@@@@@@               '), nl,
    write('                     @@    @@  @@  @@       @@  @@@@   @@     @@      @@   @@ @@      @@      @@                    '), nl,
    write('                     @@    @@  @@  @@       @@  @@ @@  @@     @@      @@@@@@@ @@@@@   @@@@@@@ @@@@@@@               '), nl,
    write('                     @@ @@ @@  @@  @@       @@  @@  @@ @@     @@      @@   @@ @@           @@      @@               '), nl,
    write('                      @@@@@@  @@@@ @@@@@@@ @@@@ @@   @@@@      @@@@@@ @@   @@ @@@@@@@ @@@@@@@ @@@@@@@               '), nl,
    write('                         @@                                                                                         ').

% display_menu/0 - Displays the game menu
display_menu :-
    logo,
    nl, nl, nl, nl, nl,
    write('--- Qilin Chess Menu ---'), nl, nl,
    write('1. Human vs Human'), nl,
    write('2. Human vs Computer'), nl,
    write('3. Rules'), nl,
    write('0. EXIT'), nl, nl,
    write('Choose an option'), nl.

display_difficulty_selection :-
    logo, 
    nl, nl, nl, nl, nl,
    write('--- Choose AI Difficulty ---'), nl, nl,
    write('1. Easy'), nl,
    write('2. Hard'), nl,
    write('0. Back to Menu'), nl, nl,
    write('Choose an option'), nl.

display_color_selection :-
    logo,
    nl, nl, nl, nl, nl,
    write('--- Choose Your Player ---'), nl, nl,
    write('1. Red'), nl,
    write('2. Black'), nl,
    write('0. Back to Difficulty Selection'), nl, nl,
    write('Choose an option'), nl.

display_rules :-
    nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl,
    write('--- Qilin Chess Rules ---'), nl,
    write('1. Two players ('), write_colored_text(red, 'red'), write(' and '),  write_colored_text(green, 'black'), write(')'), nl,
    write('2. The chessboard is composed of three nested squares and lines connecting the centers of the sides of the squares'), nl,
    write('     - There are 24 spots on the chessboard where you can place your pieces'), nl,
    write('3. Each side has 18 chess pieces'), nl,
    write('4. Game is divided into 2 stages, the play stage and the move stage'), nl,
    nl,
    write('--- Play Stage ---'), nl,
    write('1. '), write_colored_text(red, 'Red'), write(' Starts.'), nl,
    write('2. Each player has 18 chess pieces and takes turns placing them at the intersection of the line segments'), nl,
    write('3. If one side has 3 chess pieces arranged in a straight line (vertical, horizontal or diagonal) it can '), write_colored_text(magenta, 'Press Down'), write(' any chess piece of the other side. By pressing down means stacking a piece on top of any of the adversary''s chess piece on board'), nl,
    write('4. The '), write_colored_text(magenta, 'pressed'), write(' piece DOES NOT BELONG to any side, it can''t form a straight line with any other chess piece'), nl,
    write('Stage END:'), nl,
    write('     - When all 24 positions are filled the first stage ends and the pressed pieces (both of the stack) are removed from the board'), nl,
    write('     - If there is no pressed piece on board, both sides take 1 piece out from the board'), nl,
    nl,
    write('--- Move Stage ---'), nl,
    write('1. '), write_colored_text(green, 'Black'), write(' Starts'), nl,
    write('2. Both sides take turns to move the chess pieces to the empty postitions on the chessboard'), nl,
    write('3. By aligning 3 of its pieces in a straight line (vertical, horizontal or diagonal), a player can remove 1 opposing piece from the board'), nl,
    write('Stage END:'), nl,
    write('     - The game ends when one player has no pieces left on the board.'), nl.