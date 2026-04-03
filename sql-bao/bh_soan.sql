create or replace function FTBH_SOAN_TXT(
    b_ma_dvi varchar2,b_so_id number,b_tim varchar2,b_tso varchar2:=' ') return varchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_lenh varchar2(1000); b_nv varchar2(10); b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
b_nv:=FTBH_SOAN_NVt(b_ma_dvi,b_so_id,b_tso);
if b_nv=' ' then return ' '; end if;
b_lenh:='select FBH_'||b_nv||'_TXT(:ma_dvi,:so_id,:tim) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id,b_tim;
return b_kq;
end;
/
create or replace function FTBH_SOANd_TXT(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_tim varchar2,b_tso varchar2:=' ') return varchar2
AS
    b_kq nvarchar2(500):=' '; b_lenh varchar2(1000); b_nv varchar2(10); b_txt clob;
begin
-- Dan - Tra gia tri varchar2 trong txt
b_nv:=FTBH_SOAN_NVt(b_ma_dvi,b_so_id,b_tso);
if b_nv=' ' then return ' '; end if;
if b_so_id_dt=0 or b_nv not in('PHH','PKT','2B','XE','TAU') then
    b_kq:=FTBH_SOAN_TXT(b_ma_dvi,b_so_id,b_tim,b_tso);
else
    b_lenh:='select FBH_'||b_nv||'_TXT(:ma_dvi,:so_id,:tim,:so_id_dt) from dual';
    EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id,b_tim,b_so_id_dt;
end if;
return b_kq;
end;
/
create or replace function FTBH_SOAN_NVt(b_ma_dvi varchar2,b_so_id number,b_tso varchar2:=' ') return varchar2
AS
    b_kq varchar2(10); b_lenh varchar2(1000); b_nv varchar2(200); b_i1 number;
    a_nv pht_type.a_var;
begin
-- Dan - Tra ID qua so hd
b_kq:=FKH_JS_GTRIs(b_tso,'nv',' ');
if b_kq<>' ' then return b_kq; end if;
if FKH_JS_GTRIs(b_tso,'kieu_ps')='B' then
    select nvl(min(nv),' ') into b_kq from bh_bao where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq<>' ' then return b_kq; end if;
end if;
b_nv:='PHH,PKT,PTNCC,PTNNN,PTNVC,PTN,2B,XE,TAU,HANG,HOP,GOP,NONGCT,NONGTS,NONGVN,NONG,NG,SK,NGDL,NGTD';
PKH_CH_ARR(b_nv,a_nv);
for b_lp in 1..a_nv.count loop
    b_lenh:='select count(*) from bh_'||a_nv(b_lp)||' where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh into b_i1 using b_ma_dvi,b_so_id;
    if b_i1<>0 then b_kq:=a_nv(b_lp); exit; end if;
end loop;
return b_kq;
end;
/
create or replace function FTBH_SOAN_SO_ID(b_ma_dvi varchar2,b_so_hd number,b_nv varchar2) return number
AS
    b_kq number; b_lenh varchar2(1000);
begin
-- Dan - Tra ID qua so hd
b_lenh:='select nvl(min(so_id),0) from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_hd= :so_hd';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_hd;
if b_nv='NG' and b_kq=0 then
    select nvl(min(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
    if b_kq=0 then
        select nvl(min(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
        if b_kq=0 then
            select nvl(min(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
        end if;
    end if;
elsif b_nv='PTN' and b_kq=0 then
    select nvl(min(so_id),0) into b_kq from bh_ptncc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
    if b_kq=0 then
        select nvl(min(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
        if b_kq=0 then
            select nvl(min(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_SOAN_SO_HD(b_ma_dvi varchar2,b_so_id number,b_nvN varchar2:=' ') return varchar2
AS
    b_kq varchar2(20); b_lenh varchar2(1000); b_nv varchar2(10):=b_nvN;
begin
-- Dan - Tra so hd qua ID
if b_nv=' ' then b_nv:=FTBH_SOAN_NVt(b_ma_dvi,b_so_id); end if;
b_lenh:='select min(so_hd) from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id;
if b_kq is null and b_nvN='NG' then
    select nvl(min(so_hd),' ') into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq=' ' then
        select nvl(min(so_hd),' ') into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_kq=' ' then
            select nvl(min(so_hd),' ') into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    end if;
elsif b_kq is null and b_nvN='PTN' then
    select nvl(min(so_hd),' ') into b_kq from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq=' ' then
        select nvl(min(so_hd),' ') into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_kq=' ' then
            select nvl(min(so_hd),' ') into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_SOAN_SO_IDd(b_ma_dvi varchar2,b_so_id number,b_nvN varchar2:=' ') return number
AS
    b_kq number; b_lenh varchar2(1000); b_nv varchar2(10):=b_nvN;
begin
-- Dan - Tra so IDd
if b_nv=' ' then b_nv:=FTBH_SOAN_NVt(b_ma_dvi,b_so_id); end if;
b_lenh:='select nvl(min(so_id_d),0) from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_id;
if b_kq=0 and b_nvN='NG' then
    select nvl(min(so_id_d),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq=0 then
        select nvl(min(so_id_d),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_kq=0 then
            select nvl(min(so_id_d),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    end if;
elsif b_kq=0 and b_nvN='PTN' then
    select nvl(min(so_id_d),0) into b_kq from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq=0 then
        select nvl(min(so_id_d),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_kq=0 then
            select nvl(min(so_id_d),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
            if b_kq=0 then
              select nvl(min(so_id_d),0) into b_kq from bh_ptnch where ma_dvi=b_ma_dvi and so_id=b_so_id;
            end if;
        end if;
    end if;
elsif b_kq=0 and b_nvN='NONG' then
    select nvl(min(so_id_d),0) into b_kq from bh_nongct where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_kq=0 then
        select nvl(min(so_id_d),0) into b_kq from bh_nongts where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_kq=0 then
            select nvl(min(so_id_d),0) into b_kq from bh_nongvn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_SOAN_SO_IDb(b_ma_dvi varchar2,b_so_id number,b_nvN varchar2:=' ') return number
AS
    b_kq number; b_lenh varchar2(1000); b_so_idD number; b_nv varchar2(10):=b_nvN;
begin
-- Dan - Tra so IDb
if b_nv=' ' then b_nv:=FTBH_SOAN_NVt(b_ma_dvi,b_so_id); end if;
b_so_idD:=FTBH_SOAN_SO_IDd(b_ma_dvi,b_so_id,b_nv);
if b_so_idD=0 then return 0; end if;
b_lenh:='select nvl(max(so_id),0) from bh_'||b_nv||' where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_dvi,b_so_idD;
if b_kq=0 and b_nvN='NG' then
    select nvl(max(so_id),0) into b_kq from bh_sk where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    if b_kq=0 then
        select nvl(max(so_id),0) into b_kq from bh_ngdl where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
        if b_kq=0 then
            select nvl(max(so_id),0) into b_kq from bh_ngtd where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
        end if;
    end if;
elsif b_kq=0 and b_nvN='PTN' then
    select nvl(max(so_id),0) into b_kq from bh_ptncc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
    if b_kq=0 then
        select nvl(max(so_id),0) into b_kq from bh_ptnnn where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
        if b_kq=0 then
            select nvl(max(so_id),0) into b_kq from bh_ptnvc where ma_dvi=b_ma_dvi and so_id_d=b_so_idD;
        end if;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PTBH_SOAN_TTINf(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,
    b_so_hd out varchar2,b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number,
    b_nt_tien out varchar2,b_nt_phi out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ch varchar2(10);
begin
-- Dan - Tra ttin hd
b_i1:=FTBH_SOAN_SO_IDb(b_ma_dvi,b_so_id,b_nv);
if b_nv='PHH' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_phh where ma_dvi=b_ma_dvi and so_id=b_i1;
elsif b_nv='PKT' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_i1;
elsif b_nv='PTN' then
    b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id); -- nam sua lai nghiep vu ptn
    if b_ch=' ' then
        select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_i1<>0 then
            select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
                from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    else
        select count(*) into b_i1 from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if b_i1<>0 then
            select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
                from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        elsif b_ch='CC' then
            select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
                from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_id;
        elsif b_ch='NN' then
            select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
                from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_id;
        else
            select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
                from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    end if;
elsif b_nv='2B' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_2b where ma_dvi=b_ma_dvi and so_id=b_i1;
elsif b_nv='XE' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_xe where ma_dvi=b_ma_dvi and so_id=b_i1;
elsif b_nv='TAU' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_tau where ma_dvi=b_ma_dvi and so_id=b_i1;
elsif b_nv='HANG' then
    select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_hang where ma_dvi=b_ma_dvi and so_id=b_i1;
elsif b_nv='NG' then
    b_ch:=FBH_SOAN_BGHD_NG(b_ma_dvi,b_so_id);
    if b_ch=' ' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ng where ma_dvi=b_ma_dvi and so_id=b_i1;
    elsif b_ch='SK' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_sk where ma_dvi=b_ma_dvi and so_id=b_i1;
    elsif b_ch='DL' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_i1;
    else
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_i1;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_TTINf:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_TTINft(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,
    b_so_hd out varchar2,b_ngay_ht out number,b_ngay_hl out number,b_ngay_kt out number,
    b_nt_tien out varchar2,b_nt_phi out varchar2,b_so_idB out number,b_loi out varchar2)
AS
    b_ch varchar2(10); b_il number;
begin
-- Dan - Tra ttin hd
b_so_idB:=FTBH_SOAN_SO_IDb(b_ma_dvi,b_so_id,b_nv);
--Nam: select count de kiem tra truoc
if b_nv='PHH' then
    select count(*) into b_il from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
elsif b_nv='PKT' then
    select count(*) into b_il from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
elsif b_nv='PTN' then
    b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id);
    if b_ch=' ' then
        select count(*) into b_il from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
        if b_il<>0 then
          select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
        end if;
    elsif b_ch='CC' then
      select count(*) into b_il from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
      if b_il<>0 then
         select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
      end if;
    elsif b_ch='NN' then
      select count(*) into b_il from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
      if b_il<>0 then
         select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
      end if;
    else
      select count(*) into b_il from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
      if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
      end if;
    end if;
elsif b_nv='2B' then
    select count(*) into b_il from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;   
elsif b_nv='XE' then
    select count(*) into b_il from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
elsif b_nv='TAU' then
    select count(*) into b_il from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
elsif b_nv='HANG' then
    select count(*) into b_il from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    if b_il<>0 then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
        from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
elsif b_nv='NG' then
    b_ch:=FBH_SOAN_BGHD_NG(b_ma_dvi,b_so_id);
    if b_ch=' ' then
        select count(*) into b_il from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idB;
        if b_il<>0 then
            select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idB;
        end if;
    elsif b_ch='SK' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_ch='DL' then
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    else
        select ngay_ht,ngay_hl,ngay_kt,nt_tien,nt_phi into b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi
            from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_TTINft:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_TTINt(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,
    b_so_hd out varchar2,b_ngay_ht out number,b_nt_tien out varchar2,b_nt_phi out varchar2,
    b_ttrang out varchar2,b_so_idD out number,b_so_idB out number,b_loi out varchar2)
AS
    b_ch varchar2(10);
begin
-- Dan - Tra ttin hd cbi tai TM
b_so_idB:=FTBH_SOAN_SO_IDb(b_ma_dvi,b_so_id,b_nv);
if b_nv='PHH' then
    select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
        into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
        from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PKT' then
    select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
        into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
        from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='PTN' then
    b_ch:=FBH_SOAN_BGHD_PTN(b_ma_dvi,b_so_id);
    if b_ch=' ' then
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_ch='CC' then
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ptncc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_ch='NN' then
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ptnnn where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    else
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ptnvc where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
elsif b_nv='2B' then
    select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
        into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
        from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='XE' then
    select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
        into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
        from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='TAU' then
    select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
        into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
        from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='HANG' then
    select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
        into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
        from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_idB;
elsif b_nv='NG' then
    b_ch:=FBH_SOAN_BGHD_NG(b_ma_dvi,b_so_id);
    if b_ch=' ' then
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_ch='SK' then
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    elsif b_ch='DL' then
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ngdl where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    else
        select ngay_ht,nt_tien,nt_phi,ttrang,so_id_d
            into b_ngay_ht,b_nt_tien,b_nt_phi,b_ttrang,b_so_idD
            from bh_ngtd where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_TTINt:loi'; end if;
end;
/
create or replace PROCEDURE FTBH_SOAN_NV(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,
    a_so_id_dtB out pht_type.a_num,a_ghepB out pht_type.a_var,
    a_so_id_dtBG out pht_type.a_num,a_ma_dviG out pht_type.a_var,
    a_so_idG out pht_type.a_num,a_so_id_dtG out pht_type.a_num,b_loi out varchar2)
AS
begin
-- Dan - Tim doi tuong trong bao gia va cac doi tuong ghep
PKH_MANG_KD_N(a_so_id_dtB); PKH_MANG_KD(a_ghepB); PKH_MANG_KD_N(a_so_id_dtBG);
PKH_MANG_KD(a_ma_dviG); PKH_MANG_KD_N(a_so_idG); PKH_MANG_KD_N(a_so_id_dtG);
if b_nv='PHH' then
    PTBH_BAO_GHDT_PHH(b_ma_dvi,b_so_id,
        a_so_id_dtB,a_ghepB,a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
elsif b_nv='PKT' then
    PTBH_BAO_GHDT_PKT(b_ma_dvi,b_so_id,
        a_so_id_dtB,a_ghepB,a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
elsif b_nv='XE' then
    PTBH_BAO_GHDT_XE(b_ma_dvi,b_so_id,a_so_id_dtB,b_loi);
elsif b_nv='2B' then
    PTBH_BAO_GHDT_2B(b_ma_dvi,b_so_id,a_so_id_dtB,b_loi);
elsif b_nv='TAU' then
    PTBH_BAO_GHDT_TAU(b_ma_dvi,b_so_id,a_so_id_dtB,b_loi);
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_SOAN_NV:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_TLd(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,b_loi out varchar2,b_so_id_ta number:=0)
AS
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_tso varchar2(200); b_so_idB number;
    b_ngay_ht number; b_ngay_hl number; b_ngay_kt number; b_so_hd varchar2(20); b_cdt varchar2(10);
begin
-- Dan - Tinh phan bo ty le tai cho 1 doi tuong
delete tbh_ghep_tl_temp;
b_tso:='{"xly":"F","ttrang":"S","nv":"'||b_nv||'"}';
if a_ma_dvi.count=1 then
    b_cdt:=FTBH_SOANd_TXT(b_ma_dvi,b_so_id,b_so_id_dt,'cdt',b_tso);
    if b_cdt<>' ' and instr(b_cdt,'F')=0 then b_loi:=''; return; end if;
end if;
PTBH_SOAN_TTINft(b_ma_dvi,b_so_id,b_nv,b_so_hd,b_ngay_ht,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_so_idB,b_loi);
if b_loi is not null then return; end if;
PTBH_GHEP_TL(b_so_id_ta,b_ngay_ht,b_ngay_hl,b_nv,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_tso);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_TLd:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_TLv(
    b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_vuot out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; b_so_id_dtB number;
    a_so_id_dtB pht_type.a_num; a_ghepB pht_type.a_var;
    a_so_id_dtBG pht_type.a_num; a_ma_dviG pht_type.a_var;
    a_so_idG pht_type.a_num; a_so_id_dtG pht_type.a_num;

    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Kiem tra soan vuot nguong
b_vuot:='K';
if FBH_HD_CO_TAM(b_ma_dvi,b_so_id)<>'C' then b_loi:=''; return; end if;
FTBH_SOAN_NV(b_ma_dvi,b_so_id,b_nv,a_so_id_dtB,a_ghepB,a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
if b_loi is not null then return; end if;
if a_so_id_dtB.count=0 then
    a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=0;
    PTBH_SOAN_TLd(b_ma_dvi,b_so_id,0,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
    if b_i1<>0 then b_vuot:='C'; end if;
else
    PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
    for b_lp in 1..a_so_id_dtB.count loop
        PKH_MANG_XOA(a_ma_dvi); PKH_MANG_XOA_N(a_so_id); PKH_MANG_XOA_N(a_so_id_dt);
        b_so_id_dtB:=a_so_id_dtB(b_lp); b_kt:=1;
        a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=b_so_id_dtB;
        for b_lp1 in 1..a_so_id_dtBG.count loop
            if a_so_id_dtBG(b_lp1)=b_so_id_dtB then
                b_kt:=b_kt+1;
                a_ma_dvi(b_kt):=a_ma_dviG(b_lp1); a_so_id(b_kt):=a_so_idG(b_lp1); a_so_id_dt(b_kt):=a_so_id_dtG(b_lp1); 
            end if;
        end loop;
        PTBH_SOAN_TLd(b_ma_dvi,b_so_id,b_so_id_dtB,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
        if b_loi is not null then return; end if;
        select count(*) into b_i1 from tbh_ghep_tl_temp where pthuc='O';
        if b_i1<>0 then b_vuot:='C'; exit; end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_TLv:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_CBI(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; b_so_id_dtB number;
    a_so_id_dtB pht_type.a_num; a_ghepB pht_type.a_var;
    a_so_id_dtBG pht_type.a_num; a_ma_dviG pht_type.a_var;
    a_so_idG pht_type.a_num; a_so_id_dtG pht_type.a_num;

    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Kiem tra soan vuot nguong
FTBH_SOAN_NV(b_ma_dvi,b_so_id,b_nv,a_so_id_dtB,a_ghepB,
    a_so_id_dtBG,a_ma_dviG,a_so_idG,a_so_id_dtG,b_loi);
if b_loi is not null then return; end if;
PKH_MANG_KD(a_ma_dvi); PKH_MANG_KD_N(a_so_id); PKH_MANG_KD_N(a_so_id_dt);
if a_so_id_dtB.count=0 then
    a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=0;
    PTBH_SOAN_TLd(b_ma_dvi,b_so_id,0,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
    if b_loi is not null then return; end if;
    select count(*) into b_i1 from tbh_ghep_tl_temp where so_id_ta=0;
else
    for b_lp in 1..a_so_id_dtB.count loop
        PKH_MANG_XOA(a_ma_dvi); PKH_MANG_XOA_N(a_so_id); PKH_MANG_XOA_N(a_so_id_dt);
        b_so_id_dtB:=a_so_id_dtB(b_lp); b_kt:=1;
        a_ma_dvi(1):=b_ma_dvi; a_so_id(1):=b_so_id; a_so_id_dt(1):=b_so_id_dtB;
        for b_lp1 in 1..a_so_id_dtBG.count loop
            if a_so_id_dtBG(b_lp1)=b_so_id_dtB then
                b_kt:=b_kt+1;
                a_ma_dvi(b_kt):=a_ma_dviG(b_lp1); a_so_id(b_kt):=a_so_idG(b_lp1); a_so_id_dt(b_kt):=a_so_id_dtG(b_lp1); 
            end if;
        end loop;
        PTBH_SOAN_TLd(b_ma_dvi,b_so_id,b_so_id_dtB,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi);
        if b_loi is not null then return; end if;
        select count(*) into b_i1 from tbh_ghep_tl_temp where so_id_ta=0;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_CBI:loi'; end if;
end;
/
create or replace procedure PTBH_SOAN_TLm(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nv varchar2,
    a_ma_dvi pht_type.a_var,a_so_id pht_type.a_num,a_so_id_dt pht_type.a_num,
    b_ngay_hl out number,b_ngay_kt out number,b_vuot out number,b_loi out varchar2,b_so_id_ta number:=0)
AS
    b_ngay_hlD number; b_ngay_ktD number;
    b_so_hd varchar2(20); b_ngay_ht number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
begin
-- Dan - Tra % vuot nguong
PTBH_SOAN_TLd(b_ma_dvi,b_so_id,b_so_id_dt,b_nv,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,b_so_id_ta);
if b_loi is not null then return; end if;
select nvl(max(pt),0) into b_vuot from tbh_ghep_tl_temp where pthuc='O';
b_ngay_hl:=30000101; b_ngay_kt:=0;
for b_lp in 1..a_ma_dvi.count loop
    PTBH_SOAN_TTINf(a_ma_dvi(b_lp),a_so_id(b_lp),b_nv,b_so_hd,b_ngay_ht,b_ngay_hlD,b_ngay_ktD,b_nt_tien,b_nt_phi,b_loi);
    if b_loi is not null then return; end if;
    if b_ngay_hl>b_ngay_hlD then b_ngay_hl:=b_ngay_hlD; end if;
    if b_ngay_kt<b_ngay_ktD then b_ngay_kt:=b_ngay_ktD; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_SOAN_TLm:loi'; end if;
end;
/
