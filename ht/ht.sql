create or replace procedure PHT_ID_MOI(b_so_id out number,b_loi out varchar2,b_ngay number:=0)
AS
begin
-- Dan - Dang ky mot so ID moi cho chung tu
FHT_ID_MOI(b_so_id,b_ngay);
if b_so_id=0 then b_loi:='loi:Va cham NSD:loi'; end if;
end;
/
create or replace procedure FHT_ID_MOI(b_so_id out number,b_ngayN number:=0)
AS
    b_ngay number; b_ngay_ht number:=PKH_NG_CSO(sysdate);
    PRAGMA AUTONOMOUS_TRANSACTION;
begin
-- Dan - Tra so ID theo ngay
select ngay,so_id into b_ngay,b_so_id from ht_idM for update wait 10;
if sql%rowcount=0 then
    b_so_id:=0;
else
    if b_ngay=0 then
        b_so_id:=1;
        insert into ht_idM values(b_ngay_ht,1);
    elsif b_ngay_ht>b_ngay then
        b_so_id:=1;
        update ht_idM set ngay=b_ngay_ht,so_id=b_so_id;
    else
        b_so_id:=b_so_id+1;
        update ht_idM set so_id=b_so_id;
    end if;
    b_so_id:=b_ngay_ht*1000000+b_so_id;
end if;
commit;
exception when others then b_so_id:=0;
end;
/
create or replace function FKH_NV_TSO(b_ma_dvi varchar2,b_md varchar2,b_nv varchar2,b_ma varchar2,b_tkhao varchar2:=' ') return varchar2
AS
     b_kq varchar2(200);
begin
-- Dan - Liet ke
select nvl(min(tso),b_tkhao) into b_kq from kh_nv_tso where ma_dvi=b_ma_dvi and md=b_md and nv=b_nv and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DL_MA_KH_QLY(b_ma varchar2) return varchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select nvl(min(ma_ct),' ') into b_kq from bh_dl_ma_kh where ma=b_ma;
return b_kq;
end;
/
create or replace function FTT_TRA_TGTT(b_ma_dvi varchar2,b_ngay number,b_ma_nt varchar2) return number
AS
	b_d1 date; b_d2 date; b_tg number:=1;
begin
-- Dan - Tra ty gia thuc te
b_d2:=PKH_SO_CDT(b_ngay);
select max(ngay) into b_d1 from tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma_nt and ngay<=b_d2;
if b_d1 is not null then
	select ty_gia into b_tg from tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma_nt and ngay=b_d1;
end if;
return b_tg;
end;
/
create or replace procedure PHT_MA_MOI (b_ma out varchar2,b_loi out varchar2)
AS
    b_so number;
begin
-- Dan - Tra ma moi
b_ma:=''; PHT_ID_MOI(b_so,b_loi);
if b_loi is null then b_ma:=substr(trim(to_char(b_so)),2); end if;
end;
/
create or replace procedure PHT_NSD_LOGIN
	(b_ma_login varchar2,b_pas varchar2,b_ma_dvi out varchar2,b_nsd out varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(200); b_idvung number;
begin
-- Dan - Kiem tra ma NSD
PHT_MA_NSD_KTRA_VU('',b_ma_login,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(ma_dvi),nvl(min(ma),b_ma_login) into b_ma_dvi,b_nsd from ht_ma_nsd where ma_login=b_ma_login;
if FHT_MA_NSD_ACC(b_ma_dvi,b_nsd)='C' then
	open cs1 for select * from ht_dns where idvung=b_idvung;
else
	open cs1 for select * from ht_dns where idvung=b_idvung and md in
	(select distinct md from ht_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_NSD_KTRA_VU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_idvung out number,b_loi out varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2)
AS
begin
-- Dan - Kiem tra quyen NSD tra lai vung
if instr(b_ma_dvi,'$A$')<>1 then
    PHTG_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,b_nv,b_kt);
else
    PHTA_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,b_nv,b_kt);
end if;
end;
/
create or replace procedure PHTG_MA_NSD_KTRA_VU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_idvung out number,b_loi out varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2)
AS
begin
-- Dan - Kiem tra quyen NSD tra lai vung
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,b_kt);
if b_loi is null then
    b_idvung:=FHTG_MA_NSD_VUNG(b_ma_dvi,b_nsd);
    if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PHTA_MA_NSD_KTRA_VU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_idvung out number,b_loi out varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2)
AS
begin
-- Dan - Kiem tra quyen NSD tra lai vung
b_loi:=FHTA_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,b_kt);
if b_loi is null then b_idvung:=FHTA_MA_NSD_VUNG(b_ma_dvi,b_nsd); end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FHTG_MA_NSD_VUNG(b_ma_dvi varchar2, b_nsd varchar2) return number
AS
    b_idvung number;
begin
-- Dan - Tra vung NSD
if trim(b_ma_dvi) is null then
    select nvl(min(idvung),-1) into b_idvung from ht_login where ma=b_nsd;
else
    select nvl(min(idvung),-1) into b_idvung from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
end if;
return b_idvung;
end;
/
create or replace function FHTA_MA_NSD_VUNG(b_ma_dviN varchar2,b_nsdN varchar2) return number
AS
    b_idvung number:=0; b_ma_dvi varchar2(30):=FHTA_MA_DVI_CAT(b_ma_dviN);
begin
-- Dan - Tra vung NSD
if FHT_MA_NSD_LOAI(b_ma_dviN,b_nsdN)='D' then
    select nvl(min(idvung),0) into b_idvung from htA_ma_nsd where ma_dvi=b_ma_dvi;
end if;
return b_idvung;
end;
/
create or replace function FHT_MA_NSD_ACC (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Quyen chu Account
if instr(b_ma_dvi,'$A$')<>1 then
    b_kq:=FHTG_MA_NSD_ACC(b_ma_dvi,b_nsd);
else
    b_kq:=FHTA_MA_NSD_ACC(b_ma_dvi,b_nsd);
end if;
return b_kq;
end;
/
create or replace procedure PHT_MA_NSD_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs1 out pht_type.cs_type)
AS
begin
-- Dan - Kiem tra ma NSD
PHTG_MA_NSD_TEST(b_ma_dvi,b_nsd,b_pas,b_md,cs1);
/*if instr(b_ma_dvi,'$A$')<>1 then
    PHTG_MA_NSD_TEST(b_ma_dvi,b_nsd,b_pas,b_md,cs1);
else
    PHTA_MA_NSD_TEST(b_ma_dvi,b_nsd,b_pas,b_md,cs1);
end if;*/
end;
/
CREATE OR REPLACE procedure PHTG_MA_NSD_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(200); b_ma_ct varchar2(50); b_ma_dviG varchar2(20); a_nsd pht_type.a_nvar;
begin
-- Dan - Kiem tra ma NSD
b_loi:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Cam xam nhap:loi';
for b_lp in 1..20 loop a_nsd(b_lp):=' '; end loop;
if trim(b_ma_dvi) is not null then
    select ten,phong into a_nsd(1),a_nsd(2) from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
    select cap,ten,dchi,ma_thue,ma_ct,ktt,g_doc,ma_goc into a_nsd(3),a_nsd(4),a_nsd(5),
        a_nsd(6),b_ma_ct,a_nsd(9),a_nsd(10),a_nsd(11) from ht_ma_dvi where ma=b_ma_dvi;
    select nvl(min(ten),' ') into a_nsd(7) from ht_ma_dvi where ma=b_ma_ct;
    b_ma_dviG:=FHT_MA_DVI_ME(b_ma_dvi);
    a_nsd(12):=FKH_NV_TSO(b_ma_dviG,'HT','form','soN',',');
end if;
open cs1 for select a_nsd(1) ten,a_nsd(2) phong, a_nsd(3) cap, a_nsd(4) ten_dvi,a_nsd(5) dchi_dvi,a_nsd(6) ma_thue,
    a_nsd(7) ten_ct, a_nsd(8) ver, a_nsd(9) ten_ktt, a_nsd(10) ten_gd,a_nsd(11) ma_goc,a_nsd(12) form_soN from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHT_MA_DVI_ME (b_ma varchar2) return varchar2
AS
    b_me varchar2(20):=b_ma; b_ma_ct varchar2(20):='a'; b_nh varchar2(1):=FHT_MA_DVI_NHOM(b_ma); b_nhC varchar2(1);
begin
-- Dan - Tra don vi cao nhat
while trim(b_ma_ct) is not null loop
    select min(ma_ct) into b_ma_ct from ht_ma_dvi where ma=b_me;
    if trim(b_ma_ct) is not null then
        b_nhC:=FHT_MA_DVI_NHOM(b_ma_ct);
        if b_nhC=b_nh or (b_nhC in('T','G') and b_nh in('T','G')) then b_me:=b_ma_ct; else exit; end if;
    end if;
end loop;
return b_me;
end;
/
create or replace function FHT_MA_DVI_NHOM (b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra don vi gan nhat
if b_ma is not null then
    select min(vp) into b_kq from ht_ma_dvi where ma=b_ma;
end if;
return b_kq;
end;
/
create or replace procedure PKH_MA_HANJ_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
	b_loi varchar2(100); b_lenh varchar2(1000); 
  b_dong number; b_tu number; b_den number; b_tim nvarchar2(100);
  cs_lke clob:=''; b_md varchar2(20):='BH';
begin
-- viet anh - Xem han thay doi so lieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,'','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
select count(*) into b_dong from kh_ma_han where ma_dvi=b_ma_dvi and md=b_md order by ma_cd;
select JSON_ARRAYAGG(json_object(ma_dvi,md,ma_cd,nv,ma_nsd,ngay,'ngay_ht' value PKH_NG_CSO(ngay_ht),lydo,nsd,idvung) 
       order by ma_cd) into cs_lke from kh_ma_han where ma_dvi=b_ma_dvi and md=b_md order by ma_cd,nv;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HANJ_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
    b_loi varchar2(100);
    cs_ma_cd clob; cs_nv clob; b_idvung number;
begin
-- viet anh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,'ten' value ten_gon,ma_ct returning clob) order by ten_gon returning clob) 
       into cs_ma_cd from ht_ma_dvi where idvung=b_idvung and b_ma_dvi in(ma,ma_ct);
select json_object('cs_ma_cd' value cs_ma_cd returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HANJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(200); b_i1 number; b_ma_ct varchar2(10); b_idvung number;  b_lenh varchar2(1000);
    b_ngay_log date:=sysdate; b_ma_nsd varchar2(20):=b_nsd; b_nv_bh varchar2(20); b_ngay_d number;
    b_md varchar2(10):='BH';b_ma_cd varchar2(10);b_nv varchar2(10);b_ngay number;
begin
-- Dan - Nhap han thay doi so lieu
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_cd,nv,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma_cd,b_nv,b_ngay using b_oraIn;
if trim(b_ma_nsd) is not null then
    if b_md<>'HD' then
        if instr(b_ma_nsd,'$A$')=0 then
            select count(*) into b_i1 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma_nsd;
            if b_i1=0 then b_loi:='loi:Ma NSD '||b_ma_nsd||' chua khai bao:loi'; raise PROGRAM_ERROR; end if;
            if b_ma_cd='AL' then
                b_loi:='loi:Phai chon don vi va nghiep vu:loi';raise PROGRAM_ERROR;
            end if;
        else
            select count(*) into b_i1 from hta_ma_nsd where ma=substr(b_ma_nsd,4);
            if b_i1=0 then b_loi:='loi:Ma NSD '||b_ma_nsd||' chua khai bao:loi'; raise PROGRAM_ERROR; end if;
            if b_ma_cd='AL' then
                b_loi:='loi:Phai chon don vi va nghiep vu:loi';raise PROGRAM_ERROR;
            end if;
        end if;
    else
        select count(*) into b_i1 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma_nsd;
        if b_i1=0 then b_loi:='loi:Ma NSD '||b_ma_nsd||' chua khai bao:loi'; raise PROGRAM_ERROR; end if;
        if b_ma_cd='AL' then
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