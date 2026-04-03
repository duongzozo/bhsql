/*** DONG BAO HIEM ***/
create or replace function FBH_HD_DO_PS_VAT(b_ma_dvi varchar2,b_so_id_tt number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from bh_hd_do_vat_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id_vat<>b_so_id_tt;
return b_kq;
end;
/
create or replace function FBH_DONG_KYHO(b_ma_dvi varchar2,b_so_id number,b_dvi varchar2) return varchar2
AS
    b_kq varchar2(20):='K'; b_i1 number;
begin
-- Dan - Hop dong noi bo ky ho (ty le 100%)
select count(*) into b_i1 from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and nha_bh=b_dvi and pthuc='D' and pt=100;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DONG_NBH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac nha BH
select nvl(min(nha_bh),' '),count(*) into b_kq,b_i1 from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C';
if b_i1>1 then b_kq:=' '; end if;
return b_kq;
end;
/
create or replace function FBH_DONG_NBHk(b_ma_dvi varchar2,b_so_id number,b_nbh varchar2:=' ') return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Xac dinh nha BH
select count(*) into b_i1 from bh_hd_do_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C' and b_nbh in(' ',nha_bh);
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure FBH_DONG_TL_DT_DVI(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,a_dvi out pht_type.a_var,a_tl out pht_type.a_num)
AS
    b_bt number:=0; b_i1 number;
begin
-- Dan - Xac dinh ty le dong noi bo theo nghiep vu
PKH_MANG_KD(a_dvi); PKH_MANG_KD_N(a_tl);
for r_lp in (select distinct nha_bh from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select nvl(max(pt),0) into b_i1 from (
        select nha_bh,so_id_dt,pthuc,pt,lh_nv from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id)
        where nha_bh=r_lp.nha_bh and so_id_dt in (0,b_so_id_dt) and pthuc='D' and lh_nv in (' ',b_lh_nv);
    if b_i1>0 then
        b_bt:=b_bt+1;
        a_dvi(b_bt):=r_lp.nha_bh; a_tl(b_bt):=b_i1;
    end if;
end loop;
end;
/
create or replace function FBH_DONG_TL_DT_1DVI(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_dvi varchar2) return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ty le dong noi bo theo nghiep vu cho 1 don vi
select nvl(max(pt),0) into b_kq from
    (select nha_bh,so_id_dt,pthuc,pt,lh_nv from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id)
    where nha_bh=b_dvi and so_id_dt in (0,b_so_id_dt) and pthuc='D' and lh_nv in (' ',b_lh_nv);
return b_kq;
end;
/
create or replace procedure FBH_DONG_TL_HD
    (b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num,
    a_lh_nv out pht_type.a_var,a_pt out pht_type.a_num,a_hh out pht_type.a_num)
AS
    b_i1 number:=0; b_kieu_do varchar2(1); b_i2 number;
begin
-- Dan - Xac dinh ty le dong bao hiem con lai hop dong
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_id);
PKH_MANG_KD_N(a_so_id_dt);
if b_kieu_do<>'G' then
    for r_lp in (select so_id_dt,pthuc,lh_nv,nha_bh,nvl(max(pt),0) pt,nvl(min(hh),0) hh from bh_hd_do_tl
        where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_id_dt,pthuc,lh_nv,nha_bh) loop
        if r_lp.pthuc in('C','T') and r_lp.pt<>0 then
            b_i2:=0;
            for b_lp in 1..b_i1 loop
                if a_so_id_dt(b_lp)=r_lp.so_id_dt and a_lh_nv(b_lp)=r_lp.lh_nv then
                    b_i2:=b_lp;
                    a_pt(b_i2):=a_pt(b_i2)+r_lp.pt; a_hh(b_i2):=a_hh(b_i2)+r_lp.hh;
                    exit;
                end if;
            end loop;
            if b_i2=0 then
                b_i1:=b_i1+1;
                a_so_id_dt(b_i1):=r_lp.so_id_dt; a_lh_nv(b_i1):=r_lp.lh_nv; a_pt(b_i1):=r_lp.pt; a_hh(b_i1):=r_lp.hh;
            end if;
        end if;
    end loop;
    if b_kieu_do='V' then
        for b_lp in 1..a_so_id_dt.count loop
            if a_pt(b_lp)<>0 then a_pt(b_lp):=100-a_pt(b_lp); end if;
        end loop;
    end if;
end if;
end;
/
create or replace function FBH_DONG_NBHV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Xac nha BH ve
select nvl(min(nha_bh),' ') into b_kq from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and pthuc='C';
return b_kq;
end;
/
create or replace function FBH_HD_DO_PS_NG(b_ma_dvi varchar2,b_so_id_ps number) return number
AS
    b_kq number;
begin
-- Dan - Ngay phat sinh so lieu dong
select min(ngay_ht) into b_kq from bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function FBH_HD_DO_PS(b_ma_dvi varchar2,b_so_id number,b_so_id_ps number:=0) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
if b_so_id_ps<>0 then
    select count(*) into b_kq from bh_hd_do_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps;
else
    select count(*) into b_kq from bh_hd_do_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_DO_CT(b_ma_dvi varchar2,b_so_id_ps number) return number
AS
    b_kq number;
begin
-- Dan - So da phat sinh xu ly
select count(*) into b_kq from bh_hd_do_ct where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
return b_kq;
end;
/
create or replace function PBH_DO_BH_CN_QD
    (b_ma_dvi varchar2,b_nha_bh varchar2,b_ma_nt varchar2,b_ngay_ht number,b_l_ct varchar2,b_tien number) return number
AS
    b_i1 number; b_ton number:=0; b_ton_qd number; b_noite varchar2(5):='VND'; b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
if b_ma_nt<>b_noite then
    FBH_DO_BH_CN_TON(b_ma_dvi,b_nha_bh,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
    if b_l_ct='T' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
    if b_ton=b_tien then b_tien_qd:=b_ton_qd;
    elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
        if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
        else b_tien_qd:=round(b_tien*b_i1,0);
        end if;
    end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure FBH_DO_BH_CN_TON
    (b_ma_dvi varchar2,b_nha_bh varchar2,b_ma_nt varchar2,b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_do_bh_sc where
    ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
    b_ton:=0; b_ton_qd:=0;
else
    select nvl(ton,0),nvl(ton_qd,0) into b_ton,b_ton_qd from bh_do_bh_sc where
        ma_dvi=b_ma_dvi and nha_bh=b_nha_bh and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace procedure PBH_DO_BH_THL_CN(b_ma_dvi varchar2,b_ngayd number,b_ngayc number)
AS
    b_loi varchar2(100); b_ngay_ht number; b_so_id number; b_nha_bh varchar2(20);
begin
-- Dan - Tong hop lai so cai cong no dong BH
delete bh_do_bh_sc where ma_dvi=b_ma_dvi and ngay_ht>=b_ngayd;
commit;
for r_lp in (select distinct ngay_ht from bh_hd_do_cn where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc) loop
    b_ngay_ht:=r_lp.ngay_ht;
    for r_lp1 in(select so_id_tt,nha_bh from bh_hd_do_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht) loop
        b_so_id:=r_lp1.so_id_tt;
        for r_lp2 in (select ma_nt,tien,tien_qd from bh_hd_do_pp where ma_dvi=b_ma_dvi and so_id_tt=b_so_id and pt='C') loop
            PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,r_lp1.nha_bh,r_lp2.ma_nt,r_lp2.tien,r_lp2.tien_qd,b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
        end loop;
    end loop;
    commit;
end loop;
for r_lp in (select distinct ngay_ht from bh_do_bh_cn where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc) loop
    b_ngay_ht:=r_lp.ngay_ht;
    for r_lp1 in(select l_ct,ngay_ht,nha_bh,ma_nt,tien,tien_qd
        from bh_do_bh_cn where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht) loop
        PBH_DO_BH_CN_THOP(b_ma_dvi,r_lp1.l_ct,b_ngay_ht,r_lp1.nha_bh,r_lp1.ma_nt,r_lp1.tien,r_lp1.tien_qd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end loop;
    commit;
end loop;
for r_lp in (select distinct ngay_ht from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc) loop
    b_ngay_ht:=r_lp.ngay_ht;
    for r_lp1 in (select so_id_tt,ngay_ht from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht) loop
        select min(so_id_tt) into b_so_id from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=r_lp1.so_id_tt;
        b_nha_bh:=FBH_DONG_NBH(b_ma_dvi,b_so_id);
        for r_lp2 in (select ma_nt,tien,tien_qd from bh_bt_tt_ct where ma_dvi=b_ma_dvi and so_id_tt=r_lp1.so_id_tt and pt='B') loop
            PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nha_bh,r_lp2.ma_nt,-r_lp2.tien,-r_lp2.tien_qd,b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
        end loop;
    end loop;
    commit;
end loop;
for r_lp in (select distinct ngay_ht from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc) loop
    b_ngay_ht:=r_lp.ngay_ht;
    for r_lp1 in (select so_id from bh_hd_goc_hu where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht) loop
        b_so_id:=r_lp1.so_id;
        if FBH_HD_KIEU_HD(b_ma_dvi,b_so_id) not in('V','U','K') then
            b_nha_bh:=FBH_DONG_NBH(b_ma_dvi,b_so_id);
            for r_lp2 in (select ma_nt,tien,tien_qd from bh_hd_goc_hutt where ma_dvi=b_ma_dvi and so_id=b_so_id and pt='B') loop
                PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nha_bh,r_lp2.ma_nt,-r_lp2.tien,-r_lp2.tien_qd,b_loi);
                if b_loi is not null then raise PROGRAM_ERROR; end if;
            end loop;
        end if;
    end loop;
    commit;
end loop;
for r_lp in (select distinct ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc) loop
    b_ngay_ht:=r_lp.ngay_ht;
    for r_lp1 in (select so_id_tt,ma_dl from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht) loop
        b_so_id:=r_lp1.so_id_tt;
        for r_lp2 in (select ma_nt,tien,tien_qd from bh_hd_goc_ttct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id and pt='B') loop
            PBH_DO_BH_CN_THOP(b_ma_dvi,'C',b_ngay_ht,r_lp1.ma_dl,r_lp2.ma_nt,r_lp2.tien,r_lp2.tien_qd,b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
        end loop;
    end loop;
    commit;
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DO_VAT_SC_THL(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Tong hop lai so cai VAT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','H');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; commit;
delete bh_hd_do_sc_vat where ma_dvi=b_ma_dvi;
insert into temp_1(n1) select distinct so_id_tt from bh_hd_do_ct where ma_dvi=b_ma_dvi;
--bo tam dvi_tt do bang kh co truong nay
insert into temp_1(n1) select so_id_tt from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and trim(ma_dl) is not null;
for r_lp in (select distinct n1 so_id_tt from temp_1) loop
    PBH_HD_DO_TH_VAT(b_ma_dvi,r_lp.so_id_tt,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_HD_DOTA_LKE(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_bt number:=0;
    b_ma_dvi varchar2(10); b_so_id number; b_so_idB number; b_nv varchar2(10);
    b_ngay_ht number; b_ngay_hl number; b_ma_ta varchar2(20); b_ten nvarchar2(500):=' ';
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tpT number:=0; b_tpP number:=0;
    b_do_tl number; b_doT number; b_doP number; b_ta_tl number; b_ve_tl number; 
    b_taT number; b_taP number; b_veT number; b_veP number;
    b_tien number; b_phi number; b_con_tl number; b_conT number; b_conP number;    
    a_ma_dviX pht_type.a_var; a_so_idX pht_type.a_num;
    a_so_id_dtX pht_type.a_num; a_so_id_dt pht_type.a_num; a_nhom pht_type.a_var;
    r_hd bh_hd_goc%rowtype;
begin
-- Dan - Ty le tai theo lh_nv
delete bh_hd_dota_temp; delete tbh_ghep_nv_temp; commit;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_so_id:=nvl(b_so_id,0);
if b_ma_dvi=' ' or b_so_id=0 then b_loi:='loi:Nhap hop dong,GCN:loi'; raise PROGRAM_ERROR; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
b_loi:='loi:Hop dong da xoa hoac chua duyet:loi';
if b_so_idB=0 then raise PROGRAM_ERROR; end if;
select * into r_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
b_nv:=r_hd.nv;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH',b_nv,'X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_nt_tien:=r_hd.nt_tien; b_nt_phi:=r_hd.nt_phi; b_ngay_ht:=r_hd.ngay_ht; b_ngay_hl:=r_hd.ngay_hl;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
if b_nv in('PHH','PKT','TAU','XE','2B') then
    select distinct so_id_dt,' ' bulk collect into a_so_id_dt,a_nhom
        from bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_idB order by so_id_dt;
elsif b_nv='NG' then
    select count(*) into b_i1 from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_i1>0 then
        select distinct so_id_dt,nhom bulk collect into a_so_id_dt,a_nhom
            from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    else
        --nampb: hd bao khong co danh sach a_so_id_dt(1):=0; a_nhom(1):=' ';
        select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
        if b_i1>0 then
           select distinct so_id_dt,' ' bulk collect into a_so_id_dt,a_nhom
            from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
        else
           a_so_id_dt(1):=0; a_nhom(1):=' ';
        end if;
        
    end if;
else
    b_ten:=FBH_HD_TEN(b_ma_dvi,b_so_idB);
    a_so_id_dt(1):=0; a_nhom(1):=' ';
end if;
for b_lp in 1..a_so_id_dt.count loop
    delete tbh_ghep_nv_temp;
    a_ma_dviX(1):=b_ma_dvi; a_so_idX(1):=b_so_idB; a_so_id_dtX(1):=a_so_id_dt(b_lp);
    PTBH_GHEP_NV(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dviX,a_so_idX,a_so_id_dtX,b_loi,'{"nv":"'||b_nv||'"}');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    select nvl(sum(tien),0),sum(phi),sum(tien_con),sum(do_tien),sum(ta_tien),sum(ve_tien),
        sum(round(pt_con*phi/100,b_tpP)),sum(round(do_tl*phi/100,b_tpP)),
        sum(round(ta_tl*phi/100,b_tpP)),sum(round(ve_tl*phi/100,b_tpP)) into
        b_tien,b_phi,b_conT,b_doT,b_taT,b_veT,b_conP,b_doP,b_taP,b_veP from tbh_ghep_nv_temp0;
    if b_tien=0 then continue; end if;
    b_con_tl:=round(b_conT*100/b_tien,2); b_do_tl:=round(b_doT*100/b_tien,2);
    b_ta_tl:=round(b_taT*100/b_tien,2); b_ve_tl:=round(b_veT*100/b_tien,2);
    if a_so_id_dt(1)<>0 then
        b_ten:=FTBH_GHEP_NH_TEN(b_nv,b_ma_dvi,b_so_idB,a_so_id_dt(b_lp));
    end if;
    insert into bh_hd_dota_temp values(
        a_so_id_dt(b_lp),a_nhom(b_lp),b_ten,' ',b_tien,b_phi,b_con_tl,b_conT,b_conP,
        b_do_tl,b_doT,b_doP,b_ta_tl,b_taT,b_taP,b_ve_tl,b_veT,b_veP,0);
end loop;
select JSON_ARRAYAGG(json_object(
    ten,tien,phi,con_tl,conT,conP,do_tl,doT,doP,ta_tl,taT,taP,ve_tl,veT,veP,so_id_dt)
    order by nhom,ten returning clob) into b_oraOut from bh_hd_dota_temp; 
delete bh_hd_dota_temp; delete tbh_ghep_nv_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_DOTA_CT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; b_nv varchar2(10);
    dt_ve clob; dt_ta clob;
begin
-- Dan - Xem
delete bh_hd_dota_temp_1; delete bh_hd_dota_temp_2; commit;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,so_id_dt,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_so_id_dt,b_nv using b_oraIn;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH',b_nv,'X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_HD_DOTA_CT(b_ma_dvi,b_so_id,b_so_id_dt,b_nv,dt_ve,dt_ta,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('dt_ve' value dt_ve,'dt_ta' value dt_ta returning clob) into b_oraOut from dual;
delete bh_hd_dota_temp_1; delete bh_hd_dota_temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FBH_HD_DOTA_CT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,
    dt_ve out clob,dt_ta out clob,b_loi out varchar2)
AS
    b_i1 number; b_kieu varchar2(10); b_kieu_do varchar2(1); b_pthuc varchar2(1);
    b_ngay_ht number; b_ngay_hl number; b_nhom varchar2(10); b_nbhC varchar2(20); b_so_idD number; b_so_idB number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tpT number:=0; b_tpP number:=0;
    b_tien number; b_phi number; b_pt number; b_tienH number; b_phiH number;
    b_tienG number; b_phiG number; b_ptG number; b_tienX number; b_phiX number; b_tienD number; b_phiD number;
    b_so_id_taB number; b_ng_ht number; b_ng_hl number; b_ng_kt number;
    
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num; a_pthuc pht_type.a_var; 
    bh_ngay_hl pht_type.a_num; bh_lh_nv pht_type.a_var; bh_kieu pht_type.a_var;
    bh_pthuc pht_type.a_var; bh_nbh pht_type.a_var; bh_nbhC pht_type.a_var; 
    bh_pt pht_type.a_num; bh_hh pht_type.a_num; bh_tien pht_type.a_num; bh_phi pht_type.a_num; 
    bh_hhong pht_type.a_num; bh_tl_thue pht_type.a_num; bh_thue pht_type.a_num;
    dk_lh_nv pht_type.a_var; dk_tien pht_type.a_num; dk_phi pht_type.a_num;
    a_so_id_ta pht_type.a_num; a_nbh pht_type.a_var; a_tien pht_type.a_num; a_pt pht_type.a_num;

    dt_ct clob; dt_bh clob;
begin
-- Dan - Xem
delete bh_hd_dota_temp_1; delete bh_hd_dota_temp_2; delete bh_hd_dota_temp_3;
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
if b_so_idB=0 then b_loi:='loi:Hop dong da xoa hoac chua duyet:loi'; return; end if;
select ngay_ht,ngay_hl,nt_tien,nt_phi,so_id_d into b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,b_so_idD
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
if b_ngay_ht<b_ngay_hl then b_ngay_ht:=b_ngay_hl; end if;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_idB; a_so_id_dt(1):=b_so_id_dt; 
PTBH_GHEP_NV_TIEN(b_ngay_ht,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_tienH,b_phiH,b_loi,'{"nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
for b_lp1 in 1..3 loop
    b_nhom:=substr('FDT',b_lp1,1);
    select count(*) into b_i1 from bh_hd_do_nh where ma_dvi=b_ma_dvi and so_id=b_so_idD and nhom=b_nhom;
    if b_i1=1 then
        delete bh_hd_dota_temp_1;
        if b_nhom='F' then b_kieu:='D';
        elsif b_nhom='T' then b_kieu:='V';
        else b_kieu:=FBH_HD_DO_NH_TXT(b_ma_dvi,b_so_idD,b_nhom,'kieu');
        end if;
        select txt into dt_ct from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_idD and nhom=b_nhom and loai='dt_ct';
        select txt into dt_bh from bh_hd_do_nh_txt where ma_dvi=b_ma_dvi and so_id=b_so_idD and nhom=b_nhom and loai='dt_bh';
        dt_ct:=FKH_JS_BONH(dt_ct); dt_bh:=FKH_JS_BONH(dt_bh);
        FBH_HD_DO_NH_PHId(dt_ct,dt_bh,b_nhom,
            b_ma_dvi,b_so_idB,b_so_id_dt,b_nv,b_kieu,b_nt_tien,b_nt_phi,b_tien,b_phi,b_tienX,b_phiX,
            bh_lh_nv,bh_kieu,bh_pthuc,bh_nbh,bh_pt,bh_hh,bh_tien,bh_phi,bh_hhong,bh_tl_thue,bh_thue,b_loi);
        if b_loi is not null then return; end if;
        for b_lp in 1..bh_nbh.count loop
            if bh_kieu(b_lp)='D' then b_nbhC:=bh_nbh(b_lp); exit; end if;
        end loop;
        for b_lp in 1..bh_nbh.count loop
            if b_nhom='D' and b_kieu='V' and bh_kieu(b_lp)<>'D' then
                insert into bh_hd_dota_temp_1 values('D',b_nbhC,' ','D',0,bh_tien(b_lp),bh_phi(b_lp),0,0,0,0);
            else
                insert into bh_hd_dota_temp_1 values('D',bh_nbh(b_lp),' ',bh_kieu(b_lp)
                    ,0,bh_tien(b_lp),bh_phi(b_lp),bh_hh(b_lp),bh_hhong(b_lp),bh_thue(b_lp),0);
            end if;
        end loop;
        insert into bh_hd_dota_temp_2
            (select b_nhom,nbh,b_nbhC,kieu,0,0,sum(tien) tien,sum(phi) phi,max(hh),sum(hhong) hhong,0,sum(thue) thue
            from bh_hd_dota_temp_1 group by kieu,nbh);
        update bh_hd_dota_temp_2 set
            pt=round(tien*100/b_tienH,2),hh=decode(phi,0,0,round(hhong*100/phi,2)),tl_thue=decode(phi,0,0,round(thue*100/phi,2));
        select sum(pt),sum(tien),sum(phi) into b_pt,b_tien,b_phi from bh_hd_dota_temp_2 where pthuc=b_nhom;
        if b_nhom='D' then b_kieu:=b_nhom||b_kieu; else b_kieu:=b_nhom; end if;
        insert into bh_hd_dota_temp_2 values(b_nhom,'..'||b_kieu,' ',' ',b_pt,0,b_tien,b_phi,0,0,0,0);
    end if;
end loop;
--
b_kieu_do:=FBH_DONG(b_ma_dvi,b_so_idD);
select nvl(sum(tien),0),sum(phi) into b_tienG,b_phiG from bh_hd_dota_temp_2 where kieu<>' ' and pthuc='T';
select nvl(sum(tien),0),nvl(sum(phi),0) into b_tienD,b_phiD from bh_hd_dota_temp_2 where kieu<>' ' and pthuc='D';
if b_kieu_do='V' then
    b_tienG:=b_tienG+(b_tienH-b_tienD); b_phiG:=b_phiG+(b_phiH-b_phiD);
end if;
if b_tienG=0 then b_tienG:=b_tienH; b_phiG:=b_phiH; end if;
select nvl(sum(tien),0),sum(phi) into b_tienX,b_phiX from bh_hd_dota_temp_2 where kieu<>' ' and pthuc='F';
b_tienG:=b_tienG-b_tienX; b_phiG:=b_phiG-b_phiX;
if b_kieu_do='D' then
    b_tienG:=b_tienG-b_tienD; b_phiG:=b_phiG-b_phiD;
end if;
if b_tienG<>b_tienH then
    b_pt:=round(b_tienG*100/b_tienH,2);
    insert into bh_hd_dota_temp_2 values(' ','..0',' ',' ',b_pt,0,b_tienG,b_phiG,0,0,0,0);
    select JSON_ARRAYAGG(json_object('nbh' value decode(instr(nbh,'..'),0,'-- '||FBH_DTAC_MA_TEN(nbh),nbh),
        nbhC,kieu,pt,tien,phi,hh,hhong,tl_thue,thue,pthuc,sott)
        order by sott returning clob) into dt_ve from
        (select nbh,nbhC,kieu,pt,tien,phi,hh,hhong,tl_thue,thue,pthuc,row_number() over (order by pthuc,nbhC,kieu) sott
        from bh_hd_dota_temp_2 order by pthuc,nbhC,kieu);
end if;
-- Tam thoi
PBH_HD_NV_DKa(b_nv,b_ma_dvi,b_so_idD,b_so_id_dt,dk_lh_nv,dk_tien,dk_phi,b_loi);
if b_loi is not null then return; end if;
delete bh_hd_dota_temp_1; delete bh_hd_dota_temp_2;
PTBH_TM_SO_ID_TA_DT(b_ma_dvi,b_so_idD,b_so_id_dt,b_ngay_ht,a_so_id_ta);
for b_lp_ta in 1..a_so_id_ta.count loop
    b_so_id_taB:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp_ta),b_ngay_ht);
    FTBH_TM_NGAYf(b_so_id_taB,b_ng_ht,b_ng_hl,b_ng_kt);
    delete bh_hd_dota_temp_3;
    for r_lp in(select * from bh_hd_nv_temp) loop
        insert into bh_hd_dota_temp_3
            select nha_bh,nha_bhC,kieu,tien,phi,hhong,thue 
            from tbh_tm_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi and
            so_id_hd=b_so_idD and so_id_dt in (0,b_so_id_dt) and lh_nv in(' ',r_lp.lh_nv) and tien>0;
    end loop;
    insert into bh_hd_dota_temp_2
        select 'C',nbh,nbhC,kieu,0,0,sum(tien),sum(phi),0,
            sum(hhong),0,sum(thue) from bh_hd_dota_temp_3 group by nbh,nbhC,kieu;
end loop;
-- co dinh
delete bh_hd_dota_temp_1;
PTBH_GHEP_SO_ID_TA_DT(b_ma_dvi,b_so_idD,b_so_id_dt,a_so_id_ta,b_ngay_ht);
for b_lp_ta in 1..a_so_id_ta.count loop
    b_so_id_taB:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp_ta),b_ngay_ht);
    FTBH_GHEP_NGAYf(b_so_id_taB,b_ng_ht,b_ng_hl,b_ng_kt);
    insert into bh_hd_dota_temp_2
        select pthuc,nha_bh,nha_bhC,kieu,0,0,sum(tien),sum(phi),0,sum(hhong),0,sum(thue) from
        (select pthuc,nha_bh,nha_bhC,kieu,lh_nv,decode(ngay_hl,b_ng_ht,tien,0) tien,phi,hhong,thue
        from tbh_ghep_pbo where so_id=b_so_id_taB and ngay_hl=b_ng_ht and ma_dvi_hd=b_ma_dvi and
        so_id_hd=b_so_idD and so_id_dt in (0,b_so_id_dt) and lh_nv in(' ',lh_nv) and tien>0)
        group by pthuc,kieu,nha_bh,nha_bhC;
end loop;
update bh_hd_dota_temp_2 set
    hh=decode(phi,0,0,round(hhong*100/phi,2)),tl_thue=decode(phi,0,0,round(thue*100/phi,2));
for b_lp1 in 1..3 loop
    b_pthuc:=substr('CQS',b_lp1,1);
    select sum(tien),sum(phi) into b_tien,b_phi from bh_hd_dota_temp_2 where pthuc=b_pthuc;
    insert into bh_hd_dota_temp_2 values(b_pthuc,'..'||b_pthuc,' ',' ',0,0,b_tien,b_phi,0,0,0,0);
end loop;
--
select nvl(sum(tien),0),sum(phi) into b_tien,b_phi from bh_hd_dota_temp_2 where substr(nbh,1,2)<>'..';
if b_tien<>0 then
    b_tien:=b_tienG-b_tien; b_phi:=b_phiG-b_phi;
    insert into bh_hd_dota_temp_2 values(' ','..0',' ',' ',0,0,b_tien,b_phi,0,0,0,0);
    update bh_hd_dota_temp_2 set pt=round(tien*100/b_tienH,4),ptG=round(tien*100/b_tienG,4);
    select JSON_ARRAYAGG(json_object('nbh' value decode(instr(nbh,'..'),0,'-- '||FBH_DTAC_MA_TEN(nbh),nbh),
        kieu,ptG,pt,tien,phi,hh,hhong,tl_thue,thue,pthuc,sott)
        order by sott returning clob) into dt_ta from
        (select nbh,kieu,ptG,pt,tien,phi,hh,hhong,tl_thue,thue,pthuc,row_number() over (order by pthuc,nbhC,kieu) sott
        from bh_hd_dota_temp_2 order by pthuc,nbhC,kieu);
end if;
delete bh_hd_dota_temp_1; delete bh_hd_dota_temp_2; delete bh_hd_dota_temp_3;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HD_DOTA_CT:loi'; end if;
end;
/
