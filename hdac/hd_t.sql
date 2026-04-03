drop table HD_SC_BC_SO;
CREATE GLOBAL TEMPORARY TABLE HD_SC_BC_SO
(
  DAU   NUMBER,
  CUOI  NUMBER
)
ON COMMIT DELETE ROWS
NOCACHE;
CREATE INDEX HD_SC_BC_SO_I3 ON HD_SC_BC_SO(DAU, CUOI);

drop table hd_3;
create table hd_3
(
  ma_dvi  varchar2(10),
  so_id   number,
  so_tt   number,
  loai_x  varchar2(2),
  ma_x    varchar2(10),
  loai_n  varchar2(2),
  ma_n    varchar2(20),
  ma      varchar2(20),
  seri    varchar2(10),
  quyen   varchar2(50),
  dau     number,
  cuoi    number,
  gia     number

);
create unique index hd_3_u0 on hd_3(ma_dvi, so_id, so_tt);
create index hd_3_i1 on hd_3 (ma_dvi, so_id);
create index hd_3_i2 on hd_3 (ma_dvi, loai_x, ma, ma_x);
create index hd_3_i4 on hd_3 (ma_dvi, so_id, ma, seri, dau, cuoi);

drop table hd_2;
create table hd_2
(
  ma_dvi  varchar2(10),
  so_id   number,
  so_tt   number,
  ma      varchar2(20),
  seri    varchar2(10),
  quyen   varchar2(50),
  dau     number,
  cuoi    number,
  ma_tke  varchar2(5),
  gia     number

);
create unique index hd_2_u0 on hd_2(ma_dvi, so_id, so_tt);
create index hd_2_i1 on hd_2 (ma_dvi, so_id);
create index hd_2_i4 on hd_2 (ma_dvi, so_id, ma, seri, dau, cuoi);

drop table hd_sc;
create table hd_sc
(
  ma_dvi   varchar2(10),
  loai_bp  varchar2(2),
  ma_bp    varchar2(20),
  ma       varchar2(20),
  seri     varchar2(10),
  dau      number,
  cuoi     number,
  thang    number

);
create unique index hd_sc_u0 on hd_sc(ma_dvi, thang, loai_bp, ma_bp, ma, seri, dau);
create index hd_sc_i1 on hd_sc (ma_dvi, loai_bp, ma_bp);
create index hd_sc_i2 on hd_sc (ma, seri, dau);

drop table hd_1;
create table hd_1
(
  ma_dvi    varchar2(10),
  so_id     number,
  so_id_bh  number,
  ngay_ht   number,
  l_ct      varchar2(1),
  so_ct     varchar2(20),
  ngay_ct   date,
  ma_cc     varchar2(10),
  loai_n    varchar2(2),
  ma_n      varchar2(20),
  nd        nvarchar2(400),
  htoan     varchar2(1),
  ngay_nh   date,
  nsd       varchar2(10)

);
create unique index hd_1_u0 on hd_1(ma_dvi, so_id);
create index hd_1_i1 on hd_1 (ma_dvi, so_id_bh);

drop table hd_ma_hd;
create table hd_ma_hd
(
  ma_dvi   varchar2(10),
  ma       varchar2(20),
  mau      varchar2(20),
  ma_nhom  varchar2(20),
  nv       varchar2(20),
  ten      nvarchar2(50),
  do_dai   number,
  so_lien  number,
  so_to    number,
  nsd      varchar2(10)

);
create unique index hd_ma_hd_u0 on hd_ma_hd(ma_dvi, ma);

drop table hd_ma_qly;
create table hd_ma_qly
(
  ma_dvi   varchar2(10),
  ma_qly   varchar2(1),
  nsd      varchar2(10),
  ngay_nh  date

);
create unique index hd_ma_qly_u0 on hd_ma_qly(ma_dvi, ma_qly);

drop table hd_ma_nhom;
create table hd_ma_nhom
(
  ma_dvi varchar2(10),
  ma     varchar2(10),
  ten    nvarchar2(50),
  nsd    varchar2(10)

);
create unique index hd_ma_nhom_u0 on hd_ma_nhom(ma_dvi, ma);

drop table hd_sc_ton;
create table hd_sc_ton
(
  ma_dvi  varchar2(10),
  loai_bp varchar2(2),
  ma_bp   varchar2(10),
  ma      varchar2(20),
  seri    varchar2(10),
  dau     number,
  cuoi    number

);
create unique index hd_sc_ton_u0 on hd_sc_ton(ma_dvi, ma, seri, dau);
create index hd_sc_ton_i1 on hd_sc_ton (ma, seri, dau);

drop table cc_sc;
create table cc_sc
(
  ma_dvi    varchar2(20),
  so_id     number,
  so_the    varchar2(20),
  so_ct_ht  varchar2(20),
  ngay_ht   date,
  nhom      varchar2(5),
  ma_vt     varchar2(30),
  ten       nvarchar2(200),
  dac_ta    nvarchar2(200),
  ma_tk     varchar2(10),
  luong     number,
  ma_nt     varchar2(5),
  gia       number,
  von       number,
  so_ct_kt  varchar2(20),
  ngay_kt   date,
  ma_nt_thu varchar2(5),
  thu       number,
  nd        nvarchar2(400),
  nsd       varchar2(10),
  so_id_vt  number,
  idvung    number

);
create unique index cc_sc_u0 on cc_sc(ma_dvi, so_id);
create unique index cc_sc_i1 on cc_sc (ma_dvi, so_the);
create index cc_sc_i2 on cc_sc (ma_dvi, ngay_ht);
create index cc_sc_i3 on cc_sc (ma_dvi, ngay_kt);
create index cc_sc_i4 on cc_sc (ma_dvi, so_id_vt);

drop table vt_ma_vt;
create table vt_ma_vt
(
  ma_dvi varchar2(20),
  nhom   varchar2(5),
  ma     varchar2(30),
  ma_phu varchar2(30),
  ten    nvarchar2(200),
  dvi    nvarchar2(20),
  pp     varchar2(1),
  pb     varchar2(1),
  ma_ts  varchar2(10),
  kieu   varchar2(3),
  han    number,
  du_tru number,
  d_muc  varchar2(1),
  dai    number,
  rong   number,
  cao    number,
  gia_pp varchar2(1),
  sc_pp  varchar2(1),
  ma_ct  varchar2(30),
  nsd    varchar2(10),
  idvung number,
  so_id  number

);
create unique index vt_ma_vt_u0 on vt_ma_vt(ma_dvi, nhom, ma);
create index vt_ma_vt_i1 on vt_ma_vt (ma_dvi, ma_ct);
create index vt_ma_vt_i2 on vt_ma_vt (ma_dvi, so_id);

drop table cc_ch;
create table cc_ch
(
  ma_dvi varchar2(20),
  so_id  number,
  ngay   date,
  tien   number,
  nd     nvarchar2(200),
  idvung number

);
create unique index cc_ch_u0 on cc_ch(ma_dvi, so_id, ngay);

drop table cc_du;
create table cc_du
(
  ma_dvi varchar2(20),
  so_id  number,
  ngayd  date,
  ngayc  date,
  nd     nvarchar2(200),
  idvung number

);
create unique index cc_du_u0 on cc_du(ma_dvi, so_id, ngayd);

drop table cc_bd;
create table cc_bd
(
  ma_dvi varchar2(20),
  so_id  number,
  ngay   date,
  tien   number,
  nd     nvarchar2(200),
  idvung number

);
create unique index cc_bd_u0 on cc_bd(ma_dvi, so_id, ngay);

drop table hd_sc_bc cascade constraints;
create global temporary table hd_sc_bc
(
  ma    varchar2(20 byte),
  seri  varchar2(10 byte),
  dau   number,
  cuoi  number
)
on commit delete rows nocache;
create index hd_sc_bc_i3 on hd_sc_bc (ma, seri, dau, cuoi);
