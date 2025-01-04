:- consult('menu.pl').
:- consult('board.pl').
:- consult('utils.pl').

:- use_module(library(random)).
:- use_module(library(lists)).

% Debug function to see board.
display_board(game_state(PlayerTypes, Stage, Board, CurrentPlayer, [RedCount, BlackCount], _, _)) :-
    nth1(CurrentPlayerIndex, [red, black], CurrentPlayer),
    nth1(CurrentPlayerIndex, PlayerTypes, PlayerType),
    write('Player Type: '), write(PlayerType), nl.
    write('Current Board State: '), nl,
    write('Board: '), write(Board), nl,
    write('Stage: '), write(Stage), nl,
    write('Pieces left: '), nl,
    write('Red: '), write(RedCount), nl,
    write('Black: '), write(BlackCount), nl, nl.


% play/0 - Main predicate to start the game and display the menu
play :- 
    repeat,
    display_menu,
    catch(read(UserInput), _, invalid_menu_input),
    skip_line,
    handle_option(UserInput, Continue),
    continue_play_loop(Continue).

% continue_play_loop/1 - Determines whether to continue the play loop
continue_play_loop(false) :- !.
continue_play_loop(true) :- fail.

% handle_option/2 - Handles the user's menu choice
handle_option(1, true) :- 
    write('Starting Human vs Human game...'), nl,
    start_game(human, human),
    fail.

handle_option(2, true) :- 
    write('Starting Human vs Computer game...'), nl,
    start_game(human, computer-2),
    fail.

handle_option(3, true) :- 
    display_rules,
    fail.

handle_option(0, false) :-
    write('Exiting the game. Goodbye!'), nl.

handle_option(_, true) :-
    write('Invalid option. Please choose a valid option from 0-3.'), nl,
    fail.

% invalid_menu_input/0 - Handles invalid menu input
invalid_menu_input :-
    write('Invalid input. Please enter a number between 0 and 3.'), nl,
    fail.

% start_game/2 - Starts the game with the given player types
start_game(Player1Type, Player2Type) :-
    initial_state([Player1Type, Player2Type], GameState),
    first_stage_loop(GameState).

% initial_state/2 - Sets up the initial game state with 18 pieces per player
% Initial state changed for debugging issues
initial_state([Player1Type, Player2Type], game_state([Player1Type, Player2Type], first_stage, Board, red, [7, 7], [], 0)) :-
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

% get_player_type/3 - Determines the player type based on the current player
get_player_type(CurrentPlayer, PlayerTypes, PlayerType) :-
    nth1(CurrentPlayerIndex, [red, black], CurrentPlayer),
    nth1(CurrentPlayerIndex, PlayerTypes, PlayerType).

% first_stage_loop/1 - First stage loop of the game
first_stage_loop(GameState) :-
    GameState = game_state(PlayerTypes, first_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    display_game(GameState),
    display_board(GameState),
    first_stage_over(GameState, Transition),
    !,
    write('Entering the second stage (Move Stage) ...'), nl,
    Transition.

first_stage_loop(GameState) :-
    GameState = game_state(PlayerTypes, first_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    choose_move(GameState, PlayerType, Move),
    move(GameState, Move, GameStateAfterMove),
    handle_press_down_move(GameStateAfterMove).

% choose_move/3 - Chooses a move based on the player type
choose_move(GameState, human, Move) :-
    read_move(GameState, Move).

choose_move(GameState, computer-Level, Move) :-
    valid_moves(GameState, ValidMoves),
    choose_move(Level, GameState, ValidMoves, Move).

% choose_move/4 - Chooses a move for the computer based on the difficulty level
choose_move(1, _GameState, ValidMoves, Move) :-
    random_select(Move, ValidMoves, _Rest),
    write('Level 1 AI chooses move: '), write(Move), nl.

choose_move(2, game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowRewardMoveCount), ValidMoves, BestMove) :-
    write('Valid Moves: '), write(ValidMoves), nl,
    findall(Value-Move,
        (member(Move, ValidMoves),
        write('Move: '), write(Move), nl,
         simulate_remove_choice(game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowRewardMoveCount), Move, SimulatedGameState),
         value(SimulatedGameState, CurrentPlayer, Value)),   % Evaluate the state
        MoveValues),

    % Sort the moves by value in ascending order and then reverse to get descending order
    keysort(MoveValues, SortedMoveValues),
    reverse(SortedMoveValues, ReversedMoveValues),

    % Extract the best value
    ReversedMoveValues = [BestValue-_|_],

    % Collect all moves with the best value
    findall(Move, member(BestValue-Move, ReversedMoveValues), BestMoves),

    % Randomly select one of the best moves
    random_member(BestMove, BestMoves),

    write('Reversed Value-Move pairs: '), write(ReversedMoveValues), nl,
    write('Best Moves: '), write(BestMoves), nl,
    write('Level 2 AI chooses move: '), write(BestMove), nl.

choose_move(2, GameState, ValidMoves, BestMove) :-
    findall(Value-Move,
        (member(Move, ValidMoves),
         move(GameState, Move, SimulatedGameState), % Simulate the move
         GameState = game_state(_, _, Board, CurrentPlayer, Pieces, Lines, AllowRewardMoveCount),
         value(SimulatedGameState, CurrentPlayer, Value)),   % Evaluate the state
        MoveValues),

    % Sort the moves by value in ascending order and then reverse to get descending order
    keysort(MoveValues, SortedMoveValues),
    reverse(SortedMoveValues, ReversedMoveValues),

    % Extract the best value
    ReversedMoveValues = [BestValue-_|_],

    % Collect all moves with the best value
    findall(Move, member(BestValue-Move, ReversedMoveValues), BestMoves),

    % Randomly select one of the best moves
    random_member(BestMove, BestMoves),

    write('Reversed Value-Move pairs: '), write(ReversedMoveValues), nl,
    write('Best Moves: '), write(BestMoves), nl,
    write('Level 2 AI chooses move: '), write(BestMove), nl.

% simulate_remove_choice/3 - Simulates the removal of a piece for computer player in transition stage
simulate_remove_choice(GameState, Position, NewGameState) :-
    valid_position(Position),
    GameState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    update_board(Board, Position, empty, NewBoard),
    NewGameState = game_state(PlayerTypes, transition_stage, NewBoard, CurrentPlayer, Pieces, Lines, AllowPressCount).

% value/3 - Evaluates the desirability of a game state for the current player
value(game_state(_, transition_stage, Board, CurrentPlayer, _, Lines, _), CurrentPlayer, Value) :-
    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),
    write('CountPotentialLines: '), write(OpponentPotentialLines), nl,

    % Count potential lines for the current player
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),
    write('CurrentPlayerPotentialLines: '), write(CurrentPlayerPotentialLines), nl,

    % Evaluate mobility for the current player
    valid_moves(game_state(_, transition_stage, Board, CurrentPlayer, _, _, 0), CurrentPlayerMoves),
    length(CurrentPlayerMoves, CurrentPlayerMobility),

    % Evaluate mobility for the opponent
    valid_moves(game_state(_, transition_stage, Board, Opponent, _, _, 0), OpponentMoves),
    length(OpponentMoves, OpponentMobility),

    Value is - OpponentPotentialLines * 5 + CurrentPlayerPotentialLines * 2 + CurrentPlayerMobility - OpponentMobility.

value(game_state(_, first_stage, Board, CurrentPlayer, _, Lines, AllowPressCount), CurrentPlayer, Value) :-
    AllowPressCount > 0,

    % Count lines formed by the current player
    count_lines(Board, CurrentPlayer, CurrentPlayerLines),

    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),

    % Count potential lines for the current player
    % This is a penalty in cases that are to press down because the piece played is considered as an own piece 
    % but actually is to play it on top of opponent's piece so it becomes "pressed" and not considered as potential line for next round
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),

    Value is CurrentPlayerLines * 10 - OpponentPotentialLines * 5 - CurrentPlayerPotentialLines * 2.

value(game_state(_, first_stage, Board, CurrentPlayer, _, Lines, 0), CurrentPlayer, Value) :-
    % Count lines formed by the current player
    count_lines(Board, CurrentPlayer, CurrentPlayerLines),

    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),

    % Count potential lines for the current player
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),

    Value is CurrentPlayerLines * 10 - OpponentPotentialLines * 5 + CurrentPlayerPotentialLines * 2.

value(game_state(_, second_stage, Board, CurrentPlayer, _, Lines, _), CurrentPlayer, Value) :-
    % Count lines formed by the current player
    count_lines(Board, CurrentPlayer, CurrentPlayerLines),
    write('CountLines: '), write(CurrentPlayerLines), nl,

    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),
    write('CountPotentialLines: '), write(OpponentPotentialLines), nl,

    % Count potential lines for the current player
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),
    write('CurrentPlayerPotentialLines: '), write(CurrentPlayerPotentialLines), nl,

    % Evaluate mobility for the current player
    valid_moves(game_state(_, second_stage, Board, CurrentPlayer, _, _, 0), CurrentPlayerMoves),
    length(CurrentPlayerMoves, CurrentPlayerMobility),

    % Evaluate mobility for the opponent
    valid_moves(game_state(_, second_stage, Board, Opponent, _, _, 0), OpponentMoves),
    length(OpponentMoves, OpponentMobility),

    Value is CurrentPlayerLines * 10 - OpponentPotentialLines * 5 + CurrentPlayerPotentialLines * 2 + CurrentPlayerMobility - OpponentMobility.

% count_lines/3 - Counts the number of lines formed by a player
count_lines(Board, Player, Count) :-
    findall(Line, (
        straight_lines(Lines),
        member(Line, Lines),
        all_in_line(Board, Line, Player)
    ), FormedLines),
    length(FormedLines, Count).

% count_potential_lines/3 - Counts the number of potential lines a player can form
count_potential_lines(Board, Player, Count) :-
    findall(Line, (
        straight_lines(Lines),
        member(Line, Lines),
        potential_line(Board, Line, Player)
    ), PotentialLines),
    length(PotentialLines, Count).

% potential_line/3 - Checks if a line is a potential line for a player
potential_line(Board, [Pos1, Pos2, Pos3], Player) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-empty, Board).

potential_line(Board, [Pos1, Pos2, Pos3], Player) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos3-Player, Board),
    memberchk(Pos2-empty, Board).

potential_line(Board, [Pos1, Pos2, Pos3], Player) :-
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-Player, Board),
    memberchk(Pos1-empty, Board).

% read_move/3 - Reads a move from the human player based on the game state
read_move(GameState, Move) :-
    valid_moves(GameState, ValidMoves),
    repeat,
    write('Valid Moves: '), write(ValidMoves), nl,
    write('Enter your move'), nl,
    catch(read(UserInput), _, invalid_move_input),
    skip_line,
    process_move(UserInput, ValidMoves, Move),
    !.

% valid_moves/2 - Returns a list of all possible valid moves
valid_moves(game_state(_, transition_stage, Board, CurrentPlayer, _, _, _), ListOfMoves) :-
    setof(Position, member(Position-CurrentPlayer, Board), ListOfMoves).

valid_moves(game_state(_, first_stage, Board, CurrentPlayer, _, _, AllowRewardMoveCount), ListOfMoves) :-
    AllowRewardMoveCount > 0,
    next_player(CurrentPlayer, Opponent),
    setof(Position, member(Position-Opponent, Board), ListOfMoves).

valid_moves(game_state(_, first_stage, Board, _, _, _, 0), ListOfMoves) :-
    setof(Position, member(Position-empty, Board), ListOfMoves).

valid_moves(game_state(_, second_stage, Board, CurrentPlayer, _, _, AllowRewardMoveCount), ListOfMoves) :-
    AllowRewardMoveCount > 0,
    next_player(CurrentPlayer, Opponent),
    setof(Position, member(Position-Opponent, Board), ListOfMoves).

valid_moves(game_state(_, second_stage, Board, CurrentPlayer, _, _, 0), ListOfMoves) :-
    findall(Move, (
        member(From-CurrentPlayer, Board),  % Find the player's pieces
        adjacent_position(From, To),        % Get adjacent positions
        member(To-empty, Board),            % Ensure the destination is empty
        atom_concat(From, To, Move)         % Create the move string
    ), UnsortedMoves),
    sort(UnsortedMoves, ListOfMoves).

% process_move/3 - Processes user input as a move
process_move(Move, ValidMoves, Move) :-
    atom(Move),
    atom_length(Move, 2),
    valid_position(Move),
    memberchk(Move, ValidMoves),
    !.

process_move(Move, ValidMoves, Move) :-
    atom(Move),
    atom_length(Move, 4),
    sub_atom(Move, 0, 2, _, From),
    sub_atom(Move, 2, 2, 0, To),
    valid_position(From),
    valid_position(To),
    memberchk(Move, ValidMoves),
    !.


process_move(_, _, _) :-
    invalid_move_input.

% invalid_move_input/0 - Handles invalid move input
invalid_move_input :-
    write('Invalid move. Please try again.'), nl, nl,
    fail.

% move/3 - Validates and executes a move for the first stage
move(game_state(PlayerTypes, first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), Move, game_state(PlayerTypes, first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowPressCount)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    check_lines_formed(first_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowPressCount is AllowPressCount + NewLineCount,
    !.

% move/3 - Validates and executes a move for the second stage
move(game_state(PlayerTypes, second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount), Move, game_state(PlayerTypes, second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowRemoveCount)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    NewRedCount = RedCount,
    NewBlackCount = BlackCount,
    check_lines_formed(second_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowRemoveCount is AllowRemoveCount + NewLineCount,
    !.

% handle_press_down_move/1 - Handles whether to perform a press down move or continue the game loop
handle_press_down_move(GameStateAfterMove) :-
    GameStateAfterMove = game_state(PlayerTypes, first_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    AllowPressCount > 0,
    display_game(GameStateAfterMove),
    display_board(GameStateAfterMove),
    write('Moves left to press down: '), write(AllowPressCount), nl,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    press_down(GameStateAfterMove, PlayerType, GameStateAfterPress),
    handle_press_down_move(GameStateAfterPress).

handle_press_down_move(GameStateAfterMove) :-
    GameStateAfterMove = game_state(PlayerTypes, first_stage, Board, CurrentPlayer, Pieces, Lines, 0),
    next_player(CurrentPlayer, NextPlayer),
    NewGameState = game_state(PlayerTypes, first_stage, Board, NextPlayer, Pieces, Lines, 0),
    first_stage_loop(NewGameState).

% press_down/3 - Allows the current player to press down an opponent's piece
press_down(GameState, human, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    repeat,
    write('Valid Moves: '), write(ValidMoves), nl,
    write('You formed a line! Choose an opponent\'s piece to press down'), nl,
    catch(read(PressMove), _, invalid_press_down_input),
    skip_line,
    process_press_down_move(GameState, PressMove, ValidMoves, NewGameState),
    !.

press_down(GameState, computer-Level, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    choose_move(GameState, computer-Level, PressMove),
    process_press_down_move(GameState, PressMove, ValidMoves, NewGameState),
    !.

% process_press_down_move/4 - Processes the press down move based on its validity
process_press_down_move(GameState, PressMove, ValidMoves, NewGameState) :-
    atom(PressMove),
    valid_position(PressMove),
    memberchk(PressMove, ValidMoves),
    GameState = game_state(PlayerTypes, first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    next_player(CurrentPlayer, NextPlayer),
    update_board(Board, PressMove, pressed, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    NewAllowPressCount is AllowPressCount - 1,
    NewGameState = game_state(PlayerTypes, first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], Lines, NewAllowPressCount).

process_press_down_move(_, _, _, _) :-
    invalid_press_down_input.

% invalid_press_down_input/0 - Handles invalid press down input
invalid_press_down_input :-
    write('Invalid press down move. Please try again.'), nl, nl,
    fail.

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
    GameState = game_state(PlayerTypes, Stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    \+ memberchk(_-empty, Board),
    write('Play Stage complete. Transitioning game to Move Stage.'), nl,
    
    % Replace pressed pieces with empty ones using recursion
    remove_all_pressed(Board, BoardWithoutPressed, PressedFound),
    TransitionState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    handle_pressed_pieces(PressedFound, TransitionState, BoardWithoutPressed, NewGameState).

% handle_pressed_pieces/4 - Handles the cases based on whether pressed pieces were found
handle_pressed_pieces(false, game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), BoardWithoutPressed, NewGameState) :-
    GameState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    write('No pressed pieces. Each side will remove one piece.'), nl,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    choose_piece_to_remove(GameState, PlayerType, GameStateAfterRedRemoval),
    GameStateAfterRedRemoval = game_state(PlayerTypes, _, BoardAfterRedRemoval, CurrentPlayer, _, _, _),
    count_pieces(BoardAfterRedRemoval, red, NewRedCount),
    next_player(CurrentPlayer, NextPlayer),
    TempGameState = game_state(PlayerTypes, _, BoardAfterRedRemoval, NextPlayer, _, _, _),
    display_game(TempGameState),
    get_player_type(NextPlayer, PlayerTypes, NextPlayerType),
    choose_piece_to_remove(TempGameState, NextPlayerType, GameStateAfterBlackRemoval),
    GameStateAfterBlackRemoval = game_state(PlayerTypes, _, FinalBoard, _, _, _, _),
    count_pieces(FinalBoard, black, NewBlackCount),
    NewGameState = game_state(PlayerTypes, second_stage, FinalBoard, NextPlayer, [NewRedCount, NewBlackCount], [], 0).

handle_pressed_pieces(true, game_state(PlayerTypes, transition_stage, _, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), BoardWithoutPressed, NewGameState) :-
    write('Removing pressed pieces...'), nl,
    FinalBoard = BoardWithoutPressed,
    count_pieces(BoardWithoutPressed, red, NewRedCount),
    count_pieces(BoardWithoutPressed, black, NewBlackCount),
    next_player(CurrentPlayer, NextPlayer),
    NewGameState = game_state(PlayerTypes, second_stage, FinalBoard, NextPlayer, [NewRedCount, NewBlackCount], [], 0).

% remove_all_pressed/3 - Recursively replaces pressed pieces with empty
remove_all_pressed([], [], false). % Base case: empty board, no pressed pieces found

remove_all_pressed([Position-pressed | Rest], [Position-empty | NewRest], true) :-
    remove_all_pressed(Rest, NewRest, _). % At least one pressed piece was found

remove_all_pressed([Other | Rest], [Other | NewRest], PressedFound) :-
    remove_all_pressed(Rest, NewRest, PressedFound).

% choose_piece_to_remove/3 - Allows a player to choose one piece to remove
choose_piece_to_remove(GameState, human, NewGameState) :-
    valid_moves(GameState, ValidMoves),  % Get the player's own pieces
    GameState = game_state(PlayerTypes, Stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    repeat,
    write('Valid Moves: '), write(ValidMoves), nl,
    write('Choose a piece to remove'), nl,
    catch(read(Position), _, invalid_remove_choice_input),
    skip_line,
    process_remove_choice(GameState, Position, ValidMoves, NewGameState),
    !.

choose_piece_to_remove(GameState, computer-Level, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    choose_move(GameState, computer-Level, Position),
    process_remove_choice(GameState, Position, ValidMoves, NewGameState),
    !.

% process_remove_choice/4 - Processes the remove choice based on its validity
process_remove_choice(GameState, Position, ValidMoves, NewGameState) :-
    atom(Position),
    valid_position(Position),
    memberchk(Position, ValidMoves),
    GameState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    update_board(Board, Position, empty, NewBoard),
    NewGameState = game_state(PlayerTypes, transition_stage, NewBoard, CurrentPlayer, Pieces, Lines, AllowPressCount).

process_remove_choice(_, _, _, _) :-
    invalid_remove_choice_input.

% invalid_remove_choice_input/0 - Handles invalid remove choice input
invalid_remove_choice_input :-
    write('Invalid choice. Please try again.'), nl,
    fail.

% count_pieces/3 - Recursively counts the number of pieces of a given player on the board
count_pieces([], _, 0). % Base case: empty board, count is 0

count_pieces([_-Player | Rest], Player, Count) :-
    count_pieces(Rest, Player, RestCount),
    Count is RestCount + 1.

count_pieces([_ | Rest], Player, Count) :-
    count_pieces(Rest, Player, Count).

% second_stage_loop/1 - Second stage loop of the game
second_stage_loop(GameState) :-
    GameState = game_state(PlayerTypes, second_stage, Board, CurrentPlayer, Pieces, Lines, AllowRemoveCount),
    display_game(GameState),
    display_board(GameState),
    game_over(GameState, Winner),
    !,
    write('GAME OVER, WINNER IS: '), write(Winner), nl.

second_stage_loop(GameState) :-
    GameState = game_state(_, _, _, CurrentPlayer, _, _, _),
    valid_moves(GameState, []),  % No valid moves left
    write('Valid Moves: []'), nl,
    write('YOU HAVE NO VALID MOVES LEFT'), nl,
    next_player(CurrentPlayer, Winner),
    write('GAME OVER, WINNER IS: '), write(Winner), nl.
    
second_stage_loop(GameState) :-
    GameState = game_state(PlayerTypes, second_stage, Board, CurrentPlayer, Pieces, Lines, AllowRemoveCount),
    valid_moves(GameState, ValidMoves),
    ValidMoves \= [],
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    choose_move(GameState, PlayerType, Move),
    move(GameState, Move, GameStateAfterMove),
    handle_remove_move(GameStateAfterMove, GameStateAfterRemove),
    update_lines(GameStateAfterRemove, GameStateAfterLinesUpdate),
    second_stage_loop(GameStateAfterLinesUpdate).

% handle_remove_move/2 - Handles whether to perform a remove move or continue the game loop
handle_remove_move(GameStateAfterMove, GameStateAfterRemove) :-
    GameStateAfterMove = game_state(PlayerTypes, second_stage, Board, CurrentPlayer, Pieces, Lines, AllowRemoveCount),
    AllowRemoveCount > 0,
    display_game(GameStateAfterMove),
    display_board(GameStateAfterMove),
    write('Moves left to remove: '), write(AllowRemoveCount), nl,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    remove(GameStateAfterMove, PlayerType, TempGameStateAfterRemove),
    handle_remove_move(TempGameStateAfterRemove, GameStateAfterRemove).

handle_remove_move(GameStateAfterMove, GameStateAfterRemove) :-
    GameStateAfterMove = game_state(PlayerTypes, second_stage, Board, CurrentPlayer, Pieces, Lines, 0),
    next_player(CurrentPlayer, NextPlayer),
    GameStateAfterRemove = game_state(PlayerTypes, second_stage, Board, NextPlayer, Pieces, Lines, 0).

% remove/3 - Allows the current player to remove an opponent's piece
remove(GameState, human, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    repeat,
    write('Valid Moves: '), write(ValidMoves), nl,
    write('You formed a line! Choose an opponent\'s piece to remove'),
    catch(read(RemoveMove), _, invalid_remove_input),
    skip_line,
    process_remove_move(GameState, RemoveMove, ValidMoves, NewGameState),
    !.

remove(GameState, computer-Level, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    write('Valid Moves: '), write(ValidMoves), nl,
    choose_move(GameState, computer-Level, RemoveMove),
    process_remove_move(GameState, RemoveMove, ValidMoves, NewGameState),
    !.

% process_remove_move/4 - Processes the remove move based on its validity
process_remove_move(GameState, RemoveMove, ValidMoves, NewGameState) :-
    atom(RemoveMove),
    valid_position(RemoveMove),
    memberchk(RemoveMove, ValidMoves),
    GameState = game_state(PlayerTypes, second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount),
    next_player(CurrentPlayer, NextPlayer),
    update_board(Board, RemoveMove, empty, NewBoard),
    decrement_piece_count(NextPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    NewAllowRemoveCount is AllowRemoveCount - 1,
    NewGameState = game_state(PlayerTypes, second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], Lines, NewAllowRemoveCount).

process_remove_move(_, _, _, _) :-
    invalid_remove_input.

% invalid_remove_input/0 - Handles invalid remove input
invalid_remove_input :-
    write('Invalid remove move. Please try again.'), nl,
    fail.

% update_lines/2 - Updates the Lines in the game state based on the current board
update_lines(game_state(PlayerTypes, Stage, Board, CurrentPlayer, Pieces, OldLines, AllowRemoveCount), 
             game_state(PlayerTypes, Stage, Board, CurrentPlayer, Pieces, NewLines, AllowRemoveCount)) :-
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
game_over(game_state(_PlayerTypes, _Stage, _Board, _CurrentPlayer, [RedCount, _BlackCount], _Lines, _AllowRemoveCount), black) :-
    RedCount = 0.
game_over(game_state(_PlayerTypes, _Stage, _Board, _CurrentPlayer, [_RedCount, BlackCount], _Lines, _AllowRemoveCount), red) :-
    BlackCount = 0.