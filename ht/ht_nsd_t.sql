drop table hta_ma_nsd;
create table hta_ma_nsd
(
  ma_dvi     varchar2(20),
  ma         varchar2(30),
  ten        nvarchar2(100),
  pas        varchar2(20),
  phong      varchar2(20),
  ma_dvi_ql  varchar2(20),
  nsd        varchar2(10),
  ma_login   varchar2(50),
  idvung     number

);
create unique index hta_ma_nsd_u0 on hta_ma_nsd(ma_dvi, ma);
create index hta_ma_nsd_u on hta_ma_nsd (ma_login);

drop table hta_login;
create table hta_login
(
  ma      varchar2(50),
  pas     varchar2(20),
  idvung  number,
  qu      varchar2(1),
  tgian   date,
  nloi    number

);
create unique index hta_login_u0 on hta_login(ma);

drop table ht_ma_nsd_nv;
create table ht_ma_nsd_nv
(
  ma_dvi  varchar2(20),
  ma      varchar2(10),
  md      varchar2(10),
  nv      varchar2(10),
  tc      varchar2(10),
  idvung  number
);

drop table ht_ma_nsd_nhom;
create table ht_ma_nsd_nhom
(
  ma_dvi  varchar2(20),
  ma      varchar2(10),
  md      varchar2(10),
  nhom    varchar2(10),
  idvung  number
);

drop table ht_ma_nhom_nv;
create table ht_ma_nhom_nv
(
  ma_dvi  varchar2(20),
  md      varchar2(10),
  ma      varchar2(10),
  nv      varchar2(10),
  tc      varchar2(10),
  idvung  number
);

drop table ht_login;
create table ht_login
(
  ma      varchar2(50),
  pas     varchar2(20),
  idvung  number,
  qu      varchar2(1),
  tgian   date,
  nloi    number
);
create unique index ht_login_u0 on ht_login(ma);

drop table ht_ma_dvi;
create table ht_ma_dvi
(
  ma         varchar2(20),
  cap        varchar2(1),
  ten        nvarchar2(100),
  ten_gon    nvarchar2(100),
  dchi       nvarchar2(100),
  ma_thue    varchar2(30),
  g_doc      nvarchar2(60),
  ktt        nvarchar2(60),
  ten_sv     varchar2(50),
  ten_db     varchar2(50),
  ten_dbo    varchar2(50),
  ip         varchar2(50),
  ma_tk      varchar2(20),
  nhang      varchar2(10),
  kvuc       varchar2(10),
  ma_ct      varchar2(20),
  pas_di     varchar2(10),
  pas_den    varchar2(10),
  tt_hd      varchar2(1),
  loai       varchar2(1),
  vp         varchar2(1),
  ngay_bd    number,
  ngay_kt    number,
  nsd        varchar2(10),
  idvung     number,
  ma_goc     varchar2(20),
  ma_ct_goc  varchar2(20),
  tdx        number                             default 0,
  tdy        number                             default 0
);

drop table ht_ma_nsd;
create table ht_ma_nsd
(
  ma_dvi    varchar2(20),
  ma        varchar2(10),
  ten       nvarchar2(100),
  pas       varchar2(20),
  phong     varchar2(20),
  nsd       varchar2(10),
  ma_login  varchar2(50),
  idvung    number

);
create unique index ht_ma_nsd_u0 on ht_ma_nsd(ma_dvi,ma);

drop table hta_ma_nsd_nv;
create table hta_ma_nsd_nv
(
  ma_dvi  varchar2(20),
  ma      varchar2(30),
  md      varchar2(10),
  nv      varchar2(10),
  tc      varchar2(10),
  idvung  number

);
create unique index hta_ma_nsd_nv_u0 on hta_ma_nsd_nv(ma_dvi, ma, md, nv);

drop table hta_ma_nsd_nhom;
create table hta_ma_nsd_nhom
(
  ma_dvi  varchar2(20),
  ma      varchar2(10),
  md      varchar2(10),
  nhom    varchar2(10),
  idvung  number

);
create unique index hta_ma_nsd_nhom_u0 on hta_ma_nsd_nhom(ma_dvi, ma, md, nhom);

drop table kh_nsd_du;
create table kh_nsd_du
(
  ma_dvi  varchar2(20),
  nsd     varchar2(20),
  md      varchar2(10),
  nv      varchar2(50),
  ma      varchar2(50),
  ten     nvarchar2(400),
  dan     nvarchar2(2000),
  idvung  number
);
create index kh_nsd_du_i1 on kh_nsd_du(ma_dvi, nsd, md, nv);

drop table ht_ma_nsd_qly;
create table ht_ma_nsd_qly
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(10 byte),
  md      varchar2(10 byte),
  dvi     varchar2(10 byte),
  idvung  number
);