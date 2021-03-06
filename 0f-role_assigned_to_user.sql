-- 
-- For RFo v1.2 (GS)
-- For RFo v2.0 (GS)

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool role_assigned_to_user.log

declare
  i INTEGER;
  j INTEGER;
  v_user_id   NUMBER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_user_name varchar2(100);
  v_role_id varchar2(100);
  v_object_name varchar2(100);
  v_role_ids t_tab := t_tab();
   v_users t_tab;
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
t_tab('AA','Y','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX1','','Y','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX2','','','Y','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX3','','','','Y','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX4','','','','','Y','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX5','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX6','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX7','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX8','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX9','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX10','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX11','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX12','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX13','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX14','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX15','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX16','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX17','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX18','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX19','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX20','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX21','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX22','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX23','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX24','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX25','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX26','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX27','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX28','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX29','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX30','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX31','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX32','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX33','','','','','','','','','','','','','','',''),
t_tab('UXXXXXXXXXXXXXXXXXXXXXXXXXX34','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX1','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX2','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX3','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX4','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX5','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX6','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX7','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX8','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX9','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX10','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX11','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX12','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX13','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX14','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX15','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX16','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX17','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX18','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX19','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX20','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX21','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX22','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX23','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX24','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX25','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX26','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX27','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX28','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX29','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX30','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX31','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX32','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX33','','','','','','','','','','','','','','',''),
t_tab('UMMMXXXXXXXXXXXXXXXXXXXXXXX34','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX1','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX2','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX3','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX4','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX5','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX6','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX7','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX8','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX9','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX10','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX11','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX12','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX13','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX14','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX15','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX16','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX17','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX18','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX19','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX20','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX21','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX22','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX23','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX24','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX25','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX26','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX27','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX28','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX29','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX30','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX31','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX32','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX33','','','','','','','','','','','','','','',''),
t_tab('UGGGXXXXXXXXXXXXXXXXXXXXXXX34','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX1','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX2','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX3','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX4','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX5','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX6','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX7','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX8','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX9','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX10','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX11','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX12','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX13','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX14','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX15','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX16','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX17','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX18','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX19','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX20','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX21','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX22','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX23','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX24','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX25','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX26','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX27','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX28','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX29','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX30','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX31','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX32','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX33','','','','','','','','','','','','','','',''),
t_tab('UAGGXXXXXXXXXXXXXXXXXXXXXXX34','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX1','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX2','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX3','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX4','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX5','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX6','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX7','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX8','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX9','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX10','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX11','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX12','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX13','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX14','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX15','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX16','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX17','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX18','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX19','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX20','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX21','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX22','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX23','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX24','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX25','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX26','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX27','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX28','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX29','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX30','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX31','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX32','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX33','','','','','','','','','','','','','','',''),
t_tab('UBGGXXXXXXXXXXXXXXXXXXXXXXX34','','','','','','','','','','','','','','','')
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

  -- delete existing role assigned to user
  FOR i in v_role_ids.first..v_role_ids.last LOOP
    delete from grantee_priv where grantee_id > 0 and priv_id = v_role_ids(i);
  END LOOP;
  
  -- loop the user list
 -- loop the user list
   FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_user_name:=v_access(1);
    
		begin
 			select user_id into v_user_id from cd_users where user_name=v_user_name;
		exception
		 when no_data_found then
          raise_application_error(-20000, 'Can not find the User: '||v_user_name);
        when others then
        	raise;
    end;	        
    	        
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_role_id := v_role_ids(j);

      -- grant the access 
      IF  v_access_type = 'Y' THEN

					 insert into grantee_priv (grantee_id, priv_id)  values (v_user_id , v_role_id) ;

          dbms_output.put_line('-- User '||v_user_name||'['||v_user_id||'] is assigned to role '||v_user_group(j)||'['||v_role_id||'] role');
    	    
      

      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  
  -- update the statistics
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  
  dbms_output.put_line('Assigning user to role... Done.');
  
    	
exception
  when others then  
	  rollback; 
	  raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));            
END;
/

spool off
exit;
