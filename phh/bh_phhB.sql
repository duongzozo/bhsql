create or replace function FBH_PHHB_DVI(
	b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan - Tra dvi rui ro
select min(ten) into b_kq from bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
return b_kq;
end;
/
create or replace function FBH_PHHB_SO_HD(b_ma_dvi varchar2,b_so_id number) return varchar2
as
    b_kq varchar2(50);
begin
-- Dan - Tra so hop dong
select min(so_hd) into b_kq from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace function FBH_PHHB_SO_ID(b_ma_dvi varchar2,b_so_hd varchar2,b_nv varchar2:='') return number
as
    b_kq number;
begin
-- Dan - Tra so id
if nvl(b_nv,' ')=' ' then 
    select nvl(min(so_id),0) into b_kq from bh_phhB where ma_dvi=b_ma_dvi and so_hd=b_so_hd;
else 
    select nvl(min(so_id),0) into b_kq from bh_phhB where ma_dvi=b_ma_dvi and so_hd=b_so_hd and nv=b_nv;
end if;
return b_kq;
end;
/
create or replace procedure PBH_PHHB_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10);
    b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngay_ht,nv,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_nv,b_klk,b_tu,b_den using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from bh_phhB where ma_dvi=b_ma_dvi and 
        ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,lan,nsd) returning clob) into cs_lke from
        (select  ma_dvi,so_id,so_hd,nsd,lan,rownum sott from bh_phhB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PHH','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_phhB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,lan,nsd) returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,lan,nsd,rownum sott from bh_phhB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phhB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,lan,nsd) returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,lan,nsd,rownum sott from bh_phhB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHB_LKE_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_phong varchar2(10); b_so_hd varchar2(20);
    b_so_id number; b_ngay_ht number; b_nv varchar2(1); b_klk varchar2(1); b_trangKt number; b_tu number; b_den number;
    b_trang number; b_dong number; cs_lke clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,ngay_ht,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_ngay_ht,b_nv,b_klk,b_trangKt using b_oraIn;
b_so_hd:=FBH_PHHB_SO_HD(b_ma_dvi,b_so_id);
if b_so_hd is null then b_loi:='loi:GCN, hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
if b_klk ='N' then
    select count(*) into b_dong from bh_phh
		where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_phhB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,lan,nsd) returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,lan,nsd,rownum sott from bh_phhB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and nsd=b_nsd order by so_hd)
        where sott between b_tu and b_den;
elsif b_klk='P' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'BH','PHH','X')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    select count(*) into b_dong from bh_phhB where ma_dvi=b_ma_dvi and
        ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_phhB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,lan,nsd) returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,lan,nsd,rownum sott from bh_phhB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv and phong=b_phong order by so_hd)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from bh_phhB where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_hd,rownum sott from bh_phhB where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where so_hd>=b_so_hd;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(ma_dvi,so_id,so_hd,lan,nsd) returning clob) into cs_lke from
        (select ma_dvi,so_id,so_hd,lan,nsd,rownum sott from bh_phhB  where
            ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nv=b_nv order by so_hd)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHB_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_so_id number; b_so_hd varchar2(20);b_nv varchar2(10);
    b_lenh varchar2(2000); b_loi varchar2(100);
begin
-- Dan - Hoi so ID qua so hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_hd,nv');
EXECUTE IMMEDIATE b_lenh into b_so_hd,b_nv using b_oraIn;
b_so_id:=FBH_PHHB_SO_ID(b_ma_dvi,b_so_hd,b_nv);
if b_so_id=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHB_XOA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh varchar2,b_lan number,b_loi out varchar2)
AS
    b_i1 number; b_nsdC varchar2(20);
begin
-- Dan - Xoa
b_loi:='loi:Loi xu ly PBH_PHHB_XOA_XOA:loi';
select count(*) into b_i1 from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>0 then
  select nsd into b_nsdC from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
  if b_nsdC<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
end if;
select count(*) into b_i1 from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_loi:='loi:Khong sua, xoa bao gia da chuyen sang GCN, hop dong:loi'; return; end if;
b_loi:='loi:Loi xoa Table bh_phhB:loi';
-- viet anh -- bo xoa bh_phhB_txt o NH_NH, them o XOA_XOA
if b_lan = 0 then
    delete bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    delete bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan;
end if;
delete bh_phhB_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_phhB_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_BAO_NV_XOA(b_ma_dvi,b_nsd,b_so_id,b_nh,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PHHB_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PHH','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
--delete bh_phhB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id;
PBH_PHHB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'X',0,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHB_HDBS(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number;
    b_dong number; cs_lke clob:='';
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id using b_oraIn;
if b_so_id<>0 then
    select JSON_ARRAYAGG(json_object( ma_dvi,so_id,lan,'ngay_ht' value FKH_JS_GTRIn(txt,'ngay_ht') , 'ttoan' value FKH_JS_GTRIn(txt,'ttoan'),
        'so_hd' value FKH_JS_GTRIs(txt,'so_hd') ,'ttrang' value FKH_JS_GTRIs(txt,'ttrang') ) order by lan returning clob) into cs_lke
        from bh_phhB_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHBH_CTBG(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_i1 number;
    b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    dt_ct clob; dt_dkbs clob; dt_lt clob; dt_dk clob; dt_hu clob; 
    ds_ct clob; ds_dk clob; ds_dkbs clob:=''; ds_pvi clob;
    ds_lt clob:=''; ds_dkth clob; ds_kbt clob:=''; ds_ttt clob:=''; dt_kytt clob;

begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
select count(1) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
if b_i1 > 0 then
  select txt into dt_ct from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_ct';
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dkbs';
  if b_i1=1 then
      select txt into dt_dkbs from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dkbs';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
  if b_i1=1 then
      select txt into dt_lt from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_lt';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dk';
  if b_i1=1 then
      select txt into dt_dk from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_dk';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hu';
  if b_i1=1 then
      select txt into dt_hu from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_hu';
  end if;
  select txt into ds_ct from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ct';
  select txt into ds_dk from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dk';
  select txt into ds_pvi from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_pvi';
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkbs';
  if b_i1=1 then
      select txt into ds_dkbs from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkbs';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_lt';
  if b_i1=1 then
      select txt into ds_lt from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_lt';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkth';
  if b_i1=1 then
      select txt into ds_dkth from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_dkth';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_kbt';
  if b_i1=1 then
      select txt into ds_kbt from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_kbt';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
  if b_i1=1 then
      select txt into ds_ttt from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='ds_ttt';
  end if;
  select count(*) into b_i1 from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
  if b_i1<>0 then
      select txt into dt_kytt from bh_phhB_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and lan=b_lan and loai='dt_kytt';
  end if;
end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,
    'dt_ct' value dt_ct,'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'dt_lt' value dt_lt,'dt_hu' value dt_hu,
    'ds_ct' value ds_ct,'ds_dk' value ds_dk,'ds_dkbs' value ds_dkbs,'ds_pvi' value ds_pvi,
    'ds_lt' value ds_lt,'ds_dkth' value ds_dkth,
    'ds_kbt' value ds_kbt,'ds_ttt' value ds_ttt,'dt_kytt' value dt_kytt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PHHB_CHUYEN_HD(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_ma_dvi varchar2(10); b_so_id number; b_lan number;
    b_i1 number; b_ttrang varchar2(1);
begin
-- Dan - Liet ke sua doi bo sung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,so_id,lan');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_so_id,b_lan using b_oraIn;
if b_so_id<>0 and b_lan>0 then
    select so_id,max(lan),ttrang into b_so_id,b_i1,b_ttrang from bh_phhB where ma_dvi=b_ma_dvi and so_id=b_so_id group by so_id,ttrang;
    if b_lan < b_i1 then b_loi:='loi:Bao gia cu khong duoc tao hop dong:loi'; raise PROGRAM_ERROR; end if;
    if b_ttrang <> 'D'  then b_loi:='loi:Bao gia chua duoc duyet:loi'; raise PROGRAM_ERROR; end if;
end if;
select json_object('lan' value b_lan) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;