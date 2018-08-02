
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

spool apply_process_access.log

declare
  l_proc        VARCHAR2(60):='uam_apply_process_access';
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
t_tab('103','','','N','N','','N','','','','','',''),
t_tab('625','','','N','N','','N','','','','','',''),
t_tab('707','','','N','N','','N','','','','','',''),
t_tab('61','','','N','N','','N','','','','','',''),
t_tab('54','','','N','N','','N','','','','','',''),
t_tab('6','','','N','N','','N','','','','','',''),
t_tab('92','','','N','N','','N','','','','','',''),
t_tab('76','','','N','N','','N','','','','','',''),
t_tab('75','','','N','N','','N','','','','','',''),
t_tab('611','','','N','N','','N','','','','','',''),
t_tab('100','','','N','N','','N','','','','','',''),
t_tab('99','','','N','N','','N','','','','','',''),
t_tab('56','','','N','N','','N','','','','','',''),
t_tab('705','','','N','N','','N','','','','','',''),
t_tab('42','','','N','N','','N','','','','','',''),
t_tab('5','','','N','N','','N','','','','','',''),
t_tab('642','','','N','N','','N','','','','','',''),
t_tab('4','','','N','N','','N','','','','','',''),
t_tab('709','','','N','N','','N','','','','','',''),
t_tab('708','','','N','N','','N','','','','','',''),
t_tab('706','','','N','N','','N','','','','','',''),
t_tab('7','','','N','N','','N','','','','','',''),
t_tab('8','','','N','N','','N','','','','','',''),
t_tab('9','','','N','N','','N','','','','','',''),
t_tab('1','','','N','N','','N','','','','','',''),
t_tab('624','','','N','N','','N','','','','','',''),
t_tab('623','','','N','N','','N','','','','','',''),
t_tab('3','','','N','N','','N','','','','','',''),
t_tab('41','','','N','N','','N','','','','','',''),
t_tab('40','','','N','N','','N','','','','','',''),
t_tab('72','','','N','N','','N','','','','','',''),
t_tab('612','','','N','N','','N','','','','','',''),
t_tab('2','','','N','N','','N','','','','','',''),
t_tab('45','','','N','N','','N','','','','','',''),
t_tab('136','','','N','N','','N','','','','','',''),
t_tab('19','','','N','N','','N','','','','','',''),
t_tab('18','','','N','N','','N','','','','','',''),
t_tab('16','','','N','N','','N','','','','','',''),
t_tab('43','','','N','N','','N','','','','','',''),
t_tab('17','','','N','N','','N','','','','','',''),
t_tab('65','','','N','N','','N','','','','','',''),
t_tab('33','','','N','N','','N','','','','','',''),
t_tab('50','','','N','N','','N','','','','','',''),
t_tab('31','','','N','N','','N','','','','','',''),
t_tab('64','','','N','N','','N','','','','','',''),
t_tab('135','','','N','N','','N','','','','','',''),
t_tab('28','','','N','N','','N','','','','','',''),
t_tab('14','','','N','N','','N','','','','','',''),
t_tab('90','','','N','N','','N','','','','','',''),
t_tab('60','','','N','N','','N','','','','','',''),
t_tab('46','','','N','N','','N','','','','','',''),
t_tab('63','','','N','N','','N','','','','','',''),
t_tab('600','','','N','N','','N','','','','','',''),
t_tab('621','','','N','N','','N','','','','','',''),
t_tab('620','','','N','N','','N','','','','','',''),
t_tab('141','','','N','N','','N','','','','','',''),
t_tab('11','','','N','N','','N','','','','','',''),
t_tab('712','','','N','N','','N','','','','','',''),
t_tab('710','','','N','N','','N','','','','','',''),
t_tab('158','','','N','N','','N','','','','','',''),
t_tab('10','','','N','N','','N','','','','','',''),
t_tab('159','','','N','N','','N','','','','','',''),
t_tab('161','','','N','N','','N','','','','','',''),
t_tab('67','','','N','N','','N','','','','','',''),
t_tab('601','','','N','N','','N','','','','','',''),
t_tab('355','','','N','N','','N','','','','','',''),
t_tab('523','','','N','N','','N','','','','','',''),
t_tab('522','','','N','N','','N','','','','','',''),
t_tab('711','','','N','N','','N','','','','','',''),
t_tab('44','','','N','N','','N','','','','','',''),
t_tab('30','','','N','N','','N','','','','','',''),
t_tab('22','','','N','N','','N','','','','','',''),
t_tab('-274','','','N','N','','N','','','','','',''),
t_tab('12','','','N','N','','N','','','','','',''),
t_tab('38','','','N','N','','N','','','','','',''),
t_tab('49','','','N','N','','N','','','','','',''),
t_tab('52','','','N','N','','N','','','','','',''),
t_tab('-275','','','N','N','','N','','','','','',''),
t_tab('55','','','N','N','','N','','','','','',''),
t_tab('29','','','N','N','','N','','','','','',''),
t_tab('35','','','N','N','','N','','','','','',''),
t_tab('34','','','N','N','','N','','','','','',''),
t_tab('23','','','N','N','','N','','','','','',''),
t_tab('25','','','N','N','','N','','','','','',''),
t_tab('356','','','N','N','','N','','','','','',''),
t_tab('633','','','N','N','','N','','','','','',''),
t_tab('635','','','N','N','','N','','','','','',''),
t_tab('634','','','N','N','','N','','','','','',''),
t_tab('636','','','N','N','','N','','','','','',''),
t_tab('358','','','N','N','','N','','','','','',''),
t_tab('639','','','N','N','','N','','','','','',''),
t_tab('628','','','N','N','','N','','','','','',''),
t_tab('637','','','N','N','','N','','','','','',''),
t_tab('627','','','N','N','','N','','','','','',''),
t_tab('160','','','N','N','','N','','','','','',''),
t_tab('359','','','N','N','','N','','','','','',''),
t_tab('632','','','N','N','','N','','','','','',''),
t_tab('640','','','N','N','','N','','','','','',''),
t_tab('626','','','N','N','','N','','','','','',''),
t_tab('643','','','N','N','','N','','','','','',''),
t_tab('638','','','N','N','','N','','','','','',''),
t_tab('68','','','N','N','','N','','','','','',''),
t_tab('357','','','N','N','','N','','','','','',''),
t_tab('641','','','N','N','','N','','','','','',''),
t_tab('273','','','N','N','','N','','','','','',''),
t_tab('619','','','N','N','','N','','','','','',''),
t_tab('610','','','N','N','','N','','','','','',''),
t_tab('26','','','N','N','','N','','','','','',''),
t_tab('618','','','N','N','','N','','','','','',''),
t_tab('337','','','N','N','','N','','','','','',''),
t_tab('146','','','N','N','','N','','','','','',''),
t_tab('195','','','N','N','','N','','','','','',''),
t_tab('613','','','N','N','','N','','','','','',''),
t_tab('80','','','N','N','','N','','','','','',''),
t_tab('145','','','N','N','','N','','','','','',''),
t_tab('410','','','N','N','','N','','','','','',''),
t_tab('166','','','N','N','','N','','','','','',''),
t_tab('406','','','N','N','','N','','','','','',''),
t_tab('629','','','N','N','','N','','','','','',''),
t_tab('409','','','N','N','','N','','','','','',''),
t_tab('407','','','N','N','','N','','','','','',''),
t_tab('408','','','N','N','','N','','','','','',''),
t_tab('704','','','N','N','','N','','','','','',''),
t_tab('143','','','N','N','','N','','','','','',''),
t_tab('405','','','N','N','','N','','','','','',''),
t_tab('403','','','N','N','','N','','','','','',''),
t_tab('404','','','N','N','','N','','','','','',''),
t_tab('144','','','N','N','','N','','','','','',''),
t_tab('402','','','N','N','','N','','','','','',''),
t_tab('400','','','N','N','','N','','','','','',''),
t_tab('401','','','N','N','','N','','','','','',''),
t_tab('165','','','N','N','','N','','','','','',''),
t_tab('614','','','N','N','','N','','','','','',''),
t_tab('615','','','N','N','','N','','','','','',''),
t_tab('617','','','N','N','','N','','','','','',''),
t_tab('616','','','N','N','','N','','','','','',''),
t_tab('630','','','N','N','','N','','','','','',''),
t_tab('411','','','N','N','','N','','','','','',''),
t_tab('32','','','N','N','','N','','','','','',''),
t_tab('622','','','N','N','','N','','','','','',''),
t_tab('413','','','N','N','','N','','','','','',''),
t_tab('412','','','N','N','','N','','','','','',''),
t_tab('177','','','N','N','','N','','','','','',''),
t_tab('24','','','N','N','','N','','','','','',''),
t_tab('62','','','N','N','','N','','','','','',''),
t_tab('101','','','N','N','','N','','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY PROCESS ACCESS',null,null,'Apply Process UAM'); 
    
  v_group_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Setting PROCESS access matrix...');
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
  l_step:='010';  
  
  delete from priv p where exists (select 1 from priv_process pp where pp.priv_id=p.priv_id);
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
    insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, process_id) 
		values ( seq_priv.nextval, 0, 0, 'N', 99, 'process', v_object_name);
 	 
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
       insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, process_id) 
					values ( seq_priv.nextval, v_group_id, 0, v_access_type, 10, 'process', v_object_name);
        
        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10');
        pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10',null);

      END IF;
    END LOOP;
  END LOOP;
  commit;

  l_step:='030';
  -- update the statistics
  dbms_output.put_line('Gather table statistics....');
  pack_stats.gather_table_stats('PRIV');
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  pack_stats.gather_table_stats('PRIV_PROCESS');

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
  pack_stats.gather_table_stats ('PRIV_ACTION');
  pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_CONTEXT');
  pack_stats.gather_table_stats ('PRIV_TABLE');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');
  
  dbms_output.put_line('Setting PROCESS access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting PROCESS access matrix... done.',null);
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
