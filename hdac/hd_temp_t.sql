drop table TEMP_SL_100;
create global temporary table TEMP_SL_100
(
  ma_dvi   varchar2(20),
  loai_bp  varchar2(2),
  ma_bp    varchar2(20)
)
on commit preserve rows nocache;

drop table TEMP_HD_SC_THANG;

create global temporary table TEMP_HD_SC_THANG
(
  ma_dvi   nvarchar2(10),
  loai_bp  nvarchar2(2),
  ma_bp    nvarchar2(10),
  ma       nvarchar2(20),
  seri     nvarchar2(10),
  thang    number
)
on commit preserve rows nocache;
/

drop table TEMP_SL;
create global temporary table TEMP_SL
(
  bang  varchar2(50),
  c1    nvarchar2(250),
  c2    nvarchar2(250),
  c3    nvarchar2(250),
  c4    nvarchar2(250),
  c5    nvarchar2(250),
  c6    nvarchar2(250),
  c7    nvarchar2(250),
  c8    nvarchar2(250),
  c9    nvarchar2(250),
  c10   nvarchar2(250),
  c11   nvarchar2(250),
  c12   nvarchar2(250),
  c13   nvarchar2(250),
  c14   nvarchar2(250),
  c15   nvarchar2(250),
  c16   nvarchar2(250),
  c17   nvarchar2(250),
  c18   nvarchar2(250),
  c19   nvarchar2(250),
  c20   nvarchar2(250),
  c21   nvarchar2(250),
  c22   nvarchar2(250),
  c23   nvarchar2(250),
  c24   nvarchar2(250),
  c25   nvarchar2(250),
  c26   nvarchar2(250),
  c27   nvarchar2(250),
  c28   nvarchar2(250),
  c29   nvarchar2(250),
  c30   nvarchar2(250),
  n1    number,
  n2    number,
  n3    number,
  n4    number,
  n5    number,
  n6    number,
  n7    number,
  n8    number,
  n9    number,
  n10   number,
  n11   number,
  n12   number,
  n13   number,
  n14   number,
  n15   number,
  n16   number,
  n17   number,
  n18   number,
  n19   number,
  n20   number,
  n21   number,
  n22   number,
  n23   number,
  n24   number,
  n25   number,
  n26   number,
  n27   number,
  n28   number,
  n29   number,
  n30   number,
  d1    date,
  d2    date,
  d3    date,
  d4    date,
  d5    date,
  d6    date,
  d7    date,
  d8    date,
  d9    date,
  d10   date,
  b1    varchar2(10),
  b2    varchar2(10),
  b3    varchar2(10),
  b4    varchar2(10),
  b5    varchar2(10),
  b6    varchar2(10),
  b7    varchar2(10),
  b8    varchar2(10),
  b9    varchar2(10),
  b10   varchar2(10),
  b11   varchar2(10),
  b12   varchar2(10),
  b13   varchar2(10),
  b14   varchar2(10),
  b15   varchar2(10)
)
on commit preserve rows
nocache;