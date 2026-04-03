----bao gia

CREATE OR REPLACE PROCEDURE PBH_PHH_IN_B(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    -- chung
    b_loi varchar2(100);b_i1 number;b_i2 number;b_phan number;b_ma_dt varchar2(500); b_lvuc varchar2(500);
    b_nd_dkhoan nvarchar2(500); b_nd_qtac nvarchar2(500);b_ten varchar2(10);b_ma_dk varchar2(10); b_ma_qtac varchar2(10);
    b_tongphits number;b_tongthuets number; b_tlphits_bb number;b_tlphits_khac number;b_tlphigdkd number;
    b_phits_bb number;b_phits_khac number;b_phigdkd number;
    b_thuets_bb number;b_thuets_khac number;b_thuegdkd number;
    b_lenh varchar2(1000);b_c clob;
    -- orain
    b_so_hd varchar2(50) :=FKH_JS_GTRIs(b_oraIn,'so_hd');
    b_ma_dvi varchar2(10) :=FKH_JS_GTRIs(b_oraIn,'ma_dvi');
    b_so_id number:=FKH_JS_GTRIs(b_oraIn,'so_id');
    
    b_tc_count number:= 0;

    --bien mang
    a_pvbh_ma pht_type.a_var; a_pvbh_ten pht_type.a_nvar;a_pvbh_ptts pht_type.a_num;a_pvbh_tc pht_type.a_var;
    a_pvbh_ma_dk pht_type.a_var;a_pvbh_ma_dk_ten pht_type.a_nvar;a_pvbh_ma_qtac pht_type.a_var;a_pvbh_ma_qtac_ten pht_type.a_nvar;

     -- truong out
    dt_ct clob; dt_bs clob; dt_dk clob; dt_lt clob; dt_kbt clob; dt_kytt clob;dt_pvi clob; 
    dt_dkbs clob;dt_ddiem clob;dt_pvi_nd clob;dt_phi clob;dt_lbh clob;
    -- pvi + qtac thietaits
    pvi_ts clob;pvi_gdkd clob;b_dvi clob;

begin
-- Dan - Xem
delete temp_7;commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','PHH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_hd=0 then b_loi:='loi:So hop dong da xoa:loi'; raise PROGRAM_ERROR; end if;

b_ma_dvi:=nvl(trim(b_ma_dvi),b_ma_dviN);

select count(*) into b_i1 from bh_phhB_txt t where t.so_id = b_so_id AND t.loai='dt_ct';
if b_i1 <> 0 then
  SELECT FKH_JS_BONH(t.txt) INTO dt_ct from bh_phhB_txt t where t.so_id = b_so_id AND t.loai='dt_ct';
b_ma_dt:=FKH_JS_GTRIs(dt_ct,'ma_dt');
  b_lvuc:=FKH_JS_GTRIs(dt_ct,'lvuc');
  b_lvuc:= SUBSTR(b_lvuc, INSTR(b_lvuc, '|') + 1);
  PKH_JS_THAYa(dt_ct,'lvuc',b_lvuc);
  select json_object('ten_dvi' value NVL(ten,' '),'dchi_dvi' value NVL(dchi,' '),'ma_tk_dvi' value NVL(ma_tk,' '),
           'nhang_dvi' value NVL(nhang,' '), 'gdoc_dvi' value NVL(g_doc,' '),'ma_thue_dvi' value NVL(ma_thue,' ') returning clob) into b_dvi
               from ht_ma_dvi where ma=b_ma_dvi;
    dt_ct:=FKH_JS_BONH(dt_ct);
    b_dvi:=FKH_JS_BONH(b_dvi);
    select json_mergepatch(dt_ct,b_dvi) into dt_ct from dual;
end if;

select count(*) into b_i1 from bh_phhB_txt t where t.so_id = b_so_id AND t.loai='dt_dk';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_dk from bh_phhB_txt where  so_id=b_so_id and loai='dt_dk';
end if;

select count(*) into b_i1 from bh_phhB_txt t where t.so_id = b_so_id AND t.loai='dt_pvi';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_pvi from bh_phhB_txt where  so_id=b_so_id and loai='dt_pvi';
end if;

select count(*) into b_i1 from bh_phhB_txt t where t.so_id = b_so_id AND t.loai='dt_dkbs';
if b_i1 <> 0 then
    select FKH_JS_BONH(txt) into dt_dkbs from bh_phhB_txt where  so_id=b_so_id and loai='dt_dkbs';
end if;
--LAM SACH
-- select count(*) into b_i1 from bh_phhB_kbt where  so_id=b_so_id and trim(lt) is not null;
-- if(b_i1>0) then
--     select FKH_JS_BONH(lt) into dt_lt from bh_phhB_kbt where  so_id=b_so_id;
-- end if;
-- select count(*) into b_i1 from bh_phhB_kbt where  so_id=b_so_id and trim(dk) is not null;
-- if(b_i1>0) then
--     select FKH_JS_BONH(kbt) into dt_kbt from bh_phhB_kbt where  so_id=b_so_id;
-- end if;
select count(*) into b_i1 from bh_hd_goc_ttdt where  so_id=b_so_id and trim(ttin) is not null;
if(b_i1>0) then
        select FKH_JS_BONH(ttin) into dt_pvi_nd from bh_hd_goc_ttdt where  so_id=b_so_id;
end if;
-- select JSON_ARRAYAGG(json_object(ngay,tien) order by ngay) into dt_kytt from bh_phhB_tt where  so_id=b_so_id;

select txt into b_c from bh_phhB_txt j where  so_id=b_so_id and j.loai='dt_pvi';

if b_c='""' then b_c:=''; else b_c:=substr(b_c,2,length(b_c)-2); end if;
if b_c <> '""' then
       b_lenh := FKH_JS_LENH('ten,ma,ptts,tc');
       EXECUTE IMMEDIATE b_lenh bulk collect INTO a_pvbh_ten,a_pvbh_ma,a_pvbh_ptts,a_pvbh_tc USING b_c;
       for b_lp in 1..a_pvbh_ma.count loop
          SELECT FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'ma_dk'),FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'ma_qtac')into b_ma_dk ,b_ma_qtac
                 from BH_PHH_PVI t where  t.ma= a_pvbh_ma(b_lp);
          select count(*) into b_i1 from bh_ma_dk t where  ma=b_ma_dk;
          if b_i1>0 then       
               SELECT nvl(FKH_JS_GTRIs(FKH_JS_BONH(t.txt) ,'nd'),'')into b_nd_dkhoan from BH_MA_DK t where ma=b_ma_dk;
          else 
            b_nd_dkhoan:=' ';
          end if;
          select count(*) into b_i1 from bh_ma_qtac t where  ma=b_ma_qtac;
          if b_i1>0 then 
               SELECT nvl(FKH_JS_GTRIs(FKH_JS_BONH(t.txt),'ten'),'')into b_nd_qtac from bh_ma_qtac t where  ma= b_ma_qtac ;
          else
            b_nd_qtac:=' ';
          end if;
          -- neu ptts <> 0 la thiet hai tai san insert vao temp_7
          if a_pvbh_ptts(b_lp) <>0 then
             if a_pvbh_tc(b_lp) = 'C' then
                if b_tc_count = 0 then
                   insert into temp_7(c1,c2,c3,n1) values('- ' || b_nd_dkhoan,'- ' ||b_nd_qtac,a_pvbh_tc(b_lp),2);
                end if;
                insert into temp_7(c1,c3,n1) values(a_pvbh_ten(b_lp),a_pvbh_tc(b_lp),3);
             else
                insert into temp_7(c1,c2,c3,n1) values('- ' || b_nd_dkhoan,'- ' ||b_nd_qtac,a_pvbh_tc(b_lp),1);
             end if;
             b_tc_count := b_tc_count +1;
          else
            -- neu ptts = 0 la gian doan kinh doanh insert vao temp_6
            insert into temp_6(c1,c2,n1) values('- ' || b_nd_dkhoan,'- ' ||b_nd_qtac,0);
          end if;
      end loop;
end if;
select JSON_ARRAYAGG(json_object('ND_DK' VALUE c1,'ND_QTAC' VALUE c2, 'TC' value c3,'STT' value N1)order by n1 returning clob) into pvi_ts from temp_7;
select JSON_ARRAYAGG(json_object('ND_DK' VALUE c1,'ND_QTAC' VALUE c2,'STT' value N1)order by n1 returning clob) into pvi_gdkd from temp_6;
delete temp_6;
delete temp_7;
-- select sum(pt),sum(phi),sum(thue) into b_tlphits_khac,b_phits_khac,b_thuets_khac from bh_phhB_dk t where t.so_id = b_so_id and ma like 'TS%' and tc='C' and pvi_tc<>'B';
-- select sum(pt),sum(phi),sum(thue) into b_tlphits_bb,b_phits_bb ,b_thuets_bb from  bh_phhB_dk t where t.so_id = b_so_id and ma like 'TS%' and tc='C' and pvi_tc='B';
-- select sum(pt),sum(phi),sum(thue) into b_tlphigdkd,b_phigdkd,b_thuegdkd from bh_phhB_dk t where t.so_id = b_so_id and ma = 'TX';
-- select sum(pt) into b_tlphigdkd from bh_phhB_dk t where t.so_id = b_so_id and ma like 'TX%';
-- select sum(phi),sum(thue) into b_tongphits,b_tongthuets from bh_phhB_dk t where t.so_id = b_so_id and ma = 'TS';

insert into temp_7(n1,n2,n3,n4,n5,n6,n7,n8,n9,n10,n11)
values(b_tlphits_khac,b_phits_khac,b_thuets_khac,b_tlphits_bb,b_phits_bb,b_thuets_bb,b_tlphigdkd,b_phigdkd,b_thuegdkd,b_tongphits,b_tongthuets);
select JSON_ARRAYAGG(json_object('tlphits_khac' VALUE n1,'phits_khac' VALUE n2,'thuets_khac' VALUE n3,'tlphits_bb' VALUE n4,'phits_bb' value n5,
'thuets_bb'value n6,'tlphigdkd'value n7,'phigdkd'value n8,'thuegdkd'value n9,'tongphits'value n10,'tongthuets'value n11)) into dt_phi from temp_7;
--- lay loai bh
select JSON_ARRAYAGG(json_object(ma,loai)order by loai returning clob) into dt_lbh from bh_phh_lbh;


select json_object('dt_ct' value dt_ct,'dt_bs' value dt_bs,'dt_dk' value dt_dk,'dt_pvi' value dt_pvi,'dt_dkbs' value dt_dkbs,'dt_pvi_nd' value dt_pvi_nd,'dt_lt' value dt_lt,'dt_kbt' value dt_kbt,'dt_kytt' value dt_kytt,'dt_phi' value dt_phi,'dt_lbh' value dt_lbh,'pvi_ts' value pvi_ts,'pvi_gdkd' value pvi_gdkd returning clob) into b_oraOut from dual;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); rollback; end if;
end;
