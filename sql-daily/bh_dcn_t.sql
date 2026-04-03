drop table bh_dcn_ma;
create table bh_dcn_ma
    (ma varchar2(20),
    ten nvarchar2(200),
    cmt varchar2(20),
    ng_sinh number,
    gioi varchar2(1),
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100),--duchq update length email
    ma_nh varchar2(10),
    so_tk varchar2(20),
    ten_tk nvarchar2(100),
    kvuc varchar2(20),
    txt clob
);
create unique index bh_dcn_ma_u0 on bh_dcn_ma(ma);
CREATE unique INDEX bh_dcn_ma_u1 on bh_dcn_ma(mobi);
CREATE unique INDEX bh_dcn_ma_u2 on bh_dcn_ma(cmt);
CREATE INDEX bh_dcn_ma_u3 on bh_dcn_ma(email);

drop table bh_dcn_maL;
create table bh_dcn_maL
    (ma varchar2(20),
    ten nvarchar2(200),
    cmt varchar2(20),
    ng_sinh number,
    gioi varchar2(1),
    dchi nvarchar2(500),
    mobi varchar2(20),
    email varchar2(100), --duchq update length
    ma_nh varchar2(10),
    so_tk varchar2(20),
    ten_tk nvarchar2(100),
    kvuc varchar2(20),
    txt clob,
    ngay date);

-- To chuc

drop table bh_dcn_ma_tc;
create table bh_dcn_ma_tc
    (ma varchar2(30),
    ma_ql varchar2(30)
);
create unique index bh_dcn_ma_tc_u0 on bh_dcn_ma_tc(ma);
CREATE INDEX bh_dcn_ma_tc_i1 on bh_dcn_ma_tc(ma_ql);

-- Tuyen dung

drop table bh_dcn_ma_td;
create table bh_dcn_ma_td
    (ma varchar2(30),
    ma_ql varchar2(30)
);
create unique index bh_dcn_ma_td_u0 on bh_dcn_ma_td(ma);
CREATE INDEX bh_dcn_ma_td_i1 on bh_dcn_ma_td(ma_ql);

-- Don vi,can bo huong doanh thu

drop table bh_dcn_ma_dvi;
create table bh_dcn_ma_dvi
    (ma varchar2(30),
    ma_dvi varchar2(20),
 ma_cb varchar2(20)
);
create unique index bh_dcn_ma_dvi_u0 on bh_dcn_ma_dvi(ma);

-- chung chi

drop table bh_dcn_ma_cc;
create table bh_dcn_ma_cc
    (ma varchar2(30),
    so varchar2(30),
    ngay number,
    nsd varchar2(30)
);
create unique index bh_dcn_ma_cc_u0 on bh_dcn_ma_cc(ma);

-- San pham duoc ban

drop table bh_dcn_ma_sp;
create table bh_dcn_ma_sp
    (ma varchar2(30),
    sp varchar2(100)           -- Danh sach form san pham dai ly duoc phep ban
);
create unique index bh_dcn_ma_sp_u0 on bh_dcn_ma_sp(ma,sp);

drop table bh_dcn_ma_cd;
create table bh_dcn_ma_cd
    (ma varchar2(30),
    chuc varchar2(1),           -- 1:Nhom, P:Phong, G:Giam doc
 ngay number
);
create unique index bh_dcn_ma_cd_u0 on bh_dcn_ma_cd(ma);

drop table bh_dcn_ma_cdL;
create table bh_dcn_ma_cdL
    (ma varchar2(30),
    chuc varchar2(1),
 ngay number,
    ngay_ht date);

drop table bh_dcn_ma_cdS;
create table bh_dcn_ma_cdS
    (ma varchar2(30),
    so number,
    ngay number);
CREATE INDEX bh_dcn_ma_cdS_i1 on bh_dcn_ma_cdS(ma);

-- Danh sach den

drop table bh_dcn_ma_den;
create table bh_dcn_ma_den
    (ma varchar2(30),
    lydo nvarchar2(200)
);
create unique index bh_dcn_ma_den_u0 on bh_dcn_ma_den(ma);

-- Ty le Hoa hong, ho tro, dich vu

drop table bh_dcn_ma_hh;
create table bh_dcn_ma_hh
    (nv varchar2(5),
    sp varchar2(20),
 ngay number,
    lh_nv varchar2(10),
    hhong number,
    htro number,
    dvu number,
    nsd varchar2(10)
);
create unique index bh_dcn_ma_hh_u0 on bh_dcn_ma_hh(nv,sp,ngay,lh_nv);

-- Thue thu nhap dai ly

drop table bh_dcn_ma_thue;
create table bh_dcn_ma_thue
    (ngay number,
    ts number
);
create unique index bh_dcn_ma_thue_u0 on bh_dcn_ma_thue(ngay);

-- He so thuong dai ly theo doanh thu

drop table bh_dcn_ma_hsoD;
create table bh_dcn_ma_hsoD
    (ngay number,
    dthu number,
 hso number
);
create unique index bh_dcn_ma_hsod_u0 on bh_dcn_ma_hsod(ngay,dthu);

-- He so thuong theo doanh thu nhom cho quan ly

drop table bh_dcn_ma_hsoQ;
create table bh_dcn_ma_hsoQ
    (ngay number,
 cd varchar2(1),
    dthu number,
 hso number
);
create unique index bh_dcn_ma_hsoq_u0 on bh_dcn_ma_hsoq(ngay,cd,dthu);

-- Muc thuong tuyen dung

drop table bh_dcn_ma_hsoT;
create table bh_dcn_ma_hsoT
    (ngay number,
    tien number
);
create unique index bh_dcn_ma_hsot_u0 on bh_dcn_ma_hsot(ngay);

-- He so thuong doi, nhom

drop table bh_dcn_ma_hsoC;
create table bh_dcn_ma_hsoC
    (ma varchar2(30),
 ngay number,
    dthu number,
 hso number
);
create unique index bh_dcn_ma_hsoc_u0 on bh_dcn_ma_hsoc(ma,ngay,dthu);

/*** DIEM ***/

drop table bh_dcn_diem_ct;
CREATE TABLE bh_dcn_diem_ct
    (so_id_hh number,
    ngay_ht number,
 so_id number,
    gcn varchar2(30),
    ten nvarchar2(500),
    ma varchar2(30),
 maQ varchar2(30),
    tien number,
    hhong number,
    htro number,
    dvu number);
CREATE INDEX bh_dcn_diem_ct_i0 on bh_dcn_diem_ct(so_id_hh);
CREATE INDEX bh_dcn_diem_ct_i1 on bh_dcn_diem_ct(ma,ngay_ht);
CREATE INDEX bh_dcn_diem_ct_i2 on bh_dcn_diem_ct(maQ,ngay_ht);
CREATE INDEX bh_dcn_diem_ct_i3 on bh_dcn_diem_ct(ngay_ht);

drop table bh_dcn_diem_ctL;
CREATE TABLE bh_dcn_diem_ctL
    (so_id_hh number,
    ngay_ht number,
 so_id number,
    gcn varchar2(30),
    ten nvarchar2(500),
    ma varchar2(30),
 maQ varchar2(30),
    tien number,
    hhong number,
    htro number,
    dvu number);

drop table bh_dcn_diem_dvu;
CREATE TABLE bh_dcn_diem_dvu
    (so_id_hh number,
    ngay_ht number,
    ma varchar2(30),
    so number
);
create unique index bh_dcn_diem_dvu_u0 on bh_dcn_diem_dvu(so_id_hh);
CREATE INDEX bh_dcn_diem_dvu_i1 on bh_dcn_diem_dvu(ma);

drop table bh_dcn_diem_dvuL;
CREATE TABLE bh_dcn_diem_dvuL
    (so_id_hh number,
    ngay_ht number,
    ma varchar2(30),
    so number);

drop table bh_dcn_diem_ps;
CREATE TABLE bh_dcn_diem_ps
    (ma varchar2(30),
 ngay number
);
create unique index bh_dcn_diem_ps_u0 on bh_dcn_diem_ps(ma);

drop table bh_dcn_diem_doi;
CREATE TABLE bh_dcn_diem_doi
    (so_id number,
    ngay_ht number,
    ma varchar2(30),
    so number,
 soT number,
 soQ number,
    ma_dviQ varchar2(10)
);
create unique index bh_dcn_diem_doi_u0 on bh_dcn_diem_doi(so_id);

drop table bh_dcn_diem_co;
CREATE TABLE bh_dcn_diem_co
    (ma varchar2(30),
    loai varchar2(10),
    so number
);
create unique index bh_dcn_diem_co_u0 on bh_dcn_diem_co(ma,loai);

drop table bh_dcn_diem_coL;
CREATE TABLE bh_dcn_diem_coL
    (ma varchar2(30),
    loai varchar2(10),
    so number,
    ngay_ht date);

drop table bh_dcn_diem_ls;
 CREATE TABLE bh_dcn_diem_ls
  (ma varchar2(30),
  loai varchar2(10),
  so number,
  nd nvarchar2(500),
  ngay date);

/*** To chuc ***/

drop table bh_dtc_ma_hh;
create table bh_dtc_ma_hh
    (ma varchar2(20),
 nv varchar2(5),
    sp varchar2(20),
 ngay number,
    lh_nv varchar2(10),
    hhong number,
    htro number,
    dvu number,
    nsd varchar2(10)
);
create unique index bh_dtc_ma_hh_u0 on bh_dtc_ma_hh(ma,nv,sp,ngay,lh_nv);

drop table bh_dtc_ma_pbo;
create table bh_dtc_ma_pbo
    (ma varchar2(20),
 ngay number,
 pbo number,
    nsd varchar2(10)
);
create unique index bh_dtc_ma_pbo_u0 on bh_dtc_ma_pbo(ma,ngay);