drop table TEMP_BC_BH_DTBH_MM;
create global temporary table TEMP_BC_BH_DTBH_MM
(
  ma_dvi     varchar2(10),
  so_hd      varchar2(50),
  nv         varchar2(10),
  kieu_hd    varchar2(1),
  ma_kh      varchar2(20),
  nguon      varchar2(20),
  cb_ql      varchar2(10),
  phong      varchar2(10),
  kieu_kt    varchar2(1),
  ma_kt      varchar2(20),
  ngay_hl    date,
  ngay_kt    date,
  ma_nt      varchar2(5),
  lh_nv      varchar2(20),
  so_id      number,
  so_id_tt   number,
  ngay_ht    number,
  ngay_htnv  number,
  phi        number,
  thue       number,
  phi_nt     number,
  thue_nt    number,
  dbh        number,
  ma_dvig    varchar2(10)
)
on commit preserve rows
nocache;

drop table TEMP_BC_BH_DTBH_MNVM;
create global temporary table TEMP_BC_BH_DTBH_MNVM
(
  ma_dvi     varchar2(20),
  so_hd      varchar2(50),
  nv         varchar2(10),
  kieu_hd    varchar2(1),
  ma_kh      varchar2(20),
  nguon      varchar2(20),
  cb_ql      varchar2(10),
  phong      varchar2(10),
  kieu_kt    varchar2(1),
  ma_kt      varchar2(20),
  ngay_hl    date,
  ngay_kt    date,
  ma_nt      varchar2(5),
  lh_nv      varchar2(20),
  so_id      number,
  ngay_ht    number,
  ngay_htnv  number,
  phi        number,
  thue       number,
  phi_nt     number,
  thue_nt    number,
  dbh        number,
  ma_dvig    varchar2(10)
)
on commit preserve rows nocache;

DROP TABLE TEMP_BC_BH_DTPS_MM;
CREATE GLOBAL TEMPORARY TABLE TEMP_BC_BH_DTPS_MM
(
  MA_DVI     VARCHAR2(20),
  SO_HD      VARCHAR2(50),
  NV         VARCHAR2(10),
  KIEU_HD    VARCHAR2(1),
  MA_KH      VARCHAR2(20),
  NGUON      VARCHAR2(20),
  CB_QL      VARCHAR2(10),
  PHONG      VARCHAR2(10),
  KIEU_KT    VARCHAR2(1),
  MA_KT      VARCHAR2(20),
  NGAY_HL    DATE,
  NGAY_KT    DATE,
  MA_NT      VARCHAR2(5),
  LH_NV      VARCHAR2(10),
  SO_ID      NUMBER,
  NGAY_HT    NUMBER,
  NGAY_HTNV  NUMBER,
  PHI        NUMBER,
  THUE       NUMBER,
  PHI_NT     NUMBER,
  THUE_NT    NUMBER,
  SO_ID_XL   NUMBER,
  MA_DVIG    VARCHAR2(10)
)
ON COMMIT PRESERVE ROWS
NOCACHE;

drop table TEMP_BC_BH_DTPS_MNVM;
create global temporary table TEMP_BC_BH_DTPS_MNVM
(
  ma_dvi     varchar2(20),
  so_hd      varchar2(50),
  nv         varchar2(10),
  kieu_hd    varchar2(1),
  ma_kh      varchar2(20),
  nguon      varchar2(20),
  cb_ql      varchar2(10),
  phong      varchar2(10),
  kieu_kt    varchar2(1),
  ma_kt      varchar2(20),
  ngay_hl    date,
  ngay_kt    date,
  ma_nt      varchar2(5),
  lh_nv      varchar2(10),
  so_id      number,
  ngay_ht    number,
  ngay_htnv  number,
  phi        number,
  thue       number,
  phi_nt     number,
  thue_nt    number,
  dbh        number,
  ma_dvig    varchar2(10)
)
on commit preserve rows nocache;

drop table TEMP_BC_BH_DTTT_MA_DT;
create global temporary table TEMP_BC_BH_DTTT_MA_DT
(
  ma_dvi     varchar2(20),
  so_hd      varchar2(50),
  nv         varchar2(10),
  kieu_hd    varchar2(1),
  ma_kh      varchar2(20),
  nguon      varchar2(20),
  cb_ql      varchar2(10),
  phong      varchar2(10),
  kieu_kt    varchar2(1),
  ma_kt      varchar2(20),
  ngay_hl    date,
  ngay_kt    date,
  ma_nt      varchar2(5),
  lh_nv      varchar2(20),
  ma_dt      varchar2(10),
  so_id_tt   number,
  so_id      number,
  ngay       number,
  ngay_ht    number,
  ngay_htnv  number,
  ngay_htbs  number,
  phi        number,
  thue       number,
  hhong      number,
  hhong_nt   number,
  htro       number,
  htro_nt    number,
  pt         varchar2(1),
  dbh        number,
  ma_dvig    varchar2(10)
)
on commit preserve rows nocache;

drop table TEMP_BC_BH_DTTT_MM;
create global temporary table TEMP_BC_BH_DTTT_MM
(
  ma_dvi     varchar2(10),
  so_hd      varchar2(50),
  nv         varchar2(10),
  kieu_hd    varchar2(1),
  ma_kh      varchar2(20),
  nguon      varchar2(20),
  cb_ql      varchar2(10),
  phong      varchar2(10),
  kieu_kt    varchar2(1),
  ma_kt      varchar2(20),
  ngay_hl    date,
  ngay_kt    date,
  ma_nt      varchar2(5),
  lh_nv      varchar2(20),
  so_id_tt   number,
  so_id      number,
  ngay_ht    number,
  ngay_htnv  number,
  phi        number,
  thue       number,
  hhong      number,
  hhong_nt   number,
  htro       number,
  htro_nt    number,
  pt         varchar2(1),
  dbh        number,
  ma_dvig    varchar2(10)
)
on commit preserve rows nocache;

drop table TEMP_BC_PHONG;
create global temporary table TEMP_BC_PHONG
(
  phong  varchar2(10)
)
on commit preserve rows nocache;

drop table TEMP_BC_NV;

create global temporary table TEMP_BC_NV
(
  nv  varchar2(10)
)
on commit preserve rows nocache;

drop table TEMP_BC_DVI;
create global temporary table TEMP_BC_DVI
(
  dvi  varchar2(10)
)
on commit preserve rows nocache;

drop table BH_THANG2D_BC_DT_LUU;
create global temporary table BH_THANG2D_BC_DT_LUU
(
  ma_dvi                          varchar2(50 byte),
  phong                           nvarchar2(100),
  nv                              varchar2(200 byte),
  dt_ps                           number,
  thue_dtps                       number,
  dt_bh                           number,
  thue_dtbh                       number,
  dt_tt                           number,
  thue_dttt                       number,
  lh_nv                           varchar2(100 byte),
  ma_kh                           varchar2(200 byte),
  ma_kt                           varchar2(200 byte),
  ma_gt                           varchar2(200 byte),
  cb_ql                           varchar2(200 byte),
  so_hd                           varchar2(200 byte),
  loai_kh                         varchar2(50 byte)
)
on commit preserve rows nocache;

drop table BC_BH_BT_TEMP;
create global temporary table BC_BH_BT_TEMP
(
  ma_dvi    VARCHAR2(20),
  so_id     NUMBER,
  nv        VARCHAR2(10),
  phong     VARCHAR2(10),
  lh_nv     VARCHAR2(20),
  ngay_qd_n NUMBER,
  ma_dvi_hd VARCHAR2(10),
  so_id_hd  NUMBER,
  so_id_dt  NUMBER,
  tien      NUMBER,
  tien_qd   NUMBER,
  ngay_ht   NUMBER,
  tc        VARCHAR2(1),
  c1        NVARCHAR2(200),
  c2        NVARCHAR2(200),
  c3        NVARCHAR2(200),
  c4        NVARCHAR2(200),
  c5        NVARCHAR2(200),
  c6        NVARCHAR2(200),
  c7        NVARCHAR2(200),
  c8        NVARCHAR2(200),
  c9        NVARCHAR2(200),
  c10       NVARCHAR2(200),
  c11       NVARCHAR2(200),
  c12       NVARCHAR2(200),
  c13       NVARCHAR2(200),
  c14       NVARCHAR2(200),
  c15       NVARCHAR2(200),
  c16       NVARCHAR2(200),
  c17       NVARCHAR2(200),
  c18       NVARCHAR2(200),
  c19       NVARCHAR2(200),
  c20       NVARCHAR2(200),
  c21       NVARCHAR2(200),
  c22       NVARCHAR2(200),
  c23       NVARCHAR2(200),
  c24       NVARCHAR2(200),
  c25       NVARCHAR2(200),
  c26       NVARCHAR2(200),
  c27       NVARCHAR2(200),
  c28       NVARCHAR2(200),
  c29       NVARCHAR2(200),
  c30       NVARCHAR2(200),
  n1        NUMBER,
  n2        NUMBER,
  n3        NUMBER,
  n4        NUMBER,
  n5        NUMBER,
  n6        NUMBER,
  n7        NUMBER,
  n8        NUMBER,
  n9        NUMBER,
  n10       NUMBER,
  n11       NUMBER,
  n12       NUMBER,
  n13       NUMBER,
  n14       NUMBER,
  n15       NUMBER,
  n16       NUMBER,
  n17       NUMBER,
  n18       NUMBER,
  n19       NUMBER,
  n20       NUMBER,
  n21       NUMBER,
  n22       NUMBER,
  n23       NUMBER,
  n24       NUMBER,
  n25       NUMBER,
  n26       NUMBER,
  n27       NUMBER,
  n28       NUMBER,
  n29       NUMBER,
  n30       NUMBER,
  d1        DATE,
  d2        DATE,
  d3        DATE,
  d4        DATE,
  d5        DATE
);

drop table bc_bh_bt_hs_temp;
create global temporary table bc_bh_bt_hs_temp
(
  ma_dvi    varchar2(20),
  so_id     number,
  nv        varchar2(10),
  phong     varchar2(10),
  lh_nv     varchar2(20),
  ngay_qd_n number,
  ma_dvi_hd varchar2(10),
  so_id_hd  number,
  so_id_dt  number,
  tien      number,
  tien_qd   number,
  ngay_ht   number,
  tc        varchar2(1)
);