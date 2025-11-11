#program base.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Temporal event rules for inferring some lung cancer related simple events (Section 2.2 of the paper) %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% expansion window (equivalent optimization: keep static in base to avoid re-grounding)
pt_window(primary_lungC_episode, c34, 345600).

#program step(t).
#external use_simple_events(t).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Equivalent optimizations: scope dynamic rules to the active step to shrink grounding space            %%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% primary lung cancer episode
exists(primary_lungC_episode, P, c34, T, 1) :-
    use_simple_events(t),
    obs(has_lungc_adicap_diag, P, E, T),
    patient(P),
    time_scope(t, T).

exists(primary_lungC_episode, P, c34, T, 2) :-
    use_simple_events(t),
    obs(has_icd10_diag, P, E, T),
    patient(P),
    time_scope(t, T),
    primary_lungC(E),
    E != c349,
    E != c348.

exists(primary_lungC_episode, P, c34, T, 3) :-
    use_simple_events(t),
    obs(has_icd10_diag, P, c349, T),
    patient(P),
    time_scope(t, T).

exists(primary_lungC_episode, P, c34, T, 3) :-
    use_simple_events(t),
    obs(has_icd10_diag, P, c348, T),
    patient(P),
    time_scope(t, T).

% secondary cancer episode
exists_pers(secondary_cancer_episode, P, E, T, 2) :-
    use_simple_events(t),
    obs(has_icd10_diag, P, E, T),
    patient(P),
    time_scope(t, T),
    secondary_cancer(E).

% TKI targeted therapy
exists_pers(tki_target_therapy, P, D, T, 1) :-
    use_simple_events(t),
    obs(has_adm, P, D, T),
    patient(P),
    time_scope(t, T),
    tki(D).

terminates(tki_target_therapy, P, D, T, 1) :-
    use_simple_events(t),
    obs(has_adm, P, D1, T),
    patient(P),
    time_scope(t, T),
    tki(D),
    tki(D1),
    D != D1.

% egfr mutation
exists_pers(egfr_mutation, P, egfr, T, 1) :-
    use_simple_events(t),
    obs(has_egfr_mut, P, E, T),
    patient(P),
    time_scope(t, T).

terminates(egfr_mutation, P, egfr, T, 1) :-
    use_simple_events(t),
    obs(has_no_egfr_mut, P, E, T),
    patient(P),
    time_scope(t, T).

% alk mutation
exists_pers(alk_mutation, P, alk, T, 1) :-
    use_simple_events(t),
    obs(has_alk_mut, P, E, T),
    patient(P),
    time_domain(T).

terminates(alk_mutation, P, alk, T, 1) :-
    use_simple_events(t),
    obs(has_no_alk_mut, P, E, T),
    patient(P),
    time_domain(T).

