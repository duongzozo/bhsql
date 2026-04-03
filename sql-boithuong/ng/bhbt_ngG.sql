create or replace function FBH_BT_NG_CHOc(b_ma_dvi varchar2,b_so_id number) return clob
AS
    b_kq clob:=''; b_i1 number;
begin
-- Dan - Tra dieu kien cho cua Ca nhan
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_cho';
if b_i1=1 then
    select txt into b_kq from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_cho';
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_NG_CHOc(
    b_ma_dvi varchar2,b_so_id number,dt_cho out clob,dt_bvi out clob,dt_hk out clob)
AS
    b_i1 number;
begin
-- Dan - Tra dieu kien cho cua Ca nhan
dt_cho:=''; dt_bvi:=''; dt_hk:='';
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_cho';
if b_i1=1 then
    select txt into dt_cho from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_cho';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
if b_i1=1 then
    select txt into dt_bvi from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1=1 then
    select txt into dt_hk from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
end;
/
create or replace function FBH_BT_NG_CHOg(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return clob
AS
    b_kq clob:=''; b_i1 number;
begin
-- Dan - Tra dieu kien cho cua Gia dinh
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_cho';
if b_i1=1 then
    select txt into b_kq from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_cho';
end if;
return b_kq;
end;
/
create or replace procedure PBH_BT_NG_CHOg(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,dt_cho out clob,dt_bvi out clob,dt_hk out clob)
AS
    b_lenh varchar2(1000); b_txt clob; b_i1 number;
    dt_nh_ct pht_type.a_clob; dt_nh_cho pht_type.a_clob; dt_nh_bvi pht_type.a_clob;
begin
-- Dan - Tra dieu kien cho cua gia dinh
dt_cho:=''; dt_bvi:=''; dt_hk:='';
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_hk';
if b_i1 = 1 then
   select txt into dt_hk from bh_sk_kbt  where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_hk';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_cho';
if b_i1 = 1 then
   select txt into dt_cho from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_cho';
end if;
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_bvi';
if b_i1 = 1 then
   select txt into dt_bvi from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and loai='dt_bvi';
end if;
end;
/
create or replace function FBH_BT_NG_CHOt(b_ma_dvi varchar2,b_so_id number,b_so_id_dt number) return clob
AS
    b_kq clob:=''; b_lenh varchar2(1000); b_nhom varchar2(10); b_txt clob;
    dt_nh_ct pht_type.a_clob; dt_nh_cho pht_type.a_clob;
begin
-- Dan - Tra dieu kien cho cua To chuc
select nvl(min(nhom),' ') into b_nhom from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
select txt into b_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
b_txt:=FKH_JS_BONH(b_txt); b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_cho');
EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_cho using b_txt;
for b_lp in 1..dt_nh_ct.count loop
    if FKH_JS_GTRIs(dt_nh_ct(b_lp),'nhom')=b_nhom then
        b_kq:=dt_nh_cho(b_lp); exit;
    end if;
end loop;
return b_kq;
end;
/
create or replace procedure PBH_BT_NG_CHOt(
    b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,dt_cho out clob,dt_bvi out clob)
AS
    b_lenh varchar2(1000); b_nhom varchar2(10); b_txt clob;
    dt_nh_ct pht_type.a_clob; dt_nh_cho pht_type.a_clob; dt_nh_bvi pht_type.a_clob;
begin
-- Dan - Tra dieu kien cho cua To chuc
dt_cho:=''; dt_bvi:='';
select nvl(min(nhom),' ') into b_nhom from bh_sk_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
select txt into b_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
b_txt:=FKH_JS_BONH(b_txt); b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_cho,dt_nh_bvi');
EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_cho,dt_nh_bvi using b_txt;
for b_lp in 1..dt_nh_ct.count loop
    if FKH_JS_GTRIs(dt_nh_ct(b_lp),'nhom')=b_nhom then
        dt_cho:=dt_nh_cho(b_lp); dt_bvi:=dt_nh_bvi(b_lp); exit;
    end if;
end loop;
end;
/
create or replace procedure PBH_BT_NG_CHOtd(
    b_ma_dvi varchar2,b_so_id number,dt_hk out clob,dt_cho out clob,dt_bvi out clob )
AS
    b_i1 number;
begin
-- Dan - Tra dieu kien cho cua tin dung
select count(*) into b_i1 from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1 = 1 then
   select txt into dt_hk from bh_ngtd_txt  where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select count(*) into b_i1 from bh_ngtd_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_cho';
if b_i1 = 1 then
   select txt into dt_cho from bh_ngtd_kbt  where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_cho';
end if;
select count(*) into b_i1 from bh_ngtd_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
if b_i1 = 1 then
   select txt into dt_bvi from bh_ngtd_kbt  where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
end if;
end;
/
create or replace procedure PBH_BT_NG_CHOdl(
    b_ma_dvi varchar2,b_so_id number,dt_hk out clob,dt_cho out clob,dt_bvi out clob )
AS
    b_i1 number;
begin
-- viet anh - Tra dieu kien cho cua du lich
select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
if b_i1 = 1 then
   select txt into dt_hk from bh_ngdl_txt  where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
end if;
select count(*) into b_i1 from bh_ngdl_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
if b_i1 = 1 then
   select txt into dt_bvi from bh_ngdl_kbt  where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_bvi';
end if;
end;
/
create or replace procedure PBH_BT_NG_GCN(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(1000); b_gcn varchar2(20); b_nhom varchar2(10);
    b_ma_dvi varchar2(10); b_so_id number:=0; b_so_id_dt number;b_nv varchar2(10); b_ngay_xr number; b_so_id_dtN number; b_tpa nvarchar2(500);
    dt_nh_ct pht_type.a_clob; dt_nh_dk pht_type.a_clob; dt_nh_dkbs pht_type.a_clob; dt_ds_nhom pht_type.a_var; dt_nh_cho pht_type.a_clob; dt_nh_bvi pht_type.a_clob;
    dt_ct clob;dt_ct_txt clob:=''; dt_nhom_txt clob:=''; dt_ds_txt clob:=''; dt_kbt clob:=''; dt_btlke clob:=''; dt_dk clob; dt_dkbs clob; dt_lt clob:=''; dt_txt clob;
    dt_hk clob:=''; dt_cho clob:=''; dt_bvi clob:=''; b_txt clob;
    b_nh_nhom varchar2(10); b_ds_nhom varchar2(10); b_dt_nhom varchar2(10); b_noidi nvarchar2(4000); b_noiden nvarchar2(4000);
    dt_dk_ct pht_type.a_clob;b_dk_ma varchar2(20); b_dk_tien number;
begin
-- Dan - Liet ke theo GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('gcn,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_gcn,b_ngay_xr using b_oraIn;
b_loi:='loi:GCN da xoa hoac chua duyet:loi';
FBH_NG_HD_SO_ID_DT(b_gcn,b_ngay_xr,b_ma_dvi,b_so_id,b_so_id_dt);
if b_so_id=0 then b_loi:='loi:GCN da xoa hoac chua duyet:loi'; raise PROGRAM_ERROR; end if;
b_nv:=FBH_NG_NV(b_ma_dvi,b_so_id);
if b_nv='SKC' then
    select json_object('gcn' value b.gcn,b.ten,b.ngay_hl,b.ngay_kt,'ma_dvi_ql' value b.ma_dvi,a.so_hd,
        'lhe_ten' value b.ten,'lhe_mobi' value b.mobi,'lhe_email' value b.email,'nt_tien' value nt_tien) into dt_ct
        from bh_ng a,bh_ng_ds b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=b_so_id_dt;
    PBH_BT_NG_CHOc(b_ma_dvi,b_so_id,dt_cho,dt_bvi,dt_hk);

elsif b_nv='SKG' then
    select json_object('gcn' value b.gcn,b.ten,b.ngay_hl,b.ngay_kt,'ma_dvi_ql' value b.ma_dvi,a.so_hd,
        'lhe_ten' value b.ten,'lhe_mobi' value b.mobi,'lhe_email' value b.email,'nt_tien' value nt_tien) into dt_ct
        from bh_ng a,bh_ng_ds b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=b_so_id_dt;
    PBH_BT_NG_CHOg(b_ma_dvi,b_so_id,b_so_id_dt,dt_cho,dt_bvi,dt_hk);
elsif b_nv='SKT' then
    select json_object('gcn' value b.gcn,b.ten,b.ngay_hl,b.ngay_kt,'ma_dvi_ql' value b.ma_dvi,a.so_hd,
        'lhe_ten' value b.ten,'lhe_mobi' value b.mobi,'lhe_email' value b.email,
        'luong' value FBH_BT_NG_LUONG(b.ma_dvi,b.so_id,b.so_id_dt),'nt_tien' value nt_tien, 'tpa' value FBH_DTAC_MA_TENl(a.tpa)) into dt_ct
        from bh_sk a,bh_sk_ds b where a.ma_dvi=b.ma_dvi and a.so_id=b.so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=b_so_id_dt;
    PBH_BT_NG_CHOt(b_ma_dvi,b_so_id,b_so_id_dt,dt_cho,dt_bvi);
elsif b_nv in ('DLC','DLG','DLT','TDC') then
    select json_object('gcn' value b.gcn,b.ten,b.ngay_hl,b.ngay_kt,'ma_dvi_ql' value b.ma_dvi,a.so_hd,
        'lhe_ten' value b.ten,'lhe_mobi' value b.mobi,'lhe_email' value b.email,'nt_tien' value nt_tien) into dt_ct
        from bh_ng a,bh_ng_ds b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
        b.ma_dvi=b_ma_dvi and b.so_id=b_so_id and b.so_id_dt=b_so_id_dt;
    select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
    if b_i1 > 0 then
       select txt into dt_hk from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_hk';
    end if;
    if b_nv in ('DLC','DLG') then
      select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
      if b_i1 > 0 then
         select FKH_JS_BONH(txt) into dt_ct_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
         b_lenh:=FKH_JS_LENH('noidi,noiden');
         EXECUTE IMMEDIATE b_lenh into b_noidi,b_noiden using dt_ct_txt;
         PKH_JS_THAYa(dt_ct,'noidi,noiden',b_noidi||','||b_noiden);
      end if;
        PBH_BT_NG_CHOdl(b_ma_dvi,b_so_id,dt_hk,dt_cho,dt_bvi); -- viet anh
     elsif b_nv in ('TDC') then
        select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        if b_i1 > 0 then
           select FKH_JS_BONH(txt) into dt_ct from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
        end if;
        PBH_BT_NG_CHOtd(b_ma_dvi,b_so_id,dt_hk,dt_cho,dt_bvi); -- viet anh
     else
       select nhom into b_dt_nhom from bh_ngdl_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
       select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
       if b_i1 > 0 then
         select FKH_JS_BONH(txt) into dt_nhom_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
         b_lenh:=FKH_JS_LENH('dt_nh_ct');
         EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct using dt_nhom_txt;
         for b_lp in 1..dt_nh_ct.count loop
           b_lenh:=FKH_JS_LENH('nhom,noidi,noiden');
           EXECUTE IMMEDIATE b_lenh into b_nh_nhom,b_noidi,b_noiden using dt_nh_ct(b_lp);
           if b_dt_nhom <> b_nh_nhom then continue; end if;
           -- lay nhom trong ds
           select FKH_JS_BONH(txt) into dt_ds_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
           b_lenh:=FKH_JS_LENH('nhom');
           EXECUTE IMMEDIATE b_lenh bulk collect into dt_ds_nhom using dt_ds_txt;
           for b_lp1 in 1..dt_ds_nhom.count loop
                if b_nh_nhom=dt_ds_nhom(b_lp1) then
                  PKH_JS_THAYa(dt_ct,'noidi,noiden',b_noidi||','||b_noiden); exit;
               end if;
           end loop;

         end loop;
      end if;
     end if;
end if;
select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
if b_i1=1 then
    select dk,lt,kbt into dt_dk,dt_lt,dt_kbt from bh_ng_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
end if;
if b_nv = 'SKC' then
    select count(*) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    if b_i1=1 then
      select txt into dt_dkbs from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    end if;
    select FBH_DTAC_MA_TENl(tpa) into b_tpa from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;

    PKH_JS_THAYa(dt_ct,'tpa',b_tpa);


elsif b_nv = 'SKG' then
    select count(*) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
    if b_i1=1 then
      select txt into dt_nhom_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
    end if;
    b_lenh:=FKH_JS_LENHc('dt_ds_ct,dt_ds_dk,dt_ds_dkbs');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_dk,dt_nh_dkbs using dt_nhom_txt;
    for b_lp in 1..dt_nh_ct.count loop
      b_lenh:=FKH_JS_LENH('so_id_dt');
      EXECUTE IMMEDIATE b_lenh into b_so_id_dtN using dt_nh_ct(b_lp);
      if b_so_id_dt <> b_so_id_dtN then continue; end if;
      dt_dk:=dt_nh_dk(b_lp); dt_dkbs:=dt_nh_dkbs(b_lp);
    end loop;
    select FBH_DTAC_MA_TENl(tpa) into b_tpa from bh_sk where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PKH_JS_THAYa(dt_ct,'tpa',b_tpa);
elsif b_nv = 'TDC' then
  -- viet anh
    select txt into dt_dk from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
    select count(*) into b_i1 from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    if b_i1=1 then
      select txt into dt_dkbs from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    end if;
elsif b_nv in ('DLC','DLG') then
    select txt into dt_dk from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dk';
    select count(*) into b_i1 from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    if b_i1=1 then
       select txt into dt_dkbs from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_dkbs';
    end if;
elsif b_nv = 'DLT' then
    select FKH_JS_BONH(txt) into dt_nhom_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_nh';
    b_lenh:=FKH_JS_LENHc('dt_nh_ct,dt_nh_dk,dt_nh_dkbs');
    EXECUTE IMMEDIATE b_lenh bulk collect into dt_nh_ct,dt_nh_dk,dt_nh_dkbs using dt_nhom_txt;
    for b_lp in 1..dt_nh_ct.count loop
      b_lenh:=FKH_JS_LENH('nhom');
      EXECUTE IMMEDIATE b_lenh into b_nh_nhom using dt_nh_ct(b_lp);
      if b_dt_nhom <> b_nh_nhom then continue; end if;
      dt_dk:=dt_nh_dk(b_lp); dt_dkbs:=dt_nh_dkbs(b_lp);
    end loop;
end if;
dt_btlke:=FBH_BT_NG_BTH_LKE(b_so_id_dt);
select json_object('nv' value b_nv,'dt_ct' value dt_ct,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,
    'dt_btlke' value dt_btlke,'dt_cho' value dt_cho,'dt_bvi' value dt_bvi,'dt_hk' value dt_hk,
    'dt_dk' value dt_dk,'dt_dkbs' value dt_dkbs,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_GCNd(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; 
begin
-- Dan - Tra so_id_dt qua GCN
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','NG','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
--nam lay so id_dt bo sung
FBH_NG_HD_SO_ID_DTc(b_oraIn,b_ma_dvi,b_so_id,b_so_id_dt);
select json_object('so_id_dt' value b_so_id_dt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_GCNgdk(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_gcn varchar2(20); b_ngay_xr number;
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number; b_nv varchar2(10);
begin
-- Nam - Lay dieu khoan theo gcn
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('gcn,ngay_xr');
EXECUTE IMMEDIATE b_lenh into b_gcn,b_ngay_xr using b_oraIn;
if trim(b_gcn) is null or b_ngay_xr=30000101 then
    b_loi:='loi:Nhap GCN va ngay xay ra:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:GCN '||b_gcn||' da xoa hoac chua duyet:loi';
FBH_NG_HD_SO_ID_DT(b_gcn,b_ngay_xr,b_ma_dvi,b_so_id,b_so_id_dt);
if b_so_id=0 then raise PROGRAM_ERROR; end if;
select nv into b_nv from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv in ('SKC','DLC') then
    select JSON_ARRAYAGG(json_object(ma,'tien_bh' value tien,'tien' value 0,ma_dvi,so_id,so_id_dt,'bt' value bt,ten,tc,ma_ct,kieu
    ,pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptb,ptg,phig,lkep,lkeb,luy,lh_bh) order by bt returning clob) into b_oraOut
        from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select JSON_ARRAYAGG(json_object(ma,'tien_bh' value tien,'tien' value 0,ma_dvi,so_id,so_id_dt,'bt' value bt,ten,tc,ma_ct,kieu
    ,pt,phi,cap,ma_dk,lh_nv,t_suat,thue,ttoan,ptb,ptg,phig,lkep,lkeb,luy,lh_bh) order by bt returning clob) into b_oraOut
        from bh_ng_dk where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_LKE_GCN
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_gcn varchar2(20):=FKH_JS_GTRIs(b_oraIn,'gcn'); 
    b_ma_dvi varchar2(10); b_so_id number; b_so_id_dt number;
    cs_phi clob; cs_bth clob;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','BT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_NG_HD_SO_ID_DTd(b_gcn,b_ma_dvi,b_so_id,b_so_id_dt);
FBH_BT_LKE_PHI(b_ma_dvi,b_so_id,cs_phi);
select JSON_ARRAYAGG(json_object(so_hs,ngay_mo,ttrang,tien,ma_dvi,so_id) order by ngay_mo desc)
    into cs_bth from bh_bt_ng where ma_dvi_ql=b_ma_dvi and so_id_hd=b_so_id and so_id_dt=b_so_id_dt;
select json_object('cs_phi' value cs_phi,'cs_bth' value cs_bth) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_TEST(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    dt_ct clob,dt_dk clob,dt_grv in out clob,dt_hk clob,dt_tba clob,dt_kbt out clob,dt_bvi clob,
    b_nv out varchar2,b_gcn out varchar2,b_loai_hs out varchar2,
    b_ma_dvi_ql out varchar2,b_so_hd out varchar2,b_so_id_hd out number,b_so_id_dt out number,
    b_ma_khH out varchar2,b_tenH out nvarchar2,b_ma_kh out varchar2,b_ten out nvarchar2,
    b_tienHK out number, b_ma_nn out varchar2,b_ma_dtri out varchar2,b_tpa out nvarchar2,b_so_tpa out varchar2,

    dk_ma out pht_type.a_var,dk_ten out pht_type.a_nvar,dk_tc out pht_type.a_var,dk_ma_ct out pht_type.a_var,
    dk_tien_bh out pht_type.a_num,dk_pt_bt out pht_type.a_num,dk_t_that out pht_type.a_num,
    dk_tien out pht_type.a_num,dk_thue out pht_type.a_num,dk_tien_qd out pht_type.a_num,dk_thue_qd out pht_type.a_num,
    dk_cap out pht_type.a_var,dk_ma_dk out pht_type.a_var,dk_ma_bs out pht_type.a_var,
    dk_lh_nv out pht_type.a_var,dk_t_suat out pht_type.a_num,dk_lkeB out pht_type.a_var,

    grv_ma out pht_type.a_var,grv_ten out pht_type.a_nvar,grv_so out pht_type.a_var,grv_ng_cap out pht_type.a_num,grv_tien out pht_type.a_num,
    hk_ma out pht_type.a_var,hk_ten out pht_type.a_nvar,hk_ma_nt out pht_type.a_var,
    hk_tien out pht_type.a_num,hk_thue out pht_type.a_num,
    hk_tien_qd out pht_type.a_num,hk_thue_qd out pht_type.a_num,
    tba_ten out pht_type.a_nvar,tba_ma_nt out pht_type.a_var,tba_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_ktraHL varchar2(1):='K';
    b_so_id_hdB number; b_tg number; b_nt_tien varchar2(5);
    b_ttrang varchar2(1); b_ngay_xr number; b_ngay_gr number; b_ngay_hl number; b_noP varchar2(1); b_tien number;
    b_kho number; b_so_ngay number; cho_tle varchar2(1);
    dk_bt_con pht_type.a_num; dk_choC pht_type.a_var; dk_cho pht_type.a_num; dk_cho_tl pht_type.a_var;
begin
-- Dan kiem tra thong tin nhap ho so boi thuong
b_lenh:=FKH_JS_LENH('ttrang,gcn,ngay_xr,ngay_gr,ngay_hl,nop,ma_nn,ma_dtri,nt_tien,loai_hs,tpa,so_tpa');
EXECUTE IMMEDIATE b_lenh into b_ttrang,b_gcn,b_ngay_xr,b_ngay_gr,b_ngay_hl,b_noP,b_ma_nn,b_ma_dtri,b_nt_tien,b_loai_hs,b_tpa,b_so_tpa using dt_ct;
b_tpa:=PKH_MA_TENl(b_tpa);
b_kho:=nvl(FKH_KHO_NGSO(b_ngay_hl,b_ngay_xr),0)+1;
if b_gcn=' ' then b_loi:='loi:Nhap so GCN:loi'; return; end if;
if b_loai_hs not in('T','B','A') then b_loi:='loi:Sai loai ho so:loi'; return; end if;
if b_loai_hs='A' then
    if b_tpa=' ' then
        b_loi:='loi:Nhap TPA:loi'; return;
    elsif FBH_MA_GDINH_NV(b_tpa,'NG')<>'C' or FBH_DTAC_MA_HAN(b_tpa)='K' then
        b_loi:='loi:Sai ma TPA:loi'; return;
    end if;
end if;
FBH_NG_HD_SO_ID_DTc(b_gcn,b_ma_dvi_ql,b_so_id_hd,b_so_id_dt);
if b_so_id_hd=0 then b_loi:='loi:Hop dong chua duyet hoac da xoa:loi'; return; end if;
select nv into b_nv from bh_ng where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hd;
b_so_id_hdB:=FBH_NG_SO_IDb(b_ma_dvi_ql,b_so_id_hd,b_ngay_xr);
select so_hd,ma_kh,ten into b_so_hd,b_ma_kh,b_ten from bh_ng where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB;
b_lenh:=FKH_JS_LENH('ma,ten,tc,ma_ct,tien_bh,pt_bt,t_that,tien,cap,ma_dk,ma_bs,lh_nv,t_suat,lkeb,bt_con,cho,cho_tle');
EXECUTE IMMEDIATE b_lenh bulk collect into
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_lkeB,dk_bt_con,dk_choC,dk_cho_tl using dt_dk;
if dk_ma.count=0 then b_loi:='loi:Nhap dieu khoan:loi'; return; end if;
b_tg:=FBH_TT_TRA_TGTT(b_ngay_xr,b_nt_tien);
b_tien:=0;
for b_lp in 1..dk_ma.count loop
    dk_thue(b_lp):=0; dk_thue_qd(b_lp):=0;
    if b_nt_tien='VND' then
        dk_tien_qd(b_lp):=dk_tien(b_lp);
    else
        dk_tien_qd(b_lp):=round(b_tg*dk_tien(b_lp),0);
    end if;
    if trim(dk_lh_nv(b_lp)) is not null then
        b_tien:=b_tien+dk_tien(b_lp);
    end if;
    if trim(dk_choC(b_lp)) is not null then dk_cho(b_lp):=TO_NUMBER(trim(dk_choC(b_lp))); else dk_cho(b_lp):=0;  end if;
end loop;
b_lenh:=FKH_JS_LENH('ma,ten,so_grv,ng_cap,tien');
EXECUTE IMMEDIATE b_lenh bulk collect into grv_ma,grv_ten,grv_so,grv_ng_cap,grv_tien using dt_grv;
for b_lp in 1..grv_ten.count loop
    grv_ma(b_lp):=nvl(trim(grv_ma(b_lp)),' '); grv_so(b_lp):=nvl(trim(grv_so(b_lp)),' '); grv_ng_cap(b_lp):=nvl(trim(grv_ng_cap(b_lp)),0); 
    if grv_ten(b_lp)=' ' or grv_so(b_lp)=' ' or grv_ng_cap(b_lp)=0 then
        b_loi:='loi:Giay ra vien can nhap du: ma benh vien, so CT, ngay cap:loi'; return;
    end if;
    select count(*) into b_i1 from bh_bt_ng_grv where ma=grv_ten(b_lp) and so=grv_so(b_lp) and ng_cap=grv_ng_cap(b_lp);
    if b_i1<>0 then b_loi:='loi:Trung giay ra vien: '||grv_so(b_lp)||':loi'; return; end if;
end loop;
b_tienHK:=0;
if trim(dt_hk) is null then
    PKH_MANG_KD(hk_ma_nt);
else
    b_lenh:=FKH_JS_LENH('ma,ten,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect into hk_ma,hk_ten,hk_tien using dt_hk;
    for b_lp in 1..hk_ten.count loop
        hk_ma(b_lp):=nvl(trim(hk_ma(b_lp)),to_char(b_lp));
        hk_ma_nt(b_lp):=b_nt_tien; hk_thue(b_lp):=0; hk_thue_qd(b_lp):=0;
        b_tienHK:=b_tienHK+hk_tien(b_lp);
        if b_nt_tien='VND' then
            hk_tien_qd(b_lp):=hk_tien(b_lp);
        else
            hk_tien_qd(b_lp):=round(b_tg*hk_tien(b_lp),0);
        end if;
    end loop;
end if;
if trim(dt_tba) is null then
    PKH_MANG_KD(tba_ma_nt);
else
    b_lenh:=FKH_JS_LENH('ten,ma_nt,tien');
    EXECUTE IMMEDIATE b_lenh bulk collect into tba_ten,tba_ma_nt,tba_tien using dt_tba;
    for b_lp in 1..tba_ma_nt.count loop
        tba_ma_nt(b_lp):=nvl(trim(tba_ma_nt(b_lp)),'VND');
    end loop;
end if;
dt_kbt:='';
if b_ttrang in('T','D') then
    if b_tien<b_tienHK then b_loi:='loi:Tien ho so nho hon tien huong khac:loi'; return; end if;
    for b_lp in 1..dk_ma.count loop
        if dk_bt_con(b_lp)<0 then
            b_loi:='loi:Dieu khoan '||dk_ma(b_lp)||' boi thuong vuot muc trach nhiem :loi'; return;
        end if;
        -- thoi gian cho
        b_so_ngay:=nvl(dk_cho(b_lp),0); cho_tle:=nvl(dk_cho_tl(b_lp),' ');
        if b_so_ngay > 0 and b_kho - b_so_ngay <= 0 and cho_tle <> 'C' and substr(b_nv, 1, 2) IN ('SK', 'TD') then -- viet anh
           b_loi:='loi:Dieu khoan: ' || dk_ma(b_lp) || ' - thoi gian cho: ' || b_so_ngay || ':loi'; return;
        end if;
    end loop;
    --if b_noP='K' and FBH_HD_HOI_NOPHI(b_ma_dvi_ql,b_so_id_hd)='C' then
    --    b_loi:='loi:Khach hang con no phi:loi'; return;
    --end if;
    select count(*) into b_i1 from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
    if b_i1<>0 then
        select kbt into dt_kbt from bh_ng_kbt where ma_dvi=b_ma_dvi_ql and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt;
    end if;
    dt_kbt:=FKH_JS_BONH(dt_kbt);
    if b_ngay_gr is null or b_ngay_gr in(0,30000101) then b_ngay_gr:=b_ngay_xr; end if;
    select count(*) into b_i1 from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id_hdB and so_id_dt=b_so_id_dt and
        (b_ngay_xr not between ngay_hl and ngay_kt or b_ngay_gr not between ngay_hl and ngay_kt);
    if b_i1<>0 then
        if trim(dt_kbt) is null then b_loi:='loi:Ngay xay ra ngoai ngay hieu luc:loi'; return; end if;
        b_ktraHL:='C';
    end if;
    PBH_BT_NG_KBT(b_ma_dvi_ql,b_so_id_hd,b_so_id_dt,b_ktraHL,dt_ct,dt_dk,dt_kbt,b_loi);
    if b_loi is not null then return; end if;
end if;
-- chuclh - bo sung kiem tra cau hinh bvi
if b_ttrang = 'D' and dt_grv <> ' ' then
   PBH_BT_NG_BVI(b_ma_dvi,b_nsd,b_so_id_hd,b_so_id_dt,dt_grv,dt_dk,b_loi);
   if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_BT_NG_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); b_i1 number; b_ngay_htC number; b_ma_dviC varchar2(20);
    dt_ct clob; dt_dk clob; dt_grv clob; dt_hk clob; dt_tba clob; dt_kbt clob; dt_tltt clob;
    dt_tlpt clob; dt_ttt clob; dt_bvi clob;

    b_so_id number; b_ngay_ht number; b_nv varchar2(10); b_so_hs varchar2(30); b_ttrang varchar2(1);
    b_kieu_hs varchar2(1); b_so_hs_g varchar2(20); b_phong varchar2(10);
    b_ngay_gui number; b_ngay_mo number; b_ngay_do number; b_ngay_xr number;
    b_n_trinh varchar2(200); b_n_duyet varchar2(200); b_ngay_qd number;
    b_nt_tien varchar2(5); b_c_thue varchar2(1); b_tien number; b_thue number;
    b_noP varchar2(1); b_bphi varchar2(1); b_dung varchar2(1); b_traN varchar2(1);
    b_gcn varchar2(20); b_ma_dvi_ql varchar2(10); b_so_hd varchar2(20); b_so_id_hd number; b_so_id_dt number;
    b_ma_khH varchar2(20); b_tenH nvarchar2(500); b_ma_kh varchar2(20); b_ten nvarchar2(500); 
    b_tienHK number; b_ma_nn varchar2(10); b_ma_dtri varchar2(10); b_loai_hs varchar2(1); b_tpa nvarchar2(500); b_so_tpa varchar2(20);

    dk_ma pht_type.a_var; dk_ten pht_type.a_nvar; dk_tc pht_type.a_var; dk_ma_ct pht_type.a_var;
    dk_tien_bh pht_type.a_num; dk_pt_bt pht_type.a_num; dk_t_that pht_type.a_num;
    dk_tien pht_type.a_num; dk_thue pht_type.a_num; dk_tien_qd pht_type.a_num; dk_thue_qd pht_type.a_num;
    dk_cap pht_type.a_var; dk_ma_dk pht_type.a_var; dk_ma_bs pht_type.a_var;
    dk_lh_nv pht_type.a_var; dk_t_suat pht_type.a_num; dk_lkeB pht_type.a_var;

    grv_ma pht_type.a_var; grv_ten pht_type.a_nvar; grv_so pht_type.a_var; grv_ng_cap pht_type.a_num; grv_tien pht_type.a_num;
    hk_ma pht_type.a_var; hk_ten pht_type.a_nvar; hk_ma_nt pht_type.a_var;
    hk_tien pht_type.a_num; hk_thue pht_type.a_num; hk_tien_qd pht_type.a_num; hk_thue_qd pht_type.a_num;
    tba_ten pht_type.a_nvar; tba_ma_nt pht_type.a_var; tba_tien pht_type.a_num;
    r_hs bh_bt_ng%rowtype;

begin
-- Dan - Nhap ho so boi thuong
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','BT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('so_id');
EXECUTE IMMEDIATE b_lenh into b_so_id using b_oraIn;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_grv,dt_tltt,dt_tlpt,dt_hk,dt_tba,dt_ttt,dt_bvi');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_grv,dt_tltt,dt_tlpt,dt_hk,dt_tba,dt_ttt,dt_bvi using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_grv); FKH_JSa_NULL(dt_tltt); FKH_JSa_NULL(dt_tba);
FKH_JSa_NULL(dt_tlpt); FKH_JSa_NULL(dt_hk); FKH_JSa_NULL(dt_ttt); FKH_JSa_NULL(dt_bvi);
if b_so_id<>0 then
    select count(*) into b_i1 from bh_bt_ng where so_id=b_so_id;
    if b_i1=0 then b_so_id:=0; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    b_loi:='loi:Ho so dang xu ly:loi';
    -- chuclh: theo don vi hsbt
    select ma_dvi,ngay_ht into b_ma_dviC,b_ngay_htC from bh_bt_ng where so_id=b_so_id for update nowait;
    if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
    PBH_BT_NG_XOA_XOA(b_ma_dviC,b_nsd,b_so_id,true,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_BT_TEST(b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,dt_ct,
    b_ngay_ht,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_phong,b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,
    b_n_trinh,b_n_duyet,b_ngay_qd,b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_NG_TEST(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_grv,dt_hk,dt_tba,dt_kbt,dt_bvi,
    b_nv,b_gcn,b_loai_hs,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_dt,
    b_ma_khH,b_tenH,b_ma_kh,b_ten,b_tienHK,b_ma_nn,b_ma_dtri,b_tpa,b_so_tpa,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_lkeB,
    grv_ma,grv_ten,grv_so,grv_ng_cap,grv_tien,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_BT_NG_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,dt_ct,dt_dk,dt_grv,dt_hk,dt_tba,dt_kbt,dt_tltt,dt_tlpt,dt_ttt,dt_bvi,
    b_ngay_ht,b_nv,b_so_hs,b_ttrang,b_kieu_hs,b_so_hs_g,b_loai_hs,'C',b_phong,
    b_ngay_gui,b_ngay_mo,b_ngay_do,b_ngay_xr,b_n_trinh,b_n_duyet,b_ngay_qd,
    b_nt_tien,b_c_thue,b_tien,b_thue,b_noP,b_bphi,b_dung,b_traN,
    b_gcn,b_ma_dvi_ql,b_so_hd,b_so_id_hd,b_so_id_dt,
    b_ma_khH,b_tenH,b_ma_kh,b_ten,b_tienHK,b_ma_nn,b_ma_dtri,b_tpa,b_so_tpa,
    dk_ma,dk_ten,dk_tc,dk_ma_ct,dk_tien_bh,dk_pt_bt,dk_t_that,
    dk_tien,dk_thue,dk_tien_qd,dk_thue_qd,dk_cap,dk_ma_dk,dk_ma_bs,dk_lh_nv,dk_t_suat,dk_lkeB,
    grv_ma,grv_ten,grv_so,grv_ng_cap,grv_tien,
    hk_ma,hk_ten,hk_ma_nt,hk_tien,hk_thue,hk_tien_qd,hk_thue_qd,
    tba_ten,tba_ma_nt,tba_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hs' value b_so_hs) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_BT_NG_BVI(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id_hd number,b_so_id_dt number,dt_grv clob,dt_dk clob,b_loi out varchar2)
as
    b_lenh varchar2(2000); b_i1 number; b_txt clob;
    b_ma_bvi varchar2(500); b_ten_bv varchar2(500); b_dgia number;
    dt_grv_bvi pht_type.a_var;
    bvi_ma pht_type.a_var; bvi_bth pht_type.a_var; bvi_dct pht_type.a_num; bvi_blanh pht_type.a_var;
    dt_bvi_txt clob; dt_ma_phi pht_type.a_var; dt_bvi_phi pht_type.a_var;
    bvi_ma_phi pht_type.a_var; bvi_ten_phi pht_type.a_var; bvi_bth_phi pht_type.a_var; bvi_dct_phi pht_type.a_num; bvi_blanh_phi pht_type.a_var;
    dk_ma pht_type.a_var;dk_tien pht_type.a_num;
begin
-- Dan - Kiem soat dieu kien rieng
select count(*) into b_i1 from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and loai='dt_bvi';
if b_i1 > 0 then
  select FKH_JS_BONH(txt) into dt_bvi_txt from bh_sk_kbt where ma_dvi=b_ma_dvi and so_id=b_so_id_hd and so_id_dt=b_so_id_dt and loai='dt_bvi';
  b_lenh:=FKH_JS_LENH('ten');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_grv_bvi using dt_grv;
  b_lenh:=FKH_JS_LENH('ma,bvi');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_ma_phi,dt_bvi_phi using dt_bvi_txt;
  b_lenh:=FKH_JS_LENH('ma,tien');
  EXECUTE IMMEDIATE b_lenh bulk collect into dk_ma,dk_tien using dt_dk;
  --nam: kiem tra ma benh vien
  for b_lp in 1..dt_grv_bvi.count loop
    select count(*) into b_i1 from bh_ma_bv where ma=dt_grv_bvi(b_lp);
    if b_i1=0 then b_loi:='loi:Sai ma benh vien '||dt_grv_bvi(b_lp)||':loi'; return; end if;
  end loop;
  for b_lp in 1..dk_ma.count loop
    if dk_tien(b_lp) <=0 then continue; end if;
    b_i1 := FKH_ARR_VTRI(dt_ma_phi,dk_ma(b_lp));
    if b_i1 > 0 then
      for b_lp1 in 1..dt_ma_phi.count loop
          -- dieu khoan duoc boi thuong
          if dk_ma(b_lp) = dt_ma_phi(b_lp1) then
           b_lenh:=FKH_JS_LENH('ma,bth');
           EXECUTE IMMEDIATE b_lenh bulk collect into bvi_ma_phi,bvi_bth_phi using dt_bvi_phi(b_lp1);
           for b_lp2 in 1..bvi_ma_phi.count loop
              b_ma_bvi:=PKH_MA_TENl(bvi_ma_phi(b_lp2)); b_ten_bv:=PKH_TEN_TENl(bvi_ma_phi(b_lp2));
              -- khong trung benh vien
              b_i1 := FKH_ARR_VTRI(dt_grv_bvi,b_ma_bvi);
              if b_i1 <= 0 then
                b_dgia:=FBH_NG_BVI_DGIA(b_ma_bvi);
                if FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'BT_CSYT',b_dgia,'NB')='C' and b_dgia > 3 then
                   b_loi:='loi:Benh vien '||b_ten_bv||' thuoc phan loai xau/rat xau:loi'; return;
                end if;
              elsif  bvi_bth_phi(b_lp2)<>'C' then 
                b_loi:='loi:Khong duoc boi thuong benh vien: '||b_ten_bv||':loi'; return;
              end if;
           end loop;
          end if; 
      end loop;
    else 
      -- dieu khoan chung
      b_i1 := FKH_ARR_VTRI(dt_ma_phi,'--');
      if b_i1 > 0 then
        b_lenh:=FKH_JS_LENH('ma,bth');
           EXECUTE IMMEDIATE b_lenh bulk collect into bvi_ma_phi,bvi_bth_phi using dt_bvi_phi(b_i1);
        for b_lp1 in 1..bvi_ma_phi.count loop
            -- khong trung benh vien
            b_ma_bvi:=PKH_MA_TENl(bvi_ma_phi(b_lp1)); b_ten_bv:=PKH_TEN_TENl(bvi_ma_phi(b_lp1));
            bvi_ma_phi(b_lp1):=b_ma_bvi; bvi_ten_phi(b_lp1):=b_ten_bv;
        end loop;
      end if;
       
      for b_lp1 in 1..dt_grv_bvi.count loop
        -- khong trung benh vien
        b_i1 := FKH_ARR_VTRI(bvi_ma_phi,dt_grv_bvi(b_lp1));
        if b_i1 <= 0 then
          b_dgia:=FBH_NG_BVI_DGIA(dt_grv_bvi(b_lp1));
          if FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'BT_CSYT',b_dgia,'NB')='C' and b_dgia > 3 then
             select ten into b_ten_bv from bh_ma_bv where ma=dt_grv_bvi(b_lp1);
             b_loi:='loi:Benh vien '||b_ten_bv||' thuoc phan loai xau/rat xau:loi'; return;
          end if;
        elsif bvi_bth_phi(b_i1)<>'C' then 
          b_loi:='loi:Khong duoc boi thuong benh vien: '||bvi_ten_phi(b_i1)||':loi'; return;
        end if;
      end loop;
    end if;
   end loop;
else
  -- khong cau hinh csyt
  b_lenh:=FKH_JS_LENH('ten');
  EXECUTE IMMEDIATE b_lenh bulk collect into dt_grv_bvi using dt_grv;
  for b_lp in 1..dt_grv_bvi.count loop
    b_dgia:=FBH_NG_BVI_DGIA(dt_grv_bvi(b_lp));
     select ten into b_ten_bv from bh_ma_bv where ma=dt_grv_bvi(b_lp);
    if FBH_PQU_KTRA_KHs(b_ma_dvi,b_nsd,'BT_CSYT',b_dgia,'NB')='C' and b_dgia > 3 then
      b_loi:='loi:Benh vien '||b_ten_bv||' thuoc phan loai xau/rat xau:loi'; return;
    end if;
  end loop;
end if;
b_loi:='';
end;
/
create or replace function FBH_NG_BVI_DGIA(b_ma_bvi varchar2) return number
AS
     b_lenh varchar2(2000);b_i1 number; b_kq number:=0; b_dgia varchar2(1); b_txt clob;
begin
-- chuclh dgia bvi
if b_ma_bvi <> ' ' then
   select count(1) into b_i1 from bh_ma_bv a, bh_dtac_ma_txt b where a.ma=b.ma and a.ma=b_ma_bvi;
   if b_i1 <=0 then return 0; end if;
   select txt into b_txt from bh_ma_bv a, bh_dtac_ma_txt b where a.ma=b.ma and a.ma=b_ma_bvi;
   b_lenh:=FKH_JS_LENH('dgia');
   EXECUTE IMMEDIATE b_lenh into b_dgia using b_txt;
   b_kq:=nvl(to_number(b_dgia),0);
end if;
return b_kq;
end;
/