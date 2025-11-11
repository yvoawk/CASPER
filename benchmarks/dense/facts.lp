#program step(0).
step_time(0, 0).
obs(has_lungc_adicap_diag, bench_patient, rba7v4, 0).
obs(has_adm, bench_patient, erlotinib, 0).

#program step(86400).
step_time(86400, 86400).
obs(has_icd10_diag, bench_patient, c349, 86400).
obs(has_adm, bench_patient, erlotinib, 86400).
obs(has_adm, bench_patient, osimertinib, 86400).

#program step(172800).
step_time(172800, 172800).
obs(has_icd10_diag, bench_patient, c348, 172800).
obs(has_no_egfr_mut, bench_patient, egfr_moins, 172800).

#program step(259200).
step_time(259200, 259200).
obs(has_adm, bench_patient, erlotinib, 259200).
obs(has_egfr_mut, bench_patient, egfr_plus, 259200).

#program step(345600).
step_time(345600, 345600).
obs(death, bench_patient, 345600).
