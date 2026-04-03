-- Nguyen nhan ton that

drop table bh_pkt_nntt;
create table bh_pkt_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_pkt_nntt_u0 on bh_pkt_nntt(ma);
create index bh_pkt_nntt_i1 on bh_pkt_nntt (ma_ct);

-- Ma muc rui ro

drop table bh_pkt_mrr;
create table bh_pkt_mrr
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_pkt_mrr_u0 on bh_pkt_mrr(ma);

-- Dieu kien thi cong

drop table bh_pkt_ma_dktc;
create table bh_pkt_ma_dktc
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_pkt_ma_dktc_u0 on bh_pkt_ma_dktc(ma);
  
-- Dieu kien dia ly

drop table bh_pkt_ma_dkdl;
create table bh_pkt_ma_dkdl
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_pkt_ma_dkdl_u0 on bh_pkt_ma_dkdl(ma);

-- Nhom may thiet bi

drop table bh_pkt_ma_ntb;
create table bh_pkt_ma_ntb
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  tc varchar2(1),
  ma_ct varchar2(20),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_pkt_ma_ntb_u0 on bh_pkt_ma_ntb(ma);
create index bh_pkt_ma_ntb_i1 on bh_pkt_ma_ntb (ma_ct);

-- Cap cong trinh

drop table bh_pkt_ma_cct;
create table bh_pkt_ma_cct
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_pkt_ma_cct_u0 on bh_pkt_ma_cct(ma);

-- Nhom cong trinh

drop table bh_pkt_ma_nct;
create table bh_pkt_ma_nct
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  tc varchar2(1),
  ma_ct varchar2(10),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_pkt_ma_nct_u0 on bh_pkt_ma_nct(ma);
create index bh_pkt_ma_nct_i1 on bh_pkt_ma_nct (ma_ct);

-- Ty le phi / tgian BH

drop table bh_pkt_tltg;
create table bh_pkt_tltg
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_pkt_tltg_i1 on bh_pkt_tltg(tltg);

-- San pham

drop table bh_pkt_ma_sp;
CREATE TABLE bh_pkt_ma_sp
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_pkt_ma_sp_u0 on bh_pkt_ma_sp(ma);
create index bh_pkt_ma_sp_i1 on bh_pkt_ma_sp (ma_ct);

drop table bh_pkt_pvi;
CREATE TABLE bh_pkt_pvi
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
create unique index bh_pkt_pvi_u0 on bh_pkt_pvi(ma);

drop table bh_pkt_lbh;
CREATE TABLE bh_pkt_lbh
    (ma_dvi varchar2(10),
    ma varchar2(10),
    loai varchar2(5),               -- TS,TB,KH
    ten nvarchar2(500),
 tc varchar2(1),
    ma_ct varchar2(10),
    ma_dk varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_pkt_lbh_u0 on bh_pkt_lbh(ma);
create index bh_pkt_lbh_i1 on bh_pkt_lbh(ma_ct);

-- Bieu phi

drop table bh_pkt_phi;
create table bh_pkt_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),           -- G-GCN,H-Hdong
    ma_sp varchar2(10),
    ma_cct varchar2(10),  -- Cap ctrinh
    ma_nct varchar2(10),  -- Nhom ctrinh
    ma_dkdl varchar2(10),  -- Dieu kien dia ly
    ma_dktc varchar2(10),  -- Dieu kien thi cong
    rru varchar2(1),   -- Rro uot: C-Co, K-Khong
    ma_ntb varchar2(10),  -- Nhom tbi
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_pkt_phi_u0 on bh_pkt_phi(so_id);
CREATE INDEX bh_pkt_phi_i1 on bh_pkt_phi(nhom,ma_sp);

drop table bh_pkt_phi_dk;
CREATE TABLE bh_pkt_phi_dk
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
    lbh varchar2(5),   -- TS,TB,KH
 nv varchar2(1),    -- C-Chinh, M-Mo rong
    ktru varchar2(1)         -- Khau tru theo pham vi
);
create unique index bh_pkt_phi_dk_u0 on bh_pkt_phi_dk(so_id,ma);

drop table bh_pkt_phiP_dk;
CREATE TABLE bh_pkt_phiP_dk
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
create unique index bh_pkt_phip_dk_u0 on bh_pkt_phip_dk(so_id,ma);

drop table bh_pkt_phi_lt;
CREATE TABLE bh_pkt_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_pkt_phi_lt_u0 on bh_pkt_phi_lt(so_id,bt);

drop table bh_pkt_phi_txt;
create table bh_pkt_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_pkt_phi_txt_u0 on bh_pkt_phi_txt(so_id,loai);

drop table bh_pkt_sp;
create table bh_pkt_sp
(
  ma_dvi  varchar2(10),
  ma      varchar2(10) not null,
  ten     nvarchar2(500),
  tc      varchar2(1),
  ma_ct   varchar2(10),
  ngay_kt number,
  nsd     varchar2(10),
  txt     clob
);
CREATE INDEX bh_pkt_sp_i1 on bh_pkt_sp (ma_ct);