drop table bh_kh_hoi_temp1;
create GLOBAL TEMPORARY table bh_kh_hoi_temp1(
 ma varchar2(30),
 ten nvarchar2(500));

drop table bh_kh_hoi_temp;
create GLOBAL TEMPORARY table bh_kh_hoi_temp(
 ma varchar2(30),
 ten nvarchar2(1000),
 bt number);

drop table bh_kh_ttt;
CREATE TABLE bh_kh_ttt
 (ma_dvi varchar2(10),
 ps varchar2(10),
 nv varchar2(10),
 ma varchar2(20),
 ten nvarchar2(400),
 loai varchar2(1),
 bb varchar2(1),
 ktra varchar2(100),
 bt number,
 nsd varchar2(10)
);
create unique index bh_kh_ttt_u0 on bh_kh_ttt(ps,nv,ma);

drop table kh_cay;
create global temporary table kh_cay
 (ma   varchar2(20),
 ten  nvarchar2(200),
 loai varchar2(1),
 tso  nvarchar2(1000));