--#######################################################################
-- wijaya.kusumo v2.0
-- For RFo v1.2
--
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    wijaya.kusumo     v2.3        Added print to log_table
--     LB                 Test in RFO v2.0
--#######################################################################

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool apply_action_access.log

declare
  l_proc        VARCHAR2(60):='uam_apply_action_access';
  l_step        VARCHAR2(3) := '000';  
  l_start_time	DATE;
  i INTEGER;
  j INTEGER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_group_id varchar2(100);
  v_object_name varchar2(100);
  v_group_ids t_tab := t_tab();
  v_access t_tab;
  
  
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
t_tab('76','','','N','N','','N','','','','','',''),
t_tab('48','','','','','','','','','','','',''),
t_tab('3','','','','','','Y','RO','','','','',''),
t_tab('77','','','','','','','','','','','',''),
t_tab('78','','','','','','','','','','','',''),
t_tab('79','','','','','Y','','','','','','',''),
t_tab('80','','','','','','','','','','','',''),
t_tab('4','','','','','','','','','','','',''),
t_tab('5','','','','','','','','','','','',''),
t_tab('6','','','','','','','','','','','',''),
t_tab('7','','','','','','','','','','','',''),
t_tab('53','','','','','','','','','','','',''),
t_tab('73','','','','','','','','','','','',''),
t_tab('34','','','','','','','','','','','',''),
t_tab('22','','','','','','','','','','','',''),
t_tab('35','','','','','','','','','','','',''),
t_tab('103','','','','','','','','','','','',''),
t_tab('60','','','','','','','','','','','',''),
t_tab('9','','','','','','','','','','','',''),
t_tab('11','','','','','','','','','','','',''),
t_tab('81','','','','','','','','','','','',''),
t_tab('61','','','','','','','','','','','',''),
t_tab('1','','','','','','','','','','','',''),
t_tab('12','','','','','','','','','','','',''),
t_tab('36','','','','','','','','','','','',''),
t_tab('13','','','','','','','','','','','',''),
t_tab('82','','','','','','','','','','','',''),
t_tab('16','','','','','','','','','','','',''),
t_tab('15','','','','','','','','','','','',''),
t_tab('17','','','','','','','','','','','',''),
t_tab('18','','','','','','','','','','','',''),
t_tab('19','','','','','','','','','','','',''),
t_tab('23','','','','','','','','','','','',''),
t_tab('62','','','','','','','','','','','',''),
t_tab('83','','','','','','','','','','','',''),
t_tab('101','','','','','','','','','','','',''),
t_tab('66','','','','','','','','','','','',''),
t_tab('102','','','','','','','','','','','',''),
t_tab('68','','','','','','','','','','','',''),
t_tab('69','','','','','','','','','','','',''),
t_tab('70','','','','','','','','','','','',''),
t_tab('72','','','','','','','','','','','',''),
t_tab('71','','','','','','','','','','','',''),
t_tab('84','','','','','','','','','','','',''),
t_tab('2','','','','','','','','','','','',''),
t_tab('20','','','','','','','','','','','',''),
t_tab('63','','','','','','','','','','','',''),
t_tab('64','','','','','','','','','','','',''),
t_tab('65','','','','','','','','','','','',''),
t_tab('24','','','','','','','','','','','',''),
t_tab('37','','','','','','','','','','','',''),
t_tab('40','','','','','','','','','','','',''),
t_tab('67','','','','','','','','','','','',''),
t_tab('74','','','','','','','','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line			

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY ACTION ACCESS',null,null,'Apply Action UAM'); 
    
  v_group_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Setting ACTION access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting ACTION access matrix...',null);
  
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
  l_step:='010';  

  delete from priv p where exists (select 1 from priv_action pp where pp.priv_id=p.priv_id);
  pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' row(s) of old UAM entries deleted.',null);
  
  dbms_output.put_line('--Creating new UAM entries...');
  pack_log.log_write('I','T',l_proc,l_step,'--Creating new UAM entries...',null);
  
  l_step:='020';  
    
  -- loop the UAM setting
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_object_name :=v_access(1);
    l_step:='021';
  
    dbms_output.put_line('----Inserting default UAM entry...');
    pack_log.log_write('I','T',l_proc,l_step,'----Inserting default UAM entry...',null);
    -- insert the DEFAULT access rules: deny all with lowest priority
    insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, action_id) 
		values ( seq_priv.nextval, 0, 0, 'N', 99, 'action', v_object_name);
 	 
    dbms_output.put_line('----Object ID:'||v_object_name||' access:N priority:99');
    pack_log.log_write('I','T',l_proc,l_step,'----Object ID:'||v_object_name||' access:N priority:99',null);
      
    l_step:='022';  
      
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_group_id := v_group_ids(j);

      -- grant the access 
      IF  v_access_type = 'Y' THEN
        l_step:='023';
        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, action_id) 
					values ( seq_priv.nextval, v_group_id, 0, v_access_type, 10, 'action', v_object_name);
        
        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10');
        pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10',null);

      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  l_step:='040';
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
  
  dbms_output.put_line('Setting ACTION access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting ACTION access matrix... done.',null);
  pack_log.log_end();

exception
  when others then  
	  rollback;
	  pack_log.log_write('E','T',l_proc,l_step, pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000), null);
	  pack_log.log_end();  
	  raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));            
END;
/

spool off
exit;
