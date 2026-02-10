% ==============================================================================
% CASPER version v1.1.0
% Author: Yvon K. Awuklu
% Description: Preference encoding for clinical event detection
% See Theorem 5 in the paper for details
% ==============================================================================

% Prioritizes higher confidence levels
has_event :- event(_, _, _, _, _, _).
max_conf_level(Max) :- has_event, Max = #max{ L : event(_, _, _, _, _, L) }.
#maximize{ 1@(Max-L+1), ID : rep_event(ID, N, P, E, (T1, T2), L), max_conf_level(Max) }.
