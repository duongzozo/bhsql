create or replace procedure PBH_2B_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_nv varchar2(10); b_so_hdL varchar2(1); b_kieu_hd varchar2(1); b_txt clob; b_txt_ds clob;
    ds_so_id pht_type.a_num; ds_gcn pht_type.a_var; ds_gcnG pht_type.a_var; ds_kieu_gcn pht_type.a_var; ds_nv_bh pht_type.a_var;
    dt_ds clob; a_dt_ds pht_type.a_clob; a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob; a_ds_lt pht_type.a_clob; a_ds_ttt pht_type.a_clob;
    a_nv pht_type.a_var; a_ds_kbt pht_type.a_clob; a_ds_dkbs pht_type.a_clob; a_dsM pht_type.a_clob;
begin
-- dan - Update sau duyet
select so_hd,so_hdL,kieu_hd,nv into b_so_hd,b_so_hdL,b_kieu_hd,b_nv from bh_2b where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
select txt into b_txt from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_2b_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';

-- update txt
-- viet anh -- check count
select count(*) into b_i1 from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
if b_i1<>0 then
   select FKH_JS_BONH(txt) into b_txt_ds from bh_2b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_ds using b_txt_ds;
for b_lp in 1..a_dt_ds.count loop
  b_txt_ds:=FKH_JS_BONH(a_dt_ds(b_lp));
  b_lenh:=FKH_JS_LENHc('ds_ct,ds_dk,ds_lt,ds_kbt,ds_ttt,ds_dkbs');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct,a_ds_dk,a_ds_lt,a_ds_kbt,a_ds_ttt,a_ds_dkbs using b_txt_ds;
  if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach xe:loi'; return; end if;
  for ds_lp in 1..a_ds_ct.count loop
    b_lenh:=FKH_JS_LENH('so_id_dt,gcn,gcn_g,nvb,nvt,nvv,nvm');
    EXECUTE IMMEDIATE b_lenh into
        ds_so_id(ds_lp),ds_gcn(ds_lp),ds_gcnG(ds_lp),a_nv(1),a_nv(2),a_nv(3),a_nv(4) using a_ds_ct(ds_lp);
    ds_kieu_gcn(ds_lp):='G'; ds_gcnG(ds_lp):=' ';
    ds_nv_bh(ds_lp):='';
    for b_lp1 in 1..3 loop
        a_nv(b_lp1):=nvl(trim(a_nv(b_lp1)),' ');
        if a_nv(b_lp1)='C' then
            a_nv(b_lp1):=substr('BTV',b_lp1,1);
            PKH_GHEP(ds_nv_bh(ds_lp),a_nv(b_lp1));
        end if;
    end loop;

    if ds_so_id(ds_lp)<100000 then
      PHT_ID_MOI(ds_so_id(ds_lp),b_loi);
      if b_loi is not null then return; end if;
    elsif b_kieu_hd in('S','B') and ds_gcnG(ds_lp)<>' ' then
      select count(*) into b_i1 from bh_2b_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and gcn=ds_gcnG(ds_lp);
      if b_i1=0 then b_loi:='loi:GCN '||ds_gcnG(ds_lp)||' da xoa:loi'; return; end if;
      ds_kieu_gcn(ds_lp):=b_kieu_hd;
    end if;
    if ds_gcn(ds_lp)=' ' or instr(ds_gcn(ds_lp),'.')=2 then
        if b_so_hdL='E' and b_kieu_hd<>'S' and instr(ds_nv_bh(ds_lp),'B')<>0 then
          if b_ttrang<>'D' then ds_gcn(ds_lp):=nvl(trim(ds_gcn(ds_lp)),' '); -- nam -- khi ttrang ='D' thi moi sinh so gcn cho ds xe moi
          else
            PBH_2B_VACH('2B',ds_gcn(ds_lp),b_loi);
            if b_loi is not null then return; end if;
          end if;
        else
            ds_gcn(ds_lp):=substr(to_char(ds_so_id(ds_lp)),3);
            if ds_kieu_gcn(ds_lp)<>'G' then
                select count(*) into b_i1 from bh_2b_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and kieu_gcn=b_kieu_hd;
                ds_gcn(ds_lp):=ds_gcn(ds_lp)||'/'||b_kieu_hd||to_char(b_i1+1);
            end if;
        end if;
    end if;

    PKH_JS_THAYa(a_ds_ct(ds_lp),'gcn',ds_gcn(ds_lp));
    select json_object('ds_ct' value a_ds_ct(ds_lp),'ds_dk' value a_ds_dk(ds_lp),
        'ds_lt' value a_ds_lt(ds_lp),'ds_kbt' value a_ds_kbt(ds_lp),'ds_ttt' value a_ds_ttt(ds_lp),
        'ds_dkbs' value a_ds_dkbs(ds_lp) returning clob) into a_dsM(b_lp) from dual;
  end loop;
end loop;

dt_ds:=FKH_ARRc_JS(a_dsM);
update bh_2b_txt set txt=dt_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
update bh_2b set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_hdL='P' then
    PBH_2B_DON(b_ma_dvi,b_so_id,'N',b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_2B_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_NG_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; b_nv varchar2(10); ds_gcn pht_type.a_var;  
begin
-- dan - Update sau duyet
select so_hd,nv into b_so_hd,b_nv from bh_ng where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_ng_ds where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_ng_ds set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
b_nv:=substr(b_nv,1,2);
if b_nv='TD' then
    select txt into b_txt from bh_ngtd_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_ngtd_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_ngtd set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='SK' then
    select txt into b_txt from bh_sk_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_sk_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_sk set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select txt into b_txt from bh_ngdl_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_ngdl_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_ngdl set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
update bh_ng set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NG_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_PHH_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; ds_gcn pht_type.a_var; 
begin
-- dan - Update sau duyet
select so_hd into b_so_hd from bh_phh where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_phh_dvi where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_phh_dvi set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
select txt into b_txt from bh_phh_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_phh set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_phh_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PHH_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_PKT_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; ds_gcn pht_type.a_var; 
begin
-- dan - Update sau duyet
select so_hd into b_so_hd from bh_pkt where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_pkt_dvi where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_pkt_dvi set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
select txt into b_txt from bh_pkt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_pkt set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_pkt_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PKT_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_TAU_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; ds_gcn pht_type.a_var; 
begin
-- dan - Update sau duyet
select so_hd into b_so_hd from bh_tau where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_tau_ds where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_tau_ds set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
select txt into b_txt from bh_tau_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_tau set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_tau_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_TAU_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_XE_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(2000); b_i1 number; b_nv varchar2(10); b_so_hdL varchar2(1); b_kieu_hd varchar2(1); b_txt clob; b_txt_ds clob;
    ds_so_id pht_type.a_num; ds_gcn pht_type.a_var; ds_gcnG pht_type.a_var; ds_kieu_gcn pht_type.a_var; ds_nv_bh pht_type.a_var;
    dt_ds clob; a_dt_ds pht_type.a_clob; a_ds_ct pht_type.a_clob; a_ds_dk pht_type.a_clob; a_ds_lt pht_type.a_clob; a_ds_ttt pht_type.a_clob;
    a_nv pht_type.a_var; a_ds_kbt pht_type.a_clob; a_ds_dkbs pht_type.a_clob; a_dsM pht_type.a_clob;
begin
-- dan - Update sau duyet
select so_hd,so_hdL,kieu_hd,nv into b_so_hd,b_so_hdL,b_kieu_hd,b_nv from bh_xe where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
select txt into b_txt from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_xe_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';

-- update txt 
-- viet anh -- check count
select count(*) into b_i1 from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
if b_i1<>0 then
   select FKH_JS_BONH(txt) into b_txt_ds from bh_xe_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
end if;
b_lenh:=FKH_JS_LENHc('');
EXECUTE IMMEDIATE b_lenh bulk collect into a_dt_ds using b_txt_ds;
for b_lp in 1..a_dt_ds.count loop
  b_txt_ds:=FKH_JS_BONH(a_dt_ds(b_lp));
  b_lenh:=FKH_JS_LENHc('ds_ct,ds_dk,ds_lt,ds_kbt,ds_ttt,ds_dkbs');
  EXECUTE IMMEDIATE b_lenh bulk collect into a_ds_ct,a_ds_dk,a_ds_lt,a_ds_kbt,a_ds_ttt,a_ds_dkbs using b_txt_ds;
  if a_ds_ct.count=0 then b_loi:='loi:Nhap danh sach xe:loi'; return; end if;
  for ds_lp in 1..a_ds_ct.count loop
    b_lenh:=FKH_JS_LENH('so_id_dt,gcn,gcn_g,nvb,nvt,nvv,nvm');
    EXECUTE IMMEDIATE b_lenh into
        ds_so_id(ds_lp),ds_gcn(ds_lp),ds_gcnG(ds_lp),a_nv(1),a_nv(2),a_nv(3),a_nv(4) using a_ds_ct(ds_lp);
    ds_kieu_gcn(ds_lp):='G'; ds_gcnG(ds_lp):=' ';
    ds_nv_bh(ds_lp):='';
    for b_lp1 in 1..3 loop
        a_nv(b_lp1):=nvl(trim(a_nv(b_lp1)),' ');
        if a_nv(b_lp1)='C' then
            a_nv(b_lp1):=substr('BTV',b_lp1,1);
            PKH_GHEP(ds_nv_bh(ds_lp),a_nv(b_lp1));
        end if;
    end loop;

    if ds_so_id(ds_lp)<100000 then
      PHT_ID_MOI(ds_so_id(ds_lp),b_loi);
      if b_loi is not null then return; end if;
    elsif b_kieu_hd in('S','B') and ds_gcnG(ds_lp)<>' ' then
      select count(*) into b_i1 from bh_xe_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and gcn=ds_gcnG(ds_lp);
      if b_i1=0 then b_loi:='loi:GCN '||ds_gcnG(ds_lp)||' da xoa:loi'; return; end if;
      ds_kieu_gcn(ds_lp):=b_kieu_hd;
    end if;
    if ds_gcn(ds_lp)=' ' or instr(ds_gcn(ds_lp),'.')=2 then
        if b_so_hdL='E' and b_kieu_hd<>'S' and instr(ds_nv_bh(ds_lp),'B')<>0 then
          if b_ttrang<>'D' then ds_gcn(ds_lp):=nvl(trim(ds_gcn(ds_lp)),' '); -- nam -- khi ttrang ='D' thi moi sinh so gcn cho ds xe moi
          else
            PBH_XE_VACH('XE',ds_gcn(ds_lp),b_loi);
            if b_loi is not null then return; end if;
          end if;
        else
            ds_gcn(ds_lp):=substr(to_char(ds_so_id(ds_lp)),3);
            if ds_kieu_gcn(ds_lp)<>'G' then
                select count(*) into b_i1 from bh_xe_ds where ma_dvi=b_ma_dvi and so_id_dt=ds_so_id(ds_lp) and kieu_gcn=b_kieu_hd;
                ds_gcn(ds_lp):=ds_gcn(ds_lp)||'/'||b_kieu_hd||to_char(b_i1+1);
            end if;
        end if;
    end if;

    PKH_JS_THAYa(a_ds_ct(ds_lp),'gcn',ds_gcn(ds_lp));
    select json_object('ds_ct' value a_ds_ct(ds_lp),'ds_dk' value a_ds_dk(ds_lp),
        'ds_lt' value a_ds_lt(ds_lp),'ds_kbt' value a_ds_kbt(ds_lp),'ds_ttt' value a_ds_ttt(ds_lp),
        'ds_dkbs' value a_ds_dkbs(ds_lp) returning clob) into a_dsM(b_lp) from dual;
  end loop;
end loop;

dt_ds:=FKH_ARRc_JS(a_dsM);
update bh_xe_txt set txt=dt_ds where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ds';
update bh_xe set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_hdL='P' then
    PBH_XE_DON(b_ma_dvi,b_so_id,'N',b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_XE_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_HANG_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_txt clob;
begin
-- dan - Update sau duyet
select so_hd into b_so_hd from bh_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
select txt into b_txt from bh_hang_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_hang set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_hang_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HANG_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_PTN_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; b_nv varchar2(10); ds_gcn pht_type.a_var; 
begin
-- Nam - Update sau duyet
select so_hd,nv into b_so_hd,b_nv from bh_ptn where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_ptn_dvi where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_ptn_dvi set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
b_nv:=substr(b_nv,3,4);
if b_nv='NN' then
    select txt into b_txt from bh_ptnnn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_ptnnn_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_ptnnn set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='CC' then
    select txt into b_txt from bh_ptncc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_ptncc_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_ptncc set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select txt into b_txt from bh_ptnvc_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_ptnvc_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_ptnvc set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
update bh_ptn set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_PTN_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_NONG_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; b_nv varchar2(10); ds_gcn pht_type.a_var; 
begin
-- Nam - Update sau duyet
select so_hd,nv into b_so_hd,b_nv from bh_nong where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_nong_dvi where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_nong_dvi set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
if b_nv='VN' then
   select txt into b_txt from bh_nongvn_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
 PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
 update bh_nongvn_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
 update bh_nongvn set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_nv='CT' then
    select txt into b_txt from bh_nongct_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_nongct_txt set txt='"'||b_txt||'"' where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    update bh_nongct set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
else
    select txt into b_txt from bh_nongts_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
    PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
    update bh_nongts_txt set txt='"'||b_txt||'"' where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
 update bh_nongts set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
update bh_nong set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_NONG_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_HOP_HD_DU(
    b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
    b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_txt clob; ds_gcn pht_type.a_var; 
begin
-- Nam - Update sau duyet
select so_hd into b_so_hd from bh_hop where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_so_hd,'.');
if b_ttrang='D' then
    if b_i1=2 then b_so_hd:=substr(b_so_hd,3); end if;
else
    if b_i1<>2 then b_so_hd:=b_ttrang||'.'||b_so_hd; end if;
end if;
b_lenh:='select gcn from bh_hop_ds where ma_dvi= :ma_dvi and so_id= :so_id';
EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO ds_gcn using b_ma_dvi, b_so_id;
for ds_lp in 1..ds_gcn.count loop
    if instr(ds_gcn(ds_lp), '.') = 2 then
        ds_gcn(ds_lp):=substr(ds_gcn(ds_lp), 3);
    END IF;
    b_lenh := 'update bh_hop_ds set gcn= :ds_gcn where ma_dvi= :ma_dvi and so_id= :so_id';
    EXECUTE IMMEDIATE b_lenh using ds_gcn(ds_lp), b_ma_dvi, b_so_id;
end loop;
select txt into b_txt from bh_hop_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
PKH_JS_THAYa(b_txt,'so_hd,ksoat,dvi_ksoat,ttrang',b_so_hd||','||b_nsd_ks||','||b_ma_dvi_ks||','||b_ttrang);
update bh_hop set so_hd=b_so_hd,ttrang=b_ttrang,dvi_ksoat=b_ma_dvi_ks,ksoat=b_nsd_ks where ma_dvi=b_ma_dvi and so_id=b_so_id;
update bh_hop_txt set txt=b_txt where ma_dvi=b_ma_dvi and so_id=b_so_id and loai='dt_ct';
b_loi:='';
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HOP_HD_DU:loi'; end if;
end;
/
create or replace procedure PBH_HD_DU_NV(
    b_nv varchar2,b_ma_dvi varchar2,b_so_id number,b_ma_dvi_ks varchar2,b_nsd_ks varchar2,
	b_ttrang varchar2,b_so_hd out varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(1000);
begin
-- Dan - Update NV sau duyet
b_lenh:='begin PBH_'||b_nv||'_HD_DU(:ma_dvi,:so_id,:ma_dvi_ks,:nsd_ks,:ttrang,:so_hd,:loi); end;';
--nam: out b_so_hd
EXECUTE IMMEDIATE b_lenh using b_ma_dvi,b_so_id,b_ma_dvi_ks,b_nsd_ks,b_ttrang,out b_so_hd,out b_loi;
exception when others then if b_loi is null then b_loi:='loi:Loi xu ly PBH_HD_DU_NV:loi'; end if;
end;
/
