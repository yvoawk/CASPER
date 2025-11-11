#program step(0).
step_time(0, 0).
obs(has_icd10_diag, bench_patient, c340, 0).

#program step(604800).
step_time(604800, 604800).
obs(has_adm, bench_patient, erlotinib, 604800).

#program step(1209600).
step_time(1209600, 1209600).
obs(has_icd10_diag, bench_patient, c348, 1209600).
