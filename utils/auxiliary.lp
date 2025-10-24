% ==============================================================================
% CASPER version v1.0.0
% Author: Yvon K. Awuklu
% Description: Auxiliary predicates encoding
% ==============================================================================

#include "python.lp".

#include "../encoding/temporal_predicate.lp".

% window
w_start(T) :- T = #min{ Tx : obs(_, _, _, Tx) }; T >= 0.
w_end(T + @get_shift(unit)) :- T = #max{ Tx : obs(_, _, _, Tx) }.

window(S, E) :- w_start(S); w_end(E).

highest_terminates(L) :- L = #min{ Lx : terminates(N, P, E, _, Lx) }.
if_highest_exists(L) :- not terminates(N, P, E, _, _) : exists(N, P, E, _, _); L = #min{ Lx : exists(N, P, _, _, Lx); Ly : exists_pers(N, P, _, _, Ly) }.
highest_exists(N, L) :- exists(N, P, _, _, _); L = #min{ Lx : exists(N, P, _, _, Lx); Ly : exists_pers(N, P, _, _, Ly) }.
lowest_exists(N, L) :- not exists_level_count(N, 1); exists(N, P, _, _, _); L = #max{ Lx : exists(N, P, _, _, Lx); Ly : exists_pers(N, P, _, _, Ly) }.

exists_level_count(N, C) :- exists(N, _, _, _, _); C = #count{ P, L : exists(N, P, _, _, L) }.
terminates_level_count(N, C) :- terminates(N, _, _, _, _); C = #count{ P, L : terminates(N, P, _, _, L) }.

% default termination condition
terminates(P, T, L) :- obs(death, P, T); L = #min{ Lx : highest_terminates(Lx); Ly: if_highest_exists(Ly) }.  % patient death
terminates(P, T, L) :- exists(N, P, _, _, _); not obs(death, P, _); T = @ongoing_time(unit); L = #min{ Lx : highest_terminates(Lx); Ly: if_highest_exists(Ly) }. % ongoing event

% valid time
valid_time(T) :- exists(_, _, _, T, _).
valid_time(T) :- exists_pers(_, _, _, T, _).
valid_time(T) :- terminates(_, _, _, T, _).
valid_time(T) :- terminates(_, T, _).

% meta-event definition
event(@get_id(N, P, T1, T2), N, P, (T1, T2), L) :- m_event(N, P, (T1, T2), L).
event(@get_id(N, P, E, T1, T2), N, P, E, (T1, T2), L) :- m_event(N, P, E, (T1, T2), L).

% event interval
e_interval(T1, T2) :- event(_, _, _, _, (T1, T2), _).
e_interval(T1, T2) :- event(_, _, _, (T1, T2), _).