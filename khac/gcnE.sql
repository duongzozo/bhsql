create or replace procedure PBH_GCNE_NH(
    b_ma_dvi varchar2,b_so_id number,b_md varchar2,b_nv varchar2,b_ma varchar2,b_loi out varchar2)
AS
    b_ngay_nh date:=sysdate;
begin
-- Dan - Nhap vao job
b_loi:='loi:Loi nhap table bh_gcnE:loi';
insert into bh_gcnE values(b_ma_dvi,b_so_id,b_md,b_nv,b_ma,b_ngay_nh);
b_loi:='';
exception when others then if b_loi is null then return; else null; end if;
end;
/
create or replace procedure PBH_GCNE_XOA(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_nh date; b_doi varchar2(100); b_ma_dvi_ta varchar2(10);
begin
-- Dan - Xoa khoi job
b_loi:='loi:Loi xoa table bh_gcnE:loi';
select count(*) into b_i1 from bh_gcnE_ky where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_loi:='loi:GCN da ky:loi'; return; end if;
select count(*),min(ngay_nh) into b_i1,b_ngay_nh from bh_gcnE where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_ma_dvi_ta:=FTBH_DVI_TA();
    b_doi:=FKH_NV_TSO(b_ma_dvi_ta,'BH','KY','GCN','3');
    b_i1:=PKH_LOC_CHU_SO(b_doi);
    if FKH_KHO_PHUT(b_ngay_nh,sysdate)>b_i1 then
        b_loi:='loi:Han huy ky truoc '||b_doi||':loi'; return;
    end if;
    delete bh_gcnE where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then return; else null; end if;
end;
/
create or replace procedure PBH_GCNE_LOI(b_md varchar2,b_nv varchar2,b_ma varchar2,b_loi varchar2)
AS
begin
-- Dan - Ghi loi
insert into bh_gcnE_loi values(b_md,b_nv,b_ma,b_loi);
commit;
end;
/
create or replace procedure PBH_GCNE_LKE(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_ngay date; b_ma_dvi varchar2(10):=FTBH_DVI_TA();
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','GCNE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_gcnE_loi where md=b_md and nv=b_nv and ma=b_ma;
if b_i1<>0 then
    open cs_lke for select * from temp_1 where rownum<0;
    return;
end if;
b_i1:=PKH_LOC_CHU_SO(FKH_NV_TSO(b_ma_dvi,b_md,'KY','*','3'))+1;
b_ngay:=sysdate-b_i1/1440;
open cs_lke for select ma_dvi,so_id,md,nv,ma from bh_gcnE where
    md=b_md and b_nv in(' ',nv) and b_ma in(' ',ma) and ngay_nh<b_ngay and rownum<21;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GCNE_KY(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_so_id number,b_ky clob)
AS
    b_loi varchar2(100); b_md varchar2(5); b_nv varchar2(10); b_ma varchar2(10); b_ngay_nh date:=sysdate;
begin
-- Dan - Ky
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','GCNE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select md,nv,ma into b_md,b_nv,b_ma from bh_gcnE where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_gcnE where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into bh_gcnE_ky values(b_ma_dvi,b_so_id,b_md,b_nv,b_ma,b_ky,b_ngay_nh);
--LAM SACH
-- if b_md='BH' then
--     if b_nv='XEL' and b_ma in('GCN','HD') then
--         insert into bh_gcnE_tra (
--             select b_ma_dvi,b_so_id,b_nv,b_ma,mobi,so_hd,ngay_hl,ngay_kt,ngay_cap from bh_xelgcn where ma_dvi=b_ma_dvi and so_id=b_so_id);
--     end if;
-- end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GCNE_CHU(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma_dvi varchar2,b_so_id number,b_ky out clob)
AS
    b_loi varchar2(100);
begin
-- Dan - Tra chu Ky
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','GCNE','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:GCN da xoa:loi';
select ky into b_ky from bh_gcnE_ky where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
