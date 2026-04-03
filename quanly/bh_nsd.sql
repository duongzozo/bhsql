create or replace Function FBH_MA_NSD_LHNV
    (b_ma_dvi varchar2,b_nsd varchar2,b_loai varchar2,b_nv varchar2,b_ngay_ht number,
    a_ma_dt_n pht_type.a_var,a_lhnv_n pht_type.a_var,a_ma_nt pht_type.a_var,
    a_tien_n pht_type.a_num,a_phi_n pht_type.a_num) return varchar2
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_noite varchar2(5);
    b_tien number; b_phi number; b_kthac number; b_bthuong number; b_pphi number;
    b_tl_kthac number; b_tl_bthuong number; b_tl_pphi number;
    a_ma_dt pht_type.a_var; a_lhnv pht_type.a_var; a_tien pht_type.a_num; a_phi pht_type.a_num;
begin
-- Dan - Kiem tra vuot nguong. Them kiem soat giam phi
if a_lhnv_n.count=0 then return 'K'; end if;
b_noite:='VND';
PKH_MANG_KD(a_lhnv);
for b_lp in 1..a_lhnv_n.count loop
    if a_ma_nt(b_lp)<>b_noite then
        b_tien:=FTT_VND_QD(b_ma_dvi,b_ngay_ht,a_ma_nt(b_lp),a_tien_n(b_lp));
    else
        b_tien:=a_tien_n(b_lp);
    end if;
	b_phi:=a_phi_n(b_lp);
    b_i2:=0;
    for b_lp1 in 1..a_lhnv.count loop
        if a_lhnv(b_lp1)=a_lhnv_n(b_lp) and a_ma_dt(b_lp1)=a_ma_dt_n(b_lp) then b_i2:=b_lp1; exit; end if;
    end loop;
    if b_i2=0 then
        b_i2:=a_lhnv.count+1; a_lhnv(b_i2):=a_lhnv_n(b_lp); a_ma_dt(b_i2):=a_ma_dt_n(b_lp);
        a_tien(b_i2):=b_tien; a_phi(b_i2):=b_phi;
    else
        a_tien(b_i2):=a_tien(b_i2)+b_tien;
		if a_phi(b_i2)>b_phi then a_phi(b_i2):=b_phi; end if;
    end if;
end loop;
for b_lp in 1..a_lhnv.count loop
    if a_tien(b_lp)<>0 or a_phi(b_lp)<>0 then
        select nvl(min(tl_kthac),100),nvl(min(tl_bthuong),100),nvl(min(tl_pphi),100) into b_tl_kthac,b_tl_bthuong,b_tl_pphi
            from bh_ma_nsd_dt where ma_dvi=b_ma_dvi and ma=b_nsd and nv=b_nv and dt=a_ma_dt(b_lp);
        select nvl(min(kthac),0),nvl(min(bthuong),0),nvl(min(pphi),0) into b_kthac,b_bthuong,b_pphi
            from bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_nsd and lhnv=a_lhnv(b_lp);
        if b_tl_kthac>100 then b_kthac:=b_tl_kthac; else b_kthac:=round(b_kthac*b_tl_kthac/100,0); end if;
        if b_tl_bthuong>100 then b_bthuong:=b_tl_bthuong; else b_bthuong:=round(b_bthuong*b_tl_bthuong/100,0); end if;
        if b_tl_pphi<b_pphi then b_pphi:=b_tl_pphi; else b_pphi:=round(b_pphi*b_tl_pphi/100,0); end if;
        if (b_loai='H' and ((b_kthac<>0 and b_kthac<a_tien(b_lp)) or (b_pphi<>0 and b_pphi<a_phi(b_lp)))) or
            (b_loai='B' and b_bthuong<>0 and b_bthuong<a_tien(b_lp)) then return 'C';
        end if;
    end if;
end loop;
return 'K';
exception when others then return 'C';
end;
/
create or replace Function FBH_MA_NSD_LHNV_BTH
    (b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ngay_ht number,
    a_ma_dt_n pht_type.a_var,a_lhnv_n pht_type.a_var,a_ma_nt pht_type.a_var,a_tien_n pht_type.a_num) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_i2 number; b_noite varchar2(5):='VND';
    b_tien number; b_bthuong number; b_tl_bthuong number;
    a_ma_dt pht_type.a_var; a_lhnv pht_type.a_var; a_tien pht_type.a_num;
begin
-- Dan - Kiem tra vuot nguong. Them kiem soat giam phi
if a_lhnv_n.count=0 then return b_kq; end if;
PKH_MANG_KD(a_lhnv);
for b_lp in 1..a_lhnv_n.count loop
    if a_ma_nt(b_lp)<>b_noite then
        b_tien:=FTT_VND_QD(b_ma_dvi,b_ngay_ht,a_ma_nt(b_lp),a_tien_n(b_lp));
    else
        b_tien:=a_tien_n(b_lp);
    end if;
    b_i2:=0;
    for b_lp1 in 1..a_lhnv.count loop
        if a_lhnv(b_lp1)=a_lhnv_n(b_lp) and a_ma_dt(b_lp1)=a_ma_dt_n(b_lp) then b_i2:=b_lp1; exit; end if;
    end loop;
    if b_i2=0 then
        b_i2:=a_lhnv.count+1; a_lhnv(b_i2):=a_lhnv_n(b_lp); a_ma_dt(b_i2):=a_ma_dt_n(b_lp); a_tien(b_i2):=b_tien;
    else
        a_tien(b_i2):=a_tien(b_i2)+b_tien;
    end if;
end loop;
for b_lp in 1..a_lhnv.count loop
    if a_tien(b_lp)<>0 then
        select nvl(min(tl_bthuong),100) into b_tl_bthuong from bh_ma_nsd_dt where
            ma_dvi=b_ma_dvi and ma=b_nsd and nv=b_nv and dt=a_ma_dt(b_lp);
        select nvl(min(bthuong),0) into b_bthuong from bh_ma_nsd_lhnv where
            ma_dvi=b_ma_dvi and ma=b_nsd and lhnv=a_lhnv(b_lp);
        if b_tl_bthuong>100 then b_bthuong:=b_tl_bthuong; else b_bthuong:=round(b_bthuong*b_tl_bthuong/100,0); end if;
        if b_bthuong<>0 and b_bthuong<a_tien(b_lp) then
            b_kq:='C'; exit;
        end if;
    end if;
end loop;
return b_kq;
exception when others then return 'C';
end;
/
create or replace function FBH_MA_NSD_GIA(b_ma_dvi varchar2,b_ma varchar2) return number
AS
    b_kq number;
begin
select nvl(min(gia),0) into b_kq from bh_ma_nsd_gia where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_NSD_HOAN(b_ma_dvi varchar2,b_ma varchar2) return number
AS
    b_kq number;
begin
select nvl(min(hoan),0) into b_kq from bh_ma_nsd_gia where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_NSD_DT(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,
    b_lh_nv varchar2,b_ma_nt varchar2) return varchar2
AS
    b_nv varchar2(5); b_kq varchar2(50);
begin
b_nv:=FBH_HD_NV(b_ma_dvi,b_so_id);
-- if b_nv='XE' then
--     select muc_rr into b_kq from bh_xegcn where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
-- elsif b_nv='XEL' then
--     select muc_rr into b_kq from bh_xelgcn where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='2BL' then
--     select loai_xe into b_kq from bh_2blgcn where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='HANG' then
--     select ma_nhom into b_kq from bh_hhgcn where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='NG' then
--     b_kq:='';
-- elsif b_nv='TAU' then
--     select muc_rr into b_kq from bh_taugcn where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
-- elsif b_nv='TAUL' then
--     select muc_rr into b_kq from bh_taulgcn where ma_dvi=b_ma_dvi and so_id=b_so_id;
-- elsif b_nv='PHH' then
--     select ma_dt into b_kq from bh_phhgcn_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
-- elsif b_nv='PKT' then
--     select min(ma_dt) into b_kq from bh_pktgcn_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt
--         and lh_nv=b_lh_nv and nt_tien=b_ma_nt;
-- elsif b_nv='PTN' then
--     b_kq:='';
-- end if;
return b_kq;
end;
/
create or replace function FBH_MA_NSD_DT_TEN(b_ma_dvi varchar2,b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
if b_nv='XE' then
    select min(ten) into b_kq from bh_xe_rr where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='2B' then
    select min(ten) into b_kq from bh_2b_loai where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='HANG' then
    select min(ten) into b_kq from bh_hh_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='NG' then
    select min(ten) into b_kq from bh_nguoi_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='TAU' then
    select min(ten) into b_kq from bh_tau_rr where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='PHH' then
    select min(ten) into b_kq from bh_phh_dtuong where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='PKT' then
    select min(ten) into b_kq from bh_pkt_dtuong where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_NSD_NV
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke lhnv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','ND','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select ma lhnv,ten,'' kthac,'' bthuong,'' chon from bh_ma_lhnv where ma_dvi=b_ma_dvi and tc='C' order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NSD_DT(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke doi tuong theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','ND','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nv='XE' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_xe_rr where ma_dvi=b_ma_dvi order by ma;
elsif b_nv='2B' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_2b_loai where ma_dvi=b_ma_dvi order by ma;
elsif b_nv='HANG' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_hh_ma_nhom where ma_dvi=b_ma_dvi order by ma;
elsif b_nv='NG' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_nguoi_nhom where ma_dvi=b_ma_dvi order by ma;
elsif b_nv='TAU' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_tau_rr where ma_dvi=b_ma_dvi order by ma;
elsif b_nv='PHH' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_phh_dtuong where ma_dvi=b_ma_dvi order by ma;
elsif b_nv='PKT' then
    open cs1 for select b_nv nv,ma dt,ten,0 tl_kthac,0 tl_bthuong,0 tl_pphi,'' chon from bh_pkt_dtuong where ma_dvi=b_ma_dvi order by ma;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NSD_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
	b_gia out number,b_hoan out number,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','ND','X');
if b_loi is not null then  raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select a.*,b.ten from bh_ma_nsd_lhnv a,bh_ma_lhnv b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi=b_ma_dvi and b.ma=a.lhnv order by a.lhnv;
open cs2 for select a.*,FBH_MA_NSD_DT_TEN(b_ma_dvi,nv,dt) ten from bh_ma_nsd_dt a where ma_dvi=b_ma_dvi and ma=b_ma order by nv,dt;
select nvl(min(gia),0),nvl(min(hoan),0) into b_gia,b_hoan from bh_ma_nsd_gia where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NSD_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_gia number,b_hoan number,
    a_lhnv in out pht_type.a_var,a_kthac pht_type.a_num,a_bthuong pht_type.a_num,a_pphi pht_type.a_num,
    a_nv in out pht_type.a_var,a_dt pht_type.a_var,a_tl_kthac pht_type.a_num,a_tl_bthuong pht_type.a_num,a_tl_pphi pht_type.a_num)
AS
    b_loi varchar2(100); b_i1 number; b_ten nvarchar2(200);
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','ND','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma NSD:loi'; raise PROGRAM_ERROR; end if;
if b_gia is null then b_loi:='loi:Nhap muc duyet phuong an gia:loi'; raise PROGRAM_ERROR; end if;
if b_hoan is null then b_loi:='loi:Nhap muc chuyen tien tu dong:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma NSD chua dang ky:loi';
select 0 into b_i1 from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_ma;
PKH_MANG(a_lhnv);
for b_lp in 1..a_lhnv.count loop
    b_loi:='loi:Loi chi tiet dong '||to_char(b_lp)||':loi';
    if a_lhnv(b_lp) is null or a_kthac(b_lp) is null or a_bthuong(b_lp) is null
        or (a_kthac(b_lp)=0 and a_bthuong(b_lp)=0) or a_pphi(b_lp) is null then raise PROGRAM_ERROR; end if;
    b_loi:='loi:Chua dang ky ma '||a_lhnv(b_lp)||':loi';
    select 0 into b_i1 from bh_ma_lhnv where ma_dvi=b_ma_dvi and ma=a_lhnv(b_lp);
end loop;
PKH_MANG(a_nv);
for b_lp in 1..a_nv.count loop
    b_loi:='loi:Loi doi tuong dong '||to_char(b_lp)||':loi';
    if a_dt(b_lp) is null or a_tl_kthac(b_lp) is null or a_tl_bthuong(b_lp) is null
        or (a_tl_kthac(b_lp)=0 and a_tl_bthuong(b_lp)=0) or a_tl_pphi(b_lp) is null then raise PROGRAM_ERROR;
    end if;
    b_loi:=FBH_MA_NSD_DT_TEN(b_ma_dvi,a_nv(b_lp),a_dt(b_lp));
    if b_loi is null then b_loi:='loi:Chua dang ky ma '||a_dt(b_lp)||':loi'; raise PROGRAM_ERROR; end if;
end loop;
delete bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_ma;
delete bh_ma_nsd_dt where ma_dvi=b_ma_dvi and ma=b_ma;
delete bh_ma_nsd_gia where ma_dvi=b_ma_dvi and ma=b_ma;
for b_lp in 1..a_lhnv.count loop
    insert into bh_ma_nsd_lhnv values(b_ma_dvi,b_ma,a_lhnv(b_lp),'VND',a_kthac(b_lp),'VND',a_bthuong(b_lp),a_pphi(b_lp),b_nsd);
end loop;
for b_lp in 1..a_nv.count loop
    insert into bh_ma_nsd_dt values(b_ma_dvi,b_ma,a_nv(b_lp),a_dt(b_lp),a_tl_kthac(b_lp),a_tl_bthuong(b_lp),a_tl_pphi(b_lp),b_nsd);
end loop;
insert into bh_ma_nsd_gia values(b_ma_dvi,b_ma,b_gia,b_hoan,b_nsd);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NSD_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','ND','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma NSD:loi'; raise PROGRAM_ERROR; end if;
delete bh_ma_nsd_lhnv where ma_dvi=b_ma_dvi and ma=b_ma;
delete bh_ma_nsd_dt where ma_dvi=b_ma_dvi and ma=b_ma;
delete bh_ma_nsd_gia where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
