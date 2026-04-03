-- Hop dong

drop table bh_phh;
create table bh_phh
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
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
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
        PARTITION bh_phh_0800 values ('0800'),
        PARTITION bh_phh_DEFA values (DEFAULT));
CREATE unique INDEX bh_phh_u1 on bh_phh(ma_dvi,so_id) local;
CREATE unique INDEX bh_phh_u2 on bh_phh(ma_dvi,so_hd) local;
CREATE INDEX bh_phh_i1 on bh_phh(ngay_ht) local;
CREATE INDEX bh_phh_i2 on bh_phh(so_id_d) local;
CREATE INDEX bh_phh_i3 on bh_phh(so_id_g) local;
CREATE INDEX bh_phh_i4 on bh_phh(so_id_kt) local;
CREATE INDEX bh_phh_c1 on bh_phh(ma_kh);
CREATE INDEX bh_phh_c2 on bh_phh(so_hd);

drop table bh_phh_dvi;
create table bh_phh_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    dvi nvarchar2(500),
    ma_dt varchar2(10),
    kvuc varchar2(10),
    lvuc nvarchar2(500),
    ddiem nvarchar2(500),
    dk_lut varchar2(1),
    hs_lut number,
    mrr varchar2(10),
	cdt varchar2(5),
    tdx number,
    tdy number,
    bk number,
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    so_idP number,
    giam number,
    phi number,
    thue number,
    ttoan number,
	tlbt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phh_dvi_0800 values ('0800'),
        PARTITION bh_phh_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_phh_dvi_i1 on bh_phh_dvi(so_id) local;
CREATE INDEX bh_phh_dvi_i2 on bh_phh_dvi(so_id_dt) local;
CREATE INDEX bh_phh_dvi_i3 on bh_phh_dvi(gcn) local;

drop table bh_phh_dk;
create table bh_phh_dk
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
    ma_dkC varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    thue number,
    ttoan number,
    ptB number,
	phiB number,
    ptG number,
    phiG number,
    lkeM varchar2(1),
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    lbh varchar2(5),			-- TS,TB,HH,KH
	nv varchar2(1),				-- C-Chinh, M-Mo rong, T-Them
	ktru varchar2(1),
    pvi_ma varchar2(10),
    pvi_tc varchar2(1),
	pvi_ktru varchar2(100))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phh_dk_0800 values ('0800'),
        PARTITION bh_phh_dk_DEFA values (DEFAULT));
CREATE INDEX bh_phh_dk_i1 on bh_phh_dk(so_id,so_id_dt) local;

drop table bh_phh_kbt;
create table bh_phh_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phh_kbt_0800 values ('0800'),
        PARTITION bh_phh_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_phh_kbt_i1 on bh_phh_kbt(so_id,so_id_dt) local;

drop table bh_phh_txt;
create table bh_phh_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phh_txt_0800 values ('0800'),
        PARTITION bh_phh_txt_DEFA values (DEFAULT));
CREATE INDEX bh_phh_txt_i1 on bh_phh_txt(so_id) local;

drop table bh_phh_tt;
create table bh_phh_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phh_tt_0800 values ('0800'),
        PARTITION bh_phh_tt_DEFA values (DEFAULT));
CREATE INDEX bh_phh_tt_i1 on bh_phh_tt(so_id) local;

drop table bh_phh_ttu;
create table bh_phh_ttu
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dvi nvarchar2(500),
    tdx number,
    tdy number,
    bk number,
    ngay_hl number,
    ngay_kt number);
CREATE INDEX bh_phh_ttu_i1 on bh_phh_ttu(so_id);
CREATE INDEX bh_phh_ttu_i2 on bh_phh_ttu(so_id_dt);

/* Bao gia */

drop table bh_phhB;
create table bh_phhB
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
        PARTITION bh_phhB_0800 values ('0800'),
        PARTITION bh_phhB_DEFA values (DEFAULT));
CREATE unique INDEX bh_phhB_u1 on bh_phhB(ma_dvi,so_id) local;
CREATE unique INDEX bh_phhB_u2 on bh_phhB(ma_dvi,so_hd) local;
CREATE INDEX bh_phhB_i1 on bh_phhB(ngay_ht) local;
CREATE INDEX bh_phhB_i2 on bh_phhB(ma_kh);

drop table bh_phhB_dvi;
create table bh_phhB_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(500),
	mrr varchar2(10),
    ma_dt varchar2(10),
    ddiem nvarchar2(500),
    dl_lut varchar2(1),
    hs_lut number,
    cdt varchar2(5),
    tdx number,
    tdy number,
    bk number,
    ngay_hl number,
    ngay_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhB_dvi_0800 values ('0800'),
        PARTITION bh_phhB_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_phhB_dvi_i1 on bh_phhB_dvi(so_id,so_id_dt) local;

drop table bh_phhB_dk;
create table bh_phhB_dk
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ma varchar2(10),
    ten nvarchar2(500),
	kieu varchar2(1),
    lh_nv varchar2(10),
    tien number,
    phi number,
    ptG number,
    pvi_ma varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhB_dk_0800 values ('0800'),
        PARTITION bh_phhB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_phhB_dk_i1 on bh_phhB_dk(so_id,so_id_dt) local;

drop table bh_phhB_txt;
create table bh_phhB_txt
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhB_txt_0800 values ('0800'),
        PARTITION bh_phhB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_phhB_txt_i1 on bh_phhB_txt(so_id,lan) local;

-- Phuc hoi

drop table bh_phhP;
create table bh_phhP
    (ma_dvi varchar2(10),
    so_id_ps number,
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    so_ct varchar2(20),
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    phi number,
    thue number,
    ttoan number,
    phi_qd number,
    thue_qd number,
    ttoan_qd number,
    so_id_kt number,
    nsd varchar2(30),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhP_0800 values ('0800'),
        PARTITION bh_phhP_DEFA values (DEFAULT));
CREATE unique INDEX bh_phhP_u1 on bh_phhP(ma_dvi,so_id_ps) local;
CREATE unique INDEX bh_phhP_u2 on bh_phhP(ma_dvi,so_id,ngay_ht) local;

drop table bh_phhP_dvi;
create table bh_phhP_dvi
    (ma_dvi varchar2(10),
    so_id_ps number,
    so_id number,
    so_id_dt number,
    ngay_ht number,
    dvi nvarchar2(500),
    ma_dt varchar2(10),
    lan number,
    bth number,
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhP_dvi_0800 values ('0800'),
        PARTITION bh_phhP_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_phhP_dvi_i1 on bh_phhP_dvi(so_id_ps) local;
CREATE INDEX bh_phhP_dvi_i2 on bh_phhP_dvi(so_id,ngay_ht) local;

drop table bh_phhP_dk;
create table bh_phhP_dk
    (ma_dvi varchar2(10),
    so_id_ps number,
    so_id number,
    so_id_dt number,
    ngay_ht number,
    lh_nv varchar2(10),
    t_suat number,
    ma_dt varchar2(10),
    phi number,
    thue number,
    phi_qd number,
    thue_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhP_dk_0800 values ('0800'),
        PARTITION bh_phhP_dk_DEFA values (DEFAULT));
CREATE INDEX bh_phhP_dk_i1 on bh_phhP_dk(so_id_ps) local;
CREATE INDEX bh_phhP_dk_i2 on bh_phhP_dk(so_id,ngay_ht) local;

drop table bh_phhP_txt;
create table bh_phhP_txt
    (ma_dvi varchar2(10),
    so_id_ps number,
    so_id number,
    ngay_ht number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_phhP_txt_0800 values ('0800'),
        PARTITION bh_phhP_txt_DEFA values (DEFAULT));
CREATE INDEX bh_phhP_txt_i1 on bh_phhP_txt(so_id_ps) local;

drop table bh_phhb_ls;
create table bh_phhb_ls
(
  ma_dvi varchar2(10),
  so_id  number,
  lan    number,
  loai   varchar2(20),
  txt    clob
)
partition by list (ma_dvi)(
  partition bh_phhb_ls_001 values ('001'),
  partition bh_phhb_ls_002 values ('002'),
  partition bh_phhb_ls_defa values (default));
CREATE INDEX bh_phhb_ls_i1 on bh_phhb_ls (so_id, lan);