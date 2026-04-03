/* Ham JS */
create or replace function FKH_JS_GTRIs(
    b_txt clob,b_ten varchar2,b_de varchar2:=' ') return varchar2
as
    b_kq varchar2(1000):=' '; b_c clob; b_tenH varchar2(50);
    b_t json_object_t; a_cot json_key_list; b_gtri json_element_t;
begin
-- Dan - Tra gia tri var
b_c:=trim(FKH_JS_BONH(b_txt));
if b_c is null then return b_de; end if;
b_tenH:=upper(b_ten); b_t:=json_object_t(b_c); a_cot:=b_t.get_keys;
for b_lp in 1..a_cot.count loop
    if upper(a_cot(b_lp))=b_tenH then
        b_gtri:=b_t.get(a_cot(b_lp));
        if b_gtri.is_string() then
            b_kq:=b_t.get_string(a_cot(b_lp));
        elsif b_gtri.is_number() then
            b_kq:=to_char(b_t.get_number(a_cot(b_lp)));
        end if;
        exit;
    end if;
end loop;
b_kq:=nvl(trim(b_kq),b_de);
return b_kq;
exception when others then return b_de;
end;
/
create or replace function FKH_JS_GTRIu(
    b_txt clob,b_ten varchar2,b_de nvarchar2:=' ') return nvarchar2
as
    b_kq nvarchar2(2000):=''; b_c clob; b_tenH varchar2(50);
    b_t json_object_t; a_cot json_key_list; b_gtri json_element_t;
begin
-- Dan - Tra gia tri var
b_c:=trim(FKH_JS_BONH(b_txt));
if b_c is null then return b_de; end if;
b_tenH:=upper(b_ten); b_t:=json_object_t(b_c); a_cot:=b_t.get_keys;
for b_lp in 1..a_cot.count loop
    if upper(a_cot(b_lp))=b_tenH then
        b_gtri:=b_t.get(a_cot(b_lp));
        if b_gtri.is_string() then
            b_kq:=b_t.get_string(a_cot(b_lp));
        elsif b_gtri.is_number() then
            b_kq:=to_char(b_t.get_number(a_cot(b_lp)));
        end if;
        exit;
    end if;
end loop;
b_kq:=nvl(trim(b_kq),b_de);
return b_kq;
exception when others then return b_de;
end;
/
create or replace function FKH_JS_GTRIc(
    b_txt clob,b_ten varchar2,b_de clob:=' ') return clob
as
    b_kq clob; b_c clob; b_tenH varchar2(50);
    b_t json_object_t; a_cot json_key_list; b_gtri json_element_t;
begin
-- Dan - Tra gia tri clob
b_c:=trim(FKH_JS_BONH(b_txt));
if b_c is null then return b_de; end if;
b_tenH:=upper(b_ten); b_t:=json_object_t(b_c); a_cot:=b_t.get_keys;
for b_lp in 1..a_cot.count loop
    if upper(a_cot(b_lp))=b_tenH then
        b_gtri:=b_t.get(a_cot(b_lp));
        if b_gtri.is_string() then
            b_kq:=b_t.get_string(a_cot(b_lp));
        elsif b_gtri.is_number() then
            b_kq:=to_char(b_t.get_number(a_cot(b_lp)));
        end if;
        exit;
    end if;
end loop;
b_kq:=nvl(trim(b_kq),b_de);
return b_kq;
exception when others then return b_de;
end;
/
create or replace function FKH_JS_GTRIn(
    b_txt clob,b_ten varchar2,b_de number:=0) return number
as
    b_kq number:=0; b_c clob; b_tenH varchar2(50);
    b_t json_object_t; a_cot json_key_list; b_gtri json_element_t;
begin
-- Dan - Tra gia tri var
b_c:=trim(FKH_JS_BONH(b_txt));
if b_c is null then return b_de; end if;
b_tenH:=upper(b_ten); b_t:=json_object_t(b_c); a_cot:=b_t.get_keys;
for b_lp in 1..a_cot.count loop
    if upper(a_cot(b_lp))=b_tenH then
        b_gtri:=b_t.get(a_cot(b_lp)); b_kq:=b_de;
        if b_gtri.is_string() then
            b_kq:=PKH_LOC_CHU_SO(b_t.get_string(a_cot(b_lp)),'T');
        elsif b_gtri.is_number() then
            b_kq:=b_t.get_number(a_cot(b_lp));
        end if;
        exit;
    end if;
end loop;
return b_kq;
exception when others then return b_de;
end;
/
-- chuclh
create or replace function FKH_JS_GTRI(b_txt clob,b_ten varchar2) return nvarchar2
as
    b_kq nvarchar2(2000); b_lenh varchar2(1000);
    --b_txt clob:='{"a":1,"b":"cot B","c":"cot C"}';
    --b_ten varchar2(100):='a';
begin
-- Dan - Tra gia tri nvarchar
b_lenh:='select json_value(:txt,'||'''$.'||b_ten||''') from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_txt;
return b_kq;
end;
/
-- Tra gia tri trong clob dang mang
create or replace function FKH_JSa_GTRIu(b_txt clob,b_hang number,b_ten varchar2,b_de nvarchar2:='') return nvarchar2
as
    b_kq nvarchar2(1000); b_lenh varchar2(1000); b_c clob:=FKH_JS_BONH(b_txt);
begin
-- Dan - Tra gia tri nvar
b_lenh:='select json_value(:txt,'||'''$['||to_char(b_hang-1)||'].'||b_ten||''' returning nvarchar2) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_c;
if b_kq is null then b_kq:=b_de; end if;
return b_kq;
end;
/
create or replace function FKH_JSa_GTRIs(b_txt clob,b_hang number,b_ten varchar2,b_de varchar2:='') return varchar2
as
    b_kq varchar2(1000); b_lenh varchar2(1000); b_c clob:=FKH_JS_BONH(b_txt);
begin
-- Dan - Tra gia tri var
b_lenh:='select json_value(:txt,'||'''$['||to_char(b_hang-1)||'].'||b_ten||''' returning varchar2) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_c;
if b_kq is null then b_kq:=b_de; end if;
return b_kq;
end;
/
create or replace function FKH_JSa_GTRIn(b_txt clob,b_hang number,b_ten varchar2,b_de number:=0) return number
as
    b_kq varchar2(1000); b_lenh varchar2(1000); b_c clob:=FKH_JS_BONH(b_txt);
begin
-- Dan - Tra gia tri var
b_lenh:='select json_value(:txt,'||'''$['||to_char(b_hang-1)||'].'||b_ten||''' returning number) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_c;
if b_kq is null then b_kq:=b_de; end if;
return b_kq;
end;
/
create or replace function FKH_JSa_GTRIc(b_txt clob,b_hang number,b_ten varchar2) return clob
as
    b_kq clob; b_lenh varchar2(1000); b_c clob:=FKH_JS_BONH(b_txt);
begin
-- Dan - Tra gia tri clob
b_lenh:='select json_value(:txt,'||'''$['||to_char(b_hang-1)||'].'||b_ten||''' returning clob) from dual';
EXECUTE IMMEDIATE b_lenh into b_kq using b_c;
return b_kq;
end;
/
-- Tao lenh
create or replace function FKH_JS_LENH(b_ten varchar2,b_bang varchar2:='',b_hoa varchar2:='K') return varchar2
as
    b_kq varchar2(2000); b_tenX varchar2(1000); a_ten pht_type.a_var;
begin
-- Dan - Tra lenh
if b_hoa<>'C' then b_tenX:=b_ten; else b_tenX:=upper(b_ten); end if;
PKH_CH_ARR(b_tenX,a_ten);
if trim(b_ten) is null then
	b_kq:='select * ';
else 
	b_kq:='select ';
	for b_lp in 1..a_ten.count loop
		if b_lp<>1 then b_kq:=b_kq||','; end if;
		b_kq:=b_kq||'a'||to_char(b_lp);
	end loop;
end if;
b_kq:=b_kq||' from json_table(:txt,''$'||b_bang||'[*]'' COLUMNS (';
if trim(b_ten) is null then
    b_kq:=b_kq||'a varchar2 PATH ''$''';
else
    for b_lp in 1..a_ten.count loop
        if b_lp<>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||'a'||to_char(b_lp)||' varchar2 PATH ''$.'||a_ten(b_lp)||'''';
    end loop;
end if;
b_kq:=b_kq||'))';
return b_kq;
end;
/
create or replace function FKH_JS_LENHu(b_ten varchar2,b_bang varchar2:='',b_hoa varchar2:='K') return varchar2
as
    b_kq varchar2(2000); b_tenX varchar2(1000); a_ten pht_type.a_var;
begin
-- Dan - Tra lenh
if b_hoa<>'C' then b_tenX:=b_ten; else b_tenX:=upper(b_ten); end if;
PKH_CH_ARR(b_tenX,a_ten);
if trim(b_ten) is null then
	b_kq:='select * ';
else 
	b_kq:='select ';
	for b_lp in 1..a_ten.count loop
		if b_lp<>1 then b_kq:=b_kq||','; end if;
		b_kq:=b_kq||'a'||to_char(b_lp);
	end loop;
end if;
b_kq:=b_kq||' from json_table(:txt,''$'||b_bang||'[*]'' COLUMNS (';
if trim(b_ten) is null then
    b_kq:=b_kq||'a nvarchar2 PATH ''$''';
else
    for b_lp in 1..a_ten.count loop
        if b_lp<>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||'a'||to_char(b_lp)||' nvarchar2 PATH ''$.'||a_ten(b_lp)||'''';
    end loop;
end if;
b_kq:=b_kq||'))';
return b_kq;
end;
/
create or replace function FKH_JS_LENHn(b_ten varchar2,b_bang varchar2:='',b_hoa varchar2:='K') return varchar2
as
    b_kq varchar2(2000); b_tenX varchar2(1000); a_ten pht_type.a_var;
begin
-- Dan - Tra lenh
if b_hoa<>'C' then b_tenX:=b_ten; else b_tenX:=upper(b_ten); end if;
PKH_CH_ARR(b_tenX,a_ten);
if trim(b_ten) is null then
	b_kq:='select * ';
else 
	b_kq:='select ';
	for b_lp in 1..a_ten.count loop
		if b_lp<>1 then b_kq:=b_kq||','; end if;
		b_kq:=b_kq||'a'||to_char(b_lp);
	end loop;
end if;
b_kq:=b_kq||' from json_table(:txt,''$'||b_bang||'[*]'' COLUMNS (';
if trim(b_ten) is null then
    b_kq:=b_kq||'a number PATH ''$''';
else
    for b_lp in 1..a_ten.count loop
        if b_lp<>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||'a'||to_char(b_lp)||' number PATH ''$.'||a_ten(b_lp)||'''';
    end loop;
end if;
b_kq:=b_kq||'))';
return b_kq;
end;
/
create or replace function FKH_JS_LENHo(b_ten varchar2, b_bang varchar2:='', b_hoa varchar2:='K') return varchar2
as
    b_kq varchar2(2000); b_tenX varchar2(1000); a_ten pht_type.a_var;
begin
    -- Dan - Tra lenh
    if b_hoa <> 'C' then b_tenX := b_ten; else b_tenX := upper(b_ten); end if;
    
    PKH_CH_ARR(b_tenX, a_ten);

    if trim(b_ten) is null then
        b_kq := 'select * ';
    else
        b_kq := 'select ';
        for b_lp in 1..a_ten.count loop
            if b_lp <> 1 then b_kq := b_kq || ','; end if;
            b_kq := b_kq || 'a' || to_char(b_lp);
        end loop;
    end if;

    b_kq := b_kq || ' from json_table(:txt,''$' || b_bang || '[*]'' COLUMNS (';

    if trim(b_ten) is null then
        b_kq := b_kq || 'a varchar2(4000) FORMAT JSON PATH ''$''';
    else
        for b_lp in 1..a_ten.count loop
            if b_lp <> 1 then b_kq := b_kq || ','; end if;
            b_kq := b_kq || 'a' || to_char(b_lp) || ' varchar2(4000) FORMAT JSON PATH ''$.' || a_ten(b_lp) || '''';
        end loop;
    end if;
    
    b_kq := b_kq || '))';
    return b_kq;
end;
/
create or replace function FKH_JS_LENHc(b_ten varchar2,b_bang varchar2:='') return varchar2
as
    b_kq varchar2(2000); a_ten pht_type.a_var;
begin
-- Dan - Tra lenh cac bien ra clob
PKH_CH_ARR(b_ten,a_ten);
if trim(b_ten) is null then
	b_kq:='select * ';
else 
	b_kq:='select ';
	for b_lp in 1..a_ten.count loop
		if b_lp<>1 then b_kq:=b_kq||','; end if;
		b_kq:=b_kq||'a'||to_char(b_lp);
	end loop;
end if;
b_kq:=b_kq||' from json_table(:txt,''$'||b_bang||'[*]'' COLUMNS (';
if trim(b_ten) is null then
    b_kq:=b_kq||' a clob PATH ''$''';
else
    for b_lp in 1..a_ten.count loop
        if b_lp<>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||'a'||to_char(b_lp)||' clob PATH ''$.'||a_ten(b_lp)||'''';
    end loop;
end if;
b_kq:=b_kq||'))';
return b_kq;
end;
/
create or replace function FKH_JS_LENHt(b_ten varchar2,b_bang varchar2:='') return varchar2
as
    b_kq varchar2(2000); a_ten pht_type.a_var;
begin
-- Dan - Tra lenh cac bien ra object T
PKH_CH_ARR(b_ten,a_ten);
if trim(b_ten) is null then
	b_kq:='select * ';
else 
	b_kq:='select ';
	for b_lp in 1..a_ten.count loop
		if b_lp<>1 then b_kq:=b_kq||','; end if;
		b_kq:=b_kq||'a'||to_char(b_lp);
	end loop;
end if;
b_kq:=b_kq||' from json_table(:txt,''$'||b_bang||'[*]'' COLUMNS (';
if trim(b_ten) is null then
    b_kq:=b_kq||' a JSON_OBJECT_T PATH ''$''';
else
    for b_lp in 1..a_ten.count loop
        if b_lp<>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||'a'||to_char(b_lp)||' JSON_OBJECT_T PATH ''$.'||a_ten(b_lp)||'''';
    end loop;
end if;
b_kq:=b_kq||'))';
return b_kq;
end;
/
create or replace function FKH_JS_LENHj return varchar2
as
begin
-- Dan - Tra lenh cac bien ra json
return 'select *  from json_table(:txt,''$[*]'' COLUMNS ( a json PATH ''$''))';
end;
/
create or replace procedure FKH_JSt_NULL(b_t in out json_object_t)
as
    b_n number; b_s nvarchar2(3000);
    a_cot json_key_list; b_gtri json_element_t;
begin
-- Dan - Chuyen chuoi null thanh ' ',0
a_cot:=b_t.get_keys;
for b_lp in 1..a_cot.count loop
    b_gtri:=b_t.get(a_cot(b_lp));
    if b_gtri is null then continue; end if;
    if b_gtri.is_number() then
        b_n:=nvl(b_t.get_number(a_cot(b_lp)),0); b_t.put(a_cot(b_lp),b_n);
    elsif b_gtri.is_string() then
        b_s:=nvl(trim(b_t.get_string(a_cot(b_lp))),' '); b_t.put(a_cot(b_lp),b_s);
    end if;
end loop;
end;
/

create or replace procedure PKH_JS_THAY(b_js in out clob,b_cot varchar2,b_gtri nvarchar2)
as
    b_t json_object_t;
begin
-- Dan - Co thi thay, chua co thi them
b_js:=FKH_JS_BONH(b_js);
if length(b_js)=0 then b_js:='{}'; end if;
b_t:=json_object_t(b_js); b_t.put(b_cot,b_gtri);
b_js:=b_t.to_string();
end;
/
create or replace procedure PKH_JS_THAYa(
    b_js in out clob,b_cot varchar2,b_gtri varchar2,b_cach varchar2:=',')
as
    b_lenh varchar2(1000):='{';
    a_cot pht_type.a_var; a_gtri pht_type.a_var;
begin
-- Dan - Co thi thay, chua co thi them
b_js:=FKH_JS_BONH(b_js);
if length(b_js)=0 then b_js:='{}'; end if;
PKH_CH_ARR(b_cot,a_cot); PKH_CH_ARR(b_gtri,a_gtri,b_cach);
for b_lp in 1..a_cot.count loop
    if b_lp>1 then b_lenh:=b_lenh||','; end if;
    b_lenh:=b_lenh||'"'||a_cot(b_lp)||'":"'||a_gtri(b_lp)||'"';
end loop;
b_lenh:=b_lenh||'}';
select json_mergepatch(b_js,b_lenh) into b_js from dual;
end;
/
create or replace procedure PKH_JS_THAYas(b_js in out clob,b_cot varchar2,a_gtri pht_type.a_var)
as
    b_lenh varchar2(1000):='{';
    a_cot pht_type.a_var;
begin
-- Dan - Co thi thay, chua co thi them mang chu
b_js:=FKH_JS_BONH(b_js);
if length(b_js)=0 then b_js:='{}'; end if;
PKH_CH_ARR(b_cot,a_cot);
for b_lp in 1..a_cot.count loop
    if b_lp>1 then b_lenh:=b_lenh||','; end if;
    b_lenh := b_lenh||'"'||a_cot(b_lp)||'":"'||a_gtri(b_lp)||'"';
end loop;
b_lenh:=b_lenh||'}';
--nampb: mer tung phan tu cua mang vao json, neu dung json_mergepatch truc tiep se bi loi do json_mergepatch khong xu ly duoc mang
    if substr(trim(b_js), 1, 1) = '[' then
        select JSON_ARRAYAGG(json_mergepatch(jt.obj, b_lenh) returning clob) into b_js
               from JSON_TABLE(b_js, '$[*]' COLUMNS (obj clob FORMAT JSON PATH '$')) jt;
    else
        select json_mergepatch(b_js, b_lenh) into b_js from dual;
    end if;
end;
/
create or replace procedure PKH_JS_THAYn(b_js in out clob,b_cot varchar2,b_gtri number)
as
    b_lenh varchar2(1000):='{';
begin
-- Dan - Co thi thay, chua co thi them
b_js:=FKH_JS_BONH(b_js);
if length(b_js)=0 then b_js:='{}'; end if;
b_lenh:=b_lenh||'"'||b_cot||'":'||to_char(b_gtri)||'}';
select json_mergepatch(b_js,b_lenh) into b_js from dual;
end;
/
create or replace procedure PKH_JS_THAYan(b_js in out clob,b_cot varchar2,a_gtri pht_type.a_num)
as
    b_lenh varchar2(1000):='{';
    a_cot pht_type.a_var;
begin
-- Dan - Co thi thay, chua co thi them mang so
    b_js:=FKH_JS_BONH(b_js);
    if length(b_js)=0 then b_js:='{}'; end if;
    PKH_CH_ARR(b_cot,a_cot);
    for b_lp in 1..a_cot.count loop
        if b_lp>1 then b_lenh:=b_lenh||','; end if;
        b_lenh:=b_lenh||'"'||a_cot(b_lp)||'":'||to_char(a_gtri(b_lp));
    end loop;
    b_lenh:=b_lenh||'}';
    --nampb: mer tung phan tu cua mang vao json, neu dung json_mergepatch truc tiep se bi loi do json_mergepatch khong xu ly duoc mang
    if substr(trim(b_js), 1, 1) = '[' then
        select JSON_ARRAYAGG(json_mergepatch(jt.obj, b_lenh) returning clob) into b_js
               from JSON_TABLE(b_js, '$[*]' COLUMNS (obj clob FORMAT JSON PATH '$')) jt;
    else
        select json_mergepatch(b_js, b_lenh) into b_js from dual;
    end if;
end;
/
create or replace procedure PKH_JS_THAYc(b_js in out clob,b_cot varchar2,b_gtri clob)
as
    b_lenh varchar2(1000):='{';
begin
-- Dan - Co thi thay, chua co thi them; bo cot neu b_gtri=null
b_js:=FKH_JS_BONH(b_js);
if length(b_js)=0 then b_js:='{}'; end if;
b_lenh:=b_lenh||'"'||b_cot||'":"'||b_gtri||'"}';
select json_mergepatch(b_js,b_lenh) into b_js from dual;
end;
/
create or replace procedure PKH_JS_BO(b_js in out clob,b_cot varchar2)
as
    b_lenh varchar2(1000):='{';
    a_cot pht_type.a_var;
begin
-- Dan - Bo cot
b_js:=FKH_JS_BONH(b_js);
if length(b_js)=0 then b_js:='{}'; end if;
PKH_CH_ARR(b_cot,a_cot);
for b_lp in 1..a_cot.count loop
    if b_lp>1 then b_lenh:=b_lenh||','; end if;
    b_lenh:=b_lenh||'"'||a_cot(b_lp)||'":null';
end loop;
b_lenh:=b_lenh||'}';
select json_mergepatch(b_js,b_lenh) into b_js from dual;
end;
/
create or replace function FKH_BANG_JS(b_bang varchar2,b_cotN varchar2,b_dk varchar2,b_xep varchar2) return clob
as
    b_lenh varchar2(2000); b_kq clob:=''; b_cot varchar2(1000):=nvl(trim(b_cotN),'*');
begin
-- Dan - Tra Json cua bang
b_lenh:='SELECT json_arrayagg(lke) from (SELECT json_object('||b_cot||') lke from '||b_bang;
if trim(b_dk) is not null then b_lenh:=b_lenh||' where '||b_dk; end if;
if trim(b_xep) is not null then b_lenh:=b_lenh||' order by '||b_xep; end if;
b_lenh:=b_lenh||')';
EXECUTE IMMEDIATE b_lenh into b_kq;
return b_kq;
end;
/
create or replace function FKH_ARRc_JS(a_c pht_type.a_clob,b_dk varchar2:='C') return clob
AS
    b_kq clob:='['; b_txt clob; b_i1 number;
begin
-- Tra chuoi Js cua mang clob
if b_dk='C' then
    for b_lp in 1..a_c.count loop
        if b_lp>1 then b_kq:=b_kq||','; end if;
        select json_object('zzz' value a_c(b_lp) returning clob) into b_txt from dual;
        b_txt:=substr(b_txt,8); b_i1:=length(b_txt)-1;
        b_kq:=b_kq||substr(b_txt,1,b_i1);
    end loop;
else
    for b_lp in 1..a_c.count loop
        if b_lp>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||a_c(b_lp);
    end loop;
end if;
b_kq:=b_kq||']';
return b_kq;
end;
/
create or replace function FKH_ARRn_JS(a_n pht_type.a_num) return clob
AS
    b_kq clob:='[';
begin
-- Tra chuoi Js cua mang so
for b_lp in 1..a_n.count loop
    if b_lp>1 then b_kq:=b_kq||','; end if;
    b_kq:=b_kq||to_char(a_n(b_lp));
end loop;
b_kq:=b_kq||']';
return b_kq;
end;
/
-- chuclh: giu format json - neu khong se bi them /. KIEU OBJECT - DANH GIA SU DUNG NEU LAM VIEC VOI OBJ
create or replace function FKH_ARRo_JS(a_c pht_type.a_clob,b_dk varchar2:='C') return clob
AS
    b_kq clob:='['; b_txt clob; b_i1 number;
begin
-- Tra chuoi Js cua mang clob
if b_dk='C' then
    for b_lp in 1..a_c.count loop
        if b_lp>1 then b_kq:=b_kq||','; end if;
        select json_object('zzz' value a_c(b_lp) FORMAT JSON returning clob) into b_txt from dual;
        b_txt:=substr(b_txt,8); b_i1:=length(b_txt)-1;
        b_kq:=b_kq||substr(b_txt,1,b_i1);
    end loop;
else
    for b_lp in 1..a_c.count loop
        if b_lp>1 then b_kq:=b_kq||','; end if;
        b_kq:=b_kq||a_c(b_lp);
    end loop;
end if;
b_kq:=b_kq||']';
return b_kq;
end;
/
create or replace function FKH_JS_BONH(b_js clob) return clob
as
    b_kq clob:=trim(b_js);
begin
-- Dan - Bo nhay kep 2 dau Json
if b_kq is not null then
    while substr(b_kq,1,1)='"' loop
    b_kq:=substr(b_kq,2,length(b_kq)-2);
    end loop;
end if;
return b_kq;
end;
/
create or replace procedure PKH_JS_BONH(b_js in out clob)
as
begin
-- Dan - Bo nhay kep 2 dau Json
b_js:=trim(b_js);
if b_js is not null then
    while substr(b_js,1,1)='"' loop
    b_js:=substr(b_js,2,length(b_js)-2);
    end loop;
end if;
end;
/
create or replace function PKH_JS_COT(b_js clob) return varchar2
as
    b_kq VARCHAR2(200):=''; b_jo JSON_OBJECT_T; a_jk JSON_KEY_LIST;
begin
-- Dan - Lay ten cot chuoi Json
b_jo:=JSON_OBJECT_T.parse(b_js); a_jk:=b_jo.get_keys;
for b_lp in 1..a_jk.count loop
    b_kq:=FKH_GHEP(b_kq,lower(a_jk(b_lp)));
end loop;
return b_kq;
end;
/
create or replace function PKH_JS_TIM(b_gtri clob,b_tim clob) return varchar2
as
    b_kq VARCHAR2(200):='C'; b_joG JSON_OBJECT_T; b_joT JSON_OBJECT_T; a_jk JSON_KEY_LIST;
	b_c varchar2(500);
begin
-- Dan - Kiem tra Js trong Js
b_joG:=JSON_OBJECT_T(lower(b_gtri));
b_joT:=JSON_OBJECT_T(lower(b_tim)); a_jk:=b_joT.get_keys;
for b_lp in 1..a_jk.count loop
	if trim(b_joG.get_string(a_jk(b_lp))) is not null and
		trim(b_joG.get_string(a_jk(b_lp)))<>trim(b_joT.get_string(a_jk(b_lp))) then b_kq:='K'; exit;
    end if;
end loop;
return b_kq;
end;
/
create or replace procedure FKH_JSat_NULL(a_t in out json_array_t)
as
    b_n number; b_s nvarchar2(2000); b_kt number:=a_t.get_size()-1;
    b_t json_object_t; a_cot json_key_list; b_gtri json_element_t;
begin
-- Dan - Chuyen chuoi null thanh ' ',0
for b_lp in 0..b_kt loop
    b_t:=treat(a_t.get(b_lp) as json_object_t);
    a_cot:=b_t.get_keys;
    for b_lp in 1..a_cot.count loop
        b_gtri:=b_t.get(a_cot(b_lp));
        if b_gtri.is_number() then
            b_n:=nvl(b_t.get_number(a_cot(b_lp)),0); b_t.put(a_cot(b_lp),b_n);
        elsif b_gtri.is_string() then
            b_s:=nvl(trim(b_t.get_string(a_cot(b_lp))),' '); b_t.put(a_cot(b_lp),b_s);
        end if;
    end loop;
    a_t.put(b_lp,b_t,OVERWRITE=>TRUE);
end loop;
end;
/
create or replace procedure FKH_JS_NULL(b_js in out clob)
as
    b_t json_object_t;
begin
-- Dan - Chuyen chuoi null thanh ' ',0
if trim(b_js) is null then return; end if;
b_t:=json_object_t(b_js);
FKH_JSt_NULL(b_t); b_js:=b_t.to_clob();
b_js:=replace(b_js,'""','" "'); -- chuclh: ham nay khong can vi FKH_JSt_NULL da lam roi. replace tao ra ban sao
end;
/
create or replace procedure FKH_JSa_NULL(b_js in out clob)
as
    a_t json_array_t;
begin
-- Dan - Chuyen chuoi null thanh ' ',0
if trim(b_js) is null then return; end if;
a_t:=json_array_t(b_js);
FKH_JSat_NULL(a_t); b_js:=a_t.to_clob();
b_js:=replace(b_js,'""','" "');
end;
/
