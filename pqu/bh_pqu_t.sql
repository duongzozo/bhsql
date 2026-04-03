drop table bh_pqu_ma;
create table bh_pqu_ma(
    ma varchar2(10),
    ten nvarchar2(500),
    nsd varchar2(10),
 txt clob
);
create unique index bh_pqu_ma_u0 on bh_pqu_ma(ma);

drop table bh_pqu_nhom;
create table bh_pqu_nhom(
    so_id number,
    nhom varchar2(10),
    nv varchar2(10),            --Line Sp
    ma_sp varchar2(10),
    nhomT nvarchar2(500),
    ma_spT nvarchar2(500)
);
create unique index bh_pqu_nhom_u0 on bh_pqu_nhom(so_id);
CREATE INDEX bh_pqu_nhom_i1 on bh_pqu_nhom(nhom,nv,ma_sp);

drop table bh_pqu_nhom_ct;
create table bh_pqu_nhom_ct(
    so_id number,
    ma_ql varchar2(10),         -- Ma quyen loi trong SP
    ma_pqu varchar2(10),        -- Ma phan quyen
    ghan number,
    ma_qlT nvarchar2(500),
    ma_pquT nvarchar2(500));
CREATE INDEX bh_pqu_nhom_ct_i1 on bh_pqu_nhom_ct(so_id);

drop table bh_pqu_nhom_lt;
create table bh_pqu_nhom_lt(
    so_id number,
    ma_lt varchar2(10),
    ten nvarchar2(500));
CREATE INDEX bh_pqu_nhom_lt_i1 on bh_pqu_nhom_lt(so_id);

drop table bh_pqu_nsd;
create table bh_pqu_nsd(
    so_id number,
    ma_dvi varchar2(10),
    nsd varchar2(20),
    nv varchar2(10),           --Line Sp
    ma_sp varchar2(10),
    nsdT nvarchar2(500),
    ma_spT nvarchar2(500)
);
create unique index bh_pqu_nsd_u0 on bh_pqu_nsd(so_id);
CREATE INDEX bh_pqu_nsd_i1 on bh_pqu_nsd(ma_dvi,nsd,nv,ma_sp);

drop table bh_pqu_nsd_ct;
create table bh_pqu_nsd_ct(
    so_id number,
    ma_ql varchar2(10),         -- Ma quyen loi trong SP
    ma_pqu varchar2(10),        -- Ma phan quyen
    ghan number,
    ma_qlT nvarchar2(500),
    ma_pquT nvarchar2(500));
CREATE INDEX bh_pqu_nsd_ct_i1 on bh_pqu_nsd_ct(so_id);

drop table bh_pqu_nsd_lt;
create table bh_pqu_nsd_lt(
    so_id number,
    ma_lt varchar2(10),
    ten nvarchar2(500));
CREATE INDEX bh_pqu_nsd_lt_i1 on bh_pqu_nsd_lt(so_id);

drop table bh_pqu_nsd_temp_ql;
create GLOBAL TEMPORARY table bh_pqu_nsd_temp_ql(
    ma_ql varchar2(10),
    ma_qlT varchar2(500));

drop table bh_pqu_nsd_temp;
create GLOBAL TEMPORARY table bh_pqu_nsd_temp(
    ma_ql varchar2(10),
    ma_pqu varchar2(10),
    ghan number,
    ma_qlT varchar2(500),
    ma_pquT varchar2(500));

-- khac

drop table bh_pqu_nhom_kh;
create table bh_pqu_nhom_kh(
    so_id number,
 nv varchar2(10),
 loai varchar2(10),
    nhom varchar2(10),
    nhomT nvarchar2(500),
    loaiT nvarchar2(500)
);
create unique index bh_pqu_nhom_kh_u0 on bh_pqu_nhom_kh(so_id);
CREATE INDEX bh_pqu_nhom_kh_i1 on bh_pqu_nhom_kh(nv,loai,nhom);

drop table bh_pqu_nsd_kh;
create table bh_pqu_nsd_kh(
    so_id number,
 nv varchar2(10),
 loai varchar2(10),
    ma_dvi varchar2(10),
 nsd varchar2(20),
    nsdT nvarchar2(100),
    loaiT nvarchar2(500)
);
create unique index bh_pqu_nsd_kh_u0 on bh_pqu_nsd_kh(so_id);
CREATE INDEX bh_pqu_nsd_kh_i1 on bh_pqu_nsd_kh(nv,loai,ma_dvi,nsd);

drop table bh_pqu_khang;
create table bh_pqu_khang(
    ma_dvi varchar2(10),
 nsd varchar2(20),
    nsdT nvarchar2(100),
 nv varchar2(10),
 mobi varchar2(20),
 email varchar2(100));--duchq update
CREATE INDEX bh_pqu_khang_i1 on bh_pqu_khang(ma_dvi,nsd);

drop table bh_pqu_txt;
create table bh_pqu_txt(
    so_id number,
    loai varchar2(10),
    txt clob);
CREATE INDEX bh_pqu_txt_i1 on bh_pqu_txt(so_id);