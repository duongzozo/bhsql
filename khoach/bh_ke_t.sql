drop table bh_ke_dthu_trso;
create table bh_ke_dthu_trso
    (dviK varchar2(1),
    dvi varchar2(10),
    nam number,
    ma varchar2(20),
    trso number);
create index bh_ke_dthu_trso_i1 on bh_ke_dthu_trso(dviK,dvi,nam);

drop table bh_ke_dthu_ng;
create table bh_ke_dthu_ng
    (dviK varchar2(1),          -- kieu don vi: D-don vi, B-Bo phan
    dvi varchar2(10),
    nv varchar2(10),
    kenh varchar2(10),
    khang varchar2(10),         -- Nhom khach hang
    ngay number);
create index bh_ke_dthu_ng_i1 on bh_ke_dthu_ng(dviK,dvi,nv);
create index bh_ke_dthu_ng_i2 on bh_ke_dthu_ng(ngay);

drop table bh_ke_dthu;
create table bh_ke_dthu
    (dviK varchar2(1),          -- kieu don vi: D-don vi, B-Bo phan
    dvi varchar2(10),
    nv varchar2(10),
    kenh varchar2(10),
    khang varchar2(10),         -- Nhom khach hang
    ngay number,
    ma varchar2(20),         -- Ma ke hoach
    nhom varchar2(20),
    lh_nv varchar2(10),
    goc number,
    dong number,
    tai number,
    tam number,
    nam number,
    bt number);
create index bh_ke_dthu_i1 on bh_ke_dthu(dviK,dvi,nv,nam);
create index bh_ke_dthu_i2 on bh_ke_dthu(dviK,dvi,nv,kenh,khang,ngay);

drop table bh_ke_che_ng;
create table bh_ke_che_ng
    (dviK varchar2(1),          -- kieu don vi: D-don vi, B-Bo phan
    dvi varchar2(10),
    nv varchar2(10),
    kenh varchar2(10),
    khang varchar2(10),         -- Nhom khach hang
    ngay number);
create index bh_ke_che_ng_i1 on bh_ke_che_ng(dviK,dvi,nv);
create index bh_ke_che_ng_i2 on bh_ke_che_ng(ngay);

drop table bh_ke_che;
create table bh_ke_che
    (dviK varchar2(1),          -- kieu don vi: D-don vi, B-Bo phan
    dvi varchar2(10),
    nv varchar2(10),
    kenh varchar2(10),
    khang varchar2(10),         -- Nhom khach hang
    ngay number,
    ma varchar2(20),         -- Ma ke hoach
    nhom varchar2(20),
    lh_nv varchar2(10),
    goc number,
    dong number,
    tai number,
    tam number,
    nam number,
    bt number);
create index bh_ke_che_i1 on bh_ke_che(dviK,dvi,nv,nam);
create index bh_ke_che_i2 on bh_ke_che(dviK,dvi,nv,ngay,nhom);