create or replace procedure PBH_KT_DTHU(b_ngayD number,b_ngayC number)
AS
    a_ma_dvi pht_type.a_var;
begin
-- Dan - Tinh doanh thu
delete bh_kt_dthuG_temp1; delete bh_kt_dthuD_temp1; delete bh_kt_dthuT_temp1; commit;
select distinct ma_dvi bulk collect into a_ma_dvi from kt_1 where ngay_ht between b_ngayD and b_ngayC;
--LAM SACH
-- for b_lp in 1..a_ma_dvi.count loop
--     PBH_KT_DTHU_DTt(a_ma_dvi(b_lp),b_ngayD,b_ngayC);
--     commit;
-- end loop;
delete bh_kt_dthuG_temp1; delete bh_kt_dthuD_temp1; delete bh_kt_dthuT_temp1; commit;
end;

/
