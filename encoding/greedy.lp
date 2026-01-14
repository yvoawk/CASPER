% ==============================================================================
% CASPER version v1.0.2
% Author: Yvon K. Awuklu
% Description: temporal repair encoding
% See Section 2.2 & Section 2.3 (Definitions 6, 7, 8) in the paper for details
% ==============================================================================

rep1(ID,N,P,E,(S,Ee)) :- event(ID,N,P,E,(S,Ee),1).
{ rep2(ID,N,P,E,(S,Ee)) } :- event(ID,N,P,E,(S,Ee),2).
%{ rep3(ID,N,P,E,(S,Ee)) } :- event(ID,N,P,E,(S,Ee),3).

% an event should not be contains by another event of the same type
:- rep1(_, N, P, E, (Start1, End1)), rep2(_, N, P, E, (Start2, End2)), contains((Start1, End1), (Start2, End2)).
:- rep2(_, N, P, E, (Start1, End1)), rep1(_, N, P, E, (Start2, End2)), contains((Start1, End1), (Start2, End2)).
:- rep1(_, N, P, E, (Start1, End1)), rep3(_, N, P, E, (Start2, End2)), contains((Start1, End1), (Start2, End2)).
:- rep3(_, N, P, E, (Start1, End1)), rep1(_, N, P, E, (Start2, End2)), contains((Start1, End1), (Start2, End2)).
:- rep2(_, N, P, E, (Start1, End1)), rep3(_, N, P, E, (Start2, End2)), contains((Start1, End1), (Start2, End2)).
:- rep3(_, N, P, E, (Start1, End1)), rep2(_, N, P, E, (Start2, End2)), contains((Start1, End1), (Start2, End2)).

% ensure maximality: for every element not in the set, adding it would cause a conflict
%inconsistent_if_added(N, P, E, (Start2, End2)) :- rep2(_, N, P, E, (Start1, End1)), contains((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start1, End1)) :- event(_, N, P, E, (Start1, End1),_), contains((Start1, End1), (Start2, End2)).
inconsistent_if_added(N, P, E, (Start2, End2)) :- event(_, N, P, E, (Start1, End1),_), contains((Start1, End1), (Start2, End2)).


safe_to_add2(N,P,E,(S,Ee)) :-
    event(_,N,P,E,(S,Ee),2),
    not inconsistent_if_added(N,P,E,(S,Ee)).

:- not rep2(_, N, P, E, (Start, End)), event(_, N, P, E, (Start, End), 2), safe_to_add2(N,P,E,(Start,End)).




rep_event(ID,N,P,E,(S,Ee),L) :- rep1(ID,N,P,E,(S,Ee)), L=1.
rep_event(ID,N,P,E,(S,Ee),L) :- rep2(ID,N,P,E,(S,Ee)), L=2.
%rep_event(ID,N,P,E,(S,Ee),L) :- rep3(ID,N,P,E,(S,Ee)), L=3.

%#show contains/2.
%#show rep2/5.
%#show safe_to_add2/4.
%#show inconsistent_if_added/4.

