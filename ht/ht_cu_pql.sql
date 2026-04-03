-- CHUCLH: KT CU DANG DUNG
-- MA CAN BO CU
create or replace procedure PHT_MA_CB_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem he thong ma can bo
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
	select count(*) into b_dong from ht_ma_cb where ma_dvi=b_ma_dvi;
	PKH_LKE_TRANG(b_dong,b_tu,b_den);
	open cs_lke for select * from (select phong,ma,ten,nsd,row_number() over (order by phong,ma) sott from ht_ma_cb
		where ma_dvi=b_ma_dvi order by phong,ma) where sott between b_tu and b_den;
else
	select count(*) into b_dong from ht_ma_cb where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
	PKH_LKE_TRANG(b_dong,b_tu,b_den);
	open cs_lke for select * from (select phong,ma,ten,nsd,row_number() over (order by phong,ma) sott from ht_ma_cb
		where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by phong,ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PHT_MA_CB_MA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_phong varchar2,b_ma varchar2,b_trangkt number,
	b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from ht_ma_cb where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select phong,ma,row_number() over (order by phong,ma) sott
	from ht_ma_cb where ma_dvi=b_ma_dvi order by phong,ma) where phong>b_phong or (phong=b_phong and ma>=b_ma);
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select phong,ma,ten,nsd,row_number() over (order by phong,ma) sott from ht_ma_cb
	where ma_dvi=b_ma_dvi order by phong,ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CB_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- Dan - Xem ct
open cs_lke for select * from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PHT_MA_CB_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_so_cmt varchar2,
    b_phong varchar2,b_cv varchar2,b_ma_tk varchar2,b_nhang varchar2,b_ten_nh nvarchar2,b_mobi varchar2,b_mail varchar2,b_ma_hr varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma can bo
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma can bo:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma phong' || b_phong || ':loi';
if trim(b_phong) is null then raise PROGRAM_ERROR; end if;
select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
if b_i1 is null then raise PROGRAM_ERROR; end if;
if trim(b_cv) is not null then
    b_loi:='loi:Ma chuc vu chua dang ky:loi';
    select 0 into b_i1 from ht_ma_cvu where ma_dvi=b_ma_dvi and ma=b_cv;
    if b_i1 is null then raise PROGRAM_ERROR; end if;
end if;
if trim(b_nhang) is not null then
    b_loi:='loi:Ma ngan hang chua dang ky:loi';
    select 0 into b_i1 from kh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_nhang;
    if b_i1 is null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Va cham NSD:loi';
delete ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
insert into ht_ma_cb values(b_ma_dvi,b_ma,b_ten,b_so_cmt,b_phong,b_cv,b_ma_tk,b_nhang,b_ten_nh,b_mobi,b_mail,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CB_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa ma can bo
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then
	b_loi:='loi:Nhap ma can bo:loi'; raise PROGRAM_ERROR;
end if;
delete ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CB_FILE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,a_phong pht_type.a_var,a_ma pht_type.a_var,a_ten pht_type.a_nvar)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap qua file
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for b_lp in 1..a_phong.count loop
    if a_phong(b_lp) is null or trim(a_ma(b_lp)) is null or trim(a_ten(b_lp)) is null then
        b_loi:='loi:Nhap sai dong#'||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    b_loi:='loi:Sai ma phong#'||a_phong(b_lp)||':loi';
    select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..a_phong.count loop
        if a_ma(b_lp1)=a_ma(b_lp) then
            b_loi:='loi:Trung ma#'||a_ma(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
    end loop;
end loop;
b_loi:='loi:Va cham NSD:loi';
for b_lp in 1..a_phong.count loop
    delete ht_ma_cb where ma_dvi=b_ma_dvi and ma=a_ma(b_lp);
    insert into ht_ma_cb values(b_ma_dvi,a_ma(b_lp),a_ten(b_lp),'',a_phong(b_lp),'','','','',b_nsd,b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma chuc vu
create or replace procedure PHT_MA_CVU_LKE
	  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100);
begin
-- Dan - Xem he thong ma cvu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from ht_ma_cvu where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CVU_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_ma_ct varchar2)
AS
	b_loi varchar2(100); b_i1 number; b_idvung number; a_ma pht_type.a_var;
begin
-- Dan - Nhap ma cvu
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma cvu:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is not null then
	if b_ma_ct=b_ma then b_loi:='loi:Sai ma cap tren:loi'; raise PROGRAM_ERROR; end if;
	PKH_CH_ARR(b_ma_ct,a_ma);
	for b_lp in 1..a_ma.count loop
		select count(*) into b_i1 from ht_ma_cvu where ma_dvi=b_ma_dvi and ma=a_ma(b_lp);
		if b_i1=0 then b_loi:='loi:Ma cap tren chua dang ky:loi'; raise PROGRAM_ERROR; end if;
		
		select count(*) into b_i1 from ht_ma_cvu where ma_dvi=b_ma_dvi and ma=a_ma(b_lp) and ma_ct=b_ma;
		if b_i1>0 then b_loi:='loi:Ma cap tren khong cho phep:loi'; raise PROGRAM_ERROR; end if;
	end loop;
end if;
delete ht_ma_cvu where ma_dvi=b_ma_dvi and ma=b_ma;
b_loi:='loi:Va cham NSD:loi';
insert into ht_ma_cvu values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CVU_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100); b_i1 number; b_ma_cd varchar2(10);
begin
-- Dan - Nhap ma cvu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma cvu:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from ht_ma_cvu where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if b_i1<>0 then b_loi:='loi:Con ma cap duoi:loi'; raise PROGRAM_ERROR; end if;
delete ht_ma_cvu where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma don vi
create or replace procedure PHT_MA_DVI_CD
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke don vi truc thuoc
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select ma dvi,ten,ten_gon from (select ma,ten,ten_gon,ma_ct from ht_ma_dvi where idvung=b_idvung) where ma_ct=b_ma_dvi order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_NB
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100); b_idvung number; b_ma_ct varchar2(20);
begin
-- Dan - Liet ke don vi truc thuoc va don vi
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_dvi) is null then
	open cs1 for select ma dvi,ten,ten_gon from (select ma,ten,ten_gon,ma_ct from ht_ma_dvi where idvung=b_idvung) where trim(ma_ct) is null order by ten;
else
	open cs1 for select ma dvi,ten,ten_gon from (select ma,ten,ten_gon,ma_ct from ht_ma_dvi where idvung=b_idvung) where b_ma_dvi in(ma,ma_ct) order by ten;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_NG
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100); b_idvung number; b_ma_ct varchar2(20);
begin
-- Dan - Liet ke don vi cap tren va ngang cap
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
select ma_ct into b_ma_ct from ht_ma_dvi where ma=b_ma_dvi;
open cs1 for select ma dvi,ten,ten_gon from (select ma,ten,ten_gon,ma_ct from ht_ma_dvi where idvung=b_idvung) where b_ma_ct in(ma,ma_ct) order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_ND 
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number; b_ma_ct varchar2(20);
begin
-- Dan - Liet ke don vi cap tren va ngang cap va cap duoi
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
select ma_ct into b_ma_ct from ht_ma_dvi where ma=b_ma_dvi;
open cs1 for select ma dvi,ten,ten_gon from (select ma,ten,ten_gon,ma_ct from ht_ma_dvi where idvung=b_idvung) where ma=b_ma_ct or ma_ct in(b_ma_dvi,b_ma_ct) order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_tim nvarchar2,b_tu_n number,b_den_n number,
    b_dong out number,cs_lke out pht_type.cs_type,b_dk varchar2:='T')
AS
    b_loi varchar2(100); b_idvung number; b_tu number:=b_tu_n; b_den number:=b_den_n; b_ma_dviS varchar2(20):=' ';
begin
-- Dan - Xem he thong ma don vi
delete temp_1; delete temp_2; commit;
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
if b_dk='C' then        -- Lay don vi cap duoi
    select nvl(min(ma_ct),' ') into b_ma_dviS from ht_ma_dvi where ma_ct=b_ma_dvi;
elsif b_dk='D' then     -- Lay don vi minh va cap duoi
    b_ma_dviS:=b_ma_dvi;
end if;
insert into temp_1(c1,c2,c3,c4) select * from (select ma_goc,ten,ma,ma_ct_goc from ht_ma_dvi where idvung=b_idvung order by ma_goc)
    start with ma_ct_goc=b_ma_dviS CONNECT BY prior ma_goc=ma_ct_goc;
    b_dong:=sql%rowcount;
if trim(b_tim) is null then
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    insert into temp_2(c1,c2,c3,c4,n1) select c1,rpad(lpad('-',2*(level-1),'-')||c1,20),c2,c3,rownum
        from temp_1 start with c4=b_ma_dviS CONNECT BY prior c1=c4;
    open cs_lke for select c1 ma_goc,c2 xep,c3 ten,c4 ma
        from (select c1,c2,c3,c4,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
else
    insert into temp_2(c1,c2,c3) select c1,c2,c3 from temp_1 where upper(c3) like b_tim;
    b_dong:=sql%rowcount;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select c1 ma_goc,c1 xep,c2 ten,c3 ma from
        (select c1,c2,c3,row_number() over (order by c1) sott from temp_2) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number; b_tu number; b_den number;
begin
-- Dan - Xem
delete temp_1; delete temp_2; commit;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
insert into temp_1(c1,c2,c3,c4) select ma_goc,ma_ct_goc,ten,ma from ht_ma_dvi where idvung=b_idvung order by ma_goc;
b_dong:=sql%rowcount;
insert into temp_2(c1,c2,c3,c4,n1) select c1,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,c3 ten,c4,rownum
    from temp_1 start with c2=' ' CONNECT BY prior c1=c2;
select nvl(min(sott),b_dong) into b_tu from (select c1,row_number() over (order by n1) sott from temp_2 order by n1) where c1>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select c1 ma_goc,c2 xep,c3 ten,c4 ma
    from (select c1,c2,c3,c4,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Chi tiet ma don vi
open cs1 for select * from ht_ma_dvi where ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ma varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Tra ten don vi
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
b_loi:='Ma chua dang ky';
if b_nv='NHANG' then
    select ten into b_ten from kh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='KVUC' then
    select ten into b_ten from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='TEN' then
    select ten into b_ten from ht_ma_dvi where ma=b_ma;
elsif b_nv='DCHI' then
    select dchi into b_ten from ht_ma_dvi where ma=b_ma;
elsif b_nv='GOC' then
    select ma_goc into b_ten from ht_ma_dvi where ma=b_ma;
elsif b_nv='GON' then
    select ten_gon into b_ten from ht_ma_dvi where ma=b_ma;
elsif b_nv='PHONG' then
    select ten into b_ten from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_cap varchar2,
    b_ten nvarchar2,b_ten_gon nvarchar2,b_dchi nvarchar2,b_ma_thue varchar2,b_g_doc nvarchar2,b_ktt nvarchar2,
    b_ten_sv varchar2,b_ten_db varchar2,b_ten_dbo varchar2,b_ip varchar2,b_ma_tk varchar2,
    b_nhang varchar2,b_kvuc varchar2,b_ma_ct varchar2,b_pas_di varchar2,b_pas_den varchar2,
    b_tt_hd varchar2,b_loai varchar2,b_vp varchar2,b_ngay_bd number,b_ngay_kt number,b_dbo_ma varchar2:='K',b_tdx number,b_tdy number)
AS
    b_i1 number; b_c1 varchar2(1); b_loi varchar2(100); b_idvung number;
    b_ma_v varchar2(20); b_ma_ct_v varchar2(20); b_nsd_l varchar2(10);
begin
-- Dan - Nhap he thong ma don vi
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma don vi:loi'; raise PROGRAM_ERROR; end if;
if b_tt_hd is null or b_tt_hd not in('T','P') then
    b_loi:='loi:Trang thai Server: T-Tai cho; P-Phan tan:loi'; raise PROGRAM_ERROR;
end if;
if b_loai is null or b_loai not in('P','R','D') then
    b_loi:='loi:Loai: P-Hach toan phu thuoc, R-Hach toan rieng, D-Hach toan doc lap:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_vp) is null then b_loi:='loi:Sai nho,:loi'; raise PROGRAM_ERROR; end if;
if b_cap is null or b_cap not between '1' and '5' then
    b_loi:='loi:Cap don vi tu 1-5:loi'; raise PROGRAM_ERROR;
end if;
if b_nhang is not null then
    b_loi:='loi:Ma ngan hang chua dang ky:loi';
    select 0 into b_i1 from kh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_nhang;
end if;
--if b_kvuc is not null then
--    b_loi:='loi:Ma khu vuc chua dang ky:loi';
--    select 0 into b_i1 from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_kvuc;
--end if;
if b_ma_ct is null then raise PROGRAM_ERROR; end if;
if b_ma_ct=b_ma then b_loi:='loi:Trung ma dang khai bao va ma cap tren:loi'; raise PROGRAM_ERROR; end if;
if b_idvung=0 then
    b_ma_v:=b_ma; b_ma_ct_v:=b_ma_ct;
else
    b_ma_ct_v:=to_char(b_idvung);
    b_ma_v:=b_ma_ct_v||'_'||b_ma;
    if trim(b_ma_ct) is not null then
        b_ma_ct_v:=b_ma_ct_v||'_'||b_ma_ct;
    end if;
end if;
b_loi:='loi:Sai ma cap tren:loi';
/* if b_dbo_ma='C' then PKT_DVI_DBO_MA(b_ma_v,b_idvung); end if; */
b_loi:='loi:Va cham nguoi su dung:loi'; b_nsd_l:=FHT_MA_NSD_LUU(b_ma_dvi,b_nsd);
delete ht_ma_dvi where ma=b_ma_v;
insert into ht_ma_dvi values
    (b_ma_v,b_cap,b_ten,b_ten_gon,b_dchi,b_ma_thue,b_g_doc,b_ktt,b_ten_sv,b_ten_db,b_ten_dbo,b_ip,b_ma_tk,b_nhang,b_kvuc,
    b_ma_ct_v,b_pas_di,b_pas_den,b_tt_hd,b_loai,b_vp,b_ngay_bd,b_ngay_kt,b_nsd_l,b_idvung,b_ma,b_ma_ct,b_tdx,b_tdy);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_DVI_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_ma_cd varchar2(10); b_loi varchar2(100);
begin
-- Dan - Xoa he thong ma don vi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma don vi:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dvi=b_ma then b_loi:='loi:Khong xoa don vi cua chinh NSD:loi'; raise PROGRAM_ERROR; end if;
select min(ma) into b_ma_cd from ht_ma_dvi where ma_ct=b_ma;
if trim(b_ma_cd) is not null then b_loi:='loi:Co ma cap duoi#'||b_ma_cd||':loi'; raise PROGRAM_ERROR; end if;
delete ht_ma_dvi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma phong
create or replace procedure PHT_MA_PHONG_TEN 
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_ma varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Tra ten phong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Phong chua dang ky:loi';
select ten into b_ten from ht_ma_phong where ma_dvi=b_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONG_LKE (
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_tim nvarchar2,b_tu_n number,b_den_n number,
    b_dong out number,cs_lke out pht_type.cs_type,b_dk varchar2:='T')
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n; b_phongS varchar2(20):=' ';
begin
-- Dan - Liet ke he thong ma phong
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dk='C' then        -- Lay bo phan cap duoi
    select nvl(min(ma_ct),' ') into b_phongS from ht_ma_dvi where ma_ct=b_ma_dvi;
elsif b_dk='D' then     -- Lay bo phan minh va cap duoi
    b_phongS:=b_ma_dvi;
end if;
insert into temp_1(c1,c2,c3,c4)
    select * from (select ma,ten,nhom,ma_ct from ht_ma_phong where ma_dvi=b_ma_dvi order by ma)
    start with ma_ct=b_phongS CONNECT BY prior ma=ma_ct;
b_dong:=sql%rowcount;
if trim(b_tim) is null then
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    insert into temp_2(c1,c2,c3,c4,n1) select c1,rpad(lpad('-',2*(level-1),'-')||c1,20),c2,c3,rownum
        from temp_1 start with c4=b_phongS CONNECT BY prior c1=c4;
    open cs_lke for select c1 ma,c2 xep,c3 ten,c4 nhom
        from (select c1,c2,c3,c4,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
else
    insert into temp_2(c1,c2,c3) select c1,c2,c3 from temp_1 where upper(c2) like b_tim;
    b_dong:=sql%rowcount;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select c1 ma,c1 xep,c2 ten,c3 nhom from
        (select c1,c2,c3,row_number() over (order by c1) sott from temp_2) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONG_DVI
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem he thong ma phong theo don vi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select ma,ten from ht_ma_phong where ma_dvi=b_dvi order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONG_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,cs_lke out pht_type.cs_type,b_dk varchar2:='T')
AS
    b_loi varchar2(100); b_phongS varchar2(20):=' ';
begin
-- Dan - Xem he thong ma phong
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dk='C' then        -- Lay bo phan cap duoi
    select nvl(min(ma_ct),' ') into b_phongS from ht_ma_dvi where  ma_ct=b_dvi;
elsif b_dk='D' then     -- Lay bo phan minh va cap duoi
    b_phongS:=b_ma_dvi;
end if;
insert into temp_1(c1,c2,c3,c4,c5,c6)
    select * from (select ma,ten,nhom,ma_ct,pnhan,nsd from ht_ma_phong where ma_dvi=b_dvi /*and ma_dvi=b_ma_dvi*/ order by ma)
    start with ma_ct=b_phongS CONNECT BY prior ma=ma_ct;
insert into temp_2(c1,c2,c3,c4,c5,c6,n1) select c1,rpad(lpad('-',2*(level-1),'-')||c1,20),c2,c3,c5,c6,rownum
    from temp_1 start with c4=b_phongS CONNECT BY prior c1=c4;
open cs_lke for select c1 ma,c2 xep,c3 ten,c4 nhom,c5 pnhan,'' email, '' ten_en,c6 nsd from temp_2;
delete temp_1; delete temp_2; commit;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_PHONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_ma varchar2,b_ten nvarchar2, 
    b_nhom varchar2,b_pnhan varchar2,b_ma_ct varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_ma_cd varchar2(10); b_idvung number;
begin
-- Dan - Nhap ma phong
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;

if trim(b_ma) is null then b_loi:='loi:Nhap ma phong:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_nhom is null or b_nhom not in ('T','G') then b_loi:='loi:Sai khoi:loi'; raise PROGRAM_ERROR; end if;
if b_ma_ct is null or b_ma_ct=b_ma then b_loi:='loi:Sai ma cap tren:loi'; raise PROGRAM_ERROR; end if;
--if b_pnhan is null or b_pnhan not in ('C','K') then b_loi:='loi:Sai phap nhan:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is not null then
    select count(*) into b_i1 from ht_ma_phong where ma_dvi=b_dvi and ma=b_ma_ct;
    if b_i1=0 then b_loi:='loi:Ma cap tren chua dang ky:loi'; raise PROGRAM_ERROR; end if;
end if;

delete ht_ma_phong where ma_dvi=b_dvi and ma=b_ma;
b_loi:='loi:Va cham NSD:loi';
insert into ht_ma_phong values(b_dvi,b_ma,b_ten,b_nhom,'',b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma nhom
create or replace procedure PHT_MA_NHOM_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select ma,ten from ht_ma_nhom where ma_dvi=b_ma_dvi and md=b_md order by ma;
end;
/
create or replace procedure PHT_MA_NHOM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma varchar2,
    cs_ct out pht_type.cs_type,cs_nv out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - CT nhom
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_ct for select * from ht_ma_nhom where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma;
open cs_nv for select nv,tc from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NHOM_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_md) is null then b_loi:='loi:Nhap Modul:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma;
delete ht_ma_nhom where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NHOM_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,
    b_ma varchar2,b_ten nvarchar2,a_nv pht_type.a_var,a_tc pht_type.a_var)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan
PHTG_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_md) is null then b_loi:='loi:Nhap Modul:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma;
delete ht_ma_nhom where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma;
insert into ht_ma_nhom values(b_ma_dvi,b_md,b_ma,b_ten,b_nsd,b_idvung);
for b_lp in 1..a_nv.count loop
    if trim(a_tc(b_lp)) is not null then
        insert into ht_ma_nhom_nv values(b_ma_dvi,b_md,b_ma,a_nv(b_lp),a_tc(b_lp),b_idvung);
    end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma nsd
create or replace procedure PHTG_MA_NSD_MA_LOGIN
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma varchar2,b_ma_login varchar2)
AS
    b_loi varchar2(100); b_ma_g varchar2(50);
begin
-- Dan - Kiem tra trung ma login
b_ma_g:=FHT_MA_NSD_LOGIN(b_dvi,b_nsd);
b_loi:=FHT_MA_NSD_XET(b_ma_g,b_ma_dvi,b_ma,b_ma_login);
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHTA_MA_NSD_MA_LOGIN
    (b_dvi varchar2,b_nsdN varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma varchar2,b_ma_login varchar2)
AS
    b_loi varchar2(100); b_ma_g varchar2(50); b_nsd varchar2(30):=FHTA_MA_NSD_CAT(b_nsdN);
begin
-- Dan - Kiem tra trung ma login
b_ma_g:=FHTA_MA_NSD_LOGIN(b_dvi,b_nsd);
b_loi:=FHTA_MA_NSD_XET(b_ma_g,b_ma_dvi,b_ma,b_ma_login);
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHTA_MA_NSD_XET
    (b_ma_gN varchar2,b_ma_dviN varchar2,b_maN varchar2,b_ma_loginN varchar2) return varchar2
AS
    b_ma_c varchar2(50); b_i1 number; b_ma_g varchar2(30):=FHTA_MA_NSD_CAT(b_ma_gN);
    b_ma_dvi varchar2(30):=FHTA_MA_NSD_CAT(b_ma_dviN); b_ma varchar2(50):=FHTA_MA_NSD_CAT(b_maN);
    b_ma_login varchar2(50):=FHTA_MA_NSD_CAT(b_ma_loginN);
begin
-- Dan - Kiem tra trung ma login
if b_ma_dvi is null or b_ma is null or b_ma_login is null then return 'loi:Nhap don vi, ma quan ly, ma login:loi'; end if;
select count(*) into b_i1 from htA_ma_nsd where ma_dvi=b_ma_dvi;
if b_i1<>0 then
    select min(ma_login) into b_ma_c from htA_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
    if (b_ma_c is null and b_ma_g<>b_ma_login) or (b_ma_c is not null and b_ma_c<>b_ma_login) then
        select count(*) into b_i1 from htA_login where ma=b_ma_login;
        if b_i1<>0 then return 'loi:Trung ma login:loi'; end if;
    end if;
end if;
return '';
end;
/
create or replace function FHTA_MA_NSD_DLY(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - Tra NSD la dai ly
if substr(b_ma,1,3) in('$D$','$A$','$G$','$F$') then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FHT_MA_NSD_LOGIN (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra ma login
if instr(b_ma_dvi,'$A$')<>1 then
    b_kq:=FHTG_MA_NSD_LOGIN(b_ma_dvi,b_nsd);
else
    b_kq:=FHTA_MA_NSD_LOGIN(b_ma_dvi,b_nsd);
end if;
return b_kq;
end;
/
create or replace function FHT_MA_NSD_XET
    (b_ma_g varchar2,b_ma_dvi varchar2,b_ma varchar2,b_ma_login varchar2) return varchar2
AS
    b_ma_c varchar2(50); b_i1 number;
begin
-- Dan - Kiem tra trung ma login
if b_ma_dvi is null or b_ma is null or b_ma_login is null then return 'loi:Nhap don vi, ma quan ly, ma login:loi'; end if;
select min(ma_login) into b_ma_c from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
if (b_ma_c is null and b_ma_g<>b_ma_login) or (b_ma_c is not null and b_ma_c<>b_ma_login) then
    select count(*) into b_i1 from ht_login where ma=b_ma_login;
    if b_i1<>0 then return 'loi:Trung ma login:loi'; end if;
end if;
return '';
end;
/
create or replace function FHT_MA_NSD_VUNG (b_ma_dvi varchar2,b_nsd varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra vung NSD
if instr(b_ma_dvi,'$A$')<>1 then
    b_kq:=FHTG_MA_NSD_VUNG(b_ma_dvi,b_nsd);
else
    b_kq:=FHTA_MA_NSD_VUNG(b_ma_dvi,b_nsd);
end if;
return b_kq;
end;
/
create or replace function FHT_MA_NSD_TENl(b_ma_dvi varchar2,b_nsd varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten NSD
b_kq:=b_nsd||'|'||FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);

return b_kq;
end;
/
create or replace function FHT_MA_NSD_TEN (b_ma_dvi varchar2,b_nsd varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten NSD
if instr(b_ma_dvi,'$A$')<>1 then
    b_kq:=FHTG_MA_NSD_TEN(b_ma_dvi,b_nsd);
else
    b_kq:=FHTA_MA_NSD_TEN(b_ma_dvi,b_nsd);
end if;
return b_kq;
end;
/
create or replace function FHT_MA_NSD_DVI
    (b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2,b_dvi varchar2) return varchar2
AS
    b_i1 number;
begin
-- Dan - Kiem tra quyen NSD voi don vi
if b_dvi is null then return 'K'; end if;
if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,b_nv,b_kt)<>'C' then return 'K'; end if;
select count(*) into b_i1 from ht_ma_nsd_qly where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md;
if b_i1<>0 then
    select count(*) into b_i1 from ht_ma_nsd_qly where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and dvi=b_dvi;
    if b_i1=0 then return 'K'; end if;
end if;
return 'C';
end;
/
create or replace function FHTG_MA_NSD_TEN(b_ma_dvi varchar2, b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(100):='';
begin
-- Dan - Tra ten NSD
if trim(b_ma_dvi) is not null and trim(b_ma) is not null then
    select min(ten) into b_kq from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
return b_kq;
end;
/
create or replace function FHTA_MA_NSD_TEN(b_ma_dviN varchar2,b_nsdN varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):='';
    b_ma_dvi varchar2(30):=FHTA_MA_DVI_CAT(b_ma_dviN); b_nsd varchar2(50):=FHTA_MA_NSD_CAT(b_nsdN);
begin
-- Dan - Tra ten NSD
if FHT_MA_NSD_LOAI(b_ma_dviN,b_nsdN)='D' then
    select min(ten) into b_kq from htA_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
end if;
return b_kq;
end;
/
create or replace procedure PHT_MA_NSD_QU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2,b_qu out varchar2)
AS
begin
-- Dan - Xem he thong ma NSD
if instr(b_ma_dvi,'$A$')<>1 then
    b_qu:=FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,b_nv,b_kt);
else
    b_qu:=FHTA_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,b_nv,b_kt);
end if;
end;
/
CREATE OR REPLACE procedure PHT_MA_NSD_MA_LOGIN
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma varchar2,b_ma_login varchar2)
AS
begin
-- Dan - Kiem tra trung ma login
if FHTA_MA_NSD_DLY(b_nsd)='C' then
    PHTA_MA_NSD_MA_LOGIN(b_dvi,b_nsd,b_pas,b_ma_dvi,b_ma,b_ma_login);
else
    PHTG_MA_NSD_MA_LOGIN(b_dvi,b_nsd,b_pas,b_ma_dvi,b_ma,b_ma_login);
end if;
end;
/
create or replace procedure PHT_MA_NSD_LKE
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_md varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
delete temp_1; delete temp_2; commit;
b_loi:=FHTG_MA_NSD_KTRA(b_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi:loi';
if b_ma_dvi is null then raise PROGRAM_ERROR; end if;
if FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT','ND','X')<>'C' then
    b_dong:=1;
    open cs_lke for select phong,ma,ten,nsd from ht_ma_nsd where ma_dvi=b_dvi and ma=b_nsd;
elsif trim(b_md) is null then
    select count(*) into b_dong from ht_ma_nsd where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select phong,ma,ten,row_number() over (order by phong,ma) sott from ht_ma_nsd
        where ma_dvi=b_ma_dvi order by phong,ma) where sott between b_tu and b_den;
else
    insert into temp_1(c1) select distinct ma from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and md in(b_md,'HT');
    insert into temp_1(c1) select distinct ma from ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and md=b_md;
    insert into temp_2(c1) select distinct c1 from temp_1;
    b_dong:=sql%rowcount;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select phong,ma,ten,row_number() over (order by phong,ma) sott from ht_ma_nsd where ma_dvi=b_ma_dvi and 
        ma in(select c1 from temp_2) order by phong,ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_MA (
  b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,
  b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100); b_i1 number; b_tu number; b_den number;
begin
-- Dan - Xem
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHTG_MA_NSD_KTRA(b_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi:loi';
if b_ma_dvi is null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_md) is null then
  insert into temp_1(c1,c2,c3) select phong,ma,ten from ht_ma_nsd where ma_dvi=b_ma_dvi order by phong,ma;
else
  insert into temp_3(c1) select distinct ma from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and md in(b_md,'HT');
  insert into temp_3(c1) select distinct ma from ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and md=b_md;
  insert into temp_1(c1,c2,c3) select phong,ma,ten from ht_ma_nsd where ma_dvi=b_ma_dvi and
    ma in(select distinct c1 from temp_3) order by phong,ma;
end if;
b_dong:=sql%rowcount;
insert into temp_2(c1,c2,c3,n1) select c1,c2,c3,rownum from temp_1 order by c1,c2;
select nvl(min(sott),-1) into b_tu from (select c2,row_number() over (order by n1) sott from temp_2 order by n1) where c2=b_ma;
if b_tu<0 then
  select nvl(min(sott),b_dong) into b_tu from (select c2,row_number() over (order by n1) sott from temp_2 order by n1) where c2>b_ma;
end if;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select c1 phong,c2 ma,c3 ten,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
delete temp_1; delete temp_2; delete temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_QLY
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma varchar2,b_md varchar2,cs_dvi out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_ma_ktra varchar2(10):=b_nsd;
begin
-- Dan - Xem danh sach don vi quan ly
b_loi:=FHTG_MA_NSD_KTRA(b_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi:loi';
if b_ma_dvi is null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is not null and b_ma<>b_nsd then
    if FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT','ND','X')<>'C' then b_loi:='loi:Khong vuot quyen:'; raise PROGRAM_ERROR; end if;
    b_ma_ktra:=b_ma;
end if;
open cs_dvi for select a.dvi,b.ten from ht_ma_nsd_qly a,ht_ma_dvi b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma_ktra and a.md=b_md and b.ma=a.dvi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_CT
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma varchar2,b_md varchar2,
    cs_ct out pht_type.cs_type,cs_nv out pht_type.cs_type,cs_dvi out pht_type.cs_type,cs_nhom out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Xem quyen NSD
b_loi:=FHTG_MA_NSD_KTRA(b_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi:loi';
if b_ma_dvi is null then raise PROGRAM_ERROR; end if;
if b_nsd<>b_ma then
    if FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT','ND','X')<>'C' then b_loi:='loi:Khong vuot quyen:loi'; raise PROGRAM_ERROR; end if;
end if;
open cs_ct for select ma_login,ma,ten,phong,nsd from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
open cs_nv for select nv,tc from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_ma and md in('HT',b_md);
open cs_dvi for select a.dvi,b.ten from ht_ma_nsd_qly a,ht_ma_dvi b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma and a.md=b_md and b.ma=a.dvi;
open cs_nhom for select nhom from ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_ma and md=b_md;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_XOA
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_nsd_c varchar2(10); b_idvung number; b_qu number; b_ma_login varchar2(50);
begin
-- Dan - Xoa ma NSD
PHTG_MA_NSD_KTRA_VU(b_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','ND','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=FHT_MA_DVI_KTRA(b_idvung,b_ma_dvi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma NSD:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select nsd,ma_login into b_nsd_c,b_ma_login from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong xoa ma do nguoi khac khai bao:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
update ht_ma_nsd set nsd=b_nsd where ma_dvi=b_ma_dvi and nsd=b_ma;
delete ht_ma_nsd_qly where ma_dvi=b_ma_dvi and ma=b_ma;
delete ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_ma;
delete ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
delete ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
if FHTG_MA_NSD_ACC('',b_ma_login)<>'C' then delete ht_login where ma=b_ma_login; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_NH
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_ma_login varchar2,
    b_ma varchar2,b_md varchar2,b_ten nvarchar2,b_pas_n varchar2,b_phong varchar2,
    a_md in out pht_type.a_var,a_nv pht_type.a_var,a_tc pht_type.a_var,a_dvi in out pht_type.a_var,a_nhom in out pht_type.a_var)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number; b_qu varchar2(1):='K'; b_ten_nv nvarchar2(100);
    b_nsd_c varchar2(10); b_tc varchar2(10); b_ma_g varchar2(50); b_ma_login_c varchar2(50); b_pas_c varchar2(20);
begin
-- Dan - Nhap ma NSD
PHTG_MA_NSD_KTRA_VU(b_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=FHT_MA_DVI_KTRA(b_idvung,b_ma_dvi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma_login) is null then b_loi:='loi:Nhap ma login:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma quan ly:loi'; raise PROGRAM_ERROR; end if;
if trim(b_md) is null then b_loi:='loi:Nhap Modul:loi'; raise PROGRAM_ERROR; end if;
if b_nsd=b_ma and FHTG_MA_NSD_ACC(b_dvi,b_nsd)<>'C' then
    if trim(b_pas_n) is null then  b_loi:='loi:Nhap password:loi'; raise PROGRAM_ERROR; end if;
    b_loi:='loi:Loi doi Password:loi';
    select ma_login into b_ma_login_c from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
    if b_ma_login_c<>b_ma_login then raise PROGRAM_ERROR; end if;
    update ht_login set pas=b_pas_n where ma=b_ma_login;
    update ht_ma_nsd set pas=b_pas_n where ma_dvi=b_ma_dvi and ma=b_nsd;
    commit; return;
end if;
b_ma_g:=FHTG_MA_NSD_LOGIN(b_dvi,b_nsd);
b_loi:=FHT_MA_NSD_XET(b_ma_g,b_ma_dvi,b_ma,b_ma_login);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma phong:loi';
if b_phong is null then raise PROGRAM_ERROR;
elsif trim(b_phong) is not null then
    select count(*) into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi;
    if b_i1<>0 then
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
    end if;
end if;
PKH_MANG(a_md); PKH_MANG(a_dvi); PKH_MANG(a_nhom);
for b_lp in 1..a_nhom.count loop
    b_loi:='loi:Ma nhom#'||a_nhom(b_lp)||'#chua dang ky:loi';
    select 0 into b_i1 from ht_ma_nhom where ma_dvi=b_ma_dvi and md=b_md and ma=a_nhom(b_lp);
end loop;
for b_lp in 1..a_dvi.count loop
    b_loi:='loi:Ma don vi dong chua dang ky#'||a_dvi(b_lp)||':loi';
    select 0 into b_i1 from ht_ma_dvi where ma=a_dvi(b_lp);
end loop;
if FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT','ND','N')<>'C' then
    b_loi:='loi:Khong vuot quyen:loi'; raise PROGRAM_ERROR;
end if;
if FHTG_MA_NSD_ACC(b_dvi,b_nsd)<>'C' then
    for b_lp in 1..a_md.count loop
        b_loi:='loi:Sai nghiep vu#'||a_nv(b_lp)||':loi';
        if trim(a_tc(b_lp)) is not null then
        b_i1:=length(a_tc(b_lp));
        if a_md(b_lp)='HT' then
            select min(tc) into b_tc from ht_ma_nsd_nv where ma_dvi=b_dvi and ma=b_nsd and md='HT' and nv=a_nv(b_lp);
            if b_tc is null or b_tc<>a_tc(b_lp) then
                for b_lp1 in 1..b_i1 loop
                    if FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT',a_nv(b_lp),substr(a_tc(b_lp),b_lp1,1))<>'C' then
                        b_loi:='loi:Khong cap vuot quyen#'||trim(b_ten_nv)||':loi'; raise PROGRAM_ERROR;
                    end if;
                end loop;
            end if;
        elsif FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT','ND','Q')<>'C' then
            for b_lp1 in 1..b_i1 loop
                if FHTG_MA_NSD_QU(b_dvi,b_nsd,b_md,a_nv(b_lp),substr(a_tc(b_lp),b_lp1,1))<>'C' then
                    b_loi:='loi:Khong cap vuot quyen#'||trim(b_ten_nv)||':loi'; raise PROGRAM_ERROR;
                end if;
            end loop;
        end if;
        end if;
    end loop;
    if a_nhom.count<>0 then
        if FHTG_MA_NSD_QU(b_dvi,b_nsd,'HT','ND','Q')<>'C' then
            for b_lp in 1..a_nhom.count loop
                b_loi:='loi:Khong cap vuot quyen nhom#'||a_nhom(b_lp)||':loi';
                select 0 into b_i1 from ht_ma_nsd_nhom where ma_dvi=b_dvi and ma=b_nsd and md=b_md and nhom=a_nhom(b_lp);
            end loop;
        end if;
    end if;
    for b_lp in 1..a_dvi.count loop
        b_loi:='loi:Ma don vi#'||a_dvi(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from ht_ma_dvi where ma=a_dvi(b_lp);
    end loop;
end if;
b_qu:=FHTG_MA_NSD_ACC('',b_ma_login); b_nsd_c:=FHT_MA_NSD_LUU(b_dvi,b_nsd);
select count(*),min(pas),min(ma_login) into b_i1,b_pas_c,b_ma_login_c from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
if b_i1<>0 then
    delete ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_ma and md in(b_md,'HT');
    delete ht_ma_nsd_qly where ma_dvi=b_ma_dvi and ma=b_ma and md=b_md;
    delete ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_ma and md=b_md;
    delete ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
    if trim(b_pas_n) is not null then b_pas_c:=b_pas_n; end if;
else
    if trim(b_pas_n) is null then  b_loi:='loi:Nhap password:loi'; raise PROGRAM_ERROR; end if;
    b_pas_c:=b_pas_n; b_ma_login_c:=b_ma_login;
end if;
delete ht_login where ma=b_ma_login_c;
insert into ht_ma_nsd values(b_ma_dvi,b_ma,b_ten,b_pas_c,b_phong,b_nsd_c,b_ma_login,b_idvung);
for b_lp in 1..a_md.count loop
    insert into ht_ma_nsd_nv values(b_ma_dvi,b_ma,a_md(b_lp),a_nv(b_lp),a_tc(b_lp),b_idvung);
end loop;
for b_lp in 1..a_dvi.count loop
    insert into ht_ma_nsd_qly values(b_ma_dvi,b_ma,b_md,a_dvi(b_lp),b_idvung);
end loop;
for b_lp in 1..a_nhom.count loop
    insert into ht_ma_nsd_nhom values(b_ma_dvi,b_ma,b_md,a_nhom(b_lp),b_idvung);
end loop;
insert into ht_login values(b_ma_login,b_pas_c,b_idvung,b_qu,sysdate,0);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_HOI_ID_MOI
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id out number)
AS
	b_loi varchar2(100);
begin
-- Dan - Hoi ID moi
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_FILE
    (b_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_md varchar2,a_phong pht_type.a_var,
    a_ma pht_type.a_var,a_ma_login pht_type.a_var,a_ten pht_type.a_nvar,a_pas pht_type.a_var,a_nhom pht_type.a_var)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number; b_nsd_l varchar2(10); b_qu varchar2(1);
    b_ma_g varchar2(50); b_ma_login varchar2(50); b_nhom varchar2(200); a_nh pht_type.a_var;
    b_iP number;
begin
-- Dan - Nhap qua file
PHTG_MA_NSD_KTRA_VU(b_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=FHT_MA_DVI_KTRA(b_idvung,b_ma_dvi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_md) is null then b_loi:='loi:Nhap Modul:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_iP from ht_ma_phong where ma_dvi=b_ma_dvi;
for b_lp in 1..a_phong.count loop
    if a_phong(b_lp) is null or trim(a_ma_login(b_lp)) is null or trim(a_ma(b_lp)) is null or trim(a_ten(b_lp)) is null or a_pas(b_lp) is null then
        b_loi:='loi:Nhap sai dong#'||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    if trim(a_phong(b_lp)) is not null and b_iP<>0 then
        b_loi:='loi:Sai ma phong#'||a_phong(b_lp)||':loi';
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
    end if;
    PKH_CH_ARR(trim(a_nhom(b_lp)),a_nh);
    for b_lp1 in 1..a_nh.count loop
        b_loi:='loi:Ma nhom chua dang ky#'||a_ma(b_lp)||':'||a_nh(b_lp1)||':loi';
        select 0 into b_i1 from ht_ma_nhom where ma_dvi=b_ma_dvi and md=b_md and ma=a_nh(b_lp1);
    end loop;
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..a_phong.count loop
        if a_ma_login(b_lp1)=a_ma_login(b_lp) then
            b_loi:='loi:Trung login#'||a_ma_login(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
        if a_ma(b_lp1)=a_ma(b_lp) then
            b_loi:='loi:Trung ma#'||a_ma(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
    end loop;
    b_loi:=FHT_MA_NSD_XET(b_ma_g,b_ma_dvi,a_ma(b_lp),a_ma_login(b_lp));
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    if (b_dvi is null and b_nsd=a_ma_login(b_lp)) or (b_dvi is not null and b_nsd=a_ma(b_lp)) then
        b_loi:='loi:Trung ma dang load File:loi'; raise PROGRAM_ERROR;
    end if;
end loop;
b_nsd_l:=FHT_MA_NSD_LUU(b_dvi,b_nsd);
for b_lp in 1..a_phong.count loop
    select min(ma_login) into b_ma_login from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=a_ma(b_lp);
    if b_ma_login is not null then
        delete ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=a_ma(b_lp) and md in(b_md,'HT');
        delete ht_ma_nsd_qly where ma_dvi=b_ma_dvi and ma=a_ma(b_lp) and md=b_md;
        delete ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=a_ma(b_lp) and md=b_md;
        delete ht_ma_nsd where ma_dvi=b_ma_dvi and ma=a_ma(b_lp);
        delete ht_login where ma=a_ma_login(b_lp);
    end if;
end loop;
b_loi:='loi:Va cham NSD:loi';
for b_lp in 1..a_phong.count loop
    insert into ht_ma_nsd values(b_ma_dvi,a_ma(b_lp),a_ten(b_lp),a_pas(b_lp),a_phong(b_lp),b_nsd_l,a_ma_login(b_lp),b_idvung);
    PKH_CH_ARR(trim(a_nhom(b_lp)),a_nh);
    for b_lp1 in 1..a_nh.count loop
        insert into ht_ma_nsd_nhom values(b_ma_dvi,a_ma(b_lp),b_md,a_nh(b_lp1),b_idvung);
    end loop;
    b_qu:=FHTG_MA_NSD_ACC('',a_ma_login(b_lp));
    insert into ht_login values(a_ma_login(b_lp),a_pas(b_lp),b_idvung,b_qu,sysdate,0);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/**MA KHAC**/
-- ma nuoc 
create or replace procedure PKH_MA_NUOC_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from kh_ma_nuoc where ma_dvi=b_ma_dvi order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NUOC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem ma ngan hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_ma_nuoc where ma_dvi=b_ma_dvi;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select a.*,row_number() over (order by ma) sott from kh_ma_nuoc a
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NUOC_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_ma_nuoc where ma_dvi=b_ma_dvi;
select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from kh_ma_nuoc
    where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select a.*,row_number() over (order by ma) sott from kh_ma_nuoc a
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NUOC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if; 
if trim(b_ma) is null or trim(b_ten) is null then b_loi:='loi:Nhap ma nuoc, ten nuoc:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_nuoc where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kh_ma_nuoc values(b_ma_dvi,b_ma,b_ten,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NUOC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then
    b_loi:='loi:Nhap ma nuoc, ten nuoc:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_nuoc where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma linh vuc
create or replace procedure PKH_MA_LVUC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,ma_ct,nsd 
    from (select * from kh_ma_lvuc where ma_dvi=b_ma_dvi order by ma)
    start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
end;
/
create or replace procedure PKH_MA_LVUC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_ma_ct varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma khu vuc
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma quan ly:loi';
if b_ma_ct=b_ma then raise PROGRAM_ERROR;
elsif trim(b_ma_ct) is not null then
    select 0 into b_i1 from kh_ma_lvuc where ma_dvi=b_ma_dvi and ma=b_ma_ct;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_lvuc where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kh_ma_lvuc values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_LVUC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kh_ma_lvuc where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if b_i1<>0 then b_loi:='loi:Ma dang su dung:loi'; raise PROGRAM_ERROR; end if;
delete kh_ma_lvuc where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma loai doanh nghiep
create or replace procedure BPKH_MA_LOAI_DN_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem he thong ma loai doanh nghiep
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,ma_ct,nsd 
    from (select * from kh_ma_loai_dn where ma_dvi=b_ma_dvi order by ma)
    start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
end;
/
create or replace procedure PKH_MA_LOAI_DN_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_ma_ct varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma khu vuc
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma quan ly:loi';
if b_ma_ct=b_ma then raise PROGRAM_ERROR;
elsif trim(b_ma_ct) is not null then
    select 0 into b_i1 from kh_ma_loai_dn where ma_dvi=b_ma_dvi and ma=b_ma_ct;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_loai_dn where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kh_ma_loai_dn values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_LOAI_DN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kh_ma_loai_dn where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if b_i1<>0 then b_loi:='loi:Ma dang su dung:loi'; raise PROGRAM_ERROR; end if;
delete kh_ma_loai_dn where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- ma khu vuc
create or replace procedure PKH_MA_KVUC_LIST
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Khu vuc list
delete kh_ma_kvuc_temp_1; delete kh_ma_kvuc_temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into kh_ma_kvuc_temp_1 select ma,ten,ma_ct from kh_ma_kvuc where ma_dvi=b_ma_dvi order by ten;
insert into kh_ma_kvuc_temp_2 select ma,lpad('-',2*(level-1),'-')||' '||ten
    from kh_ma_kvuc_temp_1 start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
open cs_lke for select ma,ten from kh_ma_kvuc_temp_2;
delete kh_ma_kvuc_temp_1; delete kh_ma_kvuc_temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_TDO
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten out nvarchar2,b_tdo out varchar2)
as
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
    b_ma_ct varchar(10); b_maC varchar(10); b_tinh varchar2(200); b_quan varchar2(200); b_phuong varchar2(200);
begin
-- Dan - Xac dinh ten, cap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma chua dang ky:loi';
select ten,ma_ct into b_ten,b_ma_ct from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma;
b_phuong:=FKH_BO_UNICODE(b_ten); b_tdo:='';
if trim(b_ma_ct) is not null then
    select FKH_BO_UNICODE(ten),ma_ct into b_quan,b_maC from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma_ct;
    if trim(b_maC) is not null then
        select FKH_BO_UNICODE(ten),ma_ct into b_tinh,b_ma_ct from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_maC;
        if trim(b_ma_ct) is null then b_tdo:=b_phuong||','||b_quan||','||b_tinh; end if;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_CH(b_ma_dviN varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Liet ke don vi cap 1
open cs_lke for select ma,ten from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma_ct=' ' order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_1
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Liet ke don vi cap 1
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select ma,ten from kh_ma_kvuc where ma_dvi=b_ma_dviN and ma_ct=' ' order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_2
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Liet ke don vi cap 2
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select ma,ten from kh_ma_kvuc where ma_dvi=b_ma_dviN and ma_ct=b_ma order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_QL
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ma_ct out varchar2)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Tra khu vuc cap tren
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(ma_ct) into b_ma_ct from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_QLY
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ma_ct out varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma_ct:=FKH_MA_KVUC_QLY(b_ma_dvi,b_ma);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_LKE
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_cap number; b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then
    open cs_lke for select ma,ten,ma_ct,0 cap,FKH_MA_KVUC_TC(b_ma_dviN,ma) tc from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma_ct=' ' order by ma;
else
    b_cap:=FKH_MA_KVUC_CAP(b_ma_dviN,b_ma);
    open cs_lke for select ma,ten,b_ma ma_ct,b_cap cap,FKH_MA_KVUC_TC(b_ma_dviN,ma) tc
        from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma_ct=b_ma order by ma;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_TIM
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_dk varchar2,b_ten nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
    b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Liet ke theo ten
if b_dk='M' then delete temp_1; commit; end if;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap tim:loi'; raise PROGRAM_ERROR; end if;
if b_dk='M' then
    insert into temp_1(c1,c2) select ma,ten from kh_ma_kvuc where ma_dvi=b_ma_dvi and upper(ten) like b_ten;
    b_dong:=sql%rowcount;
else
    select count(*) into b_dong from temp_1;
end if;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select c1 ma,c2 ten,' ' ma_ct,0 cap,'C' tc from
    (select c1,c2,row_number() over (order by c1) sott from temp_1 order by c1) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_CT
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','NXM');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PKH_MA_KVUC_XOA
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_ma_c varchar2(20);
    b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Nhap ma khu vuc
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select min(ma) into b_ma_c from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if trim(b_ma_c) is not null then b_loi:='loi:Con ma cap duoi#'||b_ma_c||':loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NHANG_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten out nvarchar2)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(ten) into b_ten from kh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NHANG_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from kh_ma_nhang where ma_dvi=b_ma_dvi order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NHANG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem ma ngan hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from kh_ma_nhang where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select a.*,row_number() over (order by ma) sott from kh_ma_nhang a
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kh_ma_nhang where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select a.*,row_number() over (order by ma) sott from kh_ma_nhang a
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NHANG_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_ma_nhang where ma_dvi=b_ma_dvi;
select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from kh_ma_nhang
    where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select a.*,row_number() over (order by ma) sott from kh_ma_nhang a
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NHANG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_dchi nvarchar2)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap ma ngan hang
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma ngan hang:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table KH_MA_NHANG:loi';
delete kh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kh_ma_nhang values (b_ma_dvi,b_ma,b_ten,b_dchi,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_NHANG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Nhap ma ngan hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma ngan hang:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table KH_MA_NHANG:loi';
delete kh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NH_TK_NHA_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke theo ngan hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select ma,ten from kh_ma_nhang where ma_dvi=b_ma_dvi and ma in
    (select distinct ma_nh from kh_nh_tk where ma_dvi=b_ma_dvi) order by ten;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NH_TK_NHA_TK
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_nh varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke theo ngan hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select ma_tk ma,ma_tk ten from kh_nh_tk where ma_dvi=b_ma_dvi and ma_nh=b_ma_nh order by ma_tk;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NH_TK_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_nh_tk where ma_dvi=b_ma_dvi;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select a.*,row_number() over (order by ma_nh,ma_tk) sott from kh_nh_tk a
    where ma_dvi=b_ma_dvi order by ma_nh,ma_tk) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NH_TK_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_nh varchar2,b_ma_tk varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_nh is null or b_ma_tk is null then b_loi:='loi:Nhap ma ngan hang, tai khoan:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_nh_tk where ma_dvi=b_ma_dvi;
select nvl(min(sott),0) into b_tu from (select ma_nh,ma_tk,row_number() over (order by ma_nh,ma_tk) sott from kh_nh_tk
    where ma_dvi=b_ma_dvi order by ma_nh,ma_tk) where ma_nh=b_ma_nh and ma_tk>=b_ma_tk;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select a.*,row_number() over (order by ma_nh,ma_tk) sott from kh_nh_tk a
    where ma_dvi=b_ma_dvi order by ma_nh,ma_tk) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NH_TK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_nh varchar2,b_ma_tk varchar2,b_ten nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma tai khoan ngan hang
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma_nh) is null then b_loi:='loi:Nhap ma ngan hang:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_tk) is null then b_loi:='loi:Nhap ma tai khoan ngan hang:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_nh_tk where ma_dvi=b_ma_dvi and ma_nh=b_ma_nh and ma_tk=b_ma_tk;
insert into kh_nh_tk values (b_ma_dvi,b_ma_nh,b_ma_tk,b_ten,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NH_TK_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_nh varchar2,b_ma_tk varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Nhap ma tai khoan ngan hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma_nh) is null then b_loi:='loi:Nhap ma ngan hang:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_tk) is null then b_loi:='loi:Nhap ma tai khoan ngan hang:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
delete kh_nh_tk where ma_dvi=b_ma_dvi and ma_nh=b_ma_nh and ma_tk=b_ma_tk;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- so lieu 
create or replace procedure PKH_MA_LNV_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem uu tien Modul nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select ma,nsd from kh_ma_lnv where ma_dvi=b_ma_dvi order by tt;
end;
/
create or replace procedure PKH_MA_LNV_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, a_nv pht_type.a_var,a_ten pht_type.a_var)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap uu tien nghiep vu
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete kh_ma_lnv where ma_dvi=b_ma_dvi;
for b_lp in 1..a_nv.count loop
    insert into kh_ma_lnv values(b_ma_dvi,a_nv(b_lp),a_ten(b_lp),b_lp,b_nsd,b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HAN_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem han thay doi so lieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from kh_ma_han where ma_dvi=b_ma_dvi and md=b_md order by ma_cd,nv;
end;
/
create or replace procedure PKH_MA_HAN_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_md varchar2,b_ma_cd varchar2,b_nv varchar2,b_ngay number)
AS
    b_loi varchar2(200); b_i1 number; b_ma_ct varchar2(10); b_idvung number;
    b_ngay_log date:=sysdate; b_ma_nsd varchar2(20):=b_nsd; b_nv_bh varchar2(20); b_ngay_d number;
begin
-- Dan - Nhap han thay doi so lieu
if trim(b_ma_nsd) is not null then
    if b_md<>'HD' then
        if instr(b_ma_nsd,'$A$')=0 then
            select count(*) into b_i1 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma_nsd;
            if b_i1=0 then b_loi:='loi:Ma NSD '||b_ma_nsd||' chua khai bao:loi'; raise PROGRAM_ERROR; end if;
            if b_ma_cd='AL' or b_nv='AL' then
                b_loi:='loi:Phai chon don vi va nghiep vu:loi';raise PROGRAM_ERROR;
            end if;
        else
            select count(*) into b_i1 from hta_ma_nsd where ma=substr(b_ma_nsd,4);
            if b_i1=0 then b_loi:='loi:Ma NSD '||b_ma_nsd||' chua khai bao:loi'; raise PROGRAM_ERROR; end if;
            if b_ma_cd='AL' or b_nv='AL' then
                b_loi:='loi:Phai chon don vi va nghiep vu:loi';raise PROGRAM_ERROR;
            end if;
        end if;
    else
        select count(*) into b_i1 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma_nsd;
        if b_i1=0 then b_loi:='loi:Ma NSD '||b_ma_nsd||' chua khai bao:loi'; raise PROGRAM_ERROR; end if;
        if b_ma_cd='AL' or b_nv='AL' then
            b_loi:='loi:Phai chon don vi va nghiep vu:loi';raise PROGRAM_ERROR;
        end if;
    end if;
else
    b_ma_nsd:=' ';
end if;

b_loi:='loi:Sai don vi:loi';
if b_ma_cd is null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai loai nghiep vu '||b_nv||':loi';
if b_nv is null then raise PROGRAM_ERROR; end if;
if b_nv<>'AL' then
    if b_nv like 'KT_%' then b_nv_bh:=substr(b_nv,instr(b_nv,'_')+1); else b_nv_bh:=b_nv; end if;
    PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,b_nv_bh,'H');
else
    PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,'MA','H');
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;

if b_ma_cd not in(b_ma_dvi,'AL') then
    b_loi:='loi:Khong phai don vi truc thuoc:loi';
    select ma_ct into b_ma_ct from ht_ma_dvi where ma=b_ma_cd;
    --if b_ma_ct is null or b_ma_ct<>b_ma_dvi then raise PROGRAM_ERROR; end if;
end if;
select ma_ct into b_ma_ct from ht_ma_dvi where ma=b_ma_dvi;
b_ngay_d:=b_ngay;
if b_ma_nsd=' ' or b_nsd in ('HH','XCG','TSKT','CN') then
    if trim(b_ma_ct) is not null then
        select count(*) into b_i1 from kh_ma_han where ma_dvi=b_ma_dvi and md=b_md
            and ma_cd=b_ma_ct and nv in('AL',b_nv) and ngay>b_ngay_d;
        if b_i1<>0 then b_loi:='loi:Vuot han cap tren:loi'; raise PROGRAM_ERROR; end if;
    end if;
end if;
if b_nv<>'AL' then
    if b_ma_nsd=' ' then
        if b_ma_cd='AL' then
            select count(*) into b_i1 from kh_ma_han where ma_dvi=b_ma_dvi and md=b_md and nv='AL' and ngay>=b_ngay_d;
        else
            select count(*) into b_i1 from kh_ma_han where ma_dvi=b_ma_dvi and md=b_md and ma_cd=b_ma_cd and nv='AL' and ngay>=b_ngay_d;
        end if;
        if b_i1<>0 and b_nv<>'NSLD' then b_loi:='loi:Vuot han tat ca:loi'; raise PROGRAM_ERROR; end if;
    end if;
end if;
b_loi:='loi:Loi Table kh_ma_han:loi';
if b_ma_cd='AL' then
    delete kh_ma_han where ma_dvi=b_ma_dvi and md=b_md and (nv=b_nv or (b_nv='AL' and ngay<b_ngay_d))
        and ma_cd in(select ma from ht_ma_dvi where b_ma_dvi in (ma,ma_ct));
    delete kh_ma_han where ma_dvi in(select ma from ht_ma_dvi where ma_ct=b_ma_dvi)
        and md=b_md and ma_cd=b_ma_dvi and (nv=b_nv or (b_nv='AL' and ngay<b_ngay_d));
    insert into kh_ma_han select b_ma_dvi,b_md,ma,b_nv,' ',b_ngay_d,'',sysdate,b_nsd,b_idvung from ht_ma_dvi where b_ma_dvi in (ma,ma_ct);
    insert into kh_ma_han select ma,b_md,b_ma_dvi,b_nv,' ',b_ngay_d,'',sysdate,b_nsd,b_idvung from ht_ma_dvi where ma_ct=b_ma_dvi;

    insert into kh_ma_han_log select b_ngay_log,b_ma_dvi,b_md,ma,b_nv,b_ma_nsd,b_ngay_d,'',sysdate,b_nsd,b_idvung from ht_ma_dvi where b_ma_dvi in (ma,ma_ct);
    insert into kh_ma_han_log select b_ngay_log,ma,b_md,b_ma_dvi,b_nv,b_ma_nsd,b_ngay_d,'',sysdate,b_nsd,b_idvung from ht_ma_dvi where ma_ct=b_ma_dvi;
else
    if b_nv='AL' then
        delete kh_ma_han where ma_dvi=b_ma_dvi and md=b_md and ma_cd=b_ma_cd and ma_nsd=b_ma_nsd and nv=b_nv;
    else
        if b_nsd<>'TIN' then
            delete kh_ma_han where ma_dvi=b_ma_dvi and nsd=b_nsd and md=b_md and ma_cd=b_ma_cd and ma_nsd=b_ma_nsd and (nv=b_nv or (b_nv='AL' and ngay<b_ngay_d));
        else
            delete kh_ma_han where ma_dvi=b_ma_dvi and md=b_md and ma_cd=b_ma_cd and ma_nsd=b_ma_nsd and (nv=b_nv or (b_nv='AL' and ngay<b_ngay_d));
        end if;
    end if;
    insert into kh_ma_han values (b_ma_dvi,b_md,b_ma_cd,b_nv,b_ma_nsd,b_ngay_d,'',sysdate,b_nsd,b_idvung);
    insert into kh_ma_han_log values (b_ngay_log,b_ma_dvi,b_md,b_ma_cd,b_nv,b_ma_nsd,b_ngay_d,'',sysdate,b_nsd,b_idvung);
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HAN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma_cd varchar2,b_nv varchar2)
AS
    b_loi varchar2(100); b_ma_ct varchar2(10); b_dvi_ta varchar2(10):=FTBH_DVI_TA();
begin
-- Nam
if b_ma_dvi<>b_dvi_ta and (b_nv='AL' or b_ma_dvi<>b_ma_cd) then
    b_loi:='loi:Khong co quyen xoa han:loi'; raise PROGRAM_ERROR;
end if;
-- Dan - Xoa han thay doi so lieu
if b_nv is null then b_loi:='loi:Nhap loai nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_nv<>'AL' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,'H');
else
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'MA','H');
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_cd not in(b_ma_dvi,'AL') then
    b_loi:='loi:Khong phai don vi truc thuoc:loi';
    select ma_ct into b_ma_ct from ht_ma_dvi where ma=b_ma_cd;
    --if b_ma_ct is null or b_ma_ct<>b_ma_dvi then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi Table MA_HAN:loi';
if b_ma_cd='AL' then
    delete kh_ma_han where ma_dvi=b_ma_dvi and md=b_md and nv=b_nv and ma_cd in (select ma from ht_ma_dvi where b_ma_dvi in (ma,ma_ct));
    delete kh_ma_han where ma_dvi in(select ma from ht_ma_dvi where ma_ct=b_ma_dvi) and md=b_md and ma_cd=b_ma_dvi and nv=b_nv;
else
    delete kh_ma_han where ma_dvi=b_ma_dvi and (b_nsd='TIN' or nsd=b_nsd) and (trim(b_nsd) is null or ma_nsd=b_nsd) and md=b_md and ma_cd=b_ma_cd and nv=b_nv;
    if b_ma_dvi<>b_ma_cd then
        delete kh_ma_han where ma_dvi=b_ma_cd and (b_nsd='TIN' or nsd=b_nsd) and md=b_md and ma_cd=b_ma_dvi and nv=b_nv;
    end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/