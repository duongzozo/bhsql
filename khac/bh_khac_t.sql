drop table bh_kh_so_tt;
CREATE TABLE bh_kh_so_tt
 (ma_dvi varchar2(10),
 loai varchar2(10),
 nv varchar2(10),
 nam number,
 stt number
);
create unique index bh_kh_so_tt_u0 on bh_kh_so_tt(ma_dvi,loai,nv,nam);

drop table bh_kh_so_tt_nv;
CREATE TABLE bh_kh_so_tt_nv
 (nv varchar2(10),
 nv_tu varchar2(10)
);
create unique index bh_kh_so_tt_nv_u0 on bh_kh_so_tt_nv(nv);

drop table bh_kh_ttt_ct;
CREATE TABLE bh_kh_ttt_ct
 (ma_dvi varchar2(10),
 ps varchar2(10),
 nv varchar2(10),
 so_id number,
 so_id_dt number,
 ma varchar2(20),
 nd nvarchar2(1000),
 so number
);
create unique index bh_kh_ttt_ct_u0 on bh_kh_ttt_ct(ma_dvi,ps,nv,so_id,so_id_dt,ma);

drop table bh_kh_ttt_ct_temp;
create GLOBAL TEMPORARY table bh_kh_ttt_ct_temp(
 ma varchar2(20),
 nd nvarchar2(1000),
 ma_nt varchar2(5))
ON COMMIT PRESERVE ROWS;

drop table bh_kh_js;
create table bh_kh_js
    (ma_dvi varchar2(10),
 nv varchar2(10),
    so_id number,
    so_id_dt number,
    nd clob,
    CONSTRAINT bh_kh_js_chk check (nd is JSON))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_kh_js_0800 values ('0800'),
        PARTITION bh_kh_js_DEFA values (DEFAULT));
CREATE INDEX bh_kh_js_u on bh_kh_js(nv,so_id,so_id_dt) local;

drop table bh_kh_muc;
CREATE TABLE bh_kh_muc
 (ma_dvi varchar2(10),
 so_id number,
 nv varchar2(10),
 ngay number,
 muc varchar2(10),
 nsd varchar2(10)
);
create unique index bh_kh_muc_u0 on bh_kh_muc(ma_dvi,so_id);
create index bh_kh_muc_i1 on bh_kh_muc (ma_dvi,nv,ngay);

drop table bh_kh_muc_ct;
CREATE TABLE bh_kh_muc_ct
 (ma_dvi varchar2(10),
 so_id number,
 ma varchar2(20),
 tu_nd varchar2(200),
 tu_dk varchar2(2),
 den_nd varchar2(20),
 den_dk varchar2(2),
 loai varchar2(1)
);
create unique index bh_kh_muc_ct_u0 on bh_kh_muc_ct(ma_dvi,so_id,ma);

drop table bh_kh_file;
CREATE TABLE bh_kh_file
    (ma_dvi varchar2(10),
    so_id number,
    so_id_g number,
    ten varchar2(50),
    url varchar2(200),
    nd nvarchar2(500),
    nsd varchar2(10),
    ngay_nh date
);
create unique index bh_kh_file_u0 on bh_kh_file(ma_dvi,so_id);
create index bh_kh_file_i1 on bh_kh_file (ma_dvi,so_id_g);

drop table bh_kh_toa_do;
CREATE TABLE bh_kh_toa_do
    (ma_dvi varchar2(10),
    so_id number,
    b_x number,
 b_y number,
 b_r number
);
create unique index bh_kh_toa_do_u0 on bh_kh_toa_do(ma_dvi,so_id);

drop table bh_kh_gd;
CREATE TABLE bh_kh_gd
    (ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10), -- T:TTGD, H:Ho so boi thuong, B:Bao gia, G: Hop dong goc, C:Chuan bi
    pas varchar2(10),
 nd nvarchar2(200)
);
create unique index bh_kh_gd_u0 on bh_kh_gd(so_id);


/*** Gui thong bao ***/

drop table kh_guiM;
CREATE TABLE kh_guiM(
    ps varchar2(30),
 loai varchar2(1),  -- S-SMS, M-Mail
    nd nvarchar2(2000)  -- Noi dung gui
);
create unique index kh_guim_u0 on kh_guim(ps,loai);

drop table kh_gui;
CREATE TABLE kh_gui(
    so_id number,
    ps varchar2(30),
    so_idG number,
 loai varchar2(1),  -- S-SMS, M-Mail
    toi varchar2(30),       -- S-so mobi, M-dchi email
    nd nvarchar2(2000),
 tao date
);
create unique index kh_gui_u0 on kh_gui(so_id);

drop table kh_guiL;
CREATE TABLE kh_guiL(
    so_id number,
    ps varchar2(30),
    so_idG number,
 loai varchar2(1),
    toi varchar2(30),
    nd nvarchar2(2000),
 tao date,
    gui date);
create index kh_guiL_i1 on kh_guiL (so_id);
CREATE INDEX kh_guiL_i2 on kh_guiL(so_idG);

drop table bh_tkeNH;
CREATE TABLE bh_tkeNH(ma varchar2(10));

drop table kh_file;
create table kh_file
  (ma_dvi    varchar2(20),
  so_id      number,
  ten        nvarchar2(400),
  goc        varchar2(200),
  kieuf      varchar2(1),
  x          number,
  y          number,
  r          number,
  vtri       varchar2(100),
  bt         number,
  ma_dvi_nh  varchar2(20),
  nsd        varchar2(10),
  ngay_nh    date,
  idvung     number
);
create unique index kh_file_u0 on kh_file(ma_dvi, so_id, bt);
create index kh_file_i1 on kh_file (ma_dvi, so_id, goc);

drop table kh_so_tt_nam;
create table kh_so_tt_nam
(
  ma_dvi varchar2(10),
  loai   varchar2(10),
  nv     varchar2(10),
  nam    number,
  stt    number

);
create unique index kh_so_tt_nam_u0 on kh_so_tt_nam(ma_dvi, loai, nv, nam);

drop table kh_ttt_ct;
create table kh_ttt_ct
(
  ma_dvi   varchar2(10),
  so_id    number,
  so_id_dt number,
  md       varchar2(10),
  nv       varchar2(10),
  ma       varchar2(20),
  nd       nvarchar2(2000),
  so       number,
  idvung   number

);
create unique index kh_ttt_ct_u0 on kh_ttt_ct(ma_dvi, so_id, so_id_dt, ma);

drop table kh_nh_tk;
create table kh_nh_tk
(
  ma_dvi varchar2(20),
  ma_nh  varchar2(10),
  ma_tk  varchar2(20),
  ten    nvarchar2(200),
  nsd    varchar2(10),
  idvung number

);
create unique index kh_nh_tk_u0 on kh_nh_tk(ma_dvi, ma_nh, ma_tk);

drop table kh_ma_nhang;
create table kh_ma_nhang
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  dchi   nvarchar2(200),
  nsd    varchar2(10),
  idvung number

);
create unique index kh_ma_nhang_u0 on kh_ma_nhang(ma_dvi, ma);

drop table BH_HHGCN;
create table BH_HHGCN
(
  ma_dvi      VARCHAR2(10),
  so_id       NUMBER,
  ngay_ht     NUMBER,
  kieu_kt     VARCHAR2(1),
  ma_kt       VARCHAR2(10),
  dly_tke     VARCHAR2(10),
  hd_vay      VARCHAR2(30),
  hhong       NUMBER,
  cb_ql       VARCHAR2(10),
  phong       VARCHAR2(10),
  ma_cb       VARCHAR2(10),
  so_hd       VARCHAR2(50),
  kieu_hd     VARCHAR2(1),
  so_hd_g     VARCHAR2(50),
  ma_kh       VARCHAR2(20),
  ten         NVARCHAR2(400),
  dchi        NVARCHAR2(400),
  dd_a        NVARCHAR2(200),
  cv_a        NVARCHAR2(100),
  ma_thue_a   VARCHAR2(20),
  tkhoan_a    NVARCHAR2(200),
  phone_a     VARCHAR2(30),
  fax_a       VARCHAR2(30),
  ng_huong    NVARCHAR2(1000),
  ng_huong_dc NVARCHAR2(1000),
  hd_kem      VARCHAR2(1),
  ma_nhom     VARCHAR2(10),
  ngay_hl     NUMBER,
  ngay_kt     NUMBER,
  gdinh       VARCHAR2(30),
  cang_di     VARCHAR2(20),
  di_tu       NVARCHAR2(400),
  cang_den    VARCHAR2(20),
  di_den      NVARCHAR2(400),
  ctai        VARCHAR2(1),
  dk_bh       VARCHAR2(200),
  mt_tien     NUMBER,
  mt_pt       NUMBER,
  mt_ktr      VARCHAR2(1),
  mt_chu      NVARCHAR2(400),
  nt_tien     VARCHAR2(5),
  nt_phi      VARCHAR2(5),
  k_phi       VARCHAR2(1),
  pp_tinh     VARCHAR2(10),
  lgia        VARCHAR2(5),
  ty_gia      NUMBER,
  tien_qd     NUMBER,
  ngay_cap    NUMBER,
  nd          NVARCHAR2(2000),
  kieu_gt     VARCHAR2(1),
  ma_gt       VARCHAR2(20),
  nha         VARCHAR2(20),
  tka         VARCHAR2(30),
  ng_mua      VARCHAR2(1),
  so_id_g     NUMBER,
  so_id_d     NUMBER,
  nsd         VARCHAR2(10),
  ttrang      VARCHAR2(1),
  ksoat       VARCHAR2(10),
  ngay_nh     DATE
)
partition by list (MA_DVI)
(
  partition BH_HHGCN_001 values ('001'),
  partition BH_HHGCN_002 values ('002'),
  partition BH_HHGCN_003 values ('003'),
  partition BH_HHGCN_005 values ('005'),
  partition BH_HHGCN_007 values ('007'),
  partition BH_HHGCN_008 values ('008'),
  partition BH_HHGCN_011 values ('011'),
  partition BH_HHGCN_012 values ('012'),
  partition BH_HHGCN_013 values ('013'),
  partition BH_HHGCN_015 values ('015'),
  partition BH_HHGCN_016 values ('016'),
  partition BH_HHGCN_017 values ('017'),
  partition BH_HHGCN_018 values ('018'),
  partition BH_HHGCN_021 values ('021'),
  partition BH_HHGCN_024 values ('024'),
  partition BH_HHGCN_026 values ('026'),
  partition BH_HHGCN_028 values ('028'),
  partition BH_HHGCN_029 values ('029'),
  partition BH_HHGCN_030 values ('030'),
  partition BH_HHGCN_032 values ('032'),
  partition BH_HHGCN_035 values ('035'),
  partition BH_HHGCN_037 values ('037'),
  partition BH_HHGCN_040 values ('040'),
  partition BH_HHGCN_042 values ('042'),
  partition BH_HHGCN_046 values ('046'),
  partition BH_HHGCN_047 values ('047'),
  partition BH_HHGCN_051 values ('051'),
  partition BH_HHGCN_055 values ('055'),
  partition BH_HHGCN_056 values ('056'),
  partition BH_HHGCN_010 values ('010', '020'),
  partition BH_HHGCN_025 values ('025', '027'),
  partition BH_HHGCN_036 values ('036', '039'),
  partition BH_HHGCN_043 values ('043', '045'),
  partition BH_HHGCN_050 values ('050', '052'),
  partition BH_HHGCN_053 values ('053', '058'),
  partition BH_HHGCN_060 values ('060', '061'),
  partition BH_HHGCN_004 values ('004', '006', '009'),
  partition BH_HHGCN_022 values ('022', '023', '031'),
  partition BH_HHGCN_038 values ('038', '041', '044'),
  partition BH_HHGCN_048 values ('048', '049', '057', '064'),
  partition BH_HHGCN_000 values ('000', '019', '033', '034'),
  partition BH_HHGCN_054 values ('054', '059', '062', '063'),
  partition BH_HHGCN_DEFA values (DEFAULT)
);
create index BH_HHGCN_I1 on BH_HHGCN (NGAY_HT);
create index BH_HHGCN_I2 on BH_HHGCN (SO_ID_D);
create index BH_HHGCN_I3 on BH_HHGCN (SO_ID_G);
create unique index BH_HHGCN_U1 on BH_HHGCN (MA_DVI, SO_ID);
create unique index BH_HHGCN_U2 on BH_HHGCN (MA_DVI, SO_HD);

drop table kh_ksoat;
create table kh_ksoat
(
  ma_dvi varchar2(10),
  so_id  number,
  ksoat  varchar2(200),
  idvung number

);
create unique index kh_ksoat_u0 on kh_ksoat(ma_dvi, so_id);

drop table bh_xe_rr;
create table bh_xe_rr
(
  ma_dvi varchar2(10),
  ma     varchar2(10),
  ten    nvarchar2(200),
  nsd    varchar2(10)

);
create unique index bh_xe_rr_u0 on bh_xe_rr(ma_dvi, ma);

drop table bh_hh_ma_nhom;
create table bh_hh_ma_nhom
(
  ma_dvi varchar2(10),
  ma     varchar2(10),
  ten    nvarchar2(200),
  nsd    varchar2(10)

);
create unique index bh_hh_ma_nhom_u0 on bh_hh_ma_nhom(ma_dvi, ma);

drop table bh_nguoi_nhom;
create table bh_nguoi_nhom
(
  ma_dvi  varchar2(10),
  ma      varchar2(10),
  ten     nvarchar2(200),
  nhom    varchar2(1),
  tc      varchar2(1),
  ngay_bd number,
  ngay_kt number,
  ky      number,
  doi     number,
  hnam    number,
  hchuyen number,
  nsd     varchar2(10)

);
create unique index bh_nguoi_nhom_u0 on bh_nguoi_nhom(ma_dvi, ma);

drop table bh_tau_rr;
create table bh_tau_rr
(
  ma_dvi varchar2(10),
  ma     varchar2(10),
  ten    nvarchar2(200),
  nsd    varchar2(10)

);
create unique index bh_tau_rr_u0 on bh_tau_rr(ma_dvi, ma);

drop table bh_pkt_dtuong;
create table bh_pkt_dtuong
(
  ma_dvi varchar2(10),
  ma     varchar2(20),
  ten    nvarchar2(200),
  ma_ct  varchar2(20),
  nsd    varchar2(10)

);
create unique index bh_pkt_dtuong_u0 on bh_pkt_dtuong(ma_dvi, ma);
create index bh_pkt_dtuong_i1 on bh_pkt_dtuong (ma_dvi, ma_ct);

drop table bh_ma_vay;
create table bh_ma_vay
(
  ma_dvi varchar2(10),
  ma     varchar2(10),
  ten    nvarchar2(50),
  nsd    varchar2(10)

);
create unique index bh_ma_vay_u0 on bh_ma_vay(ma_dvi, ma);