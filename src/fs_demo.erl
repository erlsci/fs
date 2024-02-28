-module(fs_demo).

-include_lib("fs/include/const.hrl").

-export([start_looper/0,
         start_looper/1]).

% sample subscriber

start_looper() -> start_looper(?DEFAULT_NAME).

start_looper(Name) ->
    spawn(fun () ->
                  fs:subscribe(Name),
                  loop()
          end).

loop() ->
    receive
        {_Pid, {fs, file_event}, {Path, Flags}} ->
            error_logger:info_msg("file_event: ~p ~p",
                                  [Path, Flags]);
        _ -> ignore
    end,
    loop().
