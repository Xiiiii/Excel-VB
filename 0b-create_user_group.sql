-- wijaya.kusumo v2.0
-- RFo v1.2

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool create_user_group.log

declare
  i INTEGER;
  type t_tab is table of varchar2(100);
 	
  v_group_ids t_tab := t_tab();
  
-- AUTO:Begin.  System tag, do not modify this line
  v_user_group t_tab := t_tab(
'TEST0',
'TEST1',
'TEST2',
'TEST3',
'TEST4',
'TEST5',
'TEST6',
'TEST7',
'TEST8',
'TEST9',
'TEST10',
'TEST11',
'TEST12'
   );
--AUTO:End.  System tag, do not modify this line	
  
--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  
  pack_context.contextid_open(1);  
  v_group_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Creating USER GROUP...');
  
  -- check the user group if exists
  For i in v_user_group.first.. v_user_group.last LOOP
    begin
    	select grantee_id into v_group_ids(i) from v_grantee where grantee_type='G' and group_name=v_user_group(i);
    exception
      when no_data_found then
        insert into v_grantee ( grantee_id, grantee_type, group_name,grantee_name)
		      values (-seq_grantee.nextval, 'G', v_user_group(i),  v_user_group(i) ); 
		    dbms_output.put_line('--'||v_user_group(i)||' user group created');
      when others then
      	raise;
    end;
  END LOOP;
  
  commit;
  
  pack_stats.gather_table_stats('GRANTEES'); 
   
exception
  when others then  
	  rollback;
	  raise;          
END;
/

spool off
exit;
