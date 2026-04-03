-- DONG TAU --
-- quy mô xưởng --

drop table bh_dtau_qmo;
CREATE TABLE bh_dtau_qmo
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_qmo_u0 on bh_dtau_qmo(ma);

-- Nơi thi công --

drop table bh_dtau_ntc;
CREATE TABLE bh_dtau_ntc
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_ntc_u0 on bh_dtau_ntc(ma);

-- Vật liệu dàn đỡ --

drop table bh_dtau_vlieuda;
CREATE TABLE bh_dtau_vlieuda
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_vlieuda_u0 on bh_dtau_vlieuda(ma);

-- Loại tàu --

drop table bh_dtau_loai;
CREATE TABLE bh_dtau_loai
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_loai_u0 on bh_dtau_loai(ma);

-- Vật liệu đóng tàu --

drop table bh_dtau_vlieudo;
CREATE TABLE bh_dtau_vlieudo
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_vlieudo_u0 on bh_dtau_vlieudo(ma);

-- Cách hạ thủy --

drop table bh_dtau_hthuy;
CREATE TABLE bh_dtau_hthuy
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_hthuy_u0 on bh_dtau_hthuy(ma);

-- Cấp --

drop table bh_dtau_cap;
CREATE TABLE bh_dtau_cap
    (ma_dvi varchar2(10),
    ma varchar2(10),
    ten nvarchar2(200),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_dtau_cap_u0 on bh_dtau_cap(ma);

-- Bieu phi --

drop table bh_dtau_phi;
CREATE TABLE bh_dtau_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(10),
    qmo varchar2(10),
    ntc varchar2(10),
    vlieuda varchar2(10),           -- vat lieu dan do 
    loai varchar2(10),
    vlieudo varchar2(10),           -- vat lieu dong tau
    hthuy varchar2(10),                   
    dtich number,
    ttai number,
    kcach number,
    tgian number,
    nv_bh varchar2(10),             -- V-Vat chat, T-TNDS, N-tan nan LD, K-TN khac
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_dtau_phi_u0 on bh_dtau_phi(so_id);
CREATE INDEX bh_dtau_phi_i1 on bh_dtau_phi(nv_bh,nhom,loai,vlieudo,hthuy);

drop table bh_dtau_phi_dk;
CREATE TABLE bh_dtau_phi_dk
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
    lkeM varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    ma_dk varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    cap number,
    lh_bh varchar2(1)
);
create unique index bh_dtau_phi_dk_u0 on bh_dtau_phi_dk(so_id,bt);
CREATE INDEX bh_dtau_phi_dk_i1 on bh_dtau_phi_dk(so_id);

drop table bh_dtau_phi_lt;
CREATE TABLE bh_dtau_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_dtau_phi_lt_u0 on bh_dtau_phi_lt(so_id,bt);

drop table bh_dtau_phi_txt;
create table bh_dtau_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_dtau_phi_txt_u0 on bh_dtau_phi_txt(so_id,loai);