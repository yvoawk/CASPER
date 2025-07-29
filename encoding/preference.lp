% ==============================================================================
% CASPER version v1.0.0
% Author: XXXX XXXXXX
% Description: Preference encoding for clinical event detection
% ==============================================================================

% Define weights for confidence levels
weight(3, 1).
weight(2, 10).  
weight(1, 100).   

% Compute weighted sum for each event
weighted_event(ID, N, W) :- rep_event(ID, N, P, E, (T1, T2), L); weight(L, W).

% Maximize the total weight (prioritizes higher confidence levels)
#maximize{ W, ID, N : weighted_event(ID, N, W) }.