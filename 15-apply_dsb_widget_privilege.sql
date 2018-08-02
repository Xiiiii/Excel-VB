------------------------------------------------------------------
-- Dashboard v2.x - RFO v1.1
-- Ngah Ting Lim v1.0
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    LB                  v2.3        Added print to log_table
--   Test in RFO v2.0
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

spool apply_dsb_widget.log

declare
  l_proc        VARCHAR2(60):='uam_apply_dsb_widget_access';
  l_step        VARCHAR2(3) := '000';  
  i INTEGER;
  j INTEGER;
  v_id number;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_role_name varchar2(200);
  v_group_name varchar2(100);
  v_object_name varchar2(100);
  v_role_names t_tab := t_tab();
  v_group_names t_tab := t_tab();
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
t_tab('Analytic Editor','','','','','','','','','Y','Y','','','','',''),
t_tab('BU_Role_Search','','','','','','','','','Y','N','','','','',''),
t_tab('BU_Role_Search_Grid','','','','','','','','','Y','N','','','','',''),
t_tab('BU_Role_User_List','','','','','','','','','Y','N','','','','',''),
t_tab('CCD96D52-5D84-4404-A377-EE161F9757F5','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Bar','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Bar Editor','','','','','','','','','Y','N','','','','',''),
t_tab('Drill Bubble','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Bubble Editor','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Bubble Flex','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Line','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Line Editor','','','','','','','','','Y','N','','','','',''),
t_tab('Drill Pie','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Pie Editor','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Scatter','','','','','','','','','Y','N','','','','',''),
t_tab('Drill Scatter Editor','','','','','','','','','Y','Y','','','','',''),
t_tab('Drill Table','','','','','','','','','Y','Y','','','','',''),
t_tab('Dynamic Cross Tab','','','','','','','','','Y','Y','','','','',''),
t_tab('Dynamic CrossTab (2)','','','','','','','','','Y','Y','','','','',''),
t_tab('Export Utility','','','','','','','','','Y','Y','','','','',''),
t_tab('FRT Report Editor','','','','','','','','','Y','N','','','','',''),
t_tab('MART','','','','','','','','','Y','N','','','','',''),
t_tab('MAUI sheet','','','','','','','','','Y','N','','','','',''),
t_tab('OLAP Schema Management','','','','','','','','','Y','N','','','','',''),
t_tab('QuickCubeDesigner','','','','','','','','','Y','N','','','','',''),
t_tab('RRT Dynamic Cross Tab','','','','','','','','','Y','N','','','','',''),
t_tab('Recall_Reason','','','','','','','','','Y','N','','','','',''),
t_tab('RichEditor','','','','','','','','','Y','N','','','','',''),
t_tab('RichEditor Editor','','','','','','','','','Y','N','','','','',''),
t_tab('System Admin','','','','','','','','','Y','N','','','','',''),
t_tab('URL','','','','','','','','','Y','N','','','','',''),
t_tab('URL Editor','','','','','','','','','Y','N','','','','',''),
t_tab('User_Lookup_Search','','','','','','','','','Y','N','','','','',''),
t_tab('User_Lookup_Search_Result','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Delegation List Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Group Info Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF IFrame Widget','','','','','','','','','Y','N','','','','',''),
t_tab('WF Note Viewer Wdiget','','','','','','','','','Y','N','','','','',''),
t_tab('WF Task Assigned List Widget','','','','','','','','','Y','N','','','','',''),
t_tab('WF Task Candidate List Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Task List Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Task Reassign Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Team Task List Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF User Permission Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Workflow List Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WF Workflow Monitor List Widget','','','','','','','','','Y','Y','','','','',''),
t_tab('WFAuditList','','','','','','','','','Y','Y','','','','',''),
t_tab('WFAuditSearch','','','','','','','','','Y','Y','','','','',''),
t_tab('WF_INFO_FORM','','','','','','','','','Y','Y','','','','',''),
t_tab('WF_participant_list','','','','','','','','','Y','Y','','','','',''),
t_tab('WF_participant_list_selector','','','','','','','','','Y','N','','','','',''),
t_tab('WF_reassign_task','','','','','','','','','','','','','','',''),
t_tab('WF_reassign_task_button','','','','','','','','','','','','','','',''),
t_tab('Workflow Space Renderer','','','','','','','','','','','','','','',''),
t_tab('WorkflowMonitorSearch','','','','','','','','','','','','','','',''),
t_tab('WorkflowMonitorSearch_Result','','','','','','','','','','','','','','',''),
t_tab('WorkflowSearch','','','','','','','','','','','','','','',''),
t_tab('WorkflowSearch_Button','','','','','','','','','','','','','','',''),
t_tab('WorkflowSearch_Result','','','','','','','','','','','','','','',''),
t_tab('sae_review_context','','','','','','','','','','','','','','',''),
t_tab('startworkflow_form','','','','','','','','','','','','','','','')
   );
-- AUTO:End.  System tag, do not modify this line

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY DSB WIDGET ACCESS',null,null,'Apply DSB WIDGET SPACE UAM');
  v_group_names.extend(v_user_group.count);
  v_role_names.extend(v_user_role.count);
  
  l_step := '010';
  dbms_output.put_line('Setting Widget access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting DSB WIDGET access ...',null);
  
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
  dbms_output.put_line('--Deleting old Section space UAM entries...');
  delete from dsb_privilege dp where dp.widget_def_id is not null;
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
        
    -- loop the user role access
    l_step := '051';
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_role_name := v_role_names(j);
      
      
   --   select max(id) into v_id from dsb_privilege;
      -- grant the access 
      IF  v_access_type = 'Y' THEN
        l_step := '052';
        insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values (SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, null, null, v_object_name, 'WRITE');
       
      ELSIF  v_access_type = 'RO' THEN
        l_step := '053';
        insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values ( SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, null, null, v_object_name, 'READ');

	ELSIF v_access_type='N' THEN
	      l_step := '054';
	      insert into dsb_privilege (id, role_name, section_space_def_id, section_def_id, page_def_id, widget_def_id, privilege) values (SEQ_LO_CONF_PRIVILEGE.nextval, v_role_name, null, null, null, v_object_name, 'NONE');
 
      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  dbms_output.put_line('Setting Widget access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting Widget access matrix... done.',null);
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
