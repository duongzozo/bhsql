/*** DOI NGUOI THU BA ***/
create or replace function FBH_BT_TBA_TXT(b_ma_dvi varchar2,b_so_id number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
select count(*) into b_i1 from bh_bt_tba_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_tba_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace function FBH_BT_TBA_TON(
    b_ma_dvi varchar2,b_so_id number,b_ten nvarchar2,b_ma_nt varchar2,b_ngay_ht number:=30000101) return number
AS
    b_kq number:=0; b_ngayX number;
begin
select nvl(max(ngay_ht),0) into b_ngayX from bh_bt_tba_sc where ma_dvi=b_ma_dvi and
    so_id=b_so_id and ten=b_ten and ma_nt=b_ma_nt and ngay_ht<=b_ngay_ht;
if b_ngayX<>0 then
    select ton into b_kq from bh_bt_tba_sc where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ten=b_ten and ma_nt=b_ma_nt and ngay_ht=b_ngayX;
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_TBA_THOP
    (b_ma_dvi varchar2,b_ps varchar2,b_ngay_ht number,b_so_id number,
    b_ten nvarchar2,b_ma_nt varchar2,b_tien number,b_loi out varchar2)
AS
    b_thu number; b_chi number; b_ton number; b_i1 number;
begin
-- Dan - Tong hop boi thuong
if b_ps='T' then b_thu:=b_tien; b_chi:=0;
else b_thu:=0; b_chi:=b_tien;
end if;
select nvl(max(ngay_ht),0) into b_i1 from bh_bt_tba_sc where ma_dvi=b_ma_dvi and
    so_id=b_so_id and ten=b_ten and ma_nt=b_ma_nt and ngay_ht<b_ngay_ht;
b_ton:=FBH_BT_TBA_TON(b_ma_dvi,b_so_id,b_ten,b_ma_nt,b_i1);
update bh_bt_tba_sc set thu=thu+b_thu,chi=chi+b_chi
    where ma_dvi=b_ma_dvi and so_id=b_so_id and ten=b_ten and ma_nt=b_ma_nt and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into bh_bt_tba_sc values(b_ma_dvi,b_so_id,b_ten,b_ma_nt,b_thu,b_chi,0,b_ngay_ht);
end if;
for b_rc in (select * from bh_bt_tba_sc where ma_dvi=b_ma_dvi and so_id=b_so_id and
    ten=b_ten and ma_nt=b_ma_nt and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_i1:=b_rc.ngay_ht;
    if b_rc.thu=0 and b_rc.chi=0 then
        delete bh_bt_tba_sc where ma_dvi=b_ma_dvi and ma_dvi=b_ma_dvi and
            so_id=b_so_id and ten=b_ten and ma_nt=b_ma_nt and ngay_ht=b_i1;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi;
        update bh_bt_tba_sc set ton=b_ton where ma_dvi=b_ma_dvi and so_id=b_so_id and ten=b_ten and ma_nt=b_ma_nt and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_BT_TBA_PT(b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_so_id_bt number; b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_ngay_ht number; b_tien number; b_ton number; b_hs number;
    a_lh_nv pht_type.a_var; a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
Begin
-- Dan - Phan tich
b_loi:='loi:Loi xu lu PBH_BT_TBA_PT:loi';
select ngay_ht,so_id_bt,ma_dvi_ql,so_id_hd,so_id_dt into b_ngay_ht,b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt
    from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in(select * from bh_bt_tba_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    select nvl(min(tien),0) into b_tien from bh_bt_tba_ps
        where ma_dvi=b_ma_dvi and so_id=b_so_id_bt and ten=r_lp.ten and ma_nt=r_lp.ma_nt;
    if b_tien=0 then continue; end if;
    b_ton:=FBH_BT_TBA_TON(b_ma_dvi,b_so_id_bt,r_lp.ten,r_lp.ma_nt,b_ngay_ht);
    if b_ton=0 then
        select lh_nv,sum(tien) bulk collect into a_lh_nv,a_tien from
            (select lh_nv,tien from bh_bt_tba_ps_pt where ma_dvi=b_ma_dvi and so_id=b_so_id_bt and ten=r_lp.ten and ma_nt=r_lp.ma_nt union
            select lh_nv,-tien from bh_bt_tba_pt where ma_dvi=b_ma_dvi and so_id_bt=b_so_id_bt and ten=r_lp.ten and ma_nt=r_lp.ma_nt)
            group by lh_nv having sum(tien)<>0;
    else
        b_hs:=r_lp.tien/b_tien;
        select lh_nv,round(tien*b_hs,0) bulk collect into a_lh_nv,a_tien from
            bh_bt_tba_ps_pt where ma_dvi=b_ma_dvi and so_id=b_so_id_bt and ten=r_lp.ten and ma_nt=r_lp.ma_nt;
    end if;
    for b_lp in 1..a_lh_nv.count loop
        if r_lp.ma_nt='VND' then
            a_tien_qd(b_lp):=a_tien(b_lp);
        else
            a_tien_qd(b_lp):=FBH_TT_VND_QD(b_ngay_ht,r_lp.ma_nt,a_tien(b_lp));
        end if;
    end loop;
    forall b_lp in 1..a_lh_nv.count
        insert into bh_bt_tba_pt values(b_ma_dvi,b_so_id,b_so_id_bt,b_ma_dvi_hd,b_so_id_hd,b_so_id_dt,
            b_ngay_ht,r_lp.ten,r_lp.ma_nt,a_lh_nv(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_BT_TBA_TON(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number;
    b_so_hs varchar2(30); b_so_id number:=0; cs_ton clob:='';
begin
-- Dan - Liet ke ton
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_so_hs:=FKH_JS_GTRIs(b_oraIn,'so_hs');
if trim(b_so_hs) is null then b_loi:='loi:Nhap so ho so boi thuong:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
if b_so_id=0 then b_loi:='loi:Ho so boi thuong chua nhap hoac da xoa:loi'; raise PROGRAM_ERROR; end if;
for r_lp in (select ten,ma_nt,max(ngay_ht) ngay_ht from bh_bt_tba_sc where ma_dvi=b_ma_dvi and so_id=b_so_id group by ten,ma_nt) loop
    select ton into b_i1 from bh_bt_tba_sc where
        ma_dvi=b_ma_dvi and so_id=b_so_id and ten=r_lp.ten and ma_nt=r_lp.ma_nt and ngay_ht=r_lp.ngay_ht;
    if b_i1<>0 then
        insert into temp_1(c1,c2,n1) values(r_lp.ten,r_lp.ma_nt,b_i1);
    end if;
end loop;
select JSON_ARRAYAGG(json_object('ten' value c1,'ma_nt' value c2,'tien' value n1) order by c1,c2 returning clob) into cs_ton from temp_1;
select json_object('cs_ton' value cs_ton returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TBA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_so_id number; dt_ct clob; dt_dk clob; dt_txt clob;
begin
-- Dan - Xem chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Thu doi nguoi thu ba da xoa:loi';
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
select json_object('so_hs' value so_hs,'so_ct' value so_ct returning clob) into dt_ct from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ten,ma_nt,tien) order by ten,ma_nt returning clob) into dt_dk
    from bh_bt_tba_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
    --nam: select dt_ct tu txt
select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
    from bh_bt_tba_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
select json_object('so_id' value b_so_id,'dt_dk' value dt_dk,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure Pbh_BT_TBA_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_so_id_bt number;
    b_so_hs varchar2(30); b_ngay_ht number; b_klk varchar2(1); b_tu number; b_den number; b_phong varchar2(10);
    b_dong number:=0; cs_lke clob:='';
    
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hs,ngay_ht,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_so_hs,b_ngay_ht,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_tba where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
            where sott between b_tu and b_den;
    end if;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
            (select so_id,ten,rownum sott from bh_bt_tba where 
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc)
            where sott between b_tu and b_den;
    end if;
elsif trim(b_so_hs) is not null then
    b_so_id_bt:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_bt=b_so_id_bt;
    if b_dong<>0 then
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        select JSON_ARRAYAGG(json_object(so_id,ngay_ht) returning clob) into cs_lke from
            (select so_id,ngay_ht,rownum sott from bh_bt_tba where ma_dvi=b_ma_dvi and so_id_bt=b_so_id_bt order by ngay_ht desc)
            where sott between b_tu and b_den;
    end if;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TBA_LKE_ID(
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
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_tba where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_tba where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id desc)
        where sott between b_tu and b_den;
elsif b_klk='P' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,rownum sott from bh_bt_tba where
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) where so_id<=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ten) returning clob) into cs_lke from
        (select so_id,ten,rownum sott from bh_bt_tba where 
        ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by so_id desc) 
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TBA_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,dt_dk clob,
    b_ngay_ht out number,b_so_hs out varchar2,b_so_id_bt out number,b_nv out varchar2,
    b_so_ct out varchar2,b_nt_tra out varchar2,b_tra out number,b_tra_qd out number,
    b_thue out number,b_thue_qd out number,b_t_suat out number,
    b_ma_thue out varchar2,b_ten_tba out nvarchar2,b_dchi out nvarchar2,
    b_mau out varchar2,b_seri out varchar2,b_so_don out varchar2,b_ma_kh out varchar2,b_ten out nvarchar2,
    a_ten out pht_type.a_nvar,a_ma_nt out pht_type.a_var,a_tien out pht_type.a_num,a_tien_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(2000);
begin
-- Dan - kiem tra thong tin nhap
b_lenh:=FKH_JS_LENH('ngay_ht,so_hs,so_ct,nt_tra,tra,thue,t_suat');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_so_hs,b_so_ct,b_nt_tra,b_tra,b_thue,b_t_suat using dt_ct;
b_lenh:=FKH_JS_LENH('ten,ma_nt,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ten,a_ma_nt,a_tien using dt_dk;
--nam: bo check tra=0
if b_ngay_ht=0 or b_so_hs=' ' or b_nt_tra=' ' then
    b_loi:='loi:Sai so lieu nhap:loi'; return; 
end if;
b_so_id_bt:=PBH_BT_HS_SOID(b_ma_dvi,b_so_hs);
if b_so_id_bt=0 then b_loi:='loi:Ho so boi thuong da xoa:loi'; return; end if;
select nv,ma_kh,ten into b_nv,b_ma_kh,b_ten from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
if b_nt_tra='VND' then
    b_tra_qd:=b_tra; b_thue_qd:=b_thue;
else
    if FBH_TT_KTRA(b_nt_tra)<>'C' then b_loi:='loi:Sai loai tien tra:loi'; return; end if;
    b_i1:=FBH_TT_TRA_TGTT(b_ngay_ht,b_nt_tra);
    b_tra_qd:=round(b_tra*b_i1,0); b_thue_qd:=round(b_thue*b_i1,0);
end if;
for b_lp in 1..a_ten.count loop
    b_loi:='loi:Sai so lieu nhap chi tiet dong '||to_char(b_lp)||':loi';
    if a_ten(b_lp) is null or a_ma_nt(b_lp) is null or a_tien(b_lp) is null or a_tien(b_lp)<=0 then return; end if;
    select count(*) into b_i1 from bh_bt_tba_ps where ma_dvi=b_ma_dvi and so_id=b_so_id_bt and ten=a_ten(b_lp) and ma_nt=a_ma_nt(b_lp);
    if b_i1=0 then return; end if;
    a_tien_qd(b_lp):=FBH_TT_VND_QD(b_ngay_ht,a_ma_nt(b_lp),a_tien(b_lp));
end loop;
if trim(b_so_ct) is null then
    b_so_ct:=substr(to_char(b_so_id),3); PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_BT_TBA_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_ngay_ht number,b_so_hs varchar2,b_so_id_bt number,b_nv varchar2,
    b_so_ct varchar2,b_nt_tra varchar2,b_tra number,b_tra_qd number,
    b_thue number,b_thue_qd number,b_ma_thue varchar2,b_t_suat number,b_ten_tba nvarchar2,b_dchi nvarchar2,
    b_mau varchar2,b_seri varchar2,b_so_don varchar2,b_ma_kh varchar2,b_ten nvarchar2,
    a_ten pht_type.a_nvar,a_ma_nt pht_type.a_var,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,
    dt_ct clob,dt_dk clob,b_loi out varchar2)
AS
    b_phong varchar2(10); b_ma_dvi_xl varchar2(10); b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_so_id_dt number;
    b_tien number; b_tien_qd number; b_tien_do number; b_tien_do_qd number; b_tl_do number; b_tp number;
begin
-- Dan - Nhap chi tiet
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
b_tien:=FKH_ARR_TONG(a_tien); b_tien_qd:=FKH_ARR_TONG(a_tien_qd);
select phong,ma_dvi_xl,ma_dvi_ql,so_id_hd,so_id_dt into b_phong,b_ma_dvi_xl,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt
    from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
insert into bh_bt_tba values(b_ma_dvi,b_so_id,b_ngay_ht,b_nv,b_so_hs,b_so_id_bt,
    b_ma_dvi_xl,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_so_ct,
    b_tien,b_thue,b_tien+b_thue,b_tien_qd,b_thue_qd,b_tien_qd+b_thue_qd,b_t_suat,b_nt_tra,b_tra,b_tra_qd,
    b_ma_thue,b_ten_tba,b_dchi,b_mau,b_seri,b_so_don,b_ma_kh,b_ten,b_phong,b_nsd,sysdate,0);
for b_lp in 1..a_ma_nt.count loop
    insert into bh_bt_tba_ct values(b_ma_dvi,b_so_id,a_ten(b_lp),a_ma_nt(b_lp),a_tien(b_lp),a_tien_qd(b_lp));
end loop;
insert into bh_bt_tba_txt values(b_ma_dvi,b_so_id,'dt_ct',dt_ct);
insert into bh_bt_tba_txt values(b_ma_dvi,b_so_id,'dt_dk',dt_dk);
for b_lp in 1..a_ma_nt.count loop
    PBH_BT_TBA_THOP(b_ma_dvi,'C',b_ngay_ht,b_so_id_bt,a_ten(b_lp),a_ma_nt(b_lp),a_tien(b_lp),b_loi);
    if b_loi is not null then return; end if;
end loop;
PBH_BT_TBA_PT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
if b_tien<>0 then
    if FBH_DONG(b_ma_dvi_ql,b_so_id_hd)='D' then
        PBH_TH_DO_TBA(b_ma_dvi,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PTBH_TH_TA_TBA(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
--duong insert vao job
PBH_HD_VAT_JOB_INSERT(b_ma_dvi,b_so_id,'BTTBA',b_nsd);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_TBA_NH_NH:loi'; end if;
end;
/
create or replace procedure PBH_BT_TBA_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS 
    b_i1 number; b_nsd_c varchar2(10); b_ngay_ht number; b_so_id_bt number;
    b_ma_dvi_ql varchar2(10); b_so_id_hd number; b_tien number;
    b_tien_do number; b_tien_do_qd number; b_tl_do number; b_tp number; b_ten nvarchar2(200);
Begin
-- Dan - Xoa chi tiet
select count(*) into b_i1 from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select ngay_ht,nsd,so_id_kt,so_id_bt,tien,ten into b_ngay_ht,b_nsd_c,b_i1,b_so_id_bt,b_tien,b_ten
    from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then return; end if;
if b_nsd<>b_nsd_c then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa chung tu da hach toan:loi'; return; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'BH','BT');
if b_loi is not null then return; end if;
select ma_dvi_ql,so_id_hd into b_ma_dvi_ql,b_so_id_hd from bh_bt_hs where ma_dvi=b_ma_dvi and so_id=b_so_id_bt;
for r_lp in (select ten,ma_nt,tien from bh_bt_tba_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    PBH_BT_TBA_THOP(b_ma_dvi,'C',b_ngay_ht,b_so_id_bt,r_lp.ten,r_lp.ma_nt,-r_lp.tien,b_loi);
    if b_loi is not null then return; end if;
end loop;
if b_tien<>0 then
    if FTBH_PS(b_ma_dvi_ql,b_so_id_hd,b_so_id)<>0 then b_loi:='loi:Khong xoa thanh toan da xu ly tai BH:loi'; return; end if;
    delete bh_bt_tba_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PBH_TH_DO_XOA_PS(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PTBH_TH_TA_XOA(b_so_id,0,0,0,b_loi);
    if b_loi is not null then return; end if;
end if;
delete bh_bt_tba_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_tba_pt where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_tba_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_BT_TBA_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PBH_BT_TBA_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(100); dt_ct clob; dt_dk clob;
    b_so_id number; b_ngay_ht number; b_so_hs varchar2(20); b_so_id_bt number;
    b_so_ct varchar2(20); b_nt_tra varchar2(5); b_tra number; b_tra_qd number;
    b_thue number; b_thue_qd number; b_t_suat number;
    b_ma_thue varchar2(20); b_ten_tba nvarchar2(500); b_dchi nvarchar2(500);
    b_mau varchar2(20); b_seri varchar2(10); b_so_don varchar2(20);
    b_ma_kh varchar2(20); b_ten nvarchar2(500); b_nv varchar2(10);
    a_ten pht_type.a_nvar; a_ma_nt pht_type.a_var; a_tien pht_type.a_num; a_tien_qd pht_type.a_num;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PBH_BT_TBA_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_TBA_TEST(b_ma_dvi,b_so_id,dt_ct,dt_dk,
    b_ngay_ht,b_so_hs,b_so_id_bt,b_nv,b_so_ct,b_nt_tra,b_tra,b_tra_qd,
    b_thue,b_thue_qd,b_t_suat,b_ma_thue,b_ten_tba,b_dchi,b_mau,b_seri,b_so_don,b_ma_kh,b_ten,
    a_ten,a_ma_nt,a_tien,a_tien_qd,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_TBA_NH_NH(b_ma_dvi,b_nsd,b_so_id,b_ngay_ht,b_so_hs,b_so_id_bt,b_nv,b_so_ct,b_nt_tra,b_tra,b_tra_qd,
    b_thue,b_thue_qd,b_t_suat,b_ma_thue,b_ten_tba,b_dchi,b_mau,b_seri,b_so_don,b_ma_kh,b_ten,
    a_ten,a_ma_nt,a_tien,a_tien_qd,dt_ct,dt_dk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TBA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi nvarchar2(200); b_so_id number;
begin
-- Dan - Xoa 
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id is null or b_so_id=0 then b_loi:='loi:Nhap SO ID:loi'; raise PROGRAM_ERROR; end if;
PBH_BT_TBA_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_TBA_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; r_hd bh_bt_tba%rowtype;
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan - Xoa
b_loi:=''; b_kt:=0;
select * into r_hd from bh_bt_tba where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_hd.so_don is not null then
    b_kt:=b_kt+1;
    a_gcn_m(b_kt):=r_hd.mau; a_gcn_c(b_kt):=r_hd.seri; a_gcn_s(b_kt):=r_hd.so_don;
    PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn_s,r_hd.nsd,'',b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; end if;
end;
/
create or replace procedure PBH_BT_TBA_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); cs_lke clob:='';
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number; b_ma_kh varchar2(20); b_so_hs varchar2(30);
begin
-- Dan - Tim thanh toan qua CMT, mobi, email
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hs,cmt,mobi,email');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hs,b_cmt,b_mobi,b_email using b_oraIn;
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_hs:=nvl(b_so_hs,' ');
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and b_so_hs in (' ',so_hs) and ma_kh=b_ma_kh and
            ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_tba where ma_dvi=b_ma_dvi and b_so_hs in (' ',so_hs) and ma_kh=b_ma_kh and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
elsif b_ngayD between b_ngay and 30000101 then
    select count(*) into b_dong from bh_bt_tba where ma_dvi=b_ma_dvi and b_so_hs in (' ',so_hs) and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
    select JSON_ARRAYAGG(json_object(ngay_ht,so_hs,ten,so_id) order by ngay_ht desc returning clob) into cs_lke
        from bh_bt_tba where ma_dvi=b_ma_dvi and b_so_hs in (' ',so_hs) and ngay_ht between b_ngayD and b_ngayC and nsd=b_nsd;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
