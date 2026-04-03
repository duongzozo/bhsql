create or replace function FTBH_TM_TXT(b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from tbh_tm_txt where so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from tbh_tm_txt where so_id=b_so_id and loai='dt_ct';
	PKH_JS_BONH(b_txt); b_kq:=nvl(FKH_JS_GTRIs(b_txt,b_tim),' ');
end if;
return b_kq;
end;
/
create or replace function FTBH_TM(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra co nhuong tai tam 
select count(*) into b_i1 from tbh_tm_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FTBH_TM_FR(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Kiem tra co Fronting
select count(*) into b_i1 from tbh_tmN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then
    select count(*) into b_i1 from tbh_tm_hd a,tbh_tm b where 
        a.ma_dvi_hd=b_ma_dvi and a.so_id_hd=b_so_id and a.so_id=b.so_id and b.pthuc='F';
    if b_i1<>0 then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_TM_TL(
    b_ma_dvi varchar2,b_so_id number,b_lh_nv varchar2,
    b_ngayD number,b_ngayC number:=30000101) return number
AS
    b_kq number:=0; b_i1 number; b_so_id_ta number; b_so_idD number;
    b_ngay_hl number; b_ngay_kt number; b_ngayT number;
    a_so_id_ta pht_type.a_num;
begin
-- Dan - Xac dinh ty le tai theo nghiep vu
PKH_MANG_KD_N(a_so_id_ta);
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for r_lp in (select distinct so_id from tbh_tm_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD) loop
    b_so_id_ta:=FTBH_TM_SO_ID_DAU(r_lp.so_id);
    if FKH_ARR_VTRI_N(a_so_id_ta,b_so_id_ta)<>0 then continue; end if;
    b_i1:=a_so_id_ta.count+1;
    a_so_id_ta(b_i1):=b_so_id_ta;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp),b_ngayC);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_tm where so_id=b_so_id_ta;
    if b_ngayD<=b_ngay_kt and b_ngayC>=b_ngay_hl then
        select nvl(max(ngay_hl),0) into b_ngayT from tbh_tm_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            lh_nv in(' ',b_lh_nv) and tien>0 and ngay_hl<=b_ngayD;
        if b_ngayT<>0 then
            select nvl(sum(pt),0) into b_i1 from tbh_tm_pbo where so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and
                ngay_hl=b_ngayT and so_id_hd=b_so_id and lh_nv in(' ',b_lh_nv) and tien>0;
            b_kq:=b_kq+b_i1;
        end if;
    end if;
end loop;
return b_kq;
end;
/
create or replace function FTBH_TM_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,
    b_ngayD number,b_ngayC number:=30000101) return number
AS
    b_kq number:=0; b_i1 number; b_so_id_ta number; b_so_idD number;
    b_ngay_hl number; b_ngay_kt number; b_ngayT number;
    a_so_id_ta pht_type.a_num;
begin
-- Dan - Xac dinh ty le tai theo nghiep vu
PKH_MANG_KD_N(a_so_id_ta);
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for r_lp in (select distinct so_id from tbh_tm_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in(0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_TM_SO_ID_DAU(r_lp.so_id);
    if FKH_ARR_VTRI_N(a_so_id_ta,b_so_id_ta)<>0 then continue; end if;
    b_i1:=a_so_id_ta.count+1;
    a_so_id_ta(b_i1):=b_so_id_ta;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp),b_ngayC);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_tm where so_id=b_so_id_ta;
    if b_ngayD<=b_ngay_kt and b_ngayC>=b_ngay_hl then
        select nvl(max(ngay_hl),0) into b_ngayT from tbh_tm_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
             so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0 and ngay_hl<=b_ngayD;
        if b_ngayT<>0 then
            select nvl(sum(pt),0) into b_i1 from tbh_tm_pbo where so_id=b_so_id_ta and
                ma_dvi_hd=b_ma_dvi and ngay_hl=b_ngayT and so_id_hd=b_so_id and
                so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0;
            b_kq:=b_kq+b_i1;
        end if;
    end if;
end loop;
return b_kq;
end;
/
create or replace procedure PTBH_TM_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,
    b_tlT out number,b_tlN out number,b_ngayD number,b_ngayC number:=30000101)
AS
    b_i1 number; b_so_id_ta number; b_so_idD number;
    b_ngay_hl number; b_ngay_kt number; b_ngayT number;
    a_so_id_ta pht_type.a_num;
begin
-- Dan - Xac dinh ty le tai theo nghiep vu
PKH_MANG_KD_N(a_so_id_ta);
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
b_tlT:=0; b_tlN:=0;
for r_lp in (select distinct so_id from tbh_tm_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in(0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_TM_SO_ID_DAU(r_lp.so_id);
    if FKH_ARR_VTRI_N(a_so_id_ta,b_so_id_ta)<>0 then continue; end if;
    b_i1:=a_so_id_ta.count+1;
    a_so_id_ta(b_i1):=b_so_id_ta;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp),b_ngayC);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_tm where so_id=b_so_id_ta;
    if b_ngayD<=b_ngay_kt and b_ngayC>=b_ngay_hl then
        select nvl(max(ngay_hl),0) into b_ngayT from tbh_tm_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt=b_so_id_dt and lh_nv in(' ',b_lh_nv) and tien>0 and ngay_hl<=b_ngayD;
        if b_ngayT<>0 then
            for r_lp in (select nha_bh,pt from tbh_tm_pbo where
                so_id=b_so_id_ta and ngay_hl=b_ngayT and ma_dvi_hd=b_ma_dvi and
                so_id_hd=b_so_id and so_id_dt=b_so_id_dt and lh_nv in(' ',b_lh_nv) and tien>0) loop
                if FBH_DTAC_MA_NHOM(r_lp.nha_bh)='T' then b_tlT:=b_tlT+r_lp.pt; else b_tlN:=b_tlN+r_lp.pt; end if;
            end loop;
        end if;
    end if;
end loop;
end;
/
create or replace function FTBH_TM_HH_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_lh_nv varchar2,b_ngayD number,b_phi number,b_tp number:=0) return number
AS
    b_i1 number; b_kq number:=0;
    b_so_id_ta number; b_so_idD number; b_ngay_hl number; b_ngay_kt number;
    a_so_id_ta pht_type.a_num;
begin
-- Dan - Tinh hoa hong
PKH_MANG_KD_N(a_so_id_ta);
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for r_lp in (select distinct so_id from tbh_tm_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in (0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_TM_SO_ID_DAU(r_lp.so_id); b_i1:=0;
    for b_lp in 1..a_so_id_ta.count loop
        if a_so_id_ta(b_lp)=b_so_id_ta then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_i1:=a_so_id_ta.count+1;
        a_so_id_ta(b_i1):=b_so_id_ta;
    end if;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp),b_ngayD);
    b_ngay_hl:=FTBH_HD_NGAY_HL('',b_so_id_ta); b_ngay_kt:=FTBH_HD_NGAY_KT('',b_so_id_ta);
    if b_ngayD between b_ngay_hl and b_ngay_hl then
        for r_lp in(select pt,pt_hh from tbh_tm_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0) loop
            b_kq:=b_kq+round(b_phi*r_lp.pt*r_lp.pt_hh/10000,b_tp);
        end loop;
    end if;
end loop;
return b_kq;
end;
/
create or replace procedure PTBH_TM_HH_DT
    (b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,
    b_ngayD number,b_phi number,b_hhT out number,b_hhN out number,b_tp number:=0)
AS
    b_i1 number; b_so_id_ta number; b_so_idD number; b_ngay_hl number; b_ngay_kt number;
    b_pT number; b_hT number; b_pN number; b_hN number;
    a_so_id_ta pht_type.a_num;
begin
-- Dan - Tinh hoa hong
PKH_MANG_KD_N(a_so_id_ta);
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for r_lp in (select distinct so_id from tbh_tm_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in (0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_TM_SO_ID_DAU(r_lp.so_id); b_i1:=0;
    for b_lp in 1..a_so_id_ta.count loop
        if a_so_id_ta(b_lp)=b_so_id_ta then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_i1:=a_so_id_ta.count+1;
        a_so_id_ta(b_i1):=b_so_id_ta;
    end if;
end loop;
b_hhT:=0; b_hhN:=0;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp),b_ngayD);
    b_ngay_hl:=FTBH_HD_NGAY_HL('',b_so_id_ta); b_ngay_kt:=FTBH_HD_NGAY_KT('',b_so_id_ta);
    if b_ngayD between b_ngay_hl and b_ngay_hl then
        for r_lp in(select pt,pt_hh,nha_bh from tbh_tm_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0) loop
            b_i1:=round(b_phi*r_lp.pt*r_lp.pt_hh/10000,b_tp);
            if FBH_DTAC_MA_NHOM(r_lp.nha_bh)='T' then b_hhT:=b_hhT+b_i1; else b_hhN:=b_hhN+b_i1; end if;
        end loop;
    end if;
end loop;
end;
/
create or replace function FTBH_TM_SO_ID_DAU(b_so_id number,b_dk varchar2:='K') return number
AS
    b_so_idD number; b_so_ctG varchar2(20);
begin
-- Dan - Tra so ID tai dau
select nvl(min(so_id_d),0) into b_so_idD from tbh_tm where so_id=b_so_id;
if b_so_idD=0 and b_dk='C' then
    select nvl(min(so_id_d),0) into b_so_idD from tbh_tmB where so_id=b_so_id;
    if b_so_idD=0 then
        select nvl(min(so_ctG),' ') into b_so_ctG from tbh_tmB_cbi where so_id=b_so_id;
        if b_so_ctG<>' ' then
            select nvl(min(so_id_d),0) into b_so_idD from tbh_tm where so_ct=b_so_ctG;
        end if;
    end if;
end if;
return b_so_idD;
end;
/
create or replace function FTBH_TM_SO_ID_GOC(b_so_id number) return number
AS
    b_so_id_g number;
begin   
--  Tra so ID goc qua so ID xu ly
select nvl(min(so_id_g),0) into b_so_id_g from tbh_tm where so_id=b_so_id;
return b_so_id_g;
end;
/
create or replace function FTBH_TM_SO_ID_BS(b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number;
begin
-- Dan - Tra so ID tai tam thoi bo sung qua so ID
b_so_idD:=FTBH_TM_SO_ID_DAU(b_so_id);
select nvl(max(so_id),b_so_id) into b_kq from (select so_id,ngay_ht from tbh_tm where so_id_d=b_so_idD) where ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FTBH_TM_SO_ID_TR(b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number;
begin
-- Dan - Tra so ID truoc
b_so_idD:=FTBH_GHEP_SO_ID_DAU(b_so_id);
select nvl(max(so_id),0) into b_kq from (select so_id,ngay_ht from tbh_tm where so_id_d=b_so_idD) where ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FTBH_TM_SO_CT(b_so_ct varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID
select nvl(min(so_id),0) into b_kq from tbh_tm where so_ct=b_so_ct;
return b_kq;
end;
/
create or replace function FTBH_TM_SO_CTd(b_so_ct varchar2) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID
select nvl(min(so_id_d),0) into b_kq from tbh_tm where so_ct=b_so_ct;
return b_kq;
end;
/
create or replace function FTBH_TM_SO_ID(b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so ID
select min(so_ct) into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PTBH_TM_TTIN(
    b_ma_dvi varchar2,b_so_id number,b_kieu_ps out varchar2,b_nv out varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
begin
-- Dan - Tra ttin hd
b_loi:='loi:Loi xu ly PTBH_TM_TTIN:loi';
select nvl(min(nv),' ') into b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv<>' ' then
    b_kieu_ps:='H'; b_so_hd:=FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id);
else
    select nvl(min(nv),' '),min(so_hd) into b_nv,b_so_hd from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_nv<>' ' then
        b_kieu_ps:='B';
    else
        b_loi:='loi:Hop dong, bao gia da xoa:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TM_TTINk(
    b_ma_dvi varchar2,b_so_id number,b_kieu_ps out varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra ttin hd
b_loi:='loi:Loi xu ly PTBH_TM_TTINk:loi';
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_kieu_ps:='H';
else
    select count(*) into b_i1 from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        b_kieu_ps:='B';
    else
        b_loi:='loi:Hop dong, bao gia da xoa:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TM_TTINh(
    b_ma_dvi varchar2,b_so_id number,b_ngay_hl out number,b_ngay_kt out number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra ttin hd
b_loi:='loi:Loi xu ly PTBH_TM_TTINh:loi';
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select count(*) into b_i1 from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        b_loi:='loi:Hop dong, bao gia da xoa:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TM_TTINn(
    b_ma_dvi varchar2,b_so_id number,b_nv out varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra ttin hd
b_loi:='loi:Loi xu ly PTBH_TM_TTINn:loi';
select nvl(min(nv),' ') into b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv=' ' then
	select nvl(min(nv),' ') into b_nv from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
	if b_nv=' ' then b_loi:='loi:Hop dong, bao gia da xoa:loi'; return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_TM_TTINf(
    b_ma_dvi varchar2,b_so_id number,b_kieu_ps out varchar2,b_nv out varchar2,b_so_hd out varchar2,
    b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number,b_nt_tien out varchar2,b_nt_phi out varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Tra ttin hd
b_loi:='loi:Loi xu ly PTBH_TM_TTINf:loi';
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_kieu_ps:='H'; b_so_hd:=FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id);
    select nv,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_nv,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select count(*) into b_i1 from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        b_kieu_ps:='B';
        select so_hd,nv,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_so_hd,b_nv,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        b_loi:='loi:Hop dong, bao gia da xoa:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTBH_TM_NT_TA(b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Nguyen te hop dong tam
select nvl(min(nt_tien),'VND') into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_TM_NT_PHI(b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Nguyen te hop dong tam
select nvl(min(nt_phi),'VND') into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_TM_HD_HTHANH(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_no number:=0; b_co number:=0; b_kq number;
begin
for r_lp in (select distinct ma_dvi_hd,so_id_hd from tbh_tm_hd where so_id=b_so_id) loop
    for r_lp1 in (select ma_nt,sum(no) no,sum(co) co from bh_hd_goc_sc_phi
        where ma_dvi=r_lp.ma_dvi_hd and so_id=r_lp.so_id_hd group by ma_nt) loop
        if r_lp1.ma_nt='VND' then b_no:=b_no+r_lp1.no; b_co:=b_co+r_lp1.co;
        else
            b_no:=b_no+FTT_VND_QD(b_ma_dvi,'30000101',r_lp1.ma_nt,r_lp1.no);
            b_co:=b_co+FTT_VND_QD(b_ma_dvi,'30000101',r_lp1.ma_nt,r_lp1.co);
        end if;
    end loop;
end loop;
if b_co=b_no then b_kq:=100;
elsif b_no=0 or b_co=0 then b_kq:=0;
else b_kq:=round(b_co*100/b_no,2);
end if;
return b_kq;
end;
/
create or replace function FTBH_TM_SO_BS(b_so_id number) return varchar2
AS
    b_so_idD number; b_so_ct varchar2(20); b_so_bs varchar2(20); b_stt number; b_i1 number:=1; 
begin
-- Dan - Tra so sua doi bo sung
b_so_idD:=FTBH_TM_SO_ID_DAU(b_so_id); b_so_ct:=substr(to_char(b_so_idD),3);
select count(*) into b_stt from tbh_tm where so_id_d=b_so_idD;
while b_i1<>0 loop
     b_so_bs:=b_so_ct||'/'||'B'||trim(to_char(b_stt));
     select count(*) into b_i1 from tbh_tm where so_ct=b_so_bs;
     b_stt:=b_stt+1;
end loop;
return b_so_bs;
end;
/
create or replace procedure PTBH_TM_SO_ID_TA(
    b_ma_dvi_hd varchar2,b_so_id_hd number,a_so_id_ta out pht_type.a_num)
AS
    b_so_idD number;
begin
-- Dan - Tra mang so ID dau tai tam thoi qua so ID hop dong
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
select distinct b.so_id_d BULK COLLECT into a_so_id_ta from tbh_tm_hd a,tbh_tm b where
    a.ma_dvi_hd=b_ma_dvi_hd and a.so_id_hd=b_so_idD and b.so_id=a.so_id;
end;
/
create or replace function FTBH_TM_SO_ID_DT_TA(
    b_so_id number,b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number) return boolean
AS
    b_so_idD number; b_i1 number; b_kq boolean:=false;
begin
-- Dan - Ktra hop dong tai tam chua so ID hop dong va so ID doi tuong
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
select count(*) into b_i1 from (select * from tbh_tm_hd where so_id=b_so_id)
    where ma_dvi_hd=b_ma_dvi_hd and so_id_hd=b_so_idD and so_id_dt=b_so_id_dt;
if b_i1<>0 then b_kq:=true; end if;
return b_kq;
end;
/
create or replace function FTBH_TM_NGUON(b_so_id number,b_ngay number) return varchar2
AS
    b_so_id_bs number; b_nguon varchar2(1);
begin
b_so_id_bs:=FTBH_TM_SO_ID_BS(b_so_id,b_ngay);
select nvl(min(nguon),'N') into b_nguon from tbh_tm where so_id=b_so_id_bs;
return b_nguon;
end;
/
create or replace function FTBH_TM_NV(b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
select min(nv) into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_TM_NGAY_XL(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay xu ly hop dong tai
select nvl(min(ngay_ht),0) into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_TM_NGAY_HL(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay hieu luc hop dong tai
select nvl(min(ngay_hl),0) into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_TM_NGAY_KT(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay ket thuc hop dong tai
select nvl(min(ngay_kt),0) into b_kq from tbh_tm where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FTBH_TM_NGAYf(
	b_so_id number,b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number)
AS
begin
-- Dan - Ngay hop dong tai
select nvl(min(ngay_ht),0),nvl(min(ngay_hl),0),nvl(min(ngay_kt),0)
	into b_ngay_ht,b_ngay_hl,b_ngay_kt from tbh_tm where so_id=b_so_id;
end;
/
create or replace procedure PTBH_TM_SO_ID_TA_DT
    (b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number,a_so_id_ta out pht_type.a_num)
AS
    b_so_id_hdD number; b_nv varchar2(10);
begin
-- Dan - So ID hop dong tai tam thoi cho 1 doi tuong trong hop dong bao hiem
PKH_MANG_KD_N(a_so_id_ta);
b_so_id_hdD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id_hdD);
if b_ngay=0 then
    select so_id BULK COLLECT into a_so_id_ta from
        (select a.so_id_d,max(a.so_id) so_id from tbh_tm_hd b,tbh_tm a
        where b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=b_so_id_hdD and (b_so_id_dt=0 or b.so_id_dt in(0,b_so_id_dt))
        and a.so_id=b.so_id group by a.so_id_d);
else
    select so_id BULK COLLECT into a_so_id_ta from
        (select a.so_id_d,max(a.so_id) so_id from tbh_tm_hd b,tbh_tm a
        where b.ma_dvi_hd=b_ma_dvi and b.so_id_hd=b_so_id_hdD and (b_so_id_dt=0 or b.so_id_dt in(0,b_so_id_dt))
        and a.so_id=b.so_id and b_ngay between a.ngay_hl and a.ngay_kt group by a.so_id_d);
end if;
end;
/
create or replace procedure PTBH_TM_SO_ID_TA_TL(
    b_so_id number,a_pthuc out pht_type.a_var,a_ma_ta out pht_type.a_var,a_nha_bh out pht_type.a_var,
    a_pt out pht_type.a_num,a_tien out pht_type.a_num,b_ngay number:=30000101)
AS
    b_so_idB number; b_i1 number; b_nha_bh varchar2(20);
begin
-- Dan - Ty le tai tam thoi cua 1 hop dong tai
b_so_idB:=FTBH_TM_SO_ID_BS(b_so_id,b_ngay);
select 'F',ma_ta,nbhC,sum(pt),sum(tien) BULK COLLECT into a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_tien
	from tbh_tm_phi where so_id=b_so_idB group by ma_ta,nbhC;
end;
/
create or replace procedure FTBH_TM_PBO_TL(
    b_so_id number,
    a_ma_dvi out pht_type.a_var,a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,
    a_lh_nv out pht_type.a_var,a_tl out pht_type.a_num,b_loi out varchar2)
AS
    b_bt number:=0; b_phi number:=0; a_phi pht_type.a_num;
begin
-- Dan - Tinh ty le phi
select * BULK COLLECT into a_ma_dvi,a_so_id,a_so_id_dt,a_lh_nv,a_phi from
    (select ma_dvi_hd,so_id_hd,so_id_dt,lh_nv,sum(phi) phi from tbh_tm_pbo
    where so_id=b_so_id group by ma_dvi_hd,so_id_hd,so_id_dt,lh_nv) where phi>0;
for b_lp in 1..a_ma_dvi.count loop
    b_phi:=b_phi+a_phi(b_lp);
end loop;
if b_phi>0 then
    for b_lp in 1..a_ma_dvi.count loop
        a_tl(b_lp):=round(a_phi(b_lp)/b_phi,4);
    end loop;
else
    for b_lp in 1..a_ma_dvi.count loop
        a_tl(b_lp):=0;
    end loop;
end if;
end;
/
create or replace procedure PBH_TMN_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_tl out number,b_hh out number)
AS
begin
-- Dan - Xac dinh ty le nhan tai Fac
select nvl(sum(pt),0),nvl(max(hh),0) into b_tl,b_hh from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) and lh_nv in (' ',b_lh_nv);
b_hh:=-b_hh;
end;
/