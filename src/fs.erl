-module(fs).

-include_lib("kernel/include/file.hrl").
-include_lib("fs/include/const.hrl").

-export([start_link/1, start_link/2,
         subscribe/0, subscribe/1, subscribe/2,
         known_events/0, known_events/1,
         find_executable/2,
         path/0, path/1]).

% sample subscriber

start_link(Name) -> start_link(Name, path()).

start_link(Name, Path) ->
    SupName = name(Name, "sup"),
    FileHandler = name(Name, "file"),
    fs_sup:start_link(SupName, Name, FileHandler, Path).

subscribe() -> subscribe(?DEFAULT_NAME).

subscribe(Name) -> subscribe(Name, self()).

subscribe(Name, Pid) ->
    gen_event:add_sup_handler(Name,
                              {fs_event_bridge, Pid},
                              [Pid]).

path() ->
    path(application:get_env(fs, path)).

path(Path) ->
    case Path of
        undefined -> filename:absname("");
        {ok, P} -> filename:absname(P);
        P -> filename:absname(P)
    end.

known_events() -> known_events(?DEFAULT_NAME).

known_events(Name) ->
    gen_server:call(name(Name, "file"), known_events).

find_executable(Cmd, DepsPath) ->
    Executable = 
        case priv_file(Cmd) of
            false -> mad_file(DepsPath);
            Priv -> Priv
        end,
    case filename:pathtype(Executable) of
        relative ->
            filename:join(path(), Executable);
        _PathType ->
            Executable
    end.

mad_file(DepsPath) ->
    case filelib:is_regular(DepsPath) of
        true -> DepsPath;
        false ->
            case load_file(DepsPath) of
                {error, _} ->
                    %% This path has been already checked in find_executable/2
                    false;
                {ok, ETSFile} ->
                    filelib:ensure_dir(DepsPath),
                    file:write_file(DepsPath, ETSFile),
                    file:write_file_info(DepsPath,
                                         #file_info{mode = 8#00555})
            end
    end.

priv_file(Cmd) ->
    case code:priv_dir(fs) of
        Priv when is_list(Priv) ->
            Path = filename:join(Priv, Cmd),
            case filelib:is_regular(Path) of
                true -> Path;
                false -> false
            end;
        _ -> false
    end.

name(Name, Prefix) ->
    NameList = erlang:atom_to_list(Name),
    list_to_atom(NameList ++ Prefix).

ets_created() ->
    case ets:info(filesystem) of
        undefined ->
            ets:new(filesystem,
                    [set, named_table, {keypos, 1}, public]);
        _ -> skip
    end.

load_file(Name) ->
    ets_created(),
    case ets:lookup(filesystem, Name) of
        [{Name, Bin}] -> {ok, Bin};
        _ -> {error, etsfs}
    end.
