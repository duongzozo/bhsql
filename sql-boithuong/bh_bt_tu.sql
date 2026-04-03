/*** Tam ung boi thuong ***/
create or replace procedure PBH_BT_TU_TTINh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_i1 number; b_lenh varchar2(1000);
    b_so_hs varchar2(30); b_dk varchar2(1); b_so_id number;
    b_nbh varchar2(20); b_nbhT nvarchar2(500):=' ';
    b_nt_tien varchar2(5); b_ten nvarchar2(500); b_so_pa varchar2(20);
begin
-- Dan - Tra ttin ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs,so_pa,dk');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_so_pa,b_dk using b_oraIn;
b_so_id:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs); b_dk:=nvl(trim(b_dk),' ');
if b_so_id=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_so_pa<>' ' then
    select count(*) into b_i1 from bh_bt_hs where
        ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang=b_dk and so_hs=b_so_pa;
    if b_i1=0 then b_so_pa:=' '; end if;
end if;
if b_dk='D' then
    b_nbh:=FBH_BT_HS_NBH_TONn(b_ma_dvi,b_so_id);
    if b_nbh<>' ' then b_nbhT:=FBH_MA_NBH_TENl(b_nbh); end if;
end if;
select json_object('so_hs' value b_so_hs,'nt_tien' value nt_tien,'ten' value ten,'ma_kh' value ma_kh,'nbh' value b_nbhT,'so_pa' value b_so_pa) into b_oraOut
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_TTINp(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_hs varchar2(30);
begin
-- Dan - Tra ttin p.an
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_oraIn),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so phuong an:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Phuong an da xoa:loi';
select json_object(nt_tien,ten) into b_oraOut from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_PA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_so_hs varchar2(30); b_dk varchar2(1); b_so_id number;
begin
-- Dan - Tra ttin ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs,dk');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_dk using b_oraIn;
b_so_id:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs); b_dk:=nvl(trim(b_dk),' ');
if b_so_id=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma' value so_hs,'ten' value so_hs) order by so_hs returning clob) into b_oraOut
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang=b_dk;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_NBH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_hs varchar2(20);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    a_nbh pht_type.a_var; a_pthuc pht_type.a_var;
begin
-- Dan - Tra ton NBH
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=nvl(trim(b_oraIn),' ');
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; raise PROGRAM_ERROR; end if;
select nvl(min(ma_dvi_ql),' '),min(so_id_hd),min(so_id_dt) into b_ma_dvi_hd,b_so_id_hd,b_so_id_dt
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
if b_ma_dvi_hd=' ' then b_loi:='loi:Ho so boi thuong da xoa:loi'; raise PROGRAM_ERROR; end if;
PBH_HD_NBHc(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,a_nbh,a_pthuc);
forall b_lp in 1..a_nbh.count insert into temp_1(c1) values(a_nbh(b_lp));
select JSON_ARRAYAGG(json_object(ma,ten) order by ten) into b_oraOut from
    (select c1 ma,FBH_DTAC_MA_TEN(c1) ten from temp_1);
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number;
    dt_ct clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tam ung da xoa:loi';
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
select txt into dt_txt from bh_bt_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object(so_hs,so_ct,'so_pa' value so_pa||'|'||so_pa,
    'nbh' value FBH_DTAC_MA_TENl(nbh),'txt' value dt_txt returning clob) into dt_ct
    from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'dt_ct' value dt_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id_hs number;
    b_so_hs varchar2(30); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_tu where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_tu where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_tu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_tu where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_tu where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_loi out varchar2)
AS
    b_i1 number; b_psN varchar2(1); 
    r_hd bh_bt_tu%rowtype;
begin
select count(*) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hd from bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if b_nsd<>r_hd.nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hd.ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
if FBH_BT_HS_TTRANG(b_ma_dvi,r_hd.so_id_hs)<>'T' or (r_hd.so_id_pa<>0 and FBH_BT_HS_TTRANG(b_ma_dvi,r_hd.so_id_pa)<>'T') then
    b_loi:='loi:Khong sua, xoa tam ung ho so da duyet:loi'; return;
end if;
if r_hd.l_ct='T' then b_psN:='C'; else b_psN:='T'; end if;
if r_hd.pt_tra='C' then
    PBH_KH_CN_TU_THOP(b_ma_dvi,b_psN,r_hd.ngay_ht,r_hd.ma_kh,r_hd.nt_tra,-r_hd.tra,-r_hd.tra_qd,b_loi,r_hd.phong);
    if b_loi is not null then return; end if;
    PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif r_hd.pt_tra='B' then
    PBH_DO_BH_CN_THOP(b_ma_dvi,r_hd.nv,r_hd.ngay_ht,r_hd.nbh,r_hd.nt_tra,-r_hd.tra,-r_hd.tra_qd,b_loi);
    if b_loi is not null then return; end if;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_bt_tu_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_tu_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_tu where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_TU_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_TU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_i1 number; b_i2 number; b_lenh varchar2(1000); dt_ct clob;
    b_phong varchar2(10); b_tien_qd number:=0; b_so_id_hs number; b_ngay_hs number;
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_ttrang varchar2(1); b_so_id number; 
    b_ngay_ht number; b_l_ct varchar2(1); b_so_pa varchar2(20); b_so_id_pa number:=0;
    b_so_hs varchar2(20); b_so_ct varchar2(20); b_ma_nt varchar2(5); b_tien number;
    b_nt_tien varchar2(5); b_nt_tra varchar2(5); b_t_suat number;
    b_tra number; b_tra_qd number; b_thue number; b_thue_qd number;
    b_nbh varchar2(20); b_pt_tra varchar2(1); b_psN varchar2(1); b_nv varchar2(10);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_idX number; b_so_id_dt number;
    b_kieu_do varchar2(1); b_kieu_tmN varchar2(1); b_dbhTra varchar2(1);
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num;
    a_tien_qd pht_type.a_num; a_thue pht_type.a_num; a_thue_qd pht_type.a_num;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct');
EXECUTE IMMEDIATE b_lenh into dt_ct using b_oraIn;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_BT_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'N',b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(dt_ct);
b_lenh:=FKH_JS_LENH('ngay_ht,l_ct,so_hs,so_pa,so_ct,ma_nt,tien,nt_tra,tra,thue,t_suat,nbh,pt_tra');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_l_ct,b_so_hs,b_so_pa,b_so_ct,b_ma_nt,b_tien,
    b_nt_tra,b_tra,b_thue,b_t_suat,b_nbh,b_pt_tra using dt_ct;
if b_pt_tra not in('T','C','B','F') then
    b_loi:='loi:Sai phuong thuc tra:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_ht=0 or b_l_ct not in('T','C') or b_so_hs=' ' or b_ma_nt=' ' or b_tien=0 then
    b_loi:='loi:Sai so lieu nhap:loi'; raise PROGRAM_ERROR;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
select so_id,nv,ngay_ht,ma_kh,ten,phong,ttrang,ma_dvi_ql,so_id_hd,nt_tien,so_id_dt into
    b_so_id_hs,b_nv,b_ngay_hs,b_ma_kh,b_ten,b_phong,b_ttrang,b_ma_dvi_hd,b_so_id_hd,b_nt_tien,b_so_id_dt
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
if b_so_pa=' ' then
    b_so_idX:=b_so_id_hs;
else
    b_loi:='loi:Phuong an da xoa:loi';
    if b_nv='XE' then
        select so_id_bt,so_id into b_i1,b_so_id_pa from bh_bt_xeP where ma_dvi=b_ma_dvi and so_hs=b_so_pa;
    else
        b_loi:='loi:Khong nhap phuong an:loi';
    end if;
    if b_i1<>b_so_id_hs then b_loi:='loi:Phuong an khong thuoc ho so:loi'; return; end if;
    b_so_idX:=b_so_id_pa;
end if;
if b_nt_tien<>b_ma_nt then b_loi:='loi:Loai tien chi khac loai tien ho so:loi'; raise PROGRAM_ERROR; end if;
b_nt_tra:=nvl(trim(b_nt_tra),b_ma_nt); b_tra:=nvl(b_tra,0); b_thue:=nvl(b_thue,0);
--nam: b_tra=b_tien+b_thue
if b_ma_nt=b_nt_tra and b_tra<>b_tien+b_thue then b_loi:='loi:Sai so tien thuc tra:loi'; raise PROGRAM_ERROR; end if;
b_kieu_do:=FBH_DONG(b_ma_dvi_hd,b_so_id_hd); b_kieu_tmN:=FTBH_TMN(b_ma_dvi_hd,b_so_id_hd);
b_dbhTra:=FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhTra',b_nv);
if b_nbh<>' ' and (b_dbhTra='C' or (b_kieu_do<>'V' and b_kieu_tmN<>'C')) then
    b_loi:='loi:Khong chon nha bao hiem:loi'; raise PROGRAM_ERROR;
end if;
if b_dbhTra='K' and (b_kieu_do='V' or b_kieu_tmN='C') then
    if b_pt_tra='C' then b_loi:='loi:Sai phuong thuc tra:loi'; raise PROGRAM_ERROR; end if;
    if b_nbh=' ' then b_loi:='loi:Chon nha bao hiem:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_nt_tra='VND' then
    b_tra_qd:=b_tra;
else
    if FBH_TT_KTRA(b_nt_tra)='K' then b_loi:='loi:Sai loai tien tra:loi'; raise PROGRAM_ERROR; end if;
    b_tra_qd:=FBH_TT_VND_QD(b_ngay_ht,b_nt_tra,b_tra);
end if;
if b_ngay_hs>b_ngay_ht then b_loi:='loi:Ngay chi truoc ngay nhap ho so:loi'; raise PROGRAM_ERROR; end if;
if b_ttrang<>'T' or (b_so_id_pa<>0 and FBH_BT_HS_TTRANG(b_ma_dvi,b_so_id_hs)<>'T') then
    b_loi:='loi:Chi tung phan cho ho so dang trinh:loi'; raise PROGRAM_ERROR;
end if;
select nvl(sum(tien),0) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_idX;
select nvl(sum(tien),0) into b_i2 from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_idX;
if b_tien+b_i1>b_i2 then b_loi:='loi:Tong chi nhieu hon ho so:loi'; raise PROGRAM_ERROR; end if;
if FBH_BT_HS_DPHONG(b_ma_dvi,b_so_id_hs)-FBH_BT_HS_DACHI(b_ma_dvi,b_so_id_hs)<b_tien then
    b_loi:='loi:Tong chi nhieu hon du phong duoc duyet:loi'; raise PROGRAM_ERROR;
end if;
if b_pt_tra='B' and b_nbh=' ' then
    b_loi:='loi:Chon nha bao hiem:loi'; raise PROGRAM_ERROR;
elsif b_pt_tra='C' and b_nbh<>' ' then
    b_loi:='loi:Khong chon nha bao hiem:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_nt='VND' then
    b_tien_qd:=b_tien; b_thue_qd:=b_thue;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    b_tien_qd:=round(b_i1*b_tien,0); b_thue_qd:=round(b_i1*b_thue,0);
end if;
if b_so_pa=' ' then
    PBH_BT_HS_PT(b_ma_dvi,b_so_id_hs,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
        a_so_id_dt,a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;    
else
    PBH_BT_XEp_PT(b_ma_dvi,b_so_id_pa,b_ngay_ht,b_ma_nt,b_tien,b_tien_qd,b_thue,b_thue_qd,
        a_lh_nv,a_tien,a_tien_qd,a_thue,a_thue_qd,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    for b_lp in 1..a_lh_nv.count loop a_so_id_dt(b_lp):=b_so_id_dt; end loop;
end if;
if b_so_ct=' ' then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
insert into bh_bt_tu values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_so_id_hs,
    b_so_pa,b_so_id_pa,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_l_ct,b_so_ct,b_pt_tra,b_nbh,
    b_ma_nt,b_tien,b_tien_qd,b_nt_tra,b_tra,b_tra_qd,
    b_thue,b_thue_qd,b_t_suat,b_ma_kh,b_ten,b_phong,b_nsd,sysdate,0);
--if b_so_pa=' ' then
    forall b_lp in 1..a_lh_nv.count
        insert into bh_bt_tu_pt values(b_ma_dvi,b_so_id,b_so_id_hs,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ngay_ht,
            a_lh_nv(b_lp),b_ma_nt,a_tien(b_lp),a_tien_qd(b_lp),a_thue(b_lp),a_thue_qd(b_lp));
--end if;
insert into bh_bt_tu_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
if b_l_ct='T' then b_psN:='C'; else b_psN:='T'; end if;
if b_nbh<>' ' and (b_pt_tra='C' or FBH_HD_NBHf(b_ma_dvi_hd,b_so_id_hd)='G') then
    b_loi:='loi:Khong chon nha tai:loi'; raise PROGRAM_ERROR;
end if;
if b_pt_tra='C' then
    PBH_KH_CN_TU_THOP(b_ma_dvi,b_psN,b_ngay_ht,b_ma_kh,b_nt_tra,b_tra,b_tra_qd,b_loi,b_phong);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
elsif b_pt_tra='B' then
    PBH_DO_BH_CN_THOP(b_ma_dvi,b_nv,b_ngay_ht,b_nbh,b_nt_tra,b_tra,b_tra_qd,b_loi);
    if b_loi is not null then return; end if;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_kieu_do='D' and FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhTra',b_nv)<>'C' then
    PBH_TH_DO_BTHu(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PTBH_TH_TA_BTU(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
--duong insert vao job
if b_l_ct = 'T' then
    PBH_HD_VAT_JOB_INSERT(b_ma_dvi,b_so_id,'BTTU',b_nsd);
end if;


select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Dan - Xoa tam ung boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
if b_so_id=0 then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_TU_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
create or replace procedure PBH_BT_TU_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); cs_lke clob:='';
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100); b_so_hs varchar2(30);
    b_ngayD number; b_ngayC number; b_ma_kh varchar2(20); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
begin
-- Dan - Tim tam ung qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hs using b_oraIn;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if; 
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_hs:=trim(b_so_hs);
if b_so_hs is not null then
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_tu where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
elsif trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_tu where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
else
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_tu where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd and rownum<201;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
