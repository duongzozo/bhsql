-- Phat sinh

drop table bh_VTP_ps;
create table bh_VTP_ps(
    bil varchar2(20),
 so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    ngay number,
    loai varchar2(1),           -- 1-di, 2-ve, 3- ca di & ve
    cuoc number,
    phi number,
    txt clob,                   -- Thong tin: Nguoi gui, nguoi nhan
    ngayB number
);
create unique index bh_vtp_ps_u0 on bh_vtp_ps(bil);

-- Bang tong hop

drop table bh_VTP_psT;
create table bh_VTP_psT(
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    so_bil number,
    cuoc number,
    phi number
);
create unique index bh_vtp_pst_u0 on bh_vtp_pst(so_id);

-- Bang loi

drop table bh_VTP_loi;
create table bh_VTP_loi(
    loai varchar2(1),
    bil varchar2(20),
    loi varchar2(500));

drop table bh_VTP_psLT;            -- Dich chuyen sau 2 thang
create table bh_VTP_psLT(
    bil varchar2(20),
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    ngay number,
    loai varchar2(1),           -- 1-di, 2-ve, 3- ca di & ve
    cuoc number,
    phi number,
    txt clob,                   -- Thong tin: Nguoi gui, nguoi nhan
    ngayB number);

drop table bh_VTP_psLN;            -- Dich chuyen sau 18 thang
create table bh_VTP_psLN(
    bil varchar2(20),
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    ngay number,
    loai varchar2(1),           -- 1-di, 2-ve, 3- ca di & ve
    cuoc number,
    phi number,
    txt clob,                   -- Thong tin: Nguoi gui, nguoi nhan
    ngayB number);

drop table bh_VTP_psTLT;
create table bh_VTP_psTLT(
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    so_bil number,
    cuoc number,
    phi number
);
create unique index bh_vtp_pstlt_u0 on bh_vtp_pstlt(so_id);

drop table bh_VTP_psTLN;
create table bh_VTP_psTLN(
    so_id number,
    so_hd varchar2(20),
    ngay_ht number,
    so_bil number,
    cuoc number,
    phi number
);
create unique index bh_vtp_pstln_u0 on bh_vtp_pstln(so_id);

drop table bh_VTP_bt;
create table bh_VTP_bt(
    bil varchar2(20),
 so_id number,
 so_id_hd number,
    so_hd varchar2(20),
 so_id_hs number,
    so_hs varchar2(30),
    ngay_ht number,
    ngay number,
    loai varchar2(1),           -- 1-di, 2-ve, 3- ca di & ve
    cuoc number,
    ma_nn varchar2(10),
    txt clob
);
create unique index bh_vtp_bt_u0 on bh_vtp_bt(bil);

-- Bang tong hop

drop table bh_VTP_btT;
create table bh_VTP_btT(
    so_id number,
    ngay_ht number,
 so_bill number,
 so_hs number,
    cuoc number,
 thue number
);
create unique index bh_vtp_btt_u0 on bh_vtp_btt(so_id);

drop table bh_VTP_btLT;
create table bh_VTP_btLT(
    bil varchar2(20),
 so_id number,
 so_id_hd number,
    so_hd varchar2(20),
 so_id_hs number,
    so_hs varchar2(30),
    ngay_ht number,
    ngay number,
    loai varchar2(1),           -- 1-di, 2-ve, 3- ca di & ve
    cuoc number,
    ma_nn varchar2(10),
    txt clob);

drop table bh_VTP_btLN;
create table bh_VTP_btLN(
    bil varchar2(20),
 so_id number,
 so_id_hd number,
    so_hd varchar2(20),
 so_id_hs number,
    so_hs varchar2(30),
    ngay_ht number,
    ngay number,
    loai varchar2(1),           -- 1-di, 2-ve, 3- ca di & ve
    cuoc number,
    ma_nn varchar2(10),
    txt clob);

drop table bh_VTP_giam;
create table bh_VTP_giam(
 thang number,
 phi number,
 bthuong number,
 tl number,
 giam number
);
create unique index bh_vtp_giam_u0 on bh_vtp_giam(thang);

drop table bh_vtppt;
create table bh_vtppt
(
  so_id    number,
  so_hd    varchar2(20 byte),
  ngay_ht  number,
  so_pil   number,
  cuoc     number,
  phi      number
);
create unique index bh_vtppt_u0 on bh_vtppt(so_pil);

drop table bh_hh_ma_pp;
create table bh_hh_ma_pp
(
  ma_dvi  varchar2(10 byte),
  ma      varchar2(10 byte),
  ten     nvarchar2(200),
  nsd     varchar2(10 byte)
);
create unique index bh_hh_ma_pp_u0 on bh_hh_ma_pp(ma_dvi, ma);

drop table bh_hh_ma_hang;
create table bh_hh_ma_hang
(
  ma_dvi  varchar2(10 byte),
  ma      varchar2(20 byte),
  ten     nvarchar2(200),
  ma_ct   varchar2(20 byte),
  nsd     varchar2(10 byte)
);
create unique index bh_hh_ma_hang_u0 on bh_hh_ma_hang(ma_dvi, ma);
create index bh_hh_ma_hang_i1 on bh_hh_ma_hang (ma_dvi, ma_ct);