-- CHUCLH bo khong dung PROCEDURE PHT_MA_NSD_NH
/ 
create or replace PROCEDURE PHT_MA_PHONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_ma varchar2,b_ten nvarchar2, 
    b_nhom varchar2,b_pnhan varchar2,b_ma_ct varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_ma_cd varchar2(10); b_idvung number;
begin
-- Dan - Nhap ma phong
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','NM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
 
if trim(b_ma) is null then b_loi:='loi:Nhap ma phong:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_nhom is null or b_nhom not in ('T','G') then b_loi:='loi:Sai khoi:loi'; raise PROGRAM_ERROR; end if;
if b_ma_ct is null or b_ma_ct=b_ma then b_loi:='loi:Sai ma cap tren:loi'; raise PROGRAM_ERROR; end if;
--if b_pnhan is null or b_pnhan not in ('C','K') then b_loi:='loi:Sai phap nhan:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is not null then
    select count(*) into b_i1 from ht_ma_phong where ma_dvi=b_dvi and ma=b_ma_ct;
    if b_i1=0 then b_loi:='loi:Ma cap tren chua dang ky:loi'; raise PROGRAM_ERROR; end if;
end if;
 
delete ht_ma_phong where ma_dvi=b_dvi and ma=b_ma;
b_loi:='loi:Va cham NSD:loi';
insert into ht_ma_phong values(b_dvi,b_ma,b_ten,b_nhom,'',b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/ 
  
/**** Ma can bo ****/
  
