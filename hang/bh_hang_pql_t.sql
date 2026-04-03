-- ma nguyen nhan ton that--

drop table bh_hang_nntt;
create table bh_hang_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_hang_nntt_u0 on bh_hang_nntt(ma);
create index bh_hang_nntt_i1 on bh_hang_nntt (ma_ct);

-- Ty le phi / tgian BH

drop table bh_hang_tltg;
create table bh_hang_tltg
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_hang_tltg_i1 on bh_hang_tltg(tltg);


--Ma phuong thuc van chuyen

drop table bh_hang_pt;
CREATE TABLE bh_hang_pt
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(500),
    tai varchar2(1),   -- Co xu ly tai:C,K
    nsd varchar2(10),
    txt clob
);
create unique index bh_hang_pt_u0 on bh_hang_pt(ma);

-- Nhom hang

drop table bh_hang_nhom;
CREATE TABLE bh_hang_nhom
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  phi number,
  uoc number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_hang_nhom_u0 on bh_hang_nhom(ma);

--Ma loai hang(xuat - nhap -noi dia)

drop table bh_hang_loai;
CREATE TABLE bh_hang_loai
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  ma_ct varchar2(10),
  tc varchar2(1),
  mrr varchar2(10),
  ngay_bd number,
  ngay_kt number,
  nsd varchar2(10),
  txt clob
);
create unique index bh_hang_loai_u0 on bh_hang_loai(ma);
create index bh_hang_loai_i1 on bh_hang_loai (ma_ct);

-- Ma phuong thuc dong goi

drop table bh_hang_dgoi;
create table bh_hang_dgoi
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  mrr varchar2(10),
  nsd varchar2(10),
  txt clob
);
create unique index bh_hang_dgoi_u0 on bh_hang_dgoi(ma);

--Ma Cang

drop table bh_hang_cang;
create table bh_hang_cang
  (ma_dvi varchar2(10),
  ma varchar2(10),
  ten nvarchar2(500),
  nuoc varchar2(10),
  nsd varchar2(10),
  txt clob
);
create unique index bh_hang_cang_u0 on bh_hang_cang(ma);
CREATE INDEX bh_hang_cang_i1 on bh_hang_cang(nuoc,ma);

-- Ma phuong phap tinh

drop table bh_hang_pp;
create table bh_hang_pp
  (ma_dvi varchar2(10),
  ma varchar2(10), -- MA PHAI DUNG 100/110/100CIF/110CIF
  ten nvarchar2(500),
  nsd varchar2(10),
  txt clob
);
create unique index bh_hang_pp_u0 on bh_hang_pp(ma);

-- dieu kien giao hang

drop table bh_hang_dkgh;
create table bh_hang_dkgh
  (ma_dvi varchar2(10),
  ma varchar(10),
  ten nvarchar2(500),
  nsd varchar2(10),
  txt clob
);
create unique index bh_hang_dkgh_u0 on bh_hang_dkgh(ma);

-- san pham

drop table bh_hang_sp;
create table bh_hang_sp 
  (ma_dvi varchar2(10), 
  ma varchar2(10), 
  ten nvarchar2(200), 
  tc varchar2(1), 
  ma_ct varchar2(20), 
  ngay_kt number, 
  nsd varchar2(20), 
  txt clob
);
create unique index bh_hang_sp_u0 on bh_hang_sp(ma);

-- danh muc kiem soat

drop table bh_hang_ks;
create table bh_hang_ks(
  ma_dvi varchar2(10),
  so_id number,
  pt varchar2(10),
  ma_qtac varchar2(10),
  loai varchar2(10),
  dgoi varchar2(10),
  nsd varchar2(10),
  ngay_nh date
);
create unique index bh_hang_ks_u0 on bh_hang_ks(so_id);
CREATE INDEX bh_hang_ks_i1 on bh_hang_ks(pt,ma_qtac,loai,dgoi);

-- Bieu phi

drop table bh_hang_phi;
create table bh_hang_phi
    (ma_dvi varchar2(10),
    so_id number,
    pt varchar2(10),      -- G-GCN,H-Hdong
    nhang varchar2(10),
    qtac varchar2(10),
    khoang_cach number, -- tu bn toi bn
    thoi_gian number, -- co the tu bn toi bn
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_hang_phi_u0 on bh_hang_phi(so_id);
create unique index bh_hang_phi_i1 on bh_hang_phi(pt,nhang,qtac);
-- danh sach hang

drop table bh_hang_phi_ds;
create table bh_hang_phi_ds
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    dgoi varchar2(10),    
    pt number
);
create unique index bh_hang_phi_ds_u0 on bh_hang_phi_ds(so_id,bt);
-- Phi dieu khoan

drop table bh_hang_phi_dk;
create table bh_hang_phi_dk
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
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    ma_dk varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    cap number,                
    lh_bh varchar2(5)-- C-Chinh M-Mo rong

);
create unique index bh_hang_phi_dk_u0 on bh_hang_phi_dk(so_id,bt);

-- Phi loai tru

drop table bh_hang_phi_lt;
create table bh_hang_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_dk varchar2(10), -- nam them
    ma_lt varchar2(10),
    ten nvarchar2(500)
);
create unique index bh_hang_phi_lt_u0 on bh_hang_phi_lt(so_id,bt);

--Phi txt

drop table bh_hang_phi_txt;
create table bh_hang_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_hang_phi_txt_u0 on bh_hang_phi_txt(so_id,loai);