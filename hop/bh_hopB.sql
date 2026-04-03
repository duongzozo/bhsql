create or replace function FBH_HOPB_NHOM(
    b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Nam - Tra nghiep vu
select min(nhom) into b_kq from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HOPB_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Nam - Tra so hop dong
select min(so_hd) into b_kq from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_HOPB_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='',b_nhom varchar2:='') return number
as
    b_kq number;
begin
-- Nam - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_hopB where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_hopB where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv and nhom=b_nhom;
end if;
return b_kq;
end;
/
create or replace procedure PBH_HOPB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(10); b_nhom varchar2(1);
    b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Nam - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,nhom,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_nhom,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_hopB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hopB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HOP','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hopB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hopB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hopB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hopB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPB_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(10); b_nhom varchar2(1);
  b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Nam - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,nhom,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_nhom,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_HOPB_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_hopB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hopB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hopB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','HOP','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_hopB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hopB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hopB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_hopB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_hopB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(obj) into cs_lke from
        (select json_object(ma_dvi,so_id,so_hd,lan,nsd) obj,rownum sott from bh_hopB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nhom=b_nhom order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPB_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10); b_nhom varchar2(2);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Nam - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_lenh:=FKH_JS_LENH('so_hd,nv,nhom');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv,b_nhom using b_oraIn;
b_so_id:=FBH_HOPB_SO_ID(b_ma_dvi,b_so_hd,b_nv,b_nhom);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPB_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_dong number; cs_lke clob:='';
    b_so_id number; b_lan number; b_ma_kh varchar2(20); b_so_hd varchar2(20);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(100);
    b_ten nvarchar2(500); b_phong varchar2(10);
    b_ngayD number; b_ngayC number; b_ttrang varchar2(1);
    b_nv varchar2(10); b_nhom varchar2(1); b_i1 number;
begin
-- Nam - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,ttrang,cmt,mobi,email,ten,so_hd,nv,nhom');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_ttrang,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_nv,b_nhom using b_oraIn;
b_ttrang:=nvl(trim(b_ttrang),' '); b_ten:=nvl(trim(upper(b_ten)), ' ');
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
b_i1:=PKH_NG_CSO(add_months(sysdate,-36));
if b_ngayD in (0,30000101) or b_ngayD<b_i1 then b_ngayD:=b_i1; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_i1:=0;
if trim(b_cmt||b_mobi||b_email) is not null then
    b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
    if b_ma_kh is null then b_loi:='loi:Khong tim duoc khach hang:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select so_id,max(lan) lan from bh_hopB where ma_dvi=b_ma_dvi and ma_kh=b_ma_kh and nv=b_nv and nhom=b_nhom and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ttrang in (' ',ttrang) group by so_id) loop
        b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
        insert into ket_qua(c1,c2,c3,n1,n10,n11,n12,n13)
            select so_hd,ttrang,ten,ngay_ht,b_so_id,b_lan,ngay_hl,ngay_kt
            from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
    end loop;
else
    for r_lp in (select so_id,max(lan) lan from bh_hopB where ma_dvi=b_ma_dvi and nv=b_nv and nhom=b_nhom and
        ngay_ht between b_ngayD and b_ngayC and phong=b_phong and (b_so_hd = ' ' OR so_hd LIKE '%' || b_so_hd || '%')
        and (b_ten = ' ' OR upper(ten) LIKE '%' || b_ten || '%') and b_ttrang in (' ',ttrang) group by so_id) loop
        b_so_id:=r_lp.so_id; b_lan:=r_lp.lan;
        insert into ket_qua(c1,c2,c3,n1,n10,n11,n12,n13)
            select so_hd,ttrang,ten,ngay_ht,b_so_id,b_lan,ngay_hl,ngay_kt
            from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
        b_i1:=b_i1+1;
        if b_i1>300 then exit; end if;
    end loop;
end if;
select count(*) into b_dong from ket_qua;
select JSON_ARRAYAGG(json_object('so_hd' value c1,'lan' value n11,'ttrang' value c2,'ten' value c3,
    'ngay_ht' value n1,'ma_dvi' value b_ma_dvi,'so_id' value n10,'ngay_hl' value n12, 'ngay_kt' value n13 returning clob)
    order by n3 desc,c1 returning clob) into cs_lke from ket_qua;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPB_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_lan number,b_loi out varchar2)
AS
    b_i1 number; b_nsdC varchar2(20);
begin
-- Nam - Xoa
b_loi:='loi:Loi xu ly PBH_HOPB_XOA_XOA:loi';
select count(*) into b_i1 from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>0 then
  select nsd into b_nsdC from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
  if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
end if;
select count(*) into b_i1 from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa bao gia da chuyen sang hop dong:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_hopB:loi';
if b_lan = 0 then
    delete bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    delete bh_hopB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
end if;
delete bh_hopB_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hopB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BAO_NV_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_HOPB_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Nam - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HOP','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_HOPB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',0,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPB_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number;
    b_dong number; cs_lke clob:='';
begin
-- Nam - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id<>0 then
    select JSON_ARRAYAGG(json_object( ma_dvi,so_id,lan,'ngay_ht' value FKH_JS_GTRIn(txt,'ngay_ht') , 'ttoan' value FKH_JS_GTRIn(txt,'ttoan'),
                                'so_hd' value FKH_JS_GTRIs(txt,'so_hd') ,'ttrang' value FKH_JS_GTRIs(txt,'ttrang') ) order by lan returning clob) into cs_lke
                              from bh_hopB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_HOPB_CHUYEN_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    b_i1 number; b_ttrang varchar2(1);
begin
-- Nam - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','HOP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
if b_so_id<>0 and b_lan>0 then
    select so_id,max(lan),ttrang into b_so_id,b_i1,b_ttrang from bh_hopB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_id,ttrang;
    if b_lan < b_i1 then b_loi:='loi:Bao gia cu khong duoc tao hop dong:loi'; raise PROGRAM_ERROR; end if; 
    if b_ttrang <> 'D'  then b_loi:='loi:Bao gia chua duoc duyet:loi'; raise PROGRAM_ERROR; end if;
end if;
select json_object('lan' value b_lan) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
