-- nam
create or replace function FBH_MA_NV_DUNG(
    b_2b varchar2,b_xe varchar2,b_hang varchar2,b_phh varchar2,
    b_pkt varchar2,b_ptn varchar2,b_nguoi varchar2,b_tau varchar2,
    b_hop varchar2,b_nong varchar2) return varchar2
AS
    b_nv varchar2(100);
begin
-- Dan - Tra nv
if b_2b='C' then b_nv:='2B'; end if;
if b_xe='C' then PKH_GHEP(b_nv,'XE'); end if;
if b_hang='C' then PKH_GHEP(b_nv,'HANG'); end if;
if b_phh='C' then PKH_GHEP(b_nv,'PHH'); end if;
if b_pkt='C' then PKH_GHEP(b_nv,'PKT'); end if;
if b_ptn='C' then PKH_GHEP(b_nv,'PTN'); end if;
if b_nguoi='C' then PKH_GHEP(b_nv,'NG'); end if;
if b_tau='C' then PKH_GHEP(b_nv,'TAU'); end if;
if b_hop='C' then PKH_GHEP(b_nv,'HOP'); end if;
if b_nong='C' then PKH_GHEP(b_nv,'NONG'); end if;
b_nv:=nvl(trim(b_nv),' ');
return b_nv;
end;
/
create or replace function FBH_MA_NV_CO(b_nv varchar2,b_tim varchar2,b_dk varchar2:='K') return varchar2
AS
    b_kq varchar2(1):='K'; a_nv pht_type.a_var; a_tim pht_type.a_var;
begin
-- Dan - Tra co nghiep vu
if b_tim=' ' or (b_nv=' ' and b_dk='C') then
    b_kq:='C';
else
    PKH_CH_ARR(b_nv,a_nv); PKH_CH_ARR(b_tim,a_tim);
    for b_lp1 in 1..a_tim.count loop
        b_kq:=FKH_ARR_TIM(a_nv,a_tim(b_lp1));
        if b_kq='K' then exit; end if;
    end loop;
end if;
return b_kq;
end;
/
create or replace function FBH_MA_NV_BAO(b_nvB varchar2,b_nv varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; a_nv pht_type.a_var;
begin
-- Dan - Tra bao nghiep vu
if b_nvB<>'*' then
    PKH_CH_ARR(b_nv,a_nv);
    for b_lp in 1..a_nv.count loop
        if instr(b_nvB,a_nv(b_lp))<=0 then b_kq:='K'; exit; end if;
    end loop;
end if;
return b_kq;
end;
/
/*** Ma bo tai chinh ***/
create or replace function FBH_MA_LHNV_BO_T_SUAT(b_ma varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra ten
select nvl(min(t_suat),0) into b_kq from bh_ma_lhnv_bo where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_BO_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_ma_lhnv_bo where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_BO_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_ma_lhnv_bo where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_LHNV_BO_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_ma_lhnv_bo where tc='C' and ngay_bd<=b_ngay and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_BO_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv_bo;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv_bo order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv_bo where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv_bo a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_BO_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv_bo;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ma_lhnv_bo order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ma_lhnv_bo order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv_bo order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv_bo where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_lhnv_bo where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv_bo a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_BO_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; cs_dk clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_lhnv_bo where ma=b_ma;
if b_i1<>0 then 
    select json_object(ma,txt) into cs_ct from bh_ma_lhnv_bo where ma=b_ma;
    select JSON_ARRAYAGG(json_object(ma,ngay_bd,t_suat,pt_nop,pt_thau) order by ngay_bd desc returning clob) into cs_dk from bh_ma_lhnv_boL where ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct,'cs_dk' value cs_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_BO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10);
    b_ngay_bd number; b_ngay_kt number; b_t_suat number; b_pt_nop number; b_pt_thau number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ngay_bd,ngay_kt,t_suat,pt_nop,pt_thau');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ngay_bd,b_ngay_kt,b_t_suat,b_pt_nop,b_pt_thau using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_tc) is null or b_tc not in ('T','C') then b_loi:='loi:Sai tinh chat:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ma_lhnv_bo where ma=b_ma_ct and tc='T';
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
if b_tc='C' then
    delete bh_ma_lhnv_boL where ma=b_ma and ngay_bd=b_ngay_bd;
    insert into bh_ma_lhnv_boL select ma,ngay_bd,t_suat,pt_nop,pt_thau
        from bh_ma_lhnv_bo where ma=b_ma and ngay_bd<>b_ngay_bd;
end if;
delete bh_ma_lhnv_bo where ma=b_ma;
insert into bh_ma_lhnv_bo values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_t_suat,b_pt_nop,b_pt_thau,b_ngay_bd,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_BO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_lhnv_bo where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_lhnv_boL where ma=b_ma;
delete bh_ma_lhnv_bo where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** lhnv Tai ***/
create or replace function FBH_MA_LHNV_TA_BO(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra ma lh_nv BTC tuong ung
select min(ma_cd) into b_kq from bh_ma_lhnv_tai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TAI_NV(b_ma varchar2,b_nv varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra nghiep vu tai cho line nghiep vu
if b_ma<>' ' then
    select count(*) into b_i1 from bh_ma_lhnv_tai where ma=b_ma and FBH_MA_NV_CO(nv,b_nv)='C';
    if b_i1<>0 then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TAI_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_ma_lhnv_tai where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TAI_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
b_kq:=FBH_MA_LHNV_TAI_TEN(b_ma);
if b_kq is not null then b_kq:=b_ma||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TAI_TENf(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
b_kq:=FBH_MA_LHNV_TAI_TEN(b_ma);
if b_kq is not null then b_kq:=b_ma||'|'||b_ma||' - '||b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TAI_TENe(b_ma varchar2) return varchar2
AS
    b_kq varchar2(200);
begin
-- Dan - Ten tieng Anh
select min(FKH_JS_GTRIs(txt,'tenE')) into b_kq from bh_ma_lhnv_tai where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TAI_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ma_lhnv_tai where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_TENj(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_oraInX clob:=b_oraIn;
begin
-- Dan - Tim ten
PKH_JS_THAY(b_oraInX,'ktra','bh_ma_lhnv_tai,ma,ten');
PKH_HOI_TENj(b_ma_dvi,b_nsd,b_pas,b_oraInX,b_oraOut);
end;
/
create or replace procedure PBH_MA_LHNV_TAIj(
    b_oraIn clob,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_gtri varchar2(2000); b_ten nvarchar2(100); b_min nvarchar2(100); b_xep varchar2(50);
    b_ktra varchar2(10); b_trangKt number; b_tc varchar2(1); b_cK varchar2(200):=' ';
    a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong
b_lenh:=FKH_JS_LENH('ktra,gtri,trangKt,tc,xep');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_gtri,b_trangKt,b_tc,b_xep using b_oraIn;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):='bh_ma_lhnv_tai'; a_ch(2):='ma'; a_ch(3):='ten';
if nvl(trim(b_xep),'1')='M' then b_xep:=a_ch(2); else b_xep:=a_ch(3); end if;
if trim(b_ktra) is not null then
    b_cK:='FBH_MA_NV_CO(nv,'||CHR(39)||b_ktra||CHR(39)||')='||CHR(39)||'C'||CHR(39);
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
if trim(b_gtri) is null then
    b_lenh:='select count(*) from '||a_ch(1);
    if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
    execute immediate b_lenh into b_dong;
    if b_dong between 2 and b_trangKt then
        b_lenh:='insert into bh_kh_hoi_temp select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum from '||a_ch(1);
        if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
         b_lenh:=b_lenh||' order by '||b_xep;
        execute immediate b_lenh;
    end if;
else
    b_ten:='%'||b_gtri||'%'; b_gtri:=upper(b_gtri);
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where '||a_ch(2)||' >= :ma or upper('||a_ch(3)||') like :ten';
    if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
    execute immediate b_lenh into b_dong,b_min using b_gtri,b_ten;
    if not(b_dong>b_trangKt or (b_dong=1 and upper(b_min)=b_gtri)) then
        b_lenh:='insert into bh_kh_hoi_temp select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum from '||a_ch(1)||' where '||
            a_ch(2)||' >= :ma or upper('||a_ch(3)||') like :ten';
        if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
        b_lenh:=b_lenh||' order by '||b_xep;
        execute immediate b_lenh using b_gtri,b_ten;
    end if;
end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_MAj(
    b_oraIn clob,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate); b_xep varchar2(50);
    b_tu number:=1; b_den number; b_trang number; b_tc varchar2(1); b_cK varchar2(200):=' ';
    b_ktra varchar2(200); b_gtri varchar2(2000); b_ten nvarchar2(500); b_trangkt number;
    a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('ktra,gtri,trangKt,tc,xep');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_gtri,b_trangKt,b_tc,b_xep using b_oraIn;
if b_gtri is null then b_loi:='loi:Nhap ma:loi'; return; end if;
a_ch(1):='bh_ma_lhnv_tai'; a_ch(2):='ma'; a_ch(3):='ten';
if nvl(trim(b_xep),'1')='M' then b_xep:=a_ch(2); else b_xep:=a_ch(3); end if;
if trim(b_ktra) is not null then
    b_cK:='FBH_MA_NV_CO(nv,'||CHR(39)||b_ktra||CHR(39)||')='||CHR(39)||'C'||CHR(39);
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
b_ten:='%'||b_gtri||'%';
b_lenh:='select count(*) from '||a_ch(1)||' where '||a_ch(2)||' >= :ma or upper('||a_ch(3)||') like :ten';
if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
execute immediate b_lenh into b_dong using b_gtri,b_ten;
if b_dong<>0 then
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='insert into bh_kh_hoi_temp select ma,ten,rownum from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||') sott from '||a_ch(1);
    if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
    b_lenh:=b_lenh||' order by '||b_xep||') where ma >= :ma or upper(ten) like :ten and sott between :tu and :den';
    execute immediate b_lenh using b_gtri,b_ten,b_tu,b_den;
end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_SLj(
    b_oraIn clob,b_tu out number,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate); b_xep varchar2(50);
    a_ch pht_type.a_var; b_den number; b_ktra varchar2(200);
    b_ng varchar2(1); b_tc varchar2(1); b_cK varchar2(200):=' ';
begin
-- Dan - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('ktra,tu,den,tc,xep');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_tu,b_den,b_tc,b_xep using b_oraIn;
a_ch(1):='bh_ma_lhnv_tai'; a_ch(2):='ma'; a_ch(3):='ten';
if nvl(trim(b_xep),'1')='M' then b_xep:=a_ch(2); else b_xep:=a_ch(3); end if;
if trim(b_ktra) is not null then
    b_cK:='FBH_MA_NV_CO(nv,'||CHR(39)||b_ktra||CHR(39)||')='||CHR(39)||'C'||CHR(39);
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
b_lenh:='select count(*) from '||a_ch(1);
if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
execute immediate b_lenh into b_dong;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
b_lenh:='insert into bh_kh_hoi_temp select ma,ten,rownum from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||b_xep||') sott from '||a_ch(1);
if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
b_lenh:=b_lenh||' order by '||b_xep||') where sott between :tu and :den';
execute immediate b_lenh using b_tu,b_den;
b_loi:='';
end;
/
create or replace procedure PBH_MA_LHNV_TAI_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri varchar2(2000);
    b_kieu varchar2(1); b_dong number:=0; b_tu number:=1; cs_lke clob:='';
begin
-- Dan - Liet ke dong
delete bh_kh_hoi_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_oraIn) is null then
    select json_object('kieu' value 'C','dong' value 0,'tu' value 1,'cs_lke' value '') into b_oraOut from dual;
    return;
end if;
b_lenh:=FKH_JS_LENH('kieu,gtri');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri using b_oraIn;
if nvl(trim(b_kieu),' ')<>'C' then
    PBH_MA_LHNV_TAIj(b_oraIn,b_dong,b_loi);
elsif trim(b_gtri) is not null then
    PBH_MA_LHNV_TAI_MAj(b_oraIn,b_dong,b_loi);
else
    PBH_MA_LHNV_TAI_SLj(b_oraIn,b_tu,b_dong,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,'ten' value ma||' - '||ten) order by bt returning clob) into cs_lke from bh_kh_hoi_temp;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_kh_hoi_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_ma_lhnv_tai a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv_tai;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv_tai order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv_tai where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv_tai a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv_tai;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ma_lhnv_tai order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ma_lhnv_tai order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv_tai order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv_tai where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_lhnv_tai where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv_tai a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(json_object(ma,txt)) into cs_ct from bh_ma_lhnv_tai where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_ma_ct varchar2(10); b_ma_cd varchar2(10); b_ngay_kt number;
    b_nv varchar2(100):=' '; b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1); b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,ma_cd,ngay_kt,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_ma_cd,b_ngay_kt,
    b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_tc) is null or b_tc not in ('T','C') then b_loi:='loi:Sai tc:loi'; raise PROGRAM_ERROR; end if;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ma_lhnv_tai where ma=b_ma_ct and tc<>'C';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_lhnv_tai where ma=b_ma;
insert into bh_ma_lhnv_tai values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_ma_cd,b_ngay_kt,b_nv,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_TAI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_lhnv_tai where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_lhnv_tai where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** lhnv ***/
create or replace function FBH_MA_LHNV_TAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra ma lh_nv tai tuong ung
select min(ma_tai) into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_BB(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra loai B-Bat buoc, T-Tu nguyen
select nvl(min(bb),'T') into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_LHNV(b_ma varchar2,b_bb varchar2,b_loai varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Kiem tra loai lh_nv
select count(*) into b_i1 from bh_ma_lhnv where ma=b_ma and bb=b_bb and loai=b_loai;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_UU(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - Xac dinh uu tien
if FBH_MA_LHNV_BB(b_ma)='B' then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_BO(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra ma lh_nv BTC tuong ung
select min(ma_cd) into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_MA_LHNV_NOP(
    b_ma varchar2,b_pt_nop out number,b_pt_thau out number,b_dk varchar2:='T')
AS
    b_ma_cd varchar2(10);
begin
-- Dan - Tra % nop trich truoc, thue nha thau
if trim(b_ma) is null then
	select nvl(max(pt_nop),0),nvl(max(pt_thau),0) into b_pt_nop,b_pt_thau from bh_ma_lhnv_bo;
else
    if b_dk='G' then b_ma_cd:=FBH_MA_LHNV_BO(b_ma); else b_ma_cd:=FBH_MA_LHNV_TA_BO(b_ma); end if;
	if b_ma_cd is null then
		b_pt_nop:=0; b_pt_thau:=0;
	else
		select nvl(min(pt_nop),0),nvl(min(pt_thau),0) into b_pt_nop,b_pt_thau from bh_ma_lhnv_bo where ma=b_ma_cd;
	end if;
end if;
end;
/
CREATE OR REPLACE function FBH_MA_LHNV_THUE(b_ma varchar2) return number
AS
    b_kq number; b_ma_cd varchar2(10);
begin
-- Dan - Tra thue
b_ma_cd:=FBH_MA_LHNV_BO(b_ma);
select nvl(min(t_suat),0) into b_kq from bh_ma_lhnv_bo where ma=b_ma_cd;
return b_kq;
end;
/
create or replace procedure FBH_MA_LHNV_HHONG(
    b_ma varchar2,b_nv varchar2,b_ngay number,b_hhong out number,b_htro out number,b_dvu out number)
AS
    b_ngayM number;
begin
-- Dan - Tra ty le hoa hong
select nvl(max(ngay_bd),0) into b_ngayM from bh_ma_lhnv where ma=b_ma and instr(nv,b_nv)>0 and b_ngay between ngay_bd and ngay_kt;
if b_ngayM=0 then
    b_hhong:=0; b_htro:=0; b_dvu:=0;
else
    select nvl(max(hhong),0),nvl(max(htro),0),nvl(max(dvu),0) into b_hhong,b_htro,b_dvu
        from bh_ma_lhnv_thue where ma=b_ma and ngay_bd=b_ngayM;
end if;
end;
/
create or replace function FBH_MA_LHNV_LOAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra loai bao hiem V,N,TV,TN
select min(loai) into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_NV(b_ma varchar2) return varchar2
AS
    b_kq varchar2(100);
begin
-- Dan - Tra nghiep vu XE,NGUOI,...
select min(nv) into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con han dung
select count(*) into b_i1 from bh_ma_lhnv where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_ma_lhnv where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Tra ten
b_kq:=FBH_MA_LHNV_TEN(b_ma);
if b_kq is not null then b_kq:=b_ma||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_MA_LHNV_TENf(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
b_kq:=FBH_MA_LHNV_TEN(b_ma);
if b_kq is not null then b_kq:=b_ma||'|'||b_ma||' - '||b_kq; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_LHNV_TENj(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_oraInX clob:=b_oraIn;
begin
-- Dan - Tim ten
PKH_JS_THAY(b_oraInX,'ktra','bh_ma_lhnv,ma,ten');
PKH_HOI_TENj(b_ma_dvi,b_nsd,b_pas,b_oraInX,b_oraOut);
end;
/
create or replace procedure PBH_MA_LHNVj(
    b_oraIn clob,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_gtri varchar2(50); b_ten nvarchar2(100); b_min nvarchar2(100); b_xep varchar2(50);
    b_ktra varchar2(10); b_trangKt number; b_tc varchar2(1); b_cK varchar2(200):=' ';
    a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong
b_lenh:=FKH_JS_LENH('ktra,gtri,trangKt,tc,xep');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_gtri,b_trangKt,b_tc,b_xep using b_oraIn;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):='bh_ma_lhnv'; a_ch(2):='ma'; a_ch(3):='ten';
if nvl(trim(b_xep),'1')='M' then b_xep:=a_ch(2); else b_xep:=a_ch(3); end if;
if trim(b_ktra) is not null then
    b_cK:='FBH_MA_NV_CO(nv,'||CHR(39)||b_ktra||CHR(39)||')='||CHR(39)||'C'||CHR(39);
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
if trim(b_gtri) is null then
    b_lenh:='select count(*) from '||a_ch(1);
    if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
    execute immediate b_lenh into b_dong;
    if b_dong between 2 and b_trangKt then
        b_lenh:='insert into bh_kh_hoi_temp select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum from '||a_ch(1);
        if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
         b_lenh:=b_lenh||' order by '||b_xep;
        execute immediate b_lenh;
    end if;
else
    b_ten:='%'||b_gtri||'%'; b_gtri:=upper(b_gtri);
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where '||a_ch(2)||' >= :ma or upper('||a_ch(3)||') like :ten';
    if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
    execute immediate b_lenh into b_dong,b_min using b_gtri,b_ten;
    if not(b_dong>b_trangKt or (b_dong=1 and upper(b_min)=b_gtri)) then
        b_lenh:='insert into bh_kh_hoi_temp select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum from '||a_ch(1)||' where '||
            a_ch(2)||' >= :ma or upper('||a_ch(3)||') like :ten';
        if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
        b_lenh:=b_lenh||' order by '||b_xep;
        execute immediate b_lenh using b_gtri,b_ten;
    end if;
end if;
end;
/
create or replace procedure PBH_MA_LHNV_MAj(
    b_oraIn clob,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate); b_xep varchar2(50);
    b_tu number:=1; b_den number; b_trang number; b_tc varchar2(1); b_cK varchar2(200):=' ';
    b_ktra varchar2(200); b_gtri varchar2(30); b_ten nvarchar2(500); b_trangkt number;
    a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('ktra,gtri,trangKt,tc,xep');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_gtri,b_trangKt,b_tc,b_xep using b_oraIn;
if b_gtri is null then b_loi:='loi:Nhap ma:loi'; return; end if;
a_ch(1):='bh_ma_lhnv'; a_ch(2):='ma'; a_ch(3):='ten';
if nvl(trim(b_xep),'1')='M' then b_xep:=a_ch(2); else b_xep:=a_ch(3); end if;
if trim(b_ktra) is not null then
    b_cK:='FBH_MA_NV_CO(nv,'||CHR(39)||b_ktra||CHR(39)||')='||CHR(39)||'C'||CHR(39);
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
b_ten:='%'||b_gtri||'%';
b_lenh:='select count(*) from '||a_ch(1)||' where '||a_ch(2)||' >= :ma or upper('||a_ch(3)||') like :ten';
if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
execute immediate b_lenh into b_dong using b_gtri,b_ten;
if b_dong<>0 then
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='insert into bh_kh_hoi_temp select ma,ten,rownum from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||') sott from '||a_ch(1);
    if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
    b_lenh:=b_lenh||' order by '||b_xep||') where ma >= :ma or upper(ten) like :ten and sott between :tu and :den';
    execute immediate b_lenh using b_gtri,b_ten,b_tu,b_den;
end if;
end;
/
create or replace procedure PBH_MA_LHNV_SLj(
    b_oraIn clob,b_tu out number,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate); b_xep varchar2(50);
    a_ch pht_type.a_var; b_den number; b_ktra varchar2(200);
    b_ng varchar2(1); b_tc varchar2(1); b_cK varchar2(200):=' ';
begin
-- Dan - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('ktra,tu,den,tc,xep');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_tu,b_den,b_tc,b_xep using b_oraIn;
a_ch(1):='bh_ma_lhnv'; a_ch(2):='ma'; a_ch(3):='ten';
if nvl(trim(b_xep),'1')='M' then b_xep:=a_ch(2); else b_xep:=a_ch(3); end if;
if trim(b_ktra) is not null then
    b_cK:='FBH_MA_NV_CO(nv,'||CHR(39)||b_ktra||CHR(39)||')='||CHR(39)||'C'||CHR(39);
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
b_lenh:='select count(*) from '||a_ch(1);
if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
execute immediate b_lenh into b_dong;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
b_lenh:='insert into bh_kh_hoi_temp select ma,ten,rownum from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||b_xep||') sott from '||a_ch(1);
if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
b_lenh:=b_lenh||' order by '||b_xep||') where sott between :tu and :den';
execute immediate b_lenh using b_tu,b_den;
b_loi:='';
end;
/
create or replace procedure PBH_MA_LHNV_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri varchar2(30);
    b_kieu varchar2(1); b_dong number:=0; b_tu number:=1; cs_lke clob:='';
begin
-- Dan - Liet ke dong
delete bh_kh_hoi_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_oraIn) is null then
    select json_object('kieu' value 'C','dong' value 0,'tu' value 1,'cs_lke' value '') into b_oraOut from dual;
    return;
end if;
b_lenh:=FKH_JS_LENH('kieu,gtri');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri using b_oraIn;
if nvl(trim(b_kieu),' ')<>'C' then
    PBH_MA_LHNVj(b_oraIn,b_dong,b_loi);
elsif trim(b_gtri) is not null then
    PBH_MA_LHNV_MAj(b_oraIn,b_dong,b_loi);
else
    PBH_MA_LHNV_SLj(b_oraIn,b_tu,b_dong,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,'ten' value ma||' - '||ten) order by bt returning clob) into cs_lke from bh_kh_hoi_temp;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_kh_hoi_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); b_nv varchar2(10); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nv:=FKH_JS_GTRIs(b_oraIn,'nv');
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_ma_lhnv
    where tc='C' and ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_lhnv;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ma_lhnv order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ma_lhnv order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_lhnv order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_lhnv where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_lhnv where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_lhnv a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngayM number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; cs_dk clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(max(ngay_bd),0) into b_ngayM from bh_ma_lhnv_thue where ma=b_ma;
if b_ngayM<>0 then
    select min(json_object(a.ma,a.txt,b.hhong,b.hh_q,b.hh_f,b.htro,b.ht_q,b.ht_f,b.dvu,b.dv_q,b.dv_f)) into cs_ct
        from bh_ma_lhnv a,bh_ma_lhnv_thue b where a.ma=b_ma and a.ngay_bd=b_ngayM and b.ma=a.ma;
    select JSON_ARRAYAGG(json_object('ngay_bd' value PKH_SO_CNG(ngay_bd),
        hhong,hh_q,hh_f,htro,ht_q,ht_f,dvu,dv_q,dv_f) order by ngay_bd desc returning clob) into cs_dk
        from bh_ma_lhnv_thue where ma=b_ma;
else
    select min(json_object(ma,txt)) into cs_ct from bh_ma_lhnv where ma=b_ma;
end if;
select json_object('cs_dk' value cs_dk,'cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1); b_bb varchar2(1); b_loai varchar2(5);
    b_ma_ct varchar2(10); b_ma_cd varchar2(10); b_ma_tai varchar2(10); b_ngay_bd number; b_ngay_kt number;
    b_hhong number; b_hh_q number; b_hh_f number; b_htro number; b_ht_q number; b_ht_f number; b_dvu number; b_dv_q number; b_dv_f number;
    b_nv varchar2(100):=' '; b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1); b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,bb,loai,ma_ct,ma_cd,ma_tai,ngay_bd,ngay_kt,
    hhong,hh_q,hh_f,htro,ht_q,ht_f,dvu,dv_q,dv_f,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_bb,b_loai,b_ma_ct,b_ma_cd,b_ma_tai,b_ngay_bd,b_ngay_kt,
    b_hhong,b_hh_q,b_hh_f,b_htro,b_ht_q,b_ht_f,b_dvu,b_dv_q,b_dv_f,
    b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_tc) is null or b_tc not in ('T','C') then b_loi:='loi:Sai tc:loi'; raise PROGRAM_ERROR; end if;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
if b_tc='C' then
    if trim(b_loai) is null or b_loai not in ('V','N','TV','TN') then
        b_loi:='loi:Sai loai bao hiem:loi'; raise PROGRAM_ERROR;
    end if;
end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ma_lhnv where ma=b_ma_ct and tc<>'C';
end if;
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_lhnv_thue where ma=b_ma and ngay_bd=b_ngay_bd;
delete bh_ma_lhnv where ma=b_ma;
insert into bh_ma_lhnv values(b_ma_dvi,b_ma,b_ten,b_tc,b_bb,b_loai,b_ma_ct,b_ma_cd,b_ma_tai,b_ngay_bd,b_ngay_kt,b_nv,b_nsd,b_oraIn);
if b_tc='C' then
    insert into bh_ma_lhnv_thue values(b_ma_dvi,b_ma,b_ngay_bd,b_hhong,b_hh_q,b_hh_f,b_htro,b_ht_q,b_ht_f,b_dvu,b_dv_q,b_dv_f);
end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_LHNV_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_lhnv where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_lhnv_thue where ma=b_ma;
delete bh_ma_lhnv where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/



/*** Ma dieu khoan ***/
create or replace function FBH_MA_DK_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ma_dk where ma=b_ma and tc='C';
return b_kq;
end;
/
create or replace function FBH_MA_DK_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ma_dk where ma=b_ma and tc='C' and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_MA_DK_LHNV(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select nvl(min(lh_nv),' ') into b_kq from bh_ma_dk where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_MA_DK_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into cs_lke from bh_ma_dk a where tc='C' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
end;
/
create or replace procedure PBH_MA_DK_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_dk;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_dk order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dk where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_dk a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_dk;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ma_dk order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ma_dk order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,xep) returning clob) into cs_lke from
        (select b.*,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_dk order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct) b)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dk where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_dk where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_dk a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt) into cs_ct from bh_ma_dk where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_tc varchar2(1);
    b_ma_ct varchar2(10); b_lh_nv varchar2(10); b_ngay_kt number; b_nv varchar2(100):=' '; b_nvB varchar2(100);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1); 
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,lh_nv,ngay_kt,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_tc,b_ma_ct,b_lh_nv,b_ngay_kt,
    b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_tc) is null or b_tc not in ('T','C') then b_loi:='loi:Sai tc:loi'; raise PROGRAM_ERROR; end if;
if b_tc='C' then
    if trim(b_lh_nv) is null then b_loi:='loi:Nhap loai hinh nghiep vu:loi'; raise PROGRAM_ERROR; end if;
    b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
    b_nvB:=FBH_MA_LHNV_NV(b_lh_nv);
    if FBH_MA_NV_BAO(b_nvB,b_nv)<>'C' then b_loi:='loi:Dieu khoan va nghiep vu lech nghiep vu ap dung:loi'; raise PROGRAM_ERROR; end if;
end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ma_dk where ma=b_ma_ct and tc<>'C';
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_dk where ma=b_ma;
insert into bh_ma_dk values(b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ct,b_lh_nv,b_ngay_kt,b_nv,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_dk where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_dk where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Ma dieu khoan bo sung ***/
create or replace function FBH_MA_DKBS_MA_DK(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select nvl(min(ma_dk),' ') into b_kq from bh_ma_dkbs where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_DKBS_LHNV(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select nvl(min(lh_nv),' ') into b_kq from bh_ma_dkbs where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_DKBS_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ma_dkbs where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_DKBS_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ma_dkbs where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_DKBS_ND(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10); b_txt clob;
begin
-- Dan - Tra noi dung dieu khoan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=trim(b_oraIn);
if b_ma is null then
    b_oraOut:='';
else
    select txt into b_txt from bh_ma_dkbs where ma=b_ma;
    b_oraOut:=FKH_JS_GTRIc(b_txt,'nd');
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate);
    b_ma_dk varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma_dk'); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_lke from bh_ma_dkbs where ma_dk=b_ma_dk and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
end;
/
create or replace procedure PBH_MA_DKBS_LKE (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;  
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_dkbs;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select  ma,ten,nsd,rownum sott from bh_ma_dkbs a order by ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dkbs where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,rownum sott from bh_ma_dkbs where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan -- Nam nhap focus vao ban ghi moi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_dkbs;
select JSON_ARRAYAGG(json_object(ma,ten,nsd returning clob) order by ma returning clob) into cs_lke from bh_ma_dkbs;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=nvl(trim(b_ma),' ');
if b_ma=' ' then b_loi:='loi:Chon ma:loi'; raise PROGRAM_ERROR; end if;
select json_object(ma,txt returning clob) into cs_ct from bh_ma_dkbs where ma=b_ma;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_nvB varchar2(100);
    b_ma_dk varchar2(10); b_ma varchar2(10); b_ten nvarchar2(500); b_lh_nv varchar2(10);
    b_ngay_kt number; b_nv varchar2(100):=' '; b_lh_nvB varchar2(10);
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1);
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ma_dk,lh_nv,ngay_kt,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ma_dk,b_lh_nv,b_ngay_kt,b_2b,b_xe,b_hang,b_phh,
                         b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma dieu khoan bo sung:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
b_ma_dk:=nvl(trim(b_ma_dk),' '); b_lh_nv:=nvl(trim(b_lh_nv),' ');
if b_ma_dk<>' ' then
    if FBH_MA_DK_HAN(b_ma_dk)<>'C' then b_loi:='loi:Sai ma dieu khoan chinh:loi'; raise PROGRAM_ERROR; end if;
    select nv,lh_nv into b_nvB,b_lh_nvB from bh_ma_dk where ma=b_ma_dk;
    if FBH_MA_NV_BAO(b_nvB,b_nv)<>'C' then
        b_loi:='loi:Dieu khoan bo sung va dieu khoan chinh lech nghiep vu ap dung:loi'; raise PROGRAM_ERROR;
    end if;
    if b_lh_nv not in(' ',b_lh_nvB)  then
        b_loi:='loi:Dieu khoan bo sung va dieu khoan chinh lech loai hinh nghiep vu:loi'; raise PROGRAM_ERROR;
    end if;
end if;
if b_lh_nv<>' ' then
    if FBH_MA_LHNV_HAN(b_lh_nv)<>'C' then b_loi:='loi:Sai loai hinh nghiep vu:loi'; raise PROGRAM_ERROR; end if;
    b_nvB:=FBH_MA_LHNV_NV(b_lh_nv);
    if FBH_MA_NV_BAO(b_nvB,b_nv)<>'C' then
        b_loi:='loi:Loai hinh nghiep vu lech nghiep vu ap dung:loi'; raise PROGRAM_ERROR;
    end if;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_ma_dkbs where ma=b_ma;
insert into bh_ma_dkbs values(b_ma_dvi,b_ma,b_ten,b_ma_dk,b_lh_nv,b_ngay_kt,b_nv,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=nvl(trim(b_ma),' ');
if b_ma=' ' then b_loi:='loi:Chon ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_ma_dkbs where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Ma dieu khoan loai tru ***/
create or replace function FBH_MA_DKLT_TEN(b_ma_dk varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ma_dklt where ma_dk=b_ma_dk and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_DKLT_HAN(b_ma_dk varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ma_dklt where ma_dk=b_ma_dk and ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_DKLT_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate);
    b_ma_dk varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma_dk'); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_lke from bh_ma_dklt where ma_dk=b_ma_dk and ma<>' ' and ngay_kt>b_ngay;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
end;
/
create or replace procedure PBH_MA_DKLT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_dklt;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dk,ma,ten,nsd,'xep' value decode(ma,' ',ma_dk,'--'||ma)) returning clob) into cs_lke
        from (select  a.*,rownum sott from bh_ma_dklt a order by ma_dk,ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dklt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dk,ma,ten,nsd,'xep' value ma||'<'||ma_dk) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_dklt a where ma<>' ' and upper(ten) like b_tim order by ma_dk,ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKLT_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ma_dk varchar2(10); b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dk,ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma_dk,b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma dieu khoan bo sung:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_dklt;
    select nvl(min(sott),b_dong) into b_tu from
        (select a.*,rownum sott from bh_ma_dklt a order by ma_dk,ma)
        where ma_dk=b_ma_dk and ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dk,ma,ten,nsd,'xep' value decode(ma,' ',ma_dk,'--'||ma)) returning clob) into cs_lke
        from (select a.*,rownum sott from bh_ma_dklt a order by ma_dk,ma)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_dklt where ma<>' ' and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_dklt where ma<>' ' and upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select count(*) into b_dong from bh_ma_dklt where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dk,ma,ten,nsd,'xep' value ma||'<'||ma_dk) returning clob) into cs_lke
        from (select a.*,rownum sott from bh_ma_dklt a where ma<>' ' and upper(ten) like b_tim order by ma_dk,ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKLT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    --duchq tang do dai b_lenh
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_ma_dk varchar2(10); b_ma varchar2(10); cs_ct clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dk,ma');
EXECUTE IMMEDIATE b_lenh into b_ma_dk,b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ma_dk:=nvl(trim(b_ma_dk),' ');
select count(*) into b_i1 from bh_ma_dklt where ma_dk=b_ma_dk and ma=b_ma;
if b_i1<>0 then
  select json_object(ma_dk,ma,txt returning clob) into cs_ct from bh_ma_dklt where ma_dk=b_ma_dk and ma=b_ma;
end if;
select json_object('cs_ct' value cs_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKLT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_nvB varchar2(100);
    b_ma_dk varchar2(10); b_ma varchar2(10); b_ten nvarchar2(500);
    b_ngay_kt number; b_tenDK nvarchar2(500); b_nv varchar2(100):=' ';
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1); 
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dk,ma,ten,ngay_kt,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ma_dk,b_ma,b_ten,b_ngay_kt,b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ma_dk:=nvl(trim(b_ma_dk),' ');
if b_ma=' ' then b_loi:='loi:Nhap ma dieu khoan loai tru:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
if b_ma_dk=' ' then b_tenDK:='Cho tat ca dieu khoan';
else
    b_loi:='loi:Sai ma dieu khoan chinh:loi';
    if FBH_MA_DK_HAN(b_ma_dk)<>'C' then raise PROGRAM_ERROR; end if;
    select ten,nv into b_tenDK,b_nvB from bh_ma_dk where ma=b_ma_dk;
    if FBH_MA_NV_BAO(b_nvB,b_nv)<>'C' then raise PROGRAM_ERROR; end if;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_dklt where ma=b_ma; --Nam: chi check trung ma khong check trung ma_dk
select count(*) into b_i1 from bh_ma_dklt where ma=' ';
if b_i1=0 then
    insert into bh_ma_dklt values(b_ma_dvi,b_ma_dk,' ',b_tenDK,30000101,' ',' ',' ');
else 
    insert into bh_ma_dklt values(b_ma_dvi,b_ma_dk,b_ma,b_ten,b_ngay_kt,b_nv,b_nsd,b_oraIn);
end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKLT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    --duchq tang do dai b_lenh
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number; b_ma_dk varchar2(10); b_ma varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dk,ma');
EXECUTE IMMEDIATE b_lenh into b_ma_dk,b_ma using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ma_dk:=nvl(trim(b_ma_dk),' ');
select count(*) into b_i1 from bh_ma_dklt where ma_dk=b_ma_dk;
if b_i1>2 then
    delete bh_ma_dklt where ma_dk=b_ma_dk and ma=b_ma;
else
    delete bh_ma_dklt where ma_dk=b_ma_dk;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKLT_ND(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10); b_txt clob;
begin
-- DUCHQ - Tra noi dung dieu khoan loai tru
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=trim(b_oraIn);
if b_ma is null then
    b_oraOut:='';
else
    select txt into b_txt from bh_ma_dklt where ma=b_ma;
    select json_object('nd' VALUE FKH_JS_GTRIc(b_txt,'nd')returning clob) into b_oraOut FROM dual;

    --b_oraOut:='{"nd":"'||FKH_JS_GTRIc(b_txt,'nd')||'"}';
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_HOI_TEN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri varchar2(30); a_gtri pht_type.a_var;
    b_ctrId varchar2(100); b_ten nvarchar2(500);
begin
-- Dan - Tim ten cho hover
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ctrId,gtri');
EXECUTE IMMEDIATE b_lenh into b_ctrId,b_gtri using b_oraIn;
if instr(b_gtri,'|')=0 then
    select min(ten) into b_ten from bh_ma_dk where ma=b_gtri;
elsif instr(b_gtri,'|')=1 then
    b_gtri:=substr(b_gtri,2);
    select min(ten) into b_ten from bh_ma_dkbs where ma_dk=' ' and ma=b_gtri;
else
    PKH_CH_ARR(b_gtri,a_gtri,'|');
    select min(ten) into b_ten from bh_ma_dkbs where ma_dk=a_gtri(1) and ma=a_gtri(2);
end if;
select json_object('ctrId' value b_ctrId,'ten' value b_ten) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DK_LISTt(b_nv varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
insert into bh_ma_dknv_temp
	select '1',ma,ten from bh_ma_dk where tc='C' and ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
end;
/
create or replace procedure PBH_MA_DK_LIST_MA(
    b_oraIn clob,b_dong out number,cs1 out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); a_ch pht_type.a_var; b_tu number:=1; b_den number; b_trang number;
    b_gtri nvarchar2(500); b_ten nvarchar2(500); b_trangkt number;
begin
-- Dan - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('gtri,trangKt');
EXECUTE IMMEDIATE b_lenh into b_gtri,b_trangKt using b_oraIn;
if b_gtri is null then b_loi:='loi:Nhap ma:loi'; return; end if;
b_ten:='%'||b_gtri||'%';
select count(*) into b_dong from bh_ma_dknv_temp where ma>=b_gtri or upper(ten) like b_ten;
if b_dong>b_trangKt then b_den:=b_trangKt; else b_den:=b_dong; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by xep,ma returning clob) into cs1 from
    (select ma,ten,xep,rownum sott from bh_ma_dknv_temp where ma>=b_gtri or upper(ten) like b_ten order by xep,ma)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PBH_MA_DK_LIST_SL(
    b_oraIn clob,b_tu out number,b_dong out number,cs1 out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_den number;
begin
-- Dan - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_ma_dknv_temp;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten) returning clob) into cs1 from
    (select ma,ten,rownum sott from bh_ma_dknv_temp order by xep,ma)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PBH_MA_DK_LIST_VTRI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_dong number; b_tu number:=1; b_gtri varchar2(20); b_nv varchar2(10);
    b_ctrId varchar2(100); b_ma varchar2(30); b_ten nvarchar2(500); b_vtri number;
begin
-- Dan - Tra ma,ten tuong ung ma cu va vi tri moi
b_lenh:=FKH_JS_LENH('ctrId,gtri,vtri,nv');
EXECUTE IMMEDIATE b_lenh into b_ctrId,b_gtri,b_vtri,b_nv using b_oraIn;
PBH_MA_DK_HOI_LISTt(b_nv);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_gtri) is not null then 
    select count(*) into b_dong from bh_ma_dknv_temp;
    select nvl(min(sott),1) into b_tu from
        (select ma,row_number() over (order by xep,ma) sott from bh_ma_dknv_temp order by xep,ma)
    where ma>=b_gtri;
    b_tu:=b_tu+b_vtri;
    if b_tu<1 then b_tu:=b_dong;
    elsif b_tu>b_dong then b_tu:=1;
    end if;
end if;
select min(ma),min(ten) into b_ma,b_ten from 
    (select ma,ten,row_number() over (order by xep,ma) sott from bh_ma_dknv_temp order by xep,ma)
    where sott=b_tu;
select json_object('ctrId' value b_ctrId,'ma' value b_ma,'ten' value b_ten,'vtri' value b_vtri) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- DKBS --
create or replace procedure PBH_MA_DKBS_HOI_TEN(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri varchar2(30); a_gtri pht_type.a_var;
    b_ctrId varchar2(100); b_ten nvarchar2(500);
begin
-- Dan - Tim ten cho hover
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ctrId,gtri');
EXECUTE IMMEDIATE b_lenh into b_ctrId,b_gtri using b_oraIn;
select min(ten) into b_ten from bh_ma_dkbs where ma=b_gtri;
select json_object('ctrId' value b_ctrId,'ten' value b_ten) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DKBS_LISTt(b_nv varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
insert into bh_ma_dknv_temp
    select '2',ma,ten from bh_ma_dkbs where ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
end;
/
create or replace procedure PBH_MA_DKBS_HOI_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri varchar2(20); b_nv varchar2(10);
    b_kieu varchar2(1); b_dong number; b_tu number:=1; cs_lke clob;
begin
-- Dan - Liet ke dong
delete bh_ma_dknv_temp; commit;
b_lenh:=FKH_JS_LENH('kieu,gtri,nv');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_nv using b_oraIn;
PBH_MA_DKBS_LISTt(b_nv);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_kieu<>'C' then
    PBH_MA_DK_LIST(b_oraIn,b_dong,cs_lke,b_loi);
elsif trim(b_gtri) is not null then
    PBH_MA_DK_LIST_MA(b_oraIn,b_dong,cs_lke,b_loi);
else
    PBH_MA_DK_LIST_SL(b_oraIn,b_tu,b_dong,cs_lke,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_ma_dknv_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Ma qui tac
create or replace function FBH_MA_QTAC_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ma_qtac where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_QTAC_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_ma_qtac where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_QTAC_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ma_qtac where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_QTAC_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngay number:=PKH_NG_CSO(sysdate);
    b_nv varchar2(10):=FKH_JS_GTRIs(b_oraIn,'nv'); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_lke
    from bh_ma_qtac where ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
end;
/
create or replace procedure PBH_MA_QTAC_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob:=''; b_tim nvarchar2(200);
    b_lenh varchar2(1000); b_tu number; b_den number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then 
  select count(*) into b_dong from bh_ma_qtac;
  PKH_LKE_TRANG(b_dong,b_tu,b_den);
  select JSON_ARRAYAGG(obj) into cs_lke from
    (select json_object(ma,ten,nsd) obj,rownum sott from bh_ma_qtac order by ten)
            where sott between b_tu and b_den;
else 
  select count(*) into b_dong from bh_ma_qtac where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd,'xep' value ma) returning clob) into cs_lke from
        (select a.*,rownum sott from bh_ma_qtac a where upper(ten) like b_tim order by ma)
    where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_QTAC_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_ma_qtac;
select JSON_ARRAYAGG(json_object(ma,ten,nsd returning clob) order by ma returning clob) into cs_lke from bh_ma_qtac;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_QTAC_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,txt) into cs_ct from bh_ma_qtac where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_QTAC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number; b_nv varchar2(100):=' ';
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1); 
    b_hop varchar2(1); b_nong varchar2(1);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,ngay_kt,xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_ngay_kt,b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_qtac where ma=b_ma;
insert into bh_ma_qtac values(b_ma_dvi,b_ma,b_ten,b_ngay_kt,b_nv,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_QTAC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_ma_qtac where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* viet anh */
create or replace procedure PBH_MA_QTAC_LISTt(b_nv varchar2,b_nhom varchar2,b_lay_all varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
  -- viet anh
insert into temp_1(c1,c2,c3)
  select '1',ma,ten from bh_ma_qtac where ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
end;

