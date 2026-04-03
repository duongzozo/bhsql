create or replace view V_BC_BH_DTTT_HUY(MA_DVI, SO_HD, NV, KIEU_HD, MA_KH, NGUON, CB_QL, PHONG, KIEU_KT, MA_KT, NGAY_HL, 
NGAY_KT, MA_NT, LH_NV, MA_DT, SO_ID_TT, SO_ID, NGAY, NGAY_HT, NGAY_HTNV, 
NGAY_HTBS, PHI, THUE, HHONG, HHONG_NT, HTRO, HTRO_NT, PT, DBH, MA_DVIG)
AS
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_kt,ma_nt,lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_tt,nv.ngay_ht,
    phi_qd,thue_qd,FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong),
    nv.hhong,FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro),nv.htro,pt,0,goc.ma_dvi
    from bh_hd_goc goc,bh_hd_goc_ttpt nv
    where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id  and kieu_hd <>'V' and (pt='G'or pt='H')
        and (nv.ma_dvi,nv.so_id) in (select ma_dvi,so_id  from bh_hd_goc_hu)
--so tren bao gom ca so huy chua thu tien
union all
--loai tru cac mon huy chua thu tien
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,phong,kieu_kt,ma_kt,
    ngay_hl,ngay_hl,nv.ma_nt,lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_tt,nv.ngay_ht,
    -phi_qd,-thue_qd,-FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.hhong),-nv.hhong,
    -FTT_VND_QD(goc.ma_dvi,nv.ngay_ht,nv.ma_nt,nv.htro),-nv.htro,pt,0,goc.ma_dvi
    from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_goc_hups c
    where goc.ma_dvi=nv.ma_dvi and goc.so_id=nv.so_id  and goc.ma_dvi=c.ma_dvi and  goc.so_id=c.so_id and nv.ma_nt=c.ma_nt
    and no<>0 and tra=0 and kieu_hd <>'V' and (pt='G'or pt='H') and nv.phi<0 and nv.so_id=so_id_tt union all
--giam dong bao hiem di
select goc.ma_dvi,so_hd,nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
    goc.ngay_hl,ngay_kt,ma_nt,nv.lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_tt,nv.ngay_ht,
    -phi_qd*c.pt/100,-thue_qd*c.pt/100,0,0,0,0,'',0,goc.ma_dvi
    from bh_hd_goc goc,bh_hd_goc_ttpt nv,(select t1.* from bh_hd_do t,bh_hd_do_tl t1 where t.ma_dvi=t1.ma_dvi and 
                                                       t.so_id=t1.so_id and t.kieu='D' and t1.pthuc='C') c
    where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=c.ma_dvi 
    and goc.so_id=nv.so_id  and nv.so_id=c.so_id and nv.lh_nv=c.lh_nv and (nv.pt='G'or nv.pt='H') 
    and (nv.ma_dvi,nv.so_id) in (select ma_dvi,so_id  from bh_hd_goc_hu) union all
--Dong bao hiem don vi
--tang cho don vi dong folow 
select decode(b.pthuc,'D',b.nha_bh,goc.ma_dvi),so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
    goc.ngay_hl,ngay_kt,
    ma_nt,nv.lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_ht,nv.ngay_ht,
    phi_qd*b.pt/100, 0,0,0,0,0,'G',1,goc.ma_dvi
    from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_do a,bh_hd_do_tl b
    where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=b.ma_dvi
    and goc.so_id=nv.so_id and nv.so_id=b.so_id and nv.lh_nv=b.lh_nv
    and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
    and kieu_hd <>'V' and (nv.pt='G'or nv.pt='H') and a.kieu='D'  and b.pthuc in ('D','P') 
    and (nv.ma_dvi,nv.so_id) in (select ma_dvi,so_id  from bh_hd_goc_hu) union all
--Giam cho don vi dong leader (don vi goc)
select goc.ma_dvi,so_hd,goc.nv,kieu_hd,ma_kh,ma_gt,cb_ql,goc.phong,kieu_kt,ma_kt,
    goc.ngay_hl,ngay_kt,
    ma_nt,nv.lh_nv,ma_dt,nv.so_id_tt,goc.so_id,ngay,goc.ngay_ht,nv.ngay_ht,nv.ngay_ht,
    -phi_qd*b.pt/100, 0,0,0,0,0,'G',0,goc.ma_dvi
    from bh_hd_goc goc,bh_hd_goc_ttpt nv,bh_hd_do a,bh_hd_do_tl b
    where goc.ma_dvi=nv.ma_dvi and goc.ma_dvi=b.ma_dvi and nv.lh_nv=b.lh_nv
    and a.ma_dvi=b.ma_dvi and a.so_id=b.so_id
    and goc.so_id=nv.so_id and nv.so_id=b.so_id and kieu_hd <>'V' 
    and (nv.pt='G'or nv.pt='H') and a.kieu='D'  and  b.pthuc in ('D','P')
    and (nv.ma_dvi,nv.so_id) in (select ma_dvi,so_id  from bh_hd_goc_hu)
