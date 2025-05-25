% ==============================================================================
% CASPER version v1.0.0
% Author: Yvon K. Awuklu
% Description: temporal repair encoding
% ==============================================================================

{ rep_event(ID, N, P, E, (Start, End), L) } :- event(ID, N, P, E, (Start, End), L).

% an event should not be equals to another event of the same type
:- rep_event(ID1, N, P, E, (Start, End), _), rep_event(ID2, N, P, E, (Start, End), _), ID1 != ID2, equals((Start, End), (Start, End)).

% an event should not be contains by by another event of the same type
:- rep_event(_, N, P, E, (Start1, End1), _), rep_event(_, N, P, E, (Start2, End2), _), contains((Start1, End1), (Start2, End2)).

% an event should not be starts by another event of the same type
:- rep_event(_, N, P, E, (Start, End1), _), rep_event(_, N, P, E, (Start, End2), _), starts((Start, End1), (Start, End2)).

% an event should not be finishes by by another event of the same type
:- rep_event(_, N, P, E, (Start1, End), _), rep_event(_, N, P, E, (Start2, End), _), finishes((Start1, End), (Start2, End)).

% ensure maximality: for every element not in the set, adding it would cause a conflict
inconsistent_if_added(N, P, E, (Start, End2)) :- rep_event(_, N, P, E, (Start, End1), _), starts((Start, End1), (Start, End2)).
inconsistent_if_added(N, P, E, (Start, End1)) :- rep_event(_, N, P, E, (Start, End2), _), starts((Start, End1), (Start, End2)).

inconsistent_if_added(N, P, E, (Start2, End2)) :- rep_event(_, N, P, E, (Start1, End1), _), overlaps((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start1, End1)) :- rep_event(_, N, P, E, (Start2, End2), _), overlaps((Start1, End1), (Start2, End2)).

inconsistent_if_added(N, P, E, (Start2, End2)) :- rep_event(_, N, P, E, (Start1, End1), _), contains((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start1, End1)) :- rep_event(_, N, P, E, (Start2, End2), _), contains((Start1, End1), (Start2, End2)).

inconsistent_if_added(N, P, E, (Start2, End)) :- rep_event(_, N, P, E, (Start1, End), _), finishes((Start1, End), (Start2, End)).
inconsistent_if_added(N, P, E, (Start1, End)) :- rep_event(_, N, P, E, (Start2, End), _), finishes((Start1, End), (Start2, End)).

:- not rep_event(_, N, P, E, (Start, End), _), event(_, N, P, E, (Start, End), _), not inconsistent_if_added(N, P, E, (Start, End)).