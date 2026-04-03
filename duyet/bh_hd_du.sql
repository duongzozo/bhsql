create or replace procedure PBH_HD_DU_LKE(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number;
    b_nv varchar2(10); b_ma_dvi varchar2(10); b_phong varchar2(10); b_ttrang varchar2(1); b_loc varchar2(10);
    b_ngayD number; b_ngayC number; b_so_hd varchar2(20);
    b_tienD number; b_tienC number; b_tu number; b_den number;
    b_dong number; dt_lke clob;
Begin
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_HD_DU_LKE:loi';
b_lenh:=FKH_JS_LENH('nv,dvi,phong,ttrang,loc,ngayd,ngayc,so_hd,tien_d,tien_c,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma_dvi,b_phong,b_ttrang,b_loc,
    b_ngayD,b_ngayC,b_so_hd,b_tienD,b_tienC,b_tu,b_den using b_oraIn;
b_nv:=nvl(trim(b_nv),'0'); b_ma_dvi:=nvl(trim(b_ma_dvi),' ');
b_phong:=nvl(trim(b_phong),' '); b_ttrang:=nvl(trim(b_ttrang),'0');
b_loc:=nvl(trim(b_loc),'0'); b_so_hd:=nvl(trim(b_so_hd),' ');
if b_so_hd<>' ' then b_so_hd:='%'||b_so_hd||'%'; end if;
b_ngayD:=nvl(b_ngayd,0); b_ngayC:=nvl(b_ngayC,0);
if b_ngayD=30000101 then b_ngayD:=0; end if;
if b_ngayC=30000101 then b_ngayC:=0; end if;
insert into temp_1(c1,n1,n2,c2,c3,c4,c5,c6,c9,c10,c11,c7,n7,c8,n8)
    select ma_dvi,so_id,ngay_ht,nv,so_hd,ma_kh,ttrang,nsd,phong,ten,ksoat,nt_tien,tien,nt_phi,phi from bh_hd_goc where
    b_ma_dvi in(' ',ma_dvi) and (b_so_hd=' ' or so_hd like b_so_hd) and 
    (b_ngayD=0 or ngay_ht>=b_ngayd) and (b_ngayC=0 or ngay_ht<=b_ngayC) and
    b_nv in('0',nv) and b_phong in(' ',phong) and b_ttrang in('0',ttrang) and
    (b_tienD=0 or tien>=b_tienD) and (b_tienC=0 or tien<=b_tienC) and
	(ma_dvi=b_ma_dviN or FHT_MA_NSD_DVI(b_ma_dviN,b_nsdN,'BH',nv,'N',b_ma_dvi)='C') and
    (b_loc='0' or FBH_PQU_HD(nv,b_ma_dviN,b_nsdN,ma_dvi,so_id)='C');
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
insert into temp_2(c1,n1,c2,c7,n7,c8,n8,n2,c3,c4,c5,c6,c9,c10,c11,n11) select * from
    (select c1,n1,c2,c7,n7,c8,n8,n2,c3,c4,c5,c6,c9,c10,c11,rownum sott from temp_1 order by c1,c9,c2,n2,c3)
    where sott between b_tu and b_den;
for r_lp in (select * from temp_2 where c5='T') loop
    select nvl(max(bt),0) into b_i1 from bh_hd_goc_ch where ma_dvi=r_lp.c1 and so_id=r_lp.n1;
    if b_i1<>0 then
        update temp_2 set c6=(select min(nsd_tr) from bh_hd_goc_ch where ma_dvi=r_lp.c1 and so_id=r_lp.n1 and bt=b_i1);
    end if;
end loop;
update temp_2 set c5=decode(c5,'D','Da duyet','H','Huy bo','Dang trinh');
select JSON_ARRAYAGG(json_object(
    'ma_dvi' value c1,'so_id' value n1,'so_hd' value c3,'ngay_ht' value n2,
    'phong' value c9,'ma_bh' value c2,'ten' value c10,'nt_tien' value c7,
    'tien' value n7,'nt_phi' value c8,'phi' value n8,'ttrang' value c5,
    'nsd' value c6,'ksoat' value c11 returning clob) order by n11 returning clob) into dt_lke from temp_2;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DU_TRINH_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_bt number; b_i1 number;
    b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number; b_ttrang varchar2(1);
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_HD_TRINH_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select ma_dvi,nsd,ttrang into b_ma_dvi_tr,b_nsd_tr,b_ttrang from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang<>'T' then
    b_loi:='loi:Hop dong, GCN khong dang trang thai trinh:loi'; raise PROGRAM_ERROR;
end if;
select nvl(max(bt),0) into b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_bt<>0 then
    select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
end if;
if b_ma_dviN<>b_ma_dvi_tr or b_nsdN<>b_nsd_tr then
    b_bt:=b_bt+1; b_i1:=PKH_NG_CSO(sysdate);
    insert into bh_hd_goc_ch values(b_ma_dvi,b_so_id,'H',b_bt,b_i1,b_ma_dviN,b_nsdN);
    commit;
end if;
b_oraOut:='{"ttrang":"T"}';
exception when others then rollback; raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PBH_HD_DU_KSOAT_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(200); b_lenh varchar2(2000);
    b_ngay_ht number; b_ngay_cap number; b_ttrang varchar2(1); b_qu varchar2(1); b_nv varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Kiem soat nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi xu ly PBH_HD_DU_KSOAT_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Hop dong, GCN dang xu ly:loi';
select nv,ttrang,ngay_ht,ngay_cap into b_nv,b_ttrang,b_ngay_ht,b_ngay_cap from bh_hd_goc
    where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_ttrang<>'T' then
    b_loi:='loi:Hop dong, GCN khong o trang thai trinh:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_dviN<>b_ma_dvi then
    b_qu:=FHT_MA_NSD_DVI(b_ma_dviN,b_nsdN,'BH',b_nv,'N',b_ma_dvi);
    if b_qu<>'C' then b_loi:='loi:Khong duoc phan cap duyet don vi:loi'; raise PROGRAM_ERROR; end if;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','KT'||b_nv||'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:=PKH_NGAY_LUI_TEST(b_ma_dvi,b_ngay_ht,b_ngay_cap,b_nv);
if b_loi is not null then return; end if;
update bh_hd_goc set ttrang='D' where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_HD_UP_NH(b_ma_dvi,b_so_id,b_ma_dviN,b_nsdN,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('ttrang' value 'D','ksoat' value b_nsdN) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DU_TRINH_XOA
    (b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_bt number;
    b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Hop dong, GCN dang xu ly:loi';
select nvl(max(bt),0) into b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_bt=0 then return; end if;
select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
if b_ma_dviN<>b_ma_dvi_tr or b_nsdN<>b_nsd_tr then return; end if;
b_loi:='loi:Loi TABLE bh_hd_goc_ch:loi';
delete bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
b_oraOut:='{"ttrang":"T"}';
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
End;
/
create or replace procedure PBH_HD_DU_KSOAT_XOA
    (b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(2000);
    b_ma_dvi_ks varchar2(10); b_nsd_ks varchar2(20); b_ttrang varchar2(1);
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Kiem soat xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Hop dong, GCN dang xu ly:loi';
select ttrang,ksoat,dvi_ksoat into b_ttrang,b_nsd_ks,b_ma_dvi_ks from bh_hd_goc
    where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_ttrang<>'D' then b_loi:='loi:Hop dong, GCN chua duyet:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dvi_ks<>b_ma_dviN or b_nsd_ks<>b_nsdN then
    b_loi:='loi:Khong xoa nguoi khac duyet:loi'; raise PROGRAM_ERROR;
end if;
PBH_HD_UP_XOA(b_ma_dvi,b_so_id,b_ma_dviN,b_nsdN,b_loi,'C');    
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:='{"ttrang":"T"}';
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DU_GOC(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10); b_nvG varchar2(10);
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_HD_DU_GOC:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
if b_nv is null then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_nv <> 'HANG' then
  b_lenh:='select nv from '||FBH_HD_GOC_BANG(b_nv)||' where ma_dvi= :ma_dvi and so_id= :so_id';
  EXECUTE IMMEDIATE b_lenh into b_nvG using b_ma_dvi,b_so_id;
end if;
if b_nv in ('NG','NONG') then b_nv:=b_nvG;
elsif b_nv = 'PTN' then b_nv:=b_nvG||FBH_PTN_NHOM(b_ma_dvi,b_so_id);
elsif b_nv = 'HOP' then b_nv:=b_nvG||FBH_HOP_NHOM(b_ma_dvi,b_so_id);
elsif b_nv = 'HANG' then b_nv:=b_nv;
else b_nv:=b_nv||b_nvG;
end if;
select json_object('nv' value b_nv) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

