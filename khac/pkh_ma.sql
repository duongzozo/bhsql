/*** Liet ke ty gia ***/
create or replace procedure PTT_TGTT_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_tu_n number,b_den_n number,b_dong out number,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Nga - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tt_tgtt where ma_dvi=b_ma_dvi;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs1 for select * from (select ma,ngay,ngay ngay_so,ty_gia,nsd,row_number() over (order by ma,ngay) sott from tt_tgtt
	where ma_dvi=b_ma_dvi order by ma,ngay) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TGTT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_nt varchar2,b_ngay date,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Nga - Xem ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_nt is null then b_loi:='loi:Nhap ma nguyen te:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tt_tgtt where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,ngay,row_number() over (order by ma,ngay) sott
    from tt_tgtt where ma_dvi=b_ma_dvi order by ma,ngay) where ma>=b_ma_nt and ngay>=b_ngay;
--b_loi:='loi:'||b_tu;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
--b_loi:=b_loi||':'||b_tu||':'||b_trang||':loi'; raise PROGRAM_ERROR;
open cs_lke for select * from (select ma,ngay,ngay ngay_so,ty_gia,nsd,row_number() over (order by ma,ngay) sott from tt_tgtt
    where ma_dvi=b_ma_dvi order by ma,ngay) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Liet ke ma hang ***/
create or replace procedure PBH_HH_HANG_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); 
begin
-- Nga - Xem ma hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from bh_hh_ma_hang where ma_dvi= b_ma_dvi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FKH_MA_KVUC_TC(b_ma_dviN varchar2,b_ma varchar2) return varchar2
as
    b_kq varchar2(1):='C'; b_i1 number; b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Xac dinh TC
select count(*) into b_i1 from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if b_i1<>0 then b_kq:='T'; end if;
return b_kq;
end;
/
create or replace function FKH_MA_KVUC_CAP(b_ma_dviN varchar2,b_ma varchar2) return number
as
    b_kq number:=0; b_maM varchar(30); b_maC varchar(30);
    b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Xac dinh cap
b_maC:=b_ma;
while trim(b_maC) is not null loop
    b_kq:=b_kq+1;
    select min(ma_ct) into b_maM from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_maC;
    b_maC:=b_maM;
end loop;
return b_kq;
end;
/
create or replace procedure PTT_MA_NT_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type,b_ma varchar2:='')
AS
begin
-- Dan - Xem ma ngoai te
if b_ma is null then
	open cs1 for select * from tt_ma_nt where ma_dvi=b_ma_dvi order by ma;
else	open cs1 for select * from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
end;
/
create or replace procedure PTT_MA_NT_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
	b_ten nvarchar2,b_ten_xu nvarchar2,b_tc varchar2)
AS
	b_loi varchar2(100); b_c5 varchar2(5); b_idvung number;
begin
-- Dan - Nhap ma ngoai te
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma ngoai te:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc not in ('C','K') then
	b_loi:='loi:Noi te: C-Co; K-Khong:loi'; raise PROGRAM_ERROR;
end if;
if b_tc='C' then
	select max(ma) into b_c5 from tt_ma_nt where ma_dvi=b_ma_dvi and tc='C';
	if b_c5 is not null and b_c5<>b_ma then b_loi:='loi:Da co noi te#'||b_c5||':loi'; raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi Table TT_MA_NT:loi';
delete tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma;
insert into tt_ma_nt values(b_ma_dvi,b_ma,b_ten,b_ten_xu,b_tc,b_nsd,b_idvung);
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_MA_NT_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa ma ngoai te
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma ngoai te:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table TT_MA_NT:loi';
delete tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;