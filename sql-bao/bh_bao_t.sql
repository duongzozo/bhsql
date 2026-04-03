drop table bh_bao;
create table bh_bao
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(20),
    nv varchar2(10),
    ttrang varchar2(1),
    phong varchar2(10),
	ma_kh varchar2(20),
	ten nvarchar2(500),
    ngay_ht number,
    ngay_hl number,
    ngay_kt number,
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    nsd varchar2(10),
    dvi_ksoat varchar2(10),
    ksoat varchar2(10))
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bao_0800 values ('0800'),
    PARTITION bh_bao_DEFA values (DEFAULT));
CREATE unique INDEX bh_bao_i1 on bh_bao(ma_dvi,so_id) local;
CREATE INDEX bh_bao_i2 on bh_bao(so_hd) local;

drop table bh_bao_ch;
create table bh_bao_ch
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(1),
    bt number,
    ngay number,
    ma_dvi_tr varchar2(10),
    nsd_tr varchar2(10))
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_bao_ch_0800 values ('0800'),
    PARTITION bh_bao_ch_DEFA values (DEFAULT));
CREATE unique INDEX bh_bao_ch_u on bh_bao_ch(ma_dvi,so_id,loai,bt) local;
CREATE INDEX bh_bao_ch_i1 on bh_bao_ch(so_id) local;

drop table tbh_tmb;
create table tbh_tmb(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    nt_ta varchar2(5),
    nt_phi varchar2(5),
	nha_bh varchar2(20),
    nguon varchar2(1),
    pbo_cp varchar2(1),
    dvi varchar2(10),
    so_idb number,
    so_id_dtb number,
    so_hd varchar2(30),
	ten nvarchar2(400),
    kieu_xl varchar2(1), -- K-Da,C-Cho,K-Khong
    nsd varchar2(10),
    ngay_nh date);
create unique index tbh_tmb_u1 on tbh_tmb(ma_dvi,so_id);
CREATE INDEX tbh_tmb_i1 on tbh_tmb (ma_dvi,ngay_ht,nv);
CREATE INDEX tbh_tmb_i2 on tbh_tmb (dvi,so_idb,so_id_dtb);

drop table tbh_tmb_phi;
create table tbh_tmb_phi(
	ma_dvi varchar2(10),
	so_id number,
	ma_ta varchar2(20),
	pt number,
	tien number,
	phi number,
	tl_thue number,
	thue number,
	pt_hh number,
	hhong number,
	bt number);
CREATE INDEX tbh_tmb_phi_i1 on tbh_tmb_phi(ma_dvi,so_id);