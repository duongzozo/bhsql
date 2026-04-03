drop table BH_KT_TK;
CREATE TABLE BH_KT_TK
(
  MA_DVI  VARCHAR2(20),
  NGAY    NUMBER,
  LOAI    VARCHAR2(5),
  MA_TK   VARCHAR2(200),
  NSD     VARCHAR2(20)
)
/

drop table bh_tke_kt_nv;
create table bh_tke_kt_nv
 (ma_dvi varchar2(10),
 ma_tke varchar2(10),
 lh_nv varchar2(10));

drop table bh_kt_matk;
CREATE TABLE bh_kt_matk
 (ma_dvi varchar2(10),
 ngay number,
 nhom varchar2(5),
 loai varchar2(20),
 ma_tk varchar2(20),
 tk_thue varchar2(20),
 nsd varchar2(10)
);
create unique index bh_kt_matk_u0 on bh_kt_matk(ma_dvi,ngay,nhom,loai,ma_tk,tk_thue);

drop table bh_kt_dm_lct;
create table bh_kt_dm_lct
 (ma varchar2(20),
  ten varchar2(500)
);
create unique index bh_kt_dm_lct_u0 on bh_kt_dm_lct(ma);

drop table bh_kt;
CREATE TABLE bh_kt
 (ma_dvi varchar2(10),
 so_id number,
 ngay_ht number,
 l_ct varchar2(10),
 so_ct varchar2(20),
 nha varchar2(10),
 tk_nha varchar2(20),
 nsd varchar2(10)
);
create unique index bh_kt_u0 on bh_kt(ma_dvi,so_id);
create index bh_kt_i1 on bh_kt (ma_dvi,ngay_ht);

drop table bh_kt_txt;
create table bh_kt_txt
    (ma_dvi varchar2(10),
    so_id number,
    loai varchar2(20),
    txt clob)
    PARTITION BY LIST (ma_dvi) (
        PARTITION bh_kt_txt_0800 values ('0800'),
        PARTITION bh_kt_txt_DEFA values (DEFAULT));
CREATE INDEX bh_kt_txt_i1 on bh_kt_txt(so_id) local;

/** Phan bo ke toan **/

drop table bh_kt_pbo_dt_temp;
create GLOBAL TEMPORARY table bh_kt_pbo_dt_temp(
    ma_dvi varchar2(10),
    so_id number,
 nv varchar2(10),
 sp varchar2(20),
    lh_nv varchar2(20),
    phi number)
ON COMMIT PRESERVE ROWS;

drop table bh_kt_pbo_bt_temp;
create GLOBAL TEMPORARY table bh_kt_pbo_bt_temp(
    ma_dvi varchar2(10),
    so_id number,
 nv varchar2(10),
 sp varchar2(20),
    lh_nv varchar2(20),
    tien number)
ON COMMIT PRESERVE ROWS;

drop table bh_kt_pbo_temp;
create GLOBAL TEMPORARY table bh_kt_pbo_temp(
    ma_dvi varchar2(10),
    nhom varchar2(1),           -- H-HO, D-Don vi
    loai varchar2(1),   -- D-Theo doanh thu, B-Theo boi thuong
    ma_tke varchar2(30),
    so_id number,
    lh_nv varchar2(20),
    phi number,
    pbo number)
ON COMMIT PRESERVE ROWS;

/** Tong hop doanh thu **/

drop table bh_kt_dthuG_temp1;
create GLOBAL TEMPORARY table bh_kt_dthuG_temp1(
    ma_dvi varchar2(10),
    ma_dvi_qd varchar2(10),
 so_id number,
 so_id_dt number,
 kieu_hd varchar2(1),
 nv varchar2(10),
 sp varchar2(20),
 ma_dt varchar2(20),
    lh_nv varchar2(20),
    phi number,
 phiC number)
ON COMMIT PRESERVE ROWS;

drop table bh_kt_dthuD_temp1;
create GLOBAL TEMPORARY table bh_kt_dthuD_temp1(
    ma_dvi varchar2(10),
 so_id number,
 so_id_dt number,
 kieu_hd varchar2(1),
 kieu_do varchar2(1),
 nv varchar2(10),
 sp varchar2(20),
 ma_dt varchar2(20),
    lh_nv varchar2(20),
    phi number,
 phiT number,
 hhT number)
ON COMMIT PRESERVE ROWS;

drop table bh_kt_dthuT_temp1;
create GLOBAL TEMPORARY table bh_kt_dthuT_temp1(
    ma_dvi varchar2(10),
 so_id number,
 so_id_dt number,
 kieu_hd varchar2(1),
 nv varchar2(10),
 sp varchar2(20),
 ma_dt varchar2(20),
    lh_nv varchar2(20),
 pthuc varchar2(1),
    phi number,
 phiT number,
 hhT number)
ON COMMIT PRESERVE ROWS;

drop table kt_1;
create table kt_1
(
  ma_dvi  varchar2(20) not null,
  so_id   number not null,
  ngay_ht number,
  l_ct    varchar2(10),
  so_tt   number,
  so_ct   varchar2(30),
  ngay_ct varchar2(10),
  tien    number,
  nd      nvarchar2(400),
  ndp     nvarchar2(400),
  nsd     varchar2(10),
  hth     varchar2(10),
  lk      varchar2(100),
  htoan   varchar2(1),
  md      varchar2(2),
  ngay_nh date,
  idvung  number

);
create unique index kt_1_u0 on kt_1(ma_dvi,so_id);
create index kt_1_i1 on kt_1 (ma_dvi, ngay_ht, l_ct, so_tt);

drop table kt_2;
create table kt_2
(
  ma_dvi  varchar2(20) not null,
  so_id   number not null,
  bt      number not null,
  ngay_ht number,
  nv      varchar2(1),
  ma_tk   varchar2(20),
  ma_tke  varchar2(20),
  tien    number,
  note    nvarchar2(200),
  idvung  number

);
create unique index kt_2_u0 on kt_2(ma_dvi, so_id, bt);
create index kt_2_i1 on kt_2 (ma_dvi, ngay_ht);

drop table kt_3;
create table kt_3
(
  ma_dvi    varchar2(20),
  so_id     number,
  bt        number,
  ngay_ht   number,
  ma_tk_no  varchar2(20),
  ma_tke_no varchar2(20),
  note_no   nvarchar2(200),
  ma_tk_co  varchar2(20),
  ma_tke_co nvarchar2(20),
  note_co   nvarchar2(200),
  tien      number,
  l_ct      varchar2(10),
  so_id_so  number,
  idvung    number

);
create unique index kt_3_u0 on kt_3(ma_dvi, so_id, bt);
create index kt_3_i1 on kt_3 (ma_dvi, ngay_ht, so_id_so);
create index kt_3_i2 on kt_3 (ma_dvi, so_id_so);
create index kt_3_i3 on kt_3 (ma_dvi, ngay_ht, ma_tk_no, ma_tke_no);
create index kt_3_i4 on kt_3 (ma_dvi, ngay_ht, ma_tk_co, ma_tke_co);

drop table kt_bctk;
create table kt_bctk
(
  ma_dvi  varchar2(20),
  id_ma   number,
  ngay_ht number,
  ma_bc   varchar2(30),
  ten_bc  nvarchar2(150),
  rep     varchar2(30),
  ma      varchar2(10),
  dau     char(1),
  hs      number,
  ten     nvarchar2(150),
  ht      char(1),
  bt      number,
  so_tt   varchar2(10),
  ma_ct   varchar2(10),
  nsd     varchar2(20)

);
create unique index kt_bctk_u0 on kt_bctk(ma_dvi, id_ma);
create index kt_bctk_i1 on kt_bctk (ma_dvi, ma_bc, ngay_ht, id_ma);

drop table kt_bctk_nv;
create table kt_bctk_nv
(
  ma_dvi varchar2(20) not null,
  id_nv  number not null,
  id_ma  number,
  ma     varchar2(10),
  cot    number,
  dau    char(1),
  nv     varchar2(2)

);
create unique index kt_bctk_nv_u0 on kt_bctk_nv(ma_dvi, id_nv);

drop table ktb_bc;
create table ktb_bc
(
  ma_dvi varchar2(20) not null,
  ma_bc  varchar2(20) not null,
  ten_bc nvarchar2(150),
  loai   varchar2(20) not null,
  nhom   varchar2(10) not null,
  so_tt  varchar2(20) not null,
  ngayd  number,
  ngayc  number,
  ma     varchar2(10),
  ten    nvarchar2(150),
  cap    varchar2(1),
  ht     varchar2(1),
  cot1   number,
  cot2   number,
  cot3   number,
  cot4   number,
  cot5   number,
  cot6   number,
  cot7   number,
  cot8   number,
  cot9   number,
  cot10  number,
  cot11  number,
  cot12  number,
  cot13  number,
  cot14  number,
  cot15  number,
  cot16  number,
  cot17  number,
  cot18  number,
  cot19  number,
  cot20  number,
  cot21  number,
  cot22  number,
  cot23  number,
  cot24  number,
  cot25  number,
  cot26  number,
  cot27  number,
  cot28  number,
  nsd    varchar2(10)

);
create unique index ktb_bc_u0 on ktb_bc(ma_dvi, ma_bc, loai, nhom, so_tt);