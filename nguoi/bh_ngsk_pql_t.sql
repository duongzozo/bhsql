drop TABLE bh_sk_vph;
CREATE TABLE bh_sk_vph
    (ma_bv varchar2(20),
    ma varchar2(20),
    ten nvarchar2(500),
    ma_ct varchar2(10),
    ma_dk varchar2(10),
 bhxh number
);
create unique index bh_sk_vph_u0 on bh_sk_vph(ma_bv,ma);
CREATE INDEX bh_sk_vph_i1 on bh_sk_vph(ma_bv,ma_ct);

-- Thoi gian cho

drop TABLE bh_sk_cho;
CREATE TABLE bh_sk_cho
    (ma_bv varchar2(20),
    ma varchar2(20),
    ten nvarchar2(500),
    tc varchar2(1),    
    ma_ct varchar2(10),
    so_ngay number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_sk_cho_u0 on bh_sk_cho(ma);
CREATE INDEX bh_sk_cho_i1 on bh_sk_cho(ma_ct);

/* Ma benh */

drop table bh_sk_benh;
create table bh_sk_benh
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    muc number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_sk_benh_u0 on bh_sk_benh(ma);

/* Ma phau thuat */

drop table bh_sk_pthuat;
create table bh_sk_pthuat
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    tlbtM number,
 tlbtX number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_sk_pthuat_u0 on bh_sk_pthuat(ma);

/* Ty le thuong tat */

drop table bh_sk_tttl;
create table bh_sk_tttl
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(1000),
    tc varchar2(1),
    ma_ct varchar2(10),
    tlbtM number,
 tlbtX number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_sk_tttl_u0 on bh_sk_tttl(ma);

drop table bh_sk_benhL;
create table bh_sk_benhL
    (ma varchar2(10),
    ngay_bd number,
    muc number);
create index bh_sk_benhL_i1 on bh_sk_benhL(ma);

/* Ma san pham */

drop table bh_sk_sp;
create table bh_sk_sp
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_bd number,
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_sk_sp_u0 on bh_sk_sp(ma);
create index bh_sk_sp_i1 on bh_sk_sp (ma_ct);

/* Ma goi */

drop table bh_sk_goi;
CREATE TABLE bh_sk_goi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_sk_goi_u0 on bh_sk_goi(ma);

-- Ty le phi / tgian BH

drop table bh_sk_tltg;
create table bh_sk_tltg
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_sk_tltg_i1 on bh_sk_tltg(tltg);

-- ty le giam phi toi da / so nguoi

drop table bh_sk_tlgi;
create table bh_sk_tlgi
    (ma_dvi varchar2(10),
    so_ng number,
    tl_giam number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_sk_tlgi_i1 on bh_sk_tlgi(so_ng);

/* Bieu phi */

drop table bh_sk_phi;
CREATE TABLE bh_sk_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
    tuoi number,
    luong number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_sk_phi_u0 on bh_sk_phi(so_id);
CREATE INDEX bh_sk_phi_i1 on bh_sk_phi(nhom,ma_sp,cdich,goi,tuoi,luong);

drop table bh_sk_phi_dk;
CREATE TABLE bh_sk_phi_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),         -- Ma cap tren
    kieu varchar2(1),
    tien number,
    pt number,
    phi number,
    lkeM varchar2(1),
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    ma_dk varchar2(10),
    ma_dkC varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    cap number,                 
    lh_bh varchar2(5)-- C-Chinh M-Mo rong

);
create unique index bh_sk_phi_dk_u0 on bh_sk_phi_dk(so_id,bt);

drop table bh_sk_phi_lt;
CREATE TABLE bh_sk_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_sk_phi_lt_u0 on bh_sk_phi_lt(so_id,bt);

drop table bh_sk_phi_txt;
create table bh_sk_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob
);
create unique index bh_sk_phi_txt_u0 on bh_sk_phi_txt(so_id,loai);