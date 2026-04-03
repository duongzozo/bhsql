-- Ty le phi
create or replace procedure PBH_TPA_PHI_TLE(
    b_ma varchar2,b_tl_phi out number,b_t_suat out number)
AS
    b_i1 number;
begin
-- Dan - Tra ty le phi, thue suat
select nvl(max(ngay_bd),0) into b_i1 from bh_tpa_phi where ma=b_ma;
select nvl(min(tl_phi),0),nvl(min(t_suat),0) into b_tl_phi,b_t_suat
    from bh_tpa_phi where ma=b_ma and ngay_bd=b_i1;
end;
/
create or replace procedure PBH_TPA_PHI_TPA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(1000);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into b_oraOut from
    bh_ma_gdinh where FBH_MA_GDINH_NV(ma,'NG')='C' and FBH_MA_GDINH_HAN(ma)='C';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_PHI_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(500):=FKH_JS_GTRIs(b_oraIn,'ma'); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma=' ' then b_loi:='loi:Nhap ma TPA:loi'; raise PROGRAM_ERROR; end if;
-- chuclh ma-ten
b_ma:=PKH_MA_TENl(b_ma);
select count(*) into b_i1 from bh_tpa_phi where ma=b_ma;
if b_i1 <= 0 then 
  select json_object('ma' value FBH_DTAC_MA_TENl(b_ma),'tl_phi' value 0,'t_suat' value 0) into cs_ct from dual;
  select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
else
  select json_object('ma' value FBH_DTAC_MA_TENl(ma),'tl_phi' value tl_phi,'t_suat' value t_suat) into cs_ct from bh_tpa_phi where ma=b_ma;
  select json_object('cs_ct' value cs_ct) into b_oraOut from bh_tpa_phi where ma=b_ma;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_PHI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(ma),tl_phi,t_suat,ma) order by ma) into b_oraOut from bh_tpa_phi;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_PHI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_i1 number;
    b_ma varchar2(20); b_tl_phi number; b_t_suat number; b_ngay_bd number;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tl_phi,t_suat,ngay_bd');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tl_phi,b_t_suat,b_ngay_bd using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma TPA:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_gdinh where ma=b_ma;
if b_i1=0 then b_loi:='loi:Ma TPA chua khai bao:loi'; raise PROGRAM_ERROR; end if;
b_tl_phi:=nvl(b_tl_phi,0); b_t_suat:=nvl(b_t_suat,0);
if b_ngay_bd in(0,30000101) then b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
delete bh_tpa_phi where ma=b_ma;
insert into bh_tpa_phi values(b_ma_dvi,b_ma,b_tl_phi,b_t_suat,b_ngay_bd,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_PHI_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn cLob)
AS
    b_loi varchar2(100); b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma=' ' then b_loi:='loi:Nhap ma TPA:loi'; raise PROGRAM_ERROR; end if;
delete bh_tpa_phi where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Hop dong
create or replace procedure PBH_TPA_HD_XOA(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_so_id_tr number;
begin
-- Dan - Xoa phat sinh hop dong TPA
select count(*),max(so_id_tr) into b_i1,b_so_id_tr
    from bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1<>0 then
    if b_so_id_tr<>0 then b_loi:='loi:Khong sua, xoa hop dong da thanh toan TPA:loi'; return; end if;
    delete bh_tpa_hd_pt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
    delete bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TPA_HD_XOA:loi'; end if;
end;
/
create or replace procedure PBH_TPA_HD_PS(
    b_ma_dvi varchar2,b_so_id_tt number,b_loi out varchar2)
as
    b_so_id number; b_nv varchar2(10); b_ngay_ht number; b_tien number;
begin
-- Dan - Phat sinh hop dong
select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_goc_ttps where so_id_tt=b_so_id_tt;
if b_ngay_ht=0 then b_loi:=''; return; end if;
for r_lp in (select so_id,sum(tien) tien from bh_hd_goc_tthd where so_id_tt=b_so_id_tt and pt in('G','N') group by so_id) loop
    b_so_id:=r_lp.so_id; b_nv:=FBH_NG_NV(b_ma_dvi,b_so_id);
    if b_nv in ('SKT','SKU') then
        PBH_TPA_HD_PSh(b_ma_dvi,b_so_id_tt,b_so_id,b_nv,b_ngay_ht,r_lp.tien,b_loi);
        if b_loi is not null then return; end if;
    elsif b_nv in ('SKC','SKG') then
        PBH_TPA_HD_PSc(b_ma_dvi,b_so_id_tt,b_so_id,b_nv,b_ngay_ht,r_lp.tien,b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TPA_HD_PS:loi'; end if;
end;
/
create or replace procedure PBH_TPA_HD_PSc(
    b_ma_dvi varchar2,b_so_id_tt number,b_so_id number,b_nv varchar2,b_ngay_ht number,b_phi number,b_loi out varchar2)
AS
    b_i1 number; b_tp number:=0; b_tg number:=1; b_phiH number;
    b_so_idB number; b_so_hd varchar2(20); b_nt_phi varchar2(5);
    b_tpa varchar2(20); b_tl_phi number; b_t_suat number;
    b_tpa_phi number; b_tpa_thue number; b_tpa_phi_qd number; b_tpa_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
begin
-- Dan - Phat sinh nv=ca nhan, gia dinh
b_so_idB:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id);
select nt_phi,tpa,phi into b_nt_phi,b_tpa,b_phiH from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_tpa=' ' or b_phiH=0 then b_loi:=''; return; end if;
PBH_TPA_PHI_TLE(b_tpa,b_tl_phi,b_t_suat);
if b_tl_phi=0 then b_loi:=''; return; end if;
select so_hd into b_so_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_tpa_phi:=round(b_tl_phi*b_phi/100,b_tp); b_tpa_thue:=round(b_tpa_phi*b_t_suat/100,b_tp);
if b_nt_phi='VND' then
    b_tpa_phi_qd:=b_tpa_phi; b_tpa_thue_qd:=b_tpa_thue;
else
    b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
    b_tpa_phi_qd:=round(b_tg*b_tpa_phi,0); b_tpa_thue_qd:=round(b_tg*b_tpa_thue,0);
end if;
insert into bh_tpa_hd values(b_ma_dvi,b_so_id_tt,b_so_id,b_so_hd,b_ngay_ht,b_nv,
    b_nt_phi,b_phi,b_tpa,b_tpa_phi,b_tpa_thue,b_tpa_phi_qd,b_tpa_thue_qd,0,0);
b_i1:=b_tpa_phi/b_phiH;
select so_id_dt,lh_nv,tien bulk collect into a_so_id_dt,a_lh_nv,a_tien
    from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ';
for b_lp in 1..a_lh_nv.count loop
    if b_lp=a_lh_nv.count then
        a_tien(b_lp):=b_tpa_phi;
    else
        a_tien(b_lp):=round(b_i1*a_tien(b_lp),b_tp); b_tpa_phi:=b_tpa_phi-a_tien(b_lp);
    end if;
    a_thue(b_lp):=round(a_tien(b_lp)*b_t_suat/100,b_tp);
end loop;
if b_nt_phi='VND' then
    for b_lp in 1..a_lh_nv.count loop
        a_tien_qd(b_lp):=a_tien(b_lp); a_thue_qd(b_lp):=a_thue(b_lp);
    end loop;
else
    for b_lp in 1..a_lh_nv.count loop
        a_tien_qd(b_lp):=round(b_tg*a_tien(b_lp),0);
        a_thue_qd(b_lp):=round(b_tg*a_thue(b_lp),0);
    end loop;
end if;
forall b_lp in 1..a_lh_nv.count
    insert into bh_tpa_hd_pt values(b_ma_dvi,b_so_id_tt,b_ngay_ht,b_so_id,a_so_id_dt(b_lp),
        a_lh_nv(b_lp),b_nt_phi,a_tien(b_lp),a_thue(b_lp),a_tien_qd(b_lp),a_thue_qd(b_lp));
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TPA_HD_PSc:loi'; end if;
end;
/
create or replace procedure PBH_TPA_HD_PSh(
    b_ma_dvi varchar2,b_so_id_tt number,b_so_id number,b_nv varchar2,b_ngay_ht number,b_phiT number,b_loi out varchar2)
AS
    b_i1 number; b_tp number:=0; b_tg number:=1; b_so_idB number; b_so_hd varchar2(20);
    b_nt_phi varchar2(5); b_phi number; b_phiH number; b_tpa varchar2(20); b_tpaH varchar2(20);
    b_tl_phiH number:=0; b_t_suatH number:=0; b_tl_phi number; b_t_suat number;
    b_tpa_phi number; b_tpa_thue number; b_tpa_phi_qd number; b_tpa_thue_qd number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
begin
-- Dan - Phat sinh nv=to chuc
b_so_idB:=FBH_SK_SO_IDb(b_ma_dvi,b_so_id);
select nt_phi,tpa,phi into b_nt_phi,b_tpaH,b_phiH from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
select so_hd into b_so_hd from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_tpaH<>' ' then
    PBH_TPA_PHI_TLE(b_tpaH,b_tl_phiH,b_t_suatH);
end if;
if b_nt_phi<>'VND' then
    b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
end if;
b_phiH:=b_phiT/b_phiH;
for r_lp in(select tpa,sum(phi*so_dt) phi from bh_sk_nh where ma_dvi=b_ma_dvi and so_id=b_so_idB group by tpa) loop
    if r_lp.tpa=' ' then
        b_tpa:=b_tpaH;
        b_tl_phi:=b_tl_phiH; b_t_suat:=b_t_suatH;
    else
        b_tpa:=r_lp.tpa;
        PBH_TPA_PHI_TLE(b_tpa,b_tl_phi,b_t_suat);
    end if;
    if b_tl_phi=0 then continue; end if;
    b_phi:=round(b_phiH*r_lp.phi,b_tp);
    b_tpa_phi:=round(b_tl_phi*b_phi/100,b_tp); b_tpa_thue:=round(b_tpa_phi*b_t_suat/100,b_tp);
    if b_nt_phi='VND' then
        b_tpa_phi_qd:=b_tpa_phi; b_tpa_thue_qd:=b_tpa_thue;
    else
        b_tpa_phi_qd:=round(b_tg*b_tpa_phi,0); b_tpa_thue_qd:=round(b_tg*b_tpa_thue,0);
    end if;
    insert into bh_tpa_hd values(b_ma_dvi,b_so_id_tt,b_so_id,b_so_hd,b_ngay_ht,b_nv,b_nt_phi,b_phi,
        b_tpa,b_tpa_phi,b_tpa_thue,b_tpa_phi_qd,b_tpa_thue_qd,0,0);
    b_i1:=b_tpa_phi/r_lp.phi;
    select so_id_dt,lh_nv,tien bulk collect into a_so_id_dt,a_lh_nv,a_tien from bh_sk_dk where
        ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' and so_id_dt in
        (select distinct b.so_id_dt from bh_sk_nh a,bh_sk_ds b where
            a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and a.tpa=r_lp.tpa and
            b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.nhom=a.nhom);
    for b_lp in 1..a_lh_nv.count loop
        if b_lp=a_lh_nv.count then
            a_tien(b_lp):=b_tpa_phi;
        else
            a_tien(b_lp):=round(b_i1*a_tien(b_lp),b_tp); b_tpa_phi:=b_tpa_phi-a_tien(b_lp);
        end if;
        a_thue(b_lp):=round(a_tien(b_lp)*b_t_suat/100,b_tp);
    end loop;
    if b_nt_phi='VND' then
        for b_lp in 1..a_lh_nv.count loop
            a_tien_qd(b_lp):=a_tien(b_lp); a_thue_qd(b_lp):=a_thue(b_lp);
        end loop;
    else
        for b_lp in 1..a_lh_nv.count loop
            a_tien_qd(b_lp):=round(b_tg*a_tien(b_lp),0);
            a_thue_qd(b_lp):=round(b_tg*a_thue(b_lp),0);
        end loop;
    end if;
    forall b_lp in 1..a_lh_nv.count
        insert into bh_tpa_hd_pt values(b_ma_dvi,b_so_id_tt,b_ngay_ht,b_so_id,a_so_id_dt(b_lp),
            a_lh_nv(b_lp),b_nt_phi,a_tien(b_lp),a_thue(b_lp),a_tien_qd(b_lp),a_thue_qd(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TPA_HD_PSh:loi'; end if;
end;
/
create or replace procedure PBH_TPA_HD_HUY(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
as
    b_nv varchar2(10); b_ngay_ht number; b_tien number; b_tra number; b_so_id_tt number;
begin
-- Dan - Phat sinh hop dong
b_nv:=FBH_NG_NV(b_ma_dvi,b_so_id);
if substr(b_nv,1,2)<>'SK' then b_loi:=''; return; end if;
select nvl(min(ngay_ht),0),nvl(min(hoanP),0),nvl(min(tra),0) into b_ngay_ht,b_tien,b_tra from bh_hd_goc_hu where so_id=b_so_id;
if b_tra=0 or b_tien=0 then b_loi:=''; return; end if;
b_so_id_tt:=b_so_id*10;
if b_nv in ('SKH','SKU') then
    PBH_TPA_HD_PSh(b_ma_dvi,b_so_id_tt,b_so_id,b_nv,b_ngay_ht,-b_tien,b_loi);
else
    PBH_TPA_HD_PSc(b_ma_dvi,b_so_id_tt,b_so_id,b_nv,b_ngay_ht,-b_tien,b_loi);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TPA_HD_HUY:loi'; end if;
end;
/
-- Thanh toan
create or replace function FBH_TPA_TT_TXT(b_ma_dvi varchar2,b_so_id_tr number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_tpa_tra_txt where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_tpa_tra_txt where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_TPA_TT_TPA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(2000);
begin
-- Dan - Tra ton TPA
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma' value tpa,'ten' value FBH_DTAC_MA_TEN(tpa))) into b_oraOut from 
    (select distinct tpa from bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tr=0);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_tpa varchar2(20):=trim(b_oraIn);
begin
-- Dan - Tra ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tpa=' ' then b_loi:='loi:Nhap ma TPA:loi'; raise PROGRAM_ERROR; end if;
-- nam: chinh key chu thuong
select JSON_ARRAYAGG(json_object(
    'ngay_ht' value ngay_ht,'so_hd' value so_hd,'nt_phi' value nt_phi,'phi' value phi,'tpa_phi' value tpa_phi,'tpa_thue' value tpa_thue,
    'chon' value '','tpa_phi_qd' value tpa_phi_qd,'tpa_thue_qd' value tpa_thue_qd,'so_id_tt' value so_id_tt,'so_id' value so_id)
    order by ngay_ht,so_hd returning clob) into b_oraOut
    from bh_tpa_hd where ma_dvi=b_ma_dvi and tpa=b_tpa and so_id_tr=0;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_tr number:=FKH_JS_GTRIn(b_oraIn,'so_id_tr');
    dt_ct clob; dt_hd clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thanh toan da xoa:loi';
select json_object(so_ct,'tpa' value FBH_DTAC_MA_TENl(tpa)) into dt_ct
    from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
select JSON_ARRAYAGG(json_object(
    'ngay_ht' value ngay_ht,'so_hd' value so_hd,'nt_phi' value nt_phi,'phi' value phi,'tpa_phi' value tpa_phi,
    'tpa_thue' value tpa_thue,'chon' value '','tpa_phi_qd' value tpa_phi_qd,'tpa_thue_qd' value tpa_thue_qd,
    'so_id_tt' value so_id_tt,'so_id' value so_id,'tpa' value tpa) order by ngay_ht,so_hd returning clob) into dt_hd
    from bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_tpa_tra_txt where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr and loai='dt_ct';
select json_object('so_id_tr' value b_so_id_tr,'dt_hd' value dt_hd,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';    
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_tpa_tra where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(tpa),so_id_tr) returning clob) into cs_lke from
            (select so_id_tr,tpa,rownum sott from bh_tpa_tra where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tr desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from bh_tpa_tra where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(tpa),so_id_tr) returning clob) into cs_lke from
            (select so_id_tr,tpa,rownum sott from bh_tpa_tra where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id_tr desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id_tr number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_tr,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id_tr,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_tpa_tra where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tr,rownum sott from bh_tpa_tra where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tr desc) where so_id_tr<=b_so_id_tr;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(tpa),so_id_tr) returning clob) into cs_lke from
        (select so_id_tr,tpa,rownum sott from bh_tpa_tra where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id_tr desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_tpa_tra where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tr,rownum sott from bh_tpa_tra where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id_tr desc) where so_id_tr<=b_so_id_tr;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object('ten' value FBH_DTAC_MA_TEN(tpa),so_id_tr) returning clob) into cs_lke from
        (select so_id_tr,tpa,rownum sott from bh_tpa_tra where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id_tr desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_TEST(
    b_ma_dvi varchar2,b_so_id_tr number,dt_ct in out clob,dt_hd clob,
    b_ngay_ht out number,b_so_ct out varchar2,b_pt_tra out varchar2,b_tpa out varchar2,
    b_tien_qd out number,b_thue_qd out number,b_nt_tra out varchar2,b_tra out number,b_tra_qd out number,
    a_so_id_tt out pht_type.a_num,a_so_id out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000);
    a_so_hd pht_type.a_var;
begin
-- Dan kiem tra thong tin nhap
b_lenh:=FKH_JS_LENH('ngay_ht,so_ct,pt_tra,tpa,nt_tra,tra');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_ct,b_pt_tra,b_tpa,b_nt_tra,b_tra using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_tt,so_id,so_hd');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id_tt,a_so_id,a_so_hd using dt_hd;
if b_pt_tra not in('T','C') then b_loi:='loi:Sai phuong thuc tra:loi'; return; end if;
if a_so_id.count=0 then b_loi:='loi:Nhap hop dong thanh toan:loi'; return; end if;
if b_tpa=' ' then b_loi:='loi:Nhap ma TPA:loi'; return; end if;
if b_nt_tra=' ' or FBH_TT_KTRA(b_nt_tra)='K' then b_loi:='loi:Sai loai tien tra:loi'; return; end if;
b_tien_qd:=0; b_thue_qd:=0;
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi';
    if a_so_id_tt(b_lp)=0 or a_so_id(b_lp)=0 then return; end if;
    select nvl(sum(tpa_phi_qd),0),nvl(sum(tpa_thue_qd),0) into b_i1,b_i2
        from bh_tpa_hd where ma_dvi=b_ma_dvi and so_id_tt=a_so_id_tt(b_lp) and so_id=a_so_id(b_lp) and tpa=b_tpa and so_id_tr=0;
    if b_i1=0 then b_loi:='loi:Thanh toan hop dong '||a_so_hd(b_lp)||' da tra TPA:loi'; return; end if;
    b_tien_qd:=b_tien_qd+b_i1; b_thue_qd:=b_thue_qd+b_i2;
end loop;
if b_nt_tra='VND' then b_tra_qd:=b_tra; else b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra); end if;
b_so_ct:=substr(to_char(b_so_id_tr),3);
PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TPA_TT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tr number,dt_ct clob,dt_hd clob,
    b_ngay_ht number,b_so_ct varchar2,b_loai varchar2,b_pt_tra varchar2,b_tpa varchar2,
    b_tien_qd number,b_thue_qd number,b_nt_tra varchar2,b_tra number,b_tra_qd number,
    a_so_id_tt pht_type.a_num,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Nhap thanh toan boi thuong
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','NG');
if b_loi is not null then return; end if;
insert into bh_tpa_tra values(
    b_ma_dvi,b_so_id_tr,b_ngay_ht,b_so_ct,b_loai,b_pt_tra,b_tpa,b_tien_qd,b_thue_qd,b_nt_tra,b_tra,b_tra_qd,b_nsd,sysdate,0);
for b_lp in 1..a_so_id.count loop
    update bh_tpa_hd set so_id_tr=b_so_id_tr where ma_dvi=b_ma_dvi and so_id_tt=a_so_id_tt(b_lp) and so_id=a_so_id(b_lp) and tpa=b_tpa;
end loop;
insert into bh_tpa_tra_txt values(b_ma_dvi,b_so_id_tr,'dt_ct',dt_ct);
insert into bh_tpa_tra_txt values(b_ma_dvi,b_so_id_tr,'dt_hd',dt_hd);
for b_lp in 1..a_so_id.count loop
    PBH_TH_DO_TPA(b_ma_dvi,b_so_id_tr,a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
--PTBH_TH_TA_TPA(b_ma_dvi,b_so_id_tr,b_loi);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TPA_TT_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_TPA_TT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tr number,b_loi out varchar2)
AS 
    b_i1 number; b_ngay_ht number; b_so_id number; b_tien number; b_tien_qd number;
    b_nsdC varchar2(10); b_ma_nt varchar2(5); b_ma_kh varchar2(20); b_pt_tra varchar2(1);
    b_nbh varchar2(20); b_phong varchar2(10);
    r_hd bh_tpa_tra%rowtype;
Begin
-- Dan - Xoa thanh toan boi thuong
select count(*) into b_i1 from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hd from bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr for update nowait;
if sql%rowcount=0 then b_loi:='loi:Thanh toan dang xu ly:loi'; return; end if;
if b_nsd<>r_hd.nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hd.ngay_ht,'BH','NG');
if b_loi is not null then return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id_tr,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id_tr,0,0,0,b_loi);
if b_loi is not null then return; end if;
update bh_tpa_hd set so_id_tr=0 where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
delete bh_tpa_tra_txt where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
delete bh_tpa_tra where ma_dvi=b_ma_dvi and so_id_tr=b_so_id_tr;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TPA_TT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi nvarchar2(200); b_lenh varchar2(2000);
    dt_ct clob; dt_hd clob;
    b_so_id_tr number; b_ngay_ht number; b_so_ct varchar2(20); b_loai varchar2(1); b_pt_tra varchar2(1);
    b_tpa varchar2(20); b_tien_qd number; b_thue_qd number; b_nt_tra varchar2(5); b_tra number; b_tra_qd number; 
    a_so_id_tt pht_type.a_num; a_so_id pht_type.a_num;
begin
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tr:=FKH_JS_GTRIn(b_oraIn,'so_id_tr');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
if b_so_id_tr=0 then
    PHT_ID_MOI(b_so_id_tr,b_loi);
else
    PBH_TPA_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tr,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd);
PBH_TPA_TT_TEST(
    b_ma_dvi,b_so_id_tr,dt_ct,dt_hd,b_ngay_ht,b_so_ct,b_pt_tra,b_tpa,
    b_tien_qd,b_thue_qd,b_nt_tra,b_tra,b_tra_qd,a_so_id_tt,a_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_TPA_TT_NH_NH(
    b_ma_dvi,b_nsd,b_so_id_tr,dt_ct,dt_hd,
    b_ngay_ht,b_so_ct,b_loai,b_pt_tra,b_tpa,b_tien_qd,b_thue_qd,b_nt_tra,b_tra,b_tra_qd,a_so_id_tt,a_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_tr' value b_so_id_tr,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi nvarchar2(200); b_so_id_tr number;
begin
-- Dan - Xoa thanh toan boi thuong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tr:=FKH_JS_GTRIn(b_oraIn,'so_id_tr');
if b_so_id_tr is null or b_so_id_tr=0 then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_TPA_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tr,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_TPA_TT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob;
    b_dong number; b_ngayD number; b_ngayC number; b_tpa varchar2(20);
begin
-- Dan - Tim thanh toan qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,tpa');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_tpa using b_oraIn;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_tpa:=nvl(trim(b_tpa),' ');
select count(*) into b_dong from bh_tpa_tra where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_tpa in(' ',tpa);
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,'ten' value FBH_DTAC_MA_TEN(tpa),nt_tra,tra,so_id_tr)
	order by ngay_ht desc,so_ct returning clob) into cs_lke
    from bh_tpa_tra where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_tpa in(' ',tpa);
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
