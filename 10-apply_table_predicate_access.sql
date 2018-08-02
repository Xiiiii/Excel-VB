--#######################################################################
-- wijaya.kusumo/LNT v2.1
-- Apply TABLE PREDICATE access matrix from template to database
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

set define off

spool apply_table_predicate_access.log

declare
  l_proc        VARCHAR2(60):='uam_apply_table_predicate_access';
  l_step        VARCHAR2(3) := '000';  
  l_start_time	DATE;
  i INTEGER;
  j INTEGER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_group_id varchar2(100);
  v_object_name varchar2(100);
  v_predicate varchar2(1000);
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
t_tab('CURRENCY',':old.ccy_code =''AMD''','','','N','I','','N','','','','','',''),
t_tab('LOANDEPO',':old.book_code =''USD''','','','U','W','','I','','','','','',''),
t_tab('MKT_FX_INPUT',':old.ccy_code =''CNY''','','','N','D','','N','','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line			
 
 
--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY TABLE PREDICATE ACCESS',null,null,'Apply Table Predicate UAM');
  v_group_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Setting TABLE PREDICATE access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting TABLE PREDICATE access matrix...',null);
  
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
  l_step:='010';
  
  dbms_output.put_line('--Deleting old UAM entries...');
  --delete from v_grantee_priv_all where priv_type='table' and predicate is not null;
	delete from priv p where exists (select 1 from priv_table pp where pp.priv_id=p.priv_id and p.predicate is not null);
  pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' row(s) of old UAM entries deleted.',null);
		  
  dbms_output.put_line('--Creating new UAM entries...');
  pack_log.log_write('I','T',l_proc,l_step,'--Creating new UAM entries...',null);
  
  l_step:='020';

  -- loop the UAM setting
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_object_name :=v_access(1);
    v_predicate :=v_access(2);
    l_step:='021';   
       
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-2 LOOP
      v_access_type := v_access(2+j);
      v_group_id := v_group_ids(j);

      -- grant the access for relevant privileges
      
      -------------------------------------------------------------------
      -- RO = Read only but predicate has :old bind variables
      -------------------------------------------------------------------
      IF v_access_type = 'RO' and v_predicate is not null and v_predicate  like '%:old.%' THEN
      l_step:='022';
      pack_log.log_write('E','T',l_proc,l_step,'Read Only predicate access cannot contain '':old'' bind variables.','v_object_name:'||v_object_name||', v_predicate:'|| v_predicate ||', v_group_id:'||v_group_id);

      dbms_output.put_line('----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(S) priority:5');   
    	dbms_output.put_line('#####################################################');
	    dbms_output.put_line('Predicate contains '':old'' bind variables, which are NOT allowed for READ ONLY privileges. Please reset the RO privilege or predicate.'); 
	    dbms_output.put_line('#####################################################');  

      -------------------------------------------------------------------
      -- RO = Read only but predicate does not have :old bind variables
      -------------------------------------------------------------------
	ELSIF v_access_type = 'RO' and v_predicate is not null and v_predicate not like '%:old.%' THEN
          l_step:='023';
          insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, access_type, process_next_if_ok, priority, priv_type, table_name, predicate) 
					values ( seq_priv.nextval, v_group_id, 0, 'P', 'S', 'N', 5, 'table', v_object_name, v_predicate);      
          dbms_output.put_line('----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(S) priority:5'); 
          pack_log.log_write('I','T',l_proc,l_step,'----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(Read Only) priority:5',null);

      -------------------------------------------------------------------  	
      -- I = Insert         
      -------------------------------------------------------------------
      ELSIF v_access_type = 'I' and v_predicate is not null THEN
		      l_step:='024';
          insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, access_type, process_next_if_ok, priority, priv_type, table_name, predicate) 
					values ( seq_priv.nextval, v_group_id, 0, 'P', 'I', 'N', 5, 'table', v_object_name, v_predicate);      
          dbms_output.put_line('----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(S) priority:5');
          pack_log.log_write('I','T',l_proc,l_step,'----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(Insert) priority:5',null);

      -------------------------------------------------------------------
      -- W = Write
      -------------------------------------------------------------------
	ELSIF v_access_type = 'W' and v_predicate is not null THEN
	    	  l_step:='025';
          insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, access_type, process_next_if_ok, priority, priv_type, table_name, predicate) 
					values ( seq_priv.nextval, v_group_id, 0, 'P', 'W', 'N', 5, 'table', v_object_name, v_predicate);      
         dbms_output.put_line('----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(S) priority:5');
         pack_log.log_write('I','T',l_proc,l_step,'----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(Write) priority:5',null);

      -------------------------------------------------------------------
      -- U = Update
      -------------------------------------------------------------------
	ELSIF v_access_type = 'U' and v_predicate is not null THEN
	    	  l_step:='026';
          insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, access_type, process_next_if_ok, priority, priv_type, table_name, predicate) 
					values ( seq_priv.nextval, v_group_id, 0, 'P', 'U', 'N', 5, 'table', v_object_name, v_predicate);      
          dbms_output.put_line('----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(S) priority:5');
          pack_log.log_write('I','T',l_proc,l_step,'----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(Update) priority:5',null);

      -------------------------------------------------------------------
      -- D = Delete
      -------------------------------------------------------------------
	ELSIF v_access_type = 'D' and v_predicate is not null THEN
	     	  l_step:='027';
          insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, access_type, process_next_if_ok, priority, priv_type, table_name, predicate) 
					values ( seq_priv.nextval, v_group_id, 0, 'P', 'D', 'N', 5, 'table', v_object_name, v_predicate);      
         dbms_output.put_line('----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(S) priority:5');
         pack_log.log_write('I','T',l_proc,l_step,'----v_object_name:'||v_object_name||' v_predicate:'|| v_predicate ||' v_group_id:'||v_group_id||' access:Y(Delete) priority:5',null);
  ELSE 
          l_step:='028';
	END IF;

    END LOOP;
  END LOOP;
  commit;
  
  -- update the statistics
  dbms_output.put_line('Gather table statistics....');

  pack_stats.gather_table_stats('PRIV');
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  pack_stats.gather_table_stats('PRIV_TABLE');

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
  pack_stats.gather_table_stats ('PRIV_ACTION');
  pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_CONTEXT');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');
    
  dbms_output.put_line('Setting TABLE PREDICATE access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting CONTEXT access matrix... done.',null);
  pack_log.log_end();
  
  dbms_output.put_line('#########################################');
  dbms_output.put_line('NOTE: Remember to run resync process!');
  dbms_output.put_line('#########################################');
    
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
