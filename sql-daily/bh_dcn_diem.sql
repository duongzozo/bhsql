create or replace function FBH_DCN_DIEM_PS(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number;
begin
-- Da phat sinh
select count(*) into b_i1 from bh_dcn_diem_ps where ma=b_ma;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DCN_DIEM_CO(b_ma varchar2,b_loai varchar2) return number
AS
    b_kq number;
begin
-- Tra so diem con
select nvl(min(so),0) into b_kq from bh_dcn_diem_co where ma=b_ma and loai=b_loai;
return b_kq;
end;
/
create or replace procedure PBH_DCN_DIEM_CO(
    b_ma varchar2,b_loai varchar2,b_so number,b_nd nvarchar2,b_loi out varchar2,b_dk varchar2:='C')
AS
    b_soN number; b_soK number; b_ngay date:=sysdate;
begin
-- Tong hop so cai co
b_loi:='loi:Tong hop so cai co:loi';
b_soN:=FBH_DCN_DIEM_CO(b_ma,b_loai);
b_soK:=b_soN+b_so;
if b_so<0 and b_soK<0 and (b_dk='C' or b_loai='K') then b_loi:='loi:Qua so diem ton:loi'; return; end if;
if b_soN<>0 then
    insert into bh_dcn_diem_coL values(b_ma,b_loai,b_soN,b_ngay);
end if;
if b_soK=0 then
    delete bh_dcn_diem_co where ma=b_ma and loai=b_loai;
elsif b_soN<>0 then
    update bh_dcn_diem_co set so=b_soK where ma=b_ma and loai=b_loai;
else
    insert into bh_dcn_diem_co values(b_ma,b_loai,b_soK);
end if;
insert into bh_dcn_diem_ls values(b_ma,b_loai,b_so,b_nd,b_ngay);
b_loi:='';
end;
/
create or replace procedure PBH_DCN_DIEM_CT(
    b_so_id_hh number,b_ngay_ht number,b_so_id number,b_gcn varchar2,b_ten nvarchar2,
    b_ma varchar2,b_maQ varchar2,b_tien number,b_hhong number,b_htro number,b_dvu number,b_loi out varchar2)
AS
begin
-- Nhap chung tu hoa hong
b_loi:='loi:Loi tong hop diem:loi'; 
insert into bh_dcn_diem_ct values(b_so_id_hh,b_ngay_ht,b_so_id,b_gcn,b_ten,b_ma,b_maQ,b_tien,b_hhong,b_htro,b_dvu);
end;
/
create or replace procedure PBH_DCN_DIEM_DVU(
    b_so_id_hh number,b_ngay_ht number,b_ma varchar2,b_so number,b_loi out varchar2)
AS
begin
-- Nhap diem dich vu
b_loi:='loi:Luu diem dich vu:loi';
insert into bh_dcn_diem_dvu values(b_so_id_hh,b_ngay_ht,b_ma,b_so);
end;
/
create or replace procedure PBH_DCN_DIEM_CD(b_loi out varchar2)
AS
    b_ngayD number; b_ngay_ht number; b_ngayT number; b_d date:=sysdate; b_kt number;
    b_so number; b_cd varchar2(1); b_cdT varchar2(1);
    a_ma pht_type.a_var; a_maX pht_type.a_var; 
begin
-- Dan - Xet chuc danh
b_ngay_ht:=round(PKH_NG_CSO(trunc(sysdate)),-2)+1;
b_ngayD:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngay_ht),-1));
select distinct ma bulk collect into a_maX from bh_dcn_diem_ct where ngay_ht<b_ngay_ht; -- and FBH_DCN_MAl(ma)='D';
select distinct maQ bulk collect into a_ma from bh_dcn_diem_ct where ngay_ht<b_ngay_ht and trim(maQ) is not null; -- and FBH_DCN_MAl(maQ)='D';
b_kt:=a_maX.count;
for b_lp in 1..a_ma.count loop
    b_kt:=b_kt+1; a_maX(b_kt):=a_ma(b_lp);
end loop;
PKH_ARR_DNH(a_maX,a_ma);
delete bh_dcn_ma_cdS where FKH_KHO_THSO(ngay,b_ngay_ht)>3;
for b_lp in 1..a_ma.count loop
    select sum(hhong+htro+dvu) into b_so from bh_dcn_diem_ct where ngay_ht<b_ngay_ht and a_ma(b_lp) in(ma,maQ);
    insert into bh_dcn_ma_cdS values(a_ma(b_lp),b_so,b_ngayD);
    select sum(so) into b_so from bh_dcn_ma_cdS where ma=a_ma(b_lp);
    if b_so>=300000000 then b_cd:='3';
    elsif b_so>=150000000 then b_cd:='2';
    elsif b_so>=60000000 then b_cd:='1';
    else b_cd:='0';
    end if;
    select min(chuc),min(ngay) into b_cdT,b_ngayT from bh_dcn_ma_cd where ma=a_ma(b_lp);
    if b_cdT is null or b_cdT<b_cd or (b_cdT>b_cd and FKH_KHO_THSO(b_ngayT,b_ngayD)>2) then
        if b_cdT is not null then
            insert into bh_dcn_ma_cdL select a.*,b_d from bh_dcn_ma_cd a where ma=a_ma(b_lp);
            delete bh_dcn_ma_cd where ma=a_ma(b_lp);
        end if;
        if b_cd<>'0' then
            insert into bh_dcn_ma_cd values(a_ma(b_lp),b_cd,b_ngayD);
        end if;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DCN_DIEM_DOI(b_loi out varchar2)
AS
    b_ngayD number; b_ngayC number; b_ngay_ht number;
    b_ma_dviQ varchar2(10); b_ma_dvi varchar2(10):=FTBH_DVI_TA();
    b_so_id number; b_dthu number; b_hhong number; b_hso number;
    b_so number; b_soT number; b_soQ number;
    a_maQ pht_type.a_var; a_ma pht_type.a_var;
    a_maP pht_type.a_var; a_maX pht_type.a_var; 
begin
-- Dan - Tong hop cuoi thang diem thuong, doi nhom, tuyen dung
b_ngay_ht:=round(PKH_NG_CSO(trunc(sysdate)),-2)+1;
b_ngayD:=PKH_NG_CSO(add_months(PKH_SO_CDT(b_ngay_ht),-1)); b_ngayC:=b_ngayD+30;
select distinct ma bulk collect into a_ma from bh_dcn_diem_ct where ngay_ht<b_ngay_ht and FBH_DCN_MAt(ma)='C';
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Loi tong hop '||a_ma(b_lp)||':loi';
    b_soT:=0; b_soQ:=0;
    select nvl(sum(so),0) into b_so from bh_dcn_diem_dvu where ma=a_ma(b_lp) and ngay_ht<b_ngay_ht;
    select nvl(sum(tien),0),nvl(sum(hhong+htro),0) into b_dthu,b_hhong
        from bh_dcn_diem_ct where ma=a_ma(b_lp) and ngay_ht<b_ngay_ht;
    if b_dthu>0 and b_hhong>0 then
        b_hso:=FBH_DCN_MA_HSOd(b_ngayD,b_dthu);
        if b_hso<>0 then b_soT:=round(b_hhong*b_hso/100,0); end if;
    end if;
    select nvl(sum(tien),0),nvl(sum(hhong),0) into b_dthu,b_hhong
        from bh_dcn_diem_ct where maQ=a_ma(b_lp) and ngay_ht<b_ngay_ht;
    if b_dthu>0 and b_hhong>0 then
        b_hso:=FBH_DCN_MA_HSOq(b_ngayD,a_ma(b_lp),b_dthu);
        if b_hso<>0 then b_soQ:=round(b_hhong*b_hso/100,0); end if;
    end if;
    b_ma_dviQ:=FBH_DCN_MA_DVI(a_ma(b_lp));
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then return; end if;
    insert into bh_dcn_diem_doi values(b_so_id,b_ngay_ht,a_ma(b_lp),b_so,b_soT,b_soQ,b_ma_dviQ);
    b_dthu:=b_so+b_soT+b_soQ;
    if b_soT<>0 then
        PBH_DCN_DIEM_CO(a_ma(b_lp),'C',b_soT,'Thuong doanh thu',b_loi,'K');
        if b_loi is not null then return; end if;
    end if;
    if b_soQ<>0 then
        PBH_DCN_DIEM_CO(a_ma(b_lp),'C',b_soQ,'Thuong quan ly',b_loi,'K');
        if b_loi is not null then return; end if;
    end if;
    if b_so<>0 then
        PBH_DCN_DIEM_CO(a_ma(b_lp),'C',b_so,'Giam hoan phi',b_loi,'K');
        if b_loi is not null then return; end if;
    end if;
    insert into bh_dcn_diem_dvuL values(0,b_ngayC,a_ma(b_lp),b_dthu);
end loop;
insert into bh_dcn_diem_dvuL select * from bh_dcn_diem_dvu where ngay_ht<b_ngay_ht;
delete bh_dcn_diem_dvu where ngay_ht<b_ngay_ht;
b_so:=FBH_DCN_MA_HSOt(b_ngay_ht);
if b_so<>0 then
    select distinct maQ,ma bulk collect into a_maQ,a_ma from bh_dcn_diem_ct where
		ngay_ht<b_ngay_ht and FBH_DCN_MAt(ma)='C' and FBH_DCN_DIEM_PS(ma)='K';
    PKH_ARR_DNH(a_ma,a_maP); PKH_ARR_DNH(a_maQ,a_maX);
    for b_lp in 1..a_maP.count loop
        insert into bh_dcn_diem_ps values(a_maP(b_lp),b_ngayC);
    end loop;
    for b_lp in 1..a_maX.count loop
        b_soQ:=0;
        for b_lp1 in 1..a_maQ.count loop
            if a_maX(b_lp)=a_maQ(b_lp1) then b_soQ:=b_soQ+1; end if;
        end loop;
        b_dthu:=b_soQ*b_so;
        PBH_DCN_DIEM_CO(a_ma(b_lp),'C',b_dthu,'Thuong tuyen dung',b_loi,'K');
        if b_loi is not null then return; end if;
        insert into bh_dcn_diem_dvuL values(0,b_ngayC,a_ma(b_lp),b_dthu);
    end loop;
end if;
insert into bh_dcn_diem_ctL select * from bh_dcn_diem_ct where ngay_ht<b_ngay_ht;
delete bh_dcn_diem_ct where ngay_ht<b_ngay_ht;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DCN_DIEM_TRA(b_ma varchar2,b_diem number,b_loi out varchar2)
AS
    b_ma_dvi varchar2(30); b_so_id number; b_tien number; b_ngay_ht number:=PKH_NG_CSO(trunc(sysdate));
    r_dcn bh_dcn_ma%rowtype;
begin
-- Dan - Thanh toan diem
if b_diem<=0 then b_loi:='loi:Diem thanh toan phai lon hon 0:loi'; return; end if;
PBH_DCN_DIEM_CO(b_ma,'C',-b_diem,'Thanh toan diem',b_loi);
if b_loi is not null then return; end if;
select * into r_dcn from bh_dcn_ma where ma=b_ma;
b_ma_dvi:=FBH_DCN_MA_DVI(b_ma);
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then return; end if;
PBH_TTA_NH(b_so_id,b_ma_dvi,b_so_id,b_ngay_ht,'HH_DL',' ',' ',' ',r_dcn.ten,' ',
    r_dcn.ma_nh,r_dcn.so_tk,r_dcn.ten_tk,b_tien,'Thanh toan diem','MBD','D',b_loi);
end;
/
create or replace procedure PBH_DCN_DIEM_CHUYEN(
	b_maG varchar2,b_maN varchar2,b_loai varchar2,b_diem number,b_loi out varchar2)
AS
	b_ten nvarchar2(200);
begin
-- Dan - Chuyen diem
if b_diem<=0 then b_loi:='loi:Diem chuyen phai lon hon 0:loi'; return; end if;
select min(ten) into b_ten from bh_dtac_ma where ma=b_maN;
PBH_DCN_DIEM_CO(b_maG,b_loai,-b_diem,'Chuyen diem cho '||b_ten,b_loi);
if b_loi is not null then return; end if;
select min(ten) into b_ten from bh_dtac_ma where ma=b_maG;
PBH_DCN_DIEM_CO(b_maN,b_loai,b_diem,'Nhan diem tu '||b_ten,b_loi,'K');
if b_loi is not null then return; end if;
end;
/
create or replace procedure PBH_DCN_DIEM_DUNG(
    b_ma varchar2,b_diem number,b_nd varchar2,b_coK out number,b_coC out number,b_loi out varchar2)
AS
begin
-- Dan - Dung diem
if b_diem<=0 then b_loi:='loi:Diem tieu dung phai lon hon 0:loi'; return; end if;
b_coK:=FBH_DCN_DIEM_CO(b_ma,'K');
if b_coK<b_diem then b_coC:=FBH_DCN_DIEM_CO(b_ma,'C'); end if;
if b_coK+b_coC<b_diem then b_loi:='loi:Diem tieu dung nhieu hon so diem co:loi'; return; end if;
if b_coK<b_diem then
    b_coC:=b_diem-b_coK;
else
    b_coK:=b_diem; b_coC:=0;
end if;
PBH_DCN_DIEM_CO(b_ma,'K',b_coK,b_nd,b_loi);
if b_loi is not null then return; end if;
if b_coC<>0 then
    PBH_DCN_DIEM_CO(b_ma,'C',b_coC,b_nd,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
end;
/
