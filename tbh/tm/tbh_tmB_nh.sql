-- Chao tai tam
create or replace function FTBH_TMB_NH_DT(
    b_nv varchar2,b_kieu varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_dk varchar2:='K') return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten doi tuong
if b_nv='PHH' then
	if b_kieu='B' then
		b_kq:=FBH_PHHB_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
	else
		b_kq:=FBH_PHH_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
	end if;
elsif b_nv='PKT' then
	if b_kieu='B' then
	    b_kq:=FBH_PKTB_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
	else
	    b_kq:=FBH_PKT_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
	end if;
end if;
if b_kq is not null and b_dk='C' then b_kq:=to_char(b_so_id_dt)||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace function FTBH_TMB_KIEU(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2) return varchar2
as
    b_kq varchar2(1):=' ';
begin
if FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id)<>' ' then b_kq:='H';
elsif FTBH_SOAN_SO_HD(b_ma_dvi,b_so_id,b_nv)<>' ' then b_kq:='T';
elsif FBH_BAO_SO_HD(b_ma_dvi,b_so_id)<>' ' then b_kq:='B';
end if;
return b_kq;
exception when others then return '';
end;
/
create or replace function FTBH_TMB_SO_HD(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_kieu varchar2) return varchar2
as
    b_kq varchar2(20):='';
begin
if b_kieu='B' then
    b_kq:=FBH_BAO_SO_HD(b_ma_dvi,b_so_id);
elsif b_kieu='T' then
    b_kq:=FTBH_SOAN_SO_HD(b_ma_dvi,b_so_id,b_nv);
else
    b_kq:=FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id);
end if;
return b_kq;
exception when others then return '';
end;
/
create or replace function FTBH_TMB_SO_ID_DAU(b_so_id number) return number
AS
    b_so_idD number;
begin
-- Dan - Tra so ID tai dau
select nvl(min(so_id_d),0) into b_so_idD from tbh_tmB where so_id=b_so_id;
return b_so_idD;
end;
/
create or replace function FTBH_TMB_SO_BS(b_so_id number) return varchar2
AS
    b_so_idD number; b_so_ct varchar2(20); b_so_bs varchar2(20); b_stt number; b_i1 number:=1; 
begin
-- Dan - Tra so sua doi bo sung
b_so_idD:=FTBH_TMB_SO_ID_DAU(b_so_id);
select min(so_ct),count(*) into b_so_ct,b_stt from tbh_tmB where so_id_d=b_so_idD;
while b_i1<>0 loop
     b_so_bs:=b_so_ct||'/'||'BS'||trim(to_char(b_stt));
     select count(*) into b_i1 from tbh_tmB where so_ct=b_so_bs;
     b_stt:=b_stt+1;
end loop;
return b_so_bs;
end;
/
create or replace function FTBH_TMB_CBI_TT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_kieu_xl varchar2(1);
begin
-- Dan - Tra tinh trang co tai tam
select min(kieu_xl),count(*) into b_kieu_xl,b_i1
    from tbh_tmB_cbi where ma_dviP=b_ma_dvi and so_idP=b_so_id;
if b_i1<>0 then
    if b_kieu_xl='C' then b_kq:='D'; else b_kq:='V'; end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_TMB_SO_CT(b_so_ct varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID
select nvl(min(so_id),0) into b_kq from tbh_tmB where so_ct=b_so_ct;
return b_kq;
end;
/
create or replace function FTBH_TMB_TEN(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_dk varchar2:='K') return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten doi tuong
if b_nv='PHH' then
    b_kq:=FBH_PHHB_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
elsif b_nv='PKT' then
    b_kq:=FBH_PKTB_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
elsif b_nv='XE' then
    b_kq:=FBH_XEB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
elsif b_nv='2B' then
    b_kq:=FBH_2BB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
elsif b_nv='TAU' then
    b_kq:=FBH_TAUB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
end if;
if b_kq is not null and b_dk='C' then b_kq:=to_char(b_so_id_dt)||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace procedure PTBH_TMB_DTt(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_nv varchar2(10); b_lenh varchar2(2000); b_c clob;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number;
    b_kieu_ps varchar2(1); b_so_hd varchar2(20); b_ten nvarchar2(500);
    a_ma_dvi pht_type.a_var; a_kieu pht_type.a_var; a_so_hd pht_type.a_var;
    a_ten pht_type.a_nvar; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Danh sach doi tuong ghep
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt using b_oraIn;
PTBH_TM_TTIN(b_ma_dvi,b_so_id,b_kieu_ps,b_nv,b_so_hd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:='';
if b_nv='PHH' then
    PTBH_BAO_TAO_PHHt(b_ma_dvi,b_so_id,b_so_id_dt,a_ma_dvi,a_kieu,a_so_hd,a_ten,a_so_id,a_so_id_dt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
elsif b_nv='PKT' then
    PTBH_BAO_TAO_PKTt(b_ma_dvi,b_so_id,b_so_id_dt,a_ma_dvi,a_kieu,a_so_hd,a_ten,a_so_id,a_so_id_dt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
elsif b_nv='HANG' then
    PTBH_BAO_TAO_HANG(b_ma_dvi,b_so_id,a_ma_dvi,a_kieu,a_so_hd,a_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    for b_lp in 1..a_ma_dvi.count loop
        a_ten(b_lp):=' '; a_so_id_dt(b_lp):=' ';
    end loop;
else
    b_ten:=' '; a_kieu(1):=b_kieu_ps;
    if b_kieu_ps='H' then
        if b_nv='2B' then b_ten:=FBH_2B_BIEN(b_ma_dvi,b_so_id,b_so_id_dt);
        elsif b_nv='XE' then b_ten:=FBH_XE_BIEN(b_ma_dvi,b_so_id,b_so_id_dt);
        elsif b_nv='TAU' then b_ten:=FBH_TAU_BIEN(b_ma_dvi,b_so_id,b_so_id_dt);
        end if;
    else        
        if b_nv='2B' then b_ten:=FBH_2BB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
        elsif b_nv='XE' then b_ten:=FBH_XEB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
        elsif b_nv='TAU' then b_ten:=FBH_TAUB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
        end if;
    end if;
    a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=b_so_id_dt; a_so_hd(1):=b_so_hd; a_ten(1):=b_ten;
end if;
for b_lp in 1..a_ma_dvi.count loop
    select json_object('ma_dvi_hd' value a_ma_dvi(b_lp),'kieu' value a_kieu(b_lp),'so_hd' value a_so_hd(b_lp),
        'so_id_hd' value a_so_id(b_lp),'so_id_dt' value to_char(a_so_id_dt(b_lp))||'|'||a_ten(b_lp) returning clob) into b_c from dual;
    PKH_GHEPc(b_oraOut,b_c);
end loop;
b_oraOut:='['||b_oraOut||']';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_i2 number; b_lenh varchar2(2000);
    b_so_id number; b_vuot number; b_ngay_hl number; b_ngay_kt number;
    b_ma_ta varchar2(200); b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_vt number; b_tpT number:=0; b_tpP number:=0; b_tien number; b_phi number; b_pt number;
    b_tl_thue number; b_thue number; b_hhong number; b_nv varchar2(10);

    a_nbh pht_type.a_var; a_nbh_pt pht_type.a_num; a_nbh_hh pht_type.a_num;
    a_nbh_kieu pht_type.a_var; a_nbhC pht_type.a_var;
    a_ma_taC pht_type.a_var; a_ptC pht_type.a_num; a_tienC pht_type.a_num;
    a_ma_ta pht_type.a_var; a_tien pht_type.a_num; a_phi pht_type.a_num;
    a_do_tl pht_type.a_num; a_ta_tl pht_type.a_num; a_ve_tl pht_type.a_num;
    a_do_tien pht_type.a_num; a_ta_tien pht_type.a_num; a_ve_tien pht_type.a_num;

    dt_ct clob; dt_hd clob; dt_bh clob; cs_nv clob:=''; cs_mata clob:=''; cs_phi clob:=''; cs_nbh clob:=''; 
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_tl_temp; delete tbh_ghep_phi_temp; delete tbh_ghep_nv_temp0 commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd,dt_bh using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd); FKH_JSa_NULL(dt_bh);
b_lenh:=FKH_JS_LENH('ma_ta,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_ta,b_nv using dt_ct;
b_lenh:=FKH_JS_LENH('nbh,pt,hh,kieu');
EXECUTE IMMEDIATE b_lenh bulk collect into a_nbh,a_nbh_pt,a_nbh_hh,a_nbh_kieu using dt_bh;
for b_lp in 1..a_nbh.count loop
    if a_nbh_kieu(b_lp)='C' then
        a_nbhC(b_lp):=a_nbh(b_lp);
    else
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in REVERSE 1..b_i1 loop
            if a_nbh_kieu(b_lp1)='C' then b_i2:=b_lp1; exit; end if;
        end loop;
        if b_i2=0 then b_loi:='loi:Sai kieu nha bao hiem '||a_nbh(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
        a_nbhC(b_lp):=a_nbh(b_i2);
    end if;
    b_pt:=b_pt+a_nbh_pt(b_lp);
end loop;
if b_pt=0 then b_loi:=''; return; end if;
if b_pt>100 then b_loi:='loi:Tai vuot 100%:loi'; raise PROGRAM_ERROR; end if;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
FTBH_TMB_VUOT(b_so_id,dt_ct,dt_hd,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_i1,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_ta<>'#' then
    if b_nv<>'NG' then
        delete tbh_ghep_tl_temp where pthuc<>'O' and instr(b_ma_ta,ma_ta)=0;
    else
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc<>'O';
        if b_i1=0 then delete tbh_ghep_tl_temp; end if;
    end if;
end if;
select distinct ma_ta BULK COLLECT into a_ma_taC from tbh_ghep_tl_temp order by ma_ta;
if a_ma_taC.count=0 then b_loi:='loi:Khong vuot tai co dinh:loi'; raise PROGRAM_ERROR; end if;
select ma_ta,tien,phi,do_tien,do_tl,ta_tien+tm_tien,ta_tl+tm_tl,ve_tien,ve_tl BULK COLLECT into
    a_ma_ta,a_tien,a_phi,a_do_tien,a_do_tl,a_ta_tien,a_ta_tl,a_ve_tien,a_ve_tl
    from tbh_ghep_nv_temp order by ma_ta;
for b_lp in 1..a_nbh.count loop
    for b_lp1 in 1..a_ma_taC.count loop
        b_vt:=FKH_ARR_VTRI(a_ma_ta,a_ma_taC(b_lp1));
        if b_vt=0 then continue; end if;
        b_pt:=a_nbh_pt(b_lp); b_tien:=round(a_tien(b_vt)*b_pt/100,b_tpT);
        b_phi:=round(a_phi(b_vt)*b_pt/100,b_tpP); b_hhong:=round(b_phi*a_nbh_hh(b_lp)/100,b_tpP);
        b_i1:=b_phi-b_hhong;
        PTBH_PBO_NOP(a_ma_taC(b_lp1),a_nbh(b_lp),b_ngay_hl,b_i1,b_tpT,b_tl_thue,b_thue,b_loi,'T');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        insert into tbh_ghep_phi_temp values(
            '',a_ma_taC(b_lp1),a_nbh(b_lp),b_pt,b_tien,b_phi,b_tl_thue,b_thue,a_nbh_hh(b_lp),b_hhong);
        a_ta_tien(b_vt):=a_ta_tien(b_vt)+b_tien;
        a_ta_tl(b_vt):=a_ta_tl(b_vt)+b_pt;
    end loop;
end loop;
delete tbh_ghep_nv_temp0;
for b_lp in 1..a_ma_ta.count loop
    a_ta_tl(b_lp):=round(a_ta_tien(b_lp)*100/a_tien(b_lp),4);
    if a_do_tien(b_lp)<>0 then
        a_ptC(b_lp):=100-a_do_tl(b_lp)-a_ta_tl(b_lp)+a_ve_tl(b_lp);
        a_tienC(b_lp):=a_tien(b_lp)-a_do_tien(b_lp)-a_ta_tien(b_lp)+a_ve_tien(b_lp);
    elsif a_ve_tien(b_lp)<>0 then
        a_ptC(b_lp):=a_ve_tl(b_lp)-a_ta_tl(b_lp);
        a_tienC(b_lp):=a_ve_tien(b_lp)-a_ta_tien(b_lp);
    else
        a_ptC(b_lp):=100-a_ta_tl(b_lp);
        a_tienC(b_lp):=a_tien(b_lp)-a_ta_tien(b_lp);
    end if;
    insert into tbh_ghep_nv_temp0 values(a_ma_ta(b_lp),a_tien(b_lp),a_phi(b_lp),a_ptC(b_lp),a_tienC(b_lp),
        a_ta_tl(b_lp),a_ta_tien(b_lp),a_do_tl(b_lp),a_do_tien(b_lp),a_ta_tl(b_lp),a_ta_tien(b_lp),
        0,0,a_ve_tl(b_lp),a_ve_tien(b_lp),a_ptC(b_lp),a_tienC(b_lp));
end loop;
select JSON_ARRAYAGG(json_object(*) order by ma_ta returning clob) into cs_nv from tbh_ghep_nv_temp0;
select JSON_ARRAYAGG(json_object('ma' value ma_ta,'ten' value FBH_MA_LHNV_TAI_TEN(ma_ta)) order by ma_ta) into cs_mata from
    (select distinct ma_ta from tbh_ghep_nv_temp0);
select JSON_ARRAYAGG(json_object('ten' value FBH_MA_NBH_TEN(nha_bh),ma_ta,pt,tien,phi,tl_thue,thue,pt_hh,hhong,'nbh' value nha_bh)
    order by nha_bh,ma_ta returning clob) into cs_phi from tbh_ghep_phi_temp;
--Nam: gan 'nha_bh' value nha_bh
select JSON_ARRAYAGG(json_object('nha_bh' value nha_bh,'phi' value phi,'hhong' value hhong) returning clob) into cs_nbh from
    (select nha_bh,sum(phi) phi,sum(hhong) hhong from tbh_ghep_phi_temp group by nha_bh);
select json_object('cs_nv' value cs_nv,'cs_mata' value cs_mata,
    'cs_phi' value cs_phi,'cs_nbh' value cs_nbh returning clob) into b_oraOut from dual;
delete tbh_ghep_tl_temp; delete tbh_ghep_phi_temp;
delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp0; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_CH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_idP number,b_loi out varchar2)
AS
    b_i1 number; b_ch varchar2(1):='K'; b_so_ct varchar2(20);
    b_oraIn clob; b_oraOut clob; b_txt clob;
    b_so_idD number; b_nv varchar2(10);
    b_so_id number; b_so_id_dt number; b_dvi_ta varchar2(20):=FTBH_DVI_TA();
    dt_ct clob; dt_hd clob; dt_bh clob; dt_phi clob;
    a_ma_dvi_xl pht_type.a_var; a_so_id_xl pht_type.a_num;
begin
-- Dan - Chuyen TMB => TM
for r_lp in (select so_id,so_id_dtP from tbh_tmB where ma_dviP=b_ma_dvi and so_idP=b_so_idP) loop
    b_so_id:=r_lp.so_id; b_so_id_dt:=r_lp.so_id_dtP;
    select txt into b_txt from tbh_tmB_txt where so_id=b_so_id and loai='dt_ct';
    dt_ct:=FKH_JS_BONH(b_txt);
    select txt into b_txt from tbh_tmB_txt where so_id=b_so_id and loai='dt_bh';
    dt_bh:=FKH_JS_BONH(b_txt);
    select txt into b_txt from tbh_tmB_txt where so_id=b_so_id and loai='dt_phi';
    dt_phi:=FKH_JS_BONH(b_txt);
    --Nam: gan key
    select JSON_ARRAYAGG(json_object('ma_dvi_hd' value ma_dvi_hd,'so_hd' value FBH_HD_GOC_SO_HD(ma_dvi_hd,so_id_hd),
        'so_id_hd' value so_id_hd,'so_id_dt' value so_id_dt,'bt' value bt) order by bt returning clob) into dt_hd from tbh_tmB_hd where so_id=b_so_id;
    select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,
        'dt_hd' value dt_hd,'dt_bh' value dt_bh,'dt_phi' value dt_phi returning clob) into b_oraIn from dual;
    PTBH_TM_NHc(b_ma_dvi,b_nsd,b_oraIn,b_i1,b_so_ct,b_loi);
    if b_loi is not null then return; end if;
    b_ch:='C';
end loop;
if b_ch='K' then
    PTBH_GHEP_CONk(b_ma_dvi,b_so_idP,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CH:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_nv varchar2(10); b_ngayD number; b_ngayC number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_klk,b_tu,b_den using b_oraIn;
if b_klk='C' then
    select count(*) into b_dong from tbh_tmB_cbi where ngay_ht between b_ngayD and b_ngayC and nv=b_nv and kieu_xl='C';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,'ma_dvi' value ma_dviP,
        'so_ct' value FTBH_TMB_SO_HD(ma_dviP,so_idP,nv,kieu_ps))) into cs_lke from
        (select so_id,ma_dviP,so_idP,nv,kieu_ps,rownum sott from tbh_tmB_cbi where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv and kieu_xl='C' order by ma_dviP,so_ct)
        where sott between b_tu and b_den;
elsif b_klk='K' then
    select count(*) into b_dong from tbh_tmB_cbi where ngay_ht between b_ngayd and b_ngayc and nv=b_nv and kieu_xl='K';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,'ma_dvi' value ma_dviP,
        'so_ct' value FTBH_TMB_SO_HD(ma_dviP,so_idP,nv,kieu_ps))) into cs_lke from
        (select so_id,ma_dviP,so_idP,nv,kieu_ps,rownum sott from tbh_tmB_cbi where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv and kieu_xl='K' order by ma_dviP,so_ct)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_tmB where ngay_ht between b_ngayd and b_ngayc and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
        (select so_id,PKH_SO_CNG(ngay_ht) ma_dvi,so_ct,rownum sott from tbh_tmB where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv order by ngay_ht desc,so_ct desc)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000);
    b_so_ct varchar2(20); b_ngayD number; b_ngayC number; b_nv varchar2(10); b_trangKt number;
    b_dong number; cs_lke clob; b_tu number; b_den number; b_trang number;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_ct,ngayd,ngayc,nv,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_ct,b_ngayD,b_ngayC,b_nv,b_trangKt using b_oraIn;
select count(*) into b_dong from tbh_tmB where ngay_ht between b_ngayd and b_ngayc and nv=b_nv;
select nvl(min(sott),b_dong) into b_tu from
    (select so_ct,rownum sott from tbh_tmB where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv order by ngay_ht desc,so_ct desc)
    where so_ct<=b_so_ct;
PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
    (select so_id,PKH_SO_CNG(ngay_ht) ma_dvi,so_ct,rownum sott from tbh_tmB where
    ngay_ht between b_ngayd and b_ngayc and nv=b_nv order by ngay_ht desc,so_ct desc)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_SO_CT(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_so_ct varchar2(20):=trim(b_oraIn); b_so_id number:=0;
begin
-- Dan - Tra so ID qua so CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_ct is not null then b_so_id:=FTBH_TMB_SO_CT(b_so_ct); end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- chuclh: json tra ve chu hoa
create or replace procedure PTBH_TMB_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_so_id number; b_kieu_ps varchar2(1);
    b_ma_dviP varchar2(10); b_so_idP number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    dt_ct clob:=''; dt_hd clob:=''; dt_bh clob:='';
    dt_phi clob:=''; dt_nbhP clob:=''; dt_txt clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Xu ly da xoa:loi';
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
select count(*) into b_i1 from tbh_tmB where so_id=b_so_id;
if b_i1<>0 then
    select json_object('so_ct' value so_ct) into dt_ct from tbh_tmB where so_id=b_so_id;
    select JSON_ARRAYAGG(json_object('kieu' value kieu,'ma_dvi_hd' value ma_dvi_hd,'so_hd' value so_hd,'so_id_hd' value so_id_hd,
        'so_id_dt' value to_char(so_id_dt)||'|'||ten returning clob) order by bt returning clob)
        into dt_hd from tbh_tmB_hd where so_id=b_so_id;
    select JSON_ARRAYAGG(json_object('nbh' value FBH_MA_NBH_TENl(nbh),'kieu' value kieu,'pt' value pt,'hh' value hh) order by bt)
        into dt_bh from tbh_tmB_nbh where so_id=b_so_id;
    select JSON_ARRAYAGG(json_object(
        'ten' value FBH_MA_NBH_TEN(nbh),'ma_ta' value ma_ta,'pt' value pt,'tien' value tien,'phi' value phi,
        'tl_thue' value tl_thue,'thue' value thue,'pt_hh' value pt_hh,'hhong' value hhong,'nbh' value nbh) order by nbh,ma_ta)
        into dt_phi from tbh_tmB_phi where so_id=b_so_id;
    select JSON_ARRAYAGG(json_object('nbh' value nbh,'phi' value phi,'hhong' value hhong) returning clob) into dt_nbhP from
        (select nbh,sum(phi) phi,sum(hhong) hhong from tbh_tmB_phi where so_id=b_so_id group by nbh);
    select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
        from tbh_tmB_txt where so_id=b_so_id and loai='dt_ct';
else
    select count(*) into b_i1 from tbh_tmB_cbi where so_id=b_so_id;
    if b_i1=0 then raise PROGRAM_ERROR; end if;
    select kieu_ps,ma_dviP,so_idP into b_kieu_ps,b_ma_dviP,b_so_idP from tbh_tmB_cbi where so_id=b_so_id;
    if b_kieu_ps='B' then
        select nvl(min(nt_tien),'VND'),nvl(min(nt_phi),'VND') into b_nt_tien,b_nt_phi
            from bh_bao where ma_dvi=b_ma_dviP and so_id=b_so_idP;
    else
        select nvl(min(nt_tien),'VND'),nvl(min(nt_phi),'VND') into b_nt_tien,b_nt_phi
            from bh_hd_goc where ma_dvi=b_ma_dviP and so_id=b_so_idP;
    end if;
    select json_object('nv' value nv,'ngay_ht' value ngay_ht,'so_ct' value so_ct,'so_ctG' value so_ctG,
                       'nd' value nd,'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi)
        into dt_ct from tbh_tmB_cbi where so_id=b_so_id;
    select JSON_ARRAYAGG(json_object('kieu' value kieu,'ma_dvi_hd' value ma_dvi_hd,'so_hd' value so_hd,
                                     'so_id_hd' value so_id_hd,'so_id_dt' value to_char(so_id_dt)||'|'||ten returning clob) order by bt returning clob)
        into dt_hd from tbh_tmB_cbi_hd where so_id=b_so_id;
    select JSON_ARRAYAGG(json_object('nbh' value FBH_MA_NBH_TENl(nbh),'kieu' value kieu,'pt' value pt,'hh' value hh) order by bt)
        into dt_bh from tbh_tmB_cbi_nbh where so_id=b_so_id;
end if;
select json_object('so_id' value b_so_id,'dt_hd' value dt_hd,
    'dt_bh' value dt_bh,'dt_phi' value dt_phi,'dt_nbhp' value dt_nbhP,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,dt_hd clob,dt_bh clob,dt_phi clob,
    b_nv out varchar2,b_so_ct out varchar2,b_kieu out varchar2,b_so_ctG out varchar2,
    b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number,
    b_nt_tien out varchar2,b_nt_phi out varchar2,b_nguon out varchar2,
    b_pthuc out varchar2,b_so_idD out number,b_so_idG out number,
    a_ma_dvi out pht_type.a_var,a_kieu out pht_type.a_var,
    a_so_hd out pht_type.a_var,a_so_id_hd out pht_type.a_num,
    a_so_id_dt out pht_type.a_num,a_ten out pht_type.a_nvar,
    nbh_ma out pht_type.a_var,nbh_pt out pht_type.a_num,nbh_hh out pht_type.a_num,
    nbh_kieu out pht_type.a_var,nbh_maC out pht_type.a_var,
    phi_nbh out pht_type.a_var,phi_ma_ta out pht_type.a_var,
    phi_pt out pht_type.a_num,phi_tien out pht_type.a_num,
    phi_phi out pht_type.a_num,phi_tl_thue out pht_type.a_num,phi_thue out pht_type.a_num,
    phi_pt_hh out pht_type.a_num,phi_hhong out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_pt number:=0;
begin
-- Dan - Kiem tra so lieu
b_lenh:=FKH_JS_LENH('nv,so_ct,kieu,so_ctg,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,nguon,pthuc');
EXECUTE IMMEDIATE b_lenh into b_nv,b_so_ct,b_kieu,b_so_ctG,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pthuc using dt_ct;
if b_nv is null or b_nv not in ('XE','2B','HANG','PHH','PKT','PTN','NG','TAU') then
    b_loi:='loi:Sai nghiep vu:loi'; return;
end if;
b_ngay_ht:=nvl(b_ngay_ht,PKH_NG_CSO(sysdate));
b_nt_tien:=nvl(trim(b_nt_tien),'VND'); b_nt_phi:=nvl(trim(b_nt_tien),'VND');
if b_nt_tien<>'VND' then
    select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_nt_tien;
end if;
if b_nt_phi<>'VND' then
    select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_nt_phi;
end if;
b_ngay_hl:=nvl(b_ngay_hl,0); b_ngay_kt:=nvl(b_ngay_kt,0);
if b_ngay_hl in(0,30000101) or b_ngay_kt in(0,30000101) or b_ngay_hl>b_ngay_kt then
    b_loi:='loi:Sai ngay hieu luc:loi'; return;
end if;
b_lenh:=FKH_JS_LENH('kieu,ma_dvi_hd,so_hd,so_id_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_kieu,a_ma_dvi,a_so_hd,a_so_id_hd,a_so_id_dt using dt_hd;
if a_ma_dvi.count=0 then b_loi:='loi:Nhap hop dong/bao gia can tai:loi'; return; end if;
for b_lp in 1..a_ma_dvi.count loop
    if a_kieu(b_lp) not in('H','B','T') or a_ma_dvi(b_lp)=' ' or a_so_hd(b_lp)=' ' then
        b_loi:='loi:Sai so lieu hop dong dong '||trim(to_char(b_lp))||':loi'; return;
    end if;
    if a_so_id_hd(b_lp)=0 then
        if a_kieu(b_lp)='B' then
            a_so_id_hd(b_lp):=FTBH_SOAN_SO_ID(a_ma_dvi(b_lp),a_so_hd(b_lp),b_nv);
        else
            a_so_id_hd(b_lp):=FBH_HD_GOC_SO_ID_DAU(a_ma_dvi(b_lp),a_so_hd(b_lp));
        end if;
        if a_so_id_hd(b_lp)=0 then
            b_loi:='loi:Hop dong '||a_so_hd(b_lp)||' da xoa:loi'; return;
        end if;
    end if;
    if b_nv not in('PHH','PKT','TAU','XE','2B') then
        a_so_id_dt(b_lp):=0; a_ten(b_lp):=' ';
    else
        if a_so_id_dt(b_lp)=0 then a_so_id_dt(b_lp):=a_so_id_hd(b_lp); end if;
        a_ten(b_lp):=FTBH_GHEP_NH_DT(b_nv,b_ngay_ht,a_ma_dvi(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp));
    end if;
    if b_nv<>FBH_HD_NV(a_ma_dvi(b_lp),a_so_id_hd(b_lp)) then
        b_loi:='loi:Hop dong '||a_so_hd(b_lp)||' khac nghiep vu:loi'; return;
    end if;
end loop;
for b_lp in 1..a_ma_dvi.count loop
    if b_lp<a_ma_dvi.count then
        b_i1:=b_lp+1;
        for b_lp1 in b_i1..a_ma_dvi.count loop
            if a_so_id_hd(b_lp1)=a_so_id_hd(b_lp) and a_so_id_dt(b_lp1)=a_so_id_dt(b_lp) then
                b_loi:='loi:Trung doi tuong tich tu dong '||to_char(b_lp)||':loi'; return;
            end if;
        end loop;
    end if;
end loop;
b_lenh:=FKH_JS_LENH('nbh,pt,hh,kieu');
EXECUTE IMMEDIATE b_lenh bulk collect into nbh_ma,nbh_pt,nbh_hh,nbh_kieu using dt_bh;
for b_lp in 1..nbh_ma.count loop
    if nbh_ma(b_lp)=' ' or FBH_MA_NBH_HAN(nbh_ma(b_lp))<>'C' then
        b_loi:='loi:Sai nha tai dong: '||to_char(b_lp)||':loi'; return;
    end if;
    if nbh_kieu(b_lp) not in ('C','P') then
        b_loi:='loi:Sai kieu nha tai: '||nbh_ma(b_lp)||':loi'; return;
    end if;
    if nbh_kieu(b_lp)='C' then
        nbh_maC(b_lp):=nbh_ma(b_lp);
    else
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in REVERSE 1..b_i1 loop
            if nbh_kieu(b_lp1)='C' then b_i2:=b_lp1; exit; end if;
        end loop;
        if b_i2=0 then b_loi:='loi:Sai kieu nha bao hiem '||nbh_ma(b_lp)||':loi'; return; end if;
        nbh_maC(b_lp):=nbh_ma(b_i2);
    end if;
    b_pt:=b_pt+nbh_pt(b_lp);
end loop;
if b_pt=0 then b_loi:='loi:Nhap ty le tai:loi'; return; end if;
if b_pt>100 then b_loi:='loi:Tai vuot 100%:loi'; return; end if;
b_lenh:=FKH_JS_LENH('nbh,ma_ta,pt,tien,phi,tl_thue,thue,pt_hh,hhong');
EXECUTE IMMEDIATE b_lenh bulk collect into
    phi_nbh,phi_ma_ta,phi_pt,phi_tien,phi_phi,phi_tl_thue,phi_thue,phi_pt_hh,phi_hhong using dt_phi;
for b_lp in 1..phi_ma_ta.count loop
    if phi_ma_ta(b_lp)=' ' or phi_pt(b_lp) not between 0 and 100 then
        b_loi:='loi:Sai so lieu phi tai dong: '||trim(to_char(b_lp))||':loi'; return;
    end if;
end loop;
b_so_ct:=trim(b_so_ct); b_so_ctG:=nvl(trim(b_so_ctG),' ');
b_i1:=PKH_SO_NAM(b_ngay_ht);
if b_so_ctG=' ' then
    b_kieu:='G'; b_so_idD:=b_so_id; b_so_idG:=0;
    b_so_ct:=substr(to_char(b_so_id),3);
else
    b_kieu:='B';
    select count(*) into b_i1 from tbh_tm where so_ct=b_so_ctG;
    if b_i1<>1 then b_loi:='loi:So tai Fac goc da xoa:loi'; return; end if;
    select ngay_ht,ngay_kt,so_id_d,so_id into b_i1,b_i2,b_so_idD,b_so_idG from tbh_tm where so_ct=b_so_ctG;
    if b_i1>b_ngay_ht then b_loi:='loi:Ngay sua doi phai sau ngay phat sinh goc:loi'; return; end if;
    select count(*) into b_i1 from tbh_tm where so_id_g=b_so_idG;
    if b_i1<>0 then b_loi:='loi:So tai Fac goc da co sua doi bo sung:loi'; return; end if;
    if b_so_ct is null then b_so_ct:=FTBH_TMB_SO_BS(b_so_idD); end if;
end if;
PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_ma_dviP varchar2,b_so_idP number,b_so_id_dtP number,b_nv varchar2,
    b_so_ct varchar2,b_kieu varchar2,b_so_ctG varchar2,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,b_nt_tien varchar2,b_nt_phi varchar2,
    b_nguon varchar2,b_pthuc varchar2,b_so_idD number,b_so_idG number,
    a_ma_dvi pht_type.a_var,a_kieu pht_type.a_var,
    a_so_hd pht_type.a_var,a_so_id_hd pht_type.a_num,
    a_so_id_dt pht_type.a_num,a_ten pht_type.a_nvar,
    nbh_ma pht_type.a_var,nbh_pt pht_type.a_num,nbh_hh pht_type.a_num,
    nbh_kieu pht_type.a_var,nbh_maC pht_type.a_var,
    phi_nbh pht_type.a_var,phi_ma_ta pht_type.a_var,
    phi_pt pht_type.a_num,phi_tien pht_type.a_num,
    phi_phi pht_type.a_num,phi_tl_thue pht_type.a_num,phi_thue pht_type.a_num,
    phi_pt_hh pht_type.a_num,phi_hhong pht_type.a_num,
    dt_ct in out clob,dt_hd in out clob,dt_bh clob,dt_phi clob,b_loi out varchar2)
AS
    b_i1 number;
begin
insert into tbh_tmB values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_ct,b_kieu,b_so_ctG,b_ma_dviP,b_so_idP,b_so_id_dtP,
    b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pthuc,b_so_idD,b_so_idG,b_nsd,sysdate);    
for b_lp in 1..a_ma_dvi.count loop
    insert into tbh_tmB_hd values(
        b_ma_dvi,b_so_id,a_kieu(b_lp),a_ma_dvi(b_lp),a_so_hd(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp),a_ten(b_lp),b_lp);
end loop;
for b_lp in 1..nbh_ma.count loop
    insert into tbh_tmB_nbh values(b_so_id,nbh_ma(b_lp),nbh_pt(b_lp),nbh_hh(b_lp),nbh_kieu(b_lp),nbh_maC(b_lp),b_lp);
end loop;
for b_lp in 1..phi_ma_ta.count loop
    b_i1:=FKH_ARR_VTRI(nbh_ma,phi_nbh(b_lp));
    insert into tbh_tmB_phi values(
        b_so_id,phi_nbh(b_lp),nbh_maC(b_i1),phi_ma_ta(b_lp),phi_pt(b_lp),phi_tien(b_lp),phi_phi(b_lp),
        phi_tl_thue(b_lp),phi_thue(b_lp),phi_pt_hh(b_lp),phi_hhong(b_lp),b_lp);
end loop;
select JSON_ARRAYAGG(json_object(
    kieu,ma_dvi_hd,so_hd,so_id_hd,'so_id_dt' value so_id_dt||'|'||ten,bt) order by bt returning clob) into dt_hd
    from tbh_tmB_hd where so_id=b_so_id;
PKH_JS_THAYn(dt_ct,'ngay_ht',b_ngay_ht);
PKH_JS_THAYn(dt_ct,'ngay_hl',b_ngay_hl);
PKH_JS_THAYn(dt_ct,'ngay_kt',b_ngay_kt);
insert into tbh_tmB_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into tbh_tmB_txt values(b_ma_dvi,b_so_id,'dt_hd',dt_hd);
insert into tbh_tmB_txt values(b_ma_dvi,b_so_id,'dt_bh',dt_bh);
insert into tbh_tmB_txt values(b_ma_dvi,b_so_id,'dt_phi',dt_phi);
update tbh_tmB_cbi set kieu_xl='D' where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_NH_NH:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_nsdC varchar2(10);
begin
-- Dan - Xoa
b_loi:='';
select count(*),min(nsd) into b_i1,b_nsdC from tbh_tmB where so_id=b_so_id;
if b_i1<>0 then
    if trim(b_nsdC) is not null and b_nsd<>b_nsdC then
        b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return;
    end if;
    delete tbh_tmB_txt where so_id=b_so_id;
    delete tbh_tmB_phi where so_id=b_so_id;
    delete tbh_tmB_hd where so_id=b_so_id;
	delete tbh_tmB_nbh where so_id=b_so_id;
	delete tbh_tmB where so_id=b_so_id;
end if;
update tbh_tmB_cbi set kieu_xl='C' where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    b_ma_dviP varchar2(10):=' '; b_so_idP number:=0; b_so_id_dtP number:=0;
    b_nv varchar2(10); b_so_ct varchar2(20); b_so_id number;
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); 
    b_nguon varchar2(1); b_pthuc varchar2(1); b_so_idD number; b_so_idG number; 
    b_kieu varchar2(1); b_so_ctG varchar2(20); 
    a_ma_dvi pht_type.a_var; a_kieu pht_type.a_var;
    a_so_hd pht_type.a_var; a_so_id_hd pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_ten pht_type.a_nvar; 
    nbh_ma pht_type.a_var; nbh_pt pht_type.a_num; nbh_hh pht_type.a_num;
    nbh_kieu pht_type.a_var; nbh_maC pht_type.a_var; 
    phi_nbh pht_type.a_var; phi_ma_ta pht_type.a_var;
    phi_pt pht_type.a_num; phi_tien pht_type.a_num; 
    phi_phi pht_type.a_num; phi_tl_thue pht_type.a_num; phi_thue pht_type.a_num;
    phi_pt_hh pht_type.a_num; phi_hhong pht_type.a_num;
    dt_ct clob; dt_hd clob; dt_bh clob; dt_phi clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd,dt_bh,dt_phi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd,dt_bh,dt_phi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd); FKH_JSa_NULL(dt_bh); FKH_JSa_NULL(dt_phi);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    select count(*) into b_i1 from tbh_tmb_cbi where so_id=b_so_id;
    if b_i1<>0 then
        select ma_dviP,so_idP,so_id_dtP into b_ma_dviP,b_so_idP,b_so_id_dtP from tbh_tmB_cbi where so_id=b_so_id;
    end if;
    select count(*) into b_i1 from tbh_tmB where so_id=b_so_id;
    if b_i1<>0 then
        PTBH_TMB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
    end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMB_TEST(
    b_ma_dvi,b_so_id,dt_ct,dt_hd,dt_bh,dt_phi,
    b_nv,b_so_ct,b_kieu,b_so_ctG,b_ngay_ht,b_ngay_hl,b_ngay_kt,
    b_nt_tien,b_nt_phi,b_nguon,b_pthuc,b_so_idD,b_so_idG,
    a_ma_dvi,a_kieu,a_so_hd,a_so_id_hd,a_so_id_dt,a_ten,
    nbh_ma,nbh_pt,nbh_hh,nbh_kieu,nbh_maC,
    phi_nbh,phi_ma_ta,phi_pt,phi_tien,phi_phi,phi_tl_thue,phi_thue,phi_pt_hh,phi_hhong,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TMB_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    b_ma_dviP,b_so_idP,b_so_id_dtP,b_nv,b_so_ct,b_kieu,b_so_ctG,
    b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,
    b_nguon,b_pthuc,b_so_idD,b_so_idG,
    a_ma_dvi,a_kieu,a_so_hd,a_so_id_hd,a_so_id_dt,a_ten,
    nbh_ma,nbh_pt,nbh_hh,nbh_kieu,nbh_maC,
    phi_nbh,phi_ma_ta,phi_pt,phi_tien,phi_phi,phi_tl_thue,phi_thue,phi_pt_hh,phi_hhong,
    dt_ct,dt_hd,dt_bh,dt_phi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
PTBH_TMB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_TMB_KH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_kieu_xl varchar2(1); b_so_id number;
begin
-- Dan - Nhap khong tai
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Nhap so lieu sai:loi';
select kieu_xl into b_kieu_xl from tbh_tmB_cbi where so_id=b_so_id;
if b_kieu_xl='D' then
    b_loi:='loi:Da chuyen tai tam thoi:loi'; raise PROGRAM_ERROR;
end if;
if b_kieu_xl='K' then b_kieu_xl:='C'; else b_kieu_xl:='K'; end if;
update tbh_tmB_cbi set kieu_xl=b_kieu_xl where so_id=b_so_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FTBH_TMB_VUOT(
    b_so_id number,dt_ct clob,dt_hd clob,
    b_ngay_hl out number,b_ngay_kt out number,b_nt_tien out varchar2,b_nt_phi out varchar2,b_vuot out number,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_kieu_ps varchar2(1):='H';
    b_nv varchar2(10); b_ngay_ht number; b_tso varchar2(100);
    a_kieu pht_type.a_var; a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var;
    a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
    b_ma_dviP varchar2(10); b_so_idP number; b_so_id_dtP number;
    b_ngay_hlX number; b_ngay_ktX number;
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_tl_temp;
b_lenh:=FKH_JS_LENH('nv,ngay_ht,nt_tien,nt_phi');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngay_ht,b_nt_tien,b_nt_phi using dt_ct;
b_lenh:=FKH_JS_LENH('kieu,ma_dvi_hd,so_hd,so_id_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_kieu,a_ma_dvi,a_so_hd,a_so_id,a_so_id_dt using dt_hd;
if a_ma_dvi.count=0 then b_loi:='loi:Nhap hop dong can tai:loi'; return; end if;
if b_nv='NG' and a_ma_dvi.count=1 and a_so_id_dt(1)=0 then
    select nvl(max(tien),0) into b_i1 from bh_ng_dk where ma_dvi=a_ma_dvi(1) and so_id=a_so_id(1);
    if b_i1<>0 then
        select nvl(min(so_id_dt),0) into a_so_id_dt(1) from bh_ng_dk where ma_dvi=a_ma_dvi(1) and so_id=a_so_id(1) and tien=b_i1;
    end if;
end if;
b_ngay_hl:=30000101; b_ngay_kt:=0; b_vuot:=0;
if b_so_id<>0 then
    select nvl(min(kieu_ps),'H') into b_kieu_ps from tbh_tmB_cbi where so_id=b_so_id;
    if b_kieu_ps in('B','T') then
        select ma_dviP,so_idP,so_id_dtP into b_ma_dviP,b_so_idP,b_so_id_dtP from tbh_tmB_cbi where so_id=b_so_id;
        if b_kieu_ps='B' then
            PTBH_BAO_TLm(b_ma_dviP,b_so_idP,b_so_id_dtP,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_ngay_hl,b_ngay_kt,b_vuot,b_loi,b_so_id);
        else
            PTBH_SOAN_TLm(b_ma_dviP,b_so_idP,b_so_id_dtP,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_ngay_hl,b_ngay_kt,b_vuot,b_loi,b_so_id);
        end if;
        if b_loi is not null then return; end if;
    end if;
end if;
if b_kieu_ps not in('B','T') then
    for b_lp in 1..a_ma_dvi.count loop
        if nvl(a_so_id(b_lp),0)=0 then
            select so_id_d into a_so_id(b_lp) from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_hd=a_so_hd(b_lp);
        end if;
        if b_nv in('PHH','PKT','TAU','XE','2B') and a_so_id_dt(b_lp)=0 then a_so_id_dt(b_lp):=a_so_id(b_lp); end if;
    end loop;
    for b_lp in 1..a_ma_dvi.count loop
        b_i1:=0;
        if b_lp<a_ma_dvi.count then
            b_i2:=b_lp+1;
            for b_lp1 in b_i2..a_ma_dvi.count loop
                if a_so_hd(b_lp)=a_so_hd(b_lp1) then b_i1:=1; exit; end if;
            end loop;
        end if;
        if b_i1=0 then
            PBH_HD_NGAY_HL(a_ma_dvi(b_lp),a_so_id(b_lp),b_ngay_ht,b_ngay_hlX,b_ngay_ktX);
            if b_ngay_hl>b_ngay_hlX then b_ngay_hl:=b_ngay_hlX; end if;
            if b_ngay_kt<b_ngay_ktX then b_ngay_kt:=b_ngay_ktX; end if;
        end if;
    end loop;
    b_tso:='{"ttrang":"T","xly":"F"}';
    PTBH_GHEP_TL(b_so_id,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select nvl(max(pt),0) into b_vuot from tbh_ghep_tl_temp where pthuc='O';
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_TMB_VUOT:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_VUOT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id number; b_vuot number; b_ngay_hl number; b_ngay_kt number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    dt_ct clob; dt_hd clob;
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_tl_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd);
FTBH_TMB_VUOT(b_so_id,dt_ct,dt_hd,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_vuot,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('vuot' value b_vuot,'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt) into b_oraOut from dual;
delete tbh_ghep_tl_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
