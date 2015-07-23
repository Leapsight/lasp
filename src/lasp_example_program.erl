%% -------------------------------------------------------------------
%%
%% Copyright (c) 2014 SyncFree Consortium.  All Rights Reserved.
%%
%% This file is provided to you under the Apache License,
%% Version 2.0 (the "License"); you may not use this file
%% except in compliance with the License.  You may obtain
%% a copy of the License at
%%
%%   http://www.apache.org/licenses/LICENSE-2.0
%%
%% Unless required by applicable law or agreed to in writing,
%% software distributed under the License is distributed on an
%% "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY
%% KIND, either express or implied.  See the License for the
%% specific language governing permissions and limitations
%% under the License.
%%
%% -------------------------------------------------------------------

-module(lasp_example_program).
-author("Christopher Meiklejohn <cmeiklejohn@basho.com>").

-behavior(lasp_program).

-export([init/1,
         process/5,
         execute/2,
         value/1,
         type/0]).

-record(state, {id}).

-define(CORE, lasp_core).
-define(TYPE, lasp_orset_gbtree).

%% @doc Initialize an or-set as an accumulator.
init(Store) ->
    {ok, Id} = ?CORE:declare(?TYPE, Store),
    {ok, #state{id=Id}}.

%% @doc Notification from the system of an event.
process(Object, _Reason, Actor, #state{id=Id}=State, Store) ->
    {ok, _} = ?CORE:update(Id, {add, Object}, Actor, Store),
    {ok, State}.

%% @doc Return the result.
execute(#state{id=Id}, Store) ->
    lager:info("Execute called."),
    {ok, {_, _, _, Value}} = ?CORE:read(Id, undefined, Store),
    lager:info("Execute finished."),
    {value, Value}.

%% @doc Pass the value through directly.
value(X) ->
    X.

%% @doc Return type information about what type of CRDT this program
%%      returns.
type() ->
    ?TYPE.
