/*** KIEU TINH THUE ***/
create or replace procedure PBH_HT_THUE_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select a.*,'' ngay_ch, ngay ngay_so from bh_ht_thue a where ma_dvi=b_ma_dvi order by ngay;
end;
/
create or replace procedure PBH_HT_THUE_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Chi tiet ma thue
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select * from bh_ht_thue where ma_dvi=b_ma_dvi and ngay=b_ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HT_THUE_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_noPhi varchar2,b_hanTT varchar2,b_tl_hh varchar2,b_tl_ht varchar2,
	b_hh_gt varchar2,b_hh_mg varchar2,b_hh_ht varchar2,b_hh_th varchar2,b_hh_do varchar2,b_hh_ta varchar2,
	b_gcn_2b varchar2,b_gcn_xe varchar2,b_gcn_ng varchar2,b_gcn_hang varchar2,b_gcn_tau varchar2,
	b_gcn_phh varchar2,b_gcn_pkt varchar2,b_gcn_ptn varchar2,b_gcn_td varchar2,b_phi_do varchar2,
	b_tt_do varchar2,b_ch_ta varchar2,b_gh_phh varchar2,b_gh_pkt varchar2,b_gh_hang varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if b_tl_hh is null or b_tl_hh not in('C','K') or b_tl_ht is null or b_tl_ht not in('C','K') or b_hh_ht is null or b_hh_gt not in('C','K') then
	b_loi:='loi:Sai kieu tinh hoa hong:loi'; raise PROGRAM_ERROR;
end if;
if b_hh_mg is null or b_hh_mg not in('C','T','K')
	or b_hh_ht is null or b_hh_ht not in('C','T','K')
	or b_hh_th is null or b_hh_th not in('T','Q','N')
	or b_hh_do is null or b_hh_do not in('C','K')
	or b_hh_ta is null or b_hh_ta not in('C','K')
	or b_gh_phh is null or b_gh_phh not in('C','K')
	or b_gh_pkt is null or b_gh_pkt not in('C','K')
	or b_gh_hang is null or b_gh_hang not in('C','K') then
	b_loi:='loi:Sai kieu quan ly:loi'; raise PROGRAM_ERROR;
end if;
if b_gcn_2b is null or b_gcn_2b not in('K','T','H','G') or b_gcn_xe is null or b_gcn_xe not in('K','T','H','G')
	or b_gcn_ng is null or b_gcn_ng not in('K','T','H','G') or b_gcn_hang is null or b_gcn_hang not in('K','C')
	or b_gcn_tau is null or b_gcn_tau not in('K','T','H','G') or b_gcn_phh is null or b_gcn_phh not in('K','C')
	or b_gcn_pkt is null or b_gcn_pkt not in('K','C') or b_gcn_ptn is null or b_gcn_ptn not in('K','C')
	or b_gcn_td is null or b_gcn_td not in('K','C') then
	b_loi:='loi:Sai kieu quan ly an chi:loi'; raise PROGRAM_ERROR;
end if;
if b_phi_do is null or b_phi_do not in('K','C') then b_loi:='loi:Sai kieu tinh phi dong BH:loi'; raise PROGRAM_ERROR; end if;
if b_tt_do is null or b_tt_do not in('K','C') then b_loi:='loi:Sai kieu xu ly thanh toan dong BH:loi'; raise PROGRAM_ERROR; end if;
if b_ch_ta is null or b_ch_ta not in('K','C') then b_loi:='loi:Sai kieu xu ly chuyen tai:loi'; raise PROGRAM_ERROR; end if;
delete bh_ht_thue where ma_dvi=b_ma_dvi and ngay=b_ngay;
insert into bh_ht_thue values(b_ma_dvi,b_ngay,b_noPhi,b_hanTT,b_tl_hh,b_tl_ht,b_hh_gt,b_hh_mg,b_hh_ht,b_hh_th,b_hh_do,b_hh_ta,
	b_gcn_2b,b_gcn_xe,b_gcn_ng,b_gcn_hang,b_gcn_tau,b_gcn_phh,b_gcn_pkt,b_gcn_ptn,b_gcn_td,b_phi_do,b_tt_do,
	b_ch_ta,b_gh_phh,b_gh_pkt,b_gh_hang,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HT_THUE_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
	b_loi varchar2(100);
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
delete bh_ht_thue where ma_dvi=b_ma_dvi and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HT_THUE_TS(b_ma_dvi varchar2,b_ngay_ht number,b_nv varchar2,b_de varchar2:='K') return varchar2
AS
	b_kq varchar2(1):=b_de; b_lenh varchar2(100); b_ngay number;
begin
-- Dan - Xac dinh kieu quan ly
select nvl(max(ngay),0) into b_ngay from bh_ht_thue where ma_dvi=b_ma_dvi and ngay<=b_ngay_ht;
if b_ngay<>0 then
	b_lenh:='select min('||b_nv||') from bh_ht_thue where ma_dvi= :ma_dvi and ngay= :ngay';
	EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_ngay;
	if trim(b_kq) is null then b_kq:=b_de; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HT_THUE_TT(b_ma_dvi varchar2,b_ngay_ht number) return number
AS
    b_kq number:=0; b_lenh varchar2(100); b_ngay number; b_hanTT varchar2(3);
begin
-- Dan - Xac dinh kieu quan ly
select nvl(max(ngay),0) into b_ngay from bh_ht_thue where ma_dvi=b_ma_dvi and ngay<=b_ngay_ht;
if b_ngay<>0 then
    b_lenh:='select min(hanTT) from bh_ht_thue where ma_dvi= :ma_dvi and ngay= :ngay';
    EXECUTE IMMEDIATE b_lenh into b_hanTT using b_ma_dvi,b_ngay;
    if trim(b_hanTT) is null then b_hanTT:='0'; end if;
    b_kq:=PKH_LOC_CHU_SO(b_hanTT,'F','F');
end if;
return b_kq;
end;
/
create or replace procedure PBH_HT_THUE_TS
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_nv varchar2,b_kq out varchar2)
AS
begin
-- Dan - Hoi kieu quan ly
b_kq:=FBH_HT_THUE_TS(b_ma_dvi,b_ngay_ht,b_nv);
end;
/
/*** MA LINH VUC KINH DOANH ***/
create or replace PROCEDURE PBH_MA_LVUC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lvuc where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,tc,nsd,row_number() over (order by ma) sott from bh_ma_lvuc
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lvuc where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,tc,nsd,row_number() over (order by ma) sott from bh_ma_lvuc
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
-- may a dan
create or replace procedure PBH_MA_LVUC_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt) into cs_ct from bh_ma_lvuc where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LVUC_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Minh - Xem theo ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_lvuc where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_lvuc where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,tc,nsd,row_number() over (order by ma) sott from bh_ma_lvuc
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LVUC_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_lvuc where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* MA DIEU KHOAN */
create or replace procedure FBH_MA_DK_KTRA(b_ma_dvi_n varchar2,b_nv varchar2,b_ma_dk varchar2,b_loi out varchar2)
AS
	b_i1 number; a_ma_dk pht_type.a_var; b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Kiem tra dieu khoan
PKH_CH_ARR(b_ma_dk,a_ma_dk);
for b_lp in 1..a_ma_dk.count loop
	b_loi:='loi:Chua dang ky dieu khoan '||a_ma_dk(b_lp)||':loi';
	select 0 into b_i1 from (select nv from bh_ma_dk where ma_dvi=b_ma_dvi and ma=a_ma_dk(b_lp)) where nv in('*',b_nv);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_MA_DK_KTRA(b_ma_dvi_n varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ma_dk varchar2)
AS
	b_loi varchar2(100); b_ma_dvi varchar2(20):=FTBH_DVI_TA();
begin
-- Dan - Kiem tra dieu khoan
FBH_MA_DK_KTRA(b_ma_dvi,b_nv,b_ma_dk,b_loi);
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
end;
/
/*** MA THONG KE BAO HIEM ***/
create or replace PROCEDURE PBH_MA_LCP_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
-- Minh updated - liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; commit;
if b_tim is null then
    insert into temp_1(c1,c2,c3,c4,c5,n1) select ma,ma_ct,ten,tc,nsd,row_number() over (order by ma) sott from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma;
    update temp_1 set c2=' ' where c2 is null;
    open cs_lke for select c1 ma,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,c2 ma_ct,c3 ten,c4 tc,c5 nsd
        from temp_1 where n1 between b_tu and b_den start with c2=' ' CONNECT BY prior c1=c2;
else
    insert into temp_1(c1,c2,c3,c4,c5,n1) select ma,ma_ct,ten,tc,nsd,row_number() over (order by ma) sott from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma;
    update temp_1 set c2=' ' where c2 is null;
    open cs_lke for select c1 ma,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,c2 ma_ct,c3 ten,c4 tc,c5 nsd
        from temp_1 where upper(c3) like b_tim and n1 between b_tu and b_den start with c2=' ' CONNECT BY prior c1=c2;
end if;
end;
/
create or replace procedure PBH_MA_LCP_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem ma thong ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,tc,ma_ct,nsd 
	from (select * from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma)
	start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
end;
/
create or replace procedure PBH_MA_LCP_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nx varchar2,
	cs1 out pht_type.cs_type,b_ma varchar2,b_ten nvarchar2:='',b_tc varchar2:='C',b_ma_ct varchar2:=' ')
AS
	b_loi varchar2(100); b_i1 number;
begin
-- Dan - Nhap ma thong ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ma is null or trim(b_ma) is null then b_loi:='loi:Nhap ma thong ke:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
if b_nx='N' then
	if b_tc is null or b_tc not in('T','C') then b_loi:='loi:Tinh chat:T,C:loi'; raise PROGRAM_ERROR; end if;
	if b_ma_ct is null then b_loi:='loi:Sai ma bac cao:loi'; raise PROGRAM_ERROR;
	elsif b_ma_ct<>' ' then
		if  b_ma_ct=b_ma then b_loi:='loi:Sai ma quan ly:loi'; raise PROGRAM_ERROR; end if;
		select count(*) into b_i1 from bh_ma_lcp where ma_dvi=b_ma_dvi and ma=b_ma_ct;
		if b_i1=0 then b_loi:='loi:Ma bac cao chua dang ky:loi'; raise PROGRAM_ERROR; end if;
	end if;
else
	select count(*) into b_i1 from bh_ma_lcp where ma_dvi=b_ma_dvi and ma_ct=b_ma;
	if b_i1>0 then b_loi:='loi:Con ma chi tiet:loi'; raise PROGRAM_ERROR; end if;
end if;
delete bh_ma_lcp where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then insert into bh_ma_lcp values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_nsd); end if;
commit;
open cs1 for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,tc,ma_ct,nsd 
	from (select * from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma)
	start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LCP_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete temp_1; commit;
select count(*) into b_dong from bh_ma_lcp where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
insert into temp_1(c1,c2,c3,c4,c5,n1) select ma,ma_ct,ten,tc,nsd,row_number() over (order by ma) sott from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma;
    update temp_1 set c2=' ' where c2 is null;
    open cs_lke for select c1 ma,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,c2 ma_ct,c3 ten,c4 tc,c5 nsd
        from temp_1 where n1 between b_tu and b_den start with c2=' ' CONNECT BY prior c1=c2;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LCP_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- MINH - Xem ct
open cs_lke for select * from bh_ma_lcp where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PBH_MA_LCP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma dieu khoan:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham nguoi su dung:loi';
delete bh_ma_lcp where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
/*** KE HOACH NGHIEP VU ***/
create or replace procedure PBH_MA_LHNV_KH_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Chi tiet bang, liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select distinct ngay,kieu,dvi,nsd from bh_ma_lhnv_kh where ma_dvi=b_ma_dvi order by ngay DESC,kieu,dvi;
end;
/
create or replace procedure PBH_MA_LHNV_KH_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_kieu varchar2,b_dvi varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; commit;
insert into temp_1(c1,c2,c3) select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten
	from (select ma,ten,ma_ct from bh_ma_lhnv where ma_dvi=b_ma_dvi order by ma)
	start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
update temp_1 set n1=(select kh from bh_ma_lhnv_kh where ma_dvi=b_ma_dvi and ngay=b_ngay and kieu=b_kieu and dvi=b_dvi and ma=c2);
update temp_1 set n1=0 where n1 is null;
open cs1 for select c1 xep,c2 ma,c3 ten,n1 kh from temp_1 order by c2;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_KH_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_kieu varchar2,
	b_dvi varchar2,dk_ma pht_type.a_var,dk_kh pht_type.a_num,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100); b_i1 number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if b_kieu is null or b_kieu not in('P','C') then b_loi:='loi:Sai kieu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi:loi';
if b_dvi is null then raise PROGRAM_ERROR; end if;
if b_kieu='C' then
	select 0 into b_i1 from ht_ma_dvi where ma=b_dvi;
else	select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_dvi;
end if;
if dk_ma.count=0 then b_loi:='loi:Chua nhap ma thong ke bao hiem:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..dk_ma.count loop
	b_loi:='loi:Sai so lieu chi tiet dong '||to_char(b_lp)||':loi';
	if dk_ma(b_lp) is null or dk_kh(b_lp) is null then raise PROGRAM_ERROR; end if;
	select 0 into b_i1 from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=dk_ma(b_lp);
end loop;
b_loi:='loi:Loi Table bh_ma_lhnv_kh:loi';
delete bh_ma_lhnv_kh where ma_dvi=b_ma_dvi and ngay=b_ngay and kieu=b_kieu and dvi=b_dvi;
for b_lp in 1..dk_ma.count loop
	insert into bh_ma_lhnv_kh values(b_ma_dvi,b_ngay,b_kieu,b_dvi,dk_ma(b_lp),dk_kh(b_lp),b_nsd);
end loop;
commit;
open cs1 for select distinct ngay,kieu,dvi,nsd from bh_ma_lhnv_kh where ma_dvi=b_ma_dvi order by ngay DESC,kieu,dvi;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_KH_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_kieu varchar2,b_dvi varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_ma_lhnv_kh where ma_dvi=b_ma_dvi and ngay=b_ngay and kieu=b_kieu and dvi=b_dvi;
commit;
open cs1 for select distinct ngay,kieu,dvi,nsd from bh_ma_lhnv_kh where ma_dvi=b_ma_dvi order by ngay DESC,kieu,dvi;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** KE HOACH MA THONG KE ***/
create or replace procedure PBH_MA_LCP_KH_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Chi tiet bang, liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select distinct ngay,kieu,dvi,nsd from bh_ma_lcp_kh where ma_dvi=b_ma_dvi order by ngay DESC,kieu,dvi;
end;
/
create or replace procedure PBH_MA_LCP_KH_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_kieu varchar2,b_dvi varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; commit;
insert into temp_1(c1,c2,c3) select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten
	from (select ma,ten,ma_ct from bh_ma_lcp where ma_dvi=b_ma_dvi order by ma)
	start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
update temp_1 set n1=(select kh from bh_ma_lcp_kh where ma_dvi=b_ma_dvi and ngay=b_ngay and kieu=b_kieu and dvi=b_dvi and ma=c2);
update temp_1 set n1=0 where n1 is null;
open cs1 for select c1 xep,c2 ma,c3 ten,n1 kh from temp_1;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LCP_KH_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_kieu varchar2,b_dvi varchar2,
	dk_ma pht_type.a_var,dk_kh pht_type.a_num,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100); b_i1 number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if dk_ma.count=0 then b_loi:='loi:Chua nhap ma thong ke bao hiem:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..dk_ma.count loop
	b_loi:='loi:Sai so lieu chi tiet dong '||to_char(b_lp)||':loi';
	if dk_ma(b_lp) is null or dk_kh(b_lp) is null then raise PROGRAM_ERROR; end if;
	select 0 into b_i1 from bh_ma_lcp where ma_dvi=b_ma_dvi and ma=dk_ma(b_lp);
end loop;
b_loi:='loi:Loi Table bh_ma_lcp_kh:loi';
delete bh_ma_lcp_kh where ma_dvi=b_ma_dvi and ngay=b_ngay and kieu=b_kieu and dvi=b_dvi;
for b_lp in 1..dk_ma.count loop
	insert into bh_ma_lcp_kh values(b_ma_dvi,b_ngay,b_kieu,b_dvi,dk_ma(b_lp),dk_kh(b_lp),b_nsd);
end loop;
commit;
open cs1 for select distinct ngay,kieu,dvi,nsd from bh_ma_lcp_kh where ma_dvi=b_ma_dvi order by ngay DESC,kieu,dvi;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LCP_KH_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_kieu varchar2,b_dvi varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_ma_lcp_kh where ma_dvi=b_ma_dvi and ngay=b_ngay and kieu=b_kieu and dvi=b_dvi;
commit;
open cs1 for select distinct ngay,kieu,dvi,nsd from bh_ma_lcp_kh where ma_dvi=b_ma_dvi order by ngay DESC,kieu,dvi;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** MA LOAI HINH BH BO TAI CHINH ***/
/*** MA LOAI vay ***/
create or replace procedure PBH_MA_VAY_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem ma loai vay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from bh_ma_vay where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PBH_MA_VAY_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nx varchar2,cs1 out pht_type.cs_type,b_ma varchar2,b_ten nvarchar2:='')
AS
	b_loi varchar2(100);
begin
-- Dan - Nhap ma loai vay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ma is null or trim(b_ma)='' then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_vay where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then insert into bh_ma_vay values (b_ma_dvi,b_ma,b_ten,b_nsd); end if;
commit;
open cs1 for select * from bh_ma_vay where ma_dvi=b_ma_dvi order by ma;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Muc do ton that ***/
create or replace procedure PBH_MA_MD_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
--  Xem ma muc do ton that
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from bh_ma_md where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace PROCEDURE PBH_MA_MD_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
-- Minh updated - lke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_md where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_md
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_md where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_md
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_MA_MD_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- MINH - Xem ct
open cs_lke for select * from bh_ma_md where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PBH_MA_MD_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma muc do ton that
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma muc do:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_md where ma_dvi=b_ma_dvi and ma=b_ma;
insert into bh_ma_md values (b_ma_dvi,b_ma,b_ten,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_MD_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Minh - Xem theo ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_md where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_md where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_md
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_MD_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma muc do ton that
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma muc do:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_md where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Nguyen nhan ***/
create or replace procedure PBH_MA_NN_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Ngan - Xem ma nguyen nhan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from bh_ma_nn where ma_dvi=b_ma_dvi order by ten;
end;
/
create or replace PROCEDURE PBH_MA_NN_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
-- Minh updated - lke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nn where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_nn
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_nn where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_nn
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_MA_NN_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nx varchar2,cs_lke out pht_type.cs_type,b_ma varchar2,b_ten nvarchar2:='')
AS
	b_loi varchar2(100);
begin
-- - Nhap ma nguyen nhan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ma is null or trim(b_ma)='' then b_loi:='loi:Nhap ma nguyen nhan:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_nn where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then
	insert into bh_ma_nn values (b_ma_dvi,b_ma,b_ten,b_nsd);
end if;
commit;
open cs_lke for select * from bh_ma_nn where ma_dvi=b_ma_dvi order by ma;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NN_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- MINH - Xem ct
open cs_lke for select * from bh_ma_nn where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PBH_MA_NN_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Minh - Xem theo ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_nn where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_nn where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_nn
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_nn where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** MA QUY LOI ***/
create or replace procedure PBH_MA_QLOI_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Ngan - Xem ma quy loi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from bh_ma_qloi where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PBH_MA_QLOI_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nx varchar2,cs_lke out pht_type.cs_type,b_ma varchar2,b_ten nvarchar2:='')
AS
	b_loi varchar2(100);
begin
-- - Nhap ma quy loi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ma is null or trim(b_ma)='' then b_loi:='loi:Nhap ma quy loi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_qloi where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then
	insert into bh_ma_qloi values (b_ma_dvi,b_ma,b_ten,b_nsd);
end if;
commit;
open cs_lke for select * from bh_ma_qloi where ma_dvi=b_ma_dvi order by ma;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Ma hau qua ***/
create or replace procedure PBH_MA_HQ_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Giang - Xem ma hau qua
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from bh_ma_hq where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PBH_MA_HQ_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nx varchar2,cs1 out pht_type.cs_type,b_ma varchar2,b_ten nvarchar2:='')
AS
	b_loi varchar2(100);
begin
-- Giang- Nhap ma hau qua
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ma is null or trim(b_ma)='' then b_loi:='loi:Nhap ma hau qua:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_hq where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then
	insert into bh_ma_hq values (b_ma_dvi,b_ma,b_ten,b_nsd);
end if;
commit;
open cs1 for select * from bh_ma_hq where ma_dvi=b_ma_dvi order by ma;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--/* MA TY LE THUONG TAT*/
create or replace procedure PBH_MA_TLE_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	cs_bh_ma_tle out pht_type.cs_type,b_ma varchar2:='')
AS
	b_loi varchar2(100);
begin
--  Xem ma ty le thuong tat
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_ma is null then
	open cs_bh_ma_tle for select * from bh_ma_tle where ma_dvi=b_ma_dvi order by ma;
else	open cs_bh_ma_tle for select * from bh_ma_tle  where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
end;
/
create or replace procedure PBH_MA_TLE_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_nx varchar2,cs_bh_ma_tle out pht_type.cs_type,
	b_ma varchar2,b_ten nvarchar2:='',b_ty_le varchar2:='')
AS
	b_loi varchar2(100);
begin
-- - Nhap ma ty le thuong tat
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then
	b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_ma is null or trim(b_ma)='' then
	b_loi:='loi:Nhap ma ty le thuong tat:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_tle where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then
	insert into bh_ma_tle values (b_ma_dvi,b_ma,b_ten,b_ty_le,b_nsd);
end if;
commit;
open cs_bh_ma_tle for select * from bh_ma_tle where ma_dvi=b_ma_dvi order by ma;
exception
	when others then rollback; raise_application_error(-20105,b_loi);
end;
/
--thu tuc tuyen van chuyen
create or replace procedure PBH_MA_TVC_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	cs_bh_ma_tvc out pht_type.cs_type,b_ma varchar2:='')
AS
	b_loi varchar2(100);
begin
-- Giang - Xem ma tuyen van chuyen
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_ma is null then
	open cs_bh_ma_tvc for select * from bh_ma_tvc where ma_dvi=b_ma_dvi order by ma;
else	open cs_bh_ma_tvc for select * from bh_ma_tvc where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
end;
/
create or replace procedure PBH_MA_TVC_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_nx varchar2,cs_bh_ma_tvc out pht_type.cs_type,
	b_ma varchar2,b_ten nvarchar2:='')
AS
	b_loi varchar2(100);b_i1 number;b_c10 varchar2(10);
begin
-- Giang - Nhap ma tuyen van chuyen
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nx is null or b_nx not in ('N','X') then
	b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_ma is null or trim(b_ma)='' then
	b_loi:='loi:Nhap ma tuyen van chuyen:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_tvc where ma_dvi=b_ma_dvi and ma=b_ma;
if b_nx='N' then
	insert into bh_ma_tvc values (b_ma_dvi,b_ma,b_ten,b_nsd);
end if;
commit;
open cs_bh_ma_tvc for select * from bh_ma_tvc where ma_dvi=b_ma_dvi order by ma;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

/*** HUONG KHAC ***/
create or replace function FBH_MA_HK_TEN(b_ma_dvi varchar2,b_ma varchar2) return nvarchar2
AS
	b_kq nvarchar2(200);
begin
-- Dan - Tra ten ma huong khac
select min(ten) into b_kq from bh_ma_hk where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace PROCEDURE PBH_MA_HK_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
-- Minh updated - lke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_hk where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,kieu,nsd,row_number() over (order by ma) sott from bh_ma_hk
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_hk where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,kieu,nsd,row_number() over (order by ma) sott from bh_ma_hk
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_MA_HK_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- MINH - Xem ct
open cs_lke for select * from bh_ma_hk where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PBH_MA_HK_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Minh - Xem theo ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_hk where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_hk where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,kieu,nsd,row_number() over (order by ma) sott from bh_ma_hk
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_HK_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_kieu varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_kieu is null or b_kieu not in('C','K') then b_loi:='loi:Sai kieu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_hk where ma_dvi=b_ma_dvi and ma=b_ma;
insert into bh_ma_hk values (b_ma_dvi,b_ma,b_ten,b_kieu,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_HK_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_hk where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** NHOM NGHE ***/
create or replace procedure PBH_MA_NH_NGH_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Xem ma nhom nghe
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from bh_ma_nh_ngh where ma_dvi=b_ma_dvi order by ten;
end;
/
create or replace PROCEDURE PBH_MA_NH_NGH_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nh_ngh where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_nh_ngh
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_rr where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_nh_ngh
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_MA_NH_NGH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- MINH - Xem ct
open cs_lke for select * from bh_ma_nh_ngh where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PBH_MA_NH_NGH_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_nh_ngh where ma_dvi=b_ma_dvi and ma=b_ma;
insert into bh_ma_nh_ngh values (b_ma_dvi,b_ma,b_ten,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NH_NGH_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Minh - Xem theo ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_nh_ngh where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_nh_ngh where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_nh_ngh
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NH_NGH_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_nh_ngh where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

/*** DOI TUONG ***/
create or replace procedure PBH_MA_DT_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Xem ma doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from bh_ma_dt where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace PROCEDURE PBH_MA_DT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - created
-- Minh updated - lke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_dt where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_dt
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dt where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_dt
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_MA_DT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- MINH - Xem ct
open cs_lke for select * from bh_ma_dt where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PBH_MA_DT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Minh - Xem theo ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_dt where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_dt where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,nsd,row_number() over (order by ma) sott from bh_ma_dt
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DT_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_dt where ma_dvi=b_ma_dvi and ma=b_ma;
insert into bh_ma_dt values (b_ma_dvi,b_ma,b_ten,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DT_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_ma_dt where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** NGAY NHAP LUI THEO NGHIEP VU ***/
create or replace function FBH_NV_NGAY(b_ma_dvi varchar2,b_nv varchar2,b_ngay number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra lui ngay theo nghiep vu
select nvl(min(ngay),0) into b_i1 from bh_nv_ngay where ma_dvi=b_ma_dvi and nv=b_nv;
if PKH_NG_CSO(sysdate-b_i1)<=b_ngay then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_NV_NGAY_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(200); b_nvq varchar2(10);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select * from bh_nv_ngay where ma_dvi=b_ma_dvi order by nv;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NV_NGAY_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nv is null then b_loi:='loi:Nhap nghiep vu:loi'; raise PROGRAM_ERROR; end if;
delete bh_nv_ngay where ma_dvi=b_ma_dvi and nv=b_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NV_NGAY_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ngay number)
AS
    b_loi varchar2(200);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nv is null or b_ngay is null then b_loi:='loi:Sai so lieu nhap:loi'; raise PROGRAM_ERROR; end if;
delete bh_nv_ngay where ma_dvi=b_ma_dvi and nv=b_nv;
insert into bh_nv_ngay values(b_ma_dvi,b_nv,b_ngay,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/


create or replace procedure PBH_MA_BV_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ct
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from bh_ma_bv where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_BV_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_bv where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from bh_ma_bv where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from bh_ma_bv
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_MA_BV_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - lke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_tim) is null then
    select count(*) into b_dong from bh_ma_bv where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from bh_ma_bv
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_bv where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from bh_ma_bv
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_QTAC_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); cs_lke clob:=''; b_nv varchar2(10);
    b_lenh varchar2(1000);
begin
-- Tra ma quy tac theo nv
b_lenh:=FKH_JS_LENH('nv');
EXECUTE IMMEDIATE b_lenh into b_nv using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nv,'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_ma_qtac where nv=b_nv;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MAU_AC_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_loai_ac nvarchar2(100); b_nv varchar2(10); b_vp varchar(20);
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete from temp_1;
b_lenh:=FKH_JS_LENH('ma,nv');
EXECUTE IMMEDIATE b_lenh into b_loai_ac,b_nv using b_oraIn;
select min(ma) into b_vp from ht_ma_dvi where vp='C';
insert into temp_1(c1,c3,c4,c5) select ma_dvi,nv||'>'||ma,ma,nv from hd_ma_hd where ma_dvi = b_vp and nv in(b_nv) and ma_nhom='AC';
--select count(*) into b_dong from hd_ma_hd where ma_dvi=b_ma_dvi and ma_nhom='AC' and UPPER(mau)=UPPER(b_loai_ac);
select count(*) into b_dong from hd_sc a, temp_1 b where a.ma=b.c3 and a.loai_bp='C' and a.ma_dvi = b_ma_dvi and a.ma_bp=b_nsd;
if b_dong>0 then
    --select JSON_ARRAYAGG(json_object('ma' value mau,ten)) into cs_lke from hd_ma_hd where ma_dvi=b_ma_dvi and ma_nhom='AC' and UPPER(mau)=UPPER(b_loai_ac);
    select JSON_ARRAYAGG(json_object('ma' value PKH_MA_TENl(t.c4))) into cs_lke from 
    (select distinct b.c4 as c4 from hd_sc a, temp_1 b 
           where a.ma=b.c3 and a.loai_bp='C' and a.ma_dvi = b_ma_dvi and a.ma_bp=b_nsd) t;
end if;
delete from temp_1;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
