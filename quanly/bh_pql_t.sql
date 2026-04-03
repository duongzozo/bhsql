-- Kieu tinh thue

drop table bh_ht_thue;
create table bh_ht_thue
 (ma_dvi varchar2(10),
 ngay number,
 no_phi varchar2(1),
 hanTT varchar2(3),
 tl_hh varchar2(1),
 tl_ht varchar2(1),
 hh_gt varchar2(1),
 hh_mg varchar2(1),
 hh_ht varchar2(1),
 hh_th varchar2(1),
 hh_do varchar2(1),
 hh_ta varchar2(1),
 gcn_2b varchar2(1),
 gcn_xe varchar2(1),
 gcn_ng varchar2(1),
 gcn_hang varchar2(1),
 gcn_tau varchar2(1),
 gcn_phh varchar2(1),
 gcn_pkt varchar2(1),
 gcn_ptn varchar2(1),
 gcn_td varchar2(1),
 phi_do varchar2(1),
 tt_do varchar2(1),
 ch_ta varchar2(1),
 gh_phh varchar2(1),
 gh_pkt varchar2(1),
 gh_hang varchar2(1),
 nsd varchar2(10)
);
create unique index bh_ht_thue_u0 on bh_ht_thue(ma_dvi,ngay);

--Ma hau qua

drop table bh_ma_hq;
create table bh_ma_hq
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(50),
 nsd varchar2(10)
);
create unique index bh_ma_hq_u0 on bh_ma_hq(ma_dvi,ma);

--Ma tuyen van chuyen

drop table bh_ma_tvc;
create table bh_ma_tvc
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(50),
 nsd varchar2(10)
);
create unique index bh_ma_tvc_u0 on bh_ma_tvc(ma_dvi,ma);

-- Ma quy loi

drop TABLE bh_ma_qloi;
CREATE TABLE bh_ma_qloi
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(100),
 nsd varchar2(10)
);
create unique index bh_ma_qloi_u0 on bh_ma_qloi(ma_dvi,ma);

--Ma nguyen nhan tai nan

drop TABLE bh_ma_nn;
CREATE TABLE bh_ma_nn
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(100),
 nsd varchar2(10)
);
create unique index bh_ma_nn_u0 on bh_ma_nn(ma_dvi,ma);

-- Muc do thiet hai

drop TABLE bh_ma_md;
CREATE TABLE bh_ma_md
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(200),
 nsd varchar2(10)
);
create unique index bh_ma_md_u0 on bh_ma_md(ma_dvi,ma);

-- MA TY LE THUONG TAT

drop table bh_ma_tle;
create table bh_ma_tle
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(50),
 ty_le varchar2(10),
 nsd varchar2(10)
);
create unique index bh_ma_tle_u0 on bh_ma_tle(ma_dvi,ma);


-- Ma thong ke bao hiem

drop table bh_ma_lcp;
create table bh_ma_lcp
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(50),
 tc varchar2(1),
 ma_ct varchar2(10),
 nsd varchar2(10)
);
create unique index bh_ma_lcp_u0 on bh_ma_lcp(ma_dvi,ma);
CREATE INDEX bh_ma_lcp_i1 on bh_ma_lcp(ma_dvi,ma_ct);

drop table bh_ma_lcp_kh;
create table bh_ma_lcp_kh
 (ma_dvi varchar2(10),
 ngay number,
 kieu varchar2(1),
 dvi varchar2(10),
 ma varchar2(10),
 kh number,
 nsd varchar2(10)
);
create unique index bh_ma_lcp_kh_u0 on bh_ma_lcp_kh(ma_dvi,ngay,kieu,dvi,ma);

-- Loai hinh bao hiem --

drop table bh_ma_lhbh;
create table bh_ma_lhbh
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ten nvarchar2(50),
 ngay date,
 ld_ky varchar2(10),
 phong varchar2(10),
 nsd varchar2(10)
);
create unique index bh_ma_lhbh_u0 on bh_ma_lhbh(ma_dvi,ma); 
 
-- Cap duyet

drop TABLE  bh_ma_lhbh_nd;
create table bh_ma_lhbh_nd
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ngay date,
 tien number,
 cap varchar2(5)
);
create unique index bh_ma_lhbh_nd_u0 on bh_ma_lhbh_nd(ma_dvi,ma,ngay,tien);

-- Nguong tai

drop TABLE bh_ma_lhbh_nt;
create table bh_ma_lhbh_nt
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ngay date,
 tien number,
 loai varchar2(1)
);
create unique index bh_ma_lhbh_nt_u0 on bh_ma_lhbh_nt(ma_dvi,ma,ngay,tien);

-- Thong tin doi tuong

drop table bh_ma_lhbh_dt;
create table bh_ma_lhbh_dt
 (ma_dvi varchar2(10),
 ma varchar2(10),
 ma_dt varchar2(10),
 ma_tke varchar2(20),
 ten nvarchar2(200),
 loai varchar2(1),
 do_dai number,
 luu varchar2(1),
 so_tt number
);
create unique index bh_ma_lhbh_dt_u0 on bh_ma_lhbh_dt(ma_dvi,ma,ma_dt,ma_tke);

drop table bh_ma_nh_ngh;
create table bh_ma_nh_ngh
 (ma_dvi varchar2(10),
 ma varchar2(20),
 ten nvarchar2(200),
 nsd varchar2(10)
);
create unique index bh_ma_nh_ngh_u0 on bh_ma_nh_ngh(ma_dvi,ma);

drop table bh_ma_dt;
create table bh_ma_dt
 (ma_dvi varchar2(10),
 ma varchar2(20),
 ten nvarchar2(200),
 nsd varchar2(10)
);
create unique index bh_ma_dt_u0 on bh_ma_dt(ma_dvi,ma);

-- file anh

drop table bh_anh;
create table bh_anh(
 ma_dvi varchar2(10),
 so_id number,
 so_id_dt number,
 loai varchar2(3),
 ten nvarchar2(200),
 anh BLOB,
 nsd varchar2(10)
);
create unique index bh_anh_u0 on bh_anh(ma_dvi,so_id_dt);
CREATE INDEX bh_anh_i1 on bh_anh(ma_dvi,so_id);

/* Ngay duoc lui theo nghiep vu */

drop table bh_nv_ngay;
CREATE TABLE bh_nv_ngay
    (ma_dvi varchar2(20),
 nv varchar2(10),
    ngay number,
    nsd varchar2(10)
);
create unique index bh_nv_ngay_u0 on bh_nv_ngay(ma_dvi,nv);

drop table bh_ma_bs;
create table bh_ma_bs
 (ma_dvi varchar2(20),
 nv varchar2(10),
 ma varchar2(30),
 ten nvarchar2(400),
 ten_e varchar2(200),
 lh_nv varchar2(10),
 nsd varchar2(10)
);
create unique index bh_ma_bs_u0 on bh_ma_bs(ma_dvi,nv,ma);