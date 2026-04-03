drop table bh_ma_nuoc;
CREATE TABLE bh_ma_nuoc(
    ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    nsd varchar2(10)
);
create unique index bh_ma_nuoc_u0 on bh_ma_nuoc(ma);

drop table bh_ma_kvuc;
create table bh_ma_kvuc
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ma_ct varchar2(20),
    ngay_kt varchar2(20),
    nsd varchar2(10)
);
create unique index bh_ma_kvuc_u0 on bh_ma_kvuc(ma);

drop table kh_ma_kvuc;
create table kh_ma_kvuc
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(200),
  ma_ct   varchar2(20 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kh_ma_kvuc_u0 on kh_ma_kvuc(ma_dvi, ma);
create index kh_ma_kvuc_i1 on kh_ma_kvuc (ma_dvi, ma_ct);

drop table kh_ma_nuoc;
create table kh_ma_nuoc
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(30 byte),
  ten     nvarchar2(100),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kh_ma_nuoc_u0 on kh_ma_nuoc(ma_dvi, ma);

drop table kh_sl_day;
create table kh_sl_day
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(4 byte),
  ngayd   number,
  ngayc   number,
  ngayt   number,
  ngayb   number,
  nsd     varchar2(10 byte),
  kq      varchar2(1 byte),
  loai    varchar2(1 byte),
  idvung  number
);
create unique index kh_sl_day_u0 on kh_sl_day(ma_dvi, ma, loai);

drop table kh_trdoi;
create table kh_trdoi
(
  ma_dvi     varchar2(20 byte),
  so_id      number,
  bt         number,
  nd         nvarchar2(500),
  ma_dvi_nh  varchar2(20 byte),
  gchu       varchar2(100 byte),
  nsd        varchar2(10 byte),
  ngay_nh    date,
  idvung     number);
create index kh_trdoi_i1 on kh_trdoi (ma_dvi, so_id, bt);