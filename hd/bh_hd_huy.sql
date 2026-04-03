/*** Huy hop dong ***/
create or replace function FBH_HD_HU_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_HD_HU
    (b_ma_dvi varchar2,b_so_id varchar2,b_ngay_ht number:=30000101) return varchar2
AS
    b_kq varchar2(1):='K'; b_ngayP number; b_ngayH number;
begin
-- Dan - Kiem tra hop dong huy
select nvl(max(ngay_ht),0) into b_ngayH from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
if b_ngayH<>0 then
	select nvl(max(ngay_ht),0) into b_ngayP from bh_hd_goc_phoi where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
	if b_ngayP<b_ngayH then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_HU_NGAY
    (b_ma_dvi varchar2,b_so_id varchar2,b_ngay_ht number:=30000101) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay huy gan nhat
select nvl(max(ngay_ht),0) into b_kq from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FBH_HD_HU_HOAN
    (b_ma_dvi varchar2,b_so_id varchar2,b_ngay_ht number:=30000101) return number
AS
    b_kq number:=0; b_ngayH number;
begin
-- Dan - Tra so hoan
select nvl(max(ngay_ht),0) into b_ngayH from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
if b_ngayH<>0 then
	select nvl(max(hoanP),0) into b_kq from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_HU_TLE(
    b_ma_dvi varchar2,b_so_id varchar2,b_ngay_ht number:=30000101,b_hoanN number:=0) return number
AS
     b_i1 number; b_so_idB number; b_ngayH number; b_hoanP number; b_phi number;
begin
-- Dan - Tra ty le huy so voi tong phi
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
select nvl(sum(phi),0) into b_phi from bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB and lh_nv<>' ';
if b_phi=0 then return 0; end if;
select nvl(sum(tien),0) into b_hoanP from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='C';
select nvl(sum(tien),0) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='N';
b_hoanP:=b_hoanP-b_i1;
if b_hoanP=0 then b_hoanP:=b_hoanN; end if;
if b_hoanP=0 then
    select nvl(max(ngay_ht),0) into b_ngayH from bh_hd_goc_hu
        where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
    if b_ngayH<>0 then
        select hoanP into b_hoanP from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
    end if;
end if;
return round(b_hoanP*100/b_phi,0);
end;
/
create or replace procedure PBH_HD_HU_SO_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_so_hd varchar2(20):=trim(b_oraIn);
    b_so_idD number; b_so_idB number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_ngayH number; b_tp number:=0; b_bth number; b_choP number:=0; b_choT number:=0;
    b_phi number; b_thue number; b_phiB number; b_phiT number; b_nopP number; b_nopT number;
    b_con number:=0; b_hoanP number:=0; b_hoanT number:=0; b_tra number:=0;
    r_hd bh_hd_goc%rowtype;
begin
-- Dan - Thong tin hop dong huy
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_hd is null then b_loi:='loi:Nhap hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_idD:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_idD=0 then b_loi:='loi:Hop dong, GCN da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ngayH:=FBH_HD_HU_NGAY(b_ma_dvi,b_so_idD);
if b_ngayH<>0 and FBH_HD_HU(b_ma_dvi,b_so_idD)='C' then
    select txt into b_oraOut from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_idD and ngay_ht=b_ngayH;
else
    b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_idD);
    select min(nt_tien),min(nt_phi),sum(phi),sum(thue) into b_nt_tien,b_nt_phi,b_phi,b_thue
        from bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    select nvl(sum(phi),0) into b_phiB from bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB and FBH_MA_LHNV_BB(lh_nv)='B';
    select nvl(sum(phi),0) into b_phiT from bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_idB and FBH_MA_LHNV_BB(lh_nv)='T';
    select nvl(sum(phi),0),nvl(sum(thue),0) into b_choP,b_choT from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD and pt='C';
    select nvl(sum(phi),0),nvl(sum(thue),0) into b_i1,b_i2 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD and pt='N';
    b_choP:=b_choP-b_thue-b_i1+b_i2; b_choT:=b_choT-b_i2;
    if b_choP<0 then b_choP:=0; b_choT:=0; end if;
    select nvl(sum(b.tien),0) into b_bth from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_idD and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
    select * into r_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    b_i1:=FKH_KHO_NGSO(r_hd.ngay_hl,r_hd.ngay_kt);
    if b_choP=0 and b_bth=0 and b_nopP>b_phiB and b_i1>0 then
        b_ngayH:=PKH_NG_CSO(sysdate); b_i2:=FKH_KHO_NGSO(r_hd.ngay_hl,b_ngayH);
        if b_i2>0 then
            b_con:=round((b_i1-b_i2)*100/b_i1,2);
            if b_nt_phi<>'VND' then b_tp:=2; end if;
            b_hoanP:=round((b_nopP-b_phiB)*b_con/100,b_tp);
            b_hoanT:=round(b_nopT*b_con/100,b_tp);
            b_tra:=b_hoanP+b_hoanT;
        end if;
    end if;
    select json_object('so_hd' value b_so_hd,'ma_kh' value r_hd.ma_kh,'ten' value r_hd.ten,
        'ngay_hl' value r_hd.ngay_hl,'ngay_kt' value r_hd.ngay_kt,'nt_tien' value b_nt_tien,'bth' value b_bth,
        'nt_phi' value b_nt_phi,'phi' value b_phi,'thue' value b_thue,'phiB' value b_phiB,'phiT' value b_phiT,
        'nopP' value b_nopP,'nopT' value b_nopT,'choP' value b_choP,'choT' value b_choT,
        'con' value b_con,'hoanP' value b_hoanP,'hoanT' value b_hoanT,
        'nt_tra' value b_nt_phi,'tra' value b_tra returning clob) into b_oraOut from dual;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_hu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_hu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HU_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_hd varchar2(20); b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_hd,rownum sott from bh_hd_goc_hu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd) where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_hu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_hd,rownum sott from bh_hd_goc_hu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd) where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_hd,ngay_ht) returning clob) into cs_lke from
        (select so_hd,ngay_ht,rownum sott from bh_hd_goc_hu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_so_id number; b_ngay_ht number; b_ngayH number;
begin
-- Dan - Xem chi tiet huy hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht using b_oraIn;
if trim(b_so_hd)='' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
b_ngay_ht:=nvl(b_ngay_ht,0);
b_ngayH:=FBH_HD_HU_NGAY(b_ma_dvi,b_so_id,b_ngay_ht);
if b_ngayH=0 then b_loi:='loi:Cham dut hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select txt into b_oraOut from bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
--duong tra ve so_id 
PKH_JS_THAY_D(b_oraOut,'so_id',b_so_id);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HU_PT(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_tp number; b_ngay_ht number; b_nv varchar2(10);
    b_ma_nt varchar2(5); b_so_idB number; b_tl number; b_choP number;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_phi pht_type.a_num;
    a_phi_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
Begin
-- Dan - Phan tich
select nt_phi,ngay_ht,nv into b_ma_nt,b_ngay_ht,b_nv from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_tl:=FBH_HD_HU_TLE(b_ma_dvi,b_so_id,b_ngay_ht);
if b_tl=0 then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
if b_ma_nt<>'VND' then b_tp:=2; end if;
select so_id_dt,lh_nv,phi,thue bulk collect into a_so_id_dt,a_lh_nv,a_phi,a_thue
    from bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
for b_lp in 1..a_so_id_dt.count loop
    a_phi(b_lp):=round(a_phi(b_lp)*b_tl/100,b_tp); a_thue(b_lp):=round(a_thue(b_lp)*b_tl/100,b_tp);
end loop;
if b_ma_nt<>'VND' then
    b_tl:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    for b_lp in 1..a_so_id_dt.count loop
        a_phi_qd(b_lp):=round(a_phi(b_lp)*b_tl,0); a_thue_qd(b_lp):=round(a_thue(b_lp)*b_tl,0);
    end loop;
else
    for b_lp in 1..a_so_id_dt.count loop
        a_phi_qd(b_lp):=a_phi(b_lp); a_thue_qd(b_lp):=a_thue(b_lp);
    end loop;
end if;
for b_lp in 1..a_so_id_dt.count loop
    insert into bh_hd_goc_hupt values(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),b_nv,a_lh_nv(b_lp),
        b_ma_nt,a_phi(b_lp),a_phi_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp),b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HU_PT:loi'; else null; end if;
end;
/
create or replace procedure PBH_HD_HU_TH(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=10000;
    b_tl number; b_tp number:=0; b_so_id_tt number; b_nv varchar2(10);
    b_ngay_ht number; b_hthue varchar2(1); b_kvat varchar2(1); b_nt_phi varchar2(5); b_tra number;
    dk_so_id_dt pht_type.a_num; dk_ngay pht_type.a_num; dk_lh_nv pht_type.a_var;
    dk_ma_dt pht_type.a_var; dk_t_suat pht_type.a_num;
    dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_ttoan pht_type.a_num;
    dk_hhong pht_type.a_num; dk_htro pht_type.a_num; dk_dvu pht_type.a_num;
    dk_hhong_qd pht_type.a_num; dk_htro_qd pht_type.a_num; dk_dvu_qd pht_type.a_num;
    dk_phi_qd pht_type.a_num; dk_thue_qd pht_type.a_num; dk_ttoan_qd pht_type.a_num;
    dk_hhong_tl pht_type.a_num; dk_htro_tl pht_type.a_num; dk_dvu_tl pht_type.a_num;
    pbo_ma_dvi pht_type.a_var; pbo_so_id_tt pht_type.a_num; pbo_phi pht_type.a_num;
begin
-- Dan - Phan tich huy hop dong
b_so_id_tt:=b_so_id*10;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select tra,nt_phi,ngay_ht,hthue,kvat,con,nv into b_tra,b_nt_phi,b_ngay_ht,b_hthue,b_kvat,b_tl,b_nv
    from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_tl=0 then b_loi:=''; return; end if;
b_tl:=b_tl/100;
select so_id_dt,ngay,lh_nv,ma_dt,t_suat,
    sum(decode(pt,'N',0,phi)) phi,sum(decode(pt,'N',0,thue)) thue,
    sum(decode(pt,'N',0,phi_qd)) phi_qd,sum(decode(pt,'N',0,thue_qd)) thue_qd,
    sum(decode(pt,'C',0,hhong)) hhong,sum(decode(pt,'C',0,htro)) htro,sum(decode(pt,'C',0,dvu)) dvu,
    sum(decode(pt,'C',0,hhong_qd)) hhong_qd,sum(decode(pt,'C',0,htro_qd)) htro_qd,sum(decode(pt,'C',0,dvu_qd)) dvu_qd,
    max(hhong_tl) hhong_tl,max(htro_tl) htro_tl,max(dvu_tl) dvu_tl bulk collect into 
    dk_so_id_dt,dk_ngay,dk_lh_nv,dk_ma_dt,dk_t_suat,dk_phi,dk_thue_qd,dk_phi_qd,dk_thue,
    dk_hhong,dk_htro,dk_dvu,dk_hhong_qd,dk_htro_qd,dk_dvu_qd,dk_hhong_tl,dk_htro_tl,dk_dvu_tl
    from bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht
    group by so_id_dt,ngay,lh_nv,ma_dt,t_suat;
if b_nt_phi<>'VND' then b_tp:=2; end if;
if b_hthue<>'C' then
    for b_lp in 1..dk_lh_nv.count loop
        dk_thue(b_lp):=0; dk_thue_qd(b_lp):=0;
    end loop;
end if;
for b_lp1 in 1..dk_lh_nv.count loop
    dk_phi(b_lp1):=round(dk_phi(b_lp1)*b_tl,b_tp); dk_thue(b_lp1):=round(dk_thue(b_lp1)*b_tl,b_tp);
    dk_phi_qd(b_lp1):=round(dk_phi_qd(b_lp1)*b_tl,0); dk_thue_qd(b_lp1):=round(dk_thue_qd(b_lp1)*b_tl,0);
    dk_hhong(b_lp1):=round(dk_hhong(b_lp1)*b_tl,b_tp); dk_hhong_qd(b_lp1):=round(dk_hhong_qd(b_lp1)*b_tl,b_tp);
    dk_htro(b_lp1):=round(dk_htro(b_lp1)*b_tl,b_tp); dk_htro_qd(b_lp1):=round(dk_htro_qd(b_lp1)*b_tl,b_tp);
    dk_dvu(b_lp1):=round(dk_dvu(b_lp1)*b_tl,b_tp); dk_dvu_qd(b_lp1):=round(dk_dvu_qd(b_lp1)*b_tl,b_tp);
    dk_ttoan(b_lp1):=dk_phi(b_lp1)+dk_thue(b_lp1); dk_ttoan_qd(b_lp1):=dk_phi_qd(b_lp1)+dk_thue_qd(b_lp1);
end loop;
for b_lp1 in 1..dk_lh_nv.count loop
    b_bt:=b_bt+1;
    insert into bh_hd_goc_ttptdt values(
        b_ma_dvi,b_so_id_tt,b_bt,b_so_id,dk_so_id_dt(b_lp1),b_nv,b_ngay_ht,b_ngay_ht,
        dk_ngay(b_lp1),'H',dk_ma_dt(b_lp1),b_nt_phi,dk_lh_nv(b_lp1),dk_t_suat(b_lp1),
        -dk_phi(b_lp1),-dk_thue(b_lp1),-dk_ttoan(b_lp1),-dk_hhong(b_lp1),-dk_htro(b_lp1),-dk_dvu(b_lp1),
        -dk_phi_qd(b_lp1),-dk_thue_qd(b_lp1),-dk_ttoan_qd(b_lp1),-dk_hhong_qd(b_lp1),-dk_htro_qd(b_lp1),-dk_dvu_qd(b_lp1),
        dk_hhong_tl(b_lp1),dk_htro_tl(b_lp1),dk_dvu_tl(b_lp1));
end loop;
select ngay,lh_nv,ma_dt,t_suat,sum(phi),sum(thue),sum(phi_qd),sum(thue_qd),
    sum(hhong),sum(htro),sum(dvu),sum(hhong_qd),sum(htro_qd),sum(dvu_qd) bulk collect into
    dk_ngay,dk_lh_nv,dk_ma_dt,dk_t_suat,dk_phi,dk_thue,dk_phi_qd,dk_thue_qd,
    dk_hhong,dk_htro,dk_dvu,dk_hhong_qd,dk_htro_qd,dk_dvu_qd
    from bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt group by ngay,lh_nv,ma_dt,t_suat;
for b_lp1 in 1..dk_lh_nv.count loop
    b_bt:=b_bt+1;
    if dk_phi(b_lp1)=0 then
        dk_hhong_tl(b_lp1):=0; dk_htro_tl(b_lp1):=0; dk_dvu_tl(b_lp1):=0;
    else
        dk_hhong_tl(b_lp1):=round(dk_hhong(b_lp1)*100/dk_phi(b_lp1),3);
        dk_htro_tl(b_lp1):=round(dk_htro(b_lp1)*100/dk_phi(b_lp1),3);
        dk_dvu_tl(b_lp1):=round(dk_dvu(b_lp1)*100/dk_phi(b_lp1),3);
    end if;
    dk_ttoan(b_lp1):=dk_phi(b_lp1)+dk_thue(b_lp1); dk_ttoan_qd(b_lp1):=dk_phi_qd(b_lp1)+dk_thue_qd(b_lp1);
    insert into bh_hd_goc_ttpt values(
        b_ma_dvi,b_so_id_tt,b_bt,b_so_id,b_nv,b_ngay_ht,b_ngay_ht,
        dk_ngay(b_lp1),'H',dk_ma_dt(b_lp1),b_nt_phi,dk_lh_nv(b_lp1),dk_t_suat(b_lp1),
        dk_phi(b_lp1),dk_thue(b_lp1),dk_ttoan(b_lp1),dk_hhong(b_lp1),dk_htro(b_lp1),dk_dvu(b_lp1),
        dk_phi_qd(b_lp1),dk_thue_qd(b_lp1),dk_ttoan_qd(b_lp1),dk_hhong_qd(b_lp1),dk_htro_qd(b_lp1),dk_dvu_qd(b_lp1),
        dk_hhong_tl(b_lp1),dk_htro_tl(b_lp1),dk_dvu_tl(b_lp1));
end loop;
PBH_HD_HU_PT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_tra=0 then return; end if;
PBH_TH_HH(b_ma_dvi,b_so_id,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
PBH_TPA_HD_HUY(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_TH_DO_HU(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TMN_HU(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_HU(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HU_TH:loi'; end if;
end;
/
create or replace PROCEDURE PBH_HD_HU_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,dt_ct in out clob,
    b_ngay_ht out number,b_con out number,b_nt_phi out varchar2,
    b_choP out number,b_choT out number,b_choP_qd out number,b_choT_qd out number,
    b_hoanP out number,b_hoanT out number,b_hoanP_qd out number,b_hoanT_qd out number,
    b_nt_tra out varchar2,b_pt_tra out varchar2,b_tra out number,b_tra_qd out number,
    b_hthue out varchar2,b_ma_kh out varchar2,b_ma_dl out varchar2,b_phong out varchar2,
    b_kvat out varchar2,b_so_don out varchar2,b_ma_ldo out varchar2,
    a_ma_nt_no out pht_type.a_var,a_tra out pht_type.a_num,
    a_ma_nt_xl out pht_type.a_var,a_ton out pht_type.a_num,a_no out pht_type.a_num,
    a_no_qd out pht_type.a_num,a_tra_xl out pht_type.a_num,
    a_pt out pht_type.a_var,a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num,
    a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; b_i4 number; b_lenh varchar2(2000); b_tg number:=1;
    b_phi number; b_ton number; b_no number; b_no_qd number;
    b_kieu_hd varchar2(1); b_kieu_kt varchar2(1); b_so_idB number;
begin
-- Dan - Kiem tra so lieu huy hop dong
b_lenh:=FKH_JS_LENH('ngay_ht,ma_kh,kvat,nt_phi,phi,con,hoanp,hoant,pt_tra,nt_tra,tra,ma_ldo');
EXECUTE IMMEDIATE b_lenh into
    b_ngay_ht,b_ma_kh,b_kvat,b_nt_phi,b_phi,b_con,b_hoanP,b_hoanT,b_pt_tra,b_nt_tra,b_tra,b_ma_ldo using dt_ct;
if b_ngay_ht=0 or b_kvat not in ('N','P','S','K') then
    b_loi:='loi:Nhap so lieu sai:loi'; return;
end if;
if FBH_HD_HU(b_ma_dvi,b_so_id,b_ngay_ht)<>'K' then b_loi:='loi:Hop dong da huy:loi'; return; end if;
b_i1:=FBH_HD_PHOI_NGAY(b_ma_dvi,b_so_id);
if b_ngay_ht<b_i1 then b_loi:='loi:Hop dong phuc hoi ngay '||PKH_SO_CNG(b_i1)||':loi'; return; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd); b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
select kieu_hd,ma_kh,kieu_kt,ma_kt,ngay_ht into b_kieu_hd,b_ma_kh,b_kieu_kt,b_ma_dl,b_i1
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngay_ht<b_i1 then b_loi:='loi:Huy truoc ngay phat sinh hop dong:loi'; return; end if;
if b_kieu_hd in('U','K') then b_loi:='loi:Kieu hop dong khong can huy:loi'; return; end if;
b_ma_ldo:=PKH_MA_TENl(b_ma_ldo);
if b_ma_ldo<>' ' and FBH_MA_HUY_HAN(b_ma_ldo)<>'C' then
    b_loi:='loi:Sai ma thong ke ly do huy:loi'; return;
end if;
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_hd=b_so_id and ttrang='D';
if b_i1<>0 then
    if b_hoanP>0 then b_loi:='loi:Khong hoan phi khi da co boi thuong:loi'; return; end if;
    if b_ngay_ht<=b_i1 then b_loi:='loi:Khong cham dut hop dong truoc ngay phat sinh boi thuong:loi'; return; end if;
end if;
if b_kieu_kt='T' then b_ma_dl:=' '; end if;
PKH_MANG_KD(a_ma_nt_no); PKH_MANG_KD(a_ma_nt_xl); PKH_MANG_KD(a_pt); PKH_MANG_KD(a_ma_nt);
if b_hoanP<=0 then b_loi:=''; return; end if;
if b_hoanP>FKH_JS_GTRIn(dt_ct,'nopp') then b_loi:='loi:Hoan phi nhieu hon so da thanh toan:loi'; return; end if;
if b_hoanT<>0 then
    if b_hoanT>FKH_JS_GTRIn(dt_ct,'nopt') then b_loi:='loi:Hoan thue nhieu hon so da thanh toan:loi'; return; end if;
    b_hthue:='C';
end if;
b_nt_tra:=nvl(trim(b_nt_tra),' ');
b_i1:=b_hoanP+b_hoanT;
if b_nt_phi=b_nt_tra and b_tra<>b_i1 then b_loi:='loi:Chenh tien tra:loi'; return; end if;
a_ma_nt_no(1):=b_nt_phi; a_tra(1):=b_i1;
if b_i1>0 then
    a_pt(1):=nvl(FKH_JS_GTRIs(dt_ct,'pt_tra'),' ');  a_tien(1):=b_tra;
    if a_pt(1) not in('T','C','B','V') then b_loi:='loi:Sai phuong thuc tra:loi'; return; end if;
    if a_pt(1) in('B','V') then
        if a_pt(1)='B' then
            b_ma_dl:=FBH_DONG_NBH(b_ma_dvi,b_so_id);
        else
            b_ma_dl:=FTBH_TMN_NBH(b_ma_dvi,b_so_id);
        end if;
        if trim(b_ma_dl) is null then
            b_loi:='loi:Khong tim duoc nha bao hiem cho phuong thuc:loi'; return;
        end if;
    end if;
    if b_nt_tra<>' ' then a_ma_nt(1):=b_nt_tra; else a_ma_nt(1):=b_nt_phi; end if;
end if;
if b_con=0 and b_phi<>0 and b_hoanP<>0 then
    b_con:=FBH_HD_HU_TLE(b_ma_dvi,b_so_id,b_ngay_ht,b_hoanP);
    PKH_JS_THAYn(dt_ct,'con',b_con);
end if;
b_i1:=0; 
for r_lp in (select distinct ma_nt from bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_TH_PHI_TON(b_ma_dvi,b_so_id,r_lp.ma_nt,30000101,b_ton);
    PBH_TH_NO_TON(b_ma_dvi,b_so_id,r_lp.ma_nt,30000101,b_no,b_no_qd);
    b_tra:=0;
    for b_lp in 1..a_ma_nt_no.count loop
        if a_ma_nt_no(b_lp)=r_lp.ma_nt then b_tra:=a_tra(b_lp); exit; end if;
    end loop;
    if b_ton<>0 or b_tra<>0 or b_no<>0 then
        b_i1:=b_i1+1; a_ma_nt_xl(b_i1):=r_lp.ma_nt; a_ton(b_i1):=b_ton; a_tra_xl(b_i1):=b_tra;
        a_no(b_i1):=b_no; a_no_qd(b_i1):=b_no_qd;
    end if;
end loop;
select nvl(sum(tien),0),nvl(sum(thue),0),nvl(sum(tien_qd),0),nvl(sum(thue_qd),0) into b_choP,b_choT,b_choP_qd,b_choT_qd
    from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='C';
select nvl(sum(tien),0),nvl(sum(thue),0),nvl(sum(tien_qd),0),nvl(sum(thue_qd),0) into b_i1,b_i2,b_i3,b_i4
    from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='N';
b_choP:=b_choP-b_i1; b_choT:=b_choT-b_i2; b_choP_qd:=b_choP_qd-b_i3; b_choT_qd:=b_choT_qd-b_i4;
if b_choP<0 then b_choP:=0; b_choP_qd:=0; b_choT:=0; b_choT_qd:=0; end if;
if b_nt_phi='VND' then
    b_hoanP_qd:=b_hoanP; b_hoanT_qd:=b_hoanT;
    a_tien_qd(1):=a_tien(1);
else
    b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
    b_hoanP_qd:=round(b_hoanP*b_tg,0); b_hoanT_qd:=round(b_hoanT*b_tg,0);
    if a_pt(1)='C' then
        a_tien_qd(1):=PBH_KH_CN_TU_QD(b_ma_dvi,b_ma_kh,'T',b_nt_phi,b_ngay_ht,a_tien(1),b_phong);
    elsif a_pt(1) in('B','V') then
        a_tien_qd(1):=PBH_DO_BH_CN_QD(b_ma_dvi,b_ma_dl,b_nt_phi,b_ngay_ht,'T',a_tien(1));
    else
        a_tien_qd(1):=round(a_tien(1)*b_tg,0);
    end if;
end if;
if b_nt_tra='VND' then b_tra_qd:=b_tra; else b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra); end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HU_TEST:loi'; end if;
end;
/
create or replace procedure PBH_HD_HU_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_so_hd varchar2,b_ngay_ht number,
    b_so_ct varchar2,b_ma_kh varchar2,b_ma_dl varchar2,b_con number,b_nt_phi varchar2,
    b_choP number,b_choT number,b_choP_qd number,b_choT_qd number,
    b_hoanP number,b_hoanT number,b_hoanP_qd number,b_hoanT_qd number,
    b_nt_tra varchar2,b_pt_tra varchar2,b_tra number,b_tra_qd number,b_hthue varchar2,b_phong varchar2,
    b_kvat varchar2,b_mau varchar2,b_seri varchar2,b_so_don varchar2,b_ma_ldo varchar2,
    a_ma_nt_no pht_type.a_var,a_ton pht_type.a_num,a_no pht_type.a_num,a_no_qd pht_type.a_num,a_tra pht_type.a_num,
    a_pt pht_type.a_var,a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,dt_ct clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_nv varchar2(10);
    b_cn boolean:=false; b_dl varchar2(1):='K'; b_ten nvarchar2(500);
    a_ma_nt_hu pht_type.a_var; a_tien_hu pht_type.a_num;
    b_tien_hu number:=0;
begin
-- Dan - Nhap huy hop dong
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
b_ten:=FKH_JS_GTRI(dt_ct,'ten'); b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
insert into bh_hd_goc_hu values(b_ma_dvi,b_so_id,b_nv,b_so_hd,b_ngay_ht,b_so_ct,b_con,
    b_nt_phi,b_choP,b_choT,b_choP_qd,b_choT_qd,
    b_hoanP,b_hoanT,b_hoanP_qd,b_hoanT_qd,b_pt_tra,b_nt_tra,b_tra,b_tra_qd,
    b_hthue,b_phong,b_ma_kh,b_ten,b_ma_dl,b_kvat,b_mau,b_seri,b_so_don,b_ma_ldo,0,b_nsd,sysdate);
insert into bh_hd_goc_hu_txt values(b_ma_dvi,b_so_id,b_ngay_ht,'dt_ct',dt_ct);
if FBH_HD_KIEU_HD(b_ma_dvi,b_so_id) not in('U','K') then
    for b_lp in 1..a_ma_nt_no.count loop
        if a_ton(b_lp)<>0 then
            PBH_TH_PHI(b_ma_dvi,'C',b_so_id,a_ma_nt_no(b_lp),b_ngay_ht,a_ton(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end if;
        if a_no(b_lp)<>0 then
            PBH_TH_NO_THOP(b_ma_dvi,'C',b_so_id,a_ma_nt_no(b_lp),b_ngay_ht,a_no(b_lp),a_no_qd(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end if;
        b_tien_hu:=b_tien_hu+a_no(b_lp)+a_tra(b_lp);
    end loop;
    if a_pt.count<>0 then
        if a_pt(1)='C' then
            PBH_KH_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_kh,a_ma_nt(1),a_tien(1),a_tien_qd(1),b_loi,b_phong);
            if b_loi is not null then return; end if;
            PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
            if b_loi is not null then return; end if;
        elsif a_pt(1) in('B','V') then
            PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_dl,a_ma_nt(1),a_tien(1),a_tien_qd(1),b_loi);
            if b_loi is not null then return; end if;
            PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end if;
    for b_lp in 1..a_pt.count loop
        insert into bh_hd_goc_hutt values(b_ma_dvi,b_so_id,b_lp,a_pt(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
    end loop;
    for b_lp in 1..a_ma_nt_no.count loop
        insert into bh_hd_goc_hups values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,
            a_ma_nt_no(b_lp),a_ton(b_lp),a_no(b_lp),a_no_qd(b_lp),a_tra(b_lp));
    end loop;
end if;
PBH_HD_HU_TH(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
--duong insert vao job
if b_pt_tra <> 'B' then
   PBH_HD_VAT_JOB_INSERT(b_ma_dvi,b_so_id*10,'HUHD',b_nsd);
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HU_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_HD_HU_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngayH number;
    b_cn boolean:=false; b_dl varchar2(1):='K';
    b_ngay_ht number; b_ma_kh varchar2(20); b_ma_dl varchar2(20); b_so_id_tt number;
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
    pbo_ma_dvi pht_type.a_var; pbo_so_id_tt pht_type.a_num; pbo_phi pht_type.a_num;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    r_hd bh_hd_goc_hu%rowtype;
Begin
-- Dan - Xoa huy hop dong
b_ngayH:=FBH_HD_HU_NGAY(b_ma_dvi,b_so_id);
if b_ngayH=0 or FBH_HD_HU(b_ma_dvi,b_so_id)<>'C' then b_loi:=''; return; end if;
select * into r_hd from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd<>r_hd.nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
b_so_id_tt:=b_so_id*10;
if FBH_HD_DO_CT(b_ma_dvi,b_so_id_tt)<>0 then
    b_loi:='loi:Chung tu thanh toan da thanh toan dong BH:loi'; return;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngayH,'BH','TT');
if b_loi is not null then return; end if;
if FBH_HD_KIEU_HD(b_ma_dvi,b_so_id) not in('U','K') then
    b_ngay_ht:=r_hd.ngay_ht; b_ma_kh:=r_hd.ma_kh; b_ma_dl:=r_hd.ma_dl;
    for r_lp in (select ma_nt,ton,no,no_qd from bh_hd_goc_hups where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        if r_lp.ton<>0 then
            PBH_TH_PHI(b_ma_dvi,'C',b_so_id,r_lp.ma_nt,r_hd.ngay_ht,-r_lp.ton,b_loi);
            if b_loi is not null then return; end if;
        end if;
        if r_lp.no<>0 then
            PBH_TH_NO_THOP(b_ma_dvi,'C',b_so_id,r_lp.ma_nt,r_hd.ngay_ht,-r_lp.no,-r_lp.no_qd,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end loop;
    if r_hd.pt_tra in('C','B','V') then
        select -tien,-tien_qd bulk collect into a_tien,a_tien_qd
            from bh_hd_goc_hutt where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if r_hd.pt_tra='C' then
            PBH_KH_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,r_hd.ma_dl,r_hd.nt_phi,a_tien(1),a_tien_qd(1),b_loi,r_hd.phong);
            if b_loi is not null then return; end if;
            PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
            if b_loi is not null then return; end if;
        elsif r_hd.pt_tra in('B','V') then
            PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,r_hd.ma_dl,r_hd.nt_phi,a_tien(1),a_tien_qd(1),b_loi);
            if b_loi is not null then return; end if;
            PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end if;
    PBH_TPA_HD_XOA(b_ma_dvi,b_so_id_tt,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_hd_goc_hu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
delete bh_hd_goc_hupt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_hups where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_hd_goc_hutt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_sc_hh where dvi_xl=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_tt;
delete bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_ngayH;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id_tt,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id_tt,0,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_HU_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_HU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_ma_kh varchar2(20); b_ma_dl varchar2(20); b_phong varchar2(10); b_so_id number; b_i1 number;
    a_ma_nt_xl pht_type.a_var; a_ton pht_type.a_num; a_no pht_type.a_num;
    a_no_qd pht_type.a_num; a_tra_xl pht_type.a_num; a_tien_qd pht_type.a_num;
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;

    b_so_hd varchar2(20); b_ngay_ht number; b_so_ct varchar2(20):=' '; b_con number; b_nt_phi varchar2(5);
    b_choP number; b_choT number; b_choP_qd number; b_choT_qd number;
    b_hoanP number; b_hoanT number; b_hoanP_qd number; b_hoanT_qd number;
    b_nt_tra varchar2(5); b_pt_tra varchar2(1); b_tra number; b_tra_qd number;
    b_hthue varchar2(1); b_kvat varchar2(1); b_ma_ldo nvarchar2(500);
    b_mau varchar2(20); b_seri varchar2(10); b_so_don varchar2(20);    

    a_ma_nt_no pht_type.a_var; a_tra pht_type.a_num;
    a_pt pht_type.a_var; a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
    dt_ct clob;
begin
-- Dan - Nhap huy hop dong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
dt_ct:=FKH_JS_GTRIc(b_oraIn,'dt_ct'); FKH_JS_NULL(dt_ct);
b_so_hd:=FKH_JS_GTRIs(dt_ct,'so_hd');
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_HD_HU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_HU_TEST(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,
    b_ngay_ht,b_con,b_nt_phi,b_choP,b_choT,b_choP_qd,b_choT_qd,
    b_hoanP,b_hoanT,b_hoanP_qd,b_hoanT_qd,
    b_nt_tra,b_pt_tra,b_tra,b_tra_qd,b_hthue,b_ma_kh,b_ma_dl,b_phong,b_kvat,b_so_don,b_ma_ldo,
    a_ma_nt_no,a_tra,a_ma_nt_xl,a_ton,a_no,a_no_qd,a_tra_xl,a_pt,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HD_HU_NH_NH(b_ma_dvi,b_nsd,b_so_id,b_so_hd,b_ngay_ht,b_so_ct,b_ma_kh,b_ma_dl,b_con,
    b_nt_phi,b_choP,b_choT,b_choP_qd,b_choT_qd,
    b_hoanP,b_hoanT,b_hoanP_qd,b_hoanT_qd,b_nt_tra,b_pt_tra,b_tra,b_tra_qd,
    b_hthue,b_phong,b_kvat,b_mau,b_seri,b_so_don,b_ma_ldo,
    a_ma_nt_no,a_ton,a_no,a_no_qd,a_tra_xl,a_pt,a_ma_nt,a_tien,a_tien_qd,dt_ct,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HU_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_i1 number; b_so_hd varchar2(20); b_so_id number; 
begin
-- Dan - Xoa huy hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HUY','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hd:=nvl(trim(b_oraIn),' ');
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
--duchq them dieu kien neu có phuc hoi thi khong duoc xoa hd
select count(*) into b_i1 from bh_hd_goc_phoi where ma_dvi= b_ma_dvi and so_id = b_so_id;
if b_i1 > 0 then b_loi:='loi:Khong xoa cham dut khi da co phuc hoi:loi'; raise PROGRAM_ERROR; end if;
PBH_HD_HU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_HU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(300); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(20);
    b_dong number; b_ngay number;
    b_ngayD number; b_ngayC number;
begin
-- Dan - Tim hop dong qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hd');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hd using b_oraIn;
b_so_hd:=nvl(trim(b_so_hd),' ');
b_ngay:=PKH_NG_CSO(sysdate);
if b_ngayC is null or b_ngayC in(0,30000101) then b_ngayC:=b_ngay; end if;
b_ngay:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD is null or b_ngayD in(0,30000101) or b_ngayD<b_ngay then b_ngayD:=b_ngay; end if;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select count(*) into b_dong from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and b_so_hd in (' ',so_hd)
    and ngay_ht between b_ngayD and b_ngayC;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ten,'nv' value FBH_HD_NV(ma_dvi,so_id))
        order by ngay_ht desc,so_hd returning clob) into cs_lke
        from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_hd_goc_hu where ma_dvi=b_ma_dvi and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hd,ten,'nv' value FBH_HD_NV(ma_dvi,so_id))
        order by ngay_ht desc,so_hd returning clob) into cs_lke
        from bh_hd_goc_hu where ma_dvi=b_ma_dvi and b_so_hd in (' ',so_hd) and ngay_ht between b_ngayD and b_ngayC;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/



