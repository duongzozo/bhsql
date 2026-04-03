drop table bh_bt_qu;
create table bh_bt_qu
 (ma_dvi varchar2(10),
 dvi varchar2(10),
 nsd varchar2(10));
CREATE unique INDEX bh_bt_qu_u1 on bh_bt_qu(ma_dvi,dvi);
CREATE INDEX bh_bt_qu_i1 on bh_bt_qu(dvi);

drop table bh_bt_ksoat;
create table bh_bt_ksoat
 (ma_dvi varchar2(10),
 dvi varchar2(10),
 so_id number,
 nsd varchar2(10));
CREATE unique INDEX bh_bt_ksoat_u1 on bh_bt_ksoat(ma_dvi,dvi,so_id);
CREATE INDEX bh_bt_ksoat_i1 on bh_bt_ksoat(dvi,so_id);

drop table bh_bt_tke_dn;
create table bh_bt_tke_dn
 (ma_dvi varchar2(10),
 ma_bh varchar2(10),
 lh_nv varchar2(10),
 bt number,
 ma_tke varchar2(20),
 ten nvarchar2(200),
 loai varchar2(1),
 do_dai number);
CREATE unique INDEX bh_bt_tke_dn_u1 on bh_bt_tke_dn(ma_dvi,ma_bh,lh_nv,bt);

-- BOI THUONG HO SO --

drop TABLE bh_bt_hs;
CREATE TABLE bh_bt_hs
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    so_hs varchar2(30),
    ttrang varchar2(1),
    kieu_hs varchar2(1),
    so_hs_g varchar2(20),
    ma_dvi_ql varchar2(10),
    ma_dvi_xl varchar2(10),
    so_id_hd number,
    so_id_dt number,
    so_hd varchar2(20),
    so_hs_bt varchar2(20),
    so_id_bt number,
    ma_khH varchar2(20),
    tenH nvarchar2(500),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    phong varchar2(10),
    skien varchar2(20),
    ngay_gui number,
    ngay_xr number,
    ngay_do number,
    n_trinh varchar2(10),
    n_duyet varchar2(10),
    ngay_qd number,
    nt_tien varchar2(5),
    noP varchar2(1),
    bphi varchar2(1),
    dung varchar2(1),
    traN varchar2(1),
    nsd varchar2(10),
    so_id_kt number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    bangG varchar2(50),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hs_0800 values ('0800'),
        PARTITION bh_bt_hs_0885 values ('0885'),
        PARTITION bh_bt_hs_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_hs_u1 on bh_bt_hs(ma_dvi,so_id) local;
CREATE unique INDEX bh_bt_hs_u2 on bh_bt_hs(ma_dvi,so_hs) local;
CREATE INDEX bh_bt_hs_i1 on bh_bt_hs(ngay_ht) local;
CREATE INDEX bh_bt_hs_i2 on bh_bt_hs(so_id_kt) local;
CREATE INDEX bh_bt_hs_i3 on bh_bt_hs(so_id_hd) local;
CREATE INDEX bh_bt_hs_i4 on bh_bt_hs(ngay_qd) local;
CREATE INDEX bh_bt_hs_i5 on bh_bt_hs(so_id_bt) local;
CREATE INDEX bh_bt_hs_i6 on bh_bt_hs(so_hs_bt) local;
CREATE INDEX bh_bt_hs_c1 on bh_bt_hs(ma_kh);
CREATE INDEX bh_bt_hs_c2 on bh_bt_hs(ma_khH);
CREATE INDEX bh_bt_hs_c3 on bh_bt_hs(skien);
CREATE INDEX bh_bt_hs_c0 on bh_bt_hs(ma_dvi_ql,so_id_hd,so_id_dt);

drop TABLE bh_bt_hs_nv;
CREATE TABLE bh_bt_hs_nv
    (ma_dvi varchar2(10),
    so_id number,
 so_id_dt number,
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    tien_bh number,
    pt_bt number,
    t_that number,
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
 ttoan_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hs_nv_0800 values ('0800'),
        PARTITION bh_bt_hs_nv_0885 values ('0885'),
        PARTITION bh_bt_hs_nv_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hs_nv_i1 on bh_bt_hs_nv(so_id) local;
CREATE INDEX bh_bt_hs_nv_i2 on bh_bt_hs_nv(so_id_dt) local;

drop TABLE bh_bt_hs_txt;
CREATE TABLE bh_bt_hs_txt
 (ma_dvi varchar2(10),
 so_id number,
 loai varchar2(10),
 txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hs_txt_0800 values ('0800'),
        PARTITION bh_bt_hs_txt_0885 values ('0885'),
        PARTITION bh_bt_hs_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hs_txt_i1 on bh_bt_hs_txt(so_id) local;

-- Du phong boi thuong

drop table bh_bt_hs_dp;
create table bh_bt_hs_dp
    (ma_dvi varchar2(10),
    so_id number,
    ttrang varchar2(1),
    ngay_dp number,
    nv varchar2(10),
    so_hs varchar2(30),
    ma_dvi_ql varchar2(10),
    so_id_hd number,
    so_id_dt number,
    so_hd varchar2(20),
    ten nvarchar2(500),
    phong varchar2(10),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    chi number,
    chi_qd number,
    con number,
    con_qd number,
    dong number,
    dong_qd number,
    tai number,
    tai_qd number,
    nsd varchar2(20), 
    dvi_ksoat varchar2(10),
    ksoat varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hs_dp_0800 values ('0800'),
        PARTITION bh_bt_hs_dp_0885 values ('0885'),
        PARTITION bh_bt_hs_dp_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hs_dp_i1 on bh_bt_hs_dp(so_id,ngay_dp) local;
CREATE INDEX bh_bt_hs_dp_i2 on bh_bt_hs_dp(ttrang,ma_dvi_ql,so_id_hd) local;

drop table bh_bt_hs_dp_ct;
create table bh_bt_hs_dp_ct
    (ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    ngay_dp number,
    lh_nv varchar2(10),
    tien number,
    tien_qd number,
    chi number,
    chi_qd number,
    con_tl number,
    con number,
    con_qd number,
    dong_tl number,
    dong number,
    dong_qd number,
    tai_tl number,
    tai number,
    tai_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hs_dp_ct_0800 values ('0800'),
        PARTITION bh_bt_hs_dp_ct_0885 values ('0885'),
        PARTITION bh_bt_hs_dp_ct_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hs_dp_ct_i1 on bh_bt_hs_dp_ct(so_id,ngay_dp) local;
CREATE INDEX bh_bt_hs_dp_ct_i2 on bh_bt_hs_dp_ct(nv,ngay_dp) local;

drop table bh_bt_hs_dp_temp;
create GLOBAL TEMPORARY table bh_bt_hs_dp_temp
 (so_id_dt number,
 lh_nv varchar2(10),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 dong number,
 dong_qd number,
 tai number,
 tai_qd number)
 ON COMMIT PRESERVE ROWS;

-- Phan bo dong BH noi bo

drop table bh_bt_hs_pb;
create table bh_bt_hs_pb
 (ma_dvi varchar2(10),
 so_id number,
 bt number,
 ngay_ht number,
 dvi_xl varchar2(10),
 phong varchar2(10),
 so_id_hd number,
 lh_nv varchar2(10),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 so_id_kt number);
CREATE unique INDEX bh_bt_hs_pb_u1 on bh_bt_hs_pb(ma_dvi,so_id,bt);
CREATE INDEX bh_bt_hs_pb_i1 on bh_bt_hs_pb(ma_dvi,ngay_ht);
CREATE INDEX bh_bt_hs_pb_i2 on bh_bt_hs_pb(dvi_xl,ngay_ht);
CREATE INDEX bh_bt_hs_pb_i3 on bh_bt_hs_pb(dvi_xl,so_id);
CREATE INDEX bh_bt_hs_pb_i4 on bh_bt_hs_pb(ma_dvi,so_id_kt);

drop table bh_bt_hs_pb_temp;
create GLOBAL TEMPORARY table bh_bt_hs_pb_temp
 (dvi_xl varchar2(10),
 phong varchar2(10),
 lh_nv varchar2(10),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 so_id_kt number)
 ON COMMIT PRESERVE ROWS;

drop table bh_bt_hs_tke;
create table bh_bt_hs_tke
 (ma_dvi varchar2(10),
 so_id number,
 lh_nv varchar2(10),
 bt number,
 ma_tke varchar2(20),
 gtri nvarchar2(200));
CREATE unique INDEX bh_bt_hs_tke_u1 on bh_bt_hs_tke(ma_dvi,so_id,lh_nv,bt);

drop table bh_bt_hs_ps;
create table bh_bt_hs_ps
 (ma_dvi varchar2(10),
 so_id number,
 ma_nt varchar2(5),
 tien number,
 tien_qd number);
CREATE unique INDEX bh_bt_hs_ps_u1 on bh_bt_hs_ps(ma_dvi,so_id,ma_nt);

drop table bh_bt_hs_sc;
create table bh_bt_hs_sc
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
        PARTITION bh_bt_hs_sc_0800 values ('0800'),
 PARTITION bh_bt_hs_sc_0885 values ('0885'),
        PARTITION bh_bt_hs_sc_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_hs_sc_u1 on bh_bt_hs_sc(ma_dvi,so_id,ma_nt,ngay_ht) local;

-- Phi phai thu tu nha lead: dong, nhan tai tam thoi

drop table bh_bt_hs_nbh;
create table bh_bt_hs_nbh
    (ma_dvi varchar2(10),
    so_id number,
    nbh varchar2(20),
    ma_nt varchar2(5),
 thu number,
 thu_qd number,
 chi number,
 chi_qd number,
 ton number,
 ton_qd number,
    ngay_ht number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hs_nbh_0800 values ('0800'),
        PARTITION bh_bt_hs_nbh_0885 values ('0885'),
        PARTITION bh_bt_hs_nbh_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hs_nbh_u on bh_bt_hs_nbh(so_id,nbh,ma_nt,ngay_ht) local;

drop table bh_bt_tu;
CREATE TABLE bh_bt_tu
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    so_hs varchar2(30),
    so_id_hs number,
    so_pa varchar2(20),
    so_id_pa number,
    ma_dvi_ql varchar2(10),
    so_id_hd number,
    so_id_dt number,
    l_ct varchar2(1),   
    so_ct varchar2(20),
    pt_tra varchar2(1),
    nbh varchar2(20),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    thue number,
    thue_qd number,
    t_suat number,
    ma_kh varchar2(20),
    ten nvarchar2(500),
    phong varchar2(10),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tu_txt_0800 values ('0800'),
        PARTITION bh_bt_tu_txt_0885 values ('0885'),
        PARTITION bh_bt_tu_txt_DEFA values (DEFAULT));
create unique index bh_bt_tu_u on bh_bt_tu (ma_dvi,so_id);
create index bh_bt_tu_i1 on bh_bt_tu (ngay_ht);
create index bh_bt_tu_i2 on bh_bt_tu (so_hs);
create index bh_bt_tu_i3 on bh_bt_tu (so_id_hs);
create index bh_bt_tu_i4 on bh_bt_tu (so_pa);
create index bh_bt_tu_i5 on bh_bt_tu (so_id_pa);
create index bh_bt_tu_i6 on bh_bt_tu (so_id_kt);
create index bh_bt_tu_i7 on bh_bt_tu (ma_dvi_ql,so_id_hd);

drop table bh_bt_tu_pt;
create table bh_bt_tu_pt
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
        PARTITION bh_bt_tu_pt_txt_0800 values ('0800'),
        PARTITION bh_bt_tu_pt_txt_0885 values ('0885'),
        PARTITION bh_bt_tu_pt_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tu_pt_i1 on bh_bt_tu_pt(so_id) local;
CREATE INDEX bh_bt_tu_pt_i2 on bh_bt_tu_pt(ngay_ht) local;

drop TABLE bh_bt_tu_txt;
CREATE TABLE bh_bt_tu_txt
 (ma_dvi varchar2(10),
 so_id number,
 loai varchar2(10),
 txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tu_txt_0800 values ('0800'),
        PARTITION bh_bt_tu_txt_0885 values ('0885'),
        PARTITION bh_bt_tu_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tu_txt_i1 on bh_bt_tu_txt(so_id) local;

drop table bh_bt_tu_temp;
create GLOBAL TEMPORARY table bh_bt_tu_temp
 (so_id number,
 ngay_ht number,
 tien number)
 ON COMMIT PRESERVE ROWS;

-- THANH TOAN BOI THUONG

drop TABLE bh_bt_tt;
CREATE TABLE bh_bt_tt
    (ma_dvi varchar2(10),
    so_id_tt number,
    ngay_ht number,
    so_hs varchar2(30),
    so_pa varchar2(20),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    tien number,
    thue number,
    tien_qd number,
    thue_qd number,
    t_suat number,
    pt_tra varchar2(1),
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    so_ct varchar2(20),
    phong varchar2(10),
    nbh varchar2(20),
    tpa varchar2(20),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tt_0800 values ('0800'),
        PARTITION bh_bt_tt_0885 values ('0885'),
        PARTITION bh_bt_tt_DEFA values (DEFAULT));
CREATE unique INDEX bh_bt_tt_u1 on bh_bt_tt(ma_dvi,so_id_tt) local;
CREATE INDEX bh_bt_tt_i1 on bh_bt_tt(ngay_ht) local;
CREATE INDEX bh_bt_tt_i2 on bh_bt_tt(so_id_kt) local;

drop table bh_bt_tt_ps;
CREATE TABLE bh_bt_tt_ps
 (ma_dvi varchar2(10),
 so_id_tt number,
 bt number,
 so_id number,
 so_id_pa number,
 ma_nt varchar2(5),
 tien number,
 tien_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tt_ps_0800 values ('0800'),
        PARTITION bh_bt_tt_ps_0885 values ('0885'),
        PARTITION bh_bt_tt_ps_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tt_ps_i1 on bh_bt_tt_ps(so_id_tt) local;
CREATE INDEX bh_bt_tt_ps_i2 on bh_bt_tt_ps(so_id) local;

drop table bh_bt_tt_ct;
create table bh_bt_tt_ct
 (ma_dvi varchar2(10),
 so_id_tt number,
 bt number,
 pt varchar2(1),
 ma_nt varchar2(5),
 tien number,
 tien_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tt_ct_0800 values ('0800'),
        PARTITION bh_bt_tt_ct_0885 values ('0885'),
        PARTITION bh_bt_tt_ct_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tt_ct_i1 on bh_bt_tt_ct(so_id_tt) local;

drop table bh_bt_tt_txt;
create table bh_bt_tt_txt
    (ma_dvi varchar2(10),
    so_id_tt number,
 loai varchar2(10),
 txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_tt_txt_0800 values ('0800'),
        PARTITION bh_bt_tt_txt_0885 values ('0885'),
        PARTITION bh_bt_tt_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_tt_txt_i1 on bh_bt_tt_txt(so_id_tt) local;

drop table bh_bt_tt_temp;
create GLOBAL TEMPORARY table bh_bt_tt_temp
 (so_id_tt number,
 tien number,
 ngay_ht number)
 ON COMMIT PRESERVE ROWS;

drop TABLE bh_bt_ho;
CREATE TABLE bh_bt_ho
 (ma_dvi varchar2(10),
 so_id number,
 nv varchar2(10),
 dvi_xl varchar2(10),
 k_thue varchar2(1),
 so_id_dt number,
 nsd varchar2(10));
CREATE unique INDEX bh_bt_ho_u1 on bh_bt_ho(ma_dvi,so_id,dvi_xl,so_id_dt);

drop table bh_bt_nv_temp;
create GLOBAL TEMPORARY table bh_bt_nv_temp
 (so_id_dt number,
 ten nvarchar2(400),
 lh_nv varchar2(20),
 nt_tien varchar2(5),
 tien number,
 tien_vnd number)
 ON COMMIT PRESERVE ROWS;

drop table bh_bt_ds_temp;
create GLOBAL TEMPORARY table bh_bt_ds_temp
 (so_id_dt number,
 ten nvarchar2(400))
 ON COMMIT PRESERVE ROWS;

drop table bh_bt_dt_temp;
create GLOBAL TEMPORARY table bh_bt_dt_temp
 (so_id_dt number)
 ON COMMIT PRESERVE ROWS;

drop TABLE bh_bt_chs;
CREATE TABLE bh_bt_chs
 (ma_dvi varchar2(10),
 so_id number,
 ngay_ht number,
 nv varchar2(5),
 so_hs varchar2(50),
 ma_dvi_ql varchar2(10),
 so_cv_kn varchar2(30),
 ngay_gui number,
 ngay_xr number,
 ngay_do number,
 ngay_qd number,
 gd_ten nvarchar2(50),
 gd_mobil varchar2(20),
 gd_pas varchar2(10),
 nsd varchar2(10),
 so_id_hd number,
 ngay_nh date)
     PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_chs_0800 values ('0800'),
        PARTITION bh_bt_chs_0885 values ('0885'),
        PARTITION bh_bt_chs_DEFA values (DEFAULT));
CREATE UNIQUE INDEX bh_bt_chs_u1 on bh_bt_chs(ma_dvi,so_id) local;
CREATE UNIQUE INDEX bh_bt_chs_u2 on bh_bt_chs(ma_dvi_ql,so_hs);
CREATE INDEX bh_bt_chs_i1 on bh_bt_chs(ngay_ht) local;
CREATE INDEX bh_bt_chs_i2 on bh_bt_chs(so_hs) local;
CREATE INDEX bh_bt_chs_i3 on bh_bt_chs(ma_dvi_ql,so_id);
CREATE INDEX bh_bt_chs_i4 on bh_bt_chs(so_id);

drop TABLE bh_bt_chs_nv;
CREATE TABLE bh_bt_chs_nv
 (ma_dvi varchar2(10),
 so_id number,
 bt number,
 so_id_bs number,
 so_id_dt number,
 tenTT nvarchar2(400),
 ddiem nvarchar2(400),
 lh_nv varchar2(10),
 ma_dt varchar2(10),
 ma_nt varchar2(5),
 tien_bh number,
 pt_bt number,
 t_that number,
 k_tru number,
 tien number,
 tien_qd number,
 dxuat nvarchar2(400))
 PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_chs_nv_0800 values ('0800'),
        PARTITION bh_bt_chs_nv_0885 values ('0885'),
        PARTITION bh_bt_chs_nv_DEFA values (DEFAULT));
CREATE INDEX bh_bt_chs_nv_i1 on bh_bt_chs_nv(so_id) local;
CREATE INDEX bh_bt_chs_nv_i2 on bh_bt_chs_nv(so_id_bs,so_id_dt) local;

drop TABLE bh_bt_cntba;
CREATE TABLE bh_bt_cntba
 (ma_dvi varchar2(10),
 so_id number,
 bt number,
 ten nvarchar2(200),
 ma_nt varchar2(10),
 tien number)
 PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_cntba_0800 values ('0800'),
        PARTITION bh_bt_cntba_0885 values ('0885'),
        PARTITION bh_bt_cntba_DEFA values (DEFAULT));
CREATE INDEX bh_bt_cntba_i1 on bh_bt_cntba(so_id) local;

drop TABLE bh_bt_hbh;
CREATE TABLE bh_bt_hbh
    (ma_dvi varchar2(10),
    so_id number,
    ma_nh varchar2(10),
    so_tk varchar2(30),
    ten nvarchar2(200))
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bt_hbh_0800 values ('0800'),
    PARTITION bh_bt_hbh_0885 values ('0885'),
    PARTITION bh_bt_hbh_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hbh_i1 on bh_bt_hbh(so_id) local;

drop table bh_bt_hs_tim_temp;
create GLOBAL TEMPORARY table bh_bt_hs_tim_temp(
    ngay_ht number,
    nv varchar2(10),
    so_hs varchar2(30),
    ttrang varchar2(1),
    so_hd varchar2(20),
    ten nvarchar2(500),
    ma_dvi varchar2(10),
    so_id number,
 ma_kh varchar2(20))
    ON COMMIT PRESERVE ROWS;

drop TABLE bh_bt_goc_temp1;
create GLOBAL TEMPORARY table bh_bt_goc_temp1(
 lh_nv varchar2(10),
    tien_bh number,
    pt_bt number,
    t_that number,
    tien number,
    tien_qd number,
    thue number,
    thue_qd number)
 ON COMMIT PRESERVE ROWS;

drop table bh_btL;
create table bh_btL(
    ma_dvi varchar2(10),
    so_id number,
    so_hs varchar2(30),
    ma_dvi_ql varchar2(10),
    so_hd varchar2(50),
    tien number,
    gio varchar2(20),
    ngay varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_btL_0800 values ('0800'),
        PARTITION bh_btL_0885 values ('0885'),
        PARTITION bh_btL_DEFA values (DEFAULT));
CREATE INDEX bh_btL_i1 on bh_btL(so_id,ngay) local;

drop table bh_btL_txt;
create table bh_btL_txt(
    ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob,
    ngay varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_btL_txt_0800 values ('0800'),
        PARTITION bh_btL_txt_0885 values ('0885'),
        PARTITION bh_btL_txt_DEFA values (DEFAULT));
CREATE INDEX bh_btL_txt_i1 on bh_btL_txt(so_id,ngay,loai) local;

drop table bh_bt_dota_temp;
create GLOBAL TEMPORARY table bh_bt_dota_temp(
    lh_nv varchar2(10),
    tien number,
    phi number,
    con_tl number,
    conT number,
    conP number,
    do_tl number,
    doT number,
    doP number,
    ta_tl number,
    taT number,
    taP number,
    ve_tl number,
    veT number,
    veP number)
    ON COMMIT PRESERVE ROWS;

drop table bh_bt_dota_temp_0;
create GLOBAL TEMPORARY table bh_bt_dota_temp_0(
    so_id_ta number,
    pthuc varchar2(10),
    nbh varchar2(20),
    nbhC varchar2(20),
    lh_nv varchar2(10),
    tien number,
    phi number)
    ON COMMIT PRESERVE ROWS;

drop table bh_bt_dota_temp_1;
create GLOBAL TEMPORARY table bh_bt_dota_temp_1(
    so_id_ta number,
    pthuc varchar2(10),
    nbh varchar2(20),
    nbhC varchar2(20),
    lh_nv varchar2(10),
    tien number,
    phi number)
    ON COMMIT PRESERVE ROWS;

drop table bh_bt_dota_temp_2;
create GLOBAL TEMPORARY table bh_bt_dota_temp_2(
    pthuc varchar2(10),
    nbh varchar2(20),
    tien number,
    bth number)
    ON COMMIT PRESERVE ROWS;

drop table bh_bt_dota_temp_3;
create GLOBAL TEMPORARY table bh_bt_dota_temp_3(
    pthuc varchar2(10),
    nbh varchar2(20),
    pt number,
    tien number,
    bth number)
    ON COMMIT PRESERVE ROWS;

drop TABLE bh_btP_hs;
CREATE TABLE bh_btP_hs
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    so_hs varchar2(30),
    ttrang varchar2(1),
    so_hs_bt varchar2(20),
    so_id_bt number,
    ten nvarchar2(500),
    n_trinh varchar2(10),
    ngay_tr number,
    n_duyet varchar2(10),
    ngay_qd number,
    nt_tien varchar2(5),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
    ttoan_qd number,
    nsd varchar2(10),
    dvi_ksoat varchar2(10),
    ksoat varchar2(20),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_btP_hs_0800 values ('0800'),
        PARTITION bh_btP_hs_0885 values ('0885'),
        PARTITION bh_btP_hs_DEFA values (DEFAULT));
CREATE unique INDEX bh_btP_hs_u1 on bh_btP_hs(ma_dvi,so_id) local;
CREATE unique INDEX bh_btP_hs_u2 on bh_btP_hs(ma_dvi,so_hs) local;
CREATE INDEX bh_btP_hs_i2 on bh_btP_hs(so_id_bt) local;
CREATE INDEX bh_btP_hs_i1 on bh_btP_hs(so_hs_bt) local;

drop table bh_btp_tu;
create table bh_btp_tu
(
  ma_dvi     varchar2(10 byte),
  so_id      number,
  ngay_ht    number,
  so_hs      varchar2(20 byte),
  so_id_hs   number,
  so_hs_bt   varchar2(20 byte),
  so_id_bt   number,
  ma_dvi_ql  varchar2(10 byte),
  so_id_hd   number,
  l_ct       varchar2(1 byte),
  so_ct      varchar2(20 byte),
  ma_nt      varchar2(5 byte),
  tien       number,
  tien_qd    number,
  nt_tra     varchar2(5 byte),
  tygia      number,
  tra        number,
  tra_qd     number,
  thue       number,
  thue_qd    number,
  ma_kh      varchar2(20 byte),
  ten        nvarchar2(500),
  phong      varchar2(10 byte),
  nsd        varchar2(10 byte),
  ngay_nh    date,
  so_id_kt   number,
  txt        clob)
  PARTITION BY LIST (ma_dvi) (
        PARTITION bh_btP_hs_0800 values ('0800'),
        PARTITION bh_btP_hs_0885 values ('0885'),
        PARTITION bh_btP_hs_DEFA values (DEFAULT)
);
create unique index bh_btp_tu_u0 on bh_btp_tu(ma_dvi,so_id);

create index bh_btp_tu_i1 on bh_btp_tu (ma_dvi, ngay_ht);
create index bh_btp_tu_i2 on bh_btp_tu (ma_dvi, so_hs);
create index bh_btp_tu_i3 on bh_btp_tu (ma_dvi, so_id_hs);
create index bh_btp_tu_i4 on bh_btp_tu (ma_dvi, so_hs_bt);
create index bh_btp_tu_i5 on bh_btp_tu (ma_dvi, so_id_bt);
create index bh_btp_tu_i6 on bh_btp_tu (ma_dvi, so_id_kt);