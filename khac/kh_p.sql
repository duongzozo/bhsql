create or replace function FKH_Fm(b_tp number:=0) return varchar2
AS
	b_kq varchar2(30):='999,999,999,999,999,999';
begin
-- Dan
if b_tp>0 then b_kq:=b_kq||'.'||substr('999999',1,b_tp); end if;
return b_kq;
end;
/
create or replace function FKH_SO_Fm(b_so number,b_tp number:=0) return varchar2
AS
    b_fm varchar2(30); b_i1 number :=b_tp;
begin
-- Dan
if b_so=trunc(b_so,0) then b_i1:=0; end if;
b_fm:=FKH_Fm(b_i1);
return trim(to_char(b_so,b_fm));
end;
/
create or replace function FKH_RAND(b_kt number) return varchar2
AS
    b_kq varchar2(50); b_i1 number:=abs(DBMS_RANDOM.RANDOM);
begin
-- Dan - Tra so ngau nhien
b_kq:=to_char(b_i1);
b_kq:=rpad(b_kq,b_kt,'0');
b_kq:=substr(b_kq,1,b_kt);
return b_kq;
end;
/
create or replace function FKH_GIAO(b_x1 number,b_y1 number,b_x2 number,b_y2 number) return varchar2
AS
	b_kq varchar2(1):='K';
begin
-- Dan - Xac dinh co diem chung
if b_y2>=b_x1 and b_y1>=b_x2 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FKH_GIAOd(b_x1 date,b_y1 date,b_x2 date,b_y2 date) return varchar2
AS
	b_kq varchar2(1):='K';
begin
-- Dan - Xac dinh co diem chung
if b_y2>=b_x1 and b_y1>=b_x2 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FKH_GIAOdn(b_x1N number,b_y1N number,b_x2N number,b_y2N number) return varchar2
AS
	b_kq varchar2(1):='K'; b_x1 date:=PKH_SO_CDT(b_x1N); b_y1 date:=PKH_SO_CDT(b_y1N); b_x2 date:=PKH_SO_CDT(b_x2N); b_y2 date:=PKH_SO_CDT(b_y2N);
begin
-- Dan - Xac dinh co diem chung
if b_y2>=b_x1 and b_y1>=b_x2 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FKH_KCACH(b_tdoX1 number,b_tdoY1 number,b_tdoX2 number,b_tdoY2 number,b_dvi varchar2:='KM') return number
AS
	b_kq number:=0;
begin
-- Dan - Xac dinh khoang cach
b_kq:=sdo_geom.sdo_distance(sdo_geometry(2001, 4326, null, sdo_elem_info_array(1, 1, 1),
	sdo_ordinate_array(b_tdoY1,b_tdoX1)),sdo_geometry(2001, 4326, null,sdo_elem_info_array(1, 1, 1),
	sdo_ordinate_array(b_tdoY2,b_tdoX2)), 1, 'unit='||b_dvi);
return round(b_kq,1);
end;
/
create or replace procedure FKH_CHIA(
    b_phi number,a_ma_dt pht_type.a_var,a_tl pht_type.a_num,a_phi out pht_type.a_num)
AS
    b_tp number:=0; b_con number:=b_phi;
begin
-- Dan - Chia tien theo ty le
if b_phi<>round(b_phi,0) then b_tp:=2; end if;
for b_lp in 1..a_ma_dt.count loop
    if b_lp=a_ma_dt.count then a_phi(b_lp):=b_con;
    else
        a_phi(b_lp):=round(b_phi*a_tl(b_lp),b_tp);
        if abs(a_phi(b_lp))>abs(b_con) then a_phi(b_lp):=b_con; end if;
        b_con:=b_con-a_phi(b_lp);
    end if;
end loop;
end;
/
create or replace function FKH_SOIDG(b_so_id number) return varchar2
AS
    b_s varchar2(16):=to_char(b_so_id); b_i1 number;
begin
b_i1:=PKH_LOC_CHU_SO(substr(b_s,9));
return substr(b_s,3, 6)||trim(to_char(b_i1));
end;
/
create or replace function FKH_BUNI return nvarchar2
AS
begin
return '';
end;
/
create or replace procedure PKH_LKE_VTRI(b_trangkt number,b_tu in out number,b_den out number,b_trang out number)
AS
begin
-- Dan - Xac dinh vi tri liet ke
b_trang:=round((b_tu-1)/b_trangkt-.5,0);
if b_trang<0 then b_trang:=0; end if;
b_tu:=b_trang*b_trangkt+1; b_den:=b_tu+b_trangkt-1; b_trang:=b_trang+1;
end;
/
create or replace procedure PKH_LKE_TRANG(b_dong number,b_tu in out number,b_den in out number)
AS
	b_trangkt number; b_trang number;
begin
-- Dan - Xac dinh vi tri liet ke
if b_den=1000000 then b_trangkt:=b_tu; else b_trangkt:=b_den-b_tu+1; end if;
if b_tu>b_dong then b_tu:=b_dong; end if;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
end;
/
create or replace function FKH_CTR_BANG(b_bang varchar2,b_ten varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
    b_bangH varchar2(50):=upper(b_bang); b_tenH varchar2(50):=upper(b_ten);
begin
-- Dan - Cau truc bang
select count(*) into b_i1 from all_tab_columns where upper(table_name)=b_bangH and upper(column_name)=b_tenH and OWNER = SYS_CONTEXT('USERENV', 'CURRENT_SCHEMA');
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PKH_CTR_BANG
	(b_bang varchar2,a_ma out pht_type.a_var,a_loai out pht_type.a_var,a_ten out pht_type.a_nvar)
AS
	 b_loi varchar2(100); b_kt number:=0; b_loai varchar2(2); b_owner varchar2(20):=user; b_bangH varchar2(50):=upper(b_bang);
begin
-- Hung - Cau truc bang
b_loi:='loi:Loi doc cau truc:loi';
PKH_MANG_KD(a_ma); PKH_MANG_KD(a_loai); PKH_MANG_KD_U(a_ten);
for b_lp in (select a.column_name ma,a.data_type loai,b.comments ten
	from all_tab_columns a, all_col_comments b
	where a.owner=b_owner and a.table_name=b_bangH and b.owner=b_owner
	and b.table_name=b_bangH and b.column_name=a.column_name) loop
	b_kt:=b_kt+1; b_loai:=substr(b_lp.loai,1,2); a_ma(b_kt):=b_lp.ma; a_ten(b_kt):=b_lp.ten;
	if b_loai in('VA','NV') then a_loai(b_kt):='C';
	elsif b_loai='DA' then a_loai(b_kt):='N';
	elsif b_loai='NU' then a_loai(b_kt):='S';
	else a_loai(b_kt):='K';
	end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_LKE_CTRUC
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_bang varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(200); b_owner varchar2(20); b_bangH varchar2(50):=upper(b_bang);
begin
-- Dan - Cau truc bang
b_loi:='loi:Loi doc cau truc:loi';
select min(owner) into b_owner from all_tab_columns where table_name=b_bangH;
if b_owner is null then raise PROGRAM_ERROR; end if;
open cs1 for select column_name cot,data_type loai from all_tab_columns where owner=b_owner and table_name=b_bangH;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_LKE_CTRUCv(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_owner varchar2(50); b_tso varchar(30):='owner';
    b_bang varchar2(50):=upper(trim(b_oraIn));
begin
-- Dan - Cau truc bang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi cau hinh tham so:loi';
select upper(ten) into b_owner from ht_tso_hd where ma=b_tso;
if b_owner is null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi doc cau truc:loi';
select JSON_ARRAYAGG(json_object(
    'cot' value column_name,'rong' value decode(data_type,'VARCHAR2',data_length,round((data_length+1)/2,0))) returning clob)
    into b_oraOut from all_tab_columns where owner=b_owner and table_name=b_bang and data_type in('VARCHAR2','NVARCHAR2');
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function PKH_LOC_CHU
	(b_chu varchar2,b_dau varchar2:='F',b_tp varchar2:='T') return varchar2
AS
	b_c2 varchar2(200); b_c3 varchar2(200); b_c1 varchar2(1); b_i1 number;
begin
-- Dan - Loc cac ky tu trong chuoi
b_c3:=trim(b_chu);
if b_c3 is null then return ''; end if;
b_i1:=length(rtrim(b_c3)); b_c2:=' ';
for b_lp in 1..b_i1 loop
	b_c1:=substr(b_c3,b_lp,1);
	if instr('0123456789',b_c1)>0 or (b_tp='T' and b_c1='.' and instr(b_c2,'.')=0) then
		b_c2:=trim(b_c2)||b_c1;
	end if;
end loop;
if b_dau='T' and instr(b_c3,'-')>0 and length(rtrim(b_c2))>0 then b_c2:='-'||rtrim(b_c2); end if;
if b_c2='.' then b_c2:=' '; end if;
return rtrim(b_c2);
end;
/
create or replace function PKH_LOC_CHU_SO(
	b_chu varchar2,b_dau varchar2:='F',b_tp varchar2:='T') return number
AS
	b_c2 varchar2(200); b_c3 varchar2(200); b_c1 varchar2(1); b_i1 number;
begin
-- Dan - Loc cac ky tu trong chuoi va doi thanh so
b_c3:=trim(b_chu);
if b_c3 is null then return 0; end if;
b_i1:=length(rtrim(b_c3)); b_c2:=' ';
for b_lp in 1..b_i1 loop
	b_c1:=substr(b_c3,b_lp,1);
	if instr('0123456789',b_c1)>0 or (b_tp='T' and b_c1='.' and instr(b_c2,'.')=0) then
		b_c2:=trim(b_c2)||b_c1;
	end if;
end loop;
if b_dau='T' and instr(b_c3,'-')>0 and length(rtrim(b_c2))>0 then b_c2:='-'||trim(b_c2); end if;
if b_c2='.' then b_c2:='0'; end if;
return to_number(trim(b_c2));
end;
/
create or replace function PKH_LOC_SO(b_chu varchar2) return varchar2
AS
    b_c2 varchar2(1000); b_c3 varchar2(1000); b_c1 varchar2(10); b_i1 number;
begin
-- Dan - Loc cac so trong chuoi
b_c3:=trim(b_chu);
b_c3:=replace(b_c3,' ','');
if b_c3 is null then return ''; end if;
b_i1:=length(b_c3); b_c2:=' ';
for b_lp in 1..b_i1 loop
    b_c1:=substr(b_c3,b_lp,1);
    if instr('0123456789',b_c1)>0 then b_c2:=trim(b_c2)||b_c1; end if;
end loop;
return rtrim(b_c2);
end;
/
create or replace function PKH_LOC_CHUi
	(b_chu varchar2,b_loc varchar2) return varchar2
AS
	b_kq varchar2(1000):=b_chu; a_loc pht_type.a_var;
begin
-- Dan - Loc cac ky tu trong chuoi
PKH_CH_ARR(b_loc,a_loc);
for b_lp in 1..a_loc.count loop
	b_kq:=replace(b_kq,a_loc(b_lp),'');
end loop;
return b_kq;
end;
/
create or replace procedure PKH_GHEP(b_cu in out varchar2,b_them varchar2,b_cach varchar2:=',')
AS
begin
-- Dan - them chuoi
if trim(b_cu) is null then b_cu:=b_them; else b_cu:=b_cu||b_cach||b_them; end if;
end;
/
create or replace function FKH_GHEP(b_cu varchar2,b_them varchar2,b_cach varchar2:=',') return varchar2
AS
	b_kq varchar2(2000):=b_cu;
begin
-- Dan - them chuoi
if trim(b_kq) is null then b_kq:=b_them; else b_kq:=b_kq||b_cach||b_them; end if;
return b_kq;
end;
/
create or replace procedure PKH_GHEPc(b_cu in out clob,b_them clob,b_cach varchar2:=',')
AS
begin
-- Dan - them chuoi clob
if b_cu is null then b_cu:=b_them; else b_cu:=b_cu||b_cach||b_them; end if;
end;
/
create or replace function FKH_THEM(b_cu varchar2,b_them varchar2,b_cach varchar2:=',') return varchar2
AS
    b_kq varchar2(2000):=b_cu;
begin
-- Dan - them chuoi
if b_kq is null then
    b_kq:=b_them;
elsif trim(FKH_CH_TIM(b_kq,b_them,b_cach)) is null then
    b_kq:=b_cach||b_them;
end if;
return b_kq;
end;
/
create or replace function FKH_GHEP_SERI(b_mau varchar2,b_chu varchar2,b_so varchar2,b_de varchar2) return varchar2
AS
	b_kq varchar2(50):='';
begin
-- Dan - Ghep Seri hoa don
if trim(b_so) is not null then
	b_kq:=trim(b_mau);
	if trim(b_chu) is not null then
		if b_kq is null then b_kq:=trim(b_chu);
		else  b_kq:=trim(b_kq)||'+'||trim(b_chu);
		end if;
	end if;
	if b_kq is null then b_kq:=trim(b_so);
	else  b_kq:=trim(b_kq)||'+'||trim(b_so);
	end if;
end if;
if b_kq is null then b_kq:=b_de; end if;
return b_kq;
end;
/
create or replace function PKH_HOI_SERI(b_chu varchar2) return varchar2
AS
	b_c3 varchar2(200); b_c1 varchar2(1); b_i1 number; b_i2 number:=1;
	b_seri varchar2(200):=''; b_so varchar2(200):=''; b_duoi varchar2(200):='';
begin
-- Dan - Cho seri tiep theo
b_c3:=trim(b_chu);
if b_c3 is null then return '1'; end if;
b_i1:=length(b_c3);
while b_i2<=b_i1 loop
	b_c1:=substr(b_c3,b_i2,1);
	exit when instr('0123456789',b_c1)>0;
	b_seri:=trim(b_seri)||b_c1; b_i2:=b_i2+1;
end loop;
while b_i2<=b_i1 loop
	b_c1:=substr(b_c3,b_i2,1);
	exit when instr('0123456789',b_c1)=0;
	b_so:=trim(b_so)||b_c1; b_i2:=b_i2+1;
end loop;
b_duoi:=substr(b_c3,b_i2);
if b_so is null then b_so:='1';
else
	b_i1:=length(b_so); b_i2:=to_number(b_so)+1; b_so:=trim(to_char(b_i2));
	if b_i1>length(b_so) then b_so:=lpad(b_so,b_i1,'0'); end if;
end if;
return ltrim(b_seri)||trim(b_so)||rtrim(b_duoi);
end;
/
create or replace procedure PKH_CH_ARR(b_ch varchar2,a_ch out pht_type.a_var,b_cach varchar2:=',')
AS
	b_kt number:=0; b_i1 number; b_i2 number; b_c varchar2(4000);
begin
-- Dan - Chuyen chuoi thanh mang chuoi
PKH_MANG_KD(a_ch);
if b_ch is null then return; end if;
b_c:=b_ch;
while b_c is not null loop
	b_i1:=instr(b_c,b_cach); b_kt:=b_kt+1;
	if b_i1=0 then a_ch(b_kt):=b_c; b_c:='';
	else a_ch(b_kt):=substr(b_c,1,b_i1-1); b_c:=substr(b_c,b_i1+1);
	end if;
end loop;
end;
/
create or replace procedure PKH_CH_ARR_U(b_ch nvarchar2,a_ch out pht_type.a_nvar,b_cach varchar2:=',')
AS
	b_kt number:=0; b_i1 number; b_i2 number; b_c nvarchar2(4000);
begin
-- Dan - Chuyen chuoi thanh mang Unicode
PKH_MANG_KD_U(a_ch);
if b_ch is null then return; end if;
b_c:=b_ch;
while b_c is not null loop
	b_i1:=instr(b_c,b_cach); b_kt:=b_kt+1;
	if b_i1=0 then a_ch(b_kt):=b_c; b_c:='';
	else a_ch(b_kt):=substr(b_c,1,b_i1-1); b_c:=substr(b_c,b_i1+1);
	end if;
end loop;
end;
/
create or replace procedure PKH_CH_ARR_N(b_ch varchar2,a_ch out pht_type.a_num,b_cach varchar2:=',')
AS
	b_kt number:=0; b_i1 number; b_i2 number; b_c varchar2(4000);
begin
-- Dan - Chuyen chuoi thanh mang so
PKH_MANG_KD_N(a_ch);
if b_ch is null then return; end if;
b_c:=b_ch;
while b_c is not null loop
	b_i1:=instr(b_c,b_cach); b_kt:=b_kt+1;
	if b_i1=0 then a_ch(b_kt):=to_number(b_c); b_c:='';
	else a_ch(b_kt):=to_number(substr(b_c,1,b_i1-1)); b_c:=substr(b_c,b_i1+1);
	end if;
end loop;
end;
/
create or replace function FKH_ARR_CH(a_ch pht_type.a_var,b_cach varchar2:='#') return varchar2
AS
	b_ch varchar2(4000):='';
begin
-- Dan - Chuyen mang chu thanh chuoi
if a_ch is null or a_ch.count=0 then return ''; end if;
b_ch:=a_ch(1);
for b_lp in 2..a_ch.count loop
	b_ch:=trim(b_ch)||b_cach||nvl(a_ch(b_lp),'');
end loop;
return b_ch;
end;
/
create or replace function FKH_ARR_CH_U(a_ch pht_type.a_nvar,b_cach varchar2:='#') return nvarchar2
AS
	b_ch nvarchar2(4000):='';
begin
-- Dan - Chuyen mang chu Unicode thanh chuoi Unicode
if a_ch is null or a_ch.count=0 then return ''; end if;
b_ch:=a_ch(1);
for b_lp in 2..a_ch.count loop
	b_ch:=trim(b_ch)||b_cach||nvl(a_ch(b_lp),'');
end loop;
return b_ch;
end;
/
create or replace function FKH_ARR_CH_N(a_ch pht_type.a_num,b_cach varchar2:='#') return varchar2
AS
	b_ch varchar2(4000):='';
begin
-- Dan - Chuyen mang chu Unicode thanh chuoi Unicode
if a_ch is null or a_ch.count=0 then return ''; end if;
b_ch:=to_char(a_ch(1));
for b_lp in 2..a_ch.count loop
	b_ch:=b_ch||b_cach||to_char(a_ch(b_lp));
end loop;
return b_ch;
end;
/
create or replace function FKH_ARR_CH_D(a_ch pht_type.a_date,b_cach varchar2:='#') return varchar2
AS
	b_ch varchar2(4000):='';
begin
-- Dan - Chuyen mang chu Unicode thanh chuoi Unicode
if a_ch is null or a_ch.count=0 then return ''; end if;
b_ch:=to_char(a_ch(1),'yyyymmdd');
for b_lp in 2..a_ch.count loop
	b_ch:=b_ch||b_cach||to_char(a_ch(b_lp),'yyyymmdd');
end loop;
return b_ch;
end;
/
create or replace function FKH_ARR_TONG(a_ch pht_type.a_num) return number
AS
	b_kq number:=0;
begin
-- Dan - Tinh tong
for b_lp in 1..a_ch.count loop b_kq:=b_kq+a_ch(b_lp); end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_MIN(a_ch pht_type.a_var) return varchar2
AS
	b_kq varchar2(4000);
begin
-- Dan - Tra gia tri min trong mang
if a_ch is null or a_ch.count=0 then return ''; end if;
b_kq:=a_ch(1);
for b_lp in 2..a_ch.count loop
	if a_ch(b_lp)<b_kq then b_kq:=a_ch(b_lp); end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_MINn(a_ch pht_type.a_num) return number
AS
	b_kq number:=0;
begin
-- Dan - Tra gia tri min trong mang
if a_ch is not null and a_ch.count<>0 then
	b_kq:=a_ch(1);
	for b_lp in 2..a_ch.count loop
	if a_ch(b_lp)<b_kq then b_kq:=a_ch(b_lp); end if;
end loop;
end if;
return b_kq;
end;
/
create or replace function FKH_ARR_MAX(a_ch pht_type.a_var) return varchar2
AS
	b_kq varchar2(4000):='';
begin
-- Dan - Tra gia tri max trong mang
if a_ch is not null and a_ch.count<>0 then
	b_kq:=a_ch(1);
	for b_lp in 2..a_ch.count loop
		if a_ch(b_lp)>b_kq then b_kq:=a_ch(b_lp); end if;
	end loop;
end if;
return b_kq;
end;
/
create or replace function FKH_ARR_MAXn(a_ch pht_type.a_num) return number
AS
	b_kq number:=0;
begin
-- Dan - Tra gia tri max trong mang so
if a_ch is not null and a_ch.count<>0 then
	b_kq:=a_ch(1);
	for b_lp in 2..a_ch.count loop
		if a_ch(b_lp)>b_kq then b_kq:=a_ch(b_lp); end if;
	end loop;
end if;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRIm(a_ch pht_type.a_var) return number
AS
	b_kq number;
begin
-- Dan - Tra vi tri min trong mang
if a_ch is null or a_ch.count=0 then return 0; end if;
b_kq:=1;
for b_lp in 2..a_ch.count loop
	if a_ch(b_lp)<b_kq then b_kq:=b_lp; end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRIx(a_ch pht_type.a_var) return number
AS
	b_kq number;
begin
-- Dan - Tra vi tri max trong mang
if a_ch is null or a_ch.count=0 then return 0; end if;
b_kq:=1;
for b_lp in 2..a_ch.count loop
	if a_ch(b_lp)>b_kq then b_kq:=b_lp; end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRIm_N(a_ch pht_type.a_num) return number
AS
	b_kq number;
begin
-- Dan - Tra vi tri min trong mang
if a_ch is null or a_ch.count=0 then return 0; end if;
b_kq:=1;
for b_lp in 2..a_ch.count loop
	if a_ch(b_lp)<b_kq then b_kq:=b_lp; end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRIx_N(a_ch pht_type.a_num) return number
AS
	b_kq number;
begin
-- Dan - Tra vi tri max trong mang
if a_ch is null or a_ch.count=0 then return 0; end if;
b_kq:=1;
for b_lp in 2..a_ch.count loop
	if a_ch(b_lp)>b_kq then b_kq:=b_lp; end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRI(a_ch pht_type.a_var,b_tim varchar2,b_dk varchar2:='B') return number
AS
    b_kq number:=0;
begin
-- Dan - Tim vi tri trong mang
if b_dk='B' then
    for b_lp in 1..a_ch.count loop
        if upper(a_ch(b_lp))=upper(b_tim) then b_kq:=b_lp; exit; end if;
    end loop;
elsif b_dk='G' then
    for b_lp in 1..a_ch.count loop
        if instr(upper(a_ch(b_lp)),upper(b_tim))=1 then b_kq:=b_lp; exit; end if;
    end loop;
else
    for b_lp in 1..a_ch.count loop
        if instr(upper(a_ch(b_lp)),upper(b_tim))>0 then b_kq:=b_lp; exit; end if;
    end loop;
end if;
return b_kq;
end;
/
create or replace function FKH_ARR_TIM(a_ch pht_type.a_var,b_tim varchar2,b_dk varchar2:='B') return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - Tim co hay khong
if FKH_ARR_VTRI(a_ch,b_tim,b_dk)>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRIu(a_ch pht_type.a_nvar,b_tim nvarchar2,b_dk varchar2:='B') return number
AS
    b_kq number:=0;
begin
-- Dan - Tim vi tri trong mang
if b_dk='B' then
    for b_lp in 1..a_ch.count loop
        if upper(a_ch(b_lp))=upper(b_tim) then b_kq:=b_lp; exit; end if;
    end loop;
elsif b_dk='G' then
    for b_lp in 1..a_ch.count loop
        if instr(upper(a_ch(b_lp)),upper(b_tim))=1 then b_kq:=b_lp; exit; end if;
    end loop;
else
    for b_lp in 1..a_ch.count loop
        if instr(upper(a_ch(b_lp)),upper(b_tim))>0 then b_kq:=b_lp; exit; end if;
    end loop;
end if;
return b_kq;
end;
/
create or replace function FKH_ARR_VTRI_N(a_ch pht_type.a_num,b_tim number) return number
AS
    b_kq number:=0;
begin
-- Dan - Tim vi tri trung trong mang
for b_lp in 1..a_ch.count loop
    if a_ch(b_lp)=b_tim then b_kq:=b_lp; exit; end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_ARR_TIM_N(a_ch pht_type.a_num,b_tim number) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - Tra gia tri co trong mang
if FKH_ARR_VTRI_N(a_ch,b_tim)>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FKH_ARR_TIM_TEN(a_ten pht_type.a_var,a_nd pht_type.a_var,b_tim varchar2) return varchar2
AS
    b_kq varchar2(2000):=''; b_i1 number;
begin
-- Dan - Tra gia tri tim neu thay
b_i1:=FKH_ARR_VTRI(a_ten,b_tim);
if b_i1<>0 then b_kq:=a_nd(b_i1); end if;
return b_kq;
end;
/
create or replace function FKH_ARR_TIM_TENu(a_ten pht_type.a_var,a_nd pht_type.a_nvar,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(2000):=''; b_i1 number;
begin
-- Dan - Tra gia tri tim neu thay
b_i1:=FKH_ARR_VTRI(a_ten,b_tim);
if b_i1<>0 then b_kq:=a_nd(b_i1); end if;
return b_kq;
end;
/
create or replace procedure PKH_ARR_TIM_TENu(
    a_ten pht_type.a_var,a_nd pht_type.a_nvar,b_tim varchar2,a_tra out pht_type.a_nvar)
AS
    a_tim pht_type.a_var;
begin
-- Dan - Tra gia tri tim neu thay
PKH_CH_ARR(b_tim,a_tim);
for b_lp in 1..a_tim.count loop
    a_tra(b_lp):=FKH_ARR_TIM_TENu(a_ten,a_nd,a_tim(b_lp));
end loop;
end;
/
create or replace function FKH_ARR_TIM_TENn(a_ten pht_type.a_var,a_nd pht_type.a_num,b_tim varchar2) return number
AS
    b_kq number:=-1.e18; b_i1 number;
begin
-- Dan - Tra gia tri tim neu thay
b_i1:=FKH_ARR_VTRI(a_ten,b_tim);
if b_i1<>0 then b_kq:=a_nd(b_i1); end if;
return b_kq;
end;
/
create or replace function FKH_CH_TIM(b_ch varchar2,b_tim varchar2,b_cach varchar2:=',') return varchar2
AS
	b_kq varchar2(100):=' '; a_ch pht_type.a_var; a_t pht_type.a_var;
begin
-- Dan - Tra tim neu thay
PKH_CH_ARR(b_ch,a_ch,b_cach);
for b_lp in 1..a_ch.count loop
	PKH_CH_ARR(a_ch(b_lp),a_t,':');
	if a_t(1)=b_tim then b_kq:=a_t(2); exit; end if;
end loop;
return b_kq;
end;
/
create or replace procedure PKH_ARR_THEM(a_chC in out pht_type.a_var,a_chT pht_type.a_var)
AS
	b_kt number;
begin
-- Dan - Them vao mang tu mang khac neu chua co
b_kt:=a_chC.count;
for b_lp in 1..a_chT.count loop
	if FKH_ARR_TIM(a_chC,a_chT(b_lp))='K' then
		b_kt:=b_kt+1; a_chC(b_kt):=a_chT(b_lp) ;
	end if;
end loop;
end;
/
create or replace procedure PKH_ARR_THEM_N(a_chC in out pht_type.a_num,a_chT pht_type.a_num)
AS
	b_kt number;
begin
-- Dan - Them vao mang tu mang khac neu chua co
b_kt:=a_chC.count;
for b_lp in 1..a_chT.count loop
	if FKH_ARR_TIM_N(a_chC,a_chT(b_lp))='K' then
		b_kt:=b_kt+1; a_chC(b_kt):=a_chT(b_lp) ;
	end if;
end loop;
end;
/
create or replace procedure PKH_ARR_THAYu(
    a_maM pht_type.a_var,a_ndM pht_type.a_nvar,a_ma pht_type.a_var,a_nd in out pht_type.a_nvar)
AS
    b_i1 number;
begin
-- Dan - Thay doi noi dung
for b_lp in 1..a_maM.count loop
    b_i1:=FKH_ARR_VTRI(a_ma,a_maM(b_lp));
    if b_i1<>0 then a_nd(b_i1):=a_ndM(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_ARR_XEP_N(a_ch in out pht_type.a_num)
AS
    b_i1 number; b_n number; b_kt number:=a_ch.count;
begin
-- Dan - xep
if b_kt>1 then
    for b_lp in 1..b_kt loop
        b_i1:=b_lp+1;
        if b_i1>b_kt then exit; end if;
        for b_lp1 in b_i1..b_kt loop
            if a_ch(b_lp)>a_ch(b_lp1) then b_n:=a_ch(b_lp); a_ch(b_lp):=a_ch(b_lp1); a_ch(b_lp1):=b_n; end if;
        end loop;
    end loop;
end if;
end;
/
create or replace procedure PKH_ARR_DNH(a_goc pht_type.a_var,a_kq out pht_type.a_var)
AS
    b_kt number:=1; b_i1 number;
begin
-- Dan - Tra mang duy nhat
a_kq(1):=a_goc(1);
for b_lp in 2..a_goc.count loop
    b_i1:=0;
    for b_lp1 in 1..b_kt loop
        if a_kq(b_lp1)=a_goc(b_lp) then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then b_kt:=b_kt+1; a_kq(b_kt):=a_goc(b_lp); end if;
end loop;
end;
/
create or replace function PKH_MA_TENl(b_tenL nvarchar2,b_de varchar2:=' ') return varchar2
AS
  b_kq varchar2(50):=b_de; b_ten nvarchar2(1000); b_i1 number;
begin
-- Dan - Tra phan ma trong ten cua list
b_ten:=trim(b_tenL);
if trim(b_ten) is not null then
  b_i1:=instr(b_ten,'|'); --Nam: ưu tien ky tu |
  if b_i1=0 then b_i1:=instr(b_ten,':'); end if;
  if b_i1=0 then
    b_kq:=substr(b_ten,1,20);
  else
    b_i1:=b_i1-1;
    if b_i1>20 then b_i1:=20; end if;
    b_kq:=substr(b_ten,1,b_i1);
  end if;
end if;
return nvl(b_kq,b_de);
end;
/
create or replace function PKH_TEN_TENl(b_tenL nvarchar2,b_de varchar2:=' ') return nvarchar2
AS
	b_kq nvarchar2(500):=b_de; b_ten nvarchar2(1000); b_i1 number;
begin
-- Dan - Tra phan ten trong ten cua list
b_ten:=trim(b_tenL);
if trim(b_ten) is not null then
	b_i1:=instr(b_ten,':');
	if b_i1=0 then b_i1:=instr(b_ten,'|'); end if;
	if b_i1<>0 then b_kq:=substr(b_ten,b_i1+1); end if;
end if;
return nvl(b_kq,b_de);
end;
/
create or replace function PKH_MA_MA
	(b_ngoai varchar2,b_trong varchar2) return boolean
AS
	a_ch pht_type.a_var;
begin
-- Dan - Tim chuoi trong chuoi
if b_trong is null or b_ngoai is null then return false; end if;
PKH_CH_ARR(b_ngoai,a_ch);
for b_lp in 1..a_ch.count loop
	if a_ch(b_lp)=b_trong then return true; end if;
end loop;
return false;
end;
/
create or replace function PKH_MA_MA_C
	(b_ngoai varchar2,b_trong varchar2) return varchar2
AS
begin
-- Dan - Tim chuoi trong chuoi return C,K
if PKH_MA_MA(b_ngoai,b_trong) then return 'C'; else return 'K'; end if;
end;
/
create or replace function PKH_MA_LMA
	(b_ngoai varchar2,b_trong varchar2) return boolean
AS
	a_ch pht_type.a_var;
begin
-- Dan - Tim chuoi trong chuoi (like)
if b_trong is null or b_ngoai is null then return false; end if;
PKH_CH_ARR(b_ngoai,a_ch);
for b_lp in 1..a_ch.count loop
	if instr(b_trong,a_ch(b_lp))=1 then return true; end if;
end loop;
return false;
end;
/
create or replace function PKH_MA_LMA_C
	(b_ngoai varchar2,b_trong varchar2) return varchar2
AS
begin
-- Dan - Tim chuoi trong chuoi (like) ket qua la 'C','K'
if PKH_MA_LMA(b_ngoai,b_trong) then return 'C'; else return 'K'; end if;
end;
/
create or replace function PKH_MA_LMA_S
	(b_ngoai varchar2,b_trong varchar2) return varchar2
AS
	a_ch pht_type.a_var;
begin
-- Dan - Tra chuoi trong chuoi (like)
if b_trong is null or b_ngoai is null then return ''; end if;
PKH_CH_ARR(b_ngoai,a_ch);
for b_lp in 1..a_ch.count loop
	if instr(b_trong,a_ch(b_lp))=1 then return a_ch(b_lp); end if;
end loop;
return '';
end;
/
create or replace function PKH_MA_GMA
	(b_ngoai varchar2,b_trong varchar2) return boolean
AS
	a_ch pht_type.a_var;
begin
-- Dan - Tim chuoi giua chuoi (%like%)
if b_trong is null or b_ngoai is null then return false; end if;
PKH_CH_ARR(b_ngoai,a_ch);
for b_lp in 1..a_ch.count loop
	if instr(b_trong,a_ch(b_lp))<>0 then return true; end if;
end loop;
return false;
end;
/
create or replace function PKH_MA_GMA_C
	(b_ngoai varchar2,b_trong varchar2) return varchar2
AS
begin
-- Dan - Tim chuoi trong chuoi (like) ket qua la 'C','K'
if PKH_MA_GMA(b_ngoai,b_trong) then return 'C'; else return 'K'; end if;
end;
/
create or replace function PKH_SO_CH(b_so number) return varchar2
AS
begin
-- Dan - Chuyen so chu
return trim(to_char(b_so,'999G999G999G999G999D99'));
end;
/
create or replace function PKH_NG_TH(b_ngay date) return number
AS
begin
-- Dan - Chuyen ngay sang so dang yyyymm
return to_number(to_char(b_ngay,'yyyymm'));
end;
/
create or replace function PKH_NG_CSO(b_ngay date) return number
AS
begin
-- Dan - Chuyen ngay sang so dang yyyymmdd
return to_number(to_char(b_ngay,'yyyymmdd'));
end;
/
create or replace function PKH_CNG_SO(b_ngay varchar2) return number
AS
	b_c8 varchar2(8);
begin
-- Dan - Chuyen chu ngay sang so dang yyyymmdd
b_c8:=substr(b_ngay,7,4)||substr(b_ngay,4,2)||substr(b_ngay,1,2);
return to_number(b_c8);
end;
/
create or replace function PKH_CNG_CSO(b_ngay varchar2) return varchar2
AS
begin
-- Dan - Chuyen chu ngay sang chu dang yyyymmdd
return substr(b_ngay,7,4)||substr(b_ngay,4,2)||substr(b_ngay,1,2);
end;
/
create or replace function PKH_SO_CNG(b_so number) return varchar2
AS
	b_c8 varchar2(8);
begin
-- Dan - Chuyen so dang yyyymmdd sang chuoi dd/mm/yyyy
b_c8:=to_char(b_so);
return substr(b_c8,7,2)||'/'||substr(b_c8,5,2)||'/'||substr(b_c8,1,4);
end;
/
create or replace function PKH_SO_CDT(b_so number) return date
AS
	b_c8 varchar2(8); b_c2 varchar2(2); b_c1 varchar2(2); b_c6 varchar2(6);
begin
-- Dan - Chuyen so dang yyyymmdd sang date
b_c8:=to_char(b_so); b_c2:=substr(b_c8,7,2); b_c6:=substr(b_c8,1,6);
if b_c2='00' then b_c2:='01';
else
	b_c1:=to_char(last_day(to_date(b_c6||'01','yyyymmdd')),'dd');
	if to_number(b_c2)>to_number(b_c1) then b_c2:=b_c1; end if;
end if;
return trunc(to_date(b_c6||b_c2,'yyyymmdd'));
exception when others then return null;
end;
/
create or replace function PKH_CNG_NG(b_ngay varchar2,b_de date:='01-jan-3000') return date
AS
	b_kq date:=b_de; b_c8 varchar2(8);
begin
-- Dan - Chuyen chuoi dang ngay dd/mm/yyyy sang ngay
if trim(b_ngay) is not null and length(b_ngay)=10 then
	b_c8:=substr(b_ngay,7,4)||substr(b_ngay,4,2)||substr(b_ngay,1,2);
	b_kq:=to_date(b_c8,'yyyymmdd');
end if;
return b_kq;
end;
/
create or replace function PKH_NG_NG(b_ngay date) return date
AS
begin
-- Dan - Lam tron ngay, bo gio, phut, giay
return trunc(b_ngay);
end;
/
create or replace function PKH_SO_THANG(b_so number) return number
AS
begin
-- Dan - Tra thang cua so dang yyyymmdd 
return (round(b_so,-2)-round(b_so,-4))/100;
end;
/
create or replace function PKH_SO_QUI(b_so number) return number
AS
begin
-- Dan - Tra qui cua so dang yyyymmdd
return FLOOR((round(b_so,-2)-round(b_so,-4)-100)/300)+1;
end;
/
create or replace function PKH_ID_NAM(b_so_id number) return number
AS
begin
-- Dan - Tra nam cua so ID
return round(b_so_id,-10)/10000000000;
end;
/
create or replace function PKH_SO_NAM(b_so number) return number
AS
begin
-- Dan - Tra nam so dang yyyymmdd
return round(b_so,-4)/10000;
end;
/
create or replace function FKH_NG_NGAY(b_ngay date) return number
AS
begin
-- Dan - Tra ngay cua thang
return EXTRACT(DAY FROM b_ngay);
end;
/
create or replace function FKH_NG_THANG(b_ngay date) return number
AS
begin
-- Dan - Tra thang cua date
return EXTRACT(MONTH FROM b_ngay);
end;
/
create or replace function FKH_NG_QUI(b_ngay date) return number
AS
    b_th number:=FKH_NG_THANG(b_ngay);
begin
-- Dan - Tra qui cua so dang yyyymmdd
return FLOOR((b_th-1)/3)+1;
end;
/
create or replace function FKH_NG_NAM(b_ngay date) return number
AS
begin
-- Dan - Tra nam cua date
return EXTRACT(YEAR FROM b_ngay);
end;
/
create or replace function FKH_KHO_NG(b_ngayd date,b_ngayc date,b_dk varchar2:='C') return number
As
    b_kq number;
begin
-- Tra khoang giua 2 ngay
b_kq:=trunc(b_ngayc)-trunc(b_ngayd);
if b_dk='C' and substr(to_char(b_ngayd,'ddmmyy'),1,2)=substr(to_char(b_ngayc,'ddmmyy'),1,2) then
    b_kq:=b_kq+1;
end if;
return b_kq;
end;
/
create or replace function FKH_KHO_NGSO(b_sod number,b_soc number,b_dk varchar2:='C') return number
As
	b_ngayd date:=PKH_SO_CDT(b_sod); b_ngayc date:=PKH_SO_CDT(b_soc);
begin
-- Tra khoang giua 2 ngay dang so
return FKH_KHO_NG(b_ngayd,b_ngayc,b_dk);
end;
/
create or replace function FKH_TD_NGSO(b_so number,b_td number) return number
As
	b_ngay date:=PKH_SO_CDT(b_so);
begin
-- Thay doi ngay dang so
return PKH_NG_CSO(b_ngay+b_td);
end;
/
create or replace function FKH_KHO_TH(b_ngayd date,b_ngayc date) return number
As
begin
-- Tra khoang thang giua 2 ngay
return months_between(trunc(b_ngayc,'MONTH'),trunc(b_ngayd,'MONTH'));
end;
/
create or replace function FKH_KHO_THSO(b_sod number,b_soc number) return number
As
	b_ngayd date:=PKH_SO_CDT(b_sod); b_ngayc date:=PKH_SO_CDT(b_soc);
begin
-- Tra khoang thang giua 2 ngay dang so
return months_between(trunc(b_ngayc,'MONTH'),trunc(b_ngayd,'MONTH'));
end;
/
create or replace function FKH_KHO_NA(b_ngayd date,b_ngayc date) return number
As
    b_th number:=FKH_KHO_TH(b_ngayd,b_ngayc);
begin
-- Tra khoang nam giua 2 ngay
return floor(b_th /12);
end;
/
create or replace function FKH_KHO_NASO(b_sod number,b_soc number) return number
As
    b_th number:=FKH_KHO_THSO(b_sod,b_soc);
begin
-- Tra khoang nam giua 2 ngay dang so
return floor(b_th /12);
end;
/
create or replace function FKH_KHO_GIO(b_ngayd date,b_ngayc date) return number
As
begin
-- Tra khoang gio
return 24*FKH_KHO_NG(b_ngayd,b_ngayc)+to_number(to_char(b_ngayc,'hh24'))-to_number(to_char(b_ngayd,'hh24'));
end;
/
create or replace function FKH_KHO_PHUT(b_ngayd date,b_ngayc date) return number
As
begin
-- Tra khoang phut
return 60*FKH_KHO_GIO(b_ngayd,b_ngayc)+to_number(to_char(b_ngayc,'mi'))-to_number(to_char(b_ngayd,'mi'));
end;
/
create or replace function FKH_KHO_GIAY(b_ngayd date,b_ngayc date) return number
As
begin
-- Tra khoang giay
return 60*FKH_KHO_PHUT(b_ngayd,b_ngayc)+to_number(to_char(b_ngayc,'ss'))-to_number(to_char(b_ngayd,'ss'));
end;
/
create or replace function FKH_NAM_GIAY return number
AS
    b_ngay date:=sysdate; b_n number; b_d date; b_c varchar2(10);
begin
-- Tra khoang giay tinh tu dau nam
b_n:=FKH_NG_NAM(b_ngay); b_c:='01/01/'||to_char(b_n); b_d:=PKH_CNG_NG(b_c);
b_n:=FKH_KHO_GIAY(b_d,b_ngay);
return b_n;
end;
/
create or replace function FKH_NAM_GIAYs return varchar2
AS
    b_n number; b_c varchar2(10);
begin
-- Tra khoang giay tinh tu dau nam
b_c:=to_char(sysdate,'yy')||'00000000';
b_n:=to_number(b_c)+FKH_NAM_GIAY();
return to_char(b_n);
end;
/
create or replace function FKH_NGAY_LE(b_ngayD Date,b_ngayC Date,b_dk varchar2:='Y') return number
AS
    b_c date:=b_ngayD; b_d date:=b_ngayD; b_i1 number:=12;
begin
-- Dan - Tra phan ngay le con lai theo thang (M), nam (Y)
if b_dk<>'Y' then b_i1:=1; end if;
while b_ngayC>b_c loop
    b_d:=b_c; b_c:=add_months(b_c,b_i1);
end loop;
return FKH_KHO_NG(b_d,b_ngayC);
end;
/
create or replace function FKH_NGAY_CHAN(b_ngayD Date,b_ngayC Date,b_dk varchar2:='Y') return number
AS
    b_kq number:=0; b_c date:=b_ngayD; b_i1 number:=12;
begin
-- Dan - Tra so thang (M), nam (Y) chan
if b_dk<>'Y' then b_i1:=1; end if;
while b_ngayC>=b_c loop
    b_kq:=b_kq+1;
    b_c:=add_months(b_c,b_i1);
end loop;
return b_kq;
end;
/
create or replace function FKH_NGAY_CHANn(b_ngayDn number,b_ngayCn number,b_dk varchar2:='Y') return number
AS
    b_kq number:=0; b_c date; b_i1 number:=12;
	b_ngayD Date:=PKH_SO_CDT(b_ngayDn); b_ngayC Date:=PKH_SO_CDT(b_ngayCn);
begin
-- Dan - Tra so thang (M), nam (Y) chan
b_c:=b_ngayD;
if b_dk<>'Y' then b_i1:=1; end if;
while b_ngayC>=b_c loop
    b_kq:=b_kq+1;
    b_c:=add_months(b_c,b_i1);
end loop;
return b_kq;
end;
/
create or replace function FKH_NGAY_TYLE(b_ngayD Date,b_ngayC Date,b_dk varchar2:='Y') return number
AS
    b_kq number:=0; b_i1 number:=365;
begin
-- Dan - Tra he so thang (M), nam (Y)
if b_dk<>'Y' then b_i1:=30; end if;
b_kq:=FKH_NGAY_CHAN(b_ngayD,b_ngayC,b_dk)+round(FKH_NGAY_LE(b_ngayD,b_ngayC,b_dk)/b_i1,4);
return b_kq;
end;
/
create or replace procedure PKH_MANG(b_mang in out pht_type.a_var)
AS
	b_kt number;
begin
-- Dan - Xoa yeu to thua trong mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	if b_mang(b_lp) is null then b_mang.delete(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_MANGL(b_mang in out pht_type.a_lvar)
AS
	b_kt number;
begin
-- Dan - Xoa yeu to thua trong mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	if b_mang(b_lp) is null then b_mang.delete(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_MANG_U(b_mang in out pht_type.a_nvar)
AS
	b_kt number;
begin
-- Dan - Xoa yeu to thua trong mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	if b_mang(b_lp) is null then b_mang.delete(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_MANG_N(b_mang in out pht_type.a_num)
AS
	b_kt number;
begin
-- Dan - Xoa yeu to thua trong mang so
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	if b_mang(b_lp) is null or b_mang(b_lp)=0 then b_mang.delete(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_MANG_N0(b_mang in out pht_type.a_num)
AS
	b_kt number;
begin
-- Dan - Xoa yeu to thua trong mang so de lai so 0
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	if b_mang(b_lp) is null then b_mang.delete(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_MANG_D(b_mang in out pht_type.a_date)
AS
	b_kt number;
begin
-- Dan - Xoa yeu to thua trong mang date
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	if b_mang(b_lp) is null then b_mang.delete(b_lp); end if;
end loop;
end;
/
create or replace procedure PKH_MANG_XOA(b_mang in out pht_type.a_var)
AS
	b_kt number;
begin
-- Dan - Xoa mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	b_mang.delete(b_lp);
end loop;
end;
/
create or replace procedure PKH_MANG_XOAL(a_mang in out pht_type.a_lvar)
AS
	b_kt number;
begin
-- Dan - Xoa mang dai
b_kt:=a_mang.count;
for b_lp in reverse 1..b_kt loop
	a_mang.delete(b_lp);
end loop;
end;
/
create or replace procedure PKH_MANG_XOA_N(b_mang in out pht_type.a_num)
AS
	b_kt number;
begin
-- Dan - Xoa mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	b_mang.delete(b_lp);
end loop;
end;
/
create or replace procedure PKH_MANG_XOA_D(b_mang in out pht_type.a_date)
AS
	b_kt number;
begin
-- Dan - Xoa mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	b_mang.delete(b_lp);
end loop;
end;
/
create or replace procedure PKH_MANG_XOA_U(b_mang in out pht_type.a_nvar)
AS
	b_kt number;
begin
-- Dan - Xoa mang
b_kt:=b_mang.count;
for b_lp in reverse 1..b_kt loop
	b_mang.delete(b_lp);
end loop;
end;
/
create or replace procedure PKH_MANG_KD(b_mang in out pht_type.a_var,b_kt number:=0)
AS
begin
-- Dan - Khoi dong mang
if b_kt<>0 then
	for b_lp in 1..b_kt loop b_mang(b_lp):=''; end loop;
else
	b_mang(1):=''; b_mang.delete(1);
end if;
end;
/
create or replace procedure PKH_MANG_KDL(b_mang in out pht_type.a_lvar,b_kt number:=0)
AS
begin
-- Dan - Khoi dong mang
if b_kt<>0 then
	for b_lp in 1..b_kt loop b_mang(b_lp):=''; end loop;
else
	b_mang(1):=''; b_mang.delete(1);
end if;
end;
/
create or replace procedure PKH_MANG_KD_N(b_mang in out pht_type.a_num,b_kt number:=0)
AS
begin
-- Dan - Khoi dong mang so
if b_kt<>0 then
	for b_lp in 1..b_kt loop b_mang(b_lp):=0; end loop;
else
	b_mang(1):=0; b_mang.delete(1);
end if;
end;
/
create or replace procedure PKH_MANG_KD_D(b_mang in out pht_type.a_date,b_kt number:=0)
AS
begin
-- Dan - Khoi dong mang ngay
if b_kt<>0 then
	for b_lp in 1..b_kt loop b_mang(b_lp):=sysdate; end loop;
else
	b_mang(1):=sysdate; b_mang.delete(1);
end if;
end;
/
create or replace procedure PKH_MANG_KD_U(b_mang in out pht_type.a_nvar,b_kt number:=0)
AS
begin
-- Dan - Khoi dong mang
if b_kt<>0 then
	for b_lp in 1..b_kt loop b_mang(b_lp):=''; end loop;
else
	b_mang(1):=''; b_mang.delete(1);
end if;
end;
/
create or replace procedure PKH_MANG_XEP(a_mang in out pht_type.a_var)
AS
    b_kt number:=a_mang.count; b_i1 number; b_i2 number;
begin
-- Dan - Xep mang
for b_lp in 1..b_kt loop
    b_i1:=b_lp+1;
    if b_i1>b_kt then exit; end if;
    for b_lp1 in b_i1..b_kt loop
        if a_mang(b_lp)>a_mang(b_lp1) then
            b_i2:=a_mang(b_lp); a_mang(b_lp):=a_mang(b_lp1); a_mang(b_lp1):=b_i2;
        end if;
    end loop;
end loop;
end;
/
create or replace procedure PKH_MANG_XEPn(a_mang in out pht_type.a_num)
AS
    b_kt number:=a_mang.count; b_i1 number; b_i2 number;
begin
-- Dan - Xep mang
for b_lp in 1..b_kt loop
    b_i1:=b_lp+1;
    if b_i1>b_kt then exit; end if;
    for b_lp1 in b_i1..b_kt loop
        if a_mang(b_lp)>a_mang(b_lp1) then
            b_i2:=a_mang(b_lp); a_mang(b_lp):=a_mang(b_lp1); a_mang(b_lp1):=b_i2;
        end if;
    end loop;
end loop;
end;
/
create or replace procedure PKH_MANG_DUY(
    a_in pht_type.a_var,a_out out pht_type.a_var,b_xep varchar2:='K')
AS
    b_i1 number:=0;
begin
-- Dan - Tra mang duy nhat
PKH_MANG_KD(a_out);
for b_lp in 1..a_in.count loop
    if FKH_ARR_VTRI(a_out,a_in(b_lp))=0 then
        b_i1:=b_i1+1; a_out(b_i1):=a_in(b_lp);
    end if;
end loop;
if b_xep='C' then PKH_MANG_XEP(a_out); end if;
end;
/
create or replace procedure PKH_MANG_DUYn(
    a_in pht_type.a_num,a_out out pht_type.a_num,b_xep varchar2:='K')
AS
    b_i1 number:=0;
begin
-- Dan - Tao mang duy nhat
PKH_MANG_KD_N(a_out);
for b_lp in 1..a_in.count loop
    if FKH_ARR_VTRI_N(a_out,a_in(b_lp))=0 then
        b_i1:=b_i1+1; a_out(b_i1):=a_in(b_lp);
    end if;
end loop;
if b_xep='C' then PKH_MANG_XEPn(a_out); end if;
end;
/
create or replace function FKH_BO_UNICODE(b_chu nvarchar2,b_trang varchar2:='K',b_hoa varchar2:='K') return varchar2
As
	b_kq varchar2(32527):='';
begin
-- Son - Bo dau
if trim(b_chu) is not null then
	b_kq:=translate(b_chu,unistr(
		'\00E1\00E0\1EA3\00E3\1EA1\0103\1EAF\1EB1\1EB3\1EB5\1EB7\00E2\1EA5\1EA7\1EA9\1EAB\1EAD\0111\00E9\00E8\1EBB\1EBD\1EB9\00EA\1EBF\1EC1\1EC3\1EC5\1EC7\00ED\00EC\1EC9\0129\1ECB\00F3\00F2\1ECF\00F5\1ECD\00F4\1ED1\1ED3\1ED5\1ED7\1ED9\01A1\1EDB\1EDD\1EDF\1EE1\1EE3\00FA\00F9\1EE7\0169\1EE5\01B0\1EE9\1EEB\1EED\1EEF\1EF1\00FD\1EF3\1EF7\1EF9\1EF5\00C1\00C0\1EA2\00C3\1EA0\0102\1EAE\1EB0\1EB2\1EB4\1EB6\00C2\1EA4\1EA6\1EA8\1EAA\1EAC\0110\00C9\00C8\1EBA\1EBC\1EB8\00CA\1EBE\1EC0\1EC2\1EC4\1EC6\00CD\00CC\1EC8\0128\1ECA\00D3\00D2\1ECE\00D5\1ECC\00D4\1ED0\1ED2\1ED4\1ED6\1ED8\01A0\1EDA\1EDC\1EDE\1EE0\1EE2\00DA\00D9\1EE6\0168\1EE4\01AF\1EE8\1EEA\1EEC\1EEE\1EF0\00DD\1EF2\1EF6\1EF8\1EF4'),
		'aaaaaaaaaaaaaaaaadeeeeeeeeeeeiiiiiooooooooooooooooouuuuuuuuuuuyyyyyAAAAAAAAAAAAAAAAADEEEEEEEEEEEIIIIIOOOOOOOOOOOOOOOOOUUUUUUUUUUUYYYYY');
	b_kq:=REGEXP_REPLACE(b_kq,'[^' || CHR(1) || '-' || CHR(127) || ']','');
	if b_trang='C' then b_kq:=replace(b_kq,' ',''); end if;
	if b_hoa='C' then b_kq:=upper(b_kq); end if;
end if;
return b_kq;
end;
/
create or replace function FKH_TEN_KD(b_ten nvarchar2) return varchar2
AS
	a_ten pht_type.a_nvar;
begin
-- Dan - Tra phan ten va doi thanh khong dau chu hoa
PKH_CH_ARR_U(b_ten,a_ten,' ');
return upper(FKH_BO_UNICODE(a_ten(a_ten.count)));
end;
/
create or replace procedure PKH_CH_THEM(b_cu in out varchar2,b_moi varchar2,b_cach varchar2:=',')
AS
	b_kt number; b_so_id number; b_log boolean:=true; a_ch pht_type.a_var;
begin
-- Dan - Them vao chuoi neu chua co
PKH_CH_ARR(b_cu,a_ch,b_cach); b_kt:=a_ch.count;
for b_lp in 1..b_kt loop
	if a_ch(b_lp)=b_moi then b_log:=false; exit; end if;
end loop;
if b_log then b_kt:=b_kt+1; a_ch(b_kt):=b_moi; end if;
b_cu:=FKH_ARR_CH(a_ch,b_cach);
end;
/
create or replace procedure PKH_LKE(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_lenh nvarchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100); b_s varchar2(1000);
begin
-- Dan - Liet ke dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_s:=replace(b_lenh,'|','''');
open cs1 for b_s;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_LENH(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,b_qu varchar2,b_lenh varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,b_qu);
if b_loi is not null then raise PROGRAM_ERROR; end if;
execute immediate b_lenh;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_TEN(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_bang varchar2,b_truong varchar2,b_gtri varchar2,b_kq varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(200); b_i1 number; a_gtri pht_type.a_var; b_s nvarchar2(500); b_c varchar2(1):=',';
begin
-- Dan - Tim ten
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_bang='ht_ma_nsd' and b_truong='pas' then
    b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR;
end if;
if instr(b_gtri,';')>0 then b_c:=';'; end if;
PKH_CH_ARR(b_gtri,a_gtri,b_c);
if trim(b_kq) is null then
    for b_lp in 1..a_gtri.count loop
        b_i1:=FKH_HOI_CO(b_ma_dvi,b_bang,b_truong,a_gtri(b_lp));
        if b_lp=1 then b_ten:=to_char(b_i1); else b_ten:=b_ten||';'||to_char(b_i1); end if;
        if b_i1=0 then exit; end if;
    end loop;
else
    for b_lp in 1..a_gtri.count loop
        b_s:=FKH_HOI_TEN(b_ma_dvi,b_bang,b_truong,a_gtri(b_lp),b_kq);
        if b_lp=1 then b_ten:=b_s; else b_ten:=b_ten||';'||b_s; end if;
        if b_s='' then exit; end if;
    end loop;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FKH_HOI_CO(b_ma_dviN varchar2,b_bang varchar2,b_truong varchar2,b_gtri varchar2) return number
AS
	b_lenh varchar2(500); b_kq number; b_ma_dvi varchar2(20);
begin
-- Dan - Kiem tra ma co chua
if b_bang<>'ht_ma_dvi' then
	b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,b_bang);
	b_lenh:='select count(*) from '||b_bang||' where ma_dvi= :ma_dvi and '||b_truong||'= :ma';
	execute immediate b_lenh into b_kq using b_ma_dvi,b_gtri;
else 
	b_lenh:='select count(*) from ht_ma_dvi where '||b_truong||'= :ma';
	execute immediate b_lenh into b_kq using b_gtri;
end if;
return b_kq;
end;
/
create or replace function FKH_HOI_TEN(b_ma_dviN varchar2,b_bang varchar2,b_truong varchar2,b_gtri varchar2,b_kq varchar2) return nvarchar2
AS
    b_lenh varchar2(500); b_ten nvarchar2(500); b_ma_dvi varchar2(20);
begin
-- Dan - Kiem tra ma co chua
if b_bang='bh_dl_ma_kh' then
    b_lenh:='select min('||b_kq||') from '||b_bang||' where '||b_truong||'= :ma';
    execute immediate b_lenh into b_ten using b_gtri;
elsif b_bang<>'ht_ma_dvi' then
    b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,b_bang);
    b_lenh:='select min('||b_kq||') from '||b_bang||' where ma_dvi= :ma_dvi and '||b_truong||'= :ma';
    execute immediate b_lenh into b_ten using b_ma_dvi,b_gtri;
else 
    b_lenh:='select min('||b_kq||') from ht_ma_dvi where '||b_truong||'= :ma';
    execute immediate b_lenh into b_ten using b_gtri;
end if;
return b_ten;
end;
/
create or replace procedure PKH_HOI_LIST_SL(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_tu_n number,b_den_n number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_tu number:=b_tu_n; b_den number:=b_den_n; b_ma_dvi varchar2(20):=b_ma_dviN;
begin
-- Dan - Liet ke dong tu, den
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
	PKH_LKE_TRANG(b_dong,b_tu,b_den);
	b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||') sott from '||a_ch(1)||
		' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where sott between :tu and :den';
	open cs1 for b_lenh using b_ma_dvi,b_tu,b_den;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||') sott from '||a_ch(1)||
        ' where idvung= :idvung order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_idvung,b_tu,b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LISTt(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_maN nvarchar2,b_trangKt number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; b_i1 number;
	b_ma varchar2(50); b_ten nvarchar2(100); b_min nvarchar2(100); b_ma_dvi varchar2(20);
	a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if b_maN is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
b_ma:=FKH_BO_UNICODE(b_maN)||'%'; b_ten:='%'||b_maN||'%';
if a_ch(1)<>'ht_ma_dvi' then
	b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where ma_dvi= :ma_dvi and ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten)';
	execute immediate b_lenh into b_i1,b_min using b_ma_dvi,b_ma,b_ten;
else
	b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where idvung= :idvung and ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten)';
	execute immediate b_lenh into b_i1,b_min using b_idvung,b_ma,b_ten;
end if;
if b_i1>b_trangKt or (b_i1=1 and upper(b_min)=b_maN) then
	open cs1 for select '' ma,'' ten from dual;
else
	if a_ch(1)<>'ht_ma_dvi' then
		b_lenh:='select '||a_ch(2)||' ma,'||a_ch(3)||' ten from '||a_ch(1)||' where ma_dvi= :ma_dvi and ('||
			a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten) order by '||a_ch(2);
		open cs1 for b_lenh using b_ma_dvi,b_ma,b_ten;
	else
		b_lenh:='select '||a_ch(2)||' ma,'||a_ch(3)||' ten from '||a_ch(1)||' where idvung= :idvung and ('||
			a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten) order by '||a_ch(2);
		open cs1 for b_lenh using b_idvung,b_ma,b_ten;
	end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_MA(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_maN varchar2,b_trangkt number,b_trang out number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_tu number; b_den number; b_ma_dvi varchar2(20); b_ma varchar2(50);
begin
-- Dan - Liet ke dong tu, den
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if b_maN is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
b_ma:=FKH_BO_UNICODE(b_maN);
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where '||a_ch(2)||'>= :ma';
    execute immediate b_lenh into b_tu using b_ma_dvi,b_ma;
    if b_tu=0 then b_tu:=b_dong; end if;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_ma_dvi,b_tu,b_den;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where '||a_ch(2)||'>= :ma';
    execute immediate b_lenh into b_tu using b_idvung,b_ma;
    if b_tu=0 then b_tu:=b_dong; end if;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_idvung,b_tu,b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_MAt(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_maN nvarchar2,b_trangkt number,b_trang out number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_tu number; b_den number; b_ma_dvi varchar2(20);
    b_ma varchar2(50); b_ten nvarchar2(500); b_maM varchar2(50); b_tenM nvarchar2(500);
begin
-- Dan - Liet ke dong tu, den gan dung theo ma va ten
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if b_maN is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma:=FKH_BO_UNICODE(b_maN)||'%'; b_ten:='%'||b_maN||'%';
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*),min('||a_ch(2)||'),min('||a_ch(3)||') from '||a_ch(1)||
		' where ma_dvi= :ma_dvi and '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
    execute immediate b_lenh into b_dong,b_maM,b_tenM using b_ma_dvi,b_ma,b_ten;
	if b_dong=1 and (b_maM=b_maN or b_tenM=b_maN) then
		PKH_HOI_LIST_MA(b_ma_dviN,b_nsd,b_pas,b_ktra,b_maM,b_trangkt,b_trang,b_dong,cs1);
	else
		b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
			') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
		execute immediate b_lenh into b_tu using b_ma_dvi,b_ma,b_ten;
		PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
		b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
			') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||
			') where ma like :ma or upper(ten) like :ten and sott between :tu and :den';
	    open cs1 for b_lenh using b_ma_dvi,b_ma,b_ten,b_tu,b_den;
	end if;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung and '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
    execute immediate b_lenh into b_dong using b_idvung,b_ma,b_ten;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
    execute immediate b_lenh into b_tu using b_idvung,b_ma,b_ten;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||
        ') where ma like :ma or upper(ten) like :ten and sott between :tu and :den';
    open cs1 for b_lenh using b_idvung,b_ma,b_ten,b_tu,b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_VTRI(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_xep number,b_ktra varchar2,b_ma varchar2,b_vtri number,b_tra out nvarchar2)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_dong number; b_tu number; b_ten nvarchar2(100); b_ma_dvi varchar2(20);
begin
-- Dan - Tra ma,ten tuong ung ma cu va vi tri moi
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    if trim(b_ma) is null then b_tu:=1;
    else 
        b_lenh:='select nvl(min(sott),1) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where '||a_ch(b_xep)||'= :ma';
        execute immediate b_lenh into b_tu using b_ma_dvi,b_ma;
        b_tu:=b_tu+b_vtri;
        if b_tu<1 then b_tu:=b_dong;
        elsif b_tu>b_dong then b_tu:=1;
        end if;
    end if;
    b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where '||a_ch(b_xep)||'= :ma and sott= :tu';
    execute immediate b_lenh into b_tra,b_ten using b_ma_dvi,b_ma,b_tu;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    if trim(b_ma) is null then b_tu:=1;
    else 
        b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where '||a_ch(b_xep)||'= :ma';
        execute immediate b_lenh into b_tu using b_idvung,b_ma;
        b_tu:=b_tu+b_vtri;
        if b_tu<1 then b_tu:=b_dong;
        elsif b_tu>b_dong then b_tu:=1;
        end if;
    end if;
    b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where '||a_ch(b_xep)||'= :ma and sott= :tu';
    execute immediate b_lenh into b_tra,b_ten using b_idvung,b_ma,b_tu;
end if;
b_tra:=b_tra||'{'||b_ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_DAU(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_xep number,b_ktra varchar2,b_ma varchar2,b_tim varchar2,b_tra out nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_idvung number; b_ma_dvi varchar2(20);
    b_dong number; b_tu number; b_ten nvarchar2(1000); a_ch pht_type.a_var;
begin
-- Dan - Tra ma,ten tuong ung ma cu va ky tu dau can tim tiep
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch); b_tra:='';
a_ch(1):=lower(a_ch(1));
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    if trim(b_ma) is null then
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
        execute immediate b_lenh into b_tu using b_ma_dvi,b_tim;        
    else 
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where '||a_ch(2)||'= :ma';
        execute immediate b_lenh into b_i1 using b_ma_dvi,b_ma;
        if b_i1=0 then
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_ma_dvi,b_tim;        
        else
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(3)||') where sott> :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_ma_dvi,b_i1,b_tim;
            if b_tu=0 then
                b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                    ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where sott< :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
                execute immediate b_lenh into b_tu using b_ma_dvi,b_i1,b_tim;
            end if;
        end if;
    end if;
    if b_tu<>0 then
        b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where sott= :tu';
        execute immediate b_lenh into b_tra,b_ten using b_ma_dvi,b_tu;
    end if;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    if trim(b_ma) is null then
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
        execute immediate b_lenh into b_tu using b_idvung,b_tim;        
    else 
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where '||a_ch(2)||'= :ma';
        execute immediate b_lenh into b_i1 using b_idvung,b_ma;
        if b_i1=0 then
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_idvung,b_tim;        
        else
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(3)||') where sott> :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_idvung,b_i1,b_tim;
            if b_tu=0 then
                b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                    ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where sott< :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
                execute immediate b_lenh into b_tu using b_idvung,b_i1,b_tim;
            end if;
        end if;
    end if;
    if b_tu<>0 then
        b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where sott= :tu';
        execute immediate b_lenh into b_tra,b_ten using b_idvung,b_tu;
    end if;
end if;
if b_tra is not null then b_tra:=b_tra||'{'||b_ten; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** TRAO DOI ***/
create or replace procedure PKH_TRDOI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi_n varchar2,b_so_id number,b_bt number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_dvi varchar2(20);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null or b_bt is null then b_loi:='loi:Nhap don vi, so thu tu:loi'; raise PROGRAM_ERROR; end if;
if trim(b_dvi_n) is null then b_dvi:=b_ma_dvi; else b_dvi:=b_dvi_n; end if;
open cs_lke for select FHT_MA_NSD_TEN(ma_dvi_nh,nsd) nsd,nd,bt,gchu,to_char(ngay_nh,'mi:hh dd/mm') ngay
    from kh_trdoi where ma_dvi=b_dvi and so_id=b_so_id and bt>b_bt order by bt;
exception when PROGRAM_ERROR then raise_application_error(-20105, b_loi);
end;
/
create or replace procedure PKH_TRDOI_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi_n varchar2,b_so_id number,b_nd nvarchar2,b_gchu varchar2:='')
AS
	b_loi varchar2(100); b_idvung number; b_bt number; b_dvi varchar2(20);
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PHT_ID_MOI(b_bt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_dvi_n) is null then b_dvi:=b_ma_dvi; else b_dvi:=b_dvi_n; end if;
b_loi:='loi:Loi Table KH_TRDOI:loi';
insert into kh_trdoi values(b_dvi,b_so_id,b_bt,b_nd,b_ma_dvi,b_gchu,b_nsd,sysdate,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FKH_KSOAT_TRA
    (b_ma_dvi varchar2,b_so_id varchar2) return varchar2
AS
    b_kq varchar2(200);
begin
select min(ksoat) into b_kq from kh_ksoat where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FKH_SO_TT_NAM
    (b_ma_dvi varchar2,b_loai varchar2,b_nv varchar2,b_nam number,b_stt out number,b_loi out varchar2)
AS
begin
-- Dan - Tra so thu tu theo nghiep vu, nam
b_loi:='loi:Loi lay so thu tu:loi';
select count(*) into b_stt from kh_so_tt_nam where ma_dvi=b_ma_dvi and loai=b_loai and nv=b_nv and nam=b_nam;
if b_stt=0 then
    b_stt:=1;
    insert into kh_so_tt_nam values(b_ma_dvi,b_loai,b_nv,b_nam,1);
else
    select stt into b_stt from kh_so_tt_nam where ma_dvi=b_ma_dvi and loai=b_loai and nv=b_nv and nam=b_nam for update wait 10;
	if sql%rowcount<>0 then
		b_stt:=b_stt+1;
		update kh_so_tt_nam set stt=b_stt where ma_dvi=b_ma_dvi and loai=b_loai and nv=b_nv and nam=b_nam;
	end if;
end if;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure FKH_TAO_SO_NAM
    (b_ma_dvi varchar2,b_loai varchar2,b_nv varchar2,b_nam number,b_stt out varchar2,b_loi out varchar2)
AS
    b_so number;
begin
-- Dan - Tao so thu tu theo nghiep vu, nam
FKH_SO_TT_NAM(b_ma_dvi,b_loai,b_nv,b_nam,b_so,b_loi);
if b_loi is not null then return; end if;
if trim(b_loai) is not null then b_stt:='/'||b_loai; else b_stt:=''; end if;
if trim(b_nv) is not null then b_stt:=b_stt||'/'||b_nv; end if;
b_stt:=to_char(b_so)||b_stt||'/'||to_char(b_nam);
end;
/
create or replace procedure PKH_CAY
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ham varchar2,b_cs out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_bien varchar2(1000);
begin
-- Dan - Liet ke dang cay
delete kh_cay; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_i1:=instr(b_ham,'#');
if b_i1=0 then
    b_lenh:='begin '||b_ham||'(:ma_dvi,:ma); end;';
    EXECUTE IMMEDIATE b_lenh using b_ma_dvi,b_ma;
else
    b_bien:=substr(b_ham,b_i1+1);
    b_lenh:='begin '||substr(b_ham,1,b_i1-1)||'(:ma_dvi,:ma,:bien); end;';
    EXECUTE IMMEDIATE b_lenh using b_ma_dvi,b_ma,b_bien;    
end if;
open b_cs for select * from kh_cay order by ten;
delete kh_cay; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FKH_KHO_KTRAs(
    b_gtri varchar2,b_tu_dk varchar2,b_tu varchar2,
    b_den_dk varchar2,b_den varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_lenh nvarchar2(1000); b_co int;
    a_tu pht_type.a_var;
begin
-- Dan - Ktra thuoc khoang loai chuoi
PKH_CH_ARR(b_tu,a_tu);
if b_tu_dk='~' then
    for b_lp in 1..a_tu.count loop
        if instr(a_tu(b_lp),b_gtri)=1 then b_kq:='C'; exit; end if;
    end loop;
elsif b_tu_dk in('>','>=') and b_den_dk<>' ' then
    b_lenh:='begin if :gtri1 '||b_tu_dk||' :tu and :gtri2 '||b_den_dk||' :den then :co:=1; end if; end;';
    for b_lp in 1..a_tu.count loop
        EXECUTE IMMEDIATE b_lenh using b_gtri,a_tu(b_lp),b_gtri,b_den,out b_co;
        if nvl(b_co,0)=1 then b_kq:='C'; exit; end if;
    end loop;
elsif b_tu_dk=' ' and b_den_dk<>' ' then
    b_lenh:='begin if :gtri'||b_den_dk||':den then :co:=1; end if; end;';
    EXECUTE IMMEDIATE b_lenh using b_gtri,b_den,out b_co;
    if nvl(b_co,0)=1 then b_kq:='C'; end if;
elsif b_tu_dk in ('=','<>','<','<=','>','>=') then
    b_lenh:='begin if :gtri'||b_tu_dk||':tu then :co:=1; end if; end;';
    for b_lp in 1..a_tu.count loop
        EXECUTE IMMEDIATE b_lenh using b_gtri,a_tu(b_lp),out b_co;
        if nvl(b_co,0)=1 then b_kq:='C'; exit; end if;
    end loop;
end if;
return b_kq;
exception when others then return 'K';
end;
/
create or replace function FKH_KHO_KTRAn(
    b_gtri number,b_tu_dk varchar2,b_tu varchar2,
    b_den_dk varchar2,b_den number) return varchar2
AS
    b_kq varchar2(1):='K'; b_lenh nvarchar2(1000); b_co int;
    a_tuS pht_type.a_var; a_tu pht_type.a_num;
begin
-- Dan - Ktra thuoc khoang loai chuoi
PKH_CH_ARR(b_tu,a_tuS);
for b_lp in 1..a_tuS.count loop
    a_tu(b_lp):=PKH_LOC_CHU_SO(a_tuS(b_lp),'T');
end loop;
if b_tu_dk in('>','>=') and b_den_dk<>' ' then
    b_lenh:='begin if :gtri1 '||b_tu_dk||' :tu and :gtri2 '||b_den_dk||' :den then :co:=1; end if; end;';
    for b_lp in 1..a_tu.count loop
        EXECUTE IMMEDIATE b_lenh using b_gtri,a_tu(b_lp),b_gtri,b_den,out b_co;
        if nvl(b_co,0)=1 then b_kq:='C'; exit; end if;
    end loop;
elsif b_tu_dk=' ' and b_den_dk<>' ' then
    b_lenh:='begin if :gtri'||b_den_dk||':den then :co:=1; end if; end;';
    EXECUTE IMMEDIATE b_lenh using b_gtri,b_den,out b_co;
    if nvl(b_co,0)=1 then b_kq:='C'; end if;
elsif b_tu_dk in ('=','<>','<','<=','>','>=') then
    b_lenh:='begin if :gtri'||b_tu_dk||':tu then :co:=1; end if; end;';
    for b_lp in 1..a_tu.count loop
        EXECUTE IMMEDIATE b_lenh using b_gtri,a_tu(b_lp),out b_co;
        if nvl(b_co,0)=1 then b_kq:='C'; exit; end if;
    end loop;
end if;
return b_kq;
exception when others then return 'K';
end;
/
create or replace function FKH_KHO_KTRA(
    b_gtri varchar2,b_loai varchar2,b_tu_dk varchar2,b_tu_nd varchar2,
    b_den_dk varchar2,b_den_nd varchar2) return varchar2
AS
    b_kq varchar2(1); b_gtriN number; b_tuN number; b_denN number;
    b_gtriS varchar2(200); b_tuS varchar2(500); b_denS varchar2(500);
begin
-- Dan - Ktra thuoc khoang
b_kq:='K';
b_gtriS:=upper(nvl(trim(b_gtri),' ')); b_tuS:=upper(nvl(trim(b_tu_nd),' ')); b_denS:=upper(nvl(trim(b_den_nd),' '));
if b_loai in ('C','H') then
    b_kq:=FKH_KHO_KTRAs(b_gtriS,b_tu_dk,b_tuS,b_den_dk,b_denS);
else
    if b_loai='S' then
        b_denN:=PKH_LOC_CHU_SO(b_denS,'T');
    else
        if b_tuS<>' ' then b_tuS:=to_char(PKH_CNG_SO(b_tuS)); end if;
        if b_denS=' ' then b_denN:=0; else b_denN:=PKH_CNG_SO(b_denS); end if;
    end if;
    b_gtriN:=PKH_LOC_CHU_SO(b_gtriS,'T');
    b_kq:=FKH_KHO_KTRAn(b_gtriN,b_tu_dk,b_tuS,b_den_dk,b_denN);
end if;
return b_kq;
exception when others then return 'K';
end;
/
create or replace function PKH_NGAY_LUI_TEST
    (b_ma_dvi varchar2,b_ngay number,b_ngay_cap number,b_nv varchar2) return varchar2
AS
    b_loi varchar2(100); b_d1 number; b_n1 number;
begin
if b_ngay is null then return 'loi:Nhap ngay xu ly nghiep vu#'||b_nv||':loi'; end if;
select max(ngay),count(*) into b_d1,b_n1 from bh_nv_ngay where nv=b_nv;
if b_n1=0 then return ''; end if;
if b_ngay - b_ngay_cap >  b_d1 then return 'loi:Vuot qua han nhap lui #'||b_nv||' ngay#'||PKH_SO_CNG(b_ngay - b_d1)||':loi'; end if;
return '';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function PKH_MA_HAN_TEST
    (b_ma_dvi varchar2,b_ngay number,b_md varchar2,b_nv varchar2,b_bc varchar2:='') return varchar2
AS
    b_loi varchar2(100); b_d1 number; b_n1 number; b_ma_ct varchar2(10);
begin
if b_ngay is null then return 'loi:Nhap ngay xu ly nghiep vu#'||b_nv||':loi'; end if;
select nvl(min(ma_ct),' ') into b_ma_ct from ht_ma_dvi where ma=b_ma_dvi;
select max(ngay),count(*) into b_d1,b_n1 from kh_ma_han where md=b_md and ma_cd=b_ma_dvi and nv=b_nv;
if b_n1=0 then return ''; end if;
if b_n1=0 and b_bc is not null then
    select max(ngay),count(*) into b_d1,b_n1 from kh_ma_han where md=b_md and ma_cd=b_ma_dvi and nv=b_bc;
end if;
if b_n1=0 then
    select max(ngay),count(*) into b_d1,b_n1 from kh_ma_han where md=b_md and ma_cd=b_ma_dvi and nv='AL';
end if;
if b_n1=0 and b_ma_ct<>' ' then
    if b_n1=0 then
        select max(ngay),count(*) into b_d1,b_n1 from kh_ma_han where md=b_md and ma_cd=b_ma_ct and nv=b_nv;
    end if;
    if b_n1=0 and b_bc is not null then
        select max(ngay),count(*) into b_d1,b_n1 from kh_ma_han where md=b_md and ma_cd=b_ma_ct and nv=b_bc;
    end if;
    if b_n1=0 then
        select max(ngay),count(*) into b_d1,b_n1 from kh_ma_han where md=b_md and ma_cd=b_ma_ct and nv='AL';
    end if;
end if;
if b_n1=0 then return ''; end if;
b_n1:=b_d1;
if b_n1>=b_ngay then return 'loi:Han thay doi#'||b_nv||' ngay#'||to_char(to_date(b_d1, 'YYYYMMDD'), 'DD/MM/YYYY')||':loi'; end if;
return '';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTT_TUNG_QD
	(b_ma_dvi varchar2,b_ngay number,b_ma_nt_v varchar2,b_tien_v number,b_ma_nt_r varchar2) return number
AS
	b_noite varchar2(5); b_tg_v number; b_tg_r number; b_kq number; b_le number;
begin
-- Dan - Doi ra loai tien tuong ung
if b_ma_nt_v=b_ma_nt_r then b_kq:=b_tien_v;
else
	b_noite:=FTT_TRA_NOITE(b_ma_dvi);
	if b_ma_nt_v=b_noite then b_tg_v:=1; else b_tg_v:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt_v); end if;
	if b_ma_nt_r=b_noite then b_tg_r:=1; b_le:=0; else b_tg_r:=FTT_TRA_TGTT(b_ma_dvi,b_ngay,b_ma_nt_r); b_le:=2; end if;
	b_kq:=round(b_tien_v*b_tg_v/b_tg_r,b_le);
end if;
return b_kq;
end;
/
create or replace function FTT_SC_QD
	(b_ma_dvi varchar2,b_ma_nt varchar2,b_ma_nh varchar2,b_ma_tk varchar2,b_ngay_ht number,b_tien number) return number
AS
	b_i1 number; b_ton number:=0; b_ton_qd number; b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
select nvl(max(ngay_ht),0) into b_i1 from tt_sc where
	ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht<=b_ngay_ht;
if b_i1=0 then return b_tien_qd; end if;
select ton,ton_qd into b_ton,b_ton_qd from tt_sc where
	ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht=b_i1;
if b_ton<=b_tien then
	b_tien_qd:=b_ton_qd;
else	b_tien_qd:=round(b_ton_qd*b_tien/b_ton,0);
end if;
return b_tien_qd;
end;
/
create or replace function FBH_KHO_KNGAY(b_nd varchar2) return number
as
    b_kq number:=0; b_kieu varchar2(1); b_s varchar2(100);
begin
--nampb: chuyen dang D,M,Y -> ngay. Khong khai bao mac dinh la Y
b_s:=upper(trim(b_nd));
if instr(b_s, '|') > 0 then
    b_kieu:=substr(b_s,1,instr(b_s, '|') - 1);
    b_kq:=PKH_LOC_CHU_SO(b_s, 'F', 'F');
else
    b_kieu:='Y';
    b_kq:=PKH_LOC_CHU_SO(b_s, 'F', 'F');
end if;
if b_kieu='D' then
    return b_kq;
elsif b_kieu='M' then
    return b_kq * 30;
else
    return b_kq* 365;
end if;
exception when others then return 0; 
end;
