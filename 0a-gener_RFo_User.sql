
WHENEVER SQLERROR EXIT SQL.SQLCODE

call pack_context.contextid_open(1);

-------------------------------------------
-- print the user_list
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading off
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_user_list.log

select 
  user_name from cd_users where user_id<>1 order by user_id;

spool off
exit;