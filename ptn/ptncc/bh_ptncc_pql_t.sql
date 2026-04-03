--BO MA--
/* Ma san pham */

drop table bh_ptncc_sp;
create table bh_ptncc_sp
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
create unique index bh_ptncc_sp_u0 on bh_ptncc_sp(ma);
create index bh_ptncc_sp_i1 on bh_ptncc_sp (ma_ct);

/* Bieu phi */

drop table bh_ptncc_phi;
create table bh_ptncc_phi
    (ma_dvi varchar2(10),
    so_id number,
    nhom varchar2(1),
    ma_sp varchar2(10),
    lvuc varchar2(10),
    cdich varchar2(10),
 tlph number,
    ghan varchar2(1),
    ngay_bd number,
    ngay_kt number,
    nsd varchar2(10)
);
create unique index bh_ptncc_phi_u0 on bh_ptncc_phi(so_id);
CREATE INDEX bh_ptncc_phi_i1 on bh_ptncc_phi(nhom,ma_sp,lvuc,cdich,ghan);

drop table bh_ptncc_phi_dk;
create table bh_ptncc_phi_dk
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma varchar2(10),
    ten nvarchar2(500),
    tc varchar2(1),
    ma_ct varchar2(10),
    kieu varchar2(1),
    tien number,
    pt number,
    phi number,
    lkeM varchar2(1),
    lkeP varchar2(1),
    lkeB varchar2(1),
    luy varchar2(1),
    ktru varchar2(1),
    ma_dk varchar2(10),
    ma_dkC varchar2(10),
    lh_nv varchar2(10),
    t_suat number,
    cap number, 
    lh_bh varchar2(1)
);
create unique index bh_ptncc_phi_dk_u0 on bh_ptncc_phi_dk(so_id,bt);
-- nam them

drop table bh_ptncc_phi_lt;
create table bh_ptncc_phi_lt
    (ma_dvi varchar2(10),
    so_id number,
    bt number,
    ma_lt varchar2(10),
    ten varchar2(500)
);
create unique index bh_ptncc_phi_lt_u0 on bh_ptncc_phi_lt(so_id,bt);

drop table bh_ptncc_phi_txt;
create table bh_ptncc_phi_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob
);
create unique index bh_ptncc_phi_txt_u0 on bh_ptncc_phi_txt(so_id,loai);