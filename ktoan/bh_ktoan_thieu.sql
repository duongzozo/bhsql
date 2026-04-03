create or replace function FKT_PB_KIEU
    (b_ma_dvi varchar2,b_ngay_ht number,b_ma_tk varchar2,b_ma_tke varchar2:=' ') return varchar2
AS
    b_kq varchar2(1):=' '; b_ngay number;
begin
-- Dan - Tra kieu bo
select nvl(max(ngay),0) into b_ngay from kt_pb where ma_dvi=b_ma_dvi and ngay<=b_ngay_ht and instr(b_ma_tk,ma_tk)=1
    and (trim(ma_tke) is null or trim(b_ma_tke) is null or  instr(b_ma_tke,ma_tke)=1);
if b_ngay<>0 then
    select nvl(max(kieu),' ') into b_kq from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and instr(b_ma_tk,ma_tk)=1
        and (trim(ma_tke) is null or trim(b_ma_tke) is null or instr(b_ma_tke,ma_tke)=1);
end if;
return b_kq;
end;
/
create or replace function FKT_PB_NHOM
    (b_ma_dvi varchar2,b_ngay_ht number,b_ma_tk varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; b_ngay number;
begin
-- Dan - Tra kieu bo
select nvl(max(ngay),0) into b_ngay from kt_pb where ma_dvi=b_ma_dvi and ngay<=b_ngay_ht and instr(b_ma_tk,ma_tk)=1;
if b_ngay<>0 then
    select nvl(max(nhom),'K') into b_kq from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and instr(b_ma_tk,ma_tk)=1;
end if;
return b_kq;
end;
/
create or replace function PKH_MA_LCT_TRA_LQ
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number,b_nv varchar2,b_ma_tk varchar2) return boolean
AS
    a_nv pht_type.a_var; a_ma_tk pht_type.a_lvar;
begin
-- Dan - Xac dinh tai khoan cua nghiep vu
PKH_MA_LCT_NVTK(b_ma_dvi,b_md,b_ma,b_ngay,a_nv,a_ma_tk);
if a_nv.count=0 then return false; end if;
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp) in('T',b_nv) and PKH_MA_LMA_C(a_ma_tk(b_lp),b_ma_tk)='C' then return true; end if;
end loop;
return false;
end;
/
create or replace function PKH_MA_LCT_TRA_TK
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number,b_nv varchar2:='T',b_dubi varchar2:=' ',b_tc varchar2:='K') return varchar2
AS
    b_ma_tk varchar2(1500):=''; a_nv pht_type.a_var; a_ma_tk pht_type.a_lvar;
begin
-- Dan - Tra tai khoan
PKH_MA_LCT_NVTK(b_ma_dvi,b_md,b_ma,b_ngay,a_nv,a_ma_tk,b_tc);
if a_nv.count=0 then return b_dubi; end if;
for b_lp in 1..a_nv.count loop
    if b_nv='T' or a_nv(b_lp) in('T',b_nv) then
        if trim(b_ma_tk) is null then b_ma_tk:=trim(a_ma_tk(b_lp));
        else
            b_ma_tk:=trim(b_ma_tk)||','||trim(a_ma_tk(b_lp));
        end if;
    end if;
end loop;
return b_ma_tk;
end;
/
create or replace procedure PKH_MA_LCT_NVTK
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number,
    a_nv out pht_type.a_var,a_ma_tk out pht_type.a_lvar,b_tc varchar2:='K')
AS
    b_d1 number; b_i1 number:=0;
begin
-- Dan - Xac dinh tai khoan theo loai chung tu
PKH_MANG_KD(a_nv);
select nvl(max(ngay),0) into b_d1 from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay<=b_ngay;
if b_d1=0 then return; end if;
for b_rc in (select distinct nv,ma_tk from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_d1) loop
    if b_rc.nv in ('N','C','T') or b_tc='C' then
        b_i1:=0;
        for b_lp in 1..a_nv.count loop
            if a_nv(b_lp)=b_rc.nv then b_i1:=b_lp; exit; end if;
        end loop;
        if b_i1<>0 then
            a_ma_tk(b_i1):=trim(a_ma_tk(b_i1))||','||trim(b_rc.ma_tk);
        else    b_i1:=a_nv.count+1; a_nv(b_i1):=b_rc.nv; a_ma_tk(b_i1):=b_rc.ma_tk;
        end if;
    end if;
end loop;
end;
/
create or replace procedure PKT_KT2_NH
    (b_idvung number,b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,a_nv pht_type.a_var,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num,
    a_note pht_type.a_nvar,a_tc pht_type.a_var,a_bt pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_ngay number;
begin
-- Dan - Nhap KT2
b_loi:='loi:Loi Table KT_2:loi'; b_i1:=0;
for b_lp in 1..a_nv.count loop
    if b_i1<a_bt(b_lp) then b_i1:=a_bt(b_lp); end if;
end loop;
for b_lp in 1..a_nv.count loop
    if a_bt(b_lp)<>0 then b_i2:=a_bt(b_lp); else b_i1:=b_i1+1; b_i2:=b_i1; end if;
    insert into kt_2 values(b_ma_dvi,b_so_id,b_i2,b_ngay_ht,a_nv(b_lp),a_ma_tk(b_lp),a_ma_tke(b_lp),a_tien(b_lp),a_note(b_lp),b_idvung);
end loop;
select count(*) into b_i1 from kt_sp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>0 then
    select nvl(max(ngay),0) into b_ngay from kh_pbo where ma_dvi=b_ma_dvi and ngay<=b_ngay_ht;
    for b_lp in 1..a_nv.count loop
        select count(*) into b_i1 from (select a.ma_sp from kt_sp a, kh_pbo_sp b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and a.bt=a_bt(b_lp)
            and b.ma_dvi=b_ma_dvi and b.ngay=b_ngay and b.ma_tk=a_ma_tk(b_lp) and b.ma_sp=a.ma_sp);
        if b_i1=0 then
            delete kt_sp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp);
        end if;
    end loop;
    delete kt_sp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt not in(select bt from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id);
end if;
select count(*) into b_i1 from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1>0 then
    for b_lp in 1..a_nv.count loop
        if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,a_nv(b_lp),a_ma_tk(b_lp))=false then
            delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp);
        end if;
    end loop;
    delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt not in(select bt from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id);
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LOC_LCT
    (b_l_ct_n varchar2,a_nv_n pht_type.a_var,a_ma_tk_n pht_type.a_var,a_ma_tke_n pht_type.a_var,a_tc_n pht_type.a_var,a_tien_n pht_type.a_num,
    a_nv out pht_type.a_var,a_ma_tk out pht_type.a_var,a_ma_tke out pht_type.a_var,a_tc out pht_type.a_var,a_tien out pht_type.a_num)
AS
    b_kt number:=0; b_l_ct varchar2(10):=nvl(b_l_ct_n,' ');
begin
-- Dan - Loc tai khoan theo loai CT
PKH_MANG_KD(a_nv);
for b_lp in 1..a_nv_n.count loop
    if (a_nv_n(b_lp)='N' and (b_l_ct<>'KC/N') or (a_nv_n(b_lp)='C' and b_l_ct<>'KC/C')) then
        b_kt:=b_kt+1;
        a_nv(b_kt):=a_nv_n(b_lp); a_ma_tk(b_kt):=a_ma_tk_n(b_lp); a_ma_tke(b_kt):=a_ma_tke_n(b_lp); a_tc(b_kt):=a_tc_n(b_lp); a_tien(b_kt):=a_tien_n(b_lp);
    end if;
end loop;
end;
/
CREATE OR REPLACE procedure PKH_MA_LCT_TKNV
    (b_ma_dvi varchar2,b_md varchar2,b_ngay number,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,b_ma out varchar2)
AS
    b_i1 number; b_i2 number:=0; a_nv_l pht_type.a_var; a_ma_tk_l pht_type.a_var;
    a_nv_n pht_type.a_var; a_ma_tk_n pht_type.a_lvar; a_kq pht_type.a_num;
begin
-- Dan - Xac dinh loai chung tu nghiep vu theo tai khoan
b_ma:=' ';
PKH_MA_LCT_TK(b_ma_dvi,b_md,b_ngay,a_nv,a_ma_tk,a_nv_l,a_ma_tk_l);
if a_nv_l.count=0 then return; end if;
for r_lp in(select distinct ma from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md) loop
    PKH_MA_LCT_NVTK(b_ma_dvi,b_md,r_lp.ma,b_ngay,a_nv_n,a_ma_tk_n);
    if a_nv_n.count<>0 then
        for b_lp in 1..a_nv_l.count loop
            a_kq(b_lp):=0;
        end loop;
        for b_lp in 1..a_nv_n.count loop
            b_i1:=0;
            for b_lp1 in 1..a_nv_l.count loop
                if a_nv_n(b_lp) in('T',a_nv_l(b_lp1)) and PKH_MA_LMA_C(a_ma_tk_n(b_lp),a_ma_tk_l(b_lp1))='C' then
                    b_i1:=1; a_kq(b_lp1):=1;
                end if;
            end loop;
            if b_i1=0 then exit; end if;
        end loop;
        if b_i1<>0 then
            for b_lp in 1..a_nv_l.count loop
                if a_kq(b_lp)=0 then b_i1:=0; exit; end if;
            end loop;
            if b_i1<>0 then b_ma:=r_lp.ma; return; end if;
        end if;
        b_i2:=1;
    end if;
end loop;
if b_i2<>0 then
    for r_lp in(select distinct ma from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md) loop
        if FKH_MA_LCT_NVBK(b_ma_dvi,b_md,r_lp.ma,b_ngay)='C' then b_ma:=r_lp.ma; return; end if;
    end loop;
end if;
end;
/
create or replace procedure PKH_MA_LCT_TK
    (b_ma_dvi varchar2,b_md varchar2,b_ngay number,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,
    a_nv_l out pht_type.a_var,a_ma_tk_l out pht_type.a_var,b_ma varchar2:='')
AS
    b_i1 number; a_nv_n pht_type.a_var; a_ma_tk_n pht_type.a_lvar;
begin
-- Dan - Xac dinh tai khoan lien quan nghiep vu
PKH_MANG_KD(a_nv_l);
for r_lp in(select distinct ma from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and (b_ma is null or ma=b_ma) and nv in('N','C','T')) loop
    PKH_MA_LCT_NVTK(b_ma_dvi,b_md,r_lp.ma,b_ngay,a_nv_n,a_ma_tk_n);
    b_i1:=0;
    for b_lp in 1..a_nv_n.count loop
        b_i1:=0;
        for b_lp1 in 1..a_nv.count loop
            if a_nv_n(b_lp) in('T',a_nv(b_lp1)) and PKH_MA_LMA_C(a_ma_tk_n(b_lp),a_ma_tk(b_lp1))='C' then b_i1:=1; exit; end if;
        end loop;
        exit when b_i1=0;
    end loop;
    if b_i1<>0 then
        for b_lp1 in 1..a_nv.count loop
            b_i1:=0;
            for b_lp in 1..a_nv_n.count loop
                if a_nv_n(b_lp) in('T',a_nv(b_lp1)) and PKH_MA_LMA_C(a_ma_tk_n(b_lp),a_ma_tk(b_lp1))='C' then b_i1:=1; exit; end if;
            end loop;
            if b_i1<>0 then
                for b_lp in 1..a_nv_l.count loop
                    if a_nv_l(b_lp)=a_nv(b_lp1) and a_ma_tk_l(b_lp)=a_ma_tk(b_lp1) then b_i1:=0; exit; end if;
                end loop;               
                if b_i1<>0 then
                    b_i1:=a_nv_l.count+1; a_nv_l(b_i1):=a_nv(b_lp1); a_ma_tk_l(b_i1):=a_ma_tk(b_lp1);
                end if;
            end if;
        end loop;
    end if;
end loop;
end;
/
create or replace function FKH_MA_LCT_NVBK
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number) return varchar2
AS
    b_d1 number; b_tc varchar2(1); b_kq varchar2(1):='K';
begin
-- Dan - Xac dinh loai chung tu lien quan den tai khoan bat ky
select nvl(max(ngay),0) into b_d1 from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay<=b_ngay;
if b_d1<>0 then
    select tc into b_tc from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_d1;
    if trim(b_tc) is not null and b_tc='B' then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PCN_NV_NH
    (b_ma_dvi varchar2,b_so_id number,b_tt out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; a_ch pht_type.a_var; b_thue number;
    b_md varchar2(2); b_nsd varchar2(20); b_ngay_ht number; b_ty_gia number; b_ma_kh varchar2(21); b_idvung number;
    b_nd nvarchar2(400); b_ndp nvarchar2(400); b_tien number; b_tien_n number; b_noite varchar2(5); b_so_ct varchar2(30);
    b_viec varchar2(20):=' '; b_hdong varchar2(20):=' '; b_hdongB varchar2(20):=' '; b_bt number:=0; b_kt number; b_htoan varchar2(1);
    b_l_ct_cn varchar2(10); b_nh_ts varchar2(1); b_tp number:=0; b_s varchar2(200);  b_t varchar2(200);
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_ma_tk_xl pht_type.a_var;
    a_tien pht_type.a_num; b_lk varchar2(100); b_ngay_ct varchar2(10); b_l_ct_vt varchar2(1):=' ';
    b_ma_nt varchar2(5); b_ma_nt_t varchar2(5); b_ma_nt_c varchar2(5); b_tg_tt number;
    a_l_cn pht_type.a_var; a_l_ct pht_type.a_var; a_l_ct_xl pht_type.a_var; a_ma_tk_l pht_type.a_var;
    a_tien_l pht_type.a_num; a_tien_qd_l pht_type.a_num; a_tien_vt_l pht_type.a_num;

    a_loai pht_type.a_var; a_loai_xl pht_type.a_var; a_ma_cn pht_type.a_var; a_ma_nt pht_type.a_var;
    a_viec pht_type.a_var; a_hdong pht_type.a_var; a_ma_ctr pht_type.a_var;
    a_viec_vt pht_type.a_var; a_hdong_vt pht_type.a_var; a_hdongB_vt pht_type.a_var;
    a_tien_vt pht_type.a_num; a_thue_vt pht_type.a_num; a_tien_vt_qd pht_type.a_num;
    a_tl_vt pht_type.a_num; a_vt_chia pht_type.a_num; a_ty_gia pht_type.a_num;
    a_bt_ps pht_type.a_num; a_ct_th pht_type.a_nvar; a_han pht_type.a_num;
    a_ls_bt pht_type.a_num; a_ls_ppt pht_type.a_var; a_ls_ngay pht_type.a_num; a_ls_tien pht_type.a_num; a_ls_ls pht_type.a_num;
    a_bt_tt pht_type.a_num; a_so_id pht_type.a_num; a_bt pht_type.a_num; a_tra pht_type.a_num; a_tra_qd pht_type.a_num;
    a_phi pht_type.a_num; a_phi_qd pht_type.a_num;
    b_cn_ctr varchar2(1); b_cn_tdoi varchar2(1); b_l_ct_xl varchar2(2); b_loai varchar2(1);
    a_so_id_xl pht_type.a_num; a_bt_xl pht_type.a_num; a_tra_xl pht_type.a_num;
    a_tra_qd_xl pht_type.a_num; a_phi_xl pht_type.a_num; a_phi_qd_xl pht_type.a_num;
    r_cn cn_ps%rowtype;
begin
-- Dan - Chuyen chung tu hach toan sang cong no
b_loi:='loi:Chung tu hach toan da xoa:loi';
select md,nsd,ngay_ht,so_ct,ngay_ct,nd,ndp,idvung into b_md,b_nsd,b_ngay_ht,b_so_ct,b_ngay_ct,b_nd,b_ndp,b_idvung
    from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKT_TRA_KT2(b_ma_dvi,b_so_id,a_nv,a_ma_tk,a_ma_tke,a_tien,b_lk,b_loi);
if b_loi is not null then return; end if;
PKH_MA_LCT_TK(b_ma_dvi,'CN',b_ngay_ht,a_nv,a_ma_tk,a_l_ct,a_ma_tk_l,'CN');
if a_l_ct.count=0 then b_loi:='loi:Chuyen nghiep vu cong no sai:loi'; return; end if;
PKH_MA_LCT_TIEN(a_nv,a_ma_tk,a_tien,a_l_ct,a_ma_tk_l,a_tien_qd_l);
b_noite:=FTT_TRA_NOITE(b_ma_dvi);
PKH_MANG_KD(a_hdong_vt);
if b_md='VT' or instr(b_lk,'VT:2')>0 then
    select l_ct,nh_ts,nvl(k_ma_kh||ma_kh,'K'),ma_nt,thue,tien_tt,hdongM,hdongB,viec,tg_tt
        into b_l_ct_vt,b_nh_ts,b_ma_kh,b_ma_nt_t,b_thue,b_tien,b_hdong,b_hdongB,b_viec,b_tg_tt from vt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_l_ct_vt in ('N','X','P','B','S') then
        select hdongMC,hdongBC,viec,sum(tien),sum(thue) bulk collect into a_hdong_vt,a_hdongB_vt,a_viec_vt,a_tien_vt,a_thue_vt from
            (select hdongMC,hdongBC,nvl(trim(Cviec),b_viec) viec,tien,thue from (select * from vt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id)
            where tien<>0 and trim(hdongMC) is not null or (b_l_ct_vt='X' and trim(hdongBC) is not null))
            group by hdongMC,hdongBC,viec having sum(tien)<>0;
        if b_ma_nt_t<>b_noite then b_tp:=2; end if;
        b_i1:=0;
        if b_l_ct_vt='X' then
            b_hdong:=b_hdongB;
            for b_lp in 1..a_hdong_vt.count loop
                a_hdong_vt(b_lp):=a_hdongB_vt(b_lp);
            end loop;
        end if;
        for b_lp in 1..a_hdong_vt.count loop
            a_tien_vt(b_lp):=a_tien_vt(b_lp)+a_thue_vt(b_lp);
            b_i1:=b_i1+a_tien_vt(b_lp); a_tl_vt(b_lp):=1;
        end loop;
        if b_i1<>0 then
            b_i2:=0;
            for b_lp in 1..a_hdong_vt.count loop
                a_tl_vt(b_lp):=round(a_tien_vt(b_lp)/b_i1,5);
                b_i2:=b_i2+a_thue_vt(b_lp);
            end loop;
            FKH_CHIA(b_tien,a_hdong_vt,a_tl_vt,a_vt_chia);
            for b_lp in 1..a_hdong_vt.count loop
                a_tien_vt(b_lp):=a_vt_chia(b_lp);
            end loop;
            if b_nh_ts='K' and b_thue<>0 and b_i2=0 then
                FKH_CHIA(b_thue,a_hdong_vt,a_tl_vt,a_vt_chia);
                for b_lp in 1..a_hdong_vt.count loop
                    a_tien_vt(b_lp):=a_tien_vt(b_lp)+a_vt_chia(b_lp);
                end loop;
            end if;
        end if;
        b_ma_nt_c:=b_ma_nt_t;
    end if;
elsif b_md='TT' or instr(b_lk,'TT:2')>0 then
    select k_ma_kh||ma_kh,ma_nt_t,ma_nt_c,viec,hdong,tien_t+tien_c
        into b_ma_kh,b_ma_nt_t,b_ma_nt_c,b_viec,b_hdong,b_tien from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
elsif b_md='TV' or instr(b_lk,'TV:2')>0 then
    select ma_nt,t_toan into b_ma_nt_t,b_tien from tv_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
select nvl(max(k_ma_kh||ma_kh),'K') into b_ma_kh from tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_nt_c:=b_ma_nt_t;
elsif b_md='XL' or instr(b_lk,'XL:2')>0 then
    select nvl(k_ma_kh||ma_kh,'K'),ma_nt,tien into b_ma_kh,b_ma_nt_t,b_tien from xl_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_nt_c:=b_ma_nt_t;
else
    b_ma_kh:='K';
    b_ma_nt_t:=b_noite; b_ma_nt_c:=b_noite; b_tien:=0;
    for b_lp in 1..a_l_ct.count loop
        b_tien:=b_tien+a_tien_qd_l(b_lp);
    end loop;
end if;
PKH_MANG_KD_N(a_ls_bt); PKH_MANG_KD_N(a_bt_tt); PKH_MANG_KD_N(a_bt_ps);
PKH_MANG_KD(a_loai); PKH_MANG_KD(a_loai_xl);
if b_md='BH' then
   PKH_MANG_XOA(a_l_ct); PKH_MANG_XOA(a_ma_tk_l); PKH_MANG_XOA_N(a_tien_l); PKH_MANG_XOA_N(a_tien_qd_l);
   for r_lp in(select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        b_l_ct_cn:=FCN_TK_MA(b_ma_dvi,b_ngay_ht,r_lp.ma_tk);
        if trim(b_l_ct_cn) is not null then
            b_i1:=instr(r_lp.note,'['); b_i2:=instr(r_lp.note,']');
            if (b_i1<>0 and b_i2>b_i1) then
                b_i1:=b_i1+1;
                PKH_CH_ARR(substr(r_lp.note,b_i1,b_i2-b_i1),a_ch);
                b_bt:=b_bt+1;
                a_bt_ps(b_bt):=b_bt; a_l_ct(b_bt):=r_lp.nv; a_l_cn(b_bt):=b_l_ct_cn;
                b_loai:=FCN_TK_PS(b_ma_dvi,b_ngay_ht,r_lp.ma_tk);
                if b_loai='N' then
                    if a_l_ct(b_bt)='N' then b_l_ct_xl:='PN'; else b_l_ct_xl:='TN'; end if;
                else
                    if a_l_ct(b_bt)='C' then b_l_ct_xl:='PC'; else b_l_ct_xl:='TC'; end if;
                end if;
                a_loai_xl(b_bt):=substr(b_l_ct_xl,1,1); a_l_ct_xl(b_bt):=substr(b_l_ct_xl,2,1);
                a_loai(b_bt):=a_loai_xl(b_bt); a_ma_cn(b_bt):='K'||a_ch(3); a_ma_nt(b_bt):=a_ch(4);
                a_ma_tk_xl(b_bt):=r_lp.ma_tk; a_ma_tk_l(b_bt):=r_lp.ma_tk;
                a_tien_l(b_bt):=PKH_LOC_CHU_SO(a_ch(6),'T'); a_tien_qd_l(b_bt):=r_lp.tien;
                a_ct_th(b_bt):=r_lp.note; a_ty_gia(b_bt):=round(a_tien_qd_l(b_bt)/a_tien_l(b_bt),2);
                a_han(b_bt):=0; a_viec(b_bt):=' '; a_hdong(b_bt):=' '; a_ma_ctr(b_bt):=' ';
            end if;
        end if;
    end loop;
end if;
if b_md='DP' then
    select l_ct into b_l_ct_xl from dp_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_l_ct_xl='KN' then
        PKH_MANG_XOA(a_l_ct); PKH_MANG_XOA(a_ma_tk_l); PKH_MANG_XOA_N(a_tien_l); PKH_MANG_XOA_N(a_tien_qd_l);
        for r_lp in(select * from dp_cn where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_bt:=b_bt+1;
            select * into r_cn from cn_ps where ma_dvi=b_ma_dvi and so_id=r_lp.so_id_ps and bt=r_lp.bt_ps;
            a_bt_ps(b_bt):=b_bt; a_l_ct(b_bt):='N'; a_l_ct_xl(b_bt):='N'; a_loai_xl(b_bt):='T';
            a_ma_cn(b_bt):=r_cn.ma_cn; a_ma_nt(b_bt):=r_cn.ma_nt;
            a_ma_tk_xl(b_bt):=r_cn.ma_tk; a_ma_tk_l(b_bt):=r_cn.ma_tk;
            a_l_cn(b_bt):=FCN_TK_MA(b_ma_dvi,b_ngay_ht,a_ma_tk_l(b_bt));
            a_viec(b_bt):=r_cn.viec; a_hdong(b_bt):=r_cn.hdong; a_ma_ctr(b_bt):=r_cn.ma_ctr;
            a_tien_l(b_bt):=r_cn.tien-r_cn.tra; a_tien_qd_l(b_bt):=r_cn.tien_qd-r_cn.tra_qd; a_ty_gia(b_bt):=1;
            a_bt_tt(b_bt):=b_bt; a_so_id(b_bt):=r_lp.so_id_ps; a_bt(b_bt):=r_lp.bt_ps;
            a_tra(b_bt):=r_cn.tien-r_cn.tra; a_tra_qd(b_bt):=r_cn.tien_qd-r_cn.tra_qd;
            a_phi(b_bt):=0; a_phi_qd(b_bt):=0; a_loai(b_bt):='T'; a_han(b_bt):=0; a_ct_th(b_bt):=' ';
        end loop;
    end if;
elsif b_md='KT' then
   PKH_MANG_XOA(a_l_ct); PKH_MANG_XOA(a_ma_tk_l); PKH_MANG_XOA_N(a_tien_l); PKH_MANG_XOA_N(a_tien_qd_l);
   for r_lp in(select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        b_l_ct_cn:=FCN_TK_MA(b_ma_dvi,b_ngay_ht,r_lp.ma_tk);
        if trim(b_l_ct_cn) is not null then
            b_i1:=instr(r_lp.note,'['); b_i2:=instr(r_lp.note,']');
      b_bt:=b_bt+1;
            b_i1:=instr(r_lp.note,'['); b_i2:=instr(r_lp.note,']');
            if b_i1<>0 and b_i2>b_i1 then
                b_i1:=b_i1+1; b_i2:=b_i2-b_i1;
                b_s:=substr(r_lp.note,b_i1,b_i2);
                b_t:=FKH_CH_TIM(b_s,'kh');
                if b_t<>' ' then
                    a_ma_cn(b_bt):='K'||b_t;
                else
                    b_t:=FKH_CH_TIM(b_s,'cb');
                    if b_t<>' ' then a_ma_cn(b_bt):='C'||b_t; end if;
                end if;
        a_viec(b_bt):=FKH_CH_TIM(b_s,'vi');
        a_hdong(b_bt):=FKH_CH_TIM(b_s,'hm');
                if a_hdong(b_bt)=' ' then a_hdong(b_bt):=FKH_CH_TIM(b_s,'hb'); end if;
      else
        a_ma_cn(b_bt):='K';
        a_viec(b_bt):=' ';
        a_hdong(b_bt):=' ';
      end if;
            a_bt_ps(b_bt):=b_bt; a_l_ct(b_bt):=r_lp.nv; a_l_cn(b_bt):=b_l_ct_cn;
            b_loai:=FCN_TK_PS(b_ma_dvi,b_ngay_ht,r_lp.ma_tk);
            if b_loai='N' then
                if a_l_ct(b_bt)='N' then b_l_ct_xl:='PN'; else b_l_ct_xl:='TN'; end if;
            else
        if a_l_ct(b_bt)='C' then b_l_ct_xl:='PC'; else b_l_ct_xl:='TC'; end if;
            end if;
            a_loai_xl(b_bt):=substr(b_l_ct_xl,1,1); a_l_ct_xl(b_bt):=substr(b_l_ct_xl,2,1);
            a_loai(b_bt):=a_loai_xl(b_bt);
            a_ma_nt(b_bt):='VND';
            --a_ma_cn(b_bt):='K';
            a_ma_tk_xl(b_bt):=r_lp.ma_tk; a_ma_tk_l(b_bt):=r_lp.ma_tk;
            a_tien_l(b_bt):=r_lp.tien; a_tien_qd_l(b_bt):=r_lp.tien;
            a_ct_th(b_bt):=r_lp.note; a_ty_gia(b_bt):=1; a_han(b_bt):=0;
            a_ma_ctr(b_bt):=' ';

        end if;
    end loop;
elsif b_bt=0 and a_hdong_vt.count>0 then
    for b_lp in 1..a_l_ct.count loop
        a_tien_vt_l(b_lp):=a_tien_qd_l(b_lp); a_ma_tk_xl(b_lp):=a_ma_tk_l(b_lp);
    end loop;
    PKH_MANG_XOA(a_ma_tk_l); PKH_MANG_XOA_N(a_tien_l); PKH_MANG_XOA_N(a_tien_qd_l);
    b_kt:=0;
    for b_lp in 1..a_l_ct.count loop
        b_loai:=FCN_TK_PS(b_ma_dvi,b_ngay_ht,a_ma_tk_xl(b_lp));
        if b_loai='N' then
            if a_l_ct(b_lp)='N' then b_l_ct_xl:='PN'; else b_l_ct_xl:='TN'; end if;
        else
            if a_l_ct(b_lp)='C' then b_l_ct_xl:='PC'; else b_l_ct_xl:='TC'; end if;
        end if;
        if b_ma_nt_t<>b_noite then
            if b_tg_tt=1 then
                FKH_CHIA(a_tien_vt_l(b_lp),a_hdong_vt,a_tl_vt,a_vt_chia);
            else
                a_tien_qd_l(1):=a_tien_vt_l(b_lp);
                for b_lp1 in 2..a_hdong_vt.count loop
                    a_tien_qd_l(b_lp1):=round(b_tg_tt*a_tien_vt(b_lp1),0);
                    if abs(a_tien_qd_l(b_lp1))>abs(a_tien_qd_l(1)) then a_tien_qd_l(b_lp1):=a_tien_qd_l(1); end if;
                    a_vt_chia(b_lp1):=a_tien_qd_l(b_lp1);
                    a_tien_qd_l(1):=a_tien_qd_l(1)-a_tien_qd_l(b_lp1);
                end loop;
                a_vt_chia(1):=a_tien_qd_l(1);
            end if;
        end if;
        for b_lp1 in 1..a_hdong_vt.count loop
            b_kt:=b_kt+1;
            a_bt_ps(b_kt):=b_kt; a_ct_th(b_kt):=' '; a_ma_cn(b_kt):=b_ma_kh; a_ty_gia(b_kt):=b_tg_tt;
            a_viec(b_kt):=a_viec_vt(b_lp1); a_hdong(b_kt):=a_hdong_vt(b_lp1); a_ma_ctr(b_kt):=' '; a_han(b_kt):=0;
            a_ma_nt(b_kt):=b_ma_nt_c; a_ma_tk_l(b_kt):=a_ma_tk_xl(b_lp); a_tien_l(b_kt):=a_tien_vt(b_lp1);
            if a_ma_nt(b_kt)=b_noite then
                a_tien_qd_l(b_kt):=a_tien_l(b_kt);
            else
                a_tien_qd_l(b_kt):=a_vt_chia(b_lp1);
            end if;
            a_l_cn(b_kt):=FCN_TK_MA(b_ma_dvi,b_ngay_ht,a_ma_tk_l(b_kt));
            if trim(b_ma_kh) is not null and length(b_ma_kh)>1 and FKH_NV_TSO(b_ma_dvi,'KT','CN','lket')<>'K' then
                PCN_CT_TON_XLY(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct_xl,b_ma_kh,a_ma_nt(b_kt),a_ma_tk_l(b_kt),a_viec(b_kt),a_hdong(b_kt),a_ma_ctr(b_kt),
                    a_tien_l(b_kt),a_tien_qd_l(b_kt),a_so_id_xl,a_bt_xl,a_tra_xl,a_tra_qd_xl,a_phi_xl,a_phi_qd_xl,b_loi);
                if b_loi is not null then return; end if;
                if a_so_id_xl.count<>0 then
                    for b_lp_tt in 1..a_so_id_xl.count loop
                        b_bt:=b_bt+1;
                        a_bt_tt(b_bt):=b_lp; a_so_id(b_bt):=a_so_id_xl(b_lp_tt); a_bt(b_bt):=a_bt_xl(b_lp_tt);
                        a_tra(b_bt):=a_tra_xl(b_lp_tt); a_tra_qd(b_bt):=a_tra_qd_xl(b_lp_tt);
                        a_phi(b_bt):=a_phi_xl(b_lp_tt); a_phi_qd(b_bt):=a_phi_qd_xl(b_lp_tt);
                    end loop;
                end if;
            end if;
            a_loai_xl(b_kt):=substr(b_l_ct_xl,1,1); a_l_ct_xl(b_kt):=substr(b_l_ct_xl,2,1); a_loai(b_kt):=a_loai_xl(b_lp);
        end loop;
    end loop;
elsif b_bt=0 then
    for b_lp in 1..a_l_ct.count loop
        a_bt_ps(b_lp):=b_lp; a_ct_th(b_lp):=' '; a_ma_cn(b_lp):=b_ma_kh; a_ty_gia(b_lp):=1;
        a_viec(b_lp):=b_viec; a_hdong(b_lp):=b_hdong; a_ma_ctr(b_lp):=' '; a_han(b_lp):=0;
        if a_l_ct(b_lp)='N' then a_ma_nt(b_lp):=b_ma_nt_c; else a_ma_nt(b_lp):=b_ma_nt_t; end if;
        if a_ma_nt(b_lp)=b_noite then
            a_tien_l(b_lp):=a_tien_qd_l(b_lp);
        else
            a_tien_l(b_lp):=b_tien;
            if b_tien<>0 then a_ty_gia(b_lp):=round(a_tien_qd_l(b_lp)/b_tien,2); end if;
        end if;
        a_l_cn(b_lp):=FCN_TK_MA(b_ma_dvi,b_ngay_ht,a_ma_tk_l(b_lp)); b_loai:=FCN_TK_PS(b_ma_dvi,b_ngay_ht,a_ma_tk_l(b_lp));
        if b_loai='N' then
            if a_l_ct(b_lp)='N' then b_l_ct_xl:='PN'; else b_l_ct_xl:='TN'; end if;
        else
            if a_l_ct(b_lp)='C' then b_l_ct_xl:='PC'; else b_l_ct_xl:='TC'; end if;
        end if;
        if trim(b_ma_kh) is not null and length(b_ma_kh)>1 and FKH_NV_TSO(b_ma_dvi,'KT','CN','lket')<>'K' then
            PCN_CT_TON_XLY(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct_xl,b_ma_kh,a_ma_nt(b_lp),a_ma_tk_l(b_lp),a_viec(b_lp),a_hdong(b_lp),a_ma_ctr(b_lp),
                a_tien_l(b_lp),a_tien_qd_l(b_lp),a_so_id_xl,a_bt_xl,a_tra_xl,a_tra_qd_xl,a_phi_xl,a_phi_qd_xl,b_loi);
            if b_loi is not null then return; end if;
            if a_so_id_xl.count<>0 then
                for b_lp_tt in 1..a_so_id_xl.count loop
                    b_bt:=b_bt+1;
                    a_bt_tt(b_bt):=b_lp; a_so_id(b_bt):=a_so_id_xl(b_lp_tt); a_bt(b_bt):=a_bt_xl(b_lp_tt);
                    a_tra(b_bt):=a_tra_xl(b_lp_tt); a_tra_qd(b_bt):=a_tra_qd_xl(b_lp_tt);
                    a_phi(b_bt):=a_phi_xl(b_lp_tt); a_phi_qd(b_bt):=a_phi_qd_xl(b_lp_tt);
                end loop;
            end if;
        end if;
        a_loai_xl(b_lp):=substr(b_l_ct_xl,1,1); a_l_ct_xl(b_lp):=substr(b_l_ct_xl,2,1);
        a_loai(b_lp):=a_loai_xl(b_lp);
    end loop;
end if;
b_htoan:='T'; b_tt:='0';
if b_md in('VT','TV','TT','XL','DP','BH') and FKH_NV_TSO(b_ma_dvi,'KT','CN','lket')<>'K' then
    PCN_CT_TEST(b_ma_dvi,b_nsd,b_so_id,b_md,'H',b_ngay_ht,a_l_cn,a_loai_xl,a_ma_cn,a_ma_nt,a_ma_tk_xl,
        a_viec,a_hdong,a_ma_ctr,a_tien_l,a_ty_gia,a_tien_qd_l,
        a_bt_ps,a_ls_bt,a_ls_ppt,a_ls_ngay,a_ls_tien,a_ls_ls,a_bt_tt,a_so_id,a_bt,a_tra,a_tra_qd,a_phi,a_phi_qd,a_loai,b_loi);
    if b_loi is null then b_htoan:='H'; b_tt:='2';
--  elsif b_md='BH' then --b_loi:=''; return;
    end if;
    for b_lp in 1..a_l_ct.count loop
        a_l_ct_xl(b_lp):=a_loai_xl(b_lp);
    end loop;
end if;
PCN_CN_NH(b_idvung,b_ma_dvi,'',b_md,b_htoan,b_ngay_ht,b_so_id,b_so_ct,b_ngay_ct,'','C','K',0,0,'','','',b_nd,b_ndp,
    a_l_ct_xl,a_loai,a_ma_cn,a_ma_nt,a_ma_tk_l,a_viec,a_hdong,a_ma_ctr,a_ct_th,a_tien_l,a_ty_gia,a_tien_qd_l,a_han,a_bt_ps,
    a_ls_bt,a_ls_ppt,a_ls_ngay,a_ls_tien,a_ls_ls,a_bt_tt,a_so_id,a_bt,a_tra,a_tra_qd,a_phi,a_phi_qd,b_loi);
if b_loi is not null then return; end if;
if b_htoan='H' then
    PCN_THOP_CT(b_ma_dvi,'N',b_so_id,b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_TRA_KT2
    (b_ma_dvi varchar2,b_so_id number,a_nv out pht_type.a_var,
    a_ma_tk out pht_type.a_var,a_ma_tke out pht_type.a_var,
    a_tien out pht_type.a_num,b_lk out varchar2,b_loi out varchar2)
AS
    b_kt number;
begin
-- Dan - Lay KT2 cua chung tu hach toan qua ID
select min(lk) into b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKH_MANG_KD(a_nv); b_kt:=0;
for b_rc in (select nv,ma_tk,ma_tke,tien from kt_2
    where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_kt:=b_kt+1; a_nv(b_kt):=b_rc.nv; a_ma_tk(b_kt):=b_rc.ma_tk;
    a_ma_tke(b_kt):=b_rc.ma_tke; a_tien(b_kt):=b_rc.tien;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_MA_LCT_TIEN
    (a_nv pht_type.a_var,a_ma_tk pht_type.a_var,a_tien pht_type.a_num,
    a_nv_l pht_type.a_var,a_ma_tk_l pht_type.a_var,a_tien_l out pht_type.a_num)
AS
begin
-- Dan - Tra lai tien nghiep vu
for b_lp in 1..a_nv_l.count loop
    a_tien_l(b_lp):=0;
    for b_lp1 in 1..a_nv.count loop
        if a_nv_l(b_lp)=a_nv(b_lp1) and a_ma_tk_l(b_lp)=a_ma_tk(b_lp1) then
            a_tien_l(b_lp):=a_tien_l(b_lp)+a_tien(b_lp1);
        end if;
    end loop;
end loop;
end;
/
create or replace function FCN_TK_MA
    (b_ma_dvi varchar2,b_ngay number,b_ma_tk varchar2) return varchar2
AS
    b_kq varchar2(10); b_i1 number;
begin
-- Dan - Tra ma theo tai khoan
select nvl(max(ngay),0) into b_i1 from cn_tk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
select nvl(min(ma),' ') into b_kq from cn_tk where ma_dvi=b_ma_dvi and ngay=b_i1 and instr(b_ma_tk,ma_tk)=1;
return b_kq;
end;
/
create or replace function FCN_TK_PS
    (b_ma_dvi varchar2,b_ngay number,b_ma_tk varchar2) return varchar2
AS
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra loai theo tai khoan
select nvl(max(ngay),0) into b_i1 from cn_tk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
select nvl(min(loai),'N') into b_kq from cn_tk where ma_dvi=b_ma_dvi and ngay=b_i1 and ma_tk=b_ma_tk;
return b_kq;
end;
/
create or replace procedure PCN_CT_TON_XLY
    (b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,b_l_ct varchar2,b_ma_cn varchar2,
    b_ma_nt varchar2,b_ma_tk varchar2,b_viec varchar2,b_hdong varchar2,b_ma_ctr varchar2,b_tien number,b_tien_qd number,
    a_so_id out pht_type.a_num,a_bt out pht_type.a_num,a_tra out pht_type.a_num,
    a_tra_qd out pht_type.a_num,a_phi out pht_type.a_num,a_phi_qd out pht_type.a_num,b_loi out varchar2)
AS
    b_bt number:=0; b_tien_c number:=b_tien; b_tien_qd_c number:=b_tien_qd; b_tp number; b_tl number;
begin
-- Dan -- Tinh thanh toan
delete cn_ton_temp;
FCN_CT_TON(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_ma_cn,b_ma_nt,b_ma_tk,b_viec,b_hdong,b_ma_ctr,b_loi);
if b_loi is not null then return; end if;
PKH_MANG_KD_N(a_so_id);
for r_lp in (select * from cn_ton_temp order by ngay_ht,so_id_ps) loop
    if r_lp.tien<b_tien_c and r_lp.tien_qd<b_tien_qd_c then
        b_tien_c:=b_tien_c-r_lp.tien; b_tien_qd_c:=b_tien_c-r_lp.tien_qd;
    elsif (r_lp.tien=b_tien_c and r_lp.tien_qd=b_tien_qd_c) or (r_lp.tien>b_tien_c and r_lp.tien_qd>b_tien_qd_c) then
        b_tien_c:=0; b_tien_qd_c:=0;
    end if;
    if b_tien_c=0 and b_tien_qd_c=0 then exit; end if;
end loop;
if b_tien_c=0 and b_tien_qd_c=0 then
    if b_ma_nt<>'VND' then b_tp:=2; else b_tp:=0; end if;
    b_tien_c:=b_tien; b_tien_qd_c:=b_tien_qd;
    for r_lp in (select * from cn_ton_temp order by ngay_ht,so_id_ps) loop
        if (r_lp.tien<b_tien_c and r_lp.tien_qd<b_tien_qd_c) or
            (r_lp.tien=b_tien_c and r_lp.tien_qd=b_tien_qd_c) or
            (r_lp.tien>b_tien_c and r_lp.tien_qd>b_tien_qd_c)then
            b_bt:=b_bt+1;
            a_so_id(b_bt):=r_lp.so_id_ps; a_bt(b_bt):=r_lp.bt_ps;           
            if r_lp.tien<=b_tien_c then 
                a_tra(b_bt):=r_lp.tien;a_tra_qd(b_bt):=r_lp.tien_qd;
                a_phi(b_bt):=r_lp.phi; a_phi_qd(b_bt):=r_lp.phi_qd;
            else
                b_tl:=b_tien_c/r_lp.tien;
                a_tra(b_bt):=round(r_lp.tien*b_tl,b_tp); a_tra_qd(b_bt):=round(r_lp.tien_qd*b_tl,0);
                a_phi(b_bt):=round(r_lp.phi*b_tl,b_tp); a_phi_qd(b_bt):=round(r_lp.phi_qd*b_tl,0);      
            end if;
            b_tien_c:=b_tien_c-r_lp.tien; b_tien_qd_c:=b_tien_c-r_lp.tien_qd;
        end if;
        if b_tien_c<=0 or b_tien_qd_c<=0 then exit; end if;
    end loop;
end if;
end;
/
create or replace procedure FCN_CT_TON
    (b_ma_dvi varchar2,b_so_id number,b_ngay_ht number,b_l_ct_n varchar2,b_ma_cn varchar2,
    b_ma_nt varchar2,b_ma_tk varchar2,b_viec varchar2,b_hdong varchar2,b_ma_ctr varchar2,b_loi out varchar2)
as
    b_i1 number; b_i2 number; b_c1 varchar2(1); b_bt number; b_loai varchar2(1);
    b_l_ct varchar2(1); b_tra number; b_tra_qd number;
    b_ma_cn_c varchar2(21); b_ma_nt_c varchar2(5); b_ma_tk_c varchar2(20); b_viec_c varchar2(20); b_hdong_c varchar2(20); b_ma_ctr_c varchar2(21);
begin
-- dan - tinh cong no ton
b_loai:=substr(b_l_ct_n,1,1); b_l_ct:=substr(b_l_ct_n,2,1);
if substr(b_l_ct_n,1,1)<>'p' then b_loai:='p'; else b_loai:='t'; end if;
insert into cn_ton_temp select so_id,bt,ngay_ht,'',tien-tra,tien_qd-tra_qd,0,0,'' from (
    select so_id,bt,ngay_ht,tien,tra,tien_qd,tra_qd,viec,hdong,ma_ctr from cn_ps where
    ma_dvi=b_ma_dvi and ngay_ht<=b_ngay_ht and tien-tra<>0 and l_ct=b_l_ct and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk)
    where fcn_ct_loai(b_ma_dvi,so_id,bt)=b_loai and b_viec in('*',viec) and b_hdong in('*',hdong) and b_ma_ctr in(ma_ctr,'*');
if b_so_id<>0 then
    delete cn_ton_temp where so_id_ps=b_so_id;
    select nvl(min(htoan),'t') into b_c1 from cn_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_c1='h' then
        b_bt:=0;
        for r_lp in(select * from cn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            if fcn_ct_loai(b_ma_dvi,r_lp.so_id_ps,r_lp.bt_ps)=b_loai then
                if b_bt<>r_lp.bt_tt then
                    b_bt:=r_lp.bt_tt;
                    select ma_cn,ma_nt,ma_tk,viec,hdong,ma_ctr into b_ma_cn_c,b_ma_nt_c,b_ma_tk_c,b_viec_c,b_hdong_c,b_ma_ctr_c
                        from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
                end if;
                if b_ma_cn=b_ma_cn_c and b_ma_nt=b_ma_nt_c and b_ma_tk=b_ma_tk_c and b_viec in('*',b_viec_c)
                    and b_hdong in('*',b_hdong_c) and b_ma_ctr in(b_ma_ctr_c,'*') then
                    b_i1:=r_lp.so_id_ps; b_i2:=r_lp.bt_ps;
                    if r_lp.loai<>'d' then
                        b_tra:=r_lp.tien; b_tra_qd:=r_lp.tien_qd;
                    else
                        b_tra:=-r_lp.tien; b_tra_qd:=-r_lp.tien_qd;
                    end if;
                    update cn_ton_temp set tien=tien+b_tra,tien_qd=tien_qd+b_tra_qd where so_id_ps=b_i1 and bt_ps=b_i2;
                    if sql%rowcount=0 then
                        insert into cn_ton_temp select so_id,bt,ngay_ht,'',b_tra,b_tra_qd,0,0,nd
                            from cn_ps where ma_dvi=b_ma_dvi and so_id=b_i1 and bt=b_i2;
                    end if;
                end if;
            end if;
        end loop;
    end if;
end if;
delete cn_ton_temp where tien=0;
update cn_ton_temp set (so_ct,nd)=(select so_ct,nd from cn_ch where ma_dvi=b_ma_dvi and so_id=so_id_ps);
if b_loai='t' then
    for r_lp in (select so_id_ps,bt_ps,tien from cn_ton_temp) loop
        b_i1:=r_lp.so_id_ps; b_i2:=r_lp.bt_ps;
        pcn_tinh_ls(b_ma_dvi,b_i1,b_i2,b_ngay_ht,r_lp.tien,b_tra,b_tra_qd,b_loi);
        if b_loi is not null then return; end if;
        update cn_ton_temp set phi=b_tra,phi_qd=b_tra_qd where so_id_ps=b_i1 and bt_ps=b_i2;
    end loop;
end if;
b_loi:='';
end;
/
create or replace function FCN_CT_LOAI
    (b_ma_dvi varchar2,b_so_id number,b_bt number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Tra loai
select nvl(min(loai),' ') into b_kq from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
return b_kq;
end;
/
create or replace procedure PCN_TINH_LS
    (b_ma_dvi varchar2,b_so_id number,b_bt number,b_ngay_ht number,b_tien number,b_phi out number,b_phi_qd out number,b_loi out varchar2)
AS
    b_ma_nt varchar2(5); b_noite varchar2(5); b_tp number:=0; b_tg number:=1;
    b_ngay number; b_khoang number; b_ls number; b_han number; b_ppt varchar2(1);
begin
-- Dan - Tinh lai cong no
b_phi:=0; b_phi_qd:=0; b_loi:='';
select nvl(max(ngay),0) into b_ngay from cn_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt and ngay<=b_ngay_ht;
if b_ngay=0 then return; end if;
select ls,ppt into b_ls,b_ppt from cn_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt and ngay=b_ngay;
if b_ls=0 then return; end if;
select ma_nt into b_ma_nt from cn_ps where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt;
b_noite:=FTT_TRA_NOITE(b_ma_dvi);
if b_ma_nt<>b_noite then b_tp:=2; b_tg:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_ht,b_ma_nt); end if;
if b_ls<0 then
    b_phi:=round(b_tien*b_ls/100,b_tp);
else
    b_han:=PCN_NGAY_HAN(b_ma_dvi,b_so_id,b_bt);
    if b_han=0 then return; end if;
    if b_ppt='D' then
        b_khoang:=PKH_SO_CDT(b_ngay_ht)-PKH_SO_CDT(b_han);
    elsif b_ppt='M' then
        b_khoang:=MONTHS_BETWEEN(PKH_SO_CDT(round(b_han,-2)+1),PKH_SO_CDT(round(b_ngay_ht,-2)+1));
    else
        b_khoang:=(round(b_ngay_ht,-4)-round(b_han,-4))/10000;
    end if;
    if b_khoang>0 then b_phi:=round(b_tien*b_ls*b_khoang/100,b_tp); end if;
end if;
b_phi_qd:=round(b_phi*b_tg,0);
end;
/
create or replace function PCN_NGAY_HAN(b_ma_dvi varchar2,b_so_id number,b_bt number) return number
AS
    b_ngay number;
begin
-- Dan - Tim ngay phai tra 
select nvl(min(ngay),0) into b_ngay from cn_ls where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_bt and ls>0;
return b_ngay;
end;
/
create or replace procedure PCN_CT_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_md varchar2,b_htoan varchar2,b_ngay_ht number,
    a_l_cn pht_type.a_var,a_l_ct in out pht_type.a_var,a_ma_cn pht_type.a_var,a_ma_nt pht_type.a_var,
    a_ma_tk out pht_type.a_var,a_viec pht_type.a_var,a_hdong pht_type.a_var,
    a_ma_ctr pht_type.a_var,a_tien pht_type.a_num,a_ty_gia pht_type.a_num,a_tien_qd pht_type.a_num,a_bt_ps pht_type.a_num,
    a_ls_bt pht_type.a_num,a_ls_ppt pht_type.a_var,a_ls_ngay pht_type.a_num,a_ls_tien pht_type.a_num,a_ls_ls pht_type.a_num,
    a_bt_tt pht_type.a_num,a_so_id pht_type.a_num,a_bt pht_type.a_num,a_tra pht_type.a_num,a_tra_qd pht_type.a_num,
    a_phi pht_type.a_num,a_phi_qd pht_type.a_num,a_loai in out pht_type.a_var,b_loi out varchar2)
AS
    b_c1 varchar2(1); b_c10 varchar2(20); b_c20 varchar2(20); b_i1 number; b_i2 number;
    b_idvung number:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd); b_tt varchar2(1); b_noite varchar2(5); r_cn cn_ps%rowtype; r_ct cn_ct%rowtype;
begin
-- Dan - Kiem tra so lieu nhap cong no da qui doi phat sinh
if b_htoan is null or b_htoan not in ('H','T') or b_ngay_ht is null or a_l_ct.count=0 then
    --b_loi:='loi:So lieu nhap sai:loi'; return;
    b_loi:='loi:So lieu nhap sai:'||b_htoan||' '||to_char(b_ngay_ht)||' '||to_char(a_l_ct.count); return;
end if;
b_noite:=FTT_TRA_NOITE(b_ma_dvi); b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
for b_lp in 1..a_l_ct.count loop
    a_loai(b_lp):=a_l_ct(b_lp);
end loop;
for b_lp in 1..a_l_ct.count loop
    if a_ma_cn(b_lp) is null or length(a_ma_cn(b_lp))<2 or a_l_cn(b_lp) is null or
        a_l_ct(b_lp) is null or a_l_ct(b_lp) not in ('P','T','D') or a_bt_ps(b_lp) is null then
        b_loi:='loi:Nhap ma cong no dong chi tiet dong '||to_char(b_lp)||':loi'; return;
    end if;
    a_l_ct(b_lp):=FCN_TK_LOAI(b_ma_dvi,b_ngay_ht,a_l_cn(b_lp));
    a_ma_tk(b_lp):=FCN_TK_TK(b_ma_dvi,b_ngay_ht,a_l_cn(b_lp));
    b_loi:='loi:Ma#'||trim(a_ma_cn(b_lp))||'#cong no dong#'||to_char(b_lp)||'#chua dang ky:loi';
    b_c1:=substr(a_ma_cn(b_lp),1,1); b_c20:=substr(a_ma_cn(b_lp),2);
    if b_c1 in('K','U') then
        select 0 into b_i1 from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_c20;
    elsif b_c1='D' then
        select 0 into b_i1 from cn_ma_dl where ma_dvi=b_ma_dvi and ma=b_c20;
    elsif b_c1='C' then
        select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_c20;
    elsif b_c1='B' then
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_c20;
    elsif b_c1='N' then
        select 0 into b_i1 from ht_ma_dvi where idvung=b_idvung and ma_goc=b_c20;
    else
        b_loi:='loi:Sai loai ma cong no:loi'; return;
    end if;
    b_loi:='loi:Sai tien cong no#'||trim(a_ma_cn(b_lp))||':loi';
    if a_tien(b_lp) is null or a_tien_qd(b_lp) is null or a_ty_gia(b_lp) is null or
        a_tien_qd(b_lp)=0 or (sign(a_tien_qd(b_lp))<>sign(a_tien(b_lp)) and a_tien(b_lp)<>0) or
        a_tien_qd(b_lp)<>round(a_tien_qd(b_lp),0) then return;
    end if;
    if a_ma_nt(b_lp)<> b_noite then
        b_loi:='loi:Ma ngoai te#'||trim(a_ma_nt(b_lp))||'#chua dang ky:loi';
        select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=a_ma_nt(b_lp);
    elsif a_tien(b_lp)<>a_tien_qd(b_lp) or a_ty_gia(b_lp)<>1 then return;
    end if;
    b_loi:='loi:Sai ma viec:loi';
    if a_viec(b_lp) is null then return; end if;
    if trim(a_viec(b_lp)) is not null then
        select ttrang into b_c1 from kh_ma_viec where ma_dvi=b_ma_dvi and ma=a_viec(b_lp);
        if b_c1<>'D' then return; end if;
    end if;
    b_loi:='loi:Sai hop dong:loi';
    if a_hdong(b_lp) is null then return; end if;
    if trim(a_hdong(b_lp)) is not null then
        select ttrang into b_c1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=a_hdong(b_lp);
        if b_c1<>'D' then return; end if;
    end if;
    if FKH_VIEC_HDONG(b_ma_dvi,a_viec(b_lp),a_hdong(b_lp))<>'C' then
        b_loi:='loi:Ma viec '||a_viec(b_lp)||' va ma hop dong '||a_hdong(b_lp)||' khong dong bo:loi'; return;
    end if;
    if a_ma_ctr(b_lp) is null then
        b_loi:='loi:Nhap ma cong trinh:loi'; return;
    elsif a_ma_ctr(b_lp)<>' ' then
        b_loi:='loi:Ma#'||trim(a_ma_ctr(b_lp))||'#chua dang ky:loi';
        b_c1:=substr(a_ma_ctr(b_lp),1,1); b_c20:=substr(a_ma_ctr(b_lp),2);
        if b_c1='L' then
            select 0 into b_i1 from xl_ma_ctr where ma_dvi=b_ma_dvi and ma=b_c20;
        elsif b_c1='X' then
            select 0 into b_i1 from xd_ma_ctr where ma_dvi=b_ma_dvi and ma=b_c20;
        elsif b_c1='T' then
            select 0 into b_i1 from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_c20;
        end if;
    end if;
end loop;
b_loi:='loi:Sai so lieu lai suat:loi';
for b_lp in 1..a_ls_bt.count loop
    if a_ls_bt(b_lp) is null or a_ls_ppt(b_lp) is null or a_ls_ngay(b_lp) is null or
        a_ls_tien(b_lp) is null or a_ls_ls(b_lp) is null then return; end if;
    b_i1:=0;
    for b_lp1 in 1..a_l_ct.count loop
        if a_ls_bt(b_lp)=a_bt_ps(b_lp1) then
            if a_loai(b_lp1)<>'P' then return; else b_i1:=1; end if;
        end if;
    end loop;
    if b_i1=0 then return; end if;
end loop;
for b_lp in 1..a_bt_tt.count loop
    b_loi:='loi:Mat dong bo so lieu nhap dong #'||to_char(b_lp)||':loi';
    if a_so_id(b_lp) is null or a_bt(b_lp) is null or a_so_id(b_lp)=b_so_id or
        a_tra(b_lp) is null or a_tra_qd(b_lp) is null or a_tra_qd(b_lp)=0 or
        (a_tra(b_lp)<>0 and sign(a_tra(b_lp))<>sign(a_tra_qd(b_lp))) or
        a_phi(b_lp) is null or a_phi_qd(b_lp) is null or sign(a_phi(b_lp))<>sign(a_phi_qd(b_lp)) then return;
    end if;
    b_i1:=0;
    for b_lp1 in 1..a_l_ct.count loop
        if a_bt_ps(b_lp1)=a_bt_tt(b_lp) then b_i1:=b_lp1; exit; end if;
    end loop;
    select * into r_cn from cn_ps where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and bt=a_bt(b_lp) for update nowait;
    if sql%rowcount=0 then return; end if;
    if r_cn.ngay_ht>b_ngay_ht or a_ma_cn(b_i1)<>r_cn.ma_cn or a_ma_nt(b_i1)<>r_cn.ma_nt or a_ma_tk(b_i1)<>r_cn.ma_tk
        or a_l_ct(b_i1)<>r_cn.l_ct or a_viec(b_i1)<>r_cn.viec or a_hdong(b_i1)<>r_cn.hdong or a_ma_ctr(b_i1)<>r_cn.ma_ctr then return;
    end if;
    if a_ma_nt(b_i1)=b_noite and (a_tra(b_lp)<>a_tra_qd(b_lp) or a_phi(b_lp)<>a_phi_qd(b_lp)) then return; end if;
end loop;
for b_lp in 1..a_l_ct.count loop
    b_i1:=a_tien(b_lp); b_i2:=a_tien_qd(b_lp);
    for b_lp1 in 1..a_bt_tt.count loop
        if a_bt_tt(b_lp1)=a_bt_ps(b_lp) then
            b_i1:=b_i1-a_tra(b_lp1); b_i2:=b_i2-a_tra_qd(b_lp1);
        end if;
    end loop;
    if b_i1<0 or sign(b_i1)<>sign(b_i2) or (b_i1<>0 and a_loai(b_lp)='D') then
        b_loi:='loi:Mat dong bo so lieu dau nhap dong#'||to_char(b_lp)||':loi'; return;
    end if;
end loop;
if b_so_id<>0 then
    for r_lp in (select so_id,loai,l_ct,bt_ps from cn_tt where ma_dvi=b_ma_dvi and so_id_ps=b_so_id) loop
        b_i1:=0;
        for b_lp in 1..a_l_ct.count loop
            if a_bt_ps(b_lp)=r_lp.bt_ps and a_loai(b_lp) not in('D',r_lp.loai) and a_l_ct(b_lp)=r_lp.l_ct then b_i1:=1; exit; end if;
        end loop;
        if b_i1=0 then
            select htoan into b_c1 from cn_ch where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
            if b_c1='H' then b_loi:='loi:Chung tu da co thanh toan:loi'; return; end if;
        end if;
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FCN_TK_LOAI
    (b_ma_dvi varchar2,b_ngay number,b_l_cn varchar2) return varchar2
AS
    b_kq varchar2(1); b_i1 number;
begin
-- Dan - Tra loai theo ma
select nvl(max(ngay),0) into b_i1 from cn_tk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
select nvl(min(loai),'N') into b_kq from cn_tk where ma_dvi=b_ma_dvi and ngay=b_i1 and ma=b_l_cn;
return b_kq;
end;
/
create or replace function FCN_TK_TK
    (b_ma_dvi varchar2,b_ngay number,b_l_cn varchar2) return varchar2
AS
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Tra tai khoan theo ma
select nvl(max(ngay),0) into b_i1 from cn_tk where ma_dvi=b_ma_dvi and ngay<=b_ngay;
select nvl(min(ma_tk),' ') into b_kq from cn_tk where ma_dvi=b_ma_dvi and ngay=b_i1 and ma=b_l_cn;
return b_kq;
end;
/
create or replace function FKH_VIEC_HDONG
    (b_ma_dvi varchar2,b_viec varchar2,b_hdong varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; b_i1 number;
begin
-- Dan - Tra quan he viec va hdong
if trim(b_viec) is not null and trim(b_hdong) is not null then
    select count(*) into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and viec=b_viec;
    if b_i1=0 then
        select count(*) into b_i1 from kh_ma_viec where ma_dvi=b_ma_dvi and hdong=b_hdong;
        if b_i1=0 then b_kq:='K'; end if;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PCN_CN_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_htoan varchar2,
    b_ngay_ht number,b_so_id number,b_so_ct in out varchar2,b_ngay_ct varchar2,b_nhom varchar2,
    b_loai varchar2,b_pp varchar2,b_t_suat number,b_thue number,b_mau varchar2,b_seri varchar2,b_so_hd varchar2,b_nd nvarchar2,b_ndp nvarchar2,
    a_l_ct pht_type.a_var,a_loai pht_type.a_var,a_ma_cn pht_type.a_var,a_ma_nt pht_type.a_var,
    a_ma_tk pht_type.a_var,a_viec pht_type.a_var,a_hdong pht_type.a_var,a_ma_ctr pht_type.a_var,a_ct_th pht_type.a_nvar,
    a_tien pht_type.a_num,a_ty_gia pht_type.a_num,a_tien_qd pht_type.a_num,a_han pht_type.a_num,a_bt_ps pht_type.a_num,
    a_ls_bt pht_type.a_num,a_ls_ppt pht_type.a_var,a_ls_ngay pht_type.a_num,a_ls_tien pht_type.a_num,a_ls_ls pht_type.a_num,
    a_bt_tt pht_type.a_num,a_so_id pht_type.a_num,a_bt pht_type.a_num,a_tra pht_type.a_num,
    a_tra_qd pht_type.a_num,a_phi pht_type.a_num,a_phi_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; b_sua number; b_sua_qd number; b_tra number; b_tra_qd number; b_htoan_tt varchar2(1);
begin
-- Dan - Nhap cong no
if trim(b_so_ct) is null then
    b_so_ct:=FCN_SOTT(b_ma_dvi,b_ngay_ht);
end if;
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST_NSD(b_ma_dvi,b_ngay_ht,'KT','CN',b_nsd);
    if b_loi is not null then return; end if;
end if;
b_i1:=0;
for b_lp in 1..a_l_ct.count loop
    b_i1:=b_i1+a_tien(b_lp);
end loop;
b_loi:='loi:Loi Table CN_CH:loi';
insert into cn_ch values(b_ma_dvi,b_so_id,b_ngay_ht,substr(b_so_ct,1,20),b_ngay_ct,b_nhom,b_i1,b_loai,
    b_pp,b_t_suat,b_thue,b_mau,b_seri,b_so_hd,b_nd,b_ndp,b_nsd,b_htoan,b_md,sysdate,b_idvung);
b_loi:='loi:Loi Table CN_CT:loi';
for b_lp in 1..a_bt_ps.count loop
    insert into cn_ct values(b_ma_dvi,b_so_id,a_bt_ps(b_lp),b_ngay_ht,a_l_ct(b_lp),a_loai(b_lp),a_ma_cn(b_lp),
        a_ma_nt(b_lp),a_ma_tk(b_lp),a_viec(b_lp),a_hdong(b_lp),a_ma_ctr(b_lp),a_ct_th(b_lp),a_tien(b_lp),a_ty_gia(b_lp),a_tien_qd(b_lp),a_han(b_lp),b_idvung);
end loop;
b_loi:='loi:Loi Table CN_LS:loi';
for b_lp in 1..a_ls_bt.count loop
    insert into cn_ls values(b_ma_dvi,b_so_id,a_ls_bt(b_lp),a_ls_ppt(b_lp),a_ls_ngay(b_lp),a_ls_tien(b_lp),a_ls_ls(b_lp),b_idvung);
end loop;
b_loi:='loi:Loi Table CN_TT:loi';
for b_lp in 1..a_bt_tt.count loop
    b_i1:=0;
    for b_lp1 in 1..a_l_ct.count loop
        if a_bt_tt(b_lp)=a_bt_ps(b_lp1) then b_i1:=b_lp1; exit; end if;
    end loop;
    insert into cn_tt values(b_ma_dvi,b_so_id,b_lp,a_bt_ps(b_i1),a_l_ct(b_i1),a_loai(b_i1),
        a_so_id(b_lp),a_bt(b_lp),a_tra(b_lp),a_tra_qd(b_lp),a_phi(b_lp),a_phi_qd(b_lp),b_ngay_ht,b_idvung);
end loop;
if b_htoan<>'H' then b_loi:=''; return; end if;
b_loi:='loi:Loi Update Table CN_PS:loi';
for b_lp in 1..a_bt_tt.count loop
    b_i1:=0;
    for b_lp1 in 1..a_l_ct.count loop
        if a_bt_tt(b_lp)=a_bt_ps(b_lp1) then b_i1:=b_lp1; exit; end if;
    end loop;
    if a_loai(b_i1)='D' then
        update cn_ps set tien=tien+a_tra(b_lp),tien_qd=tien_qd+a_tra_qd(b_lp) where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
    else
        update cn_ps set tra=tra+a_tra(b_lp),tra_qd=tra_qd+a_tra_qd(b_lp) where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp) and bt=a_bt(b_lp);
    end if;
end loop;
b_loi:='loi:Loi Table CN_PS:loi';
for b_lp in 1..a_l_ct.count loop
    if a_loai(b_lp)<>'D' then
        b_sua:=a_tien(b_lp); b_sua_qd:=a_tien_qd(b_lp); b_tra:=0; b_tra_qd:=0;
        for b_lp1 in 1..a_bt_tt.count loop
            if a_bt_tt(b_lp1)=a_bt_ps(b_lp) then
                b_sua:=b_sua-a_tra(b_lp1); b_sua_qd:=b_sua_qd-a_tra_qd(b_lp1);
            end if;
        end loop;
        for r_lp in (select distinct so_id from cn_tt where ma_dvi=b_ma_dvi and so_id_ps=b_so_id and bt_ps=a_bt_ps(b_lp)) loop
            select htoan into b_htoan_tt from cn_ch where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
            if b_htoan_tt='H' then
                for r_lp1 in (select loai,tien,tien_qd from cn_tt where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and so_id_ps=b_so_id and bt_ps=a_bt_ps(b_lp)) loop
                    if r_lp1.loai='D' then
                        b_sua:=b_sua+r_lp1.tien; b_sua_qd:=b_sua_qd+r_lp1.tien_qd;
                    else
                        b_tra:=b_tra+r_lp1.tien; b_tra_qd:=b_tra_qd+r_lp1.tien_qd;
                    end if;
                end loop;
            end if;
        end loop;
        if b_sua<>b_tra then
            insert into cn_ps values(b_ma_dvi,b_so_id,a_bt_ps(b_lp),a_ct_th(b_lp),a_l_ct(b_lp),a_ma_cn(b_lp),a_ma_nt(b_lp),
                a_ma_tk(b_lp),a_viec(b_lp),a_hdong(b_lp),a_ma_ctr(b_lp),b_sua,b_tra,b_sua_qd,b_tra_qd,b_ngay_ht,b_idvung);
        end if;
    end if;
end loop;
PKH_NGAY_TD(b_ma_dvi,'CN',b_ngay_ht,b_loi);
if b_loi is not null then return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FCN_SOTT(b_ma_dvi varchar2,b_ngay_ht number) return varchar2
AS
    b_d1 number; b_d2 number; b_i1 number;
begin
-- Dan - Cho so thu tu tiep theo cua CT cong no
b_d1:=trunc(b_ngay_ht,-2); b_d2:=b_d1+100;
select nvl(max(PKH_LOC_CHU_SO(so_ct,'F','F')),0) into b_i1 from (select so_ct,md from cn_ch where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2) where md='CN';
return to_char(b_i1+1);
end;
/
create or replace function PKH_MA_HAN_TEST_NSD
    (b_ma_dvi varchar2,b_ngay number,b_md varchar2,b_nv_n varchar2,b_ma_nsd varchar2) return varchar2
as
    b_loi varchar2(200); b_d1 number; b_n1 number; b_ma_ct varchar2(10);b_i1 number;b_n1_nsd number;b_nv varchar2(10):=b_nv_n;
begin
/*
    Thay dan vao cac procedure NH, XOA

    select PKH_MA_HAN_TEST_NSD('032',20210406,'BH','KT_NG','ADMIN') from dual;

*/
-- Chuyen nghiep vu suc khoe thanh CON NGUOI
if b_nv in ('KT_SK','KT_SKL') then b_nv:='KT_NG'; end if;
if b_ngay is null then return 'loi:Nhap ngay xu ly nghiep vu '||b_nv||':loi'; end if;
-- han NSLD
select nvl(min(ma_ct),' ') into b_ma_ct from ht_ma_dvi where ma=b_ma_dvi;
select max(ngay) into b_d1 from kh_ma_han
    where ma_dvi=b_ma_dvi and md=b_md and ma_cd in(b_ma_dvi,b_ma_ct) and nv in(b_nv,'AL') and trim(ma_nsd) is null;
if b_d1 is null then return ''; end if;
b_n1:=b_d1;
if b_n1<b_ngay then return ''; end if;
--if b_n1>=b_ngay then return 'loi:Han thay doi '||b_ma_dvi||' '||b_nv||' ngay '||to_char(b_d1,'dd/mm/yyyy')||' b_ngay '||b_ngay||' b_n1 '||b_n1||':loi'; end if;
select count(*) into b_i1 from kh_ma_han where ma_dvi=b_ma_dvi and ma_nsd=b_ma_nsd
    and md=b_md and ma_cd in(b_ma_dvi,b_ma_ct) and (nv in(substr(b_nv,1,2),'AL') or nv in(b_nv,'AL'));
if b_i1=0 then
    if b_n1>=b_ngay then return 'loi:1Han ma_dvi:'||b_ma_dvi||' nsd: '||b_ma_nsd||' md:'||b_md||' nv:'||b_nv||' ngay han: '||to_char(b_d1,'dd/mm/yyyy')||' b_ngay: '||b_ngay||':loi'; end if;
else
    select max(ngay) into b_d1 from kh_ma_han where ma_dvi=b_ma_dvi and ma_nsd=b_ma_nsd
        and md=b_md and ma_cd in(b_ma_dvi,b_ma_ct) and (nv in(substr(b_nv,1,2),'AL') or nv in(b_nv,'AL'));
    b_n1_nsd:=b_d1;
    --if b_n1_nsd >= b_ngay then return 'loi:2Han thay doi '||b_ma_dvi||' nsd '||b_ma_nsd||' '||b_nv||' ngay '||to_char(b_d1,'dd/mm/yyyy')||' b_ngay '||b_ngay||' b_n1 '||b_n1||':loi'; end if;
    if b_md='KT' then
        if b_n1_nsd <> b_ngay then return 'loi:2Han ma_dvi:'||b_ma_dvi||' nsd: '||b_ma_nsd||' md:'||b_md||' nv:'||b_nv||' ngay han: '||to_char(b_d1,'dd/mm/yyyy')||' b_ngay '||b_ngay||':loi'; end if;
    else
        if b_n1_nsd >= b_ngay then return 'loi:3Han ma_dvi:'||b_ma_dvi||' nsd: '||b_ma_nsd||' md:'||b_md||' nv:'||b_nv||' ngay han: '||to_char(b_d1,'dd/mm/yyyy')||' b_ngay '||b_ngay||':loi'; end if;
    end if;
end if;
return '';
exception when others then if b_loi is null then raise program_error; else null; end if;
end;
/
create or replace procedure PCN_THOP_CT(b_ma_dvi varchar2,b_nv varchar2,b_so_id number,b_loi out varchar2)
AS
    b_tien number; b_tien_qd number; b_l_ct varchar2(1); b_so_id_ps number; b_bt_ps number; b_loai varchar2(1);
begin
-- Dan - Tong hop so cai cong no
for r_lp in (select * from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt) loop
    b_l_ct:=r_lp.l_ct;
    if r_lp.loai='T' then
        b_l_ct:='C';
    elsif r_lp.loai='D' then
        select so_id_ps,bt_ps into b_so_id_ps,b_bt_ps from cn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=r_lp.bt;
        select loai into b_loai from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id_ps and bt=b_bt_ps;
        if b_loai='T' then b_l_ct:='C'; end if;
    end if;
    if b_nv='N' then
        b_tien:=r_lp.tien; b_tien_qd:=r_lp.tien_qd;
    else
        b_tien:=-r_lp.tien; b_tien_qd:=-r_lp.tien_qd;
    end if;
    PCN_THOP_SCAI(r_lp.idvung,b_ma_dvi,r_lp.ngay_ht,b_l_ct,r_lp.ma_cn,r_lp.ma_nt,r_lp.ma_tk,b_tien,b_tien_qd,b_loi);
    if b_loi is not null then return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PCN_THOP_SCAI
    (b_idvung number,b_ma_dvi varchar2,b_ngay_ht number,b_nv varchar2,b_ma_cn varchar2,
    b_ma_nt varchar2,b_ma_tk varchar2,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_i1 number; b_no_ps number; b_co_ps number; b_no_ck number; b_co_ck number;
    b_no_ps_qd number; b_co_ps_qd number; b_no_ck_qd number; b_co_ck_qd number;
begin
b_loi:='loi:Loi Table SC_CN:loi';
if b_nv='N' then b_no_ps:=b_tien; b_co_ps:=0; b_no_ps_qd:=b_tien_qd; b_co_ps_qd:=0;
else b_no_ps:=0; b_co_ps:=b_tien; b_no_ps_qd:=0; b_co_ps_qd:=b_tien_qd;
end if;
select nvl(max(ngay_ht),-1) into b_i1 from cn_sc where
    ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht<b_ngay_ht;
if b_i1<0 then b_no_ck:=0; b_co_ck:=0; b_no_ck_qd:=0; b_co_ck_qd:=0;
else select no_ck,co_ck,no_ck_qd,co_ck_qd into b_no_ck,b_co_ck,b_no_ck_qd,b_co_ck_qd from cn_sc where
    ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht=b_i1;
end if;
select count(*) into b_i1 from cn_sc where ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht=b_ngay_ht;

b_loi:='loi:Loi Table SC_CN '||TO_CHAR(b_i1)||'--'||nvl(b_ma_tk,'ZZZ')||' 1:loi';
if b_i1=0 then
    insert into cn_sc values(b_ma_dvi,b_ma_cn,b_ma_nt,b_ma_tk,b_no_ps,b_co_ps,0,0,b_no_ps_qd,b_co_ps_qd,0,0,b_ngay_ht,b_idvung);
else
    update cn_sc set no_ps=no_ps+b_no_ps,co_ps=co_ps+b_co_ps,no_ps_qd=no_ps_qd+b_no_ps_qd,co_ps_qd=co_ps_qd+b_co_ps_qd
        where ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht=b_ngay_ht;
end if;
b_loi:='loi:Sai so du qui doi:loi';
for b_rc in (select no_ps,co_ps,no_ps_qd,co_ps_qd,ngay_ht from cn_sc where
    ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    b_no_ck:=b_no_ck+b_rc.no_ps-b_rc.co_ps-b_co_ck; b_no_ck_qd:=b_no_ck_qd+b_rc.no_ps_qd-b_rc.co_ps_qd-b_co_ck_qd;
    b_i1:=b_rc.ngay_ht;
    --if FKH_NV_TSO(b_ma_dvi,'KT','CN','kieu')='S' and sign(b_no_ck)<>sign(b_no_ck_qd) then return; end if;
    if b_no_ck=0 and b_rc.no_ps=0 and b_rc.co_ps=0 and b_no_ck_qd=0 and b_rc.no_ps_qd=0 and b_rc.co_ps_qd=0 then
        delete cn_sc where ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht=b_i1;
    else
        if b_no_ck<0 then b_co_ck:=-b_no_ck; b_no_ck:=0; b_co_ck_qd:=-b_no_ck_qd; b_no_ck_qd:=0;
        else b_co_ck:=0; b_co_ck_qd:=0;
        end if;
        update cn_sc set no_ck=b_no_ck,co_ck=b_co_ck,no_ck_qd=b_no_ck_qd,co_ck_qd=b_co_ck_qd where
            ma_dvi=b_ma_dvi and ma_cn=b_ma_cn and ma_nt=b_ma_nt and ma_tk=b_ma_tk and ngay_ht=b_i1;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKT_KH_CBAO_TT(b_ma_dvi varchar2,b_ngay number) return varchar2
AS
    b_kq varchar2(100):=''; b_i1 number; b_n number; b_tien number:=0; b_ngM number;
begin
-- Dan - Tra canh bao tien
select nvl(max(ngay),0) into b_ngM from kt_kh_cbao_tt where ma_dvi=b_ma_dvi and ngay<=b_ngay;
if b_ngM>0 then
    for r_lp in (select ma_nt,ma_nh,ma_tk,max(ngay_ht) ngay_ht from tt_sc where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngM and b_ngay group by ma_nt,ma_nh,ma_tk) loop
        select count(*) into b_i1 from kt_kh_cbao_ttL where ma_dvi=b_ma_dvi and ngay=b_ngM and ma_nh=r_lp.ma_nh and ma_tk=r_lp.ma_tk;
        if b_i1=0 then
            select ton_qd into b_n from tt_sc where ma_dvi=b_ma_dvi and ma_nt=r_lp.ma_nt and
                ma_nh=r_lp.ma_nh and ma_tk=r_lp.ma_tk and ngay_ht=r_lp.ngay_ht;
            b_tien:=b_tien+b_n;
        end if;
    end loop;
    if b_tien<>0 then 
        select bao into b_i1 from kt_kh_cbao_tt where ma_dvi=b_ma_dvi and ngay=b_ngM;
        if b_tien>b_i1 then b_kq:='bao:So du tien vuot qua muc cho phep:bao'; end if;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PCD_CD_XOA_XOA
      (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,a_dviC pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_i1 number; b_nsd_c varchar2(10); b_ngay_ht number;
    b_htoan varchar2(1); b_l_ct varchar2(5); b_dvi varchar2(20); b_ngay_du number;
begin
-- Dan - Xoa
select count(*) into b_i1 from cd_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select nsd,htoan,ngay_ht,l_ct,dvi,ngay_du into b_nsd_c,b_htoan,b_ngay_ht,b_l_ct,b_dvi,b_ngay_du
    from cd_ch where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 or b_l_ct in('DT','DC','NT','NC') then return; end if;
if b_htoan='H' then
    if b_nsd<>b_nsd_c then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return;
    elsif b_ngay_du<>0 then b_loi:='loi:Khong sua, xoa chung tu don vi da hach toan:loi'; return;
    end if;
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','CD');
    if b_loi is not null then return; end if;
    if b_l_ct in ('PT','PC') then
        for r_lp in (select distinct dvi from cd_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            b_i1:=0;
            for b_lp in 1..a_dviC.count loop
                if r_lp.dvi=a_dviC(b_lp) then b_i1:=1; exit; end if;
            end loop;
            if b_i1=0 then
                PCD_CT_GOC_XOA(r_lp.dvi,b_so_id,b_loi);
                if b_loi is not null then return; end if;
            end if;
        end loop;
    else
        PCD_CT_GOC_XOA(b_dvi,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PKH_NGAY_TD(b_ma_dvi,'CD',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table CD_CT:loi';
delete cd_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table CD_CH:loi';
delete cd_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PCD_CT_GOC_XOA
      (b_ma_dvi varchar2,b_so_id_du number,b_loi out varchar2)
AS
    b_so_id number; b_htoan varchar2(1);
begin
-- Dan - Xoa don vi huong
select nvl(min(so_id),0) into b_so_id from cd_ch where ma_dvi=b_ma_dvi and so_id_du=b_so_id_du;
if b_so_id=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select htoan into b_htoan from cd_ch where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 then return;
elsif b_htoan<>'T' then b_loi:='loi:Don vi da hach toan:loi'; return;
end if;
b_loi:='loi:Loi xoa Table CD_CH cua don vi nhan:loi';
delete cd_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi xoa Table CD_CT cua don vi nhan:loi';
delete cd_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then rollback;
end;
/
create or replace procedure PCD_CD_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_md varchar2,b_ngay_ht number,b_htoan varchar2,
    b_l_ct varchar2,b_dvi varchar2,b_so_ct varchar2,b_ngay_ct varchar2,b_tien number,b_nd nvarchar2,
    a_dvi pht_type.a_var,a_ma_nt pht_type.a_var,a_tygia pht_type.a_num,a_tien pht_type.a_num,
    a_tien_qd pht_type.a_num,a_nd pht_type.a_nvar,a_dviC pht_type.a_var,b_loi out varchar2)
AS
    b_lenh varchar2(1000); b_l_ct_n varchar2(2);
    b_ch_dvi varchar2(2000); b_ch_ma_nt varchar2(2000); b_ch_tygia varchar2(2000);
    b_ch_tien varchar2(2000); b_ch_tien_qd varchar2(2000); b_ch_nd nvarchar2(4000);
    a_dvi_xl pht_type.a_var; b_log boolean; b_kt number;
begin
-- Dan - Nhap
b_loi:='loi:Loi Table CD_CH:loi';
insert into cd_ch values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_dvi,b_so_ct,b_ngay_ct,b_tien,b_nd,b_nsd,b_htoan,b_md,sysdate,0,0,'',b_idvung);
b_loi:='loi:Loi Table CD_CT:loi';
for b_lp in 1..a_ma_nt.count loop
    insert into cd_ct values(b_ma_dvi,b_so_id,b_lp,a_dvi(b_lp),a_ma_nt(b_lp),a_tygia(b_lp),a_tien(b_lp),a_tien_qd(b_lp),a_nd(b_lp),0,0,'',b_idvung);
end loop;
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','CD');
    if b_loi is not null then return; end if;
    b_ch_dvi:=FKH_ARR_CH(a_dvi); b_ch_ma_nt:=FKH_ARR_CH(a_ma_nt); b_ch_tygia:=FKH_ARR_CH_N(a_tygia);
    b_ch_tien:=FKH_ARR_CH_N(a_tien); b_ch_tien_qd:=FKH_ARR_CH_N(a_tien_qd); b_ch_nd:=FKH_ARR_CH_U(a_nd);
    if b_l_ct in ('PT','PC') then
        b_l_ct_n:='N'||substr(b_l_ct,2,1); a_dvi_xl(1):=a_dvi(1); b_kt:=1;
        for b_lp in 2..a_ma_nt.count loop
            b_log:=true;
            for b_lp1 in 1..b_kt loop
                if a_dvi_xl(b_lp1)=a_dvi(b_lp) then b_log:=false; exit; end if;
            end loop;
            if b_log then
                b_kt:=b_kt+1; a_dvi_xl(b_kt):=a_dvi(b_lp);
            end if;
        end loop;
        for b_lp in 1..b_kt loop
            b_log:=true;
            for b_lp1 in 1..a_dviC.count loop
                if a_dvi_xl(b_lp)=a_dviC(b_lp1) then b_log:=false; exit; end if;
            end loop;
            if b_log then
                PCD_CT_GOC_NH(b_idvung,a_dvi_xl(b_lp),b_ngay_ht,b_l_ct_n,b_ma_dvi,b_so_ct,b_ngay_ct,
                    b_tien,b_nd,a_dvi,a_ma_nt,a_tygia,a_tien,a_tien_qd,a_nd,b_so_id,b_loi);
                if b_loi is not null then return; end if;
            end if;
        end loop;
    else
        b_l_ct_n:='D'||substr(b_l_ct,1,1);
        PCD_CT_GOC_NH(b_idvung,b_dvi,b_ngay_ht,b_l_ct_n,b_ma_dvi,b_so_ct,b_ngay_ct,
            b_tien,b_nd,a_dvi,a_ma_nt,a_tygia,a_tien,a_tien_qd,a_nd,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PKH_NGAY_TD(b_ma_dvi,'CD',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PCD_CT_GOC_NH
    (b_idvung number,b_ma_dvi varchar2,b_ngay_ht number,b_l_ct varchar2,
    b_dvi varchar2,b_so_ct varchar2,b_ngay_ct varchar2,b_tien_n number,b_nd nvarchar2,
    a_dvi pht_type.a_var,a_ma_nt pht_type.a_var,a_tygia pht_type.a_num,a_tien pht_type.a_num,
    a_tien_qd pht_type.a_num,a_nd pht_type.a_nvar,b_so_id_du number,b_loi out varchar2)
AS
    b_so_id number; b_tien number:=0;
begin
-- Dan - Nhap vao don vi huong
select nvl(min(so_id),0) into b_so_id from cd_ch where ma_dvi=b_ma_dvi and so_id_du=b_so_id_du;
if b_so_id=0 then PHT_ID_MOI(b_so_id,b_loi);
else
    PCD_CT_GOC_XOA(b_ma_dvi,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi nhap Table CD_CH cua don vi nhan:loi';
if b_l_ct in ('NT','NC') then
    for b_lp in 1..a_ma_nt.count loop
        if a_dvi(b_lp)=b_ma_dvi then b_tien:=b_tien+a_tien_qd(b_lp); end if;
    end loop;
else b_tien:=b_tien_n;
end if;
insert into cd_ch values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_dvi,b_so_ct,b_ngay_ct,b_tien,b_nd,'','T','CD',sysdate,b_so_id_du,b_ngay_ht,'',b_idvung);
b_loi:='loi:Loi nhap Table CD_CT cua don vi nhan:loi';
if b_l_ct in ('NT','NC') then
    for b_lp in 1..a_ma_nt.count loop
        if a_dvi(b_lp)=b_ma_dvi then
            insert into cd_ct values(b_ma_dvi,b_so_id,b_lp,'',a_ma_nt(b_lp),a_tygia(b_lp),a_tien(b_lp),a_tien_qd(b_lp),a_nd(b_lp),0,0,'',b_idvung);
        end if;
    end loop;   
else
    for b_lp in 1..a_ma_nt.count loop
        insert into cd_ct values(b_ma_dvi,b_so_id,b_lp,'',a_ma_nt(b_lp),a_tygia(b_lp),a_tien(b_lp),a_tien_qd(b_lp),a_nd(b_lp),0,0,'',b_idvung);
    end loop;
end if;
b_loi:='';
exception when others then rollback;
end;
/
create or replace procedure PKT_CT_NV_XL
    (b_ma_dvi varchar2,b_nsd varchar2,b_htoan varchar2,b_ngay_ht number,b_so_id number,
    b_l_ct varchar2,b_so_ct in out varchar2,b_ngay_ct varchar2,b_nd nvarchar2,
    a_nv in out pht_type.a_var,a_ma_tk in out pht_type.a_var,
    a_ma_tke in out pht_type.a_var,a_tien in out pht_type.a_num,a_note pht_type.a_nvar,
    a_bt pht_type.a_num,b_md_n varchar2,b_md_x varchar2,b_lk out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_tt varchar2(1):='2'; b_htoan_xl varchar2(1):=b_htoan;
begin
-- Xu ly ke toan tu nghiep vu
if b_md_n<>b_md_x then
    if b_htoan<>'T' then
        PKT_CT_NV_SUA(b_ma_dvi,b_nsd,b_htoan_xl,b_ngay_ht,b_so_id,b_so_ct,b_ngay_ct,b_nd,' ',
            a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_md_x,b_lk,b_loi);
    else
        PKT_CT_NV_DOI(b_ma_dvi,b_md_x,b_so_id,b_lk,b_loi);
    end if;
else
    select count(*) into b_i1 from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if a_nv.count=0 then
        if b_htoan<>'T' then
            PKT_LKET_KTRA(b_ma_dvi,b_md_n,b_so_id,b_tt,b_loi); 
            if b_loi is not null then return; end if;
        end if;
        if b_tt='2' then
            if b_i1<>0 then
                PKT_CT_NV_XOA(b_ma_dvi,b_nsd,b_so_id,b_md_n,b_md_n,b_lk,b_loi);
                if b_loi is not null then return; end if;
            end if;
            b_loi:=''; return;
        end if;
    end if;
    if b_htoan='T' or FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N')='K' or a_nv.count=0 then
        b_htoan_xl:='T';
    end if;
    if b_i1<>0 then
        PKT_CT_NV_SUA(b_ma_dvi,b_nsd,b_htoan_xl,b_ngay_ht,b_so_id,b_so_ct,b_ngay_ct,b_nd,' ',
            a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_md_n,b_lk,b_loi);
    else
        PKT_CT_NV_NH(b_ma_dvi,b_nsd,b_htoan_xl,b_ngay_ht,b_so_id,b_so_ct,b_ngay_ct,
            b_nd,' ',a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_md_n,b_lk,b_loi);
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_NV_SUA
    (b_ma_dvi varchar2,b_nsd varchar2,b_htoan_m varchar2,b_ngay_ht number,b_so_id number,b_so_ctM in out varchar2,
    b_ngay_ct varchar2,b_nd nvarchar2,b_ndp nvarchar2,a_nv in out pht_type.a_var,a_ma_tk in out pht_type.a_var,
    a_ma_tke in out pht_type.a_var,a_tien in out pht_type.a_num,a_note pht_type.a_nvar,
    a_bt pht_type.a_num,b_md_x varchar2,b_lk out varchar2,b_loi out varchar2)
AS
    b_qu varchar2(1); b_htoan_c varchar2(1); b_so_tt number:=0; b_nsd_n varchar2(10):=b_nsd;
    b_tt varchar2(1):='0'; b_md_c varchar2(10); b_so_ct varchar2(20);
begin
-- Sua ke toan tu nghiep vu
b_loi:='loi:Chung tu hach toan da xoa:loi';
if b_htoan_m='T' then b_nsd_n:=''; end if;
b_qu:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N');
select htoan,md,so_ct into b_htoan_c,b_md_c,b_so_ct from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if trim(b_so_ctM) is not null and (b_md_c=b_md_x or trim(b_so_ct) is null) then b_so_ct:=b_so_ctM; end if;
if b_qu='C' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
    if b_loi is null then
        PKT_KT_SUA(b_ma_dvi,b_nsd_n,b_md_x,b_htoan_m,b_ngay_ht,' ',b_so_tt,b_so_ct,b_ngay_ct,
            b_nd,b_ndp,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_loi);
    else
        PKT_CT_NV_DOI(b_ma_dvi,b_md_x,b_so_id,b_lk,b_loi);
    end if;
else
    if b_htoan_c='H' then
        PKT_CT_NV_DOI(b_ma_dvi,b_md_x,b_so_id,b_lk,b_loi);
    else
        PKT_KT_SUA(b_ma_dvi,b_nsd_n,b_md_x,'T',b_ngay_ht,' ',b_so_tt,b_so_ct,b_ngay_ct,
            b_nd,b_ndp,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_loi);
    end if;
end if;
if b_loi is not null then return; end if;
if b_htoan_m='H' and b_md_x='VT' and instr(b_lk,'BP:0')<>0 then
    PKT_CT_BP_LKET(b_ma_dvi,b_so_id,b_tt,b_loi);
    if b_loi is null and b_tt<>'0' then
        PKT_LKET_NV(b_ma_dvi,'BP',b_so_id,b_tt,b_lk,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
if instr(b_lk,b_md_c)<0 or instr(b_lk,b_md_x)<0 then b_loi:='loi:Khong sua hach toan mat lien ket nghiep vu:loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_KT_SUA
    (b_ma_dvi varchar2,b_nsd varchar2,b_md_x varchar2,b_htoan_m varchar2,b_ngay_ht_m number,b_l_ct varchar2,
    b_so_tt in out number,b_so_ct in out varchar2,b_ngay_ct varchar2,b_nd nvarchar2,b_ndp nvarchar2,
    a_nv_m pht_type.a_var,a_ma_tk_m pht_type.a_var,a_ma_tke_m pht_type.a_var,a_tien_m pht_type.a_num,
    a_note_m pht_type.a_nvar,a_bt_m pht_type.a_num,b_so_id number,b_lk_m out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_htoan varchar2(1); b_ngay_ht number; b_kt number; b_idvung number;
    b_c1 varchar2(1); b_lk varchar2(100); b_nsd_c varchar2(10); b_md varchar2(2);
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num; a_tc pht_type.a_var;
begin
-- Dan - Sua hach toan ke toan
b_loi:='loi:Chung tu dang xu ly:loi';
select md,nsd,htoan,ngay_ht,lk,so_tt,idvung into b_md,b_nsd_c,b_htoan,b_ngay_ht,b_lk,b_i1,b_idvung
    from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sqlcode<>0 or sql%rowcount<>1 then return; end if;
if b_so_tt is null or b_so_tt=0 then b_so_tt:=b_i1; end if;
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
    if b_loi is not null then return; end if;
    b_kt:=0;
    for b_rc in (select nv,ma_tk,ma_tke,tien from kt_2
        where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        b_kt:=b_kt+1; a_nv(b_kt):=b_rc.nv; a_ma_tk(b_kt):=b_rc.ma_tk;
        a_ma_tke(b_kt):=b_rc.ma_tke; a_tien(b_kt):=-b_rc.tien;
    end loop;
    PKT_BP_THOP(b_ma_dvi,'X',b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PKT_THOP_CT(b_idvung,b_ma_dvi,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tien,b_loi);
    if b_loi is not null then return; end if;
    PKT_KT3_XOA(b_ma_dvi,b_so_id,b_loi);
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table KT_2:loi';
delete kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table KT_1:loi';
delete kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_htoan='H' then b_c1:='K'; else b_c1:='C'; end if;
if trim(b_so_ct) is null then b_so_ct:=FKT_SOCT(b_ma_dvi,b_ngay_ht,b_l_ct); end if;
PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan_m,b_ngay_ht_m,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,b_nd,b_ndp,a_nv_m,
    a_ma_tk_m,a_ma_tke_m,a_tien_m,a_note_m,a_bt_m,b_so_id,b_md,b_lk_m,b_loi,b_c1,b_c1);
if b_loi is not null then return; end if;
if b_htoan='H' then
    PKT_TCHAT(b_ma_dvi,a_ma_tk,a_tc,b_loi);
    if b_loi is not null then return; end if;
    PKT_KTRA_SODU(b_ma_dvi,b_ngay_ht,a_ma_tk,a_ma_tke,a_tc,b_loi);
    if b_loi is not null then return; end if;
    PKT_BP_THOP(b_ma_dvi,'N',b_so_id,b_loi);
    if b_loi is not null then return; end if;
    if b_htoan_m='H' then
        PKT_LKET_SUA(b_ma_dvi,b_md,b_md_x,b_nsd,b_so_id,b_l_ct,b_ngay_ht,b_lk_m,b_lk,b_loi);
    else
        PKT_LKET_XOA(b_ma_dvi,b_md,b_nsd,b_so_id,b_lk,b_loi);
    end if;
    if b_loi is not null then return; end if;
    if b_nsd_c is not null and b_nsd<>b_nsd_c then
        update kt_1 set nsd=b_nsd_c,hth=b_nsd where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_BP_THOP
    (b_ma_dvi varchar2,b_nv varchar2,b_so_id number,b_loi out varchar2)
AS
    b_ma_tke varchar2(20); b_lk varchar2(100); b_ngay_ht number; b_i1 number; b_no_ps number; b_co_ps number;
    b_no_ck number; b_co_ck number; b_idvung number; a_tc pht_type.a_var;
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num;
    a_ma_ttr pht_type.a_var; a_ma_lvuc pht_type.a_var; a_dvi pht_type.a_var; a_phong pht_type.a_var;
    a_ma_cb pht_type.a_var; a_viec pht_type.a_var; a_hdong pht_type.a_var; a_ma_sp pht_type.a_var;
begin
b_loi:='';
select min(ngayc),min(idvung),count(*) into b_ngay_ht,b_idvung,b_i1 from kt_pbo where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then
    select ngay_ht,lk,idvung into b_ngay_ht,b_lk,b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if instr(b_lk,'BP:2')<1 then b_loi:=''; return; end if;
end if;
b_ngay_ht:=round(b_ngay_ht,-2)+1;
PKT_KT2_BP(b_ma_dvi,b_so_id,a_nv,a_ma_tk,a_ma_tke,a_ma_ttr,a_ma_lvuc,a_dvi,a_phong,a_ma_cb,a_viec,a_hdong,a_ma_sp,a_tien,b_loi);
if b_loi is not null or a_nv.count=0 then return; end if;
if b_nv='X' then
    for b_lp in 1..a_nv.count loop a_tien(b_lp):=-a_tien(b_lp); end loop;
end if;
for b_lp in 1..a_nv.count loop
    b_loi:='loi:Chung tu dang xu ly:loi';
    select tc into a_tc(b_lp) from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp) for update nowait;
    if sqlcode<>0 or sql%rowcount<>1 then raise PROGRAM_ERROR; end if;
end loop;
b_loi:='loi:Loi Table SC_TK:loi';
for b_lp in 1..a_nv.count loop
    if instr(a_tc(b_lp),'TK:H')=0 then b_ma_tke:=' ';
    else b_ma_tke:=a_ma_tke(b_lp); end if;
    if a_nv(b_lp)='N' then b_no_ps:=a_tien(b_lp); b_co_ps:=0;
    else b_no_ps:=0; b_co_ps:=a_tien(b_lp); end if;
    b_i1:=null;
    select nvl(max(ngay_ht),-1) into b_i1 from kt_sc_bp where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and 
        dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and viec=a_viec(b_lp) and
        hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht<b_ngay_ht;
    if b_i1<0 then b_no_ck:=0; b_co_ck:=0;
    else select no_ck,co_ck into b_no_ck,b_co_ck from kt_sc_bp where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and 
        dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and viec=a_viec(b_lp) and
        hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht=b_i1;
    end if;
    select count(*) into b_i1 from kt_sc_bp where
        ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and 
        dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and viec=a_viec(b_lp) and
        hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht=b_ngay_ht;
    if b_i1=0 then
        insert into kt_sc_bp values(b_ma_dvi,a_ma_tk(b_lp),b_ma_tke,a_ma_ttr(b_lp),a_ma_lvuc(b_lp),a_dvi(b_lp),
            a_phong(b_lp),a_ma_cb(b_lp),a_viec(b_lp),a_hdong(b_lp),a_ma_sp(b_lp),b_no_ps,b_co_ps,0,0,b_ngay_ht,b_idvung);
    else
        update kt_sc_bp set no_ps=no_ps+b_no_ps,co_ps=co_ps+b_co_ps where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp)
            and ma_tke=b_ma_tke and ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and 
            dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and viec=a_viec(b_lp) and
            hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht=b_ngay_ht;
    end if;
    for b_rc in (select no_ps,co_ps,ngay_ht from kt_sc_bp where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke and
        ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and
        viec=a_viec(b_lp) and hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht>=b_ngay_ht order by ngay_ht) loop
        b_no_ck:=b_no_ck+b_rc.no_ps-b_rc.co_ps-b_co_ck; b_i1:=b_rc.ngay_ht;
        if b_no_ck=0 and b_rc.no_ps=0 and b_rc.co_ps=0 then
            delete kt_sc_bp where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=b_ma_tke
            and ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and 
            dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and viec=a_viec(b_lp) and
            hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht=b_i1;
        else
            if b_no_ck<0 then b_co_ck:=-b_no_ck; b_no_ck:=0; else b_co_ck:=0; end if;
            update kt_sc_bp set no_ck=b_no_ck,co_ck=b_co_ck where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp)
                and ma_tke=b_ma_tke and ma_ttr=a_ma_ttr(b_lp) and ma_lvuc=a_ma_lvuc(b_lp) and 
                dvi=a_dvi(b_lp) and phong=a_phong(b_lp) and ma_cb=a_ma_cb(b_lp) and viec=a_viec(b_lp) and
                hdong=a_hdong(b_lp) and ma_sp=a_ma_sp(b_lp) and ngay_ht=b_i1;
        end if;
    end loop;
end loop;
PKH_HDONG_DT_THOP(b_ma_dvi,b_nv,b_so_id,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_KT2_BP
    (b_ma_dvi varchar2,b_so_id number,a_nv out pht_type.a_var,a_ma_tk out pht_type.a_var,
    a_ma_tke out pht_type.a_var,a_ma_ttr out pht_type.a_var,a_ma_lvuc out pht_type.a_var,
    a_dvi out pht_type.a_var,a_phong out pht_type.a_var,a_ma_cb out pht_type.a_var,
    a_viec out pht_type.a_var,a_hdong out pht_type.a_var,a_ma_sp out pht_type.a_var,a_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_bno number; b_bco number; b_i1 number:=0; b_i2 number:=0; b_nhom varchar2(10); b_l_ct varchar2(10);
    a_nv_n pht_type.a_var; a_ma_tk_n pht_type.a_var; a_ma_tke_n pht_type.a_var; a_tien_n pht_type.a_num; a_bt pht_type.a_num;
begin
-- Dan - Tao but toan KT_2 va KT_BP
b_loi:=''; PKH_MANG_KD(a_nv); b_i1:=0;
select nvl(l_ct,' ') into b_l_ct from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt) loop
    if (r_lp.nv='N' and b_l_ct<>'KC/N') or (r_lp.nv='C' and b_l_ct<>'KC/C') then
        b_i1:=b_i1+1;
        a_nv_n(b_i1):=r_lp.nv; a_ma_tk_n(b_i1):=r_lp.ma_tk; a_ma_tke_n(b_i1):=r_lp.ma_tke;
        a_tien_n(b_i1):=r_lp.tien; a_bt(b_i1):=r_lp.bt;
        end if;
end loop;
if b_i1=0 then b_loi:=''; return; end if;
for b_lp in 1..b_i1 loop
    select min(nhom),nvl(sum(tien),0),count(*) into b_nhom,b_bno,b_bco from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp);
    if b_bco<>0 and b_bno=a_tien_n(b_lp) then
        for r_lp in (select * from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp)) loop
            b_i2:=b_i2+1;
            a_nv(b_i2):=a_nv_n(b_lp); a_ma_tk(b_i2):=a_ma_tk_n(b_lp); a_ma_tke(b_i2):=a_ma_tke_n(b_lp); a_tien(b_i2):=r_lp.tien;
            a_ma_ttr(b_i2):=r_lp.ma_ttr; a_ma_lvuc(b_i2):=r_lp.ma_lvuc; a_dvi(b_i2):=r_lp.dvi;
            a_phong(b_i2):=r_lp.phong; a_ma_cb(b_i2):=r_lp.ma_cb; a_viec(b_i2):=r_lp.viec;
            a_hdong(b_i2):=r_lp.hdong; a_ma_sp(b_i2):=r_lp.ma_sp;
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_HDONG_DT_THOP
    (b_ma_dvi varchar2,b_nv varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number; b_idvung number; b_bt number:=0; b_nd nvarchar2(400);
    a_nv pht_type.a_var; a_tien pht_type.a_num; a_hdong pht_type.a_var;
begin
-- Dan - Thua huong tu chung tu phan bo ke toan
b_loi:='loi:Loi tong hop doanh thu, chi phi hop dong:loi';
delete kh_hdong_dt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_nv='N' then
    select nvl(min(ngay_ht),0),min(nd),min(idvung)  into b_ngay_ht,b_nd,b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_ngay_ht=0 then b_loi:=''; return; end if;
    PCN_KT2_HDONG(b_ma_dvi,b_so_id,a_nv,a_hdong,a_tien,b_loi);
    if b_loi is not null or a_nv.count=0 then return; end if;
    b_loi:='loi:Loi Table kh_hdong_dt:loi';
    for b_lp in 1..a_nv.count loop
        select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=a_hdong(b_lp);
        b_bt:=b_bt+1;
        insert into kh_hdong_dt values(b_ma_dvi,b_so_id,b_bt,a_hdong(b_lp),b_ngay_ht,a_nv(b_lp),a_tien(b_lp),b_nd,b_idvung);
    end loop;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PCN_KT2_HDONG
    (b_ma_dvi varchar2,b_so_id number,a_nv out pht_type.a_var,a_hdong out pht_type.a_var,a_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_bno number; b_bco number; b_i1 number:=0; b_i2 number:=0; b_hdong varchar2(20);
    a_nv_n pht_type.a_var; a_ma_tk_n pht_type.a_var; a_ma_tke_n pht_type.a_var; a_tien_n pht_type.a_num; a_bt pht_type.a_num;
begin
-- Dan - Tao but toan KT_2 va KT_BP
b_loi:='loi:Loi lay hop dong:loi';
PKH_MANG_KD(a_nv);
for r_lp in (select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt) loop
    b_i1:=b_i1+1;
    a_nv_n(b_i1):=r_lp.nv; a_bt(b_i1):=r_lp.bt; a_tien_n(b_i1):=r_lp.tien;
end loop;
if b_i1=0 then b_loi:=''; return; end if;
for b_lp in 1..b_i1 loop
    select nvl(sum(tien),0),count(*) into b_bno,b_bco from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp);
    if b_bco<>0 and b_bno=a_tien_n(b_lp) then
        for r_lp in (select viec,hdong,sum(tien) tien from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp) group by viec,hdong having sum(tien)<>0) loop
            if trim(r_lp.hdong) is not null then b_hdong:=r_lp.hdong;
            elsif trim(r_lp.viec) is not null then
                b_hdong:=FKH_MA_HDONG_VIEC(b_ma_dvi,r_lp.viec);
            end if;
            if trim(b_hdong) is not null and b_hdong!='*' then
                b_i2:=b_i2+1;
                a_nv(b_i2):=a_nv_n(b_lp); a_tien(b_i2):=r_lp.tien; a_hdong(b_i2):=b_hdong;
            end if;
        end loop;
    end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKH_MA_HDONG_VIEC(b_ma_dvi varchar2,b_viec varchar2) return varchar2
as
    b_kq varchar2(20); b_i1 number;
begin
-- Dan - Tra ma hop dong theo ma viec
select nvl(min(hdong),' ') into b_kq from kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_viec;
if trim(b_kq) is null then
    select nvl(min(ma),' '),count(*) into b_kq,b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and viec=b_viec;
    if b_i1>1 then b_kq:='*'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PKT_KT3_XOA
    (b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number;
begin
select nvl(max(so_so),0) into b_i1 from kt_3 a,kt_so_so b where
    a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id_so;
if b_i1<>0 then
    b_loi:='loi:Khong sua,xoa chung tu da len chung tu ghi so ('||to_char(b_i1)||'):loi'; return;
end if;
b_loi:='loi:Loi Table KT_3:loi';
delete kt_3 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_TCHAT
    (b_ma_dvi varchar2,a_ma_tk pht_type.a_var,a_tc out pht_type.a_var,b_loi out varchar2)
AS
begin
-- Dan - Xac dinh tinh chat tai khoan
for b_lp in 1..a_ma_tk.count loop
    a_tc(b_lp):=FKT_TCHAT(b_ma_dvi,a_ma_tk(b_lp));
    if a_tc(b_lp)=' ' then b_loi:='loi:Tai khoan#'||rtrim(a_ma_tk(b_lp))||'#chua dang ky:loi'; return; end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKT_TCHAT(b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(100);
begin
-- Dan - Tinh chat tai khoan
select nvl(min(tc),' ') into b_kq from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PKT_LKET_SUA
    (b_ma_dvi varchar2,b_md varchar2,b_md_x varchar2,b_nsd varchar2,b_so_id number,b_l_ct varchar2,
    b_ngay_ht number,b_lk in out varchar2,b_lk_c varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(200); b_i1 number; b_i2 number; b_c1 varchar2(1); b_c2 varchar2(2);
    b_xlr varchar2(1); b_xlrT varchar2(100):='';
begin
-- Dan - Sua lien ket khi sua chung tu hanh toan
b_i1:=1; b_i2:=length(trim(b_lk_c));
while b_i1<b_i2 loop
    b_c2:=substr(b_lk_c,b_i1,2); b_loi:='loi:Loi goi xoa lien ket nghiep vu#'||trim(b_c2)||':loi';
    if b_c2='BP' then
        if instr(b_lk,b_c2)=0 then
            PKT_BP_THOP(b_ma_dvi,'X',b_so_id,b_loi);
            if b_loi is not null then return; end if;
            delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id;
        end if;
    elsif b_c2='LC' then
        if instr(b_lk,b_c2)=0 then delete kt_lc where ma_dvi=b_ma_dvi and so_id=b_so_id; end if;
    elsif b_c2 not in('TK','BH','HD','HO','KP',b_md,b_md_x) and (instr(b_lk,b_c2)=0 or instr(b_lk_c,b_c2||':0')>0) then
        if b_c2 in('CN','VT') then
            b_lenh:='begin P'||b_c2||'_'||b_c2||'_XLR(:ma_dvi,:so_id,:xlr); end;';
            execute immediate b_lenh using b_ma_dvi,b_so_id,out b_xlr;
        else
            b_xlr:='K';
        end if;
        if b_xlr<>'C' then        
            b_lenh:='begin P'||b_c2||'_'||b_c2||'_XOA(:ma_dvi,:nsd,:so_id,:loi); end;';
            execute immediate b_lenh using b_ma_dvi,b_nsd,b_so_id,out b_loi;
            if b_loi is not null then return; end if;
        else
            b_xlrT:=b_xlrT||b_c2||':';
        end if;
    end if;
    b_i1:=b_i1+4;
end loop;
b_i1:=1; b_i2:=length(trim(b_lk));
while b_i1<b_i2 loop
    b_c2:=substr(b_lk,b_i1,2);
    if b_c2 not in('TK','LC','BH','HD','HO','KP') then
        if b_c2 not in(b_md,b_md_x) and (instr(b_lk_c,b_c2)=0 or instr(b_lk_c,b_c2||':0')>0) then
            b_loi:='loi:Loi goi day lien ket nghiep vu#'||trim(b_c2)||':loi';
            if b_xlrT is null or instr(b_xlrT,b_c2)=0 then
                if b_c2 in ('CN','TT','TV','DP') or instr(b_lk_c,'BP:0')>0 then
                    b_lenh:='begin P'||b_c2||'_NV_NH(:ma_dvi,:so_id,:tt,:loi); end;';
                    execute immediate b_lenh using b_ma_dvi,b_so_id,out b_c1,out b_loi;
                    if b_loi is not null then return; end if;
                    b_lk:=replace(b_lk,substr(b_lk,b_i1,4),b_c2||':'||b_c1);
                elsif b_c2<>'BP' then
                    b_c1:='0'; b_lenh:='begin P'||b_c2||'_NV_NH(:ma_dvi,:so_id,:loi); end;';
                    execute immediate b_lenh using b_ma_dvi,b_so_id,out b_loi;
                    if b_loi is not null then return; end if;
                end if;
            end if;
        else
            b_loi:='loi:Loi goi kiem tra lien ket nghiep vu#'||trim(b_c2)||':loi';
            if b_c2='BP' then
                b_lenh:='begin PKT_CT_BP_LKET(:ma_dvi,:so_id,:tt,:loi); end;';
            else
                b_lenh:='begin P'||b_c2||'_KTRA_LKET(:ma_dvi,:so_id,:tt,:loi); end;';
            end if;
            execute immediate b_lenh using b_ma_dvi,b_so_id,out b_c1,out b_loi;
            if b_loi is not null then return; end if;
            b_lk:=replace(b_lk,substr(b_lk,b_i1,4),b_c2||':'||b_c1);
        end if;
    end if;
    b_i1:=b_i1+4;
end loop;
b_loi:='loi:Loi Table KT_1:loi';
update kt_1 set lk=b_lk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LKET_XOA
    (b_ma_dvi varchar2,b_md varchar2,b_nsd varchar2,b_so_id number,b_lk varchar2,b_loi out varchar2)
AS
    b_lenh varchar2(200); b_i1 number; b_i2 number; b_c2 varchar2(2);
begin
-- Dan - Xoa lien ket khi xoa chung tu hanh toan
b_i1:=1; b_i2:=length(trim(b_lk));
while b_i1<b_i2 loop
    b_c2:=substr(b_lk,b_i1,2);
    if b_c2='BP' then 
        PKT_BP_THOP(b_ma_dvi,'X',b_so_id,b_loi);
        if b_loi is not null then return; end if;
        delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_c2='LC' then 
        delete kt_lc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_c2='BH' and b_c2<>b_md then 
        PBH_KT_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
        if b_loi is not null then return; end if;
    elsif b_c2 not in('TK','BH','HD','HO','KP',b_md) then
        b_lenh:='begin P'||b_c2||'_'||b_c2||'_XOA(:ma_dvi,:nsd,:so_id,:loi); end;';
        execute immediate b_lenh using b_ma_dvi,b_nsd,b_so_id,out b_loi;
        if b_loi is not null then return; end if;
    end if;
    b_i1:=b_i1+4;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_NV_DOI
    (b_ma_dvi varchar2,b_md_n varchar2,b_so_id number,b_lk out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_tt varchar2(1);
begin
-- Sua lien ket ke toan tu nghiep vu b_md_n
PKT_LKET_KTRA(b_ma_dvi,b_md_n,b_so_id,b_tt,b_loi);
if b_loi is not null then return; end if;
PKT_LKET_NV(b_ma_dvi,b_md_n,b_so_id,b_tt,b_lk,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LKET_NV
    (b_ma_dvi varchar2,b_md varchar2,b_so_id number,b_tt varchar2,b_lk out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;
begin
-- Dan - Sua lien ket khi hoan thien chung tu nghiep vu
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht,lk into b_ngay_ht,b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount=0 then return; end if;
b_i1:=instr(b_lk,b_md);
if b_i1=0 then b_loi:='loi:Chung tu hach toan mat nghiep vu:loi'; return; end if;
if trim(b_tt) is null then
    b_lk:=replace(b_lk,substr(b_lk,b_i1,4),'');
else
    b_lk:=replace(b_lk,substr(b_lk,b_i1,4),b_md||':'||b_tt);
end if;
b_loi:='loi:Loi KT_1:loi';
update kt_1 set lk=b_lk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_BP_LKET
    (b_ma_dvi varchar2,b_so_id number,b_tt out varchar2,b_loi out varchar2)
AS
    b_i1 number:=0; b_log boolean; b_lk varchar2(100); b_ngay_ht number;b_l_ct varchar2(10);
begin
-- Dan - Phan bo bo phan    
b_loi:='loi:Chung tu dang xu ly:loi'; b_tt:='0';
select ngay_ht,lk,nvl(l_ct,' ') into b_ngay_ht,b_lk,b_l_ct from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sqlcode<>0 or sql%rowcount=0 then return; end if;
if instr(b_lk,'BP')=0 then b_loi:='loi:Khong phai chung tu phan bo bo phan:loi'; return; end if;
if instr(b_lk,'TK:0')<>0 or instr(b_lk,'TK:1')<>0 then b_loi:='loi:Nhap thong ke truoc phan bo bo phan:loi'; return; end if;
for r_lp1 in (select * from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_tt:='2';
    for r_lp in(select nv from kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=r_lp1.nhom) loop
        if (r_lp.nv='ma_ttr' and trim(r_lp1.ma_ttr) is null) or
            (r_lp.nv='ma_lvuc' and trim(r_lp1.ma_lvuc) is null) or
            (r_lp.nv='dvi' and trim(r_lp1.dvi) is null) or
            (r_lp.nv='phong' and trim(r_lp1.phong) is null) or
            (r_lp.nv='ma_cb' and trim(r_lp1.ma_cb) is null) or
            (r_lp.nv='hdong' and trim(r_lp1.hdong) is null) or
            (r_lp.nv='ma_sp' and trim(r_lp1.ma_sp) is null) then b_tt:='1'; exit;
        end if;
    end loop;
    if b_tt='1' then exit; end if;
end loop;
if b_tt='2' then
    for r_lp in (select nv,ma_tk,tien,bt from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
        if (r_lp.nv='N' and b_l_ct<>'KC/N') or (r_lp.nv='C' and b_l_ct<>'KC/C') then
            b_log:=PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,r_lp.nv,r_lp.ma_tk);
            select nvl(sum(tien),0) into b_i1 from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=r_lp.bt;
            if (b_i1<>r_lp.tien and b_log) or (b_i1<>0 and b_log=false) then b_tt:='1'; exit; end if;
        end if;
    end loop;
end if;
b_loi:='';
end;
/
create or replace procedure PKT_CT_NV_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_md_n varchar2,b_md_x varchar2,b_lk out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_lenh varchar2(400); b_tt varchar2(1):='0';
begin
-- Xoa ke toan tu nghiep vu
if b_md_n=b_md_x then
    select min(lk),count(*) into b_lk,b_i1 from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1>0 then
        PKT_KT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,b_md_n);
        if b_loi is not null then return; end if;
    else
        delete kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
else
    if b_md_x in ('CN','TT','TV') then
        b_lenh:='begin P'||b_md_x||'_NV_NH(:ma_dvi,:so_id,:tt,:loi); end;';
        execute immediate b_lenh using b_ma_dvi,b_so_id,out b_tt,out b_loi;
    elsif b_md_x<>'BH' then
        b_lenh:='begin P'||b_md_x||'_NV_NH(:ma_dvi,:so_id,:loi); end;';
        execute immediate b_lenh using b_ma_dvi,b_so_id,out b_loi;
    end if;
    if b_loi is not null then return; end if;
    PKT_LKET_NV(b_ma_dvi,b_md_x,b_so_id,b_tt,b_lk,b_loi);
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_NV_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_htoan varchar2,b_ngay_ht number,b_so_id number,
    b_so_ct in out varchar2,b_ngay_ct varchar2,b_nd nvarchar2,b_ndp nvarchar2,a_nv pht_type.a_var,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_tien pht_type.a_num,
    a_note pht_type.a_nvar,a_bt pht_type.a_num,b_md varchar2,b_lk out varchar2,b_loi out varchar2)
AS
    b_so_tt number; b_phong varchar2(10); b_idvung number; b_tt varchar2(1):='0';
begin
-- Nhap ke toan tu nghiep vu
b_idvung:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; return; end if;
PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,' ',b_so_tt,b_so_ct,b_ngay_ct,b_nd,b_ndp,
    a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_md,b_lk,b_loi,'C');
if b_loi is not null then return; end if;
if b_htoan='H' and instr(b_lk,'BP:0')<>0 then
    if b_md='TT' then
        select phong into b_phong from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if trim(b_phong) is not null then
            for b_lp in 1..a_bt.count loop
                if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,a_nv(b_lp),a_ma_tk(b_lp)) then
                    insert into kt_bp values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,' ',' ',' ',' ',b_phong,' ',' ',' ',' ',a_tien(b_lp),b_lp,b_idvung);
                end if;
            end loop;
            b_tt:='2';
        end if;
    elsif b_md='VT' then
        PKT_CT_BP_LKET(b_ma_dvi,b_so_id,b_tt,b_loi);
        if b_loi is not null then b_tt:='0'; end if;
    end if;
    if b_tt<>'0' then
        PKT_LKET_NV(b_ma_dvi,'BP',b_so_id,b_tt,b_lk,b_loi);
        if b_loi is not null then return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_TEST
    (b_ma_dvi varchar2,b_ngay_ht number,b_l_ct varchar2,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,
    a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_tc out pht_type.a_var,b_tno out number,b_loi out varchar2)
AS
    b_tco number; b_c1 varchar2(1); b_i1 number;
begin
-- Dan - Kiem tra chung tu hach toan ke toan
if trim(b_l_ct) is not null and b_l_ct not in ('KC','KC/N','KC/C') then
    b_loi:='loi:Ma loai chung tu chua dang ky:loi';
    select 0 into b_i1 from kt_ma_lct where ma_dvi=b_ma_dvi and ma=b_l_ct;
end if;
if a_nv.count=0 then b_loi:='loi:Nhap hach toan:loi'; return; end if;
b_tno:=0; b_tco:=0; b_loi:='';
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp) is null or a_nv(b_lp) not in('N','C') or a_ma_tk(b_lp) is null or
        a_tien(b_lp) is null then
        b_loi:='loi:Sai so lieu nhap ke toan:loi'; return;
    end if;
    b_loi:='loi:Tai khoan#'||rtrim(a_ma_tk(b_lp))||'#chua dang ky:loi';
    select tc into a_tc(b_lp) from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
    b_loi:='loi:Sai phat sinh tai khoan#'||rtrim(a_ma_tk(b_lp))||':loi';
    b_i1:=instr(a_tc(b_lp),'T1'); b_c1:=substr(a_tc(b_lp),b_i1+3,1);
    if b_i1=0 or b_c1 not in ('T',a_nv(b_lp)) then return; end if;
    b_loi:='loi:Sai ma thong ke#'||rtrim(a_ma_tke(b_lp))||'#tai khoan#'||trim(a_ma_tk(b_lp))||':loi';
    if instr(a_tc(b_lp),'TK:H')>0 or instr(a_tc(b_lp),'TK:C')>0 then
        if a_ma_tke(b_lp)<>' ' then
            select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=a_ma_tke(b_lp);
        elsif FKH_NV_TSO(b_ma_dvi,'KT','KT','ma_tke','K')='C' then return;
        end if;
    elsif a_ma_tke(b_lp)<>' ' then return;
    end if;
    if a_tien(b_lp)=0 and PKT_CT_TKLQVAT(b_ma_dvi,a_nv(b_lp),a_ma_tk(b_lp),b_ngay_ht)<>'C' then
        b_loi:='loi:Nhap tien dong#'||to_char(b_lp)||':loi'; return;
    end if; 
    if a_nv(b_lp)='N' then b_tno:=b_tno+a_tien(b_lp);
    else b_tco:=b_tco+a_tien(b_lp); end if;
end loop;
if b_tno<>b_tco then b_loi:='loi:Tong tien NO '||b_tno||' khac tong tien CO'||b_tco||':loi'; return; end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_BH_PBO_DV
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_idvung number; b_ngayD number; b_ngay_ct varchar2(10); b_cbao varchar2(200);
    b_so_id number; b_bt number:=0; b_kt number:=0; b_so_tt number:=0; b_so_ct varchar2(20):=' '; b_lk varchar2(100);
    a_phT pht_type.a_var; a_tl pht_type.a_num; a_tienP pht_type.a_num;
    a_ma_tkP pht_type.a_var; a_ma_tkeP pht_type.a_var; a_ph pht_type.a_var; a_sp pht_type.a_var; a_tienC pht_type.a_num;
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var;
    a_tien pht_type.a_num; a_note pht_type.a_nvar; a_bt pht_type.a_num;

    a_dvi pht_type.a_var; a_ma_nt pht_type.a_var; a_tygia pht_type.a_num;
    a_tienD pht_type.a_num; a_tien_qd pht_type.a_num; a_nd pht_type.a_nvar;
begin
-- Dan - Tong hop phan bo san pham THANG
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','Q');
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_ht is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_ngayD:=trunc(b_ngay_ht,-2)+1; b_ngay_ct:=PKH_SO_CNG(b_ngay_ht);
for r_lp in (select htoan,l_ct,lk from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngay_ht) loop
    if r_lp.htoan='H' and nvl(r_lp.l_ct,' ')<>'KC' and instr(r_lp.lk,'BP')>0
        and (instr(r_lp.lk,'TK:1')>0 or instr(r_lp.lk,'TK:0')>0) then
        b_loi:='loi:Hoan chinh ma thong ke truoc khi phan bo:loi'; raise PROGRAM_ERROR;
    end if;
end loop;
PKH_MANG_KD(a_ma_tk);
for r_lp in (select * from (select so_id,htoan,nvl(l_ct,' ') l_ct,lk from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngay_ht)
    where htoan='H' and l_ct<>'KC') loop
    for r_lp1 in (select * from (select * from kt_2 where ma_dvi=b_ma_dvi and so_id=r_lp.so_id) where
        FKT_PB_NHOM(b_ma_dvi,b_ngay_ht,ma_tk)='D' and FKT_PB_KIEU(b_ma_dvi,b_ngay_ht,ma_tk,ma_tke)='D' and
        ((nv='N' and r_lp.l_ct<>'KC/N') or (nv='C' and r_lp.l_ct<>'KC/C'))) loop
        if r_lp1.nv='N' then b_i1:=r_lp1.tien; else b_i1:=-r_lp1.tien; end if;
        for b_lp in 1..a_ma_tk.count loop
            if a_ma_tkP(b_lp)=r_lp1.ma_tk and a_ma_tkeP(b_lp)=r_lp1.ma_tke then
                a_tienP(b_lp):=a_tienP(b_lp)+b_i1; b_i1:=0; exit;
            end if;
        end loop;
        if b_i1<>0 then
            b_i2:=a_ma_tkP.count+1;
            a_ma_tkP(b_i2):=r_lp1.ma_tk; a_ma_tkeP(b_i2):=r_lp1.ma_tke; a_tienP(b_i2):=b_i1;
        end if;
    end loop;
end loop;
PKH_MANG_KD(a_ph);
FKT_BH_PBO_TDV(b_ngay_ht,a_phT,a_tl);
for b_lp1 in 1..a_ma_tkP.count loop
    FKT_BH_PBO_CDV(a_tienP(b_lp1),a_phT,a_tl,a_tienC);
    b_i1:=0;
    for b_lp in 1..a_ph.count loop
        if a_phT(b_lp)<>b_ma_dvi then
            b_kt:=b_kt+1; b_i1:=b_i1+a_tienC(b_lp);
            a_dvi(b_kt):=a_phT(b_lp); a_ma_nt(b_kt):='VND'; a_tygia(b_kt):=1;
            a_tien(b_kt):=a_tienC(b_lp); a_tien_qd(b_kt):=a_tienC(b_lp); a_nd(b_kt):=a_ma_tkeP(b_lp1);
        else
            b_bt:=b_bt+1;
            a_nv(b_bt):='N'; a_ma_tk(b_bt):='Ma tai khoan chi phi phan bo';
            a_ma_tke(b_bt):=a_ma_tkeP(b_lp1); a_tien(b_bt):=a_tienC(b_lp); a_note(b_bt):=' '; a_bt(b_bt):=b_bt;
        end if;
        if b_i1<>0 then
            b_bt:=b_bt+1;
            a_nv(b_bt):='N'; a_ma_tk(b_bt):=PKH_MA_LCT_TRA_TK(b_ma_dvi,'CD','PC',b_ngay_ht,'N');
            a_ma_tke(b_bt):=a_ma_tkeP(b_lp1); a_tien(b_bt):=b_i1; a_note(b_bt):=' '; a_bt(b_bt):=b_bt;
        end if;
    end loop;
end loop;
for b_lp in 1..a_ma_tkP.count loop
    b_bt:=b_bt+1;
    a_nv(b_bt):='C'; a_ma_tk(b_bt):=a_ma_tkP(b_lp); a_ma_tke(b_bt):=a_ma_tkeP(b_lp);
    a_tien(b_bt):=a_tienP(b_lp); a_note(b_bt):=' '; a_bt(b_bt):=b_bt;
end loop;
PKT_CT_NH(b_ma_dvi,b_nsd,b_pas,'H',b_ngay_ht,'KC/N',b_so_tt,b_so_ct,b_ngay_ct,'Phan bo chi phi chung toan dia ban',' ',
    a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_cbao);
PCD_CT_NH(b_ma_dvi,b_nsd,b_pas,b_so_id,b_so_ct,b_ngay_ht,'H','PC',' ',b_ngay_ct,'Phan bo chi phi chung toan dia ban',
    a_dvi,a_ma_nt,a_tygia,a_tien,a_tien_qd,a_nd,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_lk,b_cbao);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function PKT_CT_TKLQVAT
    (b_ma_dvi varchar2,b_nv varchar2,b_ma_tk varchar2,b_ngay number) return varchar2
AS
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var;
begin
-- Dan - Tra tai khoan lien quan VAT
PKH_MA_LCT_MDTK(b_ma_dvi,'TV',b_ngay,a_nv,a_ma_tk);
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp)=b_nv and PKH_MA_LMA(a_ma_tk(b_lp),b_ma_tk) then return 'C'; end if;
end loop;
return 'K';
end;
/
create or replace procedure PKH_MA_LCT_MDTK
    (b_ma_dvi varchar2,b_md varchar2,b_ngay number,a_nv out pht_type.a_var,a_ma_tk out pht_type.a_var)
AS
    b_i1 number;
begin
-- Dan - Xac dinh tai khoan theo Modul
PKH_MANG_KD(a_nv);
for r_lp in (select distinct nv,ma_tk from kh_ma_lct_tk b where ma_dvi=b_ma_dvi and md=b_md and (ma,ngay) in
    (select ma,max(ngay) from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ngay<=b_ngay group by ma)) loop
    if r_lp.nv in ('N','C','T') then
        b_i1:=a_nv.count+1; a_nv(b_i1):=r_lp.nv; a_ma_tk(b_i1):=r_lp.ma_tk;
    end if;
end loop;
end;
/
create or replace function FKT_SOTT
    (b_ma_dvi varchar2,b_ngay_ht number,b_l_ct varchar2) return number
AS
    b_d1 number; b_d2 number; b_i1 number;
begin
-- Dan - Cho so thu tu tiep theo cua CT ke toan
b_d1:=round(b_ngay_ht,-2); b_d2:=b_d1+100;  --Theo thang
if FKH_NV_TSO(b_ma_dvi,'KT','KT','so_ct','C')='C' then
    select nvl(max(so_tt),0) into b_i1 from (select l_ct,so_tt from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2) where nvl(l_ct,' ')=nvl(b_l_ct,' ');
else
    select nvl(max(so_tt),0) into b_i1 from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2;
end if;
return b_i1+1;
end;
/
create or replace function FKT_SOCT
    (b_ma_dvi varchar2,b_ngay_ht number,b_l_ct varchar2) return varchar2
AS
    b_d1 number; b_d2 number; b_i1 number; b_kq varchar2(20):='';
begin
-- Dan - Cho so chung tu tiep theo cua CT ke toan
b_d1:=round(b_ngay_ht,-2); b_d2:=b_d1+100;  --Theo thang
if FKH_NV_TSO(b_ma_dvi,'KT','KT','so_ct','C')='C' then
    select nvl(max(PKH_LOC_CHU_SO(substr(so_ct,instr(so_ct,'/',-1)+1),'F','F')),0) into b_i1 from
        (select md,l_ct,so_ct from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2) where md='KT' and nvl(l_ct,' ')=nvl(b_l_ct,' ');
    if trim(b_l_ct) is null then b_kq:='KHAC-'; else b_kq:=b_l_ct||'-'; end if;
else
    select nvl(max(PKH_LOC_CHU_SO(substr(so_ct,instr(so_ct,'/',-1)+1),'F','F')),0) into b_i1 from
        (select md,so_ct from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2) where md='KT';
end if;
b_kq:=b_kq||substr(to_char(b_ngay_ht),5,2)||'/'||to_char(b_i1+1);
return b_kq;
end;
/
create or replace function FBH_HH_HD_KEM(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1);
begin
-- Dan - Xac dinh kieu hop dong goc
select nvl(min(hd_kem),'K') into b_kq from bh_hhgcn where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
create or replace procedure FKT_BH_PBO_TDV
    (b_ngay_ht number,a_ph out pht_type.a_var,a_tl out pht_type.a_num)
AS
    b_i1 number:=0; b_ngayD number; b_ngayC number;
begin
-- Dan - Tao ty le doanh thu theo don vi
b_ngayD:=trunc(b_ngay_ht,-2)+1;
select ma_dvi,sum(phi_qd) bulk collect into a_ph,a_tl from bh_hd_goc_ttpb
    where ngay_ht between b_ngayD and b_ngay_ht and pthuc in('G','C') group by ma_dvi,nv having sum(phi_qd)>0;
for b_lp in 1..a_ph.count loop
    b_i1:=b_i1+a_tl(b_lp);
end loop;
for b_lp in 1..a_ph.count loop
    a_tl(b_lp):=a_tl(b_lp)/b_i1;
end loop;
end;
/
create or replace procedure FKT_BH_PBO_CDV
    (b_tien number,a_ph pht_type.a_var,a_tl pht_type.a_num,a_tien out pht_type.a_num)
AS
-- Dan - Chia theo ty le doanh thu
begin
a_tien(1):=b_tien;
for b_lp in 2..a_ph.count loop
    a_tien(b_lp):=round(b_tien*a_tl(b_lp),0);
    if abs(a_tien(b_lp))>abs(a_tien(1)) then a_tien(b_lp):=a_tien(1); end if;
    a_tien(1):=a_tien(1)-a_tien(b_lp);
end loop;
end;
/
create or replace procedure PTS_TH_LAI
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_klk varchar2:='T')
AS
	b_loi varchar2(100); b_i1 number; b_ngc date; b_ngt date; b_ngkh date; b_so_the varchar2(20); b_idvung number;
begin
-- Dan - Tong hop so cai khau hao
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TS','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngc:=PKH_SO_CDT(b_ngay); b_ngc:=last_day(b_ngc); b_i1:=PKH_NG_CSO(b_ngc);
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_i1,'KT','TS');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete ts_kh where ma_dvi=b_ma_dvi and ngay>=b_ngc;
delete ts_phu where ma_dvi=b_ma_dvi and ngay>=b_ngc;
delete temp_1; commit;
insert into temp_1(c1,c2) (select distinct a.so_the,b.loai from ts_sc_2 a,ts_sc_1 b where
	a.ma_dvi=b_ma_dvi and a.ng_bd<=b_ngc and b.ma_dvi=b_ma_dvi and a.so_the=b.so_the);
if sql%rowcount=0 then b_loi:='loi:Chua co phat sinh:loi'; raise PROGRAM_ERROR; end if;
select min(ng_bd) into b_ngkh from ts_sc_2 a,temp_1 b where ma_dvi=b_ma_dvi and a.so_the=b.c1;
b_ngkh:=last_day(b_ngkh);
if b_klk in('T','C') then
	select count(*),max(ngay) into b_i1,b_ngt from ts_kh where ma_dvi=b_ma_dvi;
	if b_i1<>0 then
		b_ngt:=add_months(b_ngt,1);
		if b_ngkh<b_ngt then b_ngkh:=b_ngt; end if;
	end if;
end if;
if b_klk in ('T','P') then
	select count(*),max(ngay) into b_i1,b_ngt from ts_phu where ma_dvi=b_ma_dvi;
	if b_i1<>0 then
		b_ngt:=add_months(b_ngt,1);
		if b_ngkh<b_ngt then b_ngkh:=b_ngt; end if;
	end if;
end if;
while b_ngkh<=b_ngc loop
	for r_lp in (select c1 so_the,c2 loai from temp_1) loop
		b_so_the:=r_lp.so_the;
		select count(*) into b_i1 from ts_sc_2 where ma_dvi=b_ma_dvi and so_the=b_so_the and ng_bd<=b_ngkh;
		if b_i1<>0 then
			if b_klk in('T','C') and r_lp.loai<>'P' then
				PTS_KH_TH(b_ma_dvi,b_so_the,b_ngkh,b_loi);
				if b_loi is not null then raise PROGRAM_ERROR; end if;
			elsif b_klk in('T','P') and r_lp.loai='P' then
				PTS_PHU_TH(b_ma_dvi,b_so_the,b_ngkh,b_loi);
				if b_loi is not null then raise PROGRAM_ERROR; end if;
			end if;
		end if;
	end loop;
	commit;
	b_ngkh:=add_months(b_ngkh,1);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_KH_TH
	(b_ma_dvi varchar2,b_so_the varchar2,b_ngc date,b_loi out varchar2)
AS
	b_i1 number; b_i2 number; b_i3 number; b_d1 date; b_d2 date; b_d3 date; b_them number:=0;
	b_dvid varchar2(10); b_dvic varchar2(10); b_ngd date; b_ngt date; b_ngn date;
	b_ppt varchar2(1); b_nam number; b_ng_kh date; b_tg_kh number; b_tcon number; b_ma_ng varchar2(5);
	b_lbd varchar2(1); b_tckhao varchar2(1); b_xl varchar2(1); b_idvung number;
	b_nggia_dk number; b_nggia_bd number; b_nggia_bs number; b_nggia_ck number; b_ng_cu number;
	b_kh_dk number; b_kh_bd number; b_kh_bs number; b_kh_th number; b_kh_ck number; b_so_ngkh number:=0;
begin
-- Dan - Tong hop nguyen gia,khao hao theo nguon tung thang
--	b_ma_ng - Ma nguon.
--	b_nggia_dk,b_nggia_ck,b_nggia_bd,b_nggia_bs - Ng.gia dau, cuoi ky, b.dong ng.gia trong, sau ky
--	b_kh_dk,b_kh_ck,b_kh_th,b_kh_bd,b_kh_bs - Luy ke khau hao den dau, cuoi ky, k.hao thang, b.dong l.ke k.hao trong, sau ky
select tg_kh,ng_kh,idvung into b_tg_kh,b_ng_kh,b_idvung from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
b_ngd:=trunc(b_ngc,'MONTH'); b_ngt:=b_ngd-1; b_ngn:=trunc(b_ngd,'YEAR')-1;
if b_ng_kh<=b_ngc then
	b_d1:=b_ng_kh;
	if b_ng_kh<b_ngd then
		select count(*) into b_i1 from ts_kh where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<b_ngd;
		if b_i1<>0 then
			b_d1:=b_ngd; b_d3:=trunc(b_ng_kh,'MONTH');
			b_them:=(b_ng_kh-b_d3)/((last_day(b_ng_kh)-b_d3)+1);
			b_tg_kh:=b_tg_kh+months_between(b_ngd,b_d3);
		end if;
	end if;
	b_d3:=trunc(b_d1,'MONTH'); b_i3:=0;
	if b_d1<>b_d3 then
		b_i3:=1-(b_d1-b_d3)/((last_day(b_d1)-b_d3)+1);
		b_d1:=add_months(b_d3,1); b_d3:=b_d1;
	end if;
	if b_d1<b_ngc then
		select count(*),max(ngay) into b_i1,b_d2 from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<=b_d1;
		if b_i1<>0 then
			select khao into b_tckhao from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_d2;
		else
			b_tckhao:='K';
		end if;
		for r_lp in(select ngay,khao from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay between b_d1 and b_ngc) loop
			if r_lp.khao<>b_tckhao then
				if b_tckhao='K' then b_so_ngkh:=b_so_ngkh+(r_lp.ngay-b_d1); end if;
				b_d1:=r_lp.ngay; b_tckhao:=r_lp.khao;
			end if;
		end loop;
		if b_tckhao='K' then b_so_ngkh:=b_so_ngkh+(b_ngc-b_d1)+1; end if;
		b_i1:=months_between(b_ngc+1,b_d3); b_i2:=(b_ngc-b_d3)+1;
		b_so_ngkh:=b_i1*b_so_ngkh/b_i2;
	end if;
	b_so_ngkh:=b_so_ngkh+b_i3;
end if;
if b_so_ngkh<>0 then
	PTS_KH_PTT(b_ma_dvi,b_so_the,b_ngd,b_tg_kh,b_ppt,b_nam,b_tcon,b_loi);
	if b_loi is not null then return; end if;
end if;
b_loi:='Loi don vi su dung';
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<=b_ngc;
if b_i1=0 then raise PROGRAM_ERROR; end if;
select dvi_sd into b_dvic from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<b_ngd;
if b_i1=0 then b_dvid:=b_dvic;
else select dvi_sd into b_dvid from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
end if;
for r_lp in (select distinct ma_ng from ts_sc_2 where ma_dvi=b_ma_dvi and so_the=b_so_the and ng_bd<=b_ngc) loop
	b_ma_ng:=r_lp.ma_ng; b_loi:='Da xoa ma nguon#'||b_ma_ng;
	select nvl(khao,'C') into b_tckhao from xd_ma_nguon where ma_dvi=b_ma_dvi and ma=b_ma_ng;
	select nvl(sum(nggia_ck),0),nvl(sum(kh_ck),0) into b_nggia_dk,b_kh_dk from ts_kh where
		ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngt and ma_ng=b_ma_ng;
	b_nggia_bd:=0; b_nggia_bs:=0; b_kh_th:=0; b_kh_bd:=0; b_kh_bs:=0;
	for b_rc in (select ma_bd,sum(tien_qd) tien from ts_sc_2 where ma_dvi=b_ma_dvi and
		so_the=b_so_the and ma_ng=b_ma_ng and (ng_bd between b_ngd and b_ngc) group by ma_bd) loop
		b_loi:='Da xoa ma bien dong#'||b_rc.ma_bd;
		select loai,xl into b_lbd,b_xl from ts_ma_bdong where ma_dvi=b_ma_dvi and ma=b_rc.ma_bd;
		if b_lbd='T' then
			if b_xl='T' then b_nggia_bd:=b_nggia_bd+b_rc.tien; else b_nggia_bs:=b_nggia_bs+b_rc.tien; end if;
		elsif b_lbd='G' then
			if b_xl='T' then b_nggia_bd:=b_nggia_bd-b_rc.tien; else b_nggia_bs:=b_nggia_bs-b_rc.tien; end if;
		elsif b_lbd='K' then
			if b_xl='T' then b_kh_bd:=b_kh_bd+b_rc.tien; else b_kh_bs:=b_kh_bs+b_rc.tien; end if;
		elsif b_lbd='C' then
			b_kh_th:=b_kh_th+b_rc.tien;
		end if;
	end loop;
	b_nggia_ck:=b_nggia_dk+b_nggia_bd; b_kh_ck:=b_kh_dk+b_kh_bd;
	if b_so_ngkh<>0 and b_tckhao='C' and b_kh_th=0 and b_nggia_ck>b_kh_ck then
		if b_nam<=0 then b_kh_th:=0;
		elsif b_ppt='P' then b_kh_th:=round(b_nggia_ck*b_nam/1200,0);
		elsif b_ppt='C' then b_kh_th:=round(b_nggia_ck/(12*b_nam),0);
		elsif b_tcon=0 then b_kh_th:=b_nggia_ck-b_kh_ck;
		else
			b_kh_th:=round((b_nggia_ck-b_kh_ck)/(b_tcon+b_them),0);
		    if b_ppt='S' then		-- Khau hao nhanh
				b_loi:='Sai he so dieu chinh nam loai#'||to_char(b_nam)||'#cho ngay#'||to_char(b_ngd,'dd/mm/yyyy');
				select max(nam),count(*) into b_i1,b_i2 from ts_hsdc where ma_dvi=b_ma_dvi and ngay<=b_ngd and nam<=b_nam;
				if b_i2=0 then raise PROGRAM_ERROR; end if;
				select hs into b_i2 from ts_hsdc where ma_dvi=b_ma_dvi and nam=b_i1 and ngay in
					(select max(ngay) from ts_hsdc where ma_dvi=b_ma_dvi and ngay<=b_ngd and nam=b_i1);
				select nvl(sum(kh_ck),0) into b_i1 from ts_kh where
					ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngn and ma_ng=b_ma_ng;
				select nvl(sum(kh_bd),0) into b_i3 from ts_kh where
					ma_dvi=b_ma_dvi and so_the=b_so_the and (ngay>b_ngn and ngay<b_ngd) and ma_ng=b_ma_ng;
				b_i1:=round((b_nggia_ck-b_i1-b_i3-b_kh_bd)*b_i2/b_nam/12,0);
				if b_i1>b_kh_th then b_kh_th:=b_i1; end if;
			end if;
		end if;
		b_kh_th:=round(b_kh_th*b_so_ngkh,0);
		if b_nggia_ck<b_kh_ck+b_kh_th then b_kh_th:=b_nggia_ck-b_kh_ck; end if;
	end if;
	b_nggia_ck:=b_nggia_ck+b_nggia_bs; b_nggia_bd:=b_nggia_bd+b_nggia_bs;
	b_kh_ck:=b_kh_ck+b_kh_th+b_kh_bs; b_kh_bd:=b_kh_bd+b_kh_bs;
	if b_dvid=b_dvic then
		insert into ts_kh values(b_ma_dvi,b_ngc,b_so_the,b_dvid,b_ma_ng,b_nggia_dk,b_nggia_bd,0,0,b_nggia_ck,b_kh_dk,b_kh_bd,b_kh_th,0,0,b_kh_ck,b_tcon,b_idvung);
	else
		insert into ts_kh values(b_ma_dvi,b_ngc,b_so_the,b_dvid,b_ma_ng,b_nggia_dk,0,b_nggia_dk,0,0,b_kh_dk,0,0,b_kh_dk,0,0,b_tcon,b_idvung);
		insert into ts_kh values(b_ma_dvi,b_ngc,b_so_the,b_dvic,b_ma_ng,0,b_nggia_bd,0,b_nggia_dk,b_nggia_ck,0,b_kh_bd,b_kh_th,0,b_kh_dk,b_kh_ck,b_tcon,b_idvung);
	end if;
end loop;
b_loi:='';
exception when others then
	if b_loi is null then b_loi:='Loi tinh khau hao#'; end if;
	b_loi:='loi:'||trim(b_loi)||'#so the#'||b_so_the||':loi';
end;
/
create or replace procedure PTS_KH_PTT(b_ma_dvi varchar2,b_so_the varchar2,b_ngay date,
	b_tg_kh number,b_ppt out varchar2,b_nam out number,b_tcon out number,b_loi out varchar2)
AS
	b_i1 number; b_ngbd date; b_ngd date; b_ngc date; b_ma_ts varchar2(10);
	b_kieu varchar2(2); b_con_khao number:=0; b_nggia_dk number; b_kh_dk number;
begin
-- Dan - Phuong thuc tinh KH
b_loi:='loi:Loi tim kieu khau hao the#'||b_so_the||':loi';
select count(*),max(ngay) into b_i1,b_ngbd from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<=b_ngay and b_con_khao<>0;
if b_i1<>0 then
	select ma_ts,kieu,con_khao into b_ma_ts,b_kieu,b_con_khao from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngbd;
else
	select ma_ts,kieu into b_ma_ts,b_kieu from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
end if;
select count(*),max(ngay) into b_i1,b_ngc from ts_ma_ts_kh where ma_dvi=b_ma_dvi and ma=b_ma_ts and kieu=b_kieu and ngay<=b_ngay;
if b_i1=0 then b_loi:='loi:Ma TS:'||b_ma_ts||'#kieu KH:'||b_kieu||'#chua dang ky:loi'; return; end if;
select ppt,nam into b_ppt,b_nam from ts_ma_ts_kh where ma_dvi=b_ma_dvi and ma=b_ma_ts and kieu=b_kieu and ngay=b_ngc;
b_tcon:=b_nam*12-b_tg_kh;
if b_ppt='N' and (b_con_khao=0 or b_ngc>b_ngbd) then
	select count(*),max(ngay) into b_i1,b_ngd from ts_kh where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<b_ngc;
	if b_i1<>0 then
		select nvl(sum(nggia_ck),0),nvl(sum(kh_ck),0) into b_nggia_dk,b_kh_dk
			from ts_kh where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngd;
		if b_nggia_dk<>0 then
			b_tcon:=round(b_nam*12*(1-b_kh_dk/b_nggia_dk),0)-months_between(b_ngay,trunc(b_ngd,'MONTH'));
		end if;
	end if;
elsif b_con_khao<>0 then
	b_nam:=b_con_khao; b_tcon:=b_nam*12-months_between(b_ngay,trunc(b_ngbd,'MONTH'));
end if;
if b_tcon<0 then b_tcon:=0; end if;
b_loi:='';
end;
/
create or replace procedure PTS_DAUKY
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay date,b_so_the varchar2,b_dvi_sd varchar2,
    b_ma_ng varchar2,b_nggia_dk number,b_kh_dk number)
AS
    b_loi varchar2(100); b_idvung number; b_d1 date; b_i1 number; b_nggia_c number; b_kh_c number;
begin
-- Dan - Dieu chinh so du dau ky
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_so_the) is null then
    b_loi:='loi:Nhap so the:loi';
elsif b_ngay is null then
    b_loi:='loi:Nhap ngay:loi';
elsif trim(b_dvi_sd) is null then
    b_loi:='loi:Nhap don vi su dung the#'||b_so_the||':loi';
elsif trim(b_ma_ng) is null then
    b_loi:='loi:Nhap nguon the#'||b_so_the||'';
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
select min(ngay),count(*) into b_d1,b_i1 from ts_kh where ma_dvi=b_ma_dvi;
if b_i1<>0 and b_d1<>b_ngay then
    b_loi:='loi:Sai ngay dau ky '||b_d1||':loi'; raise PROGRAM_ERROR;
end if;
select nvl(min(nggia_dk),0),nvl(min(kh_dk),0),count(*) into b_nggia_c,b_kh_c,b_i1 from ts_kh
    where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngay and dvi_sd=b_dvi_sd and ma_ng=b_ma_ng;
b_nggia_c:=b_nggia_dk-b_nggia_c; b_kh_c:=b_kh_dk-b_kh_c;
if b_i1=0 then
    insert into ts_kh values(b_ma_dvi,b_ngay,b_so_the,b_dvi_sd,b_ma_ng,b_nggia_dk,0,0,0,b_nggia_dk,b_kh_dk,0,0,0,0,b_kh_dk,0,b_idvung);
elsif b_nggia_c<>0 or b_kh_c<>0 then
    update ts_kh set nggia_dk=b_nggia_dk,nggia_ck=b_nggia_dk,kh_dk=b_kh_dk,kh_ck=b_kh_dk
        where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngay and dvi_sd=b_dvi_sd and ma_ng=b_ma_ng;
end if;
if b_i1=0 or b_nggia_c<>0 or b_kh_c<>0 then
    update ts_kh set nggia_dk=nggia_dk+b_nggia_c,nggia_ck=nggia_ck+b_nggia_c,kh_dk=kh_dk+b_kh_c,kh_ck=kh_ck+b_kh_c
        where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay>b_ngay and dvi_sd=b_dvi_sd and ma_ng=b_ma_ng;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_TK_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_tk varchar2,b_ten out nvarchar2,b_tc out varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Hoi ten, tc ma tai khoan
b_loi:='loi:Ma tai khoan chua dang ky:loi';
if trim(b_ma_tk) is null then raise PROGRAM_ERROR; end if;
select ten,tc into b_ten,b_tc from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_TK_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NXM');
open cs1 for select distinct ngay,nsd from cn_tk where ma_dvi=b_ma_dvi order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_LCT_NGAY
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_md_k varchar2(10):=b_md;
begin
-- Dan - Liet ke
if b_md in('BP','LC') then b_md_k:='KT'; end if;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_md_k,'');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select ngay,PKH_SO_CNG(ngay) ngay_ch,nsd from
    (select distinct ngay,nsd from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md) order by ngay DESC;
end;
/
create or replace procedure PKH_MA_LCT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_d1 number; b_md_k varchar2(10):=b_md;
begin
-- Dan - Xem ma loai chung tu
if b_md in('BP','LC') then b_md_k:='KT'; end if;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_md_k,'');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select ma,ten,nsd,ngay ngay_so,PKH_SO_CNG(ngay) ngay from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md order by ngay,ma;
end;
/
create or replace procedure PBH_CP_LCT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ma doi tuong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select '' nhom,l_ct loai,ten,'T' tc,pdo,pta from bh_cp_lct where ma_dvi=b_ma_dvi order by l_ct;
end;
/
create or replace procedure PKH_NV_TSO_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,cs_lke out pht_type.cs_type)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,b_md,b_nv,'');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_md is null or b_nv is null then b_loi:='loi:Nhap Modul, nghiep vu:loi'; end if;
open cs_lke for select ma,tso from kh_nv_tso where ma_dvi=b_ma_dvi and md=b_md and nv=b_nv;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_BP_NHOM_CT
 (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_ct out pht_type.cs_type,cs_nv out pht_type.cs_type)
AS
 b_loi varchar2(100);
begin
-- Dan - CT nhom
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_ct for select * from kt_bp_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
open cs_nv for select nv,loai from kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FVT_MA_CAP(b_ma_dvi varchar2,b_nhom varchar2,b_ma_ts varchar2) return number
as
    b_kq number:=0; b_maM varchar(30); b_maC varchar(30);
begin
-- Dan - Xac dinh cap
b_maC:=b_ma_ts;
while b_maC<>' ' loop
    b_kq:=b_kq+1;
    select nvl(min(ma_ct),' ') into b_maM from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_maC;
    b_maC:=b_maM;
end loop;
return b_kq;
end;
/
create or replace function FCC_DUNG(b_ma_dvi varchar2,b_so_id varchar2,b_phong varchar2,b_ma_cb varchar2) return varchar2
as
    b_kq varchar2(1):='K'; b_i1 number; b_ngay date;
begin
-- Dan - Kiem tra phong, nsd dung CC
select count(*),max(ngay_qd) into b_i1,b_ngay from cc_dc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    select count(*) into b_i1 from (select phong,ma_cb from cc_dc where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay_qd=b_ngay)
        where b_phong in(' ',b_phong) and b_ma_cb in(' ',ma_cb);
    if b_i1<>0 then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FVT_MA_QLY(b_ma_dvi varchar2,b_nhom varchar2,b_ma_qly varchar2,b_ma_ts varchar2) return varchar2
as
    b_kq varchar2(30):=' '; b_maM varchar(30); b_maC varchar(30); b_log boolean:=true;
begin
-- Dan - Xac dinh ma con
b_maC:=b_ma_ts;
while b_maC<>' ' loop
    b_kq:=b_maC;
    select nvl(min(ma_ct),' ') into b_maM from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_maC;
    if b_maM=b_ma_qly then b_log:=false; exit; end if;
    b_maC:=b_maM;
end loop;
if b_log and trim(b_ma_qly) is not null then b_kq:=' '; end if;
return b_kq;
end;
/
create or replace function FTS_MA_TS_CAP(b_ma_dvi varchar2,b_ma_ts varchar2) return number
as
    b_kq number:=0; b_maM varchar(30); b_maC varchar(30);
begin
-- Dan - Xac dinh cap
b_maC:=b_ma_ts;
while b_maC<>' ' loop
    b_kq:=b_kq+1;
    select nvl(min(ma_ql),' ') into b_maM from ts_ma_ts where ma_dvi=b_ma_dvi and ma=b_maC;
    b_maC:=b_maM;
end loop;
return b_kq;
end;
/
create or replace function FTS_DUNG(b_ma_dvi varchar2,b_so_the varchar2,b_phong varchar2,b_ma_cb varchar2) return varchar2
as
    b_kq varchar2(1):='K'; b_i1 number; b_ngay date;
begin
-- Dan - Kiem tra don vi, phong, nsd dung TS
select count(*),max(ngay_qd) into b_i1,b_ngay from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the;
if b_i1<>0 then
    select count(*) into b_i1 from (select phong,ma_cb from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_ngay)
        where b_phong in(' ',b_phong) and b_ma_cb in(' ',ma_cb);
    if b_i1<>0 then b_kq:='C'; end if;
end if;
return b_kq;
end;
/
create or replace function FTS_MA_TS_QLY(b_ma_dvi varchar2,b_ma_qly varchar2,b_ma_ts varchar2) return varchar2
as
    b_kq varchar2(30):=' '; b_maM varchar(30); b_maC varchar(30); b_log boolean:=true;
begin
-- Dan - Xac dinh ma con
b_maC:=b_ma_ts;
while b_maC<>' ' loop
    b_kq:=b_maC;
    select nvl(min(ma_ql),' ') into b_maM from ts_ma_ts where ma_dvi=b_ma_dvi and ma=b_maC;
    if b_maM=b_ma_qly then b_log:=false; exit; end if;
    b_maC:=b_maM;
end loop;
if b_log and trim(b_ma_qly) is not null then b_kq:=' '; end if;
return b_kq;
end;
/
create or replace procedure PKT_BP_NHOM_CT
 (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_ct out pht_type.cs_type,cs_nv out pht_type.cs_type)
AS
 b_loi varchar2(100);
begin
-- Dan - CT nhom
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_ct for select * from kt_bp_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
open cs_nv for select nv,loai from kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HOI_KT_LIST_MAt(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
    b_ktra varchar2,b_maN nvarchar2,b_trangkt number,b_trang out number,b_dong out number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lenh varchar2(1000); b_idvung number; a_ch pht_type.a_var;
    b_tu number; b_den number; b_ma_dvi varchar2(20);
    b_ma varchar2(50); b_ten nvarchar2(100);
begin
-- Dan - Liet ke dong tu, den gan dung theo ma va ten
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_CH_ARR(b_ktra,a_ch);
a_ch(1):=lower(a_ch(1));
b_ma_dvi:=FKH_NV_DVI(b_ma_dviN,a_ch(1));
if a_ch.count>3 then
    if a_ch(4)='C' then b_ma_dvi:=FTBH_DVI_TA(); end if;
end if;

if a_ch(1)='ht_ma_nsd' and upper(a_ch(3))='PAS' then b_loi:='loi:Khong xem password:loi'; raise PROGRAM_ERROR; end if;
if b_maN is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_ma:=b_maN||'%'; b_ten:='%'||b_maN||'%';
if a_ch(1)<>'ht_ma_dvi' then
    b_lenh:='select count(*) from '||a_ch(1)||' where ma_dvi= :ma_dvi';
    execute immediate b_lenh into b_dong using b_ma_dvi;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
    execute immediate b_lenh into b_tu using b_ma_dvi,b_ma,b_ten;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where ma_dvi= :ma_dvi order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_ma_dvi,b_tu,b_den;
else
    b_lenh:='select count(*) from '||a_ch(1)||' where idvung= :idvung';
    execute immediate b_lenh into b_dong using b_idvung;
    b_lenh:='select nvl(min(sott),1) from (select '||a_ch(2)||','||a_ch(3)||',row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where '||a_ch(2)||' like :ma or upper('||a_ch(3)||') like :ten';
    execute immediate b_lenh into b_tu using b_idvung,b_ma,b_ten;
    if b_tu=0 then b_tu:=b_dong; end if;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    b_lenh:='select * from (select '||a_ch(2)||' ma,'||a_ch(3)||' ten,row_number() over (order by '||a_ch(2)||
        ') sott from '||a_ch(1)||' where idvung= :idvung order by '||a_ch(2)||') where sott between :tu and :den';
    open cs1 for b_lenh using b_idvung,b_tu,b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
CREATE OR REPLACE PROCEDURE PKT_MA_TK_LKE
 (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
 b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
 b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select count(*) into b_dong from kt_ma_tk where ma_dvi=b_ma_dvi;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from kt_ma_tk
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
end;
/
CREATE OR REPLACE PROCEDURE PKT_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_d number,b_ngay_c number,b_treo varchar2,b_gso varchar2,b_l_ct varchar2,b_nv varchar2,
    b_dc varchar2,b_tk_no varchar2,b_tk_co varchar2,b_tien_d number,b_tien_c number,
    b_t_c varchar2,b_nd nvarchar2,b_nd_c varchar2,b_so_ct varchar2,b_nsd_n varchar2,
    b_dvi varchar2,b_phong varchar2,b_ma_cb varchar2, b_viec varchar2, b_hdong varchar2,b_ma_sp varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_dc0 varchar2(4);
    b_dc1 varchar2(4); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Tim kiem chung tu ke toan
delete kt_tim_temp1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
insert into kt_tim_temp1(n1) select so_id from kt_1 where ma_dvi=b_ma_dvi and
    (ngay_ht between b_ngay_d and b_ngay_c) and htoan in('T',b_treo) and (b_l_ct is null or l_ct=b_l_ct) and
    (b_so_ct is null or upper(so_ct) like b_so_ct) and (b_nsd_n is null or nsd=b_nsd_n);
if b_nv='C' then
    delete kt_tim_temp1 where exists(select * from kt_1 where ma_dvi=b_ma_dvi and so_id=n1 and trim(lk)='');
elsif b_nv<>'K' then
    if b_dc='C' then
        delete kt_tim_temp1 where exists(select * from kt_1 where ma_dvi=b_ma_dvi and so_id=n1 and
            instr(lk,b_nv||':0')=0 and instr(lk,b_nv||':1')=0);
    else
        delete kt_tim_temp1 where exists(select * from kt_1 where ma_dvi=b_ma_dvi and so_id=n1 and (lk is null or instr(lk,b_nv)=0));
    end if;
end if;
if b_dc='C' then
    delete kt_tim_temp1 where exists(select * from kt_1 where ma_dvi=b_ma_dvi and
    so_id=n1 and (lk is null or (instr(lk,'0')=0 and instr(lk,'1')=0)));
end if;
if b_gso='C' then
    delete kt_tim_temp1 where exists(select * from kt_3 where ma_dvi=b_ma_dvi and so_id=n1 and so_id_so<>0);
end if;
if b_nd is not null then
    if b_nd_c='C' then
        delete kt_tim_temp1 where not exists(select * from kt_2 where
            ma_dvi=b_ma_dvi and so_id=n1 and upper(note) like b_nd);
    else    delete kt_tim_temp1 where not exists(select * from kt_1 where
            ma_dvi=b_ma_dvi and so_id=n1 and upper(nd) like b_nd);
    end if;
end if;
if b_tk_no is not null then
    delete kt_tim_temp1 where not exists(select * from kt_2 where
        ma_dvi=b_ma_dvi and so_id=n1 and nv='N' and ma_tk like b_tk_no);
end if;
if b_tk_co is not null then
    delete kt_tim_temp1 where not exists(select * from kt_2 where
        ma_dvi=b_ma_dvi and so_id=n1 and nv='C' and ma_tk like b_tk_co);
end if;
if b_tien_d<>0 or b_tien_c<>0 then
  if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.e18;
  elsif b_tien_d=0 then b_n1:=-1.e18; b_n2:=b_tien_c;
  else b_n1:=b_tien_d; b_n2:=b_tien_c;
  end if;
  if b_t_c='C' then
    delete kt_tim_temp1 where not exists(select * from kt_2 where ma_dvi=b_ma_dvi and so_id=n1 and tien between b_n1 and b_n2);
  else
    delete kt_tim_temp1 where not exists(select * from kt_1 where ma_dvi=b_ma_dvi and so_id=n1 and tien between b_n1 and b_n2);
  end if;
end if;
if b_dvi<>' ' or b_phong<>' ' or b_ma_cb<>' ' or b_viec<>' ' or b_hdong<>' ' or b_ma_sp<>' ' then
    delete kt_tim_temp1 where not exists(select * from kt_bp where ma_dvi=b_ma_dvi and so_id=n1 and
    dvi in(' ',b_dvi) and phong in(' ',b_phong) and ma_cb in(' ',b_ma_cb) and viec in(' ',b_viec) and hdong in(' ',b_hdong) and ma_sp in(' ',b_ma_sp));
end if;
select count(*) into b_dong from kt_tim_temp1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,md,l_ct,so_ct,tien,nd,PKH_SO_CNG(ngay_ht) ngay_htc,lk,nsd,
    row_number() over (order by ngay_ht,l_ct,so_tt) sott from kt_1,kt_tim_temp1
    where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,so_tt) where sott between b_tu and b_den;
end;
/
create or replace procedure PTT_TK_NH
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,
  a_ma pht_type.a_var,a_ma_tk pht_type.a_var,a_md pht_type.a_var,a_nv pht_type.a_var,a_ten pht_type.a_nvar,
  a_tk_md pht_type.a_var,a_tk_ma in out pht_type.a_var,a_tk_nv pht_type.a_var,a_tk_tk pht_type.a_var)
AS
  b_loi varchar2(100); b_idvung number; b_i1 number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if a_ma.count=0 then b_loi:='loi:Nhap nghiep vu chi tiet:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
  if a_ma(b_lp) is null or a_ma(b_lp) not in('TMV','TMN','TGV','TGN','D','P','G','TSE','CSE') then
    b_loi:='loi:Sai loai nghiep vu:loi'; raise PROGRAM_ERROR;
  end if;
  if trim(a_ma_tk(b_lp)) is not null then
    b_loi:='loi:Tai khoan#'||a_ma_tk(b_lp)||'#chua dang ky:loi';
    select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
  end if;
end loop;
PKH_MANG(a_tk_ma);
b_loi:='loi:Loi Table tt_tk:loi';
delete tt_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
b_loi:='loi:Loi Table kh_ma_lct:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md in('TT','SE') and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md in('TT','SE') and ngay=b_ngay;
for b_lp in 1..a_ma.count loop
  insert into tt_tk values(b_ma_dvi,b_ngay,a_ma(b_lp),a_ma_tk(b_lp),b_nsd,b_idvung);
end loop;
for b_lp in 1..a_nv.count loop
  insert into kh_ma_lct values(b_ma_dvi,a_md(b_lp),a_nv(b_lp),b_ngay,a_ten(b_lp),'',b_nsd,b_idvung);
end loop;
for b_lp in 1..a_tk_ma.count loop
  insert into kh_ma_lct_tk values(b_ma_dvi,a_tk_md(b_lp),a_tk_ma(b_lp),b_ngay,b_lp,a_tk_nv(b_lp),a_tk_tk(b_lp),'',b_idvung);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_LCT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma varchar2,
    b_ngay number,b_ten nvarchar2,b_tc varchar2,a_nv in out pht_type.a_var,a_ma_tk in out pht_type.a_var)
AS
    b_loi varchar2(100); b_i1 number; b_c1 varchar2(200); b_c2 varchar2(20); b_c3 varchar2(200); b_md_k varchar2(10):=b_md;
    b_log boolean; b_idvung number; a_ma_tk_xl pht_type.a_var;
begin
-- Dan - Nhap ma loai chung tu
if b_md in('BP','LC') then b_md_k:='KT'; end if;
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT',b_md_k,'Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_md) is null or trim(b_ma) is null or b_ngay is null then
    b_loi:='loi:So lieu nhap sai:loi'; raise PROGRAM_ERROR;
end if;
PKH_MANG(a_nv);
for b_lp in 1..a_nv.count loop
    b_c1:=trim(a_ma_tk(b_lp)); b_c3:=' ';
    if b_c1 is not null then
        PKH_CH_ARR(b_c1,a_ma_tk_xl);
        for b_lp1 in 1..a_ma_tk_xl.count loop
            b_c2:=trim(a_ma_tk_xl(b_lp1));
            if b_c2 is not null then
                select count(*) into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma like trim(b_c2)||'%';
                if b_i1=0 then b_loi:='loi:Chua dang ky tai khoan#'||b_c2||':loi'; raise PROGRAM_ERROR; end if;
                if b_c3=' ' then b_c3:=b_c2; else b_c3:=trim(b_c3)||','||b_c2; end if;
            end if;
        end loop;
    end if;
    if b_c3=' ' then a_nv.delete(b_lp); else a_ma_tk(b_lp):=b_c3; end if;
end loop;
b_loi:='loi:Va cham nguoi su dung:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_ngay;
insert into kh_ma_lct values (b_ma_dvi,b_md,b_ma,b_ngay,b_ten,b_tc,b_nsd,b_idvung);
for b_lp in 1..a_nv.count loop
    insert into kh_ma_lct_tk values(b_ma_dvi,b_md,b_ma,b_ngay,b_lp,a_nv(b_lp),a_ma_tk(b_lp),'',b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_TK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,
    a_ma pht_type.a_var,a_ten_l pht_type.a_nvar,a_loai pht_type.a_var,a_ma_tk pht_type.a_var,a_md in out pht_type.a_var,a_nv pht_type.a_var,
    a_ten pht_type.a_nvar,a_tk_md in out pht_type.a_var,a_tk_ma pht_type.a_var,a_tk_nv pht_type.a_var,a_tk_tk pht_type.a_var)
AS
    b_loi varchar2(100); b_idvung number; b_i1 number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','CN','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if; 
if a_ma.count=0 then b_loi:='loi:Nhap nghiep vu chi tiet:loi'; raise PROGRAM_ERROR; end if; 
for b_lp in 1..a_ma.count loop
    if trim(a_ma(b_lp)) is null or trim(a_ten_l(b_lp)) is null or a_loai(b_lp) is null or a_loai(b_lp) not in('N','C') then
        b_loi:='loi:Sai loai nghiep vu:loi'; raise PROGRAM_ERROR;
    end if;
    if trim(a_ma_tk(b_lp)) is not null then
        b_loi:='loi:Tai khoan#'||a_ma_tk(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
    end if;
end loop;
PKH_MANG(a_md); PKH_MANG(a_tk_md);
b_loi:='loi:Loi Table CN_TK:loi';
delete cn_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
b_loi:='loi:Loi Table kh_ma_lct:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md in('CN','SE') and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md in('CN','SE') and ngay=b_ngay;
for b_lp in 1..a_ma.count loop
    insert into cn_tk values(b_ma_dvi,b_ngay,a_ma(b_lp),a_ten_l(b_lp),a_loai(b_lp),a_ma_tk(b_lp),b_nsd,b_lp,b_idvung);
end loop;
for b_lp in 1..a_md.count loop
    insert into kh_ma_lct values(b_ma_dvi,a_md(b_lp),a_nv(b_lp),b_ngay,a_ten(b_lp),'',b_nsd,b_idvung);
end loop;
for b_lp in 1..a_tk_md.count loop
    insert into kh_ma_lct_tk values(b_ma_dvi,a_tk_md(b_lp),a_tk_ma(b_lp),b_ngay,b_lp,a_tk_nv(b_lp),a_tk_tk(b_lp),'',b_idvung);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 /
 create or replace procedure PVT_MA_NHOM_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem ma nhom vat tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from vt_ma_nhom where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 /
 create or replace procedure PVT_MA_CL_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- Xem ma chat luong
open cs_lke for select * from vt_ma_cl where ma_dvi=b_ma_dvi order by ma;

end;

 /
 create or replace procedure PVT_MA_NHOM_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100);
begin
-- Dan - Xem ma nhom vat tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from vt_ma_nhom where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 /
 create or replace procedure PVT_MA_DVT_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- Dan - Liet ke
open cs_lke for select * from vt_ma_dvt where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PVT_MA_KHO_LKE
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem ma kho
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,gon,ma_tk,pp,thu_kho,ma_ct,nsd
	from (select * from vt_ma_kho where ma_dvi=b_ma_dvi order by ma) start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 /
 create or replace procedure PKT_KH_TTT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ps varchar2,b_nv varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_ps,'NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from kt_kh_ttt where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv order by bt;
end;
/
create or replace procedure PVT_TK_NH
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,
  a_nv pht_type.a_var,a_ten pht_type.a_nvar,
  a_tk_ma in out pht_type.a_var,a_tk_nv pht_type.a_var,a_tk_tk pht_type.a_var,
  a_lq_ma in out pht_type.a_var,a_lq_tk pht_type.a_var)
AS
  b_loi varchar2(100); b_idvung number; b_i1 number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if a_nv.count=0 then b_loi:='loi:Nhap nghiep vu chi tiet:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_nv.count loop
  if trim(a_nv(b_lp)) is null or trim(a_ten(b_lp)) is null then
    b_loi:='loi:Sai loai nghiep vu:loi'; raise PROGRAM_ERROR;
  end if;
end loop;
PKH_MANG(a_tk_ma); PKH_MANG(a_lq_ma);
for b_lp in 1..a_lq_ma.count loop
  if a_lq_ma(b_lp) is null or a_lq_tk(b_lp) is null then
    b_loi:='loi:Sai tai khoan lien quan dong#'||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
  end if;
  b_loi:='loi:Tai khoan#'||a_lq_tk(b_lp)||'#chua dang ky:loi';
  select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_lq_tk(b_lp);
end loop;
for b_lp in 1..a_tk_ma.count loop
  if a_tk_ma(b_lp) is null or a_tk_nv(b_lp) is null then
    b_loi:='loi:Sai dinh khoan dong#'||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
  end if;
end loop;
b_loi:='loi:Loi Table kh_ma_lct:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md in('VT','VTL') and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md='VT' and ngay=b_ngay;
for b_lp in 1..a_nv.count loop
  insert into kh_ma_lct values(b_ma_dvi,'VT',a_nv(b_lp),b_ngay,a_ten(b_lp),'',b_nsd,b_idvung);
end loop;
for b_lp in 1..a_tk_ma.count loop
  insert into kh_ma_lct_tk values(b_ma_dvi,'VT',a_tk_ma(b_lp),b_ngay,b_lp,a_tk_nv(b_lp),a_tk_tk(b_lp),'',b_idvung);
end loop;
for b_lp in 1..a_lq_ma.count loop
  insert into kh_ma_lct_tk values(b_ma_dvi,'VTL',a_lq_ma(b_lp),b_ngay,b_lp,'K',a_lq_tk(b_lp),'',b_idvung);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NV_TSO_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,a_ma in out pht_type.a_var,a_tso pht_type.a_var)
AS
     b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,b_md,b_nv,'Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_md is null or b_nv is null then b_loi:='loi:Nhap Modul, nghiep vu:loi'; end if;
PKH_MANG(a_ma);
delete kh_nv_tso where ma_dvi=b_ma_dvi and md=b_md and nv=b_nv;
for b_lp in 1..a_ma.count loop
    insert into kh_nv_tso values(b_ma_dvi,b_nsd,b_md,b_nv,a_ma(b_lp),a_tso(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_TH_LAI(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay date)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number; b_so_id number; b_ng_m date; b_ngayd date; b_ngayc date;
    b_nggia_dk number; b_nggia_bd number; b_nggia_ck number; b_kh_dk number; b_kh_bd number; b_kh_ck number;
begin 
-- Dan - Tong hop phan bo
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','CC','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select max(ngay) into b_ngayd from cc_kh where ma_dvi=b_ma_dvi and ngay<b_ngay;
if b_ngayd is null then b_ngayd:=trunc(b_ngay,'MONTH'); else b_ngayd:=last_day(b_ngayd)+1; end if;
delete cc_kh where ma_dvi=b_ma_dvi and ngay>b_ngayd;
while b_ngayd<=b_ngay loop
    b_ngayc:=last_day(b_ngayd);
    for r_lp in (select so_id,ngay_ht,ngay_kt,von from cc_sc where ma_dvi=b_ma_dvi and ngay_kt>=b_ngayd) loop
        if r_lp.ngay_ht<=b_ngayc then
            b_so_id:=r_lp.so_id; b_kh_bd:=0;
            select max(ngay) into b_ng_m from cc_kh where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay<b_ngayd;
            if b_ng_m is null then
                b_nggia_dk:=0; b_kh_dk:=0;
            else
                select nggia_ck,kh_ck into b_nggia_dk,b_kh_dk from cc_kh where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay=b_ng_m;
            end if;
            if r_lp.ngay_kt between b_ngayd and b_ngayc then
                b_nggia_bd:=b_kh_dk-b_nggia_dk; b_nggia_ck:=b_kh_dk;
            else
                select nvl(sum(tien),0) into b_nggia_bd from cc_bd where ma_dvi=b_ma_dvi and so_id=b_so_id and ngay between b_ngayd and b_ngayc;
                if r_lp.ngay_ht between b_ngayd and b_ngayc then b_nggia_bd:=b_nggia_bd+r_lp.von; end if;
                b_nggia_ck:=b_nggia_dk+b_nggia_bd;
                if b_kh_dk<>0 and b_kh_dk=b_nggia_dk then
                    b_kh_bd:=b_nggia_bd;
                else
                    PCC_TINH_PB(b_ma_dvi,b_so_id,b_ngayd,b_ngayc,b_kh_bd,b_i1,b_loi);
                    if b_loi is not null then raise PROGRAM_ERROR; end if;
                    if b_i1=0 then
                        b_kh_bd:=b_nggia_ck-b_kh_dk;
                    elsif b_kh_bd<>0 and b_nggia_ck<>r_lp.von then
                        b_kh_bd:=round((b_nggia_ck-b_kh_dk)*b_kh_bd/b_i1,0);
                    end if;
                end if;
            end if;
            if b_nggia_bd<>0 or b_kh_bd<>0 then
                b_kh_ck:=b_kh_dk+b_kh_bd;
                insert into cc_kh values(b_ma_dvi,b_so_id,b_ngayc,b_nggia_dk,b_nggia_bd,b_nggia_ck,b_kh_dk,b_kh_bd,b_kh_ck,b_idvung);
            end if;
        end if;
    end loop;
    commit;
    b_ngayd:=add_months(b_ngayd,1);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 
/
create or replace procedure PCC_TINH_PB
    (b_ma_dvi varchar2,b_so_id number,b_ngayd date,b_ngayc date,b_pb out number,b_con out number,b_loi out varchar2)
AS
    b_i1 number:=0; a_ngay pht_type.a_date; a_tien pht_type.a_num;
begin
PKH_MANG_KD_D(a_ngay); PKH_MANG_KD_N(a_tien);
for r_lp in(select ngay,tien from cc_ch where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay) loop
    b_i1:=b_i1+1;
    a_ngay(b_i1):=r_lp.ngay; a_tien(b_i1):=r_lp.tien;
end loop;
if b_i1=0 then
    PCC_ID_KY(b_ma_dvi,b_so_id,a_ngay,a_tien,b_loi);
    if b_loi is not null then return; end if;
end if;
for r_lp in (select ngayd,ngayc from cc_du where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngayd) loop
    if r_lp.ngayc<'01-Jan-3000' then
        b_i1:=months_between(r_lp.ngayc,r_lp.ngayd)+1;
        for b_lp in 1..a_ngay.count loop
            if a_ngay(b_lp)>=r_lp.ngayd then a_ngay(b_lp):=add_months(a_ngay(b_lp),b_i1); end if;
        end loop;
    else
        for b_lp in 1..a_ngay.count loop
            if a_ngay(b_lp)>=r_lp.ngayd then a_ngay(b_lp):='01-Jan-3000'; end if;
        end loop;
        exit;
    end if;
end loop;
b_pb:=0; b_con:=0;
for b_lp in 1..a_ngay.count loop
    if a_ngay(b_lp) between b_ngayd and b_ngayc then b_pb:=b_pb+a_tien(b_lp); end if;
    if a_ngay(b_lp)>=b_ngayd then b_con:=b_con+a_tien(b_lp); end if;
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PCC_ID_KY(b_ma_dvi varchar2,b_so_id number,a_ngay out pht_type.a_date,a_tien out pht_type.a_num,b_loi out varchar2)
AS
    b_ngay_ht date; b_han number; b_kieu varchar2(1); b_von number; b_nhom varchar2(5); b_ma_vt varchar2(30);
begin
b_loi:='loi:Loi tinh phan bo:loi';
select ngay_ht,von,nhom,ma_vt into b_ngay_ht,b_von,b_nhom,b_ma_vt from cc_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
select kieu,han into b_kieu,b_han from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma_vt;
PCC_TINH_KY(b_ngay_ht,0,b_han,b_kieu,b_von,a_ngay,a_tien);
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
 
/
create or replace procedure PCC_TINH_KY
    (b_ngay_ht date,b_chi_g number,b_han number,b_kieu varchar2,b_von number,a_ngay out pht_type.a_date,a_tien out pht_type.a_num)
AS
    b_lech number:=b_von; b_i1 number; b_i2 number; b_kt number:=0;
    b_han_sd date; b_kymoi date:=trunc(b_ngay_ht); b_chi number:=b_chi_g;
begin
-- Dan - Tinh ky phan bo
PKH_MANG_KD_D(a_ngay); PKH_MANG_KD_N(a_tien);
if b_kieu='D' then
    if b_chi=0 then b_chi:=round(b_von/b_han,0); end if;
    b_i1:=b_kymoi-trunc(b_kymoi,'MONTH');
    if b_i1<>0 then
        b_i2:=last_day(b_kymoi)-trunc(b_kymoi,'MONTH')+1;
        b_i1:=round(b_chi*(b_i2-b_i1)/b_i2,0);
        if b_lech-b_i1<5000 then b_i1:=b_lech; end if;
        b_kt:=b_kt+1; a_ngay(b_kt):=b_kymoi; a_tien(b_kt):=b_i1;
        b_lech:=b_lech-b_i1; b_kymoi:=add_months(b_kymoi,1);
    end if;
    while b_lech>0 loop
        if b_lech-b_chi<5000 then b_chi:=b_lech; end if;
        b_kt:=b_kt+1; a_ngay(b_kt):=b_kymoi; a_tien(b_kt):=b_chi;
        b_lech:=b_lech-b_chi; b_kymoi:=add_months(b_kymoi,1);
    end loop;
else
    if b_chi=0 then b_chi:=round(.5*b_von,0); end if;
    b_han_sd:=add_months(b_kymoi,b_han);
    while b_kymoi<b_han_sd and b_lech>500000 loop
        b_kt:=b_kt+1; a_ngay(b_kt):=b_kymoi; a_tien(b_kt):=b_chi;
        b_lech:=b_lech-b_chi; b_kymoi:=add_months(b_kymoi,12); b_chi:=round(.5*b_chi,0);
    end loop;
    if b_lech<> 0 then
        b_kt:=b_kt+1; a_ngay(b_kt):=b_han_sd; a_tien(b_kt):=b_lech;
     end if;
end if;
end;
 
/
create or replace procedure PCC_TH_HTOAN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number)
AS
    b_ngay date; b_ngayd date; b_ngayc date; b_idvung number; b_so_id number; b_kt number:=0; b_bt number:=0; b_lk varchar2(100);
    b_loi varchar2(100); b_i1 number; b_i2 number; b_tien number; b_log boolean; b_phong varchar2(10); b_ch varchar2(50);
    b_ma_tk varchar2(20); b_ma_tkG varchar2(20); b_so_ct varchar2(20):=' '; b_dviG varchar2(20); b_dvi_sd varchar2(20);
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num; a_note pht_type.a_nvar; a_bt pht_type.a_num;
    a_sp_bt pht_type.a_num; a_nhom pht_type.a_var; a_ma_ttr pht_type.a_var; a_ma_lvuc pht_type.a_var;
    a_dvi pht_type.a_var; a_phong pht_type.a_var; a_ma_cb pht_type.a_var; a_hdong pht_type.a_var;
    a_viec pht_type.a_var; a_ma_cd pht_type.a_var; a_ma_sp pht_type.a_var; a_sp_tien pht_type.a_num; a_thue pht_type.a_num;
    a_ma_tk_xl pht_type.a_var; a_ma_tke_xl pht_type.a_var; a_tien_xl pht_type.a_num;
    a_ma_nt pht_type.a_var; a_tygia pht_type.a_num; a_sp_nd pht_type.a_nvar; a_ch pht_type.a_var;
begin
-- Dan - Hach toan
delete temp_1; delete temp_2; delete temp_3; delete temp_4; delete ket_qua; commit;
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_ht is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_ngay:=PKH_SO_CDT(b_ngay_ht); b_ngayd:=trunc(b_ngay,'MONTH'); b_ngayc:=last_day(b_ngay);
b_ch:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'PB','C',b_ngay_ht,'N'); PKH_CH_ARR(b_ch,a_ch);
b_ma_tkG:=FKH_ARR_MIN(a_ch); PKH_MANG_KD(a_ma_tk_xl);
for r_lp2 in (select so_id,sum(kh_bd) kh_bd from cc_kh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc group by so_id) loop
    select ma_tk into b_ma_tk from cc_sc where ma_dvi=b_ma_dvi and so_id=r_lp2.so_id;
    if trim(b_ma_tk) is null then b_ma_tk:=b_ma_tkG; end if;
    b_i2:=r_lp2.kh_bd; PKH_MANG_XOA(a_ma_tk_xl); b_kt:=0; b_log:=false;
    insert into ket_qua(c1,n1) values(b_ma_tk,b_i2);
    select count(*) into b_i1 from cc_pb where ma_dvi=b_ma_dvi and so_id=r_lp2.so_id and bt<1000;

    if b_i1=0 then b_loi:='loi:Cong cu#'||FCC_SO_ID_THE(b_ma_dvi,r_lp2.so_id)||'#chua khai phan bo tai khoan:loi'; raise PROGRAM_ERROR; end if;
    for r_lp in (select ma_tk,ma_tke,pt from cc_pb where ma_dvi=b_ma_dvi and so_id=r_lp2.so_id and bt<1000) loop
        b_kt:=b_kt+1; b_tien:=round(r_lp2.kh_bd*r_lp.pt/100,0);
        a_ma_tk_xl(b_kt):=r_lp.ma_tk; a_ma_tke_xl(b_kt):=r_lp.ma_tke; a_tien_xl(b_kt):=b_tien;
        if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,'T',r_lp.ma_tk) then b_log:=true; end if;
        b_i2:=b_i2-b_tien;
    end loop;
    a_tien_xl(b_kt):=a_tien_xl(b_kt)+b_i2;
    if b_log then
        for b_lp in 1..b_kt loop
            b_i2:=a_tien_xl(b_lp);
            select count(*) into b_i1 from cc_pb where ma_dvi=b_ma_dvi and so_id=r_lp2.so_id and bt>1000;
            if b_i1=0 then
                insert into temp_1(c1,c2,c3,c4,n1) values(a_ma_tk_xl(b_lp),a_ma_tke_xl(b_lp),' ',' ',a_tien_xl(b_lp));
            else
                for r_lp in (select ma_tk phong,ma_tke sp,pt from cc_pb where ma_dvi=b_ma_dvi and so_id=r_lp2.so_id and bt>1000) loop
                    b_i1:=b_i1-1; b_tien:=round(a_tien_xl(b_lp)*r_lp.pt/100,0);
                    if b_i1=0 or abs(b_tien)>abs(b_i2) then b_tien:=b_i2; end if;
                    b_i2:=b_i2-b_tien;
                    insert into temp_1(c1,c2,c3,c4,n1) values(a_ma_tk_xl(b_lp),a_ma_tke_xl(b_lp),r_lp.phong,r_lp.sp,b_tien);
                end loop;
            end if;
        end loop;
    else
        for b_lp in 1..b_kt loop
            insert into temp_1(c1,c2,c3,c4,n1) values(a_ma_tk_xl(b_lp),a_ma_tke_xl(b_lp),' ',' ',a_tien_xl(b_lp));
        end loop;
    end if;
end loop;
b_kt:=0; b_bt:=0;
insert into temp_2(c1,c2,c3,c4,n1) select c1,c2,c3,c4,sum(n1) from temp_1 group by c1,c2,c3,c4 having sum(n1)<>0;
insert into temp_3(c1,c2) select distinct c1,c2 from temp_2;
for r_lp in(select c1 ma_tk,c2 ma_tke from temp_3) loop
    b_kt:=b_kt+1;
    a_nv(b_kt):='N'; a_ma_tk(b_kt):=r_lp.ma_tk; a_ma_tke(b_kt):=r_lp.ma_tke; a_note(b_kt):=' '; a_bt(b_kt):=b_kt;
    select sum(n1) into a_tien(b_kt) from temp_2 where c1=r_lp.ma_tk and c2=r_lp.ma_tke;
    for r_lp1 in (select c3 phong,c4 sp,n1 tien from temp_2 where c1=r_lp.ma_tk and c2=r_lp.ma_tke order by c3,c4) loop
        b_bt:=b_bt+1;
        a_sp_bt(b_bt):=b_kt; a_dvi(b_bt):=' '; a_phong(b_bt):=r_lp1.phong; a_hdong(b_bt):=' ';
        a_ma_cb(b_bt):=' '; a_viec(b_bt):=' '; a_ma_sp(b_bt):=r_lp1.sp; a_sp_tien(b_bt):=r_lp1.tien; a_thue(b_bt):=0;
        a_nhom(b_bt):=FKT_BP_NHOM(b_ma_dvi,r_lp1.phong,r_lp1.sp);
        a_ma_ttr(b_bt):=' '; a_ma_lvuc(b_bt):=' ';
    end loop;
end loop;
for r_lp in(select c1 ma_tk,sum(n1) tien from ket_qua group by c1 having sum(n1)<>0) loop
    b_kt:=b_kt+1;
    a_nv(b_kt):='C'; a_ma_tk(b_kt):=r_lp.ma_tk; a_ma_tke(b_kt):=' '; a_tien(b_kt):=r_lp.tien; a_note(b_kt):=' '; a_bt(b_kt):=b_kt;
end loop;
if b_kt<>0 then
    b_i1:=0; PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PKT_KT_NH(b_ma_dvi,b_nsd,'H',b_ngay_ht,' ',b_i1,b_so_ct,' ','Tong hop phan bo cong cu',' ',
        a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'KT',b_lk,b_loi,'C');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    if b_bt<>0 then
        PKT_CT_BP_NH(b_ma_dvi,'','',b_so_id,a_sp_bt,a_nhom,a_ma_ttr,a_ma_lvuc,a_dvi,a_phong,a_ma_cb,a_viec,a_hdong,a_ma_sp,a_sp_tien,'K','K');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    b_loi:='loi:Khong phat sinh phan bo cong cu:loi'; raise PROGRAM_ERROR;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FCC_SO_ID_THE(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_the varchar2(20);
begin
    select min(so_the) into b_so_the from cc_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
    return b_so_the;
end;
 
/
create or replace function FKT_BP_NHOM(b_ma_dvi varchar2,b_phong varchar2,b_sp varchar2) return varchar2
AS
    b_kq varchar2(10):=' '; b_i1 number; b_i2 number;
begin
for r_lp in (select ma from kt_bp_nhom where ma_dvi=b_ma_dvi) loop
    select count(*) into b_i1 from kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=r_lp.ma and nv='phong';
    select count(*) into b_i2 from kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=r_lp.ma and nv='ma_sp';
    if (trim(b_phong) is null and b_i1=0 and b_i2=1) or (trim(b_sp) is null and b_i1=2 and b_i2=0)
        or (trim(b_phong) is not null and trim(b_sp) is not null and b_i1=1 and b_i2=1) then
        b_kq:=r_lp.ma; exit;
    end if;
end loop;
return b_kq; 
end;
/create or replace procedure PKT_CT_BP_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,a_bt in out pht_type.a_num,
    a_nhom pht_type.a_var,a_ma_ttr pht_type.a_var,a_ma_lvuc pht_type.a_var,a_dvi pht_type.a_var,a_phong pht_type.a_var,
    a_ma_cb pht_type.a_var,a_viec pht_type.a_var,a_hdong pht_type.a_var,a_ma_sp pht_type.a_var,a_tien pht_type.a_num,b_comm varchar2:='C',b_pbo varchar2:='K')
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_i3 number; b_lk varchar2(100); b_idvung number;b_vung varchar2(10):='';
    b_ngay_ht number; b_nv varchar2(1); b_ma_tk varchar2(20); b_tt varchar2(1):='0'; b_tc varchar2(1); b_l_ct varchar2(10);
begin
-- Dan - Phan bo bo phan
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','N');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht,lk,idvung,nvl(l_ct,' ') into b_ngay_ht,b_lk,b_idvung,b_l_ct from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sqlcode<>0 or sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if instr(b_lk,'BP')=0 then b_loi:='loi:Khong phai chung tu phan bo bo phan:loi'; raise PROGRAM_ERROR; end if;
if instr(b_lk,'TK:0')<>0 or instr(b_lk,'TK:1')<>0 then b_loi:='loi:Nhap thong ke truoc phan bo bo phan:loi'; raise PROGRAM_ERROR; end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for b_lp in 1..a_bt.count loop
    b_loi:='loi:Da xoa but toan #'||to_char(b_lp)||':loi';
    select nv,ma_tk,tien into b_nv,b_ma_tk,b_i2 from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp);
    if FKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,b_nv,b_ma_tk)='K' and
         ((b_nv='N' and b_l_ct<>'KC/N') or (b_nv='C' and b_l_ct<>'KC/C')) then
        b_loi:='loi:Phat sinh #'||b_nv||'#tai khoan #'||trim(b_ma_tk)||'# khong phan bo bo phan:loi';
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
    if a_ma_ttr(b_lp) is null or a_ma_lvuc(b_lp) is null or a_dvi(b_lp) is null or a_phong(b_lp) is null or
        a_ma_cb(b_lp) is null or a_viec(b_lp) is null or a_hdong(b_lp) is null or a_ma_sp(b_lp) is null or a_tien(b_lp) is null or a_tien(b_lp)=0 then
        b_loi:='loi:Sai so lieu phan bo tai khoan #'||trim(b_ma_tk)||':loi';
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
    if trim(a_nhom(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma nhom #'||trim(a_nhom(b_lp))||':loi';
        select 0 into b_i1 from kt_bp_nhom where ma_dvi=b_ma_dvi and ma=a_nhom(b_lp);
    end if;
    if trim(a_ma_ttr(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma thi truong#'||trim(a_ma_ttr(b_lp))||':loi';
        select 0 into b_i1 from kh_ma_ttu where ma_dvi=b_ma_dvi and ma=a_ma_ttr(b_lp);
    end if;
    if trim(a_ma_lvuc(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma linh vuc#'||trim(a_ma_lvuc(b_lp))||':loi';
        select 0 into b_i1 from kh_ma_lvuc where ma_dvi=b_ma_dvi and ma=a_ma_lvuc(b_lp);
    end if;
    if trim(a_dvi(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma don vi#'||trim(a_dvi(b_lp))||':loi';
        select 0 into b_i1 from ht_ma_dvi where idvung=b_idvung and ma_goc=a_dvi(b_lp);
    end if;
    if trim(a_phong(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma bo phan#'||trim(a_phong(b_lp))||':loi';
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
        if FHT_MA_PHONG_CT(b_ma_dvi,a_phong(b_lp))<>'C' then
            b_loi:='loi:Khong phan bo phong bac cao:loi';
        end if;
    end if;
    if trim(a_ma_cb(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma can bo#'||trim(a_ma_cb(b_lp))||':loi';
        select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=a_ma_cb(b_lp);
    end if;
    if trim(a_viec(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma viec#'||trim(a_viec(b_lp))||':loi';
        select 0 into b_i1 from kh_ma_viec where ma_dvi=b_ma_dvi and ma=a_viec(b_lp);
    end if;
    if trim(a_hdong(b_lp)) is not null then
        b_loi:='loi:Chua dang ky ma hop dong#'||trim(a_hdong(b_lp))||':loi';
        select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=a_hdong(b_lp);
    end if;
    /*
    if FKH_VIEC_HDONG(b_ma_dvi,a_viec(b_lp),a_hdong(b_lp))<>'C' then
        b_loi:='loi:Ma viec '||a_viec(b_lp)||' va ma hop dong '||a_hdong(b_lp)||' khong dong bo:loi'; raise PROGRAM_ERROR;
    end if;
    */
    if trim(a_ma_sp(b_lp)) is not null then
        b_loi:='loi:Nhap sai san pham#'||trim(a_ma_sp(b_lp))||':loi';
        select tc into b_tc from sx_ma_sp where ma_dvi=b_ma_dvi and ma=a_ma_sp(b_lp);
        if b_tc<>'C' then raise PROGRAM_ERROR; end if;
    end if;
    if b_tt<>'1' then
        b_i1:=1; b_i3:=b_lp+1;
        for b_lp2 in b_i3..a_bt.count loop
            if a_bt(b_lp)=a_bt(b_lp2) then b_i1:=0; exit; end if;
        end loop;
        if b_i1>0 then
            b_i1:=0;
            for b_lp2 in 1..b_lp loop
                if a_bt(b_lp)=a_bt(b_lp2) then b_i1:=b_i1+a_tien(b_lp2); end if;
            end loop;
            if b_i2=b_i1 then b_tt:='2'; else b_tt:='1'; end if;
        end if;
    end if;
end loop;
if b_tt=2 then
    for b_lp in 1..a_bt.count loop
        for r_lp in(select nv,loai from kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=a_nhom(b_lp)) loop
            b_loi:='';
            if r_lp.nv='ma_ttr' and trim(a_ma_ttr(b_lp)) is null then b_loi:='thi truong';
            elsif r_lp.nv='ma_lvuc' and trim(a_ma_lvuc(b_lp)) is null then b_loi:='linh vuc';
            elsif r_lp.nv='dvi' and trim(a_dvi(b_lp)) is null then b_loi:='don vi';
            elsif r_lp.nv='phong' and trim(a_phong(b_lp)) is null then b_loi:='bo phan';
            elsif r_lp.nv='ma_cb' and trim(a_ma_cb(b_lp)) is null then b_loi:='Can bo';
            elsif r_lp.nv='hdong' and trim(a_hdong(b_lp)) is null  then b_loi:='so hop dong';
            elsif r_lp.nv='ma_sp' and trim(a_ma_sp(b_lp)) is null then b_loi:='san pham';
            end if;
            if b_loi is not null then
                if r_lp.loai='B' then
                    b_loi:='loi: Dong '||b_lp||' phai nhap '||b_loi||':loi'; raise PROGRAM_ERROR;
                else
                    b_tt:='1'; exit;
                end if;
            end if;
        end loop;
        if b_tt<>'2' then exit; end if;
    end loop;
end if;
if b_pbo='K' then
    PKT_CT_BP_XOA_XOA(b_ma_dvi,b_so_id,b_loi);
else
    PKT_CT_BP_XOA_PBO(b_ma_dvi,b_so_id,a_bt,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_idvung<>0 then b_vung:=trim(to_char(b_idvung))||'_'; end if;
for b_lp in 1..a_bt.count loop
    insert into kt_bp values(b_ma_dvi,b_so_id,a_bt(b_lp),b_ngay_ht,a_nhom(b_lp),a_ma_ttr(b_lp),a_ma_lvuc(b_lp),
        a_dvi(b_lp),a_phong(b_lp),a_ma_cb(b_lp),a_viec(b_lp),a_hdong(b_lp),a_ma_sp(b_lp),a_tien(b_lp),b_lp,b_idvung);
end loop;
if b_tt='2' then
    for r_lp in (select nv,ma_tk,bt from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_i1:=1;
    for b_lp in 1..a_bt.count loop
        if a_bt(b_lp)=r_lp.bt then b_i1:=0; exit; end if;
    end loop;
    if b_i1>0 then
        b_nv:=r_lp.nv; b_ma_tk:=r_lp.ma_tk;
        if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,b_nv,b_ma_tk) then b_tt:='1'; exit; end if;
    end if;
    end loop;
end if;
PKT_LKET_NV(b_ma_dvi,'BP',b_so_id,b_tt,b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_BP_THOP(b_ma_dvi,'N',b_so_id,b_loi); 
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 
/
create or replace function FKH_MA_LCT_TRA_LQ
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number,b_nv varchar2,b_ma_tk varchar2) return varchar2
AS
    b_kq varchar2(1):='K'; a_nv pht_type.a_var; a_ma_tk pht_type.a_lvar;
begin
-- Dan - Xac dinh tai khoan cua nghiep vu
PKH_MA_LCT_NVTK(b_ma_dvi,b_md,b_ma,b_ngay,a_nv,a_ma_tk);
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp) in('T',b_nv) and PKH_MA_LMA_C(a_ma_tk(b_lp),b_ma_tk)='C' then b_kq:='C'; exit; end if;
end loop;
return b_kq;
end;
 
/
create or replace function FHT_MA_PHONG_CT (b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; b_i1 number;
begin
-- Dan - Ktra phong chi tiet
select count(*) into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if b_i1<>0 then b_kq:='K'; end if;
return b_kq;
end;
/
create or replace procedure PKT_CT_BP_XOA_XOA
    (b_ma_dvi varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_ngay_ht number;
begin
--- Dan - Phan bo bo phan
select nvl(min(ngay_ht),0) into b_ngay_ht from kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ngay_ht<>0 then
    select nvl(min(ngay_ht),0) into b_i1 from kt_bp_qly where ma_dvi=b_ma_dvi and ngay_ht>=b_ngay_ht;
    if b_i1=0 then
        select nvl(min(ngay_ht),0) into b_i1 from kt_bp_goc where ma_dvi=b_ma_dvi and ngay_ht>=b_ngay_ht;
    end if;
    if b_i1<>0 then
        b_loi:='loi:Da tong hop phan bo chi phi den ngay '||PKH_SO_CNG(b_i1)||':loi'; return;
    end if;
    PKT_BP_THOP(b_ma_dvi,'X',b_so_id,b_loi);
    if b_loi is not null then return; end if;
end if;
delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_BP_XOA_PBO
    (b_ma_dvi varchar2,b_so_id number,a_bt pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
begin
--- Dan - Phan bo bo phan
PKT_BP_THOP(b_ma_dvi,'X',b_so_id,b_loi);
if b_loi is not null then return; end if;
for b_lp in 1..a_bt.count loop
    delete kt_bp where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=a_bt(b_lp);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
 
 /
 create or replace procedure PTS_KH_PTT(b_ma_dvi varchar2,b_so_the varchar2,b_ngay date,
  b_tg_kh number,b_ppt out varchar2,b_nam out number,b_tcon out number,b_loi out varchar2)
AS
  b_i1 number; b_ngbd date; b_ngd date; b_ngc date; b_ma_ts varchar2(10);
  b_kieu varchar2(2); b_con_khao number:=0; b_nggia_dk number; b_kh_dk number;
begin
-- Dan - Phuong thuc tinh KH
b_loi:='loi:Loi tim kieu khau hao the#'||b_so_the||':loi';
select count(*),max(ngay) into b_i1,b_ngbd from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<=b_ngay and b_con_khao<>0;
if b_i1<>0 then
  select ma_ts,kieu,con_khao into b_ma_ts,b_kieu,b_con_khao from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngbd;
else
  select ma_ts,kieu into b_ma_ts,b_kieu from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
end if;
select count(*),max(ngay) into b_i1,b_ngc from ts_ma_ts_kh where ma_dvi=b_ma_dvi and ma=b_ma_ts and kieu=b_kieu and ngay<=b_ngay;
if b_i1=0 then b_loi:='loi:Ma TS:'||b_ma_ts||'#kieu KH:'||b_kieu||'#chua dang ky:loi'; return; end if;
select ppt,nam into b_ppt,b_nam from ts_ma_ts_kh where ma_dvi=b_ma_dvi and ma=b_ma_ts and kieu=b_kieu and ngay=b_ngc;
b_tcon:=b_nam*12-b_tg_kh;
if b_ppt='N' and (b_con_khao=0 or b_ngc>b_ngbd) then
  select count(*),max(ngay) into b_i1,b_ngd from ts_kh where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<b_ngc;
  if b_i1<>0 then
    select nvl(sum(nggia_ck),0),nvl(sum(kh_ck),0) into b_nggia_dk,b_kh_dk
      from ts_kh where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngd;
    if b_nggia_dk<>0 then
      b_tcon:=round(b_nam*12*(1-b_kh_dk/b_nggia_dk),0)-months_between(b_ngay,trunc(b_ngd,'MONTH'));
    end if;
  end if;
elsif b_con_khao<>0 then
  b_nam:=b_con_khao; b_tcon:=b_nam*12-months_between(b_ngay,trunc(b_ngbd,'MONTH'));
end if;
if b_tcon<0 then b_tcon:=0; end if;
b_loi:='';
end;
/
create or replace procedure PTS_KH_TH
	(b_ma_dvi varchar2,b_so_the varchar2,b_ngc date,b_loi out varchar2)
AS
	b_i1 number; b_i2 number; b_i3 number; b_d1 date; b_d2 date; b_d3 date; b_them number:=0;
	b_dvid varchar2(10); b_dvic varchar2(10); b_ngd date; b_ngt date; b_ngn date;
	b_ppt varchar2(1); b_nam number; b_ng_kh date; b_tg_kh number; b_tcon number; b_ma_ng varchar2(5);
	b_lbd varchar2(1); b_tckhao varchar2(1); b_xl varchar2(1); b_idvung number;
	b_nggia_dk number; b_nggia_bd number; b_nggia_bs number; b_nggia_ck number; b_ng_cu number;
	b_kh_dk number; b_kh_bd number; b_kh_bs number; b_kh_th number; b_kh_ck number; b_so_ngkh number:=0;
begin
-- Dan - Tong hop nguyen gia,khao hao theo nguon tung thang
--	b_ma_ng - Ma nguon.
--	b_nggia_dk,b_nggia_ck,b_nggia_bd,b_nggia_bs - Ng.gia dau, cuoi ky, b.dong ng.gia trong, sau ky
--	b_kh_dk,b_kh_ck,b_kh_th,b_kh_bd,b_kh_bs - Luy ke khau hao den dau, cuoi ky, k.hao thang, b.dong l.ke k.hao trong, sau ky
select tg_kh,ng_kh,idvung into b_tg_kh,b_ng_kh,b_idvung from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
b_ngd:=trunc(b_ngc,'MONTH'); b_ngt:=b_ngd-1; b_ngn:=trunc(b_ngd,'YEAR')-1;
if b_ng_kh<=b_ngc then
	b_d1:=b_ng_kh;
	if b_ng_kh<b_ngd then
		select count(*) into b_i1 from ts_kh where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<b_ngd;
		if b_i1<>0 then
			b_d1:=b_ngd; b_d3:=trunc(b_ng_kh,'MONTH');
			b_them:=(b_ng_kh-b_d3)/((last_day(b_ng_kh)-b_d3)+1);
			b_tg_kh:=b_tg_kh+months_between(b_ngd,b_d3);
		end if;
	end if;
	b_d3:=trunc(b_d1,'MONTH'); b_i3:=0;
	if b_d1<>b_d3 then
		b_i3:=1-(b_d1-b_d3)/((last_day(b_d1)-b_d3)+1);
		b_d1:=add_months(b_d3,1); b_d3:=b_d1;
	end if;
	if b_d1<b_ngc then
		select count(*),max(ngay) into b_i1,b_d2 from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay<=b_d1;
		if b_i1<>0 then
			select khao into b_tckhao from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_d2;
		else
			b_tckhao:='K';
		end if;
		for r_lp in(select ngay,khao from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay between b_d1 and b_ngc) loop
			if r_lp.khao<>b_tckhao then
				if b_tckhao='K' then b_so_ngkh:=b_so_ngkh+(r_lp.ngay-b_d1); end if;
				b_d1:=r_lp.ngay; b_tckhao:=r_lp.khao;
			end if;
		end loop;
		if b_tckhao='K' then b_so_ngkh:=b_so_ngkh+(b_ngc-b_d1)+1; end if;
		b_i1:=months_between(b_ngc+1,b_d3); b_i2:=(b_ngc-b_d3)+1;
		b_so_ngkh:=b_i1*b_so_ngkh/b_i2;
	end if;
	b_so_ngkh:=b_so_ngkh+b_i3;
end if;
if b_so_ngkh<>0 then
	PTS_KH_PTT(b_ma_dvi,b_so_the,b_ngd,b_tg_kh,b_ppt,b_nam,b_tcon,b_loi);
	if b_loi is not null then return; end if;
end if;
b_loi:='Loi don vi su dung';
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<=b_ngc;
if b_i1=0 then raise PROGRAM_ERROR; end if;
select dvi_sd into b_dvic from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<b_ngd;
if b_i1=0 then b_dvid:=b_dvic;
else select dvi_sd into b_dvid from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
end if;
for r_lp in (select distinct ma_ng from ts_sc_2 where ma_dvi=b_ma_dvi and so_the=b_so_the and ng_bd<=b_ngc) loop
	b_ma_ng:=r_lp.ma_ng; b_loi:='Da xoa ma nguon#'||b_ma_ng;
	select nvl(khao,'C') into b_tckhao from xd_ma_nguon where ma_dvi=b_ma_dvi and ma=b_ma_ng;
	select nvl(sum(nggia_ck),0),nvl(sum(kh_ck),0) into b_nggia_dk,b_kh_dk from ts_kh where
		ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngt and ma_ng=b_ma_ng;
	b_nggia_bd:=0; b_nggia_bs:=0; b_kh_th:=0; b_kh_bd:=0; b_kh_bs:=0;
	for b_rc in (select ma_bd,sum(tien_qd) tien from ts_sc_2 where ma_dvi=b_ma_dvi and
		so_the=b_so_the and ma_ng=b_ma_ng and (ng_bd between b_ngd and b_ngc) group by ma_bd) loop
		b_loi:='Da xoa ma bien dong#'||b_rc.ma_bd;
		select loai,xl into b_lbd,b_xl from ts_ma_bdong where ma_dvi=b_ma_dvi and ma=b_rc.ma_bd;
		if b_lbd='T' then
			if b_xl='T' then b_nggia_bd:=b_nggia_bd+b_rc.tien; else b_nggia_bs:=b_nggia_bs+b_rc.tien; end if;
		elsif b_lbd='G' then
			if b_xl='T' then b_nggia_bd:=b_nggia_bd-b_rc.tien; else b_nggia_bs:=b_nggia_bs-b_rc.tien; end if;
		elsif b_lbd='K' then
			if b_xl='T' then b_kh_bd:=b_kh_bd+b_rc.tien; else b_kh_bs:=b_kh_bs+b_rc.tien; end if;
		elsif b_lbd='C' then
			b_kh_th:=b_kh_th+b_rc.tien;
		end if;
	end loop;
	b_nggia_ck:=b_nggia_dk+b_nggia_bd; b_kh_ck:=b_kh_dk+b_kh_bd;
	if b_so_ngkh<>0 and b_tckhao='C' and b_kh_th=0 and b_nggia_ck>b_kh_ck then
		if b_nam<=0 then b_kh_th:=0;
		elsif b_ppt='P' then b_kh_th:=round(b_nggia_ck*b_nam/1200,0);
		elsif b_ppt='C' then b_kh_th:=round(b_nggia_ck/(12*b_nam),0);
		elsif b_tcon=0 then b_kh_th:=b_nggia_ck-b_kh_ck;
		else
			b_kh_th:=round((b_nggia_ck-b_kh_ck)/(b_tcon+b_them),0);
		    if b_ppt='S' then		-- Khau hao nhanh
				b_loi:='Sai he so dieu chinh nam loai#'||to_char(b_nam)||'#cho ngay#'||to_char(b_ngd,'dd/mm/yyyy');
				select max(nam),count(*) into b_i1,b_i2 from ts_hsdc where ma_dvi=b_ma_dvi and ngay<=b_ngd and nam<=b_nam;
				if b_i2=0 then raise PROGRAM_ERROR; end if;
				select hs into b_i2 from ts_hsdc where ma_dvi=b_ma_dvi and nam=b_i1 and ngay in
					(select max(ngay) from ts_hsdc where ma_dvi=b_ma_dvi and ngay<=b_ngd and nam=b_i1);
				select nvl(sum(kh_ck),0) into b_i1 from ts_kh where
					ma_dvi=b_ma_dvi and so_the=b_so_the and ngay=b_ngn and ma_ng=b_ma_ng;
				select nvl(sum(kh_bd),0) into b_i3 from ts_kh where
					ma_dvi=b_ma_dvi and so_the=b_so_the and (ngay>b_ngn and ngay<b_ngd) and ma_ng=b_ma_ng;
				b_i1:=round((b_nggia_ck-b_i1-b_i3-b_kh_bd)*b_i2/b_nam/12,0);
				if b_i1>b_kh_th then b_kh_th:=b_i1; end if;
			end if;
		end if;
		b_kh_th:=round(b_kh_th*b_so_ngkh,0);
		if b_nggia_ck<b_kh_ck+b_kh_th then b_kh_th:=b_nggia_ck-b_kh_ck; end if;
	end if;
	b_nggia_ck:=b_nggia_ck+b_nggia_bs; b_nggia_bd:=b_nggia_bd+b_nggia_bs;
	b_kh_ck:=b_kh_ck+b_kh_th+b_kh_bs; b_kh_bd:=b_kh_bd+b_kh_bs;
	if b_dvid=b_dvic then
		insert into ts_kh values(b_ma_dvi,b_ngc,b_so_the,b_dvid,b_ma_ng,b_nggia_dk,b_nggia_bd,0,0,b_nggia_ck,b_kh_dk,b_kh_bd,b_kh_th,0,0,b_kh_ck,b_tcon,b_idvung);
	else
		insert into ts_kh values(b_ma_dvi,b_ngc,b_so_the,b_dvid,b_ma_ng,b_nggia_dk,0,b_nggia_dk,0,0,b_kh_dk,0,0,b_kh_dk,0,0,b_tcon,b_idvung);
		insert into ts_kh values(b_ma_dvi,b_ngc,b_so_the,b_dvic,b_ma_ng,0,b_nggia_bd,0,b_nggia_dk,b_nggia_ck,0,b_kh_bd,b_kh_th,0,b_kh_dk,b_kh_ck,b_tcon,b_idvung);
	end if;
end loop;
b_loi:='';
exception when others then
	if b_loi is null then b_loi:='Loi tinh khau hao#'; end if;
	b_loi:='loi:'||trim(b_loi)||'#so the#'||b_so_the||':loi';
end;
/
create or replace procedure PTS_PHU_TH(b_ma_dvi varchar2,b_so_the varchar2,b_ngc date,b_loi out varchar2)
AS
  b_i1 number; b_i2 number; b_i3 number; b_d1 date; b_d2 date; b_d3 date; b_them number:=0;
  b_dvid varchar2(10); b_dvic varchar2(10); b_ngd date; b_ngt date; b_ngn date;
  b_ma_ng varchar2(5); b_lbd varchar2(1); b_xl varchar2(1); b_idvung number;
  b_nggia_dk number; b_nggia_bd number; b_nggia_bs number; b_nggia_ck number; b_ng_cu number;
begin
-- Dan - Tong hop nguyen gia theo nguon cua the phu, the tam
--  b_ma_ng,b_nggia_dk,b_nggia_ck,b_nggia_bd,b_nggia_bs - Ma nguon, Ng.gia dau, cuoi ky, b.dong ng.gia trong, sau ky
b_ngd:=trunc(b_ngc,'MONTH'); b_ngt:=b_ngd-1; b_ngn:=trunc(b_ngd,'YEAR')-1;
b_loi:='Loi don vi su dung ';
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<=b_ngc;
if b_i1=0 then raise PROGRAM_ERROR; end if;
select dvi_sd,idvung into b_dvic,b_idvung from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<b_ngd;
if b_i1=0 then
  b_dvid:=b_dvic;
else  select dvi_sd into b_dvid from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
end if;
for r_lp in (select distinct ma_ng from ts_sc_2 where ma_dvi=b_ma_dvi and so_the=b_so_the and ng_bd<=b_ngc) loop
  b_ma_ng:=r_lp.ma_ng; b_loi:='Da xoa ma nguon#'||b_ma_ng;
  select nvl(sum(nggia_ck),0) into b_nggia_dk from ts_phu where ma_dvi=b_ma_dvi and ngay=b_ngt and so_the=b_so_the and ma_ng=b_ma_ng;
  b_nggia_bd:=0; b_nggia_bs:=0;
  for b_rc in (select ma_bd,sum(tien_qd) tien from ts_sc_2 where ma_dvi=b_ma_dvi and
    so_the=b_so_the and ma_ng=b_ma_ng and (ng_bd between b_ngd and b_ngc) group by ma_bd) loop
    b_loi:='Da xoa ma bien dong#'||b_rc.ma_bd;
    select loai,xl into b_lbd,b_xl from ts_ma_bdong where ma_dvi=b_ma_dvi and ma=b_rc.ma_bd;
    if b_lbd='T' then
      if b_xl='T' then
        b_nggia_bd:=b_nggia_bd+b_rc.tien;
      else  b_nggia_bs:=b_nggia_bs+b_rc.tien;
      end if;
    elsif b_lbd='G' then
      if b_xl='T' then
        b_nggia_bd:=b_nggia_bd-b_rc.tien;
      else  b_nggia_bs:=b_nggia_bs-b_rc.tien;
      end if;
    end if;
  end loop;
  b_nggia_bd:=b_nggia_bd+b_nggia_bs; b_nggia_ck:=b_nggia_dk+b_nggia_bd;
  if b_dvid=b_dvic then
    insert into ts_phu values(b_ma_dvi,b_ngc,b_so_the,b_dvid,b_ma_ng,b_nggia_dk,b_nggia_bd,0,0,b_nggia_ck,b_idvung);
  else  insert into ts_phu values(b_ma_dvi,b_ngc,b_so_the,b_dvid,b_ma_ng,b_nggia_dk,0,b_nggia_dk,0,0,b_idvung);
    insert into ts_phu values(b_ma_dvi,b_ngc,b_so_the,b_dvic,b_ma_ng,0,b_nggia_bd,0,b_nggia_dk,b_nggia_ck,b_idvung);
  end if;
end loop;
b_loi:='';
exception when others then
  if b_loi is null then b_loi:='loi:Loi tap hop nguyen gia the phu:loi'; end if;
  b_loi:='loi:'||trim(b_loi)||'#so the#'||b_so_the||':loi';
end;
 /
 create or replace procedure PTS_TH_HTOAN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number)
AS
    b_ngay date; b_ngayd date; b_ngayc date; b_idvung number; b_so_id number; b_kt number:=0; b_bt number:=0; b_lk varchar2(100);
    b_loi varchar2(100); b_i1 number; b_i2 number; b_tien number; b_log boolean; b_phong varchar2(10); b_cbao varchar2(200);
    b_ma_tk varchar2(20); b_ma_tkG varchar2(20); b_so_ct varchar2(20); b_dvi_sd varchar2(20); b_htoan varchar2(1):='H';
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num; a_note pht_type.a_nvar; a_bt pht_type.a_num;
    a_sp_bt pht_type.a_num; a_nhom pht_type.a_var; a_dvi pht_type.a_var; a_phong pht_type.a_var; a_hdong pht_type.a_var; 
    a_ma_sp pht_type.a_var; a_sp_tien pht_type.a_num; a_thue pht_type.a_num;
    a_ma_tk_xl pht_type.a_var; a_ma_tke_xl pht_type.a_var; a_tien_xl pht_type.a_num;
    a_ma_nt pht_type.a_var; a_tygia pht_type.a_num; a_sp_nd pht_type.a_nvar;
begin
-- Dan - Hach toan
delete ts_htoan_temp_1; delete ts_htoan_temp_2; delete ts_htoan_temp_3; delete ts_htoan_temp_4; commit;
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_ht is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_ngay:=PKH_SO_CDT(b_ngay_ht); b_ngayd:=trunc(b_ngay,'MONTH'); b_ngayc:=last_day(b_ngay);
b_ma_tkG:=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TS','K',b_ngay_ht,'K'); PKH_MANG_KD(a_ma_tk_xl);
for r_lp1 in (select so_the,sum(kh_th) kh_bd,min(dvi_sd) dvi_sd from ts_kh where ma_dvi=b_ma_dvi and ngay between b_ngayd and b_ngayc group by so_the) loop
    select ma_tk_kh into b_ma_tk from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=r_lp1.so_the;
    if trim(b_ma_tk) is null then b_ma_tk:=b_ma_tkG; end if;
    b_i2:=r_lp1.kh_bd; PKH_MANG_XOA(a_ma_tk_xl); b_kt:=0; b_log:=false;
    insert into ts_htoan_temp_4 values(b_ma_tk,b_i2);
    select count(*) into b_i1 from ts_pb where ma_dvi=b_ma_dvi and so_the=r_lp1.so_the and bt<1000;
    if b_i1<>0 then
        for r_lp in (select ma_tk,ma_tke,pt from ts_pb where ma_dvi=b_ma_dvi and so_the=r_lp1.so_the and bt<1000) loop
            b_kt:=b_kt+1; b_tien:=round(r_lp1.kh_bd*r_lp.pt/100,0);
            a_ma_tk_xl(b_kt):=r_lp.ma_tk; a_ma_tke_xl(b_kt):=r_lp.ma_tke; a_tien_xl(b_kt):=b_tien;
            if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,'T',r_lp.ma_tk) then b_log:=true; end if;
            b_i2:=b_i2-b_tien;
        end loop;
        a_tien_xl(b_kt):=a_tien_xl(b_kt)+b_i2;
    else
        b_kt:=b_kt+1; b_htoan:='T';
        a_ma_tk_xl(b_kt):=' '; a_ma_tke_xl(b_kt):=' '; a_tien_xl(b_kt):=b_i2;
    end if;
    if b_log then
        for b_lp in 1..b_kt loop
            b_i2:=a_tien_xl(b_lp);
            select count(*) into b_i1 from ts_pb where ma_dvi=b_ma_dvi and so_the=r_lp1.so_the and bt>1000;
            if b_i1<>0 and b_htoan='H' then
                for r_lp in (select dvi,ma_tk phong,ma_tke sp,pt from ts_pb where ma_dvi=b_ma_dvi and so_the=r_lp1.so_the and bt>1000) loop
                    b_i1:=b_i1-1; b_tien:=round(a_tien_xl(b_lp)*r_lp.pt/100,0);
                    if b_i1=0 or abs(b_tien)>abs(b_i2) then b_tien:=b_i2; end if;
                    b_i2:=b_i2-b_tien;
                    if trim(r_lp.dvi) is null then b_dvi_sd:=r_lp1.dvi_sd; else b_dvi_sd:=r_lp.dvi; end if;
                    if trim(r_lp.phong) is null then b_phong:=FTS_PHONG_SD(b_ma_dvi,r_lp1.so_the,b_ngay_ht); else b_phong:=r_lp.phong; end if;
                    insert into ts_htoan_temp_1 values(a_ma_tk_xl(b_lp),a_ma_tke_xl(b_lp),b_dvi_sd,r_lp.phong,r_lp.sp,b_tien);
                end loop;
            end if;
        end loop;
    else
        for b_lp in 1..b_kt loop
            insert into ts_htoan_temp_1 values(a_ma_tk_xl(b_lp),a_ma_tke_xl(b_lp),' ',' ',' ',a_tien_xl(b_lp));
        end loop;
    end if;
end loop;
insert into ts_htoan_temp_2 select ma_tk,ma_tke,dvi,phong,sp,sum(tien) from ts_htoan_temp_1 group by ma_tk,ma_tke,dvi,phong,sp having sum(tien)<>0;
insert into ts_htoan_temp_3 select distinct ma_tk,ma_tke from ts_htoan_temp_2;
b_kt:=0; b_bt:=0;
for r_lp in(select * from ts_htoan_temp_3) loop
    b_kt:=b_kt+1;
    a_nv(b_kt):='N'; a_ma_tk(b_kt):=r_lp.ma_tk; a_ma_tke(b_kt):=r_lp.ma_tke; a_note(b_kt):=' '; a_bt(b_kt):=b_kt;
    select nvl(sum(tien),0) into a_tien(b_kt) from ts_htoan_temp_2 where ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke;
    if b_htoan='H' then
        for r_lp1 in (select dvi,phong,sp,tien from ts_htoan_temp_2 where ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke
            and (dvi<>' ' or phong<>' ' or sp<>' ') order by dvi,phong,sp) loop
            b_bt:=b_bt+1;
            a_sp_bt(b_bt):=b_kt; a_dvi(b_bt):=r_lp1.dvi; a_phong(b_bt):=r_lp1.phong; a_hdong(b_bt):=' ';
            a_ma_sp(b_bt):=r_lp1.sp; a_sp_tien(b_bt):=r_lp1.tien; a_thue(b_bt):=0;
            a_nhom(b_bt):=FKT_BP_NHOM(b_ma_dvi,r_lp1.phong,r_lp1.sp);
        end loop;
    end if;
end loop;
for r_lp in(select ma_tk,sum(tien) tien from ts_htoan_temp_4 group by ma_tk having sum(tien)<>0) loop
    b_kt:=b_kt+1;
    a_nv(b_kt):='C'; a_ma_tk(b_kt):=r_lp.ma_tk; a_ma_tke(b_kt):=' '; a_tien(b_kt):=r_lp.tien; a_note(b_kt):=' '; a_bt(b_kt):=b_kt;
end loop;
if b_kt<>0 then
    b_i1:=0; PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,' ',b_i1,b_so_ct,' ','Tong hop phan bo khau hao tai san',' ',
        a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'KT',b_lk,b_loi,'C');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    if b_bt<>0 then
        PKT_CT_BP_NH(b_ma_dvi,'','',b_so_id,a_sp_bt,a_nhom,a_hdong,a_hdong,a_dvi,a_phong,a_hdong,a_hdong,a_hdong,a_ma_sp,a_sp_tien,'K');
    end if;
else
    b_loi:='loi:Khong phat sinh phan bo khau hao:loi'; raise PROGRAM_ERROR;
end if;
if b_kt<>0 and b_htoan='H' then
    delete ts_htoan_temp_2 where dvi in(' ',b_ma_dvi);
    select count(*),nvl(sum(tien),0) into b_kt,b_i1 from ts_htoan_temp_2;
    if b_kt<>0 then
        a_ma_tk(1):=PKH_MA_LCT_TRA_TK(b_ma_dvi,'CD','CD',b_ngay_ht,'N');
        if trim(a_ma_tk(1)) is null then b_loi:='loi:Chua khai bao tai khoan chi ho:loi'; raise PROGRAM_ERROR; end if;
        b_kt:=1; b_bt:=0; a_nv(1):='N'; a_ma_tke(1):=' '; a_tien(b_kt):=b_i1; a_note(1):=' '; a_bt(1):=1;
        delete ts_htoan_temp_3;
        insert into ts_htoan_temp_3 select distinct ma_tk,ma_tke from ts_htoan_temp_2;
        for r_lp in(select * from ts_htoan_temp_3) loop
            b_kt:=b_kt+1;
            a_nv(b_kt):='C'; a_ma_tk(b_kt):=r_lp.ma_tk; a_ma_tke(b_kt):=r_lp.ma_tke; a_note(b_kt):=' '; a_bt(b_kt):=b_kt;
            select nvl(sum(tien),0) into a_tien(b_kt) from ts_htoan_temp_2 where ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke;
            for r_lp1 in (select dvi,phong,sp,tien from ts_htoan_temp_2 where ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke) loop
                b_bt:=b_bt+1;
                a_sp_bt(b_bt):=b_kt; a_dvi(b_bt):=r_lp1.dvi; a_phong(b_bt):=r_lp1.phong; a_hdong(b_bt):=' ';
                a_ma_sp(b_bt):=r_lp1.sp; a_sp_tien(b_bt):=r_lp1.tien; a_thue(b_bt):=0;
                a_nhom(b_bt):=FKT_BP_NHOM(b_ma_dvi,r_lp1.phong,r_lp1.sp);
                a_ma_nt(b_bt):='VND'; a_tygia(b_bt):=1; a_sp_nd(b_bt):='';
            end loop;
            b_i1:=b_i1+a_tien(b_kt);
        end loop;
        b_i1:=0; b_so_ct:=''; PHT_ID_MOI(b_so_id,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        PKT_KT_NH(b_ma_dvi,b_nsd,'H',b_ngay_ht,' ',b_i1,b_so_ct,' ','Phan bo khau hao tai san cho don vi',' ',
            a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'KT',b_lk,b_loi,'C');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
        if b_bt<>0 then
            PKT_CT_BP_NH(b_ma_dvi,'','',b_so_id,a_sp_bt,a_nhom,a_hdong,a_hdong,a_dvi,a_phong,a_hdong,a_hdong,a_hdong,a_ma_sp,a_sp_tien,'K');
        end if;
        PCD_CT_NH(b_ma_dvi,'','',b_so_id,b_so_ct,b_ngay_ht,'H','PC',' ','','Phan bo khau hao tai san cho don vi',
            a_dvi,a_ma_nt,a_tygia,a_sp_tien,a_sp_tien,a_sp_nd,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_lk,b_cbao,'K');
    end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 
/
create or replace procedure PTS_MA_TT_XEM
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100);
begin
-- Dan - Xem ma trang thai SD
open cs_lke for select * from ts_ma_tt where ma_dvi=b_ma_dvi order by ma;

end;

 /
 create or replace procedure PTS_MA_BDONG_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Xem ma bien dong tai san
open cs1 for select * from ts_ma_bdong where ma_dvi=b_ma_dvi order by ma;
end;
 /
 create or replace procedure PTS_MA_TS_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number; b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Lke
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
insert into temp_1(c1,c2,c3) select ma,ten,ma_ql from ts_ma_ts where ma_dvi=b_ma_dvi order by ma;
b_dong:=sql%rowcount;
insert into temp_2(c1,c2,c3,c10,n1) select c1,c2,c3,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,rownum
    from temp_1 start with c3=' ' CONNECT BY prior c1=c3;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select c1 ma,c2 ten,c10 xep
    from (select c1,c2,c10,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
delete temp_1; delete temp_2; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_LCT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma varchar2,b_ngay number,b_dk varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_d1 number; b_md_k varchar2(10):=b_md;
begin
-- Dan - Chi tiet
if b_md in('BP','LC') then b_md_k:='KT'; end if;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_md_k,'');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_dk<>'C' then b_d1:=b_ngay;
else select nvl(max(ngay),b_ngay) into b_d1 from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay<=b_ngay;
end if;
open cs1 for select * from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_d1;
end;
/
create or replace procedure PTS_BD_TIM
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_d number,b_ngay_c number,
  b_treo varchar2,b_dc varchar2,b_l_ct varchar2,b_so_the varchar2,b_nd nvarchar2,
  b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Tim kiem chung tu bien dong tai san
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; commit;
insert into temp_1(n1) select so_id from ts_bd_1 where ma_dvi=b_ma_dvi and htoan in('T',b_treo) and
  (ngay_ht between b_ngay_d and b_ngay_c) and (b_nd is null or upper(nd) like b_nd);
if b_dc='C' then
  delete temp_1 where exists(select * from kt_1 where
  ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'TS:0')=0 and instr(lk,'TS:1')=0);
end if;
if b_so_the is not null then
  delete temp_1 where not exists(select * from ts_bd_2 where

    ma_dvi=b_ma_dvi and so_id=n1 and so_the=b_so_the);
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,so_ct,nd,pkh_so_cng(ngay_ht) ngay_htc,
  row_number() over (order by ngay_ht,l_ct,so_id) sott from ts_bd_1,temp_1
  where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,so_id)
  where sott between b_tu and b_den;
end;
/
create or replace procedure PTS_DC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem dieu chuyen tai san
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san chua co:loi';
select ten into b_ten from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select ngay_qd,PKH_NG_CSO(ngay_qd) ngay_so,FHT_MA_DVI_GOC(dvi_sd) dvi_sd,phong,ma_cb

    from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the order by ngay_qd DESC;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FHT_MA_DVI_GOC (b_ma varchar2) return varchar2
AS
	b_goc varchar2(10);
begin
-- Dan - Tra ma goc don vi
select min(ma_goc) into b_goc from ht_ma_dvi where ma=b_ma;
return b_goc;
end;
/
create or replace procedure PCN_TK_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select * from cn_tk where ma_dvi=b_ma_dvi and ngay=b_ngay order by bt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FTS_PHONG_SD(b_ma_dvi varchar2,b_so_the varchar2,b_ngay number) return varchar2
AS
    b_kq varchar2(20):=''; b_i1 number; b_d1 date; b_ng date;
begin
-- Dan - Tra don vi su dung
b_ng:=PKH_SO_CDT(b_ngay);
select count(*),max(ngay_qd) into b_i1,b_d1 from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd<=b_ng;
if b_i1<>0 then
    select phong into b_kq from ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_d1;
end if;
return b_kq;
end;
/
create or replace procedure PKT_MA_LCT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ma loai chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select ma,ten,nsd from kt_ma_lct where ma_dvi=b_ma_dvi and FKT_MA_LCT_NV(b_ma_dvi,ma,b_nv)='C' order by ma;
end;
/
create or replace procedure PKT_MA_LCT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
    b_ten nvarchar2,a_nv in out pht_type.a_var,a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var)
AS
    b_loi varchar2(100); b_i1 number; b_c1 varchar2(1); b_tc varchar2(100);
    b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null or trim(b_ten) is null then b_loi:='loi:So lieu nhap sai:loi'; raise PROGRAM_ERROR; end if;
if b_ma in('KC','KC/C','KC/N') then b_loi:='loi:Cac Ma KC,KC/N,KC/C danh rieng, khong khai bao:loi'; raise PROGRAM_ERROR; end if;
PKH_MANG(a_nv);
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp) not in ('N','C') then b_loi:='loi:Phat sinh:N-No,C-Co:loi'; raise PROGRAM_ERROR; end if;
    b_loi:='loi:Sai tai khoan#'||a_ma_tk(b_lp)||':loi';
    select tc into b_tc from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
    b_i1:=instr(b_tc,'T1'); b_c1:=substr(b_tc,b_i1+3,1);
    if b_i1=0 or b_c1 not in ('T',a_nv(b_lp)) then raise PROGRAM_ERROR; end if;
    b_i1:=instr(b_tc,'TK');
    if instr(b_tc,'TK')<0 and trim(a_ma_tke(b_lp)) is not null then raise PROGRAM_ERROR; end if;
    if trim(a_ma_tke(b_lp)) is not null then
        b_loi:='loi:Sai ma t.ke#'||a_ma_tke(b_lp)||'#t.khoan#'||a_ma_tk(b_lp)||':loi';
        select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=a_ma_tke(b_lp);
    end if;
end loop;
b_loi:='loi:Va cham nguoi su dung:loi';
delete kt_ma_lct_tk where ma_dvi=b_ma_dvi and ma=b_ma;
delete kt_ma_lct where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kt_ma_lct values (b_ma_dvi,b_ma,b_ten,b_nsd,b_idvung);
for b_lp in 1..a_nv.count loop
    insert into kt_ma_lct_tk values(b_ma_dvi,b_ma,a_nv(b_lp),a_ma_tk(b_lp),a_ma_tke(b_lp),b_lp,b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_LCT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from kt_ma_lct_tk where ma_dvi=b_ma_dvi and ma=b_ma order by bt;
end;
/
create or replace procedure PKT_MA_LCT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(250);
begin
-- Dan - Xoa ma loai chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Nhap so lieu sai:loi';
if b_ma is null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table MA_LCT:loi';
delete kt_ma_lct_tk where ma_dvi=b_ma_dvi and ma=b_ma;
delete kt_ma_lct where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 
/
create or replace function FKT_MA_LCT_NV(b_ma_dvi varchar2,b_ma varchar2,b_nv varchar2) return varchar2
AS
    b_kq varchar2(1):='C'; b_i1 number;
begin
-- Dan - Xem ma loai chung tu
if trim(b_nv) is not null then
    select count(*) into b_i1 from kt_ma_lct_tk where ma_dvi=b_ma_dvi and ma=b_ma and nv=b_nv;
    if b_i1=0 then b_kq:='K'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PKT_MA_LC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke ma luu chuyen
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
insert into temp_1(c1,c2,c3,c4,c5) select ma,nvl(ma_ql,' '),ten,nsd,tc from kt_ma_lc where ma_dvi=b_ma_dvi order by ma;

b_dong:=sql%rowcount;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
insert into temp_2(c1,c2,c3,c4,c5,c10,n1) select c1,c2,c3,c4,c5,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,rownum
    from temp_1 start with c2=' ' CONNECT BY prior c1=c2;
open cs_lke for select c10 xep,c1 ma,c2 ma_ql,c3 ten,c4 nsd,c5 tc
    from (select c1,c2,c3,c4,c5,c10,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
end;
/
create or replace procedure PKT_MA_TK_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ma tai khoan chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma;
end;
/
create or replace procedure PKT_MA_TKE_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem ma thong ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_tim is null then
    select count(*) into b_dong from kt_ma_tke where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select a.*,row_number() over (order by nhom,ma) sott
        from kt_ma_tke a where ma_dvi=b_ma_dvi order by nhom,ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kt_ma_tke where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select a.*,row_number() over (order by nhom,ma) sott
        from kt_ma_tke a where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by nhom,ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PKT_MA_TKLC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select distinct ma_tk,nsd from kt_ma_tklc where ma_dvi=b_ma_dvi order by ma_tk;
end;
/
create or replace procedure PKT_BP_NHOM_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select ma,ten from kt_bp_nhom where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_DN_HTKC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select ma,ngay_ht,PKH_SO_CNG(ngay_ht) ngayc from kt_htkc where ma_dvi=b_ma_dvi order by ma,ngay_ht; 
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;end;
/
create or replace procedure PKT_PB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem phan bo san pham
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select distinct ngay,ma_tk,ma_tke from kt_pb where ma_dvi=b_ma_dvi order by ngay desc,ma_tk,ma_tke;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_NAMTC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from kt_namtc where ma_dvi=b_ma_dvi order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_TK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_tc varchar2,b_ngay date)
AS
    b_loi varchar2(100); b_c1 varchar2(1); b_c2 varchar2(2); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma tai khoan chi tiet
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma tai khoan:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai tinh chat tai khoan:#'||b_tc||':loi';
b_i1:=length(rtrim(b_tc));
while b_i1>4 loop
    b_c2:=substr(b_tc,b_i1-4,2); b_c1:=substr(b_tc,b_i1-1,1);
    if substr(b_tc,b_i1-2,1)<>':' or substr(b_tc,b_i1,1)<>',' or
        (b_c2='T1' and b_c1 not in('T','N','C','K')) or
        (b_c2='T2' and b_c1 not in ('N','C','T')) or
        (b_c2='TK' and b_c1 not in ('C','H','K')) or
        (b_c2='HT' and b_c1 not in ('C','K')) or
        (b_c2='BC' and b_c1 not in ('C','R','K')) then exit;
    end if;
    b_i1:=b_i1-5;
end loop;
b_loi:='loi:Va cham NSD:loi';
delete kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kt_ma_tk values (b_ma_dvi,b_ma,b_ten,b_tc,b_ngay,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_TKTKE_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke tai khoan - thong ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select distinct ma_tk,nhom,nsd from kt_ma_tktke where ma_dvi=b_ma_dvi order by ma_tk;
end;
/
create or replace procedure PKH_HOI_KT_LIST_MA(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
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
create or replace procedure PKT_MA_TKE_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,b_ma varchar2,
    b_ten nvarchar2,b_loai varchar2,b_tc varchar2,b_pb varchar2,b_ps varchar2)
AS
    b_loi varchar2(250); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma thong ke
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_nhom) is null then b_loi:='loi:Nhap nhom thong ke:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma thong ke:loi'; raise PROGRAM_ERROR; end if;
if b_loai is null or b_loai not in('C','T','K') then b_loi:='loi:Loai:T-Thu, C-Chi, K-Khac:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc not in('C','T') then b_loi:='loi:Sai tinh chat:loi'; raise PROGRAM_ERROR; end if;
if b_pb is null or b_pb not in('Q','K','P') then b_loi:='loi:Sai tinh chat phan bo san pham:loi'; raise PROGRAM_ERROR; end if;
if b_ps is null or b_ps not in('C','B') then b_loi:='loi:Sai phat sinh:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table MA_TKE:loi';
delete kt_ma_tke where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
insert into kt_ma_tke values (b_ma_dvi,b_nhom,b_ma,b_ten,b_loai,b_tc,b_pb,b_ps,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_NV_NH
    (b_ma_dvi varchar2,b_so_id number,b_tt out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; r_se se_1%rowtype; r_tc tc_ps%rowtype;

    b_md varchar2(2); b_nsd varchar2(20); b_ngay_ht number; b_l_ct varchar2(5); b_so_tt number:=0; b_ma_thue varchar2(20);
    b_ngay_ct varchar2(10); b_nd nvarchar2(400); b_ndp nvarchar2(400); b_ma_nt_t varchar2(5); b_htoan varchar2(1):='T'; b_phong varchar2(10);
    b_k_ma_kh varchar2(1):='K'; b_ma_kh varchar2(20); b_ten nvarchar2(400); b_dchi nvarchar2(400); b_idvung number;
    b_ma_noite varchar2(5); b_nha_t varchar2(10) :=' '; b_tk_nha_t varchar2(20) :=' '; b_nha_c varchar2(10) :=' '; b_tk_nha_c varchar2(20) :=' ';
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var;
    a_tien pht_type.a_num; b_lk varchar2(100); b_tien_t number; b_tien_c number;
    a_nv_l pht_type.a_var; a_ma_tk_l pht_type.a_var; a_tien_l pht_type.a_num;
    a_so_id pht_type.a_num; a_tien_ph pht_type.a_num; a_tien_qd_ph pht_type.a_num;
begin
-- Dan - Chuyen chung tu hach toan sang tien te
b_tien_t:=0; b_tien_c:=0; b_loi:='loi:Chung tu hach toan da xoa:loi';
select md,nsd,ngay_ht,ngay_ct,nd,ndp,idvung into b_md,b_nsd,b_ngay_ht,b_ngay_ct,b_nd,b_ndp,b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKT_TRA_KT2(b_ma_dvi,b_so_id,a_nv,a_ma_tk,a_ma_tke,a_tien,b_lk,b_loi);
if b_loi is not null then return; end if;
PKH_MA_LCT_TKNV(b_ma_dvi,'TT',b_ngay_ht,a_nv,a_ma_tk,b_l_ct);
if trim(b_l_ct) is null then b_loi:='loi:Khong co loai chung tu tien te tuong ung:loi'; return; end if;
PKH_MA_LCT_TK(b_ma_dvi,'TT',b_ngay_ht,a_nv,a_ma_tk,a_nv_l,a_ma_tk_l,b_l_ct);
PKH_MA_LCT_TIEN(a_nv,a_ma_tk,a_tien,a_nv_l,a_ma_tk_l,a_tien_l);
for b_lp in 1..a_nv_l.count loop
    if a_nv_l(b_lp)='N' then b_tien_t:=b_tien_t+a_tien_l(b_lp); else b_tien_c:=b_tien_c+a_tien_l(b_lp); end if;
end loop;
b_ma_noite:=FTT_TRA_NOITE(b_ma_dvi);
PKH_MANG_KD_N(a_so_id);
if b_md='TC' then
    select * into r_tc from tc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if r_tc.l_ct in('VG','CT') then
        PTT_TT_NH(b_idvung,b_ma_dvi,'',b_md,r_tc.ngay_ht,'T',b_so_id,b_l_ct,b_so_tt,' ',r_tc.ngay_ct,r_tc.so_ct,' ',' ',' ',' ',' ',
        r_tc.nd,r_tc.ndp,'K',' ',' ',' ','','','','','','',b_ma_noite,'',0,0,1,1,'','',r_tc.ma_nt,'',r_tc.tien,r_tc.tien_qd,1,1,'','',
        'K','K',0,0,'','','',a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
    else
        PTT_TT_NH(b_idvung,b_ma_dvi,'',b_md,r_tc.ngay_ht,'T',b_so_id,b_l_ct,b_so_tt,' ',r_tc.ngay_ct,r_tc.so_ct,' ',' ',' ',' ',' ',
        r_tc.nd,r_tc.ndp,'K',' ',' ',' ','','','','','','',
        r_tc.ma_nt,'',r_tc.tien,r_tc.tien_qd,1,1,'','',b_ma_noite,'',0,0,1,1,'','',
        'K','K',0,0,'','','',a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
    end if;
    b_tt:='0'; b_loi:='';
    return;
end if;
b_i1:=0; b_tt:='0';
if b_md='SE' then
    b_loi:='loi:Chung tu sec da xoa:loi';
    select * into r_se from se_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if r_se.l_ct='V' then
        for r_lp in (select l_ct,tien from se_3 a,se_2 b where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and
            b.ma_dvi=b_ma_dvi and b.so_id=a.so_id_ps and b.so_tt=a.so_tt_ps) loop
            if r_lp.l_ct='T' then b_i1:=b_i1+r_lp.tien; else b_i1:=b_i1-r_lp.tien; end if;
        end loop;
    end if;
end if;
if b_i1>0 then
    PTT_TT_NH(b_idvung,b_ma_dvi,'',b_md,b_ngay_ht,'T',b_so_id,b_l_ct,b_so_tt,' ',
        b_ngay_ct,' ',' ',' ',' ',' ',' ',b_nd,b_ndp,'K','','','','','','','','','',r_se.ma_nt,'',b_i1,b_tien_t,1,1,
        r_se.nha,r_se.tk_nha,b_ma_noite,'',0,0,1,1,'','','C','K',0,0,'','','',a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
elsif b_i1<0 then
    PTT_TT_NH(b_idvung,b_ma_dvi,'',b_md,b_ngay_ht,'T',b_so_id,b_l_ct,b_so_tt,' ',
        b_ngay_ct,' ',' ',' ',' ',' ',' ',b_nd,b_ndp,'K','','','','','','','','','',b_ma_noite,'',0,0,1,1,
        '','',r_se.ma_nt,'',-b_i1,b_tien_c,1,1,r_se.nha,r_se.tk_nha,'C','K',0,0,'','','',a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
else
    if b_md='BH' then
        b_loi:='loi:Chung tu da xoa:loi';
        select nvl(nha,' '),nvl(tk_nha,' ') into b_nha_t,b_tk_nha_t from bh_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if substr(b_l_ct,1,1)<>'T' then
            b_nha_c:=b_nha_t; b_tk_nha_c:=b_tk_nha_t; b_nha_t:=' '; b_tk_nha_t:=' ';
        end if;
    elsif b_md='KP' then
        b_loi:='loi:Kenh phan phoi:loi';
        --select nha,tk_nha into b_nha_t,b_tk_nha_t from kp_kt where ma_dvi=b_ma_dvi and so_id=b_so_id;
        if substr(b_l_ct,1,1)<>'T' then
            b_nha_c:=b_nha_t; b_tk_nha_c:=b_tk_nha_t; b_nha_t:=''; b_tk_nha_t:='';
        end if;
    elsif b_md='VT' or instr(b_lk,'VT:2')>0 then
        select k_ma_kh,ma_kh,ten,dchi into b_k_ma_kh,b_ma_kh,b_ten,b_dchi from vt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_md='CN' or instr(b_lk,'CN:2')>0 then
        select ma_cn into b_ma_kh from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=1;
        b_k_ma_kh:=substr(b_ma_kh,1,1); b_ma_kh:=substr(b_ma_kh,2);
    elsif b_md='XL' or instr(b_lk,'XL:2')>0 then
        select k_ma_kh,ma_kh into b_k_ma_kh,b_ma_kh from xl_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    elsif b_md='TV' or instr(b_lk,'TV:2')>0 then
        select k_ma_kh,ma_kh,ten,dchi into b_k_ma_kh,b_ma_kh,b_ten,b_dchi from tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=1;
    end if;
    b_htoan:='T'; b_tt:='0';
    if b_md in('VT','CN','TV','XL') then
        if trim(b_ten) is null and trim(b_k_ma_kh) is not null and trim(b_ma_kh) is not null then
            if b_k_ma_kh in('K','U') then
                select ten,dchi,tax into b_ten,b_dchi,b_ma_thue from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
            elsif b_k_ma_kh='D' then
                select ten,dchi,tax into b_ten,b_dchi,b_ma_thue from cn_ma_dl where ma_dvi=b_ma_dvi and ma=b_ma_kh;
            elsif b_k_ma_kh='C' then
                select a.ten,b.ten into b_ten,b_dchi from ht_ma_cb a,ht_ma_phong b where a.ma_dvi=b_ma_dvi and a.ma=b_ma_kh
                    and b.ma_dvi=b_ma_dvi and a.phong=b.ma;
            end if;
        end if;
        if FKH_NV_TSO(b_ma_dvi,'KT','TT','lket')='K' then
            b_tt:='0';
        else
            PTT_CT_TEST(b_ma_dvi,b_nsd,b_md,b_ngay_ht,'H',b_l_ct,b_ngay_ct,' ',b_phong,' ',' ',' ',b_k_ma_kh,b_ma_kh,
                b_ma_noite,'',b_tien_t,b_tien_t,1,1,b_nha_t,b_tk_nha_t,
                b_ma_noite,'',b_tien_c,b_tien_c,1,1,b_nha_c,b_tk_nha_c,a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
            if b_loi is null then b_htoan:='H'; b_tt:='2'; end if;
        end if;
    end if;
    PTT_TT_NH(b_idvung,b_ma_dvi,'',b_md,b_ngay_ht,b_htoan,b_so_id,b_l_ct,b_so_tt,' ',b_ngay_ct,'','',b_phong,
        ' ',' ',' ',b_nd,b_ndp,b_k_ma_kh,b_ma_kh,b_ten,'','',b_dchi,b_ma_thue,'','','',b_ma_noite,'',b_tien_t,b_tien_t,1,1,
        b_nha_t,b_tk_nha_t,b_ma_noite,'',b_tien_c,b_tien_c,1,1,b_nha_c,b_tk_nha_c,'C','K',0,0,'','','',a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
    if b_loi is not null then return; end if;
    if b_htoan='H' then
        PTT_KTRA_SODU(b_ma_dvi,b_loi);
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTT_TT_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_ngay_ht number,b_htoan varchar2,
    b_so_id number,b_l_ct varchar2,b_so_tt in out number,b_so_ph varchar2,b_ngay_ct varchar2,
    b_so_ct varchar2,b_nhom varchar2,b_phong varchar2,b_viec varchar2,b_hdong varchar2,b_nvien varchar2,
    b_nd nvarchar2,b_ndp nvarchar2,b_k_ma_kh varchar2,b_ma_kh varchar2,b_ten nvarchar2,b_nguoi_gd nvarchar2,
    b_cmt varchar2,b_d_chi nvarchar2,b_ma_thue varchar2,b_nhb varchar2,b_tk_nhb varchar2,b_ten_nhb nvarchar2,
    b_ma_nt_t varchar2,b_ma_tke_t varchar2,b_tien_t number,b_noi_te_t number,
    b_tg_ht_t number,b_tg_tt_t number,b_nha_t varchar2,b_tk_nha_t varchar2,b_ma_nt_c varchar2,
    b_ma_tke_c varchar2,b_tien_c number,b_noi_te_c number,b_tg_ht_c number,b_tg_tt_c number,b_nha_c varchar2,b_tk_nha_c varchar2,
    b_loai varchar2,b_pp varchar2,b_t_suat number,b_thue number,b_mau varchar2,b_seri varchar2,b_so_hd varchar2,
    a_so_id pht_type.a_num,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number;
begin
-- Dan - Nhap TT_1
b_i2:=round(b_ngay_ht,-2); b_i3:=b_i2+100;
if b_so_tt>0 then
    if trim(b_nhom) is not null then
        select count(*) into b_i1 from tt_1 where ma_dvi=b_ma_dvi and (ngay_ht between b_i2 and b_i3) and nhom=b_nhom and so_tt=b_so_tt;
    else
        select count(*) into b_i1 from tt_1 where ma_dvi=b_ma_dvi and (ngay_ht between b_i2 and b_i3) and l_ct=b_l_ct and so_tt=b_so_tt;
    end if;
else
    b_i1:=1;
end if;
if b_i1>0 then
    if trim(b_nhom) is not null then
        b_so_tt:=FTT_SOTT(b_ma_dvi,b_ngay_ht,b_nhom,'N');

    else
        b_so_tt:=FTT_SOTT(b_ma_dvi,b_ngay_ht,b_l_ct,'L');
    end if;
end if;
b_loi:='loi:Loi Table TT_1:loi';
insert into tt_1 values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_tt,b_so_ph,b_ngay_ct,b_nhom,b_viec,b_hdong,b_nvien,b_nd,b_ndp,
    b_so_ct,b_k_ma_kh,b_ma_kh,b_ten,b_nguoi_gd,b_cmt,b_phong,b_d_chi,b_ma_thue,b_nhb,b_tk_nhb,b_ten_nhb,b_ma_nt_t,
    b_ma_tke_t,b_tien_t,b_tg_ht_t,b_tg_tt_t,b_noi_te_t,b_nha_t,b_tk_nha_t,b_ma_nt_c,b_ma_tke_c,
    b_tien_c,b_tg_ht_c,b_tg_tt_c,b_noi_te_c,b_nha_c,b_tk_nha_c,b_loai,b_pp,b_t_suat,b_thue,b_mau,b_seri,b_so_hd,b_nsd,b_htoan,b_md,sysdate,'',b_idvung);
if FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B')<>'B' and substr(b_l_ct,1,1)<>'T' and b_ma_nt_c<>'VND' then
    for b_lp in 1..a_so_id.count loop
        insert into tt_2 values(b_ma_dvi,b_so_id,b_ngay_ht,b_ma_nt_c,b_nha_c,b_tk_nha_c,a_so_id(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_lp,b_idvung);
    end loop;
end if;
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','TT');
    if b_loi is not null then return; end if;
    if b_tien_t<>0 or b_noi_te_t<>0 then
        PTT_TH_CT(b_ma_dvi,b_idvung,'T',b_ma_nt_t,b_nha_t,b_tk_nha_t,b_tien_t,b_noi_te_t,b_ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if b_tien_c<>0 or b_noi_te_c<>0 then
        PTT_TH_CT(b_ma_dvi,b_idvung,'C',b_ma_nt_c,b_nha_c,b_tk_nha_c,b_tien_c,b_noi_te_c,b_ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B')<>'B' then
        if substr(b_l_ct,1,1)<>'C' and b_ma_nt_t<>'VND' then
            PTT_TH_PH(b_idvung,b_ma_dvi,'N',b_ma_nt_t,b_nha_t,b_tk_nha_t,b_ngay_ht,b_so_id,b_tien_t,b_noi_te_t,b_loi);
            if b_loi is not null then return; end if;
        end if;
        if substr(b_l_ct,1,1)<>'T' and b_ma_nt_c<>'VND' then
            for b_lp in 1..a_so_id.count loop
                PTT_TH_PH(b_idvung,b_ma_dvi,'X',b_ma_nt_c,b_nha_c,b_tk_nha_c,b_ngay_ht,a_so_id(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_loi);
                if b_loi is not null then return; end if;
            end loop;
        end if;
    end if;
    PKH_NGAY_TD(b_ma_dvi,'TT',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTT_SOTT(b_ma_dvi varchar2,b_ngay_ht number,b_l_ct_n varchar2,b_kieu varchar2) return number
AS
    b_d1 number; b_d2 number; b_i1 number; b_l_ct varchar2(3);
begin
-- Dan - Cho so thu tu tiep theo cua CT tien te
b_d1:=trunc(b_ngay_ht,-2); b_d2:=b_d1+100;
if b_kieu='L' then
    b_l_ct:=trim(substr(b_l_ct_n,1,2))||'%';
    select nvl(max(so_tt),0) into b_i1 from (select l_ct,so_tt from tt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2) where l_ct like b_l_ct;
else
    select nvl(max(so_tt),0) into b_i1 from (select nhom,so_tt from tt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_d1 and b_d2) where nhom=b_l_ct;
end if;
return b_i1+1;
end;
/
create or replace procedure PTT_TH_CT
    (b_ma_dvi varchar2,b_idvung number,b_ps varchar2,b_ma_nt varchar2,b_ma_nh varchar2,b_ma_tk varchar2,
    b_tien number,b_tien_qd number,b_ngay_ht number,b_loi out varchar2)
AS
    b_thu number:=0; b_chi number:=0; b_ton number:=0;
    b_thu_qd number:=0; b_chi_qd number:=0; b_ton_qd number:=0; b_i1 number;
begin
-- Dan - Tong hop chung tu tien te
if b_ps='T' then b_thu:=b_tien; b_thu_qd:=b_tien_qd; else b_chi:=b_tien; b_chi_qd:=b_tien_qd; end if;
select nvl(max(ngay_ht),0) into b_i1 from tt_sc where
    ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht<b_ngay_ht;
if b_i1>0 then
    select ton,ton_qd into b_ton,b_ton_qd from tt_sc where
    ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht=b_i1;
end if;
update tt_sc set thu=thu+b_thu,thu_qd=thu_qd+b_thu_qd,chi=chi+b_chi,chi_qd=chi_qd+b_chi_qd where
    ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht=b_ngay_ht;
if sql%rowcount=0 then
    insert into tt_sc values (b_ma_dvi,b_ma_nt,b_ma_nh,b_ma_tk,b_thu,b_thu_qd,b_chi,b_chi_qd,0,0,b_ngay_ht,b_idvung);
end if;
for b_rc in (select thu,thu_qd,chi,chi_qd,ngay_ht from tt_sc where
    ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and ma_nh=b_ma_nh and
    ma_tk=b_ma_tk and ngay_ht>=b_ngay_ht order by ngay_ht) loop
    if b_rc.thu=0 and b_rc.thu_qd=0 and b_rc.chi=0 and b_rc.chi_qd=0 then
        delete tt_sc where ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and
            ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht=b_rc.ngay_ht;
    else
        b_ton:=b_ton+b_rc.thu-b_rc.chi; b_ton_qd:=b_ton_qd+b_rc.thu_qd-b_rc.chi_qd;
        update tt_sc set ton=b_ton,ton_qd=b_ton_qd where ma_dvi=b_ma_dvi and ma_nt=b_ma_nt and
            ma_nh=b_ma_nh and ma_tk=b_ma_tk and ngay_ht=b_rc.ngay_ht;
    end if;
end loop;
b_loi:=null;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTT_TH_PH
    (b_idvung number,b_ma_dvi varchar2,b_nv varchar2,b_ma_nt varchar2,b_ma_nh varchar2,b_ma_tk varchar2,
    b_ngay_ht number,b_so_id number,b_tien number,b_tien_qd number,b_loi out varchar2)
AS
    b_xl number; b_xl_qd number; b_con number;
begin
-- Dan - Tong hop chi tiet 1 Record
b_loi:='loi:Loi tong hop phieu:loi';
if FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B')<>'B' and b_ma_nt<>'VND' then
    if b_nv='X' then b_xl:=-b_tien; b_xl_qd:=-b_tien_qd; else b_xl:=b_tien; b_xl_qd:=b_tien_qd; end if;
    select nvl(max(tien),0) into b_con from tt_ph where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_con=0 then
        insert into tt_ph values(b_ma_dvi,b_so_id,b_ma_nt,b_ma_nh,b_ma_tk,b_ngay_ht,b_xl,b_xl_qd,b_idvung);
    elsif b_con+b_xl<>0 then
        update tt_ph set tien=tien+b_xl,tien_qd=tien_qd+b_xl_qd where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        delete tt_ph where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTT_CT_TEST
    (b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_ngay_ht number,b_htoan varchar2,b_l_ct varchar2,b_ngay_ct varchar2,b_nhom varchar2,
    b_phong out varchar2,b_viec varchar2,b_hdong varchar2,b_nvien varchar2,
    b_k_ma_kh varchar2,b_ma_kh varchar2,b_ma_nt_t varchar2,b_ma_tke_t varchar2,
    b_tien_t number,b_noi_te_t number,b_tg_ht_t number,b_tg_tt_t number,b_nha_t varchar2,
    b_tk_nha_t varchar2,b_ma_nt_c varchar2,b_ma_tke_c varchar2,b_tien_c number,b_noi_te_c number,
    b_tg_ht_c number,b_tg_tt_c number,b_nha_c varchar2,b_tk_nha_c varchar2,
    a_so_id pht_type.a_num,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_i3 number; b_c1 varchar2(1); b_c3 varchar2(3); b_noite varchar2(5);
    b_ma_tk varchar2(20); b_lc_t number:=0; b_lc_c number:=0; b_tt varchar2(1); b_idvung number:=FHT_MA_NSD_VUNG(b_ma_dvi,b_nsd);
    b_ma_nt_xl varchar2(5); b_nha_xl varchar2(10); b_tk_nha_xl varchar2(20);
    a_nv_t pht_type.a_var; a_ma_tk_t pht_type.a_var; a_tien_t pht_type.a_num;
begin
-- Dan - Kiem tra chung tu tien te
if b_ngay_ht is null then b_loi:='loi:Nhap ngay hach toan:loi'; return; end if;
if b_htoan is null or b_htoan not in ('H','T') then
    b_loi:='loi:Hach toan: H-Hach toan, T-Treo:loi'; return;
end if;
if b_l_ct is null or b_l_ct not in('TMV','TGV','TMN','TGN','CMV','CGV','CMN','CGN','D') then
    b_loi:='loi:Sai loai chung tu:loi'; return;
end if;
b_loi:='loi:Sai ma nhom CT:loi';
if b_nhom is null then return;
elsif trim(b_nhom) is not null then
    select 0 into b_i1 from kt_ma_lct where ma_dvi=b_ma_dvi and ma=b_nhom;
end if;
b_loi:='loi:Sai ma viec:loi';
if b_viec is null then return; end if;
if trim(b_viec) is not null then
    select ttrang into b_c1 from kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_viec;
    if b_c1<>'D' then return; end if;
end if;
b_loi:='loi:Sai hop dong:loi';
if b_hdong is null then return; end if;
if trim(b_hdong) is not null then
    select ttrang into b_c1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_hdong;
    if b_c1<>'D' then return; end if;
end if;
if FKH_VIEC_HDONG(b_ma_dvi,b_viec,b_hdong)<>'C' then b_loi:='loi:Ma viec va hop dong khong dong bo:loi'; return; end if;
b_loi:='loi:Sai ma nhan vien:loi';
if b_nvien is null then return;
elsif trim(b_nvien) is not null then
    select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_nvien;
end if;
b_phong:=' ';
if b_k_ma_kh is not null and b_ma_kh is not null then
    b_loi:='loi:Sai ma khach hang:loi';
    if b_k_ma_kh in('K','U') then
        select 0 into b_i1 from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='D' then
        select 0 into b_i1 from cn_ma_dl where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='C' then
        select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='B' then
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='N' then
        select 0 into b_i1 from ht_ma_dvi where idvung=b_idvung and ma_goc=b_ma_kh;
    else return;
    end if;
end if;
if b_tien_t is null or b_noi_te_t is null or b_tien_c is null or b_noi_te_c is null then
    b_loi:='loi:Tien phai khac NULL:loi'; return;
end if;
if b_ma_nt_t is null or b_ma_nt_c is null then
    b_loi:='loi:Loai tien phai khac NULL:loi'; return;
end if;
if b_tg_ht_t is null or b_tg_tt_t is null or b_tg_ht_t<=0 or b_tg_tt_t<=0 or
    b_tg_ht_c is null or b_tg_tt_c is null or b_tg_ht_c<=0 or b_tg_tt_c<=0 then
    b_loi:='loi:Sai ty gia:loi'; return;
end if;
if b_nha_t is null or b_tk_nha_t is null or b_nha_c is null or b_tk_nha_c is null then
    b_loi:='loi:Sai ngan hang:loi'; return;
end if;
b_noite:=FTT_TRA_NOITE(b_ma_dvi);
if substr(b_l_ct,1,1)='T' then
    if b_tien_c<>0 or b_noi_te_c<>0 then b_loi:='loi:Khong nhap tien chi:loi'; return; end if;
    if (substr(b_l_ct,2,1)='G' and (b_nha_t=' ' or b_tk_nha_t=' ')) or
       (substr(b_l_ct,2,1)='M' and b_tk_nha_t<>' ') then
        b_loi:='loi:Sai tai khoan ngan hang A tien THU:loi'; return;
    end if;
    if (substr(b_l_ct,3,1)='N' and b_ma_nt_t=b_noite) or (substr(b_l_ct,3,1)='V' and b_ma_nt_t<>b_noite) then
        b_loi:='loi:Sai loai tien THU:loi'; return;
    end if;
elsif substr(b_l_ct,1,1)='C' then
    if b_tien_t<>0 or b_noi_te_t<>0 then b_loi:='loi:Khong nhap tien thu:loi'; return; end if;
    if (substr(b_l_ct,2,1)='G' and (b_nha_c=' ' or b_tk_nha_c=' ')) or
       (substr(b_l_ct,2,1)='M' and b_tk_nha_c<>' ') then
        b_loi:='loi:Sai tai khoan ngan hang A tien CHI:loi'; return;
    end if;
    if (substr(b_l_ct,3,1)='N' and b_ma_nt_c=b_noite) or (substr(b_l_ct,3,1)='V' and b_ma_nt_c<>b_noite) then
        b_loi:='loi:Sai loai tien CHI:loi'; return;
    end if;
end if;
if substr(b_l_ct,1,1) in('T','D') then
    if b_nha_t<>' ' then
        if b_tk_nha_t=' ' then
            b_loi:='loi:Qui tien THU chua dang ky:loi';
            select 0 into b_i1 from tt_ma_qui where ma_dvi=b_ma_dvi and ma=b_nha_t;
        else
            b_loi:='loi:Tai khoan ngan hang A tien THU chua dang ky:loi';
            select 0 into b_i1 from kh_nh_tk where ma_dvi=b_ma_dvi and ma_nh=b_nha_t and ma_tk=b_tk_nha_t;
        end if;
    elsif b_tk_nha_t=' ' then
        select count(*) into b_i1 from tt_ma_qui where ma_dvi=b_ma_dvi;
        if b_i1<>0 then b_loi:='loi:Nhap ma qui:loi'; return; end if;
    end if;
    if b_ma_nt_t=b_noite then
        if b_tien_t=0 then b_loi:='loi:Nhap tien THU:loi'; return; end if;
        if b_noi_te_t<>b_tien_t then b_loi:='loi:Sai tien thu qui doi noi te:loi'; return; end if;
        if b_tg_ht_t<>1 or b_tg_tt_t<>1 then b_loi:='loi:Sai ty gia THU:loi'; return; end if;
    else
        b_loi:='loi:Ma ngoai te THU chua dang ky:loi';
        select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt_t;
        if b_noi_te_t=0 or (b_l_ct='D' and b_tien_t=0) then b_loi:='loi:Nhap tien THU:loi'; return; end if;
    end if;
    select count(*) into b_i1 from kt_ma_lc where ma_dvi=b_ma_dvi;
    if b_i1>0 then
        if b_ma_tke_t is null then b_loi:='loi:Nhap ma luu chuyen THU:loi'; return; end if;
        b_loi:='loi:Ma thong ke THU chua dang ky:loi';
        select tc into b_c1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma_tke_t;
        if b_c1 not in('T','D') or (b_c1='T' and b_l_ct='D') or (b_c1='D' and b_l_ct<>'D') then
            b_loi:='loi:Sai tinh chat ma luu chuyen THU:loi'; return;
        end if;
    end if;
end if;
if substr(b_l_ct,1,1) in('C','D') then
    if b_nha_c<>' ' then
        if b_tk_nha_c=' ' then
            b_loi:='loi:Qui tien CHI chua dang ky:loi';
            select 0 into b_i1 from tt_ma_qui where ma_dvi=b_ma_dvi and ma=b_nha_c;
        else
            b_loi:='loi:Tai khoan ngan hang A tien CHI chua dang ky:loi';
            select 0 into b_i1 from kh_nh_tk where ma_dvi=b_ma_dvi and ma_nh=b_nha_c and ma_tk=b_tk_nha_c;
        end if;
    elsif b_tk_nha_c=' ' then
        select count(*) into b_i1 from tt_ma_qui where ma_dvi=b_ma_dvi;
        if b_i1<>0 then b_loi:='loi:Nhap ma qui:loi'; return; end if;
    end if;
    if b_ma_nt_c=b_noite then
        if b_tien_c=0 then b_loi:='loi:Nhap tien CHI:loi'; return; end if;
        if b_noi_te_c<>b_tien_c then b_loi:='loi:Sai tien chi qui doi noi te:loi'; return; end if;
        if b_tg_ht_c<>1 or b_tg_tt_c<>1 then b_loi:='loi:Sai ty gia CHI:loi'; return; end if;
    else
        b_loi:='loi:Ma ngoai te CHI chua dang ky:loi';
        select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma_nt_c;
        if b_noi_te_c=0 or (b_l_ct='D' and b_tien_c=0) then b_loi:='loi:Nhap tien CHI:loi'; return; end if;
    end if;
    select count(*) into b_i1 from tt_ma_tke where ma_dvi=b_ma_dvi;
    if b_i1>0 then
        if b_ma_tke_c is null then b_loi:='loi:Nhap ma thong ke CHI:loi'; return; end if;
        b_loi:='loi:Ma thong ke CHI chua dang ky:loi';
        select tc into b_c1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma_tke_c;
        if b_c1 not in('C','D') or (b_c1='C' and b_l_ct='D') or (b_c1='D' and b_l_ct<>'D') then
            b_loi:='loi:Sai tinh chat ma luu chuyen CHI:loi'; return;
        end if;
    end if;
end if;
if b_l_ct='D' and b_ma_nt_t=b_ma_nt_c and b_tien_t<>b_tien_c then
    b_loi:='loi:Sai tien chuyen doi:loi'; return;
end if;
if substr(b_l_ct,1,1)<>'T' and b_ma_nt_c<>b_noite and FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B')<>'B' then
    if a_so_id.count=0 then b_loi:='loi:Chon phieu thu:loi'; return; end if;
    b_i2:=0; b_i3:=0;
    for b_lp in 1..a_so_id.count loop
        b_loi:='loi:Sai chi tiet phieu dong #'||to_char(b_lp)||':loi';
        if a_so_id(b_lp) is null or a_tien(b_lp) is null or a_tien(b_lp)<=0 or a_tien_qd(b_lp) is null or a_tien_qd(b_lp)<=0 then return; end if;
        b_loi:='loi:Da chi het phieu dong #'||to_char(b_lp)||':loi';
        select 0 into b_i1 from tt_ph where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        b_loi:='loi:Da thay doi phieu dong #'||to_char(b_lp)||':loi';
        select ma_nt_c,nha_c,tk_nha_c into b_ma_nt_xl,b_nha_xl,b_tk_nha_xl from tt_1 where ma_dvi=b_ma_dvi and so_id=a_so_id(b_lp);
        if b_ma_nt_c<>b_ma_nt_xl or b_nha_c<>b_nha_xl or b_tk_nha_c<>b_tk_nha_xl then return; end if;
        b_i2:=b_i2+a_tien(b_lp); b_i3:=b_i3+a_tien_qd(b_lp);
    end loop;
    if b_i2<>b_tien_c or b_i3<>b_noi_te_c then
        b_loi:='loi:Sai tong tien phieu thu chi tiet:loi'; return;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTT_KTRA_SODU(b_ma_dvi varchar2,b_loi out varchar2)
AS
    b_i1 number; b_ksl varchar2(1); b_so_id number; b_so_ct varchar2(100);
begin
-- Dan - Kiem tra so du tien te
b_loi:='';
b_ksl:=FKH_NV_TSO(b_ma_dvi,'KT','TT','sodu');
if b_ksl<>'K' then
    select count(*) into b_i1 from tt_sc where ma_dvi=b_ma_dvi and (ton<0 or sign(ton)<>sign(ton_qd));
else
    select count(*) into b_i1 from tt_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd);
end if;
if b_i1<>0 then
    if b_ksl<>'K' then
        select trim(ma_nt)||decode(ma_nh,' ','',' #Ngan hang#:'||ma_nh)||
            decode(ma_tk,' ','',' #Tai khoan#:'||ma_tk)||' #Ngay#: '||PKH_SO_CNG(ngay_ht)
            into b_loi from tt_sc where ma_dvi=b_ma_dvi and (ton<0 or sign(ton)<>sign(ton_qd)) and rownum=1;
    else
        select trim(ma_nt)||decode(ma_nh,' ','',' #Ngan hang#:'||ma_nh)||
            decode(ma_tk,' ','',' #Tai khoan#:'||ma_tk)||' #Ngay#: '||PKH_SO_CNG(ngay_ht)
            into b_loi from tt_sc where ma_dvi=b_ma_dvi and sign(ton)<>sign(ton_qd) and rownum=1;
    end if;
    b_loi:='loi:Qua so du #'||trim(b_loi)||':loi'; return;
end if;
if FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B')<>'B' then
    select nvl(min(so_id),0) into b_so_id from tt_ph where ma_dvi=b_ma_dvi and (tien<0 or sign(tien)<>sign(tien_qd));
    if b_so_id<>0 then
        select min(so_tt||decode(so_ph,' ','',':'||so_ph)) into b_so_ct from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
        b_loi:='loi:Qua so du phieu #'||b_so_ct||':loi';
    else
        delete tt_ph where ma_dvi=b_ma_dvi and tien=0;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_HOI_HTOAN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_lk_ht out number,b_qht out varchar2)
AS
begin
-- Dan - Hoi hach toan
PKH_MA_LCT_KBAO_TK(b_ma_dvi,b_nsd,b_pas,b_nv,b_lk_ht);
b_qht:=FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N');
end;
/
create or replace procedure PKH_MA_LCT_KBAO_TK
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_so out number)
AS
begin
-- Dan - Xac dinh nghiep vu lien quan tai khoan hach toan
select count(*) into b_so from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and (ma,ngay)
    in (select ma,max(ngay) from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md group by ma);
end;
/
create or replace procedure PTT_MA_QUI_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
begin
-- Dan - Xem ma quy
open cs_lke for select * from tt_ma_qui where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PKH_HOI_VIEC_HDONG
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_viec out varchar2,b_hdong out varchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Xem co theo doi viec va hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kh_ma_viec where ma_dvi=b_ma_dvi;
if b_i1<>0 then b_viec:='C'; else b_viec:='K'; end if;
select count(*) into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi;
if b_i1<>0 then b_hdong:='C'; else b_hdong:='K'; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_LC_DONG
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dong out number)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke ma luu chuyen
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select count(*) into b_dong from kt_ma_lc where ma_dvi=b_ma_dvi;
end;
/
create or replace procedure PTT_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu tien te theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk='T' then
    select count(*) into b_dong from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||decode(so_ph,' ','','/'||so_ph) so_tt_ph,decode(tien_t,0,tien_c,tien_t) tien,
        row_number() over (order by l_ct,so_ph,so_tt) sott from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_ph,so_tt)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||decode(so_ph,' ','','/'||so_ph) so_tt_ph,decode(tien_t,0,tien_c,tien_t) tien,
        row_number() over (order by l_ct,so_ph,so_tt) sott from tt_1
        where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_ph,so_tt)
        where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PTT_CT_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    cs_1 out pht_type.cs_type,cs_2 out pht_type.cs_type,cs_3 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lk varchar2(100); b_ppt varchar2(1);
begin
-- Dan - Xem chi tiet cua 1 chung tu tien qua ID
delete tt_2_temp_2; delete tt_2_temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu da xoa:loi';
b_ppt:=FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B');
select min(lk) into b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_1 for select a.*,b_lk lk from tt_1 a where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_ppt<>'B' then
    insert into tt_2_temp_1 select so_id_ps,0,0,tien,tien_qd from tt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    insert into tt_2_temp_1 select so_id,tien,tien_qd,0,0 from tt_ph where
        ma_dvi=b_ma_dvi and so_id in (select so_id_ps from tt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id);
    insert into tt_2_temp_2 select so_id,sum(tien),sum(tien_qd),sum(chi),sum(chi_qd) from tt_2_temp_1 group by so_id;
    if b_ppt='T' then
        open cs_2 for select b.so_id,a.tien,a.tien_qd,a.chi,a.chi_qd,b.ngay_ht,so_tt||decode(so_ph,' ','',':'||so_ph) so_ct,nd
            from tt_2_temp_2 a,tt_1 b where b.ma_dvi=b_ma_dvi and b.so_id=a.so_id order by b.ngay_ht,b.so_id;
    else
        open cs_2 for select b.so_id,a.tien,a.tien_qd,a.chi,a.chi_qd,b.ngay_ht,so_tt||decode(so_ph,' ','',':'||so_ph) so_ct,nd
            from tt_2_temp_2 a,tt_1 b where b.ma_dvi=b_ma_dvi and b.so_id=a.so_id order by b.ngay_ht DESC,b.so_id DESC;
    end if;
else
    open cs_2 for select * from tt_2_temp_2;
end if;
open cs_3 for select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete tt_2_temp_2; delete tt_2_temp_1; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_CT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_htoan varchar2,
    b_so_id in out number,b_l_ct varchar2,b_so_tt in out number,b_so_ph varchar2,b_ngay_ct varchar2,
    b_so_ct varchar2,b_nhom varchar2,b_viec varchar2,b_hdong varchar2,b_nvien varchar2,b_nd nvarchar2,b_ndp nvarchar2,b_k_ma_kh varchar2,
    b_ma_kh varchar2,b_ten nvarchar2,b_nguoi_gd nvarchar2,b_cmt varchar2,b_d_chi nvarchar2,b_ma_thue varchar2,
    b_nhb varchar2,b_tk_nhb varchar2,b_ten_nhb nvarchar2,b_ma_nt_t varchar2,b_ma_tke_t varchar2,b_tien_t number,b_noi_te_t number,
    b_tg_ht_t number,b_tg_tt_t number,b_nha_t varchar2,b_tk_nha_t varchar2,b_ma_nt_c varchar2,
    b_ma_tke_c varchar2,b_tien_c number,b_noi_te_c number,b_tg_ht_c number,b_tg_tt_c number,b_nha_c varchar2,b_tk_nha_c varchar2,
    b_loai varchar2,b_pp varchar2,b_t_suat number,b_thue number,b_mau varchar2,b_seri varchar2,b_so_hd varchar2,
    a_so_id in out pht_type.a_num,a_tien_ph pht_type.a_num,a_tien_qd_ph pht_type.a_num,
    a_nv in out pht_type.a_var,a_ma_tk in out pht_type.a_var,a_ma_tke in out pht_type.a_var,
    a_tien in out pht_type.a_num,a_note pht_type.a_nvar,a_bt pht_type.a_num,b_lk out varchar2,b_cbao out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_md varchar2(2); b_htoan_c varchar2(1):=' ';
    b_idvung number; b_ct_kt varchar2(20); b_phong varchar2(10);
begin
-- Dan - Nhap chung tu tien te
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
PKH_MANG(a_nv); PKH_MANG_N(a_so_id);
if b_so_id=0 then
    b_md:='TT'; PHT_ID_MOI(b_so_id,b_loi);
else
    select nvl(min(md),'TT'),nvl(min(htoan),' '),count(*) into b_md,b_htoan_c,b_i1 from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then PTT_TT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'K'); end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTT_CT_TEST(b_ma_dvi,b_nsd,b_md,b_ngay_ht,b_htoan,b_l_ct,b_ngay_ct,b_nhom,b_phong,b_viec,b_hdong,b_nvien,
    b_k_ma_kh,b_ma_kh,b_ma_nt_t,b_ma_tke_t,b_tien_t,b_noi_te_t,b_tg_ht_t,b_tg_tt_t,b_nha_t,b_tk_nha_t,b_ma_nt_c,
    b_ma_tke_c,b_tien_c,b_noi_te_c,b_tg_ht_c,b_tg_tt_c,b_nha_c,b_tk_nha_c,a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTT_TT_NH(b_idvung,b_ma_dvi,b_nsd,b_md,b_ngay_ht,b_htoan,b_so_id,b_l_ct,b_so_tt,b_so_ph,b_ngay_ct,b_so_ct,
    b_nhom,b_phong,b_viec,b_hdong,b_nvien,b_nd,b_ndp,b_k_ma_kh,b_ma_kh,b_ten,b_nguoi_gd,b_cmt,b_d_chi,b_ma_thue,b_nhb,b_tk_nhb,b_ten_nhb,b_ma_nt_t,
    b_ma_tke_t,b_tien_t,b_noi_te_t,b_tg_ht_t,b_tg_tt_t,b_nha_t,b_tk_nha_t,b_ma_nt_c,b_ma_tke_c,b_tien_c,b_noi_te_c,
    b_tg_ht_c,b_tg_tt_c,b_nha_c,b_tk_nha_c,b_loai,b_pp,b_t_suat,b_thue,b_mau,b_seri,b_so_hd,a_so_id,a_tien_ph,a_tien_qd_ph,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_htoan='H' or b_htoan_c='H' then
    PTT_KTRA_SODU(b_ma_dvi,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_ct_kt:=b_l_ct||'-'||substr(to_char(b_ngay_ht),5,2)||'/'||b_so_tt;
if trim(b_so_ph) is not null then b_ct_kt:=b_ct_kt||'/'||b_so_ph; end if;
PKT_CT_NV_XL(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_so_id,b_l_ct,b_ct_kt,b_ngay_ct,b_nd,
    a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_md,'TT',b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_HDONG_TT_KT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_htoan='H' then
    b_cbao:=FKT_KH_CBAO(b_ma_dvi,b_ngay_ht,a_ma_tk);
    if instr(b_cbao,'loi:')=1 then b_loi:=b_cbao; raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_ktra varchar2:='C')
AS
    b_i1 number; b_idvung number; r_tt tt_1%rowtype;
begin
-- Dan - Xoa chung tu tien te
b_loi:='loi:Chung tu dang xu ly:loi';
select count(*),min(b_idvung) into b_i1,b_idvung from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_tt from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 then  return; end if;
if r_tt.htoan='H' then
    if r_tt.nsd<>b_nsd then b_loi:='loi:Khong sua, xoa CT nguoi khac:loi'; return; end if;
    if r_tt.ksoat<>b_nsd and nvl(r_tt.ksoat,' ')<>' ' then b_loi:='loi:Chung tu da kiem soat:loi'; return; end if;
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_tt.ngay_ht,'KT','TT');
    if b_loi is not null then return; end if;
    if r_tt.tien_t<>0 or r_tt.noi_te_t<>0 then
        PTT_TH_CT(b_ma_dvi,b_idvung,'T',r_tt.ma_nt_t,r_tt.nha_t,r_tt.tk_nha_t,-r_tt.tien_t,-r_tt.noi_te_t,r_tt.ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if r_tt.tien_c<>0 or r_tt.noi_te_c<>0 then
        PTT_TH_CT(b_ma_dvi,b_idvung,'C',r_tt.ma_nt_c,r_tt.nha_c,r_tt.tk_nha_c,-r_tt.tien_c,-r_tt.noi_te_c,r_tt.ngay_ht,b_loi);
        if b_loi is not null then return; end if;
    end if;
    if FKH_NV_TSO(b_ma_dvi,'KT','TT','ppt','B')<>'B' then
        if substr(r_tt.l_ct,1,1)<>'T' and r_tt.ma_nt_c<>'VND' then
            for r_lp in (select * from tt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
                select ngay_ht into b_i1 from tt_1 where ma_dvi=b_ma_dvi and so_id=r_lp.so_id_ps;
                PTT_TH_PH(r_tt.idvung,b_ma_dvi,'N',r_lp.ma_nt,r_lp.nha_c,r_lp.tk_nha_c,b_i1,r_lp.so_id_ps,r_lp.tien,r_lp.tien_qd,b_loi);
                if b_loi is not null then return; end if;
            end loop;
        end if;
        if substr(r_tt.l_ct,1,1)<>'C' and r_tt.ma_nt_t<>'VND' then
            PTT_TH_PH(r_tt.idvung,b_ma_dvi,'X',r_tt.ma_nt_t,r_tt.nha_t,r_tt.tk_nha_t,r_tt.ngay_ht,b_so_id,r_tt.tien_t,r_tt.noi_te_t,b_loi);
            if b_loi is not null then return; end if;
        end if;
    end if;
    if b_ktra<>'K' then
        PTT_KTRA_SODU(b_ma_dvi,b_loi);
        if b_loi is not null then return; end if;
    end if;
    PKH_NGAY_TD(b_ma_dvi,'TT',r_tt.ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table TT_2:loi';
delete tt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table TT_1:loi';
delete tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKH_HDONG_TT_KT
    (b_ma_dvi varchar2,b_so_id_g number,b_loi out varchar2)
AS
    b_i1 number; b_ma varchar2(30); b_nhom varchar2(1); b_ngay_ht number; b_l_ct varchar2(3); b_idvung number; b_lket varchar2(100);
    b_so_id number:=0; b_nd nvarchar2(400); b_tien number:=0; b_loai varchar2(1); b_ma_nt varchar2(5);
    r_tt tt_1%rowtype;
begin
-- Dan - Thua huong tu chung tu vat tu, cong no, tien te
b_loi:='loi:Loi tong hop doanh thu, chi phi hop dong:loi';
delete kh_hdong_tt where ma_dvi=b_ma_dvi and so_id_g=b_so_id_g;
select nvl(min(ngay_ht),0) into b_ngay_ht from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id_g;
if b_ngay_ht=0 then b_loi:=''; return; end if;
select nd,lk,idvung into b_nd,b_lket,b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id_g;
if instr(b_lket,'CN:2')>0 then
    for r_lp in (select * from cn_ct where ma_dvi=b_ma_dvi and b_so_id=b_so_id_g) loop
        if r_lp.l_ct='T' and substr(r_lp.ma_ctr,1,1)='H' and length(r_lp.ma_ctr)>1 then
            if trim(r_lp.hdong) is not null then b_ma:=r_lp.hdong;
            elsif trim(r_lp.viec) is not null then
                b_ma:=FKH_MA_HDONG_VIEC(b_ma_dvi,r_lp.viec);
            end if;
            if trim(b_ma) is not null and b_ma!='*' then
                b_loi:='loi:Da xoa ma hop dong:loi';
                select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
                if FKH_MA_HDONG_NTE(b_ma_dvi,b_ma)<>r_lp.ma_nt then b_loi:='loi:Sai loai tien hop dong:loi'; return; end if;
                b_nhom:=FKH_MA_HDONG_NHOM(b_ma_dvi,b_ma);
                if b_nhom='B' then b_loai:='T'; else b_loai:='C'; end if;
                PHT_ID_MOI(b_so_id,b_loi);
                if b_loi is not null then return; end if;  
                insert into kh_hdong_tt values(b_ma_dvi,b_so_id,b_ma,b_ngay_ht,b_loai,r_lp.tien,b_nd,'',sysdate,b_so_id_g,b_idvung);
            end if;
        end if;
    end loop;
end if;
if b_so_id=0 and instr(b_lket,'TT:2')>0 then
    select * into r_tt from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id_g;
    b_loai:=substr(r_tt.l_ct,1,1);
    if b_loai in('T','C') then
        if trim(r_tt.hdong) is not null then b_ma:=r_tt.hdong;
        elsif trim(r_tt.viec) is not null then
            b_ma:=FKH_MA_HDONG_VIEC(b_ma_dvi,r_tt.viec);
        end if;
        if trim(b_ma) is not null and b_ma!='*' then
            b_loi:='loi:Da xoa ma hop dong:loi';
            select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
            if b_loai='T' then
                b_tien:=r_tt.tien_t; b_ma_nt:=r_tt.ma_nt_t;
            else
                b_tien:=r_tt.tien_c; b_ma_nt:=r_tt.ma_nt_c;
            end if;
            if FKH_MA_HDONG_NTE(b_ma_dvi,b_ma)=b_ma_nt then
                PHT_ID_MOI(b_so_id,b_loi);
                if b_loi is not null then return; end if;  
                insert into kh_hdong_tt values(b_ma_dvi,b_so_id,b_ma,b_ngay_ht,b_loai,b_tien,b_nd,'',sysdate,b_so_id_g,b_idvung);
            end if;
        end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKH_MA_HDONG_NTE(b_ma_dvi varchar2,b_ma varchar2) return varchar2
as
    b_kq varchar2(5);
begin
-- Dan - Tra nguyen te hop dong
select nvl(min(ma_nt),'VND') into b_kq from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace function FKH_MA_HDONG_NHOM(b_ma_dvi varchar2,b_ma varchar2) return varchar2
as
    b_kq varchar2(1);
begin
-- Dan - Tra nhom hop dong
select nvl(min(nhom),'M') into b_kq from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
return b_kq;
end;
/
create or replace procedure PTT_KTRA_LKET
    (b_ma_dvi varchar2,b_so_id number,b_tt out varchar2,b_loi out varchar2)
AS
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var;
    a_tien pht_type.a_num; b_lk varchar2(100); b_htoan varchar2(1);
    a_nv_t pht_type.a_var;a_ma_tk_t pht_type.a_var; a_tien_t pht_type.a_num;
    r_tt tt_1%rowtype; b_c3 varchar2(3); b_noite varchar2(5); b_i1 number;
begin
-- Dan - Kiem tra can doi hach toan va tien te
b_loi:='';
select count(*) into b_i1 from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then PTT_NV_NH(b_ma_dvi,b_so_id,b_tt,b_loi); return; end if;
select * into r_tt from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if r_tt.htoan='T' then b_tt:='0'; b_loi:=''; return; end if;
if (r_tt.nha_t=r_tt.nha_c or (r_tt.nha_t<>' ' and r_tt.nha_c<>' '))
    and r_tt.noi_te_t=r_tt.noi_te_c and a_nv.count=0 then b_tt:='2'; return;
end if;
if FKH_MA_LCT_NVTK(b_ma_dvi,'TT',r_tt.l_ct,r_tt.ngay_ht)='K' then b_tt:='2'; return; end if;
PKT_TRA_KT2(b_ma_dvi,b_so_id,a_nv,a_ma_tk,a_ma_tke,a_tien,b_lk,b_loi);
if b_loi is not null then return; end if;
b_noite:=FTT_TRA_NOITE(b_ma_dvi); b_i1:=0;
if r_tt.noi_te_t<>0 then
    b_i1:=b_i1+1; a_nv_t(b_i1):='N'; a_tien_t(b_i1):=r_tt.noi_te_t;
    if trim(r_tt.tk_nha_t) is null then b_c3:='TM'; else b_c3:='TG'; end if;
    if r_tt.ma_nt_t=b_noite then b_c3:=trim(b_c3)||'V'; else b_c3:=trim(b_c3)||'N'; end if;
    a_ma_tk_t(b_i1):=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT',b_c3,r_tt.ngay_ht,a_nv_t(b_i1));
    if trim(a_ma_tk_t(b_i1)) is null then b_loi:='loi:Chua dinh nghia loai chung tu#'||b_c3||':loi'; return; end if;
end if;
if r_tt.noi_te_c<>0 then
    b_i1:=b_i1+1; a_nv_t(b_i1):='C'; a_tien_t(b_i1):=r_tt.noi_te_c;
    if trim(r_tt.tk_nha_c) is null then b_c3:='CM'; else b_c3:='CG'; end if;
    if r_tt.ma_nt_c=b_noite then b_c3:=trim(b_c3)||'V'; else b_c3:=trim(b_c3)||'N'; end if;
    a_ma_tk_t(b_i1):=PKH_MA_LCT_TRA_TK(b_ma_dvi,'TT',b_c3,r_tt.ngay_ht,a_nv_t(b_i1));
    if trim(a_ma_tk_t(b_i1)) is null then b_loi:='loi:Chua dinh nghia loai chung tu#'||b_c3||':loi'; return; end if;
end if;
PKH_MA_LCT_CDOI_TK(b_ma_dvi,'TT',r_tt.l_ct,r_tt.ngay_ht,a_nv,a_ma_tk,a_tien,a_nv_t,a_ma_tk_t,a_tien_t,b_tt);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKH_MA_LCT_NVTK
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number) return varchar2
AS
    b_d1 number; b_i1 number; b_kq varchar2(1):='K'; b_tc varchar2(1);
begin
-- Dan - Xac dinh loai chung tu co dinh khoan
select nvl(max(ngay),0) into b_d1 from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay<=b_ngay;
if b_d1<>0 then
    select tc into b_tc from kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_d1;
    if b_tc='B' then b_kq:='C';
    else
        select count(*) into b_i1 from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_d1 and nv in('N','C','T');
        if b_i1<>0 then b_kq:='C'; end if;
    end if;
end if;
return b_kq;
end;
/
create or replace procedure PKH_MA_LCT_CDOI_TK
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,a_tien pht_type.a_num,
    a_nv_n pht_type.a_var,a_ma_tk_n pht_type.a_var,a_tien_n pht_type.a_num,b_tt out varchar2)
AS
    a_nv_k pht_type.a_var; a_ma_tk_k pht_type.a_var; a_tien_k pht_type.a_num;
    a_ma_tk_p pht_type.a_var; a_tien_p pht_type.a_num; b_i1 number;
begin
-- Dan - Kiem tra can doi nghiep vu tai khoan
b_tt:='2';
if FKH_MA_LCT_NVBK(b_ma_dvi,b_md,b_ma,b_ngay)='C' then
    PKH_MA_LCT_TKBK(b_ma_dvi,b_md,b_ngay,a_nv,a_ma_tk,a_nv_k,a_ma_tk_k);
elsif FKH_MA_LCT_NVTK(b_ma_dvi,b_md,b_ma,b_ngay)='C' then
    PKH_MA_LCT_TK(b_ma_dvi,b_md,b_ngay,a_nv,a_ma_tk,a_nv_k,a_ma_tk_k,b_ma);
else
    return;
end if;
if a_nv_k.count=0 and a_nv_n.count=0 then return; end if;
PKH_MA_LCT_TIEN(a_nv,a_ma_tk,a_tien,a_nv_k,a_ma_tk_k,a_tien_k);
PKH_MANG_KD(a_ma_tk_p);
for b_lp in 1..a_nv_n.count loop
    b_i1:=0;
    for b_lp1 in 1..a_ma_tk_p.count loop
        if a_ma_tk_p(b_lp1)=a_ma_tk_n(b_lp) then b_i1:=b_lp1; exit; end if;
    end loop;
    if b_i1=0 then b_i1:=a_ma_tk_p.count+1; a_ma_tk_p(b_i1):=a_ma_tk_n(b_lp); a_tien_p(b_i1):=0; end if;
    if a_nv_n(b_lp)='N' then a_tien_p(b_i1):=a_tien_p(b_i1)+a_tien_n(b_lp); else a_tien_p(b_i1):=a_tien_p(b_i1)-a_tien_n(b_lp); end if;
end loop;
for b_lp in 1..a_nv_k.count loop
    b_i1:=0;
    for b_lp1 in 1..a_ma_tk_p.count loop
        if PKH_MA_LMA_C(a_ma_tk_p(b_lp1),a_ma_tk_k(b_lp))='C' then b_i1:=b_lp1; exit; end if;
    end loop;
    if b_i1=0 then b_tt:='1'; return; end if;
    if a_nv_k(b_lp)='N' then a_tien_p(b_i1):=a_tien_p(b_i1)-a_tien_k(b_lp); else a_tien_p(b_i1):=a_tien_p(b_i1)+a_tien_k(b_lp); end if;
end loop;
for b_lp in 1..a_ma_tk_p.count loop
    if a_tien_p(b_lp)<>0 then b_tt:='1'; return; end if;
end loop;
end;
/
create or replace procedure PKH_MA_LCT_TKBK
    (b_ma_dvi varchar2,b_md varchar2,b_ngay number,a_nv pht_type.a_var,
    a_ma_tk pht_type.a_var,a_nv_l out pht_type.a_var,a_ma_tk_l out pht_type.a_var)
AS
    b_i1 number; b_xl number:=0; a_nv_n pht_type.a_var; a_ma_tk_n pht_type.a_lvar; a_xl pht_type.a_var;
begin
-- Dan - Xac dinh tai khoan bat ky lien quan nghiep vu
PKH_MANG_KD(a_nv_l);
for b_lp in 1..a_nv.count loop
    a_xl(b_lp):='K';
end loop;
for r_lp in(select distinct ma from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md) loop
    PKH_MA_LCT_NVTK(b_ma_dvi,b_md,r_lp.ma,b_ngay,a_nv_n,a_ma_tk_n);
    for b_lp in 1..a_nv.count loop
        if a_xl(b_lp)='K' then
            b_i1:=0;
            for b_lp1 in 1..a_nv_n.count loop
                if a_nv_n(b_lp1) in('T',a_nv(b_lp)) and PKH_MA_LMA_C(a_ma_tk_n(b_lp1),a_ma_tk(b_lp))='C' then b_i1:=1; exit; end if;
            end loop;
            if b_i1<>0 then
                b_i1:=a_nv_l.count+1;
                a_nv_l(b_i1):=a_nv(b_lp); a_ma_tk_l(b_i1):=a_ma_tk(b_lp); b_xl:=b_xl+1; exit;
            end if;
        end if;
    end loop;
    if b_xl=a_nv.count then exit; end if;
end loop;
end;
/
create or replace procedure PTT_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_klk varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_klk ='T' then
    select count(*) into b_dong from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by l_ct,so_ph,so_tt) sott
        from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_ph,so_tt) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||decode(so_ph,' ','','/'||so_ph) so_tt_ph,decode(tien_t,0,tien_c,tien_t) tien,
        row_number() over (order by l_ct,so_ph,so_tt) sott
        from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_ph,so_tt) where sott between b_tu and b_den;
else
    select count(*) into b_dong from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by l_ct,so_ph,so_tt) sott
        from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_ph,so_tt) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||decode(so_ph,' ','','/'||so_ph) so_tt_ph,decode(tien_t,0,tien_c,tien_t) tien,
        row_number() over (order by l_ct,so_ph,so_tt) sott
        from tt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by l_ct,so_ph,so_tt) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_d number,b_ngay_c number,b_treo varchar2,b_dc varchar2,b_l_ct varchar2,
    b_phong varchar2,b_nha varchar2,b_nhb varchar2,b_so_ph_d number,b_so_ph_c number,
    b_tien_d number,b_tien_c number,b_ten nvarchar2,b_d_chi nvarchar2,b_nd nvarchar2,
    b_so_ph_dk varchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Tim kiem chung tu tien te
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
insert into temp_1(n1) select so_id from tt_1 where
    ma_dvi=b_ma_dvi and htoan in('T',b_treo) and (ngay_ht between b_ngay_d and b_ngay_c) and
    (b_l_ct is null or l_ct=b_l_ct) and (b_phong is null or phong=b_phong) and
    (b_nha is null or nha_t like b_nha) and (b_nhb is null or nha_c like b_nhb) and
    (b_nd is null or upper(nd) like b_nd) and (b_d_chi is null or upper(d_chi) like b_d_chi) and
    (b_ten is null or upper(nguoi_gd) like b_ten);
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where
    ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'TT:0')=0 and instr(lk,'TT:1')=0);
end if;
if b_tien_d<>0 or b_tien_c=0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.e18;
    elsif b_tien_d=0 then b_n1:=-1.e18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where exists(select * from tt_1 where ma_dvi=b_ma_dvi and so_id=n1 and
        (tien_t not between b_n1 and b_n2) and (tien_c not between b_n1 and b_n2));
end if;
if b_so_ph_d is not null or b_so_ph_c is not null then
    if b_so_ph_c is null then b_n1:=PKH_LOC_CHU_SO(b_so_ph_d); b_n2:=1.e18;
    elsif b_so_ph_d is null then b_n1:=-1; b_n2:=PKH_LOC_CHU_SO(b_so_ph_c);
    else b_n1:=PKH_LOC_CHU_SO(b_so_ph_d); b_n2:=PKH_LOC_CHU_SO(b_so_ph_c);
    end if;
    if b_so_ph_dk='P' then
        delete temp_1 where exists(select * from tt_1 where ma_dvi=b_ma_dvi and
            so_id=n1 and (PKH_LOC_CHU_SO(so_ph) not between b_n1 and b_n2));
    else    delete temp_1 where exists(select * from tt_1 where ma_dvi=b_ma_dvi and
            so_id=n1 and (so_tt not between b_n1 and b_n2));
    end if;
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,so_tt,so_ph,decode(tien_t,0,tien_c,tien_t) tien,nd,PKH_SO_CNG(ngay_ht) ngay_htc,
    row_number() over (order by ngay_ht,l_ct,PKH_LOC_CHU_SO(so_tt)) sott from tt_1,temp_1
    where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,PKH_LOC_CHU_SO(so_tt))
    where sott between b_tu and b_den;
end;
/
create or replace procedure PKT_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu cong no theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    select count(*) into b_dong from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||':'||trim(so_ct) so_ct,tien,nd,nsd,row_number() over (order by so_id) sott
        from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||':'||trim(so_ct) so_ct,tien,nd,nsd,row_number() over (order by so_id) sott
        from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PKT_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lcdoi number;
begin
-- Dan - Xem chi tiet cua 1 chung tu qua ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select count(*) into b_lcdoi from kt_lcdoi where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs1 for select b_lcdoi lcdoi,a.* from kt_1 a where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs2 for select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
 
/
create or replace procedure PKT_CT_SUA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_htoan varchar2,
    b_ngay_ht number,b_l_ct varchar2,b_so_tt in out number,b_so_ct in out varchar2,
    b_ngay_ct varchar2,b_nd nvarchar2,b_ndp nvarchar2,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,
    a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_note pht_type.a_nvar,
    a_bt pht_type.a_num,b_so_id number,b_lk out varchar2,b_cbao out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_ngay_ht_c number;
    b_nsd_c varchar2(10); b_htoan_c varchar2(1); b_md varchar2(2);
begin
-- Dan - Sua chung tu ke toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select md,nsd,htoan,lk into b_md,b_nsd_c,b_htoan_c,b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_md not in('BH','HD','HO','KP') then
    b_loi:='loi:Sua hach toan tu nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_nsd_c is null or b_nsd_c=b_nsd then
    PKT_KT_SUA(b_ma_dvi,b_nsd,'KT',b_htoan,b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,
        b_nd,b_ndp,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_loi);
elsif instr(b_lk,'TK')<>0 and b_htoan_c='H' and b_htoan='H' then
    PKT_CT_HTHIEN(b_ma_dvi,b_nsd,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_loi);
else
    b_loi:='loi:Khong sua chung tu nguoi khac:loi'; raise PROGRAM_ERROR;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_htoan='H' then
    b_cbao:=FKT_KH_CBAO(b_ma_dvi,b_ngay_ht,a_ma_tk);
    if instr(b_cbao,'loi:')=1 then b_loi:=b_cbao; raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_CT_HTHIEN
    (b_ma_dvi varchar2,b_nsd varchar2,a_nv pht_type.a_var,a_ma_tk pht_type.a_var,
    a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_note pht_type.a_nvar,
    a_bt pht_type.a_num,b_so_id number,b_lk out varchar2,b_loi out varchar2)
AS
    b_ngay_ht number; b_l_ct varchar2(5); b_i1 number; b_i2 number; b_idvung number;
    a_tc pht_type.a_var; a_nv_s pht_type.a_var; a_ma_tk_s pht_type.a_var; a_tien_s pht_type.a_num;
    a_nv_c pht_type.a_var; a_ma_tk_c pht_type.a_var; a_ma_tke_c pht_type.a_var; a_tc_c pht_type.a_var; a_tien_c pht_type.a_num;
begin
-- Dan - Hoan thien chung tu ke toan
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht,l_ct,lk,idvung into b_ngay_ht,b_l_ct,b_lk,b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
if b_loi is not null then return; end if;
PKH_MANG_KD(a_nv_s); PKH_MANG_KD(a_nv_c);
for b_lp in 1..a_nv.count loop
    b_i1:=1;
    while b_i1<=a_nv_s.count loop
        if a_nv_s(b_i1)=a_nv(b_lp) and a_ma_tk_s(b_i1)=a_ma_tk(b_lp) then
            a_tien_s(b_i1):=a_tien_s(b_i1)+a_tien(b_lp); exit;
        end if;
        b_i1:=b_i1+1;
    end loop;
    if b_i1>a_nv_s.count then
        a_nv_s(b_i1):=a_nv(b_lp); a_ma_tk_s(b_i1):=a_ma_tk(b_lp); a_tien_s(b_i1):=a_tien(b_lp);
    end if;
end loop;
b_i1:=0;
for b_rc in (select nv,ma_tk,ma_tke,tien from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    b_i1:=b_i1+1; a_nv_c(b_i1):=b_rc.nv; a_ma_tk_c(b_i1):=b_rc.ma_tk;
    a_ma_tke_c(b_i1):=b_rc.ma_tke; a_tien_c(b_i1):=-b_rc.tien;
    b_i2:=1;
    while b_i2<=a_nv_s.count loop
        if a_nv_s(b_i2)=a_nv_c(b_i1) and a_ma_tk_s(b_i2)=a_ma_tk_c(b_i1) then
            a_tien_s(b_i2):=a_tien_s(b_i2)+a_tien_c(b_i1); exit;
        end if;
        b_i2:=b_i2+1;
    end loop;
    if b_i2>a_nv_s.count then b_loi:='loi:Khong bot tai khoan#'||rtrim(a_ma_tk_c(b_i1))||':loi'; return; end if;
end loop;
for b_lp in 1..a_nv_s.count loop
    if a_tien_s(b_lp)<>0 then b_loi:='loi:Khong thay doi tong tien tai khoan#'||rtrim(a_ma_tk_s(b_lp))||':loi'; return; end if;
end loop;
PKT_TCHAT(b_ma_dvi,a_ma_tk,a_tc,b_loi);
if b_loi is not null then return; end if;
PKT_THOP_CT(b_idvung,b_ma_dvi,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tien,b_loi);
if b_loi is not null then return; end if;
PKT_THOP_CT(b_idvung,b_ma_dvi,b_ngay_ht,a_nv_c,a_ma_tk_c,a_ma_tke_c,a_tien_c,b_loi);
if b_loi is not null then return; end if;
PKT_KTRA_SODU(b_ma_dvi,b_ngay_ht,a_ma_tk,a_ma_tke,a_tc,b_loi);
if b_loi is not null then return; end if;
PKT_TCHAT(b_ma_dvi,a_ma_tk_c,a_tc_c,b_loi);
if b_loi is not null then return; end if;
PKT_KTRA_SODU(b_ma_dvi,b_ngay_ht,a_ma_tk_c,a_ma_tke_c,a_tc_c,b_loi);
if b_loi is not null then return; end if;
PKT_LKET_SUA_TKE(b_ma_dvi,b_so_id,a_ma_tke,a_tc,b_lk,b_loi);
if b_loi is not null then return; end if;
PKT_KT3_XOA(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then return; end if;
PKT_KT3_NH(b_idvung,b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,b_loi);
if b_loi is not null then return; end if;
b_loi:='loi:Loi Table KT_1:loi';
update kt_1 set hth=b_nsd where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table KT_2:loi';
delete kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKT_KT2_NH(b_idvung,b_ma_dvi,b_so_id,b_ngay_ht,a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_tc,a_bt,b_loi);
if b_loi is not null then return; end if;
PKT_BP_THOP(b_ma_dvi,'N',b_so_id,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LKET_SUA_TKE
    (b_ma_dvi varchar2,b_so_id number,a_ma_tke pht_type.a_var,
    a_tc pht_type.a_var,b_lk in out varchar2,b_loi out varchar2)
AS
    b_c1 varchar2(1); b_i1 number; b_l_ct varchar2(5); b_ngay_ht number;
begin
-- Dan - Sua lien ket khi bo xung thong ke chung tu hanh toan
b_loi:='loi:Loi Table KT_1:loi';
select ngay_ht,l_ct into b_ngay_ht,b_l_ct from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_i1:=instr(b_lk,'TK'); b_c1:=FKT_LKET_TKE(a_ma_tke,a_tc,b_l_ct);
if b_c1=' ' then b_lk:=replace(b_lk,substr(b_lk,b_i1,4),'');
else b_lk:=replace(b_lk,substr(b_lk,b_i1,4),'TK:'||b_c1);
end if;
update kt_1 set lk=b_lk where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_klk varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    select count(*) into b_dong from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott
        from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||':'||trim(so_ct) so_ct,tien,nd,nsd,row_number() over (order by so_id) sott
        from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    select nvl(min(sott),b_dong) into b_tu from (select so_id,row_number() over (order by so_id) sott
        from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) where so_id>=b_so_id;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select so_id,l_ct,to_char(so_tt)||':'||trim(so_ct) so_ct,tien,nd,nsd,row_number() over (order by so_id) sott
        from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PTV_MA_HD_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
	b_loi varchar2(100); b_idvung number;
begin
--- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TV','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null or trim(b_ten) is null then b_loi:='loi:Nhap ma, ten:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham nguoi su dung:loi';
delete tv_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
insert into tv_ma_hd values(b_ma_dvi,b_ma,b_ten,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_MA_NHOM_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_tc varchar2,b_loai varchar2)
AS
    b_loi varchar2(100); b_idvung number;
begin
--- Dan - Nhap ma nhom thue
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TV','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc not in ('C','T') then
    b_loi:='loi:Tinh chat:C-Chi tiet; T-Tong:loi'; raise PROGRAM_ERROR;
end if;
if b_loai is null or b_loai not in ('V','R') then
    b_loi:='loi:Loai nhom:V-Dau vao; R-Dau ra:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Va cham nguoi su dung:loi';
delete tv_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
insert into tv_ma_nhom values(b_ma_dvi,b_ma,b_ten,b_tc,b_loai,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_NGAY_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_kieu_c varchar2(1);
begin
-- Hung - Xem ngay bao cao thue
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from tv_ngay where ma_dvi=b_ma_dvi;
end;
/
create or replace procedure PKH_MA_LCT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma varchar2,b_ngay number)
AS
    b_loi varchar2(250); b_md_k varchar2(10):=b_md;
begin
-- Dan - Xoa ma loai chung tu
if b_md in('BP','LC') then b_md_k:='KT'; end if;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_md_k,'Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Nhap so lieu sai:loi';
if b_ma is null or b_ngay is null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table MA_LCT:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md=b_md and ma=b_ma and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCD_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_d number,
    b_ngay_c number,b_treo varchar2,b_dc varchar2,b_l_ct varchar2,b_dvi varchar2,
    b_so_ct varchar2,b_tien_d number,b_tien_c number,b_nd nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Tim kiem chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CD','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; commit;
insert into temp_1(n1,c1,c2,c3,c4,c5,n2) select so_id,l_ct,htoan,nd,so_ct,dvi,tien from cd_ch
    where ma_dvi=b_ma_dvi and (ngay_ht between b_ngay_d and b_ngay_c);
if b_l_ct is not null then delete temp_1 where c1<>b_l_ct; end if;
if b_treo='C' then delete temp_1 where c2='T'; end if;
if b_so_ct is not null then delete temp_1 where c4<>b_so_ct; end if;
if b_nd is not null then delete temp_1 where upper(c3) not like b_nd; end if;
if b_dvi is not null then delete temp_1 where c5 not like b_dvi; end if;
if b_tien_d<>0 or b_tien_c<>0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.E18;
    elsif b_tien_d=0 then b_n1:=-1.E18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where n2<b_n1 or n2>b_n2;
end if;
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'CD:0')=0 and instr(lk,'CD:1')=0);
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,so_ct,dvi,nsd,tien,nd,ngay_ht,row_number() over (order by ngay_ht,l_ct,so_id) sott 
    from cd_ch,temp_1 where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,so_id) where sott between b_tu and b_den;
end;
/
create or replace procedure PVT_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_d number,b_ngay_c number,b_treo varchar2,b_dc varchar2,b_l_ct varchar2,
    b_kho varchar2,b_ma_vt varchar2,b_ma_kh varchar2,b_ten nvarchar2,
    b_tien_d number,b_tien_c number,b_nd nvarchar2,b_hdong varchar2,b_viec varchar2,b_nvien varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n; 
begin
-- Dan - Tim kiem chung tu vat tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; delete temp_2; commit;
insert into temp_1(n1) select so_id from vt_1 where ma_dvi=b_ma_dvi and b_treo in(' ',htoan)
    and (b_l_ct is null or l_ct=b_l_ct) and (ngay_ht between b_ngay_d and b_ngay_c)
    and (b_ma_kh is null or ma_kh like b_ma_kh) and (b_nd is null or upper(nd) like b_nd) and (b_ten is null or upper(ten) like b_ten);
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where
    ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'VT:0')=0 and instr(lk,'VT:1')=0);
end if;
if b_tien_d<>0 or b_tien_c=0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.E18;
    elsif b_tien_d=0 then b_n1:=-1.E18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where not exists(select * from vt_1 where ma_dvi=b_ma_dvi and so_id=n1 and (tien between b_n1 and b_n2));
end if;
if b_kho is not null then
    delete temp_1 where not exists(select * from vt_2 where ma_dvi=b_ma_dvi and so_id=n1 and kho=b_kho);
end if;
if b_ma_vt is not null then
    delete temp_1 where not exists(select * from vt_2 where ma_dvi=b_ma_dvi and so_id=n1 and ma_vt like b_ma_vt);
end if;
if b_hdong is not null or b_viec is not null or b_nvien is not null then
    insert into temp_2(n1) select so_id from vt_2 where ma_dvi=b_ma_dvi 
        and (b_hdong is null or hdongBC like b_hdong or hdongBC like b_hdong)
        and (b_viec is null or Cviec like b_viec) and (b_nvien is null or Cnvien like b_nvien);
    insert into temp_2(n1) select so_id from vt_1 where ma_dvi=b_ma_dvi
        and (b_hdong is null or hdongB like b_hdong or hdongB like b_hdong)
        and (b_viec is null or viec like b_viec) and (b_nvien is null or nvien like b_nvien);
    delete temp_1 a where not exists(select * from temp_2 b where b.n1=a.n1);
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,trim(so_tt)||':'||trim(so_ct) so_ct,tien,nd,pkh_so_cng(ngay_ht) ngay_htc,
    row_number() over (order by ngay_ht,l_ct,so_tt) sott from vt_1,temp_1
    where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,so_tt)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PCD_CT_LKE_LCT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke loai chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CD','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select ma,min(ten) ten from kh_ma_lct where ma_dvi=b_ma_dvi and md='CD' group by ma order by decode(ma,'TD',1,'CD',2,'DT',3,'DC',4,5);
end;
/
create or replace procedure PCN_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_d number,b_ngay_c number,
    b_treo varchar2,b_dc varchar2,b_ma_cn varchar2,b_ten nvarchar2,b_ma_tk varchar2,
    b_viec varchar2,b_hdong varchar2,b_tien_d number,b_tien_c number,b_nd nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n;-- b_dong number;
begin
-- Dan - Tim kiem chung tu cong no
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; commit;
insert into temp_1(n1) select so_id from cn_ch where ma_dvi=b_ma_dvi and htoan in('T',b_treo) and
    (ngay_ht between b_ngay_d and b_ngay_c) and (b_nd is null or upper(nd) like b_nd);
if b_tien_d<>0 or b_tien_c<>0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.E18;
    elsif b_tien_d=0 then b_n1:=-1.E18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where not exists(select * from cn_ct where
        ma_dvi=b_ma_dvi and so_id=n1 and (tien between b_n1 and b_n2));
end if;
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where
    ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'CN:2')>0);
end if;
if b_ma_cn is not null then
    delete temp_1 where not exists(select * from cn_ct where
        ma_dvi=b_ma_dvi and so_id=n1 and ma_cn like b_ma_cn);
end if;
if b_ten is not null then
    delete temp_1 where not exists(select * from cn_ct where
        ma_dvi=b_ma_dvi and so_id=n1 and upper(FCN_MA_TEN(b_ma_dvi,ma_cn)) like b_ten);
end if;
if b_ma_tk is not null then
    delete temp_1 where not exists(select * from cn_ct where
        ma_dvi=b_ma_dvi and so_id=n1 and ma_tk like b_ma_tk);
end if;
if b_viec is not null then
    delete temp_1 where not exists(select * from cn_ct where ma_dvi=b_ma_dvi and so_id=n1 and viec like b_viec);
end if;
if b_hdong is not null then
    delete temp_1 where not exists(select * from cn_ct where ma_dvi=b_ma_dvi and so_id=n1 and hdong like b_hdong);
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,so_ct,tien,nd,PKH_SO_CNG(ngay_ht) ngay_htc,row_number() over (order by ngay_ht,so_id) sott 
    from cn_ch,temp_1 where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,so_id) where sott between b_tu and b_den;
end;
/
create or replace function FCN_MA_TEN
    (b_ma_dvi varchar2,b_ma varchar2) return nvarchar2
AS
    b_nv varchar2(1); b_ma_cn varchar2(20); b_ten nvarchar2(200):=' ';
begin
-- Dan - Tra ten
b_nv:=substr(b_ma,1,1); b_ma_cn:=substr(b_ma,2);
if b_nv in ('K','U','I') then select ten into b_ten from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_cn;
elsif b_nv='D' then select ten into b_ten from cn_ma_dl where ma_dvi=b_ma_dvi and ma=b_ma_cn;
elsif b_nv='C' then select ten into b_ten from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_cn;
elsif b_nv='B' then select ten into b_ten from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma_cn;
elsif b_nv='N' then select ten into b_ten from ht_ma_dvi where ma=b_ma_cn;
end if;
return b_ten;
end;
/
create or replace procedure PVT_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_d number,b_ngay_c number,b_treo varchar2,b_dc varchar2,b_l_ct varchar2,
    b_kho varchar2,b_ma_vt varchar2,b_ma_kh varchar2,b_ten nvarchar2,
    b_tien_d number,b_tien_c number,b_nd nvarchar2,b_hdong varchar2,b_viec varchar2,b_nvien varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n; 
begin
-- Dan - Tim kiem chung tu vat tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; delete temp_2; commit;
insert into temp_1(n1) select so_id from vt_1 where ma_dvi=b_ma_dvi and b_treo in(' ',htoan)
    and (b_l_ct is null or l_ct=b_l_ct) and (ngay_ht between b_ngay_d and b_ngay_c)
    and (b_ma_kh is null or ma_kh like b_ma_kh) and (b_nd is null or upper(nd) like b_nd) and (b_ten is null or upper(ten) like b_ten);
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where
    ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'VT:0')=0 and instr(lk,'VT:1')=0);
end if;
if b_tien_d<>0 or b_tien_c=0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.E18;
    elsif b_tien_d=0 then b_n1:=-1.E18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where not exists(select * from vt_1 where ma_dvi=b_ma_dvi and so_id=n1 and (tien between b_n1 and b_n2));
end if;
if b_kho is not null then
    delete temp_1 where not exists(select * from vt_2 where ma_dvi=b_ma_dvi and so_id=n1 and kho=b_kho);
end if;
if b_ma_vt is not null then
    delete temp_1 where not exists(select * from vt_2 where ma_dvi=b_ma_dvi and so_id=n1 and ma_vt like b_ma_vt);
end if;
if b_hdong is not null or b_viec is not null or b_nvien is not null then
    insert into temp_2(n1) select so_id from vt_2 where ma_dvi=b_ma_dvi 
        and (b_hdong is null or hdongBC like b_hdong or hdongBC like b_hdong)
        and (b_viec is null or Cviec like b_viec) and (b_nvien is null or Cnvien like b_nvien);
    insert into temp_2(n1) select so_id from vt_1 where ma_dvi=b_ma_dvi
        and (b_hdong is null or hdongB like b_hdong or hdongB like b_hdong)
        and (b_viec is null or viec like b_viec) and (b_nvien is null or nvien like b_nvien);
    delete temp_1 a where not exists(select * from temp_2 b where b.n1=a.n1);
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,trim(so_tt)||':'||trim(so_ct) so_ct,tien,nd,pkh_so_cng(ngay_ht) ngay_htc,
    row_number() over (order by ngay_ht,l_ct,so_tt) sott from vt_1,temp_1
    where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,so_tt)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PKT_TH_PBO
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_i3 number; b_ngay date; b_ngayd number; b_so_id number; b_kt number; b_ng_pb number;
    b_tien number; b_l_ct varchar2(10); b_sp varchar2(1):='K';
    a_bt pht_type.a_num; a_nhom pht_type.a_var; a_dvi pht_type.a_var; a_phong pht_type.a_var;
    a_ma_cb pht_type.a_var; a_viec pht_type.a_var; a_hdong pht_type.a_var;
    a_ma_ttr pht_type.a_var; a_ma_lvuc pht_type.a_var; a_sp pht_type.a_var; a_tien pht_type.a_num;
    a_xl_phong pht_type.a_var; a_xl_sp pht_type.a_var; a_xl_tien pht_type.a_num;

    b_bp_xl number; b_bp_kt number:=0; b_sp_kt number:=0; b_nsu_kt number:=0;
    a_bp_ps pht_type.a_var; a_bp_tl pht_type.a_num; a_sp_ps pht_type.a_var; a_sp_tl pht_type.a_num;
    a_nsu_bp pht_type.a_var; a_nsu_tl pht_type.a_num; a_hdong_bp pht_type.a_var; a_hdong_tl pht_type.a_num; a_hdong_tien pht_type.a_num;
begin
-- Dan - Tong hop phan bo san pham
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_ht is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
select nvl(max(ngay),0) into b_ng_pb from kt_pb where ma_dvi=b_ma_dvi and ngay<=b_ngay_ht;
b_ngay:=PKH_SO_CDT(b_ngay_ht); b_ngayd:=PKH_NG_CSO(trunc(b_ngay,'MONTH'));
for r_lp in (select htoan,l_ct,lk from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngay_ht) loop
    if r_lp.htoan='H' and nvl(r_lp.l_ct,' ')<>'KC' and instr(r_lp.lk,'BP')>0
        and (instr(r_lp.lk,'TK:1')>0 or instr(r_lp.lk,'TK:0')>0) then
        b_loi:='loi:Hoan chinh ma thong ke truoc khi phan bo:loi'; raise PROGRAM_ERROR;
    end if;
end loop;
FKH_NSU_TL(b_ma_dvi,b_ngayd,a_nsu_bp,a_nsu_tl);
b_nsu_kt:=a_nsu_bp.count;
b_tien:=0; PKH_MANG_KD(a_bp_ps);
for r_lp in (select phong,sum(no_ps-co_ps) tien from kt_sc_bp where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngay_ht group by phong) loop
    if r_lp.tien>0 then
        b_bp_kt:=b_bp_kt+1; b_tien:=b_tien+r_lp.tien;
        a_bp_ps(b_bp_kt):=r_lp.phong; a_bp_tl(b_bp_kt):=r_lp.tien;
    end if;
end loop;
if b_bp_kt>0 then
    for b_lp in 1..b_bp_kt loop
        a_bp_tl(b_lp):=a_bp_tl(b_lp)/b_tien;
    end loop;
end if;
b_tien:=0; PKH_MANG_KD(a_sp_ps);
for r_lp in (select ma_sp,sum(no_ps-co_ps) tien from kt_sc_bp where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngay_ht group by ma_sp) loop
    if r_lp.tien>0 then
        b_bp_kt:=b_bp_kt+1; b_tien:=b_tien+r_lp.tien;
        a_bp_ps(b_bp_kt):=r_lp.ma_sp; a_sp_tl(b_bp_kt):=r_lp.tien;
    end if;
end loop;
if b_sp_kt>0 then
    for b_lp in 1..b_sp_kt loop
        a_sp_tl(b_lp):=a_sp_tl(b_lp)/b_tien;
    end loop;
end if;
PKH_MANG_KD_N(a_bt); PKH_MANG_KD(a_nhom); PKH_MANG_KD(a_ma_ttr); PKH_MANG_KD(a_ma_lvuc); PKH_MANG_KD(a_dvi);
PKH_MANG_KD(a_phong); PKH_MANG_KD(a_sp); PKH_MANG_KD_N(a_tien);
for r_lp in (select so_id,htoan,l_ct,lk from kt_1 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngay_ht) loop
    select count(*) into b_i1 from kt_bp_goc where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
    if b_i1<>0 then b_l_ct:='KC'; else b_l_ct:=nvl(r_lp.l_ct,' '); end if;
    if r_lp.htoan='H' and b_l_ct<>'KC' and instr(r_lp.lk,'BP')>0 then
        b_kt:=0;
        PKH_MANG_XOA_N(a_bt); PKH_MANG_XOA(a_nhom); PKH_MANG_XOA(a_ma_ttr); PKH_MANG_XOA(a_ma_lvuc);
        PKH_MANG_XOA(a_dvi); PKH_MANG_XOA(a_ma_cb); PKH_MANG_XOA(a_viec); PKH_MANG_XOA(a_hdong);
        PKH_MANG_XOA(a_phong); PKH_MANG_XOA(a_sp); PKH_MANG_XOA_N(a_tien);
        for r_lp1 in (select * from kt_2 where ma_dvi=b_ma_dvi and so_id=r_lp.so_id) loop
            if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,'T',r_lp1.ma_tk) and ((r_lp1.nv='N' and b_l_ct<>'KC/N') or (r_lp1.nv='C' and b_l_ct<>'KC/C')) then
                b_tien:=r_lp1.tien;
                for r_lp2 in (select * from kt_bp where ma_dvi=b_ma_dvi and so_id=r_lp.so_id and bt=r_lp1.bt) loop
                    b_i1:=r_lp2.tien; b_bp_xl:=b_i1; b_tien:=b_tien-b_i1;
                    FKH_VIEC_BP_TL(b_ma_dvi,r_lp2.viec,r_lp2.hdong,a_hdong_bp,a_hdong_tl);
                    if trim(r_lp2.phong) is not null and (b_sp_kt=0 or trim(r_lp2.ma_sp) is not null) then
                        b_kt:=b_kt+1;
                        a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                        a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                        a_phong(b_kt):=r_lp2.phong; a_sp(b_kt):=r_lp2.ma_sp; a_tien(b_kt):=r_lp2.tien;
                        b_bp_xl:=0;
                    elsif trim(r_lp2.phong) is not null then
                        PKT_TINH_PBO_PH(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke,r_lp2.tien,r_lp2.phong,a_xl_sp,a_xl_tien);
                        if a_xl_sp.count<>0 then
                            for b_lp in 1..a_xl_sp.count loop
                                b_kt:=b_kt+1;
                                a_phong(b_kt):=r_lp2.phong; a_sp(b_kt):=a_xl_sp(b_lp); a_tien(b_kt):=a_xl_tien(b_lp);
                                a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                            end loop;
                            b_bp_xl:=0;
                        elsif b_sp_kt<>0 then
                            for b_lp in 1..b_sp_kt loop
                                b_kt:=b_kt+1;
                                a_phong(b_kt):=r_lp2.phong; a_sp(b_kt):=a_sp_ps(b_lp);
                                if b_lp=b_sp_kt then
                                    a_tien(b_kt):=b_i1;
                                else
                                    a_tien(b_kt):=round(r_lp2.tien*a_sp_tl(b_lp),0);
                                    b_i1:=b_i1-a_tien(b_kt);
                                end if;
                                a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                            end loop;
                            b_bp_xl:=0;
                        end if;
                    elsif trim(r_lp2.ma_sp) is not null then
                        if a_hdong_bp.count<>0 then
                            PKT_TINH_PBO_HDONG(b_ma_dvi,b_tien,a_hdong_bp,a_hdong_tl,a_xl_tien);
                            for b_lp in 1..a_hdong_bp.count loop
                                b_kt:=b_kt+1;
                                a_phong(b_kt):=a_hdong_bp(b_lp); a_sp(b_kt):=r_lp2.ma_sp; a_tien(b_kt):=a_xl_tien(b_lp);
                                a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                            end loop;
                            b_bp_xl:=0;
                        elsif b_nsu_kt<>0 and FKT_PB_KIEU(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke)='N' then
                            for b_lp in 1..b_nsu_kt loop
                                b_kt:=b_kt+1;
                                a_phong(b_kt):=a_nsu_bp(b_lp); a_sp(b_kt):=r_lp2.ma_sp;
                                if b_lp=b_nsu_kt then
                                    a_tien(b_kt):=b_i1;
                                else
                                    a_tien(b_kt):=round(r_lp2.tien*a_nsu_tl(b_lp),0);
                                    b_i1:=b_i1-a_tien(b_kt);
                                end if;
                                a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                            end loop;
                            b_bp_xl:=0;
                        else
                            PKT_TINH_PBO_SP(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke,r_lp2.tien,r_lp2.ma_sp,a_xl_phong,a_xl_tien);
                            if a_xl_phong.count<>0 then
                                for b_lp in 1..a_xl_phong.count loop
                                    b_kt:=b_kt+1;
                                    a_phong(b_kt):=a_xl_phong(b_lp); a_sp(b_kt):=r_lp2.ma_sp; a_tien(b_kt):=a_xl_tien(b_lp);
                                    a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                    a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                                end loop;
                                b_bp_xl:=0;
                            elsif b_bp_kt<>0 then
                                for b_lp in 1..b_bp_kt loop
                                    b_kt:=b_kt+1;
                                    a_phong(b_kt):=a_bp_ps(b_lp); a_sp(b_kt):=r_lp2.ma_sp;
                                    if b_lp=b_bp_kt then
                                        a_tien(b_kt):=b_i1;
                                    else
                                        a_tien(b_kt):=round(r_lp2.tien*a_bp_tl(b_lp),0);
                                        b_i1:=b_i1-a_tien(b_kt);
                                    end if;
                                    a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                    a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                                end loop;
                                b_bp_xl:=0;
                            end if;
                        end if;
                    elsif a_hdong_bp.count<>0 then
                        PKT_TINH_PBO_HDONG(b_ma_dvi,b_tien,a_hdong_bp,a_hdong_tl,a_hdong_tien);
                        for b_lp1 in 1..a_hdong_bp.count loop
                            PKT_TINH_PBO_PH(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke,a_hdong_tien(b_lp1),a_hdong_bp(b_lp1),a_xl_sp,a_xl_tien);
                            if a_xl_sp.count<>0 then
                                for b_lp in 1..a_xl_sp.count loop
                                    b_kt:=b_kt+1;
                                    a_phong(b_kt):=a_hdong_bp(b_lp1); a_sp(b_kt):=a_xl_sp(b_lp); a_tien(b_kt):=a_xl_tien(b_lp);
                                    a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                    a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                                end loop;
                                b_bp_xl:=b_bp_xl-a_hdong_tien(b_lp1);
                            elsif b_sp_kt<>0 then
                                b_i2:=a_hdong_tien(b_lp1);
                                for b_lp in 1..b_sp_kt loop
                                    b_kt:=b_kt+1;
                                    a_phong(b_kt):=a_hdong_bp(b_lp1); a_sp(b_kt):=a_sp_ps(b_lp);
                                    if b_lp=b_sp_kt then
                                        a_tien(b_kt):=b_i2;
                                    else
                                        a_tien(b_kt):=round(a_hdong_tien(b_lp1)*a_sp_tl(b_lp),0);
                                        b_i2:=b_i2-a_tien(b_kt);
                                    end if;
                                    a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                    a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                                end loop;
                                b_bp_xl:=b_bp_xl-a_hdong_tien(b_lp1);
                            end if;
                        end loop;
                    elsif b_nsu_kt<>0 and FKT_PB_KIEU(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke)='N' then
                        for b_lp1 in 1..b_nsu_kt loop
                            if b_lp1=b_nsu_kt then
                                b_i2:=b_i1;
                            else
                                b_i2:=round(r_lp2.tien*a_nsu_tl(b_lp1),0);
                                b_i1:=b_i1-b_i2;
                            end if;
                            PKT_TINH_PBO_PH(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke,b_i2,a_nsu_bp(b_lp1),a_xl_sp,a_xl_tien);
                            if a_xl_sp.count<>0 then
                                for b_lp in 1..a_xl_sp.count loop
                                    b_kt:=b_kt+1;
                                    a_phong(b_kt):=a_nsu_bp(b_lp1); a_sp(b_kt):=a_xl_sp(b_lp); a_tien(b_kt):=a_xl_tien(b_lp);
                                    a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                    a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                                end loop;
                                b_bp_xl:=b_bp_xl-b_i2;
                            elsif b_sp_kt<>0 then
                                b_i3:=b_i2;
                                for b_lp in 1..b_sp_kt loop
                                    b_kt:=b_kt+1;
                                    a_phong(b_kt):=a_nsu_bp(b_lp1); a_sp(b_kt):=a_sp_ps(b_lp);
                                    if b_lp=b_sp_kt then
                                        a_tien(b_kt):=b_i2;
                                    else
                                        a_tien(b_kt):=round(b_i2*a_sp_tl(b_lp),0);
                                        b_i3:=b_i3-a_tien(b_kt);
                                    end if;
                                    a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                                    a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                                end loop;
                                b_bp_xl:=b_bp_xl-b_i2;
                            end if;
                        end loop;
                    elsif b_bp_xl<>0 then
                        PKT_TINH_PBO(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke,b_bp_xl,a_xl_phong,a_xl_sp,a_xl_tien);
                        for b_lp in 1..a_xl_phong.count loop
                            b_kt:=b_kt+1;
                            a_phong(b_kt):=a_xl_phong(b_lp); a_sp(b_kt):=a_xl_sp(b_lp); a_tien(b_kt):=a_xl_tien(b_lp);
                            a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=r_lp2.nhom; a_ma_ttr(b_kt):=r_lp2.ma_ttr; a_ma_lvuc(b_kt):=r_lp2.ma_lvuc;
                            a_dvi(b_kt):=r_lp2.dvi; a_ma_cb(b_kt):=r_lp2.ma_cb; a_viec(b_kt):=r_lp2.viec; a_hdong(b_kt):=r_lp2.hdong;
                        end loop;
                    end if;
                end loop;
                if b_tien<>0 then
                    PKT_TINH_PBO(b_ma_dvi,b_ng_pb,r_lp1.ma_tk,r_lp1.ma_tke,b_tien,a_xl_phong,a_xl_sp,a_xl_tien);
                    for b_lp in 1..a_xl_phong.count loop
                        b_kt:=b_kt+1;
                        a_phong(b_kt):=a_xl_phong(b_lp); a_sp(b_kt):=a_xl_sp(b_lp); a_tien(b_kt):=a_xl_tien(b_lp);
                        a_bt(b_kt):=r_lp1.bt; a_nhom(b_kt):=' '; a_ma_ttr(b_kt):=' '; a_ma_lvuc(b_kt):=' ';
                        a_dvi(b_kt):=' '; a_ma_cb(b_kt):=' '; a_viec(b_kt):=' '; a_hdong(b_kt):=' ';
                    end loop;
                end if;
            end if;
        end loop;
        if b_kt<>0 then
            insert into kt_bp_goc select * from kt_bp where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
            for b_lp in 1..b_kt loop
                if trim(a_nhom(b_lp)) is null then
                    a_nhom(b_lp):=FKT_BP_NHOM(b_ma_dvi,a_phong(b_lp),a_sp(b_lp));
                end if;
            end loop;
            PKT_CT_BP_NH(b_ma_dvi,b_nsd,b_pas,r_lp.so_id,a_bt,a_nhom,a_ma_ttr,a_ma_lvuc,a_dvi,a_phong,a_ma_cb,a_viec,a_hdong,a_sp,a_tien,'K');
            if b_loi is not null then raise PROGRAM_ERROR; end if;
        end if;
    end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure FKH_NSU_TL
    (b_ma_dvi varchar2,b_ngay number,a_phong out pht_type.a_var,a_nsu out pht_type.a_num,b_nhom varchar2:='T')
AS
    b_i1 number:=0;
begin
-- Dan - Tra ty le nhan su
FKH_NSU_PHONG(b_ma_dvi,b_ngay,a_phong,a_nsu,b_nhom);
for b_lp in 1..a_phong.count loop
    b_i1:=b_i1+a_nsu(b_lp);
end loop;
if b_i1<>0 then
    for b_lp in 1..a_phong.count loop
        a_nsu(b_lp):=a_nsu(b_lp)/b_i1;
    end loop;
end if;
end;
/
create or replace procedure FKH_NSU_PHONG
    (b_ma_dvi varchar2,b_ngay number,a_phong out pht_type.a_var,a_nsu out pht_type.a_num,b_nhom varchar2:='T')
AS
    b_kt number:=0; b_nh varchar2(1);
begin
-- Dan - Tra so nhan su
PKH_MANG_KD(a_phong);
for r_lp in (select phong,max(ngay) ngay from kh_nsu where ma_dvi=b_ma_dvi and ngay<=b_ngay group by phong) loop
    b_nh:=FHT_MA_PHONG_NHOM(b_ma_dvi,r_lp.phong);
    if instr(b_nhom,b_nh)>0 then
        b_kt:=b_kt+1;
        a_phong(b_kt):=r_lp.phong;
        select nsu into a_nsu(b_kt) from kh_nsu where ma_dvi=b_ma_dvi and ngay=r_lp.ngay and phong=r_lp.phong;
    end if;
end loop;
end;
/
create or replace function FHT_MA_PHONG_NHOM (b_ma_dvi varchar2,b_ma varchar2) return varchar2
AS
    b_kq varchar2(1):='G';
begin
-- Dan - Tra nhom
if trim(b_ma) is not null then
    select nvl(min(nhom),'G') into b_kq from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
return b_kq;
end;
/
create or replace procedure FKH_VIEC_BP_TL
    (b_ma_dvi varchar2,b_hdong varchar2,b_viec varchar2,a_phong out pht_type.a_var,a_pt out pht_type.a_num)
AS
    b_kt number:=0; b_i1 number:=0;
begin
-- Dan - Tra ty le bo phan
PKH_MANG_KD(a_phong);
if trim(b_hdong) is not null then
    for r_lp in (select phong,sum(pt) pt from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and ma=b_hdong group by phong having sum(pt)<>0) loop
        b_kt:=b_kt+1;
        a_phong(b_kt):=r_lp.phong; a_pt(b_kt):=r_lp.pt;
        b_i1:=b_i1+a_pt(b_kt);
    end loop;
end if;
if b_kt=0 and trim(b_viec) is not null then
    for r_lp in (select phong,sum(pt) pt from kh_ma_viec_bp where ma_dvi=b_ma_dvi and ma=b_viec group by phong having sum(pt)<>0) loop
        b_kt:=b_kt+1;
        a_phong(b_kt):=r_lp.phong; a_pt(b_kt):=r_lp.pt;
        b_i1:=b_i1+a_pt(b_kt);
    end loop;
end if;
if b_kt<>0 then
    for b_lp in 1..b_kt loop
        a_pt(b_lp):=a_pt(b_lp)/b_i1;
    end loop;
end if;
end;
/
create or replace procedure PKT_TINH_PBO_PH
    (b_ma_dvi varchar2,b_ngay number,b_ma_tk varchar2,b_ma_tke varchar2,b_tien number,
    b_phong varchar2,a_sp out pht_type.a_var,a_tien out pht_type.a_num)
AS
    b_i1 number; b_i2 number; b_i3 number; b_pt number; b_kt number:=0;
begin 
PKH_MANG_KD(a_sp);
for r_lp in (select distinct ma_tk,ma_tke from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay order by ma_tk desc,ma_tke desc) loop
    if instr(b_ma_tk,r_lp.ma_tk)=1 and (trim(r_lp.ma_tke) is null or instr(b_ma_tke,r_lp.ma_tke)=1)  then
        select nvl(sum(pt),0) into b_pt from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and bt>10000 and phong in(' ',b_phong);
        if b_pt<>0 then
            b_i1:=b_pt; b_i2:=b_tien;
            for r_lp1 in (select sp,pt from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and bt>10000 and phong in(' ',b_phong)) loop
                if b_i1=r_lp1.pt then b_i3:=b_i2;
                else
                    b_i3:=round(b_tien*r_lp1.pt/b_pt,0);
                    if abs(b_i3)>abs(b_i1) then b_i3:=b_i1; end if;
                end if;
                b_i1:=b_i1-r_lp1.pt;
                if b_i3<> 0 then
                    b_kt:=b_kt+1; b_i2:=b_i2-b_i3;
                    a_sp(b_kt):=r_lp1.sp; a_tien(b_kt):=b_i3;
                end if;
            end loop;
        end if;
        exit;
    end if;
end loop;
end;
/
create or replace procedure PKT_TINH_PBO_HDONG
    (b_ma_dvi varchar2,b_tien number,a_phong pht_type.a_var,a_tl pht_type.a_num,a_tien out pht_type.a_num)
AS
    b_i1 number:=b_tien;
begin 
for b_lp in 1..a_phong.count loop
    if b_lp=a_phong.count then
        a_tien(b_lp):=b_i1;
    else
        a_tien(b_lp):=round(b_tien*a_tl(b_lp),0);
        if abs(a_tien(b_lp))>abs(b_i1) then a_tien(b_lp):=b_i1; end if;
        b_i1:=b_i1-a_tien(b_lp);
    end if;
end loop;
end;
/
create or replace procedure PKT_TINH_PBO_SP
    (b_ma_dvi varchar2,b_ngay number,b_ma_tk varchar2,b_ma_tke varchar2,b_tien number,
    b_sp varchar2,a_phong out pht_type.a_var,a_tien out pht_type.a_num)
AS
    b_i1 number; b_i2 number; b_i3 number; b_pt number; b_kt number:=0;
begin 
PKH_MANG_KD(a_phong);
for r_lp in (select distinct ma_tk,ma_tke from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay order by ma_tk desc,ma_tke desc) loop
    if instr(b_ma_tk,r_lp.ma_tk)=1 and (trim(r_lp.ma_tke) is null or instr(b_ma_tke,r_lp.ma_tke)=1)  then
        select nvl(sum(pt),0) into b_pt from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and bt>10000 and sp in(' ',b_sp);
        if b_pt<>0 then
            b_i1:=b_pt; b_i2:=b_tien;
            for r_lp1 in (select phong,pt from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and bt>10000 and sp in(' ',b_sp)) loop
                if b_i1=r_lp1.pt then b_i3:=b_i2;
                else
                    b_i3:=round(b_tien*r_lp1.pt/b_pt,0);
                    if abs(b_i3)>abs(b_i2) then b_i3:=b_i2; end if;
                end if;
                b_i1:=b_i1-r_lp1.pt;
                if b_i3<>0 then
                    b_kt:=b_kt+1; b_i2:=b_i2-b_i3;
                    a_phong(b_kt):=r_lp1.phong; a_tien(b_kt):=b_i3;
                end if;
            end loop;
        end if;
        exit;
    end if;
end loop;
end;
/
create or replace procedure PKT_TINH_PBO
    (b_ma_dvi varchar2,b_ngay number,b_ma_tk varchar2,b_ma_tke varchar2,b_tien number,
    a_phong out pht_type.a_var,a_sp out pht_type.a_var,a_tien out pht_type.a_num)
AS
    b_i1 number; b_i2 number; b_i3 number; b_kt number:=0; b_pt number;
begin 
PKH_MANG_KD(a_phong);
for r_lp in (select distinct ma_tk,ma_tke from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay order by ma_tk desc,ma_tke desc) loop
    if instr(b_ma_tk,r_lp.ma_tk)=1 and (trim(r_lp.ma_tke) is null or instr(b_ma_tke,r_lp.ma_tke)=1)  then
        select nvl(sum(pt),0) into b_pt from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and bt>10000;
        if b_pt<>0 then
            b_i1:=b_pt; b_i2:=b_tien;
            for r_lp1 in (select phong,sp,pt from kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=r_lp.ma_tk and ma_tke=r_lp.ma_tke and bt>10000) loop
                if b_i1=r_lp1.pt then b_i3:=b_i2;
                else
                    b_i3:=round(b_tien*r_lp1.pt/b_pt,0);
                    if abs(b_i3)>abs(b_i1) then b_i3:=b_i1; end if;
                end if;
                b_i1:=b_i1-r_lp1.pt;
                if b_i3<> 0 then
                    b_kt:=b_kt+1; b_i2:=b_i2-b_i3;
                    a_phong(b_kt):=r_lp1.phong; a_sp(b_kt):=r_lp1.sp; a_tien(b_kt):=b_i3;
                end if;
            end loop;
        end if;
        exit;
    end if;
end loop;
end;
/
create or replace procedure PPB_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_l_ct varchar2,
    b_klk varchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu tien te theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','PB','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_l_ct='C' then
    if b_klk='T' then
        select count(*) into b_dong from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('N','C');
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,so_ct,tien,row_number() over (order by so_ct) sott 
            from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('N','C') order by so_ct) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('N','C') and (nsd is null or nsd=b_nsd);
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,so_ct,tien,
            row_number() over (order by so_ct) sott from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('N','C') and (nsd is null or nsd=b_nsd) order by so_ct)
            where sott between b_tu and b_den;
    end if;
else
    if b_klk='T' then
        select count(*) into b_dong from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('T','X');
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,so_ct,tien,row_number() over (order by so_ct) sott 
            from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('T','X') order by so_ct) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('T','X') and (nsd is null or nsd=b_nsd);
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,so_ct,tien,
            row_number() over (order by so_ct) sott from pb_0 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and l_ct in('T','X') and (nsd is null or nsd=b_nsd) order by so_ct)
            where sott between b_tu and b_den;
    end if;
end if;
end;
/
create or replace procedure PPB_MA_NHOM_XEM
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
--- Dan - Xem nhom ma phan bo
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from pb_ma_nhom where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PKH_MA_TTU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,ma_ct,nsd 
    from (select * from kh_ma_ttu where ma_dvi=b_ma_dvi order by ma)
    start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
end;
/
create or replace procedure PKH_MA_LOAI_DN_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem he thong ma loai doanh nghiep
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select rpad(lpad('-',2*(level-1),'-')||ma,20) xep,ma,ten,ma_ct,nsd 
    from (select * from kh_ma_loai_dn where ma_dvi=b_ma_dvi order by ma)
    start with ma_ct=' ' CONNECT BY prior ma=ma_ct;
end;
/
create or replace package PKG_KH is
procedure PKH_MA_HAN_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_md varchar2,b_ma_cd varchar2,b_nv varchar2,b_ma_nsd_n varchar2,b_ngay date,b_lydo nvarchar2:=' ');
procedure PKH_MA_HAN_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_ma_cd varchar2,b_nv varchar2,b_ma_nsd varchar2);    
end PKG_KH;
/
create or replace procedure PKH_GOP_XLY_TIM_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_tthai varchar2,b_ngayd number,b_ngayc number,
	b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
/*
declare
    b_dong number;cs_lke pht_type.cs_type;
begin
PKH_GOP_XLY_TIM_CT('110','1','','C',20250101,20250131,1,20,b_dong,cs_lke);
end;	
*/	
AS
	b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select count(*) into b_dong from kh_gop where PKH_NG_CSO(ngay_nh) between b_ngayd and b_ngayc 
    and ((b_tthai='C' and trim(xly) is null) or (b_tthai<>'C' and trim(xly) is not null));
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select a.*,PKH_NG_CDT(a.ngay_nh) ngay_nhc,rowidtochar(rowid) row_id,row_number() over (order by ngay_nh) sott from kh_gop a
    where PKH_NG_CSO(ngay_nh) between b_ngayd and b_ngayc 
    and ((b_tthai='C' and trim(xly) is null) or (b_tthai<>'C' and trim(xly) is not null)) 
    order by ngay_nh) where sott between b_tu and b_den;
end;
/
create or replace function PKH_NG_CDT(b_ngay date) return varchar
AS
begin
-- Dan - Chuyen ngay sang so dang dd/MM/yyyy
return (to_char(b_ngay,'dd/MM/yyyy'));
end;
/
create or replace procedure PKH_HOI_KT_LIST(b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,
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
create or replace procedure PKT_CT_PBCH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_ma_tke varchar2,b_ma_mc varchar2)
AS
    b_loi varchar2(100); b_i1 number;  b_i2 number; b_i3 number; b_so_id number; b_idvung number;
    b_noite varchar2(5); b_so_ct varchar2(20):=' '; b_so_tt number; b_lk varchar2(100); b_ngay_d number;
    b_ngay_c number; b_cch number; b_ctt number; b_tl number; b_bt number; b_nd nvarchar2(100);
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num;
    a_note pht_type.a_nvar; a_bt pht_type.a_num; a_ma_sp pht_type.a_var;
    a_ma_ctr PHT_TYPE.a_var; a_hang PHT_TYPE.a_var; a_ma_mc PHT_TYPE.a_var; a_ma_vi PHT_TYPE.a_var;
    a_ma_nt PHT_TYPE.a_var; a_tg_tt PHT_TYPE.a_num; a_tien_qd PHT_TYPE.a_num;
    b_ma_tk varchar2(20); b_ma_sp varchar2(10); b_c1 varchar2(1);
begin
-- Dan - Ket chuyen chi phi chung(627) sang chi phi truc tiep(154)
delete temp_1; delete temp_2; delete temp_3; commit;
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngay_d:=round(b_ngay_ht,-2)+01; b_ngay_c:=b_ngay_d+98;
-- Loc 627
insert into temp_1(c1,c2,n1) select a.ma_tk,a.ma_tke,a.no_ck-a.co_ck from kt_sc a,
    (select ma_tk,ma_tke,max(ngay_ht) ngay_ht from kt_sc where ma_dvi=b_ma_dvi and
    ngay_ht<=b_ngay_c and ma_tk like '627%' group by ma_tk,ma_tke) b where
    a.ma_dvi=b_ma_dvi and a.ma_tk=b.ma_tk and a.ma_tke=b.ma_tke and a.ngay_ht=b.ngay_ht;
delete temp_1 where n1=0;
select nvl(sum(n1),0) into b_cch from temp_1;
if b_cch=0 then b_loi:='loi:Het so phan bo tai khoan 627:loi'; raise PROGRAM_ERROR; end if;
-- Loc 154
insert into temp_2(n10,n11,n12,c1,n1,c2) select a.ngay_ht,b.so_id,b.bt,b.ma_tk,b.tien,a.lk
    from kt_1 a,kt_2 b where a.ma_dvi=b_ma_dvi and a.ngay_ht between b_ngay_d and b_ngay_c
    and a.htoan='H' and nvl(a.l_ct,' ')<>'KC' and b.ma_dvi=b_ma_dvi and
    b.so_id=a.so_id and b.nv='N' and b.ma_tk like '154%' and b.tien>0;
delete temp_2 where n11 in(select distinct so_id from kt_3 where
    ma_dvi=b_ma_dvi and ngay_ht between b_ngay_d and b_ngay_c and
    (ma_tk_no like '154%' and ma_tk_co like '627%'));
delete temp_2 where n11 in(select distinct so_id from xl_1 where
    ma_dvi=b_ma_dvi and ngay_ht between b_ngay_d and b_ngay_c and l_ct<>'C');
select nvl(sum(n1),0) into b_ctt from temp_2;
if b_ctt=0 then b_loi:='loi:Khong phat sinh chi 154:loi'; raise PROGRAM_ERROR; end if;
for r_lp in(select n10 ngay_ht,n11 so_id,n12 bt,c1 ma_tk,c2 lk from temp_2) loop
    b_so_id:=r_lp.so_id; b_i1:=r_lp.bt; b_i2:=r_lp.ngay_ht; b_ma_tk:=r_lp.ma_tk; b_lk:=r_lp.lk;
    if instr(b_lk,'SP:0')>0 or instr(b_lk,'SP:1')>0 then
        b_loi:='loi:Chua hoan thanh phan bo san pham ngay#'||PKH_SO_CNG(b_i2)||':loi'; raise PROGRAM_ERROR;
    end if;
    if instr(b_lk,'BP:0')>0 or instr(b_lk,'BP:1')>0 then
        b_loi:='loi:Chua hoan thanh phan bo bo phan ngay#'||PKH_SO_CNG(b_i2)||':loi'; raise PROGRAM_ERROR;
    end if;
    select nvl(min(ma_sp),'*') into b_ma_sp from kt_sp where
        ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_i1 and rownum=1;
    if b_ma_sp<>'*' then
        b_loi:='loi:Da xoa ma san pham#'||trim(b_ma_sp)||'#tai khoan#'||trim(b_ma_tk);
        b_loi:=trim(b_loi)||'#ngay#'||PKH_SO_CNG(b_i2)||':loi';
        select 0 into b_i3 from kh_pbo_sp where ma_dvi=b_ma_dvi and ngay in
            (select max(ngay) from kh_pbo_sp where ma_dvi=b_ma_dvi and ngay<=b_i2 and
            ma_tk=b_ma_tk and ma_sp=b_ma_sp) and ma_tk=b_ma_tk and ma_sp=b_ma_sp;
    end if;
end loop;
insert into temp_3(c1,c2,n1) (select c1,c3,n1 from (select c1,c3,sum(n1) n1 from temp_2 group by c1,c3));
-- Phan bo
b_tl:=b_cch/b_ctt;
update temp_3 set n2=round(n1*b_tl,0);
select nvl(sum(n2),0) into b_i1 from temp_3;
if b_i1<>b_cch then
    b_i1:=b_cch-b_i1;
    update temp_3 set n2=n2+b_i1 where rownum=1;
end if;
b_i1:=0;
for r_lp in(select c1 ma_tk,c2 ma_sp,n2 tien from temp_3 where n2<>0 order by c1,c2) loop
    b_i1:=b_i1+1; a_ma_sp(b_i1):=r_lp.ma_sp; a_nv(b_i1):='N';
    a_ma_tk(b_i1):=r_lp.ma_tk; a_ma_tke(b_i1):=b_ma_tke;
    a_tien(b_i1):=r_lp.tien; a_note(b_i1):=''; a_bt(b_i1):=b_i1;
end loop;
b_bt:=b_i1+1;
for r_lp in(select c1 ma_tk,c2 ma_tke, n1 tien from temp_1 where n1<>0 order by c1,c2) loop
    b_i1:=b_i1+1; a_nv(b_i1):='C'; a_ma_tk(b_i1):=r_lp.ma_tk; a_ma_tke(b_i1):=r_lp.ma_tke;
    a_tien(b_i1):=r_lp.tien; a_note(b_i1):=''; a_bt(b_i1):=b_i1;
end loop;
b_lk:=''; b_nd:='Phan bo chi phi chung 627'; b_so_tt:=0;
PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_KT_NH(b_ma_dvi,b_nsd,'H',b_ngay_ht,' ',b_so_tt,b_so_ct,PKH_SO_CNG(b_ngay_ht),b_nd,' ',
    a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'KT',b_lk,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if instr(b_lk,'SP')>0 then
    for b_lp in 1..a_ma_sp.count loop
        b_ma_tk:=a_ma_tk(b_lp);
        if a_ma_sp(b_lp)<>'*' then
            insert into kt_sp values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,a_ma_sp(b_lp),a_tien(b_lp));
        else
            insert into kt_sp (select b_ma_dvi,b_so_id,b_lp,b_ngay_ht,ma_sp,a_tien(b_lp)
                from kh_pbo_sp where ma_dvi=b_ma_dvi and ngay in(select max(ngay) from kh_pbo_sp where
                ma_dvi=b_ma_dvi and ngay<=b_ngay_ht and ma_tk=b_ma_tk) and ma_tk=b_ma_tk);
        end if;
    end loop;
    --b_c1:=FKT_LKET_SP(b_ma_dvi,b_so_id,'',b_ngay_ht);
    --PKT_LKET_NV(b_ma_dvi,'SP',b_so_id,b_c1,b_lk,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
if instr(b_lk,'XL')>0 then
    b_noite:=FTT_TRA_NOITE(b_ma_dvi);
    PKH_MA_LCT_TIEN_NV(b_ma_dvi,'XL','C',b_ngay_ht,a_nv,a_ma_tk,a_tien,b_cch);

    if b_cch=0 then b_loi:='loi:Sai loai chung tu xay lap:loi'; raise PROGRAM_ERROR; end if;
    delete ket_qua;
    insert into ket_qua(c1,n3,c2,n1) select b.ma_ctr,b.hang,b.ma_mc,sum(b.tien_qd) from xl_1 a,xl_2 b where
        a.ma_dvi=b_ma_dvi and a.ngay_ht between b_ngay_d and b_ngay_c and
        a.l_ct='C' and a.tien_qd>0 and a.htoan='H' and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id group by b.ma_ctr,b.hang,b.ma_mc;
    select nvl(sum(n1),0) into b_ctt from ket_qua;
    if b_ctt=0 then b_loi:='loi:Khong co phat sinh chi xay lap trong ky:loi'; raise PROGRAM_ERROR; end if;
    b_tl:=b_cch/b_ctt;
    update ket_qua set n2=round(n1*b_tl,0);
    select nvl(sum(n2),0) into b_i1 from ket_qua;
    if b_i1<>b_cch then
        b_i1:=b_cch-b_i1;
        update ket_qua set n2=n2+b_i1 where rownum=1;
    end if;
    b_i1:=0; b_so_ct:=FXL_SOTT(b_ma_dvi,b_ngay_ht,'C');
    for r_lp in (select c1 ma_ctr,n3 hang,c2 ma_mc,n2 tien from ket_qua order by c1,n3,c2) loop
        b_i1:=b_i1+1; a_ma_ctr(b_i1):=r_lp.ma_ctr; a_hang(b_i1):=r_lp.hang; a_ma_vi(b_i1):=' ';
        a_ma_mc(b_i1):=r_lp.ma_mc; a_ma_nt(b_i1):=b_noite; a_tg_tt(b_i1):=1; a_tien_qd(b_i1):=r_lp.tien;
    end loop;
    PXL_XL_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PXL_XL_NH(b_idvung,b_ma_dvi,b_nsd,'KT',b_so_id,'H',b_ngay_ht,'C',b_so_ct,' ','VND',1,
        'K',' ','C','K',0,0,' ',' ',' ',b_nd,' ',0,0,a_ma_ctr,a_hang,a_ma_mc,a_ma_vi,a_tien_qd,a_tien_qd,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PKT_LKET_NV(b_ma_dvi,'XL',b_so_id,'2',b_lk,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_LCT_TIEN_NV
    (b_ma_dvi varchar2,b_md varchar2,b_ma varchar2,b_ngay number,a_nv pht_type.a_var,
    a_ma_tk pht_type.a_var,a_tien pht_type.a_num,b_tien out number)
AS
    a_nv_l pht_type.a_var; a_ma_tk_l pht_type.a_var; a_tien_l pht_type.a_num;
begin
-- Dan - Xac dinh tong tien lien quan mot nghiep vu
PKH_MA_LCT_TK(b_ma_dvi,b_md,b_ngay,a_nv,a_ma_tk,a_nv_l,a_ma_tk_l);
PKH_MA_LCT_TIEN(a_nv,a_ma_tk,a_tien,a_nv_l,a_ma_tk_l,a_tien_l);
b_tien:=0;
for b_lp in 1..a_nv_l.count loop
    b_tien:=b_tien+a_tien_l(b_lp);
end loop;
end;
/
create or replace function FXL_SOTT(b_ma_dvi varchar2,b_ngay_ht number,b_loai varchar2) return varchar2
AS
    b_d1 number; b_d2 number; b_i1 number; b_c2 varchar2(2);
begin
-- Dan - Cho so thu tu tiep theo cua CT xay lap
b_d1:=round(b_ngay_ht,-2);b_d2:=b_d1+100; b_c2:=substr(b_loai,1,1)||'%';
select nvl(max(PKH_LOC_CHU_SO(so_ct)),0) into b_i1 from xl_1 where ma_dvi=b_ma_dvi and (ngay_ht between b_d1 and b_d2) and loai like b_c2;
if b_i1<10000 then b_i1:=1; else b_i1:=round(b_i1/10000,0)+1; end if;
return trim(to_char(b_i1))||'/'||substr(to_char(b_ngay_ht),5,2)||':'||substr(to_char(b_ngay_ht),3,2);
end;
/
create or replace procedure PXL_XL_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_nsd_c varchar2(10); b_ngay_ht number; b_htoan varchar2(1);
begin
-- Dan - Xoa chung tu du an, cong trinh
select count(*) into b_i1 from xl_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select nsd,ngay_ht,htoan into b_nsd_c,b_ngay_ht,b_htoan from xl_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 then return; end if;
if b_htoan='H' then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua xoa chung tu nguoi khac:loi'; return; end if;
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','XL');
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'XL',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table XL:loi';
delete xl_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete xl_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PXL_XL_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_so_id number,b_htoan varchar2,b_ngay_ht number,
    b_l_ct varchar2,b_so_ct varchar2,b_ngay_ct varchar2,b_ma_nt varchar2,b_tg_tt number,
    b_k_ma_kh varchar2,b_ma_kh varchar2,b_loai varchar2,b_pp varchar2,b_t_suat number,b_thue number,
    b_mau varchar2,b_seri varchar2,b_so_hd varchar2,b_nd nvarchar2,b_ndp nvarchar2,b_tien number,b_tien_qd number,
    a_ma_ctr pht_type.a_var,a_hang pht_type.a_var,a_ma_mc pht_type.a_var,a_ma_vi pht_type.a_var,a_tien pht_type.a_num,a_tien_qd pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number;
begin
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','XL');
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'XL',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table XL:loi';
insert into xl_1 values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_ct,b_ngay_ct,b_ma_nt,b_tg_tt,
    b_k_ma_kh,b_ma_kh,b_loai,b_pp,b_t_suat,b_thue,b_mau,b_seri,b_so_hd,b_nd,b_ndp,b_tien,b_tien_qd,b_nsd,b_htoan,b_md,b_idvung);
for b_lp in 1..a_ma_ctr.count loop
    insert into xl_2 values(b_ma_dvi,b_so_id,a_ma_ctr(b_lp),a_hang(b_lp),a_ma_mc(b_lp),a_ma_vi(b_lp),a_tien(b_lp),a_tien_qd(b_lp),b_lp,b_idvung);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_HTKC_SL
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,b_ma varchar2,b_ngay_ht number,b_dvi varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - So lieu hach toan ket chuyen
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_HTKC_TEST(b_ma_dvi,b_ngayd,b_ngayc,b_ma,b_ngay_ht,b_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_HTKC_SLHT(b_ma_dvi,b_ngayd,b_ngayc,b_ma,b_ngay_ht,b_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select tk_no,tke_no,tk_co,tke_co,sum(tien) tien from kt_htkc_tk_temp group by tk_no,tke_no,tk_co,tke_co order by tk_no,tke_no,tk_co,tke_co;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_HTKC_TEST
    (b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_ma varchar2,b_ngay_ht number,b_dvi varchar2,b_loi out varchar2)
AS
begin
if b_ngayd is null or b_ngayc is null or b_ma is null or b_ngay_ht is null or b_dvi is null then
    b_loi:='loi:Nhap ngay, ma , don vi ket chuyen:loi';
else b_loi:='';
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_HTKC_SLHT
    (b_ma_dvi varchar2,b_ngayd number,b_ngayc number,b_ma varchar2,b_ngay_ht number,b_dvi varchar2,b_loi out varchar2)
AS
    b_ngay number; b_ma_tk varchar2(20); b_ma_tke varchar2(20); b_tc varchar2(100); b_ck boolean:=true;
    b_ma_tkeht varchar2(20); b_tien number;
begin
delete kt_htkc_tk_temp;
select nvl(max(ngay_ht),0) into b_ngay from kt_htkc where ma_dvi=b_ma_dvi and ma=b_ma and ngay_ht<=b_ngay_ht;
if b_ngay=0 then b_loi:='loi:Ma dinh nghia ket chuyen da xoa:loi'; return; end if;
for r_lp in (select * from kt_htkc_1 where ma_dvi=b_ma_dvi and ma=b_ma and ngay_ht=b_ngay) loop
    b_tc:='K'; b_ma_tkeht:='';
    if trim(r_lp.ma_tkeht) is not null then
        b_ma_tkeht:=r_lp.ma_tkeht;
    else
        b_tc:=FKT_TCHAT(b_ma_dvi,r_lp.ma_tk);
        if instr(b_tc,'TK')>0 then b_tc:='C'; end if;
    end if;
    if r_lp.loai in('DN','DC') then
        if b_ck then BKT_CDTK_TKE(b_dvi,b_ngayd,b_ngayc); b_ck:=false; end if;
        b_ma_tk:=trim(r_lp.ma_tk)||'%';
        if trim(r_lp.ma_tke) is not null then
            b_ma_tke:=trim(r_lp.ma_tke)||'%';
            for r_lp1 in (select * from kt_sc_temp_tke where ma_tk like b_ma_tk and ma_tke like b_ma_tke) loop
                if b_tc='C' then b_ma_tkeht:=r_lp1.ma_tke; end if;
                if r_lp.loai='DN' then
                    insert into kt_htkc_tk_temp values(r_lp.ma_tkht,b_ma_tkeht,r_lp1.ma_tk,r_lp1.ma_tke,r_lp1.no_ck-r_lp1.co_ck,'N');
                else
                    insert into kt_htkc_tk_temp values(r_lp1.ma_tk,r_lp1.ma_tke,r_lp.ma_tkht,b_ma_tkeht,r_lp1.co_ck-r_lp1.no_ck,'C');
                end if;
            end loop;
        else
            for r_lp1 in (select * from kt_sc_temp_tke where ma_tk like b_ma_tk) loop
                if b_tc='C' then b_ma_tkeht:=r_lp1.ma_tke; end if;
                if r_lp.loai='DN' then
                    insert into kt_htkc_tk_temp values(r_lp.ma_tkht,b_ma_tkeht,r_lp1.ma_tk,r_lp1.ma_tke,r_lp1.no_ck-r_lp1.co_ck,'N');
                else
                    insert into kt_htkc_tk_temp values(r_lp1.ma_tk,r_lp1.ma_tke,r_lp.ma_tkht,b_ma_tkeht,r_lp1.co_ck-r_lp1.no_ck,'C');
                end if;
            end loop;
        end if;
    end if;
end loop;
b_loi:='';
end;
/
create or replace procedure BKT_CDTK_TKE(b_ma_dvi varchar2,b_ngayd number,b_ngayc number)
AS
    b_ngaydn number;
begin
-- Dan - Can doi tai khoan + thong ke
delete kt_sc_temp_tke;
b_ngaydn:=round(b_ngayd,-4)+0101;
insert into kt_sc_temp_tke select ma_tk,ma_tke,0,0,0,0,no_ck,co_ck,0,0 from kt_sc where ma_dvi=b_ma_dvi and (ma_tk,ma_tke,ngay_ht) in 
    (select ma_tk,ma_tke,max(ngay_ht) from kt_sc where ma_dvi=b_ma_dvi and ngay_ht<=b_ngayc group by ma_tk,ma_tke);
update kt_sc_temp_tke set (no_ps,co_ps)=(select nvl(sum(no_ps),0),nvl(sum(co_ps),0) from kt_sc where
    ma_dvi=b_ma_dvi and ma_tk=kt_sc_temp_tke.ma_tk and ma_tke=kt_sc_temp_tke.ma_tke and ngay_ht between b_ngayd and b_ngayc);
update kt_sc_temp_tke set (no_lk,co_lk)=(select nvl(sum(no_ps),0),nvl(sum(co_ps),0) from kt_sc where
    ma_dvi=b_ma_dvi and ma_tk=kt_sc_temp_tke.ma_tk and ma_tke=kt_sc_temp_tke.ma_tke and ngay_ht between b_ngaydn and b_ngayc);
delete kt_sc_temp_tke where no_ck=0 and co_ck=0 and no_lk=0 and co_lk=0;
insert into kt_sc_temp_tke select ma_tk,ma_tke,no_ck,co_ck,0,0,0,0,0,0 from kt_sc where ma_dvi=b_ma_dvi and (ma_tk,ma_tke,ngay_ht) in
    (select ma_tk,ma_tke,max(ngay_ht) from kt_sc where ma_dvi=b_ma_dvi and ngay_ht<b_ngayd group by ma_tk,ma_tke);
end;
/
create or replace procedure PKT_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_lk out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_md varchar2(10); b_nsd_c varchar2(10);
begin
-- Dan - Xoa chung tu ke toan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then
    b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select md,lk,nsd into b_md,b_lk,b_nsd_c from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_md<>'KT' then
    b_loi:='loi:Khong sua, xoa chung tu Modul khac:loi'; raise PROGRAM_ERROR;
elsif b_nsd_c is not null and b_nsd_c<>b_nsd then
    b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; raise PROGRAM_ERROR;
end if;
PKT_KT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'KT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_HTKC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,b_ma varchar2,
    b_ngay_ht number,b_dvi varchar2,b_l_ct varchar2,b_so_ctN varchar2,b_ngay_ct varchar2,b_nd nvarchar2)
AS
    b_loi varchar2(100); b_idvung number; b_bt number:=0; b_kt number:=0; b_tt number:=0; b_bp_no boolean; b_bp_co boolean;
    b_so_id number; b_so_tt number; b_ma_tk varchar2(20); b_ma_tke varchar2(20);
    b_lk varchar2(100); b_ss varchar2(1); b_so_ct varchar2(20):=b_so_ctN;
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var;
    a_tien_kt pht_type.a_num; a_note pht_type.a_nvar; a_bt_kt pht_type.a_num;

    a_bt pht_type.a_num; a_nhom pht_type.a_var; a_ma_ttr pht_type.a_var;
    a_ma_lvuc pht_type.a_var; a_dvi pht_type.a_var; a_phong pht_type.a_var;
    a_ma_cb pht_type.a_var; a_viec pht_type.a_var; a_hdong pht_type.a_var;
    a_ma_sp pht_type.a_var; a_tien pht_type.a_num;
    
    a_bt_xl pht_type.a_num; a_nhom_xl pht_type.a_var; a_ma_ttr_xl pht_type.a_var;
    a_ma_lvuc_xl pht_type.a_var; a_dvi_xl pht_type.a_var; a_phong_xl pht_type.a_var;
    a_ma_cb_xl pht_type.a_var; a_viec_xl pht_type.a_var; a_hdong_xl pht_type.a_var;
    a_ma_sp_xl pht_type.a_var; a_tien_xl pht_type.a_num;
begin
delete kt_htkc_tk_temp; delete kt_sc_bp_temp; commit;
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','N');
if b_idvung<0 then b_loi:='loi:Cam xam nhap:loi'; raise PROGRAM_ERROR; end if;
PKT_HTKC_TEST(b_ma_dvi,b_ngayd,b_ngayc,b_ma,b_ngay_ht,b_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_HTKC_SLHT(b_ma_dvi,b_ngayd,b_ngayc,b_ma,b_ngay_ht,b_dvi,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
BKT_CDBP(b_dvi,b_ngayd,b_ngayc);
for r_lp in (select * from kt_htkc_tk_temp order by tk_no,tke_no,tk_co,tke_co) loop
    b_bp_no:=PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,'T',r_lp.tk_no);
    b_bp_co:=PKH_MA_LCT_TRA_LQ(b_ma_dvi,'BP','BP',b_ngay_ht,'T',r_lp.tk_co);
    if r_lp.nv='N' and b_bp_co then
        b_ma_tk:=r_lp.tk_co; b_ma_tke:=r_lp.tke_co;
    elsif r_lp.nv='C' and b_bp_no then
        b_ma_tk:=r_lp.tk_no; b_ma_tke:=r_lp.tke_no;
    end if;
    if b_kt<>0 then
        b_kt:=0; PKH_MANG_XOA(a_dvi); PKH_MANG_XOA(a_phong); PKH_MANG_XOA(a_hdong); PKH_MANG_XOA(a_ma_sp); PKH_MANG_XOA_N(a_tien);
    end if;
    if b_ma_tk is not null then
        for r_lp1 in (select * from kt_sc_bp_temp where ma_tk=b_ma_tk and ma_tke=b_ma_tke) loop
            b_kt:=b_kt+1;
            a_dvi(b_kt):=r_lp1.dvi; a_phong(b_kt):=r_lp1.phong;
            a_hdong(b_kt):=r_lp1.hdong; a_ma_sp(b_kt):=r_lp1.ma_sp;
            if r_lp.nv='C' then a_tien(b_kt):=r_lp1.no_ck-r_lp1.co_ck;
            else a_tien(b_kt):=r_lp1.co_ck-r_lp1.no_ck;
            end if;
        end loop;
    end if;
    b_bt:=b_bt+1;
    a_nv(b_bt):='N'; a_ma_tk(b_bt):=r_lp.tk_no; a_ma_tke(b_bt):=r_lp.tke_no; a_tien_kt(b_bt):=r_lp.tien; a_note(b_bt):=' '; a_bt_kt(b_bt):=b_bt;
    if b_bp_no and b_kt<>0 then
        for b_lp in 1..b_kt loop
            b_tt:=b_tt+1;
            a_bt_xl(b_tt):=b_bt; a_dvi_xl(b_tt):=a_dvi(b_lp); a_phong_xl(b_tt):=a_phong(b_lp);
            a_hdong_xl(b_tt):=a_hdong(b_lp); a_ma_sp_xl(b_tt):=a_ma_sp(b_lp); a_tien_xl(b_tt):=a_tien(b_lp);
        end loop;
    end if;
    b_bt:=b_bt+1;
    a_nv(b_bt):='C'; a_ma_tk(b_bt):=r_lp.tk_co; a_ma_tke(b_bt):=r_lp.tke_co; a_tien_kt(b_bt):=r_lp.tien; a_note(b_bt):=' '; a_bt_kt(b_bt):=b_bt;
    if b_bp_co and b_kt<> 0 then
        for b_lp in 1..b_kt loop
            b_tt:=b_tt+1;
            a_bt_xl(b_tt):=b_bt; a_dvi_xl(b_tt):=a_dvi(b_lp); a_phong_xl(b_tt):=a_phong(b_lp);
            a_hdong_xl(b_tt):=a_hdong(b_lp); a_ma_sp_xl(b_tt):=a_ma_sp(b_lp); a_tien_xl(b_tt):=a_tien(b_lp);
        end loop;
    end if;
end loop;
if b_bt=0 then b_loi:='loi:Da ket chuyen het:loi'; raise PROGRAM_ERROR; end if;
b_so_tt:=0; PHT_ID_MOI(b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_KT_NH(b_ma_dvi,b_nsd,'H',b_ngay_ht,b_l_ct,b_so_tt,b_so_ct,b_ngay_ct,b_nd,' ',
    a_nv,a_ma_tk,a_ma_tke,a_tien_kt,a_note,a_bt_kt,b_so_id,'KT',b_lk,b_loi,'C');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tt>0 then
    for b_lp in 1..b_tt loop
        insert into kt_bp values(b_ma_dvi,b_so_id,a_bt_xl(b_lp),b_ngay_ht,'KC',
            a_dvi_xl(b_lp),a_phong_xl(b_lp),' ',a_hdong_xl(b_lp),' ',
            ' ',a_ma_sp_xl(b_lp),a_tien_xl(b_lp),0,b_lp,b_idvung);
    end loop;
    PKT_BP_THOP(b_ma_dvi,'N',b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PKT_CT_BP_LKET(b_ma_dvi,b_so_id,b_ss,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
    PKT_LKET_NV(b_ma_dvi,'BP',b_so_id,b_ss,b_lk,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure BKT_CDBP(b_ma_dvi varchar2,b_ngayd number,b_ngayc number)
AS
    b_ngaydn number;
begin
-- Dan - Tong hop phan bo bo phan, san pham
delete kt_sc_bp_temp1; delete kt_sc_bp_temp;
b_ngaydn:=round(b_ngayd,-4)+0101;
insert into kt_sc_bp_temp1 select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,0,0,0,0,no_ck,co_ck,0,0
    from kt_sc_bp where ma_dvi=b_ma_dvi and (ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,ngay_ht) in 
    (select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,max(ngay_ht)
    from kt_sc_bp where ma_dvi=b_ma_dvi and ngay_ht<=b_ngayc group by ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp);
insert into kt_sc_bp_temp1 select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,0,0,nvl(sum(no_ps),0),nvl(sum(co_ps),0),0,0,0,0
    from kt_sc_bp where ma_dvi=b_ma_dvi and ngay_ht between b_ngayd and b_ngayc group by ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp;
insert into kt_sc_bp_temp1 select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,0,0,0,0,0,0,nvl(sum(no_ps),0),nvl(sum(co_ps),0)
    from kt_sc_bp where ma_dvi=b_ma_dvi and ngay_ht between b_ngaydn and b_ngayc group by ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp;
insert into kt_sc_bp_temp1 select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,no_ck,co_ck,0,0,0,0,0,0
    from kt_sc_bp where ma_dvi=b_ma_dvi and (ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,ngay_ht) in
    (select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,max(ngay_ht)
    from kt_sc_bp where ma_dvi=b_ma_dvi and ngay_ht<b_ngayd group by ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp);
insert into kt_sc_bp_temp select ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp,sum(no_dk),sum(co_dk),sum(no_ps),sum(co_ps),sum(no_ck),sum(co_ck),sum(no_lk),sum(co_lk)
    from kt_sc_bp_temp1 group by ma_tk,ma_tke,ma_ttr,ma_lvuc,dvi,phong,ma_cb,viec,hdong,ma_sp;
delete kt_sc_bp_temp where no_ck=0 and co_ck=0 and no_lk=0 and co_lk=0;
end;
/
create or replace procedure PCN_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu cong no theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    select count(*) into b_dong from cn_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select a.*,FCN_SO_REF(b_ma_dvi,so_id) so_ref from

        (select so_id,so_ct,tien,nd,row_number() over (order by so_id) sott
        from cn_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) a where sott between b_tu and b_den;
else
    select count(*) into b_dong from cn_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select a.*,FCN_SO_REF(b_ma_dvi,so_id) so_ref from
        (select so_id,so_ct,tien,nd,row_number() over (order by so_id) sott
        from cn_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) a
        where sott between b_tu and b_den;
end if;
end;
/
create or replace function FCN_SO_REF(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(50); b_i1 number;
begin
-- Dan - Tra so ref
select min(viec),count(*) into b_kq,b_i1 from (select distinct viec from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id) where trim(viec) is not null;
if b_i1<>1 then b_kq:=''; end if;
return b_kq;
end;
/
create or replace procedure PCN_DCTG_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_ma_tk varchar2,cs_1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_noite varchar2(5); b_ma_nt varchar2(5);
begin
-- Dan - Tim chenh lech ty gia cong no ngoai te
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_noite:=FTT_TRA_NOITE(b_ma_dvi);
delete temp_1; delete temp_2; commit;
insert into temp_1(n1,n2,n3,c1,c2,c3,c4,c5,c8,c9,c6,n4,n5)
    select so_id,bt,ngay_ht,nd,l_ct,ma_cn,ma_nt,ma_tk,viec,hdong,ma_ctr,tien-tra,tien_qd-tra_qd from cn_ps where
    ma_dvi=b_ma_dvi and ma_nt<>b_noite and tien<>tra and b_ma_tk in(ma_tk,' ') and ngay_ht<=b_ngay_ht;
insert into temp_2(c1) (select distinct c4 from temp_1);
for r_lp in (select c1 ma_nt from temp_2) loop
    b_ma_nt:=r_lp.ma_nt;
    b_i1:=FTT_TRA_TGTT(b_ma_dvi,b_ngay_ht,b_ma_nt);
    update temp_1 set n6=round(n4*b_i1,0)-n5 where c4=b_ma_nt;
end loop;
open cs_1 for select n1 so_id,n2 bt,PKH_SO_CNG(n3) ngay,c1 nd,c2 l_ct,c3 ma_cn,c4 ma_nt,c5 ma_tk,
    c8 viec,c9 hdong,c6 ma_ctr,n4 tien,n5 tien_qd,n6 tien_dc
    from temp_1 where n6<>0 order by c4,n3,c2,c3;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PDP_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','DP','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_klk ='T' then
    select count(*) into b_dong from dp_ct where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,so_ct,tien,row_number() over (order by so_id) sott
        from dp_ct where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from dp_ct where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,so_ct,tien,row_number() over (order by so_id) sott
        from dp_ct where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_MA_KH_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_klk varchar2,b_tim nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_klk='T' then
    if b_tim is null then
        select count(*) into b_dong from cn_ma_kh where ma_dvi=b_ma_dvi;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_kh
            where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from cn_ma_kh where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_kh
            where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
    end if;
else
    if b_tim is null then
        select count(*) into b_dong from cn_ma_kh where ma_dvi=b_ma_dvi and nhom in (b_klk,'T');
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_kh
            where ma_dvi=b_ma_dvi and nhom in (b_klk,'T') order by ma) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from cn_ma_kh where ma_dvi=b_ma_dvi and nhom in (b_klk,'T') and upper(ten) like b_tim;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_kh
            where ma_dvi=b_ma_dvi and nhom in (b_klk,'T') and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_MA_DL_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tim nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem ma khach hang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from cn_ma_dl where ma_dvi=b_ma_dvi;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_dl
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from cn_ma_dl where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_dl
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_TK_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if; 
b_loi:='loi:Loi Table kh_ma_lct:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md in('CN','SE') and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md in('CN','SE') and ngay=b_ngay;
b_loi:='loi:Loi Table CN_TK:loi';
delete cn_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PDP_MA_HESO_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
--- Liet ke he so trich du phong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','DP','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select distinct ngay_ht from dp_ma_heso where ma_dvi=b_ma_dvi order by ngay_ht;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PDP_MA_HESO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht varchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
--  Xoa he so trich du phong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','DP','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay_ht is null or b_ngay_ht<=0 then b_loi:='loi:Nhap ngay ap dung:loi'; raise PROGRAM_ERROR; end if;
delete dp_ma_heso where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCD_CT_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_dvi varchar2,b_l_ct varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CD','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if trim(b_dvi) is null then
    if b_l_ct in ('TD','CD') then
        select count(*) into b_dong from cd_ch where ma_dvi=b_ma_dvi and l_ct=b_l_ct and ngay_du=0;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by so_id) sott
            from cd_ch where ma_dvi=b_ma_dvi and l_ct=b_l_ct and ngay_du=0 order by so_id) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from cd_ch where ma_dvi=b_ma_dvi and l_ct=b_l_ct and htoan='T';
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by so_id) sott
            from cd_ch where ma_dvi=b_ma_dvi and l_ct=b_l_ct and htoan='T' order by so_id) where sott between b_tu and b_den;
    end if;
else
    if b_l_ct in ('TD','CD') then
        select count(*) into b_dong from cd_ch where ma_dvi=b_ma_dvi and dvi=b_dvi and l_ct=b_l_ct and ngay_du=0;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by so_id) sott
            from cd_ch where ma_dvi=b_ma_dvi and dvi=b_dvi and l_ct=b_l_ct and ngay_du=0 order by so_id) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from cd_ch where ma_dvi=b_ma_dvi and dvi=b_dvi and l_ct=b_l_ct and htoan='T';
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by so_id) sott
            from cd_ch where ma_dvi=b_ma_dvi and dvi=b_dvi and l_ct=b_l_ct and htoan='T' order by so_id) where sott between b_tu and b_den;
    end if;
end if;
end;
/
create or replace procedure PVT_MA_NHOM_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_nhom varchar2)
AS
	b_loi varchar2(100); b_i1 number; b_i2 number:=0; b_idvung number;
begin
-- Nhap ma nhom
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_nhom is null or b_nhom not in('V','H','S','C') then b_loi:='loi:Sai loai:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete vt_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
insert into vt_ma_nhom values (b_ma_dvi,b_ma,b_ten,b_nhom,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_CL_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
	b_loi varchar2(100); b_idvung number;
begin
-- Nhap ma chat luong
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma chat luong:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete vt_ma_cl where ma_dvi=b_ma_dvi and ma=b_ma;
insert into vt_ma_cl values (b_ma_dvi,b_ma,b_ten,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_DVT_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_so_tp number)
AS
	b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_so_tp is null then b_loi:='loi:Nhap phan thap phan khi doi don vi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete vt_ma_dvt where ma_dvi=b_ma_dvi and ma=b_ma;
insert into vt_ma_dvt values (b_ma_dvi,b_ma,b_ten,b_so_tp,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_VT_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,b_tim nvarchar2,
  b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100); b_i1 number; b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Xem ma vat tu
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Nhap sai nhom vat tu:loi';
if b_nhom is null then b_loi:='loi:Nhap sai nhom vat tu:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
  insert into temp_1(c1,c2,c3,n2) select ma,nvl(ma_ct,' '),ten,so_id from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom order by ma;
  b_dong:=sql%rowcount;
  PKH_LKE_TRANG(b_dong,b_tu,b_den);
  insert into temp_2(c1,c2,c3,n2,c10,n1) select c1,c2,c3,n2,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,rownum
    from temp_1 start with c2=' ' CONNECT BY prior c1=c2;
  open cs_lke for select c10 xep,c1 ma,c3 ten,n2 so_id
    from (select c10,c1,c3,n2,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
else
  insert into temp_1(c1,c3,n2) select ma,ten,so_id from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and upper(ten) like b_tim order by ma;
  b_dong:=sql%rowcount;
  PKH_LKE_TRANG(b_dong,b_tu,b_den);
  open cs_lke for select c1 xep,c1 ma,c3 ten,n2 so_id from
    (select c1,c3,n2,row_number() over (order by c1) sott from temp_1 order by c1) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_KHO_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,
	b_gon nvarchar2,b_ma_tk varchar2,b_pp varchar2,b_thu_kho nvarchar2,b_ma_ct varchar2)
AS
	b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma kho
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma kho:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten kho:loi'; raise PROGRAM_ERROR; end if;
if b_ma_tk is not null then
	b_loi:='loi:Ma tai khoan chua dang ky:loi';
	select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
end if;
if b_pp is null or b_pp not in(' ','N','S','B','G') then
	b_loi:='loi:Sai phuong phap xuat kho:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Sai ma quan ly:loi';
if b_ma_ct=b_ma then raise PROGRAM_ERROR;
elsif trim(b_ma_ct) is not null then
	select 0 into b_i1 from vt_ma_kho where ma_dvi=b_ma_dvi and ma=b_ma_ct;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete vt_ma_kho where ma_dvi=b_ma_dvi and ma=b_ma;
insert into vt_ma_kho values(b_ma_dvi,b_ma,b_ten,b_gon,b_ma_tk,b_pp,b_thu_kho,b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_KH_TTT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ps varchar2,b_nv varchar2,
    a_ma pht_type.a_var,a_ten pht_type.a_nvar,a_loai pht_type.a_var,a_bb pht_type.a_var,
    a_ktra pht_type.a_var,a_f_tkhao pht_type.a_var,a_f_sht_tkhao pht_type.a_var,a_lke pht_type.a_nvar,a_tra pht_type.a_nvar)
AS
    b_loi varchar2(100);
begin
-- Dan - Nhap thong tin them chung tu theo nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_ps,'M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if a_ma.count=0 then b_loi:='loi:Nhap thong tin them:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma.count loop
    b_loi:='loi:Nhap sai dong '||to_char(b_lp)||':loi';
    if trim(a_ma(b_lp)) is null or trim(a_ten(b_lp)) is null or
        a_loai(b_lp) is null or a_loai(b_lp) not in('C','H','S','N','K','L','D','G') or
        a_bb(b_lp) is null or a_bb(b_lp) not in('C','K') then raise PROGRAM_ERROR;
    end if;
end loop;
b_loi:='loi:Va cham NSD:loi';
delete kt_kh_ttt where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv;
for b_lp in 1..a_ma.count loop
    insert into kt_kh_ttt(ma_dvi,ps,nv,ma,ten,loai,bb,ktra,f_tkhao,f_sht_tkhao,lke,tra,bt,nsd) 
        values(b_ma_dvi,b_ps,b_nv,a_ma(b_lp),a_ten(b_lp),a_loai(b_lp),
        a_bb(b_lp),a_ktra(b_lp),a_f_tkhao(b_lp),a_f_sht_tkhao(b_lp),a_lke(b_lp),a_tra(b_lp),b_lp,b_nsd);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_KH_TTT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ps varchar2,b_nv varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT',b_ps,'M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete kt_kh_ttt where ma_dvi=b_ma_dvi and ps=b_ps and nv=b_nv;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_TK_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,
	cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select * from kh_ma_lct where ma_dvi=b_ma_dvi and md='VT' and ngay=b_ngay;
open cs2 for select * from kh_ma_lct_tk where ma_dvi=b_ma_dvi and md='VTL' and ngay=b_ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_TK_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table kh_ma_lct:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md in('VT','VTL') and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md='VT' and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_TIM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd date,b_ngayc date,b_ten nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo so the va ten
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_ngayd='01-jan-3000' and b_ngayc='01-jan-3000' then
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from cc_sc where ma_dvi=b_ma_dvi and upper(ten) like b_ten;
elsif b_ngayd='01-jan-3000' then
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from cc_sc where ma_dvi=b_ma_dvi and ngay_ht<=b_ngayc and (b_ten is null or upper(ten) like b_ten);
elsif b_ngayc='01-jan-3000' then
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from cc_sc where ma_dvi=b_ma_dvi and ngay_ht>=b_ngayd and (b_ten is null or upper(ten) like b_ten);
else
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from cc_sc where ma_dvi=b_ma_dvi and (ngay_ht between b_ngayd and b_ngayc) and (b_ten is null or upper(ten) like b_ten);
end if;
b_dong:=sql%rowcount;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select ' ' nhom,' ' ma_ts,1 so_ts,n1 so_id,c1 so_the,c2 ten,' ' ma_ct,0 cap,'C' tc from 
    (select n1,c1,c2,row_number() over (order by c1) sott from temp_1 order by c1) where sott between b_tu and b_den;
end;
/
create or replace procedure PCC_PB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Xem phan bo
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_so_the) is null then b_loi:='loi:Nhap the cong cu:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FCC_SO_ID(b_ma_dvi,b_so_the);
if b_so_id=0 then b_loi:='loi:Cong cu da xoa:loi'; raise PROGRAM_ERROR; end if;
select ten into b_ten from cc_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs1 for select distinct ngay from cc_pb where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FCC_SO_ID(b_ma_dvi varchar2,b_so_the varchar2) return number
AS
    b_so_id number;
begin
-- Dan - Hoi so ID cua qua so the
select nvl(max(so_id),0) into b_so_id from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the;
return b_so_id;
end;
/
create or replace procedure PCC_PB_COPY
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2)
AS
    b_loi varchar2(100); b_so_id number; b_so_id_vt number; b_idvung number;
begin
-- Dan -- Copy phan bo
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','CC','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_the is null then b_loi:='loi:Nhap the cong cu:loi'; raise PROGRAM_ERROR; end if;
b_so_id:=FCC_SO_ID(b_ma_dvi,b_so_the);
if b_so_id=0 then b_loi:='loi:Cong cu da xoa:loi'; raise PROGRAM_ERROR; end if;
select so_id_vt into b_so_id_vt from cc_sc where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_so_id_vt=0 then b_loi:='loi:Cong cu khong gan voi phieu xuat vat tu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table CC_PB:loi';
for r_lp in (select so_id from cc_sc where ma_dvi=b_ma_dvi and so_id_vt=b_so_id_vt) loop
    if b_so_id<>r_lp.so_id then
        delete cc_pb where ma_dvi=b_ma_dvi and so_id=r_lp.so_id;
        insert into cc_pb select b_ma_dvi,r_lp.so_id,ngay,ma_tk,ma_tke,dvi,pt,b_nsd,bt,b_idvung from cc_pb where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_PTU_TEN(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_ptu varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem phu tung goc
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from cc_ptu_1 where ma_dvi=b_ma_dvi and so_ptu=b_so_ptu;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PCC_SU_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Liet ke sua 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Cong cu chua co:loi';
select ten,so_id into b_ten,b_so_id from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select a.*,to_char(ngay_di,'yyyymmdd') di_so from cc_su a
    where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay_di;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_KHAO_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem qua trinh khao hao
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san chua co:loi';
select ten into b_ten from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select * from cc_khao where ma_dvi=b_ma_dvi and so_the=b_so_the order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_KHAO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan -- Xoa qua trinh khao hao tai san
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_the is null then b_loi:='loi:Nhap the tai san:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table cc_khao:loi';
delete cc_khao where ma_dvi=b_ma_dvi and so_the=b_so_the;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_VT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_klk='T' then
    select count(*) into b_dong from tv_vt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,mau||'+'||seri||'+'||so_hd so_ct,
        row_number() over (order by so_id) sott from tv_vt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tv_vt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,mau||'+'||seri||'+'||so_hd so_ct,
        row_number() over (order by so_id) sott from tv_vt where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and nsd=b_nsd order by so_id)
        where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_CT_LKE_LCT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke loai chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select ma,min(ten) ten from kh_ma_lct where ma_dvi=b_ma_dvi and md='TV' group by ma
    order by decode(ma,'R',0,'V',1,'N',2,'T',3,'H',4,5);
end;
/
create or replace procedure PTV_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu tien te theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk='T' then
    select count(*) into b_dong from tv_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,t_toan,
        row_number() over (order by so_id) sott from tv_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id)
        where sott between b_tu and b_den;
else
    select count(*) into b_dong from tv_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,t_toan,
        row_number() over (order by so_id) sott from tv_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id)
        where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PTV_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_d number,b_ngay_c number,
    b_treo varchar2,b_dc varchar2,b_l_ct varchar2,b_mau varchar2,
    b_seri varchar2,b_so_hd varchar2,b_ma_thue varchar2,
    b_tien_d number,b_tien_c number,b_ten nvarchar2,b_dchi nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n; 
begin
-- Dan - Tim kiem chung tu thue GTGT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; delete temp_2; commit;
insert into temp_2(n1,c1) select so_id,l_ct from tv_1 where ma_dvi=b_ma_dvi and htoan in('T',b_treo) and
    (ngay_ht between b_ngay_d and b_ngay_c) and (b_l_ct is null or l_ct=b_l_ct);
if b_dc='C' then
    delete temp_2 where exists(select * from kt_1 where
    ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'TV:2')>0);
end if;
insert into temp_1(n1,n2,n3,n4,c1,c2,c3,c4,c5,c6,c7) select so_id,bt,ngay_ht,t_toan,c1,mau,seri,so_hd,ten,ma_thue,dchi
    from tv_2,temp_2 where ma_dvi=b_ma_dvi and so_id=n1;
if b_tien_d<>0 or b_tien_c<>0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.E18;
    elsif b_tien_d=0 then b_n1:=-1.E18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where n4 not between b_n1 and b_n2;
end if;
if b_mau is not null then
    delete temp_1 where c2 is null or c2<>b_mau;
end if;
if b_seri is not null then
    delete temp_1 where c3 is null or c3<>b_seri;
end if;
if b_so_hd is not null then
    delete temp_1 where c4 is null or instr(c4,b_so_hd)=0;
end if;
if b_ten is not null then
    delete temp_1 where c5 is null or upper(c5) not like b_ten;
end if;
if b_dchi is not null then
    delete temp_1 where c7 is null or upper(c7) not like b_dchi;
end if;
if b_ma_thue is not null then
    delete temp_1 where c6 is null or instr(c6,b_ma_thue)=0;
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select n1 so_id,c1 l_ct,c3 seri,c4 so_hd,n4 t_toan,PKH_SO_CNG(n3) ngay_htc,
    row_number() over (order by n3,c1,c3,c4) sott from temp_1 order by n3,c1,c3,c4)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PTV_MA_HD_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);b_i1 number;b_i2 number;
begin
--- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma chi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham nguoi su dung:loi';
delete tv_ma_hd where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_MA_NHOM_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
--- Dan - Nhap ma nhom thue
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma chi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham nguoi su dung:loi';
delete tv_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_NGAY_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Hung - Nhap ngay bao cao thue
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TV','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay not between 1 and 31 then b_loi:='loi:Nhap sai ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham nguoi su dung:loi';
delete tv_ngay where ma_dvi=b_ma_dvi;
insert into tv_ngay values (b_ma_dvi,b_ngay,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PPB_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_l_ct varchar2,b_so_ct varchar2,b_so_id out number)
AS
    b_loi varchar2(100);
begin
-- Dan - Hoi so ID cua 1 chung tu phan bo qua L_CT,SO_CT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','PB','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select nvl(min(so_id),0) into b_so_id from pb_0 where ma_dvi=b_ma_dvi and l_ct=b_l_ct and so_ct=b_so_ct;
end;
/
create or replace procedure PPB_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_d number,
    b_ngay_c number,b_treo varchar2,b_dc varchar2,b_so_ct varchar2,
    b_tien_d number,b_tien_c number,b_nd nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number; b_tu number:=b_tu_n; b_den number:=b_den_n; 
begin
-- Dan - Tim kiem chung tu phan bo
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','PB','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; commit;
insert into temp_1(n1) select so_id from pb_0 where ma_dvi=b_ma_dvi
    and htoan in('T',b_treo) and (ngay_ht between b_ngay_d and b_ngay_c)
    and (b_so_ct is null or upper(so_ct) like b_so_ct or upper(so_hd) like b_so_ct)
    and (b_nd is null or upper(nd) like b_nd);
if b_tien_d<>0 or b_tien_c<>0 then
    if b_tien_c=0 then b_n1:=b_tien_d; b_n2:=1.E18;
    elsif b_tien_d=0 then b_n1:=-1.E18; b_n2:=b_tien_c;
    else b_n1:=b_tien_d; b_n2:=b_tien_c;
    end if;
    delete temp_1 where not exists(select * from pb_0 where ma_dvi=b_ma_dvi and so_id=n1 and (tien between b_n1 and b_n2));
end if;
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where
    ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'PB:0')=0 and instr(lk,'PB:1')=0);
end if;
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,so_ct,tien,nd,PKH_SO_CNG(ngay_ht) ngay_htc,
    row_number() over (order by ngay_ht,l_ct,so_id) sott from pb_0,temp_1
    where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,l_ct,so_id)
    where sott between b_tu and b_den;
end;
/
create or replace procedure PPB_MA_NHOM_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2)
AS
	b_loi varchar2(100); b_idvung number;
begin
--- Dan - Nhap nhom ma phan bo
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma nhom:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table pb_ma_nhom:loi';
delete pb_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
insert into pb_ma_nhom values(b_ma_dvi,b_ma,b_ten,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_TIM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd date,b_ngayc date,b_ten nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo so the va ten
delete temp_1;delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_ngayd='01-jan-3000' and b_ngayc='01-jan-3000' then
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from ts_sc_1 where ma_dvi=b_ma_dvi and upper(ten) like b_ten;
elsif b_ngayd='01-jan-3000' then
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from ts_sc_1 where ma_dvi=b_ma_dvi and ng_qd<=b_ngayc and (b_ten is null or upper(ten) like b_ten);
elsif b_ngayc='01-jan-3000' then
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from ts_sc_1 where ma_dvi=b_ma_dvi and ng_qd>=b_ngayd and (b_ten is null or upper(ten) like b_ten);
else
    insert into temp_1(c1,c2,n1) select so_the,ten,so_id from ts_sc_1 where ma_dvi=b_ma_dvi and (ng_qd between b_ngayd and b_ngayc) and (b_ten is null or upper(ten) like b_ten);
end if;
b_dong:=sql%rowcount;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select ' ' ma_ts,1 so_ts,n1 so_id,c1 so_the,c2 ten,' ' ma_ct,0 cap,'C' tc from
    (select n1,c1,c2,row_number() over (order by c1) sott from temp_1 order by c1) where sott between b_tu and b_den;
end;
/
create or replace procedure PTS_DC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ngay_qd date,
    b_so_qd varchar2,b_dvi_sd varchar2,b_phong varchar2,b_ma_cb varchar2,b_dchi nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_d1 date; b_idvung number;
begin
-- Dan - Nhap dieu chuyen
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TS','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_the is null or trim(b_so_the) is null then b_loi:='loi:Nhap the tai san:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_qd is null then b_loi:='loi:Nhap ngay dieu chuyen:loi'; raise PROGRAM_ERROR; end if;
if b_dvi_sd is null then b_loi:='loi:Nhap don vi su dung:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma don vi su dung chua dang ky:loi';
select 0 into b_i1 from ht_ma_dvi where ma=b_dvi_sd;
if b_phong is not null then
    b_loi:='loi:Ma bo phan chua dang ky:loi';
    select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
end if;
if b_ma_cb is not null then
    b_loi:='loi:Ma nguoi su dung chua dang ky:loi';
    select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_cb;
end if;
b_loi:='loi:The tai san chua co:loi';
select 0 into b_i1 from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the for update nowait;
if sqlcode<>0 or sql%rowcount=0 then raise PROGRAM_ERROR; end if;
delete ts_dc where ma_dvi=b_ma_dvi and so_the=b_so_the and ngay_qd=b_ngay_qd;
insert into ts_dc values(b_ma_dvi,b_so_the,b_ngay_qd,b_so_qd,b_dvi_sd,b_phong,b_ma_cb,b_dchi,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_PB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem phan bo tai san
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san da xoa:loi';
select ten into b_ten from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs1 for select distinct ngay from ts_pb where ma_dvi=b_ma_dvi and so_the=b_so_the order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_KHAO_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem qua trinh khao hao
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san chua co:loi';
select ten into b_ten from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select * from ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_KHAO_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan -- Xoa qua trinh khao hao tai san
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_the is null then b_loi:='loi:Nhap the tai san:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table TS_KHAO:loi';
delete ts_khao where ma_dvi=b_ma_dvi and so_the=b_so_the;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_SU_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Liet ke sua 
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Cong cu chua co:loi';
select ten,so_id into b_ten,b_so_id from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select a.*,to_char(ngay_di,'yyyymmdd') di_so from ts_su a
    where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay_di;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_PTU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san chua co:loi';
select ten,so_id into b_ten,b_so_id from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select a.*,FTS_PTU_SO_ID_THE(b_ma_dvi,so_id_ptu) so_ptu,FTS_PTU_SO_ID_TEN(b_ma_dvi,so_id_ptu) ten
    from ts_ptu_2 a where ma_dvi=b_ma_dvi and so_id_ts=b_so_id order by so_id_ptu,ngay,so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_BD_LKE_LCT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Liet ke loai chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select ma,min(ten) ten from kh_ma_lct where ma_dvi=b_ma_dvi and md='TS' group by ma
  order by decode(ma,'T',0,'G',1,2);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_TKE_TK_LIST(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma_tk varchar2,b_ma_n varchar2,b_trangKt number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(100); b_min varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=b_ma_n||'%';
select count(*),min(ma_tke) into b_i1,b_min from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=b_ma_tk and ma_tke like b_ma;
if b_i1>b_trangKt or (b_i1=1 and b_min=b_ma_n) then
    open cs1 for select c1 ma,c2 ten from temp_1 where rownum=0;
else
    open cs1 for select ma_tke ma,ten from kt_ma_tktke  where ma_dvi=b_ma_dvi and ma_tk=b_ma_tk and ma_tke like b_ma order by ma_tke;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_CT_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,
    b_ma varchar2,b_ma2 varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_c1 varchar2(1);
begin
-- Dan - Hoi ten cac ma khi nhap chung tu hach toan
if b_nv='L_CT' then
    b_loi:='loai chung tu';
    b_i1:=to_number(b_ma2);
    select min(ten) into b_ten from kh_ma_lct where ma_dvi=b_ma_dvi and md='KT' and ma=b_ma and ngay<=b_i1;
    if b_ten is null then raise PROGRAM_ERROR; end if;
elsif b_nv='MA_TK' then
    b_loi:='tai khoan';
    select ten into b_ten from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='MA_TKE' then
    b_loi:='thong ke';
    select ten into b_ten from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=b_ma and ma_tke=b_ma2;
elsif b_nv='MA_LC' then
    b_loi:='luu chuyen tien te';
    select ten,tc into b_ten,b_c1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma;
    if b_c1='G' then b_loi:='loi:Sai tinh chat ma luu chuyen tien te:loi'; raise PROGRAM_ERROR; end if;
elsif b_nv='MA_SP' then
    b_loi:='san pham';
    select ten into b_ten from vt_ma_vt where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
exception when others then raise_application_error(-20105,'loi:Ma#'||b_loi||'#chua dang ky:loi');
end;
/
CREATE OR REPLACE PROCEDURE PTS_MA_TS_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma varchar2,b_ten nvarchar2,b_don_vi varchar2,b_loai varchar2,b_tc varchar2,b_ma_ql varchar2,
    a_kieu in out pht_type.a_var,a_ngay pht_type.a_date,a_ppt pht_type.a_var,
    a_nam pht_type.a_num,a_dt pht_type.a_num,a_gh pht_type.a_num)
AS
    b_loi varchar2(100); b_idvung number; b_i1 number;
begin
-- Dan - Nhap he thong ma tai san
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TS','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma)='' then b_loi:='loi:Nhap ma tai san:loi'; raise PROGRAM_ERROR; end if;
if b_loai is null or b_loai not in('H','V','T') then
    b_loi:='loi:Loai tai san: H-Huu hinh,V-Vo hinh,T-Thue tai tai chinh:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Sai tinh chat:loi';
if b_tc is null or b_tc not in('T','C') then raise PROGRAM_ERROR;
    if b_tc='C' then
        select count(*) into b_i1 from ts_ma_ts where b_ma_dvi=b_ma_dvi and ma_ql=b_ma;
        if b_i1<>0 then raise PROGRAM_ERROR; end if;
    end if;
end if;
b_loi:='loi:Sai ma bac cao:loi';
if b_ma_ql is null then raise PROGRAM_ERROR;
elsif trim(b_ma_ql) is not null then
    select 0 into b_i1 from ts_ma_ts where b_ma_dvi=b_ma_dvi and ma=b_ma_ql and tc='T';
end if;
b_loi:='loi:Loi Table MA_TS:loi';
delete ts_ma_ts where ma_dvi=b_ma_dvi and ma=b_ma;
insert into ts_ma_ts values (b_ma_dvi,b_ma,b_ten,b_don_vi,b_loai,b_tc,b_ma_ql,b_nsd,b_idvung);
b_loi:='loi:Loi Table MA_TS_KH:loi';
delete ts_ma_ts_kh where ma_dvi=b_ma_dvi and ma=b_ma;
PKH_MANG(a_kieu);
for b_lp in 1..a_kieu.count loop
    if a_kieu(b_lp) is null or trim(a_kieu(b_lp)) is null then
        b_loi:='loi:Nhap kieu:loi'; raise PROGRAM_ERROR;
    end if;
    if a_ngay(b_lp) is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
    if a_ppt(b_lp) is null or a_ppt(b_lp) not in ('N','P','S','C') then
        b_loi:='loi:P.phap tinh k.hao: N-Nam, P-Phan tram nam, S-So du giam dan, C-Co dinh theo nam su dung:loi'; raise PROGRAM_ERROR;
    end if;
    if a_nam(b_lp) is null then
        b_loi:='loi:Nhap % khau hao ,nam SD'; raise PROGRAM_ERROR;
    end if;
    insert into ts_ma_ts_kh values(b_ma_dvi,b_ma,a_kieu(b_lp),a_ngay(b_lp),a_ppt(b_lp),a_nam(b_lp),a_dt(b_lp),a_gh(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_MA_BDONG_NH
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
  b_ten nvarchar2,b_loai varchar2,b_xl varchar2,b_tc varchar2,cs1 out pht_type.cs_type)
AS
  b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap ma bien dong tai san
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TS','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma bien dong:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
if b_loai is null or b_loai not in ('T','G','C','K') then
  b_loi:='loi:Loai: T-Tang, G-Giam, C-K.hao ky, K-Luy ke k.hao:loi'; raise PROGRAM_ERROR;
end if;
if b_xl is null or b_xl not in ('S','T') then
  b_loi:='loi:Xu ly: T-Trong thang; S-Sau mot thang:loi'; raise PROGRAM_ERROR;
end if;
if b_tc is null or b_tc not in ('C','T') then
  b_loi:='loi:Tinh chat:C-Chi tiet; T-Tong:loi'; raise PROGRAM_ERROR;
end if;
delete ts_ma_bdong where ma_dvi=b_ma_dvi and ma=b_ma;
insert into ts_ma_bdong values(b_ma_dvi,b_ma,b_ten,b_loai,b_xl,b_tc,b_nsd,b_idvung);
commit;
open cs1 for select * from ts_ma_bdong where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_MA_TT_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
	b_ten nvarchar2,b_tc varchar2,cs_lke out pht_type.cs_type)
AS
	b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap ma so no
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TS','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tc not in ('C','T') then b_loi:='loi:Tinh chat:C-Chi tiet; T-Tong:loi'; raise PROGRAM_ERROR; end if;
delete ts_ma_tt where ma_dvi=b_ma_dvi and ma=b_ma;
insert into ts_ma_tt values (b_ma_dvi,b_ma,b_ten,b_tc,b_nsd,b_idvung);
commit;
open cs_lke for select * from ts_ma_tt where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_TH_XOA(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
	b_loi varchar2(100); b_ngc date;
begin
-- Dan - Xoa tong hop so cai khau hao
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ngc:=PKH_SO_CDT(b_ngay); b_ngc:=add_months(trunc(b_ngc,'MONTH'),1)-1;
b_loi:='loi:Loi xoa Table TS_KH:loi';
delete ts_kh where ma_dvi=b_ma_dvi and ngay>=b_ngc;
b_loi:='loi:Loi xoa Table TS_PHU:loi';
delete ts_phu where ma_dvi=b_ma_dvi and ngay>=b_ngc;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PXL_MA_LCTR_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ma loai cong trinh XDCB
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','MX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_1 for select * from xl_ma_lctr where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PXL_MA_CTR_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
    cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100);
Begin
-- Dan - Xem chi tiet ma so cong trinh XL
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from xl_ma_ctr where ma_dvi=b_ma_dvi and ma=b_ma;
open cs2 for select * from xl_ma_ctr_hang where ma_dvi=b_ma_dvi and ma=b_ma order by bt;
end;
/
create or replace procedure PXL_DT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_so_id out varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(100);
Begin
-- Dan - Tra so ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_loi:='loi:Du an, cong trinh chua nhap:loi';
select ten into b_ten from xl_ma_ctr where ma_dvi=b_ma_dvi and ma=b_ma;
select nvl(min(so_id),0) into b_so_id from xldt_1 where ma_dvi=b_ma_dvi and ma=b_ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PXL_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
delete xl_temp_lke; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk='T' then
    insert into xl_temp_lke select distinct so_id,so_ct,tien,'' from xl_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id;
    b_dong:=sql%rowcount;
else
    insert into xl_temp_lke select distinct so_id,so_ct,tien,nsd from xl_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id;
    delete xl_temp_lke where nsd is not null and nsd<>b_nsd;
    select count(*) into b_dong from xl_temp_lke;
end if;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,so_ct,tien, row_number() over (order by so_id) sott from xl_temp_lke order by so_id)
    where sott between b_tu and b_den;
end;
/
CREATE OR REPLACE PROCEDURE PXL_TIM_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_d number,b_ngay_c number,b_treo varchar2,b_dc varchar2,b_l_ct varchar2,
    b_ma_ctr varchar2,b_nd nvarchar2,b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_n1 number; b_n2 number;b_tu number:=b_tu_n; b_den number:=b_den_n; 
begin
-- Dan - Tim kiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
delete temp_1; commit;
insert into temp_1(n1) select distinct so_id from xl_1 where ma_dvi=b_ma_dvi and htoan in('T',b_treo) and
 (b_l_ct is null or l_ct=b_l_ct) and (ngay_ht between b_ngay_d and b_ngay_c) and (b_nd is null or upper(nd) like b_nd); 
if b_dc='C' then
    delete temp_1 where exists(select * from kt_1 where ma_dvi=b_ma_dvi and so_id=n1 and instr(lk,'XL:0')=0 and instr(lk,'XL:1')=0);
end if;
if b_ma_ctr is not null then
    delete temp_1 where not exists(select * from xl_2 where ma_dvi=b_ma_dvi and so_id=n1 and ma_ctr like b_ma_ctr);
end if;
update temp_1 set (c1,c2,c3,c4)=(select distinct l_ct,so_ct,nd,pkh_so_cng(ngay_ht) ngay_htc from xl_1 where so_id=temp_1.n1);
select count(*) into b_dong from temp_1;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id, l_ct, so_ct, nd, pkh_so_cng(ngay_ht) ngay_htc,
    row_number() over (order by ngay_ht,so_ct,so_id) sott from xl_1,temp_1
    where ma_dvi=b_ma_dvi and so_id=n1 order by ngay_ht,so_ct,so_id) where sott between b_tu and b_den;
end;
/
create or replace procedure PXL_MA_VI_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ma muc chi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','MX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select * from xl_ma_vi where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PXL_LKE_HANG
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
Begin
-- Dan - Liet ke hang muc
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','X');
if b_loi is not null then raise_application_error(-20105,b_loi);end if;
open cs_lke for select * from xl_ma_ctr_hang where ma_dvi=b_ma_dvi and ma=b_ma order by bt;
end;
/
create or replace procedure PXL_HT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ngay date,b_ma varchar2,b_hang varchar2,b_muc varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number:=0; b_c10 varchar2(10); b_ngay_c date; b_idvung number;
Begin
-- Dan - Nhap xoa danh gia muc do hoan thanh
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','XL','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nv is null or b_nv not in ('N','X') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
PXL_HT_NH_NH(b_idvung,b_ma_dvi,b_nsd,b_nv,b_ngay,b_ma,b_hang,b_muc,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PXL_MA_MC_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem ma muc chi xay lap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','XL','MX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from xl_ma_mc where ma_dvi=b_ma_dvi order by ma;
end;
/
create or replace procedure PXL_HT_NH_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_nv varchar2,b_ngay date,b_ma varchar2,b_hang varchar2,b_muc varchar2,b_loi out varchar2)
AS
    b_i1 number; b_i2 number:=0; b_c10 varchar2(10); b_ngay_c date; b_muc_m varchar2(1):='D';
Begin
-- Dan - Nhap xoa danh gia muc do hoan thanh
if b_ma is null then b_loi:='loi:Nhap ma cong trinh:loi'; return; end if;
if b_hang is null then b_loi:='loi:Nhap sai hang cong trinh '||b_ma||':loi'; return; end if;
if b_muc is null or b_muc not in('D','H','Q','T') then b_loi:='loi:Sai muc do hoan thanh cong trinh '||b_ma||':loi'; return; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select 0 into b_i1 from xl_ma_ctr where ma_dvi=b_ma_dvi and ma=b_ma for update nowait;
if sql%rowcount<>1 then return;end if;
if b_nv='N' then
    if trim(b_hang) is not null then
        b_loi:='loi:Ma hang muc#'||to_char(b_hang)||'#chua dang ky:loi';
        select 0 into b_i1 from xl_ma_ctr_hang where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang;
    end if;
    if b_muc='Q' then
        b_loi:='loi:Hang muc chua hoan thanh:loi';
        select 0 into b_i1 from xlht_1 where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang and muc='H';

    elsif b_muc='T' then
        b_loi:='loi:Hang muc chua duyet quyet toan:loi';
        select 0 into b_i1 from xlht_1 where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang and muc='Q';
    end if;
else
    if b_muc='D' then b_loi:=''; return;
    elsif b_muc='Q' then
        select count(*) into b_i1 from xlht_1 where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang and muc='T';
        if b_i1<>0 then b_loi:='loi:Hang muc da tat toan:loi'; return; end if;
    elsif b_muc='H' then
        select count(*) into b_i1 from xlht_1 where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang and muc='Q';
        if b_i1<>0 then b_loi:='loi:Hang muc da duyet quyet toan:loi'; return; end if;
    end if;
end if;
select count(*) into b_i1 from xlht_1 where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang and muc=b_muc;
if b_i1>0 then
    delete xlht_1 where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang and muc=b_muc;
    if b_nv='X' then
        if b_muc='T' then b_muc_m:='Q';
        elsif b_muc='Q' then b_muc_m:='H';
        end if;
    end if;
end if;
if b_nv='N' then
    insert into xlht_1 values (b_ma_dvi,b_ma,b_hang,b_muc,b_ngay,b_nsd,b_idvung);
    b_muc_m:=b_muc;
end if;
update xl_ma_ctr_hang set muc=b_muc_m where ma_dvi=b_ma_dvi and ma=b_ma and hang=b_hang;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTBH_MU_MA_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','TA','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select * from tbh_mu_ma where ma_dvi=b_ma_dvi order by ma;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace package PKG_KHOACH_MA is
---- CHUNG
function Fs_MA_NV_TEN(b_nv varchar2) return nvarchar2;
function Fs_MA_LHNV_TEN(b_ma_lhnv varchar2) return nvarchar2;
function Fs_MA_TEN(b_bang varchar2,b_dvi varchar2,b_ma varchar2) return nvarchar2;
procedure PMA_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_bang varchar2,b_dvi varchar2,b_ma varchar2,b_ten out nvarchar2);
procedure PKHOACH_CHUNG_MA_LHNV_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type, b_nv varchar2); 
function Fs_MA_CP_TEN(b_ma_dvi varchar2,b_loai_cp varchar2,b_ma varchar2) return nvarchar2;    
---- Het CHUNG

---- MA_CTTT
procedure PKHOACH_MA_CTTT_LKE_ALL
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTTT_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
  b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTTT_CT
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTTT_MA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
  b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTTT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_loai varchar2);
procedure PKHOACH_MA_CTTT_XOA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2);
---- Het MA_CTTT      

---- MA_CTBD
procedure PKHOACH_MA_CTBD_LKE_ALL
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTBD_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
  b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTBD_CT
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTBD_MA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
  b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_CTBD_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_loai varchar2);
procedure PKHOACH_MA_CTBD_XOA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2);
---- Het MA_CTBD      

---- Ma loai kenh
procedure PKHOACH_MA_LOAI_KENH_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_LOAI_KENH_NH
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2);
procedure PKHOACH_MA_LOAI_KENH_XOA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2);
---- Het Ma loai kenh


---- Ma nhom khach hang
procedure PKHOACH_MA_NHOM_KH_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_NHOM_KH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_ma out pht_type.cs_type, cs_ma_ct out pht_type.cs_type);    
procedure PKHOACH_MA_NHOM_KH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_ma varchar2,b_ten nvarchar2,b_loai varchar2,
    a_ma_kh pht_type.a_var, a_ten_kh pht_type.a_nvar);
procedure PKHOACH_MA_NHOM_KH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_ma varchar2);
    
---- Het Ma nhom khach hang
---- Ma nhom kenh
procedure PKHOACH_MA_NHOM_KENH_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_NHOM_KENH_LKE_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_NHOM_KENH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_ma out pht_type.cs_type, cs_ma_ct out pht_type.cs_type);    
procedure PKHOACH_MA_NHOM_KENH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_ma varchar2,b_ten nvarchar2,b_loai varchar2,
    a_ma_kenh pht_type.a_var, a_ten_kenh pht_type.a_nvar);
procedure PKHOACH_MA_NHOM_KENH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2, b_ma varchar2);
---- Het Ma nhom kenh

---- Ma nhom san pham nghiep vu
procedure PKHOACH_MA_NHOM_SP_LKE
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_NHOM_SP_CT
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type);
procedure PKHOACH_MA_NHOM_SP_NH
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,
  b_nv varchar2,b_lhnv varchar2,b_ma_ct varchar2,b_stbh_tu number,b_stbh_den number);
procedure PKHOACH_MA_NHOM_SP_XOA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2);  
  
end PKG_KHOACH_MA;
/
create or replace procedure PKT_MA_TKE_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,b_ma varchar2,b_tim nvarchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nhom is null then b_loi:='loi:Nhap nhom:loi'; raise PROGRAM_ERROR; end if;
if b_tim is null then
    select count(*) into b_dong from kt_ma_tke where ma_dvi=b_ma_dvi;
    select nvl(min(sott),b_dong) into b_tu from (select nhom,ma,row_number() over (order by nhom,ma) sott
        from kt_ma_tke where ma_dvi=b_ma_dvi order by nhom,ma) where nhom>b_nhom or (nhom=b_nhom and ma>=b_ma);
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select a.*,row_number() over (order by nhom,ma) sott from kt_ma_tke a
        where ma_dvi=b_ma_dvi order by nhom,ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kt_ma_tke where ma_dvi=b_ma_dvi and upper(ten) like b_tim;
    select nvl(min(sott),b_dong) into b_tu from (select nhom,ma,row_number() over (order by nhom,ma) sott
        from kt_ma_tke where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by nhom,ma) where nhom>b_nhom or (nhom=b_nhom and ma>=b_ma);
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select a.*,row_number() over (order by nhom,ma) sott from kt_ma_tke a
        where ma_dvi=b_ma_dvi and upper(ten) like b_tim order by nhom,ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_TKE_NHOM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Xem nhom ma thong ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_lke for select * from kt_ma_tke where ma_dvi=b_ma_dvi and nhom=b_nhom and tc='C' order by ma;
end;
/
create or replace procedure PKT_MA_LC_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_trangkt number,
    b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Tim ma
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
insert into temp_1(c1,c2,c3,c4,c5) select ma,nvl(ma_ql,' '),ten,nsd,tc from kt_ma_lc where ma_dvi=b_ma_dvi order by ma;
b_dong:=sql%rowcount;
insert into temp_2(c1,c2,c3,c4,c5,c10,n1) select c1,c2,c3,c4,c5,rpad(lpad('-',2*(level-1),'-')||c1,20),rownum
    from temp_1 start with c2=' ' CONNECT BY prior c1=c2;
select nvl(min(sott),0) into b_tu from (select c1,row_number() over (order by n1) sott from temp_2 order by n1) where c1=b_ma;
if b_tu=0 then
    select nvl(min(sott),b_dong) into b_tu from (select c1,row_number() over (order by n1) sott from temp_2 order by n1) where c1>b_ma;
end if;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select c10 xep,c1 ma,c2 ma_ql,c3 ten,c4 nsd,c5 tc
    from (select c1,c2,c3,c4,c5,c10,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_LC_TC
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
begin
-- Dan - Liet ke ma luu chuyen chi tiet
open cs1 for select ma,ten from kt_ma_lc where ma_dvi=b_ma_dvi and tc<>'G' order by ma;
end;
/
create or replace procedure PKT_BP_NHOM_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_tc varchar2,a_nv pht_type.a_var,a_loai pht_type.a_var)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if b_tc is null or b_tc not in ('C','K') then b_loi:='loi:Luu so cai: C,K:loi'; raise PROGRAM_ERROR; end if;
delete kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=b_ma;
delete kt_bp_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kt_bp_nhom values(b_ma_dvi,b_ma,b_ten,b_tc,b_nsd,b_idvung);
for b_lp in 1..a_nv.count loop
    if trim(a_nv(b_lp)) is not null and a_loai(b_lp) is not null and a_loai(b_lp) in('C','B') then
        insert into kt_bp_nhom_nv values(b_ma_dvi,b_ma,a_nv(b_lp),a_loai(b_lp),b_idvung);
    end if;
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_DN_HTKC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ngay_ht number,b_l_ct varchar2,b_nd nvarchar2,
    a_loai pht_type.a_var,a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_ma_tkdu pht_type.a_var,
    a_ma_tkedu pht_type.a_var,a_ma_tkht pht_type.a_var,a_ma_tkeht pht_type.a_var,a_pb in out  pht_type.a_var)
AS
    b_loi varchar2(100);
begin
-- Dan - Nhap
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NQ');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_ht is null then b_loi:='loi:Nhap ngay dinh nghia:loi'; raise PROGRAM_ERROR;end if;
delete kt_htkc_1 where ma_dvi=b_ma_dvi and ma=b_ma and b_ngay_ht=b_ngay_ht;
delete kt_htkc where ma_dvi=b_ma_dvi and ma=b_ma and b_ngay_ht=b_ngay_ht;
insert into kt_htkc values (b_ma_dvi,b_ngay_ht,b_ma,b_l_ct,b_nd);
for b_lp in 1..a_loai.count loop
    if a_pb(b_lp) is null or a_pb(b_lp)<>'K' then a_pb(b_lp):='C'; end if;
    insert into kt_htkc_1 values(b_ma_dvi,b_ngay_ht,b_ma,b_lp,a_loai(b_lp),a_ma_tk(b_lp),
        a_ma_tke(b_lp),a_ma_tkdu(b_lp),a_ma_tkedu(b_lp),a_ma_tkht(b_lp),a_ma_tkeht(b_lp),a_pb(b_lp));
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;end;
/
create or replace procedure PKT_CT_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,
    b_ma varchar2,b_ma2 varchar2,b_ten out nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_c1 varchar2(1);
begin
-- Dan - Hoi ten cac ma khi nhap chung tu hach toan
if b_nv='L_CT' then
    b_loi:='loai chung tu';
    b_i1:=to_number(b_ma2);
    select min(ten) into b_ten from kh_ma_lct where ma_dvi=b_ma_dvi and md='KT' and ma=b_ma and ngay<=b_i1;
    if b_ten is null then raise PROGRAM_ERROR; end if;
elsif b_nv='MA_TK' then
    b_loi:='tai khoan';
    select ten into b_ten from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='MA_TKE' then
    b_loi:='thong ke';
    select ten into b_ten from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=b_ma and ma_tke=b_ma2;
elsif b_nv='MA_LC' then
    b_loi:='luu chuyen tien te';
    select ten,tc into b_ten,b_c1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma;
    if b_c1='G' then b_loi:='loi:Sai tinh chat ma luu chuyen tien te:loi'; raise PROGRAM_ERROR; end if;
elsif b_nv='MA_SP' then
    b_loi:='san pham';
    select ten into b_ten from vt_ma_vt where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
exception when others then raise_application_error(-20105,'loi:Ma#'||b_loi||'#chua dang ky:loi');
end;
/
create or replace procedure PSX_MA_SP_KB
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_hang out number)
AS
    b_loi varchar2(100);
begin
-- Dan - Khai bao
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select count(*) into b_hang from sx_ma_sp where ma_dvi=b_ma_dvi;
end;
/
create or replace procedure PKH_MA_TTU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_ma_ct varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma khu vuc
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','MA','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma quan ly:loi';
if b_ma_ct=b_ma then raise PROGRAM_ERROR;
elsif trim(b_ma_ct) is not null then
    select 0 into b_i1 from kh_ma_ttu where ma_dvi=b_ma_dvi and ma=b_ma_ct;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_ttu where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kh_ma_ttu values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_KVUC_NH
    (b_ma_dviN varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_ma_ct varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
    b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Nhap ma khu vuc
PHT_MA_NSD_KTRA_VU(b_ma_dviN,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null or trim(b_ten) is null then
    b_loi:='loi:Nhap ma, ten khu vuc:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_ct=b_ma then b_loi:='loi:Sai ma quan ly:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_ct) is not null then
    b_loi:='loi:Ma cap tren chua dang ky:loi';
    select 0 into b_i1 from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma_ct;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kh_ma_kvuc values(b_ma_dvi,b_ma,b_ten,b_ma_ct,b_nsd,b_idvung);
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_GOP_XLY_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_row_id varchar2,b_xly nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kh_gop where rowidtochar(rowid) = b_row_id;
if b_i1=0 then b_loi:='loi:Khong tim thay gop y:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi nhap xu ly gop y kh_gop:loi';
update kh_gop set xly=b_xly,nsd_xly=b_nsd,ngay_qd=sysdate where rowidtochar(rowid) = b_row_id;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_l_ct varchar2,b_so_tt number,b_so_id out number)
AS
    b_loi varchar2(100); b_d1 number; b_d2 number;
begin
-- Dan - Hoi so ID cua 1 chung tu hach toan qua L_CT,SO_TT
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_d1:=round(b_ngay_ht,-2); b_d2:=b_d1+100;
if FKH_NV_TSO(b_ma_dvi,'KT','KT','so_ct','C')='C' then
    select nvl(max(so_id),0) into b_so_id from kt_1 where ma_dvi=b_ma_dvi and
        (ngay_ht between b_d1 and b_d2) and nvl(l_ct,' ')=nvl(b_l_ct,' ') and so_tt=b_so_tt;
else
    select nvl(max(so_id),0) into b_so_id from kt_1 where ma_dvi=b_ma_dvi and (ngay_ht between b_d1 and b_d2) and so_tt=b_so_tt;
end if;
end;
/
create or replace procedure PKT_MA_TKE_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,b_ma varchar2)
AS
    b_loi varchar2(250);b_i1 number;
begin
-- Dan - Nhap ma thong ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_nhom) is null then b_loi:='loi:Nhap nhom thong ke:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma thong ke:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table MA_TKE:loi';
delete kt_ma_tke where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_LC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma varchar2,b_ten nvarchar2,b_tc varchar2,b_ma_ql varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma luu chuyen te
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null or b_ma_ql is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_tc not in ('C','T','D','L','X','G') then b_loi:='loi:Sai tinh chat:loi'; raise PROGRAM_ERROR; end if;
if b_ma_ql<>' ' then
    if b_ma=b_ma_ql then b_loi:='loi:Ma trung ma tong:loi'; raise PROGRAM_ERROR; end if;
    b_loi:='loi:Ma tong chua dang ky:loi';
    select 0 into b_i1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma_ql;
end if;
b_loi:='loi:Loi Table KT_MA_LC:loi';
delete kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma;
insert into kt_ma_lc values (b_ma_dvi,b_ma,b_ten,b_tc,b_ma_ql,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_LC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Xoa ma luu chuyen te
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma_ql=b_ma;
if b_i1<>0 then b_loi:='loi:Khong xoa ma tong co ma chi tiet:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table KT_MA_LC:loi';
delete kt_ma_lc where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_MA_TKLC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma_tk varchar2,a_ma_lc pht_type.a_var)
AS
    b_loi varchar2(100); b_tc varchar2(1); b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma_tk) is null then b_loi:='loi:Nhap ma tai khoan:loi'; raise PROGRAM_ERROR; end if;
if a_ma_lc.count=0 then b_loi:='loi:Nhap ma luu chuyen:loi'; raise PROGRAM_ERROR; end if;
for b_lp in 1..a_ma_lc.count loop
    b_loi:='loi:Sai ma luu chuyen dong#'||to_char(b_lp)||':loi';
    if a_ma_lc(b_lp) is null then raise PROGRAM_ERROR; end if;
    select tc into b_tc from kt_ma_lc where ma_dvi=b_ma_dvi and ma=a_ma_lc(b_lp);
    if b_tc is null or b_tc='G' then raise PROGRAM_ERROR; end if;
end loop;
b_loi:='loi:Loi Table MA_TKLC:loi';
delete kt_ma_tklc where ma_dvi=b_ma_dvi and ma_tk=b_ma_tk;
for b_lp in 1..a_ma_lc.count loop
    insert into kt_ma_tklc values (b_ma_dvi,b_ma_tk,a_ma_lc(b_lp),b_nsd,b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_BP_NHOM_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete kt_bp_nhom_nv where ma_dvi=b_ma_dvi and ma=b_ma;
delete kt_bp_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_DN_HTKC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ngay_ht number)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NQ');
if b_loi is not null then raise PROGRAM_ERROR;end if;
delete kt_htkc_1 where ma_dvi=b_ma_dvi and ma=b_ma and b_ngay_ht=b_ngay_ht;
delete kt_htkc where ma_dvi=b_ma_dvi and ma=b_ma and b_ngay_ht=b_ngay_ht;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_DN_HTKC_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ngay_ht number,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise PROGRAM_ERROR;end if;
open cs1 for select * from kt_htkc where ma_dvi=b_ma_dvi and ma=b_ma and ngay_ht=b_ngay_ht;
open cs2 for select * from kt_htkc_1 where ma_dvi=b_ma_dvi and ma=b_ma and ngay_ht=b_ngay_ht order by bt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_PB_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_ma_tk varchar2,b_ma_tke varchar2,b_nhom varchar2,b_kieu varchar2,b_nv varchar2,
    a_ma_tk in out pht_type.a_var,a_ma_tke pht_type.a_var,a_tk_pt pht_type.a_num,
    a_phong in out pht_type.a_var,a_sp pht_type.a_var,a_sp_pt pht_type.a_num)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_idvung number; b_so_id number;
begin
-- Dan - Nhap phan bo
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay ap dung:loi'; raise PROGRAM_ERROR; end if;
if b_ma_tk is null or b_ma_tke is null then
    b_loi:='loi:Nhap sai phan bo tai khoan:loi'; raise PROGRAM_ERROR;
end if;
if b_nhom is null or b_nhom not in ('T','G','K') then
    b_loi:='loi:Sai nhom:loi'; raise PROGRAM_ERROR;
end if;
if b_kieu is null or b_kieu not in ('C','N','H','S','T','D') then
    b_loi:='loi:Sai kieu phan bo:loi'; raise PROGRAM_ERROR;
end if;
if b_nv is null or b_nv not in ('N','C') then
    b_loi:='loi:Sai nghiep vu:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Sai ma tai khoan:loi';
if b_ma_tk is null then raise PROGRAM_ERROR; end if;
select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
b_loi:='loi:Sai ma thong ke:loi';
if b_ma_tke is null then raise PROGRAM_ERROR; end if;
if b_ma_tke<>' ' then
    select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=b_ma_tk and ma_tke=b_ma_tke;
end if;
PKH_MANG(a_ma_tk); b_i2:=0;
for b_lp in 1..a_ma_tk.count loop
    b_loi:='loi:Nhap sai phan bo theo tai khoan dong# '||to_char(b_lp)||':loi';
    if a_ma_tk(b_lp) is null or a_ma_tke(b_lp) is null or (b_ma_tk=a_ma_tk(b_lp) and b_ma_tke=a_ma_tke(b_lp))
         or a_tk_pt(b_lp) is null or a_tk_pt(b_lp)<0 then raise PROGRAM_ERROR;
    end if;
    select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_ma_tk(b_lp);
    if a_ma_tke(b_lp)<>' ' then
        select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=a_ma_tk(b_lp) and ma_tke=a_ma_tke(b_lp);
    end if;
    b_i2:=b_i2+a_tk_pt(b_lp);
end loop;
if b_i2 not in(0,100) then b_loi:='loi:Tong ty le phan bo bo phan <> 100:loi'; raise PROGRAM_ERROR; end if;
PKH_MANG(a_phong); b_i2:=0;
for b_lp in 1..a_phong.count loop
    if a_phong(b_lp) is null or a_sp(b_lp) is null or a_sp_pt(b_lp) is null or a_sp_pt(b_lp)<=0
        or (trim(a_phong(b_lp)) is null and trim(a_sp(b_lp)) is null) then
        b_loi:='loi:Nhap sai phan bo san pham dong# '||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    if trim(a_phong(b_lp)) is not null then
        b_loi:='loi:Ma bo phan#'||a_phong(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
    end if;
    if trim(a_sp(b_lp)) is not null then
        b_loi:='loi:Ma san pham#'||a_sp(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from sx_ma_sp where ma_dvi=b_ma_dvi and ma=a_sp(b_lp);
    end if;
    b_i2:=b_i2+a_sp_pt(b_lp);
end loop;
if b_i2 not in(0,100) then b_loi:='loi:Tong ty le phan bo bo phan <> 100:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table kt_pb:loi';
delete kt_pb where ma_dvi=b_ma_dvi and ngay=b_ngay and ma_tk=b_ma_tk and ma_tke=b_ma_tke;
for b_lp in 1..a_ma_tk.count loop
    insert into kt_pb values(b_ma_dvi,b_ngay,b_ma_tk,b_ma_tke,b_nhom,b_kieu,b_nv,a_ma_tk(b_lp),a_ma_tke(b_lp),a_tk_pt(b_lp),b_nsd,b_lp,b_idvung);
end loop;
for b_lp in 1..a_phong.count loop
    insert into kt_pb values(b_ma_dvi,b_ngay,b_ma_tk,b_ma_tke,b_nhom,b_kieu,b_nv,a_phong(b_lp),a_sp(b_lp),a_sp_pt(b_lp),b_nsd,10000+b_lp,b_idvung);
end loop;
if a_ma_tk.count=0 and a_phong.count=0 then
    insert into kt_pb values(b_ma_dvi,b_ngay,b_ma_tk,b_ma_tke,b_nhom,b_kieu,b_nv,' ',' ',0,b_nsd,0,b_idvung);
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
 
/
create or replace procedure PKT_MA_NAMTC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','Q');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table KT_NAMTC:loi';
delete kt_namtc where ma_dvi=b_ma_dvi and ngay=b_ngay;
insert into kt_namtc values(b_ma_dvi,b_ngay,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKT_DAU_KY_XEM
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ngay_ht number;
begin
-- Dan - Xem so du dau ky tai khoan
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select nvl(min(ngay_ht),0) into b_ngay_ht from kt_sc where ma_dvi=b_ma_dvi;
open cs_lke for select ma_tk,ma_tke,no_ps,co_ps,no_ck,co_ck,ngay_ht
    from kt_sc where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by ma_tk,ma_tke;
end;
/
create or replace procedure PTT_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_lk out varchar2)
AS
    b_loi varchar2(100); b_md varchar2(2);
begin
-- Dan - Xoa chung tu tien te
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select md into b_md from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
PTT_TT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_CT_NV_XOA(b_ma_dvi,b_nsd,b_so_id,b_md,'TT',b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_HDONG_TT_KT(b_ma_dvi,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TGTT_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ngay date,b_ty_gia number)
AS
	b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ty gia thuc te
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null or b_ma=FTT_TRA_NOITE(b_ma_dvi) then b_loi:='loi:Sai ma ngoai te:loi'; raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma ngoai te chua dang ky:loi';
select 0 into b_i1 from tt_ma_nt where ma_dvi=b_ma_dvi and ma=b_ma;
if b_ty_gia<=0 then b_loi:='loi:Sai ty gia phai:loi'; raise PROGRAM_ERROR;end if;
b_loi:='loi:Va cham NSD:loi';
delete tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma and ngay=b_ngay;
insert into tt_tgtt values (b_ma_dvi,b_ma,b_ngay,b_ty_gia,b_nsd,b_idvung);
/*
--Nhap ty gia cho toan bo cong ty
delete tt_tgtt where ma=b_ma and ngay=b_ngay;
for b_lp in (select distinct ma_dvi from kt_sc) loop
  insert into tt_tgtt values (b_lp.ma_dvi,b_ma,b_ngay,b_ty_gia,b_nsd);
end loop;
*/
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TGTT_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ngay date)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa ty gia thuc te
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null or b_ma=FTT_TRA_NOITE(b_ma_dvi) then b_loi:='loi:Sai ma ngoai te:loi'; raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Va cham NSD:loi';
delete tt_tgtt where ma_dvi=b_ma_dvi and ma=b_ma and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_MA_QUI_NH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_ma varchar2,b_ten nvarchar2,b_ma_tk varchar2,b_thu_qui nvarchar2)
AS
	b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap ma quy
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null or trim(b_ma)='' then
	b_loi:='loi:Nhap ma qui:loi'; raise PROGRAM_ERROR;
end if;
if b_ma_tk is not null then
	b_loi:='loi:Ma tai khoan chua dang ky:loi';
	select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete tt_ma_qui where ma_dvi=b_ma_dvi and ma=b_ma;
insert into tt_ma_qui values (b_ma_dvi,b_ma,b_ten,b_ma_tk,b_thu_qui,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TK_CT
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,cs1 out pht_type.cs_type)
AS
	b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select * from tt_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTT_TK_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table kh_ma_lct:loi';
delete kh_ma_lct_tk where ma_dvi=b_ma_dvi and md in('TT','SE') and ngay=b_ngay;
delete kh_ma_lct where ma_dvi=b_ma_dvi and md in('TT','SE') and ngay=b_ngay;
b_loi:='loi:Loi Table tt_tk:loi';
delete tt_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_CT_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    b_ngay_ht number,b_l_cn varchar2,b_l_ct varchar2,b_ma_cn varchar2,b_ma_nt varchar2,
    b_viec varchar2,b_hdong varchar2,b_ma_ctr varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_xl varchar2(2); b_ma_tk varchar2(20);
begin
-- Dan - Hoi cong no ton
delete cn_ton_temp; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_tk:=FCN_TK_TK(b_ma_dvi,b_ngay_ht,b_l_cn); b_xl:=b_l_ct||FCN_TK_LOAI(b_ma_dvi,b_ngay_ht,b_l_cn);
FCN_CT_TON(b_ma_dvi,b_so_id,b_ngay_ht,b_xl,b_ma_cn,b_ma_nt,b_ma_tk,b_viec,b_hdong,b_ma_ctr,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs_lke for select a.*,tien ton,tien_qd ton_qd from cn_ton_temp a order by ngay_ht,so_id_ps;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_MA_KH_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_klk varchar2,
    b_ma varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number; b_nhom varchar2(1):='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_klk<>'T' then
    select min(nhom) into b_nhom from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
if b_nhom is null then b_nhom:='T'; end if;
select count(*) into b_dong from cn_ma_kh where ma_dvi=b_ma_dvi and b_nhom in (nhom,'T');
select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from cn_ma_kh
    where ma_dvi=b_ma_dvi and b_nhom in (nhom,'T') order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_kh
    where ma_dvi=b_ma_dvi and b_nhom in (nhom,'T') order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_MA_DL_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from cn_ma_dl where ma_dvi=b_ma_dvi;
select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from cn_ma_dl
    where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from cn_ma_dl
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCD_CT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CD','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    select count(*) into b_dong from cd_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by so_id) sott
        from cd_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by so_id) where sott between b_tu and b_den;
else
    select count(*) into b_dong from cd_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd);
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by so_id) sott
        from cd_ch where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and (nsd is null or nsd=b_nsd) order by so_id) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PVT_CT_LKE_LCT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke loai chung tu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','MNX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs1 for select ma,min(ten) ten from kh_ma_lct where ma_dvi=b_ma_dvi and md='VT' group by ma
    order by decode(ma,'N',0,'E','1','X',2,'S',3,'D',6,'U',9,'G',12,'L',15,'B',18,'C',21,'I',24,'V',27,'R',30,33);
end;
/
create or replace procedure PVT_MA_NHOM_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100); b_i1 number;
begin
-- Dan - Nhap ma nhom
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma nhom:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from vt_sc where ma_dvi=b_ma_dvi and nhom=b_ma;
if b_i1<>0 then b_loi:='loi:Ma dang su dung:loi'; raise PROGRAM_ERROR; end if;
delete vt_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_CL_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Nhap ma chat luong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma chat luong:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete vt_ma_cl where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_DVT_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Ma dang su dung:loi';
delete vt_ma_dvt where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_VT_MA
  (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nhom varchar2,b_ma varchar2,
  b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
  b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem ma vat tu
delete temp_1; delete temp_2; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nhom is null then b_loi:='loi:Nhap nhom:loi'; raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
insert into temp_1(c1,c2,c3,n2) select ma,nvl(ma_ct,' '),ten,so_id from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom order by ma;
b_dong:=sql%rowcount;
insert into temp_2(c1,c2,c3,n2,c10,n1) select c1,c2,c3,n2,rpad(lpad('-',2*(level-1),'-')||c1,20) xep,rownum
  from temp_1 start with c2=' ' CONNECT BY prior c1=c2;
select nvl(min(sott),0) into b_tu from (select c1,row_number() over (order by n1) sott from temp_2 order by n1) where c1=b_ma;
if b_tu=0 then
	select nvl(min(sott),b_dong) into b_tu from (select c1,row_number() over (order by n1) sott from temp_2 order by n1) where c1>b_ma;
end if;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select c10 xep,c1 ma,c3 ten, n2 so_id
	from (select c10,c1,c3,n2,row_number() over (order by n1) sott from temp_2 order by n1) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_VT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,
    b_nhom varchar2,b_ma varchar2,b_ma_phu varchar2,b_ten nvarchar2,b_dvi nvarchar2,
    b_pp varchar2,b_pb varchar2,b_ma_ts varchar2,b_kieu varchar2,b_han number,b_du_tru number,
    b_d_muc varchar2,b_dai number,b_rong number,b_cao number,b_gia_pp varchar2,b_ma_ct varchar2,
    a_kt in out pht_type.a_num,a_hs pht_type.a_num,a_ct_nhom in out pht_type.a_var,a_ct_ma pht_type.a_var,a_ct_dvt pht_type.a_nvar,a_ct_luong pht_type.a_num,
    a_ql_dvt in out pht_type.a_nvar,a_cd_dvt_c in out pht_type.a_nvar,a_cd_dvt_m pht_type.a_nvar,a_cd_hs pht_type.a_num)
AS
    b_loi varchar2(100); b_i1 number; b_pp_c varchar2(1); b_sc_pp varchar2(1):='D'; b_idvung number;
begin
-- Dan - Nhap ma vat tu
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M'); 
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Nhap sai nhom vat tu:loi';
if b_nhom is null then raise PROGRAM_ERROR;
elsif b_nhom<>' ' then
    select 0 into b_i1 from vt_ma_nhom where ma_dvi=b_ma_dvi and ma=b_nhom;
end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma vat tu:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_phu) is null then b_loi:='loi:Nhap ma phu:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten vat tu:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai don vi tinh:loi';
if b_dvi is null then raise PROGRAM_ERROR;
elsif trim(b_dvi) is not null then
    select 0 into b_i1 from vt_ma_dvt where ma_dvi=b_ma_dvi and ma=b_dvi;
end if;
if b_pp is null or b_pp not in('B','G','N','S','H') then
    b_loi:='loi:Sai Phuong phap tinh gia:loi'; raise PROGRAM_ERROR;
end if;
if b_pb is null or b_pb not in('K','C','T','D','N','G') then
    b_loi:='loi:Sai loai ma:loi'; raise PROGRAM_ERROR;
end if;
if b_pb in('D','N') then
    b_loi:='loi:Sai ma, kieu tai san:loi';
    if b_ma_ts is null or b_kieu is null then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from ts_ma_ts_kh where ma_dvi=b_ma_dvi and ma=b_ma_ts and kieu=b_kieu;
elsif b_pb in('C','T') and (b_kieu is null or b_kieu not in('D','N')) then
    b_loi:='loi:Sai kieu phan bo:loi'; raise PROGRAM_ERROR;
end if;
if b_han is null or b_han<0 then b_loi:='loi:Han su dung cong cu phai >= 0:loi'; raise PROGRAM_ERROR; end if;
if b_du_tru is null or b_du_tru<0 then b_loi:='loi:So du tru phai >= 0:loi'; raise PROGRAM_ERROR; end if;
if b_d_muc is null or b_d_muc not in('C','K') then
    b_loi:='loi:Sai dinh muc:loi'; raise PROGRAM_ERROR;
end if;
if b_gia_pp is null or b_gia_pp not in('D','R','C','S','V,N') then b_loi:='loi:PP tinh gia:D,R,C,S,V,N:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma bac cao:loi';
if b_ma_ct is null or b_ma_ct=b_ma then raise PROGRAM_ERROR;
elsif trim(b_ma_ct) is not null then
    select pb into b_pp_c from vt_ma_vt where ma_dvi=b_ma_dvi and ma=b_ma_ct;
    if  b_pp_c<>'G' then raise PROGRAM_ERROR; end if;
end if;
PKH_MANG_N(a_kt); PKH_MANG(a_ct_nhom); PKH_MANG_U(a_ql_dvt); PKH_MANG_U(a_cd_dvt_c);
b_loi:='loi:Loi he so tinh gia:loi';
for b_lp in 1..a_kt.count loop
    if a_kt(b_lp) is null or a_kt(b_lp)<=0 or a_hs(b_lp) is null or a_hs(b_lp)<=0 then raise PROGRAM_ERROR; end if;
end loop;
b_loi:='loi:Loi thanh phan chi tiet:loi';
for b_lp in 1..a_ct_nhom.count loop
    if a_ct_nhom(b_lp) is null or a_ct_ma(b_lp) is null or a_ct_dvt(b_lp) is null or a_ct_luong(b_lp) is null or a_ct_luong(b_lp)<=0 or
        (a_ct_nhom(b_lp)=b_nhom and a_ct_ma(b_lp)=b_ma) then raise PROGRAM_ERROR; end if;
    select pb into b_pp_c from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=a_ct_nhom(b_lp) and ma=a_ct_ma(b_lp);
    if b_pp_c='G' then b_loi:='loi:Thanh phan chi tiet khong la ma tong:loi'; raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from vt_ma_dvt where ma_dvi=b_ma_dvi and ma=a_ct_dvt(b_lp);
end loop;
b_loi:='loi:Loi nhieu don vi tinh:loi';
if a_ql_dvt.count<>0 then
    if a_ql_dvt.count>2 then b_loi:='loi:Khong qua 2 don vi tinh phu:loi'; raise PROGRAM_ERROR; end if;
    b_sc_pp:=to_char(a_ql_dvt.count);
    for b_lp in 1..a_ql_dvt.count loop
        if a_ql_dvt(b_lp) is null or a_ql_dvt(b_lp)=b_dvi then raise PROGRAM_ERROR; end if;
        select 0 into b_i1 from vt_ma_dvt where ma_dvi=b_ma_dvi and ma=a_ql_dvt(b_lp);
    end loop;
end if;
b_loi:='loi:Loi don vi chuyen doi:loi';
for b_lp in 1..a_cd_dvt_c.count loop
    if a_cd_dvt_c(b_lp) is null or a_cd_dvt_m(b_lp) is null or a_cd_hs(b_lp) is null or a_cd_hs(b_lp)<=0 then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from vt_ma_dvt where ma_dvi=b_ma_dvi and ma=a_cd_dvt_c(b_lp);
    select 0 into b_i1 from vt_ma_dvt where ma_dvi=b_ma_dvi and ma=a_cd_dvt_m(b_lp);
end loop;
select nvl(min(pp),' ') into b_pp_c from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
if b_pp_c not in(' ',b_pp) and (b_pp in('B','T') or b_pp_c in('B','T')) then
    select count(*) into b_i1 from vt_sc where ma_dvi=b_ma_dvi and nhom=b_nhom and ma_vt=b_ma;
    if b_i1<>0 then b_loi:='loi:Ma dang su dung khong thay doi phuong phap tinh:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Ma dang su dung:loi';
delete vt_ma_vt_dvq where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
delete vt_ma_vt_dvc where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
delete vt_ma_vt_ct where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
delete vt_ma_vt_hs where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
delete vt_ma_vt where ma_dvi=b_ma_dvi and nhom=b_nhom and ma=b_ma;
insert into vt_ma_vt values (b_ma_dvi,b_nhom,b_ma,b_ma_phu,b_ten,b_dvi,b_pp,b_pb,
    b_ma_ts,b_kieu,b_han,b_du_tru,b_d_muc,b_dai,b_rong,b_cao,b_gia_pp,b_sc_pp,b_ma_ct,b_nsd,b_idvung,b_so_id);
for b_lp in 1..a_kt.count loop
    insert into vt_ma_vt_hs values(b_ma_dvi,b_nhom,b_ma,a_kt(b_lp),a_hs(b_lp),b_idvung);
end loop;
for b_lp in 1..a_ct_nhom.count loop
    insert into vt_ma_vt_ct values(b_ma_dvi,b_nhom,b_ma,b_lp,a_ct_nhom(b_lp),a_ct_ma(b_lp),a_ct_dvt(b_lp),a_ct_luong(b_lp),b_idvung);
end loop;
for b_lp in 1..a_ql_dvt.count loop
    insert into vt_ma_vt_dvq values(b_ma_dvi,b_nhom,b_ma,b_lp,a_ql_dvt(b_lp),b_idvung);
end loop;
for b_lp in 1..a_cd_dvt_c.count loop
    insert into vt_ma_vt_dvc values(b_ma_dvi,b_nhom,b_ma,b_lp,a_cd_dvt_c(b_lp),a_cd_dvt_m(b_lp),a_cd_hs(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_KHO_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100); b_i1 number;
begin
-- Dan - Xoa ma kho
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma kho:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from vt_ma_kho where ma_dvi=b_ma_dvi and ma_ct=b_ma;
if b_i1<>0 then b_loi:='loi:Xoa ma chi tiet truoc:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from vt_sc where ma_dvi=b_ma_dvi and kho=b_ma;
if b_i1<>0 then b_loi:='loi:Ma kho dang su dung:loi'; raise PROGRAM_ERROR; end if;
delete vt_ma_kho where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PVT_MA_MDSD_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ten nvarchar2,b_ma_tk varchar2,b_ma_tke varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ten) is null then b_loi:='loi:Nhap ten:loi'; raise PROGRAM_ERROR; end if;
if trim(b_ma_tk) is not null then
    b_loi:='loi:Ma tai khoan chua dang ky:loi';
    select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
end if;
if trim(b_ma_tk) is not null and trim(b_ma_tke) is not null then
    b_loi:='loi:Ma thong ke theo tai khoan chua dang ky:loi';
    select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=b_ma_tk and ma_tke=b_ma_tke;
end if;
b_loi:='loi:Loi Table VT_MA_MDSD:loi';
delete vt_ma_mdsd where ma_dvi=b_ma_dvi and ma=b_ma;
insert into vt_ma_mdsd values(b_ma_dvi,b_ma,b_ten,b_ma_tk,b_ma_tke,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_so_id out number)
AS
begin
-- Dan - Hoi so ID cua qua so the
b_so_id:=FCC_SO_ID(b_ma_dvi,b_so_the);
end;
/
create or replace procedure PCC_PTU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san chua co:loi';
select ten,so_id into b_ten,b_so_id from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select a.*,FCC_PTU_SO_ID_THE(b_ma_dvi,so_id_ptu) so_ptu,FCC_PTU_SO_ID_TEN(b_ma_dvi,so_id_ptu) ten
    from cc_ptu_2 a where ma_dvi=b_ma_dvi and so_id_cc=b_so_id order by so_id_ptu,ngay,so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCC_DC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id_dc in out number,
    b_so_the varchar2,b_so_qd varchar2,b_ngay_qd date,b_phong varchar2,b_ma_cb varchar2,
    b_phong_cu varchar2,b_ma_cb_cu varchar2,b_ma_mdsd varchar2,b_luong number,b_tong out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_i3 number; b_i4 number; b_c1 varchar2(1); b_so_id number; b_idvung number;
begin
-- Dan - Nhap dieu chuyen
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','CC','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_the is null then b_loi:='loi:Nhap so the:loi'; raise PROGRAM_ERROR; end if;
if b_ngay_qd is null then b_loi:='loi:Nhap ngay dieu chuyen:loi'; raise PROGRAM_ERROR; end if;
if b_luong is null or b_luong=0 then b_loi:='loi:Nhap luong:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma bo phan:loi';
if b_phong is null then raise PROGRAM_ERROR; end if;
select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
b_loi:='loi:Sai ma can bo su dung:loi';
if b_ma_cb is null then raise PROGRAM_ERROR; end if;
if b_ma_cb<>' ' then
    select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_cb;
end if;
b_loi:='loi:Sai ma bo phan cu:loi';
if b_phong_cu is null then raise PROGRAM_ERROR; end if;
if b_phong_cu<>' ' then
    select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong_cu;
end if;
if b_ma_cb_cu is null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma can bo su dung cu:loi';
if b_ma_cb_cu<>' ' then
    select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_cb_cu;
    if trim(b_phong_cu) is null then b_loi:='loi:Nhap phong cu:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_phong=b_phong_cu and b_ma_cb=b_ma_cb_cu then
    b_loi:='loi:Thay doi noi su dung:loi'; raise PROGRAM_ERROR;
end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select so_id,luong into b_so_id,b_i1 from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the for update nowait;
if sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if b_so_id_dc is null or b_so_id_dc=0 then
    PHT_ID_MOI(b_so_id_dc,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    delete cc_dc where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dc=b_so_id_dc;
end if;
select nvl(sum(luong),0) into b_i2 from cc_dc where ma_dvi=b_ma_dvi and so_id=b_so_id and phong_cu=' ';
if trim(b_phong_cu) is not null then
    select nvl(sum(luong),0) into b_i4 from cc_dc where ma_dvi=b_ma_dvi and so_id=b_so_id and phong=b_phong_cu and ma_cb=b_ma_cb_cu;
    select nvl(sum(luong),0) into b_i3 from cc_dc where ma_dvi=b_ma_dvi and so_id=b_so_id and phong_cu=b_phong_cu and ma_cb_cu=b_ma_cb_cu;
    if b_i4<b_luong+b_i3 then b_loi:='loi:Chuyen qua so luong da cap:loi'; raise PROGRAM_ERROR; end if;
else
    b_i2:=b_i2+b_luong;
    if b_i2>b_i1 then b_loi:='loi:Chuyen qua so luong cua the:loi'; raise PROGRAM_ERROR; end if;
end if;
insert into cc_dc values(b_ma_dvi,b_so_id,b_so_id_dc,b_so_qd,b_ngay_qd,b_phong,b_ma_cb,b_phong_cu,b_ma_cb_cu,b_ma_mdsd,b_luong,b_nsd,b_idvung);
b_tong:=to_char(b_i2)||'/'||to_char(b_i1);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FCC_PTU_SO_ID_TEN(b_ma_dvi varchar2,b_so_id number) return nvarchar2
AS
    b_ten nvarchar2(400);
begin
    select min(ten) into b_ten from cc_ptu_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    return b_ten;
end;
/
create or replace function FCC_PTU_SO_ID_THE(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_the varchar2(20);
begin
    select min(so_ptu) into b_so_the from cc_ptu_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    return b_so_the;
end;
/
create or replace procedure PCC_PTU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_ten out nvarchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_so_id number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CC','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Tai san chua co:loi';
select ten,so_id into b_ten,b_so_id from cc_sc where ma_dvi=b_ma_dvi and so_the=b_so_the;
open cs_lke for select a.*,FCC_PTU_SO_ID_THE(b_ma_dvi,so_id_ptu) so_ptu,FCC_PTU_SO_ID_TEN(b_ma_dvi,so_id_ptu) ten
    from cc_ptu_2 a where ma_dvi=b_ma_dvi and so_id_cc=b_so_id order by so_id_ptu,ngay,so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NSD_DU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_md varchar2,b_nv varchar2,b_ma varchar2)
AS
     b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_md is null or b_nv is null or b_ma is null then b_loi:='loi:Nhap Modul, nghiep vu, ma:loi'; end if;
delete kh_nsd_du where ma_dvi=b_ma_dvi and nsd=b_nsd and md=b_md and nv=b_nv and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PPB_PS_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_htoan varchar2,
    b_ngay_ht number,b_so_id in out number,b_l_ct varchar2,b_so_ct in out varchar2,
    b_tien number,b_ngay_bd date,b_kieu varchar2,b_p_bo number,b_ma_tk varchar2,b_nhom varchar2,
    b_loai varchar2,b_so_hd varchar2,b_phong varchar2,b_nd nvarchar2,b_duoi varchar2,
    a_ngay in out pht_type.a_date,a_doi pht_type.a_num,
    a_pb_ma_tk pht_type.a_var,a_pb_ma_tke pht_type.a_var,a_pt_tk in out pht_type.a_num,
    a_phong pht_type.a_var,a_sp pht_type.a_var,a_pt_sp in out pht_type.a_num,
    a_nv in out pht_type.a_var,a_ma_tk in out pht_type.a_var,a_ma_tke in out pht_type.a_var,a_tien in out pht_type.a_num,
    a_note pht_type.a_nvar,a_bt pht_type.a_num,b_lk out varchar2,b_cbao out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_md varchar2(2); b_doi number;b_idvung number;
begin
-- Dan - Nhap phat sinh phan bo
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','PB','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
PKH_MANG(a_nv); PKH_MANG_D(a_ngay); PKH_MANG_N(a_pt_tk); PKH_MANG_N(a_pt_sp);
if b_so_id=0 then
    b_md:='PB';
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else    b_loi:='loi:Chung tu dang xu ly:loi';
    select md into b_md from pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    PPB_PS_PS_XOA(b_ma_dvi,b_nsd,b_so_id,true,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PPB_PS_TEST(b_ma_dvi,b_md,b_htoan,b_ngay_ht,b_l_ct,b_tien,b_doi,b_ngay_bd,b_kieu,b_p_bo,b_ma_tk,b_nhom,b_loai,b_so_hd,b_phong,b_duoi,
    a_ngay,a_doi,a_pb_ma_tk,a_pb_ma_tke,a_pt_tk,a_phong,a_sp,a_pt_sp,a_nv,a_ma_tk,a_tien,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PPB_PS_PS_NH(b_idvung,b_ma_dvi,b_nsd,b_md,b_htoan,b_ngay_ht,b_so_id,b_l_ct,b_so_ct,b_tien,b_doi,b_ngay_bd,b_kieu,b_p_bo,
    b_ma_tk,b_nhom,b_loai,b_so_hd,b_phong,b_nd,b_duoi,a_ngay,a_doi,a_pb_ma_tk,a_pb_ma_tke,a_pt_tk,a_phong,a_sp,a_pt_sp,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKT_CT_NV_XL(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_so_id,b_l_ct,b_so_ct,'',b_nd,
    a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_md,'PB',b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_htoan='H' then
    b_cbao:=FKT_KH_CBAO(b_ma_dvi,b_ngay_ht,a_ma_tk);
    if instr(b_cbao,'loi:')=1 then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PPB_PS_PS_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS
    b_i1 number; r_pb pb_0%ROWTYPE;
begin
-- Dan - Xoa phat sinh phan bo
select count(*) into b_i1 from pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_pb from pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 then b_loi:='loi:Chung tu dang xu ly:loi'; return; end if;
if r_pb.htoan='H' then
    if r_pb.nsd<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_pb.ngay_ht,'KT','PB');
    if b_loi is not null then return; end if;
    if not b_nh then
        select nvl(max(ngay_ht),0) into b_i1 from pb_2 where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
        if b_i1<>0 then
            b_loi:='loi:Da thuc hien phan bo ngay#'||PKH_SO_CNG(b_i1)||':loi'; return;
        end if;
    end if;
    PKH_NGAY_TD(b_ma_dvi,'KT',r_pb.ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table pb_1:loi';
delete pb_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table pb_pb:loi';
delete pb_pb where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table pb_0:loi';
delete pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PPB_PS_TEST
    (b_ma_dvi varchar2,b_md varchar2,b_htoan varchar2,b_ngay_ht number,
    b_l_ct varchar2,b_tien number,b_doi out number,b_ngay_bd date,b_kieu varchar2,
    b_p_bo number,b_ma_tk varchar2,b_nhom varchar2,b_loai varchar2,b_so_hd varchar2,b_phong varchar2,b_duoi varchar2,
    a_ngay pht_type.a_date,a_doi pht_type.a_num,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_pt_tk pht_type.a_num,
    a_phong pht_type.a_var,a_sp pht_type.a_var,a_pt_sp pht_type.a_num,
    a_nv pht_type.a_var,a_ht_ma_tk pht_type.a_var,a_tien pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_i2 number; b_tt varchar2(1); b_nv varchar2(1); b_tk_ct varchar2(20); a_duoi pht_type.a_var;
begin
-- Dan - Kiem tra so lieu nhap phat sinh phan bo
if b_htoan is null or b_htoan not in ('H','T') then
    b_loi:='loi:Hach toan: H-Hach toan, T-Treo:loi'; return;
end if;
if b_l_ct is null or b_l_ct not in('C','N')  then b_loi:='loi:Loai CT: C-Phat sinh chi tra truoc, N-Phat sinh thu nhan truoc:loi'; return; end if;
if b_ngay_bd is null then b_loi:='loi:Nhap ngay bat dau phan bo:loi'; return; end if;
if b_kieu is null or b_kieu not in('T','Q','N') then
    b_loi:='loi:Kieu phan bo: T-Thang, Q-Qui, N-Nam:loi'; return;
end if;
if b_p_bo is null or b_p_bo<2 then b_loi:='loi:So lan phan bo phai > 1:loi'; return; end if;
if b_nhom is not null then
    b_loi:='loi:Ma nhom phan bo chua dang ky:loi';
    select 0 into b_i1 from pb_ma_nhom where ma_dvi=b_ma_dvi and ma=b_nhom;
end if;
if trim(b_so_hd) is not null then
    if b_loai is null or b_loai not in ('K','H') then b_loi:='loi:Sai loai doi tuong:loi'; return; end if;
    if b_loai='K' then
        b_loi:='loi:Ma khach hang chua dang ky:loi';
        select 0 into b_i1 from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_so_hd;
    else
        b_loi:='loi:So hop dong chua dang ky:loi';
        select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_so_hd;
    end if;
end if;
if b_phong is not null then
    b_loi:='loi:Ma bo phan chua dang ky:loi';
    select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
end if;
if a_ngay.count<>b_doi-1 then b_loi:='loi:Sai so ngay phan bo phan bo:loi'; return; end if;
b_doi:=0;
for b_lp in 1..a_ngay.count loop
    if a_doi(b_lp) is null or a_doi(b_lp)<0 then
        b_loi:='loi:Sai so lieu phan bo ngay#'||to_char(a_ngay(b_lp),'dd/mm/yyyy')||':loi'; return;
    end if;
    b_doi:=b_doi+a_doi(b_lp);
end loop;
b_i2:=0;
for b_lp in 1..a_pt_tk.count loop
    if a_ma_tk(b_lp) is null or a_ma_tke(b_lp) is null or a_pt_tk(b_lp)<0 then
        b_loi:='loi:Nhap sai phan bo tai khoan dong#'||to_char(b_lp)||':loi'; return;
    end if;
    PKH_CH_ARR(a_ma_tk(b_lp),a_duoi);
    for b_lp1 in 1..a_duoi.count loop
        b_loi:='loi:Ma tai khoan#'||a_duoi(b_lp1)||'#chua dang ky:loi';
        select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_duoi(b_lp1);
        if trim(a_ma_tke(b_lp)) is not null then
            b_loi:='loi:Ma thong ke#'||a_ma_tke(b_lp)||'#chua dang ky:loi';
            select 0 into b_i1 from kt_ma_tktke where ma_dvi=b_ma_dvi and ma_tk=a_duoi(b_lp1) and ma_tke=a_ma_tke(b_lp);
        end if;
    end loop;
    b_i2:=b_i2+a_pt_tk(b_lp);
end loop;
if b_i2 not in(0,100) then b_loi:='loi:Nhap sai tong % phan bo tai khoan:loi'; return; end if;
b_i2:=0;
for b_lp in 1..a_pt_sp.count loop
    if a_phong(b_lp) is null or a_sp(b_lp) is null or a_pt_sp(b_lp)<0
        or (trim(a_phong(b_lp)) is null and trim(a_sp(b_lp)) is null) then
        b_loi:='loi:Nhap sai phan bo san pham dong#'||to_char(b_lp)||':loi'; return;
    end if;
    if trim(a_phong(b_lp)) is not null then
        b_loi:='loi:Ma bo phan#'||a_phong(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
    end if;
    if trim(a_sp(b_lp)) is not null then
        b_loi:='loi:Ma san pham#'||a_sp(b_lp)||'#chua dang ky:loi';
        select 0 into b_i1 from sx_ma_sp where ma_dvi=b_ma_dvi and ma=a_sp(b_lp);
    end if;
    b_i2:=b_i2+a_pt_sp(b_lp);
end loop;
if b_i2 not in(0,100) then b_loi:='loi:Nhap sai tong % phan bo san pham:loi'; return; end if;
if b_ma_tk is not null then
    b_loi:='loi:Sai ma tai khoan doanh thu, chi phi tra truoc:loi';
    select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=b_ma_tk;
    if a_nv.count<>0 then
        if b_l_ct='N' then b_nv:='C'; else b_nv:='N'; end if;
        b_i2:=b_doi;
        for b_lp in 1..a_nv.count loop
            if a_nv(b_lp)=b_nv and a_ht_ma_tk(b_lp)=b_ma_tk then b_i2:=b_i2-a_tien(b_lp); end if;
        end loop;
        if b_i2<>0 then b_loi:='loi:Sai tien cho phan bo va hach toan:loi'; return; end if;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PPB_PS_PS_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_htoan varchar2,
    b_ngay_ht number,b_so_id number,b_l_ct varchar2,b_so_ct in out varchar2,b_tien number,
    b_doi number,b_ngay_bd date,b_kieu varchar2,b_p_bo number,b_ma_tk varchar2,b_nhom varchar2,
    b_loai varchar2,b_so_hd varchar2,b_phong varchar2,b_nd nvarchar2,b_duoi varchar2,
    a_ngay pht_type.a_date,a_doi pht_type.a_num,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_pt_tk pht_type.a_num,
    a_phong pht_type.a_var,a_sp pht_type.a_var,a_pt_sp pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; a_tra pht_type.a_num; b_tra number;
begin
-- Dan - Nhap phat sinh phan bo
if trim(b_so_ct) is not null then
    select count(*) into b_i1 from pb_0 where ma_dvi=b_ma_dvi and l_ct=b_l_ct and so_ct=b_so_ct;
    if b_i1<>0 then b_loi:='loi:Trung so chung tu phan bo phat sinh:loi'; return; end if;
else
    b_so_ct:=PPB_SOTT(b_ma_dvi,b_ngay_ht,b_l_ct);
end if;
for b_lp in 1..a_ngay.count loop
    a_tra(b_lp):=0; 
end loop;
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','PB');
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
    select nvl(sum(tien),0) into b_i1 from pb_2 where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
    if b_i1>0 then
        for b_lp in 1..a_ngay.count loop
            if b_i1>a_doi(b_lp) then a_tra(b_lp):=a_doi(b_lp); else a_tra(b_lp):=b_i1; end if;
            b_i1:=b_i1-a_tra(b_lp);
            if b_i1<=b_tra then exit; end if;
        end loop;
        if b_i1>0 then b_loi:='loi:Khong sua tien nho hon so da thuc hien phan bo:loi'; return; end if;
    end if;
end if;
b_loi:='loi:Loi Table pb_0:loi';
insert into pb_0 values(b_ma_dvi,b_so_id,b_ngay_ht,b_l_ct,b_so_ct,b_tien,b_doi,b_ngay_bd,
    b_kieu,b_p_bo,b_ma_tk,b_nhom,b_loai,b_so_hd,b_phong,b_nd,b_duoi,b_nsd,b_htoan,b_md,sysdate,b_idvung);
b_loi:='loi:Loi Table pb_1:loi';
for b_lp in 1..a_ngay.count loop
    insert into pb_1 values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,b_l_ct,a_ngay(b_lp),a_doi(b_lp),a_tra(b_lp),b_idvung);
end loop;
b_loi:='loi:Loi Table PB_PB:loi';
delete pb_pb where ma_dvi=b_ma_dvi and so_id=b_so_id;
for b_lp in 1..a_pt_tk.count loop
    insert into pb_pb values(b_ma_dvi,b_so_id,a_ma_tk(b_lp),a_ma_tke(b_lp),a_pt_tk(b_lp),b_lp,b_idvung);
end loop;
for b_lp in 1..a_pt_sp.count loop
    insert into pb_pb values(b_ma_dvi,b_so_id,a_phong(b_lp),a_sp(b_lp),a_pt_sp(b_lp),b_lp+1000,b_idvung);
end loop;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PPB_PS_PS_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_nh boolean,b_loi out varchar2)
AS
    b_i1 number; r_pb pb_0%ROWTYPE;
begin
-- Dan - Xoa phat sinh phan bo
select count(*) into b_i1 from pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select * into r_pb from pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 then b_loi:='loi:Chung tu dang xu ly:loi'; return; end if;
if r_pb.htoan='H' then
    if r_pb.nsd<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,r_pb.ngay_ht,'KT','PB');
    if b_loi is not null then return; end if;
    if not b_nh then
        select nvl(max(ngay_ht),0) into b_i1 from pb_2 where ma_dvi=b_ma_dvi and so_id_ps=b_so_id;
        if b_i1<>0 then
            b_loi:='loi:Da thuc hien phan bo ngay#'||PKH_SO_CNG(b_i1)||':loi'; return;
        end if;
    end if;
    PKH_NGAY_TD(b_ma_dvi,'KT',r_pb.ngay_ht,b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table pb_1:loi';
delete pb_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table pb_pb:loi';
delete pb_pb where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table pb_0:loi';
delete pb_0 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function PPB_SOTT
    (b_ma_dvi varchar2,b_ngay_ht number,b_l_ct varchar2) return varchar2
AS
    b_d1 number; b_d2 number; b_i1 number;
begin
-- Dan - Cho so thu tu tiep theo cua CT phan bo
b_d1:=round(b_ngay_ht,-2);b_d2:=b_d1+100;   --Theo thang
select nvl(max(PKH_LOC_CHU_SO(so_ct)),0) into b_i1 from pb_0 where
    ma_dvi=b_ma_dvi and (ngay_ht between b_d1 and b_d2) and l_ct=b_l_ct;
if b_i1<10000 then b_i1:=1; else b_i1:=round(b_i1/10000,0)+1; end if;
return trim(to_char(b_i1))||'/'||substr(to_char(b_ngay_ht),5,2)||'_'||substr(to_char(b_ngay_ht),3,2);
end;
/
create or replace procedure PPB_MA_NHOM_XOA
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
	b_loi varchar2(100);
begin
-- Dan - Nhap nhom ma phan bo
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma nhom:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi Table pb_ma_nhom:loi';
delete pb_ma_nhom where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;

/
create or replace procedure PPB_TH_TON
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,
    b_l_ct varchar2,b_nhom varchar2,b_so_ct_ps varchar2,cs_1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_d1 date;
begin
-- Dan - Tim kiem phai thuc hien phan bo thang
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','PB','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete temp_1; delete temp_2; commit;
if trim(b_so_ct_ps) is null then
    b_d1:=PKH_SO_CDT(b_ngay_ht); b_d1:=last_day(b_d1)+1;
    insert into temp_2(n1,n2,c1) select a.so_id,b.tien-b.tra,a.nhom from pb_0 a,pb_1 b
        where a.ma_dvi=b_ma_dvi and a.l_ct=b_l_ct and a.htoan='H' and a.ngay_ht<=b_ngay_ht
        and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.ngay<b_d1 and b.tien<>b.tra;
    if trim(b_nhom) is not null then
        delete temp_2 where c1 is null or c1<>b_nhom;
    end if;
else
    insert into temp_2(n1,n2,c1) select a.so_id,b.tien-b.tra,a.nhom from pb_0 a,pb_1 b
        where a.ma_dvi=b_ma_dvi and a.l_ct=b_l_ct and a.htoan='H' and
        a.so_ct=b_so_ct_ps and b.ma_dvi=b_ma_dvi and b.so_id=a.so_id and b.tien<>b.tra;
end if;
insert into temp_1(n1,n2) select n1 ,sum(n2) from temp_2 group by n1 having sum(n2)<>0;
update temp_1 set (c1,c2,c3,c4)=(select so_ct,pkh_so_cng(ngay_ht),decode(so_hd,null,'',loai||so_hd) so_hd,nd from pb_0 where ma_dvi=b_ma_dvi and so_id=n1);
open cs_1 for select n1 so_id_ps,c1 so_ct,n2 tien,c2 ngay,c3 so_hd,c4 nd from temp_1 order by c1;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTS_THE_SO_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_the varchar2,b_so_id out varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Cho so the moi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TS','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
b_so_id:=FTS_THE_SO_ID(b_ma_dvi,b_so_the);
end;
/
create or replace function FTS_THE_SO_ID(b_ma_dvi varchar2,b_so_the varchar) return number
AS
    b_so_id number;
begin
select nvl(min(so_id),0) into b_so_id from ts_sc_1 where ma_dvi=b_ma_dvi and so_the=b_so_the;
return b_so_id;
end;
/
create or replace procedure PCN_TK_NV
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ngay number;
begin
-- Dan - Chi tiet
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NXM');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select nvl(max(ngay),0) into b_ngay from cn_tk where ma_dvi=b_ma_dvi;
open cs1 for select ma,ten from cn_tk where ma_dvi=b_ma_dvi and ngay=b_ngay order by bt;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/

create or replace procedure PKH_NSU_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_phong varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number; b_nhom varchar2(1):='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not     null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if b_phong is null then b_loi:='loi:Nhap phong:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_nsu where ma_dvi=b_ma_dvi;
select nvl(min(sott),0) into b_tu from (select ngay,phong,row_number() over (order by ngay,phong) sott from kh_nsu
    where ma_dvi=b_ma_dvi order by ngay,phong) where ngay=b_ngay and phong=b_phong;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select a.*,row_number() over (order by ngay,phong) sott from kh_nsu a
    where ma_dvi=b_ma_dvi order by ngay,phong) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NSU_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke chung tu cong no theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kh_nsu where ma_dvi=b_ma_dvi;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select a.*,row_number() over (order by ngay,phong) sott
    from kh_nsu a where ma_dvi=b_ma_dvi order by ngay,phong) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NSU_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_phong varchar2,b_nsu number,b_tnsu number)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai phong:loi';
if b_phong is null then raise PROGRAM_ERROR;
else select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
end if;
if b_nsu is null or b_tnsu is null then b_loi:='loi:Nhap so nguoi:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Loi table KH_NSU:loi';
delete kh_nsu where ma_dvi=b_ma_dvi and ngay=b_ngay and phong=b_phong;
insert into kh_nsu values(b_ma_dvi,b_ngay,b_phong,b_nsu,b_tnsu,b_nsd,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_NSU_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,b_phong varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'HT','HT','N');
if b_loi is not     null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
if b_phong is null then b_loi:='loi:Nhap phong:loi'; raise PROGRAM_ERROR; end if;
delete kh_nsu where ma_dvi=b_ma_dvi and ngay=b_ngay and phong=b_phong;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_VIEC_ND
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_nd out nvarchar2,b_hdong out varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Tra noi dung va ma hdong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VIC','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma viec:loi';
if b_ma is null then raise PROGRAM_ERROR; end if;
select nd,hdong into b_nd,b_hdong from kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_ma;
if trim(b_hdong) is null then
    b_hdong:=FKH_MA_HDONG_VIEC(b_ma_dvi,b_ma);
    if b_hdong='*' then b_hdong:=''; end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_VIEC_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_klk varchar2,b_ma varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number; b_nhom varchar2(1):='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VIC','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_klk='T' then
    select count(*) into b_dong from kh_ma_viec where ma_dvi=b_ma_dvi;
    select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from kh_ma_viec
        where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma,nd,row_number() over (order by ma) sott from kh_ma_viec
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kh_ma_viec where ma_dvi=b_ma_dvi and ttrang=b_klk;
    select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from kh_ma_viec
        where ma_dvi=b_ma_dvi and ttrang=b_klk order by ma) where ma>=b_ma;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma,nd,row_number() over (order by ma) sott from kh_ma_viec
        where ma_dvi=b_ma_dvi and ttrang=b_klk order by ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_VIEC_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_klk varchar2,b_tim nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VIC','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if b_klk ='T' then
    if b_tim is null then
        select count(*) into b_dong from kh_ma_viec where ma_dvi=b_ma_dvi;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select ma,nd from (select ma,nd,row_number() over (order by ma) sott
            from kh_ma_viec where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from kh_ma_viec where ma_dvi=b_ma_dvi and upper(nd) like b_tim;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select ma,nd from (select ma,nd,row_number() over (order by ma) sott
            from kh_ma_viec where ma_dvi=b_ma_dvi and upper(nd) like b_tim order by ma) where sott between b_tu and b_den;
    end if;
elsif b_tim is null then
    select count(*) into b_dong from kh_ma_viec where ma_dvi=b_ma_dvi and ttrang=b_klk;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select ma,nd from (select ma,nd,row_number() over (order by ma) sott
        from kh_ma_viec where ma_dvi=b_ma_dvi and ttrang=b_klk order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kh_ma_viec where ma_dvi=b_ma_dvi and ttrang=b_klk and upper(nd) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select ma,nd from (select ma,nd,row_number() over (order by ma) sott
        from kh_ma_viec where ma_dvi=b_ma_dvi and ttrang=b_klk and upper(nd) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PKH_MA_VIEC_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_ct out pht_type.cs_type,cs_bp out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VIC','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_ct for select * from kh_ma_viec a where ma_dvi=b_ma_dvi and ma=b_ma;
open cs_bp for select * from kh_ma_viec_bp where ma_dvi=b_ma_dvi and ma=b_ma order by bt;
end;
/
create or replace procedure PKH_MA_VIEC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma in out varchar2,
    b_phong varchar2,b_ma_cb varchar2,b_k_ma_kh varchar2,b_ma_kh varchar2,
    b_nd nvarchar2,b_ngay_bd_n number,b_ngay_kt number,
    b_viecg varchar2,b_hdong varchar2,b_ttrang_n varchar2,b_ldo nvarchar2,
    a_dvi pht_type.a_var,a_phong pht_type.a_var,a_ma_cb pht_type.a_var,a_pt in out pht_type.a_num)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number; b_ngay_bd number; b_ttrang varchar2(1);
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','VIC','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma bo phan quan ly:loi';
if b_phong is null then raise PROGRAM_ERROR;
else select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_phong;
end if;
b_loi:='loi:Sai ma nguoi quan ly:loi';
if b_ma_cb is null then raise PROGRAM_ERROR;
elsif trim(b_ma_cb) is not null then
    select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_cb;
end if;
if trim(b_nd) is null then b_loi:='loi:Nhap noi dung:loi'; raise PROGRAM_ERROR; end if;
if trim(b_k_ma_kh) is null or b_k_ma_kh not in('K','U','N','B','D','C') then b_loi:='loi:Nhap kieu ma khach hang:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma khach hang:loi';
if b_ma_kh is null then raise PROGRAM_ERROR;
elsif trim(b_ma_kh) is not null then
    if b_k_ma_kh in('K','U') then
        select 0 into b_i1 from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='N' then
        select 0 into b_i1 from ht_ma_dvi where idvung=b_idvung and ma_goc=b_ma_kh;
    elsif b_k_ma_kh='B' then
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='D' then
        select 0 into b_i1 from cn_ma_dl where ma_dvi=b_ma_dvi and ma=b_ma_kh;
    elsif b_k_ma_kh='C' then
        select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=b_ma_kh;
end if;
end if;
b_loi:='loi:Sai viec goc:loi';
if b_viecg is null then raise PROGRAM_ERROR;
elsif trim(b_viecg) is not null then
    if b_ma=b_viecg then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_viecg;
end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_hdong is null then raise PROGRAM_ERROR;
elsif trim(b_hdong) is not null then
    select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_hdong;
end if;
if b_ngay_bd_n is null or b_ngay_kt is null or b_ngay_bd_n>b_ngay_kt then
    b_loi:='loi:Sai ngay bat dau hoac ngay ket thuc:loi'; raise PROGRAM_ERROR;
end if;
if b_ngay_bd_n<30000101 then b_ngay_bd:=b_ngay_bd_n; else b_ngay_bd:=PKH_NG_CSO(sysdate); end if;
if b_ngay_kt=30000101 then
    b_ttrang:='D';
else
    if b_ttrang_n is null or b_ttrang_n not in('K','H') then
        b_loi:='loi:Sai trang thai:loi'; raise PROGRAM_ERROR;
    end if;
    b_ttrang:=b_ttrang_n;
end if;
if b_ttrang='H' and trim(b_ldo) is null then
    b_loi:='loi:Nhap ly do huy:loi'; raise PROGRAM_ERROR;
end if;
PKH_MANG_N(a_pt);
for b_lp in 1..a_pt.count loop
    b_loi:='loi:Nhap sai phan bo dong#'||to_char(b_lp)||':loi';
    if a_dvi(b_lp) is null or a_phong(b_lp) is null or a_ma_cb(b_lp) is null or a_pt(b_lp) is null then raise PROGRAM_ERROR; end if;
    if trim(a_dvi(b_lp)) is not null then
        select 0 into b_i1 from ht_ma_dvi where idvung=b_idvung and ma_goc=a_dvi(b_lp);
    end if;
    if trim(a_phong(b_lp)) is not null then
        select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
    end if;
    if trim(a_ma_cb(b_lp)) is not null then
        select 0 into b_i1 from ht_ma_cb where ma_dvi=b_ma_dvi and ma=a_ma_cb(b_lp);
    end if;
end loop;
if trim(b_ma) is null then
    b_ma:=Fkh_ma_viec_HOI_MA(b_ma_dvi,b_ngay_bd);
else
    delete kh_ma_viec_bp where ma_dvi=b_ma_dvi and ma=b_ma;
    delete kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
b_loi:='loi:Va cham nguoi su dung:loi';
insert into kh_ma_viec values (b_ma_dvi,b_ma,b_phong,b_ma_cb,b_k_ma_kh,b_ma_kh,b_nd,b_ngay_bd,b_ngay_kt,b_viecg,b_hdong,b_ttrang,b_ldo,b_nsd,b_idvung);
for b_lp in 1..a_pt.count loop
    insert into kh_ma_viec_bp values(b_ma_dvi,b_ma,b_lp,a_dvi(b_lp),a_phong(b_lp),a_ma_cb(b_lp),a_pt(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_VIEC_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_nsd_c varchar2(10);
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','VIC','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma viec:loi'; raise PROGRAM_ERROR; end if;
select min(nsd),count(*) into b_nsd_c,b_i1 from kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_ma;
if b_i1<>0 then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong xoa ma cua NSD khac:loi'; raise PROGRAM_ERROR; end if;
    delete kh_ma_viec_bp where ma_dvi=b_ma_dvi and ma=b_ma;
    delete kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_ND
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_nd out nvarchar2,b_viec out varchar2,b_ma_sp out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_id_kq number;
begin
-- Dan - Tra noi dung va ma viec
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_ma is null then raise PROGRAM_ERROR; end if;
select nd,viec into b_nd,b_viec from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
if trim(b_viec) is null then
    select min(ma),count(*) into b_viec,b_i1 from kh_ma_viec where ma_dvi=b_ma_dvi and hdong=b_ma;
    if b_i1>1 then b_viec:=''; end if;
end if;
select min(a.ma_dv) into b_ma_sp from kh_ma_hdong_dv a,sx_ma_sp b where
    a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi=b_ma_dvi and b.ma=a.ma_dv and b.nhom='C' order by a.ma_dv;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_NTE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ma_nt out varchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Tra ma nguyen te hop dong
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma_nt:=FKH_MA_HDONG_NTE(b_ma_dvi,b_ma);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_SP(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_hdong varchar2,b_maN varchar2,b_trangKt number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number; b_ma varchar2(100); b_min varchar2(100);
begin
-- Dan - Liet ke
delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_ma:=b_maN||'%';
select count(*),min(ma_dv) into b_i1,b_min from kh_ma_hdong_dv where ma_dvi=b_ma_dvi and ma=b_hdong and ma_dv like b_ma;
if b_i1>b_trangKt or (b_i1=1 and b_min=b_maN) then
    open cs1 for select '' ma,'' ten from temp_1 where rownum=0;
else
    open cs1 for select b.ma,b.ten from kh_ma_hdong_dv a,sx_ma_sp b
        where a.ma_dvi=b_ma_dvi and a.ma=b_hdong and a.ma_dv like b_ma and 
        b.ma_dvi=b_ma_dvi and b.ma=a.ma_dv order by b.ma;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_BP
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_dk varchar2,b_bp out nvarchar2)
AS
    b_loi varchar2(100);
begin
-- Dan - Tra noi dung va ma viec
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_ma is null then raise PROGRAM_ERROR; end if;
b_bp:=FKH_MA_HDONG_BP(b_ma_dvi,b_ma,b_dk);
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_PH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_ph out nvarchar2)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Tra noi dung va ma viec
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_ma is null then raise PROGRAM_ERROR; end if;
select count(*),min(phong) into b_i1,b_ph from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and ma=b_ma;
if b_i1>1 then b_ph:=''; end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_klk varchar2,b_ma varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number; b_nhom varchar2(1):='';
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
if b_klk='T' then
    select count(*) into b_dong from kh_ma_hdong where ma_dvi=b_ma_dvi;
    select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from kh_ma_hdong
        where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma,so_hd,nd,row_number() over (order by ma) sott from kh_ma_hdong
        where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kh_ma_hdong where ma_dvi=b_ma_dvi and ttrang=b_klk;
    select nvl(min(sott),0) into b_tu from (select ma,row_number() over (order by ma) sott from kh_ma_hdong
        where ma_dvi=b_ma_dvi and ttrang=b_klk order by ma) where ma>=b_ma;
    PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
    open cs_lke for select * from (select ma,so_hd,nd,row_number() over (order by ma) sott from kh_ma_hdong
        where ma_dvi=b_ma_dvi and ttrang=b_klk order by ma) where sott between b_tu and b_den;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_MA_HDONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_klk varchar2,b_tim nvarchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n; b_phong varchar2(10);
begin
-- Dan - Liet ke chung tu cong no theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N')<>'C' then
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    if b_tim is null then
        select count(*) into b_dong from (select distinct a.ma from kh_ma_hdong a,kh_ma_hdong_bp b where
            b.ma_dvi=b_ma_dvi and b.phong=b_phong and a.ma_dvi=b_ma_dvi and a.ma=b.ma);
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select ma,so_hd,nd from (select distinct a.ma,a.so_hd,a.nd,row_number() over (order by a.ma) sott from kh_ma_hdong a,kh_ma_hdong_bp b
            where b.ma_dvi=b_ma_dvi and b.phong=b_phong and a.ma_dvi=b_ma_dvi and a.ma=b.ma order by a.ma) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from (select a.ma from kh_ma_hdong a,kh_ma_hdong_bp b where
            b.ma_dvi=b_ma_dvi and b.phong=b_phong and a.ma_dvi=b_ma_dvi and a.ma=b.ma and upper(a.nd) like b_tim);
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select ma,so_hd,nd from (select a.ma,a.so_hd,a.nd,row_number() over (order by a.ma) sott from kh_ma_hdong a,kh_ma_hdong_bp b
            where b.ma_dvi=b_ma_dvi and b.phong=b_phong and a.ma_dvi=b_ma_dvi and a.ma=b.ma and upper(a.nd) like b_tim order by a.ma) where sott between b_tu and b_den;
    end if;
elsif b_klk ='T' then
    if b_tim is null then
        select count(*) into b_dong from kh_ma_hdong where ma_dvi=b_ma_dvi;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select ma,so_hd,nd from (select ma,so_hd,nd,row_number() over (order by ma) sott
            from kh_ma_hdong where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
    else
        select count(*) into b_dong from kh_ma_hdong where ma_dvi=b_ma_dvi and upper(nd) like b_tim;
        PKH_LKE_TRANG(b_dong,b_tu,b_den);
        open cs_lke for select ma,so_hd,nd from (select ma,so_hd,nd,row_number() over (order by ma) sott
            from kh_ma_hdong where ma_dvi=b_ma_dvi and upper(nd) like b_tim order by ma) where sott between b_tu and b_den;
    end if;
elsif b_tim is null then
    select count(*) into b_dong from kh_ma_hdong where ma_dvi=b_ma_dvi and ttrang=b_klk;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select ma,so_hd,nd from (select ma,so_hd,nd,row_number() over (order by ma) sott
        from kh_ma_hdong where ma_dvi=b_ma_dvi and ttrang=b_klk order by ma) where sott between b_tu and b_den;
else
    select count(*) into b_dong from kh_ma_hdong where ma_dvi=b_ma_dvi and ttrang=b_klk and upper(nd) like b_tim;
    PKH_LKE_TRANG(b_dong,b_tu,b_den);
    open cs_lke for select ma,so_hd,nd from (select ma,so_hd,nd,row_number() over (order by ma) sott
        from kh_ma_hdong where ma_dvi=b_ma_dvi and ttrang=b_klk and upper(nd) like b_tim order by ma) where sott between b_tu and b_den;
end if;
end;
/
create or replace procedure PKH_MA_HDONG_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,
    cs_ct out pht_type.cs_type,cs_vt out pht_type.cs_type,cs_dv out pht_type.cs_type,
    cs_da out pht_type.cs_type,cs_tt out pht_type.cs_type,cs_bp out pht_type.cs_type,cs_phi out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_ct for select * from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
open cs_vt for select a.*,decode(a.nhom,' ','',a.nhom||':')||a.ma_vt||':'||b.ten ten from kh_ma_hdong_vt a,vt_ma_vt b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi (+) =b_ma_dvi and b.nhom (+) =a.nhom and b.ma (+) =a.ma_vt order by bt;
open cs_dv for select a.*,a.ma_dv||':'||b.ten ten from kh_ma_hdong_dv a,sx_ma_sp b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi (+) =b_ma_dvi and b.ma (+) =a.ma_dv order by bt;
open cs_da for select * from kh_ma_hdong_da where ma_dvi=b_ma_dvi and ma=b_ma order by bt;
open cs_tt for select * from kh_ma_hdong_tt where ma_dvi=b_ma_dvi and ma=b_ma order by ngay;
open cs_bp for select a.dvi,a.phong||'{'||b.ten phong,a.ma_cb,a.pt,a.tien from kh_ma_hdong_bp a,ht_ma_phong b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi=b_ma_dvi and b.ma=a.phong order by a.bt;
open cs_phi for select a.dvi,a.phong||'{'||b.ten phong,a.pt from kh_ma_hdong_phi a,ht_ma_phong b
    where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi=b_ma_dvi and b.ma=a.phong order by a.bt;
end;
/
create or replace procedure PKH_MA_HDONG_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if trim(b_ma) is null then b_loi:='loi:Nhap ma hop dong:loi'; raise PROGRAM_ERROR; end if;
select min(nsd),min(so_id_kt),count(*) into b_nsd_c,b_so_id_kt,b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
if b_i1=0 then return; end if;
if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong xoa ma cua NSD khac:loi'; raise PROGRAM_ERROR; end if;
b_loi:='loi:Khong xoa hop dong da phat sinh so lieu:loi';
if b_so_id_kt>0 then raise PROGRAM_ERROR; end if;
select count(*) into b_i1 from kh_hdong_dt where ma_dvi=b_ma_dvi and ma=b_ma;
if b_i1=0 then
    select count(*) into b_i1 from kh_hdong_dh where ma_dvi=b_ma_dvi and ma=b_ma;
    if b_i1=0 then
        select count(*) into b_i1 from kh_hdong_tt where ma_dvi=b_ma_dvi and ma=b_ma;
    end if;
end if;
if b_i1<>0 then raise PROGRAM_ERROR; end if;
delete kh_ma_hdong_phi where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong_bp where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong_th where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong_tt where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong_vt where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong_dv where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong_da where ma_dvi=b_ma_dvi and ma=b_ma;
delete kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TON_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nv varchar2,b_ma varchar2,b_dk varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Liet ke ton hoan thanh
delete kh_hdong_vt_temp; delete kh_hdong_vt_temp1;
delete kh_hdong_dv_temp; delete kh_hdong_dv_temp1;
delete kh_hdong_da_temp; delete kh_hdong_da_temp1;
commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma ho dong:loi';
if b_ma is null then raise PROGRAM_ERROR;
else
    select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
if b_nv='VT' then
    if b_dk='C' then
        open cs_lke for select a.*,decode(a.nhom,' ','',a.nhom||':')||a.ma_vt||':'||b.ten ten from kh_hdong_dh_vt a,vt_ma_vt b
            where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi (+) =b_ma_dvi and b.nhom (+) =a.nhom and b.ma (+) =a.ma_vt order by bt;
    else
         PKH_HDONG_TON_VT(b_ma_dvi,b_ma);
        open cs_lke for select a.*,decode(a.nhom,' ','',a.nhom||':')||a.ma_vt||':'||b.ten ten from kh_hdong_vt_temp a,vt_ma_vt b
            where b.ma_dvi (+) =b_ma_dvi and b.nhom (+) =a.nhom and b.ma (+) =a.ma_vt order by a.ma_vt;
    end if;
elsif b_nv='DV' then
    if b_dk='C' then
        open cs_lke for select a.*,a.ma_dv||':'||b.ten ten from kh_hdong_dh_dv a,sx_ma_sp b
            where a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi (+) =b_ma_dvi and b.ma (+) =a.ma_dv order by bt;
    else
        PKH_HDONG_TON_DV(b_ma_dvi,b_ma);
        open cs_lke for select a.*,a.ma_dv||':'||b.ten ten from kh_hdong_dv_temp a,sx_ma_sp b
            where b.ma_dvi (+) =b_ma_dvi and b.ma (+) =a.ma_dv order by a.ma_dv;
    end if;
else
    if b_dk='C' then
        open cs_lke for select * from kh_hdong_dh_da where ma_dvi=b_ma_dvi and ma=b_ma;
    else
        PKH_HDONG_TON_DA(b_ma_dvi,b_ma);
        open cs_lke for select * from kh_hdong_da_temp;
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_DH_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke hoan thanh theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma ho dong:loi'; raise PROGRAM_ERROR; end if;
open cs_lke for select ngay,nd,so_id from kh_hdong_dh where ma_dvi=b_ma_dvi and ma=b_ma order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_DH_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    cs_ct out pht_type.cs_type,cs_vt out pht_type.cs_type,cs_dv out pht_type.cs_type,cs_da out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_ct for select * from kh_hdong_dh where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_vt for select a.*,decode(a.nhom,' ','',a.nhom||':')||a.ma_vt||':'||b.ten ten from kh_hdong_dh_vt a,vt_ma_vt b
    where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.ma_dvi (+) =b_ma_dvi and b.nhom (+) =a.nhom and b.ma (+) =a.ma_vt order by bt;
open cs_dv for select a.*,a.ma_dv||':'||b.ten ten from kh_hdong_dh_dv a,sx_ma_sp b
    where a.ma_dvi=b_ma_dvi and a.so_id=b_so_id and b.ma_dvi (+) =b_ma_dvi and b.ma (+) =a.ma_dv order by bt;
open cs_da for select * from kh_hdong_dh_da where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt;
end;
/
create or replace procedure PKH_HDONG_DH_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_i1 number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
PKH_HDONG_DH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'H',b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_DH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,b_ma varchar2,b_ngay number,b_tien number,b_nd nvarchar2,
    a_nhom in out pht_type.a_var,a_ma_vt pht_type.a_var,a_nuoc pht_type.a_var,a_model pht_type.a_var,
    a_dv pht_type.a_nvar,a_cl pht_type.a_var,a_dai pht_type.a_num,a_rong pht_type.a_num,a_cao pht_type.a_num,
    a_luong pht_type.a_num,a_vt_gia pht_type.a_num,a_vt_tien pht_type.a_num,
    a_dv_ma in out pht_type.a_var,a_dv_dv pht_type.a_nvar,a_dv_luong pht_type.a_num,a_dv_gia pht_type.a_num,a_dv_tien pht_type.a_num,
    a_da_nd in out pht_type.a_nvar,a_da_tien pht_type.a_num)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number; b_nsd_c varchar2(10); b_so_id_kt number:=0;
    b_nhom varchar2(1); b_ma_nt varchar2(5); b_tien_qd number; b_ttrang varchar2(1);
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if trim(b_ma) is null then raise PROGRAM_ERROR; end if;
select nhom,ma_nt,ttrang into b_nhom,b_ma_nt,b_ttrang from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
if b_ttrang<>'D' then b_loi:='loi:Hop dong da dong:loi'; raise PROGRAM_ERROR; end if;
if b_ngay is null or b_tien is null or b_tien=0 or trim(b_nd) is null then b_loi:='loi:Sai so lieu nhap:loi'; raise PROGRAM_ERROR; end if;
if b_ma_nt='VND' then b_tien_qd:=b_tien; else b_tien_qd:=FTT_VND_QD(b_ma_dvi,b_ngay,b_ma_nt,b_tien); end if;
PKH_MANG(a_nhom); PKH_MANG(a_dv_ma); PKH_MANG_U(a_da_nd);
for b_lp in 1..a_nhom.count loop
    b_loi:='loi:Nhap sai hang dong#'||to_char(b_lp)||':loi';
    if a_nhom(b_lp) is null or a_ma_vt(b_lp) is null or a_nuoc(b_lp) is null or
        a_model(b_lp) is null or a_dv(b_lp) is null or a_cl(b_lp) is null or
        a_dai(b_lp) is null or a_rong(b_lp) is null or a_cao(b_lp) is null or a_luong(b_lp)=0 or
        a_vt_gia(b_lp) is null or a_vt_gia(b_lp)<0 or a_vt_tien(b_lp) is null or a_vt_tien(b_lp)=0 then raise PROGRAM_ERROR;
    end if;
    select count(*) into b_i1 from (select * from kh_ma_hdong_vt where ma_dvi=b_ma_dvi and ma=b_ma) where
        nhom=a_nhom(b_lp) and ma_vt=a_ma_vt(b_lp) and nuoc=a_nuoc(b_lp) and model=a_model(b_lp) and
        dv=a_dv(b_lp) and cl=a_cl(b_lp) and dai=a_dai(b_lp) and rong=a_rong(b_lp) and cao=a_cao(b_lp);
    if b_i1=0 then raise PROGRAM_ERROR; end if;
end loop;
for b_lp in 1..a_dv_ma.count loop
    b_loi:='loi:Nhap sai dich vu dong#'||to_char(b_lp)||':loi';
    if a_dv_ma(b_lp) is null or a_dv_tien(b_lp) is null or a_dv_tien(b_lp)=0 then raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from (select * from kh_ma_hdong_dv where ma_dvi=b_ma_dvi and ma=b_ma) where ma=a_dv_ma(b_lp) and dv=a_dv_dv(b_lp);
    if b_i1=0 then raise PROGRAM_ERROR; end if;
end loop;
for b_lp in 1..a_da_nd.count loop
    b_loi:='loi:Nhap sai hop dong dong#'||to_char(b_lp)||':loi';
    if a_da_nd(b_lp) is null or a_da_tien(b_lp) is null or a_da_tien(b_lp)=0 then raise PROGRAM_ERROR; end if;
    select count(*) into b_i1 from (select * from kh_ma_hdong_da where ma_dvi=b_ma_dvi and ma=b_ma) where nd=a_da_nd(b_lp);
    if b_i1=0 then raise PROGRAM_ERROR; end if;
end loop;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PKH_HDONG_DH_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,'H',b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_nhom='B' then b_i1:=0; else b_i1:=-1; end if;
b_loi:='loi:Loi Table kh_hdong_dh:loi';
insert into kh_hdong_dh values(b_ma_dvi,b_so_id,b_ma,b_ngay,b_tien,b_tien_qd,b_nd,b_nsd,sysdate,b_i1,b_idvung);
for b_lp in 1..a_nhom.count loop
    insert into kh_hdong_dh_vt values(b_ma_dvi,b_so_id,b_lp,b_ma,b_ngay,a_nhom(b_lp),a_ma_vt(b_lp),a_nuoc(b_lp),a_model(b_lp),
        a_dv(b_lp),a_cl(b_lp),a_dai(b_lp),a_rong(b_lp),a_cao(b_lp),a_luong(b_lp),a_vt_gia(b_lp),a_vt_tien(b_lp),b_idvung);
end loop;
for b_lp in 1..a_dv_ma.count loop
    insert into kh_hdong_dh_dv values(b_ma_dvi,b_so_id,b_lp,b_ma,b_ngay,a_dv_ma(b_lp),
        a_dv_dv(b_lp),a_dv_luong(b_lp),a_dv_gia(b_lp),a_dv_tien(b_lp),b_idvung);
end loop;
for b_lp in 1..a_da_nd.count loop
    insert into kh_hdong_dh_da values(b_ma_dvi,b_so_id,b_lp,b_ma,b_ngay,a_da_nd(b_lp),a_da_tien(b_lp),b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_i1 number;
begin
-- Dan - Liet ke thanh toan theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_ma is null then  raise PROGRAM_ERROR;
else
    select count(*) into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
open cs_lke for select ngay,nd,so_id from kh_hdong_tt where ma_dvi=b_ma_dvi and ma=b_ma order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TT_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs_ct out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_ct for select * from kh_hdong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace procedure PKH_HDONG_TT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_i1 number; b_nsd_c varchar2(10);
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
select min(nsd),count(*) into b_nsd_c,b_i1 from kh_hdong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; raise PROGRAM_ERROR; end if;
    delete kh_hdong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,b_ma varchar2,b_ngay number,b_loai varchar2,b_tien number,b_nd nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number; b_nsd_c varchar2(10); b_so_id_g number:=0;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_ma is null then  raise PROGRAM_ERROR;
else
    select 0 into b_i1 from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
if b_ngay is null or b_loai is null or b_loai not in ('T','C') or b_tien is null or b_tien=0
    or trim(b_nd) is null then b_loi:='loi:Sai so lieu nhap:loi'; raise PROGRAM_ERROR;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
else
    select min(nsd),count(*),nvl(min(so_id_g),0) into b_nsd_c,b_i1 ,b_so_id_g from kh_hdong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; raise PROGRAM_ERROR; end if;
        delete kh_hdong_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
b_loi:='loi:Loi Table kh_hdong_tt:loi';
insert into kh_hdong_tt values(b_ma_dvi,b_so_id,b_ma,b_ngay,b_loai,b_tien,b_nd,b_nsd,sysdate,b_so_id_g,b_idvung);
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_NB_LSU
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ma varchar2,b_phong_n varchar2,cs_ct out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number; b_phong varchar2(10);
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_phong_n is not null and b_phong<>b_phong_n and FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N')<>'C' then
    b_loi:='loi:Khong xem so lieu bo phan khac:loi'; raise PROGRAM_ERROR;
end if;
open cs_ct for select ngay_ht,tien,nd,so_id from kh_hdong_nb where ma_dvi=b_ma_dvi and ma=b_ma order by ngay_ht,so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_NB_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_phong varchar2(10);
begin
-- Dan - Liet ke thanh toan theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N')='C' then
    open cs_lke for select phong,ma,tien,so_id from kh_hdong_nb where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by phong,ma,so_id;
else
    b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
    open cs_lke for select phong,ma,tien,so_id from kh_hdong_nb where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht and phong=b_phong order by ma,so_id;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_NB_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs_ct out pht_type.cs_type)
AS
    b_loi varchar2(100); b_idvung number;
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','X');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N')<>'C' and FKH_HDONG_NB_PHONG(b_ma_dvi,b_so_id)<>FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd) then
    b_loi:='loi:Khong xem so lieu bo phan khac:loi'; raise PROGRAM_ERROR;
end if;
open cs_ct for select * from kh_hdong_nb where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_NB_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_i1 number; b_nsd_c varchar2(10);
begin
-- Dan - xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID:loi'; raise PROGRAM_ERROR; end if;
PKH_HDONG_NB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_NB_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,b_ma varchar2,
    b_ma_sp varchar2,b_phong_n varchar2, b_ngay_ht number,b_so_ct varchar2,b_tien number,b_nd nvarchar2)
AS
    b_loi varchar2(100); b_i1 number; b_i2 number; b_idvung number; b_nsd_c varchar2(10);
    b_phong varchar2(10); b_bt number; b_tp number; b_ma_nt varchar2(5); b_tien_qd number; b_ttrang varchar2(1);
    b_nhom varchar2(1); b_con number; b_con_qd number; b_phi number; b_phi_qd number;
    a_ma_cb pht_type.a_var; a_pt pht_type.a_num;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','HDO','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Sai ma hop dong:loi';
if b_ma is null then raise PROGRAM_ERROR;
else
    select nhom,ma_nt,ttrang into b_nhom,b_ma_nt,b_ttrang from kh_ma_hdong where ma_dvi=b_ma_dvi and ma=b_ma;
    if b_ttrang not in ('D','C') then b_loi:='loi:Hop dong da dong:loi'; raise PROGRAM_ERROR; end if;
    if b_nhom='M' then b_loi:='loi:Sai nhom:loi'; raise PROGRAM_ERROR; end if;
end if;
b_loi:='loi:Sai ma bo phan:loi';
b_phong:=FHT_MA_NSD_PHONG(b_ma_dvi,b_nsd);
if b_phong_n is not null then
    if FHT_MA_NSD_QU(b_ma_dvi,b_nsd,'KT','KT','N')<>'C' and b_phong<>b_phong_n then raise PROGRAM_ERROR; end if;
    select 0 into b_i1 from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and dvi in(' ',b_ma_dvi) and ma=b_ma and phong=b_phong_n;
    b_phong:=b_phong_n;
end if;
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    PKH_HDONG_NB_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_tien is null or b_tien=0 then
    b_loi:='loi:Nhap tien:loi'; raise PROGRAM_ERROR;
else
    select nvl(sum(tien),0) into b_i1 from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and dvi in(' ',b_ma_dvi) and ma=b_ma and phong=b_phong;
    select nvl(sum(tien),0) into b_i2 from kh_hdong_nb where ma_dvi=b_ma_dvi and ma=b_ma and phong=b_phong;
    if b_i1<b_tien+b_i2 then b_loi:='loi:Vuot qua tien hop dong:loi'; raise PROGRAM_ERROR; end if;
end if;
if b_ngay_ht is null or trim(b_nd) is null then b_loi:='loi:Sai so lieu nhap:loi'; raise PROGRAM_ERROR; end if;
if b_ma_nt='VND' then b_tp:=0; b_tien_qd:=b_tien; else b_tp:=2; b_tien_qd:=FTT_VND_QD(b_ma_dvi,b_ngay_ht,b_ma_nt,b_tien); end if;
if b_nhom='B' and b_ttrang='D' then b_i1:=0; else b_i1:=-1; end if;
b_loi:='loi:Loi Table kh_hdong_nb:loi';
insert into kh_hdong_nb values(b_ma_dvi,b_so_id,b_ngay_ht,b_phong,b_ma,b_ma_sp,b_so_ct,b_ma_nt,b_tien,b_tien_qd,b_nd,b_nsd,sysdate,' ',b_i1,b_idvung);
select ma_cb,pt BULK COLLECT into a_ma_cb,a_pt from (select ma_cb,pt,phong from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and ma=b_ma)
    where phong=b_phong and trim(ma_cb) is not null and pt<>0;
if a_ma_cb.count<>0 then
    b_con:=b_tien; b_con_qd:=b_tien_qd;
    b_i1:=0;
    for b_lp in 1..a_ma_cb.count loop
        b_i1:=b_i1+a_pt(b_lp);
    end loop;
    for b_lp in 1..a_ma_cb.count loop
        if b_lp=a_ma_cb.count then b_phi:=b_con; b_phi_qd:=b_con_qd;
        else
            b_phi:=round(a_pt(b_lp)*b_tien/b_i1,b_tp);
            if b_ma_nt='VND' then b_phi_qd:=b_phi; else b_phi_qd:=FTT_VND_QD(b_ma_dvi,b_ngay_ht,b_ma_nt,b_phi); end if;
        end if;
        insert into kh_hdong_nb_dt values(b_ma_dvi,b_so_id,b_lp,a_ma_cb(b_lp),b_phi,b_phi_qd,b_idvung);
        b_con:=b_con-b_phi; b_con_qd:=b_con_qd-b_phi_qd;
    end loop;
end if;
select nvl(sum(pt),0),max(bt) into b_i1,b_bt from kh_ma_hdong_phi where ma_dvi=b_ma_dvi and ma=b_ma;
if b_i1<>0 then
    b_con:=b_tien; b_con_qd:=b_tien_qd;
    for r_lp in (select dvi,phong,pt,bt from kh_ma_hdong_phi where ma_dvi=b_ma_dvi and ma=b_ma order by bt) loop
        if r_lp.bt=b_bt then b_phi:=b_con; b_phi_qd:=b_con_qd;
        else
            b_phi:=round(r_lp.pt*b_tien/b_i1,b_tp);
            if b_ma_nt='VND' then b_phi_qd:=b_phi; else b_phi_qd:=FTT_VND_QD(b_ma_dvi,b_ngay_ht,b_ma_nt,b_phi); end if;
        end if;
        insert into kh_hdong_nb_phi values(b_ma_dvi,b_so_id,r_lp.bt,r_lp.dvi,r_lp.phong,b_ma,b_ma_nt,b_phi,b_phi_qd,b_idvung);
        b_con:=b_con-b_phi; b_con_qd:=b_con_qd-b_phi_qd;
    end loop;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TK_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Cac loai co the dung
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
open cs1 for select distinct ngay from kh_hdong_tk where ma_dvi=b_ma_dvi order by ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TK_CT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); 
begin
-- Dan - Liet ke
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if;
open cs1 for select * from kh_hdong_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TK_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number,
    a_ma pht_type.a_var,a_tk pht_type.a_var)
AS
    b_loi varchar2(100); b_idvung number; b_i1 number;
begin
-- Dan - Nhap
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','HDO','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if; 
if a_ma.count=0 then b_loi:='loi:Nhap tai khoan chi tiet:loi'; raise PROGRAM_ERROR; end if; 
for b_lp in 1..a_ma.count loop
    if a_ma(b_lp) is null or a_tk(b_lp) is null then
        b_loi:='loi:Sai chi tiet dong#'||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    b_loi:='loi:Tai khoan#'||a_tk(b_lp)||'#chua dang ky:loi';
    select 0 into b_i1 from kt_ma_tk where ma_dvi=b_ma_dvi and ma=a_tk(b_lp);
end loop;
b_loi:='loi:Loi Table kh_hdong_tk:loi';
delete kh_hdong_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
for b_lp in 1..a_ma.count loop
    insert into kh_hdong_tk values(b_ma_dvi,b_ngay,a_ma(b_lp),a_tk(b_lp),b_nsd,b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PKH_HDONG_TK_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay number)
AS
    b_loi varchar2(100);
begin
-- Dan - Xoa
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','HDO','M');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ngay is null then b_loi:='loi:Nhap ngay:loi'; raise PROGRAM_ERROR; end if; 
b_loi:='loi:Loi Table kh_hdong_tk:loi';
delete kh_hdong_tk where ma_dvi=b_ma_dvi and ngay=b_ngay;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FKH_MA_VIEC_HOI_MA
    (b_ma_dvi varchar2,b_ngay number) return varchar2
AS
    b_kq varchar2(30); b_dau varchar2(30); b_d1 number; b_d2 number; b_i1 number; b_i2 number;
begin
-- Dan - Cho ma tiep theo
b_d1:=round(b_ngay,-2); b_d2:=b_d1+100;  --Theo thang
select max(ma) into b_kq from kh_ma_viec where ma_dvi=b_ma_dvi and ngay_bd between b_d1 and b_d2;
if b_kq is null then
    b_i1:=0; b_dau:=to_char(b_ngay);
    b_dau:=substr(b_dau,5,2)||'/'||substr(b_dau,3,2)||'/';
else
    b_i1:=PKH_LOC_CHU_SO(substr(b_dau,7));
end if;
while b_kq is null loop
    b_i1:=b_i1+1;
    b_kq:=substr(b_dau,1,6)||to_char(b_i1);
    select count(*) into b_i2 from kh_ma_viec where ma_dvi=b_ma_dvi and ma=b_kq;
    if b_i2<>0 then b_kq:=''; else exit; end if;
end loop;
return b_kq;
end;
/
create or replace function FKH_MA_HDONG_BP (b_ma_dvi varchar2,b_ma varchar2,b_dk varchar2:='T') return nvarchar2
AS
    a_phong pht_type.a_var; b_lke nvarchar2(1000):=''; b_tra nvarchar2(1000):=''; b_ten nvarchar2(400);
begin
-- Dan - Tra ma phong theo hop dong
if b_dk='1' then
    select min(phong) into b_tra from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and ma=b_ma;
    return b_tra;
else
    select phong bulk collect into a_phong from kh_ma_hdong_bp where ma_dvi=b_ma_dvi and ma=b_ma order by phong;
    for b_lp in 1..a_phong.count loop
        select min(ten) into b_ten from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
        if b_lp=1 then
            b_lke:=b_ten; b_tra:=a_phong(b_lp);
        else
            b_lke:=b_lke||','||b_ten; b_tra:=b_tra||','||a_phong(b_lp);
        end if;
    end loop;
    return b_lke||'|'||b_tra;
end if;
end;
/
create or replace procedure PKH_HDONG_TON_VT(b_ma_dvi varchar2,b_ma varchar2)
AS
begin
-- Dan - Ton hang theo ma
delete kh_hdong_vt_temp; delete kh_hdong_vt_temp1;
insert into kh_hdong_vt_temp1 select nhom,ma_vt,nuoc,model,dv,cl,dai,rong,cao,sum(luong),gia,sum(tien)
    from kh_ma_hdong_vt where ma_dvi=b_ma_dvi and ma=b_ma group by nhom,ma_vt,nuoc,model,dv,cl,dai,rong,cao,gia;
insert into kh_hdong_vt_temp1 select nhom,ma_vt,nuoc,model,dv,cl,dai,rong,cao,-sum(luong),gia,-sum(tien)
    from kh_hdong_dh_vt where ma_dvi=b_ma_dvi and ma=b_ma group by nhom,ma_vt,nuoc,model,dv,cl,dai,rong,cao,gia;
insert into kh_hdong_vt_temp select nhom,ma_vt,nuoc,model,dv,cl,dai,rong,cao,sum(luong),gia,sum(tien)
    from kh_hdong_vt_temp1 group by nhom,ma_vt,nuoc,model,dv,cl,dai,rong,cao,gia having sum(luong)<>0;
end;
/
create or replace procedure PKH_HDONG_TON_DV(b_ma_dvi varchar2,b_ma varchar2)
AS
begin
-- Dan - Ton dich vu theo ID
delete kh_hdong_dv_temp; delete kh_hdong_dv_temp1;
insert into kh_hdong_dv_temp1 select ma_dv,dv,sum(luong),gia,sum(tien)
    from kh_ma_hdong_dv where ma_dvi=b_ma_dvi and ma=b_ma group by ma_dv,dv,gia;
insert into kh_hdong_dv_temp1 select ma_dv,dv,-sum(luong),gia,-sum(tien)
    from kh_hdong_dh_dv where ma_dvi=b_ma_dvi and ma=b_ma group by ma_dv,dv,gia;
insert into kh_hdong_dv_temp select ma_dv,dv,sum(luong),gia,sum(tien)
    from kh_hdong_dv_temp1 group by ma_dv,dv,gia having sum(luong)<>0 or sum(tien)<>0;
end;
/
create or replace procedure PKH_HDONG_TON_DA(b_ma_dvi varchar2,b_ma varchar2)
AS
begin
-- Dan - Ton viec theo ID
delete kh_hdong_da_temp; delete kh_hdong_da_temp1;
insert into kh_hdong_da_temp1 select nd,sum(tien)
    from kh_ma_hdong_da where ma_dvi=b_ma_dvi and ma=b_ma group by nd;
insert into kh_hdong_da_temp1 select nd,-sum(tien)
    from kh_hdong_dh_da where ma_dvi=b_ma_dvi and ma=b_ma group by nd;
insert into kh_hdong_da_temp select nd,sum(tien) from kh_hdong_da_temp1 group by nd having sum(tien)<>0;
end;
/
create or replace procedure PKH_HDONG_DH_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_dk varchar2,b_loi out varchar2)
AS
    b_i1 number; b_nsd_c varchar2(10); b_so_id_kt number;
begin
-- Dan - xoa
select min(nsd),min(so_id_kt),count(*) into b_nsd_c,b_so_id_kt,b_i1 from kh_hdong_dh where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi'; return; end if;
    if b_dk<>'G' and b_so_id_kt>0 then b_loi:='loi:Chung tu da hach toan:loi'; return; end if;
    delete kh_hdong_dh_vt where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete kh_hdong_dh_dv where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete kh_hdong_dh_da where ma_dvi=b_ma_dvi and so_id=b_so_id;
    delete kh_hdong_dh where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace package PKG_KHOACH_BTHUONG is
procedure P_BTHUONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_BTHUONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2,b_he_so number);
procedure P_BTHUONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2);
end;
/
create or replace package PKG_KHOACH_BTHUONG is
procedure P_BTHUONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_BTHUONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2,b_he_so number);
procedure P_BTHUONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2);
end;
/
create or replace package PKG_KHOACH_BTHUONG is
procedure P_BTHUONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_BTHUONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2,b_he_so number);
procedure P_BTHUONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2);
end;
/
create or replace package PKG_KHOACH_BTHUONG is
procedure P_BTHUONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_BTHUONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2,b_he_so number);
procedure P_BTHUONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2);
end;
/
create or replace package PKG_KHOACH_BTHUONG is
procedure P_BTHUONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BTHUONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_BTHUONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2,b_he_so number);
procedure P_BTHUONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_nv varchar2,b_lhnv varchar2);
end;
/
create or replace package PKG_KHOACH_CHUNG is
function FHT_MA_DVI_HO(b_dvi varchar2:='') return nvarchar2;
function FTHANG_TEN(b_thang varchar2) return nvarchar2;
procedure PHT_MA_DVI_XEM(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,cs1 out pht_type.cs_type);
end;
/
create or replace package PKG_KHOACH_COCHE is
/*
    Co che chi phi kinh doanh co dinh theo don vị
*/
procedure P_CPKDCD_DVI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDCD_DVI_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_dvi varchar2,b_ma_cttt varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDCD_DVI_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_dvi varchar2,b_ma_cttt varchar2,cs1 out pht_type.cs_type);    
procedure P_CPKDCD_DVI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_dvi varchar2,
    b_ma_cttt varchar2,b_quy number,
    a_thang pht_type.a_var,a_cphi pht_type.a_num);
procedure P_CPKDCD_DVI_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_dvi varchar2,b_ma_cttt varchar2);

/*
    Co che chi phi kinh doanh co dinh theo don vị
*/
-----------------------------------------------------------   

/*
    Co che chi phi kinh doanh co dinh theo phong
*/
procedure P_CPKDCD_PHONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDCD_PHONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_phong varchar2,b_ma_cttt varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDCD_PHONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_phong varchar2,b_ma_cttt varchar2,cs1 out pht_type.cs_type);    
procedure P_CPKDCD_PHONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_phong varchar2,
    b_ma_cttt varchar2,b_quy number,
    a_thang pht_type.a_var,a_cphi pht_type.a_num);
procedure P_CPKDCD_PHONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_phong varchar2,b_ma_cttt varchar2);
/*
    Hết Co che chi phi kinh doanh co dinh theo phòng
*/
----------------------------------------------------------
/*
    Co che chi phi kinh doanh biến đổi theo don vị
*/

procedure P_CPKDBD_DVI_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDBD_DVI_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_dvi varchar2,b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDBD_DVI_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_dvi varchar2,b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_CPKDBD_DVI_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_dvi varchar2,
    b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2,b_quy number,
    a_thang pht_type.a_var,a_cphi pht_type.a_num);
procedure P_CPKDBD_DVI_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_dvi varchar2,b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2);
/*
    Co che chi phi kinh doanh biến đổi theo don vị
*/
----------------------------------------------------------
/*
    Co che chi phi kinh doanh biến đổi theo phòng/ban
*/
procedure P_CPKDBD_PHONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDBD_PHONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_phong varchar2,b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CPKDBD_PHONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nam number,b_ngay_kh number,b_phong varchar2,b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2,cs1 out pht_type.cs_type);    
procedure P_CPKDBD_PHONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,b_phong varchar2,
    b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2,b_quy number,
    a_thang pht_type.a_var,a_cphi pht_type.a_num);
procedure P_CPKDBD_PHONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_nam number,b_ngay_kh number,
    b_phong varchar2,b_ma_cttt varchar2,b_nv varchar2,b_lhnv varchar2);


/*
    Co che chi phi kinh doanh biến đổi theo phòng/ban
*/
-----------------------------------------------------------


/*
    Co che chi phi chỉ định theo hợp đồng
*/


procedure P_CP_HDONG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,b_so_hd varchar2,b_ma_cttt varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CP_HDONG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngayd number,b_ngayc number,b_so_hd_tim varchar2,b_ma_cttt_tim varchar2,
    b_ngay_kh number,b_so_hd varchar2,b_ma_cttt varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CP_HDONG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_kh number,b_so_hd varchar2,b_ma_cttt varchar2,cs1 out pht_type.cs_type);    
procedure P_CP_HDONG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_kh number,
    b_so_hd varchar2,b_ma_cttt varchar2,b_he_so number);
procedure P_CP_HDONG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_kh number,
    b_so_hd varchar2,b_ma_cttt varchar2);
/*
    Co che chi phi chỉ định theo hợp đồng
*/
-----------------------------------------------------

/*
    Co che chi phi chỉ định theo khách hàng
*/
procedure P_CP_KHANG_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_nhom_kh varchar2,b_nv varchar2,b_lhnv varchar2,b_ma_cttt varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CP_KHANG_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngayd number,b_ngayc number,b_nhom_kh_tim varchar2,b_nv_tim varchar2,b_lhnv_tim varchar2,b_ma_cttt_tim varchar2,
    b_ngay_kh number,b_nhom_kh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_ma_cttt varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CP_KHANG_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_kh number,b_nhom_kh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_ma_cttt varchar2,cs1 out pht_type.cs_type);    
procedure P_CP_KHANG_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_kh number,
    b_nhom_kh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_dthu_den number,b_ma_cttt varchar2,b_he_so number);
procedure P_CP_KHANG_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_kh number,
    b_nhom_kh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_ma_cttt varchar2);
/*
    Co che chi phi chỉ định theo khách hàng
*/
-------------------------------------------------------


/*
    Co che chi phi chỉ định theo đại lý/kênh
*/


procedure P_CP_KENH_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngayd number,b_ngayc number,
    b_ma_kenh varchar2,b_nv varchar2,b_lhnv varchar2,b_ma_cttt varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_CP_KENH_LKE_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngayd number,b_ngayc number,b_ma_kenh_tim varchar2,b_nv_tim varchar2,b_lhnv_tim varchar2,b_ma_cttt_tim varchar2,
    b_ngay_kh number,b_ma_kenh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_ma_cttt varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);    
procedure P_CP_KENH_HOI_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_kh number,b_ma_kenh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_ma_cttt varchar2,cs1 out pht_type.cs_type);    
procedure P_CP_KENH_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_kh number,
    b_ma_kenh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_dthu_den number,b_ma_cttt varchar2,b_he_so number);
procedure P_CP_KENH_CT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_kh number,
    b_ma_kenh varchar2,b_nv varchar2,b_lhnv varchar2,b_dthu_tu number,b_ma_cttt varchar2);
   
/*
    Co che chi phi chỉ định theo đại lý/kênh
*/
------------------------------------------------

/*
    Co che bổ sung - điều chỉnh trực tiêp
*/
procedure P_BS_DC_TT_LKE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BS_DC_TT_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ngay_dc number,b_loai_cp varchar2,b_ma_cp varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type);
procedure P_BS_DC_TT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_loai_cp varchar2,b_ma_cp varchar2,b_tien number,b_ngay_dc number);
procedure P_BS_DC_TT_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_loai_cp varchar2,b_ma_cp varchar2,b_ngay_dc number);

/*
    Co che bổ sung - điều chỉnh trực tiêp
*/

end;
/
create or replace procedure PBH_KT_NH_VNRE(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id in out number,
    b_l_ct varchar2,b_ngay_ht number,b_htoan varchar2,b_so_ct_n varchar2,
    b_ngay_ct varchar2,b_nd nvarchar2,b_nha varchar2,b_tk_nha varchar2,
    a_nv in out pht_type.a_var,a_ma_tk pht_type.a_var,
    a_ma_tke pht_type.a_var,a_tien pht_type.a_num,a_note pht_type.a_nvar,a_bt pht_type.a_num,b_lk out varchar2)
AS
    b_so_id_c number; b_loi varchar2(100); b_so_tt varchar2(20); b_kt_1 number;
    a_so_id pht_type.a_num; b_i1 number; b_i2 number; b_so_ct varchar2(20):=b_so_ct_n;
begin
-- Dan - Nhap chung tu ke toan nghiep vu bao hiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_MANG(a_nv); PKH_MANG_KD_N(a_so_id); b_i1:=0; b_i2:=0;
b_so_id_c:=b_so_id; b_so_tt:='0'; b_lk:='';
if b_so_id=0 then
    PHT_ID_MOI(b_so_id,b_loi);
else
    select count(*) into b_kt_1 from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id_c<>0 then
    if a_nv.count<>0 then
        if b_kt_1<>0 then
            PKT_KT_SUA(b_ma_dvi,b_nsd,'BH',b_htoan,b_ngay_ht,' ',b_so_tt,b_so_ct,b_ngay_ct,
                b_nd,' ',a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,b_lk,b_loi);
        else 
            PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,' ',b_so_tt,b_so_ct,b_ngay_ct,b_nd,' ',
                a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'BH',b_lk,b_loi,'C');
        end if;
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    elsif b_kt_1<>0 then
        PKT_KT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'BH');
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
elsif a_nv.count<>0 then
    PKT_KT_NH(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,' ',b_so_tt,b_so_ct,b_ngay_ct,b_nd,' ',
        a_nv,a_ma_tk,a_ma_tke,a_tien,a_note,a_bt,b_so_id,'BH',b_lk,b_loi,'C');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_XOA_VNRE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number)
AS
    b_loi varchar2(100); b_kt_1 number;
begin
-- Dan - Xoa chung tu hach toan nghiep vu
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_kt_1 from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_kt_1<>0 then
    PKT_KT_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi,'BH');
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_KT_LKE_VNRE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_klk varchar2,
    b_tu_n number,b_den_n number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number:=b_tu_n; b_den number:=b_den_n;
begin
-- Dan - Liet ke theo ngay
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
select count(*) into b_dong from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
PKH_LKE_TRANG(b_dong,b_tu,b_den);
open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by l_ct,so_id) sott
    from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_id) where sott between b_tu and b_den;
end;
/
create or replace procedure PBH_KT_LKE_ID_VNRE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,b_ngay_ht number,b_klk varchar2,
    b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select count(*) into b_dong from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht;
select nvl(min(sott),b_dong) into b_tu from (select l_ct,so_id,row_number() over (order by l_ct,so_id) sott
    from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_id) where so_id=b_so_id;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select so_id,l_ct,so_ct,row_number() over (order by l_ct,so_id) sott
    from kt_1 where ma_dvi=b_ma_dvi and ngay_ht=b_ngay_ht order by l_ct,so_id) where sott between b_tu and b_den;
end;
/
create or replace procedure PBH_KT_CT_VNRE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,cs_ct out pht_type.cs_type,cs_ht out pht_type.cs_type)
AS
    b_loi varchar2(100);
begin
-- Dan - Liet ke hach toan nghiep vu bao hiem
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
open cs_ct for select * from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_ht for select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_MA_HOI_TEN
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_nv varchar2,b_ma varchar2,cs_ten out pht_type.cs_type)
AS
begin
-- Dan - Hoi ten,dia chi,ma thue
if b_nv='MA_DVI' then
    open cs_ten for select a.*,a.ma_thue tax from ht_ma_dvi a where ma=b_ma;
elsif b_nv='MA_PH' then
    open cs_ten for select a.*,'' dchi,'' tax from ht_ma_phong a where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='MA_CB' then
    open cs_ten for select a.ten,a.ma_tk,a.nhang,a.ten_nh,b.ten dchi,'' tax from ht_ma_cb a,ht_ma_phong b where
        a.ma_dvi=b_ma_dvi and a.ma=b_ma and b.ma_dvi=b_ma_dvi and b.ma=a.phong;
elsif b_nv='MA_KH' then
    open cs_ten for select * from cn_ma_kh where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='MA_DL' then
    open cs_ten for select * from cn_ma_dl where ma_dvi=b_ma_dvi and ma=b_ma;
elsif b_nv='MA_CC' then
    open cs_ten for select * from cn_ma_cc where ma_dvi=b_ma_dvi and ma=b_ma;
end if;
end;
 
/
create or replace procedure PTV_NV_NH
    (b_ma_dvi varchar2,b_so_id number,b_tt out varchar2,b_loi out varchar2)
AS
    b_i1 number; b_log boolean; b_md varchar2(2); b_nsd varchar2(20); b_ngay_ht number; b_l_ct varchar2(5); b_lk varchar2(100); b_thue number;
    b_thue_qd number; b_t_toan number; b_t_toan_qd number; b_noite varchar2(5); b_nd nvarchar2(200);
    b_k_ma_kh varchar2(1):='K'; b_ma_kh varchar2(20):=''; b_ten nvarchar2(400); b_idvung number;
    a_nv pht_type.a_var; a_ma_tk pht_type.a_var; a_ma_tke pht_type.a_var; a_tien pht_type.a_num;
    a_nv_l pht_type.a_var; a_ma_tk_l pht_type.a_var; a_tien_l pht_type.a_num;
    r_vt vt_1%rowtype; r_tt tt_1%rowtype; r_cn_ch cn_ch%rowtype; r_cn_ct cn_ct%rowtype; r_xl xl_1%rowtype; r_tc tc_ps%rowtype;
    b_htoan varchar2(1):='T'; b_bt number:=0; b_ma_nt varchar(5); b_tg_tt number;
    a_bt_hd pht_type.a_num; a_mau pht_type.a_var; a_seri pht_type.a_var; a_so_hd pht_type.a_var; 
    a_so_phu pht_type.a_var; a_kieu pht_type.a_var; a_lay pht_type.a_var; a_hoan pht_type.a_var;
    a_ma_hd pht_type.a_var; a_nhom pht_type.a_var; a_ngay_ct pht_type.a_var; 
    a_k_ma_kh pht_type.a_var; a_ma_kh pht_type.a_var; a_ten pht_type.a_nvar; a_dchi pht_type.a_nvar; 
    a_ma_thue pht_type.a_var; a_nd pht_type.a_nvar; a_tien_t pht_type.a_num; a_loai pht_type.a_var; 
    a_pp pht_type.a_var; a_t_suat pht_type.a_num; a_thue pht_type.a_num; a_t_toan pht_type.a_num; 
    a_ma_tk_h pht_type.a_var; a_ma_tke_h pht_type.a_var; a_ma_ctr pht_type.a_var; a_bt_ct pht_type.a_num; 
    a_hang pht_type.a_nvar; a_dv pht_type.a_nvar; a_luong pht_type.a_num; a_gia pht_type.a_num; a_tien_h pht_type.a_num;
begin
-- Dan - Chuyen chung tu hach toan sang
b_loi:='loi:Chung tu hach toan da xoa:loi';
select md,nsd,ngay_ht,nd,idvung into b_md,b_nsd,b_ngay_ht,b_nd,b_idvung from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
PKT_TRA_KT2(b_ma_dvi,b_so_id,a_nv,a_ma_tk,a_ma_tke,a_tien,b_lk,b_loi);
if b_loi is not null then return; end if;
PKH_MA_LCT_TKNV(b_ma_dvi,'TV',b_ngay_ht,a_nv,a_ma_tk,b_l_ct);
if trim(b_l_ct) is null then b_loi:='loi:Khong co loai chung tu thue tuong ung:loi'; return; end if;
PKH_MA_LCT_TK(b_ma_dvi,'TV',b_ngay_ht,a_nv,a_ma_tk,a_nv_l,a_ma_tk_l,b_l_ct);
PKH_MA_LCT_TIEN(a_nv,a_ma_tk,a_tien,a_nv_l,a_ma_tk_l,a_tien_l);
b_thue_qd:=0; b_thue:=0; b_t_toan_qd:=0;
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp)='N' then b_t_toan_qd:=b_t_toan_qd+a_tien(b_lp); end if;
end loop;
for b_lp in 1..a_nv_l.count loop
    if a_nv_l(b_lp)='N' then b_thue_qd:=b_thue_qd+a_tien_l(b_lp); else b_thue:=b_thue+a_tien_l(b_lp); end if;
end loop;
if b_thue_qd=0 then b_thue_qd:=b_thue; end if;
b_tt:=0; PKH_MANG_KD_N(a_bt_ct); b_log:=true;
a_ma_tk_h(1):=''; a_ma_tke_h(1):=''; a_ma_ctr(1):=' '; a_ten(1):=''; a_dchi(1):=''; a_ma_thue(1):='';
a_so_phu(1):=' '; a_kieu(1):='G'; a_lay(1):='K'; a_hoan(1):='K'; a_nhom(1):=''; a_ma_hd(1):='01GTKT';
select count(*),min(ma) into b_i1,a_ma_hd(1) from tv_ma_hd where ma_dvi=b_ma_dvi;
if b_i1>1 then a_ma_hd(1):=' '; end if;
if b_md='VT' or instr(b_lk,'VT:2')>0 then
    b_loi:='loi:Dang xu ly chung tu vat tu:loi';
    select * into r_vt from vt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if r_vt.pp='K' then b_t_toan:=r_vt.tien+r_vt.thue; else b_t_toan:=r_vt.tien; end if;
    b_ma_nt:=r_vt.ma_nt; b_tg_tt:=r_vt.tg_tt;
    b_thue:=r_vt.thue;
    a_bt_hd(1):=1; a_mau(1):=r_vt.mau; a_seri(1):=r_vt.seri; a_so_hd(1):=r_vt.so_hd; a_ngay_ct(1):=r_vt.ngay_ct;
    a_k_ma_kh(1):=r_vt.k_ma_kh; a_ma_kh(1):=r_vt.ma_kh; a_ten(1):=r_vt.ten; a_dchi(1):=r_vt.dchi;
    a_ma_thue(1):=r_vt.ma_thue; a_nd(1):=r_vt.nd; a_tien_t(1):=r_vt.tien; a_loai(1):=r_vt.loai;
    a_pp(1):=r_vt.pp; a_t_suat(1):=r_vt.t_suat; a_thue(1):=r_vt.thue; a_t_toan(1):=b_t_toan;
    a_ma_ctr(1):=FKT_KH_TTT_HOI_ND(b_ma_dvi,'VT',b_so_id,0,'X');
    for r_lp in(select nhom,ma_vt,dv,luong,gia,tien,bt from vt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt) loop
        select min(ten) into b_ten from vt_ma_vt where ma_dvi=b_ma_dvi and nhom=r_lp.nhom and ma=r_lp.ma_vt;
        b_bt:=b_bt+1;
        a_bt_ct(b_bt):=1; a_hang(b_bt):=b_ten; a_dv(b_bt):=r_lp.dv; a_luong(b_bt):=r_lp.luong;
        a_gia(b_bt):=r_lp.gia; a_tien_h(b_bt):=r_lp.tien;
    end loop;
elsif b_md='XL' or instr(b_lk,'XL:2')>0 then
    b_loi:='loi:Dang xu ly chung tu du an, xay lap:loi';
    select * into r_xl from xl_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_ma_nt:=r_xl.ma_nt; b_tg_tt:=r_xl.tg_tt; b_t_toan:=r_xl.tien; b_thue:=r_xl.thue;
    a_bt_hd(1):=1; a_mau(1):=r_xl.mau; a_seri(1):=r_xl.seri; a_so_hd(1):=r_xl.so_hd; a_ngay_ct(1):=r_xl.ngay_ct;
    a_k_ma_kh(1):=r_xl.k_ma_kh; a_ma_kh(1):=r_xl.ma_kh; a_nd(1):=r_xl.nd;
    a_loai(1):=r_xl.loai; a_pp(1):=r_xl.pp; a_t_suat(1):=r_xl.t_suat; a_thue(1):=b_thue; a_t_toan(1):=b_t_toan;
    if r_xl.loai<>'T' then a_tien_t(1):=b_t_toan-b_thue; else a_tien_t(1):=b_t_toan; end if;
elsif b_md='TT' or instr(b_lk,'TT:2')>0 then
    b_loi:='loi:Dang xu ly chung tu tien te:loi';
    select * into r_tt from tt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_tg_tt:=1; b_thue:=r_tt.thue;
    if r_tt.tien_t<>0 then
        b_t_toan:=r_tt.tien_t; b_ma_nt:=r_tt.ma_nt_t;
        if b_ma_nt<>'VND' and b_t_toan<>0 then b_tg_tt:=round(r_tt.noi_te_t/b_t_toan,0); end if;
    else
        b_t_toan:=r_tt.tien_c; b_ma_nt:=r_tt.ma_nt_c;
        if b_ma_nt<>'VND' and b_t_toan<>0 then b_tg_tt:=round(r_tt.noi_te_c/b_t_toan,0); end if;
    end if; 
    a_bt_hd(1):=1; a_mau(1):=r_tt.mau; a_seri(1):=r_tt.seri; a_so_hd(1):=r_tt.so_hd; a_ngay_ct(1):=r_tt.ngay_ct;
    a_k_ma_kh(1):=r_tt.k_ma_kh; a_ma_kh(1):=r_tt.ma_kh; a_nd(1):=r_tt.nd;
    a_ten(1):=r_tt.ten; a_dchi(1):=r_tt.d_chi; a_ma_thue(1):=r_tt.ma_thue;
    a_loai(1):=r_tt.loai; a_pp(1):=r_tt.pp; a_t_suat(1):=r_tt.t_suat; a_thue(1):=b_thue; a_t_toan(1):=b_t_toan;
    if r_tt.loai<>'T' then a_tien_t(1):=b_t_toan-b_thue; else a_tien_t(1):=b_t_toan; end if;
elsif b_md='CN' or instr(b_lk,'CN:2')>0 then
    b_loi:='loi:Dang xu ly chung tu cong no:loi';
    select * into r_cn_ch from cn_ch where ma_dvi=b_ma_dvi and so_id=b_so_id;
    b_thue:=r_cn_ch.thue; b_t_toan:=r_cn_ch.tien; a_ngay_ct(1):=r_cn_ch.ngay_ct;
    a_bt_hd(1):=1; a_mau(1):=r_cn_ch.mau; a_seri(1):=r_cn_ch.seri; a_so_hd(1):=r_cn_ch.so_hd; a_nd(1):=r_cn_ch.nd;
    a_loai(1):=r_cn_ch.loai; a_pp(1):=r_cn_ch.pp; a_t_suat(1):=r_cn_ch.t_suat; a_thue(1):=b_thue; a_t_toan(1):=b_t_toan;
    if r_cn_ch.loai<>'T' then a_tien_t(1):=b_t_toan-b_thue; else a_tien_t(1):=b_t_toan; end if;
    select min(bt) into b_i1 from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id;
    select * into r_cn_ct from cn_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and bt=b_i1;
    b_ma_nt:=r_cn_ct.ma_nt; b_tg_tt:=r_cn_ct.ty_gia;
    a_k_ma_kh(1):=substr(r_cn_ct.ma_cn,1,1); a_ma_kh(1):=substr(r_cn_ct.ma_cn,2);
elsif b_md='TC' or instr(b_lk,'TC:2')>0 then
    b_loi:='loi:Dang xu ly chung tu tai chinh:loi';
    select * into r_tc from tc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if r_tc.thue<>0 then
        b_thue:=r_tc.thue; b_t_toan:=r_tc.lai; a_ngay_ct(1):=r_tc.ngay_ct;
        a_bt_hd(1):=1; a_mau(1):=r_tc.mau; a_seri(1):=r_tc.seri; a_so_hd(1):=r_tc.so_hd; a_nd(1):=r_tc.nd;
        a_loai(1):=r_tc.loai; a_pp(1):=r_tc.pp; a_t_suat(1):=r_tc.t_suat; a_thue(1):=b_thue; a_t_toan(1):=b_t_toan;
        if r_tc.loai<>'T' then a_tien_t(1):=b_t_toan-b_thue; else a_tien_t(1):=b_t_toan; end if;
        b_ma_nt:=r_tc.ma_nt;
        if b_ma_nt='VND' then
            b_tg_tt:=1;
        else
            b_tg_tt:=round(b_thue_qd/b_thue,0);
        end if;
        a_k_ma_kh(1):='K'; a_ma_kh(1):=' ';
    end if;
else
    b_log:=false;
end if;
if b_log then
    if b_thue_qd=0 or a_loai(1)='L' then b_thue:=0; b_thue_qd:=0; end if;
    PTV_CT_TEST(b_ma_dvi,b_nsd,b_md,b_ngay_ht,b_ngay_ht,'H',b_l_ct,b_ma_nt,b_tg_tt,b_tg_tt,b_thue_qd,b_t_toan_qd,
        a_bt_hd,a_mau,a_seri,a_so_hd,a_so_phu,a_kieu,a_lay,a_hoan,a_ma_hd,a_nhom,a_ngay_ct,a_k_ma_kh,a_ma_kh,a_tien_t,a_loai,
        a_pp,a_t_suat,a_thue,a_t_toan,a_ma_tk_h,a_ma_tke_h,a_ma_ctr,b_thue,b_t_toan,b_loi);
    if b_loi is null then
        b_htoan:='H'; b_tt:='2';
        if a_k_ma_kh(1) is not null and a_ma_kh(1) is not null then
            if a_k_ma_kh(1) in('U','K') then
                select ten,dchi,tax into a_ten(1),a_dchi(1),a_ma_thue(1) from cn_ma_kh where ma_dvi=b_ma_dvi and ma=a_ma_kh(1);
            elsif a_k_ma_kh(1)='D' then
                select ten,dchi,tax into a_ten(1),a_dchi(1),a_ma_thue(1) from cn_ma_dl where ma_dvi=b_ma_dvi and ma=a_ma_kh(1);
            end if;
        end if;
    end if;
    PTV_TV_NH(b_idvung,b_ma_dvi,'',b_md,b_ngay_ht,b_ngay_ht,b_htoan,b_so_id,b_l_ct,
        b_ma_nt,b_tg_tt,b_tg_tt,b_thue,b_t_toan,b_thue_qd,b_t_toan_qd,
        a_bt_hd,a_mau,a_seri,a_so_hd,a_so_phu,a_kieu,a_lay,a_hoan,a_ma_hd,a_nhom,a_ngay_ct,a_k_ma_kh,a_ma_kh,
        a_ten,a_dchi,a_ma_thue,a_nd,a_tien_t,a_loai,a_pp,a_t_suat,a_thue,a_t_toan,
        a_ma_tk_h,a_ma_tke_h,a_ma_ctr,a_bt_ct,a_hang,a_dv,a_luong,a_gia,a_tien_h,b_loi); 
else
    insert into tv_1 values(b_ma_dvi,b_so_id,b_l_ct,b_ngay_ht,b_ngay_ht,'VND',1,1,
        b_thue_qd,b_t_toan_qd,b_thue_qd,b_t_toan_qd,'','T',b_md,sysdate,b_idvung);
    b_loi:='loi:Loi Table TV_2:loi'; b_t_toan:=b_t_toan_qd-b_thue_qd; b_thue:=0;
    if b_t_toan<>0 then b_thue:=round(100.*b_thue_qd/b_t_toan,0); end if;
    insert into tv_2 values(b_ma_dvi,b_so_id,b_ngay_ht,'MAU','SERI','SO HD','','G','C','K','','','',b_k_ma_kh,b_ma_kh,'','','',
        b_nd,b_t_toan,'C','K',b_thue,b_thue_qd,b_t_toan_qd,'','',' ',1,b_idvung);
    b_loi:='';
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FKT_KH_TTT_HOI_ND
    (b_ma_dvi varchar2,b_ps varchar2,b_so_id varchar2,b_so_id_dt varchar2,b_ma varchar2) return nvarchar2
AS
    b_nd nvarchar2(2000);
begin
-- Dan - Tra noi dung cua thong tin them
select nvl(max(nd),' ') into b_nd from kt_kh_ttt_ct where ma_dvi=b_ma_dvi and so_id=b_so_id and so_id_dt=b_so_id_dt and ma=b_ma;
return b_nd;
end;
/
create or replace procedure PTV_TV_NH
    (b_idvung number,b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_ngay_ht number,b_ngay_bc number,
    b_htoan varchar2,b_so_id number,b_l_ct varchar2,b_ma_nt varchar2,b_tg_ht number,
    b_tg_tt number,b_thue number,b_t_toan number,b_thue_qd number,b_t_toan_qd number,
    a_bt_hd pht_type.a_num,a_mau pht_type.a_var,a_seri pht_type.a_var,a_so_hd pht_type.a_var,
    a_so_phu pht_type.a_var,a_kieu pht_type.a_var,a_lay pht_type.a_var,a_hoan pht_type.a_var,
    a_ma_hd pht_type.a_var,a_nhom pht_type.a_var,a_ngay_ct pht_type.a_var,
    a_k_ma_kh pht_type.a_var,a_ma_kh pht_type.a_var,a_ten pht_type.a_nvar,a_dchi pht_type.a_nvar,
    a_ma_thue pht_type.a_var,a_nd pht_type.a_nvar,a_tien pht_type.a_num,a_loai pht_type.a_var,
    a_pp pht_type.a_var,a_t_suat pht_type.a_num,a_thue pht_type.a_num,a_t_toan pht_type.a_num,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_ma_ctr pht_type.a_var,a_bt_ct pht_type.a_num,
    a_hang pht_type.a_nvar,a_dv pht_type.a_nvar,a_luong pht_type.a_num,a_gia pht_type.a_num,a_tien_h pht_type.a_num,b_loi out varchar2)
AS
    b_i1 number; b_log boolean;
begin
-- Dan - Nhap TV
if b_htoan='H' then
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','TV');
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'TV',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
    if b_l_ct in('R','T') then
        for b_lp in 1..a_so_hd.count loop
        if a_hoan(b_lp)='K' then
            b_i1:=b_lp-1; b_log:=true;
            for b_lp1 in 1..b_i1 loop
                if a_hoan(b_lp1)='K' and a_mau(b_lp1)=a_mau(b_lp) and a_seri(b_lp1)=a_seri(b_lp) and a_so_hd(b_lp1)=a_so_hd(b_lp) then
                    b_log:=false; exit;
                end if;
            end loop;
        end if;
        end loop;
    end if;
end if;
b_loi:='loi:Loi Table TV_1:loi';
insert into tv_1 values(b_ma_dvi,b_so_id,b_l_ct,b_ngay_ht,b_ngay_bc,b_ma_nt,b_tg_ht,b_tg_tt,
    b_thue,b_t_toan,b_thue_qd,b_t_toan_qd,b_nsd,b_htoan,b_md,sysdate,b_idvung);
b_loi:='loi:Loi Table TV_2:loi';
for b_lp in 1..a_bt_hd.count loop
    insert into tv_2 values(b_ma_dvi,b_so_id,b_ngay_ht,
        a_mau(b_lp),a_seri(b_lp),a_so_hd(b_lp),a_so_phu(b_lp),a_kieu(b_lp),a_lay(b_lp),a_hoan(b_lp),a_ma_hd(b_lp),a_nhom(b_lp),a_ngay_ct(b_lp),
        a_k_ma_kh(b_lp),a_ma_kh(b_lp),a_ten(b_lp),a_dchi(b_lp),a_ma_thue(b_lp),a_nd(b_lp),a_tien(b_lp),a_loai(b_lp),
        a_pp(b_lp),a_t_suat(b_lp),a_thue(b_lp),a_t_toan(b_lp),a_ma_tk(b_lp),a_ma_tke(b_lp),a_ma_ctr(b_lp),a_bt_hd(b_lp),b_idvung);
end loop;
b_loi:='loi:Loi Table TV_3:loi';
for b_lp in 1..a_bt_ct.count loop
    insert into tv_3 values(b_ma_dvi,b_so_id,a_bt_ct(b_lp),a_hang(b_lp),a_dv(b_lp),a_luong(b_lp),a_gia(b_lp),a_tien_h(b_lp),b_lp,b_idvung);
end loop;
if b_htoan='H' then
    PTV_DON(b_ma_dvi,b_so_id,'N',b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTV_DON(b_ma_dvi varchar2,b_so_id number,b_nv varchar2,b_loi out varchar2)
AS
    b_i1 number; b_kt number; b_nsd varchar2(10); b_ngay_ht number; b_l_ct varchar2(1);
    a_gcn_m pht_type.a_var; a_gcn_c pht_type.a_var; a_gcn_s pht_type.a_var;
begin 
-- Dan - Xoa
b_loi:=''; b_kt:=0; return;
select nsd,ngay_ht,l_ct into b_nsd,b_ngay_ht,b_l_ct from tv_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_l_ct in('R','T') then
    for r_lp in (select distinct mau,seri,so_hd from tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id and hoan='K') loop
        b_kt:=b_kt+1;
        a_gcn_m(b_kt):=r_lp.mau; a_gcn_c(b_kt):=r_lp.seri; a_gcn_s(b_kt):=r_lp.so_hd;
    end loop;
    if b_kt<>0 then
        PHD_PH_DON(b_ma_dvi,b_nv,b_ngay_ht,b_so_id,a_gcn_m,a_gcn_c,a_gcn_s,b_nsd,'',b_loi);
    end if;
end if;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PTV_CT_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    cs_1 out pht_type.cs_type,cs_2 out pht_type.cs_type,
    cs_3 out pht_type.cs_type,cs_4 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lk varchar2(100);
begin
-- Dan - Xem chi tiet cua 1 hoa don thue GTGT qua ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','TV','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select min(lk) into b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_1 for select a.*,b_lk lk from tv_1 a where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_2 for select * from tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_3 for select * from tv_3 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_4 for select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
end;
/
create or replace procedure PTV_TV_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2,b_dk varchar2:='K')
AS
    b_i1 number; b_nsd_c varchar2(10); b_ngay_ht number; b_htoan varchar2(1); b_l_ct varchar2(1);
begin
-- Dan - Xoa chung tu tien te
select count(*) into b_i1 from tv_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_loi:=''; return; end if;
select nsd,ngay_ht,htoan,l_ct into b_nsd_c,b_ngay_ht,b_htoan,b_l_ct from tv_1 where
    ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sql%rowcount<>1 then b_loi:='loi:Chung tu dang xu ly:loi'; return; end if;
if b_htoan='H' then
    if b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa chung tu nguoi khac:loi'; return; end if;
    if b_dk='C' and b_l_ct in ('R','T') then
        for r_lp in (select distinct hoan,kieu,bt from tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
            if r_lp.hoan='K' and r_lp.kieu='G' then
                PHDe_PS_XOA(b_ma_dvi,b_so_id,r_lp.bt,b_loi);
                if b_loi is not null then return; end if;
            end if;
        end loop;
    end if;
    b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','TV');
    if b_loi is not null then return; end if;
    PKH_NGAY_TD(b_ma_dvi,'TV',b_ngay_ht,b_loi);
    if b_loi is not null then return; end if;
    PTV_DON(b_ma_dvi,b_so_id,'X',b_loi);
    if b_loi is not null then return; end if;
end if;
b_loi:='loi:Loi Table TV_2:loi';
delete tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table TV_3:loi';
delete tv_3 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='loi:Loi Table TV_1:loi';
delete tv_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_LC_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_ngay_ht number;
begin
-- Dan - Liet ke luu chuyen tien te qua ID
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
delete ket_qua; commit;
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht into b_ngay_ht from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in(select nv,ma_tk,tien from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'LC','LC',b_ngay_ht,r_lp.nv,r_lp.ma_tk) then
        insert into ket_qua(c1,c2,n1) values(r_lp.nv,r_lp.ma_tk,r_lp.tien);
    end if;
end loop;
open cs1 for select c1 nv,c2 ma_tk,sum(n1) tien from ket_qua group by c1,c2;
open cs2 for select nv,ma_lc,tien,nsd from kt_lc where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHDe_PS_XOA
    (b_ma_dvi varchar2,b_so_id_ps number,b_bt_ps number,b_loi out varchar2)
AS
    b_so_id number; b_lan number; b_tt varchar2(1); b_ps varchar2(1);
begin
-- Dan - Xoa yeu cau cap hoa don
select nvl(max(lan),0) into b_lan from hde where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and bt_ps=b_bt_ps;
if b_lan=0 then
    b_loi:='loi:Hoa don da xoa:loi'; return;
elsif b_lan>1 then
    b_loi:='loi:Da cap hoa don:loi'; return;
else
    select so_id,tt,ps into b_so_id,b_tt,b_ps from hde where
        ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and bt_ps=b_bt_ps and lan=b_lan for update nowait;
    if sql%rowcount=0 then
        b_loi:='loi:Va cham NSD:loi'; return;
    elsif b_ps='H' then
        b_loi:='loi:Khong xoa da huy:loi'; return;
    elsif b_tt<>'1' then
        b_loi:='loi:Khong xoa da duyet:loi'; return;
    else
        delete hde where ma_dvi=b_ma_dvi and so_id=b_so_id;
        delete hde_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PKT_CT_LC_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    a_nv in out pht_type.a_var,a_ma_lc pht_type.a_var,a_tien pht_type.a_num,b_lk out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_tk number:=0; b_idvung number;
    b_ngay_ht number; b_hth varchar2(10); b_nsd_c varchar2(10); b_tt varchar2(1); b_c1 varchar2(1);
begin
-- Dan - Nhap luu chuyen
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','KT','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_loi:='loi:Chung tu dang xu ly:loi';
select ngay_ht,lk into b_ngay_ht,b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
if sqlcode<>0 or sql%rowcount=0 then raise PROGRAM_ERROR; end if;
if instr(b_lk,'LC')=0 then
    b_loi:='loi:Khong phai chung tu luu chuyen tien te:loi'; raise PROGRAM_ERROR;
end if;
b_loi:=PKH_MA_HAN_TEST(b_ma_dvi,b_ngay_ht,'KT','KT');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for r_lp in (select nv,ma_tk,tien from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if PKH_MA_LCT_TRA_LQ(b_ma_dvi,'LC','LC',b_ngay_ht,r_lp.nv,r_lp.ma_tk) then
        if r_lp.nv='N' then b_tk:=b_tk+r_lp.tien; else b_tk:=b_tk-r_lp.tien; end if;
    end if;
end loop;
PKH_MANG(a_nv);
for b_lp in 1..a_nv.count loop
    if a_nv(b_lp) is null or a_nv(b_lp) not in('N','C') or a_ma_lc(b_lp) is null or
        trim(a_ma_lc(b_lp)) is null or a_tien(b_lp) is null or a_tien(b_lp)=0 then
        b_loi:='loi:Sai so lieu dong#'||to_char(b_lp)||':loi';
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
    b_loi:='loi:Sai ma luu chuyen tien te#'||trim(a_ma_lc(b_lp))||':loi';
    select tc into b_c1 from kt_ma_lc where ma_dvi=b_ma_dvi and ma=a_ma_lc(b_lp);
    if b_c1='G' then raise PROGRAM_ERROR; end if;
    if a_nv(b_lp)='N' then b_tk:=b_tk-a_tien(b_lp); else b_tk:=b_tk+a_tien(b_lp); end if;
end loop;
delete kt_lc where ma_dvi=b_ma_dvi and so_id=b_so_id;
for b_lp in 1..a_nv.count loop
    insert into kt_lc values(b_ma_dvi,b_so_id,b_lp,b_ngay_ht,a_nv(b_lp),a_ma_lc(b_lp),a_tien(b_lp),b_nsd,b_idvung);
end loop;
if b_tk=0 then b_tt:='2';
elsif a_nv.count<>0 then b_tt:='1';
else b_tt:='0';
end if;
PKT_LKET_NV(b_ma_dvi,'LC',b_so_id,b_tt,b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PKH_NGAY_TD(b_ma_dvi,'KT',b_ngay_ht,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PTV_CT_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_ngay_ht number,b_ngay_bc number,b_htoan varchar2,
    b_so_id in out number,b_l_ct varchar2,b_ma_nt varchar2,b_tg_ht number,b_tg_tt number,b_thue_qd number,b_t_toan_qd number,
    a_bt_hd pht_type.a_num,a_mau pht_type.a_var,a_seri pht_type.a_var,a_so_hd pht_type.a_var,
    a_so_phu pht_type.a_var,a_kieu pht_type.a_var,a_lay pht_type.a_var,a_hoan pht_type.a_var,
    a_ma_hd pht_type.a_var,a_nhom pht_type.a_var,a_ngay_ct pht_type.a_var,
    a_k_ma_kh pht_type.a_var,a_ma_kh pht_type.a_var,a_ten pht_type.a_nvar,a_dchi pht_type.a_nvar,
    a_ma_thue pht_type.a_var,a_nd pht_type.a_nvar,a_tien_hd pht_type.a_num,a_loai pht_type.a_var,
    a_pp pht_type.a_var,a_t_suat pht_type.a_num,a_thue pht_type.a_num,a_t_toan pht_type.a_num,
    a_ma_tk pht_type.a_var,a_ma_tke pht_type.a_var,a_ma_ctr pht_type.a_var,a_bt_ct in out pht_type.a_num,
    a_hang pht_type.a_nvar,a_dv pht_type.a_nvar,a_luong pht_type.a_num,a_gia pht_type.a_num,a_tien_h pht_type.a_num,
    a_nv in out pht_type.a_var,a_ma_tk_ht in out pht_type.a_var,a_ma_tke_ht in out pht_type.a_var,
    a_tien in out pht_type.a_num,a_note pht_type.a_nvar,a_bt pht_type.a_num,b_lk out varchar2,b_cbao out varchar2)
AS
    b_loi varchar2(100); b_i1 number; b_md varchar2(2); b_thue number; b_t_toan number;
    b_idvung number; b_so_ct varchar2(30):=''; b_nd nvarchar2(500); b_l_ctK varchar2(20); b_l_ctC varchar2(5);
    a_bt_hdC pht_type.a_num; a_mauC pht_type.a_var; a_seriC pht_type.a_var; a_so_hdC pht_type.a_var;
begin
-- Dan - Nhap hoa don thue GTGT
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'KT','TV','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_so_id is null then b_loi:='loi:Nhap so ID chung tu:loi'; raise PROGRAM_ERROR; end if;
PKH_MANG(a_nv); PKH_MANG_N(a_bt_ct); PKH_MANG_KD_N(a_bt_hdC);
if b_so_id=0 then
    b_md:='TV'; PHT_ID_MOI(b_so_id,b_loi);
else
    select count(*),nvl(min(md),'TV'),min(l_ct) into b_i1,b_md,b_l_ctC from tv_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        if b_l_ctC in('R','T') then
            b_i1:=0;
            for r_lp in (select distinct hoan,kieu,mau,seri,so_hd,bt from tv_2 where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
                if r_lp.hoan='K' and r_lp.kieu='E' then
                    b_i1:=b_i1+1;
                    a_bt_hdC(b_i1):=r_lp.bt; a_mauC(b_i1):=r_lp.mau; a_seriC(b_i1):=r_lp.seri; a_so_hdC(b_i1):=r_lp.so_hd;
                end if;
            end loop;
        end if;
        PTV_TV_XOA(b_ma_dvi,b_nsd,b_so_id,b_loi);
    end if;
end if;
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTV_CT_TEST(b_ma_dvi,b_nsd,b_md,b_ngay_ht,b_ngay_bc,b_htoan,b_l_ct,b_ma_nt,b_tg_ht,b_tg_tt,b_thue_qd,b_t_toan_qd,
    a_bt_hd,a_mau,a_seri,a_so_hd,a_so_phu,a_kieu,a_lay,a_hoan,a_ma_hd,a_nhom,a_ngay_ct,a_k_ma_kh,a_ma_kh,
    a_tien_hd,a_loai,a_pp,a_t_suat,a_thue,a_t_toan,a_ma_tk,a_ma_tke,a_ma_ctr,b_thue,b_t_toan,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PTV_TV_NH(b_idvung,b_ma_dvi,b_nsd,b_md,b_ngay_ht,b_ngay_bc,b_htoan,b_so_id,b_l_ct,b_ma_nt,
    b_tg_ht,b_tg_tt,b_thue,b_t_toan,b_thue_qd,b_t_toan_qd,
    a_bt_hd,a_mau,a_seri,a_so_hd,a_so_phu,a_kieu,a_lay,a_hoan,a_ma_hd,a_nhom,a_ngay_ct,a_k_ma_kh,
    a_ma_kh,a_ten,a_dchi,a_ma_thue,a_nd,a_tien_hd,a_loai,a_pp,a_t_suat,a_thue,
    a_t_toan,a_ma_tk,a_ma_tke,a_ma_ctr,a_bt_ct,a_hang,a_dv,a_luong,a_gia,a_tien_h,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_l_ct in('R','T') then
    for b_lp in 1..a_bt_hd.count loop
        if a_hoan(b_lp)='K' and a_kieu(b_lp)='E' then
            PHDe_PS_NH(b_ma_dvi,b_nsd,'KT','TV','D',b_so_id,a_bt_hd(b_lp),b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
        end if;
    end loop;
end if;
if b_l_ctC in('R','T') and a_bt_hdC.count<>0 then
    if b_l_ct not in('R','T') then
        for b_lp in 1..a_bt_hdC.count loop
            PHDe_PS_HUY(b_ma_dvi,b_so_id,a_bt_hdC(b_lp),b_loi);
            if b_loi is not null then raise PROGRAM_ERROR; end if;
        end loop;
    else
        for b_lp in 1..a_bt_hdC.count loop
            b_i1:=0;
            for b_lp1 in 1..a_bt_hd.count loop
                if a_bt_hd(b_lp1)=a_bt_hdC(b_lp) then b_i1:=1; exit; end if;
            end loop;
            if b_i1=0 then
                PHDe_PS_HUY(b_ma_dvi,b_so_id,a_bt_hdC(b_lp),b_loi);
                if b_loi is not null then raise PROGRAM_ERROR; end if;
            end if;
        end loop;
    end if;
end if;
select count(*),min(l_ct),nvl(min(nd),' ') into b_i1,b_l_ctK,b_nd from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1=0 then b_l_ctK:=b_l_ct; end if;
PKT_CT_NV_XL(b_ma_dvi,b_nsd,b_htoan,b_ngay_ht,b_so_id,b_l_ct,b_so_ct,PKH_SO_CNG(b_ngay_ht),b_nd,
    a_nv,a_ma_tk_ht,a_ma_tke_ht,a_tien,a_note,a_bt,b_md,'TV',b_lk,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_htoan='H' then
    b_cbao:=FKT_KH_CBAO(b_ma_dvi,b_ngay_ht,a_ma_tk);
    if instr(b_cbao,'loi:')=1 then b_loi:=b_cbao; raise PROGRAM_ERROR; end if;
end if;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHDe_PS_NH
    (b_ma_dvi varchar2,b_nsd varchar2,b_md varchar2,b_nv varchar2,b_psN varchar2,b_so_id_ps number,b_bt_ps number,b_loi out varchar2)
AS
    b_i1 number; b_so_id number; b_tt varchar2(1); b_ps varchar2(5); b_lan number; b_ngay_ps varchar2(20);
begin
-- Dan - Nhap yeu cau cap hoa don
FHDe_PS_TTIN(b_ma_dvi,b_md,b_nv,b_so_id_ps,b_bt_ps,b_loi);
if b_loi is not null then return; end if;
select nvl(max(lan),0) into b_lan from hde where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and bt_ps=b_bt_ps;
if b_lan=0 then
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then return; end if;
    b_lan:=1;
else
    select so_id,tt,ps into b_so_id,b_tt,b_ps from hde where
        ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and bt_ps=b_bt_ps and lan=b_lan for update nowait;
    if sql%rowcount=0 then
        b_loi:='loi:Va cham NSD:loi'; return;
    elsif b_ps='H' then
         b_loi:='loi:Khong sua da huy:loi'; return;
    elsif b_tt='1' then
        delete hde where ma_dvi=b_ma_dvi and so_id=b_so_id;
        delete hde_hang where ma_dvi=b_ma_dvi and so_id=b_so_id;
    else
        PHT_ID_MOI(b_so_id,b_loi);
        if b_loi is not null then return; end if;
        b_lan:=b_lan+1;
    end if;
end if;
if b_lan=1 then b_ps:='M'; else b_ps:=b_psN; end if;
b_ngay_ps:=to_char(SYSDATE,'DD/MM/YYYY HH24:MI:SS');
insert into hde select b_ma_dvi,b_so_id,b_md,b_nv,b_ps,b_so_id_ps,b_bt_ps,b_lan,
    ngay,kieu,so_ct,ma_kh,ten,dchi,tax,ma_nt,tg,nd,tien,tsuat,thue,ttoan,
    tien_qd,thue_qd,ttoan_qd,b_ngay_ps,b_nsd,'1','01-jan-3000',' ','01-jan-3000',' ',' ' from hde_temp_ch;
insert into hde_hang select b_ma_dvi,b_so_id,ma,ten,dvi,gia,luong,tien,tsuat,thue,ttoan,gia_qd,tien_qd,thue_qd,ttoan_qd from hde_temp_hang;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PHDe_PS_HUY
    (b_ma_dvi varchar2,b_so_id_ps number,b_bt_ps number,b_loi out varchar2)
AS
    b_so_hd varchar2(50); b_so_id number; b_lan number; b_ngay_ps date:=sysdate; 
    r_hd hde%rowtype;
begin
-- Dan - Huy hoa don
select nvl(max(lan),0),max(so_hd) into b_lan,b_so_hd from hde where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and bt_ps=b_bt_ps;
if b_lan=0 then
    b_loi:='loi:Hoa don da xoa:loi'; return;
else
    select * into r_hd from hde where ma_dvi=b_ma_dvi and so_id_ps=b_so_id_ps and bt_ps=b_bt_ps and lan=b_lan for update nowait;
    if sql%rowcount=0 then
        b_loi:='loi:Va cham NSD:loi'; return;
    elsif r_hd.ps='H' then
        b_loi:='loi:Da huy:loi'; return;
    elsif r_hd.tt='1' then
        PHDe_PS_XOA(b_ma_dvi,b_so_id_ps,b_bt_ps,b_loi);
        return;
    end if;
    b_lan:=r_hd.lan+1; 
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then return; end if;
    if trim(b_so_hd) is null then
        insert into hde values(b_ma_dvi,b_so_id,r_hd.md,r_hd.nv,'H',r_hd.kieu,b_so_id_ps,b_bt_ps,b_lan,r_hd.ngay,r_hd.so_ct,r_hd.ma_kh,r_hd.ten,
            r_hd.dchi,r_hd.tax,r_hd.ma_nt,r_hd.tg,r_hd.nd,r_hd.tien,r_hd.tsuat,r_hd.thue,r_hd.ttoan,
            r_hd.tien_qd,r_hd.thue_qd,r_hd.ttoan_qd,b_ngay_ps,r_hd.nsd,'4',b_ngay_ps,' ',b_ngay_ps,' ',' ');
    else
        insert into hde values(b_ma_dvi,b_so_id,r_hd.md,r_hd.nv,'H',r_hd.kieu,b_so_id_ps,b_bt_ps,b_lan,r_hd.ngay,r_hd.so_ct,r_hd.ma_kh,r_hd.ten,
            r_hd.dchi,r_hd.tax,r_hd.ma_nt,r_hd.tg,r_hd.nd,r_hd.tien,r_hd.tsuat,r_hd.thue,r_hd.ttoan,
            r_hd.tien_qd,r_hd.thue_qd,r_hd.ttoan_qd,b_ngay_ps,r_hd.nsd,'2','01-jan-3000',' ','01-jan-3000',' ',' ');
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure FHDe_PS_TTIN(
    b_ma_dvi varchar2,b_md varchar2,b_nv varchar2,b_so_id number,b_bt number,b_loi out nvarchar2)
AS
    b_lenh varchar2(1000);
begin
-- Dan -- Tra thong tin
delete hde_temp_ch; delete hde_temp_hang;

b_lenh:='begin PHDe_'||b_md||'_'||b_nv||'(:ma_dvi,:so_id,:bt,:loi); end;';
execute immediate b_lenh using b_ma_dvi,b_so_id,b_bt,out b_loi;
end;
/
CREATE OR REPLACE PROCEDURE PKT_MA_TK_MA
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
    b_ma varchar2,b_trangkt number,b_trang out number,b_dong out number,cs_lke out pht_type.cs_type)
AS
    b_loi varchar2(100); b_tu number; b_den number;
begin
-- Dan - Xem Ma
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','KT','MNX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_ma is null then b_loi:='loi:Nhap ma:loi'; raise PROGRAM_ERROR; end if;
select count(*) into b_dong from kt_ma_tk where ma_dvi=b_ma_dvi;
select nvl(min(sott),b_dong) into b_tu from (select ma,row_number() over (order by ma) sott
    from kt_ma_tk where ma_dvi=b_ma_dvi order by ma) where ma>=b_ma;
PKH_LKE_VTRI(b_trangkt,b_tu,b_den,b_trang);
open cs_lke for select * from (select ma,ten,row_number() over (order by ma) sott from kt_ma_tk
    where ma_dvi=b_ma_dvi order by ma) where sott between b_tu and b_den;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PCN_CT_ID
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_so_id number,
    cs_1 out pht_type.cs_type,cs_2 out pht_type.cs_type,cs_3 out pht_type.cs_type,cs_4 out pht_type.cs_type,cs_5 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_lk varchar2(100);
begin
-- Dan - Xem chi tiet cua 1 chung tu cong no qua ID
delete cn_tt_temp; delete cn_tt_ps_temp; delete cn_tt_ch_temp; commit;

b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'KT','CN','NX');
if b_loi is not null then raise_application_error(-20105,b_loi); end if;
select min(lk) into b_lk from kt_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_1 for select a.*,b_lk lk from cn_ch a where ma_dvi=b_ma_dvi and so_id=b_so_id;
open cs_2 for select a.*,FCN_TK_MA(ma_dvi,ngay_ht,ma_tk) l_cn
    from cn_ct a where ma_dvi=b_ma_dvi and so_id=b_so_id order by bt;
open cs_3 for select * from cn_ls where ma_dvi=b_ma_dvi and so_id=b_so_id order by ngay;
insert into cn_tt_temp select * from cn_tt where ma_dvi=b_ma_dvi and so_id=b_so_id;
for r_lp in (select so_id_ps,bt_ps from cn_tt_temp) loop
    insert into cn_tt_ps_temp select so_id,bt,ngay_ht,nd,tien,tien_qd from cn_ps
        where ma_dvi=b_ma_dvi and so_id=r_lp.so_id_ps and bt=r_lp.bt_ps;
    insert into cn_tt_ch_temp select so_id,so_ct,nd,htoan,nsd from cn_ch where ma_dvi=b_ma_dvi and so_id=r_lp.so_id_ps;
end loop;
open cs_4 for select distinct a.bt_tt bt,a.so_id_ps,a.bt_ps,b.ngay_ht,c.so_ct,b.nd,a.tien,a.tien_qd,b.ton,b.ton_qd,a.phi,a.phi_qd
    from cn_tt_temp a,cn_tt_ps_temp b,cn_tt_ch_temp c where b.so_id=a.so_id_ps and b.bt=a.bt_ps and c.so_id=a.so_id_ps;
open cs_5 for select * from kt_2 where ma_dvi=b_ma_dvi and so_id=b_so_id;
delete cn_tt_temp; delete cn_tt_ps_temp; delete cn_tt_ch_temp; commit;
end;
/
create or replace procedure PBH_HD_GOC_TINH_CT
    (b_ma_dvi varchar2,b_ngay_ht number,a_lh_nv pht_type.a_var,a_k_phi pht_type.a_var,
    a_nt_phi pht_type.a_var,a_phi pht_type.a_num,a_k_thue out pht_type.a_var,
    a_c_thue out pht_type.a_var,a_t_suat out pht_type.a_num,a_thue out pht_type.a_num,
    a_ttoan out pht_type.a_num,a_phi_dt out pht_type.a_num,b_loi out varchar2)
AS
    b_t number:=0; b_i1 number:=1; b_nt varchar2(1):='C'; b_noite varchar2(5); b_tp number;
begin
-- Dan - Tinh phi d.thu, thue, t.toan theo loai hinh nghiep vu
b_noite:=FTT_TRA_NOITE(b_ma_dvi);
for b_lp in 1..a_lh_nv.count loop
    if a_lh_nv(b_lp) is not null then   
--         PBH_MA_LHNV_THUE(b_ma_dvi,a_lh_nv(b_lp),b_ngay_ht,a_k_thue(b_lp),a_c_thue(b_lp),a_t_suat(b_lp),b_loi);
        if b_loi is not null then return; end if;
        if b_noite=a_nt_phi(b_lp) then b_tp:=0; else b_tp:=2; end if;
        if a_k_phi(b_lp)='K' then a_c_thue(b_lp):='K'; end if;
--         PBPBH_HD_GOC_TINH_CTH_TINH_THUE(a_phi(b_lp),a_k_phi(b_lp),a_c_thue(b_lp),a_k_thue(b_lp),a_t_suat(b_lp),b_tp,a_thue(b_lp),a_phi(b_lp));
        a_ttoan(b_lp):=a_phi(b_lp)+a_thue(b_lp);
        if b_noite<>a_nt_phi(b_lp) then
            b_nt:='K';
        else
            b_t:=b_t+a_ttoan(b_lp);
            if a_ttoan(b_lp)>a_ttoan(b_i1) then b_i1:=b_lp; end if;
        end if;
   else
        a_k_thue(b_lp):='K'; a_c_thue(b_lp):='C'; a_t_suat(b_lp):=0; a_thue(b_lp):=0; a_phi_dt(b_lp):=0; a_ttoan(b_lp):=0;
   end if;
end loop;
if b_nt='C' then
    b_t:=b_t-round(b_t,-3);
    if b_t<>0 then
        a_ttoan(b_i1):=a_ttoan(b_i1)-b_t;
        a_phi_dt(b_i1):=a_phi_dt(b_i1)-b_t;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace function FTBH_GD_TXT(b_ma_dvi varchar2,b_so_id_tt number,b_tim varchar2) return nvarchar2
AS
    b_kq nvarchar2(500):=' '; b_i1 number; b_txt clob;
begin
-- Dan
select count(*) into b_i1 from bh_bt_gd_hs_tt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt and loai='dt_ct';
if b_i1=1 then
    select txt into b_txt from bh_bt_gd_hs_tt_txt where ma_dvi=b_ma_dvi and so_id=b_so_id_tt and loai='dt_ct';
    b_kq:=FKH_JS_GTRIu(b_txt,b_tim);
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_GOC_TINH_CT
    (b_ma_dvi varchar2,b_ngay_ht number,a_lh_nv pht_type.a_var,a_k_phi pht_type.a_var,
    a_nt_phi pht_type.a_var,a_phi pht_type.a_num,a_k_thue out pht_type.a_var,
    a_c_thue out pht_type.a_var,a_t_suat out pht_type.a_num,a_thue out pht_type.a_num,
    a_ttoan out pht_type.a_num,a_phi_dt out pht_type.a_num,b_loi out varchar2)
AS
    b_t number:=0; b_i1 number:=1; b_nt varchar2(1):='C'; b_noite varchar2(5); b_tp number;
begin
-- Dan - Tinh phi d.thu, thue, t.toan theo loai hinh nghiep vu
b_noite:=FTT_TRA_NOITE(b_ma_dvi);
for b_lp in 1..a_lh_nv.count loop
    if a_lh_nv(b_lp) is not null then   
--         PBH_MA_LHNV_THUE(b_ma_dvi,a_lh_nv(b_lp),b_ngay_ht,a_k_thue(b_lp),a_c_thue(b_lp),a_t_suat(b_lp),b_loi);
        if b_loi is not null then return; end if;
        if b_noite=a_nt_phi(b_lp) then b_tp:=0; else b_tp:=2; end if;
        if a_k_phi(b_lp)='K' then a_c_thue(b_lp):='K'; end if;
--         PBPBH_HD_GOC_TINH_CTH_TINH_THUE(a_phi(b_lp),a_k_phi(b_lp),a_c_thue(b_lp),a_k_thue(b_lp),a_t_suat(b_lp),b_tp,a_thue(b_lp),a_phi(b_lp));
        a_ttoan(b_lp):=a_phi(b_lp)+a_thue(b_lp);
        if b_noite<>a_nt_phi(b_lp) then
            b_nt:='K';
        else
            b_t:=b_t+a_ttoan(b_lp);
            if a_ttoan(b_lp)>a_ttoan(b_i1) then b_i1:=b_lp; end if;
        end if;
   else
        a_k_thue(b_lp):='K'; a_c_thue(b_lp):='C'; a_t_suat(b_lp):=0; a_thue(b_lp):=0; a_phi_dt(b_lp):=0; a_ttoan(b_lp):=0;
   end if;
end loop;
if b_nt='C' then
    b_t:=b_t-round(b_t,-3);
    if b_t<>0 then
        a_ttoan(b_i1):=a_ttoan(b_i1)-b_t;
        a_phi_dt(b_i1):=a_phi_dt(b_i1)-b_t;
    end if;
end if;
b_loi:='';
exception when others then if b_loi is null then raise PROGRAM_ERROR; else null; end if;
end;
/
create or replace procedure PBH_DKBS_TINH
	(b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,
	b_so_hd_g varchar2,b_ngay_ht number,b_nt_phi varchar2,
	a_lh_nv pht_type.a_var,a_k_phi pht_type.a_var,a_phi pht_type.a_num,b_thue out number,b_ttoan out number)
AS
	b_loi varchar2(200); b_ngay_phi number;
	a_nt_phi pht_type.a_var; a_phi_dt pht_type.a_num; a_thue pht_type.a_num;
	a_ttoan pht_type.a_num; a_k_thue pht_type.a_var; a_c_thue pht_type.a_var; a_t_suat pht_type.a_num;
begin
-- Dan - Tinh tong phi
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for b_lp in 1..a_lh_nv.count loop
	a_nt_phi(b_lp):=b_nt_phi;
end loop;
b_ngay_phi:=FBH_HD_NGAY_DAU(b_ma_dvi,b_so_hd_g,b_ngay_ht);
PBH_HD_GOC_TINH_CT(b_ma_dvi,b_ngay_phi,a_lh_nv,a_k_phi,a_nt_phi,a_phi,a_k_thue,a_c_thue,a_t_suat,a_thue,a_ttoan,a_phi_dt,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_thue:=0; b_ttoan:=0;
for b_lp in 1..a_lh_nv.count loop
	b_thue:=b_thue+a_thue(b_lp); b_ttoan:=b_ttoan+a_ttoan(b_lp);
end loop;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_GOPH_NH(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob,b_comm varchar2:='C')
AS
    b_loi varchar2(3000); b_lenh varchar2(2000); b_i1 number;
    dt_ct clob; dt_hd clob; dt_kytt clob;
-- Chung
    b_so_id number; b_so_hd varchar2(20); b_ngay_ht number; b_ttrang varchar2(1); b_kieu_hd varchar2(1); b_so_hd_g varchar2(20); 
    b_kieu_kt varchar2(1); b_ma_kt varchar2(20); b_kieu_gt varchar2(1); b_ma_gt varchar2(20); b_ma_cb varchar2(20); 
    b_so_hdL varchar2(20); b_loai_kh varchar2(1); b_ma_kh varchar2(20); b_ten nvarchar2(500); b_dchi nvarchar2(500); 
    b_cmt varchar2(20); b_mobi varchar2(20); b_email varchar2(50); 
    b_gio_hl varchar2(20); b_ngay_hl number; b_gio_kt varchar2(20); b_ngay_kt number; b_ngay_cap number; 
    b_nt_tien varchar2(5); b_nt_phi varchar2(5); b_c_thue varchar2(1); 
    b_tl_giam number; b_phi number; b_giam number; b_thue number; b_ttoan number; b_hhong number;
    b_so_idG number; b_so_idD number; b_ngayD number; b_phong varchar2(10); 
    tt_ngay pht_type.a_num; tt_tien pht_type.a_num; 
-- Rieng
    hd_so_id_kem pht_type.a_num; hd_nv pht_type.a_var; hd_loai pht_type.a_var;
    hd_so_kem pht_type.a_var; hd_ttrang pht_type.a_var;
    hd_tien pht_type.a_num; hd_phi pht_type.a_num; hd_thue pht_type.a_num;
-- Xu ly
    b_ngay_htC number;
begin
-- Dan - Nhap
if b_comm='C' then
    b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','GOP','N',b_comm);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
b_so_id:=FKH_JS_GTRIn(b_oraIn,'so_id');
b_lenh:=FKH_JS_LENHc('dt_ct,dt_hd,dt_kytt');
EXECUTE IMMEDIATE b_lenh into dt_ct,dt_hd,dt_kytt using b_oraIn;
if b_so_id<>0 then
    select count(*) into b_i1 from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then
        select ngay_ht,kieu_hd,ttrang into b_ngay_htC,b_kieu_hd,b_ttrang from bh_gop where ma_dvi=b_ma_dvi and so_id=b_so_id for update nowait;
        if sql%rowcount=0 then b_loi:='loi:Va cham NSD:loi'; raise PROGRAM_ERROR; end if;
        if b_ttrang not in('T','D') then b_kieu_hd:='X'; else b_kieu_hd:='N'; end if;
        --PBH_GOP_XOA_XOA(b_ma_dvi,b_nsd,b_so_id,b_kieu_hd,b_loi);
        if b_loi is not null then raise PROGRAM_ERROR; end if;
    end if;
else
    PHT_ID_MOI(b_so_id,b_loi);
    if b_loi is not null then raise PROGRAM_ERROR; end if;
end if;
PBH_HD_JS_TEST(
    b_ma_dvi,b_nsd,b_so_id,b_ngay_htC,'bh_gop',dt_ct,dt_kytt,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_loai_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,
    b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,b_so_idG,b_so_idD,b_ngayD,b_phong,b_ma_cb,b_ma_kh,
    tt_ngay,tt_tien,b_loi,'GOP');
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_GOPH_TESTr(
    b_ma_dvi,b_nsd,b_so_idG,dt_ct,dt_hd,
    hd_so_id_kem,hd_nv,hd_loai,hd_so_kem,hd_ttrang,hd_tien,hd_phi,hd_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
PBH_GOPH_NH_NH(
    b_ma_dvi,b_nsd,b_so_id,
    dt_ct,dt_hd,
    b_so_hd,b_ngay_ht,b_ttrang,b_kieu_hd,b_so_hd_g,b_kieu_kt,b_ma_kt,b_kieu_gt,b_ma_gt,b_ma_cb,b_so_hdL,
    b_loai_kh,b_ma_kh,b_ten,b_dchi,b_cmt,b_mobi,b_email,
    b_gio_hl,b_ngay_hl,b_gio_kt,b_ngay_kt,b_ngay_cap,b_nt_tien,b_nt_phi,b_c_thue,b_phi,b_giam,b_thue,b_ttoan,b_hhong,
    b_so_idG,b_so_idD,b_ngayD,b_phong,
    tt_ngay,tt_tien,
    hd_so_id_kem,hd_nv,hd_loai,hd_so_kem,hd_ttrang,hd_tien,hd_phi,hd_thue,b_loi);
if b_loi is not null then raise PROGRAM_ERROR; end if;
if b_comm='C' then commit; end if;
select json_object('ma_dvi' value b_ma_dvi,'so_id' value b_so_id,'so_hd' value b_so_hd, 'ma_kh' value b_ma_kh) into b_oraOut from dual;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FTBH_TMC_CBI_TT(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(1):='K'; b_i1 number; b_phai_xl varchar2(1); b_kieu_xl varchar2(1);
begin
-- Dan - Tra tinh trang phai ghep tai
select min(phai_xl),min(kieu_xl),count(*) into b_phai_xl,b_kieu_xl,b_i1
    from tbh_tmC_cbi where ma_dvi_hd=b_ma_dvi and so_id_hd=b_so_id;
if b_i1<>0 then
    if b_kieu_xl='C' and b_phai_xl='C' then b_kq:='D'; else b_kq:='V'; end if;
end if;
return b_kq;
end;
/
create or replace procedure PBH_HD_TTRANG_HD(b_ma_dvi varchar2,b_so_idN number,cs1 out pht_type.cs_type)
AS
    b_loi varchar2(100); b_nv varchar2(10);
    b_so_id number:=b_so_idN; b_i1 number; b_tt varchar2(1); b_thue varchar2(1); b_hhong varchar2(1);
begin
-- Dan - Trang thai hop dong
delete bh_hd_ttrang_temp; delete bh_hd_do_vat_temp1; delete bh_hd_do_vat_temp2; delete bh_hd_do_vat_temp3; commit;
b_so_id:=FBH_HD_SO_ID_DAU(b_ma_dvi,b_so_idN);
b_tt:='X';
select count(*) into b_i1 from bh_hd_goc_sc_phi_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then b_tt:='D';
else
    select count(*) into b_i1 from bh_hd_goc_sc_no_ton where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then b_tt:='V'; end if;
end if;
if b_tt<>'X' then insert into bh_hd_ttrang_temp values('tt_phi',b_tt); end if;
b_thue:='X'; b_hhong:='X';
for r_lp in(select distinct so_id_tt from bh_hd_goc_tthd where ma_dvi=b_ma_dvi and so_id=b_so_id) loop
    if b_thue='X' then
        select count(*) into b_i1 from bh_hd_goc_sc_vat where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt;
        if b_i1<>0 then b_thue:='D'; end if;
    end if;
    if b_hhong='X' then
        select count(*) into b_i1 from bh_hd_goc_sc_hh where ma_dvi=b_ma_dvi and so_id_tt=r_lp.so_id_tt;
        if b_i1<>0 then b_hhong:='D'; end if;
    end if;
end loop;
if b_thue<>'X' then insert into bh_hd_ttrang_temp values('tt_thue',b_thue); end if;
if b_hhong<>'X' then insert into bh_hd_ttrang_temp values('tt_hhong',b_hhong); end if;
if FBH_HD_HU(b_ma_dvi,b_so_id)='C' then
    insert into bh_hd_ttrang_temp values('hd_huy','D');
end if;
select count(*) into b_i1 from bh_hd_do_tl where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tle','V'); end if;
if FBH_DONG(b_ma_dvi,b_so_id)<>'G' then
    select count(*) into b_i1 from bh_hd_do_sc_ps where ma_dvi=b_ma_dvi and so_id=b_so_id;
    if b_i1<>0 then insert into bh_hd_ttrang_temp values('do_tt','D'); end if;
    if FBH_HD_DO_VAT_TONh(b_ma_dvi,b_so_id)='C' then
        insert into bh_hd_ttrang_temp values('do_vat','D');
    end if;
end if;
select count(*) into b_i1 from bh_bt_hs where ma_dvi=b_ma_dvi and so_id_hd=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('bt_hs','V'); end if;
select count(*) into b_i1 from bh_bt_ho where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then insert into bh_hd_ttrang_temp values('bt_ho','V'); end if;
b_tt:=FTBH_TMC_CBI_TT(b_ma_dvi,b_so_id);
if b_tt<>'K' then
    insert into bh_hd_ttrang_temp values('ta_pbo',b_tt);
end if;
open cs1 for select * from bh_hd_ttrang_temp;
delete bh_hd_ttrang_temp; delete bh_hd_do_vat_temp1;
delete bh_hd_do_vat_temp2; delete bh_hd_do_vat_temp3; commit;
end;
/
create or replace procedure PBH_PTNCC_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(10); b_lbh varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,lbh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_lbh using b_oraIn;
b_lbh:=nvl(b_lbh,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
      join bh_ptn t1 on t.so_id = t1.so_id
      join bh_ptn_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC and t1.nv='TNCC';
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
         join bh_ptn t1 on t.so_id = t1.so_id
         join bh_ptn_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv='TNCC'
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNNN_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(10); b_lbh varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,lbh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_lbh using b_oraIn;
b_lbh:=nvl(b_lbh,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
      join bh_ptn t1 on t.so_id = t1.so_id
      join bh_ptn_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC and t1.nv='TNNN';
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
         join bh_ptn t1 on t.so_id = t1.so_id
         join bh_ptn_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv='TNNN'
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_PTNVC_TIM_IMP(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob,b_oraOut out clob)
AS
    b_i1 number; b_loi varchar2(2000); b_lenh varchar2(2000); cs_lke clob:='';
    b_so_id number;  b_so_idC number; b_so_hd_c varchar2(40); b_so_hd varchar2(40);
    b_dong number; b_ngay number:=PKH_NG_CSO(add_months(sysdate,-36));
    b_ngayD number; b_ngayC number;
    b_ten nvarchar2(200); b_phong varchar2(10); b_nv varchar2(10); b_lbh varchar2(1);
    b_tu number; b_den number;
begin
-- viet anh
delete ket_qua; delete temp_1; commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','PTN','NX');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_lenh:=FKH_JS_LENH('ngayd,ngayc,so_hd_c,tu,den,lbh');
EXECUTE IMMEDIATE b_lenh into b_ngayD,b_ngayC,b_so_hd_c,b_tu,b_den,b_lbh using b_oraIn;
b_lbh:=nvl(b_lbh,'G'); b_so_hd_c:=nvl(trim(b_so_hd_c),' ');
if b_ngayD in (0,30000101) then b_ngayD:=b_ngay; end if;
if b_ngayC=0 then b_ngayC:=30000101; end if;
if trim(b_so_hd_c) is not null then
  insert into temp_1(n1) select so_id from bh_hd_map where ma_dvi = b_ma_dvi and so_hd_c = b_so_hd_c;
  for r_lp in (select distinct(t.n1) so_id_d from temp_1 t) loop
    b_so_idC:=FBH_PTN_SO_IDc(b_ma_dvi,r_lp.so_id_d);
    insert into ket_qua(c1,c2,c3,n1,n2,n3,n4)
    select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
      join bh_ptn t1 on t.so_id = t1.so_id
      join bh_ptn_dvi t2 on t.so_id = t2.so_id
    where t.so_id = b_so_idC and t.so_hd_c = b_so_hd_c and t1.ngay_ht between b_ngayD and b_ngayC and t1.nv='TNVC';
  end loop;
else
  -- lay all theo dieu kien
  insert into ket_qua(c1,c2,c3,n1,n2,n3,n4)
  select t1.so_hd,t.so_hd_c,t2.gcn,t1.ngay_hl,t1.ngay_kt,t1.ngay_cap,t.so_id
    from bh_hd_map t
         join bh_ptn t1 on t.so_id = t1.so_id
         join bh_ptn_dvi t2 on t.so_id = t2.so_id
   where t.ma_dvi = b_ma_dvi
     and t1.nv='TNVC'
     and t1.ngay_ht between b_ngayD and b_ngayC;
end if;
select JSON_ARRAYAGG(json_object('ma_dvi' value b_ma_dvi,'so_hd' value c1,'so_hd_c' value c2,'gcn' value c3,'ngay_hl' value n1,
     'ngay_kt' value n2,'ngay_cap' value n3,'so_id' value n4) returning clob) into cs_lke from (
      select * from (
          select t.*, ROW_NUMBER() over (order by n3 desc, n4 desc) as sott from ket_qua t
      ) where sott between b_tu and b_den and rownum<600);
select count(*) into b_dong from ket_qua where rownum<600;
select json_object('dong' value b_dong,'cs_lke' value cs_lke returning clob) into b_oraOut from dual;
delete ket_qua; commit;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SLI_PBOc(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_hs number; b_ngT number;
    b_thang number; b_ngay_bd number; b_ngayD number; b_ngayC number;
    b_tien number; b_tienT number; b_kc number; b_dthu number;
    a_nv pht_type.a_var; a_ng pht_type.a_num;
begin
-- Dan - Phan bo chung
EXECUTE IMMEDIATE 'truncate table sli_pb_temp REUSE STORAGE';
EXECUTE IMMEDIATE 'truncate table sli_pb_th_nv REUSE STORAGE';
EXECUTE IMMEDIATE 'truncate table sli_pb_th_lh REUSE STORAGE';
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_thang:=FKH_JS_GTRIn(b_oraIn,'thang');
if b_thang=0 then b_loi:='loi:Nhap thang:loi'; raise PROGRAM_ERROR; end if;
b_ngayD:=b_thang*10+1; b_ngayC:=b_ngayD+98;
select nvl(max(ngay_bd),0) into b_ngay_bd from bh_ke_tk where ngay_bd<=b_ngayD;
if b_ngay_bd=0 then b_loi:='loi:Chua khai bao tai khoan phan bo:loi'; raise PROGRAM_ERROR; end if;
select nvl(sum(tien),0) into b_dthu from sli_dt_th_nv where ma_dvi=b_ma_dvi and thang=b_ngayD;
if b_dthu>0 then
    b_tienT:=0;
    for r_lp in (select ma_tk,ma_tke from bh_ke_tk where ngay_bd=b_ngay_bd and pp='D' order by bt) loop
        select nvl(sum(no_ps-co_ps),0),count(*) into b_tien,b_i1 from kt_sc where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and ma_tk=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke);
        if b_i1<>0 then
            select nvl(sum(tien),0) into b_kc from kt_3 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
                l_ct='KC' and ma_tk_co=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke_co);
            b_tienT:=b_tienT+b_tien+b_kc;
        end if;
    end loop;
    if b_tienT>0 then
        b_hs:=b_tienT/b_dthu;
        insert into sli_pb_temp select nv,'D',lh_nv,round(tien*b_hs,0)
            from sli_dt_th_lh where ma_dvi=b_ma_dvi and thang=b_ngayD;
    end if;
end if;
b_tienT:=0;
for r_lp in (select ma_tk,ma_tke from bh_ke_tk where ngay_bd=b_ngay_bd and pp='N' order by bt) loop
    select nvl(sum(no_ps-co_ps),0),count(*) into b_tien,b_i1 from kt_sc where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and ma_tk=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke);
    if b_i1<>0 then
        select nvl(sum(tien),0) into b_kc from kt_3 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
            l_ct='KC' and ma_tk_co=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke_co);
        b_tienT:=b_tienT+b_tien+b_kc;
    end if;
end loop;
if b_tienT>0 then
    select nv,count(*) bulk collect into a_nv,a_ng from
        (select distinct nv,ma from ht_ma_nsd_nv where 
        ma_dvi=b_ma_dvi and md='BH' and nv in('XE','2B','TAU','NG','HANG','PHH','PKT','PTN','HOP','GOP','NONG'))
        group by nv;
    b_ngT:=FKH_ARR_TONG(a_ng);
    for b_lp in 1..a_nv.count loop
        select nvl(sum(tien),0) into b_dthu from sli_dt_th_nv where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        if b_dthu>0 then
            b_tien:=round(b_tienT*a_ng(b_lp)/b_ngT,0); b_hs:=b_tien/b_dthu;
            insert into sli_pb_temp select nv,'D',lh_nv,round(tien*b_hs,0)
                from sli_dt_th_lh where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        end if;
    end loop;
end if;
b_tienT:=0;
for r_lp in (select ma_tk,ma_tke from bh_ke_tk where ngay_bd=b_ngay_bd and pp='V' order by bt) loop
    select nvl(sum(no_ps-co_ps),0),count(*) into b_tien,b_i1 from kt_sc where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and ma_tk=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke);
    if b_i1<>0 then
        select nvl(sum(tien),0) into b_kc from kt_3 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
            l_ct='KC' and ma_tk_co=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke_co);
        b_tienT:=b_tienT+b_tien+b_kc;
    end if;
end loop;
if b_tienT>0 then
    select nv,count(*) bulk collect into a_nv,a_ng from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC group by nv;
    b_ngT:=FKH_ARR_TONG(a_ng);
    for b_lp in 1..a_nv.count loop
        select nvl(sum(tienP),0) into b_dthu from sli_bt_th_nv where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        if b_dthu>0 then
            b_tien:=round(b_tienT*a_ng(b_lp)/b_ngT,0); b_hs:=b_tien/b_dthu;
            insert into sli_pb_temp select nv,'B',lh_nv,round(tienP*b_hs,0)
                from sli_bt_th_lh where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        end if;
    end loop;
end if;
insert into sli_pb_th_lh select b_ma_dvi,b_ngayD,nv,pp,lh_nv,sum(tien) from sli_pb_temp group by nv,pp,lh_nv having sum(tien)>0;
insert into sli_pb_th_nv select b_ma_dvi,b_ngayD,nv,pp,sum(tien) from sli_pb_th_lh group by nv,pp;
EXECUTE IMMEDIATE 'truncate table sli_pb_temp DROP STORAGE';
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SLI_PBOh(
    b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_oraIn clob)
AS
    b_loi varchar2(100); b_i1 number; b_hs number; b_ngT number;
    b_thang number; b_ngay_bd number; b_ngayD number; b_ngayC number;
    b_tien number; b_tienT number; b_kc number; b_dthu number;
    a_nv pht_type.a_var; a_ng pht_type.a_num;
begin
-- Dan - Phan bo chung
EXECUTE IMMEDIATE 'truncate table sli_pb_temp REUSE STORAGE';
EXECUTE IMMEDIATE 'truncate table sli_pb_th_nv REUSE STORAGE';
EXECUTE IMMEDIATE 'truncate table sli_pb_th_lh REUSE STORAGE';
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','KE','N');
if b_loi is not null then raise PROGRAM_ERROR; end if;
b_thang:=FKH_JS_GTRIn(b_oraIn,'thang');
if b_thang=0 then b_loi:='loi:Nhap thang:loi'; raise PROGRAM_ERROR; end if;
b_ngayD:=b_thang*10+1; b_ngayC:=b_ngayD+98;
select nvl(max(ngay_bd),0) into b_ngay_bd from bh_ke_tk where ngay_bd<=b_ngayD;
if b_ngay_bd=0 then b_loi:='loi:Chua khai bao tai khoan phan bo:loi'; raise PROGRAM_ERROR; end if;
select nvl(sum(tien),0) into b_dthu from sli_dt_th_nv where ma_dvi=b_ma_dvi and thang=b_ngayD;
if b_dthu>0 then
    b_tienT:=0;
    for r_lp in (select ma_tk,ma_tke from bh_ke_tk where ngay_bd=b_ngay_bd and pp='D' order by bt) loop
        select nvl(sum(no_ps-co_ps),0),count(*) into b_tien,b_i1 from kt_sc where
            ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and ma_tk=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke);
        if b_i1<>0 then
            select nvl(sum(tien),0) into b_kc from kt_3 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
                l_ct='KC' and ma_tk_co=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke_co);
            b_tienT:=b_tienT+b_tien+b_kc;
        end if;
    end loop;
    if b_tienT>0 then
        b_hs:=b_tienT/b_dthu;
        insert into sli_pb_temp select nv,'D',lh_nv,round(tien*b_hs,0)
            from sli_dt_th_lh where ma_dvi=b_ma_dvi and thang=b_ngayD;
    end if;
end if;
b_tienT:=0;
for r_lp in (select ma_tk,ma_tke from bh_ke_tk where ngay_bd=b_ngay_bd and pp='N' order by bt) loop
    select nvl(sum(no_ps-co_ps),0),count(*) into b_tien,b_i1 from kt_sc where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and ma_tk=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke);
    if b_i1<>0 then
        select nvl(sum(tien),0) into b_kc from kt_3 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
            l_ct='KC' and ma_tk_co=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke_co);
        b_tienT:=b_tienT+b_tien+b_kc;
    end if;
end loop;
if b_tienT>0 then
    select nv,count(*) bulk collect into a_nv,a_ng from
        (select distinct nv,ma from ht_ma_nsd_nv where 
        ma_dvi=b_ma_dvi and md='BH' and nv in('XE','2B','TAU','NG','HANG','PHH','PKT','PTN','HOP','GOP','NONG'))
        group by nv;
    b_ngT:=FKH_ARR_TONG(a_ng);
    for b_lp in 1..a_nv.count loop
        select nvl(sum(tien),0) into b_dthu from sli_dt_th_nv where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        if b_dthu>0 then
            b_tien:=round(b_tienT*a_ng(b_lp)/b_ngT,0); b_hs:=b_tien/b_dthu;
            insert into sli_pb_temp select nv,'D',lh_nv,round(tien*b_hs,0)
                from sli_dt_th_lh where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        end if;
    end loop;
end if;
b_tienT:=0;
for r_lp in (select ma_tk,ma_tke from bh_ke_tk where ngay_bd=b_ngay_bd and pp='V' order by bt) loop
    select nvl(sum(no_ps-co_ps),0),count(*) into b_tien,b_i1 from kt_sc where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and ma_tk=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke);
    if b_i1<>0 then
        select nvl(sum(tien),0) into b_kc from kt_3 where ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC and
            l_ct='KC' and ma_tk_co=r_lp.ma_tk and r_lp.ma_tke in(' ',ma_tke_co);
        b_tienT:=b_tienT+b_tien+b_kc;
    end if;
end loop;
if b_tienT>0 then
    select nv,count(*) bulk collect into a_nv,a_ng from bh_bt_hs where
        ma_dvi=b_ma_dvi and ngay_ht between b_ngayD and b_ngayC group by nv;
    b_ngT:=FKH_ARR_TONG(a_ng);
    for b_lp in 1..a_nv.count loop
        select nvl(sum(tienP),0) into b_dthu from sli_bt_th_nv where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        if b_dthu>0 then
            b_tien:=round(b_tienT*a_ng(b_lp)/b_ngT,0); b_hs:=b_tien/b_dthu;
            insert into sli_pb_temp select nv,'B',lh_nv,round(tienP*b_hs,0)
                from sli_bt_th_lh where ma_dvi=b_ma_dvi and thang=b_ngayD and nv=a_nv(b_lp);
        end if;
    end loop;
end if;
insert into sli_pb_th_lh select b_ma_dvi,b_ngayD,nv,pp,lh_nv,sum(tien) from sli_pb_temp group by nv,pp,lh_nv having sum(tien)>0;
insert into sli_pb_th_nv select b_ma_dvi,b_ngayD,nv,pp,sum(tien) from sli_pb_th_lh group by nv,pp;
EXECUTE IMMEDIATE 'truncate table sli_pb_temp DROP STORAGE';
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PBH_SV_KH_SODT
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,b_sodt varchar2,cs1 out pht_type.cs_type,cs2 out pht_type.cs_type)
AS
    b_loi varchar2(100); a_ma_dvi pht_type.a_var; a_ma_kh pht_type.a_var; a_so_id pht_type.a_num;
begin
-- Dan - Thong tin KH qua so DT
delete bh_sv_kh_temp1;
commit;
b_loi:=FHT_MA_NSD_KTRA(b_ma_dvi,b_nsd,b_pas,'BH','','');
if b_loi is not null then raise PROGRAM_ERROR; end if;
select ma_dvi,ma BULK COLLECT into a_ma_dvi,a_ma_kh from bh_hd_ma_kh where mobi=b_sodt;
if a_ma_dvi.count=0 then b_loi:='Khong tim thay'; raise PROGRAM_ERROR;
elsif a_ma_dvi.count>100 then b_loi:='Tim thay nhieu hon 100 dong'; raise PROGRAM_ERROR;
end if;
open cs1 for select a.*,FHT_MA_DVI_TEN(ma_dvi) ten_dvi from bh_hd_ma_kh a where mobi=b_sodt order by ten;
for b_lp in 1..a_ma_dvi.count loop
    select distinct so_id_d BULK COLLECT into a_so_id from bh_hd_goc where ma_dvi=a_ma_dvi(b_lp) and ma_kh=a_ma_kh(b_lp);
    for b_lp1 in 1..a_so_id.count loop
        insert into bh_sv_kh_temp1 select a_ma_dvi(b_lp),a_ma_kh(b_lp),so_hd,nv from bh_hd_goc
            where ma_dvi=a_ma_dvi(b_lp) and ma_kh=a_ma_kh(b_lp) and so_id_d=a_so_id(b_lp1);
    end loop;
end loop;
open cs2 for select * from bh_sv_kh_temp1;
exception when others then if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace procedure PHT_MA_CB_FILE
    (b_ma_dvi varchar2,b_nsd varchar2,b_pas varchar2,a_phong pht_type.a_var,a_ma pht_type.a_var,a_ten pht_type.a_nvar)
AS
    b_loi varchar2(100); b_i1 number; b_idvung number;
begin
-- Dan - Nhap qua file
PHT_MA_NSD_KTRA_VU(b_ma_dvi,b_nsd,b_pas,b_idvung,b_loi,'HT','HT','MN');
if b_loi is not null then raise PROGRAM_ERROR; end if;
for b_lp in 1..a_phong.count loop
    if a_phong(b_lp) is null or trim(a_ma(b_lp)) is null or trim(a_ten(b_lp)) is null then
        b_loi:='loi:Nhap sai dong#'||to_char(b_lp)||':loi'; raise PROGRAM_ERROR;
    end if;
    b_loi:='loi:Sai ma phong#'||a_phong(b_lp)||':loi';
    select 0 into b_i1 from ht_ma_phong where ma_dvi=b_ma_dvi and ma=a_phong(b_lp);
    b_i1:=b_lp+1;
    for b_lp1 in b_i1..a_phong.count loop
        if a_ma(b_lp1)=a_ma(b_lp) then
            b_loi:='loi:Trung ma#'||a_ma(b_lp)||':loi'; raise PROGRAM_ERROR;
        end if;
    end loop;
end loop;
b_loi:='loi:Va cham NSD:loi';
for b_lp in 1..a_phong.count loop
    delete ht_ma_cb where ma_dvi=b_ma_dvi and ma=a_ma(b_lp);
    insert into ht_ma_cb values(b_ma_dvi,a_ma(b_lp),a_ten(b_lp),'',a_phong(b_lp),'','','','','','',b_nsd,b_idvung);
end loop;
commit;
exception when others then rollback; if b_loi is null then raise PROGRAM_ERROR; else raise_application_error(-20105,b_loi); end if;
end;
/
create or replace function FKH_HDONG_NB_PHONG(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_kq varchar2(10);
begin
-- Dan - Tra phong
select nvl(min(phong),' ') into b_kq from kh_hdong_nb where ma_dvi=b_ma_dvi and so_id=b_so_id;
return b_kq;
end;
/
 create or replace procedure PKH_HDONG_NB_XOA_XOA
    (b_ma_dvi varchar2,b_nsd varchar2,b_so_id number,b_loi out varchar2)
AS
    b_i1 number; b_nsd_c varchar2(10); b_ksoat varchar2(10); b_so_id_kt number;
begin
-- Dan - xoa
select min(nsd),min(so_id_kt),min(ksoat),count(*) into b_nsd_c,b_so_id_kt,b_ksoat,b_i1 from kh_hdong_nb where ma_dvi=b_ma_dvi and so_id=b_so_id;
if b_i1<>0 then
    if b_nsd_c is not null and b_nsd_c<>b_nsd then b_loi:='loi:Khong sua, xoa so lieu nguoi khac:loi';
    elsif b_so_id_kt>0 or trim(b_ksoat) is not null then b_loi:='loi:Ke toan da kiem soat:loi';
    else
        delete kh_hdong_nb_dt where ma_dvi=b_ma_dvi and so_id=b_so_id;
        delete kh_hdong_nb_phi where ma_dvi=b_ma_dvi and so_id=b_so_id;
        delete kh_hdong_nb where ma_dvi=b_ma_dvi and so_id=b_so_id;
    end if;
end if;
end;
/
create or replace function FKH_MA_KVUC_QLY(b_ma_dviN varchar2,b_ma varchar2) return varchar
as
    b_kq varchar2(200):=''; b_maM varchar(30); b_maC varchar(30);
    b_ma_dvi varchar2(20):=FKH_NV_DVI(b_ma_dviN,'kh_ma_kvuc');
begin
-- Dan - Xac dinh cap
b_maC:=b_ma;
while trim(b_maC) is not null loop
    select min(ma_ct) into b_maM from kh_ma_kvuc where ma_dvi=b_ma_dvi and ma=b_maC;
    if trim(b_maM) is not null then
        if trim(b_kq) is null then b_kq:=b_maM; else b_kq:=b_maM||','||b_kq; end if;
    end if;
    b_maC:=b_maM;
end loop;
return b_kq;
end;
 
/
create or replace procedure BCN_CDTK_CT(b_ma_dvi varchar2,b_ngayd number,b_ngayc number)
AS
    b_ngaydn number;
begin
-- Dan - Can doi chi tiet so cai cong no
delete cn_sc_temp_ct;
-- b_ngayd:=round(b_ngayd,-4)+0101;
insert into cn_sc_temp_ct select ma_cn,ma_nt,ma_tk,0,0,0,0,no_ck,co_ck,0,0,0,0,0,0,no_ck_qd,co_ck_qd,0,0
    from cn_sc where ma_dvi=b_ma_dvi and (ma_cn,ma_nt,ma_tk,ngay_ht) in
    (select ma_cn,ma_nt,ma_tk,max(ngay_ht) from cn_sc where ma_dvi=b_ma_dvi and ngay_ht<=b_ngayc group by ma_cn,ma_nt,ma_tk);
update cn_sc_temp_ct set (no_ps,co_ps,no_ps_qd,co_ps_qd)=(select nvl(sum(no_ps),0),nvl(sum(co_ps),0),nvl(sum(no_ps_qd),0),nvl(sum(co_ps_qd),0)
    from cn_sc where ma_dvi=b_ma_dvi and ma_cn=cn_sc_temp_ct.ma_cn and ma_nt=cn_sc_temp_ct.ma_nt and
    ma_tk=cn_sc_temp_ct.ma_tk and ngay_ht between b_ngayd and b_ngayc);
update cn_sc_temp_ct set (no_lk,co_lk,no_lk_qd,co_lk_qd)=(select nvl(sum(no_ps),0),nvl(sum(co_ps),0),nvl(sum(no_ps_qd),0),nvl(sum(co_ps_qd),0)
    from cn_sc where ma_dvi=b_ma_dvi and ma_cn=cn_sc_temp_ct.ma_cn and ma_nt=cn_sc_temp_ct.ma_nt and
    ma_tk=cn_sc_temp_ct.ma_tk and ngay_ht between b_ngaydn and b_ngayc);
delete cn_sc_temp_ct where no_ck=0 and co_ck=0 and no_lk=0 and co_lk=0;
-- Cuong: Sua lai dau ky
/*
update cn_sc_temp_ct set no_dk=no_ck+no_ps-co_ck-co_ps,no_dk_qd=no_ck_qd+no_ps_qd-co_ck_qd-co_ps_qd;
update cn_sc_temp_ct set co_dk=-no_dk,co_dk_qd=-no_dk_qd where no_dk<0;
update cn_sc_temp_ct set no_dk=0,no_dk_qd=0 where no_dk<0;
*/
-- Sua lai cach tinh so dau ky
/*
update cn_sc_temp_ct set (no_dk,co_dk,no_dk_qd,co_dk_qd)=(select nvl(no_ck,0),nvl(co_ck,0),nvl(no_ck_qd,0),nvl(co_ck_qd,0)
    from cn_sc where ma_dvi=b_ma_dvi and (ma_cn,ma_nt,ma_tk,ngay_ht) in
        (select ma_cn,ma_nt,ma_tk,max(ngay_ht) from cn_sc where ma_dvi=b_ma_dvi and ngay_ht=b_ngayd group by ma_cn,ma_nt,ma_tk)
        and ma_dvi=b_ma_dvi and ma_cn=cn_sc_temp_ct.ma_cn and ma_nt=cn_sc_temp_ct.ma_nt
        and ma_tk=cn_sc_temp_ct.ma_tk and ngay_ht between b_ngayd and b_ngayc);
*/
insert into cn_sc_temp_ct select ma_cn,ma_nt,ma_tk,no_ck,co_ck,0,0,0,0,0,0, no_ck_qd,co_ck_qd, 0,0,0,0,0,0
    from cn_sc where ma_dvi=b_ma_dvi and (ma_cn,ma_nt,ma_tk,ngay_ht) in
    (select ma_cn,ma_nt,ma_tk,max(ngay_ht) from cn_sc where ma_dvi=b_ma_dvi and ngay_ht<b_ngayd group by ma_cn,ma_nt,ma_tk);
end;
/
create or replace function FTS_PTU_SO_ID_TEN(b_ma_dvi varchar2,b_so_id number) return nvarchar2
AS
    b_ten nvarchar2(400);
begin
    select min(ten) into b_ten from ts_ptu_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    return b_ten;
end;
 
/
create or replace function FTS_PTU_SO_ID_THE(b_ma_dvi varchar2,b_so_id number) return varchar2
AS
    b_so_the varchar2(20);
begin
    select min(so_ptu) into b_so_the from ts_ptu_1 where ma_dvi=b_ma_dvi and so_id=b_so_id;
    return b_so_the;
end;
