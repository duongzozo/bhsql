create or replace PROCEDURE PBH_BT_DUPH_XOA(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Xoa du phong
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then
    delete bh_bt_hs_dp_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_DUPH_XOA:loi'; end if;
end;
/
create or replace PROCEDURE PBH_BT_DUPH_NH(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_loiQ varchar2(100); b_i1 number; b_tp number:=0; b_ngay_hl number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_dvi_ksoat varchar2(10):=' '; b_ksoat varchar2(20):=' '; b_hsc number;
    b_nt_tien varchar2(5); b_tg number; b_tong number; b_lh_nvX varchar2(10);
    b_do_tl number; b_dong number; b_dong_qd number; b_ta_tl number; b_tai number; b_tai_qd number;
    b_tien number; b_tien_qd number; b_con_tl number; b_con number; b_con_qd number;
    b_chi number; b_chi_qd number; b_chiT number:=0;
    b_ngay_dp number:=PKH_NG_CSO(sysdate); b_ma_ta varchar2(20);
    a_ma_ta pht_type.a_var; a_do_tl pht_type.a_num; a_ta_tl pht_type.a_num; a_ve_tl pht_type.a_num;

    a_ma_dvi_hd pht_type.a_var; a_so_id_hd pht_type.a_num; a_so_id_dt pht_type.a_num;
    r_hs bh_bt_hs%rowtype;
begin   
-- Dan - Tong hop du phong
select * into r_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hs_dp_temp; delete tbh_ghep_nv_temp2;
select count(*) into b_i1 from bh_bt_hs_dp where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp and
    r_hs.ma_dvi<>' ' and (dvi_ksoat<>r_hs.ma_dvi or ksoat<>r_hs.nsd);
if b_i1<>0 then b_loi:='loi:Du phong da kiem soat:loi'; return; end if;
delete bh_bt_hs_dp_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
delete bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
select nvl(sum(tien),0),max(lh_nv) into b_tong,b_lh_nvX from bh_bt_hs_nv where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_tong=0 then b_loi:='loi:Ho so chua uoc ton that:loi'; return; end if;
b_ma_dvi_hd:=r_hs.ma_dvi_ql; b_so_id_hd:=r_hs.so_id_hd; b_so_id_dt:=r_hs.so_id_dt;
a_ma_dvi_hd(1):=b_ma_dvi_hd; a_so_id_hd(1):=b_so_id_hd; a_so_id_dt(1):=b_so_id_dt; 
b_nt_tien:=r_hs.nt_tien;
if b_nt_tien<>'VND' then b_tp:=2; end if;
b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi_hd,b_so_id_hd,b_ngay_dp);
PBH_PQU_BT(r_hs.nv,r_hs.ma_dvi,r_hs.nsd,b_ma_dvi,b_so_id,b_loiQ);
if b_loiQ is null then b_dvi_ksoat:=r_hs.ma_dvi; b_ksoat:=r_hs.nsd; end if;
PTBH_GHEP_NV(0,b_ngay_dp,b_ngay_hl,'VND','VND',a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,b_loi,'{"nv":"'||r_hs.nv||'"}');
if b_loi is not null then return; end if;
select ma_ta,nvl(max(do_tl),0),nvl(max(ta_tl),0),nvl(max(ve_tl),0) bulk collect into a_ma_ta,a_do_tl,a_ta_tl,a_ve_tl
    from tbh_ghep_nv_temp group by ma_ta;
for b_lp in 1..a_ma_ta.count loop
    if a_do_tl(b_lp)<>0 then
        b_i1:=100-a_do_tl(b_lp)+a_ve_tl(b_lp);
    elsif a_ve_tl(b_lp)<>0 then
        b_i1:=a_ve_tl(b_lp);
    else
        b_i1:=100;
    end if;
    b_i1:=b_i1-a_ta_tl(b_lp);
    a_ta_tl(b_lp):=100-b_i1-a_do_tl(b_lp);
end loop;
for r_lp in(select ma_nt,sum(tien) tien from bh_bt_tu where ma_dvi=b_ma_dvi and so_id_hs=b_so_id group by ma_nt) loop
    if r_lp.ma_nt<>b_nt_tien then
        b_chiT:=b_chiT+FBH_TT_TUNG_QD(b_ngay_dp,r_lp.ma_nt,r_lp.tien,b_nt_tien); 
    else
        b_chiT:=b_chiT+r_lp.tien;
    end if;
end loop;
b_hsc:=b_chiT/b_tong;
for r_lp in (select lh_nv,sum(tien) tien from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi and so_id=b_so_id group by lh_nv order by lh_nv) loop
    b_ma_ta:=FBH_MA_LHNV_TAI(r_lp.lh_nv);
    if trim(b_ma_ta) is null then b_i1:=0; else b_i1:=FKH_ARR_VTRI(a_ma_ta,b_ma_ta); end if;
    if b_i1=0 then
        b_do_tl:=0; b_ta_tl:=0;
    else
        b_do_tl:=a_do_tl(b_i1); b_ta_tl:=a_ta_tl(b_i1);
    end if;
    b_tien:=r_lp.tien; b_chi:=round(b_tien*b_hsc,b_tp);
    if b_chi>b_chiT or r_lp.lh_nv=b_lh_nvX then b_chi:=b_chiT; end if;
    b_dong:=round(b_do_tl*b_tien/100,b_tp); b_tai:=round(b_ta_tl*b_tien/100,b_tp);
    if b_tp=0 then
        b_tien_qd:=b_tien; b_chi_qd:=b_chi; b_dong_qd:=b_dong; b_tai_qd:=b_tai;
    else
        b_tg:=FBH_TT_TRA_TGTT(b_ngay_dp,b_nt_tien);
        b_tien_qd:=round(b_tien*b_tg,0); b_chi_qd:=round(b_chi*b_tg,0);
        b_dong_qd:=round(b_dong*b_tg,0); b_tai_qd:=round(b_tai*b_tg,0);
    end if;
    b_con_tl:=100-b_do_tl-b_ta_tl; b_chiT:=b_chiT-b_chi;
    b_con:=b_tien-b_chi-b_dong-b_tai; b_con_qd:=b_tien_qd-b_chi_qd-b_dong_qd-b_tai_qd;
    insert into bh_bt_hs_dp_ct values(b_ma_dvi,b_so_id,r_hs.nv,b_ngay_dp,r_lp.lh_nv,b_tien,b_tien_qd,
        b_chi,b_chi_qd,b_con_tl,b_con,b_con_qd,b_do_tl,b_dong,b_dong_qd,b_ta_tl,b_tai,b_tai_qd);
end loop;
select sum(tien),sum(tien_qd),sum(chi),sum(chi_qd),sum(con),sum(con_qd),sum(dong),sum(dong_qd),sum(tai),sum(tai_qd) into
    b_tien,b_tien_qd,b_chi,b_chi_qd,b_con,b_con_qd,b_dong,b_dong_qd,b_tai,b_tai_qd
    from bh_bt_hs_dp_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
insert into bh_bt_hs_dp values(b_ma_dvi,b_so_id,' ',b_ngay_dp,r_hs.nv,r_hs.so_hs,
    b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,r_hs.so_hd,r_hs.ten,r_hs.phong,b_nt_tien,
    b_tien,b_tien_qd,b_chi,b_chi_qd,b_con,b_con_qd,b_dong,b_dong_qd,b_tai,b_tai_qd,r_hs.nsd,b_dvi_ksoat,b_ksoat);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_DUPH_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_DUPH_CT(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_dp number;
begin
-- Dan - Liet ke chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,ngay_dp');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_ngay_dp using b_oraIn;
select JSON_ARRAYAGG(json_object(
    lh_nv,'ten' value FBH_MA_LHNV_TEN(lh_nv),tien,con_tl,con,
    dong_tl,dong,tai_tl,tai) order by lh_nv returning clob) into b_oraOut
    from bh_bt_hs_dp_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
end;
/
create or replace procedure PBH_BT_DUPH_LKE(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Liet ke ngay duph
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
select JSON_ARRAYAGG(json_object(
    ngay_dp,ma_nt,tien,chi,con,dong,tai,ksoat,ma_dvi,so_id)
    order by ngay_dp desc returning clob) into b_oraOut
    from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace procedure PBH_BT_DUPH_XOAn(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_ngay_dp number;
    r_dp bh_bt_hs_dp%rowtype;
begin
-- Dan - Xoa ngay duph
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,ngay_dp');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_ngay_dp using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0); b_ngay_dp:=nvl(b_ngay_dp,0);
if b_ma_dvi=' ' or b_so_id=0 or b_ngay_dp=0 then
    b_loi:='loi:Chon ngay du phong con xoa:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_i1 from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
if b_i1=0 then return; end if;
b_loi:='loi:Khong xoa so lieu nguoi khac:loi';
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id and nsd=b_nsd;
if b_i1=0 or b_ma_dvi<>b_ma_dviN then raise PROGRAM_ERROR; end if;
select * into r_dp from bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
if r_dp.ksoat<>' ' and (r_dp.dvi_ksoat<>b_ma_dvi or r_dp.ksoat<>b_nsd) then
    b_loi:='loi:Khong xoa du phong da duyet:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_dp<to_number(to_char(sysdate,'yyyymm')||'01') and r_dp.ksoat<>' ' then
    b_loi:='loi:Khong xoa du phong thang truoc:loi'; raise PROGRAM_ERROR;
end if;
delete bh_bt_hs_dp_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
delete bh_bt_hs_dp where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_dp=b_ngay_dp;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/




create or replace PROCEDURE FBH_BT_DOTA(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_id_dt number; b_ngay_xr number; b_ngay_hl number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_idB number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tpP number:=0;
    a_ma_dvi_hd pht_type.a_var; a_so_id_hd pht_type.a_num; a_so_id_dt pht_type.a_num;
    r_hs bh_bt_hs%rowtype; r_hd bh_hd_goc%rowtype;
begin
-- Dan - Ty le dong, tai
delete bh_bt_dota_temp;
b_loi:='loi:Ho so da xoa hoac chua duyet:loi';
select * into r_hs from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ngay_xr:=r_hs.ngay_xr;
b_ma_dvi_hd:=r_hs.ma_dvi_ql; b_so_id_hd:=r_hs.so_id_hd; b_so_id_dt:=r_hs.so_id_dt;
a_ma_dvi_hd(1):=b_ma_dvi_hd; a_so_id_hd(1):=b_so_id_hd; a_so_id_dt(1):=b_so_id_dt;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr);
if b_so_idB=0 then b_loi:='loi:Hop dong da xoa hoac chua duyet:loi'; return; end if;
select * into r_hd from bh_hd_goc where ma_dvi=b_ma_dvi_hd and so_id=b_so_idB;
b_nt_tien:=r_hd.nt_tien; b_nt_phi:=r_hd.nt_phi; b_ngay_hl:=r_hd.ngay_hl;
PTBH_GHEP_NV(0,b_ngay_xr,b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,b_loi,'{"mata":"K","nv":"'||r_hs.nv||'"}');
if b_loi is not null then return; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
insert into bh_bt_dota_temp
    select ma_ta,tien,phi,pt_con,tien_con,round(pt_con*phi,b_tpP),
    do_tl,do_tien,round(do_tl*phi,b_tpP),ta_tl+tm_tl,ta_tien+tm_tien,
    round((ta_tl+tm_tl)*phi,b_tpP),ve_tl,ve_tien,round(ve_tl*phi,b_tpP) from tbh_ghep_nv_temp0;
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_BT_DOTA:loi'; end if;
end;
/
create or replace PROCEDURE PBH_BT_DOTA(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number;
begin
-- Dan - Ty le dong, tai
delete bh_bt_dota_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then b_loi:='loi:Nhap ho so:loi'; raise PROGRAM_ERROR; end if;
FBH_BT_DOTA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(lh_nv,'ten' value FBH_MA_LHNV_TEN(lh_nv),
    tien,phi,con_tl,conT,conP,do_tl,doT,doP,ta_tl,taT,taP,ve_tl,veT,veP) order by lh_nv returning clob)
    into b_oraOut from bh_bt_dota_temp; 
delete bh_bt_dota_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HD_DOTA_PT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_loi out varchar2,b_mata varchar2:='K')
AS
    b_i1 number; b_kieu varchar2(10); b_pthuc varchar2(1); b_ttrang varchar2(1);
    b_ngay_ht number; b_nhom varchar2(10); b_nbhC varchar2(20); b_nv varchar2(10);  
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_so_id_ta number; b_ng_hl_ta number;
    b_tien number; b_phi number; b_pt number; b_tienX number; b_phiX number;
    
    bh_so_id_ta pht_type.a_num; bh_lh_nv pht_type.a_var; bh_kieu pht_type.a_var;
    bh_pthuc pht_type.a_var; bh_nbh pht_type.a_var; bh_nbhC pht_type.a_var; 
    bh_pt pht_type.a_num; bh_hh pht_type.a_num; bh_tien pht_type.a_num; bh_phi pht_type.a_num; 
    bh_hhong pht_type.a_num; bh_tl_thue pht_type.a_num; bh_thue pht_type.a_num;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num; dk_phi pht_type.a_num;
    a_so_id_ta pht_type.a_num;
    dt_ct clob; dt_bh clob;
begin
-- Dan - Xem
select nv,ngay_ht,nt_tien,nt_phi,ttrang into b_nv,b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang<>'D' then b_loi:='loi:Hop dong chua duyet:loi'; return; end if;
delete bh_bt_dota_temp_1; delete bh_bt_dota_temp_0;
for b_lp1 in 1..3 loop
    b_nhom:=substr('FDT',b_lp1,1);
    select count(*) into b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom;
    if b_i1=1 then
        if b_nhom='F' then b_kieu:='D';
        elsif b_nhom='T' then b_kieu:='V';
        else b_kieu:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,b_nhom,'kieu');
        end if;
        select txt into dt_ct from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_ct';
        select txt into dt_bh from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and nhom=b_nhom and loai='dt_bh';
        dt_ct:=FKH_JS_BONH(dt_ct); dt_bh:=FKH_JS_BONH(dt_bh);
        FBH_HD_DO_NH_PHId(dt_ct,dt_bh,b_nhom,
            b_ma_dvi,b_so_id,b_so_id_dt,b_nv,b_kieu,b_nt_tien,b_nt_phi,b_tien,b_phi,b_tienX,b_phiX,
            bh_lh_nv,bh_kieu,bh_pthuc,bh_nbh,bh_pt,bh_hh,bh_tien,bh_phi,bh_hhong,bh_tl_thue,bh_thue,b_loi);
        if b_loi is not null then return; end if;
        if b_nhom='D' then b_nhom:=b_nhom||b_kieu; end if;
        for b_lp in 1..bh_nbh.count loop
            b_nbhC:=bh_nbh(b_lp);
            if bh_kieu(b_lp)<>'D' and b_lp>1 then
                b_i1:=b_lp-1;
                for b_lp2 in reverse 1..b_i1 loop
                    if bh_kieu(b_lp2)='D' then b_nbhC:=bh_nbh(b_lp2); exit; end if;
                end loop;
            end if;
            insert into bh_bt_dota_temp_1 values(b_so_id,b_nhom,bh_nbh(b_lp),b_nbhC,bh_lh_nv(b_lp),bh_tien(b_lp),bh_phi(b_lp));
        end loop;
    end if;
end loop;
--
PBH_HD_NV_DKa(b_nv,b_ma_dvi,b_so_id,b_so_id_dt,dk_lh_nv,dk_tien,dk_phi,b_loi);
if b_loi is not null then return; end if;
select distinct a.so_id_d bulk collect into a_so_id_ta from tbh_tm a,tbh_tm_hd b 
    where b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=b_so_id and
    b.so_id_dt in(0,b_so_id_dt) and a.so_id=b.so_id and a.pthuc<>'F';
for b_lp2 in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp2),b_ngay_ht);
    select lh_nv,kieu,nha_bh,nha_bhC,pt,0 bulk collect into
        bh_lh_nv,bh_kieu,bh_nbh,bh_nbhC,bh_pt,bh_hh from tbh_tm_pbo where
        so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and so_id_dt in(0,b_so_id_dt) and tien>0;
    if bh_nbh.count<>0 then
        FBH_HD_DO_NH_PHIt(b_nv,b_nt_tien,b_nt_phi,
            dk_lh_nv,dk_tien,dk_phi,
            bh_lh_nv,bh_kieu,bh_nbh,bh_pt,bh_hh,bh_tien,bh_phi,bh_hhong,bh_tl_thue,bh_thue,b_loi);
        if b_loi is not null then return; end if;
        for b_lp in 1..bh_nbh.count loop
            insert into bh_bt_dota_temp_1 values(
                a_so_id_ta(b_lp2),'C',bh_nbh(b_lp),bh_nbhC(b_lp),bh_lh_nv(b_lp),bh_tien(b_lp),bh_phi(b_lp));
        end loop;
    end if;
end loop;
--
for b_lp1 in 1..2 loop
    b_pthuc:=substr('QS',b_lp1,1);
    select distinct a.so_id_d bulk collect into a_so_id_ta from tbh_ghep a,tbh_ghep_hd b 
        where b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=b_so_id and
        b.so_id_dt in(0,b_so_id_dt) and a.so_id=b.so_id;
    for b_lp2 in 1..a_so_id_ta.count loop
        b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp2),b_ngay_ht);
        select nvl(max(ngay_hl),0) into b_ng_hl_ta from tbh_ghep_pbo where so_id=b_so_id_ta and ngay_hl<=b_ngay_ht;
        if b_ng_hl_ta=0 then continue; end if;
        select lh_nv,kieu,nha_bh,nha_bhC,pt,tien bulk collect into
            bh_lh_nv,bh_kieu,bh_nbh,bh_nbhC,bh_pt,bh_hh from tbh_ghep_pbo where
            so_id=b_so_id_ta and ngay_hl=b_ng_hl_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt in(0,b_so_id_dt) and pthuc=b_pthuc and tien>0;
        if bh_nbh.count=0 then continue; end if;
        FBH_HD_DO_NH_PHIt(b_nv,b_nt_tien,b_nt_phi,
            dk_lh_nv,dk_tien,dk_phi,
            bh_lh_nv,bh_kieu,bh_nbh,bh_pt,bh_hh,bh_tien,bh_phi,bh_hhong,bh_tl_thue,bh_thue,b_loi);
        if b_loi is not null then return; end if;
        forall b_lp in 1..bh_nbh.count
            insert into bh_bt_dota_temp_0 values(
            a_so_id_ta(b_lp2),b_pthuc,bh_nbh(b_lp),bh_nbhC(b_lp),bh_lh_nv(b_lp),bh_tien(b_lp),bh_phi(b_lp));
    end loop;
end loop;
if b_mata='C' then      -- Chuyen ma lh_nv => ma_ta
    update bh_bt_dota_temp_0 set lh_nv=FBH_MA_LHNV_TAI(lh_nv);
end if;
insert into bh_bt_dota_temp_1 select so_id_ta,pthuc,nbh,nbhC,lh_nv,sum(tien),sum(phi)
    from bh_bt_dota_temp_0 group by so_id_ta,pthuc,nbh,nbhC,lh_nv;
delete bh_bt_dota_temp_0;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HD_DOTA_PT:loi'; end if;
end;
/
create or replace procedure FBH_BT_DOTA_PT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    a_so_id_ta out pht_type.a_num,a_pthuc out pht_type.a_var,
    a_nbh out pht_type.a_var,a_nbhC out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_pt out pht_type.a_num,
    a_tien out pht_type.a_num,a_phi out pht_type.a_num,
    b_loi out varchar2,b_mata varchar2:='K',b_nbh varchar2:='K')
AS
    b_i1 number; b_tienH number;
    a_lh_nvH pht_type.a_var; a_tienH pht_type.a_num; a_phiH pht_type.a_num;
begin
-- Dan - Xem
delete bh_bt_dota_temp_1;
FBH_HD_NV_TIENl(b_ma_dvi,b_so_id,b_so_id_dt,a_lh_nvH,a_tienH,a_phiH,b_loi);
if b_loi is not null then return; end if;
FBH_HD_DOTA_PT(b_ma_dvi,b_so_id,b_so_id_dt,b_loi,b_mata);
if b_loi is not null then return; end if;
if b_nbh<>'K' then              -- Lay nbh phu va chinh
    select so_id_ta,pthuc,nbh,nbhC,lh_nv,sum(tien),sum(phi) bulk collect into a_so_id_ta,a_pthuc,a_nbh,a_nbhC,a_lh_nv,a_tien,a_phi
        from bh_bt_dota_temp_1 group by so_id_ta,pthuc,nbh,nbhC,lh_nv having sum(tien)<>0;
else                            -- Chi lay nbh chinh
    select so_id_ta,pthuc,nbhC,lh_nv,sum(tien),sum(phi) bulk collect into a_so_id_ta,a_pthuc,a_nbhC,a_lh_nv,a_tien,a_phi
        from bh_bt_dota_temp_1 group by so_id_ta,pthuc,nbhC,lh_nv having sum(tien)<>0;
    for b_lp in 1..a_pthuc.count loop
        a_nbh(b_lp):=a_nbhC(b_lp);
    end loop;
end if;
b_tienH:=FKH_ARR_TONG(a_tienH);
for b_lp in 1..a_pthuc.count loop
    b_i1:=FKH_ARR_VTRI(a_lh_nvH,a_lh_nv(b_lp));
    if b_i1=0 then
        a_pt(b_lp):=round(a_tien(b_lp)*100/b_tienH,2);
    else
        a_pt(b_lp):=round(a_tien(b_lp)*100/a_tienH(b_i1),2);
    end if;
end loop;
delete bh_bt_dota_temp_1;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_BT_DOTA_PT:loi'; end if;
end;
/
create or replace PROCEDURE PBH_BT_DOTA_LKE(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_i2 number;
    b_ma_dvi varchar2(10); b_so_id number; b_pt number; b_nv varchar2(10);
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_hdB number; b_so_id_dt number;
    b_nt_tien varchar2(5); b_tp number:=0; b_bth number; b_bthH number;
    b_ngay_xr number; b_ngay_hl number; b_ttrang varchar2(1); b_so_idD number;
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_nbh pht_type.a_var; a_nbhC pht_type.a_var; 
    a_lh_nv pht_type.a_var; a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num;
    a_s pht_type.a_var;
begin
-- Dan - Ty le tai
delete bh_bt_dota_temp; delete bh_bt_dota_temp_1;
delete bh_bt_dota_temp_2; delete bh_bt_dota_temp_3; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then b_loi:='loi:Nhap ho so:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ho so da xoa:loi';
select nv,ngay_xr,nt_tien,ma_dvi_ql,so_id_hd,so_id_dt,ttrang into
    b_nv,b_ngay_xr,b_nt_tien,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_ttrang
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_hdB:=FBH_HD_SO_ID_BS(b_ma_dvi_hd,b_so_id_hd,b_ngay_xr); 
b_ngay_hl:=FBH_HD_NGAY_HL(b_ma_dvi_hd,b_so_id_hdB,b_ngay_xr);
if b_ttrang not in('T','D') then
    b_loi:='loi:Ho so chua o trang thai trinh, duyet:loi'; raise PROGRAM_ERROR;
end if;
select lh_nv,sum(tien) bulk collect into dk_lh_nv,dk_tien from bh_bt_hs_nv
    where ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv<>' ' group by lh_nv having sum(tien)<>0;
b_bthH:=FKH_ARR_TONG(dk_tien);
if b_bthH=0 then b_loi:='loi:Ho so khong boi thuong:loi'; raise PROGRAM_ERROR; end if;
--nampb: ty le dong tai lay theo so_id_d
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
FBH_BT_DOTA_PT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,
    a_so_id_ta,a_pthuc,a_nbh,a_nbhC,a_lh_nv,a_pt,a_tien,a_phi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
for b_lp in 1..a_pthuc.count loop
    for b_lp1 in 1..dk_lh_nv.count loop
        if a_lh_nv(b_lp) in(' ',dk_lh_nv(b_lp1)) then
            b_i1:=round(dk_tien(b_lp1)*a_pt(b_lp)/100,b_tp);
            insert into bh_bt_dota_temp_2 values(a_pthuc(b_lp),a_nbhC(b_lp),a_tien(b_lp),b_i1);
        end if;
    end loop;
end loop;
insert into bh_bt_dota_temp_3 select pthuc,nbh,0,sum(tien),sum(bth) from bh_bt_dota_temp_2 group by pthuc,nbh;
select nvl(sum(bth),0) into b_bth from bh_bt_dota_temp_3 where pthuc='DV';
if b_bth<>0 then b_bth:=b_bthH-b_bth; end if;
select nvl(sum(bth),0) into b_i1 from bh_bt_dota_temp_3 where pthuc='T';
b_bth:=b_bth+b_i1;
if b_bth=0 then b_bth:=b_bthH; end if;
select nvl(sum(bth),0) into b_i1 from bh_bt_dota_temp_3 where pthuc not in('DV','T');
b_bth:=b_bth-b_i1;
insert into bh_bt_dota_temp_3 values(' ','..0',0,0,b_bth);
PKH_CH_ARR('DD,DV,F,T,C,Q,S',a_s);
for b_lp in 1..a_s.count loop
    select sum(bth) into b_bth from bh_bt_dota_temp_3 where pthuc=a_s(b_lp);
    if b_bth<>0 then
        insert into bh_bt_dota_temp_3 values(to_char(b_lp)||a_s(b_lp),'..'||to_char(b_lp)||a_s(b_lp),0,0,b_bth);
    end if;
end loop;
for b_lp in 1..a_s.count loop
    update bh_bt_dota_temp_3 set pthuc=to_char(b_lp)||a_s(b_lp) where pthuc=a_s(b_lp);
end loop;
update bh_bt_dota_temp_3 set pt=round(bth*100/b_bthH,2);
select JSON_ARRAYAGG(json_object('nbh' value decode(instr(nbh,'..'),0,'-- '||FBH_DTAC_MA_TEN(nbh),nbh),pt,bth,tien,pthuc)
    order by sott returning clob) into b_oraOut from
    (select nbh,pt,bth,tien,pthuc,row_number() over (order by pthuc,nbh) sott from bh_bt_dota_temp_3 order by pthuc,nbh);
delete bh_bt_dota_temp; delete bh_bt_dota_temp_1; delete bh_bt_dota_temp_2; delete bh_bt_dota_temp_3; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
