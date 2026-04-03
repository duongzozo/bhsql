create or replace PROCEDURE BC_BH_TNDS_XECG
    (B_MADVI VARCHAR2,B_NSD VARCHAR2,B_PAS VARCHAR2,
    B_MA_DVI VARCHAR2,B_NV VARCHAR2,B_NGAYD NUMBER,B_NGAYC NUMBER,CS_KQ OUT PHT_TYPE.CS_TYPE)
AS
    B_LOI VARCHAR2(100);B_NGAYDN NUMBER; B_N1 NUMBER; B_N2 NUMBER;B_I1 NUMBER;B_TTRANG1 VARCHAR2(10);
BEGIN

IF B_NGAYD IS NULL OR B_NGAYC IS NULL THEN
    B_LOI:='loi:Nhap ngay bao cao:loi'; RAISE PROGRAM_ERROR;
END IF;
B_NGAYDN:=ROUND(B_NGAYD,-4)+101;
B_LOI:='loi:Ma chua dang ky:loi';
DELETE TEMP_1;DELETE TEMP_2;DELETE KET_QUA; COMMIT;

PBC_LAY_DVI(B_MADVI,B_MA_DVI,B_NSD,B_PAS,B_LOI);
IF B_LOI IS NOT NULL THEN RAISE PROGRAM_ERROR; END IF;
BC_BH_TNDS_XECG_MD(B_MADVI,B_MA_DVI,B_NV,B_NGAYD,B_NGAYC,B_LOI);

UPDATE TEMP_1 SET C23=(SELECT TEN FROM BH_MA_LHNV WHERE MA_DVI=TEMP_1.C1 AND MA=TEMP_1.C11);
UPDATE TEMP_1 SET C32=(SELECT TEN FROM HT_MA_DVI WHERE MA=TEMP_1.C1);


SELECT COUNT(*) INTO B_I1 FROM TEMP_BC_DVI;
IF B_I1=0 THEN
    OPEN CS_KQ FOR SELECT C1 MA_DVI,C2 SO_HD,N2 SO_ID_DT,C3 GCN,C4 BIEN_SO,C5 SO_KHUNG,C6 SO_MAY,C7 LOAI_XE,C8 HANG_XE,C9 HIEU_XE, C10 GCN_NGAY_HL,C11 GCN_NGAY_KT,
        C12 MD_SD, C13 TEN_CHU_XE,C14 DCHI, C15 NGAY_BBH, C19 NGUOI_BBH,N1 SO_ID, N2 SO_ID_DT, N3 SO_CN,N4 TTAI,N5 NAM_SX, N6 PHI_BH,
        C17 MA_KH, C18 PHONG,C19 MA_CB,C21 MA_KT,C22 MA_GT,c24 NSD,C20 NGAY_TT FROM TEMP_1,BH_HD_GOC
        WHERE C1=MA_DVI AND N1=SO_ID AND (B_TTRANG1 IS NULL OR TTRANG=B_TTRANG1);
ELSE
    OPEN CS_KQ FOR SELECT C1 MA_DVI,C2 SO_HD,N2 SO_ID_DT,C3 GCN,C4 BIEN_SO,C5 SO_KHUNG,C6 SO_MAY,C7 LOAI_XE,C8 HANG_XE,C9 HIEU_XE, C10 GCN_NGAY_HL,C11 GCN_NGAY_KT,
        C12 MD_SD, C13 TEN_CHU_XE,C14 DCHI, C15 NGAY_BBH, C19 NGUOI_BBH,N1 SO_ID, N2 SO_ID_DT, N3 SO_CN,N4 TTAI,N5 NAM_SX, N6 PHI_BH,
        C17 MA_KH, C18 PHONG,C19 MA_CB,C21 MA_KT,C22 MA_GT,c24 NSD,C20 NGAY_TT FROM TEMP_1,TEMP_BC_DVI,BH_HD_GOC
        WHERE C1=DVI AND C1=MA_DVI AND N1=SO_ID AND (B_TTRANG1 IS NULL OR TTRANG=B_TTRANG1);
END IF;
EXCEPTION WHEN OTHERS THEN RAISE_APPLICATION_ERROR(-20105,B_LOI);
END;
/
CREATE OR REPLACE PROCEDURE PBC_THANG2D_TH_BT_PB_MD (b_tc varchar2)
AS
begin
-- Lay du lieu boi thuong da phan bo chi phi theo Dong BH noi bo
    --delete temp_bt_1;delete temp_bt_2;delete bc_bh_bt_hs_temp;
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_1';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_2';
    EXECUTE IMMEDIATE 'TRUNCATE TABLE bc_bh_bt_hs_temp';

    insert into temp_bt_1(ma_dvi,so_id,lh_nv,n2,dvi_xl,c1) select pb.ma_dvi,so_id,lh_nv,tien_qd,pb.dvi_xl,pb.phong
        from bh_bt_hs_pb pb,temp_bc_ts ts where pb.ma_dvi like ts.ma_dvi and ngay_ht between ts.ngayd and ts.ngayc;

    --chen nhung vu duyet =0
    /*insert into temp_bt_1(ma_dvi,so_id,lh_nv,n2,dvi_xl,c1)
        select nv.ma_dvi, nv.so_id, nv.lh_nv, 0, nv.ma_dvi,hs.phong
        from bh_bt_hs_nv nv,bh_bt_hs hs, temp_bc_ts ts
        where nv.ma_dvi like ts.ma_dvi and hs.so_id=nv.so_id and hs.ma_dvi=nv.ma_dvi
        and nv.tien_qd=0 and TO_NUMBER(to_char(hs.ngay_qd,'yyyymmdd'))<=ts.ngayc
        --and to_number(to_char(hs.ngay_qd,'yyyymmdd')) between ts.ngayd and ts.ngayc
        --and nv.so_id not in (select so_id
        --    from bh_bt_hs_pb pb,temp_bc_ts ts where pb.ma_dvi like ts.ma_dvi and ngay_ht between ts.ngayd and ts.ngayc)
        group by nv.ma_dvi, nv.so_id, nv.lh_nv, nv.ma_dvi,hs.phong;
*/

    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bt_1 t
        where bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id-- and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=nv.ma_dvi and nv.so_id=t.so_id
            and bt.ma_dvi=bt.ma_dvi_xl
            --and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd) not in ('V','N');
            and exists (select 1 from bh_hd_goc where ma_dvi=bt.ma_dvi_ql and so_id=bt.so_id_hd
                and kieu_hd not in ('V','N'));

    -- chen them nguoi khac bt ho minh
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts,temp_bt_1 t
        where bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id  -- and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=nv.ma_dvi and nv.so_id=t.so_id
            and bt.ma_dvi=bt.ma_dvi_xl and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
            and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi_ql like ts.ma_dvi;

/*
    update temp_bt_2 t2 set n8=(select t2.n5 * max(t1.n2) from temp_bt_1 t1
                                        where t1.ma_dvi=t2.ma_dvi and t1.so_id=t2.so_id and t1.lh_nv=t2.lh_nv and t1.n2<>0);
*/
  merge into temp_bt_2 t2
        using (select ma_dvi,so_id,lh_nv,max(n2) n2 from temp_bt_1 group by ma_dvi,so_id,lh_nv) t1
        on (t1.ma_dvi=t2.ma_dvi and t1.so_id=t2.so_id and t1.lh_nv=t2.lh_nv and t1.n2<>0)
        when MATCHED then
        update set t2.n8=t2.n5*t1.n2;


--    update temp_bt_2 t2 set n9=(select sum(t.n5) from temp_bt_2 t
--                                        where t.ma_dvi=t2.ma_dvi and t.so_id=t2.so_id and t.lh_nv=t2.lh_nv);


EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_1';
insert into temp_bt_1 (ma_dvi,so_id,lh_nv,n5) select ma_dvi,so_id,lh_nv,sum(nvl(n5,0)) from temp_bt_2
    group by ma_dvi,so_id,lh_nv;
merge into temp_bt_2 t2
    using temp_bt_1 t
    on (t.ma_dvi=t2.ma_dvi and t.so_id=t2.so_id and t.lh_nv=t2.lh_nv)
    when MATCHED then
    update set t2.n9=t.n5;

    update temp_bt_2 set n1=round(n8/n9,0) where n9<>0;
    insert into bc_bh_bt_hs_temp select ma_dvi,so_id,c2,c3,lh_nv,n2,c6,n3,so_id_dt,n4,n1,n7,c5 from temp_bt_2;

end;
/
create or replace PROCEDURE          PBC_THANG2D_BT_CGQ_MD(b_tc varchar2)
AS
begin
--delete temp_bt_1;delete temp_bt_2;delete temp_bt_3;
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_1';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_2';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_3';

-- Lay so lieu trong bang bh_bt_hs_dp_ct
PBC_THANG2D_BT_CQG_CT(b_tc);
-- Lay so lieu trong bang bh_bt_hs_dp
PBC_THANG2D_BT_CQG(b_tc);
insert into temp_bt_2 (ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,n6,n7,so_id_dt,c1,c4,n8)
    select a.ma_dvi,a.c2,a.c3,a.lh_nv,a.so_id,a.n2,a.n3,a.n4,a.n5,nv.tien,nv.tien_qd,nv.so_id_dt,c1,c4,n6
    from temp_bt_3 a,bh_bt_hs_nv nv
    where a.ma_dvi=nv.ma_dvi and a.so_id=nv.so_id;
 
    
-- Tong hop so lieu
delete temp_bt_2 a where (a.ma_dvi,a.so_id) in (select b.ma_dvi,b.so_id from temp_bt_1 b);
update temp_bt_2 a set n9=(select sum(n7) from temp_bt_2 b where b.ma_dvi=a.ma_dvi and b.so_id=a.so_id group by b.ma_dvi,b.so_id);
update temp_bt_2 set n1= round(n7*n5/n9,0) where n9<>0;
insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c4,n6) 
    select ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n1,so_id_dt,c4,n8 from temp_bt_2;

end;
/
CREATE OR REPLACE PROCEDURE PBC_THANG2D_BT_CQG_CT(b_tc varchar2)
-- Boi thuong chua giai quyet lay so lieu trong bang bh_bt_hs_dp_ct
AS
begin
-- Tu lam
if PKH_MA_MA(b_tc,'T') or PKH_MA_MA(b_tc,'*')  then --
    /*
    insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,nv.so_id_dt,'T',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp_ct nv,(select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp_ct a,temp_bc_ts t
                where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,temp_bc_ts ts
            where bt.ma_dvi_xl=bt.ma_dvi_ql and
                bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi=ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,nv.lh_nv,bt.so_id,bt.ngay_ht,bt.so_id_hd,nv.tien,nv.tien_qd,bt.so_id_dt,'T',bt.ma_dvi_ql,bt.ngay_qd
            from bh_bt_hs bt,bh_bt_hs_dp_ct nv,(select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp_ct a,temp_bc_ts t
                where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc and bt.ngay_qd>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl=bt.ma_dvi_ql and bt.ma_dvi=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp;
end if;
-- Don vi khac lam ho
if PKH_MA_MA(b_tc,'N') or PKH_MA_MA(b_tc,'*') or PKH_MA_MA(b_tc,'T')  then
    /*
    insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,nv.so_id_dt,'N',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp_ct nv,(select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp_ct a,temp_bc_ts t
                where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,temp_bc_ts ts
            where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi=ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,bt.so_id_hd,nv.tien,nv.tien_qd,bt.so_id_dt,'N',bt.ma_dvi_ql,bt.ngay_qd
            from bh_bt_hs bt,bh_bt_hs_dp_ct nv,(select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp_ct a,temp_bc_ts t
                where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc and bt.ngay_qd>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl<>bt.ma_dvi_ql and  bt.ma_dvi=ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp;
end if;
--  lam ho don vi khac
if PKH_MA_MA(b_tc,'H') or PKH_MA_MA(b_tc,'*') then
    /*
    insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_bs,nv.tien,nv.tien_qd,nv.so_id_dt,'H',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts
            where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi=ma_dvi_xl
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,nv.lh_nv,bt.so_id,bt.ngay_ht,nv1.so_id_bs,nv.tien,nv.tien_qd,bt.so_id_dt,'H',bt.ma_dvi_ql,bt.ngay_qd
            from bh_bt_hs bt,bh_bt_hs_nv nv,bh_bt_chs_nv nv1,temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc and bt.ngay_qd>ts.ngayc
                and nv.ma_dvi=nv1.ma_dvi and nv.so_id=nv1.so_id
                and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi=ma_dvi_xl
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id;
end if;
commit;
end;
/
 create or replace PROCEDURE          PBC_THANG2D_BT_CQG(b_tc varchar2)  
AS
begin
-- Boi thuong chua giai quyet lay so lieu trong bang bh_bt_hs_dp
-- Tu lam
if PKH_MA_MA(b_tc,'T') or PKH_MA_MA(b_tc,'*') then
    /*
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'T',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp nv,
                (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
                  where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                    temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi_xl=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id 
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp     
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'T',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp nv,
                (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
                  where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                    temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc
                and to_char(ngay_qd,'yyyymmdd')>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id 
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp;     
end if;
--Don vi khac lam ho
if PKH_MA_MA(b_tc,'N') or PKH_MA_MA(b_tc,'*') or PKH_MA_MA(b_tc,'T') then
    /*
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'N',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp nv,
                (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
                  where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                temp_bc_ts ts
            where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi=ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id 
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'N',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp nv,
                (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
                  where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc 
                and to_char(bt.ngay_qd,'yyyymmdd')>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id 
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp;
end if;

--Lam ho don vi khac 
if PKH_MA_MA(b_tc,'H') or PKH_MA_MA(b_tc,'*') then
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_bs,nv.tien,nv.tien_qd,'H',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc 
                and to_char(ngay_qd,'yyyymmdd')>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl<>bt.ma_dvi_ql and  bt.ma_dvi=bt.ma_dvi_xl
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id;
end if;        
commit;
end;
/
CREATE OR REPLACE PROCEDURE BC_KEHOACH_DT_BT_1
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2, b_dvi varchar2, b_phong varchar2,b_nguon varchar2, b_loai_kh varchar2, b_lhnv varchar2,
    b_ngayd number,b_ngayc number,cs_kq out pht_type.cs_type)
AS
    b_loi varchar2(100);b_ngaydn number; b_n1 number; b_n2 number; b_ngaynt number;b_i1 number;
    b_ngay_c number; b_d1 number; b_d2 number;b_ngayd_nt number;b_ngayc_nt number;
    b_ngayd_lk_nt number;b_ngayc_lk_nt number;b_ma_vp varchar2(10); b_lkh varchar2(10);
Begin
-- Bao cao nhanh tinh hinh  boi thuong tong
b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;

b_lkh:='';
if b_loai_kh is not null then
    b_lkh:=b_loai_kh;
end if;

PBC_LAY_NV(b_madvi,b_madvi,b_nsd,b_pas,b_phong);
select count(*) into b_i1 from temp_bc_nv where nv='BT';
if b_i1=0 then
    b_loi:='loi:Ban khong co quyen xem bao cao nay:loi'; raise PROGRAM_ERROR;
end if;


if b_ngayd is null or b_ngayc is null then
    b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
end if;
b_ngaydn:=round(b_ngayd,-4)+101;

--b_loi:='loi:Ma chua dang ky:loi';
delete bc_bh_bt_temp;delete ket_qua; commit;

-- So lieu trong ky
delete temp_bc_ts;
--PBC_BH_TS(b_madvi,b_nsd,'',b_ngayd,b_ngayc,b_loi);
insert into temp_bc_ts values(b_dvi||'%',b_ngayd, b_ngayc);
--if b_loi is not null then raise PROGRAM_ERROR; end if;

THANG2d_PBC_LAY_NV(b_madvi,b_nsd,'','');


PBC_THANG2D_TH_BT_PB_MD('T');
insert into bc_bh_bt_temp (ma_dvi,phong,c30, n1,ngay_ht,so_id_hd,ma_dvi_hd, lh_nv)
                select t.ma_dvi,t.phong,t.nv, sum(t.tien_qd),t.ngay_ht,t.so_id_hd,t.ma_dvi_hd, t.lh_nv from bc_bh_bt_hs_temp t, bh_hd_goc goc
                where t.ngay_qd_n<30000101 and t.ngay_ht between b_ngayd and b_ngayc
                and (b_phong is null or t.phong=b_phong) and (b_lhnv is null or t.lh_nv like b_lhnv||'%')
                and t.so_id_hd=goc.so_id and t.ma_dvi_hd=goc.ma_dvi and (trim(b_nguon) is null or goc.ma_gt like b_nguon||'%')
                and t.nv in (Select nv from temp_bc_nv)
                group by t.ma_dvi,t.phong,t.nv,t.ngay_ht,t.so_id_hd,t.ma_dvi_hd,t.lh_nv;
--chua giai quyet ==> OK
delete temp_bc_ts;
--PBC_BH_TS(b_madvi,b_nsd,'',b_ngayd,b_ngayc,b_loi);
insert into temp_bc_ts values(b_dvi||'%',b_ngayd, b_ngayc);
PBC_THANG2D_BT_CGQ_MD('T');
insert into bc_bh_bt_temp (ma_dvi,phong,c30,n2,ngay_ht,so_id_hd,ma_dvi_hd,lh_nv)
                select t.ma_dvi,t.c3,t.c2,sum(t.n5),t.n2,t.n3,t.c4, t.lh_nv from temp_bt_1 t, bh_hd_goc goc
                where (b_phong is null or t.c3=b_phong) and (b_lhnv is null or t.lh_nv like b_lhnv||'%')
                and t.n3=goc.so_id and t.c4=goc.ma_dvi and (trim(b_nguon) is null or goc.ma_gt like b_nguon||'%')
                and t.c2 in (Select nv from temp_bc_nv)
                group by t.ma_dvi,t.c3,t.c2,t.n2,t.n3,t.c4,t.lh_nv;
--============TRONG KY=============XU LY TRUONG HOP DAC BIET HD, HP, LC, YB, TB=======================

            --bot so lieu HP, them vao so lieu HD
            update bc_bh_bt_temp set ma_dvi='025', phong='KDHY' where ma_dvi='007' and phong='KDHY' and ngay_ht>=20110101;
            update bc_bh_bt_temp set ma_dvi='025', phong='KD02' where ma_dvi='007' and phong='KDHD' and ngay_ht>=20110101;
            --Bot so lieu tay bac, them vao so lieu
            update bc_bh_bt_temp set ma_dvi='023', phong='KD01' where ma_dvi='003' and phong='KVLC' and ngay_ht>=20110101;
            update bc_bh_bt_temp set ma_dvi='024', phong='KD01' where ma_dvi='003' and phong='KVYB' and ngay_ht>=20110101;


-- So lieu luy ke tu dau nam
if b_ngaydn=b_ngayd then
    update bc_bh_bt_temp set n4=n1, n5=n2;
else
    delete temp_bc_ts;
    insert into temp_bc_ts values(b_dvi||'%',b_ngaydn, b_ngayc);
    --boi thuong luy ke ==> OK
    PBC_THANG2D_TH_BT_PB_MD('T');
    insert into bc_bh_bt_temp (ma_dvi,phong,c30,n4,ngay_ht,so_id_hd,ma_dvi_hd,lh_nv)
                    select t.ma_dvi,t.phong,t.nv,sum(t.tien_qd),t.ngay_ht,t.so_id_hd,t.ma_dvi_hd,t.lh_nv from bc_bh_bt_hs_temp t, bh_hd_goc goc
                    where t.ngay_qd_n<30000101 and t.ngay_ht between b_ngaydn and b_ngayc
                    and (b_phong is null or t.phong=b_phong) and (b_lhnv is null or t.lh_nv like b_lhnv||'%')
                    and t.so_id_hd=goc.so_id and t.ma_dvi_hd=goc.ma_dvi and (trim(b_nguon) is null or goc.ma_gt like b_nguon||'%')
                    and t.nv in (Select nv from temp_bc_nv)
                    group by t.ma_dvi,t.phong,t.nv,t.ngay_ht,t.so_id_hd,t.ma_dvi_hd,t.lh_nv;
    delete temp_bc_ts;
    insert into temp_bc_ts values(b_dvi||'%',b_ngaydn, b_ngayc);
    PBC_THANG2D_BT_CGQ_MD('T');
    insert into bc_bh_bt_temp (ma_dvi,phong,c30,n5,ngay_ht,so_id_hd,ma_dvi_hd,lh_nv)
                    select t.ma_dvi,t.c3,t.c2,sum(t.n5),t.n2,t.n3,t.c4,t.lh_nv from temp_bt_1 t, bh_hd_goc goc
                    where (b_phong is null or t.c3=b_phong) and (b_lhnv is null or t.lh_nv like b_lhnv||'%')
                    and t.n3=goc.so_id and t.c4=goc.ma_dvi and (trim(b_nguon) is null or goc.ma_gt like b_nguon||'%')
                    and t.c2 in (Select nv from temp_bc_nv)
                    group by t.ma_dvi,t.c3,t.c2,t.n2,t.n3,t.c4,t.lh_nv;

     --==========LUY KE===============XU LY TRUONG HOP DAC BIET HD, HP, LC, YB, TB=======================

                --bot so lieu HP, them vao so lieu HD
                update bc_bh_bt_temp set ma_dvi='025', phong='KDHY' where ma_dvi='007' and phong='KDHY' and ngay_ht>=20110101;
                update bc_bh_bt_temp set ma_dvi='025', phong='KD02' where ma_dvi='007' and phong='KDHD' and ngay_ht>=20110101;
                --Bot so lieu tay bac, them vao so lieu
                update bc_bh_bt_temp set ma_dvi='023', phong='KD01' where ma_dvi='003' and phong='KVLC' and ngay_ht>=20110101;
                update bc_bh_bt_temp set ma_dvi='024', phong='KD01' where ma_dvi='003' and phong='KVYB' and ngay_ht>=20110101;

end if;


delete ket_qua; delete temp_1;

insert into temp_1(c1, c10, c2, n1, n2, n4, n5, n7, n8)
    select a.ma_dvi, lh_nv, ma_kh, sum(nvl(n1,0)), sum(nvl(n2,0)), sum(nvl(n4,0)), sum(nvl(n5,0)),
    sum(nvl(n7,0)), sum(nvl(n8,0)) from bc_bh_bt_temp a, bh_hd_goc b where a.ma_dvi_hd=b.ma_dvi
    and a.so_id_hd=b.so_id  and (b_dvi is null or a.ma_dvi like b_dvi||'%') and (b_lhnv is null or lh_nv like b_lhnv||'%')
    and (b_phong is null or a.phong=b_phong)
    group by a.ma_dvi, lh_nv, ma_kh;

if b_lkh is not null then
    update temp_1 set c3=(Select loai from bh_hd_ma_kh where ma_dvi=c1 and ma=c2);
end if;

-- cap nhat doanh thu trong ky, luy ke
insert into temp_1(c10,c3, n10)
    (Select lh_nv, loai_kh, sum(nvl(dt_bh,0)) from BH_THANG2D_BC_DT_LUU
    where --ngay between b_ngayd and b_ngayc and 
    (b_dvi is null or ma_dvi like b_dvi||'%')
    and (b_lhnv is null or lh_nv like b_lhnv||'%') and (b_lkh is null or loai_kh like b_lkh||'%')
    --and (trim(b_nguon) is null or nguon like b_nguon||'%')
    and (b_phong is null or phong=b_phong) and nv in (Select nv from temp_bc_nv)
    group by lh_nv, loai_kh);

if b_ngaydn=b_ngayd then
    update temp_1 set n11=n10;
else
    insert into temp_1(c10, c3, n11)
        (Select lh_nv,loai_kh, sum(nvl(dt_bh,0)) from BH_THANG2D_BC_DT_LUU
        where --ngay between b_ngaydn and b_ngayc and 
        (b_dvi is null or ma_dvi like b_dvi||'%')
        and (b_lhnv is null or lh_nv like b_lhnv||'%') and (b_lkh is null or loai_kh like b_lkh||'%')
        --and (trim(b_nguon) is null or nguon like b_nguon||'%')
        and (b_phong is null or phong=b_phong) and nv in (Select nv from temp_bc_nv)
        group by lh_nv, loai_kh);
end if;
delete temp_1 where c10='*';
insert into ket_qua(c10, n10, n11, n1, n2, n4, n5, n7, n8)
    select c10, sum(nvl(n10,0)),sum(nvl(n11,0)),sum(nvl(n1,0)), sum(nvl(n2,0)), sum(nvl(n4,0)), sum(nvl(n5,0)),
    sum(nvl(n7,0)), sum(nvl(n8,0)) from temp_1 where (b_lkh is null or c3 like b_lkh||'%')
    group by c10;



delete ket_qua where n10=0 and n11=0 and n3=0 and n1=0 and n2=0 and n4=0 and n5=0 and n7=0 and n8=0;

update ket_qua set c11=(select ten from bh_ma_lhnv where ma=c10 and ma_dvi='000');

update ket_qua set (c12,c13)=(Select substr(c10,1,2),ten from bh_ma_lhnv where ma=substr(c10,1,2) and ma_dvi='000');
--chen dong tong vao

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'XG', '',0,
        sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'XG%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'XG%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='XG';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'HH', '', 0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'HH%';

update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'HH%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='HH';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'TT', '', 0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'TT%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'TT%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='TT';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'CN', '',0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'CN%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'CN%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='CN';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'HK', '',0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'HK%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'HK%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='HK';


insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'TS', '',0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'TS%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'TS%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='TS';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'KT', '',0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'KT%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'KT%' and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='KT';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'HP', '',0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'HP%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'HP%'
                        and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000'))) where c10='HP';

insert into ket_qua(c10, c11, n9, n10, n11, n1, n2, n4, n5)
    select 'TN', '',0,
    sum(n10), sum(n11), sum(n1), sum(n2), sum(n4), sum(n5)
        from ket_qua where c10 like 'TN%';
update ket_qua set n9=(Select sum(kh) from bh_ma_lhnv_kh where substr(ngay,1,4)=substr(b_ngaydn,1,4) and ma like 'TN%'
                      and ((kieu='C' and dvi<>'000') or(kieu='P' and dvi='000')))
    where c10='TN';

commit;


open cs_kq for
    SELECT * FROM
           (SELECT  ds.*, ROWNUM stt FROM
              (
                select c10 ma_nv, c11 ten_nv, n9 DT_KH,
                    round(nvl(n10,0)) DT_BH_TK, round(nvl(n11,0)) DT_BH_LK,
                    round(n1) BT_DGQ_TK, round(nvl(n2,0)) BT_CGQ_TK,
                    round(n4) BT_DGQ_LK, round(n5) BT_CGQ_LK
                from ket_qua order by c10
            ) ds
        )order by ma_nv;

exception when others then raise_application_error(-20105,b_loi);
end;
/
create or replace PROCEDURE            "BC_DTHU_TAI_VE_BH" 
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_lhnv varchar2, b_ngayd number, b_ngayc number,b_loi out varchar2)
as
begin
   -- ma_dvi,so_id,ngay_ht,so_id_ta_ps,nv,loai,goc,ma_nt,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,lh_nv,pt,nt_tien,tien,nt_phi,phi,tl_thue,thue,pt_hh,hhong,kieu_hd,kieu_dt
    delete bh_bc_tbh_ve_bh_temp; commit;
    -- Lay doanh thu ban hang
/*
    insert into bh_bc_tbh_ve_bh_temp select a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
        d.ma_dvi_hd,d.so_id_hd,d.so_id_dt,a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,c.pt,
       -- d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong),a.so_id_dc,a.kieu  -- lay tien qd
         d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien_qd),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong_qd),a.so_id_dc,a.kieu
              from tbh_dc_pt a, tbh_ve_phi c, tbh_ve_pbo d
              where a.so_id_ta_ps=c.so_id and a.so_id_ta_ps=d.so_id and c.so_id = d.so_id
              and a.ngay_ht between b_ngayd and b_ngayc and (b_lhnv is null or d.lh_nv like b_lhnv||'%')
              and FBH_MA_LHNV_TAI(d.ma_dvi,d.lh_nv)=c.ma_ta and FBH_MA_LHNV_TAI(d.ma_dvi,d.lh_nv)=a.ma_ta
              and a.kieu in ('V','N') and c.tien > 0 and a.goc='HD_PS' --and so_id_dc=20150625015171
              group by  a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,d.ma_dvi_hd,d.so_id_hd,d.so_id_dt,
              a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,c.pt,d.nt_tien,a.ma_nt,a.so_id_dc,a.kieu;
              */
              /*
    insert into bh_bc_tbh_ve_bh_temp select a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
        d.ma_dvi_hd,d.so_id_hd,0,a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,0, -- tam bo so_id_dt
       -- d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong),a.so_id_dc,a.kieu  -- lay tien qd
         d.nt_tien,0,a.ma_nt,sum(a.tien_qd),0,sum(a.thue),0,sum(a.hhong_qd),a.so_id_dc,a.kieu
              from tbh_dc_pt a,tbh_ve_pbo d
              where a.so_id_ta_ps=d.so_id
              and a.ngay_ht between b_ngayd and b_ngayc and (b_lhnv is null or d.lh_nv like b_lhnv||'%')
              and FBH_MA_LHNV_TAI(d.ma_dvi,d.lh_nv)=a.ma_ta
              and a.kieu in ('V','N') and a.goc='HD_PS' --and so_id_dc=20150625015171
              group by  a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,d.ma_dvi_hd,d.so_id_hd,
              a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,d.nt_tien,a.ma_nt,a.so_id_dc,a.kieu;
*/
    insert into bh_bc_tbh_ve_bh_temp select a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
        '',0,0,a.pthuc,a.ma_ta,a.nha_bh,'',0, -- tam bo so_id_dt
       -- d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong),a.so_id_dc,a.kieu  -- lay tien qd
         '',0,a.ma_nt,sum(a.tien),0,sum(a.thue),0,sum(a.hhong),a.so_id_dc,a.kieu
              from tbh_dc_pt a
              where a.ngay_ht between b_ngayd and b_ngayc
              and a.kieu in ('V','N') and a.goc='HD_PS' -- and so_id_dc in (20150611005394,20150611005091)
              group by  a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
              a.pthuc,a.ma_ta,a.nha_bh,a.ma_nt,a.so_id_dc,a.kieu;
    update bh_bc_tbh_ve_bh_temp a set (ma_dvi_hd,so_id_hd,so_id_dt,nt_tien,lh_nv)=(select max(ma_dvi_hd),max(so_id_hd),max(so_id_dt),max(nt_tien),max(lh_nv) from tbh_ve_pbo c
        --where a.ma_dvi=c.ma_dvi and a.so_id_ta_ps=c.so_id and (b_lhnv is null or c.lh_nv like b_lhnv||'%') and FBH_MA_LHNV_TAI(c.ma_dvi,c.lh_nv)=a.ma_ta); --SUA LAI THEO SO_ID sdbs
        where a.ma_dvi=c.ma_dvi and a.so_id=c.so_id and (b_lhnv is null or c.lh_nv like b_lhnv||'%') and FBH_MA_LHNV_TAI(c.ma_dvi,c.lh_nv)=a.ma_ta);
           --   pt_hh 4,tl_thue 6,tien 9,pt 11;
    update bh_bc_tbh_ve_bh_temp a set (pt_hh,tl_thue,tien,pt)=(select max(pt_hh),max(tl_thue),sum(tien),max(pt) from tbh_ve_phi c
        where a.ma_dvi=c.ma_dvi and a.so_id_ta_ps=c.so_id and c.tien > 0);
    
    --DQD sua
    --delete bh_bc_tbh_ve_bh where ngay_ht between b_ngayd and b_ngayc;
    --insert into bh_bc_tbh_ve_bh select * from bh_bc_tbh_ve_bh_temp;
    commit;
    exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
 CREATE OR REPLACE PROCEDURE BC_BT_TH_BH_TAI_NV
    (b_madvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_dvi varchar2,b_ma_nv varchar2, b_nha_bh varchar2, b_hd varchar2,b_tc varchar2,
    b_ngayd number,b_ngayc number,cs_kq out pht_type.cs_type)
as
    b_loi varchar2(100);b_i1 number; b_ma_nv1 varchar2(10); b_ngaydn number;
    b_tc1 varchar2(1); b_dvi varchar2(10);
begin
    b_ma_nv1:=b_ma_nv;
    b_tc1:='*';
    b_ngaydn:=round(b_ngayd,-4)+101;
    -- Bao cao ho so boi thuong ton dong( chua giai quyet)
    b_loi:=FHT_MA_NSD_KTRA(b_madvi,b_nsd,b_pas,'BH','','');
    --b_loi:='loi:'||b_ma_nv1||':loi';
    if b_loi is not null then raise PROGRAM_ERROR; end if;

    if b_ngayd is null or b_ngayc is null then
        b_loi:='loi:Nhap ngay bao cao:loi'; raise PROGRAM_ERROR;
    end if;
    b_loi:='loi:Ma chua dang ky:loi';

    delete bc_bh_bt_temp;delete temp_6;commit;
    BBC_LAY_NV(b_madvi,b_nsd,'','');
    select count(*) into b_i1 from temp_bc_nv where nv='BT';
    if b_i1=0 then
        b_loi:='loi:Ban khong co quyen xem bao cao nay:loi'; raise PROGRAM_ERROR;
    end if;
    --boi thuong trong ky
    delete temp_6;
    delete temp_bc_ts;
    PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,b_ngayd,b_ngayc,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PBC_BH_BT_CGQ_TAI(b_tc1);
    insert into temp_6(c1, n1)
    select t.lh_nv,sum(t.n5) from temp_bt_1 t
        where (b_ma_nv1 is null or t.lh_nv like b_ma_nv1 ||'%')
        --and (b_ma_dvi is null or t.ma_dvi like b_ma_dvi||'%')
        and t.n2 between b_ngayd and b_ngayc
        --and t.lh_nv in (Select nv from temp_bc_nv)
        group by t.lh_nv;

    PBC_BH_TH_BT_PB_MD_TAI(b_tc1);
    insert into temp_6(c1, n2)
    select t.lh_nv,sum(t.tien_qd) from bc_bh_bt_hs_temp t
         where t.ngay_qd_n<30000101 and t.ngay_ht between b_ngayd and b_ngayc
             --and (b_ma_dvi is null or t.ma_dvi like b_ma_dvi||'%')
             and (b_ma_nv1 is null or t.lh_nv like b_ma_nv1 ||'%')
         group by t.lh_nv;
    --boi thuong luy ke
    if b_ngaydn=b_ngayd then
        update temp_6 set n3=n1, n4=n2;
    else
        delete temp_bc_ts;
        PBC_BH_TS(b_madvi,b_nsd,b_ma_dvi,b_ngaydn,b_ngayc,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        PBC_BH_BT_CGQ_TAI(b_tc1);
        insert into temp_6(c1, n3)
        select t.lh_nv,sum(t.n5) from temp_bt_1 t
            where (b_ma_nv1 is null or t.lh_nv like b_ma_nv1 ||'%')
            --and (b_ma_dvi is null or t.ma_dvi like b_ma_dvi||'%')
            and t.n2 between b_ngaydn and b_ngayc
            --and t.lh_nv in (Select nv from temp_bc_nv)
            group by t.lh_nv;

        PBC_BH_TH_BT_PB_MD_TAI(b_tc1);
        insert into temp_6(c1, n4)
        select t.lh_nv,sum(t.tien_qd) from bc_bh_bt_hs_temp t
             where t.ngay_qd_n<30000101 and t.ngay_ht between b_ngaydn and b_ngayc
             --and (b_ma_dvi is null or t.ma_dvi like b_ma_dvi||'%')
             and (b_ma_nv1 is null or t.lh_nv like b_ma_nv1 ||'%')
             group by t.lh_nv;
    end if;
    --chen doanh thu ban hang
    BC_DTHU_TAI_VE_BH(b_ma_dvi, b_nsd, b_pas, b_ma_nv1, b_ngayd, b_ngayc, b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    insert into temp_6(c1, n5)
        select a.lh_nv, sum(FTT_VND_QD(a.ma_dvi,a.ngay_ht,a.nt_phi,a.phi))
            from bh_bc_tbh_ve_bh a where
            --(b_ma_dvi is null or ma_dvi like b_ma_dvi||'%') and
            a.ngay_ht between b_ngayd and b_ngayc
            and (b_ma_nv1 is null or a.lh_nv like b_ma_nv1||'%')
        group by a.lh_nv;
    if b_ngaydn = b_ngayd then
        update temp_6 set n6=n5;
    else
        insert into temp_6(c1, n6)
        select a.lh_nv, sum(FTT_VND_QD(a.ma_dvi,a.ngay_ht,a.nt_phi,a.phi))
            from bh_bc_tbh_ve_bh a where
            --(b_ma_dvi is null or ma_dvi like b_ma_dvi||'%') and
            a.ngay_ht between b_ngaydn and b_ngayc
            and (b_ma_nv1 is null or a.lh_nv like b_ma_nv1||'%')
        group by a.lh_nv;
    end if;
    update temp_6 set c2=(Select ten from bh_ma_lhnv where ma_dvi='000' and ma=c1);
    open cs_kq for
        SELECT * FROM
           (SELECT  ds.*, ROWNUM stt FROM
              (
                select c1 MA_NV, c2 ten_nv, sum(n1) BT_CGQ_TK, sum(n2) BT_DGQ_TK, sum(n3) BT_CGQ_LK,
                    sum(n4) BT_DGQ_LK, sum(n5) DT_BH_TK, sum(n6) DT_BH_LK
                    from temp_6 group by c1, c2 order by c1
            ) ds
        )order by ma_nv;

    exception when others then raise_application_error(-20105,b_loi);
end;
/

create or replace PROCEDURE          PBC_BH_TH_BT_PB_MD_TAI (B_TC VARCHAR2)
AS
BEGIN 
--edit dqd
--DELETE TEMP_BT_1;DELETE TEMP_BT_2;DELETE BC_BH_BT_HS_TEMP; 
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_1';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_2';
EXECUTE IMMEDIATE 'TRUNCATE TABLE bc_bh_bt_hs_temp';
INSERT INTO TEMP_BT_1(MA_DVI,SO_ID,LH_NV,N2,DVI_XL,C1) SELECT PB.MA_DVI,SO_ID,LH_NV,TIEN_QD,PB.DVI_XL,PB.PHONG
    FROM BH_BT_HS_PB PB,TEMP_BC_TS TS WHERE PB.MA_DVI=TS.MA_DVI AND NGAY_HT BETWEEN TS.NGAYD AND TS.NGAYC;

INSERT INTO TEMP_BT_1(MA_DVI,SO_ID,LH_NV,N2,DVI_XL,C1)
    SELECT NV.MA_DVI, NV.SO_ID, NV.LH_NV, 0, NV.MA_DVI,HS.PHONG
    FROM BH_BT_HS_NV NV,BH_BT_HS HS, TEMP_BC_TS TS 
    WHERE NV.MA_DVI=TS.MA_DVI AND HS.SO_ID=NV.SO_ID AND HS.MA_DVI=NV.MA_DVI
    AND NV.TIEN_QD=0 AND TO_NUMBER(TO_CHAR(HS.NGAY_QD,'yyyymmdd'))<=TS.NGAYC AND TO_NUMBER(TO_CHAR(HS.NGAY_QD,'yyyymmdd')) BETWEEN TS.NGAYD AND TS.NGAYC 
    AND NV.SO_ID NOT IN (SELECT SO_ID
        FROM BH_BT_HS_PB PB,TEMP_BC_TS TS WHERE PB.MA_DVI=TS.MA_DVI AND NGAY_HT BETWEEN TS.NGAYD AND TS.NGAYC)
    GROUP BY NV.MA_DVI, NV.SO_ID, NV.LH_NV, NV.MA_DVI,HS.PHONG;
   
IF B_TC='*' THEN
    INSERT INTO TEMP_BT_2(MA_DVI,C2,C3,LH_NV,SO_ID,N2,N3,N4,N5,SO_ID_DT,N7,C5,C6)
        SELECT T.MA_DVI,BT.NV,T.C1 PHONG,NV.LH_NV,BT.SO_ID,PKH_NG_CSO(BT.NGAY_QD) NGAY_QD_N,SO_ID_HD,
                TIEN,TIEN_QD,NV.SO_ID_DT,BT.NGAY_HT,B_TC,BT.MA_DVI_QL
        FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BT_1 T
        WHERE BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID AND (BT.MA_DVI_QL=T.DVI_XL OR BT.MA_DVI=BT.MA_DVI_XL) AND BT.SO_ID=T.SO_ID AND T.LH_NV=NV.LH_NV
            --AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD) IN ('V','N');
            and (select nvl(min(kieu_hd),' ') from bh_hd_goc where ma_dvi=bt.ma_dvi_ql and so_id=bt.so_id_hd) not in ('V', 'N');
            


ELSIF B_TC='K' THEN
    INSERT INTO TEMP_BT_2(MA_DVI,C2,C3,LH_NV,SO_ID,N2,N3,N4,N5,SO_ID_DT,N7,C5,C6)
        SELECT T.MA_DVI,BT.NV,T.C1 PHONG,NV.LH_NV,BT.SO_ID,PKH_NG_CSO(BT.NGAY_QD) NGAY_QD_N,SO_ID_HD,
                TIEN,TIEN_QD,NV.SO_ID_DT,BT.NGAY_HT,B_TC,BT.MA_DVI_QL
        FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BC_TS TS,TEMP_BT_1 T
        WHERE BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID AND BT.MA_DVI_QL=T.DVI_XL AND BT.SO_ID=T.SO_ID AND T.LH_NV=NV.LH_NV
            AND BT.MA_DVI=BT.MA_DVI_XL AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD)  IN ('V','N')
            AND BT.MA_DVI_XL<>BT.MA_DVI_QL AND BT.MA_DVI_XL<>TS.MA_DVI AND BT.MA_DVI_QL<>TS.MA_DVI;
END IF;

IF PKH_MA_MA(B_TC,'T') THEN
    INSERT INTO TEMP_BT_2(MA_DVI,C2,C3,LH_NV,SO_ID,N2,N3,N4,N5,SO_ID_DT,N7,C5,C6)
        SELECT T.MA_DVI,BT.NV,T.C1 PHONG,NV.LH_NV,BT.SO_ID,PKH_NG_CSO(BT.NGAY_QD) NGAY_QD_N,SO_ID_HD,
                TIEN,TIEN_QD,NV.SO_ID_DT,BT.NGAY_HT,B_TC,BT.MA_DVI_QL
        FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BT_1 T
        WHERE BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID AND BT.MA_DVI_QL=T.DVI_XL AND BT.SO_ID=T.SO_ID
            AND BT.MA_DVI=BT.MA_DVI_XL AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD)  IN ('V','N');

    
    INSERT INTO TEMP_BT_2(MA_DVI,C2,C3,LH_NV,SO_ID,N2,N3,N4,N5,SO_ID_DT,N7,C5,C6)
        SELECT T.MA_DVI,BT.NV,T.C1 PHONG,NV.LH_NV,BT.SO_ID,PKH_NG_CSO(BT.NGAY_QD) NGAY_QD_N,SO_ID_HD,
                TIEN,TIEN_QD,NV.SO_ID_DT,BT.NGAY_HT,B_TC,BT.MA_DVI_QL
        FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BC_TS TS,TEMP_BT_1 T
        WHERE BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID AND BT.MA_DVI_QL=T.DVI_XL AND BT.SO_ID=T.SO_ID
            AND BT.MA_DVI=BT.MA_DVI_XL AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD)  IN ('V','N')
            AND BT.MA_DVI_XL<>BT.MA_DVI_QL AND BT.MA_DVI_QL=TS.MA_DVI;
END IF;

IF PKH_MA_MA(B_TC,'N') THEN
    INSERT INTO TEMP_BT_2(MA_DVI,C2,C3,LH_NV,SO_ID,N2,N3,N4,N5,SO_ID_DT,N7,C5,C6)
        SELECT T.MA_DVI,BT.NV,T.C1 PHONG,NV.LH_NV,BT.SO_ID,PKH_NG_CSO(BT.NGAY_QD) NGAY_QD_N,SO_ID_HD,
                TIEN,TIEN_QD,NV.SO_ID_DT,BT.NGAY_HT,B_TC,BT.MA_DVI_QL
        FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BC_TS TS,TEMP_BT_1 T
        WHERE BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID AND BT.MA_DVI_QL=T.DVI_XL AND BT.SO_ID=T.SO_ID AND T.LH_NV=NV.LH_NV
            AND BT.MA_DVI=BT.MA_DVI_XL AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD)  IN ('V','N')
            AND BT.MA_DVI_XL<>BT.MA_DVI_QL AND BT.MA_DVI_QL=TS.MA_DVI;
END IF;

IF PKH_MA_MA(B_TC,'H') THEN
    INSERT INTO TEMP_BT_2(MA_DVI,C2,C3,LH_NV,SO_ID,N2,N3,N4,N5,SO_ID_DT,N7,C5,C6)
        SELECT T.MA_DVI,BT.NV,T.C1 PHONG,NV.LH_NV,BT.SO_ID,PKH_NG_CSO(BT.NGAY_QD) NGAY_QD_N,SO_ID_HD,
                TIEN,TIEN_QD,NV.SO_ID_DT,BT.NGAY_HT,B_TC,BT.MA_DVI_QL
        FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BC_TS TS,TEMP_BT_1 T
        WHERE BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID AND BT.MA_DVI_QL=T.DVI_XL AND BT.SO_ID=T.SO_ID AND T.LH_NV=NV.LH_NV
            AND BT.MA_DVI=BT.MA_DVI_XL AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD)  IN ('V','N')
            AND BT.MA_DVI_XL<>BT.MA_DVI_QL AND BT.MA_DVI_XL=TS.MA_DVI;
END IF;

UPDATE TEMP_BT_2 T2 SET N8=(SELECT T2.N5 * MAX(T1.N2) FROM TEMP_BT_1 T1 
                                    WHERE T1.MA_DVI=T2.MA_DVI AND T1.SO_ID=T2.SO_ID AND T1.LH_NV=T2.LH_NV AND T1.N2<>0);  
--merge into temp_bt_2
--using temp_bt_1
--on (temp_bt_2.ma_dvi=temp_bt_1.ma_dvi and temp_bt_2.so_id=temp_bt_1.so_id and temp_bt_2.lh_nv=temp_bt_1.lh_nv
--and temp_bt_1.n2<>0 )
--when matched then
--update set temp_bt_2.n8 = temp_bt_2.n5 * temp_bt_1.n2;
UPDATE TEMP_BT_2 T2 SET N9=(SELECT SUM(T.N5) FROM TEMP_BT_2 T 
                                    WHERE T.MA_DVI=T2.MA_DVI AND T.SO_ID=T2.SO_ID AND T.LH_NV=T2.LH_NV);


UPDATE TEMP_BT_2 SET N1=ROUND(N8/N9,0) WHERE N9<>0;

INSERT INTO BC_BH_BT_HS_TEMP SELECT MA_DVI,SO_ID,C2,C3,LH_NV,N2,C6,N3,SO_ID_DT,N4,N1,N7,C5 FROM TEMP_BT_2;

DELETE FROM BC_BH_BT_HS_TEMP WHERE SUBSTR(LH_NV,1,2) NOT IN (SELECT NV FROM TEMP_BC_NV) AND PHONG NOT IN (SELECT PHONG FROM TEMP_BC_PHONG);

END;
/
create or replace PROCEDURE PBC_BH_BT_CGQ_TAI(b_tc varchar2)
AS
begin
delete temp_bt_1;delete temp_bt_2;delete temp_bt_3;
-- Lay so lieu trong bang bh_bt_hs_dp_ct
PBC_BH_BT_CQG_CT_TAI(b_tc);
-- Lay so lieu trong bang bh_bt_hs_dp
PBC_BH_BT_CQG_TAI(b_tc);
insert into temp_bt_2 (ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,n6,n7,so_id_dt,c1,c4,n8)
    select a.ma_dvi,a.c2,a.c3,a.lh_nv,a.so_id,a.n2,a.n3,a.n4,a.n5,nv.tien,nv.tien_qd,nv.so_id_dt,c1,c4,n6
    from temp_bt_3 a,bh_bt_hs_nv nv
    where a.ma_dvi=nv.ma_dvi and a.so_id=nv.so_id;
-- Tong hop so lieu
delete temp_bt_2 a where (a.ma_dvi,a.so_id) in (select b.ma_dvi,b.so_id from temp_bt_1 b);
update temp_bt_2 a set n9=(select sum(n7) from temp_bt_2 b where b.ma_dvi=a.ma_dvi and b.so_id=a.so_id group by b.ma_dvi,b.so_id);
update temp_bt_2 set n1= round(n7*n5/n9,0) where n9<>0;
insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c4,n6)
    select ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n1,so_id_dt,c4,n8 from temp_bt_2;
delete from temp_bt_1 where SUBSTR(lh_nv,1,2) not in (Select nv from temp_bc_nv) and c3 not in (Select phong from temp_bc_phong);

end; 
/
CREATE OR REPLACE PROCEDURE PBC_BH_BT_CQG_CT_TAI(b_tc varchar2)
-- Boi thuong chua giai quyet lay so lieu trong bang bh_bt_hs_dp_ct
AS
begin
-- Tu lam
if PKH_MA_MA(b_tc,'T') or PKH_MA_MA(b_tc,'*')  then --
insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,bt.so_id_hd,nv.tien,nv.tien_qd,bt.so_id_dt,'T',bt.ma_dvi_ql,bt.ngay_qd
    from bh_bt_hs bt,bh_bt_hs_dp_ct nv,(select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp_ct a,temp_bc_ts t
        where a.ma_dvi=t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,temp_bc_ts ts
    where bt.ma_dvi_xl=bt.ma_dvi_ql and
        bt.ma_dvi=ts.ma_dvi and bt.ma_dvi=ma_dvi_ql
        and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
        and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
        and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N')
        and bt.ngay_ht between ts.ngayd and ts.ngayc and ngay_qd>ts.ngayc;

--thang2d them vao truong hop dong bao hiem noi bo
end if;
-- Don vi khac lam ho
if PKH_MA_MA(b_tc,'N') or PKH_MA_MA(b_tc,'*') or PKH_MA_MA(b_tc,'T')  then
insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,bt.so_id_hd,nv.tien,nv.tien_qd,bt.so_id_dt,'N',bt.ma_dvi_ql,bt.ngay_qd
    from bh_bt_hs bt,bh_bt_hs_dp_ct nv,(select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp_ct a,temp_bc_ts t
        where a.ma_dvi=t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,temp_bc_ts ts
    where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi=ts.ma_dvi and bt.ma_dvi=ma_dvi_ql
        and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
        and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
        and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N')
        and bt.ngay_ht between ts.ngayd and ts.ngayc and ngay_qd>ts.ngayc;

end if;
--  lam ho don vi khac
IF PKH_MA_MA(B_TC,'H') OR PKH_MA_MA(B_TC,'*') THEN
INSERT INTO TEMP_BT_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c1,c4,n6)
SELECT DISTINCT bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,bt.so_id_hd,nv.tien,nv.tien_qd,bt.so_id_dt,'H',bt.ma_dvi_ql,bt.ngay_qd
    FROM BH_BT_HS BT,BH_BT_HS_NV NV,TEMP_BC_TS TS
    WHERE BT.MA_DVI_XL<>BT.MA_DVI_QL AND BT.MA_DVI=TS.MA_DVI AND BT.MA_DVI=MA_DVI_XL
        AND BT.MA_DVI=NV.MA_DVI AND BT.SO_ID=NV.SO_ID
        AND FBH_HD_KIEU_HD(BT.MA_DVI_QL,BT.SO_ID_HD)  in ('V','N')
        AND BT.NGAY_HT BETWEEN TS.NGAYD AND TS.NGAYC AND NGAY_QD>TS.NGAYC;
END IF;

delete from temp_bt_1 where SUBSTR(lh_nv,1,2) not in (Select nv from temp_bc_nv) and c3 not in (Select phong from temp_bc_phong);

end;
/
CREATE OR REPLACE PROCEDURE PBC_BH_BT_CQG_TAI(b_tc varchar2)
AS
begin
-- Boi thuong chua giai quyet lay so lieu trong bang bh_bt_hs_dp
-- Tu lam
if PKH_MA_MA(b_tc,'T') or PKH_MA_MA(b_tc,'*') then
insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
select distinct bt.ma_dvi,bt.nv,bt.phong,nv1.lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'T',bt.ma_dvi_ql,bt.ngay_qd
    from bh_bt_hs bt,bh_bt_hs_nv nv1,bh_bt_hs_dp nv,
        (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,bh_bt_hs_nv b,temp_bc_ts t
          where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.ma_dvi=t.ma_dvi 
                and round(ngay_dp,-2)<=round(t.ngayc,-2) and b.lh_nv is not null group by a.ma_dvi,a.so_id) dp,
            temp_bc_ts ts
    where bt.ma_dvi=ts.ma_dvi and bt.ma_dvi_xl=bt.ma_dvi_ql
        and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
        and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
        and bt.ma_dvi=nv1.ma_dvi and bt.so_id=nv1.so_id
        and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)in ('V','N')
        and bt.ngay_ht between ts.ngayd and ts.ngayc and ngay_qd>ts.ngayc;

end if;
--Don vi khac lam ho
if PKH_MA_MA(b_tc,'N') or PKH_MA_MA(b_tc,'*') or PKH_MA_MA(b_tc,'T') then
insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'N',bt.ma_dvi_ql,bt.ngay_qd
    from bh_bt_hs bt,bh_bt_hs_nv nv1,bh_bt_hs_dp nv,
        (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,bh_bt_hs_nv b,temp_bc_ts t
          where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.ma_dvi=t.ma_dvi
                and a.ma_dvi=t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
        temp_bc_ts ts
    where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi=ts.ma_dvi and bt.ma_dvi=bt.ma_dvi_ql
        and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
        and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
        and bt.ma_dvi=nv1.ma_dvi and bt.so_id=nv1.so_id
        and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd) in ('V','N')
        and bt.ngay_ht between ts.ngayd and ts.ngayc and ngay_qd>ts.ngayc;

end if;

--Lam ho don vi khac
if PKH_MA_MA(b_tc,'H') or PKH_MA_MA(b_tc,'*') then
insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,bt.so_id_hd,nv.tien,nv.tien_qd,'H',bt.ma_dvi_ql,bt.ngay_qd
    from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts
    where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi=ts.ma_dvi and bt.ma_dvi=bt.ma_dvi_xl
        and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
        and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd) in ('V','N')
        and bt.ngay_ht between ts.ngayd and ts.ngayc and ngay_qd>ts.ngayc;
end if;

delete from temp_bt_3 where SUBSTR(lh_nv,1,2) not in (Select nv from temp_bc_nv) and c3 not in (Select phong from temp_bc_phong);

end;
/
create or replace procedure PBC_BH_TH_BT_PB_MD_TAI (b_tc varchar2)
AS
begin
-- Lay du lieu boi thuong da phan bo chi phi theo Dong BH noi bo
delete temp_bt_1;delete temp_bt_2;delete bc_bh_bt_hs_temp;
insert into temp_bt_1(ma_dvi,so_id,lh_nv,n2,dvi_xl,c1) select pb.ma_dvi,so_id,lh_nv,tien_qd,pb.dvi_xl,pb.phong
    from bh_bt_hs_pb pb,temp_bc_ts ts where pb.ma_dvi=ts.ma_dvi and ngay_ht between ts.ngayd and ts.ngayc;


--chen nhung vu ton that duyet=0
insert into temp_bt_1(ma_dvi,so_id,lh_nv,n2,dvi_xl,c1)
    select nv.ma_dvi, nv.so_id, nv.lh_nv, 0, nv.ma_dvi,hs.phong
    from bh_bt_hs_nv nv,bh_bt_hs hs, temp_bc_ts ts
    where nv.ma_dvi=ts.ma_dvi and hs.so_id=nv.so_id and hs.ma_dvi=nv.ma_dvi
    and nv.tien_qd=0 and hs.ngay_qd<=ts.ngayc and hs.ngay_qd between ts.ngayd and ts.ngayc
    and nv.so_id not in (select so_id
        from bh_bt_hs_pb pb,temp_bc_ts ts where pb.ma_dvi=ts.ma_dvi and ngay_ht between ts.ngayd and ts.ngayc)
    group by nv.ma_dvi, nv.so_id, nv.lh_nv, nv.ma_dvi,hs.phong;

--Tat ca
if b_tc='*' then
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bt_1 t
        where bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and (bt.ma_dvi_ql=t.dvi_xl or bt.ma_dvi=bt.ma_dvi_xl) and bt.so_id=t.so_id and t.lh_nv=nv.lh_nv
            and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd) in ('V','N');



  /*-- Giam dong bao hiem neu co
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi, '', d.phong, t.lh_nv, 0, d.ngay_ht, t.so_id,
            tien, tien_qd, 0, d.ngay_ht, 'T', t.ma_dvi
            from bh_hd_do_pt t, bh_hd_do_tt d, temp_bc_ts ts
            where t.so_id_tt=d.so_id_tt and t.loai='DT_LE_BT' and t.nv='T' and t.ma_dvi=d.ma_dvi
            and t.ma_dvi=ts.ma_dvi; */


-- Khoan phai chi do Dong BH noi bo (khong phai don vi ky hop dong, khong phai don vi lam ho so boi thuong)
elsif b_tc='K' then
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts,temp_bt_1 t
        where bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=bt.ma_dvi_xl and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N')
            and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi_xl<>ts.ma_dvi and bt.ma_dvi_ql<>ts.ma_dvi;
end if;
--Tu lam
if PKH_MA_MA(b_tc,'T') then
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bt_1 t
        where bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id-- and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=bt.ma_dvi_xl and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N');

    -- chen them nguoi khac bt ho minh
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts,temp_bt_1 t
        where bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id-- and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=bt.ma_dvi_xl and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N')
            and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi_ql=ts.ma_dvi;



end if;
-- Nguoi khac lam ho
if PKH_MA_MA(b_tc,'N') then
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts,temp_bt_1 t
        where bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=bt.ma_dvi_xl and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N')
            and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi_ql=ts.ma_dvi;
end if;
-- lam ho nguoi khac
if PKH_MA_MA(b_tc,'H') then
    insert into temp_bt_2(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,n7,c5,c6)
        select t.ma_dvi,bt.nv,t.c1 phong,nv.lh_nv,bt.so_id,bt.ngay_qd ngay_qd_n,so_id_hd,
                tien,tien_qd,nv.so_id_dt,bt.ngay_ht,b_tc,bt.ma_dvi_ql
        from bh_bt_hs bt,bh_bt_hs_nv nv,temp_bc_ts ts,temp_bt_1 t
        where bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi_ql=t.dvi_xl and bt.so_id=t.so_id and t.lh_nv=nv.lh_nv
            and bt.ma_dvi=bt.ma_dvi_xl and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  in ('V','N')
            and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi_xl=ts.ma_dvi;
end if;

update temp_bt_2 t2 set n8=(select t2.n5 * max(t1.n2) from temp_bt_1 t1
                                    where t1.ma_dvi=t2.ma_dvi and t1.so_id=t2.so_id and t1.lh_nv=t2.lh_nv and t1.n2<>0);
update temp_bt_2 t2 set n9=(select sum(t.n5) from temp_bt_2 t
                                    where t.ma_dvi=t2.ma_dvi and t.so_id=t2.so_id and t.lh_nv=t2.lh_nv);
update temp_bt_2 set n1=round(n8/n9,0) where n9<>0;
insert into bc_bh_bt_hs_temp select ma_dvi,so_id,c2,c3,lh_nv,n2,c6,n3,so_id_dt,n4,n1,n7,c5 from temp_bt_2;

--Xoa cac nghiep vu khong duoc xem

delete from bc_bh_bt_hs_temp where SUBSTR(lh_nv,1,2) not in (Select nv from temp_bc_nv) and phong not in (Select phong from temp_bc_phong);

end;
/
DROP PROCEDURE PBC_THANG2D_BT_CQG;
CREATE OR REPLACE PROCEDURE PBC_THANG2D_BT_CQG(b_tc varchar2)
AS
begin
-- Boi thuong chua giai quyet lay so lieu trong bang bh_bt_hs_dp
-- Tu lam
if PKH_MA_MA(b_tc,'T') or PKH_MA_MA(b_tc,'*') then
    /*
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'T',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp nv,
                (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
                  where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                    temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi_xl=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,nv1.lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'T',bt.ma_dvi_ql,bt.ngay_qd
            from bh_bt_hs bt,bh_bt_hs_dp nv,bh_bt_hs_dp_ct nv1,
                (select a.ma_dvi,a.so_id,max(a.ngay_dp) ngay_dp from bh_bt_hs_dp a,bh_bt_hs_dp_ct b,temp_bc_ts t
                  where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.ngay_dp=b.ngay_dp and 
                        a.ma_dvi LIKE t.ma_dvi and round(a.ngay_dp,-2)<=round(t.ngayc,-2) and b.lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                    temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc
                and bt.ngay_qd>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and nv.ma_dvi=nv1.ma_dvi and nv.so_id=nv1.so_id and nv.ngay_dp=nv1.ngay_dp
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp;
end if;
--Don vi khac lam ho
if PKH_MA_MA(b_tc,'N') or PKH_MA_MA(b_tc,'*') or PKH_MA_MA(b_tc,'T') then
    /*
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'N',bt.ma_dvi_ql,PKH_NG_CSO(bt.ngay_qd)
            from bh_bt_hs bt,bh_bt_hs_dp nv,
                (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
                  where a.ma_dvi LIKE t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                temp_bc_ts ts
            where bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi LIKE ts.ma_dvi and bt.ma_dvi=ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ngay_ht between ts.ngayd and ts.ngayc and to_char(ngay_qd,'yyyymmdd')>ts.ngayc;
    */
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,lh_nv,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,'N',bt.ma_dvi_ql,bt.ngay_qd
            from bh_bt_hs bt,bh_bt_hs_dp nv,bh_bt_hs_dp_ct nv1,
                (select a.ma_dvi,a.so_id,max(a.ngay_dp) ngay_dp from bh_bt_hs_dp a,bh_bt_hs_dp_ct b,temp_bc_ts t
                  where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and a.ngay_dp=b.ngay_dp and 
                        a.ma_dvi LIKE t.ma_dvi and round(a.ngay_dp,-2)<=round(t.ngayc,-2) and lh_nv is not null group by a.ma_dvi,a.so_id) dp,
                temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc
                and bt.ngay_qd>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and bt.ma_dvi_xl<>bt.ma_dvi_ql and bt.ma_dvi=bt.ma_dvi_ql
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id
                and nv.ma_dvi=nv1.ma_dvi and nv.so_id=nv1.so_id and nv.ngay_dp=nv1.ngay_dp
                and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp;
end if;

--Lam ho don vi khac
if PKH_MA_MA(b_tc,'H') or PKH_MA_MA(b_tc,'*') then
    insert into temp_bt_3(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,c1,c4,n6)
        select distinct bt.ma_dvi,bt.nv,bt.phong,nv.lh_nv,bt.so_id,bt.ngay_ht,nv1.so_id_bs,nv.tien,nv.tien_qd,'H',bt.ma_dvi_ql,bt.ngay_qd
            from bh_bt_hs bt,bh_bt_hs_nv nv,bh_bt_chs_nv nv1,temp_bc_ts ts
            where bt.ma_dvi LIKE ts.ma_dvi and bt.ngay_ht between ts.ngayd and ts.ngayc
                and bt.ngay_qd>ts.ngayc
                and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)  not in ('V','N')
                and nv.ma_dvi=nv1.ma_dvi and nv.so_id=nv1.so_id
                and bt.ma_dvi_xl<>bt.ma_dvi_ql and  bt.ma_dvi=bt.ma_dvi_xl
                and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id;
end if;
commit;
end;
/
DROP PROCEDURE PBC_THANG2D_BT_CGQ_MD;
CREATE OR REPLACE PROCEDURE PBC_THANG2D_BT_CGQ_MD(b_tc varchar2)
AS
begin
--delete temp_bt_1;delete temp_bt_2;delete temp_bt_3;
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_1';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_2';
EXECUTE IMMEDIATE 'TRUNCATE TABLE temp_bt_3';

-- Lay so lieu trong bang bh_bt_hs_dp_ct
PBC_THANG2D_BT_CQG_CT(b_tc);
-- Lay so lieu trong bang bh_bt_hs_dp
PBC_THANG2D_BT_CQG(b_tc);
insert into temp_bt_2 (ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,n6,n7,so_id_dt,c1,c4,n8)
    select a.ma_dvi,a.c2,a.c3,a.lh_nv,a.so_id,a.n2,a.n3,a.n4,a.n5,nv.tien,nv.tien_qd,nv.so_id_dt,c1,c4,n6
    from temp_bt_3 a,bh_bt_hs_nv nv
    where a.ma_dvi=nv.ma_dvi and a.so_id=nv.so_id;
 
    
-- Tong hop so lieu
delete temp_bt_2 a where (a.ma_dvi,a.so_id) in (select b.ma_dvi,b.so_id from temp_bt_1 b);
update temp_bt_2 a set n9=(select sum(n7) from temp_bt_2 b where b.ma_dvi=a.ma_dvi and b.so_id=a.so_id group by b.ma_dvi,b.so_id);
update temp_bt_2 set n1= round(n7*n5/n9,0) where n9<>0;
insert into temp_bt_1(ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n5,so_id_dt,c4,n6) 
    select ma_dvi,c2,c3,lh_nv,so_id,n2,n3,n4,n1,so_id_dt,c4,n8 from temp_bt_2;

end;
/
DROP PROCEDURE BC_DTHU_TAI_VE_BH;
/
CREATE OR REPLACE PROCEDURE BC_DTHU_TAI_VE_BH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_lhnv varchar2, b_ngayd number, b_ngayc number,b_loi out varchar2)
as
begin
   -- ma_dvi,so_id,ngay_ht,so_id_ta_ps,nv,loai,goc,ma_nt,ma_dvi_hd,so_id_hd,so_id_dt,pthuc,ma_ta,nha_bh,lh_nv,pt,nt_tien,tien,nt_phi,phi,tl_thue,thue,pt_hh,hhong,kieu_hd,kieu_dt
    delete bh_bc_tbh_ve_bh_temp; commit;
    -- Lay doanh thu ban hang
/*
    insert into bh_bc_tbh_ve_bh_temp select a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
        d.ma_dvi_hd,d.so_id_hd,d.so_id_dt,a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,c.pt,
       -- d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong),a.so_id_dc,a.kieu  -- lay tien qd
         d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien_qd),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong_qd),a.so_id_dc,a.kieu
              from tbh_dc_pt a, tbh_ve_phi c, tbh_ve_pbo d
              where a.so_id_ta_ps=c.so_id and a.so_id_ta_ps=d.so_id and c.so_id = d.so_id
              and a.ngay_ht between b_ngayd and b_ngayc and (b_lhnv is null or d.lh_nv like b_lhnv||'%')
              and FBH_MA_LHNV_TAI(d.ma_dvi,d.lh_nv)=c.ma_ta and FBH_MA_LHNV_TAI(d.ma_dvi,d.lh_nv)=a.ma_ta
              and a.kieu in ('V','N') and c.tien > 0 and a.goc='HD_PS' --and so_id_dc=20150625015171
              group by  a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,d.ma_dvi_hd,d.so_id_hd,d.so_id_dt,
              a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,c.pt,d.nt_tien,a.ma_nt,a.so_id_dc,a.kieu;
              */
              /*
    insert into bh_bc_tbh_ve_bh_temp select a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
        d.ma_dvi_hd,d.so_id_hd,0,a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,0, -- tam bo so_id_dt
       -- d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong),a.so_id_dc,a.kieu  -- lay tien qd
         d.nt_tien,0,a.ma_nt,sum(a.tien_qd),0,sum(a.thue),0,sum(a.hhong_qd),a.so_id_dc,a.kieu
              from tbh_dc_pt a,tbh_ve_pbo d
              where a.so_id_ta_ps=d.so_id
              and a.ngay_ht between b_ngayd and b_ngayc and (b_lhnv is null or d.lh_nv like b_lhnv||'%')
              and FBH_MA_LHNV_TAI(d.ma_dvi,d.lh_nv)=a.ma_ta
              and a.kieu in ('V','N') and a.goc='HD_PS' --and so_id_dc=20150625015171
              group by  a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,d.ma_dvi_hd,d.so_id_hd,
              a.pthuc,a.ma_ta,a.nha_bh,d.lh_nv,d.nt_tien,a.ma_nt,a.so_id_dc,a.kieu;
*/
    insert into bh_bc_tbh_ve_bh_temp select a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
        '',0,0,a.pthuc,a.ma_ta,a.nha_bh,'',0, -- tam bo so_id_dt
       -- d.nt_tien,sum(c.tien),a.ma_nt,sum(a.tien),sum(c.tl_thue),sum(a.thue),max(c.pt_hh),sum(a.hhong),a.so_id_dc,a.kieu  -- lay tien qd
         '',0,a.ma_nt,sum(a.tien),0,sum(a.thue),0,sum(a.hhong),a.so_id_dc,a.kieu
              from tbh_dc_pt a
              where a.ngay_ht between b_ngayd and b_ngayc
              and a.kieu in ('V','N') and a.goc='HD_PS' -- and so_id_dc in (20150611005394,20150611005091)
              group by  a.ma_dvi,a.so_id_ps,a.ngay_ht,a.so_id_ta_ps,a.nv,a.loai,a.goc,a.ma_nt,
              a.pthuc,a.ma_ta,a.nha_bh,a.ma_nt,a.so_id_dc,a.kieu;
--     update bh_bc_tbh_ve_bh_temp a set (ma_dvi_hd,so_id_hd,so_id_dt,nt_tien,lh_nv)=(select max(ma_dvi_hd),max(so_id_hd),max(so_id_dt),max(nt_tien),max(lh_nv) from tbh_ve_pbo c
        --where a.ma_dvi=c.ma_dvi and a.so_id_ta_ps=c.so_id and (b_lhnv is null or c.lh_nv like b_lhnv||'%') and FBH_MA_LHNV_TAI(c.ma_dvi,c.lh_nv)=a.ma_ta); --SUA LAI THEO SO_ID sdbs
--         where a.ma_dvi=c.ma_dvi and a.so_id=c.so_id and (b_lhnv is null or c.lh_nv like b_lhnv||'%') and FBH_MA_LHNV_TAI(c.lh_nv)=a.ma_ta);
           --   pt_hh 4,tl_thue 6,tien 9,pt 11;
--     update bh_bc_tbh_ve_bh_temp a set (pt_hh,tl_thue,tien,pt)=(select max(pt_hh),max(tl_thue),sum(tien),max(pt) from tbh_ve_phi c
--         where a.ma_dvi=c.ma_dvi and a.so_id_ta_ps=c.so_id and c.tien > 0);

    --DQD sua
    --delete bh_bc_tbh_ve_bh where ngay_ht between b_ngayd and b_ngayc;
    --insert into bh_bc_tbh_ve_bh select * from bh_bc_tbh_ve_bh_temp;
    commit;
    exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;

/
