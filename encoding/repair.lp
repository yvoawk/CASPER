% ==============================================================================
% CASPER version v1.0.1
% Author: Yvon K. Awuklu
% Description: temporal repair encoding
% See Section 2.2 & Section 2.3 (Definitions 6, 7, 8) in the paper for details
% ==============================================================================

{ rep_event(ID, N, P, E, (Start, End), L) } :- event(ID, N, P, E, (Start, End), L).

% an event should not be contains by another event of the same type
:- rep_event(_, N, P, E, (Start1, End1), _), rep_event(_, N, P, E, (Start2, End2), _), contains((Start1, End1), (Start2, End2)).
:- rep_event(_, N, P, E, (Start1, End1), _), rep_event(_, N, P, E, (Start2, End2), _), p_during((Start1, End1), (Start2, End2)).

% an event should not be starts by another event of the same type
:- rep_event(_, N, P, E, (Start, End1), _), rep_event(_, N, P, E, (Start, End2), _), starts((Start, End1), (Start, End2)).
:- rep_event(_, N, P, E, (Start, End1), _), rep_event(_, N, P, E, (Start, End2), _), p_starts((Start, End1), (Start, End2)).

% an event should not be finishes by another event of the same type
:- rep_event(_, N, P, E, (Start1, End), _), rep_event(_, N, P, E, (Start2, End), _), finishes((Start1, End), (Start2, End)).
:- rep_event(_, N, P, E, (Start1, End), _), rep_event(_, N, P, E, (Start2, End), _), p_finishes((Start1, End), (Start2, End)).

% ensure maximality: for every element not in the set, adding it would cause a conflict
inconsistent_if_added(N, P, E, (Start, End2)) :- rep_event(_, N, P, E, (Start, End1), _), starts((Start, End1), (Start, End2)).
inconsistent_if_added(N, P, E, (Start, End1)) :- rep_event(_, N, P, E, (Start, End2), _), starts((Start, End1), (Start, End2)).

inconsistent_if_added(N, P, E, (Start, End2)) :- rep_event(_, N, P, E, (Start, End1), _), p_starts((Start, End1), (Start, End2)).
inconsistent_if_added(N, P, E, (Start, End1)) :- rep_event(_, N, P, E, (Start, End2), _), p_starts((Start, End1), (Start, End2)).

inconsistent_if_added(N, P, E, (Start2, End2)) :- rep_event(_, N, P, E, (Start1, End1), _), contains((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start1, End1)) :- rep_event(_, N, P, E, (Start2, End2), _), contains((Start1, End1), (Start2, End2)).

inconsistent_if_added(N, P, E, (Start2, End2)) :- rep_event(_, N, P, E, (Start1, End1), _), p_during((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start1, End1)) :- rep_event(_, N, P, E, (Start2, End2), _), p_during((Start1, End1), (Start2, End2)).

inconsistent_if_added(N, P, E, (Start2, End)) :- rep_event(_, N, P, E, (Start1, End), _), finishes((Start1, End), (Start2, End)).
inconsistent_if_added(N, P, E, (Start1, End)) :- rep_event(_, N, P, E, (Start2, End), _), finishes((Start1, End), (Start2, End)).

inconsistent_if_added(N, P, E, (Start2, End)) :- rep_event(_, N, P, E, (Start1, End), _), p_finishes((Start1, End), (Start2, End)).
inconsistent_if_added(N, P, E, (Start1, End)) :- rep_event(_, N, P, E, (Start2, End), _), p_finishes((Start1, End), (Start2, End)).

:- not rep_event(_, N, P, E, (Start, End), _), event(_, N, P, E, (Start, End), _), not inconsistent_if_added(N, P, E, (Start, End)).