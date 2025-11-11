#program step(t).
#external use_linear(t).

% ==============================================================================
% CASPER version v1.0.0
% Author: Yvon K. Awuklu
% Description: Linear technique for clinical event detection encoding
% See Theorem 1 in the paper for details
% ==============================================================================

pre_end_obs(N, P, E, (T, Tnext), L) :-
    use_linear(t),
    active_exists_pers(N, P, E, T, _),
    active_terminates(N, P, _, Tnext, L),
    Tnext > T,
    not active_exists_pers(N, P, _, Tx, _) : time_domain(Tx), T < Tx, Tx < Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :-
    use_linear(t),
    active_exists_pers(N, P, E, T, _),
    active_terminates(P, Tnext, L),
    Tnext > T,
    not active_exists_pers(N, P, _, Tx, _) : time_domain(Tx), T < Tx, Tx < Tnext.

l_candidate(N, P, E, (Tx, Tx), L) :-
    use_linear(t),
    active_exists_pers(N, P, E, Tx, L).

e_candidate(N, P, E, (T1, T2), L) :-
    use_linear(t),
    l_candidate(N, P, E, (T1, T2_), L1),
    pre_end_obs(N, P, E, (T1_, T2), L2),
    not active_terminates(N, P, E, T, _) : time_domain(T), T2_ < T, T < T2,
    L = #max{ Lx : l_candidate(N, P, E, (T1, T2_), Lx); Ly : pre_end_obs(N, P, E, (T1_, T2), Ly) }.
