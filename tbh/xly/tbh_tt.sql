/*** DOI CHIEU ***/
create or replace function FTBH_TT_TXT(b_ma_dvi varchar2,b_so_id_tt number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from tbh_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from tbh_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FTBH_TT_SO_ID(b_so_ct varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra so Id qua so ct
if trim(b_so_ct) is not null then
    select nvl(min(so_id_tt),0) into b_kq from tbh_tt where so_ct=b_so_ct;
end if;
return b_kq;
end;
/
create or replace function FTBH_TT_SO_CT(b_so_id_tt number) return varchar2
AS
    b_kq varchar2(20):='';
begin
-- Dan - Tra so ct qua so id
if b_so_id_tt<>0 then
    select min(so_ct) into b_kq from tbh_tt where so_id_tt=b_so_id_tt;
end if;
return b_kq;
end;
/
create or replace PROCEDURE PTBH_TT_TONnbh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    cs_nbh clob;
begin
-- Dan - Liet ke ton nha_bh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma' value nha_bh,'ten' value FBH_MA_NBH_TEN(nha_bh))) into cs_nbh from
    (select distinct nha_bh from tbh_dc where so_id_tt=0);
select json_object('cs_nbh' value cs_nbh) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_TT_TONnt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_nha_bh varchar2(20); cs_nt clob;
begin
-- Dan - Liet ke ton nha_bh => nt
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nha_bh:=FKH_JS_GTRIs(b_oraIn,'nha_bh');
if trim(b_nha_bh) is null then b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma' value nt_tra)) into cs_nt from
    (select distinct nt_tra from tbh_dc where so_id_tt=0 and nha_bh=b_nha_bh);
select json_object('cs_nt' value cs_nt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_TT_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_nha_bh varchar2(20); b_nt_tra varchar2(5);
    cs_ton clob:='';
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nha_bh,nt_tra');
EXECUTE IMMEDIATE b_lenh into b_nha_bh,b_nt_tra using b_oraIn;
if trim(b_nha_bh) is null then
    b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_nt_tra) is null then
    b_loi:='loi:Chon loai tien:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object(
    'ngay_ht' value ngay_ht,'so_bk' value so_bk,'so_dc' value so_dc,
    'tra' value tra,'so_id_dc' value so_id_dc,'chon' value '')
    order by ngay_ht,so_bk returning clob) into cs_ton
    from tbh_dc where so_id_tt=0 and nha_bh=b_nha_bh and nt_tra=b_nt_tra;
select json_object('cs_ton' value cs_ton returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_TT_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_ct varchar2(20); b_so_id number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_ct:=FKH_JS_GTRIs(b_oraIn,'so_ct');
b_so_id:=FTBH_TT_SO_ID(b_so_ct);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngayD number; b_ngayC number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_tt where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,tra,so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
            order by so_id_tt desc returning clob) into cs_lke from
            (select ngay_ht,so_ct,tra,nha_bh,so_id_tt,rownum sott from tbh_tt where 
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from tbh_tt where ngay_ht between b_ngayD and b_ngayC;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,tra,so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
            order by so_id_tt desc returning clob) into cs_lke from
            (select ngay_ht,so_ct,tra,nha_bh,so_id_tt,rownum sott from tbh_tt where 
            ngay_ht between b_ngayD and b_ngayC order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngayD number; b_ngayC number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngayd,ngayc,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngayD,b_ngayC,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from tbh_tt where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from tbh_tt where
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,tra,so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
        order by so_id_tt desc returning clob) into cs_lke from
        (select ngay_ht,so_ct,tra,nha_bh,so_id_tt,rownum sott from tbh_tt where 
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_tt desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_tt where ngay_ht between b_ngayD and b_ngayC;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from tbh_tt where
        ngay_ht between b_ngayD and b_ngayC order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,tra,so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
        order by so_id_tt desc returning clob) into cs_lke from
        (select ngay_ht,so_ct,tra,nha_bh,so_id_tt,rownum sott from tbh_tt where 
        ngay_ht between b_ngayD and b_ngayC order by so_id_tt desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_tt number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
b_loi:='loi:Xu ly da xoa:loi';
select json_object(so_ct,'nha_bh' value FBH_MA_NBH_TENl(nha_bh),'nt_tra' value nt_tra||'|'||nt_tra)
    into dt_ct from tbh_tt where so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object('so_id_dc' value so_id_dc,bt) order by bt)
    into dt_dk from tbh_tt_ct where so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from tbh_tt_txt where so_id_tt=b_so_id_tt;
select json_object('so_id_tt' value b_so_id_tt,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TT_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct clob,dt_dk clob,
    b_ngay_ht out number,b_nha_bh out varchar2,b_nt_tra out varchar2,b_pt_tra out varchar2,
    b_so_ct out varchar2,b_tra out number,b_tra_qd out number,
    b_nt_tt out varchar2,b_ttoan out number,b_ttoan_qd out number,
    a_so_id out pht_type.a_num,a_tra out pht_type.a_num,a_tra_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000);
begin
-- Dan - Kiem tra so lieu
b_lenh:=FKH_JS_LENH('ngay_ht,nha_bh,nt_tra,nt_tt,pt_tra,ttoan,so_ct');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nha_bh,b_nt_tra,b_nt_tt,b_pt_tra,b_ttoan,b_so_ct using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_dc');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id using dt_dk;
if b_ngay_ht in(0,30000101) or b_nha_bh=' ' or b_nt_tra=' ' or b_pt_tra not in('T','C') or a_so_id.count=0 then
    b_loi:='loi:Nhap so lieu sai:loi'; return;
end if;
b_tra:=0; b_tra_qd:=0;
for b_lp in 1.. a_so_id.count loop
    b_loi:='loi:Sai so lieu xu ly dong '||trim(to_char(b_lp))||':loi';
    if a_so_id(b_lp) is null then return; end if;
    select so_id_tt,tra,tra_qd into b_i1,a_tra(b_lp),a_tra_qd(b_lp) from tbh_dc where so_id_dc=a_so_id(b_lp) for update nowait;
    if sql%rowcount=0 then b_loi:='loi:So doi chieu dang xu ly dong '||to_char(b_lp)||':loi'; return; end if;
    if b_i1>0 then b_loi:='loi:So doi chieu da thanh toan dong '||to_char(b_lp)||':loi'; return; end if;
    b_tra:=b_tra+a_tra(b_lp); b_tra_qd:=b_tra_qd+a_tra_qd(b_lp);
end loop;
if b_nt_tt=b_nt_tra then
    b_ttoan:=b_tra; b_ttoan_qd:=b_tra_qd;
elsif b_nt_tt='VND' then
    b_ttoan_qd:=b_ttoan;
else
    b_ttoan_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tt,b_ttoan);
end if;
if trim(b_so_ct) is null then b_so_ct:=substr(to_char(b_so_id),3); end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TT_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_TT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,
    b_ngay_ht number,b_nha_bh varchar2,b_so_ct varchar2,
    b_nt_tra varchar2,b_pt_tra varchar2,b_tra number,b_tra_qd number,
    b_nt_tt varchar2,b_ttoan number,b_ttoan_qd number,
    a_so_id pht_type.a_num,a_tra pht_type.a_num,a_tra_qd pht_type.a_num,
    dt_ct clob,dt_dk clob,b_loi out varchar2)
AS
    b_bt number:=0; b_bt2 number:=10000; b_tien_qd number; b_thue_qd number; b_hhong_qd number;
    b_loai varchar2(10); b_tg number;
begin
-- Dan - Nhap doi chieu
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
insert into tbh_tt values(b_ma_dvi,b_so_id_tt,b_ngay_ht,b_so_ct,b_nha_bh,
    b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_nt_tt,b_ttoan,b_ttoan_qd,b_nsd,0,sysdate);
for b_lp in 1..a_so_id.count loop
    insert into tbh_tt_ct values(b_ma_dvi,b_so_id_tt,b_lp,a_so_id(b_lp),a_tra(b_lp),a_tra_qd(b_lp));
end loop;
forall b_lp in 1..a_so_id.count
    update tbh_dc set so_id_tt=b_so_id_tt where so_id_dc=a_so_id(b_lp);
insert into tbh_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_ct',dt_ct);
insert into tbh_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_dk',dt_dk);
if b_tra<>0 and b_pt_tra='C' then
    PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nha_bh,b_nt_tra,-b_tra,-b_tra_qd,b_loi);
    if b_loi is not null then return; end if;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TT_NH_NH:loi'; end if;
end;
/
create or replace procedure PTBH_TT_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_nsd_c varchar2(10); b_ngay_ht number; b_pt_tra varchar2(1);
    b_nha_bh varchar2(20); b_nt_tra varchar2(5); b_tra number; b_tra_qd number;
    a_so_id pht_type.a_num;
begin
-- Dan - Xoa doi chieu
select ngay_ht,nsd,so_id_kt,nha_bh,nt_tra,pt_tra,tra,tra_qd into
    b_ngay_ht,b_nsd_c,b_i1,b_nha_bh,b_nt_tra,b_pt_tra,b_tra,b_tra_qd
    from tbh_tt where so_id_tt=b_so_id_tt;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
if trim(b_nsd_c) is not null and b_nsd_c<>b_nsd then
    b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return;
end if;
if b_i1<>0 then b_loi:='loi:Thanh toan da hach toan:loi'; return; end if;
select so_id_dc bulk collect into a_so_id from tbh_tt_ct where so_id_tt=b_so_id_tt;
forall b_lp in 1..a_so_id.count
    update tbh_dc set so_id_tt=0 where so_id_dc=a_so_id(b_lp);
delete tbh_tt_txt where so_id_tt=b_so_id_tt;
delete tbh_tt_ct where so_id_tt=b_so_id_tt;
delete tbh_tt where so_id_tt=b_so_id_tt;
if b_tra<>0 and b_pt_tra='C' then
    PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nha_bh,b_nt_tra,-b_tra,-b_tra_qd,b_loi);
    if b_loi is not null then return; end if;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TT_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_TT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob; dt_dk clob;
    b_so_id_tt number; b_ngay_ht number; b_nha_bh varchar2(20);
    b_nt_tra varchar2(5); b_pt_tra varchar2(1);
    b_so_ct varchar2(20); b_tra number; b_tra_qd number;
    b_nt_tt varchar2(5); b_ttoan number; b_ttoan_qd number; 
    a_so_id pht_type.a_num; a_tra pht_type.a_num; a_tra_qd pht_type.a_num;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id_tt>0 then
    PTBH_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,b_loi);
else
    PHT_ID_MOI(b_so_id_tt,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TT_TEST(
    b_ma_dvi,b_so_id_tt,dt_ct,dt_dk,
    b_ngay_ht,b_nha_bh,b_nt_tra,b_pt_tra,b_so_ct,b_tra,b_tra_qd,b_nt_tt,b_ttoan,b_ttoan_qd,
    a_so_id,a_tra,a_tra_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TT_NH_NH(
    b_ma_dvi,b_nsd,b_so_id_tt,b_ngay_ht,b_nha_bh,b_so_ct,b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_nt_tt,b_ttoan,b_ttoan_qd,
    a_so_id,a_tra,a_tra_qd,dt_ct,dt_dk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_tt' value b_so_id_tt,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_tt number;
begin
-- Dan - Xoa thanh toan
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
if b_so_id_tt is null or b_so_id_tt=0 then
    b_loi:='loi:Nhap thanh toan xoa:loi'; raise PROGRAM_ERROR;
end if;
PTBH_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_nha_bh varchar2(20); b_ngayD number; b_ngayC number;
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in(0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,nt_tra,tra,so_id_tt,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
    order by ngay_ht desc,so_ct returning clob) into cs_lke from
    (select ngay_ht,so_ct,nt_tra,tra,nha_bh,so_id_tt,rownum sott from tbh_tt where
    ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',nha_bh) order by ngay_ht desc,so_ct)
    where sott<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
