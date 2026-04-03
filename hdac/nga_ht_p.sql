create or replace procedure PKH_HOI_TEN_AC(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_bang varchar2,b_truong varchar2,b_gtri varchar2,b_kq varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(200); b_i1 number; a_gtri pht_type.a_var; b_s nvarchar2(500); b_c varchar2(1):=',';
begin
-- Dan - Tim ten
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_bang='ht_ma_nsd' and b_truong='pas' then
    b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR;
end if;
if instr(b_gtri,';')>0 then b_c:=';'; end if;
PKH_CH_ARR(b_gtri,a_gtri,b_c);
if trim(b_kq) is null then
    for b_lp in 1..a_gtri.count loop
        b_i1:=FKH_HOI_CO(b_ma_dvi,b_bang,b_truong,a_gtri(b_lp));
        if b_lp=1 then b_ten:=to_char(b_i1); else b_ten:=b_ten||';'||to_char(b_i1); end if;
        if b_i1=0 then exit; end if;
    end loop;
else
    for b_lp in 1..a_gtri.count loop
        b_s:=FKH_HOI_TEN(b_ma_dvi,b_bang,b_truong,a_gtri(b_lp),b_kq);
        if b_lp=1 then b_ten:=b_s; else b_ten:=b_ten||';'||b_s; end if;
        if b_s='' then exit; end if;
    end loop;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_AC(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_ma_n varchar2,b_trangKt number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; b_i1 number;
    b_ma varchar2(100); b_min varchar2(100); a_ch pht_type.a_var; b_ma_dvi varchar2(20):=b_ma_dviN;
begin
-- Dan - Liet ke dong
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);

if a_ch.count>3 then
    if a_ch(4)='C' then b_ma_dvi:=FTBH_DVI_TA(); end if;
end if;
if upper(a_ch(1))='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
b_ma:=b_ma_n||'%';
if upper(a_ch(1))<>'HT_MA_DVI' then
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where ma_dvi= :ma_dvi and '||a_ch(2)||' like :ma';
    execute immediate b_lenh into b_i1,b_min using b_ma_dvi,b_ma;
else
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where idvung= :idvung and '||a_ch(2)||' like :ma';
    execute immediate b_lenh into b_i1,b_min using b_idvung,b_ma;
end if;
if b_i1>b_trangKt or (b_i1=1 and upper(b_min)=b_ma_n) then
    open cs1 for select c1 ma,c2 ten from temp_1 where rownum=0;
else
    if upper(a_ch(1))<>'HT_MA_DVI' then
        b_lenh:='select '||a_ch(2)||' ma,'||a_ch(3)||' ten from '||a_ch(1)||' where ma_dvi= :ma_dvi and upper('||a_ch(2)||') like :ma order by '||a_ch(2);
        open cs1 for b_lenh using b_ma_dvi,b_ma;
    else
        b_lenh:='select '||a_ch(2)||' ma,'||a_ch(3)||' ten from '||a_ch(1)||' where idvung= :idvung and upper('||a_ch(2)||') like :ma order by '||a_ch(2);
        open cs1 for b_lenh using b_idvung,b_ma;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_MA_AC(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_maN varchar2,b_trangkt number,b_trang out number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_tu number; b_den number; b_ma_dvi varchar2(20); b_ma varchar2(50);
begin
-- Dan - Liet ke dong tu, den
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);

a_ch(1):=lower(a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if b_maN is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
b_ma:=b_maN||'%';
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where '||a_ch(2)||'>= :ma';
    execute immediate b_lenh into b_tu using b_ma_dvi,b_ma;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_ma_dvi,b_tu,b_den;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where '||a_ch(2)||'>= :ma';
    execute immediate b_lenh into b_tu using b_idvung,b_ma;
    if b_tu=0 then b_tu:=b_dong; end if;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_idvung,b_tu,b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_SL_AC(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_tu_n number,b_den_n number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_tu number:=b_tu_n; b_den number:=b_den_n; b_ma_dvi varchar2(20):=b_ma_dviN;
begin
-- Dan - Liet ke dong tu, den
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));

if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||') sott from '||a_ch(1)||
        ' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_ma_dvi,b_tu,b_den;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||') sott from '||a_ch(1)||
        ' where idvung= :idvung order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_idvung,b_tu,b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_LIST_AC_DAU(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_xep number,b_ktra varchar2,b_ma varchar2,b_tim varchar2,b_tra out nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_lenh varchar2(1000); b_idvung number; b_ma_dvi varchar2(20);
    b_dong number; b_tu number; b_ten nvarchar2(1000); a_ch pht_type.a_var;
begin
-- Dan - Tra ma,ten tuong ung ma cu va ky tu dau can tim tiep
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch); b_tra:='';
a_ch(1):=lower(a_ch(1));
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    if trim(b_ma) is null then
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
        execute immediate b_lenh into b_tu using b_ma_dvi,b_tim;        
    else 
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where '||a_ch(2)||'= :ma';
        execute immediate b_lenh into b_i1 using b_ma_dvi,b_ma;
        if b_i1=0 then
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_ma_dvi,b_tim;        
        else
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(3)||') where sott> :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_ma_dvi,b_i1,b_tim;
            if b_tu=0 then
                b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                    ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where sott< :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
                execute immediate b_lenh into b_tu using b_ma_dvi,b_i1,b_tim;
            end if;
        end if;
    end if;
    if b_tu<>0 then
        b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(b_xep)||') where sott= :tu';
        execute immediate b_lenh into b_tra,b_ten using b_ma_dvi,b_tu;
    end if;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    if trim(b_ma) is null then
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
        execute immediate b_lenh into b_tu using b_idvung,b_tim;        
    else 
        b_lenh:='select nvl(min(sott),0) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where '||a_ch(2)||'= :ma';
        execute immediate b_lenh into b_i1 using b_idvung,b_ma;
        if b_i1=0 then
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_idvung,b_tim;        
        else
            b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(3)||') where sott> :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
            execute immediate b_lenh into b_tu using b_idvung,b_i1,b_tim;
            if b_tu=0 then
                b_lenh:='select nvl(min(sott),0) from (select '||a_ch(b_xep)||',row_number() over (order by '||a_ch(b_xep)||
                    ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where sott< :tu and substr('||a_ch(b_xep)||',1,1)= :tim';
                execute immediate b_lenh into b_tu using b_idvung,b_i1,b_tim;
            end if;
        end if;
    end if;
    if b_tu<>0 then
        b_lenh:='select '||a_ch(2)||','||a_ch(3)||' from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(b_xep)||
            ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(b_xep)||') where sott= :tu';
        execute immediate b_lenh into b_tra,b_ten using b_idvung,b_tu;
    end if;
end if;
if b_tra is not null then b_tra:=b_tra||'{'||b_ten; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/ 
-- chuclh: bo khong dung 
--CREATE OR REPLACE procedure PHD_CT_NH
--create or replace procedure PHD_CT_SUA
--procedure PHT_MA_CB_NH
create or replace procedure PBH_NG_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ma_dl varchar2(20):=' '; b_ks varchar2(1);
    b_loai_ac varchar(20);b_mau varchar2(200);dt_ds clob:='';b_lenh varchar2(1000);
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn pht_type.a_var; r_hd bh_xe%rowtype;
begin 
-- Dan - Kiem soat an chi
b_loi:='loi:GCN/Hop dong da xoa:loi';
select count(*) into b_i1 from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_hd from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_ks:=FBH_HT_THUE_TS(b_ma_dvi,r_hd.ngay_ht,'gcn_ng');
if b_ks is null then b_loi:='loi:Chua khai bao kieu theo doi an chi:loi'; return; end if;
if r_hd.kieu_kt<>'T' then b_ma_dl:=r_hd.ma_kt; end if;
 
select count(*) into b_i1 from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
if b_i1<>0 then
    select txt into dt_ds from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
end if;
b_lenh:=FKH_JS_LENH('mau_ac,loai_ac');
EXECUTE IMMEDIATE b_lenh into b_mau,b_loai_ac using dt_ds;

select b_loai_ac||'>'||b_mau,'',gcn bulk collect into a_gcn_m,a_gcn_c,a_gcn from bh_ng_ds where ma_dvi=b_ma_dvi and so_id=b_so_id;
PHD_PH_DON(b_ma_dvi,b_nv,r_hd.ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn,r_hd.ma_cb,b_ma_dl,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/