create or replace procedure PBH_NG_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_ma_sp varchar2(10); b_nt_tien varchar2(5); b_lan number; b_nv varchar2(10);
    b_ngay_hl number; b_ngay_kt number; b_thang number:=-1; b_tuoi number;
    a_so_id_dt pht_type.a_num; a_ten pht_type.a_nvar; a_ng_sinh pht_type.a_num; a_ma_sp pht_type.a_var;
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
    dt_ds clob; b_txt clob; dk_lh_nv pht_type.a_var;
begin
b_loi:='loi:Loi xu ly PBH_NG_PQU_BG:loi';
select nvl(max(lan),0) into b_lan from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_lan=0 then b_loi:='loi:Bao gia da xoa:loi'; raise PROGRAM_ERROR; end if;
select txt into dt_ds from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds' and lan=b_lan;
dt_ds:=FKH_JS_BONH(dt_ds);
if dt_ds is null then b_loi:=''; return; end if;
select txt into b_txt from bh_ngB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct' and lan=b_lan;
b_txt:=FKH_JS_BONH(b_txt);
b_ma_sp:=nvl(trim(FKH_JS_GTRIs(b_txt,'ma_sp')),' ');
select nv,ngay_hl,ngay_kt,nt_tien into b_nv,b_ngay_hl,b_ngay_kt,b_nt_tien from bh_ngB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
if instr(b_nv,'DL')=0 then b_thang:=FKH_KHO_THSO(b_ngay_hl,b_ngay_kt); end if;
b_lenh:=FKH_JS_LENH('so_id_dt,ten,ng_sinh,ma_sp');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id_dt,a_ten,a_ng_sinh,a_ma_sp using dt_ds;
b_txt:='';
if a_so_id_dt.count > 0 then
   for b_lp in 1..a_so_id_dt.count loop
      a_ma_sp(b_lp):=nvl(trim(a_ma_sp(b_lp)),b_ma_sp);
      if a_ng_sinh(b_lp) is null or a_ng_sinh(b_lp) in(0,30000101) then
          b_tuoi:=-1;
      else
          b_tuoi:=round((FKH_KHO_THSO(a_ng_sinh(b_lp),b_ngay_hl)-6)/12,0);
      end if;
      select ma,ten,tien,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_ptG
          from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=a_so_id_dt(b_lp);
      FBH_NG_PQU_HD(b_ma_dviN,b_nsdN,a_ten(b_lp),b_nt_tien,b_tuoi,b_thang,a_ma_sp(b_lp),'',dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_ptG,b_loi);
      if b_loi is not null then return; end if;
   end loop;
else
   select ma,ten,tien,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_ptG from bh_ngB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
      FBH_NG_PQU_HD(b_ma_dviN,b_nsdN,'',b_nt_tien,0,b_thang,b_ma_sp,'',dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_ptG,b_loi);
      if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PHH_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10); b_nt_tien varchar2(5);
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
    pvi_ma pht_type.a_var; pvi_ten pht_type.a_nvar; pvi_tien pht_type.a_num; pvi_ptG pht_type.a_num;
    dk_tienN pht_type.a_num; dk_maN pht_type.a_var; 
    b_lt clob:=''; dk_nv pht_type.a_var;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Bao gia da xoa:loi';
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    select nv bulk collect into dk_nv from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt and lh_nv<>' ';
    select pvi_ma,FBH_PHH_PVI_TEN(pvi_ma),tien,ptG bulk collect into pvi_ma,pvi_ten,pvi_tien,pvi_ptG
        from bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    FBH_PHH_PQU_HD(b_ma_dviN,b_nsdN,r_lp.ten,b_nt_tien,r_lp.mrr,r_lp.ma_dt,b_ma_sp,'','',
        dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_nv,dk_ptG,pvi_ma,pvi_ten,pvi_tien,pvi_ptG,b_loi);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PKT_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10); b_nt_tien varchar2(5);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
    pvi_ma pht_type.a_var; pvi_ten pht_type.a_nvar; pvi_tien pht_type.a_num; pvi_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Bao gia da xoa:loi';
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_pktB where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_pktB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select ma,ten,tien,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_ptG
        from bh_pktB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    FBH_PKT_PQU_HD(b_ma_dviN,b_nsdN,' ',r_lp.rru,b_ma_sp,b_nt_tien,' ',dk_ma,dk_ten,dk_tien,dk_ptG,pvi_ma,pvi_ten,pvi_tien,pvi_ptG,b_loi);
    if b_loi is not null then return; end if;
    end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_TAU_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number; b_nt_tien varchar2(5);
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Bao gia da xoa:loi';
select nt_tien into b_nt_tien from bh_tauB where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_tauB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_tuoi:=FBH_TAU_TUOI(r_lp.nam_sx);
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_tauB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    FBH_TAU_PQU_HD(b_ma_dviN,b_nsdN,r_lp.ten,r_lp.nhom,b_nt_tien,b_tuoi,r_lp.ma_sp,'',dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_XE_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number; b_nt_tien varchar2(5);
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Bao gia da xoa:loi';
select nt_tien into b_nt_tien from bh_xeB where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_tuoi:=FBH_XE_TUOI(r_lp.nam_sx);
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_xeB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    FBH_XE_PQU_HD(b_ma_dviN,b_nsdN,r_lp.ten,b_nt_tien,b_tuoi,r_lp.md_sd,r_lp.loai_xe,r_lp.ma_sp,' ',
        dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_2B_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number; b_nt_tien varchar2(5);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Bao gia da xoa:loi';
select nt_tien into b_nt_tien from bh_2bB where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_xeB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select ma,ten,tien,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_ptG
        from bh_2bB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    FBH_2B_PQU_HD(b_ma_dviN,b_nsdN,r_lp.ten,b_nt_tien,dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HANG_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10):=' ';
    b_nt_tien varchar2(5); b_tien number; b_ma_qtac varchar2(10);
    b_ma_pt varchar2(10); --Phuong thuc van chuyen
    a_dgoi pht_type.a_var; a_loai pht_type.a_var;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
b_loi:='loi:Loi xu ly PBH_HANG_PQU_HD:loi';
select nt_tien,qtac,vchuyen into b_nt_tien,b_ma_qtac,b_ma_pt from bh_hangB where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,lh_nv,' ',tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
    from bh_hangB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_dk<>' ';
select sum(tien) into b_tien
    from bh_hangB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_dk<>' ';
select dgoi bulk collect into a_dgoi
    from bh_hangB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id group by dgoi having sum(mtn)<>0;
select ma_lhang bulk collect into a_loai
    from bh_hangB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id group by ma_lhang having sum(mtn)<>0;
FBH_HANG_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,'',b_ma_qtac,b_ma_pt,b_tien,a_dgoi,a_loai,dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PTN_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10); b_nt_tien varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
--Nam - Kiem tra phan quyen
b_loi:='loi:Loi xu ly PBH_PTN_PQU_BG:loi';
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_ptnB where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,ten,tien,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_ptG
    from bh_ptnB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_ptnB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    FBH_PTN_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,FBH_PTN_TXT(b_ma_dvi,b_so_id,'ghan_m',r_lp.so_id_dt),'',dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HOP_PQU_BG(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10); b_nt_tien varchar2(10);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
--Nam - Kiem tra phan quyen
b_loi:='loi:Loi xu ly PBH_HOP_PQU_BG:loi';
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,ten,tien,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_ptG
    from bh_hopB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_hopB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    FBH_HOP_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,'',dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PQU_BG(
    b_nv varchar2,b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_lenh varchar2(1000);
begin
-- Dan - Ktra phan quyen
b_lenh:='begin PBH_'||b_nv||'_PQU_BG(:ma_dviN,:nsdN,:ma_dvi,:so_id,:loi); end;';
EXECUTE IMMEDIATE b_lenh using b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,out b_loi;
/*if b_nv='PHH' then
    PBH_PHH_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='PKT' then
    PBH_PKT_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='XE' then
    PBH_XE_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='2B' then
    PBH_2B_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='TAU' then
    PBH_TAU_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='NG' then
    PBH_NG_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='HANG' then
    PBH_HANG_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='PTN' then
    PBH_PTN_PQU_BG(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
end if;*/
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FBH_PQU_BG(
    b_nv varchar2,b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_loi varchar2(100); b_kq varchar2(1):='K';
begin
PBH_PQU_BG(b_nv,b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
if b_loi is null then b_kq:='C'; end if;
return b_kq;
end;
/
