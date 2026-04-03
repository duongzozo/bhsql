-- Goc
-- 1.Moi
-- 2.Su doi bo sung phi do doanh thu thay doi
-- 3. Phuc hoi

-- XOL

drop table tbh_xol;
create table tbh_xol(
    so_id number,
    ngay_ht number,
    so_hd varchar2(20),
    kieu_hd varchar2(1),
    so_hd_g varchar2(20),
    ma_nt varchar2(5),
    glai number,
    ttoan number,
    ngay_bd number,
    ngay_kt number,
    nv varchar2(100),            -- XE,2B,NG,...
    so_id_d number,
    so_id_g number,
    nsd varchar2(20)
);
create unique index tbh_xol_u0 on tbh_xol(so_id);
    CREATE unique INDEX tbh_xol_u1 on tbh_xol(so_hd);
    CREATE INDEX tbh_xol_i2 on tbh_xol(so_id_d);
    CREATE INDEX tbh_xol_i3 on tbh_xol(so_id_g);

drop table tbh_xol_nv;
create table tbh_xol_nv(
    so_id number,
    bt number,
    lh_nv varchar2(10),
    tu number,
    den number,
    lan number,
    pt number,
    phi number,
    vu number,
    tien number);
    CREATE INDEX tbh_xol_nv_i1 on tbh_xol_nv(so_id,lh_nv,tu);

drop table tbh_xol_nbh;
create table tbh_xol_nbh(
    so_id number,
    so_hd varchar2(20),
    nbh varchar2(20),
    kieu varchar2(1),
    pt number,
    phi number,
    tl_thue number,
    thue number,
    nbhC varchar2(20),
    bt number);
CREATE INDEX tbh_xol_nbh_i1 on tbh_xol_nbh(so_id);

drop table tbh_xol_kytt;
create table tbh_xol_kytt(
    so_id number,
    ma_nt varchar2(5),
    ngay number,
    tien number);
CREATE INDEX tbh_xol_kytt_i1 on tbh_xol_kytt(so_id);

drop table tbh_xol_txt;
create table tbh_xol_txt(
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_xol_txt_i1 on tbh_xol_txt(so_id);

drop table tbh_xol_dc;
create table tbh_xol_dc(
    so_id number,
    lh_nv varchar2(10),
    tu number,
    den number,
    lan number,
    phi number,
    vu number,
    tien number);
    CREATE INDEX tbh_xol_dc_i1 on tbh_xol_dc(so_id);

drop table tbh_xol_sc;
create table tbh_xol_sc(
    so_id number,
    lh_nv varchar2(10),
    tu number,
    den number,
    ngay number,
    lan number,
    vu number,
    tien number,
    lanT number,
    vuT number,
    tienT number);
CREATE unique INDEX tbh_xol_sc_u on tbh_xol_sc(so_id,lh_nv,tu,ngay);

-- Phuc hoi

drop table tbh_xol_ph;
create table tbh_xol_ph(
    so_id number,
    ngay_ht number,
    so_ph varchar2(20),
    ma_nt varchar2(5),
    glai number,
    ttoan number,
    ngay_bd number,
    ngay_kt number,
    nv varchar2(100),
    so_idD number,
    nsd varchar2(10)
);
create unique index tbh_xol_ph_u0 on tbh_xol_ph(so_id);
CREATE INDEX tbh_xol_ph_i1 on tbh_xol_ph(so_ph);
CREATE INDEX tbh_xol_ph_i2 on tbh_xol_ph(ngay_ht);
CREATE INDEX tbh_xol_ph_i3 on tbh_xol_ph(so_idD);

drop table tbh_xol_ph_nv;
create table tbh_xol_ph_nv(
    so_id number,
    bt number,
    lh_nv varchar2(10),
    tu number,
    den number,
    lan varchar2(10),
    pt number,
    bth number,
    phi number,
    vu number,
    tien number);
    CREATE INDEX tbh_xol_ph_nv_i1 on tbh_xol_ph_nv(so_id);

drop table tbh_xol_ph_nbh;
create table tbh_xol_ph_nbh(
    so_id number,
    so_hd varchar2(20),
    nbh varchar2(20),
    kieu varchar2(1),
    pt number,
    phi number,
    tl_thue number,
    thue number,
    nbhC varchar2(20),
    bt number);
CREATE INDEX tbh_xol_ph_nbh_i1 on tbh_xol_ph_nbh(so_id);

drop table tbh_xol_ph_dc;
create table tbh_xol_ph_dc(
    so_id number,
    lh_nv varchar2(10),
    tu number,
    den number,
    lan varchar2(10),
    phi number,
    vu number,
    tien number);
    CREATE INDEX tbh_xol_ph_dc_i1 on tbh_xol_ph_dc(so_id);

drop table tbh_xol_ph_txt;
create table tbh_xol_ph_txt(
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_xol_ph_txt_i1 on tbh_xol_ph_txt(so_id);

--- Tai XOL boi thuong ---

drop table tbh_xol_bth_ps;
create table tbh_xol_bth_ps(
    ma_dvi_bt varchar2(10),
    so_id_bt number,            -- so_id phat sinh boi thuong
    so_id_dt number,
    nv varchar2(10),
    ngay_qd number,
    ngay_xr number,
    skien varchar2(20));
CREATE INDEX tbh_xol_bth_ps_i1 on tbh_xol_bth_ps(ma_dvi_bt,so_id_bt);

drop table tbh_xol_bth_ps_ct;
create table tbh_xol_bth_ps_ct(
    ma_dvi_bt varchar2(10),
    so_id_bt number,
    ngay_ht number,
    so_id_ta number,
    ma_ta varchar2(10),
    tu number,
    den number,
    vu number,
    tien number);
CREATE INDEX tbh_xol_bth_ps_ct_i1 on tbh_xol_bth_ps_ct(ma_dvi_bt,so_id_bt);

drop table tbh_xol_bth_ps_pt;
create table tbh_xol_bth_ps_pt(
    ma_dvi_bt varchar2(10),
    so_id_bt number,
    so_id_dt number,
    ma_dvi_btT varchar2(10),
    so_id_btT number,
    so_id_ta number,
    ma_ta varchar2(10),
    lh_nv varchar2(10),
    tu number,
    den number,
    tien number,
    tien_qd number);
CREATE INDEX tbh_xol_bth_pt_pt_i1 on tbh_xol_bth_ps_pt(ma_dvi_bt,so_id_bt);
CREATE INDEX tbh_xol_bth_pt_pt_i2 on tbh_xol_bth_ps_pt(ma_dvi_btT,so_id_btT);

drop table tbh_xol_bth_ps_id;
create table tbh_xol_bth_ps_id(
    ma_dvi_bt varchar2(10),
    so_id_bt number,
    so_id_ps number);
CREATE INDEX tbh_xol_bth_ps_id_i1 on tbh_xol_bth_ps_id(ma_dvi_bt,so_id_bt);

drop table tbh_xol_bth_temp0;
create GLOBAL TEMPORARY table tbh_xol_bth_temp0(
    nv varchar2(10),
    so_id_ta number,
    ma_ta varchar2(10),
    ma_nt varchar2(5),
    tu number,
    den number,
    tien number,
    vu number)
    ON COMMIT PRESERVE ROWS;

drop table tbh_xol_bth_temp1;
create GLOBAL TEMPORARY table tbh_xol_bth_temp1(
    nv varchar2(10),
    so_id_ta number,
    ma_ta varchar2(10),
    ma_nt varchar2(5),
    tu number,
    den number,
    tien number,
    vu number)
    ON COMMIT PRESERVE ROWS;

drop table tbh_xol_bth_temp2;
create GLOBAL TEMPORARY table tbh_xol_bth_temp2(
    nv varchar2(10),
    so_id_ta number,
    nbhC varchar2(20),
    ma_nt varchar2(10),
    tien number)
    ON COMMIT PRESERVE ROWS;

drop table tbh_xol_ps;
create table tbh_xol_ps
(
  ma_dvi   varchar2(10),
  so_id    number,
  ngay_ht  number,
  nv       varchar2(10),
  so_ct    varchar2(20),
  kieu     varchar2(1),
  so_ctg   varchar2(20),
  ngay_hl  number,
  ngay_kt  number,
  nt_tien  varchar2(5),
  so_id_d  number,
  so_id_g  number,
  nsd      varchar2(10),
  ngay_nh  date

);
create unique index tbh_xol_ps_u0 on tbh_xol_ps(so_id);

drop table tbh_xol_nh;
create table tbh_xol_nh
(
  ma_dvi  varchar2(10),
  so_id   number,
  ngay_ht number,
  nv      varchar2(10),
  so_ct   varchar2(20),
  kieu    varchar2(1),
  so_ctg  varchar2(20),
  ngay_hl number,
  ngay_kt number,
  nt_tien varchar2(5),
  so_id_d number,
  so_id_g number,
  nsd     varchar2(10),
  ngay_nh date

);
create unique index tbh_xol_nh_u0 on tbh_xol_nh(so_id);
create index tbh_xol_nh_i1 on tbh_xol_nh (ngay_ht, nv);
create index tbh_xol_nh_i2 on tbh_xol_nh (so_id_d);
create index tbh_xol_nh_i3 on tbh_xol_nh (so_id_g);
create unique index tbh_xol_nh_u1 on tbh_xol_nh (so_ct);

drop table tbh_xol_nh_hd;
create table tbh_xol_nh_hd
(
  ma_dvi    varchar2(20),
  so_id     number,
  ma_dvi_hd varchar2(10),
  so_hd     varchar2(20),
  so_id_hd  number,
  so_id_dt  number,
  bt        number
);
create index tbh_xol_nh_hd_i1 on tbh_xol_nh_hd (so_id);
create index tbh_xol_nh_hd_i2 on tbh_xol_nh_hd (ma_dvi_hd, so_id_hd, so_id_dt);