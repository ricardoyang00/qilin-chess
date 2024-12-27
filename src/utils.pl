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

% Example usage
example_usage :-
    test_all_colors.