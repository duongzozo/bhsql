create or replace procedure PBH_BT_NG_KBT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ktraHL varchar2,dt_ct clob,dt_dk clob,dt_kbt clob,b_loi out varchar2)
as
    b_lenh varchar2(2000); b_i1 number; b_v number; b_s varchar2(200); b_c varchar2(2000);
    b_tien_bh number; b_lke number; b_t_that number; b_tien number; b_ktraHLi number:=0;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_tien_bh pht_type.a_num; dk_lke pht_type.a_num;
    dk_t_that pht_type.a_num; dk_bth pht_type.a_var; dk_luy pht_type.a_var; dk_tc pht_type.a_var;
    dkL_ma pht_type.a_var; dkL_tien pht_type.a_num;
    kbt_ma pht_type.a_var; kbt_kbt pht_type.a_var;
    kma_ma pht_type.a_var; kma_nd pht_type.a_var;
begin
-- Dan - Kiem soat dieu kien rieng
b_lenh:=FKH_JS_LENH('ma,lh_nv,tien_bh,t_that,tien,luy,tc');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_lh_nv,dk_tien_bh,dk_t_that,dk_bth,dk_luy,dk_tc using dt_dk;
b_lenh:=FKH_JS_LENH('ma,kbt');
EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_kbt using dt_kbt;
select ma,sum(tien) bt_lke bulk collect into dkL_ma,dkL_tien from bh_bt_ng_dk
    where (ma_dvi,so_id) in (select ma_dvi,so_id from bh_bt_ng where so_id_dt=b_so_id_dt and ttrang='D') group by ma;
for b_lp in 1..dk_ma.count loop
    dk_lke(b_lp):=0;
    b_v:=FKH_ARR_VTRI(dkL_ma,dk_ma(b_lp));
    if b_v<>0 then dk_lke(b_lp):=dkL_tien(b_v); end if;
end loop;
for b_lp in 1..dk_ma.count loop
    if dk_bth(b_lp)=0 or dk_tc(b_lp)='T' then
        b_ktraHLi:=b_ktraHLi+1;
    end if;
    if dk_bth(b_lp)<>0 then
        if dk_tien_bh(b_lp)<>0 then
            if nvl(trim(dk_luy(b_lp)),'C')='K' then b_i1:=dk_bth(b_lp); else b_i1:=dk_lke(b_lp)+dk_bth(b_lp); end if;
            if b_i1>dk_tien_bh(b_lp) then b_loi:='loi:Dieu khoan '||dk_ma(b_lp)||' boi thuong vuot muc trach nhiem:loi'; return; end if;
        end if;
        b_v:=FKH_ARR_VTRI(kbt_ma,dk_ma(b_lp));
        if b_v<>0 then
            b_c:=trim(kbt_kbt(b_v));
            if b_c is not null then
                b_lenh:=FKH_JS_LENH('ma,nd');
                EXECUTE IMMEDIATE b_lenh bulk collect into kma_ma,kma_nd using b_c;
                for b_lp1 in 1..kma_ma.count loop
                    if kma_ma(b_lp1) in('MVU','GVU','KVU') then
                        b_loi:=FBH_BT_KBT(kma_ma(b_lp1),dk_tien_bh(b_lp),dk_t_that(b_lp),dk_bth(b_lp),kma_nd(b_lp1));
                    else
                        b_s:='PBH_BT_NG_KBT_'||kma_ma(b_lp1);
                        select count(*) into b_i1 from USER_PROCEDURES where OBJECT_NAME=b_s;
                        if b_i1=0 then b_loi:='loi:Chua tao ham '||b_s||':loi'; return; end if;
                        b_lenh:='begin '||b_s||'(:ma_dvi,:so_id,:so_id_dt,:ktraHL,:tien,:lke,:ycau,:bth,:nd,:dt_ct,:loi); end;';
                        execute immediate b_lenh using b_ma_dvi,b_so_id,b_so_id_dt,b_ktraHL,dk_tien_bh(b_lp),
                            dk_lke(b_lp),dk_t_that(b_lp),dk_bth(b_lp),kma_nd(b_lp1),dt_ct,out b_loi;
                    end if;
					if b_loi is not null then b_loi:='loi:Khoan '||dk_ma(b_lp)||': '||b_loi||':loi'; return; end if;
                    if upper(kma_ma(b_lp1))='TGH' and dk_tc(b_lp)<>'T' then b_ktraHLi:=b_ktraHLi+1; end if;
                end loop;
            end if;
        end if;
    end if;
end loop;
if b_ktraHL='C' and b_ktraHLi<>dk_ma.count then
    b_loi:='loi:Ngay xay ra ngoai hieu luc hop dong:loi'; return;
end if;
b_v:=FKH_ARR_VTRI(kbt_ma,'--');
if b_v<>0 then
    b_c:=trim(kbt_kbt(b_v));
    if b_c is not null then
        b_lenh:=FKH_JS_LENH('ma,nd');
        EXECUTE IMMEDIATE b_lenh bulk collect into kma_ma,kma_nd using b_c;
        b_tien_bh:=0; b_lke:=0; b_t_that:=0; b_tien:=0;
        for b_lp in 1..dk_ma.count loop
            if trim(dk_lh_nv(b_lp)) is not null then
                b_tien_bh:=b_tien+dk_tien_bh(b_lp); b_lke:=b_lke+dk_lke(b_lp);
                b_t_that:=b_tien+dk_t_that(b_lp); b_tien:=b_tien+dk_bth(b_lp);
            end if;
        end loop;
        if b_tien>0 then
            for b_lp1 in 1..kma_ma.count loop
                if kma_ma(b_lp1) in('MVU','GVU','KVU') then
                    b_loi:=FBH_BT_KBT(kma_ma(b_lp1),b_tien_bh,b_t_that,b_tien,kma_nd(b_lp1));
                else
                    b_s:='PBH_BT_NG_KBT_'||kma_ma(b_lp1);
                    select count(*) into b_i1 from USER_PROCEDURES where OBJECT_NAME=b_s;
                    if b_i1=0 then b_loi:='loi:Chua tao ham '||b_s||':loi'; return; end if;
                    b_lenh:='begin '||b_s||'(:ma_dvi,:so_id,:so_id_dt,:ktraHL,:nd,:dt_ct,:loi); end;';
                    execute immediate b_lenh using b_ma_dvi,b_so_id,b_so_id_dt,b_ktraHL,b_tien_bh,
                        b_lke,b_t_that,b_tien,kma_nd(b_lp1),dt_ct,out b_loi;
                end if;
                if b_loi is not null then b_loi:='loi:'||b_loi||':loi'; return; end if;
            end loop;
        end if;
    end if; 
end if;
b_loi:='';
end;
/
create or replace procedure PBH_BT_NG_KBT_GLU(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ktraHL varchar2,
    b_tien_bh number,b_lke number,b_t_that number,b_tien number,b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
    b_luong number:=FKH_JS_GTRIn(dt_ct,'luong'); b_ndN number:=PKH_LOC_CHU_SO(b_nd,'F');
begin
-- Dan - Boi thuong theo Luong
if b_ndN=0 then b_loi:=''; return; end if;
b_loi:='Gioi han '||b_nd||' lan muc luong';
if round(b_luong*b_ndN,0)>=b_lke+b_tien then b_loi:=''; end if;
exception when others then null;
end;
/
create or replace procedure PBH_BT_NG_KBT_TGC(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ktraHL varchar2,
    b_tien_bh number,b_lke number,b_t_that number,b_tien number,b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
    b_ngay_xr number:=FKH_JS_GTRIn(dt_ct,'ngay_xr'); b_cho number:=PKH_LOC_CHU_SO(b_nd,'F');
    b_ngay_hl number; b_kieu_hd varchar2(1); b_so_hdG varchar2(20);
    b_so_idG number:=b_so_id; b_so_idD number; b_so_idB number; b_ngay_xrD date;
begin
-- Dan - Thoi gian cho
if b_cho=0 then b_loi:=''; return; end if;
b_loi:='Thoi gian cho '||b_nd; b_ngay_xrD:=PKH_SO_CDT(b_ngay_xr);
loop
    b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_idG,b_ngay_xr);
    select nvl(min(ngay_hl),0) into b_ngay_hl from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    if b_ngay_hl=0 then exit; end if;
    if PKH_SO_CDT(b_ngay_hl)+b_cho<=b_ngay_xrD then b_loi:=''; end if;
    b_so_idD:=FBH_NG_SO_IDd(b_ma_dvi,b_so_idG);
    select kieu_hd,so_hd_g into b_kieu_hd,b_so_hdG from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if b_kieu_hd<>'T' or b_so_hdG=' ' then
        b_so_idG:=0;
    else
        b_so_idG:=FBH_NG_SO_ID(b_ma_dvi,b_so_hdG);
    end if;
    if b_so_idG=0 then exit; end if;
end loop;
exception when others then null;
end;
/
create or replace procedure PBH_BT_NG_KBT_TGH(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ktraHL varchar2,
    b_tien_bh number,b_lke number,b_t_that number,b_tien number,b_nd varchar2,dt_ct clob,b_loi out varchar2)
as
    b_ngay_xr number:=FKH_JS_GTRIn(dt_ct,'ngay_xr'); b_ngay_gr number:=FKH_JS_GTRIn(dt_ct,'ngay_gr');
    b_choT number; b_choS number:=0;
    b_so_idB number; b_kieu_hd varchar2(1); b_ngay_xrD date; b_ngay_grD date;
    b_ngay_hl number; b_ngay_kt number; b_ngay_hlD date; b_ngay_ktD date;
    a_cho pht_type.a_var;
begin
-- Dan - Thoi gian hoi to
if b_ktraHL='K' then b_loi:='';
else
    PKH_CH_ARR(b_nd,a_cho,'|');
    b_choT:=PKH_LOC_CHU_SO(a_cho(1),'F');
    if a_cho.count>1 then b_choS:=PKH_LOC_CHU_SO(a_cho(2),'F'); end if;
    if b_choT=0 and b_choS=0 then b_loi:='loi:Ngay xay ra ngoai hieu luc hop dong:loi';
    else
        b_loi:='Thoi gian hoi to ';
        if b_ngay_gr in(0,30000101) then b_ngay_gr:=b_ngay_xr; end if;
        b_ngay_xrD:=PKH_SO_CDT(b_ngay_xr); b_ngay_grD:=PKH_SO_CDT(b_ngay_gr);
        b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay_xr);        
        select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_ng_ds
            where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
        b_ngay_hlD:=b_ngay_xrD-b_choT; b_ngay_ktD:=b_ngay_grD+b_choS;
        --nam: kiem soat ngay hoi to
        if b_choT<>0 and b_ngay_gr<b_ngay_hl and ((b_ngay_xr not between b_ngay_hl and b_ngay_kt) or (b_ngay_grD not between b_ngay_hlD and PKH_SO_CDT(b_ngay_kt))) then
          b_loi:=b_loi||' truoc hieu luc '||to_char(b_choT)||' ngay'; raise PROGRAM_ERROR;
        elsif b_choS<>0 and b_ngay_xr>b_ngay_kt and ((b_ngay_gr not between b_ngay_hl and b_ngay_kt) or (b_ngay_xrD not between PKH_SO_CDT(b_ngay_hl) and b_ngay_ktD)) then 
          b_loi:=b_loi||' sau hieu luc '||to_char(b_choS)||' ngay'; raise PROGRAM_ERROR;
        else 
          b_loi:='';
        end if;
    end if;
end if;
exception when others then null;
end;
/
