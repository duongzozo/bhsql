create or replace procedure PBH_BT_PA_DU_LKE(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    b_nv varchar2(10); b_ma_dvi varchar2(10); b_phong varchar2(10); b_ttrang varchar2(1); b_loc varchar2(10);
    b_ngayD number; b_ngayC number; b_so_hs varchar2(30);
    b_tienD number; b_tienC number; b_tu number; b_den number;
    b_dong number; dt_lke clob;
Begin
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_BT_PA_DU_LKE:loi';
b_lenh:=FKH_JS_LENH('nv,dvi,phong,ttrang,loc,ngayd,ngayc,so_hs,tien_d,tien_c,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma_dvi,b_phong,b_ttrang,b_loc,
    b_ngayD,b_ngayC,b_so_hs,b_tienD,b_tienC,b_tu,b_den using b_oraIn;
b_nv:=nvl(trim(b_nv),'0'); b_ma_dvi:=nvl(trim(b_ma_dvi),' ');
b_phong:=nvl(trim(b_phong),' '); b_ttrang:=nvl(trim(b_ttrang),'0');
b_loc:=nvl(trim(b_loc),'0'); b_so_hs:=nvl(trim(b_so_hs),' ');
if b_so_hs<>' ' then b_so_hs:='%'||b_so_hs||'%'; end if;
b_ngayD:=nvl(b_ngayd,0); b_ngayC:=nvl(b_ngayC,0);
if b_ngayD=30000101 then b_ngayD:=0; end if;
if b_ngayC=30000101 then b_ngayC:=0; end if;
insert into temp_1(c1,n1,c2,n3,c3,c5,c7,c10,c11,n2,c6,c9,c12) 
    select ma_dvi,so_id,nv,so_id_hd,so_hs,ttrang,nt_tien,tenH,ksoat,ngay_ht,nsd,phong,ma_dvi_ql from bh_bt_hs where
    b_ma_dvi in(' ',ma_dvi) and traN not in('C','K') and (b_so_hs=' ' or so_hs like b_so_hs) and 
    (b_ngayD=0 or ngay_ht>=b_ngayd) and (b_ngayC=0 or ngay_ht<=b_ngayC) and
    b_nv in('0',nv) and b_phong in(' ',phong) and b_ttrang in('0',ttrang) and
    (b_loc='0' or FBH_PQU_BT(nv,b_ma_dviN,b_nsdN,ma_dvi,so_id)='C') and
    (ma_dvi=b_ma_dviN or FHT_MA_NSD_DVI(b_ma_dviN,b_nsdN,'BH','BT','N',b_ma_dvi)='C');
-- viet anh -- sum tien
for r_lp in (select * from temp_1) loop
     update temp_1 set n7=(select nvl(sum(tien),0) from temp_1,bh_bt_hs_nv where n1=so_id and c1=ma_dvi and ma_dvi=r_lp.c1 and so_id=r_lp.n1) where n1=r_lp.n1;
end loop;
delete temp_1 where (b_tienD<>0 and n7<b_tienD) or (b_tienC<>0 and n7>b_tienC);
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
insert into temp_2(c1,n1,c2,n3,c3,c5,c7,n7,c10,c11,n2,c6,c9,c12,n11) select * from
    (select c1,n1,c2,n3,c3,c5,c7,n7,c10,c11,n2,c6,c9,c12,rownum sott from temp_1 order by c1,c9,c2,n2,c3)
    where sott between b_tu and b_den;
for r_lp in (select * from temp_2 where c5='T') loop
    select nvl(max(bt),0) into b_i1 from bh_hd_goc_ch where ma_dvi=r_lp.c1 and so_id=r_lp.n1;
    if b_i1<>0 then
        update temp_2 set c6=(select min(nsd_tr) from bh_hd_goc_ch where ma_dvi=r_lp.c1 and so_id=r_lp.n1 and bt=b_i1);
    end if;
end loop;
update temp_2 set c5=decode(c5,'D','Da duyet','H','Huy bo','Dang trinh');
select JSON_ARRAYAGG(json_object(
    'ma_dvi' value c1,'so_id' value n1,'so_hs' value c3,'ngay_ht' value n2,
    'phong' value c9,'ma_bh' value c2,'ten' value c10,'nt_tien' value c7,'tien' value n7,
    'ttrang' value c5,'nsd' value c6,'ksoat' value c11 returning clob) order by n11 returning clob) into dt_lke from temp_2;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PA_DU_TRINH_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_bt number; b_i1 number;
    b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number; b_ttrang varchar2(1);
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_BT_TRINH_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select ma_dvi,nsd,ttrang into b_ma_dvi_tr,b_nsd_tr,b_ttrang from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang<>'T' then b_loi:='loi:Phuong an khong dang trang thai trinh:loi'; raise PROGRAM_ERROR; end if;
select nvl(max(bt),0) into b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_bt<>0 then
    select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
end if;
if b_ma_dviN<>b_ma_dvi_tr or b_nsdN<>b_nsd_tr then
    b_bt:=b_bt+1; b_i1:=PKH_NG_CSO(sysdate);
    insert into bh_hd_goc_ch values(b_ma_dvi,b_so_id,'B',b_bt,b_i1,b_ma_dviN,b_nsdN);
    commit;
end if;
b_oraOut:='{"ttrang":"T"}';
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
End;
/
create or replace procedure PBH_BT_PA_DU_KSOAT_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(2000);
    b_ngay_ht number; b_ttrang varchar2(1); b_qu varchar2(1);
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10);
    b_txt clob; b_il number;
begin
-- Dan - Kiem soat nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_BT_PA_DU_KSOAT_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Phuong an dang xu ly:loi';
select nv,ttrang,ngay_ht into b_nv,b_ttrang,b_ngay_ht from bh_bt_hs
    where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_ttrang<>'T' then b_loi:='loi:Phuong an khong o trang thai trinh:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dviN<>b_ma_dvi then
    b_qu:=FHT_MA_NSD_DVI(b_ma_dviN,b_nsdN,'BH','BT','N',b_ma_dvi);
    if b_qu<>'C' then b_loi:='loi:Khong duoc phan cap duyet don vi:loi'; raise PROGRAM_ERROR; end if;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','KT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
update bh_bt_hs set ttrang='D',ngay_qd=PKH_NG_CSO(sysdate),ngay_nh=sysdate,ksoat=b_nsdN,dvi_ksoat=b_ma_dviN
    where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- viet anh
PBH_BT_HS_UP_NH(b_ma_dvi,b_so_id,b_ma_dviN,b_nsdN,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nv='XE' then
  update bh_bt_xeP set ttrang='D',ngay_qd=PKH_NG_CSO(sysdate),ngay_nh=sysdate,ksoat=b_nsdN,dvi_ksoat=b_ma_dviN
    where ma_dvi=b_ma_dvi and so_id=b_so_id;
  select count(*) into b_il from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  if b_il<>0 then
     select txt into b_txt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
     PKH_JS_THAYA(b_txt,'ttrang,ngay_qd,n_duyet','D'||','||PKH_NG_CSO(sysdate)||','||b_nsdN);
     update bh_bt_xe_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  end if;
end if;

b_oraOut:='{"ttrang":"D"}';
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_PA_DU_TRINH_XOA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_bt number;
    b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Phuong an dang xu ly:loi';
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
create or replace procedure PBH_BT_PA_DU_KSOAT_XOA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(2000);
    b_ma_dvi_ks varchar2(10); b_nsd_ks varchar2(20); b_ttrang varchar2(1);
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_qd number;
    b_nv varchar2(10); b_txt clob; b_il number;
begin
-- Dan - Kiem soat xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Phuong an dang xu ly:loi';
select ttrang,ksoat,dvi_ksoat,ngay_qd,nv into b_ttrang,b_nsd_ks,b_ma_dvi_ks,b_ngay_qd,b_nv from bh_bt_hs
    where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_ttrang<>'D' then b_loi:='loi:Phuong an chua duyet:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dvi_ks<>b_ma_dviN or b_nsd_ks<>b_nsdN then
    b_loi:='loi:Khong xoa nguoi khac duyet:loi'; raise PROGRAM_ERROR;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
update bh_bt_hs set ngay_qd=30000101,n_duyet='',ksoat='',dvi_ksoat='',ttrang='T',ngay_nh=sysdate
    where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- viet anh
if b_nv='XE' then
  update bh_bt_xeP set ngay_qd=30000101,n_duyet='',ksoat='',dvi_ksoat='',ttrang='T',ngay_nh=sysdate
    where ma_dvi=b_ma_dvi and so_id=b_so_id;
  select count(*) into b_il from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  if b_il<>0 then
     select txt into b_txt from bh_bt_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
     PKH_JS_THAYA(b_txt,'ttrang,ngay_qd,n_duyet','T'||','||30000101||','||' ');
     update bh_bt_xe_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
  end if;
end if;
PBH_BT_HS_UP_XOA(b_ma_dvi,b_so_id,b_ma_dviN,b_nsdN,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_oraOut:='{"ttrang":"T"}';
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/ 
create or replace procedure PBH_BT_PA_DU_GOC(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_nv varchar2(10); b_nvP varchar2(10);
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_loi:='loi:Phuong an da xoa:loi';
select json_object('so_hs' value so_hs,'nv' value nv,'nvp' value traN) into b_oraOut from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;