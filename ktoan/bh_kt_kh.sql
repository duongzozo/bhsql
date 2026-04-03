/*** Tai khoan hach toan nghiep vu bao hiem ***/
create or replace function FBH_KT_TK_TRAt(
    b_ma_dvi varchar2,b_ngay_ht number,b_nt_tra varchar2,b_tk_nha varchar2) return varchar2
AS
    b_tk_tra varchar2(20);
begin
-- Dan - Tra tai khoan thanh toan
if b_tk_nha=' ' then
    if b_nt_tra='VND' then
        b_tk_tra:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMV',b_ngay_ht,'N');
    else
        b_tk_tra:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TMN',b_ngay_ht,'N');
    end if;
else
    if b_nt_tra='VND' then
        b_tk_tra:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGV',b_ngay_ht,'N');
    else
        b_tk_tra:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT','TGN',b_ngay_ht,'N');
    end if;
end if;
return b_tk_tra;
end;
/
create or replace function FBH_TKE_KT_NV(b_ma_dvi varchar2,b_lh_nv varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
select min(ma_tke) into b_kq from bh_tke_kt_nv where ma_dvi=b_ma_dvi and lh_nv=b_lh_nv;
return b_kq;
end;
/
create or replace function FBH_KT_NGAY_HT(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_ngay_ht number;
begin
-- Dan - Tra NGAY_HT
select nvl(min(ngay_ht),0) into b_ngay_ht from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_ngay_ht;
end;
/
create or replace procedure PBH_KT_TK_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke ngay khai bao
open cs1 for select distinct ngay,ngay ngay_so,nsd from bh_kt_matk where ma_dvi=b_ma_dvi order by ngay;
end;
/
create or replace procedure PBH_KT_TK_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke tai khoan theo ngay
open cs1 for select * from bh_kt_matk where ma_dvi=b_ma_dvi and ngay=b_ngay;
end;
/
create or replace procedure PBH_KT_TK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,
    a_nhom pht_type.a_var,a_loai pht_type.a_var,a_ma_tk pht_type.a_var,a_tk_thue in out pht_type.a_var,a_tc pht_type.a_var)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Nhap tai khoan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null or a_nhom.count=0 then b_loi:='loi:Nhap so lieu sai:loi'; raise PROGRAM_ERROR; end if;
delete bh_kt_matk where ma_dvi=b_ma_dvi and ngay=b_ngay;
for b_lp in 1..a_nhom.count loop
    b_loi:='loi:Nhap tai khoan sai dong '||to_char(b_lp)||':loi';
    a_tk_thue(b_lp):=nvl(a_tk_thue(b_lp),' ');
    if a_nhom(b_lp) is null or a_loai(b_lp) is null or a_ma_tk(b_lp) is null
        or a_tc(b_lp) is null or a_tc(b_lp) not in('T','N') then raise PROGRAM_ERROR; end if;
    if a_tc(b_lp)<>'N' then
        select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
        if a_tk_thue(b_lp)<>' ' then
            select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_tk_thue(b_lp);
        end if;
    else
        select 0 into b_i1 from nb_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
    end if;
    insert into bh_kt_matk values(b_ma_dvi,b_ngay,a_nhom(b_lp),a_loai(b_lp),a_ma_tk(b_lp),a_tk_thue(b_lp),b_nsd);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_TK_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa khai bao tai khoan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
delete bh_kt_matk where ma_dvi=b_ma_dvi and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_KT_TK_TRA(b_ma_dvi varchar2,b_ngay number,b_nhom varchar2,b_loai varchar2) return varchar2
AS
    b_ma_tk varchar2(20); b_tk_thue varchar2(20);b_i1 number;
begin
-- Dan - Tra tai khoan theo loai
select nvl(max(ngay),0) into b_i1 from bh_kt_matk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
if b_i1=0 then return ''; end if;
select min(ma_tk) into b_ma_tk from bh_kt_matk where ma_dvi=b_ma_dvi and ngay=b_i1 and nhom=b_nhom and loai=b_loai;
return b_ma_tk;
end;
/
create or replace procedure PBH_KT_TKT_TRA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay number,b_nhom varchar2,b_loai varchar2,b_nbh varchar2,b_ma_tk out varchar2)
AS
    b_loi varchar2(100); b_nn varchar2(1); 
begin
-- Dan - Tra tai khoan tai
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_nbh) is not null then
    select nvl(min(loai),'T') into b_nn from bh_ma_nbh where ma=b_nbh;
end if;
b_ma_tk:=FBH_KT_TK_TRA(b_ma_dvi,b_ngay,b_nhom,b_loai||b_nn);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_TKT_THUE(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay number,b_nhom varchar2,b_loai varchar2,b_nbh varchar2,b_ma_tk out varchar2)
AS
    b_loi varchar2(100); b_nn varchar2(1):=''; 
begin
-- Dan - Tra tai khoan tai
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_nbh) is not null then
    select nvl(min(loai),'T') into b_nn from bh_ma_nbh where ma=b_nbh;
end if;
b_ma_tk:=FBH_KT_TK_THUE(b_ma_dvi,b_ngay,b_nhom,b_loai||b_nn);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_KT_TK_THUE(b_ma_dvi varchar2,b_ngay number,b_nhom varchar2,b_loai varchar2) return varchar2
AS
    b_tk_thue varchar2(20); b_i1 number;
begin
-- Dan - Tra tai khoan thue theo loai
select nvl(max(ngay),0) into b_i1 from bh_kt_matk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
if b_i1=0 then return ''; end if;
select min(tk_thue) into b_tk_thue from bh_kt_matk where ma_dvi=b_ma_dvi and ngay=b_i1 and nhom=b_nhom and loai=b_loai;
return b_tk_thue;
end;
/
create or replace procedure PBH_KT_TK_TRA(b_ma_dvi varchar2,b_ngay number,
    b_nhom varchar2,b_loai varchar2,b_ma_tk out varchar2,b_tk_thue out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra tai khoan theo loai
b_ma_tk:=''; b_tk_thue:='';
select nvl(max(ngay),0) into b_i1 from bh_kt_matk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
if b_i1<>0 then
    select min(ma_tk),min(tk_thue) into b_ma_tk,b_tk_thue from bh_kt_matk
    where ma_dvi=b_ma_dvi and ngay=b_i1 and nhom=b_nhom and loai=b_loai;
end if;
end;
/
