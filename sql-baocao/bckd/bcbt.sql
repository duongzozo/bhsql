CREATE OR REPLACE PROCEDURE PBC_BH_NHANH_TT_BT
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(2000); b_loi varchar2(100); b_i1 number;
    b_ma_dvi varchar2(20); b_nv_bh varchar2(20); b_ma_nv varchar2(20); b_phong varchar2(20); b_loai_kh varchar2(20);
    b_ma_kh varchar2(20); b_ma_cb varchar2(20); b_nguon varchar2(20); b_ma_dt varchar2(20); b_ma_dl varchar2(20);
    b_hd varchar2(1); b_loai_bc varchar2(1); b_ngayd number; b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    dt_ct clob; dt_ds clob; 
Begin
delete temp_1; delete temp_2; delete bc_bh_bt_temp; delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,nv_bh,ma_nv,phong,loai_kh,ma_kh,ma_cb,nguon,ma_dt,ma_dl,hd,loai_bc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nv_bh,b_ma_nv,b_phong,b_loai_kh,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_ma_dl,b_hd,b_loai_bc,b_ngayd,b_ngayc using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngay_bc := UNISTR('T\1eeb ng\00e0y ') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y ') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
b_loi:='loi:Ma chua dang ky:loi';
PBC_LAY_NV(b_ma_dviN,b_ma_dvi,b_nsd,b_pas,b_phong);
select count(*) into b_i1 from temp_bc_nv where nv='BT';
if b_i1=0 then
    b_loi:='loi:Ban khong co quyen xem bao cao nay:loi'; raise PROGRAM_ERROR;
end if;
/*
-- Hung kiem tra trong gio hanh chinh
if extract(hour from cast(sysdate as timestamp))>7 and extract(hour from cast(sysdate as timestamp))<18 then
    if trim(b_ma_dvi) is null then
        raise_application_error(-20105,'loi:Chay dia ban. De nghi chay ngoai gio:loi');
    end if;
    if (PKH_SO_CDT(b_ngayc)-PKH_SO_CDT(b_ngayd)>366) then
        raise_application_error(-20105,'loi:Khoang ngay > 365 ngay. De nghi chay ngoai gio:loi');
    end if;
end if;
*/
delete temp_bc_ts;
PBC_BH_TS(b_ma_dviN,b_nsd,b_ma_dvi,b_ngayd,b_ngayc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBC_BH_TH_BT_PB_MD(b_loai_bc);
insert into bc_bh_bt_temp (nv,ma_dvi,lh_nv,phong,n1,n2,n3,so_id,ngay_ht,so_id_hd,ma_dvi_hd)
                      select  t.nv,t.ma_dvi,t.lh_nv,t.phong,sum(t.tien_qd),0,sum(t.tien_qd),t.so_id,t.ngay_ht,t.so_id_hd,t.ma_dvi_hd
                      from bc_bh_bt_hs_temp t, bh_hd_goc goc
                        where t.ngay_qd_n<30000101 and (b_phong is null or t.phong=b_phong)
                            and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                            and goc.ma_dvi=t.ma_dvi_hd and goc.so_id=t.so_id_hd 
                            and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                            and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                            and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                            and (b_ma_dl is null or goc.ma_kt = b_ma_dl)
                            group by t.nv,t.ma_dvi,t.lh_nv,t.phong,t.so_id,t.ngay_ht,t.so_id_hd,t.ma_dvi_hd;
delete temp_bc_ts;
PBC_BH_TS(b_ma_dviN,b_nsd,b_ma_dvi,20000101,b_ngayc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBC_BH_BT_CGQ_MD(b_loai_bc);
insert into bc_bh_bt_temp (nv,ma_dvi,lh_nv,phong,n1,n2,n3,so_id,ngay_ht,so_id_hd,ma_dvi_hd)
                      select t.c2,t.ma_dvi,t.lh_nv,t.c3,t.n5,t.n5,0,t.so_id,t.n2,t.n3,t.c4
                      from temp_bt_1 t, bh_hd_goc goc
                        where (b_phong is null or t.c3=b_phong) and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                        and goc.ma_dvi=t.c4 and goc.so_id=t.n3
                        and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                        and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                        and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                        and (b_ma_dl is null or goc.ma_kt = b_ma_dl);

----------------------------------------
update bc_bh_bt_temp t1 set (c2,c3,c18,c19,c20)=
        (select so_hd,ma_kh,cb_ql,goc.ma_kt,kieu_kt from bh_hd_goc goc where ma_dvi=t1.ma_dvi_hd and so_id=t1.so_id_hd and rownum=1);
--update bc_bh_bt_temp t1 set (c25)=(select loai from bh_hd_ma_kh where ma_dvi=t1.ma_dvi_hd and ma=t1.c3);
merge into bc_bh_bt_temp t1 using bh_hd_ma_kh a on (a.ma_dvi=t1.ma_dvi_hd and a.ma=t1.c3) when matched then update set c25=a.loai;
--update bc_bh_bt_temp t1 set n20=(select ngay_ht from bh_bt_hs where ma_dvi=t1.ma_dvi and so_id=t1.so_id);
merge into bc_bh_bt_temp t1 using bh_bt_hs a on (a.ma_dvi=t1.ma_dvi and a.so_id=t1.so_id) when matched then update set n20 = a.ngay_ht;

if b_hd='T' then
    delete bc_bh_bt_temp where n20 not between b_ngayd and b_ngayc;
end if;
if b_loai_kh is not null then
    delete bc_bh_bt_temp where c25<> b_loai_kh;
end if;
if b_ma_kh is not null then
    delete bc_bh_bt_temp where c3<> b_ma_kh;
end if;
if b_ma_cb is not null then
    delete bc_bh_bt_temp where c18<> b_ma_cb;
end if;
if b_ma_dl is not null then
    delete bc_bh_bt_temp where c19<> b_ma_dl and c20 not in('D','M');
end if;

update bc_bh_bt_temp t1 set (n21,c22,c23) =(select distinct nam_sx,gcn,case when bien_xe <> ' ' then bien_xe else so_khung end from bh_xe_ds a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id and rownum=1) where t1.nv='XE';

update bc_bh_bt_temp t1 set (c22,c23) =(select distinct ten,dvi from bh_ng_ds a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id and rownum=1) where t1.nv='NG';

-- update bc_bh_bt_temp t1 set (n22,n12) =(select sum(a.tien),sum(a.phi_dt)phi from bh_xegcn_dk a,bh_bt_hs_nv b
--     where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd and a.lh_nv=b.lh_nv
--     and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id) where t1.nv='XE';

update bc_bh_bt_temp t1 set (n22) =(select sum(a.tien) from bh_sk_dk a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd and a.lh_nv=b.lh_nv
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id) where t1.nv='SK';

update bc_bh_bt_temp t1 set n29=(select nvl(max(ngay_tt),30000101) from bh_hd_goc_ttpt where ma_dvi=t1.ma_dvi_hd and so_id=t1.so_id_hd and pt<>'C');

update bc_bh_bt_temp set n14=nvl(n1,0) where ngay_ht between b_ngayd and b_ngayc;
--update bc_bh_bt_temp t1 set c21 =(select ten from ht_ma_dvi where ma=t1.ma_dvi);
merge into bc_bh_bt_temp t1 using ht_ma_dvi a on (a.ma=t1.ma_dvi) when matched then update set c21=a.ten;
update bc_bh_bt_temp t1 set (c6,c7)=(select PKH_SO_CNG(max(ngay_xr)),max(so_hs) from bh_bt_hs where so_id=t1.so_id);
---------------------------------------------------------------------------------------------------------------------
insert into ket_qua(c1,c11,c20,n30) select ma,ten,tc,(case substr(ma,1,2) when 'XG' then 1 else (case substr(ma,1,2) when 'CN' then 2 else
        (case substr(ma,1,2) when 'HH' then 3 else (case substr(ma,1,2) when 'TT' then 4 else
        (case substr(ma,1,2) when 'TS' then 5 else (case substr(ma,1,2) when 'HP' then 6 else
        (case substr(ma,1,2) when 'TN' then 7 else 0 end)  end) end) end) end) end) end) from bh_ma_lhnv where ma_dvi=b_ma_dviN and tc='T';
update ket_qua kq
        set (n1,n2,n3,n14) =(select sum(nvl(n1,0)),sum(nvl(n2,0)),
    sum(nvl(n3,0)),sum(nvl(n14,0)) from bc_bh_bt_temp t where t.lh_nv like trim(kq.c1)||'%');

insert into ket_qua( c20,c10,c21,c1,c2,c3,c4,c5,c6,c7,n1,n2,n3,c22,c23,n22,n29,n14,n30,c30,n20, c29,n21,n12)
    select 'C',ma_dvi,c21,lh_nv,c2,c3,phong,c5,c6,c7,sum(nvl(n1,0)),sum(nvl(n2,0)),sum(nvl(n3,0)),c22,c23,sum(nvl(n22,0)),n29,sum(nvl(n14,0)),
    (case when substr(lh_nv,1,2)='XG' then 1 else (case when substr(lh_nv,1,2)='CN' then 2 else
    (case when substr(lh_nv,1,2)='HH' then 3 else (case when substr(lh_nv,1,2)='TT' then 4 else
    (case when substr(lh_nv,1,2)='TS' then 5 else (case when substr(lh_nv,1,2)='HP' then 6 else
    (case when substr(lh_nv,1,2)='TN' then 7 else 0 end)  end) end) end) end) end) end),ma_dvi_hd, so_id, nv,n21,sum(nvl(n12,0))
    from bc_bh_bt_temp group by ma_dvi,c21,lh_nv,c2,c3,phong,c5,c6,c7,c22,c23,n29,ma_dvi_hd,so_id, nv,n21;

delete bc_bh_bt_temp;
insert into bc_bh_bt_temp(c20,ma_dvi,c21,lh_nv,c2,c3,phong,c5,c6,c7,n1,n2,n3,c22,c23,n22,n29,n14,n30,ma_dvi_hd,so_id,nv,n21,n12)
    select c20,c10,c21,c1,c2,c3,c4,c5,c6,c7,n1,n2,n3,c22,c23,n22,n29,n14,n30,c30,n20, c29,n21,n12 from ket_qua;
--update bc_bh_bt_temp t1 set (c13,c5)=(select ten,loai from bh_hd_ma_kh where ma_dvi=t1.ma_dvi_hd and ma=t1.c3);
merge into bc_bh_bt_temp t1 using bh_hd_ma_kh a on (a.ma_dvi=t1.ma_dvi_hd and a.ma=t1.c3) when matched then update set c13=ten,c5=loai;
--update bc_bh_bt_temp t1 set c14=(select ten from ht_ma_phong where ma_dvi=t1.ma_dvi and ma=t1.phong);
merge into bc_bh_bt_temp t1 using ht_ma_phong a on (a.ma_dvi=t1.ma_dvi and a.ma=t1.phong)  when matched then update set c14 = ten;
--update bc_bh_bt_temp t1 set c15=(select ten from kh_ma_loai_dn where ma_dvi=t1.ma_dvi and ma=t1.c5);
merge into bc_bh_bt_temp t1 using kh_ma_loai_dn a on(a.ma_dvi=t1.ma_dvi and a.ma=t1.c5)  when matched then update set c15=ten;
--update bc_bh_bt_temp t1 set c11=(select ten from bh_ma_lhnv where ma_dvi=t1.ma_dvi and ma=t1.lh_nv);
merge into bc_bh_bt_temp t1 using bh_ma_lhnv a on (a.ma_dvi=t1.ma_dvi and a.ma=t1.lh_nv) when matched then update set c11=ten;
update bc_bh_bt_temp t1 set (n4,so_id_hd)=(Select max(so_id_hd),max(so_id_hd) from bh_bt_hs hs where hs.so_id=t1.so_id and hs.ma_dvi=t1.ma_dvi);
update bc_bh_bt_temp t1 set (so_id_dt)=(Select max(so_id_dt) from bh_bt_hs_nv hs where hs.so_id=t1.so_id and hs.ma_dvi=t1.ma_dvi);
--update bc_bh_bt_temp t1 set (c28, n19)=(Select max(substr(ddiem,1,200)), max(t_that) from bh_bt_hs_nv where lh_nv=t1.lh_nv and ma_dvi=t1.ma_dvi and so_id=t1.so_id);

update bc_bh_bt_temp t set (c24, c25, c26, c27, c17)=(select dchiC, PKH_SO_CNG(ngay_cap), PKH_SO_CNG(ngay_hl),PKH_SO_CNG(ngay_kt), loai_xe from bh_xe_ds where so_id=t.so_id_hd and so_id_dt=t.so_id_dt and rownum=1) where nv like 'XE';

update bc_bh_bt_temp t1 set n23=(Select nvl(sum(pt),0) from bh_hd_do_tl where pthuc='C' and so_id=t1.so_id_hd
        and ma_dvi=t1.ma_dvi and (lh_nv=t1.lh_nv or lh_nv='*'));
--update bc_bh_bt_temp t1 set c12=(Select max(nvl(kieu,'')) from bh_hd_do_tl where  pthuc='D' and so_id=t1.so_id_hd
        --and ma_dvi=t1.ma_dvi and (lh_nv=t1.lh_nv or lh_nv='*'));
update bc_bh_bt_temp t1 set n23=100 where n23 is null or n23=0;
update bc_bh_bt_temp t1 set n14 = n14*n23/100 where n23 <> 100;
update bc_bh_bt_temp t1 set n1 = n1*n23/100 where n23 <> 100 and c12 <> '';
update bc_bh_bt_temp t1 set n2 = n2*n23/100 where n23 <> 100;
update bc_bh_bt_temp t1 set n28=(select sum(round(pt/nvl(n23/100,1),4)) from tbh_pbo tbh where tbh.so_id=t1.so_id_hd and tbh.so_id_dt=t1.so_id_dt and tbh.lh_nv=t1.lh_nv
                            and tbh.pthuc in ('O','S','Q','F') and tbh.kieu='D' and ngay_ht<=b_ngayc);
update bc_bh_bt_temp t1 set n25=(select sum(round(pt/nvl(n23/100,1),4)) from tbh_pbo tbh where tbh.so_id=t1.so_id_hd and tbh.so_id_dt=t1.so_id_dt and tbh.lh_nv=t1.lh_nv
                            and tbh.pthuc in ('F') and tbh.kieu='D' and ngay_ht<=b_ngayc);
update bc_bh_bt_temp t1 set n26=round(n3*n28/100,0);
update bc_bh_bt_temp t1 set n27=round(n2*n28/100,0);

update bc_bh_bt_temp t1 set (n7,c8,c9,c10,c12)=(select ngay_ht,PKH_SO_CNG(ngay_gui),PKH_SO_CNG(ngay_qd),nsd,ksoat from bh_bt_hs where ma_dvi=t1.ma_dvi and so_id=t1.so_id);
--update bc_bh_bt_temp t1 set c16=(select substr(nd,1,200) from bh_kh_ttt_ct where ma_dvi=t1.ma_dvi and so_id=t1.so_id and ps='BT'
--    and ((nv like 'XE%' and ma='NGUYENNHAN') or (nv like 'NG%' and ma='004')));
select json_object('ngay_bc' value b_ngay_bc,'ngay_tao' value b_ngay_tao) into dt_ct from dual;
select JSON_ARRAYAGG(json_object(lh_nv,'ten_lh_nv' value FBH_MA_LHNV_TEN(lh_nv),'gcn' value c2,'ten_phong' value c14,'ten_kh' value c13,'bien_xe' value c23,
                                 'ngay_xr' value c6,'so_hs' value c7,'tien_uoc' value nvl(tien,0),'tien_utk' value  nvl(n14,0)) returning clob) into dt_ds from bc_bh_bt_temp order by n30,lh_nv;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; 
delete bc_bh_bt_temp; 
delete ket_qua;
commit;
exception when others then raise_application_error(-20105,b_loi);
end;

/
CREATE OR REPLACE PROCEDURE PBC_BH_NHANH_BT
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100);b_ngaydn number; b_n1 number; b_n2 number; b_i1 number;
    b_ma_dvi varchar2(10);b_ma_nv varchar2(10);b_phong varchar2(10);b_loai_kh varchar2(10);
    b_ma_kh varchar2(10);b_ma_cb varchar2(10);b_nguon varchar2(10); b_ma_dt varchar2(10);b_ma_dl varchar2(10);
    b_hd varchar2(20);b_tc varchar2(10);b_phong_nsd varchar2(10);b_tchon varchar2(1);b_ngayd number;b_ngayc number;
    b_ngay_bc varchar2(100);b_dvi varchar2(500);b_ten_pb varchar2(500);b_ten_nsd varchar2(500); b_ngay_tao varchar2(500);
    dt_ct clob;dt_ds clob;
Begin
-- BCNam: Bao cao nhanh tinh hinh  boi thuong
-- tinh chat la C de in cac ma bao cao theo nghiep vu, tinh chat K in cac bao cao gom theo phong, theo don vi,khach hang vv...
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,loai_kh,ma_kh,ma_cb,ma_gt,ma_dt,ma_dl,hd,loai_bc,ngayd,ngayc,tchon');
EXECUTE IMMEDIATE b_lenh 
into b_ma_dvi,b_ma_nv,b_phong,b_loai_kh,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_ma_dl,b_hd,b_tc,b_ngayd,b_ngayc,b_tchon using b_oraIn;
b_phong:= nvl(trim(b_phong),null); b_loai_kh:= nvl(trim(b_loai_kh),null); b_ma_kh:= nvl(trim(b_ma_kh),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
b_ma_nv:= nvl(trim(b_ma_nv),null); b_ma_dt:= nvl(trim(b_ma_dt),null); b_ma_dl:= nvl(trim(b_ma_dl),null);
b_nguon:= nvl(trim(b_nguon),null); b_hd:= nvl(trim(b_hd),null);b_tc:= nvl(trim(b_tc),null);
iF FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd)='TBH' then
    b_loi:='loi:Ban khong co quyen xem bao cao:loi';
    raise PROGRAM_ERROR;
end if;

if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayd,-4)+101;
b_loi:='loi:Ma chua dang ky:loi';
b_dvi := UNISTR(' - T\00ean chi nh\00e1nh: ') || FHT_MA_DVI_TENG(b_ma_dvi);
b_phong_nsd:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_ten_pb := FHT_MA_PHONG_TEN(b_ma_dvi,b_phong_nsd);
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
--delete bc_bh_bt_temp;delete ket_qua;commit;
EXECUTE IMMEDIATE 'TRUNCATE TABLE bc_bh_bt_temp';
EXECUTE IMMEDIATE 'TRUNCATE TABLE ket_qua';
commit;

PBC_LAY_NV(b_madvi,b_ma_dvi,b_nsd,b_pas,b_phong);
--select count(*) into b_i1 from temp_bc_nv where nv='BT';
--if b_i1=0 then
--    b_loi:='loi:Ban khong co quyen xem bao cao nay:loi'; raise PROGRAM_ERROR;
--end if;
delete temp_bc_ts;
if b_ma_dvi='00' then
    PBC_BH_TS(b_madvi,b_nsd,'',b_ngayd,b_ngayc,b_loi);
else
    PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,b_ngayd,b_ngayc,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBC_BH_TH_BT_PB_MD(b_tc);
insert into bc_bh_bt_temp (ma_dvi,lh_nv,phong,so_id_hd,n2,ma_dvi_hd,so_id)
                    select t.ma_dvi,t.lh_nv,t.phong,t.so_id_hd,t.tien_qd,t.ma_dvi_hd,t.so_id from bc_bh_bt_hs_temp t, bh_hd_goc goc
                    where t.ngay_qd_n<30000101 and (b_phong is null or t.phong=b_phong)
                    and goc.so_id=t.so_id_hd and goc.ma_dvi=t.ma_dvi_hd
                    and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                    and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                    and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                    and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                    and (b_ma_dl is null or goc.ma_kt = b_ma_dl);
PBC_BH_BT_CGQ_MD(b_tc);
insert into bc_bh_bt_temp (ma_dvi,lh_nv,phong,so_id_hd,n2,ma_dvi_hd,so_id) select t.ma_dvi,t.lh_nv,t.c3,t.n3,t.n5,t.c4,t.so_id from temp_bt_1 t, bh_hd_goc goc
                    where (b_phong is null or c3=b_phong) and (b_ma_nv is null or lh_nv like b_ma_nv ||'%')
                    and goc.so_id=t.n3 and goc.ma_dvi=t.c4
                    and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                    and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                    and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                    and (b_ma_dl is null or goc.ma_kt = b_ma_dl);
delete temp_bc_ts;
PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,b_ngaydn,b_ngayc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MM';
BC_BH_LAY_BC_BH_DTBH_MM(b_ma_dvi,b_ngayd,b_ngayc);
insert into bc_bh_bt_temp (ma_dvi,lh_nv,phong,so_id_hd,n1,ma_dvi_hd) select ma_dvi,lh_nv,phong,so_id,phi,ma_dvig
    from TEMP_BC_BH_DTBH_MM where (b_phong is null or phong=b_phong) and (b_ma_nv is null or lh_nv like b_ma_nv ||'%')
        and (trim(b_nguon) is null or trim(nguon) like b_nguon||'%')
        and (b_ma_kh is null or ma_kh = b_ma_kh)
        and (b_ma_cb is null or cb_ql = b_ma_cb)
        and (b_ma_dl is null or ma_kt = b_ma_dl);
PBC_BH_TH_BT_PB_MD(b_tc);
insert into bc_bh_bt_temp (ma_dvi,lh_nv,phong,so_id_hd,n3,ma_dvi_hd,so_id)
                    select t.ma_dvi,t.lh_nv,t.phong,t.so_id_hd,t.tien_qd,t.ma_dvi_hd,t.so_id from bc_bh_bt_hs_temp t, bh_hd_goc goc
                    where t.ngay_qd_n<30000101 and (b_phong is null or t.phong=b_phong)
                    and (b_ma_nv is null or lh_nv like b_ma_nv ||'%')
                    and goc.so_id=t.so_id_hd and goc.ma_dvi=t.ma_dvi_hd
                    and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                    and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                    and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                    and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                    and (b_ma_dl is null or goc.ma_kt = b_ma_dl);
delete temp_bc_ts;
PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,20000101,b_ngayc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBC_BH_BT_CGQ_MD(b_tc);
insert into bc_bh_bt_temp (ma_dvi,lh_nv,phong,so_id_hd,n5,ma_dvi_hd,so_id)  select t.ma_dvi,t.lh_nv,t.c3,t.n3,t.n5,t.c4,t.so_id from temp_bt_1 t, bh_hd_goc goc
                    where (b_phong is null or t.c3=b_phong) and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                    and goc.so_id=t.n3 and goc.ma_dvi=t.c4
                    and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                    and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                    and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                    and (b_ma_dl is null or goc.ma_kt = b_ma_dl);

update bc_bh_bt_temp set n1=nvl(n1,0),n2=nvl(n2,0),n3=nvl(n3,0),n4=nvl(n4,0),n5=nvl(n5,0);
update bc_bh_bt_temp set n6=n2+n4,n7=n3+n5;
update bc_bh_bt_temp t1 set n13=(Select sum(pt) from bh_hd_do_tl where  pthuc='C' and so_id=t1.so_id_hd
        and ma_dvi=t1.ma_dvi and (lh_nv=t1.lh_nv or lh_nv='*'));
update bc_bh_bt_temp t1 set n13=100 where n13 is null or n13=0;
update bc_bh_bt_temp t1 set n2 = n2*n13/100 where n13 <> 100;
update bc_bh_bt_temp t1 set n5 = n5*n13/100 where n13 <> 100;

--update bc_bh_bt_temp t1 set (c3,c1,c4,c5,c2)=(select ma_kh,ma_kt,kieu_kt,cb_ql,so_hd
--                                            from bh_hd_goc where ma_dvi=t1.ma_dvi_hd and so_id=t1.so_id_hd);
merge into bc_bh_bt_temp t1
using bh_hd_goc a
on (a.ma_dvi=t1.ma_dvi_hd and a.so_id=t1.so_id_hd)
when matched then update set
c3=a.ma_kh,c1=a.ma_kt,c4=a.kieu_kt,c5=a.cb_ql,c2=a.so_hd,c17=a.nsd,c18=a.ma_kt,c19=a.kieu_kt;

/*
update
       (select bc_bh_bt_temp.c3 bc_bh_bt_temp_c3, bc_bh_bt_temp.c1 bc_bh_bt_temp_c1,
        bc_bh_bt_temp.c4 bc_bh_bt_temp_c4, bc_bh_bt_temp.c5 bc_bh_bt_temp_c5, bc_bh_bt_temp.c2 bc_bh_bt_temp_c2,

       bh_hd_goc.ma_kh bh_hd_goc_ma_kh, bh_hd_goc.ma_kt bh_hd_goc_ma_kt, bh_hd_goc.kieu_kt bh_hd_goc_kieu_kt,
       bh_hd_goc.cb_ql bh_hd_goc_cb_ql, bh_hd_goc.so_hd bh_hd_goc_so_hd
              from bc_bh_bt_temp, bh_hd_goc
             where bh_hd_goc.ma_dvi = bc_bh_bt_temp.ma_dvi_hd and bh_hd_goc.so_id = bc_bh_bt_temp.so_id_hd)
       set bc_bh_bt_temp_c3 = bh_hd_goc_ma_kh, bc_bh_bt_temp_c1 = bh_hd_goc_ma_kt,
        bc_bh_bt_temp_c4 = bh_hd_goc_kieu_kt, bc_bh_bt_temp_c5 = bh_hd_goc_cb_ql, bc_bh_bt_temp_c2 = bh_hd_goc_so_hd;
*/

update bc_bh_bt_temp t1 set n20=(select ngay_ht from bh_bt_hs where ma_dvi=t1.ma_dvi and so_id=t1.so_id);

update bc_bh_bt_temp t1 set (c13,c6)=(select ten,loai from bh_hd_ma_kh where ma_dvi=t1.ma_dvi and ma=t1.c3);
--merge into bc_bh_bt_temp
--    using (select ma_dvi,ma,ten,loai from bh_hd_ma_kh
--        where (ma_dvi,ma) in (select ma_dvi,c3 from bc_bh_bt_temp)) a
--    on (a.ma_dvi=bc_bh_bt_temp.ma_dvi and a.ma=bc_bh_bt_temp.c3)
--    when MATCHED then
--    update set bc_bh_bt_temp.c13 = a.ten, bc_bh_bt_temp.c16 = a.loai;
--MERGE INTO bc_bh_bt_temp BC_BH_BT_TEMP1 
-- USING (SELECT ma_dvi, ma, ten,loai FROM bh_hd_ma_kh 
--         WHERE EXISTS (SELECT 'X'  FROM bc_bh_bt_temp BC_BH_BT_TEMP2 
--                        WHERE NVL(ma_dvi, ma_dvi) = BH_HD_MA_KH.ma_dvi AND NVL(c3, c3) = BH_HD_MA_KH.ma) 
--         ORDER BY BH_HD_MA_KH.MA_DVI) a 
--    ON (a.ma_dvi = BC_BH_BT_TEMP1.ma_dvi AND a.ma = BC_BH_BT_TEMP1.c3) 
--  WHEN MATCHED THEN UPDATE 
--   SET BC_BH_BT_TEMP1.c13 = a.ten,BC_BH_BT_TEMP1.c16 = a.loai;

update
    (select bc_bh_bt_temp.c13 bc_bh_bt_temp_c13, bc_bh_bt_temp.c6 bc_bh_bt_temp_c6,
        bh_hd_ma_kh.ten bh_hd_ma_kh_ten, bh_hd_ma_kh.loai bh_hd_ma_kh_loai
        from bc_bh_bt_temp, bh_hd_ma_kh
        where bh_hd_ma_kh.ma_dvi = bc_bh_bt_temp.ma_dvi and bh_hd_ma_kh.ma = bc_bh_bt_temp.c3)
        set bc_bh_bt_temp_c13 = bh_hd_ma_kh_ten, bc_bh_bt_temp_c6 = bh_hd_ma_kh_loai;


update bc_bh_bt_temp t1 set c14=(select ten from ht_ma_phong where ma_dvi=t1.ma_dvi and ma=t1.phong);

--update
--    (select bc_bh_bt_temp.c14 bc_bh_bt_temp_c14, ht_ma_phong.ten ht_ma_phong_ten
--     from bc_bh_bt_temp, ht_ma_phong
--     where bc_bh_bt_temp.ma_dvi = ht_ma_phong.ma_dvi and bc_bh_bt_temp.phong = ht_ma_phong.ma)
--     set  bc_bh_bt_temp_c14 = ht_ma_phong_ten;


update bc_bh_bt_temp t1 set c15=(select ten from kh_ma_loai_dn where ma_dvi=t1.ma_dvi and ma=t1.c6);
update bc_bh_bt_temp t1 set c30=(select ten from ht_ma_dvi where ma=t1.ma_dvi);


update bc_bh_bt_temp t1 set c11=(select ten from bh_ma_lhnv where ma=t1.lh_nv) where c20='C';
--update
--    (select bc_bh_bt_temp.c15 bc_bh_bt_temp_c15, kh_ma_loai_dn.ten kh_ma_loai_dn_ten
--    from kh_ma_loai_dn, bc_bh_bt_temp
--    where kh_ma_loai_dn.ma_dvi = bc_bh_bt_temp.ma_dvi and kh_ma_loai_dn.ma = bc_bh_bt_temp.c6)
--    set bc_bh_bt_temp_c15 = kh_ma_loai_dn_ten;

--update
--    (select bc_bh_bt_temp.c30 bc_bh_bt_temp_c30, ht_ma_dvi.ten ht_ma_dvi_ten
--    from ht_ma_dvi, bc_bh_bt_temp
--    where ht_ma_dvi.ma = bc_bh_bt_temp.c6)
--    set bc_bh_bt_temp_c30 = ht_ma_dvi_ten;


if  b_hd='T' then
    delete bc_bh_bt_temp where n20 not between b_ngayd and b_ngayc;
end if;
if b_loai_kh is not null then
    delete bc_bh_bt_temp where c6<> b_loai_kh;
end if;
if b_ma_kh is not null then
    delete bc_bh_bt_temp where c3<> b_ma_kh;
end if;
if b_ma_cb is not null then
    delete bc_bh_bt_temp where c5<> b_ma_cb;
end if;
if b_ma_dl is not null then
    delete bc_bh_bt_temp where c1<> b_ma_dl and c4 not in('D','M');
end if;
commit;

-----------------------------------------------------------------------------------------------------------------------
if b_tc='C' then
    insert into ket_qua(c1,c11,c20,n30) select ma,ten,tc,(case substr(ma,1,2) when 'XG' then 1 else
        (case substr(ma,1,2) when 'CN' then 2 else
        (case substr(ma,1,2) when 'HH' then 3 else (case substr(ma,1,2) when 'TT' then 4 else
        (case substr(ma,1,2) when 'TS' then 5 else (case substr(ma,1,2) when 'HP' then 6 else
        (case substr(ma,1,2) when 'TN' then 7 else 0 end)  end) end) end) end) end) end)
        from bh_ma_lhnv where ma_dvi=b_madvi and tc='T';

    update ket_qua kq set (n1,n2,n3,n4,n5,n6,n7,c2,c3,c13,c14,c6,c15,c30) =(select sum(nvl(n1,0)),sum(nvl(n2,0)),
        sum(nvl(n3,0)),sum(nvl(n4,0)),sum(nvl(n5,0)),sum(nvl(n6,0)),sum(nvl(n7,0)),c2,c3,c13,c14,c6,c15,c30
        from bc_bh_bt_temp t where t.lh_nv like trim(kq.c1)||'%' and rownum=1 group by c2,c3,c13,c14,c6,c15,c30);
end if;

    insert into ket_qua( c20,c29,c1,c2,c3,c4,c6,c11,c13,c14,c15,c30,n1,n2,n3,n4,n5,n6,n7,n12,n30,c17)
        select 'C',ma_dvi,lh_nv,c2,c3,phong,c6,c11,c13,c14,c15,c30,sum(nvl(n1,0)),sum(nvl(n2,0)),sum(nvl(n3,0)),sum(nvl(n4,0)),
        sum(nvl(n5,0)),sum(nvl(n6,0)),sum(nvl(n7,0)),sum(nvl(n12,0)),
        (case when substr(lh_nv,1,2)='XG' then 1 else (case when substr(lh_nv,1,2)='CN' then 2 else
        (case when substr(lh_nv,1,2)='HH' then 3 else (case when substr(lh_nv,1,2)='TT' then 4 else
        (case when substr(lh_nv,1,2)='TS' then 5 else (case when substr(lh_nv,1,2)='HP' then 6 else
        (case when substr(lh_nv,1,2)='TN' then 7 else 0 end)  end) end) end) end) end) end),
        c17
        from bc_bh_bt_temp group by ma_dvi,lh_nv,c2,c3,phong,c6,c11,c13,c14,c15,c30,c17;

-- Hung kiem tra so hang phai < 65000
--select count(*) into b_i1 from ket_qua;
--if b_i1>65000 then
--    b_loi:='loi:So dong bao cao > 65000, khong mo duoc Excel:loi'; raise PROGRAM_ERROR;
--end if;

--update ket_qua t1 set c11=(select /*+ INDEX_JOIN(BH_MA_LHNV) */ ten from bh_ma_lhnv where ma_dvi=t1.c29 and ma=t1.c1) where c20='C';
update
(
    select ket_qua.c11 ket_qua_t1,bh_ma_lhnv.ten bh_ma_lhnv_ten from ket_qua,bh_ma_lhnv
    where bh_ma_lhnv.ma_dvi=ket_qua.c29 and bh_ma_lhnv.ma=ket_qua.c1 and ket_qua.c20='C'
)
set ket_qua_t1=bh_ma_lhnv_ten;

--delete ket_qua where nvl(n1,0)=0 and nvl(n2,0)=0 and nvl(n3,0)=0 and nvl(n4,0)=0 and nvl(n5,0)=0 and nvl(n6,0)=0 and nvl(n7,0)=0;

commit;
-- bo sung c20, c21
--if (SUBSTR(b_ma_nv,1,2)='CN') then
--  UPDATE ket_qua SET c20=(SELECT truong from bh_nguoihd WHERE ma_dvi=c29 and so_hd=c2) WHERE c1 like 'CN.4%';
--  UPDATE ket_qua SET c21=(SELECT ngsach from bh_nguoihd WHERE ma_dvi=c29 and so_hd=c2) WHERE c1 like 'CN.8%';
--  commit;
--   open cs_kq for select c20 tc,c29 ma_dvi,c30 ten_dvi,c1 ma_nv,c11 ten_nv,c2 so_hd,c3 ma_kh, c13 ten_kh,c4 phong,c14 ten_phong,
--       c6 loai_kh,c15 ten_loai,nvl(n1,0) dtbh_lk,nvl(n2,0) tien_gq_tk,nvl(n4,0) tien_td_tk,nvl(n6,0) tien_tk,nvl(n3,0) tien_gq_lk,nvl(n5,0) tien_td_lk,
--       nvl(n7,0) tien_lk
--       ,case when c20 = '01' then 'Mau giao'
--             when c20 = '02' then 'Tieu hoc'
--             when c20 = '03' then 'THCS'
--             when c20 = '04' then 'PTTH'
--             when c20 = '05' then 'CD,DH'
--             end truong_hoc
--       ,c21 loai_ns
--       from ket_qua order by n30,c1;
-- else
--   open cs_kq for select c20 tc,c29 ma_dvi,c30 ten_dvi,c1 ma_nv,c11 ten_nv,c2 so_hd,c3 ma_kh, c13 ten_kh,c4 phong,c14 ten_phong,
--       c6 loai_kh,c15 ten_loai,nvl(n1,0) dtbh_lk,nvl(n2,0) tien_gq_tk,nvl(n4,0) tien_td_tk,nvl(n6,0) tien_tk,nvl(n3,0) tien_gq_lk,nvl(n5,0) tien_td_lk,
--       nvl(n7,0) tien_lk,c17 nsd,c18 ma_kt,c19 kieu_kt from ket_qua order by n30,c1;
-- end if;
delete temp_1; commit;
if(b_tchon = '1') then
    insert into temp_1 (c1,c11,n1,n2,n3)
    select c1,c11,Sum(t.n1),Sum(t.n2),Sum(t.n3)
        from (select c1, c11, nvl(n1,0) n1, nvl(n2,0) n2, nvl(n3,0) n3
            from ket_qua) t group by t.c1,t.c11;
    update temp_1 t set (c40, n40) = (select to_char(rn), rn
    from (select rowid rid, row_number() over (order by c1) rn from temp_1) x where x.rid = t.rowid);
    insert into temp_1 (c40,c1,c11,n1,n2,n3,n40) select UNISTR('T\1ed4NG'), '','',nvl(sum(n1),0),nvl(sum(n2),0),nvl(sum(n3),0), nvl(max(n40+1),0) from temp_1;
    update temp_1 set (c39) = ROUND(nvl(n3,0) / nullif(n1,0) * 100, 2) || '%' where nvl(n1,0)<>0;
    update temp_1 t set t.c11= (select b.ten from bh_ma_lhnv b where b.ma = t.c1);
else
    insert into temp_1 (c1,c11,n1,n2,n3,n6,n7,n8,n9)
    select c4,c14,Sum(t.n1),Sum(t.n2),Sum(t.n3),Sum(t.n6),Sum(t.n7),Sum(t.n6)-Sum(t.n2),Sum(t.n7)-Sum(t.n3)
        from (select c4, c14, nvl(n1,0) n1, nvl(n2,0) n2, nvl(n3,0) n3, nvl(n6,0) n6, nvl(n7,0) n7
            from ket_qua) t group by t.c4,t.c14;
    update temp_1 t set (c40, n40) = (select to_char(rn), rn
    from (select rowid rid, row_number() over (order by c1) rn from temp_1) x where x.rid = t.rowid);
    insert into temp_1 (c40,c1,c11,n1,n2,n3,n6,n7,n8,n9,n40) select UNISTR('T\1ed4NG'), '','',nvl(sum(n1),0),nvl(sum(n2),0),nvl(sum(n3),0),
    nvl(sum(n6),0), nvl(sum(n7),0), nvl(sum(n8),0), nvl(sum(n9),0), nvl(max(n40+1),0) from temp_1;
    update temp_1 set (c39) = ROUND(nvl(n3,0) / nullif(n1,0) * 100, 2) || '%' where nvl(n1,0)<>0;
end if;
select JSON_ARRAYAGG(json_object('STT' value c40,'MA' value c1,'TEN' value c11,'DT' value FBH_CSO_TIEN(nvl(n1,0),''), 'BT_TK' value FBH_CSO_TIEN(nvl(n2,0),''),
'UOC_TK' value FBH_CSO_TIEN(nvl(n6,0),''),'TC_TK' value FBH_CSO_TIEN(nvl(n8,0),''),'BT_LK' value FBH_CSO_TIEN(nvl(n3,0),''), 'UOC_LK' value FBH_CSO_TIEN(nvl(n9,0),''),
'TC_LK' value FBH_CSO_TIEN(nvl(n7,0),''), 'TL_BT' value c39) order by n40 returning clob) 
    into dt_ds from temp_1;
select json_object('TEN1' value b_dvi, 'TEN2' value b_ten_pb, 'TEN3' value b_ngay_bc, 'TEN4' value b_ngay_tao, 'TEN5' value b_ten_nsd)
    into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete ket_qua; commit;
exception when others then raise_application_error(-20105,b_loi);
end;

/
CREATE OR REPLACE PROCEDURE PBC_BH_BT_TD
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_phong varchar2,b_ma_nv varchar2,b_loai_kh varchar2,
    b_ma_kh varchar2,b_ma_cb varchar2,b_nguon varchar2, b_ma_dt varchar2,b_ma_dl varchar2,b_hd varchar2,b_tc varchar2,
    b_ngayd_lk number,b_ngayc_lk number,
    b_ngayd number,b_ngayc number,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(100);b_i1 number;b_vtri number:=0;b_ma_cb_hd varchar2(20);b_ma_cb_hs varchar2(20);
Begin
--Bao cao boi thuong chua giai quyet
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;

if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;

b_loi:='loi:Ma chua dang ky:loi';
if b_ma_cb is not null then
    b_vtri:=instr(trim(b_ma_cb),'/');
    if b_vtri >= 1 then
        b_ma_cb_hs:=substr(trim(b_ma_cb),b_vtri+1);
    end if;
    if b_vtri > 1 then
        b_ma_cb_hd:= substr(trim(b_ma_cb),1,b_vtri-1);
    elsif b_vtri = 0 then
        b_ma_cb_hd:= b_ma_cb;
    end if;
end if;

delete bc_bh_bt_temp;commit;
PBC_LAY_NV(b_madvi,b_ma_dvi,b_nsd,b_pas,b_phong);
select count(*) into b_i1 from temp_bc_nv where nv='BT';
if b_i1=0 then
    b_loi:='loi:Ban khong co quyen xem bao cao nay:loi'; raise PROGRAM_ERROR;
end if;
delete temp_bc_ts;
PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,20000101,b_ngayc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBC_BH_BT_CGQ_MD(b_tc);
insert into bc_bh_bt_temp(ma_dvi,so_id,nv,phong,lh_nv,ngay_qd_n,ma_dvi_hd,so_id_hd,so_id_dt,tien,tien_qd,ngay_ht,tc,c9)
select t.ma_dvi,t.so_id,t.c2,t.c3,t.lh_nv,t.n6,t.c4,t.n3,t.so_id_dt,sum(t.n4),sum(t.n5),t.n2,t.c1,t.c5
       from temp_bt_1 t, bh_hd_goc goc
            where (b_phong is null or t.c3=b_phong) and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                        and goc.ma_dvi=t.c4 and goc.so_id=t.n3
                        and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                        and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                        and (b_ma_cb_hd is null or goc.cb_ql = b_ma_cb_hd)
                        and (b_ma_cb_hs is null or t.c5 = b_ma_cb_hs)
                        and (b_ma_dl is null or goc.ma_kt = b_ma_dl)
                        and (b_ma_dvi is null or t.ma_dvi=b_ma_dvi)
    group by t.ma_dvi,t.so_id,t.c2,t.c3,t.lh_nv,t.n6,t.c4,t.n3,t.so_id_dt,t.n2,t.c1,t.c5;

update bc_bh_bt_temp t1 set (c4,c5,c18,c3,c6)=
                (select so_hd,ma_kh,cb_ql,ma_kt,kieu_kt from bh_hd_goc g where g.ma_dvi=t1.ma_dvi_hd and g.so_id=t1.so_id_hd and rownum=1);
--update bc_bh_bt_temp t1 set c8=(select loai from bh_hd_ma_kh where ma_dvi=t1.ma_dvi_hd and ma=t1.c1);
update
    (select bc_bh_bt_temp.c8 bc_bh_bt_temp_c8, bh_hd_ma_kh.loai bh_hd_ma_kh_loai
        from bc_bh_bt_temp, bh_hd_ma_kh
        where bc_bh_bt_temp.ma_dvi_hd = bh_hd_ma_kh.ma_dvi and bc_bh_bt_temp.c1 = bh_hd_ma_kh.ma)
    set bc_bh_bt_temp_c8 = bh_hd_ma_kh_loai;

update bc_bh_bt_temp t1 set (c2,c7,c19)=(select max(so_hs),PKH_SO_CNG(max(ngay_xr)),PKH_SO_CNG(max(ngay_gui)) from bh_bt_hs bt
                                    where bt.so_id=t1.so_id);
update bc_bh_bt_temp t1 set (c22,c23) =(select distinct gcn,bien_xe from bh_xe_ds a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id and rownum=1) where t1.nv='XE';
update bc_bh_bt_temp t1 set (c22,c23) =(select distinct gcn,bien_xe from bh_2b_ds a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id and rownum=1) where c30='2B';

BC_BH_THGD_MD_CD(b_madvi,b_ma_dvi,b_ma_nv,b_phong,b_loai_kh,b_ma_kh,b_ngayd,b_ngayc,b_loi,'B');
update bc_bh_bt_temp t1 set n7=(select sum(n7) from temp_1 where c29=t1.ma_dvi and n30=t1.so_id and c18=t1.lh_nv);
update bc_bh_bt_temp t1 set n7=(select sum(tien) from bh_bt_gd_hs hs where hs.ma_dvi=t1.ma_dvi and hs.so_id_bt=t1.so_id);
update bc_bh_bt_temp t1 set c28=(select ten from ht_ma_dvi where ma=t1.ma_dvi);
update bc_bh_bt_temp t1 set c26=(select ten from ht_ma_phong where ma_dvi=t1.ma_dvi and ma=t1.phong);
update bc_bh_bt_temp t1 set c21=(select ten from bh_ma_lhnv where ma_dvi=t1.ma_dvi and ma=t1.lh_nv);
--update bc_bh_bt_temp t1 set c25=(select ten from bh_hd_ma_kh where ma_dvi=t1.ma_dvi and ma=t1.c5);
update
    (select bc_bh_bt_temp.c25 bc_bh_bt_temp_c25, bh_hd_ma_kh.ten bh_hd_ma_kh_ten
        from bc_bh_bt_temp, bh_hd_ma_kh
        where bc_bh_bt_temp.ma_dvi = bh_hd_ma_kh.ma_dvi and bc_bh_bt_temp.c5 = bh_hd_ma_kh.ma)
    set bc_bh_bt_temp_c25 = bh_hd_ma_kh_ten;

update bc_bh_bt_temp t1 set n29=(select nvl(max(ngay_tt),30000101) from bh_hd_goc_ttpt where ma_dvi=t1.ma_dvi_hd and so_id=t1.so_id_hd and pt<>'C');
--BCNam bo sung
-- LAM SACH
-- update bc_bh_bt_temp t1 set n13=(Select nvl(sum(pt),0) from bh_hd_do_tl where kieu='V' and pthuc='C' and so_id=t1.so_id_hd and
--         ma_dvi=t1.ma_dvi and (lh_nv=t1.lh_nv or lh_nv='*'));
update bc_bh_bt_temp t1 set n13=100 where n13 is null or n13=0;
update bc_bh_bt_temp t1 set n28=PKH_SO_CDT(b_ngayc)-to_date(c19,'dd/mm/yyyy') where c19<>'01/01/3000';
update bc_bh_bt_temp t1 set (n20,c20)=(select ngay_ht,nsd from bh_bt_hs where ma_dvi=t1.ma_dvi and so_id=t1.so_id);
-- update bc_bh_bt_temp t1 set n30=(Select sum(a.tien) from bh_xegcn_dk a where a.lh_nv=t1.lh_nv and a.so_id=t1.so_id_hd and a.so_id_dt=t1.so_id_dt) where so_id_dt<>0;
-- update bc_bh_bt_temp t1 set n30=(Select sum(a.tien) from bh_xelgcn_dk a where a.lh_nv=t1.lh_nv and a.so_id=t1.so_id_hd) where so_id_dt=0;

if b_hd='T' then
    delete bc_bh_bt_temp where n20 not between b_ngayd and b_ngayc;
end if;

if b_loai_kh is not null then
    delete bc_bh_bt_temp where c8<> b_loai_kh;
end if;
if b_ma_kh is not null then
    delete bc_bh_bt_temp where c5<> b_ma_kh;
end if;
if b_ma_cb_hd is not null then
    delete bc_bh_bt_temp where c18<> b_ma_cb_hd;
end if;
if b_ma_dl is not null then
    delete bc_bh_bt_temp where c3<> b_ma_dl and c6 not in('D','M');
end if;

commit;
-------------------------------------------------------------------------
open cs_kq for select ma_dvi, c28 ten_dvi, phong, c26 ten_phong, c18 cb_ql,lh_nv, c21 ten_nv, c25 ten_kh, c4 so_gcn,
    decode(n29,30000101,'Chua nop phi',PKH_SO_CNG(n29)) ngay_tt, c2 so_hs,
    c7 ngay_xr, c19 ngay_gui, PKH_SO_CNG(ngay_ht) ngay_hs, nvl(n28,0) ngay_td,
    nvl(tien_qd,0) tien_u ,nvl(n7,0) tien_gdu,c22 gcn,c23 bien_xe,
    n30 tien_bh, n10 tyle_taicd, n11 tyle_taitt, n12 tyle_taiphityle,c20 nsd
    from bc_bh_bt_temp order by ma_dvi,phong,c18,lh_nv,c5;
--exception when others then raise_application_error(-20105,b_loi);
End;

/
CREATE OR REPLACE PROCEDURE PBC_BH_BT_GQ
     (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(2000); b_loi varchar2(100); b_i1 number; b_vtri number:=0;
    b_ma_dvi varchar2(20); b_ma_nv varchar2(20); b_phong varchar2(20); b_loai_kh varchar2(20);
    b_ma_kh varchar2(20); b_ma_cb varchar2(20); b_nguon varchar2(20); b_ma_dt varchar2(20); b_ma_dl varchar2(20); b_ts_ubt number;
    b_hd varchar2(1); b_tc varchar2(10); b_ngayd number; b_ngayc number; b_ngay_bc varchar2(100); b_ngay_tao varchar2(100);
    dt_ct clob; dt_ds clob; 
Begin
--Bao cao ho so boi thuong da giai quyet
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,loai_kh,ma_kh,ma_cb,ma_gt,ma_dt,ma_dl,hd,loai_bc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_ma_nv,b_phong,b_loai_kh,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_ma_dl,b_hd,b_tc,b_ngayd,b_ngayc using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),b_madvi);
b_loi:='loi:Ma chua dang ky:loi';
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
-- Hung kiem tra khoang ngay (khong qua 03 nam)
if PKH_SO_CDT(b_ngayc)-PKH_SO_CDT(b_ngayd)>2900 then
    b_loi:='loi:Ngay dau va ngay cuoi gioi han trong 03 nam:loi'; raise PROGRAM_ERROR;
end if;
b_ngay_bc := UNISTR('T\1eeb ng\00e0y ') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y ') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');

delete bc_bh_bt_temp; commit;
PBC_LAY_NV(b_madvi,b_ma_dvi,b_nsd,b_pas,b_phong);
select count(*) into b_i1 from temp_bc_nv where nv='BT';
if b_i1=0 then
    b_loi:='loi:Ban khong co quyen xem bao cao nay:loi'; raise PROGRAM_ERROR;
end if;
delete temp_bc_ts;
PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,b_ngayd,b_ngayc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBC_BH_TH_BT_PB_MD(b_tc);
insert into bc_bh_bt_temp(ma_dvi,so_id,nv,phong,lh_nv,ngay_qd_n,ma_dvi_hd,so_id_hd,so_id_dt,tien,tien_qd,ngay_ht,tc)
    select t.ma_dvi,t.so_id,t.nv,t.phong,t.lh_nv,t.ngay_qd_n,t.ma_dvi_hd,t.so_id_hd,t.so_id_dt,sum(t.tien),sum(t.tien_qd),
            t.ngay_ht,t.tc
            from bc_bh_bt_hs_temp t, bh_hd_goc goc
                    where t.ngay_qd_n<30000101 and (b_phong is null or t.phong=b_phong)
                            and goc.so_id=t.so_id_hd and goc.ma_dvi=t.ma_dvi_hd
                            and (b_ma_nv is null or t.lh_nv like b_ma_nv ||'%')
                            and (trim(b_nguon) is null or trim(goc.ma_gt) like b_nguon||'%')
                            and (b_ma_kh is null or goc.ma_kh = b_ma_kh)
                            and (b_ma_cb is null or goc.cb_ql = b_ma_cb)
                            and (b_ma_dl is null or goc.ma_kt = b_ma_dl)
                    group by t.ma_dvi,t.so_id,t.nv,t.phong,t.lh_nv,t.ngay_qd_n,t.ma_dvi_hd,t.so_id_hd,t.so_id_dt,t.ngay_ht,t.tc;

update bc_bh_bt_temp t1 set (c4,c5,c18,c3,c6)=
            (select so_hd,ma_kh,cb_ql,ma_kt,kieu_kt from bh_hd_goc where ma_dvi=t1.ma_dvi_hd and so_id=t1.so_id_hd and rownum=1);
update bc_bh_bt_temp t1 set c8=(select loai from bh_hd_ma_kh where ma_dvi=t1.ma_dvi_hd and ma=t1.c1);
update bc_bh_bt_temp t1 set (c2,c7,c19,c24)=(select max(so_hs),max(ngay_xr),max(ngay_gui),
                                            max(ngay_qd) from bh_bt_hs where so_id=t1.so_id);
update bc_bh_bt_temp t1 set c17=(select ten from kh_ma_loai_dn where ma_dvi=t1.ma_dvi and ma=t1.c8);
update bc_bh_bt_temp t1 set c20=(select ten from ht_ma_cb where ma_dvi=t1.ma_dvi_hd and ma=t1.c18);
update bc_bh_bt_temp t1 set n20=(select ngay_ht from bh_bt_hs where ma_dvi=t1.ma_dvi and so_id=t1.so_id);
update bc_bh_bt_temp t1 set (c22, c23, c10, c11, c12, c13) =(select distinct gcn,bien_xe,dchic,
    pkh_so_cng(ngay_cap),pkh_so_cng(ngay_hl),pkh_so_cng(ngay_kt) from bh_xe_ds a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id and rownum=1) where t1.nv='XE';

update bc_bh_bt_temp t1 set (c22, c23, c10, c11, c12, c13) =(select distinct gcn,bien_xe,dchic,
    pkh_so_cng(ngay_cap),pkh_so_cng(ngay_hl),pkh_so_cng(ngay_kt) from bh_2b_ds a,bh_bt_hs_nv b
    where a.ma_dvi=b.ma_dvi and a.so_id_dt=b.so_id_dt and a.ma_dvi=t1.ma_dvi_hd
    and a.so_id=FBH_HD_SO_ID_BS(t1.ma_dvi_hd,t1.so_id_hd,30000101) and b.so_id=t1.so_id and rownum=1) where t1.nv='2B';
update bc_bh_bt_temp t1 set n7=(select sum(tien_qd) from bh_bt_gd_hs where ma_dvi=t1.ma_dvi and so_id_bt=t1.so_id);
--LAM SACH
-- update bc_bh_bt_temp t1 set n8=(select sum(tien_qd) from bh_bt_ntba_pb where ma_dvi=t1.ma_dvi and so_id_hd=t1.so_id_hd and lh_nv=t1.lh_nv);
update bc_bh_bt_temp t1 set n9=(select sum(tien_qd) from bh_bt_thoi_pb where ma_dvi=t1.ma_dvi and so_id_hd=t1.so_id_hd and lh_nv=t1.lh_nv);
update bc_bh_bt_temp t1 set c28=(select ten from ht_ma_dvi where ma=t1.ma_dvi);
update bc_bh_bt_temp t1 set c26=(select ten from ht_ma_phong where ma_dvi=t1.ma_dvi and ma=t1.phong);
update bc_bh_bt_temp t1 set c21=(select ten from bh_ma_lhnv where ma_dvi=t1.ma_dvi and ma=t1.lh_nv);
update bc_bh_bt_temp t1 set c25=(select ten from bh_hd_ma_kh where ma_dvi=t1.ma_dvi and ma=t1.c5);
update bc_bh_bt_temp t1 set n29=(select nvl(max(ngay_tt),30000101) from bh_hd_goc_ttpt where ma_dvi=t1.ma_dvi_hd and so_id=t1.so_id_hd and pt<>'C');
--update bc_bh_bt_temp t1 set c14=(Select max(substr(ddiem,1,240)) from bh_bt_hs_nv where so_id=t1.so_id and lh_nv=t1.lh_nv);
update bc_bh_bt_temp t1 set (c15,c16,c17)=(Select max(n_trinh), max(n_duyet),max(ma_dvi_xl) from bh_bt_hs where so_id=t1.so_id and ma_dvi=t1.ma_dvi);
update bc_bh_bt_temp t1 set (c15)=(Select ten from ht_ma_nsd where ma=c15 and ma_dvi=c17);
update bc_bh_bt_temp t1 set (c16)=(Select ten from ht_ma_nsd where ma=c16 and ma_dvi=c17);
--BCNam
update bc_bh_bt_temp t1 set n13=(Select nvl(sum(pt),0) from bh_hd_do_tl where pthuc='C' and so_id=t1.so_id_hd and
        ma_dvi=t1.ma_dvi and (so_id_dt = 0 or so_id_dt = t1.so_id_dt) and (lh_nv=t1.lh_nv or lh_nv='*'));
update bc_bh_bt_temp t1 set n13=100 where n13 is null or n13=0;
update bc_bh_bt_temp t1 set tien_qd = tien_qd*n13/100 where n13 <> 100;

if b_hd='T' then
    delete bc_bh_bt_temp where n20 not between b_ngayd and b_ngayc;
end if;
if b_loai_kh is not null then
    delete bc_bh_bt_temp where c8<> b_loai_kh;
end if;
if b_ma_kh is not null then
    delete bc_bh_bt_temp where c5<> b_ma_kh;
end if;
if b_ma_cb is not null then
    delete bc_bh_bt_temp where c18<> b_ma_cb;
end if;
if b_ma_dl is not null then
    delete bc_bh_bt_temp where c3<> b_ma_dl and c6 not in('D','M');
end if;

commit;
----------------------------------------------------------------------------------------------------
/*
open cs_kq for select ma_dvi, c28 ten_dvi, phong, c26 ten_phong,c18 cb_ql,
    lh_nv, c21 ten_nv, c25 ten_kh,
    c4 so_gcn,decode(n29,30000101,'Chua nop phi',PKH_SO_CNG(n29)) ngay_tt, c2 so_hs,
    c7 ngay_xr, c19 ngay_gui, PKH_SO_CNG(ngay_ht) ngay_hs, nvl(n28,0) ngay_td,
    round(nvl(tien_qd,0)) tien_u,c22 gcn,c23 bien_xe,c24 ngay_qd,nvl(n7,0) tien_g,nvl(n8,0)+nvl(n9,0) tien_thu,1 so_vu,c5 ma_kh,
    c16 loai_kh,c17 ten_loai, c10 dia_chi, c11 ngay_cap, c12 ngay_hl, c13 ngay_kt, c15 nguoi_trinh,
    c16 nguoi_duyet,n19 phi_bh, c14 dia_diem_xrtt, c18 cb_ql,c20 ten_cb_ql, n30 tien_bh,
    n10 tyle_taicd, n11 tyle_taitt, n12 tyle_taiphityle
    from bc_bh_bt_temp order by ma_dvi,phong,c18,lh_nv,c5;*/
select nvl(sum(tien_qd),0) into b_ts_ubt from bc_bh_bt_temp;
select json_object('NGAYBC' value b_ngay_bc,'NGAY_TBC' value b_ngay_tao,'USTB' value FBH_CSO_TIEN(nvl(b_ts_ubt,0),'') returning clob) into dt_ct from dual;
select JSON_ARRAYAGG(json_object('STT' value rn, 'DVI' value c28,'NVU' value c21,'KH' value c25,'SOHD' value c4, 
    'NGAYNP' value decode(n29,30000101,'Chua nop phi',PKH_SO_CNG(n29)),'SOHSBT' value c2,'NGAYTN' value c7,'NGAYNTB' value c19,'NGAYMHSBT' value PKH_SO_CNG(ngay_ht),
    'NGAYDHSBT' value c12,'SNGAYTD' value nvl(n28,0),'USTB' value FBH_CSO_TIEN(nvl(tien_qd,0),'')) returning clob) 
    into dt_ds from ( select row_number() over(order by ma_dvi,phong,c18,lh_nv,c5) rn, t.* from bc_bh_bt_temp t);
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete bc_bh_bt_temp; delete ket_qua;commit;
exception when others then raise_application_error(-20105,b_loi);
End;

