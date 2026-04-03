-- Hop dong

drop table bh_gop;
create table bh_gop
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
    email varchar2(50),
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
    nsd varchar2(30),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_gop_0800 values ('0800'),
        PARTITION bh_gop_DEFA values (DEFAULT));
CREATE unique INDEX bh_gop_u1 on bh_gop(ma_dvi,so_id) local;
CREATE unique INDEX bh_gop_u2 on bh_gop(ma_dvi,so_hd) local;
CREATE INDEX bh_gop_i1 on bh_gop(ngay_ht) local;
CREATE INDEX bh_gop_i2 on bh_gop(so_id_d) local;
CREATE INDEX bh_gop_i3 on bh_gop(so_id_g) local;
CREATE INDEX bh_gop_i4 on bh_gop(so_id_kt) local;
CREATE INDEX bh_gop_c1 on bh_gop(ma_kh);

drop table bh_gop_hd;
create table bh_gop_hd
    (ma_dvi varchar2(10),
    so_id number,
    so_id_kem number,
    nv varchar2(10),
    loai varchar2(1),
    so_kem varchar2(20),
    ttrang nvarchar2(500),
	tien number,
	phi number,
	thue number,
    bt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_gop_hd_0800 values ('0800'),
        PARTITION bh_gop_hd_DEFA values (DEFAULT));
CREATE INDEX bh_gop_hd_i1 on bh_gop_hd(so_id) local;
CREATE INDEX bh_gop_hd_i2 on bh_gop_hd(so_id_kem) local;
CREATE INDEX bh_gop_hd_i3 on bh_gop_hd(so_kem) local;

drop table bh_gop_txt;
create table bh_gop_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_gop_txt_0800 values ('0800'),
        PARTITION bh_gop_txt_DEFA values (DEFAULT));
CREATE INDEX bh_gop_txt_i1 on bh_gop_txt(so_id) local;

drop table bh_gop_tt;
create table bh_gop_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_gop_tt_0800 values ('0800'),
        PARTITION bh_gop_tt_DEFA values (DEFAULT));
CREATE INDEX bh_gop_tt_i1 on bh_gop_tt(so_id) local;