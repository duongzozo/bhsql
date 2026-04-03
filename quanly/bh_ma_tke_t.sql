-- Ma  dich

drop table bh_ma_cdich;
create table bh_ma_cdich
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_bd number,
    ngay_kt number,
 nv varchar2(100),
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_cdich_u0 on bh_ma_cdich(ma);
create index bh_ma_cdich_i1 on bh_ma_cdich(tc);

drop table bh_ma_lvuc;
create table bh_ma_lvuc
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
 md_rr varchar2(1),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_lvuc_u0 on bh_ma_lvuc(ma);

drop table bh_ma_nghe;
create table bh_ma_nghe
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
 md_rr varchar2(1),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_nghe_u0 on bh_ma_nghe(ma);

-- nhom tuoi

drop table bh_ma_tuoi;
create table bh_ma_tuoi
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),             -- D-Ngay, M-Thang, Y-Nam
    tuoi number,
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_tuoi_u0 on bh_ma_tuoi(ma);

drop table bh_ma_ldn;
create table bh_ma_ldn
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_ldn_u0 on bh_ma_ldn(ma);

drop table bh_ma_nhom_dtuong;
create table bh_ma_nhom_dtuong
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
 mrr varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_nhom_dtuong_u0 on bh_ma_nhom_dtuong(ma);
create index bh_ma_nhom_dtuong_i1 on bh_ma_nhom_dtuong (ma_ct);

drop table bh_ma_dtuong;
create table bh_ma_dtuong
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
 md_rr varchar2(1), -- chuclh
    ngay_kt number,
    nv varchar(10), -- chuclh
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_dtuong_u0 on bh_ma_dtuong(ma);
create index bh_ma_dtuong_i1 on bh_ma_dtuong (ma_ct);

drop table bh_ma_rr;
create table bh_ma_rr
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nv varchar2(100),
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_rr_u0 on bh_ma_rr(ma);

drop table bh_ma_nntt;
create table bh_ma_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nv varchar2(100),
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_nntt_u0 on bh_ma_nntt(ma);

drop table bh_ma_mdtt;
create table bh_ma_mdtt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_mdtt_u0 on bh_ma_mdtt(ma);

drop table bh_ma_huy;
create table bh_ma_huy
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_huy_u0 on bh_ma_huy(ma);

drop table bh_ma_kenh;
create table bh_ma_kenh
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ma_bo varchar2(10),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_kenh_u0 on bh_ma_kenh(ma);

drop table bh_ma_sdbs;
create table bh_ma_sdbs
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_ma_sdbs_u0 on bh_ma_sdbs(ma);

-- Duchq

drop table bh_loai_cphi;
create table bh_loai_cphi
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_loai_cphi_u0 on bh_loai_cphi(ma);

drop table bh_ma_skien;
create table bh_ma_skien
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_bd number,
    ngay_kt number,
 nv varchar2(100),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ma_skien_u0 on bh_ma_skien(ma);
create index bh_ma_skien_i1 on bh_ma_skien(ma_ct);