drop procedure BBH_BH_BC_BH_NHANH_DTMOI;
/
CREATE OR REPLACE PROCEDURE BBH_BH_BC_BH_NHANH_DTMOI
    (dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number;
    b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd'); b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi'); b_nv varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'nv'); b_phong varchar2(10);
    b_ngay_bc varchar2(100);b_ten_cn varchar2(500);b_ten_pb varchar2(500);b_ten_nsd varchar2(500); b_ngay_tao varchar2(500);
    b_tenc varchar2(100); b_mac varchar2(100); b_tenbc varchar2(500);
    dt_ct clob;dt_ds clob;b_ngayB date;
begin
delete temp_1;
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
b_ten_cn := UNISTR(' - T\00ean chi nh\00e1nh: ') || FHT_MA_DVI_TENG(b_ma_dvi);
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_ten_pb := FHT_MA_PHONG_TEN(b_ma_dvi,b_phong);
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngayB:=PKH_SO_CDT(trunc(b_ngayd,-4)+101);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
b_tenbc := UNISTR('DOANH THU PH\00c1T SINH B\1ea2O HI\1ec2M G\1ed0C THEO ');
-- c1: stt, c2: ten nv, c3: ma nv, n1: kh_dt, n2:TIENP_tky, n3: TIENP_lKe, n4:TIENB_tky, n5: TIENB_lKe, c4: n5/n1 %, n6:TIENT_tky, n7: TIENT_lKe, n8: TT
b_nv := nvl(trim(b_nv),'');
case b_nv
-- theo nghiep vu : 1- khach hang, 2-phong,3 don vi, 4-nghiep vu
    when '1' then
        b_tenc := UNISTR('T\00ean kh\00e1ch h\00e0ng');
        b_mac := UNISTR('M\00e3 kh\00e1ch h\00e0ng');
        b_tenbc := b_tenbc || UNISTR('KH\00c1CH H\00c0NG');
    when '2' then
        b_tenc := UNISTR('T\00ean ph\00f2ng');
        b_mac  := UNISTR('M\00e3 ph\00f2ng');
        b_tenbc := b_tenbc || UNISTR('PH\00D2NG BAN');
    when '3' then
        b_tenc := UNISTR('T\00ean \0111\01a1n v\1ecb');
        b_mac  := UNISTR('M\00e3 \0111\01a1n v\1ecb');
        b_tenbc := b_tenbc || UNISTR('\0110\01A0N V\1ECA');
        --du lieu bao cao
        insert into temp_1(c3,n2,n4,n6)
        select t.ma_dvi, sum(t.PHIGP), sum(t.PHIGB), sum(t.PHIGT)
            from (select ma_dvi, nvl(PHIGP,0) PHIGP, nvl(PHIGB,0) PHIGB, nvl(PHIGT,0) PHIGT
                from SLI_DT_NG_LH where (nvl(PHIGP,0) <> 0 or nvl(PHIGB,0) <> 0 or nvl(PHIGT,0) <> 0 ) 
                and ma_dvi = b_ma_dvi and ngay between b_ngayd and b_ngayc ) t
        group by t.ma_dvi;
        b_ngayd:= trunc(PKH_NG_CSO(b_ngayB),-4)+101;
        update temp_1 p set (n3, n5, n7) =(select sum(t.PHIGP), sum(t.PHIGB), sum(t.PHIGT)
            from (select ma_dvi, nvl(PHIGP,0) PHIGP, nvl(PHIGB,0) PHIGB, nvl(PHIGT,0) PHIGT
                from SLI_DT_NG_LH where (nvl(PHIGP,0) <> 0 or nvl(PHIGB,0) <> 0 or nvl(PHIGT,0) <> 0)
                and ma_dvi = b_ma_dvi and ngay between b_ngayd and b_ngayc) t
            where t.ma_dvi = p.c3);
        update temp_1 p set n1 = (select sum(t.goc)
            from (select dvi, nvl(goc,0) goc
                from sli_kh_nam_lh where dvi = b_ma_dvi and nam = b_ngayd) t
            where t.dvi = p.c3);
        update temp_1 set c2=(select ten from ht_ma_dvi where ma=c3);
    else
        b_tenc := UNISTR('T\00ean nghi\1ec7p v\1ee5');
        b_mac  := UNISTR('M\00e3 nghi\1ec7p v\1ee5');
        b_tenbc := b_tenbc || UNISTR('NGHI\1ec6P V\1ee4');
        --du lieu bao cao
        insert into temp_1(c3,n2,n4,n6)
        select  t.lh_nv, sum(t.PHIGP), sum(t.PHIGB), sum(t.PHIGT)
            from (select lh_nv, nvl(PHIGP,0) PHIGP, nvl(PHIGB,0) PHIGB, nvl(PHIGT,0) PHIGT
                from SLI_DT_NG_LH where (nvl(PHIGP,0) <> 0 or nvl(PHIGB,0) <> 0 or nvl(PHIGT,0) <> 0 )
                and ma_dvi = b_ma_dvi and ngay between b_ngayd and b_ngayc ) t
        group by t.lh_nv;
        b_ngayd:= trunc(PKH_NG_CSO(b_ngayB),-4)+101;
        update temp_1 p set (n3, n5, n7) =(select sum(t.PHIGP), sum(t.PHIGB), sum(t.PHIGT)
            from (select lh_nv, nvl(PHIGP,0) PHIGP, nvl(PHIGB,0) PHIGB, nvl(PHIGT,0) PHIGT
                from SLI_DT_NG_LH where (nvl(PHIGP,0) <> 0 or nvl(PHIGB,0) <> 0 or nvl(PHIGT,0) <> 0)
                and ngay between b_ngayd and b_ngayc) t
            where t.lh_nv = p.c3);
        update temp_1 p set n1 = (select sum(t.goc)
            from (select lh_nv, nvl(goc,0) goc
                from sli_kh_nam_lh where nam = b_ngayd) t
            where t.lh_nv = p.c3);
        update temp_1 set c2=(select ten from bh_ma_lhnv where ma=c3);
end case;
update temp_1 t set (c1, n8) = (select to_char(rn), rn
  from (select rowid rid, row_number() over (order by c2) rn from temp_1) x where x.rid = t.rowid);
insert into temp_1 (c1,c2,c3,n1,n2,n3,n4,n5,n6,n7,n8) select UNISTR('T\1ed4NG'), '','',
 nvl(sum(n1), 0), nvl(sum(n2),0), nvl(sum(n3),0), nvl(sum(n4),0), nvl(sum(n5),0), 
 nvl(sum(n6),0), nvl(sum(n7),0), nvl(sum(n8),0) from temp_1;
update temp_1 t set c4 = ( select round(sum(n5) / nullif(sum(n1),0) * 100) || '%' from temp_1 where c1 <> UNISTR('T\1ed4NG') and nvl(n1,0) <> 0)
where t.c1 = UNISTR('T\1ed4NG');
update temp_1 set c4 = round(n5 / nullif(n1,0) * 100) || '%' where nvl(n1,0) <> 0 and c1 <> UNISTR('T\1ed4NG');
update temp_1 set n1 = 0 where n1 is null;
select JSON_ARRAYAGG(json_object(c1,c2,c3,c4,n1,n2,n3,n4,n5,n6,n7) order by n8 returning clob) into dt_ds from temp_1;
select json_object('TEN_CN' value b_ten_cn,'TEN_PB' value b_ten_pb,'NGAY_BC' value b_ngay_bc, 
    'TEN_NSD' value b_ten_nsd, 'NGAY_TAO' value b_ngay_tao, 'TENC' value b_tenc, 'MAC' value b_mac, 'TENBC' value b_tenbc) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
/
CREATE OR REPLACE PROCEDURE BC_BH_DTPS_CH
      (b_madvi varchar2,b_nsd varchar2,b_pas varchar2, b_oraIn clob,b_oraOut out clob)
AS
      b_lenh varchar2(4000); b_loi varchar2(100);b_ngaydn number; b_n1 number; b_n2 number; b_i1 number; b_phong_nsd varchar2(10);
      b_ma_dvi varchar2(10);b_ma_nv varchar2(10);b_phong varchar2(10);b_loai varchar2(10); b_ma_kh varchar2(10);
      b_ma_cb varchar2(10);b_nguon varchar2(10); b_ma_dt varchar2(10);b_kieu_kt varchar2(10);b_ma_dl varchar2(10);b_tien_d number;b_tien_c number;
      b_nhom varchar2(10); b_ngayd number;b_ngayc number; b_dvi varchar2(500); b_tennv varchar2(500);b_tenloai varchar2(500); 
      b_ten_phong varchar2(500);b_ten_khach varchar2(500); b_ngay_bc varchar2(100); b_ngay_tao varchar2(100); b_ten_nsd varchar2(500); 
      dt_ct clob;dt_ds clob;
Begin
-- Bao cao chi tiet doanh thu theo nghiep vu chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,loai_kh,ma_kh,ma_cb,ma_gt,ma_dt,kieu_kt,ma_dl,tiend,tienc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh 
into b_ma_dvi,b_ma_nv,b_phong,b_loai,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_kieu_kt,b_ma_dl,b_tien_d,b_tien_c,b_ngayd,b_ngayc using b_oraIn;
b_phong:= nvl(trim(b_phong),null); b_loai:= nvl(trim(b_loai),null); b_ma_kh:= nvl(trim(b_ma_kh),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
b_ma_nv:= nvl(trim(b_ma_nv),null); b_ma_dt:= nvl(trim(b_ma_dt),null); b_kieu_kt:= nvl(trim(b_kieu_kt),null); b_ma_dl:= nvl(trim(b_ma_dl),null);
b_nguon:= nvl(trim(b_nguon),null);
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
else  b_tenloai:=' ';
end if;
if b_phong is not null then
      select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_madvi and ma=b_phong;
else
    b_phong_nsd := FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    b_ten_phong := FHT_MA_PHONG_TEN(b_ma_dvi,b_phong_nsd);
    b_phong_nsd := null;
end if;
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
if b_ma_kh is not null then
      select ten into b_ten_khach from bh_hd_ma_kh where ma_dvi=b_madvi and ma=b_ma_kh;
else b_ten_khach:=' ';
end if;
if b_tien_c=0 and b_tien_d<>0 then b_n1:=b_tien_d; b_n2:=1.e18;
elsif b_tien_c=0 and b_tien_d=0 then b_n1:=-1.e18; b_n2:=1.e18;
elsif b_tien_d=0 then b_n1:=-1.e18; b_n2:=b_tien_c;
else b_n1:=b_tien_d; b_n2:=b_tien_c;
end if;
delete temp_1;delete temp_2;delete ket_qua; commit;
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);
select count(*) into b_i1 from temp_bc_dvi;
--return;
EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTPS_MM';
BC_BH_LAY_BC_BH_DTPS_MM(b_ma_dvi,b_ngayd,b_ngayc);
if b_i1=0 then
    insert into ket_qua (c29,c1,c2,c5,c6,c7,n4,n5,n1,n11,c12,c25,c26) select ma_dvi,cb_ql,ma_kh,so_hd,'',lh_nv,sum(phi),
            sum(thue),so_id,ngay_ht,nv,ma_kt,kieu_kt
        from TEMP_BC_BH_DTPS_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_ma_cb is null or cb_ql=b_ma_cb) and (b_kieu_kt is null or kieu_kt=b_kieu_kt)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%')
        and (b_ma_dl is null or ma_kt like b_ma_dl||'%')
        and (trim(b_nguon) is null or trim(nguon) like b_nguon||'%')
        group by ma_dvi,cb_ql,ma_kh,so_hd,lh_nv,so_id, ngay_ht,nv,ma_kt,kieu_kt;
else
      insert into ket_qua (c29,c1,c2,c5,c6,c7,n4,n5,n1,n11,c12,c25,c26) select ma_dvi,cb_ql,ma_kh,so_hd,'',lh_nv,sum(phi),
            sum(thue),so_id,ngay_ht,nv,ma_kt,kieu_kt
        from TEMP_BC_BH_DTPS_MM,temp_bc_dvi where ma_dvi=dvi
            and (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_ma_cb is null or cb_ql=b_ma_cb) and (b_kieu_kt is null or kieu_kt=b_kieu_kt)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%')
        and (b_ma_dl is null or ma_kt like b_ma_dl||'%')
        and (trim(b_nguon) is null or trim(nguon) like b_nguon||'%')
                group by ma_dvi,cb_ql,ma_kh,so_hd,lh_nv,so_id, ngay_ht,nv,ma_kt,kieu_kt;
end if;
delete ket_qua where nvl(n4,0)=0 and nvl(n5,0)=0;
--update ket_qua set (c8,c3) =(select ten,loai from bh_hd_ma_kh where ma_dvi=ket_qua.c29 and ma=ket_qua.c2);
update ket_qua set c9 =(select ten from bh_ma_lhnv where ma_dvi=ket_qua.c29 and ma=ket_qua.c7);
update ket_qua set c10 =(select ten from kh_ma_loai_dn where ma_dvi=ket_qua.c29 and ma=ket_qua.c3);
update ket_qua set c4 =(select ten from ht_ma_cb where ma_dvi=ket_qua.c29 and ma=ket_qua.c1);
update ket_qua set (c11,c13,c14,c22) =(select kieu_hd,ksoat,dvi_ksoat,ma_gt from bh_hd_goc where ma_dvi=ket_qua.c29 and so_id=ket_qua.n1);
update
       (select ket_qua.c8 ket_qua_c8, ket_qua.c3 ket_qua_c3, bh_hd_ma_kh.ten bh_hd_ma_kh_ten, bh_hd_ma_kh.loai bh_hd_ma_kh_loai
              from ket_qua, bh_hd_ma_kh
             where ket_qua.c29 = bh_hd_ma_kh.ma_dvi and ket_qua.c2 = bh_hd_ma_kh.ma)
       set ket_qua_c8 = bh_hd_ma_kh_ten, ket_qua_c3 = bh_hd_ma_kh_loai;
commit;
if b_ma_nv like 'TS%' or b_ma_nv like 'HP%' then
    update ket_qua set (n9) = (Select sum(tien)
        from bh_phh_dk where so_id = n1 and ma_dvi = c29 and lh_nv = c7 and phi>0)  where c12 = 'PHH';
end if;
if b_ma_nv like 'KT%' then
    update ket_qua set (n9) = (Select sum(tien)
    from bh_pkt_dk where so_id = n1 and ma_dvi = c29 and lh_nv = c7 and phi>0)  where c12 = 'PKT';
end if;
if b_ma_nv like 'TN%' then
    update ket_qua set (n9) = (Select sum(tien)
    from bh_ptn_dk where so_id = n1 and ma_dvi = c29 and lh_nv = c7 and phi>0)  where c12 = 'PTN';
end if;
merge into ket_qua
using (select sum(tien)tien,so_id,ma_dvi,lh_nv from bh_ng_dk where phi>0 group by so_id,ma_dvi,lh_nv)a
on (a.so_id = n1 and a.ma_dvi = c29 and a.lh_nv = c7 )
when matched then update set n9  = a.tien
where c12='NG';
--LAM SACH
-- if b_ma_nv like 'TT%' then
--     merge into ket_qua
--     using (select min(nt_tien)nt_tien,sum(tien)tien,so_id,ma_dvi,lh_nv from bh_taulgcn_dk where phi>0 group by so_id,ma_dvi,lh_nv) a
--     on (a.so_id = n1 and a.ma_dvi = c29 and a.lh_nv = c7 )
--     when matched then update set n9  = a.tien
--     where c12='TAUL';
--     merge into ket_qua
--     using bh_taulgcn a
--     on (a.so_id = n1 and a.ma_dvi = c29 )
--     when matched then update set c24=a.loai_tau
--     where c12='TAUL';
--     merge into ket_qua
--     using bh_tau_loai a
--     on (a.ma = c24 and a.ma_dvi = c29 )
--     when matched then update set c23  = a.ten
--     where c12='TAUL'; 
--     
--     merge into ket_qua
--     using (select min(nt_tien)nt_tien,sum(tien)tien,so_id,ma_dvi,lh_nv from bh_taugcn_dk where phi>0 group by so_id,ma_dvi,lh_nv) a
--     on (a.so_id = n1 and a.ma_dvi = c29 and a.lh_nv = c7 )
--     when matched then update set n9  = a.tien
--     where c12='TAU';
-- end if;
update
(
select ket_qua.c27 ket_qua_c27, BH_DL_MA_KH.ten BH_DL_MA_KH_ten from ket_qua,BH_DL_MA_KH where ket_qua.c25=BH_DL_MA_KH.ma and ket_qua.c29=BH_DL_MA_KH.ma_dvi
) set ket_qua_c27= BH_DL_MA_KH_ten;
commit;

insert into temp_1 (c2,c8,c5,n4,n5,c27)
select c2,c8,c5,Sum(t.n4),Sum(t.n5),c27
    from (select c2, c8, c5, nvl(n4,0) n4, nvl(n5,0) n5, c27 
        from ket_qua where (nvl(n2,0) between b_n1 and b_n2) and (b_loai is null or c3 like '%'|| b_loai||'%')) t
group by c2,c8,c5,c27;

update temp_1 t set (c40, n40) = (select to_char(rn), rn
  from (select rowid rid, row_number() over (order by c2,c5) rn from temp_1) x where x.rid = t.rowid);
insert into temp_1 (c40,c2,c8,c5,n4,n5,c27,n40) select UNISTR('T\1ed4NG'), '','','',nvl(sum(n4),0),nvl(sum(n5),0), '', nvl(max(n40)+1,0) from temp_1
where (nvl(n2,0) between b_n1 and b_n2) and (b_loai is null or c3 like '%'|| b_loai||'%');
update temp_1 set n39 = nvl(n4,0) + nvl(n5,0);

select JSON_ARRAYAGG(json_object('STT' value c40,'MA_KH' value c2,'TEN_KH' value c8,'SO_HD' value c5,'TT' value FBH_CSO_TIEN(nvl(n39,0),''), 
'DT' value FBH_CSO_TIEN(nvl(n4,0),''), 'THUE' value FBH_CSO_TIEN(nvl(n5,0),''), 'CB_KT' value c27) order by n40 returning clob) 
    into dt_ds from temp_1;
select json_object('TEN1' value b_dvi, 'TEN2' value b_ten_phong, 'TEN3' value b_ngay_bc, 'TEN4' value b_ngay_tao, 'TEN5' value b_ten_nsd)
    into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete temp_2;delete ket_qua; commit;
exception when others then raise_application_error(-20105,b_loi);
end;

/

CREATE OR REPLACE PROCEDURE BC_BH_DTBH_CH
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(4000); b_loi varchar2(100);b_ngaydn number; b_n1 number; b_n2 number; b_i1 number; b_phong_nsd varchar2(10);
    b_ma_dvi varchar2(10);b_ma_nv varchar2(10);b_phong varchar2(10);b_loai varchar2(10); b_ma_kh varchar2(10);
    b_ma_cb varchar2(10);b_nguon varchar2(10); b_ma_dt varchar2(10);b_kieu_kt varchar2(10); b_tien_d number;b_tien_c number;
    b_nhom varchar2(10); b_ngayd number;b_ngayc number; b_dvi varchar2(500); b_tennv varchar2(500);b_tenloai varchar2(500); 
    b_ten_phong varchar2(500);b_ten_khach varchar2(500); b_ngay_bc varchar2(100); b_ngay_tao varchar2(100); b_ten_nsd varchar2(500); 
    dt_ct clob;dt_ds clob;
Begin

b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,loai_kh,ma_kh,ma_cb,ma_gt,ma_dt,kieu_kt,tiend,tienc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh 
into b_ma_dvi,b_ma_nv,b_phong,b_loai,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_kieu_kt,b_tien_d,b_tien_c,b_ngayd,b_ngayc using b_oraIn;
b_phong:= nvl(trim(b_phong),null); b_loai:= nvl(trim(b_loai),null); b_ma_kh:= nvl(trim(b_ma_kh),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
b_ma_nv:= nvl(trim(b_ma_nv),null); b_ma_dt:= nvl(trim(b_ma_dt),null); b_kieu_kt:= nvl(trim(b_kieu_kt),null); b_nguon:= nvl(trim(b_nguon),null);

if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayc,-4)+101;b_loi:='loi:Ma chua dang ky:loi';
if b_ma_dvi is not null then
    select ten into b_dvi from ht_ma_dvi where ma=b_ma_dvi;
else b_dvi:=' ';
end if;

if b_loai is not null then
    select ten into b_tenloai from kh_ma_loai_dn where ma_dvi=b_madvi and ma=b_loai;
else    b_tenloai:=' ';
end if;
if b_phong is not null then
    select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_madvi and ma=b_phong;
else
    b_phong_nsd := FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    b_ten_phong := FHT_MA_PHONG_TEN(b_ma_dvi,b_phong_nsd);
    b_phong_nsd := null;
end if;
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
if b_ma_kh is not null then
    select ten into b_ten_khach from bh_hd_ma_kh where ma_dvi=b_madvi and ma=b_ma_kh;
else b_ten_khach:=' ';
end if;
if b_tien_c=0 and b_tien_d<>0 then b_n1:=b_tien_d; b_n2:=1.e18;
elsif b_tien_c=0 and b_tien_d=0 then b_n1:=-1.e18; b_n2:=1.e18;
elsif b_tien_d=0 then b_n1:=-1.e18; b_n2:=b_tien_c;
else b_n1:=b_tien_d; b_n2:=b_tien_c;
end if;
--delete temp_2;delete ket_qua; commit;
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_2';EXECUTE IMMEDIATE 'TRUNCATE TABLE ket_qua';
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
--delete temp_bc_ts;
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bc_ts';
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);
select count(*) into b_i1 from temp_bc_dvi;

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MM';
BC_BH_LAY_BC_BH_DTBH_MM(b_ma_dvi,b_ngayd,b_ngayc);

--het xu ly
if b_i1=0 then
    insert into ket_qua (c29,c1,c2,c5,c6,c7,n2,n3,n1,c13,c14,c22,c23,c24) select ma_dvi,cb_ql,ma_kh,so_hd,'',lh_nv,sum(phi),
        sum(thue),so_id,kieu_kt,ma_kt,to_char(ngay_hl,'dd/MM/yyyy'),to_char(ngay_kt,'dd/MM/yyyy'),MA_DVIG
        from TEMP_BC_BH_DTBH_MM where (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_ma_cb is null or cb_ql=b_ma_cb) and (b_kieu_kt is null or kieu_kt=b_kieu_kt)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%')
        and (trim(b_nguon) is null or trim(nguon) like b_nguon||'%')
        group by ma_dvi,cb_ql,ma_kh,so_hd,lh_nv,so_id,kieu_kt,ma_kt,ngay_hl,ngay_kt,MA_DVIG;
else
    insert into ket_qua (c29,c1,c2,c5,c6,c7,n2,n3,n1,c13,c14,c22,c23,c24) select ma_dvi,cb_ql,ma_kh,so_hd,'',lh_nv,sum(phi),
        sum(thue),so_id,kieu_kt,ma_kt,to_char(ngay_hl,'dd/MM/yyyy'),to_char(ngay_kt,'dd/MM/yyyy'),MA_DVIG
        from TEMP_BC_BH_DTBH_MM,temp_bc_dvi where ma_dvi=dvi
            and (b_phong is null or phong=b_phong) and (b_ma_kh is null or ma_kh=b_ma_kh)
        and (b_ma_cb is null or cb_ql=b_ma_cb) and (b_kieu_kt is null or kieu_kt=b_kieu_kt)
        and (b_ma_nv is null or lh_nv like b_ma_nv||'%')
        and (trim(b_nguon) is null or trim(nguon) like b_nguon||'%')
        group by ma_dvi,cb_ql,ma_kh,so_hd,lh_nv,so_id,kieu_kt,ma_kt,ngay_hl,ngay_kt,MA_DVIG;
end if;
delete ket_qua where nvl(n2,0)=0 and nvl(n3,0)=0;
merge into ket_qua
using bh_hd_goc a
on (a.ma_dvi=c29 and a.so_id=n1)
when matched then update
set c35 = a.ma_kt,c37=a.kieu_gt,c36 = a.ma_gt,c18=ksoat,c34=nsd;
select count(*) into b_i1 from ket_qua;

update ket_qua set c4 =(select ten from ht_ma_cb where ma_dvi=ket_qua.c29 and ma=ket_qua.c1);

update ket_qua set c9 =(select ten from bh_ma_lhnv where ma_dvi=ket_qua.c29 and ma=ket_qua.c7);

update ket_qua set c10 =(select ten from kh_ma_loai_dn where ma_dvi=ket_qua.c29 and ma=ket_qua.c3);

merge into ket_qua
using bh_dl_ma_kh
on (bh_dl_ma_kh.ma_dvi=ket_qua.c24 and bh_dl_ma_kh.ma=ket_qua.c14)
when matched then update set c15 = ten;

update
    (select ket_qua.c3 kq_c3, ket_qua.c8 kq_c8, bh_hd_ma_kh.loai goc_loai, bh_hd_ma_kh.ten goc_ten,ket_qua.c25 ket_qua_c25,bh_hd_ma_kh.cmt bh_hd_ma_kh_MST,ket_qua.c38 ket_qua_c38,bh_hd_ma_kh.CMT bh_hd_ma_kh_SO_CMT
        ,ket_qua.c30 ket_qua_c30, bh_hd_ma_kh.LOAI bh_hd_ma_kh_ma_kh 
        from ket_qua, bh_hd_ma_kh
        where bh_hd_ma_kh.ma_dvi=ket_qua.c24 and bh_hd_ma_kh.ma=ket_qua.c2)
        set kq_c3=goc_loai, kq_c8=goc_ten,ket_qua_c25=bh_hd_ma_kh_MST,ket_qua_c30=bh_hd_ma_kh_ma_kh,ket_qua_c38=bh_hd_ma_kh_SO_CMT;

insert into temp_1 (c2,c8,c5,n2,n3,c35)
select c2,c8,c5,Sum(t.n2),Sum(t.n3),fht_ma_cb_ten(c29,c35)
    from (select c2, c8, c5, nvl(n2,0) n2, nvl(n3,0) n3, c29, c35
        from ket_qua where (nvl(n2,0) between b_n1 and b_n2) and (b_loai is null or c3=b_loai)) t
group by c2,c8,c5,c35,c29;

update temp_1 t set (c40, n40) = (select to_char(rn), rn
  from (select rowid rid, row_number() over (order by c2,c5) rn from temp_1) x where x.rid = t.rowid);
insert into temp_1 (c40,c2,c8,c5,n2,n3,c35,n40) select UNISTR('T\1ed4NG'), '','','',nvl(sum(n2),0),nvl(sum(n3),0), '', nvl(max(n40)+1,0) from temp_1
where (nvl(n2,0) between b_n1 and b_n2) and (b_loai is null or c3 like '%'|| b_loai||'%');
update temp_1 set n39 = nvl(n2,0) + nvl(n3,0);

select JSON_ARRAYAGG(json_object('STT' value c40,'MA_KH' value c2,'TEN_KH' value c8,'SO_HD' value c5,'TT' value FBH_CSO_TIEN(nvl(n39,0),''), 
'DT' value FBH_CSO_TIEN(nvl(n2,0),''), 'THUE' value FBH_CSO_TIEN(nvl(n3,0),''), 'CB_KT' value c35) order by n40 returning clob) 
    into dt_ds from temp_1;
select json_object('TEN1' value b_dvi, 'TEN2' value b_ten_phong, 'TEN3' value b_ngay_bc, 'TEN4' value b_ngay_tao, 'TEN5' value b_ten_nsd)
    into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete temp_2;delete ket_qua; commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BBH_BH_BC_BH_THUC_THU_CH
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2, b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(4000);  b_loi varchar2(100);b_ngaydn number; b_n1 number; b_n2 number; b_i1 number;
    b_loai_kh varchar2(1000); b_ten_proc varchar2(40); b_phong_nsd varchar2(10);
    b_ma_dvi varchar2(10);b_ma_nv varchar2(10);b_phong varchar2(10);b_loai varchar2(10); b_ma_kh varchar2(10);
    b_ma_cb varchar2(10);b_nguon varchar2(10); b_ma_dt varchar2(10);b_kieu_kt varchar2(10);b_ma_dl varchar2(10);b_tien_d number;b_tien_c number;
    b_nhom varchar2(10); b_ngayd number;b_ngayc number; b_dvi varchar2(500); b_tennv varchar2(500);b_tenloai varchar2(500); 
    b_ten_phong varchar2(500);b_ten_khach varchar2(500); b_ngay_bc varchar2(100); b_ngay_tao varchar2(100); b_ten_nsd varchar2(500); 
    dt_ct clob;dt_ds clob;
Begin

b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,loai_kh,ma_kh,ma_cb,ma_gt,ma_dt,kieu_kt,ma_dl,tiend,tienc,ngayd,ngayc');
EXECUTE IMMEDIATE b_lenh 
into b_ma_dvi,b_ma_nv,b_phong,b_loai,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_kieu_kt,b_ma_dl,b_tien_d,b_tien_c,b_ngayd,b_ngayc using b_oraIn;
b_phong:= nvl(trim(b_phong),null); b_loai:= nvl(trim(b_loai),null); b_ma_kh:= nvl(trim(b_ma_kh),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
b_ma_nv:= nvl(trim(b_ma_nv),null); b_ma_dt:= nvl(trim(b_ma_dt),null); b_kieu_kt:= nvl(trim(b_kieu_kt),null); b_ma_dl:= nvl(trim(b_ma_dl),null);
b_nguon:= nvl(trim(b_nguon),null);
if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayc,-4)+101;
b_loi:='loi:Ma chua dang ky:loi';
if b_ma_dvi is not null then
    select ten_gon into b_dvi from ht_ma_dvi where ma=b_ma_dvi;
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
else  b_phong_nsd := FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    b_ten_phong := FHT_MA_PHONG_TEN(b_ma_dvi,b_phong_nsd);
    b_phong_nsd := null;
end if;
if b_ma_kh is not null then
    select ten into b_ten_khach from bh_hd_ma_kh where ma_dvi=b_madvi and ma=b_ma_kh;
else b_ten_khach:=' ';
end if;
b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
if b_tien_c=0 and b_tien_d<>0 then b_n1:=b_tien_d; b_n2:=1.e18;
elsif b_tien_c=0 and b_tien_d=0 then b_n1:=-1.e18; b_n2:=1.e18;
elsif b_tien_d=0 then b_n1:=-1.e18; b_n2:=b_tien_c;
else b_n1:=b_tien_d; b_n2:=b_tien_c;
end if;
delete temp_1;delete temp_2;delete ket_qua; commit;
--Doanh thu
PBC_LAY_DVI(b_madvi,b_ma_dvi,b_nsd,b_pas,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);

EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTTT_MA_DT';
commit;
BC_BH_LAY_BC_BH_DTTT_MA_DT(b_ma_dvi,b_ngayd,b_ngayc);
--return;
insert into temp_1(c23,c24,c29,c28,c1,c2,c3,c4,c5,c7,n10,n1,n12,n14,c19,c22)
        select ngay_hl,ngay_kt,ma_dvi,ma_dvig,so_hd,ma_kh,cb_ql,phong,ma_kt,lh_nv,round(sum(phi),0),sum(thue),ngay_htnv,so_id,kieu_kt,nv
            from TEMP_BC_BH_DTTT_MA_DT where (b_ma_dvi is null or ma_dvi=b_ma_dvi)
                and ngay_htbs between b_ngayd and b_ngayc
                and (b_ma_cb is null or cb_ql=b_ma_cb)
                and (b_ma_kh is null or ma_kh=b_ma_kh)
                and (b_phong is null or phong=b_phong)
                and (b_ma_nv is null or lh_nv like b_ma_nv||'%')
                and (b_kieu_kt is null or kieu_kt=b_kieu_kt)
                and (b_ma_dl is null or ma_kt like b_ma_dl||'%')
                and (trim(b_nguon) is null or trim(nguon) like b_nguon||'%')
            group by ngay_hl,ngay_kt,ma_dvi,ma_dvig,so_hd,ma_kh,cb_ql,phong,ma_kt,lh_nv,ngay_htnv,so_id,kieu_kt,nv;

select count(*) into b_i1 from temp_bc_dvi;
if b_i1=0 then
    insert into ket_qua (c18,c29,c1,c2,c5,c6,c7,c11,n2,n3,c28,n12,n14,c23,c24,c19,c22)
       select c5,c29,c3,c2,c1,'',c7,c4,sum(n10),sum(n1),max(c28),n12,n14,c23,c24,c19,c22 from temp_1 group by c5,c29,c3,c2,c1,c7,c4,n12,n14,c19,c22;--where n20 between b_ngayd and b_ngayc;
else
    insert into ket_qua (c18,c29,c1,c2,c5,c6,c7,c11,n2,n3,c28,n12,n14,c23,c24,c19,c22)
         select c5,c29,c3,c2,c1,'',c7,c4,sum(n10),sum(n1),max(c28),n12,n14,c23,c24,c19,c22 from temp_1,temp_bc_dvi
         where c29=dvi group by c5,c29,c3,c2,c1,c7,c4,n12,n14,c23,c24,c19,c22;
end if;
delete ket_qua where nvl(n2,0)=0;
delete ket_qua where nvl(n2,0)=0 and nvl(n3,0)=0;

merge into ket_qua
using bh_ma_lhnv
on (ket_qua.c28 = bh_ma_lhnv.ma_dvi and ket_qua.c7 = bh_ma_lhnv.ma)
when matched then update
set c9 = ten;
--update ket_qua set c10=(select ten from kh_ma_loai_dn where ket_qua.c28 = kh_ma_loai_dn.ma_dvi and ket_qua.c3 = kh_ma_loai_dn.ma);
merge into ket_qua
using kh_ma_loai_dn
on (ket_qua.c28 = kh_ma_loai_dn.ma_dvi and ket_qua.c3 = kh_ma_loai_dn.ma  )
when matched then update
set c10 = ten;
--update ket_qua set c12=(select ten from ht_ma_phong where ket_qua.c28 = ht_ma_phong.ma_dvi and ket_qua.c11 = ht_ma_phong.ma);
merge into ket_qua
using ht_ma_phong
on (ket_qua.c28 = ht_ma_phong.ma_dvi and ket_qua.c11 = ht_ma_phong.ma)
when matched then update
set c12 = ten;
--update ket_qua set c4=(select ten from ht_ma_cb where ket_qua.c28 = ht_ma_cb.ma_dvi and ket_qua.c1 = ht_ma_cb.ma);
merge into ket_qua
using ht_ma_cb
on (ket_qua.c28 = ht_ma_cb.ma_dvi and ket_qua.c1 = ht_ma_cb.ma)
when matched then update
set c4 = ten;

update
       (select ket_qua.c3 ket_qua_c3, ket_qua.c8 ket_qua_c8,ket_qua.c17 ket_qua_c17, bh_hd_ma_kh.ten bh_hd_ma_kh_ten,
            bh_hd_ma_kh.loai bh_hd_ma_kh_loai,'' bh_hd_ma_kh_ngay_ht,
            ket_qua.c32 ket_qua_c32, bh_hd_ma_kh.cmt bh_hd_ma_kh_tax,ket_qua.c34 ket_qua_c34, bh_hd_ma_kh.cmt bh_hd_ma_kh_so_cmt
              from ket_qua, bh_hd_ma_kh
             where ket_qua.c28 = bh_hd_ma_kh.ma_dvi and ket_qua.c2 = bh_hd_ma_kh.ma)
       set ket_qua_c8 = bh_hd_ma_kh_ten, ket_qua_c3 = bh_hd_ma_kh_loai, ket_qua_c17 = bh_hd_ma_kh_ngay_ht,ket_qua_c32=bh_hd_ma_kh_tax,ket_qua_c34=bh_hd_ma_kh_so_cmt ;

update
(
select ket_qua.c27 ket_qua_c27, BH_DL_MA_KH.ten BH_DL_MA_KH_ten from ket_qua,BH_DL_MA_KH where ket_qua.c18=BH_DL_MA_KH.ma and ket_qua.c29=BH_DL_MA_KH.ma_dvi
) set ket_qua_c27= BH_DL_MA_KH_ten;
merge into ket_qua
using bh_dl_ma_kh
on (bh_dl_ma_kh.ma_dvi='000' and bh_dl_ma_kh.ma=ket_qua.c18)
when matched then update set c27 = ten
where c27 is null;
merge into ket_qua using bh_hd_goc on (ma_dvi=c29 and so_id=n14) when matched then update set c40=nsd,c13=ksoat,c14=dvi_ksoat,c15=bcnam_so_ngay_f(ngay_cap),c16=ma_gt; 
update ket_qua set n31 = (select sum(tien) from bh_hd_goc_dk where ma_dvi=c29 and so_id=n14 and lh_nv=c7);
--LAM SACH
-- merge into ket_qua using bh_dt_ma_kh a on(a.ma=c16 and a.ma_dvi=c29) when matched then update set c33 =a.ma_ct;
commit;
delete temp_1; commit;
insert into temp_1 (c2,c8,c5,n2,n3,c27)
select c2,c8,c5,Sum(t.n2),Sum(t.n3),c27
    from (select c2, c8, c5, nvl(n2,0) n2, nvl(n3,0) n3, c27
        from ket_qua where (INSTR1(c3,b_loai_kh)>0 or b_loai_kh is null) and (nvl(n2,0) between b_n1 and b_n2)) t
group by t.c2,t.c8,t.c5,t.c27;
   
update temp_1 t set (c40, n40) = (select to_char(rn), rn
  from (select rowid rid, row_number() over (order by c2,c5) rn from temp_1) x where x.rid = t.rowid);
insert into temp_1 (c40,c2,c8,c5,n2,n3,c27,n40) select UNISTR('T\1ed4NG'), '','','',nvl(sum(n2),0),nvl(sum(n3),0), '', nvl(max(n40)+1,0) from temp_1
where (INSTR1(c3,b_loai_kh)>0 or b_loai_kh is null) and (nvl(n2,0) between b_n1 and b_n2);
update temp_1 set n39 = nvl(n2,0) + nvl(n3,0);

select JSON_ARRAYAGG(json_object('STT' value c40,'MA_KH' value c2,'TEN_KH' value c8,'SO_HD' value c5,'TT' value FBH_CSO_TIEN(nvl(n39,0),''), 
'DT' value FBH_CSO_TIEN(nvl(n2,0),''), 'THUE' value FBH_CSO_TIEN(nvl(n3,0),''), 'CB_KT' value c27) order by n40 returning clob) 
    into dt_ds from temp_1;
select json_object('TEN1' value b_dvi, 'TEN2' value b_ten_phong, 'TEN3' value b_ngay_bc, 'TEN4' value b_ngay_tao, 'TEN5' value b_ten_nsd)
    into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
delete temp_1;delete temp_2;delete ket_qua; commit;
exception when others then raise_application_error(-20105,b_loi);
end;
/
CREATE OR REPLACE PROCEDURE BBH_BH_BC_BH_CT_DT_GOC
 (b_madvi varchar2,b_nsd varchar2,b_pas varchar2, b_oraIn clob,b_oraOut out clob)
  as
  b_ngayd1 number; b_loai_khang varchar2(1000); b_nghe  nvarchar2(100); b_nhom_nghe nvarchar2(100); b_so_id number;
  b_lenh varchar2(4000);  b_loi varchar2(100);b_ngaydn number; b_n1 number; b_n2 number; b_i1 number;
  b_loai_kh varchar2(1000); b_ten_proc varchar2(40); b_phong_nsd varchar2(10);
  b_ma_dvi varchar2(10);b_ma_nv varchar2(10);b_phong varchar2(10); b_ma_kh varchar2(10);
  b_ma_cb varchar2(10);b_nguon varchar2(10); b_ma_dt varchar2(10); b_kieu_kt varchar2(10);b_ma_dl varchar2(10);b_tien_d number;b_tien_c number;
  b_nhom varchar2(10); b_ngayd number;b_ngayc number; b_dvi varchar2(500); b_tennv varchar2(500);b_tenloai varchar2(500); 
  b_ten_phong varchar2(500);b_ten_khach varchar2(500); b_ngay_bc varchar2(100); b_ngay_tao varchar2(100); b_ten_nsd varchar2(500); 
  dt_ct clob;dt_ds clob;
begin
 b_lenh:=FKH_JS_LENH('ma_dvi,ma_nv,phong,loai_kh,ma_kh,ma_cb,ma_gt,ma_dt,kieu_kt,ma_dl,tiend,tienc,ngayd,ngayc');
 EXECUTE IMMEDIATE b_lenh 
 into b_ma_dvi,b_ma_nv,b_phong,b_loai_kh,b_ma_kh,b_ma_cb,b_nguon,b_ma_dt,b_kieu_kt,b_ma_dl,b_tien_d,b_tien_c,b_ngayd,b_ngayc using b_oraIn;
 b_phong:= nvl(trim(b_phong),null); b_loai_kh:= nvl(trim(b_loai_kh),null); b_ma_kh:= nvl(trim(b_ma_kh),null); b_ma_cb:= nvl(trim(b_ma_cb),null);
 b_ma_nv:= nvl(trim(b_ma_nv),null); b_ma_dt:= nvl(trim(b_ma_dt),null); b_kieu_kt:= nvl(trim(b_kieu_kt),null); b_ma_dl:= nvl(trim(b_ma_dl),null);
 b_nguon:= nvl(trim(b_nguon),null);
  execute immediate 'truncate table temp_2';execute immediate 'truncate table ket_qua';
  b_loai_khang := null;
  select ';' || trim(b_loai_kh) || ';' ||
          replace(rtrim(xmlagg(xmlelement(e, kq.ma || ';')).extract('//text()'), ';'), '#', '''''') || ';'
  into   b_loai_khang
  from   (select distinct v.ma from kh_ma_loai_dn v where v.ma_ct = b_loai_kh) kq;
  if b_loai_kh is null then
    b_loai_khang := b_loai_kh;
  end if;

  if b_ngayd is null or b_ngayc is null then
    b_loi := 'loi:Nhap ngay bao cao:loi';
    raise program_error;
  end if;
  b_ngaydn := round(b_ngayd, -4) + 101;
  --ngay truoc ngay dau 1 ngay
  b_ngayd1 := pkh_ng_cso(pkh_so_cdt(b_ngayd) - 1);

  execute immediate 'TRUNCATE TABLE temp_1';
  execute immediate 'TRUNCATE TABLE temp_2';
  execute immediate 'TRUNCATE TABLE temp_3';
  execute immediate 'TRUNCATE TABLE ket_qua';
  

  if b_tien_c = 0 and b_tien_d <> 0 then
    b_n1 := b_tien_d;
    b_n2 := 1.e18;
  elsif b_tien_c = 0 and b_tien_d = 0 then
    b_n1 := -1.e18;
    b_n2 := 1.e18;
  elsif b_tien_d = 0 then
    b_n1 := -1.e18;
    b_n2 := b_tien_c;
  else
    b_n1 := b_tien_d;
    b_n2 := b_tien_c;
  end if;
  pbc_lay_nv(b_madvi, b_ma_dvi, b_nsd, b_pas, b_phong);
  -- Hung chuyen 1
 execute immediate 'TRUNCATE TABLE TEMP_BC_BH_DTPS_MNVM';
  BC_BH_LAY_BC_BH_DTPS_MNVM(b_ma_dvi, b_ngayd, b_ngayc);-- doanh thu phat sinh
  insert into temp_2
    (c27, c1, c2, c3, c4, c5, c7, c20, c21, n2, n3, n14, c28)
    select ma_dvi, so_hd, ma_kh, cb_ql, phong, ma_kt, lh_nv,'', -- fbc_ma_bh(ma_dvi, nv, so_id)
           '', phi, thue, so_id, ma_dvig --fbc_ma_bh_ten(ma_dvi, nv, so_id, ngay_ht)
    from   temp_bc_bh_dtps_mnvm
    where  (b_ma_dvi is null or ma_dvi = b_ma_dvi)
           and (b_phong is null or phong = b_phong)
           and (b_ma_kh is null or ma_kh = b_ma_kh)
           and (b_ma_nv is null or lh_nv like b_ma_nv || '%')
           and (b_ma_cb is null or cb_ql = b_ma_cb)
           and (b_ma_dl is null or ma_kt = b_ma_dl)
           and (b_kieu_kt is null or kieu_kt = b_kieu_kt)
           and (trim(b_nguon) is null or trim(nguon) like b_nguon || '%')
           and ngay_ht between b_ngayd and b_ngayc;
  
   execute immediate 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MNVM';
  BC_BH_LAY_BC_BH_DTBH_MNVM(b_ma_dvi, b_ngayd, b_ngayc);-- doanh thu ban hang
  insert into temp_2
    (c27, c1, c2, c3, c4, c5, c7, c20, c21, n6, n7, n14, c28)
    select ma_dvi, so_hd, ma_kh, cb_ql, phong, ma_kt, lh_nv, '',
           '', phi, thue, so_id, ma_dvig
    from   temp_bc_bh_dtbh_mnvm
    where  (b_ma_dvi is null or ma_dvi = b_ma_dvi)
           and (b_phong is null or phong = b_phong)
           and (b_ma_kh is null or ma_kh = b_ma_kh)
           and (b_ma_nv is null or lh_nv like b_ma_nv || '%')
           and (b_ma_cb is null or cb_ql = b_ma_cb)
           and (b_ma_dl is null or ma_kt = b_ma_dl)
           and (b_kieu_kt is null or kieu_kt = b_kieu_kt)
           and (trim(b_nguon) is null or trim(nguon) like b_nguon || '%');
 

  execute immediate 'TRUNCATE TABLE TEMP_BC_BH_DTTT_MA_DT';
  BC_BH_LAY_BC_BH_DTTT_MA_DT(b_ma_dvi, b_ngayd, b_ngayc);-- danh thu thuc thu
  insert into temp_1
    (c27, c1, c2, c3, c4, c5, c7, c20, c21, n10, n11, n12, n13, n14, c29, c28)
    select ma_dvi, so_hd, ma_kh, cb_ql, phong, ma_kt, lh_nv, '',
           '', phi, thue, ngay, ngay_htnv, so_id, ma_dvi, ma_dvig
    from   temp_bc_bh_dttt_ma_dt
    where  (b_ma_dvi is null or ma_dvi = b_ma_dvi) --and FBH_HD_SO_ID_DAU(ma_dvi,so_id_tt)<>so_id
           --and ngay_htbs between b_ngayd and b_ngayc
           and (b_ma_nv is null or lh_nv like b_ma_nv || '%')
           and (b_phong is null or phong = b_phong)
           and (b_ma_kh is null or ma_kh = b_ma_kh)
           and (b_ma_dl is null or ma_kt = b_ma_dl)
           and (b_ma_cb is null or cb_ql = b_ma_cb)
           and (trim(b_nguon) is null or trim(nguon) like b_nguon || '%');
 

  -- Hung het chuyen 1
  insert into temp_2
    (c27, c1, c2, c3, c4, c5, c7, c20, c21, n10, n11, n14, c28)
    select c27, c1, c2, c3, c4, c5, c7, c20, c21, n10, n11, n14, c28 from temp_1; -- where n20 between b_ngayd and b_ngayc;
  -- Hung chuyen luy ke
  if b_ngayd <> b_ngaydn then
    execute immediate 'TRUNCATE TABLE TEMP_BC_BH_DTPS_MNVM';
    BC_BH_LAY_BC_BH_DTPS_MNVM(b_ma_dvi, b_ngaydn, b_ngayd1);
    insert into temp_2
      (c27, c1, c2, c3, c4, c5, c7, c20, c21, n4, n5, n16, n14, c28)
      select ma_dvi, so_hd, ma_kh, cb_ql, phong, ma_kt, lh_nv, '',
             '', phi, thue, so_id, so_id, ma_dvig
      from   temp_bc_bh_dtps_mnvm
      where  (b_ma_dvi is null or ma_dvi = b_ma_dvi)
             and (b_phong is null or phong = b_phong)
             and (b_ma_kh is null or ma_kh = b_ma_kh)
             and (b_ma_nv is null or lh_nv like b_ma_nv || '%')
             and (b_ma_cb is null or cb_ql = b_ma_cb)
             and (b_ma_dl is null or ma_kt = b_ma_dl)
             and (b_kieu_kt is null or kieu_kt = b_kieu_kt)
             and (trim(b_nguon) is null or trim(nguon) like b_nguon || '%')
             and ngay_htnv between b_ngaydn and b_ngayd1;


    execute immediate 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MNVM';
    bc_bh_lay_bc_bh_dtbh_mnvm(b_ma_dvi, b_ngaydn, b_ngayd1);
    insert into temp_2
      (c27, c1, c2, c3, c4, c5, c7, c20, c21, n8, n9, n16, n14, c28)
      select ma_dvi, so_hd, ma_kh, cb_ql, phong, ma_kt, lh_nv, '',
             '', phi, thue, so_id, so_id, ma_dvig
      from   temp_bc_bh_dtbh_mnvm
      where  (b_ma_dvi is null or ma_dvi = b_ma_dvi)
             and (b_phong is null or phong = b_phong)
             and (b_ma_kh is null or ma_kh = b_ma_kh)
             and (b_ma_nv is null or lh_nv like b_ma_nv || '%')
             and (b_ma_cb is null or cb_ql = b_ma_cb)
             and (b_ma_dl is null or ma_kt = b_ma_dl)
             and (b_kieu_kt is null or kieu_kt = b_kieu_kt)
             and (trim(b_nguon) is null or trim(nguon) like b_nguon || '%')
             and ngay_htnv between b_ngaydn and b_ngayd1;
   

    execute immediate 'TRUNCATE TABLE TEMP_1';
    execute immediate 'TRUNCATE TABLE TEMP_BC_BH_DTTT_MA_DT';
    bc_bh_lay_bc_bh_dttt_ma_dt(b_ma_dvi, b_ngaydn, b_ngayd1);
    insert into temp_1
      (c27, c1, c2, c3, c4, c5, c7, c20, c21, n12, n13, n14, n15, n16, c29, c28)
      select ma_dvi, so_hd, ma_kh, cb_ql, phong, ma_kt, lh_nv, '',
             '', phi, thue, ngay, ngay_htnv, so_id, ma_dvi, ma_dvig
      from   temp_bc_bh_dttt_ma_dt
      where  (b_ma_dvi is null or ma_dvi = b_ma_dvi) --and FBH_HD_SO_ID_DAU(ma_dvi,so_id_tt)<>so_id
           --  and ngay_htbs between b_ngaydn and b_ngayd1
             and (b_ma_nv is null or lh_nv like b_ma_nv || '%')
             and (b_ma_cb is null or cb_ql = b_ma_cb)
             and (b_ma_dvi is null or ma_dvi = b_ma_dvi)
             and (b_phong is null or phong = b_phong)
             and (b_ma_kh is null or ma_kh = b_ma_kh)
             and (b_ma_dl is null or ma_kt = b_ma_dl)
             and (trim(b_nguon) is null or trim(nguon) like b_nguon || '%');

    insert into temp_2
      (c27, c1, c2, c3, c4, c5, c7, c20, c21, n12, n13, n14, c28)
      select c27, c1, c2, c3, c4, c5, c7, c20, c21, n12, n13, n16, c28 from temp_1;
 
  end if;

  --sap xep
  insert into ket_qua
          (c27, c20, c21, c1, c2, c3, c4, c5, c6, c7, n1, n2, n3, n4, n5, n6, n7, n8, n9, n10, n11, n12, n13, n30, n14, c28)
    select c27, c20, c21, c1, c2, c3, c4, c5, c6, c7, sum(nvl(n1, 0)), sum(nvl(n2, 0)), sum(nvl(n3, 0)),
           sum(nvl(n4, 0) + nvl(n2, 0)), sum(nvl(n5, 0) + nvl(n3, 0)), sum(nvl(n6, 0)), sum(nvl(n7, 0)),
           sum(nvl(n8, 0) + nvl(n6, 0)), sum(nvl(n9, 0) + nvl(n7, 0)), sum(nvl(n10, 0)), sum(nvl(n11, 0)),
           sum(nvl(n12, 0) + nvl(n10, 0)), sum(nvl(n13, 0) + nvl(n11, 0)),
           (case
             when substr(c7, 1, 2) = 'XG' then
              1
             when substr(c7, 1, 2) = 'CN' then
              2
             when substr(c7, 1, 2) = 'HH' then
              3
             when substr(c7, 1, 2) = 'TT' then
              4
             when substr(c7, 1, 2) = 'TS' then
              5
             when substr(c7, 1, 2) = 'HP' then
              6
             when substr(c7, 1, 2) = 'TN' then
              7
             else
              0
           end), n14, c28
    from   temp_2
    group  by c27, c20, c21, c1, c2, c3, c4, c5, c6, c7, n14, c28;


  if b_loai_kh is not null then
    --update ket_qua set (c6) =(select nvl(loai, 'N/A')from   bh_hd_ma_kh where  ma_dvi = c28 and ma = c2);
    update
    (select  ket_qua.c6 ket_qua_c6, nvl(bh_hd_ma_kh.loai, 'N/A') bh_hd_ma_kh_loai,ket_qua.c32 ket_qua_c32, '' bh_hd_ma_kh_ngay_ht,
             ket_qua.c34 ket_qua_c34, bh_hd_ma_kh.cmt bh_hd_ma_kh_tax
        from ket_qua, bh_hd_ma_kh
        where ket_qua.c28 = bh_hd_ma_kh.ma_dvi and ket_qua.c2 = bh_hd_ma_kh.ma)
        set  ket_qua_c6 = bh_hd_ma_kh_loai,ket_qua_c32 = bh_hd_ma_kh_ngay_ht,ket_qua_c34=bh_hd_ma_kh_tax ;
  
    delete ket_qua  where  c6 not like b_loai_kh || '%'  or c6 is null;
    --update ket_qua set (c32) =(select to_char(ngay_ht, 'DD/mm/yyyy')from   bh_hd_ma_kh where  ma_dvi = c28 and ma = c2);
  else
    --update ket_qua set (c6,c32)=(select nvl(loai,'N/A'),to_char(ngay_ht, 'DD/mm/yyyy') from bh_hd_ma_kh where ma_dvi=c28 and ma=c2);
    update (select ket_qua.c6 ket_qua_c6, bh_hd_ma_kh.loai bh_hd_ma_kh_loai, ket_qua.c32 ket_qua_c32,
                    '' bh_hd_ma_kh_ngay_ht,
                    ket_qua.c34 ket_qua_c34, bh_hd_ma_kh.cmt bh_hd_ma_kh_tax
             from   ket_qua, bh_hd_ma_kh
             where  ket_qua.c28 = bh_hd_ma_kh.ma_dvi
                    and ket_qua.c2 = bh_hd_ma_kh.ma)
    set ket_qua_c6 = nvl(bh_hd_ma_kh_loai, 'N/A'), ket_qua_c32 = bh_hd_ma_kh_ngay_ht,ket_qua_c34=bh_hd_ma_kh_tax ;
  end if;

  -- xoa nghiep vu khong theo doi
  delete ket_qua where nvl(n14, 0) = 0;
  delete ket_qua
  where  nvl(n2, 0) = 0
         and nvl(n3, 0) = 0
         and nvl(n4, 0) = 0
         and nvl(n5, 0) = 0
         and nvl(n6, 0) = 0
         and nvl(n7, 0) = 0
         and nvl(n8, 0) = 0
         and nvl(n9, 0) = 0
         and nvl(n10, 0) = 0
         and nvl(n11, 0) = 0
         and nvl(n12, 0) = 0
         and nvl(n13, 0) = 0;


  update ket_qua set c12=(select ten from bh_hd_ma_kh where ma_dvi=c27 and ma=c2);
  update ket_qua set c13=(select ten from ht_ma_cb where ma_dvi=c28 and ma=c3);
--  update
--    (select ket_qua.c13 ket_qua_c13,ht_ma_cb.ten ht_ma_cb_ten
--    from ket_qua,ht_ma_cb
--    where ket_qua.c28= ht_ma_cb.ma_dvi and KET_QUA.C3 = ht_ma_cb.ma
--    )
--    set ket_qua_c13 = ht_ma_cb_ten;
  update ket_qua set c14=(select ten from ht_ma_phong where ma_dvi=c28 and ma=c4);
--  update
--    (select ket_qua.c14 ket_qua_c14,ht_ma_phong.ten ht_ma_phong_ten
--    from ket_qua,ht_ma_phong
--    where ket_qua.c28= ht_ma_phong.ma_dvi and KET_QUA.c4 = ht_ma_phong.ma
--    )
--    set ket_qua_c14 = ht_ma_phong_ten;
    update ket_qua set c15 =c13;
  update ket_qua set c15=(select ten from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=c5);
  
--  update (select ket_qua.c15 ket_qua_c15, bh_dl_ma_kh.ten bh_dl_ma_kh_ten
--           from   ket_qua, bh_dl_ma_kh
--           where  ket_qua.c28 = bh_dl_ma_kh.ma_dvi
--                  and ket_qua.c5 = bh_dl_ma_kh.ma)
--  set    ket_qua_c15 = bh_dl_ma_kh_ten;

  update ket_qua set c16=(select ten from kh_ma_loai_dn where ma_dvi=c28 and ma=c6);
--  update
--    (select ket_qua.c16 ket_qua_c16,kh_ma_loai_dn.ten kh_ma_loai_dn_ten
--    from ket_qua,kh_ma_loai_dn
--    where ket_qua.c28= kh_ma_loai_dn.ma_dvi and KET_QUA.c6 = kh_ma_loai_dn.ma
--    )
--    set ket_qua_c16 = kh_ma_loai_dn_ten;
  update ket_qua set c17=(select ten from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=c7);
--  update
--    (select ket_qua.c17 ket_qua_c17,bh_ma_lhnv.ten bh_ma_lhnv_ten
--    from ket_qua,bh_ma_lhnv
--    where b_ma_dvi= bh_ma_lhnv.ma_dvi and KET_QUA.c7 = bh_ma_lhnv.ma
--    )
--    set ket_qua_c17 = bh_ma_lhnv_ten;

  update (select ket_qua.c12 ket_qua_c12, bh_hd_ma_kh.ten bh_hd_ma_kh_ten, ket_qua.c22 ket_qua_c22,
                  bh_hd_ma_kh.loai bh_hd_ma_kh_ma_kh
           from   ket_qua, bh_hd_ma_kh
           where  ket_qua.c27 = bh_hd_ma_kh.ma_dvi
                  and ket_qua.c2 = bh_hd_ma_kh.ma)
  set    ket_qua_c12 = bh_hd_ma_kh_ten, ket_qua_c22 = bh_hd_ma_kh_ma_kh;



  /*
  update (select ket_qua.c13 ket_qua_c13, ht_ma_cb.ten ht_ma_cb_ten
           from   ket_qua, ht_ma_cb
           where  ket_qua.c28 = ht_ma_cb.ma_dvi
                  and ket_qua.c3 = ht_ma_cb.ma)
  set    ket_qua_c13 = ht_ma_cb_ten;
  update (select ket_qua.c14 ket_qua_c14, ht_ma_phong.ten ht_ma_phong_ten
           from   ket_qua, ht_ma_phong
           where  ket_qua.c28 = ht_ma_phong.ma_dvi
                  and ket_qua.c4 = ht_ma_phong.ma)
  set    ket_qua_c14 = ht_ma_phong_ten;
  update (select ket_qua.c15 ket_qua_c15, bh_dl_ma_kh.ten bh_dl_ma_kh_ten
           from   ket_qua, bh_dl_ma_kh
           where  ket_qua.c28 = bh_dl_ma_kh.ma_dvi
                  and ket_qua.c5 = bh_dl_ma_kh.ma)
  set    ket_qua_c15 = bh_dl_ma_kh_ten;
  update (select ket_qua.c16 ket_qua_c16, kh_ma_loai_dn.ten kh_ma_loai_dn_ten
           from   ket_qua, kh_ma_loai_dn
           where  ket_qua.c28 = kh_ma_loai_dn.ma_dvi
                  and ket_qua.c6 = kh_ma_loai_dn.ma)
  set    ket_qua_c16 = kh_ma_loai_dn_ten;
  update (select ket_qua.c17 ket_qua_c17, bh_ma_lhnv.ten bh_ma_lhnv_ten
           from   ket_qua, bh_ma_lhnv
           where  ket_qua.c28 = bh_ma_lhnv.ma_dvi
                  and ket_qua.c7 = bh_ma_lhnv.ma)
  set    ket_qua_c17 = bh_ma_lhnv_ten;
  */
--update ket_qua
--  set    (c18, c10) =
--          (select nv, ma_gt
--           from   bh_hd_goc
--           where  ma_dvi = c28
--                  and so_id = n14);
merge into ket_qua
using bh_hd_goc a
on (a.so_id=n14 and a.ma_dvi=c28)
when matched then update
set c18=a.nv,c10=a.ma_gt,c36=a.kieu_hd,c29=a.nsd;
update ket_qua set c29 = case when c29 like'%$%' then 'APP' else 'BH' end;  
  update ket_qua
  set    c10 = case
                 when c10 like 'MB%' then
                  'MB'
                 when c10 like 'VTP%' then
                  'VTP'
                 when c10 like 'DK%' then
                  'DK'
               end
  where  c10 like 'MB%'
         or c10 like 'VTP%'
         or c10 like 'DK%';
         
  if b_ma_nv like 'CN%' or b_ma_nv like 'NG%' then
  merge into ket_qua using  (select sum(nvl(tien,0))tien, max(nt_tien)nt_tien,ma_dvi,so_id,substr(lh_nv,0,6)lh_nv from bh_nguoihd_dk group by ma_dvi,so_id,substr(lh_nv,0,6))a
    on ( a.ma_dvi=c28 and a.so_id=n14 and a.lh_nv=c7 )
    when matched then update
    set n31=nvl(tien,1),c30=nvl(nt_tien,1) where c7 like 'CN%' ;
    end if;
--                                                                        LAM SACH
  --BCNam bo sung cot tien bao  hiem, enable khi Ban nghiep vu can
--   if b_ma_nv like 'TS%' or b_ma_nv like 'HP%' then

--     update ket_qua set (n31, c30) = (select sum(tien), max(nt_tien) from  bh_phhgcn_dk
--              where  ma_dvi = c28 /*and lh_nv=c7*/
--              and so_id = n14)
--             where  c7 like 'TS%';
--     update ket_qua set (n31, c30) = (select sum(tien), max(nt_tien) from bh_phhgcn_dk
--              where  ma_dvi = c28 and lh_nv = c7 and so_id = n14)
--             where  c7 like 'HP%';
--     update ket_qua set c31 = (select lvuc_kd from bh_phhgcn where ma_dvi = c28 and so_id = n14 and rownum = 1)
--         where  c7 like 'TS.%';
--   end if;
--   if b_ma_nv like 'NL%' then
--     update ket_qua
--     set    (n31, c30) =
--             (select sum(tien), max(nt_tien)
--              from   bh_taugcn_dk
--              where  ma_dvi = c28
--                     and so_id = n14
--                     and lh_nv = c7)
--     where c7 like 'NL%' and c18='TAU';
--     update ket_qua
--     set    (n31, c30) =
--             (select sum(tien), max(nt_tien)
--              from   bh_taulgcn_dk
--              where  ma_dvi = c28
--                     and so_id = n14
--                     and lh_nv = c7)
--     where c7 like 'NL%'
--            and n30 <= 1 and c18='TAUL';
--   end if;
--   if b_ma_nv like 'HK%' then
--     merge into ket_qua using  (select sum(tien)tien, max(nt_tien)nt_tien,ma_dvi,so_id,lh_nv from bh_taugcn_dk group by ma_dvi,so_id,lh_nv)a
--     on ( a.ma_dvi=c28 and a.so_id=n14 and a.lh_nv=c7 )
--     when matched then update
--     set n31=nvl(tien,1),c30=nvl(nt_tien,1) where c7 like 'HK%' and c18='TAU';
--     update ket_qua set (n31, c30) =(select sum(tien), max(nt_tien) from bh_taulgcn_dk
--     where ma_dvi=c28 and so_id=n14 and lh_nv=c7) where c7 like 'HK%'and n30 <= 1 and c18='TAUL';
--   end if;
--    if b_ma_nv like 'KT%' then
--     update ket_qua
--     set    (n31, c30) =
--             (select sum(tien), max(nt_tien)
--              from   bh_pktgcn_dk
--              where  ma_dvi = c28
--                     and lh_nv = c7
--                     and so_id = n14)
--     where  c7 like 'KT%';
--     update ket_qua
--     set    c31 =
--             (select lvuc_kd
--              from   bh_pktgcn
--              where  ma_dvi = c28
--                     and so_id = n14
--                     and rownum = 1)
--     where  c7 like 'KT.%';
--   end if;
--   if b_ma_nv like 'TN%' then
--     update ket_qua
--     set    (n31, c30) =
--             (select sum(tien), max(nt_tien)
--              from   bh_ptngcn_dk
--              where  ma_dvi = c28
--                     and lh_nv = c7
--                     and so_id = n14)
--     where  c7 like 'TN%';
--     update ket_qua
--     set    c31 =
--             (select lvuc_kd
--              from   bh_ptngcn
--              where  ma_dvi = c28
--                     and so_id = n14
--                     and rownum = 1)
--     where  c7 like 'TN.%';
--   end if;
--   if b_ma_nv like 'XG%' then
--     update ket_qua
--     set    (n31, c30) =
--             (select sum(tien), max(nt_tien)
--              from   bh_xegcn_dk
--              where  ma_dvi = c28
--                     and so_id = n14
--                     and lh_nv = c7)
--     where  c7 like 'XG.2%';
--     update ket_qua
--     set    (n31, c30) =
--             (select sum(tien), max(nt_tien)
--              from   bh_xelgcn_dk
--              where  ma_dvi = c28
--                     and so_id = n14
--                     and lh_nv = c7)
--     where  c7 like 'XG.2%'
--            and n31 is null;
--     update ket_qua
--     set    (c19) =
--             (select to_char(ngay_nh, 'dd/mm/yyyy')
--              from   bh_xehdgoc
--              where  ma_dvi = c28
--                     and so_id = n14)
--     where  c18 = 'XE';
--     update ket_qua
--     set    (c19) =
--             (select to_char(ngay_nh, 'dd/mm/yyyy')
--              from   bh_xelgcn
--              where  ma_dvi = c28
--                     and so_id = n14)
--     where  c18 = 'XEL';
--     update ket_qua
--     set    (c19) =
--             (select to_char(ngay_nh, 'dd/mm/yyyy')
--              from   bh_2bhdgoc
--              where  ma_dvi = c28
--                     and so_id = n14)
--     where  c18 = '2B';
--   end if;
--                                                                  END LAM SACH


--  update ket_qua
--  set    n29 =
--          (select 100 - sum(pt)
--           from   bh_hd_do_tl
--           where  ma_dvi = c28
--                  and so_id = n14
--                  and pthuc = 'C'
--                  and lh_nv = c7
--                  and kieu = 'D');
  --record dong it
    merge into ket_qua
    using  (select (100 - sum(t.pt) )as sum_pt,t.ma_dvi,t.so_id,t.lh_nv  from bh_hd_do_tl t, bh_hd_do t1  where t.ma_dvi=t1.ma_dvi and t.so_id=t1.so_id and t.pthuc = 'C'  and t1.kieu = 'D'
           group by t.ma_dvi,t.so_id,t.lh_nv) dong
    on(dong.ma_dvi = ket_qua.c28 and dong.so_id=ket_qua.n14 and dong.lh_nv = ket_qua.c7)
    when MATCHED then update
    set ket_qua.n29 = dong.sum_pt;
    merge into ket_qua
    using  (select (sum(t.pt) )as sum_pt,t.ma_dvi,t.so_id,t.lh_nv  from   bh_hd_do_tl t, bh_hd_do t1  where t.ma_dvi=t1.ma_dvi and t.so_id=t1.so_id and t.pthuc = 'C'  and t1.kieu = 'V'
           group by t.ma_dvi,t.so_id,t.lh_nv)dong
    on(dong.ma_dvi = ket_qua.c28 and dong.so_id=ket_qua.n14 and dong.lh_nv = ket_qua.c7)
    when MATCHED then update
    set ket_qua.n29 = dong.sum_pt
    where  n29 = 0 or n29 is null;
    
  update ket_qua
  set    (c11, c23, c24, c25,C37,C38) =
          (select kieu_kt,
                  PKH_SO_CNG(ngay_cap), PKH_SO_CNG(ngay_hl),PKH_SO_CNG(ngay_KT),MA_GT,MA_KT
           from   bh_hd_goc
           where  ma_dvi = c28
                  and so_id = n14);
  update ket_qua
  set    c26 =
          (select MAX(PKH_SO_CNG(ngay_ht))
           from   bh_hd_goc_ttpt
           where  ma_dvi = c28
                  and so_id = n14
                  and pt <> 'C');
  -- LAM SACH
--   merge into ket_qua

--   using (select min(ten)ten,ma_dvi,ma from kh_ma_nhang group by ma_dvi,ma) a
--   on (a.ma_dvi=c27 and a.ma = c10)
--   when matched then update set
--   c35 = a.ten;
-- END LAM SACH
  commit;
--  merge into ket_qua using bh_dly_kvuc a on (c27=a.ma_dvi) when matched then update set c39=a.ma_kv;
  if b_ma_dvi is not null then
      select ten into b_dvi from ht_ma_dvi where ma=b_ma_dvi;
    else b_dvi:=' ';
    end if;
    if b_ma_nv is not null then
        select ten into b_tennv from bh_ma_lhnv where ma_dvi=b_madvi and ma=b_ma_nv;
    else b_tennv:=' ';
    end if;
    if b_phong is not null then
        select ten into b_ten_phong from ht_ma_phong where ma_dvi=b_madvi and ma=b_phong;
    else
        b_phong_nsd := FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
--         b_ten_phong := FHT_MA_PHONG_TEN(b_ma_dvi,b_phong_nsd); LAM SACH
        b_phong_nsd := null;
    end if;
    b_ten_nsd:= FHT_MA_NSD_TEN(b_ma_dvi,b_nsd);
    b_ngay_bc := UNISTR(' - T\1eeb ng\00e0y') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ng\00e0y') || PKH_SO_CNG(b_ngayc);
    b_ngay_tao := UNISTR('\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
        || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
    
    delete temp_1; commit;
    insert into temp_1 (c1,c2,c12,n2,n4,n6,n8,n10,n12)
    select c1,c2,c12,Sum(t.n2),Sum(t.n4),Sum(t.n6),Sum(t.n8),Sum(t.n10),Sum(t.n12)
        from (select c1, c2, c12, nvl(n2,0) n2, nvl(n4,0) n4, nvl(n6,0) n6, nvl(n8,0) n8, nvl(n10,0) n10, nvl(n12,0) n12
            from ket_qua where (instr1(c6, b_loai_khang) > 0 or b_loai_khang is null)) t
    group by t.c1,t.c2,t.c12;

    update temp_1 t set (c40, n40) = (select to_char(rn), rn
    from (select rowid rid, row_number() over (order by c1,c2) rn from temp_1) x where x.rid = t.rowid);
    insert into temp_1 (c40,c1,c2,c12,n2,n4,n6,n8,n10,n12,n40) select UNISTR('T\1ed4NG'), '','','',
    nvl(sum(n2),0),nvl(sum(n4),0),nvl(sum(n6),0),nvl(sum(n8),0),nvl(sum(n10),0),nvl(sum(n12),0),nvl(max(n40)+1,0) from temp_1
    where (instr1(c6, b_loai_khang) > 0 or b_loai_khang is null);

    select JSON_ARRAYAGG(json_object('STT' value c40,'MA_KH' value c2,'TEN_KH' value c12,'SHD' value c1,'DTPS' value FBH_CSO_TIEN(nvl(n2,0),''), 
    'LKPS' value FBH_CSO_TIEN(nvl(n4,0),''),'DTBH' value FBH_CSO_TIEN(nvl(n6,0),''), 'LKBH' value FBH_CSO_TIEN(nvl(n8,0),''),
    'DTTT' value FBH_CSO_TIEN(nvl(n10,0),''), 'LKTT' value FBH_CSO_TIEN(nvl(n12,0),'')) order by n40 returning clob) 
        into dt_ds from temp_1;
    select json_object('TEN1' value b_dvi, 'TEN2' value b_ten_phong, 'TEN3' value b_ngay_bc, 'TEN4' value b_ngay_tao, 'TEN5' value b_ten_nsd)
        into dt_ct from dual;
    select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds returning clob) into b_oraOut from dual;
    delete temp_1;delete temp_2;delete ket_qua; commit;

exception when others then raise_application_error(-20105, b_loi);
end;
/

create or replace procedure BC_BH_KETQUA_HD_THANG
    (dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_thang number :=FKH_JS_GTRIn(b_oraIn,'ngayd');
    b_thangD number; b_thangC number :=FKH_JS_GTRIn(b_oraIn,'ngayc'); b_thangNT number;
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_ngay_bc varchar2(100);b_ten_dvi varchar2(500); b_ngayB date;
    dt_ct clob;dt_ds_bt clob;dt_ds_dt clob;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
--ASCIISTR(N'Tên doanh nghiệp bảo hiểm')
b_ten_dvi := UNISTR(' - T\00ean doanh nghi\1ec7p b\1ea3o hi\1ec3m: ') || FHT_MA_DVI_TEN(b_ma_dvi);
b_ngay_bc := UNISTR(' - B\00e1o c\00e1o qu\00fd: T\1eeb ') || PKH_SO_CNG(b_thang) || UNISTR(' \0111\1ebfn ') || PKH_SO_CNG(b_thangC);
b_thang := trunc(b_thang,-2)+01;
b_thangNT:=b_thang-10000;
delete temp_1;
if b_thang is null or b_thangC is null or b_thang > b_thangC then
      b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngayB:=PKH_SO_CDT(trunc(b_thang,-4)+101);
/*temp_1 n1-xep,c1-ma,c2-ten,c3-lvl,c4-ma_ct,c5-xep_ktu,
n2-phiGp_tk,n3-phiGp_lk,n4-phiGP_tk_nt,n5-phiGP_lk_nt,c6-tl_PhiGP_tk,c7-tl_PHIGP_lk,
n6-tienCP_tk,n7-tienCP_lk,n8-tienCP_tk_nt,n9-tienCP_lk_nt,c8-tl_tienCP_tk,c9-tl_tienCP_lk,
*/
insert into temp_1 (n1,c1,c2,c3,c4,n2,n3,n4,n5,n6,n7,n8,n9)
select row_number() over(order by ord) as stt, lpad(' ',(lvl-1)*2) || case when lvl <= 3 then ma else '-' || ma end, ten, lvl, ma_ct, 0,0,0,0,0,0,0,0
from ( select level lvl, ma, ten, rownum ord, ma_ct
    from bh_ma_lhnv_bo start with ma_ct = ' ' connect by prior ma = ma_ct order siblings by ma);
 /*--sort xep theo cap va ma
 update temp_1 t set c5 = (select to_nchar(chr(64 + x.rn))
     from ( select n1, row_number() over(partition by c3 order by n1) rn
         from temp_1 where c3 = 1) x
     where x.n1 = t.n1) where t.c3 = 1;
 update temp_1 t set c5 =(select to_nchar(x.rn) from ( select n1, row_number() over(partition by c4 order by n1) rn
     from temp_1 where c3 = 2) x where x.n1 = t.n1) where t.c3 = 2;
 update temp_1 t set c5 = ' ',c2 =( select p.c5 || to_nchar(chr(96 + x.rn) || '.' || t.c2)
     from( select n1, c4, row_number() over(partition by c4 order by n1) rn from temp_1 where c3 = 3) x join temp_1 p on trim(p.c1) = trim(x.c4)
     where x.n1 = t.n1)
 where t.c3 = 3;
 update temp_1 t set c5='', c2 = (select to_nchar(lpad('-', x.c3 - 3, '-') || ' ' || t.c2)
     from ( select n1, c3 from temp_1 where c3 >= 4) x
   where x.n1 = t.n1) where t.c3 >= 4;*/

-- du lieu
-- doanh thu ps trong ky (1)
update temp_1 p set n2=(select sum(nvl(t.PHIGP,0)) from sli_dt_th_lh t where t.thang=b_thang and trim(upper(t.lh_bo)) = trim(upper(p.c1)));

b_thangC:=b_thang; b_thangD:=trunc(PKH_NG_CSO(b_ngayB),-4)+101; 

update temp_1 p set n3=(select sum(nvl(t.PHIGP,0)) from sli_dt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

b_thangD:=trunc(PKH_NG_CSO(b_ngayB),-4)+101-10000; b_thangC:=trunc(PKH_NG_CSO(b_ngayB),-4)+1201-10000;

update temp_1 p set n4=(select sum(nvl(t.PHIGP,0)) from sli_dt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang = b_thangNT);

update temp_1 p set n5=(select sum(nvl(t.PHIGP,0)) from sli_dt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

update temp_1 p set (n2,n3,n4,n5) = ( 
    select sum(nvl(c.n2,0)), sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0))
    from temp_1 c start with trim(upper(c.c4)) = trim(upper(p.c1)) connect by nocycle prior trim(upper(c.c1)) = trim(upper(c.c4)))
where exists ( select 1 from temp_1 c where trim(upper(c.c4)) = trim(upper(p.c1)));

-- boi thuong ps trong ky (2)

update temp_1 p set n6=(select sum(nvl(t.tienCP,0)) from sli_bt_th_lh t where t.thang=b_thang and trim(upper(t.lh_bo)) = trim(upper(p.c1)));

b_thangC:=b_thang; b_thangD:=trunc(PKH_NG_CSO(b_ngayB),-4)+101; 

update temp_1 p set n7=(select sum(nvl(t.tienCP,0)) from sli_bt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

b_thangD:=trunc(PKH_NG_CSO(b_ngayB),-4)+101-10000; b_thangC:=trunc(PKH_NG_CSO(b_ngayB),-4)+1201-10000;

update temp_1 p set n8=(select sum(nvl(t.tienCP,0)) from sli_bt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang= b_thangNT);

update temp_1 p set n9=(select sum(nvl(t.tienCP,0)) from sli_bt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

update temp_1 p set (n6,n7,n8,n9) = ( 
    select sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), sum(nvl(c.n8,0)), sum(nvl(c.n9,0))
    from temp_1 c start with trim(upper(c.c4)) = trim(upper(p.c1)) connect by nocycle prior trim(upper(c.c1)) = trim(upper(c.c4)))
where exists ( select 1 from temp_1 c where trim(upper(c.c4)) = trim(upper(p.c1)));
-- sort

insert into temp_1(n1,c5,c2,c3,c4,c1,n2,n3,n4,n5) 
  select 0,  ' ',N'DOANH THU PHÍ BẢO HIỂM', '0', ' ', 'I.', sum(nvl(c.n2,0)), sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0))
  from temp_1 c where c.c1 <> 'I.' and c.c3 = '1';

insert into temp_1(n1,c5,c2,c3,c4,c1,n6,n7,n8,n9) 
  select 0,  ' ',N'BỒI THƯỜNG BẢO HIỂM GỐC', '0', ' ', 'II.', sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), sum(nvl(c.n8,0)), sum(nvl(c.n9,0))
  from temp_1 c where c.c1 <> 'II.' and c.c3 = '1';

-- ty le so sanh nam trc cho doanh thu 
update temp_1 set c6 = round(n4 / nullif(n2,0) * 100,2) || '%';
update temp_1 set c7 = round(n5 / nullif(n3,0) * 100,2) || '%';
-- ty le so sanh nam truoc cho boi thuong
update temp_1 set c8 = round(n8 / nullif(n6,0) * 100,2) || '%';
update temp_1 set c9 = round(n9 / nullif(n7,0) * 100,2) || '%';

update temp_1 set c1 = ' ', c2 =(c1 || '.' || c2) where c3 = 3;
update temp_1 t set c1='', c2 = (select to_nchar(lpad('-', x.c3 - 3, '-') || ' ' || t.c1 || '.' || t.c2)
     from ( select n1, c3 from temp_1 where c3 >= 4) x
   where x.n1 = t.n1) where t.c3 >= 4;

select json_arrayagg(json_object('STT' value c1,'TENNV' value c2,'PHIGPT' value FBH_CSO_TIEN(nvl(n2,0),' '),'PHIGPLK' value FBH_CSO_TIEN(nvl(n3,0),' '),
    'TL_PHIGPT' value c6, 'TL_TIENLK' value c7,'BAC' value c3 ) order by n1 returning clob) into dt_ds_dt from temp_1 where nvl(c1,' ') <> 'II.';
select json_arrayagg(json_object('STT' value c1,'TENNV' value c2,'PHIGPT' value FBH_CSO_TIEN(nvl(n6,0),' '),'PHIGPLK' value FBH_CSO_TIEN(nvl(n7,0),' '),
    'TL_PHIGPT' value c8, 'TL_TIENLK' value c9,'BAC' value c3 ) order by n1 returning clob) into dt_ds_bt from temp_1 where nvl(c1,' ') <> 'I.';
select json_object('ten_dvi' value b_ten_dvi, 'ngay_bc' value b_ngay_bc) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds_dt' value dt_ds_dt,'dt_ds_bt' value dt_ds_bt returning clob) into b_oraOut from dual;

delete temp_1; commit;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure BC_BH_BT_BAOHIEM
    (dk_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_lenh varchar2(1000); b_loi varchar2(100); b_i1 number; b_ngayd number :=FKH_JS_GTRIn(b_oraIn,'ngayd'); b_ngayc number :=FKH_JS_GTRIn(b_oraIn,'ngayc');
    b_thangD number := trunc(b_ngayd,-2)+01; b_thangC number := trunc(b_ngayc,-2)+01;
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');b_tkvuc varchar2(500);
    b_ngay_bc varchar2(100);b_ten_dvi varchar2(500); b_ngayB date;
    dt_ct clob;dt_ts clob;dt_ds clob;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),dk_ma_dviN);
--ASCIISTR(N'Tên doanh nghiệp bảo hiểm')
b_ten_dvi := UNISTR(' - T\00ean doanh nghi\1ec7p b\1ea3o hi\1ec3m: ') || FHT_MA_DVI_TEN(b_ma_dvi);
b_ngay_bc := UNISTR(' - B\00e1o c\00e1o qu\00fd: T\1eeb ') || PKH_SO_CNG(b_ngayd) || UNISTR(' \0111\1ebfn ') || PKH_SO_CNG(b_ngayc);
b_tkvuc := FHT_MA_DVI_TEN_KVUC(b_ma_dvi) || UNISTR(',\004E\0067\00E0\0079 ') || to_char(sysdate,'DD') || UNISTR(' \0074\0068\00E1\006E\0067 ') || to_char(sysdate,'MM') 
    || UNISTR(' \006E\0103\006D ') || to_char(sysdate,'YYYY');
delete temp_1;
if b_ngayd is null or b_ngayc is null or b_ngayd > b_ngayc then
      b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngayB:=PKH_SO_CDT(trunc(b_ngayd,-4)+101);
/*temp_1 n1-xep,c1-ma,c2-ten,c3-lvl,c4-ma_ct,c5-xep_ktu,
n3-tienCP,n4-ta_diTP,n5-ta_diNP,n6-ta_veTP,n7-ta_veNP,n8-tienGK ,n9=n3-n4-n5+n6+n7-n8,n10- 
*/
insert into temp_1 (n1,c1,c2,c3,c4,n3,n4,n5,n6,n7,n8,n9,n10)
select row_number() over(order by ord) as stt, lpad(' ',(lvl-1)*2) || case when lvl <= 3 then ma else '-' || ma end, ten, lvl, ma_ct, 0,0,0,0,0,0,0,0
from ( select level lvl, ma, ten, rownum ord, ma_ct
    from bh_ma_lhnv_bo start with ma_ct = ' ' connect by prior ma = ma_ct order siblings by ma);

-- boi thuong ps trong ky (1)
update temp_1 p set (n3,n4,n5,n6,n7,n8)=(
    select sum(nvl(t.tienCP,0)), sum(nvl(t.ta_diTP,0)), sum(nvl(t.ta_diNP,0)), sum(nvl(t.ta_veTP,0)), sum(nvl(t.ta_veNP,0)), sum(nvl(t.tienGK,0))
    from sli_bt_th_lh t where trim(upper(t.lh_bo)) = trim(upper(p.c1)) and t.thang between b_thangD and b_thangC);

update temp_1 p set n10 = (select round(nvl(sum(t.phicp),0) / 100)
    from sli_dt_th_lh t where t.lh_bo = p.c1 and t.thang between b_thangD and b_thangC);

update temp_1 set n9 = ( nvl(n3,0)) - nvl(n4,0) -nvl(n5,0) + nvl(n6,0) + nvl(n7,0) - nvl(n8,0);

update temp_1 p set (n3,n4,n5,n6,n7,n8,n9,n10) = ( 
    select sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0)), sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), 
        sum(nvl(c.n8,0)), sum(nvl(c.n9,0)), sum(nvl(c.n10,0))
    from temp_1 c start with trim(upper(c.c4)) = trim(upper(p.c1)) connect by nocycle prior trim(upper(c.c1)) = trim(upper(c.c4)))
where exists ( select 1 from temp_1 c where trim(upper(c.c4)) = trim(upper(p.c1)));

insert into temp_1(n1,c5,c2,c3,c4,c1,n3,n4,n5,n6,n7,n8,n9,n10) 
  select 0, ' ','', '0', ' ', 'I.', sum(nvl(c.n3,0)), sum(nvl(c.n4,0)), sum(nvl(c.n5,0)), sum(nvl(c.n6,0)), sum(nvl(c.n7,0)), 
    sum(nvl(c.n8,0)), sum(nvl(c.n9,0)), sum(nvl(c.n10,0))
  from temp_1 c where c.c1 <> 'I.' and c.c3 = '1';

update temp_1 set c3 ='0' where c3 = '1';
update temp_1 set n3 = round(n3 / 1000000), n4 = round(n4 / 1000000),n5 = round(n5 / 1000000),n6 = round(n6 / 1000000),
    n7 = round(n7 / 1000000), n8 = round(n8 / 1000000), n9 = round(n9 / 1000000), n10 = round(n10 / 1000000);
--sort xep theo cap va ma
update temp_1 set c1 = ' ', c2 =(c1 || '.' || c2) where c3 = 3;
update temp_1 t set c1='', c2 = (select to_nchar(lpad('-', x.c3 - 3, '-') || ' ' || t.c1 || '.' || t.c2)
     from ( select n1, c3 from temp_1 where c3 >= 4) x
   where x.n1 = t.n1) where t.c3 >= 4;
select json_arrayagg(json_object('STT' value c1,'NVU' value c2,'N3' value FBH_CSO_TIEN(nvl(n3,0),''),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),''),'N5' value FBH_CSO_TIEN(nvl(n5,0),''),'N6' value FBH_CSO_TIEN(nvl(n6,0),''),
    'N7' value FBH_CSO_TIEN(nvl(n7,0),''),'N8' value FBH_CSO_TIEN(nvl(n8,0),''),'N9' value FBH_CSO_TIEN(nvl(n9,0),''),
    'N10' value FBH_CSO_TIEN(nvl(n10,0),''), 'BAC' value c3 ) order by n1 returning clob) into dt_ds from temp_1 where nvl(c1,' ') <> 'I.';
select json_arrayagg(json_object('STT' value c1,'NVU' value c2,'N3' value FBH_CSO_TIEN(nvl(n3,0),''),
    'N4' value FBH_CSO_TIEN(nvl(n4,0),''),'N5' value FBH_CSO_TIEN(nvl(n5,0),''),'N6' value FBH_CSO_TIEN(nvl(n6,0),''),
    'N7' value FBH_CSO_TIEN(nvl(n7,0),''),'N8' value FBH_CSO_TIEN(nvl(n8,0),''),'N9' value FBH_CSO_TIEN(nvl(n9,0),''),
    'N10' value FBH_CSO_TIEN(nvl(n10,0),''), 'BAC' value c3 ) order by n1 returning clob) into dt_ts from temp_1 where nvl(c1,' ') = 'I.';
select json_object('ten_dvi' value b_ten_dvi, 'ngaybc' value b_ngay_bc, 'ngay_tbc' value b_tkvuc) into dt_ct from dual;
select json_object('dt_ct' value dt_ct,'dt_ds' value dt_ds,'dt_ts' value dt_ts returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHT_MA_DVI_TEN_KVUC(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200); b_ma_kvuc varchar2(10);
begin
-- annd
select min(kvuc) into b_ma_kvuc from ht_ma_dvi where ma=b_ma;
select min(ten) into b_kq from bh_ma_kvuc where ma=b_ma_kvuc;
return b_kq;
end;
/