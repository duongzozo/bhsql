drop TABLE bh_bt_pkt;
CREATE TABLE bh_bt_pkt(
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
    ten nvarchar2(100),
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
        PARTITION bh_bt_pkt_0800 values ('0800'),
        PARTITION bh_bt_pkt_DEFA values (DEFAULT));
CREATE UNIQUE INDEX bh_bt_pkt_u1 on bh_bt_pkt(ma_dvi,so_id) local;
CREATE UNIQUE INDEX bh_bt_pkt_u2 on bh_bt_pkt(ma_dvi,so_hs) local;
CREATE INDEX bh_bt_pkt_i1 on bh_bt_pkt(ngay_ht) local;
CREATE INDEX bh_bt_pkt_i2 on bh_bt_pkt(so_id_kt) local;
CREATE INDEX bh_bt_pkt_i3 on bh_bt_pkt(so_id_hd) local;
CREATE INDEX bh_bt_pkt_i4 on bh_bt_pkt(so_id_dt) local;
CREATE INDEX bh_bt_pkt_i6 on bh_bt_pkt(ma_kh) local;

drop TABLE bh_bt_pkt_ct;
CREATE TABLE bh_bt_pkt_ct
    (ma_dvi varchar2(10),
    so_id number,
	dvi nvarchar2(500),
	dchi nvarchar2(500),
	ng_huong nvarchar2(1000))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_pkt_ct_0800 values ('0800'),
        PARTITION bh_bt_pkt_ct_DEFA values (DEFAULT));
CREATE INDEX bh_bt_pkt_ct_i1 on bh_bt_pkt_ct(so_id) local;

drop TABLE bh_bt_pkt_dk;
CREATE TABLE bh_bt_pkt_dk
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
    lkeB varchar2(1),
	luy varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_pkt_dk_0800 values ('0800'),
        PARTITION bh_bt_pkt_dk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_pkt_dk_i1 on bh_bt_pkt_dk(so_id) local;

drop TABLE bh_bt_pkt_hk;
CREATE TABLE bh_bt_pkt_hk
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
        PARTITION bh_bt_pkt_hk_0800 values ('0800'),
        PARTITION bh_bt_pkt_hk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_pkt_hk_i1 on bh_bt_pkt_hk(so_id) local;

drop TABLE bh_bt_pkt_tba;
CREATE TABLE bh_bt_pkt_tba
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_pkt_tba_0800 values ('0800'),
        PARTITION bh_bt_pkt_tba_DEFA values (DEFAULT));
CREATE INDEX bh_bt_pkt_tba_i1 on bh_bt_pkt_tba(so_id) local;

drop table bh_bt_pkt_txt;
create table bh_bt_pkt_txt(
	ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_pkt_txt_0800 values ('0800'),
        PARTITION bh_bt_pkt_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_pkt_txt_i1 on bh_bt_pkt_txt(so_id) local;

drop table bh_bt_pkt_duph;
create table bh_bt_pkt_duph(
    ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob,
    ngay number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_pkt_duph_0800 values ('0800'),
        PARTITION bh_bt_pkt_duph_DEFA values (DEFAULT));
CREATE INDEX bh_bt_pkt_duph_i1 on bh_bt_pkt_duph(so_id,ngay) local;