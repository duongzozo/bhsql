
drop procedure PBH_IN_TBTP;
/
create or replace procedure PBH_IN_TBTP(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100);b_lenh varchar2(1000);b_bang varchar2(50);
    -- bien tam
    b_tong_ky number;
    -- truong out
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');

    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');

    dt_ct clob; dt_dv clob; dt_tt clob;
    b_count number := 0;b_i1 number;
    b_so_id_g number;b_kieu_hd varchar2(10);
    b_nt_tien varchar2(10);
     -- nv
    b_nv varchar2(10);b_nv_ng varchar2(10);
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

--check theo nv
select count(*) into b_count from bh_hd_goc where so_id = b_so_id and ma_dvi = b_ma_dvi;
if b_count = 0 then
  b_loi:=N'loi:Hợp đồng chưa được trình duyệt:loi';
  raise_application_error(-20105,b_loi);
end if;

select nv,kieu_hd,so_id_g into b_nv,b_kieu_hd,b_so_id_g from bh_hd_goc where so_id = b_so_id and ma_dvi = b_ma_dvi;
if b_so_id_g = 0 then b_so_id_g:= b_so_id;end if;
  if b_nv='PHH' then
    -- phh
    select count(*) into b_count from bh_phh_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_phh_txt where so_id = b_so_id and loai='dt_ct';
    end if;
  --end phh
  elsif b_nv='PKT' then
    -- pkt
    select count(*) into b_count from bh_pkt_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_pkt_txt where so_id = b_so_id and loai='dt_ct';
    end if;
  --end pkt
  elsif b_nv='XE' then
    -- xe
    select count(*) into b_count from bh_xe_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_xe_txt where so_id = b_so_id and loai='dt_ct';
    end if;
  --end xe
  elsif b_nv='NG' then
    select count(*) into b_i1 from bh_ng where ma_dvi =b_ma_dvi and so_id = b_so_id;
    if b_i1> 0  then
      select nv into b_nv_ng from bh_ng where ma_dvi =b_ma_dvi and so_id = b_so_id;
      if b_nv_ng in ('SKG','SKT','SKC') then
        -- nguoi sk
        select count(*) into b_count from bh_sk_txt where so_id=b_so_id and loai='dt_ct';
        if b_count <> 0 then
          select txt into dt_ct from bh_sk_txt where so_id = b_so_id and loai='dt_ct';
        end if;
        --end nguoi sk
      elsif b_nv_ng = 'TDC' then
        select count(*) into b_count from bh_ngtd_txt where so_id=b_so_id and loai='dt_ct';
        if b_count <> 0 then
          select txt into dt_ct from bh_ngtd_txt where so_id = b_so_id and loai='dt_ct';
        end if;
      elsif b_nv_ng in ('DLG','DLC','DLT') then
        -- nguoi DL
        select count(*) into b_count from bh_ngdl_txt where so_id=b_so_id and loai='dt_ct';
        if b_count <> 0 then
          select txt into dt_ct from bh_ngdl_txt where so_id = b_so_id and loai='dt_ct';
        end if;
        -- end nguoi dl
      end if;
    end if;
  elsif b_nv='2B' then
    -- xe 2b
    select count(*) into b_count from bh_2b_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_2b_txt where so_id = b_so_id and loai='dt_ct';
    end if;
  -- end xe 2b
  elsif b_nv='TAU' then
    -- tau
    select count(*) into b_count from bh_tau_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_tau_txt where so_id = b_so_id and loai='dt_ct';
    end if;
  -- end tau
  elsif b_nv='HANG' then
     -- hang
    select count(*) into b_count from bh_hang_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_hang_txt where so_id = b_so_id and loai='dt_ct';
    end if;

  -- end hang
  elsif b_nv='PTN' then
     -- PTN
    select count(*) into b_count from bh_ptn_txt where so_id=b_so_id and loai='dt_ct';
    if b_count <> 0 then
      select txt into dt_ct from bh_ptn_txt where so_id = b_so_id and loai='dt_ct';
    end if;

    -- end PTN
  end if;
--end check
b_nt_tien:= FKH_JS_GTRIs(dt_ct ,'nt_tien');
b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_hl');
if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_hl',' '); 
else PKH_JS_THAYa(dt_ct,'ngay_hl',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_cap');
if b_i1 = 30000101 then PKH_JS_THAYa(dt_ct,'ngay_cap',' '); 
else PKH_JS_THAYa(dt_ct,'ngay_cap',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );end if;

b_i1:= FKH_JS_GTRIn(dt_ct ,'thue');
PKH_JS_THAY(dt_ct,'thue',FBH_CSO_TIEN(b_i1,'') );

b_i1:= FKH_JS_GTRIn(dt_ct ,'ttoan');
PKH_JS_THAY(dt_ct,'ttoan',FBH_CSO_TIEN(b_i1,'') );
PKH_JS_THAYa(dt_ct,'bangchu',FBH_IN_CSO_CHU(b_i1,b_nt_tien) );
PKH_JS_THAY(dt_ct,'bangchu_e',FBH_IN_CSO_CHU_EN(b_i1,b_nt_tien) );


--lay tt dvi
select json_object('ten_gon' value  NVL(ten_gon,' '),'ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into dt_dv
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    dt_dv:=FKH_JS_BONH(dt_dv);
    select json_mergepatch(dt_ct,dt_dv) into dt_ct from dual;

select sum(phi) into b_i1 from BH_HD_GOC_PT t where so_id=b_so_id_g and kieu_hd = b_kieu_hd and bt < 10;
PKH_JS_THAY(dt_ct,'phi',FBH_CSO_TIEN(b_i1,'') );
select count(1) into  b_tong_ky from (select t.ngay from BH_HD_GOC_PT t where so_id=b_so_id_g and kieu_hd = b_kieu_hd and bt < 10 group by ngay);

select JSON_ARRAYAGG(json_object('so_hd' value b_so_hd,'ky_han' value rownum||'/'|| b_tong_ky,
  'ngay_den_han' value FBH_IN_CSO_NG(ngay,'DD/MM/YYYY'),'phi' value FBH_CSO_TIEN(phi,''),
  'tong_phi' value FBH_CSO_TIEN(ttoan,''), 'thue' value FBH_CSO_TIEN(thue,'') returning clob) order by ngay returning clob ) into dt_tt
       from (select t.ngay,sum(t.phi) phi,sum(t.t_suat) t_suat, sum(t.ttoan) ttoan,sum(t.thue) thue from BH_HD_GOC_PT t where  so_id=b_so_id_g and kieu_hd = b_kieu_hd and bt < 10 group by ngay);

select json_object('dt_ct' value dt_ct,'dt_tt' value dt_tt returning clob) into b_oraOut from dual;

exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi);  end if; rollback;
end;
