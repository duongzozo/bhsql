/*** Chi phi khac tai ***/
create or replace function FTBH_CP_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from tbh_cp_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from tbh_cp_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FTBH_CP_SO_ID(b_so_ct varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra so Id qua so ct
if trim(b_so_ct) is not null then
    select nvl(min(so_id),0) into b_kq from tbh_cp where so_ct=b_so_ct;
end if;
return b_kq;
end;
/
create or replace function FTBH_CP_SO_CT(b_so_id number) return varchar2
AS
    b_kq varchar2(20):='';
begin
-- Dan - Tra so ct qua so id
if b_so_id<>0 then
    select min(so_ct) into b_kq from tbh_cp where so_id=b_so_id;
end if;
return b_kq;
end;
/
create or replace PROCEDURE PTBH_CP_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_ct varchar2(20); b_so_id number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_ct:=FKH_JS_GTRIs(b_oraIn,'so_ct');
b_so_id:=FTBH_CP_SO_ID(b_so_ct);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_CP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngayD number; b_ngayC number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_cp where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(
			ngay_ht,so_ct,ma_nt,ttoan,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
			order by so_id desc returning clob) into cs_lke from
            (select ngay_ht,so_ct,nha_bh,ma_nt,ttoan,so_id,rownum sott from tbh_cp where 
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from tbh_cp where ngay_ht between b_ngayD and b_ngayC;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(
			ngay_ht,so_ct,ma_nt,ttoan,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
			order by so_id desc returning clob) into cs_lke from
            (select ngay_ht,so_ct,nha_bh,ma_nt,ttoan,so_id,rownum sott from tbh_cp where 
            ngay_ht between b_ngayD and b_ngayC order by so_id desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_CP_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngayD number; b_ngayC number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngayd,ngayc,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngayD,b_ngayC,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from tbh_cp where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from tbh_cp where
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(
		ngay_ht,so_ct,ma_nt,ttoan,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
		order by so_id desc returning clob) into cs_lke from
        (select ngay_ht,so_ct,nha_bh,ma_nt,ttoan,so_id,rownum sott from tbh_cp where 
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_cp where ngay_ht between b_ngayD and b_ngayC;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from tbh_cp where
        ngay_ht between b_ngayD and b_ngayC order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(
		ngay_ht,so_ct,ma_nt,ttoan,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
		order by so_id desc returning clob) into cs_lke from
        (select ngay_ht,so_ct,nha_bh,ma_nt,ttoan,so_id,rownum sott from tbh_cp where 
        ngay_ht between b_ngayD and b_ngayC order by so_id desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_CP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Thu, chi khac tai da xoa:loi';
select json_object(so_ct,'ma_tke' value FBH_CP_TKE_TENl(ma_tke),'nha_bh' value FBH_MA_NBH_TENl(nha_bh))
    into dt_ct from tbh_cp where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt from tbh_cp_txt where so_id=b_so_id and loai='dt_ct';
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_CP_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(200); cs_lke clob:=''; b_nha_bh varchar2(20);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); b_ngayD number; b_ngayC number;
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in(0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,ma_nt,ttoan,so_id,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
    order by ngay_ht desc,nha_bh returning clob) into cs_lke from
    (select ngay_ht,so_ct,nha_bh,ma_nt,ttoan,so_id from tbh_cp where
    ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',nha_bh)
    order by ngay_ht desc,nha_bh)
    where rownum<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_CP_TEST
	(b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,
	b_ngay_ht out number,b_so_ct out varchar2,b_l_ct out varchar2,b_nha_bh out varchar2,
	b_nv out varchar2,b_ma_tke out varchar2,b_dvi out varchar2,b_so_hd out varchar2,
	b_so_hs out varchar2,b_ma_nt out varchar2,b_so_don out varchar2,
	b_tien out number,b_thue out number,
	b_tien_qd out number,b_thue_qd out number,b_loi out varchar2)
AS
	b_i1 number; b_lenh varchar2(2000);
begin
-- Dan - Kiem tra thong tin nhap chi phi khac
b_lenh:=FKH_JS_LENH('ngay_ht,so_ct,l_ct,nha_bh,nv,ma_tke,so_hd,so_hd,ma_nt,so_don,tien,thue');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_ct,b_l_ct,b_nha_bh,b_nv,b_ma_tke,b_so_hd,b_so_hd,b_ma_nt,b_so_don,b_tien,b_thue using dt_ct;
if b_ngay_ht in(0,30000101) or b_l_ct not in('TD','TV','CD','CV') or b_ma_nt=' ' or
	b_nv not in ('HANG','2B','XE','PHH','PKT','PTN','TAU','BAY','NG','SK','PHO','PNA','KH') then
    b_loi:='loi:So lieu nhap sai:loi'; return;
end if;
if b_ma_tke=' ' then
    b_loi:='loi:Chon ma thong ke:loi'; return;
elsif FBH_CP_TKE_HAN(b_ma_tke)<>'C' then b_loi:='loi:Sai ma thong ke:loi'; return;
elsif FBH_CP_TKE_LOAI(b_ma_tke)<>substr(b_l_ct,1,1) then b_loi:='loi:Sai loai ma thong ke:loi'; return;
end if;
if b_so_hd<>' ' then
    b_dvi:=FBH_HD_MA_DVIh(b_so_hd);
    if b_dvi=' ' then b_loi:='loi:So hop dong da xoa:loi'; return; end if;
end if;
if b_so_hs<>' ' then
    b_dvi:=FBH_BT_MA_DVIh(b_so_hs);
    if b_dvi=' ' then b_loi:='loi:So ho so da xoa:loi'; return; end if;
end if;
b_loi:='loi:Sai ma nha bao hiem:loi';
if b_nha_bh=' ' then return;
else select 0 into b_i1 from bh_ma_nbh where ma=b_nha_bh;
end if;
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
else
    b_loi:='loi:Ma ngoai te chua dang ky:loi';
    select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt;
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    b_tien_qd:=round(b_i1*b_tien,0); b_thue_qd:=round(b_i1*b_thue,0);
end if;
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_CP_XOA_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
	r_hd tbh_cp%rowtype; b_so_id_hd number;
begin
-- Dan - Xoa chi phi
b_loi:='loi:Chung tu dang xu ly:loi';
select * into r_hd from tbh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nsd<>r_hd.nsd then b_loi:='loi:Khong xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hd.ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
if r_hd.so_hd is not null then
	select nvl(min(so_id_hd),0) into b_so_id_hd from tbh_cp_pt where so_id=b_so_id;
	if FTBH_PS(r_hd.dvi,b_so_id_hd,b_so_id)<>0 then b_loi:='loi:Khong xoa thu, chi khac da xu ly tai BH:loi'; return; end if;
end if;
b_loi:='loi:Loi Table BH_CP:loi';
delete tbh_cp_txt where so_id=b_so_id;
delete tbh_cp_pt where so_id=b_so_id;
delete tbh_cp where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_CP_PT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_dvi varchar2(20); b_so_hd varchar2(50); b_so_id_bt number:=0; b_so_id_hd number;
    b_ngay_ht number; b_l_ct varchar2(10); b_nv varchar2(10); b_ma_tke varchar2(10); b_ma_nt varchar2(5);
    b_tien number; b_tien_qd number; b_thue number; b_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
Begin
-- Dan - Phan tich
select dvi,so_hd,ma_nt,tien,tien_qd,thue,thue_qd,ngay_ht,l_ct,nv,ma_tke
    into b_dvi,b_so_hd,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,b_ngay_ht,b_l_ct,b_nv,b_ma_tke
    from tbh_cp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if trim(b_so_hd) is null or b_dvi is null then
    insert into tbh_cp_pt values(b_ma_dvi,b_so_id,' ',0,0,b_ngay_ht,
        b_l_ct,b_nv,b_ma_tke,' ',b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd);
    b_loi:=''; return;
end if;
b_so_id_hd:=FBH_HD_GOC_SO_ID(b_dvi,b_so_hd);
if b_so_id_hd=0 then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
PBH_HD_PT(b_dvi,b_so_id_hd,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
    a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
if b_loi is not null then return; end if;
forall b_lp in 1..a_so_id_dt.count
    insert into tbh_cp_pt values(b_ma_dvi,b_so_id,b_dvi,b_so_id_hd,a_so_id_dt(b_lp),b_ngay_ht,
        b_l_ct,b_nv,b_ma_tke,a_lh_nv(b_lp),b_ma_nt,a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CP_PT:loi'; end if;
end;
/
create or replace procedure PTBH_CP_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); dt_ct clob; 
    b_so_id number; b_ngay_ht number; b_so_ct varchar2(20); b_l_ct varchar2(10);
    b_nha_bh varchar2(20); b_nv varchar2(10); b_ma_tke varchar2(10); b_dvi varchar2(10);
    b_so_hd varchar2(20); b_so_hs varchar2(20); b_ma_nt varchar2(5); b_so_don varchar2(20);
    b_tien number; b_thue number; b_tien_qd number; b_thue_qd number;
begin
-- Dan - Nhap chi chi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id=0 then PHT_ID_MOI(b_so_id,b_loi);
else PTBH_CP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
dt_ct:=FKH_JS_GTRIc(b_oraIn,'dt_ct'); FKH_JS_NULL(dt_ct);
PTBH_CP_TEST(b_ma_dvi,b_so_id,dt_ct,
    b_ngay_ht,b_so_ct,b_l_ct,b_nha_bh,b_nv,b_ma_tke,b_dvi,b_so_hd,b_so_hs,
    b_ma_nt,b_so_don,b_tien,b_thue,b_tien_qd,b_thue_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table TBH_CP:loi';
insert into tbh_cp values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_ct,b_nha_bh,b_nv,b_ma_tke,b_dvi,b_so_hd,b_so_hs,
    b_ma_nt,b_tien,b_thue,b_tien+b_thue,b_tien_qd,b_thue_qd,b_tien_qd+b_thue_qd,b_so_don,b_nsd,sysdate,0);
insert into tbh_cp_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if trim(b_so_hd) is not null then
    PTBH_CP_PT(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PTBH_TH_TA_CPT(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PTBH_CP_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
	b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa tam ung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PTBH_CP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
