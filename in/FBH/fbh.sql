--thay trong TH b_gtri chua ky tu dac biet
create or replace procedure PKH_JS_THAY_D(b_js in out clob,b_cot varchar2,b_gtri nvarchar2)
as
    b_kq clob; b_lenh varchar2(1000):='{';
begin
b_js:=FKH_JS_BONH(b_js);
SELECT json_mergepatch(b_js, json_object(b_cot VALUE b_gtri RETURNING CLOB)) INTO b_js FROM dual;
end;
/
---pro nay tra ve gtri dang json, dung cho truong hop b_gtri da la json
create or replace procedure PKH_JS_THAYc_D(b_js in out clob, b_cot varchar2, b_gtri clob)
as
  l_patch clob;
begin
  b_js := FKH_JS_BONH(b_js);

  l_patch := '{"' || b_cot || '":' || b_gtri || '}';

  SELECT json_mergepatch(b_js, l_patch RETURNING CLOB)
  INTO b_js
  FROM dual;
end;
/
CREATE OR REPLACE FUNCTION FBH_IN_CSO_CHU_EN (
    p_number        IN NUMBER,
    p_currency_code IN VARCHAR2
) RETURN VARCHAR2
IS
    TYPE t_words IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
    v_num_words t_words;
    v_tens_words t_words;
    v_scale_words t_words;

    v_int_part NUMBER;
    v_dec_part NUMBER;
    v_res VARCHAR2(4000) := '';
    v_chunk NUMBER;
    v_index NUMBER := 0;
    v_part VARCHAR2(4000);
    v_num_str VARCHAR2(100);
    v_len NUMBER;

    v_currency_name   VARCHAR2(50);
    v_fractional_name VARCHAR2(50);

    -- hàm đọc 3 chữ số
    FUNCTION read_hundreds(p_chunk NUMBER) RETURN VARCHAR2 IS
        v_res VARCHAR2(200) := '';
        v_hundred NUMBER;
        v_ten NUMBER;
        v_unit NUMBER;
    BEGIN
        v_hundred := TRUNC(p_chunk / 100);
        v_ten     := TRUNC(MOD(p_chunk, 100) / 10);
        v_unit    := MOD(p_chunk, 10);

        IF v_hundred > 0 THEN
            v_res := v_res || v_num_words(v_hundred) || ' hundred';
            IF v_ten > 0 OR v_unit > 0 THEN
                v_res := v_res || ' and';
            END IF;
        END IF;

        IF v_ten >= 2 THEN
            v_res := v_res || ' ' || v_tens_words(v_ten);
            IF v_unit > 0 THEN
                v_res := v_res || '-' || v_num_words(v_unit);
            END IF;
        ELSIF v_ten = 1 THEN
            v_res := v_res || ' ' || v_num_words(v_ten * 10 + v_unit);
        ELSIF v_unit > 0 THEN
            v_res := v_res || ' ' || v_num_words(v_unit);
        END IF;

        RETURN TRIM(v_res);
    END;
BEGIN
    -- 0-19
    v_num_words(0) := 'zero';
    v_num_words(1) := 'one';
    v_num_words(2) := 'two';
    v_num_words(3) := 'three';
    v_num_words(4) := 'four';
    v_num_words(5) := 'five';
    v_num_words(6) := 'six';
    v_num_words(7) := 'seven';
    v_num_words(8) := 'eight';
    v_num_words(9) := 'nine';
    v_num_words(10) := 'ten';
    v_num_words(11) := 'eleven';
    v_num_words(12) := 'twelve';
    v_num_words(13) := 'thirteen';
    v_num_words(14) := 'fourteen';
    v_num_words(15) := 'fifteen';
    v_num_words(16) := 'sixteen';
    v_num_words(17) := 'seventeen';
    v_num_words(18) := 'eighteen';
    v_num_words(19) := 'nineteen';

    -- 20,30,...90
    v_tens_words(2) := 'twenty';
    v_tens_words(3) := 'thirty';
    v_tens_words(4) := 'forty';
    v_tens_words(5) := 'fifty';
    v_tens_words(6) := 'sixty';
    v_tens_words(7) := 'seventy';
    v_tens_words(8) := 'eighty';
    v_tens_words(9) := 'ninety';

    -- scale words
    v_scale_words(1) := '';
    v_scale_words(2) := ' thousand';
    v_scale_words(3) := ' million';
    v_scale_words(4) := ' billion';
    v_scale_words(5) := ' trillion';

    -- gán tên tiền tệ theo mã
    CASE UPPER(p_currency_code)
        WHEN 'USD' THEN
            v_currency_name := 'dollars';
            v_fractional_name := 'cents';
        WHEN 'VND' THEN
            v_currency_name := 'dong';
            v_fractional_name := 'xu';
        WHEN 'EUR' THEN
            v_currency_name := 'euros';
            v_fractional_name := 'cents';
        WHEN 'GBP' THEN
            v_currency_name := 'pounds';
            v_fractional_name := 'pence';
        WHEN 'JPY' THEN
            v_currency_name := 'yen';
            v_fractional_name := 'sen';
        ELSE
            v_currency_name := LOWER(p_currency_code);
            v_fractional_name := 'cents';
    END CASE;

    -- tách phần nguyên và thập phân
    v_int_part := TRUNC(p_number);
    v_dec_part := ROUND(MOD(p_number, 1) * 100); -- 2 chữ số lẻ

    -- đọc phần nguyên
    IF v_int_part = 0 THEN
        v_res := 'zero';
    ELSE
        v_num_str := TO_CHAR(v_int_part);
        v_len := LENGTH(v_num_str);
        v_index := 0;

        WHILE v_len > 0 LOOP
            v_index := v_index + 1;
            v_chunk := TO_NUMBER(SUBSTR(v_num_str, GREATEST(v_len - 2, 1), LEAST(3, v_len)));

            IF v_chunk > 0 THEN
                v_part := read_hundreds(v_chunk) || v_scale_words(v_index);
                IF v_res IS NULL THEN
                    v_res := v_part;
                ELSE
                    v_res := v_part || ', ' || v_res;
                END IF;
            END IF;

            v_len := v_len - 3;
        END LOOP;
    END IF;
    v_res := INITCAP(TRIM(v_res)) || ' ' || v_currency_name;
    -- phần thập phân
    IF v_dec_part > 0 THEN
        v_part := read_hundreds(v_dec_part);
        v_res := v_res || ' and ' || v_part || ' ' || v_fractional_name;
    END IF;
    RETURN v_res;
END;
/
create or replace function FBH_INHD_TINH_TUOI(p_ng_sinh NUMBER) return number
AS
	v_ng_sinh DATE;p_tuoi NUMBER;
begin
	v_ng_sinh := TO_DATE(TO_CHAR(p_ng_sinh), 'YYYYMMDD');
    p_tuoi := EXTRACT(YEAR FROM SYSDATE) - EXTRACT(YEAR FROM v_ng_sinh);
    IF TO_DATE(TO_CHAR(SYSDATE, 'MMDD'), 'MMDD') < TO_DATE(TO_CHAR(v_ng_sinh, 'MMDD'), 'MMDD') THEN
        p_tuoi := p_tuoi - 1;
    END IF;
return p_tuoi;
end;
/
CREATE OR REPLACE FUNCTION FBH_IN_TEN_GOI(b_goi varchar2) 
RETURN nvarchar2 
AS
  b_ten_goi nvarchar2(500):=' ';b_i1 number;
BEGIN
  if trim(b_goi) is not null then
    select count(*) into b_i1 from bh_sk_goi where ma  = b_goi;
    if b_i1 <> 0 then select ten into b_ten_goi from bh_sk_goi where ma = b_goi;end if;
  end if;
  return b_ten_goi;
END;
/
CREATE OR REPLACE FUNCTION FBH_IN_SO_CHU(p_so IN NUMBER)
RETURN VARCHAR2
IS
    v_ketqua VARCHAR2(20);
BEGIN
    CASE p_so
        WHEN 1 THEN v_ketqua := N'nhất';
        WHEN 2 THEN v_ketqua := N'hai';
        WHEN 3 THEN v_ketqua := N'ba';
        WHEN 4 THEN v_ketqua := N'bốn';
        WHEN 5 THEN v_ketqua := N'năm';
        WHEN 6 THEN v_ketqua := N'sáu';
        WHEN 7 THEN v_ketqua := N'bảy';
        WHEN 8 THEN v_ketqua := N'tám';
        WHEN 9 THEN v_ketqua := N'chín';
        ELSE
            v_ketqua := NULL;
    END CASE;

    RETURN UPPER(v_ketqua);
END;
/
create or replace procedure PKH_JS_THAYx(b_js in out clob,b_cot varchar2)
as
    b_kq clob; b_lenh varchar2(1000):='{';
    a_cot pht_type.a_var; 
begin
-- DUong - thay cac cot bang 'X'
b_js:=FKH_JS_BONH(b_js);
PKH_CH_ARR(b_cot,a_cot);
for b_lp in 1..a_cot.count loop
    if b_lp>1 then b_lenh:=b_lenh||','; end if;
    b_lenh:=b_lenh||'"'||a_cot(b_lp)||'":"X"';
end loop;
b_lenh:=b_lenh||'}';
select json_mergepatch(b_js,b_lenh) into b_js from dual;
end;
/
CREATE OR REPLACE FUNCTION FBH_IN_MANG_TO_JSON(
    p_fields IN pht_type.a_var,      
    p_values IN pht_type.a_nvar,   
    p_cols   IN NUMBER,             
    p_rows   IN NUMBER               
) RETURN CLOB
IS
    l_json_arr json_array_t := json_array_t();
    l_json_obj json_object_t;
    l_ret      CLOB;
    l_idx      PLS_INTEGER := 1;
BEGIN
    FOR r IN 1..p_rows LOOP
        l_json_obj := json_object_t();
        FOR c IN 1..p_cols LOOP
            -- tất cả giá trị đều NVARCHAR2, đưa thẳng vào JSON
            l_json_obj.put(p_fields(c), p_values(l_idx));
            l_idx := l_idx + 1;
        END LOOP;
        l_json_arr.append(l_json_obj);
    END LOOP;

    l_ret := l_json_arr.to_clob;
    RETURN l_ret;
END;



/
CREATE OR REPLACE FUNCTION FBH_IN_CSO_CHU (
    p_number    IN NUMBER,
    p_currency  IN VARCHAR2
) RETURN VARCHAR2
IS
    TYPE t_words IS TABLE OF VARCHAR2(20) INDEX BY BINARY_INTEGER;
    v_digit_words t_words;
    v_unit_words  t_words;

    v_num_str VARCHAR2(100);
    v_int_part NUMBER;
    v_dec_part NUMBER;
    v_res VARCHAR2(4000) := '';
    v_part VARCHAR2(4000);
    v_index NUMBER := 0;
    v_chunk VARCHAR2(3);
    v_len NUMBER;

    v_currency_main VARCHAR2(50);
    v_currency_sub  VARCHAR2(50);

    -- hàm đọc 3 chữ số
    FUNCTION read_hundreds(p_chunk VARCHAR2) RETURN VARCHAR2 IS
        v_res VARCHAR2(200) := '';
        v_hundred NUMBER;
        v_ten NUMBER;
        v_unit NUMBER;
    BEGIN
        v_hundred := TO_NUMBER(SUBSTR(p_chunk,1,1));
        v_ten     := TO_NUMBER(SUBSTR(p_chunk,2,1));
        v_unit    := TO_NUMBER(SUBSTR(p_chunk,3,1));

        -- hàng trăm
        IF v_hundred > 0 THEN
            v_res := v_res || v_digit_words(v_hundred) || N' trăm';
        END IF;

        -- hàng chục
        IF v_ten > 1 THEN
            v_res := v_res || ' ' || v_digit_words(v_ten) || N' mươi';
        ELSIF v_ten = 1 THEN
            v_res := v_res || N' mười';
        ELSIF v_ten = 0 AND v_unit > 0 AND v_hundred > 0 THEN
            v_res := v_res || N' lẻ';
        END IF;

        -- hàng đơn vị
        IF v_unit > 0 THEN
            IF v_ten > 1 AND v_unit = 1 THEN
                v_res := v_res || N' mốt';
            ELSIF v_ten >= 1 AND v_unit = 5 THEN
                v_res := v_res || N' lăm';
            ELSE
                v_res := v_res || ' ' || v_digit_words(v_unit);
            END IF;
        END IF;

        RETURN TRIM(v_res);
    END;

BEGIN
    -- bảng chữ số
    v_digit_words(0) := N'không';
    v_digit_words(1) := N'một';
    v_digit_words(2) := N'hai';
    v_digit_words(3) := N'ba';
    v_digit_words(4) := N'bốn';
    v_digit_words(5) := N'năm';
    v_digit_words(6) := N'sáu';
    v_digit_words(7) := N'bảy';
    v_digit_words(8) := N'tám';
    v_digit_words(9) := N'chín';

    -- đơn vị nghìn, triệu, tỷ...
    v_unit_words(0) := '';
    v_unit_words(1) := N' nghìn';
    v_unit_words(2) := N' triệu';
    v_unit_words(3) := N' tỷ';
    v_unit_words(4) := N' nghìn tỷ';
    v_unit_words(5) := N' triệu tỷ';

    -- chọn đơn vị tiền tệ
    IF UPPER(p_currency) = N'VND' THEN
        v_currency_main := N'đồng';
        v_currency_sub  := 'xu';
    ELSIF UPPER(p_currency) = 'USD' THEN
        v_currency_main := N'đô la';
        v_currency_sub  := 'xu';
    ELSE
        v_currency_main := LOWER(p_currency);
        v_currency_sub  := 'xu';
    END IF;

    -- tách phần nguyên và thập phân
    v_int_part := TRUNC(p_number);
    v_dec_part := ROUND(MOD(p_number,1) * 100); -- lấy 2 số sau dấu phẩy

    -- đọc phần nguyên
    v_num_str := TO_CHAR(v_int_part);
    v_len := LENGTH(v_num_str);
    v_res := '';
    v_index := 0;

    WHILE v_len > 0 LOOP
        v_index := v_index + 1;
        v_chunk := LPAD(SUBSTR(v_num_str, GREATEST(v_len-2,1), LEAST(3,v_len)),3,'0');
        v_part := read_hundreds(v_chunk);

        IF v_part IS NOT NULL THEN
            v_res := v_part || v_unit_words(v_index-1) || ' ' || v_res;
        END IF;

        v_len := v_len - 3;
    END LOOP;

    v_res := INITCAP(TRIM(v_res)) || ' ' || v_currency_main;

    -- đọc phần thập phân nếu có
    IF v_dec_part > 0 THEN
        v_num_str := LPAD(TO_CHAR(v_dec_part),2,'0');
        v_part := read_hundreds('0' || v_num_str); -- xử lý như 2 chữ số
        v_res := v_res || ' ' || v_part || ' ' || v_currency_sub;
    END IF;

    RETURN UPPER(SUBSTR(LOWER(TRIM(v_res)), 1, 1)) || SUBSTR(LOWER(TRIM(v_res)), 2);
END;
/
drop function FBH_IN_CSO_NG
/
CREATE OR REPLACE FUNCTION FBH_IN_CSO_NG(b_so number,b_format VARCHAR2) 
RETURN varchar2 
AS
BEGIN
  return TO_CHAR(TO_DATE(TO_CHAR(b_so, '00000000'), 'YYYYMMDD'), b_format);
END;
/
CREATE OR REPLACE FUNCTION FBH_IN_GBT(b_ktru VARCHAR2, b_loai varchar2) 
RETURN VARCHAR2 
AS
    result_str nvarchar2(500);
    percent_part VARCHAR2(50);
    money_part VARCHAR2(50);
    v_temp VARCHAR2(3);
    b_tt nvarchar2(200):= ' ';
BEGIN
    v_temp := SUBSTR(b_ktru, 1, 3);
    IF INSTR(UPPER(v_temp), 'M') > 0 THEN
        b_tt:= N'% số tiền bảo hiểm';
    ELSE
        b_tt:= N'% số tiền tổn thất';
    END IF;

    if b_loai in('KVU','MVU') then
      if b_loai = 'KVU' then
        result_str := N'Khấu trừ/vụ: ';
      else
        result_str := N'Mức/vụ: ';
      end if;
      IF INSTR(b_ktru, '|') > 0 THEN
          percent_part := SUBSTR(b_ktru, 1, INSTR(b_ktru, '|') - 1);
          money_part := SUBSTR(b_ktru, INSTR(b_ktru, '|') + 1);
          result_str :=result_str || TO_NUMBER(REGEXP_SUBSTR(percent_part, '^\d+')) || b_tt || N', tối thiểu: ' || money_part || N' VND/cho mỗi vụ tổn thất';
      ELSE
          IF TO_NUMBER(REPLACE(b_ktru, ',', '')) < 100 THEN
              result_str :=result_str || TO_NUMBER(REGEXP_SUBSTR(b_ktru, '^\d+')) || b_tt;
          ELSE
              result_str :=result_str || N'Tối thiểu: ' || b_ktru || N' VND/cho mỗi vụ tổn thất';
          END IF;
      END IF;
    elsif b_loai = 'GVU' then
      result_str := N'Giới hạn/vụ: ';
      IF INSTR(b_ktru, '|') > 0 THEN
          percent_part := SUBSTR(b_ktru, 1, INSTR(b_ktru, '|') - 1);
          money_part := SUBSTR(b_ktru, INSTR(b_ktru, '|') + 1);
          result_str := result_str || TO_NUMBER(REGEXP_SUBSTR(percent_part, '^\d+')) || b_tt || N', tối đa: ' || money_part || N' VND/cho mỗi vụ tổn thất';
      ELSE
          IF TO_NUMBER(REGEXP_SUBSTR(b_ktru, '^\d+')) < 100 THEN
              result_str :=result_str || TO_NUMBER(REGEXP_SUBSTR(b_ktru, '^\d+')) || b_tt;
          ELSE
              result_str :=result_str || N'tối đa: ' || b_ktru || N' VND/cho mỗi vụ tổn thất';
          END IF;
      END IF;
    ELSE
      CASE b_loai
        WHEN '1' THEN
          result_str := N'thời hạn bảo hành: '|| b_ktru || N' tháng';
        WHEN '2' THEN
          result_str := N'Giới hạn thời gian kéo dài tối đa: '|| b_ktru || N' ngày';
        WHEN '3' THEN
          result_str :=  b_ktru || N' ngày';
        WHEN '4' THEN
          result_str := b_ktru || N'%';
        WHEN '5' THEN
          result_str := N'trong vòng '|| b_ktru || N' ngày';
        WHEN '6' THEN
          result_str := b_ktru || N' ngày';
        WHEN '7' THEN
          result_str := N'không giảm quá '|| b_ktru || N'% số tiền bảo hiểm';
        WHEN 'KH' THEN
          result_str := b_ktru;
        ELSE
          result_str := ' ';
      END CASE;
    end if;
    RETURN result_str;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RETURN '';
    WHEN OTHERS THEN
        RETURN '';
END;
/
drop FUNCTION FBH_TNCC_IN
/
CREATE OR REPLACE FUNCTION FBH_TNCC_IN(p_key IN VARCHAR2)
RETURN VARCHAR2 IS
  v_result NVARCHAR2(500);
BEGIN
  CASE p_key
    WHEN 'V' THEN
      v_result := N'Việt Nam';
    WHEN 'T' THEN
      v_result := N'Toàn Cầu';
    WHEN 'L' THEN
      v_result := N'Toàn cầu với điều kiện loại trừ Mỹ và Canada';
    WHEN 'O' THEN
      v_result := N'Occurrence';
    WHEN 'C' THEN
      v_result := N'Claim made';
    ELSE
      v_result := N'Key không hợp lệ';
  END CASE;

  RETURN v_result;
END;
/
drop FUNCTION FBH_CSO_TIEN
/
create or replace function FBH_CSO_TIEN( b_tien number,b_nt_tien varchar2 ) return varchar2
as
    v_result varchar2(100);
begin
    if b_tien = trunc(b_tien) then
        v_result := trim(to_char(b_tien,'999,999,999,999,999,999'));
    else
        v_result := trim(to_char(round(b_tien,2),'999,999,999,999,999,990.00'));
    end if;

    return v_result || ' ' || b_nt_tien;
end;
/

drop FUNCTION FBH_CSO_TIEN_KNT
/
CREATE OR REPLACE FUNCTION FBH_CSO_TIEN_KNT(b_tien number) 
RETURN varchar2 
AS
BEGIN
  return trim(TO_CHAR(b_tien, '999,999,999,999,999,999PR'));
END;
/
drop FUNCTION FBH_TONUM
/
CREATE OR REPLACE FUNCTION FBH_TONUM(b_in VARCHAR2)
RETURN NUMBER
AS
   b_num NUMBER;
BEGIN
   IF INSTR(b_in, '-') > 0 THEN
       b_num := TO_NUMBER(b_in, 'S9999999999999.999999', 'NLS_NUMERIC_CHARACTERS = ''.,''');
   ELSE
       b_num := TO_NUMBER(b_in, '9999999999999.999999', 'NLS_NUMERIC_CHARACTERS = ''.,''');
   END IF;
   RETURN b_num;
END;
/
drop FUNCTION FBH_TO_CHAR
/
CREATE OR REPLACE FUNCTION FBH_TO_CHAR(b_in number) 
RETURN varchar2 
AS
   b_result varchar2(100);
BEGIN
  b_result:=(CASE 
    WHEN MOD(b_in, 1) = 0 THEN  TO_CHAR(ROUND(b_in, 0), '9990', 'NLS_NUMERIC_CHARACTERS=''.,''') 
    ELSE TO_CHAR(ROUND(b_in, 4), '9990D9999', 'NLS_NUMERIC_CHARACTERS=''.,''') end);
  return b_result;
END;

/
drop FUNCTION get_kbt_value
/
CREATE OR REPLACE FUNCTION get_kbt_value(c1_value IN VARCHAR2, dt_kbt IN CLOB) RETURN VARCHAR2 IS
  b_lenh VARCHAR2(2000);
  dk_ma_dk pht_type.a_var;
  dk_kbt pht_type.a_var;
  b_result VARCHAR2(2000);
BEGIN
  IF dt_kbt IS NOT NULL THEN
    b_lenh := FKH_JS_LENH('ma,kbt');
    EXECUTE IMMEDIATE b_lenh BULK COLLECT INTO dk_ma_dk, dk_kbt USING dt_kbt;

    FOR b_i1 IN 1..dk_ma_dk.COUNT LOOP
      IF dk_ma_dk(b_i1) = c1_value THEN
        b_result := dk_kbt(b_i1);
        EXIT;
      END IF;
    END LOOP;
  END IF;

  RETURN NVL(b_result,'');
  EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL; -- Or handle the exception as needed
END;
/
drop FUNCTION FBH_MKT
/
CREATE OR REPLACE FUNCTION FBH_MKT(b_ktru VARCHAR2, b_nt_tien varchar2) 
RETURN VARCHAR2 
AS
    result_str nvarchar2(500);
    percent_part VARCHAR2(50);
    money_part VARCHAR2(50);
    b_i1 number:=0;b_kvu nvarchar2(500);
BEGIN

    if INSTR(UPPER(b_ktru), 'MTN') > 0 then
      b_kvu:= N'% số tiền bảo hiểm';
    else
      b_kvu:= N'% số tiền tổn thất';
    end if;
    IF INSTR(b_ktru, '|') > 0 THEN
        percent_part := SUBSTR(b_ktru, 1, INSTR(b_ktru, '|') - 1);
        money_part := SUBSTR(b_ktru, INSTR(b_ktru, '|') + 1);
        result_str := percent_part || b_kvu || N', tối thiểu: ' || money_part || ' ' || b_nt_tien ||N'/cho mỗi vụ tổn thất.';
    ELSE
        b_i1:= TO_NUMBER(REGEXP_SUBSTR(REPLACE(b_ktru, ',', ''), '^\d+'));
        IF b_i1 < 100 THEN
            result_str := b_i1 || b_kvu;
        ELSE
            result_str := N'Tối thiểu: ' || FBH_CSO_TIEN(b_i1,b_nt_tien) ||N'/cho mỗi vụ tổn thất.';
        END IF;
    END IF;

    RETURN result_str;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RETURN N'Không áp dụng mức khấu trừ';
    WHEN OTHERS THEN
        RETURN N'Không áp dụng mức khấu trừ';
END;
/
drop FUNCTION FBH_IN_SUBSTR
/
CREATE OR REPLACE FUNCTION FBH_IN_SUBSTR(b_nd nvarchar2, b_char varchar2, b_loai varchar2) 
RETURN nvarchar2 
AS
  b_result nvarchar2(1000):= ' ';
BEGIN
    if b_loai = 'S' then
      b_result := SUBSTR(b_nd, INSTR(b_nd, b_char) + 1);
    else
       b_result := SUBSTR(b_nd, 1, INSTR(b_nd, b_char) - 1);
    end if;
    return b_result;
END;
/
CREATE OR REPLACE FUNCTION fbh_in_tinh_tlp (
    p_pttsb IN VARCHAR2,
    p_ptts  IN VARCHAR2,
    p_ppts  IN VARCHAR2,
    p_tien  IN NUMBER
) RETURN NUMBER
IS
    b_pttsb NUMBER;
    b_ptts  NUMBER;
    b_tlp   NUMBER;
BEGIN
    b_pttsb := NVL(TO_NUMBER(p_pttsb), 0);
    IF p_ptts IS NOT NULL THEN
        b_ptts := TO_NUMBER(p_ptts);
    END IF;
    --  ptts is null
    IF p_ptts IS NULL or (p_ptts = 0 or trim(p_ppts) is null) THEN
        IF b_pttsb > 100 THEN
            b_tlp := (b_pttsb / p_tien) * 100;
        ELSE
            b_tlp := b_pttsb;
        END IF;

        RETURN b_tlp;
    END IF;
    --ptts is not null
    --pttsb > 100 quy doi
    IF b_pttsb > 100 THEN
        b_pttsb := b_pttsb / p_tien;
    END IF;

    CASE UPPER(p_ppts)
        WHEN 'GP' THEN
            b_tlp := b_pttsb - b_pttsb * (b_ptts / 100);
        WHEN 'GG' THEN
            b_tlp := b_pttsb - (b_ptts * 100/ p_tien);
        WHEN 'GT' THEN
            b_tlp := b_pttsb - b_ptts;
        WHEN 'DP' THEN
            b_tlp := b_ptts;
        WHEN 'DG' THEN
            b_tlp := (b_ptts / p_tien) * 100;
        ELSE
            b_tlp := 0;
    END CASE;
	
    RETURN b_tlp;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RETURN NULL;
    WHEN OTHERS THEN
        RETURN NULL;
END;
/
CREATE OR REPLACE FUNCTION FBH_MKT_TAU(b_ktru VARCHAR2, b_nt_tien varchar2) 
RETURN VARCHAR2 
AS
    result_str nvarchar2(500);
    percent_part VARCHAR2(50);
    money_part VARCHAR2(50);
    b_i1 number:=0;b_kvu nvarchar2(500);
BEGIN

    if INSTR(UPPER(b_ktru), 'MTN') > 0 then
      b_kvu:= N'% số tiền bảo hiểm';
    else
      b_kvu:= N'% số tiền bồi thường';
    end if;
    IF INSTR(b_ktru, '|') > 0 THEN
        percent_part := SUBSTR(b_ktru, 1, INSTR(b_ktru, '|') - 1);
        money_part := SUBSTR(b_ktru, INSTR(b_ktru, '|') + 1);
        result_str := percent_part || b_kvu || N', tối thiểu: ' || money_part || ' ' || b_nt_tien ||N'/cho mỗi vụ tổn thất.';
    ELSE
        b_i1:= TO_NUMBER(REGEXP_SUBSTR(REPLACE(b_ktru, ',', ''), '^\d+'));
        IF b_i1 < 100 THEN
            result_str := b_i1 || b_kvu;
        ELSE
            result_str := N'Tối thiểu: ' || FBH_CSO_TIEN(b_i1,b_nt_tien) ||N'/cho mỗi vụ tổn thất.';
        END IF;
    END IF;

    RETURN result_str;
EXCEPTION
    WHEN VALUE_ERROR THEN
        RETURN N'Không áp dụng mức khấu trừ';
    WHEN OTHERS THEN
        RETURN N'Không áp dụng mức khấu trừ';
END;
/
CREATE OR REPLACE FUNCTION FBH_ROMAN_NEXT(p_roman IN VARCHAR2) RETURN VARCHAR2 IS
    v_num NUMBER;
    v_next_num NUMBER;
    v_roman_values pht_type.a_var;
    v_roman_chars pht_type.a_var;
    v_result VARCHAR2(100) := '';
    v_index NUMBER;
BEGIN
    -- Initialize Roman numeral mappings
    v_roman_chars(1) := 'I'; v_roman_values(1) := 1;
    v_roman_chars(2) := 'V'; v_roman_values(2) := 5;
    v_roman_chars(3) := 'X'; v_roman_values(3) := 10;
    v_roman_chars(4) := 'L'; v_roman_values(4) := 50;
    v_roman_chars(5) := 'C'; v_roman_values(5) := 100;
    v_roman_chars(6) := 'D'; v_roman_values(6) := 500;
    v_roman_chars(7) := 'M'; v_roman_values(7) := 1000;
    
    -- Convert Roman to number
    v_num := 0;
    FOR i IN 1..LENGTH(p_roman) LOOP
        FOR j IN 1..7 LOOP
            IF SUBSTR(p_roman, i, 1) = v_roman_chars(j) THEN
                IF i < LENGTH(p_roman) AND v_roman_values(j) < v_roman_values(j+1) THEN
                    v_num := v_num - v_roman_values(j);
                ELSE
                    v_num := v_num + v_roman_values(j);
                END IF;
                EXIT;
            END IF;
        END LOOP;
    END LOOP;
    
    v_next_num := v_num + 1;
    
    -- Convert next number to Roman
    WHILE v_next_num >= 1000 LOOP v_result := v_result || 'M'; v_next_num := v_next_num - 1000; END LOOP;
    IF v_next_num >= 900 THEN v_result := v_result || 'CM'; v_next_num := v_next_num - 900; END IF;
    IF v_next_num >= 500 THEN v_result := v_result || 'D'; v_next_num := v_next_num - 500; END IF;
    IF v_next_num >= 400 THEN v_result := v_result || 'CD'; v_next_num := v_next_num - 400; END IF;
    WHILE v_next_num >= 100 LOOP v_result := v_result || 'C'; v_next_num := v_next_num - 100; END LOOP;
    IF v_next_num >= 90 THEN v_result := v_result || 'XC'; v_next_num := v_next_num - 90; END IF;
    IF v_next_num >= 50 THEN v_result := v_result || 'L'; v_next_num := v_next_num - 50; END IF;
    IF v_next_num >= 40 THEN v_result := v_result || 'XL'; v_next_num := v_next_num - 40; END IF;
    WHILE v_next_num >= 10 LOOP v_result := v_result || 'X'; v_next_num := v_next_num - 10; END LOOP;
    IF v_next_num >= 9 THEN v_result := v_result || 'IX'; v_next_num := v_next_num - 9; END IF;
    IF v_next_num >= 5 THEN v_result := v_result || 'V'; v_next_num := v_next_num - 5; END IF;
    IF v_next_num >= 4 THEN v_result := v_result || 'IV'; v_next_num := v_next_num - 4; END IF;
    WHILE v_next_num >= 1 LOOP v_result := v_result || 'I'; v_next_num := v_next_num - 1; END LOOP;
    
    RETURN v_result;
END FBH_ROMAN_NEXT;
/
CREATE OR REPLACE FUNCTION FBH_TINH_THOI_GIAN_SD(p_nam_sx IN VARCHAR2) RETURN NUMBER
IS
    v_nam_sx NUMBER;
    v_thang_sx NUMBER;
    v_nam_hien_tai NUMBER;
    v_thang_hien_tai NUMBER;
    v_thoi_gian_sd NUMBER;
BEGIN
    v_thang_sx := TO_NUMBER(SUBSTR(p_nam_sx, 1, INSTR(p_nam_sx, '/') - 1));
    v_nam_sx := TO_NUMBER(SUBSTR(p_nam_sx, INSTR(p_nam_sx, '/') + 1));
    
    v_nam_hien_tai := EXTRACT(YEAR FROM SYSDATE);
    v_thang_hien_tai := EXTRACT(MONTH FROM SYSDATE);
    
    v_thoi_gian_sd := (v_nam_hien_tai - v_nam_sx) + (v_thang_hien_tai - v_thang_sx) / 12;
    
    RETURN ROUND(v_thoi_gian_sd, 1);
END FBH_TINH_THOI_GIAN_SD;
/