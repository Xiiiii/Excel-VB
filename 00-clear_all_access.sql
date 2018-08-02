--#######################################################################
-- wijaya.kusumo v2.1
-- Reset all access matrix to default (Full Access to all)
-- For RFo v1.2
--
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    wijaya.kusumo     v2.2        Added print to log_table
--    LB                v2.3        filter the role  
--    GS                v2.4        filter 'other_app' privileges
--    DC				        v2.5		    Added the drop triggers 
--    wijaya.kusumo     v2.8        Added disable trigger when deleting from CD_FDW_STRUCTURE. Added drop access function and policy workaround
--#######################################################################

spool clear_uam.log
set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

declare
  l_proc              VARCHAR2(60):='clear_uam';
  l_step              VARCHAR2(3) := '000';  
  l_start_time	      DATE;
  V_DROP_STATEMENT    VARCHAR2(200);
  v_sqlerrm           VARCHAR2(2048);
  l_count             NUMBER;
begin
  dbms_output.enable(1000000);
  pack_context.contextid_open(1);
  
  pack_log.log_begin('CLEAR UAM',null,null,'Clear all UAM related objects');
	pack_ddl.activate_trigger('CD_FDW_STRUCTURE','N');
	  
  l_step:='010';
  --delete from priv;
  pack_log.log_write('I','F',l_proc,l_step,'Deleting PRIV table contents....',null);
  l_start_time:=sysdate;
  delete from priv p where not exists ( select 1 from v_priv_grantee pg where pg.priv_type in ('other_app','role') and pg.priv_id = p.priv_id );
  pack_log.log_write('I','F',l_proc,l_step,sql%rowcount||' row(s) deleted.','elapsed time=' ||   pack_utils.diff_time_hhmmss(l_start_time));
  commit;
  
  --reset Role assignment: grant all roles to Everyone
  -- delete role assigned to user and user group
  l_step:='011';
  pack_log.log_write('I','F',l_proc,l_step,'Remove role from user and user group....',null);
  l_start_time:=sysdate;
  delete from grantee_priv gp
  where gp.priv_id in (select priv_id from priv_role)
  and gp.grantee_id != 0;
  pack_log.log_write('I','F',l_proc,l_step,sql%rowcount||' row(s) deleted.','elapsed time=' ||   pack_utils.diff_time_hhmmss(l_start_time));
  
  -- assign remaining roles to All Users
  l_count := 0;
  pack_log.log_write('I','F',l_proc,l_step,'Assign remaining roles to All Users....',null);
  l_start_time:=sysdate;
  for rec in (select priv_id from priv_role where priv_id not in (select priv_id from grantee_priv) order by 1)
  loop
    insert into grantee_priv (grantee_id, priv_id) values (0, rec.priv_id);
    l_count:= l_count+1;
  end loop;
  pack_log.log_write('I','F',l_proc,l_step,l_count||' row(s) inserted.','elapsed time=' ||   pack_utils.diff_time_hhmmss(l_start_time));    
  
  dbms_output.put_line('Run gener_access_policy....');
  l_step:='020';
  pack_log.log_write('I','F',l_proc,l_step,'Run gener_access_policy....',null);
  l_start_time:=sysdate;
	pack_access.gener_access_policy();
	pack_log.log_write('I','F',l_proc,l_step,'Completed in '||pack_utils.diff_time_hhmmss(l_start_time),null);
	dbms_output.put_line('... done in '||pack_utils.diff_time_hhmmss(l_start_time));
	
	dbms_output.put_line('Run gener_access_trigger....');
  l_step:='030';
  pack_log.log_write('I','F',l_proc,l_step,'Run gener_access_trigger....',null);
  l_start_time:=sysdate;
	pack_access.gener_access_trigger();
	pack_log.log_write('I','F',l_proc,l_step,'Completed in '||pack_utils.diff_time_hhmmss(l_start_time),null);
	dbms_output.put_line('... done in '||pack_utils.diff_time_hhmmss(l_start_time));
	
	dbms_output.put_line('Run update_context_access_list....');
 l_step:='040';
  pack_log.log_write('I','F',l_proc,l_step,'Run update_context_access_list....',null);
  l_start_time:=sysdate;
	pack_access.update_context_access_list();
	pack_log.log_write('I','F',l_proc,l_step,'Completed in '||pack_utils.diff_time_hhmmss(l_start_time),null);
	dbms_output.put_line('... done in '||pack_utils.diff_time_hhmmss(l_start_time));

  l_step:='050';
  
----------------------------------------------------------------
--- Drop the unused access functions
--- workaround for RFo v2.2.2 bug
---------------------------------------------------------------- 
  		for rec in (
			select up.object_name,up.policy_name,uo.object_name as fn
			from user_policies up, user_objects uo
			where up.policy_name like 'P\_A\_%' escape '\'
			and up.object_name in (select table_name from cd_fdw_structure where object_type in ('TABLE','VIEW') and pack_product.object_installable(object_type,table_name,hist_table_name,parameter,relevant_for,null)='Y')
			and up.function=uo.object_name(+)
		) loop
			if rec.fn is not null then
				execute immediate 'drop function '||rec.fn;
			end if;
			dbms_rls.drop_policy(pack_utils.get_schema_owner, rec.object_name, rec.policy_name);
		end loop;

    pack_log.log_write('I','T',l_proc,l_step,'Purge data from cd_fdw_structure...', null);		
		delete from cd_fdw_structure
		where object_type='POLICY'
		and table_type='ACCESS'
		and hist_table_name in (select table_name from cd_fdw_structure where object_type in ('TABLE','VIEW') and pack_product.object_installable(object_type,table_name,hist_table_name,parameter,relevant_for,null)='Y');

		delete from cd_fdw_structure
		where object_type='FUNCTION'
		and table_type='ACCESS'
		and parameter in (select table_name from cd_fdw_structure where object_type in ('TABLE','VIEW') and pack_product.object_installable(object_type,table_name,hist_table_name,parameter,relevant_for,null)='Y');
		commit;
  
----------------------------------------------------------------
--- Drop the unused policy access functions
----------------------------------------------------------------
  dbms_output.put_line('Dropping ununsed Policy Access Functions...');
  pack_log.log_write('I','T',l_proc,l_step,'Dropping ununsed Policy Access Functions...', null);
  FOR REC IN (
    SELECT OBJECT_NAME
    FROM USER_OBJECTS
    WHERE OBJECT_TYPE = 'FUNCTION'
      AND OBJECT_NAME LIKE 'F\_A\_%' ESCAPE '\'
      AND OBJECT_NAME NOT IN(
        SELECT TABLE_NAME
        FROM CD_FDW_STRUCTURE
        WHERE OBJECT_TYPE='FUNCTION'
        AND TABLE_NAME LIKE 'F\_A\_%' ESCAPE '\'
      )
    )
  LOOP
    V_DROP_STATEMENT := 'DROP FUNCTION ' || REC.OBJECT_NAME;
    pack_log.log_write('I','T',l_proc,l_step,'Dropping function : '||REC.OBJECT_NAME, null);
    EXECUTE IMMEDIATE V_DROP_STATEMENT;
  END LOOP;

  l_step:='060';
----------------------------------------------------------------
--- Drop the unused access triggers
----------------------------------------------------------------
  dbms_output.put_line('Dropping ununsed Access Triggers...');
  pack_log.log_write('I','T',l_proc,l_step,'Dropping ununsed Access Triggers...', null);
	-- drop old access trigger
	for rec in (
		select 'drop trigger ' || trigger_name drop_cmd
		from user_triggers
		where trigger_name like 'TRI\_A\_%' escape '\'
          and trigger_name != 'TRI_A_TECH_COLUMN'   --skip the trigger on A_TECH_COLUMN
	) loop
		pack_log.log_write('I','T',l_proc,l_step,'Dropping trigger : '||rec.drop_cmd, null);
		execute immediate rec.drop_cmd;
	end loop;

 	l_step:='070';
	-- purge cd_fdw_structure
	dbms_output.put_line('Purge data from cd_fdw_structure...');
	pack_log.log_write('I','T',l_proc,l_step,'Purge data from cd_fdw_structure...', null);
	delete from cd_fdw_structure
	where object_type = 'TRIGGER' and table_type = 'ACCESS';
	pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' access trigger(s) deleted from cd_fdw_structure...', null);
	commit;
	pack_ddl.activate_trigger('CD_FDW_STRUCTURE','Y');
  pack_log.log_end();  
  
  dbms_output.put_line('Resync UAM settings... done.');
  
exception
  when others then  
	  rollback;
	  v_sqlerrm := substr(sqlerrm, 1, 2048);
	  pack_log.log_write('E','F',l_proc,l_step,'ORA'||sqlcode,v_sqlerrm);
	  pack_log.log_end();  
	  raise_application_error(-20000,v_sqlerrm);        
END;
/

spool off

