create or replace function FTBH_DTUONG_TEN(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra list
if b_nv='PHH' then
    b_kq:=FTBH_MA_RR_TEN(b_ma);
elsif b_nv='PKT' then
    b_kq:=FBH_PKT_MA_NCT_TEN(b_ma);
elsif b_nv='NG' then
    b_kq:=FBH_MA_NGHE_TEN(b_ma);
elsif b_nv='XE' then
    b_kq:=FBH_XE_LOAI_TEN(b_ma);
elsif b_nv='2B' then
    b_kq:=FBH_2B_LOAI_TEN(b_ma);
elsif b_nv='TAU' then
    b_kq:=FBH_TAU_NHOM_TEN(b_ma);
end if;
return b_kq;
end;
/
create or replace function FTBH_DTUONG_TENl(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Tra ten list
b_kq:=FTBH_DTUONG_TEN(b_nv,b_ma);
if b_kq is not null then b_kq:=b_ma||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace function FTBH_DTUONG_TENf(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Tra ten list
b_kq:=FTBH_DTUONG_TEN(b_nv,b_ma);
if b_kq is not null then b_kq:=b_ma||'|'||b_ma||' - '||b_kq; end if;
return b_kq;
end;
/
create or replace function FTBH_DTUONG_BANG(b_nv varchar2) return varchar2
AS
    b_kq varchar2(50):='';
begin
-- Dan - Tra list
if b_nv='PHH' then
    b_kq:='tbh_ma_rr';
elsif b_nv='PKT' then
    b_kq:='bh_pkt_nct';
elsif b_nv='NG' then
    b_kq:='bh_ma_nghe';
elsif b_nv='XE' then
    b_kq:='bh_xe_loai';
elsif b_nv='2B' then
    b_kq:='bh_2b_loai';
elsif b_nv='TAU' then
    b_kq:='bh_tau_nhom';
end if;
return b_kq;
end;
/
create or replace procedure PTBH_DTUONG_TENJ
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_nv varchar2(10):=FKH_JS_GTRIs(b_oraIn,'nv');
	b_ktra varchar2(50); b_oraInX clob:=b_oraIn;
begin
-- Dan - Liet ke chi tiet
b_ktra:=FTBH_DTUONG_BANG(b_nv)||',ma,ten';
PKH_JS_THAY(b_oraInX,'ktra',b_ktra);
PKH_HOI_TENj(b_ma_dvi,b_nsd,b_pas,b_oraInX,b_oraOut);
end;
/
create or replace procedure PTBH_DTUONG_LIST(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_nv varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ktra');
	b_ktra varchar2(50); b_oraInX clob:=b_oraIn;
begin
-- Dan - Liet ke dong
b_ktra:=FTBH_DTUONG_BANG(b_nv)||',ma,ten';
PKH_JS_THAY(b_oraInX,'ktra',b_ktra);
PKH_HOI_LIST(b_ma_dvi,b_nsd,b_pas,b_oraInX,b_oraOut);
end;
/
/*** Muc giu lai theo NV tai ***/
create or replace function FTBH_MGIU_GLAI(
    b_ma_dvi varchar2,b_so_id number,b_lh_nv varchar2,b_ma_dt varchar2,
    b_nt_ta varchar2,b_do_tl number,b_ve_tl number,b_ngay number) return number
AS
    b_i1 number; b_ma_nt varchar2(5); b_kieu varchar2(3):='C';
    b_pt number; b_hs_gl number; b_tp number:=0; b_glai number:=0;
begin
select nvl(min(glai),0) into b_glai from tbh_mgiu_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt in(' ',b_ma_dt);
if b_glai=0 then return 0; end if;
b_ma_nt:=FTBH_MGIU_NT(b_so_id);
if b_ma_nt<>'VND' then b_tp:=2; end if;
if b_do_tl<>0 then
    select nvl(max(pt),0) into b_i1 from tbh_mgiu_do where so_id=b_so_id and b_do_tl>=pt;
    if b_i1<>0 then
        select hs_gl into b_hs_gl from tbh_mgiu_do where so_id=b_so_id and pt=b_i1;
        b_glai:=round(b_glai*b_hs_gl/100,b_tp);
    end if;
end if;
if b_ve_tl<>0 then
    select nvl(max(pt),0) into b_i1 from tbh_mgiu_ta where so_id=b_so_id and b_ve_tl>=pt;
    if b_i1<>0 then
        select hs_gl into b_hs_gl from tbh_mgiu_ta where so_id=b_so_id and pt=b_i1;
        b_glai:=round(b_glai*b_hs_gl/100,b_tp);
    end if;
end if;
if b_nt_ta<>b_ma_nt then
    b_glai:=FBH_TT_TUNG_QD(b_ngay,b_ma_nt,b_glai,b_nt_ta);
end if;
return b_glai;
end;
/
create or replace function FTBH_MGIU_SO_ID(b_nv varchar2,b_ngay number) return number
AS
    b_kq number:=0; b_ngayM number; b_ngayD number:=round(b_ngay,-4);
begin
-- Dan - Tra so_id
select nvl(max(ngay),0) into b_ngayM from tbh_mgiu where nv=b_nv and ngay between b_ngayD and b_ngay;
if b_ngayM<>0 then
    select so_id into b_kq from tbh_mgiu where nv=b_nv and ngay=b_ngayM;
end if;
return b_kq;
end;
/
create or replace function FTBH_MGIU_NT(b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Tra ma_nt
select min(ma_nt) into b_kq from tbh_mgiu where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PTBH_MGIU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from tbh_mgiu;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay,nv,nsd,so_id) returning clob) into cs_lke from
    (select ngay,nv,nsd,so_id,rownum sott from tbh_mgiu order by ngay desc,nv)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MGIU_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_so_id number; b_hangkt number; b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,hangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_hangkt using b_oraIn;
if b_so_id=0 then b_loi:='loi:Nhap so_id:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tbh_mgiu;
select nvl(min(sott),b_dong) into b_tu from 
    (select so_id,rownum sott from tbh_mgiu order by ngay desc,nv,so_id)
    where so_id>=b_so_id;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(ngay,nv,nsd,so_id)) into cs_lke from
    (select ngay,nv,nsd,so_id,rownum sott from tbh_mgiu order by ngay desc,nv,so_id)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MGIU_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_nv varchar2(10);
    b_so_id number; cs_ct clob; cs_nv clob; cs_do clob; cs_ta clob;
begin
-- Dan - Liet ke chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Khai bao muc giu lai da xoa:loi';
select nv into b_nv from tbh_mgiu where so_id=b_so_id;
select json_object(ngay,nv,ma_nt) into cs_ct from tbh_mgiu where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(
    'lh_nv' value FBH_MA_LHNV_TAI_TENf(lh_nv),
    'ma_dt' value FTBH_DTUONG_TENl(b_nv,ma_dt),glai) order by bt returning clob)
    into cs_nv from tbh_mgiu_nv where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(pt,hs_gl) order by pt returning clob) into cs_do from tbh_mgiu_do where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(pt,hs_gl) order by pt returning clob) into cs_ta from tbh_mgiu_ta where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value cs_ct,'dt_nv' value cs_nv,
    'dt_do' value cs_do,'dt_ta' value cs_ta returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MGIU_XOA_XOA
    (b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_nsdC varchar2(10); b_i1 number;
begin
-- Dan - Xoa
b_loi:='loi:Loi xoa khai bao muc giu lai:loi';
select count(*),min(nsd) into b_i1,b_nsdC from tbh_mgiu where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac '||b_nsd||'|'||b_nsdC||':loi'; return; end if;
delete tbh_mgiu where so_id=b_so_id;
delete tbh_mgiu_nv where so_id=b_so_id;
delete tbh_mgiu_do where so_id=b_so_id;
delete tbh_mgiu_ta where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PTBH_MGIU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null or b_so_id=0 then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
PTBH_MGIU_XOA_XOA(b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_MGIU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    b_so_id number; b_ngay number; b_nv varchar2(10); b_ma_nt varchar2(5);
    nv_lh_nv pht_type.a_var; nv_ma_dt pht_type.a_var; nv_glai pht_type.a_num;
    do_pt pht_type.a_num; do_hs_gl pht_type.a_num;
    ta_pt pht_type.a_num; ta_hs_gl pht_type.a_num;
    dt_ct clob; dt_nv clob; dt_do clob; dt_ta clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id<>0 then
    PTBH_MGIU_XOA_XOA(b_nsd,b_so_id,b_loi);
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_nv,dt_do,dt_ta');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_nv,dt_do,dt_ta using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay,nv,ma_nt');
EXECUTE IMMEDIATE b_lenh into b_ngay,b_nv,b_ma_nt using dt_ct;
if b_ngay is null or b_ngay in(0,30000101) then
    b_loi:='loi:Sai ngay ap dung:loi'; raise PROGRAM_ERROR;
end if;
if b_nv is null or b_nv not in('XE','2B','HANG','NG','TAU','PHH','PKT','PTN') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Sai ma nguyen te:loi';
if trim(b_ma_nt) is null then raise PROGRAM_ERROR; end if;
if b_ma_nt<>'VND' then
    select 0 into b_i1 from tt_ma_nt where ma=b_ma_nt;
end if;
if FTBH_MGIU_SO_ID(b_nv,b_ngay)<>0 then
    b_loi:='loi:Da khai bao muc giu lai:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('lh_nv,ma_dt,glai');
EXECUTE IMMEDIATE b_lenh bulk collect into nv_lh_nv,nv_ma_dt,nv_glai using dt_nv;
if nv_lh_nv.count=0 then
    b_loi:='loi:Nhap muc giu lai:loi'; raise PROGRAM_ERROR;
end if;
for b_lp in 1..nv_lh_nv.count loop
    b_loi:='loi:Sai chi tiet nghiep vu dong '||to_char(b_lp)||':loi';
    if nv_lh_nv(b_lp) is null or nv_glai(b_lp) is null or nv_glai(b_lp)<0 then
        raise PROGRAM_ERROR;
    end if;
    if FBH_MA_LHNV_TAI_NV(nv_lh_nv(b_lp),b_nv)<>'C' then raise PROGRAM_ERROR; end if;
	nv_ma_dt(b_lp):=nvl(trim(nv_ma_dt(b_lp)),' ');
	if nv_ma_dt(b_lp)<> ' ' and FTBH_DTUONG_TEN(b_nv,nv_ma_dt(b_lp)) is null then
		raise PROGRAM_ERROR;
	end if;
end loop;
if trim(dt_do) is null then
    PKH_MANG_KD_N(do_pt);
else
    b_lenh:=FKH_JS_LENH('pt,hs_gl');
    EXECUTE IMMEDIATE b_lenh bulk collect into do_pt,do_hs_gl using dt_do;
    if do_pt.count<>0 then
        for b_lp in 1..do_pt.count loop
            if do_pt(b_lp) is null or do_pt(b_lp)<0 or do_pt(b_lp)>100 or
                do_hs_gl(b_lp) is null or do_hs_gl(b_lp)<0 or do_hs_gl(b_lp)>100 then
                b_loi:='loi:Sai he so dong BH dong '||to_char(b_lp)||':loi';
                raise PROGRAM_ERROR;
            end if;
        end loop;
    end if;
end if;
if trim(dt_ta) is null then
    PKH_MANG_KD_N(ta_pt);
else
    b_lenh:=FKH_JS_LENH('pt,hs_gl');
    EXECUTE IMMEDIATE b_lenh bulk collect into ta_pt,ta_hs_gl using dt_ta;
    if ta_pt.count<>0 then
        for b_lp in 1..ta_pt.count loop
            if ta_pt(b_lp) is null or ta_pt(b_lp)<0 or ta_pt(b_lp)>100 or
                ta_hs_gl(b_lp) is null or ta_hs_gl(b_lp)<0 or ta_hs_gl(b_lp)>100 then
                b_loi:='loi:Sai he so tai BH dong'||to_char(b_lp)||':loi';
                raise PROGRAM_ERROR;
            end if;
        end loop;
    end if;
end if;
b_loi:='loi:Loi Table TBH_MGIU:loi';
insert into tbh_mgiu values(b_ma_dvi,b_so_id,b_ngay,b_nv,b_ma_nt,b_nsd);
for b_lp in 1..nv_lh_nv.count loop
    insert into tbh_mgiu_nv values(b_ma_dvi,b_so_id,nv_lh_nv(b_lp),nv_ma_dt(b_lp),nv_glai(b_lp),b_lp);
end loop;
for b_lp in 1..do_pt.count loop
    insert into tbh_mgiu_do values(b_ma_dvi,b_so_id,do_pt(b_lp),do_hs_gl(b_lp),b_lp);
end loop;
for b_lp in 1..ta_pt.count loop
    insert into tbh_mgiu_ta values(b_ma_dvi,b_so_id,ta_pt(b_lp),ta_hs_gl(b_lp),b_lp);
end loop;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Hop dong tai co dinh */
create or replace function FTBH_HD_DI_TXT(b_so_id number,b_tim varchar2,b_dk varchar2:=' ') return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from tbh_hd_di_txt where so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from tbh_hd_di_txt where so_id=b_so_id and loai='dt_ct';
	b_kq:=FKH_JS_GTRIs(b_txt,b_tim,b_dk);
end if;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_SO_HD(b_so_id number) return varchar2
AS
    b_kq varchar2(20):='';
begin
-- Dan - Tra so_hd qua so_id
select max(so_hd) into b_kq from tbh_hd_di where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FTBH_HD_DI_SO_HDt(
    b_so_id number,b_so_hd out varchar2,b_nha_bh out varchar2,b_pthuc out varchar2)
AS
begin
-- Dan - Tra tham so hop dong
select min(nha_bh) into b_nha_bh from tbh_hd_di_nha_bh where so_id=b_so_id and kieu in('C','M');
if b_nha_bh is null then
    b_so_hd:=''; b_pthuc:='';
else
    select so_hd,pthuc into b_so_hd,b_pthuc from tbh_hd_di where so_id=b_so_id;
	b_pthuc:=FTBH_MA_PTHUC_PP(b_pthuc);
end if;
end;
/
create or replace function FTBH_HD_DI_SO_HDf(b_so_id number) return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_so_hd varchar2(20); b_pthuc varchar2(10);
begin
-- Dan - Tra ten
select so_hd,pthuc into b_so_hd,b_pthuc from tbh_hd_di where so_id=b_so_id;
b_kq:=b_so_hd||'('||FTBH_MA_PTHUC_PP(b_pthuc)||')';
return b_kq;
end;
/
create or replace function FTBH_HD_DI_SO_HDl(b_so_id number) return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_nha_bh varchar2(20); b_so_hd varchar2(20); b_pthuc varchar2(10);
begin
-- Dan - Tra ten va so_hd
FTBH_HD_DI_SO_HDt(b_so_id,b_so_hd,b_nha_bh,b_pthuc);
if b_nha_bh is not null then
    b_kq:=to_char(b_so_id)||'|'||FBH_MA_NBH_TEN(b_nha_bh)||' ('||b_so_hd||'/'||b_pthuc||')';
end if;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_SO_ID(b_so_hd varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra so_id qua so_hd
select nvl(max(so_id),0) into b_kq from tbh_hd_di where so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_SO_IDp(
    b_nv varchar2,b_pthuc varchar2,b_ngay number) return number
AS
    b_kq number:=0; b_ngayM number; b_ngayD number:=round(b_ngay,-4);
begin
-- Dan - Tra so_id qua pthuc
select nvl(max(ngay_bd),0) into b_ngayM from tbh_hd_di where nv=b_nv and pthuc=b_pthuc and ngay_bd between b_ngayD and b_ngay;
if b_ngayM<>0 then
    select so_id into b_kq from tbh_hd_di  where nv=b_nv and pthuc=b_pthuc and ngay_bd=b_ngayM;
end if;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_MA_NT(b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Tra ma_nt
select nvl(min(ma_nt),'VND') into b_kq from tbh_hd_di where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_PTHUC(b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra NV
select nvl(min(pthuc),' ') into b_kq from tbh_hd_di where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_NV(b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra NV
select nvl(min(nv),' ') into b_kq from tbh_hd_di where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_HD_DI_TY_GIA(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra ty gia hop dong tai di
select nvl(max(ty_gia),1) into b_kq from tbh_hd_di where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_HD_NGAY_HL(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay hieu luc hop dong tai
select nvl(min(ngay_bd),0) into b_kq from tbh_hd_di where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_HD_NGAY_KT(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay ket thuc hop dong tai
select nvl(min(ngay_kt),0) into b_kq from tbh_hd_di where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FTBH_HD_DI_NGAY(
	b_so_id number,b_ngay_hl out number,b_ngay_kt out number)
AS
    b_kq number;
begin
-- Dan - Ngay hieu luc hop dong tai
select nvl(min(ngay_bd),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from tbh_hd_di where so_id=b_so_id;
end;
/
create or replace procedure FTBH_HD_DI_GLAI(
    b_ma_dvi varchar2,b_so_id number,b_lh_nv varchar2,b_ma_dt varchar2,b_so_dt number,
    b_nt_ta varchar2,b_do_tl number,b_ve_tl number,b_ngay number,
    b_nguong out number,b_glai out number,b_ghan out number,b_tlp out number,
    b_loi out varchar2,b_dk varchar2:='K',b_uot varchar2:='K')
AS
    b_i1 number; b_ma_nt varchar2(5); b_ma_dtM varchar2(10); b_glaiM number;
    b_tp number:=0; b_hs_ng number; b_hs_gl number; b_hs_gh number;
    b_nguongU number; b_glaiU number; b_ghanU number; 
begin
-- Dan - Tra nguong,glai,ghan tai co dinh
b_ma_nt:=FTBH_HD_DI_MA_NT(b_so_id);
if b_ma_nt<>'VND' then b_tp:=2; end if;
select max(ma_dt) into b_ma_dtM from tbh_hd_di_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt in(' ',b_ma_dt);
if b_ma_dtM is null then
    b_nguong:=-1; b_glai:=0; b_ghan:=0; b_tlp:=0; b_loi:=''; return;
end if;
select min(nguong),min(glai),min(glaiM),min(ghan),max(tlp) into b_nguong,b_glai,b_glaiM,b_ghan,b_tlp
    from tbh_hd_di_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt=b_ma_dtM;
if b_dk='C' then b_glai:=b_glaiM; end if;
if b_uot='C' then
    FTBH_HD_DI_UOT(b_so_id,b_lh_nv,b_nguongU,b_glaiU,b_ghanU);
    if b_nguongU>100 then b_nguong:=b_nguongU;
    elsif b_nguong>100 then b_nguong:=round(b_nguong*b_nguongU/100,0);
    else b_nguong:=round(b_nguong*b_nguongU/100,4);
    end if;
    if b_glaiU>100 then b_glai:=b_glaiU;
    elsif b_glai>100 then b_glai:=round(b_glai*b_glaiU/100,0);
    else b_glai:=round(b_glai*b_glaiU/100,4);
    end if;
    if b_ghanU>100 then b_ghan:=b_ghanU;
    elsif b_ghan>100 then b_ghan:=round(b_ghan*b_ghanU/100,0);
    else b_ghan:=round(b_ghan*b_ghanU/100,4);
    end if;
end if;
if b_do_tl<>0 then
    select nvl(min(pt),0) into b_i1 from tbh_hd_di_do where so_id=b_so_id and b_do_tl>=pt;
    if b_i1<>0 then
        select hs_ng,hs_gl,hs_gh into b_hs_ng,b_hs_gl,b_hs_gh from tbh_hd_di_do where so_id=b_so_id and pt=b_i1;
        if b_hs_ng<>0 then b_nguong:=round(b_nguong*b_hs_ng/100,b_tp); end if;
        if b_hs_gl<>0 then b_glai:=round(b_glai*b_hs_gl/100,b_tp); end if;
        if b_hs_gh<>0 then b_ghan:=round(b_ghan*b_hs_gh/100,b_tp); end if;
    end if;
end if;
if b_ve_tl<>0 then
    select nvl(max(pt),0) into b_i1 from tbh_hd_di_ta where so_id=b_so_id and pt<=b_ve_tl;
    if b_i1<>0 then
        select hs_ng,hs_gl,hs_gh into b_hs_ng,b_hs_gl,b_hs_gh from tbh_hd_di_ta where so_id=b_so_id and pt=b_i1;
        if b_hs_ng<>0 then b_nguong:=round(b_nguong*b_hs_ng/100,b_tp); end if;
        if b_hs_gl<>0 then b_glai:=round(b_glai*b_hs_gl/100,b_tp); end if;
        if b_hs_gh<>0 then b_ghan:=round(b_ghan*b_hs_gh/100,b_tp); end if;
    end if;
end if;
if b_ma_nt<>b_nt_ta then
    b_nguong:=FBH_TT_TUNG_QD(b_ngay,b_ma_nt,b_nguong,b_nt_ta);
    if (b_glai>100) then b_glai:=FBH_TT_TUNG_QD(b_ngay,b_ma_nt,b_glai,b_nt_ta); end if;
    if (b_ghan>100) then b_ghan:=FBH_TT_TUNG_QD(b_ngay,b_ma_nt,b_ghan,b_nt_ta); end if;
end if;
if b_so_dt>1 then
    b_nguong:=b_nguong*b_so_dt; b_ghan:=b_ghan*b_so_dt;
    b_glai:=b_glai*b_so_dt;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_HD_DI_GLAI:loi'; end if;
end;
/
create or replace procedure FTBH_HD_DI_HSNG(
    b_so_id number,b_ma_nt varchar2,b_ngay number,b_ma_dt varchar2,
	b_tienN number,b_bth number,b_ptG number,b_hs out number,b_loi out varchar2)
AS
    b_i1 number; b_tienM number; b_bthM number; b_ptGM number;
	b_tien number:=b_tienN;
begin
-- Dan - Tra he so nguong
b_hs:=100;
if b_tien>0 or b_ptG>0 or b_bth>0 then
    if b_ma_nt<>'VND' then b_tien:=FBH_TT_VND_QD(b_ngay,b_ma_nt,b_tien); end if;
    select count(*),nvl(max(tien),0),nvl(max(bth),0),nvl(max(ptG),0) into b_i1,b_tienM,b_bthM,b_ptGM
        from tbh_hd_di_hsng where so_id=b_so_id and ma_dt=b_ma_dt and (b_tien=0 or tien<b_tien) and (b_ptG=0 or ptG<b_ptG) and (b_bth=0 or bth<b_bth);
    if b_i1<>0 then
        select nvl(max(hs),100) into b_hs from tbh_hd_di_hsng where
            so_id=b_so_id and ma_dt=b_ma_dt and tien=b_tienM and bth=b_bthM and ptG=b_ptGM;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_HD_DI_HSNG:loi'; end if;
end;
/
create or replace function FTBH_HD_DI_TLP(
    b_so_id number,b_lh_nv varchar2,b_ma_dt varchar2) return number
AS
	b_kq number;
begin
-- Dan - Tra ty le phi toi thieu
select nvl(min(tlp),0) into b_kq from tbh_hd_di_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt in(' ',b_ma_dt);
return b_kq;
end;
/
create or replace procedure FTBH_HD_DI_UOT(
    b_so_id number,b_lh_nv varchar2,b_nguong out number,b_glai out number,b_ghan out number)
AS
begin
-- Dan - Tra he so uot
select nvl(min(nguong),100),nvl(min(glai),100),nvl(min(ghan),100) into b_nguong,b_glai,b_ghan
	from tbh_hd_di_uot where so_id=b_so_id and lh_nv=b_lh_nv;
end;
/
create or replace function FTBH_HD_DI_BO(b_so_id number,b_lh_nv varchar2,b_ma_dt varchar2) return varchar2
AS
	b_kq varchar2(1):='C'; b_i1 number;
begin
-- Dan - Tra doi tuong trong danh sach ko xu ly tai
if trim(b_ma_dt) is not null then
	select count(*) into b_i1 from tbh_hd_di_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt=b_ma_dt and nguong<0;
	if b_i1<>0 then b_kq:='K'; end if;
end if;
return b_kq;
end;
/
create or replace procedure FTBH_HD_DI_HH(
    b_so_id number,b_lh_nv varchar2,b_ma_dt varchar2,b_hh out number,b_hh_ll out number)
AS
begin
-- Dan - Tra ty le hoa hong
select nvl(min(hh),0),nvl(min(hh_ll),0) into b_hh,b_hh_ll
    from tbh_hd_di_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt in(' ',b_ma_dt);
end;
/
create or replace procedure FTBH_HD_DI_NV_SO_ID(
    b_nv varchar2,b_lh_nv varchar2,b_ma_dt varchar2,b_ngay number,
    a_so_id out pht_type.a_num,a_pth out pht_type.a_var,a_pp out pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_pthuc varchar2(10); b_so_id number;
    b_ngayD number:=round(b_ngay,-4);
    a_id pht_type.a_num; a_pthuc pht_type.a_var;
begin
-- Dan - Hop dong tai di theo nv,lh_nv,ma_dt,ngay(hieu luc)
PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_id);
for r_lp in (select pthuc,max(ngay_bd) ngay from tbh_hd_di 
    where nv=b_nv and ngay_bd between b_ngayD and b_ngay group by pthuc) loop
    b_pthuc:=r_lp.pthuc;
    select so_id into b_so_id from tbh_hd_di where nv=b_nv and pthuc=b_pthuc and ngay_bd=r_lp.ngay;
    if FTBH_HD_DI_BO(b_so_id,b_lh_nv,b_ma_dt)='C' then
        select count(*) into b_i1 from tbh_hd_di_nv where so_id=b_so_id and lh_nv=b_lh_nv and ma_dt in(' ',b_ma_dt);
        if b_i1<>0 then
            b_i1:=a_id.count+1; a_id(b_i1):=b_so_id; a_pthuc(b_i1):=b_pthuc;
        end if;
    end if;
end loop;
if a_id.count<>0 then
    for r_lp in (select ma,pp from tbh_ma_pthuc order by bt) loop
        for b_lp in 1..a_id.count loop
            if a_pthuc(b_lp)=r_lp.ma then
                b_i1:=a_so_id.count+1;
                a_so_id(b_i1):=a_id(b_lp); a_pth(b_i1):=a_pthuc(b_lp); a_pp(b_i1):=r_lp.pp;
                exit;
            end if;
        end loop;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_HD_DI_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_HD_DI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from tbh_hd_di;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay_bd,nv,pthuc,nsd,so_id) returning clob) into cs_lke from
    (select ngay_bd,nv,pthuc,nsd,so_id,rownum sott from tbh_hd_di order by ngay_bd desc,nv,pthuc)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_HD_DI_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_so_id number; b_trangkt number; b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_trangkt using b_oraIn;
if b_so_id=0 then b_loi:='loi:Nhap so_id:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from tbh_hd_di;
select nvl(min(sott),b_dong) into b_tu from 
    (select so_id,rownum sott from tbh_hd_di order by ngay_bd desc,nv,pthuc,so_id)
    where so_id>=b_so_id;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(ngay_bd,nv,pthuc,nsd,so_id)) into cs_lke from
    (select ngay_bd,nv,pthuc,nsd,so_id,rownum sott from tbh_hd_di order by ngay_bd desc,nv,so_id)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_HD_DI_SO_ID(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number:=0; b_so_hd varchar2(20);
begin
-- Dan - Liet ke chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hd:=FKH_JS_GTRIs(b_oraIn,'so_hd');
if trim(b_so_hd) is not null then
	b_so_id:=FTBH_HD_DI_SO_ID(b_so_hd);
end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_HD_DI_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_nv varchar2(10);
    b_so_id number; cs_ct clob; cs_bh clob; cs_nv clob; cs_do clob; cs_ta clob; cs_ng clob; cs_uot clob; cs_txt clob;
begin
-- Dan - Liet ke chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Khai bao muc giu lai da xoa:loi';
select nv into b_nv from tbh_hd_di where so_id=b_so_id;
select json_object(so_hd) into cs_ct from tbh_hd_di where so_id=b_so_id;
select JSON_ARRAYAGG(json_object('nha_bh' value FBH_MA_NBH_TENl(nha_bh)) order by bt returning clob)
    into cs_bh from tbh_hd_di_nha_bh where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(
    'lh_nv' value FBH_MA_LHNV_TAI_TENf(lh_nv),'ma_dt' value FTBH_DTUONG_TENl(b_nv,ma_dt),
    'nguong' value nguongG,'glai' value glaiG,'glaiM' value glaiMG,
    'ghan' value ghanG,hh,hh_ll,tlp) order by lh_nv,ma_dt returning clob)
    into cs_nv from tbh_hd_di_nv where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(pt,hs_ng,hs_gl,hs_gh) order by pt returning clob) into cs_do from tbh_hd_di_do where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(pt,hs_ng,hs_gl,hs_gh) order by pt returning clob) into cs_ta from tbh_hd_di_ta where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_dt,tien,bth,ptG,hs) order by ma_dt,tien,bth,ptG returning clob) into cs_ng from tbh_hd_di_hsng where so_id=b_so_id;
select JSON_ARRAYAGG(json_object('lh_nv' value FBH_MA_LHNV_TAI_TENf(lh_nv),nguong,glai,ghan) order by lh_nv returning clob)
	into cs_uot from tbh_hd_di_uot where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into cs_txt from tbh_hd_di_txt where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_nv' value cs_nv,'dt_do' value cs_do,
	'dt_ta' value cs_ta,'dt_ng' value cs_ng,'dt_uot' value cs_uot,
	'dt_ct' value cs_ct,'dt_bh' value cs_bh,'txt' value cs_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_HD_DI_XOA_XOA
    (b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_nsdC varchar2(10); b_i1 number;
begin
-- Dan - Xoa
select count(*),min(nsd) into b_i1,b_nsdC from tbh_hd_di where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac '||b_nsd||'|'||b_nsdC||':loi'; return; end if;
delete tbh_hd_di_txt where so_id=b_so_id;
delete tbh_hd_di_nv where so_id=b_so_id;
delete tbh_hd_di_nha_bh where so_id=b_so_id;
delete tbh_hd_di_do where so_id=b_so_id;
delete tbh_hd_di_ta where so_id=b_so_id;
delete tbh_hd_di_hsng where so_id=b_so_id;
delete tbh_hd_di_uot where so_id=b_so_id;
delete tbh_hd_di where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_HD_DI_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_HD_DI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null or b_so_id=0 then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
PTBH_HD_DI_XOA_XOA(b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_HD_DI_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number; b_i2 number; b_pt number:=0;
    b_so_id number; b_so_hd varchar2(20); b_nv varchar2(10); b_pthuc varchar2(10); 
    b_ma_nt varchar2(5); b_ty_gia number; b_pbo_cp varchar2(1); b_ngay_bd number; b_ngay_kt number;

    bh_nha_bh pht_type.a_var; bh_pt pht_type.a_num; bh_hh pht_type.a_num; bh_hh_ll pht_type.a_num;
    bh_kieu pht_type.a_var; bh_nha_bhC pht_type.a_var;
    nv_lh_nv pht_type.a_var; nv_ma_dt pht_type.a_var;
    nv_nguong pht_type.a_num; nv_glai pht_type.a_num; nv_glaiM pht_type.a_num; nv_ghan pht_type.a_num;
    nv_hh pht_type.a_num; nv_hh_ll pht_type.a_num; nv_tlp pht_type.a_num;
    do_pt pht_type.a_num; do_hs_ng pht_type.a_num; do_hs_gl pht_type.a_num; do_hs_gh pht_type.a_num;
    ta_pt pht_type.a_num; ta_hs_ng pht_type.a_num; ta_hs_gl pht_type.a_num; ta_hs_gh pht_type.a_num;
    ng_ma_dt pht_type.a_var; ng_tien pht_type.a_num; ng_bth pht_type.a_num; ng_ptG pht_type.a_num; ng_hs pht_type.a_num;
    nv_nguongX pht_type.a_num; nv_glaiX pht_type.a_num; nv_glaiMX pht_type.a_num; nv_ghanX pht_type.a_num;
    uot_lh_nv pht_type.a_var; uot_nguong pht_type.a_num; uot_glai pht_type.a_num; uot_ghan pht_type.a_num;
    
    dt_ct clob; dt_bh clob; dt_nv clob; dt_do clob; dt_ta clob; dt_ng clob; dt_uot clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id<>0 then
    PTBH_HD_DI_XOA_XOA(b_nsd,b_so_id,b_loi);
else
    PHT_ID_MOI(b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh,dt_nv,dt_do,dt_ta,dt_ng,dt_uot');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh,dt_nv,dt_do,dt_ta,dt_ng,dt_uot using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_bh); FKH_JSa_NULL(dt_nv);
FKH_JSa_NULL(dt_do); FKH_JSa_NULL(dt_ta); FKH_JSa_NULL(dt_ng); FKH_JSa_NULL(dt_uot);
b_lenh:=FKH_JS_LENH('so_hd,nv,pthuc,ma_nt,ty_gia,pbo_cp,ngay_bd,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv,b_pthuc,b_ma_nt,b_ty_gia,b_pbo_cp,b_ngay_bd,b_ngay_kt using dt_ct;
if b_ngay_bd in(0,30000101) then
    b_loi:='loi:Sai ngay ap dung:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
if b_nv not in('XE','2B','HANG','NG','TAU','PHH','PKT','PTN') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Sai phuong thuc:loi';
if b_pthuc=' ' then raise PROGRAM_ERROR; end if;
select 0 into b_i1 from tbh_ma_pthuc where ma=b_pthuc;
b_loi:='loi:Sai ma nguyen te:loi';
if b_ma_nt=' ' then raise PROGRAM_ERROR; end if;
if b_ma_nt<>'VND' then
    select 0 into b_i1 from tt_ma_nt where ma=b_ma_nt;
end if;
if FTBH_HD_DI_SO_IDp(b_nv,b_pthuc,b_ngay_bd)<>0 then
    b_loi:='loi:Da khai bao hop dong tai co dinh:loi'; raise PROGRAM_ERROR;
end if;
b_lenh:=FKH_JS_LENH('nha_bh,pt,hh,hh_ll,kieu');
EXECUTE IMMEDIATE b_lenh bulk collect into bh_nha_bh,bh_pt,bh_hh,bh_hh_ll,bh_kieu using dt_bh;
b_loi:='loi:Sai so lieu nha bao hiem:loi';
if bh_nha_bh.count=0 then raise PROGRAM_ERROR; end if;
for b_lp in 1..bh_nha_bh.count loop
    if bh_nha_bh(b_lp)=' ' or bh_pt(b_lp)<0 or bh_hh(b_lp)<0 or bh_hh_ll(b_lp)<0 or
        bh_kieu(b_lp) not in('C','P','M') then raise PROGRAM_ERROR;
    end if;
end loop;
for b_lp in 1..bh_nha_bh.count loop
    if bh_kieu(b_lp)='C' then
        bh_nha_bhC(b_lp):=bh_nha_bh(b_lp);
    else
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in REVERSE 1..b_i1 loop
            if bh_kieu(b_lp1)='C' then b_i2:=b_lp1; exit; end if;
        end loop;
        if b_i2=0 then b_loi:='loi:Sai kieu nha bao hiem '||bh_nha_bh(b_lp)||':loi'; return; end if;
        bh_nha_bhC(b_lp):=bh_nha_bh(b_i2);
    end if;
    b_pt:=b_pt+bh_pt(b_lp);
end loop;
if b_pt>100 then b_loi:='loi:Tong cac nha tai: '||to_char(b_pt)||':loi'; return; end if;
b_lenh:=FKH_JS_LENH('lh_nv,ma_dt,nguong,glai,glaim,ghan,hh,hh_ll,tlp');
EXECUTE IMMEDIATE b_lenh bulk collect into
    nv_lh_nv,nv_ma_dt,nv_nguong,nv_glai,nv_glaiM,nv_ghan,nv_hh,nv_hh_ll,nv_tlp using dt_nv;
if nv_lh_nv.count=0 then
    b_loi:='loi:Nhap muc giu lai:loi'; raise PROGRAM_ERROR;
end if;
for b_lp in 1..nv_lh_nv.count loop
    b_loi:='loi:Sai chi tiet nghiep vu dong '||to_char(b_lp)||':loi';
    if nv_lh_nv(b_lp)=' ' then raise PROGRAM_ERROR; end if;
    if FBH_MA_LHNV_TAI_NV(nv_lh_nv(b_lp),b_nv)<>'C' then raise PROGRAM_ERROR; end if;
    if nv_ma_dt(b_lp)<> ' ' and FTBH_DTUONG_TEN(b_nv,nv_ma_dt(b_lp)) is null then
        raise PROGRAM_ERROR;
    end if;
    if nv_glaiM(b_lp)=0 then nv_glaiM(b_lp):=nv_glai(b_lp); end if;
end loop;
if trim(dt_do) is not null then
    b_lenh:=FKH_JS_LENH('pt,hs_ng,hs_gl,hs_gh');
    EXECUTE IMMEDIATE b_lenh bulk collect into do_pt,do_hs_ng,do_hs_gl,do_hs_gh using dt_do;
    for b_lp in 1..do_pt.count loop
        if do_pt(b_lp) not between 0 and 100 or do_hs_ng(b_lp) not between 0 and 100 or
            do_hs_gl(b_lp) not between 0 and 100 or do_hs_gh(b_lp) not between 0 and 100 then
            b_loi:='loi:Sai he so dong BH dong '||to_char(b_lp)||':loi';
            raise PROGRAM_ERROR;
        end if;
    end loop;
end if;
if trim(dt_ta) is not null then
    EXECUTE IMMEDIATE b_lenh bulk collect into ta_pt,ta_hs_ng,ta_hs_gl,ta_hs_gh using dt_ta;
    for b_lp in 1..ta_pt.count loop
        if ta_pt(b_lp) not between 0 and 100 or ta_hs_ng(b_lp) not between 0 and 100 or
            ta_hs_gl(b_lp) not between 0 and 100 or ta_hs_gh(b_lp) not between 0 and 100 then
            b_loi:='loi:Sai he so tai BH dong '||to_char(b_lp)||':loi';
            raise PROGRAM_ERROR;
        end if;
    end loop;
end if;
if trim(dt_ng) is not null then
    b_lenh:=FKH_JS_LENH('ma_dt,tien,bth,ptg,hs');
    EXECUTE IMMEDIATE b_lenh bulk collect into ng_ma_dt,ng_tien,ng_bth,ng_ptG,ng_hs using dt_ng;
end if;
if trim(dt_uot) is not null then
    b_lenh:=FKH_JS_LENH('lh_nv,nguong,glai,ghan');
    EXECUTE IMMEDIATE b_lenh bulk collect into uot_lh_nv,uot_nguong,uot_glai,uot_ghan using dt_uot;
end if;
b_loi:='loi:Loi Table tbh_hd_di:loi';
insert into tbh_hd_di values(b_ma_dvi,b_so_id,b_so_hd,b_nv,b_pthuc,b_ma_nt,b_ty_gia,b_pbo_cp,b_ngay_bd,b_ngay_kt,b_nsd);
for b_lp in 1..bh_nha_bh.count loop
    insert into tbh_hd_di_nha_bh values(
        b_ma_dvi,b_so_id,b_lp,bh_nha_bh(b_lp),bh_pt(b_lp),bh_hh(b_lp),bh_hh_ll(b_lp),bh_kieu(b_lp),bh_nha_bhC(b_lp));
end loop;
if b_ma_nt='VND' then
    for b_lp in 1..nv_lh_nv.count loop
        nv_nguongX(b_lp):=nv_nguong(b_lp); nv_ghanX(b_lp):=nv_ghan(b_lp);
        nv_glaiX(b_lp):=nv_glai(b_lp); nv_glaiMX(b_lp):=nv_glaiM(b_lp); 
    end loop;
else
    if b_ty_gia<>0 then b_i1:=1;
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_bd,b_ma_nt);
    end if;
    for b_lp in 1..nv_lh_nv.count loop
        nv_nguongX(b_lp):=round(nv_nguong(b_lp)*b_i1,0);
        nv_ghanX(b_lp):=round(nv_ghan(b_lp)*b_i1,0);
        nv_glaiX(b_lp):=round(nv_glai(b_lp)*b_i1,0);
        nv_glaiMX(b_lp):=round(nv_glaiM(b_lp)*b_i1,0);
    end loop;
end if;
forall b_lp in 1..nv_lh_nv.count
    insert into tbh_hd_di_nv values(b_ma_dvi,b_so_id,nv_lh_nv(b_lp),nv_ma_dt(b_lp),
        nv_nguongX(b_lp),nv_glaiX(b_lp),nv_glaiMX(b_lp),nv_ghanX(b_lp),
        nv_hh(b_lp),nv_hh_ll(b_lp),nv_tlp(b_lp),nv_nguong(b_lp),nv_glai(b_lp),nv_glaiM(b_lp),nv_ghan(b_lp));
if trim(dt_do) is not null then
    forall b_lp in 1..do_pt.count
        insert into tbh_hd_di_do values(b_ma_dvi,b_so_id,do_pt(b_lp),do_hs_ng(b_lp),do_hs_gl(b_lp),do_hs_gh(b_lp));
end if;
if trim(dt_ta) is not null then
    forall b_lp in 1..ta_pt.count
        insert into tbh_hd_di_ta values(b_ma_dvi,b_so_id,ta_pt(b_lp),ta_hs_ng(b_lp),ta_hs_gl(b_lp),ta_hs_gh(b_lp));
end if;
if trim(dt_ng) is not null then
    forall b_lp in 1..ng_ma_dt.count
        insert into tbh_hd_di_hsng values(b_ma_dvi,b_so_id,ng_ma_dt(b_lp),ng_tien(b_lp),ng_bth(b_lp),ng_ptG(b_lp),ng_hs(b_lp));
end if;
if trim(dt_ng) is not null then
    forall b_lp in 1..uot_lh_nv.count
        insert into tbh_hd_di_uot values(b_ma_dvi,b_so_id,uot_lh_nv(b_lp),uot_nguong(b_lp),uot_glai(b_lp),uot_ghan(b_lp));
end if;
insert into tbh_hd_di_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into tbh_hd_di_txt values(b_ma_dvi,b_so_id,'dt_bh',dt_bh);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
