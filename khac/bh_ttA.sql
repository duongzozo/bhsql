/*** THANH TOAN NHANH ***/
create or replace function FBH_TTA_TTRANG(b_so_id_tt number) return varchar2
AS
    b_kq varchar2(1); b_i1 number; b_ttrangC varchar2(1);
begin
-- Dan - Tra tinh trang
select count(*) into b_i1 from bh_ttAx where so_id_tt=b_so_id_tt;
if b_i1<>0 then
	b_kq:='X';
else
	select nvl(min(ttrang),'K') into b_ttrangC from bh_ttA where so_id_tt=b_so_id_tt;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TTA_TTRANG
    (b_so_id_tt number,b_ttrang varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ttrangC varchar2(1);
begin
-- Dan - Dat tinh trang
select count(*) into b_i1 from bh_ttAx where so_id_tt=b_so_id_tt;
if b_i1<>0 then b_loi:='loi:Da hoan thanh thanh toan nhanh:loi'; return; end if;
b_loi:='loi:Loi dat tinh trang:loi';
if b_ttrang is null or b_ttrang not in('C','D','B') then return; end if;
select ttrang into b_ttrangC from bh_ttA where so_id_tt=b_so_id_tt for update nowait;
if sql%rowcount=0 then return; end if;
if b_ttrang<>b_ttrangC then
    update bh_ttA set ttrang=b_ttrang where so_id_tt=b_so_id_tt;
end if;
b_loi:='';
end;
/
create or replace procedure PBH_TTA_XOA(b_so_id_tt number,b_loi out varchar2)
AS
    b_i1 number; b_ttrangC varchar2(1);
begin
-- Dan - Xoa
b_loi:='loi:Loi xoa thanh toan nhanh:loi';
select count(*) into b_i1 from bh_ttAx where so_id_tt=b_so_id_tt;
if b_i1<>0 then return; end if;
select ttrang into b_ttrangC from bh_ttA where so_id_tt=b_so_id_tt for update nowait;
if sql%rowcount=0 or b_ttrangC='d' then return; end if;
delete bh_ttA where so_id_tt=b_so_id_tt;
b_loi:='';
end;
/
create or replace procedure PBH_TTA_NH(
    b_so_id_tt number,b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,b_l_ct varchar2,
    b_so_hd varchar2,b_gcn varchar2,b_so_hs varchar2,b_ten nvarchar2,b_ngHuong nvarchar2,
    b_ma_nh varchar2,b_so_tk varchar2,b_ten_tk varchar2,b_tien number,b_nd nvarchar2,
    b_dtac varchar2,b_ttrang varchar2,b_loi out varchar2)
AS
    b_so_dc varchar2(30); b_i1 number;
begin
-- Dan - Tao
b_loi:='loi:Loi tao thanh toan nhanh:loi';
select count(*) into b_i1 from bh_ttA_loi where b_so_id_tt=b_so_id_tt;
if b_i1=0 then
    b_i1:=b_so_id_tt;
else
    PHT_ID_MOI(b_i1,b_loi);
    if b_loi is not null then return; end if;
end if;
b_so_dc:=substr(to_char(b_i1),3);
insert into bh_ttA values(b_so_id_tt,b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_hd,b_gcn,
    b_so_hs,b_ten,b_ngHuong,b_ma_nh,b_so_tk,b_ten_tk,b_tien,b_nd,b_dtac,b_ttrang,' ',b_so_dc);
b_loi:='';
end;
/
/*** Bac dung 3 ham duoi de xu ly chuyen thanh toan nhanh ***/
create or replace procedure PBH_TTA_TON(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(200); b_so_id_tt number;
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TTA','N');
if b_loi is not null then return; end if;
select nvl(min(so_id_tt),0) into b_so_id_tt from bh_ttA where ttrang='D';
if b_so_id_tt<>0 then
	update bh_ttA set ttrang='d' where so_id_tt=b_so_id_tt and ttrang='D';
	commit;
	open cs_lke for select * from bh_ttA where so_id_tt=b_so_id_tt and ttrang='d';
else
	open cs_lke for select * from temp_1 where rownum=0;
end if;
end;
/
create or replace procedure PBH_TTA_LOI
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_tt number,b_nd nvarchar2)
AS
    b_loi varchar2(200); b_i1 number;
begin
-- Dan - Dat loi chuyen tien
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TTA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi dat loi:loi';
PHT_ID_MOI(b_i1,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
update bh_ttA set ttrang='L',so_dc=substr(to_char(b_i1),3) where so_id_tt=b_so_id_tt;
insert into bh_ttA_loi values(b_so_id_tt,b_nd,sysdate);
commit;
exception when others then
    insert into bh_ttA_loi values(b_so_id_tt,b_loi,sysdate); commit;
    raise_application_error(-20105,b_loi);
end;
/
create or replace procedure PBH_TTA_XONG(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_tt number)
AS
    b_loi varchar2(200); b_ngay_ch number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Da chuyen xong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TTA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi dat trang thai xong:loi';
insert into bh_ttAx select a.*,b_ngay_ch from bh_ttA a where so_id_tt=b_so_id_tt;
delete bh_ttA where so_id_tt=b_so_id_tt;
commit;
exception when others then
	insert into bh_ttA_loi values(b_so_id_tt,b_loi,sysdate); commit;
	raise_application_error(-20105,b_loi);
end;
/
