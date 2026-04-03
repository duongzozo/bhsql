

drop table ht_manv;
create table ht_manv
    (md varchar2(10),
    nv nvarchar2(10),
    ten varchar2(100));

drop table ht_ma_cvu_txt;
create table ht_ma_cvu_txt
    (ma varchar2(10),
    txt clob);

drop table ht_ma_dvi_txt;
create table ht_ma_dvi_txt
    (ma varchar2(20),
    txt clob);

drop table ht_ma_phong_txt;
create table ht_ma_phong_txt
    (ma_dvi varchar(20),
    ma varchar2(10),
    txt clob);

drop table ht_ma_cb_txt;
create table ht_ma_cb_txt
    (ma_dvi varchar(20),
    ma varchar2(10),
    txt clob);

drop table ht_ma_nsd_txt;
create table ht_ma_nsd_txt
    (ma varchar2(10),
    ma_dvi varchar(20),
    txt clob);

/* viet anh -- thong ke thoi gian he thong */

drop table ht_tso_hd;
create table ht_tso_hd
    (ma varchar2(10),
    ten nvarchar2(500),
    tgian number
);
create unique index ht_tso_hd_u0 on ht_tso_hd(ma);

drop table ht_idm;
create table ht_idm
(
  ngay   number,
  so_id  number
);

drop table ht_ma_cb;
create table ht_ma_cb
(
  ma_dvi  varchar2(20),
  ma      varchar2(10),
  ten     nvarchar2(50),
  so_cmt  varchar2(30),
  phong   varchar2(10),
  cv      nvarchar2(50),
  ma_tk   varchar2(30),
  nhang   varchar2(20),
  ten_nh  nvarchar2(200),
  mobi    varchar2(20),
  mail    varchar2(20),
  nsd     varchar2(10),
  idvung  number
);

drop table kh_ma_han;
create table kh_ma_han
(
  ma_dvi   varchar2(20),
  md       varchar2(10),
  ma_cd    varchar2(10),
  nv       varchar2(10),
  ma_nsd   varchar2(20),
  ngay     number,
  lydo     nvarchar2(1000),
  ngay_ht  date,
  nsd      varchar2(20),
  idvung   number
);

drop table kh_nv_tso;
create table kh_nv_tso
(
  ma_dvi  varchar2(20),
  nsd     varchar2(20),
  md      varchar2(10),
  nv      varchar2(50),
  ma      varchar2(50),
  tso     varchar2(200),
  idvung  number
);
create index kh_nv_tso_i1 on kh_nv_tso(ma_dvi, md, nv, ma);

drop table tt_tgtt;
create table tt_tgtt
(
  ma_dvi  varchar2(20),
  ma      varchar2(5),
  ngay    date,
  ty_gia  number,
  nsd     varchar2(10),
  idvung  number

);
create unique index tt_tgtt_u0 on tt_tgtt(ma_dvi, ma, ngay);

drop table tt_ma_nt;
create table tt_ma_nt
(
  ma_dvi  varchar2(20),
  ma      varchar2(5),
  ten     nvarchar2(30),
  ten_xu  nvarchar2(30),
  tc      varchar2(1),
  nsd     varchar2(10),
  idvung  number

);
create unique index tt_ma_nt_u0 on tt_ma_nt(ma_dvi, ma);
create index tt_ma_nt_i1 on tt_ma_nt(ma_dvi, tc);

drop table ht_dns;
create table ht_dns
(
  idvung  number,
  md      varchar2(20),
  ip      varchar2(50),
  port    varchar2(10),
  db      varchar2(50),
  loai    varchar2(10),
  dbo     varchar2(50),
  nsd     varchar2(50),
  pas     varchar2(50),
  sv      varchar2(30)
);

drop table kh_nsd_tso;
create table kh_nsd_tso
(
  ma_dvi  varchar2(20),
  nsd     varchar2(20),
  md      varchar2(10),
  ma      varchar2(20),
  tso     varchar2(100),
  idvung  number
);
create index kh_nsd_tso_i1 on kh_nsd_tso (ma_dvi, nsd, md);

drop table ht_ma_phong;
create table ht_ma_phong
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(10 byte),
  ten     nvarchar2(100),
  nhom    varchar2(1 byte),
  pnhan   varchar2(1 byte),
  ma_ct   varchar2(10 byte),
  nsd     varchar2(10 byte),
  idvung  number
);

drop table ht_ma_cvu;
create table ht_ma_cvu
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(10 byte),
  ten     nvarchar2(200),
  ma_ct   varchar2(100 byte),
  nsd     varchar2(10 byte),
  idvung  number
);

drop table ht_ma_nhom;
create table ht_ma_nhom
(
  ma_dvi  varchar2(20 byte),
  md      varchar2(10 byte),
  ma      varchar2(10 byte),
  ten     nvarchar2(100),
  nsd     varchar2(10 byte),
  idvung  number
);

drop table kh_ma_han_log;
create table kh_ma_han_log
(
  ngay_nh  date,
  ma_dvi   varchar2(20 byte),
  md       varchar2(10 byte),
  ma_cd    varchar2(10 byte),
  nv       varchar2(10 byte),
  ma_nsd   varchar2(20 byte),
  ngay     number,
  lydo     nvarchar2(1000),
  ngay_ht  date,
  nsd      varchar2(20 byte),
  idvung   number
);
create index kh_ma_han_log_u1 on kh_ma_han_log(ngay_nh, ma_dvi);