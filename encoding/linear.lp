% ==============================================================================
% CASPER version v1.0.0
% Author: Yvon K. Awuklu
% Description: Linear technique for clinical event detection encoding
% ==============================================================================

% find the termination time of the event
pre_end_obs(N, P, E, (T, Tnext), L) :- exists_until(N, P, E, T, L1); terminates(N, P, E_, Tnext, L); Tnext > T;
    not exists_until(N, P, _, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext.

pre_end_obs(N, P, E, (T, Tnext), L) :- exists_until(N, P, E, T, L1); terminates(P, Tnext, L); Tnext > T;
    not exists_until(N, P, _, Tx, _) : valid_time(Tx), T < Tx, Tx < Tnext.

% initialization of event
l_candidate(N, P, E, (Tx, Tx), L) :- exists_until(N, P, E, Tx, L).

e_candidate(N, P, E, (T1, T2), L) :- l_candidate(N, P, E, (T1, T2_), L1); end_obs(N, P, E, (T1_, T2), L2);
    not terminates(N, P, E, T, _) : valid_time(T), T2_ < T, T < T2;
    L = #max{ Lx : l_candidate(N, P, E, (T1, T2_), Lx); Ly : end_obs(N, P, E, (T1_, T2), Ly) }.