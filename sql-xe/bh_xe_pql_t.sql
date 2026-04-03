-- Nguyen nhan ton that

drop table bh_xe_vach;
create table bh_xe_vach
 (nv varchar2(20),
    stt number);

drop table bh_xe_nntt;
create table bh_xe_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_nntt_u0 on bh_xe_nntt(ma);
create index bh_xe_nntt_i1 on bh_xe_nntt (ma_ct);

/* Ma loai xe */

drop table bh_xe_loai;
create table bh_xe_loai
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_loai_u0 on bh_xe_loai(ma);

drop table bh_xe_nhom;
create table bh_xe_nhom
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_nhom_u0 on bh_xe_nhom(ma);

drop table bh_xe_dong;
create table bh_xe_dong
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_dong_u0 on bh_xe_dong(ma);

drop table bh_xe_hang;
create table bh_xe_hang
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_xe_hang_u0 on bh_xe_hang(ma);

drop table bh_xe_hieu;
create table bh_xe_hieu
    (ma_dvi varchar2(10),
    hang varchar2(20),
    ma varchar2(20),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_xe_hieu_u0 on bh_xe_hieu(hang,ma);

-- phien ban

drop table bh_xe_pb;
create table bh_xe_pb
    (ma_dvi varchar2(10),
    hang varchar2(20),
    hieu varchar2(20),
    ma varchar2(20), 
    ten nvarchar2(500),
    loai_xe varchar2(10),
    dong varchar2(10),
    ttai number,
    so_cn number,
    csuat number,
    dco varchar2(10),
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_xe_pb_u0 on bh_xe_pb(hang,hieu,ma);

-- Gia tham khao

drop table bh_xe_gtk;
create table bh_xe_gtk
    (ma_dvi varchar2(10),
    hang varchar2(20),
    hieu varchar2(20),
    pban varchar2(20), 
    nam_sx number,
    gia number,
    bien_do number,
    nsd varchar2(10));
CREATE INDEX bh_xe_gtk_i1 on bh_xe_gtk (hang,hieu,pban);

drop table bh_xe_mdsd;
create table bh_xe_mdsd
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_mdsd_u0 on bh_xe_mdsd(ma);

-- Ty le phi / tgian BH

drop table bh_xe_tltg;
create table bh_xe_tltg
    (nv varchar2(10),
 tu number,
 den number,
    tle number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create index bh_xe_tltg_i1 on bh_xe_tltg(nv);

drop table bh_xe_tltgb;
create table bh_xe_tltgb
(
  ma_dvi   varchar2(10 byte),
  tltg     number,
  tlph     number,
  ngay_bd  number,
  ngay_kt  number,
  nsd      varchar2(10 byte));
create unique index bh_xe_tltgb_i1 on bh_xe_tltgb (tltg);

/* Ma san pham */

drop table bh_xe_sp;
create table bh_xe_sp
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_sp_u0 on bh_xe_sp(ma);

drop table bh_xe_goi;
CREATE TABLE bh_xe_goi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_xe_goi_u0 on bh_xe_goi(ma);

/* Bieu phi */

drop table bh_xe_phi;
CREATE TABLE bh_xe_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),    -- G-GCN, H-Hdong
    nv_bh varchar2(10),    -- B-Bat buoc, T- Tu nguyen, V-Vat chat, M-Mo rong
 bh_tbo varchar2(1),    -- C-BH toan bo, K-chi BH vo xe, 
    loai_xe varchar2(10),
    nhom_xe varchar2(10),
    dong varchar2(10),
    dco varchar2(1),
    ttai number,
    so_cn number,
    tuoi number,
    gia number,
    md_sd varchar2(10),
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_xe_phi_u0 on bh_xe_phi(so_id);
CREATE INDEX bh_xe_phi_i1 on bh_xe_phi(nhom,nv_bh,ma_sp,cdich,goi);

drop table bh_xe_phi_dk;
CREATE TABLE bh_xe_phi_dk
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
create unique index bh_xe_phi_dk_u0 on bh_xe_phi_dk(so_id,bt);

drop table bh_xe_phi_lt;
CREATE TABLE bh_xe_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_xe_phi_lt_u0 on bh_xe_phi_lt(so_id,bt);

drop table bh_xe_phi_txt;
create table bh_xe_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_xe_phi_txt_u0 on bh_xe_phi_txt(so_id,loai);

drop table bh_xe_phi_temp;
create GLOBAL TEMPORARY table bh_xe_phi_temp
    (so_id number,
    ngay_bd number,
    ttai number,
    so_cn number,
    tuoi number,
    gia number);

drop table bh_xe_ktru;
CREATE TABLE bh_xe_ktru(
    muc number,
    pt number,
    ngay_kt number,
    nsd varchar2(20)
);
create unique index bh_xe_ktru_u0 on bh_xe_ktru(muc);

drop table bh_xe_ptu;
create table bh_xe_ptu(
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    dvi nvarchar2(20),
    ma_ct varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_xe_ptu_u0 on bh_xe_ptu(ma);
CREATE INDEX bh_xe_ptu_i1 on bh_xe_ptu(ma_ct);

drop table bh_xe_gia;
create table bh_xe_gia(
    maKey varchar2(100),
    hang varchar2(20),
    hieu varchar2(20),
    pban varchar2(20),
    doi number,
    ma varchar2(20),
    ten nvarchar2(500),
    Hptu number,
    Hlap number,
    Hgo number,
    Hson number,
    Hgia number,
    Nptu number,
    Nlap number,
    Ngo number,
    Nson number,
    Ngia number,
    duyet varchar2(20),
    ngay number,
    nsd varchar2(20),
 txt clob
);
create unique index bh_xe_gia_u0 on bh_xe_gia(maKey);

drop table bh_xe_giaL;
create table bh_xe_giaL(
    maKey varchar2(100),
    Hptu number,
    Hlap number,
    Hgo number,
    Hson number,
    Hgia number,
    Nptu number,
    Nlap number,
    Ngo number,
    Nson number,
    Ngia number,
    duyet varchar2(20),
    ngay number);
CREATE INDEX bh_xe_giaL_i1 on bh_xe_giaL(maKey,ngay);

drop table bh_xe_kvuc;
create table bh_xe_kvuc(
    ma varchar2(10),
    ten nvarchar2(500),
    Hptu number,
    Hlap number,
    Hgo number,
    Hson number,
    Hgia number,
    Nptu number,
    Nlap number,
    Ngo number,
    Nson number,
    Ngia number,
    duyet varchar2(20),
    ngay number,
    nsd varchar2(20)
);
create unique index bh_xe_kvuc_u0 on bh_xe_kvuc(ma);

drop table bh_xe_kvucL;
create table bh_xe_kvucL(
    ma varchar2(10),
    Hptu number,
    Hlap number,
    Hgo number,
    Hson number,
    Hgia number,
    Nptu number,
    Nlap number,
    Ngo number,
    Nson number,
    Ngia number,
    duyet varchar2(20),
    ngay number);
CREATE INDEX bh_xe_kvucL_i1 on bh_xe_kvucL(ma,ngay);