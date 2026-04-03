-- Hop dong--

drop table bh_ptn;
create table bh_ptn
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    nv varchar2(10),         -- Nghe nghiep,cong cong,van chuyen
    nhom varchar2(10),        -- G-GCN; H-Hop dong
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(30),
    kieu_kt varchar2(1),
    ma_kt varchar2(20),
    kieu_gt varchar2(1),
    ma_gt varchar2(20),
    ma_cb varchar2(10),
    phong varchar2(10),
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
    c_thue varchar2(1),          -- C-Co thue, K-khong thue, 0-thue 0%
    ma_sp varchar2(10),
    cdich varchar2(10), 
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
    nsd varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptn_0800 values ('0800'),
        PARTITION bh_ptn_DEFA values (DEFAULT));
CREATE unique INDEX bh_ptn_u1 on bh_ptn(ma_dvi,so_id) local;
CREATE unique INDEX bh_ptn_u2 on bh_ptn(ma_dvi,so_hd) local;
CREATE INDEX bh_ptn_i2 on bh_ptn(so_id_d) local;
CREATE INDEX bh_ptn_i3 on bh_ptn(so_id_g) local;
CREATE INDEX bh_ptn_i4 on bh_ptn(so_id_kt) local;
CREATE INDEX bh_ptn_c1 on bh_ptn(ma_kh);

drop table bh_ptn_dvi;
create table bh_ptn_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    dtuong nvarchar2(500),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    ngay_hoi number,
    so_idP varchar2(100),
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptn_dvi_0800 values ('0800'),
        PARTITION bh_ptn_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_ptn_dvi_i1 on bh_ptn_dvi(so_id) local;
CREATE INDEX bh_ptn_dvi_i2 on bh_ptn_dvi(so_id_dt) local;
CREATE INDEX bh_ptn_dvi_i3 on bh_ptn_dvi(gcn) local;

drop table bh_ptn_dk;
create table bh_ptn_dk
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
        PARTITION bh_ptn_dk_0800 values ('0800'),
        PARTITION bh_ptn_dk_DEFA values (DEFAULT));
CREATE INDEX bh_ptn_dk_i1 on bh_ptn_dk(so_id,so_id_dt) local;

drop table bh_ptn_txt;
create table bh_ptn_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptn_txt_0800 values ('0800'),
        PARTITION bh_ptn_txt_DEFA values (DEFAULT));
CREATE INDEX bh_ptn_txt_i1 on bh_ptn_txt(so_id) local;

drop table bh_ptn_tt;
create table bh_ptn_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptn_tt_0800 values ('0800'),
        PARTITION bh_ptn_tt_DEFA values (DEFAULT));
CREATE INDEX bh_ptn_tt_i1 on bh_ptn_tt(so_id) local;

drop table bh_ptn_kbt;
create table bh_ptn_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptn_kbt_0800 values ('0800'),
        PARTITION bh_ptn_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_ptn_kbt_i1 on bh_ptn_kbt(so_id,so_id_dt) local;

/* Bao gia */

drop table bh_ptnB;
create table bh_ptnB
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(5),          -- TNCC-Cong cong, TNNN-Nghe nghiep     
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
        PARTITION bh_ptnB_0800 values ('0800'),
        PARTITION bh_ptnB_DEFA values (DEFAULT));
CREATE unique INDEX bh_ptnB_u1 on bh_ptnB(ma_dvi,so_id) local;
CREATE unique INDEX bh_ptnB_u2 on bh_ptnB(ma_dvi,so_hd) local;
CREATE INDEX bh_ptnB_i1 on bh_ptnB(ngay_ht) local;
CREATE INDEX bh_ptnB_i2 on bh_ptnB(ma_kh);

drop table bh_ptnB_dvi;
create table bh_ptnB_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(500),
    ma_dt varchar2(10),
    ngay_hl number,
    ngay_kt number)
    PARTITION BY LIST (ma_dvi) (
    	PARTITION bh_ptnB_dvi_0800 values ('0800'),
	    PARTITION bh_ptnB_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_ptnB_dvi_i2 on bh_ptnB_dvi(so_id,so_id_dt) local;

drop table bh_ptnb_ds;
create table bh_ptnb_ds (
  ma_dvi    varchar2(10 byte),
  so_id     number,
  so_id_dt  number,
  ten       nvarchar2(500),
  ma_dt     varchar2(10 byte))
  partition by list (ma_dvi) (
    	partition bh_ptnb_dvi_0800 values ('0800'),
	    partition bh_ptnb_dvi_defa values (default));
create index bh_ptnb_ds_i2 on bh_ptnb_ds (so_id, so_id_dt);

drop table bh_ptnB_dk;
create table bh_ptnB_dk
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
        PARTITION bh_ptnB_dk_0800 values ('0800'),
        PARTITION bh_ptnB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_ptnB_dk_i1 on bh_ptnB_dk(so_id,so_id_dt) local;

drop table bh_ptnB_txt;
create table bh_ptnB_txt
    (ma_dvi varchar2(10),
    so_id number,
	lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptnB_txt_0800 values ('0800'),
        PARTITION bh_ptnB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_ptnB_txt_i1 on bh_ptnB_txt(so_id) local;

drop table bh_ptnB_ls;
create table bh_ptnB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ptnB_ls_0800 values ('0800'),
        PARTITION bh_ptnB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_ptnB_ls_i1 on bh_ptnB_ls(so_id,lan) local;