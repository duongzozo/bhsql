drop TABLE bh_bt_xe;
CREATE TABLE bh_bt_xe(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    so_hs varchar2(30),
    ttrang varchar2(1),
    kieu_hs varchar2(1),
    so_hs_g varchar2(20),
    gcn varchar2(20),
    ma_dvi_ql varchar2(10),
    ma_dvi_xl varchar2(10),
    so_id_hd number,
    so_id_dt number,
    so_hd varchar2(20),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ngay_gui number,
    ngay_mo number,
    ngay_do number,
    ngay_xr number,
    ma_nn varchar2(10),
    n_trinh varchar2(10),
    n_duyet varchar2(50),
    ngay_qd number,
    nt_tien varchar2(5),
    c_thue varchar2(1),
    tien number,
    tienHK number,
    thue number,
    ttoan number,
    noP varchar2(1),            -- Cho no phi
    bphi varchar2(1),           -- Thanh toan bu phi con no
    dung varchar2(1),           -- Dung hop dong
    traN varchar2(1),           -- Tra tu dong ngay sau khi duyet
    nsd varchar2(10),
    phong varchar2(10),
    so_id_kt number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
	ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xe_0800 values ('0800'),
        PARTITION bh_bt_xe_030 values ('0320','0330'),
        PARTITION bh_bt_xe_DEFA values (DEFAULT));
CREATE UNIQUE INDEX bh_bt_xe_u1 on bh_bt_xe(ma_dvi,so_id) local;
CREATE UNIQUE INDEX bh_bt_xe_u2 on bh_bt_xe(ma_dvi,so_hs) local;
CREATE INDEX bh_bt_xe_i1 on bh_bt_xe(ngay_ht) local;
CREATE INDEX bh_bt_xe_i2 on bh_bt_xe(so_id_kt) local;
CREATE INDEX bh_bt_xe_i3 on bh_bt_xe(so_id_hd) local;
CREATE INDEX bh_bt_xe_i4 on bh_bt_xe(so_id_dt) local;
CREATE INDEX bh_bt_xe_i6 on bh_bt_xe(ma_kh) local;

drop TABLE bh_bt_xe_ct;
CREATE TABLE bh_bt_xe_ct
    (ma_dvi varchar2(10),
    so_id number,
	bien_xe varchar2(20),
	ng_huong nvarchar2(1000),
	xe_id number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xe_ct_0800 values ('0800'),
        PARTITION bh_bt_xe_ct_030 values ('0320','0330'),
        PARTITION bh_bt_xe_ct_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xe_ct_i1 on bh_bt_xe_ct(so_id) local;
CREATE INDEX bh_bt_xe_ct_i2 on bh_bt_xe_ct(xe_id);

drop TABLE bh_bt_xe_dk;
CREATE TABLE bh_bt_xe_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    cap number, 
    ma_dk varchar2(10),
    ma_bs varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    tien_bh number,
    pt_bt number,
	t_that number,
    tien number,
    thue number,
    ttoan number,
	tien_qd number,
	thue_qd number,
	ttoan_qd number,
    nd nvarchar2(500),
    lkeB varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xe_dk_0800 values ('0800'),
        PARTITION bh_bt_xe_dk_030 values ('0320','0330'),
        PARTITION bh_bt_xe_dk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xe_dk_i1 on bh_bt_xe_dk(so_id) local;

drop TABLE bh_bt_xe_hk;
CREATE TABLE bh_bt_xe_hk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    nhom varchar2(1),
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
        PARTITION bh_bt_xe_hk_0800 values ('0800'),
        PARTITION bh_bt_xe_hk_030 values ('0320','0330'),
        PARTITION bh_bt_xe_hk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xe_hk_i1 on bh_bt_xe_hk(so_id) local;

drop TABLE bh_bt_xe_tba;
CREATE TABLE bh_bt_xe_tba
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xe_tba_0800 values ('0800'),
        PARTITION bh_bt_xe_tba_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xe_tba_i1 on bh_bt_xe_tba(so_id) local;

drop table bh_bt_xe_txt;
create table bh_bt_xe_txt(
	ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xe_txt_0800 values ('0800'),
        PARTITION bh_bt_xe_txt_030 values ('0320','0330'),
        PARTITION bh_bt_xe_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xe_txt_i1 on bh_bt_xe_txt(so_id) local;

drop table bh_bt_xe_duph;
create table bh_bt_xe_duph(
    ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob,
    ngay number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xe_duph_0800 values ('0800'),
        PARTITION bh_bt_xe_duph_030 values ('0320','0330'),
        PARTITION bh_bt_xe_duph_DEFA values (DEFAULT));
CREATE INDEX bh_bt_xe_duph_i1 on bh_bt_xe_duph(so_id,ngay) local;

drop TABLE bh_bt_xeP;
CREATE TABLE bh_bt_xeP(
    ma_dvi varchar2(10),
    so_id number,
    so_hs varchar2(30),
    ttrang varchar2(1),
    nv varchar2(1),             -- N-nguoi,T:tai san,V-vat chat
    so_hs_bt varchar2(20),
    so_id_bt varchar2(20),
    ten nvarchar2(500),
    n_trinh varchar2(10),
    n_duyet varchar2(50),
    ngay_qd number,
    ngay_do number,
    c_thue varchar2(1),
    nt_tien varchar2(5),
    tien number,
    thue number,
    nsd varchar2(10),
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
	ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_xeP_0800 values ('0800'),
        PARTITION bh_bt_xeP_030 values ('0320','0330'),
        PARTITION bh_bt_xeP_DEFA values (DEFAULT));
CREATE UNIQUE INDEX bh_bt_xeP_u1 on bh_bt_xeP(ma_dvi,so_id) local;
CREATE UNIQUE INDEX bh_bt_xeP_u2 on bh_bt_xeP(ma_dvi,so_hs) local;
CREATE INDEX bh_bt_xeP_i1 on bh_bt_xeP(so_id_bt) local;
CREATE INDEX bh_bt_xeP_i2 on bh_bt_xeP(so_hs_bt) local;