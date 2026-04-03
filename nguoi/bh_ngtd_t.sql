/* Ma san pham */

drop table bh_ngtd_sp;
create table bh_ngtd_sp
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ngtd_sp_u0 on bh_ngtd_sp(ma);

/* Ma goi */

drop table bh_ngtd_goi;
CREATE TABLE bh_ngtd_goi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ngtd_goi_u0 on bh_ngtd_goi(ma);

/* Bieu phi */

drop table bh_ngtd_phi;
CREATE TABLE bh_ngtd_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),           -- Nhom: C-ca nhan, T-To chuc
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
    tuoi number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_ngtd_phi_u0 on bh_ngtd_phi(so_id);
CREATE INDEX bh_ngtd_phi_i1 on bh_ngtd_phi(nhom,ma_sp,cdich,goi,tuoi);

drop table bh_ngtd_phi_dk;
CREATE TABLE bh_ngtd_phi_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),         -- Ma cap tren
    kieu varchar2(1),
    tien number,
    pt number,
    phi number,
    lkeM varchar2(1),
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    ma_dk varchar2(10),
    ma_dkc varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    cap number,
    lh_bh varchar2(5)-- C-Chinh M-Mo rong

);
create unique index bh_ngtd_phi_dk_u0 on bh_ngtd_phi_dk(so_id,bt);

drop table bh_ngtd_phi_lt;
CREATE TABLE bh_ngtd_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_ngtd_phi_lt_u0 on bh_ngtd_phi_lt(so_id,bt);

drop table bh_ngtd_phi_txt;
create table bh_ngtd_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_ngtd_phi_txt_u0 on bh_ngtd_phi_txt(so_id,loai);

-- Hop dong

drop table bh_ngtd;
create table bh_ngtd
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    nv varchar2(1),         -- C-Ca nhan; T-To chuc
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
    c_thue varchar2(1),          -- C-Co thue, K-khong thue
    so_dt number,
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
        PARTITION bh_ngtd_0800 values ('0800'),
        PARTITION bh_ngtd_0885 values ('0885'),
        PARTITION bh_ngtd_DEFA values (DEFAULT));
CREATE unique INDEX bh_ngtd_u1 on bh_ngtd(ma_dvi,so_id) local;
CREATE unique INDEX bh_ngtd_u2 on bh_ngtd(ma_dvi,so_hd) local;
CREATE INDEX bh_ngtd_i1 on bh_ngtd(ngay_ht) local;
CREATE INDEX bh_ngtd_i2 on bh_ngtd(so_id_d) local;
CREATE INDEX bh_ngtd_i3 on bh_ngtd(so_id_g) local;
CREATE INDEX bh_ngtd_c1 on bh_ngtd(ma_kh);

drop table bh_ngtd_ds;
create table bh_ngtd_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    ten nvarchar2(100),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100), --duchq update length
    dchi nvarchar2(400),
    ng_huong nvarchar2(500),
    gio_hl nvarchar2(50),
    ngay_hl number,
    gio_kt nvarchar2(50),
    ngay_kt number,
    ngay_cap number,
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
 so_vay number,
    so_idP number,
    phi number,
    giam number,
    ttoan number,
    ma_kh varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngtd_ds_0800 values ('0800'),
        PARTITION bh_ngtd_ds_0885 values ('0885'),
        PARTITION bh_ngtd_ds_DEFA values (DEFAULT));
CREATE INDEX bh_ngtd_ds_i3 on bh_ngtd_ds(gcn);
CREATE INDEX bh_ngtd_ds_i1 on bh_ngtd_ds(so_id) local;
CREATE INDEX bh_ngtd_ds_i2 on bh_ngtd_ds(so_id_dt) local;
CREATE INDEX bh_ngtd_ds_i4 on bh_ngtd_ds(ma_kh) local;

drop table bh_ngtd_dk;
create table bh_ngtd_dk
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
    lh_bh varchar2(5))          -- C-Chinh, M-Mo rong
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngtd_dk_0800 values ('0800'),
        PARTITION bh_ngtd_dk_0885 values ('0885'),
        PARTITION bh_ngtd_dk_DEFA values (DEFAULT));
CREATE INDEX bh_ngtd_dk_i1 on bh_ngtd_dk(so_id,so_id_dt) local;

drop table bh_ngtd_kbt;
create table bh_ngtd_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngtd_kbt_0800 values ('0800'),
        PARTITION bh_ngtd_kbt_0885 values ('0885'),
        PARTITION bh_ngtd_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_ngtd_kbt_i1 on bh_ngtd_kbt(so_id,so_id_dt) local;

drop table bh_ngtd_txt;
create table bh_ngtd_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngtd_txt_0800 values ('0800'),
        PARTITION bh_ngtd_txt_0885 values ('0885'),
        PARTITION bh_ngtd_txt_DEFA values (DEFAULT));
CREATE INDEX bh_ngtd_txt_i1 on bh_ngtd_txt(so_id) local;

drop table bh_ngtd_tt;
create table bh_ngtd_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngtd_tt_0800 values ('0800'),
        PARTITION bh_ngtd_tt_0885 values ('0885'),
        PARTITION bh_ngtd_tt_DEFA values (DEFAULT));
CREATE INDEX bh_ngtd_tt_u on bh_ngtd_tt(ma_dvi,so_id,ngay) local;

drop table bh_ngtd_ttu;
create table bh_ngtd_ttu
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ngay_hl number,
    ngay_kt number,
    ma_kh varchar2(20));
CREATE INDEX bh_ngtd_ttu_i1 on bh_ngtd_ttu(so_id);
CREATE INDEX bh_ngtd_ttu_i2 on bh_ngtd_ttu(so_id_dt);
CREATE INDEX bh_ngtd_ttu_i3 on bh_ngtd_ttu(ma_kh);

drop table bh_ngtd_dtac;
create table bh_ngtd_dtac
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    nv varchar2(1),         -- C-GCN, G-Gia dinh, T-To chuc
    ma_kh varchar2(20),
    vtro varchar2(1));      -- M-Mua, D-Duoc, H-Huong
CREATE INDEX bh_ngtd_dtac_i1 on bh_ngtd_dtac(so_id);
CREATE INDEX bh_ngtd_dtac_i2 on bh_ngtd_dtac(so_id_dt);
CREATE INDEX bh_ngtd_dtac_i3 on bh_ngtd_dtac(ma_kh);

drop table bh_ngtd_tim_temp1;
create GLOBAL TEMPORARY table bh_ngtd_tim_temp1
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    vtro varchar2(1));      -- M-Mua, D-Duoc, H-Huong

drop table bh_ngtd_tim_temp2;
create GLOBAL TEMPORARY table bh_ngtd_tim_temp2
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