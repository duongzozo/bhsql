drop table bh_tso_ht;
create table bh_tso_ht
 (ma varchar2(10),
 ten nvarchar2(500),
 loai varchar2(10)   -- Loai: J-Job
);
create unique index bh_tso_ht_u0 on bh_tso_ht(ma);

drop table bh_tso_ht_job;
create table bh_tso_ht_job
 (ma varchar2(10),
 ten nvarchar2(500),
 tgian number
);
create unique index bh_tso_ht_job_u0 on bh_tso_ht_job(ma);