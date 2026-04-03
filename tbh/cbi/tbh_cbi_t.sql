drop table tbh_cbi;
create table tbh_cbi(
    ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    so_ct varchar2(20),
    kieu varchar2(1),           -- G-Goc, B-Bo sung, T-Tai tuc
    so_ctG varchar2(20),
    ngay_ht number,
    kieu_ps varchar2(1),
    kieu_xl varchar2(1),
    phai_xl varchar2(1),
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    so_id_ta number,
    nd nvarchar2(500),
    nsd varchar2(10),
    ngay_nh date
);
create unique index tbh_cbi_u0 on tbh_cbi(so_id);
CREATE INDEX tbh_cbi_i1 on tbh_cbi (ngay_ht,nv,kieu);
CREATE INDEX tbh_cbi_i2 on tbh_cbi (ma_dvi_hd,so_id_hd);
CREATE INDEX tbh_cbi_i3 on tbh_cbi (so_id_ta);

drop table tbh_cbi_hd;
create table tbh_cbi_hd
    (ma_dvi varchar2(10),
    so_id number,
    ma_dvi_hd varchar2(10),
    so_hd varchar2(20),
    so_id_hd number,
    so_id_dt number,
    bt number);
CREATE INDEX tbh_cbi_hd_i1 on tbh_cbi_hd(so_id);
CREATE INDEX tbh_cbi_hd_i2 on tbh_cbi_hd (ma_dvi_hd,so_id_hd,so_id_dt);

drop table tbh_cbi_nbh;
create table tbh_cbi_nbh(
    so_id number,
    nbh varchar2(20),
    pt number,
    hh number,
    kieu varchar2(1),
 nbhC varchar2(20),
 bt number);
CREATE INDEX tbh_cbi_nbh_i1 on tbh_cbi_nbh(so_id);

drop table tbh_cbi_temp;
create GLOBAL TEMPORARY table tbh_cbi_temp(
 ma_dvi_hd varchar2(10),
 so_id_hd number)
ON COMMIT PRESERVE ROWS;

drop table tbh_tmB_cbi;
create table tbh_tmB_cbi(
    so_id number,
    nv varchar2(10),
    so_ct varchar2(20),
    kieu varchar2(1),               -- G-Goc, B-Bo sung
    so_ctG varchar2(20),
    ngay_ht number,
    kieu_ps varchar2(1),            -- Kieu tao cbi: B-Bao gia, H-Hop dong, T-Trinh
    kieu_xl varchar2(1),            -- Xu ly: Co, Khong
    ma_dviP varchar2(10),           -- Ma don vi, so Id tao su kien
    so_idP number,
    so_id_dtP number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    nd nvarchar2(500),
    nsd varchar2(20),
    ngay_nh date
);
create unique index tbh_tmb_cbi_u0 on tbh_tmb_cbi(so_id);
CREATE INDEX tbh_tmB_cbi_i1 on tbh_tmB_cbi (ngay_ht,nv,kieu_xl);
CREATE INDEX tbh_tmB_cbi_i2 on tbh_tmB_cbi (ma_dviP,so_idP,so_id_dtP);

drop table tbh_tmB_cbi_nbh;
create table tbh_tmB_cbi_nbh(
    so_id number,
    nbh varchar2(20),
    pt number,
    hh number,
    kieu varchar2(1),
 nbhC varchar2(20),
 bt number);
CREATE INDEX tbh_tmB_cbi_nbh_i1 on tbh_tmB_cbi_nbh(so_id);

drop table tbh_tmB_cbi_hd;
create table tbh_tmB_cbi_hd
    (so_id number,
    kieu varchar2(1),
    ma_dvi_hd varchar2(10),
    so_hd varchar2(20),
    so_id_hd number,
    so_id_dt number,
    ten nvarchar2(500),
    so_idC number,
    bt number);
CREATE INDEX tbh_tmB_cbi_hd_i1 on tbh_tmB_cbi_hd(so_id);
CREATE INDEX tbh_tmB_cbi_hd_i2 on tbh_tmB_cbi_hd(ma_dvi_hd,so_id_hd,so_id_dt);

-- chi dinh tai

drop table tbh_cbi_cdt;
create table tbh_cbi_cdt
    (ma_dvi_hd varchar2(10),
    so_id_hd number,
    pthuc varchar2(1),
    bt number
);
create unique index tbh_cbi_cdt_u0 on tbh_cbi_cdt(ma_dvi_hd,so_id_hd);