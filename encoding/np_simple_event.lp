% ==============================================================================
% CASPER version v1.1.0
% Author: Yvon K. Awuklu
% Description: Expansion technique for inferring non-persistent simple events
% See Theorem 1 in the paper for details
% ==============================================================================

% prune non-maximal candidates
pre_covered(N, P, E, (T1, T2), L) :-
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, E, (T1_, T2_), L);
    T2_ >= T2;
    T1_ <= T1;
    T2_ - T1_ > T2 - T1.

covered(N, P, E, (T1, T2), L) :-
    e_candidate(N, P, E, (T1, T2), L);
    e_candidate(N, P, E, (T1_, T2_), L);
    T2_ >= T2;
    T1_ <= T1;
    T2_ - T1_ > T2 - T1.

% initialization of non-persistent simple event
pre_candidate(N, P, E, (Tx, Tx), L) :- exists(N, P, E, Tx, L);
    L = #min{ Lx : exists(N, P, E, Tx, Lx) }.

% expansion with the highest priority level
pre_candidate(N, P, E, (T1, T2_), L) :- highest_exists_per_event(N, P, E, L); pre_candidate(N, P, E, (T1, T2), L); pre_candidate(N, P, E, (T1_, T2_), L); pt_window(N, E, D);
    T1_ = #max{ Ty : exists(N, P, E, Ty, L) , Ty <= (T2 + D), Ty > T2 };
    not terminates(N, P, E, Tx, L) : valid_time(Tx), T2 <= Tx, Tx <= T1_.

pre_candidate(N, P, E, (T1, T2_), L) :- highest_exists_per_event(N, P, E, L); pre_candidate(N, P, E, (T1, T2), L); pre_candidate(N, P, E, (T1_, T2_), L); pt_window(N, E, D);
    terminates(N, P, E, T3, L); T2_ < T3; T2 < T3; T3 <= (T2 + D);
    T1_ = #max{ Ty : exists(N, P, E, Ty, L) , Ty <= (T2 + D), Ty > T2, Ty < T3 };
    not terminates(N, P, E, Tx, L) : valid_time(Tx), T2 <= Tx, Tx <= T1_.

% expansion with other priority levels
pre_candidate(N, P, E, (T1, T2_), L) :- highest_exists_per_event(N, P, E, L1); L != L1; valid_level(N, P, E, L); pre_candidate(N, P, E, (T1, T2), L2); pre_candidate(N, P, E, (T1_, T2_), L3); pt_window(N, E, D);
    T1_ = #max{ Ty : exists(N, P, E, Ty, L5) , Ty <= (T2 + D), Ty > T2, L5 <= L }; L2 <= L; L3 <= L;
    not terminates(N, P, E, Tx, L4) : valid_time(Tx), T2 <= Tx, Tx <= T1_, L4 <= L, valid_level(N, P, E, L4).

pre_candidate(N, P, E, (T1, T2_), L) :- highest_exists_per_event(N, P, E, L1); L != L1; valid_level(N, P, E, L); pre_candidate(N, P, E, (T1, T2), L2); pre_candidate(N, P, E, (T1_, T2_), L3); pt_window(N, E, D);
    terminates(N, P, E, T3, L4); T2_ < T3; L2 <= L; L3 <= L; L4 <= L; T3 <= (T2 + D); T2 < T3;
    T1_ = #max{ Ty : exists(N, P, E, Ty, L5) , Ty <= (T2 + D), Ty > T2, Ty < T3, L5 <= L };
    not terminates(N, P, E, Tx, L6) : valid_time(Tx), T2 <= Tx, Tx <= T1_, L6 <= L, valid_level(N, P, E, L6).

% final candidate event after expansion after pruning non-maximal candidates
e_candidate(N, P, E, (T1, T2_), L) :- pre_candidate(N, P, E, (T1, T2_), L); not pre_covered(N, P, E, (T1, T2_), L).

% expansion with termination condition
e_candidate(N, P, E, (T1, Tf), L) :- e_candidate(N, P, E, (T1, T2), L); terminates(N, P, E, Tf, L2); L2 <= L; pt_window(N, E, D); T2 < Tf; Tf <= (T2 + D);
    not terminates(N, P, E, Tx, L3) : valid_time(Tx), T2 <= Tx, Tx < Tf, L3 <= L, valid_level(N, P, E, L3).

e_candidate(N, P, E, (T1, Tf), L) :- e_candidate(N, P, E, (T1, T2), L); terminates(P, Tf, L2); L2 <= L; pt_window(N, E, D); T2 < Tf; Tf <= (T2 + D);
    not terminates(N, P, E, Tx, L3) : valid_time(Tx), T2 <= Tx, Tx < Tf, L3 <= L, valid_level(N, P, E, L3).

% final event
event(@get_id(N, P, E, T1, T2), N, P, E, (T1, T2), L) :- e_candidate(N, P, E, (T1, T2), L); not e_candidate(N, P, E, (T1, T2), L1) : L1 < L, valid_level(N, P, E, L1); not covered(N, P, E, (T1, T2), L).

#show.
