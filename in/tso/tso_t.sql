drop TABLE bh_in_gcn_tso;
CREATE TABLE bh_in_gcn_tso (
    nv        VARCHAR2(20),
    ten       VARCHAR2(200),
    duong_dan VARCHAR2(250),
    ham       VARCHAR2(50),
    ma        VARCHAR2(20) NOT NULL,
    kyso      VARCHAR2(1),
    pbh      VARCHAR2(50)

);
create unique index bh_in_gcn_tso_u0 on bh_in_gcn_tso(ma);
--- Table tso cau hinh in cho api doi tac

drop TABLE bh_in_tso;
CREATE TABLE bh_in_tso (
    nv        VARCHAR2(20),
    duong_dan VARCHAR2(250),
    ham       VARCHAR2(50),
    ma        VARCHAR2(20) NOT NULL,
    kyso      VARCHAR2(1)

);
create unique index bh_in_tso_u0 on bh_in_tso(ma);

drop table bh_in_gcn_job;
create table bh_in_gcn_job
(
  ma_dvi     varchar2(10),
  so_id      number,
  nv         varchar2(20),
  ma         varchar2(10),
  duong_dan  varchar2(250),
  nd         varchar2(500),
  ham_in     varchar2(50),
  ut         varchar2(1),
  lan        number,
  ng_tao     timestamp(6)

);
create unique index bh_in_gcn_job_u0 on bh_in_gcn_job(ma_dvi, so_id);