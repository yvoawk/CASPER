% lung cancer disease definition
m_event(lung_cancer_disease, P, (T1, T2), L) :- start(primary_lungC_episode, P, T1, L); not event(_, secondary_cancer_episode, P, _,(Tx, _), _) : Tx < T1, valid_time(Tx); persist_end(P, T2).

m_event(lung_cancer_disease, P, (T1, T2), L) :- start(secondary_cancer_episode, P, T1, L); not event(_, primary_lungC_episode, P, _,(Tx, _), _) : Tx < T1, valid_time(Tx); persist_end(P, T2).