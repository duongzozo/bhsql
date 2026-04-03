CREATE OR REPLACE function FKT_DB_PS_TK_DU
    (b_ma_dvi varchar2,b_ngayd number,b_ngayc number,
    b_ma_tk_no varchar2:=' ',b_ma_tke_no varchar2:=' ',b_ma_tk_co varchar2:=' ',b_ma_tke_co varchar2:=' ') return number
AS
    b_n1 number:=0;
    b_ma_tk_no_like varchar2(21); b_ma_tke_no_like varchar2(11);
    b_ma_tk_co_like varchar2(21); b_ma_tke_co_like varchar2(11);
begin
b_ma_tk_no_like:=trim(b_ma_tk_no||'%'); b_ma_tke_no_like:=trim(b_ma_tke_no||'%');
b_ma_tk_co_like:=trim(b_ma_tk_co||'%'); b_ma_tke_co_like:=trim(b_ma_tke_co||'%');
if trim(b_ma_dvi) is not null then
    if b_ma_tk_no_like='%' and b_ma_tke_no_like='%' then
        select nvl(sum(tien),0) into b_n1 from kt_3 
            where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc 
            and ma_tk_co like b_ma_tk_co_like and ma_tke_co like b_ma_tke_co_like;
    elsif b_ma_tk_co_like='%' and b_ma_tke_co_like='%' then
        select nvl(sum(tien),0) into b_n1 from kt_3 
            where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc 
            and ma_tk_no like b_ma_tk_no_like and ma_tke_no like b_ma_tke_no_like; 
    else
        select nvl(sum(tien),0) into b_n1 from kt_3 
            where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc 
            and ma_tk_no like b_ma_tk_no_like and ma_tke_no like b_ma_tke_no_like 
            and ma_tk_co like b_ma_tk_co_like and ma_tke_co like b_ma_tke_co_like;
    end if;        
else
    if b_ma_tk_no_like='%' and b_ma_tke_no_like='%' then
        select nvl(sum(tien),0) into b_n1 from kt_3 
            where ngay_ht between b_ngayd and b_ngayc 
            and ma_tk_co like b_ma_tk_co_like and ma_tke_co like b_ma_tke_co_like;
    elsif b_ma_tk_co_like='%' and b_ma_tke_co_like='%' then
        select nvl(sum(tien),0) into b_n1 from kt_3 
            where ngay_ht between b_ngayd and b_ngayc 
            and ma_tk_no like b_ma_tk_no_like and ma_tke_no like b_ma_tke_no_like; 
    else
        select nvl(sum(tien),0) into b_n1 from kt_3 
            where ngay_ht between b_ngayd and b_ngayc 
            and ma_tk_no like b_ma_tk_no_like and ma_tke_no like b_ma_tke_no_like 
            and ma_tk_co like b_ma_tk_co_like and ma_tke_co like b_ma_tke_co_like;
    end if;        
end if;
return b_n1;
end;
/
CREATE OR REPLACE PROCEDURE THANG2D_PBC_LAY_NV
 (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_phong varchar2)
AS
    b_i1 number;b_i2 number;
begin
    delete temp_bc_nv;
    insert into temp_bc_nv(nv) select nv from ht_ma_nsd_nv 
        where ma_dvi=b_ma_dvi and ma=b_nsd and (instr(tc,'X')>0 or instr(tc,'N')>0) and md='BH';            
    select count(*) into b_i1 from temp_bc_nv where nv ='XE';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('XEL');
        insert into temp_bc_nv(nv) values('XG');
    end if;
    select count(*) into b_i1 from temp_bc_nv where nv ='2B';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('2BL');
        insert into temp_bc_nv(nv) values('XG');
    end if;
    select count(*) into b_i1 from temp_bc_nv where nv ='TAU';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('TAUL');
        insert into temp_bc_nv(nv) values('TT');
        insert into temp_bc_nv(nv) values('CN.6');
        insert into temp_bc_nv(nv) values('HK');
        insert into temp_bc_nv(nv) values('NL');
    end if;
    
    select count(*) into b_i1 from temp_bc_nv where nv ='NG';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('CN');
    end if;
    
    select count(*) into b_i1 from temp_bc_nv where nv ='PHH';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('TS');
        insert into temp_bc_nv(nv) values('HP');
    end if;
    
    select count(*) into b_i1 from temp_bc_nv where nv ='PKT';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('KT');
    end if;
    select count(*) into b_i1 from temp_bc_nv where nv ='PTN';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('TN');
    end if;
    
    select count(*) into b_i1 from temp_bc_nv where nv ='HANG';
    if b_i1>0 then
        insert into temp_bc_nv(nv) values('HH');
    end if;
    commit;
end;
/
CREATE OR REPLACE procedure PBH_HD_NGHLUC_DT
    (b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_hl out date,b_ngay_kt out date)
AS
    b_nv varchar2(10); b_bang varchar2(50); b_lenh varchar2(200);
begin
-- Dan - Tra ngay hieu luc doi tuong qua so ID hop dong, so ID doi tuong
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
if b_nv='PHH' then
    FBH_PHH_DT_NGd(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_hl,b_ngay_kt);
elsif b_nv='SK' then
    select PKH_SO_CDT(min(ngay_hl)),PKH_SO_CDT(min(ngay_kt)) into b_ngay_hl,b_ngay_kt from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv not in ('2B','XE','TAU','BAY','NG') then
    select PKH_SO_CDT(min(ngay_hl)),PKH_SO_CDT(min(ngay_kt)) into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    b_bang:=FBH_HD_GOC_BANG_CT(b_nv);
    b_lenh:='select min(ngay_hl),min(ngay_kt) from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id and so_id_dt= :so_id_dt'; 
    EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_kt using b_ma_dvi,b_so_id,b_so_id_dt;
end if;
end;
/
CREATE OR REPLACE function FBH_PHHL_MADT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
--- Hung: bang bh_phhl khong co cot ma_dt
/*
select min(ma_dt) into b_kq from bh_phhl where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
*/
return '';
end;
/
CREATE OR REPLACE PROCEDURE PBC_HOI_QPM
 (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_phong_nsd out varchar2,b_quyen out varchar2)

AS
 b_loi varchar2(100);
begin
-- Hoi phong cua nsd,quyen cua nguoi su dung
b_phong_nsd:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if PBC_HOI_QU(b_ma_dvi,b_nsd,b_pas)='C' then
	b_quyen:=4;
else
	b_quyen:=0;
end if;
exception when others then raise_application_error(-20105,b_loi);
end;
/
