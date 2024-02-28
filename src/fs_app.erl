-module(fs_app).

-behaviour(application).

-export([start/2, stop/1]).

-include_lib("fs/include/const.hrl").

start(_StartType, _StartArgs) ->
    case application:get_env(fs, backwards_compatible) of
        {ok, false} -> {ok, self()};
        {ok, true} -> fs:start_link(?DEFAULT_NAME)
    end.

stop(_State) -> ok.
