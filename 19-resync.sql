-- wijaya.kusumo v2.0
-- Re-generate prolicy and triggers
-- For RFo v1.2
-- Test in RFO V2.0


WHENEVER SQLERROR EXIT SQL.SQLCODE

spool resync.log
set serverout on

declare
  l_proc        VARCHAR2(60):='uam_resync';
  l_step        VARCHAR2(3) := '000';  
  l_start_time	DATE;
  V_DROP_STATEMENT VARCHAR2(200);

begin
  pack_context.contextid_open(1);
  
  pack_log.log_begin('RESYNC UAM',null,null,'Generate underlying UAM related objects');
  
  l_step:='010';
  pack_log.log_write('I','F',l_proc,l_step,'Gather tables statistics',null);
  
  l_step:='011';
  dbms_output.put_line('Gather ADMIN table statistics....');
  pack_stats.gather_admin_schema_stats();
  

  pack_log.log_write('I','T','UAM Resync',null,'Gather table statistics...', null);
  dbms_output.put_line('Gather table statistics...');
  pack_stats.gather_table_stats ('GRANTEE_PRIV');
  pack_stats.gather_table_stats ('GRANTEE_MEMBER');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('CD_USERS');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('PRIV_ROLE_PRIV');
  pack_stats.gather_table_stats ('PRIV_ROLE');
  pack_stats.gather_table_stats ('PRIV');
  pack_stats.gather_table_stats ('PRIV_WIN');
  pack_stats.gather_table_stats ('PRIV_NODE');
  pack_stats.gather_table_stats ('PRIV_DW');
  pack_stats.gather_table_stats ('PRIV_MENU');
  pack_stats.gather_table_stats ('PRIV_BROWSER');
  pack_stats.gather_table_stats ('PRIV_PROCESS');
  pack_stats.gather_table_stats ('PRIV_ACTION');
  pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_CONTEXT');
  pack_stats.gather_table_stats ('PRIV_TABLE');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');

  dbms_output.put_line('Run gener_access_policy....');
  l_step:='020';
  pack_log.log_write('I','F',l_proc,l_step,'Run gener_access_policy....',null);
  l_start_time:=sysdate;
	pack_access.gener_access_policy();
	pack_log.log_write('I','F',l_proc,l_step,'Completed in '||pack_utils.diff_time_hhmmss(l_start_time),null);
	dbms_output.put_line('... done in '||pack_utils.diff_time_hhmmss(l_start_time));
	
	dbms_output.put_line('Run gener_access_trigger....');
	l_step:='030';
  pack_log.log_write('I','F',l_proc,l_step,'Run gener_access_trigger....',null);
  l_start_time:=sysdate;
	pack_access.gener_access_trigger();
	pack_log.log_write('I','F',l_proc,l_step,'Completed in '||pack_utils.diff_time_hhmmss(l_start_time),null);
	dbms_output.put_line('... done in '||pack_utils.diff_time_hhmmss(l_start_time));
	
	dbms_output.put_line('Run update_context_access_list....');
	l_step:='040';
  pack_log.log_write('I','F',l_proc,l_step,'Run update_context_access_list....',null);
  l_start_time:=sysdate;
	pack_access.update_context_access_list();
	pack_log.log_write('I','F',l_proc,l_step,'Completed in '||pack_utils.diff_time_hhmmss(l_start_time),null);
	dbms_output.put_line('... done in '||pack_utils.diff_time_hhmmss(l_start_time));

----------------------------------------------------------------
--- Drop the unused policy access functions
----------------------------------------------------------------
  dbms_output.put_line('Dropping ununsed Policy Access Functions...');
  pack_log.log_write('I','T','UAM Resync',null,'Dropping ununsed Policy Access Functions...', null);
  FOR REC IN (
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'FUNCTION'
      AND OBJECT_NAME LIKE 'F\_A\_%' ESCAPE '\'
      AND OBJECT_NAME NOT IN(
        SELECT TABLE_NAME
        FROM CD_FDW_STRUCTURE
        WHERE OBJECT_TYPE='FUNCTION'
        AND TABLE_NAME LIKE 'F\_A\_%' ESCAPE '\'
      )
    )
  LOOP
    V_DROP_STATEMENT := 'DROP FUNCTION ' || REC.OBJECT_NAME;
	
    EXECUTE IMMEDIATE V_DROP_STATEMENT;
  END LOOP;

  pack_log.log_end();  
  
  dbms_output.put_line('Resync UAM settings... done.');
  
exception
  when others then  
	  rollback;
	  pack_log.log_end();  
	  raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));        
END;
/

spool off


exit;
