create or replace procedure PTBH_TMB_CBI_DT(
    b_nv varchar2,b_ma_dvi varchar2,b_so_idD number,b_so_id_dt number,
    a_ma_dvi out pht_type.a_var,a_so_hd out pht_type.a_var,a_ten out pht_type.a_nvar,
    a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,b_loi out varchar2,b_dk varchar2:='T')
AS
begin
-- Dan - Tim doi tuong ghep
if b_nv='PHH' then
    PTBH_TMB_CBI_PHH(b_ma_dvi,b_so_idD,b_so_id_dt,a_ma_dvi,a_so_hd,a_ten,a_so_id,a_so_id_dt,b_loi,b_dk);
elsif b_nv='PKT' then
    PTBH_TMB_CBI_PKT(b_ma_dvi,b_so_idD,b_so_id_dt,a_ma_dvi,a_so_hd,a_ten,a_so_id,a_so_id_dt,b_loi,b_dk);
elsif b_nv='HANG' then
    PTBH_TMB_CBI_HANG(b_ma_dvi,b_so_idD,a_ma_dvi,a_so_hd,a_so_id,b_loi,b_dk);
    for b_lp in 1..a_ma_dvi.count loop
        a_ten(b_lp):=' '; a_so_id_dt(b_lp):=0;
    end loop;
else
    a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_idD; a_so_id_dt(1):=b_so_id_dt;
    a_ten(1):=' '; a_so_hd(1):=FBH_SO_HDd(b_nv,b_ma_dvi,b_so_idD);
    b_loi:='';
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_DT:loi'; else null; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_PHH(
    b_ma_dvi varchar2,b_so_idD number,b_so_id_dt number,
    a_ma_dvi out pht_type.a_var,a_so_hd out pht_type.a_var,a_ten out pht_type.a_nvar,
    a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,b_loi out varchar2,b_dk varchar2:='T')
AS
    b_i1 number; b_so_id number; b_ngay_hl number; b_ngay_kt number; b_ddiem nvarchar2(500);
    b_bt number:=0; b_kt number:=0; b_bd number; b_tdx number; b_tdy number; b_bk number; b_ttrang varchar2(1);
    a_tdx pht_type.a_num; a_tdy pht_type.a_num; a_bk pht_type.a_num;
    a_ngay_hl pht_type.a_num; a_ngay_kt pht_type.a_num;
begin
-- Dan - Tim doi tuong ghep
if nvl(trim(b_dk),' ')<>'D' then
    b_so_id:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_idD);
else
    b_so_id:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_idD);
end if;
if b_so_id=0 then b_loi:='loi:Hop dong da xoa (PTBH_TMB_CBI_PHH):loi'; return; end if;
select count(*) into b_i1 from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_i1=0 then b_loi:='loi:Doi tuong da xoa (PTBH_TMB_CBI_PHH):loi'; return; end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD(a_so_hd); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
select ttrang into b_ttrang from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
select tdx,tdy,bk,ngay_hl,ngay_kt,ddiem into b_tdx,b_tdy,b_bk,b_ngay_hl,b_ngay_kt,b_ddiem
    from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_tdx<>0 and REGEXP_COUNT(b_ddiem, ',')>2 then
    if b_bk=0 then b_bk:=25; end if;
    for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt,dvi from bh_phh_ttu
        where so_id_dt<>b_so_id_dt and FBH_KH_AHUONG(b_tdx,b_tdy,b_bk,tdx,tdy,bk)='C' and
        FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C') loop
        if FBH_HD_CO_TAM(r_lp.ma_dvi,r_lp.so_id)='C' and (b_ttrang='D' or FBH_HD_SO_ID_BSd(r_lp.ma_dvi,r_lp.so_id)<>0) then
            b_bt:=b_bt+1;
            a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
            a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
            a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt; a_ten(b_kt):=r_lp.dvi;
        end if;
    end loop;
end if;
if b_bt<>0 then
    loop
        b_bd:=b_kt+1; b_kt:=b_bt;
        for b_lp in b_bd..b_kt loop
            for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt,dvi from bh_phh_ttu where
                so_id_dt not in(b_so_id_dt,a_so_id_dt(b_lp)) and
                FBH_KH_AHUONG(a_tdx(b_lp),a_tdx(b_lp),a_bk(b_lp),tdx,tdy,bk)='C' and
                FKH_GIAO(a_ngay_hl(b_lp),a_ngay_kt(b_lp),ngay_hl,ngay_kt)='C') loop
                b_i1:=0;
                for b_lp1 in 1..a_ma_dvi.count loop
                    if r_lp.so_id_dt=a_so_id_dt(b_lp1) then b_i1:=1; exit; end if;
                end loop;
                if b_i1=0 and FBH_HD_CO_TAM(r_lp.ma_dvi,r_lp.so_id)='C' and
                    (b_ttrang='D' or FBH_HD_SO_ID_BSd(r_lp.ma_dvi,r_lp.so_id)<>0) then
                    b_bt:=b_bt+1;
                    a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
                    a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
                    a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt; a_ten(b_kt):=r_lp.dvi;
                end if;
            end loop;
        end loop;
        exit when b_kt=b_bt;
    end loop;
end if;
b_kt:=a_ma_dvi.count+1;
a_ma_dvi(b_kt):=b_ma_dvi; a_so_id(b_kt):=FBH_PHH_SO_IDd(b_ma_dvi,b_so_id); a_so_id_dt(b_kt):=b_so_id_dt;
for b_lp in 1..b_kt loop
    a_so_hd(b_lp):=FBH_PHH_SO_HDd(a_ma_dvi(b_lp),a_so_id(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_PHH:loi'; else null; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_PKT(
    b_ma_dvi varchar2,b_so_idD number,b_so_id_dt number,
    a_ma_dvi out pht_type.a_var,a_so_hd out pht_type.a_var,a_ten out pht_type.a_nvar,
    a_so_id out pht_type.a_num,a_so_id_dt out pht_type.a_num,b_loi out varchar2,b_dk varchar2:='T')
AS
    b_i1 number; b_so_id number; b_ngay_hl number; b_ngay_kt number; b_ddiem nvarchar2(500);
    b_bt number:=0; b_kt number:=0; b_bd number; b_tdx number; b_tdy number; b_bk number; b_ttrang varchar2(1);
    a_tdx pht_type.a_num; a_tdy pht_type.a_num; a_bk pht_type.a_num;
    a_ngay_hl pht_type.a_num; a_ngay_kt pht_type.a_num;
begin
-- Dan - Tim doi tuong ghep
if nvl(trim(b_dk),' ')<>'D' then
    b_so_id:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_idD);
else
    b_so_id:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_idD);
end if;
if b_so_id=0 then b_loi:='loi:Hop dong da xoa (PTBH_TMB_CBI_PKT):loi'; return; end if;
select count(*) into b_i1 from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_i1=0 then b_loi:='loi:Doi tuong da xoa (PTBH_TMB_CBI_PKT):loi'; return; end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD(a_so_hd); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
select ttrang into b_ttrang from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
select tdx,tdy,bk,ngay_hl,ngay_kt,ddiem into b_tdx,b_tdy,b_bk,b_ngay_hl,b_ngay_kt,b_ddiem
    from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_tdx<>0 and REGEXP_COUNT(b_ddiem, ',')>2 then
    if b_bk=0 then b_bk:=25; end if;
    for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt,dvi from bh_pkt_ttu
        where so_id_dt<>b_so_id_dt and FBH_KH_AHUONG(b_tdx,b_tdy,b_bk,tdx,tdy,bk)='C' and
        FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_hl,ngay_kt)='C') loop
        if FBH_HD_CO_TAM(r_lp.ma_dvi,r_lp.so_id)='C' and (b_ttrang='D' or FBH_HD_SO_ID_BSd(r_lp.ma_dvi,r_lp.so_id)<>0) then
            b_bt:=b_bt+1;
            a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
            a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
            a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt; a_ten(b_kt):=r_lp.dvi;
        end if;
    end loop;
end if;
if b_bt<>0 then
    loop
        b_bd:=b_kt+1; b_kt:=b_bt;
        for b_lp in b_bd..b_kt loop
            for r_lp in (select ma_dvi,so_id,so_id_dt,tdx,tdy,bk,ngay_hl,ngay_kt,dvi from bh_pkt_ttu where
                so_id_dt not in(b_so_id_dt,a_so_id_dt(b_lp)) and
                FBH_KH_AHUONG(a_tdx(b_lp),a_tdx(b_lp),a_bk(b_lp),tdx,tdy,bk)='C' and
                FKH_GIAO(a_ngay_hl(b_lp),a_ngay_kt(b_lp),ngay_hl,ngay_kt)='C') loop
                b_i1:=0;
                for b_lp1 in 1..a_ma_dvi.count loop
                    if r_lp.so_id_dt=a_so_id_dt(b_lp1) then b_i1:=1; exit; end if;
                end loop;
                if b_i1=0 and FBH_HD_CO_TAM(r_lp.ma_dvi,r_lp.so_id)='C' and
                    (b_ttrang='D' or FBH_HD_SO_ID_BSd(r_lp.ma_dvi,r_lp.so_id)<>0) then
                    b_bt:=b_bt+1;
                    a_ma_dvi(b_bt):=r_lp.ma_dvi; a_so_id(b_bt):=r_lp.so_id; a_so_id_dt(b_bt):=r_lp.so_id_dt;
                    a_tdx(b_bt):=r_lp.tdx; a_tdy(b_bt):=r_lp.tdy; a_bk(b_bt):=r_lp.bk;
                    a_ngay_hl(b_bt):=r_lp.ngay_hl; a_ngay_kt(b_bt):=r_lp.ngay_kt; a_ten(b_kt):=r_lp.dvi;
                end if;
            end loop;
        end loop;
        exit when b_kt=b_bt;
    end loop;
end if;
b_kt:=a_ma_dvi.count+1;
a_ma_dvi(b_kt):=b_ma_dvi; a_so_id(b_kt):=b_so_id; a_so_id_dt(b_kt):=b_so_id_dt;
for b_lp in 1..b_kt loop
    a_so_hd(b_lp):=FBH_PKT_SO_HDd(a_ma_dvi(b_lp),a_so_id(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_TMB_CBI_PKT:loi'; end if;
end;
/
create or replace procedure PTBH_TMB_CBI_HANG(
    b_ma_dvi varchar2,b_so_idD number,
    a_ma_dvi out pht_type.a_var,a_so_hd out pht_type.a_var,
    a_so_id out pht_type.a_num,b_loi out varchar2,b_dk varchar2:='T')
AS
    b_i1 number; b_ngay_hl number; b_ngay_kt number; b_so_id number;
    b_bt number:=0; b_bd number; b_kt number:=0; b_uoc number; b_vchuyen varchar2(10); b_nhang varchar2(10);
    a_ngay_hl pht_type.a_num; a_ngay_kt pht_type.a_num; b_ttrang varchar2(1);
begin
-- Nam - Tim doi tuong ghep
if b_dk='T' then
    b_so_id:=FBH_HD_SO_ID_BSt(b_ma_dvi,b_so_idD);
else
    b_so_id:=FBH_HD_SO_ID_BSd(b_ma_dvi,b_so_idD);
end if;
if b_so_id=0 then b_loi:=''; return; end if;
--nam: hang nhieu chuyen khong xu ly tai
if FBH_HANG_TXT(b_ma_dvi,b_so_id,'hd_kem')<>'K' then b_loi:=''; return; end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD(a_so_hd); PKH_MANG_KD_N(a_so_id);
select ttrang,vchuyen,thoi_gian,nhang,ngay_cap into b_ttrang,b_vchuyen,b_uoc,b_nhang,b_ngay_hl
    from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_uoc=0 then b_uoc:=FBH_HANG_NHANG_UOC(b_nhang); end if;
b_ngay_kt:=PKH_NG_CSO(PKH_SO_CDT(b_ngay_hl)+b_uoc);
if b_uoc<>0 and FBH_HANG_PT_TAI(b_vchuyen)='C' then 
   for r_lp in (select pt,ten_pt,so_imo from bh_hang_ptvc where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
       if nvl(r_lp.so_imo,' ')<>' ' or nvl(r_lp.ten_pt,' ')<>' 'then
         for r_lp1 in (select ma_dvi,so_id,pt,ten_pt,so_imo,ngay_cap,ngay_hl,ngay_kt,ttrang from bh_hang_ttu
            where so_id<>b_so_id and hd_kem='K' and kieu_hd in('G','K') and ttrang='D' and vchuyen=b_vchuyen and
              pt=r_lp.pt and ten_pt=r_lp.ten_pt and so_imo=r_lp.so_imo and
              FKH_GIAO(b_ngay_hl,b_ngay_kt,ngay_cap,PKH_NG_CSO(PKH_SO_CDT(ngay_cap)+b_uoc))='C') loop
              if FBH_HD_CO_TAM(r_lp1.ma_dvi,r_lp1.so_id)<>'C' or (b_ttrang='T' and FBH_HD_SO_ID_BSd(r_lp1.ma_dvi,r_lp1.so_id)=0) then continue; end if;
                b_bt:=b_bt+1;
                a_ma_dvi(b_bt):=r_lp1.ma_dvi; a_so_id(b_bt):=r_lp1.so_id;
                a_ngay_hl(b_bt):=r_lp1.ngay_hl; a_ngay_kt(b_bt):=r_lp1.ngay_kt;
         end loop;
      end if;
      if b_bt<>0 then
         loop
              b_bd:=b_kt+1; b_kt:=b_bt;
              for b_lp in b_bd..b_kt loop
                  for r_lp1 in (select ma_dvi,so_id,pt,ten_pt,so_imo,ngay_cap,ngay_hl,ngay_kt,ttrang from bh_hang_ttu
                    where so_id<>b_so_id and so_id=so_id and hd_kem='K' and kieu_hd in('G','K') and ttrang='D' and vchuyen=b_vchuyen and
                      pt=r_lp.pt and ten_pt=r_lp.ten_pt and so_imo=r_lp.so_imo and
                      FKH_GIAO(a_ngay_hl(b_lp),a_ngay_kt(b_lp),ngay_hl,ngay_kt)='C') loop
                      b_i1:=0;
                      for b_lp1 in 1..a_ma_dvi.count loop
                          if r_lp1.so_id=a_so_id(b_lp1) then b_i1:=1; exit; end if;
                      end loop;
                      if b_i1=0 and FBH_HD_CO_TAM(r_lp1.ma_dvi,r_lp1.so_id)='C' then
                          b_bt:=b_bt+1;
                          a_ma_dvi(b_bt):=r_lp1.ma_dvi; a_so_id(b_bt):=r_lp1.so_id;
                          a_ngay_hl(b_bt):=r_lp1.ngay_hl; a_ngay_kt(b_bt):=r_lp1.ngay_kt;
                      end if;
                  end loop;
              end loop;
              exit when b_kt=b_bt;
          end loop;
      end if;
    end loop;
end if;
b_kt:=a_ma_dvi.count+1;
a_ma_dvi(b_kt):=b_ma_dvi; a_so_id(b_kt):=FBH_HANG_SO_IDd(b_ma_dvi,b_so_id);
for b_lp in 1..b_kt loop
    a_so_hd(b_lp):=FBH_HANG_SO_HDd(a_ma_dvi(b_lp),a_so_id(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_CBI_TAO_HANG:loi'; end if;
end;
/
