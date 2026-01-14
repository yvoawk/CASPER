% ==============================================================================
% CASPER version v1.0.2
% Author: Yvon K. Awuklu
% Description: Preferred repair encoding
% See Section 2.2 & Section 2.3 (Definitions 6, 7, 8) in the paper for details
% ==============================================================================

violates((S1,E1),(S2,E2)) :- contains((S1,E1),(S2,E2)).
violates((S1,E1),(S2,E2)) :- p_during((S1,E1),(S2,E2)).
violates((S,E1),(S,E2)) :- starts((S,E1),(S,E2)).
violates((S,E1),(S,E2)) :- p_starts((S,E1),(S,E2)).
violates((S1,E),(S2,E)) :- finishes((S1,E),(S2,E)).
violates((S1,E),(S2,E)) :- p_finishes((S1,E),(S2,E)).

% choose any subset of level-1 facts
{ rep1(ID,N,P,E,(S,Ee)) } :- event(ID,N,P,E,(S,Ee),1).

% forbid pairwise violations inside level 1
:- rep1(_,N,P,E,(S1,E1)), rep1(_,N,P,E,(S2,E2)), violates((S1,E1),(S2,E2)).
:- rep1(_,N,P,E,(S,E1)), rep1(_,N,P,E,(S,E2)), violates((S,E1),(S,E2)).
:- rep1(_,N,P,E,(S1,E)), rep1(_,N,P,E,(S2,E)), violates((S1,E),(S2,E)).

% inclusion maximal at level 1:
% if a level-1 event is not chosen and adding it would NOT create a violation,
% then the model is rejected -> forces maximality
safe_to_add1(N,P,E,(S,Ee)) :-
    event(_,N,P,E,(S,Ee),1),
    not violation_with_rep1_if_added(N,P,E,(S,Ee)).

violation_with_rep1_if_added(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,E1)), violates((S1,E1),(S,Ee)).
violation_with_rep1_if_added(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S,E1)), violates((S,E1),(S,Ee)).
violation_with_rep1_if_added(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,Ee)), violates((S1,Ee),(S,Ee)).

:- event(_,N,P,E,(S,Ee),1), not rep1(_,N,P,E,(S,Ee)), safe_to_add1(N,P,E,(S,Ee)).

% choose among level-2 events that do not conflict with fixed level-1 choices
{ rep2(ID,N,P,E,(S,Ee)) } :-
    event(ID,N,P,E,(S,Ee),2),
    not conflicts_higher2(N,P,E,(S,Ee)).

conflicts_higher2(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,E1)), violates((S1,E1),(S,Ee)).
conflicts_higher2(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S,E1)), violates((S,E1),(S,Ee)).
conflicts_higher2(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,Ee)), violates((S1,Ee),(S,Ee)).

% forbid pairwise violations inside level 2
:- rep2(_,N,P,E,(S1,E1)), rep2(_,N,P,E,(S2,E2)), violates((S1,E1),(S2,E2)).
:- rep2(_,N,P,E,(S,E1)), rep2(_,N,P,E,(S,E2)), violates((S,E1),(S,E2)).
:- rep2(_,N,P,E,(S1,E)), rep2(_,N,P,E,(S2,E)), violates((S1,E),(S2,E)).

% inclusion maximal at level 2
safe_to_add2(N,P,E,(S,Ee)) :-
    event(_,N,P,E,(S,Ee),2),
    not conflicts_higher2(N,P,E,(S,Ee)),
    not violation_with_rep2_if_added(N,P,E,(S,Ee)).

violation_with_rep2_if_added(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S1,E1)), violates((S1,E1),(S,Ee)).
violation_with_rep2_if_added(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S,E1)), violates((S,E1),(S,Ee)).
violation_with_rep2_if_added(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S1,Ee)), violates((S1,Ee),(S,Ee)).

:- event(_,N,P,E,(S,Ee),2), not rep2(_,N,P,E,(S,Ee)), safe_to_add2(N,P,E,(S,Ee)).

{ rep3(ID,N,P,E,(S,Ee)) } :-
    event(ID,N,P,E,(S,Ee),3),
    not conflicts_higher3(N,P,E,(S,Ee)).

conflicts_higher3(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,E1)), violates((S1,E1),(S,Ee)).
conflicts_higher3(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S1,E1)), violates((S1,E1),(S,Ee)).
conflicts_higher3(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S,E1)), violates((S,E1),(S,Ee)).
conflicts_higher3(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S,E1)), violates((S,E1),(S,Ee)).
conflicts_higher3(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,Ee)), violates((S1,Ee),(S,Ee)).
conflicts_higher3(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S1,Ee)), violates((S1,Ee),(S,Ee)).

% forbid pairwise violations inside level 3
:- rep3(_,N,P,E,(S1,E1)), rep3(_,N,P,E,(S2,E2)), violates((S1,E1),(S2,E2)).
:- rep3(_,N,P,E,(S,E1)), rep3(_,N,P,E,(S,E2)), violates((S,E1),(S,E2)).
:- rep3(_,N,P,E,(S1,E)), rep3(_,N,P,E,(S2,E)), violates((S1,E),(S2,E)).

% inclusion maximal at level 3
safe_to_add3(N,P,E,(S,Ee)) :-
    event(_,N,P,E,(S,Ee),3),
    not conflicts_higher3(N,P,E,(S,Ee)),
    not violation_with_rep3_if_added(N,P,E,(S,Ee)).

violation_with_rep3_if_added(N,P,E,(S,Ee)) :-
    rep3(_,N,P,E,(S1,E1)), violates((S1,E1),(S,Ee)).
violation_with_rep3_if_added(N,P,E,(S,Ee)) :-
    rep3(_,N,P,E,(S,E1)), violates((S,E1),(S,Ee)).
violation_with_rep3_if_added(N,P,E,(S,Ee)) :-
    rep3(_,N,P,E,(S1,Ee)), violates((S1,Ee),(S,Ee)).

:- event(_,N,P,E,(S,Ee),3), not rep3(_,N,P,E,(S,Ee)), safe_to_add3(N,P,E,(S,Ee)).

rep_event(ID,N,P,E,(S,Ee),L) :- rep1(ID,N,P,E,(S,Ee)), L=1.
rep_event(ID,N,P,E,(S,Ee),L) :- rep2(ID,N,P,E,(S,Ee)), L=2.
rep_event(ID,N,P,E,(S,Ee),L) :- rep3(ID,N,P,E,(S,Ee)), L=3.

conflict_higher2(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,E1)), contains((S1,E1),(S,Ee)), event(_,N,P,E,(S,Ee),2).
conflict_higher2(N,P,E,(S1,E1)) :-
    rep1(_,N,P,E,(S,Ee)), contains((S1,E1),(S,Ee)), event(_,N,P,E,(S1,E1),2).

conflict_higher3(N,P,E,(S,Ee)) :-
    rep1(_,N,P,E,(S1,E1)), contains((S1,E1),(S,Ee)), rep3(_,N,P,E,(S,Ee)).
conflict_higher3(N,P,E,(S1,E1)) :-
    rep1(_,N,P,E,(S,Ee)), contains((S1,E1),(S,Ee)), rep3(_,N,P,E,(S1,E1)).

conflict_higher3(N,P,E,(S,Ee)) :-
    rep2(_,N,P,E,(S2,E2)), contains((S2,E2),(S,Ee)), rep3(_,N,P,E,(S,Ee)).
conflict_higher3(N,P,E,(S2,E2)) :-
    rep2(_,N,P,E,(S,Ee)), contains((S2,E2),(S,Ee)), rep3(_,N,P,E,(S2,E2)).

inconsistent_if_added(N, P, E, (Start1, End1)) :- rep3(_, N, P, E, (Start2, End2), _), contains((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start2, End2)) :- rep3(_, N, P, E, (Start1, End1), _), contains((Start1, End1), (Start2, End2)).

:- not rep3(_, N, P, E, (Start, End)), event(_, N, P, E, (Start, End), 3), not inconsistent_if_added(N, P, E, (Start, End)).