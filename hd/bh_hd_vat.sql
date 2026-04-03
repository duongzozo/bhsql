/*** VAT ***/
create or replace function FBH_PS_VAT(b_ma_dvi varchar2,b_so_id_tt number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id_vat<>b_so_id_tt;
return b_kq;
end;
/
/*** Phat hanh hoa don VAT ***/
create or replace procedure PBH_HD_VAT_LAN_DOI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id_vat number;
begin
-- Dan - Liet ke lan doi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(so_id_vat),0) into b_so_id_vat from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_id_vat=0 then b_so_id_vat:=b_so_id; end if;
open cs1 for select so_id,ngay_ht,so_don from bh_hd_goc_vat_doi
    where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat order by ngay_ht,so_don;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_VAT_TTRANG
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_vat number,b_vat_doi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra tinh trang CT thanh toan
b_vat_doi:='X';
select count(*) into b_i1 from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
if b_i1<>0 then b_vat_doi:='D'; end if;
end;
/
create or replace procedure PBH_HD_VAT_DON(b_ma_dvi varchar2,b_so_id_vat number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_don varchar2(50); b_ngay_ht number; b_nsd varchar2(10); b_kvat varchar2(1);
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan - day hoa don
b_loi:=''; return;
select ngay_ht,mau,seri,so_don,nsd into b_ngay_ht,a_gcn_m(1),a_gcn_c(1),a_gcn_s(1),b_nsd
    from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
--if b_kvat='N' then return; end if;
b_don:=FKH_GHEP_SERI(a_gcn_m(1),a_gcn_c(1),a_gcn_s(1),' ');
select count(*) into b_i1 from bh_nggcn_ba where ma_dvi=b_ma_dvi and don=b_don;
if b_i1=0 then
    PHD_PH_DON(b_ma_dvi,b_nv,b_ngay_ht,b_so_id_vat,a_gcn_m,a_gcn_c,a_gcn_s,b_nsd,'',b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_VAT_NV
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_vat number,b_dbo out varchar2)
AS
    b_loi varchar2(100); b_nv varchar2(10);
begin
-- Dan - Xac dinh nghiep vu khi phat hanh hoa don
b_dbo:='';
for r_lp in (select distinct so_id from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat) loop
    b_nv:=FBH_HD_NV(b_ma_dvi,r_lp.so_id);
    if b_dbo is null then b_dbo:=b_nv;
    elsif instr(b_dbo,b_nv)=0 then b_dbo:=b_dbo||','||b_nv;
    end if;
end loop;
end;
/
create or replace procedure PBH_HD_VAT_SC_THL
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Tong hop lai so cai VAT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','H');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi;
for r_lp in (select distinct so_id,so_id_tt from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and pt not in('N','H')) loop
    PBH_TH_VAT(b_ma_dvi,r_lp.so_id,r_lp.so_id_tt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_phong varchar2(10); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','VAT','X')<>'C' then
    select count(*) into b_dong from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,don,row_number() over (order by so_id) sott from bh_hd_goc_vat_doi
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,don,row_number() over (order by so_id) sott from bh_hd_goc_vat_doi where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_phong varchar2(10); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','VAT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott from bh_hd_goc_vat_doi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,don,row_number() over (order by so_id) sott from bh_hd_goc_vat_doi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott from bh_hd_goc_vat_doi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,don,row_number() over (order by so_id) sott from bh_hd_goc_vat_doi where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; r_hd bh_hd_goc_vat_doi%rowtype;
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan
b_loi:=''; b_kt:=0;
select * into r_hd from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.so_don is not null then
    b_kt:=b_kt+1;
    a_gcn_m(b_kt):=r_hd.mau; a_gcn_c(b_kt):=r_hd.seri; a_gcn_s(b_kt):=r_hd.so_don;
    PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn_s,r_hd.nsd,'',b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    r_hd bh_hd_goc_vat_doi%rowtype; b_bt number; a_so_id pht_type.a_num; a_so_id_tt pht_type.a_num;
begin
-- Dan - Xoa doi hoa don VAT
b_loi:='';
select * into r_hd from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hd.ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
if trim(r_hd.nsd) is not null and r_hd.nsd<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
PBH_HD_VAT_DOI_DON(b_ma_dvi,b_so_id,'X',b_loi);
if b_loi is not null then return; end if;
delete bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,b_ngay_ht number,
    b_mau_c varchar2,b_seri_c varchar2,b_so_don_c varchar2,
    b_mau varchar2,b_seri varchar2,b_so_don varchar2,b_ngay_bc number)
AS
    b_loi varchar2(100); b_i1 number; b_so_id_g number; b_so_id_vat number; b_phong varchar2(10); b_don varchar2(50);
begin
-- Dan - Nhap hoa don VAT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id>0 then
    PBH_HD_VAT_DOI_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_so_don_c) is null then b_loi:='Nhap so hoa don VAT cu'; raise PROGRAM_ERROR; end if;
if trim(b_so_don) is null then b_loi:='Nhap so hoa don VAT'; raise PROGRAM_ERROR; end if;
b_don:=FKH_GHEP_SERI(b_mau_c,b_seri_c,b_so_don_c,'');
select min(so_id),nvl(min(so_id_vat),0) into b_so_id_g,b_so_id_vat from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and don=b_don;
if b_so_id_vat=0 then
    select nvl(min(so_id_vat),0) into b_so_id_vat from bh_hd_goc_vat where ma_dvi=b_ma_dvi and don=b_don;
    if b_so_id_vat=0 then b_loi:='Hoa don VAT cu '||b_don||' da xoa'; raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
    if b_i1<>0 then b_loi:='Hoa don VAT cu da doi'; raise PROGRAM_ERROR; end if;
    b_so_id_g:=0;
else
    select count(*) into b_i1 from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g;
    if b_i1<>0 then b_loi:='Hoa don VAT cu da doi'; raise PROGRAM_ERROR; end if;
end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd); b_don:=FKH_GHEP_SERI(b_mau,b_seri,b_so_don,'');
b_loi:='loi:Trung so hoa don VAT:loi';
insert into bh_hd_goc_vat_doi values(b_ma_dvi,b_so_id,b_so_id_g,b_so_id_vat,b_ngay_ht,b_phong,b_mau,b_seri,b_so_don,b_don,b_ngay_bc,b_nsd);
PBH_HD_VAT_DOI_DON(b_ma_dvi,b_so_id,'N',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(100);
begin
-- Dan - Nhap doi hoa don VAT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_VAT_DOI_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_VAT_DOI_TIM
      (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_d number,b_ngay_c number,b_so_don varchar2,
      b_tu_n number,b_den_n number,b_dong out number,cs1 out pht_type.cs_type)
AS
      b_loi varchar2(100); b_phong varchar2(10);b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Tim don VAT doi Da sua theo JS
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','VAT','X')='C' then 
insert into temp_1(n1,c2)
    select distinct so_id so_id_th,don from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi
    and ngay_ht between b_ngay_d and b_ngay_c and (b_so_don is null or so_don like b_so_don||'%') order by don;
else b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    insert into temp_1(n1,c2)
    select distinct so_id so_id_th,don from bh_hd_goc_vat_doi where ma_dvi=b_ma_dvi
    and ngay_ht between b_ngay_d and b_ngay_c and phong=b_phong
    and (b_so_don is null or so_don like b_so_don||'%') order by don;
end if;
select count(*) into b_dong from temp_1;  
    if b_den_n=1000000 then b_den:=b_dong; b_tu:=b_dong-b_tu_n; end if;
    open cs1 for select * from (select n1 so_id_th,c2 don,
    row_number() over (order by c2) sott from temp_1 order by c2) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_VAT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_so_hd varchar2(20); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_goc_vat where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_vat,ten) returning clob) into cs_lke from
            (select so_id_vat,ten,rownum sott from bh_hd_goc_vat where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_vat desc)
            where sott between b_tu and b_den;
    end if;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_vat where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_vat,ten) returning clob) into cs_lke from
            (select so_id_vat,ten,rownum sott from bh_hd_goc_vat where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_vat desc) 
            where sott between b_tu and b_den;
    end if;
elsif trim(b_so_hd) is not null then
    select count(*) into b_dong from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat in
        (select distinct so_id_vat from bh_hd_goc_vat_hd where ma_dvi=b_ma_dvi and so_hd=b_so_hd);
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_vat,ten) returning clob) into cs_lke from
            (select so_id_vat,ten,rownum sott from bh_hd_goc_vat where ma_dvi=b_ma_dvi and
                so_id_vat in(select distinct so_id_vat from bh_hd_goc_vat_hd where ma_dvi=b_ma_dvi and so_hd=b_so_hd)
                order by so_id_vat desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HD_VAT_TON_HD(b_ma_dvi varchar2,b_so_hd varchar2,b_ma_kh out varchar2)
AS
    b_so_idD number; b_so_idB number;
begin
-- Dan - Chua phat hanh hoa don VAT theo hop dong
b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_idD);
select min(ma_kh) into b_ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
insert into temp_1(n2) select so_id_tt from bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_idD;
insert into temp_2(n10,n2,n3,n4,n5,n6)
    select t_suat,so_id_tt,sum(ttoan),sum(ttoan_qd),sum(thue),sum(thue_qd)
    from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_idD and pt not in('N','H') and so_id_tt in (select n2 from temp_1)
    group by so_id_tt,t_suat;
insert into temp_2(n10,n2,n3,n4,n5,n6) select t_suat,so_id_tt,sum(-ttoan),sum(-ttoan_qd),sum(-thue),sum(-thue_qd)
    from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt in (select n2 from temp_1) group by so_id_tt,t_suat;
insert into temp_3(n10,n2,n3,n4,n5,n6) select n10,n2,sum(n3),sum(n4),sum(n5),sum(n6) from temp_2
    group by n2,n10 having sum(n3)<>0 or sum(n4)<>0 or sum(n5)<>0 or sum(n6)<>0;
update temp_3 set n9=(select min(ngay_ht) from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=n2);
update temp_3 set n1=b_so_idD,c1=b_so_hd;
end;
/
create or replace procedure FBH_HD_VAT_TON_TT(b_ma_dvi varchar2,b_so_id_tt number,b_ma_kh out varchar2)
AS
    b_ngay_tt number;
begin
-- Dan - Chua phat hanh hoa don VAT theo hop dong
insert into temp_2(n10,n1,n3,n4,n5,n6)
    select t_suat,so_id,sum(ttoan),sum(ttoan_qd),sum(thue),sum(thue_qd) from bh_hd_goc_ttpt where
    ma_dvi=b_ma_dvi and pt not in('N','H') and so_id_tt=b_so_id_tt group by t_suat,so_id;
insert into temp_2(n10,n1,n3,n4,n5,n6) select t_suat,so_id,sum(-ttoan),sum(-ttoan_qd),sum(-thue),sum(-thue_qd)
    from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt group by t_suat,so_id;
insert into temp_3(n10,n1,n3,n4,n5,n6) select n10,n1,sum(n3),sum(n4),sum(n5),sum(n6) from temp_2
    group by n10,n1 having sum(n3)<>0 or sum(n4)<>0 or sum(n5)<>0 or sum(n6)<>0;
select nvl(min(ngay_ht),0),min(ma_kh) into b_ngay_tt,b_ma_kh from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
update temp_3 set n9=b_ngay_tt,c1=FBH_HD_GOC_SO_HD(b_ma_dvi,n1);
end;
/
create or replace procedure PBH_HD_VAT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);  b_lenh varchar2(2000);
    b_phong varchar2(10); b_so_id_tt number; cs_ton clob;
    b_ngay_ht number; b_kvat varchar2(1); b_kdt_ph varchar2(1); b_ma_kt varchar2(20);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_nt varchar2(5); b_t_suat number;
    b_i1 number;
    b_so_idD number;
    b_so_id_tt_s varchar2(100);b_so_id_vat number;
	  b_ty_gia number:=1;b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Tim ton
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,kvat,kdt_ph,ma_kt,ma_kh,so_hd,ma_nt,t_suat,so_id_tt');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_kvat,b_kdt_ph,b_ma_kt,b_ma_kh,b_so_hd,b_ma_nt,b_t_suat,b_so_id_tt using b_oraIn;

select min(ma_nt) into b_ma_nt from bh_hd_goc_tthd where so_id_tt = b_so_id_tt and ma_dvi = b_ma_dvi;

b_ty_gia:=FBH_TT_TRA_TGTT(b_ngay,b_ma_nt);

if b_so_id_tt = 0 then
  if trim(b_so_hd) is not null then
    b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
    select count(*) into b_i1 from bh_hd_goc_tthd where so_id = b_so_idD and ma_dvi = b_ma_dvi;
    if b_i1 <> 0 then
      for r_lp in (select so_id_tt,rownum from bh_hd_goc_tthd where so_id = b_so_idD and ma_dvi = b_ma_dvi)
      loop
          b_so_id_tt_s :=b_so_id_tt_s || r_lp.so_id_tt;
          if r_lp.rownum < b_i1 then b_so_id_tt_s:= b_so_id_tt_s || ','; end if;
      end loop;
    end if;
  end if;
else
  b_so_id_tt_s := b_so_id_tt;
end if;


if trim(b_so_id_tt_s) is not null then
    select count(*) into b_i1 from bh_hd_goc_vat_ct where ma_dvi = b_ma_dvi and so_id_tt in (SELECT TO_NUMBER(REGEXP_SUBSTR(b_so_id_tt_s, '[^,]+', 1, LEVEL))
      FROM dual
      CONNECT BY LEVEL <= REGEXP_COUNT(b_so_id_tt_s, ',') + 1);
    if b_i1 <> 0 then
        select min(so_id_vat) into b_so_id_vat from bh_hd_goc_vat_ct where ma_dvi = b_ma_dvi and  so_id_tt in (SELECT TO_NUMBER(REGEXP_SUBSTR(b_so_id_tt_s, '[^,]+', 1, LEVEL))
      FROM dual
      CONNECT BY LEVEL <= REGEXP_COUNT(b_so_id_tt_s, ',') + 1);
      select count(*) into b_i1 from bh_hd_goc_vat_txt where ma_dvi = b_ma_dvi and  so_id_vat = b_so_id_vat and loai = 'dt_dk';
      if b_i1 <> 0 then
         select FKH_JS_BONH(txt) into cs_ton from bh_hd_goc_vat_txt where ma_dvi = b_ma_dvi and  so_id_vat = b_so_id_vat and loai = 'dt_dk';
      else
        select JSON_ARRAYAGG(json_object('so_id' value ct.so_id,'so_hd' value substr(to_char(ct.so_id),3),'so_id_tt' value ct.so_id_tt,
          'ngay_tt' value ct.ngay_tt,'ttoan' value ct.ttoan,'phi_qd' value ct.phi_qd,'ttoan_qd' value ct.ttoan_qd,'thue' value ct.thue,
          'thue_qd' value ct.thue_qd) returning clob) into cs_ton from bh_hd_goc_vat_ct ct
          where  ct.ma_dvi = b_ma_dvi and ct.so_id_tt in (SELECT TO_NUMBER(REGEXP_SUBSTR(b_so_id_tt_s, '[^,]+', 1, LEVEL))
                FROM dual
                CONNECT BY LEVEL <= REGEXP_COUNT(b_so_id_tt_s, ',') + 1);
      end if;
    else
      select JSON_ARRAYAGG(json_object('so_id' value so_id,'so_hd' value substr(to_char(so_id),3),'so_id_tt' value so_id_tt,
      'ngay_tt' value ngay,'ttoan' value ttoan,'phi_qd' value phi_qd,'ttoan_qd' value ttoan_qd,'thue' value thue,
      'thue_qd' value thue_qd)
      returning clob) into cs_ton from
          (select so_id_tt,ngay,so_id,ma_nt,sum(ttoan)*b_ty_gia ttoan,sum(thue)*b_ty_gia thue,sum(phi)*b_ty_gia phi,sum(ttoan)*b_ty_gia ttoan_qd,sum(thue)*b_ty_gia thue_qd,sum(phi)*b_ty_gia phi_qd
              from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt IN (SELECT TO_NUMBER(REGEXP_SUBSTR(b_so_id_tt_s, '[^,]+', 1, LEVEL))
                  FROM dual
                  CONNECT BY LEVEL <= REGEXP_COUNT(b_so_id_tt_s, ',') + 1) and
                    pt in('C','G')  group by so_id_tt,ngay,so_id,ma_nt);

    end if;
end if;

select json_object('ma_kh' value b_ma_kh,'cs_ton' value cs_ton returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_HD_VAT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
as
    b_loi varchar2(100); b_so_id_vat number; b_htoan varchar2(1);
begin
-- Dan - Nhap thanh toan phi
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','VAT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_vat:=FKH_JS_GTRIn(b_oraIn,'so_id_vat');
PBH_HD_VAT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_vat,b_loi);
if b_loi is not null then raise program_error; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise program_error; else raise_application_error(-20105,b_loi); end if;
end;
/
