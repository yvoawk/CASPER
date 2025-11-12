#program check(t).
#external use_meta_events(t).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%% Meta-event rules  (Section 2.2 of the paper) %%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

% lung cancer disease definition
m_event(lung_cancer_disease, P, (T1, T2), L) :-
    use_meta_events(t),
    start(primary_lungC_episode, P, T1, L);
    not block_secondary(P, T1);
    persist_end(P, T2).

m_event(lung_cancer_disease, P, (T1, T2), L) :-
    use_meta_events(t),
    start(secondary_cancer_episode, P, T1, L);
    not block_primary(P, T1);
    persist_end(P, T2).

block_secondary(P, T1) :-
    use_meta_events(t),
    event(_, secondary_cancer_episode, P, _, (Tx, _), _);
    valid_time(Tx);
    valid_time(T1);
    Tx < T1.

block_primary(P, T1) :-
    use_meta_events(t),
    event(_, primary_lungC_episode, P, _, (Tx, _), _);
    valid_time(Tx);
    valid_time(T1);
    Tx <= T1.
