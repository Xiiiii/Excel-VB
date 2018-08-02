---------------------------------------------------------------
-- Dashboard v2.x - RFO v1.1
-- Ngah Ting Lim v1.0
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    LB                  v2.3        Added print to log_table
--    RFO v2.0
---------------------------------------------------------------


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

spool apply_dsb_section.log

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
t_tab('01000ADB-0905-4C1F-B562-EC3FDF62AD45','','','','','','','','','Y','N','','','','',''),
t_tab('52611EBF-78B2-4E9B-952C-B2A365104D43','','','','','','','','','Y','N','','','','',''),
t_tab('53F65AC6-783F-46C5-95C9-EB10A640DF4B','','','','','','','','','Y','N','','','','',''),
t_tab('57B25A1D-ED38-40CB-9448-787B180D3B58','','','','','','','','','Y','N','','','','',''),
t_tab('5FA37FAB-A301-4B4A-92EA-9EC239D12108','','','','','','','','','Y','RO','','','','',''),
t_tab('7DD34E23-B49E-43EF-BBD0-F3578670855A','','','','','','','','','Y','RO','','','','',''),
t_tab('A6A69BC2-49C3-40AE-9DE0-F00C116D812D','','','','','','','','','Y','RO','','','','',''),
t_tab('D3A218F9-5399-4489-B7D6-EB69508719D7','','','','','','','','','Y','Y','','','','',''),
t_tab('E4EF8375-CB0F-4B74-AC37-3CB02293C45B','','','','','','','','','Y','Y','','','','',''),
t_tab('EF0E0329-D53A-4924-B12E-E208ABB0CB2D','','','','','','','','','Y','N','','','','',''),
t_tab('F7211FB9-84AD-4D80-AFE7-BCD15DB7D9EE','','','','','','','','','Y','Y','','','','',''),
t_tab('FAB1D6A9-9014-43D8-B70B-8B065B831B47','','','','','','','','','Y','Y','','','','','')
   );
-- AUTO:End.  System tag, do not modify this line

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY DSB SECTION ACCESS',null,null,'Apply DSB SECTION UAM');
  v_group_names.extend(v_user_group.count);
  v_role_names.extend(v_user_role.count);
  
  l_step := '010';
  dbms_output.put_line('Setting Section access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting DSB SECTION access ...',null);
 
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

  l_step := '040';
  -- Delete the existing UAM entries for Section
  dbms_output.put_line('--Deleting old Section UAM entries...');
  delete from dsb_privilege dp where dp.section_def_id is not null;
  pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' row(s) of old UAM entries deleted.',null);
  dbms_output.put_line(to_char(sql%rowcount)||' row(s) processed');
  commit;

  dbms_output.put_line('----Inserting new UAM entry...');
  pack_log.log_write('I','T',l_proc,l_step,'--Creating new UAM entries...',null);
  
  l_step := '050';
  -- loop the UAM setting
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_object_name :=v_access(1);
        
    l_step := '051';
    -- loop the user role access
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_role_name := v_role_names(j);
      
      
   --   select max(id) into v_id from dsb_privilege;
      -- grant the access 
      IF  v_access_type = 'Y' THEN
        l_step := '052';
        insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values (SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, v_object_name, null, null, 'WRITE');

      
      ELSIF  v_access_type = 'RO' THEN
        l_step := '053';
        insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values ( SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, v_object_name, null, null, 'READ');

	
	ELSIF v_access_type='N' THEN
	      l_step := '054';
	      insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values ( SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, v_object_name, null, null, 'NONE');

      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  dbms_output.put_line('Setting Section access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting Section access matrix... done.',null);
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
