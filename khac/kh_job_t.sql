--DBMS_SCHEDULER.ENABLE('JTBH_GHEP');
--DBMS_SCHEDULER.DISABLE('JTBH_GHEP');
--DBMS_SCHEDULER.RUN_JOB('JTBH_GHEP');

drop table kh_job_loi;
create table kh_job_loi(
    so_id number,
    ten varchar2(20),
    tgian date,
    loi varchar2(500));
/
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name            => 'JTBH_GHEP',
    job_type            => 'STORED_PROCEDURE',
    job_action          => 'PTBH_GHEP_TD',
    start_date          => SYSTIMESTAMP,
    repeat_interval     => 'FREQ=MINUTELY; INTERVAL=5;', -- Chay moi 5 phut
    enabled             => TRUE,
    comments            => 'Ghep tai co dinh tu dong'
  );
END;
/
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name            => 'JBH_KT_HTOAN',
    job_type            => 'STORED_PROCEDURE',
    job_action          => 'PBH_KT_TD',
    start_date          => SYSTIMESTAMP,
    repeat_interval     => 'FREQ=MINUTELY; INTERVAL=5;', -- Chay moi 5 phut
    enabled             => TRUE,
    comments            => 'Hach toan tu dong'
  );
 END;
/
BEGIN
DBMS_SCHEDULER.CREATE_JOB (
    job_name            => 'JBH_SLI_NGAY',
    job_type            => 'STORED_PROCEDURE',
    job_action          => 'PBH_SLI_NG',
    start_date          => SYSTIMESTAMP,
    repeat_interval     => 'FREQ=DAILY; BYHOUR=01; BYMINUTE=00', -- Chay nua dem
    enabled             => TRUE,
    comments            => 'Tong hop so lieu phat sinh'
  );
  END;
/

