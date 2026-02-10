% ==============================================================================
% CASPER version v1.1.0
% Author: Yvon K. Awuklu
% Description: Linear technique for inferring persistent simple events
% See Theorem 1 in the paper for details
% ==============================================================================

% find the termination time of the event
pre_end_obs(N, P, E, (T, Tnext), L) :- exists_pers(N, P, E, T, L1); terminates(N, P, E, Tnext, L); Tnext > T;
    not exists_pers(N, P, E, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext; L1 = #min{ Lx : exists_pers(N, P, E, T, Lx) }; L = #min{ Lx : terminates(N, P, E, Tnext, Lx) }.

pre_end_obs(N, P, E, (T, Tnext), L) :- exists_pers(N, P, E, T, L1); terminates(P, Tnext, L); Tnext > T;
    not exists_pers(N, P, E, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext; L1 = #min{ Lx : exists_pers(N, P, E, T, Lx) }.

end_obs(N, P, E, (T, Tnext), L) :- pre_end_obs(N, P, E, (T, Tnext), L); not end_covered(N, P, E, (T, Tnext), L).

end_covered(N, P, E, (T1, T2), L) :-
    pre_end_obs(N, P, E, (T1, T2), L);
    pre_end_obs(N, P, E, (T1_, T2_), L);
    T2_ <= T2;
    T1_ >= T1;
    T2_ - T1_ < T2 - T1.

% auxiliary predicates
pe_covered_by_higher(N, P, E, (T1, T1), L) :-
    l_candidate(N, P, E, (T1, T1), L);
    pe_candidate(N, P, E, (T1_, T2_), Lx);
    Lx < L;
    T1_ <= T1;
    T2_ >= T1.

% initialization of persistent simple event
l_candidate(N, P, E, (Tx, Tx), L) :- exists_pers(N, P, E, Tx, L);
    L = #min{ Lx : exists_pers(N, P, E, Tx, Lx) }.

pe_candidate(N, P, E, (T1, T2), L1) :- l_candidate(N, P, E, (T1, T1), L1); end_obs(N, P, E, (T1_, T2), L2); window(S, _); T1_ >= T1;
    not pe_covered_by_higher(N, P, E, (T1, T1), L1); L2 <= L1;
    T1 = #min{ T3 : exists_pers(N, P, E, T3, L1), S <= T3, T3 < T2 };
    T2 = #min{ T4 : terminates(N, P, E, T4, L3), T1 < T4, L3 <= L1; T5 : terminates(P, T5, L4), T1 < T5, L4 <= L1 }.

pe_candidate(N, P, E, (T1, T2), L1) :- l_candidate(N, P, E, (T1, T1), L1); end_obs(N, P, E, (T1_, T2), L2); T1_ >= T1;
    not pe_covered_by_higher(N, P, E, (T1, T1), L1); L2 <= L1;
    end_obs(N, P, E, (T3, T4), L3); T4 < T1; L3 <= L1;
    T4 = #max{ T5 : terminates(N, P, E, T5, L4), T5 < T1, L4 <= L1 };
    T1 = #min{ T6 : exists_pers(N, P, E, T6, L1), T4 < T6 };
    T2 = #min{ T7 : terminates(N, P, E, T7, L5), T1 < T7, L5 <= L1; T8 : terminates(P, T8, L6), T1 < T8, L6 <= L1 }.

% final event
event(@get_id(N, P, E, T1, T2_), N, P, E, (T1, T2_), L) :- pe_candidate(N, P, E, (T1, T2_), L).
