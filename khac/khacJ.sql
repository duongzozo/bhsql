/* Khai TTT */
create or replace function FBH_KH_TTT_HOI
    (b_ps varchar2,b_nv varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra co thong tn them
select count(*) into b_i1 from bh_kh_ttt where ps=b_ps and nv=b_nv;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
-- chuclh them returning clob va xoa ham o file bh_khac
create or replace procedure PBH_KH_TTT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ps varchar2(20); b_nv varchar2(20);
    b_dong number; cs_lke clob;
begin
-- Dan - Xem thong tin them chung tu theo nghiep vu
b_lenh:=FKH_JS_LENH('ps,nv');
EXECUTE IMMEDIATE b_lenh into b_ps,b_nv using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_nv,'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_kh_ttt where ps=b_ps and nv=b_nv;
select JSON_ARRAYAGG(json_object(ma,ten,loai,bb,ktra,nsd) order by bt  returning clob) into cs_lke from bh_kh_ttt where ps=b_ps and nv=b_nv;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_TTT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_ps varchar2(20); b_nv varchar2(20); b_dt_ttt clob;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_loai pht_type.a_var; a_bb pht_type.a_var; a_ktra pht_type.a_var;
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_lenh:=FKH_JS_LENH('ps,nv');
EXECUTE IMMEDIATE b_lenh into b_ps,b_nv using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_ps,'M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ttt');
EXECUTE IMMEDIATE b_lenh into b_dt_ttt using b_oraIn;
b_lenh:=FKH_JS_LENH('ma,ten,loai,bb,ktra');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_loai,a_bb,a_ktra using b_dt_ttt;
if a_ma.count=0 then raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    if trim(a_ma(b_lp)) is null or trim(a_ten(b_lp)) is null then
        b_loi:='loi:Nhap sai dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    if trim(a_loai(b_lp)) is null or a_loai(b_lp) not in('H','S','N','G') then a_loai(b_lp):='C'; end if;
    if trim(a_bb(b_lp)) is null or a_bb(b_lp)<>'C' then a_bb(b_lp):='K'; end if;
end loop;
b_loi:='loi:Va cham NSD:loi';
delete bh_kh_ttt where ps=b_ps and nv=b_nv;
for b_lp in 1..a_ma.count loop
    insert into bh_kh_ttt values(b_ma_dvi,b_ps,b_nv,a_ma(b_lp),a_ten(b_lp),a_loai(b_lp),a_bb(b_lp),a_ktra(b_lp),b_lp,b_nsd);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KH_TTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ps varchar2(20); b_nv varchar2(20);
begin
-- Dan - Xem thong tin them chung tu theo nghiep vu
b_lenh:=FKH_JS_LENH('ps,nv');
EXECUTE IMMEDIATE b_lenh into b_ps,b_nv using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH',b_ps,'M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete bh_kh_ttt where ps=b_ps and nv=b_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_CAYj
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_ham varchar2(100);
    b_ctrId varchar2(100); b_cap varchar2(2); b_ma varchar2(20); b_tso varchar2(1000); cs_lke clob;
    b_tim nvarchar2(100);
begin
-- viet anh - Liet ke dang cay
delete kh_cay; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ham,ctrId,cap,ma,tso,tim');
EXECUTE IMMEDIATE b_lenh into b_ham,b_ctrId,b_cap,b_ma,b_tso,b_tim using b_oraIn;
b_ma:=nvl(trim(b_ma),' ');
b_tim:=nvl(trim(b_tim),' ');
if trim(b_tso) is null then
    b_lenh:='begin '||b_ham||'(:ma,:tim); end;';
    EXECUTE IMMEDIATE b_lenh using b_ma,b_tim;
else
    b_lenh:='begin '||b_ham||'(:ma,:tso); end;';
    EXECUTE IMMEDIATE b_lenh using b_ma,b_tso;
end if;
select JSON_ARRAYAGG(obj returning clob) into cs_lke from
    (select json_object(ten,ma,loai,tso returning clob) obj from kh_cay order by ten);
select json_object('ctrId' value b_ctrId,'cap' value b_cap,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete kh_cay; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PKH_KTRA_TENj(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);  b_i1 number; 
	b_gtri varchar2(200); b_ktra varchar2(200);
    b_bang varchar2(30); b_truong varchar2(30); a_ktra pht_type.a_var;
begin
-- Dan - Tim ten
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('gtri,ktra');
EXECUTE IMMEDIATE b_lenh into b_gtri,b_ktra using b_oraIn;
PKH_CH_ARR(b_ktra,a_ktra);
b_bang:=a_ktra(1); b_truong:=a_ktra(2);
b_loi:='loi:Sai ma:loi';
b_lenh:='select 0 from '||b_bang||' where '||b_truong||'= :ma';
execute immediate b_lenh into b_i1 using b_gtri;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_TENj(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri varchar2(4000); b_ktra varchar2(500);
    b_bang varchar2(30); b_truong varchar2(30); b_ten varchar2(30); a_ktra pht_type.a_var;
    b_ctrId varchar2(500); b_kq nvarchar2(500);
begin
-- Dan - Tim ten
if b_comm='C' then
  b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
  if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('ctrId,gtri,ktra');
EXECUTE IMMEDIATE b_lenh into b_ctrId,b_gtri,b_ktra using b_oraIn;
PKH_CH_ARR(b_ktra,a_ktra);
b_bang:=a_ktra(1); b_truong:=a_ktra(2); b_ten:=a_ktra(3);
if b_truong='pas' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma:loi';
b_lenh:='select min('||b_ten||') from '||b_bang||' where '||b_truong||'= :ma';
execute immediate b_lenh into b_kq using b_gtri;
select json_object('ctrId' value b_ctrId,'ten' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--chuclh: ham thieu ktoan dung
create or replace function KH_HOI_TEN(b_ma_dviN varchar2,b_bang varchar2,b_truong varchar2,b_gtri varchar2,b_kq varchar2) return nvarchar2
AS
    b_lenh varchar2(500); b_ten nvarchar2(500); b_ma_dvi varchar2(20);
begin
-- Dan - Kiem tra ma co chua
if b_bang<>'ht_ma_dvi' then
    b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,b_bang);
    b_lenh:='select min('||b_kq||') from '||b_bang||' where ma_dvi= :ma_dvi and '||b_truong||'= :ma';
    execute immediate b_lenh into b_ten using b_ma_dvi,b_gtri;
else 
    b_lenh:='select min('||b_kq||') from ht_ma_dvi where '||b_truong||'= :ma';
    execute immediate b_lenh into b_ten using b_gtri;
end if;
return b_ten;
end;
/
create or replace procedure PKH_HOI_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000); b_gtri varchar2(500);
    b_ktra varchar2(500); b_kieu varchar2(1):='C'; b_dong number:=0; b_tu number:=1;
    b_ham varchar2(100); b_tso nvarchar2(1000); cs_lke clob:=''; b_txt clob;
begin
-- Dan - Liet ke dong
delete bh_kh_hoi_temp; delete bh_kh_hoi_temp1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_oraIn) is null then
    select json_object('kieu' value 'C','dong' value 0,'tu' value 1,'cs_lke' value '') into b_oraOut from dual;
    return;
end if;
b_lenh:=FKH_JS_LENH('ktra,kieu,gtri,ham,tso');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_kieu,b_gtri,b_ham,b_tso using b_oraIn;
b_txt:=b_oraIn;
if trim(b_ham) is not null then
    b_lenh := 'begin '||b_ham||'(:tso,:loi); end;';
    EXECUTE IMMEDIATE b_lenh using b_tso,out b_loi;
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    b_ktra:='bh_kh_hoi_temp1,ma,ten';
    PKH_JS_THAY(b_txt,'ktra','bh_kh_hoi_temp1,ma,ten');
elsif trim(b_ktra) is null then return;
end if;
if nvl(trim(b_kieu),' ')<>'C' then
    PKH_HOI_LISTj(b_txt,b_dong,b_loi);
elsif trim(b_gtri) is not null then
    PKH_HOI_LIST_MAj(b_txt,b_dong,b_loi);
else
    PKH_HOI_LIST_SLj(b_txt,b_tu,b_dong,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into cs_lke from bh_kh_hoi_temp;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_kh_hoi_temp; delete bh_kh_hoi_temp1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LISTj(
    b_oraIn clob,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate);
    b_gtri varchar2(50); b_ma varchar2(30); b_ten nvarchar2(500); b_min nvarchar2(100);
    b_ktra varchar2(200); b_trangKt number; b_tc varchar2(20); b_cK varchar2(200):=' ';
    a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong
b_loi:='loi:Loi xu ly PKH_HOI_LISTj:loi';
b_lenh:=FKH_JS_LENH('ktra,gtri,trangKt,tc');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_gtri,b_trangKt,b_tc using b_oraIn;
PKH_CH_ARR(b_ktra,a_ch);
if a_ch.count>2 and lower(a_ch(1))='ht_ma_nsd' and lower(a_ch(3))='pas' then b_loi:='loi:Khong xem password:loi'; return; end if;
if a_ch(1)<>'ht_ma_dvi' and FKH_CTR_BANG(a_ch(1),'ngay_kt')='C' then
    b_cK:=' ngay_kt>'||to_char(sysdate,'yyyymmdd')||' ';
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
         b_lenh:=b_lenh||' order by '||a_ch(2);
        execute immediate b_lenh;
    end if;
else
    b_gtri:=upper(b_gtri); b_ma:='%'||FKH_BO_UNICODE(b_gtri,'C','C')||'%'; b_ten:='%'||b_gtri||'%';
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
    if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
    execute immediate b_lenh into b_dong,b_min using b_ma,b_ten;
    if not(b_dong>b_trangKt or (b_dong=1 and upper(b_min)=b_gtri)) then
        b_lenh:='insert into bh_kh_hoi_temp select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum from '||a_ch(1)||' where '||
            a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
        if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
        b_lenh:=b_lenh||' order by '||a_ch(2);
        execute immediate b_lenh using b_ma,b_ten;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_HOI_LIST_MAj(
    b_oraIn clob,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate); a_ch pht_type.a_var;
    b_tu number; b_den number; b_tc varchar2(20); b_cK varchar2(200):=' ';
    b_ktra varchar2(500); b_gtri varchar2(500); b_ma varchar2(500); b_ten nvarchar2(500);
begin
-- Dan - Liet ke dong tu, den
b_loi:='loi:Loi xu ly PKH_HOI_LIST_MAj:loi';
b_lenh:=FKH_JS_LENH('ktra,gtri,tc,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_gtri,b_tc,b_tu,b_den using b_oraIn;
PKH_CH_ARR(b_ktra,a_ch);
if lower(a_ch(1))='ht_ma_nsd' and lower(a_ch(3))='pas' then b_loi:='loi:Khong xem password:loi'; return; end if;
if b_gtri is null then b_loi:='loi:Nhap ma:loi'; return; end if;
if a_ch(1)<>'ht_ma_dvi' and FKH_CTR_BANG(a_ch(1),'ngay_kt')='C' then
    b_cK:=' ngay_kt>'||to_char(sysdate,'yyyymmdd')||' ';
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
b_gtri:=upper(b_gtri); b_ma:='%'||FKH_BO_UNICODE(b_gtri,'C','C')||'%'; b_ten:='%'||b_gtri||'%';
b_lenh:='select count(*) from '||a_ch(1)||' where '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
execute immediate b_lenh into b_dong using b_ma,b_ten;
if b_dong<>0 then
    b_lenh:='insert into bh_kh_hoi_temp select ma,ten,sott from';
    b_lenh:=b_lenh||' (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum sott from '||a_ch(1);
    b_lenh:=b_lenh||' where ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten)';
    if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
    b_lenh:=b_lenh||' order by '||a_ch(2)||')';
    b_lenh:=b_lenh||' where sott between :tu and :den';
    execute immediate b_lenh using b_ma,b_ten,b_tu,b_den;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_HOI_LIST_SLj(
    b_oraIn clob,b_tu out number,b_dong out number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(sysdate); a_ch pht_type.a_var; b_den number; b_ktra varchar2(200);
    b_ng varchar2(1); b_tc varchar2(20); b_cK varchar2(200):=' ';
begin
-- Dan - Liet ke dong tu, den
b_loi:='loi:Loi xu ly PKH_HOI_LIST_SLj:loi';
b_lenh:=FKH_JS_LENH('ktra,tu,den,tc');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_tu,b_den,b_tc using b_oraIn;
PKH_CH_ARR(b_ktra,a_ch);
if lower(a_ch(1))='ht_ma_nsd' and lower(a_ch(3))='pas' then b_loi:='loi:Khong xem password:loi'; return; end if;
if a_ch(1)<>'ht_ma_dvi' and FKH_CTR_BANG(a_ch(1),'ngay_kt')='C' then
    b_cK:=' ngay_kt>'||to_char(sysdate,'yyyymmdd')||' ';
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
b_lenh:='insert into bh_kh_hoi_temp select ma,ten,rownum from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,rownum sott from '||a_ch(1);
if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
b_lenh:=b_lenh||' order by '||a_ch(2)||') where sott between :tu and :den';
execute immediate b_lenh using b_tu,b_den;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_HOI_LIST_VTRIj(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); a_ch pht_type.a_var;
    b_dong number; b_tu number:=1; b_xep number; b_ktra varchar2(200); b_gtri varchar2(20);
    b_ctrId varchar2(50); b_ma varchar2(30); b_ten nvarchar2(500); b_vtri number; b_tc varchar2(20);
    b_cK varchar2(200):=' ';
begin
-- Dan - Tra ma,ten tuong ung ma cu va vi tri moi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_oraIn) is null then
    select json_object('ctrid' value ' ','ma' value ' ','ten' value ' ','vtri' value 0) into b_oraOut from dual;
    return;
end if;
b_lenh:=FKH_JS_LENH('ctrid,xep,ktra,gtri,vtri,tc');
EXECUTE IMMEDIATE b_lenh into b_ctrId,b_xep,b_ktra,b_gtri,b_vtri,b_tc using b_oraIn;
PKH_CH_ARR(b_ktra,a_ch);
if lower(a_ch(1))='ht_ma_nsd' and lower(a_ch(3))='pas' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if a_ch(1)<>'ht_ma_dvi' and FKH_CTR_BANG(a_ch(1),'ngay_kt')='C' then
    b_cK:=' ngay_kt>'||to_char(sysdate,'yyyymmdd')||' ';
end if;
b_tc:=nvl(trim(b_tc),'C');
if FKH_CTR_BANG(a_ch(1),'tc')='C' and b_tc<>'A' then
    if b_cK<>' ' then b_cK:=b_cK||' and '; end if;
    b_cK:=b_cK||' tc='||CHR(39)||b_tc||CHR(39)||' ';
end if;
if trim(b_gtri) is not null then 
    b_lenh:='select count(*) from '||a_ch(1);
    if b_cK<>' ' then b_lenh:=b_lenh||' where '||b_cK; end if;
    execute immediate b_lenh into b_dong;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
        ') sott from '||a_ch(1)||' order by '||a_ch(b_xep)||') where '||a_ch(b_xep)||'>= :ma';
    if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
    execute immediate b_lenh into b_tu using b_gtri;
    b_tu:=b_tu+b_vtri;
    if b_tu<1 or b_tu>b_dong then b_tu:=1; end if;
end if;
b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
    ') sott from '||a_ch(1)||' order by '||a_ch(b_xep)||') where '||a_ch(b_xep)||'>= :ma';
if b_cK<>' ' then b_lenh:=b_lenh||' and '||b_cK; end if;
b_lenh:=b_lenh||' and sott= :tu';
execute immediate b_lenh into b_ma,b_ten using b_gtri,b_tu;
select json_object('ctrid' value b_ctrId,'ma' value b_ma,'ten' value b_ten,'vtri' value b_vtri) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* viet anh -- DR_LKE theo nv */
create or replace procedure PBH_MA_DMUC_HOI_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri nvarchar2(500); b_nv varchar2(10);
    b_nhom varchar2(1);  b_proc_name varchar2(100); b_lay_all varchar2(1):='K';
    b_kieu varchar2(1); b_dong number; b_tu number:=1; cs_lke clob;
begin
-- viet anh
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('kieu,gtri,nv,nhom,proc_name,lay_all');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_nv,b_nhom,b_proc_name,b_lay_all using b_oraIn;
-- truyen prod dong
b_nv:=nvl(b_nv,' '); -- th khong chon nv
if b_nv = ' ' then select json_object('kieu' value b_kieu,'dong' value 0,'tu' value 0,'cs_lke' value null) into b_oraOut from dual; return; end if;
b_lenh := 'BEGIN ' || b_proc_name || '(:nv, :nhom, :lay_all); END;';
EXECUTE IMMEDIATE b_lenh using b_nv, b_nhom, b_lay_all;
if b_kieu<>'C' then
    PBH_MA_DMUC_LIST(b_oraIn,b_dong,cs_lke,b_loi);
elsif trim(b_gtri) is not null then
    PBH_MA_DMUC_LIST_MA(b_oraIn,b_dong,cs_lke,b_loi);
else
    PBH_MA_DMUC_LIST_SL(b_oraIn,b_tu,b_dong,cs_lke,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DMUC_LIST(
    b_oraIn clob,b_dong out number,cs1 out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_gtri nvarchar2(500); b_ten nvarchar2(100); b_min nvarchar2(100);
    b_trangKt number; b_nv varchar2(10); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- viet anh
cs1:='';
b_lenh:=FKH_JS_LENH('gtri,trangKt,nv');
EXECUTE IMMEDIATE b_lenh into b_gtri,b_trangKt,b_nv using b_oraIn;
if trim(b_gtri) is null then
    select count(*) into b_dong from temp_1;
    if b_dong>1 and b_dong<=b_trangKt then
        select JSON_ARRAYAGG(json_object(c2,c3) order by c1,c2 returning clob) into cs1 from temp_1;
    end if;
else
    b_ten:='%'||b_gtri||'%'; b_gtri:=upper(b_gtri);
    select count(*),min(c3) into b_dong,b_min from temp_1 where c2>=b_gtri or upper(c3) like b_ten;
    if b_dong<=b_trangKt and (b_dong>1 or upper(b_min)<>b_gtri) then
        select JSON_ARRAYAGG(json_object(c2,c3) order by c1,c2 returning clob) into cs1 from temp_1 where c2>=b_gtri or upper(c3) like b_ten;
    end if;
end if;
end;
/
create or replace procedure PBH_MA_DMUC_LIST_MA(
    b_oraIn clob,b_dong out number,cs1 out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); a_ch pht_type.a_var; b_tu number:=1; b_den number; b_trang number;
    b_gtri nvarchar2(500); b_ten nvarchar2(500); b_trangkt number;
begin
-- viet anh - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('gtri,trangKt');
EXECUTE IMMEDIATE b_lenh into b_gtri,b_trangKt using b_oraIn;
if b_gtri is null then b_loi:='loi:PBH_MA_SP_LIST_MA:loi'; return; end if;
b_ten:=upper(unistr('\0025')||b_gtri||'%');
select count(*) into b_dong from temp_1 where upper(c3) like b_ten;
if b_dong>b_trangKt then b_den:=b_trangKt; else b_den:=b_dong; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by xep,ma returning clob) into cs1 from
    (select c1 xep,c2 ma,c3 ten,rownum sott from temp_1 where upper(c3) like b_ten order by c1,c2)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PBH_MA_DMUC_LIST_SL(
    b_oraIn clob,b_tu out number,b_dong out number,cs1 out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_den number;
begin
-- viet anh - Liet ke dong tu, den
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ma,ten) returning clob) into cs1 from
    (select c2 ma,c3 ten,row_number() over ( order by c3,c2 ) as sott from temp_1)
    where sott between b_tu and b_den;
end;
/
/** nguoi dai dien **/
create or replace procedure PBH_MA_NGDD_HOI_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri nvarchar2(500);
    b_ma_dvi_ct varchar2(20);
    b_kieu varchar2(1); b_dong number; b_tu number:=1; cs_lke clob;
begin
-- viet anh - ma nguoi dai dien
delete temp_1; commit;
b_lenh:=FKH_JS_LENH('kieu,gtri,ma_dvi_ct');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_ma_dvi_ct using b_oraIn;
PBH_NG_DDIEN_LISTt(b_ma_dvi_ct);
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_kieu<>'C' then
    PBH_MA_DMUC_LIST(b_oraIn,b_dong,cs_lke,b_loi);
elsif trim(b_gtri) is not null then
    PBH_MA_DMUC_LIST_MA(b_oraIn,b_dong,cs_lke,b_loi);
else
    PBH_MA_DMUC_LIST_SL(b_oraIn,b_tu,b_dong,cs_lke,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_NG_DDIEN_LISTt(b_ma_dvi_ct varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
  -- viet anh
insert into temp_1(c1,c2,c3)
  select '1',ma,ten from ht_ma_nsd where ma_dvi=b_ma_dvi_ct;
end;
/
create or replace procedure PBH_MA_CDICH_LIST(b_nv varchar2,b_loi out varchar2)
AS
begin
-- viet anh
b_loi:='loi:Loi xu ly PBH_MA_CDICH_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from bh_ma_cdich where FBH_MA_NV_CO(nv,b_nv)='C' and FBH_MA_CDICH_HAN(ma)='C' order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PKH_HOI_LIST_DVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000); b_gtri varchar2(500);
    b_ktra varchar2(500); b_kieu varchar2(1):='C'; b_dong number:=0; b_tu number:=1;
    b_ham varchar2(100); b_tso nvarchar2(1000); cs_lke clob:=''; b_txt clob;
begin
-- viet anh - clone PKH_HOI_LIST Liet ke dong
delete bh_kh_hoi_temp; delete bh_kh_hoi_temp1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_oraIn) is null then
    select json_object('kieu' value 'C','dong' value 0,'tu' value 1,'cs_lke' value '') into b_oraOut from dual;
    return;
end if;
b_lenh:=FKH_JS_LENH('ktra,kieu,gtri,ham,tso');
EXECUTE IMMEDIATE b_lenh into b_ktra,b_kieu,b_gtri,b_ham,b_tso using b_oraIn;
b_txt:=b_oraIn;
if trim(b_ham) is not null then
    b_lenh := 'begin '||b_ham||'(:ma_dvi,:tso,:loi); end;';
    EXECUTE IMMEDIATE b_lenh using b_ma_dvi,b_tso,out b_loi;
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    b_ktra:='bh_kh_hoi_temp1,ma,ten';
    PKH_JS_THAY(b_txt,'ktra','bh_kh_hoi_temp1,ma,ten');
elsif trim(b_ktra) is null then return;
end if;
if nvl(trim(b_kieu),' ')<>'C' then
    PKH_HOI_LISTj(b_txt,b_dong,b_loi);
elsif trim(b_gtri) is not null then
    PKH_HOI_LIST_MAj(b_txt,b_dong,b_loi);
else
    PKH_HOI_LIST_SLj(b_txt,b_tu,b_dong,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by bt returning clob) into cs_lke from bh_kh_hoi_temp;
select json_object('kieu' value b_kieu,'dong' value b_dong,'tu' value b_tu,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_kh_hoi_temp; delete bh_kh_hoi_temp1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_CB_LIST(b_ma_dvi varchar2,b_tso nvarchar2,b_loi out varchar2)
AS
begin
-- viet anh
b_loi:='loi:Loi xu ly PBH_MA_CB_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_cb where ma_dvi=b_ma_dvi order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PBH_MA_DK_LIST(
    b_oraIn clob,b_dong out number,cs1 out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_gtri nvarchar2(500); b_ten nvarchar2(100); b_min nvarchar2(100);
    b_trangKt number; b_nv varchar2(10); b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Liet ke dong
cs1:='';
b_lenh:=FKH_JS_LENH('gtri,trangKt,nv');
EXECUTE IMMEDIATE b_lenh into b_gtri,b_trangKt,b_nv using b_oraIn;
if trim(b_gtri) is null then
    select count(*) into b_dong from bh_ma_dknv_temp;
    if b_dong>1 and b_dong<=b_trangKt then
        select JSON_ARRAYAGG(json_object(ma,ten) order by xep,ma returning clob) into cs1 from bh_ma_dknv_temp;
    end if;
else
    b_ten:='%'||b_gtri||'%'; b_gtri:=upper(b_gtri);
    select count(*),min(ten) into b_dong,b_min from bh_ma_dknv_temp where ma>=b_gtri or upper(ten) like b_ten;
    if b_dong<=b_trangKt and (b_dong>1 or upper(b_min)<>b_gtri) then
        select JSON_ARRAYAGG(json_object(ma,ten) order by xep,ma returning clob) into cs1 from bh_ma_dknv_temp where ma>=b_gtri or upper(ten) like b_ten;
    end if;
end if;
end;
/
create or replace procedure PKH_HOI_TEN_AC_J
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000);b_loi varchar2(200); b_i1 number; a_gtri pht_type.a_var; b_s nvarchar2(500); b_c varchar2(1):=',';
    b_bang varchar2(200);b_truong varchar2(100);b_gtri varchar2(100);b_kq varchar2(200);b_ten nvarchar2(100);
begin
-- Dan - Tim ten
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('bang,kq,truong,ten,ma');
EXECUTE IMMEDIATE b_lenh into b_bang,b_kq,b_truong,b_ten,b_gtri using b_oraIn;

if b_bang='ht_ma_nsd' and b_truong='pas' then
    b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR;
end if;
if instr(b_gtri,';')>0 then b_c:=';'; end if;
PKH_CH_ARR(b_gtri,a_gtri,b_c);
if trim(b_kq) is null then
    for b_lp in 1..a_gtri.count loop
        b_i1:=FKH_HOI_CO(b_ma_dvi,b_bang,b_truong,a_gtri(b_lp));
        if b_lp=1 then b_ten:=to_char(b_i1); else b_ten:=b_ten||';'||to_char(b_i1); end if;
        if b_i1=0 then exit; end if;
    end loop;
else
    for b_lp in 1..a_gtri.count loop
        b_s:=FKH_HOI_TEN(b_ma_dvi,b_bang,b_truong,a_gtri(b_lp),b_kq);
        if b_lp=1 then b_ten:=b_s; else b_ten:=b_ten||';'||b_s; end if;
        if b_s='' then exit; end if;
    end loop;
end if;
select json_object('ten' value b_ten) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/
create or replace procedure PKH_FILE_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi_n varchar2,b_so_id number,b_bt number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_dvi varchar2(20);
begin
-- Dan - Liet ke tiep
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null or b_bt is null then b_loi:='loi:Nhap ID, so cuoi:loi'; raise PROGRAM_ERROR; end if;
if trim(b_dvi_n) is null then b_dvi:=b_ma_dvi; else b_dvi:=b_dvi_n; end if;
open cs_lke for select ten,goc,kieuF,decode(x+y,0,'',to_char(x)||','||to_char(y)) tdo,ngay_nh,vtri,bt,to_char(ngay_nh,'dd/mm/yy hh24:mi') ngayS
    from kh_file where ma_dvi=b_dvi and so_id=b_so_id and bt>b_bt order by bt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_FILE_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi_n varchar2,b_so_id number,b_goc varchar2)
AS
    b_loi varchar2(100); b_dvi varchar2(20); b_ma_dvi_nh varchar2(20); b_nsd_c varchar2(50);
begin
-- Dan - Xoa file
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_dvi_n) is null then b_dvi:=b_ma_dvi; else b_dvi:=b_dvi_n; end if;
if b_so_id is null or b_goc is null then b_loi:='loi:Nhap so ID, file:loi'; raise PROGRAM_ERROR; end if;
select ma_dvi_nh,nsd into b_ma_dvi_nh,b_nsd_c from kh_file where ma_dvi=b_dvi and so_id=b_so_id and goc=b_goc;
if b_ma_dvi_nh<>b_ma_dvi or b_nsd<>b_nsd_c then
    b_loi:='loi:Khong xoa File nguoi khac:loi'; raise PROGRAM_ERROR;
end if;
delete kh_file where ma_dvi=b_dvi and so_id=b_so_id and goc=b_goc;
commit; 
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_FILE_VTRI(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_dvi_n varchar2,b_so_id number,b_goc varchar2,b_vtri varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_dvi varchar2(20); b_nd_c nvarchar2(500);
begin
-- Dan - Sua file
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_dvi_n) is null then b_dvi:=b_ma_dvi; else b_dvi:=b_dvi_n; end if;
if b_so_id is null or b_goc is null or trim(b_vtri) is null then b_loi:='loi:Nhap so ID, file, vi tri:loi'; raise PROGRAM_ERROR; end if;
update kh_file set vtri=b_vtri where ma_dvi=b_dvi and so_id=b_so_id and goc=b_goc;
commit; 
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_FILE_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi_n varchar2,b_so_id number,
    b_ten nvarchar2,b_goc varchar2,b_kieuF varchar2,b_x number:=0,b_y number:=0,b_r number:=0)
AS
    b_loi varchar2(100); b_idvung number; b_bt number; b_dvi varchar2(20);
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_dvi_n) is null then b_dvi:=b_ma_dvi; else b_dvi:=b_dvi_n; end if;
select nvl(max(bt),0) into b_bt from kh_file where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_bt:=b_bt+1;
b_loi:='loi:Loi Table KH_FILE:loi';
insert into kh_file values(b_dvi,b_so_id,b_ten,b_goc,b_kieuF,b_x,b_y,b_r,' ',b_bt,b_ma_dvi,b_nsd,sysdate,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function F_KTRA_KTRU(a_ktru pht_type.a_var,b_loi out varchar2) return varchar2
as
 b_i1 number;a_ch pht_type.a_var; b_kq varchar2(1):='C';
begin
-- Chuclh - Kiem tra dinh dang
  for b_lp in 1..a_ktru.count loop
    if trim(a_ktru(b_lp)) is null then continue; end if;
    PKH_CH_ARR(a_ktru(b_lp),a_ch,'|');
    select case 
         when regexp_like(PKH_LOC_CHU_SO(a_ch(1)), '^[0-9]+$') then 'C'  else 'K'  end into b_kq
    from dual;
    if b_kq='K' then return b_kq; end if;
    if a_ch.count=1 then continue; end if;
    select case 
         when regexp_like(PKH_LOC_CHU_SO(a_ch(2)), '^[0-9]+$') then 'C'  else 'K'  end into b_kq
    from dual;
    if b_kq='K' then return b_kq; end if;
  end loop;
  b_loi:='';
  return b_kq;
exception when others then return 'K';
end;
/
create or replace procedure PBH_MA_DK_HOI_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob, b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_gtri nvarchar2(500); b_nv varchar2(10);
    b_kieu varchar2(1); b_dong number; b_tu number:=1; cs_lke clob;
begin
-- Dan - Liet ke dong
delete bh_ma_dknv_temp; commit;
b_lenh:=FKH_JS_LENH('kieu,gtri,nv');
EXECUTE IMMEDIATE b_lenh into b_kieu,b_gtri,b_nv using b_oraIn;
PBH_MA_DK_LISTt(b_nv);
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
create or replace procedure PBH_MA_DK_HOI_LISTt(b_nv varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
delete bh_ma_dknv_temp; commit;
insert into bh_ma_dknv_temp select '1',ma,ten from bh_ma_dk where ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
insert into bh_ma_dknv_temp  select decode(ma_dk,' ','2','1'),trim(ma_dk)||':'||ma ma,ten from bh_ma_dkbs where ngay_kt>b_ngay and FBH_MA_NV_CO(nv,b_nv)='C';
end;
