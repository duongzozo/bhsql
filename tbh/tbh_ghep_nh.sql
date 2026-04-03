-- Xu ly ty le tai
create or replace function FTBH_GHEP_NH_DT(
    b_nv varchar2,b_ngay_ht number,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_dk varchar2:='K') return nvarchar2
AS
    b_kq nvarchar2(500):='';
begin
-- Dan - Tra ten doi tuong
if b_nv='PHH' then
    b_kq:=FBH_PHH_DVI(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='PKT' then
    b_kq:=FBH_PKT_DVI(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='TAU' then
    b_kq:=FBH_TAU_BIEN(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='XE' then
    b_kq:=FBH_XE_BIEN(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='2B' then
    b_kq:=FBH_2B_BIEN(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
elsif b_nv='NG' then
    b_kq:=FBH_NG_TEN(b_ma_dvi,b_so_id,b_so_id_dt,b_ngay_ht);
end if;
if b_kq is not null and b_dk='C' then b_kq:=to_char(b_so_id_dt)||'|'||b_kq; end if;
return b_kq;
exception when others then return '';
end;
/
create or replace function FTBH_GHEP_NH_TEN(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_so_id_dt number,b_ngay number:=30000101) return nvarchar2
AS
    b_kq nvarchar2(500):=''; b_ten nvarchar2(500); b_so_idB number;
begin
-- Dan - Tra ten doi tuong
if b_nv='PHH' then
    b_so_idB:=FBH_PHH_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_ten from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    b_kq:=FBH_PHH_DVI(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay)||'/'||b_ten;
elsif b_nv='PKT' then
    b_so_idB:=FBH_PKT_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_ten from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    b_kq:=FBH_PKT_DVI(b_ma_dvi,b_so_idB,b_so_id_dt,b_ngay)||'/'||b_ten;
--nam: them so_id_dt=b_so_id_dt;
elsif b_nv='XE' then
    b_so_idB:=FBH_XE_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_ten from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    select decode(bien_xe,' ',so_khung,bien_xe) into b_kq from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    b_kq:=b_kq||'/'||b_ten;
elsif b_nv='TAU' then
    b_so_idB:=FBH_TAU_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_ten from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    select so_dk into b_kq from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    b_kq:=b_kq||'/'||b_ten;
elsif b_nv='2B' then
    b_so_idB:=FBH_2B_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_ten from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_idB;
    select decode(bien_xe,' ',so_khung,bien_xe) into b_kq from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
    b_kq:=b_kq||'/'||b_ten;
elsif b_nv='NG' then
    b_so_idB:=FBH_NG_SO_IDb(b_ma_dvi,b_so_id,b_ngay);
    select ten into b_kq from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_idB and so_id_dt=b_so_id_dt;
end if;
return b_kq;
end;
/
create or replace PROCEDURE PTBH_GHEP_NH_TIM(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_nv varchar2(10); b_ngayD number; b_ngayC number;
    b_so_ct varchar2(20); b_so_hd varchar2(20); cs_lke clob:='';
begin
-- Dan - Tim ty le tai co dinh
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,so_ct,so_hd');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_so_ct,b_so_hd using b_oraIn;
if b_ngayD in (0,30000101) then b_ngayD:=PKH_NG_CSO(add_months(sysdate,-36)); end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_so_ct:=trim(b_so_ct);
if b_so_ct is not null then b_so_ct:='%'||upper(b_so_ct)||'%'; end if;
b_so_hd:=trim(b_so_hd);
if b_so_hd is not null then b_so_hd:='%'||upper(b_so_hd)||'%'; end if;
select JSON_ARRAYAGG(json_object(
    a.so_id,a.ngay_ht,a.so_ct,b.ma_dvi_hd,b.so_hd,'ten' value FTBH_GHEP_NH_TEN(b_nv,b.ma_dvi_hd,b.so_id_hd,b.so_id_dt))
    order by a.ngay_ht desc,a.so_ct returning clob) into cs_lke
    from tbh_ghep a,tbh_ghep_hd b where
    a.nv=b_nv and a.ngay_ht between b_ngayD and b_ngayC and
    (b_so_ct is null or upper(a.so_ct) like b_so_ct) and
    b.so_id=a.so_id and (b_so_hd is null or upper(b.so_hd) like b_so_hd) and rownum<200;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_TIMh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(1000); b_lenh varchar2(1000); b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_so_id number; b_so_idC number; b_so_idD number; b_nv varchar2(10);
    b_ma_kh varchar2(20); b_so_hd varchar2(20); b_ma_dviD varchar2(10);
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(20);
    b_ngayD number; b_ngayC number; b_ten nvarchar2(200);
    b_tu number; b_den number; cs_lke clob:='';
begin
-- Dan - Tim hop dong qua CMT, mobi, email
delete ket_qua; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,cmt,mobi,email,ten,so_hd,ngayd,ngayc,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_cmt,b_mobi,b_email,b_ten,b_so_hd,b_ngayD,b_ngayC,b_tu,b_den using b_oraIn;
b_ma_kh:=FBH_DTAC_MAt(b_cmt,b_mobi,b_email);
if b_ngayd in (0,30000101) then b_ngayd:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
b_ten:=nvl(trim(b_ten),' ');
if b_ten<>' ' then b_ten:='%'||upper(b_ten)||'%'; end if;
b_so_hd:=nvl(trim(b_so_hd),' '); b_ma_kh:=nvl(trim(b_ma_kh),' ');
if b_nv='PHH' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_phh where 
        ngay_ht between b_ngayD and b_ngayC and ngay_kt>b_ngay and
        b_ma_kh in(' ',ma_kh) and b_so_hd in(' ',b_so_hd) and 
        (b_ten=' ' OR upper(ten) like b_ten)) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; 
        if FBH_PHH_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_PHH_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_PHH_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_phh where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_PHH_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||dvi,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_phh_dvi where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='PKT' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_pkt where 
        ngay_ht between b_ngayD and b_ngayC and ngay_kt>b_ngay and
        b_ma_kh in(' ',ma_kh) and b_so_hd in(' ',b_so_hd) and 
        (b_ten=' ' OR upper(ten) like b_ten)) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; 
        if FBH_PKT_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_PKT_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_PKT_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_pkt where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_PKT_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||dvi,ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_pkt_dvi where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='XE' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_xe where
        ngay_ht between b_ngayD and b_ngayC and ngay_kt>b_ngay and
        b_ma_kh in(' ',ma_kh) and b_so_hd in(' ',b_so_hd) and 
        (b_ten=' ' OR upper(ten) like b_ten)) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; 
        if FBH_XE_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_XE_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_XE_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_xe where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_XE_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||decode(bien_xe,' ',so_khung,bien_xe),
                    ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_xe_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='2B' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_2b where 
        ngay_ht between b_ngayD and b_ngayC and ngay_kt>b_ngay and
        b_ma_kh in(' ',ma_kh) and b_so_hd in(' ',b_so_hd) and 
        (b_ten=' ' OR upper(ten) like b_ten)) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; 
        if FBH_2B_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_2B_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_2B_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_2b where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_2B_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||decode(bien_xe,' ',so_khung,bien_xe),
                    ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_2b_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
elsif b_nv='TAU' then
    for r_lp in (select distinct ma_dvi,so_id_d from bh_tau where 
        ngay_ht between b_ngayD and b_ngayC and ngay_kt>b_ngay and
        b_ma_kh in(' ',ma_kh) and b_so_hd in(' ',b_so_hd) and 
        (b_ten=' ' OR upper(ten) like b_ten)) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; 
        if FBH_TAU_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_TAU_SO_IDc(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_TAU_SO_HDd(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_TAU where ma_dvi=b_ma_dviD and so_id=b_so_idC;
            if FBH_TAU_NV(b_ma_dviD,b_so_idD)='H' then
                insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                    select ' ','- '||so_dk||ten_tau,
                    ngay_hl,ngay_kt,ngay_cap,b_so_idD,so_id_dt,' ',b_ma_dviD,b_so_hd
                    from bh_tau_ds where ma_dvi=b_ma_dviD and so_id=b_so_idC order by bt;
            end if;
        end if;
    end loop;
else
    for r_lp in (select distinct ma_dvi,so_id_d from bh_hd_goc where 
        ngay_ht between b_ngayD and b_ngayC and ngay_kt>b_ngay and
        b_ma_kh in(' ',ma_kh) and b_so_hd in(' ',b_so_hd) and 
        (b_ten=' ' OR upper(ten) like b_ten)) loop
        b_ma_dviD:=r_lp.ma_dvi; b_so_idD:=r_lp.so_id_d; 
        if FBH_HD_TTRANG(b_ma_dviD,b_so_idD)='D' then
            b_so_idC:=FBH_HD_SO_ID_BS(b_ma_dviD,b_so_idD);
            b_so_hd:=FBH_HD_GOC_SO_HD(b_ma_dviD,b_so_idD);
            insert into ket_qua(c1,c2,n1,n2,n3,n10,n11,c11,c12,c14)
                select b_so_hd,ten,ngay_hl,ngay_kt,ngay_cap,b_so_idD,0,b_ma_dviD,b_ma_dviD,b_so_hd
                from bh_hd_goc where ma_dvi=b_ma_dviD and so_id=b_so_idC;
        end if;
    end loop;
end if;
select JSON_ARRAYAGG(json_object('ma_dviH' value c11,'so_hdH' value c1,'ten' value c2,
    'ngay_hl' value n1,'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n10,
    'so_id_dt' value n11,'ma_dvi' value c12,'so_hd' value c14 returning clob)
    order by n10 desc,n11 returning clob) into cs_lke from ket_qua where rownum<200;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_SO_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_so_ct varchar2(20):=trim(b_oraIn); b_so_id number:=0;
begin
-- Dan - Tra so ID qua so CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_ct is not null then b_so_id:=FTBH_GHEP_SO_CT(b_so_ct); end if;
select json_object('so_id' value b_so_id) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_DT(
    b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_nv varchar2(10); b_ngay_ht number; b_ma_dvi varchar2(10); b_so_hd varchar2(20);
    b_so_id number; cs_lke clob:='';
begin
-- Dan - Liet ke doi tuong theo hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dviN,b_nsd,b_pas,'BH','TBH','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngay_ht,ma_dvi,so_hd');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngay_ht,b_ma_dvi,b_so_hd using b_oraIn;
if b_nv='PHH' then
    b_so_id:=FBH_PHH_HD_SO_IDb(b_ma_dvi,b_so_hd,b_ngay_ht);
    if b_so_id<>0 then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value dvi) order by dvi returning clob)
            into cs_lke from bh_phh_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
elsif b_nv='PKT' then
    b_so_id:=FBH_PKT_HD_SO_IDb(b_ma_dvi,b_so_hd,b_ngay_ht);
    if b_so_id<>0 then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),'ten' value dvi) order by dvi returning clob)
            into cs_lke from bh_pkt_dvi where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
elsif b_nv='XE' then
    b_so_id:=FBH_XE_HD_SO_IDb(b_ma_dvi,b_so_hd,b_ngay_ht);
    if b_so_id<>0 then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),
            'ten' value decode(bien_xe,' ',so_khung,bien_xe)) order by bien_xe,so_khung returning clob)
            into cs_lke from bh_xe_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
elsif b_nv='2B' then
    b_so_id:=FBH_2B_HD_SO_IDb(b_ma_dvi,b_so_hd,b_ngay_ht);
    if b_so_id<>0 then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),
            'ten' value decode(bien_xe,' ',so_khung,bien_xe)) order by bien_xe,so_khung returning clob)
            into cs_lke from bh_2b_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
elsif b_nv='TAU' then
    b_so_id:=FBH_TAU_HD_SO_IDb(b_ma_dvi,b_so_hd,b_ngay_ht);
    if b_so_id<>0 then
        select JSON_ARRAYAGG(json_object('ma' value to_char(so_id_dt),
            'ten' value so_dk||'-'||ten_tau) order by so_dk returning clob)
            into cs_lke from bh_tau_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_NV(
    dt_ct clob,dt_hd clob,cs_nv out clob,b_loi out varchar2)
AS
    b_lenh varchar2(2000);
    b_ngay_hl number; b_ngay_kt number; b_ngay_ht number; b_nv varchar2(10);
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_so_ctG varchar2(20); b_pt_con number; b_tien_con number;
    a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp;
b_lenh:=FKH_JS_LENH('ngay_ht,ngay_hl,nt_tien,nt_phi,so_ctg,nv');
EXECUTE IMMEDIATE b_lenh into b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,b_so_ctG,b_nv using dt_ct;
b_lenh:=FKH_JS_LENH('ma_dvi_hd,so_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_dvi,a_so_hd,a_so_id_dt using dt_hd;
if a_ma_dvi.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_ma_dvi.count loop
    a_so_id(b_lp):=FBH_HD_GOC_SO_ID_DAU(a_ma_dvi(b_lp),a_so_hd(b_lp));
end loop;
if b_ngay_hl in(0,30000101) then
    FBH_HD_NGAYh_ARR(a_ma_dvi,a_so_id,b_ngay_hl,b_ngay_kt);
end if;
PTBH_GHEP_NV(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id,a_so_id_dt,b_loi,'{"nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
select JSON_ARRAYAGG(json_object(*) order by ma_ta returning clob) into cs_nv from tbh_ghep_nv_temp0;
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NH_NV:loi'; end if;
end;
/
create or replace procedure FTBH_GHEP_NH_HD(
    dt_ct clob,dt_hd clob,cs_nv out clob,cs_phi out clob,cs_tl out clob,b_loi out varchar2,b_dk varchar2:='C')
AS
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp;
delete tbh_ghep_tl_temp5; delete tbh_ghep_tl_temp6;
delete tbh_ghep_tl_temp7;
FTBH_GHEP_NH_PHI(dt_ct,dt_hd,b_loi);
if b_loi is not null then return; end if;
select JSON_ARRAYAGG(json_object(*) order by ma_ta returning clob) into cs_nv from tbh_ghep_nv_temp0;
select JSON_ARRAYAGG(json_object(
    ma_ta,so_hd_ta,'ten' value FBH_DTAC_MA_TEN(nbh),kieu,pt,tien,phi,pt_hh,hhong,tl_thue,thue,nbh,nbhC,so_id_ta)
    order by ma_ta,so_hd_ta,nbhC,nbh returning clob) into cs_tl from tbh_ghep_tl_temp6;
select JSON_ARRAYAGG(json_object(ngay,ma_ta,so_hd_ta,pt,tien,phi,so_id_ta)
    order by ngay,ma_ta,so_id_ta returning clob) into cs_phi from tbh_ghep_tl_temp7;
delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp; delete tbh_ghep_tl_temp6;
if b_dk='C' then
    delete tbh_ghep_tl_temp5; delete tbh_ghep_tl_temp7;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_GHEP_NH_HD:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NH_HD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(1000);
    dt_ct clob; dt_hd clob;
    cs_nv clob; cs_phi clob; cs_tl clob; cs_mata clob;
begin
-- Dan - Tra ghep nghiep vu BH => nghiep vu tai
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd);
FTBH_GHEP_NH_HD(dt_ct,dt_hd,cs_nv,cs_phi,cs_tl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
select JSON_ARRAYAGG(json_object('ma' value ma_ta,'ten' value FBH_MA_LHNV_TAI_TEN(ma_ta)) order by ma_ta) into cs_mata from
    (select distinct ma_ta from tbh_ghep_nv_temp0);
select json_object('cs_nv' value cs_nv,'cs_phi' value cs_phi,
    'cs_tl' value cs_tl returning clob) into b_oraOut from dual;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FTBH_GHEP_NH_CT(
    b_so_id number,dt_ct out clob,dt_hd out clob,b_loi out varchar2,b_dk varchar2:='N')
AS
    b_nv varchar2(10); b_ngay_ht number; b_ngay_hl number; b_ngay_kt number;
    b_ma_dvi_hd varchar2(10); b_so_id_hd number; b_nt_tien varchar2(5); b_nt_phi varchar2(5);
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
begin
-- Dan - Xem
select nv,ngay_ht,ma_dvi_hd,so_id_hd into b_nv,b_ngay_ht,b_ma_dvi_hd,b_so_id_hd from tbh_cbi where so_id=b_so_id;
PBH_HD_NTE(b_ma_dvi_hd,b_so_id_hd,b_nt_tien,b_nt_phi);
select ma_dvi_hd,so_id_hd bulk collect into a_ma_dvi,a_so_id from tbh_cbi_hd where so_id=b_so_id;
FBH_HD_NGAYh_ARR(a_ma_dvi,a_so_id,b_ngay_hl,b_ngay_kt);
select json_object('nv' value nv,'ngay_ht' value ngay_ht,'so_ct' value so_ct,
    'kieu' value kieu,'so_ctg' value so_ctG,'nd' value nd,'ngay_hl' value b_ngay_hl,'ngay_kt' value b_ngay_kt,
    'nt_tien' value b_nt_tien,'nt_phi' value b_nt_phi) into dt_ct from tbh_cbi where so_id=b_so_id;
if b_dk='N' then
    --nampb: set key
    select JSON_ARRAYAGG(json_object('ma_dvi_hd' value ma_dvi_hd,'so_hd' value so_hd,
        'so_id_dt' value so_id_dt||'|'||FTBH_GHEP_NH_DT(b_nv,b_ngay_ht,ma_dvi_hd,so_id_hd,so_id_dt),so_id_hd)
        order by bt returning clob) into dt_hd from tbh_cbi_hd where so_id=b_so_id;
else
    select JSON_ARRAYAGG(json_object('ma_dvi_hd' value ma_dvi_hd,'so_hd' value so_hd,'so_id_dt' value so_id_dt,'so_id_hd' value so_id_hd)
        order by bt returning clob) into dt_hd from tbh_cbi_hd where so_id=b_so_id;
end if;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly FTBH_GHEP_NH_CT:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NH_CT(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_i1 number; b_lenh varchar2(2000); b_so_id number; b_klk varchar2(1);
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num; a_so_id_dt pht_type.a_num;
    dt_ct clob:=''; dt_hd clob:=''; dt_phi clob:=''; dt_tl clob:=''; dt_nv clob:=''; dt_txt clob:='';
begin
-- Dan - Xem
delete tbh_ghep_tl_temp2; delete tbh_ghep_nv_temp0; delete tbh_ghep_nv_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,klk');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_klk using b_oraIn;
select count(*) into b_i1 from tbh_ghep where so_id=b_so_id;
if b_i1<>0 then
    select txt into dt_ct from tbh_ghep_txt where so_id=b_so_id and loai='dt_ct';
    select txt into dt_hd from tbh_ghep_txt where so_id=b_so_id and loai='dt_hd';
    PTBH_GHEP_NH_NV(dt_ct,dt_hd,dt_nv,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    select JSON_ARRAYAGG(json_object(ma_dvi_hd,so_hd,'so_id_dt' value so_id_dt||'|'||ten)
        order by bt returning clob) into dt_hd from tbh_ghep_hd where so_id=b_so_id;
    select txt into dt_phi from tbh_ghep_txt where so_id=b_so_id and loai='dt_phi';
    select txt into dt_tl from tbh_ghep_txt where so_id=b_so_id and loai='dt_tl';    
    select JSON_ARRAYAGG(json_object(loai,txt returning clob) returning clob) into dt_txt
        from tbh_ghep_txt where so_id=b_so_id and loai='dt_ct';
else
    select count(*) into b_i1 from tbh_cbi where so_id=b_so_id;
    if b_i1<>0 then
        FTBH_GHEP_NH_CT(b_so_id,dt_ct,dt_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
end if;
select json_object('so_id' value b_so_id,'klk' value b_klk,'dt_hd' value dt_hd,
    'dt_phi' value dt_phi,'dt_tl' value dt_tl,'dt_nv' value dt_nv,
    'dt_ct' value dt_ct,'txt' value dt_txt returning clob) into b_oraOut from dual;
exception when others then 
    if b_loi is null then  raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_LKE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(2000); b_lenh varchar2(2000);
    b_nv varchar2(10); b_ngayD number; b_ngayC number; b_klk varchar2(1); b_tu number; b_den number;
    b_dong number; cs_lke clob;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('nv,ngayd,ngayc,klk,tu,den');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngayD,b_ngayC,b_klk,b_tu,b_den using b_oraIn;
if b_klk='C' then
    select count(*) into b_dong from tbh_cbi where
        FTBH_CBI_NGAY(so_id) between b_ngayD and b_ngayC and nv=b_nv and kieu_xl='C' and phai_xl='K';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
        (select so_id,ma_dvi_hd ma_dvi,FBH_HD_GOC_SO_HD(ma_dvi_hd,so_id_hd) so_ct,rownum sott from tbh_cbi where
        FTBH_CBI_NGAY(so_id) between b_ngayd and b_ngayc and nv=b_nv and kieu_xl='C' and phai_xl='K' order by ma_dvi_hd,so_ct)
        where sott between b_tu and b_den;
elsif b_klk='K' then
    select count(*) into b_dong from tbh_cbi where
        FTBH_CBI_NGAY(so_id) between b_ngayd and b_ngayc and nv=b_nv and kieu_xl='K' and phai_xl='K';
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
        (select so_id,ma_dvi_hd ma_dvi,so_ct,rownum sott from tbh_cbi where
        FTBH_CBI_NGAY(so_id) between b_ngayd and b_ngayc and nv=b_nv and kieu_xl='K' and phai_xl='K' order by ma_dvi_hd,so_ct)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_ghep where ngay_ht between b_ngayd and b_ngayc and nv=b_nv;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
        (select so_id,PKH_SO_CNG(ngay_ht) ma_dvi,so_ct,rownum sott from tbh_ghep where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv order by ngay_ht desc,so_ct desc)
        where sott between b_tu and b_den;
end if;
select json_object('dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_LKE_ID (
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_so_ct varchar2(20); b_ngayD number; b_ngayC number; b_nv varchar2(10); b_klk varchar2(1); b_trangKt number;
    b_dong number; cs_lke clob; b_tu number; b_den number; b_trang number;
begin
-- Dan - Liet ke tu so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_ct,ngayd,ngayc,nv,klk,trangkt');
EXECUTE IMMEDIATE b_lenh into b_so_ct,b_ngayD,b_ngayC,b_nv,b_klk,b_trangKt using b_oraIn;
if b_klk='N' then
    select count(*) into b_dong from tbh_ghep where ngay_ht between b_ngayd and b_ngayc and nv=b_nv and nsd=b_nsd;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_ct,rownum sott from tbh_ghep where
            ngay_ht between b_ngayd and b_ngayc and nv=b_nv and nsd=b_nsd order by ngay_ht desc,so_ct desc)
        where so_ct<=b_so_ct;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
        (select so_id,PKH_SO_CNG(ngay_ht) ma_dvi,so_ct,rownum sott from tbh_ghep where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv and nsd=b_nsd order by ngay_ht desc,so_ct desc)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tbh_ghep where ngay_ht between b_ngayd and b_ngayc and nv=b_nv;
    select nvl(min(sott),b_dong) into b_tu from
        (select so_ct,rownum sott from tbh_ghep where
            ngay_ht between b_ngayd and b_ngayc and nv=b_nv order by ngay_ht desc,so_ct desc)
        where so_ct<=b_so_ct;
    PKH_LKE_VTRI(b_trangKt,b_tu,b_den,b_trang);
    select JSON_ARRAYAGG(json_object(so_id,ma_dvi,so_ct)) into cs_lke from
        (select so_id,PKH_SO_CNG(ngay_ht) ma_dvi,so_ct,rownum sott from tbh_ghep where
        ngay_ht between b_ngayd and b_ngayc and nv=b_nv order by ngay_ht desc,so_ct desc)
        where sott between b_tu and b_den;
end if;
select json_object('trang' value b_trang,'dong' value b_dong,'cs_lke' value cs_lke) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_TEST(
    b_ma_dvi varchar2,b_so_id number,dt_ct in out clob,dt_hd clob,dt_phi out clob,dt_tl out clob,
    b_nv out varchar2,b_ngay_ht out number,b_so_ct out varchar2,b_kieu out varchar2,b_so_ctG out varchar2,
    b_ngay_hl out number,b_ngay_kt out number,b_nt_tien out varchar2,b_nt_phi out varchar2,
    b_nguon out varchar2,b_pphap out varchar2,b_so_idD out number,b_so_idG out number,

    a_ma_dvi out pht_type.a_var,a_so_hd out pht_type.a_var,a_so_id_hd out pht_type.a_num,
    a_so_id_dt out pht_type.a_num,a_ten out pht_type.a_nvar,

    a_ngay_hl out pht_type.a_num,a_ma_ta out pht_type.a_var,a_so_id_ta out pht_type.a_num,
    a_so_hd_ta out pht_type.a_var,a_pthuc out pht_type.a_var,
    a_pt out pht_type.a_num,a_tien out pht_type.a_num,a_phi out pht_type.a_num,

    tl_ngay_hl out pht_type.a_num,tl_ma_ta out pht_type.a_var,tl_so_id_ta out pht_type.a_num,
    tl_so_hd_ta out pht_type.a_var,tl_pthuc out pht_type.a_var,
    tl_nbh out pht_type.a_var,tl_nbhC out pht_type.a_var,tl_kieu out pht_type.a_var,
    tl_pt out pht_type.a_num,tl_ptt out pht_type.a_num,tl_tien out pht_type.a_num,
    tl_phi out pht_type.a_num,tl_pt_hh out pht_type.a_num,tl_hhong out pht_type.a_num,
    tl_tl_thue out pht_type.a_num,tl_thue out pht_type.a_num,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_i2 number; dt_nv clob;
begin
-- Dan - Kiem tra so lieu
b_lenh:=FKH_JS_LENH('nv,ngay_ht,so_ct,kieu,so_ctg,ngay_hl,ngay_kt,nt_tien,nt_phi,nguon,pphap');
EXECUTE IMMEDIATE b_lenh into b_nv,b_ngay_ht,b_so_ct,b_kieu,b_so_ctG,
    b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pphap using dt_ct;
if b_nv not in ('XE','2B','HANG','PHH','PKT','PTN','NG','TAU') or b_kieu not in('G','B','T')  then
    b_loi:='loi:Sai nghiep vu:loi'; return;
end if;
b_nguon:=nvl(trim(b_nguon),'B'); b_pphap:=nvl(trim(b_pphap),'D');
if b_ngay_ht is null or b_ngay_ht in(0,30000101) then b_ngay_ht:=PKH_NG_CSO(sysdate); end if;
b_nt_tien:=nvl(trim(b_nt_tien),'VND'); b_nt_phi:=nvl(trim(b_nt_tien),'VND');
--nampb: kiem tra ngoai te bao hiem
if b_nt_tien<>' VND' and FBH_TT_KTRA(b_nt_tien)<>'C' then
    b_loi:='loi:Nhap sai loai tien bao hiem:loi'; return;
end if;
if b_nt_phi<>'VND' and FBH_TT_KTRA(b_nt_phi)<>'C' then
    b_loi:='loi:Nhap sai loai tien phi:loi'; return;
end if;
b_lenh:=FKH_JS_LENH('ma_dvi_hd,so_hd,so_id_dt');
EXECUTE IMMEDIATE b_lenh bulk collect into a_ma_dvi,a_so_hd,a_so_id_dt using dt_hd;
if a_ma_dvi.count=0 then b_loi:='loi:Nhap hop dong tai:loi'; return; end if;
for b_lp in 1..a_ma_dvi.count loop
    b_loi:='loi:Sai so lieu hop dong dong '||trim(to_char(b_lp))||':loi';
    if a_ma_dvi(b_lp)=' ' or a_so_hd(b_lp)=' ' then return; end if;
    a_so_id_hd(b_lp):=FBH_HD_GOC_SO_ID_DAU(a_ma_dvi(b_lp),a_so_hd(b_lp));
    if a_so_id_hd(b_lp)=0 then
        b_loi:='loi:Hop dong '||a_so_hd(b_lp)||' da xoa:loi'; return;
    end if;
    if b_nv<>FBH_HD_NV(a_ma_dvi(b_lp),a_so_id_hd(b_lp)) then
        b_loi:='loi:Hop dong '||a_so_hd(b_lp)||' khac nghiep vu:loi'; return;
    end if;
    if b_nv not in('PHH','PKT','TAU','XE','2B','NG') then
        a_so_id_dt(b_lp):=0; a_ten(b_lp):=' ';
    else
        if a_so_id_dt(b_lp)=0 then a_so_id_dt(b_lp):=a_so_id_hd(b_lp); end if;
        a_ten(b_lp):=FTBH_GHEP_NH_DT(b_nv,b_ngay_ht,a_ma_dvi(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp));
    end if;
end loop;
if b_ngay_hl in(0,30000101) or b_ngay_kt in(0,30000101) then
    FBH_HD_NGAYh_ARR(a_ma_dvi,a_so_id_hd,b_i1,b_i2);
    if b_ngay_hl in(0,30000101) then b_ngay_hl:=b_i1; end if;
    if b_ngay_kt in(0,30000101) then b_ngay_kt:=b_i2; end if;
end if;
if b_so_ctG=' ' then
    b_kieu:='G'; b_so_idD:=b_so_id; b_so_idG:=0;
    if b_so_ct is null then b_so_ct:=substr(trim(to_char(b_so_id)),3); end if;
else
    if b_kieu not in('B','T') then b_loi:='loi:Sai kieu:loi'; return; end if;
    b_loi:='loi:So cu da xoa:loi';
    select ngay_ht,ngay_kt,so_id_d,so_id into b_i1,b_i2,b_so_idD,b_so_idG from tbh_ghep where so_ct=b_so_ctG;
    if b_i1>b_ngay_ht then b_loi:='loi:Ngay sua doi phai sau ngay phat sinh goc:loi'; return; end if;
    if b_kieu='T' and b_i2>b_ngay_hl then b_loi:='loi:Ngay tai tuc moi phai sau ngay het hieu luc cu:loi'; return; end if;
    select count(*) into b_i1 from tbh_ghep where so_id_g=b_so_idG;
    if b_i1<>0 then b_loi:='loi:Chung tu goc da co sua doi bo sung:loi'; return; end if;
    if b_so_ct is null then b_so_ct:=FTBH_SO_BS(b_so_idD); end if;
end if;
FTBH_GHEP_NH_HD(dt_ct,dt_hd,dt_nv,dt_phi,dt_tl,b_loi,'K');
if b_loi is not null then return; end if;
select ngay,ma_ta,so_id_ta,so_hd_ta,pthuc,nbh,nbhC,kieu,pt,ptC,tien,phi,pt_hh,hhong,tl_thue,thue
    bulk collect into tl_ngay_hl,tl_ma_ta,tl_so_id_ta,tl_so_hd_ta,tl_pthuc,tl_nbh,tl_nbhC,
    tl_kieu,tl_pt,tl_ptt,tl_tien,tl_phi,tl_pt_hh,tl_hhong,tl_tl_thue,tl_thue from tbh_ghep_tl_temp5;
select ngay,ma_ta,so_id_ta,so_hd_ta,pthuc,pt,tien,phi bulk collect into
    a_ngay_hl,a_ma_ta,a_so_id_ta,a_so_hd_ta,a_pthuc,a_pt,a_tien,a_phi from tbh_ghep_tl_temp7;
delete tbh_ghep_tl_temp5; delete tbh_ghep_tl_temp7;
PKH_JS_THAY(dt_ct,'so_ct',b_so_ct);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NH_TEST:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NH_XOA_XOA(
    b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_nsdC varchar2(10);
begin
-- Dan - Xoa
select count(*),min(nsd) into b_i1,b_nsdC from tbh_ghep where so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
if trim(b_nsdC) is not null and b_nsd<>b_nsdC then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
select count(*) into b_i1 from tbh_ghep where so_id_g=b_so_id;
if b_i1<>0 then b_loi:='loi:Xu ly tai da co sua doi, bo sung:loi'; return; end if;
select nvl(max(so_id_xl),0) into b_i1 from tbh_ps where so_id_nv=b_so_id;
if b_i1<>0 then b_loi:='loi:Xu ly tai da xu ly phat sinh:loi'; return; end if;
delete tbh_ps_ton where so_id_nv=b_so_id;
delete tbh_ps_pbo where so_id_nv=b_so_id;
delete tbh_ps where so_id_nv=b_so_id;
delete tbh_ghep_txt where so_id=b_so_id;
delete tbh_ghep_pbo where so_id=b_so_id;
delete tbh_ghep_phi where so_id=b_so_id;
delete tbh_ghep_ky where so_id=b_so_id;
delete tbh_ghep_hd where so_id=b_so_id;
delete tbh_ghep where so_id=b_so_id;
update tbh_cbi set kieu_xl='C' where so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NH_XOA_XOA:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,
    b_nv varchar2,b_ngay_ht number,b_so_ct varchar2,b_kieu varchar2,b_so_ctG varchar2,
    b_ngay_hl number,b_ngay_kt number,b_nt_tien varchar2,b_nt_phi varchar2,
    b_nguon varchar2,b_pphap varchar2,b_so_idD number,b_so_idG number,
    a_ma_dvi pht_type.a_var,a_so_hd pht_type.a_var,a_so_id_hd pht_type.a_num,
    a_so_id_dt pht_type.a_num,a_ten pht_type.a_nvar,
    a_ngay_hl pht_type.a_num,a_ma_ta pht_type.a_var,a_so_id_ta pht_type.a_num,
    a_so_hd_ta pht_type.a_var,a_pthuc pht_type.a_var,
    a_pt pht_type.a_num,a_tien pht_type.a_num,a_phi pht_type.a_num,
    tl_ngay_hl pht_type.a_num,tl_ma_ta pht_type.a_var,tl_so_id_ta pht_type.a_num,
    tl_so_hd_ta pht_type.a_var,tl_pthuc pht_type.a_var,
    tl_nha_bh pht_type.a_var,tl_kieu pht_type.a_var,tl_pt pht_type.a_num,
    tl_ptt pht_type.a_num,tl_tien pht_type.a_num,tl_phi pht_type.a_num,
    tl_pt_hh pht_type.a_num,tl_hhong pht_type.a_num,tl_tl_thue pht_type.a_num,
    tl_thue pht_type.a_num,tl_nha_bhC pht_type.a_var,
    dt_ct clob,dt_hd clob,dt_phi clob,dt_tl clob,b_loi out varchar2,b_cbi varchar2:='K')
AS
    b_i1 number; b_i2 number; b_kt number:=0; b_hhong number:=0; b_pt_hh number;
    a_pbo_pthuc pht_type.a_var; a_pbo_ma_ta pht_type.a_var; a_pbo_pt pht_type.a_num;
    a_pbo_tien pht_type.a_num; a_pbo_phi pht_type.a_num; a_pbo_hhong pht_type.a_num;
begin
insert into tbh_ghep values(b_so_id,b_ngay_ht,b_nv,b_so_ct,b_kieu,b_so_ctG,
    b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_pphap,b_nguon,b_so_idD,b_so_idG,b_nsd,sysdate);
for b_lp in 1..a_ma_dvi.count loop
    b_i1:=FBH_HD_SO_ID_BS(a_ma_dvi(b_lp),a_so_id_hd(b_lp));
    insert into tbh_ghep_hd values(b_so_id,a_ma_dvi(b_lp),a_so_hd(b_lp),a_so_id_hd(b_lp),a_so_id_dt(b_lp),a_ten(b_lp),b_i1,b_lp);
end loop;
for b_lp in 1..a_ngay_hl.count loop
    insert into tbh_ghep_ky values(
        b_so_id,a_ngay_hl(b_lp),a_ma_ta(b_lp),a_so_id_ta(b_lp),a_so_hd_ta(b_lp),
        a_pthuc(b_lp),a_pt(b_lp),a_tien(b_lp),a_phi(b_lp),b_lp);
end loop;
for b_lp in 1..tl_ngay_hl.count loop
    insert into tbh_ghep_phi values(
        b_so_id,tl_ngay_hl(b_lp),tl_ma_ta(b_lp),tl_so_id_ta(b_lp),tl_so_hd_ta(b_lp),tl_pthuc(b_lp),
        tl_nha_bh(b_lp),tl_kieu(b_lp),tl_pt(b_lp),tl_ptt(b_lp),tl_tien(b_lp),tl_phi(b_lp),
        tl_pt_hh(b_lp),tl_hhong(b_lp),tl_tl_thue(b_lp),tl_thue(b_lp),tl_nha_bhC(b_lp),b_lp);
    b_hhong:=b_hhong+tl_hhong(b_lp);
end loop;
if b_kieu='B' then
    insert into tbh_ghep_phi select b_so_id,ngay_hl,ma_ta,so_id_ta,so_hd_ta,pthuc,
        nha_bh,kieu,pt,ptt,-tien,-phi,pt_hh,-hhong,tl_thue,-thue,nha_bhC,bt+100000
        from tbh_ghep_phi where so_id=b_so_idG and bt<100000 order by bt;
end if;
delete tbh_ghep_pbo_temp;
PTBH_GHEP_PBO(b_so_id,b_ngay_ht,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id_hd,a_so_id_dt,
    tl_so_id_ta,tl_pthuc,tl_ngay_hl,tl_ma_ta,tl_pt,tl_tien,tl_phi,
    tl_tl_thue,tl_thue,tl_pt_hh,tl_hhong,tl_nha_bh,tl_kieu,tl_nha_bhC,b_loi);
if b_loi is not null then return; end if;
for r_lp in (select * from tbh_ghep_pbo_temp) loop
    for b_lp in 1..tl_ngay_hl.count loop
        if tl_ngay_hl(b_lp)=r_lp.ngay_hl and tl_ma_ta(b_lp)=r_lp.ma_ta and
            tl_so_id_ta(b_lp)=r_lp.so_id_ta_ps and tl_nha_bh(b_lp)=r_lp.nha_bh then
            b_pt_hh:=tl_pt_hh(b_lp); exit;
        end if;
    end loop;
    insert into tbh_ghep_pbo values(
        b_so_id,r_lp.ngay_hl,r_lp.so_id_ta_ps,r_lp.so_id_ta_hd,r_lp.ma_dvi_hd,r_lp.so_id_hd,
        r_lp.so_id_dt,r_lp.nha_bh,r_lp.kieu,r_lp.nha_bhC,r_lp.ma_ta,r_lp.lh_nv,r_lp.pthuc,
        r_lp.pt,b_pt_hh,r_lp.nt_tien,r_lp.tien,r_lp.nt_phi,r_lp.phi,r_lp.hhong,r_lp.thue);
end loop;
delete tbh_ghep_pbo_temp;
if b_kieu='B' then
    insert into tbh_ghep_pbo
        select b_so_id,ngay_hl,so_id_ta_ps,so_id_ta_hd,ma_dvi_hd,so_id_hd,so_id_dt,nha_bh,kieu,nha_bhC,ma_ta,lh_nv,
        pthuc,pt,pt_hh,nt_tien,-tien,nt_phi,-phi,-hhong,-thue
        from tbh_ghep_pbo where so_id=b_so_idG and tien>0;
end if;
update tbh_cbi set kieu_xl='D' where so_id=b_so_id;
PTBH_GHEP_NV(0,b_ngay_ht,b_ngay_hl,b_nt_tien,b_nt_phi,a_ma_dvi,a_so_id_hd,a_so_id_dt,b_loi,'{"nv":"'||b_nv||'"}');
if b_loi is not null then return; end if;
select nvl(min(pt_con),0) into b_i1 from tbh_ghep_nv_temp0;
if b_i1<0 then b_loi:='loi:Tai qua 100%:loi'; return; end if;
delete tbh_ghep_nv_temp;
insert into tbh_ghep_txt values(b_so_id,'dt_ct',dt_ct);
insert into tbh_ghep_txt values(b_so_id,'dt_hd',dt_hd);
insert into tbh_ghep_txt values(b_so_id,'dt_phi',dt_phi);
insert into tbh_ghep_txt values(b_so_id,'dt_tl',dt_tl);
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_NH_NH:loi'; end if;
end;
/
create or replace procedure PTBH_GHEP_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_so_id number; b_nv varchar2(10); b_ngay_ht number; b_so_ct varchar2(20); b_kieu varchar2(1); b_so_ctG varchar2(20); 
    b_ngay_hl number; b_ngay_kt number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); 
    b_nguon varchar2(1); b_pphap varchar2(1); b_so_idD number; b_so_idG number; 
    a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var; a_so_id_hd pht_type.a_num;
    a_so_id_dt pht_type.a_num; a_ten pht_type.a_nvar; 
    a_ngay_hl pht_type.a_num; a_ma_ta pht_type.a_var; a_so_id_ta pht_type.a_num; 
    a_so_hd_ta pht_type.a_var; a_pthuc pht_type.a_var; 
    a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num; 
    tl_ngay_hl pht_type.a_num; tl_ma_ta pht_type.a_var; tl_so_id_ta pht_type.a_num; 
    tl_so_hd_ta pht_type.a_var; tl_pthuc pht_type.a_var; 
    tl_nha_bh pht_type.a_var; tl_kieu pht_type.a_var; tl_pt pht_type.a_num; 
    tl_ptt pht_type.a_num; tl_tien pht_type.a_num; tl_phi pht_type.a_num; 
    tl_pt_hh pht_type.a_num; tl_hhong pht_type.a_num; tl_tl_thue pht_type.a_num; 
    tl_thue pht_type.a_num; tl_nha_bhC pht_type.a_var;
    a_ma_dvi_xl pht_type.a_var; a_so_id_xl pht_type.a_num;

    dt_ct clob; dt_hd clob; dt_phi clob; dt_tl clob;
    b_i1 number; b_i2 number; b_kt number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=nvl(FKH_JS_GTRIn(b_oraIn,'so_id'),0);
PKH_MANG_KD(a_ma_dvi_xl);
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    select distinct ma_dvi_hd,so_id_hd BULK COLLECT into a_ma_dvi_xl,a_so_id_xl from tbh_ghep_hd where so_id=b_so_id;
    PTBH_GHEP_NH_XOA_XOA(b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd using b_oraIn;
FKH_JS_NULL(dt_ct); FKH_JSa_NULL(dt_hd);
PTBH_GHEP_NH_TEST(
    b_ma_dvi,b_so_id,dt_ct,dt_hd,dt_phi,dt_tl,
    b_nv,b_ngay_ht,b_so_ct,b_kieu,b_so_ctG,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pphap,b_so_idD,b_so_idG,
    a_ma_dvi,a_so_hd,a_so_id_hd,a_so_id_dt,a_ten,
    a_ngay_hl,a_ma_ta,a_so_id_ta,a_so_hd_ta,a_pthuc,a_pt,a_tien,a_phi,
    tl_ngay_hl,tl_ma_ta,tl_so_id_ta,tl_so_hd_ta,tl_pthuc,tl_nha_bh,tl_nha_bhC,tl_kieu,tl_pt,
    tl_ptt,tl_tien,tl_phi,tl_pt_hh,tl_hhong,tl_tl_thue,tl_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTBH_GHEP_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,b_nv,b_ngay_ht,b_so_ct,b_kieu,b_so_ctG,
    b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pphap,b_so_idD,b_so_idG,
    a_ma_dvi,a_so_hd,a_so_id_hd,a_so_id_dt,a_ten,
    a_ngay_hl,a_ma_ta,a_so_id_ta,a_so_hd_ta,a_pthuc,a_pt,a_tien,a_phi,
    tl_ngay_hl,tl_ma_ta,tl_so_id_ta,tl_so_hd_ta,tl_pthuc,tl_nha_bh,tl_kieu,tl_pt,
    tl_ptt,tl_tien,tl_phi,tl_pt_hh,tl_hhong,tl_tl_thue,tl_thue,tl_nha_bhC,
    dt_ct,dt_hd,dt_phi,dt_tl,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_kt:=a_ma_dvi_xl.count;
for b_lp in reverse 1..b_kt loop
    for b_lp1 in 1..a_ma_dvi.count loop
        if a_ma_dvi_xl(b_lp)=a_ma_dvi(b_lp1) and a_so_id_xl(b_lp)=a_so_id_hd(b_lp1) then
            a_ma_dvi_xl.delete(b_lp); a_so_id_xl.delete(b_lp); exit;
        end if;
    end loop;
end loop;
PTBH_TH_TA_NH(b_ma_dvi,'C',b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if a_ma_dvi_xl.count<>0 then
    PTBH_CBI(a_ma_dvi_xl,a_so_id_xl,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
if b_comm='C' then commit; end if;
select json_object('so_id' value b_so_id,'so_ct' value b_so_ct) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_XOA(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_so_id number; b_so_idG number;
    a_ma_dvi pht_type.a_var; a_so_id pht_type.a_num;
begin
-- Dan - Xoa GCN
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
select distinct ma_dvi_hd,so_id_hd BULK COLLECT into a_ma_dvi,a_so_id from tbh_ghep_hd where so_id=b_so_id;
if a_ma_dvi.count=0 then b_loi:='loi:Chua ghep:loi'; raise PROGRAM_ERROR; end if;
select so_id_g into b_so_idG from tbh_ghep where so_id=b_so_id;
PTBH_GHEP_NH_XOA_XOA(b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_idG<>0 then
    PTBH_TH_TA_NH(b_ma_dvi,'C',b_so_idG,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PTBH_CBI(a_ma_dvi,a_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_KH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(100); b_kieu_xl varchar2(1); b_so_id number;
begin
-- Dan - Nhap khong tai
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_loi:='loi:Nhap so lieu sai:loi';
select kieu_xl into b_kieu_xl from tbh_cbi where so_id=b_so_id;
if b_kieu_xl='D' then raise PROGRAM_ERROR; end if;
if b_kieu_xl='K' then b_kieu_xl:='C'; else b_kieu_xl:='K'; end if;
update tbh_cbi set kieu_xl=b_kieu_xl where so_id=b_so_id;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_NH_BSSD(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(200); b_lenh varchar2(1000);
    b_nv varchar2(10); b_so_id number; b_so_idD number; b_bang varchar2(100);  
    cs_lke clob:='';
begin
-- Dan - Thong tin sua doi tai
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('so_id,nv');
EXECUTE IMMEDIATE b_lenh into b_so_id,b_nv using b_oraIn;
if b_nv='F' then b_bang:='tbh_tm';
elsif b_nv='H' then b_bang:='tbh_ho';
else b_bang:='tbh_ghep';
end if;
b_lenh:='select nvl(min(so_id_d),0) from '||b_bang||' where so_id= :so_id';
EXECUTE IMMEDIATE b_lenh into b_so_idD using b_so_id;
if b_so_idD=0 then b_loi:='loi:Da xoa xu ly tai:loi'; raise PROGRAM_ERROR; end if;
b_lenh:='insert into temp_1(n1,n2,c1) select ngay_ht,so_id,so_ct from '||b_bang||' where so_id_d= :so_id';
EXECUTE IMMEDIATE b_lenh using b_so_idD;
select JSON_ARRAYAGG(json_object('ngay_ht' value n1,'so_id' value n2,'so_ct' value c1) order by n1 desc,n2 desc returning clob)
    into cs_lke from temp_1;
select json_object('cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_GHEP_TD
AS
    b_loi varchar2(1000); b_i1 number; b_d date; b_tso number:=5; -- 5p
    a_so_id pht_type.a_num;
begin
b_d:=sysdate+b_tso/24/60;
select so_id bulk collect into a_so_id from
    (select so_id from tbh_cbi where kieu_xl='C' and phai_xl='K' and ngay_nh<b_d order by so_id) where rownum<200;
for b_lp in 1..a_so_id.count loop
    select count(*) into b_i1 from kh_job_loi where so_id=a_so_id(b_lp);
    if b_i1=0 then
        PTBH_GHEP_TD_NH(a_so_id(b_lp),b_loi);
        if b_loi is null then commit;
        else
            rollback;
            insert into kh_job_loi values(a_so_id(b_lp),'PTBH_GHEP_TD',sysdate,b_loi);
            commit; exit;
        end if;
    end if;
end loop;
end;
/
create or replace procedure PTBH_GHEP_TD_NH(b_so_id number,b_loi out varchar2)
AS
    b_i1 number;
    b_ma_dvi varchar2(10):=FTBH_DVI_TA(); b_nv varchar2(10); b_ngay_ht number;
    b_so_ct varchar2(20); b_kieu varchar2(1); b_so_ctG varchar2(20); 
    b_ngay_hl number; b_ngay_kt number; b_nt_tien varchar2(5); b_nt_phi varchar2(5); 
    b_nguon varchar2(1); b_pphap varchar2(1); b_so_idD number; b_so_idG number; 
    a_ma_dvi pht_type.a_var; a_so_hd pht_type.a_var; a_so_id_hd pht_type.a_num; a_so_id_dt pht_type.a_num; 
    a_ngay_hl pht_type.a_num; a_ma_ta pht_type.a_var; a_so_id_ta pht_type.a_num; 
    a_so_hd_ta pht_type.a_var; a_pthuc pht_type.a_var; a_ten pht_type.a_nvar;
    a_pt pht_type.a_num; a_tien pht_type.a_num; a_phi pht_type.a_num; 
    tl_ngay_hl pht_type.a_num; tl_ma_ta pht_type.a_var; tl_so_id_ta pht_type.a_num; 
    tl_so_hd_ta pht_type.a_var; tl_pthuc pht_type.a_var; 
    tl_nha_bh pht_type.a_var; tl_kieu pht_type.a_var; tl_pt pht_type.a_num; 
    tl_ptt pht_type.a_num; tl_tien pht_type.a_num; tl_phi pht_type.a_num; 
    tl_pt_hh pht_type.a_num; tl_hhong pht_type.a_num; tl_tl_thue pht_type.a_num; 
    tl_thue pht_type.a_num; tl_nha_bhC pht_type.a_var;
    dt_ct clob; dt_hd clob; dt_phi clob; dt_tl clob;

begin
-- Dan - Tu dong ghep tai co dinh
select count(*) into b_i1 from tbh_cbi where so_id=b_so_id and kieu_xl='C' and phai_xl='K';
if b_i1<>1 then b_loi:=''; return; end if;
FTBH_GHEP_NH_CT(b_so_id,dt_ct,dt_hd,b_loi,'G');
if b_loi is not null then return; end if;
PTBH_GHEP_NH_TEST(
    b_ma_dvi,b_so_id,dt_ct,dt_hd,dt_phi,dt_tl,
    b_nv,b_ngay_ht,b_so_ct,b_kieu,b_so_ctG,b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pphap,b_so_idD,b_so_idG,
    a_ma_dvi,a_so_hd,a_so_id_hd,a_so_id_dt,a_ten,
    a_ngay_hl,a_ma_ta,a_so_id_ta,a_so_hd_ta,a_pthuc,a_pt,a_tien,a_phi,
    tl_ngay_hl,tl_ma_ta,tl_so_id_ta,tl_so_hd_ta,tl_pthuc,tl_nha_bh,tl_nha_bhC,tl_kieu,tl_pt,
    tl_ptt,tl_tien,tl_phi,tl_pt_hh,tl_hhong,tl_tl_thue,tl_thue,b_loi);
if b_loi is not null then return; end if;
PTBH_GHEP_NH_NH(
    b_ma_dvi,' ',b_so_id,b_nv,b_ngay_ht,b_so_ct,b_kieu,b_so_ctG,
    b_ngay_hl,b_ngay_kt,b_nt_tien,b_nt_phi,b_nguon,b_pphap,b_so_idD,b_so_idG,
    a_ma_dvi,a_so_hd,a_so_id_hd,a_so_id_dt,a_ten,
    a_ngay_hl,a_ma_ta,a_so_id_ta,a_so_hd_ta,a_pthuc,a_pt,a_tien,a_phi,
    tl_ngay_hl,tl_ma_ta,tl_so_id_ta,tl_so_hd_ta,tl_pthuc,tl_nha_bh,tl_kieu,tl_pt,
    tl_ptt,tl_tien,tl_phi,tl_pt_hh,tl_hhong,tl_tl_thue,tl_thue,tl_nha_bhC,
    dt_ct,dt_hd,dt_phi,dt_tl,b_loi);
if b_loi is not null then return; end if;
PTBH_TH_TA_NH(b_ma_dvi,'C',b_so_id,b_loi);
if b_loi is not null then return; end if;
exception when others then if b_loi is null then b_loi:='Loi khong xac dinh'; end if;
end;
/
create or replace procedure PTBH_GHEP_TD_XOA(
    b_ma_dvi_hd varchar2,b_so_id_hd number,a_ma_dvi_hd out pht_type.a_var,a_so_id_hd out pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
    a_so_id pht_type.a_num; a_ma_dvi_hdX pht_type.a_var; a_so_id_hdX pht_type.a_num;
begin
-- Dan - Xoa ghep tu dong tai co dinh
select distinct so_id BULK COLLECT into a_so_id from tbh_ghep_hd where ma_dvi_hd=b_ma_dvi_hd and so_id_hd=b_so_id_hd;
if a_so_id.count=0 then b_loi:=''; return; end if;
for b_lp in 1..a_so_id.count loop
    select count(*) into b_i1 from tbh_ps where so_id=a_so_id(b_lp);
    if b_i1<>0 then b_loi:='loi:Da phat sinh tai:loi'; return; end if;
end loop;
PKH_MANG_KD(a_ma_dvi_hd); PKH_MANG_KD_N(a_so_id_hd);
for b_lp in 1..a_so_id.count loop
    select distinct ma_dvi_hd,so_id_hd BULK COLLECT into a_ma_dvi_hdX,a_so_id_hdX
        from tbh_ghep_hd where so_id=a_so_id(b_lp) and ma_dvi_hd<>b_ma_dvi_hd or so_id_hd<>b_so_id_hd;
    PTBH_GHEP_NH_XOA_XOA(' ',a_so_id(b_lp),b_loi);
    if b_loi is not null then return; end if;
    for b_lp1 in 1..a_ma_dvi_hdX.count loop
        b_i1:=0;
        for b_lp2 in 1..a_ma_dvi_hd.count loop
            if a_ma_dvi_hd(b_lp2)=a_ma_dvi_hdX(b_lp1) and a_so_id_hd(b_lp2)=a_so_id_hdX(b_lp1) then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then
            b_i1:=a_ma_dvi_hd.count+1;
            a_ma_dvi_hd(b_i1):=a_ma_dvi_hdX(b_lp1); a_so_id_hd(b_i1):=a_so_id_hdX(b_lp1);
        end if;
    end loop;
end loop;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PTBH_GHEP_TD_XOA:loi'; end if;
end;
/
