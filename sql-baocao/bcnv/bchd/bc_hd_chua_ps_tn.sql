CREATE OR REPLACE PROCEDURE BC_BH_THDT_PSTRN_CT
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_ma_nv varchar2,b_phong varchar2,b_loai varchar2,b_ma_kh varchar2,b_tien number,
    b_ngayd number,b_ngayc number,b_lkh varchar2,cs_kq out pht_type.cs_type,
    b_dvi out varchar2,b_tennv out varchar2,b_tenloai out varchar2,b_ten_phong out varchar2,
    b_ten_khach out varchar2)
AS
    b_loi varchar2(100);b_ngaydn number;b_i1 number;
    type rc is record (ma_dvi varchar2(10),so_hd varchar2(50),so_id number,ngay_hl varchar2(10),
        ngay_kt varchar2(10),ngay_cap varchar2(10));
    type ta is table of rc index by BINARY_INTEGER;
    b_ta ta;
Begin
--Bao cao doanh thu chua phat sinh trach nhiem chi tiet theo chuan
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
--b_loi:='loi:BCNam:loi';
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayc,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
if b_ma_dvi is not null then
    select ten into b_dvi from ht_ma_dvi where ma=b_ma_dvi;
else b_dvi:=' ';
end if;
if b_ma_nv is not null then
    select ten into b_tennv from bh_ma_lhnv where ma_dvi=b_madvi and ma=b_ma_nv;
else b_tennv:=' ';
end if;
if b_loai is not null then
    select ten into b_tenloai from kh_ma_loai_dn where ma_dvi=b_madvi and ma=b_loai;
else    b_tenloai:=' ';
end if;
if b_phong is not null then
    select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_madvi and ma=b_phong;
else b_ten_phong:=' ';
end if;
if b_ma_kh is not null then
    select ten into b_ten_khach from bh_hd_ma_kh where ma_dvi=b_madvi and ma=b_ma_kh;
else b_ten_khach:=' ';
end if;
delete ket_qua;
commit;
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
BC_BH_DTCPSTN_MDM(b_madvi,b_ma_dvi,b_ma_nv,b_phong,b_loai,b_ma_kh,'','','',0,b_ngayd,b_ngayc,b_loi);

--tong hop dong
select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua(c1,c2,c3,c4,n4,n5,n6)
        select c1,c2,c3,c4,sum(n4),sum(n5),sum(n4+n5) from temp_2 group by c1,c2,c3,c4;
else
    insert into ket_qua(c1,c2,c3,c4,n4,n5,n6)
        select c1,c2,c3,c4,sum(n4),sum(n5),sum(n4+n5) from temp_2,temp_bc_dvi where c1=dvi group by c1,c2,c3,c4;
end if;


/*
update ket_qua set (n30,c6,c7,c8)=(select so_id,to_char(ngay_hl,'dd/mm/yyyy'),to_char(ngay_kt,'dd/mm/yyyy'),PKH_SO_CNG(ngay_cap)
    from bh_hd_goc where ma_dvi=ket_qua.c1 and so_hd=ket_qua.c4 and rownum=1);
*/
--select distinct ma_dvi,so_hd,so_id,to_char(ngay_hl,'dd/mm/yyyy'),to_char(ngay_kt,'dd/mm/yyyy'),PKH_SO_CNG(ngay_cap) 
--    bulk collect into b_ta from bh_hd_goc 
--    where (ma_dvi,so_hd) in (select c1,c4 from ket_qua);
--forall i in 1..b_ta.count
--    update ket_qua set n30=b_ta(i).so_id,c6=b_ta(i).ngay_hl,c7=b_ta(i).ngay_kt,c8=b_ta(i).ngay_cap 
--        where c1=b_ta(i).ma_dvi and c4=b_ta(i).so_hd;


--update
--    (select ket_qua.n30 ket_qua_n30,ket_qua.c6 ket_qua_c6,ket_qua.c7 ket_qua_c7,ket_qua.c8 ket_qua_c8,
--        bh_hd_goc.so_id bh_hd_goc_so_id,bh_hd_goc.ngay_hl bh_hd_goc_ngay_hl,bh_hd_goc.ngay_kt bh_hd_goc_ngay_kt,bh_hd_goc.ngay_cap bh_hd_goc_ngay_cap
--              from ket_qua, bh_hd_goc
--             where ket_qua.c1 = bh_hd_goc.ma_dvi and ket_qua.c4 = bh_hd_goc.so_hd)
--       set ket_qua_n30 = bh_hd_goc_so_id,ket_qua_c6 = PKH_SO_CNG(bh_hd_goc_ngay_hl),
--        ket_qua_c7 = PKH_SO_CNG(bh_hd_goc_ngay_kt),ket_qua_c8 = PKH_SO_CNG(bh_hd_goc_ngay_cap);

update ket_qua set (n30,c6,c7,c8) = (select max(so_id),PKH_SO_CNG(max(ngay_hl)),PKH_SO_CNG(max(ngay_kt)),PKH_SO_CNG(max(ngay_cap)) from bh_hd_goc where ma_dvi=c1 and so_hd=c4);

delete ket_qua where nvl(n4,0)=0 and nvl(n5,0)=0;
update ket_qua set (n12)=(select max(ngay_ht) from bh_hd_goc_sc_phi where ma_dvi=ket_qua.c1 and so_id=ket_qua.n30 and no<>0 and ton<>0);
update ket_qua set n20=PKH_SO_CDT(b_ngayc)-PKH_SO_CDT(n12) where PKH_SO_CDT(n12) is not null;
--update ket_qua set c3 =(select ten from bh_hd_ma_kh where ma_dvi=ket_qua.c1 and ma=ket_qua.c2);
update
    (select ket_qua.c3 ket_qua_c3, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
        from ket_qua, bh_hd_ma_kh
        where ket_qua.c1 = bh_hd_ma_kh.ma_dvi and ket_qua.c2 = bh_hd_ma_kh.ma)
        set ket_qua_c3 = bh_hd_ma_kh_ten;

update ket_qua set c10 =(select ten from ht_ma_dvi where ma=ket_qua.c1);
update ket_qua set n29=(select max(so_id_kt) from bh_hd_goc_nb where ma_dvi=ket_qua.c1 and so_id=ket_qua.n30);
update ket_qua set c29=(select PKH_SO_CNG(ngay_ht) from bh_kt where ma_dvi=ket_qua.c1 and so_id=ket_qua.n29) where n29<>0;
update ket_qua set c29='Chua hach toan' where n29=0;
if b_lkh = 'K' then
    delete ket_qua where n30 in (select so_id from BCNAM_HD_GOC_NO_KH where ma_dvi=c1);
elsif b_lkh = 'R' then
    delete ket_qua where n30 not in (select so_id from BCNAM_HD_GOC_NO_KH where ma_dvi=c1);
end if;
commit;
open cs_kq for select n30 tc,c1 ma_dvi,c10 ten_dvi,c2 ma_kh,c3 ten_kh,c4 so_hd,c5 ten_hd,c6 ngay_hld,
    c7 ngay_hlc,c8 ngay_capdon,PKH_SO_CNG(n12) ngay_tt,n20 ngay_qhan,n4 dthu, n5 thue,n6 phi_bh,c29 ttrang
    from ket_qua order by c1,c2,c3,c4;
--exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BC_BH_THDT_PSTRN_CTM
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_ma_nv varchar2,b_phong varchar2,b_loai varchar2,b_ma_kh varchar2,b_tien number,
    b_ngayd number,b_ngayc number,b_lkh varchar2,cs_kq out pht_type.cs_type,
    b_dvi out varchar2,b_tennv out varchar2,b_tenloai out varchar2,b_ten_phong out varchar2,
    b_ten_khach out varchar2)
AS
    b_loi varchar2(100);b_ngaydn number;b_i1 number;
     type rc is record (ma_dvi varchar2(10),so_hd varchar2(50),so_id number,ngay_hl varchar2(10),
        ngay_kt varchar2(10),ngay_cap varchar2(10),cb_ql varchar(50));
    type ta is table of rc index by BINARY_INTEGER;
    b_ta ta;
Begin
--Bao cao doanh thu chua phat sinh trach nhiem chi tiet chia ky thanh toan

b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
--b_loi:='loi:BCNam:loi';
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayc,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
if b_ma_dvi is not null then
    select ten into b_dvi from ht_ma_dvi where ma=b_ma_dvi;
else b_dvi:=' ';
end if;
if b_ma_nv is not null then
    select ten into b_tennv from bh_ma_lhnv where ma_dvi=b_madvi and ma=b_ma_nv;
else b_tennv:=' ';
end if;
if b_loai is not null then
    select ten into b_tenloai from kh_ma_loai_dn where ma_dvi=b_madvi and ma=b_loai;
else    b_tenloai:=' ';
end if;
if b_phong is not null then
    select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_madvi and ma=b_phong;
else b_ten_phong:=' ';
end if;
if b_ma_kh is not null then
    select ten into b_ten_khach from bh_hd_ma_kh where ma_dvi=b_madvi and ma=b_ma_kh;
else b_ten_khach:=' ';
end if;
delete ket_qua;
commit;
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;

BC_BH_DTCPSTN_MDM(b_madvi,b_ma_dvi,b_ma_nv,b_phong,b_loai,b_ma_kh,'','','',0,b_ngayd,b_ngayc,b_loi);

--tong hop dong
select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua(c1,c2,c3,c4,n3,n4,n5,n6)
        select c1,c2,c3,c4,n3,sum(nvl(n4,0)),sum(nvl(n5,0)),sum(nvl(n4,0))+sum(nvl(n5,0)) from temp_2 group by c1,c2,c3,c4,n20,n3;
else
    insert into ket_qua(c1,c2,c3,c4,n3,n4,n5,n6)
        select c1,c2,c3,c4,n3,sum(nvl(n4,0)),sum(nvl(n5,0)),sum(nvl(n4,0))+sum(nvl(n5,0)) from temp_2,temp_bc_dvi where c1=dvi group by c1,c2,c3,c4,n20,n3;
end if;

/*
update ket_qua set (n30,c6,c7,c8)=(select so_id,to_char(ngay_hl,'dd/mm/yyyy'),to_char(ngay_kt,'dd/mm/yyyy'),PKH_SO_CNG(ngay_cap)
    from bh_hd_goc where ma_dvi=ket_qua.c1 and so_hd=ket_qua.c4);
*/
select distinct ma_dvi,so_hd,so_id,PKH_SO_CNG(ngay_hl),PKH_SO_CNG(ngay_kt),PKH_SO_CNG(ngay_cap),cb_ql
    bulk collect into b_ta from bh_hd_goc t,ket_qua t1
    where t.ma_dvi=t1.c1 and t.so_hd=t1.c4 and t.ngay_ht between b_ngayd and b_ngayc;
forall i in 1..b_ta.count
    update ket_qua set n30=b_ta(i).so_id,c6=b_ta(i).ngay_hl,c7=b_ta(i).ngay_kt,c8=b_ta(i).ngay_cap,c15=b_ta(i).cb_ql
        where c1=b_ta(i).ma_dvi and c4=b_ta(i).so_hd;
/*update
       (select ket_qua.n30 ket_qua_n30, ket_qua.c6 ket_qua_c6, ket_qua.c7 ket_qua_c7, ket_qua.c8 ket_qua_c8,
              bh_hd_goc.so_id bh_hd_goc_so_id, bh_hd_goc.ngay_hl bh_hd_goc_ngay_hl,
              bh_hd_goc.ngay_kt bh_hd_goc_ngay_kt, bh_hd_goc.ngay_cap bh_hd_goc_ngay_cap
              from ket_qua, bh_hd_goc
             where ket_qua.c29 = bh_hd_goc.ma_dvi and ket_qua.c6 = bh_hd_goc.so_hd)
       set ket_qua_n30 = bh_hd_goc_so_id, ket_qua_c6 = to_char(bh_hd_goc_ngay_hl,'dd/mm/yyyy'),
        ket_qua_c7 = to_char(bh_hd_goc_ngay_kt,'dd/mm/yyyy'), ket_qua_c8 = PKH_SO_CNG(bh_hd_goc_ngay_cap);
*/

--update ket_qua set (n12)=(select max(ngay_ht) from bh_hd_goc_sc_phi where ma_dvi=ket_qua.c1 and so_id=ket_qua.n30 and no<>0 and ton<>0);
update ket_qua set n20=PKH_SO_CDT(b_ngayc)-PKH_SO_CDT(n3) where PKH_SO_CDT(n3) is not null;
-- update ket_qua set c3 =(select ten from bh_hd_ma_kh where ma_dvi=ket_qua.c1 and ma=ket_qua.c2);

update
       (select ket_qua.c3 ket_qua_c3, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
              from ket_qua, bh_hd_ma_kh
             where ket_qua.c1 = bh_hd_ma_kh.ma_dvi and ket_qua.c2 = bh_hd_ma_kh.ma)
       set ket_qua_c3 = bh_hd_ma_kh_ten;


update ket_qua set c10 =(select ten from ht_ma_dvi where ma=ket_qua.c1);
delete ket_qua where nvl(n4,0)=0 and nvl(n5,0)=0;
update ket_qua set n29=(select max(so_id_kt) from bh_hd_goc_nb where ma_dvi=ket_qua.c1 and so_id=ket_qua.n30);
update ket_qua set c29=(select PKH_SO_CNG(ngay_ht) from bh_kt where ma_dvi=ket_qua.c1 and so_id=ket_qua.n29) where n29<>0;
update ket_qua set c29='Chua hach toan' where n29=0;
if b_lkh = 'K' then
    delete ket_qua where n30 in (select so_id from BCNAM_HD_GOC_NO_KH where ma_dvi=c1);
elsif b_lkh = 'R' then
    delete ket_qua where n30 not in (select so_id from BCNAM_HD_GOC_NO_KH where ma_dvi=c1);
end if;
delete ket_qua where n6=0 and n5=0;
--delete ket_qua where c4='01/2009/HD.1.3-TS.1.1/HCM-PHH-' and c1='001';
open cs_kq for select n30 tc,c1 ma_dvi,c10 ten_dvi,c2 ma_kh,c3 ten_kh,c4 so_hd,c5 ten_hd,c6 ngay_hld,
    c7 ngay_hlc,c8 ngay_capdon,PKH_SO_CNG(n3) ngay_tt,n20 ngay_qhan,n4 dthu, n5 thue,n6 phi_bh,c29 ttrang,c15 CB_QL
    from ket_qua order by c1,c2,c3,c4;
exception when others then raise_application_error(-20105,b_loi);
end;
/