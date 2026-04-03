/*** Tau, thuyen ***/

drop table bh_tau_nhom;
CREATE TABLE bh_tau_nhom
 (ma_dvi varchar2(10),
 ma varchar(10),
 ten nvarchar2(500),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_nhom_u0 on bh_tau_nhom(ma);

drop table bh_tau_loai;
CREATE TABLE bh_tau_loai
 (ma_dvi varchar2(10),
 ma varchar(20),
 ten nvarchar2(500),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_loai_u0 on bh_tau_loai(ma);

drop table bh_tau_vlieu;
CREATE TABLE bh_tau_vlieu
 (ma_dvi varchar2(10),
 ma varchar(10),
 ten nvarchar2(500),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_vlieu_u0 on bh_tau_vlieu(ma);

drop table bh_tau_cap;
CREATE TABLE bh_tau_cap
 (ma_dvi varchar2(10),
 ma varchar(10),
 ten nvarchar2(500),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_cap_u0 on bh_tau_cap(ma);

drop table bh_tau_hoi;
CREATE TABLE bh_tau_hoi
 (ma_dvi varchar2(10),
 ma varchar(20),
 ten nvarchar2(500),
 loai varchar2(1),    -- 
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_hoi_u0 on bh_tau_hoi(ma);

drop table bh_tau_dkc;
CREATE TABLE bh_tau_dkc
 (ma_dvi varchar2(10),
 ma varchar(20),
 ten nvarchar2(500),
    ma_sp varchar2(10),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_dkc_u0 on bh_tau_dkc(ma);

drop table bh_tau_sp;
CREATE TABLE bh_tau_sp
    (ma_dvi varchar2(10),
    ma varchar(10),
    ten nvarchar2(500),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_tau_sp_u0 on bh_tau_sp(ma);

drop table bh_tau_mdsd;
CREATE TABLE bh_tau_mdsd
 (ma_dvi varchar2(10),
 ma varchar(10),
 ten nvarchar2(500),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_mdsd_u0 on bh_tau_mdsd(ma);

drop table bh_tau_nntt;
create table bh_tau_nntt
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_tau_nntt_u0 on bh_tau_nntt(ma);
create index bh_tau_nntt_i1 on bh_tau_nntt (ma_ct);

-- Ty le phi / tgian BH

drop table bh_tau_tltg;
create table bh_tau_tltg
    (ma_dvi varchar2(10),
    tltg number,
    tlph number,
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_tau_tltg_i1 on bh_tau_tltg(tltg);

drop table bh_tau_pvi;
CREATE TABLE bh_tau_pvi
 (ma_dvi varchar2(10),
 ma varchar(10),
 ten nvarchar2(500),
 ngay_kt number,
 nsd varchar2(10),
 txt clob
);
create unique index bh_tau_pvi_u0 on bh_tau_pvi(ma);

drop table bh_tau_dsach;
CREATE TABLE bh_tau_dsach
    (ma_dvi varchar2(10),
    ma varchar2(10) not null,
    ten nvarchar2(500),
    tenc nvarchar2(500),
    so_dk varchar2(20),
    loai varchar2(10),
    cap varchar2(10),
    ttai number,
    csuat number,
    dtich number,
    so_cn number,
    gia number,
    tvo number,
    may number,
    tbi number,
    nam_sx number,
    hcai varchar2(1),
    pvi varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_tau_dsach_u0 on bh_tau_dsach(ma);

-- Bieu phi --

drop table bh_tau_phi;
CREATE TABLE bh_tau_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(10),
    loai varchar2(10),
    cap varchar2(10),
    vlieu varchar2(10),
    ttai number,
    so_cn number,
    dtich number,
    csuat number,
    gia number,
    tuoi number,
    ma_sp varchar2(10),
    dkien varchar2(10),             -- Dieu kien: A,B,K
    md_sd varchar2(10),             -- MDSD: H-Cho hang,N-Cho nguoi,C-Ca hai
    nv_bh varchar2(10),             -- V-Vat chat, T-trach nhiem, N-nguoi, M-Bo sung
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_tau_phi_u0 on bh_tau_phi(so_id);
CREATE INDEX bh_tau_phi_i1 on bh_tau_phi(nv_bh,nhom,loai,cap,vlieu,ma_sp);

drop table bh_tau_phi_dk;
CREATE TABLE bh_tau_phi_dk
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
    gvu varchar2(100),
    lh_bh varchar2(1)
);
create unique index bh_tau_phi_dk_u0 on bh_tau_phi_dk(so_id,bt);
CREATE INDEX bh_tau_phi_dk_i1 on bh_tau_phi_dk(so_id);

drop table bh_tau_phi_lt;
CREATE TABLE bh_tau_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
 ma_dk varchar2(10),
 ten nvarchar2(500)
);
create unique index bh_tau_phi_lt_u0 on bh_tau_phi_lt(so_id,bt);

drop table bh_tau_phi_txt;
create table bh_tau_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_tau_phi_txt_u0 on bh_tau_phi_txt(so_id,loai);

drop table bh_tau_pphcai;
CREATE TABLE bh_tau_pphcai
    (ma_dvi varchar2(10),
    nhom varchar2(10),
    loai varchar2(10),
    nv_bh varchar2(1),             -- V-Vat chat, T-trach nhiem, N-nguoi, M-Bo sung
 pt number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_tau_pphcai_i1 on bh_tau_pphcai(nhom,loai,nv_bh);

drop table bh_tau_pptuoi;
CREATE TABLE bh_tau_pptuoi
    (ma_dvi varchar2(10),
    nhom varchar2(10),
    loai varchar2(10),
    nv_bh varchar2(1),             -- V-Vat chat, T-trach nhiem, N-nguoi, M-Bo sung
 tuoi number,
 pt number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_tau_pptuoi_i1 on bh_tau_pptuoi(nhom,loai,nv_bh,tuoi);

drop table bh_tau_ppvlieu;
CREATE TABLE bh_tau_ppvlieu
    (ma_dvi varchar2(10),
    nhom varchar2(10),
    loai varchar2(10),
    nv_bh varchar2(1),             -- V-Vat chat, T-trach nhiem, N-nguoi, M-Bo sung
 vlieu varchar2(10),
 pt number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_tau_ppvlieu_i1 on bh_tau_ppvlieu(nhom,loai,nv_bh,vlieu);

drop table bh_tau_ppvtoc;
CREATE TABLE bh_tau_ppvtoc
    (ma_dvi varchar2(10),
    nhom varchar2(10),
    loai varchar2(10),
    nv_bh varchar2(1),             -- V-Vat chat, T-trach nhiem, N-nguoi, M-Bo sung
 vtoc number,
 pt number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_tau_ppvtoc_i1 on bh_tau_ppvtoc(nhom,loai,nv_bh,vtoc);

drop table bh_tau_ppcap;
CREATE TABLE bh_tau_ppcap
    (ma_dvi varchar2(10),
    nhom varchar2(10),
    loai varchar2(10),
    nv_bh varchar2(1),             -- V-Vat chat, T-trach nhiem, N-nguoi, M-Bo sung
 cap varchar2(10),
 pt number,
    ngay_kt number,
    nsd varchar2(10));
create unique index bh_tau_ppcap_i1 on bh_tau_ppcap(nhom,loai,nv_bh,cap);