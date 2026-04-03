-- Hop dong

drop table bh_sk;
create table bh_sk
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(1),         -- L-GCN le; G-Gia dinh; D-Doanh nghiep
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(20),
    kieu_kt varchar2(1),
    ma_kt varchar2(20),
    kieu_gt varchar2(1),
    ma_gt varchar2(20),
    ma_cb varchar2(10),
    phong varchar2(10),
    so_hdL varchar2(1),         -- E- Dien tu, G-Giay
    loai_kh varchar2(1),
    ma_kh varchar2(20),
    ten nvarchar2(200),
    dchi nvarchar2(200),
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
    c_thue varchar2(1),          -- C-Co thue, K-khong thue, 0-thue 0%
    ma_sp varchar2(10),
    cdich varchar2(10),
    tpa varchar2(20),
    ttu varchar2(1),            -- K-Khong, H-Hop dong, N-Nhom
    so_dt number,
    dsach varchar2(1),			-- Co sach di kem: C-Co, K-Khong
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
        PARTITION bh_sk_0800 values ('0800'),
        PARTITION bh_sk_0885 values ('0885'),
        PARTITION bh_sk_DEFA values (DEFAULT));
CREATE unique INDEX bh_sk_u1 on bh_sk(ma_dvi,so_id) local;
CREATE unique INDEX bh_sk_u2 on bh_sk(ma_dvi,so_hd) local;
CREATE INDEX bh_sk_i1 on bh_sk(ngay_ht) local;
CREATE INDEX bh_sk_i2 on bh_sk(so_id_d) local;
CREATE INDEX bh_sk_i3 on bh_sk(so_id_g) local;
CREATE INDEX bh_sk_c1 on bh_sk(ma_kh);

drop table bh_sk_nh;
create table bh_sk_nh
    (ma_dvi varchar2(10),
    so_id number,
    so_id_nh number,
    bt number,
    nhom varchar2(10),
    ten nvarchar2(500),
    goi varchar2(10),
    so_idP number,
    tpa varchar2(20),
    phi number,
    so_dt number,
    luong number,
    phiN number,
    tl_giam number,
    giam number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_nh_0800 values ('0800'),
        PARTITION bh_sk_nh_0885 values ('0885'),
        PARTITION bh_sk_nh_DEFA values (DEFAULT));
CREATE INDEX bh_sk_nh_i1 on bh_sk_nh(so_id) local;
CREATE INDEX bh_sk_nh_i2 on bh_sk_nh(so_id_nh) local;

drop table bh_sk_ds;
create table bh_sk_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    ten nvarchar2(100),
    luong number,
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100), --duchq update length
    dchi nvarchar2(400),
    nghe varchar2(10),
    ng_huong nvarchar2(500),
    gio_hl nvarchar2(50),
    ngay_hl number,
    gio_kt nvarchar2(50),
    ngay_kt number,
    ngay_cap number,
    goi varchar2(10),
    so_idP number,
    nhom varchar2(10),
    phi number,
    giam number,
    ttoan number,
    dvi nvarchar2(500),
    ma_kh varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_ds_0800 values ('0800'),
        PARTITION bh_sk_ds_0885 values ('0885'),
        PARTITION bh_sk_ds_DEFA values (DEFAULT));
CREATE INDEX bh_sk_ds_i3 on bh_sk_ds(gcn);
CREATE INDEX bh_sk_ds_i1 on bh_sk_ds(so_id) local;
CREATE INDEX bh_sk_ds_i2 on bh_sk_ds(so_id_dt) local;
CREATE INDEX bh_sk_ds_i4 on bh_sk_ds(ma_kh) local;

drop table bh_sk_dk;
create table bh_sk_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),             -- T-Tong, C-Chi tiet, K-Kiem soat boi thuong
    ma_ct varchar2(10),         -- Ma cap tren
    kieu varchar2(1),
    tien number,
    pt number,
    phi number,
    cap number, 
    ma_dk varchar2(10),
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
        PARTITION bh_sk_dk_0800 values ('0800'),
        PARTITION bh_sk_dk_0885 values ('0885'),
        PARTITION bh_sk_dk_DEFA values (DEFAULT));
CREATE INDEX bh_sk_dk_i1 on bh_sk_dk(so_id,so_id_dt) local;

drop table bh_sk_kbt;
create table bh_sk_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
	loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_kbt_0800 values ('0800'),
        PARTITION bh_sk_kbt_0885 values ('0885'),
        PARTITION bh_sk_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_sk_kbt_i1 on bh_sk_kbt(so_id,so_id_dt) local;

-- Lich su benh

drop table bh_sk_lsb;
create table bh_sk_lsb
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(1000),
    muc number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_lsb_0800 values ('0800'),
        PARTITION bh_sk_lsb_0885 values ('0885'),
        PARTITION bh_sk_lsb_DEFA values (DEFAULT));
CREATE INDEX bh_sk_lsb_i1 on bh_sk_lsb(so_id,so_id_dt) local;

 -- Benh khac

drop table bh_sk_bkh;
create table bh_sk_bkh
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    ten nvarchar2(1000),
    muc number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_bkh_0800 values ('0800'),
        PARTITION bh_sk_bkh_0885 values ('0885'),
        PARTITION bh_sk_bkh_DEFA values (DEFAULT));
CREATE INDEX bh_sk_bkh_i1 on bh_sk_bkh(so_id,so_id_dt) local;
CREATE INDEX bh_sk_bkh_i2 on bh_sk_bkh(muc);

drop table bh_sk_dvi;
create table bh_sk_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dvi number,
    bt number,
    dvi nvarchar2(100),
    ca number,
    bk number,
    dchi nvarchar2(500),
    tdx number,
    tdy number);
CREATE INDEX bh_sk_dvi_i1 on bh_sk_dvi(ma_dvi,so_id);

drop table bh_sk_txt;
create table bh_sk_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_txt_0800 values ('0800'),
        PARTITION bh_sk_txt_0885 values ('0885'),
        PARTITION bh_sk_txt_DEFA values (DEFAULT));
CREATE INDEX bh_sk_txt_i1 on bh_sk_txt(so_id) local;

drop table bh_sk_tt;
create table bh_sk_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_sk_tt_0800 values ('0800'),
        PARTITION bh_sk_tt_0885 values ('0885'),
        PARTITION bh_sk_tt_DEFA values (DEFAULT));
CREATE INDEX bh_sk_tt_i1 on bh_sk_tt(so_id) local;

drop table bh_sk_tim_temp1;
create GLOBAL TEMPORARY table bh_sk_tim_temp1
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    vtro varchar2(1));      -- M-Mua, D-Duoc, H-Huong

drop table bh_sk_tim_temp2;
create GLOBAL TEMPORARY table bh_sk_tim_temp2
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    so_hd varchar2(50),
    gcn varchar2(50),
    NGAY_HT number,
    TEN NVARCHAR2(500),
    DCHI NVARCHAR2(500),
    CMT VARCHAR2(20),
    MOBI VARCHAR2(20),
    EMAIL VARCHAR2(100),--duchq update length
    NGAY_HL number,
    NGAY_KT number,
    NGAY_CAP number);

drop table bh_skN;
create table bh_skN
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(1),         -- L-GCN le; G-Gia dinh; D-Doanh nghiep
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(20),
    kieu_kt varchar2(1),
    ma_kt varchar2(20),
    kieu_gt varchar2(1),
    ma_gt varchar2(20),
    ma_cb varchar2(10),
    phong varchar2(10),
    so_hdL varchar2(1),         -- E- Dien tu, G-Giay
    loai_kh varchar2(1),
    ma_kh varchar2(20),
    ten nvarchar2(200),
    dchi nvarchar2(200),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(50),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),          -- C-Co thue, K-khong thue, 0-thue 0%
    ma_sp varchar2(10),
    cdich varchar2(10),
    tpa varchar2(20),
    ttu varchar2(1),            -- K-Khong, H-Hop dong, N-Nhom
    so_dt number,
    dsach varchar2(1),			-- Co dnh sach di kem: C-Co, K-Khong
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
        PARTITION bh_skN_0800 values ('0800'),
        PARTITION bh_skN_0885 values ('0885'),
        PARTITION bh_skN_DEFA values (DEFAULT));
CREATE unique INDEX bh_skN_u1 on bh_skN(ma_dvi,so_id) local;
CREATE unique INDEX bh_skN_u2 on bh_skN(ma_dvi,so_hd) local;
CREATE INDEX bh_skN_i1 on bh_skN(ngay_ht) local;
CREATE INDEX bh_skN_i2 on bh_skN(so_id_d) local;
CREATE INDEX bh_skN_i3 on bh_skN(so_id_g) local;
CREATE INDEX bh_skN_c1 on bh_skN(ma_kh);

drop table bh_skN_txt;
create table bh_skN_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_skN_txt_0800 values ('0800'),
        PARTITION bh_skN_txt_0885 values ('0885'),
        PARTITION bh_skN_txt_DEFA values (DEFAULT));
CREATE INDEX bh_skN_txt_i1 on bh_skN_txt(so_id) local;