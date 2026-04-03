CREATE OR REPLACE PROCEDURE BC_BH_TNDS_XECG_MD
    (B_MADVI VARCHAR2,B_MA_DVI VARCHAR2,B_NV VARCHAR2,B_NGAYD NUMBER,B_NGAYC NUMBER,B_LOI OUT VARCHAR2)
AS
   B_GHI_CHU NVARCHAR2(200);
BEGIN

IF B_NGAYD IS NULL OR B_NGAYC IS NULL THEN
    B_LOI:='loi:Nhap ngay bao cao:loi'; RETURN;
END IF;





DELETE TEMP_1; DELETE TEMP_6;
--LAM SACH
-- IF B_NV='XE' THEN
--     INSERT INTO TEMP_1(C1,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,N1,N2,N3,N4,N5,N6,C31)
--         SELECT  A.MA_DVI,A.GCN,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,TO_CHAR(NGAY_HL,'ddmmyyyy'),TO_CHAR(NGAY_KT,'ddmmyyyy'),
--             A.MD_SD,A.TEN,A.DCHI,TO_CHAR(NGAY_CAP,'ddmmyyyy'),A.SO_ID,A.SO_ID_DT,A.SO_CN,A.TTAI,A.NAM_SX,SUM(A.TTOAN),'XE'
--             FROM BH_XEGCN A,BH_XEHDGOC_DK B  WHERE A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID
--             AND (B_MA_DVI IS NULL OR A.MA_DVI = B_MA_DVI) AND (B.NGAY_HT BETWEEN B_NGAYD AND B_NGAYC)
--             GROUP BY A.MA_DVI,A.GCN,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,NGAY_HL,NGAY_KT,
--             A.MD_SD,A.TEN,A.DCHI,NGAY_CAP,A.SO_ID,A.SO_ID_DT,A.SO_CN,A.TTAI,A.NAM_SX;
--     INSERT INTO TEMP_1(C1,C3,C4,C5,C6,C7,C8,C9,C10,C11,C12,C13,C14,C15,N1,N2,N3,N4,N5,N6,C31)
--         SELECT  A.MA_DVI,A.SO_HD,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,TO_CHAR(NGAY_HL,'ddmmyyyy'),TO_CHAR(NGAY_KT,'ddmmyyyy'),
--             A.MD_SD,A.TEN,A.DCHI,TO_CHAR(NGAY_CAP,'ddmmyyyy'),A.SO_ID,0,A.SO_CN,A.TTAI,A.NAM_SX,SUM(A.TTOAN),'XEL'
--             FROM BH_XELGCN A,BH_XELGCN_DK B  WHERE A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID
--             AND (B_MA_DVI IS NULL OR A.MA_DVI = B_MA_DVI) AND (B.NGAY_HT BETWEEN B_NGAYD AND B_NGAYC)
--             GROUP BY A.MA_DVI,A.SO_HD,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,NGAY_HL,NGAY_KT,
--             A.MD_SD,A.TEN,A.DCHI,NGAY_CAP,A.SO_ID,A.SO_CN,A.TTAI,A.NAM_SX;
-- ELSIF B_NV='2B' THEN
--     INSERT INTO TEMP_1(C1,C3,C4,C5,C6,C7,C8,C9,C10,C11,C13,C14,C15,N1,N2,N6,C31)
--         SELECT  A.MA_DVI,A.GCN,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,TO_CHAR(NGAY_HL,'ddmmyyyy'),TO_CHAR(NGAY_KT,'ddmmyyyy'),
--             A.TEN,A.DCHI,TO_CHAR(NGAY_CAP,'ddmmyyyy'),A.SO_ID,A.SO_ID_DT,SUM(A.TTOAN),'2B'
--             FROM BH_2BGCN A,BH_2B_HDGOC_DK B  WHERE A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID
--             AND (B_MA_DVI IS NULL OR A.MA_DVI = B_MA_DVI) AND (B.NGAY_HT BETWEEN B_NGAYD AND B_NGAYC)
--             GROUP BY A.MA_DVI,A.GCN,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,NGAY_HL,NGAY_KT,
--             A.TEN,A.DCHI,NGAY_CAP,A.SO_ID,A.SO_ID_DT;
--     INSERT INTO TEMP_1(C1,C3,C4,C5,C6,C7,C8,C9,C10,C11,C13,C14,C15,N1,N2,N6,C31)
--         SELECT  A.MA_DVI,A.SO_HD,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,TO_CHAR(NGAY_HL,'ddmmyyyy'),TO_CHAR(NGAY_KT,'ddmmyyyy'),
--             A.TEN,A.DCHI,TO_CHAR(NGAY_CAP,'ddmmyyyy'),A.SO_ID,0,SUM(A.TTOAN),'XEL'
--             FROM BH_2BLGCN A,BH_2BLGCN_DK B  WHERE A.MA_DVI=B.MA_DVI AND A.SO_ID=B.SO_ID
--             AND (B_MA_DVI IS NULL OR A.MA_DVI = B_MA_DVI) AND (B.NGAY_HT BETWEEN B_NGAYD AND B_NGAYC)
--             GROUP BY A.MA_DVI,A.SO_HD,A.BIEN_XE,A.SO_KHUNG,A.SO_MAY,A.LOAI_XE,A.HANG_XE,A.HIEU_XE,NGAY_HL,NGAY_KT,
--             A.TEN,A.DCHI,NGAY_CAP,A.SO_ID;
-- END IF;
/*UPDATE TEMP_1 SET (C2,C30,N30,C17,C18,C19 )=(SELECT SO_HD,KIEU_HD,SO_ID_G,MA_KH,PHONG,ma_cb  FROM bh_xehdgoc WHERE MA_DVI=C1 AND SO_ID=N1
    AND (NGAY_HT BETWEEN B_NGAYD AND B_NGAYC));*/

UPDATE TEMP_1 SET (C2,C30,N30,C17,C18,C19,c21,c22,c24)=(SELECT SO_HD,KIEU_HD,SO_ID_G,MA_KH,PHONG,cb_ql,ma_kt,ma_gt,nsd FROM bh_hd_goc WHERE MA_DVI=C1 AND SO_ID=N1
    AND (NGAY_HT BETWEEN B_NGAYD AND B_NGAYC));


B_LOI:='';
EXCEPTION WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20105,B_LOI);
END;

/
CREATE OR REPLACE PROCEDURE PBH_BC_KH_DT
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,cs out pht_type.cs_type,
    b_ma_dvi varchar2,b_phong varchar2,b_nv varchar2,b_ma_kh varchar2,b_so_hd varchar2,b_uoc varchar2,
    b_kieu_bc varchar2,b_ngayd number,b_ngayc number,b_ngayd_hd number,b_ngayc_hd number)
AS
    b_loi varchar2(100);
Begin
/*
    Hung do tu ban cerp.vn/micbh2013
    Da luu sang thu tuc PBH_BC_KH_DT_HUNG_LUU_14_07_21
*/
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
--b_loi:='loi:BCNam:loi';
if b_loi is not null then raise PROGRAM_ERROR; end if;
--delete temp_2;delete temp_1;delete temp_3;commit;
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_1';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_2';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_3';

delete temp_bc_ts;
insert into temp_bc_ts values (b_ma_dvi||'%',b_ngayd,b_ngayc);
--doanh thu phat sinh trong ky
if b_kieu_bc='PS' or b_kieu_bc='T' then
    /*
    insert into temp_2 (c1,c2,c3,c4,c6,c7,n1,n4,n7)
        select ma_dvi,phong,lh_nv,nv,'',ma_kh,sum(phi),so_id,max(ngay_htnv)
            from V_BC_BH_DTPS_MM
            where (b_phong is null or phong=b_phong)
                and (b_so_hd is null or so_hd=b_so_hd) and (b_nv is null or lh_nv like b_nv||'%')
                and (b_ma_kh is null or ma_kh=b_ma_kh)
            group by ma_dvi,phong,lh_nv,nv,so_id,ma_kh;
    */
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTPS_MM';
    BC_BH_LAY_BC_BH_DTPS_MM(b_ma_dvi,b_ngayd,b_ngayc);
    insert into temp_2 (c1,c2,c3,c4,c6,c7,n1,n4,n7)
        select ma_dvi,phong,lh_nv,nv,'',ma_kh,sum(phi),so_id,max(ngay_htnv)
            from TEMP_BC_BH_DTPS_MM
            where (b_phong is null or phong=b_phong)
                and (b_so_hd is null or so_hd=b_so_hd) and (b_nv is null or lh_nv like b_nv||'%')
                and (b_ma_kh is null or ma_kh=b_ma_kh)
            group by ma_dvi,phong,lh_nv,nv,so_id,ma_kh;
end if;
--Doanh thu ban hang trong ky
if b_kieu_bc='BH' or b_kieu_bc='T' then
    /*
    insert into temp_2 (c1,c2,c3,c4,c6,c7,n1,n4,n7)
        select ma_dvi,phong,lh_nv,nv,ma_dvig,ma_kh,sum(phi),so_id,max(ngay_htnv)
            from V_BC_BH_DTBH_MM
            where (b_phong is null or phong=b_phong)
                and (b_so_hd is null or so_hd=b_so_hd) and (b_nv is null or lh_nv like b_nv||'%')
                and (b_ma_kh is null or ma_kh=b_ma_kh)
            group by ma_dvi,phong,lh_nv,nv,ma_dvig,ma_kh,so_id;
    */
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTBH_MM';
    BC_BH_LAY_BC_BH_DTBH_MM(b_ma_dvi,b_ngayd,b_ngayc);
    insert into temp_2 (c1,c2,c3,c4,c6,c7,n1,n4,n7)
        select ma_dvi,phong,lh_nv,nv,ma_dvig,ma_kh,sum(phi),so_id,max(ngay_htnv)
            from TEMP_BC_BH_DTBH_MM
            where (b_phong is null or phong=b_phong)
                and (b_so_hd is null or so_hd=b_so_hd) and (b_nv is null or lh_nv like b_nv||'%')
                and (b_ma_kh is null or ma_kh=b_ma_kh)
            group by ma_dvi,phong,lh_nv,nv,ma_dvig,ma_kh,so_id;
end if;
--Doanh thu thuc thu trong ky
if b_kieu_bc='TT' or b_kieu_bc='T' then
    /*
    insert into temp_3(c29,c28,c7,c6,c4,n10,n11,n12,n2)
        select ma_dvi,ma_dvig,lh_nv,phong,nv,so_id,ngay,ngay_htnv,sum(phi)
            from V_BC_BH_DTTT_MA_DT where (b_ma_dvi is null or ma_dvi=b_ma_dvi)
                and ngay_htbs between b_ngayd and b_ngayc and (b_nv is null or lh_nv like b_nv||'%')
                and (b_ma_dvi is null or ma_dvi=b_ma_dvi) and (b_phong is null or phong=b_phong)
                and (b_so_hd is null or so_hd=b_so_hd) and (b_ma_kh is null or ma_kh=b_ma_kh)
            group by ma_dvi,ma_dvig,lh_nv,phong,nv,so_id,ngay,ngay_htnv;
     */
    EXECUTE IMMEDIATE 'TRUNCATE TABLE TEMP_BC_BH_DTTT_MA_DT';
    BC_BH_LAY_BC_BH_DTTT_MA_DT(b_ma_dvi,b_ngayd,b_ngayc);
    insert into temp_3(c29,c28,c7,c6,c4,n10,n11,n12,n2)
        select ma_dvi,ma_dvig,lh_nv,phong,nv,so_id,ngay,ngay_htnv,sum(phi)
            from TEMP_BC_BH_DTTT_MA_DT where (b_ma_dvi is null or ma_dvi=b_ma_dvi)
                and ngay_htbs between b_ngayd and b_ngayc and (b_nv is null or lh_nv like b_nv||'%')
                and (b_ma_dvi is null or ma_dvi=b_ma_dvi) and (b_phong is null or phong=b_phong)
                and (b_so_hd is null or so_hd=b_so_hd) and (b_ma_kh is null or ma_kh=b_ma_kh)
            group by ma_dvi,ma_dvig,lh_nv,phong,nv,so_id,ngay,ngay_htnv;

    update temp_3 set n20=(select max(ngay_htnv) from V_BC_BH_DTBH_MA_DT
        where ma_dvig=c28 and so_id=n10 and phi<>0 and dbh not in (1,2,3) and ngay=n11 and ngay_htnv<=n12);
    insert into temp_2(c1,c2,c3,c4,c6,n1,n4,n7)
        select c29,c6,c7,c4,c28,sum(n2),n10,max(n20) from temp_3 where n20 between b_ngayd_hd and b_ngayc_hd group by c29,c6,c7,c4,c28,n10;
end if;
update temp_2 set n8=FBH_HD_SO_ID_BS(c6,n4,n7);
-- doanh thu khac Xe, tai san, ky thuat,trach nhiem, tau, hang, xe le, tau le
insert into temp_1(c1,c2,c3,c4,c6,n1,n4,n8,n12)
    select c1,c2,c3,c4,c6,n1,n4,n8,n7 from temp_2 where c4 not in('XE','PHH','PKT','PTN','TAU','HANG','XEL','TAUL');
-- doanh thu xe
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,substr(b.nhom_xe,0,2),c6,n1,n4,b.so_id_dt,sum(c.phi_dt),n8,n7
--         from temp_2 a,bh_xegcn b,bh_xegcn_dk c
--         where a.c4='XE' and b.ma_dvi=c.ma_dvi and a.n8=b.so_id
--           and b.ma_dvi in (Select ma from ht_ma_dvi) and b.so_id=c.so_id and b.so_id_dt=c.so_id_dt
--           and a.c3=c.lh_nv
--         group by c1,c2,c3,c4,b.nhom_xe,c6,n1,n4,b.so_id_dt,n8,n7;
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n6,n8,n12)
--     select c1,c2,c3,c4,substr(b.nhom_xe,0,2),c6,n1,n4,sum(c.phi_dt),n8,n7
--         from temp_2 a,bh_xelgcn b,bh_xelgcn_dk c
--         where a.c4='XEL' and c.ma_dvi=b.ma_dvi and a.n8=b.so_id  and b.so_id=c.so_id
--             and b.ma_dvi in (Select ma from ht_ma_dvi)
--             and a.c3=c.lh_nv
--             group by c1,c2,c3,c4,b.nhom_xe,c6,n1,n4,n8,n7;

-- doanh thu tai san
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,b.ma_dt,c6,n1,n4,b.so_id_dt,c.phi,n8,n7
--     from temp_2 a,bh_phhgcn_dvi b,bh_phhgcn_dk c
--     where a.c4='PHH' and b.ma_dvi=a.c6 and b.so_id=a.n8
--     and c.ma_dvi=a.c6 and c.so_id=a.n8 and c.so_id_dt=b.so_id_dt and a.c3=c.lh_nv;
--doanh thu trach nhiem
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,'',c6,n1,n4,c.so_id_dt,c.phi,n8,n7
--     from temp_2 a,bh_ptngcn_dk c
--     where a.c4='PTN' and c.ma_dvi=a.c6 and c.so_id=a.n8 and a.c3=c.lh_nv;
--doanh thu ky thuat
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,c.ma_dt,c6,n1,n4,c.so_id_dt,c.phi,n8,n7
--     from temp_2 a,bh_pktgcn_dk c
--     where a.c4='PKT' and c.ma_dvi=a.c6 and c.so_id=a.n8 and a.c3=c.lh_nv;
--doanh thu tau
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,'',c6,n1,n4,c.so_id_dt,c.phi,n8,n7
--     from temp_2 a,bh_taugcn_dk c
--     where a.c4='TAU' and c.ma_dvi=a.c6 and c.so_id=a.n8 and a.c3=c.lh_nv;
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,'',c6,n1,n4,c.bt,c.phi,n8,n7
--     from temp_2 a,bh_taulgcn_dk c
--     where a.c4='TAUL' and c.ma_dvi=a.c6 and c.so_id=a.n8 and a.c3=c.lh_nv;
-- doanh thu hang
-- insert into temp_1(c1,c2,c3,c4,c5,c6,n1,n4,n5,n6,n8,n12)
--     select c1,c2,c3,c4,'',c6,n1,n4,c.so_id_dt,c.phi,n8,n7
--     from temp_2 a,bh_hhgcn_dk c
--     where a.c4='HANG' and c.ma_dvi=a.c6 and c.so_id=a.n8 and a.c3=c.lh_nv;

update temp_1 a set (n7,n9)=(select sum(n6),count(*) from temp_1 b where a.c6=b.c6 and a.n8=b.n8 and a.c3=b.c3)
    where c4 in ('XE','PHH','PKT','PTN','TAU','HANG');
--update temp_1 set n7=(select sum(phi) from bh_phhgcn_dk where so_id=n8 and lh_nv=c3 and ma_dvi=c6)where c4='PHH';
--update temp_1 set n7=(select count(*) from bh_ptngcn_dk where so_id=n8  and lh_nv=c3 and ma_dvi=c6) where c4='PTN';
--update temp_1 set n7=(select count(*) from bh_pktgcn_dk where so_id=n8 and lh_nv=c3 and ma_dvi=c6) where c4='PKT';
--update temp_1 set n7=(select count(*) from bh_taugcn_dk where so_id=n8 and lh_nv=c3 and ma_dvi=c6) where c4='TAU';
--update temp_1 set n7=(select count(*) from bh_taulgcn_dk where so_id=n8 and lh_nv=c3 and ma_dvi=c6) where c4='TAUL';
--update temp_1 set n7=(select count(*) from bh_hhgcn_dk where so_id=n8 and lh_nv=c3 and ma_dvi=c6) where c4='HANG';
-- update temp_1 set c5=(select truong from bh_nguoihd where so_id=n8)where c4 like 'CN.4%';
update temp_1 set n10=n1;
update temp_1 set n10=round(n1*n6/n7,0) where n9>1 and n7<>0 and c4 in ('XE','PHH','PKT','PTN','TAU','HANG');
--update temp_1 set n10=round(n1*n6/n7) where n7<>0 and c4='PHH';
--update temp_1 set n10=round(n1/n7) where n7<>0 and c4 in('PTN','PKT','TAU','TAUL','HANG');
--update temp_1 set n10=round(n1) where c3 like 'XG.1%';
--update temp_1 set n10=n1 where c4 like 'NG%';

-- tai
if b_uoc='C' then
    update temp_1 set n11=(select sum(pt) from tbh_pbo where so_id=n4 and so_id_dt=n5 and lh_nv=c3 and ma_dvi_ps=c6
                            and pthuc in ('O','S','Q') and kieu='D' and ngay_ht<=n12);
    update temp_1 set n9=(select sum(pt) from tbh_pbo where so_id=n4 and so_id_dt=n5 and lh_nv=c3 and ma_dvi_ps=c6
                            and pthuc='F' and kieu='D' and ngay_ht<=n12);
end if;
if b_uoc='U' then
    update temp_1 set n11=(select sum(pt) from tbh_pbo_ch where so_id=n4 and so_id_dt=n5 and lh_nv=c3 and ma_dvi=c6
                            and pthuc in ('O','S','Q') and ngay_ht=(select max(ngay_ht) from tbh_pbo_ch where so_id=n8
                                and so_id_dt=n5 and lh_nv=c3 and ma_dvi=c6 and ngay_ht<=n12)) ;
    update temp_1 set n9=(select sum(pt) from tbh_pbo_ch where so_id=n4 and so_id_dt=n5 and lh_nv=c3 and ma_dvi=c6
                            and pthuc='F' and ngay_ht=(select max(ngay_ht) from tbh_pbo_ch where so_id=n8
                                and so_id_dt=n5 and lh_nv=c3 and ma_dvi=c6 and ngay_ht<=n12));
end if;
commit;
open cs for select c1 ma_dvi,c2 phong,c3 lh_nv,c4 nv,c5 ma_dt,
        round(sum(n10)) phi_ps,round(sum(n10*n11/100)) phi_cd,round(sum(n9*n10/100)) phi_tt
    from temp_1
    group by c1,c2,c3,c4,c5;
exception when others then raise_application_error(-20105,b_loi);
end;

 
/
