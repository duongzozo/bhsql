-- Nguyen nhan ton that

drop table bh_2b_vach;
create table bh_2b_vach
 (nv varchar2(20),
    stt number);

drop table bh_2b_nntt;
create table bh_2b_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_nntt_u0 on bh_2b_nntt(ma);
create index bh_2b_nntt_i1 on bh_2b_nntt (ma_ct);

/* Ma loai xe */

drop table bh_2b_loai;
create table bh_2b_loai
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_loai_u0 on bh_2b_loai(ma);

drop table bh_2b_nhom;
create table bh_2b_nhom
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_nhom_u0 on bh_2b_nhom(ma);

drop table bh_2b_dong;
create table bh_2b_dong
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_dong_u0 on bh_2b_dong(ma);

drop table bh_2b_hang;
create table bh_2b_hang
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_2b_hang_u0 on bh_2b_hang(ma);

drop table bh_2b_hieu;
create table bh_2b_hieu
    (ma_dvi varchar2(10),
    hang varchar2(20),
    ma varchar2(20),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_2b_hieu_u0 on bh_2b_hieu(hang,ma);

-- phien ban

drop table bh_2b_pb;
create table bh_2b_pb
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
create unique index bh_2b_pb_u0 on bh_2b_pb(hang,hieu,ma);

-- Gia tham khao

drop table bh_2b_gtk;
create table bh_2b_gtk
    (ma_dvi varchar2(10),
    hang varchar2(20),
    hieu varchar2(20),
    pban varchar2(20), 
    nam_sx number,
    gia number,
    bien_do number,
    nsd varchar2(10));
CREATE INDEX bh_2b_gtk_i1 on bh_2b_gtk (hang,hieu,pban);

drop table bh_2b_mdsd;
create table bh_2b_mdsd
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_mdsd_u0 on bh_2b_mdsd(ma);

-- Ty le phi / tgian BH

drop table bh_2b_tltg;
create table bh_2b_tltg
    (nv varchar2(10),
 tu number,
 den number,
    tle number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create index bh_2b_tltg_i1 on bh_2b_tltg(nv);

/* Ma san pham */

drop table bh_2b_sp;
create table bh_2b_sp
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_sp_u0 on bh_2b_sp(ma);

drop table bh_2b_goi;
CREATE TABLE bh_2b_goi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_2b_goi_u0 on bh_2b_goi(ma);

/* Bieu phi */

drop table bh_2b_phi;
CREATE TABLE bh_2b_phi
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
create unique index bh_2b_phi_u0 on bh_2b_phi(so_id);
CREATE INDEX bh_2b_phi_i1 on bh_2b_phi(nhom,nv_bh,ma_sp,cdich,goi);

drop table bh_2b_phi_dk;
CREATE TABLE bh_2b_phi_dk
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
create unique index bh_2b_phi_dk_u0 on bh_2b_phi_dk(so_id,bt);

drop table bh_2b_phi_lt;
CREATE TABLE bh_2b_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_2b_phi_lt_u0 on bh_2b_phi_lt(so_id,bt);

drop table bh_2b_phi_txt;
create table bh_2b_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_2b_phi_txt_u0 on bh_2b_phi_txt(so_id,loai);

drop table bh_2b_phi_temp;
create GLOBAL TEMPORARY table bh_2b_phi_temp
    (so_id number,
    ngay_bd number,
    ttai number,
    so_cn number,
    tuoi number,
    gia number);

drop table bh_2b_ktru;
CREATE TABLE bh_2b_ktru(
    muc number,
    pt number,
    ngay_kt number,
    nsd varchar2(20)
);
create unique index bh_2b_ktru_u0 on bh_2b_ktru(muc);

drop table bh_2b_ptu;
create table bh_2b_ptu(
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    dvi nvarchar2(20),
    ma_ct varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_2b_ptu_u0 on bh_2b_ptu(ma);
CREATE INDEX bh_2b_ptu_i1 on bh_2b_ptu(ma_ct);

drop table bh_2b_gia;
create table bh_2b_gia(
    maKey varchar2(100),
    hang varchar2(20),
    hieu varchar2(20),
    dong varchar2(20),
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
create unique index bh_2b_gia_u0 on bh_2b_gia(maKey);

drop table bh_2b_giaL;
create table bh_2b_giaL(
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
CREATE INDEX bh_2b_giaL_i1 on bh_2b_giaL(maKey,ngay);

drop table bh_2b_kvuc;
create table bh_2b_kvuc(
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
create unique index bh_2b_kvuc_u0 on bh_2b_kvuc(ma);

drop table bh_2b_kvucL;
create table bh_2b_kvucL(
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
CREATE INDEX bh_2b_kvucL_i1 on bh_2b_kvucL(ma,ngay);

-- Ty le phi / tgian BH

drop table bh_2b_tltgB;
create table bh_2b_tltgB
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_2b_tltgB_i1 on bh_2b_tltgB(tltg);