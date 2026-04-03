/*** VAT DONG BAO HIEM ***/
create or replace function FBH_HD_DO_VAT_LOAI(b_ma_dvi varchar2,b_so_id_vat number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra loai
select min(loai) into b_kq from bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
return b_kq;
end;
/
create or replace function FBH_HD_DO_VAT_TONh(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_so_id_tt number; b_ngay_ht number;
begin
-- Dan - Ton chua phat hanh hoa don VAT theo hop dong
delete bh_hd_do_vat_temp1; delete bh_hd_do_vat_temp2;
insert into bh_hd_do_vat_temp2 select distinct a.so_id_tt,a.nha_bh from bh_hd_do_sc_vat a,bh_hd_do_ct b
    where a.ma_dvi=b_ma_dvi and b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_tt=a.so_id_tt
    union
    select distinct a.so_id_tt,a.nha_bh from bh_hd_do_sc_vat a,bh_hd_goc_ttpt b
    where a.ma_dvi=b_ma_dvi and b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_tt=a.so_id_tt;
for r_lp in (select * from bh_hd_do_vat_temp2) loop
    delete bh_hd_do_vat_temp1;
    b_so_id_tt:=r_lp.so_id_tt;
    select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    if b_ngay_ht<>0 then
        insert into bh_hd_do_vat_temp1 select 'R',ma_nt,phi,0,0,0
            from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and
            pt<>'C' and FBH_HD_DO_NH_TXTn(b_ma_dvi,so_id,'D','ph')='K';
    else
        select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
        if b_ngay_ht<>0 then
            insert into bh_hd_do_vat_temp1 select decode(nv,'T','R','V'),ma_nt,tien,0,0,0 from 
                (select nv,ma_nt,sum(tien) tien from bh_hd_do_pt
                where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt group by nv,ma_nt having sum(tien)<>0);
        end if;
    end if;
    insert into bh_hd_do_vat_temp1
        select FBH_HD_DO_VAT_LOAI(b_ma_dvi,so_id_vat),ma_nt,-tien,0,0,0
        from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    select count(*) into b_i1 from 
        (select loai,ma_nt,sum(tien) from bh_hd_do_vat_temp1 group by loai,ma_nt having sum(tien)<>0);
    if b_i1<>0 then b_kq:='C'; exit; end if;
end loop;
delete bh_hd_do_vat_temp1; delete bh_hd_do_vat_temp2;
return b_kq;
end;
/
create or replace procedure PBH_HD_DO_VAT_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(2000); b_so_id_tt number; b_so_id_vat number;
    b_ngay_ht number; b_so_ct varchar2(20); b_nha_bh varchar2(20); b_loai varchar2(1); cs_lke clob:=''; 
begin
-- Dan - Ton chua phat hanh hoa don VAT
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_vat,loai,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_so_id_vat,b_loai,b_nha_bh using b_oraIn;
insert into temp_3(n1) select so_id_tt from bh_hd_do_sc_vat where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh;
if b_so_id_vat<>0 then
    select count(*) into b_i1 from bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat and nha_bh=b_nha_bh;
    if b_i1<>0 then
        insert into temp_3(n1) select so_id_tt from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
    end if;
end if;
for r_lp in (select distinct n1 so_id_tt from temp_3) loop
    delete temp_1;
    b_so_id_tt:=r_lp.so_id_tt;
    select nvl(min(ngay_ht),0),min(so_ct) into b_ngay_ht,b_so_ct from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    if b_ngay_ht<>0 then
        insert into temp_1(c1,c2,n5,n6,n7,n8) select 'R',ma_nt,phi,phi_qd,thue,thue_qd
            from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and
			pt<>'C' and FBH_HD_DO_NH_TXTn(b_ma_dvi,so_id,'D','ph')='K';
    else
        select nvl(min(ngay_ht),0),min(so_ct) into b_ngay_ht,b_so_ct from bh_hd_do_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
        if b_ngay_ht<>0 then
            insert into temp_1(c1,c2,n5,n6,n7,n8) select decode(nv,'T','R','V'),ma_nt,tien,tien_qd,thue,thue_qd
                from (select nv,ma_nt,sum(tien) tien,sum(tien_qd) tien_qd,sum(thue) thue,sum(thue_qd) thue_qd
                from bh_hd_do_pt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt group by nv,ma_nt having sum(tien)<>0);
        end if;
    end if;
	insert into temp_1(c1,c2,n5,n6,n7,n8)
		select FBH_HD_DO_VAT_LOAI(b_ma_dvi,so_id_vat),ma_nt,-tien,-tien_qd,-thue,-thue_qd
		from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    insert into temp_2(n9,c3,n1,c1,c2,n5,n6,n7,n8)
        select b_ngay_ht,b_so_ct,b_so_id_tt,c1,c2,sum(n5),sum(n6),sum(n7),sum(n8) from temp_1 group by c1,c2;
end loop;
delete temp_2 where n5=0 or c1<>b_loai;
select JSON_ARRAYAGG(json_object('so_id_tt' value n1,'ngay_ht' value n9,
    'so_ct' value c3,'ma_nt' value c2,'tien' value n5,'tien_qd' value n6,
    'thue' value n7,'thue_qd' value n8,'chon' value '') order by n1,c1,c2 returning clob) into cs_lke from temp_2;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
delete temp_1; delete temp_2; delete temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_vat number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_vat:=FKH_JS_GTRIn(b_oraIn,'so_id_vat');
b_loi:='loi:Phat hanh VAT da xoa:loi';
select json_object(ngay_ht,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) into dt_ct
	from bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
select JSON_ARRAYAGG(json_object(bt) order by bt) into dt_dk
    from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_hd_do_vat_txt where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
select json_object('so_id_vat' value b_so_id_vat,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_do_vat where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_vat,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
            (select so_id_vat,nha_bh,rownum sott from bh_hd_do_vat where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_vat desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_do_vat where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_vat,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
            (select so_id_vat,nha_bh,rownum sott from bh_hd_do_vat where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_vat desc) 
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_hd_do_vat where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_vat,rownum sott from bh_hd_do_vat where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_vat desc) where so_id_vat<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_vat,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
        (select so_id_vat,nha_bh,rownum sott from bh_hd_do_vat where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_vat desc)
        where sott between b_tu and b_den;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_do_vat where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_vat,rownum sott from bh_hd_do_vat where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_vat desc) where so_id_vat<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_vat,'nha_bh' value FBH_MA_NBH_TEN(nha_bh)) returning clob) into cs_lke from
        (select so_id_vat,nha_bh,rownum sott from bh_hd_do_vat where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_vat desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_nha_bh varchar2(20);
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(ngay_ht,loai,so_don,so_id_vat)
    order by ngay_ht desc,loai,so_don returning clob) into cs_lke from
    (select ngay_ht,loai,so_don,so_id_vat from bh_hd_do_vat
    where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',nha_bh)
    order by ngay_ht desc,loai,so_don) where rownum<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_vat number,b_loi out varchar2)
AS
    b_nsd_c varchar2(10); b_ngay_ht number; b_bt number; a_so_id_tt pht_type.a_num;
begin
-- Dan - Xoa hoa don VAT
select min(nsd),nvl(min(ngay_ht),0) into b_nsd_c,b_ngay_ht from bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
if b_ngay_ht=0 then b_loi:=''; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','DO');
if b_loi is not null then return; end if;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
b_bt:=0;
for r_lp in(select distinct so_id_tt from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat) loop
    b_bt:=b_bt+1; a_so_id_tt(b_bt):=r_lp.so_id_tt;
end loop;
delete bh_hd_do_vat_txt where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
delete bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
delete bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
for b_lp in 1..b_bt loop
    PBH_HD_DO_TH_VAT(b_ma_dvi,a_so_id_tt(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_NH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_vat number,
    b_ngay_ht number,b_loai varchar2,b_nha_bh varchar2,b_so_don varchar2,
    a_so_id_tt pht_type.a_num,a_ma_nt pht_type.a_var,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,
    a_thue pht_type.a_num,a_thue_qd pht_type.a_num,
    dt_ct clob,dt_dk clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_phong varchar2(10);
    b_ten nvarchar2(500); b_dchi nvarchar2(500); b_tax varchar2(20);
begin
-- Dan - Nhap hoa don VAT
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','DO');
if b_loi is not null then return; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
select ten,dchi,cmt into b_ten,b_dchi,b_tax from bh_ma_nbh where ma=b_nha_bh;
insert into bh_hd_do_vat values(b_ma_dvi,b_so_id_vat,b_ngay_ht,b_loai,b_nha_bh,
    b_ten,b_dchi,b_tax,b_so_don,b_ngay_ht,b_phong,b_nsd,sysdate);
for b_lp in 1..a_so_id_tt.count loop
    insert into bh_hd_do_vat_ct values(b_ma_dvi,b_so_id_vat,b_lp,
        a_so_id_tt(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
end loop;
insert into bh_hd_do_vat_txt values(b_ma_dvi,b_so_id_vat,'dt_ct',dt_ct);
insert into bh_hd_do_vat_txt values(b_ma_dvi,b_so_id_vat,'dt_dk',dt_dk);
for b_lp in 1..a_so_id_tt.count loop
    b_i1:=0; b_i2:=b_lp-1;
    for b_lp1 in 1..b_i2 loop
        if a_so_id_tt(b_lp1)=a_so_id_tt(b_lp) then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        PBH_HD_DO_TH_VAT(b_ma_dvi,a_so_id_tt(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob; dt_dk clob;
    b_so_id_vat number; b_ngay_ht number; b_loai varchar2(1); b_nha_bh varchar2(20); b_so_don varchar2(20);
    a_so_id_tt pht_type.a_num; a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
begin
-- Dan - Nhap hoa don VAT
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_vat:=FKH_JS_GTRIn(b_oraIn,'so_id_vat');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('ngay_ht,loai,nha_bh,so_don');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_loai,b_nha_bh,b_so_don using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_tt,ma_nt,tien,thue,tien_qd,thue_qd');
EXECUTE IMMEDIATE b_lenh bulk collect into
    a_so_id_tt,a_ma_nt,a_tien,a_thue,a_tien_qd,a_thue_qd using dt_dk;
if b_so_id_vat>0 then
    PBH_HD_DO_VAT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_vat,b_loi);
else
    PHT_ID_MOI(b_so_id_vat,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_don:=nvl(trim(b_so_don),' ');
if b_loai='V' and b_so_don=' ' then
    b_loi:='loi:Nhap so hoa don dau vao:loi'; raise PROGRAM_ERROR;
end if;
if a_so_id_tt.count=0 then
    b_loi:='loi:Nhap thanh toan phat sinh:loi'; raise PROGRAM_ERROR;
end if;
PBH_HD_DO_VAT_NH_NH(b_ma_dvi,b_nsd,b_so_id_vat,b_ngay_ht,b_loai,b_nha_bh,b_so_don,
    a_so_id_tt,a_ma_nt,a_tien,a_tien_qd,a_thue,a_thue_qd,dt_ct,dt_dk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_vat' value b_so_id_vat) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_vat number;
begin
-- Dan - Xoa hoa don VAT dong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_vat:=FKH_JS_GTRIn(b_oraIn,'so_id_vat');
if b_so_id_vat is null or b_so_id_vat=0 then
    b_loi:='loi:Chon xoa phat hanh VAT:loi'; raise PROGRAM_ERROR;
end if;
PBH_HD_DO_VAT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_vat,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
