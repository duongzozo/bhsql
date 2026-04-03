-- viet anh -- them table thieu

drop table bh_nggcn_ba;
create table bh_nggcn_ba
(
  ma_dvi    varchar2(10) not null,
  so_id     number not null,
  ngay_ht   number,
  ma_dl     varchar2(20),
  phong     varchar2(10),
  gcn_m     varchar2(20),
  gcn_c     varchar2(10),
  gcn_s     varchar2(20),
  gcn       varchar2(50),
  kieu_hd   varchar2(1),
  gcn_m_g   varchar2(20),
  gcn_c_g   varchar2(10),
  gcn_s_g   varchar2(20),
  gcn_g     varchar2(50),
  ten       nvarchar2(50),
  dchi      nvarchar2(200),
  nam_sinh  number,
  so_cmt    varchar2(20),
  dk_bs     varchar2(20),
  nt_tien   varchar2(5),
  tien      number,
  nt_phi    varchar2(5),
  phi       number,
  pphi      number,
  ttoan     number,
  ttoan_qd  number,
  nt_chenh  varchar2(5),
  chenh     number,
  chenh_qd  number,
  ng_huong  nvarchar2(2000),
  ngay_hl   number,
  ngay_kt   number,
  ngay_cap  number,
  mau       varchar2(20),
  seri      varchar2(10),
  so_don    varchar2(20),
  don       varchar2(50),
  hd_vay    nvarchar2(30),
  nt_vay    varchar2(5),
  tien_vay  number,
  han_vay   number,
  mdich_vay varchar2(10),
  tdoi      nvarchar2(2000),
  nd        nvarchar2(2000),
  ngay_nh   date,
  so_id_g   number,
  so_id_d   number,
  so_id_kt  number,
  ksoat     varchar2(10),
  so_id_qt  number,
  nsd       varchar2(10)

);
create unique index bh_nggcn_ba_u0 on bh_nggcn_ba(ma_dvi, so_id);
create index bh_nggcn_ba_i1 on bh_nggcn_ba (ma_dvi, ngay_ht, ma_dl);
create index bh_nggcn_ba_i2 on bh_nggcn_ba (ma_dvi, so_id_kt);
create index bh_nggcn_ba_i3 on bh_nggcn_ba (ma_dvi, so_id_qt);
create index bh_nggcn_ba_i4 on bh_nggcn_ba (ma_dvi, don);
create unique index bh_nggcn_ba_u on bh_nggcn_ba (ma_dvi, gcn);