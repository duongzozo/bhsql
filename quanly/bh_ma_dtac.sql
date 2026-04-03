-- Doi tac --
create or replace function FBH_DTAC_MA_KTHAC(b_ma varchar2,b_ma_dviX varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ma_dviC varchar2(10);
begin
-- Dan - Tra ten
select count(*),nvl(min(ma_dviC),' ') into b_i1,b_ma_dviC from bh_dtac_ma_kthac
--Nam: bo check ma_dviC<>' '
	where ma=b_ma and ma_dviX=b_ma_dviX;
if b_i1<>0 then
	if b_ma_dviC<>' ' then b_kq:='C'; else b_kq:='D'; end if;
end if;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_DVI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ten
select nvl(min(ma_dvi),' ') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAC_MA_NSD(b_ma varchar2,b_ma_dvi out varchar2,b_nsd out varchar2)
AS
    b_kq varchar2(20);
begin
-- Dan - Tra don vi, nsd tao ma
select nvl(min(ma_dvi),' '),nvl(min(nsd),' ') into b_ma_dvi,b_nsd from bh_dtac_ma where ma=b_ma;
end;
/
create or replace function FBH_DTAC_MA_NSD(b_ma_dvi varchar2,b_nsd varchar2,b_ma_kh varchar2) return varchar2
AS
    b_loi varchar2(100):=''; b_i1 number; b_ma_dviT varchar2(10); b_nsdT varchar2(20); b_q varchar2(1);
begin
b_q:=FBH_DTAC_MA_KTHAC(b_ma_kh,b_ma_dvi);
if b_q='C' then return ''; end if;
PBH_DTAC_MA_NSD(b_ma_kh,b_ma_dviT,b_nsdT);
if b_ma_dviT not in(' ',b_ma_dvi) then
    select count(*) into b_i1 from bh_hd_goc where ma_kh=b_ma_kh and ma_dvi=b_ma_dvi and ttrang='D';
    if b_i1=0 then
        if b_q='D' then
            b_loi:='loi:Doi duyet quyen khai thac khach hang:loi';
        else
            b_loi:='loi:Khach hang thuoc don vi '||b_ma_dviT||'('||b_nsdT||')'||' khai thac:loi';
        end if;
    end if;
end if;
return b_loi;
end;
/
create or replace function FBH_DTAC_MA_TXT(b_ma varchar2,b_tim varchar2) return varchar2
AS
    b_kq varchar2(500):=''; b_i1 number; b_txt clob;
begin
-- Dan - Tra gtri trong txt
select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
if b_i1=1 then
    select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
    b_kq:=FKH_JS_GTRIs(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_HAN(b_ma varchar2,b_ngayN number:=0) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=b_ngayN;
begin
-- Dan - Kiem tra con dung
if b_ngayN=0 then b_ngay:=PKH_NG_CSO(sysdate); end if;
select count(*) into b_i1 from bh_dtac_ma where ma=b_ma and b_ngay<ngay_kt;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_QLY(b_ma varchar2) return varchar2
AS
    b_kq varchar2(20);
begin
-- Dan - Tra ma cap tren
select nvl(min(ma_ct),' ') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_QLYc(b_ma varchar2) return varchar2
AS
    b_kq varchar2(20):=b_ma; b_ma_ct varchar2(20);
begin
-- Dan - Tra ma cap tren cao nhat
loop
    b_ma_ct:=FBH_DTAC_MA_QLY(b_kq);
    if b_ma_ct<>' ' then b_kq:=b_ma_ct; else exit; end if;
end loop;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ten) into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan - Tra ten
select min(ma||'|'||ten) into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_LOAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan
select nvl(min(loai),' ') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_NHOM(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan
b_kq:=FBH_DTAC_MA_TXT(b_ma,'nhom');
return nvl(trim(b_kq),'T');
end;
/
create or replace function FBH_DTAC_MA_THUE(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan
select nvl(min(c_thue),'C') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_NGHE(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan
select nvl(min(nghe),' ') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_NGHEl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_nghe varchar2(10);
begin
-- Dan - Tra ten nghe
b_nghe:=FBH_DTAC_MA_NGHE(b_ma);
if trim(b_nghe) is not null then
    if FBH_DTAC_MA_LOAI(b_ma)='C' then
        b_kq:=FBH_MA_NGHE_TENl(b_nghe);
    else
        b_kq:=FBH_MA_LVUC_TENl(b_nghe);
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_DTAC_MA_GIOI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):=' ';
begin
-- Dan
select nvl(min(gioi),' ') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
exception when others then return ' ';
end;
/
create or replace function FBH_DTAC_MA_NG_SINH(b_ma varchar2) return number
AS
    b_kq number:=0;
begin
-- Dan
select nvl(min(ng_sinh),0) into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
exception when others then return 0;
end;
/
create or replace function FBH_DTAC_MA_CMT(b_ma varchar2) return varchar2
AS
    b_kq varchar2(20):=' ';
begin
-- Dan
select nvl(min(cmt),' ') into b_kq from bh_dtac_ma where ma=b_ma;
return b_kq;
exception when others then return ' ';
end;
/
create or replace procedure PBH_DTAC_MA_PAS(b_ma varchar2,b_pas varchar2,b_loi out varchar2)
AS
begin
-- Dan - Dat lai pass
b_loi:='loi:Loi dat lai pas:loi';
if trim(b_ma) is null or trim(b_pas) is null then return; end if;
update bh_dtac_ma_pas set pas=b_pas where ma=b_ma;
if sql%rowcount=0 then
    insert into bh_dtac_ma_pas values(b_ma,b_pas);
end if;
b_loi:='';
end; 
/
--duchq update length email
create or replace function FBH_DTAC_MAt(b_cmt varchar2,b_mobi varchar2,b_emailN varchar2) return varchar2
AS
    b_i1 number; b_ma varchar2(20):=''; b_email varchar2(100):=lower(b_emailN);
begin
-- Dan - Tra ma
if trim(b_cmt) is not null  then
    select min(ma) into b_ma from bh_dtac_ma_cmt where cmt=b_cmt;
end if;
if b_ma is null and trim(b_email) is not null then
    select min(ma) into b_ma from bh_dtac_ma_email where email=b_email;
end if;
if b_ma is null and trim(b_mobi) is not null then
    select min(ma),count(*) into b_ma,b_i1 from bh_dtac_ma_mobi where mobi=b_mobi;
    if b_i1>1 then b_ma:=''; end if;
end if;
return b_ma;
end;
/
--duchq update length email
create or replace function FBH_DTAC_MAf(
    b_loai varchar2,b_ten nvarchar2,b_cmt varchar2,b_mobi varchar2,b_emailN varchar2,b_gioi varchar2,b_ng_sinh number) return varchar2
AS
    b_ma varchar2(20):=''; b_i1 number; b_tenL varchar2(100); b_email varchar2(100):=lower(b_emailN);
begin
-- Dan - Tim ma full
b_ma:=FBH_DTAC_MAt(b_cmt,b_mobi,b_emailN);
if b_ma is null and nvl(b_loai,' ')='C' and  trim(b_ten) is not null and trim(b_gioi) is not null and
    b_ng_sinh is not null and b_ng_sinh not in(0,30000101) then
    b_tenL:=FKH_BO_UNICODE(b_ten,'C','C')||to_char(b_ng_sinh)||b_gioi;
    select min(ma) into b_ma from bh_dtac_ma_ten where ten=b_tenL;
end if;
return b_ma;
end;
/
create or replace function FBH_DTAC_MA_DK(
    b_loai varchar2,b_ten nvarchar2,b_cmt varchar2,b_mobi varchar2,b_email varchar2,b_gioi varchar2,b_ng_sinh number) return varchar2
AS
    b_kq varchar2(1):='K'; 
begin
-- Dan - Dieu kien tao ma
if b_loai<>' ' and b_cmt<>' ' or b_mobi<>' ' or b_email<>' ' or (b_loai='C' and b_ten<>' ' and b_gioi<>' ' and b_ng_sinh<>0) then
    b_kq:='C';
end if;
return b_kq;
end;
/
--duchq update length email
create or replace procedure FBH_DTAC_MA_XIN(
    b_loai varchar2,b_ten nvarchar2,b_cmt varchar2,b_mobi varchar2,b_emailN varchar2,
    b_gioi varchar2,b_ng_sinh number,b_ma out varchar2,b_ps out varchar2,b_loi out varchar2)
AS
     b_email varchar2(100):=lower(b_emailN);
begin
-- Dan - Xin ma
b_ma:=FBH_DTAC_MAf(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
if b_ma is not null then
    b_ps:='C';
else
    b_ps:='M';
    PHT_MA_MOI(b_ma,b_loi);
    if b_loi is not null then return; end if;
    if b_ma is null then b_loi:='loi:Khong xin duoc ma:loi'; return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure FBH_DTAC_MA_NHn(
   b_oraIn clob,b_ma in out varchar2,b_loai out varchar2,b_ten out nvarchar2,
   b_cmt out varchar2,b_dchi out nvarchar2,b_mobi out varchar2,b_email out varchar2,
   b_gioi out varchar2,b_ng_sinh out number,b_c_thue out varchar2,b_ma_ct out varchar2,
   b_ngay_kt out number,b_nghe out varchar2,b_nhang out varchar2,b_ma_tk out varchar2,
   b_kvuc out varchar2,b_pas out varchar2,b_loi out varchar2)

AS
    b_i1 number; b_lenh varchar2(1000); b_ngheN nvarchar2(500); b_txt clob:=b_oraIn;
begin
-- Dan - cbi tham so
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('ma,loai,ten,cmt,dchi,mobi,email,gioi,ng_sinh,c_thue,ma_ct,ngay_kt,nghe,nhang,ma_tk,kvuc,pas');
EXECUTE IMMEDIATE b_lenh into b_ma,b_loai,b_ten,b_cmt,b_dchi,b_mobi,b_email,b_gioi,b_ng_sinh,
    b_c_thue,b_ma_ct,b_ngay_kt,b_ngheN,b_nhang,b_ma_tk,b_kvuc,b_pas using b_txt;
--duchq
b_nghe:=PKH_MA_TENl(b_ngheN); b_nghe:=nvl(trim(b_nghe),' ');
if nvl(b_ma,' ')=' ' then b_ma:=' '; end if;
if b_c_thue not in('C','K') then b_c_thue:='C'; end if;
if b_ngay_kt=0 or b_ngay_kt is null then b_ngay_kt:=30000101; end if;
if b_loai not in('C','T') then b_loi:='loi:Sai loai:loi'; return; end if;
if b_ten=' ' then b_loi:='loi:Nhap ten:loi'; return; end if;
-- to chuc moi kiem tra
if b_loai='T' and b_cmt=' ' then
    b_loi:='loi:Nhap ma so thue cho doanh nghiep, so giay phep thanh lap cho HCSN:loi'; return;
end if;
if b_ma_ct<>' ' then
    select count(*) into b_i1 from bh_dtac_ma where ma=b_ma_ct;
    if b_i1=0 then b_loi:='loi:Sai ma cap tren:loi'; return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FBH_DTAC_MA_NHn:loi'; end if;
end;
/
create or replace procedure PBH_DTAC_MA_XOA(b_ma varchar2,b_ps varchar2,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Xoa bao ma
select count(*) into b_i1 from bh_hd_goc where ma_kh=b_ma;
if b_i1<>0 then b_loi:='loi:Khong xoa khach hang da co hop dong:loi'; return; end if;
if b_ps='KH' then
    select count(*) into b_i1 from bh_dl_ma_kh where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma dai ly dang su dung:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_bv where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma benh vien dang su dung:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_gara where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma Gara dang xu dung:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_gdinh where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma giam dinh dang su dung:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_nbh where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma cong ty bao hiem dang su dung:loi'; return; end if;
    select count(*) into b_i1 from bh_ma_nhang where ma=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma ngan hang dang xu dung:loi'; return; end if;
    delete bh_dtac_ma_kthac where ma=b_ma;
    delete bh_hd_ma_kh where ma=b_ma;
end if;
delete bh_dtac_ma_cmt where ma=b_ma;
delete bh_dtac_ma_mobi where ma=b_ma;
delete bh_dtac_ma_email where ma=b_ma;
delete bh_dtac_ma_ten where ma=b_ma;
delete bh_dtac_ma_pas where ma=b_ma;
delete bh_dtac_ma_txt where ma=b_ma;
delete bh_dtac_ma where ma=b_ma;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_DTAC_MA_XOA:loi'; end if;
end;
/
create or replace function FBH_DTAC_MA_DVIq(b_ma_dviN varchar2,b_nsdN varchar2) return varchar2
as
    b_kq varchar2(1):='K'; b_vp varchar2(1);
begin
-- Dan - Tra quyen khai thac
select nvl(min(vp),' ') into b_vp from ht_ma_dvi where ma=b_ma_dviN;
if b_vp='C' or FBH_DTAC_MA_DVI(b_nsdN) in(' ',b_ma_dviN) then b_kq:='C'; end if;
return b_kq;
end;
/
--duchq update do dai cua b_nghe
--update length email
create or replace procedure PBH_DTAC_MA_NHn(
    b_oraIn clob,b_ma in out varchar2,b_ps out varchar2,b_loi out varchar2,b_ma_dviN varchar2:='',b_nsdN varchar2:='')
AS
    b_lenh varchar2(1000); b_i1 number; b_tenH varchar2(500); b_tenL varchar2(100):=' ';
    b_ma_dvi varchar2(10); b_nsd varchar2(20);
    b_loai varchar2(1); b_ten nvarchar2(500);
    b_cmt varchar2(20); b_dchi nvarchar2(500);
    b_mobi varchar2(20);b_email varchar2(100); b_gioi varchar2(1); b_ng_sinh number;
    b_c_thue varchar2(1); b_ma_ct varchar2(20); b_ngay_kt number; b_nghe nvarchar2(500);
    b_nhang varchar2(10); b_ma_tk varchar2(20); b_kvuc varchar2(10); b_pas varchar2(50);
    b_maT varchar2(20); b_vp varchar(1);
    r_hd bh_dtac_ma%rowtype; b_txt clob:=''; b_oraIn_txt clob:='';
begin
-- Dan - Nhap tu khai bao ma
FBH_DTAC_MA_NHn(
    b_oraIn,b_ma,b_loai,b_ten,b_cmt,b_dchi,b_mobi,b_email,b_gioi,b_ng_sinh,
    b_c_thue,b_ma_ct,b_ngay_kt,b_nghe,b_nhang,b_ma_tk,b_kvuc,b_pas,b_loi);
if b_loi is not null then return; end if;
if FBH_DTAC_MA_DK(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh)<>'C' then
    b_loi:='loi:Khong du thong tin tao ma khach hang, doi tac:loi'; return;
end if;
if b_ma=' ' then
    FBH_DTAC_MA_XIN(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh,b_ma,b_ps,b_loi);
    if b_loi is not null then return; end if;
    b_ps:='K'; b_ma_dvi:=nvl(trim(b_ma_dviN),' '); b_nsd:=nvl(trim(b_nsdN),' ');
else
    b_maT:=FBH_DTAC_MAf(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
    if b_maT is not null and b_maT<>b_ma then
        b_loi:='loi:Thong tin trung ma '||b_maT||':loi'; return;
    end if;
    b_ps:='C';
    select ma_dvi,nsd into b_ma_dvi,b_nsd from bh_dtac_ma where ma=b_ma; -- chuclh: neu loi sai ma khai thac thi thay bang maT
end if;
if FBH_DTAC_MA_DVIq(b_ma_dviN,b_nsdN)<>'C' then
    b_loi:='loi:Khong vuot quyen khai thac don vi:loi'; return;
end if;
b_tenH:=FKH_BO_UNICODE(b_ten,'C','C');
if b_loai='C' and b_ng_sinh<>0 and b_gioi<>' ' then b_tenL:=b_tenH||b_ng_sinh||b_gioi; end if;
if b_loai='C' then
    if b_ps='M' then
        if b_mobi<>' ' then
            insert into bh_dtac_ma_mobi values(b_ma,b_mobi,b_tenH);
        end if;
        if b_email<>' ' then
            insert into bh_dtac_ma_email values(b_ma,b_email,b_tenH);
        end if;
        if b_tenL<>' ' then
            insert into bh_dtac_ma_ten values(b_ma,b_tenL);
        end if;
    else
        if b_mobi<>' ' then
            select count(*) into b_i1 from bh_dtac_ma_mobi where ma=b_ma and mobi=b_mobi;
            if b_i1=0 then
                insert into bh_dtac_ma_mobi values(b_ma,b_mobi,b_tenH);
            end if;
        end if;
        if b_email<>' ' then
            select count(*) into b_i1 from bh_dtac_ma_email where ma=b_ma and email=b_email;
            if b_i1=0 then
                insert into bh_dtac_ma_email values(b_ma,b_email,b_tenH);
            end if;
        end if;
        if b_tenL<>' ' then
            select count(*) into b_i1 from bh_dtac_ma_ten where ma=b_ma and ten=b_tenL;
            if b_i1=0 then
                insert into bh_dtac_ma_ten values(b_ma,b_tenL);
            end if;
        end if;
    end if;
end if;
if b_cmt<>' ' then
    if b_ps='M' then
        b_i1:=0;
    else
        select count(*) into b_i1 from bh_dtac_ma_cmt where ma=b_ma and cmt=b_cmt;
    end if;
    if b_i1=0 then
        insert into bh_dtac_ma_cmt values(b_ma,b_cmt,b_tenH);
    end if;
end if;
if b_pas<>' ' then
    update bh_dtac_ma_pas set pas=b_pas where ma=b_ma;
    insert into bh_dtac_ma_pas values(b_ma,b_pas);
end if;
insert into bh_dtac_maL select a.*,b_oraIn,sysdate from bh_dtac_ma a where a.ma=b_ma;
select count(*) into b_i1 from bh_dtac_ma where ma=b_ma;
if b_i1=1 then 
    select *  into r_hd from bh_dtac_ma where ma=b_ma;
    b_ma_dvi:=r_hd.ma_dvi; b_nsd:=r_hd.nsd;
    if b_ng_sinh=0 then b_ng_sinh:=r_hd.ng_sinh; end if;
    if b_gioi=' ' then b_gioi:=r_hd.gioi; end if;
    if b_cmt=' ' then b_cmt:=r_hd.cmt; end if;
    if b_dchi=' ' then b_dchi:=r_hd.dchi; end if;
    if b_mobi=' ' then b_mobi:=r_hd.mobi; end if;
    if b_email=' ' then b_email:=r_hd.email; end if;
    if b_nghe=' ' then b_nghe:=r_hd.nghe; end if;
    if b_c_thue=' ' then b_c_thue:=r_hd.c_thue; end if;
    if b_nhang=' ' then b_nhang:=r_hd.nhang; end if;
    if b_ma_tk=' ' then b_ma_tk:=r_hd.ma_tk; end if;
    if b_kvuc=' ' then b_kvuc:=r_hd.kvuc; end if;
    if b_ma_ct=' ' then b_ma_ct:=r_hd.ma_ct; end if;
    if b_ngay_kt=0 then b_ngay_kt:=r_hd.ngay_kt; end if;
    select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
    if b_i1=1 then
        select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
    end if;
    b_ps:='C';
else
    b_ma_dvi:=nvl(trim(b_ma_dviN),' '); b_nsd:=nvl(trim(b_nsdN),' ');
    if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
end if;
b_loi:='loi:Loi Table BH_HD_MA_KH:loi';
delete bh_dtac_ma_txt where ma=b_ma;
delete bh_dtac_ma where ma=b_ma;
insert into bh_dtac_ma values(b_ma_dvi,b_ma,b_ten,b_ng_sinh,b_gioi,b_cmt,b_dchi,b_mobi,b_email,
    b_loai,b_nghe,b_c_thue,b_nhang,b_ma_tk,b_kvuc,b_ma_ct,b_ngay_kt,b_nsd);
--duchq thay gia tri truong ma vao OraIn truoc khi luu txt
b_oraIn_txt:=b_oraIn;
PKH_JS_THAY(b_oraIn_txt,'ma',b_ma);
insert into bh_dtac_ma_txt values(b_ma,b_oraIn_txt);
delete bh_hd_ma_kh where ma=b_ma;
insert into bh_hd_ma_kh values(b_ma_dvi,b_ma,b_ten,b_ng_sinh,b_gioi,b_cmt,b_dchi,b_mobi,b_email,
    b_loai,b_nghe,b_c_thue,b_nhang,b_ma_tk,b_kvuc,b_ma_ct,b_ngay_kt,b_nsd);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_DTAC_MA_NHn:loi'; end if;
end;
/
create or replace procedure PBH_DTAC_MA_NH(
    b_oraIn clob,b_ma in out varchar2,b_loi out varchar2,b_ma_dvi varchar2:=' ',b_nsd varchar2:=' ')
AS
    b_lenh varchar2(1000); b_i1 number; b_ps varchar2(1):='K';
    b_loai varchar2(1); b_ten nvarchar2(500); b_cmt varchar2(20); b_dchi nvarchar2(500);
    b_mobi varchar2(20); b_email varchar2(100); b_gioi varchar2(1); b_ng_sinh number;
    b_c_thue varchar2(1); b_ma_ct varchar2(20); b_ngay_kt number; b_nghe varchar2(10);
    b_nhang varchar2(10); b_ma_tk varchar2(20); b_kvuc varchar2(10); b_pas varchar2(50);
begin
-- Dan - Nhap tu giao dich
FBH_DTAC_MA_NHn(
    b_oraIn,b_ma,b_loai,b_ten,b_cmt,b_dchi,b_mobi,b_email,b_gioi,b_ng_sinh,
    b_c_thue,b_ma_ct,b_ngay_kt,b_nghe,b_nhang,b_ma_tk,b_kvuc,b_pas,b_loi);
if b_loi is not null then return; end if;
if b_ma=' ' and FBH_DTAC_MA_DK(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh)<>'C' then
    b_ma:='VANGLAI'; b_ps:='K'; b_loi:=''; return;
end if;
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_DTAC_MA_NH:loi'; end if;
end;
/
create or replace function FBH_DTAC_TTIN(b_ma varchar2) return clob
as
    b_kq clob:=''; b_i1 number;
begin
-- Dan - Tra ttin doi tac
if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma where ma=b_ma;
    if b_i1<>0 then
        select json_object(
            ma_dvi,ma,ten,ng_sinh,gioi,cmt,dchi,mobi,email,loai,nghe,c_thue,
            nhang,ma_tk,kvuc,ma_ct,nsd returning clob) into b_kq from
            (select ma_dvi,ma,ten,ng_sinh,gioi,cmt,dchi,mobi,email,loai,nghe,c_thue,
            nhang,ma_tk,kvuc,ma_ct,nsd from bh_dtac_ma where ma=b_ma);
    end if;
end if;
return b_kq;
end;
/
--DUCHQ UPDATE
create or replace function FBH_DTAC_TTINf(b_ma varchar2,b_bo varchar2:='C') return clob
as
    b_kq clob:=''; b_i1 number; b_txt clob:='';
begin
-- Dan - Tra ttin doi tac co txt
if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma where ma=b_ma;
    if b_i1<>0 then
        select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
        if b_i1<>0 then
            select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
            if b_bo='C' then PKH_JS_BO(b_txt,'ngay_kt'); end if;
        end if;
        select json_object(
            ma_dvi,ma,ten,ng_sinh,gioi,cmt,dchi,mobi,email,loai,
            'nghe' value FBH_MA_NGHE_TENl(nghe),
            'lvuc' value FBH_MA_LVUC_TENl(nghe),c_thue,
            'nhang' value FBH_MA_NHANG_TENl(nhang),ma_tk,
            'kvuc' value FBH_MA_KVUC_TENl(kvuc),ma_ct,nsd,'txt' value b_txt returning clob) into b_kq from
            (select ma_dvi,ma,ten,ng_sinh,gioi,cmt,dchi,mobi,email,loai,nghe,c_thue,
            nhang,ma_tk,kvuc,ma_ct,nsd from bh_dtac_ma b where ma=b_ma);         
    end if;
end if;
return b_kq;
end;
/
--duchq update length email
create or replace procedure PBH_DTAC_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_loai varchar2(1); b_ten nvarchar2(500); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gioi varchar2(1); b_ng_sinh number; b_ma varchar2(20);
begin
-- Dan - Tra ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('loai,ten,cmt,mobi,email,gioi,ng_sinh');
EXECUTE IMMEDIATE b_lenh into b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh using b_oraIn;
b_ma:=FBH_DTAC_MAf(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duchq update length email
--duong update lay tu txt, ko di long vong
create or replace procedure PBH_DTAC_MAt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_loai varchar2(1); b_ten nvarchar2(500); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gioi varchar2(1); b_ng_sinh number; b_ma varchar2(20);
    cs_ct clob:='';b_i1 number;
begin
-- Dan - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('loai,ten,cmt,mobi,email,gioi,ng_sinh');
EXECUTE IMMEDIATE b_lenh into b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh using b_oraIn;
b_ma:=FBH_DTAC_MAf(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma where ma=b_ma;
    if b_i1<>0 then
        select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
        if b_i1<>0 then
            select txt into cs_ct from bh_dtac_ma_txt where ma=b_ma;
            PKH_JS_BO(cs_ct,'ngay_kt');
        end if;
    end if;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
end;

/
--duchq update length email
create or replace procedure PBH_DTAC_MAf(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_loai varchar2(1); b_ten nvarchar2(500); b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_gioi varchar2(1); b_ng_sinh number; b_ma varchar2(20);
    cs_ct clob:='';
begin
-- Dan - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('loai,ten,cmt,mobi,email,gioi,ng_sinh');
EXECUTE IMMEDIATE b_lenh into b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh using b_oraIn;
b_ma:=FBH_DTAC_MAf(b_loai,b_ten,b_cmt,b_mobi,b_email,b_gioi,b_ng_sinh);
cs_ct:=FBH_DTAC_TTINf(b_ma);
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
--duong update lay tu txt
create or replace procedure PBH_DTAC_MA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:='';b_i1 number;
begin
-- Dan - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;

if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma where ma=b_ma;
    if b_i1<>0 then
        select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
        if b_i1<>0 then
            select txt into cs_ct from bh_dtac_ma_txt where ma=b_ma;
            PKH_JS_BO(cs_ct,'ngay_kt');
        end if;
    end if;
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PBH_DTAC_MA_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_dtac_ma where ma_dvi=b_ma_dvi and b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by upper(ten) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_dtac_ma
        where ma_dvi=b_ma_dvi and b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_dtac_ma where ma_dvi=b_ma_dvi and b_nsd=b_nsd and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by upper(ten) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_dtac_ma
        where ma_dvi=b_ma_dvi and b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_MA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_dtac_ma where ma_dvi=b_ma_dvi and b_nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select ten,row_number() over (order by upper(ten)) sott from bh_dtac_ma
        where ma_dvi=b_ma_dvi and b_nsd=b_nsd order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_dtac_ma
        where ma_dvi=b_ma_dvi and b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_dtac_ma where ma_dvi=b_ma_dvi and b_nsd=b_nsd and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ten,row_number() over (order by upper(ten)) sott from bh_dtac_ma
        where ma_dvi=b_ma_dvi and b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_dtac_ma
        where ma_dvi=b_ma_dvi and b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_MA_KTHAC(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_ngay date:=sysdate; b_q varchar2(1);
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_nv varchar2(10); b_ma_dviT varchar2(10); b_nsdT varchar2(20);
begin
-- Dan - Tra ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_kh,nv');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_nv using b_oraIn;
b_ma_kh:=nvl(trim(b_ma_kh),' ');
if b_ma_kh=' ' then b_loi:='loi:Chon khach hang:loi'; raise PROGRAM_ERROR; end if;
b_ten:=FBH_DTAC_MA_TEN(b_ma_kh);
if b_ten is null then b_loi:='loi:Ma khach hang chua dang ky:loi'; raise PROGRAM_ERROR; end if;
b_q:=FBH_DTAC_MA_KTHAC(b_ma_kh,b_ma_dvi);
b_loi:='loi:Da co quyen khai thac khach hang:loi';
if b_q='C' then raise PROGRAM_ERROR;
elsif b_q='D' then
    b_loi:='loi:Doi duyet quyen khai thac:loi'; raise PROGRAM_ERROR;
end if;
select count(*) into b_i1 from bh_hd_goc where ma_kh=b_ma_kh and ma_dvi=b_ma_dvi and ttrang='D';
if b_i1<>0 then raise PROGRAM_ERROR; end if;
PBH_DTAC_MA_NSD(b_ma_kh,b_ma_dviT,b_nsdT);
if trim(b_ma_dviT) is null then b_loi:='loi:Khong tim duoc don vi quan ly:loi'; raise PROGRAM_ERROR; end if;
insert into bh_dtac_ma_kthac values(b_ma_kh,b_ten,b_ma_dviT,b_ma_dvi,b_nsd,b_nv,b_ngay,' ',' ',b_ngay);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* Ma phan loai doi tac */
create or replace function FBH_DTAC_KHPL_HAN(b_nv varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_dtac_khpl where nv=b_nv and ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace function FBH_DTAC_KHPL_TEN(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_dtac_khpl where nv=b_nv and ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_DTAC_KHPL_TENl(b_nv varchar2,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_dtac_khpl where nv=b_nv and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_DTAC_KHPL_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_nv varchar2(10):=nvl(trim(b_oraIn),' ');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma returning clob) into b_oraOut from bh_dtac_khpl where nv=b_nv;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_KHPL_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_dtac_khpl;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nv,ma,ten) order by nv,ma returning clob) into cs_lke from
    (select nv,ma,ten,row_number() over (order by nv,ma) sott from bh_dtac_khpl order by nv,ma)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_KHPL_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_nv varchar2(10); b_ma varchar2(10); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma,hangkt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_hangkt using b_oraIn;
if b_nv is null or b_ma is null then b_loi:='loi:Nhap Doi tac va ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_dtac_khpl;
select nvl(min(sott),0) into b_tu from (select nv,ma,row_number() over (order by nv,ma) sott from bh_dtac_khpl order by nv,ma)
    where nv>=b_nv and ma>=b_ma;
PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object('nvT' value decode(nv,'KH','Khach hàng','Dai ly'),ma,ten,nv) order by nv,ma returning clob) into cs_lke from
    (select nv,ma,ten,row_number() over (order by nv,ma) sott from bh_dtac_khpl order by nv,ma)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_KHPL_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_nv varchar2(10); b_ma varchar2(10);
    dt_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma using b_oraIn;
if trim(b_nv) is null or trim(b_ma) is null then b_loi:='loi:Nhap doi tac va ma:loi'; raise PROGRAM_ERROR; end if;
select json_object(nv,ma,ten,ngay_kt) into dt_ct from bh_dtac_khpl where nv=b_nv and ma=b_ma;
select json_object('cs_ct' value dt_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_KHPL_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_nv varchar2(10); b_ma varchar2(10); b_ten nvarchar2(500); b_ngay_kt number;
    b_txt clob:=b_oraIn;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('nv,ma,ten,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma,b_ten,b_ngay_kt using b_txt;
if b_nv=' ' or b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap doi tac,ma,ten:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
delete bh_dtac_khpl where nv=b_nv and ma=b_ma;
insert into bh_dtac_khpl values(b_nv,b_ma,b_ten,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DTAC_KHPL_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_nv varchar2(10); b_ma varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ma');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ma using b_oraIn;
if trim(b_nv) is null or trim(b_ma) is null then b_loi:='loi:Nhap doi tac va ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_dtac_khpl where nv=b_nv and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** MA KHACH HANG BAO HIEM ***/
create or replace procedure FBH_MA_KH_PS(b_ma_kh varchar2)
AS
    b_i1 number; b_so_idB number; b_ngay_hl number; b_ngay_kt number;
    b_ngay number:=PKH_NG_CSO(sysdate); b_ttrang varchar2(1); b_no number; b_co number;
begin
-- Dan - Liet ke cac hop dong cua 1 khach hang
insert into temp_1(c1,c2,c3,c4,n11,n12,n1,n10) select ma_dvi,nv,so_hd,ttrang,ngay_hl,ngay_kt,so_id,1
    from bh_hd_goc where ma_kh=b_ma_kh and kieu_hd in('G','T') and ttrang='D';
for r_lp in (select c1 ma_dvi,n1 so_id,n11 ngay_hl,n12 ngay_kt from temp_1) loop
    select count(*) into b_so_idB from bh_hd_goc_hu where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
    if b_so_idB<>0 then
        update temp_1 set c4='H' where c1=r_lp.ma_dvi and n1=r_lp.so_id;
    else
        select nvl(sum(no),0),nvl(sum(co),0) into b_no,b_co from bh_hd_goc_sc_phi where ma_dvi=r_lp.ma_dvi and so_id=r_lp.so_id;
        b_so_idB:=FBH_HD_GOC_SO_HD_B(r_lp.ma_dvi,r_lp.so_id,30000101);
        if b_so_idB<>r_lp.so_id then
            select ngay_hl,ngay_kt into b_ngay_hl,b_ngay_kt from bh_hd_goc where ma_dvi=r_lp.ma_dvi and so_id=b_so_idB;
        else
            b_ngay_hl:=r_lp.ngay_hl; b_ngay_kt:=r_lp.ngay_kt;
        end if;
        if b_ngay_kt<b_ngay then b_ttrang:='K'; else b_ttrang:='D'; end if;
        update temp_1 set c4=b_ttrang,n2=b_no,n3=b_co,n4=b_no-b_co,n11=b_ngay_hl,n12=b_ngay_kt where c1=r_lp.ma_dvi and n1=r_lp.so_id;
    end if;
end loop;
end;
/
create or replace function FBH_HD_MA_KH_TEN(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TEN(b_ma);
end;
/
create or replace function FBH_HD_MA_KH_TENl(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TENl(b_ma);
end;
/
create or replace function FBH_HD_MA_KH_LOAI(b_ma varchar2) return varchar2
AS
    b_kq varchar2(30);
begin
-- Dan
return FBH_DTAC_MA_LOAI(b_ma);
end;
/
create or replace function FBH_HD_MA_KH_NGHE(b_ma varchar2) return varchar2
AS
begin
-- Dan
return FBH_DTAC_MA_NGHE(b_ma);
end;
/
create or replace function FBH_HD_MA_KH_THUE(b_ma varchar2) return varchar2
AS
begin
-- Dan
return FBH_DTAC_MA_THUE(b_ma);
end;
/
create or replace procedure PBH_HD_MA_KH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Xem mot khach hang
PBH_DTAC_MA_CT(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_HD_MA_KH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ps varchar2(1); b_ma varchar2(20);
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_MA_KH_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_ma varchar2(20);
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=nvl(trim(FKH_JS_GTRIs(b_oraIn,'ma')),' ');
if b_ma=' ' then b_loi:='loi:Nhap ma khach hang:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_hd_ma_kh where ma=b_ma and ma_dvi=b_ma_dvi and nsd=b_nsd;
if b_i1=0 then b_loi:='loi:Khong xoa khach hang don vi khac, NSD khac:loi'; raise PROGRAM_ERROR; end if;
PBH_DTAC_MA_XOA(b_ma,'KH',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_MA_KH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Tim ma khach hang
PBH_DTAC_MAf(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_HD_MA_KH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
PBH_DTAC_MA_LKE(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_MA_KH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DTAC_MA_MA(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HD_MA_HD_DVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_tim varchar2(20); cs_lke clob:='';
begin
select JSON_ARRAYAGG(json_object('MA' value ma,'TEN' value ten,'NV' value nv) order by ma returning clob) into cs_lke from hd_ma_hd where ma_dvi = b_ma_dvi;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Ma benh vien ***/
create or replace function FBH_MA_BV_NHOM(b_ma varchar2) return varchar2
as
    b_kq varchar2(1):=''; b_i1 number; b_txt clob;
begin
-- Dan - Tra nhom: B-Benh vien, P-Phong kham
if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
    if b_i1<>0 then
        select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
        b_kq:=FKH_JS_GTRIs(b_txt,'nhom');
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_MA_BV_TEN(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TEN(b_ma);
end;
/
create or replace function FBH_MA_BV_TENl(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TENl(b_ma);
end;
/
create or replace function FBH_MA_BV_THUE(b_ma varchar2) return varchar2
AS
begin
-- Dan
return FBH_DTAC_MA_THUE(b_ma);
end;
/
create or replace procedure PBH_MA_BVJ_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Xem mot khach hang
PBH_DTAC_MA_CT(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_MA_BVJ_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ps varchar2(1); b_ma varchar2(20);
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table BH_MA_BV:loi';
delete bh_ma_bv where ma=b_ma;
insert into bh_ma_bv select * from bh_dtac_ma where ma=b_ma;
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

create or replace procedure PBH_MA_BV_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if FBH_DTAC_MA_DVIq(b_ma_dvi,b_nsd)<>'C' then
    b_loi:='loi:Khong vuot quyen khai thac don vi:loi';
end if;
select count(*) into b_i1 from bh_ma_bv where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_bv where ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_BVJ_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Tim ma khach hang
PBH_DTAC_MAf(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_MA_BVJ_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_bv where b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_bv where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_bv where b_nsd=b_nsd and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_bv
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_BVJ_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_bv where b_nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select ten,row_number() over (order by upper(ten)) sott from bh_ma_bv where b_nsd=b_nsd order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_bv where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_bv where b_nsd=b_nsd and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ten,row_number() over (order by upper(ten)) sott from bh_ma_bv where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_bv
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/*** Gara ***/
create or replace function FBH_MA_GARA_TEN(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TEN(b_ma);
end;
/
create or replace function FBH_MA_GARA_TENl(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TENl(b_ma);
end;
/
create or replace function FBH_MA_GARA_THUE(b_ma varchar2) return varchar2
AS
begin
-- Dan
return FBH_DTAC_MA_THUE(b_ma);
end;
/
create or replace function FBH_MA_GARA_LKET(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - Tra thong tin lien ket
select min(lket) into b_kq from bh_ma_gara_ct where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_GARA_HANG(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K';
begin
-- Dan - Tra thong tin lien ket
select min(hang) into b_kq from bh_ma_gara_ct where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_MA_GARA_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_gara where b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by upper(ten) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gara where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_gara where b_nsd=b_nsd and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by upper(ten) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gara
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GARA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_gara where b_nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select ten,row_number() over (order by upper(ten)) sott from bh_ma_gara where b_nsd=b_nsd order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gara where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_gara where b_nsd=b_nsd and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ten,row_number() over (order by upper(ten)) sott from bh_ma_gara where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gara
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GARA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Xem mot khach hang
PBH_DTAC_MA_CT(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_MA_GARA_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ps varchar2(1); b_ma varchar2(20);
    b_lket varchar2(100); b_hang varchar2(100);
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('lket,hang');
EXECUTE IMMEDIATE b_lenh into b_lket,b_hang using b_oraIn;
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table BH_MA_GARA:loi';
delete bh_ma_gara_ct where ma=b_ma;
delete bh_ma_gara where ma=b_ma;
insert into bh_ma_gara select * from bh_dtac_ma where ma=b_ma;
insert into bh_ma_gara_ct values(b_ma_dvi,b_ma,b_lket,b_hang);
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GARA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if FBH_DTAC_MA_DVIq(b_ma_dvi,b_nsd)<>'C' then
    b_loi:='loi:Khong vuot quyen khai thac don vi:loi';
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_MA_GARA where ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GARA_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Tim ma khach hang
PBH_DTAC_MAf(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
/*** Ma giam dinh ***/
create or replace function FBH_MA_GDINH_KTEN(b_ma_dvi varchar2,b_k_ma_gd varchar2,b_ma_gd varchar2,b_dk varchar2:='K') return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten giam dinh qua kieu=>ten
if b_ma_gd is not null then
    if b_k_ma_gd in('G','D') then b_kq:=FBH_DTAC_MA_TEN(b_ma_gd);
    elsif b_k_ma_gd='C' then b_kq:=FHT_MA_CB_TEN(b_ma_dvi,b_ma_gd);
    end if;
end if;
if b_dk='C' then b_kq:=b_ma_gd||'|'||b_kq; end if;
return b_kq;
end;
/
create or replace function FBH_MA_GDINH_NV(b_ma varchar2,b_tim varchar2) return varchar2
as
    b_kq varchar2(1):='K'; b_i1 number; b_nv varchar2(100); b_txt clob;
begin
-- Dan - Tra nv
if trim(b_ma) is not null then
    select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
    if b_i1<>0 then
        select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
        b_nv:=FKH_JS_GTRIs(b_txt,'nv'); b_kq:=FBH_MA_NV_CO(b_nv,b_tim);
    end if;
end if;
return b_kq;
end;
/
create or replace function FBH_MA_GDINH_TEN(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TEN(b_ma);
end;
/
create or replace function FBH_MA_GDINH_TENl(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TENl(b_ma);
end;
/
create or replace function FBH_MA_GDINH_THUE(b_ma varchar2) return varchar2
AS
begin
-- Dan
return FBH_DTAC_MA_THUE(b_ma);
end;
/
create or replace function FBH_MA_GDINH_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con dung
select count(*) into b_i1 from bh_ma_gdinh where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_GDINH_THUE
    (b_ma varchar2,b_nop out varchar2,b_thau out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000); b_txt clob;
begin
-- Dan - Tra thong tin ve thue
select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
if b_i1<>0 then
    select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
    b_lenh:=FKH_JS_LENH('nop,thau');
    EXECUTE IMMEDIATE b_lenh into b_nop,b_thau using b_txt;
end if;
b_nop:=nvl(trim(b_nop),'K'); b_thau:=nvl(trim(b_thau),'K');
end;
/
create or replace procedure PBH_MA_GDINH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_gdinh where b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gdinh where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_gdinh where b_nsd=b_nsd and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gdinh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GDINH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_gdinh where b_nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select ten,row_number() over (order by upper(ten)) sott from bh_ma_gdinh where b_nsd=b_nsd order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gdinh where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_gdinh where b_nsd=b_nsd and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ten,row_number() over (order by upper(ten)) sott from bh_ma_gdinh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_gdinh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GDINH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Xem mot khach hang
PBH_DTAC_MA_CT(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_MA_GDINH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraInN clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ps varchar2(1); b_ma varchar2(20); b_nv varchar2(100):=' ';
    b_2b varchar2(1); b_xe varchar2(1); b_hang varchar2(1); b_phh varchar2(1);
    b_pkt varchar2(1); b_ptn varchar2(1); b_nguoi varchar2(1); b_tau varchar2(1); b_hop varchar2(1); b_nong varchar2(1);
    b_txt clob;
    b_oraIn clob:=b_oraInN;
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('xm,xe,hang,phh,pkt,ptn,nguoi,tau,hop,nong');
EXECUTE IMMEDIATE b_lenh into b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong using b_oraIn;
b_nv:=FBH_MA_NV_DUNG(b_2b,b_xe,b_hang,b_phh,b_pkt,b_ptn,b_nguoi,b_tau,b_hop,b_nong);
PKH_JS_THAY(b_oraIn,'nv',b_nv);
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table BH_MA_GDINH:loi';
select txt into b_txt from bh_dtac_ma_txt where ma=b_ma; -- viet anh -- them cot txt bh_ma_gdinh
delete bh_ma_gdinh where ma=b_ma;
insert into bh_ma_gdinh select ma_dvi,ma,ten,ng_sinh,gioi,cmt,dchi,mobi,email,loai,nghe,c_thue,nhang,ma_tk,kvuc,ma_ct,ngay_kt,nsd,b_txt 
       from bh_dtac_ma where ma=b_ma;
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GDINH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if FBH_DTAC_MA_DVIq(b_ma_dvi,b_nsd)<>'C' then
    b_loi:='loi:Khong vuot quyen khai thac don vi:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_gdinh where ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GDINH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Tim ma khach hang
PBH_DTAC_MAf(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
/*** Nha bao hiem ***/
create or replace function FBH_MA_NBH_HAN(b_ma varchar2,b_ngay number:=0) return varchar2
AS
begin
-- Dan - Kiem tra con dung
return FBH_DTAC_MA_HAN(b_ma,b_ngay);
end;
/
create or replace function FBH_MA_NBH_TEN(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TEN(b_ma);
end;
/
create or replace function FBH_MA_NBH_TENl(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TENl(b_ma);
end;
/
create or replace function FBH_MA_NBH_THUE(b_ma varchar2) return varchar2
AS
begin
-- Dan
return FBH_DTAC_MA_THUE(b_ma);
end;
/
create or replace procedure PBH_MA_NBH_THUE
    (b_ma varchar2,b_nop out varchar2,b_thau out varchar2)
AS
    b_i1 number; b_lenh varchar2(1000); b_txt clob;
begin
-- Dan - Tra thong tin ve thue
select count(*) into b_i1 from bh_dtac_ma_txt where ma=b_ma;
if b_i1<>0 then
    select txt into b_txt from bh_dtac_ma_txt where ma=b_ma;
    b_lenh:=FKH_JS_LENH('nop,thau');
    EXECUTE IMMEDIATE b_lenh into b_nop,b_thau using b_txt;
end if;
b_nop:=nvl(trim(b_nop),'K'); b_thau:=nvl(trim(b_thau),'K');
end;
/
create or replace procedure PBH_MA_NBH_TBH(b_dk varchar2,b_loi out varchar2)
AS
begin
-- Dan
b_loi:='loi:Loi xu ly PBH_MA_NBH_TBH:loi';
if trim(b_dk)='T' then
    insert into bh_kh_hoi_temp1 select ma,ten from bh_ma_nbh where ma_ct=' ' and nghe<>'G';
else
    insert into bh_kh_hoi_temp1 select ma,ten from bh_ma_nbh where ma_ct=' ';
end if;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PBH_MA_NBH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nbh where b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_nbh where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_nbh where b_nsd=b_nsd and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_nbh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NBH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nbh where b_nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select ten,row_number() over (order by upper(ten)) sott from bh_ma_nbh where b_nsd=b_nsd order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_nbh where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_nbh where b_nsd=b_nsd and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ten,row_number() over (order by upper(ten)) sott from bh_ma_nbh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_ma_nbh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NBH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
    cs_ct clob:=''; b_nghe varchar2(10);
begin
-- Dan - Tra ttin ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
cs_ct:=FBH_DTAC_TTINf(b_ma,'K');
if cs_ct is not null then
    select nvl(min(nghe),'G') into b_nghe from bh_ma_nbh where ma=b_ma;
    PKH_JS_THAY(cs_ct,'nghe',b_nghe);
end if;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NBH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_ps varchar2(1); b_ma varchar2(20);
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table BH_MA_NBH:loi';
delete bh_ma_nbh where ma=b_ma;
delete bh_ma_nbh_txt where ma=b_ma;
insert into bh_ma_nbh select * from bh_dtac_ma where ma=b_ma;
insert into bh_ma_nbh_txt select * from bh_dtac_ma_txt where ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NBH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if FBH_DTAC_MA_DVIq(b_ma_dvi,b_nsd)<>'C' then
    b_loi:='loi:Khong vuot quyen khai thac don vi:loi';
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_ma_nbh where ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NBH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Tim ma khach hang
PBH_DTAC_MAf(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
-- Ma dai ly --
create or replace function FBH_DL_MA_KH_HAN(b_ma varchar2,b_ngay number:=0) return varchar2
AS
begin
-- Dan - Kiem tra con dung
return FBH_DTAC_MA_HAN(b_ma,b_ngay);
end;
/
create or replace function FBH_DL_MA_KH_TEN(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TEN(b_ma);
end;
/
create or replace function FBH_DL_MA_KH_TENl(b_ma varchar2) return nvarchar2
AS
begin
-- Dan - Tra ten
return FBH_DTAC_MA_TENl(b_ma);
end;
/
create or replace function FBH_DL_MA_KH_DVI_QL(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select min(ma_dvi_ql) into b_kq from bh_dl_ma_kh_ct where ma=b_ma;
if b_kq is null then select min(ma_dvi) into b_kq from bh_dl_ma_kh where ma=b_ma; end if;
end;
/
create or replace procedure FBH_DL_MA_KH_DVI_QLf(
    b_ma varchar2,b_ma_dvi_ql out varchar2,b_phong out varchar2,b_ma_cb out varchar2)
AS
begin
-- Dan
select min(ma_dvi_ql),min(phong),min(ma_cb) into b_ma_dvi_ql,b_phong,b_ma_cb from bh_dl_ma_kh_ct where ma=b_ma;
if b_ma_dvi_ql is null then
    select min(ma_dvi) into b_ma_dvi_ql from bh_dl_ma_kh where ma=b_ma;
    b_phong:=' '; b_ma_cb:=' ';
end if;
end;
/
create or replace function FBH_DL_MA_KH_THUE(b_ma varchar2) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan
select min(ma_dvi_ql) into b_kq from bh_dl_ma_kh_ct where ma=b_ma;
return FBH_DTAC_MA_THUE(b_ma);
end;
/
create or replace procedure PBH_DL_MA_KH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
    b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_dl_ma_kh where b_nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott
        from bh_dl_ma_kh where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_dl_ma_kh where b_nsd=b_nsd and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_dl_ma_kh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_ten nvarchar2(100); b_tim nvarchar2(100); b_hangkt number;
    b_trang number:=0; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ten,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ten,b_tim,b_hangkt using b_oraIn;
if b_ten is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_dl_ma_kh where b_nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select ten,row_number() over (order by upper(ten)) sott from bh_dl_ma_kh where b_nsd=b_nsd order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott from bh_dl_ma_kh where b_nsd=b_nsd order by upper(ten))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_dl_ma_kh where b_nsd=b_nsd and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ten,row_number() over (order by upper(ten)) sott from bh_dl_ma_kh
        where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where ten>=b_ten;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma,ten,nsd) returning clob) into cs_lke from
        (select ma,ten,nsd,row_number() over (order by upper(ten)) sott
        from bh_dl_ma_kh where b_nsd=b_nsd and upper(ten) like b_tim order by upper(ten))
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Xem mot khach hang
PBH_DTAC_MA_CT(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_DL_MA_KH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
begin
-- Dan - Tim ma khach hang
PBH_DTAC_MAf(b_ma_dvi,b_nsd,b_pas,b_oraIn,b_oraOut);
end;
/
create or replace procedure PBH_DL_MA_KH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number;
    b_ma varchar2(20):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if FBH_DTAC_MA_DVIq(b_ma_dvi,b_nsd)<>'C' then
    b_loi:='loi:Khong vuot quyen khai thac don vi:loi';
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete bh_dl_ma_kh_lhnv where ma=b_ma;
delete bh_dl_ma_kh_ct where ma=b_ma;
delete bh_dl_ma_kh where ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ps varchar2(1); b_ma varchar2(20);
    b_ma_dvi_ql varchar2(10); b_phong varchar2(10); b_ma_cb varchar2(20);
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi_ql,phong,ma_cb');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi_ql,b_phong,b_ma_cb using b_oraIn;
b_ma_dvi_ql:=nvl(trim(b_ma_dvi_ql),' ');
b_phong:=nvl(trim(b_phong),' '); b_ma_cb:=nvl(trim(b_ma_cb),' ');
PBH_DTAC_MA_NHn(b_oraIn,b_ma,b_ps,b_loi,b_ma_dvi,b_nsd);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table BH_MA_NBH:loi';
delete bh_dl_ma_kh_ct where ma=b_ma;
delete bh_dl_ma_kh where ma=b_ma;
insert into bh_dl_ma_kh select * from bh_dtac_ma where ma=b_ma;
if b_ma_dvi=FBH_DTAC_MA_DVI(b_ma) and b_ma_dvi_ql<>' ' then
    insert into bh_dl_ma_kh_ct values(b_ma,b_ma_dvi_ql,b_phong,b_ma_cb);
end if;
commit;
select json_object('ma' value b_ma) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Dan - Hoa hong dai ly
create or replace procedure FBH_DL_MA_KH_LHNV_QLY(
    b_ma varchar2,b_nv varchar2,b_ngay number,b_maQ out varchar2,b_ngayQ out number) 
AS
begin
-- Dan - Ma quan ly co hoa hong
b_maQ:=b_ma; b_ngayQ:=0;
while b_ngayQ=0 and b_maQ<>'*' loop
    if trim(b_maQ) is null then b_maQ:='*'; end if;
    select nvl(max(ngay),0) into b_ngayQ from bh_dl_ma_kh_lhnv where ma=b_maQ and nv=b_nv and ngay<=b_ngay;
    if b_ngayQ=0 and b_maQ<>'*' then b_maQ:=FBH_DL_MA_KH_QLY(b_maQ); end if;
end loop;
end;
/
create or replace procedure FBH_DL_MA_KH_LHNV_HH(
    b_ma varchar2,b_nv varchar2,b_ngay number,b_lh_nv varchar2,b_hhong out number,b_htro out number,b_dvu out number)
AS
    b_maQ varchar2(20); b_ngayQ number;
begin
-- Dan - Tra ty le hoa hong
FBH_DL_MA_KH_LHNV_QLY(b_ma,b_nv,b_ngay,b_maQ,b_ngayQ);
if b_ngayQ=0 then
    b_hhong:=0; b_htro:=0; b_dvu:=0;
else
    select nvl(max(hhong),0),nvl(max(htro),0),nvl(max(dvu),0) into b_hhong,b_htro,b_dvu
    from bh_dl_ma_kh_lhnv where ma=b_maQ and nv=b_nv and ngay=b_ngayQ and lh_nv=b_lh_nv;
end if;
if b_hhong+b_htro+b_dvu=0 then FBH_MA_LHNV_HHONG(b_lh_nv,b_nv,b_ngay,b_hhong,b_htro,b_dvu); end if;
end;
/
create or replace procedure FBH_DL_MA_KH_LHNV_HHn(
    b_ma varchar2,b_nv varchar2,b_ngay number,a_lh_nv pht_type.a_var,
    a_hhong out pht_type.a_var,a_htro out pht_type.a_var,a_dvu out pht_type.a_var)
AS
    b_maQ varchar2(20); b_ngayQ number;
begin
-- Dan - Tra ty le hoa hong a_lh_nv
FBH_DL_MA_KH_LHNV_QLY(b_ma,b_nv,b_ngay,b_maQ,b_ngayQ);
if b_ngayQ=0 then
    for b_lp in 1..a_lh_nv.count loop
        a_hhong(b_lp):=0; a_htro(b_lp):=0; a_dvu(b_lp):=0;
    end loop;
else
    for b_lp in 1..a_lh_nv.count loop
        select nvl(max(hhong),0),nvl(max(htro),0),nvl(max(dvu),0) into a_hhong(b_lp),a_htro(b_lp),a_dvu(b_lp)
            from bh_dl_ma_kh_lhnv where ma=b_maQ and nv=b_nv and ngay=b_ngayQ and lh_nv=a_lh_nv(b_lp);
    end loop;
end if;
end;
/
create or replace procedure PBH_DL_MA_KH_LHNV_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(20); b_nv varchar2(10); cs_lke clob:='';
begin
-- Dan - Liet ke hoa hong theo nghiep vu,ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,nv');
EXECUTE IMMEDIATE b_lenh into b_ma,b_nv using b_oraIn;
select JSON_ARRAYAGG(json_object(ngay,nsd) order by ngay desc returning clob) into cs_lke from
    (select distinct ngay,nsd from bh_dl_ma_kh_lhnv where ma=b_ma and nv=b_nv);
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_LHNV_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_ma varchar2(20); b_nv varchar2(10); b_ngay number; cs_dk clob;
begin
-- Dan - Liet ke hoa hong theo nghiep vu,ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,nv,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma,b_nv,b_ngay using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma dai ly:loi'; raise PROGRAM_ERROR; end if;
if trim(b_nv) is null then b_loi:='loi:Nhap nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(lh_nv,ten,kthac,bthuong,hhong,hh_q,hh_f,htro,ht_q,ht_f,dvu,dv_q,dv_f) order by lh_nv returning clob) into cs_dk
    from bh_dl_ma_kh_lhnv where ma=b_ma and nv=b_nv and ngay=b_ngay;
select json_object('cs_dk' value cs_dk returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_LHNV_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_dt_ct clob; b_dt_dk clob; b_ma varchar2(20); b_nv varchar2(10); b_ngay number;
    a_lh_nv pht_type.a_var; a_ten pht_type.a_nvar; a_kthac pht_type.a_num; a_bthuong pht_type.a_num; a_hhong pht_type.a_num;
    a_hh_q pht_type.a_num; a_hh_f pht_type.a_num; a_htro pht_type.a_num; a_ht_q pht_type.a_num;
    a_ht_f pht_type.a_num; a_dvu pht_type.a_num; a_dv_q pht_type.a_num; a_dv_f pht_type.a_num;
begin
-- Dan - Nhap ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into b_dt_ct,b_dt_dk using b_oraIn;
b_lenh:=FKH_JS_LENH('ma,nv,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma,b_nv,b_ngay using b_dt_ct;
b_lenh:=FKH_JS_LENH('lh_nv,ten,kthac,bthuong,hhong,hh_q,hh_f,htro,ht_q,ht_f,dvu,dv_q,dv_f');
EXECUTE IMMEDIATE b_lenh bulk collect into a_lh_nv,a_ten,a_kthac,a_bthuong,a_hhong,a_hh_q,a_hh_f,a_htro,a_ht_q,a_ht_f,a_dvu,a_dv_q,a_dv_f using b_dt_dk;
if trim(b_ma) is null then b_loi:='loi:Nhap ma dai ly:loi'; raise PROGRAM_ERROR; end if;
if b_nv is null or b_nv not in('2B','XE','NG','PHH','HANG','TAU','PKT','PTN','HOP','NONG') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay is null or b_ngay in(0,30000101) then b_ngay:=PKH_NG_CSO(sysdate); end if;
if a_lh_nv.count=0 then
    b_loi:='loi:Nhap loai hinh nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
delete bh_dl_ma_kh_lhnv where ma=b_ma and nv=b_nv and ngay=b_ngay;
b_loi:='loi:Loi Table BH_DL_MA_LHNV:loi';
for b_lp in 1..a_lh_nv.count loop
    if trim(a_lh_nv(b_lp)) is not null or a_kthac(b_lp) is not null and a_kthac(b_lp)<>0 then
        if a_hhong(b_lp) is null then a_hhong(b_lp):=0; end if;
        if a_htro(b_lp) is null then a_htro(b_lp):=0; end if;
        if a_dvu(b_lp) is null then a_dvu(b_lp):=0; end if;
        insert into bh_dl_ma_kh_lhnv values(b_ma_dvi,b_ma,b_nv,a_lh_nv(b_lp),a_ten(b_lp),a_kthac(b_lp),a_bthuong(b_lp),a_hhong(b_lp),
            a_hh_q(b_lp),a_hh_f(b_lp),a_htro(b_lp),a_ht_q(b_lp),a_ht_f(b_lp),a_dvu(b_lp),a_dv_q(b_lp),a_dv_f(b_lp),b_ngay,b_nsd);
    end if;
end loop;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_LHNV_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(20); b_nv varchar2(10); b_ngay number;
begin
-- Dan - Xoa ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,nv,ngay');
EXECUTE IMMEDIATE b_lenh into b_ma,b_nv,b_ngay using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma dai ly:loi'; raise PROGRAM_ERROR; end if;
if b_nv is null then b_loi:='loi:Nhap nghiep vu:loi'; raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
delete bh_dl_ma_kh_lhnv where ma=b_ma and nv=b_nv and ngay=b_ngay;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_DL_MA_KH_LIST(b_oraIn varchar2,b_loi out varchar2)
AS
  b_lenh varchar2(1000); b_maN varchar2(20); b_ma_dviN varchar2(20); b_ma varchar2(20); b_phong varchar2(20); b_ma_dvi varchar2(20);
begin
-- chuclh: lay danh sach ma khach hang theo phong ban va nguoi dung. HDAC: 17/11/2023
b_lenh:=FKH_JS_LENH('ma_dvi,ma');
EXECUTE IMMEDIATE b_lenh into b_ma_dviN,b_maN using b_oraIn;
select nvl(ma,' '),ma_dvi into b_ma,b_ma_dvi from ht_ma_nsd where ma=b_maN and ma_dvi=b_ma_dviN;
if b_ma = ' ' then return; end if;
select nvl(phong,' ') into b_phong from ht_ma_cb where ma=b_ma and ma_dvi=b_ma_dvi;
if b_phong = ' ' then return; end if;
insert into bh_kh_hoi_temp1 select t.ma,t.ten from bh_dl_ma_kh t,bh_dl_ma_kh_ct t1 where t.ma=t1.ma and t1.ma_dvi_ql=b_ma_dvi and t1.phong=b_phong order by ten;
b_loi:='';
exception when others then null;
end;
/
--Ma nhang
create or replace function FBH_MA_NHANG_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ten) into b_kq from bh_ma_nhang where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_NHANG_TENl(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(200);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from bh_ma_nhang where ma=b_ma;
return b_kq;
end;
/
create or replace function FBH_MA_NHANG_HAN(b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- Dan - Kiem tra con hieu luc
select count(*) into b_i1 from bh_ma_nhang where ma=b_ma and ngay_kt>b_ngay;
if b_i1<>0 then b_kq:='C'; end if;
return b_kq;
end;
/
create or replace procedure PBH_MA_NHANGJ_LKE(
      b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
      b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number; b_tim nvarchar2(100);
      b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tim,tu,den');
EXECUTE IMMEDIATE b_lenh into b_tim,b_tu,b_den using b_oraIn;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nhang;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep from
            (select * from bh_ma_nhang order by ma) a
            start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_nhang where upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_ma_nhang a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NHANGJ_CT
      (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
      b_loi varchar2(100); b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
      b_cmt varchar2(20); cs_ct clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma da xoa:loi';
select json_object(ma_dvi,ma,ten,cmt,dchi,ma_ct,ngay_kt,nsd) into cs_ct from bh_ma_nhang where ma=b_ma;
select json_object('cs_ct' value cs_ct) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NHANGJ_MA(
      b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
      b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
      b_ma varchar2(10); b_tim nvarchar2(100); b_hangkt number;
      b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,tim,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_tim,b_hangkt using b_oraIn;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from bh_ma_nhang;
    select nvl(min(sott),0) into b_tu from (select ma,ma_ct,rownum sott from
        (select * from bh_ma_nhang order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma=b_ma;
    if b_tu=0 then
        select nvl(min(sott),b_dong) into b_tu from (select ma,ma_ct,rownum sott from
            (select * from bh_ma_nhang order by ma) a start with ma_ct=' ' CONNECT BY prior ma=ma_ct)
        where ma>b_ma;
    end if;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma,ten,nsd,xep) obj,rownum sott from
            (select a.*,rpad(lpad('-',2*(level-1),'-')||ma,20) xep,rownum sott from
                    (select * from bh_ma_nhang order by ma) a
                    start with ma_ct=' ' CONNECT BY prior ma=ma_ct))
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_ma_nhang where upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (
        select ma,rownum sott from bh_ma_nhang where upper(ten) like b_tim order by ma)
        where ma>=b_ma;
    PKH_LKE_VTRI(b_hangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select obj,rownum sott from
            (select ma,ten,json_object(ma,ten,nsd,'xep' value ma) obj from bh_ma_nhang a)
            where upper(ten) like b_tim order by ma)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NHANGJ_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500); b_dchi nvarchar2(500); b_ma_ct varchar2(10); b_ngay_kt number;
    b_cmt varchar2(20);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten,cmt,dchi,ma_ct,ngay_kt');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten,b_cmt,b_dchi,b_ma_ct,b_ngay_kt using b_oraIn;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_cmt) is null then b_loi:='loi:Nhap ma so thue:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is null then
    b_ma_ct:=' ';
else
    b_loi:='loi:Sai ma cap tren:loi';
    if b_ma=b_ma_ct then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from bh_ma_nhang where ma=b_ma_ct;
end if;
if b_ngay_kt=0 then b_ngay_kt:=30000101; end if;
b_loi:='';
delete bh_ma_nhang where ma=b_ma;
insert into bh_ma_nhang values(b_ma_dvi,b_ma,b_ten,b_cmt,b_dchi,b_ma_ct,b_ngay_kt,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_NHANGJ_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from bh_ma_nhang where ma_ct=b_ma;
if b_i1<>0 then
    b_loi:='loi:Khong xoa ma co ma chi tiet:loi'; raise PROGRAM_ERROR;
end if;
delete bh_ma_nhang where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
/* viet anh */
create or replace procedure PBH_MA_TPA_NGSK_LISTt(b_nv varchar2,b_nhom varchar2,b_lay_all varchar2)
AS
    b_ngay number:=PKH_NG_CSO(sysdate);
begin
  -- viet anh
insert into temp_1(c1,c2,c3)
  select '1',ma,ten from bh_ma_gdinh where FBH_MA_GDINH_NV(ma,b_nv)='C' and FBH_MA_GDINH_HAN(ma)='C';
end;
/
create or replace function FHT_MA_DTAC_CMT (b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
    b_cmt varchar2(20);
begin
-- viet anh - cmt DTAC
select nvl(min(cmt),' ') into b_cmt from bh_dtac_ma where ma_dvi=b_ma_dvi and ma=b_ma;
return b_cmt;
end;
/
create or replace procedure PBH_MA_DL_PHONG(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_dvi_ql varchar2(20); cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_dvi_ql:=trim(b_oraIn);
if b_ma_dvi_ql is not null then
    select JSON_ARRAYAGG(json_object(ma,ten) order by ten returning clob) into cs_lke from ht_ma_phong where ma_dvi=b_ma_dvi_ql;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DL_MACB(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_ma_dvi_ql varchar2(20); b_phong varchar2(20); cs_lke clob:='';
begin
-- Nam
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi_ql,phong');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi_ql,b_phong using b_oraIn;
if b_ma_dvi_ql is not null and b_phong is not null then
    select JSON_ARRAYAGG(json_object(ma,'ten' value ten) order by ma) into cs_lke from ht_ma_cb where ma_dvi=b_ma_dvi_ql and phong=b_phong;
end if;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_GDINH_PT_PHI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_tpa varchar2(20); b_pt_phi number;
    b_loi varchar2(1000); b_lenh varchar2(1000);
begin
-- viet anh -- lay % phi TPA
b_loi:='loi:Loi PBH_MA_GDINH_PT_PHI:loi';
b_lenh:=FKH_JS_LENH('tpa');
EXECUTE IMMEDIATE b_lenh into b_tpa using b_oraIn;
if b_tpa is not null then
    select FKH_JS_GTRIs(FKH_JS_BONH(txt),'pt_phi') into b_pt_phi from bh_ma_gdinh where ma=b_tpa;
end if;
b_loi:='';
select json_object('pt_phi' value b_pt_phi) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_MA_DL_PHONG_LIST(b_ma_dvi_ql varchar2,b_loi out varchar2)
AS
begin
-- viet anh
b_loi:='loi:Loi xu ly PBH_MA_DL_PHONG_LIST:loi';
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_phong where ma_dvi=b_ma_dvi_ql order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace function FBH_DL_MA_KH_PHONG(b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
	b_kq varchar2(10);
begin
-- Dan - Tra phong quan ly dai ly
--LAM SACH
-- select min(phong) into b_kq from bh_dl_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
