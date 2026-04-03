create or replace procedure FBH_PQU_HD_CH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000);
    b_ngay_hl number; b_ngay_cap number; b_hhong number; b_kieu_hd varchar2(1);
begin
-- dan - Kiem tra phan quyen
b_lenh:='select count(*) from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_i1 using b_ma_dvi,b_so_id;
if b_i1<>1 then b_loi:='loi:Hop dong, GCN da xoa:loi'; return; end if;
b_lenh:='select ngay_hl,ngay_cap,hhong,kieu_hd from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_ngay_hl,b_ngay_cap,b_hhong,b_kieu_hd using b_ma_dvi,b_so_id;
if b_hhong>0 and FBH_PQU_KTRA_KHn(b_ma_dviN,b_nsdN,'HD_HHMG',b_hhong,'NB')='K' then
    b_loi:='loi:Vuot muc phan cap hoa hong moi gioi:loi'; return;
end if;
if b_kieu_hd not in('B','S','N') then
    b_i1:=FKH_KHO_NGSO(b_ngay_hl,b_ngay_cap);
    if b_i1>0 and FBH_PQU_KTRA_KHn(b_ma_dviN,b_nsdN,'HD_LCAP',b_i1,'NB')='K' then
        b_loi:='loi:Vuot muc phan cap so ngay lui ngay hieu luc:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PQU_HD_CH:loi'; end if;
end;
/
create or replace procedure FBH_HANG_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_nt_tien varchar2,b_ma_sp varchar2,b_lt clob,b_ma_qtac varchar2,b_ma_pt varchar2,b_tien number,
    a_dgoi pht_type.a_var,a_loai pht_type.a_var,
    dk_ma pht_type.a_var,dk_lh_nv pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_tien pht_type.a_num; a_loi pht_type.a_var; 
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,' ','HANG',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
--Nam : kiem tra muc khai thac
if FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'HANG_HD_KT',b_tien,'NB')='K' and FBH_HANG_KS_KTRA(b_ma_dvi,b_nsd,b_ma_pt,b_ma_qtac,a_loai,a_dgoi)='C' then
    b_loi:='loi:Vuot muc khai thac muc trach nhiem voi nhom hang kiem soat:loi'; return;
end if;
b_i1:=FKH_ARR_TONG(a_tien);
if a_dgoi.count<>0 then
    a_loaiL(1):='DGOI';  a_loi(1):='Phuong thuc dong goi';
    for b_lp in 1..a_dgoi.count loop
        a_maL(1):=a_dgoi(b_lp); 
        PBH_PQU_KTRA_MA(b_ma_dvi,b_nsd,'HANG',b_i1,dk_ptG,a_loaiL,a_maL,a_loi,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
if a_loai.count<>0 then
    a_loaiL(1):='LOAI';  a_loi(1):='Loai hang';
    for b_lp in 1..a_loai.count loop
        a_maL(1):=a_loai(b_lp);
        PBH_PQU_KTRA_MA(b_ma_dvi,b_nsd,'HANG',b_i1,dk_ptG,a_loaiL,a_maL,a_loi,b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HANG_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_HANG_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10):=' '; b_lt clob; b_txt clob;
    b_nt_tien varchar2(5); b_ma_qtac varchar2(10); b_tien number;
    b_ma_pt varchar2(10); --Phuong thuc van chuyen
    a_dgoi pht_type.a_var; a_loai pht_type.a_var;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select nt_tien,qtac,vchuyen into b_nt_tien,b_ma_qtac,b_ma_pt from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,lh_nv,' ',tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
    from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_dk<>' ';
select sum(tien) into b_tien
    from bh_hang_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and ma_dk<>' ';
for b_lp in 1..dk_ma.count loop
    dk_tien(b_lp):=dk_tien(b_lp)-FBH_DONG_TL_TIEN(b_ma_dvi,b_so_id,0,dk_lh_nv(b_lp),dk_tien(b_lp));
end loop;
select dgoi bulk collect into a_dgoi
    from bh_hang_ds where ma_dvi=b_ma_dvi and so_id=b_so_id group by dgoi having sum(mtn)<>0;
select ma_lhang bulk collect into a_loai
    from bh_hang_ds where ma_dvi=b_ma_dvi and so_id=b_so_id group by ma_lhang having sum(mtn)<>0;
select lt into b_txt from bh_hang_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_lt:=FKH_JS_BONH(b_txt);
FBH_HANG_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,b_lt,b_ma_qtac,b_ma_pt,b_tien,a_dgoi,a_loai,dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HANG_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_NG_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nt_tien varchar2,
    b_tuoi number,b_thang number,b_ma_sp varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_lh_nv pht_type.a_var,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_tien pht_type.a_num; b_tien number:=0;
    a_loi pht_type.a_var; 
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
        if nvl(dk_lh_nv(b_lp),' ')<>' ' then
          b_tien:=b_tien+dk_tien(b_lp);
        end if;
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
        if nvl(dk_lh_nv(b_lp),' ')<>' ' then
          b_tien:=round(b_i1*(b_tien+dk_tien(b_lp)),0);
        end if;
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,b_dtuong,'NG',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
a_loaiL(1):='MA_SP'; a_maL(1):=b_ma_sp; a_loi(1):='San pham';
PBH_PQU_KTRA_MA(b_ma_dvi,b_nsd,'NG',b_tien,dk_ptG,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
if b_tuoi>=0 and FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'NG_HD_TUM',b_tuoi,'LB')='K' or
    FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'NG_HD_TUX',b_tuoi,'NB')='K' then
    b_loi:='loi:Vuot muc phan cap do tuoi:loi'; return;
end if;
if b_thang>=0 and FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'NG_HD_THM',b_thang,'NB')='K' or
    FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'NG_HD_THX',b_thang,'NB')='K' then
    b_loi:='loi:Vuot muc phan cap khoang hieu luc toi da:loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_NG_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_NG_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number:=-1; b_thang number:=-1; b_i1 number; b_nt_tien varchar2(5);
    b_nv varchar2(10); b_ngay_hl number; b_ngay_kt number; b_lt clob:=''; b_ten nvarchar2(500); b_ma_sp varchar2(20);
    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tien pht_type.a_num; 
    dk_lh_nv pht_type.a_var; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select nv,ngay_hl,ngay_kt,nt_tien,ten into b_nv,b_ngay_hl,b_ngay_kt,b_nt_tien,b_ten from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
  for r_lp in (select * from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
      b_tuoi:=round((FKH_KHO_THSO(r_lp.ng_sinh,r_lp.ngay_hl)-6)/12,0);
      select ma,ten,tien,lh_nv,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_ptG
          from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
      select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
      if b_i1=1 then
          select lt into b_lt from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
      else
          select lt into b_lt from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
      end if;
      b_lt:=FKH_JS_BONH(b_lt);
      FBH_NG_PQU_HD(b_ma_dviN,b_nsdN,r_lp.ten,b_nt_tien,b_tuoi,b_thang,r_lp.ma_sp,b_lt,dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_ptG,b_loi);
      if b_loi is not null then return; end if;
  end loop;
else
  b_ma_sp:=FBH_NG_TXT(b_ma_dvi,b_so_id,'ma_sp');
  select ma,ten,tien,lh_nv,ptG bulk collect into dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_ptG
          from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
  FBH_NG_PQU_HD(b_ma_dviN,b_nsdN,b_ten,b_nt_tien,0,b_thang,b_ma_sp,b_lt,dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_ptG,b_loi);
  if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NG_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_PHH_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong nvarchar2,b_nt_tien varchar2,
    b_mrr varchar2,b_ma_dt varchar2,b_ma_sp varchar2,b_cdt varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,dk_lh_nv pht_type.a_var,dk_nv pht_type.a_var,dk_ptG pht_type.a_num,
    pvi_ma pht_type.a_var,pvi_ten pht_type.a_nvar,pvi_tien pht_type.a_num,pvi_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    b_nhom varchar2(10):=FBH_PHH_DTUONG_NHOM(b_ma_dt);
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var; a_tien pht_type.a_num; b_tien number:=0;
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
        if nvl(dk_lh_nv(b_lp),' ')<>' ' and nvl(dk_nv(b_lp),'G')<>'M'then
          b_tien:=b_tien+dk_tien(b_lp);
        end if;
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
        if nvl(dk_lh_nv(b_lp),' ')<>' ' and nvl(dk_nv(b_lp),'G')<>'M'then
          b_tien:=round(b_i1*(b_tien+dk_tien(b_lp)),0);
        end if;
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,b_dtuong,'PHH',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
PBH_PQU_NHOM_KTHAC_MAa(b_ma_dvi,b_nsd,b_dtuong,'PHH','PVI',pvi_ma,pvi_ten,pvi_tien,pvi_ptG,b_loi);
if b_loi is not null then return; end if;
a_loaiL(1):='MRR'; a_maL(1):=b_mrr; a_loi(1):='muc rui ro';
a_loaiL(2):='NHOM'; a_maL(2):=b_nhom; a_loi(2):='Nhom doi tuong';
PBH_PQU_KTRA_MA(b_ma_dvi,b_nsd,'PHH',b_tien,dk_ptG,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
if trim(b_cdt) is not null and FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'HD_GHT','C','B')='K' then
    b_loi:='loi:Khong gioi han tai:loi'; return;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PHH_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_PHH_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10); b_nt_tien varchar2(5); b_pt_con number; b_lt clob:='';
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar; dk_nv pht_type.a_var;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
    pvi_ma pht_type.a_var; pvi_lh_nv pht_type.a_var;  pvi_ten pht_type.a_nvar; pvi_tien pht_type.a_num;
    pvi_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select ma,lh_nv,ten,tien,ptG,nv bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,dk_nv
        from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..dk_ma.count loop
        PBH_HD_CON_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,dk_lh_nv(b_lp),b_pt_con,b_loi);
        if b_loi is not null then return; end if;
        dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
    end loop;
    --nam: dk_lh_nv => pvi_lh_nv lay lh_nv cho pvi khong gan lai dk_lh_nv cua dieu khoan
    select pvi_ma,lh_nv,FBH_PHH_PVI_TEN(pvi_ma),tien,ptG bulk collect into pvi_ma,pvi_lh_nv,pvi_ten,pvi_tien,pvi_ptG
        from bh_phh_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt and pvi_ma<>' ';
    for b_lp in 1..pvi_ma.count loop
        pvi_tien(b_lp):=pvi_tien(b_lp)-FBH_DONG_TL_TIEN(b_ma_dvi,b_so_id,r_lp.so_id_dt,pvi_lh_nv(b_lp),pvi_tien(b_lp));
    end loop;
    select lt into b_lt from bh_phh_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_PHH_PQU_HD(b_ma_dviN,b_nsdN,r_lp.dvi,b_nt_tien,r_lp.mrr,r_lp.ma_dt,b_ma_sp,r_lp.cdt,b_lt,
        dk_ma,dk_ten,dk_tien,dk_lh_nv,dk_nv,dk_ptG,pvi_ma,pvi_ten,pvi_tien,pvi_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHH_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_PKT_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_rru varchar2,
    b_ma_sp varchar2,b_nt_tien varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,dk_tien pht_type.a_num,dk_ptG pht_type.a_num,
    pvi_ma pht_type.a_var,pvi_ten pht_type.a_nvar,pvi_tien pht_type.a_num,pvi_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,b_dtuong,'PKT',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
PBH_PQU_NHOM_KTHAC_MAa(b_ma_dvi,b_nsd,b_dtuong,'PKT','PVI',pvi_ma,pvi_ten,pvi_tien,pvi_ptG,b_loi);
if b_loi is not null then return; end if;
if b_rru<>'K' and FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'PKT_HD_UOT',b_rru,'B')<>'K'  then
    b_loi:='loi:Vuot phan cap cong trinh co rui ro uot:loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PKT_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_PKT_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_sp varchar2(10); b_lt clob; b_nt_tien varchar2(5); b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
    pvi_ma pht_type.a_var; pvi_ten pht_type.a_nvar; pvi_tien pht_type.a_num; pvi_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..dk_ma.count loop
        PBH_HD_CON_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,dk_lh_nv(b_lp),b_pt_con,b_loi);
        if b_loi is not null then return; end if;
        dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
    end loop;
    --nam: pqu khai thac pham vi
    select pvi_ma,lh_nv,FBH_PKT_PVI_TEN(pvi_ma),tien,ptG bulk collect into pvi_ma,dk_lh_nv,pvi_ten,pvi_tien,pvi_ptG
        from bh_pkt_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..pvi_ma.count loop
        pvi_tien(b_lp):=pvi_tien(b_lp)-FBH_DONG_TL_TIEN(b_ma_dvi,b_so_id,r_lp.so_id_dt,dk_lh_nv(b_lp),pvi_tien(b_lp));
    end loop;
    select lt into b_lt from bh_pkt_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_PKT_PQU_HD(b_ma_dviN,b_nsdN,r_lp.dvi,r_lp.rru,b_ma_sp,b_nt_tien,b_lt,
        dk_ma,dk_ten,dk_tien,dk_ptG,pvi_ma,pvi_ten,pvi_tien,pvi_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PKT_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_TAU_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nhom varchar2,b_nt_tien varchar2,b_tuoi number,b_ma_sp varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_lh_nv pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var; a_tien pht_type.a_num; b_tien number:=0;
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
        if nvl(dk_lh_nv(b_lp),' ')<>' ' then
          b_tien:=b_tien+dk_tien(b_lp);
        end if;
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
        if nvl(dk_lh_nv(b_lp),' ')<>' ' then
          b_tien:=round(b_i1*(b_tien+dk_tien(b_lp)),0);
        end if;
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,b_dtuong,'TAU',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
if FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'TAU_HD_TU',b_tuoi,'NB')='K' then
    b_loi:='loi:Vuot muc phan cap tuoi tau:loi'; return;
end if;
a_loaiL(1):='NHOM'; a_maL(1):=b_nhom; a_loi(1):='Nhom';
PBH_PQU_KTRA_MA(b_ma_dvi,b_nsd,'TAU',b_tien,dk_ptG,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_TAU_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_TAU_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number; b_lt clob; b_nt_tien varchar2(5); b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select nt_tien into b_nt_tien from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_tuoi:=FBH_TAU_TUOI(r_lp.nam_sx);
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_tau_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..dk_ma.count loop
        PBH_HD_CON_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,dk_lh_nv(b_lp),b_pt_con,b_loi);
        if b_loi is not null then return; end if;
        dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
    end loop;
    select lt into b_lt from bh_tau_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_TAU_PQU_HD(b_ma_dviN,b_nsdN,r_lp.ten_tau,r_lp.nhom,b_nt_tien,b_tuoi,r_lp.ma_sp,b_lt,dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TAU_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_XE_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nt_tien varchar2,
    b_tuoi number,b_md_sd varchar2,b_loai_xe varchar2,b_ma_sp varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_lh_nv pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS 
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_loaiL pht_type.a_var; a_maL pht_type.a_var; a_loi pht_type.a_var; a_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,b_dtuong,'XE',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
a_loaiL(1):='MDSD'; a_maL(1):=b_md_sd; a_loi(1):='muc dich su dung';
a_loaiL(2):='LOAI'; a_maL(2):=b_loai_xe; a_loi(2):='loai xe';
b_i1:=FKH_ARR_TONG(a_tien);
PBH_PQU_KTRA_MA(b_ma_dvi,b_nsd,'XE',b_i1,dk_ptG,a_loaiL,a_maL,a_loi,b_loi);
if b_loi is not null then return; end if;
if FBH_PQU_KTRA_KHn(b_ma_dvi,b_nsd,'XE_HD_TU',b_tuoi,'NB')='K' then
    b_loi:='loi:Vuot muc phan cap tuoi xe:loi'; return;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_XE_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_XE_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number; b_nt_tien varchar2(5); b_lt clob; b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select nt_tien into b_nt_tien from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_tuoi:=FBH_XE_TUOI(r_lp.nam_sx);
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_xe_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..dk_ma.count loop
        PBH_HD_CON_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,dk_lh_nv(b_lp),b_pt_con,b_loi);
        if b_loi is not null then return; end if;
        dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
    end loop;
    select lt into b_lt from bh_xe_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_XE_PQU_HD(b_ma_dviN,b_nsdN,r_lp.bien_xe,b_nt_tien,b_tuoi,r_lp.md_sd,r_lp.loai_xe,r_lp.ma_sp,b_lt,
        dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_XE_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_2B_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nt_tien varchar2,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS 
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,b_dtuong,'2B',' ',' ',dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_2B_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_2B_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tuoi number; b_nt_tien varchar2(5); b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select nt_tien into b_nt_tien from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
        from bh_2b_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    for b_lp in 1..dk_ma.count loop
        PBH_HD_CON_DT(b_ma_dvi,b_so_id,r_lp.so_id_dt,dk_lh_nv(b_lp),b_pt_con,b_loi);
        if b_loi is not null then return; end if;
        dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
    end loop;
    FBH_2B_PQU_HD(b_ma_dviN,b_nsdN,r_lp.bien_xe,b_nt_tien,dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_2B_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_PTN_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_nt_tien varchar2,b_ma_sp varchar2,b_ghm varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_tien pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,' ','PTN',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
if b_ghm<>' ' and FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'PTN_HD_GHM',b_ghm,'B')='K' then
    b_loi:='loi:Vuot phan cap gioi han muc trach nhiem:loi'; return;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_PTN_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_PTN_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_lt clob; b_i1 number; b_ma_sp varchar2(10); b_nt_tien varchar2(10); b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- dan - Kiem tra phan quyen
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
    from bh_ptn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for b_lp in 1..dk_ma.count loop
    PBH_HD_CON_DT(b_ma_dvi,b_so_id,0,dk_lh_nv(b_lp),b_pt_con,b_loi);
    if b_loi is not null then return; end if;
    dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
end loop;
for r_lp in (select * from bh_ptn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select count(*) into b_i1 from bh_ptn_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=1 then
        select lt into b_lt from bh_ptn_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        select lt into b_lt from bh_ptn_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    end if;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_PTN_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,FBH_PTN_TXT(b_ma_dvi,b_so_id,'ghan_m',r_lp.so_id_dt),b_lt,dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PTN_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_HOP_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_nt_tien varchar2,b_ma_sp varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_tien pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,' ','HOP',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_HOP_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_HOP_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_lt clob; b_i1 number; b_ma_sp varchar2(10); b_nt_tien varchar2(10); b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
    from bh_hop_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for b_lp in 1..dk_ma.count loop
    PBH_HD_CON_DT(b_ma_dvi,b_so_id,0,dk_lh_nv(b_lp),b_pt_con,b_loi);
    if b_loi is not null then return; end if;
    dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
end loop;
for r_lp in (select * from bh_hop_ds where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select count(*) into b_i1 from bh_hop_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=1 then
        select lt into b_lt from bh_hop_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        select lt into b_lt from bh_hop_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    end if;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_HOP_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,b_lt,dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HOP_PQU_HD:loi'; end if;
end;
/
create or replace procedure FBH_NONG_PQU_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_nt_tien varchar2,b_ma_sp varchar2,b_lt clob,
    dk_ma pht_type.a_var,dk_ten pht_type.a_nvar,
    dk_tien pht_type.a_num,dk_ptG pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
    a_tien pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
if b_nt_tien='VND' then
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=dk_tien(b_lp);
    end loop;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay,b_nt_tien);
    for b_lp in 1..dk_ma.count loop
        a_tien(b_lp):=round(b_i1*dk_tien(b_lp),0);
    end loop;
end if;
PBH_PQU_NHOM_KTHACa(b_ma_dvi,b_nsd,' ','NONG',b_ma_sp,b_lt,dk_ma,dk_ten,a_tien,dk_ptG,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_NONG_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_NONG_PQU_HD(
    b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_lt clob; b_i1 number; b_ma_sp varchar2(10); b_nt_tien varchar2(10); b_pt_con number;
    dk_ma pht_type.a_var; dk_lh_nv pht_type.a_var; dk_ten pht_type.a_nvar;
    dk_tien pht_type.a_num; dk_ptG pht_type.a_num;
begin
-- Nam - Kiem tra phan quyen
select ma_sp,nt_tien into b_ma_sp,b_nt_tien from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
select ma,lh_nv,ten,tien,ptG bulk collect into dk_ma,dk_lh_nv,dk_ten,dk_tien,dk_ptG
    from bh_nong_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
for b_lp in 1..dk_ma.count loop
    PBH_HD_CON_DT(b_ma_dvi,b_so_id,0,dk_lh_nv(b_lp),b_pt_con,b_loi);
    if b_loi is not null then return; end if;
    dk_tien(b_lp):=round(dk_tien(b_lp)*b_pt_con/100,0);
end loop;
for r_lp in (select * from bh_nong_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select count(*) into b_i1 from bh_nong_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1=1 then
        select lt into b_lt from bh_nong_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        select lt into b_lt from bh_nong_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=r_lp.so_id_dt;
    end if;
    b_lt:=FKH_JS_BONH(b_lt);
    FBH_NONG_PQU_HD(b_ma_dviN,b_nsdN,b_nt_tien,b_ma_sp,b_lt,dk_ma,dk_ten,dk_tien,dk_ptG,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NONG_PQU_HD:loi'; end if;
end;
/
create or replace procedure PBH_PQU_HD(
    b_nv varchar2,b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_lenh varchar2(1000);
begin
-- Dan - Ktra phan quyen
FBH_PQU_HD_CH(b_ma_dviN,b_nsdN,b_nv,b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
b_lenh:='begin PBH_'||b_nv||'_PQU_HD(:ma_dviN,:nsdN,:ma_dvi,:so_id,:loi); end;';
EXECUTE IMMEDIATE b_lenh using b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,out b_loi;
/*
if b_nv='PHH' then
    PBH_PHH_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='PKT' then
    PBH_PKT_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='XE' then
    PBH_XE_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='2B' then
    PBH_2B_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='TAU' then
    PBH_TAU_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='NG' then
    PBH_NG_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='HANG' then
    PBH_HANG_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
elsif b_nv='PTN' then
    PBH_PTN_PQU_HD(b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
end if;
*/
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PQU_HD:loi'; end if;
end;
/
create or replace function FBH_PQU_HD(
    b_nv varchar2,b_ma_dviN varchar2,b_nsdN varchar2,b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_loi varchar2(100); b_kq varchar2(1):='K';
begin
PBH_PQU_HD(b_nv,b_ma_dviN,b_nsdN,b_ma_dvi,b_so_id,b_loi);
if b_loi is null then b_kq:='C'; end if;
return b_kq;
end;
/


