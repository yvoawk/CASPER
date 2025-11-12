% ==============================================================================
% CASPER version v1.0.1
% Author: Yvon K. Awuklu
% Description: Preference encoding for clinical event detection
% See Theorem 3 in the paper for details
% ==============================================================================

#program check(t).
#external use_preference(t).

#maximize { 1@3, ID : use_preference(t), rep_event(ID, N, P, E, (T1, T2), 1) }.
#maximize { 1@2, ID : use_preference(t), rep_event(ID, N, P, E, (T1, T2), 2) }.
#maximize { 1@1, ID : use_preference(t), rep_event(ID, N, P, E, (T1, T2), 3) }.
