-- Ma chi phi

drop table bh_bt_gd_hs_chi;
create table bh_bt_gd_hs_chi
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob);
CREATE unique INDEX bh_bt_gd_hs_chi_u1 on bh_bt_gd_hs_chi(ma);

drop TABLE bh_bt_gd_hs;
CREATE TABLE bh_bt_gd_hs
 (ma_dvi varchar2(10),
 so_id number,
 ngay_ht number,
 nv varchar2(10),
 so_hs varchar2(50),
 ttrang varchar2(1),
 so_hs_bt varchar2(20),
 so_id_bt number,
 ma_dvi_hd varchar2(10),
 so_id_hd number,
 so_id_dt number,
 phong varchar2(10),
 ten nvarchar2(500),
 nd nvarchar2(200),
 ngay_qd number,
 pt_that number,
 that number,
 k_ma_gd varchar2(1),
 ma_gd varchar2(20),
 ma_chi varchar2(10),
 ma_nt varchar2(5),
 t_suat number,
 tien number,
 thue number,
 ttoan number,
 tien_qd number,
 thue_qd number,
 ttoan_qd number,
 nsd varchar2(10),
 so_id_kt number,
 ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_gd_hs_u on bh_bt_gd_hs(ma_dvi,so_id) local;
CREATE INDEX bh_bt_gd_hs_i1 on bh_bt_gd_hs(ngay_ht) local;
CREATE INDEX bh_bt_gd_hs_i2 on bh_bt_gd_hs(so_id_bt) local;
CREATE INDEX bh_bt_gd_hs_i3 on bh_bt_gd_hs(so_hs);

drop TABLE bh_bt_gd_hs_txt;
CREATE TABLE bh_bt_gd_hs_txt
 (ma_dvi varchar2(10),
 so_id number,
 loai varchar2(10),
 txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_txt_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_gd_hs_txt_i1 on bh_bt_gd_hs_txt(so_id) local;

drop table bh_bt_gd_hs_pt;
create table bh_bt_gd_hs_pt
 (ma_dvi varchar2(10),
 so_id number,
 so_id_bt number,
 ma_dvi_hd varchar2(10),
 so_id_hd number,
 so_id_dt number,
 ngay_qd number,
 lh_nv varchar2(20),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 thue number,
 thue_qd number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_pt_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_pt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_gd_hs_pt_i1 on bh_bt_gd_hs_pt(so_id) local;
CREATE INDEX bh_bt_gd_hs_pt_i2 on bh_bt_gd_hs_pt(ngay_qd) local;

drop table bh_bt_gd_pb;
create table bh_bt_gd_pb
(
  ma_dvi    varchar2(10 byte),
  so_id     number,
  bt        number,
  ngay_ht   number,
  dvi_xl    varchar2(10 byte),
  phong     varchar2(10 byte),
  so_id_hd  number,
  lh_nv     varchar2(10 byte),
  ma_nt     varchar2(5 byte),
  tien      number,
  tien_qd   number,
  so_id_kt  number
);
create unique index bh_bt_gd_pb_u0 on bh_bt_gd_pb(ma_dvi, so_id, bt);
create index bh_bt_gd_pb_i1 on bh_bt_gd_pb (ma_dvi, ngay_ht);
create index bh_bt_gd_pb_i2 on bh_bt_gd_pb (dvi_xl, ngay_ht);
create index bh_bt_gd_pb_i3 on bh_bt_gd_pb (dvi_xl, so_id);
create index bh_bt_gd_pb_i4 on bh_bt_gd_pb (ma_dvi, so_id_kt);

drop table bh_bt_gd_pb_temp;
create GLOBAL TEMPORARY table bh_bt_gd_pb_temp
    (dvi_xl varchar2(10),
    phong varchar2(10),
    lh_nv varchar2(10),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    so_id_kt number)
    ON COMMIT PRESERVE ROWS;

drop table bh_bt_gd_hs_sc;
create table bh_bt_gd_hs_sc
    (ma_dvi varchar2(10),
    so_id number,
    ma_nt varchar2(5),
    thu number,
    thu_qd number,
    chi number,
    chi_qd number,
    ton number,
    ton_qd number,
    ngay_ht number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_sc_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_sc_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_gd_hs_sc_u on bh_bt_gd_hs_sc(ma_dvi,so_id,ngay_ht) local;

-- THANH TOAN GIAM DINH

drop TABLE bh_bt_gd_hs_tt;
CREATE TABLE bh_bt_gd_hs_tt
    (ma_dvi varchar2(10),
    so_id_tt number,
    ngay_ht number,
    so_hs varchar2(30),
    k_ma_gd varchar2(1),
    ma_gd varchar2(20),
    phong varchar2(10),
    so_ct varchar2(20),
    ma_nt varchar2(5),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
    ttoan_qd number,
    nt_tra varchar2(5),
    tygia number,
    tra number,
    tra_qd number,
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_tt_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_tt_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_gd_hs_tt_u on bh_bt_gd_hs_tt(ma_dvi,so_id_tt) local;
CREATE INDEX bh_bt_gd_hs_tt_i1 on bh_bt_gd_hs_tt(ngay_ht) local;
CREATE INDEX bh_bt_gd_hs_tt_i2 on bh_bt_gd_hs_tt(so_id_kt) local;

drop table bh_bt_gd_hs_tt_ps;
CREATE TABLE bh_bt_gd_hs_tt_ps
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id number,
    ma_nt varchar2(5),
    tien number,
    tien_qd number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_tt_ps_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_tt_ps_DEFA values (DEFAULT));
CREATE INDEX bh_bt_gd_hs_tt_ps_i1 on bh_bt_gd_hs_tt_ps(so_id_tt) local;

drop TABLE bh_bt_gd_hs_tt_txt;
CREATE TABLE bh_bt_gd_hs_tt_txt
 (ma_dvi varchar2(10),
 so_id number,
 loai varchar2(10),
 txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_tt_txt_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_tt_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_gd_hs_tt_txt_i1 on bh_bt_gd_hs_tt_txt(so_id) local;

drop TABLE bh_bt_gd_hs_tu;
CREATE TABLE bh_bt_gd_hs_tu
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    l_ct varchar2(1),
    phong varchar2(10),
    so_hs varchar2(30),
    so_id_hs number,
    k_ma_gd varchar2(1),
    ma_gd varchar2(20),
    so_ct varchar2(20),
    ma_nt varchar2(5),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
    ttoan_qd number,
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_tu_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_tu_DEFA values (DEFAULT));
create unique index bh_bt_gd_hs_tu_u on bh_bt_gd_hs_tu (ma_dvi,so_id) local;
create index bh_bt_gd_hs_tu_i1 on bh_bt_gd_hs_tu (ma_dvi,ngay_ht) local;
create index bh_bt_gd_hs_tu_i2 on bh_bt_gd_hs_tu (ma_dvi,so_id_hs) local;
create index bh_bt_gd_hs_tu_i3 on bh_bt_gd_hs_tu (ma_dvi,so_hs) local;
create index bh_bt_gd_hs_tu_i4 on bh_bt_gd_hs_tu (ma_dvi,so_id_kt) local;

drop table bh_bt_gd_hs_tu_pt;
create table bh_bt_gd_hs_tu_pt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_bt number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    lh_nv varchar2(20),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_tu_pt_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_tu_pt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_gd_hs_tu_pt_i1 on bh_bt_gd_hs_tu_pt(so_id) local;
CREATE INDEX bh_bt_gd_hs_tu_pt_i2 on bh_bt_gd_hs_tu_pt(ngay_ht) local;

drop table bh_bt_gd_hs_tu_txt;
create table bh_bt_gd_hs_tu_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_gd_hs_tu_txt_0800 values ('0800'),
    PARTITION bh_bt_gd_hs_tu_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_gd_hs_tu_txt_i1 on bh_bt_gd_hs_tu_txt(so_id,loai) local;

drop table bh_bt_gd_sc;
create table bh_bt_gd_sc
(
  ma_dvi  varchar2(10),
  so_id   number,
  ma_nt   varchar2(5),
  thu     number,
  thu_qd  number,
  chi     number,
  chi_qd  number,
  ton     number,
  ton_qd  number,
  ngay_ht number

);
create unique index bh_bt_gd_sc_u0 on bh_bt_gd_sc(ma_dvi, so_id, ma_nt, ngay_ht);

drop table bh_bt_gd_tt;
create table bh_bt_gd_tt
(
  ma_dvi   varchar2(10),
  so_id_tt number,
  ngay_ht  number,
  k_ma_gd  varchar2(1),
  ma_gd    varchar2(20),
  phong    varchar2(10),
  so_ct    varchar2(20),
  nsd      varchar2(10),
  ngay_nh  date,
  so_id_kt number

);
create unique index bh_bt_gd_tt_u0 on bh_bt_gd_tt(ma_dvi, so_id_tt);
create index bh_bt_gd_tt_i1 on bh_bt_gd_tt (ma_dvi, ngay_ht);
create index bh_bt_gd_tt_i2 on bh_bt_gd_tt (ma_dvi, so_id_kt);

drop table bh_bt_gd_ho;
create table bh_bt_gd_ho
(
  ma_dvi varchar2(10),
  so_id  number,
  dvi_xl varchar2(10),
  k_thue varchar2(1),
  nsd    varchar2(10)

);
create unique index bh_bt_gd_ho_u0 on bh_bt_gd_ho(ma_dvi, dvi_xl, so_id);

drop table bh_bt_gd_tu;
create table bh_bt_gd_tu
(
  ma_dvi   varchar2(10),
  so_id    number,
  ngay_ht  number,
  l_ct     varchar2(1),
  phong    varchar2(10),
  so_id_hs varchar2(30),
  so_ct    varchar2(20),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  nd       nvarchar2(200),
  nsd      varchar2(10),
  ngay_nh  date,
  so_id_kt number

);
create unique index bh_bt_gd_tu_u0 on bh_bt_gd_tu(ma_dvi, so_id);
create index bh_bt_gd_tu_i1 on bh_bt_gd_tu (ma_dvi, ngay_ht);
create index bh_bt_gd_tu_i2 on bh_bt_gd_tu (ma_dvi, so_id_hs);
create index bh_bt_gd_tu_i3 on bh_bt_gd_tu (ma_dvi, so_id_kt);

drop table bh_bt_gd_hsl;
create table bh_bt_gd_hsl
(
  ma_dvi    varchar2(10),
  so_id     number,
  so_hs     varchar2(20),
  ma_dvi_ql varchar2(10),
  so_hd     varchar2(50),
  tien      number,
  gio       varchar2(20),
  ngay      varchar2(20)
)
partition by list (ma_dvi)
(
  partition bh_bt_gd_hsl_001 values ('001'),
  partition bh_bt_gd_hsl_050 values ('050', '052'),
  partition bh_bt_gd_hsl_defa values (default)
);
create index bh_bt_gd_hsl_i1 on bh_bt_gd_hsl (so_id, ngay);