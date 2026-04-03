create or replace function FBH_BT_KBTm(b_tien_bh number,b_t_that number,b_nd varchar2,b_kho number,b_dk varchar2:='L') return number
as
    b_n number:=0; b_n1 number; b_tien number; a_s pht_type.a_var;
begin
-- Dan - Muc ksoat
if trim(b_nd) is null then return 0; end if;
PKH_CH_ARR(upper(b_nd),a_s,'|');
for b_lp in 1..a_s.count loop
    b_n1:=PKH_LOC_CHU_SO(a_s(b_lp),'F');
    if b_n1<=100 then
        if instr(a_s(b_lp),'MTN')<>0 then b_tien:=b_tien_bh; else b_tien:=b_t_that; end if;
        b_n1:=round(b_tien*b_n1/100,0);
    elsif instr(a_s(b_lp),'NG')<>0 and b_kho<>0 then
        b_n1:=round(b_n1*b_tien_bh/b_kho,0);
    end if;
    if (b_dk='L' and b_n1>b_n) or (b_dk='N' and b_n1<>0 and (b_n=0 or b_n1<b_n)) then b_n:=b_n1; end if;
end loop;
return b_n;
end;
/

create or replace function FBH_BT_KBT(
    b_ktra varchar2,b_tien_bh number,b_t_that number,b_bth number,b_nd varchar2,b_kho number:=0) return varchar2
as
    b_loi varchar2(500):=''; b_n number:=0; b_dk varchar2(1):='L';
begin
-- Dan - Muc khau tru/vu tren muc trach nhiem
if b_ktra='GVU' then b_dk:='N'; end if;
b_n:=FBH_BT_KBTm(b_tien_bh,b_t_that,b_nd,b_kho,b_dk);
if b_ktra='MVU' and b_n>=b_bth then b_loi:='Mien thuong '||b_nd||' tren vu'; end if;
if b_ktra='GVU' and b_bth>b_n then b_loi:='Gioi han '||b_nd||' tren vu'; end if;
if b_ktra='KVU' and b_bth+b_n>b_t_that then b_loi:='Khau tru '||b_nd||' tren vu';
end if;
return b_loi;
exception when others then return null;
end;
/
