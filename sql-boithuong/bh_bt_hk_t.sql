-- NGUOI HUONG KHAC --

drop table bh_bt_hk_sc;
create table bh_bt_hk_sc
    (ma_dvi varchar2(10),
    so_id number,
    ma varchar2(20),
    ma_nt varchar2(5),
    thu number,
    thu_qd number,
    chi number,
    chi_qd number,
    ton number,
    ton_qd number,
    ngay_ht number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_hk_sc_0800 values ('0800'),
    PARTITION bh_bt_hk_sc_0885 values ('0885'),
    PARTITION bh_bt_hk_sc_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_hk_sc_u1 on bh_bt_hk_sc(ma_dvi,so_id,ma,ma_nt,ngay_ht) local;

drop TABLE bh_bt_hk_ps;
CREATE TABLE bh_bt_hk_ps
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
 ma varchar2(20),
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
 ttoan_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hk_ps_0800 values ('0800'),
        PARTITION bh_bt_hk_ps_0885 values ('0885'),
        PARTITION bh_bt_hk_ps_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hk_ps_i1 on bh_bt_hk_ps(so_id) local;

drop table bh_bt_hk;
CREATE TABLE bh_bt_hk
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    so_hs varchar2(30),
    so_id_hs number,
    so_pa varchar2(20),
    so_id_pa number,
    l_ct varchar2(1),
    so_ct varchar2(20),
    ten nvarchar2(500),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number,
    ttoan number,
    ttoan_qd number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    phong varchar2(10),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_hk_0800 values ('0800'),
    PARTITION bh_bt_hk_0885 values ('0885'),
    PARTITION bh_bt_hk_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_hk_u1 on bh_bt_hk_sc(ma_dvi,so_id) local;
create index bh_bt_hk_i1 on bh_bt_hk(ngay_ht) local;
CREATE INDEX bh_bt_hk_i2 on bh_bt_hk(so_id_kt) local;
create index bh_bt_hk_i3 on bh_bt_hk(so_id_hs) local;
create index bh_bt_hk_i4 on bh_bt_hk(so_id_pa) local;

drop table bh_bt_hk_ct;
CREATE TABLE bh_bt_hk_ct
    (ma_dvi varchar2(10),
    so_id number,
    ma varchar2(20),
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number,
    tien_qd number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_hk_ct_0800 values ('0800'),
    PARTITION bh_bt_hk_ct_0885 values ('0885'),
    PARTITION bh_bt_hk_ct_DEFA values (DEFAULT));
create index bh_bt_hk_ct_i1 on bh_bt_hk_ct(so_id) local;

drop table bh_bt_hk_txt;
CREATE TABLE bh_bt_hk_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_hk_txt_0800 values ('0800'),
    PARTITION bh_bt_hk_txt_0885 values ('0885'),
    PARTITION bh_bt_hk_txt_DEFA values (DEFAULT));
create index bh_bt_hk_txt_i1 on bh_bt_hk_txt(so_id) local;

drop table bh_bt_hk_ton_temp;
create GLOBAL TEMPORARY table bh_bt_hk_ton_temp
    (ma varchar2(20),
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number)
    ON COMMIT PRESERVE ROWS;

drop table bh_bt_hk_tu;
create table bh_bt_hk_tu
  (ma_dvi   varchar2(10),
  so_id    number,
  ngay_ht  number,
  so_hs    varchar2(20),
  so_id_hs number,
  ma_hk    varchar2(20),
  ten_hk   nvarchar2(500),
  l_ct     varchar2(1),
  so_ct    varchar2(20),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  ma_kh    varchar2(20),
  ten      nvarchar2(500),
  phong    varchar2(10),
  nsd      varchar2(10),
  ngay_nh  date,
  so_id_kt number
);
create unique index bh_bt_hk_tu_u0 on bh_bt_hk_tu(ma_dvi, so_id);
create index bh_bt_hk_tu_i1 on bh_bt_hk_tu (ma_dvi, ngay_ht);
create index bh_bt_hk_tu_i2 on bh_bt_hk_tu (ma_dvi, so_id_hs);
create index bh_bt_hk_tu_i3 on bh_bt_hk_tu (ma_dvi, so_id_kt);