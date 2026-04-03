create or replace procedure PBH_IN_TAI_SOA_FAC(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100); b_lenh varchar2(1000);
    -- orain
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    b_so_id_hd number:=0;
    b_nv varchar2(10);b_nt_tra varchar2(10); b_so_id_ta_hd number;
    --
    b_i1 number := 0;b_i2 number:=0;
    dt_ct clob;dt_dk clob; 

    b_temp_var varchar2(100);b_temp_nvar varchar2(500);b_temp_clob clob;
    b_nha_bh  varchar2(20);
    b_amount number:=0;
begin
b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);
--dt_ct
select count(*) into b_i1 from  tbh_dc_txt where ma_dvi = b_ma_dvi and so_id_dc = b_so_id and loai = 'dt_ct';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_ct from  tbh_dc_txt where ma_dvi = b_ma_dvi and so_id_dc = b_so_id and loai = 'dt_ct';

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_ht');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAY(dt_ct,'ngay_ht',' '); 
    else 
        PKH_JS_THAYa(dt_ct,'ngay_ht',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
        PKH_JS_THAYa(dt_ct,'uw_year',FBH_IN_CSO_NG(b_i1,'YYYY'));
    end if;

    b_i1:= FKH_JS_GTRIn(dt_ct ,'ngay_dc');
    if b_i1 = 30000101 or b_i1 = 0 then PKH_JS_THAY(dt_ct,'ngay_dc',FKH_JS_GTRIs(dt_ct ,'ngay_ht')); 
    else 
        PKH_JS_THAYa(dt_ct,'ngay_dc',FBH_IN_CSO_NG(b_i1,'DD/MM/YYYY') );
        PKH_JS_THAYa(dt_ct,'uw_year',FBH_IN_CSO_NG(b_i1,'YYYY'));
    end if;
    b_nt_tra:= FKH_JS_GTRIs(dt_ct ,'nt_tra');

    b_temp_var:= fbh_in_get_quarter_text(FKH_JS_GTRIs(dt_ct ,'ngay_dc'));
    PKH_JS_THAY(dt_ct,'period',b_temp_var);

    --Reinsurer
    b_nha_bh:= FKH_JS_GTRIs(dt_ct ,'nha_bh');
    if trim(b_nha_bh) is not null THEN
        select count(*) into b_i1 from bh_ma_nbh where ma = b_nha_bh;
        if b_i1 <> 0 THEN
            select json_object('nha_bh_ten' value  NVL(ten,' '),'nha_bh_dchi' value NVL(dchi,' ') returning clob) into b_temp_clob
               from bh_ma_nbh where ma = b_nha_bh;
            select json_mergepatch(dt_ct,b_temp_clob) into dt_ct from dual;
        end if;
    end if;
    select count(*) into b_i1 from tbh_hd_di_nha_bh where so_id = b_so_id_ta_hd and kieu='P' and  nha_bhc = b_nha_bh;
    if b_i1 <> 0 THEN
        SELECT LISTAGG((select ten from bh_ma_nbh where ma =  nha_bh) ||',', '') WITHIN GROUP (ORDER BY nha_bh) into b_temp_nvar
        from tbh_hd_di_nha_bh where so_id = b_so_id_ta_hd and kieu='P' and nha_bhc = b_nha_bh;
    end if;
    PKH_JS_THAY(dt_ct,'reinsurer',RTRIM(b_temp_nvar,',') );
    --Treaty
    select pthuc,nv into b_temp_var,b_nv from tbh_dc_pt where so_id_ta_hd = b_so_id_ta_hd group by pthuc,nv;
    if b_temp_var = 'Q' then b_temp_nvar:= 'Quota Share';
    elsif b_temp_var = 'S' then b_temp_nvar:= 'Surplus';
    end if;
    PKH_JS_THAY(dt_ct,'treaty',b_temp_nvar);
    --Covering
    PKH_JS_THAY(dt_ct,'covering',fbh_in_line_business(b_nv) );
    --your share
    select count(*) into b_i1 from tbh_hd_di_nha_bh where so_id = b_so_id_ta_hd and nha_bhc = b_nha_bh;
    if b_i1 <> 0 then
        select sum(pt) into b_i2 from tbh_hd_di_nha_bh where so_id = b_so_id_ta_hd and nha_bhc = b_nha_bh;
        PKH_JS_THAY(dt_ct,'your_share',b_i2);
        if b_i1 = 1 THEN
            select sum(hh) into b_i2 from tbh_hd_di_nha_bh where so_id = b_so_id_ta_hd and nha_bhc = b_nha_bh;
            PKH_JS_THAY(dt_ct,'commission_pt',FBH_TO_CHAR(b_i2));
        else
            select count(DISTINCT hh) into b_i2 from tbh_hd_di_nha_bh where so_id = b_so_id_ta_hd and nha_bhc = b_nha_bh;
            if b_i2 = 1 THEN
                PKH_JS_THAY(dt_ct,'commission_pt',U'Various value');
            else
                PKH_JS_THAY(dt_ct,'commission_pt',' ');
            end if;
        end if;        
    end if;
    --Total Premium
    select sum(tien) into b_i1 from tbh_ps where so_id_ta_hd = b_so_id_ta_hd and goc = 'HD_TT';
    PKH_JS_THAY(dt_ct,'tottal_premium',FBH_CSO_TIEN(b_i1,''));
    b_amount:=b_amount - b_i1;
    --Paid Loss
    select sum(tien) into b_i1 from tbh_ps where so_id_ta_hd = b_so_id_ta_hd and GOC = 'BT_TB';
    select sum(tien) into b_i2 from tbh_dc_pt where so_id_ta_hd = b_so_id_ta_hd and GOC IN ('BT_HS','BT_GD','BT_TH');
    PKH_JS_THAY(dt_ct,'paid_loss',FBH_CSO_TIEN(b_i1 + b_i2,''));
    b_amount:=b_amount + b_i1 + b_i2;
    --Outstanding loss
    b_temp_var := FKH_JS_GTRIs(dt_ct ,'ngay_dc');
    select sum(tai) into b_i1 from BH_BT_HS_DP dp,bh_bt_hs bt 
       where dp.so_id_hd = bt.so_id_hd and bt.ttrang = 'T' and dp.ma_nt = b_nt_tra and dp.nv= b_nv and dp.ksoat <> '0' 
       and TO_DATE(dp.ngay_dp, 'YYYYMMDD') BETWEEN TRUNC(TO_DATE(b_temp_var, 'DD/MM/YYYY'), 'Q') AND TO_DATE(b_temp_var, 'DD/MM/YYYY');

    PKH_JS_THAY(dt_ct,'outstanding_loss',FBH_CSO_TIEN(b_i1,''));
    ---commission_
    select sum(hhong) into b_i1 from tbh_dc_pt where so_id_ta_hd = b_so_id_ta_hd and goc = 'HD_TT';
    PKH_JS_THAY(dt_ct,'commission',FBH_CSO_TIEN(b_i1,''));
    b_amount:=b_amount + b_i1;
    --CIT for overseas reinsurers only
    select sum(thue) into b_i1 from tbh_dc_pt where so_id_ta_hd = b_so_id_ta_hd and goc = 'HD_TT';
    PKH_JS_THAY(dt_ct,'cit',FBH_CSO_TIEN(b_i1,''));
    b_amount:=b_amount + b_i1;
    if b_amount > 0 THEN
        PKH_JS_THAY(dt_ct,'amount_label','Amount due to us');
    else
        PKH_JS_THAY(dt_ct,'amount_label','Amount due to you');
    end if;
    PKH_JS_THAY(dt_ct,'amount',FBH_CSO_TIEN(ABS(b_amount),''));
end if;
--dt_dk
select count(*) into b_i1 from  tbh_dc_txt where ma_dvi = b_ma_dvi and so_id_dc = b_so_id and loai = 'dt_dk';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_dk from  tbh_dc_txt where ma_dvi = b_ma_dvi and so_id_dc = b_so_id and loai = 'dt_dk';
end if;
select json_object('dt_ct' value dt_ct returning clob) into b_oraOut from dual;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
