-- Phat sinh tai

drop table tbh_ps;
create table tbh_ps(
    ma_dvi varchar2(10),
    so_id number,
    so_id_nv number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    ps varchar2(1),         -- C-Chi, T-Thu
    kieu varchar2(1),       -- C:di co dinh, T:di tam thoi, X:XOL
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt number,
    so_id_xl number);
CREATE unique INDEX tbh_ps_u1 on tbh_ps(so_id,so_id_nv,bt);
CREATE INDEX tbh_ps_i1 on tbh_ps(so_id_ta_ps);
CREATE INDEX tbh_ps_i2 on tbh_ps(so_id_ta_hd);
CREATE INDEX tbh_ps_i3 on tbh_ps(ngay_ht,kieu,nv);
CREATE INDEX tbh_ps_i5 on tbh_ps(so_id_xl);

drop table tbh_ps_pbo;
create table tbh_ps_pbo(
    ma_dvi varchar2(10),
    so_id number,
    so_id_nv number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(10),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    bt number,
    btt number);
CREATE unique INDEX tbh_ps_pbo_u1 on tbh_ps_pbo(so_id,so_id_nv,btt);
CREATE INDEX tbh_ps_pbo_i1 on tbh_ps_pbo(so_id,so_id_ta_ps,bt);

drop table tbh_ps_ton;
create table tbh_ps_ton(
    ma_dvi varchar2(10),
    so_id number,
    so_id_nv number,
    so_id_hd number,
    so_id_dt number,
    tien number,
    thue number,
    hhong number,
    bt number);
CREATE unique INDEX tbh_ps_ton_u1 on tbh_ps_ton(so_id,so_id_nv,so_id_hd,so_id_dt,bt);

drop table tbh_ps_temp;
create GLOBAL TEMPORARY table tbh_ps_temp(
    ma_ta varchar2(20),
    lh_nv varchar2(20),
    ma_nt varchar2(20),
    tien number)
    ON COMMIT delete ROWS;

drop table tbh_ps_tt_temp;
create GLOBAL TEMPORARY table tbh_ps_tt_temp
    (ma_dvi varchar2(10),
    so_id number)
    ON COMMIT delete ROWS;

drop table tbh_ps_tt_temp1;
create GLOBAL TEMPORARY table tbh_ps_tt_temp1
    (ma_dvi varchar2(10),
    so_id number)
    ON COMMIT delete ROWS;

drop table tbh_ps_pbo_temp;
create GLOBAL TEMPORARY table tbh_ps_pbo_temp(
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number)
    ON COMMIT delete ROWS;

drop table tbh_ps_pbo_temp1;
create GLOBAL TEMPORARY table tbh_ps_pbo_temp1(
    so_id_ta_ps number  ,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5))
    ON COMMIT delete ROWS;

drop table tbh_ps_pbo_temp2;
create GLOBAL TEMPORARY table tbh_ps_pbo_temp2(
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),	
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number)
    ON COMMIT delete ROWS;

drop table tbh_ps_ton_temp;
create GLOBAL TEMPORARY table tbh_ps_ton_temp(
    tien number,
    thue number,
    hhong number,
    bt number)
    ON COMMIT delete ROWS;

drop table tbh_xl;
create table tbh_xl
    (ma_dvi varchar2(10),
    so_id_xl number,
    ngay_ht number,
    so_ct varchar2(20),
    kieu varchar2(1),
    nv varchar2(10),
    nha_bh varchar2(20),
    so_id_ta number,
    ma_nt varchar2(5),
    tra number,
    nsd varchar2(10));
    CREATE unique INDEX tbh_xl_u1 on tbh_xl(so_id_xl);
	CREATE INDEX tbh_xl_i1 on tbh_xl(ngay_ht);

drop table tbh_xl_ct;
create table tbh_xl_ct
    (ma_dvi varchar2(10),
    so_id_xl number,
    bt number,
    ma_dvi_ps varchar2(10),
    so_id_ps number,
    so_id_nv number,
    so_id_ta_ps number,
    bt_ps number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    tien_tra number,
    thue_tra number,
    hhong_tra number);
CREATE INDEX tbh_xl_ct_i1 on tbh_xl_ct(so_id_xl);
CREATE INDEX tbh_xl_ct_i2 on tbh_xl_ct(so_id_ps,so_id_ta_ps,bt_ps);

drop table tbh_xl_txt;
create table tbh_xl_txt
    (ma_dvi varchar2(10),
    so_id_xl number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_xl_txt_i1 on tbh_xl_txt(so_id_xl);

drop table tbh_xl_ton;
create table tbh_xl_ton
    (ma_dvi varchar2(10),
    so_id_xl number);
CREATE INDEX tbh_xl_ton_i1 on tbh_xl_ton(so_id_xl);

drop table tbh_xl_pbo;
create table tbh_xl_pbo
    (ma_dvi varchar2(10),
    so_id_xl number,
    ma_dvi_ps varchar2(10),
    so_id_ps number,
    so_id_nv number,
    bt_ps number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt number);
CREATE INDEX tbh_xl_pbo_i1 on tbh_xl_pbo(so_id_xl);

drop table tbh_xl_dc;
create table tbh_xl_dc
    (ma_dvi varchar2(10),
    so_id_xl number,
    ngay_ht number,
    so_ct varchar2(20),
    kieu varchar2(1),
    loai varchar2(5),
    nha_bh varchar2(20),
    nt_tra varchar2(5),
    tra number,
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt_xl number,
    so_id_dc number,
    so_id_kt number,
    ngay_nh date);
CREATE INDEX tbh_xl_dc_i1 on tbh_xl_dc(so_id_xl);
CREATE INDEX tbh_xl_dc_i2 on tbh_xl_dc(so_id_dc,ngay_ht);
CREATE INDEX tbh_xl_dc_i3 on tbh_xl_dc(so_id_kt);

drop table tbh_xl_dc_pbo;
create table tbh_xl_dc_pbo
    (ma_dvi varchar2(10),
    so_id_xl number,
    ma_dvi_ps varchar2(10),
    so_id_ps number,
    so_id_nv number,
    bt_ps number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt number);
CREATE INDEX tbh_xl_dc_pbo_i1 on tbh_xl_dc_pbo(so_id_xl);

drop table tbh_xl_dc_temp;
create GLOBAL TEMPORARY table tbh_xl_dc_temp
    (so_id_xl number,
    ngay_ht number,
    so_ct varchar2(50),
    loai varchar2(5),
    tra number,
    tien number,
    thue number,
    hhong number,
    tung number)
    ON COMMIT delete ROWS;

drop table tbh_xl_dc_temp1;
create GLOBAL TEMPORARY table tbh_xl_dc_temp1
    (so_id_xl number,
    loai varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number)
    ON COMMIT delete ROWS;

drop table tbh_xl_dc_temp2;
create GLOBAL TEMPORARY table tbh_xl_dc_temp2
    (so_id_xl number,
    loai varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number)
    ON COMMIT delete ROWS;

drop table tbh_xl_dc_temp3;
create GLOBAL TEMPORARY table tbh_xl_dc_temp3
    (so_id_xl number,
    ngay_ht number,
    so_ct varchar2(50),
    tra number,
    tien number,
    thue number,
    hhong number,
    tung number)
    ON COMMIT delete ROWS;

drop table tbh_xl_pbo_temp;
create GLOBAL TEMPORARY table tbh_xl_pbo_temp(
    ma_ta varchar2(20),
    nha_bh varchar2(20),    
    tien number,
    thue number,
    hhong number)
    ON COMMIT delete ROWS;

drop table tbh_xl_pbo_temp1;
create GLOBAL TEMPORARY table tbh_xl_pbo_temp1(
    ma_ta varchar2(20),
    nha_bh varchar2(20),    
    tien number,
    thue number,
    hhong number)
    ON COMMIT delete ROWS;

drop table tbh_xl_pbo_temp2;
create GLOBAL TEMPORARY table tbh_xl_pbo_temp2
    (ma_dvi_ps varchar2(10),
    so_id_ps number,
    so_id_nv number,
    bt_ps number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt number)
    ON COMMIT delete ROWS;

drop table tbh_xl_pbo_temp3;
create GLOBAL TEMPORARY table tbh_xl_pbo_temp3
    (loai varchar2(5),
    nha_bh varchar2(20),
    nt_tra varchar2(5),
    tra number,
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number)
    ON COMMIT delete ROWS;

drop table tbh_dc;
create table tbh_dc
    (ma_dvi varchar2(10),
    so_id_dc number,
    ngay_ht number,
    kieu varchar2(1),
    nha_bh varchar2(20),
    so_bk varchar2(20),
    so_dc varchar2(20),
    ng_dc number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    nsd varchar2(10),
    so_id_tt number,
    so_id_kt number,
    ngay_nh date);
CREATE unique INDEX tbh_dc_u1 on tbh_dc(so_id_dc);
CREATE INDEX tbh_dc_i1 on tbh_dc(ngay_ht);
CREATE INDEX tbh_dc_i2 on tbh_dc(so_id_tt);
CREATE INDEX tbh_dc_i3 on tbh_dc(so_id_kt);
CREATE INDEX tbh_dc_i5 on tbh_dc(ng_dc);

drop table tbh_dc_ct;
create table tbh_dc_ct
    (ma_dvi varchar2(20),
    so_id_dc number,
    bt number,
	so_id_xl number,
	tra number);
CREATE INDEX tbh_dc_ct_i1 on tbh_dc_ct(so_id_dc);
CREATE INDEX tbh_dc_ct_i2 on tbh_dc_ct(so_id_xl);

drop table tbh_dc_pt;
create table tbh_dc_pt
    (ma_dvi varchar2(10),
    so_id_dc number,
    ma_dvi_ps varchar2(10),
    so_id_ps number,
    bt_ps number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt number);
CREATE INDEX tbh_dc_pt_i1 on tbh_dc_pt(so_id_dc);
CREATE INDEX tbh_dc_pt_i2 on tbh_dc_pt(ngay_ht);
CREATE INDEX tbh_dc_pt_i3 on tbh_dc_pt(goc,so_id_ps);

drop table tbh_dc_txt;
create table tbh_dc_txt
    (ma_dvi varchar2(10),
    so_id_dc number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_dc_txt_i1 on tbh_dc_txt(so_id_dc);

drop table tbh_dc_temp1;
create GLOBAL TEMPORARY table tbh_dc_temp1
    (ma_dvi_ps varchar2(10),
    so_id_ps number)
    ON COMMIT delete ROWS;

drop table tbh_dc_temp2;
create GLOBAL TEMPORARY table tbh_dc_temp2
    (ma_dvi varchar2(10),
    so_id_dc number,
    ma_dvi_ps varchar2(10),
    so_id_ps number,
    bt_ps number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ngay_ht number,
    ps varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    loai varchar2(5),
    goc varchar2(10),
    ma_ta varchar2(20),
    nha_bh varchar2(20),
    pthuc varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    hhong number,
    tien_qd number,
    thue_qd number,
    hhong_qd number,
    bt number)
    ON COMMIT delete ROWS;

drop table tbh_tt;
create table tbh_tt
    (ma_dvi varchar2(10),
    so_id_tt number,
    ngay_ht number,
    so_ct varchar2(20),
    nha_bh varchar2(20),
    nt_tra varchar2(5),
    pt_tra varchar2(1),
    tra number,
    tra_qd number,
    nt_tt varchar2(5),
    ttoan number,
    ttoan_qd number,
    nsd varchar2(10),
    so_id_kt number,
    ngay_nh date);
CREATE unique INDEX tbh_tt_u1 on tbh_tt(so_id_tt);
CREATE INDEX tbh_tt_i1 on tbh_tt(ngay_ht);
CREATE INDEX tbh_tt_i2 on tbh_tt(so_id_kt);

drop table tbh_tt_ct;
create table tbh_tt_ct  
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id_dc number,
    tra number,
    tra_qd number);
CREATE INDEX tbh_tt_ct_i1 on tbh_tt_ct(so_id_tt);

drop table tbh_tt_txt;
create table tbh_tt_txt
    (ma_dvi varchar2(10),
    so_id_tt number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_tt_txt_i1 on tbh_tt_txt(so_id_tt);

drop table tbh_xl_tso_temp1;
create GLOBAL TEMPORARY table tbh_xl_tso_temp1
    (n1 number)
    ON COMMIT delete ROWS;

drop table tbh_xl_tso_temp2;
create GLOBAL TEMPORARY table tbh_xl_tso_temp2
    (n1 number)
    ON COMMIT delete ROWS;

drop table tbh_dc_dp;
create table tbh_dc_dp
(
  ma_dvi   varchar2(10),
  so_id_dc number,
  ngay_dp  number,
  kieu     varchar2(1),
  nha_bh   varchar2(20),
  so_bk    varchar2(20),
  nt_tra   varchar2(5),
  tra      number,
  tra_qd   number
);
create index tbh_dc_dp_i1 on tbh_dc_dp (so_id_dc);

drop table tbh_dc_dp_ct;
create table tbh_dc_dp_ct
(
  ma_dvi   varchar2(20),
  so_id_dc number,
  ngay_dp  number,
  so_id_xl number
);
create index tbh_dc_dp_ct_i1 on tbh_dc_dp_ct (so_id_dc);

drop table tbh_dc_dp_pt;
create table tbh_dc_dp_pt
(
  ma_dvi      varchar2(10),
  so_id_dc    number,
  ngay_dp     number,
  ma_dvi_ps   varchar2(10),
  so_id_ps    number,
  bt_ps       number,
  so_id_ta_ps number,
  so_id_ta_hd number,
  ps          varchar2(1),
  kieu        varchar2(1),
  nv          varchar2(10),
  loai        varchar2(5),
  goc         varchar2(10),
  ma_ta       varchar2(20),
  nha_bh      varchar2(20),
  pthuc       varchar2(1),
  ma_nt       varchar2(5),
  tien        number,
  thue        number,
  hhong       number,
  tien_qd     number,
  thue_qd     number,
  hhong_qd    number
);
create index tbh_dc_dp_pt_i1 on tbh_dc_dp_pt (so_id_dc, ngay_dp);