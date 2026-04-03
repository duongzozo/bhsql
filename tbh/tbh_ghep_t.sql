drop table tbh_ghep;
create table tbh_ghep(
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    so_ct varchar2(20),
    kieu varchar2(1),           -- G-Goc, B-Bo sung, T-Tai tuc
    so_ctG varchar2(20),
    ngay_hl number,
    ngay_kt number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    pphap varchar2(1),            -- D-Prorata, M-Toan hop dong
    nguon varchar2(1),            -- B-Ban hang, T-Thuc thu, N-Tra ngay
    so_id_d number,
    so_id_g number,
    nsd varchar2(10),
    ngay_nh date);
CREATE unique INDEX tbh_ghep_u0 on tbh_ghep (so_id);
CREATE unique INDEX tbh_ghep_u1 on tbh_ghep (so_ct);
CREATE INDEX tbh_ghep_i1 on tbh_ghep (ngay_ht,nv);
CREATE INDEX tbh_ghep_i2 on tbh_ghep (so_id_d);
CREATE INDEX tbh_ghep_i3 on tbh_ghep (so_id_g);

drop table tbh_ghep_hd;
create table tbh_ghep_hd(
 so_id number,
 ma_dvi_hd varchar2(10),
 so_hd varchar2(20),
 so_id_hd number,
 so_id_dt number,
    ten nvarchar2(500),
    so_idC number,
 bt number);
CREATE INDEX tbh_ghep_hd_i1 on tbh_ghep_hd (so_id);
CREATE INDEX tbh_ghep_hd_i2 on tbh_ghep_hd (ma_dvi_hd,so_id_hd,so_id_dt);

drop table tbh_ghep_ky;
create table tbh_ghep_ky(
    so_id number,
    ngay_hl number,
    ma_ta varchar2(10),
    so_id_ta number,
    so_hd_ta varchar2(20),
    pthuc varchar2(1),
    pt number,
    tien number,
    phi number,
    bt number);
CREATE INDEX tbh_ghep_ky_i1 on tbh_ghep_ky(so_id);

drop table tbh_ghep_phi;
create table tbh_ghep_phi(
    so_id number,
    ngay_hl number,
    ma_ta varchar2(10),
    so_id_ta number,
    so_hd_ta varchar2(20),
    pthuc varchar2(1),
    nha_bh varchar2(20),
    kieu varchar2(1),
    pt number,     -- Ty le tai
    ptt number,     -- Ty le tham gia
    tien number,
    phi number,
    pt_hh number,
    hhong number,
    tl_thue number,
    thue number,
    nha_bhC varchar2(20),
    bt number);
CREATE INDEX tbh_ghep_phi_i1 on tbh_ghep_phi(so_id);

drop table tbh_ghep_pbo;
create table tbh_ghep_pbo(
    so_id number,
    ngay_hl number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    nha_bh varchar2(20),
    kieu varchar2(1),
    nha_bhC varchar2(20),
    ma_ta varchar2(10),
    lh_nv varchar2(10),
    pthuc varchar2(1),
    pt number,
    pt_hh number,
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    hhong number,
    thue number);
CREATE INDEX tbh_ghep_pbo_i1 on tbh_ghep_pbo(so_id);
CREATE INDEX tbh_ghep_pbo_i2 on tbh_ghep_pbo(ma_dvi_hd,so_id_hd);

drop table tbh_ghep_txt;
create table tbh_ghep_txt(
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_ghep_txt_i1 on tbh_ghep_txt(so_id);

drop table tbh_ghep_nv_temp0;
create GLOBAL TEMPORARY table tbh_ghep_nv_temp0(
    ma_ta varchar2(10),
    tien number,
    phi number,
    pt_conH number,
    tien_conH number,
    ta_tlH number,
    ta_tienH number,
    do_tl number,
    do_tien number,
    ta_tl number,
    ta_tien number,
    tm_tl number,
    tm_tien number,
    ve_tl number,
    ve_tien number,
    pt_con number,
    tien_con number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_temp;
create GLOBAL TEMPORARY table tbh_ghep_nv_temp(
 ma_ta varchar2(10),
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number,
 do_tl number,
 do_tien number,
 ta_tl number,
 ta_tien number,
    tm_tl number,
    tm_tien number,
 ve_tl number,
 ve_tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_temp1;
create GLOBAL TEMPORARY table tbh_ghep_nv_temp1(
    so_id number,
    ma_ta varchar2(20),
    lh_nv varchar2(10),
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    do_tl number,
    do_tien number,
    ta_tl number,
    ta_tien number,
    tm_tl number,
    tm_tien number,
    ve_tl number,
    ve_tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_temp2;
create GLOBAL TEMPORARY table tbh_ghep_nv_temp2(
 ma_ta varchar2(10),
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number,
 do_tl number,
 do_tien number,
 ta_tl number,
 ta_tien number,
    tm_tl number,
    tm_tien number,
 ve_tl number,
 ve_tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_temp3;
create GLOBAL TEMPORARY table tbh_ghep_nv_temp3(
    so_id number,
    ma_ta varchar2(10),
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    do_tl number,
    do_tien number,
    ta_tl number,
    ta_tien number,
    tm_tl number,
    tm_tien number,
    ve_tl number,
    ve_tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp(
    so_id_ta number,
    pthuc varchar2(10),
    ma_ta varchar2(10), 
    pt number,
    tien number,
    tlp number,
    tu number,
 den number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp1;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp1(
 so_id_ta number,
 pthuc varchar2(10),
 ma_ta varchar2(10), 
 pt number,
 tien number,
 so_hd varchar2(20),
 ten nvarchar2(500))
 ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp2;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp2(
    so_id_ta number,
    nha_bh varchar2(20),
    kieu varchar2(1),
    pt number,
    phi number,
    pt_hh number,
    hhong number,
    tl_thue number,
    thue number,
    bt number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp3;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp3(
    so_id_ta number,
    nha_bh varchar2(20),
    kieu varchar2(1),
    pt number,
    tien number,
    phi number,
    pt_hh number,
    hhong number,
    tl_thue number,
    thue number,
    bt number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp4;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp4(
    so_id_ta number,
    nha_bh varchar2(20),
    kieu varchar2(1),
    pt number,
    tien number,
    phi number,
    pt_hh number,
    hhong number,
    tl_thue number,
    thue number,
    bt number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp5;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp5(
    ngay number,
    so_id_ta number,
    so_hd_ta varchar2(20),
    pthuc varchar2(1),
    ma_ta varchar2(10),
    tienG number,                  -- Tien HD
    phiG number,                   -- Phi HD
    ptT number,                    -- % tai
    tienT number,           -- Tien tai
    phiT number,            -- Phi tai
    nbh varchar2(20),    
    nbhC varchar2(20),      -- Nha BH chinh
    kieu varchar2(1),       -- C-Chinh, P-Phu
    ptC number,             --  Ty le tham gia giua cac nha/so tai
    pt number,              -- Ty le/hd
    tien number,            -- Tien sau chia
    phi number,             -- Phi sau chia
    pt_hh number,
    hhong number,
    tl_thue number,
    thue number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp6;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp6(
    so_id_ta number,
    so_hd_ta varchar2(20),
    ma_ta varchar2(10),
    nbh varchar2(20),    
    nbhC varchar2(20),      -- Nha BH chinh
    kieu varchar2(1),       -- C-Chinh, P-Phu
    pt number,              -- Ty le/hd
    tien number,            -- Tien sau chia
    phi number,             -- Phi sau chia
    pt_hh number,
    hhong number,
    tl_thue number,
    thue number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_tl_temp7;
create GLOBAL TEMPORARY table tbh_ghep_tl_temp7(
    ngay number,
    so_id_ta number,
    so_hd_ta varchar2(20),
    pthuc varchar2(1),
    ma_ta varchar2(10),
    pt number,
    tien number,
    phi number)
    ON COMMIT delete ROWS;

drop table tbh_ghep_phi_temp;
create GLOBAL TEMPORARY table tbh_ghep_phi_temp(
 pthuc varchar2(1),
 ma_ta varchar2(10),
 nha_bh varchar2(20),
 pt number,
 tien number,
 phi number,
 tl_thue number,
 thue number,
 pt_hh number,
 hhong number)
ON COMMIT delete ROWS;

drop table tbh_ghep_phi_tempN;
create GLOBAL TEMPORARY table tbh_ghep_phi_tempN(
 pthuc varchar2(1),
 ma_ta varchar2(10),
 nha_bh varchar2(20),
 pt number,
 tien number,
 phi number,
 tl_thue number,
 thue number,
 pt_hh number,
 hhong number)
ON COMMIT delete ROWS;

drop table tbh_ghep_phi_temp1;
create GLOBAL TEMPORARY table tbh_ghep_phi_temp1(
 ma_ta varchar2(10),
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number)
ON COMMIT delete ROWS;

drop table tbh_ghep_phi_temp2;
create GLOBAL TEMPORARY table tbh_ghep_phi_temp2(
 ma_ta varchar2(10),
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number)
ON COMMIT delete ROWS;

drop table tbh_ghep_ky_temp;
create GLOBAL TEMPORARY table tbh_ghep_ky_temp(
 ngay_hl number,
 so_id_ta number,
 pthuc varchar2(1),
 ma_ta varchar2(10),
 pt number,
 tien number,
 phi number)
 ON COMMIT delete ROWS;

drop table tbh_ghep_ky_phi_temp;
create GLOBAL TEMPORARY table tbh_ghep_ky_phi_temp(
 ngay_hl number,
 so_id_ta number,
 pthuc varchar2(1),
 ma_ta varchar2(10),
 nha_bh varchar2(20),
 pt number,
 tien number,
 phi number,
 tl_thue number,
 thue number,
 pt_hh number,
 hhong number)
ON COMMIT delete ROWS;

drop table tbh_ghep_pbo_temp;
create GLOBAL TEMPORARY table tbh_ghep_pbo_temp(
    ngay_hl number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    nha_bh varchar2(20),
    kieu varchar2(1),
    nha_bhC varchar2(20),
    ma_ta varchar2(10),
    lh_nv varchar2(10),
    so_id_hd_ta number,
    pthuc varchar2(1),
    pt number,
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    hhong number,
 thue number,
    bt number)
ON COMMIT delete ROWS;

drop table tbh_ghep_kytt_temp;
create GLOBAL TEMPORARY table tbh_ghep_kytt_temp(
 ngay number,
 ma_nt varchar2(5),
 tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_phh_temp;
create GLOBAL TEMPORARY table tbh_ghep_phh_temp
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    dvi nvarchar2(500),
    ddiem nvarchar2(500));

drop table tbh_ghep_ps_temp;
create GLOBAL TEMPORARY table tbh_ghep_ps_temp(
    ps varchar2(3),
    so_id_taB number,
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    pthuc varchar2(1),
    ma_ta varchar2(10),
    nha_bh varchar2(20),
    phi number,
    thue number,
    hhong number)
ON COMMIT delete ROWS;

drop table tbh_ghep_ps_temp1;
create GLOBAL TEMPORARY table tbh_ghep_ps_temp1(
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    pthuc varchar2(1),
    ma_ta varchar2(10),
    nha_bh varchar2(20),
    phi number,
    thue number,
    hhong number)
ON COMMIT delete ROWS;

drop table tbh_ghep_ps_temp2;
create GLOBAL TEMPORARY table tbh_ghep_ps_temp2(
    so_id_ta_ps number,
    so_id_ta_hd number,
    ma_dvi_hd varchar2(10),
    so_id_hd number,
    so_id_dt number,
    pthuc varchar2(1),
    ma_ta varchar2(10),
    nha_bh varchar2(20),
    phi number,
    thue number,
    hhong number)
ON COMMIT delete ROWS;

drop table tbh_ttta_temp1;
create GLOBAL TEMPORARY table tbh_ttta_temp1(
    so_id_dt number,
    lh_nv varchar2(10),
    nt_tien varchar2(5),
    tien number,
    ta_tl number,
    ta_tien number)
ON COMMIT delete ROWS;

drop table tbh_ttta_temp;
create GLOBAL TEMPORARY table tbh_ttta_temp(
    ten nvarchar2(500),
    so_id_dt number,
    lh_nv varchar2(10),
    nt_tien varchar2(5),
    tien number,
    ta_tl number,
    ta_tien number)
ON COMMIT delete ROWS;

drop table tbh_ttcu_temp;
create GLOBAL TEMPORARY table tbh_ttcu_temp(
    pthuc varchar2(1),
    ma_ta varchar2(10),
    pt number,
    tien number,
    phi number,
    hhong number)
ON COMMIT delete ROWS;

drop table tbh_ghep_lke_xlta_temp;
create GLOBAL TEMPORARY table tbh_ghep_lke_xlta_temp(
    so_id_dt number,
    ten nvarchar2(400),
    so_ct varchar2(50),
    ngay number,
    kieu varchar2(1),
    so_id_ta number,
    so_id_ta_d number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_tempM1;
create GLOBAL TEMPORARY table tbh_ghep_nv_tempM1(
    ma_ta varchar2(10),
    lh_nv varchar2(10),
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    do_tl number,
    do_tien number,
    ve_tl number,
    ve_tien number,
    di_cd_tl number,
    di_cd_tien number,
    di_tm_tl number,
    di_tm_tien number,
    so_id_ta number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_tempM2;
create GLOBAL TEMPORARY table tbh_ghep_nv_tempM2(
    ma_dvi_hd varchar2(20),
    so_id_hd number,
    so_id_dt number,
    b_dk_lut varchar2(1),
    b_ma_dt varchar2(10),
    b_kvuc varchar2(20),
    ma_ta varchar2(10),
    tien number,
    phi number,
    do_tl number,
    do_tien number,
    ve_tl number,
    ve_tien number,
    di_cd_tl number,
    di_cd_tien number,
    di_tm_tl number,
    di_tm_tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_nv_tempM;
create GLOBAL TEMPORARY table tbh_ghep_nv_tempM(
    ma_ta varchar2(10),
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number,
    do_tl number,
    do_tien number,
    ve_tl number,
    ve_tien number,
    di_cd_tl number,
    di_cd_tien number,
    di_tm_tl number,
    di_tm_tien number)
ON COMMIT delete ROWS;

drop table tbh_ghep_dsach;
create table tbh_ghep_dsach(
    ma_dvi varchar2(10),
    ma nvarchar2(20),
    nv varchar2(10),
    ddiemd nvarchar2(250),
    ddiem varchar2(250),
    so_hd varchar2(30),
    tyle number,
    nsd varchar2(10));
CREATE unique INDEX tbh_ghep_dsach_u1 on tbh_ghep_dsach (ma_dvi,ma);
CREATE INDEX tbh_ghep_dsach_i1 on tbh_ghep_dsach (ma_dvi,nv,ddiem,so_hd);

drop table tbh_ghep_hdong;
create table tbh_ghep_hdong(
    ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    ten nvarchar2(500),
    ngay number,
    dvi varchar2(10),
    so_hd varchar2(50),
    ten_dt nvarchar2(200),
    so_id_d number,
    so_id_dt number,
    nsd varchar2(10),
    ngay_nh date);
CREATE INDEX tbh_ghep_hdong_i1 on tbh_ghep_hdong (ma_dvi,so_id);
CREATE INDEX tbh_ghep_hdong_i2 on tbh_ghep_hdong (dvi,so_id_d);
CREATE INDEX tbh_ghep_hdong_i3 on tbh_ghep_hdong (ma_dvi,nv);

drop table tbh_ghep_tdong_loi;
create table tbh_ghep_tdong_loi
    (nv varchar2(10),
    ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    loi varchar2(200));

drop table tbh_ghep_db;
create table tbh_ghep_db
    (lh_nv varchar2(20),
    muc number,
    phi number);
CREATE unique INDEX tbh_ghep_db_u1 on tbh_ghep_db(lh_nv,muc);

drop table tbh_ve_pbo;
create table tbh_ve_pbo
(
  ma_dvi    varchar2(10),
  so_id     number,
  ma_dvi_hd varchar2(10),
  so_id_hd  number,
  so_id_dt  number,
  lh_nv     varchar2(20),
  pt        number,
  nt_tien   varchar2(5),
  tien      number,
  nt_phi    varchar2(5),
  phi       number,
  bt        number
);
create unique index tbh_ve_pbo_u0 on tbh_ve_pbo(ma_dvi, so_id, bt);
create index tbh_ve_pbo_i1 on tbh_ve_pbo (ma_dvi_hd, so_id_hd, so_id_dt);

drop table tbh_ve;
create table tbh_ve (
  ma_dvi   varchar2(10 byte),
  so_id    number,
  ngay_ht  number,
  nv       varchar2(10 byte),
  kieu     varchar2(1 byte),
  kieu_hd  varchar2(1 byte),
  so_ct    varchar2(30 byte),
  ngay_hl  number,
  ngay_kt  number,
  loai     varchar2(1 byte),
  nt_tien  varchar2(5 byte),
  nt_phi   varchar2(5 byte),
  nd       nvarchar2(400),
  nguon    varchar2(1 byte),
  pbo_cp   varchar2(1 byte),
  ng_tai   number,
  so_id_d  number,
  so_id_g  number,
  nsd      varchar2(10 byte),
  ngay_nh  date
);
create unique index tbh_ve_u0 on tbh_ve(ma_dvi, so_id);
create index tbh_ve_i1 on tbh_ve (ma_dvi, ngay_ht, nv, kieu_hd, nsd);
create index tbh_ve_i2 on tbh_ve (ma_dvi, so_id_d);
create index tbh_ve_i3 on tbh_ve (ma_dvi, so_id_g);