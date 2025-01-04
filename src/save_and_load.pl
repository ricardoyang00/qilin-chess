% save_game/1 - Saves the current game state to a file
save_game(GameState) :-
    % Get the current working directory
    current_directory(CurrentDir),
    write('Current working directory: '), write(CurrentDir), nl,

    % Prompt the user for the filename
    repeat,
    write('Enter the filename to save the game'), nl,
    catch(read(Filename), _, handle_save_file_error),

    % Attempt to open the file
    catch(open(Filename, write, Stream), _, handle_open_file_error),

    write(Stream, GameState),
    write(Stream, '.'),
    close(Stream),
    write('Game saved successfully to: '), write(Filename), nl.

% load_game/1 - Loads the game state from a file
load_game(GameState) :-
    % Get the current working directory
    current_directory(CurrentDir),
    write('Current working directory: '), write(CurrentDir), nl,
    
    % Prompt the user for the filename
    repeat,
    write('Enter the filename to load the game'), nl,
    catch(read(Filename), _, handle_load_file_error),
    
    % Check if the file exists
    file_exists_check(Filename),

    % Attempt to open the file
    catch(open(Filename, read, Stream), _, handle_open_file_error),
    
    % If the file opens successfully, read the game state
    read(Stream, GameState),
    close(Stream),
    write('Game loaded successfully from: '), write(Filename), nl.

% file_exists_check/1 - Checks if the file exists
file_exists_check(Filename) :-
    file_exists(Filename),
    !.

file_exists_check(_) :-
    handle_load_file_error,
    !.

% handle_save_file_error/0 - Handles save file related errors
handle_save_file_error :-
    write('Ensure that the filename does not contain any extension or symbol and it\'s lower case.'), nl, nl,
    fail.

% handle_load_file_error/0 - Handles load file related errors
handle_load_file_error :-
    write('File does not exist. Please try again.'), nl, nl,
    fail.

% handle_open_file_error/0 - Handles open file related errors
handle_open_file_error :- 
    write('Something went wrong when trying to open file, please ensure that the filename is all lowercase.'), nl, nl,
    fail.

% start_game_from_state/1 - Starts the game from the loaded state
start_game_from_state(GameState) :-
    GameState = game_state(_PlayerTypes, Stage, _Board, _CurrentPlayer, _Pieces, _Lines, _AllowRewardMoveCount),
    start_game_from_stage(Stage, GameState).

% start_game_from_stage/2 - Helper predicate to start the game based on the stage
start_game_from_stage(first_stage, GameState) :-
    first_stage_loop(GameState).
start_game_from_stage(second_stage, GameState) :-
    second_stage_loop(GameState).