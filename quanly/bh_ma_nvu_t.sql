-- lhnv Bo tai chinh

drop table bh_ma_lhnv_bo;
create table bh_ma_lhnv_bo
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(10),
    t_suat number,
    pt_nop number,
    pt_thau number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_lhnv_bo_u0 on bh_ma_lhnv_bo(ma);
create index bh_ma_lhnv_bo_i1 on bh_ma_lhnv_bo(tc);

drop table bh_ma_lhnv_boL;
create table bh_ma_lhnv_boL
    (ma varchar2(10),
    ngay_bd number,
    t_suat number,
    pt_nop number,
    pt_thau number);
create index bh_ma_lhnv_boL_i1 on bh_ma_lhnv_boL(ma);

-- lhnv tai

drop table bh_ma_lhnv_tai;
create table bh_ma_lhnv_tai
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(10),
    ma_cd varchar2(10),
    ngay_kt number,
    nv varchar2(100),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_lhnv_tai_u0 on bh_ma_lhnv_tai(ma);
create index bh_ma_lhnv_tai_i1 on bh_ma_lhnv_tai(tc);

-- lhnv

drop table bh_ma_lhnv;
create table bh_ma_lhnv
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    tc varchar2(1),
    bb varchar2(1),     -- B bat buoc, T tu nguyen
    loai varchar2(5),         -- V-Tai san,N-Con nguoi,TV-Trach nhiem tai san, TN-Trach nhiem ve nguoi, K-Khac
    ma_ct varchar2(10),
    ma_cd varchar2(10),
    ma_tai varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nv varchar2(100),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_lhnv_u0 on bh_ma_lhnv(ma);
CREATE INDEX bh_ma_lhnv_i1 on bh_ma_lhnv(ma_cd);
CREATE INDEX bh_ma_lhnv_i2 on bh_ma_lhnv(ma_tai);
CREATE INDEX bh_ma_lhnv_i3 on bh_ma_lhnv(tc);

-- Hoa hong, ho tro, dvu

drop table bh_ma_lhnv_thue;
create table bh_ma_lhnv_thue
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ngay_bd number,
    hhong number,
    hh_q number,
    hh_f number,
    htro number,
    ht_q number,
    ht_f number,
    dvu number,
    dv_q number,
    dv_f number
);
create unique index bh_ma_lhnv_thue_u0 on bh_ma_lhnv_thue(ma,ngay_bd);

-- Qui tac

drop table bh_ma_qtac;
create table bh_ma_qtac
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ngay_kt number,
    nv varchar2(100),
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_qtac_u0 on bh_ma_qtac(ma);

-- Dieu khoan

drop table bh_ma_dk;
create table bh_ma_dk 
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(400),
    tc varchar2(1),
    ma_ct varchar2(10),
 lh_nv varchar2(10),
    ngay_kt number,
    nv varchar2(100),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_dk_u0 on bh_ma_dk(ma);
CREATE INDEX bh_ma_dk_i1 on bh_ma_dk(tc);

drop table bh_ma_dkbs;
create table bh_ma_dkbs
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(400),
    ma_dk varchar2(10),
 lh_nv varchar2(10),
    ngay_kt number,
    nv varchar2(100),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_dkbs_u0 on bh_ma_dkbs(ma);
CREATE INDEX bh_ma_dkbs_i1 on bh_ma_dkbs(ma_dk);

drop table bh_ma_dklt;
create table bh_ma_dklt
    (ma_dvi varchar2(10),
    ma_dk varchar2(10),
    ma varchar2(10),
    ten nvarchar2(400),
    ngay_kt number,
    nv varchar2(100),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_dklt_u0 on bh_ma_dklt(ma);

drop table bh_ma_dknv_temp;
create GLOBAL TEMPORARY table bh_ma_dknv_temp
    (xep varchar2(1),
 ma varchar2(30),
 ten nvarchar2(500));

drop table bh_ma_hk;
create table bh_ma_hk
(
  ma_dvi varchar2(10),
  ma     varchar2(20),
  ten    nvarchar2(200),
  kieu   varchar2(1),
  nsd    varchar2(10)

);
create unique index bh_ma_hk_u0 on bh_ma_hk(ma_dvi, ma);

drop table bh_ma_lhnv_kh;
create table bh_ma_lhnv_kh
(
  ma_dvi varchar2(10),
  ngay   number,
  kieu   varchar2(1),
  dvi    varchar2(10),
  ma     varchar2(10),
  kh     number,
  nsd    varchar2(10)

);
create unique index bh_ma_lhnv_kh_u0 on bh_ma_lhnv_kh(ma_dvi, ngay, kieu, dvi, ma);