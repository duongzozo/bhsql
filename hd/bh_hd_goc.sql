create or replace procedure FBH_HD_NGAYh_ARR(
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,
    b_ngay_hl out number,b_ngay_kt out number,b_ngay number:=30000101)
AS
    b_so_idB number; b_i1 number; b_i2 number;
begin
-- Dan - Xac dinh ngay hieu luc cho mang
b_ngay_hl:=30000101; b_ngay_kt:=0;
for b_lp in 1..a_ma_dvi.count loop
    b_so_idB:=FBH_HD_SO_ID_BS(a_ma_dvi(b_lp),a_so_id(b_lp),b_ngay);
    select nvl(min(ngay_hl),30000101),nvl(min(ngay_kt),0) into b_i1,b_i2
        from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and so_id=b_so_idB;
    if b_i1<b_ngay_hl then b_ngay_hl:=b_i1; end if;
    if b_i2>b_ngay_kt then b_ngay_kt:=b_i2; end if;
end loop;
end;
/
create or replace procedure PBH_HD_TTRANG_HD(b_ma_dvi varchar2,b_so_idN number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_nv varchar2(10);
    b_so_id number:=b_so_idN; b_i1 number; b_tt varchar2(1); b_thue varchar2(1); b_hhong varchar2(1);
begin
-- Dan - Trang thai hop dong
delete bh_hd_ttrang_temp; delete bh_hd_do_vat_temp1; delete bh_hd_do_vat_temp2; delete bh_hd_do_vat_temp3; commit;
b_so_id:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_idN);
b_tt:='X';
select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_tt:='D';
else
    select count(*) into b_i1 from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_tt:='V'; end if;
end if;
if b_tt<>'X' then insert into bh_hd_ttrang_temp values('tt_phi',b_tt); end if;
b_thue:='X'; b_hhong:='X';
for r_lp in(select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if b_thue='X' then
        select count(*) into b_i1 from bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt;
        if b_i1<>0 then b_thue:='D'; end if;
    end if;
    if b_hhong='X' then
        select count(*) into b_i1 from bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt;
        if b_i1<>0 then b_hhong:='D'; end if;
    end if;
end loop;
if b_thue<>'X' then insert into bh_hd_ttrang_temp values('tt_thue',b_thue); end if;
if b_hhong<>'X' then insert into bh_hd_ttrang_temp values('tt_hhong',b_hhong); end if;
if FBH_HD_HU(b_ma_dvi,b_so_id)='C' then
    insert into bh_hd_ttrang_temp values('hd_huy','D');
end if;
select count(*) into b_i1 from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tle','V'); end if;
if FBH_DONG(b_ma_dvi,b_so_id)<>'G' then
    select count(*) into b_i1 from bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tt','D'); end if;
    if FBH_HD_DO_VAT_TONh(b_ma_dvi,b_so_id)='C' then
        insert into bh_hd_ttrang_temp values('do_vat','D');
    end if;
end if;
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_hd=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('bt_hs','V'); end if;
select count(*) into b_i1 from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('bt_ho','V'); end if;
b_tt:=FTBH_TMC_CBI_TT(b_ma_dvi,b_so_id);
if b_tt<>'K' then
    insert into bh_hd_ttrang_temp values('ta_pbo',b_tt);
end if;
open cs1 for select * from bh_hd_ttrang_temp;
delete bh_hd_ttrang_temp; delete bh_hd_do_vat_temp1;
delete bh_hd_do_vat_temp2; delete bh_hd_do_vat_temp3; commit;
end;
/
create or replace procedure FBH_HD_SO_HD_BANG(b_so_hdN varchar2,b_ma_dvi out varchar2,b_so_id out number)
AS
    b_so_hd varchar2(50):=PKH_LOC_CHUi(b_so_hdN,'*+-/ _\');
begin
-- Dan - Hoi so hop dong co bang khong
select min(ma_dvi),nvl(min(so_id),0) into b_ma_dvi,b_so_id from bh_hd_goc where
    replace(replace(replace(replace(replace(replace(so_hd,'*',''),'+',''),'-',''),'/',''),'_',''),'_','')=b_so_hd and
    ttrang<>'D' and kieu_hd in('G','T');
end;
/
create or replace function FBH_HD_HOI_NOPHI(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_so_idD number; b_i1 number;
begin
-- Dan - Tra tinh trang no phi
if b_dk='C' then b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id); else b_so_idD:=b_so_id; end if;
select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_HD_HOI_NOPHIn(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_dk varchar2:='C') return varchar2
AS
    b_kq varchar2(1):='K'; b_so_idD number; b_ton number;
begin
-- Dan - Tra tinh trang no phi den ngay
if b_dk='C' then b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id); else b_so_idD:=b_so_id; end if;
for r_lp in (select ma_nt,max(ngay_ht) ngay_ht from bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_idD) loop
    select ton into b_ton from bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_idD and ma_nt=r_lp.ma_nt and ngay_ht=r_lp.ngay_ht;
    if b_ton<>0 then b_kq:='C'; exit; end if;
end loop;
return b_kq;
end;
/
create or replace function FBH_HD_HOI_THUE(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='0'; b_so_id_d number; b_i1 number; b_i2 number;
begin
-- Dan - Tra ten bang hop dong qua nghiep vu
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for r_lp in(select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select count(*) into b_i1 from bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt;
    if b_i1<>0 then b_kq:='1'; exit; end if;
end loop;
select nvl(sum(no_qd),0),nvl(sum(co_qd),0) into b_i1,b_i2 from bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id_d;
if b_i1=b_i2 then b_kq:='2';
elsif b_i2<>0 then b_kq:='1';
end if;
return b_kq;
end;
/
create or replace function FBH_HD_HLk(b_ma_dvi varchar2,b_so_id number,b_ngay number) return varchar2
AS
     b_kq varchar2(1):='K'; b_i1 number; b_so_id_bs number;
begin
-- Dan - Kiem tra ngay trong khoang hieu luc
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and b_ngay between ngay_hl and ngay_kt;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_HD_HL(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_id_bs number; b_ngay_hl number; b_ngay_kt number; b_kq varchar2(1):='K';
begin
-- Dan - Kiem tra hieu luc
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
if b_ngayd<=b_ngay_kt and b_ngay_hl<=b_ngayc then b_kq:='C'; end if;
return b_kq;
end;
/
/*** DOI SO HOP DONG ***/
create or replace function FBH_HD_GOC_BANG(b_nv varchar2) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra ten bang hop dong qua nghiep vu
if b_nv='XE' then b_kq:='bh_xe';
elsif b_nv='2B' then b_kq:='bh_2b';
elsif b_nv='TAU' then b_kq:='bh_tau';
elsif b_nv='PHH' then b_kq:='bh_phh';
elsif b_nv='PKT' then b_kq:='bh_pkt';
elsif b_nv='PTN' then b_kq:='bh_ptn';
elsif b_nv='NG' then b_kq:='bh_ng';
elsif b_nv='HANG' then b_kq:='bh_hang';
elsif b_nv='HOP' then b_kq:='bh_hop';
elsif b_nv='GOP' then b_kq:='bh_hop';
elsif b_nv='SK' then b_kq:='bh_sk';
elsif b_nv='NGDL' then b_kq:='bh_ngdl';
elsif b_nv='NGTD' then b_kq:='bh_ngtd';
-- nam
elsif b_nv='PTNCC' then b_kq:='bh_ptncc';
elsif b_nv='PTNNN' then b_kq:='bh_ptnnn';
elsif b_nv='PTNVC' then b_kq:='bh_ptnvc';
elsif b_nv='NONG' then b_kq:='bh_nong';
end if;
return b_kq;
end;
/
create or replace function FBH_HD_GOC_BANG_CT(b_nv varchar2) return varchar2
AS
    b_kq varchar2(50):='';
begin
-- Dan - Tra ten bang GCN qua nghiep vu
if b_nv='XE' then b_kq:='bh_xe';
elsif b_nv='2B' then b_kq:='bh_2b';
elsif b_nv='TAU' then b_kq:='bh_tau';
elsif b_nv='NG' then b_kq:='bh_ng';
elsif b_nv='PHH' then b_kq:='bh_phh';
elsif b_nv='PKT' then b_kq:='bh_pkt';
elsif b_nv='HANG' then b_kq:='bh_hang';
elsif b_nv='PTN' then b_kq:='bh_ptn';
elsif b_nv='HOP' then b_kq:='bh_hop';
elsif b_nv='NONG' then b_kq:='bh_nong';
end if;
return b_kq;
end;
/
create or replace function FBH_HD_GOC_BANG_DK(b_nv varchar2) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra ten bang dieu kien hop dong qua nghiep vu
if b_nv='XE' then b_kq:='bh_xe_dk';
elsif b_nv='2B' then b_kq:='bh_2b_dk';
elsif b_nv='TAU' then b_kq:='bh_tau_dk';
elsif b_nv='NG' then b_kq:='bh_ng_dk';
elsif b_nv='PHH' then b_kq:='bh_phh_dk';
elsif b_nv='PKT' then b_kq:='bh_pkt_dk';
elsif b_nv='HANG' then b_kq:='bh_hhgcn_dk';
elsif b_nv='PTN' then b_kq:='bh_ptngcn_dk';
elsif b_nv='HOP' then b_kq:='bh_hop_dk';
end if;
return b_kq;
end;
/
create or replace function FBH_HD_GOC_BANG_CT_DK(b_nv varchar2) return varchar2
AS
    b_kq varchar2(50):='';
begin
-- Dan - Tra ten bang GCN qua nghiep vu
if b_nv='XE' then b_kq:='bh_xe_dk';
elsif b_nv='2B' then b_kq:='bh_2b_dk';
elsif b_nv='TAU' then b_kq:='bh_tau_dk';
elsif b_nv='NG' then b_kq:='bh_ngu_dk';
elsif b_nv='PHH' then b_kq:='bh_phh_dk';
elsif b_nv='PKT' then b_kq:='bh_pkt_dk';
elsif b_nv='HANG' then b_kq:='bh_hhgcn_dk';
elsif b_nv='PTN' then b_kq:='bh_ptngcn_dk';
elsif b_nv='HOP' then b_kq:='bh_hop_dk';
end if;
return b_kq;
end;
/
create or replace function FBH_HD_MA_DVIh(b_so_hd varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh don vi
select nvl(min(ma_dvi),' ') into b_kq from bh_hd_goc where so_hd=b_so_hd;
return b_kq;
end;
/
create or replace function FBH_HD_MA_DVIi(b_so_id varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh don vi
select nvl(min(ma_dvi),' ') into b_kq from bh_hd_goc where so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_KIEU_HD(b_ma_dvi varchar2,b_so_id number,b_dk varchar2:='K') return varchar2
AS
    b_kq varchar2(1); b_so_idK number:=b_so_id;
begin
-- Dan - Xac dinh kieu hop dong
if b_dk='D' then b_so_idK:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id); end if;
select nvl(min(kieu_hd),' ') into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idK;
return b_kq;
end;
/
create or replace function FBH_HD_TIEN(b_ma_dvi varchar2,b_so_id number,b_ngay number) return number
AS
    b_so_id_bs number; b_tien number;
begin
-- Dan - Tra tong tien phi hop dong
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select nvl(sum(tien),0) into b_tien from bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return b_tien;
end;
/
create or replace function FBH_HD_TTOAN(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ps varchar2) return number
AS
    b_so_id_d number; b_ttoan number;
begin
-- Dan - Tra tong thanh toan hop dong
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
select nvl(sum(ttoan),0) into b_ttoan from (select pt,ttoan from bh_hd_goc_ttpt where
    ma_dvi=b_ma_dvi and so_id=b_so_id_d and ngay_ht<=b_ngay) where instr(b_ps,pt)>0;
return b_ttoan;
end;
/
create or replace procedure FBH_HD_TTOANF(b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ps varchar2,
    b_ttoan out number,b_ttoan_qd out number,b_thue out number,
    b_thue_qd out number,b_phi out number,b_phi_qd out number)
AS
    b_so_id_d number;
begin
-- Dan - Tra tong thanh toan hop dong
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
select nvl(sum(ttoan),0),nvl(sum(ttoan_qd),0),nvl(sum(thue),0),nvl(sum(thue_qd),0),nvl(sum(phi),0),nvl(sum(phi_qd),0)
    into b_ttoan,b_ttoan_qd,b_thue,b_thue_qd,b_phi,b_phi_qd
    from (select * from bh_hd_goc_ttpt where ma_dvi=b_ma_dvi and so_id=b_so_id_d and ngay_ht<=b_ngay) where instr(b_ps,pt)>0;
end;
/
create or replace function FBH_HD_MA_NT_TIEN(b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
AS
    b_so_id_bs number; b_ma_nt varchar2(5);
begin
-- Nampb - Tra loai tien hop dong
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_tien),'VND') into b_ma_nt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return b_ma_nt;
end;
/
create or replace function FBH_HD_MA_NT(b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return varchar2
AS
    b_so_id_bs number; b_ma_nt varchar2(5);
begin
-- Dan - Tra loai phi tien hop dong
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select nvl(min(nt_phi),'VND') into b_ma_nt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return b_ma_nt;
end;
/
create or replace procedure PBH_HD_NTE(b_ma_dvi varchar2,b_so_id number,b_nt_tien out varchar2,b_nt_phi out varchar2)
as
begin
select nvl(min(nt_tien),'VND'),nvl(min(nt_phi),'VND') into b_nt_tien,b_nt_phi from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id; 
end;
/
create or replace function FBH_HD_MA_KH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Xac dinh ma khach hang
select min(ma_kh) into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_LKH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20):='C'; b_ma_kh varchar2(20); b_bang varchar2(30); b_lenh varchar2(2000);
    b_nv varchar2(20); b_dvi varchar2(20):=FKH_NV_DVI(b_ma_dvi,'bh_hd_ma_kh');
begin
-- Dan - Xac dinh loai khach hang ca nhan hay doanh nghiep
b_ma_kh:=FBH_HD_MA_KH(b_ma_dvi,b_so_id);
if trim(b_ma_kh) is not null then
    select nvl(min(ma),'C') into b_kq from bh_hd_ma_kh where ma_dvi=b_dvi and ma=b_ma_kh;
    if b_kq<>'C' then
        b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
        if b_nv<>'2BL' then
            b_bang:=FBH_HD_GOC_BANG(b_nv);
            b_lenh:='select min(ng_mua) from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id';
            EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id;
            if trim(b_kq) is null then b_kq:='T'; end if;
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_KIEU_KT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Xac dinh kieu khai thac
select nvl(min(kieu_kt),'T') into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_MA_BP(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Xac dinh ma bo phan
select min(phong) into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_HD_MA_KT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,b_ma_kt out varchar2)
AS
begin
-- Dan - Xac dinh ma khai thac
select min(ma_kt) into b_ma_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
end;
/
create or replace function FBH_HD_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh nghiep vu
select min(nv) into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_PHONG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Xac dinh phong hop dong goc
select nvl(min(phong),' ') into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_GOC_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_hd varchar2(50);
begin
-- Dan - Tra so hop dong qua so ID
select min(so_hd) into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_hd;
end;
/
create or replace function FBH_HD_GOC_SO_HD_D(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_hd varchar2(50); b_so_id_d number;
begin
-- Dan - Tra so hop dong dau qua so ID
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
select min(so_hd) into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_d;
return b_so_hd;
end;
/
create or replace function FBH_HD_GOC_SO_HD_B(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number) return varchar2
AS
    b_so_hd varchar2(50); b_so_id_b number;
begin
-- Dan - Tra so hop dong bo sung cuoi qua so ID
b_so_id_b:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
select min(so_hd) into b_so_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_b;
return b_so_hd;
end;
/
create or replace function FBH_HD_SO_HD_NV(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_hd varchar2(20);
begin
-- Dan - Tra so hop dong theo loai
b_so_hd:=FBH_HD_GOC_SO_HD_D(b_ma_dvi,b_so_id);
return b_so_hd;
end;
/
create or replace function FBH_HD_GOC_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so hop dong
select nvl(min(so_id),0) into b_so_id from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_so_id;
end;
/
create or replace function FBH_HD_GOC_SO_IDd(b_ma_dvi varchar2,b_so_hd varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so hop dong
select nvl(min(so_id),0) into b_so_id from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd and ttrang='D';
return b_so_id;
end;
/
create or replace function FBH_HD_GOC_SO_ID_DAU(b_ma_dvi varchar2,b_so_hd varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Tra so ID qua so hop dong
select nvl(min(so_id_d),0) into b_so_id from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
return b_so_id;
end;
/
create or replace function FBH_HD_SO_ID_DAU(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Tra so ID dau qua so ID xu ly
select nvl(min(so_id_d),0) into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_SO_ID_BS(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number:=b_so_id;
begin
-- Dan - Tra so ID bo sung qua so ID
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select nvl(max(so_id),0) into b_kq from bh_hd_goc
        where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay_ht;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_SO_ID_BSt(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number:=b_so_id;
begin
-- Dan - Tra so ID bo sung qua so ID
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select nvl(max(so_id),b_so_id) into b_kq from bh_hd_goc
        where ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang in('T','D') and ngay_ht<=b_ngay_ht;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_SO_ID_BSd(
    b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_idD number; b_kq number:=0;
begin
-- Dan - Tra so ID bo sung qua so ID        -- Da duyet
b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if b_so_idD<>0 then
    select nvl(max(so_id),0) into b_kq from bh_hd_goc where
        ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D' and ngay_ht<=b_ngay_ht;
    if b_kq=0 then
        select nvl(min(so_id),0) into b_kq from bh_hd_goc where
            ma_dvi=b_ma_dvi and so_id_d=b_so_idD and ttrang='D';
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_SO_HD_BS(b_ma_dvi varchar2,b_so_hd varchar2,b_ngay_ht number:=30000101) return number
AS
    b_so_id_bs number:=0; b_so_id number;
begin
-- Dan - Tra so ID bo sung qua so hop dong
b_so_id:=FBH_HD_GOC_SO_ID(b_ma_dvi,b_so_hd);
if b_so_id<>0 then b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht); end if;
return b_so_id_bs;
end;
/
create or replace procedure PBH_HD_GOC_SO_HD_BS(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_so_hd varchar2,b_ngay_ht number,b_so_hd_bs out varchar2)
AS
    b_so_id number:=0; b_so_id_bs number:=0;
begin
-- Quy - Tra so hop dong bo sung cuoi qua so hop dong
b_so_id:=FBH_HD_SO_HD_BS(b_ma_dvi,b_so_hd,b_ngay_ht);
b_so_hd_bs:=FBH_HD_GOC_SO_HD(b_ma_dvi,b_so_id);
end;
/
create or replace function FBH_HD_GOC_SO_HD_GOC(b_ma_dvi varchar2,b_so_id number,b_nv varchar2) return varchar2
AS
    b_kq varchar2(20); b_lenh varchar2(1000);
begin
-- Dan - Tra hop dong goc theo nghiep vu
b_lenh:='select min(so_hd_g) from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id;
return nvl(trim(b_kq),' ');
end;
/
create or replace function FBH_HD_SO_ID_GOC(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_so_id_g number;
begin
-- Dan - Tra so ID goc qua so ID xu ly
select nvl(min(so_id_g),0) into b_so_id_g from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_so_id_g;
end;
/
create or replace function FBH_HD_GOC_NGAYb(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number; b_so_idB number;
begin
-- Dan - Tra ngay bo sung cuoi
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
select nvl(min(ngay_ht),0) into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_HD_SO_ID_TRUOC(b_ma_dvi varchar2,b_so_id number,b_so_id_d out number,b_so_id_g out number)
AS
begin
-- Dan - Tra so ID dau,so ID goc qua so ID
select nvl(min(so_id_d),0),nvl(min(so_id_g),0) into b_so_id_d,b_so_id_g from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace function FBH_HD_TTRANG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra tinh trang
select nvl(min(ttrang),' ') into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kq='D' and FBH_HD_HU(b_ma_dvi,b_so_id)='C' then b_kq:='H'; end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_SO_HD_NV(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_hd varchar2,b_nv out varchar2)
AS
begin
-- Dan - Xac dinh nghiep vu
select min(nv) into b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
end;
/
create or replace procedure PBH_HD_SO_ID_NV(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_nv out varchar2)
AS
begin
-- Dan - Xac dinh nghiep vu
select min(nv) into b_nv from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace function FBH_HD_NGAY(b_ma_dvi varchar,b_so_id number) return number
AS
    b_ngay_ht number;
begin
-- Dan - Tra ngay nhap hop dong
select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_ngay_ht;
end;
/
create or replace function FBH_HD_NGAYD(b_ma_dvi varchar,b_so_id number) return number
AS
    b_ngay_ht number; b_so_id_d number;
begin
-- Dan - Tra ngay dau hop dong
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
select nvl(min(ngay_ht),0) into b_ngay_ht from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_d;
return b_ngay_ht;
end;
/
create or replace function FBH_HD_NGAYD_ARR(a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num) return number
AS
    b_kq number:=30000101; b_so_id number; b_i1 number;
begin
-- Dan - Xac dinh ngay dau cho mang
for b_lp in 1..a_ma_dvi.count loop
    b_i1:=FBH_HD_NGAYD(a_ma_dvi(b_lp),a_so_id(b_lp));
    if b_i1<b_kq then b_kq:=b_i1; end if;
end loop;
return b_kq;
end;
/
create or replace function FBH_HD_NGAY_BS(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number:=30000101) return number
AS
    b_so_id_bs number; b_ngay_bs number;
begin
-- Dan - Tra so ngay bo sung qua so ID
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
select nvl(min(ngay_ht),0) into b_ngay_bs from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return b_ngay_bs;
end;
/
create or replace function FBH_HD_NGAY_DAU(b_ma_dvi varchar2,b_so_hd varchar2,b_ngay_ht number) return number
AS
    b_so_id_d number; b_kq number;
begin
-- Dan - Tra ngay dau
b_kq:=b_ngay_ht;
if b_so_hd is not null then
    select nvl(min(so_id_d),0) into b_so_id_d from bh_hd_goc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
    if b_so_id_d<>0 then b_kq:=FBH_HD_NGAY(b_ma_dvi,b_so_id_d); end if;
end if;
return b_kq;
end;
/
create or replace function FBH_HD_NGAY_HUY(b_ma_dvi varchar2,b_so_id_d number) return number
AS
    b_kq number;
begin
-- Dan - Tra ngay huy
select nvl(min(ngay_ht),0) into b_kq from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id_d;
return b_kq;
end;
/
create or replace function FBH_HD_NGCAP_ARR(a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num) return number
AS
    b_kq number:=30000101; b_so_id number; b_i1 number;
begin
-- Dan - Xac dinh ngay cap dang number cho mang
for b_lp in 1..a_ma_dvi.count loop
    b_so_id:=FBH_HD_SO_ID_DAU(a_ma_dvi(b_lp),a_so_id(b_lp));
    b_i1:=FBH_HD_NGCAP(a_ma_dvi(b_lp),b_so_id);
    if b_i1<b_kq then b_kq:=b_i1; end if;
end loop;
return b_kq;
end;
/
create or replace function FBH_HD_NGCAP(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ngay cap dang
select min(ngay_cap) into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HD_NGAY_HL(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number) return number
AS
    b_so_id_bs number; b_kq number;
begin
-- Dan - Tra ngay hieu luc
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
select ngay_hl into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return b_kq;
end;
/
create or replace function FBH_HD_NGAY_KT(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number) return number
AS
    b_so_id_bs number; b_kq number;
begin
-- Dan - Tra ngay ket thuc
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
select ngay_kt into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return b_kq;
end;
/
create or replace procedure PBH_HD_NGAY_HL(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,b_ngay_hl out number,b_ngay_kt out number)
AS
    b_so_id_bs number;
begin
-- Dan - Tra ngay hieu luc
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
end;
/
create or replace procedure FBH_HD_NGAY_HLh(b_ma_dvi varchar2,b_so_id number,b_ngay_hl out number,b_ngay_kt out number)
AS
begin
-- Dan - Tra ngay hieu luc v  ngay ket thuc
select nvl(min(ngay_hl),0),nvl(min(ngay_kt),0) into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace procedure FBH_HD_NGAY_HLb(
    b_ma_dvi varchar2,b_so_id number,b_ngay_hl out number,b_ngay_kt out number,b_ngay number:=30000101)
AS
    b_so_idB number;
begin
-- Dan - Tra ngay hieu luc v  ngay ket thuc
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
FBH_HD_NGAY_HLh(b_ma_dvi,b_so_idB,b_ngay_hl,b_ngay_kt);
end;
/
create or replace function FBH_HD_NGAY_HLk(b_ma_dvi varchar2,b_so_id number,b_ngay number) return varchar2
AS
     b_kq varchar2(1):='K'; b_i1 number; b_so_id_bs number;
begin
-- Dan - Kiem tra ngay trong khoang hieu luc
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and b_ngay between ngay_hl and ngay_kt;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_HD_NGAY_HLg(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_so_id_bs number; b_ngay_hl number; b_ngay_kt number;
begin
-- Dan - Kiem tra hieu luc giao nhau
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
return FKH_GIAO(b_ngay_hl,b_ngay_kt,b_ngayd,b_ngayc);
end;
/
create or replace function FBH_HD_NGAY_HLt(
    b_ma_dvi varchar2,b_so_id number,b_ngay number,b_ngayd number,b_ngayc number) return varchar2
AS
    b_kq varchar2(1):='K'; b_so_id_bs number; b_ngay_hl number; b_ngay_kt number;
begin
-- Dan - Kiem tra hieu luc nam trong khoang
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
if b_ngayd<=b_ngay_hl and b_ngayc>=b_ngay_kt then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_NGHLUC_HD(b_ma_dvi varchar2,b_so_id number,b_ngay_hl out number,b_ngay_kt out number)
AS
begin
-- Dan - Tra ngay hieu luc hop dong qua so ID hop dong
select min(ngay_hl),min(ngay_kt) into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace function FBH_HD_NGAY_CAP(
    b_ma_dvi varchar2,b_so_id_ps number) return number
AS
    b_kq number:=0; b_so_id number;
begin
-- Dan - Tra ngay cap
b_so_id:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_id);
if b_so_id<>0 then
    select decode(nv,'HANG',ngay_hl,ngay_cap) into b_kq
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
if b_kq=0 then b_kq:=PKH_NG_CSO(sysdate); end if;
return b_kq;
exception when others then b_kq:=PKH_NG_CSO(sysdate);
end;
/
create or replace function FBH_HD_GOC_VE_NH(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_kq number;
begin
-- Dan - Xac dinh nhap tai ve
select nvl(min(ngay_ta),0) into b_kq from bh_hd_goc_ve where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure PBH_HD_PT(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_thue number,b_thue_qd number,
    a_so_id_dt out pht_type.a_num,a_lh_nv out pht_type.a_var,a_tien out pht_type.a_num,
    a_tien_qd out pht_type.a_num,a_thue out pht_type.a_num,a_thue_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_tl number; b_tp number:=0; b_tien_t number; b_so_id_ps number;
    b_tien_c number; b_tien_c_qd number; b_thue_c number; b_thue_c_qd number; a_tl pht_type.a_num;
Begin
-- Dan - Phan tich theo hop dong
b_so_id_ps:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
PBH_HD_DS_NV_BANG(b_ma_dvi,b_so_id_ps,0,b_loi);
if b_loi is not null then return; end if;
select so_id_dt,lh_nv,sum(tien_vnd) BULK COLLECT into a_so_id_dt,a_lh_nv,a_tl
    from bh_hd_nv_temp where lh_nv<>' ' group by so_id_dt,lh_nv having sum(tien_vnd)<>0;
if a_lh_nv.count=0 then b_loi:=''; return; end if;
b_tien_t:=FKH_ARR_TONG(a_tl);
if b_ma_nt<>'VND' then b_tp:=2; end if;
b_tien_c:=b_tien; b_tien_c_qd:=b_tien_qd; b_thue_c:=b_thue; b_thue_c_qd:=b_thue_qd;
for b_lp in 1..a_lh_nv.count loop
    if b_lp=a_so_id_dt.count then
        a_tien(b_lp):=b_tien_c; a_tien_qd(b_lp):=b_tien_c_qd;
        a_thue(b_lp):=b_thue_c; a_thue_qd(b_lp):=b_thue_c_qd;
    else
        b_tl:=a_tl(b_lp)/b_tien_t;
        a_tien(b_lp):=round(b_tien*b_tl,b_tp); a_tien_qd(b_lp):=round(b_tien_qd*b_tl,0);
        a_thue(b_lp):=round(b_thue*b_tl,b_tp); a_thue_qd(b_lp):=round(b_thue_qd*b_tl,0);
        b_tien_c:=b_tien_c-a_tien(b_lp); b_tien_c_qd:=b_tien_c_qd-a_tien_qd(b_lp);
        b_thue_c:=b_thue_c-a_thue(b_lp); b_thue_c_qd:=b_thue_c_qd-a_thue_qd(b_lp);
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_PT:loi'; end if;
end;
/
create or replace function FBH_HD_TEN(b_ma_dvi varchar2,b_so_id number) return nvarchar2
AS
    b_ten nvarchar2(500); b_so_idB number;
begin
-- Dan - Ten doi tuong theo so_id
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id);
select ten into b_ten from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
return b_ten;
end;
/
create or replace function FBH_HD_DS_SO_DT(b_ma_dvi varchar2,b_so_id number,b_ngay number:=30000101) return number
AS
    b_so_dt number:=1; b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra so cac doi tuong theo hop dong
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id); b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay);
if b_nv='PHH' then
    select count(*) into b_so_dt from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PKT' then
    select count(*) into b_so_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='XE' then
    select count(*) into b_so_dt from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='2B' then
    select count(*) into b_so_dt from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='TAU' then
    select count(*) into b_so_dt from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='NG' then
    select count(*) into b_so_dt from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PTN' then
    select count(*) into b_so_dt from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='HOP' then
    select count(*) into b_so_dt from bh_hop_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
return b_so_dt;
end;
/
create or replace function FBH_HD_TL(
    b_ma_dvi_hd varchar2,b_so_id_hd number,b_lh_nv varchar2,b_ngay_ht number,b_dk varchar2:=' ') return number
AS
    b_con number; b_do number:=0; b_ta number:=0; b_ve number:=0;
begin
-- Dan - Tra ty le con lai
if instr(b_dk,'D')<>0 then b_do:=FBH_DONG_TL(b_ma_dvi_hd,b_so_id_hd,b_lh_nv); end if;
if instr(b_dk,'V')<>0 then b_ve:=FTBH_TMN_TL(b_ma_dvi_hd,b_so_id_hd,b_lh_nv); end if;
if instr(b_dk,'C')<>0 then b_ta:=FTBH_GHEP_TL(b_ma_dvi_hd,b_so_id_hd,b_lh_nv,b_ngay_ht); end if;
if instr(b_dk,'T')<>0 then b_ta:=b_ta+FTBH_TM_TL(b_ma_dvi_hd,b_so_id_hd,b_lh_nv,b_ngay_ht); end if;
if b_do<>0 then
    b_con:=100-b_do+b_ve-b_ta;
elsif b_ve<>0 then
    b_con:=b_ve-b_ta;
else
    b_con:=100-b_ta;
end if;
return b_con;
exception when others then return 0;
end;
/
create or replace function FBH_HD_TL_DT(
    b_ma_dvi_hd varchar2,b_so_id_hd number,b_so_id_dt number,b_lh_nv varchar2,b_ngay_ht number,b_dk varchar2:=' ') return number
AS
    b_con number; b_do number:=0; b_ta number:=0; b_ve number:=0;
begin
-- Dan - Tra ty le con lai
if b_dk=' ' or instr(b_dk,'D')<>0 then b_do:=FBH_DONG_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_lh_nv); end if;
if b_dk=' ' or instr(b_dk,'V')<>0 then b_ve:=FTBH_TMN_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_lh_nv); end if;
if b_dk=' ' or instr(b_dk,'C')<>0 then b_ta:=FTBH_GHEP_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_lh_nv,b_ngay_ht); end if;
if b_dk=' ' or instr(b_dk,'T')<>0 then b_ta:=b_ta+FTBH_TM_TL_DT(b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,b_lh_nv,b_ngay_ht); end if;
if b_do<>0 then
    b_con:=100-b_do+b_ve-b_ta;
elsif b_ve<>0 then
    b_con:=b_ve-b_ta;
else
    b_con:=100-b_ta;
end if;
return b_con;
exception when others then return 0;
end;
/
create or replace procedure PBH_HD_DS_DT_ARR
    (b_ma_dvi varchar2,b_so_idB number,a_so_id_dt out pht_type.a_num,b_nvN varchar2:=' ')
AS
    b_i1 number:=0; b_nv varchar2(10):=b_nvN;
begin
-- Dan - Liet ke doi tuong theo hop dong
if nvl(trim(b_nv),' ')=' ' then b_nv:=FBH_HD_NV(b_ma_dvi,b_so_idB); end if;
if b_nv='PHH' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PKT' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='XE' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='2B' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='TAU' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
else
    PKH_MANG_KD_N(a_so_id_dt,1);
end if;
end;
/
create or replace procedure PBH_HD_DS_DTt_ARR
    (b_ma_dvi varchar2,b_so_idB number,a_so_id_dt out pht_type.a_num,b_nvN varchar2:=' ')
AS
    b_i1 number:=0; b_nv varchar2(10):=b_nvN;
begin
-- Dan - Liet ke doi tuong ghep tai
if nvl(trim(b_nv),' ')=' ' then b_nv:=FBH_HD_NV(b_ma_dvi,b_so_idB); end if;
if b_nv='PHH' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PKT' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='XE' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='2B' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='TAU' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='NG' then
    select so_id_dt BULK COLLECT into a_so_id_dt from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
else
    PKH_MANG_KD_N(a_so_id_dt,1);
end if;
end;
/
create or replace procedure PBH_HD_DS_DT_ARRt(
    b_ma_dvi varchar2,b_so_idB number,a_so_id_dt out pht_type.a_num,a_ten out pht_type.a_nvar,b_nvN varchar2:=' ')
AS
    b_i1 number:=0; b_nv varchar2(10);
begin
-- Dan - Liet ke doi tuong theo hop dong
if nvl(trim(b_nv),' ')=' ' then b_nv:=FBH_HD_NV(b_ma_dvi,b_so_idB); end if;
if b_nv='PHH' then
    select so_id_dt,dvi BULK COLLECT into a_so_id_dt,a_ten from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PKT' then
    select so_id_dt,dvi BULK COLLECT into a_so_id_dt,a_ten from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='XE' then
    select so_id_dt,nvl(trim(bien_xe),so_khung) BULK COLLECT into a_so_id_dt,a_ten from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='2B' then
    select so_id_dt,nvl(trim(bien_xe),so_khung) BULK COLLECT into a_so_id_dt,a_ten from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='TAU' then
    select so_id_dt,nvl(trim(so_dk),ten_tau) BULK COLLECT into a_so_id_dt,a_ten from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB;
else
    PKH_MANG_KD_N(a_so_id_dt,1); PKH_MANG_KD_U(a_ten,1);
end if;
end;
/
create or replace function FBH_HD_SO_DT(b_ma_dvi varchar2,b_so_id number,b_ngay_ht number) return number
AS
    b_so_dt number:=1; b_so_id_d number; b_so_id_bs number; b_nv varchar2(10);
begin
-- Dan - Tra so doi tuong theo hop dong
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id_d);
-- if b_nv='HANG' then
--     select nvl(max(so_dt),1) into b_so_dt from bh_hhgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
if b_nv='NG' then
    select count(*) into b_so_dt from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
end if;
return b_so_dt;
end;
/
create or replace function FBH_HD_MA_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_ht number:=30000101) return varchar2
AS
    b_ma_dt varchar2(10):=' '; b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra ma doi tuong tuong theo hop dong
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
if b_nv='PHH' then
    b_ma_dt:=FBH_PHH_MRR(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='XE' then
    b_ma_dt:=FBH_XE_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='2B' then
    b_ma_dt:=FBH_2B_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='TAU' then
    b_ma_dt:=FBH_TAU_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='PKT' then
    b_ma_dt:=FBH_PKT_MA_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
end if;
return b_ma_dt;
end;
/
create or replace function FBH_HD_DK_LUT(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_ht number) return varchar2
AS
    b_dk_lut varchar2(1):='K'; b_so_idB number; b_nv varchar2(10);
begin
-- Dan - Tra so doi tuong theo hop dong
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
b_so_idB:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
if b_nv='PHH' then
    select dk_lut into b_dk_lut from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
elsif b_nv='PKT' then
    select dk_lut into b_dk_lut from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_idB;
-- elsif b_nv='PTN' then
--     select dk_lut into b_dk_lut from bh_ptngcn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
end if;
return b_dk_lut;
end;
/
create or replace procedure PBH_HD_DK_LUT(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_dk_lut out varchar2,b_hs_lut out number,b_ngay number:=30000101)
AS
begin
-- Dan - Tra so doi tuong theo hop dong
if b_nv='PHH' then
    FBH_PHH_DK_LUT(b_ma_dvi,b_so_id,b_so_id_dt,b_dk_lut,b_hs_lut,b_ngay);
elsif b_nv='PKT' then
    FBH_PKT_DK_LUT(b_ma_dvi,b_so_id,b_so_id_dt,b_dk_lut,b_hs_lut,b_ngay);
else
    b_dk_lut:='K'; b_hs_lut:=0;
end if;
end;
/
/*** PHAT SINH HOP DONG GOC ***/
create or replace procedure PBH_HD_GOC_SO_ID
    (b_ma_dvi varchar2,b_so_hd varchar2,b_so_id out number)
AS
begin
-- Dan - Tra so ID qua so hop dong
b_so_id:=FBH_HD_GOC_SO_ID(b_ma_dvi,b_so_hd);
end;
/
create or replace procedure PBH_HD_SO_ID_KTRA
    (b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra SO_ID moi nhap
if b_so_id_g=0 then b_loi:=''; return; end if;
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_g and ttrang<>'D';
if b_i1<>0 then b_loi:='loi:Hop dong, GCN cu da xoa hoac chua ky:loi'; return; end if;
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g and kieu_hd<>'K';
if b_i1<>0 then b_loi:='loi:Hop dong, GCN cu da co bo sung, sua doi:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_SO_ID_KTRA:loi'; end if;
end;
/
--create or replace procedure PBH_HD_NV_KTRA
create or replace procedure PBH_CT_XEM_KTRA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,
    b_bang varchar2,b_so_id number,b_dvi varchar2,b_loi out varchar2)
as
    b_i1 number; b_lenh varchar2(2000); b_phong varchar2(10); b_nsd_n varchar2(10);
begin
-- Dan - Kiem tra quyen xem bang theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then return; end if;
if b_bang='bh_kt' then
    if b_dvi is null then
        select count(*) into b_i1 from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else    select count(*) into b_i1 from bh_kt where ma_dvi=b_dvi and so_id=b_so_id;
    end if;
    if b_i1=0 then b_loi:=''; return; end if;
    if (b_dvi is null and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH',b_nv,'X')<>'C')
        or (b_dvi is not null and FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi)<>'C') then
        b_loi:='loi:Khong duoc xem:loi'; return;
    end if;
else
    if b_bang='bh_hd_goc_ttps' or b_bang='bh_bt_tt' or b_bang='bh_bt_gd_tt' or b_bang='bh_hd_do_tt' then
        b_lenh:='select count(*),min(nsd),min(phong) from '||b_bang||' where ma_dvi= :ma_dvi and so_id_tt= :so_id';
    elsif b_bang='bh_hd_goc_vat' then
        b_lenh:='select count(*),min(nsd),min(phong) from '||b_bang||' where ma_dvi= :ma_dvi and so_id_vat= :so_id';
    elsif b_bang='bh_hd_goc_hh' then
       b_lenh:='select count(*),min(nsd),min(phong) from '||b_bang||' where ma_dvi= :ma_dvi and so_id_hh= :so_id';
    elsif b_bang='bh_hd_do_vat' then
       b_lenh:='select count(*),min(nsd),min(phong) from '||b_bang||' where ma_dvi= :ma_dvi and so_id_vat= :so_id';
    else
       b_lenh:='select count(*),min(nsd),min(phong) from '||b_bang||' where ma_dvi= :ma_dvi and so_id= :so_id';
    end if;
    if b_dvi is null then
        execute immediate b_lenh into b_i1,b_nsd_n,b_phong using b_ma_dvi,b_so_id;
    else
        execute immediate b_lenh into b_i1,b_nsd_n,b_phong using b_dvi,b_so_id;
    end if;
    if b_i1=0 then b_loi:=''; return; end if;
    if (b_dvi is null and b_nsd_n<>b_nsd and FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd)<>b_phong and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH',b_nv,'X')<>'C')
        or (b_dvi is not null and FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi)<>'C' and (b_dvi<>b_ma_dvi or b_nsd_n<>b_nsd)) then
        b_loi:='loi:Khong duoc xem:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_CT_XEM_KTRA:loi'; end if;
end;
/
create or replace procedure PBH_HD_XEM_KTRA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_dvi varchar2,b_loi out varchar2)
as
     b_phong varchar2(10); b_nv varchar2(10);
begin
-- Dan - Kiem tra quyen xem hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then return; end if;
b_loi:='loi:Hop dong, GCN da xoa:loi';
if b_dvi is null or b_dvi=b_ma_dvi then
    select FBH_HD_NV_RUT(nv),phong into b_nv,b_phong from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd)<>b_phong and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH',b_nv,'X')<>'C' then
        b_loi:='loi:Khong duoc xem:loi'; return;
    end if;
else
    select FBH_HD_NV_RUT(nv) into b_nv from bh_hd_goc where ma_dvi=b_dvi and so_id=b_so_id;
    if FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi)<>'C' then
        b_loi:='loi:Khong duoc xem:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_XEM_KTRA:loi'; end if;
end;
/
/*** TIEN ICH DI KEM ***/
create or replace function FBH_TH_PHI_TON(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number) return number
AS
    b_i1 number; b_ton number:=0;
begin
-- Dan - Ton
select nvl(max(ngay_ht),0) into b_i1 from bh_hd_goc_sc_phi where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton into b_ton from bh_hd_goc_sc_phi where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
return b_ton;
end;
/
create or replace procedure PBH_TH_PHI_TON(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,b_ton out number)
AS
    b_i1 number;
begin
-- Dan - Ton
b_ton:=FBH_TH_PHI_TON(b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht);
end;
/
create or replace procedure PBH_TH_PHI(
    b_ma_dvi varchar2,b_ps varchar2,b_so_id_ps number,b_ma_nt varchar2,b_ngay_ht number,b_tien number,b_loi out varchar2)
AS
    b_so_id number; b_no number:=0; b_co number:=0; b_ton number; b_i1 number:=b_ngay_ht-1;
begin
-- Dan - Tong hop so cai phi
b_so_id:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_ps);
if b_ps='N' then b_no:=b_tien; else b_co:=b_tien; end if;
b_ton:=FBH_TH_PHI_TON(b_ma_dvi,b_so_id,b_ma_nt,b_i1);
update bh_hd_goc_sc_phi set no=no+b_no,co=co+b_co where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then insert into bh_hd_goc_sc_phi values (b_ma_dvi,b_so_id,b_ma_nt,b_ngay_ht,b_no,b_co,0); end if;
for r_lp in (select no,co,ngay_ht from bh_hd_goc_sc_phi where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=r_lp.ngay_ht;
    if r_lp.no=0 and r_lp.co=0 then
        delete bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+r_lp.no-r_lp.co;
        update bh_hd_goc_sc_phi set ton=b_ton where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
PBH_TH_SC_PHI_TON(b_ma_dvi,b_so_id,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_PHI:loi'; end if;
end;
/
create or replace procedure PBH_TH_PHI_TON_TTOAN(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,
    b_ttoan out number,b_thue out number,b_loi out varchar2,b_ngay_ht number:=30000101)
AS
    b_i1 number; b_i2 number;
begin
-- Dan - Ton chi tiet
b_loi:='loi:Loi lay ton thanh toan:loi';
select nvl(sum(thue),0),nvl(sum(ttoan),0) into b_thue,b_ttoan
    from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht and ma_nt=b_ma_nt;
select nvl(sum(thue),0),nvl(sum(ttoan),0) into b_i1,b_i2 from bh_hd_goc_ttpt where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_ht<=b_ngay_ht and ma_nt=b_ma_nt and pt not in('H','C');
b_thue:=b_thue-b_i1; b_ttoan:=b_ttoan-b_i2; b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_PHI_TON_TTOAN:loi'; end if;
end;
/
-- Phi phai thu nha dong: lead, nhan tai tam thoi
create or replace function FBH_TH_PHI_NBH_TON(
    b_ma_dvi varchar2,b_so_id number,b_nbh varchar2,b_ma_nt varchar2,b_ngay_ht number:=30000101) return number
AS
    b_i1 number; b_ton number:=0;
begin
-- Dan - Ton phi nbh
select nvl(max(ngay_ht),0) into b_i1 from bh_hd_goc_phi_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1<>0 then
    select ton into b_ton from bh_hd_goc_phi_nbh where
        ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
return b_ton;
end;
/
create or replace function FBH_TH_PHI_NBH_KTRA(
    b_ma_dvi varchar2,b_so_id number,b_nbh varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ton number:=0;
begin
-- Dan - Kiem tra ton phi lead
if trim(b_nbh) is null then
    select count(*) into b_i1 from bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=0 then b_kq:='C'; end if;
else
    for r_lp in(select distinct ma_nt from bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh) loop
        if FBH_TH_PHI_NBH_TON(b_ma_dvi,b_so_id,b_nbh,r_lp.ma_nt)<>0 then
            b_kq:='C'; exit;
        end if;
    end loop;
end if;
return b_kq;
end;
/
create or replace procedure PBH_TH_PHI_NBH(
    b_ma_dvi varchar2,b_ps varchar2,b_so_id number,b_nbh varchar2,
    b_ma_nt varchar2,b_tien number,b_ngay_ht number,b_loi out varchar2)
AS
    b_no number:=0; b_co number:=0; b_ton number; b_i1 number:=b_ngay_ht-1;
begin
-- Dan - Tong hop so cai phi
if b_ps='N' then b_no:=b_tien; else b_co:=b_tien; end if;
b_ton:=FBH_TH_PHI_NBH_TON(b_ma_dvi,b_so_id,b_nbh,b_ma_nt,b_i1);
update bh_hd_goc_phi_nbh set no=no+b_no,co=co+b_co where
    ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then insert into bh_hd_goc_phi_nbh values(b_ma_dvi,b_so_id,b_nbh,b_ma_nt,b_ngay_ht,b_no,b_co,0); end if;
for r_lp in (select no,co,ngay_ht from bh_hd_goc_phi_nbh where
    ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=r_lp.ngay_ht;
    if r_lp.no=0 and r_lp.co=0 then
        delete bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+r_lp.no-r_lp.co;
        update bh_hd_goc_phi_nbh set ton=b_ton where ma_dvi=b_ma_dvi and so_id=b_so_id and nbh=b_nbh and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_PHI_NBH:loi'; end if;
end;
/
create or replace procedure PBH_PHI_CL(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,
    a_ngay out pht_type.a_num,a_ma_dt out pht_type.a_var,a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,
    a_phi out pht_type.a_num,a_thue out pht_type.a_num,a_ttoan out pht_type.a_num,a_uu out pht_type.a_var,b_loi out varchar2)
AS
begin
-- Dan - Ton chi tiet theo loai:no,cho no
select ma_dt,lh_nv,t_suat,phi,thue,ttoan BULK COLLECT into
    a_ma_dt,a_lh_nv,a_t_suat,a_phi,a_thue,a_ttoan
    from (select ma_dt,lh_nv,t_suat,sum(phi) phi,sum(thue) thue,sum(ttoan) ttoan
    from bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht
    group by ma_dt,lh_nv,t_suat having sum(ttoan)<>0);
for b_lp in 1..a_lh_nv.count loop
    a_ngay(b_lp):=b_ngay_ht; a_uu(b_lp):=FBH_MA_LHNV_UU(a_lh_nv(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHI_CL:loi'; end if;
end;
/
create or replace procedure PBH_PHI_CLDT(
    b_ma_dvi varchar2,b_so_id number,b_ma_nt varchar2,b_ngay_ht number,
    a_so_id_dt out pht_type.a_num,a_ngay out pht_type.a_num,a_ma_dt out pht_type.a_var,
    a_lh_nv out pht_type.a_var,a_t_suat out pht_type.a_num,
    a_phi out pht_type.a_num,a_thue out pht_type.a_num,
    a_ttoan out pht_type.a_num,a_uu out pht_type.a_var,b_loi out varchar2)
AS
begin
-- Dan - Ton chi tiet theo loai:no,cho no
select so_id_dt,ma_dt,lh_nv,t_suat,phi,thue,ttoan BULK COLLECT into
    a_so_id_dt,a_ma_dt,a_lh_nv,a_t_suat,a_phi,a_thue,a_ttoan
    from (select so_id_dt,ma_dt,lh_nv,t_suat,sum(phi) phi,sum(thue) thue,sum(ttoan) ttoan
    from bh_hd_goc_cldt where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht
    group by so_id_dt,ma_dt,lh_nv,t_suat having sum(ttoan)<>0);
for b_lp in 1..a_lh_nv.count loop
    a_ngay(b_lp):=b_ngay_ht; a_uu(b_lp):=FBH_MA_LHNV_UU(a_lh_nv(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHI_CL:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_NH_PT(
    b_ma_dvi varchar2,b_so_id number,b_so_idD number,b_so_idG number,
    b_ngay_ht number,b_kieu_kt varchar2,b_ma_kt varchar2,
    dk_ma_dt pht_type.a_var,dk_nt_tien pht_type.a_var,dk_nt_phi pht_type.a_var,
    dk_lh_nv pht_type.a_var,dk_t_suat pht_type.a_num,dk_pt pht_type.a_num,
    dk_tien pht_type.a_num,dk_phi pht_type.a_num,dk_thue pht_type.a_num,dk_ttoan pht_type.a_num,
    dt_so_id_dt pht_type.a_num,dt_ma_dt pht_type.a_var,dt_nt_tien pht_type.a_var,dt_nt_phi pht_type.a_var,
    dt_lh_nv pht_type.a_var,dt_t_suat pht_type.a_num,dt_pt pht_type.a_num,
    dt_tien pht_type.a_num,dt_phi pht_type.a_num,dt_thue pht_type.a_num,dt_ttoan pht_type.a_num,
    tt_ngay pht_type.a_num,tt_ma_nt pht_type.a_var,tt_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_bt number; b_tp number:=0; b_so_idX number; b_hs number; b_nsd varchar2(10);
    b_ttoanT number; b_kieu_hd varchar2(1); b_ma_nt varchar2(5); b_nv varchar2(10); b_cu varchar2(1);
    b_kt number:=dk_lh_nv.count; b_pX number; b_pXdt number;
    cl_phi pht_type.a_num; cl_thue pht_type.a_num; cldt_phi pht_type.a_num; cldt_thue pht_type.a_num;
    tt_ngayC pht_type.a_num; tt_tienC pht_type.a_num;
begin
-- Dan - Nhap hop dong goc tu nghiep vu chi tiet
delete bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nv,kieu_hd,nsd into b_nv,b_kieu_hd,b_nsd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kieu_hd not in('B','S') then b_so_idX:=b_so_id; else b_so_idX:=b_so_idD; end if;
forall b_lp in 1..b_kt
    insert into bh_hd_goc_dk values(b_ma_dvi,b_so_id,dk_ma_dt(b_lp),dk_nt_tien(b_lp),dk_nt_phi(b_lp),
        dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_pt(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_thue(b_lp),dk_ttoan(b_lp));
if dt_so_id_dt.count<>0 then
    forall b_lp in 1..dt_lh_nv.count
        insert into bh_hd_goc_dkdt values(b_ma_dvi,b_so_id,dt_so_id_dt(b_lp),dt_ma_dt(b_lp),dt_nt_tien(b_lp),dt_nt_phi(b_lp),
            dt_lh_nv(b_lp),dt_t_suat(b_lp),dt_pt(b_lp),dt_tien(b_lp),dt_phi(b_lp),dt_thue(b_lp),dt_ttoan(b_lp));
elsif b_nv in('2B','XE','TAU','PHH','PKT') then    
    forall b_lp in 1..b_kt
        insert into bh_hd_goc_dkdt values(b_ma_dvi,b_so_id,b_so_id,dk_ma_dt(b_lp),dk_nt_tien(b_lp),dk_nt_phi(b_lp),
            dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_pt(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_thue(b_lp),dk_ttoan(b_lp));
else
    forall b_lp in 1..b_kt
        insert into bh_hd_goc_dkdt values(b_ma_dvi,b_so_id,0,dk_ma_dt(b_lp),dk_nt_tien(b_lp),dk_nt_phi(b_lp),
            dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_pt(b_lp),dk_tien(b_lp),dk_phi(b_lp),dk_thue(b_lp),dk_ttoan(b_lp));
end if;
forall b_lp in 1..tt_ngay.count
    insert into bh_hd_goc_tt values(b_ma_dvi,b_so_id,tt_ngay(b_lp),tt_ma_nt(b_lp),tt_tien(b_lp));
select nvl(max(bt),0) into b_bt from (select bt from bh_hd_goc_pt where ma_dvi=b_ma_dvi and so_id=b_so_id) where bt<1000000;
if b_so_id<>b_so_idX then
    insert into bh_hd_goc_pt select b_ma_dvi,b_so_id,bt+1000000,b_kieu_hd,b_ngay_ht,b_so_idX,
        ngay,ma_dt,ma_nt,lh_nv,t_suat,-phi,-thue,-ttoan
        from bh_hd_goc_pt where ma_dvi=b_ma_dvi and so_id_xl=b_so_idG and bt<1000000;
    insert into bh_hd_goc_ptdt select b_ma_dvi,b_so_id,bt+1000000,b_kieu_hd,b_ngay_ht,b_so_idX,so_id_dt,
        ngay,ma_dt,ma_nt,lh_nv,t_suat,-phi,-thue,-ttoan
        from bh_hd_goc_ptdt where ma_dvi=b_ma_dvi and so_id_xl=b_so_idG and bt<1000000;
end if;
b_ma_nt:=tt_ma_nt(1);
if b_ma_nt<>'VND' then b_tp:=2; end if;
if tt_ngay.count<2 then
    for b_lp in 1..b_kt loop
        if dk_phi(b_lp)<>0 or dk_thue(b_lp)<>0 then
            insert into bh_hd_goc_pt values(b_ma_dvi,b_so_id,b_lp,b_kieu_hd,b_ngay_ht,b_so_idX,tt_ngay(1),
                dk_ma_dt(b_lp),b_ma_nt,dk_lh_nv(b_lp),dk_t_suat(b_lp),dk_phi(b_lp),dk_thue(b_lp),dk_ttoan(b_lp));
        end if;
    end loop;
    if dt_so_id_dt.count=0 or b_nv not in('2B','XE','TAU','PHH','PKT') then
        for b_lp in 1..dt_lh_nv.count loop
            if dt_phi(b_lp)<>0 or dt_thue(b_lp)<>0 then
                insert into bh_hd_goc_ptdt values(b_ma_dvi,b_so_id,b_lp,b_kieu_hd,b_ngay_ht,b_so_idX,0,tt_ngay(1),
                    dt_ma_dt(b_lp),b_ma_nt,dt_lh_nv(b_lp),dt_t_suat(b_lp),dt_phi(b_lp),dt_thue(b_lp),dt_ttoan(b_lp));
            end if;
        end loop;
    elsif dt_so_id_dt(1)<>b_so_id then
        for b_lp in 1..dt_lh_nv.count loop
            if dt_phi(b_lp)<>0 or dt_thue(b_lp)<>0 then
                insert into bh_hd_goc_ptdt values(
                    b_ma_dvi,b_so_id,b_lp,b_kieu_hd,b_ngay_ht,b_so_idX,dt_so_id_dt(b_lp),tt_ngay(1),
                    dt_ma_dt(b_lp),b_ma_nt,dt_lh_nv(b_lp),dt_t_suat(b_lp),dt_phi(b_lp),dt_thue(b_lp),dt_ttoan(b_lp));
            end if;
        end loop;
    else
        for b_lp in 1..dt_lh_nv.count loop
            if dt_phi(b_lp)<>0 or dt_thue(b_lp)<>0 then
                insert into bh_hd_goc_ptdt values(b_ma_dvi,b_so_id,b_lp,b_kieu_hd,b_ngay_ht,b_so_idX,b_so_id,tt_ngay(1),
                    dt_ma_dt(b_lp),b_ma_nt,dt_lh_nv(b_lp),dt_t_suat(b_lp),dt_phi(b_lp),dt_thue(b_lp),dt_ttoan(b_lp));
            end if;
        end loop;
    end if;
    b_loi:=''; return;
end if;
b_ttoanT:=FKH_ARR_TONG(dk_phi)+FKH_ARR_TONG(dk_thue);
if b_kieu_hd in('B','S') then
    select ngay,tien bulk collect into tt_ngayC,tt_tienC from bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_idG;
else
    PKH_MANG_KD_N(tt_ngayC); PKH_MANG_KD_N(tt_tienC);
end if;
for b_lp1 in 1..tt_ngay.count loop
    if b_kieu_hd in('B','S') then
        b_i1:=FKH_ARR_VTRI_N(tt_ngayC,tt_ngay(b_lp1));
        if b_i1=b_lp1 and tt_tien(b_lp1)=tt_tienC(b_i1) then 
            insert into bh_hd_goc_pt select b_ma_dvi,b_so_id,bt,b_kieu_hd,b_ngay_ht,b_so_idX,
                tt_ngay(b_lp1),ma_dt,ma_nt,lh_nv,t_suat,phi,thue,ttoan
                from bh_hd_goc_pt where ma_dvi=b_ma_dvi and so_id_xl=b_so_idG and ngay=tt_ngay(b_lp1) and bt<1000000;
            insert into bh_hd_goc_ptdt select b_ma_dvi,b_so_id,bt,b_kieu_hd,b_ngay_ht,b_so_idX,
                so_id_dt,tt_ngay(b_lp1),ma_dt,ma_nt,lh_nv,t_suat,phi,thue,ttoan
                from bh_hd_goc_ptdt where ma_dvi=b_ma_dvi and so_id_xl=b_so_idG and ngay=tt_ngay(b_lp1) and bt<1000000;
            continue;
        end if;
    end if;
    b_hs:=tt_tien(b_lp1)/b_ttoanT;
    for b_lp in 1..b_kt loop
        cl_phi(b_lp):=round(b_hs*dk_phi(b_lp),b_tp); cl_thue(b_lp):=round(b_hs*dk_thue(b_lp),b_tp);
    end loop;
    b_i1:=tt_tien(b_lp1)-FKH_ARR_TONG(cl_phi)-FKH_ARR_TONG(cl_thue);
    b_pX:=FKH_ARR_VTRIx_N(cl_phi); cl_phi(b_pX):=cl_phi(b_pX)+b_i1;
    for b_lp in 1..b_kt loop
        insert into bh_hd_goc_pt values(b_ma_dvi,b_so_id,b_lp,b_kieu_hd,b_ngay_ht,b_so_idX,
            tt_ngay(b_lp1),dk_ma_dt(b_lp),b_ma_nt,dk_lh_nv(b_lp),dk_t_suat(b_lp),
            cl_phi(b_lp),cl_thue(b_lp),cl_phi(b_lp)+cl_thue(b_lp));
    end loop;
    if dt_so_id_dt.count<>0 then
        for b_lp in 1..dt_lh_nv.count loop
            cldt_phi(b_lp):=round(b_hs*dt_phi(b_lp),b_tp); cldt_thue(b_lp):=round(b_hs*dt_thue(b_lp),b_tp);
        end loop;
        b_i1:=tt_tien(b_lp1)-FKH_ARR_TONG(cldt_phi)-FKH_ARR_TONG(cldt_thue);
        b_pXdt:=FKH_ARR_VTRIx_N(cldt_phi); cldt_phi(b_pXdt):=cldt_phi(b_pXdt)+b_i1;
    else
        for b_lp in 1..dk_lh_nv.count loop
            cldt_phi(b_lp):=round(b_hs*dk_phi(b_lp),b_tp); cldt_thue(b_lp):=round(b_hs*dk_thue(b_lp),b_tp);
        end loop;
    end if;
    b_i1:=tt_tien(b_lp1)-FKH_ARR_TONG(cldt_phi)-FKH_ARR_TONG(cldt_thue);
    b_pXdt:=FKH_ARR_VTRIx_N(cldt_phi); cldt_phi(b_pXdt):=cldt_phi(b_pXdt)+b_i1;
    if dt_so_id_dt.count=0 or b_nv not in('2B','XE','TAU','PHH','PKT') then    
        for b_lp in 1..dk_lh_nv.count loop
            if dk_phi(b_lp)<>0 or dk_thue(b_lp)<>0 then
                insert into bh_hd_goc_ptdt values(b_ma_dvi,b_so_id,b_lp,
                    b_kieu_hd,b_ngay_ht,b_so_idX,0,tt_ngay(b_lp1),dk_ma_dt(b_lp),b_ma_nt,
                    dk_lh_nv(b_lp),dk_t_suat(b_lp),cldt_phi(b_lp),cldt_thue(b_lp),cldt_phi(b_lp)+cldt_thue(b_lp));
            end if;
        end loop;
    elsif dt_so_id_dt(1)<>b_so_id then
        for b_lp in 1..dt_lh_nv.count loop
            if dt_phi(b_lp)<>0 or dt_thue(b_lp)<>0 then
                insert into bh_hd_goc_ptdt values(b_ma_dvi,b_so_id,b_lp,
                    b_kieu_hd,b_ngay_ht,b_so_idX,dt_so_id_dt(b_lp),tt_ngay(b_lp1),dt_ma_dt(b_lp),b_ma_nt,
                    dt_lh_nv(b_lp),dt_t_suat(b_lp),cldt_phi(b_lp),cldt_thue(b_lp),cldt_phi(b_lp)+cldt_thue(b_lp));
            end if;
        end loop;
    else
        for b_lp in 1..dt_lh_nv.count loop
            if dt_phi(b_lp)<>0 or dt_thue(b_lp)<>0 then
                insert into bh_hd_goc_ptdt values(b_ma_dvi,b_so_id,b_lp,
                    b_kieu_hd,b_ngay_ht,b_so_idX,b_so_id,tt_ngay(b_lp1),dt_ma_dt(b_lp),b_ma_nt,
                    dt_lh_nv(b_lp),dt_t_suat(b_lp),cldt_phi(b_lp),cldt_thue(b_lp),cldt_phi(b_lp)+cldt_thue(b_lp));
            end if;
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_NH_PT:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_XOA_NV(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Xoa hop dong goc tu nghiep vu chi tiet
delete bh_hd_goc_dkdt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hd_goc_pt where ma_dvi=b_ma_dvi and so_id_xl=b_so_id;
delete bh_hd_goc_ptdt where ma_dvi=b_ma_dvi and so_id_xl=b_so_id;
delete bh_hd_goc_cl where ma_dvi=b_ma_dvi and so_id_xl=b_so_id;
delete bh_hd_goc_cldt where ma_dvi=b_ma_dvi and so_id_xl=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_XOA_NV:loi'; end if;
end;
/
--create or replace procedure PBH_HD_DOI_KH
-- chuclh: khong thay dung 
--create or replace procedure PBH_HD_GOC_THL(
create or replace procedure PBH_TH_SC_PHI_TON(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ton number:=0; b_ma_kt varchar2(20);
begin
-- Dan - Tong hop so cai phi ton
delete bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in(select distinct ma_nt from bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_TH_PHI_TON(b_ma_dvi,b_so_id,r_lp.ma_nt,30000101,b_ton);
    if b_ton<>0 then exit; end if;
end loop;
if b_ton=0 then b_loi:=''; return; end if;
if FBH_DONG_HHV(b_ma_dvi,b_so_id)<>'K' then
    b_ma_kt:=FBH_DONG_NBH(b_ma_dvi,b_so_id);
    insert into bh_hd_goc_sc_phi_ton select b_ma_dvi,b_so_id,so_hd,phong,ma_kh,'B',b_ma_kt
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    insert into bh_hd_goc_sc_phi_ton select b_ma_dvi,b_so_id,so_hd,phong,ma_kh,kieu_kt,ma_kt
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_SC_PHI_TON:loi'; end if;
end;
/
create or replace procedure PBH_TH_SC_NO_TON(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ton number:=0; b_ton_qd number; b_ma_kt varchar2(20);
begin
-- Dan - Tong hop so cai no ton
delete bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in(select distinct ma_nt from bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_TH_NO_TON(b_ma_dvi,b_so_id,r_lp.ma_nt,30000101,b_ton,b_ton_qd);
    if b_ton<>0 then exit; end if;
end loop;
if b_ton=0 then b_loi:=''; return; end if;
if FBH_DONG_HHV(b_ma_dvi,b_so_id)='K' then
    b_ma_kt:=FBH_DONG_NBH(b_ma_dvi,b_so_id);
    insert into bh_hd_goc_sc_no_ton select b_ma_dvi,b_so_id,so_hd,phong,ma_kh,'B',b_ma_kt
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    insert into bh_hd_goc_sc_no_ton select b_ma_dvi,b_so_id,so_hd,phong,ma_kh,kieu_kt,ma_kt
        from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TH_SC_NO_TON:loi'; end if;
end;
/
create or replace procedure PBH_THL_SC_PHI_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ngay_xl number; b_so_hd varchar2(20);
    a_so_id pht_type.a_num; b_kieu_hd varchar2(1);
begin
-- Dan - Tong hop lai so cai phi ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_MANG_KD_N(a_so_id);
if b_so_hd is not null then
    a_so_id(1):=FBH_HD_GOC_SO_ID_DAU(b_ma_dvi,b_so_hd);
    if a_so_id(1)=0 then return; end if;
else
    select distinct so_id_d BULK COLLECT into a_so_id from bh_hd_goc where ma_dvi=b_ma_dvi and ngay_ht>=b_ngay_xl;
end if;
for b_lp in 1..a_so_id.count loop
    PBH_TH_SC_PHI_TON(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PBH_TH_SC_NO_TON(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    commit;
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_UP_NH(
    b_ma_dvi varchar2,b_so_id number,b_ma_dviN varchar2,b_nsd varchar2,b_loi out varchar2,b_du varchar2:='K')
AS
    b_i1 number; b_tbhF varchar2(1);
    b_lenh varchar2(1000); b_nv varchar2(10); b_ttrang varchar2(1);
    b_dvi_ks varchar2(10):=''; b_nsd_ks varchar2(10):=''; b_so_hd varchar2(20);

    a_ma_dt pht_type.a_var; a_nt_tien pht_type.a_var; a_nt_phi pht_type.a_var;
    a_lh_nv pht_type.a_var; a_t_suat pht_type.a_num; a_pt pht_type.a_num; a_ptG pht_type.a_num;
    a_tien pht_type.a_num; a_phi pht_type.a_num; a_thue pht_type.a_num; a_ttoan pht_type.a_num;

    a_so_id_dt pht_type.a_num; a_dt_ma_dt pht_type.a_var; a_dt_nt_tien pht_type.a_var; a_dt_nt_phi pht_type.a_var;
    a_dt_lh_nv pht_type.a_var; a_dt_t_suat pht_type.a_num; a_dt_pt pht_type.a_num; a_dt_ptG pht_type.a_num;
    a_dt_tien pht_type.a_num; a_dt_phi pht_type.a_num; a_dt_thue pht_type.a_num; a_dt_ttoan pht_type.a_num;

    tt_ngay pht_type.a_num; tt_ma_nt pht_type.a_var; tt_tien pht_type.a_num;
    a_bang pht_type.a_var; r_hd bh_hd_goc%rowtype;
begin
select * into r_hd from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ttrang:=r_hd.ttrang;
if b_ttrang not in('T','D') then return; end if;
b_nv:=r_hd.nv; b_so_hd:=r_hd.so_hd; PKH_MANG_KD_N(a_so_id_dt);
if b_ttrang='D' then
    PBH_PQU_HD(b_nv,b_ma_dviN,b_nsd,b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
if b_nv='PHH' then
    PBH_PHH_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='PKT' then
    PBH_PKT_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='XE' then
    PBH_XE_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='2B' then
    PBH_2B_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='TAU' then
    PBH_TAU_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='NG' then
    PBH_NG_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='HANG' then
    PBH_HANG_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,
        a_tien,a_phi,a_thue,a_ttoan,tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='PTN' then
    PBH_PTN_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,
        a_tien,a_phi,a_thue,a_ttoan,tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='HOP' then
    PBH_HOP_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,
    a_tien,a_phi,a_thue,a_ttoan,tt_ngay,tt_ma_nt,tt_tien,b_loi);
elsif b_nv='NONG' then
    PBH_NONG_NV(b_ma_dvi,b_so_id,a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_ptG,a_tien,a_phi,a_thue,a_ttoan,
        a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_ptG,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
        tt_ngay,tt_ma_nt,tt_tien,b_loi);
end if;
if b_loi is not null then return; end if;
PBH_HD_GOC_NH_PT(b_ma_dvi,b_so_id,r_hd.so_id_d,r_hd.so_id_g,r_hd.ngay_ht,r_hd.kieu_kt,r_hd.ma_kt,
    a_ma_dt,a_nt_tien,a_nt_phi,a_lh_nv,a_t_suat,a_pt,a_tien,a_phi,a_thue,a_ttoan,
    a_so_id_dt,a_dt_ma_dt,a_dt_nt_tien,a_dt_nt_phi,a_dt_lh_nv,a_dt_t_suat,a_dt_pt,a_dt_tien,a_dt_phi,a_dt_thue,a_dt_ttoan,
    tt_ngay,tt_ma_nt,tt_tien,b_loi);
if b_loi is not null then return; end if;
if b_ma_dvi<>b_ma_dviN or b_nsd<>r_hd.nsd then b_nsd_ks:=b_nsd; b_dvi_ks:=b_ma_dviN; end if;
if b_du='C' then
    PBH_HD_DU_NV(b_nv,b_ma_dvi,b_so_id,b_dvi_ks,b_nsd_ks,b_ttrang,b_so_hd,b_loi);
    if b_loi is not null then return; end if;
end if;
update bh_hd_goc set so_hd=b_so_hd,dvi_ksoat=b_dvi_ks,ksoat=b_nsd_ks,
    ttrang=b_ttrang,so_id_kt=0 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.kieu_hd='U' then b_loi:=''; return; end if;
if b_ttrang='T' then
    PTBH_TMB_CBI_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
else
    if r_hd.kieu_hd<>'K' then
        PBH_HD_GOC_THL_CT(b_ma_dvi,r_hd.so_id_d,b_loi,b_so_id);
        if b_loi is not null then return; end if;
    end if;
    PTBH_TMB_CH(b_ma_dvi,b_nsd,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_CBI_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_UP_NH:loi'; end if;
end;
/
create or replace procedure PBH_HD_UP_XOA(
    b_ma_dvi varchar2,b_so_id number,b_dvi_ksoatN varchar2,b_ksoatN varchar2,
    b_loi out varchar2,b_du varchar2:='K',b_nh varchar2:='X')
AS
    b_i1 number; b_i2 number; b_so_hd varchar2(20);
    b_nv varchar2(10); b_kieu_hd varchar2(1); b_so_idD number; b_ngay_ht number;
    b_ttrang varchar2(1); b_dvi_ksoat varchar2(10); b_ksoat varchar2(10);
    a_ma_dvi_hd pht_type.a_var; a_so_id_hd pht_type.a_num;
begin 
-- Dan - Xoa hop dong goc
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nv,kieu_hd,so_id_d,ttrang,dvi_ksoat,ksoat,so_hd,ngay_ht into
    b_nv,b_kieu_hd,b_so_idD,b_ttrang,b_dvi_ksoat,b_ksoat,b_so_hd,b_ngay_ht
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ttrang='H' then b_loi:='loi:Hop dong/GCN da huy:loi'; return; end if;
if b_ttrang='D' then 
  -- duong them ham kiem tra 
  -- neu don da duyet ngoai khoang thoi gian cau hinh tham so thi chan khong cho sua don
  b_loi:= FBH_HD_KTRA_NHAP(b_ma_dvi,b_so_id);
  if trim(b_loi) is not null then return; end if;
end if;
if b_ttrang not in('T','D') then b_loi:=''; return; end if;
if trim(b_ksoat) is not null and (b_dvi_ksoatN<>b_dvi_ksoat or b_ksoatN<>b_ksoat) then
    b_loi:='loi:Nguoi khac duyet:loi'; return;
end if;
if b_ttrang='D' then
    select nvl(max(ngay_ht),0) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD;
    if b_i1>b_ngay_ht then b_loi:='loi:Hop dong/GCN da thanh toan phi:loi'; return; end if;
    if b_kieu_hd<>'U' then
        --nampb: kiem tra HD/GCN da xu ly tai
        select count(*) into b_i1 from tbh_tm_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
        if b_i1=0 then 
           select count(*) into b_i1 from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
        end if;
        if b_i1<>0 then b_loi:='loi:Hop dong/GCN da xu ly tai:loi'; return; end if;
        PTBH_GHEP_TD_XOA(b_ma_dvi,b_so_idD,a_ma_dvi_hd,a_so_id_hd,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
PBH_GCNE_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TMB_CBI_XOA(b_ma_dvi,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
PTBH_CBI_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_HD_GOC_XOA_NV(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_du='C' then
    PBH_HD_DU_NV(b_nv,b_ma_dvi,b_so_id,'','','T',b_so_hd,b_loi);
    if b_loi is not null then return; end if;
end if;
update bh_hd_goc set so_hd=b_so_hd,ksoat='',dvi_ksoat='',ttrang='T',so_id_kt=-1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kieu_hd='U' then b_loi:=''; return; end if;
if b_kieu_hd='K' then
    PBH_HD_GOC_THL_KEM(b_ma_dvi,b_so_idD,b_loi);
else
    PBH_HD_GOC_THL_CT(b_ma_dvi,b_so_idD,b_loi,b_so_id);
end if;
if b_ttrang='D' and a_ma_dvi_hd.count<>0 then
    PTBH_CBI(a_ma_dvi_hd,a_so_id_hd,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_UP_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_NH(b_oraIn clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_cot varchar2(1000);
    b_ma_dvi varchar2(10); b_nsd varchar2(10); b_so_id number; b_so_hd varchar2(20); b_kieu_hd varchar2(1); b_nv varchar2(10);
    b_ngay_ht number; b_ngay_cap number; b_ngay_hl number; b_ngay_kt number; b_cb_ql varchar2(20);
    b_phong varchar2(10); b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_dly_tke varchar2(20);
    b_hhong number; b_pt_hhong varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_kieu_gt varchar2(1);
    b_c_thue varchar2(1); b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tien number; b_phi number; b_thue number;
    b_ma_gt varchar2(20); b_ksoat varchar2(10); b_so_idD number; b_so_idG number;
    b_ttrang varchar2(1); b_dvi_ksoat varchar2(10); bangG varchar2(50);
begin 
-- Dan - nhap HD goc
b_cot:='ma_dvi,nsd,so_id,so_hd,kieu_hd,nv,ngay_ht,ngay_cap,ngay_hl,ngay_kt,cb_ql,phong,kieu_kt,ma_kt,dly_tke,';
b_cot:=b_cot||'hhong,pt_hhong,ma_kh,ten,kieu_gt,ma_gt,so_id_d,so_id_g,ttrang,dvi_ksoat,ksoat,bangg,nt_tien,nt_phi,tien,phi,thue';
b_lenh:=FKH_JS_LENH(b_cot);
EXECUTE IMMEDIATE b_lenh into 
    b_ma_dvi,b_nsd,b_so_id,b_so_hd,b_kieu_hd,b_nv,b_ngay_ht,b_ngay_cap,b_ngay_hl,b_ngay_kt,b_cb_ql,
    b_phong,b_kieu_kt,b_ma_kt,b_dly_tke,b_hhong,b_pt_hhong,b_ma_kh,b_ten,b_kieu_gt,
    b_ma_gt,b_so_idD,b_so_idG,b_ttrang,b_dvi_ksoat,b_ksoat,bangG,
    b_nt_tien,b_nt_phi,b_tien,b_phi,b_thue using b_oraIn;
insert into bh_hd_goc values(b_ma_dvi,b_so_id,b_so_hd,b_kieu_hd,b_nv,b_ngay_ht,
    b_ngay_cap,b_ngay_hl,b_ngay_kt,b_cb_ql,b_phong,b_kieu_kt,b_ma_kt,b_dly_tke,
    b_hhong,b_pt_hhong,b_ma_kh,b_ten,b_kieu_gt,b_ma_gt,
    b_c_thue,b_nt_tien,b_nt_phi,b_tien,b_phi,b_thue,
    b_nsd,b_so_idD,b_so_idG,0,b_ttrang,b_dvi_ksoat,b_ksoat,bangG);
PBH_HD_UP_NH(b_ma_dvi,b_so_id,b_ma_dvi,b_nsd,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_NH:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='X')
AS
begin
-- Dan - Xoa hd go
PBH_HD_GOC_TEST(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
PBH_HD_UP_XOA(b_ma_dvi,b_so_id,b_ma_dvi,b_nsd,b_loi,'K',b_nh);
if b_loi is not null then return; end if;
PBH_HD_GOC_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_nh);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='X')
AS
    b_so_idD number; b_i1 number;
begin 
-- Dan - Xoa hop dong goc
if b_nh='X' then
    b_so_idD:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
    if b_so_idD=b_so_id then
        delete bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_do_ps where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_sc_phi where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_sc_no where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_dkbs where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        delete bh_hd_goc_rr where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        select count(*) into b_i1 from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        if b_i1=0 then
            delete bh_hd_do where ma_dvi=b_ma_dvi and so_id=b_so_idD;
            delete bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        end if;
    end if;
end if;
delete bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_HD_GOC_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='X')
AS
    b_ngay_ht number; b_kieu_hd varchar2(1); b_i1 number; b_nv varchar2(10); b_so_idD number;
    b_dvi_ksoat varchar2(10); b_ksoat varchar2(10); b_ttrang varchar2(1); b_so_hd varchar2(20);
begin 
-- Dan - Test truoc khi xoa hop dong goc
select count(*) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select so_hd,so_id_d,so_id_kt,ngay_ht,kieu_hd,nv,dvi_ksoat,ksoat,ttrang
    into b_so_hd,b_so_idD,b_i1,b_ngay_ht,b_kieu_hd,b_nv,b_dvi_ksoat,b_ksoat,b_ttrang
    from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>0 then b_loi:='loi:Khong sua, xoa hop dong, GCN da hach toan ke toan:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH',b_nv,'KT');
if b_loi is not null then return; end if;
select count(*) into b_i1 from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_idD;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa hop dong, GCN da huy:loi'; return; end if;
select nvl(max(so_id),0) into b_i1 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
if b_i1>b_so_id then b_loi:='loi:Khong sua, xoa hop dong, GCN da sua doi bo sung:loi'; return; end if;
if b_ttrang='D' then
    if trim(b_ksoat) is not null and (b_ksoat<>b_nsd or b_dvi_ksoat<>b_ma_dvi) then
        b_loi:='loi:Khong sua, xoa hop dong, GCN da kiem soat:loi'; return;
    end if;
    if b_kieu_hd<>'U' then
        select nvl(max(so_id),0) into b_i1 from tbh_tm_hd b where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
        if b_i1>b_so_id then b_loi:='loi:Khong sua, xoa hop dong, GCN da xu ly tai tam thoi:loi'; return; end if;
        select nvl(max(so_id),0) into b_i1 from bh_bt_hs where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_idD;
        if b_i1>b_so_id then b_loi:='loi:Khong sua, xoa hop dong, GCN da lap ho so boi thuong:loi'; return; end if;
        for r_lp in(select distinct so_id from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD) loop
            select count(*) into b_i1 from tbh_ps where so_id=r_lp.so_id;
            if b_i1<>0 then b_loi:='loi:Da phat sinh tai:loi'; return; end if;
        end loop;
    end if;
    if b_kieu_hd not in('U','K') then
        select nvl(max(so_id),0) into b_i1 from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_idD;
        if b_i1>b_so_id  then b_loi:='loi:Khong sua, xoa hop dong, GCN da thanh toan phi:loi'; return; end if;
    end if;
elsif b_ttrang='T' and b_nh<>'N' then
    select nvl(max(so_id),0) into b_i1 from tbh_tmB_hd where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_idD;
    if b_i1>b_so_id then
        b_loi:='loi:Khong sua, xoa hop dong, GCN da xu ly chao tai tam thoi:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_GOC_TEST:loi'; end if;
end;
/
/*** CHUYEN TAI ***/
create or replace function FBH_HD_CTA(b_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra tinh trang hop dong da chuyen tai
select count(*) into b_i1 from bh_hd_cta where dvi=b_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace PROCEDURE PBH_HD_CTA_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ngayd number,b_ngayc number,
    b_dvi varchar2,b_klk varchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','CTA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi)='K' then
    b_loi:='loi:Khong vuot quyen:loi'; raise PROGRAM_ERROR;
end if;
if b_klk='D' then
    select count(*) into b_dong from bh_hd_cta where dvi=b_dvi and nv=b_nv and ngay_ht between b_ngayd and b_ngayc;
    if b_den_n=1000000 then b_den:=b_dong; b_tu:=b_dong-b_tu_n; end if;
    open cs_lke for select so_id,so_hd from (select so_id,so_hd,row_number() over (order by ngay_ht,so_id) sott from bh_hd_cta 
        where dvi=b_dvi and nv=b_nv and ngay_ht between b_ngayd and b_ngayc order by ngay_ht,so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hd_goc where ma_dvi=b_dvi and nv=b_nv and ngay_ht between b_ngayd and b_ngayc
        and ttrang='D' and FBH_HD_KIEU_HD(ma_dvi,so_id)<>'U' and FBH_HD_CTA(ma_dvi,so_id)='K';
    if b_den_n=1000000 then b_den:=b_dong; b_tu:=b_dong-b_tu_n; end if;
    open cs_lke for select so_id,so_hd from (select so_id,so_hd,row_number() over (order by ngay_ht,so_id) sott
        from bh_hd_goc where ma_dvi=b_dvi and nv=b_nv and ngay_ht between b_ngayd and b_ngayc
        and ttrang='D' and FBH_HD_KIEU_HD(ma_dvi,so_id)<>'U' and FBH_HD_CTA(ma_dvi,so_id)='K' order by ngay_ht,so_id) where sott between b_tu and b_den;
end if;
exception when others then
    if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_CTA_NH(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_i1 number; b_nv varchar2(10); b_nsd_c varchar2(10);
    b_ngay_ht number; b_ttrang varchar2(1); b_so_hd varchar2(50);
begin
-- Dan - Nhap
if b_dvi is null or b_so_id is null then b_loi:='loi:Nhap chi tiet:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong, GCN da xoa:loi';
select nv,ngay_ht,ttrang,so_hd into b_nv,b_ngay_ht,b_ttrang,b_so_hd from bh_hd_goc where ma_dvi=b_dvi and so_id=b_so_id;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','CTA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi)='K' then b_loi:='loi:Khong vuot quyen:loi';
elsif b_ttrang is null or b_ttrang<>'D' then b_loi:='loi:Hop dong chua duoc duyet:loi';
elsif b_ttrang='H' then b_loi:='loi:Hop dong da huy:loi';
elsif FBH_HD_KIEU_HD(b_dvi,b_so_id)='U' then b_loi:='loi:Sai kieu hop dong:loi';
elsif FBH_HT_THUE_TS(b_ma_dvi,b_ngay_ht,'ch_ta')='C' then b_loi:='loi:Chuyen tai tu dong:loi';
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(nsd),count(*) into b_nsd_c,b_i1 from bh_hd_cta where dvi=b_dvi and so_id=b_so_id;
if b_i1<>0 then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then
        b_loi:='loi:Khong sua,xoa NSD khac da chuyen tai:loi';
    else
        b_loi:='loi:Loi Table BH_HD_KSOAT:loi';
        delete bh_hd_cta where dvi=b_dvi and so_id=b_so_id;
        PTBH_CBI_XOA(b_dvi,b_so_id,b_loi);
    end if;
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Loi Table BH_HD_KSOAT:loi';
insert into bh_hd_cta values(b_ma_dvi,b_dvi,b_nv,b_ngay_ht,b_so_id,b_so_hd,b_nsd,sysdate);
PTBH_CBI_NH(b_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_CTA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_i1 number; b_nv varchar2(10); b_nsd_c varchar2(10);
begin
-- Dan - Xoa
if b_dvi is null or b_so_id is null then b_loi:='loi:Nhap chi tiet:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Hop dong, GCN da xoa:loi';
select nv into b_nv from bh_hd_goc where ma_dvi=b_dvi and so_id=b_so_id;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','CTA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FHT_MA_NSD_DVI(b_ma_dvi,b_nsd,'BH',b_nv,'X',b_dvi)='K' then
    b_loi:='loi:Khong vuot quyen:loi'; raise PROGRAM_ERROR;
end if;
select min(nsd),count(*) into b_nsd_c,b_i1 from bh_hd_cta where dvi=b_dvi and so_id=b_so_id;
if b_i1<>0 then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then
        b_loi:='loi:Khong xoa NSD khac da chuyen tai:loi';
    else
        b_loi:='loi:Loi Table BH_HD_KSOAT:loi';
        delete bh_hd_cta where dvi=b_dvi and so_id=b_so_id;
        PTBH_CBI_XOA(b_dvi,b_so_id,b_loi);
    end if;
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_TRA_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_so_hd varchar2,b_so_id out number)
AS
    b_loi varchar2(100);
begin
-- Dan - tra so ID hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_dvi is null or b_so_hd is null then b_loi:='loi:Don vi, so hop dong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FBH_HD_GOC_SO_ID(b_dvi,b_so_hd);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FBH_HD_KTRA_TT(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_loi varchar2(100):=''; b_i1 number; b_i2 number; b_so_id_d number;
begin
-- Dan - Kiem tra ngay thanh toan
select so_id_d,ngay_ht into b_so_id_d,b_i2 from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=FBH_HD_TT_CUOI(b_ma_dvi,b_so_id_d);
if b_i1>b_i2 then
    b_loi:='loi:Khong sua goc, sua doi sau ngay da thanh toan phi: '||PKH_SO_CNG(b_i1)||':loi';
end if;
return b_loi;
end;
/
create or replace procedure FBH_HD_BSSD_LKE(b_ma_dvi varchar2,b_so_id number,b_ngay number,
    a_so_id out pht_type.a_num,a_ngay out pht_type.a_num,a_ngay_hl out pht_type.a_num,a_ngay_kt out pht_type.a_num)
AS
    b_so_id_d number; b_ngay_hl number; b_ngay_kt number; b_bt number:=0;
    a_so_id_x pht_type.a_num; a_ngay_x pht_type.a_num;
begin
-- Dan - Liet ke cac ky sua doi
PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_ngay); PKH_MANG_KD_N(a_ngay_hl); PKH_MANG_KD_N(a_ngay_kt);
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
for b_lp in 1..a_so_id_x.count loop
    select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=a_so_id_x(b_lp);
    if b_ngay_hl<a_ngay(b_lp) or b_lp=a_so_id.count then
        b_bt:=b_bt+1;
        a_so_id(b_bt):=a_so_id_x(b_lp); a_ngay(b_bt):=a_ngay_x(b_lp);
        a_ngay_hl(b_bt):=b_ngay_hl; a_ngay_kt(b_bt):=b_ngay_kt;
    end if;
end loop;
end;
/
create or replace procedure FBH_HD_BSSD_PHI
    (b_ma_dvi varchar2,b_so_id number,b_ngXl number,b_nt_tien varchar2,b_nt_phi varchar2,
    a_so_id_kq out pht_type.a_num,a_lh_nv_kq out pht_type.a_var,a_phi_kq out pht_type.a_num)
AS
    b_ngT number; b_ngS number; b_ngT_dt number; b_ngS_dt number; b_ng number; b_tien number; b_kt number:=0; b_bt number; b_i1 number;
    a_so_id pht_type.a_num; a_ngcap pht_type.a_num; a_nghl pht_type.a_num; a_ngkt pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var; a_tien pht_type.a_num; a_phi pht_type.a_num; a_nghl_dt pht_type.a_num; a_ngkt_dt pht_type.a_num;
    a_tien_kq pht_type.a_num;
begin
-- Dan - Tinh phi trung binh
PKH_MANG_KD_N(a_so_id_kq); PKH_MANG_KD(a_lh_nv_kq);
FBH_HD_BSSD_LKE(b_ma_dvi,b_so_id,b_ngXl,a_so_id,a_ngcap,a_nghl,a_ngkt);
b_bt:=a_so_id.count;
for b_lp in 1..b_bt loop
    if b_lp=1 then b_ngT:=a_nghl(b_lp); else b_ngT:=a_ngcap(b_lp); end if;
    if b_lp=b_bt then b_ngS:=a_ngkt(b_lp); else b_ngS:=a_ngcap(b_lp+1); end if;
    if b_ngT<a_nghl(b_lp) then b_ngT:=a_nghl(b_lp); end if;
    if b_ngS>a_ngkt(b_lp) then b_ngS:=a_ngkt(b_lp); end if;
    if b_ngT<b_ngS then
      -- LAM SACH
--         FBH_HD_BSSD_TIEN(b_ma_dvi,a_so_id(b_lp),b_ngXl,b_nt_tien,b_nt_phi,a_so_id_dt,a_lh_nv,a_tien,a_phi,a_nghl_dt,a_ngkt_dt);
        for b_lp1 in 1..a_so_id_dt.count loop
            if b_ngT<a_nghl_dt(b_lp1) then b_ngT_dt:=a_nghl_dt(b_lp1); else b_ngT_dt:=b_ngT; end if;
            if b_ngS>a_ngkt_dt(b_lp1) then b_ngS_dt:=a_ngkt_dt(b_lp1); else b_ngS_dt:=b_ngS; end if;
            if b_ngT_dt<b_ngS_dt then
                b_tien:=(PKH_SO_CDT(b_ngS_dt)-PKH_SO_CDT(b_ngT_dt))*a_tien(b_lp1);
                b_i1:=0;
                for b_lp2 in 1..b_kt loop
                    if a_so_id_kq(b_lp2)=a_so_id_dt(b_lp1) and a_lh_nv_kq(b_lp2)=a_lh_nv(b_lp1) then b_i1:=b_lp2; exit; end if;
                end loop;
                if b_i1=0 then
                    b_kt:=b_kt+1;
                    a_so_id_kq(b_kt):=a_so_id_dt(b_lp1); a_lh_nv_kq(b_kt):=a_lh_nv(b_lp1); a_tien_kq(b_kt):=b_tien;
                else
                    a_tien_kq(b_i1):=a_tien_kq(b_i1)+b_tien;
                end if;
            end if;
        end loop;
    end if;
end loop;
-- FBH_HD_BSSD_TIEN(b_ma_dvi,a_so_id(b_bt),b_ngXl,b_nt_tien,b_nt_phi,a_so_id_dt,a_lh_nv,a_tien,a_phi,a_nghl_dt,a_ngkt_dt);
for b_lp2 in 1..b_kt loop
    a_phi_kq(b_lp2):=0;
    if a_tien_kq(b_lp2)<>0 then
        for b_lp1 in 1..a_so_id_dt.count loop
            if a_so_id_kq(b_lp2)=a_so_id_dt(b_lp1) and a_lh_nv_kq(b_lp2)=a_lh_nv(b_lp1) and a_phi(b_lp1)<>0 then
                a_phi_kq(b_lp2):=round(a_phi(b_lp1)/a_tien_kq(b_lp2),4); exit;
            end if;
        end loop;
    end if;
end loop;
end;

/ 
create or replace procedure PBH_HD_NGAY_HLDT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay_ht number,b_ngay_hl out number,b_ngay_kt out number)
AS
    b_so_id_bs number; b_nv varchar2(10);
begin
-- Dan - Tra ngay hieu luc doi tuong
b_so_id_bs:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id,b_ngay_ht);
select nv,ngay_hl,ngay_kt into b_nv,b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id_bs;
if b_nv='XE' then
    select nvl(min(ngay_hl),b_ngay_hl),nvl(min(ngay_kt),b_ngay_kt) into b_ngay_hl,b_ngay_kt
        from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=b_so_id_dt;
elsif b_nv='PHH' then
    select nvl(min(ngay_hl),b_ngay_hl),nvl(min(ngay_kt),b_ngay_kt) into b_ngay_hl,b_ngay_kt
        from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=b_so_id_dt;
elsif b_nv='PKT' then
    select nvl(min(ngay_hl),b_ngay_hl),nvl(min(ngay_kt),b_ngay_kt) into b_ngay_hl,b_ngay_kt
        from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=b_so_id_dt;
elsif b_nv='NG' then
    select nvl(min(ngay_hl),b_ngay_hl),nvl(min(ngay_kt),b_ngay_kt) into b_ngay_hl,b_ngay_kt
        from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=b_so_id_dt;
elsif b_nv='TAU' then
    select nvl(min(ngay_hl),b_ngay_hl),nvl(min(ngay_kt),b_ngay_kt) into b_ngay_hl,b_ngay_kt
        from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=b_so_id_dt;
elsif b_nv='2B' then
    select nvl(min(ngay_hl),b_ngay_hl),nvl(min(ngay_kt),b_ngay_kt) into b_ngay_hl,b_ngay_kt
        from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_bs and so_id_dt=b_so_id_dt;
end if;
end;
/
--duchq update length email
create or replace procedure PBH_HD_TRA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(200); cs_lke clob:='';
    b_so_id number; b_so_idC number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngayD number;
begin
-- Dan - Tra cuu hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_cmt,b_mobi,b_email using b_oraIn;
if trim(b_cmt||b_mobi||b_email) is null then b_loi:='loi:Toi thieu nhap cmt/ma so thue, mobi, eMail:loi'; raise PROGRAM_ERROR; end if;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36));
for r_lp in (select distinct ma_dvi,so_id_d from bh_hd_goc where ma_kh=b_ma_kh and ttrang='D' and ngay_ht>b_ngayD) loop
    b_so_idC:=FBH_HD_SO_ID_BS(r_lp.ma_dvi,r_lp.so_id_d);
    select max(so_hd) into b_so_hd from bh_hd_goc where ma_dvi=r_lp.ma_dvi and so_id=b_so_idC;
    insert into ket_qua(c1,c3,n1,n2,n3,c10,c11,n10)
        select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,nv,ma_dvi,b_so_idC
        from bh_hd_goc where ma_dvi=r_lp.ma_dvi and so_id=b_so_idC;
end loop;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'ten' value c3,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,
    'ma_dvi' value b_ma_dvi,'nv' value c10,'ma_dvi' value c11,'so_id' value n10 returning clob)
    order by c1 desc returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
create or replace procedure PBH_HD_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:=''; b_tu number; b_den number;
    b_nv varchar2(1); b_ma_kh varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_phong varchar2(10);
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete bh_hd_goc_tim_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HD','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,cmt,mobi,email,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_tu,b_den using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_nv:=nvl(trim(b_nv),'*');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select count(*) into b_dong from bh_hd_goc where ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        insert into bh_hd_goc_tim_temp select ngay_ht,nv,so_hd,ttrang,ten,ma_dvi,so_id,ma_kh from
            (select ngay_ht,nv,so_hd,ttrang,ten,ma_dvi,so_id,ma_kh,rownum sott from bh_hd_goc where
            ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0 and b_nv in('*',nv) order by ngay_ht desc,nv,so_hd)
            where sott between b_tu and b_den;
    end if;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_hd_goc where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        insert into bh_hd_goc_tim_temp select ngay_ht,nv,so_hd,ttrang,ten,ma_dvi,so_id,ma_kh from
            (select ngay_ht,nv,so_hd,ttrang,ten,ma_dvi,so_id,ma_kh,rownum sott from bh_hd_goc where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and phong=b_phong and so_id_g=0 and b_nv in('*',nv) order by ngay_ht desc,nv,so_hd)
            where sott between b_tu and b_den;
    end if;
end if;
select JSON_ARRAYAGG(json_object(*) order by ngay_ht desc,nv,so_hd returning clob) into cs_lke from bh_hd_goc_tim_temp;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete bh_hd_goc_tim_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- duong them fbh kiem tra chan khong cho sua don da duyet
CREATE OR REPLACE FUNCTION FBH_HD_KTRA_NHAP(b_ma_dvi VARCHAR2,b_so_id NUMBER)
RETURN varchar2
AS
    b_nv        VARCHAR2(10);
    b_nv_ng     VARCHAR2(10);
    b_ngay_nh   DATE;
    b_tgian_tso NUMBER:= 0;
    b_sql       VARCHAR2(4000);
    b_tgian_nh number;
    b_i1 number;
    b_loi nvarchar2(1000):= '';b_ttrang varchar2(1);
BEGIN
    -- lay thoi gian cau hinh tso
    SELECT count(*) INTO b_i1  FROM bh_tso_ht_job WHERE ma = 'DUYET';
    if b_i1 <> 0 then
       SELECT tgian INTO b_tgian_tso  FROM bh_tso_ht_job WHERE ma = 'DUYET';
    end if;
    SELECT nv,ttrang INTO b_nv,b_ttrang FROM bh_hd_goc WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
    IF b_nv IN ('PHH','PKT','XE','2B','TAU','HANG','HOP') THEN
       b_sql := 'SELECT ngay_nh  FROM bh_' || LOWER(b_nv) ||
          ' AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL ''0'' MINUTE) WHERE ma_dvi = :1  AND so_id = :2';
        begin
          EXECUTE IMMEDIATE b_sql INTO b_ngay_nh USING b_ma_dvi, b_so_id;
        exception
        WHEN others THEN
            b_sql := 'SELECT ngay_nh  FROM bh_' || LOWER(b_nv) ||
            ' AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL ''0'' MINUTE) WHERE ma_dvi = :1  AND so_id = :2';
            EXECUTE IMMEDIATE b_sql INTO b_ngay_nh USING b_ma_dvi, b_so_id;
        end;
    ELSIF b_nv = 'NG' THEN
        SELECT COUNT(*) INTO b_i1 FROM bh_ng WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
        IF b_i1 > 0 THEN
            SELECT nv INTO b_nv_ng FROM bh_ng WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            IF b_nv_ng IN ('SKG','SKT','SKC') THEN
              --nam: suc khoe to chuc cho sua doi don da duyet khi khong co danh sach 
                if b_nv_ng='SKT' then 
                  select COUNT(*) INTO b_i1 FROM bh_ng_ds WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
                  if b_i1 > 0 then
                     SELECT ngay_nh INTO b_ngay_nh FROM bh_sk AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
                  else 
                     b_ngay_nh:=SYSDATE;
                  end if;
                else 
                  SELECT ngay_nh INTO b_ngay_nh FROM bh_sk AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
                end if;
            ELSIF b_nv_ng = 'TDC' THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_ngtd AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            ELSIF b_nv_ng IN ('DLG','DLC','DLT') THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_ngdl AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            END IF;
        END IF;
     ELSIF b_nv = 'PTN' THEN
        SELECT COUNT(*) INTO b_i1 FROM bh_ptn WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
        IF b_i1 > 0 THEN
            SELECT nv INTO b_nv_ng FROM bh_ptn WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            --bh_ptncc,bh_ptnnn,bh_ptnvc
            IF b_nv_ng IN ('TNVC') THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_ptnvc AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            ELSIF b_nv_ng = 'TNCC' THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_ptncc AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            ELSIF b_nv_ng IN ('TNNN') THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_ptnnn AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            END IF;
        END IF;
    ELSIF b_nv = 'NONG' THEN
        SELECT COUNT(*) INTO b_i1 FROM bh_nong WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
        IF b_i1 > 0 THEN
            SELECT nv INTO b_nv_ng FROM bh_nong WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            IF b_nv_ng IN ('CT') THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_nongct AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            ELSIF b_nv_ng = 'TS' THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_nongts AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            ELSIF b_nv_ng IN ('VN') THEN
                SELECT ngay_nh INTO b_ngay_nh FROM bh_nongvn AS OF TIMESTAMP (SYSTIMESTAMP - INTERVAL '0' MINUTE) WHERE ma_dvi = b_ma_dvi AND so_id = b_so_id;
            END IF;
        END IF;
    END IF;
    b_tgian_nh:= ROUND((SYSDATE - b_ngay_nh) * 24 * 60);
    b_loi:= '';
    if b_tgian_tso <= b_tgian_nh and b_ttrang='D' THEN
        b_loi:='loi:Khong sua, xoa hop dong/GCN da duyet:loi';
    end if;
    return b_loi;
END;
/
create or replace procedure PHD_PH_DON(b_ma_dvi varchar2,b_nv varchar2,b_ngay number,b_so_id number,
    a_ma pht_type.a_var,a_seri pht_type.a_var,a_so_c pht_type.a_var,b_ma_cb varchar2,b_ma_dl varchar2,b_loi out varchar2)
AS
    a_ma_m pht_type.a_var;a_seri_m pht_type.a_var;a_dau pht_type.a_num;a_cuoi pht_type.a_num;a_tke pht_type.a_var;a_gia pht_type.a_num;
    a_quyen pht_type.a_var;
    b_ma varchar2(10);b_seri varchar2(10);b_so number;b_id number;b_gia number;b_bp varchar2(10);b_i1 number;
    b_loai varchar2(1); b_phong varchar2(10);b_so_ct varchar2(20);b_i number;b_loai_x VARCHAR2(2);b_ma_x varchar2(10);b_loi_d varchar2(100);
begin
--Lan--Goi nhap ctu hoa don khi Phat hanh an chi--
b_id:=0;
if b_nv='X' then
    select nvl(min(so_id),0),count(*) into b_id,b_i1 from hd_1 where ma_dvi=b_ma_dvi and so_id_bh=b_so_id;
    if b_id=0 then --Xu ly cac don khong dua so_id_bh sang
        PHD_PH_DON_X(b_ma_dvi,b_ngay,a_ma,a_seri,a_so_c,b_loi_d);
    else
        if b_i1>1 then
            b_id:=0; b_ma:=a_ma(1); b_seri:=a_seri(1); b_so:=PKH_LOC_CHU_SO(a_so_c(1));
            for b_lp in (select so_id from hd_1 where ma_dvi=b_ma_dvi and so_id_bh=b_so_id) loop
                select nvl(min(so_id),0) into b_id from hd_2 where ma_dvi=b_ma_dvi and so_id=b_lp.so_id
                    and ma=b_ma and b_so between dau and cuoi;
                if b_id<>0 then exit; end if;
            end loop;
        end if;
        PHD_CT_XOA_XOA(b_ma_dvi,b_ma_cb,b_id,b_loi_d,'NV');
    end if;
    if b_loi_d is not null then b_loi:=b_loi_d; return; end if;
else
    --select count(*) into b_i from ht_ma_dvi where ten like '%MIC%' or ten like '%B?o hi?m B?u ?i?n%' or ten like '%SHB-VINACOMIN%';
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_ma_cb);
    delete temp_sl;
    for b_lop in 1..a_ma.count loop
        if length(a_so_c(b_lop)) >= 7 then
          b_so:=to_number(substr(a_so_c(b_lop),-7));
        else
          b_so:=PKH_LOC_CHU_SO(a_so_c(b_lop));
        end if;
        b_so:=to_number(b_so); b_ma:=substr(a_ma(b_lop),1,10); b_seri:=nvl(a_seri(b_lop),' ' );
        PHD_HOI_BP(b_ma_dvi,b_ngay,b_ma,b_so,b_seri,b_loai,b_bp);
        if not ((b_loai='C' and b_ma_cb=b_bp) or (b_loai='B' and b_bp=b_phong) or (b_loai='L' and b_bp=b_ma_dl)) then
            b_loi:='loi:So hoa don khong co trong so cai. Loai: '|| b_loai || ' - Ma Can Bo:' || b_ma_cb || ' - Ma Bo Phan: ' || b_bp ||  ' So An Chi : ' || FKH_GHEP_SERI(b_ma,b_seri,b_so,'')||':loi';
            return;
        end if;
        select nvl(min(n1),0) into b_i from temp_sl where c1=b_ma and n1=b_so;
        if b_i<>0 then
            b_loi:='loi:Trung GCN so '||FKH_GHEP_SERI(b_ma,b_seri,b_so,'')||':loi';
            return;
        else
            insert into temp_sl(c1,c2,n1) values (b_ma,b_seri,b_so);
        end if;
    end loop;
    delete temp_3;
    insert into temp_3(c1,c2) select distinct c1,c2 from temp_sl;
    b_i:=0;
    for b_lp in (select c1,c2 from temp_3 order by c1,c2) loop
        delete hd_sc_bc_so;
        for b_lp1 in (select n1 from temp_sl where c1=b_lp.c1 and c2=b_lp.c2 order by n1) loop
            BC_HD_TH_BC_SO(b_lp1.n1,b_lp1.n1);
        end loop;
        for b_lp2 in (select dau,cuoi from hd_sc_bc_so order by dau) loop
            b_i:=b_i+1;
            a_ma_m(b_i):=b_lp.c1; a_seri_m(b_i):=b_lp.c2; a_quyen(b_i):=0; a_dau(b_i):=b_lp2.dau; a_cuoi(b_i):=b_lp2.cuoi; a_gia(b_i):=0; a_tke(b_i):='D';
        end loop;
    end loop;
    b_so_ct:=a_ma_m(1)||'/'||trim(to_char(a_dau(1)));
    PHD_CT_NH_NH(b_ma_dvi,b_ma_cb,b_ngay,'H',b_id,b_so_id,'X',b_so_ct,PKH_SO_CDT(b_ngay),'','','','Xuat tu dong',a_ma_m,a_seri_m,a_quyen,a_dau,a_cuoi,a_tke,a_gia,b_loi);
    if b_loi_d is not null then b_loi:=b_loi_d; return; end if;
end if;
end;
/
create or replace function FBH_HD_SO_ID_BAO(b_ma_dvi varchar2,b_so_id number) return number
AS
    b_so_id_d number; b_so_id_g number; b_so_id_b number;
begin
-- Dan - Tra so ID dau cua hop dong bao
b_so_id_d:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id);
if FBH_HD_KIEU_HD(b_ma_dvi,b_so_id_d)<>'K' then
    b_so_id_b:=b_so_id_d;
else
    b_so_id_g:=FBH_HD_SO_ID_GOC(b_ma_dvi,b_so_id_d);
    b_so_id_b:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_g);
end if;
return b_so_id_b;
end;
/
create or replace procedure PHD_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_loi out varchar2)
AS
    b_d1 date; b_d2 date; b_i1 number; b_i2 number;
begin
---Lan--Test han su dung chuong trinh hoa don---
b_loi:='';
select min(ngay_nh),max(ngay_nh) into b_d1,b_d2 from hd_1;
b_i1:=to_number(to_char(b_d1,'yyyymmdd')); b_i2:=to_number(to_char(b_d2,'yyyymmdd'));
--if b_i2-b_i1>365 then b_loi:='loi:Het han su dung chuong trinh hoa don:loi';end if;
end;
/
create or replace function FBH_HD_NGAY_TAI(b_ma_dvi varchar2,b_so_id_ps number,b_ngay_xl number:=0) return number
AS
    b_kq number; b_nv varchar2(10); b_so_id number;
begin
-- Dan - Tra ngay xu ly tai
-- nam: truyen b_so_id_ps
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id_ps);
if b_ngay_xl=0 then
    b_so_id:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_id_ps);
else
    b_so_id:=FBH_HD_SO_ID_BS(b_ma_dvi,b_so_id_ps,b_ngay_xl);
end if;
if b_nv<>'HANG' then
    select ngay_hl into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select ngay_cap into b_kq from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
return b_kq;
end;