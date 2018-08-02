-- LNT v1.0
-- RFo v1.2

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool drop_user_group.log

declare
  i INTEGER;
  type t_tab is table of varchar2(100);
  l_proc        VARCHAR2(60):='Drop_User_Group';
  l_step        VARCHAR2(3) := '000';  
 	
  v_group_ids t_tab := t_tab();
  -- TODO: Enter the list of user group name to be deleted here. 
  v_user_group t_tab := t_tab('TEST0',
'TEST1',
'TEST2',
'TEST3',
'TEST4',
'TEST5',
'TEST6',
'TEST7',
'TEST8',
'TEST9');
 
--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  
  pack_context.contextid_open(1);  
  v_group_ids.extend(v_user_group.count);
  l_step:='010';
  
  dbms_output.put_line('DROPPING USER GROUP...');
  -- check the user group if exists
  For i in v_user_group.first.. v_user_group.last LOOP
    begin
	
    	select grantee_id into v_group_ids(i) from v_grantee where grantee_type='G' and group_name=v_user_group(i);

	-- Do not allow deletion of All users group
	if v_user_group(i) ='All users' then
		dbms_output.put_line('Cannot delete All users group. This is a default group.');
       		pack_log.log_write('I','T',l_proc,l_step,'Cannot delete All users group. This is a default group.', null);
	else
		dbms_output.put_line('Dropping User Group id: '||v_group_ids(i)|| ' , Group name: ' || v_user_group(i));
		pack_log.log_write('I','T',l_proc,l_step,'Dropping User Group id: '||v_group_ids(i)|| ' , Group name: ' || v_user_group(i), null);
		delete from v_grantee where grantee_type='G' and group_name=v_user_group(i);
	end if;
    exception
      when no_data_found then
	dbms_output.put_line('The user group: '||v_user_group(i)|| ' does not exist');
        pack_log.log_write('I','T',l_proc,l_step,'The user group '|| v_user_group(i)|| ' does not exist', null);
      when others then
      	raise;
    end;
  END LOOP;
  
  commit;
  l_step:='020';

  -- update the statistics
  pack_stats.gather_table_stats('GRANTEES'); 

  dbms_output.put_line('DROPPING USER GROUP...Done!');
  
  dbms_output.put_line('#########################################');
  dbms_output.put_line('NOTE: Remember to run resync process!');
  dbms_output.put_line('#########################################');

   
exception
  when others then  
	  rollback;
	  raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));                     
END;
/

spool off
