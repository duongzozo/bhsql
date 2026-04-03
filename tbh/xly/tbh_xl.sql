/*** XU LY PHAT SINH SO LIEU TAI ***/
create or replace function FTBH_XL_SO_PS(b_kieu varchar2,b_so_id_taG number,b_so_id_taH number,b_pthuc varchar2) return varchar2
AS
    b_kq varchar2(50);
begin
-- Dan - Tra so tai
if b_kieu='C' then 
    select min(so_hd||'/'||b_pthuc) into b_kq from tbh_hd_di where so_id=b_so_id_taH;
    b_kq:=FTBH_SO_GHEP(b_so_id_taG)||'('||b_kq||')';
elsif b_kieu='T' then
    select nvl(min(so_ct),' ') into b_kq from tbh_tm where so_id=b_so_id_taG;
else
    select nvl(min(so_hd),' ') into b_kq from tbh_xol where so_id=b_so_id_taG;
end if;
return b_kq;
end;
/
-- C:tai di co dinh, T:tai di tam thoi, D:Tai di co dinh cua nhan, B:tai di tam thoi cua nhan, V:Nhan co dinh, N:nhan tam thoi
create or replace function FTBH_XL_KI(b_kieu varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra kieu
-- C:tai di co dinh, T:tai di tam thoi, D:Tai di co dinh cua nhan, B:tai di tam thoi cua nhan, V:Nhan co dinh, N:nhan tam thoi, X:Tai phi ty le
if b_kieu in('C','D') then b_kq:='C';
elsif b_kieu in('T','B') then b_kq:='T';
elsif b_kieu='X' then b_kq:='X';
else b_kq:='N';
end if;
return b_kq;
end;
/
create or replace function FTBH_XL_HDT(b_kieu varchar2,b_so_id_ta number) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra so hd tai
if b_kieu='C' then
    b_kq:=FTBH_HD_DI_SO_HD(b_so_id_ta);
elsif b_kieu='T' then
    b_kq:=FTBH_TM_SO_ID(b_so_id_ta);
else
    b_kq:=substr(to_char(b_so_id_ta),3);
end if;
return b_kq;
end;
/
create or replace function FTBH_XL_NT(b_kieu varchar2,b_so_id_ta number,b_goc varchar2) return varchar2
AS
    b_kq varchar2(5):='VND';
begin
-- Dan - Tra ma nguyen te tra
if b_so_id_ta<>0 then
    if b_kieu='C' then
        b_kq:=FTBH_HD_DI_MA_NT(b_so_id_ta);
    elsif b_kieu='T' then
        b_kq:=FTBH_TM_NT_TA(b_so_id_ta);
    elsif b_kieu='X' then
        b_kq:=FTBH_XOL_MA_NT(b_so_id_ta);
    end if;
end if;
return b_kq;
end;
/
create or replace function FTBH_XL_PS(b_so_id number,b_so_id_nv number,b_bt number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra kieu phat sinh:T-Thu,C-Chi
select min(ps) into b_kq from tbh_ps where so_id=b_so_id and so_id_nv=b_so_id_nv and bt=b_bt;
return b_kq;
end;
/
create or replace function FTBH_XL_SO_ID(b_so_ct varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan - Tra so Id qua so ct
if trim(b_so_ct) is not null then
    select nvl(min(so_id_xl),0) into b_kq from tbh_xl where so_ct=b_so_ct;
end if;
return b_kq;
end;
/
create or replace function FTBH_XL_SO_CT(b_so_id number) return varchar2
AS
    b_kq varchar2(20):='';
begin
-- Dan - Tra so ct qua so id
if b_so_id<>0 then
    select min(so_ct) into b_kq from tbh_xl where so_id_xl=b_so_id;
end if;
return b_kq;
end;
/
create or replace PROCEDURE PTBH_XL_TONng(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngxlD number; b_ngxlC number;
begin
-- Dan - Liet ke ton ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(a.ngay_ht),0),nvl(max(a.ngay_ht),0) into b_ngxlD,b_ngxlC
    from tbh_ps a,tbh_ps_ton b where b.so_id=a.so_id and b.bt=a.bt;
select json_object('ngxld' value b_ngxlD,'ngxlc' value b_ngxlC) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TONki(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_ngxlD number; b_ngxlC number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
select JSON_ARRAYAGG(json_object('ma' value ma)) into b_oraOut from
    (select distinct FTBH_XL_KI(a.kieu) ma from tbh_ps a,tbh_ps_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and b.so_id=a.so_id and b.bt=a.bt);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
    create or replace PROCEDURE PTBH_XL_TONnv(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1);
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object('ma' value decode(nv,' ','.',nv))) into b_oraOut from
    (select distinct nv from tbh_ps a,tbh_ps_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and b.so_id=a.so_id and b.bt=a.bt);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TONnbh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1); b_nv varchar2(10);
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nv');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nv using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
if b_nv is null then
    b_loi:='loi:Chon nghiep vu:loi'; raise PROGRAM_ERROR;
elsif b_nv='.' then b_nv:=' ';
end if;
select JSON_ARRAYAGG(json_object('ma' value nha_bh,'ten' value FBH_MA_NBH_TEN(nha_bh))) into b_oraOut from
    (select distinct a.nha_bh from tbh_ps a,tbh_ps_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and a.nv=b_nv and b.so_id=a.so_id and b.bt=a.bt);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TONhdt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1); b_nv varchar2(10); b_nha_bh varchar2(20);
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nv,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nv,b_nha_bh using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
if b_nv is null then
    b_loi:='loi:Chon nghiep vu:loi'; raise PROGRAM_ERROR;
elsif b_nv='.' then b_nv:=' ';
end if;
if b_nha_bh is null then
    b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
end if;
select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_ta_hd),
    'ten' value FTBH_XL_HDT(b_kieu,so_id_ta_hd))) into b_oraOut from
    (select distinct a.so_id_ta_hd from tbh_ps a,tbh_ps_ton b
    where a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and
    a.so_id_ta_hd<>0 and a.nv=b_nv and a.nha_bh=b_nha_bh and b.so_id=a.so_id and b.bt=a.bt);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TONps(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1);
    b_nv varchar2(10); b_nha_bh varchar2(20); b_so_id_taC varchar2(20); b_so_id_ta number;
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nv,nha_bh,so_hd_ta');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nv,b_nha_bh,b_so_id_taC using b_oraIn;
b_so_id_ta:=PKH_LOC_CHU_SO(b_so_id_taC,'F','F');
if b_so_id_ta<>0 then
    select JSON_ARRAYAGG(json_object('ma' value goc)) into b_oraOut from
        (select distinct goc from tbh_ps a,tbh_ps_ton b
        where a.ngay_ht between b_ngxlD and b_ngxlC and a.so_id_ta_hd=b_so_id_ta and b.so_id=a.so_id and b.bt=a.bt);
else
    if b_ngxlD is null or b_ngxlD in(0,30000101) then
        b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
    end if;
    if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
    if b_kieu is null or b_kieu not in('C','T','N','X') then
        b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
    end if;
    if b_nv is null then
        b_loi:='loi:Chon nghiep vu:loi'; raise PROGRAM_ERROR;
    elsif b_nv='.' then b_nv:=' ';
    end if;
    if b_nha_bh is null then
        b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
    end if;
    select JSON_ARRAYAGG(json_object('ma' value goc)) into b_oraOut from
        (select distinct goc from tbh_ps a,tbh_ps_ton b
        where a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and
        a.nv=b_nv and a.nha_bh=b_nha_bh and b.so_id=a.so_id and b.bt=a.bt);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TONnt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1); b_goc varchar2(10);
    b_nv varchar2(10); b_nha_bh varchar2(20); b_so_id_taC varchar2(20); b_so_id_ta number;
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nv,nha_bh,so_hd_ta,goc');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nv,b_nha_bh,b_so_id_taC,b_goc using b_oraIn;
b_so_id_ta:=PKH_LOC_CHU_SO(b_so_id_taC,'F','F');
b_goc:=nvl(trim(b_goc),' ');
if b_so_id_ta<>0 then
    select JSON_ARRAYAGG(json_object('ma' value ma_nt,'ten' value ma_nt)) into b_oraOut from
        (select distinct ma_nt from tbh_ps a,tbh_ps_ton b
        where a.ngay_ht between b_ngxlD and b_ngxlC and a.so_id_ta_hd=b_so_id_ta and
        b_goc in(' ',a.goc) and b.so_id=a.so_id and b.bt=a.bt);
else
    if b_ngxlD is null or b_ngxlD in(0,30000101) then
        b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
    end if;
    if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
    if b_kieu is null or b_kieu not in('C','T','N','X') then
        b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
    end if;
    if b_nv is null then
        b_loi:='loi:Chon nghiep vu:loi'; raise PROGRAM_ERROR;
    elsif b_nv='.' then b_nv:=' ';
    end if;
    if b_nha_bh is null then
        b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
    end if;
    select JSON_ARRAYAGG(json_object('ma' value ma_nt,'ten' value ma_nt)) into b_oraOut from
        (select distinct ma_nt from tbh_ps a,tbh_ps_ton b
        where a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and
        a.nv=b_nv and a.nha_bh=b_nha_bh and b_goc in(' ',a.goc) and b.so_id=a.so_id and b.bt=a.bt);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_txt clob:=b_oraIn;
    b_ngxlD number; b_ngxlC number; b_kieu varchar2(1); b_nv varchar2(10); b_nha_bh varchar2(20);
    b_so_id_ta number; b_goc varchar2(10); b_ma_nt varchar2(5);
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,kieu,nv,nha_bh,so_hd_ta,goc,ma_nt');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_kieu,b_nv,b_nha_bh,b_so_id_ta,b_goc,b_ma_nt using b_oraIn;
if b_ngxlD in(0,30000101) then b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR; end if;
if b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
if b_nv=' ' then
    b_loi:='loi:Chon nghiep vu:loi'; raise PROGRAM_ERROR;
elsif b_nv='.' then b_nv:=' ';
end if;
if b_nha_bh=' ' then b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR; end if;
if b_ma_nt=' ' then b_loi:='loi:Chon loai tien:loi'; raise PROGRAM_ERROR; end if;
b_goc:=nvl(trim(b_goc),' ');
if b_so_id_ta<>0 then
    select JSON_ARRAYAGG(json_object(
        'ngay_ht' value  ngay_ht,'so_ct' value  so_ct,'goc' value  goc,
        'tien' value tien,'thue' value  thue,'hhong' value  hhong,
        'tien_tra' value tien_tra,'thue_tra' value thue_tra,'hhong_tra' value hhong_tra,
        'ma_dvi' value ma_dvi,'so_id' value so_id,'so_id_nv' value so_id_nv,
        'so_id_ta_ps' value so_id_ta_ps,'bt' value bt,'ps' value ps,
        'ma_dvi_hd' value ma_dvi_hd,'so_id_hd' value so_id_hd,'so_id_dt' value so_id_dt)
        order by ngay_ht,so_id returning clob) into b_oraOut from
        (select a.ngay_ht,FTBH_XL_SO_PS(a.kieu,a.so_id_ta_ps,a.so_id_ta_hd,a.pthuc) so_ct,
        a.goc,b.tien,b.thue,b.hhong,b.tien tien_tra,b.thue thue_tra,b.hhong hhong_tra,
        a.ma_dvi,a.so_id,b.so_id_nv,a.so_id_ta_ps,a.bt,a.ps,a.ma_dvi_hd,a.so_id_hd,a.so_id_dt
        from tbh_ps a,tbh_ps_ton b where
        a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and
        a.nv=b_nv and a.nha_bh=b_nha_bh and a.so_id_ta_hd=b_so_id_ta and
        ma_nt=b_ma_nt and b_goc in(' ',a.goc) and b.so_id=a.so_id and b.so_id_nv=a.so_id_nv and b.bt=a.bt);
else
    select JSON_ARRAYAGG(json_object(
        'ngay_ht' value  ngay_ht,'so_ct' value  so_ct,'goc' value  goc,
        'tien' value tien,'thue' value  thue,'hhong' value  hhong,
        'tien_tra' value tien_tra,'thue_tra' value thue_tra,'hhong_tra' value hhong_tra,
        'ma_dvi' value ma_dvi,'so_id' value so_id,'so_id_nv' value so_id_nv,
        'so_id_ta_ps' value so_id_ta_ps,'bt' value bt,'ps' value ps,
        'ma_dvi_hd' value ma_dvi_hd,'so_id_hd' value so_id_hd,'so_id_dt' value so_id_dt)
        order by ngay_ht,so_id returning clob) into b_oraOut from
        (select a.ngay_ht,FTBH_XL_SO_PS(a.kieu,a.so_id_ta_ps,a.so_id_ta_hd,a.pthuc) so_ct,
        a.goc,b.tien,b.thue,b.hhong,b.tien tien_tra,b.thue thue_tra,b.hhong hhong_tra,
        a.ma_dvi,a.so_id,b.so_id_nv,a.so_id_ta_ps,a.bt,a.ps,a.ma_dvi_hd,a.so_id_hd,a.so_id_dt
        from tbh_ps a,tbh_ps_ton b where
        a.ngay_ht between b_ngxlD and b_ngxlC and FTBH_XL_KI(a.kieu)=b_kieu and
        a.nv=b_nv and a.nha_bh=b_nha_bh and a.ma_nt=b_ma_nt and
        b_goc in(' ',a.goc) and b.so_id=a.so_id and b.so_id_nv=a.so_id_nv and b.bt=a.bt);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_TRA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ma_nt varchar2(5); b_nt_tt varchar2(5); b_tien number; b_tra number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_nt,nt_tt,tien');
EXECUTE IMMEDIATE b_lenh into b_ma_nt,b_nt_tt,b_tien using b_oraIn;
b_tra:=FBH_TT_TUNG_QD(30000101,b_ma_nt,b_tien,b_nt_tt);
select json_object('tra' value b_tra) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_XL_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_ct varchar2(20); b_so_id number;
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_ct:=FKH_JS_GTRIs(b_oraIn,'so_ct');
b_so_id:=FTBH_XL_SO_ID(b_so_ct);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id number;
    b_ngayD number; b_ngayC number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_klk,b_tu,b_den using b_oraIn;
b_klk:=' ';
if b_klk='N' then
    select count(*) into b_dong from tbh_xl where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_ct,nsd,so_id_xl) order by so_id_xl desc returning clob) into cs_lke from
            (select so_ct,nsd,so_id_xl,rownum sott from tbh_xl where 
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_xl desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from tbh_xl where ngay_ht between b_ngayD and b_ngayC;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_ct,nsd,so_id_xl) order by so_id_xl desc returning clob) into cs_lke from
            (select so_ct,nsd,so_id_xl,rownum sott from tbh_xl where 
            ngay_ht between b_ngayD and b_ngayC order by so_id_xl desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngayD number; b_ngayC number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','DO','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngayd,ngayc,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngayD,b_ngayC,b_klk,b_trangKt using b_oraIn;
b_klk:=' ';
if b_klk ='N' then
    select count(*) into b_dong from tbh_xl where ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_ct,so_id_xl,rownum sott from tbh_xl where
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_xl desc) where so_id_xl<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_xl,so_ct,nsd) order by so_id_xl desc returning clob) into cs_lke from
        (select so_id_xl,so_ct,nsd,rownum sott from tbh_xl where 
        ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd order by so_id_xl desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_xl where ngay_ht between b_ngayD and b_ngayC;
    select nvl(min(sott),b_dong) into b_tu from (select so_ct,so_id_xl,rownum sott from tbh_xl where
        ngay_ht between b_ngayD and b_ngayC order by so_id_xl desc) where so_id_xl<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_xl,so_ct,nsd) order by so_id_xl desc returning clob) into cs_lke from
        (select so_id_xl,so_ct,nsd,rownum sott from tbh_xl where 
        ngay_ht between b_ngayD and b_ngayC order by so_id_xl desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_id_xl number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
delete temp_1;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id_xl:=FKH_JS_GTRIn(b_oraIn,'so_id_xl');
b_loi:='loi:Xu ly da xoa:loi';
select json_object(so_ct,'nha_bh' value FBH_MA_NBH_TENl(nha_bh),
    'so_hd_ta' value to_char(so_id_ta)||'|'||FTBH_XL_HDT(kieu,so_id_ta))
    into dt_ct from tbh_xl where so_id_xl=b_so_id_xl;
insert into temp_1(n4,n5,n6,n10,n11,n12,n13,c14,n14,n15)
    select tien_tra,thue_tra,hhong_tra,so_id_ps,so_id_nv,bt_ps,so_id_ta_ps,ma_dvi_hd,so_id_hd,so_id_dt
    from tbh_xl_ct where so_id_xl=b_so_id_xl;
update temp_1 set c1=FTBH_XL_PS(n10,n11,n12);
update temp_1 set (n1,n2,n3)=(select nvl(min(tien),0),nvl(min(thue),0),nvl(min(hhong),0)
    from tbh_ps_ton where so_id=n10 and so_id_nv=n11 and bt=n12);
update temp_1 set n1=n1+n4,n2=n2+n5,n3=n3+n6;
select JSON_ARRAYAGG(json_object(
    'tien' value n1,'thue' value n2,'hhong' value n3,'chon' value '',
    'so_id' value n10,'so_id_nv' value n11,'bt' value n12,'so_id_ta_ps' value n13,
    'ps' value c1,'ma_dvi_hd' value c14,'so_id_hd' value n14,'so_id_dt' value n15)
    order by n10 returning clob) into dt_dk from temp_1;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from tbh_xl_txt where so_id_xl=b_so_id_xl;
select json_object('so_id_xl' value b_so_id_xl,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'txt' value dt_txt returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_TEST(
    b_ma_dvi varchar2,b_so_id_xl number,dt_ct clob,dt_dk clob,
    b_ngay_ht out number,b_so_ct out varchar2,b_kieu out varchar2,
    b_nv out varchar2,b_nha_bh out varchar2,b_so_id_ta out number,
    b_ma_nt out varchar2,b_nt_tt out varchar2,b_tien_tt out number,b_tra out number,
    a_so_id out pht_type.a_num,a_so_id_nv out pht_type.a_num,
    a_so_id_ta_ps out pht_type.a_num,a_bt out pht_type.a_num,
    a_ma_dvi_hd out pht_type.a_var,a_so_id_hd out pht_type.a_num,a_so_id_dt out pht_type.a_num,
    a_tien out pht_type.a_num,a_thue out pht_type.a_num,a_hhong out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000); b_tp number:=0; b_ps varchar2(1); b_kieu_ta varchar2(1);
    b_ma_nt_xl varchar2(5); b_nha_bh_xl varchar2(20); b_so_id_taC varchar2(20);
    b_tien number; b_thue number; b_hhong number;

begin
-- Dan - Kiem tra so lieu
b_lenh:=FKH_JS_LENH('ngay_ht,kieu,nv,nha_bh,so_hd_ta,ma_nt,tra');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_kieu,b_nv,b_nha_bh,b_so_id_taC,b_ma_nt,b_tra using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,so_id_nv,so_id_ta_ps,bt,ma_dvi_hd,so_id_hd,so_id_dt,tien_tra');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_so_id_nv,a_so_id_ta_ps,a_bt,
    a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,a_tien using dt_dk;
if b_nv is null then
    b_loi:='loi:Chon nghiep vu:loi'; return;
elsif b_nv='.' then b_nv:=' ';
end if;
b_so_id_ta:=PKH_LOC_CHU_SO(b_so_id_taC,'F','F');
if b_ngay_ht is null or b_kieu is null or b_kieu not in('C','T','N','X') or
    b_nv not in(' ','2B','XE','NG','HANG','PHH','PKT','PTN','TAU','HOP','NONG','GOP') or
    a_so_id.count=0 then b_loi:='loi:Nhap so lieu sai:loi'; return;
end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
b_tra:=0;
for b_lp in 1.. a_so_id.count loop
    b_loi:='loi:Sai so lieu dong '||to_char(b_lp)||':loi';
    if a_tien(b_lp)=0 then return; end if;
    select so_id_ta_hd,nha_bh,ma_nt,ps,kieu into b_i1,b_nha_bh_xl,b_ma_nt_xl,b_ps,b_kieu_ta from tbh_ps
        where so_id=a_so_id(b_lp) and so_id_NV=a_so_id_NV(b_lp) and bt=a_bt(b_lp);
    if b_kieu_ta<>b_kieu then b_loi:='loi:Sai kieu tai dong '||trim(to_char(b_lp))||':loi'; end if;
    if b_nha_bh<>b_nha_bh_xl then
        b_loi:='loi:Sai nha tai dong '||to_char(b_lp)||':loi'; return;
    end if;
    if b_ma_nt is null then
        b_ma_nt:=b_ma_nt_xl;
        if b_ma_nt<>'VND' then b_tp:=2; end if;
    elsif b_ma_nt<>b_ma_nt_xl then
        b_loi:='loi:Sai loai tien dong '||to_char(b_lp)||':loi'; return;
    end if;
    select nvl(min(tien),0),nvl(min(thue),0),nvl(min(hhong),0) into b_tien,b_thue,b_hhong
        from tbh_ps_ton where so_id=a_so_id(b_lp) and so_id_NV=a_so_id_NV(b_lp) and bt=a_bt(b_lp);
    if sign(a_tien(b_lp))<>sign(b_tien) or abs(a_tien(b_lp))>abs(b_tien) then
        b_loi:='loi:Sai tien dong '||to_char(b_lp)||':loi'; return;
    end if;
    if a_tien(b_lp)=b_tien then
        a_thue(b_lp):=b_thue; a_hhong(b_lp):=b_hhong;
    else
        b_i1:=a_tien(b_lp)/b_tien;
        a_thue(b_lp):=round(b_thue*b_i1,b_tp); a_hhong(b_lp):=round(b_hhong*b_i1,b_tp);
    end if;
    b_i1:=a_tien(b_lp)-a_thue(b_lp)-a_hhong(b_lp);
    if b_ps='C' then b_tra:=b_tra+b_i1; else b_tra:=b_tra-b_i1; end if;
end loop;
if trim(b_so_ct) is null then b_so_ct:=substr(trim(to_char(b_so_id_xl)),3); end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XL_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_XL_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_xl number,b_ngay_ht number,b_so_ct varchar2,
    b_kieu varchar2,b_nv varchar2,b_nha_bh varchar2,b_so_id_ta number,b_ma_nt varchar2,b_tra number,b_nt_tt varchar2,b_tien_tt number,
    a_so_id pht_type.a_num,a_so_id_nv pht_type.a_num,a_so_id_ta_ps pht_type.a_num,a_bt pht_type.a_num,
    a_ma_dvi_hd pht_type.a_var,a_so_id_hd pht_type.a_num,a_so_id_dt pht_type.a_num,
    a_tien pht_type.a_num,a_thue pht_type.a_num,a_hhong pht_type.a_num,
    dt_ct clob,dt_dk clob,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; b_tl number; b_tp number:=0; b_ps varchar2(1);
    b_tien number; b_thue number; b_hhong number; b_tienc number; b_thuec number; b_hhongc number;
begin
-- Dan - Nhap
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
b_loi:='loi:Loi Table tbh_xl:loi';
insert into tbh_xl values(b_ma_dvi,b_so_id_xl,b_ngay_ht,b_so_ct,b_kieu,b_nv,b_nha_bh,b_so_id_ta,b_ma_nt,b_tra,b_nsd);
insert into tbh_xl_ton values(b_ma_dvi,b_so_id_xl);
b_loi:='loi:Loi Table tbh_xl_ct:loi';
for b_lp in 1..a_so_id.count loop
    insert into tbh_xl_ct values(b_ma_dvi,b_so_id_xl,b_lp,
        b_ma_dvi,a_so_id(b_lp),a_so_id_nv(b_lp),a_so_id_ta_ps(b_lp),a_bt(b_lp),
        a_ma_dvi_hd(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp),
        a_tien(b_lp),a_thue(b_lp),a_hhong(b_lp));
end loop;
forall b_lp in 1..a_so_id.count
    update tbh_ps set so_id_xl=b_so_id_xl where so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
b_loi:='loi:Loi Table tbh_xl_pbo:loi';
if b_ma_nt<>'VND' then b_tp:=2; end if;
delete tbh_xl_pbo_temp2; delete tbh_xl_pbo_temp3;
b_i3:=0;
for b_lp in 1..a_so_id.count loop
    delete tbh_xl_pbo_temp; delete tbh_xl_pbo_temp1;
    b_hhongc:=a_hhong(b_lp); b_i1:=0; b_i2:=0;
    select nvl(min(tien),0) into b_tien from tbh_ps_ton where
        so_id=a_so_id(b_lp) and so_id_nv=a_so_id_nv(b_lp) and bt=a_bt(b_lp);
    if b_tien<>0 then
        select tien into b_tien from tbh_ps where so_id=a_so_id(b_lp) and so_id_nv=a_so_id_nv(b_lp) and bt=a_bt(b_lp);
        b_tienc:=a_tien(b_lp); b_thuec:=a_thue(b_lp); b_hhongc:=a_hhong(b_lp); b_tl:=b_tienc/b_tien;
        for r_lp in (select * from tbh_ps_pbo where so_id=a_so_id(b_lp) and so_id_nv=a_so_id_nv(b_lp) and bt=a_bt(b_lp)) loop
            b_i3:=b_i3+1; b_tien:=round(b_tl*r_lp.tien,b_tp);
            b_thue:=round(b_tl*r_lp.thue,b_tp); b_hhong:=round(b_tl*r_lp.hhong,b_tp);
            insert into tbh_xl_pbo_temp2 values (
                b_ma_dvi,r_lp.so_id,r_lp.so_id_nv,r_lp.bt,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,
                b_ngay_ht,r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,r_lp.goc,r_lp.ma_ta,r_lp.nha_bh,
                r_lp.pthuc,r_lp.ma_nt,b_tien,b_thue,b_hhong,0,0,0,b_i3);
            b_tienc:=b_tienc-b_tien; b_thuec:=b_thuec-b_thue; b_hhongc:=b_hhongc-b_hhong;
            if abs(b_tien)>b_i2 then b_i2:=abs(b_tien); b_i1:=b_i3;  end if;
        end loop;
        if b_tienc<>0 or b_thuec<>0 or b_hhongc<>0 then
            update tbh_xl_pbo_temp2 set tien=tien+b_tienc,thue=thue+b_thuec,hhong=hhong+b_hhongc where bt=b_i1;
        end if;
    else
        insert into tbh_xl_pbo_temp1 select ma_ta,nha_bh,tien,thue,hhong from tbh_ps_pbo
            where so_id=a_so_id(b_lp) and so_id_nv=a_so_id_nv(b_lp) and bt=a_bt(b_lp);
        insert into tbh_xl_pbo_temp1 select ma_ta,nha_bh,-sum(tien),-sum(thue),-sum(hhong) from tbh_xl_pbo
            where so_id_ps=a_so_id(b_lp) and so_id_nv=a_so_id_nv(b_lp) and bt_ps=a_bt(b_lp) group by ma_ta,nha_bh;
        insert into tbh_xl_pbo_temp select ma_ta,nha_bh,sum(tien),sum(thue),sum(hhong)
            from tbh_xl_pbo_temp1 group by ma_ta,nha_bh;
        for r_lp in (select so_id,so_id_nv,bt,so_id_ta_ps,so_id_ta_hd,ps,kieu,nv,
            loai,goc,b.ma_ta,b.nha_bh,pthuc,ma_nt,b.tien,b.thue,b.hhong
            from tbh_ps a,tbh_xl_pbo_temp b where so_id=a_so_id(b_lp) and so_id_nv=a_so_id_nv(b_lp) and bt=a_bt(b_lp)) loop
            b_i3:=b_i3+1;  b_hhongc:=b_hhongc-r_lp.hhong;
            insert into tbh_xl_pbo_temp2 values(
                b_ma_dvi,r_lp.so_id,r_lp.so_id_nv,r_lp.bt,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,b_ngay_ht,
                r_lp.ps,r_lp.kieu,r_lp.nv,r_lp.loai,r_lp.goc,r_lp.ma_ta,r_lp.nha_bh,r_lp.pthuc,
                r_lp.ma_nt,r_lp.tien,r_lp.thue,r_lp.hhong,0,0,0,b_i3);
            if abs(r_lp.hhong)>b_i2 then b_i1:=b_i3; b_i2:=abs(r_lp.hhong); end if;
        end loop;
        if b_hhongc<>0 then
            update tbh_xl_pbo_temp2 set hhong=hhong+b_hhongc where bt=b_i1;
        end if;
    end if;
end loop;
insert into tbh_xl_pbo select b_ma_dvi,b_so_id_xl,a.* from tbh_xl_pbo_temp2 a;
update tbh_xl_pbo_temp2 set tien_qd=tien,thue_qd=thue,hhong_qd=hhong where ma_nt='ma_nt';
for r_lp in(select distinct ma_nt from tbh_xl_pbo_temp2 where ma_nt<>'ma_nt') loop
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,r_lp.ma_nt);
    update tbh_xl_pbo_temp2 set tien_qd=round(tien*b_i1,0),thue_qd=round(thue*b_i1,0),hhong_qd=round(hhong*b_i1,0)
    where ma_nt=r_lp.ma_nt;
end loop;
insert into tbh_xl_dc_pbo select b_ma_dvi,b_so_id_xl,a.* from tbh_xl_pbo_temp2 a;
update tbh_xl_pbo_temp2 set bt=decode(ps,'C',tien-thue-hhong,thue+hhong-tien);
insert into tbh_xl_pbo_temp3
    select loai,nha_bh,ma_nt,sum(bt),sum(tien),sum(thue),sum(hhong),sum(tien_qd),sum(thue_qd),sum(hhong_qd)
        from tbh_xl_pbo_temp2 group by loai,nha_bh,ma_nt;
--nam: anh huy yeu cau insert = 0 thay vi -1
insert into tbh_xl_dc
    select b_ma_dvi,b_so_id_xl,b_ngay_ht,b_so_ct,b_kieu,loai,nha_bh,nt_tra,tra,
        tien,thue,hhong,tien_qd,thue_qd,hhong_qd,rownum,0,0,sysdate from tbh_xl_pbo_temp3;
insert into tbh_xl_txt values(b_ma_dvi,b_so_id_xl,'dt_ct',dt_ct);
insert into tbh_xl_txt values(b_ma_dvi,b_so_id_xl,'dt_dk',dt_dk);
for b_lp in 1..a_so_id.count loop
    PTBH_TH_TA_PS_TON(b_ma_dvi,a_so_id(b_lp),a_so_id_nv(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XL_NH_NH:loi'; end if;
end;
/
create or replace procedure PTBH_XL_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_xl number,b_loi out varchar2)
AS
    b_i1 number; b_nsdC varchar2(10); b_ngay_ht number;
    a_ma_dvi_ps pht_type.a_var; a_so_id_ps pht_type.a_num; a_so_id_nv pht_type.a_num;
    a_so_id_hd pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Xoa
b_loi:='';
select ngay_ht,nsd into b_ngay_ht,b_nsdC from tbh_xl where so_id_xl=b_so_id_xl;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','TA');
if b_loi is not null then return; end if;
if trim(b_nsdC) is not null and b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
select nvl(max(so_id_dc+so_id_kt),0) into b_i1 from tbh_xl_dc where so_id_xl=b_so_id_xl;
if b_i1>0 then b_loi:='loi:Khong sua, xoa chung tu da Hach toan hoac doi chieu tai:loi'; return; end if;
select distinct ma_dvi_ps,so_id_ps,so_id_nv,so_id_hd,so_id_dt bulk collect into
    a_ma_dvi_ps,a_so_id_ps,a_so_id_nv,a_so_id_hd,a_so_id_dt
    from tbh_xl_ct where so_id_xl=b_so_id_xl;
delete tbh_xl_ton where so_id_xl=b_so_id_xl;
delete tbh_xl_txt where so_id_xl=b_so_id_xl;
delete tbh_xl_dc where so_id_xl=b_so_id_xl;
delete tbh_xl_dc_pbo where so_id_xl=b_so_id_xl;
delete tbh_xl_pbo where so_id_xl=b_so_id_xl;
delete tbh_xl_ct where so_id_xl=b_so_id_xl;
delete tbh_xl where so_id_xl=b_so_id_xl;
update tbh_ps set so_id_xl=0 where so_id_xl=b_so_id_xl;
for b_lp in 1..a_ma_dvi_ps.count loop
    PTBH_TH_TA_PS_TON(a_ma_dvi_ps(b_lp),a_so_id_ps(b_lp),
        a_so_id_nv(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_XL_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_XL_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); dt_ct clob; dt_dk clob;
    b_so_id_xl number; b_ngay_ht number; b_so_ct varchar2(20); b_kieu varchar2(1);
    b_nv varchar2(10); b_nha_bh varchar2(20); b_so_id_ta number; b_ma_nt varchar2(5); b_tra number;
    a_so_id pht_type.a_num; a_so_id_nv pht_type.a_num; a_so_id_ta_ps pht_type.a_num; a_bt pht_type.a_num;
    a_ma_dvi_hd pht_type.a_var; a_so_id_hd pht_type.a_num; a_so_id_dt pht_type.a_num;
    a_tien pht_type.a_num; a_thue pht_type.a_num; a_hhong pht_type.a_num;
begin
-- Dan - Nhap xu ly
delete tbh_xl_pbo_temp; delete tbh_xl_pbo_temp1;
delete tbh_xl_pbo_temp2; delete tbh_xl_pbo_temp3;
if b_comm='C' then
    commit;
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_xl:=FKH_JS_GTRIn(b_oraIn,'so_id_xl');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id_xl>0 then
    PTBH_XL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_xl,b_loi);
else
    PHT_ID_MOI(b_so_id_xl,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_XL_TEST(b_ma_dvi,b_so_id_xl,dt_ct,dt_dk,
    b_ngay_ht,b_so_ct,b_kieu,b_nv,b_nha_bh,b_so_id_ta,b_ma_nt,b_tra,
    a_so_id,a_so_id_nv,a_so_id_ta_ps,a_bt,a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,a_tien,a_thue,a_hhong,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_XL_NH_NH(
    b_ma_dvi,b_nsd,b_so_id_xl,b_ngay_ht,b_so_ct,b_kieu,b_nv,b_nha_bh,b_so_id_ta,b_ma_nt,b_tra,
    a_so_id,a_so_id_nv,a_so_id_ta_ps,a_bt,a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,a_tien,a_thue,a_hhong,
    dt_ct,dt_dk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_xl' value b_so_id_xl,'so_ct' value b_so_ct) into b_oraOut from dual;
delete tbh_xl_pbo_temp; delete tbh_xl_pbo_temp1;
delete tbh_xl_pbo_temp2; delete tbh_xl_pbo_temp3;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id_xl number;
begin
-- Dan - Xoa thanh toan phi
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_xl:=FKH_JS_GTRIn(b_oraIn,'so_id_xl');
if b_so_id_xl is null or b_so_id_xl=0 then
    b_loi:='loi:Chon xoa xu ly:loi'; raise PROGRAM_ERROR;
end if;
PTBH_XL_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_xl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(200); cs_lke clob:='';
    b_nha_bh varchar2(20); b_kieu varchar2(1); b_nv varchar2(10);
    b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36)); b_ngayD number; b_ngayC number;
begin
-- Dan - Tim thanh toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,kieu,nv,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_kieu,b_nv,b_nha_bh using b_oraIn;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if b_ngayD in(0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
b_kieu:=nvl(trim(b_kieu),' '); b_nv:=nvl(trim(b_nv),' '); b_nha_bh:=nvl(trim(b_nha_bh),' ');
--nam: nt_tt => ma_nt, bo cot tien_tt
select JSON_ARRAYAGG(json_object(ngay_ht,so_ct,kieu,nv,ma_nt,so_id_xl,'nha_bh' value FBH_MA_NBH_TEN(nha_bh))
    order by ngay_ht desc,kieu,nv,nha_bh returning clob) into cs_lke from
    (select ngay_ht,so_ct,kieu,nv,nha_bh,ma_nt,so_id_xl,rownum sott from tbh_xl where
    ngay_ht between b_ngayD and b_ngayC and b_kieu in(' ',kieu) and b_nv in(' ',nv) and b_nha_bh in(' ',nha_bh)
    order by ngay_ht desc,kieu,nv,nha_bh)
    where sott<201;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_XL_TD
AS
    b_ma_dvi varchar2(10):=FTBH_DVI_TA();
    b_loi varchar2(1000); dt_ct clob; dt_dk clob;
    b_so_id_xl number; b_ngay_ht number; b_so_ct varchar2(20); b_kieu varchar2(1);
    b_nv varchar2(10); b_nha_bh varchar2(20); b_so_id_ta number; b_ma_nt varchar2(5);
    b_tra number; b_traC varchar2(100); b_nt_tt varchar2(5); b_tien_tt number;
    a_so_id pht_type.a_num; a_so_id_nv pht_type.a_num; a_so_id_ta_ps pht_type.a_num; a_bt pht_type.a_num;
    a_tien pht_type.a_num; a_thue pht_type.a_num; a_hhong pht_type.a_num;
    a_ngay_ht pht_type.a_num; a_nha_bh pht_type.a_var;
    a_ma_dvi_hd pht_type.a_var;a_so_id_hd pht_type.a_num;a_so_id_dt pht_type.a_num;
begin
-- Dan - Tu dong xu ly phat sinh tai
--select distinct a.ngay_ht,a.nha_bh bulk collect into a_ngay_ht,a_nha_bh
--    from tbh_ps a,tbh_ps_ton b where a.so_id=b.so_id order by a.ngay_ht;

select distinct a.ngay_ht,a.nha_bh bulk collect into a_ngay_ht,a_nha_bh
    from tbh_ps a,tbh_ps_ton b where b.so_id=20251126000004 and a.so_id=b.so_id order by a.ngay_ht;

for b_lp in 1..a_ngay_ht.count loop
    for r_lp in (select distinct a.kieu,a.nv,a.ma_nt,a.goc from tbh_ps a,tbh_ps_ton b where
        a.ngay_ht=a_ngay_ht(b_lp) and a.nha_bh=a_nha_bh(b_lp) and
        a.so_id=b.so_id and a.so_id_nv=b.so_id_nv and a.bt=b.bt ) loop
        select JSON_ARRAYAGG(json_object(
            'ngay_ht' value a_ngay_ht(b_lp),'so_ct' value  so_ct,'goc' value r_lp.goc,
            'tien' value tien,'thue' value  thue,'hhong' value  hhong,
            'tien_tra' value tien_tra,'thue_tra' value thue_tra,'hhong_tra' value hhong_tra,
            'ma_dvi' value ma_dvi,'so_id' value so_id,'so_id_nv' value so_id_nv,
            'so_id_ta_ps' value so_id_ta_ps,'bt' value bt,'ps' value ps)
            order by so_id returning clob) into dt_dk from
            (select FTBH_XL_SO_PS(r_lp.kieu,a.so_id_ta_ps,a.so_id_ta_hd,a.pthuc) so_ct,b.tien,b.thue,b.hhong,
            b.tien tien_tra,b.thue thue_tra,b.hhong hhong_tra,a.ma_dvi,a.so_id,b.so_id_nv,a.so_id_ta_ps,a.bt,a.ps
            from tbh_ps a,tbh_ps_ton b where
            a.ngay_ht=a_ngay_ht(b_lp) and a.nha_bh=a_nha_bh(b_lp) and
            a.kieu=r_lp.kieu and a.nv=r_lp.nv and a.ma_nt=r_lp.ma_nt and r_lp.goc in(' ',a.goc) and
            a.so_id=b.so_id and a.so_id_nv=b.so_id_nv and a.bt=b.bt);
        select json_object('ngay_ht' value a_ngay_ht(b_lp),'kieu' value r_lp.kieu,'nv' value r_lp.nv,
            'nha_bh' value a_nha_bh(b_lp),'so_hd_ta' value ' ','nt_tt' value r_lp.ma_nt,
            'ma_nt' value r_lp.ma_nt,'tien_tt' value 0) into dt_ct from dual;

        select json_object('ngay_ht' value 20251206,'kieu' value r_lp.kieu,'nv' value r_lp.nv,
            'nha_bh' value a_nha_bh(b_lp),'so_hd_ta' value ' ','nt_tt' value r_lp.ma_nt,
            'ma_nt' value r_lp.ma_nt,'tien_tt' value 0) into dt_ct from dual;

        b_so_id_xl:=0;
        PTBH_XL_TEST(b_ma_dvi,b_so_id_xl,dt_ct,dt_dk,
            b_ngay_ht,b_so_ct,b_kieu,b_nv,b_nha_bh,b_so_id_ta,b_ma_nt,b_nt_tt,b_tien_tt,b_tra,
            a_so_id,a_so_id_nv,a_so_id_ta_ps,a_bt,a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,a_tien,a_thue,a_hhong,b_loi);
        if b_loi is not null then
            b_loi:='Loi Test : '||to_char(a_ngay_ht(b_lp))||' nha_bh: '||a_nha_bh(b_lp)||' - '||b_loi;
        end if;
        PHT_ID_MOI(b_so_id_xl,b_loi);
        if b_loi is not null then
            b_loi:='Loi xin so ID ngay: '||to_char(a_ngay_ht(b_lp))||' nha_bh: '||a_nha_bh(b_lp)||' - '||b_loi;
            raise PROGRAM_ERROR;
        end if;
        b_so_ct:=substr(to_char(b_so_id_xl),3);
        b_traC:=FKH_SO_Fm(b_tra,2); b_traC:=b_so_ct||'|'||b_traC||'|'||b_traC;
        PKH_JS_THAYa(dt_ct,'so_ct,tra,tien_tt',b_traC,'|');
        PTBH_XL_NH_NH(
            b_ma_dvi,' ',b_so_id_xl,b_ngay_ht,b_so_ct,b_kieu,b_nv,
            b_nha_bh,b_so_id_ta,b_ma_nt,b_tra,b_nt_tt,b_tien_tt,
            a_so_id,a_so_id_nv,a_so_id_ta_ps,a_bt,a_ma_dvi_hd,a_so_id_hd,a_so_id_dt,a_tien,a_thue,a_hhong,
            dt_ct,dt_dk,b_loi);
        if b_loi is not null then
            b_loi:='Loi nhap : '||to_char(a_ngay_ht(b_lp))||' nha_bh: '||a_nha_bh(b_lp)||' - '||b_loi;
            raise PROGRAM_ERROR;
        end if;
        commit;
    end loop;
end loop;
exception when others then
    rollback;
    if b_loi is null then b_loi:='Loi khong xac dinh'; end if;
    insert into kh_job_loi values(0,'PTBH_XL_TD',sysdate,b_loi);
    commit;
end;
/
