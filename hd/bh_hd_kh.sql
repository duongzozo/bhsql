create or replace function FBH_HD_TXT(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_dk varchar2:='') return varchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_lenh varchar2(1000); b_bang varchar2(50); b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
if b_nv is null then return b_kq; end if;
b_bang:=FBH_HD_GOC_BANG_CT(b_nv)||b_dk||'_txt';
b_lenh:='select count(*) from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id and loai= :loai'; 
EXECUTE IMMEDIATE b_lenh into b_i1 using b_ma_dvi,b_so_id,'dt_ct';
if b_i1=1 then
    b_lenh:='select txt from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id and loai= :loai'; 
    EXECUTE IMMEDIATE b_lenh into b_txt using b_ma_dvi,b_so_id,'dt_ct';
    PKH_JS_BONH(b_txt); b_kq:=nvl(FKH_JS_GTRIs(b_txt,b_tim),' ');
end if;
return b_kq;
end;
/
create or replace function FBH_HD_MA_KT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ma khai thac
select nvl(min(decode(kieu_kt,'T',' ',ma_kt)),' ') into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_MA_KT_LOAI(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20):=' '; b_ma_kt varchar2(20);
begin
-- Dan - Tra loai C-ca nhan, T-To chuc ma khai thac
b_ma_kt:=FBH_HD_MA_KT(b_ma_dvi,b_so_id);
if b_ma_kt<>' ' then b_kq:=FBH_DTAC_MA_LOAI(b_ma_kt); end if;
return b_kq;
end;
/
create or replace function FBH_HD_CDT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_pthuc varchar2,b_tso varchar2:=' ') return varchar2
AS
    b_kq varchar2(1):='K'; b_cdt varchar2(10); b_so_idD number;
begin
-- Dan - Tra gia tri varchar2 trong txt
--nam: chi dinh tai lay theo don goc
if FKH_JS_GTRIs(b_tso,'kieu_ps','H')='B' then b_so_idD:=b_so_id;
else b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
end if;
b_cdt:=FTBH_SOANd_TXT(b_ma_dvi,b_so_idD,b_so_id_dt,'cdt',b_tso);
if b_cdt=' ' or instr(b_cdt,b_pthuc)<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
-- chuclh: truong hop ng, ptn 
create or replace function FBH_SO_IDd(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number) return number
AS
    b_nvH varchar2(20); b_kq number; b_lenh varchar2(1000);
begin
-- Dan - Tra so_id_d
b_nvH:=FBH_NV_HDd(b_nv,b_ma_dvi,b_so_id);
b_lenh:='select FBH_'||b_nvH||'_SO_IDd(:ma_dvi,:so_id) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id;
return b_kq;
end;
/
create or replace function FBH_SO_HDd(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20):=' '; b_lenh varchar2(1000);
begin
-- Dan - Tra ten doi tuong
b_lenh:='select FBH_'||b_nv||'_SO_HDd(:ma_dvi,:so_id) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id;
return b_kq;
end;
/
create or replace function FBH_NV_HDd(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20):=' '; b_ch varchar2(20);
begin
-- Dan - Tra ten doi tuong
if b_nv='PTN' then
    b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id);
    if b_ch=' ' then b_kq:='PTN';
    elsif b_ch='CC' then b_kq:='PTNCC';
    elsif b_ch='NN' then b_kq:='PTNNN';
    else b_kq:='PTNVC'; end if;
elsif b_nv='NG' then
    b_ch:=FBH_SOAN_BGHD_NG(b_ma_dvi,b_so_id);
    if b_ch=' ' then b_kq:='NG';
    elsif b_ch='SK' then b_kq:='SK';
    elsif b_ch='DL' then b_kq:='NGDL';
    else b_kq:='NGTD'; end if;
else
    b_kq:=b_nv;
end if;
return b_kq;
end;
/
create or replace function FBH_MRR_DT(b_nv varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,b_ngay number:=30000101) return varchar2
AS
    b_kq varchar2(10):=' '; b_mrr varchar2(10);
begin
-- Dan - Tra muc rui ro cao nhat cua doi tuong
if b_nv='PHH' then
    for b_lp in 1..a_ma_dvi.count loop
        b_mrr:=FBH_PHH_CAT(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ngay);
        if b_mrr>b_kq then b_kq:=b_mrr; end if;
    end loop;
elsif b_nv='PKT' then
    for b_lp in 1..a_ma_dvi.count loop
        b_mrr:=FBH_PKT_MA_DT(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ngay);
        if b_mrr>b_kq then b_kq:=b_mrr; end if;
    end loop;
--nam
elsif b_nv='XE' then
    if a_ma_dvi.count<>0 then
        b_kq:=FBH_XE_MA_DT(a_ma_dvi(1),a_so_id(1),a_so_id_dt(1),b_ngay);
    end if;
elsif b_nv='TAU' then
    if a_ma_dvi.count<>0 then
        b_kq:=FBH_TAU_MA_DT(a_ma_dvi(1),a_so_id(1),a_so_id_dt(1),b_ngay);
    end if;
elsif b_nv='2B' then
    if a_ma_dvi.count<>0 then
        b_kq:=FBH_2B_MA_DT(a_ma_dvi(1),a_so_id(1),a_so_id_dt(1),b_ngay);
    end if;
elsif b_nv='NG' then
    if a_ma_dvi.count<>0 and a_so_id_dt(1)<>0 then
        b_kq:=FBH_NG_MA_DT(a_ma_dvi(1),a_so_id(1),a_so_id_dt(1),b_ngay);
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_CO_TAM(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq nvarchar2(1):='C';
begin
-- Dan - Tra co tai tam khong
if FBH_DONG(b_ma_dvi,b_so_id)='G' and FTBH_TMN(b_ma_dvi,b_so_id)='C' then b_kq:='K'; end if;
return b_kq;
end;
/
create or replace function FBH_HD_DTUONG(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_i1 number; b_so_idB number;
begin
-- Dan - Tra ten doi tuong
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
    if b_so_idB=0 then b_so_idB:=b_so_id; end if;
    if b_nv in('PHH') then
        b_kq:=FBH_PHH_DVI(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
    elsif b_nv in('PKT') then
        b_kq:=FBH_PKT_DVI(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
    elsif b_nv in('XE') then
        b_kq:=FBH_XE_BIEN(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
    elsif b_nv in('2B') then
        b_kq:=FBH_2B_BIEN(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
    elsif b_nv in('TAU') then
        b_kq:=FBH_TAU_BIEN(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
    elsif b_nv in('NG') then
        b_kq:=FBH_NG_TEN(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay);
    else
        b_kq:=FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id);
    end if;
else
    if b_nv in('PHH','PHHB') then
        b_kq:=FBH_PHHB_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
    elsif b_nv in('PKT','PKTB') then
        b_kq:=FBH_PKTB_DVI(b_ma_dvi,b_so_id,b_so_id_dt);
    elsif b_nv in('XE','XEB') then
        b_kq:=FBH_XEB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
    elsif b_nv in('2B','2BB') then
        b_kq:=FBH_2BB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
    elsif b_nv in('TAU','TAUB') then
        b_kq:=FBH_TAUB_TEN(b_ma_dvi,b_so_id,b_so_id_dt);
    else
        b_kq:=substr(to_char(b_so_id),3);
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_DTUONGl(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten doi tuong dang dr_lke
b_kq:=to_char(b_so_id_dt)||'|'||FBH_HD_DTUONG(b_nv,b_ma_dvi,b_so_id,b_so_id_dt,b_ngay);
return b_kq;
end;
/
create or replace function FBH_HD_DTUONGc(b_nv varchar2,b_ma_dvi varchar2,b_so_id number) return clob
AS
    b_kq clob:=''; b_i1 number; b_so_idB number;
begin
-- Dan - Tra ten doi tuong
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
    if b_so_idB=0 then b_so_idB:=b_so_id; end if;
    if b_nv in('PHH','PHHB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value dvi) order by dvi returning clob) into b_kq
            from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('PKT','PKTB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value dvi) order by dvi returning clob) into b_kq
            from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('TAU','TAUB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value FBH_TAU_BIEN(b_ma_dvi,b_so_idB,so_id_dt)) order by bt returning clob) into b_kq
            from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('XE','XEB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value FBH_XE_BIEN(b_ma_dvi,b_so_idB,so_id_dt)) order by bt returning clob) into b_kq
            from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('2B','2BB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value FBH_2B_BIEN(b_ma_dvi,b_so_idB,so_id_dt)) order by bt returning clob) into b_kq
            from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
else
    if b_nv in('PHH','PHHB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),ten) order by ten returning clob) into b_kq
            from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('PKT','PKTB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),ten) order by ten returning clob) into b_kq
            from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('TAU','TAUB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value FBH_TAU_BIEN(b_ma_dvi,b_so_id,so_id_dt)) order by so_id_dt returning clob) into b_kq
            from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('XE','XEB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value FBH_XE_BIEN(b_ma_dvi,b_so_id,so_id_dt)) order by so_id_dt returning clob) into b_kq
            from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('2B','2BB') then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value FBH_2B_BIEN(b_ma_dvi,b_so_id,so_id_dt)) order by so_id_dt returning clob) into b_kq
            from bh_2bB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure FBH_HD_DTUONGa(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num)
AS
    b_kq clob:=''; b_i1 number; b_so_idB number;
begin
-- Dan - Tra ten doi tuong
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
    if b_so_idB=0 then b_so_idB:=b_so_id; end if;
    if b_nv in('PHH','PHHB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('PKT','PKTB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('TAU','TAUB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('XE','XEB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_nv in('2B','2BB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    else
        a_so_id_dt(1):=b_so_id;
    end if;
else
    if b_nv in('PHH','PHHB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('PKT','PKTB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('TAU','TAUB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('XE','XEB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_nv in('2B','2BB') then
        select so_id_dt bulk collect into a_so_id_dt from bh_2B_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        a_so_id_dt(1):=b_so_id;
    end if;
end if;
end;
/
create or replace function FBH_HD_NVl(b_nv varchar2,b_ma_dvi varchar2,b_so_id number) return clob
AS
    b_kq clob:=''; b_i1 number; b_so_idB number;
begin
-- Dan - Tra ten doi tuong
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
    if b_so_idB=0 then b_so_idB:=b_so_id; end if;
    if b_nv in('PHH','PHHB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB);
    elsif b_nv in('PKT','PKTB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB);
    elsif b_nv in('TAU','TAUB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB);
    elsif b_nv in('XE','XEB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB);
    elsif b_nv in('2B','2BB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB);
    end if;
else
    if b_nv in('PHH','PHHB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id);
    elsif b_nv in('PKT','PKTB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_pktB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id);
    elsif b_nv in('TAU','TAUB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_tauB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id);
    elsif b_nv in('XE','XEB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_xeB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id);
    elsif b_nv in('2B','2BB') then
        select JSON_ARRAYAGG(json_object('ma' value lh_nv,'ten' value lh_nv) order by lh_nv returning clob) into b_kq
            from (select distinct lh_nv from bh_2bB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id);
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_NV_DK(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2)
AS
    b_nv varchar2(10); b_ten nvarchar2(500); b_ngcap number;
    b_lenh varchar2(1000); b_nt_tien varchar2(5); b_tg number;
begin
-- Dan - Liet ke nghiep vu theo hop dong
b_loi:='loi:Loi xu ly PBH_HD_NV_DK:loi';
delete bh_hd_nv_temp;
--nam : rao dong ben duoi
--b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id); b_ngcap:=FBH_HD_NGAY_TAI(b_ma_dvi,b_so_id);
select nvl(min(nv),' '),min(ngay_ht),min(nt_tien) into b_nv,b_ngcap,b_nt_tien
    from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv=' ' then b_loi:='loi:Bao gia da xoa:loi'; return; end if;
b_lenh:='begin PBH_BAO_DK_'||b_nv||'(:ma_dvi,:so_id,:so_id_dt,:loi); end;';
execute immediate b_lenh using b_ma_dvi,b_so_id,b_so_id_dt,out b_loi;
if b_loi is not null then return; end if;
if b_so_id_dt<>0 then delete bh_hd_nv_temp where so_id_dt not in(0,b_so_id_dt); end if;
if b_nt_tien='VND' then
    update bh_hd_nv_temp set tien_vnd=tien;
else
    b_tg:=FBH_TT_TRA_TGTT(b_ngcap,b_nt_tien);
    update bh_hd_nv_temp set tien_vnd=round(tien*b_tg,0);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2,b_tso varchar2:=' ')
AS
    b_nv varchar2(10); b_ngcap number; b_nt_tien varchar2(5); b_tg number;
    b_lenh varchar2(1000); b_ttrang varchar2(1):='H';
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(nv),' '),min(ngay_cap),min(nt_tien) into b_nv,b_ngcap,b_nt_tien
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_nv=' ' then
    b_nv:=FTBH_SOAN_NVt(b_ma_dvi,b_so_id_ps,b_tso);
    if b_nv=' ' then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
    b_lenh:='select nvl(min(ngay_cap),0),min(nt_tien) from '||FBH_HD_GOC_BANG(b_nv)||' where ma_dvi= :ma_dvi and so_id= :so_id';
    execute immediate b_lenh into b_ngcap,b_nt_tien using b_ma_dvi,b_so_id_ps;
end if;
b_lenh:='begin PBH_HD_DS_NV_BANG_'||b_nv||'(:ma_dvi,:so_id_ps,:so_id_dt,:loi); end;';
execute immediate b_lenh using b_ma_dvi,b_so_id_ps,b_so_id_dt,out b_loi;
if b_loi is not null then return; end if;
if b_nt_tien='VND' then
    update bh_hd_nv_temp set tien_vnd=tien;
else
    b_tg:=FBH_TT_TRA_TGTT(b_ngcap,b_nt_tien);
    update bh_hd_nv_temp set tien_vnd=round(tien*b_tg,0);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG:loi'; end if;
end;
/
create or replace procedure PBH_HD_NV_DKa(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    dk_lh_nv out pht_type.a_var,dk_tien out pht_type.a_num,dk_phi out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Liet ke nghiep vu theo hop dong
b_loi:='loi:Loi xu ly PBH_HD_NV_DKa:loi';
if b_nv='PHH' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='PHHB' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='PKT' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='PKTB' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_pktB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='TAU' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='TAUB' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_tauB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='XE' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='XEB' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_xeB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='2B' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='2BB' then
    select lh_nv,tien,phi bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_2bB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and lh_nv<>' ';
elsif b_nv='NG' then
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and b_so_id_dt in(0,so_id_dt) and lh_nv<>' ' group by lh_nv;
elsif b_nv='NGB' then
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and b_so_id_dt in(0,so_id_dt) and lh_nv<>' ' group by lh_nv;
elsif b_nv='PTN' then
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='PTNB' then
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_ptnB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HANG' then
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
elsif b_nv='HANGB' then
    select lh_nv,sum(tien),sum(phi) bulk collect into dk_lh_nv,dk_tien,dk_phi
        from bh_hangB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_HD_NV_TIENl(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_lh_nv out pht_type.a_var,a_tien out pht_type.a_num,a_phi out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Tinh tong tien, phi theo loai hinh nghiep vu
select lh_nv,nvl(sum(tien),0),nvl(sum(phi),0) bulk collect into a_lh_nv,a_tien,a_phi from bh_hd_goc_dkdt
    where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt) and lh_nv<>' ' group by lh_nv;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HD_NV_TIENl:loi'; end if;
end;
/
create or replace procedure FBH_HD_NV_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_tien out number,b_phi out number,b_loi out varchar2)
AS
begin
-- Dan - Tinh tong tien, phi
b_loi:='loi:Loi xu ly FBH_HD_NV_TIEN:loi';
select nvl(sum(tien),0),nvl(sum(phi),0) into b_tien,b_phi from bh_hd_goc_dkdt
    where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt) and lh_nv<>' ';
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_NV_TIEN(
    b_ngay_ht number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_tien out number,b_phi out number,b_loi out varchar2)
AS
begin
-- Dan - Tinh tong tien, phi
b_loi:='loi:Loi xu ly PBH_HD_NV_TIEN:loi';
delete bh_hd_nv_temp; delete bh_hd_nv_tong_temp1; delete bh_hd_nv_tong_temp2;
for b_lp in 1..a_ma_dvi.count loop
    PBH_HD_NV_DK(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_loi);
    if b_loi is not null then return; end if;
    insert into bh_hd_nv_tong_temp1 select nt_tien,sum(tien),nt_phi,sum(phi)
        from bh_hd_nv_temp where lh_nv<>' ' group by nt_tien,nt_phi;
end loop;
insert into bh_hd_nv_tong_temp2 select nt_tien,sum(tien),nt_phi,sum(phi) from bh_hd_nv_tong_temp1 group by nt_tien,nt_phi;
update bh_hd_nv_tong_temp2 set tien=FBH_TT_TUNG_QD(b_ngay_ht,nt_tien,tien,b_nt_tien) where nt_tien<>b_nt_tien;
update bh_hd_nv_tong_temp2 set phi=FBH_TT_TUNG_QD(b_ngay_ht,nt_phi,phi,b_nt_phi) where nt_phi<>b_nt_phi;
select nvl(sum(tien),0),nvl(sum(phi),0) into b_tien,b_phi from bh_hd_nv_tong_temp2;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HD_NV_SP(b_ma_dvi varchar2,b_so_id number,b_nv out varchar2,b_sp out varchar2,b_dk varchar2:='C')
AS
begin
-- Dan - Tra nghiep vu, san pham
-- chuclh: chinh ma_sp cho het invalid
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
if b_nv='SK' then
    select nvl(min(ma_sp),'*') into b_sp from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    b_sp:='*';
end if;
if b_dk='C' then b_nv:=FBH_HD_NV_RUT(b_nv); end if;
end;
/
create or replace function FBH_HD_NBHb(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - tra kieu ve
if FBH_DONG(b_ma_dvi,b_so_id)='V' or FTBH_TMN(b_ma_dvi,b_so_id)='C' then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_NBHl(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number)
AS
begin
-- Dan - Liet ke nha BH
delete temp_1;
insert into temp_1(c1,c2) (
select distinct nha_bh,'D' from bh_hd_do_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) union
select distinct nha_bhC,'N' from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) union
select distinct nha_bhC,'T' from tbh_tm_pbo where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and so_id_dt in(0,b_so_id_dt) union
select distinct nha_bhC,'C' from tbh_ghep_pbo where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and so_id_dt in(0,b_so_id_dt));
end;
/
create or replace procedure PBH_HD_NBH(
    b_ma_dvi varchar2,b_so_id number,a_nbh out pht_type.a_var,a_pthuc out pht_type.a_var,b_dk varchar2:=' ')
AS
    b_kt number; b_kieu_do varchar2(1):=FBH_DONG(b_ma_dvi,b_so_id);
begin
-- Dan - Xac dinh nha BH
PTBH_TMN_NBH(b_ma_dvi,b_so_id,a_nbh);
b_kt:=a_nbh.count;
for b_lp in 1..b_kt loop a_pthuc(b_lp):='T'; end loop;
if b_kieu_do<>'G' and b_dk in(' ',b_kieu_do)  then
    for r_lp in(select distinct nha_bh from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C') loop
        b_kt:=b_kt+1; a_nbh(b_kt):=r_lp.nha_bh; a_pthuc(b_kt):=b_kieu_do;
    end loop;
end if;
end;
/
create or replace procedure PBH_HD_NBHd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,a_nbh out pht_type.a_var,a_pthuc out pht_type.a_var,b_dk varchar2:=' ')
AS
    b_kt number; b_kieu_do varchar2(1):=FBH_DONG(b_ma_dvi,b_so_id);
begin
-- Dan - Xac dinh nha BH
PTBH_TMN_NBH(b_ma_dvi,b_so_id,a_nbh);
b_kt:=a_nbh.count;
for b_lp in 1..b_kt loop a_pthuc(b_lp):='T'; end loop;
if b_kieu_do<>'G' and  b_dk in(' ',b_kieu_do)  then
    for r_lp in(select distinct nha_bh from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt)) loop
        b_kt:=b_kt+1; a_nbh(b_kt):=r_lp.nha_bh; a_pthuc(b_kt):=b_kieu_do;
    end loop;
end if;
end;
/
create or replace procedure PBH_HD_NBHc(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,a_nbh out pht_type.a_var,a_pthuc out pht_type.a_var)
AS
    b_kt number; b_nbh varchar2(20);
begin
-- Dan - Xac dinh nha BH chinh
PTBH_TMN_NBH(b_ma_dvi,b_so_id,a_nbh);
b_kt:=a_nbh.count;
for b_lp in 1..b_kt loop a_pthuc(b_lp):='T'; end loop;
if FBH_DONG(b_ma_dvi,b_so_id)='V' then
    select nvl(min(nha_bh),' ') into b_nbh from bh_hd_do_tl where 
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt);
    if b_nbh<>' ' then b_kt:=b_kt+1; a_nbh(b_kt):=b_nbh; a_pthuc(b_kt):='D'; end if;
end if;
end;
/
create or replace function FBH_HD_NBHf(
    b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='G'; a_nbh pht_type.a_var;
begin
-- Dan - Xac dinh loai ve
if FBH_DONG(b_ma_dvi,b_so_id)='V' then b_kq:='D';
else
    PTBH_TMN_NBH(b_ma_dvi,b_so_id,a_nbh);
    if a_nbh.count<>0 then b_kq:='T'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_NBH_TL(
    b_ma_dvi varchar2,b_so_id number,b_lh_nv varchar2,b_pthuc varchar2,b_nbh varchar2:=' ') return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ty le dong bao hiem theo nghiep vu
if b_pthuc='T' then
    b_kq:=FTBH_TMN_TL(b_ma_dvi,b_so_id,b_lh_nv,b_nbh);
else
    b_kq:=FBH_DONG_TL(b_ma_dvi,b_so_id,b_lh_nv,b_nbh);
end if;
return b_kq;
end;
/
create or replace function FBH_HD_NBH_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_pthuc varchar2,b_nbh varchar2:=' ') return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ty le dong bao hiem theo nghiep vu
if b_pthuc='T' then
    b_kq:=FTBH_TMN_TL_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_lh_nv,b_nbh);
else
    b_kq:=FBH_DONG_TL_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_lh_nv,b_nbh);
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_PHH(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp select a.so_id_dt,a.dvi,a.ma_dt,b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_phh_dvi a,bh_phh_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dvi,a.ma_dt,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PHH:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_PKT(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
--Nam: a.ma_dt
insert into bh_hd_nv_temp select a.so_id_dt,a.dvi,a.ma_dt,b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_pkt_dvi a,bh_pkt_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dvi,a.ma_dt,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PKT:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_PTN(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp select a.so_id_dt,a.dtuong,'',b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_ptn_dvi a,bh_ptn_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dtuong,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PTN:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_PTNCC(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp select a.so_id_dt,a.dtuong,'',b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_ptncc_dvi a,bh_ptncc_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dtuong,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PTNCC:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_PTNNN(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp select a.so_id_dt,a.dtuong,'',b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_ptnnn_dvi a,bh_ptnnn_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dtuong,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PTNNN:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_PTNVC(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp select a.so_id_dt,a.dtuong,'',b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_ptnvc_dvi a,bh_ptnvc_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dtuong,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PTNVC:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_2B(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
insert into bh_hd_nv_temp select
    a.so_id_dt,a.gcn||' - '||decode(a.bien_xe,' ',a.so_khung,a.bien_xe)||' - ' ||trim(a.tenC),
    a.loai_xe,b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_2b_ds a,bh_2b_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.gcn,a.bien_xe,a.so_khung,a.tenC,a.loai_xe,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_2B:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_XE(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
insert into bh_hd_nv_temp select
    a.so_id_dt,a.gcn||' - '||decode(a.bien_xe,' ',a.so_khung,a.bien_xe)||' - ' ||trim(a.tenC),
    a.loai_xe,b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_xe_ds a,bh_xe_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.gcn,a.bien_xe,a.so_khung,a.tenC,a.loai_xe,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_XE:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_TAU(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
insert into bh_hd_nv_temp select
    a.so_id_dt,trim(a.so_dk||'/'||a.ten_tau),
    a.loai,b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_tau_ds a,bh_tau_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,trim(a.so_dk||'/'||a.ten_tau),a.loai,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_TAU:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_NG(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_i1 number;
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
--nam:  hop dong bao muc trach nhiem theo ca hd
if b_i1<>0 then
  insert into bh_hd_nv_temp select
      a.so_id_dt,a.ten,a.nghe,b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
      from bh_ng_ds a,bh_ng_dk b where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.so_id_dt=b.so_id_dt and 
      a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and b.lh_nv<>' ' group by a.so_id_dt,a.ten,a.nghe,b.lh_nv,b_nt_tien,b_nt_phi;
else
  insert into bh_hd_nv_temp select
      '','','',lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
      from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and lh_nv<>' ' group by lh_nv,b_nt_tien,b_nt_phi;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_NG:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_SK(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
-- chuclh: gom theo lhnv
insert into bh_hd_nv_temp 
       select 0,' ',' ',lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi) from
               (select lh_nv,sum(tien) tienT,sum(phi) phiT
               from bh_sk_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and lh_nv<>' ' group by lh_nv,b_nt_tien,b_nt_phi);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_NG:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_NGDL(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
-- chuclh: gom theo lhnv
insert into bh_hd_nv_temp  
    select 0,' ',' ',lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi) from
               (select lh_nv,sum(tien) tienT,sum(phi) phiT
               from bh_ngdl_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and lh_nv<>' ' group by lh_nv,b_nt_tien,b_nt_phi);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_NG:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_NGTD(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
-- chuclh: gom theo lhnv
insert into bh_hd_nv_temp  
    select 0,' ',' ',lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi) from
               (select lh_nv,sum(tien) tienT,sum(phi) phiT
               from bh_ngtd_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and lh_nv<>' ' group by lh_nv,b_nt_tien,b_nt_phi);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_NG:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_HANG(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    a_so_id_dtK pht_type.a_num; a_dviK pht_type.a_var; a_ma_dtK pht_type.a_var;
    a_lh_nvK pht_type.a_var; a_nt_tienK pht_type.a_var; a_tienK pht_type.a_num;
    a_nt_phiK pht_type.a_var; a_phiK pht_type.a_num;
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then b_loi:=''; return; end if;
insert into bh_hd_nv_temp  select 0,' ',' ',lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
    from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and lh_nv<>' ' group by lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_PTN:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_HOP(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp  select 0,' ',' ',lh_nv,b_nt_tien,sum(tien),0,b_nt_phi,sum(phi)
    from bh_hop_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and lh_nv<>' ' group by lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_HOP:loi'; end if;
end;
/
create or replace procedure PBH_HD_DS_NV_BANG_NONG(
    b_ma_dvi varchar2,b_so_id_ps number,b_so_id_dt number,b_loi out varchar2)
AS
    b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Nam - Liet ke nghiep vu theo hop dong
delete bh_hd_nv_temp;
select nvl(min(ngay_ht),0),min(nt_tien),min(nt_phi) into b_ngay_ht,b_nt_tien,b_nt_phi
    from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id_ps;
if b_ngay_ht=0 then return; end if;
insert into bh_hd_nv_temp select a.so_id_dt,a.dvi,'',b.lh_nv,b_nt_tien,sum(b.tien),0,b_nt_phi,sum(b.phi)
    from bh_nong_dvi a,bh_nong_dk b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id_ps and b_so_id_dt in(0,a.so_id_dt) and
    b.ma_dvi=b_ma_dvi and b.so_id=b_so_id_ps and b.so_id_dt=a.so_id_dt and b.lh_nv<>' ' group by a.so_id_dt,a.dvi,b.lh_nv,b_nt_tien,b_nt_phi;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DS_NV_BANG_HOP:loi'; end if;
end;
/
create or replace procedure PBH_HD_QUA(
    b_ma_dvi varchar2,b_so_id number,b_vuot out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_ngay_hl number; b_ngay_ht number;
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_so_id_dtX pht_type.a_num;
begin
-- Dan - Kiem tra tai>100
b_loi:=''; b_vuot:='K';
select nvl(min(nv),' '),min(ngay_ht),min(ngay_hl) into b_nv,b_ngay_hl,b_ngay_ht
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv<>' ' then return; end if;
FBH_HD_DTUONGa(b_nv,b_ma_dvi,b_so_id,a_so_id_dtX);
a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id;
for b_lp in 1..a_so_id_dtX.count loop
    a_so_id_dt(1):=a_so_id_dtX(b_lp);
    PTBH_GHEP_NV(0,b_ngay_ht,b_ngay_hl,'VND','VND',a_ma_dvi,a_so_id,a_so_id_dt,b_loi,'{"mata":"K","nv":"'||b_nv||'"}');
    if b_loi is not null then return; end if;
    select nvl(min(pt_con),0) into b_i1 from tbh_ghep_nv_temp0;
    if b_i1<0 then b_vuot:='C'; exit; end if;
end loop;
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_QUA:loi'; end if;
end;
/
create or replace procedure PBH_HD_CON_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_pt_con out number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_ngay_hl number; b_ngay_ht number;
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
    b_do_tl number; b_ve_tl number;
begin
-- Dan - Tra % con sau dong tai
b_loi:=''; b_pt_con:=0;
select nvl(min(nv),' '),min(ngay_ht),min(ngay_hl) into b_nv,b_ngay_hl,b_ngay_ht
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv=' ' then return; end if;
a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=b_so_id_dt;
PTBH_GHEP_NV(0,b_ngay_ht,b_ngay_hl,'VND','VND',a_ma_dvi,a_so_id,a_so_id_dt,b_loi,'{"mata":"K","nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
select nvl(max(do_tl),0),nvl(max(ve_tl),0) into b_do_tl,b_ve_tl
    from tbh_ghep_nv_temp0 where ma_ta=b_lh_nv;
if b_do_tl<>0 then
    b_pt_con:=100-b_do_tl+b_ve_tl;
elsif b_ve_tl<>0 then
    b_pt_con:=b_ve_tl;
else
    b_pt_con:=100;
end if;
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_CON_DT:loi'; end if;
end;
/
create or replace PROCEDURE PBH_HD_VUOT(
    b_ma_dvi varchar2,b_so_id number,b_vuot out number,b_loi out varchar2)
AS
    b_i1 number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tso varchar2(500);
    b_so_hd varchar2(20); b_ngay_ht number; b_ngay_hl number; b_nv varchar2(10);
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
    a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar; 
begin
-- Dan - Tra ty le vuot tai co dinh max
b_vuot:=0;
if FBH_HD_CO_TAM(b_ma_dvi,b_so_id)<>'C' then b_loi:=''; return; end if;
select so_hd,ngay_ht,ngay_hl,nt_tien,nt_phi,nv into b_so_hd,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,b_nv
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_id,a_so_id_dt);
b_tso:='{"ttrang":"T","xly":"F"}';
for b_lp in 1..a_so_id_dt.count loop
    PTBH_TMB_CBI_DT(b_nv,b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,b_tso);
    if b_loi is not null then return; end if;
    select nvl(max(pt),0) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_vuot<b_i1 then b_vuot:=b_i1; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_VUOT:loi'; end if;
end;
/
create or replace PROCEDURE PBH_HD_VUOTs(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_vuot out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_so_hd varchar2(20); b_ngay_ht number; b_ngay_hl number; b_ngay_kt number;
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
    a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar; 
begin
-- Dan - Kiem tra vuot tai
b_vuot:='K';
if FBH_HD_CO_TAM(b_ma_dvi,b_so_id)<>'C' then b_loi:=''; return; end if;
PTBH_SOAN_TTINf(b_ma_dvi,b_so_id,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_loi);
if b_loi is not null then return; end if;
PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_id,a_so_id_dt,b_nv);
for b_lp in 1..a_so_id_dt.count loop
    PTBH_TMB_CBI_DT(b_nv,b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi,'T');
    if b_loi is not null then return; end if;
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then b_vuot:='C'; exit; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_VUOTs:loi'; end if;
end;
/
create or replace function FBH_HD_NV_RUT(b_nv varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh nghiep vu
if b_nv='2BL' then b_kq:='2B';
elsif b_nv='XEL' then b_kq:='XE';
elsif b_nv='TAUL' then b_kq:='TAU';
elsif b_nv='BAYL' then b_kq:='BAY';
elsif b_nv='NGL' then b_kq:='NG';
elsif b_nv='SKL' then b_kq:='SK';
elsif b_nv='HANGL' then b_kq:='HANG';
elsif b_nv='PHHL' then b_kq:='PHH';
elsif b_nv='PHOL' then b_kq:='PHO';
elsif b_nv='PNAL' then b_kq:='PNA';
else b_kq:=b_nv;
end if;
return b_kq;
end;
/