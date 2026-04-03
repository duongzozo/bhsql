/*** MO ***/
create or replace function FBH_BT_TXT_NV(b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_nvN varchar2:=' ') return nvarchar2
as
    b_kq nvarchar2(500):=' '; b_nv varchar2(10):=b_nvN; b_lenh varchar2(2000);
begin
-- Dan - Tra su kien
if b_nv=' ' then b_nv:=FBH_BT_HS_HD_NV(b_ma_dvi,b_so_id); end if;
b_lenh:='select FBH_BT_'||b_nv||'_TXT(:ma_dvi,:so_id,:tim) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id,b_tim;
b_kq:=PKH_MA_TENl(b_kq);
return b_kq;
end;
/
create or replace function FBH_BT_HS_DPHONG(b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
AS
    b_kq number:=0; b_i1 number;
begin
-- Dan - Tra so du phong
if FBH_BT_HS_TTRANG(b_ma_dvi,b_so_id)='T' then
    select nvl(max(ngay_dp),0) into b_i1 from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp<=b_ngay;
    if b_i1<>0 then
        if FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhtra')<>'C' then
            select nvl(max(tien),0) into b_kq from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_i1 and ksoat<>' ';
        else
            select nvl(max(tien-dong),0) into b_kq from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_i1 and ksoat<>' ';
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_BT_HS_DACHI(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number; b_i1 number;
begin
-- Dan - Tra da chi
select nvl(sum(tien),0) into b_kq from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
select nvl(sum(tien),0) into b_i1 from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_kq:=b_kq+b_i1;
select nvl(sum(tien),0) into b_i1 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
b_kq:=b_kq+b_i1;
return b_kq;
end;
/
create or replace function FBH_BT_KTRUs(a_ktru pht_type.a_var) return varchar2
AS
    b_ptM number:=0; b_gtriM number:=0; b_i1 number; b_kq varchar2(500):=' ';
    a_ch pht_type.a_var;
begin
-- Dan - Tra muc khau tru toi da
for b_lp in 1..a_ktru.count loop
    if trim(a_ktru(b_lp)) is null then continue; end if;
    PKH_CH_ARR(a_ktru(b_lp),a_ch,'|');
    b_i1:=PKH_LOC_CHU_SO(a_ch(1));
    if b_i1>b_ptM then b_ptM:=b_i1; end if;
    if a_ch.count=1 then continue; end if;
    b_i1:=PKH_LOC_CHU_SO(a_ch(2));
    if b_i1>b_gtriM then b_gtriM:=b_i1; end if;
end loop;
if b_ptM<>0 or b_gtriM<>0 then b_kq:=to_char(b_ptM)||'|'||to_char(b_gtriM); end if;
return b_kq;
end;
/
create or replace function FBH_BT_KTRUn(b_ktru varchar2,b_tien number) return number
AS
    b_pt number:=0; b_gtriM number:=0; b_i1 number:=0; b_kq number:=0;
    a_ch pht_type.a_var;
begin
-- Dan - Tra muc khau tru
PKH_CH_ARR(b_ktru,a_ch,'|');
b_i1:=PKH_LOC_CHU_SO(a_ch(1));
if b_i1>0 then b_kq:=round(b_i1*b_tien/100,0); end if;
if a_ch.count>1 then
    b_i1:=PKH_LOC_CHU_SO(a_ch(2));
    if b_i1>b_kq then b_kq:=b_i1; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_BCAO_PBO(
    a_ma pht_type.a_var,a_ma_ct pht_type.a_var,a_cap pht_type.a_num,
    a_t_that pht_type.a_num,a_tien in out pht_type.a_num,b_loi out varchar2)
AS
    b_ma varchar2(10); b_bt number; b_cap number; b_bth number; b_tth number; b_hs number;
begin
-- Dan Phan bo boi thuong bac cao
b_loi:='loi:Loi xu ly PBH_BT_BCAO_PBO:loi';
b_cap:=FKH_ARR_MAXn(a_cap)-1;
for b_lp in 1..b_cap loop
    for b_lp1 in 1..a_ma.count loop
        if a_cap(b_lp1)=b_lp then
            b_ma:=a_ma(b_lp1); b_bth:=a_tien(b_lp1); b_tth:=0;
            for b_lp2 in 1..a_ma.count loop
                if a_ma_ct(b_lp2)=b_ma and a_t_that(b_lp2)<>0 then
                    if a_tien(b_lp2)<>0 then
                        b_bth:=b_bth-a_tien(b_lp2);
                    else
                        b_bt:=b_lp2; b_tth:=b_tth+a_t_that(b_lp2);
                    end if;
                end if;
            end loop;
            if b_bth<>0 then
                if b_tth=0 then b_loi:='loi:Loi phan bo ma: '||b_ma||':loi'; return; end if;
                b_hs:=b_bth/b_tth;
                for b_lp2 in 1..a_ma.count loop
                    if a_ma_ct(b_lp2)=b_ma and a_t_that(b_lp2)<>0 and a_tien(b_lp2)=0 then
                        if b_lp2=b_bt then
                            a_tien(b_lp2):=b_bth; exit;
                        else
                            a_tien(b_lp2):=round(b_hs*a_t_that(b_lp2),0);
                            b_bth:=b_bth-a_tien(b_lp2);
                        end if;
                    end if;
                end loop;
            end if;
        end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_BCAO_PBO:loi'; end if;
end;
/
create or replace function FBH_BT_MA_DVIh(b_so_hs varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh don vi
select nvl(min(ma_dvi),' ') into b_kq from bh_bt_hs where so_hs=b_so_hs;
return b_kq;
end;
/
create or replace function FBH_BT_MA_DVIi(b_so_id varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh don vi
select nvl(min(ma_dvi),' ') into b_kq from bh_bt_hs where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_BT_GD_HO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hs varchar2,b_dvi_xl varchar2,b_k_thue varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_so_id number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi xu ly:loi';
if b_dvi_xl<>'*' then select 0 into b_i1 from ht_ma_dvi where ma=b_dvi_xl; end if;
b_loi:='loi:Sai so ho so:loi';
if b_so_hs is null then raise PROGRAM_ERROR; end if;
b_so_id:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
if b_k_thue is null or b_k_thue not in('K','C') then b_loi:='loi:Sai kieu xu ly thue:loi'; raise PROGRAM_ERROR; end if;
delete bh_bt_gd_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl=b_dvi_xl;
insert into bh_bt_gd_ho values(b_ma_dvi,b_so_id,b_dvi_xl,b_k_thue,b_nsd);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** THONG KE ***/
create or replace procedure PBH_BT_TKEDN_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select distinct ma_bh,lh_nv,'' ten from bh_bt_tke_dn where ma_dvi=b_ma_dvi;
end;
/
create or replace procedure PBH_BT_TKEDN_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_bh varchar2,
    b_lh_nv varchar2,b_ten out nvarchar2,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200);
begin
-- Dan - Chi _LKE
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai nghiep vu:loi';
select ten into b_ten from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=b_lh_nv;
open cs1 for select * from bh_bt_tke_dn where ma_dvi=b_ma_dvi and ma_bh=b_ma_bh and lh_nv=b_lh_nv order by bt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TKEDN_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_bh varchar2,b_lh_nv varchar2,
    ds_ma_tke pht_type.a_var,ds_ten pht_type.a_var,ds_loai pht_type.a_var,ds_do_dai pht_type.a_num)
AS
    b_loi nvarchar2(200); b_i1 number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma_bh) is null then b_loi:='loi:Nhap loai hinh bao hiem:loi'; raise PROGRAM_ERROR; end if;
if ds_ma_tke.count=0 then b_loi:='loi:Danh muc thong ke:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai nghiep vu:loi';
if b_lh_nv is null then  raise PROGRAM_ERROR; end if;
select 0 into b_i1 from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=b_lh_nv;
delete bh_bt_tke_dn where ma_dvi=b_ma_dvi and ma_bh=b_ma_bh and lh_nv=b_lh_nv;
for b_lp in 1..ds_ma_tke.count loop
    b_loi:='loi:Sai so lieu dong '||to_char(b_lp)||':loi';
    if ds_ma_tke(b_lp) is null  or ds_ten(b_lp) is null  or ds_loai(b_lp) is null or
        ds_loai(b_lp) not in('C','N','S','H') or ds_do_dai(b_lp) is null or ds_do_dai(b_lp)<0 then raise PROGRAM_ERROR;
    end if;
    insert into bh_bt_tke_dn values(b_ma_dvi,b_ma_bh,b_lh_nv,b_lp,ds_ma_tke(b_lp),ds_ten(b_lp),ds_loai(b_lp),ds_do_dai(b_lp));
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TKEDN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_bh varchar2,b_lh_nv varchar2)
AS
    b_loi nvarchar2(200);
begin
-- Dan - Xoa 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma_bh is null or b_lh_nv is null then b_loi:='loi:Nhap san pham, nghiep vu:loi'; raise PROGRAM_ERROR; end if;
delete bh_bt_tke_dn where ma_dvi=b_ma_dvi and ma_bh=b_ma_bh and lh_nv=b_lh_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Thong ke boi thuong ***/
create or replace procedure PBH_BT_TKENH_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_nv varchar2(10);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; commit;
b_nv:=FBH_BT_HS_HD_NV(b_ma_dvi,b_so_id);
if b_nv is null then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
insert into temp_1(c1) select distinct lh_nv from bh_bt_tke_dn where ma_dvi=b_ma_dvi and ma_bh=b_nv;
open cs1 for select c1 lh_nv,ten from temp_1 a,bh_ma_lhnv b where ma_dvi=b_ma_dvi and c1=ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TKENH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_lh_nv varchar2,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_id_hd varchar2(30); b_nv varchar2(10);
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; commit;
b_nv:=FBH_BT_HS_HD_NV(b_ma_dvi,b_so_id);
if b_nv is null then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
insert into temp_1(c1,c2,c3,n1,n2) select ma_tke,ten,loai,do_dai,bt from bh_bt_tke_dn where ma_dvi=b_ma_dvi and ma_bh=b_nv and lh_nv=b_lh_nv;
update temp_1 set c4=(select gtri from bh_bt_hs_tke where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv=b_lh_nv and ma_tke=c1);
open cs1 for select c1 ma_tke,c2 ten,c3 loai,n1 do_dai,c4 gtri from temp_1 order by n2;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TKENH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    b_lh_nv varchar2,ds_ma_tke pht_type.a_var,ds_gtri pht_type.a_var)
AS
    b_loi nvarchar2(200); b_i1 number; b_nsd_c varchar2(10);
begin
-- Dan - Nhap ma loai hinh bao hiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap SO_ID:loi'; raise PROGRAM_ERROR; end if;
if ds_ma_tke.count=0 then b_loi:='loi:Nhap so lieu thong ke:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai nghiep vu:loi';
if b_lh_nv is null then raise PROGRAM_ERROR; end if;
select 0 into b_i1 from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=b_lh_nv;
b_nsd_c:=FBH_BT_HS_NSD(b_ma_dvi,b_so_id);
if b_nsd_c is null then b_loi:='loi:Ho so dang xu ly:loi'; raise PROGRAM_ERROR; end if;
if b_nsd<>b_nsd_c then b_loi:='loi:Ho so cua nguoi khac:loi'; raise PROGRAM_ERROR; end if;
delete bh_bt_hs_tke where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv=b_lh_nv;
for b_lp in 1..ds_ma_tke.count loop
    b_loi:='loi:Sai so lieu ma_tke dong '||to_char(b_lp)||':loi';
    if ds_ma_tke(b_lp) is null or ds_gtri(b_lp) is null then raise PROGRAM_ERROR; end if;
    insert into bh_bt_hs_tke values(b_ma_dvi,b_so_id,b_lh_nv,b_lp,ds_ma_tke(b_lp),ds_gtri(b_lp));
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TKENH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_lh_nv varchar2)
AS
    b_loi nvarchar2(200); b_nsd_c varchar2(10);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null or b_lh_nv is null then b_loi:='loi:Nhap SO_ID, nghiep vu:loi'; raise PROGRAM_ERROR; end if;
b_nsd_c:=FBH_BT_HS_NSD(b_ma_dvi,b_so_id);
if b_nsd_c is null then b_loi:='loi:Ho so dang xu ly:loi'; raise PROGRAM_ERROR; end if;
if b_nsd<>b_nsd_c then b_loi:='loi:Ho so cua nguoi khac:loi'; raise PROGRAM_ERROR; end if;
delete bh_bt_hs_tke where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv=b_lh_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** BOI THUONG ***/
create or replace procedure PBH_BT_HS_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_phong varchar2(10); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma_dvi,so_hs,so_id,row_number() over (order by so_id) sott from bh_bt_hs where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id) where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma_dvi,so_hs,so_id,row_number() over (order by so_id) sott from bh_bt_hs where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma_dvi,so_hs,so_id,row_number() over (order by so_id) sott from bh_bt_hs where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_klk varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_phong varchar2(10); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma_dvi,so_hs,so_id,row_number() over (order by so_id) sott from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id) where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma_dvi,so_hs,so_id,row_number() over (order by so_id) sott from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma_dvi,so_hs,so_id,row_number() over (order by so_id) sott from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--create or replace procedure PBH_BT_HS_LKE_DT
create or replace procedure FBH_BT_HS_NV_DT
    (b_ma_dvi varchar2,b_ma_dvi_ql varchar2,b_so_id number,b_so_id_bt number,b_loi out varchar2,cs1 out pht_type.cs_type)
AS
    b_i1 number; b_so_id_d number; b_so_id_bs number; b_nv varchar2(10);
begin
-- Dan - Liet ke danh sach doi tuong theo hop dong
if b_ma_dvi<>b_ma_dvi_ql then
    if FBH_BT_HO_HD(b_ma_dvi_ql,b_so_id,b_ma_dvi)=0 then
        b_loi:='loi:Hop dong khong duoc phep boi thuong ho:loi'; return;
    end if;
end if;
delete bh_bt_nv_temp;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id); b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi_ql,b_so_id,30000101);
PBH_HD_DS_NV_BANG(b_ma_dvi_ql,b_so_id_bs,0,b_loi);
if b_loi is not null then return; end if;
insert into bh_bt_nv_temp select so_id_dt,ten,lh_nv,nt_tien,sum(tien),sum(tien_vnd) from bh_hd_nv_temp group by so_id_dt,ten,lh_nv,nt_tien;
if b_ma_dvi<>b_ma_dvi_ql then
    b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi_ql,b_so_id);
    delete bh_bt_nv_temp where FBH_BT_HO_DT(b_ma_dvi_ql,b_so_id_d,b_ma_dvi,so_id_dt)=0;
end if;
if b_so_id_bt<>0 then
    delete bh_bt_nv_temp where FBH_BT_DS_DT(b_ma_dvi,b_so_id_bt,so_id_dt)=0;
end if;
open cs1 for select b_nv nv,a.so_id_dt,a.ten,a.lh_nv,b.ten lh_nv_ten,a.nt_tien ma_nt,a.tien
    from bh_bt_nv_temp a,bh_ma_lhnv b where b.ma_dvi=b_ma_dvi and b.ma=a.lh_nv;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_BT_HS_NV_DT:loi'; end if;
end;
/
create or replace procedure FBH_BT_HS_DS_DT
    (b_ma_dvi varchar2,b_ma_dvi_ql varchar2,b_so_id number,b_so_id_bt number,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number; b_so_idB number;
begin
-- Dan - Liet ke danh sach doi tuong theo hop dong
if b_ma_dvi<>b_ma_dvi_ql and FBH_BT_HO_HD(b_ma_dvi_ql,b_so_id,b_ma_dvi)=0 then
    b_loi:='loi:Hop dong khong duoc phep boi thuong ho:loi'; return;
end if;
delete bh_bt_nv_temp; delete bh_bt_ds_temp;
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi_ql,b_so_id,30000101);
PBH_HD_DS_NV_BANG(b_ma_dvi_ql,b_so_idB,0,b_loi);
if b_loi is not null then return; end if;
insert into bh_bt_ds_temp select distinct so_id_dt,ten from bh_hd_nv_temp;
if b_ma_dvi<>b_ma_dvi_ql then
    b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_ql,b_so_id);
    delete bh_bt_ds_temp where FBH_BT_HO_DT(b_ma_dvi_ql,b_so_idD,b_ma_dvi,so_id_dt)=0;
end if;
select count(*) into b_i1 from bh_bt_ds_temp;
if b_i1>30 and b_so_id_bt<>0 then
    delete bh_bt_ds_temp where FBH_BT_DS_DT(b_ma_dvi,b_so_id_bt,so_id_dt)=0;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_BT_HS_DS_DT:loi'; end if;
end;
/
create or replace function FBH_BT_HS_TEN_DT(b_so_id_dt number) return nvarchar2
AS
    b_ten nvarchar2(400);
begin
-- Dan - Ten doi tuong
select min(ten) into b_ten from bh_hd_nv_temp where so_id_dt=b_so_id_dt;
return b_ten;
end;
/
create or replace procedure PBH_BT_HS_DT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi_ql varchar2,b_so_hd varchar2,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_id number; b_i1 number;
begin
-- Dan - Liet ke danh sach doi tuong theo hop dong
delete bh_bt_ds_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID(b_ma_dvi_ql,b_so_hd);
FBH_BT_HS_DS_DT(b_ma_dvi,b_ma_dvi_ql,b_so_id,0,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select so_id_dt,ten from bh_bt_ds_temp order by so_id_dt;
delete bh_bt_ds_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_DT_CHON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi_ql varchar2,
    b_so_hd varchar2,a_so_id_dt pht_type.a_num,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Dan - Liet ke danh sach doi tuong theo hop dong
delete bh_bt_dt_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID(b_ma_dvi_ql,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_so_id_dt.count loop
    insert into bh_bt_dt_temp values(a_so_id_dt(b_lp));
end loop;
FBH_BT_HS_NV_DT(b_ma_dvi,b_ma_dvi_ql,b_so_id,0,b_loi,cs1);
if b_loi is not null then raise PROGRAM_ERROR; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_PT(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_thue number,b_thue_qd number,
    a_so_id_dt out pht_type.a_num,a_lh_nv out pht_type.a_var,a_tien out pht_type.a_num,
    a_tien_qd out pht_type.a_num,a_thue out pht_type.a_num,a_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_tl number; b_tp number:=0; b_tien_t number;
    b_tien_c number; b_tien_c_qd number; b_thue_c number; b_thue_c_qd number; a_tl pht_type.a_num;
Begin
-- Dan - Phan tich theo ho so boi thuong
select so_id_dt,lh_nv,sum(decode(tien,0,t_that,tien)) bulk collect into a_so_id_dt,a_lh_nv,a_tl from bh_bt_hs_nv 
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' and (tien<>0 or t_that<>0) group by so_id_dt,lh_nv;
if a_lh_nv.count=0 then b_loi:=''; return; end if;
b_tien_t:=FKH_ARR_TONG(a_tl);
--Nam: check tien ton that = 0 va tien_tba<>0 (BA Trang)
if b_tien_t=0 then b_loi:='loi:Ho so khong co ton that, khong nhap thu doi nguoi thu ba:loi'; return; end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
b_tien_c:=b_tien; b_tien_c_qd:=b_tien_qd; b_thue_c:=b_thue; b_thue_c_qd:=b_thue_qd;
for b_lp in 1..a_lh_nv.count loop
    if b_lp=a_so_id_dt.count then
        a_tien(b_lp):=b_tien_c; a_tien_qd(b_lp):=b_tien_c_qd;
        a_thue(b_lp):=b_thue_c; a_thue_qd(b_lp):=b_thue_c_qd;
    else
        b_tl:=a_tl(b_lp)/b_tien_t;
        a_tien(b_lp):=round(b_tien*b_tl,b_tp); a_tien_qd(b_lp):=round(b_tien_qd*b_tl,0);
        a_thue(b_lp):=round(b_thue*b_tl,b_tp); a_thue_qd(b_lp):=round(b_thue_qd*b_tl,0);
        b_tien_c:=b_tien_c-a_tien(b_lp); b_tien_c_qd:=b_tien_c_qd-a_tien_qd(b_lp);
        b_thue_c:=b_thue_c-a_thue(b_lp); b_thue_c_qd:=b_thue_c_qd-a_thue_qd(b_lp);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_PT:loi'; end if;
end;
/
create or replace procedure PBH_BT_HS_NGAY_XR
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_xr number,
    b_ma_dvi_ql varchar2,b_so_hd varchar2,b_kq out varchar2)
AS
    b_loi varchar2(100); b_so_id_hd number; b_i1 number;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_hd:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi_ql,b_so_hd);
select count(*) into b_i1 from (select so_id,ngay_xr from bh_bt_hs where ma_dvi_ql=b_ma_dvi_ql and so_id_hd=b_so_id_hd)
    where so_id<>b_so_id and ngay_xr=b_ngay_xr;
if b_i1<>0 then b_kq:='C'; else b_kq:='K'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Tien ich ***/
create or replace function FBH_BT_NT_TIEN(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Tra NT_TIEN bao hiem
select nvl(min(nt_tien),'VND') into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tinh trang
select nvl(min(ttrang),'X') into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_NSD(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_nsd varchar2(10);
begin
-- Dan - Tra NSD ho so
select min(nsd) into b_nsd from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_nsd;
end;
/
create or replace function FBH_BT_HS_NBH_TON(
    b_ma_dvi varchar2,b_so_id number,b_nbh varchar2,b_ngay_ht number:=30000101) return number
AS
    b_i1 number; b_ton number:=0;
begin
-- Dan - Ton boi thuong nbh
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton into b_ton from bh_bt_hs_nbh where
        ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ngay_ht=b_i1;
end if;
return b_ton;
end;
/
create or replace function FBH_BT_HS_TON(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_i1 number; b_ton number:=0;
begin
-- Dan - Ton boi thuong
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs_sc where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton into b_ton from bh_bt_hs_sc where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht=b_i1;
end if;
return b_ton;
end;
/
create or replace procedure PBH_BT_HS_SC_TON
    (b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs_sc where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
    b_ton:=0; b_ton_qd:=0;
else
    select ton,ton_qd into b_ton,b_ton_qd from bh_bt_hs_sc where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace function FBH_BT_HS_SC_QD(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,b_l_ct varchar2,b_tien number) return number
AS
    b_i1 number; b_ton number:=0; b_ton_qd number; b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
if b_ma_nt='VND' then return b_tien; end if;
PBH_BT_HS_SC_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
if b_l_ct='T' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
if b_ton=b_tien then b_tien_qd:=b_ton_qd;
elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
    if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
    else b_tien_qd:=round(b_tien*b_i1,0);
    end if;
end if;
return b_tien_qd;
end;
/
create or replace function FBH_BT_HS_TIEN(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tong tien
select nvl(sum(tien),0) into b_kq from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_BT_HS_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_so_id number,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_thu number:=0; b_chi number:=0; b_ton number; b_i1 number;
    b_thu_qd number:=0; b_chi_qd number:=0; b_ton_qd number;
begin
-- Dan - Tong hop boi thuong
if b_ps='T' then
    b_thu:=b_tien; b_thu_qd:=b_tien_qd;
else
    b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_BT_HS_SC_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update bh_bt_hs_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_bt_hs_sc values(b_ma_dvi,b_so_id,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
else
    delete bh_bt_hs_sc where ma_dvi=b_ma_dvi and ma_dvi=b_ma_dvi and
        so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht and thu=0 and chi=0;
end if;
for b_rc in (select * from bh_bt_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and
    ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
    update bh_bt_hs_sc set ton=b_ton,ton_qd=b_ton_qd where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_THOP:loi'; end if;
end;
/
create or replace procedure FBH_BT_HS_LKE_PHI
    (b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
begin
-- Dan - Liet ke phi, boi thuong
insert into temp_1(c1,n1) select ma_nt,sum(ttoan) from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id group by ma_nt;
update temp_1 set (n2,n3)=(select nvl(sum(decode(pt,'C',0,tien)),0),nvl(sum(tien),0)
    from  bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=c1);
open cs1 for select c1 ma_nt,n1 phi,n2 ttoan,n3-n2 no,n1-n2 ton from temp_1;
if b_so_id_dt<0 then
    insert into temp_2(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
    insert into temp_2(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id;
else
    insert into temp_2(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
    insert into temp_2(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien from bh_bt_hs a,bh_bt_hs_nv b where
        a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_id and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
end if;
open cs2 for select n10 so_id,c1 so_hs,n9 ngay_ht,c2 ma_nt,nvl(sum(n1),0) tien,nvl(sum(n2),0) ton from temp_2 group by n10,c1,n9,c2 order by n10 desc;
end;
/
create or replace procedure PBH_BT_HS_LKE_PHI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_so_id number; b_loi nvarchar2(200);
begin
-- Dan - Liet ke phi, boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; delete temp_2; commit;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
FBH_BT_HS_LKE_PHI(b_ma_dvi,b_so_id,-1,cs1,cs2);
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_LKE_HS
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_so_id_dt number,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_idD number;
begin
-- Dan - Liet ke phi, boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_2; commit;
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_so_idD=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
insert into temp_2(n10,c1,n9,c2,n1) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien
    from bh_bt_hs a,bh_bt_hs_nv b where a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_idD
    and a.n_duyet is not null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
insert into temp_2(n10,c1,n9,c2,n2) select a.so_id,a.so_hs,a.ngay_ht,b.ma_nt,b.tien
    from bh_bt_hs a,bh_bt_hs_nv b where a.ma_dvi=b_ma_dvi and a.so_id_hd=b_so_idD
    and a.n_duyet is null and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.so_id_dt=b_so_id_dt;
open cs1 for select n10 so_id,c1 so_hs,n9 ngay_ht,c2 ma_nt,nvl(sum(n1),0) tien,nvl(sum(n2),0) ton from temp_2 group by n10,c1,n9,c2;
delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_LKE_PHIdt
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_idD number;
begin
-- Dan - Liet ke phi, boi thuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; delete temp_2; commit;
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_so_id=0 then b_loi:='loi:Hop dong goc da xoa:loi'; raise PROGRAM_ERROR; end if;
FBH_BT_HS_LKE_PHI(b_ma_dvi,b_so_idD,b_so_id,cs1,cs2);
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TON_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du boi thuong
select nvl(min(so_id),0) into b_i1 from bh_bt_hs_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='Sai so du boi thuong ho so '|| FBH_BT_HS_SOHS(b_ma_dvi,b_i1)||':loi'; else b_loi:=''; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_TON_KTRA:loi'; end if;
end;
/
create or replace function FBH_BT_HS_SOHS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_hs varchar2(50);
begin
-- Dan - Tra so ho so qua ID
select min(so_hs) into b_so_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_hs;
end;
/
create or replace function PBH_BT_HS_SOID(b_ma_dvi varchar2,b_so_hs varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so ho so
select nvl(min(so_id),0) into b_so_id from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
return b_so_id;
end;
/
create or replace function PBH_BT_HS_HD_SO_ID(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_so_id_hd number;
begin
-- Dan - Tra SO_ID hop dong
select nvl(min(so_id_hd),0) into b_so_id_hd from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_id_hd;
end;
/
create or replace function PBH_BT_HS_HD_SO_HS_G(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_hs_g varchar2(50):=' ';
begin
-- Nam - Tra SO_HS_G theo ID
select nvl(min(so_hs_g),0) into b_so_hs_g from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_hs_g;
end;
/
create or replace function FBH_BT_HS_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_id_hd number; b_so_hd varchar2(50):='';
begin
-- Dan - Tra so hop dong
b_so_id_hd:=PBH_BT_HS_HD_SO_ID(b_ma_dvi,b_so_id);
if b_so_id_hd<>0 then b_so_hd:=FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id_hd); end if;
return b_so_hd;
end;
/
create or replace function FBH_BT_HS_CHS(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra loai ho so cua TTGD
select count(*) into b_i1 from bh_bt_chs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='C'; else b_kq:='K'; end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_HS_ID_DVI(
    b_ma_dvi varchar2,b_so_id number,b_so_id_hd out number,b_ma_dvi_ql out varchar2,b_ma_dvi_xl out varchar2)
AS
begin
-- Dan - Tra don vi quan ly, xu ly
select nvl(min(so_id_hd),0),min(ma_dvi_ql),min(ma_dvi_xl) into b_so_id_hd,b_ma_dvi_ql,b_ma_dvi_xl from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_id_hd=0 then
    select nvl(min(so_id_hd),0),min(ma_dvi_ql),min(ma_dvi_xl) into b_so_id_hd,b_ma_dvi_ql,b_ma_dvi_xl
        from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
end;
/
create or replace function FBH_BT_HS_DVI_QL(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra don vi quan ly hop dong
select min(ma_dvi_ql) into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_DVI_XL(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra don vi xu ly boi thuong
select min(ma_dvi_xl) into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_PHONG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra phong quan ly hop dong
select min(phong) into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_ID_HD(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra so_id hop dong
select nvl(min(so_id_hd),0) into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_HD_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra NV hop dong
select nvl(min(nv),' ') into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_BT_HS_HD_DL(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_id_hd number; b_ma_dvi_ql varchar2(10); b_ma_dvi_xl varchar2(10); b_ma_dl varchar2(10):=''; b_kieu_kt varchar2(1);
begin
-- Dan - Tra dai ly hop dong
PBH_BT_HS_ID_DVI(b_ma_dvi,b_so_id,b_so_id_hd,b_ma_dvi_ql,b_ma_dvi_xl);
if b_so_id_hd<>0 then
    select kieu_kt,ma_kt into b_kieu_kt,b_ma_dl from bh_hd_goc where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd;
    if b_kieu_kt not in('D','M') then b_ma_dl:=''; end if;
end if;
return b_ma_dl;
end;
/
create or replace function FBH_BT_HS_HD_KH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_id_hd number; b_ma_dvi_ql varchar2(10); b_ma_dvi_xl varchar2(10); b_ma_kh varchar2(20):='';
begin
-- Dan - Tra ma khach hang hop dong
PBH_BT_HS_ID_DVI(b_ma_dvi,b_so_id,b_so_id_hd,b_ma_dvi_ql,b_ma_dvi_xl);
if b_so_id_hd<>0 then 
    select ma_kh into b_ma_kh from bh_hd_goc where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd;
end if;
return b_ma_kh;
end;
/
create or replace function FBH_BT_HS_HD_TEN(b_ma_dvi varchar2,b_so_id number) return nvarchar2
AS
    b_so_id_hd number; b_ten nvarchar2(200):=''; b_ma_dvi_ql varchar2(10); b_ma_dvi_xl varchar2(10);
begin
-- Dan - Tra ten khach hang hop dong
PBH_BT_HS_ID_DVI(b_ma_dvi,b_so_id,b_so_id_hd,b_ma_dvi_ql,b_ma_dvi_xl);
if b_so_id_hd<>0 then 
    select ten into b_ten from bh_hd_goc where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd;
end if;
return b_ten;
end;
/
/*** BOI THUONG HO ***/
create or replace function FBH_BT_HO_K_THUE(b_ma_dvi varchar2,b_so_id number,b_dvi_xl varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra kieu xu ly thue
select nvl(min(k_thue),'C') into b_kq from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl in('*',b_dvi_xl);
return b_kq;
end;
/
create or replace function FBH_BT_HO_HD(b_ma_dvi varchar2,b_so_id number,b_dvi_xl varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra hop dong cho phep boi thuong ho
select count(*) into b_kq from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl in('*',b_dvi_xl);
return b_kq;
end;
/
create or replace function FBH_BT_HO_DT(b_ma_dvi varchar2,b_so_id number,b_dvi_xl varchar2,b_so_id_dt number) return number
AS
    b_kq number;
begin
-- Dan - Tra doi tuong cho phep boi thuong ho
select count(*) into b_kq from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl in('*',b_dvi_xl) and so_id_dt in(b_so_id_dt,0);
return b_kq;
end;
/
create or replace function FBH_BT_HO_DVI(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra don vi boi thuong ho
select min(dvi_xl) into b_kq from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(b_so_id_dt,0);
return b_kq;
end;
/
create or replace function FBH_BT_DS_DT(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
AS
    b_kq number;
begin
-- Dan - Tra doi tuong co trong ho so boi thuomg
if b_so_id>0 then
    select count(*) into b_kq from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(b_so_id_dt,0);
else
    select count(*) into b_kq from bh_bt_dt_temp;
end if;
return b_kq;
end;
/
create or replace function FBH_BT_NGAY_XR(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra doi tuong co trong ho so boi thuomg
select nvl(min(ngay_xr),0) into b_kq from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_BT_HO_LKE_DVI
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai so hop dong:loi';
if b_so_hd is null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
open cs1 for select distinct dvi_xl from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HO_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,b_dvi_xl varchar2,cs1 out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_so_id number; b_so_id_bs number;
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dvi_xl is null or b_so_hd is null then b_loi:='loi:Nhap don vi xu ly va so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,30000101);
open cs1 for select a.*,FBH_HD_TEN_DT(b_ma_dvi,b_so_id_bs,so_id_dt) ten from bh_bt_ho a where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl=b_dvi_xl;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,
    b_dvi_xl varchar2,b_k_thue varchar2,a_so_id_dt in out pht_type.a_num)
AS
    b_loi nvarchar2(200); b_i1 number; b_so_id number; b_so_id_bs number; b_nv varchar2(10);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma don vi xu ly:loi'; PKH_MANG_N(a_so_id_dt);
if b_dvi_xl is null or b_dvi_xl=b_ma_dvi then raise PROGRAM_ERROR; end if;
if b_dvi_xl<>'*' then
    select 0 into b_i1 from ht_ma_dvi where ma=b_dvi_xl;
elsif a_so_id_dt.count<>0 then
    b_loi:='loi:Khong nhap danh muc doi tuong:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Sai so hop dong:loi';
if b_so_hd is null then raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
if b_k_thue is null or b_k_thue not in('K','C') then b_loi:='loi:Sai kieu xu ly thue:loi'; raise PROGRAM_ERROR; end if;
delete bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl=b_dvi_xl;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
if b_nv in('2BL','TAUL','HANGL') or a_so_id_dt.count=0 then
    insert into bh_bt_ho values(b_ma_dvi,b_so_id,b_nv,b_dvi_xl,b_k_thue,0,b_nsd);
else
    b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,30000101);
    for b_lp in 1..a_so_id_dt.count loop
        b_loi:='loi:Doi tuong dong '||to_char(b_lp)||' da xoa:loi';
        -- LAM SACH
--         if b_nv='XE' then
--             select 0 into b_i1 from bh_xegcn where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='2B' then
--             select 0 into b_i1 from bh_2bgcn where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='TAU' then
--             select 0 into b_i1 from bh_taugcn where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='PHH' then
--             select 0 into b_i1 from bh_phhgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='PKT' then
--             select 0 into b_i1 from bh_pktgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='PTN' then
--             select 0 into b_i1 from bh_ptngcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='HANG' then
--             select 0 into b_i1 from bh_hhgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         elsif b_nv='NG' then
--             select 0 into b_i1 from bh_nguoihd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=a_so_id_dt(b_lp);
--         end if;
        insert into bh_bt_ho values(b_ma_dvi,b_so_id,b_nv,b_dvi_xl,b_k_thue,a_so_id_dt(b_lp),b_nsd);
    end loop;
end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_BT_HO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,b_dvi_xl varchar2)
AS
    b_loi nvarchar2(200); b_i1 number; b_so_id number; b_so_id_bs number; b_nv varchar2(10);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dvi_xl is null or b_so_hd is null then b_loi:='loi:Nhap don vi xu ly va so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Sai so hop dong:loi'; raise PROGRAM_ERROR; end if;
delete bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id and dvi_xl=b_dvi_xl;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GOC_TIM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi_ql varchar2,b_ma_bh varchar2,
    b_ten_kh varchar2,b_gcn_m varchar2,b_gcn_c varchar2,b_gcn_s varchar2,
    b_bien_xe varchar2,b_so_khung varchar2,b_so_may varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi nvarchar2(200); b_i1 number;
begin
-- Dan - Tim hop dong goc
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; delete temp_2; delete temp_3; commit;
insert into temp_3(n1) select distinct so_id from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl in('*',b_ma_dvi);
--LAM SACH
-- if b_ma_bh in(' ','2B') then
--     insert into temp_1(n1) select distinct so_id from bh_2bgcn where ma_dvi=b_ma_dvi_ql and
--         (b_gcn_m is null or gcn_m like b_gcn_m) and (b_gcn_c is null or gcn_c like b_gcn_c) and (b_gcn_s is null or gcn_s like b_gcn_s) and
--         (b_bien_xe is null or bien_xe like b_bien_xe) and (b_so_khung is null or so_khung like b_so_khung) and (b_so_may is null or so_may like b_so_may)
--         and so_id in (select n1 from temp_3);
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'2B',so_hd,ten from bh_2bhdgoc where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select distinct n1 from temp_1);
-- end if;
-- if b_ma_bh in(' ','XE') then
--     insert into temp_1(n1) select distinct so_id from bh_xegcn where ma_dvi=b_ma_dvi_ql and
--         (b_gcn_m is null or gcn_m like b_gcn_m) and (b_gcn_c is null or gcn_c like b_gcn_c) and (b_gcn_s is null or gcn_s like b_gcn_s) and
--         (b_bien_xe is null or bien_xe like b_bien_xe) and (b_so_khung is null or so_khung like b_so_khung) and (b_so_may is null or so_may like b_so_may)
--         and so_id in (select n1 from temp_3);
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'XE',so_hd,ten from bh_xehdgoc where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select distinct n1 from temp_1);
-- end if;
-- if b_ma_bh in(' ','NG') then
--     insert into temp_1(n1) select distinct so_id from bh_nguoihd_ds where ma_dvi=b_ma_dvi_ql and
--         (b_gcn_m is null or gcn_m like b_gcn_m) and (b_gcn_c is null or gcn_c like b_gcn_c) and (b_gcn_s is null or gcn_s like b_gcn_s)
--         and so_id in (select n1 from temp_3);
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'NG',so_hd,ten from bh_nguoihd where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select distinct n1 from temp_1);
-- end if;
-- if b_ma_bh in(' ','TAU') then
--     insert into temp_1(n1) select distinct so_id from bh_taugcn where ma_dvi=b_ma_dvi_ql and (b_gcn_s is null or gcn like b_gcn_s)
--         and (b_ten_kh is null or ten like b_ten_kh or ten_tau like b_ten_kh) and so_id in (select n1 from temp_3);
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'TAU',so_hd,ten from bh_tauhdgoc where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select distinct n1 from temp_1);
-- end if;
-- if b_ma_bh in(' ','HANG') then
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'HANG',so_hd,ten from bh_hhgcn where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select n1 from temp_3);
-- end if;
-- if b_ma_bh in(' ','PHH') then
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'PHH',so_hd,ten from bh_phhgcn where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select n1 from temp_3);
-- end if;
-- if b_ma_bh in(' ','PKT') then
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'PKT',so_hd,ten from bh_pktgcn where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select n1 from temp_3);
-- end if;
-- if b_ma_bh in(' ','PTN') then
--     insert into temp_2(n1,c1,c2,c3) select ngay_ht,'PTN',so_hd,ten from bh_ptngcn where ma_dvi=b_ma_dvi_ql and
--         (b_ten_kh is null or upper(ten) like b_ten_kh) and so_id in (select n1 from temp_3);
-- end if;
open cs_lke for select n1 ngay_ht,c1 nv,c2 so_hd,c3 ten from temp_2 order by n1,c1,c2;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PBH_BT_HS_PBO(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_ma_dvi_xl varchar2(10); b_so_id_dt number; b_so_id_hd number; b_so_id_kt number;
    b_tp number; b_bt number:=0; b_dvi_xl varchar2(10);
    b_tien number; b_tien_qd number; b_tien_t number; b_tien_qd_t number; b_tien_c number; b_tien_qd_c number;
    b_dvi_xlM varchar2(10); b_tienM number; b_ttrang varchar2(1);
begin
-- Dan - Tong hop phan bo boi thuong dong BH noi bo
b_loi:='loi:Loi tong hop phan bo boi thuong dong BH noi bo:loi';
select min(ma_dvi),nvl(max(so_id_kt),0) into b_dvi_xl,b_i1 from bh_bt_hs_pb where dvi_xl=b_ma_dvi and so_id=b_so_id;
if b_i1>0 then
    b_loi:='loi:Don vi '||b_dvi_xl||' da hach toan phan bo boi thuong:loi'; return;
end if;
delete bh_bt_hs_pb where dvi_xl=b_ma_dvi and so_id=b_so_id;
select min(ma_dvi_xl),nvl(min(ngay_qd),30000101),min(so_id_hd),min(ttrang)
    into b_ma_dvi_xl,b_ngay_ht,b_so_id_hd,b_ttrang
    from bh_bt_hs where ma_dvi_ql=b_ma_dvi and so_id=b_so_id;
if b_ttrang<>'D' then b_loi:=''; return; end if;
delete bh_bt_hs_pb_temp;
for r_lp in (select so_id_dt,lh_nv,ma_nt,sum(tien) tien,sum(tien_qd) tien_qd from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi_xl and so_id=b_so_id group by so_id_dt,lh_nv,ma_nt) loop
    b_so_id_dt:=r_lp.so_id_dt; b_dvi_xlM:=b_ma_dvi; b_tienM:=0;
    b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd; b_tien_c:=b_tien; b_tien_qd_c:=b_tien_qd;
    if r_lp.ma_nt='VND' then b_tp:=0; else b_tp:=2; end if;
    for r_lp1 in (select nha_bh,pthuc,sum(pt) pt from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id_hd
        and so_id_dt in(0,b_so_id_dt) and pthuc in('P','D') and lh_nv in (' ', r_lp.lh_nv) group by nha_bh,pthuc) loop
        b_tien_t:=round(b_tien*r_lp1.pt/100,b_tp); b_tien_qd_t:=round(b_tien_qd*r_lp1.pt/100,0);
        if r_lp1.pthuc='D' then b_dvi_xl:=r_lp1.nha_bh; b_so_id_kt:=0;
        else b_dvi_xl:=b_ma_dvi; b_so_id_kt:=-1; end if;
        insert into bh_bt_hs_pb_temp values(b_dvi_xl,' ',r_lp.lh_nv,r_lp.ma_nt,b_tien_t,b_tien_qd_t,b_so_id_kt);
        b_tien_c:=b_tien_c-b_tien_t; b_tien_qd_c:=b_tien_qd_c-b_tien_qd_t;
        if b_tienM<b_tien_t then b_tienM:=b_tien_t; b_dvi_xlM:=b_dvi_xl; end if;
    end loop;
    if b_tien_c<>0 or b_tien_qd_c<>0 then
        if b_dvi_xlM=b_ma_dvi then b_so_id_kt:=-1; else b_so_id_kt:=0; end if;
        insert into bh_bt_hs_pb_temp values(b_dvi_xlM,' ',r_lp.lh_nv,r_lp.ma_nt,b_tien_c,b_tien_qd_c,-1);
    end if;
end loop;
for r_lp in (select dvi_xl,lh_nv,ma_nt,so_id_kt,sum(tien) tien,sum(tien_qd) tien_qd
    from bh_bt_hs_pb_temp group by dvi_xl,lh_nv,ma_nt,so_id_kt) loop
    b_bt:=b_bt+1;
    insert into bh_bt_hs_pb values(r_lp.dvi_xl,b_so_id,b_bt,b_ngay_ht,b_ma_dvi,
        ' ',b_so_id_hd,r_lp.lh_nv,r_lp.ma_nt,r_lp.tien,r_lp.tien_qd,r_lp.so_id_kt);
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_PBO:loi'; end if;
end;
/
/*** KIEM SOAT ***/
create or replace procedure PBH_BT_HS_KSOAT_NH
    (b_ma_dvi_ks varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_so_id number)
AS
    b_loi nvarchar2(200); b_i1 number; b_ngay_qd number; b_ttrang varchar2(1);
    b_ksoat varchar2(10); b_qu varchar2(1); b_nv varchar2(5);
    a_muc_rr pht_type.a_var; a_lh_nv pht_type.a_var; a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
begin
-- Dan - Kiem soat nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi_ks,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so dang xu ly:loi';
select ksoat,ngay_qd,nv,ttrang into b_ksoat,b_ngay_qd,b_nv,b_ttrang from bh_bt_hs
    where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_ttrang='D' then b_loi:='loi:Ho so da duyet:loi'; raise PROGRAM_ERROR; end if;
if b_ksoat is not null then b_loi:='loi:Ho so da kiem soat:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dvi_ks<>b_ma_dvi then
    b_qu:=FHT_MA_NSD_DVI(b_ma_dvi_ks,b_nsd,'BH','BT','N',b_ma_dvi);
else
    b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','N');
end if;
if b_qu<>'C' then b_loi:='loi:Khong phan cap duyet boi thuong:loi'; raise PROGRAM_ERROR; end if;
select lh_nv,tien_qd,'VND',' ' bulk collect into a_lh_nv,a_tien,a_ma_nt,a_muc_rr from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id;
if FBH_MA_NSD_LHNV(b_ma_dvi_ks,b_nsd,'B',b_nv,b_ngay_qd,a_muc_rr,a_lh_nv,a_ma_nt,a_tien,a_tien)='C' then
    b_loi:='loi:Vuot qua nguong duyet boi thuong:loi'; raise PROGRAM_ERROR;
end if;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','Q')<>'C' and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','H')<>'C' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
update bh_bt_hs set so_id_kt=0,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd,ngay_qd=b_ngay_qd,ngay_nh=sysdate
    where ma_dvi_xl=b_ma_dvi and so_id=b_so_id;
PBH_BT_HS_UP_NH(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_KSOAT_XOA(
    b_ma_dvi_ks varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_so_id number)
AS
    b_loi nvarchar2(200); b_dvi_ks varchar2(10); b_ksoat varchar2(10);
    b_qu varchar2(1); b_ngay_qd number;
begin
-- Dan - Kiem soat xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi_ks,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so dang xu ly xoa:loi';
select dvi_ksoat,ksoat,ngay_qd into b_dvi_ks,b_ksoat,b_ngay_qd from bh_bt_hs
    where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_ksoat is null then b_loi:='loi:Ho so khong bi kiem soat:loi'; raise PROGRAM_ERROR; end if;
if b_dvi_ks<>b_ma_dvi_ks or b_ksoat<>b_nsd then b_loi:='loi:Khong xoa kiem soat cua nguoi khac:loi'; raise PROGRAM_ERROR; end if;
if b_ma_dvi_ks<>b_ma_dvi then
    b_qu:=FHT_MA_NSD_DVI(b_ma_dvi_ks,b_nsd,'BH','BT','N',b_ma_dvi);
else
    b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BT','N');
end if;
if b_qu<>'C' then b_loi:='loi:Khong phan cap duyet boi thuong:loi'; raise PROGRAM_ERROR; end if;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','Q')<>'C' and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','BH','H')<>'C' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_HS_UP_XOA(b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_DSDT_TIM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type,
    b_ngay_ht number,b_ma_dvi_ql varchar2,b_so_hd varchar2,b_xe_m varchar2,b_xe_c varchar2,
    b_xe_s varchar2,b_bien_xe varchar2,b_so_khung varchar2,b_so_may varchar2,b_ten_dt varchar2)
AS
    b_loi nvarchar2(200); b_i1 number; b_so_id_hd number;b_nv varchar2(10); b_bang varchar2(50); b_so_id_b number;
    b_so_id number;  
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong da xoa:loi';
select so_id into b_so_id_hd from bh_hd_goc where ma_dvi=b_ma_dvi_ql and so_hd=b_so_hd;
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id_hd); b_bang:=FBH_HD_GOC_BANG(b_nv); 
b_so_id_b:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id_hd,b_ngay_ht);
--LAM SACH
-- if b_ma_dvi=b_ma_dvi_ql then
--     if b_nv='2B' then
--         open cs1 for select trim(gcn) gcn,'GCN:'||trim(gcn)||', Bien xe:'||trim(bien_xe)||', Ten:'||trim(ten) ten,so_id_dt
--         from bh_2bgcn where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_bien_xe is null or bien_xe like '%'||b_bien_xe||'%') order by so_id_dt;
--     elsif b_nv='XE' then
--         open cs1 for select trim(gcn) gcn,'GCN:'||trim(gcn)||', Bien xe:'||trim(bien_xe)||', Ten:'||trim(ten) ten,so_id_dt
--         from bh_xegcn where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_bien_xe is null or bien_xe like '%'||b_bien_xe||'%') order by so_id_dt;
--     elsif b_nv='TAU' then
--         open cs1 for select trim(gcn) gcn,substr(decode(gcn,' ','','GCN:'||trim(gcn)||', Ten:')||trim(ten_tau),1,200) ten,so_id_dt
--         from bh_taugcn where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_ten_dt is null or upper(ten_tau) like b_ten_dt)order by so_id_dt;
--     elsif b_nv='PHH' then
--         open cs1 for select ' ' gcn,dvi ten,so_id_dt 
--         from bh_phhgcn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_ten_dt is null or upper(dvi) like b_ten_dt)order by bt;
--     elsif b_nv='PKT' then
--         open cs1 for select ' ' gcn,dvi ten,so_id_dt 
--         from bh_pktgcn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_ten_dt is null or upper(dvi) like b_ten_dt)order by bt;
--     elsif b_nv='PTN' then
--         open cs1 for select ' ' gcn,dvi ten,so_id_dt 
--         from bh_ptngcn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_ten_dt is null or upper(dvi) like b_ten_dt)order by bt;
--     elsif b_nv='HANG' then
--          open cs1 for select distinct ' ' gcn,ten_pt ten,so_id_dt
--         from bh_hhgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_ten_dt is null or ten_pt like b_ten_dt) order by so_id_dt;
--     elsif b_nv='NG' then
--         open cs1 for select substr('GCN:'||trim(gcn)||',Ten:'||trim(ten),1,200) ten,so_id_dt
--         from bh_nguoihd_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_b and (b_ten_dt is null or upper(ten) like b_ten_dt) order by so_id_dt;
--     end if;
-- else
--     if FBH_BT_HO_HD(b_ma_dvi_ql,b_so_id_hd,b_ma_dvi)=0 then
--            b_loi:='loi:Hop dong khong duoc phep boi thuong ho:loi'; raise PROGRAM_ERROR;
--     end if;
--     b_so_id:=FBH_HD_SO_ID_BS(b_ma_dvi_ql,b_so_id_hd,30000101);
--     select nvl(min(so_id_dt),0) into b_i1 from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl=b_ma_dvi and so_id=b_so_id_hd;
--     if b_nv='2B' then
--         open cs1 for select so_id_dt,'GCN:'||trim(gcn)||', Bien xe:'||trim(bien_xe)||', Ten:'||trim(ten) ten
--             from bh_2bgcn where ma_dvi=b_ma_dvi_ql and so_id=b_so_id and (b_bien_xe is null or bien_xe like '%'||b_bien_xe||'%') and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql 
--             and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by so_id_dt;
--     elsif b_nv='XE' then
--         open cs1 for select so_id_dt,'GCN:'||trim(gcn)||', Bien xe:'||trim(bien_xe)||', Ten:'||trim(ten) ten
--             from bh_xegcn where ma_dvi=b_ma_dvi_ql and so_id=b_so_id and (b_bien_xe is null or bien_xe like '%'||b_bien_xe||'%') and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql
--             and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by so_id_dt;
--     elsif b_nv='TAU' then
--         open cs1 for select so_id_dt,'GCN:'||trim(gcn)||', Ten:'||trim(ten_tau) ten
--             from bh_taugcn where ma_dvi=b_ma_dvi_ql and so_id=b_so_id  and (b_ten_dt is null or upper(ten_tau) like b_ten_dt) and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql
--             and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by so_id_dt;
--     elsif b_nv='PHH' then
--         open cs1 for select so_id_dt,dvi ten from bh_phhgcn_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id 
--             and (b_ten_dt is null or upper(dvi) like b_ten_dt) and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by bt;
--     elsif b_nv='PKT' then
--         open cs1 for select so_id_dt,dvi ten from bh_pktgcn_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id 
--             and (b_ten_dt is null or upper(dvi) like b_ten_dt) and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by bt;
--     elsif b_nv='PTN' then
--         open cs1 for select so_id_dt,dvi ten from bh_ptngcn_dvi where ma_dvi=b_ma_dvi_ql and so_id=b_so_id 
--             and (b_ten_dt is null or upper(dvi) like b_ten_dt) and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by bt;
--     elsif b_nv='HANG' then
--         open cs1 for select distinct so_id_dt,ten_pt ten from bh_hhgcn_dk where ma_dvi=b_ma_dvi_ql and so_id=b_so_id
--             and (b_ten_dt is null or ten_pt like b_ten_dt) and
--             so_id_dt in(select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by so_id_dt;
--     elsif b_nv='NG' then
--         open cs1 for select so_id_dt,'GCN:'||trim(gcn)||',Ten:'||trim(ten) ten
--             from bh_nguoihd_ds where ma_dvi=b_ma_dvi_ql and so_id=b_so_id and (b_ten_dt is null or upper(ten) like b_ten_dt) and so_id_dt in
--             (select so_id_dt from bh_bt_ho where ma_dvi=b_ma_dvi_ql and dvi_xl=b_ma_dvi and so_id=b_so_id_hd) order by so_id_dt;
--     end if;
-- end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;

/
/*** TT GIAM DINH ***/
create or replace procedure PBH_BT_CHS_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,b_klk varchar2,b_dk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TTGD','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_klk='N' then
    if b_dk='D' then
        insert into temp_1(n1,c1) select so_id,so_hs from
            (select so_id,so_hs,nsd,ngay_qd from bh_bt_chs where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc
            and nsd=b_nsd and FBH_BT_HS_TTRANG(ma_dvi,so_id)='T');
    else
        insert into temp_1(n1,c1) select so_id,so_hs from
            (select so_id,so_hs,nsd from bh_bt_chs where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc)
            where nsd=b_nsd;
    end if;
else
    if b_dk='D' then
        insert into temp_1(n1,c1) select so_id,so_hs from
            (select so_id,so_hs,ngay_qd from bh_bt_chs where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc
            and FBH_BT_HS_TTRANG(ma_dvi,so_id)='T');
    else
        insert into temp_1(n1,c1) select so_id,so_hs from bh_bt_chs where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc;
    end if;
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select n1 so_id,c1 so_hs from (select n1,c1,row_number() over (order by n1) sott from temp_1 order by n1) where sott between b_tu and b_den;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_CHS_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngayd number,b_ngayc number,
    b_klk varchar2,b_dk varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TTGD','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_klk='N' then
    if b_dk='D' then
        insert into temp_1(n1,c1) select so_id,so_hs from
            (select so_id,so_hs,nsd,ngay_qd from bh_bt_Chs where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc
            and nsd=b_nsd and FBH_BT_HS_TTRANG(ma_dvi,so_id)='T');
    else
        insert into temp_1(n1,c1) select so_id,so_hs from
            (select so_id,so_hs,nsd,ngay_qd from bh_bt_Chs where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc and nsd=b_nsd);
    end if;
else
    if b_dk='D' then
        insert into temp_1(n1,c1) select so_id,so_hs from
            (select so_id,so_hs,nsd,ngay_qd from bh_bt_chs where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc and FBH_BT_HS_TTRANG(ma_dvi,so_id)='T');
    else
        insert into temp_1(n1,c1) select so_id,so_hs from bh_bt_chs where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc;
    end if;
end if;
select count(*) into b_dong from temp_1;
select nvl(min(sott),b_dong) into b_tu from (select n1,row_number() over (order by n1) sott from temp_1 order by n1) where n1>=b_so_id;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select c1 so_hs,n1 so_id,row_number() over (order by n1) sott from temp_1 order by n1) where sott between b_tu and b_den;
delete temp_1; commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_BT_CDS_DT(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return number
AS
    b_kq number;
begin
-- Dan - Tra doi tuong co trong ho so boi thuomg
if b_so_id>0 then
    select count(*) into b_kq from bh_bt_chs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(b_so_id_dt,0);
else
    select count(*) into b_kq from bh_bt_dt_temp;
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_CHS_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi_ql varchar2,b_so_hs varchar2,b_so_id out number)
AS
    b_loi varchar2(100);
begin
-- Dan - Hoi SO ID qua so ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TTGD','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(so_id),0) into b_so_id from bh_bt_chs where ma_dvi_ql=b_ma_dvi_ql and so_hs=b_so_hs;
end;
/
create or replace procedure PBH_BT_THOP_LAI(b_ma_dvi varchar2,b_ngayd number,b_ngayc number)
AS
    b_loi nvarchar2(200); b_i1 number; b_ma_nt varchar2(5);
    b_so_id number; b_ngay_qd number; b_tl_do number; b_tp number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_tienH number; b_tien_qdH number; b_tien number; b_tien_qd number; b_tienC number; b_tien_qdC number;
    a_dt_nbh pht_type.a_var; a_dt_lh_nv pht_type.a_var; a_dt_pt pht_type.a_num;
    a_nbhX pht_type.a_var; a_ma_ntX pht_type.a_var; a_tienX pht_type.a_num; a_tien_qdX pht_type.a_num;
begin
-- Dan -- Tong hop lai so cai BH_BT_HS_SC
delete bh_bt_hs_sc where ma_dvi=b_ma_dvi and ngay_ht>=b_ngayd;
commit;
PKH_MANG_KD(a_nbhX); PKH_MANG_KD_N(a_tienX); PKH_MANG_KD_N(a_tien_qdX);
for r_lp1 in (select so_id,nv,ngay_qd,ma_dvi_ql,so_id_hd,so_id_dt from bh_bt_hs where
    ma_dvi=b_ma_dvi and ttrang='D' and ngay_qd between b_ngayd and b_ngayc) loop
    b_so_id:=r_lp1.so_id; b_ngay_qd:=r_lp1.ngay_qd;
    b_ma_dvi_ql:=r_lp1.ma_dvi_ql; b_so_id_hd:=r_lp1.so_id_hd; b_so_id_dt:=r_lp1.so_id_dt;
    PKH_MANG_XOA(a_nbhX); PKH_MANG_XOA_N(a_tienX); PKH_MANG_XOA_N(a_tien_qdX);
    b_tienH:=0; b_tien_qdH:=0;
    if FBH_DONG(b_ma_dvi_ql,b_so_id_hd)='V' then
        select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
            from bh_hd_do_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt) and pthuc='C'
            group by nha_bh,lh_nv;
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            PBH_BH_HS_NBH_TH(b_ma_dvi,b_so_id,'T',b_ngay_qd,a_nbhX(b_lp),b_ma_nt,a_tienX(b_lp),a_tien_qdX(b_lp),b_loi);
            if b_loi is not null then return; end if;
            b_tienH:=b_tien+a_tienX(b_lp); b_tien_qdH:=b_tien_qd+a_tien_qdX(b_lp);
        end loop;
    end if;
    if FBH_HD_DO_NH_NHOM(b_ma_dvi_ql,b_so_id_hd,'T')='C' then
        select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
            from tbh_tmN_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt)
            group by so_id_dt,nha_bh,lh_nv;
        PKH_MANG_XOA(a_nbhX); PKH_MANG_XOA_N(a_tienX); PKH_MANG_XOA_N(a_tien_qdX);
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            PBH_BH_HS_NBH_TH(b_ma_dvi,b_so_id,'T',b_ngay_qd,a_nbhX(b_lp),b_ma_nt,a_tienX(b_lp),a_tien_qdX(b_lp),b_loi);
            if b_loi is not null then return; end if;
            b_tienH:=b_tien+a_tienX(b_lp); b_tien_qdH:=b_tien_qd+a_tien_qdX(b_lp);
        end loop;
    end if;
    if b_tienH=0 then
        for r_lp in (select * from bh_bt_tba_ps where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            PBH_BT_TBA_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,r_lp.ten,r_lp.ma_nt,r_lp.tien,b_loi);
            if b_loi is not null then return; end if;
        end loop;
        for r_lp in (select * from bh_bt_hk_ps where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            PBH_BT_HK_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,r_lp.ma,b_ma_nt,r_lp.tien,r_lp.tien_qd,b_loi);
            if b_loi is not null then return; end if;
        end loop;
        select sum(tien),sum(tien_qd) into b_tienH,b_tien_qdH from bh_bt_hs_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhtra',r_lp1.nv)='C' then
            select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
                from bh_hd_do_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt) and pthuc='C'
                group by nha_bh,lh_nv;
            PKH_MANG_KD(a_nbhX); PKH_MANG_KD_N(a_tienX); PKH_MANG_KD_N(a_tien_qdX);
            for r_lp in (select lh_nv,tien,tien_qd from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
                b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
                for b_lp in 1..a_dt_nbh.count loop
                    if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                        b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                        b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                        b_i1:=0;
                        for b_lp1 in 1..a_nbhX.count loop
                            if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                        end loop;
                        if b_i1=0 then
                            b_i1:=a_nbhX.count+1;
                            a_nbhX(b_i1):=a_dt_nbh(b_lp);
                            a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                        else
                            a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                        end if;
                    end if;
                end loop;
            end loop;
            for b_lp in 1..a_nbhX.count loop
                b_tienH:=b_tienH-a_tienX(b_lp); b_tien_qdH:=b_tien_qdH-a_tien_qdX(b_lp);
            end loop;
        end if;
    end if;
    PBH_BT_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,b_tienH,b_tien_qdH,b_loi);
    if b_loi is not null then return; end if;
    commit;
end loop;
for r_lp1 in (select distinct ngay_ht from bh_bt_tu where ma_dvi=b_ma_dvi and (ngay_ht between b_ngayd and b_ngayc)) loop
    b_ngay_qd:=r_lp1.ngay_ht;
    for r_lp in (select l_ct,so_id_hs,ma_nt,tien,tien_qd from bh_bt_tu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_qd) loop
        PBH_BT_HS_THOP(b_ma_dvi,r_lp.l_ct,b_ngay_qd,r_lp.so_id_hs,r_lp.ma_nt,r_lp.tien,r_lp.tien_qd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end loop;
    commit;
end loop;
for r_lp1 in (select so_id_tt,ngay_ht from bh_bt_tt where ma_dvi=b_ma_dvi and (ngay_ht between b_ngayd and b_ngayc)) loop
    b_so_id:=r_lp1.so_id_tt; b_ngay_qd:=r_lp1.ngay_ht;
    for r_lp in (select so_id,ma_nt,tien,tien_qd from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id) loop
        PBH_BT_HS_THOP(b_ma_dvi,'C',b_ngay_qd,r_lp.so_id,r_lp.ma_nt,r_lp.tien,r_lp.tien_qd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end loop;
    commit;
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HU_XOA(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Xoa huy tu boi thuong
b_loi:='loi:Loi xoa huy:loi';
delete bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if sql%rowcount<>0 then
    PTBH_CBI_HU_XOA(b_ma_dvi,b_so_id,b_loi);
else
    b_loi:='';
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HU_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_HU_NH(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_loi out varchar2)
AS
begin
-- Dan - Huy tu boi thuong
b_loi:='loi:Loi nhap huy:loi';
insert into bh_hd_goc_hu
    select b_ma_dvi,b_so_id,nv,so_hd,b_ngay,' ',0,'VND',0,0,0,0,0,0,0,0,
    'T','VND',0,0,'K',phong,ma_kh,ten,' ','S',' ',' ',' ',' ',0,'',sysdate
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
PTBH_CBI_HU_NH(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HU_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_HS_UP_NH(
    b_ma_dvi varchar2,b_so_id number,b_ma_dviN varchar2,b_nsdN varchar2,b_loi out varchar2,b_du varchar2:='K')
AS
    b_i1 number; b_i2 number; b_ngay_qd number; b_so_id_dt number; r_hd bh_bt_hs%rowtype;
    b_kieu_do varchar2(1); b_kieu_tmN varchar2(1);  b_ma_nt varchar2(5); b_tp number:=0;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_bt number; b_dbhtra varchar2(1);
    b_tienC number; b_tien_qdC number; b_tien number; b_tien_qd number;
    b_tienH number:=0; b_tien_qdH number:=0;
    a_dt_so_id pht_type.a_num; a_dt_nbh pht_type.a_var; a_dt_lh_nv pht_type.a_var; a_dt_pt pht_type.a_num;
    a_nbhX pht_type.a_var; a_ma_ntX pht_type.a_var; a_tienX pht_type.a_num; a_tien_qdX pht_type.a_num;
begin
-- Dan - Kiem soat nhap
select * into r_hd from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.ttrang<>'D' then b_loi:=''; return; end if;
if r_hd.so_id_bt<>0 then
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=r_hd.so_id_bt and ttrang<>'T';
    if b_i1<>0 then b_loi:='loi:Ho so boi thuong da duyet:loi'; return; end if;
end if;
b_ma_dvi_ql:=r_hd.ma_dvi_ql; b_so_id_hd:=r_hd.so_id_hd; b_so_id_dt:=r_hd.so_id_dt;
b_ngay_qd:=r_hd.ngay_qd; b_ma_nt:=r_hd.nt_tien;
if b_ma_nt<>'VND' then b_tp:=2; end if;
PBH_PQU_BT(r_hd.nv,b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_BT_DU_NV(r_hd.nv,b_ma_dvi,b_so_id,b_ma_dviN,b_nsdN,r_hd.ttrang,b_ngay_qd,b_loi);
if b_loi is not null then return; end if;
/* --    Tam che test truoc trien khai
for r_lp in (select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd) loop
    select count(*) into b_i1 from bh_hd_goc_ttps where ma_dvi=b_ma_dvi_ql and so_id_tt=r_lp.so_id_tt and so_id_kt=0;
    if b_i1<>0 then b_loi:='loi:Thanh toan phi hop dong/GCN chua hach toan ke toan:loi'; return; end if;
end loop;
*/
b_kieu_do:=FBH_DONG(b_ma_dvi_ql,b_so_id_hd); b_kieu_tmN:=FTBH_TMN(b_ma_dvi_ql,b_so_id_hd);
b_dbhtra:=FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhtra',r_hd.nv);
PKH_MANG_KD(a_nbhX); PKH_MANG_KD_N(a_tienX); PKH_MANG_KD_N(a_tien_qdX);
if b_dbhtra='K' then
    if b_kieu_do='V' then
        select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
            from bh_hd_do_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt) and pthuc='C'
            group by nha_bh,lh_nv;
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            b_tienH:=b_tienH+a_tienX(b_lp); b_tien_qdH:=b_tien_qdh+a_tien_qdX(b_lp);
        end loop;
        for b_lp in 1..a_nbhX.count loop
            select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_tu
                where ma_dvi=b_ma_dvi and so_id_hs=b_so_id and nbh=a_nbhX(b_lp);
            a_tienX(b_lp):=a_tienX(b_lp)-b_i1; a_tien_qdX(b_lp):=a_tien_qdX(b_lp)-b_i2;
            PBH_BT_HS_NBH_TH(b_ma_dvi,b_so_id,'T',b_ngay_qd,a_nbhX(b_lp),b_ma_nt,a_tienX(b_lp),a_tien_qdX(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end loop;
    end if;
    if b_kieu_tmN='C' then
        select nha_bhC,lh_nv,sum(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
            from tbh_tmN_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt)
            group by so_id_dt,nha_bhC,lh_nv;
        PKH_MANG_XOA(a_nbhX); PKH_MANG_XOA_N(a_tienX); PKH_MANG_XOA_N(a_tien_qdX);
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            b_tienH:=b_tienH+a_tienX(b_lp); b_tien_qdH:=b_tien_qdh+a_tien_qdX(b_lp);
        end loop;
        for b_lp in 1..a_nbhX.count loop
            select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_tu
                where ma_dvi=b_ma_dvi and so_id_hs=b_so_id and nbh=a_nbhX(b_lp);
            a_tienX(b_lp):=a_tienX(b_lp)-b_i1; a_tien_qdX(b_lp):=a_tien_qdX(b_lp)-b_i2;
            PBH_BT_HS_NBH_TH(b_ma_dvi,b_so_id,'T',b_ngay_qd,a_nbhX(b_lp),b_ma_nt,a_tienX(b_lp),a_tien_qdX(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end loop;
    end if;
end if;
if b_tienH=0 then
    select sum(tien),sum(tien_qd) into b_tienH,b_tien_qdH from bh_bt_hs_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_hs_ps where ma_dvi=b_ma_dvi and
        so_id in (select so_id from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang='D');
    b_tienH:=b_tienH-b_i1; b_tien_qdH:=b_tien_qdH-b_i2;
    select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    b_tienH:=b_tienH-b_i1; b_tien_qdH:=b_tien_qdH-b_i2;
    select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_pa=b_so_id;
    b_tienH:=b_tienH-b_i1; b_tien_qdH:=b_tien_qdH-b_i2;
    select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    b_tienH:=b_tienH-b_i1; b_tien_qdH:=b_tien_qdH-b_i2;
    select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_pa=b_so_id;
    b_tienH:=b_tienH-b_i1; b_tien_qdH:=b_tien_qdH-b_i2;
    for r_lp in (select * from bh_bt_hk_ps where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        PBH_BT_HK_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,r_lp.ma,b_ma_nt,r_lp.tien,r_lp.tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    if b_dbhtra='C' then
        select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
            from bh_hd_do_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt) and pthuc='C'
            group by nha_bh,lh_nv;
        PKH_MANG_KD(a_nbhX); PKH_MANG_KD_N(a_tienX); PKH_MANG_KD_N(a_tien_qdX);
        for r_lp in (select lh_nv,tien,tien_qd from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            b_tienH:=b_tienH-a_tienX(b_lp); b_tien_qdH:=b_tien_qdH-a_tien_qdX(b_lp);
        end loop;
    end if;
    if b_tienH<>0 then
        PBH_BT_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,b_tienH,b_tien_qdH,b_loi);
        if b_loi is not null then return; end if;
    end if;
    for r_lp in (select * from bh_bt_tba_ps where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        PBH_BT_TBA_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,r_lp.ten,r_lp.ma_nt,r_lp.tien,b_loi);
        if b_loi is not null then return; end if;
    end loop;
elsif b_dbhtra='C' then 
    PBH_BT_HS_THOP(b_ma_dvi,'T',b_ngay_qd,b_so_id,b_ma_nt,b_tienH,b_tien_qdH,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_BT_HS_PBO(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_kieu_do='D' and b_dbhtra='K' then
    PBH_TH_DO_BTH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PTBH_TH_TA_BT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOL_BT(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_UP_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_HS_UP_XOA(
    b_ma_dvi varchar2,b_so_id number,b_ma_dviN varchar2,b_nsdN varchar2,b_loi out varchar2,b_du varchar2:='K')
AS 
    b_i1 number; b_i2 number; b_ngay_qd number; r_hd bh_bt_hs%rowtype;
    b_tienC number; b_tien_qdC number; b_tien number; b_tien_qd number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number; b_ma_nt varchar2(5); b_tp number:=0;
    b_kieu_do varchar2(1); b_dbhTra varchar2(1);
    a_dt_nbh pht_type.a_var; a_dt_lh_nv pht_type.a_var; a_dt_pt pht_type.a_num;
    a_nbhX pht_type.a_var; a_ma_ntX pht_type.a_var; a_tienX pht_type.a_num; a_tien_qdX pht_type.a_num;
Begin
-- Dan - Xoa update boi thuong
select * into r_hd from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.ttrang<>'D' then b_loi:=''; return; end if;
b_ma_dvi_ql:=r_hd.ma_dvi_ql; b_so_id_hd:=r_hd.so_id_hd; b_so_id_dt:=r_hd.so_id_dt;
b_ngay_qd:=r_hd.ngay_qd; b_ma_nt:=r_hd.nt_tien;
if b_ma_nt<>'VND' then b_tp:=2; end if;
if b_ma_dvi<>r_hd.ma_dvi_xl then b_loi:='loi:Khong sua, xoa chung tu boi thuong ho:loi'; return; end if;
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs_g=r_hd.so_hs;
if b_i1<>0 then b_loi:='loi:Ho so da tao ho so bo sung:loi'; return; end if;
if r_hd.so_id_bt<>0 then
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=r_hd.so_id_bt and ttrang<>'T';
    if b_i1<>0 then b_loi:='loi:Ho so boi thuong da duyet:loi'; return; end if;
end if;
select count(*) into b_i1 from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_loi:='loi:Ho so da thanh toan boi thuong:loi'; return; end if;
select count(*) into b_i1 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
if b_i1<>0 then b_loi:='loi:Ho so da thanh toan huong khac:loi'; return; end if;
select count(*) into b_i1 from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_bt=b_so_id;
if b_i1<>0 then b_loi:='loi:Ho so da thu doi nguoi thu 3:loi'; return; end if;
if r_hd.so_id_kt>0 then
    PBH_KT_TD_XOA(b_ma_dvi,r_hd.so_id_kt,b_loi);
    if b_loi is not null then return; end if;
end if;
if FBH_HD_DO_PS(b_ma_dvi_ql,b_so_id_hd,b_so_id)<>0 then b_loi:='loi:Ho so da thanh toan dong bao hiem:loi'; return; end if;
if FTBH_PS(b_ma_dvi_ql,b_so_id_hd,b_so_id)<>0 then b_loi:='loi:Khong xoa ho so da xu ly tai BH:loi'; return; end if;
if b_ma_dvi<>b_ma_dvi_ql and FBH_DONG_KYHO(b_ma_dvi_ql,b_so_id_hd,b_ma_dvi)<>'C' then
    select so_id_kt into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi_ql and so_id=b_so_id;
    if b_i1>0 then b_loi:='loi:Khong sua, xoa chung tu don vi quan ly hop dong da hach toan:loi'; return; end if;
    update bh_bt_hs set ngay_qd=30000101,n_duyet='',so_id_kt=-1,ksoat='',dvi_ksoat='',ttrang='T',ngay_nh=sysdate
        where ma_dvi=b_ma_dvi_ql and so_id=b_so_id;
end if;
PKH_MANG_KD(a_nbhX); PKH_MANG_KD_N(a_tienX); PKH_MANG_KD_N(a_tien_qdX);
b_kieu_do:=FBH_DONG(b_ma_dvi_ql,b_so_id_hd);
b_dbhTra:=FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'dbhtra',r_hd.nv);
if b_dbhTra='K' then
    if b_kieu_do='V' then
        select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
            from bh_hd_do_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt) and pthuc='C'
            group by nha_bh,lh_nv;
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_tu
                where ma_dvi=b_ma_dvi and so_id_hs=b_so_id and nbh=a_nbhX(b_lp);
            a_tienX(b_lp):=a_tienX(b_lp)-b_i1; a_tien_qdX(b_lp):=a_tien_qdX(b_lp)-b_i2;
            PBH_BH_HS_NBH_TH(b_ma_dvi,b_so_id,'T',b_ngay_qd,a_nbhX(b_lp),b_ma_nt,-a_tienX(b_lp),-a_tien_qdX(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end loop;
    end if;
    select nha_bh,lh_nv,max(pt) BULK COLLECT into a_dt_nbh,a_dt_lh_nv,a_dt_pt
        from tbh_tmN_tl where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd and so_id_dt in(0,b_so_id_dt)
        group by so_id_dt,nha_bh,lh_nv;
    if a_dt_nbh.count>0 then
        PKH_MANG_XOA(a_nbhX); PKH_MANG_XOA_N(a_tienX); PKH_MANG_XOA_N(a_tien_qdX);
        for r_lp in (select lh_nv,tien+thue tien,tien_qd+thue_qd tien_qd
            from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
            for b_lp in 1..a_dt_nbh.count loop
                if a_dt_lh_nv(b_lp) in(' ',r_lp.lh_nv) then
                    b_tienC:=round(b_tien*a_dt_pt(b_lp)/100,b_tp);
                    b_tien_qdC:=round(b_tien_qd*a_dt_pt(b_lp)/100,0);
                    b_i1:=0;
                    for b_lp1 in 1..a_nbhX.count loop
                        if a_nbhX(b_lp1)=a_dt_nbh(b_lp) then b_i1:=b_lp1; exit; end if;
                    end loop;
                    if b_i1=0 then
                        b_i1:=a_nbhX.count+1;
                        a_nbhX(b_i1):=a_dt_nbh(b_lp);
                        a_tienX(b_i1):=b_tienC; a_tien_qdX(b_i1):=b_tien_qdC;
                    else
                        a_tienX(b_i1):=a_tienX(b_i1)+b_tienC; a_tien_qdX(b_i1):=a_tien_qdX(b_i1)+b_tien_qdC;
                    end if;
                end if;
            end loop;
        end loop;
        for b_lp in 1..a_nbhX.count loop
            select nvl(sum(tien),0),nvl(sum(tien_qd),0) into b_i1,b_i2 from bh_bt_tu
                where ma_dvi=b_ma_dvi and so_id_hs=b_so_id and nbh=a_nbhX(b_lp);
            a_tienX(b_lp):=a_tienX(b_lp)-b_i1; a_tien_qdX(b_lp):=a_tien_qdX(b_lp)-b_i2;
            PBH_BH_HS_NBH_TH(b_ma_dvi,b_so_id,'T',b_ngay_qd,a_nbhX(b_lp),b_ma_nt,-a_tienX(b_lp),-a_tien_qdX(b_lp),b_loi);
            if b_loi is not null then return; end if;
        end loop;
    end if;
end if;
delete bh_bt_tba_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hk_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BT_DU_NV(r_hd.nv,b_ma_dvi,b_so_id,'','','T',30000101,b_loi);
if b_loi is not null then return; end if;
PBH_BT_DUPH_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_BT_HS_PBO(b_ma_dvi_ql,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOL_BTx(b_ma_dvi_ql,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_UP_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_HS_KTRA(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du boi thuong
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hs_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='Sai so du boi thuong ngay '||PKH_SO_CNG(b_i1)||':loi'; return; end if;
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hk_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='Sai so du nguoi huong khac ngay '||PKH_SO_CNG(b_i1)||':loi'; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_HS_KTRA:loi'; end if;
end;
/
--duchq update length email
create or replace procedure PBH_BT_HS_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:=''; b_tu number; b_den number;
    b_nv varchar2(10); b_ma_kh varchar2(20); b_so_hs varchar2(30);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_phong varchar2(10);
begin
-- Dan - Tim ho so boi thuong qua CMT, mobi, email
delete bh_bt_hs_tim_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,cmt,mobi,email,tu,den,so_hs');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_tu,b_den,b_so_hs using b_oraIn;
if b_ngayD in (0,30000101) or b_ngayD<b_ngay then b_ngayD:=b_ngay; end if; 
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_nv:=nvl(trim(b_nv),'*'); b_so_hs:=nvl(trim(b_so_hs),' ');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select count(*) into b_dong from bh_bt_hs where ma_kh=b_ma_kh and b_so_hs in (' ',so_hs) 
    and ngay_ht between b_ngayD and b_ngayC and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        insert into bh_bt_hs_tim_temp select ngay_ht,nv,so_hs,ttrang,so_hd,ten,ma_dvi,so_id,ma_kh from
            (select ngay_ht,nv,so_hs,ttrang,so_hd,ten,ma_dvi,so_id,ma_kh,rownum sott from bh_bt_hs where
            ma_kh=b_ma_kh and b_so_hs in (' ',so_hs)  and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_nv in('*',nv) order by ngay_ht desc,nv,so_hs)
            where sott between b_tu and b_den;
    end if;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_bt_hs where ma_dvi=b_ma_dvi and b_so_hs in (' ',so_hs) and ngay_ht between b_ngayD and b_ngayC and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        insert into bh_bt_hs_tim_temp select ngay_ht,nv,so_hs,ttrang,so_hd,ten,ma_dvi,so_id,ma_kh from
            (select ngay_ht,nv,so_hs,ttrang,so_hd,ten,ma_dvi,so_id,ma_kh,rownum sott from bh_bt_hs where
            ma_dvi=b_ma_dvi and b_so_hs in (' ',so_hs)  and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and b_nv in('*',nv) order by ngay_ht desc,nv,so_hs)
            where sott between b_tu and b_den;
    end if;
end if;
select JSON_ARRAYAGG(json_object(*) order by ngay_ht desc,nv,so_hs returning clob) into cs_lke from bh_bt_hs_tim_temp;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_bt_hs_tim_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HS_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma_dvi_ql varchar2(10); b_so_hs varchar2(30); dt_ct clob;
begin
-- Nam - Hoi SO ID qua so ho so
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi_ql,b_so_hs using b_oraIn;
b_oraOut:=''; b_so_hs:=trim(b_so_hs);
if b_so_hs is not null then
    if trim(b_ma_dvi_ql) is null then b_ma_dvi_ql:=b_ma_dvi; end if;
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi_ql and so_hs=b_so_hs;
    if b_i1<>0 then
        select json_object(so_hs,ten,'ma_nt' value nt_tien,'ma_kh' value ma_kh,'ttrang' value ttrang) into dt_ct
            from bh_bt_hs where ma_dvi=b_ma_dvi_ql and so_hs=b_so_hs;
    end if;
end if;
select json_object('dt_ct' value dt_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_GOC_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_ngay_ht number,b_ttrang varchar2,
    b_ma_dvi_ql varchar2,b_so_hd varchar2,b_so_id_hd out number,b_so_id_dt out number,b_so_id_bs out number,
    b_ngay_xr number,b_ngay_qd number,b_nt_tien out varchar2,b_noP varchar2,
    b_bphi varchar2,b_dung varchar2,b_traN varchar2,
    b_ma_khH in out varchar2,b_tenH in out nvarchar2,b_ma_kh varchar2,b_ten nvarchar2,
    
    a_so_id_dt pht_type.a_num,a_ma_dt pht_type.a_var,a_ma_nt pht_type.a_var,
    a_lh_nv pht_type.a_var,a_tien_bh pht_type.a_num,a_pt_bt pht_type.a_num,a_t_that pht_type.a_num,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,a_thue pht_type.a_num,a_thue_qd pht_type.a_num,
    hk_ma pht_type.a_var,hk_ma_nt pht_type.a_var,hk_tien pht_type.a_num,hk_tien_qd pht_type.a_num,
    xl_ma_nt out pht_type.a_var,xl_tien out pht_type.a_num,xl_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kieu_hd varchar2(1);
    b_kieu_do varchar2(1); b_tl_do number; b_tp number:=0;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_so_id_hd:=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi_ql,b_so_hd);
if b_so_id_hd=0 then b_loi:='loi:Ho so da xoa:loi'; return; end if;
if FBH_HD_HU(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr)='C' then
    b_loi:='loi:Ho dong cham dut tai thoi diem xay ra:loi'; return;
end if;
if b_ttrang is null or b_ttrang not in('S','T','D','H','C') then
    b_loi:='loi:Sai tinh trang ho so:loi'; return;
end if;
if trim(b_ma_khH) is null then b_ma_khH:=b_ma_kh; end if;
if trim(b_tenH) is null then b_tenH:=b_ten; end if;
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi_ql,b_so_id_hd);
--nampb: lay nt_tien
b_nt_tien:=FBH_HD_MA_NT_TIEN(b_ma_dvi_ql,b_so_id_bs,b_ngay_xr);
if b_nt_tien<>'VND' then b_tp:=2; end if;
xl_ma_nt(1):=b_nt_tien; xl_tien(1):=0; xl_tien_qd(1):=0;
if FBH_DONG(b_ma_dvi_ql,b_so_id_hd)='V' then
    for b_lp in 1..a_lh_nv.count loop
        b_tl_do:=FBH_DONG_TL_DT(b_ma_dvi_ql,b_so_id_hd,a_so_id_dt(b_lp),a_lh_nv(b_lp));
        if b_tl_do<>0 then
            xl_tien(1):=xl_tien(1)+round((a_tien(b_lp)+a_thue(b_lp))*b_tl_do/100,b_tp);
            xl_tien_qd(1):=xl_tien_qd(1)+round((a_tien_qd(b_lp)+a_thue_qd(b_lp))*b_tl_do/100,0);
        end if;
    end loop;
end if;
if FBH_HD_DO_NH_NHOM(b_ma_dvi_ql,b_so_id_hd,'T')='C' then
    for b_lp in 1..a_lh_nv.count loop
        b_tl_do:=FTBH_TMN_TL_DT(b_ma_dvi_ql,b_so_id_hd,a_so_id_dt(b_lp),a_lh_nv(b_lp));
        if b_tl_do<>0 then
            xl_tien(1):=xl_tien(1)+round((a_tien(b_lp)+a_thue(b_lp))*b_tl_do/100,b_tp);
            xl_tien_qd(1):=xl_tien_qd(1)+round((a_tien_qd(b_lp)+a_thue_qd(b_lp))*b_tl_do/100,0);
        end if;
    end loop;
end if;
if xl_tien(1)=0 then
    for b_lp in 1..a_lh_nv.count loop
        xl_tien(1):=xl_tien(1)+a_tien(b_lp)+a_thue(b_lp);
        xl_tien_qd(1):=xl_tien_qd(1)+a_tien_qd(b_lp)+a_thue_qd(b_lp);
    end loop;
end if;
for b_lp in 1..hk_ma.count loop
    xl_tien(1):=xl_tien(1)-hk_tien(b_lp);
    xl_tien_qd(1):=xl_tien_qd(1)-hk_tien_qd(b_lp);
end loop;
if xl_tien(1)<0 then b_loi:='loi:Doi tuong huong khac nhieu hon so duyet:loi'; return; end if;
for r_lp in (select ma_nt,sum(tien) tien from bh_bt_thoi where
    ma_dvi=b_ma_dvi and so_id_hs=b_so_id and ngay_ht<b_ngay_qd and kh_thu='C' group by ma_nt) loop
    if r_lp.ma_nt=xl_ma_nt(1) then
        b_i1:=r_lp.tien;
    else
        b_i1:=FBH_TT_TUNG_QD(b_ngay_qd,r_lp.ma_nt,r_lp.tien,xl_ma_nt(1));
    end if;
    xl_tien(1):=xl_tien(1)-b_i1; xl_tien_qd(1):=xl_tien_qd(1)-FBH_TT_VND_QD(b_ngay_xr,xl_ma_nt(1),b_i1);
end loop;
b_i1:=0;
for b_lp in 1..a_lh_nv.count loop
    b_i1:=b_i1+a_tien(b_lp);
end loop;
if b_i1>0 and b_ttrang='D' and FBH_HD_KIEU_HD(b_ma_dvi_ql,b_so_id_hd)<>'K' then
    b_i2:=FBH_HD_SO_ID_BAO(b_ma_dvi_ql,b_so_id_hd);
    select nvl(min(ngay_ht),0) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi_ql and so_id=b_i2;
    if b_i1=0 or b_i1>b_ngay_xr or FBH_HD_TT_TON_ID(b_ma_dvi_ql,b_i2,b_ngay_qd)='C' then
        if b_noP='K' then b_loi:='loi:Hop dong con no phi:loi'; return; end if;
        if FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'BT_NOP','C','B')<>'C' then
            b_loi:='loi:Khong duoc phan quyen cho no phi:loi'; return;
        end if;
    end if;
end if;
b_so_id_dt:=a_so_id_dt(1);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GOC_TEST:loi'; end if;
end;
/
create or replace procedure PBH_BT_GOC_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_ngay_ht number,b_nv varchar2,b_so_hs in out varchar2,b_ttrang varchar2,
    b_kieu_hs varchar2,b_so_hs_g varchar2,b_ma_dvi_ql varchar2,
    b_so_id_hd number,b_so_id_dt number,b_so_id_bs number,
    b_so_hd varchar2,b_ma_khH varchar2,b_tenH nvarchar2,b_ma_kh varchar2,b_ten nvarchar2,
    b_ngay_gui number,b_ngay_xr number,b_ngay_do number,b_n_trinh varchar2,
    b_n_duyet varchar2,b_ngay_qd number,b_nt_tien varchar2,
    b_noP varchar2,b_bphi varchar2,b_dung varchar2,b_traN varchar2,b_bangG varchar2,
    a_so_id_dt pht_type.a_num,a_ma_dt pht_type.a_var,a_ma_nt pht_type.a_var,a_lh_nv pht_type.a_var,
    a_tien_bh pht_type.a_num,a_pt_bt pht_type.a_num,a_t_that pht_type.a_num,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,a_thue pht_type.a_num,a_thue_qd pht_type.a_num,
    hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_thue pht_type.a_num,hk_tien_qd pht_type.a_num,hk_thue_qd pht_type.a_num,
    tba_ten pht_type.a_nvar,tba_ma_nt pht_type.a_var,tba_tien pht_type.a_num,
    xl_ma_nt pht_type.a_var,xl_tien pht_type.a_num,xl_tien_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_so_id_kt number:=-1; b_phong varchar2(10); b_skien varchar2(20);
    b_phongG varchar2(10); b_dvi_ksoat varchar2(10):=''; b_ksoat varchar2(10):='';
    a_so_id_dt_pt pht_type.a_num; a_lh_nv_pt pht_type.a_var; a_tien_pt pht_type.a_num;
    a_tien_qd_pt pht_type.a_num; a_thue_pt pht_type.a_num; a_thue_qd_pt pht_type.a_num;
begin
-- Dan - Nhap boi thuong
b_loi:='loi:Loi xu ly BT_GOC_NH_NH:loi';
if b_ttrang='D' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_qd,'BH','BT');
    if b_loi is not null then return; end if;
    b_so_id_kt:=0; b_dvi_ksoat:=b_ma_dvi; b_ksoat:=b_nsd;
end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_skien:=nvl(FBH_BT_TXT_NV(b_ma_dvi,b_so_id,'skien',b_nv),' ');
b_loi:='loi:Loi Table BH_BT_HS:loi';
insert into bh_bt_hs values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_ttrang,
    b_kieu_hs,b_so_hs_g,b_ma_dvi_ql,b_ma_dvi,b_so_id_hd,b_so_id_dt,b_so_hd,
    ' ',0,b_ma_khH,b_tenH,b_ma_kh,b_ten,
    b_phong,b_skien,b_ngay_gui,b_ngay_xr,b_ngay_do,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,
    b_noP,b_bphi,b_dung,b_traN,b_nsd,b_so_id_kt,b_dvi_ksoat,b_ksoat,b_bangG,sysdate);
b_loi:='loi:Loi Table BH_BT_HS_NV:loi';
for b_lp in 1..a_lh_nv.count loop
    insert into bh_bt_hs_nv values(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dt(b_lp),
        a_ma_nt(b_lp),a_lh_nv(b_lp),a_tien_bh(b_lp),a_pt_bt(b_lp),a_t_that(b_lp),
        a_tien(b_lp),a_thue(b_lp),a_tien(b_lp)+a_thue(b_lp),a_tien_qd(b_lp),a_thue_qd(b_lp),a_tien_qd(b_lp)+a_thue_qd(b_lp));
end loop;
b_loi:='loi:Loi Table BH_BT_HS_PS:loi';
for b_lp in 1..xl_ma_nt.count loop
    insert into bh_bt_hs_ps values(b_ma_dvi,b_so_id,xl_ma_nt(b_lp),xl_tien(b_lp),xl_tien_qd(b_lp));
end loop;
if hk_ma_nt.count<>0 then
    b_loi:='loi:Loi Table BH_BT_HK_PS:loi';
    for b_lp in 1..hk_ma_nt.count loop
        insert into bh_bt_hk_ps values(b_ma_dvi,b_so_id,b_lp,hk_ma(b_lp),hk_ten(b_lp),hk_ma_nt(b_lp),
            hk_tien(b_lp),hk_thue(b_lp),hk_tien(b_lp)+hk_thue(b_lp),
            hk_tien_qd(b_lp),hk_thue_qd(b_lp),hk_tien_qd(b_lp)+hk_thue_qd(b_lp));
    end loop;
end if;
if tba_ma_nt.count<>0 then
    b_loi:='loi:Loi Table BH_BT_TBA_PS:loi';
    for b_lp in 1..tba_ma_nt.count loop
        insert into bh_bt_tba_ps values(b_ma_dvi,b_so_id,b_lp,tba_ten(b_lp),tba_ma_nt(b_lp),tba_tien(b_lp));
    end loop;
    if b_ttrang='D' then
        for b_lp in 1..tba_ma_nt.count loop
            PBH_BT_HS_PT(b_ma_dvi,b_so_id,b_ngay_ht,tba_ma_nt(b_lp),tba_tien(b_lp),tba_tien(b_lp),0,0,
                a_so_id_dt_pt,a_lh_nv_pt,a_tien_pt,a_tien_qd_pt,a_thue_pt,a_thue_qd_pt,b_loi);
            if b_loi is not null then return; end if;
            for b_lp1 in 1..a_lh_nv_pt.count loop
                if a_lh_nv_pt(b_lp1)<>' ' then
                    insert into bh_bt_tba_ps_pt values(
                        b_ma_dvi,b_so_id,tba_ten(b_lp),tba_ma_nt(b_lp),a_lh_nv_pt(b_lp1),a_tien_pt(b_lp1));
                end if;
            end loop;
        end loop;
    end if;
end if;
if b_ttrang='T' then
    update bh_bt_hs_dp set ttrang=' ' where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_ttrang='D' then
    update bh_bt_hs_dp set ttrang='D' where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PBH_BT_HS_UP_NH(b_ma_dvi,b_so_id,b_ma_dvi,b_nsd,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GOC_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_GOC_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS 
    b_i1 number; r_hs bh_bt_hs%rowtype;
Begin
-- Dan - Xoa boi thuong
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if; 
  -- duong kiem tra khong cho sua,xoa so bt da duyet theo cau hinh tham so
  -- da them ngay 21/08/2025, bi xoa vao ngay 28/09/2025
  b_loi:= FBH_BT_KTRA_NHAP(b_ma_dvi,b_so_id);
  if trim(b_loi) is not null then return; end if;
  --end duong
  b_loi:='loi:Ho so dang xu ly:loi';
  select * into r_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then b_loi:='loi:Ho so dang xu ly:loi'; return; end if;
if nvl(trim(r_hs.ksoat),' ') not in(' ',b_nsd) then b_loi:='loi:Khong sua, xoa chung tu da kiem soat:loi'; return; end if;
if nvl(trim(r_hs.nsd),' ') not in(' ',b_nsd) then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if r_hs.ttrang='D' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_hs.ngay_qd,'BH','BT');
    if b_loi is not null then return; end if;
    if r_hs.traN='C' then b_loi:='loi:Ho so da thanh toan:loi'; return; end if;
    if r_hs.dung='C' then
        PBH_BT_HU_XOA(r_hs.ma_dvi_ql,r_hs.so_id_hd,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PBH_BT_HS_UP_XOA(b_ma_dvi,b_so_id,b_ma_dvi,b_nsd,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_nh=false then
    select count(*) into b_i1 from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da thanh toan:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da co phuong an boi thuong:loi'; return; end if; -- viet anh -- sua msg
    select count(*) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da tam ung:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_gd_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so co ho so giam dinh:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_hk_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da tam ung nguoi huong khac:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da thanh toan huong khac:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_bt=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da doi nguoi thu ba:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_thoi where ma_dvi=b_ma_dvi and so_id_hs=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da co thu hoi:loi'; return; end if;
    -- viet anh - chan xoa PABT
    select count(*) into b_i1 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id_pa=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa phuong an da thanh toan huong khac:loi'; return; end if;
    select count(*) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_pa=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa phuong an da tam ung:loi'; return; end if;
    --
    --nam: khong xoa ho so da tao du phong
    select count(*) into b_i1 from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_loi:='loi:Khong xoa ho so da du phong:loi'; return; end if;
    delete bh_bt_hs_tke where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
delete bh_bt_tba_ps_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_tba_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hk_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hs_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GOC_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_GOC_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_ngay_ht number,b_nv varchar2,b_so_hs in out varchar2,b_ttrang varchar2,
    b_kieu_hs varchar2,b_so_hs_g varchar2,b_ma_dvi_ql varchar2,b_so_hd varchar2,
    b_ma_kh varchar2,b_ten nvarchar2,b_ma_khH in out varchar2,b_tenH in out nvarchar2,
    b_ngay_gui number,b_ngay_xr number,b_ngay_do number,b_n_trinh varchar2,b_n_duyet varchar2,
    b_ngay_qd number,b_noP varchar2,b_bphi varchar2,b_dung varchar2,b_traN varchar2,b_bangG varchar2,

    a_so_id_dt pht_type.a_num,a_ma_dt pht_type.a_var,a_ma_nt pht_type.a_var,a_lh_nv pht_type.a_var,
    a_tien_bh pht_type.a_num,a_pt_bt pht_type.a_num,a_t_that pht_type.a_num,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,a_thue pht_type.a_num,a_thue_qd pht_type.a_num,
    hk_ma pht_type.a_var,hk_ten pht_type.a_nvar,hk_ma_nt pht_type.a_var,
    hk_tien pht_type.a_num,hk_tien_qd pht_type.a_num,hk_thue pht_type.a_num,hk_thue_qd pht_type.a_num,
    tba_ten pht_type.a_nvar,tba_ma_nt pht_type.a_var,tba_tien pht_type.a_num,
    b_loi out varchar2,b_duph varchar2:='K')
AS
    b_so_id_hd number; b_so_id_dt number; b_so_id_bs number; b_nt_tien varchar2(5);
    xl_ma_nt pht_type.a_var; xl_tien pht_type.a_num; xl_tien_qd pht_type.a_num;   
    a_muc_rr pht_type.a_var;
    r_hs bh_bt_hs%rowtype;
begin
b_loi:='loi:Loi tong hop boi thuong:loi';
PBH_BT_GOC_XOA(b_ma_dvi,b_nsd,b_so_id,true,b_loi);
if b_loi is not null then return; end if;
PBH_BT_GOC_TEST(    
    b_ma_dvi,b_nsd,b_so_id,b_ngay_ht,b_ttrang,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_dt,b_so_id_bs,
    b_ngay_xr,b_ngay_qd,b_nt_tien,b_noP,b_bphi,b_dung,b_traN,b_ma_khH,b_tenH,b_ma_kh,b_ten,
    a_so_id_dt,a_ma_dt,a_ma_nt,a_lh_nv,a_tien_bh,a_pt_bt,a_t_that,a_tien,a_tien_qd,a_thue,a_thue_qd,
    hk_ma,hk_ma_nt,hk_tien,hk_tien_qd,xl_ma_nt,xl_tien,xl_tien_qd,b_loi);
if b_loi is not null then return; end if;
PBH_BT_GOC_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_ttrang,
    b_kieu_hs,b_so_hs_g,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_so_id_bs,b_so_hd,b_ma_khH,b_tenH,b_ma_kh,b_ten,
    b_ngay_gui,b_ngay_xr,b_ngay_do,b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,
    b_noP,b_bphi,b_dung,b_traN,b_bangG,
    a_so_id_dt,a_ma_dt,a_ma_nt,a_lh_nv,a_tien_bh,a_pt_bt,a_t_that,a_tien,a_tien_qd,a_thue,a_thue_qd,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,
    xl_ma_nt,xl_tien,xl_tien_qd,b_loi);
if b_loi is not null then return; end if;
PBH_BT_HS_KTRA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_ttrang='D' and b_dung='C' then
    PBH_BT_HU_NH(b_ma_dvi_ql,b_so_id_hd,b_ngay_qd,b_loi);
    if b_loi is not null then return; end if;
elsif b_ttrang='T' and b_duph='C' then
    PBH_BT_DUPH_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_GOC_NH:loi'; end if;
end;
/
-- duong them fbh kiem tra chan khong cho sua ho so bt da duyet
create or replace function FBH_BT_KTRA_NHAP(b_ma_dvi VARCHAR2,b_so_id NUMBER)
RETURN varchar2
AS
    b_ngay_nh   DATE;
    b_tgian_tso NUMBER:= 0;
    b_tgian_nh number;
    b_i1 number;
    b_loi nvarchar2(1000):= '';b_ttrang varchar2(1);
BEGIN
    -- lay thoi gian cau hinh tso
    SELECT count(*) INTO b_i1  FROM bh_tso_ht_job WHERE ma = 'DUYETHS';
    if b_i1 <> 0 then
       SELECT tgian INTO b_tgian_tso  FROM bh_tso_ht_job WHERE ma = 'DUYETHS';
    end if;
    select count(*) into b_i1 from bh_bt_hs where so_id = b_so_id and ma_dvi = b_ma_dvi;
	if b_i1 <> 0 then
		select ngay_nh,ttrang into b_ngay_nh,b_ttrang from bh_bt_hs where so_id = b_so_id and ma_dvi = b_ma_dvi;
		b_tgian_nh:= round((sysdate - b_ngay_nh) * 24 * 60);
		b_loi:= '';
		if b_tgian_tso <= b_tgian_nh and b_ttrang='D' then
			b_loi:='loi:Khong sua, xoa ho so boi thuong da duyet:loi';
		end if;
	end if;
    return b_loi;
END;
/
