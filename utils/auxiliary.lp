#program base.

% ==============================================================================
% CASPER version v1.0.0
% Author: Yvon K. Awuklu
% Description: Auxiliary predicates encoding
% ==============================================================================

#include "python.lp".
#include "../encoding/temporal_predicate.lp".

#const win := 604800. % 7-day default temporal window (equivalent optimization: shared constant)

% meta-event definition
event(@get_id(N, P, T1, T2), N, P, (T1, T2), L) :- m_event(N, P, (T1, T2), L).
event(@get_id(N, P, E, T1, T2), N, P, E, (T1, T2), L) :- m_event(N, P, E, (T1, T2), L).

% Period helper shared across expansion rules
period_template(N, E, D) :- pt_window(N, E, D).

% event interval cache
e_interval(T1, T2) :- event(_, _, _, _, (T1, T2), _).
e_interval(T1, T2) :- event(_, _, _, (T1, T2), _).

#program step(t).
#external use_temporal_index(t).

% Anchor for the current step (equivalent optimization: avoid recomputing arithmetic)
anchor_time(t, Anchor) :- use_temporal_index(t), step_time(t, Anchor).

% Active observation helpers shared across modules
active_exists(N, P, E, T, L) :- use_temporal_index(t), exists(N, P, E, T, L), time_scope(t, T).
active_exists_pers(N, P, E, T, L) :- use_temporal_index(t), exists_pers(N, P, E, T, L), time_scope(t, T).
active_terminates(N, P, E, T, L) :- use_temporal_index(t), terminates(N, P, E, T, L), time_domain(T).
active_terminates(P, T, L) :- use_temporal_index(t), terminates(P, T, L), time_domain(T).

window_start_raw(t, Anchor - win) :- anchor_time(t, Anchor), Anchor >= win.
window_start_raw(t, 0) :- anchor_time(t, Anchor), Anchor < win.

step_window(t, Start, End) :-
    use_temporal_index(t),
    window_start_raw(t, Start),
    anchor_time(t, Anchor),
    End = Anchor + @get_shift(unit),
    Start <= End.

window(Start, End) :- step_window(t, Start, End).

% Time and entity domains scoped to the active window (equivalent optimization: guard joins)
base_time(T) :- obs(_, _, _, T).
base_time(T) :- terminates(_, _, _, T, _).
base_time(T) :- terminates(_, T, _).

patient(P) :- use_temporal_index(t), obs(_, P, _, _).
entity(E) :- use_temporal_index(t), obs(_, _, E, _).

time_scope(t, T) :-
    use_temporal_index(t),
    base_time(T),
    step_window(t, Start, End),
    Start <= T,
    T <= End.

time_domain(T) :- time_scope(t, T).

valid_time(T) :- base_time(T).

% Highest/lowest helpers restricted to scoped events (equivalent optimization: avoid global aggregates)
highest_terminates(L) :- L = #min{ Lx : active_terminates(N, P, E, _, Lx) }.
if_highest_exists(L) :-
    use_temporal_index(t),
    not terminates(N, P, E, _, _) : exists(N, P, E, _, _),
    L = #min{ Lx : exists(N, P, _, _, Lx); Ly : exists_pers(N, P, _, _, Ly) }.

highest_exists(N, L) :-
    use_temporal_index(t),
    active_exists(N, P, _, _, _),
    L = #min{ Lx : active_exists(N, P, _, _, Lx); Ly : active_exists_pers(N, P, _, _, Ly) }.

lowest_exists(N, L) :-
    use_temporal_index(t),
    not exists_level_count(N, 1),
    active_exists(N, P, _, _, _),
    L = #max{ Lx : active_exists(N, P, _, _, Lx); Ly : active_exists_pers(N, P, _, _, Ly) }.

exists_level_count(N, C) :-
    use_temporal_index(t),
    active_exists(N, _, _, _, _),
    C = #count{ P, L : active_exists(N, P, _, _, L) }.

terminates_level_count(N, C) :-
    use_temporal_index(t),
    active_terminates(N, _, _, _, _),
    C = #count{ P, L : active_terminates(N, P, _, _, L) }.

no_need_more_expansion(N) :- exists_level_count(N, C), C <= 2.

% default termination condition (equivalent optimization: scoped on patient domain)
terminates(P, T, L) :-
    use_temporal_index(t),
    obs(death, P, T),
    L = #min{ Lx : highest_terminates(Lx); Ly : if_highest_exists(Ly) }.

terminates(P, T, L) :-
    use_temporal_index(t),
    exists(N, P, _, _, _),
    not obs(death, P, _),
    anchor_time(t, Anchor),
    T = Anchor + @get_shift(unit),
    L = #min{ Lx : highest_terminates(Lx); Ly : if_highest_exists(Ly) }.

% helper predicates (equivalent optimization: bounded by current window)
start(N, P, T, L) :-
    use_temporal_index(t),
    event(_, N, P, _, (T, _), L),
    step_window(t, S, _),
    S <= T,
    not event(_, N, P, _, (Tx, _), _) : base_time(Tx), S <= Tx, Tx < T.

end(N, P, T, L) :-
    use_temporal_index(t),
    event(_, N, P, _, (_, T), L),
    step_window(t, _, E),
    T <= E,
    not event(_, N, P, _, (_, Tx), _) : base_time(Tx), T < Tx, Tx <= E.

persist_end(P, T) :-
    use_temporal_index(t),
    terminates(P, T, _).
