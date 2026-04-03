/*** NGUOI HUONG KHAC ***/
create or replace function FBH_BT_HK_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_bt_hk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_hk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function PBH_BT_HK_TEN(b_ma_dvi varchar2,b_so_id number,b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Tra ten ma huong khac
select min(ten) into b_kq from bh_bt_hk_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_BT_HK_TEN_DT(
   b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
   b_loi varchar2(100); b_lenh varchar2(1000); b_dtuong varchar2(1); b_ma_dtuong varchar2(20); b_ten nvarchar2(500);

begin
-- Nam- tra ten theo doi tuong(tau,hang,ptnHang)
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('dtuong,ma_dtuong');
execute immediate b_lenh into b_dtuong,b_ma_dtuong using b_oraIn;
b_dtuong:=nvl(b_dtuong,' '); b_ma_dtuong:=nvl(b_ma_dtuong,' ');
if trim(b_dtuong)='K' then
  select ten into b_ten from bh_hd_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_dtuong;
else
  select ten into b_ten from bh_ma_nhang where ma_dvi=b_ma_dvi and ma=b_ma_dtuong;
end if;
select json_object('ten' value b_ten) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HK_KTRA
    (b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number;
begin
-- Dan - Kiem tra so du
b_loi:='';
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hk_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and sign(ton)<>sign(ton_qd);
if b_i1<>0 then b_loi:='Sai so du nguoi huong khac ngay '||PKH_SO_CNG(b_i1)||':loi'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function PBH_BT_HK_SC_QD
    (b_ma_dvi varchar2,b_so_id varchar2,b_ma varchar2,
    b_ma_nt varchar2,b_ngay_ht number,b_l_ct varchar2,b_tien number) return number
AS
    b_i1 number; b_ton number:=0; b_ton_qd number; b_noite varchar2(5); b_tien_qd number:=b_tien;
begin
-- Dan - Qui doi tien
if b_ma_nt<>'VND' then
    PBH_BT_HK_SC_TON(b_ma_dvi,b_so_id,b_ma,b_ma_nt,b_ngay_ht,b_ton,b_ton_qd);
    if b_l_ct='T' then b_ton:=-b_ton; b_ton_qd:=-b_ton_qd; end if;
    if b_ton=b_tien then b_tien_qd:=b_ton_qd;
    elsif b_ton>b_tien then b_tien_qd:=round((b_tien*b_ton_qd/b_ton),0);
    else
        b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_ma_nt);
        if b_ton>0 then b_tien_qd:=b_ton_qd+round((b_tien-b_ton)*b_i1,0);
        else b_tien_qd:=round(b_tien*b_i1,0);
        end if;
    end if;
end if;
return b_tien_qd;
end;
/
create or replace procedure PBH_BT_HK_SC_TON(
    b_ma_dvi varchar2,b_so_id number,b_ma varchar2,b_ma_nt varchar2,
    b_ngay_ht number,b_ton out number,b_ton_qd out number)
AS
    b_i1 number;
begin
-- Dan - Ton va ton_qd
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_hk_sc where
    ma_dvi=b_ma_dvi and so_id=b_so_id and ma=b_ma and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_i1=0 then
    b_ton:=0; b_ton_qd:=0;
else
    select ton,ton_qd into b_ton,b_ton_qd from bh_bt_hk_sc where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ma=b_ma and ma_nt=b_ma_nt and ngay_ht=b_i1;
end if;
end;
/
create or replace procedure PBH_BT_HK_THOP(
    b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_so_id number,b_ma varchar2,
    b_ma_nt varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_thu number; b_chi number; b_ton number; b_i1 number;
    b_thu_qd number; b_chi_qd number; b_ton_qd number;
begin
-- Dan - Tong hop huong khac
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; b_chi:=0; b_chi_qd:=0;
else b_thu:=0; b_thu_qd:=0; b_chi:=b_tien; b_chi_qd:=b_tien_qd;
end if;
PBH_BT_HK_SC_TON(b_ma_dvi,b_so_id,b_ma,b_ma_nt,b_ngay_ht-1,b_ton,b_ton_qd);
update bh_bt_hk_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd
    where ma_dvi=b_ma_dvi and so_id=b_so_id and ma=b_ma and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_bt_hk_sc values(b_ma_dvi,b_so_id,b_ma,b_ma_nt,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_bt_hk_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and
    ma=b_ma and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 then
        delete bh_bt_hk_sc where ma_dvi=b_ma_dvi and ma_dvi=b_ma_dvi and
            so_id=b_so_id and ma=b_ma and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update bh_bt_hk_sc set ton=b_ton,ton_qd=b_ton_qd where ma_dvi=b_ma_dvi and
            so_id=b_so_id and ma=b_ma and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_HK_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(2000);
    b_so_hs varchar2(30); b_so_pa varchar2(20); b_ma_nt varchar2(5); b_l_ct varchar2(1);
    b_so_id_bt number; b_so_id_pa number; b_so_idX number; b_tp number:=0; b_txt clob:=b_oraIn;
    b_ton number; b_tien number; b_thue number; b_ttoan number;
begin
-- Dan - Liet ke ton
delete bh_bt_hk_ton_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt); b_oraOut:='';
b_lenh:=FKH_JS_LENH('so_hs,so_pa,l_ct,ma_nt');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_so_pa,b_l_ct,b_ma_nt using b_txt;
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; raise PROGRAM_ERROR; end if;
b_so_id_bt:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
if b_so_id_bt=0 then b_loi:='loi:Ho so boi thuong chua nhap hoac da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_so_pa=' ' then
    b_so_idX:=b_so_id_bt;
else
    select nvl(min(so_id),0),min(so_id_bt) into b_so_id_pa,b_i1
        from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_pa and ttrang='D';
    if b_so_id_pa=0 then b_loi:='loi:Phuong an da xoa hoac chua duyet:loi'; raise PROGRAM_ERROR; end if;
    if b_so_id_bt<>b_i1 then b_loi:='loi:Phuong an khong thuoc ho so:loi'; raise PROGRAM_ERROR; end if;
    b_so_idX:=b_so_id_pa;
end if;
if b_ma_nt<>'VND' then b_tp:=2; end if;
for r_lp in (select ma,ma_nt,max(ngay_ht) ngay_ht from bh_bt_hk_sc where
    ma_dvi=b_ma_dvi and so_id=b_so_idX group by ma,ma_nt) loop
    select ton into b_ton from bh_bt_hk_sc where ma_dvi=b_ma_dvi and so_id=b_so_idX and
        ma=r_lp.ma and ma_nt=r_lp.ma_nt and ngay_ht=r_lp.ngay_ht;
    if b_ton<>0 then
        insert into bh_bt_hk_ton_temp values(r_lp.ma,PBH_BT_HK_TEN(b_ma_dvi,b_so_idX,r_lp.ma),r_lp.ma_nt,b_ton);
    end if;
end loop;
select JSON_ARRAYAGG(json_object(*) order by ten) into b_oraOut from bh_bt_hk_ton_temp;
delete bh_bt_hk_ton_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HK_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_so_id number; dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thanh toan huong khac da xoa:loi';
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
select json_object(so_ct,'so_pa' value so_pa||'|'||so_pa) into dt_ct
    from bh_bt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma,ten,tien) order by ten returning clob) into dt_dk
    from bh_bt_hk_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_hk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('so_id' value b_so_id,'dt_dk' value dt_dk,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HK_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id_bt number;
    b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
    
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_hk where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_hk where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HK_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_phong varchar2(10); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_hk where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_hk where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_hk where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_hk where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_hk where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HK_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,dt_dk clob,
    b_ngay_ht out number,b_so_hs out varchar2,b_so_id_bt out number,
    b_so_pa out varchar2,b_so_id_pa out number,b_ten out nvarchar2,
    b_l_ct out varchar2,b_so_ct out varchar2,b_nt_tra out varchar2,
    b_tra out number,b_tra_qd out number,b_thue out number,b_thue_qd out number,
    a_ma out pht_type.a_var,a_ten out pht_type.a_nvar,a_ma_nt out pht_type.a_var,
    a_tien out pht_type.a_num,a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000); b_ton number; b_ton_qd number;
    b_so_idX number; b_ttrang varchar2(1); b_tong number:=0;
begin
-- Dan - Kiem tra thong tin nhap
b_loi:='loi:Loi xu ly PBH_BT_HK_TEST:loi';
b_lenh:=FKH_JS_LENH('ngay_ht,so_hs,so_pa,ten,l_ct,so_ct,nt_tra,tra,thue');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_hs,b_so_pa,b_ten,b_l_ct,b_so_ct,b_nt_tra,b_tra,b_thue using dt_ct;
b_lenh:=FKH_JS_LENH('ma,ten,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_ma_nt,a_tien using dt_dk;
if b_l_ct not in('T','C') then b_loi:='loi:Sai loai chung tu:loi'; return; end if;
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so boi thuong:loi'; return; end if;
b_loi:='loi:Ho so boi thuong da xoa hoac dang xu ly:loi';
select so_id,ttrang into b_so_id_bt,b_ttrang from bh_bt_hs
    where ma_dvi=b_ma_dvi and so_hs=b_so_hs for update nowait;
if sql%rowcount=0 then return; end if;
if b_so_pa=' ' then
    b_so_id_pa:=0; b_so_idX:=b_so_id_bt;
else
    b_loi:='loi:Phuong an da xoa hoac dang xu ly:loi';
    select so_id,so_id_bt into b_so_id_pa,b_i1 from bh_bt_hs
        where ma_dvi=b_ma_dvi and so_hs=b_so_pa and ttrang='D' for update nowait;
    if sql%rowcount=0 then return; end if;
    if b_i1<>b_so_id_bt then b_loi:='loi:Phuong an khong thuoc ho so:loi'; raise PROGRAM_ERROR; end if;
    if b_ttrang not in('T','D') then
        b_loi:='loi:Tinh trang ho so phai dang trinh, da duyet:loi'; return;
    end if;
    b_so_idX:=b_so_id_pa;
end if;
if a_ma.count=0 then b_loi:='loi:Nhap doi tuong tra:loi'; return; end if;
select ten into b_ten from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_idX;
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Sai so lieu nhap chi tiet dong '||to_char(b_lp)||':loi';
    if a_ma(b_lp)=' ' or a_ma_nt(b_lp)=' ' or a_tien(b_lp)=0 then return; end if;
    PBH_BT_HK_SC_TON(b_ma_dvi,b_so_idX,a_ma(b_lp),a_ma_nt(b_lp),b_ngay_ht,b_ton,b_ton_qd);
    if sign(b_ton)<>sign(a_tien(b_lp)) or abs(b_ton)<abs(a_tien(b_lp)) then
        b_loi:='loi:Tra qua so duoc duyet:loi'; return;
    end if;
    if a_ma_nt(b_lp)='VND' then
        a_tien_qd(b_lp):=a_tien(b_lp);
    elsif a_tien(b_lp)=b_ton then
        a_tien_qd(b_lp):=b_ton_qd;
    else
        a_tien_qd(b_lp):=round(b_ton_qd*a_tien(b_lp)/b_ton,0);
    end if;
    b_tong:=b_tong+a_tien(b_lp);
end loop;
b_loi:='';
if b_ttrang<>'D' and b_tong>FBH_BT_HS_DPHONG(b_ma_dvi,b_so_id_bt)-FBH_BT_HS_DACHI(b_ma_dvi,b_so_id_bt) then
    b_loi:='loi:Tong chi nhieu hon du phong duoc duyet:loi'; raise PROGRAM_ERROR;
end if;
if b_nt_tra='VND' then
    b_tra_qd:=b_tra; b_thue_qd:=b_thue;
else
    if FBH_TT_KTRA(b_nt_tra)<>'C' then b_loi:='loi:Sai loai tien tra:loi'; return; end if;
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_tra);
    b_tra_qd:=round(b_tra*b_i1,0); b_thue_qd:=round(b_thue*b_i1,0);
end if;
if b_so_ct=' ' then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_HK_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS 
    b_i1 number; b_nsd_c varchar2(10); b_ngay_ht number;
    b_so_id_bt number; b_so_id_pa number; b_so_idX number; b_l_ct varchar2(1);
Begin
-- Dan - Xoa chi tiet
select count(*) into b_i1 from bh_bt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht,l_ct,nsd,so_id_kt,so_id_hs,so_id_pa into b_ngay_ht,b_l_ct,b_nsd_c,b_i1,b_so_id_bt,b_so_id_pa
    from bh_bt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd<>b_nsd_c then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu da hach toan:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
if b_so_id_pa<>0 then b_so_idX:=b_so_id_pa; else b_so_idX:=b_so_id_bt; end if;
for r_lp in (select ma,ma_nt,tien,tien_qd from bh_bt_hk_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_BT_HK_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_so_idX,r_lp.ma,r_lp.ma_nt,-r_lp.tien,-r_lp.tien_qd,b_loi);
    if b_loi is not null then return; end if;
end loop;
PBH_BT_HK_KTRA(b_ma_dvi,b_so_idX,b_loi);
if b_loi is not null then return; end if;
delete bh_bt_hk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hk_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_hk where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_HK_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,dt_ct clob,dt_dk clob,
    b_ngay_ht number,b_so_hs varchar2,b_so_id_bt number,
    b_so_pa varchar2,b_so_id_pa number,b_ten nvarchar2,
    b_l_ct varchar2,b_so_ct varchar2,b_nt_tra varchar2,
    b_tra number,b_tra_qd number,b_thue number,b_thue_qd number,
    a_ma pht_type.a_var,a_ten pht_type.a_nvar,a_ma_nt pht_type.a_var,
    a_tien pht_type.a_num,a_tien_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_phong varchar2(10); b_so_idX number:=b_so_id_bt;
    b_tien number; b_tien_qd number;
begin
-- Dan - Nhap chi tiet
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_loi is not null then return; end if;
if b_so_id_pa<>0 then b_so_idX:=b_so_id_pa; end if;
b_tien:=FKH_ARR_TONG(a_tien); b_tien_qd:=FKH_ARR_TONG(a_tien_qd);
insert into bh_bt_hk values(b_ma_dvi,b_so_id,b_ngay_ht,
    b_so_hs,b_so_id_bt,b_so_pa,b_so_id_pa,b_l_ct,b_so_ct,b_ten,
    b_tien,b_tien_qd,b_thue,b_thue_qd,b_tra+b_thue,b_tra_qd+b_thue_qd,
    b_nt_tra,b_tra,b_tra_qd,b_phong,b_nsd,sysdate,0);
for b_lp in 1..a_ma.count loop
    PBH_BT_HK_THOP(b_ma_dvi,b_l_ct,b_ngay_ht,b_so_idX,a_ma(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
    if b_loi is not null then return; end if;
    insert into bh_bt_hk_ct values(b_ma_dvi,b_so_id,a_ma(b_lp),a_ten(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
insert into bh_bt_hk_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_bt_hk_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
PBH_BT_HK_KTRA(b_ma_dvi,b_so_idX,b_loi);
if b_loi is not null then return; end if;
--duong insert vao job
if b_l_ct = 'T' then
    PBH_HD_VAT_JOB_INSERT(b_ma_dvi,b_so_id,'BTHK',b_nsd);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_HK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_so_id number; b_ngay_ht number; b_so_hs varchar2(20); b_so_id_bt number; 
    b_so_pa varchar2(20); b_so_id_pa number; b_ten nvarchar2(500); 
    b_l_ct varchar2(1); b_so_ct varchar2(20); b_nt_tra varchar2(5); 
    b_tra number; b_tra_qd number; b_thue number; b_thue_qd number; 
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_ma_nt pht_type.a_var; 
    a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
    dt_ct clob; dt_dk clob;
begin
-- Dan - Nhap CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_BT_HK_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_HK_TEST(
    b_ma_dvi,b_so_id,dt_ct,dt_dk,
    b_ngay_ht,b_so_hs,b_so_id_bt,b_so_pa,b_so_id_pa,b_ten,
    b_l_ct,b_so_ct,b_nt_tra,b_tra,b_tra_qd,b_thue,b_thue_qd,
    a_ma,a_ten,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_HK_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,
    b_ngay_ht,b_so_hs,b_so_id_bt,b_so_pa,b_so_id_pa,b_ten,
    b_l_ct,b_so_ct,b_nt_tra,b_tra,b_tra_qd,b_thue,b_thue_qd,
    a_ma,a_ten,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_HK_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Dan - Xoa thanh toan huong khac
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null or b_so_id=0 then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_HK_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
