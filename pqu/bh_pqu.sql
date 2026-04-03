-- Ma ksoat quyen khai thac
create or replace function FBH_PQU_MA_TEN(b_ma varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ten) into b_kq from bh_pqu_ma where ma=b_ma;
return b_kq;
end;
/
create or replace procedure PBH_PQU_MA_XEM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object(ma,ten) order by ma) into cs_lke from bh_pqu_ma;
select json_object('cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_MA_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_dong number:=0; cs_lke clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pqu_ma;
select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by ma) into cs_lke from bh_pqu_ma;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_MA_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_trang number:=1; b_dong number:=0; cs_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from bh_pqu_ma;
select JSON_ARRAYAGG(json_object(ma,ten,nsd) order by ma) into cs_lke from bh_pqu_ma;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_MA_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_kq clob; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object(ma,ten) into b_kq from bh_pqu_ma where ma=b_ma;
select json_object('cs_ct' value b_kq) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_MA_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000);
    b_ma varchar2(10); b_ten nvarchar2(500);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma,ten');
EXECUTE IMMEDIATE b_lenh into b_ma,b_ten using b_oraIn;
b_ma:=nvl(trim(b_ma),' '); b_ten:=nvl(trim(b_ten),' ');
if b_ma=' ' or b_ten=' ' then b_loi:='loi:Nhap ma,ten:loi'; raise PROGRAM_ERROR; end if;
delete bh_pqu_ma where ma=b_ma;
insert into bh_pqu_ma values(b_ma,b_ten,b_nsd,b_oraIn);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_MA_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(10):=FKH_JS_GTRIs(b_oraIn,'ma');
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
delete bh_pqu_ma where ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Khai bao quyen nhom
create or replace procedure FBH_PQU_NSD_NHOM(b_ma_dvi varchar2,b_nsd varchar2,a_nhom out pht_type.a_var)
AS
    b_kq varchar2(10);
begin
-- Dan
select nhom bulk collect into a_nhom from ht_ma_nsd_nhom where ma_dvi=b_ma_dvi and ma=b_nsd and md='BH';
end;
/
create or replace function FBH_PQU_NHOM_TENL(b_nhom varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from ht_ma_nhom where ma=b_nhom;
return b_kq;
end;
/
create or replace function FBH_PQU_SP_TEN(b_nv varchar2,b_ma_sp varchar2) return nvarchar2
AS
    b_kq nvarchar2(500); b_lenh varchar2(1000);
begin
-- Dan
if b_nv='NG' then
    select min(ten) into b_kq from bh_ngdl_sp where ma=b_ma_sp;
    if b_kq is null then
        select min(ten) into b_kq from bh_sk_sp where ma=b_ma_sp;
        if b_kq is null then
            select min(ten) into b_kq from bh_ngtd_sp where ma=b_ma_sp;
        end if;
    end if;
elsif b_nv='PTN' then
  select min(ten) into b_kq from bh_ptncc_sp where ma=b_ma_sp;
    if b_kq is null then
        select min(ten) into b_kq from bh_ptnnn_sp where ma=b_ma_sp;
        if b_kq is null then
            select min(ten) into b_kq from bh_ptnvc_sp where ma=b_ma_sp;
        end if;
    end if;
elsif b_nv='NONG' then
  select min(ten) into b_kq from bh_nongct_sp where ma=b_ma_sp;
    if b_kq is null then
        select min(ten) into b_kq from bh_nongvn_sp where ma=b_ma_sp;
        if b_kq is null then
            select min(ten) into b_kq from bh_nongts_sp where ma=b_ma_sp;
        end if;
    end if;
else
    b_lenh:='select min(ten) from bh_'||b_nv||'_sp where ma= : ma';
    EXECUTE IMMEDIATE b_lenh into b_kq using b_ma_sp;
end if;
return b_kq;
end;
/
create or replace function FBH_PQU_NSD_TENL(b_ma_dvi varchar2,b_nsd varchar2) return nvarchar2
AS
    b_kq nvarchar2(500);
begin
-- Dan
select min(ma||'|'||ten) into b_kq from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
return b_kq;
end;
/
create or replace function FBH_PQU_SP_TENl(b_nv varchar2,b_ma_sp varchar2) return nvarchar2
AS
    b_kq nvarchar2(500); b_ten nvarchar2(500); b_lenh varchar2(1000);
begin
-- viet anh
if b_nv='NG' then
    select min(ma), min(ten) into b_kq, b_ten from bh_ngdl_sp where ma=b_ma_sp;
    if b_kq is null then
        select min(ma), min(ten) into b_kq, b_ten from bh_sk_sp where ma=b_ma_sp;
        if b_kq is null then
            select min(ma), min(ten) into b_kq, b_ten from bh_ngtd_sp where ma=b_ma_sp;
        end if;
    end if;
elsif b_nv='PTN' then
  select min(ma), min(ten) into b_kq, b_ten from bh_ptncc_sp where ma=b_ma_sp;
    if b_kq is null then
        select min(ma), min(ten) into b_kq, b_ten from bh_ptnnn_sp where ma=b_ma_sp;
        if b_kq is null then
            select min(ma), min(ten) into b_kq, b_ten from bh_ptnvc_sp where ma=b_ma_sp;
        end if;
    end if;
elsif b_nv='NONG' then
  select min(ma), min(ten) into b_kq, b_ten from bh_nongct_sp where ma=b_ma_sp;
    if b_kq is null then
        select min(ma), min(ten) into b_kq, b_ten from bh_nongvn_sp where ma=b_ma_sp;
        if b_kq is null then
            select min(ma), min(ten) into b_kq, b_ten from bh_nongts_sp where ma=b_ma_sp;
        end if;
    end if;
else
    b_lenh:='select min(ma), min(ten) from bh_'||b_nv||'_sp where ma= : ma';
    EXECUTE IMMEDIATE b_lenh into b_kq, b_ten using b_ma_sp;
end if;
return b_kq||'|'||b_ten;
end;
/
create or replace function FBH_PQU_NHOM_SO_ID(b_nhom varchar2,b_nv varchar2,b_ma_sp varchar2) return number
AS
    b_kq number;
begin
-- Dan
select nvl(min(so_id),0) into b_kq from bh_pqu_nhom where nhom=b_nhom and nv=b_nv and ma_sp in(' ',b_ma_sp);
return b_kq;
end;
/
create or replace procedure FBH_PQU_NHOM_QLOI(
    b_nv varchar2,b_ma_sp varchar2,dt_dk out clob,dt_lt out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_bang varchar2(50);
begin
-- Dan
b_loi:='loi:Loi xu ly FBH_PQU_NHOM_QLOI:loi';
b_bang:='bh_'||b_nv||'_phi';
if b_ma_sp<>' ' then
    if b_nv='NG' then
        select count(*) into b_i1 from bh_ngdl_phi where ma_sp=b_ma_sp;
        if b_i1<>0 then
            b_bang:='bh_ngdl_phi';
        else
            select count(*) into b_i1 from bh_sk_phi where ma_sp=b_ma_sp;
            if b_i1<>0 then b_bang:='bh_sk_phi'; else b_bang:='bh_ngtd_phi'; end if;
        end if;
    elsif b_nv='PTN' then
        select count(*) into b_i1 from bh_ptncc_phi where ma_sp=b_ma_sp;
        if b_i1<>0 then
            b_bang:='bh_ptncc_phi';
        else
            select count(*) into b_i1 from bh_ptnnn_phi where ma_sp=b_ma_sp;
            if b_i1<>0 then b_bang:='bh_ptnnn_phi'; 
            else 
              select count(*) into b_i1 from bh_ptnch_phi where ma_sp=b_ma_sp;
              if b_i1<>0 then b_bang:='bh_ptnch_phi'; else b_bang:='bh_ptnvc_phi'; end if;
            end if;
        end if;
    elsif b_nv='NONG' then --Nam: nghiep vu NONG
        select count(*) into b_i1 from bh_nongvn_phi where ma_sp=b_ma_sp;
        if b_i1<>0 then
            b_bang:='bh_nongvn_phi';
        else
            select count(*) into b_i1 from bh_nongct_phi where ma_sp=b_ma_sp;
            if b_i1<>0 then b_bang:='bh_nongct_phi'; else b_bang:='bh_nongts_phi'; end if;
        end if;
    end if;
    b_lenh:='insert into temp_1(c1,c2) select b.ma,min(b.ten) from '||b_bang||' a,'||b_bang||'_dk b where a.ma_sp= : ma_sp and b.so_id=a.so_id group by b.ma';
    EXECUTE IMMEDIATE b_lenh using b_ma_sp;
    b_lenh:='insert into temp_2(c1,c2) select b.ma_lt,min(b.ten) from '||b_bang||' a,'||b_bang||'_lt b where a.ma_sp= : ma_sp and b.so_id=a.so_id group by b.ma_lt';
    EXECUTE IMMEDIATE b_lenh using b_ma_sp;
else
    if b_nv='NG' then
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_ngdl_phi_dk group by ma union
            select ma,min(ten) from bh_ngtd_phi_dk group by ma union
            select ma,min(ten) from bh_sk_phi_dk group by ma;
    elsif b_nv='PTN' then
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_ptncc_phi_dk group by ma union
            select ma,min(ten) from bh_ptnvc_phi_dk group by ma union
            select ma,min(ten) from bh_ptnch_phi_dk group by ma union
            select ma,min(ten) from bh_ptnnn_phi_dk group by ma;
    elsif b_nv='NONG' then --Nam: nghiep vu NONG
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_nongvn_phi_dk group by ma union
            select ma,min(ten) from bh_nongct_phi_dk group by ma union
            select ma,min(ten) from bh_nongts_phi_dk group by ma;
    elsif b_nv in ('HOP') then --Nam: nghiep vu HOP
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_hop_phi_dk group by ma union
            select ma,min(ten) from bh_dtau_phi_dk group by ma;
    else
        b_lenh:='insert into temp_1(c1,c2) select ma,min(ten) from '||b_bang||'_dk group by ma';
        EXECUTE IMMEDIATE b_lenh;
        b_lenh:='insert into temp_2(c1,c2) select ma_lt,min(ten) from '||b_bang||'_lt group by ma_lt';
        EXECUTE IMMEDIATE b_lenh;
    end if;
end if;
insert into bh_pqu_nsd_temp_ql select c1,min(c2) from temp_1 group by c1;
insert into bh_pqu_nsd_temp select a.ma_ql,b.ma,0,a.ma_qlT,b.ten from bh_pqu_nsd_temp_ql a, bh_pqu_ma b order by a.ma_ql,b.ma;
for r_lp in (select ma_ql,min(ma_pqu) ma_pqu from bh_pqu_nsd_temp group by ma_ql,ma_qlT) loop
    update bh_pqu_nsd_temp set ma_qlT='' where ma_ql=r_lp.ma_ql and ma_pqu<>r_lp.ma_pqu;
end loop;
select JSON_ARRAYAGG(json_object(*) order by ma_ql,ma_pqu returning clob) into dt_dk from bh_pqu_nsd_temp;
select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2) order by c1 returning clob) into dt_lt from temp_2;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PQU_NHOM_SO_ID(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_so_id number;
    b_nhom varchar2(10); b_nv varchar2(10); b_ma_sp varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv,b_ma_sp using b_oraIn;
b_nhom:=nvl(trim(b_nhom),' '); b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
if b_nv=' ' or b_nv not in ('XE','2B','TAU','PHH','PKT','PTN','NG','HANG','HOP','NONG') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
b_so_id:=FBH_PQU_NHOM_SO_ID(b_nhom,b_nv,b_ma_sp);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_QLOI(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000);
    b_nhom varchar2(10); b_nv varchar2(10); b_ma_sp varchar2(10); dt_dk clob:=''; dt_lt clob:='';
begin
-- Dan
delete temp_1; delete temp_2; delete bh_pqu_nsd_temp_ql; delete bh_pqu_nsd_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv,b_ma_sp using b_oraIn;
b_nhom:=nvl(trim(b_nhom),' '); b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
if b_nv=' ' or b_nv not in ('XE','2B','TAU','PHH','PKT','PTN','NG','HANG','HOP','NONG') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
FBH_PQU_NHOM_QLOI(b_nv,b_ma_sp,dt_dk,dt_lt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('dt_dk' value dt_dk,'dt_lt' value dt_lt returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete bh_pqu_nsd_temp_ql; delete bh_pqu_nsd_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- nam fix phan quyen PTN
create or replace procedure FBH_PQU_NHOM_SP(b_nv varchar2,dt_lke out clob)
AS
    b_ngay number:=PKH_NG_CSO(sysdate); b_lenh varchar2(1000);
begin
-- Dan
if b_nv='NG' then
    insert into temp_1(c1,c2)
        select ma,ten from bh_ngdl_sp where ngay_kt>b_ngay union
        select ma,ten from bh_ngtd_sp where ngay_kt>b_ngay union
        select ma,ten from bh_sk_sp where ngay_kt>b_ngay;
elsif b_nv='PTN' then
      insert into temp_1(c1,c2)
        select ma,ten from bh_ptncc_sp where ngay_kt>b_ngay union
        select ma,ten from bh_ptnnn_sp where ngay_kt>b_ngay;
elsif b_nv='NONG' then --Nam: them nghiep vu NONG
      insert into temp_1(c1,c2)
        select ma,ten from bh_nongvn_sp where ngay_kt>b_ngay union
        select ma,ten from bh_nongct_sp where ngay_kt>b_ngay union
        select ma,ten from bh_nongts_sp where ngay_kt>b_ngay;
else
    b_lenh:='insert into temp_1(c1,c2) select ma,min(ten) from bh_'||b_nv||'_sp where ngay_kt> : ngay group by ma';
    EXECUTE IMMEDIATE b_lenh using b_ngay;
end if;
select JSON_ARRAYAGG(json_object('ma' value c1,'ten' value c2) order by c2) into dt_lke from temp_1;
end;
/
-- viet anh - chuyen dr_list sang dr_lke - phan quyen khai thac nhom ma_sp
create or replace procedure PBH_PQ_NHOM_SP_LIST(b_tso varchar2,b_loi out varchar2)
AS
       b_lenh varchar2(1000); b_nv varchar2(5);
       b_ngay number:=PKH_NG_CSO(sysdate);
begin
-- viet anh
b_loi:='loi:Loi xu ly PBH_PQ_NHOM_SP_LIST:loi';
b_lenh:=FKH_JS_LENH('nv');
EXECUTE IMMEDIATE b_lenh into b_nv using b_tso;
if b_nv is not null then
    if b_nv='NG' then
    insert into bh_kh_hoi_temp1(ma,ten) select ma,ten from (
        select ma, ten from bh_ngdl_sp where ngay_kt > b_ngay union
        select ma, ten from bh_ngtd_sp where ngay_kt > b_ngay union
        select ma, ten from bh_sk_sp where ngay_kt > b_ngay
    ) t order by ten;
    elsif b_nv='PTN' then
          insert into bh_kh_hoi_temp1(ma,ten) select ma,ten from (
            select ma,ten from bh_ptncc_sp where ngay_kt>b_ngay union
            select ma,ten from bh_ptnnn_sp where ngay_kt>b_ngay
        ) t order by ten;
    elsif b_nv='NONG' then
          insert into bh_kh_hoi_temp1(ma,ten) select ma,ten from (
            select ma,ten from bh_nongvn_sp where ngay_kt>b_ngay union
            select ma,ten from bh_nongct_sp where ngay_kt>b_ngay union
            select ma,ten from bh_nongts_sp where ngay_kt>b_ngay
        ) t order by ten;    
    else
        b_lenh:='insert into bh_kh_hoi_temp1 select ma,min(ten) from bh_'||b_nv||'_sp where ngay_kt> : ngay group by ma';
        EXECUTE IMMEDIATE b_lenh using b_ngay;
    end if;
end if;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure PBH_PQU_NHOM_SP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); dt_lke clob; b_nv varchar2(10):=b_oraIn;
begin
-- Dan
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
FBH_PQU_NHOM_SP(b_nv,dt_lke);
select json_object('dt_lke' value dt_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_pqu_nhom;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nhomT,nv,ma_spT,so_id) order by nhom,nv,ma_sp returning clob) into dt_lke from
    (select nhom,nv,ma_sp,nhomT,ma_spT,so_id,rownum sott from bh_pqu_nhom order by nhom,nv,ma_sp)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_MA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number;
    b_nhom varchar2(10); b_nv varchar2(10); b_ma_sp varchar2(10);
    b_trang number:=1; b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,nv,ma_sp,hangkt');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv,b_ma_sp,b_hangKt using b_oraIn;
b_ma_sp:=nvl(b_ma_sp,' ');
select count(*) into b_dong from bh_pqu_nhom;
select nvl(min(sott),b_dong) into b_tu from
    (select a.*,rownum sott from bh_pqu_nhom a order by nhom,nv,ma_sp)
    where nhom>=b_nhom and nv>=b_nv and ma_sp>=b_ma_sp;
PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(nhomT,nv,ma_spT,so_id) order by nhom,nv,ma_sp returning clob) into dt_lke from
    (select nhom,nv,ma_sp,nhomT,ma_spT,so_id,rownum sott from bh_pqu_nhom order by nhom,nv,ma_sp)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_nv varchar2(10);
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_ct clob; dt_dk clob; dt_lt clob; dt_ma_sp clob;
begin
-- Dan - Xem chi tiet theo so ID
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Phan quyen da xoa:loi';
select nv into b_nv from bh_pqu_nhom where so_id=b_so_id;
FBH_PQU_NHOM_SP(b_nv,dt_ma_sp);
-- viet anh
select JSON_ARRAYAGG(json_object('nhom' value FBH_PQU_NHOM_TENL(nhom),nv,'ma_sp' value FBH_PQU_SP_TENl(b_nv,ma_sp))) 
       into dt_ct from bh_pqu_nhom where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_ql,ma_pqu,ghan,ma_qlT,ma_pquT) order by ma_ql,ma_pqu returning clob)
    into dt_dk from bh_pqu_nhom_ct where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by ma_lt returning clob)
    into dt_lt from bh_pqu_nhom_lt where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'dt_lt' value dt_lt,'dt_ma_sp' value dt_ma_sp returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE procedure PBH_PQU_NHOM_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_nhom varchar2(10); b_nv varchar2(10); b_ma_sp varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nhom,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv,b_ma_sp using b_oraIn;
b_nhom:=nvl(trim(b_nhom),' '); b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
b_so_id:=FBH_PQU_NHOM_SO_ID(b_nhom,b_nv,b_ma_sp);
if b_so_id<>0 then
    delete bh_pqu_nhom_ct where so_id=b_so_id;
    delete bh_pqu_nhom where so_id=b_so_id;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NHOM_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_i1 number; b_so_id number;
    b_nhom varchar2(10); b_nv varchar2(10); b_ma_sp varchar2(10);
    b_nhomT nvarchar2(500); b_ma_spT nvarchar2(500):=' ';
    a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
    a_ma_qlT pht_type.a_nvar; a_ma_pquT pht_type.a_nvar;
    a_lt_ma pht_type.a_var; a_lt_ten pht_type.a_nvar;
    dt_ct clob; dt_dk clob; dt_lt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_lt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_lt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_lt);
b_lenh:=FKH_JS_LENH('nhom,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_nhom,b_nv,b_ma_sp using dt_ct;
b_nhom:=nvl(trim(b_nhom),' '); b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
select min(ten) into b_nhomT from ht_ma_nhom where md='BH' and ma=b_nhom;
if b_nhomT is null then b_loi:='loi:Sai ma nhom:loi'; raise PROGRAM_ERROR; end if;
if b_nv=' ' or b_nv not in ('XE','2B','TAU','PHH','PKT','PTN','NG','HANG','HOP','NONG') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_sp<>' ' then
    b_ma_spT:=FBH_PQU_SP_TEN(b_nv,b_ma_sp);
    if b_ma_spT is null then b_loi:='loi:Sai ma san pham:loi'; raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('ma_ql,ma_pqu,ghan,ma_qlt,ma_pqut');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_ql,a_ma_pqu,a_ghan,a_ma_qlt,a_ma_pqut using dt_dk;
if a_ma_ql.count=0 then b_loi:='loi:Chua nhap phan quyen:loi'; raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_lt,ten');
EXECUTE IMMEDIATE b_lenh bulk collect into a_lt_ma,a_lt_ten using dt_lt;
b_so_id:=FBH_PQU_NHOM_SO_ID(b_nhom,b_nv,b_ma_sp);
if b_so_id<>0 then
    delete bh_pqu_nhom_lt where so_id=b_so_id;
    delete bh_pqu_nhom_ct where so_id=b_so_id;
    delete bh_pqu_nhom where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_pqu_nhom values(b_so_id,b_nhom,b_nv,b_ma_sp,b_nhomT,b_ma_spT);
forall b_lp in 1..a_ma_ql.count
    insert into bh_pqu_nhom_ct values(b_so_id,a_ma_ql(b_lp),a_ma_pqu(b_lp),a_ghan(b_lp),a_ma_qlT(b_lp),a_ma_pquT(b_lp));
forall b_lp in 1..a_lt_ma.count
    insert into bh_pqu_nhom_lt values(b_so_id,a_lt_ma(b_lp),a_lt_ten(b_lp));
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Phan quyen NSD
create or replace function FBH_PQU_NSD_SO_ID(b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ma_sp varchar2) return number
AS
    b_kq number;
begin
-- Dan
select nvl(min(so_id),0) into b_kq from bh_pqu_nsd where ma_dvi=b_ma_dvi and nsd=b_nsd and nv=b_nv and ma_sp=b_ma_sp;
return b_kq;
end;
/
create or replace procedure PBH_PQU_NSD_NSD(b_ma_dvi varchar2,b_loi out varchar2)
AS
begin
-- Dan
b_loi:='loi:Loi xu ly PBH_PQU_NSD_NSD:loi';
insert into bh_kh_hoi_temp1 select ma,ten from ht_ma_nsd where ma_dvi=b_ma_dvi order by ten;
b_loi:='';
exception when others then null;
end;
/
create or replace procedure FBH_PQU_NSD_QLOI(
    b_nv varchar2,b_ma_sp varchar2,b_ma_dvi varchar2,dt_dk out clob,dt_lt out clob,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_bang varchar2(50);
begin
-- Dan
b_loi:='loi:Loi xu ly FBH_PQU_NSD_QLOI:loi';
b_bang:='bh_'||b_nv||'_phi';
if b_ma_sp<>' ' then
    if b_nv='NG' then
        select count(*) into b_i1 from bh_ngdl_phi where ma_sp=b_ma_sp;
        if b_i1<>0 then
            b_bang:='bh_ngdl_phi';
        else
            select count(*) into b_i1 from bh_sk_phi where ma_sp=b_ma_sp;
            if b_i1<>0 then b_bang:='bh_sk_phi'; else b_bang:='bh_ngtd_phi'; end if;
        end if;
    elsif b_nv='PTN' then
        select count(*) into b_i1 from bh_ptncc_phi where ma_sp=b_ma_sp;
        if b_i1<>0 then
            b_bang:='bh_ptncc_phi';
        else
            select count(*) into b_i1 from bh_ptnvc_phi where ma_sp=b_ma_sp;
            if b_i1<>0 then b_bang:='bh_ptnvc_phi'; 
            else 
              select count(*) into b_i1 from bh_ptnch_phi where ma_sp=b_ma_sp;
              if b_i1<>0 then b_bang:='bh_ptnch_phi'; 
              else b_bang:='bh_ptnnn_phi'; end if;
             end if;
        end if;
    elsif b_nv='NONG' then
        select count(*) into b_i1 from bh_nongct_phi where ma_sp=b_ma_sp;
        if b_i1<>0 then
            b_bang:='bh_nongct_phi';
        else
            select count(*) into b_i1 from bh_nongvn_phi where ma_sp=b_ma_sp;
            if b_i1<>0 then b_bang:='bh_nongvn_phi'; else b_bang:='bh_nongts_phi'; end if;
        end if;
    end if;
    b_lenh:='insert into temp_1(c1,c2) select b.ma,min(b.ten) from '||b_bang||' a,'||b_bang||'_dk b where a.ma_sp= : ma_sp and b.so_id=a.so_id group by b.ma';
    EXECUTE IMMEDIATE b_lenh using b_ma_sp;
    b_lenh:='insert into temp_2(c1,c2) select b.ma_lt,min(b.ten) from '||b_bang||' a,'||b_bang||'_lt b where a.ma_sp= : ma_sp and b.so_id=a.so_id group by b.ma_lt';
    EXECUTE IMMEDIATE b_lenh using b_ma_sp;
else
    if b_nv='NG' then
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_ngdl_phi_dk group by ma union
            select ma,min(ten) from bh_ngtd_phi_dk group by ma union
            select ma,min(ten) from bh_sk_phi_dk group by ma;
    elsif b_nv='PTN' then
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_ptncc_phi_dk group by ma union
            select ma,min(ten) from bh_ptnvc_phi_dk group by ma union
            select ma,min(ten) from bh_ptnch_phi_dk group by ma union
            select ma,min(ten) from bh_ptnnn_phi_dk group by ma;
    elsif b_nv='NONG' then
        insert into temp_1(c1,c2)
            select ma,min(ten) from bh_nongvn_phi_dk group by ma union
            select ma,min(ten) from bh_nongct_phi_dk group by ma union
            select ma,min(ten) from bh_nongts_phi_dk group by ma;
    else
        b_lenh:='insert into temp_1(c1,c2) select ma,min(ten) from '||b_bang||'_dk group by ma';
        EXECUTE IMMEDIATE b_lenh;
        b_lenh:='insert into temp_2(c1,c2) select ma_lt,min(ten) from '||b_bang||'_lt group by ma_lt';
        EXECUTE IMMEDIATE b_lenh;
    end if;
end if;
insert into bh_pqu_nsd_temp_ql select c1,min(c2) from temp_1 group by c1;
insert into bh_pqu_nsd_temp select a.ma_ql,b.ma,0,a.ma_qlT,b.ten from bh_pqu_nsd_temp_ql a, bh_pqu_ma b order by a.ma_ql,b.ma;
for r_lp in (select ma_ql,min(ma_pqu) ma_pqu from bh_pqu_nsd_temp group by ma_ql,ma_qlT) loop
    update bh_pqu_nsd_temp set ma_qlT='' where ma_ql=r_lp.ma_ql and ma_pqu<>r_lp.ma_pqu;
end loop;
select JSON_ARRAYAGG(json_object(*) order by ma_ql,ma_pqu returning clob) into dt_dk from bh_pqu_nsd_temp;
select JSON_ARRAYAGG(json_object('ma_lt' value c1,'ten' value c2) order by c1 returning clob) into dt_lt from temp_2;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_PQU_NSD_SO_ID(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000); b_so_id number:=0;
    b_ma_dvi varchar2(10); b_nsd varchar2(20); b_nv varchar2(10); b_ma_sp varchar2(10);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nsd,b_nv,b_ma_sp using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_nsd:=nvl(trim(b_nsd),' ');
b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
b_so_id:=FBH_PQU_NSD_SO_ID(b_ma_dvi,b_nsd,b_nv,b_ma_sp);
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE PBH_PQU_NSD_QLOI(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(2000);
    b_ma_dvi varchar2(10); b_nsd varchar2(20); b_nv varchar2(10); b_ma_sp varchar2(10); dt_dk clob:=''; dt_lt clob:='';
begin
-- Dan
delete temp_1; delete temp_2; delete bh_pqu_nsd_temp_ql; delete bh_pqu_nsd_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','MA','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nsd,b_nv,b_ma_sp using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_nsd:=nvl(trim(b_nsd),' ');
b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
FBH_PQU_NSD_QLOI(b_nv,b_ma_sp,b_ma_dvi,dt_dk,dt_lt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select json_object('dt_dk' value dt_dk,'dt_lt' value dt_lt returning clob) into b_oraOut from dual;
delete temp_1; delete temp_2; delete bh_pqu_nsd_temp_ql; delete bh_pqu_nsd_temp; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_tu number; b_den number;
    b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('tu,den');
EXECUTE IMMEDIATE b_lenh into b_tu,b_den using b_oraIn;
select count(*) into b_dong from bh_pqu_nsd;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
select JSON_ARRAYAGG(json_object(nsdT,nv,ma_spT,so_id,ma_dvi,nsd,ma_sp) order by ma_dvi,nsdT,nv,ma_sp returning clob) into dt_lke from
    (select a.*,rownum sott from bh_pqu_nsd a order by ma_dvi,nsdT,nv,ma_sp)
    where sott between b_tu and b_den;
select json_object('dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_MA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000);
    b_tu number; b_den number; b_hangKt number;
    b_ma_dvi varchar2(10); b_nsd varchar2(20); b_nv varchar2(10); b_ma_sp varchar2(10);
    b_trang number:=1; b_dong number:=0; dt_lke clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,ma_sp,hangkt');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nsd,b_nv,b_ma_sp,b_hangKt using b_oraIn;
b_ma_sp:=nvl(b_ma_sp,' ');
select count(*) into b_dong from bh_pqu_nsd;
select nvl(min(sott),b_dong) into b_tu from
    (select a.*,rownum sott from bh_pqu_nsd a order by ma_dvi,nsdT,nv,ma_sp)
    where ma_dvi>=b_ma_dvi and nsd>b_nsd and nv>=b_nv and ma_sp>=b_ma_sp;
PKH_LKE_VTRI(b_hangKt,b_tu,b_den,b_trang);
select JSON_ARRAYAGG(json_object(nsdT,nv,ma_spT,so_id,ma_dvi,nsd,ma_sp) order by ma_dvi,nsdT,nv,ma_sp returning clob) into dt_lke from
    (select a.*,rownum sott from bh_pqu_nsd a order by ma_dvi,nsdT,nv,ma_sp)
    where sott between b_tu and b_den;
select json_object('trang' value b_trang,'dong' value b_dong,'dt_lke' value dt_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_nv varchar2(10);
    b_so_id number:=FKH_JS_GTRIn(b_oraIn,'so_id');
    dt_ct clob; dt_dk clob; dt_lt clob; dt_ma_sp clob;
begin
-- Dan - Xem chi tiet theo so ID
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','HT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Phan quyen da xoa:loi';
select nv into b_nv from bh_pqu_nsd where so_id=b_so_id;
FBH_PQU_NHOM_SP(b_nv,dt_ma_sp);
-- viet anh
select JSON_ARRAYAGG(json_object(ma_dvi,'nsd' value nsd||'|'||nsdT,nv,'ma_sp' value FBH_PQU_SP_TENl(b_nv,ma_sp))) 
       into dt_ct from bh_pqu_nsd where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_ql,ma_pqu,ghan,ma_qlT,ma_pquT) order by ma_ql,ma_pqu returning clob)
    into dt_dk from bh_pqu_nsd_ct where so_id=b_so_id;
select JSON_ARRAYAGG(json_object(ma_lt,ten) order by ma_lt returning clob)
    into dt_lt from bh_pqu_nsd_lt where so_id=b_so_id;
select json_object('so_id' value b_so_id,'dt_ct' value dt_ct,'dt_dk' value dt_dk,
    'dt_lt' value dt_lt,'dt_ma_sp' value dt_ma_sp returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else  raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_XOA(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_so_id number;
    b_ma_dvi varchar2(10); b_nsd varchar2(20); b_nv varchar2(10); b_ma_sp varchar2(10); dt_pqu clob:='';
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nsd,b_nv,b_ma_sp using b_oraIn;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_nsd:=nvl(trim(b_nsd),' ');
b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
--b_so_id:=FBH_PQU_NSD_SO_ID(b_ma_dvi,b_nsd,b_nv,b_ma_sp);
b_so_id:= FKH_JS_GTRIn(b_oraIn,'so_id');
if b_so_id<>0 then
	delete bh_pqu_nsd_lt where so_id=b_so_id;
    delete bh_pqu_nsd_ct where so_id=b_so_id;
    delete bh_pqu_nsd where so_id=b_so_id;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PQU_NSD_NH(
    b_ma_dviN varchar2,b_nsdN varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000); b_i1 number; b_so_id number;
    b_ma_dvi varchar2(10); b_nsd varchar2(20);
    b_nv varchar2(10); b_ma_sp varchar2(10);
    b_nsdT nvarchar2(100); b_ma_spT nvarchar2(500):=' ';
    a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
    a_ma_qlT pht_type.a_nvar; a_ma_pquT pht_type.a_nvar;
    a_lt_ma pht_type.a_var; a_lt_ten pht_type.a_nvar;
    dt_ct clob; dt_dk clob; dt_lt clob;
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsdN,b_pas,'BH','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_dk,dt_lt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_dk,dt_lt using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_dk); FKH_JSa_NULL(dt_lt);
b_lenh:=FKH_JS_LENH('ma_dvi,nsd,nv,ma_sp');
EXECUTE IMMEDIATE b_lenh into b_ma_dvi,b_nsd,b_nv,b_ma_sp using dt_ct;
b_ma_dvi:=nvl(trim(b_ma_dvi),' '); b_nsd:=nvl(trim(b_nsd),' ');
b_nv:=nvl(trim(b_nv),' '); b_ma_sp:=nvl(trim(b_ma_sp),' ');
if b_ma_dvi=' ' or b_nsd=' ' then
    b_loi:='loi:Nhap ma don vi, ma NSD:loi'; raise PROGRAM_ERROR;
end if;
select min(ten) into b_nsdT from ht_ma_nsd where ma_dvi=b_ma_dvi and ma=b_nsd;
if b_nsdT is null then b_loi:='loi:Sai ma NSD '||b_nsd||':'||b_ma_dvi||':loi'; raise PROGRAM_ERROR; end if;
if b_nv=' ' or b_nv not in ('XE','2B','TAU','PHH','PKT','PTN','NG','HANG','HOP','NONG') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_sp<>' ' then
    b_ma_spT:=FBH_PQU_SP_TEN(b_nv,b_ma_sp);
    if b_ma_spT is null then b_loi:='loi:Sai ma san pham:loi'; raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('ma_ql,ma_pqu,ghan,ma_qlt,ma_pqut');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_ql,a_ma_pqu,a_ghan,a_ma_qlT,a_ma_pquT using dt_dk;
if a_ma_ql.count=0 then b_loi:='loi:Chua nhap phan quyen:loi'; raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ma_lt,ten');
EXECUTE IMMEDIATE b_lenh bulk collect into a_lt_ma,a_lt_ten using dt_lt;
b_so_id:=FBH_PQU_NSD_SO_ID(b_ma_dvi,b_nsd,b_nv,b_ma_sp);
if b_so_id<>0 then
    delete bh_pqu_nsd_lt where so_id=b_so_id;
    delete bh_pqu_nsd_ct where so_id=b_so_id;
    delete bh_pqu_nsd where so_id=b_so_id;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
insert into bh_pqu_nsd values(b_so_id,b_ma_dvi,b_nsd,b_nv,b_ma_sp,b_nsdT,b_ma_spT);
forall b_lp in 1..a_ma_ql.count
    insert into bh_pqu_nsd_ct values(b_so_id,a_ma_ql(b_lp),a_ma_pqu(b_lp),a_ghan(b_lp),a_ma_qlT(b_lp),a_ma_pquT(b_lp));
forall b_lp in 1..a_lt_ma.count
    insert into bh_pqu_nsd_lt values(b_so_id,a_lt_ma(b_lp),a_lt_ten(b_lp));
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
-- Kiem tra quyen
create or replace procedure FBH_PQU_NHOM_GHANa(
    b_nhom varchar2,b_nv varchar2,b_ma_sp varchar2,
    a_ma_ql out pht_type.a_var,a_ma_pqu out pht_type.a_var,a_ghan out pht_type.a_num)
AS
    b_so_id number;
begin
-- Dan
b_so_id:=FBH_PQU_NHOM_SO_ID(b_nhom,b_nv,b_ma_sp);
if b_so_id=0 then
    PKH_MANG_KD(a_ma_ql); PKH_MANG_KD(a_ma_pqu); PKH_MANG_KD_N(a_ghan);
else
    select ma_ql,ma_pqu,ghan bulk collect into a_ma_ql,a_ma_pqu,a_ghan from bh_pqu_nhom_ct where so_id=b_so_id;
end if;
end;
/
create or replace procedure FBH_PQU_NSD_GHANa(
    b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ma_sp varchar2,
    a_ma_ql out pht_type.a_var,a_ma_pqu out pht_type.a_var,a_ghan out pht_type.a_num)
AS
    b_so_id number;
begin
-- Dan
b_so_id:=FBH_PQU_NSD_SO_ID(b_ma_dvi,b_nsd,b_nv,b_ma_sp);
if b_so_id=0 then
    PKH_MANG_KD(a_ma_ql); PKH_MANG_KD(a_ma_pqu); PKH_MANG_KD_N(a_ghan);
else
    select ma_ql,ma_pqu,ghan bulk collect into a_ma_ql,a_ma_pqu,a_ghan from bh_pqu_nsd_ct where so_id=b_so_id;
end if;
end;
/
create or replace procedure FBH_PQU_NHOM_GHAN(
    b_ma_dvi varchar2,b_nsd varchar2,a_nhom pht_type.a_var,b_nv varchar2,b_ma_sp varchar2,
    a_ma_ql out pht_type.a_var,a_ma_pqu out pht_type.a_var,a_ghan out pht_type.a_num,b_loi out varchar2)
AS
    b_so_id number; b_kt number:=0; b_ktC number; b_i1 number;
    a_ma_qlN pht_type.a_var; a_ma_pquN pht_type.a_var; a_ghanN pht_type.a_num;
begin
-- Dan
b_loi:='loi:Loi xu ly FBH_PQU_NHOM_GHAN:loi';
PKH_MANG_KD(a_ma_ql); PKH_MANG_KD(a_ma_pqu); PKH_MANG_KD_N(a_ghan);
for b_lpN in 1..a_nhom.count loop
    b_kt:=a_ma_ql.count; b_ktC:=b_kt;
    FBH_PQU_NHOM_GHANa(a_nhom(b_lpN),b_nv,b_ma_sp,a_ma_qlN,a_ma_pquN,a_ghanN);
    for b_lp in 1..a_ma_qlN.count loop
        b_i1:=0;
        for b_lp1 in 1..b_ktC loop
            if a_ma_ql(b_lp1)=a_ma_qlN(b_lp) and a_ma_pqu(b_lp1)=a_ma_pquN(b_lp) then
                if a_ghan(b_lp1)<a_ghanN(b_lp) then a_ghan(b_lp1):=a_ghanN(b_lp); end if;
                b_i1:=1; exit;
            end if;
        end loop;
        if b_i1=0 then
            b_kt:=b_kt+1;
            a_ma_ql(b_kt):=a_ma_qlN(b_lp); a_ma_pqu(b_kt):=a_ma_pquN(b_lp); a_ghan(b_kt):=a_ghanN(b_lp);
        end if;
    end loop;
end loop;
FBH_PQU_NSD_GHANa(b_ma_dvi,b_nsd,b_nv,b_ma_sp,a_ma_qlN,a_ma_pquN,a_ghanN);
if a_ma_qlN.count<>0 then
    b_kt:=a_ma_ql.count; b_ktC:=b_kt;
    for b_lp in 1..a_ma_qlN.count loop
        b_i1:=0;
        for b_lp1 in 1..b_ktC loop
            if a_ma_ql(b_lp1)=a_ma_qlN(b_lp) and a_ma_pqu(b_lp1)=a_ma_pquN(b_lp) then
                if a_ghan(b_lp1)<a_ghanN(b_lp) then a_ghan(b_lp1):=a_ghanN(b_lp); end if;
                b_i1:=1; exit;
            end if;
        end loop;
        if b_i1=0 then
            b_kt:=b_kt+1;
            a_ma_ql(b_kt):=a_ma_qlN(b_lp); a_ma_pqu(b_kt):=a_ma_pquN(b_lp); a_ghan(b_kt):=a_ghanN(b_lp);
        end if;
    end loop;
end if;
b_loi:='';
end;
/
create or replace procedure PBH_PQU_NHOM_KTHAC(
    b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ma_sp varchar2,dt_dk clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number;
    a_nhom pht_type.a_var; a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_tien pht_type.a_num; a_ptG pht_type.a_num;
    a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
begin
-- Dan - Duyet khai thac
b_loi:='loi:Loi xu ly PBH_PQU_NHOM_KTHAC:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
FBH_PQU_NHOM_GHAN(b_ma_dvi,b_nsd,a_nhom,b_nv,b_ma_sp,a_ma_ql,a_ma_pqu,a_ghan,b_loi);
if b_loi is not null then return; end if;
b_lenh:=FKH_JS_LENH('ma,ten,tien,ptg');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma,a_ten,a_tien,a_ptG using dt_dk;
for b_lp in 1..a_ma.count loop
    a_ten(b_lp):=a_ma(b_lp)||' - '||nvl(a_ten(b_lp),' ');
    for b_lp1 in 1..a_ma_ql.count loop
        if a_ma_ql(b_lp1)=a_ma(b_lp) then
            if a_ma_pqu(b_lp1)='HD_MKT' then
                if a_ghan(b_lp1)<0 then b_loi:='loi:Khong duoc khai thac '||a_ten(b_lp)||':loi'; return;
                elsif a_ghan(b_lp1)<a_tien(b_lp) then b_loi:='Vuot muc khai thac '||a_ten(b_lp)||':loi'; return;
                end if;
            end if;
            if a_ma_pqu(b_lp1)='HD_MGP' and a_ghan(b_lp1)<a_ptG(b_lp) then
                 b_loi:='Giam phi vuot muc phan cap '||a_ten(b_lp)||':loi'; return;
            end if;
        end if;
    end loop;
end loop;
b_loi:='';
end;
/
create or replace procedure FBH_PQU_NHOM_LT(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,a_nhom pht_type.a_var,b_nv varchar2,b_ma_sp varchar2,b_lt clob,b_loi out varchar2)
AS
    b_so_id number; b_kt number; b_lenh varchar2(1000);
    a_ma pht_type.a_var; a_ten pht_type.a_nvar; a_maN pht_type.a_var;
begin
-- Dan
b_loi:='loi:Loi xu ly FBH_PQU_NHOM_LT:loi';
PKH_MANG_KD(a_ma); PKH_MANG_KD_U(a_ten);
if a_nhom.count=0 then b_loi:=''; return; end if;
b_so_id:=FBH_PQU_NHOM_SO_ID(a_nhom(1),b_nv,b_ma_sp);
if b_so_id<>0 then
    select ma_lt,ten bulk collect into a_ma,a_ten from bh_pqu_nhom_lt where so_id=b_so_id;
end if;
if a_ma.count=0 then b_loi:=''; return; end if;
for b_lpN in 2..a_nhom.count loop
    b_so_id:=FBH_PQU_NHOM_SO_ID(a_nhom(b_lpN),b_nv,b_ma_sp);
    if b_so_id<>0 then
        b_kt:=a_ma.count;
        select ma_lt bulk collect into a_maN from bh_pqu_nhom_lt where so_id=b_so_id;
        for b_lp in reverse 1..b_kt loop
            if FKH_ARR_VTRI(a_maN,a_ma(b_lp))=0 then a_ma.delete(b_lp); a_ten.delete(b_lp); end if;
        end loop;
    end if;
end loop;
if a_ma.count=0 then b_loi:=''; return; end if;
b_so_id:=FBH_PQU_NSD_SO_ID(b_ma_dvi,b_nsd,b_nv,b_ma_sp);
if b_so_id<>0 then
    b_kt:=a_ma.count;
    select ma_lt bulk collect into a_maN from bh_pqu_nsd_lt where so_id=b_so_id;
    for b_lp in reverse 1..b_kt loop
        if FKH_ARR_VTRI(a_maN,a_ma(b_lp))=0 then a_ma.delete(b_lp); a_ten.delete(b_lp); end if;
    end loop;
end if;
if a_ma.count=0 then b_loi:=''; return; end if;
b_lenh:=FKH_JS_LENH('ma_lt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_maN using FKH_JS_BONH(b_lt);
for b_lp in 1..a_ma.count loop
    if FKH_ARR_VTRI(a_maN,a_ma(b_lp))=0 then b_loi:='loi: ' || b_dtuong || ' khong bo ma loai tru: '||a_ten(b_lp)|| '-' ||b_ma_sp|| ':loi'; return; end if;
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_PQU_NHOM_KTHACa(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nv varchar2,b_ma_sp varchar2,b_lt clob,
    a_ma pht_type.a_var,a_ten pht_type.a_nvar,a_tien pht_type.a_num,a_ptG pht_type.a_num,b_loi out varchar2)
AS
    a_nhom pht_type.a_var; a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
begin
-- Dan - Duyet khai thac
b_loi:='loi:Loi xu ly PBH_PQU_NHOM_KTHAC:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
FBH_PQU_NHOM_LT(b_ma_dvi,b_nsd,b_dtuong,a_nhom,b_nv,b_ma_sp,b_lt,b_loi);
if b_loi is not null then return; end if;
FBH_PQU_NHOM_GHAN(b_ma_dvi,b_nsd,a_nhom,b_nv,b_ma_sp,a_ma_ql,a_ma_pqu,a_ghan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_ma.count loop
    for b_lp1 in 1..a_ma_ql.count loop
        if a_ma_ql(b_lp1)=a_ma(b_lp) then
            if a_ma_pqu(b_lp1)='HD_MKT' then
                if a_ghan(b_lp1)<0 then b_loi:='loi:'||b_dtuong||' khong duoc khai thac '||a_ma(b_lp)||':loi'; return;
                elsif a_ghan(b_lp1)<a_tien(b_lp) then
                    b_loi:='loi:'||b_dtuong||' gioi han khai thac '||a_ma(b_lp)||': '||PKH_SO_CH(a_ghan(b_lp1))||':loi'; return;
                end if;
            end if;
            if a_ma_pqu(b_lp1)='HD_MGP' and a_ghan(b_lp1)<a_ptG(b_lp) then
                 b_loi:='loi:'||b_dtuong||' gioi han giam phi '||a_ma(b_lp)||': '||PKH_SO_CH(a_ghan(b_lp1))||':loi'; return;
            end if;
        end if;
    end loop;
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_PQU_NHOM_BTHa(
    b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ma_sp varchar2,
    a_ma pht_type.a_var,a_ten pht_type.a_nvar,a_tien pht_type.a_num,b_loi out varchar2)
AS
    a_nhom pht_type.a_var; a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
begin
-- Dan - Duyet boi thuong
b_loi:='loi:Loi xu ly PBH_PQU_NHOM_BTHa:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
FBH_PQU_NHOM_GHAN(b_ma_dvi,b_nsd,a_nhom,b_nv,b_ma_sp,a_ma_ql,a_ma_pqu,a_ghan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_ma.count loop
    for b_lp1 in 1..a_ma_ql.count loop
        if a_ma_ql(b_lp1)=a_ma(b_lp) and a_ma_pqu(b_lp1)='BT_MDU' and a_ghan(b_lp1)<a_tien(b_lp) then
            b_loi:='loi:Gioi han duyet boi thuong '||a_ten(b_lp)||': '||PKH_SO_CH(a_ghan(b_lp1))||':loi'; return;
        end if;
    end loop;
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_PQU_KTRA_BTMAa(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nv varchar2,b_loai varchar2,
    a_ma pht_type.a_var,a_ten pht_type.a_nvar,a_tien pht_type.a_num,b_loi out varchar2)
AS
    a_nhom pht_type.a_var; a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
begin
-- Nam - Duyet boi thuong
b_loi:='loi:Loi xu ly PBH_PQU_KTRA_BTMAa:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
FBH_PQU_NHOM_KH_GHAN(b_ma_dvi,b_nsd,a_nhom,b_nv,b_loai,a_ma_ql,a_ma_pqu,a_ghan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_ma.count loop
    for b_lp1 in 1..a_ma_ql.count loop
        if a_ma_ql(b_lp1)=a_ma(b_lp) and a_ma_pqu(b_lp1)='BT_MDU' and a_ghan(b_lp1)<a_tien(b_lp) then
           b_loi:='loi:'||b_dtuong||' gioi han duyet boi thuong '||a_ten(b_lp)||': '||PKH_SO_CH(a_ghan(b_lp1))||':loi'; return;
        end if;
    end loop;
end loop;
b_loi:='';
end;
/
create or replace procedure PBH_PQU_KTRA_BTMA(
    b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_tien number,
    a_loai pht_type.a_var,a_ma pht_type.a_var,a_loi pht_type.a_var,b_loi out varchar2)
as
    b_so_id number; a_nhom pht_type.a_var; 
begin
-- Nam - Kiem tra gioi han ma nhom
b_loi:='loi:Loi xu ly PBH_PQU_KTRA_BTMA:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
for b_lp in 1..a_loai.count loop
    for b_lp2 in 1..a_nhom.count loop
        b_so_id:=FBH_PQU_NHOM_KH_SO_ID(b_nv,a_loai(b_lp),a_nhom(b_lp2));
        if b_so_id<>0 then
            for r_lp in (select ma_ql,ghan,ma_pqu from bh_pqu_nhom_ct where so_id=b_so_id) loop
              if r_lp.ma_ql=a_ma(b_lp) and r_lp.ma_pqu='BT_MDU' and r_lp.ghan<b_tien then
                  b_loi:='loi:Gioi han duyet boi thuong '||a_loi(b_lp)||' ma '||a_ma(b_lp)||': '||FKH_SO_Fm(r_lp.ghan)||':loi'; return;
          end if;
            end loop;
        end if;
    end loop;
    b_so_id:=FBH_PQU_NSD_KH_SO_ID(b_nv,a_loai(b_lp),b_ma_dvi,b_nsd);
    if b_so_id<>0 then
        for r_lp in (select ma_ql,ghan,ma_pqu from bh_pqu_nsd_ct where so_id=b_so_id) loop
          if r_lp.ma_ql=a_ma(b_lp) and r_lp.ma_pqu='BT_MDU' and r_lp.ghan<b_tien then
                  b_loi:='loi:Gioi han duyet boi thuong '||a_loi(b_lp)||' ma '||a_ma(b_lp)||': '||FKH_SO_Fm(r_lp.ghan)||':loi'; return;
          end if;
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FBH_PQU_NHOM_KH_GHAN(
    b_ma_dvi varchar2,b_nsd varchar2,a_nhom pht_type.a_var,b_nv varchar2,b_loai varchar2,
    a_ma_ql out pht_type.a_var,a_ma_pqu out pht_type.a_var,a_ghan out pht_type.a_num,b_loi out varchar2)
AS
    b_so_id number; b_kt number:=0; b_ktC number; b_i1 number;
    a_ma_qlN pht_type.a_var; a_ma_pquN pht_type.a_var; a_ghanN pht_type.a_num;
begin
-- Dan
b_loi:='loi:Loi xu ly FBH_PQU_NHOM_KH_GHAN:loi';
PKH_MANG_KD(a_ma_ql); PKH_MANG_KD(a_ma_pqu); PKH_MANG_KD_N(a_ghan);
for b_lpN in 1..a_nhom.count loop
    b_kt:=a_ma_ql.count; b_ktC:=b_kt;
    FBH_PQU_NHOM_KH_GHANa(b_nv,b_loai,a_nhom(b_lpN),a_ma_qlN,a_ma_pquN,a_ghanN);
    for b_lp in 1..a_ma_qlN.count loop
        b_i1:=0;
        for b_lp1 in 1..b_ktC loop
            if a_ma_ql(b_lp1)=a_ma_qlN(b_lp) and a_ma_pqu(b_lp1)=a_ma_pquN(b_lp) then
                if a_ghan(b_lp1)<a_ghanN(b_lp) then a_ghan(b_lp1):=a_ghanN(b_lp); end if;
                b_i1:=1; exit;
            end if;
        end loop;
        if b_i1=0 then
            b_kt:=b_kt+1;
            a_ma_ql(b_kt):=a_ma_qlN(b_lp); a_ma_pqu(b_kt):=a_ma_pquN(b_lp); a_ghan(b_kt):=a_ghanN(b_lp);
        end if;
    end loop;
end loop;
FBH_PQU_NSD_KH_GHANa(b_nv,b_loai,b_ma_dvi,b_nsd,a_ma_qlN,a_ma_pquN,a_ghanN);
if a_ma_qlN.count<>0 then
    b_kt:=a_ma_ql.count; b_ktC:=b_kt;
    for b_lp in 1..a_ma_qlN.count loop
        b_i1:=0;
        for b_lp1 in 1..b_ktC loop
            if a_ma_ql(b_lp1)=a_ma_qlN(b_lp) and a_ma_pqu(b_lp1)=a_ma_pquN(b_lp) then
                if a_ghan(b_lp1)<a_ghanN(b_lp) then a_ghan(b_lp1):=a_ghanN(b_lp); end if;
                b_i1:=1; exit;
            end if;
        end loop;
        if b_i1=0 then
            b_kt:=b_kt+1;
            a_ma_ql(b_kt):=a_ma_qlN(b_lp); a_ma_pqu(b_kt):=a_ma_pquN(b_lp); a_ghan(b_kt):=a_ghanN(b_lp);
        end if;
    end loop;
end if;
b_loi:='';
end;
/
create or replace procedure PBH_PQU_NHOM_KTHAC_MAa(
    b_ma_dvi varchar2,b_nsd varchar2,b_dtuong varchar2,b_nv varchar2,b_loai varchar2,
    a_ma pht_type.a_var,a_ten pht_type.a_nvar,a_tien pht_type.a_num,a_ptG pht_type.a_num,b_loi out varchar2)
AS
    a_nhom pht_type.a_var; a_ma_ql pht_type.a_var; a_ma_pqu pht_type.a_var; a_ghan pht_type.a_num;
begin
-- Dan - Duyet khai thac
b_loi:='loi:Loi xu ly PBH_PQU_NHOM_KTHAC:loi';
FBH_PQU_NSD_NHOM(b_ma_dvi,b_nsd,a_nhom);
FBH_PQU_NHOM_KH_GHAN(b_ma_dvi,b_nsd,a_nhom,b_nv,b_loai,a_ma_ql,a_ma_pqu,a_ghan,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_ma.count loop
    for b_lp1 in 1..a_ma_ql.count loop
        if a_ma_ql(b_lp1)=a_ma(b_lp) then
            if a_ma_pqu(b_lp1)='HD_MKT' then
                if a_ghan(b_lp1)<0 then b_loi:='loi:'||b_dtuong||' khong duoc khai thac '||a_ten(b_lp)||':loi'; return;
                elsif a_ghan(b_lp1)<a_tien(b_lp) then
                    b_loi:='loi:'||b_dtuong||' gioi han khai thac '||a_ten(b_lp)||': '||PKH_SO_CH(a_ghan(b_lp1))||':loi'; return;
                end if;
            end if;
            if a_ma_pqu(b_lp1)='HD_MGP' and a_ghan(b_lp1)<a_ptG(b_lp) then
                if a_ghan(b_lp1)<100 then b_loi:='%:loi'; else b_loi:=':loi'; end if;
                b_loi:='loi:Dia diem:'||b_dtuong||', gioi han giam phi cho '||a_ten(b_lp)||': '||PKH_SO_CH(a_ghan(b_lp1))||b_loi; return;
            end if;
        end if;
    end loop;
end loop;
b_loi:='';
end;
/
