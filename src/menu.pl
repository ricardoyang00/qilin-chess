:- consult('utils.pl').

% logo/0 - Displays the game logo
logo :-
    nl,nl,nl,nl,nl,
    write('            @@           @@     @@              @              @@@                 @@        @@         @@          '), nl,
    write('             @@@         @@     @@              @@@       @@   @@   @@@            @@        @@         @@          '), nl,
    write('       @@@@@@@@@@@@@@    @@     @@                @         @@ @@  @@              @@        @@         @@          '), nl,
    write('       @@  @@          @@@@ @@@ @@@@@      @@@@@@@@@@@@@       @@                  @@     @@@@@@@@@@@@@@@@@@@@      '), nl,
    write('       @@  @@   @        @@     @@         @@  @@  @@    @@@@@@@@@@@@@@@@     @@@@@@@@@@@    @@         @@          '), nl,
    write('       @@@@@@@@@@@@@@@   @@@@@@@@@         @@  @@  @@        @@@@@@@               @@        @@         @@          '), nl,
    write('       @@  @@   @   @@   @@     @@         @@ @@@@@@@@@@   @@@ @@   @@@           @@@        @@@@@@@@@@@@@          '), nl,
    write('       @@  @@   @   @@   @@     @@         @@  @@  @@ @@ @@@   @@     @@@         @@@@@      @@         @@          '), nl,
    write('       @@  @@  @@@  @@   @@     @@         @@  @@  @@ @@       @@@               @@@@ @@     @@         @@          '), nl,
    write('       @@@@@@@@@@@@@@@   @@ @@@ @@         @@ @@@@@@@@@@  @@        @@          @@ @@  @@    @@@@@@@@@@@@@          '), nl,
    write('       @@  @@   @@       @@     @@         @@ @@   @@    @@@@@@ @@@@@@@@@      @@  @@        @@         @@          '), nl,
    write('       @@  @    @@       @@     @@         @@ @@   @     @@  @@     @@       @@@   @@        @@         @@          '), nl,
    write('       @   @@@@ @@@@@@ @@@@@@@@@@@@@@@     @  @@@@ @@@@@@@   @@ @@  @@             @@   @@@@@@@@@@@@@@@@@@@@@@@     '), nl,
    write('      @@   @    @@        @@@   @         @@  @@   @   @@ @@@@@ @@  @@             @@                               '), nl,
    write('      @@   @  @ @@  @@@  @@@    @@        @@  @@   @  @     @@  @@@@@@@@@@         @@         @@@@   @@@@           '), nl,
    write('     @@    @@@  @@@@    @@       @@@     @@   @@@  @@@@    @@       @@             @@      @@@@         @@@         '), nl,
    write('     @@    @     @    @@@          @@@             @@    @@@        @@             @@   @@@@              @@@       '), nl,
    write('                      @@                                @@          @@             @@                               '), nl,
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
    write('4. Load Game'), nl,
    write('5. Special Commands'), nl,
    write('0. EXIT'), nl, nl,
    write('Choose an option'), nl.

% display_difficulty_selection/0 - Displays the AI difficulty selection menu
display_difficulty_selection :-
    logo, 
    nl, nl, nl, nl, nl,
    write('--- Choose AI Difficulty ---'), nl, nl,
    write('1. Easy'), nl,
    write('2. Hard'), nl,
    write('0. Back to Menu'), nl, nl,
    write('Choose an option'), nl.

% display_color_selection/0 - Displays the color selection menu
display_color_selection :-
    logo,
    nl, nl, nl, nl, nl,
    write('--- Choose Your Player ---'), nl, nl,
    write('1. Red'), nl,
    write('2. Black'), nl,
    write('0. Back to Difficulty Selection'), nl, nl,
    write('Choose an option'), nl.

% display_rules/0 - Displays the game rules
display_rules :-
    nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl,
    write('--- Qilin Chess Rules ---'), nl, nl,
    write('1. Two players ('), write_colored_text(red, 'red'), write(' and '),  write_colored_text(green, 'black'), write(')'), nl,
    write('2. The chessboard is composed of three nested squares and lines connecting the centers of the sides of the squares'), nl,
    write('     - There are 24 spots on the chessboard where you can place your pieces'), nl,
    write('3. Each side has 18 chess pieces'), nl,
    write('4. Game is divided into 2 main stages, the play stage and the move stage, and 1 secondary stage, the transition stage'), nl,
    nl,
    write('--- First Stage (Play Stage) ---'), nl, nl,
    write('1. '), write_colored_text(red, 'Red'), write(' Starts.'), nl,
    write('2. Each player has 18 chess pieces and takes turns placing them at the intersection of the line segments'), nl,
    write('3. If one side has 3 chess pieces arranged in a straight line (vertical, horizontal or diagonal) it can '), write_colored_text(yellow, 'Press Down'), write(' any chess piece of the other side. By pressing down means stacking a piece on top of any of the adversary''s chess piece on board'), nl,
    write('4. The '), write_colored_text(yellow, 'pressed'), write(' piece DOES NOT BELONG to any side, it can''t form a straight line with any other chess piece'), nl,
    write('Stage END:'), nl,
    write('     - When all 24 positions are filled the first stage ends.'), nl,
    nl,
    write('--- Transition Stage ---'), nl, nl,
    write('1. When First Stage ends, the pressed pieces (both of the stack) are removed from the board'), nl,
    write('2. If there is no pressed piece on board, both sides take 1 own piece out from the board'), nl,
    write('Stage END:'), nl,
    write('     - When the pieces are removed the transition stage ends.'), nl,
    nl,
    write('--- Second Stage (Move Stage) ---'), nl, nl,
    write('1. '), write_colored_text(green, 'Black'), write(' Starts'), nl,
    write('2. Both sides take turns to move the chess pieces to the empty postitions on the chessboard'), nl,
    write('3. By aligning 3 of its pieces in a straight line (vertical, horizontal or diagonal), a player can remove 1 opposing piece from the board'), nl,
    write('Stage END:'), nl,
    write('     - The game ends when one player has no pieces left on the board.'), nl, nl, nl.

% display_commands/0 - Display some commands that can be used midgame
display_commands :-
    nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl, nl,
    write('--- Special Commands ---'), nl, nl,
    write('1. forfeit. -> Forfeits the game and declares the opponent as the winner.'), nl,
    write('2. save. -> Saves the current game state to a file (in the working directory). You can load this saved game by selecting option 4 (Load Game) from the menu and entering the filename.'), nl, nl,
    write('NOTE:'), nl,
    write('      These commands may not be available in certain phases of the game.'), nl,
    nl, nl.

% game_over_display/1 - Displays the text winner is red
game_over_display(red) :-
    nl,nl,nl,nl,nl,
    game_over_text,
    write('       @@     @@ @@ @@@    @@ @@@    @@ @@@@@@@ @@@@@@      @@ @@@@@@@     '), write_colored_text(red,'@@@@@@  @@@@@@@ @@@@@@ '), write('     @@ @@ @@    '), nl, 
    write('       @@     @@ @@ @@@@   @@ @@@@   @@ @@      @@   @@     @@ @@          '), write_colored_text(red,'@@   @@ @@      @@   @@'), write('     @@ @@ @@    '), nl, 
    write('       @@  @  @@ @@ @@ @@  @@ @@ @@  @@ @@@@@   @@@@@@      @@ @@@@@@@     '), write_colored_text(red,'@@@@@@  @@@@@   @@   @@'), write('     @@ @@ @@    '), nl, 
    write('       @@ @@@ @@ @@ @@  @@ @@ @@  @@ @@ @@      @@   @@     @@      @@     '), write_colored_text(red,'@@   @@ @@      @@   @@'), write('                 '), nl,
    write('        @@@ @@@  @@ @@   @@@@ @@   @@@@ @@@@@@@ @@   @@     @@ @@@@@@@     '), write_colored_text(red,'@@   @@ @@@@@@@ @@@@@@ '), write('     @@ @@ @@    '), nl,
    nl, nl, nl.

% game_over_display/1 - Displays the text winner is black
game_over_display(black) :-
    nl,nl,nl,nl,nl,
    game_over_text,
    write('     @@     @@ @@ @@@    @@ @@@    @@ @@@@@@@ @@@@@@      @@ @@@@@@@     '), write_colored_text(green,'@@@@@@  @@       @@@@@   @@@@@@ @@   @@'), write('     @@ @@ @@    '), nl,
    write('     @@     @@ @@ @@@@   @@ @@@@   @@ @@      @@   @@     @@ @@          '), write_colored_text(green,'@@   @@ @@      @@   @@ @@      @@  @@ '), write('     @@ @@ @@    '), nl,
    write('     @@  @  @@ @@ @@ @@  @@ @@ @@  @@ @@@@@   @@@@@@      @@ @@@@@@@     '), write_colored_text(green,'@@@@@@  @@      @@@@@@@ @@      @@@@@  '), write('     @@ @@ @@    '), nl,
    write('     @@ @@@ @@ @@ @@  @@ @@ @@  @@ @@ @@      @@   @@     @@      @@     '), write_colored_text(green,'@@   @@ @@      @@   @@ @@      @@  @@ '), write('                 '), nl,
    write('      @@@ @@@  @@ @@   @@@@ @@   @@@@ @@@@@@@ @@   @@     @@ @@@@@@@     '), write_colored_text(green,'@@@@@@  @@@@@@@ @@   @@  @@@@@@ @@   @@'), write('     @@ @@ @@    '), nl,
    nl, nl, nl.

% game_over_text/0 - Displays a text that represents game over
game_over_text :-                                                                                                                                                                                                                                                                              
    write('            .-:       :-:              .-:        .-:. ..                  .-:.                  .:.        :-:             '), nl,               
    write('      :----=*@%+=----=*@%=----:.      .-#%=.      :#*::+#+.              .=#@#-......           :*#=       .+%+.            '), nl,               
    write('     .-++++*#@@*++++++#@%*++++=.  .*%%%@@@@@@@%#-.:#*: .=#*-         .-*%@@@@@@@@@@@%=.        .+%+:.-*#%%%%@@@%%%%%%#=.    '), nl,               
    write('           .-++:.    .=*+:::.      :::::::::::::..-%#:  .-=:     -*#%%%#+-:.....:=%%+.        .+#+..:-----=%@*=-------.     '), nl,               
    write('       .=+*******###%%%@@@%%+:     .=+*****+*+--+#%@@%%%%%%*-    :==-:.-++:   .-*%#=.         =%*:.=#*-...=%#-.             '), nl,               
    write('       .-=++++=====-:::...--.      :#@*====+#@*:.:+%#+*%*-::           .=#%+=*%%*-.         .=%%+=*%#=+%@@@@@@@%+.          '), nl,               
    write('         -#+:   :+#=    .+%*:      :#%-    .+%*.  -%*:+%+.         :-==*#@@@#+-::==.        .+##*#@#- ..-#@+::*%+.          '), nl,               
    write('         .+%+.   =#+.  -*%+:       :#@%****#%@*. .=%+:+%+.        .=###*+=:...-*%%+:.          .-##-   .+%*:.:*%+.          '), nl,               
    write('          .==.   :+=.  .:.          :--=*%#=--:  .*%=.+%+.              ..-+#@@@@@@@@@@@#:    .=#*:....-#@@@@@@@@@@@@%=.    '), nl,               
    write('      -**########@@@#########*=.   .=*-.=%*-++:  -%%-.+%+.         :+#%%%%#+-.......:+%%=.   :*@@##%%#: .....:*@*:....      '), nl,               
    write('      :======+*%@@@@%@#+======:.   -#%-.=%*-=%*:.+@+..+%+. ::       :--:::=+=.    .=#%*:     -*#*+=:..  :**: .*@+.:++:      '), nl,               
    write('           .-+#+-+%*-=**=:        .+%+..=%+::+*-=%#- .+%+.:**:            :*%*-:-*%%*-.            ....:*%+. .*%+..=%*:     '), nl,               
    write('       .:+#%#=: .+%*. .-*##*=:    -*+. .=%+. .:+%#-  .+%+.-**:           .:=#@@@%*-.         .:-=*#%%*+#%=.  .*@+. .+%+.    '), nl,               
    write('     :+%%#+-.    =%*.    :-*#%*-   ...-=*%+.  =%#-   .=%%###=.   -+**###%%%#*+=:.           -#%#*+=-::+#+..-=+%@+.  :**-    '), nl,               
    write('      ::.        -*=.       .::.     .=**=.   :-:     .-+++-.    :+++===-:..                ...       ... .+**+=:    ..     '), nl,
    write('                                                                                                                            '), nl,
    write('                                                                                                                            '), nl,
    write('                                                                                                                            '), nl,
    write('                      @@@@@@   @@@@@  @@@    @@@ @@@@@@@      @@@@@@  @@    @@ @@@@@@@ @@@@@@                               '), nl,
    write('                     @@       @@   @@ @@@@  @@@@ @@          @@    @@ @@    @@ @@      @@   @@                              '), nl,
    write('                     @@   @@@ @@@@@@@ @@ @@@@ @@ @@@@@       @@    @@ @@    @@ @@@@@   @@@@@@                               '), nl,
    write('                     @@    @@ @@   @@ @@  @@  @@ @@          @@    @@  @@  @@  @@      @@   @@                              '), nl,
    write('                      @@@@@@  @@   @@ @@      @@ @@@@@@@      @@@@@@    @@@@   @@@@@@@ @@   @@                              '), nl,
    nl, nl.
             