drop table bh_xe;
create table bh_xe
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    nv varchar2(10),              -- G-GCN; H-Hop dong
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
    ten nvarchar2(200),
    dchi nvarchar2(500),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100),--duchq update
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),          -- C-Co thue, K-khong thue, 0-thue 0%
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
        PARTITION bh_xe_020 values ('0200'),
        PARTITION bh_xe_040 values ('0410','0420'),
        PARTITION bh_xe_060 values ('0650'),
        PARTITION bh_xe_DEFA values (DEFAULT));
CREATE unique INDEX bh_xe_u1 on bh_xe(ma_dvi,so_id) local;
CREATE unique INDEX bh_xe_u2 on bh_xe(ma_dvi,so_hd) local;
CREATE INDEX bh_xe_i1 on bh_xe(ngay_ht) local;
CREATE INDEX bh_xe_i2 on bh_xe(so_id_d) local;
CREATE INDEX bh_xe_i3 on bh_xe(so_id_g) local;
CREATE INDEX bh_xe_i4 on bh_xe(so_id_kt) local;
CREATE INDEX bh_xe_c1 on bh_xe(ma_kh);

drop table bh_xe_ds;
create table bh_xe_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
	tenC nvarchar2(500),
    cmtC varchar2(20),
    mobiC varchar2(20),
    emailC varchar2(100),--duchq update
	dchiC nvarchar2(500),
	ng_huong nvarchar2(1000),
	bien_xe varchar2(20),
	so_khung varchar2(30),
	so_may varchar2(30),
	hang varchar2(20),
	hieu varchar2(20),
	pban varchar2(20),
    loai_xe varchar2(10),
    nhom_xe varchar2(10),
    dong varchar2(10),
    dco varchar2(1),
    ttai number,
    so_cn number,
	nam_sx number,
    gia number,
    md_sd varchar2(10),
    nv_bh varchar2(10),				-- B-Bat buoc, T- Tu nguyen, V-Vat chat, M-Mo rong
	bh_tbo varchar2(1),				-- C-BH toan bo, K-chi BH vo xe, 
    ma_sp varchar2(10),
    cdich varchar2(10),
	goi varchar2(10),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    giam number,
    phi number,
    thue number,
    ttoan number,
	so_idP varchar2(100),
	xe_id number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xe_ds_020 values ('0200'),
        PARTITION bh_xe_ds_040 values ('0410','0420'),
        PARTITION bh_xe_ds_060 values ('0650'),
        PARTITION bh_xe_ds_DEFA values (DEFAULT));
CREATE INDEX bh_xe_ds_i0 on bh_xe_ds(xe_id);
CREATE INDEX bh_xe_ds_i1 on bh_xe_ds(so_id) local;
CREATE INDEX bh_xe_ds_i2 on bh_xe_ds(so_id_dt);
CREATE INDEX bh_xe_ds_i3 on bh_xe_ds(gcn);

drop table bh_xe_dk;
create table bh_xe_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),             -- T-Tong, C-Chi tiet
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
    lh_bh varchar2(5))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xe_dk_020 values ('0200'),
        PARTITION bh_xe_dk_040 values ('0410','0420'),
        PARTITION bh_xe_dk_060 values ('0650'),
        PARTITION bh_xe_dk_DEFA values (DEFAULT));
CREATE INDEX bh_xe_dk_i1 on bh_xe_dk(so_id,so_id_dt) local;

drop table bh_xe_kbt;
create table bh_xe_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xe_kbt_020 values ('0200'),
        PARTITION bh_xe_kbt_040 values ('0410','0420'),
        PARTITION bh_xe_kbt_060 values ('0650'),
        PARTITION bh_xe_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_xe_kbt_i1 on bh_xe_kbt(so_id,so_id_dt) local;

drop table bh_xe_txt;
create table bh_xe_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xe_txt_020 values ('0200'),
        PARTITION bh_xe_txt_040 values ('0410','0420'),
        PARTITION bh_xe_txt_060 values ('0650'),
        PARTITION bh_xe_txt_DEFA values (DEFAULT));
CREATE INDEX bh_xe_txt_i1 on bh_xe_txt(so_id) local;

drop table bh_xe_tt;
create table bh_xe_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xe_tt_020 values ('0200'),
        PARTITION bh_xe_tt_040 values ('0410','0420'),
        PARTITION bh_xe_tt_060 values ('0650'),
        PARTITION bh_xe_tt_DEFA values (DEFAULT));
CREATE INDEX bh_xe_tt_i1 on bh_xe_tt(so_id) local;

drop table bh_xe_ID;
create table bh_xe_ID(
    xe_id number,
	ten nvarchar2(500),
    cmt varchar2(20),
    mobi varchar2(20),
    email varchar2(100),--duchq update
	dchi nvarchar2(500),
	bien_xe varchar2(30),
	so_khung varchar2(30),
	so_may varchar2(30),
	hang varchar2(20),
	hieu varchar2(20),
	pban varchar2(20),
    loai_xe varchar2(10),
    nhom_xe varchar2(10),
    dong varchar2(10),
    dco varchar2(1),
    ttai number,
    so_cn number,
	nam_sx number,
    gia number);
CREATE INDEX bh_xe_ID_i1 on bh_xe_ID(xe_id);
CREATE INDEX bh_xe_ID_i2 on bh_xe_ID(so_khung);
CREATE INDEX bh_xe_ID_i3 on bh_xe_ID(bien_xe);

drop table bh_xeB;
create table bh_xeB
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    so_hd varchar2(20),
    ngay_ht number,
    nv varchar2(10),              -- G-GCN; H-Hop dong
    ttrang varchar2(1),
    kieu_hd varchar2(1),
    so_hd_g varchar2(30),
    phong varchar2(10),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ngay_hl number,
    ngay_kt number,
    nt_tien varchar2(5),
	tien number,
    nt_phi varchar2(5),
	phi number,
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    nsd varchar2(30),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xeB_020 values ('0200'),
        PARTITION bh_xeB_040 values ('0410','0420'),
        PARTITION bh_xeB_060 values ('0650'),
        PARTITION bh_xeB_DEFA values (DEFAULT));
CREATE unique INDEX bh_xeB_u1 on bh_xeB(ma_dvi,so_id) local;
CREATE unique INDEX bh_xeB_u2 on bh_xeB(ma_dvi,so_hd) local;
CREATE INDEX bh_xeB_i1 on bh_xeB(ngay_ht) local;
CREATE INDEX bh_xeB_i2 on bh_xeB(ma_kh);

drop table bh_xeB_ds;
create table bh_xeB_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(500),
    loai_xe varchar2(10),
    nam_sx number,
    md_sd varchar2(10),
    ma_sp varchar2(10),
    ma_dt varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xeB_ds_020 values ('0200'),
        PARTITION bh_xeB_ds_040 values ('0410','0420'),
        PARTITION bh_xeB_ds_060 values ('0650'),
        PARTITION bh_xeB_ds_DEFA values (DEFAULT));
CREATE INDEX bh_xeB_ds_i1 on bh_xeB_ds(so_id,so_id_dt) local;

drop table bh_xeB_dk;
create table bh_xeB_dk
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
        PARTITION bh_xeB_dk_020 values ('0200'),
        PARTITION bh_xeB_dk_040 values ('0410','0420'),
        PARTITION bh_xeB_dk_060 values ('0650'),
        PARTITION bh_xeB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_xeB_dk_i1 on bh_xeB_dk(so_id,so_id_dt) local;

drop table bh_xeB_txt;
create table bh_xeB_txt
    (ma_dvi varchar2(10),
    so_id number,
	lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xeB_txt_020 values ('0200'),
        PARTITION bh_xeB_txt_040 values ('0410','0420'),
        PARTITION bh_xeB_txt_060 values ('0650'),
        PARTITION bh_xeB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_xeB_txt_i1 on bh_xeB_txt(so_id) local;

drop table bh_xeB_ls;
create table bh_xeB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_xeB_ls_020 values ('0200'),
        PARTITION bh_xeB_ls_040 values ('0410','0420'),
        PARTITION bh_xeB_ls_060 values ('0650'),
        PARTITION bh_xeB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_xeB_ls_i1 on bh_xeB_ls(so_id,lan) local;