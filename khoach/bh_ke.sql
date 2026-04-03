/* Tien ich */
create or replace procedure PBH_KE_TAO_DVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kieu varchar2(1); b_phong varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_kieu:=nvl(trim(b_oraIn),' ');
if b_kieu='D' then
    select JSON_ARRAYAGG(json_object(ma,ten)) into b_oraOut from
        (select ma,lpad('-',2*(level-1),'-')||ten ten from
        (select ma,ten,ma_ct from ht_ma_dvi order by ma)
        start with ma_ct=' ' CONNECT BY prior ma=ma_ct);
elsif b_kieu='B' then
    select JSON_ARRAYAGG(json_object(ma,ten)) into b_oraOut from
        (select ma,lpad('-',2*(level-1),'-')||ten ten from
        (select ma,ten,ma_ct from ht_ma_phong where ma_dvi=b_ma_dvi order by ma)
        start with ma_ct=' ' CONNECT BY prior ma=ma_ct);
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into b_oraOut from ht_ma_nsd where ma_dvi=b_ma_dvi and phong=b_phong;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_dong number:=0; cs_lke clob:=''; b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_tu,b_den using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' then
    b_loi:='loi:Nhap don vi va nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_dong from bh_ke_dthu_ng where dviK=b_dviK and dvi=b_dvi and nv=b_nv;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay,'kenhT' value FBH_MA_KENH_TEN(kenh),khang,kenh)
    order by ngay,kenh,khang returning clob) into cs_lke from
    (select ngay,kenh,khang,row_number() over (order by ngay,kenh,khang) sott
    from bh_ke_dthu_ng where dviK=b_dviK and dvi=b_dvi and nv=b_nv order by ngay,kenh,khang)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number;
    b_txt clob:=b_oraIn; dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,kenh,khang,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap don vi, nghiep vu, ngay giao:loi'; raise PROGRAM_ERROR;
end if;
select json_object('kenh' value b_kenh,'khang' value b_khang,'ngay' value b_ngay) into dt_ct from dual;
select JSON_ARRAYAGG(json_object('ma' value FBH_KE_THU_MA_TENl(ma),
    'nhom' value FBH_KE_THU_DT_TENl(nv,nhom),'lh_nv' value FBH_MA_LHNV_TENl(lh_nv),
    goc,dong,tai,tam,bt) order by bt returning clob) into dt_dk
    from bh_ke_dthu where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number; b_nam number;
    a_ma pht_type.a_var; a_nhom pht_type.a_var; a_lh_nv pht_type.a_var; a_goc pht_type.a_num;
    a_dong pht_type.a_num; a_tai pht_type.a_num; a_tam pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,kenh,khang,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay using dt_ct;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap kieu, doi tuong duoc giao, nghiep vu, ngay giao:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('ma,nhom,lh_nv,goc,dong,tai,tam');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_nhom,a_lh_nv,a_goc,a_dong,a_tai,a_tam using dt_dk;
if a_ma.count=0 then b_loi:='loi:Nhap noi dung giao'; raise PROGRAM_ERROR; end if;
b_nam:=PKH_SO_NAM(b_ngay);
select count(*) into b_i1 from bh_ke_dthu_ng where
    dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
if b_i1<>0 then
    delete bh_ke_dthu where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
else
    insert into bh_ke_dthu_ng values(b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay);
end if;
for b_lp in 1..a_ma.count loop
    insert into bh_ke_dthu values(b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay,
        a_ma(b_lp),a_nhom(b_lp),a_lh_nv(b_lp),a_goc(b_lp),a_dong(b_lp),a_tai(b_lp),a_tam(b_lp),b_nam,b_lp);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number;
    b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,kenh,khang,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap don vi, nghiep vu, ngay giao'; raise PROGRAM_ERROR;
end if;
delete bh_ke_dthu_ng where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
if sql%rowcount<>0 then
    delete bh_ke_dthu where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_DIA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number; b_nam number;
    a_nv pht_type.a_var; a_kenh pht_type.a_var; a_khang pht_type.a_var;
    a_ma pht_type.a_var; a_nhom pht_type.a_var; a_lh_nv pht_type.a_var; a_goc pht_type.a_num;
    a_dong pht_type.a_num; a_tai pht_type.a_num; a_tam pht_type.a_num;
    a_nvX pht_type.a_var; a_kenhX pht_type.a_var; a_khangX pht_type.a_var;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('dvik,dvi,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_ngay using dt_ct;
if b_dviK not in('D','B') or b_dvi=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap don vi, ngay giao:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('nv,kenh,khang,ma,nhom,lh_nv,goc,dong,tai,tam');
EXECUTE IMMEDIATE b_lenh bulk collect into a_nv,a_kenh,a_khang,a_ma,a_nhom,a_lh_nv,a_goc,a_dong,a_tai,a_tam using dt_dk;
if a_ma.count=0 then b_loi:='loi:Nhap noi dung giao:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Sai so lieu dong:'||to_char(b_lp)||':loi';
    if a_nv(b_lp) not in('2B','XE','NG','HANG','PHH','PKT','PTN','TAU','NONG','HOP') or
        a_khang(b_lp) not in(' ','C','T') then return; end if;
    if a_kenh(b_lp)<>' ' then
        select count(*) into b_i1 from bh_ma_kenh where ma=a_kenh(b_lp);
        if b_i1=0 then return; end if;
    end if;
    select count(*) into b_i1 from bh_ke_thu_ma where ma=a_ma(b_lp);
    if b_i1=0 then return; end if;
    if a_nhom(b_lp)<>' ' then
        select count(*) into b_i1 from bh_ke_thu_dt where nv=a_nv(b_lp) and ma=a_nhom(b_lp);
        if b_i1=0 then return; end if;
    end if;    
    if a_lh_nv(b_lp)<>' ' then
        select count(*) into b_i1 from bh_ma_lhnv where ma=a_lh_nv(b_lp);
        if b_i1=0 then return; end if;
    end if;    
end loop;
a_nvX(1):=a_nv(1); a_kenhX(1):=a_kenh(1); a_khangX(1):=a_khang(1);
for b_lp in 2..a_ma.count loop
    b_i1:=0;
    for b_lp1 in 1..a_nvX.count loop
        if a_nvX(b_lp1)=a_nv(b_lp) and a_kenhX(b_lp1)=a_kenh(b_lp) and a_khangX(b_lp1)=a_khang(b_lp) then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_i1:=a_nvX.count+1;
        a_nvX(b_i1):=a_nv(b_lp); a_kenhX(b_i1):=a_kenh(b_lp); a_khangX(b_i1):=a_khang(b_lp);
    end if;
end loop;
b_nam:=PKH_SO_NAM(b_ngay);
for b_lp in 1..a_nvX.count loop
    select count(*) into b_i1 from bh_ke_dthu_ng where
        dviK=b_dviK and dvi=b_dvi and nv=a_nvX(b_lp) and kenh=a_kenhX(b_lp) and khang=a_khangX(b_lp) and ngay=b_ngay;
    if b_i1<>0 then
        delete bh_ke_dthu where dviK=b_dviK and dvi=b_dvi and nv=a_nvX(b_lp) and
            kenh=a_kenhX(b_lp) and khang=a_khangX(b_lp) and ngay=b_ngay;
    else
        insert into bh_ke_dthu_ng values(b_dviK,b_dvi,a_nvX(b_lp),a_kenhX(b_lp),a_khangX(b_lp),b_ngay);
    end if;
end loop;
for b_lp in 1..a_ma.count loop
    insert into bh_ke_dthu values(b_dviK,b_dvi,a_nv(b_lp),a_kenh(b_lp),a_khang(b_lp),b_ngay,
        a_ma(b_lp),a_nhom(b_lp),a_lh_nv(b_lp),a_goc(b_lp),a_dong(b_lp),a_tai(b_lp),a_tam(b_lp),b_nam,b_lp);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_KE_DTHU_TRSO(
    b_dviK varchar2,b_dvi varchar2,b_nam number,b_ma varchar2) return number
AS
    b_kq number;
begin
-- Dan
select nvl(min(trso),0) into b_kq from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_KE_DTHU_TRSO_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dviK varchar2(1); b_dvi varchar2(10); b_nam number;
    b_dong number:=0; cs_lke clob:=''; b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nam,tu,den');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nam,b_tu,b_den using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nam=0 then
    b_loi:='loi:Nhap don vi va nam ke hoach:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_dong from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,'ten' value FBH_KE_THU_MA_TEN(ma),trso)
    order by ma returning clob) into cs_lke from
    (select ma,trso,row_number() over (order by ma) sott
    from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam order by ma)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_TRSO_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangkt number;
    b_dviK varchar2(1); b_dvi varchar2(10); b_nam number; b_ma varchar2(20);
    b_trang number:=0; b_dong number:=0; cs_lke clob:=''; b_txt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_txt:=trim(b_oraIn); FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nam,ma,trangkt');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nam,b_ma,b_hangkt using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nam=0 then
    b_loi:='loi:Nhap don vi va nam ke hoach'; raise PROGRAM_ERROR;
end if;
select count(*) into b_dong from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam;
select nvl(min(sott),0) into b_tu from 
    (select ma,trso,row_number() over (order by ma) sott
    from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam order by ma)
    where ma=b_ma;
if b_tu=0 then
    select nvl(min(sott),0) into b_tu from 
        (select ma,trso,row_number() over (order by ma) sott
        from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam order by ma)
        where ma>b_ma;
end if;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(ma,'ten' value FBH_KE_THU_MA_TEN(ma),trso)
    order by ma returning clob) into cs_lke from
    (select ma,trso,row_number() over (order by ma) sott
    from bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam order by ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_TRSO_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nam number; b_ma varchar2(20); b_trso number;
    b_txt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_txt:=trim(b_oraIn); FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nam,ma');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nam,b_ma using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nam=0 or b_ma=' ' then
    b_loi:='loi:Nhap don vi, nam ke hoach, ma ke hoach:loi'; raise PROGRAM_ERROR;
end if;
b_trso:=FBH_KE_DTHU_TRSO(b_dviK,b_dvi,b_nam,b_ma);
select json_object('trso' value b_trso) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_TRSO_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nam number; b_ma varchar2(20); b_trso number;
    b_txt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_txt:=trim(b_oraIn); FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nam,ma,trso');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nam,b_ma,b_trso using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nam=0 or b_ma=' ' or b_trso<0 then
    b_loi:='loi:Nhap don vi, nam ke hoach, ma ke hoach, trong so:loi'; raise PROGRAM_ERROR;
end if;
if FBH_KE_THU_MA_HAN(b_ma)<>'C' then b_loi:='loi:Sai ma ke hoach:loi'; raise PROGRAM_ERROR; end if;
delete bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam and ma=b_ma;
insert into bh_ke_dthu_trso values(b_dviK,b_dvi,b_nam,b_ma,b_trso);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_TRSO_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nam number; b_ma varchar2(20);
    b_txt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_txt:=trim(b_oraIn); FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nam,ma');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nam,b_ma using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nam=0 or b_ma=' ' then
    b_loi:='loi:Nhap don vi, nam ke hoach, ma ke hoach:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_DTHU_TRSO_DIA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nam number;
    a_ma pht_type.a_var; a_trso pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('dvik,dvi,nam');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nam using dt_ct;
if b_dviK not in('D','B') or b_dvi=' ' or b_nam=0 then
    b_loi:='loi:Nhap don vi, nam ke hoach giao:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('ma,trso');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_trso using dt_dk;
if a_ma.count=0 then b_loi:='loi:Nhap trong so:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    if FBH_KE_THU_MA_HAN(a_ma(b_lp))<>'C' or a_trso(b_lp)<0 then
        b_loi:='loi:Loi so lieu dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
end loop;
delete bh_ke_dthu_trso where dviK=b_dviK and dvi in(' ',b_dvi) and nam=b_nam;
forall b_lp in 1..a_ma.count
    insert into bh_ke_dthu_trso values(b_dviK,b_dvi,b_nam,a_ma(b_lp),a_trso(b_lp));
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Giao co che
create or replace procedure PBH_KE_CHE_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_dong number:=0; cs_lke clob:=''; b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_tu,b_den using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' then
    b_loi:='loi:Nhap don vi va nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_dong from bh_ke_che_ng where dviK=b_dviK and dvi=b_dvi and nv=b_nv;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay,'kenhT' value FBH_MA_KENH_TEN(kenh),khang,kenh)
    order by ngay,kenh,khang returning clob) into cs_lke from
    (select ngay,kenh,khang,row_number() over (order by ngay,kenh,khang) sott
    from bh_ke_che_ng where dviK=b_dviK and dvi=b_dvi and nv=b_nv order by ngay,kenh,khang)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHE_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number;
    b_txt clob:=b_oraIn; dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,kenh,khang,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap don vi, nghiep vu, ngay giao:loi'; raise PROGRAM_ERROR;
end if;
select json_object('kenh' value b_kenh,'khang' value b_khang,'ngay' value b_ngay) into dt_ct from dual;
select JSON_ARRAYAGG(json_object('ma' value FBH_KE_CHI_MA_TENl(ma),
    'nhom' value FBH_KE_THU_DT_TENl(nv,nhom),'lh_nv' value FBH_MA_LHNV_TENl(lh_nv),
    goc,dong,tai,tam,bt) order by bt returning clob) into dt_dk
    from bh_ke_che where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
select json_object('dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHE_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number; b_nam number;
    a_ma pht_type.a_var; a_nhom pht_type.a_var; a_lh_nv pht_type.a_var; a_goc pht_type.a_num;
    a_dong pht_type.a_num; a_tai pht_type.a_num; a_tam pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,kenh,khang,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay using dt_ct;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap kieu, doi tuong duoc giao, nghiep vu, ngay giao:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('ma,nhom,lh_nv,goc,dong,tai,tam');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_nhom,a_lh_nv,a_goc,a_dong,a_tai,a_tam using dt_dk;
if a_ma.count=0 then b_loi:='loi:Nhap noi dung giao'; raise PROGRAM_ERROR; end if;
b_nam:=PKH_SO_NAM(b_ngay);
select count(*) into b_i1 from bh_ke_che_ng where
    dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
if b_i1<>0 then
    delete bh_ke_che where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
else
    insert into bh_ke_che_ng values(b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay);
end if;
for b_lp in 1..a_ma.count loop
    insert into bh_ke_che values(b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay,
        a_ma(b_lp),a_nhom(b_lp),a_lh_nv(b_lp),a_goc(b_lp),a_dong(b_lp),a_tai(b_lp),a_tam(b_lp),b_nam,b_lp);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHE_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number;
    b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('dvik,dvi,nv,kenh,khang,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_nv,b_kenh,b_khang,b_ngay using b_txt;
if b_dviK=' ' or b_dvi=' ' or b_nv=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap don vi, nghiep vu, ngay giao'; raise PROGRAM_ERROR;
end if;
delete bh_ke_che_ng where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
if sql%rowcount<>0 then
    delete bh_ke_che where dviK=b_dviK and dvi=b_dvi and nv=b_nv and kenh=b_kenh and khang=b_khang and ngay=b_ngay;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KE_CHE_DIA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_dviK varchar2(1); b_dvi varchar2(10); b_nv varchar2(10);
    b_kenh varchar2(10); b_khang varchar2(10); b_ngay number; b_nam number;
    a_nv pht_type.a_var; a_kenh pht_type.a_var; a_khang pht_type.a_var;
    a_ma pht_type.a_var; a_nhom pht_type.a_var; a_lh_nv pht_type.a_var; a_goc pht_type.a_num;
    a_dong pht_type.a_num; a_tai pht_type.a_num; a_tam pht_type.a_num;
    a_nvX pht_type.a_var; a_kenhX pht_type.a_var; a_khangX pht_type.a_var;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('dvik,dvi,ngay');
EXECUTE IMMEDIATE b_lenh into b_dviK,b_dvi,b_ngay using dt_ct;
if b_dviK not in('D','B') or b_dvi=' ' or b_ngay in(0,30000101) then
    b_loi:='loi:Nhap don vi, ngay giao:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('nv,kenh,khang,ma,nhom,lh_nv,goc,dong,tai,tam');
EXECUTE IMMEDIATE b_lenh bulk collect into a_nv,a_kenh,a_khang,a_ma,a_nhom,a_lh_nv,a_goc,a_dong,a_tai,a_tam using dt_dk;
if a_ma.count=0 then b_loi:='loi:Nhap noi dung giao:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Sai so lieu dong:'||to_char(b_lp)||':loi';
    if a_nv(b_lp) not in('2B','XE','NG','HANG','PHH','PKT','PTN','TAU','NONG','HOP') or
        a_khang(b_lp) not in(' ','C','T') then return; end if;
    if a_kenh(b_lp)<>' ' then
        select count(*) into b_i1 from bh_ma_kenh where ma=a_kenh(b_lp);
        if b_i1=0 then return; end if;
    end if;
    select count(*) into b_i1 from bh_ke_thu_ma where ma=a_ma(b_lp);
    if b_i1=0 then return; end if;
    if a_nhom(b_lp)<>' ' then
        select count(*) into b_i1 from bh_ke_thu_dt where nv=a_nv(b_lp) and ma=a_nhom(b_lp);
        if b_i1=0 then return; end if;
    end if;    
    if a_lh_nv(b_lp)<>' ' then
        select count(*) into b_i1 from bh_ma_lhnv where ma=a_lh_nv(b_lp);
        if b_i1=0 then return; end if;
    end if;    
end loop;
a_nvX(1):=a_nv(1); a_kenhX(1):=a_kenh(1); a_khangX(1):=a_khang(1);
for b_lp in 2..a_ma.count loop
    b_i1:=0;
    for b_lp1 in 1..a_nvX.count loop
        if a_nvX(b_lp1)=a_nv(b_lp) and a_kenhX(b_lp1)=a_kenh(b_lp) and a_khangX(b_lp1)=a_khang(b_lp) then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_i1:=a_nvX.count+1;
        a_nvX(b_i1):=a_nv(b_lp); a_kenhX(b_i1):=a_kenh(b_lp); a_khangX(b_i1):=a_khang(b_lp);
    end if;
end loop;
b_nam:=PKH_SO_NAM(b_ngay);
for b_lp in 1..a_nvX.count loop
    select count(*) into b_i1 from bh_ke_che_ng where
        dviK=b_dviK and dvi=b_dvi and nv=a_nvX(b_lp) and kenh=a_kenhX(b_lp) and khang=a_khangX(b_lp) and ngay=b_ngay;
    if b_i1<>0 then
        delete bh_ke_che where dviK=b_dviK and dvi=b_dvi and nv=a_nvX(b_lp) and
            kenh=a_kenhX(b_lp) and khang=a_khangX(b_lp) and ngay=b_ngay;
    else
        insert into bh_ke_che_ng values(b_dviK,b_dvi,a_nvX(b_lp),a_kenhX(b_lp),a_khangX(b_lp),b_ngay);
    end if;
end loop;
for b_lp in 1..a_ma.count loop
    insert into bh_ke_che values(b_dviK,b_dvi,a_nv(b_lp),a_kenh(b_lp),a_khang(b_lp),b_ngay,
        a_ma(b_lp),a_nhom(b_lp),a_lh_nv(b_lp),a_goc(b_lp),a_dong(b_lp),a_tai(b_lp),a_tam(b_lp),b_nam,b_lp);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
