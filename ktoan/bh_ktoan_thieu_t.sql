drop table kt_pb;
create table kt_pb
(
  ma_dvi  varchar2(20 byte),
  ngay    number,
  ma_tk   varchar2(20 byte),
  ma_tke  varchar2(20 byte),
  nhom    varchar2(1 byte),
  kieu    varchar2(1 byte),
  nv      varchar2(1 byte),
  phong   varchar2(20 byte),
  sp      varchar2(20 byte),
  pt      number,
  nsd     varchar2(10 byte),
  bt      number,
  idvung  number
);
create unique index kt_pb_u0 on kt_pb(ma_dvi, ngay, ma_tk, ma_tke, bt);

drop table kt_sp;
create table kt_sp
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  bt       number,
  ngay_ht  number,
  ma_sp    varchar2(10 byte),
  tien     number
);
create unique index kt_sp_u0 on kt_sp(ma_dvi, so_id, bt, ma_sp);
create index kt_sp_i1 on kt_sp (ma_dvi, ngay_ht, ma_sp);

drop table kh_pbo;
create table kh_pbo
(
  ma_dvi  varchar2(20 byte),
  ngay    number,
  ma_tk   varchar2(20 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kh_pbo_u0 on kh_pbo(ma_dvi, ngay, ma_tk);

drop table kh_pbo_sp;
create table kh_pbo_sp
(
  ma_dvi  varchar2(20 byte),
  ngay    number,
  ma_tk   varchar2(20 byte),
  ma_sp   varchar2(10 byte),
  idvung  number
);
create unique index kh_pbo_sp_u0 on kh_pbo_sp(ma_dvi, ngay, ma_tk, ma_sp);

drop table kt_bp;
create table kt_bp
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  bt       number,
  ngay_ht  number,
  nhom     varchar2(10 byte),
  ma_ttr   varchar2(10 byte),
  ma_lvuc  varchar2(10 byte),
  dvi      varchar2(20 byte),
  phong    varchar2(10 byte),
  ma_cb    varchar2(10 byte),
  viec     varchar2(20 byte),
  hdong    varchar2(20 byte),
  ma_sp    varchar2(20 byte),
  tien     number,
  bt_phu   number,
  idvung   number
);
create unique index kt_bp_u0 on kt_bp(ma_dvi, so_id, bt, bt_phu);
create index kt_bp_i1 on kt_bp (ma_dvi, ngay_ht);
create index kt_bp_i2 on kt_bp (ma_dvi, hdong);

drop table kt_lc;
create table kt_lc
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  bt       number,
  ngay_ht  number,
  nv       varchar2(1 byte),
  ma_lc    varchar2(10 byte),
  tien     number,
  nsd      varchar2(10 byte),
  idvung   number
);
create unique index kt_lc_u0 on kt_lc(ma_dvi, so_id, bt);
create index kt_lc_i1 on kt_lc (ma_dvi, ngay_ht);

drop table cn_ps;
create table cn_ps
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  bt       number,
  nd       nvarchar2(400),
  l_ct     varchar2(1 byte),
  ma_cn    varchar2(31 byte),
  ma_nt    varchar2(5 byte),
  ma_tk    varchar2(20 byte),
  viec     varchar2(20 byte),
  hdong    varchar2(20 byte),
  ma_ctr   varchar2(30 byte),
  tien     number,
  tra      number,
  tien_qd  number,
  tra_qd   number,
  ngay_ht  number,
  idvung   number
);
create unique index cn_ps_u0 on cn_ps(ma_dvi, so_id, bt);
create index cn_ps_i1 on cn_ps (ma_dvi, ngay_ht, tien-tra desc, l_ct, ma_cn,  ma_nt, ma_tk);

drop table vt_1;
create table vt_1
(
  ma_dvi     varchar2(20 byte),
  so_id      number,
  ngay_ht    number,
  l_ct       varchar2(1 byte),
  so_tt      varchar2(20 byte),
  so_ct      varchar2(20 byte),
  ngay_ct    varchar2(10 byte),
  hdongm     varchar2(20 byte),
  hdongb     varchar2(20 byte),
  viec       varchar2(20 byte),
  nvien      varchar2(10 byte),
  k_tc       varchar2(1 byte),
  so_tt_tc   varchar2(20 byte),
  lenh       varchar2(30 byte),
  so_kn      varchar2(30 byte),
  nd         nvarchar2(400),
  ndp        nvarchar2(400),
  k_ma_kh    varchar2(1 byte),
  ma_kh      varchar2(20 byte),
  ten        nvarchar2(200),
  dchi       nvarchar2(200),
  ma_thue    varchar2(30 byte),
  gchu       varchar2(200 byte),
  l_gia      varchar2(20 byte),
  ma_nt      varchar2(5 byte),
  tg_tt      number,
  ht_ttoan   varchar2(1 byte),
  nh_khau    varchar2(1 byte),
  nh_ts      varchar2(1 byte),
  tl_ggia    number,
  ggia       number,
  vchuyen    number,
  gvon       number,
  loai       varchar2(1 byte),
  pp         varchar2(1 byte),
  t_suat     number,
  thue       number,
  mau        varchar2(20 byte),
  seri       varchar2(10 byte),
  so_hd      varchar2(20 byte),
  ngay_hd    varchar2(10 byte),
  tl_hhong   number,
  hhong      number,
  t_suat_dl  number,
  thue_dl    number,
  tien       number,
  tien_tt    number,
  nsd        varchar2(10 byte),
  htoan      varchar2(1 byte),
  md         varchar2(2 byte),
  ngay_nh    date,
  ksoat      varchar2(10 byte),
  so_id_hd   number,
  idvung     number
);
create unique index vt_1_u0 on vt_1(ma_dvi, so_id);

create index vt_1_i1 on vt_1 (ma_dvi, ngay_ht, l_ct);
create index vt_1_i2 on vt_1 (ma_dvi, lenh, l_ct);
create index vt_1_i3 on vt_1 (ma_dvi, so_tt);
create index vt_1_i4 on vt_1 (ma_dvi, so_tt_tc);
create index vt_1_i5 on vt_1 (ma_dvi, so_id_hd, ngay_ht);

drop table vt_2;
create table vt_2
(
  ma_dvi     varchar2(20 byte),
  so_id      number,
  bt         number,
  ngay_ht    number,
  kho        varchar2(10 byte),
  kho_m      varchar2(10 byte),
  gkho       varchar2(1 byte),
  tao_the    varchar2(1 byte),
  loai_vt    varchar2(1 byte),
  nhom       varchar2(10 byte),
  ma_vt      varchar2(30 byte),
  nuoc       varchar2(10 byte),
  model      varchar2(50 byte),
  lo         varchar2(50 byte),
  dv         nvarchar2(20),
  cl         varchar2(10 byte),
  dai        number,
  rong       number,
  cao        number,
  luong      number,
  luong_p1   number,
  luong_p2   number,
  gia        number,
  gia_qd     number,
  so_tien    number,
  tl_tnk     number,
  tnk        number,
  tnk_qd     number,
  tl_tdb     number,
  tdb        number,
  tdb_qd     number,
  tl_tkh     number,
  tkh        number,
  tkh_qd     number,
  phi        number,
  tien       number,
  thue       number,
  von        number,
  ma_nt_g    varchar2(5 byte),
  gia_g      number,
  von_g      number,
  nd         nvarchar2(200),
  ct_loai    varchar2(1 byte),
  ct_pp      varchar2(1 byte),
  ct_t_suat  number,
  ct_thue    number,
  hdongmc    varchar2(20 byte),
  hdongbc    varchar2(20 byte),
  cviec      varchar2(20 byte),
  cnvien     varchar2(10 byte),
  vontb      varchar2(1 byte)                   default 'k',
  lay_von    varchar2(1 byte)                   default 'c',
  idvung     number
);
create unique index vt_2_u0 on vt_2(ma_dvi, so_id, bt);
create index vt_2_i1 on vt_2 (ma_dvi, ngay_ht);

drop table tt_1;
create table tt_1
(
  ma_dvi    varchar2(20 byte),
  so_id     number,
  ngay_ht   number,
  l_ct      varchar2(5 byte),
  so_tt     number,
  so_ph     varchar2(20 byte),
  ngay_ct   varchar2(10 byte),
  nhom      varchar2(10 byte),
  viec      varchar2(20 byte),
  hdong     varchar2(20 byte),
  nvien     varchar2(10 byte),
  nd        nvarchar2(400),
  ndp       nvarchar2(400),
  so_ct     varchar2(200 byte),
  k_ma_kh   varchar2(1 byte),
  ma_kh     varchar2(20 byte),
  ten       nvarchar2(200),
  nguoi_gd  nvarchar2(200),
  cmt       varchar2(20 byte),
  phong     varchar2(10 byte),
  d_chi     nvarchar2(200),
  ma_thue   varchar2(20 byte),
  nhb       varchar2(10 byte),
  tk_nhb    varchar2(20 byte),
  ten_nhb   nvarchar2(200),
  ma_nt_t   varchar2(5 byte),
  ma_tke_t  varchar2(10 byte),
  tien_t    number,
  tg_ht_t   number,
  tg_tt_t   number,
  noi_te_t  number,
  nha_t     varchar2(10 byte),
  tk_nha_t  varchar2(20 byte),
  ma_nt_c   varchar2(5 byte),
  ma_tke_c  varchar2(10 byte),
  tien_c    number,
  tg_ht_c   number,
  tg_tt_c   number,
  noi_te_c  number,
  nha_c     varchar2(10 byte),
  tk_nha_c  varchar2(20 byte),
  loai      varchar2(1 byte),
  pp        varchar2(1 byte),
  t_suat    number,
  thue      number,
  mau       varchar2(20 byte),
  seri      varchar2(10 byte),
  so_hd     varchar2(20 byte),
  nsd       varchar2(10 byte),
  htoan     varchar2(1 byte),
  md        varchar2(2 byte),
  ngay_nh   date,
  ksoat     varchar2(10 byte),
  idvung    number
);
create unique index tt_1_u0 on tt_1(ma_dvi, so_id);
create index tt_1_i1 on tt_1 (ma_dvi, ngay_ht, l_ct, so_tt);
create index tt_1_i2 on tt_1 (ma_dvi, l_ct, so_id);
create index tt_1_i3 on tt_1 (ma_dvi, ngay_ht, nhom, so_tt);

drop table tv_1;
create table tv_1
(
  ma_dvi     varchar2(20 byte),
  so_id      number,
  l_ct       varchar2(5 byte),
  ngay_ht    number,
  ngay_bc    number,
  ma_nt      varchar2(5 byte),
  tg_ht      number,
  tg_tt      number,
  thue       number,
  t_toan     number,
  thue_qd    number,
  t_toan_qd  number,
  nsd        varchar2(10 byte),
  htoan      varchar2(1 byte),
  md         varchar2(2 byte),
  ngay_nh    date,
  idvung     number
);
create unique index tv_1_u0 on tv_1(ma_dvi, so_id);
create index tv_1_i1 on tv_1 (ma_dvi, ngay_ht);

drop table tv_2;
create table tv_2
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  ngay_ht  number,
  mau      varchar2(20 byte),
  seri     varchar2(10 byte),
  so_hd    varchar2(20 byte),
  so_phu   varchar2(1 byte),
  kieu     varchar2(1 byte),
  lay      varchar2(1 byte),
  hoan     varchar2(1 byte),
  ma_hd    varchar2(20 byte),
  nhom     varchar2(5 byte),
  ngay_ct  varchar2(10 byte),
  k_ma_kh  varchar2(1 byte),
  ma_kh    varchar2(20 byte),
  ten      nvarchar2(400),
  dchi     nvarchar2(400),
  ma_thue  varchar2(20 byte),
  nd       nvarchar2(400),
  tien     number,
  loai     varchar2(1 byte),
  pp       varchar2(1 byte),
  t_suat   number,
  thue     number,
  t_toan   number,
  ma_tk    varchar2(20 byte),
  ma_tke   varchar2(10 byte),
  ma_ctr   varchar2(20 byte),
  bt       number,
  idvung   number
);
create unique index tv_2_u0 on tv_2(ma_dvi, so_id, bt);
create index tv_2_i1 on tv_2 (ma_dvi, ngay_ht);
create index tv_2_i2 on tv_2 (ma_dvi, mau, seri, so_hd, so_phu);

drop table xl_1;
create table xl_1
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  ngay_ht  number,
  l_ct     varchar2(2 byte),
  so_ct    varchar2(20 byte),
  ngay_ct  varchar2(10 byte),
  ma_nt    varchar2(5 byte),
  tg_tt    number,
  k_ma_kh  varchar2(1 byte),
  ma_kh    varchar2(20 byte),
  loai     varchar2(1 byte),
  pp       varchar2(1 byte),
  t_suat   number,
  thue     number,
  mau      varchar2(20 byte),
  seri     varchar2(10 byte),
  so_hd    varchar2(20 byte),
  nd       nvarchar2(400),
  ndp      nvarchar2(400),
  tien     number,
  tien_qd  number,
  nsd      varchar2(10 byte),
  htoan    varchar2(1 byte),
  md       varchar2(2 byte),
  idvung   number
);
create unique index xl_1_u0 on xl_1(ma_dvi, so_id);
create index xl_1_i1 on xl_1 (ma_dvi, ngay_ht, nsd);

drop table cn_tk;
create table cn_tk
(
  ma_dvi  varchar2(20 byte),
  ngay    number,
  ma      varchar2(10 byte),
  ten     nvarchar2(200),
  loai    varchar2(1 byte),
  ma_tk   varchar2(20 byte),
  nsd     varchar2(10 byte),
  bt      number,
  idvung  number
);
create unique index cn_tk_u0 on cn_tk(ma_dvi, ngay, ma);
create index cn_tk_i1 on cn_tk (ma_dvi, ngay, ma_tk);

drop table dp_ct;
create table dp_ct
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  ngay_ht  number,
  l_ct     varchar2(2 byte),
  nhom     varchar2(5 byte),
  so_ct    varchar2(20 byte),
  ngay_ct  varchar2(10 byte),
  tien     number,
  nd       nvarchar2(400),
  ndp      nvarchar2(400),
  nsd      varchar2(10 byte),
  htoan    varchar2(1 byte),
  md       varchar2(2 byte),
  ngay_nh  date,
  idvung   number
);
create unique index dp_ct_u0 on dp_ct(ma_dvi, so_id);

drop table dp_cn;
create table dp_cn
(
  ma_dvi    varchar2(20 byte),
  so_id     number,
  so_id_ps  number,
  bt_ps     number,
  ton       number,
  da_dp     number,
  tien      number,
  bt        number,
  idvung    number
);
create unique index dp_cn_u0 on dp_cn(ma_dvi, so_id, bt);
create index dp_cn_i1 on dp_cn (ma_dvi, so_id_ps);

drop table cn_ton_temp;
create global temporary table cn_ton_temp
(
  so_id_ps  number,
  bt_ps     number,
  ngay_ht   number,
  so_ct     varchar2(20 byte),
  tien      number,
  tien_qd   number,
  phi       number,
  phi_qd    number,
  nd        nvarchar2(400)
)
on commit preserve rows nocache;

drop table cn_ct;
create table cn_ct
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  bt       number,
  ngay_ht  number,
  l_ct     varchar2(1 byte),
  loai     varchar2(1 byte),
  ma_cn    varchar2(31 byte),
  ma_nt    varchar2(5 byte),
  ma_tk    varchar2(20 byte),
  viec     varchar2(20 byte),
  hdong    varchar2(20 byte),
  ma_ctr   varchar2(30 byte),
  ct_th    nvarchar2(400),
  tien     number,
  ty_gia   number,
  tien_qd  number,
  han      number,
  idvung   number
);
create unique index cn_ct_u0 on cn_ct(ma_dvi, so_id, bt);
create index cn_ct_i1 on cn_ct (ma_dvi, ngay_ht);

drop table cn_ch;
create table cn_ch
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  ngay_ht  number,
  so_ct    varchar2(25 byte),
  ngay_ct  varchar2(10 byte),
  nhom     varchar2(10 byte),
  tien     number,
  loai     varchar2(1 byte),
  pp       varchar2(1 byte),
  t_suat   number,
  thue     number,
  mau      varchar2(20 byte),
  seri     varchar2(10 byte),
  so_hd    varchar2(20 byte),
  nd       nvarchar2(400),
  ndp      nvarchar2(400),
  nsd      varchar2(20 byte),
  htoan    varchar2(1 byte),
  md       varchar2(2 byte),
  ngay_nh  date,
  idvung   number
);
create unique index cn_ch_u0 on cn_ch(ma_dvi, so_id);
create index cn_ch_i1 on cn_ch (ma_dvi, ngay_ht);

drop table cn_tt;
create table cn_tt
(
  ma_dvi    varchar2(20 byte),
  so_id     number,
  bt        number,
  bt_tt     number,
  l_ct      varchar2(1 byte),
  loai      varchar2(1 byte),
  so_id_ps  number,
  bt_ps     number,
  tien      number,
  tien_qd   number,
  phi       number,
  phi_qd    number,
  ngay_ht   number,
  idvung    number
);
create unique index cn_tt_u0 on cn_tt(ma_dvi, so_id, bt);
create index cn_tt_i1 on cn_tt (ma_dvi, ngay_ht);
create index cn_tt_ilk on cn_tt (ma_dvi, so_id_ps, bt_ps, loai);

drop table cn_ls;
create table cn_ls
(
  ma_dvi  varchar2(20 byte),
  so_id   number,
  bt      number,
  ppt     varchar2(1 byte),
  ngay    number,
  tien    number,
  ls      number,
  idvung  number
);
create unique index cn_ls_u0 on cn_ls(ma_dvi, so_id, bt, ngay);

drop table cn_ma_kh;
create table cn_ma_kh
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(400),
  ten_e   varchar2(200 byte),
  ten_t   varchar2(200 byte),
  dchi    nvarchar2(400),
  tax     varchar2(30 byte),
  nhang   varchar2(10 byte),
  ma_tk   varchar2(50 byte),
  ten_nh  nvarchar2(200),
  loai    varchar2(5 byte),
  kvuc    varchar2(10 byte),
  phone   varchar2(20 byte),
  fax     varchar2(20 byte),
  ngay_d  date,
  ngay_c  date,
  ma_ct   varchar2(20 byte),
  nhom    varchar2(1 byte),
  cit     number,
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index cn_ma_kh_u0 on cn_ma_kh(ma_dvi, ma);
create index cn_ma_kh_i1 on cn_ma_kh (ma_dvi, ma_ct);
create index cn_ma_kh_i2 on cn_ma_kh (ma_dvi, tax);
create index cn_ma_kh_i3 on cn_ma_kh (ma_dvi, nhom);

drop table cn_ma_dl;
create table cn_ma_dl
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(200),
  ten_e   varchar2(200 byte),
  ten_t   varchar2(200 byte),
  dchi    nvarchar2(200),
  tax     varchar2(30 byte),
  nhang   varchar2(10 byte),
  ma_tk   varchar2(50 byte),
  ten_nh  nvarchar2(200),
  loai    varchar2(5 byte),
  kvuc    varchar2(10 byte),
  phone   varchar2(20 byte),
  fax     varchar2(20 byte),
  ngay_d  date,
  ngay_c  date,
  ma_ct   varchar2(20 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index cn_ma_dl_u0 on cn_ma_dl(ma_dvi, ma);
create index cn_ma_dl_i1 on cn_ma_dl (ma_dvi, ngay_d);
create index cn_ma_dl_i2 on cn_ma_dl (ma_dvi, ma_ct);
create index cn_ma_dl_i3 on cn_ma_dl (ma_dvi, tax);
create index cn_ma_dl_i4 on cn_ma_dl (ma_dvi, nsd);

drop table kh_ma_viec;
create table kh_ma_viec
(
  ma_dvi   varchar2(20 byte),
  ma       varchar2(20 byte),
  phong    varchar2(10 byte),
  ma_cb    varchar2(10 byte),
  k_ma_kh  varchar2(1 byte),
  ma_kh    varchar2(20 byte),
  nd       nvarchar2(1000),
  ngay_bd  number,
  ngay_kt  number,
  viecg    varchar2(20 byte),
  hdong    varchar2(20 byte),
  ttrang   varchar2(1 byte),
  ldo      nvarchar2(1000),
  nsd      varchar2(10 byte),
  idvung   number
);
create unique index kh_ma_viec_u0 on kh_ma_viec(ma_dvi, ma);
create index kh_ma_viec_bp_i1 on kh_ma_viec (ma_dvi, phong);
create index kh_ma_viec_i1 on kh_ma_viec (ma_dvi, ttrang, ngay_bd);
create index kh_ma_viec_i2 on kh_ma_viec (ma_dvi, hdong);

drop table kh_ma_hdong;
create table kh_ma_hdong
(
  ma_dvi    varchar2(20 byte),
  ma        varchar2(20 byte),
  so_hd     varchar2(50 byte),
  nhom      varchar2(1 byte),
  phong     varchar2(10 byte),
  ma_cb     varchar2(10 byte),
  k_ma_kh   varchar2(1 byte),
  ma_kh     varchar2(20 byte),
  ma_nt     varchar2(5 byte),
  ty_gia    number,
  tien      number,
  thue      number,
  ttoan     number,
  nd        nvarchar2(1000),
  ngay_bd   number,
  ngay_kt   number,
  ma_ttr    varchar2(10 byte),
  ma_lvuc   varchar2(10 byte),
  hd_goc    varchar2(20 byte),
  viec      varchar2(20 byte),
  ttrang    varchar2(1 byte),
  gchu      nvarchar2(1000),
  nsd       varchar2(10 byte),
  so_id_kt  number,
  idvung    number
);
create unique index kh_ma_hdong_u0 on kh_ma_hdong(ma_dvi, ma);
create index kh_ma_hdong_i1 on kh_ma_hdong (ma_dvi, ttrang, ngay_bd);
create index kh_ma_hdong_i2 on kh_ma_hdong (ma_dvi, viec);

drop table kh_ma_lct;
create table kh_ma_lct
(
  ma_dvi  varchar2(20 byte),
  md      varchar2(5 byte),
  ma      varchar2(5 byte),
  ngay    number,
  ten     nvarchar2(200),
  tc      varchar2(1 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kh_ma_lct_u0 on kh_ma_lct(ma_dvi, md, ngay, ma);
create index kh_ma_lct_i1 on kh_ma_lct (ma_dvi, md, tc, ngay);
create index kh_ma_lct_i2 on kh_ma_lct (ma_dvi, ngay);

drop table kh_ma_lct_tk;
create table kh_ma_lct_tk
(
  ma_dvi  varchar2(20 byte),
  md      varchar2(5 byte),
  ma      varchar2(5 byte),
  ngay    number,
  bt      number,
  nv      varchar2(1 byte),
  ma_tk   varchar2(200 byte),
  ma_tke  varchar2(200 byte),
  idvung  number
);
create unique index kh_ma_lct_tk_u0 on kh_ma_lct_tk(ma_dvi, md, ngay, ma);
create index kh_ma_lct_tk_i1 on kh_ma_lct_tk (ma_dvi, md, ngay, nv, ma_tk);

drop table xl_ma_ctr;
create table xl_ma_ctr
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  ma       varchar2(20 byte),
  loai     varchar2(5 byte),
  ten      nvarchar2(400),
  mo_ta    nvarchar2(400),
  dia_chi  nvarchar2(400),
  so_qd    varchar2(30 byte),
  ngay_qd  date,
  ld_ky    varchar2(30 byte),
  ma_dl    varchar2(30 byte),
  ma_kh    varchar2(30 byte),
  nsd      varchar2(10 byte),
  idvung   number
);
create unique index xl_ma_ctr_u0 on xl_ma_ctr(ma_dvi, so_id);
create index xl_ma_ctr_i1 on xl_ma_ctr (ma_dvi, ngay_qd);
create unique index xl_ma_ctr_i2 on xl_ma_ctr (ma_dvi, ma);

drop table xd_ma_ctr;
create table xd_ma_ctr
(
  ma_dvi     varchar2(20 byte),
  so_id      number,
  ma         varchar2(20 byte),
  loai       varchar2(2 byte),
  cap        varchar2(1 byte),
  phan_cap   varchar2(1 byte),
  ten        nvarchar2(100),
  mo_ta      nvarchar2(100),
  dia_chi    nvarchar2(100),
  so_qd      varchar2(20 byte),
  ngay_qd    date,
  ld_ky      nvarchar2(50),
  ma_dvi_ql  varchar2(10 byte),
  nsd        varchar2(10 byte),
  idvung     number
);
create unique index xd_ma_ctr_u0 on xd_ma_ctr(ma_dvi, so_id);
create index xd_ma_ctr_i1 on xd_ma_ctr (ma_dvi, ngay_qd);
create unique index xd_ma_ctr_i2 on xd_ma_ctr (ma_dvi, ma);

drop table ts_sc_1;
create table ts_sc_1
(
  ma_dvi     varchar2(20 byte),
  so_id      number,
  so_the     varchar2(20 byte),
  loai       varchar2(1 byte),
  so_tam     varchar2(20 byte),
  so_qd      varchar2(20 byte),
  ng_qd      date,
  ten        nvarchar2(200),
  dac_ta     nvarchar2(200),
  ma_ts      varchar2(10 byte),
  kieu       varchar2(3 byte),
  tt         varchar2(1 byte),
  so_the_ql  varchar2(20 byte),
  ma_tk      varchar2(20 byte),
  ma_tk_kh   varchar2(20 byte),
  model      varchar2(50 byte),
  seri       varchar2(30 byte),
  nuoc_sx    varchar2(10 byte),
  c_suat     nvarchar2(200),
  ng_tang    date,
  ng_sd      date,
  ng_kh      date,
  tg_kh      number,
  ma_ctr     varchar2(20 byte),
  hang       number,
  nsd        varchar2(10 byte),
  so_id_vt   number,
  idvung     number
);
create unique index ts_sc_1_u0 on ts_sc_1(ma_dvi, so_id);
create unique index ts_sc_1_i1 on ts_sc_1 (ma_dvi, so_the);
create index ts_sc_1_i2 on ts_sc_1 (ma_dvi, so_the_ql);
create index ts_sc_1_i3 on ts_sc_1 (ma_dvi, so_tam);
create index ts_sc_1_i4 on ts_sc_1 (ma_dvi, ng_qd);
create index ts_sc_1_i5 on ts_sc_1 (ma_dvi, so_id_vt);

drop table cn_sc;
create table cn_sc
(
  ma_dvi    varchar2(20 byte),
  ma_cn     varchar2(21 byte),
  ma_nt     varchar2(5 byte),
  ma_tk     varchar2(20 byte),
  no_ps     number,
  co_ps     number,
  no_ck     number,
  co_ck     number,
  no_ps_qd  number,
  co_ps_qd  number,
  no_ck_qd  number,
  co_ck_qd  number,
  ngay_ht   number,
  idvung    number
);
create unique index cn_sc_u0 on cn_sc(ma_dvi, ma_cn, ma_nt, ma_tk, ngay_ht);

drop table kt_kh_cbao;
create table kt_kh_cbao
(
  ma_dvi  varchar2(10 byte),
  ma_tk   varchar2(20 byte),
  nv      varchar2(1 byte),
  bao     number,
  chan    number,
  mail    varchar2(500 byte),
  ngay    number,
  idvung  number
);
create unique index kt_kh_cbao_u0 on kt_kh_cbao(ma_dvi, ma_tk);

drop table kt_kh_cbao_tt;
create table kt_kh_cbao_tt
(
  ma_dvi  varchar2(10 byte),
  ma_nh   varchar2(10 byte),
  ma_tk   varchar2(20 byte),
  bao     number,
  mail    varchar2(500 byte),
  ngay    number,
  idvung  number
);
create unique index kt_kh_cbao_tt_u0 on kt_kh_cbao_tt(ma_dvi, ma_nh, ma_tk);

drop table kt_kh_cbao_ttl;
create table kt_kh_cbao_ttl
(
  ma_dvi  varchar2(10 byte),
  ngay    number,
  ma_nh   varchar2(10 byte),
  ma_tk   varchar2(20 byte),
  idvung  number
);
create unique index kt_kh_cbao_ttl_u0 on kt_kh_cbao_ttl(ma_dvi, ngay, ma_nh, ma_tk);

drop table cd_ch;
create table cd_ch
(
  ma_dvi    varchar2(20 byte),
  so_id     number,
  ngay_ht   number,
  l_ct      varchar2(5 byte),
  dvi       varchar2(20 byte),
  so_ct     varchar2(20 byte),
  ngay_ct   varchar2(10 byte),
  tien      number,
  nd        nvarchar2(400),
  nsd       varchar2(10 byte),
  htoan     varchar2(1 byte),
  md        varchar2(2 byte),
  ngay_nh   date,
  so_id_du  number,
  ngay_du   number,
  nd_pa     nvarchar2(400),
  idvung    number
);
create unique index cd_ch_u0 on cd_ch(ma_dvi, so_id);
create index cd_ch_i1 on cd_ch (ma_dvi, ngay_ht);
create index cd_ch_i2 on cd_ch (ma_dvi, l_ct, so_ct, dvi);
create index cd_ch_i3 on cd_ch (ma_dvi, so_id_du);
create index cd_ch_i4 on cd_ch (ma_dvi, dvi, l_ct, ngay_du);
create index cd_ch_i5 on cd_ch (ma_dvi, dvi, l_ct, htoan);

drop table cd_ct;
create table cd_ct
(
  ma_dvi    varchar2(20 byte),
  so_id     number,
  bt        number,
  dvi       varchar2(20 byte),
  ma_nt     varchar2(5 byte),
  tygia     number,
  tien      number,
  tien_qd   number,
  nd        nvarchar2(400),
  so_id_du  number,
  ngay_du   number,
  nd_pa     nvarchar2(400),
  idvung    number
);
create unique index cd_ct_u0 on cd_ct(ma_dvi, so_id, bt);

drop table kt_pbo;
create table kt_pbo
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  ngayd    number,
  ngayc    number,
  nsd      varchar2(10 byte),
  ngay_nh  date,
  idvung   number
);
create unique index kt_pbo_u0 on kt_pbo(ma_dvi, so_id);
create index kt_pbo_i1 on kt_pbo (ma_dvi, ngayc);

drop table kt_sc_bp;
create table kt_sc_bp
(
  ma_dvi   varchar2(20 byte),
  ma_tk    varchar2(20 byte),
  ma_tke   varchar2(20 byte),
  ma_ttr   varchar2(10 byte),
  ma_lvuc  varchar2(10 byte),
  dvi      varchar2(20 byte),
  phong    varchar2(10 byte),
  ma_cb    varchar2(10 byte),
  viec     varchar2(20 byte),
  hdong    varchar2(20 byte),
  ma_sp    varchar2(20 byte),
  no_ps    number,
  co_ps    number,
  no_ck    number,
  co_ck    number,
  ngay_ht  number,
  idvung   number
);
create unique index kt_sc_bp_u0 on kt_sc_bp(ma_dvi, ma_tk, ma_tke, ma_ttr, ma_lvuc, 
                                    dvi, phong, ma_cb, viec, hdong, ma_sp, ngay_ht);
create index kt_sc_bp_i1 on kt_sc_bp (ma_dvi, ngay_ht);

drop table kh_hdong_dt;
create table kh_hdong_dt
(
  ma_dvi  varchar2(20 byte),
  so_id   number,
  bt      number,
  ma      varchar2(20 byte),
  ngay    number,
  nv      varchar2(1 byte),
  tien    number,
  nd      nvarchar2(400),
  idvung  number
);
create unique index kh_hdong_dt_u0 on kh_hdong_dt(ma_dvi, so_id, bt);
create index kh_hdong_dt_i1 on kh_hdong_dt (ma_dvi, ma);

drop table kt_so_so;
create table kt_so_so
(
  ma_dvi   varchar2(20 byte),
  so_id    number,
  so_so    number,
  ngay_ht  number,
  nv       varchar2(2 byte),
  l_ct     varchar2(5 byte),
  ten      nvarchar2(200),
  ps       varchar2(1 byte),
  ma_tk    varchar2(20 byte),
  idvung   number
);
create unique index kt_so_so_u0 on kt_so_so(ma_dvi, so_id);
create index kt_so_so_i1 on kt_so_so (ma_dvi, ngay_ht);

drop table kt_bp_nhom_nv;
create table kt_bp_nhom_nv
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(10 byte),
  nv      varchar2(20 byte),
  loai    varchar2(1 byte),
  idvung  number
);
create unique index kt_bp_nhom_nv_u0 on kt_bp_nhom_nv(ma_dvi, ma, nv);

drop table kt_bp_qly;
create table kt_bp_qly
(
  ma_dvi   varchar2(20 byte),
  ngay_ht  number,
  ma_tke   varchar2(20 byte),
  phong    varchar2(10 byte),
  ma_sp    varchar2(20 byte),
  tien     number,
  loai     varchar2(1 byte),
  idvung   number);
create index kt_bp_qly_i1 on kt_bp_qly (ma_dvi, ngay_ht);

drop table tv_ma_hd;
create table tv_ma_hd
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(100),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index tv_ma_hd_u0 on tv_ma_hd(ma_dvi, ma);

drop table tv_rom;
create table tv_rom
(
  ma_dvi  varchar2(20 byte),
  mau     varchar2(20 byte),
  seri    varchar2(10 byte),
  so_hdd  varchar2(20 byte),
  so_hdc  varchar2(20 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index tv_rom_u0 on tv_rom(ma_dvi, mau, seri, so_hdd);

drop table tv_ma_nhom;
create table tv_ma_nhom
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(5 byte),
  ten     nvarchar2(100),
  tc      varchar2(1 byte),
  loai    varchar2(1 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index tv_ma_nhom_u0 on tv_ma_nhom(ma_dvi, ma);

drop table nb_ma_tk;
create table nb_ma_tk
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(10 byte),
  ten     nvarchar2(100),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index nb_ma_tk_u0 on nb_ma_tk(ma_dvi, ma);

drop table kt_ma_tk;
create table kt_ma_tk
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(100),
  tc      varchar2(100 byte),
  ngay    date,
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kt_ma_tk_u0 on kt_ma_tk(ma_dvi, ma);

drop table kt_ma_lct;
create table kt_ma_lct
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(400),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kt_ma_lct_u0 on kt_ma_lct(ma_dvi, ma);

drop table kt_ma_tktke;
create table kt_ma_tktke
(
  ma_dvi  varchar2(20 byte),
  ma_tk   varchar2(20 byte),
  ma_tke  varchar2(20 byte),
  ten     nvarchar2(100),
  nhom    varchar2(5 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index kt_ma_tktke_u0 on kt_ma_tktke(ma_dvi, ma_tk, ma_tke);

drop table kt_sc;
create table kt_sc
(
  ma_dvi   varchar2(20 byte),
  ma_tk    varchar2(20 byte),
  ma_tke   varchar2(20 byte),
  no_ps    number,
  co_ps    number,
  no_ck    number,
  co_ck    number,
  ngay_ht  number,
  idvung   number
);
create unique index kt_sc_u0 on kt_sc(ma_dvi, ma_tk, ma_tke, ngay_ht);
create index kt_sc_i1 on kt_sc (ma_dvi, ngay_ht);

drop table tt_sc;
create table tt_sc (
  ma_dvi   varchar2(20 byte),
  ma_nt    varchar2(5 byte),
  ma_nh    varchar2(10 byte),
  ma_tk    varchar2(20 byte),
  thu      number,
  thu_qd   number,
  chi      number,
  chi_qd   number,
  ton      number,
  ton_qd   number,
  ngay_ht  number,
  idvung   number
);
create unique index tt_sc_u0 on tt_sc(ma_dvi, ma_nt, ma_nh, ma_tk, ngay_ht);
create index tt_sc_i1 on tt_sc (ma_dvi, ngay_ht);

drop table ts_kh;
create table ts_kh
(
  ma_dvi    varchar2(20 byte),
  ngay      date,
  so_the    varchar2(20 byte),
  dvi_sd    varchar2(20 byte),
  ma_ng     varchar2(5 byte),
  nggia_dk  number,
  nggia_bd  number,
  nggia_di  number,
  nggia_ve  number,
  nggia_ck  number,
  kh_dk     number,
  kh_bd     number,
  kh_th     number,
  kh_di     number,
  kh_ve     number,
  kh_ck     number,
  tcon      number,
  idvung    number
);
create unique index ts_kh_u0 on ts_kh(ma_dvi, so_the, ngay, dvi_sd, ma_ng);

drop table ts_khao;
create table ts_khao
(
  ma_dvi    varchar2(20 byte),
  so_the    varchar2(20 byte),
  ngay      date,
  ma_ts     varchar2(10 byte),
  kieu      varchar2(3 byte),
  con_khao  number,
  ma_md     varchar2(10 byte),
  ma_tt     varchar2(10 byte),
  khao      varchar2(1 byte),
  nd        nvarchar2(200),
  nsd       varchar2(10 byte),
  idvung    number
);
create unique index ts_khao_u0 on ts_khao(ma_dvi, so_the, ngay);

drop table ts_ma_ts_kh;
create table ts_ma_ts_kh
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(10 byte),
  kieu    varchar2(3 byte),
  ngay    date,
  ppt     varchar2(1 byte),
  nam     number,
  dt      number,
  gh      number,
  idvung  number
);
create unique index ts_ma_ts_kh_u0 on ts_ma_ts_kh(ma_dvi, ma, kieu, ngay);

drop table ts_dc;
create table ts_dc
(
  ma_dvi   varchar2(20 byte),
  so_the   varchar2(20 byte),
  ngay_qd  date,
  so_qd    varchar2(20 byte),
  dvi_sd   varchar2(50 byte),
  phong    varchar2(10 byte),
  ma_cb    varchar2(10 byte),
  dchi     nvarchar2(100),
  nsd      varchar2(10 byte),
  idvung   number
);
create unique index ts_dc_u0 on ts_dc(ma_dvi, so_the, ngay_qd);

drop table ts_sc_2;
create table ts_sc_2
(
  ma_dvi   varchar2(20 byte),
  so_the   varchar2(20 byte),
  ma_bd    varchar2(5 byte),
  ma_ng    varchar2(5 byte),
  ma_nt    varchar2(5 byte),
  tien     number,
  tien_qd  number,
  ng_bd    date,
  idvung   number
);
create unique index ts_sc_2_u0 on ts_sc_2(ma_dvi, so_the, ma_bd, ma_ng, ma_nt, ng_bd);
create index ts_sc_2_i1 on ts_sc_2 (ma_dvi, ng_bd);

drop table xd_ma_nguon;
create table xd_ma_nguon
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(5 byte),
  ten     nvarchar2(100),
  tc      varchar2(1 byte),
  ma_tk   varchar2(100 byte),
  khao    varchar2(1 byte),
  nguon   varchar2(1 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index xd_ma_nguon_u0 on xd_ma_nguon(ma_dvi, ma);

drop table ts_ma_bdong;
create table ts_ma_bdong
(
  ma_dvi  varchar2(20 byte),
  ma      varchar2(5 byte),
  ten     nvarchar2(200),
  loai    varchar2(1 byte),
  xl      varchar2(1 byte),
  tc      varchar2(1 byte),
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index ts_ma_bdong_u0 on ts_ma_bdong(ma_dvi, ma);

drop table ts_hsdc;
create table ts_hsdc
(
  ma_dvi  varchar2(20 byte),
  ngay    date,
  nam     number,
  hs      number,
  nsd     varchar2(10 byte),
  idvung  number
);
create unique index ts_hsdc_u0 on ts_hsdc(ma_dvi, ngay, nam);

drop table ts_sots_temp;
create global temporary table ts_sots_temp
(
  ma_ts varchar2(30),
  sots  number
)
on commit preserve rows;

drop table ts_sots_temp_2;
create global temporary table ts_sots_temp_2
(
  ma_ts varchar2(30),
  sots  number
)
on commit preserve rows;

drop table ts_sots_temp_1;
create global temporary table ts_sots_temp_1
(
  ma_ts varchar2(30),
  sots  number
)
on commit preserve rows;

drop table cc_dc;
create table cc_dc
(
  ma_dvi   varchar2(20),
  so_id    number,
  so_id_dc number,
  so_qd    varchar2(20),
  ngay_qd  date,
  phong    varchar2(10),
  ma_cb    varchar2(10),
  phong_cu varchar2(10),
  ma_cb_cu varchar2(10),
  ma_mdsd  varchar2(5),
  luong    number,
  nsd      varchar2(10),
  idvung   number

);
create unique index cc_dc_u0 on cc_dc(ma_dvi, so_id, so_id_dc);
create index cc_dc_i1 on cc_dc (ma_dvi, so_id, phong, ma_cb, ngay_qd);
create index cc_dc_i2 on cc_dc (ma_dvi, so_id, phong_cu, ma_cb_cu, ngay_qd);

drop table ts_ma_ts;
create table ts_ma_ts
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  don_vi varchar2(10),
  loai   varchar2(1),
  tc     varchar2(1),
  ma_ql  varchar2(10),
  nsd    varchar2(10),
  idvung number

);
create unique index ts_ma_ts_u0 on ts_ma_ts(ma_dvi, ma);

drop table ts_dc;
create table ts_dc
(
  ma_dvi  varchar2(20),
  so_the  varchar2(20),
  ngay_qd date,
  so_qd   varchar2(20),
  dvi_sd  varchar2(50),
  phong   varchar2(10),
  ma_cb   varchar2(10),
  dchi    nvarchar2(100),
  nsd     varchar2(10),
  idvung  number

);
create unique index ts_dc_u0 on ts_dc(ma_dvi, so_the, ngay_qd);

drop table kt_bp_nhom;
create table kt_bp_nhom
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  tc     varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index kt_bp_nhom_u0 on kt_bp_nhom(ma_dvi, ma);

drop table kt_tim_temp1;
create global temporary table kt_tim_temp1
  (n1 number)
on commit preserve rows;
create index kt_tim_temp1 on kt_tim_temp1 (n1);

drop table tt_tk;
create table tt_tk
(
  ma_dvi varchar2(20),
  ngay   number,
  ma     varchar2(5),
  ma_tk  varchar2(20),
  nsd    varchar2(10),
  idvung number

);
create unique index tt_tk_u0 on tt_tk(ma_dvi, ngay, ma);

drop table vt_ma_cl;
create table vt_ma_cl
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(50),
  nsd    varchar2(10),
  idvung number

);
create unique index vt_ma_cl_u0 on vt_ma_cl(ma_dvi, ma);

drop table vt_ma_dvt;
create table vt_ma_dvt
(
  ma_dvi varchar2(20),
  ma     nvarchar2(10),
  ten    nvarchar2(20),
  so_tp  number,
  nsd    varchar2(10),
  idvung number

);
create unique index vt_ma_dvt_u0 on vt_ma_dvt(ma_dvi, ma);

drop table vt_ma_kho;
create table vt_ma_kho
(
  ma_dvi  varchar2(20),
  ma      varchar2(10),
  ten     nvarchar2(200),
  gon     nvarchar2(200),
  ma_tk   varchar2(20),
  pp      varchar2(1),
  thu_kho nvarchar2(50),
  ma_ct   varchar2(10),
  nsd     varchar2(10),
  idvung  number

);
create unique index vt_ma_kho_u0 on vt_ma_kho(ma_dvi, ma);
create index vt_ma_kho_i1 on vt_ma_kho (ma_dvi, ma_ct);

drop table kt_kh_ttt;
create table kt_kh_ttt
(
  ma_dvi      varchar2(20),
  ps          varchar2(10),
  nv          varchar2(10),
  ma          varchar2(20),
  ten         nvarchar2(400),
  loai        varchar2(1),
  bb          varchar2(1),
  ktra        varchar2(100),
  f_tkhao     varchar2(100),
  f_sht_tkhao varchar2(100),
  lke         nvarchar2(500),
  tra         varchar2(100),
  bt          number,
  nsd         varchar2(20)

);
create unique index kt_kh_ttt_u0 on kt_kh_ttt(ma_dvi, ps, nv, ma);
create index kt_kh_ttt_i1 on kt_kh_ttt (ma_dvi, ps, nv, bt);

drop table cc_kh;
create table cc_kh
(
  ma_dvi   varchar2(20),
  so_id    number,
  ngay     date,
  nggia_dk number,
  nggia_bd number,
  nggia_ck number,
  kh_dk    number,
  kh_bd    number,
  kh_ck    number,
  idvung   number

);
create unique index cc_kh_u0 on cc_kh(ma_dvi, so_id, ngay);
create index cc_kh_i1 on cc_kh (ma_dvi, ngay);

drop table cc_pb;
create table cc_pb
(
  ma_dvi varchar2(20),
  so_id  number,
  ngay   number,
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  dvi    varchar2(20),
  pt     number,
  nsd    varchar2(10),
  bt     number,
  idvung number

);
create unique index cc_pb_u0 on cc_pb(ma_dvi, so_id, ngay, bt);

drop table kh_ma_ttu;
create table kh_ma_ttu
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  ma_ct  varchar2(10),
  nsd    varchar2(10),
  idvung number

);
create unique index kh_ma_ttu_u0 on kh_ma_ttu(ma_dvi, ma);

drop table kh_ma_lvuc;
create table kh_ma_lvuc
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  ma_ct  varchar2(10),
  nsd    varchar2(10),
  idvung number

);
create unique index kh_ma_lvuc_u0 on kh_ma_lvuc(ma_dvi, ma);

drop table sx_ma_sp;
create table sx_ma_sp
(
  ma_dvi  varchar2(20),
  ma      varchar2(20),
  ten     nvarchar2(200),
  tc      varchar2(1),
  nhom    varchar2(1),
  ma_ct   varchar2(20),
  tk_dthu varchar2(20),
  tk_cphi varchar2(20),
  dv      nvarchar2(20),
  nsd     varchar2(10),
  idvung  number

);
create unique index sx_ma_sp_u0 on sx_ma_sp(ma_dvi, ma);

drop table kt_bp_goc;
create table kt_bp_goc
(
  ma_dvi  varchar2(20),
  so_id   number,
  bt      number,
  ngay_ht number,
  nhom    varchar2(10),
  ma_ttr  varchar2(10),
  ma_lvuc varchar2(10),
  dvi     varchar2(20),
  phong   varchar2(10),
  ma_cb   varchar2(10),
  viec    varchar2(20),
  hdong   varchar2(20),
  ma_sp   varchar2(20),
  tien    number,
  bt_phu  number,
  idvung  number
);

drop table ts_kh;
create table ts_kh
(
  ma_dvi   varchar2(20),
  ngay     date,
  so_the   varchar2(20),
  dvi_sd   varchar2(20),
  ma_ng    varchar2(5),
  nggia_dk number,
  nggia_bd number,
  nggia_di number,
  nggia_ve number,
  nggia_ck number,
  kh_dk    number,
  kh_bd    number,
  kh_th    number,
  kh_di    number,
  kh_ve    number,
  kh_ck    number,
  tcon     number,
  idvung   number

);
create unique index ts_kh_u0 on ts_kh(ma_dvi, so_the, ngay, dvi_sd, ma_ng);

drop table ts_phu;
create table ts_phu
(
  ma_dvi   varchar2(20),
  ngay     date,
  so_the   varchar2(20),
  dvi_sd   varchar2(10),
  ma_ng    varchar2(5),
  nggia_dk number,
  nggia_bd number,
  nggia_di number,
  nggia_ve number,
  nggia_ck number,
  idvung   number

);
create unique index ts_phu_u0 on ts_phu(ma_dvi, so_the, ngay, dvi_sd, ma_ng);

drop table ts_sc_2;
create table ts_sc_2
(
  ma_dvi  varchar2(20),
  so_the  varchar2(20),
  ma_bd   varchar2(5),
  ma_ng   varchar2(5),
  ma_nt   varchar2(5),
  tien    number,
  tien_qd number,
  ng_bd   date,
  idvung  number

);
create unique index ts_sc_2_u0 on ts_sc_2(ma_dvi, so_the, ma_bd, ma_ng, ma_nt, ng_bd);
create index ts_sc_2_i1 on ts_sc_2 (ma_dvi, ng_bd);

drop table ts_khao;
create table ts_khao
(
  ma_dvi   varchar2(20),
  so_the   varchar2(20),
  ngay     date,
  ma_ts    varchar2(10),
  kieu     varchar2(3),
  con_khao number,
  ma_md    varchar2(10),
  ma_tt    varchar2(10),
  khao     varchar2(1),
  nd       nvarchar2(200),
  nsd      varchar2(10),
  idvung   number

);
create unique index ts_khao_u0 on ts_khao(ma_dvi, so_the, ngay);

drop table ts_ma_ts_kh;
create table ts_ma_ts_kh
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  kieu   varchar2(3),
  ngay   date,
  ppt    varchar2(1),
  nam    number,
  dt     number,
  gh     number,
  idvung number

);
create unique index ts_ma_ts_kh_u0 on ts_ma_ts_kh(ma_dvi, ma, kieu, ngay);

drop table xd_ma_nguon;
create table xd_ma_nguon
(
  ma_dvi varchar2(20),
  ma     varchar2(5),
  ten    nvarchar2(100),
  tc     varchar2(1),
  ma_tk  varchar2(100),
  khao   varchar2(1),
  nguon  varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index xd_ma_nguon_u0 on xd_ma_nguon(ma_dvi, ma);

drop table ts_ma_bdong;
create table ts_ma_bdong
(
  ma_dvi varchar2(20),
  ma     varchar2(5),
  ten    nvarchar2(200),
  loai   varchar2(1),
  xl     varchar2(1),
  tc     varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index ts_ma_bdong_u0 on ts_ma_bdong(ma_dvi, ma);

drop table ts_hsdc;
create table ts_hsdc
(
  ma_dvi varchar2(20),
  ngay   date,
  nam    number,
  hs     number,
  nsd    varchar2(10),
  idvung number

);
create unique index ts_hsdc_u0 on ts_hsdc(ma_dvi, ngay, nam);

drop table ts_ma_tt;
create table ts_ma_tt
(
  ma_dvi varchar2(20),
  ma     varchar2(5),
  ten    nvarchar2(200),
  tc     varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index ts_ma_tt_u0 on ts_ma_tt(ma_dvi, ma);

drop table ts_bd_1;
create table ts_bd_1
(
  ma_dvi  varchar2(20),
  so_id   number,
  ngay_ht number,
  l_ct    varchar2(5),
  ng_bd   date,
  so_ct   varchar2(20),
  nd      nvarchar2(200),
  nsd     varchar2(10),
  htoan   varchar2(1),
  md      varchar2(2),
  ngay_nh date,
  idvung  number

);
create unique index ts_bd_1_u0 on ts_bd_1(ma_dvi, so_id);
create index ts_bd_1_i1 on ts_bd_1 (ma_dvi, ngay_ht);
create index ts_bd_1_i2 on ts_bd_1 (ma_dvi, ng_bd);

drop table ts_bd_2;
create table ts_bd_2
(
  ma_dvi  varchar2(20),
  so_id   number,
  ngay_ht number,
  so_the  varchar2(20),
  ma_bd   varchar2(5),
  ma_ng   varchar2(5),
  ma_nt   varchar2(5),
  ty_gia  number,
  tien    number,
  tien_qd number,
  so_qd   varchar2(20),
  bt      number,
  idvung  number

);
create unique index ts_bd_2_u0 on ts_bd_2(ma_dvi, so_id, bt);
create index ts_bd_2_i1 on ts_bd_2 (ma_dvi, ngay_ht);
create index ts_bd_2_i2 on ts_bd_2 (ma_dvi, so_the);

drop table ts_htoan_temp_1;
create global temporary table ts_htoan_temp_1
(
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  dvi    varchar2(20),
  phong  varchar2(10),
  sp     varchar2(20),
  tien   number
)
on commit preserve rows;

drop table ts_htoan_temp_2;
create global temporary table ts_htoan_temp_2
(
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  dvi    varchar2(20),
  phong  varchar2(10),
  sp     varchar2(20),
  tien   number
)
on commit preserve rows;

drop table ts_htoan_temp_3;
create global temporary table ts_htoan_temp_3
(
  ma_tk  varchar2(20),
  ma_tke varchar2(20)
)
on commit preserve rows;

drop table ts_htoan_temp_4;
create global temporary table ts_htoan_temp_4
(
  ma_tk varchar2(20),
  tien  number
)
on commit preserve rows;

drop table ts_pb;
create table ts_pb
(
  ma_dvi varchar2(20),
  so_the varchar2(20),
  ngay   number,
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  dvi    varchar2(20),
  pt     number,
  nsd    varchar2(10),
  bt     number,
  idvung number

);
create unique index ts_pb_u0 on ts_pb(ma_dvi, so_the, ngay, bt);

drop table kt_ma_lct_tk;
create table kt_ma_lct_tk
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  nv     varchar2(1),
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  bt     number,
  idvung number

);
create unique index kt_ma_lct_tk_u0 on kt_ma_lct_tk(ma_dvi, ma, bt);

drop table kt_ma_tklc;
create table kt_ma_tklc
(
  ma_dvi varchar2(20),
  ma_tk  varchar2(20),
  ma_lc  varchar2(10),
  nsd    varchar2(10),
  idvung number

);
create unique index kt_ma_tklc_u0 on kt_ma_tklc(ma_dvi, ma_tk, ma_lc);

drop table kt_htkc;
create table kt_htkc
(
  ma_dvi  varchar2(20),
  ngay_ht number,
  ma      varchar2(20),
  l_ct    varchar2(10),
  nd      nvarchar2(400)

);
create unique index kt_htkc_u0 on kt_htkc(ma_dvi, ma, ngay_ht);

drop table kt_namtc;
create table kt_namtc
(
  ma_dvi varchar2(20),
  ngay   number,
  nsd    varchar2(10),
  idvung number

);
create unique index kt_namtc_u0 on kt_namtc(ma_dvi, ngay);

drop table se_1;
create table se_1
(
  ma_dvi  varchar2(20) not null,
  so_id   number not null,
  ngay_ht number,
  l_ct    varchar2(1),
  so_tt   number,
  so_ph   varchar2(20),
  ngay_ct varchar2(20),
  ma_nt   varchar2(5),
  tg_ht   number,
  nha     varchar2(10),
  tk_nha  varchar2(20),
  nd      nvarchar2(400),
  tien    number,
  tien_qd number,
  nsd     varchar2(10),
  htoan   varchar2(1),
  md      varchar2(2),
  ngay_nh date,
  idvung  number

);
create unique index se_1_u0 on se_1(ma_dvi, so_id);
create index se_1_i1 on se_1 (ma_dvi, ngay_ht, l_ct, nsd);
create index se_1_i2 on se_1 (ma_dvi, ngay_ht, l_ct, so_tt);

drop table tc_ps;
create table tc_ps
(
  ma_dvi  varchar2(20),
  so_id   number,
  hdong   varchar2(20),
  ngay_ht number,
  l_ct    varchar2(2),
  so_ct   varchar2(20),
  ngay_ct varchar2(10),
  ma_nt   varchar2(5),
  tien    number,
  lai     number,
  thue    number,
  tien_qd number,
  lai_qd  number,
  thue_qd number,
  nd      nvarchar2(400),
  ndp     nvarchar2(400),
  loai    varchar2(1),
  pp      varchar2(1),
  t_suat  number,
  mau     varchar2(20),
  seri    varchar2(10),
  so_hd   varchar2(20),
  nsd     varchar2(10),
  htoan   varchar2(1),
  md      varchar2(2),
  ngay_nh date,
  idvung  number

);
create unique index tc_ps_u0 on tc_ps(ma_dvi, so_id);
create index tc_ps_i1 on tc_ps (ma_dvi, hdong);

drop table tt_2;
create table tt_2
(
  ma_dvi   varchar2(20),
  so_id    number,
  ngay_ht  number,
  ma_nt    varchar2(5),
  nha_c    varchar2(10),
  tk_nha_c varchar2(20),
  so_id_ps number,
  tien     number,
  tien_qd  number,
  bt       number,
  idvung   number

);
create unique index tt_2_u0 on tt_2(ma_dvi, so_id, bt);
create index tt_2_i1 on tt_2 (ma_dvi, so_id_ps);

drop table tt_ph;
create table tt_ph
(
  ma_dvi  varchar2(20),
  so_id   number,
  ma_nt   varchar2(5),
  ma_nh   varchar2(10),
  ma_tk   varchar2(20),
  ngay_ht number,
  tien    number,
  tien_qd number,
  idvung  number

);
create unique index tt_ph_u0 on tt_ph(ma_dvi, so_id); 
create index tt_ph_i1 on tt_ph (ma_dvi, ma_nt, ma_nh, ma_tk, ngay_ht);

drop table se_3;
create table se_3
(
  ma_dvi   varchar2(20),
  so_id    number,
  so_tt    number,
  ngay_ht  number,
  so_id_ps number,
  so_tt_ps number,
  idvung   number

);
create unique index se_3_u0 on se_3(ma_dvi, so_id, so_tt);
create index se_3_i1 on se_3 (ma_dvi, ngay_ht);
create index se_3_i2 on se_3 (ma_dvi, so_id_ps, so_tt_ps);

drop table tt_ma_qui;
create table tt_ma_qui
(
  ma_dvi  varchar2(20),
  ma      varchar2(5),
  ten     nvarchar2(50),
  ma_tk   varchar2(20),
  thu_qui nvarchar2(100),
  nsd     varchar2(10),
  idvung  number

);
create unique index tt_ma_qui_u0 on tt_ma_qui(ma_dvi, ma);

drop table tt_ma_tke;
create table tt_ma_tke
(
  ma_dvi varchar2(20),
  ma     varchar2(5),
  ten    nvarchar2(50),
  tc     varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index tt_ma_tke_u0 on tt_ma_tke(ma_dvi, ma);

drop table tt_2_temp_2;
create global temporary table tt_2_temp_2
(
  so_id   number,
  tien    number,
  tien_qd number,
  chi     number,
  chi_qd  number
)
on commit preserve rows;

drop table tt_2_temp_1;
create global temporary table tt_2_temp_1
(
  so_id   number,
  tien    number,
  tien_qd number,
  chi     number,
  chi_qd  number
)
on commit preserve rows;

drop table kh_hdong_tt;
create table kh_hdong_tt
(
  ma_dvi  varchar2(20),
  so_id   number,
  ma      varchar2(20),
  ngay    number,
  loai    varchar2(1),
  tien    number,
  nd      nvarchar2(400),
  nsd     varchar2(10),
  ngay_nh date,
  so_id_g number,
  idvung  number

);
create unique index kh_hdong_tt_u0 on kh_hdong_tt(ma_dvi, so_id);
create index kh_hdong_tt_i1 on kh_hdong_tt (ma_dvi, ma);
create index kh_hdong_tt_i2 on kh_hdong_tt (ma_dvi, so_id_g);

drop table kt_lcdoi;
create table kt_lcdoi
(
  ma_dvi  varchar2(20),
  so_id   number,
  bt      number,
  ngay_ht number,
  nv      varchar2(1),
  ma_c    varchar2(10),
  ma_m    varchar2(10),
  tien    number,
  nd      nvarchar2(200),
  nsd     varchar2(10),
  idvung  number

);
create unique index kt_lcdoi_u0 on kt_lcdoi(ma_dvi, so_id, bt);
create index kt_lcdoi_i1 on kt_lcdoi (ma_dvi, ngay_ht);

drop table tv_ngay;
create table tv_ngay
(
  ma_dvi varchar2(20),
  ngay   number,
  nsd    varchar2(10),
  idvung number
);

drop table kh_nsu;
create table kh_nsu
(
  ma_dvi varchar2(20),
  ngay   number,
  phong  varchar2(10),
  nsu    number,
  tnsu   number,
  nsd    varchar2(10),
  idvung number

);
create unique index kh_nsu_u0 on kh_nsu(ma_dvi, ngay, phong);

drop table kh_ma_hdong_bp;
create table kh_ma_hdong_bp
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  bt     number,
  dvi    varchar2(20),
  phong  varchar2(10),
  ma_cb  varchar2(10),
  pt     number,
  tien   number,
  idvung number

);
create unique index kh_ma_hdong_bp_u0 on kh_ma_hdong_bp(ma_dvi, ma, bt);
create index kh_hdong_bp_i1 on kh_ma_hdong_bp (ma_dvi, dvi, ma, phong);

drop table kh_ma_viec_bp;
create table kh_ma_viec_bp
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  bt     number,
  dvi    varchar2(20),
  phong  varchar2(10),
  ma_cb  varchar2(10),
  pt     number,
  idvung number

);
create unique index kh_ma_viec_bp_u0 on kh_ma_viec_bp(ma_dvi, ma, bt);

drop table pb_0;
create table pb_0
(
  ma_dvi  varchar2(20),
  so_id   number,
  ngay_ht number,
  l_ct    varchar2(1),
  so_ct   varchar2(20),
  tien    number,
  doi     number,
  ngay_bd date,
  kieu    varchar2(1),
  p_bo    number,
  ma_tk   varchar2(20),
  nhom    varchar2(5),
  loai    varchar2(1),
  so_hd   varchar2(20),
  phong   varchar2(10),
  nd      nvarchar2(400),
  duoi    varchar2(20),
  nsd     varchar2(10),
  htoan   varchar2(1),
  md      varchar2(2),
  ngay_nh date,
  idvung  number

);
create unique index pb_0_u0 on pb_0(ma_dvi, so_id);
create index pb_0_i1 on pb_0 (ma_dvi, ngay_ht, l_ct);
create index pb_0_i2 on pb_0 (ma_dvi, l_ct, so_ct);

drop table pb_ma_nhom;
create table pb_ma_nhom
(
  ma_dvi varchar2(20),
  ma     varchar2(5),
  ten    nvarchar2(100),
  nsd    varchar2(10),
  idvung number

);
create unique index pb_ma_nhom_u0 on pb_ma_nhom(ma_dvi, ma);

drop table kh_ma_lnv;
create table kh_ma_lnv
(
  ma_dvi varchar2(20),
  ma     varchar2(2),
  ten    nvarchar2(200),
  tt     number,
  nsd    varchar2(10),
  idvung number

);
create unique index kh_ma_lnv_u0 on kh_ma_lnv(ma_dvi, ma);

drop table kh_gop;
create table kh_gop
(
  ma_dvi  varchar2(20),
  goc     varchar2(20),
  nd      nvarchar2(400),
  gop     nvarchar2(400),
  xly     nvarchar2(400),
  ngayd   number,
  ngayc   number,
  cluong  varchar2(10),
  nsd_xly varchar2(20),
  nsd     varchar2(20),
  ngay_qd date,
  ngay_nh date

);
create unique index kh_gop_u0 on kh_gop(ngay_qd, ngay_nh);
create index kh_gop_i1 on kh_gop (ngayd, ngayc);

drop table xl_2;
create table xl_2
(
  ma_dvi  varchar2(20),
  so_id   number,
  ma_ctr  varchar2(20),
  hang    varchar2(20),
  ma_mc   varchar2(20),
  ma_vi   varchar2(20),
  tien    number,
  tien_qd number,
  bt      number,
  idvung  number

);
create unique index xl_2_u0 on xl_2(ma_dvi, so_id, bt);
create index xl_2_i1 on xl_2 (ma_dvi, ma_ctr, hang);

drop table kt_htkc_tk_temp;
create global temporary table kt_htkc_tk_temp
(
  tk_no  varchar2(20),
  tke_no varchar2(20),
  tk_co  varchar2(20),
  tke_co varchar2(20),
  tien   number,
  nv     varchar2(1)
)
on commit preserve rows;

drop table kt_htkc_1;
create table kt_htkc_1
(
  ma_dvi   varchar2(20),
  ngay_ht  number,
  ma       varchar2(20),
  bt       number,
  loai     varchar2(2),
  ma_tk    varchar2(20),
  ma_tke   varchar2(20),
  ma_tkdu  varchar2(20),
  ma_tkedu varchar2(20),
  ma_tkht  varchar2(20),
  ma_tkeht varchar2(20),
  pb       varchar2(1)

);
create unique index kt_htkc_1_u0 on kt_htkc_1(ma_dvi, ma, ngay_ht, bt);

drop table kt_sc_temp_tke;
create global temporary table kt_sc_temp_tke
(
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  no_dk  number,
  co_dk  number,
  no_ps  number,
  co_ps  number,
  no_ck  number,
  co_ck  number,
  no_lk  number,
  co_lk  number
)
on commit preserve rows;
create index kt_sc_temp_tke_i1 on kt_sc_temp_tke (ma_tk, ma_tke);

drop table kt_sc_bp_temp;
create global temporary table kt_sc_bp_temp
(
  ma_tk   varchar2(20),
  ma_tke  varchar2(20),
  ma_ttr  varchar2(10),
  ma_lvuc varchar2(10),
  dvi     varchar2(20),
  phong   varchar2(10),
  ma_cb   varchar2(10),
  viec    varchar2(20),
  hdong   varchar2(20),
  ma_sp   varchar2(20),
  no_dk   number,
  co_dk   number,
  no_ps   number,
  co_ps   number,
  no_ck   number,
  co_ck   number,
  no_lk   number,
  co_lk   number
)
on commit preserve rows;
create index kt_sc_bp_temp_i1 on kt_sc_bp_temp (ma_tk, ma_tke);

drop table kt_sc_bp_temp1;
create global temporary table kt_sc_bp_temp1
(
  ma_tk   varchar2(20),
  ma_tke  varchar2(20),
  ma_ttr  varchar2(10),
  ma_lvuc varchar2(10),
  dvi     varchar2(20),
  phong   varchar2(10),
  ma_cb   varchar2(10),
  viec    varchar2(20),
  hdong   varchar2(20),
  ma_sp   varchar2(20),
  no_dk   number,
  co_dk   number,
  no_ps   number,
  co_ps   number,
  no_ck   number,
  co_ck   number,
  no_lk   number,
  co_lk   number
)
on commit preserve rows;

drop table dp_ma_heso;
create table dp_ma_heso
(
  ma_dvi  varchar2(20),
  ngay_ht number,
  han     number,
  pt      number,
  nsd     varchar2(10),
  ngay    date,
  idvung  number
);

drop table vt_ma_mdsd;
create table vt_ma_mdsd
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  ma_tk  varchar2(20),
  ma_tke varchar2(20),
  nsd    varchar2(10),
  idvung number

);
create unique index vt_ma_mdsd_u0 on vt_ma_mdsd(ma_dvi, ma);

drop table cc_ptu_1;
create table cc_ptu_1
(
  ma_dvi   varchar2(20),
  so_id    number,
  so_id_cc number,
  so_ptu   varchar2(20),
  ten      nvarchar2(100),
  model    varchar2(50),
  seri     varchar2(50),
  don_vi   nvarchar2(100),
  idvung   number

);
create unique index cc_ptu_1_u0 on cc_ptu_1(ma_dvi, so_id);
create unique index cc_ptu_1_i1 on cc_ptu_1 (ma_dvi, so_ptu);
create index cc_ptu_1_i2 on cc_ptu_1 (ma_dvi, so_id_cc);

drop table cc_su;
create table cc_su
(
  ma_dvi  varchar2(20),
  so_id   number,
  ngay_di date,
  gchu_di nvarchar2(200),
  ma_kh   varchar2(10),
  ngay_ve date,
  c_luong nvarchar2(200),
  tien    number,
  gchu_ve nvarchar2(200),
  nsd     varchar2(10),
  idvung  number

);
create unique index cc_su_u0 on cc_su(ma_dvi, so_id, ngay_di);

drop table cc_khao;
create table cc_khao
(
  ma_dvi varchar2(20),
  so_the varchar2(20),
  ngay   date,
  ma_md  varchar2(10),
  ma_tt  varchar2(10),
  nd     nvarchar2(200),
  nsd    varchar2(10),
  idvung number

);
create unique index cc_khao_u0 on cc_khao(ma_dvi, so_the, ngay);

drop table tv_vt;
create table tv_vt
(
  ma_dvi  varchar2(20),
  so_id   number,
  ngay_ht number,
  k_ma_kh varchar2(1),
  ma_kh   varchar2(20),
  ten     nvarchar2(200),
  dchi    nvarchar2(200),
  ma_thue varchar2(30),
  nd      nvarchar2(200),
  ma_nt   varchar2(5),
  tg_tt   number,
  loai    varchar2(1),
  pp      varchar2(1),
  t_suat  number,
  tien    number,
  thue    number,
  ttoan   number,
  mau     varchar2(20),
  seri    varchar2(10),
  so_hd   varchar2(20),
  ngay_bc number,
  nsd     varchar2(10),
  ngay_nh date,
  idvung  number

);
create unique index tv_vt_u0 on tv_vt(ma_dvi, so_id);
create index tv_vt_i1 on tv_vt (ma_dvi, ngay_ht, nsd);

drop table ts_su;
create table ts_su
(
  ma_dvi  varchar2(20),
  so_id   number,
  ngay_di date,
  gchu_di nvarchar2(200),
  ma_kh   varchar2(10),
  ngay_ve date,
  c_luong nvarchar2(200),
  tien    number,
  gchu_ve nvarchar2(200),
  nsd     varchar2(10),
  idvung  number

);
create unique index ts_su_u0 on ts_su(ma_dvi, so_id, ngay_di);

drop table xl_ma_lctr;
create table xl_ma_lctr
(
  ma_dvi varchar2(20),
  ma     varchar2(5),
  ten    nvarchar2(200),
  nsd    varchar2(10),
  idvung number

);
create unique index xl_ma_lctr_u0 on xl_ma_lctr(ma_dvi, ma);

drop table xl_ma_ctr_hang;
create table xl_ma_ctr_hang
(
  ma_dvi  varchar2(20),
  so_id   number,
  ma      varchar2(20),
  hang    varchar2(20),
  ten     nvarchar2(400),
  ngay_bd date,
  ngay_kt date,
  so_the  varchar2(20),
  so_dt   varchar2(20),
  dv_dt   nvarchar2(400),
  d_diem  nvarchar2(400),
  dvtc    nvarchar2(100),
  nhang   varchar2(10),
  ma_tk   varchar2(20),
  muc     varchar2(1),
  ngay_qd date,
  bt      number,
  idvung  number

);
create unique index xl_ma_ctr_hang_u0 on xl_ma_ctr_hang(ma_dvi, so_id, hang); 
create index xl_ma_ctr_hang_i1 on xl_ma_ctr_hang (ma_dvi, ngay_qd);
create index xl_ma_ctr_hang_i2 on xl_ma_ctr_hang (ma_dvi, ma, hang);
create index xl_ma_ctr_hang_i3 on xl_ma_ctr_hang (ma_dvi, muc);

create table xldt_1
(
  ma_dvi varchar2(20),
  so_id  number,
  ma     varchar2(20),
  so_qd  varchar2(20),
  ld_ky  varchar2(30),
  ngay   date,
  hang   varchar2(20),
  ma_mc  varchar2(20),
  nguon  varchar2(5),
  ma_nt  varchar2(5),
  tien   number,
  nsd    varchar2(10),
  bt     number,
  idvung number

);
create unique index xldt_1_u0 on xldt_1(ma_dvi, so_id, bt);
create index xldt_1_i1 on xldt_1 (ma_dvi, ngay);
create index xldt_1_i2 on xldt_1 (ma_dvi, ma, hang);

drop table xl_temp_lke;
create global temporary table xl_temp_lke
(
  so_id number,
  so_ct varchar2(20),
  tien  number,
  nsd   varchar2(10)
)
on commit preserve rows;

drop table xl_ma_vi;
create table xl_ma_vi
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  ten    nvarchar2(400),
  tc     varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index xl_ma_vi_u0 on xl_ma_vi(ma_dvi, ma);

drop table xlht_1;
create table xlht_1
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  hang   varchar2(20),
  muc    varchar2(1),
  ngay   date,
  nsd    varchar2(10),
  idvung number

);
create unique index xlht_1_u0 on xlht_1(ma_dvi, ma, hang, muc);
create index xlht_1_i1 on xlht_1 (ma_dvi, ngay);

drop table xl_ma_mc;
create table xl_ma_mc
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  ten    nvarchar2(400),
  tc     varchar2(1),
  nsd    varchar2(10),
  idvung number

);
create unique index xl_ma_mc_u0 on xl_ma_mc(ma_dvi, ma);

drop table vt_sc;
create table vt_sc
(
  ma_dvi  varchar2(20),
  kho     varchar2(10),
  loai    varchar2(1),
  nhom    varchar2(5),
  ma_vt   varchar2(30),
  nuoc    varchar2(30),
  model   varchar2(50),
  lo      varchar2(50),
  dv      nvarchar2(20),
  cl      varchar2(10),
  dai     number,
  rong    number,
  cao     number,
  l_n     number,
  l_n_p1  number,
  l_n_p2  number,
  l_x     number,
  l_x_p1  number,
  l_x_p2  number,
  l_t     number,
  l_t_p1  number,
  l_t_p2  number,
  t_n     number,
  t_x     number,
  t_t     number,
  ngay_ht number,
  idvung  number

);
create unique index vt_sc_u0 on vt_sc(ma_dvi, kho, loai, nhom, ma_vt, nuoc, model, lo, dv, cl, dai, rong, cao, ngay_ht);
create index vt_sc_i1 on vt_sc (ma_dvi, loai, nhom, ma_vt);

drop table vt_ma_vt_dvq;
create table vt_ma_vt_dvq
(
  ma_dvi varchar2(20),
  nhom   varchar2(5),
  ma     varchar2(30),
  bt     number,
  dvt    nvarchar2(20),
  idvung number

);
create unique index vt_ma_vt_dvq_u0 on vt_ma_vt_dvq(ma_dvi, nhom, ma, dvt);

drop table vt_ma_vt_dvc;
create table vt_ma_vt_dvc
(
  ma_dvi varchar2(20),
  nhom   varchar2(5),
  ma     varchar2(30),
  bt     number,
  dvt_c  nvarchar2(20),
  dvt_m  nvarchar2(20),
  hs     number,
  idvung number

);
create unique index vt_ma_vt_dvc_u0 on vt_ma_vt_dvc(ma_dvi, nhom, ma, bt);
create index vt_ma_vt_dvc_i1 on vt_ma_vt_dvc (ma_dvi, nhom, ma, dvt_c, dvt_m);

drop table vt_ma_vt_ct;
create table vt_ma_vt_ct
(
  ma_dvi  varchar2(20),
  nhom    varchar2(5),
  ma      varchar2(30),
  bt      number,
  nhom_ct varchar2(5),
  ma_ct   varchar2(30),
  dvt_ct  nvarchar2(20),
  luong   number,
  idvung  number

);
create unique index vt_ma_vt_ct_u0 on vt_ma_vt_ct(ma_dvi, nhom, ma, bt);

drop table vt_ma_vt_hs;
create table vt_ma_vt_hs
(
  ma_dvi varchar2(20),
  nhom   varchar2(5),
  ma     varchar2(30),
  kt     number,
  hs     number,
  idvung number

);
create unique index vt_ma_vt_hs_u0 on vt_ma_vt_hs(ma_dvi, nhom, ma, kt);

drop table cc_ptu_2;
create table cc_ptu_2
(
  ma_dvi    varchar2(20),
  so_id     number,
  so_id_cc  number,
  so_id_ptu number,
  so_qd     varchar2(20),
  ngay      date,
  ma_nt     varchar2(5),
  tien      number,
  luong     number,
  ly_do     nvarchar2(400),
  so_id_nh  number,
  so_id_ps  number,
  nsd       varchar2(10),
  idvung    number

);
create unique index cc_ptu_2_u0 on cc_ptu_2(ma_dvi, so_id, so_id_nh);
create index cc_ptu_2_i1 on cc_ptu_2 (ma_dvi, so_id_cc);
create index cc_ptu_2_i2 on cc_ptu_2 (ma_dvi, so_id_nh);
create index cc_ptu_2_i3 on cc_ptu_2 (ma_dvi, so_id_ps);
create index cc_ptu_2_i4 on cc_ptu_2 (ma_dvi, so_id_ptu);

drop table pb_2;
create table pb_2
(
  ma_dvi   varchar2(20),
  so_id    number,
  bt       number,
  ngay_ht  number,
  so_id_ps number,
  tien     number,
  idvung   number

);
create unique index pb_2_u0 on pb_2(ma_dvi, so_id, bt);
create index pb_2_i2 on pb_2 (ma_dvi, so_id_ps);

drop table pb_1;
create table pb_1
(
  ma_dvi  varchar2(20),
  so_id   number,
  bt      number,
  ngay_ht number,
  l_ct    varchar2(1),
  ngay    date,
  tien    number,
  tra     number,
  idvung  number

);
create unique index pb_1_u0 on pb_1(ma_dvi, so_id, bt);

drop table pb_pb;
create table pb_pb
(
  ma_dvi varchar2(20),
  so_id  varchar2(20),
  ma_tk  varchar2(50),
  ma_tke varchar2(20),
  pt     number,
  bt     number,
  idvung number

);
create unique index pb_pb_u0 on pb_pb(ma_dvi, so_id, bt);

drop table kh_ma_hdong_dv;
create table kh_ma_hdong_dv
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  bt     number,
  ngay   number,
  ma_dv  varchar2(30),
  dv     nvarchar2(20),
  luong  number,
  gia    number,
  tien   number,
  idvung number

);
create unique index kh_ma_hdong_dv_u0 on kh_ma_hdong_dv(ma_dvi, ma, bt);

drop table kh_ma_hdong_vt;
create table kh_ma_hdong_vt
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  bt     number,
  ngay   number,
  nhom   varchar2(5),
  ma_vt  varchar2(30),
  nuoc   varchar2(10),
  model  varchar2(50),
  dv     nvarchar2(20),
  cl     varchar2(10),
  dai    number,
  rong   number,
  cao    number,
  luong  number,
  gia    number,
  tien   number,
  bhanh  number,
  idvung number

);
create unique index kh_ma_hdong_vt_u0 on kh_ma_hdong_vt(ma_dvi, ma, bt);

drop table kh_ma_hdong_da;
create table kh_ma_hdong_da
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  bt     number,
  ngay   number,
  nd     nvarchar2(400),
  tien   number,
  idvung number

);
create unique index kh_ma_hdong_da_u0 on kh_ma_hdong_da(ma_dvi, ma, bt);

drop table kh_ma_hdong_tt;
create table kh_ma_hdong_tt
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  ngay   number,
  tien   number,
  nd     nvarchar2(400),
  idvung number

);
create unique index kh_ma_hdong_tt_u0 on kh_ma_hdong_tt(ma_dvi, ma, ngay);

drop table kh_ma_hdong_phi;
create table kh_ma_hdong_phi
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  bt     number,
  dvi    varchar2(20),
  phong  varchar2(10),
  pt     number,
  idvung number

);
create unique index kh_ma_hdong_phi_u0 on kh_ma_hdong_phi(ma_dvi, ma, bt); 
create index kh_hdong_phi_i1 on kh_ma_hdong_phi (ma_dvi, dvi, ma, phong);
create index kh_hdong_phi_i2 on kh_ma_hdong_phi (ma_dvi, phong);

drop table kh_hdong_dh;
create table kh_hdong_dh
(
  ma_dvi   varchar2(20),
  so_id    number,
  ma       varchar2(20),
  ngay     number,
  tien     number,
  tien_qd  number,
  nd       nvarchar2(400),
  nsd      varchar2(10),
  ngay_nh  date,
  so_id_kt number,
  idvung   number

);
create unique index kh_hdong_dh_u0 on kh_hdong_dh(ma_dvi, so_id);
create index kh_hdong_dh_i1 on kh_hdong_dh (ma_dvi, ma);
create index kh_hdong_dh_i2 on kh_hdong_dh (ma_dvi, so_id_kt);

drop table kh_ma_hdong_th;
create table kh_ma_hdong_th
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  ngay   number,
  tien   number,
  idvung number

);
create unique index kh_ma_hdong_th_u0 on kh_ma_hdong_th(ma_dvi, ma, ngay);

drop table kh_hdong_vt_temp;
create global temporary table kh_hdong_vt_temp
(
  nhom  varchar2(5),
  ma_vt varchar2(30),
  nuoc  varchar2(10),
  model varchar2(50),
  dv    nvarchar2(20),
  cl    varchar2(10),
  dai   number,
  rong  number,
  cao   number,
  luong number,
  gia   number,
  tien  number
)
on commit preserve rows;

drop table kh_hdong_vt_temp1;
create global temporary table kh_hdong_vt_temp1
(
  nhom  varchar2(5),
  ma_vt varchar2(30),
  nuoc  varchar2(10),
  model varchar2(50),
  dv    nvarchar2(20),
  cl    varchar2(10),
  dai   number,
  rong  number,
  cao   number,
  luong number,
  gia   number,
  tien  number
)
on commit preserve rows;

drop table kh_hdong_dv_temp;
create global temporary table kh_hdong_dv_temp
(
  ma_dv varchar2(30),
  dv    nvarchar2(20),
  luong number,
  gia   number,
  tien  number
)
on commit preserve rows;

drop table kh_hdong_dv_temp1;
create global temporary table kh_hdong_dv_temp1
(
  ma_dv varchar2(30),
  dv    nvarchar2(20),
  luong number,
  gia   number,
  tien  number
)
on commit preserve rows;

drop table kh_hdong_da_temp;
create global temporary table kh_hdong_da_temp
(
  nd   nvarchar2(400),
  tien number
)
on commit preserve rows;

drop table kh_hdong_da_temp1;
create global temporary table kh_hdong_da_temp1
(
  nd   nvarchar2(400),
  tien number
)
on commit preserve rows;

drop table kh_hdong_dh_vt;
create table kh_hdong_dh_vt
(
  ma_dvi varchar2(20),
  so_id  number,
  bt     number,
  ma     varchar2(20),
  ngay   number,
  nhom   varchar2(5),
  ma_vt  varchar2(30),
  nuoc   varchar2(10),
  model  varchar2(50),
  dv     nvarchar2(20),
  cl     varchar2(10),
  dai    number,
  rong   number,
  cao    number,
  luong  number,
  gia    number,
  tien   number,
  idvung number

);
create unique index kh_hdong_dh_vt_u0 on kh_hdong_dh_vt(ma_dvi, so_id, bt);
create index kh_hdong_dh_vt_i1 on kh_hdong_dh_vt (ma_dvi, ma, ngay);

drop table kh_hdong_dh_dv;
create table kh_hdong_dh_dv
(
  ma_dvi varchar2(20),
  so_id  number,
  bt     number,
  ma     varchar2(20),
  ngay   number,
  ma_dv  varchar2(30),
  dv     nvarchar2(20),
  luong  number,
  gia    number,
  tien   number,
  idvung number

);
create unique index kh_hdong_dh_dv_u0 on kh_hdong_dh_dv(ma_dvi, so_id, bt);
create index kh_hdong_dh_dv_i1 on kh_hdong_dh_dv (ma_dvi, ma, ngay);

drop table kh_hdong_dh_da;
create table kh_hdong_dh_da
(
  ma_dvi varchar2(20),
  so_id  number,
  bt     number,
  ma     varchar2(20),
  ngay   number,
  nd     nvarchar2(400),
  tien   number,
  idvung number

);
create unique index kh_hdong_dh_da_u0 on kh_hdong_dh_da(ma_dvi, so_id, bt);
create index kh_hdong_dh_da_i1 on kh_hdong_dh_da (ma_dvi, ma, ngay);

drop table kt_kh_ttt_ct;
create table kt_kh_ttt_ct
(
  ma_dvi   varchar2(10),
  so_id    number,
  so_id_dt number,
  ma       varchar2(20),
  nd       nvarchar2(2000),
  so       number,
  idvung   number

);
create unique index kt_kh_ttt_ct_u0 on kt_kh_ttt_ct(ma_dvi, so_id, so_id_dt, ma);

drop table tv_3;
create table tv_3
(
  ma_dvi varchar2(20),
  so_id  number,
  bt     number,
  hang   nvarchar2(400),
  dv     nvarchar2(20),
  luong  number,
  gia    number,
  tien   number,
  bt_ct  number,
  idvung number

);
create unique index tv_3_u0 on tv_3(ma_dvi, so_id, bt_ct);

drop table hde;
create table hde
(
  ma_dvi   varchar2(20),
  so_id    number,
  md       varchar2(5),
  nv       varchar2(10),
  ps       varchar2(5),
  so_id_ps number,
  bt_ps    number,
  lan      number,
  ngay     number,
  kieu     varchar2(1),
  so_ct    varchar2(50),
  ma_kh    varchar2(50),
  ten      nvarchar2(500),
  dchi     nvarchar2(500),
  tax      varchar2(50),
  ma_nt    varchar2(3),
  tg       number,
  nd       nvarchar2(500),
  tien     number,
  tsuat    number,
  thue     number,
  ttoan    number,
  tien_qd  number,
  thue_qd  number,
  ttoan_qd number,
  ngay_ps  varchar2(20),
  nsd      varchar2(20),
  tt       varchar2(1),
  ngay_du  date,
  nguoi_du varchar2(20),
  ngay_ph  date,
  nd_ph    nvarchar2(1000),
  so_hd    varchar2(50)

);
create unique index hde_u0 on hde(ma_dvi, so_id);
create unique index hde_i1 on hde (ma_dvi, so_id_ps, bt_ps, lan);
create index hde_i2 on hde (ma_dvi, md, tt, nsd);
create index hde_i3 on hde (ma_dvi, so_hd);

drop table hde_hang;
create table hde_hang
(
  ma_dvi   varchar2(20),
  so_id    number,
  ma       varchar2(30),
  ten      nvarchar2(500),
  dvi      nvarchar2(50),
  gia      number,
  luong    number,
  tien     number,
  tsuat    number,
  thue     number,
  ttoan    number,
  gia_qd   number,
  tien_qd  number,
  thue_qd  number,
  ttoan_qd number
);
create index hde_hang_i1 on hde_hang (ma_dvi, so_id);

drop table hde_temp_hang;
create global temporary table hde_temp_hang
(
  ma       varchar2(30),
  ten      nvarchar2(500),
  dvi      nvarchar2(50),
  gia      number,
  luong    number,
  tien     number,
  tsuat    number,
  thue     number,
  ttoan    number,
  gia_qd   number,
  tien_qd  number,
  thue_qd  number,
  ttoan_qd number
)
on commit preserve rows;

drop table hde_temp_ch;
create global temporary table hde_temp_ch
(
  ngay     number,
  kieu     varchar2(1),
  so_ct    varchar2(50),
  ma_kh    varchar2(50),
  ten      nvarchar2(500),
  dchi     nvarchar2(500),
  tax      varchar2(30),
  ma_nt    varchar2(5),
  tg       number,
  nd       nvarchar2(500),
  tien     number,
  tsuat    number,
  thue     number,
  ttoan    number,
  tien_qd  number,
  thue_qd  number,
  ttoan_qd number
)
on commit preserve rows;

drop table cn_tt_temp;
create global temporary table cn_tt_temp
(
  ma_dvi   varchar2(20),
  so_id    number,
  bt       number,
  bt_tt    number,
  l_ct     varchar2(1),
  loai     varchar2(1),
  so_id_ps number,
  bt_ps    number,
  tien     number,
  tien_qd  number,
  phi      number,
  phi_qd   number,
  ngay_ht  number,
  idvung   number
)
on commit preserve rows;

drop table cn_tt_ps_temp;
create global temporary table cn_tt_ps_temp
(
  so_id   number,
  bt      number,
  ngay_ht number,
  nd      nvarchar2(400),
  ton     number,
  ton_qd  number
)
on commit preserve rows;

drop table cn_tt_ch_temp;
create global temporary table cn_tt_ch_temp
(
  so_id number,
  so_ct varchar2(20),
  nd    nvarchar2(400),
  htoan varchar2(1),
  nsd   varchar2(10)
)
on commit preserve rows;

drop table kt_ma_tke;
create table kt_ma_tke
(
  ma_dvi varchar2(20),
  nhom   varchar2(5),
  ma     varchar2(20),
  ten    nvarchar2(100),
  loai   varchar2(1),
  tc     varchar2(1),
  pb     varchar2(1),
  ps     varchar2(1),
  nsd    varchar2(10),
  idvung number,
  constraint kt_ma_tke_p primary key (ma_dvi, nhom, ma)
);


drop table kt_ma_tke;
create table kt_ma_tke
(
  ma_dvi varchar2(20),
  nhom   varchar2(5),
  ma     varchar2(20),
  ten    nvarchar2(100),
  loai   varchar2(1),
  tc     varchar2(1),
  pb     varchar2(1),
  ps     varchar2(1),
  nsd    varchar2(10),
  idvung number,
  constraint kt_ma_tke_p primary key (ma_dvi, nhom, ma)
);

drop table KH_MA_LOAI_DN;
create table KH_MA_LOAI_DN
(
  ma_dvi VARCHAR2(20),
  ma     VARCHAR2(10),
  ten    NVARCHAR2(200),
  ma_ct  VARCHAR2(10),
  nsd    VARCHAR2(10),
  idvung NUMBER,
  constraint KH_MA_LOAI_DN_P primary key (MA_DVI, MA)
);


drop table bh_bt_thoi_pb;
create table bh_bt_thoi_pb
(
  ma_dvi   varchar2(10),
  so_id    number,
  bt       number,
  ngay_ht  number,
  dvi_xl   varchar2(10),
  phong    varchar2(10),
  so_id_hd number,
  lh_nv    varchar2(10),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  so_id_kt number
)
partition by list (ma_dvi)(
  partition bh_bt_thoi_pb_001 values ('001'),
  partition bh_bt_thoi_pb_defa values (default)
);
create index bh_bt_thoi_pb_i1 on bh_bt_thoi_pb (so_id);

drop table bh_hd_goc_nb;
create table bh_hd_goc_nb
(
  ma_dvi   varchar2(10),
  so_id    number,
  so_id_g  number,
  so_id_d  number,
  so_id_kt number,
  ngay_ht  number,
  kieu_hd  varchar2(1),
  so_hd    varchar2(20),
  tien     number,
  ngay_nh  date
)
partition by list (ma_dvi)
(
  partition bh_hd_goc_nb_001 values ('001'),
  partition bh_hd_goc_nb_002 values ('002'),
  partition bh_hd_goc_nb_050 values ('050', '052'),
  partition bh_hd_goc_nb_defa values (default)
);
create index bh_hd_goc_nb_i1 on bh_hd_goc_nb (so_id_kt);
create index bh_hd_goc_nb_u1 on bh_hd_goc_nb (so_id);

drop table bh_ma_dk_bs;
create table bh_ma_dk_bs
(
  ma_dvi    varchar2(10),
  ma_dk     varchar2(30),
  ma        varchar2(10),
  ten       nvarchar2(400),
  ten_e     varchar2(200),
  noidung   nvarchar2(2000),
  noidung_e varchar2(1000),
  nsd       varchar2(10),
  constraint bh_ma_dk_bs_p primary key (ma_dvi, ma_dk, ma)
);


drop table vt_ma_nhom;
create table vt_ma_nhom
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  nhom   varchar2(1),
  nsd    varchar2(10),
  idvung number,
  constraint vt_ma_nhom_p primary key (ma_dvi, ma)
);

drop table cn_ma_cc;
create table cn_ma_cc
(
  ma_dvi varchar2(20),
  ma     varchar2(20),
  ten    nvarchar2(200),
  ten_e  varchar2(200),
  ten_t  varchar2(200),
  dchi   nvarchar2(200),
  tax    varchar2(30),
  nhang  varchar2(10),
  ma_tk  varchar2(50),
  ten_nh nvarchar2(200),
  loai   varchar2(5),
  kvuc   varchar2(10),
  phone  varchar2(20),
  fax    varchar2(20),
  ngay_d date,
  ngay_c date,
  ma_ct  varchar2(20),
  nsd    varchar2(10),
  idvung number,
  constraint cn_ma_cc_p primary key (ma_dvi, ma)
);
create index cn_ma_cc_i1 on cn_ma_cc (ma_dvi, ngay_d);
create index cn_ma_cc_i2 on cn_ma_cc (ma_dvi, ma_ct);
create index cn_ma_cc_i3 on cn_ma_cc (ma_dvi, tax);
create index cn_ma_cc_i4 on cn_ma_cc (ma_dvi, nsd);


create table kh_hdong_nb_dt;
create table kh_hdong_nb_dt
(
  ma_dvi  varchar2(20),
  so_id   number,
  bt      number,
  ma_cb   varchar2(10),
  tien    number,
  tien_qd number,
  idvung  number,
  constraint kh_hdong_nb_dt_p primary key (ma_dvi, so_id, bt)
);

drop table kh_hdong_nb_phi;
create table kh_hdong_nb_phi
(
  ma_dvi  varchar2(20),
  so_id   number,
  bt      number,
  dvi     varchar2(20),
  phong   varchar2(10),
  ma      varchar2(20),
  ma_nt   varchar2(5),
  tien    number,
  tien_qd number,
  idvung  number,
  constraint kh_hdong_nb_phi_p primary key (ma_dvi, so_id, bt)
);


drop table kh_hdong_tk;
create table kh_hdong_tk
(
  ma_dvi varchar2(20),
  ngay   number,
  ma     varchar2(5),
  ma_tk  varchar2(30),
  nsd    varchar2(10),
  idvung number,
  constraint kh_hdong_tk_p primary key (ma_dvi, ngay, ma)
)

drop table kh_ma_kvuc_temp_1;
create global temporary table kh_ma_kvuc_temp_1
(
  ma    varchar2(20),
  ten   nvarchar2(200),
  ma_ct varchar2(20)
)
on commit preserve rows;

drop table kh_ma_kvuc_temp_2;
create global temporary table kh_ma_kvuc_temp_2
(
  ma  varchar2(20),
  ten nvarchar2(300)
)
on commit preserve rows;


drop table kt_ma_lc;
create table kt_ma_lc
(
  ma_dvi varchar2(20),
  ma     varchar2(10),
  ten    nvarchar2(200),
  tc     varchar2(1),
  ma_ql  varchar2(10),
  nsd    varchar2(10),
  idvung number,
  constraint kt_ma_lc_p primary key (ma_dvi, ma)
);

drop table tbh_mu_ps_tt;
create table tbh_mu_ps_tt
(
  ma_dvi   varchar2(10),
  so_id_ps number,
  bt       number,
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  so_id_tt number,
  constraint tbh_mu_ps_tt_p primary key (ma_dvi, so_id_ps, bt)
);
create index tbh_mu_ps_tt_i1 on tbh_mu_ps_tt (ma_dvi, so_id_tt);


drop table cn_sc_temp_ct;
create global temporary table cn_sc_temp_ct
(
  ma_cn    varchar2(21),
  ma_nt    varchar2(5),
  ma_tk    varchar2(20),
  no_dk    number,
  co_dk    number,
  no_ps    number,
  co_ps    number,
  no_ck    number,
  co_ck    number,
  no_lk    number,
  co_lk    number,
  no_dk_qd number,
  co_dk_qd number,
  no_ps_qd number,
  co_ps_qd number,
  no_ck_qd number,
  co_ck_qd number,
  no_lk_qd number,
  co_lk_qd number
)
on commit preserve rows;

drop table ts_ptu_2;
create table ts_ptu_2
(
  ma_dvi    varchar2(20),
  so_id     number,
  so_id_ts  number,
  so_id_ptu number,
  so_qd     varchar2(20),
  ngay      date,
  ma_nt     varchar2(5),
  tien      number,
  luong     number,
  ly_do     nvarchar2(400),
  so_id_nh  number,
  so_id_ps  number,
  nsd       varchar2(10),
  idvung    number,
  constraint ts_ptu_2_p primary key (ma_dvi, so_id, so_id_nh)
);
create index ts_ptu_2_i1 on ts_ptu_2 (ma_dvi, so_id_ts);
create index ts_ptu_2_i2 on ts_ptu_2 (ma_dvi, so_id_nh);
create index ts_ptu_2_i3 on ts_ptu_2 (ma_dvi, so_id_ps);
create index ts_ptu_2_i4 on ts_ptu_2 (ma_dvi, so_id_ptu);


drop table ts_ptu_1;
create table ts_ptu_1
(
  ma_dvi   varchar2(20),
  so_id    number,
  so_id_ts number,
  so_ptu   varchar2(20),
  ten      nvarchar2(100),
  model    varchar2(50),
  seri     varchar2(50),
  don_vi   nvarchar2(100),
  idvung   number,
  constraint ts_ptu_1_p primary key (ma_dvi, so_id)
);
create unique index ts_ptu_1_i1 on ts_ptu_1 (ma_dvi, so_ptu);
create index ts_ptu_1_i2 on ts_ptu_1 (ma_dvi, so_id_ts);


