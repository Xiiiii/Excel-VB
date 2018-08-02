-- wijaya.kusumo v2.0
-- For RFo v1.2

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

set define off

spool apply_application_access.log

declare
  i INTEGER;
  j INTEGER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_group_id varchar2(100);
  v_object_name varchar2(100);
  v_group_ids t_tab := t_tab();
  v_access t_tab;
  v_action_type_id INTEGER;
  
    -- AUTO:Begin.  System tag, do not modify this line
  v_user_group t_tab := t_tab(
'TEST0',
'TEST1',
'TEST2',
'TEST3',
'TEST444',
'TEST5',
'TEST6',
'TEST77',
'TEST88',
'TEST900',
'TEST11',
'TEST111'
   );
  v_access_list t_list := t_list(
t_tab('Dashboard','Y','Y','Y','Y','','Y','Y','','','','',''),
t_tab('RiskAuthority','Y','Y','Y','Y','','Y','Y','','','','',''),
t_tab('Scenario Analyzer','Y','Y','Y','Y','','Y','Y','','','','',''),
t_tab('Financial & Risk Datamart','Y','Y','Y','Y','','Y','Y','','','','',''),
t_tab('Administration','Y','Y','Y','Y','','Y','Y','','','','',''),
t_tab('System Tools','Y','Y','Y','Y','','Y','Y','','','','',''),
t_tab('Dashboard Configuration','Y','Y','Y','Y','','Y','Y','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line			
 
 
--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  
  pack_context.contextid_open(1);  
  v_group_ids.extend(v_user_group.count);
  dbms_output.enable(1000000); 
  dbms_output.put_line('Setting ACTION access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  
  -- check the user group if exists
  For i in v_user_group.first.. v_user_group.last LOOP
    begin
    	select grantee_id into v_group_ids(i) from v_grantee where grantee_type='G' and group_name=v_user_group(i);
    exception
      when no_data_found then
        raise_application_error(-20000, 'Can not find the User Group: '||v_user_group(i));
      when others then
      	raise;
    end;
    dbms_output.put_line('--'||v_user_group(i)||' user group is OK');
  END LOOP;

  dbms_output.put_line('--Deleting old UAM entries...');
  delete from priv p where exists (select 1 from PRIV_OTHER_APP pp where pp.priv_id=p.priv_id);
  
  dbms_output.put_line('--Creating new UAM entries...');
  
  select ACTION_TYPE_ID into v_action_type_id from access_obj_type_action where action_TYPE='OPEN';
  
  -- loop the UAM setting
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_object_name :=v_access(1);
    if v_object_name = 'System Tools' or v_object_name = 'Dashboard Configuration' then
		v_object_name :='- '||v_object_name;
	end if;
	
    dbms_output.put_line('----Inserting default UAM entry...');
    -- insert the DEFAULT access rules: deny all with lowest priority
    insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, action_type_id, object_name) 
		values ( seq_priv.nextval, 0, 0, 'N', 99, 'other_app',v_action_type_id, v_object_name);
 	 
    dbms_output.put_line('----Object ID:'||v_object_name||' access:N priority:99');
      
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_group_id := v_group_ids(j);

      -- grant the access 
      IF  v_access_type = 'Y' THEN
        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, action_type_id, object_name) 
					values ( seq_priv.nextval, v_group_id, 0, v_access_type, 10, 'other_app',v_action_type_id, v_object_name);
        
        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10');

      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  -- update the statistics
  dbms_output.put_line('Gather table statistics....');
  pack_stats.gather_table_stats('PRIV');
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  pack_stats.gather_table_stats('PRIV_ACTION');

  pack_stats.gather_table_stats('PRIV_DW');
  pack_stats.gather_table_stats('PRIV_WIN');
  pack_stats.gather_table_stats ('GRANTEE_MEMBER');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('CD_USERS');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('PRIV_ROLE_PRIV');
  pack_stats.gather_table_stats ('PRIV_ROLE');
  pack_stats.gather_table_stats ('PRIV_NODE');
  pack_stats.gather_table_stats ('PRIV_MENU');
  pack_stats.gather_table_stats ('PRIV_BROWSER');
  pack_stats.gather_table_stats ('PRIV_PROCESS');
  pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_CONTEXT');
  pack_stats.gather_table_stats ('PRIV_TABLE');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');
  
  dbms_output.put_line('Setting Application access matrix... done.');
exception
  when others then  
	  rollback;
	  raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));            
END;
/

spool off

exit;
