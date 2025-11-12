% ==============================================================================
% CASPER version v1.0.1
% Author: Yvon K. Awuklu
% Description: Linear technique for clinical event detection encoding
% See Theorem 1 in the paper for details
% ==============================================================================

% find the termination time of the event
pre_end_obs(N, P, E, (T, Tnext), L) :- exists_pers(N, P, E, T, L1); terminates(N, P, E_, Tnext, L); Tnext > T;
    not exists_pers(N, P, _, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :- exists_pers(N, P, E, T, L1); terminates(P, Tnext, L); Tnext > T;
    not exists_pers(N, P, _, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext.

% auxiliary predicates
pe_covered_by_higher(N, P, E, (T1, T1), L) :-
    l_candidate(N, P, E, (T1, T1), L);
    pe_candidate(N, P, E, (T1_, T2_), Lx);
    Lx < L;
    T1_ <= T1;
    T2_ >= T1.

% initialization of persistent simple event
l_candidate(N, P, E, (Tx, Tx), L) :- exists_pers(N, P, E, Tx, L).

pe_candidate(N, P, E, (T1, T2), L) :- l_candidate(N, P, E, (T1, T1), L1); end_obs(N, P, E, (T1_, T2), L2); window(S, _); T1_ >= T1;
    not pe_covered_by_higher(N, P, E, (T1, T1), L1);
    not l_candidate(N, P, E, (T3, T3), L3) : valid_time(T3), S <= T3, T3 < T1, same_priority(L1, L3);
    not terminates(N, P, E, T, _) : valid_time(T), T1 < T, T < T2;
    L = #max{ Lx : l_candidate(N, P, E, (T1, T1), Lx); Ly : end_obs(N, P, E, (T1_, T2), Ly) }.

pe_candidate(N, P, E, (T1, T2), L) :- l_candidate(N, P, E, (T1, T1), L1); end_obs(N, P, E, (T1_, T2), L2); T1_ >= T1;
    not pe_covered_by_higher(N, P, E, (T1, T1), L1);
    end_obs(N, P, E, (T3, T4), _); T4 < T1;
    not l_candidate(N, P, E, (T5, T5), L3) : valid_time(T5), T4 <= T5, T5 < T1, same_priority(L1, L3);
    not terminates(N, P, E, T, _) : valid_time(T), T1 < T, T < T2;
    L = #max{ Lx : l_candidate(N, P, E, (T1, T1), Lx); Ly : end_obs(N, P, E, (T1_, T2), Ly) }.

% final event
event(@get_id(N, P, E, T1, T2_), N, P, E, (T1, T2_), L) :- pe_candidate(N, P, E, (T1, T2_), L).

