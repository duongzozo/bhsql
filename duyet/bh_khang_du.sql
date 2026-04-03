create or replace procedure PBH_KHANG_DU_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(2000); dt_lke clob;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten,ma_dvi,ma_dviX,nsdX,nvX,'tdiem' value to_char(ngayX,'hh:mi dd/mm/yyyy'))
	order by ma_dvi,ten returning clob) into dt_lke from bh_dtac_ma_kthac
    where ma_dviC=' ' and FBH_PQU_KHANG_QU(b_ma_dvi,b_nsd,nvX,ma_dvi)='C';
select json_object('dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE procedure PBH_KHANG_DU_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ngay date:=sysdate;
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_ma_dvi pht_type.a_var;
    a_ma_dviX pht_type.a_var; a_nvX pht_type.a_var;
    b_txt clob:=b_oraIn;
Begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi xu ly PBH_KHANG_DU_NH:loi';
FKH_JSa_NULL(b_txt);
b_lenh:=FKH_JS_LENH('ma,ten,ma_dvi,ma_dvix,nvx');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_ma_dvi,a_ma_dviX,a_nvX using b_txt;
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp)=' ' or a_ma_dviX(b_lp)=' ' then
        b_loi:='loi:Chon khach hang dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    if FBH_PQU_KHANG_QU(b_ma_dvi,b_nsd,a_nvX(b_lp),a_ma_dvi(b_lp))<>'C' then
        b_loi:='loi:Khong duoc phan cap khach hang: '||a_ten(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
end loop;
forall b_lp in 1..a_ma.count
    update bh_dtac_ma_kthac set ma_dviC=b_ma_dvi,nsdC=b_nsd,ngayC=b_ngay where ma=a_ma(b_lp) and ma_dviX=a_ma_dviX(b_lp);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
