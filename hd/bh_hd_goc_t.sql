drop table bh_hd_goc;
create table bh_hd_goc
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(20),
    kieu_hd varchar2(1),
    nv varchar2(10),
    ngay_ht number,
    ngay_cap number,
    ngay_hl number,
    ngay_kt number,
    cb_ql varchar2(10),
    phong varchar2(10),
    kieu_kt varchar2(1),
    ma_kt varchar2(20),
    dly_tke varchar2(20),
    hhong number,
    pt_hhong varchar2(1),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    kieu_gt varchar2(1),
    ma_gt varchar2(20),
    c_thue varchar2(1),
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    tien number,
    phi number,
    thue number,
    nsd varchar2(10),
    so_id_d number,
    so_id_g number,
    so_id_kt number,
    ttrang varchar2(1),
    dvi_ksoat varchar2(10),
    ksoat varchar2(10),
    bangG varchar2(50))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_0800 values ('0800'),
        PARTITION bh_hd_goc_0883 values ('0883'),
        PARTITION bh_hd_goc_0885 values ('0885'),
        PARTITION bh_hd_goc_020 values ('0200'),
        PARTITION bh_hd_goc_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_060 values ('0650'),
        PARTITION bh_hd_goc_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_u1 on bh_hd_goc(ma_dvi,so_id) local;
CREATE unique INDEX bh_hd_goc_u2 on bh_hd_goc(ma_dvi,so_hd) local;
CREATE INDEX bh_hd_goc_i2 on bh_hd_goc(so_id_g) local;
CREATE INDEX bh_hd_goc_i3 on bh_hd_goc(so_id_d) local;
CREATE INDEX bh_hd_goc_i8 on bh_hd_goc(ngay_ht) local;
CREATE INDEX bh_hd_goc_i9 on bh_hd_goc(ngay_cap) local;
CREATE INDEX bh_hd_goc_i10 on bh_hd_goc(ngay_kt) local;
CREATE INDEX bh_hd_goc_c1 on bh_hd_goc(ma_kh);

-- Dieu khoan

drop table bh_hd_goc_dk;
create table bh_hd_goc_dk
    (ma_dvi varchar2(10),
    so_id number,
    ma_dt varchar2(10),
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    pt number,
    tien number,
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_dk_0800 values ('0800'),
        PARTITION bh_hd_goc_dk_0883 values ('0883'),
        PARTITION bh_hd_goc_dk_0885 values ('0885'),
        PARTITION bh_hd_goc_dk_020 values ('0200'),
        PARTITION bh_hd_goc_dk_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_dk_060 values ('0650'),
        PARTITION bh_hd_goc_dk_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_dk_i1 on bh_hd_goc_dk(so_id) local;

-- Dieu khoan

drop table bh_hd_goc_dkdt;
create table bh_hd_goc_dkdt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    ma_dt varchar2(10),
    nt_tien varchar2(5),
    nt_phi varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    pt number,
    tien number,
    phi number, 
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_dkdt_0800 values ('0800'),
        PARTITION bh_hd_goc_dkdt_0883 values ('0883'),
        PARTITION bh_hd_goc_dkdt_0885 values ('0885'),
        PARTITION bh_hd_goc_dkdt_020 values ('0200'),
        PARTITION bh_hd_goc_dkdt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_dkdt_060 values ('0650'),
        PARTITION bh_hd_goc_dkdt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_dkdt_i1 on bh_hd_goc_dkdt(so_id) local;

drop table bh_hd_goc_tt;
create table bh_hd_goc_tt
    (ma_dvi varchar2(10),
    so_id number,
    ngay number,
    ma_nt varchar2(5),
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_tt_0800 values ('0800'),
        PARTITION bh_hd_goc_tt_0883 values ('0883'),
        PARTITION bh_hd_goc_tt_0885 values ('0885'),
        PARTITION bh_hd_goc_tt_020 values ('0200'),
        PARTITION bh_hd_goc_tt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_tt_060 values ('0650'),
        PARTITION bh_hd_goc_tt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_tt_u on bh_hd_goc_tt(so_id) local;

-- Phan tich cho tung ky thanh toan

drop table bh_hd_goc_pt;
create table bh_hd_goc_pt
    (ma_dvi varchar2(10),
    so_id_xl number,
    bt number,
    kieu_hd varchar2(1),
    ngay_ht number,
    so_id number,
    ngay number,
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_pt_0800 values ('0800'),
        PARTITION bh_hd_goc_pt_0883 values ('0883'),
        PARTITION bh_hd_goc_pt_0885 values ('0885'),
        PARTITION bh_hd_goc_pt_020 values ('0200'),
        PARTITION bh_hd_goc_pt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_pt_060 values ('0650'),
        PARTITION bh_hd_goc_pt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_pt_i1 on bh_hd_goc_pt(so_id_xl) local;
CREATE INDEX bh_hd_goc_pt_i2 on bh_hd_goc_pt(so_id) local;

drop table bh_hd_goc_ptdt;
create table bh_hd_goc_ptdt
    (ma_dvi varchar2(10),
    so_id_xl number,
    bt number,
    kieu_hd varchar2(1),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    ngay number,
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    phi number,
    thue number,
    ttoan number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ptdt_0800 values ('0800'),
        PARTITION bh_hd_goc_ptdt_0883 values ('0883'),
        PARTITION bh_hd_goc_ptdt_0885 values ('0885'),
        PARTITION bh_hd_goc_ptdt_020 values ('0200'),
        PARTITION bh_hd_goc_ptdt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ptdt_060 values ('0650'),
        PARTITION bh_hd_goc_ptdt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ptdt_i1 on bh_hd_goc_ptdt(so_id_xl) local;
CREATE INDEX bh_hd_goc_ptdt_i2 on bh_hd_goc_ptdt(so_id,so_id_dt) local;

-- So con lai neu hop dong la dong BH

drop table bh_hd_goc_cl;
create table bh_hd_goc_cl
    (ma_dvi varchar2(10),
    so_id_xl number,
    bt number,
    kieu_hd varchar2(1),
    ngay_ht number,
    so_id number,
    ngay number,
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    phi number,
    thue number,
    ttoan number,
    nha_bh varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_cl_0800 values ('0800'),
        PARTITION bh_hd_goc_cl_0883 values ('0883'),
        PARTITION bh_hd_goc_cl_0885 values ('0885'),
        PARTITION bh_hd_goc_cl_020 values ('0200'),
        PARTITION bh_hd_goc_cl_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_cl_060 values ('0650'),
        PARTITION bh_hd_goc_cl_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_cl_u on bh_hd_goc_cl(so_id_xl) local;
CREATE INDEX bh_hd_goc_cl_i2 on bh_hd_goc_cl(so_id) local;

drop table bh_hd_goc_cldt;
create table bh_hd_goc_cldt
    (ma_dvi varchar2(10),
    so_id_xl number,
    bt number,
    kieu_hd varchar2(1),
    ngay_ht number,
    so_id number,
    so_id_dt number,
    ngay number,
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    phi number,
    thue number,
    ttoan number,
    nha_bh varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_cldt_0800 values ('0800'),
        PARTITION bh_hd_goc_cldt_0883 values ('0883'),
        PARTITION bh_hd_goc_cldt_0885 values ('0885'),
        PARTITION bh_hd_goc_cldt_020 values ('0200'),
        PARTITION bh_hd_goc_cldt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_cldt_060 values ('0650'),
        PARTITION bh_hd_goc_cldt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_cldt_u on bh_hd_goc_cldt(so_id_xl) local;
CREATE INDEX bh_hd_goc_cldt_i2 on bh_hd_goc_cldt(so_id_dt) local;

-- Tong tin doi tuong trong hop dong

drop table bh_hd_goc_ttindt;
create table bh_hd_goc_ttindt
    (ma_dvi varchar2(10),
    so_id number,               -- So id dau
    so_id_dt number,
    nv varchar2(10),
    ten nvarchar2(500),
    ma_kh varchar2(20),
    ngay_kt number,
    ttin clob,
    ma_ke varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttindt_0800 values ('0800'),
        PARTITION bh_hd_goc_ttindt_0883 values ('0883'),
        PARTITION bh_hd_goc_ttindt_0885 values ('0885'),
        PARTITION bh_hd_goc_ttindt_020 values ('0200'),
        PARTITION bh_hd_goc_ttindt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttindt_060 values ('0650'),
        PARTITION bh_hd_goc_ttindt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttindt_i1 on bh_hd_goc_ttindt(so_id) local;
CREATE INDEX bh_hd_goc_ttindt_i2 on bh_hd_goc_ttindt(ma_kh);
CREATE INDEX bh_hd_goc_ttindt_i3 on bh_hd_goc_ttindt(nv,ma_ke);

-- Dieu khoan bo sung kem theo

drop table bh_hd_goc_dkbs;
create table bh_hd_goc_dkbs
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    bt number,
    ma_dk varchar2(30),
    ma varchar2(200),
    tc varchar2(1),
    lh_nv varchar2(20),
    nt_tien varchar2(5),
    tien number,
    pt number,
    phi number,
    mt_tien number default 0,
    mt_pt number default 0,
    mt_ktr varchar2(1) default 0,
    mt_chu nvarchar2(400) default ' ',
    loai varchar2(10) default ' ',
    ten nvarchar2(1000) default ' ',
    tenE varchar2(500) default ' ')
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_dkbs_0800 values ('0800'),
        PARTITION bh_hd_goc_dkbs_0883 values ('0883'),
        PARTITION bh_hd_goc_dkbs_0885 values ('0885'),
        PARTITION bh_hd_goc_dkbs_020 values ('0200'),
        PARTITION bh_hd_goc_dkbs_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_dkbs_060 values ('0650'),
        PARTITION bh_hd_goc_dkbs_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_dkbs_u on bh_hd_goc_dkbs(ma_dvi,so_id,so_id_dt,bt) local;

-- Danh muc rui ro kem theo

drop table bh_hd_goc_rr;
create table bh_hd_goc_rr
    (ma_dvi varchar2(10),
    so_id number,
    ma varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_rr_0800 values ('0800'),
        PARTITION bh_hd_goc_rr_0883 values ('0883'),
        PARTITION bh_hd_goc_rr_0885 values ('0885'),
        PARTITION bh_hd_goc_rr_020 values ('0200'),
        PARTITION bh_hd_goc_rr_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_rr_060 values ('0650'),
        PARTITION bh_hd_goc_rr_DEFA values (DEFAULT));
    CREATE INDEX bh_hd_goc_rr_u on bh_hd_goc_rr(so_id,ma) local;

-- THANH TOAN PHI

drop table bh_hd_goc_ttps;
create table bh_hd_goc_ttps
    (ma_dvi varchar2(10),
    so_id_tt number,
    ngay_ht number,
    kvat varchar2(1),
    so_ct varchar2(20),
    ma_kh varchar2(20),
    pt_tra varchar2(1),
    nha_bh varchar2(20),
    ma_dl varchar2(20),
    vochK varchar2(1),
    vochD varchar2(20),
    phong varchar2(10),
    ten nvarchar2(500),
    dchi nvarchar2(400),
    ma_thue varchar2(30),
    ttoan_qd number,
    thue_qd number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    kieuhd varchar2(1),     -- Kieu hoa don: P-Giay,E-Dien tu,K-Khong lay
    layhd varchar2(1),
    htoan varchar2(1),
    so_hdon_c varchar2(20),
    nd nvarchar2(500),
    nsd varchar2(10),
    so_id_kt number,
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttps_0800 values ('0800'),
        PARTITION bh_hd_goc_ttps_0883 values ('0883'),
        PARTITION bh_hd_goc_ttps_0885 values ('0885'),
        PARTITION bh_hd_goc_ttps_020 values ('0200'),
        PARTITION bh_hd_goc_ttps_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttps_060 values ('0650'),
        PARTITION bh_hd_goc_ttps_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_ttps_u on bh_hd_goc_ttps(ma_dvi,so_id_tt) local;
CREATE INDEX bh_hd_goc_ttps_i1 on bh_hd_goc_ttps(ngay_ht) local;
CREATE INDEX bh_hd_goc_ttps_i2 on bh_hd_goc_ttps(so_id_kt) local;

drop table bh_hd_goc_tthd;
create table bh_hd_goc_tthd
    (ma_dvi varchar2(10),
    so_id_tt number,  
    bt number,
    ngay_ht number,
    so_id number,
    ngay number,
    pt varchar2(1),         -- Phuong thuc thanh toan: G tra ngay, C cho no phi, N thanh toan da cho no
    ma_nt varchar2(5),
    phi number,
    tien number,
    tien_qd number,
    thue number,
    thue_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_tthd_0800 values ('0800'),
        PARTITION bh_hd_goc_tthd_0883 values ('0883'),
        PARTITION bh_hd_goc_tthd_0885 values ('0885'),
        PARTITION bh_hd_goc_tthd_020 values ('0200'),
        PARTITION bh_hd_goc_tthd_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_tthd_060 values ('0650'),
        PARTITION bh_hd_goc_tthd_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_tthd_u on bh_hd_goc_tthd(ma_dvi,so_id_tt,bt) local;
CREATE INDEX bh_hd_goc_tthd_i1 on bh_hd_goc_tthd(so_id,ngay_ht) local;
CREATE INDEX bh_hd_goc_tthd_i2 on bh_hd_goc_tthd(so_id,pt) local;
CREATE INDEX bh_hd_goc_tthd_i3 on bh_hd_goc_tthd(so_id_tt,so_id) local;
CREATE INDEX bh_hd_goc_tthd_i4 on bh_hd_goc_tthd(ngay_ht) local;

drop table bh_hd_goc_tthd_temp;
create GLOBAL TEMPORARY table bh_hd_goc_tthd_temp
    (so_id_tt number,
    ngay_ht number)
    ON COMMIT delete ROWS;

drop table bh_hd_goc_ttpt_temp;
create GLOBAL TEMPORARY table bh_hd_goc_ttpt_temp
    (loai varchar2(1),
    ngay_ht number,
    so_id number)
    ON COMMIT delete ROWS;

drop table bh_hd_goc_ttct;
create table bh_hd_goc_ttct
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    pt varchar2(1),     --- Tra bang gi: T- Tien, N- Cong No, D: Dai ly thu ho, B-Bao hiem dong thu ho
    ma_nt varchar2(5),
    tien number,
    tien_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttct_0800 values ('0800'),
        PARTITION bh_hd_goc_ttct_0883 values ('0883'),
        PARTITION bh_hd_goc_ttct_0885 values ('0885'),
        PARTITION bh_hd_goc_ttct_020 values ('0200'),
        PARTITION bh_hd_goc_ttct_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttct_060 values ('0650'),
        PARTITION bh_hd_goc_ttct_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttct_u on bh_hd_goc_ttct(so_id_tt) local;

drop table bh_hd_goc_ttxt;
create table bh_hd_goc_ttxt
    (ma_dvi varchar2(10),
    so_id_tt number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttxt_0800 values ('0800'),
        PARTITION bh_hd_goc_ttxt_0883 values ('0883'),
        PARTITION bh_hd_goc_ttxt_0885 values ('0885'),
        PARTITION bh_hd_goc_ttxt_020 values ('0200'),
        PARTITION bh_hd_goc_ttxt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttxt_060 values ('0650'),
        PARTITION bh_hd_goc_ttxt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttxt_i1 on bh_hd_goc_ttxt(so_id_tt) local;

-- Phan tich ket qua thanh toan cho tung ky

drop table bh_hd_goc_ttpt;
create table bh_hd_goc_ttpt
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id number,
    nv varchar2(10),
    ngay_ht number,
    ngay_tt number,
    ngay number,
    pt varchar2(1),
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    phi number,
    thue number,
    ttoan number,
    hhong number,
    htro number,
    dvu number,
    phi_qd number,
    thue_qd number,
    ttoan_qd number,
    hhong_qd number,
    htro_qd number,
    dvu_qd number,
    hhong_tl number,
    htro_tl number,
    dvu_tl number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttpt_0800 values ('0800'),
        PARTITION bh_hd_goc_ttpt_0883 values ('0883'),
        PARTITION bh_hd_goc_ttpt_0885 values ('0885'),
        PARTITION bh_hd_goc_ttpt_020 values ('0200'),
        PARTITION bh_hd_goc_ttpt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttpt_060 values ('0650'),
        PARTITION bh_hd_goc_ttpt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttpt_i2 on bh_hd_goc_ttpt(so_id_tt) local;
CREATE INDEX bh_hd_goc_ttpt_i1 on bh_hd_goc_ttpt(so_id) local;
CREATE INDEX bh_hd_goc_ttpt_i3 on bh_hd_goc_ttpt(ngay_ht) local;

drop table bh_hd_goc_ttptdt;
create table bh_hd_goc_ttptdt
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id number,
    so_id_dt number,
    nv varchar2(10),
    ngay_ht number,
    ngay_tt number,
    ngay number,
    pt varchar2(1),
    ma_dt varchar2(10),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    t_suat number,
    phi number,
    thue number,
    ttoan number,
    hhong number,
    htro number,
    dvu number,
    phi_qd number,
    thue_qd number,
    ttoan_qd number,
    hhong_qd number,
    htro_qd number,
    dvu_qd number,
    hhong_tl number,
    htro_tl number,
    dvu_tl number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttptdt_0800 values ('0800'),
        PARTITION bh_hd_goc_ttptdt_0883 values ('0883'),
        PARTITION bh_hd_goc_ttptdt_0885 values ('0885'),
        PARTITION bh_hd_goc_ttptdt_020 values ('0200'),
        PARTITION bh_hd_goc_ttptdt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttptdt_060 values ('0650'),
        PARTITION bh_hd_goc_ttptdt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttptdt_i2 on bh_hd_goc_ttptdt(so_id_tt) local;
CREATE INDEX bh_hd_goc_ttptdt_i1 on bh_hd_goc_ttptdt(so_id) local;
CREATE INDEX bh_hd_goc_ttptdt_i3 on bh_hd_goc_ttptdt(ngay_ht) local;

-- Phan bo dong BH noi bo ket qua thanh toan

drop table bh_hd_goc_ttpb;
create table bh_hd_goc_ttpb
    (ma_dvi varchar2(10),
    so_id_tt number,
    bt number,
    so_id number,
    nv varchar2(10),
    ngay_ht number,
    pthuc varchar2(1),
    dvi_xl varchar2(10),
    phong varchar2(10),
    ma_dl varchar2(20),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    phi number,
    hhong number,
    htro number,
    dvu number,
    phi_qd number,
    hhong_qd number,
    htro_qd number,
    dvu_qd number,
    hhong_tl number,
    htro_tl number,
    dvu_tl number,
    so_id_kt number,
    pt varchar2(1))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttpb_0800 values ('0800'),
        PARTITION bh_hd_goc_ttpb_0883 values ('0883'),
        PARTITION bh_hd_goc_ttpb_0885 values ('0885'),
        PARTITION bh_hd_goc_ttpb_020 values ('0200'),
        PARTITION bh_hd_goc_ttpb_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttpb_060 values ('0650'),
        PARTITION bh_hd_goc_ttpb_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttpb_u on bh_hd_goc_ttpb(so_id_tt) local;
CREATE INDEX bh_hd_goc_ttpb_i2 on bh_hd_goc_ttpb(so_id) local;
CREATE INDEX bh_hd_goc_ttpb_i4 on bh_hd_goc_ttpb(dvi_xl) local;
CREATE INDEX bh_hd_goc_ttpb_i6 on bh_hd_goc_ttpb(so_id_kt) local;
CREATE INDEX bh_hd_goc_ttpb_i7 on bh_hd_goc_ttpb(ngay_ht) local;

drop table bh_hd_goc_ttke;
create table bh_hd_goc_ttke
    (ma_dvi varchar2(10),
    so_id_tt number,
    so_id number,
    nv varchar2(10),
    ngay_ht number,
    ma varchar2(20),                -- Ma co che
    lh_nv varchar2(10),
    tien number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ttke_0800 values ('0800'),
        PARTITION bh_hd_goc_ttke_0883 values ('0883'),
        PARTITION bh_hd_goc_ttke_0885 values ('0885'),
        PARTITION bh_hd_goc_ttke_020 values ('0200'),
        PARTITION bh_hd_goc_ttke_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ttke_060 values ('0650'),
        PARTITION bh_hd_goc_ttke_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ttke_u on bh_hd_goc_ttke(so_id_tt) local;
CREATE INDEX bh_hd_goc_ttke_i1 on bh_hd_goc_ttke(so_id) local;
CREATE INDEX bh_hd_goc_ttke_i2 on bh_hd_goc_ttke(ngay_ht) local;

drop table bh_hd_goc_vat_hd;
create table bh_hd_goc_vat_hd
    (ma_dvi varchar2(10),
    so_id_vat number,
    so_id number,
    so_id_tt number,
    ngay_tt number,
    so_hd varchar2(20),
    thue number,
    ttoan number,
    thue_qd number,
    ttoan_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_vat_hd_0800 values ('0800'),
        PARTITION bh_hd_goc_vat_hd_0883 values ('0883'),
        PARTITION bh_hd_goc_vat_hd_0885 values ('0885'),
        PARTITION bh_hd_goc_vat_hd_020 values ('0200'),
        PARTITION bh_hd_goc_vat_hd_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_vat_hd_060 values ('0650'),
        PARTITION bh_hd_goc_vat_hd_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_vat_hd_i1 on bh_hd_goc_vat_hd(so_id_vat) local;
CREATE INDEX bh_hd_goc_vat_hd_i2 on bh_hd_goc_vat_hd(so_id_tt) local;
CREATE INDEX bh_hd_goc_vat_hd_i3 on bh_hd_goc_vat_hd(so_id) local;

drop table bh_hd_goc_vat_doi;
create table bh_hd_goc_vat_doi
    (ma_dvi varchar2(10),
    so_id number,
    so_id_g number,
    so_id_vat number,
    ngay_ht number,
    phong varchar2(10),
    mau varchar2(20),
    seri varchar2(20),
    so_don varchar2(20),
    don varchar2(50),
    ngay_bc number,
    nsd varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_vat_doi_0800 values ('0800'),
        PARTITION bh_hd_goc_vat_doi_0883 values ('0883'),
        PARTITION bh_hd_goc_vat_doi_0885 values ('0885'),
        PARTITION bh_hd_goc_vat_doi_020 values ('0200'),
        PARTITION bh_hd_goc_vat_doi_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_vat_doi_060 values ('0650'),
        PARTITION bh_hd_goc_vat_doi_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_vat_doi_u1 on bh_hd_goc_vat_doi(ma_dvi,so_id) local;
CREATE unique INDEX bh_hd_goc_vat_doi_u2 on bh_hd_goc_vat_doi(ma_dvi,don) local;
CREATE INDEX bh_hd_goc_vat_doi_i1 on bh_hd_goc_vat_doi(so_id_vat) local;
CREATE INDEX bh_hd_goc_vat_doi_i2 on bh_hd_goc_vat_doi(so_id_g) local;
CREATE INDEX bh_hd_goc_vat_doi_i3 on bh_hd_goc_vat_doi(ngay_ht) local;
CREATE INDEX bh_hd_goc_vat_doi_i4 on bh_hd_goc_vat_doi(ngay_bc) local;

drop table bh_hd_goc_vat_txt;
create table bh_hd_goc_vat_txt
    (ma_dvi varchar2(10),
    so_id_vat number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_vat_txt_0800 values ('0800'),
        PARTITION bh_hd_goc_vat_txt_0883 values ('0883'),
        PARTITION bh_hd_goc_vat_txt_0885 values ('0885'),
        PARTITION bh_hd_goc_vat_txt_020 values ('0200'),
        PARTITION bh_hd_goc_vat_txt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_vat_txt_060 values ('0650'),
        PARTITION bh_hd_goc_vat_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_vat_txt_i1 on bh_hd_goc_vat_txt(so_id_vat) local;

drop table bh_hd_goc_vat_temp;
create GLOBAL TEMPORARY table bh_hd_goc_vat_temp
    (so_id_vat number,
    so_don varchar2(30))
    ON COMMIT delete ROWS;

drop table bh_hd_goc_vat_temp1;
create GLOBAL TEMPORARY table bh_hd_goc_vat_temp1
    (so_id number,
    so_id_tt number)
    ON COMMIT delete ROWS;

-- Duyet hoa hong

drop table bh_hd_goc_hh;
create table bh_hd_goc_hh
    (ma_dvi varchar2(10),
    so_id_hh number,
    ngay_ht number,
    so_ct varchar2(20),
    phong varchar2(10),
    ma_dl varchar2(20),
    ten nvarchar2(500),
    pt_tra varchar2(1),
    ttoan_qd number,
    thue_qd number,
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    nsd varchar2(10),
    so_id_kt number,
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_020 values ('0200'),
        PARTITION bh_hd_goc_hh_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_060 values ('0650'),
        PARTITION bh_hd_goc_hh_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_hh_u on bh_hd_goc_hh(ma_dvi,so_id_hh) local;
CREATE INDEX bh_hd_goc_hh_i1 on bh_hd_goc_hh(ngay_ht) local;
CREATE INDEX bh_hd_goc_hh_i2 on bh_hd_goc_hh(so_id_kt);

drop table bh_hd_goc_hh_ct;
create table bh_hd_goc_hh_ct
    (ma_dvi varchar2(10),
    so_id_hh number,
    bt number,
    so_id number,
    so_id_tt number,
    so_hd varchar2(20),
    pt varchar2(1),
    dvi_xl varchar2(20),
    phong varchar2(10),
    ma_dl varchar2(20),
    ngay_tt number,
    ma_nt varchar2(5),
    hhong number,
    htro number,
    dvu number,
    hhong_qd number,
    htro_qd number,
    dvu_qd number,
    thue number,
    thue_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_ct_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_ct_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_ct_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_ct_020 values ('0200'),
        PARTITION bh_hd_goc_hh_ct_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_ct_060 values ('0650'),
        PARTITION bh_hd_goc_hh_ct_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hh_ct_i1 on bh_hd_goc_hh_ct(so_id_hh) local;
CREATE INDEX bh_hd_goc_hh_ct_i2 on bh_hd_goc_hh_ct(so_id) local;

drop table bh_hd_goc_hh_pt;
create table bh_hd_goc_hh_pt
    (ma_dvi varchar2(10),
    so_id_hh number,
    bt number,
    so_id number,
    so_id_tt number,
    pt varchar2(1),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    hhong number,
    hhong_qd number,
    htro number,
    htro_qd number,
    dvu number,
    dvu_qd number,
    thue_hh number,
    thue_hh_qd number,
    thue_ht number,
    thue_ht_qd number,
    thue_dv number,
    thue_dv_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_pt_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_pt_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_pt_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_pt_020 values ('0200'),
        PARTITION bh_hd_goc_hh_pt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_pt_060 values ('0650'),
        PARTITION bh_hd_goc_hh_pt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hh_pt_p on bh_hd_goc_hh_pt(so_id_hh) local;

drop table bh_hd_goc_hh_ptdt;
create table bh_hd_goc_hh_ptdt
    (ma_dvi varchar2(10),
    so_id_hh number,
    bt number,
    so_id number,
    so_id_dt number,
    so_id_tt number,
    pt varchar2(1),
    ma_nt varchar2(5),
    lh_nv varchar2(10),
    hhong number,
    hhong_qd number,
    htro number,
    htro_qd number,
    dvu number,
    dvu_qd number,
    thue_hh number,
    thue_hh_qd number,
    thue_ht number,
    thue_ht_qd number,
    thue_dv number,
    thue_dv_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_ptdt_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_ptdt_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_ptdt_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_ptdt_020 values ('0200'),
        PARTITION bh_hd_goc_hh_ptdt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_ptdt_060 values ('0650'),
        PARTITION bh_hd_goc_hh_ptdt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hh_ptdt_p on bh_hd_goc_hh_ptdt(so_id_hh) local;

drop table bh_hd_goc_hh_txt;
create table bh_hd_goc_hh_txt
    (ma_dvi varchar2(10),
    so_id_hh number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_txt_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_txt_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_txt_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_txt_020 values ('0200'),
        PARTITION bh_hd_goc_hh_txt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_txt_060 values ('0650'),
        PARTITION bh_hd_goc_hh_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hh_txt_i1 on bh_hd_goc_hh_txt(so_id_hh) local;

drop table bh_hd_goc_hh_dly;
create table bh_hd_goc_hh_dly
    (ma_dvi varchar2(10),
    nv varchar2(10),
    so_id_hh number,
    ngay number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_dly_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_dly_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_dly_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_dly_020 values ('0200'),
        PARTITION bh_hd_goc_hh_dly_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_dly_060 values ('0650'),
        PARTITION bh_hd_goc_hh_dly_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_hh_dly_u1 on bh_hd_goc_hh_dly(ma_dvi,so_id_hh) local;
CREATE INDEX bh_hd_goc_hh_dly_i1 on bh_hd_goc_hh_dly(nv);

drop table bh_hd_goc_hh_dle;
create table bh_hd_goc_hh_dle
    (ma_dvi varchar2(10),
    so_id_hh number,
    ngay number,
    ma_dl varchar2(20),
    so_hd varchar2(50),
    ten_kh nvarchar2(500),
    phi number,
    hhong number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_dle_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_dle_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_dle_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_dle_020 values ('0200'),
        PARTITION bh_hd_goc_hh_dle_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_dle_060 values ('0650'),
        PARTITION bh_hd_goc_hh_dle_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_hh_dle_u1 on bh_hd_goc_hh_dle(ma_dvi,so_id_hh) local;

drop table bh_hd_goc_hh_dleL;
create table bh_hd_goc_hh_dleL
    (ma_dvi varchar2(10),
    so_id_hh number,
    ngay number,
    ma_dl varchar2(20),
    so_hd varchar2(50),
    ten_kh nvarchar2(500),
    phi number,
    hhong number,
    ngay_tt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hh_dleL_0800 values ('0800'),
        PARTITION bh_hd_goc_hh_dleL_0883 values ('0883'),
        PARTITION bh_hd_goc_hh_dleL_0885 values ('0885'),
        PARTITION bh_hd_goc_hh_dleL_020 values ('0200'),
        PARTITION bh_hd_goc_hh_dleL_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hh_dleL_060 values ('0650'),
        PARTITION bh_hd_goc_hh_dleL_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hh_dleL_u1 on bh_hd_goc_hh_dleL(so_id_hh,ngay) local;

-- Huy hop dong

drop table bh_hd_goc_hu;
create table bh_hd_goc_hu
    (ma_dvi varchar2(10),
    so_id number,
    nv varchar2(10),
    so_hd varchar2(20),
    ngay_ht number,
    so_ct varchar2(20),
    con number,
    nt_phi varchar2(5),
	choP number,
	choT number,
	choP_qd number,
	choT_qd number,
	hoanP number,
	hoanT number,
	hoanP_qd number,
	hoanT_qd number,
    pt_tra varchar2(1),
    nt_tra varchar2(5),
    tra number,
    tra_qd number,
    hthue varchar2(1),
    phong varchar2(10),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ma_dl varchar2(20),
    kvat varchar2(1),
    mau varchar2(20),
    seri varchar2(10),
    so_don varchar2(20),
    ma_ldo varchar2(10),
    so_id_kt number,
    nsd varchar2(10),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hu_0800 values ('0800'),
        PARTITION bh_hd_goc_hu_0883 values ('0883'),
        PARTITION bh_hd_goc_hu_0885 values ('0885'),
        PARTITION bh_hd_goc_hu_020 values ('0200'),
        PARTITION bh_hd_goc_hu_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hu_060 values ('0650'),
        PARTITION bh_hd_goc_hu_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_hu_u1 on bh_hd_goc_hu(ma_dvi,so_id,ngay_ht) local;
CREATE INDEX bh_hd_goc_hu_i1 on bh_hd_goc_hu(ma_kh) local;
CREATE INDEX bh_hd_goc_hu_i2 on bh_hd_goc_hu(so_id_kt);

drop table bh_hd_goc_hu_txt;
create table bh_hd_goc_hu_txt
    (ma_dvi varchar2(10),
    so_id number,
	ngay_ht number,
    loai varchar2(10),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hu_txt_0800 values ('0800'),
        PARTITION bh_hd_goc_hu_txt_0883 values ('0883'),
        PARTITION bh_hd_goc_hu_txt_0885 values ('0885'),
        PARTITION bh_hd_goc_hu_txt_020 values ('0200'),
        PARTITION bh_hd_goc_hu_txt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hu_txt_060 values ('0650'),
        PARTITION bh_hd_goc_hu_txt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hu_txt_u on bh_hd_goc_hu_txt(so_id,ngay_ht) local;

drop table bh_hd_goc_hups;
create table bh_hd_goc_hups
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ngay_ht number,
    ma_nt varchar2(5),
    ton number,
    no number,
    no_qd number,
    tra number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hups_0800 values ('0800'),
        PARTITION bh_hd_goc_hups_0883 values ('0883'),
        PARTITION bh_hd_goc_hups_0885 values ('0885'),
        PARTITION bh_hd_goc_hups_020 values ('0200'),
        PARTITION bh_hd_goc_hups_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hups_060 values ('0650'),
        PARTITION bh_hd_goc_hups_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_hups_u on bh_hd_goc_hups(ma_dvi,so_id,bt) local;

drop table bh_hd_goc_hupt;
create table bh_hd_goc_hupt
    (ma_dvi varchar2(10),
    so_id number,
    so_id_dt number,
    nv varchar2(10),
    lh_nv varchar2(20),
    ma_nt varchar2(5),
    tien number,
    tien_qd number,
    thue number,
    thue_qd number,
    bt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hupt_0800 values ('0800'),
        PARTITION bh_hd_goc_hupt_0883 values ('0883'),
        PARTITION bh_hd_goc_hupt_0885 values ('0885'),
        PARTITION bh_hd_goc_hupt_020 values ('0200'),
        PARTITION bh_hd_goc_hupt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hupt_060 values ('0650'),
        PARTITION bh_hd_goc_hupt_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_hupt_u on bh_hd_goc_hupt(so_id,bt) local;

drop table bh_hd_goc_hutt;
create table bh_hd_goc_hutt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    pt varchar2(1),
    ma_nt varchar2(5),
    tien number,
    tien_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_hutt_0800 values ('0800'),
        PARTITION bh_hd_goc_hutt_0883 values ('0883'),
        PARTITION bh_hd_goc_hutt_0885 values ('0885'),
        PARTITION bh_hd_goc_hutt_020 values ('0200'),
        PARTITION bh_hd_goc_hutt_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_hutt_060 values ('0650'),
        PARTITION bh_hd_goc_hutt_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_hutt_u on bh_hd_goc_hutt(ma_dvi,so_id,bt) local;

-- Phuc hoi

drop table bh_hd_goc_phoi;
create table bh_hd_goc_phoi
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    ldo nvarchar2(500),
    so_hd varchar2(20),
    phong varchar2(10),
    ma_kh varchar2(20),
    ten nvarchar2(500),
    ma_dl varchar2(20),
    nsd varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_phoi_0800 values ('0800'),
        PARTITION bh_hd_goc_phoi_0883 values ('0883'),
        PARTITION bh_hd_goc_phoi_0885 values ('0885'),
        PARTITION bh_hd_goc_phoi_020 values ('0200'),
        PARTITION bh_hd_goc_phoi_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_phoi_060 values ('0650'),
        PARTITION bh_hd_goc_phoi_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_phoi_i1 on bh_hd_goc_phoi(ma_dvi,so_id,ngay_ht) local;

drop table bh_hd_goc_hu_temp;
create GLOBAL TEMPORARY table bh_hd_goc_hu_temp
    (so_hd varchar2(30))
    ON COMMIT delete ROWS;

drop table bh_hd_goc_hu_temp1;
create GLOBAL TEMPORARY table bh_hd_goc_hu_temp1
    (ma_nt varchar2(5),
    phi number,
    ttoan number)
    ON COMMIT delete ROWS;

drop table bh_hd_goc_hu_temp2;
create GLOBAL TEMPORARY table bh_hd_goc_hu_temp2
    (ma_nt varchar2(5),
    phi number,
    ttoan number,
    tra number)
    ON COMMIT delete ROWS;

/*  Luu thong tin ve phi*/

drop table bh_hd_goc_sc_phi;
create table bh_hd_goc_sc_phi
    (ma_dvi varchar2(10),
    so_id number,
    ma_nt varchar2(5),
    ngay_ht number,
    no number,
    co number,
    ton number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_sc_phi_0800 values ('0800'),
        PARTITION bh_hd_goc_sc_phi_0883 values ('0883'),
        PARTITION bh_hd_goc_sc_phi_0885 values ('0885'),
        PARTITION bh_hd_goc_sc_phi_020 values ('0200'),
        PARTITION bh_hd_goc_sc_phi_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_sc_phi_060 values ('0650'),
        PARTITION bh_hd_goc_sc_phi_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_sc_phi_u on bh_hd_goc_sc_phi(so_id,ma_nt,ngay_ht) local;

drop table bh_hd_goc_sc_no;
create table bh_hd_goc_sc_no
    (ma_dvi varchar2(10),
    so_id number,
    ma_nt varchar2(5),
    ngay_ht number,
    no number,
    no_qd number,
    co number,
    co_qd number,
    ton number,
    ton_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_sc_no_0800 values ('0800'),
        PARTITION bh_hd_goc_sc_no_0883 values ('0883'),
        PARTITION bh_hd_goc_sc_no_0885 values ('0885'),
        PARTITION bh_hd_goc_sc_no_020 values ('0200'),
        PARTITION bh_hd_goc_sc_no_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_sc_no_060 values ('0650'),
        PARTITION bh_hd_goc_sc_no_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_sc_no_u on bh_hd_goc_sc_no(ma_dvi,so_id,ma_nt,ngay_ht) local;

drop table bh_hd_goc_sc_phi_ton;
create table bh_hd_goc_sc_phi_ton
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    phong varchar2(10),
    ma_kh varchar2(20),
    kieu_kt varchar2(1),
    ma_kt varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_sc_phi_ton_0800 values ('0800'),
        PARTITION bh_hd_goc_sc_phi_ton_0883 values ('0883'),
        PARTITION bh_hd_goc_sc_phi_ton_0885 values ('0885'),
        PARTITION bh_hd_goc_sc_phi_ton_020 values ('0200'),
        PARTITION bh_hd_goc_sc_phi_ton_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_sc_phi_ton_060 values ('0650'),
        PARTITION bh_hd_goc_sc_phi_ton_DEFA values (DEFAULT));
CREATE iNDEX bh_hd_goc_sc_phi_ton_i0 on bh_hd_goc_sc_phi_ton(so_id) local;
CREATE INDEX bh_hd_goc_sc_phi_ton_i1 on bh_hd_goc_sc_phi_ton(ma_kh) local;
CREATE INDEX bh_hd_goc_sc_phi_ton_i2 on bh_hd_goc_sc_phi_ton(so_hd) local;
CREATE INDEX bh_hd_goc_sc_phi_ton_i3 on bh_hd_goc_sc_phi_ton(phong) local;

drop table bh_hd_goc_sc_no_ton;
create table bh_hd_goc_sc_no_ton
    (ma_dvi varchar2(10),
    so_id number,
    so_hd varchar2(50),
    phong varchar2(10),
    ma_kh varchar2(20),
    kieu_kt varchar2(1),
    ma_kt varchar2(20))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_sc_no_ton_0800 values ('0800'),
        PARTITION bh_hd_goc_sc_no_ton_0883 values ('0883'),
        PARTITION bh_hd_goc_sc_no_ton_0885 values ('0885'),
        PARTITION bh_hd_goc_sc_no_ton_020 values ('0200'),
        PARTITION bh_hd_goc_sc_no_ton_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_sc_no_ton_060 values ('0650'),
        PARTITION bh_hd_goc_sc_no_ton_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_sc_no_ton_i0 on bh_hd_goc_sc_no_ton(so_id) local;
CREATE INDEX bh_hd_goc_sc_no_ton_i1 on bh_hd_goc_sc_no_ton(ma_kh) local;
CREATE INDEX bh_hd_goc_sc_no_ton_i2 on bh_hd_goc_sc_no_ton(so_hd) local;
CREATE INDEX bh_hd_goc_sc_no_ton_i3 on bh_hd_goc_sc_no_ton(phong) local;

-- Phi phai doi tu nha lead: dong, nhan tai tam thoi

drop table bh_hd_goc_phi_nbh;
create table bh_hd_goc_phi_nbh
    (ma_dvi varchar2(10),
    so_id number,
    nbh varchar2(20),
    ma_nt varchar2(5),
    ngay_ht number,
    no number,
    co number,
    ton number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_phi_nbh_0800 values ('0800'),
        PARTITION bh_hd_goc_phi_nbh_0883 values ('0883'),
        PARTITION bh_hd_goc_phi_nbh_0885 values ('0885'),
        PARTITION bh_hd_goc_phi_nbh_020 values ('0200'),
        PARTITION bh_hd_goc_phi_nbh_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_phi_nbh_060 values ('0650'),
        PARTITION bh_hd_goc_phi_nbh_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_phi_nbh_u on bh_hd_goc_phi_nbh(so_id,nbh,ma_nt,ngay_ht) local;

/* Thong tin ve thanh toan hoa hong*/

drop table bh_hd_goc_sc_hh;
create table bh_hd_goc_sc_hh
    (ma_dvi varchar2(10),
    so_id number,
    so_id_tt number,
    bt number,
    dvi_xl varchar2(10),
    phong varchar2(10),
    ma_dl varchar2(20),
    ngay_tt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_sc_hh_0800 values ('0800'),
        PARTITION bh_hd_goc_sc_hh_0883 values ('0883'),
        PARTITION bh_hd_goc_sc_hh_0885 values ('0885'),
        PARTITION bh_hd_goc_sc_hh_020 values ('0200'),
        PARTITION bh_hd_goc_sc_hh_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_sc_hh_060 values ('0650'),
        PARTITION bh_hd_goc_sc_hh_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_sc_hh_i1 on bh_hd_goc_sc_hh(so_id) local;
CREATE INDEX bh_hd_goc_sc_hh_i2 on bh_hd_goc_sc_hh(dvi_xl) local;
CREATE INDEX bh_hd_goc_sc_hh_i3 on bh_hd_goc_sc_hh(so_id_tt) local;

/* Thong tin ve tra hoa don VAT */

drop table bh_hd_goc_sc_vat;
create table bh_hd_goc_sc_vat
    (ma_dvi varchar2(10),
    so_id number,
    so_id_tt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_sc_vat_0800 values ('0800'),
        PARTITION bh_hd_goc_sc_vat_0883 values ('0883'),
        PARTITION bh_hd_goc_sc_vat_0885 values ('0885'),
        PARTITION bh_hd_goc_sc_vat_020 values ('0200'),
        PARTITION bh_hd_goc_sc_vat_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_sc_vat_060 values ('0650'),
        PARTITION bh_hd_goc_sc_vat_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_goc_sc_vat_u on bh_hd_goc_sc_vat(ma_dvi,so_id,so_id_tt) local;

drop table bh_hd_dt_temp;
create GLOBAL TEMPORARY table bh_hd_dt_temp
    (so_id_dt number)
    ON COMMIT delete ROWS;

drop table bh_hd_ttrang_temp;
create GLOBAL TEMPORARY table bh_hd_ttrang_temp
    (nv varchar2(10),
    tt varchar2(1))
    ON COMMIT delete ROWS;

drop table bh_hd_nv_temp;
create GLOBAL TEMPORARY table bh_hd_nv_temp
    (so_id_dt number,
    ten nvarchar2(400),
    ma_dt varchar2(30),
    lh_nv varchar2(20),
    nt_tien varchar2(5),
    tien number,
    tien_vnd number,
    nt_phi varchar2(5),
    phi number)
    ON COMMIT delete ROWS;

drop table bh_hd_nv_tong_temp;
create GLOBAL TEMPORARY table bh_hd_nv_tong_temp
    (lh_nv varchar2(20),
    nt_tien varchar2(5),
    tien number,
    tien_vnd number,
    nt_phi varchar2(5),
    phi number)
    ON COMMIT delete ROWS;

drop table bh_hd_nv_tong_temp1;
create GLOBAL TEMPORARY table bh_hd_nv_tong_temp1(
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number)
    ON COMMIT delete ROWS;

drop table bh_hd_nv_tong_temp2;
create GLOBAL TEMPORARY table bh_hd_nv_tong_temp2(
    nt_tien varchar2(5),
    tien number,
    nt_phi varchar2(5),
    phi number)
    ON COMMIT delete ROWS;

drop table bh_hd_goc_htct_temp1;
create GLOBAL TEMPORARY table bh_hd_goc_htct_temp1
    (phong varchar2(10),
    lh_nv varchar2(10),
    ttoan_qd number,
    phi_qd number,
    hhong_qd number,
    htro_qd number,
    dvu_qd number)
    ON COMMIT delete ROWS;

drop table bh_hd_goc_htct_temp;
create GLOBAL TEMPORARY table bh_hd_goc_htct_temp
    (phong varchar2(10),
    lh_nv varchar2(10),
    ttoan_qd number,
    phi_qd number,
    hhong_qd number,
    htro_qd number,
    dvu_qd number)
    ON COMMIT delete ROWS;

/* Chuyen trinh */

drop table bh_hd_goc_ch;
create table bh_hd_goc_ch
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(1),
    bt number,
    ngay number,
    ma_dvi_tr varchar2(10),
    nsd_tr varchar2(10))
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_goc_ch_0800 values ('0800'),
        PARTITION bh_hd_goc_ch_0883 values ('0883'),
        PARTITION bh_hd_goc_ch_0885 values ('0885'),
        PARTITION bh_hd_goc_ch_020 values ('0200'),
        PARTITION bh_hd_goc_ch_040 values ('0400','0410','0430'),
        PARTITION bh_hd_goc_ch_060 values ('0650'),
        PARTITION bh_hd_goc_ch_DEFA values (DEFAULT));
CREATE INDEX bh_hd_goc_ch_i1 on bh_hd_goc_ch(so_id) local;

drop table bh_hd_cta;
create table bh_hd_cta
    (ma_dvi varchar2(10),
    dvi varchar2(10),
    nv varchar2(10),
    ngay_ht number,
    so_id number,
    so_hd varchar2(50),
    nsd varchar2(10),
    ngay_nh date)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_hd_cta_0800 values ('0800'),
        PARTITION bh_hd_cta_0883 values ('0883'),
        PARTITION bh_hd_cta_0885 values ('0885'),
        PARTITION bh_hd_cta_020 values ('0200'),
        PARTITION bh_hd_cta_040 values ('0400','0410','0430'),
        PARTITION bh_hd_cta_060 values ('0650'),
        PARTITION bh_hd_cta_DEFA values (DEFAULT));
CREATE unique INDEX bh_hd_cta_u on bh_hd_cta(ma_dvi,so_id) local; 
CREATE INDEX bh_hd_cta_i1 on bh_hd_cta(dvi,so_id) local; 
CREATE INDEX bh_hd_cta_i2 on bh_hd_cta(dvi,nv,ngay_ht) local;

drop table bh_hd_goc_tim_temp;
create GLOBAL TEMPORARY table bh_hd_goc_tim_temp(
    ngay_ht number,
    nv varchar2(10),
    so_hd varchar2(20),
    ttrang varchar2(1),
    ten nvarchar2(500),
    ma_dvi varchar2(10),
    so_id number,
    ma_kh varchar2(20))
    ON COMMIT delete ROWS;

drop table bh_hd_dota_temp;
create GLOBAL TEMPORARY table bh_hd_dota_temp(
    so_id_dt number,
    nhom varchar2(10),
    ten nvarchar2(500),
    lh_nv varchar2(10),
    tien number,
    phi number,
    con_tl number,
    conT number,
    conP number,
    do_tl number,
    doT number,
    doP number,
    ta_tl number,
    taT number,
    taP number,
    ve_tl number,
    veT number,
    veP number,
    bt number)
    ON COMMIT delete ROWS;

drop table bh_hd_dota_temp_1;
create GLOBAL TEMPORARY table bh_hd_dota_temp_1(
    pthuc varchar2(10),
    nbh varchar2(20),
    nbhC varchar2(20),
    kieu varchar2(10),
    pt number,
    tien number,
    phi number,
    hh number,
    hhong number,
    thue number,
    ngay_hl number)
    ON COMMIT delete ROWS;

drop table bh_hd_dota_temp_2;
create GLOBAL TEMPORARY table bh_hd_dota_temp_2(
    pthuc varchar2(10),
    nbh varchar2(20),
    nbhC varchar2(20),
    kieu varchar2(10),
    pt number,
    ptG number,
    tien number,
    phi number,
    hh number,
    hhong number,
    tl_thue number,
    thue number)
    ON COMMIT delete ROWS;

drop table bh_hd_dota_temp_3;
create GLOBAL TEMPORARY table bh_hd_dota_temp_3(
    nbh varchar2(20),
    nbhC varchar2(20),
    kieu varchar2(10),
    tien number,
    phi number,
    hhong number,
    thue number)
    ON COMMIT delete ROWS;

drop table bh_hd_dota_temp_4;
create GLOBAL TEMPORARY table bh_hd_dota_temp_4(
    nbh varchar2(20),
    nbhC varchar2(20),
    kieu varchar2(10),
    tien number,
    pt number,
    phi number,
    hhong number,
    thue number)
    ON COMMIT delete ROWS;

drop table bh_hd_goc_ve;
create table bh_hd_goc_ve
(
  ma_dvi  varchar2(10),
  so_id   number,
  so_id_d number,
  so_id_g number,
  nv      varchar2(10),
  ngay_ht number,
  ngay_ta number
)
partition by list (ma_dvi)
(
  partition bh_hd_goc_ve_001 values ('001'),
  partition bh_hd_goc_ve_002 values ('002'),
  partition bh_hd_goc_ve_defa values (default)
);
create index bh_hd_goc_ve_i1 on bh_hd_goc_ve (ngay_ta);
create index bh_hd_goc_ve_i2 on bh_hd_goc_ve (nv, ngay_ht, ngay_ta);
create unique index bh_hd_goc_ve_u on bh_hd_goc_ve (ma_dvi, so_id);

drop table bh_hd_goc_dt;
create table bh_hd_goc_dt
(
  ma_dvi varchar2(10),
  so_id  number,
  bt     number,
  ma     varchar2(10),
  ma_tke varchar2(20),
  g_tri  varchar2(200)
)
partition by list (ma_dvi)
(
  partition bh_hd_goc_dt_001 values ('001'),
  partition bh_hd_goc_dt_002 values ('002'),
  partition bh_hd_goc_dt_defa values (default)
);
create unique index bh_hd_goc_dt_u on bh_hd_goc_dt (ma_dvi, so_id, bt, ma_tke);

drop table bh_hd_goc_hh_tt;
create table bh_hd_goc_hh_tt
(
  ma_dvi   varchar2(10),
  so_id_hh number,
  bt       number,
  pt       varchar2(1),
  ma_nt    varchar2(5),
  tien     number,
  tien_qd  number
)
partition by list (ma_dvi)
(
  partition bh_hd_goc_hh_tt_0800 values ('0800'),
  partition bh_hd_goc_hh_tt_DEFA values (DEFAULT)
);
create unique index bh_hd_goc_hh_tt_u on bh_hd_goc_hh_tt (ma_dvi, so_id_hh, bt) local;

drop table bh_hd_goc_ttdt;
create table bh_hd_goc_ttdt (
  ma_dvi    varchar2(10 byte),
  so_id     number,
  so_id_dt  number,
  nv        varchar2(10 byte),
  ten       nvarchar2(500),
  ma_kh     varchar2(20 byte),
  ngay_kt   number,
  ttin      clob
) partition by list (ma_dvi) (
    partition bh_hd_goc_hh_tt_0800 values ('0800'),
    partition bh_hd_goc_hh_tt_defa values (default)
);
create index bh_hd_goc_ttdt_i1 on bh_hd_goc_ttdt (so_id);
create index bh_hd_goc_ttdt_i2 on bh_hd_goc_ttdt (ma_kh);