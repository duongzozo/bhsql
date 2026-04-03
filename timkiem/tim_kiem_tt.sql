create or replace procedure PBH_HD_DO_CN_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_nha_bh varchar2(20);
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_nha_bh:=nvl(trim(b_nha_bh),' ');
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,nd,so_id)
    order by ngay_ht desc,so_id returning clob) into cs_lke from bh_hd_do_cn
  where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and b_nha_bh in(' ',nha_bh) and rownum<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HDDTU_TIM
      (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
      b_ngayd number, b_ngayc number,b_ma_kh varchar2,b_so_ct varchar2,b_tiend number,b_tienc number,
      b_tu_n number,b_den_n number,b_dong out number,cs1 out pht_type.cs_type)
AS
      b_loi varchar2(100);b_n1 number;b_n2 number;b_tu number:=b_tu_n; b_den number:=b_den_n;
Begin
-- Tim cong no khach hang Da sua theo JS
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KH','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1;
insert into temp_1(n1,c2,c3,c4,n3)
      select distinct so_id,pkh_so_cng(ngay_ht) as ngay_ht,ma_kh,ma_nt, tien
      from bh_kh_cn_tu where ma_dvi=b_ma_dvi
      and ngay_ht between b_ngayd and b_ngayc
      and (b_ma_kh is null or ma_kh like '%'||b_ma_kh||'%')
      and (b_so_ct is null or so_ct like '%'||b_so_ct||'%');
if b_tiend>0 and b_tienc>0 then delete temp_1 where nvl(n3,0) not between b_tiend and b_tienc; end if;
update temp_1 set c5=(select ten from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=temp_1.c3);
select count(*) into b_dong from temp_1;  
    if b_den_n=1000000 then
        b_den:=b_dong; b_tu:=b_dong-b_tu_n;
    end if;     
      open cs1 for select * from (select n1 so_id, c2 ngay_ht, c5 ma_kh,c4 ma_nt,n3 tien,
    row_number() over (order by c2) sott from temp_1 order by c2) where sott between b_tu and b_den;
end;
/