create or replace function FBH_PKTP_NGAY_PH(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_xr number:=30000101) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay phuc hoi
select nvl(max(ngay_ht),0) into b_kq from bh_pktP_dvi where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and ngay_ht<b_ngay_xr;
return b_kq;
end;
/
create or replace PROCEDURE PBH_PKTP_PT(b_ma_dvi varchar2,b_so_id number,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngcap number;
    b_kieu_do varchar2(1); b_kieu_hhv varchar2(1); b_kieu_phv varchar2(1);
    b_tp number:=0; b_tg number:=1; b_ngay_ht number; b_nt_phi varchar2(5);
    b_hhong number; b_htro number; b_dvu number; b_hhong_qd number; b_htro_qd number; b_dvu_qd number;
    b_hhong_tl number; b_htro_tl number; b_dvu_tl number; 
    b_k_tl_hh varchar2(1); b_k_tl_ht varchar2(1); b_kieu_tt varchar2(1);
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_tl_mg number; b_nv varchar2(10);

    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_ma_dt pht_type.a_var;
    dk_phi pht_type.a_num; dk_thue pht_type.a_num; dk_phi_qd pht_type.a_num; dk_thue_qd pht_type.a_num;
begin
-- Dan - Phan tich thanh toan
b_loi:='loi:Loi xu ly PBH_PKTP_PT:loi';
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
select count(*) into b_i1 from bh_pktP where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
if b_i1=0 then b_loi:=''; return; end if;
select ngay_ht,nt_phi into b_ngay_ht,b_nt_phi from bh_pktP where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
if b_nt_phi='VND' then b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi); end if;
select nv,kieu_kt,ma_kt,hhong,ngay_cap into b_nv,b_kieu_kt,b_ma_kt,b_tl_mg,b_ngcap
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_kieu_do:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','kieu');
b_kieu_phv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
b_kieu_hhv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','dl');
select lh_nv,t_suat,ma_dt,sum(phi),sum(thue),sum(phi_qd),sum(thue_qd) BULK COLLECT
    into dk_lh_nv,dk_t_suat,dk_ma_dt,dk_phi,dk_thue,dk_phi_qd,dk_thue_qd
    from bh_pktP_dk where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps group by lh_nv,t_suat,ma_dt;
for b_lp in 1..dk_lh_nv.count loop
    b_hhong:=0; b_htro:=0; b_dvu:=0;
    b_hhong_qd:=0; b_htro_qd:=0; b_dvu_qd:=0;
    b_hhong_tl:=0; b_htro_tl:=0; b_dvu_tl:=0;
    if b_kieu_kt<>'T' and trim(b_ma_kt) is not null and (b_kieu_do<>'V' or b_kieu_hhv<>'K') then
        if b_kieu_kt='M' then
            b_hhong_tl:=b_tl_mg;
        else
            FBH_DL_MA_KH_LHNV_HH(b_ma_kt,b_nv,b_ngcap,dk_lh_nv(b_lp),b_hhong_tl,b_htro_tl,b_dvu_tl);
        end if;
        if b_kieu_do='D' and b_kieu_hhv='C' then
            b_i2:=FBH_HD_DO_NH_TXTn(b_ma_dvi,b_so_id,'D','pt_dl');
            if b_i2>0 and b_i2<100 then
                b_i2:=100-b_i2;
                b_hhong_tl:=round(b_hhong_tl*b_i2/100,3);
                b_htro_tl:=round(b_htro_tl*b_i2/100,3);
                b_dvu_tl:=round(b_dvu_tl*b_i2/100,3);
            end if;
        end if;
        b_hhong:=round(dk_phi(b_lp)*b_hhong_tl/100,b_tp);
        b_htro:=round(dk_phi(b_lp)*b_htro_tl/100,b_tp);
        b_dvu:=round(dk_phi(b_lp)*b_dvu_tl/100,b_tp);
        if b_tg=1 then
            b_hhong_qd:=b_hhong; b_htro_qd:=b_htro; b_dvu_qd:=b_dvu;
        else
            b_hhong_qd:=round(b_hhong*b_tg,0);
            b_htro_qd:=round(b_htro*b_tg,0);
            b_dvu_qd:=round(b_dvu*b_tg,0);
        end if;
    end if;
    insert into bh_hd_goc_ttpt values(b_ma_dvi,b_so_id_ps,b_lp,b_so_id,b_nv,b_ngay_ht,b_ngay_ht,b_ngay_ht,
        'G',dk_ma_dt(b_lp),b_nt_phi,dk_lh_nv(b_lp),dk_t_suat(b_lp),
        dk_phi(b_lp),dk_thue(b_lp),dk_phi(b_lp)+dk_thue(b_lp),b_hhong,b_htro,b_dvu,
        dk_phi_qd(b_lp),dk_thue_qd(b_lp),dk_phi_qd(b_lp)+dk_thue_qd(b_lp),
        b_hhong_tl,b_htro_tl,b_dvu_tl,b_hhong_qd,b_htro_qd,b_dvu_qd);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace PROCEDURE PBH_PKTP_PTDT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number; b_tp number:=0; b_hs number; b_bt number;
    b_nv varchar2(10):='PKT'; b_so_idD number; b_so_idB number; b_nt_phi varchar2(5);
    b_phi number; b_thue number; b_hhong number; b_htro number; b_dvu number; 
    b_phi_qd number; b_thue_qd number; b_hhong_qd number; b_htro_qd number; b_dvu_qd number;
    b_phiX number; b_thueX number; b_hhongX number; b_htroX number; b_dvuX number; 
    b_phi_qdX number; b_thue_qdX number; b_hhong_qdX number; b_htro_qdX number; b_dvu_qdX number;
    b_phiC number; b_thueC number; b_hhongC number; b_htroC number; b_dvuC number; 
    b_phi_qdC number; b_thue_qdC number; b_hhong_qdC number; b_htro_qdC number; b_dvu_qdC number;
    a_so_id_dt pht_type.a_num; a_ma_dt pht_type.a_var; a_phi pht_type.a_num; a_idD pht_type.a_num;
begin
-- Dan - Phan tich phuc hoi cho doi tuong
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
select count(*) into b_i1 from bh_pktP where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
if b_i1=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_d,nt_phi into b_so_idD,b_nt_phi from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idD and so_id_dt<>b_so_idD;
if b_i1=0 then
    insert into bh_hd_goc_ttptdt select
        ma_dvi,so_id_tt,bt,so_id,0,b_nv,ngay_ht,ngay_tt,ngay,pt,ma_dt,ma_nt,
        lh_nv,t_suat,phi,thue,ttoan,hhong,htro,dvu,phi_qd,thue_qd,
        ttoan_qd,hhong_qd,htro_qd,dvu_qd,hhong_tl,htro_tl,dvu_tl
        from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
    b_loi:=''; return;
end if;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id); b_bt:=0;
for r_lp in(select * from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps and phi<>0) loop
    select so_id_dt,ma_dt,phi bulk collect into a_so_id_dt,a_ma_dt,a_phi from bh_hd_goc_ptdt
        where ma_dvi=b_ma_dvi and so_id_xl=b_so_idB and ngay=r_lp.ngay and lh_nv=r_lp.lh_nv;
    PKH_MANG_DUYn(a_so_id_dt,a_idD);
    if a_idD.count=1 then
        b_bt:=b_bt+1;
        insert into bh_hd_goc_ttptdt values(
            b_ma_dvi,b_so_id_ps,b_bt,r_lp.so_id,a_idD(1),b_nv,r_lp.ngay_ht,r_lp.ngay_tt,
            r_lp.ngay,r_lp.pt,a_ma_dt(1),r_lp.ma_nt,r_lp.lh_nv,r_lp.t_suat,
            r_lp.phi,r_lp.thue,r_lp.ttoan,r_lp.hhong,r_lp.htro,r_lp.dvu,r_lp.phi_qd,r_lp.thue_qd,
            r_lp.ttoan_qd,r_lp.hhong_qd,r_lp.htro_qd,r_lp.dvu_qd,r_lp.hhong_tl,r_lp.htro_tl,r_lp.dvu_tl);
        continue;
    end if;
    b_phi:=r_lp.phi; b_thue:=r_lp.thue; b_hhong:=r_lp.hhong; b_htro:=r_lp.htro; b_dvu:=r_lp.dvu;
    b_phi_qd:=r_lp.phi_qd; b_thue_qd:=r_lp.thue_qd; b_hhong_qd:=r_lp.hhong_qd;
    b_htro_qd:=r_lp.htro_qd; b_dvu_qd:=r_lp.dvu_qd;
    b_i1:=FKH_ARR_TONG(a_phi); b_hs:=round(abs(b_i1/b_phi),5);
    for b_lp in 1..a_so_id_dt.count loop
        if b_lp=a_so_id_dt.count then
            b_hhongX:=b_hhongC; b_htroX:=b_htroC;
            b_dvuX:=b_dvuC; b_phi_qdX:=b_phi_qdC;
            b_thue_qdX:=b_thue_qdC; b_hhong_qdX:=b_hhong_qdC;
            b_htro_qdX:=b_htro_qdC; b_dvu_qdX:=b_dvu_qdC;
        else
            b_phiX:=round(b_phi*b_hs,b_tp); b_thueX:=round(b_thue*b_hs,b_tp);
            b_hhongX:=round(b_hhong*b_hs,b_tp); b_htroX:=round(b_htro*b_hs,b_tp);
            b_dvuX:=round(b_dvu*b_hs,b_tp); b_phi_qd:=round(b_phi_qd*b_hs,0);
            b_thue_qdX:=round(b_thue_qd*b_hs,0); b_hhong_qdX:=round(b_hhong_qd*b_hs,0);
            b_htro_qdX:=round(b_htro_qd*b_hs,0); b_dvu_qdX:=round(b_dvu_qd*b_hs,0);
            b_phiC:=b_phi-b_phiX; b_thueC:=b_thue-b_thueX;
            b_hhongC:=b_hhong-b_hhongX; b_htroC:=b_htro-b_htroX;
            b_dvuC:=b_dvu-b_dvuX; b_phi_qdC:=b_phi_qd-b_phi_qdX;
            b_thue_qdC:=b_thue_qd-b_thue_qdX; b_hhong_qdC:=b_hhong_qd-b_hhong_qdX;
            b_htro_qdC:=b_htro_qd-b_htro_qdX; b_dvu_qdC:=b_dvu_qd-b_dvu_qdX;
        end if;
        b_bt:=b_bt+1;
        insert into bh_hd_goc_ttptdt values(
            b_ma_dvi,b_so_id_ps,b_bt,r_lp.so_id,a_so_id_dt(b_lp),b_nv,r_lp.ngay_ht,r_lp.ngay_tt,
            r_lp.ngay,r_lp.pt,a_ma_dt(b_lp),r_lp.ma_nt,r_lp.lh_nv,r_lp.t_suat,
            b_phiX,b_thueX,b_phiX+b_thueX,b_hhongX,b_htroX,b_dvuX,b_phi_qdX,b_thue_qdX,
            b_phi_qdX+b_thue_qdX,b_hhong_qdX,b_htro_qdX,b_dvu_qdX,r_lp.hhong_tl,r_lp.htro_tl,r_lp.dvu_tl);
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PKTP_PTDT:loi'; end if;
end;
/
create or replace procedure PBH_PKTP_TH_ID(
    b_ma_dvi varchar2,b_dk varchar2,b_so_id number,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number;
    b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_kieu_hd varchar2(1);
    pbo_ma_dvi  pht_type.a_var; pbo_so_id_tt pht_type.a_num; pbo_phi_dt pht_type.a_num;
begin
-- Dan - Phan tich
b_loi:='';
delete bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_ps;
delete bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_ps;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_ps;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_tt=b_so_id_ps;
PBH_PKTP_PT(b_ma_dvi,b_so_id,b_so_id_ps,b_loi);
if b_loi is not null then return; end if;
PBH_PKTP_PTDT(b_ma_dvi,b_so_id,b_so_id_ps,b_loi);
if b_loi is not null then return; end if;
b_kieu_do:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','kieu'); b_kieu_phv:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_id,'D','ph');
if b_kieu_do='V' and b_kieu_phv='K' then
    PBH_HD_DO_TH_VAT(b_ma_dvi,b_so_id_ps,b_loi);
else
    PBH_TH_VAT(b_ma_dvi,b_so_id,b_so_id_ps,b_loi);
end if;
if b_loi is not null then return; end if;
PBH_TH_HH(b_ma_dvi,b_so_id,b_so_id_ps,b_loi);
if b_loi is not null then return; end if;
PBH_TH_DO(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKTP_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_so_hd varchar2(20); b_tu number; b_den number; b_so_idD number; b_so_idB number;
    b_dong number; cs_lke clob; cs_ct clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_tu,b_den using b_oraIn;
b_so_hd:=nvl(trim(b_so_hd),' ');
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_idD:=FBH_PKT_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_so_idD=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
b_so_idB:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_idD);
select json_object(nt_tien,nt_phi) into cs_ct from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
select count(*) into b_dong from bh_pktP where ma_dvi=b_ma_dvi and so_id=b_so_idD;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(ngay_ht) order by ngay_ht desc returning clob) into cs_lke
    from bh_pktP where ma_dvi=b_ma_dvi and so_id=b_so_idD;
select json_object('dong' value b_dong,'cs_lke' value cs_lke,'cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTP_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht,b_trangKt using b_oraIn;
b_so_hd:=nvl(trim(b_so_hd),' '); b_ngay_ht:=nvl(b_ngay_ht,0);
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PKT_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pktP where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nvl(min(sott),b_dong) into b_tu from
    (select ngay_ht,rownum sott from bh_pktP where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay_ht)
    where ngay_ht>=b_ngay_ht;
PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(ngay_ht) order by ngay_ht desc returning clob) into cs_lke from
    (select ngay_ht,rownum sott from bh_pktP  where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay_ht)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTP_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_so_hd varchar2(20); b_so_id_ps number; b_ngay_ht number;
    dt_ct clob; dt_hd clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht using b_oraIn;
b_so_hd:=nvl(trim(b_so_hd),' '); b_ngay_ht:=nvl(b_ngay_ht,0);
select nvl(min(so_id_ps),0) into b_so_id_ps from bh_pktP where ma_dvi=b_ma_dvi and so_hd=b_so_hd and ngay_ht=b_ngay_ht;
if b_so_id_ps=0 then b_loi:='loi:Phuc hoi da xoa:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_ct from bh_pktP_txt where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and loai='dt_ct';
select txt into dt_hd from bh_pktP_txt where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and loai='dt_hd';
select json_object('dt_ct' value dt_ct,'dt_hd' value dt_hd returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTP_THEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_i1 number; b_so_hd varchar2(20); b_so_id number;
    b_dvi nvarchar2(500); b_lan number;b_so_idB number;b_bth number;
begin
-- Dan - Xem
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hd:=nvl(trim(b_oraIn),' ');
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PKT_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
for r_lp in (select so_id_dt,max(ngay_qd) ngay_qd,sum(tien) bth from bh_bt_pkt
    where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id and ttrang='D' group by so_id_dt) loop

  select count(*) into b_i1 from bh_pktP_dvi where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht>=r_lp.ngay_qd and so_id_dt=r_lp.so_id_dt;
    if b_i1<>0 then continue; end if;
    b_so_idB:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_id);
    select nvl(sum(b.tien),0) into b_bth from bh_bt_pkt a,bh_bt_pkt_dk b where
        a.ma_dvi_ql=b_ma_dvi and a.so_id_hd=b_so_idB and a.so_id_dt=r_lp.so_id_dt and a.ttrang='D' and
        b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.lh_nv<>' ' and FBH_MA_LHNV_LOAI(b.lh_nv)='V';
    if b_bth=0 then continue; end if;
    select min(dvi) into b_dvi from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=r_lp.so_id_dt;
    select count(*) into b_lan from bh_pktP_dvi where
        ma_dvi=b_ma_dvi and so_id=b_so_idB and ngay_ht<r_lp.ngay_qd and so_id_dt=r_lp.so_id_dt;
    insert into temp_1(c1,n1,n2,n3,n4,n10) values(b_dvi,b_lan,b_bth,0,0,r_lp.so_id_dt);

end loop;
select JSON_ARRAYAGG(json_object('dvi' value c1,'lan' value n1,'bth' value n2,'phi' value n3,'thue' value n4,'so_id_dt' value n10)
    order by n10 returning clob) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTP_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number; b_so_idK number; b_nsdC varchar2(20); b_so_id number; b_ngay_ht number;
begin
-- Dan - Xoa
b_loi:='loi:Loi xu ly PBH_PKTP_XOA_XOA:loi';
select count(*) into b_i1 from bh_pktP where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
if b_i1=0 then b_loi:=''; return; end if;
select so_id_kt,nsd,so_id,ngay_ht into b_so_idK,b_nsdC,b_so_id,b_ngay_ht
    from bh_pktP where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TT');
if b_loi is not null then return; end if;
if b_so_idK>0 then b_loi:='loi:Khong sua, xoa phuc hoi da hach toan ke toan:loi'; return; end if;
if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
select count(*) into b_i1 from bh_pktP where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht>b_ngay_ht;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa phuc hoi da co phuc hoi:loi'; return; end if;
select count(*) into b_i1 from bh_pktP_dvi a,bh_bt_pkt b where
    a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and a.ngay_ht=b_ngay_ht and
    b.ma_dvi_ql=b_ma_dvi and b.so_id_hd=b_so_id and b.so_id_dt=a.so_id_dt and ttrang='D' and b.ngay_qd>=b_ngay_ht;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa phuc hoi da co boi thuong da duyet:loi'; return; end if;
if FBH_PS_HH(b_ma_dvi,b_so_id,b_so_id_ps)<>0 then
    b_loi:='loi:Chung tu thanh toan da duyet hoa hong:loi'; return;
end if;
if FBH_HD_DO_CT(b_ma_dvi,b_so_id_ps)<>0 then
    b_loi:='loi:Chung tu thanh toan da thanh toan dong BH:loi'; return;
end if;
if FBH_PS_VAT(b_ma_dvi,b_so_id_ps)<>0 or FBH_HD_DO_PS_VAT(b_ma_dvi,b_so_id_ps)<>0  then
    b_loi:='loi:Chung tu thanh toan da phat hanh hoa don thue:loi'; return;
end if;
PBH_HD_TT_XOA_VAT(b_ma_dvi,b_so_id_ps,b_loi);
if b_loi is not null then return; end if;
PBH_HD_TT_XOA_VAT_DO(b_ma_dvi,b_so_id_ps,b_loi);
if b_loi is not null then return; end if;
PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id_ps,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_XOA(b_so_id_ps,0,0,0,b_loi);
if b_loi is not null then return; end if;
delete bh_hd_goc_ttptdt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
delete bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
delete bh_hd_goc_ttpb where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
delete bh_hd_do_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_ps;
delete bh_pktP_dk where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete bh_pktP_txt where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete bh_pktP_dvi where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
delete bh_pktP where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKTP_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_ps number,b_so_id number,
    dt_ct in out clob,dt_hd clob,
    b_so_hd varchar2,b_ngay_ht number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_so_id_dt pht_type.a_num,a_dvi pht_type.a_nvar,a_ma_dt pht_type.a_var,
    a_lan pht_type.a_num,a_bth pht_type.a_num,
    a_phi pht_type.a_num,a_thue pht_type.a_num,b_loi out varchar2)
AS
    b_so_ct varchar2(20):=substr(to_char(b_so_id),3); b_so_idB number;
    b_tp number:=0; b_tg number:=1; b_hs number;
    b_phi number; b_thue number; b_phi_qd number; b_thue_qd number;
    b_phiP number; b_thueP number; b_phiP_qd number; b_thueP_qd number;
    b_phiT number; b_thueT number; b_phiT_qd number; b_thueT_qd number; b_phiM number; b_lh_nv varchar2(10);
begin
-- Dan - Nhap
b_loi:='loi:Loi xu ly PBH_PKTP_NH_NH:loi';
b_so_idB:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_id);
if b_nt_phi='VND' then
    b_tp:=2; b_tg:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_phi);
end if;
for b_lp in 1..a_so_id_dt.count loop
    if a_phi(b_lp)=0 then continue; end if;
    select nvl(sum(phi),0) into b_phiT from bh_pkt_dk
        where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=a_so_id_dt(b_lp) and lh_nv<>' ';
    if b_phiT=0 then  continue; end if;
    b_hs:=a_phi(b_lp)/b_phiT; b_lh_nv:=' '; b_phiM:=0; b_phiT:=a_phi(b_lp); b_thueT:=a_thue(b_lp);
    for r_lp in(select lh_nv,t_suat,sum(phi) phi,sum(thue) thue from bh_pkt_dk where
        ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=a_so_id_dt(b_lp) and lh_nv<>' ' and phi<>0 group by lh_nv,t_suat) loop
        if r_lp.phi>b_phiM then b_phiM:=r_lp.phi; b_lh_nv:=r_lp.lh_nv; end if;
        b_phiP:=round(a_phi(b_lp)*b_hs,b_tp); b_thueP:=round(a_thue(b_lp)*b_hs,b_tp);
        b_phiT:=b_phiT-b_phiP; b_thueT:=b_thueT-b_thueP;
        if b_tg=1 then
            b_phiP_qd:=b_phiP; b_thueP_qd:=b_thueP;
        else
            b_phiP_qd:=round(b_phiP*b_tg,0); b_thueP_qd:=round(b_thueP*b_tg,0);
        end if;
        insert into bh_pktP_dk values(b_ma_dvi,b_so_id_ps,b_so_id,a_so_id_dt(b_lp),b_ngay_ht,
            r_lp.lh_nv,r_lp.t_suat,a_ma_dt(b_lp),b_phiP,b_thueP,b_phiP_qd,b_thueP_qd);
    end loop;
    if b_phiT<>0 or b_thueT<>0 then
        if b_tg=1 then
            b_phiT_qd:=b_phiT; b_thueT_qd:=b_thueT;
        else
            b_phiT_qd:=round(b_phiT*b_tg,0); b_thueT_qd:=round(b_thueT*b_tg,0);
        end if;
        update bh_pktP_dk set phi=phi+b_phiT,thue=thue+b_thueT,phi_qd=phi_qd+b_phiT_qd,thue_qd=thue_qd+b_thueT_qd
            where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and so_id_dt=a_so_id_dt(b_lp) and lh_nv=b_lh_nv;
    end if;
end loop;
select sum(phi),sum(thue),sum(phi_qd),sum(thue_qd) into b_phiT,b_thueT,b_phiT_qd,b_thueT_qd
    from bh_pktP_dk where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
insert into bh_pktP values(
    b_ma_dvi,b_so_id_ps,b_so_id,b_so_hd,b_ngay_ht,b_so_ct,b_nt_tien,b_nt_phi,
    b_phi,b_thue,b_phi+b_thue,b_phi_qd,b_thue_qd,b_phi_qd+b_thue_qd,0,b_nsd,sysdate);
forall b_lp in 1..a_so_id_dt.count
    insert into bh_pktP_dvi values(b_ma_dvi,b_so_id_ps,b_so_id,a_so_id_dt(b_lp),b_ngay_ht,
        a_dvi(b_lp),a_ma_dt(b_lp),a_lan(b_lp),a_bth(b_lp),a_phi(b_lp),a_thue(b_lp),a_phi(b_lp)+a_thue(b_lp));
PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
insert into bh_pktP_txt values(b_ma_dvi,b_so_id_ps,b_so_id,b_ngay_ht,'dt_ct',dt_ct);
insert into bh_pktP_txt values(b_ma_dvi,b_so_id_ps,b_so_id,b_ngay_ht,'dt_hd',dt_hd);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKTP_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    b_so_id_ps number; b_so_id number; b_so_idB number; b_nha_bh varchar2(20);
    b_so_hd varchar2(20); b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_phong varchar2(10); b_kieu_do varchar2(1);
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_ma_thue varchar2(20); b_dchi nvarchar2(500);
    a_so_id_dt pht_type.a_num; a_dvi pht_type.a_nvar; a_ma_dt pht_type.a_var;
    a_lan pht_type.a_num; a_bth pht_type.a_num; a_phi pht_type.a_num; a_thue pht_type.a_num;
    dt_ct clob; dt_hd clob;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd);
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht using dt_ct;
b_so_hd:=nvl(trim(b_so_hd),' '); b_ngay_ht:=nvl(b_ngay_ht,0);
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_PKT_HD_SO_IDd(b_ma_dvi,b_so_hd);
if b_so_id=0 then b_loi:='loi:Hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_ht=0 then b_loi:='loi:Nhap ngay phuc hoi:loi'; raise PROGRAM_ERROR; end if;
select nvl(min(so_id_ps),0) into b_so_id_ps from bh_pktP where ma_dvi=b_ma_dvi and so_hd=b_so_hd and ngay_ht=b_ngay_ht;
if b_so_id_ps<>0 then
    PBH_PKTP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_ps,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    PHT_ID_MOI(b_so_id_ps,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('dvi,lan,bth,phi,thue,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_dvi,a_lan,a_bth,a_phi,a_thue,a_so_id_dt using dt_hd;
if a_dvi.count=0 then b_loi:='loi:Nhap dia diem phuc hoi:loi'; raise PROGRAM_ERROR; end if;
b_so_idB:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_id);
b_loi:='loi:Hop dong bo sung da xoa:loi';
select nt_tien,nt_phi into b_nt_tien,b_nt_phi from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
for b_lp in 1..a_so_id_dt.count loop
    a_lan(b_lp):=nvl(a_lan(b_lp),0); a_bth(b_lp):=nvl(a_bth(b_lp),0);
    a_phi(b_lp):=nvl(a_phi(b_lp),0); a_thue(b_lp):=nvl(a_thue(b_lp),0);
    a_so_id_dt(b_lp):=nvl(a_so_id_dt(b_lp),0);
    b_loi:='loi:Dia diem dong '||to_char(b_lp)||' da xoa:loi';
    select ma_dt into a_ma_dt(b_lp) from bh_pkt_dvi
        where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=a_so_id_dt(b_lp);
    select dvi into a_dvi(b_lp) from bh_pkt_dvi
        where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=a_so_id_dt(b_lp);
end loop;
PBH_PKTP_NH_NH(
    b_ma_dvi,b_nsd,b_so_id_ps,b_so_id,dt_ct,dt_hd,b_so_hd,b_ngay_ht,b_nt_tien,b_nt_phi,
    a_so_id_dt,a_dvi,a_ma_dt,a_lan,a_bth,a_phi,a_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_PKTP_TH_ID(b_ma_dvi,'T',b_so_id,b_so_id_ps,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select phong,ma_kh,ten into b_phong,b_ma_kh,b_ten from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ma_kh='VANGLAI' then
    b_dchi:=' '; b_ma_thue:=' ';
else
    select cmt,dchi into b_dchi,b_ma_thue from bh_dtac_ma where ma=b_ma_kh;
end if;
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
--if b_kieu_do='G' then
    --PBH_HD_TT_NH_VAT(b_ma_dvi,b_nsd,b_so_id_ps,b_ngay_ht,'P',b_phong,b_ma_kh,b_nt_phi,b_ma_thue,

    --    b_ten,b_dchi,' ',' ',' ',b_ngay_ht,b_ngay_ht,'H',b_ngay_ht,b_loi);
    --if b_loi is not null then return; end if;
if b_kieu_do='V' then
    b_nha_bh:=FBH_DONG_NBHV(b_ma_dvi,b_so_id);
    PBH_HD_TT_NH_VAT_DO(b_ma_dvi,b_nsd,b_so_id_ps,b_ngay_ht,b_phong,b_nha_bh,b_nt_phi,' ',b_ngay_ht,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    PBH_HD_DO_TH_PS(b_ma_dvi,b_so_id,b_so_id_ps,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PTBH_TH_TA_PHI_GHEP(b_ma_dvi,b_so_id_ps,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_TH_TA_PHI_TM(b_ma_dvi,b_so_id_ps,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
--pbh_bh_vat_job_nh(b_ma_dvi,b_so_id, b_so_id_ps,b_loi);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PKTP_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_so_id_ps number;
    b_so_hd varchar2(20); b_ngay_ht number;
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PKT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,ngay_ht');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_ngay_ht using b_oraIn;
b_so_hd:=nvl(trim(b_so_hd),' '); b_ngay_ht:=nvl(b_ngay_ht,0);
if b_so_hd=' ' then b_loi:='loi:Nhap so hop dong:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_ht=0 then b_loi:='loi:Nhap ngay phuc hoi:loi'; raise PROGRAM_ERROR; end if;
select nvl(min(so_id_ps),0) into b_so_id_ps from bh_pktP where ma_dvi=b_ma_dvi and so_hd=b_so_hd and ngay_ht=b_ngay_ht;
if b_so_id_ps<>0 then
    PBH_PKTP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_ps,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    commit;
end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/




