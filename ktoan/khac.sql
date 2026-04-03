create or replace procedure PKH_HOI_KT_LIST_SL(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
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
create or replace procedure PKH_HOI_KT_LISTt(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_maN nvarchar2,b_trangKt number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; b_i1 number;
    b_ma varchar2(50); b_ten nvarchar2(100); b_min nvarchar2(100); b_ma_dvi varchar2(20);
    a_ch pht_type.a_var;
begin
-- Dan - Liet ke dong
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if b_maN is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
b_ma:=b_maN||'%'; b_ten:='%'||b_maN||'%';
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where ma_dvi= :ma_dvi and ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten)';
    execute immediate b_lenh into b_i1,b_min using b_ma_dvi,b_ma,b_ten;
else
    b_lenh:='select count(*),min('||a_ch(2)||') from '||a_ch(1)||' where idvung= :idvung and ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten)';
    execute immediate b_lenh into b_i1,b_min using b_idvung,b_ma,b_ten;
end if;
if b_i1>b_trangKt or (b_i1=1 and upper(b_min)=b_maN) then
    open cs1 for select '' ma,'' ten from dual;
else
    if a_ch(1)<>'ht_ma_dvi' then
        b_lenh:='select '||a_ch(2)||' ma,'||a_ch(3)||' ten from '||a_ch(1)||' where ma_dvi= :ma_dvi and ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten) order by '||a_ch(2);
        open cs1 for b_lenh using b_ma_dvi,b_ma,b_ten;
    else
        b_lenh:='select '||a_ch(2)||' ma,'||a_ch(3)||' ten from '||a_ch(1)||' where idvung= :idvung and ('||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten) order by '||a_ch(2);
        open cs1 for b_lenh using b_idvung,b_ma,b_ten;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;