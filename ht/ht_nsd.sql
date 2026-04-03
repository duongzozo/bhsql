
create or replace function FHTA_MA_NSD_KTRA
    (b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_md varchar2,
    b_nv varchar2,b_kt varchar2,b_comm varchar2:='C') return varchar2
AS
    b_ma_dvi varchar2(30):=FHTA_MA_DVI_CAT(b_ma_dviN); b_nsd varchar2(50):=FHTA_MA_NSD_CAT(b_nsdN);
    b_i1 number; b_pas_c varchar2(20); b_d1 date; b_loi varchar2(100); b_ma_login varchar2(50); b_qu varchar2(1);
    a_nv pht_type.a_var; a_kt pht_type.a_var; a_nv1 pht_type.a_var; a_kt1 pht_type.a_var;
begin
-- Dan - Kiem tra quyen NSD
if FHT_MA_NSD_LOAI(b_ma_dviN,b_nsdN)<>'D' then return ''; end if;
b_loi:='loi:Cam xam nhap:loi';
b_ma_login:=FHTA_MA_NSD_LOGIN(b_ma_dviN,b_nsdN);
select pas,tgian,nloi,qu into b_pas_c,b_d1,b_i1,b_qu from htA_login where ma=b_ma_login;
if b_i1>100 then return 'loi:Nguoi su dung da het han:loi'; end if;
if b_i1>2 and 86400*(sysdate-b_d1)<30 then return b_loi; end if;
if (b_pas_c is null and b_pas is not null) or (b_pas_c is not null and b_pas is null) or b_pas_c<>b_pas then
    update htA_login set tgian=sysdate,nloi=nloi+1 where ma=b_ma_login;
    if b_comm='C' then commit; end if;
    return b_loi;
end if;
if b_i1>0 and b_comm='C' then
    update htA_login set nloi=0 where ma=b_ma_login;
    commit;
end if;
if b_md is null or b_qu='C' then return ''; end if;
select count(*) into b_i1 from htA_ma_nsd where ma_dvi=b_ma_dvi;
if b_i1=0 then return b_loi; end if;
if b_nv is not null or b_kt is not null then
    PKH_CH_ARR(b_nv,a_nv); PKH_CH_ARR(b_kt,a_kt);
    if b_kt is null then
        for b_lp in 1..a_nv.count loop a_kt(b_lp):=''; end loop;
    elsif b_nv is null then
        for b_lp in 1..a_kt.count loop a_nv(b_lp):=''; end loop;
    end if;
end if;
return b_loi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else return b_loi; end if;
end;
/
create or replace function FHTA_MA_DVI_CAT(b_ma varchar2) return varchar2
AS
    b_kq varchar2(30):=b_ma; b_i1 number;
begin
-- Dan - Gon NSD
if b_ma<>'$A$' and instr(b_ma,'$A$')=1 then b_kq:=substr(b_ma,4); end if;
return b_kq;
end;
/
create or replace function FHTA_MA_NSD_CAT(b_ma varchar2) return varchar2
AS
    b_kq varchar2(30):=b_ma; b_c3 varchar2(3):=substr(b_ma,1,3); b_i1 number;
begin
-- Dan - Gon NSD
if b_c3 in('$G$','$F$') then
    b_kq:=b_c3;
else
    b_kq:=substr(b_ma,4);
    b_i1:=instr(b_kq,'|');      -- Tham so Agent co ten
    if b_i1>1 then
        b_i1:=b_i1-1;
        b_kq:=substr(b_kq,1,b_i1);
    end if;
end if;
-- truonghq ko cat $A$ voi truong hop linkhouse de phan biet voi bancas
if b_c3 in('$A$') then b_kq := b_ma; end if;
return b_kq;
end;
/
create or replace function FHT_MA_NSD_LOAI
    (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_kq varchar2(1):='N';
begin
-- Dan - Tra loai NSD
if instr(b_ma_dvi,'$A$')=1 then b_kq:=substr(b_nsd,2,1); end if;
return b_kq;
end;
/
CREATE OR REPLACE function FHTA_MA_NSD_LOGIN(b_ma_dviN varchar2,b_nsdN varchar2) return varchar2
AS
    b_i1 number; b_ma_login varchar2(50);
    b_ma_dvi varchar2(30):=FHTA_MA_DVI_CAT(b_ma_dviN); b_nsd varchar2(50):=FHTA_MA_NSD_CAT(b_nsdN);
begin
-- Dan - Tra ma login
b_ma_login:=b_nsd;
if FHT_MA_NSD_LOAI(b_ma_dviN,b_nsdN)='D' then
    select min(ma_login) into b_ma_login from htA_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
end if;
return b_ma_login;
end;
/
create or replace function FHTG_MA_NSD_ACC
    (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_qu varchar2(1):='K'; b_ma_login varchar2(50);
begin
-- Dan - Quyen chu Account
b_ma_login:=FHTG_MA_NSD_LOGIN(b_ma_dvi,b_nsd);
if b_ma_login is not null then select nvl(min(qu),'K') into b_qu from ht_login where ma=b_ma_login; end if;
return b_qu;
end;
/

create or replace function FHT_MA_NSD_KTRA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,
    b_nv varchar2,b_kt varchar2,b_comm varchar2:='C') return varchar2
AS
    b_kq varchar2(100):='';
begin
-- Dan - Kiem tra quyen NSD
if instr(b_ma_dvi,'$A$')<>1 then
    b_kq:=FHTG_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,b_kt,b_comm);
else
    b_kq:=FHTA_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,b_kt,b_comm);
end if;
return b_kq;
end;
/
create or replace function FHTG_MA_NSD_KTRA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,
    b_nv varchar2,b_kt varchar2,b_comm varchar2:='C') return varchar2
AS
    b_i1 number; b_pas_c varchar2(20); b_d1 date; b_loi varchar2(100); b_ma_login varchar2(50); b_qu varchar2(1);
    a_nv pht_type.a_var; a_kt pht_type.a_var; a_nv1 pht_type.a_var; a_kt1 pht_type.a_var;
begin
-- Dan - Kiem tra quyen NSD
b_loi:='loi:Cam xam nhap:loi';
b_ma_login:=FHTG_MA_NSD_LOGIN(b_ma_dvi,b_nsd);
select pas,tgian,nloi,qu into b_pas_c,b_d1,b_i1,b_qu from ht_login where ma=b_ma_login;
if b_i1>100 then return 'loi:Nguoi su dung da het han:loi'; end if;
if b_i1>2 and 86400*(sysdate-b_d1)<30 then return b_loi; end if;
if (b_pas_c is null and b_pas is not null) or (b_pas_c is not null and b_pas is null) or b_pas_c<>b_pas then
    update ht_login set tgian=sysdate,nloi=nloi+1 where ma=b_ma_login;
    if b_comm='C' then commit; end if;
    return b_loi;
end if;
if b_i1>0 and b_comm='C' then
    update ht_login set nloi=0 where ma=b_ma_login;
    commit;
end if;
if b_md is null or b_qu='C' then return ''; end if;
if b_ma_dvi is null then return b_loi; end if;
b_loi:='';
select count(*) into b_i1 from ht_ma_dvi;
if b_i1=0 then return 'C'; end if;
select count(*) into b_i1 from ht_ma_nsd where ma_dvi=b_ma_dvi;
if b_i1=0 then return 'C'; end if;
if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HT','0')<>'C' and (b_nv is not null or b_kt is not null) then
    PKH_CH_ARR(b_nv,a_nv); PKH_CH_ARR(b_kt,a_kt);
    if b_kt is null then
        for b_lp in 1..a_nv.count loop a_kt(b_lp):=''; end loop;
    elsif b_nv is null then
        for b_lp in 1..a_kt.count loop a_nv(b_lp):=''; end loop;
    end if;
    b_i1:=0;
    for b_lp in 1..a_nv.count loop
        if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,a_nv(b_lp),a_kt(b_lp))='C' then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then b_loi:='loi:Khong vuot quyen:loi'; end if;
end if;
return b_loi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else return b_loi; end if;
end;
/
create or replace function FHTG_MA_NSD_LOGIN
    (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_ma_login varchar2(50);
begin
-- Dan - Tra ma login
if b_ma_dvi is null then b_ma_login:=b_nsd;
else select min(ma_login) into b_ma_login from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
end if;
return b_ma_login;
end;
/
create or replace function FHT_MA_NSD_PHONG (b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
    b_phong varchar2(10);
begin
-- Dan - Ma phong NSD
select nvl(min(phong),' ') into b_phong from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
return b_phong;
end;
/
create or replace function FHT_MA_NSD_QU (
    b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Kiem tra quyen NSD
if instr(b_ma_dvi,'$A$')<>1 then
    b_kq:=FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,b_nv,b_kt);
else
    b_kq:=FHTA_MA_NSD_QU(b_ma_dvi,b_nsd,b_md,b_nv,b_kt);
end if;
return b_kq;
end;
/
create or replace function FHTA_MA_NSD_QU(
    b_ma_dviN varchar2,b_nsdN varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2) return varchar2
AS
    b_i1 number; b_tc varchar2(10); b_i2 number:=length(b_kt);
    b_ma_dvi varchar2(30):=FHTA_MA_DVI_CAT(b_ma_dviN); b_nsd varchar2(50):=FHTA_MA_NSD_CAT(b_nsdN);
begin
-- Dan - Kiem tra quyen NSD
if FHT_MA_NSD_LOAI(b_ma_dviN,b_nsdN) in ('A','G','F') or FHTA_MA_NSD_ACC(b_ma_dviN,b_nsdN)='C' then return 'C'; end if;
if b_nv is null or b_kt is null then
    if b_nv is null and b_kt is null then
        select count(*) into b_i1 from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md;
        if b_i1<>0 then return 'C'; end if;
        select count(*) into b_i1 from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md;
        if b_i1<>0 then return 'C'; end if;
    elsif b_nv is null then
        for r_lp in (select tc from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
            b_tc:=r_lp.tc;
            if b_tc is not null then
                for b_lp in 1..b_i2 loop
                    if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
                end loop;
            end if;
        end loop;
        for r_lp1 in (select nhom from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
            for r_lp in (select tc from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=r_lp1.nhom) loop
                b_tc:=r_lp.tc;
                if b_tc is not null then
                    for b_lp in 1..b_i2 loop
                        if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
                    end loop;
                end if;
            end loop;
        end loop;
    else
        select count(*) into b_i1 from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nv=b_nv;
        if b_i1<>0 then return 'C'; end if;
        for r_lp in (select nhom from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
            select count(*) into b_i1 from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=r_lp.nhom and nv=b_nv;
            if b_i1<>0 then return 'C'; end if;
        end loop;
    end if;
else
    select min(tc) into b_tc from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nv=b_nv;
    if b_tc is not null then
        for b_lp in 1..b_i2 loop
            if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
        end loop;
    end if;
    for r_lp in (select nhom from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
        select min(tc) into b_tc from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=r_lp.nhom and nv=b_nv;
        if b_tc is not null then
            for b_lp in 1..b_i2 loop
                if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
            end loop;
        end if;
    end loop;
end if;
return 'K';
end;
/
create or replace function FHTA_MA_NSD_ACC (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_qu varchar2(1):='K'; b_ma_login varchar2(50);
begin
-- Dan - Quyen chu Account
b_ma_login:=FHTA_MA_NSD_LOGIN(b_ma_dvi,b_nsd);
if b_ma_login is not null then
    select nvl(min(qu),'K') into b_qu from htA_login where ma=b_ma_login;
end if;
return b_qu;
end;
/
create or replace procedure PHT_MA_NSD_MENU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_bq varchar2,a_qu pht_type.a_var,cs1 out pht_type.cs_type)
AS
begin
-- Dan - Xem he thong ma NSD
if instr(b_ma_dvi,'$A$')<>1 then
    PHTG_MA_NSD_MENU(b_ma_dvi,b_nsd,b_pas,b_bq,a_qu,cs1);
else
    PHTA_MA_NSD_MENU(b_ma_dvi,b_nsd,b_pas,b_bq,a_qu,cs1);
end if;
end;
/
create or replace procedure PHTG_MA_NSD_MENU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_bq varchar2,a_qu pht_type.a_var,cs1 out pht_type.cs_type)
AS
    a_s pht_type.a_var;
begin
-- Dan - Xem he thong ma NSD
delete temp_1; commit;
for b_lp in 1..a_qu.count loop
    PKH_CH_ARR(a_qu(b_lp),a_s);
    if a_s.count<2 then a_s(2):=''; a_s(3):='';
    elsif a_s.count<3 then a_s(3):='';
    end if;
    if FHTG_MA_NSD_QU(b_ma_dvi,b_nsd,a_s(1),a_s(2),a_s(3))='C' then
        insert into temp_1(c1) values(a_qu(b_lp));
    end if;
end loop;
open cs1 for select c1 qu from temp_1;
delete temp_1; commit;
end;
/
create or replace procedure PHTA_MA_NSD_MENU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_bq varchar2,a_qu pht_type.a_var,cs1 out pht_type.cs_type)
AS
    a_s pht_type.a_var;
begin
-- Dan - Xem he thong ma NSD
delete temp_1; commit;
for b_lp in 1..a_qu.count loop
    PKH_CH_ARR(a_qu(b_lp),a_s);
    if a_s.count<2 then a_s(2):=''; a_s(3):='';
    elsif a_s.count<3 then a_s(3):='';
    end if;
    if FHTA_MA_NSD_MENU(b_ma_dvi,b_nsd,a_s(1),a_s(2),a_s(3))='C' then
        insert into temp_1(c1) values(a_qu(b_lp));
    end if;
end loop;
open cs1 for select c1 qu from temp_1;
delete temp_1; commit;
end;
/
create or replace function FHTA_MA_NSD_MENU(
    b_ma_dviN varchar2,b_nsdN varchar2,b_md varchar2,b_nv varchar2,b_kt varchar2) return varchar2
AS
    b_i1 number; b_tc varchar2(10); b_i2 number:=length(b_kt);
    b_ma_dvi varchar2(30):=FHTA_MA_DVI_CAT(b_ma_dviN); b_nsd varchar2(50):=FHTA_MA_NSD_CAT(b_nsdN);
begin
-- Dan - Kiem tra quyen NSD
if b_nv is null or b_kt is null then
    if b_nv is null and b_kt is null then
        select count(*) into b_i1 from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md;
        if b_i1<>0 then return 'C'; end if;
        select count(*) into b_i1 from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md;
        if b_i1<>0 then return 'C'; end if;
    elsif b_nv is null then
        for r_lp in (select tc from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
            b_tc:=r_lp.tc;
            if b_tc is not null then
                for b_lp in 1..b_i2 loop
                    if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
                end loop;
            end if;
        end loop;
        for r_lp1 in (select nhom from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
            for r_lp in (select tc from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=r_lp1.nhom) loop
                b_tc:=r_lp.tc;
                if b_tc is not null then
                    for b_lp in 1..b_i2 loop
                        if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
                    end loop;
                end if;
            end loop;
        end loop;
    else
        select count(*) into b_i1 from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nv=b_nv;
        if b_i1<>0 then return 'C'; end if;
        for r_lp in (select nhom from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
            select count(*) into b_i1 from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=r_lp.nhom and nv=b_nv;
            if b_i1<>0 then return 'C'; end if;
        end loop;
    end if;
else
    select min(tc) into b_tc from htA_ma_nsd_nv where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md and nv=b_nv;
    if b_tc is not null then
        for b_lp in 1..b_i2 loop
            if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
        end loop;
    end if;
    for r_lp in (select nhom from htA_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md=b_md) loop
        select min(tc) into b_tc from ht_ma_nhom_nv where ma_dvi=b_ma_dvi and md=b_md and ma=r_lp.nhom and nv=b_nv;
        if b_tc is not null then
            for b_lp in 1..b_i2 loop
                if instr(b_tc,substr(b_kt,b_lp,1))<>0 then return 'C'; end if;
            end loop;
        end if;
    end loop;
end if;
return 'K';
end;
/
create or replace procedure PKH_NSD_DU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,cs_lke out pht_type.cs_type)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_md is null or b_nv is null then b_loi:='loi:Nhap Modul, nghiep vu:loi'; end if;
open cs_lke for select * from kh_nsd_du where ma_dvi=b_ma_dvi and nsd=b_nsd and md=b_md and nv=b_nv;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHT_MA_NSD_LUU (b_ma_dvi varchar2,b_nsd varchar2) return varchar2
AS
    b_kq varchar2(10):='';
begin
-- Dan - Tra dns NSD
if trim(b_ma_dvi) is not null then b_kq:=b_nsd; end if;
return b_kq;
end;
/
create or replace function FKH_NV_DVI(b_ma_dvi varchar2,b_bang varchar2) return varchar2
AS
    b_kq varchar2(20):=b_ma_dvi; b_kt number:=0; b_dvi varchar2(20):=b_ma_dvi;
    a_dvi pht_type.a_var;
begin
-- Dan - Xac dinh don vi dung chung cua bang
while trim(b_dvi) is not null loop
    b_kt:=b_kt+1; a_dvi(b_kt):=b_dvi;
    b_dvi:=FHT_MA_DVI_QLY(b_dvi);
end loop;
for b_lp in REVERSE 1..b_kt loop
    b_dvi:=FKH_NV_TSO(a_dvi(b_lp),'*','*',b_bang,'K');
    if b_dvi='C' then b_kq:=a_dvi(b_lp); exit; end if;
end loop;
return b_kq;
end;
/
