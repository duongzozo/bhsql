-- HON HOP--
-- ma nguyen nhan ton that--

drop table bh_hop_nntt;
create table bh_hop_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_hop_nntt_u0 on bh_hop_nntt(ma);
create index bh_hop_nntt_i1 on bh_hop_nntt (ma_ct);

-- Ty le phi ngan han

drop table bh_hop_tltg;
create table bh_hop_tltg
    (ma_dvi varchar2(10),
 tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_hop_tltg_i1 on bh_hop_tltg(tltg);

/* Ma san pham */

drop table bh_hop_sp;
create table bh_hop_sp
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
create unique index bh_hop_sp_u0 on bh_hop_sp(ma);
create index bh_hop_sp_i1 on bh_hop_sp (ma_ct);

/* Ma goi */

drop table bh_hop_goi;
CREATE TABLE bh_hop_goi
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_hop_goi_u0 on bh_hop_goi(ma);

/* Bieu phi */

drop table bh_hop_phi;
create table bh_hop_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    ma_sp varchar2(10),
    cdich varchar2(10),
    goi varchar2(10),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_hop_phi_u0 on bh_hop_phi(so_id);
CREATE INDEX bh_hop_phi_i1 on bh_hop_phi(nhom,ma_sp,cdich,goi);

drop table bh_hop_phi_dk;
CREATE TABLE bh_hop_phi_dk
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
    lh_nv varchar2(10),
    t_suat number,
    cap number,                 
    lh_bh varchar2(5),   -- C-Chinh, M-Mo rong
    ktru varchar2(1)
);
create unique index bh_hop_phi_dk_u0 on bh_hop_phi_dk(so_id,bt);

drop table bh_hop_phi_lt;
CREATE TABLE bh_hop_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
    ma_dk varchar2(10),
    ten nvarchar2(500)
);
create unique index bh_hop_phi_lt_u0 on bh_hop_phi_lt(so_id,bt);

drop table bh_hop_phi_txt;
create table bh_hop_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(10),
    txt clob
);
create unique index bh_hop_phi_txt_u0 on bh_hop_phi_txt(so_id,loai);