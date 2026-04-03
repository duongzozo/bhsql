create or replace procedure PTBH_UNG_TRA(
    b_so_id number,b_ngayD number,b_ngayC number,b_ngay_ht number,b_loi out varchar2)
AS
     b_i1 number; b_bt number:=0; b_ma_dvi varchar2(10):=FTBH_DVI_TA;
     a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_bt pht_type.a_num;
     r_ung tbh_ung_ps_ct%rowtype;
begin
-- Dan - Tap hop hoan tra ung
b_loi:='loi:Loi tong hop hoan ung:loi';
for r_lp in (select distinct ma_dvi,so_id from tbh_ps where ngay_ht between b_ngayD and b_ngayC and goc in('HD_TT','HD_HU')) loop
    select ma_dvi,so_id,bt bulk collect into a_ma_dvi,a_so_id,a_bt from
        tbh_ung_ps_ct where ma_dvi_hd=r_lp.ma_dvi and so_id_hd=r_lp.so_id and tra='C';
    for b_lp in 1..a_ma_dvi.count loop
        b_bt:=b_bt+1;
        select * into r_ung from tbh_ung_ps_ct where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
        insert into tbh_ung_tra_ct values(
            b_ma_dvi,b_so_id,b_bt,b_ngay_ht,r_ung.kieu,r_ung.ma_dvi_hd,r_ung.so_id_hd,r_ung.ma_nt,r_ung.tle,r_ung.phi,r_ung.ung,r_ung.ung_qd);
        update tbh_ung_ps_ct set tra='D' where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
    end loop;
end loop;
for r_lp in (select distinct ma_dvi_hd,so_id_hd from tbh_ung_ps_ct where tra='C' and ngay_ht<=b_ngayC) loop
    if FBH_HD_HU(r_lp.ma_dvi_hd,r_lp.so_id_hd,b_ngayC)='C' then
        select ma_dvi,so_id,bt bulk collect into a_ma_dvi,a_so_id,a_bt from
            tbh_ung_ps_ct where ma_dvi_hd=r_lp.ma_dvi_hd and so_id_hd=r_lp.so_id_hd and tra='C';
        for b_lp in 1..a_ma_dvi.count loop
            b_bt:=b_bt+1;
            select * into r_ung from tbh_ung_ps_ct where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
            insert into tbh_ung_tra_ct values(
                b_ma_dvi,b_so_id,b_bt,b_ngay_ht,r_ung.kieu,r_ung.ma_dvi_hd,r_ung.so_id_hd,r_ung.ma_nt,r_ung.tle,r_ung.phi,r_ung.ung,r_ung.ung_qd);
            update tbh_ung_ps_ct set tra='D' where ma_dvi=a_ma_dvi(b_lp) and so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
        end loop;
    end if; 
end loop;
insert into tbh_ung_tra select b_ma_dvi,b_so_id,b_ngay_ht,sum(ung_qd),0 from tbh_ung_tra_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTBH_TAM_DC(b_ma_dvi varchar2,b_so_id number,b_bt number) return varchar2
as
    b_kq varchar2(1):='C'; b_i1 number; b_i2 number; b_ma_dviG varchar2(10):=FTBH_DVI_TA;
begin
-- Dan - Kiem tra da doi chieu
select nvl(max(so_id_xl),0) into b_i1 from tbh_xl_ct where ma_dvi_ps=b_ma_dvi and so_id_ps=b_so_id and bt_ps=b_bt;
if b_i1<>0 then
    select nvl(max(so_id_dc),0) into b_i2 from tbh_dc_ct where ma_dvi=b_ma_dviG and so_id_xl=b_i1;
    if b_i2<>0 then b_kq:='D'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PTBH_TAM_PS(
    b_so_id number,b_ngayD number,b_ngayC number,b_ngay_ht number,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number:=0; b_ma_dvi varchar2(10):=FTBH_DVI_TA;
    b_tien_qd number; b_hhong_qd number; b_tien number:=0;
begin
-- Dan - Tap hop tam ung
b_loi:='loi:Loi tong hop tam hach toan:loi';
for r_lp in (select * from tbh_ps where ngay_ht between b_ngayD and b_ngayC and goc not in('TA_UP','TA_HU')) loop
    select count(*) into b_i1 from tbh_tam_ps_ct where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id and bt=r_lp.bt;
    if b_i1=0 and FTBH_TAM_DC(r_lp.ma_dvi,r_lp.so_id,r_lp.bt)='C' then
        if r_lp.ma_nt='VND' then
            b_tien_qd:=r_lp.tien; b_hhong_qd:=r_lp.hhong;
        else
            b_i1:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_ht,r_lp.ma_nt);
            b_tien_qd:=round(r_lp.tien*b_i1,0); b_hhong_qd:=round(r_lp.hhong*b_i1,0);
        end if;
        b_i1:=b_tien_qd-b_hhong_qd;
        if r_lp.ps='T' then b_tien:=b_tien+b_i1; else b_tien:=b_tien-b_i1; end if;
        b_bt:=b_bt+1;
        insert into tbh_tam_ps_ct values(b_ma_dvi,b_so_id,
            r_lp.ma_dvi,r_lp.so_id,r_lp.bt,b_ngay_ht,r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,
            r_lp.goc,r_lp.nha_bh,r_lp.pthuc,r_lp.ma_nt,r_lp.tien,b_tien_qd,r_lp.hhong,b_hhong_qd,'C');
    end if;
end loop;
insert into tbh_tam_ps select b_ma_dvi,b_so_id,b_ngay_ht,b_tien,0 from tbh_tam_ps_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TAM_TRA(
    b_so_id number,b_ngayD number,b_ngayC number,b_ngay_ht number,b_loi out varchar2)
AS
    b_i1 number; b_xl varchar2(1); b_tien number:=0; b_ma_dvi varchar2(10):=FTBH_DVI_TA;
begin
-- Dan - Tap hop tam ung
b_loi:='loi:Loi tong hop tam hach toan:loi';
for r_lp in (select * from tbh_tam_ps_ct where tra='C' and ngay_ht<b_ngayC) loop
    b_xl:='K';
    if FTBH_TAM_DC(r_lp.ma_dvi,r_lp.so_id,r_lp.bt)='C' then
        b_xl:='C';
    else
        select count(*) into b_i1 from tbh_ps where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id and bt=r_lp.bt;
        if b_i1=0 then b_xl:='C'; end if;
    end if;
    if b_xl='C' then
        insert into tbh_tam_tra_ct values(b_ma_dvi,b_so_id,
            r_lp.ma_dvi,r_lp.so_id,r_lp.bt,b_ngay_ht,r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,
            r_lp.goc,r_lp.nha_bh,r_lp.pthuc,r_lp.ma_nt,r_lp.tien,r_lp.tien_qd,r_lp.hhong,r_lp.hhong_qd);
        update tbh_tam_ps_ct set tra='D' where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id and bt=r_lp.bt;
        b_i1:=r_lp.tien_qd-r_lp.hhong_qd;
		if r_lp.ps='T' then b_tien:=b_tien+b_i1; else b_tien:=b_tien-b_i1; end if;
    end if;
end loop;
insert into tbh_tam_tra select b_ma_dvi,b_so_id,b_ngay_ht,b_tien,0 from tbh_tam_tra_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_UNG_XOA(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(200); b_i1 number; b_ma_dvi varchar2(10):=FTBH_DVI_TA;
begin
-- Dan - Xoa tam ung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from tbh_ung_tra where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select so_id_kt into b_i1 from tbh_ung_tra where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
    if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
    if b_i1<>0 then
        b_loi:='loi:Khong sua, xoa chung tu da hach toan ke toan:loi';
        raise PROGRAM_ERROR;
    end if;
    for r_lp in (select ma_dvi,so_id,bt from tbh_ung_tra_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        update tbh_ung_ps_ct set tra='C' where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id and bt=r_lp.bt;
    end loop;
end if;
select count(*) into b_i1 from tbh_tam_tra where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select so_id_kt into b_i1 from tbh_tam_tra where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
    if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
    if b_i1<>0 then
        b_loi:='loi:Khong sua, xoa chung tu da hach toan ke toan:loi';
        raise PROGRAM_ERROR;
    end if;
    for r_lp in (select ma_dvi,so_id,bt from tbh_tam_tra_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        update tbh_tam_ps_ct set tra='C' where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id and bt=r_lp.bt;
    end loop;
end if;
if b_i1<>0 then
    select so_id_kt into b_i1 from tbh_ung_ps where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
    if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
    if b_i1<>0 then
        b_loi:='loi:Khong sua, xoa chung tu da hach toan ke toan:loi';
        raise PROGRAM_ERROR;
    end if;
end if;
select count(*) into b_i1 from tbh_tam_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select so_id_kt into b_i1 from tbh_tam_ps where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
    if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
    if b_i1<>0 then
        b_loi:='loi:Khong sua, xoa chung tu da hach toan ke toan:loi';
        raise PROGRAM_ERROR;
    end if;
end if;
PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete tbh_ung_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_ung_ps_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_ung_tra where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_ung_tra_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tam_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tam_ps_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tam_tra where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tam_tra_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
