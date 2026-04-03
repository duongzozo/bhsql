/*** THANH TOAN PHI ***/
create or replace procedure PBH_HD_TT_TON_TTOAN(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ma_nt varchar2,
    b_ttoan out number,b_thue out number,b_loi out varchar2,b_ngay_ht number:=30000101)
AS
    b_i1 number; b_i2 number;
begin
-- Dan - Ton chua thanh toan
select nvl(sum(thue),0),nvl(sum(ttoan),0) into b_thue,b_ttoan
    from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
select nvl(sum(thue),0),nvl(sum(ttoan),0) into b_i1,b_i2
    from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and ma_nt=b_ma_nt and pt not in('C','H') and ngay_ht<=b_ngay_ht;
b_thue:=b_thue-b_i1; b_ttoan:=b_ttoan-b_i2; b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_TON_TTOAN:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_TON_NO(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ma_nt varchar2,
    b_ttoan out number,b_thue out number,b_loi out varchar2,b_ngay_ht number:=30000101)
AS
    b_i1 number; b_i2 number;
begin
-- Dan - Ton cho no phi
select nvl(sum(thue),0),nvl(sum(ttoan),0) into b_thue,b_ttoan
    from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and ma_nt=b_ma_nt and pt='C' and ngay_ht<=b_ngay_ht;
select nvl(sum(thue),0),nvl(sum(ttoan),0) into b_i1,b_i2
    from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ngay and ma_nt=b_ma_nt and pt='N' and ngay_ht<=b_ngay_ht;
b_thue:=b_thue-b_i1; b_ttoan:=b_ttoan-b_i2; b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_TON_NO:loi'; end if;
end;
/
create or replace function FBH_HD_TT_TXT(b_ma_dvi varchar2,b_so_id_tt number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_hd_goc_ttxt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_goc_ttxt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_TT_NV(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_tt number,b_dbo out varchar2)
AS
    b_loi varchar2(100); b_nv varchar2(10);
begin
-- Dan - Xac dinh nghiep vu thanh toan
b_dbo:='';
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_nv:=FBH_HD_NV(b_ma_dvi,r_lp.so_id);
    if b_dbo is null then b_dbo:=b_nv;
    elsif instr(b_dbo,b_nv)=0 then b_dbo:=b_dbo||','||b_nv;
    end if;
end loop;
end;
/
create or replace procedure PBH_HD_TT_MA_DL(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_tt number,b_dbo out varchar2)
AS
    b_loi varchar2(100); b_nv varchar2(10);
begin
-- Dan - Xac dinh nghiep vu thanh toan
b_dbo:='';
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_nv:=FBH_HD_NV(b_ma_dvi,r_lp.so_id);
    if b_dbo is null then b_dbo:=b_nv;
    elsif instr(b_dbo,b_nv)=0 then b_dbo:=b_dbo||','||b_nv;
    end if;
end loop;
end;
/
/*Liet ke hop dong no phi*/
create or replace procedure PBH_HD_TT_NOPHI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,b_ngayd number,b_ngayc number,
        b_tu_n number,b_den_n number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number; b_i2 number; b_tu number:=b_tu_n; b_den number:=b_den_n;
    b_dviKH varchar2(20):=FKH_NV_DVI(b_ma_dvi,'bh_hd_ma_kh'); b_so_idD number:=0;
begin
-- Dan - Liet ke cac hop dong no phi
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_so_hd) is not null then
    b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
end if;
insert into temp_1(n1,c1)
    select so_id,so_hd from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and b_so_idD in(0,so_id) union all
    select so_id,so_hd from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and b_so_idD in(0,so_id);
insert into temp_3(c5,n1,n2,c7,n3) select ma_dvi,so_id,ngay,'G',sum(ttoan) from bh_hd_goc_cl
    where ma_dvi=b_ma_dvi and so_id in (select n1 from temp_1) and
    ngay_ht between b_ngayd and b_ngayc group by ma_dvi,so_id,ngay;
insert into temp_3(c5,n1,n2,c7,n3) select  ma_dvi,so_id,ngay,'G',-sum(ttoan) from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and pt not in('C','N','H') and so_id in (select n1 from temp_1) and ngay_ht between b_ngayd and b_ngayc group by ma_dvi,so_id,ngay;
insert into temp_3(c5,n1,n2,c7,n3) select ma_dvi,so_id,ngay,'G',sum(ttoan) from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and pt='C' and so_id in (select n1 from temp_1) and ngay_ht between b_ngayd and b_ngayc group by ma_dvi,so_id,ngay;
insert into temp_3(c5,n1,n2,c7,n3) select ma_dvi,so_id,ngay,'G',-sum(ttoan) from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and pt='N' and so_id in (select n1 from temp_1) and ngay_ht between b_ngayd and b_ngayc group by ma_dvi,so_id,ngay;
insert into temp_2(c5,c7,n1,n2,n3) select c5,c7,n1,n2,sum(n3) from temp_3 group by c5,c7,n1,n2 having sum(n3)<>0;
update temp_2 set c1=(select distinct c1 from temp_1 where n1=temp_2.n1);
update temp_2 set (c2,c6)=(select ma_kh,nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=temp_2.n1);
update temp_2 set (c3,c4)=(select ten,mobi from bh_hd_ma_kh where ma=temp_2.c2);
select count(*) into b_dong from temp_2;
if b_den_n=1000000 then
    b_den:=b_dong; b_tu:=b_dong-b_tu_n;
end if;
open cs1 for select * from (select c5 ma_dvi,n1 so_id,c1 so_hd,c3 ten,c4 phone, pkh_so_cng(n2) ngay_nph,n3 phi,c6 nv,
    row_number() over (order by n1,c1,c5) sott from temp_2 order by n1,c1,c5) where sott between b_tu and b_den;        
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_TYLE
    (b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,a_ngay out pht_type.a_num,a_tl out pht_type.a_num)
AS
    b_loi varchar2(100); b_kt number:=0; b_tien number:=0;
begin
-- Dan - Ty le thanh toan theo ky
PKH_MANG_KD_N(a_ngay); PKH_MANG_KD_N(a_tl);
select ngay,tien BULK COLLECT into a_ngay,a_tl from
    (select ngay,sum(tien) tien from bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt
    group by ngay having sum(tien)<>0 order by ngay);
if a_ngay.count<2 then
    PKH_MANG_XOA_N(a_ngay); PKH_MANG_XOA_N(a_tl);
else
    for b_lp in 1..a_ngay.count loop
        a_tl(b_lp):=a_tl(b_lp)/b_tien;
    end loop;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR;end if;
end;
/
create or replace function FBH_HD_PS_TT(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_PS_TTs(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - So da phat sinh xu ly
if FBH_HD_PS_TT(b_ma_dvi,b_so_id)<>0 then b_kq:='C';  end if;
return b_kq;
end;
/
create or replace function FBH_HD_TT_NGAY(b_ma_dvi varchar2,b_so_id_tt number) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay thanh toan
select nvl(min(ngay_ht),0) into b_kq from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
return b_kq;
end;
/
create or replace function FBH_HD_TT_CUOI(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay thanh toan cuoi
select nvl(max(ngay_ht),0) into b_kq from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_TT_KIEU(b_ma_dvi varchar2,b_so_id_tt number) return varchar2
AS
 b_kq varchar2(1);
begin
-- Dan - Tra kieu thanh toan
select nvl(min(pt),'C') into b_kq from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
return b_kq;
end;
/
create or replace function FBH_HD_TT_TON_ID(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra ton no phi theo so hop dong
select count(*) into b_i1 from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then
    select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_HD_TT_TON_HD(b_ma_dvi varchar2,b_so_hd varchar2) return varchar2
AS
	b_kq varchar2(1):='K'; b_so_idD number;
begin
-- Dan - Tra ton no phi theo so hop dong
if trim(b_so_hd) is not null then
    b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
end if;
if b_so_idD<>0 then
	b_kq:=FBH_HD_TT_TON_ID(b_ma_dvi,b_so_idD);
end if;
return b_kq;
end;
/
create or replace function FBH_HD_TT_HTHANH(
    b_ma_dvi varchar2,b_so_id varchar2,b_nguon varchar2:='B',b_ngay number:=30000101) return number
AS
    b_kq number:=100; b_no number; b_co number; b_noN number; b_coN number;
begin
-- Dan - Tra ty le con so voi tong thuc thu
-- b_nguon: B-Ban hang, T-Thuc thu
select nvl(sum(no),0),nvl(sum(co),0) into b_no,b_co from
    bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
if b_no>0 then
    if b_nguon='T' then
        select nvl(sum(no),0),nvl(sum(co),0) into b_noN,b_coN from
            bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
        b_co:=b_co-(b_noN-b_coN);
    end if;
    if b_co<=0 then b_kq:=0; else b_kq:=round(b_co*100/b_no,2); end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_TT_HTHANH(
    b_ma_dvi varchar2,b_so_id varchar2,b_tlB out number,b_tlT out number,b_ngay number:=30000101)
AS
    b_kq number:=100; b_no number; b_co number; b_noN number; b_coN number;
begin
-- Dan - Tra ty le con so voi tong thuc thu
-- b_dk: B-Ban hang, T-Thuc thu
b_tlB:=100; b_tlT:=100;
select nvl(sum(no),0),nvl(sum(co),0) into b_no,b_co from bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
if b_no>0 then
    if b_co<=0 then
        b_tlB:=0; b_tlT:=0; 
    else
        b_tlB:=round(b_co*100/b_no,2);
        select nvl(sum(no),0),nvl(sum(co),0) into b_noN,b_coN from bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
        b_co:=b_noN-b_coN;
        if b_co<=0 then b_tlT:=0; else b_tlT:=round(b_co*100/b_no,2); end if;
    end if;
end if;
end;
/
create or replace function FBH_HD_TT_TLE(
    b_ma_dvi varchar2,b_so_id varchar2,b_tien number,b_ngay number:=30000101) return number
AS
    b_kq number:=100; b_no number; b_co number; b_noN number; b_coN number;
begin
-- Dan - Tra ty le con so voi tong thuc thu
-- b_dk: B-Ban hang, T-Thuc thu
if b_tien<=0 then b_kq:=0;
else
    select nvl(sum(no),0) into b_no from bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay;
    if b_no>0 then b_kq:=round(b_tien*100/b_no,2); end if;
end if;
return b_kq;
end;
/
create or replace procedure FBH_HD_TT_TON(
    b_ma_dvi varchar2,b_so_id number,a_ngay out pht_type.a_num,
    a_pt out pht_type.a_var,a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num)
AS
begin
-- Dan - Tra no kphi
select ngay,pt,ma_nt,sum(tien) bulk collect into a_ngay,a_pt,a_ma_nt,a_tien from (
    select ngay,'G' pt,ma_nt,sum(ttoan) tien from bh_hd_goc_cl
        where ma_dvi=b_ma_dvi and so_id=b_so_id group by ngay,ma_nt union
    select ngay,'G' pt,ma_nt,-sum(ttoan) tien from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id=b_so_id and pt in('C','G') group by ngay,ma_nt  union
    select ngay,'N' pt,ma_nt,sum(ttoan) tien from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='C' group by ngay,ma_nt union
    select ngay,'N' pt,ma_nt,-sum(ttoan) tien from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='N' group by ngay,ma_nt)
    group by ngay,pt,ma_nt having sum(tien)<>0 order by ngay,pt DESC;
end;
/
create or replace procedure PBH_HD_TT_DON(b_ma_dvi varchar2,b_so_id_tt number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_so_id_vat number; b_ngay_ht number; b_nsd varchar2(10); b_don varchar2(50); b_kvat varchar2(1);
    r_hd bh_hd_goc_vat%rowtype; a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan - Day don
select kvat into b_kvat from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_kvat='N' then b_loi:=''; return; end if;
for r_lp in (select distinct so_id_vat from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_so_id_vat:=r_lp.so_id_vat;
    select count(*) into b_i1 from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat and so_id_tt<>b_so_id_tt;
    if b_i1<>0 then
        b_loi:='loi:Phat hanh chung hoa don vat cho nhieu thanh toan. Phai xoa phat hanh hoa don truoc:loi'; return;
    end if;
    select ngay_ht,nsd,mau,seri,so_don into b_ngay_ht,b_nsd,a_gcn_m(1),a_gcn_c(1),a_gcn_s(1)
        from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
    b_don:=FKH_GHEP_SERI(a_gcn_m(1),a_gcn_c(1),a_gcn_s(1),' ');
    select count(*) into b_i1 from bh_nggcn_ba where ma_dvi=b_ma_dvi and don=b_don;
    if b_i1=0 then
        PHD_PH_DON(b_ma_dvi,b_nv,b_ngay_ht,b_so_id_vat,a_gcn_m,a_gcn_c,a_gcn_s,b_nsd,'',b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_DON:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_XOA_VAT(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    r_hd bh_hd_goc_vat%rowtype; b_i1 number; b_i2 number; b_ngay_ht number;
begin
-- Dan - Xoa VAT
select count(*),max(so_id_vat) into b_i1,b_i2 from 
    (select distinct so_id_vat from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt);
if b_i1=0 then b_loi:=''; return; end if;
if b_i1<>1 or b_i2<>b_so_id_tt then b_loi:='loi:Thanh toán dã phát hành hóa don:loi'; return; end if;
PBH_HD_TT_DON(b_ma_dvi,b_so_id_tt,'X',b_loi);
if b_loi is not null then return; end if;
delete bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_tt;
for r_lp in (select distinct so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    PBH_TH_VAT(b_ma_dvi,r_lp.so_id,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_XOA_VAT:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_KE(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_nhom varchar2(20); b_ngay_ht number; b_ngay number; b_pt number; b_bt number:=0;
    b_nv varchar2(10); b_kenh varchar2(10); b_ma_kh varchar2(20);
    a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
    a_ma pht_type.a_var; a_lh_nv pht_type.a_var; a_tl pht_type.a_num;
    a_so_idK pht_type.a_num; a_nvK pht_type.a_var; a_maK pht_type.a_var;
    a_lh_nvK pht_type.a_var; a_tienK pht_type.a_num;
begin
-- Dan - Xu ly ke
select ngay_ht into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select distinct so_id,so_id_dt bulk collect into a_so_id,a_so_id_dt from
    bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
for b_lp in 1..a_so_id.count loop
    select nvl(min(ma_ke),' ') into b_nhom from bh_hd_goc_ttindt where
        ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and so_id_dt=a_so_id_dt(b_lp);
    if b_nhom=' ' then continue; end if;
    select nv,ma_kh into b_nv,b_ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
    b_ma_kh:=FBH_DTAC_MA_QLYc(b_ma_kh);
    b_kenh:=PKH_MA_TENl(FBH_HD_TXT(b_nv,b_ma_dvi,a_so_id(b_lp),'ma_kenh'));
    select nvl(max(ngay),0) into b_ngay from bh_ke_che where
        dviK='D' and dvi=b_ma_dvi and nv=b_nv and ngay<=b_ngay_ht and
        nhom=b_nhom and kenh in(' ',b_kenh) and khang in(' ',b_ma_kh);
    if b_ngay=0 then continue; end if;
    select ma,lh_nv,goc bulk collect into a_ma,a_lh_nv,a_tl from bh_ke_che where
        dviK='D' and dvi=b_ma_dvi and nv=b_nv and ngay=b_ngay and
        nhom=b_nhom and kenh in(' ',b_kenh) and khang in(' ',khang);
    for r_lp in (select lh_nv,phi_qd tien from bh_hd_goc_ttptdt where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=a_so_id(b_lp) and
        so_id_dt=a_so_id_dt(b_lp) order by lh_nv) loop
        PBH_HD_CON_DT(b_ma_dvi,a_so_id(b_lp),a_so_id_dt(b_lp),r_lp.lh_nv,b_pt,b_loi);
        if b_loi is not null then return; end if;
        for b_lp1 in 1..a_ma.count loop
            if a_lh_nv(b_lp1)<>r_lp.lh_nv then continue; end if;
            b_bt:=b_bt+1;
            a_so_idK(b_bt):=a_so_id(b_lp); a_nvK(b_bt):=b_nv; a_maK(b_bt):=a_ma(b_lp1);
            a_lh_nvK(b_bt):=r_lp.lh_nv; a_tienK(b_bt):=round(r_lp.tien*b_pt*a_tl(b_lp1)/10000,0);
        end loop;
    end loop;
end loop;
forall b_lp in 1..b_bt
    insert into bh_hd_goc_ttke values
    (b_ma_dvi,b_so_id_tt,a_so_idK(b_lp),a_nvK(b_lp),b_ngay_ht,a_maK(b_lp),a_lh_nvK(b_lp),a_tienK(b_lp));
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_KE:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_XOA_VAT_DO(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; r_hd bh_hd_do_vat%rowtype;
begin
-- Dan - Xoa VAT dong BH
select count(*) into b_i1 from bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_tt;
if b_i1=0 then b_loi:=''; return; end if;
delete bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_tt;
delete bh_hd_do_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_tt;
PBH_HD_DO_TH_VAT(b_ma_dvi,b_so_id_tt,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_XOA_VAT_DO:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_NH_VAT_DO(
	b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,b_ngay_ht number,b_phong varchar2,b_nha_bh varchar2,
    b_ma_nt varchar2,b_so_don varchar2,b_ngay_bc number,b_loi out varchar2)
AS
    b_i1 number; b_ma_thue varchar2(30); b_ten nvarchar2(500); b_dchi nvarchar2(500); b_don varchar2(50);
begin
-- Dan - Nhap hoa don VAT dong BH
select nvl(sum(ttoan_qd),-1) into b_i1 from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt='G';
if b_i1<0 then b_loi:=''; return; end if;
select ten,dchi,cmt into b_ten,b_dchi,b_ma_thue from bh_ma_nbh where ma=b_nha_bh;
b_loi:='loi:Trung so hoa don VAT:loi';
insert into bh_hd_do_vat values(b_ma_dvi,b_so_id_tt,b_ngay_ht,'R',b_nha_bh,
    b_ten,b_dchi,b_ma_thue,b_so_don,b_ngay_bc,b_phong,b_nsd,sysdate);
delete temp_1;
insert into temp_1(c1,n1,n2,n3,n4) select ma_nt,sum(phi),sum(phi_qd),sum(thue),sum(thue_qd) from bh_hd_goc_ttpt
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt not in('C','N','H') group by ma_nt;
insert into bh_hd_do_vat_ct select b_ma_dvi,b_so_id_tt,rownum,b_so_id_tt,c1,n1,n2,n3,n4 from temp_1;
PBH_HD_DO_TH_VAT(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_NH_VAT_DO:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_TONk(
    b_ma_dvi varchar2,a_so_id pht_type.a_num,a_ngayV pht_type.a_num,
    a_ptV pht_type.a_var,a_tienV pht_type.a_num,b_loi out varchar2)
AS
    b_c varchar2(1); b_i1 number; b_so_id number; b_kt number;
    a_ngay pht_type.a_num; a_pt pht_type.a_var; a_tien pht_type.a_num;
    a_ngayN pht_type.a_num; a_ptN pht_type.a_var; a_tienN pht_type.a_num;
    a_so_idU pht_type.a_num;
begin
-- Dan - Kiem tra thanh toan hop le
PKH_MANG_DUYn(a_so_id,a_so_idU);
for lp_so_id in 1..a_so_idU.count loop
    b_so_id:=a_so_idU(lp_so_id); b_kt:=0; b_c:='K';
    for b_lp in 1..a_so_id.count loop
        if a_so_id(b_lp)=b_so_id then
            b_kt:=b_kt+1;
            a_ngayN(b_kt):=a_ngayV(b_lp); a_ptN(b_kt):=a_ptV(b_lp); a_tienN(b_kt):=a_tienV(b_lp);
        end if;
    end loop;
    select ngay,pt,sum(ttoan) bulk collect into a_ngay,a_pt,a_tien from (
        select ngay,'G' pt,ttoan from bh_hd_goc_cl
            where ma_dvi=b_ma_dvi and so_id=b_so_id union
        select ngay,'G' pt,-ttoan from bh_hd_goc_ttpt
            where ma_dvi=b_ma_dvi and pt not in('N','H') and so_id=b_so_id union
        select ngay,'N' pt,ttoan from bh_hd_goc_ttpt
            where ma_dvi=b_ma_dvi and pt='C' and so_id=b_so_id union
        select ngay,'N' pt,-ttoan from bh_hd_goc_ttpt
            where ma_dvi=b_ma_dvi and pt='N' and so_id=b_so_id order by ngay,pt)
        group by ngay,pt having sum(ttoan)<>0;
    for b_lp in 1..a_pt.count loop
        if a_pt(b_lp)<>'G' then b_c:='C'; end if;
    end loop;
    for b_lp in 1..b_kt loop
        for b_lp1 in 1..a_pt.count loop
            if a_ngayN(b_lp)=a_ngay(b_lp1) then a_pt(b_lp1):='X'; exit; end if;
        end loop;
        if a_ptN(b_lp)<>'C' then continue; end if;
        if b_c='C' then b_loi:='loi:Khong cho no tiep neu con no:loi'; return; end if;
        for b_lp1 in 1..b_kt loop
            if a_ngayN(b_lp1)<>a_ngayN(b_lp) then b_loi:='loi:Khong cho no nhieu ky:loi'; return; end if;
        end loop;
    end loop;
    for b_lp in 1..a_pt.count loop
        if a_pt(b_lp)='X' then continue; end if;
        b_i1:=b_lp-1;
        for b_lp1 in 1..b_i1 loop
            if a_pt(b_lp1)='X' and a_ngay(b_lp1)>a_ngay(b_lp) then
                b_loi:='loi:Thanh toan lan luot theo ky:loi'; return;
            end if;
        end loop;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_TONk:loi'; end if;
end;
/
create or replace procedure PBH_HD_TT_TTRANG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
  b_loi varchar2(100); b_i1 number;
  b_so_id_tt number:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
  b_thue varchar2(1); b_hhong varchar2(1); cs_ttr clob:='';
  b_ttrang varchar2(1); b_so_id_vat number;
  b_so_id number;b_ngay number;b_pt_tra varchar2(1);
begin
-- Dan - Tra tinh trang CT thanh toan
delete bh_hd_ttrang_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_thue:='X'; b_hhong:='X';
--duong sua logic hien thi mau hoa don
select count(*) into b_i1 from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1 <> 0 then
  select min(so_id_vat) into b_so_id_vat  from bh_hd_goc_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
  select ttrang into b_ttrang from bh_hd_goc_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
  if b_ttrang = 'V' then b_thue:='V';
  elsif b_ttrang = 'X' then b_thue:='X';
  elsif b_ttrang = 'D' then b_thue:='D';
  end if;
else b_thue:='D';
end if;
--kiem tra thanh toan có phai la thanh toan sau khi cho no phi hay khong
select min(so_id) into b_so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_so_id <> 0 then
  select count(*) into b_i1 from bh_hd_goc_ttps ps
  left join bh_hd_goc_tthd hd on hd.so_id_tt = ps.so_id_tt
  where hd.so_id = b_so_id and hd.ma_dvi = b_ma_dvi;
  if b_i1 > 1 then
    select min(ps.pt_tra) into b_pt_tra from bh_hd_goc_ttps ps
    left join bh_hd_goc_tthd hd on hd.so_id_tt = ps.so_id_tt
    where hd.so_id = b_so_id and hd.ma_dvi = b_ma_dvi;
    if b_pt_tra = 'N' then
      select pt_tra into b_pt_tra from bh_hd_goc_ttps where ma_dvi = b_ma_dvi and so_id_tt = b_so_id_tt;
      if b_pt_tra <> 'N' then b_thue:='X'; end if;
    end if;
  end if;
end if;
---end check thue
select count(*) into b_i1 from bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1<>0 then b_hhong:='D'; end if;
insert into bh_hd_ttrang_temp values('tt_thue',b_thue);
insert into bh_hd_ttrang_temp values('tt_hhong',b_hhong);
select JSON_ARRAYAGG(json_object(nv,tt)) into cs_ttr from bh_hd_ttrang_temp;
select json_object('cs_ttr' value cs_ttr) into b_oraOut from dual;
delete bh_hd_ttrang_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_SO_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_kh varchar2(20);
    b_so_hd varchar2(20):=trim(b_oraIn); b_so_idD number; b_so_id number;
begin
-- Dan - Tra tinh trang CT thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(so_id_d),min(so_id),nvl(min(ma_kh),' ') into b_so_idD,b_so_id,b_ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
if b_ma_kh=' ' then b_loi:='loi:Hop dong/GCN da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_so_id<>b_so_idD then
    select min(so_hd) into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idD;
end if;
if b_ma_kh<>'VANGLAI' then
    select json_object('ma_kh' value b_ma_kh,ten,dchi,mobi,email,'ma_thue' value cmt,'so_hd' value b_so_hd) into b_oraOut from bh_dtac_ma where ma=b_ma_kh;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_NBH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_ma_kh varchar2(20);
begin
-- Dan - Tra ton NBH
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_kh,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_so_hd using b_oraIn;
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ma_kh=' ' and b_so_hd=' ' then b_loi:='loi:Nhap so hop dong, khach hang:loi'; raise PROGRAM_ERROR; end if;
b_oraOut:='';
if b_so_hd<>' ' then
    insert into temp_1(n1)
        select so_id from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_hd=b_so_hd union all
        select so_id from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else
    insert into temp_1(n1)
        select so_id from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh union all
        select so_id from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh;
end if;
delete temp_1 where FBH_HD_NBHb(b_ma_dvi,n1)<>'C';
insert into temp_2(c1) 
    select distinct nha_bh from temp_1 a,tbh_tmN_tl b where
        b.ma_dvi=b_ma_dvi and b.so_id=a.n1 and FBH_TH_PHI_NBH_KTRA(b_ma_dvi,a.n1,nha_bh)='C' union all
    select distinct nha_bh from temp_1 a,bh_hd_do_tl b where
        b.ma_dvi=b_ma_dvi and b.so_id=a.n1 and b.pthuc='C' and FBH_TH_PHI_NBH_KTRA(b_ma_dvi,a.n1,nha_bh)='C';
select JSON_ARRAYAGG(json_object('ma' value c1,'ten' value FBH_DTAC_MA_TEN(c1))) into b_oraOut
    from (select distinct c1 from temp_2);
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_NBHt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_ma_kh varchar2(20);
begin
-- Dan - Tra ton NBH
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_kh,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_so_hd using b_oraIn;
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_ma_kh=' ' and b_so_hd=' ' then return; end if;
if b_so_hd<>' ' then
    insert into temp_1(n1)
        select so_id from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_hd=b_so_hd union
        select so_id from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else
    insert into temp_1(n1)
        select so_id from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh union
        select so_id from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh;
end if;
delete temp_1 where FBH_HD_NBHb(b_ma_dvi,n1)<>'C';
insert into temp_2(c1)
    select distinct b.nha_bh from temp_1 a,bh_hd_do_tl b where
        b.ma_dvi=b_ma_dvi and b.so_id=a.n1 and b.pthuc='C' and FBH_TH_PHI_NBH_KTRA(b_ma_dvi,a.n1,nha_bh)='C' union
    select distinct nha_bh from temp_1 a,tbh_tmN_tl b where
        b.ma_dvi=b_ma_dvi and b.so_id=a.n1 and FBH_TH_PHI_NBH_KTRA(b_ma_dvi,a.n1,nha_bh)='C';
if sql%rowcount=0 then
    b_oraOut:='';
elsif sql%rowcount=1 then
    select min(FBH_DTAC_MA_TENl(c1)) into b_oraOut from temp_2;
else
    b_oraOut:='--';
end if;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_i2 number; b_lenh varchar2(2000);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_nha_bh varchar2(20); b_pt_tra varchar2(1);
    b_so_idD number; b_ton number; b_tien number; b_tp number; b_nt_phi varchar2(5);
    b_txt clob:=b_oraIn;
begin
-- Dan - Hoi ten, liet ke no khi nhap thanh toan phi
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('ma_kh,so_hd,nha_bh,pt_tra');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_so_hd,b_nha_bh,b_pt_tra using b_txt;
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_so_hd=' ' and b_ma_kh=' ' then
    b_loi:='loi:Nhap so hop dong/GCN, ma khach hang:loi'; raise PROGRAM_ERROR;
end if;
b_pt_tra:=nvl(trim(b_pt_tra),'T');
if b_so_hd<>' ' then
    select nvl(min(so_id_d),0),min(nt_phi) into b_so_idD,b_nt_phi from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
    if b_so_idD=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
    b_nt_phi:=FBH_HD_MA_NT(b_ma_dvi,b_so_idD);
    if b_nha_bh<>' ' then
        b_i1:=FBH_TH_PHI_NBH_TON(b_ma_dvi,b_so_idD,b_nha_bh,b_nt_phi);
    else
        if FBH_HD_NBHb(b_ma_dvi,b_so_idD)='C' then
            b_loi:='loi:Nhap nha bao hiem:loi'; raise PROGRAM_ERROR;
        end if;
        select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        if b_i1=0 and b_pt_tra<>'N' then
            select count(*) into b_i1 from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        end if;
    end if;
    if b_i1<>0 then insert into temp_1(n1,c1) values(b_so_idD,b_so_hd); end if;
else
    if b_pt_tra='N' then
        insert into temp_1(n1,c1)
            select so_id,so_hd from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh;
    else
        insert into temp_1(n1,c1)
            select so_id,so_hd from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh union all
            select so_id,so_hd from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh;
    end if;
    if b_nha_bh<>' ' then
        delete temp_1 where FBH_TH_PHI_NBH_KTRA(b_ma_dvi,n1,b_nha_bh)<>'C';
    else
        select count(*) into b_i1 from temp_1 where FBH_HD_NBHb(b_ma_dvi,n1)='C';
        if b_i1<>0 then b_loi:='loi:Nhap nha bao hiem:loi'; raise PROGRAM_ERROR; end if;
    end if;
end if;
select count(*) into b_i1 from temp_1;
if b_i1<>0 then
    insert into temp_3(n1,n2,c2,c3,n3) select so_id,ngay,'G',ma_nt,sum(ttoan) from bh_hd_goc_cl
        where ma_dvi=b_ma_dvi and so_id in (select n1 from temp_1) group by so_id,ngay,ma_nt;
    insert into temp_3(n1,n2,c2,c3,n3) select so_id,ngay,'G',ma_nt,-sum(ttoan) from bh_hd_goc_ttpt
        where ma_dvi=b_ma_dvi and pt in('C','G') and so_id in (select n1 from temp_1) group by so_id,ngay,ma_nt;
    if b_pt_tra<>'N' then
        insert into temp_3(n1,n2,c2,c3,n3) select so_id,ngay,'N',ma_nt,sum(ttoan) from bh_hd_goc_ttpt
            where ma_dvi=b_ma_dvi and pt='C' and so_id in (select n1 from temp_1) group by so_id,ngay,ma_nt;
        insert into temp_3(n1,n2,c2,c3,n3) select so_id,ngay,'N',ma_nt,-sum(ttoan) from bh_hd_goc_ttpt
            where ma_dvi=b_ma_dvi and pt='N' and so_id in (select n1 from temp_1) group by so_id,ngay,ma_nt;
    end if;
    insert into temp_2(n1,n2,c2,c3,n3) select n1,n2,c2,c3,sum(n3) from temp_3 group by n1,n2,c2,c3 having sum(n3)<>0;
    if sql%rowcount<>0 then
        if b_nha_bh<>' ' then
            for r_lp in(select distinct n1 so_id,c3 ma_nt from temp_2) loop
                select count(*) into b_i1 from bh_hd_goc_phi_nbh where
                    ma_dvi=b_ma_dvi and so_id=r_lp.so_id and nbh<>b_nha_bh and ma_nt=r_lp.ma_nt and
                    FBH_TH_PHI_NBH_TON(ma_dvi,so_id,nbh,ma_nt)<>0;
                if b_i1<>0 then
                    select sum(n3) into b_tien from temp_2 where n1=r_lp.so_id and c3=r_lp.ma_nt;
                    if b_tien<>0 then
                        if r_lp.ma_nt<>'VND' then b_tp:=2; else b_tp:=0; end if;
                        b_ton:=FBH_TH_PHI_NBH_TON(b_ma_dvi,r_lp.so_id,b_nha_bh,r_lp.ma_nt);
                        b_i1:=b_ton/b_tien;
                        update temp_2 set n3=round(n3*b_i1,b_tp) where n1=r_lp.so_id and c3=r_lp.ma_nt;
                        select sum(n3),max(n2) into b_i1,b_i2 from temp_2 where n1=r_lp.so_id and c3=r_lp.ma_nt;
                        if b_i1<>b_ton then
                            b_i1:=b_ton-b_i1;
                            update temp_2 set n3=n3+b_i1 where n1=r_lp.so_id and c3=r_lp.ma_nt and n2=b_i2;
                        end if;
                    end if;
                end if;
            end loop;
        end if;
        update temp_2 set c1=(select min(c1) from temp_1 where n1=temp_2.n1);
        select JSON_ARRAYAGG(json_object('so_id' value n1,'so_hd' value c1,'pt' value c2,'ngay' value n2,'ma_nt' value c3,
            'phi' value n3,'tien' value n3) order by c1,c2 DESC,n2,c3 DESC returning clob) into b_oraOut from temp_2;
    end if;
end if;
delete temp_1; delete temp_2; delete temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
    b_so_id_tt number; b_nbh varchar2(20);
    dt_ct clob; dt_dk clob; dt_tt clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt'); b_nbh:=FBH_HD_TT_NBH(b_ma_dvi,b_so_id_tt);
b_loi:='loi:Thanh toan da xoa:loi';
select json_object(ma_kh,'nha_bh' value FBH_DTAC_MA_TENl(b_nbh)) into dt_ct
    from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object('so_hd' value FBH_HD_GOC_SO_HD_D(b_ma_dvi,so_id),
    'ngay' value ngay,'pt' value pt,'ma_nt' value ma_nt,'phi' value phi,
    'tien' value tien,'chon' value '','so_id' value so_id) order by so_id desc returning clob) into dt_dk
    from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(pt,ma_nt,tien) order by ma_nt) into dt_tt from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from bh_hd_goc_ttxt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select json_object('so_id_tt' value b_so_id_tt,'dt_dk' value dt_dk,'dt_tt' value dt_tt,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_so_hd varchar2(20); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
            (select so_id_tt,ten,rownum sott from bh_hd_goc_ttps where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
            (select so_id_tt,ten,rownum sott from bh_hd_goc_ttps where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) 
            where sott between b_tu and b_den;
    end if;
elsif trim(b_so_hd) is not null then
    b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
    select count(*) into b_dong from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt in
        (select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id);
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ngay_ht) returning clob) into cs_lke from
            (select so_id_tt,ngay_ht,rownum sott from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and
                so_id_tt in(select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id)
                order by ngay_ht desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_hd_goc_ttps where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
        (select so_id_tt,ten,rownum sott from bh_hd_goc_ttps where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tt desc)
        where sott between b_tu and b_den;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_hd_goc_ttps where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
        (select so_id_tt,ten,rownum sott from bh_hd_goc_ttps where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id_tt desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TT_TEST(
    b_ma_dvi varchar2,dt_ct clob,dt_dk clob,
    b_ngay_ht out number,b_htoan out varchar2,b_kvat out varchar2,b_ma_kh out varchar2,b_so_ct out varchar2,
    b_pt_tra out varchar2,b_nha_bh out varchar2,b_ma_dl out varchar2,
    b_vochD out varchar2,b_vochK out varchar2,b_phong varchar2,b_ttoan_qd out number,b_thue_qd out number,
    b_kieuHD out varchar2,b_layHD out varchar2,b_so_don out varchar2,b_ngay_bc out varchar2,b_ng_hd out varchar2,
    b_ten out nvarchar2,b_dchi out varchar2,b_email out varchar2,b_ma_thue out varchar2,b_nd out nvarchar2,
    b_nt_tra out varchar2,b_tra out number,b_tra_qd out number,
    a_so_id out pht_type.a_num,a_ngay out pht_type.a_num,a_pt_tt out pht_type.a_var,
    a_ma_nt_tt out pht_type.a_var,a_phi_tt out pht_type.a_num,a_tien_tt out pht_type.a_num,
    a_tien_tt_qd out pht_type.a_num,a_thue_tt out pht_type.a_num,a_thue_tt_qd out pht_type.a_num,
    a_pt out pht_type.a_var,a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num,a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; b_lenh varchar2(2000); b_so_id number; b_so_id_bs number;
    b_kieu_hd varchar2(1); b_ngoai boolean:=false; b_ma_khX varchar2(20);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(50); b_tp number:=0; b_kieu_do varchar2(1);
    a_so_hd pht_type.a_var; a_so_idU pht_type.a_num;
begin
-- Dan - Kiem tra so lieu nhap thanh toan phi
b_lenh:=FKH_JS_LENH('ngay_ht,htoan,ma_kh,ten,dchi,ma_thue,email,so_ct,pt_tra,
    kvat,kieuhd,layhd,so_don,ngay_bc,ng_hd,vochd,nd,nt_tra,tra,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_htoan,b_ma_kh,b_ten,b_dchi,b_ma_thue,b_email, -- viet anh
    b_so_ct,b_pt_tra,b_kvat,b_kieuHD,b_layHD,b_so_don,b_ngay_bc,b_ng_hd,
    b_vochD,b_nd,b_nt_tra,b_tra,b_nha_bh using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,ngay,pt,ma_nt,phi,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_ngay,a_pt_tt,a_ma_nt_tt,a_phi_tt,a_tien_tt using dt_dk;
if b_ma_kh=' ' then b_ma_kh:='VANGLAI'; end if;
if b_ngay_ht=0 then b_loi:='loi:Nhap ngay thanh toan:loi'; return; end if;
if b_htoan<>'H' then b_loi:='loi:Nhap sai trang thai:loi'; return; end if;
if a_so_id.count=0 then b_loi:='loi:Nhap hop dong thanh toan:loi'; return; end if;
if b_kvat is null or b_kvat not in('N','P','S') then b_loi:='loi:Sai kieu phat hanh hoa don VAT:loi'; return; end if;
if b_kieuhd is null or b_kieuhd not in('E','P') then b_loi:='loi:Sai loai hoa don VAT:loi'; return; end if;
if b_pt_tra is null or b_pt_tra not in('T','N','C','D','B','V','H') then
    b_loi:='loi:Sai phuong thuc tra '||b_pt_tra||':loi'; return;
end if;
b_nt_tra:=nvl(trim(b_nt_tra),'VND');
if b_nt_tra='VND' then
    b_tra_qd:=b_tra;
else
    if FBH_TT_KTRA(b_nt_tra)<>'C' then b_loi:='loi:Sai loai tien tra:loi'; return; end if;
    b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra);
end if;
a_pt(1):=b_pt_tra; a_ma_nt(1):=b_nt_tra; a_tien(1):=b_tra;
for b_lp in 1.. a_so_id.count loop
    if a_so_id(b_lp) is null or a_pt_tt(b_lp) is null or a_pt_tt(b_lp) not in('G','N','C') or
        a_ma_nt_tt(b_lp) is null or a_tien_tt(b_lp) is null or a_tien_tt(b_lp)=0 then return;
    end if;
    a_so_hd(b_lp):=FBH_HD_GOC_SO_HD_D(b_ma_dvi,a_so_id(b_lp));
    if trim(a_so_hd(b_lp)) is null then
        b_loi:='loi:Khong tim duoc so hop dong/GCN:loi'; return;
    end if;
    if FBH_HD_TTRANG(b_ma_dvi,a_so_id(b_lp))<>'D' then
        b_loi:='loi:Hop dong/GCN '||a_so_hd(b_lp)||' chua duyet hoac da cham dut:loi'; return;
    end if;
end loop;
b_ma_dl:=' ';
if b_pt_tra='B' then
    b_nha_bh:=FBH_DONG_NBH(b_ma_dvi,a_so_id(1));
    if b_nha_bh=' ' then b_loi:='loi:Khong tim duoc nha dong bao hiem:loi'; end if;
    for b_lp in 2..a_so_id.count loop
        if FBH_DONG_NBH(b_ma_dvi,a_so_id(b_lp))<>b_nha_bh then
            b_loi:='loi:Phai thanh toan cung nha dong bao hiem:loi'; return;
        end if;
    end loop;
    for b_lp in 1.. a_so_id.count loop
        if FBH_TH_PHI_NBH_TON(b_ma_dvi,a_so_id(b_lp),b_nha_bh,a_ma_nt_tt(b_lp),b_ngay_ht)<a_tien_tt(b_lp) then
            b_loi:='loi:Thanh toan qua so ton hop dong: '||a_so_hd(b_lp)||':loi'; return;
        end if;
    end loop;
elsif b_pt_tra='V' then
    b_nha_bh:=FTBH_TMN_NBH(b_ma_dvi,a_so_id(1));
    if b_nha_bh=' ' then b_loi:='loi:Khong tim duoc nha tai:loi'; end if;
    for b_lp in 2..a_so_id.count loop
        if FTBH_TMN_NBH(b_ma_dvi,a_so_id(b_lp))<>b_nha_bh then
            b_loi:='loi:Phai thanh toan cung nha tai:loi'; return;
        end if;
    end loop;
    for b_lp in 1.. a_so_id.count loop
        if FBH_TH_PHI_NBH_TON(b_ma_dvi,a_so_id(b_lp),b_nha_bh,a_ma_nt_tt(b_lp),b_ngay_ht)<a_tien_tt(b_lp) then
            b_loi:='loi:Thanh toan qua so ton hop dong: '||a_so_hd(b_lp)||':loi'; return;
        end if;
    end loop;
elsif b_pt_tra='D' then
    select min(ma_kt) into b_ma_dl from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=a_so_id(1) and kieu_kt<>'T';
    if b_ma_dl is null then b_loi:='loi:Sai kieu thanh toan dai ly thu:loi'; return; end if;
    for b_lp in 2..a_so_id.count loop
        select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=a_so_id(1) and kieu_kt<>'T' and ma_kt=b_ma_dl;
        if b_i1=0 then b_loi:='loi:Thanh toan cung ma dai ly:loi'; return; end if;
    end loop;
elsif b_pt_tra='C' and b_ma_kh='VANGLAI' then
    b_loi:='loi:Khong chon cong no khach vang lai:loi'; return;
end if;
if b_layHD='C' and (trim(b_dchi) is null or trim(b_email) is null) then
    b_loi:='loi:Nhap dia chi, eMail:loi';
end if;
b_so_id:=0;
for b_lp in 1.. a_so_id.count loop
    if b_kvat='N' and a_tien_tt(b_lp)>0 then b_loi:='loi:Sai kieu hoa don VAT:loi'; return; end if;
    b_so_id:=a_so_id(b_lp);
    b_i1:=FBH_HD_NGAY_BS(b_ma_dvi,b_so_id);
    if b_ngay_ht<b_i1 then b_loi:='loi:Khong thanh toan truoc ngay hop dong hoac ngay sua doi: '||PKH_SO_CNG(b_i1)||':loi'; return; end if;
    b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
    select kieu_hd,ma_kh into b_kieu_hd,b_ma_khX from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
    if b_ma_kh<>b_ma_khX then b_loi:='loi:Sai ma khach hang va hop dong thanh toan:loi'; return; end if;
    if b_kieu_hd in('U','K') then
        b_loi:='loi:Khong thanh toan cho hop dong uoc, kem:loi'; return;
    end if;
    if b_pt_tra='N' then
        if a_pt_tt(b_lp) not in('G','C') then b_loi:='loi:Da cho no phi:loi'; return; end if;
        a_pt_tt(b_lp):='C';
    end if;
    if b_pt_tra='H' and a_pt_tt(b_lp)<>'N' then b_loi:='loi:Sai kieu thanh toan no kho doi:loi'; return; end if;
    if a_pt_tt(b_lp)<>'N' then
        PBH_HD_TT_TON_TTOAN(b_ma_dvi,a_so_id(b_lp),a_ngay(b_lp),a_ma_nt_tt(b_lp),b_i1,b_i2,b_loi,b_ngay_ht);
    else
        PBH_HD_TT_TON_NO(b_ma_dvi,a_so_id(b_lp),a_ngay(b_lp),a_ma_nt_tt(b_lp),b_i1,b_i2,b_loi,b_ngay_ht);
    end if;
    if b_loi is not null then return; end if;
    if sign(b_i1)<>sign(a_tien_tt(b_lp)) or abs(b_i1)<abs(a_tien_tt(b_lp)) then
        b_loi:='loi:Sai tien thanh toan:loi'; return;
    end if;
    if a_ma_nt_tt(b_lp)<>'VND' then b_tp:=2; else b_tp:=0; end if;
    if b_i2=0 then
        a_thue_tt(b_lp):=0;
    elsif b_i1=a_tien_tt(b_lp) then
        a_thue_tt(b_lp):=b_i2;
    else
        a_thue_tt(b_lp):=round(b_i2*a_tien_tt(b_lp)/b_i1,b_tp);
    end if;
    if a_ma_nt_tt(b_lp)='VND' then
        a_tien_tt_qd(b_lp):=a_tien_tt(b_lp); a_thue_tt_qd(b_lp):=a_thue_tt(b_lp);
    elsif a_pt_tt(b_lp)='N' then
        a_tien_tt_qd(b_lp):=FBH_TH_NO_QD(b_ma_dvi,a_so_id(b_lp),a_ma_nt_tt(b_lp),b_ngay_ht,'C',a_tien_tt(b_lp));
        a_thue_tt_qd(b_lp):=round(a_thue_tt(b_lp)*a_tien_tt_qd(b_lp)/a_tien_tt(b_lp),0);
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,a_ma_nt_tt(b_lp));
        a_tien_tt_qd(b_lp):=round(a_tien_tt(b_lp)*b_i1,0);
        a_thue_tt_qd(b_lp):=round(a_thue_tt(b_lp)*b_i1,0);
    end if;
end loop;
b_ttoan_qd:=FKH_ARR_TONG(a_tien_tt_qd); b_thue_qd:=FKH_ARR_TONG(a_thue_tt_qd);
if a_ma_nt.count<>0 then
    for b_lp in 1..a_ma_nt.count loop
        if a_ma_nt(b_lp)<>'VND' then
            select count(*) into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=a_ma_nt(b_lp);
            if b_i1=0 then b_loi:='loi:Ngoai te '||a_ma_nt(b_lp)||'chua nhap:loi'; return; end if;
        end if;
        if a_pt(b_lp) is null then a_pt(b_lp):=b_pt_tra; end if;
    end loop;
elsif b_pt_tra not in('N','K') then
    a_pt(1):=b_pt_tra; a_ma_nt(1):='VND'; a_tien(1):=b_ttoan_qd;
end if;
for b_lp in 1..a_ma_nt.count loop
    if a_ma_nt(b_lp)='VND' then
        a_tien_qd(b_lp):=a_tien(b_lp);
    elsif a_pt(b_lp)='D' then
        a_tien_qd(b_lp):=PBH_DL_CN_TU_QD(b_ma_dvi,b_ma_dl,'C',a_ma_nt(b_lp),b_ngay_ht,a_tien(b_lp));
    elsif a_pt(b_lp)='B' then
        a_tien_qd(b_lp):=PBH_DO_BH_CN_QD(b_ma_dvi,b_ma_dl,a_ma_nt(b_lp),b_ngay_ht,'C',a_tien(b_lp));
    elsif a_pt(b_lp)='C' then
        a_tien_qd(b_lp):=PBH_KH_CN_TU_QD(b_ma_dvi,b_ma_kh,'C',a_ma_nt(b_lp),b_ngay_ht,a_tien(b_lp),b_phong);
    else
        a_tien_qd(b_lp):=FBH_TT_VND_QD(b_ngay_ht,a_ma_nt(b_lp),a_tien(b_lp));
    end if;
end loop;
b_i1:=0; b_i2:=0;
for b_lp in 1..a_so_id.count loop
    if a_pt_tt(b_lp)='N' then b_i1:=1; else b_i2:=1; end if;
end loop;
if b_i1<>0 and b_i2<>0 then
    b_loi:='loi:Khong thanh toan dong thoi vua thuc thu,ban hang vua no phi:loi'; return;
end if;
for b_lp in 1..a_so_id.count loop
    if b_lp<=1 or a_pt_tt(b_lp)='C' then continue; end if;
    b_i1:=b_lp-1;
    for b_lp1 in 1..b_i1 loop
        if a_pt_tt(b_lp1)='C' and a_so_id(b_lp1)=a_so_id(b_lp) and a_ngay(b_lp1)<>a_ngay(b_lp) then
            b_loi:='loi:Sai thanh toan phi:loi'; return;
        end if;
    end loop;
end loop;
PBH_HD_TT_TONk(b_ma_dvi,a_so_id,a_ngay,a_pt_tt,a_tien_tt,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_TEST:loi'; end if;
end;
/
create or replace PROCEDURE PBH_HD_TT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_ngay_ht number,b_kvat varchar2,b_so_id_tt number,
    b_ma_kh varchar2,b_pt_tra varchar2,b_nha_bh in out varchar2,b_ma_dl varchar2,
    b_vochD varchar2,b_vochK varchar2,b_so_ct in out varchar2,b_phong varchar2,
    b_ten nvarchar2,b_dchi nvarchar2,b_ma_thue varchar2,b_ttoan_qd number,b_thue_qd number,
    b_nt_tra varchar2,b_tra number,b_tra_qd number,b_kieuHD varchar2,b_layHD varchar2,
    b_htoan varchar2,b_so_don varchar2,b_ngay_bc number,b_ng_hd number,b_nd nvarchar2,
    a_so_id pht_type.a_num,a_ngay pht_type.a_num,a_pt_tt in out pht_type.a_var,a_ma_nt_tt pht_type.a_var,
    a_phi pht_type.a_num,a_tien_tt pht_type.a_num,a_tien_tt_qd pht_type.a_num,
    a_thue_tt pht_type.a_num,a_thue_tt_qd pht_type.a_num,
    a_pt pht_type.a_var,a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,
    dt_ct in out clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngay_nh number:=PKH_NG_CSO(sysdate);
    b_ton number; b_ton_qd number; b_kieu_do varchar2(1); b_ma_nt varchar2(5):=a_ma_nt_tt(1);
    a_so_idU pht_type.a_num;
begin
-- Dan - Nhap thanh toan phi
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id_tt),3);
    PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
insert into bh_hd_goc_ttps values(b_ma_dvi,b_so_id_tt,b_ngay_ht,b_kvat,b_so_ct,b_ma_kh,
    b_pt_tra,b_nha_bh,b_ma_dl,b_vochK,b_vochD,b_phong,b_ten,b_dchi,b_ma_thue,b_ttoan_qd,b_thue_qd,
    b_nt_tra,b_tra,b_tra_qd,b_kieuHD,b_layHD,b_htoan,b_so_don,b_nd,b_nsd,0,sysdate);
for b_lp in 1..a_pt.count loop
    insert into bh_hd_goc_ttct values(b_ma_dvi,b_so_id_tt,b_lp,a_pt(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
for b_lp in 1..a_so_id.count loop
    insert into bh_hd_goc_tthd values(b_ma_dvi,b_so_id_tt,b_lp,b_ngay_ht,a_so_id(b_lp),a_ngay(b_lp),
        a_pt_tt(b_lp),a_ma_nt_tt(b_lp),a_phi(b_lp),a_tien_tt(b_lp),a_tien_tt_qd(b_lp),a_thue_tt(b_lp),a_thue_tt_qd(b_lp));
end loop;
insert into bh_hd_goc_ttxt values(b_ma_dvi,b_so_id_tt,'dt_ct',dt_ct);
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
for b_lp in 1..a_so_id.count loop
    if a_pt_tt(b_lp)<>'N' then
        PBH_TH_PHI(b_ma_dvi,'C',a_so_id(b_lp),a_ma_nt_tt(b_lp),b_ngay_ht,a_tien_tt(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
    if a_pt_tt(b_lp) in('C','N') then
        PBH_TH_NO_THOP(b_ma_dvi,a_pt_tt(b_lp),a_so_id(b_lp),a_ma_nt_tt(b_lp),b_ngay_ht,a_tien_tt(b_lp),a_tien_tt_qd(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
PBH_TPA_HD_PS(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
if b_pt_tra='C' then
    for b_lp in 1..a_pt.count loop
        PBH_KH_CN_TU_THOP(b_ma_dvi,'C',b_ngay_ht,b_ma_kh,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi,b_phong);
        if b_loi is not null then return; end if;
    end loop;
    PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra='D' then
    for b_lp in 1..a_pt.count loop
        PBH_DL_CN_TU_THOP(b_ma_dvi,'C',b_ngay_ht,b_ma_dl,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
    PBH_DL_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra in('B','V') then
    for b_lp in 1..a_pt.count loop
        PBH_DO_BH_CN_THOP(b_ma_dvi,'C',b_ngay_ht,b_nha_bh,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
PKH_MANG_DUYn(a_so_id,a_so_idU);
for b_lp in 1..a_so_idU.count loop
    PBH_TH_TH_ID(b_ma_dvi,'T',a_so_idU(b_lp),b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_kieu_do:=FBH_DONG(b_ma_dvi,a_so_id(1));
--if b_kieu_do='G' then
--    PBH_HD_TT_NH_VAT(b_ma_dvi,b_nsd,b_so_id_tt,b_ngay_ht,b_kvat,b_phong,b_ma_kh,b_ma_nt,b_ma_thue,
--        b_ten,b_dchi,' ',' ',b_so_don,b_ngay_bc,b_ng_hd,b_htoan,b_ngay_nh,b_loi);
--    if b_loi is not null then return; end if;
if b_kieu_do='V' then
    for b_lp in 1..a_so_id.count loop
        PBH_TH_PHI_NBH(b_ma_dvi,'C',a_so_id(b_lp),b_nha_bh,a_ma_nt_tt(b_lp),a_tien_tt(b_lp),b_ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    if a_pt_tt(1)<>'N' then b_ma_nt:=a_ma_nt_tt(1); end if;
    PBH_HD_TT_NH_VAT_DO(b_ma_dvi,b_nsd,b_so_id_tt,b_ngay_ht,b_phong,b_nha_bh,b_ma_nt,b_so_don,b_ngay_bc,b_loi);
    if b_loi is not null then return; end if;
else
    for b_lp in 1..a_so_id.count loop
        PBH_HD_DO_TH_PS(b_ma_dvi,a_so_id(b_lp),b_so_id_tt,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
if FTBH_TMN(b_ma_dvi,a_so_id(1))='C' then
    for b_lp in 1..a_so_id.count loop
        PBH_TH_PHI_NBH(b_ma_dvi,'C',a_so_id(b_lp),b_nha_bh,a_ma_nt_tt(b_lp),a_tien_tt(b_lp),b_ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
PTBH_TH_TA_PHI_GHEP(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
if b_pt_tra not in('N','H') then
    PTBH_TH_TA_PHI_TM(b_ma_dvi,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_HD_TT_KE(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
--duong insert vao job
if b_pt_tra in ('T','N','B','C') then
   PBH_HD_VAT_JOB_INSERT(b_ma_dvi,b_so_id_tt,'TTP',b_nsd);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_NH_NH:loi'; end if;
end;
/
create or replace PROCEDURE PBH_HD_TT_XOA_XOA(
	b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,b_nh boolean,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_nsd_c varchar2(20); b_ngay_ht number; b_pt_tra varchar2(1);
    b_ma_kh varchar2(20); b_nha_bh varchar2(20); b_ma_dl varchar2(50); b_phong varchar2(10);
    b_ma_nt varchar2(5); b_tien number; b_tien_qd number; b_kh boolean:=false; b_dl varchar2(1):='T';
    b_ngay_nh date; b_kieuhd varchar2(1); b_vochD varchar2(20); b_htoan varchar2(1);
    b_so_id number; b_so_id_hd number; b_so_id_kt number; 
    a_so_id pht_type.a_num;
begin
-- Dan - Xoa thanh toan phi
select count(*) into b_i1 from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1=0 then b_loi:=''; return; end if;
select nsd,so_id_kt,ngay_ht,ma_kh,nha_bh,ma_dl,vochD,phong,kieuhd,ngay_nh,htoan,pt_tra into
    b_nsd_c,b_so_id_kt,b_ngay_ht,b_ma_kh,b_nha_bh,b_ma_dl,b_vochD,b_phong,b_kieuhd,b_ngay_nh,b_htoan,b_pt_tra
    from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
if b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
if b_so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,b_so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
select distinct so_id bulk collect into a_so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
for b_lp in 1..a_so_id.count loop
    select count(*) into b_i1 from bh_hd_goc_tthd where
        ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and so_id_tt>b_so_id_tt and ngay_ht>b_ngay_ht;
    if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu da co thanh toan:loi'; return; end if;
end loop;
for b_lp in 1..a_so_id.count loop
    select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=a_so_id(b_lp) and ttrang='D' and so_id>b_so_id_tt;
    if b_i1<>0 then
        b_loi:='loi:Khong sua, xoa thanh toan hop dong co sua doi, bo sung:loi'; return;
    end if;
end loop;
for b_lp in 1..a_so_id.count loop
    if FBH_PS_HH(b_ma_dvi,a_so_id(b_lp),b_so_id_tt)<>0 then
        b_loi:='loi:Chung tu da tra hoa hong:loi'; return;
    end if;
end loop;
for b_lp in 1..a_so_id.count loop
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_hd=a_so_id(b_lp) and ttrang='D' and ngay_qd>b_ngay_ht;
    if b_i1<>0 then b_loi:='loi:Khong sua, xoa thanh toan co ho so boi thuong da duyet:loi'; return; end if;
end loop;
if FBH_HD_DO_CT(b_ma_dvi,b_so_id_tt)<>0 then
    b_loi:='loi:Chung tu thanh toan da thanh toan dong BH:loi'; return;
end if;
if FBH_PS_VAT(b_ma_dvi,b_so_id_tt)<>0 or FBH_HD_DO_PS_VAT(b_ma_dvi,b_so_id_tt)<>0  then
    b_loi:='loi:Chung tu thanh toan da phat hanh hoa don thue:loi'; return;
end if;
for r_lp in (select so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt='C') loop
    select count(*) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and pt<>'C' and so_id_tt>b_so_id_tt;
    if b_i1<>0  then b_loi:='loi:Khong sua, xoa da thanh toan cho no phi :loi'; return; end if;
end loop;
for r_lp in (select so_id,pt,ma_nt,tien,tien_qd from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    b_so_id:=r_lp.so_id; b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
    if r_lp.pt<>'N'  then
        PBH_TH_PHI(b_ma_dvi,'C',b_so_id,b_ma_nt,b_ngay_ht,b_tien,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if r_lp.pt in('C','N') then
        PBH_TH_NO_THOP(b_ma_dvi,r_lp.pt,b_so_id,b_ma_nt,b_ngay_ht,b_tien,b_tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if b_nha_bh<>' ' then
        PBH_TH_PHI_NBH(b_ma_dvi,'C',b_so_id,b_nha_bh,b_ma_nt,b_tien,b_ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
if b_pt_tra='C' then
    for r_lp in (select ma_nt,tien,tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
        b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
        PBH_KH_CN_TU_THOP(b_ma_dvi,'C',b_ngay_ht,b_ma_kh,b_ma_nt,b_tien,b_tien_qd,b_loi,b_phong);
        if b_loi is not null then return; end if;
    end loop;
    PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra='D' then
    for r_lp in (select ma_nt,tien,tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
        b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
        PBH_DL_CN_TU_THOP(b_ma_dvi,'C',b_ngay_ht,b_ma_dl,b_ma_nt,b_tien,b_tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    PBH_DL_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra in('B','V') then
    for r_lp in (select ma_nt,tien,tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
        b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
        PBH_DO_BH_CN_THOP(b_ma_dvi,'C',b_ngay_ht,b_nha_bh,b_ma_nt,b_tien,b_tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_HD_TT_XOA_VAT(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
PBH_HD_TT_XOA_VAT_DO(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id_tt,0,0,0,b_loi);
if b_loi is not null then return; end if;
PBH_TPA_HD_XOA(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
delete bh_hd_goc_ttke where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttxt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_do_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
delete bh_hd_goc_sc_hh where dvi_xl=b_ma_dvi and so_id_tt=b_so_id_tt;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_TT_XOA_XOA:loi'; end if;
end;
/
--duchq update length email
create or replace PROCEDURE PBH_HD_TT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_i1 number; b_i2 number; b_t_suat number; b_kieu_do varchar2(1);
    b_c2 varchar2(50); b_kt1 number; b_ma_nt varchar2(5):='VND'; 
    b_phong varchar2(10); b_don varchar2(50); 
    
    b_lan number; b_so_hdon varchar2(30); b_ps varchar2(30); b_ttrang varchar2(30);b_so_id_hde number;
    b_so_hdon_tr varchar2(50); b_so_id_hdon number;
    b_ma_thue_tr varchar2(50); b_so_seri varchar2(50); b_ngay_nh number:=PKH_NG_CSO(sysdate);

    b_so_id_tt number; b_ngay_ht number; b_htoan varchar2(1);
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500); b_ma_thue varchar2(20); b_email varchar2(100);
    b_so_ct varchar2(20); b_pt_tra varchar2(1); b_kvat varchar2(1); b_kieuHD varchar2(1); b_layHD varchar2(1);
    b_so_don varchar2(20); b_ngay_bc number; b_ng_hd number;
    b_vochD varchar2(20); b_nd nvarchar2(500); b_ttoan_qd number; b_thue_qd number; 
    b_nha_bh varchar2(20); b_ma_dl varchar2(20); b_vochK varchar2(1);
    b_nt_tra varchar2(5); b_tra number; b_tra_qd number;

    a_so_id pht_type.a_num; a_ngay pht_type.a_num; a_pt pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_tien_qd pht_type.a_num; 
      
    a_pt_tt pht_type.a_var; a_ma_nt_tt pht_type.a_var; a_phi_tt pht_type.a_num;
    a_tien_tt pht_type.a_num; a_tien_tt_qd pht_type.a_num;
    a_thue_tt pht_type.a_num; a_thue_tt_qd pht_type.a_num;
    
    dt_ct clob; dt_dk clob;
begin
-- Dan - Nhap thanh toan phi
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id_tt<>0 then
    PBH_HD_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,true,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    PHT_ID_MOI(b_so_id_tt,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
PBH_HD_TT_TEST(
    b_ma_dvi,dt_ct,dt_dk,
    b_ngay_ht,b_htoan,b_kvat,b_ma_kh,b_so_ct,b_pt_tra,b_nha_bh,b_ma_dl,
    b_vochD,b_vochK,b_phong,b_ttoan_qd,b_thue_qd,b_kieuHD,b_layHD,b_so_don,b_ngay_bc,b_ng_hd,
    b_ten,b_dchi,b_email,b_ma_thue,b_nd,b_nt_tra,b_tra,b_tra_qd,
    a_so_id,a_ngay,a_pt_tt,a_ma_nt_tt,a_phi_tt,a_tien_tt,a_tien_tt_qd,a_thue_tt,a_thue_tt_qd,
    a_pt,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_TT_NH_NH(b_ma_dvi,b_nsd,b_ngay_ht,b_kvat,b_so_id_tt,b_ma_kh,b_pt_tra,b_nha_bh,
    b_ma_dl,b_vochD,b_vochK,b_so_ct,b_phong,b_ten,b_dchi,b_ma_thue,b_ttoan_qd,b_thue_qd,
    b_nt_tra,b_tra,b_tra_qd,b_kieuHD,b_layHD,b_htoan,b_so_don,b_ngay_bc,b_ng_hd,b_nd,
    a_so_id,a_ngay,a_pt_tt,a_ma_nt_tt,a_phi_tt,a_tien_tt,
    a_tien_tt_qd,a_thue_tt,a_thue_tt_qd,a_pt,a_ma_nt,a_tien,a_tien_qd,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id_tt,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_HD_TT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_tt number;
begin
-- Dan - Xoa thanh toan phi
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
PBH_HD_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,false,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HD_TT_NBH(b_ma_dvi varchar2,b_so_id_tt number) return varchar2
AS
    b_nha_bh varchar2(20):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_hd_goc_ttxt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_goc_ttxt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
    b_txt:=FKH_JS_BONH(b_txt); b_nha_bh:=nvl(trim(FKH_JS_GTRIs(b_txt,'nha_bh')),' ');
end if;
return b_nha_bh;
end;
