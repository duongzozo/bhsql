create or replace procedure PBH_HD_TRINH_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number; b_ngay_hd number; b_bt number; b_i1 number; b_i2 number;
    b_ma_dvi_tr varchar2(10); b_nsdN_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_HD_TRINH_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if FBH_HD_TTRANG(b_ma_dvi,b_so_id)='D' then b_loi:='loi:Hop dong, GCN da duyet:loi'; raise PROGRAM_ERROR; end if;
select count(*),nvl(max(bt),0) into b_i1,b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='H';
if b_i1=0 then
    select ma_dvi,nsd into b_ma_dvi_tr,b_nsdN_tr from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsdN_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='H' and bt=b_bt;
end if;
if b_ma_dvi=b_ma_dvi_tr and b_nsdN=b_nsdN_tr then b_loi:=''; return; end if;
for b_lp in (select distinct lh_nv from bh_hd_goc_dk) loop
    select max(kthac) into b_i1 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi_tr and ma=b_nsdN_tr;
    select max(kthac) into b_i2 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_nsdN;
    if b_i1>b_i2 then b_loi:='loi:Vuot nguong khai thac voi nguoi trinh '||b_ma_dvi_tr||'/'||b_nsdN_tr||':loi'; raise PROGRAM_ERROR; end if;
end loop;
select ngay_ht into b_ngay_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay:=PKH_NG_CSO(sysdate);
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_hd,'BH','KT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_bt:=b_bt+1;
insert into bh_hd_goc_ch values(b_ma_dvi,b_so_id,'H',b_bt,b_ngay,b_ma_dvi,b_nsdN);
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PBH_HD_TRINH_XOA
    (b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngay number; b_ngay_hd number; b_bt number; b_i1 number;
    b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi_hd,so_id_hd');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select count(*),nvl(max(bt),0),nvl(max(ngay),0) into b_i1,b_bt,b_ngay
    from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='H';
if b_i1=0 then return; end if;
select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='H' and bt=b_bt;
if b_ma_dvi<>b_ma_dvi_tr and b_nsdN<>b_nsd_tr then return; end if;
select ngay_ht into b_ngay_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_hd,'BH','KT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi TABLE bh_hd_goc_ch:loi';
delete bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='H' and bt=b_bt;
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
End;
/
create or replace procedure PBH_HD_GOC_PC_NSD
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi_g varchar2,b_so_id number,b_pc out varchar2)
AS
    b_loi varchar2(100); b_nsd_g varchar2(10); b_lenh varchar2(1000); b_i1 number; 
    b_lhnv varchar2(20); b_nv varchar2(5); b_bang varchar2(50);
    b_c1 varchar2(10):='/'; b_c2 varchar2(10):='::'; b_c3 varchar2(10):=' - ';
Begin
PBH_HD_XEM_KTRA(b_ma_dvi,b_nsd,b_pas,b_so_id,b_ma_dvi_g,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Khong tim thay thong tin hop dong:loi';
select nv,nsd into b_nv,b_nsd_g from bh_hd_goc where ma_dvi=b_ma_dvi_g and so_id=b_so_id;
b_bang:=FBH_HD_GOC_BANG_DK(b_nv);
b_lenh:='select min(lh_nv) from '||b_bang||' where ma_dvi=:ma_dvi and so_id=:so_id and lh_nv is not null';
EXECUTE IMMEDIATE b_lenh into b_lhnv using b_ma_dvi_g,b_so_id;
select nvl(max(kthac),0) into b_i1 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi_g and ma=b_nsd_g and lhnv=b_lhnv;
b_pc:=b_ma_dvi_g||b_c1||b_nsd_g||b_c2||b_i1;
if b_i1=0 then return; end if;
for b_lp in (select distinct kthac from bh_ma_nsd_lhnv where lhnv=b_lhnv and kthac>b_i1
    and FHT_MA_NSD_DVI(ma_dvi,ma,'BH',b_nv,'X',b_ma_dvi)='C' order by kthac) loop
    if b_pc is not null then b_pc:=b_pc||b_c3; end if;
    select count(*) into b_i1 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_nsd and lhnv=b_lhnv and kthac=b_lp.kthac;    
    if b_i1<>0 then b_pc:=b_pc||b_ma_dvi||b_c1||b_nsd;
    else
        select min(ma_dvi)||b_c1||min(ma) into b_lenh from bh_ma_nsd_lhnv where lhnv=b_lhnv and kthac=b_lp.kthac
            and FHT_MA_NSD_DVI(ma_dvi,ma,'BH',b_nv,'X',b_ma_dvi)='C';
        b_pc:=b_pc||b_lenh;
    end if;
    b_pc:=b_pc||b_c2||trim(to_char(b_lp.kthac,'999,999,999,999,999,999'));
end loop;
select count(*) into b_i1 from bh_ma_nsd_lhnv where lhnv=b_lhnv and kthac=0 and FHT_MA_NSD_DVI(ma_dvi,ma,'BH',b_nv,'X',b_ma_dvi)='C';
if b_i1<>0 then
    select count(*) into b_i1 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_nsd and lhnv=b_lhnv and kthac=0
        and FHT_MA_NSD_DVI(ma_dvi,ma,'BH',b_nv,'X',b_ma_dvi)='C';
    if b_i1<>0 then b_pc:=b_pc||b_c3||b_ma_dvi||b_c1||b_nsd; 
    else
        select min(ma_dvi)||b_c1||min(ma) into b_lenh from bh_ma_nsd_lhnv where lhnv=b_lhnv and kthac=0
            and FHT_MA_NSD_DVI(ma_dvi,ma,'BH',b_nv,'X',b_ma_dvi)='C';
        b_pc:=b_pc||b_c3||b_lenh;
    end if;
    b_pc:=b_pc||b_c2||'0';
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
End;
/
create or replace procedure PBH_BT_TRINH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi_hs varchar2,b_so_id_hs number)
AS
    b_loi varchar2(100); b_ngay number; b_bt number; b_i1 number; b_i2 number; b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);  
	b_nv varchar2(10); b_bang varchar2(50); b_lenh varchar2(2000); b_cvu varchar(10); b_cvu_pc varchar2(10);
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FBH_BT_HS_TTRANG(b_ma_dvi_hs,b_so_id_hs)='H' then b_loi:='loi:Ho so boi thuong da duyet:loi'; raise PROGRAM_ERROR; end if;
select count(*),nvl(max(bt),0) into b_i1,b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi_hs and so_id=b_so_id_hs and loai='T';
if b_i1=0 then
    select ma_dvi,nsd into b_ma_dvi_tr,b_nsd_tr from bh_bt_hs where ma_dvi=b_ma_dvi_hs and so_id=b_so_id_hs;
else
    select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi_hs and so_id=b_so_id_hs and loai='T' and bt=b_bt;
end if;
if b_ma_dvi=b_ma_dvi_tr and b_nsd=b_nsd_tr then b_loi:=''; return; end if;
for b_lp in (select distinct lh_nv from bh_bt_hs_nv where ma_dvi=b_ma_dvi_hs and so_id=b_so_id_hs) loop
    select max(bthuong) into b_i1 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi_tr and ma=b_nsd_tr and lhnv=b_lp.lh_nv;
    select max(bthuong) into b_i2 from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_nsd and lhnv=b_lp.lh_nv;
    if b_i1>b_i2 then
		b_loi:='loi:Vuot nguong duyet boi thuong voi nguoi trinh '||b_ma_dvi_tr||'/'||b_nsd_tr||'; nghiep vu: '||b_lp.lh_nv||':loi';
		raise PROGRAM_ERROR;
	end if;
end loop;
b_bt:=b_bt+1;
insert into bh_hd_goc_ch values(b_ma_dvi_hs,b_so_id_hs,'T',b_bt,PKH_NG_CSO(sysdate),b_ma_dvi,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
End;
/
