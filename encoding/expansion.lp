% ==============================================================================
% CASPER version v1.0.1
% Author: Yvon K. Awuklu
% Description: Expansion technique for clinical event detection encoding
% See Theorem 1 in the paper for details
% ==============================================================================

% find the termination time of the event
pre_end_obs(N, P, E, (T, Tnext), L) :- exists(N, P, E, T, L1); terminates(N, P, E, Tnext, L); pt_window(N, E, D); Tnext <= (T + D); Tnext > T;
    not exists(N, P, E, Tx, _) : valid_time(Tx), T < Tx, Tx <= Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :- exists(N, P, E, T, L1); terminates(P, Tnext, L); pt_window(N, E, D); Tnext <= (T + D); Tnext > T;
    not exists(N, P, E, Tx, _) : valid_time(Tx), T < Tx, Tx <= Tnext.

end_obs(N, P, E, (T, Tnext), L) :- pre_end_obs(N, P, E, (T, Tnext), L); not end_covered(N, P, E, (T, Tnext), L).


end_covered(N, P, E, (T1, T2), L) :-
    pre_end_obs(N, P, E, (T1, T2), L);
    pre_end_obs(N, P, E, (T1_, T2_), Lx);
    T2_ <= T2;
    T1_ >= T1;
    T2_ - T1_ < T2 - T1;
    Lx <= L.

% check if the event is covered by another event
pre_covered(N, P, E, (T1, T2), L) :-
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, E, (T1_, T2_), L);
    T2_ >= T2;
    T1_ <= T1;
    T2_ - T1_ > T2 - T1.

pre_covered(N, P, E, (T1, T2), L) :-
    pre_candidate(N, P, E, (T1, T2), L);
    pre_candidate(N, P, _, (T1_, T2_), Lx);
    T2_ >= T2;
    T1_ <= T1;
    Lx < L.

covered(N, P, E, (T1, T2), L) :-
    e_candidate(N, P, E, (T1, T2), L);
    e_candidate(N, P, E, (T1_, T2_), L);
    T2_ >= T2;
    T1_ <= T1;
    T2_ - T1_ > T2 - T1.

covered(N, P, E, (T1, T2), L) :-
    e_candidate(N, P, E, (T1, T2), L);
    e_candidate(N, P, _, (T1_, T2_), Lx);
    T2_ >= T2;
    T1_ <= T1;
    Lx < L.

e_covered_by_higher(N, P, (T1, T2), L) :-
    e_candidate(N, P, _, (T1, T2), L);
    e_candidate(N, P, _, (T1_, T2_), Lx);
    Lx < L;
    T1_ <= T1;
    T2_ >= T2.

% initialization of non-persistent simple event
pre_candidate(N, P, E, (Tx, Tx), L) :- exists(N, P, E, Tx, L).

% forward expansion of event
% first expansion with the highest priority level
pre_candidate(N, P, E, (T1, T2_), L) :- highest_exists(N, L); pre_candidate(N, P, E, (T1, T2), L); pre_candidate(N, P, E, (T1_, T2_), L); pt_window(N, E, D); T1_ <= (T2 + D); T1_ > T2;
    not terminates(N, P, _, Tx, _) : valid_time(Tx), T2 <= Tx, Tx <= T1_.

pre_candidate(N, P, E, (T1, T2_), L) :- not no_need_more_expansion(N); highest_exists(N, L1); lowest_exists(N, L2); L > L1; L < L2; pre_candidate(N, P, E, (T1, T2), L); pre_candidate(N, P, E, (T1_, T2_), L); pt_window(N, E, D); T1_ <= (T2 + D); T1_ > T2;
    not exists(N, P, _, Ty, L1) : valid_time(Ty), T2 <= Ty, Ty <= T1_, higher_priority(L1, L); 
    not terminates(N, P, _, Tx, _) : valid_time(Tx), T2 <= Tx, Tx <= T1_.

e_candidate(N, P, E, (T1, T2_), L) :- pre_candidate(N, P, E, (T1, T2_), L); not pre_covered(N, P, E, (T1, T2_), L).

% second expansion with other priority levels
e_candidate(N, P, E, (T1, T2_), L) :- e_candidate(N, P, E, (T1, T2), Lx); e_candidate(N, P, _, (T1_, T2_), L); L >= Lx; pt_window(N, E, D); T1_ <= (T2 + D); T1_ > T2;
    not e_covered_by_higher(N, P, (T1_, T2_), L);
    not terminates(N, P, _, Tx, _) : valid_time(Tx), T2 <= Tx, Tx <= T1_.

% backward expansion of event
% second expansion with other priority levels
e_candidate(N, P, E, (T1_, T2), L) :- e_candidate(N, P, E, (T1, T2), Lx); e_candidate(N, P, _, (T1_, T2_), L); L >= Lx; pt_window(N, E, D); T2_ >= (T1 - D); T2_ < T1;
    not e_covered_by_higher(N, P, (T1_, T2_), L);
    not terminates(N, P, _, Tx, _) : valid_time(Tx), T2_ <= Tx, Tx <= T1.

% expansion with termination condition
e_candidate(N, P, E, (T1, Tf), L) :- e_candidate(N, P, E, (T1, T2), L1); end_obs(N, P, E, (T2, Tf), L2);
    L = #max{ Lx : e_candidate(N, P, E, (T1, T2), Lx); Ly : end_obs(N, P, E, (T2, Tf), Ly) }.

% meet e_candidate
e_candidate(N, P, E, (T1, T2), L) :- e_candidate(N, P, E, (T1, T), L); e_candidate(N, P, E, (T, T2), L).

% final event
event(@get_id(N, P, E, T1, T2_), N, P, E, (T1, T2_), L) :- e_candidate(N, P, E, (T1, T2_), L); not covered(N, P, E, (T1, T2_), L).

#show.