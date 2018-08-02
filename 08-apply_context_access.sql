--#######################################################################
-- wijaya.kusumo v2.0
-- For RFo v1.2
--
-- Revision:
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    wijaya.kusumo     v2.3        Added print to log_table
--     LB                           Test in RFO v2.0
--    wijaya.kusumo     v2.8        Added priority for generic Status access. 
--                                  Removed context existance check
--#######################################################################
set serverout on size 999999
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool apply_context_access_MA.log

declare
  l_proc        varchar2(60):='uam_apply_context_access';
  l_step        varchar2(3) := '000';
  l_start_time  DATE;
  i INTEGER;
  j INTEGER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_group_id varchar2(100);
  v_group_ids t_tab := t_tab();
  v_context_ids t_tab;
  v_context_status  varchar2(100);
  v_reporting_date  varchar2(100);
  v_workspace varchar2(100);
  v_position  varchar2(100);
  l_sql       varchar2(4000);
  v_ctx_id    number;
  v_rd_id     number;
  v_ws_id     number;
  v_pos_id    number;
  v_status_id     number;
  v_priority      number; 
  v_priority_set  number;
  v_ctx_list  t_list:= t_list();
  v_access    t_tab;


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
t_tab('19900101','BIII_CR11P1_LIGHT','0','','','','','N','','','RO','','','','','',''),
t_tab('20040701','CUSTOM','0','','','','','N','','','N','','','','','',''),
t_tab('20030701','PREVIOUS','0','','','','','','','','','','','','','',''),
t_tab('20160101','P3','0','','','','','','','','','','','','','',''),
t_tab('20161016','BIII_CR11P1_LIGHT','0','','','','','','','','','','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line			

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);
  pack_log.log_begin('UAM: APPLY CONTEXT ACCESS',null,null,'Apply Context UAM');
  v_group_ids.extend(v_user_group.count);
  v_ctx_list.extend(v_access_list.count);

  dbms_output.put_line('Setting CONTEXT access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting CONTEXT access matrix...',null);

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

  -- check and initialized context configuration
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_context_ids := t_tab();
    v_context_ids.extend(v_access_list.count);
    v_reporting_date := v_access_list(i)(1);
    v_workspace := v_access_list(i)(2);
    v_position := v_access_list(i)(3);
    v_context_status := v_access_list(i)(4);
    v_priority := v_access_list(i)(5);    
    v_rd_id := null;
    v_ws_id := null;
    v_pos_id := null;
    v_status_id := null;

    l_sql:='select c.context_id from contexts c, workspaces w where w.workspace_id = c.workspace_id ';

    if v_reporting_date is not null then
      l_sql:=l_sql||'and c.reporting_date = to_date('''||v_reporting_date||''',''YYYYMMDD'') ';

      -- check reporting date validity
      begin
        select rd_id into v_rd_id from reporting_days where reporting_date = to_date(v_reporting_date,'YYYYMMDD');
      exception
        when no_data_found then
          raise_application_error(-20000, 'Can not find the Reporting Days! rd:'||v_reporting_date||', ws:'||v_workspace||', pos:'||v_position);
        when others then
                raise;
      end;
    end if;

    if v_workspace is not null then
      l_sql:=l_sql||'and w.name = '''||v_workspace||''' ';

      -- check workspace name validity
      begin
        select workspace_id into v_ws_id from workspaces where upper(name) = upper(v_workspace);
      exception
        when no_data_found then
          raise_application_error(-20000, 'Can not find the Workspace name! rd:'||v_reporting_date||', ws:'||v_workspace||', pos:'||v_position);
        when others then
                raise;
      end;
    end if;

    if v_position is not null then
      l_sql:=l_sql||'and c.position = '||v_position||' ';

      -- check position validity
      begin
        select position into v_pos_id from position where position = v_position;
      exception
        when no_data_found then
          raise_application_error(-20000, 'Can not find the Position! rd:'||v_reporting_date||', ws:'||v_workspace||', pos:'||v_position);
        when others then
                raise;
      end;
    end if;

    if v_context_status is not null then
      l_sql:=l_sql||'and c.status_id = '||v_context_status||' ';

      -- check status validity
      begin
        select code into v_status_id from context_status where code = v_context_status;
      exception
        when no_data_found then
          raise_application_error(-20000, 'Can not find the Context status code! rd:'||v_reporting_date||', ws:'||v_workspace||', pos:'||v_position);
        when others then
                raise;
      end;
    end if;

    v_ctx_list(i) := t_tab(v_rd_id, v_ws_id, v_pos_id,v_status_id,v_priority);
  end loop;

  dbms_output.put_line('--Deleting old UAM entries...');
  l_step:='010';
  delete from priv p where exists (select 1 from priv_context pp where pp.priv_id=p.priv_id);
  pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' row(s) of old UAM entries deleted.',null);

  dbms_output.put_line('--Creating new UAM entries...');
  pack_log.log_write('I','T',l_proc,l_step,'--Creating new UAM entries...',null);

  l_step:='020';

  -- loop the UAM setting
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_rd_id := v_ctx_list(i)(1);
    v_ws_id := v_ctx_list(i)(2);
    v_pos_id := v_ctx_list(i)(3);
    v_status_id := v_ctx_list(i)(4);
    v_priority_set := v_ctx_list(i)(5);
    l_step:='021';

    dbms_output.put_line('----Inserting default UAM entry...');
    -- insert the DEFAULT access rules: deny all with lowest priority
    insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, rd_id, workspace_id, position,status_id)
                values ( seq_priv.nextval, 0, 0, 'N', 99, 'context', v_rd_id, v_ws_id, v_pos_id,v_status_id);
    dbms_output.put_line('----v_rd_id:'||v_rd_id||', v_ws_id:'||v_ws_id||', v_pos_id:'||v_pos_id||' access:N priority:99');
    pack_log.log_write('I','T',l_proc,l_step,'----v_rd_id:'||v_rd_id||', v_ws_id:'||v_ws_id||', v_pos_id:'||v_pos_id||' access:N priority:99',null);

    l_step:='022';
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-5 LOOP
      v_access_type := v_access(5+j);
      v_group_id := v_group_ids(j);

      IF  v_access_type = 'Y' THEN
        l_step:='023';
        if v_priority_set = '' or v_priority_set is null then
          v_priority_set := 10;  -- Read Write
        end if;       
        l_step:='024';
        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, rd_id, workspace_id, position,status_id)
                                        values ( seq_priv.nextval, v_group_id, 0, 'Y', v_priority_set, 'context', v_rd_id, v_ws_id, v_pos_id,v_status_id);

        dbms_output.put_line('G>'||v_group_id ||'--v_rd_id:'||v_rd_id||', v_ws_id:'||v_ws_id||', v_pos_id:'||v_pos_id||' access:Y priority:10');
        pack_log.log_write('I','T',l_proc,l_step,'----v_rd_id:'||v_rd_id||', v_ws_id:'||v_ws_id||', v_pos_id:'||v_pos_id||' access:Y priority:10',null);
      ELSIF  v_access_type = 'RO' THEN
        l_step:='026';
        if v_priority_set = '' or v_priority_set is null then
          v_priority_set := 20;  -- Read Only
        end if;
        l_step:='027';
        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, rd_id, workspace_id, position, status_id)
                                        values ( seq_priv.nextval, v_group_id, 0, 'R', v_priority_set, 'context', v_rd_id, v_ws_id, v_pos_id, v_status_id);

        dbms_output.put_line('G>'|| v_group_id || '--v_rd_id:'||v_rd_id||', v_ws_id:'||v_ws_id||', v_pos_id:'||v_pos_id||' access:R priority:20');
        pack_log.log_write('I','T',l_proc,l_step,'----v_rd_id:'||v_rd_id||', v_ws_id:'||v_ws_id||', v_pos_id:'||v_pos_id||' access:R priority:20',null);
      END IF;
    END LOOP;
  END LOOP;
  commit;

  l_step:='030';
  -- update the statistics
  dbms_output.put_line('Gather table statistics....');
  pack_stats.gather_table_stats('PRIV');
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  pack_stats.gather_table_stats('PRIV_CONTEXT');

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
  --pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_TABLE');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');

  dbms_output.put_line('Setting CONTEXT access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting CONTEXT access matrix... done.',null);
  pack_log.log_end();

--exception
--  when others then
--          rollback;
--          pack_log.log_write('E','T',l_proc,l_step, pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000), null);
--          pack_log.log_end();
--          raise_application_error(-20000,pack_utils.truncstr(substr(sqlerrm, 1, 2048),4000));
END;
/

spool off
exit;
