-- NGUOI THU BA --

drop table bh_bt_tba_sc;
create table bh_bt_tba_sc
 (ma_dvi varchar2(10),
 so_id number,
 ten nvarchar2(500),
 ma_nt varchar2(5),
 thu number,
 chi number,
 ton number,
 ngay_ht number
);
create unique index bh_bt_tba_sc_u0 on bh_bt_tba_sc(ma_dvi,so_id,ten,ma_nt,ngay_ht);

-- Phat sinh khi tao ho so

drop TABLE bh_bt_tba_ps;
CREATE TABLE bh_bt_tba_ps
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tba_ps_0800 values ('0800'),
        PARTITION bh_bt_tba_ps_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tba_ps_i1 on bh_bt_tba_ps(so_id) local;

drop table bh_bt_tba_ps_pt;
create table bh_bt_tba_ps_pt
 (ma_dvi varchar2(10),
 so_id number,
 ten nvarchar2(500),
 ma_nt varchar2(5),
 lh_nv varchar2(10),
 tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tba_ps_pt_0800 values ('0800'),
        PARTITION bh_bt_tba_ps_pt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tba_ps_pt_i1 on bh_bt_tba_ps_pt(so_id) local;

-- Thanh toan

drop table bh_bt_tba;
CREATE TABLE bh_bt_tba
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    so_hs varchar2(30),
    so_id_bt number,
    ma_dvi_ql varchar2(10),
    ma_dvi_xl varchar2(10),
    so_id_hd number,
    so_id_dt number,
    so_ct varchar2(20),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
    ttoan_qd number,
    t_suat number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,    
    ma_thue varchar2(30),
    ten_tba nvarchar2(500),
    dchi nvarchar2(500),
    mau varchar2(20),
    seri varchar2(20),
    so_don varchar2(20),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    phong varchar2(10),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tba_0800 values ('0800'),
        PARTITION bh_bt_tba_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_tba_i0 on bh_bt_tba(ma_dvi,so_id) local;
CREATE INDEX bh_bt_tba_i1 on bh_bt_tba(ngay_ht) local;
CREATE INDEX bh_bt_tba_i2 on bh_bt_tba(so_id_kt) local;
create index bh_bt_tba_i3 on bh_bt_tba(so_id_bt) local;
create index bh_bt_tba_i4 on bh_bt_tba(ma_dvi_ql,so_id_hd);

drop table bh_bt_tba_ct;
CREATE TABLE bh_bt_tba_ct
    (ma_dvi varchar2(10),
    so_id number,
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number,
    tien_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tba_ct_0800 values ('0800'),
        PARTITION bh_bt_tba_ct_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tba_ct_i1 on bh_bt_tba_ct(ma_dvi,so_id,ten,ma_nt);

drop table bh_bt_tba_pt;
create table bh_bt_tba_pt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_bt number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    ten nvarchar2(500),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    tien number,
    tien_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tba_pt_0800 values ('0800'),
        PARTITION bh_bt_tba_pt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tba_pt_i1 on bh_bt_tba_pt(so_id) local;
CREATE INDEX bh_bt_tba_pt_i2 on bh_bt_tba_pt(so_id_bt) local;

drop table bh_bt_tba_txt;
CREATE TABLE bh_bt_tba_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tba_txt_0800 values ('0800'),
        PARTITION bh_bt_tba_txt_DEFA values (DEFAULT));
create index bh_bt_tba_txt_i1 on bh_bt_tba_txt(so_id) local;

drop table bh_bt_ntba_tt;
create table bh_bt_ntba_tt
(
  ma_dvi   varchar2(10) not null,
  so_id    number not null,
  ngay_ht  number,
  phong    varchar2(10),
  so_id_hs varchar2(30),
  so_ct    varchar2(30),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  thue     number,
  thue_qd  number,
  ttoan    number,
  ttoan_qd number,
  loai     varchar2(1),
  pp       varchar2(1),
  t_suat   number,
  ma_thue  varchar2(30),
  ten      nvarchar2(500),
  dchi     nvarchar2(500),
  mau      varchar2(20),
  seri     varchar2(20),
  so_don   varchar2(20),
  nd       nvarchar2(500),
  nsd      varchar2(10),
  ngay_nh  date,
  so_id_kt number

);
create unique index bh_bt_ntba_tt_u0 on bh_bt_ntba_tt(ma_dvi, so_id);
create index bh_bt_ntba_tt_i1 on bh_bt_ntba_tt (ma_dvi, ngay_ht);
create index bh_bt_ntba_tt_i2 on bh_bt_ntba_tt (ma_dvi, so_id_kt);

drop table bh_bt_ntba_tt_pt;
create table bh_bt_ntba_tt_pt
(
  ma_dvi   varchar2(10),
  so_id    number,
  so_id_bt number,
  so_id_hd number,
  so_id_dt number,
  ngay_ht  number,
  lh_nv    varchar2(10),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  thue     number,
  thue_qd  number,
  bt       number

);
create unique index bh_bt_ntba_tt_pt_u0 on bh_bt_ntba_tt_pt(ma_dvi, so_id, bt);

drop table bh_bt_ng_tba;
create table bh_bt_ng_tba
 (ma_dvi varchar2(10),
    so_id  number,
    bt     number,
    ten    nvarchar2(500),
    ma_nt  varchar2(5),
    tien   number)
 partition by list (ma_dvi)(
   partition bh_bt_ng_tba_0800 values ('0800'),
   partition bh_bt_ng_tba_defa values (default));
create index bh_bt_ng_tba_i1 on bh_bt_ng_tba (so_id);

--chuclh: ktoan dung

drop table bh_bt_ntba_pb;
create table bh_bt_ntba_pb
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
create unique index bh_bt_ntba_pb_u0 on bh_bt_ntba_pb(ma_dvi, so_id, bt);
create index bh_bt_ntba_pb_i1 on bh_bt_ntba_pb (ma_dvi, ngay_ht);
create index bh_bt_ntba_pb_i2 on bh_bt_ntba_pb (dvi_xl, ngay_ht);
create index bh_bt_ntba_pb_i3 on bh_bt_ntba_pb (dvi_xl, so_id);
create index bh_bt_ntba_pb_i4 on bh_bt_ntba_pb (ma_dvi, so_id_kt);