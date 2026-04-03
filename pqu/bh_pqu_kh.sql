-- Quyen nhom
create or replace function FBH_PQU_NHOM_KH_SO_ID(b_nv varchar2,b_loai varchar2,b_nhom varchar2) return number
AS
    b_kq number;
begin
-- Dan
select nvl(min(so_id),0) into b_kq from bh_pqu_nhom_kh where nv=b_nv and loai=b_loai and nhom=b_nhom;
return b_kq;
end;
/
create or replace procedure FBH_PQU_NHOM_KH_GHANa(
    b_nv varchar2,b_loai varchar2,b_nhom varchar2,
    a_ma_ql out pht_type.a_var,a_ma_pqu out pht_type.a_var,a_ghan out pht_type.a_num)
AS
    b_so_id number;
begin
-- Dan
b_so_id:=FBH_PQU_NHOM_KH_SO_ID(b_nv,b_loai,b_nhom);
if b_so_id=0 then
    PKH_MANG_KD(a_ma_ql); PKH_MANG_KD(a_ma_pqu); PKH_MANG_KD_N(a_ghan);
else
    select ma_ql,ma_pqu,ghan bulk collect into a_ma_ql,a_ma_pqu,a_ghan from bh_pqu_nhom_ct where so_id=b_so_id;
end if;
end;
/
create or replace procedure PBH_PQU_NHOM_KH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nv varchar2(10); b_tu number; b_den number; b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_den using b_oraIn;
if b_nv='CH' then
    select count(*) into b_dong from bh_pqu_nhom_kh where nv='CH';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(nhomT,so_id) order by nhomT returning clob) into dt_lke from
        (select nhomT,so_id,rownum sott from bh_pqu_nhom_kh where nv='CH' order by nhomT)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pqu_nhom_kh where nv<>'CH';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(nhomT,nv,loaiT,so_id) order by nhomT,nv,loaiT returning clob) into dt_lke from
        (select nhomT,nv,loaiT,so_id,rownum sott from bh_pqu_nhom_kh where nv<>'CH' order by nhomT,nv,loaiT)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_KH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number;
    b_nv varchar2(10); b_loaiT varchar2(500); b_nhom varchar2(10); b_nhomT varchar2(500);
    b_trang number:=1; b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,loait,nhom,hangkt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_loaiT,b_nhom,b_hangKt using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_loaiT:=nvl(trim(b_loaiT),' '); b_nhom:=nvl(trim(b_nhom),' ');
if b_nhom<>' ' and b_nv<>' ' then
    select nvl(min(ten),' ') into b_nhomT from ht_ma_nhom where md='BH' and ma=b_nhom;
    if b_nv='CH' then
        select count(*) into b_dong from bh_pqu_nhom_kh where nv='CH';
        select nvl(min(sott),b_dong) into b_tu from
            (select a.*,rownum sott from bh_pqu_nhom_kh a where nv='CH' order by nhomT) where nhomT>=b_nhomT;
        PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
        select JSON_ARRAYAGG(json_object(nhomT,so_id) order by nhomT returning clob) into dt_lke from
            (select nhomT,so_id,rownum sott from bh_pqu_nhom_kh where nv='CH' order by nhomT)
            where sott between b_tu and b_den;
    else
        select count(*) into b_dong from bh_pqu_nhom_kh where nv<>'CH';
        select nvl(min(sott),b_dong) into b_tu from
            (select a.*,rownum sott from bh_pqu_nhom_kh a where nv<>'CH' order by nhomT,nv,loaiT)
            where nhomT>=b_nhomT and nv>=b_nv and loaiT>=b_loaiT;
        PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
        select JSON_ARRAYAGG(json_object(nhomT,nv,loaiT,so_id) order by nhomT,nv,loaiT returning clob) into dt_lke from
            (select nhomT,nv,loaiT,so_id,rownum sott from bh_pqu_nhom_kh where nv<>'CH' order by nhomT,nv,loaiT)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_KH_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_nv varchar2(10); b_loai varchar2(10); b_nhom varchar2(10); b_so_id number;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,loai,nhom');
EXECUTE IMMEDIATE b_lenh into b_nv,b_loai,b_nhom using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_loai:=nvl(trim(b_loai),' '); b_nhom:=nvl(trim(b_nhom),' ');
b_so_id:=FBH_PQU_NHOM_KH_SO_ID(b_nv,b_loai,b_nhom);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_KH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id'); b_nv varchar2(10);
    dt_ct clob; dt_dk clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(nv) into b_nv from bh_pqu_nhom_kh where so_id=b_so_id;
if b_nv is null then b_loi:='loi:Phan quyen da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('nhom' value nhom||'|'||nhomT,'nv' value nv,'loai' value loai) into dt_ct from bh_pqu_nhom_kh where so_id=b_so_id;
if b_nv='CH' then
    select txt into dt_dk from bh_pqu_txt where so_id=b_so_id and loai='pqu';
else
    select JSON_ARRAYAGG(json_object(ma_ql,ma_pqu,ghan,ma_qlT,ma_pquT) order by ma_ql,ma_pqu returning clob)
        into dt_dk from bh_pqu_nhom_ct where so_id=b_so_id;
end if;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_KH_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(b_so_id,0);
if b_so_id<>0 then
    delete bh_pqu_txt where so_id=b_so_id;
    delete bh_pqu_nhom_ct where so_id=b_so_id;
    delete bh_pqu_nhom_kh where so_id=b_so_id;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_KH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number; b_so_id number;
    b_nv varchar2(10); b_loai nvarchar2(10); b_nhom varchar2(10); b_nhomT nvarchar2(500); b_loaiT nvarchar2(500);
    a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
    a_ma_qlT pht_type.a_nvar; a_ma_pquT pht_type.a_nvar;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('nhom,nv,loai,loait');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv,b_loai,b_loaiT using dt_ct;
b_nv:=nvl(trim(b_nv),' '); b_loai:=nvl(trim(b_loai),' '); b_nhom:=nvl(trim(b_nhom),' ');
select min(ten) into b_nhomT from ht_ma_nhom where md='BH' and ma=b_nhom;
if b_nhomT is null then b_loi:='loi:Sai ma nhom:loi'; raise PROGRAM_ERROR; end if;
if trim(dt_dk) is null then b_loi:='loi:Chua nhap phan quyen:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PQU_NHOM_KH_SO_ID(b_nv,b_loai,b_nhom);
if b_so_id<>0 then
    delete bh_pqu_txt where so_id=b_so_id;
    delete bh_pqu_nhom_ct where so_id=b_so_id;
    delete bh_pqu_nhom_kh where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_pqu_nhom_kh values(b_so_id,b_nv,b_loai,b_nhom,b_nhomT,b_loaiT);
insert into bh_pqu_txt values(b_so_id,'dt_ct',dt_ct);
if b_nv='CH' then
    insert into bh_pqu_txt values(b_so_id,'pqu',dt_dk);
else
    b_lenh:=FKH_JS_LENH('ma_ql,ma_pqu,ghan,ma_qlt,ma_pqut');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_ql,a_ma_pqu,a_ghan,a_ma_qlt,a_ma_pqut using dt_dk;
    if a_ma_ql.count=0 then b_loi:='loi:Chua nhap phan quyen:loi'; raise PROGRAM_ERROR; end if;
    forall b_lp in 1..a_ma_ql.count
        insert into bh_pqu_nhom_ct values(b_so_id,a_ma_ql(b_lp),a_ma_pqu(b_lp),a_ghan(b_lp),a_ma_qlT(b_lp),a_ma_pquT(b_lp));
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Chung NSD
create or replace function FBH_PQU_NSD_KH_SO_ID(b_nv varchar2,b_loai varchar2,b_ma_dvi varchar2,b_nsd varchar2) return number
AS
    b_kq number;
begin
-- Dan
select nvl(min(so_id),0) into b_kq from bh_pqu_nsd_kh where nv=b_nv and loai=b_loai and ma_dvi=b_ma_dvi and nsd=b_nsd;
return b_kq;
end;
/
create or replace procedure FBH_PQU_NSD_KH_GHANa(
    b_nv varchar2,b_loai varchar2,b_ma_dvi varchar2,b_nsd varchar2,
    a_ma_ql out pht_type.a_var,a_ma_pqu out pht_type.a_var,a_ghan out pht_type.a_num)
AS
    b_so_id number;
begin
-- Dan
b_so_id:=FBH_PQU_NSD_KH_SO_ID(b_nv,b_loai,b_ma_dvi,b_nsd);
if b_so_id=0 then
    PKH_MANG_KD(a_ma_ql); PKH_MANG_KD(a_ma_pqu); PKH_MANG_KD_N(a_ghan);
else
    select ma_ql,ma_pqu,ghan bulk collect into a_ma_ql,a_ma_pqu,a_ghan from bh_pqu_nsd_ct where so_id=b_so_id;
end if;
end;
/
create or replace procedure PBH_PQU_NSD_KH_LKE(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_nv varchar2(10); b_tu number; b_den number; b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_tu,b_den using b_oraIn;
if b_nv='CH' then
    select count(*) into b_dong from bh_pqu_nsd_kh where nv='CH';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,nsdT,so_id) order by ma_dvi,nsdT returning clob) into dt_lke from
        (select ma_dvi,nsdT,so_id,rownum sott from bh_pqu_nsd_kh where nv='CH' order by ma_dvi,nsdT)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_pqu_nsd_kh where nv<>'CH';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,nsdT,nv,loaiT,so_id) order by ma_dvi,nsdT,nv,loaiT returning clob) into dt_lke from
        (select ma_dvi,nsdT,nv,loaiT,so_id,rownum sott from bh_pqu_nsd_kh where nv<>'CH' order by ma_dvi,nsdT,nv,loaiT)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_KH_MA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number;
    b_nv varchar2(10); b_loaiT varchar2(500); b_ma_dvi varchar2(10); b_nsd varchar2(20); b_nsdT varchar2(100);
    b_trang number:=1; b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,loait,ma_dvi,nsd,hangkt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_loaiT,b_ma_dvi,b_nsd,b_hangKt using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_loaiT:=nvl(trim(b_loaiT),' ');
b_ma_dvi:=nvl(trim(b_ma_dvi),' ');  b_nsd:=nvl(trim(b_nsd),' ');
if b_nv<>' ' then
    select nvl(min(ten),' ') into b_nsdT from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
    if b_nv='CH' then
        select count(*) into b_dong from bh_pqu_nsd_kh where nv='CH';
        select nvl(min(sott),b_dong) into b_tu from
            (select a.*,rownum sott from bh_pqu_nsd_kh a where nv='CH' order by ma_dvi,nsdT)
            where ma_dvi>b_ma_dvi and nsdT>=b_nsdT;
        PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
        select JSON_ARRAYAGG(json_object(ma_dvi,nsdT,so_id) order by ma_dvi,nsdT returning clob) into dt_lke from
            (select ma_dvi,nsdT,so_id,rownum sott from bh_pqu_nsd_kh where nv='CH' order by ma_dvi,nsdT)
            where sott between b_tu and b_den;
    else
        select count(*) into b_dong from bh_pqu_nsd_kh where nv<>'CH';
        select nvl(min(sott),b_dong) into b_tu from
            (select a.*,rownum sott from bh_pqu_nsd_kh a where nv<>'CH' order by ma_dvi,nsdT,nv,loaiT)
            where ma_dvi>=b_ma_dvi and nsdT>=b_nsdT and nv>=b_nv and loaiT>=b_loaiT;
        PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
        select JSON_ARRAYAGG(json_object(ma_dvi,nsdT,nv,loaiT,so_id) order by ma_dvi,nsdT,nv,loaiT returning clob) into dt_lke from
            (select ma_dvi,nsdT,nv,loaiT,so_id,rownum sott from bh_pqu_nsd_kh where nv<>'CH' order by ma_dvi,nsdT,nv,loaiT)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_KH_SO_ID(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_nv varchar2(10); b_loai varchar2(10); b_ma_dvi varchar2(10); b_nsd varchar2(20); b_so_id number;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,loai,ma_dvi,nsd');
EXECUTE IMMEDIATE b_lenh into b_nv,b_loai,b_ma_dvi,b_nsd using b_oraIn;
b_nv:=nvl(trim(b_nv),' '); b_loai:=nvl(trim(b_loai),' ');
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_nsd:=nvl(trim(b_nsd),' '); 
b_so_id:=FBH_PQU_NSD_KH_SO_ID(b_nv,b_loai,b_ma_dvi,b_nsd);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_KH_CT(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id'); b_nv varchar2(10);
	dt_ct clob; dt_dk clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(nv) into b_nv from bh_pqu_nsd_kh where so_id=b_so_id;
if b_nv is null then b_loi:='loi:Phan quyen da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object(ma_dvi,'nsd' value nsd||'|'||nsdT,'nv' value nv,'loai' value loai) into dt_ct
    from bh_pqu_nsd_kh where so_id=b_so_id;
if b_nv='CH' then
    select txt into dt_dk from bh_pqu_txt where so_id=b_so_id and loai='pqu';
else
    select JSON_ARRAYAGG(json_object(ma_ql,ma_pqu,ghan,ma_qlT,ma_pquT) order by ma_ql,ma_pqu returning clob)
        into dt_dk from bh_pqu_nsd_ct where so_id=b_so_id;
end if;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_KH_XOA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(b_so_id,0);
if b_so_id<>0 then
    delete bh_pqu_txt where so_id=b_so_id;
    delete bh_pqu_nsd_ct where so_id=b_so_id;
    delete bh_pqu_nsd_kh where so_id=b_so_id;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_KH_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number; b_so_id number;
    b_nv varchar2(10); b_loai nvarchar2(10); b_loaiT nvarchar2(500);
    b_ma_dvi varchar2(10); b_nsd varchar2(20); b_nsdT nvarchar2(100);
    a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
    a_ma_qlT pht_type.a_nvar; a_ma_pquT pht_type.a_nvar;
    dt_ct clob; dt_dk clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,loai,loait');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nsd,b_nv,b_loai,b_loaiT using dt_ct;
b_nv:=nvl(trim(b_nv),' '); b_loai:=nvl(trim(b_loai),' ');
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_nsd:=nvl(trim(b_nsd),' '); 
select min(ten) into b_nsdT from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
if b_nsdT is null then b_loi:='loi:Sai ma NSD:loi'; raise PROGRAM_ERROR; end if;
if trim(dt_dk) is null then b_loi:='loi:Chua nhap phan quyen nhom:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PQU_NSD_KH_SO_ID(b_nv,b_loai,b_ma_dvi,b_nsd);
if b_so_id<>0 then
    delete bh_pqu_txt where so_id=b_so_id;
    delete bh_pqu_nsd_ct where so_id=b_so_id;
    delete bh_pqu_nsd_kh where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_pqu_nsd_kh values(b_so_id,b_nv,b_loai,b_ma_dvi,b_nsd,b_nsdT,b_loaiT);
if b_nv='CH' then
    insert into bh_pqu_txt values(b_so_id,'pqu',dt_dk);
else
    b_lenh:=FKH_JS_LENH('ma_ql,ma_pqu,ghan,ma_qlt,ma_pqut');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_ql,a_ma_pqu,a_ghan,a_ma_qlt,a_ma_pqut using dt_dk;
    if a_ma_ql.count=0 then b_loi:='loi:Chua nhap phan quyen:loi'; raise PROGRAM_ERROR; end if;
    forall b_lp in 1..a_ma_ql.count
        insert into bh_pqu_nsd_ct values(b_so_id,a_ma_ql(b_lp),a_ma_pqu(b_lp),a_ghan(b_lp),a_ma_qlT(b_lp),a_ma_pquT(b_lp));
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--
create or replace procedure PBH_PQU_KH_MO(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000);
begin
-- Dan - Tham so mo form
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra) order by bt returning clob) into b_oraOut from bh_kh_ttt where nv='CH';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_KH_QLOI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000);
    b_nv varchar2(10); b_loai varchar2(500); b_hang varchar2(20); dt_dk clob;
begin
-- Dan - Tham so mo form
delete bh_pqu_nsd_temp_ql; delete bh_pqu_nsd_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,loai');
EXECUTE IMMEDIATE b_lenh into b_nv,b_loai using b_oraIn;
b_loai:=PKH_MA_TENl(b_loai);
if b_nv='HANG' then
    if b_loai='DGOI' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_hang_dgoi order by ma;
    elsif b_loai='LOAI' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_hang_loai order by ma;
    end if;
elsif b_nv='PHH' then
    if b_loai='MRR' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_phh_mrr order by ma;
    elsif b_loai='NHOM' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_phh_nhom order by ma;
    elsif b_loai='PVI' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_phh_pvi order by ma;
    end if;
elsif b_nv='PKT' then
    if b_loai='PVI' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_pkt_pvi order by ma;
    end if;
elsif b_nv='TAU' then
    if b_loai='NHOM' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_tau_nhom order by ma;
    end if;
elsif b_nv='XE' then
    if b_loai='MDSD' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_xe_mdsd order by ma;
    elsif b_loai='LOAI' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from bh_xe_loai order by ma;
    end if;
elsif b_nv='NG' then
    if b_loai='MA_SP' then
        insert into bh_pqu_nsd_temp_ql select ma,ten from (
        select ma,ten from bh_sk_sp union
        select ma,ten from bh_ngdl_sp union
        select ma,ten from bh_ngtd_sp ) order by ma;
    end if;
end if;
insert into bh_pqu_nsd_temp select a.ma_ql,b.ma,0,a.ma_qlT,b.ten from bh_pqu_nsd_temp_ql a, bh_pqu_ma b order by a.ma_ql,b.ma;
for r_lp in (select ma_ql,min(ma_pqu) ma_pqu from bh_pqu_nsd_temp group by ma_ql,ma_qlT) loop
    update bh_pqu_nsd_temp set ma_qlT='' where ma_ql=r_lp.ma_ql and ma_pqu<>r_lp.ma_pqu;
end loop;
select JSON_ARRAYAGG(json_object(*) order by ma_ql,ma_pqu returning clob) into b_oraOut from bh_pqu_nsd_temp;
delete bh_pqu_nsd_temp_ql; delete bh_pqu_nsd_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Kiem tra
create or replace procedure PBH_PQU_KTRA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_tien number,a_ptG pht_type.a_num,
    a_loai pht_type.a_var,a_ma pht_type.a_var,a_loi pht_type.a_var,b_loi out varchar2)
as
    b_i1 number; b_so_id number; b_tienK number; b_lenh varchar2(2000); b_txt clob;
    a_nhom pht_type.a_var; a_maK pht_type.a_var; a_tienK pht_type.a_num;
begin
-- Dan - Kiem tra gioi han ma nhom
b_loi:='loi:Loi xu ly PBH_PQU_KTRA_MA:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
for b_lp in 1..a_loai.count loop
    for b_lp2 in 1..a_nhom.count loop
        b_so_id:=FBH_PQU_NHOM_KH_SO_ID(b_nv,a_loai(b_lp),a_nhom(b_lp2));
        if b_so_id<>0 then
            for r_lp in (select ma_ql,ghan,ma_pqu from bh_pqu_nhom_ct where so_id=b_so_id) loop
              if r_lp.ma_ql=a_ma(b_lp) then --Nam: them dieu kien ma_ql=ma
                if r_lp.ma_pqu='HD_MKT' then
                  if r_lp.ghan<0 then b_loi:='loi:'||a_loi(b_lp)||' khong duoc khai thac '||a_ma(b_lp)||':loi'; return;
                  elsif r_lp.ghan<b_tien then
                      b_loi:='loi:Vuot phan cap khai thac '||a_loi(b_lp)||' ma '||a_ma(b_lp)||': '||FKH_SO_Fm(r_lp.ghan)||':loi'; return;
                  end if;
                elsif r_lp.ma_pqu='HD_MGP' then
                  if r_lp.ghan<a_ptG(b_lp) then 
                      b_loi:='loi:'||a_loi(b_lp)||' gioi han giam phi '||a_ma(b_lp)||': '||PKH_SO_CH(r_lp.ghan)||':loi'; return;
                  end if;
                end if;
              end if;
            end loop;
        end if;
    end loop;
    b_so_id:=FBH_PQU_NSD_KH_SO_ID(b_nv,a_loai(b_lp),b_ma_dvi,b_nsd);
    if b_so_id<>0 then
        for r_lp in (select ma_ql,ghan,ma_pqu from bh_pqu_nsd_ct where so_id=b_so_id) loop
          if r_lp.ma_ql=a_ma(b_lp) then --Nam: them dieu kien ma_ql=ma
            if r_lp.ma_pqu='HD_MKT' then
              if r_lp.ghan<0 then b_loi:='loi:'||a_loi(b_lp)||' khong duoc khai thac '||a_ma(b_lp)||':loi'; return;
              elsif r_lp.ghan<b_tien then
                  b_loi:='loi:Vuot phan cap khai thac '||a_loi(b_lp)||' ma '||a_ma(b_lp)||': '||FKH_SO_Fm(r_lp.ghan)||':loi'; return;
              end if;
            elsif r_lp.ma_pqu='HD_MGP' then
              if r_lp.ghan<a_ptG(b_lp) then 
                  b_loi:='loi:'||a_loi(b_lp)||' gioi han giam phi '||a_ma(b_lp)||': '||PKH_SO_CH(r_lp.ghan)||':loi'; return;
              end if;
            end if;
          end if;
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_PQU_KTRA_KH(b_ma_dvi varchar2,b_nsd varchar2,b_ma varchar2,
    a_kqN out pht_type.a_nvar,b_kqU out nvarchar2,b_loi out varchar2)
as
    b_i1 number; b_so_id number; b_lenh varchar2(2000); b_txt clob; b_kt number:=0;
    a_nhom pht_type.a_var; a_maK pht_type.a_var; a_gtri pht_type.a_nvar;
begin
-- Dan - Kiem tra phan quyen khac
b_loi:='loi:Loi xu lu PBH_PQU_KTRA_KH:loi';
PKH_MANG_KD_U(a_kqN); b_kqU:='';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
for b_lp in 1..a_nhom.count loop
    b_so_id:=FBH_PQU_NHOM_KH_SO_ID('CH','PQU',a_nhom(b_lp));
    if b_so_id<>0 then
        select txt into b_txt from bh_pqu_txt where so_id=b_so_id and loai='pqu';
        b_txt:=FKH_JS_BONH(b_txt); b_lenh:=FKH_JS_LENH('ma,nd');
        EXECUTE IMMEDIATE b_lenh bulk collect into a_maK,a_gtri using b_txt;
        for b_lp1 in 1..a_maK.count loop
            if a_maK(b_lp1)=b_ma then 
                b_kt:=b_kt+1;
                a_kqN(b_kt):=a_gtri(b_lp1); exit;
            end if;
        end loop;
    end if;
end loop;
b_so_id:=FBH_PQU_NSD_KH_SO_ID('CH','PQU',b_ma_dvi,b_nsd);
if b_so_id<>0 then
    select txt into b_txt from bh_pqu_txt where so_id=b_so_id and loai='pqu';
    b_txt:=FKH_JS_BONH(b_txt); b_lenh:=FKH_JS_LENH('ma,nd');
    EXECUTE IMMEDIATE b_lenh bulk collect into a_maK,a_gtri using b_txt;
    for b_lp1 in 1..a_maK.count loop
        if a_maK(b_lp1)=b_ma then b_kqU:=a_gtri(b_lp1); exit; end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_PQU_KTRA_KHn(
    b_ma_dvi varchar2,b_nsd varchar2,b_ma varchar2,b_gtri number,b_dk varchar2) return varchar2
as
    b_loi varchar2(1000); b_i1 number;
    a_kqN pht_type.a_nvar; b_kqU nvarchar2(500);
    a_maK pht_type.a_var; a_gtri pht_type.a_nvar;
    b_nN number; b_nU number;
begin
FBH_PQU_KTRA_KH(b_ma_dvi,b_nsd,b_ma,a_kqN,b_kqU,b_loi);
if b_loi is not null then return 'K'; end if;
if a_kqN.count=0 and b_kqU is null then return 'C'; end if;
for b_lp in 1..a_kqN.count loop
    b_nN:=PKH_LOC_CHU_SO(a_kqN(b_lp),'T');
    if (b_dk='N' and b_gtri<b_nN) or (b_dk='L' and b_gtri>b_nN) or
        (b_dk='NB' and b_gtri<=b_nN) or (b_dk='LB' and b_gtri>=b_nN) or
        (b_dk='B' and b_gtri=b_nN) then return 'C';
    end if;
end loop;
if b_kqU is not null then
    b_nU:=PKH_LOC_CHU_SO(b_kqU,'T');
    if (b_dk='N' and b_gtri<b_nU) or (b_dk='L' and b_gtri>b_nU) or
        (b_dk='NB' and b_gtri<=b_nU) or (b_dk='LB' and b_gtri>=b_nU) or
        (b_dk='B' and b_gtri=b_nU) then return 'C';
    end if;
end if;
return 'K';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_PQU_KTRA_KHs(
    b_ma_dvi varchar2,b_nsd varchar2,b_ma varchar2,b_gtri nvarchar2,b_dk varchar2) return varchar2
as
    b_kq varchar2(1):='K'; b_i1 number;
    a_kqN pht_type.a_nvar; b_kqU nvarchar2(500); b_loi varchar2(1000);
    a_maK pht_type.a_var; a_gtri pht_type.a_nvar;
begin
-- Dan - Kiem tra phan quyen khac
FBH_PQU_KTRA_KH(b_ma_dvi,b_nsd,b_ma,a_kqN,b_kqU,b_loi);
if b_loi is not null then return 'K'; end if;
if a_kqN.count=0 and b_kqU is null then return 'C'; end if;
for b_lp in 1..a_kqN.count loop
    if (b_dk='N' and b_gtri<a_kqN(b_lp)) or (b_dk='L' and b_gtri>a_kqN(b_lp)) or
        (b_dk='NB' and b_gtri<=a_kqN(b_lp)) or (b_dk='LB' and b_gtri>=a_kqN(b_lp)) or
        (b_dk='B' and b_gtri=a_kqN(b_lp)) then return 'C';
    end if;
end loop;
if (b_dk='N' and b_gtri<b_kqU) or (b_dk='L' and b_gtri>b_kqU) or
    (b_dk='NB' and b_gtri<=b_kqU) or (b_dk='LB' and b_gtri>=b_kqU) or
    (b_dk='B' and b_gtri=b_kqU) then return 'C';
end if;
return 'K';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
-- Phan quyen duyet khai thac khach hang
create or replace function FBH_PQU_KHANG_QU(
    b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ma_dviQ varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Kiem tra quyen duyet
select count(*) into b_i1 from bh_pqu_khang where ma_dvi=b_ma_dvi and nsd=b_nsd and nv in(' ',b_nv);
if b_i1<>0 then
    if b_ma_dvi<>b_ma_dviQ then
        select count(*) into b_i1 from ht_ma_dvi where ma=b_ma_dviQ and ma_ct=b_ma_dvi;
    end if;
    if b_i1<>0 then b_kq:='C'; end if;
end if;
return b_kq;
exception when others then raise PROGRAM_ERROR;
end;
/
create or replace procedure PBH_PQU_KHANG_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(2000); dt_dk clob;
begin
-- Dan - Xem chi tiet theo so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma_dvi,'nsd' value nsd||'|'||nsdT,nv,mobi,email) order by ma_dvi,nsdT,nv returning clob) into dt_dk from bh_pqu_khang;
select json_object('dt_dk' value dt_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_KHANG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    a_ma_dvi pht_type.a_var; a_nv pht_type.a_var; a_mobi pht_type.a_var; a_email pht_type.a_var; 
    a_nsd pht_type.a_var; a_nsdT pht_type.a_nvar; a_nsdN pht_type.a_nvar;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_PQU_KHANG_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,mobi,email');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_dvi,a_nsdN,a_nv,a_mobi,a_email using b_oraIn;
for b_lp in 1..a_nv.count loop
    a_nv(b_lp):=nvl(trim(a_nv(b_lp)),' '); a_ma_dvi(b_lp):=nvl(trim(a_ma_dvi(b_lp)),' ');
    a_nsdN(b_lp):=nvl(trim(a_nsdN(b_lp)),' ');
    if a_ma_dvi(b_lp) =' ' or a_nsdN(b_lp)=' ' then
        b_loi:='loi:Nhap ma don vi, NSD dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    a_nsd(b_lp):=PKH_MA_TENl(a_nsdN(b_lp)); a_nsdT(b_lp):=PKH_TEN_TENl(a_nsdN(b_lp));
end loop;
delete bh_pqu_khang;
forall b_lp in 1..a_nv.count
    insert into bh_pqu_khang values(a_ma_dvi(b_lp),a_nsd(b_lp),a_nsdT(b_lp),a_nv(b_lp),a_mobi(b_lp),a_email(b_lp));
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
