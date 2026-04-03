drop table bh_ng;
create table bh_ng
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    nv varchar2(10),         -- SK,DL,TD
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
    email varchar2(100),--duchq update length
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),          -- C-Co thue, K-khong thue, 0-thue 0%
    ttu varchar2(1),            -- K-Khong, H-Hop dong, N-Nhom
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
        PARTITION bh_ng_0800 values ('0800'),
        PARTITION bh_ng_080 values ('0883','0885'),
        PARTITION bh_ng_DEFA values (DEFAULT));
CREATE unique INDEX bh_ng_u1 on bh_ng(ma_dvi,so_id) local;
CREATE unique INDEX bh_ng_u2 on bh_ng(ma_dvi,so_hd) local;
CREATE INDEX bh_ng_i2 on bh_ng(so_id_d) local;
CREATE INDEX bh_ng_i3 on bh_ng(so_id_g) local;
CREATE INDEX bh_ng_i4 on bh_ng(so_id_kt) local;
CREATE INDEX bh_ng_c1 on bh_ng(ma_kh);

drop table bh_ng_dk;
create table bh_ng_dk
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
        PARTITION bh_ng_dk_0800 values ('0800'),
        PARTITION bh_ng_dk_080 values ('0883','0885'),
        PARTITION bh_ng_dk_DEFA values (DEFAULT));
CREATE INDEX bh_ng_dk_i1 on bh_ng_dk(so_id,so_id_dt) local;

drop table bh_ng_ds;
create table bh_ng_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    ten nvarchar2(100),
    ng_sinh number,
    gioi varchar2(1),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    dchi nvarchar2(400),
    nghe varchar2(10),
    ng_huong nvarchar2(500),
    ma_sp varchar2(10),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    so_idp number,
    phi number,
    giam number,
    ttoan number,
    dvi nvarchar2(100),
    ma_kh varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ng_ds_0800 values ('0800'),
        PARTITION bh_ng_ds_080 values ('0883','0885'),
        PARTITION bh_ng_ds_DEFA values (DEFAULT));
CREATE INDEX bh_ng_ds_i1 on bh_ng_ds(so_id) local;
CREATE INDEX bh_ng_ds_i2 on bh_ng_ds(so_id_dt) local;
CREATE INDEX bh_ng_ds_c1 on bh_ng_ds(gcn);
CREATE INDEX bh_ng_ds_c2 on bh_ng_ds(ma_kh);

drop table bh_ng_tt;
create table bh_ng_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ng_tt_0800 values ('0800'),
        PARTITION bh_ng_tt_080 values ('0883','0885'),
        PARTITION bh_ng_tt_DEFA values (DEFAULT));
CREATE INDEX bh_ng_tt_i1 on bh_ng_tt(so_id) local;

drop table bh_ng_ttu;
create table bh_ng_ttu
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dvi number,
    dvi nvarchar2(100),
    ca number,
    bk number,
    mota nvarchar2(500),
    tdx number,
    tdy number,
    ngay_hl number,
    ngay_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ng_ttu_0800 values ('0800'),
        PARTITION bh_ng_ttu_080 values ('0883','0885'),
        PARTITION bh_ng_ttu_DEFA values (DEFAULT));
CREATE INDEX bh_ng_ttu_i1 on bh_ng_ttu(so_id) local;
CREATE INDEX bh_ng_ttu_i2 on bh_ng_ttu(so_id_dvi) local;

drop table bh_ng_ttu_dk;
create table bh_ng_ttu_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dvi number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    lh_nv varchar2(10),
    tien number,
    pt number,
    phi number,
    t_suat number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ng_ttu_dk_0800 values ('0800'),
        PARTITION bh_ng_ttu_dk_080 values ('0883','0885'),
        PARTITION bh_ng_ttu_dk_DEFA values (DEFAULT));
CREATE INDEX bh_ng_ttu_dk_i1 on bh_ng_ttu_dk(so_id) local;

drop table bh_ng_kbt;
create table bh_ng_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ng_kbt_0800 values ('0800'),
        PARTITION bh_ng_kbt_080 values ('0883','0885'),
        PARTITION bh_ng_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_ng_kbt_i1 on bh_ng_kbt(so_id,so_id_dt) local;

drop table bh_ng_txt;
create table bh_ng_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ng_txt_0800 values ('0800'),
        PARTITION bh_ng_txt_080 values ('0883','0885'),
        PARTITION bh_ng_txt_DEFA values (DEFAULT));
CREATE INDEX bh_ng_txt_i1 on bh_ng_txt(so_id) local;

drop table bh_ngB;
create table bh_ngB
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(10),				-- G-GCN; H-Hop dong
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(30),
    phong varchar2(10),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ngay_hl number,
    ngay_kt number,
	dsach varchar2(1),
    nt_tien varchar2(5),
	tien number,
    nt_phi varchar2(5),
	phi number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    nsd varchar2(20),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngB_0800 values ('0800'),
        PARTITION bh_ngB_080 values ('0883','0885'),
        PARTITION bh_ngB_DEFA values (DEFAULT));
CREATE unique INDEX bh_ngB_u1 on bh_ngB(ma_dvi,so_id) local;
CREATE INDEX bh_ngB_i1 on bh_ngB(ngay_ht) local;
CREATE INDEX bh_ngB_i2 on bh_ngB(ma_kh);

drop table bh_ngB_ds;
create table bh_ngB_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(100),
    so_idp number,
    ma_sp varchar2(10),
    ngay_hl number,
    ngay_kt number,
    ngay_cap number,
    ma_kh varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngB_ds_0800 values ('0800'),
        PARTITION bh_ngB_ds_080 values ('0883','0885'),
        PARTITION bh_ngB_ds_DEFA values (DEFAULT));
CREATE INDEX bh_ngB_ds_i1 on bh_ngB_ds(so_id) local;
CREATE INDEX bh_ngB_ds_i2 on bh_ngB_ds(so_id_dt) local;
CREATE INDEX bh_ngB_ds_c2 on bh_ngB_ds(ma_kh);

drop table bh_ngB_dk;
create table bh_ngB_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
	ma varchar2(10),
	ten nvarchar2(500),
    lh_nv varchar2(10),
    tien number,
    phi number,
	ptG number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngB_dk_0800 values ('0800'),
        PARTITION bh_ngB_dk_080 values ('0883','0885'),
        PARTITION bh_ngB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_ngB_dk_i1 on bh_ngB_dk(so_id) local;

drop table bh_ngB_txt;
create table bh_ngB_txt
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngB_txt_0800 values ('0800'),
        PARTITION bh_ngB_txt_080 values ('0883','0885'),
        PARTITION bh_ngB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_ngB_txt_i1 on bh_ngB_txt(so_id) local;

drop table bh_ngB_ls;
create table bh_ngB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_ngB_ls_0800 values ('0800'),
        PARTITION bh_ngB_ls_080 values ('0883','0885'),
        PARTITION bh_ngB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_ngB_ls_i1 on bh_ngB_ls(so_id,lan) local;