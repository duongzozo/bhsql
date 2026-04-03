create or replace PROCEDURE PBH_BT_GD_SMS_TON(cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
open cs1 for select distinct ma_dvi,so_id from bh_bt_hs_sms where tt='C' and ttN<>'K' order by so_id;
end;
/
create or replace PROCEDURE PBH_BT_GD_SMS_GUI
    (b_ma_dvi varchar2,b_so_id number,b_bt number)
AS
    b_i1 number;
begin
-- Dan - Da gui
select lan into b_i1 from bh_bt_hs_sms where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
b_i1:=b_i1+1;
if b_i1<2 then
    update bh_bt_hs_sms set lan=lan+1,ngB=sysdate where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
else
    update bh_bt_hs_sms set lan=lan+1,ngB=sysdate,tt='K' where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
end if;
commit;
end;
/
