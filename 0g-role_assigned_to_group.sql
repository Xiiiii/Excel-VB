-- 
-- For RFo v1.2 (GS)
-- For RFo v2.0 (GS)


set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool role_assigned_to_group.log

declare
  i INTEGER;
  j INTEGER;
  v_group_id   NUMBER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_group_name varchar2(100);
  v_role_id varchar2(100);
  v_object_name varchar2(100);
  v_role_ids t_tab := t_tab();
  v_groups t_tab;
  v_access t_tab;
  v_access_type varchar2(100);
  
-- AUTO:Begin.  System tag, do not modify this line
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
  v_access_list t_list := t_list(
t_tab('TEST0','Y','','','','','','','','','','','','','',''),
t_tab('TEST1','','Y','','','','','','','','','','','','',''),
t_tab('TEST2','','','Y','','','','','','','','','','','',''),
t_tab('TEST3','','','','Y','Y','','','','','','','','','',''),
t_tab('TEST444','','','','','','','','','','','','','','',''),
t_tab('TEST5','','','','','','','','','','','','','','',''),
t_tab('TEST6','','','','','','','','','','','','','','',''),
t_tab('TEST77','','','','','','','','','','','','','','',''),
t_tab('TEST88','','','','','','','','','','','','','','',''),
t_tab('TEST900','','','','','','','','','','','','','','',''),
t_tab('TEST11','','','','','','','','','','','','','','',''),
t_tab('TEST111','','','','','','','','','','','','','','','')
   );
-- AUTO:End.  System tag, do not modify this line
  
--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  
  pack_context.contextid_open(1);  
  v_role_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Assigning user to role...');
  dbms_output.put_line('Check ROLE existence...');
    
  -- check the role if exists
  For i in v_user_group.first.. v_user_group.last LOOP
    begin
    	select priv_id into v_role_ids(i) from priv_role where role_name=v_user_group(i);
    exception
      when no_data_found then
        raise_application_error(-20000, 'Can not find the ROLE: '||v_user_group(i));
      when others then
      	raise;
    end;
    dbms_output.put_line('--'||v_user_group(i)||' role is OK');
  END LOOP;


  -- delete existing role assigned to group
  FOR i in v_role_ids.first..v_role_ids.last LOOP
    delete from grantee_priv where grantee_id <= 0 and priv_id = v_role_ids(i);
  END LOOP;
  
  -- loop the group list
   FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_group_name:=v_access(1);
    
		begin
 			 select grantee_id into v_group_id from v_grantee where grantee_type='G' and group_name=v_group_name;
		exception
		 when no_data_found then
          raise_application_error(-20000, 'Can not find the Group: '||v_group_name);
        when others then
        	raise;
    end;	        
    	        
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_role_id := v_role_ids(j);

      -- grant the access 
      IF  v_access_type = 'Y' THEN

					 insert into grantee_priv (grantee_id, priv_id)  values (v_group_id , v_role_id) ;
          dbms_output.put_line('-- Group '||v_group_name||'['||v_group_id||'] is assigned with '||v_user_group(j)||'['||v_role_id||'] role');
    	    

      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  
  -- update the statistics
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  
  dbms_output.put_line('Assigning group to role... Done.');
  
    	
exception
  when others then  
	  rollback; 
	  raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));            
END;
/

spool off
exit;
