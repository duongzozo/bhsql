drop table bh_do_bh_sc;
create table bh_do_bh_sc
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
create unique index bh_do_bh_sc_u0 on bh_do_bh_sc(ma_dvi,nha_bh,ma_nt,ngay_ht);

drop table bh_hd_do_sc_ps;
create table bh_hd_do_sc_ps
    (ma_dvi varchar2(10),
    so_id number,
    so_id_ps number);
CREATE INDEX bh_hd_do_sc_ps_i1 on bh_hd_do_sc_ps(ma_dvi,so_id);
CREATE INDEX bh_hd_do_sc_ps_i2 on bh_hd_do_sc_ps(ma_dvi,so_id_ps);

drop table bh_hd_do_sc_vat;
create table bh_hd_do_sc_vat
    (ma_dvi varchar2(10),
    so_id_tt number,
    phong varchar2(10),
    nha_bh varchar2(20),
    ngay_ht number);
CREATE INDEX bh_hd_do_sc_vat_i1 on bh_hd_do_sc_vat(ma_dvi,phong,nha_bh,ngay_ht);
CREATE INDEX bh_hd_do_sc_vat_i2 on bh_hd_do_sc_vat(ma_dvi,so_id_tt);

-- Ty le dong bao hiem

drop table bh_hd_do;
create table bh_hd_do
    (ma_dvi varchar2(10),
    so_id number,
    kieu varchar2(1),           -- D:Di, V-Ve
    nv varchar2(10),
    ngay_hl number,
    nsd varchar(10)
);
create unique index bh_hd_do_u0 on bh_hd_do(ma_dvi,so_id);

drop table bh_hd_do_tl;
create table bh_hd_do_tl
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    nha_bh varchar2(20),
    pthuc varchar2(1),          -- C-Bao hiem, D-Don vi, P-Phong,
    lh_nv varchar2(10),
    pt number,
    hh number,
    ngay_hl number);
CREATE INDEX bh_hd_do_tl_i1 on bh_hd_do_tl(ma_dvi,so_id,so_id_dt);

drop table bh_hd_do_txt;
create table bh_hd_do_txt(
    ma_dvi varchar2(10),
    so_id number,
    ngay_hl number,
    loai varchar2(10),
    txt clob);
CREATE INDEX bh_hd_do_txt_i1 on bh_hd_do_txt(ma_dvi,so_id);

drop table bh_hd_doL;
create table bh_hd_doL
    (ma_dvi varchar2(10),
    so_id number,
    kieu varchar2(1),
    nv varchar2(10),
    ngay_hl number,
    nsd varchar(10));
CREATE INDEX bh_hd_doL_i1 on bh_hd_doL(ma_dvi,so_id,ngay_hl);

drop table bh_hd_doL_tl;
create table bh_hd_doL_tl
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    nha_bh varchar2(20),
    pthuc varchar2(1),          -- C-Bao hiem, D-Don vi, P-Phong,
    lh_nv varchar2(10),
    pt number,
    hh number,
    ngay_hl number);
CREATE INDEX bh_hd_doL_tl_i1 on bh_hd_doL_tl(ma_dvi,so_id,ngay_hl);

drop table bh_hd_doL_txt;
create table bh_hd_doL_txt(
    ma_dvi varchar2(10),
    so_id number,
    ngay_hl number,
    loai varchar2(10),
    txt clob);
CREATE INDEX bh_hd_doL_txt_i1 on bh_hd_doL_txt(ma_dvi,so_id);

drop table bh_hd_do_tl_temp1;
create GLOBAL TEMPORARY table bh_hd_do_tl_temp1
    (ma varchar2(20),
    ten nvarchar2(500))
    ON COMMIT delete ROWS;

drop table bh_hd_do_ps;
create table bh_hd_do_ps
    (ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    so_ct varchar2(20),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    pthuc varchar2(1),
    nha_bh varchar2(20),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    ma_dt varchar2(10),
    tien number,
    thue number,
    tien_qd number,
    thue_qd number);
CREATE INDEX bh_hd_do_ps_i1 on bh_hd_do_ps(ma_dvi,ngay_ht);
CREATE INDEX bh_hd_do_ps_i2 on bh_hd_do_ps(ma_dvi,so_id_ps,so_id);

drop table bh_hd_do_ps_temp;
create GLOBAL TEMPORARY table bh_hd_do_ps_temp
    (so_id_ps number,
    so_ct varchar2(20),
    so_id_dt number,
    ngay_ht number,
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    nha_bh varchar2(20),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    tien number,
    thue number)
    ON COMMIT delete ROWS;

/* Thanh toan dong */

drop table bh_hd_do_tt;
create table bh_hd_do_tt
    (ma_dvi varchar2(10),
    so_id_tt number,
    ngay_ht number,
    so_ct varchar2(20),
    phong varchar2(10),
    nha_bh varchar2(20),
    chi_qd number,
    thu_qd number,
    thue_v_qd number,
    thue_r_qd number,
    nt_tra varchar2(5),
    pt_tra varchar2(1),
    tra number,
    tra_qd number,
    cit number,
    cit_qd number,
    nsd varchar2(10),
    so_id_kt number
);
create unique index bh_hd_do_tt_u0 on bh_hd_do_tt(ma_dvi,so_id_tt);
CREATE INDEX bh_hd_do_tt_i1 on bh_hd_do_tt(ma_dvi,ngay_ht);
CREATE INDEX bh_hd_do_tt_i2 on bh_hd_do_tt(ma_dvi,so_id_kt);
CREATE INDEX bh_hd_do_tt_i3 on bh_hd_do_tt(ma_dvi,nha_bh);

drop table bh_hd_do_ct;
create table bh_hd_do_ct
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id number,
    so_id_ps number,
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    ma_nt varchar2(5),
    tien number,
    thue number,
    tien_qd number,
    thue_qd number);
CREATE INDEX bh_hd_do_ct_i2 on bh_hd_do_ct(ma_dvi,so_id_tt);
CREATE INDEX bh_hd_do_ct_i1 on bh_hd_do_ct(ma_dvi,so_id,so_id_ps);

drop table bh_hd_do_pp;
create table bh_hd_do_pp
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    pt varchar2(1),
    ma_nt varchar2(5),
    tien number,
    tien_qd number);
CREATE INDEX bh_hd_do_pp_i1 on bh_hd_do_pp(ma_dvi,so_id_tt);

drop table bh_hd_do_tt_txt;
create table bh_hd_do_tt_txt(
    ma_dvi varchar2(10),
    so_id_tt number,
    loai varchar2(10),
    txt clob);
CREATE INDEX bh_hd_do_tt_txt_i1 on bh_hd_do_tt_txt(ma_dvi,so_id_tt);

drop table bh_hd_do_pt;
create table bh_hd_do_pt
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    ngay_ht number,
    so_id number,
    so_id_dt number,
    so_id_ps number,
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    pthuc varchar2(1),
    kieu varchar2(1),
    ma_nt varchar2(5),
    lh_nv varchar2(20),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number);
CREATE INDEX bh_hd_do_pt_i1 on bh_hd_do_pt(ma_dvi,so_id_tt);
CREATE INDEX bh_hd_do_pt_i2 on bh_hd_do_pt(ma_dvi,ngay_ht);
CREATE INDEX bh_hd_do_pt_i3 on bh_hd_do_pt(ma_dvi,so_id_ps);

drop table bh_hd_do_tt_temp;
create GLOBAL TEMPORARY table bh_hd_do_tt_temp
    (so_id_tt number,
    ngay_ht number,
    nha_bh varchar2(20))
    ON COMMIT delete ROWS;

-- Phan bo dong BH noi bo ket qua chi nha dong

drop table bh_hd_do_pb;
create table bh_hd_do_pb
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id number,
    ngay_ht number,
    dvi_xl varchar2(10),
    phong varchar2(10),
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    pthuc varchar2(1),
    kieu varchar2(1),
    lh_nv varchar2(10),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    so_id_kt number
);
create unique index bh_hd_do_pb_u0 on bh_hd_do_pb(ma_dvi,so_id_tt,bt);
CREATE INDEX bh_hd_do_pb_i1 on bh_hd_do_pb(ma_dvi,so_id,ngay_ht);
CREATE INDEX bh_hd_do_pb_i2 on bh_hd_do_pb(ma_dvi,so_id,so_id_tt);
CREATE INDEX bh_hd_do_pb_i3 on bh_hd_do_pb(ma_dvi,so_id,so_id_kt);
CREATE INDEX bh_hd_do_pb_i4 on bh_hd_do_pb(dvi_xl,so_id,so_id_tt);
CREATE INDEX bh_hd_do_pb_i5 on bh_hd_do_pb(dvi_xl,so_id_tt);
CREATE INDEX bh_hd_do_pb_i6 on bh_hd_do_pb(ma_dvi,so_id_kt);

-- CONG NO NHA DONG BH

drop table bh_hd_do_cn;
CREATE TABLE bh_hd_do_cn
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    l_ct varchar2(1),
    nha_bh varchar2(20),
    so_ct varchar2(20),
    nd nvarchar2(200),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    phong varchar2(10),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hd_do_cn_0800 values ('0800'),
    PARTITION bh_hd_do_cn_DEFA values (DEFAULT));
create unique index bh_hd_do_cn_u on bh_hd_do_cn(ma_dvi,so_id) local;
create index bh_hd_do_cn_i1 on bh_hd_do_cn(ngay_ht) local;
create index bh_hd_do_cn_i2 on bh_hd_do_cn(so_id_kt) local;

drop table bh_hd_do_cn_txt;
CREATE TABLE bh_hd_do_cn_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hd_do_cn_txt_0800 values ('0800'),
    PARTITION bh_hd_do_cn_txt_DEFA values (DEFAULT));
create index bh_hd_do_cn_txt_i1 on bh_hd_do_cn_txt(so_id) local;

-- Hoa don VAT cho DONG

drop table bh_hd_do_vat;
create table bh_hd_do_vat
    (ma_dvi varchar2(10),
    so_id_vat number,
    ngay_ht number,
    loai varchar2(1),           -- V-vao,R-Ra
    nha_bh varchar2(20),
    ten nvarchar2(500),
    dchi nvarchar2(500),
    tax varchar2(20),
    so_don varchar2(20),
    ngay_bc number,
    phong varchar2(10),
    nsd varchar2(10),
    ngay_nh date
);
create unique index bh_hd_do_vat_u0 on bh_hd_do_vat(ma_dvi,so_id_vat);
CREATE INDEX bh_hd_do_vat_i1 on bh_hd_do_vat(ma_dvi,ngay_ht);

drop table bh_hd_do_vat_ct;
create table bh_hd_do_vat_ct
    (ma_dvi varchar2(10),
    so_id_vat number,
    bt number,
    so_id_tt number,
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number);
CREATE INDEX bh_hd_do_vat_ct_i1 on bh_hd_do_vat_ct(ma_dvi,so_id_vat);
CREATE INDEX bh_hd_do_vat_ct_i2 on bh_hd_do_vat_ct(ma_dvi,so_id_tt);

drop table bh_hd_do_vat_txt;
create table bh_hd_do_vat_txt
    (ma_dvi varchar2(10),
    so_id_vat number,
    loai varchar2(10),
    txt clob);
CREATE INDEX bh_hd_do_vat_txt_i1 on bh_hd_do_vat_txt(ma_dvi,so_id_vat);

drop table bh_hd_do_vat_temp1;
create GLOBAL TEMPORARY table bh_hd_do_vat_temp1
    (loai varchar2(20),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number)
    ON COMMIT delete ROWS;

drop table bh_hd_do_vat_temp2;
create GLOBAL TEMPORARY table bh_hd_do_vat_temp2
    (so_id_tt number,
    nha_bh varchar2(20))
    ON COMMIT delete ROWS;

drop table bh_hd_do_vat_temp3;
create GLOBAL TEMPORARY table bh_hd_do_vat_temp3
    (so_id_tt number,
    ngay_ht number,
    so_ct varchar2(20),
    loai varchar2(20),
    nha_bh varchar2(20),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number)
    ON COMMIT delete ROWS;

drop table bh_hd_do_ps_temp1;
create GLOBAL TEMPORARY table bh_hd_do_ps_temp1
    (ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    so_ct varchar2(20),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    pthuc varchar2(1),
    nha_bh varchar2(20),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    ma_dt varchar2(10),
    tien number,
    thue number,
    tien_qd number,
    thue_qd number)
    ON COMMIT delete ROWS;

drop table bh_hd_do_ps_temp2;
create GLOBAL TEMPORARY table bh_hd_do_ps_temp2
    (ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    so_ct varchar2(20),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    nhom varchar2(5),
    loai varchar2(20),
    nv varchar2(1),
    pthuc varchar2(1),
    nha_bh varchar2(20),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    ma_dt varchar2(10),
    tien number,
    thue number,
    tien_qd number,
    thue_qd number)
    ON COMMIT delete ROWS;

drop table bh_hd_do_nh;
create table bh_hd_do_nh(
    ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    ngay_hl number,
    nsd varchar2(20),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hd_do_nh_0800 values ('0800'),
    PARTITION bh_hd_do_nh_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_do_nh_u on bh_hd_do_nh(ma_dvi,so_id,nhom) local;

drop table bh_hd_do_nh_txt;
create table bh_hd_do_nh_txt(
    ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    ngay_hl number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hd_do_nh_txt_0800 values ('0800'),
    PARTITION bh_hd_do_nh_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_do_nh_txt_i1 on bh_hd_do_nh_txt(so_id,nhom) local;

drop table bh_hd_do_nhL;
create table bh_hd_do_nhL(
    ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    kieu varchar2(1),
    nv varchar2(10),
    ngay_hl number,
    nsd varchar2(20),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hd_do_nhL_0800 values ('0800'),
    PARTITION bh_hd_do_nhL_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_do_nhL_u on bh_hd_do_nhL(ma_dvi,so_id,nhom) local;

drop table bh_hd_do_nhL_txt;
create table bh_hd_do_nhL_txt(
    ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    ngay_hl number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
    PARTITION bh_hd_do_nhL_txt_0800 values ('0800'),
    PARTITION bh_hd_do_nhL_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_do_nhL_txt_i1 on bh_hd_do_nhL_txt(so_id,nhom) local;

drop table bh_do_bh_cn;
create table bh_do_bh_cn
(
  ma_dvi   varchar2(10),
  so_id    number,
  ngay_ht  number,
  l_ct     varchar2(1),
  nha_bh   varchar2(20),
  so_ct    varchar2(20),
  nd       NVARCHAR2(200),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number,
  nsd      varchar2(10),
  txt      clob,
  ngay_nh  date,
  so_id_kt number
)
PARTITION BY LIST (ma_dvi) (
    PARTITION bh_do_bh_cn_0800 values ('0800'),
    PARTITION bh_do_bh_cn_DEFA values (DEFAULT)
);
create unique index bh_do_bh_cn_u0 on bh_do_bh_cn(ma_dvi, so_id);
create index bh_do_bh_cn_i1 on bh_do_bh_cn(ma_dvi, ngay_ht) local;