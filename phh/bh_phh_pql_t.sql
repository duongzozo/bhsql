-- Dieu khoan them

drop table bh_phh_dkth;
create table bh_phh_dkth
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(400),
 lh_nv varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_phh_dkth_u0 on bh_phh_dkth(ma);

-- Nguyen nhan ton that

drop table bh_phh_nntt;
create table bh_phh_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_phh_nntt_u0 on bh_phh_nntt(ma);
create index bh_phh_nntt_i1 on bh_phh_nntt (ma_ct);

-- Ma muc rui ro

drop table bh_phh_mrr;
create table bh_phh_mrr
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_phh_mrr_u0 on bh_phh_mrr(ma);

-- Ma nhom

drop table bh_phh_nhom;
create table bh_phh_nhom
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
 mrr varchar2(10),
 ma_ta varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_phh_nhom_u0 on bh_phh_nhom(ma);
create index bh_phh_nhom_i1 on bh_phh_nhom (ma_ct);

-- Ma doi tuong

drop table bh_phh_dtuong;
create table bh_phh_dtuong
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(20),
 nhom varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_phh_dtuong_u0 on bh_phh_dtuong(ma);
create index bh_phh_dtuong_i1 on bh_phh_dtuong (ma_ct);

-- Ty le phi / tgian BH

drop table bh_phh_tltg;
create table bh_phh_tltg
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_phh_tltg_i1 on bh_phh_tltg(tltg);

-- Ma san pham

drop table bh_phh_sp;
CREATE TABLE bh_phh_sp
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
create unique index bh_phh_sp_u0 on bh_phh_sp(ma);
create index bh_phh_sp_i1 on bh_phh_sp (ma_ct);

drop table bh_phh_sp_dl;
CREATE TABLE bh_phh_sp_dl
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ma_dl varchar2(20));
create index bh_phh_sp_dl_i1 on bh_phh_sp_dl(ma);

drop table bh_phh_goi;
CREATE TABLE bh_phh_goi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_phh_goi_u0 on bh_phh_goi(ma);

drop table bh_phh_pvi;
CREATE TABLE bh_phh_pvi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    tc varchar2(1),    -- C-Chinh, D:Duy nhat, B-Bat buoc, M-Mo rong
    ten nvarchar2(500),
    loai varchar2(1),
    ma_ct varchar2(10),
    ma_dk varchar2(10),
    ma_qtac varchar2(10),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_phh_pvi_u0 on bh_phh_pvi(ma);

drop table bh_phh_lbh;
CREATE TABLE bh_phh_lbh
    (ma_dvi varchar2(10),
    ma varchar2(10),
    loai varchar2(5),               -- TS,TB,HH,KH
    ten nvarchar2(500),
 tc varchar2(1),
    ma_ct varchar2(10),
    ma_dk varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_phh_lbh_u0 on bh_phh_lbh(ma);
create index bh_phh_lbh_i1 on bh_phh_lbh(ma_ct);

-- Bieu phi loai bao hiem

drop table bh_phh_phi;
CREATE TABLE bh_phh_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),           -- G-GCN,H-Hdong
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
    mrr varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_phh_phi_u0 on bh_phh_phi(so_id);
CREATE unique INDEX bh_phh_phi_i1 on bh_phh_phi(nhom,ma_sp,cdich,goi,mrr);

drop table bh_phh_phi_dk;
CREATE TABLE bh_phh_phi_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),    -- C-Chi tiet,T-tong
    ma_ct varchar2(10),         -- Ma cap tren
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
    lbh varchar2(5),   -- TS,TB,HH,KH
 nv varchar2(1),    -- C-Chinh, M-Mo rong
 ktru varchar2(1)   -- Khau tru theo pham vi
);
create unique index bh_phh_phi_dk_u0 on bh_phh_phi_dk(so_id,ma);

drop table bh_phh_phiP_dk;
CREATE TABLE bh_phh_phiP_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
 ten nvarchar2(500),
    ptTS number,
    ptKH number,
    ktru varchar2(100),
    tc varchar2(1),    
    loai varchar2(1),
    ma_ct varchar2(10)
);
create unique index bh_phh_phip_dk_u0 on bh_phh_phip_dk(so_id,ma);

drop table bh_phh_phi_lt;
CREATE TABLE bh_phh_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_phh_phi_lt_u0 on bh_phh_phi_lt(so_id,bt);

drop table bh_phh_phi_txt;
create table bh_phh_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_phh_phi_txt_u0 on bh_phh_phi_txt(so_id,loai);