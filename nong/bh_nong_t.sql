drop table bh_nong;
create table bh_nong
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    ngay_ht number,
    nv varchar2(10),         -- Vat nuoi,Cay trong,Thuy san
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
    ma_sp varchar2(10),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    c_thue varchar2(1),          -- C-Co thue, K-khong thue, 0-thue 0%
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
        PARTITION bh_nong_0800 values ('0800'),
        PARTITION bh_nong_DEFA values (DEFAULT));
CREATE unique INDEX bh_nong_u1 on bh_nong(ma_dvi,so_id) local;
CREATE unique INDEX bh_nong_u2 on bh_nong(ma_dvi,so_hd) local;
CREATE INDEX bh_nong_i2 on bh_nong(so_id_d) local;
CREATE INDEX bh_nong_i3 on bh_nong(so_id_g) local;
CREATE INDEX bh_nong_i4 on bh_nong(so_id_kt) local;
CREATE INDEX bh_nong_c1 on bh_nong(ma_kh);

drop table bh_nong_dk;
create table bh_nong_dk
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
        PARTITION bh_nong_dk_0800 values ('0800'),
        PARTITION bh_nong_dk_DEFA values (DEFAULT));
CREATE INDEX bh_nong_dk_i1 on bh_nong_dk(so_id,so_id_dt) local;

drop table bh_nong_dvi;
create table bh_nong_dvi
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
    loai varchar2(10),
    gio_hl varchar2(10),
    ngay_hl number,
    gio_kt varchar2(10),
    ngay_kt number,
    ngay_cap number,
    so_idp number,
    phi number,
    giam number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nong_dvi_0800 values ('0800'),
        PARTITION bh_nong_dvi_DEFA values (DEFAULT));
CREATE INDEX bh_nong_dvi_i1 on bh_nong_dvi(so_id) local;
CREATE INDEX bh_nong_dvi_i2 on bh_nong_dvi(so_id_dt) local;
CREATE INDEX bh_nong_dvi_c1 on bh_nong_dvi(gcn);

drop table bh_nong_txt;
create table bh_nong_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nong_txt_0800 values ('0800'),
        PARTITION bh_nong_txt_DEFA values (DEFAULT));
CREATE INDEX bh_nong_txt_i1 on bh_nong_txt(so_id) local;

drop table bh_nong_tt;
create table bh_nong_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nong_tt_0800 values ('0800'),
        PARTITION bh_nong_tt_DEFA values (DEFAULT));
CREATE INDEX bh_nong_tt_i1 on bh_nong_tt(so_id) local;

drop table bh_nong_kbt;
create table bh_nong_kbt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dk clob,
    lt clob,
    kbt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_nong_kbt_0800 values ('0800'),
        PARTITION bh_nong_kbt_DEFA values (DEFAULT));
CREATE INDEX bh_nong_kbt_i1 on bh_nong_kbt(so_id,so_id_dt) local;