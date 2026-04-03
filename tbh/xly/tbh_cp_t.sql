-- CHI PHI KHAC --

drop TABLE tbh_cp;
CREATE TABLE tbh_cp
    (ma_dvi varchar2(20),
    so_id number,
    ngay_ht number,
    l_ct varchar2(10),
    so_ct varchar2(20),
    nha_bh varchar2(20),
    nv varchar2(10),
    ma_tke varchar2(10),
    dvi varchar2(10),
    so_hd varchar2(20),
    so_hs varchar2(30),
    ma_nt varchar2(5),
    tien number,
    thue number,
    ttoan number,
    tien_qd number,
    thue_qd number,
    ttoan_qd number,
    so_don varchar2(20),
    nsd varchar2(10),
    ngay_nh date,
    so_id_kt number
);
create unique index tbh_cp_u0 on tbh_cp(so_id);
CREATE INDEX tbh_cp_i1 on tbh_cp(ngay_ht);
CREATE INDEX tbh_cp_i2 on tbh_cp(so_id_kt);

drop table tbh_cp_pt;
create table tbh_cp_pt
 (ma_dvi varchar2(10),
 so_id number,
 dvi varchar2(10),
 so_id_hd number,
 so_id_dt number,
 ngay_ht number,
 l_ct varchar2(10),
 nv varchar2(10),
    ma_tke varchar2(10),
 lh_nv varchar2(20),
 ma_nt varchar2(5),
 tien number,
 tien_qd number,
 thue number,
 thue_qd number);
CREATE INDEX tbh_cp_pt_i1 on tbh_cp_pt(so_id);

drop table tbh_cp_txt;
create table tbh_cp_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX tbh_cp_txt_i1 on tbh_cp_txt(so_id);