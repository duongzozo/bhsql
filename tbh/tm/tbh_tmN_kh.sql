/*** DONG BAO HIEM ***/
create or replace function FTBH_TMN_VAT_LOAI(b_ma_dvi varchar2,b_so_id_vat number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra loai
select min(loai) into b_kq from tbh_tmN_vat where ma_dvi=b_ma_dvi and so_id_vat=b_so_id_vat;
return b_kq;
end;
/
create or replace function FBH_TMN_PS_VAT(b_ma_dvi varchar2,b_so_id_tt number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from tbh_tmN_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id_vat<>b_so_id_tt;
return b_kq;
end;
/
create or replace function FBH_TMN_NBH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac nha BH
select nvl(min(nha_bh),' '),count(*) into b_kq,b_i1 from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>1 then b_kq:=' '; end if;
return b_kq;
end;
/
create or replace function FTBH_TMN_NBHk(b_ma_dvi varchar2,b_so_id number,b_nbh varchar2:=' ') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Xac dinh nha BH
select count(*) into b_i1 from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and b_nbh in(' ',nha_bh);
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FTBH_TMN_NBHV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Xac nha BH ve
select nvl(min(nha_bh),' ') into b_kq from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_TMN_PS_NG(b_ma_dvi varchar2,b_so_id_ps number) return number
AS
    b_kq number;
begin
-- Dan - Ngay phat sinh so lieu dong
select min(ngay_ht) into b_kq from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FBH_TMN_PS(b_ma_dvi varchar2,b_so_id number,b_so_id_ps number:=0) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
if b_so_id_ps<>0 then
    select count(*) into b_kq from tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps;
else
    select count(*) into b_kq from tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
return b_kq;
end;
/
create or replace function FBH_TMN_CT(b_ma_dvi varchar2,b_so_id_ps number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from tbh_tmN_ct where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace procedure FTBH_TMN_CN_TON
    (b_ma_dvi varchar2,b_nha_bh varchar2,b_ma_nt varchar2,b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from tbh_tmN_sc where
    ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
    b_ton:=0; b_ton_qd:=0;
else
    select nvl(ton,0),nvl(ton_qd,0) into b_ton,b_ton_qd from tbh_tmN_sc where
        ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace function PTBH_TMN_CN_QD
    (b_ma_dvi varchar2,b_nha_bh varchar2,b_ma_nt varchar2,b_ngay_ht number,b_l_ct varchar2,b_tien number) return number
AS
    b_i1 number; b_ton number:=0; b_ton_qd number; b_noite varchar2(5):='VND'; b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
if b_ma_nt<>b_noite then
    FTBH_TMN_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
    if b_l_ct='T' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
    if b_ton=b_tien then b_tien_qd:=b_ton_qd;
    elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
        if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
        else b_tien_qd:=round(b_tien*b_i1,0);
        end if;
    end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure PTBH_TMN_TH_VAT(b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number:=0; b_ngay_ht number; b_nha_bh varchar2(20);
begin
-- Dan - Tong hop so cai thue VAT
b_loi:='loi:Loi xu ly PBH_TMN_TH_VAT:loi';
delete temp_1;
delete tbh_tmN_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_ngay_ht<>0 then
    insert into temp_1(c1,c2,n5) select 'R',ma_nt,phi from bh_hd_goc_ttpt where
        ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and pt<>'C';
else
    select nvl(min(ngay_ht),0) into b_ngay_ht from tbh_tmN_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    if b_ngay_ht<>0 then
        insert into temp_1(c1,c2,n5) select decode(nv,'T','R','V'),ma_nt,tien from
        (select nv,ma_nt,sum(tien) tien from tbh_tmN_pt where ma_dvi=b_ma_dvi and
        so_id_tt=b_so_id_tt group by nv,ma_nt having sum(tien)<>0);
    end if;
end if;
if b_ngay_ht=0 then b_loi:=''; return; end if;
insert into temp_1(c1,c2,n5)
    select FTBH_TMN_VAT_LOAI(b_ma_dvi,so_id_vat),ma_nt,-tien
    from tbh_tmN_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select count(*) into b_i1 from
    (select c1,c2,sum(n5) from temp_1 group by c1,c2 having sum(n5)<>0);
if b_i1<>0 then
    select nvl(min(nha_bh),' ') b_nha_bh into b_nha_bh from tbh_tmN_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    if b_nha_bh<>' ' then
        insert into tbh_tmN_sc_vat values(b_ma_dvi,b_so_id_tt,' ',b_nha_bh,b_ngay_ht);
    end if;
end if;
b_loi:='';
delete temp_1;
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PTBH_TMN_CN_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du
select nvl(min(ngay_ht),0) into b_i1 from tbh_tmN_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TMN_CN_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_nha_bh varchar2,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_thu number; b_chi number; b_ton number; b_i1 number; b_i2 number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop so cai
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
FBH_DO_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update tbh_tmN_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into tbh_tmN_sc values(b_ma_dvi,b_nha_bh,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from tbh_tmN_sc where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 and b_rc.thu_qd=0 and b_rc.chi_qd=0 then
        delete tbh_tmN_sc where ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update tbh_tmN_sc set ton=b_ton,ton_qd=b_ton_qd where
            ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
select nvl(min(ngay_ht),0) into b_i1 from tbh_tmN_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1<>0 then
    b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
