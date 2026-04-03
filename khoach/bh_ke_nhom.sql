create or replace procedure PBH_KE_CTI_NHOM(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_nhom out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_nv varchar2(10); b_ngay_ht number;
    b_so_idN number; b_cti varchar2(500); b_ma varchar2(50); b_ham varchar2(50); b_kq varchar2(1);
    a_nhom pht_type.a_var;
begin
-- Dan - Tra nhom
b_nhom:=' ';
select nv,ngay_ht into b_nv,b_ngay_ht from bh_hd_goc where ma_dvi=b_ma_dvi and so_id=b_so_id;
select distinct ma bulk collect into a_nhom from bh_ke_thu_dt where nv=b_nv and tc='C' and ngay_kt>b_ngay_ht;
for b_lp in 1..a_nhom.count loop
    b_kq:='K';
    select nvl(max(so_id),0) into b_so_idN from bh_ke_thu_cti
        where nv=b_nv and ma=a_nhom(b_lp) and ngay_hl<=b_ngay_ht;
    for r_lp in (select * from bh_ke_thu_cti_ct where so_id=b_so_idN and loai<>'G') loop
        b_ma:=r_lp.ma; b_ham:=' '; b_i1:=instr(b_ma,'$'); b_ham:='PBH_KE_CTI';
        if b_i1>0 then
            if b_i1>1 then b_ham:=b_ham||'_'||substr(b_ma,1,b_i1-1); end if;
            if length(b_ma)>b_i1 then b_ma:=substr(b_ma,b_i1+1); else b_ma:=' '; end if;
        else
            b_i1:=instr(b_ma,'@');
            if b_i1>0 then
                b_ham:=b_ham||'_'||b_nv;
                if b_i1>1 then b_ham:=b_ham||'_'||substr(b_ma,1,b_i1-1); end if;
                if length(b_ma)>b_i1 then b_ma:=substr(b_ma,b_i1+1); else b_ma:=' '; end if;
            else
                b_ham:='PBH_KE_CTI_'||b_nv||'_'||r_lp.ma; b_ma:=' ';
            end if;
        end if;
        if b_ma=' ' then
            b_lenh:='begin '||b_ham||'(:loai,:ma_dvi,:so_id,:so_id_dt,:cti,:loi); end;';
            EXECUTE IMMEDIATE b_lenh using r_lp.loai,b_ma_dvi,b_so_id,b_so_id_dt,out b_cti,out b_loi;
        else
            b_lenh:='begin '||b_ham||'(:ma,:loai,:ma_dvi,:so_id,:so_id_dt,:cti,:loi); end;';
            EXECUTE IMMEDIATE b_lenh using b_ma,r_lp.loai,b_ma_dvi,b_so_id,b_so_id_dt,out b_cti,out b_loi;
        end if;
        if b_loi is not null then return; end if;
        b_kq:=FKH_KHO_KTRA(b_cti,r_lp.loai,r_lp.tu_dk,r_lp.tu_nd,r_lp.den_dk,r_lp.den_nd);
        if b_kq='K' then exit; end if;
    end loop;
    if b_kq='C' then b_nhom:=a_nhom(b_lp); exit; end if;
end loop;
if b_nhom=' ' then
    for r_lp in(select ma from bh_ke_thu_dt where nv=b_nv order by ma) loop
        select count(*) into b_i1 from bh_ke_thu_cti where nv=b_nv and ma=r_lp.ma;
        if b_i1=0 then b_nhom:=r_lp.ma; exit; end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_NHOM:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_2B(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,
    b_so_id_dt number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_2B_TXT(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
else
    b_kq:=to_char(FBH_2B_TXTn(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_2B:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_XE(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,
    b_so_id_dt number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_XE_TXT(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
else
    b_kq:=to_char(FBH_XE_TXTn(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_XE:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_TAU(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,
    b_so_id_dt number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_TAU_TXT(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
else
    b_kq:=to_char(FBH_TAU_TXTn(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_TAU:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_PHH(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,
    b_so_id_dt number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_PHH_TXT(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
else
    b_kq:=to_char(FBH_PHH_TXTn(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_PHH:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_PKT(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,
    b_so_id_dt number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_PKT_TXT(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
else
    b_kq:=to_char(FBH_PKT_TXTn(b_ma_dvi,b_so_id,b_ma,b_so_id_dt));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_PKT:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_PTN(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_PTN_TXT(b_ma_dvi,b_so_id,b_ma));
else
    b_kq:=to_char(FBH_PTN_TXTn(b_ma_dvi,b_so_id,b_ma));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_PTN:loi'; end if;
end;
/
create or replace procedure PBH_KE_CTI_NG(
    b_ma varchar2,b_loai varchar2,b_ma_dvi varchar2,b_so_id number,b_kq out varchar2,b_loi out varchar2)
AS
    b_txt nvarchar2(200); b_lenh varchar2(1000); b_n number;
begin
-- Dan - Tra tham so
if b_loai in ('C','H') then
    b_kq:=PKH_MA_TENl(FBH_NG_TXT(b_ma_dvi,b_so_id,b_ma));
else
    b_kq:=to_char(FBH_NG_TXTn(b_ma_dvi,b_so_id,b_ma));
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_KE_CTI_NG:loi'; end if;
end;
/
