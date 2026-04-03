/*** Nhan FAC ***/
create or replace function FTBH_TMN_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return varchar2
AS
    b_kq varchar2(100):=' '; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from tbh_tmN_txt where so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from tbh_tmN_txt where so_id=b_so_id and loai='dt_ct';
	b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FTBH_TMN_TXTn(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return number
AS
    b_kq number:=0; b_i1 number; b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
select count(*) into b_i1 from tbh_tmN_txt where so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
	select txt into b_txt from tbh_tmN_txt where so_id=b_so_id and loai='dt_ct';
	b_kq:=FKH_JS_GTRIn(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FTBH_TMN(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Dan - Tra co nhan FAC
select count(*) into b_i1 from tbh_tmN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FTBH_TMN_TL(
    b_ma_dvi varchar2,b_so_id number,b_lh_nv varchar2,b_nbh varchar2:=' ') return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ty le dong bao hiem theo nghiep vu
select nvl(sum(pt),0) into b_kq from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and lh_nv in (' ',b_lh_nv) and b_nbh in(' ',nha_bhC);
return b_kq;
end;
/
create or replace function FTBH_TMN_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_nbh varchar2:=' ') return number
AS
    b_kq number;
begin
-- Dan - Xac dinh ty le nhan tai Fac
select nvl(sum(pt),0) into b_kq from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) and lh_nv in (' ',b_lh_nv) and b_nbh in(' ',nha_bhC);
return b_kq;
end;
/
create or replace procedure PTBH_TMN_TL_DT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_tlT out number,b_tlN out number)
AS
begin
-- Dan - Xac dinh ty le nhan tai Fac
b_tlT:=0; b_tlN:=0;
for r_lp in(select pt,nha_bh from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) and lh_nv in (' ',b_lh_nv)) loop
    if FBH_DTAC_MA_NHOM(r_lp.nha_bh)='T' then b_tlT:=b_tlT+r_lp.pt; else b_tlN:=b_tlN+r_lp.pt; end if;
end loop;
end;
/
create or replace function FTBH_TMN_TL_HH(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,b_phi number,b_tp number:=0) return number
AS
    b_kq number:=0;
begin
-- Dan - Tinh hoa hong
for r_lp in (select pt,hh from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) and lh_nv in (' ',b_lh_nv)) loop
    b_kq:=b_kq+round(b_phi*r_lp.pt*r_lp.hh/10000,b_tp);
end loop;
return b_kq;
end;
/
create or replace procedure PTBH_TMN_TL_HH(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_lh_nv varchar2,
    b_phi number,b_hhT out number,b_hhN out number,b_tp number:=0)
AS
    b_hh number;
begin
-- Dan - Tinh hoa hong
b_hhT:=0; b_hhN:=0;
for r_lp in(select pt,hh,nha_bh from tbh_tmN_tl where
    ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in (0,b_so_id_dt) and lh_nv in (' ',b_lh_nv)) loop
    b_hh:=round(b_phi*r_lp.pt*r_lp.hh/10000,b_tp);
    if FBH_DTAC_MA_NHOM(r_lp.nha_bh)='T' then b_hhT:=b_hhT+b_hh; else b_hhN:=b_hhN+b_hh; end if;
end loop;
end;
/
create or replace function FTBH_TMN_TL_TIEN(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_lh_nv varchar2,b_tien number,b_nbh varchar2:=' ') return number
AS
    b_kq number; b_tl number; b_nt_phi varchar2(5); b_tp number:=0;
begin
-- Dan - Tra tien theo ty le
b_tl:=FTBH_TMN_TL_DT(b_ma_dvi,b_so_id,b_so_id_dt,b_lh_nv,b_nbh);
select nvl(min(nt_phi),' ') into b_nt_phi from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nt_phi<>'VND' then b_tp:=2; end if;
b_kq:=round(b_tien*b_tl/100,b_tp);
return b_kq;
end;
/
create or replace procedure FTBH_TMN_TL_HD
    (b_ma_dvi varchar2,b_so_id number,a_so_id_dt out pht_type.a_num,
    a_lh_nv out pht_type.a_var,a_pt out pht_type.a_num,a_hh out pht_type.a_num)
AS
    b_i1 number:=0; b_i2 number;
begin
-- Dan - Xac dinh ty le dong bao hiem con lai hop dong
PKH_MANG_KD_N(a_so_id_dt);
for r_lp in (select so_id_dt,lh_nv,nha_bh,nvl(max(pt),0) pt,nvl(min(hh),0) hh from tbh_tmN_tl
    where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_id_dt,lh_nv,nha_bh) loop
    if r_lp.pt=0 then continue; end if;
    b_i2:=0;
    for b_lp in 1..b_i1 loop
        if a_so_id_dt(b_lp)=r_lp.so_id_dt and a_lh_nv(b_lp)=r_lp.lh_nv then
            b_i2:=b_lp;
            a_pt(b_i2):=a_pt(b_i2)+r_lp.pt; a_hh(b_i2):=a_hh(b_i2)+r_lp.hh;
            exit;
        end if;
    end loop;
    if b_i2=0 then
        b_i1:=b_i1+1;
        a_so_id_dt(b_i1):=r_lp.so_id_dt; a_lh_nv(b_i1):=r_lp.lh_nv; a_pt(b_i1):=r_lp.pt; a_hh(b_i1):=r_lp.hh;
    end if;
end loop;
end;
/
create or replace procedure FTBH_TMN_CN_KTRA(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du
select nvl(min(ngay_ht),0) into b_i1 from tbh_tmN_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='loi:Sai so du ngay '||pkh_so_cng(b_i1)||':loi'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
-- chuclh: sql may a dan sai
create or replace function FTBH_TMN_NBH(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac dinh nha BH
select nvl(min(nha_bh),' '),count(*) into b_kq,b_i1 from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>1 then b_kq:=' '; end if; 
return b_kq;
end;
/
create or replace procedure PTBH_TMN_NBH(b_ma_dvi varchar2,b_so_id number,a_nbh out pht_type.a_var,b_dk varchar2:='C')
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac dinh nha BH
if b_dk='C' then
    select distinct nha_bhC bulk collect into a_nbh from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select distinct nha_bh bulk collect into a_nbh from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
end;
/
create or replace procedure PTBH_TMN_NBHd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,a_nbh out pht_type.a_var,b_dk varchar2:='C')
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Xac dinh nha BH
if b_dk='C' then
    select distinct nha_bhC bulk collect into a_nbh from tbh_tmN_tl where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt);
else
    select distinct nha_bh bulk collect into a_nbh from tbh_tmN_tl where
        ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt in(0,b_so_id_dt);
end if;
end;
/
create or replace procedure PTBH_TMN_TH_PS(
    b_ma_dvi varchar2,b_so_id number,b_so_id_ps number,b_loi out varchar2)
AS
    b_i1 number:=0; b_i2 number;
begin
-- Dan - Tong hop so cai phat sinh tbh_tmN_sc_ps
delete temp_1;
insert into temp_1(c1,c2,c3,c4,n1) select nhom,loai,nha_bh,ma_nt,tien from tbh_tmN_ps
    where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps;
insert into temp_1(c1,c2,c3,c4,n1) select a.nhom,a.loai,b.nha_bh,a.ma_nt,-a.tien
    from tbh_tmN_pt a,tbh_tmN_tt b where
    a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and a.so_id_ps=b_so_id_ps and
    b.ma_dvi=b_ma_dvi and b.so_id_tt=a.so_id_tt ;
select count(*) into b_i1 from (select c1,c2,c3,c4,sum(n1),sum(n2) from temp_1
    group by c1,c2,c3,c4 having sum(n1)<>0 or sum(n2)<>0) a;
select count(*) into b_i2 from tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps;
if b_i1=0 then
    if b_i2<>0 then delete tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps=b_so_id_ps; end if;
elsif
    b_i2=0 then insert into tbh_tmN_sc_ps values(b_ma_dvi,b_so_id,b_so_id_ps);
end if;
delete temp_1;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi Table PTBH_TMN_TH_PS:loi'; end if;
end;
/
create or replace procedure PTBH_TMN_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_nh varchar2:='C')
As
  b_nsdC varchar2(10); b_i1 number; b_ngay_hl number; b_ttrang varchar2(1); b_so_id_ps number;
begin
select count(*) into b_i1 from tbh_tmN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nvl(max(ngay_hl),0),count(*) into b_ngay_hl,b_i1 from tbh_tmNL where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_so_id_ps:=b_so_id*10+b_i1; end if;
b_ttrang:=FBH_HD_TTRANG(b_ma_dvi,b_so_id);
if b_ttrang in('D','H') then b_loi:='loi:Khong sua xoa nhan tai FAC hop dong da duyet, da huy:loi'; end if;
delete tbh_tmN_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tmN where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_hl=0 then
    delete bh_hd_goc_phi_nbh where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    insert into tbh_tmN select * from tbh_tmNL where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    insert into tbh_tmN_tl select * from tbh_tmNL_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    insert into tbh_tmN_txt select * from tbh_tmNL_txt
        where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete tbh_tmNL_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete tbh_tmNL_tl where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete tbh_tmNL where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_hl=b_ngay_hl;
    delete tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
    delete tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TMN_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_TMN_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
begin
-- Dan - Xoa
PTBH_TMN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then return; end if;
if FBH_HD_TTRANG(b_ma_dvi,b_so_id)='T' and FBH_HD_CO_TAM(b_ma_dvi,b_so_id)='C' then
    PTBH_TMB_CBI_NH(b_ma_dvi,b_so_id,b_loi,'X');
    if b_loi is not null then return; end if;
end if;
b_loi:='';
end;
/
create or replace procedure PTBH_TMN_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nv varchar2,b_oraIn clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000);
    b_ngay_hl number; b_kieu varchar2(1); b_ttrang varchar2(1);
    dk_so_id_dtC pht_type.a_var; dk_so_id_dt pht_type.a_num;
    dk_nha_bh pht_type.a_var; dk_lh_nv pht_type.a_var; dk_pt pht_type.a_num;
    dk_hh pht_type.a_num; dk_kieu pht_type.a_var; dk_nha_bhC pht_type.a_var;
    dt_ct clob; dt_bh clob;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay_hl,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_kieu using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_dt,nha_bh,lh_nv,pt,hh,kieu');
EXECUTE IMMEDIATE b_lenh bulk collect into dk_so_id_dtC,dk_nha_bh,dk_lh_nv,dk_pt,dk_hh,dk_kieu using dt_bh;
for b_lp in 1..dk_nha_bh.count loop
    dk_so_id_dtC(b_lp):=PKH_MA_TENl(dk_so_id_dtC(b_lp));
    dk_so_id_dt(b_lp):=PKH_LOC_CHU(dk_so_id_dtC(b_lp),'F','F');
    dk_nha_bh(b_lp):=nvl(PKH_MA_TENl(dk_nha_bh(b_lp)),' ');
    dk_pt(b_lp):=nvl(dk_pt(b_lp),0); dk_hh(b_lp):=nvl(dk_hh(b_lp),0);
    dk_lh_nv(b_lp):=nvl(PKH_MA_TENl(dk_lh_nv(b_lp)),' ');
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),'D');
    dk_nha_bhC(b_lp):=dk_nha_bh(b_lp);
    if dk_kieu(b_lp)<>'D' then
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in REVERSE 1..b_i1 loop
            if dk_kieu(b_lp1)='D' then b_i2:=b_lp1; exit; end if;
        end loop;
        if b_i2<>0 then dk_nha_bhC(b_lp):=dk_nha_bh(b_i2); end if;
    end if;
end loop;
PTBH_TMN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then return; end if;
insert into tbh_tmN values(b_ma_dvi,b_so_id,b_nv,b_ngay_hl,b_nsd);
forall b_lp in 1..dk_nha_bh.count
    insert into tbh_tmN_tl values(b_ma_dvi,b_so_id,dk_so_id_dt(b_lp),dk_nha_bh(b_lp),
        dk_lh_nv(b_lp),dk_pt(b_lp),dk_hh(b_lp),dk_kieu(b_lp),dk_nha_bhC(b_lp),b_ngay_hl);
b_ttrang:=FBH_HD_TTRANG(b_ma_dvi,b_so_id);
if b_ttrang='D' then
    PBH_HD_GOC_THL_CT(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TH_TMN(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_CBI_NH(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
elsif b_ttrang='T' and FBH_HD_CO_TAM(b_ma_dvi,b_so_id)='C' then
    PTBH_TMB_CBI_NH(b_ma_dvi,b_so_id,b_loi,'X');
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PTBH_TMN_SUA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nv varchar2,b_oraIn clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000);
    b_ngay_hl number; b_kieu varchar2(1); b_so_id_ps number:=0;
    dk_so_id_dtC pht_type.a_var; dk_so_id_dt pht_type.a_num;
    dk_nha_bh pht_type.a_var; dk_pthuc pht_type.a_var; 
    dk_lh_nv pht_type.a_var; dk_pt pht_type.a_num; dk_hh pht_type.a_num;
    dk_kieu pht_type.a_var; dk_nha_bhC pht_type.a_var;
    dt_ct clob; dt_bh clob;
begin
-- Dan - Nhap
b_lenh:=FKH_JS_LENHc('dt_ct,dt_bh');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_bh using b_oraIn;
b_lenh:=FKH_JS_LENH('ngay_hl,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_kieu using dt_ct;
b_lenh:=FKH_JS_LENH('so_id_dt,nha_bh,lh_nv,pt,hh,kieu');
EXECUTE IMMEDIATE b_lenh bulk collect into 
    dk_so_id_dtC,dk_nha_bh,dk_pthuc,dk_lh_nv,dk_pt,dk_hh,dk_kieu using dt_bh;
for b_lp in 1..dk_nha_bh.count loop
    dk_so_id_dtC(b_lp):=PKH_MA_TENl(dk_so_id_dtC(b_lp));
    dk_so_id_dt(b_lp):=PKH_LOC_CHU(dk_so_id_dtC(b_lp),'F','F');
    dk_nha_bh(b_lp):=nvl(PKH_MA_TENl(dk_nha_bh(b_lp)),' ');
    dk_pt(b_lp):=nvl(dk_pt(b_lp),0); dk_hh(b_lp):=nvl(dk_hh(b_lp),0);
    dk_lh_nv(b_lp):=nvl(PKH_MA_TENl(dk_lh_nv(b_lp)),' ');
    dk_kieu(b_lp):=nvl(trim(dk_kieu(b_lp)),'D');
    dk_nha_bhC(b_lp):=dk_nha_bh(b_lp);
    if dk_kieu(b_lp)<>'D' then
        b_i1:=b_lp-1; b_i2:=0;
        for b_lp1 in REVERSE 1..b_i1 loop
            if dk_kieu(b_lp1)='D' then b_i2:=b_lp1; exit; end if;
        end loop;
        if b_i2<>0 then dk_nha_bhC(b_lp):=dk_nha_bh(b_i2); end if;
    end if;
end loop;
if FBH_HD_TTRANG(b_ma_dvi,b_so_id)<>'D' then b_loi:='loi:Hop dong chua duyet:loi'; return; end if;
select count(*) into b_i1 from tbh_tmNL where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    b_so_id_ps:=b_so_id*10+b_i1;
    insert into tbh_tmN_ps_temp1 select * from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_ps<>b_so_id_ps;
end if;
PTBH_TMN_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then return; end if;
insert into tbh_tmN values(b_ma_dvi,b_so_id,b_nv,b_ngay_hl,b_nsd);
forall b_lp in 1..dk_nha_bh.count
    insert into tbh_tmN_tl values(b_ma_dvi,b_so_id,dk_so_id_dt(b_lp),dk_nha_bh(b_lp),
        dk_lh_nv(b_lp),dk_pt(b_lp),dk_hh(b_lp),dk_kieu(b_lp),dk_nha_bhC(b_lp),b_ngay_hl);
PBH_HD_GOC_THL_CT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TMN(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
insert into tbh_tmN_ps_temp2 select * from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
insert into tbh_tmN_ps select * from tbh_tmN_ps_temp1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
update tbh_tmN_ps_temp1 set ngay_ht=b_ngay_hl,bt=0,tien=-tien,tien_qd=-tien_qd,thue=-thue,thue_qd=-thue_qd;
insert into tbh_tmN_ps_temp1 select * from tbh_tmN_ps_temp2;
delete tbh_tmN_ps_temp2;
insert into tbh_tmN_ps_temp2 select b_ma_dvi,0,0,so_ct,b_ngay_hl,so_id,so_id_dt,nhom,loai,nv,pthuc,nha_bh,ma_nt,lh_nv,ma_dt,
    sum(tien),sum(thue),sum(tien_qd),sum(thue_qd) from tbh_tmN_ps_temp1
    group by so_ct,so_id,so_id_dt,nhom,loai,nv,pthuc,nha_bh,ma_nt,lh_nv,ma_dt having sum(tien)<>0;
select count(*) into b_i1 from tbh_tmNL where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_so_id_ps:=b_so_id*10+b_i1+1;
update tbh_tmN_ps_temp2 set so_id_ps=b_i1,bt=rownum;
insert into tbh_tmN_ps select * from tbh_tmN_ps_temp2;
PTBH_CBI_NH(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace PROCEDURE PTBH_TH_TMNth(
    b_ma_dvi varchar2,b_so_id number,
    a_so_id_ps pht_type.a_num,a_so_ct pht_type.a_var,a_ngay pht_type.a_num,a_nhom pht_type.a_var,
    a_loai pht_type.a_var,a_nv pht_type.a_var,a_so_id_dt pht_type.a_num,a_lh_nv pht_type.a_var,
    a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_thue pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_tpP number:=0; b_bt number:=0;
    b_kieu_do varchar2(1); b_kieu_phv varchar2(1); b_kieu_vat varchar2(1);
    b_loai varchar2(20); b_nvT varchar2(1); b_ma_dt varchar2(10); b_hhong number; 
    b_tien number; b_thue number; b_tien_qd number; b_thue_qd number; 
    do_so_id_dt pht_type.a_num; do_lh_nv pht_type.a_var;
    do_so_id_dtT pht_type.a_num; do_lh_nvT pht_type.a_var; do_ptT pht_type.a_num;
    do_nbhC pht_type.a_var; do_nbh pht_type.a_var;
    do_pt pht_type.a_num; do_ptG pht_type.a_num; do_hh pht_type.a_num;
begin
-- Dan - Tong hop phat sinh dong bao hiem
delete tbh_tmN_ps_temp;
select distinct so_id_dt,lh_nv,nha_bh,nha_bhC,pt,hh BULK COLLECT into do_so_id_dt,do_lh_nv,do_nbh,do_nbhC,do_pt,do_hh
    from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if do_so_id_dt.count=0 then b_loi:=''; return; end if;
select distinct so_id_dt,lh_nv,sum(pt) BULK COLLECT into do_so_id_dtT,do_lh_nvT,do_ptT
    from tbh_tmN_tl where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_id_dt,lh_nv having sum(pt)<>0;
for b_lp1 in 1..do_lh_nv.count loop
    do_ptG(b_lp1):=0;
    for b_lp in 1..do_lh_nvT.count loop
        if do_so_id_dtT(b_lp)=do_so_id_dt(b_lp1) and do_lh_nvT(b_lp)=do_lh_nv(b_lp1) then
            do_ptG(b_lp1):=do_pt(b_lp1)/do_ptT(b_lp); exit;
        end if;
    end loop;
end loop;
if a_ma_nt(1)<>'VND' then b_tpP:=2; end if;
for b_lp in 1..a_lh_nv.count loop
    for b_lp1 in 1..do_lh_nv.count loop
        if do_pt(b_lp1)=0 or do_so_id_dt(b_lp1) not in(0,a_so_id_dt(b_lp)) or do_lh_nv(b_lp1) not in(' ',a_lh_nv(b_lp)) then
            continue;
        end if;
        if a_loai(b_lp)='DT_PHL_BHd' then
            b_tien:=round(a_tien(b_lp)*do_ptG(b_lp1),b_tpP); b_thue:=round(a_thue(b_lp)*do_ptG(b_lp1),b_tpP);
        else
            b_tien:=round(a_tien(b_lp)*do_pt(b_lp1)/100,b_tpP); b_thue:=round(a_thue(b_lp)*do_pt(b_lp1)/100,b_tpP);
        end if;
        insert into bh_hd_do_ps_temp values(a_so_id_ps(b_lp),a_so_ct(b_lp),a_so_id_dt(b_lp),a_ngay(b_lp),
            a_nhom(b_lp),a_loai(b_lp),a_nv(b_lp),do_nbhC(b_lp1),a_ma_nt(b_lp),a_lh_nv(b_lp),b_tien,b_thue);
        if a_loai(b_lp)='DT_PHL_BHd' then
            b_hhong:=round(b_tien*do_hh(b_lp1)/100,b_tpP);
            if b_hhong<>0 then
                b_thue:=round(b_hhong*.1,b_tpP);
                insert into tbh_tmN_ps_temp values(a_so_id_ps(b_lp),a_so_ct(b_lp),a_so_id_dt(b_lp),a_ngay(b_lp),
                    'T','CH_LEPd',a_nv(b_lp),do_nbhC(b_lp1),a_ma_nt(b_lp),a_lh_nv(b_lp),b_hhong,b_thue);
            end if;
        end if;
    end loop;
end loop;
for r_lp in (select so_id_ps,so_ct,so_id_dt,ngay_ht,nhom,loai,nv,nha_bh,ma_nt,lh_nv,sum(tien) tien,sum(thue) thue
    from tbh_tmN_ps_temp group by so_id_ps,so_ct,so_id_dt,ngay_ht,nhom,loai,nv,nha_bh,ma_nt,lh_nv order by so_id_ps) loop
    b_bt:=b_bt+1;
    if r_lp.ma_nt='VND' then
        b_tien_qd:=r_lp.tien; b_thue_qd:=r_lp.thue;
    else
        b_i1:=FBH_TT_TRA_TGTT(r_lp.ngay_ht,r_lp.ma_nt);
        b_tien_qd:=round(r_lp.tien*b_i1,0); b_thue_qd:=round(r_lp.thue*b_i1,0);
    end if;
    b_ma_dt:=FBH_HD_MA_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,r_lp.ngay_ht);
    insert into tbh_tmN_ps values(b_ma_dvi,r_lp.so_id_ps,b_bt,r_lp.so_ct,r_lp.ngay_ht,b_so_id,r_lp.so_id_dt,
        r_lp.nhom,r_lp.loai,r_lp.nv,'T',r_lp.nha_bh,r_lp.ma_nt,r_lp.lh_nv,b_ma_dt,
        r_lp.tien,r_lp.thue,b_tien_qd,b_thue_qd);
end loop;
for r_lp in (select distinct so_id_ps from tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PTBH_TMN_TH_PS(b_ma_dvi,b_so_id,r_lp.so_id_ps,b_loi);
    if b_loi is not null then return; end if;
end loop;
delete tbh_tmN_ps_temp;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TMNth:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_TH_TMN_PHI(
    b_ma_dvi varchar2,b_so_id_tt number,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_bt number:=0; b_kieu_do varchar2(1); b_so_ct varchar2(20); b_ngay_ht number;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop phi
delete tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
delete tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_tt;
select min(so_ct),nvl(min(ngay_ht),0) into b_so_ct,b_ngay_ht from bh_hd_goc_ttps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_ngay_ht=0 then b_loi:=''; return; end if;
for r_lp in(select so_id_dt,ma_nt,lh_nv,sum(phi) tien,sum(thue) thue from bh_hd_goc_ttptdt 
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and so_id=b_so_id and pt<>'N' and lh_nv<>' '
    group by so_id_dt,ma_nt,lh_nv) loop
    b_bt:=b_bt+1;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue; a_nv(b_bt):='T';
    a_so_id_ps(b_bt):=b_so_id_tt; a_so_id_dt(b_bt):=r_lp.so_id_dt;
    a_ngay(b_bt):=b_ngay_ht; a_ma_nt(b_bt):=r_lp.ma_nt; a_lh_nv(b_bt):=r_lp.lh_nv;
    a_nhom(b_bt):='T'; a_loai(b_bt):='DT_PHL_BHd'; a_so_ct(b_bt):=b_so_ct;
end loop;
if b_bt=0 then b_loi:=''; return; end if;
PTBH_TH_TMNth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TMN_PHI:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_TH_TMN_HU(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_id_tt number:=b_so_id*10;
    b_i1 number; b_bt number:=0; b_so_ct varchar2(20); b_ngay_ht number;
    a_so_id_ps pht_type.a_num; a_so_ct pht_type.a_var; a_ngay pht_type.a_num; a_nhom pht_type.a_var; 
    a_loai pht_type.a_var; a_nv pht_type.a_var; a_so_id_dt pht_type.a_num; a_lh_nv pht_type.a_var;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_thue pht_type.a_num;
begin
-- Dan - Tong hop Huy
select min(so_ct),nvl(min(ngay_ht),0) into b_so_ct,b_ngay_ht from bh_hd_goc_hu where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_ht=0 then b_loi:=''; return; end if;
for r_lp in(select so_id_dt,ma_nt,lh_nv,sum(phi) tien,sum(thue) thue from bh_hd_goc_ttptdt where
    ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and lh_nv<>' ' group by so_id_dt,ma_nt,lh_nv) loop
    b_bt:=b_bt+1;
    a_so_id_ps(b_bt):=b_so_id_tt; a_ngay(b_bt):=b_ngay_ht;
    a_ma_nt(b_bt):=r_lp.ma_nt; a_nhom(b_bt):='T'; a_so_ct(b_bt):=' ';
    a_so_id_dt(b_bt):=r_lp.so_id_dt; a_lh_nv(b_bt):=r_lp.lh_nv;
    a_tien(b_bt):=r_lp.tien; a_thue(b_bt):=r_lp.thue;
    a_loai(b_bt):='DT_PHL_BHd'; a_nv(b_bt):='C';
end loop;
PTBH_TH_TMNth(b_ma_dvi,b_so_id,a_so_id_ps,a_so_ct,a_ngay,a_nhom,a_loai,a_nv,a_so_id_dt,a_lh_nv,a_ma_nt,a_tien,a_thue,b_loi);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TMN_HU:loi'; end if;
end;
/
create or replace PROCEDURE PTBH_TH_TMN(
    b_ma_dvi varchar2,b_so_id number,b_loi out varchar2,b_dk varchar2:='C')
AS
begin
-- Dan - Tong hop phat sinh nhan Fac
delete tbh_tmN_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tbh_tmN_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in(select so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PTBH_TH_TMN_PHI(b_ma_dvi,r_lp.so_id_tt,b_so_id,b_loi);
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TH_TMN:loi'; end if;
end;
/
