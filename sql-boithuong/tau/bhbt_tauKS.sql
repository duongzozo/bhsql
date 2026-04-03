create or replace procedure PBH_BT_TAU_KBT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,dt_ct clob,dt_dk clob,dt_kbt clob,b_loi out varchar2)
as
    b_lenh varchar2(2000); b_i1 number; b_v number; b_s varchar2(200); b_c varchar2(2000);
    b_tien_bh number; b_lke number; b_t_that number; b_tien number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var;
    dk_tien_bh pht_type.a_num; dk_lke pht_type.a_num; dk_t_that pht_type.a_num; dk_bth pht_type.a_num; 
    dk_luy pht_type.a_var; dk_lkeB pht_type.a_var;
    dkL_ma pht_type.a_var; dkL_tien pht_type.a_num;
    kbt_ma pht_type.a_var; kbt_kbt pht_type.a_var;
    kma_ma pht_type.a_var; kma_nd pht_type.a_var;
begin
-- Dan - Kiem soat dieu kien rieng
b_lenh:=FKH_JS_LENH('ma,lh_nv,tien_bh,t_that,tien,luy,lkeB');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_lh_nv,dk_tien_bh,dk_t_that,dk_bth,dk_luy,dk_lkeB using dt_dk;
b_lenh:=FKH_JS_LENH('ma,kbt');
EXECUTE IMMEDIATE b_lenh bulk collect into kbt_ma,kbt_kbt using dt_kbt;
select ma,sum(tien) bt_lke bulk collect into dkL_ma,dkL_tien from bh_bt_tau_dk
    where (ma_dvi,so_id) in (select ma_dvi,so_id from bh_bt_tau where so_id_dt=b_so_id_dt and ttrang='D') group by ma;
for b_lp in 1..dk_ma.count loop
    dk_lke(b_lp):=0;
    b_v:=FKH_ARR_VTRI(dkL_ma,dk_ma(b_lp));
    if b_v<>0 then dk_lke(b_lp):=dkL_tien(b_v); end if;
end loop;
for b_lp in 1..dk_ma.count loop
  if dk_bth(b_lp)>0 then
    if dk_tien_bh(b_lp)<>0 then
        if nvl(trim(dk_luy(b_lp)),'C')='K' then b_i1:=dk_bth(b_lp); else b_i1:=dk_lke(b_lp)+dk_bth(b_lp); end if;
        if b_i1>dk_tien_bh(b_lp) and dk_lkeB(b_lp)<>'M' then b_loi:='loi:Dieu khoan '||dk_ma(b_lp)||' boi thuong vuot muc trach nhiem:loi'; return; end if;
    end if;
    b_v:=FKH_ARR_VTRI(kbt_ma,dk_ma(b_lp));
    if b_v<>0 then
        b_c:=trim(kbt_kbt(b_v));
        if b_c is not null then
            b_lenh:=FKH_JS_LENH('ma,nd');
            EXECUTE IMMEDIATE b_lenh bulk collect into kma_ma,kma_nd using b_c;
            for b_lp1 in 1..kma_ma.count loop
              --nam
              if kma_ma(b_lp1)='KVU' then b_loi:=''; return; end if;
                if kma_ma(b_lp1) in('MVU','GVU','KVU') then
                    b_loi:=FBH_BT_KBT(kma_ma(b_lp1),dk_tien_bh(b_lp),dk_t_that(b_lp),dk_bth(b_lp),kma_nd(b_lp1));
                else
                    b_s:='PBH_BT_TAU_KBT_'||kma_ma(b_lp1);
                    select count(*) into b_i1 from USER_PROCEDURES where OBJECT_NAME=b_s;
                    if b_i1=0 then b_loi:='loi:Chua tao ham '||b_s||':loi'; return; end if;
                    b_lenh:='begin '||b_s||'(:ma_dvi,:so_id,:so_id_dt,:tien_bh,:lke,:t_that,:bth,:nd,:dt_ct,:loi); end;';
                    execute immediate b_lenh using
                        b_ma_dvi,b_so_id,b_so_id_dt,dk_tien_bh(b_lp),dk_lke(b_lp),dk_t_that(b_lp),dk_bth(b_lp),kma_nd(b_lp1),dt_ct,out b_loi;
                    if b_loi is not null then b_loi:='Dieu khoan '||dk_ma(b_lp)||':'||b_loi; end if;
                end if;
                if b_loi is not null then b_loi:='loi:'||b_loi||':loi'; return; end if;
            end loop;
        end if;
    end if;
  end if;
end loop;
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
        for b_lp1 in 1..kma_ma.count loop
            if kma_ma(b_lp1) in('MVU','GVU','KVU') then
				b_loi:=FBH_BT_KBT(kma_ma(b_lp1),b_tien_bh,b_t_that,b_tien,kma_nd(b_lp1));
            else
                b_s:='PBH_BT_TAU_KBT_'||kma_ma(b_lp1);
                select count(*) into b_i1 from USER_PROCEDURES where OBJECT_NAME=b_s;
                if b_i1=0 then b_loi:='loi:Chua tao ham '||b_s||':loi'; return; end if;
                b_lenh:='begin '||b_s||'(:ma_dvi,:so_id,:so_id_dt,:nd,:dt_ct,:loi); end;';
                execute immediate b_lenh using b_ma_dvi,b_so_id,b_so_id_dt,b_tien_bh,b_lke,b_t_that,b_tien,kma_nd(b_lp1),dt_ct,out b_loi;
            end if;
            if b_loi is not null then b_loi:='loi:'||b_loi||':loi'; return; end if;
        end loop;
    end if; 
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
