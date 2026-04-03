drop TABLE bh_bt_hang;
CREATE TABLE bh_bt_hang(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    so_hs varchar2(30),
    ttrang varchar2(1),
    kieu_hs varchar2(1),
    so_hs_g varchar2(20),
    ma_dvi_ql varchar2(20),
    ma_dvi_xl varchar2(20),
    so_id_hd number,
    so_hd varchar2(20),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ngay_gui number,
    ngay_mo number,
    ngay_do number,
    ngay_xr number,
    ma_nn varchar2(20),
    n_trinh varchar2(20),
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
        PARTITION bh_bt_hang_0800 values ('0800'),
        PARTITION bh_bt_hang_DEFA values (DEFAULT));
CREATE UNIQUE INDEX bh_bt_hang_u1 on bh_bt_hang(ma_dvi,so_id) local;
CREATE UNIQUE INDEX bh_bt_hang_u2 on bh_bt_hang(ma_dvi,so_hs) local;
CREATE INDEX bh_bt_hang_i1 on bh_bt_hang(ngay_ht) local;
CREATE INDEX bh_bt_hang_i2 on bh_bt_hang(so_id_kt) local;
CREATE INDEX bh_bt_hang_i3 on bh_bt_hang(so_id_hd) local;
CREATE INDEX bh_bt_hang_i6 on bh_bt_hang(ma_kh) local;
/

drop TABLE bh_bt_hang_dk;
CREATE TABLE bh_bt_hang_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ma_hang varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    cap number, 
    ma_dk varchar2(10),
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
    lkeB varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hang_dk_0800 values ('0800'),
        PARTITION bh_bt_hang_dk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hang_dk_i1 on bh_bt_hang_dk(so_id) local;
-- chuclh bo sung nhom

drop TABLE bh_bt_hang_hk;
CREATE TABLE bh_bt_hang_hk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    nhom nvarchar2(500),
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
        PARTITION bh_bt_hang_hk_0800 values ('0800'),
        PARTITION bh_bt_hang_hk_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hang_hk_i1 on bh_bt_hang_hk(so_id) local;
/

drop TABLE bh_bt_hang_tba;
CREATE TABLE bh_bt_hang_tba
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ten nvarchar2(500),
    ma_nt varchar2(5),
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hang_tba_0800 values ('0800'),
        PARTITION bh_bt_hang_tba_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hang_tba_i1 on bh_bt_hang_tba(so_id) local;
/

drop table bh_bt_hang_txt;
create table bh_bt_hang_txt(
	ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hang_txt_0800 values ('0800'),
        PARTITION bh_bt_hang_txt_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hang_txt_i1 on bh_bt_hang_txt(so_id) local;
/

drop table bh_bt_hang_duph;
create table bh_bt_hang_duph(
    ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob,
    ngay number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_bt_hang_duph_0800 values ('0800'),
        PARTITION bh_bt_hang_duph_DEFA values (DEFAULT));
CREATE INDEX bh_bt_hang_duph_i1 on bh_bt_hang_duph(so_id,ngay) local;