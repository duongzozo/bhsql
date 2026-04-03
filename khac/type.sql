create or replace package PHT_TYPE AS

type a_var is table of VARCHAR2(250) index by BINARY_INTEGER;

type a_lvar is table of VARCHAR2(1050) index by BINARY_INTEGER;

type a_nvar is table of NVARCHAR2(500) index by BINARY_INTEGER;

type a_num is table of number index by BINARY_INTEGER;

type a_bool is table of boolean index by BINARY_INTEGER;

type a_date is table of date index by BINARY_INTEGER;

type a_clob is table of clob index by BINARY_INTEGER;

type a_json is table of clob index by BINARY_INTEGER;
type cs_type is ref cursor;

type kt_rc is record(ma_tk varchar2(20),kt_no number,kt_co number,nv_no number,nv_co number);

type kt_a_rc is table of kt_rc index by BINARY_INTEGER;

end PHT_TYPE;
/
