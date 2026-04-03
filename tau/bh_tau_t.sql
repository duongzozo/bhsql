drop table bh_tau;
create table bh_tau
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
        PARTITION bh_tau_0800 values ('0800'),
        PARTITION bh_tau_DEFA values (DEFAULT));
CREATE unique INDEX bh_tau_u1 on bh_tau(ma_dvi,so_id) local;
CREATE unique INDEX bh_tau_u2 on bh_tau(ma_dvi,so_hd) local;
CREATE INDEX bh_tau_i1 on bh_tau(ngay_ht) local;
CREATE INDEX bh_tau_i2 on bh_tau(so_id_d) local;
CREATE INDEX bh_tau_i3 on bh_tau(so_id_g) local;
CREATE INDEX bh_tau_i4 on bh_tau(so_id_kt) local;
CREATE INDEX bh_tau_c1 on bh_tau(ma_kh);

drop table bh_tau_ds;
create table bh_tau_ds
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
    nhom varchar2(10),
    loai varchar2(10),
    cap varchar2(10),
    vlieu varchar2(10),
    ttai number,
    so_cn number,
    dtich number,
    csuat number,
    gia number,
    tuoi number,
    ma_sp varchar2(10),
    dkien varchar2(10),             -- Dieu kien: A,B,K
    md_sd varchar2(10),             -- MDSD: H-Cho hang,N-Cho nguoi,C-Ca hai
    nv_bh varchar2(10),             -- V-Vat chat, T-trach nhiem, N-nguoi
    so_dk varchar2(20),
    ten_tau nvarchar2(500),
    nam_sx number,
    hoi varchar2(10),
    hoi_tien number,
    hoi_tyle number,
    hoi_hh number,
    tl_mgiu number,
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    giam number,
    phi number,
    thue number,
    ttoan number,
    tau_id number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tau_ds_0800 values ('0800'),
        PARTITION bh_tau_ds_DEFA values (DEFAULT));
CREATE INDEX bh_tau_ds_i0 on bh_tau_ds(tau_id);
CREATE INDEX bh_tau_ds_i1 on bh_tau_ds(so_id) local;
CREATE INDEX bh_tau_ds_i2 on bh_tau_ds(so_id_dt);
CREATE INDEX bh_tau_ds_i3 on bh_tau_ds(gcn);

drop table bh_tau_dk;
create table bh_tau_dk
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
	luy varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tau_dk_0800 values ('0800'),
        PARTITION bh_tau_dk_DEFA values (DEFAULT));
CREATE INDEX bh_tau_dk_i1 on bh_tau_dk(so_id,so_id_dt) local;

drop table bh_tau_kbt;
create table bh_tau_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tau_kbt_0800 values ('0800'),
        PARTITION bh_tau_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_tau_kbt_i1 on bh_tau_kbt(so_id,so_id_dt) local;

drop table bh_tau_txt;
create table bh_tau_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tau_txt_0800 values ('0800'),
        PARTITION bh_tau_txt_DEFA values (DEFAULT));
CREATE INDEX bh_tau_txt_i1 on bh_tau_txt(so_id) local;

drop table bh_tau_tt;
create table bh_tau_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tau_tt_0800 values ('0800'),
        PARTITION bh_tau_tt_DEFA values (DEFAULT));
CREATE INDEX bh_tau_tt_i1 on bh_tau_tt(so_id) local;

drop table bh_tau_ID;
create table bh_tau_ID(
    tau_id number,
    ten nvarchar2(500),
    tenc nvarchar2(500),
    so_dk varchar2(20),
    loai varchar2(10),
    cap varchar2(10),
    qtich varchar2(10),
    vlieu varchar2(10),
    vtoc number,
    ttai number,
    csuat number,
    dtich number,
    so_cn number,
    gia number,
    tvo number,
    may number,
    tbi number,
    nam_sx number,
    hcai varchar2(1),
    pvi nvarchar2(500));
CREATE INDEX bh_tau_ID_i1 on bh_tau_ID(tau_id);
CREATE INDEX bh_tau_ID_i3 on bh_tau_ID(so_dk);

drop table bh_tauB;
create table bh_tauB
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
        PARTITION bh_tauB_0800 values ('0800'),
        PARTITION bh_tauB_DEFA values (DEFAULT));
CREATE unique INDEX bh_tauB_u1 on bh_tauB(ma_dvi,so_id) local;
CREATE unique INDEX bh_tauB_u2 on bh_tauB(ma_dvi,so_hd) local;
CREATE INDEX bh_tauB_i1 on bh_tauB(ngay_ht) local;
CREATE INDEX bh_tauB_i2 on bh_tauB(ma_kh);

drop table bh_tauB_ds;
create table bh_tauB_ds
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(500),
	nam_sx number,
	ma_sp varchar2(10),
    nhom varchar2(10),
    ma_dt varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tauB_ds_0800 values ('0800'),
        PARTITION bh_tauB_ds_DEFA values (DEFAULT));
CREATE INDEX bh_tauB_ds_i1 on bh_tauB_ds(so_id,so_id_dt) local;

drop table bh_tauB_dk;
create table bh_tauB_dk
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
        PARTITION bh_tauB_dk_0800 values ('0800'),
        PARTITION bh_tauB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_tauB_dk_i1 on bh_tauB_dk(so_id,so_id_dt) local;

drop table bh_tauB_txt;
create table bh_tauB_txt
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tauB_txt_0800 values ('0800'),
        PARTITION bh_tauB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_tauB_txt_i1 on bh_tauB_txt(so_id,lan) local;

drop table bh_tauB_ls;
create table bh_tauB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_tauB_ls_0800 values ('0800'),
        PARTITION bh_tauB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_tauB_ls_i1 on bh_tauB_ls(so_id,lan) local;