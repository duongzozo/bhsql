create or replace procedure PBH_BT_DUDP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number;
    b_nv varchar2(10); b_dvi varchar2(10); b_phong varchar2(10); b_ttrang varchar2(1); b_loc varchar2(10);
    b_ngayD number; b_ngayC number; b_so_hs varchar2(30);
    b_tienD number; b_tienC number; b_tu number; b_den number;
    b_dong number; dt_lke clob; b_txt clob:=b_oraIn;
Begin
delete temp_1; delete temp_2; delete temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_BT_DUDP_LKE:loi';
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('nv,dvi,phong,ttrang,loc,ngayd,ngayc,so_hs,tiend,tienc,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_dvi,b_phong,b_ttrang,b_loc,
    b_ngayD,b_ngayC,b_so_hs,b_tienD,b_tienC,b_tu,b_den using b_txt;
if b_dvi=' ' then b_loi:='loi:Chon don vi:loi'; raise PROGRAM_ERROR; end if;
if b_so_hs<>' ' then b_so_hs:='%'||b_so_hs||'%'; end if;
if b_ngayD=30000101 then b_ngayD:=0; end if;
if b_ngayC=0 then b_ngayC:=3000001; end if;
if b_ngayC=0 then b_ngayC:=1.e18; end if;
insert into temp_1(c1,n1,c2,n3,c3,c5,c10,c11,n2,c6,c9,c12,c7,n7)
    select ma_dvi,so_id,nv,so_id_hd,so_hs,decode(ksoat,' ','Dang trinh','Da duyet'),
    ten,ksoat,ngay_dp,nsd,phong,ma_dvi_ql,ma_nt,tien from bh_bt_hs_dp where
    b_dvi in(' ',ma_dvi) and (b_so_hs=' ' or so_hs like b_so_hs) and 
    ngay_dp between b_ngayD and b_ngayC and
    b_nv in(' ',nv) and b_ttrang in(' ',decode(ksoat,' ','T','D')) and
    (b_loc=' ' or FBH_PQU_BT(nv,b_ma_dvi,b_nsd,ma_dvi,so_id)='C') and
    (ma_dvi=b_ma_dvi or FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH','BT','N',b_dvi)='C') and
    (b_tienD=0 or tien>=b_tienD) and (b_tienC=0 or tien<=b_tienC);
select count(*) into b_dong from temp_1;
insert into temp_3(c1,n1,n2) select c1,n1,max(n2) from temp_1 group by c1,n1;
for r_lp in (select c1,n1,n2 from temp_3) loop
    delete temp_1 where c1=r_lp.c1 and n1=r_lp.n1 and n2<r_lp.n2;
end loop;
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
select JSON_ARRAYAGG(json_object(
    'ma_dvi' value c1,'so_id' value n1,'so_hs' value c3,'ngay_ht' value n2,
    'ma_bh' value c2,'ten' value c10,'nt_tien' value c7,'tien' value n7,
    'ttrang' value c5,'nsd' value c6,'ksoat' value c11 returning clob) order by n11 returning clob) into dt_lke from temp_2;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_DUDP_TRINH_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_bt number; b_i1 number;
    b_ma_dvi_tr varchar2(10); b_nsd_tr varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_BT_TRINH_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then
    b_loi:='loi:Chon ho so can duyet du phong:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Du phong khong dang trang thai trinh:loi';
select ma_dvi,nsd into b_ma_dvi_tr,b_nsd_tr from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ksoat=' ';
select nvl(max(bt),0) into b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_bt<>0 then
    select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
end if;
if b_ma_dviN<>b_ma_dvi_tr or b_nsdN<>b_nsd_tr then
    b_bt:=b_bt+1; b_i1:=PKH_NG_CSO(sysdate);
    insert into bh_hd_goc_ch values(b_ma_dvi,b_so_id,'B',b_bt,b_i1,b_ma_dviN,b_nsdN);
end if;
b_oraOut:='T';
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
End;
/
create or replace procedure PBH_BT_DUDP_KSOAT_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(2000); r_hd bh_bt_hs%rowtype;
    b_ngay_dp number; b_qu varchar2(1); b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Kiem soat nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_BT_DUDP_KSOAT_NH:loi';
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then
    b_loi:='loi:Chon ho so can duyet du phong:loi'; raise PROGRAM_ERROR;
end if;
select nvl(max(ngay_dp),0) into b_ngay_dp from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_dp=0 then
    b_loi:='loi:Du phong khong dang trang thai trinh:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_dviN<>b_ma_dvi then
    b_qu:=FHT_MA_NSD_DVI(b_ma_dviN,b_nsdN,'BH','BT','N',b_ma_dvi);
    if b_qu<>'C' then b_loi:='loi:Khong duoc phan cap duyet don vi:loi'; raise PROGRAM_ERROR; end if;
end if;
--nam: kiem soat boi thuong
select * into r_hd from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_PQU_BT(r_hd.nv,b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
update bh_bt_hs_dp set dvi_ksoat=b_ma_dviN,ksoat=b_nsdN where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
b_oraOut:='D';
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_DUDP_TRINH_XOA(
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
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then
    b_loi:='loi:Chon ho so can duyet du phong:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Ho so dang xu ly:loi';
select nvl(max(bt),0) into b_bt from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_bt=0 then return; end if;
select ma_dvi_tr,nsd_tr into b_ma_dvi_tr,b_nsd_tr from bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
if b_ma_dviN=b_ma_dvi_tr and b_nsdN=b_nsd_tr then
    b_loi:='loi:Loi TABLE bh_hd_goc_ch:loi';
    delete bh_hd_goc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
end if;
b_oraOut:='T';
commit;
exception when others then rollback; raise_application_error(-20105,b_loi);
End;
/
create or replace procedure PBH_BT_DUDP_KSOAT_XOA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(2000);
    b_dvi_ksoat varchar2(10); b_ksoat varchar2(20);
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_dp number;
begin
-- Dan - Kiem soat xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then
    b_loi:='loi:Chon ho so can duyet du phong:loi'; raise PROGRAM_ERROR;
end if;
select nvl(max(ngay_dp),0) into b_ngay_dp from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_dp=0 then
    b_loi:='loi:Du phong khong dang trang thai trinh:loi'; raise PROGRAM_ERROR;
end if;
select dvi_ksoat,ksoat into b_dvi_ksoat,b_ksoat from bh_bt_hs_dp
    where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
if b_ksoat<>' ' and (b_dvi_ksoat<>b_ma_dviN or b_ksoat<>b_nsdN) then
    b_loi:='loi:Khong sua, xoa Hop dong/GCN nguoi khac duyet:loi'; raise PROGRAM_ERROR;
end if;
update bh_bt_hs_dp set dvi_ksoat=' ',ksoat=' ' where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
b_oraOut:='T';
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/ 
