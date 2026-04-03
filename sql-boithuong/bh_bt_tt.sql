/*** Thanh toan boi thuong ***/
create or replace function FBH_BT_TT_TXT(b_ma_dvi varchar2,b_so_id_tt number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_bt_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_TT_SOHS(b_ma_dvi varchar2,b_so_id_tt number) return varchar2
AS
    b_i1 number; b_so_id number;
begin
-- Dan - Tra so ho so thanh toan
select count(*), min(so_id) into b_i1,b_so_id from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1<>1 then return '';
else return FBH_BT_HS_SOHS(b_ma_dvi,b_so_id);
end if;
end;
/
create or replace function FBH_BT_TT_NGAY(b_ma_dvi varchar2,b_so_id_tt number) return number
AS
    b_ngay number;
begin
-- Dan - Tra ngay thanh toan
select nvl(min(ngay_ht),0) into b_ngay from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
return b_ngay;
end;
/
create or replace procedure PBH_BT_TT_HS(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_so_hs varchar2(30):=nvl(trim(b_oraIn),' ');
begin
-- Dan - Tra ttin HS
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_hs=' ' then b_loi:='loi:Nhap so ho so:loi'; raise PROGRAM_ERROR; end if;
select json_object(ma_kh,nt_tien) into b_oraOut from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_PA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_so_hs varchar2(30); b_ma_kh varchar2(20); b_so_id number;
begin
-- Dan - Tra ton PA
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_kh,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_so_hs using b_oraIn;
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hs:=nvl(trim(b_so_hs),' ');
if b_ma_kh=' ' and b_so_hs=' ' then b_loi:='loi:Nhap so ho so, khach hang:loi'; raise PROGRAM_ERROR; end if;
b_oraOut:='';
if b_so_hs<>' ' then
    b_so_id:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    if b_so_id=0 then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
    select JSON_ARRAYAGG(json_object('ma' value so_hs,'ten' value so_hs) order by so_hs) into b_oraOut
        from (select distinct so_hs from bh_bt_hs where
        ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang='D' and FBH_BT_HS_TON(b_ma_dvi,so_id)<>0);
else
    select JSON_ARRAYAGG(json_object('ma' value so_hs,'ten' value so_hs) order by so_hs) into b_oraOut
        from (select distinct so_hs from bh_bt_hs where
        ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and so_id_bt<>0 and ttrang='D' and FBH_BT_HS_TON(b_ma_dvi,so_id)<>0);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_NBH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    b_so_hs varchar2(30); b_ma_kh varchar2(20); b_so_id number;
begin
-- Dan - Tra ton NBH
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_kh,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_so_hs using b_oraIn;
b_ma_kh:=nvl(trim(b_ma_kh),' '); b_so_hs:=nvl(trim(b_so_hs),' ');
if b_ma_kh=' ' and b_so_hs=' ' then b_loi:='loi:Nhap so ho so, khach hang:loi'; raise PROGRAM_ERROR; end if;
b_oraOut:='';
if b_so_hs<>' ' then
    b_so_id:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    if b_so_id=0 then b_loi:='loi:Ho so da xoa:loi'; raise PROGRAM_ERROR; end if;
    select JSON_ARRAYAGG(json_object('ma' value nbh,'ten' value FBH_DTAC_MA_TEN(nbh))) into b_oraOut
        from (select distinct nbh from bh_bt_hs_nbh where
        ma_dvi=b_ma_dvi and so_id=b_so_id and FBH_BT_HS_NBH_TON(b_ma_dvi,b_so_id,nbh)<>0);
else
    select JSON_ARRAYAGG(json_object('ma' value nbh,'ten' value FBH_DTAC_MA_TEN(nbh))) into b_oraOut
        from (select distinct nbh from bh_bt_hs_nbh where
        ma_dvi=b_ma_dvi and FBH_BT_HS_HD_KH(b_ma_dvi,so_id)=b_ma_kh and FBH_BT_HS_NBH_TON(b_ma_dvi,so_id,nbh)<>0);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(2000); b_txt clob:=b_oraIn;
    b_ma_kh varchar2(20); b_so_hs varchar2(20); b_so_pa varchar2(20); b_nbh varchar2(20);
    b_so_id number; b_so_id_pa number; b_ngayX number; b_nt_tien varchar2(5); b_ton number;
begin
-- Dan - Hoi ton thanh toan boi thuong
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FKH_JS_NULL(b_txt);
b_lenh:=FKH_JS_LENH('ma_kh,so_hs,so_pa,nbh');
EXECUTE IMMEDIATE b_lenh into b_ma_kh,b_so_hs,b_so_pa,b_nbh using b_oraIn;
if b_ma_kh=' ' and b_so_hs=' ' then
    b_loi:='loi:Nhap so hop dong, khach hang:loi'; raise PROGRAM_ERROR;
end if;
if b_so_pa=' ' and b_nbh=' ' and FBH_BT_HS_NBH_TONh(b_ma_dvi,b_so_id)='C' then
    b_loi:='loi:Nhap nha bao hiem:loi'; raise PROGRAM_ERROR;
end if;
if b_so_pa<>' ' then
    select nvl(min(so_id),0) into b_so_id_pa from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_pa and ttrang='D';
    if b_so_id_pa=0 then b_loi:='loi:Phuong an da xoa hoac chua duyet:loi'; raise PROGRAM_ERROR; end if;
    select so_id_bt,so_hs_bt,nt_tien into b_so_id,b_so_hs,b_nt_tien
        from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_pa;
    b_ton:=FBH_BT_HS_TON(b_ma_dvi,b_so_id_pa);
    if b_ton=0 then b_loi:='loi:Phuong an da thanh toan het:loi'; raise PROGRAM_ERROR; end if;
    insert into temp_1(n10,n11,c1,c2,c3,n1) values(b_so_id,b_so_id_pa,b_so_hs,b_so_pa,b_nt_tien,b_ton);
elsif b_so_hs<>' ' then
    select nvl(min(so_id),0),min(nt_tien) into b_so_id,b_nt_tien from bh_bt_hs where ma_dvi=b_ma_dvi and so_hs=b_so_hs and ttrang='D';
    if b_so_id=0 then b_loi:='loi:Ho so da xoa hoac chua duyet:loi'; raise PROGRAM_ERROR; end if;
    if b_nbh<>' ' then
        b_ton:=FBH_BT_HS_NBH_TON(b_ma_dvi,b_so_id,b_nbh);
        if b_ton<>0 then
            insert into temp_1(n10,n11,c1,c2,c3,n1) values(b_so_id,0,b_so_hs,' ',b_nt_tien,b_ton);
        end if;
    else
        b_ton:=FBH_BT_HS_TON(b_ma_dvi,b_so_id);
        if b_ton<>0 then
            insert into temp_1(n10,n11,c1,c2,c3,n1) values(b_so_id,0,b_so_hs,' ',b_nt_tien,b_ton);
        end if;
        insert into temp_1(n10,n11,c1,c2,c3,n1)
            select so_id_bt,so_id,so_hs_bt,so_hs,nt_tien,FBH_BT_HS_TON(b_ma_dvi,so_id)
            from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=b_so_id and ttrang='D';
    end if;
else
    if b_nbh<>' ' then
        insert into temp_1(n10,n11,c1,c2,c3,n1) select so_id,0,so_hs,' ',nt_tien,FBH_BT_HS_NBH_TON(b_ma_dvi,so_id,b_nbh)
            from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=0 and ma_kh=b_ma_kh and ttrang='D';
    else
        insert into temp_1(n10,n11,c1,c2,c3,n1)
            select so_id,0,so_hs,' ',nt_tien,FBH_BT_HS_TON(b_ma_dvi,so_id)
            from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt=0 and ma_kh=b_ma_kh and ttrang='D';
        insert into temp_1(n10,n11,c1,c2,c3,n1)
            select so_id_bt,so_id,so_hs_bt,so_hs,nt_tien,FBH_BT_HS_TON(b_ma_dvi,so_id)
            from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_bt<>0 and ma_kh=b_ma_kh and ttrang='D';
    end if;
end if;
delete temp_1 where n1=0;
select JSON_ARRAYAGG(json_object(
    'so_hs' value c1,'so_pa' value c2,'ma_nt' value c3,'ton' value n1,
    'tien' value n1,'chon' value '','so_id' value n10,'so_id_pa' value n11)
    order by c1 returning clob) into b_oraOut from temp_1;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id_tt number;
    dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet thanh toan phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thanh toan da xoa:loi';
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
select json_object(ma_kh,so_ct,'so_pa' value so_pa||'|'||so_pa,
    'nbh' value FBH_DTAC_MA_TENl(nbh)) into dt_ct
    from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(so_id,so_id_pa) order by bt returning clob) into dt_dk
    from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt and loai in ('dt_ct','dt_dk');
select json_object('so_id_tt' value b_so_id_tt,'dt_ct' value dt_ct,
    'dt_dk' value dt_dk,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id_hs number;
    b_so_hs varchar2(30); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number:=0; cs_lke clob:='';
    
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs,ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
            (select so_id_tt,ten,rownum sott from bh_bt_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' and nsd=b_nsd order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
elsif trim(b_so_hs) is not null then
    b_so_id_hs:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt in
        (select distinct so_id_tt from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id_hs);
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ngay_ht) returning clob) into cs_lke from
            (select so_id_tt,ngay_ht,rownum sott from bh_bt_tt where ma_dvi=b_ma_dvi and
                so_id_tt in(select distinct so_id_tt from bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id=b_so_id_hs)
                order by ngay_ht desc)
            where sott between b_tu and b_den;
    end if;
else
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ';
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
            (select so_id_tt,ten,rownum sott from bh_bt_tt where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' order by so_id_tt desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_tu number; b_den number;
    b_so_id number; b_ngay_ht number; b_klk varchar2(1); b_trangkt number;
    b_trang number; b_dong number; cs_lke clob:='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_klk,b_trangKt using b_oraIn;
if b_klk ='N' then
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_bt_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' and nsd=b_nsd order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
        (select so_id_tt,ten,rownum sott from bh_bt_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' and nsd=b_nsd order by so_id_tt desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_bt_tt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ';
    select nvl(min(sott),b_dong) into b_tu from (select so_id_tt,rownum sott from bh_bt_tt where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' order by so_id_tt desc) where so_id_tt<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id_tt,ten) returning clob) into cs_lke from
        (select so_id_tt,ten,rownum sott from bh_bt_tt where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and tpa=' ' order by so_id_tt desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,dt_ct in out clob,dt_dk clob,
    b_ngay_ht out number,b_so_hs out varchar2,b_so_pa out varchar2,b_ma_kh out varchar2,
    b_ten out nvarchar2,b_nbh out varchar2,b_tpa out varchar2,b_so_ct out varchar2,
    b_tien out number,b_thue out number,b_tien_qd out number,b_thue_qd out number,b_t_suat out number,
    b_pt_tra out varchar2,b_nt_tra out varchar2,b_tra out number,b_tra_qd out number,
    a_so_id out pht_type.a_num,a_so_id_pa out pht_type.a_num,a_ma_nt_tt out pht_type.a_var,
    a_tien_tt out pht_type.a_num,a_tien_tt_qd out pht_type.a_num,
    a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num,a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_lenh varchar2(2000);
    b_ton number; b_ton_qd number; b_phong varchar2(10); b_kieu_do varchar2(1);
    b_ma_khC varchar2(20); b_pa varchar2(1):='C'; b_ttrang varchar2(1);
    a_so_hs pht_type.a_var; a_so_pa pht_type.a_var;
    a_ma_dvi_ql pht_type.a_var; a_so_id_hd pht_type.a_num;
begin
-- Dan kiem tra thong tin nhap thanh toan boi thuong
b_lenh:=FKH_JS_LENH('ngay_ht,so_hs,so_pa,ma_kh,ten,pt_tra,so_ct,nt_tra,tra,nbh,tpa,thue,t_suat');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_hs,b_so_pa,b_ma_kh,b_ten,
    b_pt_tra,b_so_ct,b_nt_tra,b_tra,b_nbh,b_tpa,b_thue,b_t_suat using dt_ct;
b_lenh:=FKH_JS_LENH('so_id,so_id_pa,so_hs,so_pa,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id,a_so_id_pa,a_so_hs,a_so_pa,a_ma_nt_tt,a_tien_tt using dt_dk;
if b_pt_tra not in('T','C','B') then b_loi:='loi:Sai phuong thuc tra:loi'; return; end if;
if a_so_id.count=0 then b_loi:='loi:Nhap ho so thanh toan:loi'; return; end if;
b_so_hs:=nvl(trim(b_so_hs),' '); b_so_pa:=nvl(trim(b_so_pa),' '); b_ma_kh:=nvl(trim(b_ma_kh),' '); 
b_nbh:=nvl(trim(b_nbh),' '); b_tpa:=nvl(trim(b_tpa),' '); b_ten:=nvl(trim(b_ten),' '); 
if b_ma_kh=' ' and b_tpa=' ' then b_loi:='loi:Nhap ma khach hang hoac ma TPA:loi'; return; end if;
if b_nt_tra=' ' or FBH_TT_KTRA(b_nt_tra)='K' then
    b_loi:='loi:Sai loai tien tra:loi'; return; 
end if;
a_ma_nt(1):=b_nt_tra; a_tien(1):=b_tra;
for b_lp in 1..a_so_id.count loop
    b_loi:='loi:Sai chi tiet dong '||to_char(b_lp)||':loi';
    if a_so_id(b_lp)=0 or a_ma_nt_tt(b_lp)=' ' or a_tien_tt(b_lp)=0 then return; end if;
    b_loi:='loi:Ho so '||a_so_hs(b_lp)||' da xoa hoac dang xu ly:loi';
    select ma_dvi_ql,so_id_hd,ttrang into a_ma_dvi_ql(b_lp),a_so_id_hd(b_lp),b_ttrang
        from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) for update nowait;
    if sql%rowcount=0 then return; end if;
    if a_so_id_pa(b_lp) is null then a_so_id_pa(b_lp):=0; end if;
    a_so_pa(b_lp):=nvl(trim(a_so_pa(b_lp)),' ');
    if a_so_id_pa(b_lp)=0 then 
        if b_ttrang<>'D' then b_loi:='loi:Ho so chua duyet:loi'; return; end if;
        b_pa:='K';
    else
        b_loi:='loi:Phuong an '||a_so_pa(b_lp)||' da xoa hoac dang xu ly:loi';
        select 0 into b_i1 from bh_bt_hs where
            ma_dvi=b_ma_dvi and so_id=a_so_id_pa(b_lp) and ttrang='D' for update nowait;
        if sql%rowcount=0 then return; end if;
        if b_ttrang not in('T','D') then
            b_loi:='loi:Tinh trang ho so phai dang trinh, da duyet:loi'; return;
        end if;
    end if;
end loop;
if b_pa<>'C' then
    if FBH_DONG(a_ma_dvi_ql(1),a_so_id_hd(1))='V' or FTBH_TMN(a_ma_dvi_ql(1),a_so_id_hd(1))='C' then
        if FBH_DONG(a_ma_dvi_ql(1),a_so_id_hd(1))='V' then
            if b_nbh=' ' then b_nbh:=FBH_DONG_NBH(a_ma_dvi_ql(1),a_so_id_hd(1)); end if;
            if b_nbh=' ' then b_loi:='loi:Khong tim duoc nha bao hiem:loi'; end if;
            for b_lp in 2..a_so_id.count loop
                if FBH_DONG(a_ma_dvi_ql(b_lp),a_so_id_hd(b_lp))<>'V' or FBH_DONG_NBH(a_ma_dvi_ql(b_lp),a_so_id_hd(b_lp))<>b_nbh then
                    b_loi:='loi:Phai thanh toan cung nha bao hiem:loi'; return;
                end if;
            end loop;
        end if;
        if FTBH_TMN(a_ma_dvi_ql(1),a_so_id_hd(1))='C' then
            if b_nbh=' ' then b_nbh:=FTBH_TMN_NBH(a_ma_dvi_ql(1),a_so_id_hd(1)); end if;
            if b_nbh=' ' then b_loi:='loi:Khong tim duoc nha bao hiem:loi'; end if;
            for b_lp in 2..a_so_id.count loop
                if FTBH_TMN(a_ma_dvi_ql(b_lp),a_so_id_hd(b_lp))<>'C' or FTBH_TMN_NBH(a_ma_dvi_ql(b_lp),a_so_id_hd(b_lp))<>b_nbh then
                    b_loi:='loi:Phai thanh toan cung nha bao hiem:loi'; return;
                end if;
            end loop;
        end if;
    elsif b_nbh<>' ' then
        b_loi:='loi:Khong nhap nha dong bao hiem:loi'; return;
    elsif b_pt_tra in('B','F') then
        b_loi:='loi:Khong chon phuong thuc cong no nha dong,tai:loi'; return;
    elsif b_pt_tra='C' and b_ma_kh='VANGLAI' then
        b_loi:='loi:Khong chon cong no khach vang lai:loi'; return;
    end if;
end if;
if b_nbh<>' ' and b_pa<>'C' then
    for b_lp in 1..a_so_id.count loop
        PBH_BT_HS_NBH_TON(b_ma_dvi,a_so_id(b_lp),b_nbh,a_ma_nt_tt(b_lp),b_ngay_ht,b_ton,b_ton_qd);
        if b_ton<a_tien_tt(b_lp) then
            b_loi:='loi:Ho so: '||a_so_hs(b_lp)||' con ton '||FKH_SO_Fm(b_ton,2)||':loi'; return;
        end if;
        if a_ma_nt_tt(b_lp)='VND' then
            a_tien_tt_qd(b_lp):=a_tien_tt(b_lp);
        elsif a_tien_tt(b_lp)=b_ton or b_ton=0 then
            a_tien_tt_qd(b_lp):=b_ton_qd;
        else
            a_tien_tt_qd(b_lp):=round(b_ton_qd*a_tien_tt(b_lp)/b_ton,0);
        end if;
    end loop;
else
    for b_lp in 1..a_so_id.count loop
        if FBH_BT_HS_NBH_KTRA(b_ma_dvi,a_so_id(b_lp))='C' then
            b_loi:='loi:Nhap nha bao hiem:loi'; return;
        end if;
        if a_so_id_pa(b_lp)<>0 then
            PBH_BT_HS_SC_TON(b_ma_dvi,a_so_id_pa(b_lp),a_ma_nt_tt(b_lp),b_ngay_ht,b_ton,b_ton_qd);
        else
            PBH_BT_HS_SC_TON(b_ma_dvi,a_so_id(b_lp),a_ma_nt_tt(b_lp),b_ngay_ht,b_ton,b_ton_qd);
        end if;
        if b_ton<a_tien_tt(b_lp) then
            b_loi:='loi:Ho so: '||a_so_hs(b_lp)||' con ton '||FKH_SO_Fm(b_ton,2)||':loi'; return;
        end if;
        if a_ma_nt_tt(b_lp)='VND' then
            a_tien_tt_qd(b_lp):=a_tien_tt(b_lp);
        elsif a_tien_tt(b_lp)=b_ton or b_ton=0 then
            a_tien_tt_qd(b_lp):=b_ton_qd;
        else
            a_tien_tt_qd(b_lp):=round(b_ton_qd*a_tien_tt(b_lp)/b_ton,0);
        end if;
    end loop;
end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
for b_lp in 1..a_ma_nt.count loop
    if a_ma_nt(b_lp)='VND' then
        a_tien_qd(b_lp):=a_tien(b_lp);
    else
        if b_pt_tra='C' then
            a_tien_qd(b_lp):=PBH_KH_CN_TU_QD(b_ma_dvi,b_ma_kh,'T',a_ma_nt(b_lp),b_ngay_ht,a_tien(b_lp),b_phong);
        elsif b_pt_tra='B' then
            a_tien_qd(b_lp):=PBH_DO_BH_CN_QD(b_ma_dvi,b_nbh,a_ma_nt(b_lp),b_ngay_ht,'T',a_tien(b_lp));
        elsif b_pt_tra='F' then
            a_tien_qd(b_lp):=PTBH_NHA_BH_CN_QD(b_ma_dvi,b_nbh,a_ma_nt(b_lp),b_ngay_ht,'T',a_tien(b_lp));
        else
            a_tien_qd(b_lp):= FBH_TT_VND_QD(b_ngay_ht,a_ma_nt(b_lp),a_tien(b_lp));
        end if;
    end if;
end loop;
b_tien:=FKH_ARR_TONG(a_tien_tt); b_tien_qd:=FKH_ARR_TONG(a_tien_tt_qd);
if b_nt_tra='VND' then
    b_tra_qd:=b_tra; b_thue_qd:=b_thue;
else
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_tra);
    b_tra_qd:=round(b_i1*b_tra,0); b_thue_qd:=round(b_i1*b_thue,0);
end if;
if b_so_ct=' ' then b_so_ct:=substr(to_char(b_so_id_tt),3); end if;
PKH_JS_THAYa(dt_ct,'so_ct,nbh',b_so_ct||','||b_nbh);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_TT_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,
    b_ngay_ht number,b_so_hs varchar2,b_so_pa varchar2,b_ma_kh varchar2,
    b_ten nvarchar2,b_nbh varchar2,b_tpa varchar2,b_so_ct varchar2,
    b_tien number,b_thue number,b_tien_qd number,b_thue_qd number,b_t_suat number,
    b_pt_tra varchar2,b_nt_tra varchar2,b_tra number,b_tra_qd number,
    a_so_id pht_type.a_num,a_so_id_pa pht_type.a_num,a_ma_nt_tt pht_type.a_var,
    a_tien_tt pht_type.a_num,a_tien_tt_qd pht_type.a_num,
    a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,
    dt_ct clob,dt_dk clob,b_loi out varchar2)
AS
    b_i1 number; b_phong varchar2(10);
begin
-- Dan - Nhap thanh toan boi thuong
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_loi:='loi:Loi Table BH_BT_TT:loi';
insert into bh_bt_tt values(b_ma_dvi,b_so_id_tt,b_ngay_ht,b_so_hs,b_so_pa,
    b_ma_kh,b_ten,b_tien,b_thue,b_tien_qd,b_thue_qd,b_t_suat,b_pt_tra,
    b_nt_tra,b_tra,b_tra_qd,b_so_ct,b_phong,b_nbh,b_tpa,b_nsd,sysdate,0);
b_loi:='loi:Loi Table BH_BT_TT_PS:loi';
for b_lp in 1..a_so_id.count loop
    insert into bh_bt_tt_ps values(b_ma_dvi,b_so_id_tt,b_lp,a_so_id(b_lp),a_so_id_pa(b_lp),
        a_ma_nt_tt(b_lp),a_tien_tt(b_lp),a_tien_tt_qd(b_lp));
end loop;
b_loi:='loi:Loi Table BH_BT_TT_CT:loi';
for b_lp in 1..a_ma_nt.count loop
    insert into bh_bt_tt_ct values(b_ma_dvi,b_so_id_tt,b_lp,b_pt_tra,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
insert into bh_bt_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_ct',dt_ct);
insert into bh_bt_tt_txt values(b_ma_dvi,b_so_id_tt,'dt_dk',dt_dk);
if b_nbh<>' ' then
    for b_lp in 1..a_so_id.count loop
        PBH_BT_HS_NBH_TH(b_ma_dvi,a_so_id(b_lp),'C',b_ngay_ht,b_nbh,a_ma_nt_tt(b_lp),a_tien_tt(b_lp),a_tien_tt_qd(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
end if;
for b_lp in 1..a_so_id.count loop
    if a_so_id_pa(b_lp)<>0 then
        PBH_BT_HS_THOP(b_ma_dvi,'C',b_ngay_ht,a_so_id_pa(b_lp),
        a_ma_nt_tt(b_lp),a_tien_tt(b_lp),a_tien_tt_qd(b_lp),b_loi);
    else
        PBH_BT_HS_THOP(b_ma_dvi,'C',b_ngay_ht,a_so_id(b_lp),
        a_ma_nt_tt(b_lp),a_tien_tt(b_lp),a_tien_tt_qd(b_lp),b_loi);
    end if;
    if b_loi is not null then return; end if;
end loop;
if b_pt_tra='C' then
    for b_lp in 1..a_ma_nt.count loop
        PBH_KH_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_kh,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi,b_phong);
        if b_loi is not null then return; end if;
    end loop;
    PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra='B' then
    for b_lp in 1..a_ma_nt.count loop
        PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nbh,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra='F' then
    for b_lp in 1..a_ma_nt.count loop
        PTBH_NHA_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nbh,a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
        if b_loi is not null then return; end if;
    end loop;
    FTBH_TMN_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
end if;
PBH_BT_TON_KTRA(b_ma_dvi,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_TT_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id_tt number,b_ktra boolean,b_loi out varchar2)
AS 
    b_i1 number; b_ngay_ht number; b_so_id number; b_tien number; b_tien_qd number;
    b_nsdC varchar2(10); b_ma_nt varchar2(5); b_ma_kh varchar2(20); b_pt_tra varchar2(1);
    b_nbh varchar2(20); b_phong varchar2(10);
Begin
-- Dan - Xoa thanh toan boi thuong
select count(*) into b_i1 from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht,ma_kh,pt_tra,nsd,nbh,so_id_kt,phong into b_ngay_ht,b_ma_kh,b_pt_tra,b_nsdC,b_nbh,b_i1,b_phong
    from bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu da hach toan:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
for r_lp in (select so_id,so_id_pa,ma_nt,tien,tien_qd from bh_bt_tt_ps
    where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
    if r_lp.so_id_pa<>0 then
        PBH_BT_HS_THOP(b_ma_dvi,'C',b_ngay_ht,r_lp.so_id_pa,r_lp.ma_nt,-r_lp.tien,-r_lp.tien_qd,b_loi);
        if b_loi is not null then return; end if;
    else
        PBH_BT_HS_THOP(b_ma_dvi,'C',b_ngay_ht,r_lp.so_id,r_lp.ma_nt,-r_lp.tien,-r_lp.tien_qd,b_loi);
        if b_loi is not null then return; end if;
        if b_nbh<>' ' then
            PBH_BT_HS_NBH_TH(b_ma_dvi,r_lp.so_id,'C',b_ngay_ht,b_nbh,r_lp.ma_nt,-r_lp.tien,-r_lp.tien_qd,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end if;
end loop;
if b_pt_tra='B' then
    for r_lp in (select ma_nt,tien,tien_qd from bh_bt_tt_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
        b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
        PBH_DO_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nbh,b_ma_nt,-b_tien,-b_tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra='F' then
    for r_lp in (select ma_nt,tien,tien_qd from bh_bt_tt_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
        b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
        PTBH_NHA_BH_CN_THOP(b_ma_dvi,'T',b_ngay_ht,b_nbh,b_ma_nt,-b_tien,-b_tien_qd,b_loi);
        if b_loi is not null then return; end if;
    end loop;
    FTBH_TMN_CN_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
elsif b_pt_tra='C' then
    for r_lp in (select ma_nt,tien,tien_qd from bh_bt_tt_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt) loop
        b_ma_nt:=r_lp.ma_nt; b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
        PBH_KH_CN_TU_THOP(b_ma_dvi,'T',b_ngay_ht,b_ma_kh,b_ma_nt,b_tien,b_tien_qd,b_loi,b_phong);
        if b_loi is not null then return; end if;
    end loop;
end if;
if b_ktra then
    PBH_BT_TON_KTRA(b_ma_dvi,b_loi);
    if b_loi is not null then return; end if;
    if b_pt_tra='B' then
        PBH_DO_BH_CN_KTRA(b_ma_dvi,b_loi);
        if b_loi is not null then return; end if;
    elsif b_pt_tra='B' then
        PBH_KH_CN_TU_KTRA(b_ma_dvi,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
delete bh_bt_tt_txt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_bt_tt_ct where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_bt_tt_ps where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
delete bh_bt_tt where ma_dvi=b_ma_dvi and so_id_tt=b_so_id_tt;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_TT_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi nvarchar2(200); b_lenh varchar2(2000);
    dt_ct clob; dt_dk clob;
    b_so_id_tt number; b_ngay_ht number; b_so_hs varchar2(20); b_so_pa varchar2(20);
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_pt_tra varchar2(1);
    b_so_ct varchar2(20); b_nbh varchar2(20); b_tpa varchar2(20);
    b_tien number; b_thue number; b_tien_qd number; b_thue_qd number; b_t_suat number;
    b_nt_tra varchar2(5); b_tra number; b_tra_qd number;

    a_so_id pht_type.a_num; a_so_id_pa pht_type.a_num; a_ma_nt_tt pht_type.a_var; a_tien_tt pht_type.a_num;
    a_tien_tt_qd pht_type.a_num; a_tien_qd pht_type.a_num;
    a_ma_nt pht_type.a_var; a_tien pht_type.a_num;
begin
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id_tt=0 then
    PHT_ID_MOI(b_so_id_tt,b_loi);
else
    PBH_BT_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,false,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_TT_TEST(b_ma_dvi,b_nsd,b_so_id_tt,dt_ct,dt_dk,
    b_ngay_ht,b_so_hs,b_so_pa,b_ma_kh,b_ten,b_nbh,b_tpa,b_so_ct,
    b_tien,b_thue,b_tien_qd,b_thue_qd,b_t_suat,b_pt_tra,b_nt_tra,b_tra,b_tra_qd,
    a_so_id,a_so_id_pa,a_ma_nt_tt,a_tien_tt,a_tien_tt_qd,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_TT_NH_NH(b_ma_dvi,b_nsd,b_so_id_tt,
    b_ngay_ht,b_so_hs,b_so_pa,b_ma_kh,b_ten,b_nbh,b_tpa,b_so_ct,
    b_tien,b_thue,b_tien_qd,b_thue_qd,b_t_suat,b_pt_tra,b_nt_tra,b_tra,b_tra_qd,
    a_so_id,a_so_id_pa,a_ma_nt_tt,a_tien_tt,a_tien_tt_qd,a_ma_nt,a_tien,a_tien_qd,dt_ct,dt_dk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id_tt' value b_so_id_tt) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi nvarchar2(200); b_so_id_tt number;
begin
-- Dan - Xoa thanh toan boi thuong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id_tt:=FKH_JS_GTRIn(b_oraIn,'so_id_tt');
if b_so_id_tt is null or b_so_id_tt=0 then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_TT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id_tt,true,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TT_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(400); cs_lke clob:='';
    b_cmt varchar2(20); b_mobi varchar2(20); b_so_hs varchar2(30); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ma_kh varchar2(20);
begin
-- Dan - Tim thanh toan qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,cmt,mobi,email,so_hs');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_cmt,b_mobi,b_email,b_so_hs using b_oraIn;
b_so_hs:=nvl(trim(b_so_hs),' ');
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if; 
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select count(*) into b_dong from bh_bt_tt a, bh_bt_tt_ps b, bh_bt_hs hs where a.ma_dvi=b_ma_dvi and a.ma_kh=b_ma_kh and
        a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_tt=a.so_id_tt 
        and hs.ma_dvi = b.ma_dvi and hs.so_id  = b.so_id and b_so_hs in (' ',hs.so_hs);
    select JSON_ARRAYAGG(json_object(a.ngay_ht,'so_hs' value FBH_BT_HS_SOHS(b.ma_dvi,b.so_id),a.ten,a.so_id_tt)
		order by a.ngay_ht desc returning clob) into cs_lke
        from bh_bt_tt a, bh_bt_tt_ps b, bh_bt_hs hs where a.ma_dvi=b_ma_dvi and a.ma_kh=b_ma_kh and
        a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_tt=a.so_id_tt
        and hs.ma_dvi = b.ma_dvi and hs.so_id  = b.so_id and b_so_hs in (' ',hs.so_hs);
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_bt_tt a, bh_bt_tt_ps b, bh_bt_hs hs where a.ma_dvi=b_ma_dvi and
        a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_tt=a.so_id_tt
        and hs.ma_dvi = b.ma_dvi and hs.so_id  = b.so_id and b_so_hs in (' ',hs.so_hs);
    select JSON_ARRAYAGG(json_object(a.ngay_ht,'so_hs' value FBH_BT_HS_SOHS(b.ma_dvi,b.so_id),a.ten,a.so_id_tt)
		order by a.ngay_ht desc returning clob) into cs_lke
        from bh_bt_tt a, bh_bt_tt_ps b, bh_bt_hs hs where a.ma_dvi=b_ma_dvi and
        a.ngay_ht between b_ngayD and b_ngayC and a.nsd=b_nsd and b.ma_dvi=a.ma_dvi and b.so_id_tt=a.so_id_tt
        and hs.ma_dvi = b.ma_dvi and hs.so_id  = b.so_id and b_so_hs in (' ',hs.so_hs);
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
