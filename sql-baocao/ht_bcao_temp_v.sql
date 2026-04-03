DROP VIEW V_BC_BH_BT_CQG;
CREATE OR REPLACE FORCE VIEW V_BC_BH_BT_CQG
(
    MA_DVI,
    NV,
    SO_HS,
    PHONG,
    NGAY_GUI,
    NGAY_XR,
    N_TRINH,
    N_DUYET,
    NGAY_QD,
    MA_NN,
    MA_MD,
    QUY_LOI,
    MA_NT,
    LH_NV,
    SO_ID,
    NGAY_HT_BT,
    SO_ID_HD,
    TIEN,
    TIEN_QD,
    SO_HD,
    MA_KH,
    NGAY_HT_HD,
    KIEU_HD,
    TTRANG
)
BEQUEATH DEFINER
AS
select distinct bt.ma_dvi,bt.nv,bt.so_hs,goc.phong,ngay_gui,ngay_xr,
        n_trinh,n_duyet,ngay_qd,''ma_nn,''ma_md,''quy_loi,nv.ma_nt,bt.so_id,bt.ngay_ht,nv.so_id_hd,nv.tien,nv.tien_qd,
        goc.so_hd,goc.ma_kh,goc.kieu_hd,goc.ttrang
    from bh_bt_hs bt,bh_bt_hs_dp nv,
            (select a.ma_dvi,a.so_id,max(ngay_dp) ngay_dp from bh_bt_hs_dp a,temp_bc_ts t
        where a.ma_dvi like t.ma_dvi and round(ngay_dp,-2)<=round(t.ngayc,-2) group by a.ma_dvi,a.so_id) dp,
            temp_bc_ts ts,  bh_hd_goc goc
    where bt.ma_dvi like ts.ma_dvi
        and bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi=nv.ma_dvi_ql
        and bt.ma_dvi=dp.ma_dvi and bt.so_id=dp.so_id and nv.ngay_dp=dp.ngay_dp
        and bt.ma_dvi=goc.ma_dvi and bt.so_id_hd=goc.so_id
        and FBH_HD_KIEU_HD(bt.ma_dvi_ql,bt.so_id_hd)<>'V'
        and bt.ngay_ht between ts.ngayd and ts.ngayc and ngay_qd>ts.ngayc;

DROP VIEW V_BC_BH_BT_GQ;

CREATE OR REPLACE FORCE VIEW V_BC_BH_BT_GQ
(
    MA_DVI,
    NV,
    SO_HS,
    PHONG,
    NGAY_GUI,
    NGAY_XR,
    N_TRINH,
    N_DUYET,
    NGAY_QD,
    MA_NN,
    MA_MD,
    QUY_LOI,
    MA_NT,
    LH_NV,
    SO_ID,
    SO_ID_HD,
    TIEN_BH,
    PT_BT,
    T_THAT,
    K_TRU,
    TIEN,
    TIEN_QD,
    SO_ID_DT,
    NGAY_HT_BT,
    SO_HD,
    MA_KH,
    NGAY_HT_HD,
    KIEU_HD,
    TTRANG
)
BEQUEATH DEFINER
AS
select distinct bt.ma_dvi,bt.nv,bt.so_hs,goc.phong,ngay_gui,
		ngay_xr,n_trinh,n_duyet,ngay_qd,'' ma_nn,'' ma_md,''quy_loi,ma_nt,lh_nv,bt.so_id,so_id_hd,tien_bh,
		pt_bt,t_that,'' k_tru,nv.tien,tien_qd,so_id_dt,bt.ngay_ht,goc.so_hd,goc.ma_kh,goc.ngay_ht,goc.kieu_hd,goc.ttrang
from bh_bt_hs bt,bh_bt_hs_nv nv,bh_hd_goc goc,temp_bc_ts ts
where  goc.ma_dvi like ts.ma_dvi and  nv.ma_dvi like ts.ma_dvi and 
        bt.ma_dvi=nv.ma_dvi and bt.so_id=nv.so_id and bt.ma_dvi=ma_dvi_ql and goc.ma_dvi=bt.ma_dvi and goc.so_id=bt.so_id_hd	
        and (bt.ngay_qd between ts.ngayd and ts.ngayc) and bt.ngay_qd<'30000101';

DROP VIEW V_BC_BH_DTBH_MA_DT;

CREATE OR REPLACE FORCE VIEW V_BC_BH_DTBH_MA_DT
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    NGUON,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    MA_DT,
    SO_ID,
    SO_ID_TT,
    NGAY,
    NGAY_HT,
    NGAY_HTNV,
    PHI,
    THUE,
    PHI_NT,
    THUE_NT,
    DBH,
    MA_DVIG
)
BEQUEATH DEFINER
AS
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,ma_nt,lh_nv,ma_dt,goc.so_id,so_id_tt,ngay,goc.ngay_ht,nv.ngay_tt,
    phi_qd,thue_qd,nv.phi,nv.thue,0,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpt nv
    where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and goc.kieu_hd <>'V' and pt<>'N' 

union all   
--giam doanh thu nhan truoc
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,ma_nt,lh_nv,ma_dt,goc.so_id,so_id_tt,ngay,goc.ngay_ht,nv.ngay_tt,
    -phi_qd,-thue_qd,-nv.phi,-nv.thue,4,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpt nv
    where  goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and goc.kieu_hd <>'V' and pt<>'N'
    and ((PKH_SO_NAM(ngay_tt)<PKH_SO_NAM(ngay) and add_months(PKH_SO_CDT(ngay_hl),12)<PKH_SO_CDT(ngay))
        or ( to_number(to_char(PKH_SO_CDT(ngay_hl),'yyyy'))<3000  and to_number(to_char(PKH_SO_CDT(ngay_hl),'yyyy'))>PKH_SO_NAM(ngay_tt)))
    and nv.ngay_tt>=20091001  and lh_nv not like 'KT%'
    
union all
--ket chuyen doanh thu nhan truoc
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,ma_nt,lh_nv,ma_dt,goc.so_id,so_id_tt,ngay,goc.ngay_ht,nv.ngay,
    phi_qd,thue_qd,nv.phi,nv.thue,5,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpt nv
    where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and pt<>'N'
    and ((PKH_SO_NAM(ngay_tt)<PKH_SO_NAM(ngay) and add_months(PKH_SO_CDT(ngay_hl),12)<PKH_SO_CDT(ngay)) 
        or (to_number(to_char(PKH_SO_CDT(ngay_hl),'yyyy'))<3000  and to_number(to_char(PKH_SO_CDT(ngay_hl),'yyyy'))>PKH_SO_NAM(ngay_tt)))
    and ngay_hl<nv.ngay
    and nv.ngay_tt >=20091001  and lh_nv not like 'KT%'
union all
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,ma_nt,lh_nv,ma_dt,goc.so_id,so_id_tt,ngay,goc.ngay_ht,(ngay_hl),
    phi_qd,thue_qd,nv.phi,nv.thue,5,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpt nv
    where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and pt<>'N'   
    and ngay_hl>=(nv.ngay)
    and ((PKH_SO_NAM(ngay_tt)<PKH_SO_NAM(ngay) and add_months(PKH_SO_CDT(ngay_hl),12)<PKH_SO_CDT(ngay))
        or (to_number(to_char(PKH_SO_CDT(ngay_hl),'yyyy'))<3000  and to_number(to_char(PKH_SO_CDT(ngay_hl),'yyyy'))>PKH_SO_NAM(ngay_tt)))
    and nv.ngay_tt>=20091001
union all
--giam dong bao hiem
select goc.ma_dvi,goc.so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,
    nv.ma_nt,nv.lh_nv,'',goc.so_id,nv.so_id_tt,nv.ngay_ht,goc.ngay_ht,nv.ngay_ht,
    decode(kieu,'V',tien_qd,-tien_qd), 0,decode(kieu,'V',nv.tien,-nv.tien),0,0,goc.ma_dvi from bh_hd_goc goc,bh_hd_do_pt nv, bh_hd_goc_ttpt c
    where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and nv.loai in ('CH_LE_PH','DT_LE_TL','DT_LE_HU') and c.so_id_tt = nv.so_id_ps and nv.lh_nv = c.lh_nv
    and c.ma_dvi = nv.ma_dvi

union all
--Dong bao hiem don vi
--tang cho don vi dong folow c19=DT
select nv.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,nv.phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,
    nv.ma_nt,nv.lh_nv,'',goc.so_id,nv.so_id_tt,pt.ngay,goc.ngay_ht,nv.ngay_ht,
    nv.phi_qd, 0,nv.phi,0,1,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpb nv,bh_hd_goc_ttpt pt
    where goc.ma_dvi=nv.dvi_xl and goc.so_id=nv.so_id
    and goc.ma_dvi=pt.ma_dvi and goc.so_id=pt.so_id and pt.so_id_tt=nv.so_id_tt
    
union all
--giam cho don vi dong leader c19='DG'
select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
    ngay_hl,ngay_hl,
    nv.ma_nt,nv.lh_nv,'',goc.so_id,nv.so_id_tt,pt.ngay,goc.ngay_ht,nv.ngay_ht,
    -nv.phi_qd, 0,-nv.phi,0,2,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpb nv,bh_hd_goc_ttpt pt
    where goc.ma_dvi=nv.dvi_xl and goc.so_id=nv.so_id
    and goc.ma_dvi=pt.ma_dvi and goc.so_id=pt.so_id and pt.so_id_tt=nv.so_id_tt;

DROP VIEW V_BC_BH_DTBH_MM;

CREATE OR REPLACE FORCE VIEW V_BC_BH_DTBH_MM
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    NGUON,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    SO_ID,
    SO_ID_TT,
    NGAY_HT,
    NGAY_HTNV,
    PHI,
    THUE,
    PHI_NT,
    THUE_NT,
    DBH,
    MA_DVIG
)
BEQUEATH DEFINER
AS
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay_ht,
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           0,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'N'
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
    UNION ALL
    /*
select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,ma_nt,lh_nv,goc.so_id,so_id_tt,goc.ngay_ht,nv.ngay_ht,
    phi_dt_qd,thue_qd,phi_dt,thue,0,goc.ma_dvi from bh_hd_goc goc,bh_hd_goc_ttpt nv,temp_bc_ts ts
    where goc.ma_dvi like ts.ma_dvi and  nv.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
    and goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and goc.kieu_hd not in ('V','N') and pt<>'N' union all
    */
    --giam doanh thu nhan truoc

    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay_tt,
           -phi_qd,
           -thue_qd,
           -nv.phi,
           -nv.thue,
           4,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'N'
           AND nv.ngay_tt >= 20091001
           AND nv.lh_nv NOT LIKE 'KT%'
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND (   (    PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                    AND ADD_MONTHS (PKH_SO_DATE (goc.ngay_hl), 12) <
                        PKH_SO_DATE (ngay))
                OR (    TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) <
                        3000
                    AND TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
                        PKH_SO_NAM (ngay_tt)))
    UNION ALL
    --ket chuyen doanh thu nhan truoc
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay,
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           5,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND (nv.ngay BETWEEN ts.ngayd AND ts.ngayc)
           AND nv.pt <> 'N'
           AND nv.ngay_tt >= 20091001
           AND nv.lh_nv NOT LIKE 'KT%'
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND goc.ngay_hl < nv.ngay
           AND (   (    PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                    AND ADD_MONTHS (PKH_SO_DATE (goc.ngay_hl), 12) <
                        PKH_SO_DATE (ngay))
                OR (    TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) <
                        3000
                    AND TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
                        PKH_SO_NAM (ngay_tt)))
    UNION ALL
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           (goc.ngay_hl),
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           5,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ngay_hl BETWEEN (ts.ngayd) AND (ts.ngayc)
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND nv.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND nv.pt <> 'N'
           AND goc.ngay_hl < nv.ngay
           AND (   (    PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                    AND ADD_MONTHS (PKH_SO_DATE (goc.ngay_hl), 12) <
                        PKH_SO_DATE (ngay))
                OR (    TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) <
                        3000
                    AND TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
                        PKH_SO_NAM (ngay_tt)))
           AND nv.ngay_tt >= 20091001
           AND nv.lh_nv NOT LIKE 'KT%'
    UNION ALL
    ----====================thang2d them vao xu ly truong hop ky thuat
    --giam doanh thu nhan truoc

    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay_tt,
           -phi_qd,
           -thue_qd,
           -nv.phi,
           -nv.thue,
           4,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND nv.pt <> 'N'
           AND (   (    PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                    AND ADD_MONTHS (PKH_SO_DATE (goc.ngay_hl), 12) <
                        PKH_SO_DATE (ngay))
                OR (    TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) <
                        3000
                    AND TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
                        PKH_SO_NAM (ngay_tt)))
           AND (nv.ngay_tt BETWEEN 20091001 AND 20101231)
           AND nv.lh_nv LIKE 'KT%'
           AND goc.ngay_ht < 20110101
    --          AND (goc.ma_dvi, goc.so_id) NOT IN
    --                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
    UNION ALL
    --ket chuyen doanh thu nhan truoc
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay,
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           5,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND (nv.ngay BETWEEN ts.ngayd AND ts.ngayc)
           AND nv.pt <> 'N'
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND goc.ngay_hl < nv.ngay
           AND (   (    PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                    AND ADD_MONTHS (PKH_SO_DATE (goc.ngay_hl), 12) <
                        PKH_SO_DATE (ngay))
                OR (    TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) <
                        3000
                    AND TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
                        PKH_SO_NAM (ngay_tt)))
           AND (nv.ngay_tt BETWEEN 20091001 AND 20101231)
           AND nv.lh_nv LIKE 'KT%'
           AND goc.ngay_ht < 20110101
    --          AND (goc.ma_dvi, goc.so_id) NOT IN
    --                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
    UNION ALL
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           (goc.ngay_hl),
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           5,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ngay_hl BETWEEN (ts.ngayd) AND (ts.ngayc)
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND nv.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND nv.pt <> 'N'
           AND ngay_hl >= (nv.ngay)
           AND (   (    PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                    AND ADD_MONTHS (PKH_SO_DATE (goc.ngay_hl), 12) <
                        PKH_SO_DATE (ngay))
                OR (    TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) <
                        3000
                    AND TO_NUMBER (
                            TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
                        PKH_SO_NAM (ngay_tt)))
           AND (nv.ngay_tt BETWEEN 20091001 AND 20101231)
           AND nv.lh_nv LIKE 'KT%'
           AND goc.ngay_ht < 20110101
    --          AND (goc.ma_dvi, goc.so_id) NOT IN
    --                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
    UNION ALL
    ----Xu ly tiep don ky thuat co ngay hieu luc <>nam ps hop dong va nam thanh toan
    --Giam doanh thu nhan truoc
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay_tt,
           -phi_qd,
           -thue_qd,
           -nv.phi,
           -nv.thue,
           4,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'N'
           AND nv.lh_nv LIKE 'KT%'
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND TO_NUMBER (TO_CHAR (goc.ngay_hl, 'yyyy')) < 3000
           AND TO_NUMBER (TO_CHAR (goc.ngay_hl, 'yyyy')) >
               PKH_SO_NAM (nv.ngay_tt)
           AND goc.ngay_ht < 20110101
    --          AND (goc.ma_dvi, goc.so_id) NOT IN
    --                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
    UNION ALL
    --Ket chuyen doanh thu nhan truoc
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay,
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           5,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND (nv.ngay BETWEEN ts.ngayd AND ts.ngayc)
           AND nv.pt <> 'N'
           AND nv.lh_nv LIKE 'KT%'
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND goc.ngay_hl < nv.ngay
           AND TO_NUMBER (TO_CHAR (goc.ngay_hl, 'yyyy')) < 3000
           AND TO_NUMBER (TO_CHAR (goc.ngay_hl, 'yyyy')) >
               PKH_SO_NAM (nv.ngay_tt)
           AND goc.ngay_ht < 20110101
    --          AND (goc.ma_dvi, goc.so_id) NOT IN
    --                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
    UNION ALL
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           (goc.ngay_hl),
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           5,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ngay_hl BETWEEN (ts.ngayd) AND (ts.ngayc)
           AND goc.kieu_hd NOT IN ('V', 'N')
           AND nv.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND nv.pt <> 'N'
           AND goc.ngay_hl < nv.ngay
           AND TO_NUMBER (TO_CHAR (ngay_hl, 'yyyy')) < 3000
           AND TO_NUMBER (TO_CHAR (PKH_SO_DATE (goc.ngay_hl), 'yyyy')) >
               PKH_SO_NAM (ngay_tt)
           AND nv.lh_nv LIKE 'KT%'
           AND goc.ngay_ht < 20110101
    --          AND (goc.ma_dvi, goc.so_id) NOT IN
    --                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
    UNION ALL
    ----======================================ket thuc thang2d them vao

    --giam dong bao hiem
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           nv.ma_nt,
           nv.lh_nv,
           goc.so_id,
           nv.so_id_tt,
           goc.ngay_ht,
           nv.ngay_ht,
           DECODE (kieu, 'V', tien_qd, -tien_qd),
           0,
           DECODE (kieu, 'V', nv.tien, -nv.tien),
           0,
           3,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_do_pt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.loai IN ('CH_LE_PH', 'DT_LE_TL', 'DT_LE_HU')
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
    UNION ALL
    /*
    select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
        ngay_hl,ngay_kt,
        ma_nt,lh_nv,goc.so_id,so_id_tt,goc.ngay_ht,nv.ngay_ht,
        decode(kieu,'V',tien_qd,-tien_qd), 0,decode(kieu,'V',tien,-tien),0,3,goc.ma_dvi from bh_hd_goc goc,bh_hd_do_pt nv,bh_hd_goc_ttpt pt, temp_bc_ts ts
        where goc.ma_dvi like ts.ma_dvi and nv.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
        and goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and nv.loai in ('CH_LE_PH','DT_LE_TL','DT_LE_HU') union all
    */
    --Dong bao hiem don vi
    --tang cho don vi dong folow c19=DT
    SELECT nv.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           nv.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay_ht,
           phi_qd,
           0,
           nv.phi,
           0,
           1,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'N'
           AND nv.pthuc IN ('D', 'P')
           AND goc.ma_dvi = nv.dvi_xl
           AND goc.so_id = nv.so_id
    UNION ALL
    --giam cho don vi dong leader c19='DG'
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           goc.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           so_id_tt,
           goc.ngay_ht,
           nv.ngay_ht,
           -phi_qd,
           0,
           -nv.phi,
           0,
           2,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
     WHERE     goc.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'N'
           AND nv.pthuc IN ('D', 'P')
           AND goc.ma_dvi = nv.dvi_xl
           AND goc.so_id = nv.so_id;

DROP VIEW V_BC_BH_DTBH_NTM;

CREATE OR REPLACE FORCE VIEW V_BC_BH_DTBH_NTM
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    NGUON,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    SO_ID,
    NGAY_HT,
    NGAY_HTNV,
    PHI,
    THUE,
    PHI_NT,
    THUE_NT,
    NGAY,
    NGAY_TT,
    SO_ID_TT,
    TC
)
BEQUEATH DEFINER
AS
SELECT goc.ma_dvi,
          so_hd,
          nv,
          kieu_hd,
          ma_kh,
          '',
          cb_ql,
          phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          ma_nt,
          lh_nv,
          goc.so_id,
          goc.ngay_ht,
          nv.ngay_tt,
          -phi_qd,
          -thue_qd,
          -nv.phi,
          -nv.thue,
          ngay,
          ngay_tt,
          so_id_tt,
          3
     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
    WHERE 
          --goc.ma_dvi LIKE ts.ma_dvi AND 
          nv.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
          AND goc.ma_dvi = nv.ma_dvi
          AND goc.so_id = nv.so_id
          AND goc.kieu_hd NOT IN ('V', 'N')
          AND pt <> 'N'
          AND ( (PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                 AND ADD_MONTHS (PKH_SO_CDT(ngay_hl), 12) < PKH_SO_CDT (ngay))
               OR (TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) < 3000
                   AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy'))>
                          PKH_SO_NAM (ngay_tt)))
          AND nv.ngay_tt >= 20091001
          --AND lh_nv NOT LIKE 'KT%'
   UNION ALL
   SELECT goc.ma_dvi,
          so_hd,
          nv,
          kieu_hd,
          ma_kh,
          '',
          cb_ql,
          phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          ma_nt,
          lh_nv,
          goc.so_id,
          goc.ngay_ht,
          nv.ngay_tt,
          phi_qd,
          thue_qd,
          nv.phi,
          nv.thue,
          ngay,
          ngay_tt,
          so_id_tt,
          1
     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
    WHERE 
          --goc.ma_dvi LIKE ts.ma_dvi AND 
          nv.ma_dvi LIKE ts.ma_dvi
          AND (nv.ngay BETWEEN ts.ngayd AND ts.ngayc)
          AND goc.ma_dvi = nv.ma_dvi
          AND goc.so_id = nv.so_id
          AND pt <> 'N'
          AND goc.kieu_hd NOT IN ('V', 'N')
          AND ngay_hl < nv.ngay
          AND ( (PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                 AND ADD_MONTHS (PKH_SO_CDT(ngay_hl), 12) < PKH_SO_CDT (ngay))
               OR (TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) < 3000
                   AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) >
                          PKH_SO_NAM (ngay_tt)))
          AND nv.ngay_tt >= 20091001
          --AND lh_nv NOT LIKE 'KT%'
   UNION ALL
   SELECT goc.ma_dvi,
          so_hd,
          nv,
          kieu_hd,
          ma_kh,
          '',
          cb_ql,
          phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          ma_nt,
          lh_nv,
          goc.so_id,
          TO_NUMBER (TO_CHAR (ngay_hl, 'yyyymmdd')),
          nv.ngay_tt,
          phi_qd,
          thue_qd,
          nv.phi,
          nv.thue,
          ngay,
          ngay_tt,
          so_id_tt,
          2
     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
    WHERE     
          --goc.ma_dvi LIKE ts.ma_dvi AND 
          nv.ma_dvi LIKE ts.ma_dvi
          AND goc.ma_dvi = nv.ma_dvi
          AND goc.so_id = nv.so_id
          AND pt <> 'N'
          AND goc.kieu_hd NOT IN ('V', 'N')
          AND ngay_hl BETWEEN ts.ngayd and ts.ngayc
          AND ngay_hl >= nv.ngay
          AND ( (PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
                 AND ADD_MONTHS (PKH_SO_CDT(ngay_hl), 12) < PKH_SO_CDT (ngay))
               OR (TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) < 3000
                   AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) >
                          PKH_SO_NAM (ngay_tt)))
          AND nv.ngay_tt >= 20091001
          --AND lh_nv NOT LIKE 'KT%'

  -- UNION ALL
   ----them vao xu ly truong hop don bao hiem ky thuat
--   SELECT goc.ma_dvi,
--          so_hd,
--          nv,
--          kieu_hd,
--          ma_kh,
--          '',
--          cb_ql,
--          phong,
--          kieu_kt,
--          ma_kt,
--          ngay_hl,
--          ngay_kt,
--          ma_nt,
--          lh_nv,
--          goc.so_id,
--          goc.ngay_ht,
--          nv.ngay_tt,
--          -phi_qd,
--          -thue_qd,
--          -phi,
--          -thue,
--          ngay,
--          ngay_tt,
--          so_id_tt,
--          3
--     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
--    WHERE     
--          --goc.ma_dvi LIKE ts.ma_dvi AND 
--          nv.ma_dvi LIKE ts.ma_dvi
--          AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
--          AND goc.ma_dvi = nv.ma_dvi
--          AND goc.so_id = nv.so_id
--          AND goc.kieu_hd NOT IN ('V', 'N')
--          AND pt <> 'N'
--          AND ( (PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
--                 AND ADD_MONTHS (PKH_SO_CDT(ngay_hl), 12) < PKH_SO_CDT (ngay))
--               OR (TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) < 3000
--                   AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) >
--                          PKH_SO_NAM (ngay_tt)))
--          AND nv.ngay_tt >= 20091001
--          AND lh_nv LIKE 'KT%'
--          AND goc.ngay_ht <= 20101231
--          AND (goc.ma_dvi, goc.so_id) NOT IN
--                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
--   UNION ALL
--   SELECT goc.ma_dvi,
--          so_hd,
--          nv,
--          kieu_hd,
--          ma_kh,
--          '',
--          cb_ql,
--          phong,
--          kieu_kt,
--          ma_kt,
--          ngay_hl,
--          ngay_kt,
--          ma_nt,
--          lh_nv,
--          goc.so_id,
--          goc.ngay_ht,
--          nv.ngay_tt,
--          phi_qd,
--          thue_qd,
--          phi,
--          thue,
--          ngay,
--          ngay_tt,
--          so_id_tt,
--          1
--     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
--    WHERE     
--          --goc.ma_dvi LIKE ts.ma_dvi AND 
--          nv.ma_dvi LIKE ts.ma_dvi
--          AND (nv.ngay BETWEEN ts.ngayd AND ts.ngayc)
--          AND goc.ma_dvi = nv.ma_dvi
--          AND goc.so_id = nv.so_id
--          AND pt <> 'N'
--          AND goc.kieu_hd NOT IN ('V', 'N')
--          AND ngay_hl < nv.ngay
--          AND ( (PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
--                 AND ADD_MONTHS (PKH_SO_CDT(ngay_hl), 12) < PKH_SO_CDT (ngay))
--               OR (TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) < 3000
--                   AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) >
--                          PKH_SO_NAM (ngay_tt)))
--          AND nv.ngay_tt >= 20091001
--          AND lh_nv LIKE 'KT%'
--          AND goc.ngay_ht <= 20101231
--          AND (goc.ma_dvi, goc.so_id) NOT IN
--                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
--   UNION ALL
--   SELECT goc.ma_dvi,
--          so_hd,
--          nv,
--          kieu_hd,
--          ma_kh,
--          '',
--          cb_ql,
--          phong,
--          kieu_kt,
--          ma_kt,
--          ngay_hl,
--          ngay_kt,
--          ma_nt,
--          lh_nv,
--          goc.so_id,
--          TO_NUMBER (TO_CHAR (ngay_hl, 'yyyymmdd')),
--          nv.ngay_tt,
--          phi_qd,
--          thue_qd,
--          phi,
--          thue,
--          ngay,
--          ngay_tt,
--          so_id_tt,
--          2
--     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
--    WHERE     
--          --goc.ma_dvi LIKE ts.ma_dvi AND 
--          nv.ma_dvi LIKE ts.ma_dvi
--          AND goc.ma_dvi = nv.ma_dvi
--          AND goc.so_id = nv.so_id
--          AND pt <> 'N'
--          AND goc.kieu_hd NOT IN ('V', 'N')
--          AND ngay_hl BETWEEN ts.ngayd and ts.ngayc
--          AND ngay_hl >= nv.ngay
--          AND ( (PKH_SO_NAM (ngay_tt) < PKH_SO_NAM (ngay)
--                 AND ADD_MONTHS (PKH_SO_CDT(ngay_hl), 12) < PKH_SO_CDT (ngay))
--               OR (TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) < 3000
--                   AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) >
--                          PKH_SO_NAM (ngay_tt)))
--          AND nv.ngay_tt >= 20091001
--          AND lh_nv LIKE 'KT%'
--          AND goc.ngay_ht <= 20101231
--          AND (goc.ma_dvi, goc.so_id) NOT IN
--                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
--   UNION ALL
--   ------Xu ly tiep truong hop don ky thuat nhan truoc co thoi han hieu luc cua nam khac nhung thanh toan thoi diem hien tai
--   SELECT goc.ma_dvi,
--          so_hd,
--          nv,
--          kieu_hd,
--          ma_kh,
--          '',
--          cb_ql,
--          phong,
--          kieu_kt,
--          ma_kt,
--          ngay_hl,
--          ngay_kt,
--          ma_nt,
--          lh_nv,
--          goc.so_id,
--          goc.ngay_ht,
--          nv.ngay_tt,
--          -phi_qd,
--          -thue_qd,
--          -phi,
--          -thue,
--          ngay,
--          ngay_tt,
--          so_id_tt,
--          3
--     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
--    WHERE     
--          --goc.ma_dvi LIKE ts.ma_dvi AND 
--          nv.ma_dvi LIKE ts.ma_dvi
--          AND nv.ngay_tt BETWEEN ts.ngayd AND ts.ngayc
--          AND goc.ma_dvi = nv.ma_dvi
--          AND goc.so_id = nv.so_id
--          AND goc.kieu_hd NOT IN ('V', 'N')
--          AND pt <> 'N'
--          AND TO_NUMBER (TO_CHAR (ngay_hl, 'yyyy')) < 3000
--          AND TO_NUMBER (TO_CHAR (ngay_hl, 'yyyy')) >PKH_SO_NAM (ngay_tt)   
--          AND nv.ngay_tt >= 20110101
--          AND lh_nv LIKE 'KT%'
--          AND goc.ngay_ht <= 20101231
--          AND (goc.ma_dvi, goc.so_id) NOT IN
--                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
--   UNION ALL
--   SELECT goc.ma_dvi,
--          so_hd,
--          nv,
--          kieu_hd,
--          ma_kh,
--          '',
--          cb_ql,
--          phong,
--          kieu_kt,
--          ma_kt,
--          ngay_hl,
--          ngay_kt,
--          ma_nt,
--          lh_nv,
--          goc.so_id,
--          goc.ngay_ht,
--          nv.ngay_tt,
--          phi_qd,
--          thue_qd,
--          phi,
--          thue,
--          ngay,
--          ngay_tt,
--          so_id_tt,
--          1
--     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
--    WHERE     
--          --goc.ma_dvi LIKE ts.ma_dvi AND 
--          nv.ma_dvi LIKE ts.ma_dvi
--          AND (nv.ngay BETWEEN ts.ngayd AND ts.ngayc)
--          AND goc.ma_dvi = nv.ma_dvi
--          AND goc.so_id = nv.so_id
--          AND pt <> 'N'
--          AND goc.kieu_hd NOT IN ('V', 'N')
--          AND ngay_hl < nv.ngay
--          AND TO_NUMBER (TO_CHAR (ngay_hl, 'yyyy')) < 3000
--          AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) > PKH_SO_NAM (ngay_tt) 
--          AND nv.ngay_tt >= 20110101
--          AND lh_nv LIKE 'KT%'
--          AND goc.ngay_ht <= 20101231
--          AND (goc.ma_dvi, goc.so_id) NOT IN
--                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
--   UNION ALL
--   SELECT goc.ma_dvi,
--          so_hd,
--          nv,
--          kieu_hd,
--          ma_kh,
--          '',
--          cb_ql,
--          phong,
--          kieu_kt,
--          ma_kt,
--          ngay_hl,
--          ngay_kt,
--          ma_nt,
--          lh_nv,
--          goc.so_id,
--          TO_NUMBER (TO_CHAR (ngay_hl, 'yyyymmdd')),
--          nv.ngay_tt,
--          phi_qd,
--          thue_qd,
--          phi,
--          thue,
--          ngay,
--          ngay_tt,
--          so_id_tt,
--          2
--     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
--    WHERE     
--          --goc.ma_dvi LIKE ts.ma_dvi AND 
--          nv.ma_dvi LIKE ts.ma_dvi
--          AND goc.ma_dvi = nv.ma_dvi
--          AND goc.so_id = nv.so_id
--          AND pt <> 'N'
--          AND goc.kieu_hd NOT IN ('V', 'N')
--          AND ngay_hl BETWEEN ts.ngayd and ts.ngayc
--          AND ngay_hl >= nv.ngay
--          AND TO_NUMBER (TO_CHAR (ngay_hl, 'yyyy')) < 3000
--          AND TO_NUMBER (TO_CHAR (PKH_SO_CDT(ngay_hl), 'yyyy')) > PKH_SO_NAM (ngay_tt) 
--          AND nv.ngay_tt >= 20110101
--          AND lh_nv LIKE 'KT%'
--          AND goc.ngay_ht <= 20101231
--          AND (goc.ma_dvi, goc.so_id) NOT IN
--                 (SELECT ma_dvi, so_id FROM bh_thang2d_loai_dtnt)
;

DROP VIEW V_BC_BH_DTPS_MM;

CREATE OR REPLACE FORCE VIEW V_BC_BH_DTPS_MM
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    NGUON,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    SO_ID,
    NGAY_HT,
    NGAY_HTNV,
    PHI,
    THUE,
    PHI_NT,
    THUE_NT,
    SO_ID_XL,
    MA_DVIG
)
BEQUEATH DEFINER
AS
    SELECT goc.ma_dvi,
           so_hd,
           nv,
           goc.kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_ht,
           CASE ma_nt
               WHEN 'VND'
               THEN
                   nv.phi
               ELSE
                   FTT_VND_QD (goc.ma_dvi,
                               nv.ngay_ht,
                               ma_nt,
                               nv.phi)
           END,
           CASE ma_nt
               WHEN 'VND'
               THEN
                   nv.thue
               ELSE
                   FTT_VND_QD (goc.ma_dvi,
                               nv.ngay_ht,
                               ma_nt,
                               nv.thue)
           END,
           nv.phi,
           nv.thue,
           so_id_xl,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_cl nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND FBH_HD_KIEU_HD (goc.ma_dvi, goc.so_id_d) NOT IN ('V', 'N')
           AND goc.ttrang = 'D'
    UNION ALL
    /*
    --giam dong bao hiem
    select goc.ma_dvi,so_hd,nv,goc.kieu_hd,ma_kh,cb_ql,goc.phong,kieu_kt,ma_kt,
        ngay_hl,ngay_kt,
        ma_nt,nv.lh_nv,goc.so_id,goc.ngay_ht,nv.ngay_ht,
         -FTT_VND_QD(goc.ma_dvi,goc.ngay_ht,ma_nt,phi)*c.pt/100,0,-phi,0,so_id_xl
        from bh_hd_goc goc,bh_hd_goc_cl nv,(select * from bh_hd_do_tl where pthuc='C' or ph='K' or kieu='D') c,temp_bc_ts ts
        where goc.ma_dvi like ts.ma_dvi and  nv.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
        and goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=c.ma_dvi
        and goc.so_id=nv.so_id and nv.so_id=c.so_id and nv.lh_nv=c.lh_nv union all
    */
    --Huy toan bo don khi khong tra lai tien
    SELECT goc.ma_dvi,
           so_hd,
           nv,
           goc.kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           goc.ngay_ht,
           c.n2,
           -(CASE ma_nt
                 WHEN 'VND'
                 THEN
                     nv.phi
                 ELSE
                     FTT_VND_QD (goc.ma_dvi,
                                 nv.ngay_ht,
                                 ma_nt,
                                 nv.phi)
             END),
           -(CASE ma_nt
                 WHEN 'VND'
                 THEN
                     nv.thue
                 ELSE
                     FTT_VND_QD (goc.ma_dvi,
                                 nv.ngay_ht,
                                 ma_nt,
                                 nv.thue)
             END),
           -nv.phi,
           -nv.thue,
           0,
           goc.ma_dvi
      FROM bh_hd_goc     goc,
           bh_hd_goc_cl  nv,
           (SELECT ma_dvi      c1,
                   so_id       n1,
                   ngay_ht     n2,
                   ton         n3
              FROM bh_hd_goc_hups
             WHERE tra = 0) c,
           temp_bc_ts    ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND n2 BETWEEN ts.ngayd AND ts.ngayc
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.ma_dvi = c1
           AND goc.so_id = nv.so_id
           AND goc.so_id = c.n1
           AND FBH_HD_KIEU_HD (goc.ma_dvi, goc.so_id_d) NOT IN ('V', 'N')
           AND goc.ttrang = 'D'
    UNION ALL
    --cong phan da thu duoc phi
    SELECT goc.ma_dvi,
           so_hd,
           nv,
           goc.kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           goc.ngay_ht,
           c.n2,
           phi_qd,
           thue_qd,
           nv.phi,
           nv.thue,
           0,
           goc.ma_dvi
      FROM bh_hd_goc       goc,
           bh_hd_goc_ttpt  nv,
           (SELECT ma_dvi      c1,
                   so_id       n1,
                   ngay_ht     n2,
                   ton         n3
              FROM bh_hd_goc_hups
             WHERE tra = 0) c,
           temp_bc_ts      ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND n2 BETWEEN ts.ngayd AND ts.ngayc
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.ma_dvi = c1
           AND goc.so_id = nv.so_id
           AND goc.so_id = c.n1
           AND FBH_HD_KIEU_HD (goc.ma_dvi, goc.so_id_d) NOT IN ('V', 'N')
           AND goc.ttrang = 'D'
    UNION ALL
    --END Huy toan bo don khi khong  tra lai tien
    --Huy tra lai tien
    SELECT goc.ma_dvi,
           so_hd,
           nv,
           goc.kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           goc.so_id,
           goc.ngay_ht,
           c.n2,
           CASE ma_nt
               WHEN 'VND'
               THEN
                   nv.phi
               ELSE
                   FTT_VND_QD (goc.ma_dvi,
                               nv.ngay_ht,
                               ma_nt,
                               nv.phi)
           END,
           CASE ma_nt
               WHEN 'VND'
               THEN
                   nv.thue
               ELSE
                   FTT_VND_QD (goc.ma_dvi,
                               nv.ngay_ht,
                               ma_nt,
                               nv.thue)
           END,
           nv.phi,
           nv.thue,
           0,
           goc.ma_dvi
      FROM bh_hd_goc       goc,
           bh_hd_goc_ttpt  nv,
           (SELECT ma_dvi c1, so_id n1, ngay_ht n2
              FROM bh_hd_goc_hups
             WHERE tra <> 0) c,
           temp_bc_ts      ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND n2 BETWEEN ts.ngayd AND ts.ngayc
           AND nv.so_id_tt = nv.so_id
           AND nv.pt <> 'N'
           AND nv.phi < 0
           AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.ma_dvi = c1
           AND goc.so_id = nv.so_id
           AND goc.so_id = c.n1
           AND FBH_HD_KIEU_HD (goc.ma_dvi, goc.so_id_d) NOT IN ('V', 'N')
           AND goc.ttrang = 'D'
    UNION ALL
    SELECT pb.ma_dvi,
           so_hd,
           goc.nv,
           goc.kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           pb.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           pb.ma_nt,
           pb.lh_nv,
           goc.so_id,
           goc.ngay_ht,
           goc.ngay_ht,
           pb.phi_qd,
           0,
           pb.phi,
           0,
           so_id_tt,
           goc.ma_dvi
      FROM bh_hd_goc goc, temp_bc_ts ts, bh_hd_goc_ttpb pb
     WHERE     pb.ma_dvi LIKE ts.ma_dvi
           AND goc.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND goc.ma_dvi = pb.dvi_xl
           AND goc.so_id = pb.so_id
           AND pb.pt IN ('N', 'G')
           AND FBH_HD_KIEU_HD (goc.ma_dvi, goc.so_id_d) <> 'V'
    UNION ALL
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           goc.kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           goc.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           pb.ma_nt,
           pb.lh_nv,
           goc.so_id,
           goc.ngay_ht,
           goc.ngay_ht,
           -pb.phi_qd,
           0,
           pb.phi,
           0,
           so_id_tt,
           goc.ma_dvi
      FROM bh_hd_goc goc, temp_bc_ts ts, bh_hd_goc_ttpb pb
     WHERE     goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND goc.ma_dvi = pb.ma_dvi
           AND goc.so_id = pb.so_id
           AND pb.pt IN ('N', 'G')
           AND FBH_HD_KIEU_HD (goc.ma_dvi, goc.so_id_d) <> 'V';

DROP VIEW V_BC_BH_DTTT_M;

CREATE OR REPLACE FORCE VIEW V_BC_BH_DTTT_M
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    SO_ID_TT,
    SO_ID,
    NGAY_HT,
    NGAY_HTNV,
    PHI,
    THUE,
    HHONG,
    HHONG_NT,
    HTRO,
    HTRO_NT,
    PT
)
BEQUEATH DEFINER
AS
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,cb_ql,phong,kieu_kt,ma_kt,
	PKH_SO_CNG(NGAY_HL),PKH_SO_CNG(NGAY_KT),ma_nt,lh_nv,nv.so_id_tt,goc.so_id,goc.ngay_ht,nv.ngay_tt,
	phi_qd,thue_qd,FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong),nv.hhong,FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro),nv.htro,pt
	from bh_hd_goc goc,bh_hd_goc_ttpt nv where goc.ma_dvi=nv.ma_dvi
	and goc.so_id=nv.so_id  and kieu_hd <>'V' and pt<>'C' union all
    --so tren bao gom ca so huy chua thu tien
--loai tru cac mon huy chua thu tien
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,cb_ql,phong,kieu_kt,ma_kt,
	PKH_SO_CNG(NGAY_HL),PKH_SO_CNG(NGAY_HL),nv.ma_nt,lh_nv,nv.so_id_tt,goc.so_id,goc.ngay_ht,nv.ngay_tt,
	-phi_qd,-thue_qd,-FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong),-nv.hhong,
	-FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro),-nv.htro,pt from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_goc_hups c
	where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id  and goc.ma_dvi=c.ma_dvi and  goc.so_id=c.so_id and nv.ma_nt=c.ma_nt
	and no<>0 and tra=0 and kieu_hd <>'V' and pt<>'C' and nv.phi<0 and nv.so_id=so_id_tt union all
--giam dong bao hiem di
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,cb_ql,goc.phong,kieu_kt,ma_kt,
	PKH_SO_CNG(NGAY_HL),PKH_SO_CNG(NGAY_KT),
	ma_nt,nv.lh_nv,nv.so_id_tt,goc.so_id,goc.ngay_ht,nv.ngay_tt,
	-phi_qd*c.pt/100,-thue_qd*c.pt/100,0,0,0,0,''
	from bh_hd_goc goc,bh_hd_goc_ttpt nv,(select * from bh_hd_do_tl where kieu='D' and pthuc='C' ) c
	where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=c.ma_dvi 
	and goc.so_id=nv.so_id  and nv.so_id=c.so_id and kieu_hd not in ('V','U','K') and nv.lh_nv=c.lh_nv and nv.pt<>'C' union all
--Dong bao hiem don vi
--tang cho don vi dong folow 
select decode(b.pthuc,'D',b.nha_bh,goc.ma_dvi),so_hd,nv,kieu_hd,ma_kh,cb_ql,b.phong,kieu_kt,ma_kt,
	PKH_SO_CNG(NGAY_HL),PKH_SO_CNG(NGAY_KT),
	ma_nt,nv.lh_nv,nv.so_id_tt,goc.so_id,goc.ngay_ht,nv.ngay_ht,
	phi_qd*b.pt/100, 0,0,0,0,0,'G' from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_do_tl b 
	where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=b.ma_dvi 
	and goc.so_id=nv.so_id and nv.so_id=b.so_id and nv.lh_nv=b.lh_nv
	and kieu_hd <>'V' and nv.pt<>'C' and b.kieu='D'  and b.pthuc in ('D','P') and so_id_tt<>20110129023840 union all

--Giam cho don vi dong leader (don vi goc)
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,cb_ql,goc.phong,kieu_kt,ma_kt,
	PKH_SO_CNG(NGAY_HL),PKH_SO_CNG(NGAY_KT),
	ma_nt,nv.lh_nv,nv.so_id_tt,goc.so_id,goc.ngay_ht,nv.ngay_ht,
	-phi_qd*b.pt/100, 0,0,0,0,0,'G' from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_do_tl b 
	where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=b.ma_dvi and nv.lh_nv=b.lh_nv
	and goc.so_id=nv.so_id and nv.so_id=b.so_id and kieu_hd <>'V' 
	and nv.pt<>'C' and b.kieu='D'  and  b.pthuc in ('D','P') and so_id_tt<>20110129023840;

DROP VIEW V_BC_BH_DTTT_MA_DT;


CREATE OR REPLACE FORCE VIEW V_BC_BH_DTTT_MA_DT
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    NGUON,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    MA_DT,
    SO_ID_TT,
    SO_ID,
    NGAY,
    NGAY_HT,
    NGAY_HTNV,
    NGAY_HTBS,
    PHI,
    THUE,
    HHONG,
    HHONG_NT,
    HTRO,
    HTRO_NT,
    PT,
    DBH,
    MA_DVIG
)
BEQUEATH DEFINER
AS
SELECT goc.ma_dvi,
          so_hd,
          nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          ma_nt,
          lh_nv,
          ma_dt,
          nv.so_id_tt,
          goc.so_id,
          ngay,
          goc.ngay_ht,
          nv.ngay_tt,
          nv.ngay_ht,
          phi_qd,
          thue_qd,
          FTT_VND_QD (goc.ma_dvi,
                      nv.ngay_ht,
                      nv.ma_nt,
                      nv.hhong),
          nv.hhong,
          FTT_VND_QD (goc.ma_dvi,
                      nv.ngay_ht,
                      nv.ma_nt,
                      nv.htro),
          nv.htro,
          pt,
          0,
          goc.ma_dvi
     FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
    WHERE 
          nv.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.pt <> 'C'
          and goc.ma_dvi = nv.ma_dvi
          AND goc.so_id = nv.so_id
          AND goc.kieu_hd NOT IN ('V', 'N')
   --so tren bao gom ca so huy chua thu tien
   UNION ALL
   --loai tru cac mon huy chua thu tien
   SELECT goc.ma_dvi,
          so_hd,
          nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_hl,
          nv.ma_nt,
          lh_nv,
          ma_dt,
          nv.so_id_tt,
          goc.so_id,
          ngay,
          goc.ngay_ht,
          nv.ngay_tt,
          nv.ngay_ht,
          -phi_qd,
          -thue_qd,
          -FTT_VND_QD (goc.ma_dvi,
                       nv.ngay_ht,
                       nv.ma_nt,
                       nv.hhong),
          -nv.hhong,
          -FTT_VND_QD (goc.ma_dvi,
                       nv.ngay_ht,
                       nv.ma_nt,
                       nv.htro),
          -nv.htro,
          pt,
          0,
          goc.ma_dvi
     FROM bh_hd_goc goc,
          bh_hd_goc_ttpt nv,
          bh_hd_goc_hups c,
          temp_bc_ts ts
    WHERE 
          nv.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.pt <> 'C'
          AND nv.phi < 0
          AND nv.so_id = nv.so_id_tt
          and goc.ma_dvi = nv.ma_dvi
          AND goc.so_id = nv.so_id
          AND goc.ma_dvi = c.ma_dvi
          AND goc.so_id = c.so_id
          AND nv.ma_nt = c.ma_nt
          AND c.no <> 0
          AND c.tra = 0
          AND goc.kieu_hd NOT IN ('V', 'N')
   UNION ALL
   --giam dong bao hiem di

   /*
   select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
       ngay_hl,ngay_kt,
       ma_nt,nv.lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_tt,nv.ngay_ht,
       -phi_qd*c.pt/100,-thue_qd*c.pt/100,0,0,0,0,'',0,goc.ma_dvi
       from bh_hd_goc goc,bh_hd_goc_ttpt nv,(select * from bh_hd_do_tl where kieu='D' and pthuc='C' and ph='K') c,temp_bc_ts ts
       where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=c.ma_dvi and nv.ma_dvi like ts.ma_dvi
       and goc.so_id=nv.so_id  and nv.so_id=c.so_id and c.lh_nv=nv.lh_nv and nv.pt<>'C' and nv.ngay_ht between ts.ngayd and ts.ngayc
   union all
   */
   SELECT goc.ma_dvi,
          so_hd,
          goc.nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          goc.phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          nv.ma_nt,
          nv.lh_nv,
          '',
          nv.so_id_tt,
          goc.so_id,
          nv.ngay_ht,
          c.ngay,
          nv.ngay_ht,
          nv.ngay_ht,
          -nv.tien_qd,
          -nv.thue_qd,
          0,
          0,
          0,
          0,
          '',
          0,
          goc.ma_dvi
     FROM bh_hd_goc goc,
          bh_hd_do_pt nv,
          bh_hd_goc_ttpt c,
          temp_bc_ts ts
    WHERE     
          nv.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.loai IN ('CH_LE_PH', 'DT_LE_TL', 'DT_LE_HU')
          and goc.ma_dvi LIKE ts.ma_dvi
          AND nv.so_id_ps = c.so_id_tt
          AND nv.so_id = c.so_id
          AND nv.lh_nv = c.lh_nv
          AND goc.ma_dvi = nv.ma_dvi
          AND goc.so_id = nv.so_id
   UNION ALL
   /* dang dung
   select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
       ngay_hl,ngay_kt,
       nv.ma_nt,nv.lh_nv,'',nv.so_id_tt,goc.so_id,nv.ngay_ht,goc.ngay_ht,nv.ngay_ht,nv.ngay_ht,
       -nv.tien_qd, -nv.thue_qd,0,0,0,0,'',0,goc.ma_dvi from bh_hd_goc goc,bh_hd_do_pt nv,bh_hd_goc_ttpt pt,temp_bc_ts ts
       where goc.ma_dvi like ts.ma_dvi and nv.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
       and goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=pt.ma_dvi and goc.so_id=nv.so_id and goc.so_id=pt.so_id and pt.so_id_tt=nv.so_id_tt
       and nv.loai in ('CH_LE_PH','DT_LE_TL','DT_LE_HU')
   union all
   */
   /*
   select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
       ngay_hl,ngay_kt,
       ma_nt,lh_nv,'',so_id_tt,goc.so_id,nv.ngay_ht,goc.ngay_ht,nv.ngay_ht,nv.ngay_ht,
       -tien_qd, -thue_qd,0,0,0,0,'',0,goc.ma_dvi from bh_hd_goc goc,bh_hd_do_pt nv,bh_hd_goc_ttpt pt,temp_bc_ts ts
       where goc.ma_dvi like ts.ma_dvi and nv.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
       and goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=pt.ma_dvi and goc.so_id=nv.so_id and goc.so_id=pt.so_id and pt.so_id_tt=nv.so_id_tt
       and nv.loai in ('CH_LE_PH','DT_LE_TL','DT_LE_HU')
   union all
   */
   /*
   select distinct goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
       ngay_hl,ngay_kt,nv.ma_nt,nv.lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_tt,nv.ngay_ht,
       -pb.phi_qd,-thue_qd,0,0,0,0,'',0,goc.ma_dvi
       from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_goc_ttpb pb,(select * from bh_hd_do_tl where kieu='D' and pthuc='C' and ph='K') c,temp_bc_ts ts
       where goc.ma_dvi like ts.ma_dvi and  nv.ma_dvi like ts.ma_dvi and  pb.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
       and goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=c.ma_dvi and goc.ma_dvi=pb.ma_dvi and pb.pthuc='G' and pb.pt<>'C'
       and goc.so_id=nv.so_id  and nv.so_id=c.so_id and goc.so_id=pb.so_id and nv.lh_nv=c.lh_nv and pb.lh_nv=c.lh_nv and nv.pt<>'C' union all
   */
   --Dong bao hiem don vi
   --tang cho don vi dong folow c19=DT

   SELECT nv.ma_dvi,
          so_hd,
          goc.nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          nv.phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          nv.ma_nt,
          nv.lh_nv,
          '',
          nv.so_id_tt,
          goc.so_id,
          goc.ngay_ht,
          goc.ngay_ht,
          nv.ngay_ht,
          nv.ngay_ht,
          nv.phi_qd,
          0,
          0,
          0,
          0,
          0,
          'G',
          1,
          goc.ma_dvi
     FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
    WHERE     nv.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.pthuc IN ('D', 'P')
          AND nv.pt <> 'C'
          AND goc.ma_dvi = nv.dvi_xl
          AND goc.so_id = nv.so_id            --and nv.so_id <> 20130105040243
   UNION ALL
   --loai tru khoan huy chua ghi nhan thuc thu
   SELECT nv.ma_dvi,
          so_hd,
          goc.nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          nv.phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          nv.ma_nt,
          nv.lh_nv,
          '',
          nv.so_id_tt,
          goc.so_id,
          goc.ngay_ht,
          goc.ngay_ht,
          nv.ngay_ht,
          nv.ngay_ht,
          -nv.phi_qd,
          0,
          0,
          0,
          0,
          0,
          'G',
          1,
          goc.ma_dvi
     FROM bh_hd_goc goc,
          bh_hd_goc_ttpb nv,
          bh_hd_goc_hups c,
          temp_bc_ts ts
    WHERE     nv.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.pthuc IN ('D', 'P')
          AND nv.pt <> 'C'
          AND goc.ma_dvi = nv.dvi_xl
          AND goc.so_id = nv.so_id
          AND goc.so_id = c.so_id
          AND goc.ma_dvi = c.ma_dvi
          AND c.tra = 0
   UNION ALL
   --giam cho don vi dong leader c19='DG'
   SELECT goc.ma_dvi,
          so_hd,
          goc.nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          goc.phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          nv.ma_nt,
          nv.lh_nv,
          '',
          nv.so_id_tt,
          goc.so_id,
          nv.ngay_ht,
          goc.ngay_ht,
          nv.ngay_ht,
          nv.ngay_ht,
          -nv.phi_qd,
          0,
          0,
          0,
          0,
          0,
          'G',
          0,
          goc.ma_dvi
     FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
    WHERE     goc.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.pthuc IN ('D', 'P')
          AND nv.pt <> 'C'
          AND goc.ma_dvi = nv.dvi_xl
          AND goc.so_id = nv.so_id
   UNION ALL
   SELECT goc.ma_dvi,
          so_hd,
          goc.nv,
          kieu_hd,
          ma_kh,
          ma_gt,
          cb_ql,
          goc.phong,
          kieu_kt,
          ma_kt,
          ngay_hl,
          ngay_kt,
          nv.ma_nt,
          nv.lh_nv,
          '',
          nv.so_id_tt,
          goc.so_id,
          nv.ngay_ht,
          goc.ngay_ht,
          nv.ngay_ht,
          nv.ngay_ht,
          nv.phi_qd,
          0,
          0,
          0,
          0,
          0,
          'G',
          0,
          goc.ma_dvi
     FROM bh_hd_goc goc,
          bh_hd_goc_ttpb nv,
          bh_hd_goc_hups c,
          temp_bc_ts ts
    WHERE     goc.ma_dvi LIKE ts.ma_dvi
          AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
          AND nv.pthuc IN ('D', 'P')
          AND nv.pt <> 'C'
          AND goc.ma_dvi = nv.dvi_xl
          AND goc.so_id = nv.so_id
          AND goc.so_id = c.so_id
          AND goc.ma_dvi = c.ma_dvi
          AND c.tra = 0
--and nv.so_id <> 20130105040243 --and nv.ma_dvi<>nv.dvi_xl
;

DROP VIEW V_BC_BH_DTTT_MM;


CREATE OR REPLACE FORCE VIEW V_BC_BH_DTTT_MM
(
    MA_DVI,
    SO_HD,
    NV,
    KIEU_HD,
    MA_KH,
    NGUON,
    CB_QL,
    PHONG,
    KIEU_KT,
    MA_KT,
    NGAY_HL,
    NGAY_KT,
    MA_NT,
    LH_NV,
    SO_ID_TT,
    SO_ID,
    NGAY_HT,
    NGAY_HTNV,
    PHI,
    THUE,
    HHONG,
    HHONG_NT,
    HTRO,
    HTRO_NT,
    PT,
    DBH,
    MA_DVIG
)
BEQUEATH DEFINER
AS
    SELECT goc.ma_dvi,
           so_hd,
           nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           lh_nv,
           nv.so_id_tt,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_tt,
           phi_qd,
           thue_qd,
           FTT_VND_QD (goc.ma_dvi,
                       nv.ngay_ht,
                       nv.ma_nt,
                       nv.hhong),
           nv.hhong,
           FTT_VND_QD (goc.ma_dvi,
                       nv.ngay_ht,
                       nv.ma_nt,
                       nv.htro),
           nv.htro,
           pt,
           0,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpt nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'C'
           --AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.kieu_hd <> 'V'
    --so tren bao gom ca so huy chua thu tien

    UNION ALL
    --loai tru cac mon huy chua thu tien
    SELECT goc.ma_dvi,
           so_hd,
           nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_hl,
           nv.ma_nt,
           lh_nv,
           nv.so_id_tt,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_tt,
           -phi_qd,
           -thue_qd,
           -FTT_VND_QD (goc.ma_dvi,
                        nv.ngay_ht,
                        nv.ma_nt,
                        nv.hhong),
           -nv.hhong,
           -FTT_VND_QD (goc.ma_dvi,
                        nv.ngay_ht,
                        nv.ma_nt,
                        nv.htro),
           -nv.htro,
           pt,
           0,
           goc.ma_dvi
      FROM bh_hd_goc       goc,
           bh_hd_goc_ttpt  nv,
           bh_hd_goc_hups  c,
           temp_bc_ts      ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'C'
           AND nv.phi < 0
           AND nv.so_id = nv.so_id_tt
           --AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.so_id = nv.so_id
           AND goc.ma_dvi = c.ma_dvi
           AND goc.so_id = c.so_id
           AND nv.ma_nt = c.ma_nt
           AND c.no <> 0
           AND c.tra = 0
           AND goc.kieu_hd NOT IN ('V', 'N')
    UNION ALL
    --giam dong bao hiem di
    /*
    select distinct goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
        ngay_hl,ngay_kt,
        nv.ma_nt,nv.lh_nv,nv.so_id_tt,goc.so_id,goc.ngay_ht,nv.ngay_tt,
        -pb.phi_qd,-thue_qd,0,0,0,0,'',0,goc.ma_dvi
        from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_goc_ttpb pb,(select * from bh_hd_do_tl where kieu='D' and pthuc='C' and ph='K') c,temp_bc_ts ts
        where goc.ma_dvi like ts.ma_dvi and  nv.ma_dvi like ts.ma_dvi and  pb.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
        and goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=c.ma_dvi and goc.ma_dvi=pb.ma_dvi and pb.pthuc='G' and pb.pt='C'
        and goc.so_id=nv.so_id  and nv.so_id=c.so_id and goc.so_id=pb.so_id and nv.lh_nv=c.lh_nv and pb.lh_nv=c.lh_nv and nv.pt<>'C' union all

    */

    SELECT goc.ma_dvi,
           so_hd,
           nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           goc.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           ma_nt,
           nv.lh_nv,
           nv.so_id_tt,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_tt,
           -phi_qd * c.pt / 100,
           -thue_qd * c.pt / 100,
           0,
           0,
           0,
           0,
           '',
           0,
           goc.ma_dvi
      FROM bh_hd_goc       goc,
           bh_hd_goc_ttpt  nv,
           (SELECT *
              FROM bh_hd_do_tl
             WHERE kieu = 'D' AND pthuc = 'C' AND ph = 'K') c,
           temp_bc_ts      ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pt <> 'C'
           --AND goc.ma_dvi LIKE ts.ma_dvi
           AND goc.ma_dvi = nv.ma_dvi
           AND goc.ma_dvi = c.ma_dvi
           AND goc.so_id = c.so_id
           AND goc.so_id = nv.so_id
           AND nv.so_id = c.so_id
           AND (nv.lh_nv = c.lh_nv OR c.lh_nv = '*')
    UNION ALL
    /*

    select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
        ngay_hl,ngay_kt,
        ma_nt,lh_nv,so_id_tt,goc.so_id,nv.ngay_ht,goc.ngay_ht,nv.ngay_ht,nv.ngay_ht,
        -tien_qd, -thue_qd,0,0,0,0,'',0,goc.ma_dvi from bh_hd_goc goc,bh_hd_do_pt nv,temp_bc_ts ts
        where goc.ma_dvi like ts.ma_dvi and nv.ma_dvi like ts.ma_dvi and nv.ngay_ht between ts.ngayd and ts.ngayc
        and goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id and nv.loai in ('CH_LE_PH','DT_LE_TL','DT_LE_HU')

    union all

    */
    --Dong bao hiem don vi
    --tang cho don vi dong folow c19=DT

    SELECT nv.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           nv.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           nv.ma_nt,
           nv.lh_nv,
           nv.so_id_tt,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_ht,
           nv.phi_qd,
           0,
           0,
           0,
           0,
           0,
           'G',
           1,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pthuc IN ('D', 'P')
           AND nv.pt <> 'C'
           AND goc.ma_dvi = nv.dvi_xl
           AND goc.so_id = nv.so_id           --and nv.so_id <> 20130105040243
    UNION ALL
    --loai tru nhung khoan huy khong co thuc thu
    SELECT nv.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           nv.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           nv.ma_nt,
           nv.lh_nv,
           nv.so_id_tt,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_ht,
           -nv.phi_qd,
           0,
           0,
           0,
           0,
           0,
           'G',
           1,
           goc.ma_dvi
      FROM bh_hd_goc       goc,
           bh_hd_goc_ttpb  nv,
           bh_hd_goc_hups  c,
           temp_bc_ts      ts
     WHERE     nv.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pthuc IN ('D', 'P')
           AND nv.pt <> 'C'
           AND goc.ma_dvi = nv.dvi_xl
           AND goc.so_id = nv.so_id
           AND goc.so_id = c.so_id
           AND goc.ma_dvi = c.ma_dvi
           AND c.tra <> 0
    UNION ALL
    SELECT goc.ma_dvi,
           so_hd,
           goc.nv,
           kieu_hd,
           ma_kh,
           ma_gt,
           cb_ql,
           goc.phong,
           kieu_kt,
           ma_kt,
           ngay_hl,
           ngay_kt,
           nv.ma_nt,
           nv.lh_nv,
           nv.so_id_tt,
           goc.so_id,
           goc.ngay_ht,
           nv.ngay_ht,
           -nv.phi_qd,
           0,
           0,
           0,
           0,
           0,
           'G',
           0,
           goc.ma_dvi
      FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
     WHERE     goc.ma_dvi LIKE ts.ma_dvi
           AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
           AND nv.pthuc IN ('D', 'P')
           AND nv.pt <> 'C'
           AND goc.ma_dvi = nv.dvi_xl
           AND nv.ma_dvi <> nv.dvi_xl
           AND goc.so_id = nv.so_id
           AND nv.so_id <> 20130105040243;

DROP VIEW V_BH_HD_GOC_TTPT_1;


CREATE OR REPLACE FORCE VIEW V_BH_HD_GOC_TTPT_1
(
    MA_DVI,
    SO_ID_TT,
    SO_ID,
    NGAY_TT,
    PT,
    LH_NV,
    PHI,
    THUE,
    TTOAN,
    PHI_DT,
    HHONG,
    HTRO,
    PHI_QD,
    THUE_QD,
    TTOAN_QD,
    PHI_DT_QD,
    LOAI,
    MA_DVIG
)
BEQUEATH DEFINER
AS
SELECT nv.ma_dvi,
             nv.so_id_tt,
             nv.so_id,
             nv.ngay_tt,
             nv.pt,
             nv.lh_nv,
             SUM (nv.phi),
             SUM (nv.thue),
             SUM (nv.ttoan),
             SUM (nv.phi),
             SUM (nv.hhong),
             SUM (nv.htro),
             SUM (nv.phi_qd),
             SUM (nv.thue_qd),
             SUM (nv.ttoan_qd),
             SUM (nv.phi_qd),
             'HD',
             nv.ma_dvi
        FROM bh_hd_goc_ttpt nv, temp_bc_ts ts
       WHERE     nv.ma_dvi LIKE ts.ma_dvi
             AND nv.so_id_tt IN
                     (SELECT so_id_tt
                        FROM bh_hd_goc_tthd
                       WHERE ma_dvi = nv.ma_dvi AND so_id = nv.so_id)
             AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
             AND nv.bt < 10000
             AND nv.pt <> 'N'
             AND nv.so_id_tt <> nv.so_id
    GROUP BY nv.ma_dvi,
             nv.so_id_tt,
             nv.so_id,
             nv.ngay_tt,
             nv.pt,
             nv.lh_nv,
             nv.ma_dvi
    UNION ALL
      SELECT nv.ma_dvi,
             nv.so_id_tt,
             nv.so_id,
             nv.ngay_ht,
             nv.pt,
             nv.lh_nv,
             SUM (nv.phi_qd),
             0,
             0,
             SUM (nv.phi),
             SUM (nv.hhong),
             SUM (nv.htro),
             0,
             0,
             0,
             SUM (nv.phi_qd),
             'HUL',
             nv.dvi_xl
        FROM bh_hd_goc goc, bh_hd_goc_ttpb nv, temp_bc_ts ts
       WHERE     goc.ma_dvi = nv.dvi_xl
             AND goc.so_id = nv.so_id
             AND nv.ma_dvi LIKE ts.ma_dvi
             AND nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
             AND nv.pt = 'H'
             AND nv.so_id_tt = nv.so_id                      --and nv.bt>10000
    GROUP BY nv.ma_dvi,
             nv.so_id_tt,
             nv.so_id,
             nv.ngay_ht,
             nv.pt,
             nv.lh_nv,
             nv.dvi_xl;

DROP VIEW V_BH_HD_GOC_TTPT_CN;


CREATE OR REPLACE FORCE VIEW V_BH_HD_GOC_TTPT_CN
(
    MA_DVI,
    SO_ID_TT,
    SO_ID,
    NGAY_TT,
    PT,
    LH_NV,
    PHI,
    THUE,
    TTOAN,
    PHI_DT,
    HHONG,
    HTRO,
    PHI_QD,
    THUE_QD,
    TTOAN_QD,
    PHI_DT_QD
)
BEQUEATH DEFINER
AS
      SELECT /*+ ORDERED */
             nv.ma_dvi,
             nv.so_id_tt,
             nv.so_id,
             nv.ngay_tt,
             nv.pt,
             nv.lh_nv,
             SUM (nv.phi),
             SUM (nv.thue),
             SUM (nv.ttoan),
             SUM (nv.phi),
             SUM (nv.hhong),
             SUM (nv.htro),
             SUM (nv.phi_qd),
             SUM (nv.thue_qd),
             SUM (nv.ttoan_qd),
             SUM (nv.phi_qd)
        FROM bh_hd_goc_ttpt nv, temp_bc_ts ts
       WHERE     nv.ngay_ht BETWEEN ts.ngayd AND ts.ngayc
             AND nv.pt <> 'N'
             AND nv.ma_dvi LIKE ts.ma_dvi
    GROUP BY nv.ma_dvi,
             nv.so_id_tt,
             nv.so_id,
             nv.ngay_tt,
             nv.pt,
             nv.lh_nv;

DROP VIEW V_HH_CDUYET_MD;


CREATE OR REPLACE FORCE VIEW V_HH_CDUYET_MD
(
    MA_DVI,
    LH_NV,
    MA_KT,
    PHONG,
    SO_HD,
    MA_KH,
    CB_QL,
    SO_ID,
    SO_ID_TT,
    MA_NT,
    HHONG,
    HHONG_QD,
    HTRO,
    HTRO_QD,
    NGAY_HT
)
BEQUEATH DEFINER
AS
select a.ma_dvi,lh_nv,ma_kt,phong,so_hd,ma_kh,cb_ql,a.so_id,
	b.so_id_tt,ma_nt,b.hhong,FTT_VND_QD(a.ma_dvi,b.ngay_tt,ma_nt,b.hhong),b.htro,FTT_VND_QD(a.ma_dvi,b.ngay_tt,ma_nt,b.htro),b.ngay_tt
	from bh_hd_goc a,bh_hd_goc_ttpt b where a.ma_dvi=b.ma_dvi
	and a.so_id=b.so_id and pt<>'C' union all

select g.ma_dvi,p.lh_nv,ma_kt,g.phong,so_hd,ma_kh,cb_ql,g.so_id,
	p.so_id_tt,p.ma_nt,-p.hhong,-p.hhong_qd,-p.htro,-p.htro_qd,tt.ngay_tt
	from bh_hd_goc g,bh_hd_goc_hh_pt p,bh_hd_goc_hh h ,(select distinct ma_dvi,so_id,so_id_tt,ma_nt,lh_nv,ngay_tt from bh_hd_goc_ttpt) tt
	where g.ma_dvi=p.ma_dvi and h.ma_dvi=p.ma_dvi  and tt.ma_dvi=p.ma_dvi 
	and g.so_id=p.so_id and p.so_id_hh=h.so_id_hh and p.so_id=tt.so_id and p.so_id_tt=tt.so_id_tt and p.ma_nt=tt.ma_nt and p.lh_nv=tt.lh_nv;

DROP VIEW V_HH_DDUYET;


CREATE OR REPLACE FORCE VIEW V_HH_DDUYET
(
    MA_DVI,
    SO_CT,
    LH_NV,
    MA_KT,
    PHONG,
    SO_HD,
    MA_KH,
    CB_QL,
    SO_ID,
    SO_ID_HH,
    SO_ID_TT,
    SO_ID_KT,
    MA_NT,
    HHONG,
    HHONG_QD,
    THUE_HH,
    THUE_HH_QD,
    HTRO,
    HTRO_QD,
    THUE_HT,
    THUE_HT_QD,
    NGAY_HT
)
BEQUEATH DEFINER
AS
(--select g.ma_dvi,h.so_ct,lh_nv,h.ma_kt,g.phong,so_hd,ma_kh,cb_ql,g.so_id,h.so_id_hh,p.so_id_tt,h.so_id_kt,ma_nt,p.hhong,p.hhong_qd,
select p.ma_dvi,
h.so_id_hh,--h.so_ct,
lh_nv,h.ma_dl,h.phong,so_hd,ma_kh,cb_ql,g.so_id,h.so_id_hh,p.so_id_tt,h.so_id_kt,ma_nt,p.hhong,p.hhong_qd,
	decode(kieu_kt,'D',thue_hh,0),decode(kieu_kt,'D',thue_hh_qd,0),
	p.htro,p.htro_qd,decode(kieu_kt,'D',thue_ht,0),decode(kieu_kt,'D',thue_ht_qd,0),h.ngay_ht
	from bh_hd_goc g,bh_hd_goc_hh_pt p,bh_hd_goc_hh h
	where --g.ma_dvi=ct.dvi_xl
    h.ma_dvi=p.ma_dvi 
	and g.so_id=p.so_id and p.so_id_hh=h.so_id_hh --union all
--Hoa hong dong don vi
/*
select p.ma_dvi,h.so_ct,p.lh_nv,ma_dl,g.phong,so_hd,ma_kh,cb_ql,g.so_id,h.so_id_hh,p.so_id_tt,h.so_id_kt,ma_nt,p.hhong,p.hhong_qd,
	decode(kieu_kt,'D',thue_hh,0),decode(kieu_kt,'D',thue_hh_qd,0),
	p.htro,p.htro_qd,decode(kieu_kt,'D',thue_ht,0),decode(kieu_kt,'D',thue_ht_qd,0),h.ngay_ht
	from bh_hd_goc g,(select distinct nha_bh,ma_dvi,so_id from bh_hd_do_tl where pthuc='D') t,bh_hd_goc_hh_pt p,bh_hd_goc_hh h
	where t.nha_bh=p.ma_dvi and t.so_id=g.so_id and t.so_id=p.so_id and g.ma_dvi=t.ma_dvi 
	and h.ma_dvi=p.ma_dvi and g.so_id=p.so_id and p.so_id_hh=h.so_id_hh -- union all

--hoa hong =-dl khi nv='C'--
select g.ma_dvi,t.so_ct,'',g.ma_kt,g.phong,g.so_hd,ma_kh,cb_ql,g.so_id,t.so_id_tt,t.so_id_tt,t.so_id_kt,c.ma_nt,
	c.tien-c.thue,decode(c.loai,'DT_LE_DL',c.tien_qd-c.thue_qd,-c.tien_qd+c.thue_qd),0,0,0,0,0,0,t.ngay_ht
	from bh_hd_goc g,bh_hd_do_ct c,bh_hd_do_tt t
	where g.ma_dvi=c.ma_dvi and  c.ma_dvi=t.ma_dvi
	and g.so_id=c.so_id and c.so_id_tt=t.so_id_tt
*/
);

DROP VIEW V_HH_DDUYET_TS;


CREATE OR REPLACE FORCE VIEW V_HH_DDUYET_TS
(
    MA_DVI,
    SO_CT,
    LH_NV,
    MA_KT,
    PHONG,
    SO_HD,
    MA_KH,
    CB_QL,
    SO_ID,
    SO_ID_HH,
    SO_ID_TT,
    SO_ID_KT,
    MA_NT,
    HHONG,
    HHONG_QD,
    THUE_HH,
    THUE_HH_QD,
    HTRO,
    HTRO_QD,
    THUE_HT,
    THUE_HT_QD,
    NGAY_HT
)
BEQUEATH DEFINER
AS
( --select g.ma_dvi,h.so_ct,lh_nv,h.ma_kt,g.phong,so_hd,ma_kh,cb_ql,g.so_id,h.so_id_hh,p.so_id_tt,h.so_id_kt,ma_nt,p.hhong,p.hhong_qd,
    SELECT  p.ma_dvi,
            h.so_id_hh so_ct,--h.so_ct,
            lh_nv,
            h.ma_dl,
            h.phong,
            so_hd,
            ma_kh,
            cb_ql,
            g.so_id,
            h.so_id_hh,
            p.so_id_tt,
            h.so_id_kt,
            ma_nt,
            p.hhong,
            p.hhong_qd,
            DECODE (kieu_kt, 'D', thue_hh, 0),
            DECODE (kieu_kt, 'D', thue_hh_qd, 0),
            p.htro,
            p.htro_qd,
            DECODE (kieu_kt, 'D', thue_ht, 0),
            DECODE (kieu_kt, 'D', thue_ht_qd, 0),
            h.ngay_ht
       FROM bh_hd_goc g, bh_hd_goc_hh_pt p, bh_hd_goc_hh h, temp_bc_ts ts 
      WHERE h.ma_dvi LIKE ts.ma_dvi and h.ngay_ht BETWEEN ts.ngayd AND ts.ngayc                                             --g.ma_dvi=ct.dvi_xl
            and h.ma_dvi = p.ma_dvi AND p.so_id_hh = h.so_id_hh
            AND g.so_id = p.so_id
            
                                        --union all
                                       --Hoa hong dong don vi
                                       /*
                                       select p.ma_dvi,h.so_ct,p.lh_nv,ma_dl,g.phong,so_hd,ma_kh,cb_ql,g.so_id,h.so_id_hh,p.so_id_tt,h.so_id_kt,ma_nt,p.hhong,p.hhong_qd,
                                        decode(kieu_kt,'D',thue_hh,0),decode(kieu_kt,'D',thue_hh_qd,0),
                                        p.htro,p.htro_qd,decode(kieu_kt,'D',thue_ht,0),decode(kieu_kt,'D',thue_ht_qd,0),h.ngay_ht
                                        from bh_hd_goc g,(select distinct nha_bh,ma_dvi,so_id from bh_hd_do_tl where pthuc='D') t,bh_hd_goc_hh_pt p,bh_hd_goc_hh h
                                        where t.nha_bh=p.ma_dvi and t.so_id=g.so_id and t.so_id=p.so_id and g.ma_dvi=t.ma_dvi
                                        and h.ma_dvi=p.ma_dvi and g.so_id=p.so_id and p.so_id_hh=h.so_id_hh -- union all

                                       --hoa hong =-dl khi nv='C'--
                                       select g.ma_dvi,t.so_ct,'',g.ma_kt,g.phong,g.so_hd,ma_kh,cb_ql,g.so_id,t.so_id_tt,t.so_id_tt,t.so_id_kt,c.ma_nt,
                                        c.tien-c.thue,decode(c.loai,'DT_LE_DL',c.tien_qd-c.thue_qd,-c.tien_qd+c.thue_qd),0,0,0,0,0,0,t.ngay_ht
                                        from bh_hd_goc g,bh_hd_do_ct c,bh_hd_do_tt t
                                        where g.ma_dvi=c.ma_dvi and  c.ma_dvi=t.ma_dvi
                                        and g.so_id=c.so_id and c.so_id_tt=t.so_id_tt
                                       */
   );

DROP VIEW V_TA_CD;

CREATE OR REPLACE VIEW V_TA_CD
(SO_ID_HD,so_id_dt, SO_HD_TA, SO_HD, NGAY_XU_LY, SO_CT, 
 NGAY_HL, NGAY_KT, NT_TIEN, NT_PHI, PTHUC, 
 NGAY_HIEULUC, MA_TA, PT, TIEN, PHI)
BEQUEATH DEFINER
AS 
SELECT G.so_id so_id_hd,c.so_id_dt,G.SO_HD SO_HD_TA,D.SO_HD, BCNAM_SO_NGAY_F(A.NGAY_HT) NGAY_XU_LY, A.SO_CT, BCNAM_SO_NGAY_F(A.NGAY_HL)NGAY_HL, BCNAM_SO_NGAY_F(A.NGAY_KT)NGAY_KT, A.NT_TIEN, A.NT_PHI, B.PTHUC,
BCNAM_SO_NGAY_F(B.NGAY_HL) NGAY_HIEULUC, B.MA_TA,SUM(B.PT)PT,SUM(B.TIEN)TIEN,SUM(B.PHI)PHI --,           B.TL_THUE,           B.THUE,           B.PT_HH,           B.HHONG
FROM TBH_GHEP      A,
TBH_GHEP_PHI  B,
(SELECT DISTINCT SO_ID,SO_ID_HD,so_id_dt FROM TBH_GHEP_HD)   C,
BH_HD_GOC   D,
(SELECT * FROM TBH_HD_DI WHERE MA_DVI in (select min(dvi_ta) from TBH_DVI_TA)) G
WHERE     A.SO_ID = B.SO_ID
AND A.SO_ID = C.SO_ID
AND C.SO_ID_HD = D.SO_ID
AND B.SO_ID=B.SO_ID AND B.SO_ID_TA=G.SO_ID
AND G.PTHUC = B.PTHUC AND B.PTHUC = B.PTHUC AND B.MA_TA = B.MA_TA
AND B.PT > 0
AND D.TTRANG = 'D'
--AND D.NV = 'PHH' --AND D.NGAY_HL BETWEEN B_NGAYD AND B_NGAYC
GROUP BY 
B.SO_ID,G.SO_HD,D.SO_HD,G.so_id,c.so_id_dt, BCNAM_SO_NGAY_F(A.NGAY_HT), A.SO_CT, BCNAM_SO_NGAY_F(A.NGAY_HL), BCNAM_SO_NGAY_F(A.NGAY_KT), A.NT_TIEN, A.NT_PHI, B.PTHUC,BCNAM_SO_NGAY_F(B.NGAY_HL), B.MA_TA;
