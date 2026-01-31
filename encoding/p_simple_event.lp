% ==============================================================================
% CASPER version v1.0.3
% Author: Yvon K. Awuklu
% Description: Linear technique for clinical event detection encoding
% See Theorem 1 in the paper for details
% ==============================================================================

% find the termination time of the event
pre_end_obs(N, P, E, (T, Tnext), L) :- exists_pers(N, P, E, T, L1); terminates(N, P, E, Tnext, L); Tnext > T;
    not exists_pers(N, P, E, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :- exists_pers(N, P, E, T, L1); terminates(P, Tnext, L); Tnext > T;
    not exists_pers(N, P, E, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext.

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

pe_candidate(N, P, E, (T1, T2), L) :- l_candidate(N, P, E, (T1, T1), L1); end_obs(N, P, E, (T1_, T2), L2); window(S, _); T1_ >= T1;
    not pe_covered_by_higher(N, P, E, (T1, T1), L1);
    T1 = #min{ T3 : exists_pers(N, P, E, T3, L1), S <= T3, T3 < T2 };
    T2 = #min{ T4 : terminates(N, P, E, T4, L2), T1 < T4; T5 : terminates(P, T5, L2), T1 < T5 };
    L = #max{ L1; L2 }.

pe_candidate(N, P, E, (T1, T2), L) :- l_candidate(N, P, E, (T1, T1), L1); end_obs(N, P, E, (T1_, T2), L2); T1_ >= T1;
    not pe_covered_by_higher(N, P, E, (T1, T1), L1);
    end_obs(N, P, E, (T3, T4), _); T4 < T1;
    T4 = #max{ T5 : terminates(N, P, _, T5, L2), T5 < T1 };
    T1 = #min{ T6 : exists_pers(N, P, _, T6, L1), T4 < T6 };
    T2 = #min{ T7 : terminates(N, P, _, T7, L2), T1 < T7; T8 : terminates(P, T8, L2), T1 < T8 };
    L = #max{ L1; L2 }.

% final event
event(@get_id(N, P, E, T1, T2_), N, P, E, (T1, T2_), L) :- pe_candidate(N, P, E, (T1, T2_), L).
