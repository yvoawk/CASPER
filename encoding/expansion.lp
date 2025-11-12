% ==============================================================================
% CASPER version v1.0.1
% Author: Yvon K. Awuklu
% Description: Expansion technique for clinical event detection encoding
% See Theorem 1 in the paper for details
% ==============================================================================

#program step(t).
#external use_expansion(t).

% Resolve effective expansion periods
period(N, E, D) :- use_expansion(t); pt_window(N, E, D).

%*
period(E, D) :-
    use_expansion(t),
    not pt_window(_, E, _),
    default_period(E, D),
    exists(_, _, E, _, _).
period(E, D) :-
    use_expansion(t),
    not pt_window(_, E, _),
    default_period(E, D),
    terminates(_, _, E, _, _).
*%

% Determine termination candidate (equivalent optimization: bounded temporal join)
pre_end_obs(N, P, E, (T, Tnext), L) :-
    use_expansion(t);
    active_exists(N, P, E, T, _);
    active_terminates(N, P, _, Tnext, L);
    period(N, E, D);
    Tnext <= T + D;
    Tnext > T;
    not active_exists(N, P, _, Tx, _) : time_domain(Tx), T < Tx, Tx <= Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :-
    use_expansion(t);
    active_exists(N, P, E, T, _);
    active_terminates(P, Tnext, L);
    period(N, E, D);
    Tnext <= T + D + @get_shift(unit);
    Tnext > T;
    not active_exists(N, P, _, Tx, _) : time_domain(Tx), T < Tx, Tx <= Tnext.

%*
pre_end_obs(N, P, E, (T, Tnext), L) :-
    use_expansion(t),
    active_exists(N, P, E, T, _),
    active_terminates(N, P, _, Tnext, L),
    period(E, D),
    Tnext <= T + D,
    Tnext > T,
    not active_exists(N, P, _, Tx, _) : time_domain(Tx), T < Tx, Tx <= Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :-
    use_expansion(t),
    active_exists(N, P, E, T, _),
    active_terminates(P, Tnext, L),
    period(E, D),
    Tnext <= T + D + @get_shift(unit),
    Tnext > T,
    not active_exists(N, P, _, Tx, _) : time_domain(Tx), T < Tx, Tx <= Tnext.
*%

end_obs(N, P, E, (T, Tnext), L) :-
    use_expansion(t);
    pre_end_obs(N, P, E, (T, Tnext), L);
    not end_covered(N, P, E, (T, Tnext), L).

end_covered(N, P, E, (T1, T2), L) :-
    use_expansion(t);
    pre_end_obs(N, P, E, (T1, T2), L);
    pre_end_obs(N, P, E, (T1_, T2_), Lx);
    T2_ <= T2;
    T1_ >= T1;
    T2_ - T1_ < T2 - T1;
    Lx <= L.

pre_covered(N, P, E, (T1, T2), L) :-
    use_expansion(t);
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, E, (T1_, T2_), L);
    T2_ >= T2;
    T1_ <= T1;
    T2_ - T1_ > T2 - T1.

pre_covered(N, P, E, (T1, T2), L) :-
    use_expansion(t);
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, _, (T1_, T2_), Lx);
    T2_ >= T2;
    T1_ <= T1;
    Lx < L.

covered(N, P, E, (T1, T2), L) :-
    use_expansion(t);
    e_candidate(N, P, E, (T1, T2), L);
    e_candidate(N, P, E, (T1_, T2_), L);
    T2_ >= T2;
    T1_ <= T1;
    T2_ - T1_ > T2 - T1.

covered(N, P, E, (T1, T2), L) :-
    use_expansion(t);
    e_candidate(N, P, E, (T1, T2), L);
    e_candidate(N, P, _, (T1_, T2_), Lx);
    T2_ >= T2;
    T1_ <= T1;
    Lx < L.

e_covered_by_higher(N, P, (T1, T2), L) :-
    use_expansion(t);
    e_candidate(N, P, _, (T1, T2), L);
    e_candidate(N, P, _, (T1_, T2_), Lx);
    Lx < L;
    T1_ <= T1;
    T2_ >= T2.

% define relation between levels
higher_priority(1, 2).
higher_priority(1, 3).
higher_priority(2, 3).

% initialization of non-persistent simple event
pre_candidate(N, P, E, (Tx, Tx), L) :-
    use_expansion(t);
    active_exists(N, P, E, Tx, L).

% forward expansion with the highest priority level
pre_candidate(N, P, E, (T1, T2_), L) :-
    use_expansion(t);
    highest_exists(N, L);
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, E, (T1_, T2_), L);
    period(N, E, D);
    T1_ <= T2 + D;
    T1_ > T2;
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2 <= Tx, Tx <= T1_.

%*
pre_candidate(N, P, E, (T1, T2_), L) :-
    use_expansion(t),
    highest_exists(N, L),
    pre_candidate(N, P, E, (T1, T2), L),
    pre_candidate(N, P, E, (T1_, T2_), L),
    period(E, D),
    T1_ <= T2 + D,
    T1_ > T2,
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2 <= Tx, Tx <= T1_.
*%

pre_candidate(N, P, E, (T1, T2_), L) :-
    use_expansion(t);
    not no_need_more_expansion(N);
    highest_exists(N, L1);
    lowest_exists(N, L2);
    L > L1;
    L < L2;
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, E, (T1_, T2_), L);
    period(N, E, D);
    T1_ <= T2 + D;
    T1_ > T2;
    not active_exists(N, P, _, Ty, Lx) : time_domain(Ty), higher_priority(Lx, L), T2 <= Ty, Ty <= T1_;
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2 <= Tx, Tx <= T1_.

%*
pre_candidate(N, P, E, (T1, T2_), L) :-
    use_expansion(t),
    not no_need_more_expansion(N),
    highest_exists(N, L1),
    lowest_exists(N, L2),
    L > L1,
    L < L2,
    pre_candidate(N, P, E, (T1, T2), L),
    pre_candidate(N, P, E, (T1_, T2_), L),
    period(E, D),
    T1_ <= T2 + D,
    T1_ > T2,
    not active_exists(N, P, _, Ty, Lx) : time_domain(Ty), higher_priority(Lx, L), T2 <= Ty, Ty <= T1_,
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2 <= Tx, Tx <= T1_.
*%

% keep only pre-candidates fully inside the current window and not dominated at their level
e_candidate(N, P, E, (T1, T2), L) :-
    use_expansion(t);
    pre_candidate(N, P, E, (T1, T2), L);
    time_scope(t, T1);
    time_scope(t, T2);
    not pre_covered(N, P, E, (T1, T2), L).

% expansion with other priority levels

e_candidate(N, P, E, (T1, T2_), L) :-
    use_expansion(t);
    e_candidate(N, P, E, (T1, T2), Lx);
    e_candidate(N, P, _, (T1_, T2_), L);
    L >= Lx;
    not e_covered_by_higher(N, P, (T1_, T2_), L);
    period(N, E, D);
    T1_ <= T2 + D;
    T1_ > T2;
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2 <= Tx, Tx <= T1_.

%*
e_candidate(N, P, E, (T1, T2_), L) :-
    use_expansion(t),
    e_candidate(N, P, E, (T1, T2), Lx),
    e_candidate(N, P, _, (T1_, T2_), L),
    L >= Lx,
    period(E, D),
    T1_ <= T2 + D,
    T1_ > T2,
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2 <= Tx, Tx <= T1_.
*%

% backward expansion with other priority levels

e_candidate(N, P, E, (T1_, T2), L) :-
    use_expansion(t);
    e_candidate(N, P, E, (T1, T2), Lx);
    e_candidate(N, P, _, (T1_, T2_), L);
    L >= Lx;
    not e_covered_by_higher(N, P, (T1_, T2), L);
    period(N, E, D);
    T2_ >= T1 - D;
    T2_ < T1;
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2_ <= Tx, Tx <= T1.

%*
e_candidate(N, P, E, (T1_, T2), L) :-
    use_expansion(t),
    e_candidate(N, P, E, (T1, T2), Lx),
    e_candidate(N, P, _, (T1_, T2_), L),
    L >= Lx,
    period(E, D),
    T2_ >= T1 - D,
    T2_ < T1,
    not active_terminates(N, P, _, Tx, _) : time_domain(Tx), T2_ <= Tx, Tx <= T1.
*%

% expansion with termination condition

e_candidate(N, P, E, (T1, Tf), L) :-
    use_expansion(t),
    e_candidate(N, P, E, (T1, T2), L1),
    end_obs(N, P, E, (T2, Tf), L2),
    Tf != @ongoing_time(unit),
    L = #max{ Lx : e_candidate(N, P, E, (T1, T2), Lx); Ly : end_obs(N, P, E, (T2, Tf), Ly) }.

% meet e_candidate

e_candidate(N, P, E, (T1, T2), L) :-
    use_expansion(t),
    e_candidate(N, P, E, (T1, T), L),
    e_candidate(N, P, E, (T, T2), L).

% final event

event(@get_id(N, P, E, T1, T2_), N, P, E, (T1, T2_), L) :-
    use_expansion(t),
    e_candidate(N, P, E, (T1, T2_), L),
    not covered(N, P, E, (T1, T2_), L).
