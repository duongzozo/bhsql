--Bang cho chuyen

drop table bh_ttA;
CREATE TABLE bh_ttA
    (so_id_tt number,               -- So ID thanh toan
    ma_dvi varchar2(10),            -- Ma don vi, So Id goc phat sinh thanh toan
    so_id number,
    ngay_ht number,
    l_ct varchar2(10),              -- BT_TT: Tra boi thuong, HH_DL: Tra hoa hong dai ly
    so_hd varchar2(30),
    gcn varchar2(30),
    so_hs varchar2(30),
    ten nvarchar2(500),
    ngHuong nvarchar2(500),         -- BT_TT:Ten nguoi huong, HH_DL: ten dai ly
    ma_nh varchar2(10),
    so_tk varchar2(30),
    ten_tk varchar2(500),
    tien number,
    nd nvarchar2(500),
    dtac varchar2(30),
    ttrang varchar2(1),             -- C:Cho duyet, D-Doi chuyen, d-Dang chuyen, B-Huy bo
    nsd varchar2(10),               -- Ke toan duyet. Neu tu dong nsd=' '
    so_dc varchar2(30)
);
create unique index bh_tta_u0 on bh_tta(so_id_tt);
create index bh_ttA_i1 on bh_ttA (ma_dvi,so_id);
create index bh_ttA_i2 on bh_ttA (ma_dvi,ngay_ht);
create index bh_ttA_i3 on bh_ttA (so_dc);

--Bang da chuyen xong

drop table bh_ttAx;
CREATE TABLE bh_ttAx
    (so_id_tt number,
    ma_dvi   varchar2(10),
    so_id    number,
    ngay_ht  number,
    l_ct     varchar2(10),
    so_hd    varchar2(30),
    gcn      varchar2(30),
    so_hs    varchar2(30),
    ten      nvarchar2(500),
    nghuong  nvarchar2(500),
    ma_nh    varchar2(10),
    ma_tk    varchar2(30),
    ten_tk   varchar2(500),
    tien     number,
    nd       nvarchar2(500),
    dtac     varchar2(30),
    ttrang   varchar2(1),
    nsd      varchar2(10),
    ngay_ch  number,
    so_dc    varchar2(30)
);
create unique index bh_ttax_u0 on bh_ttax(so_id_tt);
create index bh_ttAx_i1 on bh_ttAx (ma_dvi,so_id);
create index bh_ttAx_i2 on bh_ttAx (ma_dvi,ngay_ht);

--Bang loi

drop table bh_ttA_loi;
CREATE TABLE bh_ttA_loi
    (so_id_tt number,
    loi varchar2(500),
    ngay date);