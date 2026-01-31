% ==============================================================================
% CASPER version v1.0.3
% Author: Yvon K. Awuklu
% Description: Greedy preference encoding
% See Theorem 5 in the paper for details
% ==============================================================================

temporal_conflict_with_lower_level(N, P, E, (Start2, End2), L2) :-
    event(_, N, P, E, (Start1, End1), L1);
    event(_, N, P, E, (Start2, End2), L2);
    L1 < L2;
    Start1 < Start2, Start2 < End1.

temporal_conflict_with_lower_level(N, P, E, (Start2, End2), L2) :-
    event(_, N, P, E, (Start1, End1), L1);
    event(_, N, P, E, (Start2, End2), L2);
    L1 < L2;
    Start2 < Start1, Start1 < End2.

temporal_conflict_with_lower_level(N, P, E, (Start, End2), L2) :-
    event(_, N, P, E, (Start, End1), L1);
    event(_, N, P, E, (Start, End2), L2);
    L1 < L2;
    End1 != End2.

temporal_conflict_with_lower_level(N, P, E, (Start2, End), L2) :-
    event(_, N, P, E, (Start1, End), L1);
    event(_, N, P, E, (Start2, End), L2);
    L1 < L2;
    Start1 != Start2.

rep_event(ID, N, P, E, (Start, End), L) :-
    event(ID, N, P, E, (Start, End), L),
    not temporal_conflict_with_lower_level(N, P, E, (Start, End), L).

%#show event(ID, N, P, E, (Start, End), L) : rep_event(ID, N, P, E, (Start, End), L).
%#show event/5.
