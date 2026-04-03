drop table tbh_dvi_ta;
create table tbh_dvi_ta(dvi_ta varchar2(10));

drop table tbh_ma_pthuc;
create table tbh_ma_pthuc
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(500),
 pp varchar2(1),
 bt number,
 nsd varchar2(10)
);
create unique index tbh_ma_pthuc_u0 on tbh_ma_pthuc(ma);

-- Ma kieu hop dong

drop table tbh_ma_khd;
create table tbh_ma_khd
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(400),
 tc varchar2(1),
 nsd varchar2(10)
);
create unique index tbh_ma_khd_u0 on tbh_ma_khd(ma);

-- Ma rui ro

drop table tbh_ma_rr;
create table tbh_ma_rr(
 ma varchar2(10),
 ten nvarchar2(400),
 nsd varchar2(10)
);
create unique index tbh_ma_rr_u0 on tbh_ma_rr(ma);

-- CONG NO NHA TAI

drop table tbh_nha_bh_cn;
CREATE TABLE tbh_nha_bh_cn
 (ma_dvi varchar2(10),
 so_id number,
 ngay_ht number,
 l_ct varchar2(1),
 so_ct varchar2(20),
 nha_bh varchar2(20),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 nsd varchar2(10),
 txt clob,
 ngay_nh date,
 so_id_kt number
);
create unique index tbh_nha_bh_cn_u0 on tbh_nha_bh_cn(so_id);
create index tbh_nha_bh_cn_i1 on tbh_nha_bh_cn (so_ct);
create index tbh_nha_bh_cn_i2 on tbh_nha_bh_cn (ngay_ht);

drop table tbh_nha_bh_sc;
create table tbh_nha_bh_sc
 (ma_dvi varchar2(10),
 nha_bh varchar2(20),
 ma_nt varchar2(5),
 thu number,
 thu_qd number,
 chi number,
 chi_qd number,
 ton number,
 ton_qd number,
 ngay_ht number
);
create unique index tbh_nha_bh_sc_u0 on tbh_nha_bh_sc(nha_bh,ma_nt,ngay_ht);

-- Muc giu lai

drop table tbh_mgiu;
create table tbh_mgiu
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    nv varchar2(10),
    ma_nt varchar2(5),
    nsd varchar2(10)
);
create unique index tbh_mgiu_u0 on tbh_mgiu(so_id);
CREATE INDEX tbh_mgiu_i1 on tbh_mgiu(ngay);

drop table tbh_mgiu_nv;
create table tbh_mgiu_nv
    (ma_dvi varchar2(10),
    so_id number,
    lh_nv varchar2(10),
    ma_dt varchar2(10),
    glai number,
    bt number);
CREATE INDEX tbh_mgiu_nv_i1 on tbh_mgiu_nv(so_id);

drop table tbh_mgiu_do;
create table tbh_mgiu_do
    (ma_dvi varchar2(10),
    so_id number,
    pt number,
    hs_gl number,
    bt number);
CREATE INDEX tbh_mgiu_do_i1 on tbh_mgiu_do(so_id);

drop table tbh_mgiu_ta;
create table tbh_mgiu_ta
    (ma_dvi varchar2(10),
    so_id number,
    pt number,
    hs_gl number,
    bt number);
CREATE INDEX tbh_mgiu_ta_i1 on tbh_mgiu_ta(so_id);

-- Hop dong nhuong tai co dinh

drop table tbh_hd_di;
create table tbh_hd_di
 (ma_dvi varchar2(10),
 so_id number,
 so_hd varchar2(20),
 nv varchar2(10),
 pthuc varchar2(10),
 ma_nt varchar2(5),
 ty_gia number,
 pbo_cp varchar2(1),
 ngay_bd number,
 ngay_kt number,
 nsd varchar2(10)
);
create unique index tbh_hd_di_u0 on tbh_hd_di(so_id);
CREATE unique INDEX tbh_hd_di_u on tbh_hd_di(so_hd);
CREATE INDEX tbh_hd_di_i2 on tbh_hd_di(ngay_bd);

drop table tbh_hd_di_nha_bh;
create table tbh_hd_di_nha_bh
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    nha_bh varchar2(20),
    pt number,
    hh number,
    hh_ll number,
    kieu varchar2(1),
    nha_bhC varchar2(20));
CREATE INDEX tbh_hd_di_nha_bh_i1 on tbh_hd_di_nha_bh(so_id);

drop table tbh_hd_di_nv;
create table tbh_hd_di_nv
 (ma_dvi varchar2(10),
 so_id number,
 lh_nv varchar2(10),
 ma_dt varchar2(10),
 nguong number,
 glai number,
 glaiM number,   -- Giu lai toi da
 ghan number,
 hh number,
 hh_ll number,
 tlp number,
 nguongG number,
 glaiG number,
 glaiMG number,
 ghanG number);
CREATE INDEX tbh_hd_di_nv_i1 on tbh_hd_di_nv(so_id);

drop table tbh_hd_di_do;
create table tbh_hd_di_do
 (ma_dvi varchar2(10),
 so_id number,
 pt number,
 hs_ng number,
 hs_gl number,
 hs_gh number);
CREATE INDEX tbh_hd_di_do_i1 on tbh_hd_di_do(so_id);

drop table tbh_hd_di_ta;
create table tbh_hd_di_ta
 (ma_dvi varchar2(10),
 so_id number,
 pt number,
 hs_ng number,
 hs_gl number,
 hs_gh number);
CREATE INDEX tbh_hd_di_ta_i1 on tbh_hd_di_ta(so_id);

-- He so giam nguong theo % boi thuong va % giam phi

drop table tbh_hd_di_hsng;
create table tbh_hd_di_hsng
    (ma_dvi varchar2(10),
    so_id number,
    ma_dt varchar2(10),
    tien number,                -- Muc trach nhiem
    bth number,                 -- Ty le boi thuong
    ptG number,                 -- Ty le giam phi
    hs number);                 -- He so nguong
CREATE INDEX tbh_hd_di_hsng_i1 on tbh_hd_di_hsng(so_id,ma_dt);

-- He so giam Uot cho PKT

drop table tbh_hd_di_uot;
create table tbh_hd_di_uot
    (ma_dvi varchar2(10),
    so_id number,
    lh_nv varchar2(10),
    nguong number,
    glai number,
    ghan number);
CREATE INDEX tbh_hd_di_uot_i1 on tbh_hd_di_uot(so_id);

drop table tbh_hd_di_txt;
create table tbh_hd_di_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_hd_di_txt_i1 on tbh_hd_di_txt(so_id);

-- Phan Bo

drop table tbh_pbo;
CREATE TABLE tbh_pbo
    (ma_dvi varchar2(10),
    so_id_xl number,
    kieu varchar2(1),
    nv varchar2(10),
    ma_dvi_ps varchar2(10),
    so_id number,
    so_id_dt number,
    ngay_ht number,
    ngay_hl date,
    ngay_kt date,
    so_ghep varchar2(20),
    lh_nv varchar2(20),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    kieu_ad varchar2(1),
    pt number,
    hh number,
    nt_tien varchar2(5),
    tien number,
    tien_g number,
    nt_phi varchar2(5),
    phi number,
    phi_g number,
    hhong number,
    nop number,
    bt number
);
create unique index tbh_pbo_u0 on tbh_pbo(ma_dvi, so_id_xl, bt);
CREATE INDEX tbh_pbo_i1 ON tbh_pbo(ma_dvi_ps,so_id,so_id_dt,lh_nv,pthuc,nha_bh);

drop table tbh_pbo_ch;
CREATE TABLE tbh_pbo_ch
    (ma_dvi   varchar2(10) ,
    so_id_ps number ,
    so_id    number,
    so_id_dt number,
    ngay_ht  number,
    ngay_hl  date,
    ngay_kt  date,
    nv       varchar2(10),
    loai     varchar2(1),
    nha_bh   varchar2(20),
    pthuc    varchar2(5),
    lh_nv    varchar2(20),
    ma_ta    varchar2(10),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number,
    bt       number ,
    so_id_xl number
);
create unique index tbh_pbo_ch_u0 on tbh_pbo_ch(ma_dvi, so_id_ps, bt);
CREATE INDEX tbh_pbo_ch_i1 ON tbh_pbo_ch(ma_dvi,so_id_xl,so_id_dt);
CREATE INDEX tbh_pbo_ch_i2 ON tbh_pbo_ch(ma_dvi,so_id,so_id_dt);

drop table tbh_pbo_ch_nv;
CREATE TABLE tbh_pbo_ch_nv
    (ma_dvi   varchar2(10) ,
    so_id    number ,
    so_id_dt number ,
    so_id_ps number ,
    bt       number ,
    pthuc    varchar2(5),
    lh_nv    varchar2(20),
    ma_ta    varchar2(20),
    nha_bh   varchar2(20),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number,
    ngay_hl  date,
    ngay_kt  date
);
create unique index tbh_pbo_ch_nv_u0 on tbh_pbo_ch_nv(ma_dvi, so_id, so_id_dt, so_id_ps, bt);

drop table tbh_pbo_ch_temp;
CREATE GLOBAL TEMPORARY TABLE tbh_pbo_ch_temp
    (ma_dvi   varchar2(10),
    so_id_ps number,
    so_id    number,
    so_id_dt number,
    ngay_ht  number,
    ngay_hl  date,
    ngay_kt  date,
    nv       varchar2(10),
    loai     varchar2(1),
    pthuc    varchar2(5),
    lh_nv    varchar2(20),
    nha_bh   varchar2(20),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number)
    ON COMMIT PRESERVE ROWS;

drop table tbh_pbo_ch_temp_2;
CREATE GLOBAL TEMPORARY TABLE tbh_pbo_ch_temp_2
    (ma_dvi   varchar2(10),
    so_id_ps number,
    so_id    number,
    so_hd    varchar2(50),
    so_id_dt number,
    ten      Nvarchar2(200),
    ngay_ht  number,
    ngay_hl  date,
    ngay_kt  date,
    nv       varchar2(10),
    loai     varchar2(1),
    pthuc    varchar2(5),
    lh_nv    varchar2(20),
    nha_bh   varchar2(20),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number)
    ON COMMIT PRESERVE ROWS;

drop table tbh_pbo_ch_temp_3;
CREATE GLOBAL TEMPORARY TABLE tbh_pbo_ch_temp_3
    (ma_dvi_ps                      varchar2(10),
    so_id_ps number,
    so_id    number,
    so_hd    varchar2(50),
    so_id_dt number,
    ten      Nvarchar2(200),
    ngay_ht  number,
    lh_nv    varchar2(20),
    nt_tien  varchar2(5),
    tien_g   number,
    nt_phi   varchar2(5),
    phi_g    number)
ON COMMIT PRESERVE ROWS;

drop table tbh_pbo_ct_temp;
CREATE GLOBAL TEMPORARY TABLE tbh_pbo_ct_temp
    (kieu     varchar2(1),
    nv       varchar2(10),
    ma_dvi_ps                      varchar2(10),
    so_id    number,
    so_id_dt number,
    ngay_ht  number,
    ngay_hl  date,
    ngay_kt  date,
    so_ghep  varchar2(20),
    lh_nv    varchar2(20),
    nha_bh   varchar2(20),
    pthuc    varchar2(1),
    kieu_ad  varchar2(1),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number)
ON COMMIT PRESERVE ROWS;

drop table tbh_pbo_dt;
CREATE TABLE tbh_pbo_dt
    (ma_dvi   varchar2(10) ,
    so_id    number ,
    so_id_dt number,
    kieu     varchar2(1),
    nha_bh   varchar2(20),
    pthuc    varchar2(5),
    lh_nv    varchar2(10),
    pt       number,
    hh       number,
    bt       number ,
    nsd      varchar2(10)
);
create unique index tbh_pbo_dt_u0 on tbh_pbo_dt(ma_dvi, so_id, bt);
CREATE INDEX tbh_pbo_dt_i1 ON tbh_pbo_dt(ma_dvi,so_id,so_id_dt);

drop table tbh_pbo_gh_temp;
CREATE GLOBAL TEMPORARY TABLE tbh_pbo_gh_temp
    (ma_dvi_ps                      varchar2(10),
    so_id    number,
    so_id_dt number,
    ngay_ht  number,
    ngay_hl  date,
    ngay_kt  date,
    lh_nv    varchar2(20),
    pthuc    varchar2(1),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number)
ON COMMIT PRESERVE ROWS;

drop table tbh_pbo_temp;
CREATE GLOBAL TEMPORARY TABLE tbh_pbo_temp
    (ma_dvi_ps                      varchar2(10),
    so_id    number,
    so_id_dt number,
    ngay_ht  number,
    ngay_hl  date,
    ngay_kt  date,
    lh_nv    varchar2(20),
    ma_ta    varchar2(20),
    nha_bh   varchar2(20),
    pthuc    varchar2(1),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    nop      number)
ON COMMIT PRESERVE ROWS;

drop table tbh_pbo_ve;
CREATE TABLE tbh_pbo_ve
    (ma_dvi   varchar2(10) ,
    so_id    number ,
    so_id_dt number ,
    ngay_ht  number ,
    nv       varchar2(10),
    nha_bh   varchar2(20),
    ngay_hl  date,
    ngay_kt  date,
    lh_nv    varchar2(20),
    ma_ta    varchar2(20),
    pt       number,
    hh       number,
    nt_tien  varchar2(5),
    tien     number,
    tien_g   number,
    nt_phi   varchar2(5),
    phi      number,
    phi_g    number,
    hhong    number,
    bt       number ,
    nsd      varchar2(10)
);
create unique index tbh_pbo_ve_u0 on tbh_pbo_ve(ma_dvi, so_id, so_id_dt, ngay_ht, bt);

drop table tbh_pbo_xl;
CREATE TABLE tbh_pbo_xl
    (ma_dvi   varchar2(10) ,
    so_id_xl number ,
    kieu     varchar2(1),
    nv       varchar2(10),
    pthuc    varchar2(1),
    so_hd    varchar2(30),
    kieu_hd  varchar2(20),
    ngay_ht  number,
    nsd      varchar2(10)
);
create unique index tbh_pbo_xl_u0 on tbh_pbo_xl(ma_dvi, so_id_xl);
CREATE INDEX tbh_pbo_xl_i1 ON tbh_pbo_xl(ma_dvi,so_hd);

drop table tbh_hd_ve_nha_bh;
create table tbh_hd_ve_nha_bh
(
  ma_dvi varchar2(10),
  so_id  number,
  nha_bh varchar2(20),
  pt     number,
  hh     number,
  hh_ll  number,
  kieu   varchar2(1)

);
create unique index tbh_hd_ve_nha_bh_u0 on tbh_hd_ve_nha_bh(ma_dvi, so_id, nha_bh);

drop table tbh_hd_ve;
create table tbh_hd_ve
(
  ma_dvi  varchar2(10) not null,
  so_id   number not null,
  so_hd   varchar2(30),
  nv      varchar2(10),
  pthuc   varchar2(10),
  kieu_hd varchar2(10),
  ma_nt   varchar2(5),
  ty_gia  number,
  tiep    varchar2(1),
  pbo_cp  varchar2(1),
  gline   varchar2(1),
  kieu_do varchar2(1),
  kieu_ve varchar2(1),
  ngay_bd number,
  ngay_kt number,
  nsd     varchar2(10)

);
create unique index tbh_hd_ve_u0 on tbh_hd_ve(ma_dvi, so_id);
create unique index tbh_hd_ve_i1 on tbh_hd_ve (ma_dvi, so_hd);
create index tbh_hd_ve_i2 on tbh_hd_ve (ma_dvi, ngay_bd);

drop table tbh_xol_ps_hd;
create table tbh_xol_ps_hd
(
  ma_dvi    varchar2(20),
  so_id     number,
  ma_dvi_hd varchar2(10),
  so_hd     varchar2(20),
  so_id_hd  number,
  so_id_dt  number,
  bt        number
);
create index tbh_xol_ps_hd_i1 on tbh_xol_ps_hd (so_id);
create index tbh_xol_ps_hd_i2 on tbh_xol_ps_hd (ma_dvi_hd, so_id_hd, so_id_dt);