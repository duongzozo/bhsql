create or replace function FTBH_DVI_TA return varchar2
AS
    b_kq varchar2(20);
begin
select min(dvi_ta) into b_kq from tbh_dvi_ta;
return b_kq;
end;
/
create or replace procedure PTBH_DVI_TA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi_ta out varchar2)
AS
     b_loi varchar2(200);
begin
-- Dan - Tra ma don vi tai
b_dvi_ta:=FTBH_DVI_TA();
end;
/
create or replace function FTBH_GHEP(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra co nhuong tai co dinh
select count(*) into b_i1 from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FTBH_GHEP_SO_CT(b_so_ct varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so CT
select nvl(min(so_id),0) into b_so_id from tbh_ghep where so_ct=b_so_ct;
return b_so_id;
end;
/
create or replace function FTBH_GHEP_SO_CTd(b_so_ct varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so CT
select nvl(min(so_id_d),0) into b_so_id from tbh_ghep where so_ct=b_so_ct;
return b_so_id;
end;
/
create or replace function FTBH_GHEP_SO_CTc(b_so_ct varchar2) return number
AS
    b_so_id number:=0;
begin
-- Dan - Tra so ID qua so CT
if b_so_ct is not null then
    b_so_id:=FTBH_GHEP_SO_CTd(b_so_ct);
    if b_so_id=0 then b_so_id:=FTBH_TM_SO_CTd(b_so_ct); end if;
end if;
return b_so_id;
end;
/
create or replace function FTBH_GHEP_NGAY_DAU(b_so_id number) return number
AS
    b_so_idD number; b_ngayD number;
begin
-- Dan - Tra so ID tai dau
b_so_idD:=FTBH_GHEP_SO_ID_DAU(b_so_id);
select nvl(min(ngay_hl),0) into b_ngayD from tbh_ghep where so_id=b_so_idD;
return b_ngayD;
end;
/
create or replace function FTBH_KHOANG(b_ngay_xl number,a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num) return number
AS
    b_i1 number; b_khoang number:=0; b_so_id number; b_ngay_hl number; b_ngay_kt number;
begin
for b_lp in 1..a_ma_dvi.count loop
    b_so_id:=FBH_HD_SO_ID_BS(a_ma_dvi(b_lp),a_so_id(b_lp),b_ngay_xl);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_id=b_so_id;
    b_i1:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_kt);
    if b_i1>b_khoang then b_khoang:=b_i1; end if;
end loop;
return b_khoang;
end;
/
create or replace function FTBH_HS_KHO(
    b_ngT number,b_ngD number,b_nghl number,b_ngkt number,b_ngQ number) return number
AS
    b_kq number:=0; b_ngB number; b_ngC number; b_ngM number:=b_nghl;
begin
-- Dan - Tinh he so khoang tai
if b_ngT<b_ngkt then
    if b_ngQ>b_ngM then b_ngM:=b_ngQ; end if;
    if b_ngM<b_ngkt then
        if b_ngT<b_ngM then b_ngB:=b_ngM; else b_ngB:=b_ngT; end if;
        if b_ngD>b_ngkt then b_ngC:=b_ngkt; else b_ngC:=b_ngD; end if;
        if b_ngB<b_ngC then
            b_kq:=FKH_KHO_NGSO(b_ngB,b_ngC)/FKH_KHO_NGSO(b_ngT,b_ngkt);
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_HS_KHOh(
    b_ngT number,b_ngD number,b_nghl number,b_ngkt number,b_ngQ number) return number
AS
    b_kq number:=0; b_ngC number; b_ngM number:=b_nghl;
begin
-- Dan - Tinh he so khoang hop dong da su dung
if b_ngT<b_ngkt then
    if b_ngQ>b_ngM then b_ngM:=b_ngQ; end if;
    if b_ngM<b_ngkt then
        if b_ngD>b_ngkt then b_ngC:=b_ngkt; else b_ngC:=b_ngD; end if;
        if b_ngM<b_ngC then
            b_kq:=FKH_KHO_NGSO(b_ngM,b_ngC)/FKH_KHO_NGSO(b_ngT,b_ngkt);
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PTBH_KIEU_HD
    (b_ma_dvi_ps varchar2,b_so_id_ps number,b_kieu varchar2, b_goc varchar2,b_kieu_hd out varchar2)
as
    b_loi varchar2(100);
begin
-- Lay kieu phat sinh cho don goc va don nhan
if b_kieu='C' then
    if b_goc='HD_PS' then
        select max(kieu_hd) into b_kieu_hd from tbh_ghep_hd a, bh_hd_goc b where b.ma_dvi=a.ma_dvi_hd
            and a.so_id=b_so_id_ps and b.so_id=a.so_id_hd;
    elsif b_goc='HD_HU' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_hd_goc_hu b, bh_hd_goc c
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id and b.so_id=c.so_id;
    elsif b_goc='HD_TT' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_hd_goc_tthd b, bh_hd_goc c
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id
                and FBH_HD_SO_ID_DAU(b.ma_dvi,b.so_id)=c.so_id;
    elsif b_goc='BT_HS' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_bt_hs_nv b, bh_hd_goc c
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id
                and FBH_HD_SO_ID_DAU(b.ma_dvi,b.so_id)=c.so_id_d;
    elsif b_goc='BT_GD' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_bt_gd_hs b, bh_hd_goc c, bh_bt_hs_nv d
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id
                and b.so_id_bt=d.so_id and FBH_HD_SO_ID_DAU(d.ma_dvi,d.so_id)=c.so_id_d;
    elsif b_goc='BT_TB' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_bt_ntba_tt b, bh_hd_goc c, bh_bt_hs_nv d
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id
                and b.so_id_hs=d.so_id and FBH_HD_SO_ID_DAU(d.ma_dvi,d.so_id)=c.so_id_d;
    elsif b_goc='BT_TH' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_bt_thoi b, bh_hd_goc c, bh_bt_hs_nv d
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id
                and b.so_id_hs=d.so_id and FBH_HD_SO_ID_DAU(d.ma_dvi,d.so_id)=c.so_id_d;
    elsif b_goc='CP_C' then
        select max(kieu_hd) into b_kieu_hd from tbh_ps a, bh_cp b, bh_hd_goc c
            where a.ma_dvi=b_ma_dvi_ps and b.ma_dvi=a.ma_dvi and c.ma_dvi=b.ma_dvi and a.so_id=b_so_id_ps and a.so_id=b.so_id
                and FBH_HD_GOC_SO_ID_DAU(b.ma_dvi,b.so_hd)=c.so_id;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FTBH_GHEP_NT_TA(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Nguyen te hop dong tai di
select nvl(min(nt_tien),'VND') into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_GHEP_NT_PHI(b_so_id number) return varchar2
AS
    b_kq varchar2(5);
begin
-- Dan - Nguyen te hop dong tai di
select nvl(min(nt_phi),'VND') into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PTBH_DK_LUT(
    b_nv varchar2,a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_dk_lut out varchar2,b_hs_lut out number,b_ngay number:=30000101)
AS
begin
if b_nv='PHH' then
    FBH_PHH_DK_LUTn(a_ma_dvi,a_so_id,a_so_id_dt,b_dk_lut,b_hs_lut,b_ngay);
elsif b_nv='PKT' then
    FBH_PKT_DK_LUTn(a_ma_dvi,a_so_id,a_so_id_dt,b_dk_lut,b_hs_lut,b_ngay);
else
    b_dk_lut:='K'; b_hs_lut:=0;
end if;
end;
/
create or replace procedure PTBH_GHEP_KYTT(
    b_ma_dvi varchar2,b_so_id number,a_ngay out pht_type.a_num,a_pt out pht_type.a_num)
AS
    b_tien number:=0; a_tien pht_type.a_num;
begin
delete tbh_ghep_kytt_temp;
insert into tbh_ghep_kytt_temp select b.ngay,b.ma_nt,sum(b.tien) from tbh_ghep_hd a,bh_hd_goc_tt b where
    a.so_id=b_so_id and b.ma_dvi=a.ma_dvi_hd and b.so_id=a.so_id_hd group by b.ngay,b.ma_nt;
if sql%rowcount=0 then
    insert into tbh_ghep_kytt_temp select b.ngay,b.ma_nt,sum(b.tien) from tbh_tm_hd a,bh_hd_goc_tt b where
        a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.ma_dvi=a.ma_dvi_hd and b.so_id=a.so_id_hd group by b.ngay,b.ma_nt;
end if;
select distinct ngay BULK COLLECT into a_ngay from tbh_ghep_kytt_temp;
if a_ngay.count=1 then a_pt(1):=100;
else
    b_tien:=0;
    for b_lp in 1..a_ngay.count loop
        a_tien(b_lp):=0;
        for r_lp in (select ma_nt,tien from tbh_ghep_kytt_temp where ngay=a_ngay(b_lp)) loop
            if r_lp.ma_nt='VND' then a_tien(b_lp):=a_tien(b_lp)+r_lp.tien;
            else a_tien(b_lp):=a_tien(b_lp)+FBH_TT_VND_QD('30000101',r_lp.ma_nt,r_lp.tien);
            end if;
        end loop;
        b_tien:=b_tien+a_tien(b_lp);
    end loop;
    a_pt(1):=1;
    for b_lp in 2..a_ngay.count loop
        a_pt(b_lp):=round(a_tien(b_lp)/b_tien,2);
        if abs(a_pt(b_lp))>abs(a_pt(1)) then a_pt(b_lp):=a_pt(1); end if;
        a_pt(1):=a_pt(1)-a_pt(b_lp);
    end loop;
end if;
end;
/
create or replace function FTBH_GHEP_HD_HTHANH(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_no number:=0; b_co number:=0; b_kq number;
begin
for r_lp in (select distinct ma_dvi_hd,so_id_hd from tbh_ghep_hd where so_id=b_so_id) loop
    for r_lp1 in (select ma_nt,sum(no) no,sum(co) co from bh_hd_goc_sc_phi where ma_dvi=r_lp.ma_dvi_hd and so_id=r_lp.so_id_hd group by ma_nt) loop
        if r_lp1.ma_nt='VND' then b_no:=b_no+r_lp1.no; b_co:=b_co+r_lp1.co;
        else
            b_no:=b_no+FBH_TT_VND_QD('30000101',r_lp1.ma_nt,r_lp1.no);
            b_co:=b_co+FBH_TT_VND_QD('30000101',r_lp1.ma_nt,r_lp1.co);
        end if;
    end loop;
end loop;
if b_no=0 or b_co=0 then b_kq:=0;
elsif b_co>=b_no then b_kq:=100;
else b_kq:=round(b_co*100/b_no,2);
end if;
return b_kq;
end;
/
create or replace function FTBH_SO_TA(b_ma_dvi varchar2,b_nv varchar2,b_ngay_ht number) return varchar2
AS
    b_kq varchar2(50); b_stt number; b_nam number;
begin
-- Dan - Tra so tai
b_nam:=round(b_ngay_ht/10000,0);
b_stt:=FBH_KH_SO_TT(b_ma_dvi,'TA',b_nv,b_nam);
b_kq:=trim(to_char(b_stt))||'/'||substr(trim(to_char(b_nam)),3)||'/TA-'||b_nv;
return b_kq;
end;
/
create or replace function FTBH_SO_GHEP(b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so ghep
select min(so_ct) into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_SO_BS(b_so_id number) return varchar2
AS
    b_so_idD number; b_so_ct varchar2(20); b_so_bs varchar2(20); b_stt number; b_i1 number:=1; 
begin
-- Dan - Tra so sua doi bo sung
b_so_idD:=FTBH_GHEP_SO_ID_DAU(b_so_id);
select min(so_ct) into b_so_ct from tbh_ghep where so_id=b_so_idD;
select count(*) into b_stt from tbh_ghep where so_id_d=b_so_idD;
while b_i1<>0 loop
     b_so_bs:=b_so_ct||'/'||'B'||trim(to_char(b_stt));
     select count(*) into b_i1 from tbh_ghep where so_ct=b_so_bs;
     b_stt:=b_stt+1;
end loop;
return b_so_bs;
end;
/
create or replace function FTBH_HD_SO_ID_TA
    (b_ngay number,b_so_id number,b_pthuc varchar2,b_ma_ta varchar2) return number
AS
    b_so_id_ta number:=0; b_so_idB number; b_ngay_hl number; b_ngay_kt number; b_nv varchar2(10);
begin
-- Dan - Tra ID cua hop dong tai co dinh
b_so_idB:=FTBH_GHEP_SO_ID_BS(b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_ghep where so_id=b_so_idB;
if b_ngay between b_ngay_hl and b_ngay_kt then
    select nvl(min(so_id_ta),0) into b_so_id_ta from tbh_ghep_ky
        where so_id=b_so_idB and pthuc=b_pthuc and ma_ta=b_ma_ta;
end if;
return b_so_id_ta;
end;
/
create or replace function FTBH_GHEP_SO_ID_TR(b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number;
begin
-- Dan - Tra so ID truoc
b_so_idD:=FTBH_GHEP_SO_ID_DAU(b_so_id);
select nvl(max(so_id),0) into b_kq from (select so_id,ngay_ht from tbh_ghep where so_id_d=b_so_idD) where ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FTBH_GHEP_SO_ID_BS(b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number;
begin
-- Dan - Tra so ID tai bo sung qua so ID
b_so_idD:=FTBH_GHEP_SO_ID_DAU(b_so_id);
select nvl(max(so_id),b_so_idD) into b_kq from tbh_ghep where so_id_d=b_so_idD and ngay_ht<=b_ngay_ht;
return b_kq;
end;
/
create or replace function FTBH_GHEP_SO_ID_DAU(b_so_id number) return number
AS
    b_so_idD number;
begin
-- Dan - Tra so ID tai dau qua so ID
select nvl(min(so_id_d),0) into b_so_idD from tbh_ghep where so_id=b_so_id;
return b_so_idD;
end;
/
create or replace function FTBH_GHEP_SO_CT_DAU(b_so_ct varchar2) return number
AS
    b_so_idD number;
begin
-- Dan - Tra so ID tai dau qua so_ct
select nvl(min(so_id_d),0) into b_so_idD from tbh_ghep where so_ct=b_so_ct;
return b_so_idD;
end;
/
create or replace function FTBH_GHEP_SO_ID_GOC(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_so_id_g number;
begin
--  Tra so ID goc qua so ID xu ly
select nvl(min(so_id_g),0) into b_so_id_g from tbh_ghep where so_id=b_so_id;
return b_so_id_g;
end;
/
create or replace function FTBH_GHEP_NGUON(b_so_id number,b_ngay number) return varchar2
AS
    b_so_id_bs number; b_nguon varchar2(1);
begin
b_so_id_bs:=FTBH_GHEP_SO_ID_BS(b_so_id,b_ngay);
select nvl(min(nguon),'B') into b_nguon from tbh_ghep where so_id=b_so_id_bs;
return b_nguon;
end;
/
create or replace function FTBH_GHEP_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
select min(nv) into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_GHEP_NGAY_XL(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay xu ly ghep
select nvl(min(ngay_ht),0) into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_GHEP_NGAY_HL(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay hieu luc ghep
select nvl(min(ngay_hl),0) into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_GHEP_NGAY_KT(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay ket thuc ghep
select nvl(min(ngay_kt),0) into b_kq from tbh_ghep where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FTBH_GHEP_NGAYk(b_so_id number,b_ngay number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Ktra trong khoang hieu luc
select count(*) into b_i1 from tbh_ghep where so_id=b_so_id and b_ngay between ngay_hl and ngay_kt;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FTBH_GHEP_NGAYc(b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Ngay doan cuoi
select nvl(max(ngay_hl),0) into b_kq from tbh_ghep_phi where so_id=b_so_id;
return b_kq;
end;
/

create or replace procedure FTBH_GHEP_NGAYf(
    b_so_id number,b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number)
AS
begin
-- Dan - Ngay hop dong tai
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0)
    into b_ngay_hl,b_ngay_kt from tbh_ghep where so_id=b_so_id;
b_ngay_ht:=FTBH_GHEP_NGAYc(b_so_id);
end;
/
create or replace procedure PTBH_GHEP_SO_ID_TA_DTd(
    b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,a_so_id_ta out pht_type.a_num)
AS
    b_so_idD number;
begin
-- Dan - Tra danh sach tai ghep dau
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
select so_id_d BULK COLLECT into a_so_id_ta from
    (select distinct a.so_id_d from tbh_ghep_hd b,tbh_ghep a where
    b.ma_dvi_hd=b_ma_dvi_hd and b.so_id_hd=b_so_idD and b_so_id_dt in(0,b.so_id_dt) and a.so_id=b.so_id);
end;
/
create or replace procedure PTBH_GHEP_SO_ID_TA_DT(
    b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,a_so_id_ta out pht_type.a_num,b_ngay number:=30000101)
AS
    b_i1 number;
begin
-- Dan - Tra danh sach tai ghep cuoi
PTBH_GHEP_SO_ID_TA_DTd(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,a_so_id_ta);
for b_lp in 1..a_so_id_ta.count loop
    select nvl(max(so_id),a_so_id_ta(b_lp)) into b_i1 from tbh_ghep where so_id_d=a_so_id_ta(b_lp) and ngay_ht<=b_ngay;
    a_so_id_ta(b_lp):=b_i1;
end loop;
end;
/
create or replace procedure PTBH_GHEP_SO_ID_TA_TL(
    b_ma_dvi varchar2,b_so_id number,a_pthuc out pht_type.a_var,a_ma_ta out pht_type.a_var,
    a_nha_bh out pht_type.a_var,a_pt out pht_type.a_num,a_tien out pht_type.a_num,b_ngay_xl number:=30000101)
AS
    b_ngay_hl number; b_so_idB number;
begin
-- Dan - Ty le tai cua 1 hop dong tai
b_so_idB:=FTBH_GHEP_SO_ID_BS(b_so_id,b_ngay_xl);
select nvl(max(ngay_hl),0) into b_ngay_hl from
    (select ngay_hl,pt from tbh_ghep_ky where so_id=b_so_idB) where ngay_hl<=b_ngay_xl;
select pthuc,ma_ta,nha_bhC,sum(pt),sum(tien) BULK COLLECT into a_pthuc,a_ma_ta,a_nha_bh,a_pt,a_tien from
    (select ngay_hl,pthuc,ma_ta,nha_bhC,tien,round(pt*ptt/100,4) pt from tbh_ghep_phi
    where so_id=b_so_idB and ngay_hl=b_ngay_hl and bt<100000)
    group by pthuc,ma_ta,nha_bhC;
end;
/
create or replace function FTBH_GHEP_TL(
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
for r_lp in (select distinct so_id from tbh_ghep_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD) loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_DAU(r_lp.so_id);
    if FKH_ARR_VTRI_N(a_so_id_ta,b_so_id_ta)<>0 then continue; end if;
    b_i1:=a_so_id_ta.count+1;
    a_so_id_ta(b_i1):=b_so_id_ta;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp),b_ngayC);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_ghep where so_id=b_so_id_ta;
    if b_ngayD<=b_ngay_kt and b_ngayC>=b_ngay_hl then
        select nvl(max(ngay_hl),0) into b_ngayT from tbh_ghep_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            lh_nv in(' ',b_lh_nv) and tien>0 and ngay_hl<=b_ngayD;
        if b_ngayT<>0 then
            select nvl(sum(pt),0) into b_i1 from tbh_ghep_pbo where so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and
                ngay_hl=b_ngayT and so_id_hd=b_so_id and lh_nv in(' ',b_lh_nv) and tien>0;
            b_kq:=b_kq+b_i1;
        end if;
    end if;
end loop;
return b_kq;
end;
/
create or replace function FTBH_GHEP_TL_DT(
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
for r_lp in (select distinct so_id from tbh_ghep_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in(0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_DAU(r_lp.so_id);
    if FKH_ARR_VTRI_N(a_so_id_ta,b_so_id_ta)<>0 then continue; end if;
    b_i1:=a_so_id_ta.count+1;
    a_so_id_ta(b_i1):=b_so_id_ta;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp),b_ngayC);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_ghep where so_id=b_so_id_ta;
    if b_ngayD<=b_ngay_kt and b_ngayC>=b_ngay_hl then
        select nvl(max(ngay_hl),0) into b_ngayT from tbh_ghep_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
             so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0 and ngay_hl<=b_ngayD;
        if b_ngayT<>0 then
            select nvl(sum(pt),0) into b_i1 from tbh_ghep_pbo where so_id=b_so_id_ta and
                ma_dvi_hd=b_ma_dvi and ngay_hl=b_ngayT and so_id_hd=b_so_id and
                so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0;
            b_kq:=b_kq+b_i1;
        end if;
    end if;
end loop;
return b_kq;
end;
/
create or replace procedure PTBH_GHEP_TL_DT(
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
for r_lp in (select distinct so_id from tbh_ghep_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in(0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_DAU(r_lp.so_id);
    if FKH_ARR_VTRI_N(a_so_id_ta,b_so_id_ta)<>0 then continue; end if;
    b_i1:=a_so_id_ta.count+1;
    a_so_id_ta(b_i1):=b_so_id_ta;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp),b_ngayC);
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from tbh_ghep where so_id=b_so_id_ta;
    if b_ngayD<=b_ngay_kt and b_ngayC>=b_ngay_hl then
        select nvl(max(ngay_hl),0) into b_ngayT from tbh_ghep_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt=b_so_id_dt and lh_nv in(' ',b_lh_nv) and tien>0 and ngay_hl<=b_ngayD;
        if b_ngayT<>0 then
            for r_lp in (select nha_bh,pt from tbh_ghep_pbo where
                so_id=b_so_id_ta and ngay_hl=b_ngayT and ma_dvi_hd=b_ma_dvi and
                so_id_hd=b_so_id and so_id_dt=b_so_id_dt and lh_nv in(' ',b_lh_nv) and tien>0) loop
                if FBH_DTAC_MA_NHOM(r_lp.nha_bh)='T' then b_tlT:=b_tlT+r_lp.pt; else b_tlN:=b_tlN+r_lp.pt; end if;
            end loop;
        end if;
    end if;
end loop;
end;
/
create or replace function FTBH_GHEP_HH_DT(
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
for r_lp in (select distinct so_id from tbh_ghep_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in (0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_DAU(r_lp.so_id); b_i1:=0;
    for b_lp in 1..a_so_id_ta.count loop
        if a_so_id_ta(b_lp)=b_so_id_ta then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_i1:=a_so_id_ta.count+1;
        a_so_id_ta(b_i1):=b_so_id_ta;
    end if;
end loop;
for b_lp in 1..a_so_id_ta.count loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp),b_ngayD);
    b_ngay_hl:=FTBH_HD_NGAY_HL('',b_so_id_ta); b_ngay_kt:=FTBH_HD_NGAY_KT('',b_so_id_ta);
    if b_ngayD between b_ngay_hl and b_ngay_hl then
        for r_lp in(select pt,pt_hh from tbh_ghep_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0) loop
            b_kq:=b_kq+round(b_phi*r_lp.pt*r_lp.pt_hh/10000,b_tp);
        end loop;
    end if;
end loop;
return b_kq;
end;
/
create or replace procedure PTBH_GHEP_HH_DT
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
for r_lp in (select distinct so_id from tbh_ghep_hd where
    ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD and so_id_dt in (0,b_so_id_dt)) loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_DAU(r_lp.so_id); b_i1:=0;
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
    b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp),b_ngayD);
    b_ngay_hl:=FTBH_HD_NGAY_HL('',b_so_id_ta); b_ngay_kt:=FTBH_HD_NGAY_KT('',b_so_id_ta);
    if b_ngayD between b_ngay_hl and b_ngay_hl then
        for r_lp in(select pt,pt_hh,nha_bh from tbh_ghep_pbo where
            so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id and
            so_id_dt in(0,b_so_id_dt) and lh_nv in(' ',b_lh_nv) and tien>0) loop
            b_i1:=round(b_phi*r_lp.pt*r_lp.pt_hh/10000,b_tp);
            if FBH_DTAC_MA_NHOM(r_lp.nha_bh)='T' then b_hhT:=b_hhT+b_i1; else b_hhN:=b_hhN+b_i1; end if;
        end loop;
    end if;
end loop;
end;
/
/*** GHEP HOP DONG ***/
create or replace procedure PTBH_GHEP_PHI(
    b_ma_dvi varchar2,b_ngay_xl number,b_ng_tai number,
    b_ngay_hl number,b_ngay_kt number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,a_ngay_hl pht_type.a_num,a_pthuc pht_type.a_var,
    a_ma_ta pht_type.a_var,a_pt pht_type.a_num,a_tien pht_type.a_num,a_phi pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number; b_so_id number; b_so_id_ta number;
    b_ttu varchar2(10):=' '; b_pt_phi number; b_mrr varchar2(10);
    b_tp_t number:=-2; b_tp_p number:=2; b_tien number; b_phi number;
    b_tl_thue number; b_thue number; b_ma_dt varchar2(10); b_nv varchar2(20);
    b_dk_lut varchar2(1):='K'; b_hs_lut number:=0;
    b_pt number; b_hh_nh number; b_pt_ll number; b_hh_ll number; b_hh_pt number;
    b_pt_c number; b_tien_c number; b_phi_c number; b_hh_xl number; b_hh_c number;
    b_pt_xl number; b_tien_xl number; b_phi_xl number;

    a_bh_nbh pht_type.a_var; a_bh_pt pht_type.a_num; a_bh_hh pht_type.a_num; a_bh_hh_ll pht_type.a_num;
begin
-- Dan - Tinh phi tai
delete tbh_ghep_phi_temp1; delete tbh_ghep_phi_temp2; delete tbh_ghep_phi_temp;
if b_nt_phi='VND' then b_tp_p:=0; end if;
b_nv:=FBH_HD_NV(a_ma_dvi(1),a_so_id(1));
b_ma_dt:=FTBH_MA_DT(b_ma_dvi,b_ngay_hl,a_ma_dvi,a_so_id,a_so_id_dt);
PTBH_DK_LUT(b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_dk_lut,b_hs_lut,b_ngay_hl);
PTBH_GHEP_NV(0,b_ngay_xl,b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
if b_loi is not null then return; end if;
insert into tbh_ghep_phi_temp2 select ma_ta,' ',sum(tien),' ',sum(phi) from tbh_ghep_nv_temp group by ma_ta;
for b_lp in 1..a_pthuc.count loop
    if a_ngay_hl(b_lp)=b_ngay_hl or a_phi(b_lp)<>0 then
        b_so_id_ta:=FTBH_DI_NV_SO_ID(b_ma_dvi,b_ng_tai,b_nv,a_pthuc(b_lp),a_ma_ta(b_lp));
        select nvl(min(tien),0),nvl(min(phi),0) into b_tien,b_phi from tbh_ghep_phi_temp2 where ma_ta=a_ma_ta(b_lp);
        if a_tien(b_lp)<>0 then b_tien:=a_tien(b_lp);
        else b_tien:=round(b_tien*a_pt(b_lp)/100,b_tp_t);
        end if;
        if a_phi(b_lp)<>0 then b_phi:=a_phi(b_lp);
        else
            b_phi:=round(b_phi*a_pt(b_lp)/100,b_tp_p);
        end if;
        if (b_phi<>0) then b_pt_phi:=b_phi*100/b_tien; else b_pt_phi:=0; end if;
        FTBH_HD_DI_HH(b_so_id_ta,a_ma_ta(b_lp),b_ma_dt,b_hh_pt,b_hh_ll);
        if b_dk_lut='C' then
            b_hh_c:=round(b_phi*(b_hh_pt*(100-b_hs_lut)+b_hh_ll*b_hs_lut)/10000,b_tp_p);
        else
            b_hh_c:=round(b_phi*b_hh_pt/100,b_tp_p);
        end if;
        b_pt_c:=a_pt(b_lp); b_tien_c:=b_tien; b_phi_c:=b_phi;
        select nha_bh,pt,hh,hh_ll bulk collect into a_bh_nbh,a_bh_pt,a_bh_hh,a_bh_hh_ll from tbh_hd_di_nha_bh where so_id=b_so_id_ta;
        b_i1:=a_bh_nbh.count; b_i2:=0;
        for b_lp1 in 1..b_i1 loop
            b_i2:=b_i2+a_bh_pt(b_lp1);
        end loop;
        for b_lp1 in 1..b_i1 loop
            if b_lp=b_i1 then
                b_pt_xl:=b_pt_c; b_tien_xl:=b_tien_c; b_phi_xl:=b_phi_c; b_hh_xl:=b_hh_c;
            else
                b_pt_xl:=round(a_pt(b_lp)*a_bh_pt(b_lp1)/b_i2,2);
                if abs(b_pt_xl)>abs(b_pt_c) then b_pt_xl:=b_pt_c; end if;
                b_tien_xl:=round(b_tien*a_bh_pt(b_lp1)/b_i2,b_tp_t);
                if abs(b_tien_xl)>abs(b_tien_c) then b_tien_xl:=b_tien_c; end if;
                b_phi_xl:=round(b_phi*a_bh_pt(b_lp1)/b_i2,b_tp_p);
                if abs(b_phi_xl)>abs(b_phi_c) then b_phi_xl:=b_phi_c; end if;
                b_hh_xl:=round(b_phi_xl*b_hh_pt/100,b_tp_p);
                if abs(b_hh_xl)>abs(b_hh_c) then b_hh_xl:=b_hh_c; end if;
                b_pt_c:=b_pt_c-b_pt_xl; b_tien_c:=b_tien_c-b_tien_xl; b_phi_c:=b_phi_c-b_phi_xl; b_hh_c:=b_hh_c-b_hh_xl;
            end if;
            if b_hh_pt=0 then
                if b_dk_lut='C' and b_pt_phi>b_hs_lut then
                    b_hh_xl:=round(b_phi_xl*(a_bh_hh_ll(b_lp1)*(b_pt_phi-b_hs_lut)/b_pt_phi+a_bh_hh_ll(b_lp1)*b_hs_lut/b_pt_phi)/100,b_tp_p);
                else
                    b_hh_xl:=round(b_phi_xl*a_bh_hh_ll(b_lp1)/100,b_tp_p);
                end if;
            end if;
            PTBH_PBO_NOP(a_ma_ta(b_lp),a_bh_nbh(b_lp1),b_ng_tai,b_phi_xl,b_tp_p,b_tl_thue,b_thue,b_loi);
            if b_loi is not null then return; end if;
            insert into tbh_ghep_phi_temp
                values(a_pthuc(b_lp),a_ma_ta(b_lp),a_bh_nbh(b_lp1),b_pt_xl,b_tien_xl,b_phi_xl,b_tl_thue,b_thue,b_hh_pt,b_hh_xl);
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_PHI:loi'; end if;
end;
/
create or replace procedure FTBH_GHEP_PBO_TL(
    b_ma_dvi varchar2,b_so_id number,
    a_ma_dvi out pht_type.a_var,a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,
    a_lh_nv out pht_type.a_var,a_tl out pht_type.a_num,b_loi out varchar2)
AS
    b_phi number:=0; a_phi pht_type.a_num;
begin
-- Dan - Tinh ty le phi
select * BULK COLLECT into a_ma_dvi,a_so_id,a_so_id_dt,a_lh_nv,a_phi from
    (select ma_dvi_hd,so_id_hd,so_id_dt,lh_nv,sum(phi) phi from tbh_ghep_pbo
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
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_GHEP_PBO_TL:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_TIEN_1(
    b_ma_dvi varchar2,b_ngay_ht number,b_ngay_hl number,b_ngayD number,b_so_id_psN number,b_klk varchar2,
    b_nt_ta varchar2,b_nt_phi varchar2,b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,b_loi out varchar2)
AS
    b_i1 number; b_nv varchar2(10); b_nt_tien_hd varchar2(5); b_nt_phi_hd varchar2(5); b_tg number:=0;
    b_so_idB number; b_so_idD number; b_so_id_ta number;
    b_so_id_taD number; a_so_id_tm pht_type.a_num; b_so_id_ps number:=0;
begin
-- Dan - Ghep nghiep vu BH => nghiep vu tai cho 1 hop dong
delete tbh_ghep_nv_temp1; delete tbh_ghep_nv_temp2; delete tbh_ghep_nv_temp3;
if b_klk<>'H' then b_so_id_ps:=b_so_id_psN; end if;
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi_hd,b_so_id_hd);
select nvl(min(nv),' '),max(so_id) into b_nv,b_so_idB from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
PBH_HD_DS_NV_BANG(b_ma_dvi,b_so_idB,b_so_id_dt,b_loi,'{"nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
insert into tbh_ghep_nv_temp1 select 0,'',lh_nv,nt_tien,tien,nt_phi,phi,0,0,0,0,0,0,0,0 from bh_hd_nv_temp;
if FBH_DONG(b_ma_dvi_hd,b_so_idD)<>'G' then
    insert into tbh_ghep_nv_temp1 select 0,'',a.lh_nv,a.nt_tien,0,a.nt_phi,0,0,
        sum(FBH_DONG_TL_TIEN(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a.lh_nv,a.tien)),0,0,0,0,0,0
        from bh_hd_nv_temp a group by a.lh_nv,a.nt_tien,a.nt_phi
        having max(FBH_DONG_TL_DT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a.lh_nv))<>100;
end if;
if FTBH_TMN(b_ma_dvi_hd,b_so_idD)='C' then
    insert into tbh_ghep_nv_temp1 select 0,'',a.lh_nv,a.nt_tien,0,a.nt_phi,0,0,0,0,0,0,0,0,
        sum(FTBH_TMN_TL_TIEN(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a.lh_nv,a.tien))
        from bh_hd_nv_temp a group by a.lh_nv,a.nt_tien,a.nt_phi having max(FTBH_TMN_TL_DT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a.lh_nv))<>100;
end if;
if b_so_id_ps<>0 then b_so_id_taD:=FTBH_GHEP_SO_ID_DAU(b_so_id_ps); else b_so_id_taD:=0; end if;
PTBH_GHEP_SO_ID_TA_DT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a_so_id_tm,b_ngay_ht);
for b_lp in 1..a_so_id_tm.count loop
    b_so_id_ta:=FTBH_GHEP_SO_ID_DAU(a_so_id_tm(b_lp));
    if b_klk in('H','N') or b_so_id_ta<>b_so_id_taD then
        if b_klk='N' and b_so_id_ps<>0 and b_so_id_ta=b_so_id_taD then
            b_so_id_ta:=FTBH_GHEP_SO_ID_GOC(b_ma_dvi,b_so_id_ps);
        else
            b_so_id_ta:=FTBH_GHEP_SO_ID_BS(a_so_id_tm(b_lp),b_ngay_ht);
        end if;
        if b_so_id_ta<>0 then
            insert into tbh_ghep_nv_temp1 select b_so_id_ta,'',lh_nv,nt_tien,0,nt_phi,0,0,0,tien,0,0,0,0,0 from
                (select * from tbh_ghep_pbo where so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi_hd and
                so_id_hd=b_so_idD and so_id_dt=b_so_id_dt and pt>0);
        end if;
    end if;
end loop;
if b_so_id_ps<>0 then b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_ps); else b_so_id_taD:=0; end if;
PTBH_TM_SO_ID_TA_DT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,b_ngay_ht,a_so_id_tm);
for b_lp in 1..a_so_id_tm.count loop
    b_so_id_ta:=FTBH_TM_SO_ID_DAU(a_so_id_tm(b_lp));
    if b_klk in('H','N') or b_so_id_ta<>b_so_id_taD then
        if b_klk='N' and b_so_id_ps<>0 and b_so_id_ta=b_so_id_taD then
            b_so_id_ta:=FTBH_TM_SO_ID_GOC(b_so_id_ps);
        else
            b_so_id_ta:=FTBH_TM_SO_ID_BS(a_so_id_tm(b_lp),b_ngay_ht);
        end if;
        if b_so_id_ta<>0 then
            insert into tbh_ghep_nv_temp1 select b_so_id_ta,'',lh_nv,nt_tien,0,nt_phi,0,0,0,0,tien,0,0,0,0 from
                (select * from tbh_tm_pbo where so_id=b_so_id_ta and ma_dvi_hd=b_ma_dvi_hd and
                so_id_hd=b_so_idD and so_id_dt=b_so_id_dt) where pt>0;
        end if;
    end if;
end loop;
update tbh_ghep_nv_temp1 set ma_ta=FBH_MA_LHNV_TAI(lh_nv);
delete tbh_ghep_nv_temp1 where trim(ma_ta) is null;
update tbh_ghep_nv_temp1 set
    tien=FBH_TT_TUNG_QD(b_ngayD,nt_tien,tien,b_nt_ta),
    do_tien=FBH_TT_TUNG_QD(b_ngayD,nt_tien,do_tien,b_nt_ta),
    ta_tien=FBH_TT_TUNG_QD(b_ngayD,nt_tien,ta_tien,b_nt_ta) where nt_tien<>b_nt_ta;
--if FBH_HD_NV(b_ma_dvi_hd,b_so_id_hd)='HANG' then
--    FBH_HH_HD_TG(b_ma_dvi_hd,b_so_idB,b_nt_tien_hd,b_nt_phi_hd,b_tg);
 --   if b_nt_phi_hd=b_nt_phi or b_nt_phi_hd<>'VND' then b_tg:=0; end if;
--end if;
if b_tg=0 then
    update tbh_ghep_nv_temp1 set phi=FBH_TT_TUNG_QD(b_ngayD,nt_phi,phi,b_nt_phi) where nt_phi<>b_nt_phi;
else
    update tbh_ghep_nv_temp1 set phi=round(phi/b_tg,2) where nt_phi<>b_nt_phi;
end if;
insert into tbh_ghep_nv_temp2
    select ma_ta,b_nt_ta,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),sum(ta_tl),sum(ta_tien),0,0,0,0
    from tbh_ghep_nv_temp1 group by ma_ta;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_TIEN_1:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_GHEP_TIEN(
    b_ma_dvi varchar2,b_ngay_ht number,b_ngay_hl number,
    b_so_id_ps number,b_klk varchar2,b_nt_ta varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,b_loi out varchar2)
AS
     b_ngayD number;
begin
-- Dan - Ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_nv_temp2; delete tbh_ghep_nv_temp;
b_ngayD:=FBH_HD_NGAYD_ARR(a_ma_dvi,a_so_id);
for b_lp in 1..a_ma_dvi.count loop
    PTBH_GHEP_TIEN_1(b_ma_dvi,b_ngay_ht,b_ngay_hl,b_ngayD,b_so_id_ps,b_klk,
        b_nt_ta,b_nt_phi,a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
insert into tbh_ghep_nv_temp select ma_ta,b_nt_ta,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),
    sum(ta_tl),sum(ta_tien),0,0,0,0 from tbh_ghep_nv_temp2 group by ma_ta;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_TIEN:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_DOAN(
    b_ma_dvi varchar2,b_nv varchar2,b_so_ct varchar2,b_ng_xl number,b_ngay_hl number,b_ngay_kt number,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,a_ng_hl out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_kt number:=0;
    b_ng_hl number; b_ng_kt number; b_so_idG number; b_so_idD number;
    a_n pht_type.a_num;
begin
-- Dan - Tim doan hieu luc hop dong khi ghep rui ro
b_loi:='loi:Loi xu ly PTBH_GHEP_DOAN:loi';
PKH_MANG_KD_N(a_ng_hl);
for b_lp in 1..a_ma_dvi.count loop
    PBH_HD_NGAY_HLDT(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ng_xl,b_ng_hl,b_ng_kt);
    if b_ng_hl between b_ngay_hl and b_ngay_kt and FKH_ARR_TIM_N(a_ng_hl,b_ng_hl)<>'C' then
        b_kt:=b_kt+1; a_ng_hl(b_kt):=b_ng_hl;
    end if;
    b_ng_kt:=PKH_NG_CSO(PKH_SO_CDT(b_ng_kt)+1);
    if b_ng_kt>=b_ngay_hl and b_ng_kt<b_ngay_kt and FKH_ARR_TIM_N(a_ng_hl,b_ng_kt)<>'C' then
        b_kt:=b_kt+1; a_ng_hl(b_kt):=b_ng_kt;
    end if;
end loop;
for b_lp in 1..a_ma_dvi.count loop
    b_i1:=0; b_i2:=b_lp-1;
    for b_lp1 in 1..b_i2 loop
        if a_so_id(b_lp)=a_so_id(b_lp1) then b_i1:=1; exit; end if;
    end loop;
    if b_i1=0 then
        b_so_idD:=FBH_HD_SO_ID_DAU(a_ma_dvi(b_lp),a_so_id(b_lp));
        for r_lp in (select ngay_ht from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_id_d=b_so_idD and
            ttrang='D' and kieu_hd in('B','S') and ngay_ht<=b_ng_xl) loop
            b_i1:=r_lp.ngay_ht;
            if b_i1>=b_ngay_hl and b_i1<b_ngay_kt and FKH_ARR_TIM_N(a_ng_hl,b_i1)<>'C' then
                b_kt:=b_kt+1; a_ng_hl(b_kt):=b_i1;
            end if;
        end loop;
    end if;
end loop;
PKH_ARR_XEP_N(a_ng_hl);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PTBH_GHEP_DOANt(
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_ng_hl out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_kt number:=0; b_so_idD number;
begin
-- Dan - Tim doan toan bo
PKH_MANG_KD_N(a_ng_hl);
for b_lp in 1..a_ma_dvi.count loop
    b_so_idD:=FBH_HD_SO_ID_DAU(a_ma_dvi(b_lp),a_so_id(b_lp));
    for r_lp in(select distinct ngay_cap,ngay_hl,ngay_kt from bh_hd_goc
        where ma_dvi=a_ma_dvi(b_lp) and so_id_d=b_so_idD and ttrang='D') loop
        if FKH_ARR_VTRI_N(a_ng_hl,r_lp.ngay_cap)=0 then
            b_kt:=b_kt+1; a_ng_hl(b_kt):=r_lp.ngay_cap;
        end if;
        if r_lp.ngay_hl<>r_lp.ngay_cap and FKH_ARR_VTRI_N(a_ng_hl,r_lp.ngay_hl)=0 then
            b_kt:=b_kt+1; a_ng_hl(b_kt):=r_lp.ngay_hl;
        end if;
        if r_lp.ngay_kt not in(r_lp.ngay_hl,r_lp.ngay_cap) and FKH_ARR_VTRI_N(a_ng_hl,r_lp.ngay_kt)=0 then
            b_kt:=b_kt+1; a_ng_hl(b_kt):=r_lp.ngay_kt;
        end if;
    end loop;
end loop;
if a_ng_hl.count<>0 then PKH_ARR_XEP_N(a_ng_hl); end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_DOAN:loi'; end if;
end;
/
create or replace procedure FTBH_DK_LUT(
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_dk_lut out varchar2,b_hs_lut out number,b_ngay number:=30000101)
AS
    b_kq varchar2(10):=' '; b_mrr varchar2(10);
begin
-- Dan - Tra muc rui ro cao nhat cua doi tuong
for b_lp in 1..a_ma_dvi.count loop
    PBH_HD_DK_LUT(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ngay,b_dk_lut,b_hs_lut);
end loop;
end;
/
create or replace procedure PTBH_GHEP_CBI(
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number;
begin
-- Dan - Tinh lai chuan bi sau khi ghep
for b_lp in 1..a_ma_dvi.count loop
    b_i1:=0;
    if b_lp>1 then
        b_i2:=b_lp-1;
        for b_lp1 in 1..b_i2 loop
            if a_ma_dvi(b_lp1)=a_ma_dvi(b_lp) and a_so_id(b_lp1)=a_so_id(b_lp) then b_i1:=1; exit; end if;
        end loop;
    end if;
    if b_i1=0 then
        PTBH_CBI_NH(a_ma_dvi(b_lp),a_so_id(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_CBI:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_PBO(
    b_so_id_ta number,b_ngay_ht number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    a_so_id_ta pht_type.a_num,a_pthuc pht_type.a_var,a_ngay_hl pht_type.a_num,
    a_ma_ta pht_type.a_var,a_pt pht_type.a_num,a_tien pht_type.a_num,a_phi pht_type.a_num,
    a_tl_thue pht_type.a_num,a_thue pht_type.a_num,a_pt_hh pht_type.a_num,a_hhong pht_type.a_num,
    a_nha_bh pht_type.a_var,a_kieu pht_type.a_var,a_nha_bhC pht_type.a_var,b_loi out varchar2)
AS
    b_i1 number; b_so_idD number; b_so_idB number;
    b_ma_ta varchar2(10); b_ma_nt varchar2(5);
    b_tpT number; b_tpP number; b_nv varchar2(10);
    b_tien number; b_phi number; b_hhong number; b_thue number;
    b_kt number:=0; b_ktT number; b_ktP number; b_ktH number; b_ktC number;
    b_tienC number; b_phiC number; b_hhongC number; b_thueC number;
    b_tienM number; b_phiM number; b_hhongM number; b_thueM number;
    b_so_id_taD number:=FTBH_GHEP_SO_ID_DAU(b_so_id_ta);
begin
-- Dan - Tinh phan bo phi
delete tbh_ghep_pbo_temp;
for b_lp1 in 1..a_ma_ta.count loop
    b_ktT:=0; b_ktP:=0; b_ktH:=0; b_ktC:=0;
    b_tienC:=a_tien(b_lp1); b_phiC:=a_phi(b_lp1); b_hhongC:=a_hhong(b_lp1); b_thueC:=a_thue(b_lp1);
    b_tienM:=0; b_phiM:=0; b_hhongM:=0; b_thueM:=0;
    for b_lp in 1..a_ma_dvi.count loop
        b_so_idD:=FBH_HD_SO_ID_DAU(a_ma_dvi(b_lp),a_so_id(b_lp));
        if b_so_idD=0 then continue; end if;
        select nvl(min(nv),' '),max(so_id) into b_nv,b_so_idB from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_id_d=b_so_idD;
        PBH_HD_DS_NV_BANG(a_ma_dvi(b_lp),b_so_idB,a_so_id_dt(b_lp),b_loi,'{"nv":"'||b_nv||'"}');
        if b_loi is not null then return; end if;
        for r_lp in (select lh_nv,nt_tien,sum(tien) tien,nt_phi,sum(phi) phi from bh_hd_nv_temp
            where a_ma_ta(b_lp1)=' ' or FBH_MA_LHNV_TAI(lh_nv)=a_ma_ta(b_lp1) group by lh_nv,nt_tien,nt_phi) loop
            if r_lp.nt_tien<>'VND' then b_tpT:=2; else b_tpT:=0; end if;
            if r_lp.nt_phi<>'VND' then b_tpP:=2; else b_tpP:=0; end if;
            b_tien:=round(r_lp.tien*a_pt(b_lp1)/100,b_tpT);
            b_phi:=round(r_lp.phi*a_pt(b_lp1)/100,b_tpP);
            b_hhong:=round(b_phi*a_pt_hh(b_lp1)/100,b_tpP);
            b_thue:=round((b_phi-b_hhong)*a_tl_thue(b_lp1)/100,b_tpP);
            if a_ma_ta(b_lp1)<>' ' then b_ma_ta:=a_ma_ta(b_lp1); else b_ma_ta:=FBH_MA_LHNV_TAI(r_lp.lh_nv); end if;
            b_kt:=b_kt+1;
            insert into tbh_ghep_pbo_temp values(
                a_ngay_hl(b_lp1),b_so_id_taD,a_so_id_ta(b_lp1),a_ma_dvi(b_lp),b_so_idD,a_so_id_dt(b_lp),
                a_nha_bh(b_lp1),a_kieu(b_lp1),a_nha_bhC(b_lp1),b_ma_ta,r_lp.lh_nv,a_so_id_ta(b_lp1),
                a_pthuc(b_lp1),a_pt(b_lp1),r_lp.nt_tien,b_tien,r_lp.nt_phi,b_phi,b_hhong,b_thue,b_kt);
            if r_lp.nt_tien<>b_nt_tien then
                b_tien:=FBH_TT_TUNG_QD(b_ngay_ht,r_lp.nt_tien,b_tien,b_nt_tien);
            end if;
            if r_lp.nt_phi<>b_nt_phi then
                b_phi:=FBH_TT_TUNG_QD(b_ngay_ht,r_lp.nt_phi,b_phi,b_nt_phi);
                b_hhong:=FBH_TT_TUNG_QD(b_ngay_ht,r_lp.nt_phi,b_hhong,b_nt_phi);
                b_thue:=FBH_TT_TUNG_QD(b_ngay_ht,r_lp.nt_phi,b_thue,b_nt_phi);
            end if;
            if b_ktT=0 or abs(b_tienM)<abs(b_tien) then b_tienM:=b_tien; b_ktT:=b_kt; end if;
            if b_ktP=0 or abs(b_phiM)<abs(b_phi) then b_phiM:=b_phi; b_ktP:=b_kt; end if;
            if b_ktH=0 or abs(b_hhongM)<abs(b_hhong) then b_hhongM:=b_hhong; b_ktH:=b_kt; end if;
            if b_ktC=0 or abs(b_thueM)<abs(b_thue) then b_thueM:=b_thue; b_ktC:=b_kt; end if;
            b_tienC:=b_tienC-b_tien; b_phiC:=b_phiC-b_phi; b_hhongC:=b_hhongC-b_hhong; b_thueC:=b_thueC-b_thue;
        end loop;
    end loop;
    if b_tienC<>0 then
        select nt_tien into b_ma_nt from tbh_ghep_pbo_temp where bt=b_ktT;
        b_tienC:=FBH_TT_TUNG_QD(b_ngay_ht,b_nt_tien,b_tienC,b_ma_nt);
        update tbh_ghep_pbo_temp set tien=tien+b_tienC where bt=b_ktT;
    end if;
    if b_phiC<>0 then
        select nt_phi into b_ma_nt from tbh_ghep_pbo_temp where bt=b_ktP;
        b_phiC:=FBH_TT_TUNG_QD(b_ngay_ht,b_nt_phi,b_phiC,b_ma_nt);
        update tbh_ghep_pbo_temp set phi=phi+b_phiC where bt=b_ktP;
    end if;
    if b_hhongC<>0 then
        select nt_phi into b_ma_nt from tbh_ghep_pbo_temp where bt=b_ktH;
        b_hhongC:=FBH_TT_TUNG_QD(b_ngay_ht,b_nt_phi,b_hhongC,b_ma_nt);
        update tbh_ghep_pbo_temp set hhong=hhong+b_hhongC where bt=b_ktH;
    end if;
    if b_thueC<>0 then
        select nt_phi into b_ma_nt from tbh_ghep_pbo_temp where bt=b_ktC;
        b_thueC:=FBH_TT_TUNG_QD(b_ngay_ht,b_nt_phi,b_thueC,b_ma_nt);
        update tbh_ghep_pbo_temp set thue=thue+b_thueC where bt=b_ktC;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_PBO:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NV_TIEN(
    b_ngay_ht number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_tien out number,b_phi out number,b_loi out varchar2,b_tso varchar2:=' ')
AS
    b_i1 number; b_so_idD number; b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tinh tong tien, phi
delete bh_hd_nv_temp; delete bh_hd_nv_tong_temp1; delete bh_hd_nv_tong_temp2;
b_nv:=FKH_JS_GTRIs(b_tso,'nv');
for b_lp in 1..a_ma_dvi.count loop
    b_so_idD:=FBH_HD_SO_ID_DAU(a_ma_dvi(b_lp),a_so_id(b_lp));
    if b_so_idD=0 then continue; end if;
    select nvl(min(nv),b_nv),max(so_id) into b_nv,b_so_idB from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_id_d=b_so_idD;
    PBH_HD_DS_NV_BANG(a_ma_dvi(b_lp),b_so_idB,a_so_id_dt(b_lp),b_loi,'{"nv":"'||b_nv||'"}');
    if b_loi is not null then return; end if;
    insert into bh_hd_nv_tong_temp1 select nt_tien,sum(tien),nt_phi,sum(phi) from bh_hd_nv_temp group by nt_tien,nt_phi;
end loop;
insert into bh_hd_nv_tong_temp2 select nt_tien,sum(tien),nt_phi,sum(phi) from bh_hd_nv_tong_temp1 group by nt_tien,nt_phi;
update bh_hd_nv_tong_temp2 set tien=FBH_TT_TUNG_QD(b_ngay_ht,nt_tien,tien,b_nt_tien) where nt_tien<>b_nt_tien;
update bh_hd_nv_tong_temp2 set phi=FBH_TT_TUNG_QD(b_ngay_ht,nt_phi,phi,b_nt_phi) where nt_phi<>b_nt_phi;
select nvl(sum(tien),0),nvl(sum(phi),0) into b_tien,b_phi from bh_hd_nv_tong_temp2;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NV_TIEN:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NV_1(
    b_so_id_ta number,b_ngay_ht number,b_ngay_hl number,b_nt_tien varchar2,b_nt_phi varchar2,
    b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,b_loi out varchar2,b_tso varchar2:=' ')
AS
    b_i1 number; b_nt_tien_hd varchar2(5); b_ma_ta varchar2(10); b_kieu_ps varchar2(1):='H';
    b_so_idD number; b_so_idB number; b_ng_ht number; b_ng_hl number; b_ng_kt number;
    b_tpT number:=0; b_tpP number:=0; b_tg number;
    b_so_id_taB number; b_so_id_taD number:=0; b_so_id_hd_ta number;
    b_loc varchar2(1); b_ttrang varchar(1); b_xly varchar(1); b_mata varchar(1); b_nv varchar2(10);
    a_so_id_ta pht_type.a_num;
begin
-- Dan - Ghep nghiep vu BH => nghiep vu tai cho 1 hop dong
if nvl(trim(b_tso),' ')<>' ' then
    b_loc:=FKH_JS_GTRIs(b_tso,'loc'); b_ttrang:=FKH_JS_GTRIs(b_tso,'ttrang','D');
    b_xly:=FKH_JS_GTRIs(b_tso,'xly'); b_mata:=FKH_JS_GTRIs(b_tso,'mata','C'); b_nv:=FKH_JS_GTRIs(b_tso,'nv');
end if;
delete bh_hd_nv_temp; delete tbh_ghep_nv_temp1; delete tbh_ghep_nv_temp3;
select nvl(min(so_id_d),0),nvl(min(nv),b_nv) into b_so_idD,b_nv
    from bh_hd_goc where ma_dvi=b_ma_dvi_hd and so_id=b_so_id_hd;
if b_so_idD=0 then
    b_so_idD:=FTBH_SOAN_SO_IDd(b_ma_dvi_hd,b_so_id_hd,b_nv);
    if b_so_idD=0 then
        if FKH_JS_GTRIs(b_tso,'kieu_ps')<>'B' then b_loi:='loi:Hop dong da xoa:loi'; return; end if;
        b_kieu_ps:='B'; b_so_idD:=b_so_id_hd;
    end if;
    b_so_idB:=b_so_id_hd; 
else
    if b_ttrang='D' then
        b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi_hd,b_so_idD,b_ngay_ht);
    else
        b_so_idB:=FBH_HD_SO_ID_BSt(b_ma_dvi_hd,b_so_idD);
    end if;
end if;
if b_kieu_ps='B' then
    PBH_HD_NV_DK( b_ma_dvi_hd,b_so_idB,b_so_id_dt,b_loi);
else
    PBH_HD_DS_NV_BANG(b_ma_dvi_hd,b_so_idB,b_so_id_dt,b_loi,b_tso);
end if;
if b_loi is not null then return; end if;
select count(*) into b_i1 from bh_hd_nv_temp;
if b_i1=0 then b_loi:=''; return; end if;
if FBH_DONG(b_ma_dvi_hd,b_so_idD)<>'G' then
    insert into tbh_ghep_nv_temp1 select 0,'',a.lh_nv,a.nt_tien,0,a.nt_phi,0,0,
        sum(FBH_DONG_TL_TIEN(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a.lh_nv,a.tien)),0,0,0,0,0,0
        from bh_hd_nv_temp a group by a.lh_nv,a.nt_tien,a.nt_phi;
end if;
if FTBH_TMN(b_ma_dvi_hd,b_so_idD)='C' then
    insert into tbh_ghep_nv_temp1 select 0,'',a.lh_nv,a.nt_tien,0,a.nt_phi,0,0,0,0,0,0,0,0,
        sum(FTBH_TMN_TL_TIEN(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a.lh_nv,a.tien))
        from bh_hd_nv_temp a group by a.lh_nv,a.nt_tien,a.nt_phi;
end if;
delete tbh_ghep_nv_temp1 where do_tien=0 and ve_tien=0;
insert into tbh_ghep_nv_temp1 select 0,'',lh_nv,nt_tien,tien,nt_phi,phi,0,0,0,0,0,0,0,0 from bh_hd_nv_temp;
if b_xly=' ' and (b_loc=' ' or instr(b_loc,'C')>0) then
    if b_so_id_ta<>0 then b_so_id_taD:=FTBH_GHEP_SO_ID_BS(b_so_id_ta,b_ngay_ht); end if;
    PTBH_GHEP_SO_ID_TA_DT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,a_so_id_ta,b_ngay_ht);
    for b_lp in 1..a_so_id_ta.count loop
        b_so_id_taB:=FTBH_GHEP_SO_ID_BS(a_so_id_ta(b_lp),b_ngay_ht);
        if b_so_id_taB=b_so_id_taD then continue; end if;
        FTBH_GHEP_NGAYf(b_so_id_taB,b_ng_ht,b_ng_hl,b_ng_kt);
        if b_ngay_hl between b_ng_hl and b_ng_kt then
            for r_lp in(select * from bh_hd_nv_temp) loop
                select nvl(sum(pt),0),min(so_id_ta_hd) into b_i1,b_so_id_hd_ta
                    from tbh_ghep_pbo where so_id=b_so_id_taB and ngay_hl=b_ng_ht and ma_dvi_hd=b_ma_dvi_hd and
                    so_id_hd=b_so_idD and so_id_dt in(0,b_so_id_dt) and tien>0 and lh_nv=r_lp.lh_nv;
                if b_i1<>0 then
                    b_i1:=round(r_lp.tien*b_i1/100,b_tpT);
                    insert into tbh_ghep_nv_temp1 values (b_so_id_hd_ta,'',r_lp.lh_nv,r_lp.nt_tien,0,r_lp.nt_phi,0,0,0,0,b_i1,0,0,0,0);
                end if;
            end loop;
        end if;
    end loop;
end if;
if b_xly<>' ' or b_loc=' ' or instr(b_loc,'F')>0 then
    if b_so_id_ta<>0 then b_so_id_taD:=FTBH_TM_SO_ID_DAU(b_so_id_ta,'C'); end if;
    PTBH_TM_SO_ID_TA_DT(b_ma_dvi_hd,b_so_idD,b_so_id_dt,b_ngay_ht,a_so_id_ta);
    for b_lp in 1..a_so_id_ta.count loop
        b_so_id_taB:=FTBH_TM_SO_ID_BS(a_so_id_ta(b_lp),b_ngay_ht);
        b_i1:=FTBH_TM_SO_ID_DAU(a_so_id_ta(b_lp),'C');
        if b_i1=b_so_id_taD or FTBH_TM_TXT(b_so_id_taB,'tcd')='C' then continue; end if;
        FTBH_TM_NGAYf(b_so_id_taB,b_ng_ht,b_ng_hl,b_ng_kt);
        if b_ngay_hl between b_ng_hl and b_ng_kt then
            for r_lp in(select * from bh_hd_nv_temp) loop
                select nvl(sum(pt),0),min(so_id_hd_ta) into b_i1,b_so_id_hd_ta
                    from tbh_tm_pbo where so_id=b_so_id_taB and ma_dvi_hd=b_ma_dvi_hd and
                    so_id_hd=b_so_idD and so_id_dt in(0,b_so_id_dt) and tien>0 and lh_nv=r_lp.lh_nv;
                if b_i1<>0 then
                    b_i1:=round(r_lp.tien*b_i1/100,b_tpT);
                    insert into tbh_ghep_nv_temp1 values (b_so_id_hd_ta,'',r_lp.lh_nv,r_lp.nt_tien,0,r_lp.nt_phi,0,0,0,0,b_i1,0,0,0,0);
                end if;
            end loop;
        end if;
    end loop;
end if;
if b_mata<>'C' then
    update tbh_ghep_nv_temp1 set ma_ta=lh_nv;
else
    update tbh_ghep_nv_temp1 set ma_ta=FBH_MA_LHNV_TAI(lh_nv);
end if;
delete tbh_ghep_nv_temp1 where trim(ma_ta) is null;
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
for r_lp in (select distinct nt_tien from tbh_ghep_nv_temp1 where nt_tien<>b_nt_tien) loop
    b_tg:=FBH_TT_TGTT_TUNG(b_ngay_ht,r_lp.nt_tien,b_nt_tien);
    update tbh_ghep_nv_temp1 set
        tien=round(tien*b_tg,b_tpT),do_tien=round(do_tien*b_tg,b_tpT),
        ta_tien=round(ta_tien*b_tg,b_tpT),ve_tien=round(ve_tien*b_tg,b_tpT)
        where nt_tien=r_lp.nt_tien;
end loop;
update tbh_ghep_nv_temp1 set phi=FBH_TT_TUNG_QD(b_ngay_ht,nt_phi,phi,b_nt_phi) where nt_phi<>b_nt_phi;
insert into tbh_ghep_nv_temp3
    select so_id,ma_ta,b_nt_tien,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp1 group by so_id,ma_ta;
insert into tbh_ghep_nv_temp2
    select ma_ta,b_nt_tien,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp3 group by ma_ta having sum(tien)<>0;
delete tbh_ghep_nv_temp1; delete tbh_ghep_nv_temp3;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NV_1:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_GHEP_NV(
    b_so_id_ta number,b_ngay_ht number,b_ngay_hl number,b_nt_ta varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_loi out varchar2,b_tso varchar2:=' ')
AS
    b_i1 number;
    a_ma_taC pht_type.a_var; a_ptC pht_type.a_num; a_tienC pht_type.a_num;
    a_ma_ta pht_type.a_var; a_tien pht_type.a_num; a_phi pht_type.a_num;
    a_do_tl pht_type.a_num; a_ta_tl pht_type.a_num;
    a_tm_tl pht_type.a_num; a_ve_tl pht_type.a_num;
    a_do_tien pht_type.a_num; a_ta_tien pht_type.a_num;
    a_tm_tien pht_type.a_num; a_ve_tien pht_type.a_num;
begin
-- Dan - Ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp2;
for b_lp in 1..a_ma_dvi.count loop
    PTBH_GHEP_NV_1(b_so_id_ta,b_ngay_ht,b_ngay_hl,b_nt_ta,b_nt_phi,
        a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_loi,b_tso);
    if b_loi is not null then return; end if;
end loop;
insert into tbh_ghep_nv_temp
    select ma_ta,b_nt_ta,sum(tien),b_nt_phi,sum(phi),0,sum(do_tien),
    0,sum(ta_tien),0,sum(tm_tien),0,sum(ve_tien)
    from tbh_ghep_nv_temp2 group by ma_ta having sum(tien)<>0;
update tbh_ghep_nv_temp set
    do_tl=round(do_tien*100/tien,2),ta_tl=round(ta_tien*100/tien,2),
    tm_tl=round(tm_tien*100/tien,2),ve_tl=round(ve_tien*100/tien,2);
select ma_ta,tien,phi,do_tien,do_tl,ta_tien,ta_tl,tm_tien,tm_tl,ve_tien,ve_tl BULK COLLECT into
    a_ma_ta,a_tien,a_phi,a_do_tien,a_do_tl,a_ta_tien,a_ta_tl,a_tm_tien,a_tm_tl,a_ve_tien,a_ve_tl
    from tbh_ghep_nv_temp order by ma_ta;
for b_lp in 1..a_ma_ta.count loop
    if a_do_tien(b_lp)<>0 then
        a_ptC(b_lp):=100-a_do_tl(b_lp)+a_ve_tl(b_lp);
        a_tienC(b_lp):=a_tien(b_lp)-a_do_tien(b_lp)+a_ve_tien(b_lp);
    elsif a_ve_tien(b_lp)<>0 then
        a_ptC(b_lp):=a_ve_tl(b_lp); a_tienC(b_lp):=a_ve_tien(b_lp);
    else
        a_ptC(b_lp):=100; a_tienC(b_lp):=a_tien(b_lp);
    end if;
    a_ptC(b_lp):=a_ptC(b_lp)-a_ta_tl(b_lp)-a_tm_tl(b_lp);
    a_tienC(b_lp):=a_tienC(b_lp)-a_ta_tien(b_lp)-a_tm_tien(b_lp);
    insert into tbh_ghep_nv_temp0 values(a_ma_ta(b_lp),a_tien(b_lp),a_phi(b_lp),a_ptC(b_lp),a_tienC(b_lp),
        a_ta_tl(b_lp),a_ta_tien(b_lp),a_do_tl(b_lp),a_do_tien(b_lp),a_ta_tl(b_lp),a_ta_tien(b_lp),
        a_tm_tl(b_lp),a_tm_tien(b_lp),a_ve_tl(b_lp),a_ve_tien(b_lp),a_ptC(b_lp),a_tienC(b_lp));
end loop;
delete tbh_ghep_nv_temp2;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NV:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_TL(
    b_so_id_ta number,b_ngay_ht number,b_ngay_hl number,
    b_nv varchar2,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_loi out varchar2,b_tsoN varchar2:=' ')
AS
    b_tp number:=0; b_pt number; b_ma_dt varchar2(10); b_tbo varchar2(1);
    b_tlbt number; b_ptG number; b_hsng number; b_i1 number; b_uot varchar2(1):='K';
    b_tien number; b_nguong number; b_glai number; b_ghan number; b_tlp number;
    b_so_id_giu number; b_cdt varchar2(10):=' '; b_glaiM varchar2(1):=' '; b_tso varchar2(200):=b_tsoN;

    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_pp pht_type.a_var;
    a_ma_ta pht_type.a_var; a_pt_c pht_type.a_num;
    a_tien_c pht_type.a_num; a_tien_g pht_type.a_num; a_phi_g pht_type.a_num;
    a_do_tl pht_type.a_num; a_ta_tl pht_type.a_num; a_tm_tl pht_type.a_num; a_ve_tl pht_type.a_num;
    a_do_tien pht_type.a_num; a_ta_tien pht_type.a_num; a_tm_tien pht_type.a_num; a_ve_tien pht_type.a_num;
    a_lh_nvX pht_type.a_var; a_tuX pht_type.a_num; a_denX pht_type.a_num; a_tienX pht_type.a_num;
begin
-- Dan - Tinh phan bo ty le tai
delete tbh_ghep_tl_temp;
if nvl(trim(b_tso),' ')<>' ' then b_glaiM:=FKH_JS_GTRIs(b_tso,'glaim',' '); end if;
if b_nt_tien<>'VND' then b_tp:=2; end if;
if b_nv='PKT' then b_uot:=FBH_PKT_DK_UOTn(a_ma_dvi,a_so_id,a_so_id_dt); end if;
PKH_JS_THAY(b_tso,'nv',b_nv);
b_ma_dt:=FBH_MRR_DT(b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_ngay_ht);
if a_ma_dvi.count=1 then
    b_cdt:=FTBH_SOANd_TXT(a_ma_dvi(1),a_so_id(1),a_so_id_dt(1),'cdt',b_tso);
end if;
PTBH_GHEP_NV(b_so_id_ta,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_tso);
if b_loi is not null then return; end if;
select ma_ta,tien,phi,do_tien,do_tl,ta_tien,ta_tl,tm_tien,tm_tl,ve_tien,ve_tl,pt_con,tien_con BULK COLLECT into
    a_ma_ta,a_tien_g,a_phi_g,a_do_tien,a_do_tl,a_ta_tien,a_ta_tl,
    a_tm_tien,a_tm_tl,a_ve_tien,a_ve_tl,a_pt_c,a_tien_c from tbh_ghep_nv_temp0 order by ma_ta;
if b_cdt=' ' or instr(b_cdt,'C')<>0 then
    for b_lp in 1..a_ma_ta.count loop
        FTBH_HD_DI_NV_SO_ID(b_nv,a_ma_ta(b_lp),b_ma_dt,b_ngay_hl,a_so_id_ta,a_pthuc,a_pp,b_loi);
        if b_loi is not null then return; end if;
        for b_ta in 1..a_so_id_ta.count loop
            if a_pt_c(b_lp)<.01 then continue; end if;
            FTBH_HD_DI_GLAI('',a_so_id_ta(b_ta),a_ma_ta(b_lp),b_ma_dt,1,
                b_nt_tien,a_do_tl(b_lp),a_ve_tl(b_lp),b_ngay_hl,b_nguong,b_glai,b_ghan,b_tlp,b_loi,b_glaiM,b_uot);
            if b_loi is not null then return; end if;
            if b_nv='PHH' and a_tien_g(b_lp)<>0 then
                FBH_PHH_TLBT(a_ma_dvi,a_so_id,a_so_id_dt,a_ma_ta(b_lp),b_tlbt,b_ptG);
                FTBH_HD_DI_HSNG(a_so_id_ta(b_ta),b_nt_tien,b_ngay_hl,b_ma_dt,a_tien_g(b_lp),b_tlbt,b_ptG,b_hsng,b_loi);
                if b_loi is not null then return; end if;
                b_nguong:=b_nguong*b_hsng/100;
            end if;
            if b_nguong<0 or b_nguong>a_tien_c(b_lp) or (b_glai>100 and b_glai>=a_tien_c(b_lp)) then
                a_pt_c(b_lp):=0; a_tien_c(b_lp):=0;
            else
                if a_pp(b_ta)='Q' then
                    b_tbo:=nvl(trim(FTBH_HD_DI_TXT(a_so_id_ta(b_ta),'tbo')),'C');
                    if b_tbo='T' then
                        if b_glai<>0 and b_glai<=100 then
                            b_pt:=100-b_glai;
                        else
                            b_pt:=100-trunc(b_glai*100/a_tien_g(b_lp),4);
                        end if;
                    else
                        if b_glai<>0 and b_glai<=100 then
                            b_pt:=trunc((100-b_glai)*a_pt_c(b_lp)/100,4);
                        else
                            b_pt:=100-trunc(b_glai*100/a_tien_c(b_lp),4);
                        end if;
                    end if;
                elsif b_glai<>0 and b_glai<=100 then
                    b_pt:=(100-b_glai);
                    if a_pt_c(b_lp)<>100 then b_pt:=trunc(b_pt*a_pt_c(b_lp)/100,4); end if;
                else
                    b_tien:=a_tien_c(b_lp)-b_glai; b_pt:=trunc(b_tien*100/a_tien_g(b_lp),4);
                end if;
                if b_ghan<>0 and b_ghan<=100 and b_ghan<b_pt then b_pt:=b_ghan; end if;
                b_tien:=trunc(a_tien_g(b_lp)*b_pt/100,b_tp);
                if b_ghan>100 and b_ghan<b_tien then
                    b_tien:=b_ghan; b_pt:=trunc(b_tien*100/a_tien_g(b_lp),4);
                end if;
                if b_pt>a_pt_c(b_lp) then b_pt:=a_pt_c(b_lp); b_tien:=a_tien_c(b_lp); end if;
                if b_pt>0 then
                    a_pt_c(b_lp):=a_pt_c(b_lp)-b_pt; a_tien_c(b_lp):=a_tien_c(b_lp)-b_tien;
                    insert into tbh_ghep_tl_temp values(
                        a_so_id_ta(b_ta),a_pp(b_ta),a_ma_ta(b_lp),b_pt,b_tien,b_tlp,a_tien_g(b_lp),a_phi_g(b_lp));
                end if;
            end if;
        end loop;
    end loop;
end if;
if b_cdt=' ' or instr(b_cdt,'F')<>0 then
    b_so_id_giu:=FTBH_MGIU_SO_ID(b_nv,b_ngay_hl);
    if b_so_id_giu=0 then b_loi:=''; return; end if;
    for b_lp in 1..a_ma_ta.count loop
        b_glai:=FTBH_MGIU_GLAI('',b_so_id_giu,a_ma_ta(b_lp),b_ma_dt,b_nt_tien,a_do_tl(b_lp),a_tm_tl(b_lp),b_ngay_hl);
        if b_glai<>0 and ((b_glai>100 and a_tien_c(b_lp)>b_glai) or (b_glai<100 and a_pt_c(b_lp)>b_glai)) then
            if b_glai<=100 then
                b_pt:=b_glai;
                b_tien:=trunc(a_tien_g(b_lp)*b_glai/100,b_tp); 
            else
                b_tien:=b_glai; b_pt:=trunc(b_tien*100/a_tien_g(b_lp),4);
                if b_pt>a_pt_c(b_lp) then b_pt:=a_pt_c(b_lp); b_tien:=a_tien_c(b_lp); end if;
            end if;
            a_pt_c(b_lp):=a_pt_c(b_lp)-b_pt; a_tien_c(b_lp):=a_tien_c(b_lp)-b_tien;
            if a_pt_c(b_lp)>.01 then
                insert into tbh_ghep_tl_temp values(0,'O',a_ma_ta(b_lp),a_pt_c(b_lp),a_tien_c(b_lp),0,a_tien_g(b_lp),a_phi_g(b_lp));
            end if;
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_TL:loi'; end if;
end;
/
create or replace procedure FTBH_GHEP_NH_PHI(dt_ct clob,dt_hd clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; b_tso varchar2(100);
    b_kt number; b_glaiM varchar2(1);  b_tpT number:=0; b_tpP number:=0;
    b_ngD number; b_ngC number; b_nv varchar2(10); b_so_ctG varchar2(20);
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number;
    b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    b_tien number; b_tienT number; b_phi number; b_phiT number; b_pt number;
    b_hhong number; b_tl_thue number; b_thue number;
    b_so_hd_ta varchar2(20); b_vt number; b_pt_con number; b_tien_con number;
    b_kho number; b_khoH number; b_khoC number; b_khoCl number;
    
    dk_ma_taC pht_type.a_var; dk_tienC pht_type.a_num;
    dk_ma_taD pht_type.a_var; dk_phiD pht_type.a_num;
    dk_ma_ta pht_type.a_var; dk_tien pht_type.a_num; dk_phi pht_type.a_num; dk_tl pht_type.a_num;
    a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var; a_so_id pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_ng_hl pht_type.a_num; a_so_idB pht_type.a_num;
    a_so_id_ta pht_type.a_num; a_pthuc pht_type.a_var; a_ma_ta pht_type.a_var;
    a_pt pht_type.a_num; a_tien pht_type.a_num; a_tlp pht_type.a_num;
    a_tienG pht_type.a_num; a_phiG pht_type.a_num;

begin
-- Dan - Tinh phi phan doan
delete tbh_ghep_tl_temp; delete tbh_ghep_nv_temp; delete tbh_ghep_nv_temp0;
delete tbh_ghep_tl_temp5; delete tbh_ghep_tl_temp6; delete tbh_ghep_tl_temp7;
b_lenh:=FKH_JS_LENH('nv,ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi,so_ctg,glai');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_ctG,b_glaiM using dt_ct;
b_lenh:=FKH_JS_LENH('ma_dvi_hd,so_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_dvi,a_so_hd,a_so_id_dt using dt_hd;
if a_ma_dvi.count=0 then b_loi:='loi:Nhap hop dong tai:loi'; return; end if;
b_glaiM:=nvl(trim(b_glaiM),'K');
if b_nt_tien<>'VND' then b_tpT:=2; end if;
if b_nt_phi<>'VND' then b_tpP:=2; end if;
for b_lp in 1..a_ma_dvi.count loop
    a_so_id(b_lp):=FBH_HD_GOC_SO_ID_DAU(a_ma_dvi(b_lp),a_so_hd(b_lp));
end loop;
FBH_HD_NGAYh_ARR(a_ma_dvi,a_so_id,b_ngD,b_ngC);
if b_ngay_kt in(0,30000101) then b_ngay_kt:=b_ngC; end if;
if b_ngay_hl in(0,30000101) then b_ngay_hl:=b_ngD; end if;
if b_ngay_kt in(0,30000101) then b_ngay_kt:=b_ngC; end if;
PTBH_GHEP_DOANt(a_ma_dvi,a_so_id,a_ng_hl,b_loi);
if b_loi is not null then return; end if;
b_kt:=a_ng_hl.count;
while b_kt<2 loop
    b_kt:=b_kt+1; a_ng_hl(b_kt):=b_ngay_hl;
end loop;
PTBH_GHEP_NV(0,a_ng_hl(b_kt),b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,'{"nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
select ma_ta,tien bulk collect into dk_ma_taC,dk_tienC from tbh_ghep_nv_temp where tien<>0;
PKH_MANG_KD(dk_ma_taD); PKH_MANG_KD_N(dk_phiD);
b_khoH:=FKH_KHO_NGSO(a_ng_hl(1),a_ng_hl(b_kt));
if b_khoH=0 then b_khoH:=1; end if;
b_khoC:=b_khoH;
b_kt:=b_kt-1;
b_tso:='{"ttrang":"D","xly":"C","glaim":"'||b_glaiM||'"}';
for b_lp in 1..b_kt loop
    delete tbh_ghep_tl_temp;
    if a_ng_hl(b_lp) not between b_ngay_hl and b_ngay_kt then continue; end if;
    PTBH_GHEP_TL(0,a_ng_hl(b_lp),b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_tso);
    if b_loi is not null then return; end if;    
    select ma_ta,tien,phi bulk collect into dk_ma_ta,dk_tien,dk_phi from tbh_ghep_nv_temp where tien<>0;
    b_kho:=FKH_KHO_NGSO(a_ng_hl(b_lp),a_ng_hl(b_lp+1));
    b_khoCl:=round(b_khoH/b_khoC,2);
    b_khoC:=b_khoC-b_kho; b_kho:=round(b_kho/b_khoH,2);
    for b_lp1 in 1..dk_ma_ta.count loop
        b_vt:=FKH_ARR_VTRI(dk_ma_taD,dk_ma_ta(b_lp1));
        if b_vt=0 then
            b_phi:=dk_phi(b_lp1);
            b_vt:=dk_ma_taD.count+1; dk_ma_taD(b_vt):=dk_ma_ta(b_lp1); dk_phiD(b_vt):=0;
        else
            b_phi:=dk_phi(b_lp1)-dk_phiD(b_vt);
        end if;
        b_phi:=round(b_phi*b_khoCl,0);
        if dk_tien(b_lp1)=0 then dk_tl(b_lp1):=0;
        else dk_tl(b_lp1):=round(b_phi*100/dk_tien(b_lp1),4);
        end if;
        dk_phiD(b_vt):=dk_phiD(b_vt)+round(b_phi*b_kho,b_tpP);
    end loop;
    select so_id_ta,pthuc,ma_ta,pt,tien,tlp,tu,den bulk collect into
        a_so_id_ta,a_pthuc,a_ma_ta,a_pt,a_tien,a_tlp,a_tienG,a_phiG
        from tbh_ghep_tl_temp where pthuc in('Q','S');
    if a_pthuc.count=0 then continue; end if;
    for b_lp1 in 1..a_pthuc.count loop
        b_so_hd_ta:=FTBH_HD_DI_SO_HD(a_so_id_ta(b_lp1))||'('||a_pthuc(b_lp1)||')';
        b_vt:=FKH_ARR_VTRI(dk_ma_ta,a_ma_ta(b_lp1));
        if b_vt<>0 and a_tlp(b_lp1)<dk_tl(b_vt) then
            b_i1:=dk_tl(b_vt);
        else
            b_i1:=a_tlp(b_lp1);
        end if;
        b_tienT:=a_tien(b_lp1);
        b_phiT:=round(b_i1*b_kho*b_tienT/100,b_tpP);
        insert into tbh_ghep_tl_temp7 values(
            a_ng_hl(b_lp),a_so_id_ta(b_lp1),b_so_hd_ta,a_pthuc(b_lp1),a_ma_ta(b_lp1),a_pt(b_lp1),b_tienT,b_phiT);
        for r_lp in(select * from tbh_hd_di_nha_bh where so_id=a_so_id_ta(b_lp1) order by bt) loop
            b_tien:=round(b_tienT*r_lp.pt/100,b_tpT);
            b_phi:=round(b_phiT*r_lp.pt/100,b_tpP);
            b_hhong:=round(b_phi*r_lp.hh/100,b_tpP);
            if dk_tien(b_vt)=0 then b_pt:=0;
            else b_pt:=round(b_tien*100/dk_tien(b_vt),2);
            end if;
            PTBH_PBO_NOP(a_ma_ta(b_lp1),r_lp.nha_bh,b_ngay_hl,b_phi,b_tpP,b_tl_thue,b_thue,b_loi);
            if b_loi is not null then return; end if;
            insert into tbh_ghep_tl_temp5 values(
                a_ng_hl(b_lp),a_so_id_ta(b_lp1),b_so_hd_ta,a_pthuc(b_lp1),a_ma_ta(b_lp1),
                a_tienG(b_lp1),a_phiG(b_lp1),a_pt(b_lp1),b_tienT,b_phiT,r_lp.nha_bh,r_lp.nha_bhC,
                r_lp.kieu,r_lp.pt,b_pt,b_tien,b_phi,r_lp.hh,b_hhong,b_tl_thue,b_thue);
        end loop;
    end loop;
end loop;
b_i1:=a_ng_hl(b_kt);
insert into tbh_ghep_tl_temp6 select so_id_ta,so_hd_ta,ma_ta,nbh,nbhC,kieu,0,
    sum(decode(ngay,b_i1,tien,0)),sum(phi),0,sum(hhong),0,sum(thue)
    from tbh_ghep_tl_temp5 group by so_id_ta,so_hd_ta,ma_ta,nbh,nbhC,kieu;
for b_lp in 1..dk_ma_taC.count loop
    update tbh_ghep_tl_temp6 set
        pt=decode(dk_tienC(b_lp),0,0,round(tien*100/dk_tienC(b_lp),2)),
        pt_hh=decode(phi,0,0,round(hhong*100/phi,2)),
        tl_thue=decode(phi,0,0,round(thue*100/phi,2)) where ma_ta=dk_ma_taC(b_lp);
end loop;
delete tbh_ghep_tl_temp;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_GHEP_NH_PHI:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_PHI_D(
    b_ma_dvi varchar2,b_so_id_ps number,b_nv varchar2,b_ngay_ht number,b_ngay_hl number,
    b_ngay_kt number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    a_ngay_hl pht_type.a_num,a_so_id_ta pht_type.a_num,a_pthuc pht_type.a_var,
    a_ma_ta pht_type.a_var,a_pt pht_type.a_num,a_tien pht_type.a_num,
    a_tlp pht_type.a_num,a_phi pht_type.a_num,
    a_ma_dviQ pht_type.a_var,a_so_idQ pht_type.a_num,a_so_id_dtQ pht_type.a_num,
    a_so_id_taQ pht_type.a_num,a_pthucQ pht_type.a_var,
    a_ma_taQ pht_type.a_var,a_phiQ in out pht_type.a_num,
    b_loi out varchar2,b_cbi varchar2:='K')
AS
    b_i1 number; b_i2 number; b_kt number; b_ngQ number; b_pt_phi number; b_ngD number;
    b_tp_t number:=-2; b_tp_p number:=2; b_tien number; b_phi number; b_phil number; b_btQ number;
    b_tl_thue number; b_thue number;
    b_dk_lut varchar2(1):='K'; b_hs_lut number:=0; b_pt number; b_pt_ll number;
    b_ttien number; b_tphi number; b_tphil number;
    a_nghl pht_type.a_num; a_ngkt pht_type.a_num;
begin
-- Dan - Tinh phi doan
if b_nt_phi='VND' then b_tp_p:=0; end if;
PTBH_DK_LUT(b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_dk_lut,b_hs_lut,b_ngay_hl);
for b_lp in 1..a_ma_dvi.count loop
    PBH_HD_NGAY_HLDT(a_ma_dvi(b_lp),a_so_id(b_lp),a_so_id_dt(b_lp),b_ngay_hl,a_nghl(b_lp),a_ngkt(b_lp));
end loop;
for b_lp in 1..a_pthuc.count loop
    b_ttien:=0; b_tphi:=0; b_tphil:=0;
    b_ngQ:=0; b_ngD:=b_ngay_kt;
    for b_lp1 in 1..a_pthuc.count loop
        if a_so_id_ta(b_lp1)=a_so_id_ta(b_lp) and a_pthuc(b_lp1)=a_pthuc(b_lp) and a_ma_ta(b_lp1)=a_ma_ta(b_lp) then
            if a_ngay_hl(b_lp1)>a_ngay_hl(b_lp) and a_ngay_hl(b_lp1)<b_ngD then
                b_ngD:=FKH_TD_NGSO(a_ngay_hl(b_lp1),-1);
            end if;
            if a_ngay_hl(b_lp1)<a_ngay_hl(b_lp) then b_ngQ:=a_ngay_hl(b_lp); end if;
        end if;
    end loop;
    for b_lp_dt in 1..a_ma_dvi.count loop
        delete tbh_ghep_phi_temp2; delete tbh_ghep_nv_temp2;
        PTBH_GHEP_NV_1(b_ngay_ht,a_ngay_hl(b_lp),b_so_id_ps,
            b_nt_tien,b_nt_phi,a_ma_dvi(b_lp_dt),a_so_id(b_lp_dt),a_so_id_dt(b_lp_dt),b_loi,'{"nv":"'||b_nv||'"}');
        if b_loi is not null then return; end if;
        select nvl(min(tien),0),nvl(min(phi),0) into b_tien,b_phi from tbh_ghep_nv_temp2 where ma_ta=a_ma_ta(b_lp);
        if b_tien=0 then continue; end if;
        if a_tlp(b_lp)<>0 then
            b_i1:=round(b_tien*a_tlp(b_lp)/100,b_tp_p);
            if b_i1>b_phi then b_phi:=b_i1; end if;
        end if;
        if b_nv='HANG' then
            b_phi:=round(b_phi*a_pt(b_lp)/100,b_tp_p);
        else
            for b_lp1 in 1..a_ma_dviQ.count loop
                if a_ma_dviQ(b_lp1)=a_ma_dvi(b_lp_dt) and a_so_idQ(b_lp1)=a_so_id(b_lp_dt) and
                    a_so_id_dtQ(b_lp1)=a_so_id_dt(b_lp_dt) and a_so_id_taQ(b_lp1)=a_so_id_ta(b_lp) and 
                    a_pthucQ(b_lp1)=a_pthuc(b_lp) and a_ma_taQ(b_lp1)=a_ma_ta(b_lp) then
                    b_btQ:=b_lp1; exit;
                end if;
            end loop;
            b_i1:=b_phi-a_phiQ(b_btQ);
            b_i2:=FTBH_HS_KHO(a_ngay_hl(b_lp),b_ngD,a_nghl(b_lp_dt),a_ngkt(b_lp_dt),b_ngQ);
            b_phi:=round(b_i1*b_i2*a_pt(b_lp)/100,b_tp_p);
            b_i2:=FTBH_HS_KHOh(a_ngay_hl(b_lp),b_ngD,a_nghl(b_lp_dt),a_ngkt(b_lp_dt),b_ngQ);
            a_phiQ(b_btQ):=a_phiQ(b_btQ)+round(b_i1*b_i2,b_tp_p);
        end if;
        if b_dk_lut='C' then
            b_phil:=round(b_phi*(100-b_hs_lut)/100,b_tp_p); b_phi:=b_phi-b_phil;
        else
            b_phil:=0;
        end if;
        b_ttien:=b_ttien+round(b_tien*a_pt(b_lp)/100,b_tp_t); b_tphi:=b_tphi+b_phi; b_tphil:=b_tphil+b_phil;
    end loop;
    if a_tien(b_lp)<>0 then b_tien:=a_tien(b_lp); else b_tien:=b_ttien; end if;
    if a_phi(b_lp)=0 then
        b_phi:=b_tphi; b_phil:=b_tphil;
    elsif b_tphil=0 then
        b_phi:=a_phi(b_lp); b_phil:=0;
    else
        b_phi:=round(b_tphi*a_phi(b_lp)/(b_tphi+b_tphil),b_tp_p); b_phil:=a_phi(b_lp)-b_phi;
    end if;
    insert into tbh_ghep_ky_phi_temp values(
        b_ngay_ht,a_so_id_ta(b_lp),a_pthuc(b_lp),a_ma_ta(b_lp),' ',
        a_pt(b_lp),b_tien,b_phi+b_phil,0,0,0,0);
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_PHI_D:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_TINH_PHI_D(
    b_ma_dvi varchar2,b_so_id_ps number,b_nv varchar2,
    b_ngay_ht number,b_ngay_hl number,b_ngay_kt number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    a_so_id_ta pht_type.a_num,a_pthuc in out pht_type.a_var,
    a_ma_ta pht_type.a_var,a_pt pht_type.a_num,a_tien pht_type.a_num,a_tlp pht_type.a_num,
    a_ma_dviQ pht_type.a_var,a_so_idQ pht_type.a_num,a_so_id_dtQ pht_type.a_num,
    a_so_id_taQ pht_type.a_num,a_pthucQ pht_type.a_var,a_ma_taQ pht_type.a_var,
    a_phiQ in out pht_type.a_num,b_loi out varchar2,b_cbi varchar2:='K')
AS
    b_i1 number; b_i2 number:=0; b_so_idG number:=0; b_kt number:=0;
    a_ngay_xl pht_type.a_num; a_so_id_ta_xl pht_type.a_num;
    a_pthuc_xl pht_type.a_var; a_ma_ta_xl pht_type.a_var;
    a_pt_xl pht_type.a_num; a_tien_xl pht_type.a_num;
    a_tlp_xl pht_type.a_num; a_phi_xl pht_type.a_num;
begin
-- Dan - Tinh phi doan
PKH_MANG(a_pthuc);
if a_pthuc.count>0 then
    if b_kt=0 then b_i1:=b_ngay_hl; else b_i1:=b_ngay_ht; end if;
    for b_lp in 1..a_pthuc.count loop
        b_kt:=b_kt+1;
        a_ngay_xl(b_kt):=b_i1; a_so_id_ta_xl(b_kt):=a_so_id_ta(b_lp);
        a_pthuc_xl(b_kt):=a_pthuc(b_lp); a_ma_ta_xl(b_kt):=a_ma_ta(b_lp);
        a_pt_xl(b_kt):=a_pt(b_lp); a_tien_xl(b_kt):=a_tien(b_lp); a_tlp_xl(b_kt):=a_tlp(b_lp);
    end loop;
end if;
if b_kt<>0 then
    for b_lp in 1..b_kt loop
        a_phi_xl(b_lp):=0;
    end loop;
end if;
PTBH_GHEP_PHI_D(b_ma_dvi,b_so_id_ps,b_nv,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,
    a_ma_dvi,a_so_id,a_so_id_dt,
    a_ngay_xl,a_so_id_ta_xl,a_pthuc_xl,a_ma_ta_xl,a_pt_xl,a_tien_xl,a_tlp_xl,a_phi_xl,
    a_ma_dviQ,a_so_idQ,a_so_id_dtQ,a_so_id_taQ,a_pthucQ,a_ma_taQ,a_phiQ,b_loi,b_cbi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_TINH_PHI_D:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_GHEP_CONk(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tso varchar2(100);
    b_so_hd varchar2(20); b_ngay_ht number; b_ngay_hl number; b_nv varchar2(10); b_so_idB number;
    a_so_id_dt pht_type.a_num;
    a_ma_dviT pht_type.a_var; a_so_idT pht_type.a_num; a_so_id_dtT pht_type.a_num;
    a_so_hdT pht_type.a_var; a_tenT pht_type.a_nvar; 
begin
-- Dan - Kiem tra con vuot tai
if FBH_HD_CO_TAM(b_ma_dvi,b_so_id)<>'C' then b_loi:=''; return; end if;
b_so_idB:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_id);
select so_hd,ngay_ht,ngay_hl,nt_tien,nt_phi,nv into b_so_hd,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,b_nv
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
-- nam
b_tso:='{"nv":"'||b_nv||'","kieu_ps":"H"}';
if b_nv<>'NG' then
    PBH_HD_DS_DT_ARR(b_ma_dvi,b_so_id,a_so_id_dt,b_nv);
else
    a_so_id_dt(1):=FTBH_BAO_NV_NGd(b_ma_dvi,b_so_idB);
    a_ma_dviT(1):=b_ma_dvi; a_so_idT(1):=b_so_id; a_so_id_dtT(1):=a_so_id_dt(1);
end if;
for b_lp in 1..a_so_id_dt.count loop
    if b_nv<>'NG' then
        PTBH_TMB_CBI_DT(b_nv,b_ma_dvi,b_so_id,a_so_id_dt(b_lp),a_ma_dviT,a_so_hdT,a_tenT,a_so_idT,a_so_id_dtT,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if a_ma_dviT.count=1 and FBH_HD_CDT(b_ma_dvi,b_so_id,a_so_id_dt(b_lp),'F',b_tso)<>'C' then continue; end if;
    PTBH_GHEP_TL(0,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dviT,a_so_idT,a_so_id_dtT,b_loi,'{"loc":"F"}');
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O' and pt>0;
    if b_i1<>0 then b_loi:='loi:Chua xu ly tai tam thoi:loi'; return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_CONk:loi'; end if;
end;
/
