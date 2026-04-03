drop table bh_hang_ttu;
create table bh_hang_ttu
    (ma_dvi varchar2(10),
    so_id number,
    pt varchar2(20),
    ten_pt nvarchar2(500),
    so_imo varchar2(20),
    hd_kem varchar2(1),
    kieu_hd varchar2(1),
    ttrang varchar2(1),
    vchuyen varchar2(10),
    ngay_cap number,
    ngay_hl number,
    ngay_kt number);
CREATE INDEX bh_hang_ttu_i1 on bh_hang_ttu(so_id);

/**HOP DONG**/

drop table bh_hang;
create table bh_hang
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(30),
    kieu_kt varchar2(1),
    ma_kt varchar2(20),
    kieu_gt varchar2(1),
    ma_gt varchar2(20),
    ma_cb varchar2(10),
    phong varchar2(10),
    so_hdL varchar2(1),
    loai_kh varchar2(1),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    dchi nvarchar2(500),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100),--duchq update length
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),            -- C-Co thue, K-khong thue, 0-thue 0%
    qtac varchar2(10),
    nhang varchar2(10),
    hd_kem varchar2(1),           -- nhieu chuyen:C,K
    c_ctai varchar2(1),          -- C-Co, K-khong
    vchuyen varchar2(10),
    cang_di varchar2(20),
    cang_den varchar2(20),
    khoang_cach number,
    thoi_gian number,
    tong_mtn number,
    tien number,
    phi number,
    giam number,
    thue number,
    ttoan number,
    hhong number,
    so_id_g number,
    so_id_d number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    so_id_kt number,
    nsd varchar2(30),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_0800 values ('0800'),
        PARTITION bh_hang_0881 values ('0881'),
        PARTITION bh_hang_DEFA values (DEFAULT));
CREATE unique INDEX bh_hang_u1 on bh_hang(ma_dvi,so_id) local;
CREATE unique INDEX bh_hang_u2 on bh_hang(ma_dvi,so_hd) local;
CREATE INDEX bh_hang_i1 on bh_hang(ngay_ht) local;
CREATE INDEX bh_hang_i2 on bh_hang(so_id_d) local;
CREATE INDEX bh_hang_i3 on bh_hang(so_id_g) local;
CREATE INDEX bh_hang_i4 on bh_hang(ma_kh);
CREATE INDEX bh_hang_i5 on bh_hang(so_hd);

drop table bh_hang_ds;
create table bh_hang_ds(
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lhang varchar2(10),
    ten_hang varchar2(500),
    dvi_tinh varchar2(50),
    dgoi varchar2(10),
    cphi number,
    sluong number,
    gia number,
    gia_tri number,
    mtn number,
    pt number,
    lkeB varchar2(1),
    lh_nv varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_ds_0800 values ('0800'),
        PARTITION bh_hang_ds_0881 values ('0881'),
        PARTITION bh_hang_ds_DEFA values (DEFAULT));
CREATE INDEX bh_hang_ds_i1 on bh_hang_ds(so_id,bt) local;

drop table bh_hang_ptvc;
create table bh_hang_ptvc(
    ma_dvi varchar2(10),
    so_id number,
    so_idP number,
    bt number,
    pt varchar2(10),
    ten_pt varchar2(500),
    so_imo varchar2(20),
    so_ch varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_ptvc_0800 values ('0800'),
        PARTITION bh_hang_ptvc_0881 values ('0881'),
        PARTITION bh_hang_ptvc_DEFA values (DEFAULT));
CREATE INDEX bh_hang_ptvc_i1 on bh_hang_ptvc(so_id) local;
/

drop table bh_hang_vch;
create table bh_hang_vch(
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_qtac varchar2(10),
    ma_nhang varchar2(10),
    vchuyen varchar2(10),
    noi_ct nvarchar2(500),
    noi_den nvarchar2(500))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_vch_0800 values ('0800'),
        PARTITION bh_hang_vch_0881 values ('0881'),
        PARTITION bh_hang_vch_DEFA values (DEFAULT));
CREATE INDEX bh_hang_vch_i1 on bh_hang_vch(so_id) local;
/

drop table bh_hang_dk;
create table bh_hang_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_hd_g varchar2(20),
    bt number,
    ma_hang varchar2(25),
    ma varchar2(25),
    ten nvarchar2(500),
    tc varchar2(1),             -- T-Tong, C-Chi tiet, K-Kiem soat boi thuong
    ma_ct varchar2(10),         -- Ma cap tren
    kieu varchar2(1),
    tien number,
    pt number,
    phi number,
    cap number, 
    ma_dk varchar2(10),
    ma_dkC varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    thue number,
    ttoan number,
    ptB number,
    ptG number,
    phiG number,
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    lh_bh varchar2(5))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_dk_0800 values ('0800'),
        PARTITION bh_hang_dk_0881 values ('0881'),
        PARTITION bh_hang_dk_DEFA values (DEFAULT));
CREATE INDEX bh_hang_dk_i1 on bh_hang_dk(so_id,so_hd_g) local;

drop table bh_hang_kbt;
create table bh_hang_kbt
    (ma_dvi varchar2(10),
    so_id number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_kbt_0800 values ('0800'),
        PARTITION bh_hang_kbt_0881 values ('0881'),
        PARTITION bh_hang_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_hang_kbt_i1 on bh_hang_kbt(so_id) local;

drop table bh_hang_txt;
create table bh_hang_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_txt_0800 values ('0800'),
        PARTITION bh_hang_txt_0881 values ('0881'),
        PARTITION bh_hang_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hang_txt_i1 on bh_hang_txt(so_id) local;

drop table bh_hang_tt;
create table bh_hang_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hang_tt_001 values ('001'),
        PARTITION bh_hang_tt_002 values ('002'),
        PARTITION bh_hang_tt_DEFA values (DEFAULT));
CREATE INDEX bh_hang_tt_i1 on bh_hang_tt(so_id) local;

-- Bao gia --

drop table bh_hangB;
create table bh_hangB
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    so_hd varchar2(20),
    ngay_ht number,
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(30),
    kieu_kt varchar2(1),
    ma_kt varchar2(20),
    kieu_gt varchar2(1),
    ma_gt varchar2(20),
    ma_cb varchar2(10),
    phong varchar2(10), 
    so_hdL varchar2(1),     -- E- Dien tu, G-Giay
    loai_kh varchar2(1),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    dchi nvarchar2(500),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100), --duchq update length
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),            -- C-Co thue, K-khong thue, 0-thue 0%
    qtac varchar2(10),
    nhang varchar2(10),
    hd_kem varchar2(1),           -- 1- 1 chuyen , N- nhieu chuyen
    c_ctai varchar2(1),          -- C-Co, K-khong
    vchuyen varchar2(10),
    cang_di varchar2(20),
    cang_den varchar2(20),
    khoang_cach number,
    thoi_gian number,
    tong_mtn number,
    tien number,
    phi number,
    giam number,
    thue number,
    ttoan number,
    hhong number,
    so_id_g number,
    so_id_d number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    so_id_kt number,
    nsd varchar2(30),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_0800 values ('0800'),
        PARTITION bh_hangB_0881 values ('0881'),
        PARTITION bh_hangB_DEFA values (DEFAULT));
CREATE unique INDEX bh_hangB_u1 on bh_hangB(ma_dvi,so_id) local;
CREATE unique INDEX bh_hangB_u2 on bh_hangB(ma_dvi,so_hd) local;
CREATE INDEX bh_hangB_i1 on bh_hangB(ngay_ht) local;
CREATE INDEX bh_hangB_i2 on bh_hangB(ma_kh);

drop table bh_hangB_ds;
create table bh_hangB_ds
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lhang varchar2(10),
    ten_hang varchar2(500),
    dvi_tinh varchar2(50),
    dgoi varchar2(10),
    cphi number,
    sluong number,
    gia number,
    gia_tri number,
    mtn number,
    pt number,
    lkeB varchar2(1),
    lh_nv varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_ds_0800 values ('0800'),
        PARTITION bh_hangB_ds_0881 values ('0881'),
        PARTITION bh_hangB_ds_DEFA values (DEFAULT));
CREATE INDEX bh_hangB_ds_i1 on bh_hangB_ds(so_id) local;

drop table bh_hangB_ptvc;
create table bh_hangB_ptvc(
    ma_dvi varchar2(10),
    so_id number,
    so_idP number,
    bt number,
    pt varchar2(10),
    ten_pt varchar2(500),
    so_imo varchar2(20),
    so_ch varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_ptvc_0800 values ('0800'),
        PARTITION bh_hangB_ptvc_0881 values ('0881'),
        PARTITION bh_hangB_ptvc_DEFA values (DEFAULT));
CREATE INDEX bh_hangB_ptvc_i1 on bh_hangB_ptvc(so_id) local;

drop table bh_hangB_vch;
create table bh_hangB_vch(
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_qtac varchar2(10),
    ma_nhang varchar2(10),
    vchuyen varchar2(10),
    noi_ct nvarchar2(500),
    noi_den nvarchar2(500))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_vch_0800 values ('0800'),
        PARTITION bh_hangB_vch_0881 values ('0881'),
        PARTITION bh_hangB_vch_DEFA values (DEFAULT));
CREATE INDEX bh_hangB_vch_i1 on bh_hangB_vch(so_id) local;

drop table bh_hangB_dk;
create table bh_hangB_dk
    (ma_dvi varchar2(10),
    so_id number,
	ma varchar2(25),
	ten nvarchar2(500),
    ma_dk varchar2(10), -- chuclh
    lh_nv varchar2(10),
    tien number,
    phi number,
	ptG number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_dk_0800 values ('0800'),
        PARTITION bh_hangB_dk_0881 values ('0881'),
        PARTITION bh_hangB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_hangB_dk_i1 on bh_hangB_dk(so_id) local;

drop table bh_hangB_txt;
create table bh_hangB_txt
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_txt_0800 values ('0800'),
        PARTITION bh_hangB_txt_0881 values ('0881'),
        PARTITION bh_hangB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hangB_txt_i1 on bh_hangB_txt(so_id,lan) local;

drop table bh_hangB_ls;
create table bh_hangB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hangB_ls_0800 values ('0800'),
        PARTITION bh_hangB_ls_0881 values ('0881'),
        PARTITION bh_hangB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_hangB_ls_i1 on bh_hangB_ls(so_id,lan) local;