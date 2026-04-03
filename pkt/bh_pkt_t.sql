-- Hop dong

drop table bh_pkt;
create table bh_pkt
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
        PARTITION bh_pkt_0800 values ('0800'),
        PARTITION bh_pkt_DEFA values (DEFAULT));
CREATE unique INDEX bh_pkt_u1 on bh_pkt(ma_dvi,so_id) local;
CREATE unique INDEX bh_pkt_u2 on bh_pkt(ma_dvi,so_hd) local;
CREATE INDEX bh_pkt_i1 on bh_pkt(ngay_ht) local;
CREATE INDEX bh_pkt_i2 on bh_pkt(so_id_d) local;
CREATE INDEX bh_pkt_i3 on bh_pkt(so_id_g) local;
CREATE INDEX bh_pkt_i4 on bh_pkt(so_id_kt) local;
CREATE INDEX bh_pkt_c1 on bh_pkt(ma_kh);

drop table bh_pkt_dvi;
create table bh_pkt_dvi
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
    dk_lut varchar2(1),
    hs_lut number,
    cdt varchar2(5),
    tdx number,
    tdy number,
    bk number,
    -- rieng
    ma_cct varchar2(10),
    ma_dt varchar2(10),
    ma_dkdl varchar2(20),
    ma_dktc varchar2(10),        
    rru varchar2(1),                --rui ro uot 
    tgian number,                   -- So thang thi cong
	bhanh number,                   -- So thang bao hanh
    --
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    so_idP varchar2(100),
    giam number,
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pkt_dvi_0800 values ('0800'),
        PARTITION bh_pkt_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_pkt_dvi_i1 on bh_pkt_dvi(so_id) local;
CREATE INDEX bh_pkt_dvi_i2 on bh_pkt_dvi(so_id_dt) local;
CREATE INDEX bh_pkt_dvi_i3 on bh_pkt_dvi(gcn) local;

drop table bh_pkt_dk;
create table bh_pkt_dk
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
        PARTITION bh_pkt_dk_0800 values ('0800'),
        PARTITION bh_pkt_dk_DEFA values (DEFAULT));
CREATE INDEX bh_pkt_dk_i1 on bh_pkt_dk(so_id,so_id_dt) local;

drop table bh_pkt_kbt;
create table bh_pkt_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pkt_kbt_0800 values ('0800'),
        PARTITION bh_pkt_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_pkt_kbt_i1 on bh_pkt_kbt(so_id,so_id_dt) local;

drop table bh_pkt_txt;
create table bh_pkt_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pkt_txt_0800 values ('0800'),
        PARTITION bh_pkt_txt_DEFA values (DEFAULT));
CREATE INDEX bh_pkt_txt_i1 on bh_pkt_txt(so_id) local;

drop table bh_pkt_tt;
create table bh_pkt_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pkt_tt_0800 values ('0800'),
        PARTITION bh_pkt_tt_DEFA values (DEFAULT));
CREATE INDEX bh_pkt_tt_i1 on bh_pkt_tt(so_id) local;

drop table bh_pkt_ttu;
create table bh_pkt_ttu
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
	dvi nvarchar2(200),
    tdx number,
    tdy number,
    bk number,
    ngay_hl number,
    ngay_kt number);
CREATE INDEX bh_pkt_ttu_i1 on bh_pkt_ttu(so_id);
CREATE INDEX bh_pkt_ttu_i2 on bh_pkt_ttu(so_id_dt);

/* Bao gia */

drop table bh_pktB;
create table bh_pktB
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
        PARTITION bh_pktB_0800 values ('0800'),
        PARTITION bh_pktB_DEFA values (DEFAULT));
CREATE unique INDEX bh_pktB_u1 on bh_pktB(ma_dvi,so_id) local;
CREATE unique INDEX bh_pktB_u2 on bh_pktB(ma_dvi,so_hd) local;
CREATE INDEX bh_pktB_i1 on bh_pktB(ngay_ht) local;
CREATE INDEX bh_pktB_i2 on bh_pktB(ma_kh);

drop table bh_pktB_dvi;
create table bh_pktB_dvi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ten nvarchar2(500),
	ma_dt varchar2(10),
    ddiem nvarchar2(500),
    dk_lut varchar2(1),
    hs_lut number,
	rru varchar2(1),
	cdt varchar2(10),
    tdx number,
    tdy number,
    bk number,
    ngay_hl number,
    ngay_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pktB_dvi_0800 values ('0800'),
        PARTITION bh_pktB_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_pktB_dvi_i1 on bh_pktB_dvi(so_id,so_id_dt) local;

drop table bh_pktB_dk;
create table bh_pktB_dk
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
        PARTITION bh_pktB_dk_0800 values ('0800'),
        PARTITION bh_pktB_dk_DEFA values (DEFAULT));
CREATE INDEX bh_pktB_dk_i1 on bh_pktB_dk(so_id,so_id_dt) local;

drop table bh_pktB_txt;
create table bh_pktB_txt
    (ma_dvi varchar2(10),
    so_id number,
	lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pktB_txt_0800 values ('0800'),
        PARTITION bh_pktB_txt_DEFA values (DEFAULT));
CREATE INDEX bh_pktB_txt_i1 on bh_pktB_txt(so_id) local;

drop table bh_pktB_ls;
create table bh_pktB_ls
    (ma_dvi varchar2(10),
    so_id number,
    lan number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pktB_ls_0800 values ('0800'),
        PARTITION bh_pktB_ls_DEFA values (DEFAULT));
CREATE INDEX bh_pktB_ls_i1 on bh_pktB_ls(so_id,lan) local;

-- Phuc hoi

drop table bh_pktP;
create table bh_pktP
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
        PARTITION bh_pktP_0800 values ('0800'),
        PARTITION bh_pktP_DEFA values (DEFAULT));
CREATE INDEX bh_pktP_u1 on bh_pktP(so_id_ps) local;
CREATE INDEX bh_pktP_u2 on bh_pktP(so_id,ngay_ht) local;

drop table bh_pktP_dvi;
create table bh_pktP_dvi
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
        PARTITION bh_pktP_dvi_0800 values ('0800'),
        PARTITION bh_pktP_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_pktP_dvi_i1 on bh_pktP_dvi(so_id_ps) local;
CREATE INDEX bh_pktP_dvi_i2 on bh_pktP_dvi(so_id,ngay_ht) local;

drop table bh_pktP_dk;
create table bh_pktP_dk
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
        PARTITION bh_pktP_dk_0800 values ('0800'),
        PARTITION bh_pktP_dk_DEFA values (DEFAULT));
CREATE INDEX bh_pktP_dk_i1 on bh_pktP_dk(so_id_ps) local;
CREATE INDEX bh_pktP_dk_i2 on bh_pktP_dk(so_id,ngay_ht) local;

drop table bh_pktP_txt;
create table bh_pktP_txt
    (ma_dvi varchar2(10),
    so_id_ps number,
    so_id number,
    ngay_ht number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_pktP_txt_0800 values ('0800'),
        PARTITION bh_pktP_txt_DEFA values (DEFAULT));
CREATE INDEX bh_pktP_txt_i1 on bh_pktP_txt(so_id_ps) local;