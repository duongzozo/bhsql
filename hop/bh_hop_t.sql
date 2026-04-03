-- Hop dong

drop table bh_hop;
create table bh_hop
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    nv varchar2(10),         -- nghiep vu rieng
    nhom varchar2(1),        -- gcn, hop dong
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
    email varchar2(100),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),          -- C-Co thue, K-khong thue
    so_dt number,
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
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
        PARTITION bh_hop_0800 values ('0800'),
        PARTITION bh_hop_DEFA values (DEFAULT));
CREATE unique INDEX bh_hop_u1 on bh_hop(ma_dvi,so_id) local;
CREATE unique INDEX bh_hop_u2 on bh_hop(ma_dvi,so_hd) local;
CREATE INDEX bh_hop_i1 on bh_hop(ngay_ht) local;
CREATE INDEX bh_hop_i2 on bh_hop(so_id_d) local;
CREATE INDEX bh_hop_i3 on bh_hop(so_id_g) local;
CREATE INDEX bh_hop_c1 on bh_hop(ma_kh);

drop table bh_hop_ds;
create table bh_hop_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    dtuong nvarchar2(500),
    gio_hl nvarchar2(50),
    ngay_hl number,
    gio_kt nvarchar2(50),
    ngay_kt number,
    ngay_cap number,
    so_idP number,
    phi number,
    giam number,
    ttoan number)
	PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hop_ds_0800 values ('0800'),
    PARTITION bh_hop_ds_DEFA values (DEFAULT));
CREATE INDEX bh_hop_ds_i1 on bh_hop_ds(so_id) local;
CREATE INDEX bh_hop_ds_i2 on bh_hop_ds(so_id_dt) local;
CREATE INDEX bh_hop_ds_i3 on bh_hop_ds(gcn);

drop table bh_hop_dk;
create table bh_hop_dk
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
    lkeM varchar2(1),
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    lh_bh varchar2(5))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hop_dk_0800 values ('0800'),
        PARTITION bh_hop_dk_DEFA values (DEFAULT));
CREATE INDEX bh_hop_dk_i1 on bh_hop_dk(so_id,so_id_dt) local;

drop table bh_hop_kbt;
create table bh_hop_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hop_kbt_0800 values ('0800'),
        PARTITION bh_hop_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_hop_kbt_i1 on bh_hop_kbt(so_id,so_id_dt) local;

drop table bh_hop_txt;
create table bh_hop_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hop_txt_0800 values ('0800'),
        PARTITION bh_hop_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hop_txt_i1 on bh_hop_txt(so_id) local;

drop table bh_hop_tt;
create table bh_hop_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hop_tt_0800 values ('0800'),
        PARTITION bh_hop_tt_DEFA values (DEFAULT));
CREATE INDEX bh_hop_tt_u on bh_hop_tt(ma_dvi,so_id,ngay) local;

/* Bao gia */

drop table bh_hopB;
create table bh_hopB
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(5),                 -- nghiep vu rieng      
    nhom varchar2(10),              -- G-GCN; H-Hop dong
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(30),
    phong varchar2(10),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ngay_hl number,
    ngay_kt number,
    ma_sp varchar2(10),
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    nsd varchar2(30),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hopB_0800 values ('0800'),
        PARTITION bh_hopB_DEFA values (DEFAULT));
CREATE unique INDEX bh_hopB_u1 on bh_hopB(ma_dvi,so_id) local;
CREATE unique INDEX bh_hopB_u2 on bh_hopB(ma_dvi,so_hd) local;
CREATE INDEX bh_hopB_i1 on bh_hopB(ngay_ht) local;
CREATE INDEX bh_hopB_i2 on bh_hopB(ma_kh);

drop table bh_hopB_ds;
create table bh_hopB_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(500),
    ma_dt varchar2(10),
    ngay_hl number,
    ngay_kt number)
    PARTITION BY LIST (ma_dvi) (
    	PARTITION bh_hopB_ds_0800 values ('0800'),
	    PARTITION bh_hopB_ds_DEFA values (DEFAULT));
CREATE INDEX bh_hopB_ds_i2 on bh_hopB_ds(so_id,so_id_dt) local;

drop table bh_hopB_dk;
create table bh_hopB_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ma varchar2(10),
    ten nvarchar2(500),
    kieu varchar2(1),
    lh_nv varchar2(10),
    tien number,
    phi number,
    ptG number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hopB_dk_0800 values ('0800'),
        PARTITION bh_hopB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_hopB_dk_i1 on bh_hopB_dk(so_id,so_id_dt) local;

drop table bh_hopB_txt;
create table bh_hopB_txt
    (ma_dvi varchar2(10),
    so_id number,
	lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hopB_txt_0800 values ('0800'),
        PARTITION bh_hopB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hopB_txt_i1 on bh_hopB_txt(so_id) local;

drop table bh_hopB_ls;
create table bh_hopB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hopB_ls_0800 values ('0800'),
        PARTITION bh_hopB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_hopB_ls_i1 on bh_hopB_ls(so_id,lan) local;