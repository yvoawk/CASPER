%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Temporal event rules for inferring some lung cancer related simple events (Section 2.2 of the paper) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% primary lung cancer episode
exists(primary_lungC_episode, P, c34, T, 1) :- obs(has_lungc_adicap_diag, P, E, T).
exists(primary_lungC_episode, P, c34, T, 2) :- obs(has_icd10_diag, P, E, T); E != c349; E != c348; primary_lungC(E).
exists(primary_lungC_episode, P, c34, T, 3) :- obs(has_icd10_diag, P, c349, T).
exists(primary_lungC_episode, P, c34, T, 3) :- obs(has_icd10_diag, P, c348, T).

% secondary cancer episode
exists_pers(secondary_cancer_episode, P, E, T, 2) :- obs(has_icd10_diag, P, E, T); secondary_cancer(E).

% TKI targeted therapy
exists_pers(tki_target_therapy, P, D, T, 1) :- obs(has_adm, P, D, T); tki(D).
terminates(tki_target_therapy, P, D, T, 1) :- obs(has_adm, P, D1, T); obs(has_adm, P, D, T1); tki(D1); tki(D); D != D1; T1 < T.

% egfr mutation
exists_pers(egfr_mutation, P, egfr, T, 1) :- obs(has_egfr_mut, P, E, T).
terminates(egfr_mutation, P, egfr, T, 1) :- obs(has_no_egfr_mut, P, E, T).

% alk mutation
exists_pers(alk_mutation, P, alk, T, 1) :- obs(has_alk_mut, P, E, T).
terminates(alk_mutation, P, alk, T, 1) :- obs(has_no_alk_mut, P, E, T).

% expansion window
pt_window(primary_lungC_episode, c34, 345600).

