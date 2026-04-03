drop table tbh_ung_ps;
create table tbh_ung_ps(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    ung_qd number,
    so_id_kt number
);
create unique index tbh_ung_ps_u0 on tbh_ung_ps(ma_dvi,so_id);
CREATE INDEX tbh_ung_ps_i1 on tbh_ung_ps(ma_dvi,so_id_kt);

drop table tbh_ung_ps_ct;
create table tbh_ung_ps_ct(
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ngay_ht number,
    kieu varchar2(1),           -- C-Co dinh, T-Tam thoi
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    ma_nt varchar2(5),
    tle number,
    phi number,
    ung number,
    ung_qd number,
    tra varchar2(1)-- Da tra: C-Chua D-Da

);
create unique index tbh_ung_ps_ct_u0 on tbh_ung_ps_ct(ma_dvi,so_id,bt);
CREATE INDEX tbh_ung_ps_ct_i1 on tbh_ung_ps_ct(ma_dvi_hd,so_id_hd);
CREATE INDEX tbh_ung_ps_ct_i2 on tbh_ung_ps_ct(tra);

drop table tbh_ung_tra;
create table tbh_ung_tra(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    ung_qd number,
    so_id_kt number
);
create unique index tbh_ung_tra_u0 on tbh_ung_tra(ma_dvi,so_id);
CREATE INDEX tbh_ung_tra_i1 on tbh_ung_tra(ma_dvi,so_id_kt);

drop table tbh_ung_tra_ct;
create table tbh_ung_tra_ct(
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ngay_ht number,
    kieu varchar2(1),           -- C-Co dinh, T-Tam thoi
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    ma_nt varchar2(5),
    tle number,
    phi number,
    ung number,
    ung_qd number
);
create unique index tbh_ung_tra_ct_u0 on tbh_ung_tra_ct(ma_dvi,so_id,bt);
CREATE INDEX tbh_ung_tra_ct_i1 on tbh_ung_tra_ct(ma_dvi_hd,so_id_hd);

drop table tbh_tam_ps;
create table tbh_tam_ps(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    tam_qd number,
    so_id_kt number
);
create unique index tbh_tam_ps_u0 on tbh_tam_ps(ma_dvi,so_id);
CREATE INDEX tbh_tam_ps_i1 on tbh_tam_ps(ma_dvi,so_id_kt);

drop table tbh_tam_ps_ct;
create table tbh_tam_ps_ct(
    ma_dviG varchar2(10),
    so_idG number,
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    hhong number,
    hhong_qd number,
    tra varchar2(1)
);
create unique index tbh_tam_ps_ct_u0 on tbh_tam_ps_ct(ma_dvi,so_id,bt);
CREATE INDEX tbh_tam_ps_ct_i1 on tbh_tam_ps_ct(tra);
CREATE INDEX tbh_tam_ps_ct_i2 on tbh_tam_ps_ct(ma_dviG,so_idG);

drop table tbh_tam_tra;
create table tbh_tam_tra(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    tam_qd number,
    so_id_kt number
);
create unique index tbh_tam_tra_u0 on tbh_tam_tra(ma_dvi,so_id);
CREATE INDEX tbh_tam_tra_i1 on tbh_tam_tra(ma_dvi,so_id_kt);

drop table tbh_tam_tra_ct;
create table tbh_tam_tra_ct(
    ma_dviG varchar2(10),
    so_idG number,
    ma_dvi varchar2(10),
    so_id number,
    bt number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    hhong number,
    hhong_qd number
);
create unique index tbh_tam_tra_ct_u0 on tbh_tam_tra_ct(ma_dvi,so_id,bt);
CREATE INDEX tbh_tam_tra_ct_i1 on tbh_tam_tra_ct(ma_dviG,so_idG);