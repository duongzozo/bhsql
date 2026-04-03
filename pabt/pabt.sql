create or replace procedure PBH_GIA_TS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_so_id_dt number; b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_idG number; b_so_id number;
    dt_ct clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id_dt');
EXECUTE IMMEDIATE b_lenh into b_so_id_dt using b_oraIn;
b_ngay_xr:=PKH_NG_CSO(sysdate);
FBH_XE_SO_ID_DT(b_so_id_dt,b_ma_dvi,b_so_idG);
if b_so_idG=0 then b_loi:='loi:GCN xe da xoa:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_XE_SO_IDb(b_ma_dvi,b_so_idG,b_ngay_xr);
select json_object('bien' value bien_xe,'nam' value nam_sx,'hang' value hang,'hieu' value hieu,'dong' value dong,'chu' value tenc,'huong' value ng_huong) into dt_ct
    from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
select json_object('dt_ct' value dt_ct returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
