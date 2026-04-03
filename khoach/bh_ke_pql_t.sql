drop table bh_ke_khtso;
CREATE TABLE bh_ke_khtso
 (ma_dvi varchar2(10),
 nv varchar2(10),
 nsd varchar2(10),
    txt clob
);
create unique index bh_ke_khtso_u0 on bh_ke_khtso(nv);

drop table bh_ke_khcti;
create table bh_ke_khcti
    (ma_dvi varchar2(20),
    so_id number,
    nv varchar2(10),
    ma varchar2(10),            -- Ma nhom
    ngay_hl number,
    nsd varchar2(10)
);
create unique index bh_ke_khcti_u0 on bh_ke_khcti(so_id);
create unique index bh_ke_khcti_i1 on bh_ke_khcti (nv,ma,ngay_hl);

drop table bh_ke_khcti_ct;
create table bh_ke_khcti_ct
    (so_id number,
    ma varchar2(10),            -- Ma chi tieu
    ten nvarchar2(500),
    loai varchar2(5),
    tu_dk varchar2(5),
    tu_nd varchar2(100),
    den_dk varchar2(5),
    den_nd varchar2(100),
    bt number);
create index bh_ke_khcti_ct_i1 on bh_ke_khcti_ct(so_id);

drop table bh_ke_khcti_txt;
create table bh_ke_khcti_txt
    (so_id number,
    loai varchar2(10),
    txt clob);
create index bh_ke_khcti_txt_i1 on bh_ke_khcti_txt(so_id);

-- Ma ke hoach

drop table bh_ke_thu_ma;
create table bh_ke_thu_ma
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    loai varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ke_thu_ma_u0 on bh_ke_thu_ma(ma);
create index bh_ke_thu_ma_i1 on bh_ke_thu_ma (ma_ct);

drop table bh_ke_thu_dt;
create table bh_ke_thu_dt
    (ma_dvi varchar2(20),
    nv varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ke_thu_dt_u0 on bh_ke_thu_dt(nv,ma);

drop table bh_ke_thu_tso;
CREATE TABLE bh_ke_thu_tso
    (ma_dvi varchar2(10),
    nv varchar2(10),
    nsd varchar2(10),
    txt clob
);
create unique index bh_ke_thu_tso_u0 on bh_ke_thu_tso(nv);

drop table bh_ke_thu_cti;
create table bh_ke_thu_cti
    (ma_dvi varchar2(20),
    so_id number,
    nv varchar2(10),
    ma varchar2(20),            -- Ma nhom
    ngay_hl number,
    nsd varchar2(10)
);
create unique index bh_ke_thu_cti_u0 on bh_ke_thu_cti(so_id);
create unique index bh_ke_thu_cti_i1 on bh_ke_thu_cti (nv,ma,ngay_hl);

drop table bh_ke_thu_cti_ct;
create table bh_ke_thu_cti_ct
    (so_id number,
    ma varchar2(50),            -- Ma chi tieu
    ten nvarchar2(500),
    loai varchar2(5),
    tu_dk varchar2(5),
    tu_nd varchar2(500),
    den_dk varchar2(5),
    den_nd varchar2(500),
    bt number);
create index bh_ke_thu_cti_ct_i1 on bh_ke_thu_cti_ct(so_id);

drop table bh_ke_thu_cti_txt;
create table bh_ke_thu_cti_txt
    (so_id number,
    loai varchar2(10),
    txt clob);
create index bh_ke_thu_cti_txt_i1 on bh_ke_thu_cti_txt(so_id);

drop table bh_ke_chi_ma;
create table bh_ke_chi_ma
    (ma_dvi varchar2(10),
    ma varchar2(20),
    ten nvarchar2(200),
    tc varchar2(1),
    ma_ct varchar2(20),
 loai varchar2(10),
    ngay_kt number,
    nsd varchar2(10),
    txt clob
);
create unique index bh_ke_chi_ma_u0 on bh_ke_chi_ma(ma);
create index bh_ke_chi_ma_i1 on bh_ke_chi_ma (ma_ct);

-- Tai khoan Phan bo chi phi chung

drop table bh_ke_tk;
create table bh_ke_tk
    (ma_dvi varchar2(10),
    ma_tk varchar2(10),
    ma_tke varchar2(20),
    pp varchar2(5),             -- D-Doanh thu, N-Nguoi, V-Vu boi thuong
    ngay_bd number,
    nsd varchar2(10),
    bt number);
create unique index bh_ke_tk_i1 on bh_ke_tk(ma_tk,ma_tke);
create index bh_ke_tk_i2 on bh_ke_tk(ngay_bd);