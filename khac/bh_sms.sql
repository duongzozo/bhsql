create or replace procedure PBH_SMS_GCN
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_seri varchar2,b_so_n number,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_i1 number; b_i2 number; b_ten nvarchar2(100); b_do_dai number:=10; b_so_to number:=10;
	b_dvi varchar2(10); b_so_id number; b_gcn varchar2(50); b_so varchar2(50); b_tien number; b_ttoan number;
begin
-- Dan - Liet ke GCN
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SM','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null or b_so_n is null then b_loi:='loi:Nhap loai GCN, so bat dau:loi'; raise PROGRAM_ERROR; end if;
PHD_MA_TTIN(b_ma_dvi,b_ma,b_ten,b_do_dai,b_so_to,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_i2:=b_so_n;
for b_lp in 1..b_so_to loop
	b_so:='00000000000000000000'||trim(to_char(b_i2));
	b_i1:=length(b_so);
	if b_i1>b_do_dai then b_i1:=b_i1-b_do_dai+1; else b_i1:=1; end if;
	b_so:=substr(b_so,b_i1);
	b_gcn:=FKH_GHEP_SERI(b_ma,b_seri,b_so,' ');
	select min(ma_dvi),min(so_id) into b_dvi,b_so_id from bh_hd_goc where so_hd=b_gcn;
	if b_ma_dvi is null then
		insert into temp_1(n10,n1) values(b_lp,b_i2);
	else
		select sum(tien),sum(ttoan) into b_tien,b_ttoan from bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
		insert into temp_1(n10,n1,n2,n3) values(b_lp,b_i2,b_tien,b_ttoan);
	end if;
	b_i2:=b_i2+1;
end loop;
open cs_lke for select n10 tt,n1 so,n2 tien,n3 phi from temp_1 order by n10;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SMS_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
	b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SM','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_sms_nh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc;
if b_den_n=1000000 then
	b_den:=b_dong; b_tu:=b_dong-b_tu_n;
end if;
open cs_lke for select * from (select so_id,ngay,ma,seri,so,row_number() over (order by ngay,ma,seri,so) sott
	from bh_sms_nh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc order by ngay,ma,seri,so) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SMS_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_ngd date; b_ngc date;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SM','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
open cs_lke for select * from bh_sms_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SMS_NH(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_ngay number,b_ngayd varchar2,b_ngayc varchar2,b_trangkt number,
	a_ma pht_type.a_var,a_seri pht_type.a_var,a_so pht_type.a_num,a_bien pht_type.a_var,a_tien pht_type.a_num,
	a_phi pht_type.a_num,a_ngay pht_type.a_var,a_phone pht_type.a_var,a_ttrang pht_type.a_var,
	b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_i1 number; b_so_id number; b_so_id_d number; b_ma_dvi_g varchar2(10);
	b_loai_bp varchar2(2); b_phong varchar2(10); b_ma_cb varchar2(10); b_ma_dl varchar2(20);
	b_so varchar2(50); b_gcn varchar2(50); b_ten nvarchar2(100); b_do_dai number:=10; b_so_to number:=10;
	b_tu number; b_den number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SM','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null or b_ngay=0 then b_loi:='loi:Nhap ngay xu ly:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
	if a_ma(b_lp) is null or a_seri(b_lp) is null or a_so(b_lp) is null
		or a_ttrang(b_lp) is null or a_ttrang(b_lp) not in('D','H','M') then
		b_loi:='loi:Sai so lieu dong '||trim(to_char(b_lp))||':loi'; raise PROGRAM_ERROR;
	end if;
end loop;
for b_lp in 1..a_ma.count loop
	if b_lp=1 or a_ma(b_lp)<>a_ma(b_lp-1) then
		PHD_MA_TTIN(b_ma_dvi,a_ma(b_lp),b_ten,b_do_dai,b_so_to,b_loi);
		if b_loi is not null then raise PROGRAM_ERROR; end if;
	end if;
	b_so:='00000000000000000000'||trim(to_char(a_so(b_lp)));
	b_i1:=length(b_so);
	if b_i1>b_do_dai then b_i1:=b_i1-b_do_dai+1; else b_i1:=1; end if;
	b_so:=substr(b_so,b_i1);
	b_gcn:=FKH_GHEP_SERI(a_ma(b_lp),a_seri(b_lp),b_so,' ');
	select count(*) into b_i1 from bh_sms_nh where gcn=b_gcn;
	if b_i1<>0 then b_loi:='loi:Da nhap GCN '||b_gcn||':loi'; raise PROGRAM_ERROR; end if;
	b_ma_dvi_g:=' '; b_phong:=' '; b_ma_cb:=' '; b_ma_dl:=' ';
	PHT_ID_MOI(b_so_id,b_loi);
	if b_loi is not null then raise PROGRAM_ERROR; end if;
	if b_lp=1 then b_so_id_d:=b_so_id; end if;
	if a_ttrang(b_lp)='D' then
		PHD_TON_GIU(a_ma(b_lp),a_seri(b_lp),a_so(b_lp),b_ma_dvi_g,b_loai_bp,b_phong);
		if b_ma_dvi_g is null then
			select count(*) into b_i1 from bh_hd_goc where so_hd=b_gcn;
			if b_i1=0 then b_loi:='loi:Khong thay GCN '||b_gcn||' dong '||trim(to_char(b_lp))||':loi'; raise PROGRAM_ERROR; end if;
		else
			if b_loai_bp='D' then b_phong:=' ';
			elsif b_loai_bp='C' then
				b_ma_cb:=b_phong; b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi_g,b_ma_cb);
			elsif b_loai_bp='L' then
				b_ma_dl:=b_phong; b_phong:=nvl(FBH_DL_MA_KH_PHONG(b_ma_dvi_g,b_ma_dl),' ');
			end if;
			insert into bh_sms_ton values(b_ma_dvi_g,b_so_id,b_ma_dvi_g,b_gcn,b_phong,b_ma_cb,b_ma_dl);
		end if;
	end if;
	insert into bh_sms_nh values(b_ma_dvi,b_so_id,b_ngay,a_ma(b_lp),a_seri(b_lp),a_so(b_lp),a_bien(b_lp),a_tien(b_lp),
		a_phi(b_lp),a_ngay(b_lp),a_phone(b_lp),a_ttrang(b_lp),b_ma_dvi_g,b_gcn,b_phong,b_ma_cb,b_ma_dl,b_nsd);	
end loop;
select count(*) into b_dong from bh_sms_nh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc;
select nvl(min(sott),b_dong) into b_tu from (select ngay,ma,seri,so,row_number() over (order by ngay,ma,seri,so) sott
	from bh_sms_nh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc order by ngay,ma,seri,so);
b_trang:=round(b_tu/b_trangkt+.5,0);
b_tu:=(b_trang-1)*b_trangkt+1; b_den:=b_tu+b_trangkt-1;
open cs_lke for select * from (select so_id,ngay,ma,seri,so,row_number() over (order by ngay,ma,seri,so) sott
	from bh_sms_nh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc order by ngay,ma,seri,so) where sott between b_tu and b_den;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SMS_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','SM','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
delete bh_sms_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_sms_nh where ma_dvi=b_ma_dvi and so_id=b_so_id;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SMS_HD_XOA(b_gcn varchar2,b_loi out varchar2)
AS
	b_ma_dvi varchar2(10); b_so_id number; b_ma_dvi_g varchar2(10); b_phong varchar2(10); b_ma_cb varchar2(10); b_ma_dl varchar2(20);
begin
-- Dan - Xoa tu hop dong
b_loi:='';
select ma_dvi,so_id,ma_dvi_g,phong,ma_cb,ma_dl into b_ma_dvi,b_so_id,b_ma_dvi_g,b_phong,b_ma_cb,b_ma_dl from bh_sms_nh where gcn=b_gcn;
if trim(b_ma_dvi_g) is not null then
	b_loi:='loi:Loi Table BH_SMS_TON:loi';
	insert into bh_sms_ton values(b_ma_dvi_g,b_so_id,b_ma_dvi_g,b_gcn,b_phong,b_ma_cb,b_ma_dl);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;

/
