% ==============================================================================
% CASPER version v1.1.0
% Author: Yvon K. Awuklu
% Description: Auxiliary predicates encoding
% ==============================================================================

#include "python.lp".

#include "../encoding/temporal_predicate.lp".

#const start = -1.
#const end = -1.

window_override :- start >= 0, end >= 0, start < end.

% window
w_start(S) :- window_override; S = start.
w_end(E) :- window_override; E = end + @get_shift(unit).

w_start(T) :- not window_override; T = #min{ Tx : obs(_, _, _, Tx) }; T >= 0.
w_end(T + @get_shift(unit)) :- not window_override; T = #max{ Tx : obs(_, _, _, Tx) }.

window(S, E) :- w_start(S); w_end(E).

highest_terminates(L) :- L = #min{ Lx : terminates(N, P, E, _, Lx) }.
if_highest_exists(L) :- not terminates(N, P, E, _, _) : exists(N, P, E, _, _); L = #min{ Lx : exists(N, P, _, _, Lx); Ly : exists_pers(N, P, _, _, Ly) }.
highest_exists_per_event(N, P, E, L) :- exists(N, P, E, _, _); L = #min{ Lx : exists(N, P, E, _, Lx); Ly : exists_pers(N, P, E, _, Ly) }.

% default termination condition
terminates(P, T, L) :- obs(death, P, T); L = #min{ Lx : highest_terminates(Lx); Ly: if_highest_exists(Ly) }.  % patient death
terminates(P, T, L) :- not window_override; exists_pers(N, P, _, _, _); not obs(death, P, _); T = @ongoing_time(unit); L = #min{ Lx : highest_terminates(Lx); Ly: if_highest_exists(Ly) }. % ongoing event
terminates(P, T, L) :- window_override; exists_pers(N, P, _, _, _); not obs(death, P, _); T = end + @get_shift(unit); L = #min{ Lx : highest_terminates(Lx); Ly: if_highest_exists(Ly) }. % ongoing event with window override

% valid time
valid_time(T) :- exists(_, _, _, T, _).
valid_time(T) :- exists_pers(_, _, _, T, _).
valid_time(T) :- terminates(_, _, _, T, _).
valid_time(T) :- terminates(_, T, _).

% valid level
valid_level(N, P, E, L) :- exists(N, P, E, _, L).
valid_level(N, P, E, L) :- exists_pers(N, P, E, _, L).
valid_level(N, P, E, L) :- terminates(N, P, E, _, L).
valid_level(L) :- terminates(_, _, L).

% meta-event definition
event(@get_id(N, P, T1, T2), N, P, (T1, T2), L) :- m_event(N, P, (T1, T2), L).
event(@get_id(N, P, E, T1, T2), N, P, E, (T1, T2), L) :- m_event(N, P, E, (T1, T2), L).

% event interval
e_interval(T1, T2) :- event(_, _, _, _, (T1, T2), _).
e_interval(T1, T2) :- event(_, _, _, (T1, T2), _).
