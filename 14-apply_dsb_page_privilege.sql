------------------------------------------------------------------
-- Dashboard v2.x - RFO v1.1
-- Ngah Ting Lim v1.0
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    LB                  v2.3        Added print to log_table
--    RFO v2.0
------------------------------------------------------------------

-- Grant Access:
--    Y=Full Access
--    N=No Access
--    P=Predicate

--Access Type:
--    S=Read
--    W=Write
--    I=Insert
--    U=Update
--    D=Delete    

-- file size < 43KB to avoid PLS-00123: program too large (Diana nodes) error

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool apply_dsb_page.log

declare
  l_proc        VARCHAR2(60):='uam_apply_dsb_section_access';
  l_step        VARCHAR2(3) := '000';
  i INTEGER;
  j INTEGER;
  v_id number;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_group_name varchar2(100);
  v_role_name varchar2(200);
  v_object_name varchar2(100);
  v_group_names t_tab := t_tab();
  v_role_names t_tab := t_tab();
  v_access t_tab;
  
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
'RoleDashboard',
'RiskOrigins User',
'Scenario Analyzer User',
'MART Administrator',
'Reporting Services Admin',
'NO_FRT_ROLE',
'BXIZ_ENQ12'
   );
  v_access_list t_list := t_list(
t_tab('08970754-7229-496A-AAC2-DAC5EA539B30','','','','','','','','','Y','RO','','','','',''),
t_tab('0C7E996A-9DEF-4A9A-AE94-72BE40FD6097','','','','','','','','','Y','RO','','','','',''),
t_tab('0D559BD8-8969-4836-B727-AED62ECB2CCF','','','','','','','','','','','','','','',''),
t_tab('13B37910-9B45-441C-BCD5-FADF3478583B','','','','','','','','','','','','','','',''),
t_tab('173F4D56-A8C8-41E6-8EA9-94C86D545EEE','','','','','','','','','','','','','','',''),
t_tab('178E9C41-66CC-429B-A82C-F582BAFA0B2A','','','','','','','','','','','','','','',''),
t_tab('2A11B093-CF5B-4AFC-9445-519B0D8B5BCC','','','','','','','','','','','','','','',''),
t_tab('346D1B7F-9976-498D-A577-6CA02530463B','','','','','','','','','','','','','','',''),
t_tab('3B600917-E56F-461A-A2C3-B35A7A76B6A5','','','','','','','','','','','','','','',''),
t_tab('585956B5-1C2A-4623-8344-519EBDE3F709','','','','','','','','','','','','','','',''),
t_tab('619D00D6-7F04-49E3-9AE9-F641852D07EF','','','','','','','','','','','','','','',''),
t_tab('67BC8504-0419-4D42-A83E-19D5E29E0D8F','','','','','','','','','','','','','','',''),
t_tab('6C9731B4-1E26-4B2F-B9A6-7FF15AC10C6E','','','','','','','','','','','','','','',''),
t_tab('76BEF300-605A-46F2-A174-F713018BF217','','','','','','','','','','','','','','',''),
t_tab('7BADF4E5-191B-4F00-8CD2-DE2642006470','','','','','','','','','','','','','','',''),
t_tab('8F2E9357-30A7-47CE-A208-ACBA62B52C55','','','','','','','','','','','','','','',''),
t_tab('96A5908A-8A23-4AFC-BA66-AC1EB9C90B74','','','','','','','','','','','','','','',''),
t_tab('AA50F822-0975-4031-ABFD-3946A8B734F6','','','','','','','','','','','','','','',''),
t_tab('AD8713E2-401D-40C0-9192-024A3E42682A','','','','','','','','','','','','','','',''),
t_tab('C04FB62C-8375-4883-98C6-E252FE792D58','','','','','','','','','','','','','','',''),
t_tab('C0F03599-F789-4BD5-8031-FEE1DF8F0CE9','','','','','','','','','','','','','','',''),
t_tab('C71F1D7F-CAC6-4AB1-ACD4-21BB55CECEB0','','','','','','','','','','','','','','',''),
t_tab('E08465D9-F535-47BB-83ED-26A916541BCD','','','','','','','','','','','','','','',''),
t_tab('EC424CC8-105B-422A-A59B-937599C99B08','','','','','','','','','','','','','','',''),
t_tab('F1348EE3-58FC-42F0-B7AB-1602CD2BB5B0','','','','','','','','','','','','','','','')
   );
-- AUTO:End.  System tag, do not modify this line

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY DSB PAGE ACCESS',null,null,'Apply DSB PAGE UAM!');
  v_group_names.extend(v_user_group.count);
  v_role_names.extend(v_user_role.count);
  
  l_step := '010';
  dbms_output.put_line('Setting Page access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting DSB PAGE access ...',null);
  
  -- check the user group if exists
  l_step := '020';
  For i in v_user_group.first.. v_user_group.last LOOP
    begin
    	select grantee_name into v_group_names(i) from v_grantee where grantee_type='G' and group_name=v_user_group(i);
    exception
      when no_data_found then
        raise_application_error(-20000, 'Can not find the User Group: ');
      when others then
      	raise;
    end;
    dbms_output.put_line('--'||v_user_group(i)||' user group is OK');
    pack_log.log_write('I','T',l_proc,l_step,'--'||v_user_group(i)||' user group is OK',null);
  END LOOP;

 -- check the user role if exists
  l_step := '030';
  For i in v_user_role.first.. v_user_role.last LOOP
    begin
    	select role_name into v_role_names(i) from v_priv_grantee where priv_type='role' and role_name=v_user_role(i);
    exception
      when no_data_found then
        raise_application_error(-20000, 'Can not find the User Role: ');
      when others then
      	raise;
    end;
    dbms_output.put_line('--'||v_user_role(i)||' user role is OK');
    pack_log.log_write('I','T',l_proc,l_step,'--'||v_user_role(i)||' user role is OK',null);
  END LOOP;



  -- Delete the existing UAM entries for Section Space
  l_step := '040';
  dbms_output.put_line('--Deleting old Page UAM entries...');
  delete from dsb_privilege dp where dp.page_def_id is not null;
  pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' row(s) of old UAM entries deleted.',null);
  dbms_output.put_line(to_char(sql%rowcount)||' row(s) processed');
  commit;

  dbms_output.put_line('----Inserting new UAM entry...');
  pack_log.log_write('I','T',l_proc,l_step,'----Inserting new UAM entry...',null);
  

  -- loop the UAM setting
  l_step := '050';
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_object_name :=v_access(1);
        
    -- loop the user role access
    l_step := '051';
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_role_name := v_role_names(j);
      
      
   --   select max(id) into v_id from dsb_privilege;
      -- grant the access 
      IF  v_access_type = 'Y' THEN
        l_step := '052';
        insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values (SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, null, v_object_name, null, 'WRITE');
   
      ELSIF  v_access_type = 'RO' THEN
        l_step := '053';
        insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values ( SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, null, v_object_name, null, 'READ');

	ELSIF v_access_type='N' THEN
	      l_step := '054';
	      insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values ( SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, null, v_object_name, null, 'NONE');
  
      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  dbms_output.put_line('Setting Page access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting Page access matrix... done.',null);
  pack_log.log_end();
exception
  when others then  
	  rollback;
	  pack_log.log_write('E','T',l_proc,l_step, pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000), null);
	  pack_log.log_end();
	  raise;          
END;
/

spool off
exit;
