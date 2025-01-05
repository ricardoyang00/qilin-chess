:- use_module(library(file_systems)).
:- use_module(library(random)).
:- use_module(library(lists)).
:- use_module(library(system)).

:- consult('menu.pl').
:- consult('board.pl').
:- consult('save_and_load.pl').

% play/0 - Main predicate to start the game and display the menu
play :- 
    repeat,
    display_menu,
    catch(read(UserInput), _, invalid_menu_input),
    skip_line,
    validate_input(UserInput, ValidatedInput),
    handle_option(ValidatedInput),
    !.

% get_player_type/3 - Determines the player type based on the current player
get_player_type(CurrentPlayer, PlayerTypes, PlayerType) :-
    nth1(CurrentPlayerIndex, [red, black], CurrentPlayer),
    nth1(CurrentPlayerIndex, PlayerTypes, PlayerType).

% //////////////////////////// Start Game ////////////////////////////////

% handle_option/2 - Handles the user's menu choice
handle_option(1) :- 
    nl,
    write('Starting Human vs Human game...'), nl,
    start_game(human, human),
    !,
    fail.

handle_option(2) :- 
    nl,
    display_difficulty_selection,
    catch(read(Difficulty), _, invalid_menu_input),
    skip_line,
    validate_input(Difficulty, ValidatedDifficulty),
    handle_difficulty(ValidatedDifficulty),
    !.

handle_option(3) :- 
    nl,
    display_rules,
    write('Press ENTER to get back to the menu...'), nl,
    wait_for_enter,
    !,
    fail.   % Fail to continue the repeat play loop

handle_option(4) :-
    nl,
    load_game(GameState),
    start_game_from_state(GameState),
    !,
    fail.

handle_option(5) :- 
    nl,
    display_commands,
    write('Press ENTER to get back to the menu...'), nl,
    wait_for_enter,
    !,
    fail.

handle_option(0) :-
    nl,
    write('Exiting the game. Goodbye!'), nl,
    logo,
    !.

handle_valid_option(_) :-
    invalid_menu_input.
    
% invalid_menu_input/0 - Handles invalid menu input
invalid_menu_input :-
    write('Invalid input. Please enter a valid option.'), nl,
    fail.

% handle_difficulty/1 - Handles the difficulty selection
handle_difficulty(0) :-
    !,
    play.

handle_difficulty(1) :-
    nl,
    display_color_selection,
    catch(read(Color), _, invalid_menu_input),
    skip_line,
    validate_input(Color, ValidatedColor),
    handle_color(ValidatedColor, 1),
    !.

handle_difficulty(2) :-
    nl,
    display_color_selection,
    catch(read(Color), _, invalid_menu_input),
    skip_line,
    validate_input(Color, ValidatedColor),
    handle_color(ValidatedColor, 2),
    !.

handle_difficulty(_) :-
    write('Returning back to menu...'), nl,
    !,
    fail.
    
% handle_color/2 - Handles the player selection
% back to select difficulty
handle_color(0, _Level) :-
    !,
    handle_option(2).

handle_color(1, Level) :-
    nl,
    write('Starting Human vs Computer game...'), nl,
    start_game(human, computer-Level),
    !,
    fail.

handle_color(2, Level) :-
    nl,
    write('Starting Computer vs Human game...'), nl,
    start_game(computer-Level, human),
    !,
    fail.

handle_color(_, _Level) :-
    write('Returning back to difficulty selection...'), nl,
    !,
    fail.

% wait_for_enter/0 - Waits for the user to press Enter
wait_for_enter :-
    get_char(Char),
    handle_char(Char).

% handle_char/1 - Handles the character input
handle_char('\n') :- !.
handle_char(_) :-
    wait_for_enter.

% start_game/2 - Starts the game with the given player types
start_game(Player1Type, Player2Type) :-
    initial_state([Player1Type, Player2Type], GameState),
    first_stage_loop(GameState).

% initial_state/2 - Sets up the initial game state with the player types (human/computer-level), first stage of the game,
%                   red starts, 18 pieces per player, 0 lines formed and 0 reward move counts
initial_state([Player1Type, Player2Type], game_state(PlayerTypes, Stage, Board, CurrentPlayer, Pieces, Lines, AllowRewardMoveCount)) :-
    PlayerTypes = [Player1Type, Player2Type],
    Stage = first_stage,
    % Initialize the board with empty positions
    Board = [
        a1-empty, d1-empty, g1-empty, 
        b2-empty, d2-empty, f2-empty, 
        c3-empty, d3-empty, e3-empty,
        a4-empty, b4-empty, c4-empty, e4-empty, f4-empty, g4-empty, 
        c5-empty, d5-empty, e5-empty,
        b6-empty, d6-empty, f6-empty, 
        a7-empty, d7-empty, g7-empty
    ],
    CurrentPlayer = red,
    Pieces = [18, 18],
    Lines = [],
    AllowRewardMoveCount = 0.

% /////////////////////////////////////////////////////////////////////
    
% //////////////////////////// First Stage ////////////////////////////

% first_stage_loop/1 - First stage loop of the game
first_stage_loop(GameState) :-
    GameState = game_state(_PlayerTypes, first_stage, _Board, _CurrentPlayer, _Pieces, _Lines, _AllowPressCount),
    display_game(GameState),
    first_stage_over(GameState, Transition),
    !,
    nl,
    write('Press ENTER to proceed to the Move Stage...'), nl,
    wait_for_enter,
    nl,
    write('Entering the second stage (Move Stage) ...'), nl,
    Transition.

first_stage_loop(GameState) :-
    GameState = game_state(PlayerTypes, first_stage, _Board, CurrentPlayer, _Pieces, _Lines, _AllowPressCount),
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    choose_move(GameState, PlayerType, Move),
    move(GameState, Move, GameStateAfterMove),
    handle_press_down_move(GameStateAfterMove).

% /////////////////////////////////////////////////////////////////////

% //////////////////////////// Choose Move ////////////////////////////

% choose_move/3 - Chooses a move based on the player type
choose_move(GameState, human, Move) :-
    read_move(GameState, Move).

choose_move(GameState, computer-Level, Move) :-
    valid_moves(GameState, ValidMoves),
    write('Valid Moves: '), write(ValidMoves), nl, nl,
    choose_move(Level, GameState, ValidMoves, Move).

% choose_move/4 - Chooses a move for the computer based on the difficulty level
choose_move(1, _GameState, ValidMoves, Move) :-
    random_select(Move, ValidMoves, _Rest),
    write('Level 1 AI chooses move: '), write(Move), nl.

choose_move(2, game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowRewardMoveCount), ValidMoves, BestMove) :-
    findall(Value-Move,
        (member(Move, ValidMoves),
         simulate_remove_choice(game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowRewardMoveCount), Move, SimulatedGameState),
         value(SimulatedGameState, CurrentPlayer, Value)),   % Evaluate the state
        MoveValues),

    % Sort the moves by value in ascending order and then reverse to get descending order
    keysort(MoveValues, SortedMoveValues),
    reverse(SortedMoveValues, ReversedMoveValues),

    % Extract the best value
    ReversedMoveValues = [BestValue-_Move|_Rest],

    % Collect all moves with the best value
    findall(Move, member(BestValue-Move, ReversedMoveValues), BestMoves),

    % Randomly select one of the best moves
    random_member(BestMove, BestMoves),

    write('Level 2 AI chooses move: '), write(BestMove), nl.

choose_move(2, GameState, ValidMoves, BestMove) :-
    findall(Value-Move,
        (member(Move, ValidMoves),
         simulate_move(GameState, Move, SimulatedGameState), % Simulate the move
         GameState = game_state(_PlayerTypes, _Stage, _Board, CurrentPlayer, _Pieces, _Lines, _AllowRewardMoveCount),
         value(SimulatedGameState, CurrentPlayer, Value)),   % Evaluate the state
        MoveValues),

    % Sort the moves by value in ascending order and then reverse to get descending order
    keysort(MoveValues, SortedMoveValues),
    reverse(SortedMoveValues, ReversedMoveValues),

    % Extract the best value
    ReversedMoveValues = [BestValue-_Move|_Rest],

    % Collect all moves with the best value
    findall(Move, member(BestValue-Move, ReversedMoveValues), BestMoves),

    % Randomly select one of the best moves
    random_member(BestMove, BestMoves),

    % write('Reversed Value-Move pairs: '), write(ReversedMoveValues), nl, nl,
    write('Best Move(s): '), write(BestMoves), nl, nl,

    write('Level 2 AI chooses move: '), write(BestMove), nl.

% simulate_remove_choice/3 - Simulates the removal of a piece for computer player in transition stage
simulate_remove_choice(GameState, Position, NewGameState) :-
    valid_position(Position),
    GameState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    update_board(Board, Position, empty, NewBoard),
    NewGameState = game_state(PlayerTypes, transition_stage, NewBoard, CurrentPlayer, Pieces, Lines, AllowPressCount).

% simulate_move/3 - Simulation that validates and executes a move for the first stage
simulate_move(game_state(PlayerTypes, first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), Move, game_state(PlayerTypes, first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowPressCount)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    check_lines_formed(true, PlayerType, first_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowPressCount is AllowPressCount + NewLineCount,
    !.

% simulate_move/3 - Simulation that validates and executes a move for the second stage
simulate_move(game_state(PlayerTypes, second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount), Move, game_state(PlayerTypes, second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowRemoveCount)) :-
    update_board(Board, Move, CurrentPlayer, NewBoard),
    NewRedCount = RedCount,
    NewBlackCount = BlackCount,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    check_lines_formed(true, PlayerType, second_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowRemoveCount is AllowRemoveCount + NewLineCount,
    !.

% value/3 - Evaluates the desirability of a game state for the current player
value(game_state(_PlayerTypes, transition_stage, Board, CurrentPlayer, _Pieces, _Lines, _AllowPressCount), CurrentPlayer, Value) :-
    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),

    % Count potential lines for the current player
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),

    % Evaluate mobility for the current player
    valid_moves(game_state(_, transition_stage, Board, CurrentPlayer, _, _, 0), CurrentPlayerMoves),
    length(CurrentPlayerMoves, CurrentPlayerMobility),

    % Evaluate mobility for the opponent
    valid_moves(game_state(_, transition_stage, Board, Opponent, _, _, 0), OpponentMoves),
    length(OpponentMoves, OpponentMobility),

    Value is - OpponentPotentialLines * 5 + CurrentPlayerPotentialLines * 2 + CurrentPlayerMobility - OpponentMobility.

value(game_state(_PlayerTypes, first_stage, Board, CurrentPlayer, _Pieces, _Lines, AllowPressCount), CurrentPlayer, Value) :-
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

value(game_state(_PlayerTypes, first_stage, Board, CurrentPlayer, _Pieces, _Lines, 0), CurrentPlayer, Value) :-
    % Count lines formed by the current player
    count_lines(Board, CurrentPlayer, CurrentPlayerLines),

    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),

    % Count potential lines for the current player
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),

    Value is CurrentPlayerLines * 10 - OpponentPotentialLines * 5 + CurrentPlayerPotentialLines * 2.

value(game_state(_PlayerTypes, second_stage, Board, CurrentPlayer, _Pieces, _Lines, _AllowRemoveCount), CurrentPlayer, Value) :-
    % Count lines formed by the current player
    count_lines(Board, CurrentPlayer, CurrentPlayerLines),

    % Count potential lines for the opponent
    next_player(CurrentPlayer, Opponent),
    count_potential_lines(Board, Opponent, OpponentPotentialLines),

    % Count potential lines for the current player
    count_potential_lines(Board, CurrentPlayer, CurrentPlayerPotentialLines),

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

% read_move/3 - Reads a move from the human player
read_move(GameState, Move) :-
    valid_moves(GameState, ValidMoves),
    write('Valid Moves: '), write(ValidMoves), nl, nl,
    repeat,
    write('Enter your move'), nl,
    catch(read(UserInput), _, invalid_move_input),
    skip_line,
    validate_input(UserInput, ValidatedInput),
    process_move(ValidatedInput, ValidMoves, Move, GameState),
    !.

% valid_moves/2 - Returns a list of all possible valid moves in transition stage
valid_moves(game_state(_PlayerTypes, transition_stage, Board, CurrentPlayer, _Pieces, _Lines, _AllowRewardMoveCount), ListOfMoves) :-
    setof(Position, member(Position-CurrentPlayer, Board), ListOfMoves).

% valid_moves/2 - Returns a list of all possible valid press down moves in first stage
valid_moves(game_state(_PlayerTypes, first_stage, Board, CurrentPlayer, _Pieces, _Lines, AllowRewardMoveCount), ListOfMoves) :-
    AllowRewardMoveCount > 0,
    next_player(CurrentPlayer, Opponent),
    setof(Position, member(Position-Opponent, Board), ListOfMoves).

% valid_moves/2 - Returns a list of all possible valid moves in first stage
valid_moves(game_state(_PlayerTypes, first_stage, Board, _CurrentPlayer, _Pieces, _Lines, 0), ListOfMoves) :-
    setof(Position, member(Position-empty, Board), ListOfMoves).

% valid_moves/2 - Returns a list of all possible valid remove moves in second stage
valid_moves(game_state(_PlayerTypes, second_stage, Board, CurrentPlayer, _Pieces, _Lines, AllowRewardMoveCount), ListOfMoves) :-
    AllowRewardMoveCount > 0,
    next_player(CurrentPlayer, Opponent),
    setof(Position, member(Position-Opponent, Board), ListOfMoves).

% valid_moves/2 - Returns a list of all possible valid moves in second stage
valid_moves(game_state(_PlayerTypes, second_stage, Board, CurrentPlayer, _Pieces, _Lines, 0), ListOfMoves) :-
    findall(Move, (
        member(From-CurrentPlayer, Board),  % Find the player's pieces
        adjacent_position(From, To),        % Get adjacent positions
        member(To-empty, Board),            % Ensure the destination is empty
        atom_concat(From, To, Move)         % Create the move string
    ), UnsortedMoves),
    sort(UnsortedMoves, ListOfMoves).

% process_move/4 - Processes user input as a move, if user inputs forfeit. game ends
process_move(Input, _ValidMoves, _Move, game_state(_PlayerTypes, _Stage, _Board, CurrentPlayer, _Pieces, _Lines, _AllowRewardMoveCount)) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = forfeit,

    next_player(CurrentPlayer, Winner),
    game_over_display(Winner), nl,
    write('Press ENTER to get back to the menu...'), nl,
    wait_for_enter,
    !.

process_move(Input, _ValidMoves, _Move, GameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = save,

    save_game(GameState),
    !.

% process_move/4 - Processes user input as a move of the type a1
process_move(Input, ValidMoves, Move, _GameState) :-
    validate_input(Input, ValidatedInput),
    atom(ValidatedInput),
    atom_length(ValidatedInput, 2),
    valid_position(ValidatedInput),
    memberchk(ValidatedInput, ValidMoves),
    Move = ValidatedInput,
    !.

% process_move/4 - Processes user input as a move of the type a1a4, move from a1 to a4
process_move(Input, ValidMoves, Move, _GameState) :-
    validate_input(Input, ValidatedInput),
    atom(ValidatedInput),
    atom_length(ValidatedInput, 4),
    sub_atom(ValidatedInput, 0, 2, _, From),
    sub_atom(ValidatedInput, 2, 2, 0, To),
    valid_position(From),
    valid_position(To),
    memberchk(ValidatedInput, ValidMoves),
    Move = ValidatedInput,
    !.

process_move(_Input, _ValidMoves, _Move, _GameState) :-
    invalid_move_input.

% invalid_move_input/0 - Handles invalid move input
invalid_move_input :-
    write('Invalid move. Please try again.'), nl, nl,
    fail.

% /////////////////////////////////////////////////////////////////////

% //////////////////////////// General Move Function ////////////////////////////

% move/3 - Validates and executes a move for the first stage
move(game_state(PlayerTypes, first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), Move, game_state(PlayerTypes, first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowPressCount)) :-
    validate_input(Move, ValidatedMove),
    update_board(Board, ValidatedMove, CurrentPlayer, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    check_lines_formed(false, PlayerType, first_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowPressCount is AllowPressCount + NewLineCount,
    !.

% move/3 - Validates and executes a move for the second stage
move(game_state(PlayerTypes, second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount), Move, game_state(PlayerTypes, second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], NewLines, NewAllowRemoveCount)) :-
    validate_input(Move, ValidatedMove),
    update_board(Board, ValidatedMove, CurrentPlayer, NewBoard),
    NewRedCount = RedCount,
    NewBlackCount = BlackCount,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    check_lines_formed(false, PlayerType, second_stage, Move, NewBoard, CurrentPlayer, Lines, UpdatedLines, NewLineCount),
    NewLines = UpdatedLines,
    NewAllowRemoveCount is AllowRemoveCount + NewLineCount,
    !.

% ////////////////////////////////////////////////////////////////////////////////////

% //////////////////////////// First Stage Reward Move ////////////////////////////

% handle_press_down_move/1 - Handles whether to perform a press down move or continue the game loop
handle_press_down_move(GameStateAfterMove) :-
    GameStateAfterMove = game_state(PlayerTypes, first_stage, _Board, CurrentPlayer, _Pieces, _Lines, AllowPressCount),
    AllowPressCount > 0,
    display_game(GameStateAfterMove),
    write('Moves left to press down: '), write(AllowPressCount), nl, nl,
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
    write('Valid Moves: '), write(ValidMoves), nl, nl,
    repeat,
    write('You formed a line! Choose an opponent\'s piece to press down'), nl,
    catch(read(PressMove), _, invalid_press_down_input),
    skip_line,
    process_press_down_move(GameState, PressMove, ValidMoves, NewGameState),
    !.

press_down(GameState, computer-Level, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    choose_move(GameState, computer-Level, PressMove),
    process_press_down_move(GameState, PressMove, ValidMoves, NewGameState),
    nl,
    write('Press ENTER to continue...'), nl,
    wait_for_enter,
    !.

% process_press_down_move/4 - Ends the game if user inputs forfeit.
process_press_down_move(_GameState, Input, _ValidMoves, _NewGameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = forfeit,

    write('Forfeiting is not supported in the current state.'), nl, nl,
    !,
    fail.

process_press_down_move(_GameState, Input, _ValidMoves, _NewGameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = save,

    write('Saving the game is not supported in the current state.'), nl, nl,
    !,
    fail.

% process_press_down_move/4 - Processes the press down move based on its validity
process_press_down_move(GameState, Input, ValidMoves, NewGameState) :-
    validate_input(Input, PressMove),
    valid_position(PressMove),
    memberchk(PressMove, ValidMoves),
    GameState = game_state(PlayerTypes, first_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    next_player(CurrentPlayer, _NextPlayer),
    update_board(Board, PressMove, pressed, NewBoard),
    decrement_piece_count(CurrentPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    NewAllowPressCount is AllowPressCount - 1,
    NewGameState = game_state(PlayerTypes, first_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], Lines, NewAllowPressCount).

process_press_down_move(_GameState, _PressMove, _ValidMoves, _NewGameState) :-
    invalid_press_down_input.

% invalid_press_down_input/0 - Handles invalid press down input
invalid_press_down_input :-
    write('Invalid press down move. Please try again.'), nl, nl,
    fail.

% ////////////////////////////////////////////////////////////////////////////////////

% //////////////////////////// Game State Update and Outputs to the terminal ////////////////////////////

% update_board/4 - Updates the board with the player's move or maintains the same if no update
update_board([], _Position, _NewState, []). % Base case: empty board

% First stage: Matching position, update to the new state
update_board([Position-_State|Rest], Position, NewState, [Position-NewState|NewRest]) :-
    atom_length(Position, 2),
    update_board(Rest, Position, NewState, NewRest).

% First stage: No match, keep the current state and process the rest
update_board([Other|Rest], Position, NewState, [Other|NewRest]) :-
    atom_length(Position, 2),
    update_board(Rest, Position, NewState, NewRest).

% Second stage: Update the board for a move in the format a1a4
update_board(Board, Move, CurrentPlayer, NewBoard) :-
    atom_length(Move, 4),
    sub_atom(Move, 0, 2, _, From),
    sub_atom(Move, 2, 2, 0, To),
    update_board(Board, From, empty, TempBoard),
    update_board(TempBoard, To, CurrentPlayer, NewBoard).

% decrement_piece_count/5 - Decrements the piece count for the current player
decrement_piece_count(red, RedCount, BlackCount, NewRedCount, NewBlackCount) :-
    NewRedCount is RedCount - 1,
    NewBlackCount = BlackCount.

decrement_piece_count(black, RedCount, BlackCount, NewRedCount, NewBlackCount) :-
    NewBlackCount is BlackCount - 1,
    NewRedCount = RedCount.

% check_lines_formed/9 - Finds newly formed lines based on the game stage and updates the Lines list
check_lines_formed(Simulation, PlayerType, first_stage, _Move, Board, Player, ExistingLines, UpdatedLines, NewLineCount) :-
    straight_lines(AllPossibleLines),
    findall(Line, (
        member(Line, AllPossibleLines),     % Select a possible straight line.
        \+ member(Line, ExistingLines),     % Ensure the line is not already in ExistingLines.
        all_in_line(Board, Line, Player)    % Check that all positions in the line belong to the Player.
    ), NewLines),

    print_new_lines(NewLines, PlayerType, Simulation),

    length(NewLines, NewLineCount),         % Count how many new lines were formed
    append(ExistingLines, NewLines, UpdatedLines),
    !.

check_lines_formed(Simulation, PlayerType, second_stage, Move, Board, Player, ExistingLines, UpdatedLines, NewLineCount) :-
    % Extract the destination position from the move string (e.g., a1b4 -> b4)
    sub_atom(Move, 2, _, 0, Destination),

    straight_lines(AllPossibleLines),
    findall(Line, (
        member(Line, AllPossibleLines),     % Select a possible straight line.
        \+ member(Line, ExistingLines),     % Ensure the line is not already in ExistingLines.
        all_in_line(Board, Line, Player),   % Check that all positions in the line belong to the Player.
        member(Destination, Line)                  % Ensure the moved piece forms the line.
    ), NewLines),

    print_new_lines(NewLines, PlayerType, Simulation),

    length(NewLines, NewLineCount),         % Count how many new lines were formed
    append(ExistingLines, NewLines, UpdatedLines),
    !.

% print_new_lines/3 - Handles the printing of new lines if any are formed and handles different outputs based on simulation flag
% it was a simulation move, print nothing
print_new_lines(_NewLines, _PlayerType, true) :- !.

% no new lines formed by human player, print nothing
print_new_lines([], human, _Simulation) :- !.

% new lines formed by human player, print the lines
print_new_lines(NewLines, human, false) :-
    nl,
    write('New line(s) formed: '), write(NewLines), nl.

% no new lines were formed by AI, show press enter to continue
print_new_lines([], computer-_Level, false) :-
    nl,
    write('Press ENTER to continue...'), nl,
    wait_for_enter.

% new lines were formed by AI, print the lines and show press enter to continue
print_new_lines(NewLines, computer-_Level, false) :-
    nl,
    write('New line(s) formed: '), write(NewLines), nl,
    nl,
    write('Press ENTER to continue...'), nl,
    wait_for_enter.

% all_in_line/3 - Checks if all positions in a line are occupied by the same player
all_in_line(Board, [Pos1, Pos2, Pos3], Player) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-Player, Board),
    !.

% next_player/2 - Switches to the next player
next_player(red, black).
next_player(black, red).

% ////////////////////////////////////////////////////////////////////////////////////

% //////////////////////////// First Stage Over -> Transition Stage ////////////////////////////

% first_stage_over/2 - Checks if the stage 1 is over and handles the board
first_stage_over(GameState, second_stage_loop(NewGameState)) :-
    GameState = game_state(PlayerTypes, _Stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    \+ memberchk(_-empty, Board),
    write('Play Stage complete. Checking for pressed pieces...'), nl,
    
    % Replace pressed pieces with empty ones using recursion
    remove_all_pressed(Board, BoardWithoutPressed, PressedFound),
    TransitionState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    handle_pressed_pieces(PressedFound, TransitionState, BoardWithoutPressed, NewGameState).

% handle_pressed_pieces/4 - Handles the cases when no pressed pieces are found, each player removes a piece of their own
handle_pressed_pieces(false, game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount), _BoardWithoutPressed, NewGameState) :-
    GameState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowPressCount),
    write('No pressed pieces. Each side will remove one piece.'), nl, nl,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    choose_piece_to_remove(GameState, PlayerType, GameStateAfterRedRemoval),
    GameStateAfterRedRemoval = game_state(PlayerTypes, transition_stage, BoardAfterRedRemoval, CurrentPlayer, _, _, _),
    count_pieces(BoardAfterRedRemoval, red, NewRedCount),
    next_player(CurrentPlayer, NextPlayer),
    TempGameState = game_state(PlayerTypes, transition_stage, BoardAfterRedRemoval, NextPlayer, _, _, _),
    display_game(TempGameState),
    get_player_type(NextPlayer, PlayerTypes, NextPlayerType),
    choose_piece_to_remove(TempGameState, NextPlayerType, GameStateAfterBlackRemoval),
    GameStateAfterBlackRemoval = game_state(PlayerTypes, _, FinalBoard, _, _, _, _),
    count_pieces(FinalBoard, black, NewBlackCount),
    NewGameState = game_state(PlayerTypes, second_stage, FinalBoard, NextPlayer, [NewRedCount, NewBlackCount], [], 0).

% handle_pressed_pieces/4 - Handles the cases where pressed pieces are found, remove the pressed pieces from the board
handle_pressed_pieces(true, game_state(PlayerTypes, transition_stage, _, CurrentPlayer, [_RedCount, _BlackCount], _Lines, _AllowPressCount), BoardWithoutPressed, NewGameState) :-
    write('Removing pressed pieces...'), nl,
    FinalBoard = BoardWithoutPressed,
    count_pieces(BoardWithoutPressed, red, NewRedCount),
    count_pieces(BoardWithoutPressed, black, NewBlackCount),
    next_player(CurrentPlayer, NextPlayer), % Second stage black starts
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
    write('Valid Moves: '), write(ValidMoves), nl, nl,
    repeat,
    write('Choose a piece to remove'), nl,
    catch(read(Position), _, invalid_remove_choice_input),
    skip_line,
    process_remove_choice(GameState, Position, ValidMoves, NewGameState),
    !.

choose_piece_to_remove(GameState, computer-Level, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    choose_move(GameState, computer-Level, Position),
    process_remove_choice(GameState, Position, ValidMoves, NewGameState),
    nl,
    write('Press ENTER to continue...'), nl,
    wait_for_enter,
    !.

% process_remove_choice/4 - Processes the remove choice based on its validity
process_remove_choice(_GameState, Input, _ValidMoves, _NewGameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = forfeit,

    write('Forfeiting is not supported in the transition state.'), nl, nl,
    !,
    fail.

process_remove_choice(_GameState, Input, _ValidMoves, _NewGameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = save,

    write('Saving the game is not supported in the transition state.'), nl, nl,
    !,
    fail.

process_remove_choice(GameState, Input, ValidMoves, NewGameState) :-
    validate_input(Input, Position),
    valid_position(Position),
    memberchk(Position, ValidMoves),
    GameState = game_state(PlayerTypes, transition_stage, Board, CurrentPlayer, Pieces, Lines, AllowPressCount),
    update_board(Board, Position, empty, NewBoard),
    NewGameState = game_state(PlayerTypes, transition_stage, NewBoard, CurrentPlayer, Pieces, Lines, AllowPressCount).

process_remove_choice(_GameState, _Position, _ValidMoves, _NewGameState) :-
    invalid_remove_choice_input.

% invalid_remove_choice_input/0 - Handles invalid remove choice input
invalid_remove_choice_input :-
    write('Invalid choice. Please try again.'), nl, nl,
    fail.

% count_pieces/3 - Recursively counts the number of pieces of a given player on the board
count_pieces([], _Player, 0). % Base case: empty board, count is 0

count_pieces([_Position-Player | Rest], Player, Count) :-
    count_pieces(Rest, Player, RestCount),
    Count is RestCount + 1.

count_pieces([_ | Rest], Player, Count) :-
    count_pieces(Rest, Player, Count).

% ////////////////////////////////////////////////////////////////////////////////////

% //////////////////////////// Second Stage ////////////////////////////

% second_stage_loop/1 - Second stage loop of the game
second_stage_loop(GameState) :-
    GameState = game_state(_PlayerTypes, second_stage, _Board, _CurrentPlayer, _Pieces, _Lines, _AllowRemoveCount),
    display_game(GameState),
    game_over(GameState, Winner),
    !,
    game_over_display(Winner), nl,
    write('Press ENTER to get back to the menu...'), nl,
    wait_for_enter,
    !.

% second_stage_loop/1 - If current player has no moves left, game over
second_stage_loop(GameState) :-
    GameState = game_state(_PlayerTypes, _Stage, _Board, CurrentPlayer, _Pieces, _Lines, _AllowRemoveCount),
    valid_moves(GameState, []),  % No valid moves left
    write('Valid Moves: []'), nl, nl,
    write('YOU HAVE NO VALID MOVES LEFT'), nl, nl,
    write('Press ENTER to continue...'), nl,
    wait_for_enter,
    !,
    next_player(CurrentPlayer, Winner),
    game_over_display(Winner), nl,
    write('Press ENTER to get back to the menu...'), nl,
    wait_for_enter,
    !.
    
second_stage_loop(GameState) :-
    GameState = game_state(PlayerTypes, second_stage, _Board, CurrentPlayer, _Pieces, _Lines, _AllowRemoveCount),
    valid_moves(GameState, ValidMoves),
    length(ValidMoves, ValidMovesLength),
    ValidMovesLength > 0,
    get_player_type(CurrentPlayer, PlayerTypes, PlayerType),
    choose_move(GameState, PlayerType, Move),
    move(GameState, Move, GameStateAfterMove),
    handle_remove_move(GameStateAfterMove, GameStateAfterRemove),
    update_lines(GameStateAfterRemove, GameStateAfterLinesUpdate),
    second_stage_loop(GameStateAfterLinesUpdate).

% ////////////////////////////////////////////////////////////////////////////////////

% //////////////////////////// Second Stage Reward Move ////////////////////////////

% handle_remove_move/2 - Handles whether to perform a remove move or continue the game loop
handle_remove_move(GameStateAfterMove, GameStateAfterRemove) :-
    GameStateAfterMove = game_state(PlayerTypes, second_stage, _Board, CurrentPlayer, _Pieces, _Lines, AllowRemoveCount),
    AllowRemoveCount > 0,
    display_game(GameStateAfterMove),
    write('Moves left to remove: '), write(AllowRemoveCount), nl, nl,
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
    write('Valid Moves: '), write(ValidMoves), nl, nl,
    repeat,
    write('You formed a line! Choose an opponent\'s piece to remove'), nl,
    catch(read(RemoveMove), _, invalid_remove_input),
    skip_line,
    process_remove_move(GameState, RemoveMove, ValidMoves, NewGameState),
    !.

remove(GameState, computer-Level, NewGameState) :-
    valid_moves(GameState, ValidMoves),
    choose_move(GameState, computer-Level, RemoveMove),
    process_remove_move(GameState, RemoveMove, ValidMoves, NewGameState),
    nl,
    write('Press ENTER to continue...'), nl,
    wait_for_enter,
    !.

% process_remove_move/4 - Processes the remove move based on its validity
process_remove_move(_GameState, Input, _ValidMoves, _NewGameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = forfeit,
    
    write('Forfeiting is not supported in the current state.'), nl, nl,
    !,
    fail.

process_remove_move(_GameState, Input, _ValidMoves, _NewGameState) :-
    validate_input(Input, ValidatedInput),
    ValidatedInput = save,

    write('Saving the game is not supported in the current state.'), nl, nl,
    !,
    fail.

process_remove_move(GameState, Input, ValidMoves, NewGameState) :-
    validate_input(Input, RemoveMove),
    valid_position(RemoveMove),
    memberchk(RemoveMove, ValidMoves),
    GameState = game_state(PlayerTypes, second_stage, Board, CurrentPlayer, [RedCount, BlackCount], Lines, AllowRemoveCount),
    next_player(CurrentPlayer, NextPlayer),
    update_board(Board, RemoveMove, empty, NewBoard),
    decrement_piece_count(NextPlayer, RedCount, BlackCount, NewRedCount, NewBlackCount),
    NewAllowRemoveCount is AllowRemoveCount - 1,
    NewGameState = game_state(PlayerTypes, second_stage, NewBoard, CurrentPlayer, [NewRedCount, NewBlackCount], Lines, NewAllowRemoveCount).

process_remove_move(_GameState, _RemoveMove, _ValidMoves, _NewGameState) :-
    invalid_remove_input.

% invalid_remove_input/0 - Handles invalid remove input
invalid_remove_input :-
    write('Invalid remove move. Please try again.'), nl, nl,
    fail.

% update_lines/2 - Updates the Lines in the game state based on the current board
update_lines(game_state(PlayerTypes, Stage, Board, CurrentPlayer, Pieces, _OldLines, AllowRemoveCount), 
             game_state(PlayerTypes, Stage, Board, CurrentPlayer, Pieces, NewLines, AllowRemoveCount)) :-
    straight_lines(StraightLines),
    findall(Line, (member(Line, StraightLines), all_same_player(Board, Line)), NewLines).

% all_same_player/2 - Verifies that all positions in a line are occupied by the same player
all_same_player(Board, [Pos1, Pos2, Pos3]) :-
    memberchk(Pos1-Player, Board),
    memberchk(Pos2-Player, Board),
    memberchk(Pos3-Player, Board),
    \+ memberchk(Pos1-empty, Board),
    \+ memberchk(Pos2-empty, Board),
    \+ memberchk(Pos3-empty, Board).

% ////////////////////////////////////////////////////////////////////////////////////

% //////////////////////////// Game Over ////////////////////////////

% game_over/2 - Checks if the game is over and identifies the winner
game_over(game_state(_PlayerTypes, _Stage, _Board, _CurrentPlayer, [RedCount, _BlackCount], _Lines, _AllowRemoveCount), black) :-
    RedCount = 0.
game_over(game_state(_PlayerTypes, _Stage, _Board, _CurrentPlayer, [_RedCount, BlackCount], _Lines, _AllowRemoveCount), red) :-
    BlackCount = 0.

% ////////////////////////////////////////////////////////////////////////////////////