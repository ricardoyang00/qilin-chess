:- consult('menu.pl').
:- consult('board.pl').
:- consult('utils.pl').

forall(Condition, Action) :-
    \+ (Condition, \+ Action).

% Debug function to see board.
display_board(game_state(Stage, Board, _, [RedCount, BlackCount], _, _)) :-
    write('Current Board State: '), nl,
    write('Board: '), write(Board), nl,
    write('Stage: '), write(Stage), nl,
    write('Pieces left: '), nl,
    write('Red: '), write(RedCount), nl,
    write('Black: '), write(BlackCount), nl, nl.


% play/0 - Main predicate to start the game and display the menu
play :- 
    display_menu,
    read(Option),
    skip_line,
    handle_option(Option).

% handle_option/1 - Handles the user's menu choice
handle_option(1) :- start_game(red, black).
handle_option(2) :- write('Human vs Computer mode is not implemented yet.'), nl, play.
handle_option(3) :- display_rules.
handle_option(0) :- write('Exiting the game.'), nl, !.
handle_option(_) :- write('Invalid option. Please try again.'), nl, play.

% start_game/2 - Starts the game with the given player types
start_game(Player1, Player2) :-
    initial_state([Player1, Player2], GameState),
    first_stage_loop(GameState).

% initial_state/2 - Sets up the initial game state with 18 pieces per player
% Initial state changed for debugging issues
initial_state([Player1, Player2], game_state(first_stage, Board, Player1, [7, 7], [], 0)) :-
    % Initialize the board with empty positions
    Board = [
        a1-red, d1-red, g1-black, 
        b2-black, d2-black, f2-red, 
        c3-red, d3-black, e3-empty,
        a4-black, b4-red, c4-black, e4-red, f4-black, g4-red, 
        c5-red, d5-black, e5-red,
        b6-black, d6-empty, f6-red, 
        a7-black, d7-red, g7-black
    ].

% first_stage_loop/1 - First stage loop of the game
first_stage_loop(GameState) :-
    GameState = game_state(first_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    display_game(GameState),
    display_board(GameState),
    first_stage_over(GameState, Transition),
    !,
    write('Entering the second stage (Move Stage) ...'), nl,
    Transition.

first_stage_loop(GameState) :-
    valid_moves(GameState, ValidMoves),
    write('Valid Moves: '), write(ValidMoves), nl,
    read_move(GameState, Move, ValidMoves),
    move(GameState, Move, GameStateAfterMove),
    handle_press_down_move(GameStateAfterMove).

% handle_press_down_move/1 - Handles whether to perform a press down move or continue the game loop
handle_press_down_move(GameStateAfterMove) :-
    GameStateAfterMove = game_state(first_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    AllowPressCount > 0,
    display_game(GameStateAfterMove),
    display_board(GameStateAfterMove),
    write('Moves left to press down: '), write(AllowPressCount), nl,
    press_down(GameStateAfterMove, GameStateAfterPress),
    handle_press_down_move(GameStateAfterPress).

handle_press_down_move(GameStateAfterMove) :-
    GameStateAfterMove = game_state(first_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    AllowPressCount == 0,
    next_player(CurrentPlayer, NextPlayer),
    NewGameState = game_state(first_stage, Board, NextPlayer, Pieces, Lines, 0),
    first_stage_loop(NewGameState).

% valid_moves/2 - Returns a list of all possible valid moves
valid_moves(game_state(first_stage, Board, _, _, _, _), ListOfMoves) :-
    findall(Position, member(Position-empty, Board), ListOfMoves).

valid_moves(game_state(second_stage, Board, CurrentPlayer, _, _, _), ListOfMoves) :-
    findall(Move, (
        member(From-CurrentPlayer, Board),  % Find the player's pieces
        adjacent_position(From, To),        % Get adjacent positions
        member(To-empty, Board),            % Ensure the destination is empty
        atom_concat(From, To, Move)         % Create the move string
    ), ListOfMoves).

% read_move/3 - Reads a move from the human player based on the game state
read_move(GameState, Move, ValidMoves) :-
    write('Enter your move: '),
    read(Move),
    skip_line,
    valid_position(Move),
    memberchk(Move, ValidMoves),
    !.

read_move(GameState, Move, ValidMoves) :-
    write('Enter your move: '),
    read(Move),
    skip_line,
    sub_atom(Move, 0, 2, _, From),
    sub_atom(Move, 2, 2, 0, To),
    valid_position(From),
    valid_position(To),
    memberchk(Move, ValidMoves),
    !.

read_move(GameState, Move, ValidMoves) :-
    write('Invalid move. Please try again.'), nl,
    read_move(GameState, Move, ValidMoves).

% move/3 - Validates and executes a move for the first stage
move(game_state(first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRewardMoveCount), Move, game_state(first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowRewardMoveCount)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    check_lines_formed(first_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowRewardMoveCount = NewLineCount,
    !.

% move/3 - Validates and executes a move for the second stage
move(game_state(second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRewardMoveCount), Move, game_state(second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowRewardMoveCount)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    NewRedCount = RedCount,
    NewBlackCount = BlackCount,
    check_lines_formed(second_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowRewardMoveCount = NewLineCount,
    !.

% press_down/2 - Allows the current player to press down an opponent's piece
press_down(game_state(first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), 
           game_state(first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], Lines, NewAllowPressCount)) :-
    write('You formed a line! Choose an opponent\'s piece to press down: '),
    read(PressMove),
    skip_line,
    valid_position(PressMove),
    next_player(CurrentPlayer, NextPlayer),
    memberchk(PressMove-NextPlayer, Board),
    update_board(Board, PressMove, pressed, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    NewAllowPressCount is AllowPressCount - 1,
    !.

press_down(game_state(first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), SameGameState) :-
    write('Invalid press down move. Please try again.'), nl,
    press_down(game_state(first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), SameGameState).

% update_board/4 - Updates the board with the player's move or maintains the state if no update
update_board([], _, _, []). % Base case: empty board

% First stage: Matching position, update to the new state
update_board([Position-_|Rest], Position, NewState, [Position-NewState|NewRest]) :-
    atom_length(Position, 2),
    update_board(Rest, Position, NewState, NewRest).

% First stage: No match, keep the current state and process the rest
update_board([Other|Rest], Position, NewState, [Other|NewRest]) :-
    atom_length(Position, 2),
    update_board(Rest, Position, NewState, NewRest).

% Second stage: Update the board for a move in the format a1b2
update_board(Board, Move, CurrentPlayer, NewBoard) :-
    atom_length(Move, 4),
    sub_atom(Move, 0, 2, _, From),
    sub_atom(Move, 2, 2, 0, To),
    update_board(Board, From, empty, TempBoard),
    update_board(TempBoard, To, CurrentPlayer, NewBoard).

% decrement_piece_count/4 - Decrements the piece count for the current player
decrement_piece_count(red, RedCount, BlackCount, NewRedCount, NewBlackCount) :-
    NewRedCount is RedCount - 1,
    NewBlackCount = BlackCount.

decrement_piece_count(black, RedCount, BlackCount, NewRedCount, NewBlackCount) :-
    NewBlackCount is BlackCount - 1,
    NewRedCount = RedCount.

% check_lines_formed/7 - Finds newly formed lines based on the game stage and updates the Lines list
check_lines_formed(first_stage, Move, Board, Player, ExistingLines, UpdatedLines, NewLineCount) :-
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

    length(NewLines, NewLineCount),         % Count how many new lines were formed
    write('NewLineCount: '), write(NewLineCount), nl,
    append(ExistingLines, NewLines, UpdatedLines),
    !.

check_lines_formed(second_stage, Move, Board, Player, ExistingLines, UpdatedLines, NewLineCount) :-
    % Extract the destination position from the move string (e.g., a1b4 -> b4)
    sub_atom(Move, 2, _, 0, Destination),

    straight_lines(AllPossibleLines),
    findall(Line, (
        member(Line, AllPossibleLines),     % Select a possible straight line.
        \+ member(Line, ExistingLines),     % Ensure the line is not already in ExistingLines.
        all_in_line(Board, Line, Player),   % Check that all positions in the line belong to the Player.
        member(Destination, Line)                  % Ensure the moved piece forms the line.
    ), NewLines),

    % Debug: If any new lines are found, print them
    (NewLines \= [] -> 
        write('New line(s) formed by '), write(Player), write(': '), write(NewLines), nl
    ; 
        write('No new lines formed by '), write(Player), nl
    ),

    length(NewLines, NewLineCount),         % Count how many new lines were formed
    write('NewLineCount: '), write(NewLineCount), nl,
    append(ExistingLines, NewLines, UpdatedLines),
    !.

% all_in_line/3 - Checks if all positions in a line are occupied by the same player
all_in_line(Board, [Pos1, Pos2, Pos3], Player) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-Player, Board),
    !.

% next_player/2 - Switches to the next player
next_player(red, black).
next_player(black, red).

% first_stage_over/2 - Checks if the stage 1 is over and handles the board
first_stage_over(GameState, second_stage_loop(NewGameState)) :-
    GameState = game_state(Stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    \+ memberchk(_-empty, Board),
    write('Play Stage complete. Transitioning game to Move Stage.'), nl,
    
    % Replace pressed pieces with empty ones using recursion
    remove_all_pressed(Board, BoardWithoutPressed, PressedFound),
    handle_pressed_pieces(PressedFound, GameState, BoardWithoutPressed, NewGameState).

% handle_pressed_pieces/4 - Handles the cases based on whether pressed pieces were found
handle_pressed_pieces(false, game_state(Stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), BoardWithoutPressed, NewGameState) :-
    write('No pressed pieces. Each side will remove one piece.'), nl,
    choose_piece_to_remove(Board, red, BoardAfterRedRemoval),
    display_game(game_state(Stage, BoardAfterRedRemoval, black, [RedCount, BlackCount], Lines, AllowPressCount)),
    choose_piece_to_remove(BoardAfterRedRemoval, black, FinalBoard),
    count_pieces(BoardAfterRedRemoval, red, NewRedCount),
    count_pieces(FinalBoard, black, NewBlackCount),
    next_player(CurrentPlayer, NextPlayer),
    NewGameState = game_state(second_stage, FinalBoard, NextPlayer, [NewRedCount, NewBlackCount], [], 0).

handle_pressed_pieces(true, game_state(Stage, _, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), BoardWithoutPressed, NewGameState) :-
    write('Removing pressed pieces...'), nl,
    FinalBoard = BoardWithoutPressed,
    count_pieces(BoardWithoutPressed, red, NewRedCount),
    count_pieces(BoardWithoutPressed, black, NewBlackCount),
    next_player(CurrentPlayer, NextPlayer),
    NewGameState = game_state(second_stage, FinalBoard, NextPlayer, [NewRedCount, NewBlackCount], [], 0).

% remove_all_pressed/3 - Recursively replaces pressed pieces with empty
remove_all_pressed([], [], false). % Base case: empty board, no pressed pieces found

remove_all_pressed([Position-pressed | Rest], [Position-empty | NewRest], true) :-
    remove_all_pressed(Rest, NewRest, _). % At least one pressed piece was found

remove_all_pressed([Other | Rest], [Other | NewRest], PressedFound) :-
    remove_all_pressed(Rest, NewRest, PressedFound).

% choose_piece_to_remove/3 - Allows a player to choose one piece to remove
choose_piece_to_remove(Board, Player, NewBoard) :-
    write(Player), write(', choose a piece to remove (e.g., a1): '), nl,
    read(Position),
    skip_line,
    valid_removal(Board, Position, Player),
    update_board(Board, Position, empty, NewBoard).

choose_piece_to_remove(Board, Player, NewBoard) :-
    write('Invalid choice. Please try again.'), nl,
    choose_piece_to_remove(Board, Player, NewBoard).

% valid_removal/3 - Checks if the chosen piece can be removed
valid_removal(Board, Position, Player) :-
    memberchk(Position-Player, Board).

% count_pieces/3 - Recursively counts the number of pieces of a given player on the board
count_pieces([], _, 0). % Base case: empty board, count is 0

count_pieces([_-Player | Rest], Player, Count) :-
    count_pieces(Rest, Player, RestCount),
    Count is RestCount + 1.

count_pieces([_ | Rest], Player, Count) :-
    count_pieces(Rest, Player, Count).

% second_stage_loop/1 - Second stage loop of the game
second_stage_loop(GameState) :-
    GameState = game_state(second_stage, Board, CurrentPlayer, Pieces, Lines, AllowRemoveCount),
    display_game(GameState),
    display_board(GameState),
    game_over(GameState, Winner),
    !,
    write('GAME OVER, WINNER IS: '), write(Winner), nl.

second_stage_loop(GameState) :-
    valid_moves(GameState, []),  % No valid moves left
    GameState = game_state(_, _, CurrentPlayer, _, _, _),
    write('Valid Moves: []'), nl,
    write('YOU HAVE NO VALID MOVES LEFT'), nl,
    next_player(CurrentPlayer, Winner),
    write('GAME OVER, WINNER IS: '), write(Winner), nl.
    
second_stage_loop(GameState) :-
    valid_moves(GameState, ValidMoves),
    ValidMoves \= [],
    write('Valid Moves: '), write(ValidMoves), nl,
    read_move(GameState, Move, ValidMoves),
    move(GameState, Move, GameStateAfterMove),
    handle_remove_move(GameStateAfterMove, GameStateAfterRemove),
    update_lines(GameStateAfterRemove, GameStateAfterLinesUpdate),
    second_stage_loop(GameStateAfterLinesUpdate).

% handle_remove_move/2 - Handles whether to perform a remove move or continue the game loop
handle_remove_move(GameStateAfterMove, GameStateAfterRemove) :-
    GameStateAfterMove = game_state(second_stage, Board, CurrentPlayer, Pieces, Lines, AllowRemoveCount),
    AllowRemoveCount > 0,
    display_game(GameStateAfterMove),
    display_board(GameStateAfterMove),
    write('Moves left to remove: '), write(AllowRemoveCount), nl,
    remove(GameStateAfterMove, TempGameStateAfterRemove),
    handle_remove_move(TempGameStateAfterRemove, GameStateAfterRemove).

handle_remove_move(GameStateAfterMove, GameStateAfterRemove) :-
    GameStateAfterMove = game_state(second_stage, Board, CurrentPlayer, Pieces, Lines, AllowRemoveCount),
    AllowRemoveCount == 0,
    next_player(CurrentPlayer, NextPlayer),
    GameStateAfterRemove = game_state(second_stage, Board, NextPlayer, Pieces, Lines, 0).

% remove/2 - Allows the current player to remove an opponent's piece
remove(game_state(second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount), 
       game_state(second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], Lines, NewAllowRemoveCount)) :-
    write('You formed a line! Choose an opponent\'s piece to remove: '),
    read(RemoveMove),
    skip_line,
    valid_position(RemoveMove),
    next_player(CurrentPlayer, NextPlayer),
    memberchk(RemoveMove-NextPlayer, Board),
    update_board(Board, RemoveMove, empty, NewBoard),
    decrement_piece_count(NextPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    NewAllowRemoveCount is AllowRemoveCount - 1,
    !.

remove(game_state(second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount), SameGameState) :-
    write('Invalid remove move. Please try again.'), nl,
    remove(game_state(second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount), SameGameState).

% update_lines/2 - Updates the Lines in the game state based on the current board
update_lines(game_state(Stage, Board, CurrentPlayer, Pieces, OldLines, AllowRemoveCount), 
             game_state(Stage, Board, CurrentPlayer, Pieces, NewLines, AllowRemoveCount)) :-
    straight_lines(StraightLines),
    findall(Line, (member(Line, StraightLines), all_same_player(Board, Line)), NewLines),
    write('OldLines: '), write(OldLines), nl,
    write('NewLines: '), write(NewLines), nl.

% all_same_player/2 - Verifies that all positions in a line are occupied by the same player
all_same_player(Board, [Pos1, Pos2, Pos3]) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-Player, Board),
    Player \= empty.

% game_over/2 - Checks if the game is over and identifies the winner
game_over(game_state(_, _, _, [RedCount, _], _, _), black) :-
    RedCount = 0.
game_over(game_state(_, _, _, [_, BlackCount], _, _), red) :-
    BlackCount = 0.