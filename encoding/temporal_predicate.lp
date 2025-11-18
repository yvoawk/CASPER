% ==============================================================================
% CASPER version v1.0.1
% Author: Yvon K. Awuklu
% Description: temporal predicates encoding
% ==============================================================================

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% intersection of two intervals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

intersection_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    Start1 < End1;
    Start2 < End2;
    NewStart = #max{V : valid_time(V), V = Start1; V : valid_time(V), V = Start2},  % Start of the intersection
    NewEnd = #min{V : valid_time(V), V = End1; V : valid_time(V), V = End2}; % End of the intersection
    NewStart <= NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2);
    End1 = Start2.

intersection_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    Start1 < End1;
    Start2 < End2;
    NewStart = #max{V : valid_time(V), V = Start1; V : valid_time(V), V = Start2},  % Start of the intersection
    NewEnd = #min{V : valid_time(V), V = End1; V : valid_time(V), V = End2}; % End of the intersection
    NewStart <= NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2);
    % Intervals overlap
    End1 > Start2;
    End1 < End2;
    Start1 < Start2.

intersection_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    Start1 < End1;
    Start2 < End2;
    NewStart = #max{V : valid_time(V), V = Start1; V : valid_time(V), V = Start2},  % Start of the intersection
    NewEnd = #min{V : valid_time(V), V = End1; V : valid_time(V), V = End2}; % End of the intersection
    NewStart <= NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2);
    % Intervals contain each other
    Start1 < Start2;
    End1 > End2.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% union of two intervals %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% Case 1: The intervals overlap or are adjacent, so the union is a single interval
union_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    Start1 < End1;
    Start2 < End2;
    NewStart = #min{V : valid_time(V), V = Start1; V : valid_time(V), V = Start2};  % Start of the union
    NewEnd = #max{V : valid_time(V), V = End1; V : valid_time(V), V = End2};  % End of the union
    NewStart < NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2);
    End1 = Start2. % Intervals are adjacent

union_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    Start1 < End1;
    Start2 < End2;
    NewStart = #min{V : valid_time(V), V = Start1; V : valid_time(V), V = Start2};  % Start of the union
    NewEnd = #max{V : valid_time(V), V = End1; V : valid_time(V), V = End2};  % End of the union
    NewStart < NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2);
    % Intervals overlap
    End1 > Start2;
    End1 < End2;
    Start1 < Start2.

union_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    Start1 < End1;
    Start2 < End2;
    NewStart = #min{V : valid_time(V), V = Start1; V : valid_time(V), V = Start2};  % Start of the union
    NewEnd = #max{V : valid_time(V), V = End1; V : valid_time(V), V = End2};  % End of the union
    NewStart < NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2);
    % Intervals contain each other
    Start1 < Start2;
    End1 > End2.

% Case 2: The intervals are disjoint, so the union is both intervals
union_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    End1 < Start2; % Intervals are disjoint
    NewStart = Start1;
    NewEnd = End1;
    NewStart < NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2).

union_of((Start1, End1), (Start2, End2), (NewStart, NewEnd)) :-
    End1 < Start2; % Intervals are disjoint
    NewStart = Start2;
    NewEnd = End2;
    NewStart < NewEnd;
    e_interval(Start1, End1); e_interval(Start2, End2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Allen's interval algebra %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% The intervals are equal
equals((Start1, End1), (Start2, End2)) :-
    Start1 = Start2;
    End1 = End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is before the second interval
before((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start2 > End1;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is after the second interval
after((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 > End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is during the second interval
during((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 > Start2;
    End1 < End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval contains the second interval
contains((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 < Start2;
    End1 > End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval overlaps the second interval
overlaps((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 < Start2;
    End1 > Start2;
    End1 < End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is overlapped by the second interval
overlapped_by((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 > Start2;
    Start1 < End2;
    End1 > End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval starts the second interval
starts((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 = Start2;
    End1 < End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is started by the second interval
started_by((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 = Start2;
    End1 > End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval finishes the second interval
finishes((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 > Start2;
    End1 = End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is finished by the second interval
finished_by((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 < Start2;
    End1 = End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval meets the second interval
meets((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    End1 = Start2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% The first interval is met by the second interval
met_by((Start1, End1), (Start2, End2)) :-
    Start1 < End1;
    Start2 < End2;
    Start1 = End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% Vilian's point-interval algebra %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% point before interval
p_before((Start1, End1), (Start2, End2)) :-
    Start1 = End1;
    Start2 < End2;
    Start1 < Start2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% point after interval
p_after((Start1, End1), (Start2, End2)) :-
    Start1 = End1;
    Start2 < End2;
    Start1 > End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% point during interval
p_during((Start1, End1), (Start2, End2)) :-
    Start1 = End1;
    Start2 < End2;
    Start2 < Start1 < End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% point starts interval
p_starts((Start1, End1), (Start2, End2)) :-
    Start1 = End1;
    Start2 < End2;
    Start1 = Start2;
    e_interval(Start1, End1); e_interval(Start2, End2).

% point finishes interval    
p_finishes((Start1, End1), (Start2, End2)) :-
    Start1 = End1;
    Start2 < End2;
    Start1 = End2;
    e_interval(Start1, End1); e_interval(Start2, End2).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% helper predicates %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

start(N, P, T, L) :- event(_, N, P, _, (T, _), L); T = #min{ Tx : event(_, N, P, _, (Tx, _), _) }.
end(N, P, T, L) :- event(_, N, P, _, (_, T), L); T = #max{ Tx : event(_, N, P, _, (_, Tx), _) }.

persist_end(P, T) :- terminates(P, T, _).
