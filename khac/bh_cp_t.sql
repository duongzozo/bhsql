-- CHI PHI KHAC --

drop table bh_cp_lct;
CREATE TABLE bh_cp_lct
 (ma_dvi varchar2(10),
 l_ct varchar2(10),
 ten nvarchar2(400),
 nv varchar2(1),
 pdo varchar2(1),
 pta varchar2(1),
 nsd varchar2(10)
);
create unique index bh_cp_lct_u0 on bh_cp_lct(ma_dvi,l_ct);

drop TABLE bh_cp;
CREATE TABLE bh_cp
    (ma_dvi varchar2(10),
    so_id number,
    ngay_ht number,
    l_ct varchar2(10),
    so_ct varchar2(20),
    nv varchar2(10),
    ma_tke varchar2(10),
    phong varchar2(10),
    so_hd varchar2(50),
    so_id_hd number,
    so_hs varchar2(50),
    so_id_hs number,
    ma_nt varchar2(5),  
    tien number,
    tien_qd number,
    thue number,
    thue_qd number,
    ttoan number,
    ttoan_qd number,
    so_don varchar2(20),
    c_thue varchar2(1),
    t_suat number,
    ma_thue varchar2(30),
    ten nvarchar2(500),
    dchi nvarchar2(500),
    nd nvarchar2(500),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_cp_0800 values ('0800'),
        PARTITION bh_cp_DEFA values (DEFAULT));
CREATE unique INDEX bh_cp_u on bh_cp(ma_dvi,so_id) local;
CREATE INDEX bh_cp_i1 on bh_cp(ngay_ht) local;
CREATE INDEX bh_cp_i2 on bh_cp(so_id_kt) local;

drop table bh_cp_txt;
create table bh_cp_txt
 (ma_dvi varchar2(10),
 so_id number,
 loai varchar2(10),
 txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_cp_txt_0800 values ('0800'),
        PARTITION bh_cp_txt_DEFA values (DEFAULT));
CREATE INDEX bh_cp_txt_i1 on bh_cp_txt(so_id,loai) local;

-- chuclh

drop table bh_cp_pt;
create table bh_cp_pt
 (ma_dvi varchar2(10),
 so_id number,
 so_id_bt number,
 so_id_hd number,
 so_id_dt number,
 ngay_ht number,
 l_ct varchar2(1),
 nv varchar2(10),
    ma_tke varchar2(10),
 lh_nv varchar2(20),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 thue number,
 thue_qd number)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_cp_pt_0800 values ('0800'),
        PARTITION bh_cp_pt_DEFA values (DEFAULT));
CREATE INDEX bh_cp_pt_i1 on bh_cp_pt(so_id) local;

drop table bh_cp_tke;
create table bh_cp_tke
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(500),
 loai varchar2(1),
 ngay_kt number,
 nsd varchar2(10)
);
create unique index bh_cp_tke_u0 on bh_cp_tke(ma);