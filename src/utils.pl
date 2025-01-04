remake :- reconsult('game.pl').

% Define color codes as facts
color_code(black, '\e[30m').
color_code(red, '\e[31m').
color_code(green, '\e[32m').
color_code(yellow, '\e[33m').
color_code(blue, '\e[34m').
color_code(magenta, '\e[35m').
color_code(cyan, '\e[36m').
color_code(white, '\e[37m').
color_code(reset, '\e[0m').

% write_colored_text/2 - Prints text in the specified color
write_colored_text(Color, Text) :-
    color_code(Color, Code),
    write(Code), write(Text), write('\e[0m').

% test_all_colors/0 - Tests all defined colors by printing sample text
test_all_colors :-
    write_colored_text(black, 'This is black text'),
    write_colored_text(red, 'This is red text'),
    write_colored_text(green, 'This is green text'),
    write_colored_text(yellow, 'This is yellow text'),
    write_colored_text(blue, 'This is blue text'),
    write_colored_text(magenta, 'This is magenta text'),
    write_colored_text(cyan, 'This is cyan text'),
    write_colored_text(white, 'This is white text').

% validate_input/2 - Validates that the input is an instantiated atom and returns it as output
validate_input(Input, Output) :-
    % Ensure Input is instantiated and is an atom
    nonvar(Input),                     % Input must be instantiated
    validate_atom_or_number(Input),    % Input must be an atom or number
    Output = Input.                    % Output is the same as Input (valid)

% validate_atom_or_number/1 - Ensures the input is an atom or a number
validate_atom_or_number(Input) :-
    atom(Input).
validate_atom_or_number(Input) :-
    number(Input).