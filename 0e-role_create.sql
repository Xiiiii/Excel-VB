-- 
-- For RFo v1.2 (GS)
-- For RFo v2.0 (GS)


set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool role_create.log

declare
  i INTEGER;
  v_role VARCHAR2(255);
  type t_tab is table of varchar2(100);
 	
--AUTO:Begin.  System tag, do not modify this line
  v_user_group t_tab := t_tab(
'Risk Administrator1',
'Risk Administrator2',
'Risk Administrator3',
'Risk Administrator4',
'Risk Administrator5',
'Risk Administrator6',
'Risk Administrator7',
'RiskOrigins Administrator',
'RiskOrigins User',
'RoleDashboard',
'Scenario Analyzer User',
'MART Administrator',
'Reporting Services Admin',
'NO_FRT_ROLE',
'BXIZ_ENQ12'
   );
--AUTO:End.  System tag, do not modify this line	
   
--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  
  pack_context.contextid_open(1);  
  
  dbms_output.put_line('Creating ROLE...');
  
  -- check the role if exists
  For i in v_user_group.first.. v_user_group.last LOOP
    begin
    	select v_user_group(i) into v_role from priv_role where role_name=v_user_group(i);
        dbms_output.put_line('Role EXIST: '||v_user_group(i));
    exception
      when no_data_found then
        insert into v_priv_grantee (priv_id, grant_access, priority, priv_type, role_name)
             values (seq_priv.nextval, 'Y', 0, 'role', v_user_group(i));

        dbms_output.put_line('--'||v_user_group(i)||' role created');
      when others then
      	raise;
    end;
  END LOOP;
  
  commit;
  
  pack_stats.gather_table_stats('GRANTEE_PRIV'); 
  pack_stats.gather_table_stats('PRIV_ROLE'); 
   
  dbms_output.put_line('DONE.');

exception
  when others then  
	  rollback;
	  raise;          
END;
/

spool off
exit;
 
