/*** Xac nhan doi chieu ***/
create or replace PROCEDURE PTBH_DCN_TONng(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraOut out clob)
AS
    b_loi varchar2(100); b_ngxlD number; b_ngxlC number;
begin
-- Dan - Liet ke ton ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(min(ngay_ht),0),nvl(max(ngay_ht),0) into b_ngxlD,b_ngxlC from tbh_dc where ng_dc=0;
select json_object('ngxld' value b_ngxlD,'ngxlc' value b_ngxlD) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DCN_TONnbh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_klk varchar2(1);
    cs_nbh clob;
begin
-- Dan - Liet ke ton ngay => kieu => nv
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,klk');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_klk using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_klk='C' then
    select JSON_ARRAYAGG(json_object('ma' value nha_bh,'ten' value FBH_MA_NBH_TEN(nha_bh))) into cs_nbh from
        (select distinct nha_bh from tbh_dc where ng_dc=0 and ngay_ht between b_ngxlD and b_ngxlC);
elsif b_klk='D' then
    select JSON_ARRAYAGG(json_object('ma' value nha_bh,'ten' value FBH_MA_NBH_TEN(nha_bh))) into cs_nbh from
        (select distinct nha_bh from tbh_dc where ngay_ht between b_ngxlD and b_ngxlC and ng_dc<>0);
else
    select JSON_ARRAYAGG(json_object('ma' value nha_bh,'ten' value FBH_MA_NBH_TEN(nha_bh))) into cs_nbh from
        (select distinct nha_bh from tbh_dc where ngay_ht between b_ngxlD and b_ngxlC);
end if;
select json_object('cs_nbh' value cs_nbh) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DCN_TONki(
	b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
	b_ngxlD number; b_ngxlC number; b_klk varchar2(1); b_nha_bh varchar2(20);
    cs_ki clob:='';
begin
-- Dan - Liet ke ton ngay => kieu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,klk,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_klk,b_nha_bh using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if trim(b_nha_bh) is null then
    b_loi:='loi:Nhap nha tai:loi'; raise PROGRAM_ERROR;
end if;
if b_klk='C' then
	select JSON_ARRAYAGG(json_object('ma' value ma)) into cs_ki from
		(select distinct FTBH_XL_KI(kieu) ma from tbh_dc
		where ng_dc=0 and ngay_ht between b_ngxlD and b_ngxlC and nha_bh=b_nha_bh);
elsif b_klk='D' then
	select JSON_ARRAYAGG(json_object('ma' value ma)) into cs_ki from
		(select distinct FTBH_XL_KI(kieu) ma from tbh_dc
		where ngay_ht between b_ngxlD and b_ngxlC and ng_dc<>0 and nha_bh=b_nha_bh);
else
	select JSON_ARRAYAGG(json_object('ma' value ma)) into cs_ki from
		(select distinct FTBH_XL_KI(kieu) ma from tbh_dc
		where ngay_ht between b_ngxlD and b_ngxlC and nha_bh=b_nha_bh);
end if;
select json_object('cs_ki' value cs_ki) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DCN_TONnt(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_klk varchar2(1); b_kieu varchar2(1); b_nha_bh varchar2(20);
    cs_nt clob;
begin
-- Dan - Liet ke ton ngay => kieu => nt
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,klk,kieu,nha_bh');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_klk,b_kieu,b_nha_bh using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
if trim(b_nha_bh) is null then
    b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
end if;
if b_klk='C' then
    select JSON_ARRAYAGG(json_object(ma)) into cs_nt from
        (select distinct nt_tra ma from tbh_dc where ng_dc=0 and ngay_ht between b_ngxlD and b_ngxlC and nha_bh=b_nha_bh and kieu=b_kieu);
elsif b_klk='D' then
    select JSON_ARRAYAGG(json_object(ma)) into cs_nt from
        (select distinct nt_tra ma from tbh_dc where ngay_ht between b_ngxlD and b_ngxlC and ng_dc<>0 and nha_bh=b_nha_bh and kieu=b_kieu);
else
    select JSON_ARRAYAGG(json_object(ma)) into cs_nt from
        (select distinct nt_tra ma from tbh_dc where ngay_ht between b_ngxlD and b_ngxlC and nha_bh=b_nha_bh and kieu=b_kieu);
end if;
select json_object('cs_nt' value cs_nt) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace PROCEDURE PTBH_DCN_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_loi varchar2(100); b_lenh varchar2(2000);
    b_ngxlD number; b_ngxlC number; b_klk varchar2(1); b_so_dc varchar2(20);
	b_kieu varchar2(1); b_nha_bh varchar2(20); b_nt_tra varchar2(5);
    cs_ton clob:='';
begin
-- Dan - Liet ke ton
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngxld,ngxlc,klk,kieu,nha_bh,nt_tra,so_dc');
EXECUTE IMMEDIATE b_lenh into b_ngxlD,b_ngxlC,b_klk,b_kieu,b_nha_bh,b_nt_tra,b_so_dc using b_oraIn;
if b_ngxlD is null or b_ngxlD in(0,30000101) then
    b_loi:='loi:Nhap ngay bat dau xu ly:loi'; raise PROGRAM_ERROR;
end if;
if b_ngxlC is null or b_ngxlC=0 then b_ngxlC:=30000101; end if;
if b_kieu is null or b_kieu not in('C','T','N','X') then
    b_loi:='loi:Chon kieu tai:loi'; raise PROGRAM_ERROR;
end if;
if b_nha_bh is null then
    b_loi:='loi:Chon nha tai:loi'; raise PROGRAM_ERROR;
end if;
if b_nt_tra is null then
    b_loi:='loi:Chon loai tien:loi'; raise PROGRAM_ERROR;
end if;
if b_klk='C' then
    select JSON_ARRAYAGG(json_object(
		'ngay_ht' value ngay_ht,'so_bk' value so_bk,'tra' value tra,'so_dc' value so_dc,
		'ng_dc' value ng_dc,'so_id_dc' value so_id_dc,'chon' value '')
		order by ngay_ht,so_bk returning clob) into cs_ton
        from tbh_dc where ng_dc=0 and ngay_ht between b_ngxlD and b_ngxlC and nha_bh=b_nha_bh and kieu=b_kieu and nt_tra=b_nt_tra;
elsif b_klk='D' then
	b_so_dc:=trim(b_so_dc);
	if b_so_dc is null then
		select JSON_ARRAYAGG(json_object(
			'ngay_ht' value ngay_ht,'so_bk' value so_bk,'tra' value tra,'so_dc' value so_dc,
			'ng_dc' value ng_dc,'so_id_dc' value so_id_dc,'chon' value '')
			order by ngay_ht,so_bk returning clob) into cs_ton
			from tbh_dc where ng_dc<>0 and ngay_ht between b_ngxlD and b_ngxlC and
			ng_dc<>0 and nha_bh=b_nha_bh and kieu=b_kieu and nt_tra=b_nt_tra;
	else
		b_so_dc:='%'||b_so_dc||'%';
		select JSON_ARRAYAGG(json_object(
			'ngay_ht' value ngay_ht,'so_bk' value so_bk,'tra' value tra,'so_dc' value so_dc,
			'ng_dc' value ng_dc,'so_id_dc' value so_id_dc,'chon' value '')
			order by ngay_ht,so_bk returning clob) into cs_ton
			from tbh_dc where ng_dc<>0 and so_dc like b_so_dc;
	end if;
else
    select JSON_ARRAYAGG(json_object(
		'ngay_ht' value ngay_ht,'so_bk' value so_bk,'tra' value tra,'so_dc' value so_dc,
		'ng_dc' value ng_dc,'so_id_dc' value so_id_dc,'chon' value '')
		order by ngay_ht,so_bk returning clob) into cs_ton
        from tbh_dc where ngay_ht between b_ngxlD and b_ngxlC and
        nha_bh=b_nha_bh and kieu=b_kieu and nt_tra=b_nt_tra;
end if;
select json_object('cs_ton' value cs_ton returning clob) into b_oraOut from dual;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTBH_DCN_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_comm varchar2:='C')
AS
    b_loi varchar2(2000); b_lenh varchar2(2000); dt_dk clob;
    b_nh varchar2(1); b_ng_dc number; b_so_dc varchar2(20); b_i1 number;
    a_so_id pht_type.a_num;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_lenh:=FKH_JS_LENH('nh,ng_dc,so_dc');
EXECUTE IMMEDIATE b_lenh into b_nh,b_ng_dc,b_so_dc using b_oraIn;
dt_dk:=FKH_JS_GTRIc(b_oraIn,'dt_dk');
b_lenh:=FKH_JS_LENH('so_id_dc');
EXECUTE IMMEDIATE b_lenh bulk collect into a_so_id using dt_dk;
if b_nh is null or b_nh not in('N','X') then
    b_loi:='loi:Sai loai xu ly:loi'; raise PROGRAM_ERROR;
end if;
if a_so_id.count=0 then
    b_loi:='loi:Chon bang ke:loi'; raise PROGRAM_ERROR;
end if;
for b_lp in 1..a_so_id.count loop
    if a_so_id(b_lp) is null or a_so_id(b_lp)=0 then
        b_loi:='loi:Chon sai bang ke dong '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
end loop;
for b_lp in 1..a_so_id.count loop
    select so_id_tt into b_i1 from tbh_dc where so_id_dc=a_so_id(b_lp) for update nowait;
    if sql%rowcount=0 then b_loi:='loi:So doi chieu dang xu ly dong '||to_char(b_lp)||':loi'; return; end if;
    if b_i1>0 then b_loi:='loi:So doi chieu da thanh toan dong '||to_char(b_lp)||':loi'; return; end if;
end loop;
if b_nh='X' then
    forall b_lp in 1..a_so_id.count
        update tbh_dc set ng_dc=0,so_dc=' ',so_id_tt=-1 where so_id_dc=a_so_id(b_lp);
else
    if b_ng_dc is null or b_ng_dc in(0,30000101) then
        b_loi:='loi:Sai ngay doi chieu:loi'; raise PROGRAM_ERROR;
    end if;
    b_so_dc:=trim(b_so_dc);
    if b_so_dc is null then
        b_loi:='loi:Nhap so doi chieu:loi'; raise PROGRAM_ERROR;
    end if;
    forall b_lp in 1..a_so_id.count
        update tbh_dc set ng_dc=b_ng_dc,so_dc=b_so_dc,so_id_tt=0 where so_id_dc=a_so_id(b_lp);
end if;
for b_lp in 1..a_so_id.count loop
    PTBH_DC_DP(b_ma_dvi,a_so_id(b_lp),b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end loop;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
