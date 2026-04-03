--- Tai tam thoi ---

drop table tbh_tm;
create table tbh_tm(
 ma_dvi varchar2(10),
 so_id number,
 ngay_ht number,
 nv varchar2(10),
 so_ct varchar2(20),
 kieu varchar2(1),
    so_ctG varchar2(20),
 ngay_hl number,
 ngay_kt number,
 nt_tien varchar2(5),
 nt_phi varchar2(5),
 nguon varchar2(1),    -- B-Ban hang, T-Thuc thu, N-Tra ngay
 pthuc varchar2(1),              -- C-Chon, F-Fronting
 so_id_d number,
 so_id_g number,
 nsd varchar2(10),
 ngay_nh date
);
create unique index tbh_tm_u0 on tbh_tm(so_id);
CREATE unique INDEX tbh_tm_u1 on tbh_tm (so_ct);
CREATE INDEX tbh_tm_i1 on tbh_tm (ngay_ht,nv);
CREATE INDEX tbh_tm_i2 on tbh_tm (so_id_d);
CREATE INDEX tbh_tm_i3 on tbh_tm (so_id_g);

drop table tbh_tm_hd;
create table tbh_tm_hd
    (ma_dvi varchar2(10),
    so_id number,
    ma_dvi_hd varchar2(10),
    so_hd varchar2(20),
    so_id_hd number,
    so_id_dt number,
    so_idC number,
    bt number);
CREATE INDEX tbh_tm_hd_i1 on tbh_tm_hd(so_id);
CREATE INDEX tbh_tm_hd_i2 on tbh_tm_hd (ma_dvi_hd,so_id_hd,so_id_dt);

drop table tbh_tm_nbh;
create table tbh_tm_nbh(
 so_id number,
 nbh varchar2(20),
 pt number,
 hh number,
 kieu varchar2(1),
 nbhC varchar2(20),
 bt number);
CREATE INDEX tbh_tm_nbh_i1 on tbh_tm_nbh(so_id);

drop table tbh_tm_phi;
create table tbh_tm_phi(
    so_id number,
    ngay_hl number,
 nbh varchar2(20),
 nbhC varchar2(20),
    ma_ta varchar2(10),
    pt number,
    tien number,
    phi number,
    tl_thue number,
    thue number,
    pt_hh number,
    hhong number,
 bt number);
CREATE INDEX tbh_tm_phi_i1 on tbh_tm_phi (so_id);

drop table tbh_tm_pbo;
create table tbh_tm_pbo(
 so_id number,
    ngay_hl number,
    so_id_ta_ps number,
 ma_dvi_hd varchar2(10),
 so_id_hd number,
 so_id_dt number,
    nha_bh varchar2(20),
    kieu varchar2(1),
    nha_bhC varchar2(20),
    ma_ta varchar2(10),
 lh_nv varchar2(10),
 so_id_hd_ta number,
 pt number,
    pt_hh number,
 nt_tien varchar2(5),
 tien number,
 nt_phi varchar2(5),
 phi number,
 hhong number,
 thue number);
CREATE INDEX tbh_tm_pbo_i1 on tbh_tm_pbo(so_id);
CREATE INDEX tbh_tm_pbo_i2 on tbh_tm_pbo(ma_dvi_hd,so_id_hd);

drop table tbh_tm_txt;
create table tbh_tm_txt(
 so_id number,
 loai varchar2(10),
 txt clob);
CREATE INDEX tbh_tm_txt_i1 on tbh_tm_txt(so_id);

drop table tbh_tmB;
create table tbh_tmB(
    ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    nv varchar2(10),
    so_ct varchar2(20),
    kieu varchar2(1),
    so_ctG varchar2(20),
    ma_dviP varchar2(10),
    so_idP number,
    so_id_dtP number,
    ngay_hl number,
    ngay_kt number,
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    nguon varchar2(1),
    pthuc varchar2(1),
    so_id_d number,
    so_id_g number,
    nsd varchar2(10),
    ngay_nh date
);
create unique index tbh_tmb_u0 on tbh_tmb(so_id);
CREATE INDEX tbh_tmB_u1 on tbh_tmB (so_ct);
CREATE INDEX tbh_tmB_i1 on tbh_tmB (ngay_ht,nv);
CREATE INDEX tbh_tmB_i2 on tbh_tmB (so_id_d);
CREATE INDEX tbh_tmB_i3 on tbh_tmB (so_id_g);
CREATE INDEX tbh_tmB_i4 on tbh_tmB (ma_dviP,so_idP,so_id_dtP);

drop table tbh_tmB_hd;
create table tbh_tmB_hd
    (ma_dvi varchar2(10),
    so_id number,
 kieu varchar2(1),  -- H:Hop dong, B-Bao gia
    ma_dvi_hd varchar2(10),
    so_hd varchar2(20),
    so_id_hd number,
    so_id_dt number,
 ten nvarchar2(500),
    bt number);
CREATE INDEX tbh_tmB_hd_i1 on tbh_tmB_hd(so_id);

drop table tbh_tmB_nbh;
create table tbh_tmB_nbh(
 so_id number,
 nbh varchar2(20),
 pt number,
 hh number,
 kieu varchar2(1),
 nbhC varchar2(20),
 bt number);
CREATE INDEX tbh_tmB_nbh_i1 on tbh_tmB_nbh(so_id);

drop table tbh_tmB_phi;
create table tbh_tmB_phi(
    so_id number,
 nbh varchar2(20),
 nbhC varchar2(20),
    ma_ta varchar2(20),
    pt number,
    tien number,
    phi number,
    tl_thue number,
    thue number,
    pt_hh number,
    hhong number,
 bt number);
CREATE INDEX tbh_tmB_phi_i1 on tbh_tmB_phi (so_id);

drop table tbh_tmB_txt;
create table tbh_tmB_txt(
    ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_tmB_txt_i1 on tbh_tmB_txt(so_id);

-- Ty le nhan tai tam

drop table tbh_tmN;
create table tbh_tmN
    (ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    ngay_hl number,
    nsd varchar(10)
);
create unique index tbh_tmn_u0 on tbh_tmn(ma_dvi,so_id);

drop table tbh_tmN_tl;
create table tbh_tmN_tl
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    nha_bh varchar2(20),
    lh_nv varchar2(10),
    pt number,
    hh number,
 kieu varchar2(1),
 nha_bhC varchar2(20),
    ngay_hl number);
CREATE INDEX tbh_tmN_tl_i1 on tbh_tmN_tl(ma_dvi,so_id,so_id_dt);

drop table tbh_tmN_txt;
create table tbh_tmN_txt(
    ma_dvi varchar2(10),
    so_id number,
    ngay_hl number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_tmN_txt_i1 on tbh_tmN_txt(ma_dvi,so_id);

drop table tbh_tmNL;
create table tbh_tmNL
    (ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    ngay_hl number,
    nsd varchar(10));
CREATE INDEX tbh_tmNL_i1 on tbh_tmNL(ma_dvi,so_id,ngay_hl);

drop table tbh_tmNL_tl;
create table tbh_tmNL_tl
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    nha_bh varchar2(20),
    lh_nv varchar2(10),
    pt number,
    hh number,
 kieu varchar2(1),
 nha_bhC varchar2(20),
    ngay_hl number);
CREATE INDEX tbh_tmNL_tl_i1 on tbh_tmNL_tl(ma_dvi,so_id,ngay_hl);

drop table tbh_tmNL_txt;
create table tbh_tmNL_txt(
    ma_dvi varchar2(10),
    so_id number,
    ngay_hl number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_tmNL_txt_i1 on tbh_tmNL_txt(ma_dvi,so_id);

--

drop table tbh_tmN_vat;
create table tbh_tmN_vat
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
create unique index tbh_tmn_vat_u0 on tbh_tmn_vat(ma_dvi,so_id_vat);
CREATE INDEX tbh_tmN_vat_i1 on tbh_tmN_vat(ma_dvi,ngay_ht);

drop table tbh_tmN_vat_ct;
create table tbh_tmN_vat_ct
    (ma_dvi varchar2(10),
    so_id_vat number,
    bt number,
    so_id_tt number,
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number);
CREATE INDEX tbh_tmN_vat_ct_i1 on tbh_tmN_vat_ct(ma_dvi,so_id_vat);
CREATE INDEX tbh_tmN_vat_ct_i2 on tbh_tmN_vat_ct(ma_dvi,so_id_tt);

drop table tbh_tmN_vat_txt;
create table tbh_tmN_vat_txt
    (ma_dvi varchar2(10),
    so_id_vat number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_tmN_vat_txt_i1 on tbh_tmN_vat_txt(ma_dvi,so_id_vat);

drop table tbh_tmN_vat_temp1;
create GLOBAL TEMPORARY table tbh_tmN_vat_temp1
    (loai varchar2(20),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number)
    ON COMMIT PRESERVE ROWS;

drop table tbh_tmN_vat_temp2;
create GLOBAL TEMPORARY table tbh_tmN_vat_temp2
    (so_id_tt number,
    nha_bh varchar2(20))
    ON COMMIT PRESERVE ROWS;

drop table tbh_tmN_vat_temp3;
create GLOBAL TEMPORARY table tbh_tmN_vat_temp3
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
    ON COMMIT PRESERVE ROWS;
--

drop table tbh_tmN_ps;
create table tbh_tmN_ps
    (ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    so_ct varchar2(20),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    nhom varchar2(5),
    loai varchar2(10),
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
CREATE INDEX tbh_tmN_ps_i1 on tbh_tmN_ps(ma_dvi,ngay_ht);
CREATE INDEX tbh_tmN_ps_i2 on tbh_tmN_ps(ma_dvi,so_id_ps,so_id);

drop table tbh_tmN_ps_temp;
create GLOBAL TEMPORARY table tbh_tmN_ps_temp
    (so_id_ps number,
    so_ct varchar2(20),
    so_id_dt number,
    ngay_ht number,
    nhom varchar2(5),
    loai varchar2(10),
    nv varchar2(1),
    nha_bh varchar2(20),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    tien number,
    thue number)
    ON COMMIT delete ROWS;

/* Thanh toan nhan FAC */

drop table tbh_tmN_tt;
create table tbh_tmN_tt
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
create unique index tbh_tmn_tt_u0 on tbh_tmn_tt(ma_dvi,so_id_tt);
CREATE INDEX tbh_tmN_tt_i1 on tbh_tmN_tt(ma_dvi,ngay_ht);
CREATE INDEX tbh_tmN_tt_i2 on tbh_tmN_tt(ma_dvi,so_id_kt);
CREATE INDEX tbh_tmN_tt_i3 on tbh_tmN_tt(ma_dvi,nha_bh);

drop table tbh_tmN_ct;
create table tbh_tmN_ct
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
CREATE INDEX tbh_tmN_ct_i2 on tbh_tmN_ct(ma_dvi,so_id_tt);
CREATE INDEX tbh_tmN_ct_i1 on tbh_tmN_ct(ma_dvi,so_id,so_id_ps);

drop table tbh_tmN_pp;
create table tbh_tmN_pp
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    pt varchar2(1),
    ma_nt varchar2(5),
    tien number,
    tien_qd number);
CREATE INDEX tbh_tmN_pp_i1 on tbh_tmN_pp(ma_dvi,so_id_tt);

drop table tbh_tmN_tt_txt;
create table tbh_tmN_tt_txt(
    ma_dvi varchar2(10),
    so_id_tt number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_tmN_tt_txt_i1 on tbh_tmN_tt_txt(ma_dvi,so_id_tt);

drop table tbh_tmN_pt;
create table tbh_tmN_pt
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
CREATE INDEX tbh_tmN_pt_i1 on tbh_tmN_pt(ma_dvi,so_id_tt);
CREATE INDEX tbh_tmN_pt_i2 on tbh_tmN_pt(ma_dvi,ngay_ht);
CREATE INDEX tbh_tmN_pt_i3 on tbh_tmN_pt(ma_dvi,so_id_ps);

drop table tbh_tmN_tt_temp;
create GLOBAL TEMPORARY table tbh_tmN_tt_temp
    (so_id_tt number,
    ngay_ht number,
    nha_bh varchar2(20))
    ON COMMIT delete ROWS;

-- Phan bo dong BH noi bo ket qua chi nha dong

drop table tbh_tmN_pb;
create table tbh_tmN_pb
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
create unique index tbh_tmn_pb_u0 on tbh_tmn_pb(ma_dvi,so_id_tt,bt);
CREATE INDEX tbh_tmN_pb_i1 on tbh_tmN_pb(ma_dvi,so_id,ngay_ht);
CREATE INDEX tbh_tmN_pb_i2 on tbh_tmN_pb(ma_dvi,so_id,so_id_tt);
CREATE INDEX tbh_tmN_pb_i3 on tbh_tmN_pb(ma_dvi,so_id,so_id_kt);
CREATE INDEX tbh_tmN_pb_i4 on tbh_tmN_pb(dvi_xl,so_id,so_id_tt);
CREATE INDEX tbh_tmN_pb_i5 on tbh_tmN_pb(dvi_xl,so_id_tt);
CREATE INDEX tbh_tmN_pb_i6 on tbh_tmN_pb(ma_dvi,so_id_kt);

-- CONG NO NHA BH

drop table tbh_tmN_cn;
CREATE TABLE tbh_tmN_cn
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
    txt clob,
    ngay_nh date,
    so_id_kt number
);
create unique index tbh_tmn_cn_u0 on tbh_tmn_cn(ma_dvi,so_id);
create index tbh_tmN_cn_i1 on tbh_tmN_cn (ma_dvi,ngay_ht);

drop table tbh_tmN_ps_temp1;
create GLOBAL TEMPORARY table tbh_tmN_ps_temp1
    (ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    so_ct varchar2(20),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    nhom varchar2(5),
    loai varchar2(10),
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

drop table tbh_tmN_ps_temp2;
create GLOBAL TEMPORARY table tbh_tmN_ps_temp2
    (ma_dvi varchar2(10),
    so_id_ps number,
    bt number,
    so_ct varchar2(20),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    nhom varchar2(5),
    loai varchar2(10),
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

drop table tbh_tmN_sc;
create table tbh_tmN_sc
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
create unique index tbh_tmn_sc_u0 on tbh_tmn_sc(ma_dvi,nha_bh,ma_nt,ngay_ht);

drop table tbh_tmN_sc_ps;
create table tbh_tmN_sc_ps
    (ma_dvi varchar2(10),
    so_id number,
    so_id_ps number);
CREATE INDEX tbh_tmN_sc_ps_i1 on tbh_tmN_sc_ps(ma_dvi,so_id);
CREATE INDEX tbh_tmN_sc_ps_i2 on tbh_tmN_sc_ps(ma_dvi,so_id_ps);

drop table tbh_tmN_sc_vat;
create table tbh_tmN_sc_vat
    (ma_dvi varchar2(10),
    so_id_tt number,
    phong varchar2(10),
    nha_bh varchar2(20),
    ngay_ht number);
CREATE INDEX tbh_tmN_sc_vat_i1 on tbh_tmN_sc_vat(ma_dvi,phong,nha_bh,ngay_ht);
CREATE INDEX tbh_tmN_sc_vat_i2 on tbh_tmN_sc_vat(ma_dvi,so_id_tt);