-- Chung loai

drop table bh_nongts_loai;
CREATE TABLE bh_nongts_loai
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_nongts_loai_u0 on bh_nongts_loai(ma);

-- Khu vuc

drop table bh_nongts_kvuc;
create table bh_nongts_kvuc
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_nongts_kvuc_u0 on bh_nongts_kvuc(ma);

-- Hình thức

drop table bh_nongts_hthuc;
create table bh_nongts_hthuc
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_nongts_hthuc_u0 on bh_nongts_hthuc(ma);

-- Goi

drop table bh_nongts_goi;
create table bh_nongts_goi
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_nongts_goi_u0 on bh_nongts_goi(ma);

-- Pham vi

drop table bh_nongts_pvi;
CREATE TABLE bh_nongts_pvi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    tc varchar2(1),    -- C-Chinh, D:Duy nhat, B-Bat buoc, M-Mo rong
    ten nvarchar2(500),
    ngay_kt number,
 nsd varchar2(10),
    txt clob
);
create unique index bh_nongts_pvi_u0 on bh_nongts_pvi(ma);

-- San pham

drop table bh_nongts_sp;
CREATE TABLE bh_nongts_sp
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_nongts_sp_u0 on bh_nongts_sp(ma);
create index bh_nongts_sp_i1 on bh_nongts_sp (ma_ct);

-- Ty le phi / tgian BH

drop table bh_nongts_tltg;
create table bh_nongts_tltg
    (ma_dvi varchar2(10),
    loai varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_nongts_tltg_i1 on bh_nongts_tltg(tltg);

-- Bieu phi

drop table bh_nongts_phi;
create table bh_nongts_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),           -- G-GCN,H-Hdong
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),  
    loai varchar2(10),      -- Chung loai
    kvuc varchar2(10),      -- Khu vuc
    hthuc varchar2(10),   -- Hinh thuc nuoi
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_nongts_phi_u0 on bh_nongts_phi(so_id);
CREATE INDEX bh_nongts_phi_i1 on bh_nongts_phi(nhom,ma_sp);

drop table bh_nongts_phi_dk;
CREATE TABLE bh_nongts_phi_dk
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
 nv varchar2(1),    -- C-Chinh, M-Mo rong
    ktru varchar2(1)         -- Khau tru theo pham vi
);
create unique index bh_nongts_phi_dk_u0 on bh_nongts_phi_dk(so_id,ma);

drop table bh_nongts_phiP_dk;
CREATE TABLE bh_nongts_phiP_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
 ten nvarchar2(500),
    pt number,
 ktru varchar2(100),
    tc varchar2(1)
);
create unique index bh_nongts_phip_dk_u0 on bh_nongts_phip_dk(so_id,ma);

drop table bh_nongts_phi_lt;
CREATE TABLE bh_nongts_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_nongts_phi_lt_u0 on bh_nongts_phi_lt(so_id,bt);

drop table bh_nongts_phi_txt;
create table bh_nongts_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_nongts_phi_txt_u0 on bh_nongts_phi_txt(so_id,loai);