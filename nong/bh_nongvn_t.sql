-- Hop dong

drop table bh_nongvn;
create table bh_nongvn
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
        PARTITION bh_nongvn_0800 values ('0800'),
        PARTITION bh_nongvn_DEFA values (DEFAULT));
CREATE unique INDEX bh_nongvn_u1 on bh_nongvn(ma_dvi,so_id) local;
CREATE unique INDEX bh_nongvn_u2 on bh_nongvn(ma_dvi,so_hd) local;
CREATE INDEX bh_nongvn_i1 on bh_nongvn(ngay_ht) local;
CREATE INDEX bh_nongvn_i2 on bh_nongvn(so_id_d) local;
CREATE INDEX bh_nongvn_i3 on bh_nongvn(so_id_g) local;
CREATE INDEX bh_nongvn_i4 on bh_nongvn(so_id_kt) local;
CREATE INDEX bh_nongvn_c1 on bh_nongvn(ma_kh);

drop table bh_nongvn_dvi;
create table bh_nongvn_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    kieu_gcn varchar2(1),
    gcn varchar2(20),
    gcn_g varchar2(20),
    dvi nvarchar2(500),
    kvuc varchar2(10),
    ddiem nvarchar2(500),
    cdt varchar2(1),
    tdx number,
    tdy number,
    bk number,
    --rieng
    loai varchar2(10),          -- Chung loai
    qmo varchar2(10),           -- Quy mo
    so_dt number,
    --
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    so_idp number,
    giam number,
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nongvn_dvi_0800 values ('0800'),
        PARTITION bh_nongvn_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_nongvn_dvi_i1 on bh_nongvn_dvi(so_id) local;
CREATE INDEX bh_nongvn_dvi_i2 on bh_nongvn_dvi(so_id_dt) local;
CREATE INDEX bh_nongvn_dvi_i3 on bh_nongvn_dvi(gcn) local;

drop table bh_nongvn_dk;
create table bh_nongvn_dk
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
	nv varchar2(1),				-- C-Chinh, M-Mo rong
    ktru varchar2(1),
    pvi_ma varchar2(10),
    pvi_tc varchar2(1),
	pvi_ktru varchar2(100))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nongvn_dk_0800 values ('0800'),
        PARTITION bh_nongvn_dk_DEFA values (DEFAULT));
CREATE INDEX bh_nongvn_dk_i1 on bh_nongvn_dk(so_id,so_id_dt) local;

drop table bh_nongvn_kbt;
create table bh_nongvn_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nongvn_kbt_0800 values ('0800'),
        PARTITION bh_nongvn_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_nongvn_kbt_i1 on bh_nongvn_kbt(so_id,so_id_dt) local;

drop table bh_nongvn_txt;
create table bh_nongvn_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nongvn_txt_0800 values ('0800'),
        PARTITION bh_nongvn_txt_DEFA values (DEFAULT));
CREATE INDEX bh_nongvn_txt_i1 on bh_nongvn_txt(so_id) local;

drop table bh_nongvn_tt;
create table bh_nongvn_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nongvn_tt_0800 values ('0800'),
        PARTITION bh_nongvn_tt_DEFA values (DEFAULT));
CREATE INDEX bh_nongvn_tt_i1 on bh_nongvn_tt(so_id) local;