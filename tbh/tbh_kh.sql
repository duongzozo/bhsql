create or replace function FTBH_PS_SO_ID_HD(b_goc varchar2,b_ma_dvi_ps varchar2,b_so_id_ps number,b_bt_ps number) return number
as
    b_so_id number:=0; b_i1 number:=0;
begin
-- Dan - Tra so ID hop dong goc
if b_goc='HD_TT' then
    select nvl(min(so_id),0) into b_so_id from bh_hd_goc_tthd where ma_dvi=b_ma_dvi_ps and so_id_tt=b_so_id_ps and bt=b_bt_ps;
elsif b_goc='HD_HU' then
    b_so_id:=FBH_HD_SO_ID_DAU(b_ma_dvi_ps,b_so_id_ps);
elsif b_goc='BT_HS' then
    b_so_id:=PBH_BT_HS_HD_SO_ID(b_ma_dvi_ps,b_so_id_ps);
elsif b_goc='BT_TU' then
    select nvl(min(so_id_hs),0) into b_i1 from bh_bt_tu where ma_dvi=b_ma_dvi_ps and so_id=b_so_id_ps;
    if b_i1<>0 then b_so_id:=PBH_BT_HS_HD_SO_ID(b_ma_dvi_ps,b_i1); end if;
elsif b_goc='BT_GD' then
    select nvl(min(so_id_hd),0) into b_so_id from bh_bt_gd_hs where ma_dvi=b_ma_dvi_ps and so_id=b_so_id_ps;
elsif b_goc='BT_TB' then
    select nvl(min(so_id_hs),0) into b_i1 from bh_bt_ntba_tt where ma_dvi=b_ma_dvi_ps and so_id=b_so_id_ps;
    if b_i1<>0 then b_so_id:=PBH_BT_HS_HD_SO_ID(b_ma_dvi_ps,b_i1); end if;
end if;
return b_so_id;
end;
/
create or replace procedure PTBH_SO_HD
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_hd varchar2,b_so_id out number)
AS
    b_loi varchar2(100);
begin
-- Dan - So Id hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TKH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(so_id),0) into b_so_id from bh_hd_goc where ma_dvi=b_dvi and so_hd=b_so_hd;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_SO_HS
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_hs varchar2,b_so_id out number)
AS
    b_loi varchar2(100);
begin
-- Dan - So Id hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TKH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(so_id),0) into b_so_id from bh_bt_hs where ma_dvi=b_dvi and so_hs=b_so_hs;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_HD_PT(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_thue number,b_thue_qd number,
    a_so_id_dt out pht_type.a_num,a_lh_nv out pht_type.a_var,a_tien out pht_type.a_num,
    a_tien_qd out pht_type.a_num,a_thue out pht_type.a_num,a_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_tg number; b_tp number; b_noite varchar2(5); b_tien_t number; b_bt number;
    b_so_id_ps number; b_so_id_d number; b_kieu_hd varchar2(1);
    b_tien_c number; b_tien_c_qd number; b_thue_c number; b_thue_c_qd number; a_tl pht_type.a_num;
Begin
-- Dan - Phan tich theo hop dong
b_loi:='loi:Hop dong da xoa:loi';
b_so_id_ps:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
b_kieu_hd:=FBH_HD_KIEU_HD(b_ma_dvi,b_so_id_d);
PBH_HD_DS_NV_BANG(b_ma_dvi,b_so_id_ps,0,b_loi);
if b_loi is not null then return; end if;
b_noite:=FTT_TRA_NOITE(b_ma_dvi); b_bt:=0; b_tien_t:=0;
if b_kieu_hd in('V','N') then
    for r_lp in (select so_id_dt,lh_nv,sum(tien_vnd) tien from bh_hd_nv_temp
        group by so_id_dt,lh_nv having sum(tien_vnd)<>0) loop
        if FTBH_VE_TL_DT(b_ma_dvi,b_so_id_d,r_lp.so_id_dt,r_lp.lh_nv)<>0 then
            b_bt:=b_bt+1;
            a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_tl(b_bt):=r_lp.tien;
            b_tien_t:=b_tien_t+a_tl(b_bt);
        end if;
    end loop;
else
    for r_lp in (select so_id_dt,lh_nv,sum(tien_vnd) tien from bh_hd_nv_temp
        group by so_id_dt,lh_nv having sum(tien_vnd)<>0) loop
        if FTBH_GHEP_TL_DT(b_ma_dvi,b_so_id_d,r_lp.so_id_dt,r_lp.lh_nv,b_ngay_ht,b_ngay_ht)<>0
            or FTBH_TM_TL_DT(b_ma_dvi,b_so_id_d,r_lp.so_id_dt,r_lp.lh_nv,b_ngay_ht,b_ngay_ht)<>0 then
            b_bt:=b_bt+1;
            a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv; a_tl(b_bt):=r_lp.tien;
            b_tien_t:=b_tien_t+a_tl(b_bt);
        end if;
    end loop;
end if;
if b_ma_nt<>b_noite then b_tp:=2; else b_tp:=0; end if;
b_tien_c:=b_tien; b_tien_c_qd:=b_tien_qd; b_thue_c:=b_thue; b_thue_c_qd:=b_thue_qd;
for b_lp in 1..a_so_id_dt.count loop
    if b_lp<a_so_id_dt.count then
        b_tg:=a_tl(b_lp)/b_tien_t;
        a_tien(b_lp):=round(b_tien*b_tg,b_tp); a_tien_qd(b_lp):=round(b_tien_qd*b_tg,0);
        b_tien_c:=b_tien_c-a_tien(b_lp); b_tien_c_qd:=b_tien_c_qd-a_tien_qd(b_lp);
        a_thue(b_lp):=round(b_thue*b_tg,b_tp); a_thue_qd(b_lp):=round(b_thue_qd*b_tg,0);
        b_thue_c:=b_thue_c-a_thue(b_lp); b_thue_c_qd:=b_thue_c_qd-a_thue_qd(b_lp);
    else
        a_tien(b_lp):=b_tien_c; a_tien_qd(b_lp):=b_tien_c_qd;
        a_thue(b_lp):=b_thue_c; a_thue_qd(b_lp):=b_thue_c_qd;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
