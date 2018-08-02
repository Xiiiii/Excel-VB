--#############################################################################################
-- script to generate UAM template entries
--
-- Revision: 
--     Author            Date          Description
--    ---------------   -----------   -----------------------------
--    wijaya.kusumo     14-Nov-2017    Updated to RFo v5.1; list non-empty tables
--#############################################################################################

WHENEVER SQLERROR EXIT SQL.SQLCODE

call pack_context.contextid_open(1);

-------------------------------------------
-- print the Window Access entries
-------------------------------------------	

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading off
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_window_list.log

select 
  pack_product.product_name(product_sub_product) ||chr(9)||
  nvl(title, object_name) ||chr(9)|| object_name  window_name
from pb_object 
where object_type = 'WINDOW' 
	and pack_product.is_a_product_installed(product_sub_product)='Y' 
	and object_name not in ('w_select_context','w_waiter')
order by 1;

spool off

-------------------------------------------
-- print the Node Access entries
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_node_list.log

select 
  pack_product.product_name(product_sub_product) ||chr(9)||
  nvl(title, object_name) ||chr(9)|| object_name window_name
from pb_object where object_type = 'WINDOW' and 
  pack_product.is_a_product_installed(product_sub_product)='Y' 
order by 1;

spool off


-------------------------------------------
-- print the Datawindow Access entries
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_datawindow_list.log

select 
	max(pack_product.product_name(odw.product_sub_product)) ||chr(9)||
	max(nvl(nvl(ow.title, ow.object_name) || nullif(' / ' || coalesce(wt.tab_title, to_char(wt.tab_rank), '0'), ' / 0'), odw.object_name)) ||chr(9)||
	odw.object_name
from pb_object odw, pb_window_tabs wt, pb_object ow 
where odw.object_type = 'DATAWINDOW' 
	and odw.object_name = wt.dw_name (+) 
	and wt.window_name = ow.object_name (+) 
	and pack_product.is_a_product_installed(odw.product_sub_product)='Y' 
	and odw.object_name not like 'dddw\_%' escape '\' 
	and odw.object_name not like 'd\_dropdown\_%' escape '\' 
group by odw.object_name 
order by 1;

spool off

--------------------------------------------------------------------------------------
-- print the Browser Menu Access entries
-- Note: MUST USE CUSTOM BROWSER PROFILE NOT THE STANDARD BROWSER PROFILE!
--------------------------------------------------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_browser_list.log


select browser_code ||chr(9)|| replace(substr(node_path,3),'//',' > ') ||chr(9)|| node_id as browser_uam
from v_flat_browser
where node_path not like '%//Hidden Entries//%';

spool off


-------------------------------------------
-- print the Action Access entries
-- exclude obsolete actions and not required ones
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_action_list.log

select pack_product.product_name(relevant_for) || chr(9) || description ||' ('|| action_code ||')' ||chr(9)|| action_id
as uam 
from action_priv 
where pack_product.product_name(relevant_for) not in ('ALM','BIS','FCE','GEM')
and action_code not like 'menu\_chart\_%' escape '\'
and action_code not like 'menu\_cube\_%' escape '\'
and action_code not like 'gem\_%' escape '\'
and action_code not in ('reset_calculation_parameters','adm_sql_loader_control_file','adm_log_table_all_ctx','adm_edit_import_data','adm_correct_import_sqlloader','xxx','xxx','xxx','xxx','xxx','xxx','xxx','xxx')
order by 1;

spool off

-------------------------------------------
-- print the Process Access entries
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_process_list.log

select pack_product.product_name(relevant_for) || chr(9) || name ||chr(9)|| description ||chr(9)|| process_id as uam
from process order by pack_product.product_name(relevant_for), description;

spool off

-------------------------------------------
-- print the Company Access entries
-------------------------------------------
set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_company_list.log

-- disable context filtering to get the list
call pack_context.contextid_disable();

select distinct uam from (
select company_name || chr(9)|| company_code uam
from companies 
where nvl(fermat_reserved,'F')='F'
) 
order by uam asc;

-- enable context filtering again
call pack_context.context_enabled();

spool off

-------------------------------------------
-- print the Context (Workspace) Access entries
-- Focus on Workspace only
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_context_list.log


select c.description || chr(9)|| to_char(c.reporting_date,'YYYYMMDD') || chr(9)|| w.name || chr(9)|| c.position  || chr(9)|| c.status_id as uam
from contexts c, workspaces w
where w.workspace_id = c.workspace_id;

spool off  


-- @-------------------------------------------
-- @ print the Workspace Access Matrix
-- @ version 8.2
-- @-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off
SET SERVEROUTPUT ON

spool uam_workspace.log

select description ||chr(9)|| chr(9)|| name as list
from workspaces order by workspace_id;

spool off



-- @-------------------------------------------
-- @ print the Browser profile
-- @-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off
SET SERVEROUTPUT ON

spool uam_browser_profile.log

select code ||chr(9)|| description as list from browser_profile order by code;

spool off


-------------------------------------------
-- print the Table Access entries
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_table_list_all.log

select decode(standard_custom,'C','CUS','S','STD',standard_custom) || chr(9)|| nvl(pack_product.relevant_for_label(relevant_for), relevant_for)  || chr(9)|| table_type || chr(9)||table_name as uam
from cd_fdw_structure
where object_type = 'TABLE' and rol_fermat_privileges is null
and ((table_type not in ('SESSION','TRANSACTION','QUEUE','TEMP','WORKSPACE','UNIQUE') 
) or standard_custom = 'C')
and table_name not like '%\_LOG' escape '\'
and table_name not like '%\_ERR' escape '\'
and table_name not like '%UPGRADE%'
and table_name not like 'RT%'
and table_name not like 'TMP%'
and table_name not like 'QUICK_ACCESS%'
and table_name not like 'WF%'
and table_name not like 'MC%'
and table_name not like 'BIRT%'
and table_name not like 'CMP%'
and table_name not like 'CO\_%' escape '\'
and table_name not like 'COA%'
and table_name not like 'CPC%'
and table_name not like 'CUSTOM%'
and table_name not like 'DB_FILES%' 
and table_name not like 'DW%'
and table_name not like 'EXPDP%'
and table_name not like 'LICENSE%'
and table_name not like 'LANGUAGES%'
and table_name not like 'EXT\_%' escape '\'
and table_name not like 'MIGRATION%'
and table_name not like 'PB\_%' escape '\'
and table_name not like 'TABLE\_%' escape '\'
and table_name not like 'PRIV\_%' escape '\'
and table_name not like 'ACCESS\_%' escape '\'
and table_name not like 'DSB\_%' escape '\'
and table_name not like 'ERM\_%' escape '\'
and table_name not like 'FERMAT\_%' escape '\'
and table_name not like 'GRID\_%' escape '\'
and table_name not like 'IDM\_%' escape '\'
and table_name not like 'PERFMGR\_%' escape '\'
and table_name not like 'PHASE\_%' escape '\'
and table_name not like 'SQL\_%' escape '\'
and table_name not like 'STAGING_TABLES%'
and table_name not like 'TEST\_%' escape '\'
and table_name not like 'TM\_%' escape '\'
and table_name not like 'TRACKING\_%' escape '\'
and table_name not like 'USER\_%' escape '\'
and table_name not like '%#CR'
and table_name not like '%#ERR' 
and table_name not like 'HF_TRACEABILITY'
and table_name not like 'ASSO\_%' escape '\'
and table_name not like 'CHAIN\_%' escape '\'
and table_name not like 'AREA\_%' escape '\'
and table_name not like 'FLOW\_%' escape '\'
and table_name not like 'FTS\_%' escape '\'
and table_name not like 'MONITORING\_%' escape '\'
and table_name not like 'PROCESS\_%' escape '\'
and table_name not like 'QV\_%' escape '\'
and table_name not like 'SCHEDULE\_%' escape '\'
and table_name not like 'TASK\_%' escape '\'
and table_name not like 'TCM\_%' escape '\'
and table_name not like 'WORKFLOW\_%' escape '\'
and table_name not like 'AUDIT\_%' escape '\'
and table_name not like 'FLOW\_%' escape '\'
and table_name not like 'HIST\_%' escape '\'
and table_name not like 'MOV\_%' escape '\'
and table_name not like 'POOL\_%' escape '\'
and table_name not like 'RUBY\_%' escape '\'
and table_name not like 'META\_%' escape '\'
and table_name not like 'BS\_%' escape '\'
and table_name not like 'JS\_%' escape '\'
and table_name not like '%#L' escape '\'
and table_name not like '%\_I' escape '\'
and table_name not like 'ERSWF\_%' escape '\'	
and table_name not like 'FCE\_%' escape '\'		
and table_name not like 'IMPORT\_%' escape '\' 
and table_name not like 'INSTRUMENT\_%' escape '\' 
and table_name not like 'LOAD\_%' escape '\'
and table_name not like 'SCN\_%' escape '\'
and table_name not in ('BUILD_HIST', 'DLL_METHOD', 'ID_GENERATOR', 'SCRIPT_INSTALL', 'UI_STATUS', 'ARCHIVE', 'BACKUP_TABLES', 'BUILD_HIST', 'EZ_CUST_POINTS', 'FILES_ASSOCIATIONS', 'MASTER_DETAIL', 'NOTIFICATION_SUBS', 'PARAM_TABLE_COLUMNS', 'ROW_BACKUP_COLS', 'SERVER_ALLOWED_PROCESS', 'SOLUTION_TYPE', 'SWAPPING_TABLE', 'TEMPORARY_TABLE', 'TEXT_REGISTER_TMP', 'TKPROF_TABLE', 'VALUE_TYPE', 'A_TECH_COLUMN', 'LOG_FILTER_MSG', 'LONG_COMMENTS', 'TECH_FCT_INDIC_MAPPING', 'TYPE_PARAMETERS_LINKS', 'CODIFIERS', 'INTERP_METHOD', 'PROPERTY_DATA_TYPE', 'CD_COMBI_ADMIN_PROFILES', 'SERVER_ALLOWED_PROCESS', 'B3_CONFIG', 'BIS_ENTITY_TYPE_SR', 'ENTITY_RATING_SR', 'GROUP_SR', 'LSR_AGG', 'LCR_OUTFLOW_DETAIL', 'COMPANY_PERIMETER')
and table_name not in ('CHAIN', 'CHECK_ERRORS_COUNTERS', 'IMPORTED_TABLES', 'INPUT_SCRIPT', 'INSTRUMENT', 'PROCESS', 'RELEASE_MAPPING', 'WORKFLOW','PROFILE_INFO_CONFIG', 'CONFIG_PARAM_SR', 'CHECK_ERRORS_COUNTERS')
order by 1;
spool off  

-------------------------------------------
-- print the NON EMPTY Table Access entries
-------------------------------------------

spool uam_table_list_all_non_empty.log

-- disable context filtering to get the list
call pack_context.contextid_disable();

-- generate the list of table for UAM template and skip empty tables
declare
	l_query               varchar2(20000);
	l_count               number:=0;
begin
	for rec in (select decode(standard_custom,'C','CUS','S','STD',standard_custom) standard_custom, nvl(pack_product.relevant_for_label(relevant_for), relevant_for) product, table_type, table_name 
		from cd_fdw_structure
		where object_type = 'TABLE' and rol_fermat_privileges is null
		and ((table_type not in ('SESSION','TRANSACTION','QUEUE','TEMP','WORKSPACE','UNIQUE') 
		) or standard_custom = 'C')
		and table_name not like '%\_LOG' escape '\'
		and table_name not like '%\_ERR' escape '\'
		and table_name not like '%UPGRADE%'
		and table_name not like 'RT%'
		and table_name not like 'TMP%'
		and table_name not like 'QUICK_ACCESS%'
		and table_name not like 'WF%'
		and table_name not like 'MC%'
		and table_name not like 'BIRT%'
		and table_name not like 'CMP%'
		and table_name not like 'CO\_%' escape '\'
		and table_name not like 'COA%'
		and table_name not like 'CPC%'
		and table_name not like 'CUSTOM%'
		and table_name not like 'DB_FILES%' 
		and table_name not like 'DW%'
		and table_name not like 'EXPDP%'
		and table_name not like 'LICENSE%'
		and table_name not like 'LANGUAGES%'
		and table_name not like 'EXT\_%' escape '\'
		and table_name not like 'MIGRATION%'
		and table_name not like 'PB\_%' escape '\'
		and table_name not like 'TABLE\_%' escape '\'
		and table_name not like 'PRIV\_%' escape '\'
		and table_name not like 'ACCESS\_%' escape '\'
		and table_name not like 'DSB\_%' escape '\'
		and table_name not like 'ERM\_%' escape '\'
		and table_name not like 'FERMAT\_%' escape '\'
		and table_name not like 'GRID\_%' escape '\'
		and table_name not like 'IDM\_%' escape '\'
		and table_name not like 'PERFMGR\_%' escape '\'
		and table_name not like 'PHASE\_%' escape '\'
		and table_name not like 'SQL\_%' escape '\'
		and table_name not like 'STAGING_TABLES%'
		and table_name not like 'TEST\_%' escape '\'
		and table_name not like 'TM\_%' escape '\'
		and table_name not like 'TRACKING\_%' escape '\'
		and table_name not like 'USER\_%' escape '\'
		and table_name not like '%#CR'
		and table_name not like '%#ERR' 
		and table_name not like 'HF_TRACEABILITY'
		and table_name not like 'ASSO\_%' escape '\'
		and table_name not like 'CHAIN\_%' escape '\'
		and table_name not like 'AREA\_%' escape '\'
		and table_name not like 'FLOW\_%' escape '\'
		and table_name not like 'FTS\_%' escape '\'
		and table_name not like 'MONITORING\_%' escape '\'
		and table_name not like 'PROCESS\_%' escape '\'
		and table_name not like 'QV\_%' escape '\'
		and table_name not like 'SCHEDULE\_%' escape '\'
		and table_name not like 'TASK\_%' escape '\'
		and table_name not like 'TCM\_%' escape '\'
		and table_name not like 'WORKFLOW\_%' escape '\'
		and table_name not like 'AUDIT\_%' escape '\'
		and table_name not like 'FLOW\_%' escape '\'
		and table_name not like 'HIST\_%' escape '\'
		and table_name not like 'MOV\_%' escape '\'
		and table_name not like 'POOL\_%' escape '\'
		and table_name not like 'RUBY\_%' escape '\'
		and table_name not like 'META\_%' escape '\'
		and table_name not like 'BS\_%' escape '\'
		and table_name not like 'JS\_%' escape '\'
		and table_name not like '%#L' escape '\'
		and table_name not like '%\_I' escape '\'
		and table_name not like 'ERSWF\_%' escape '\'	
		and table_name not like 'FCE\_%' escape '\'		
		and table_name not like 'IMPORT\_%' escape '\' 
		and table_name not like 'INSTRUMENT\_%' escape '\' 
		and table_name not like 'LOAD\_%' escape '\'
    and table_name not like 'SCN\_%' escape '\'		
		and table_name not in ('BUILD_HIST', 'DLL_METHOD', 'ID_GENERATOR', 'SCRIPT_INSTALL', 'UI_STATUS', 'ARCHIVE', 'BACKUP_TABLES', 'BUILD_HIST', 'EZ_CUST_POINTS', 'FILES_ASSOCIATIONS', 'MASTER_DETAIL', 'NOTIFICATION_SUBS', 'PARAM_TABLE_COLUMNS', 'ROW_BACKUP_COLS', 'SERVER_ALLOWED_PROCESS', 'SOLUTION_TYPE', 'SWAPPING_TABLE', 'TEMPORARY_TABLE', 'TEXT_REGISTER_TMP', 'TKPROF_TABLE', 'VALUE_TYPE', 'A_TECH_COLUMN', 'LOG_FILTER_MSG', 'LONG_COMMENTS', 'TECH_FCT_INDIC_MAPPING', 'TYPE_PARAMETERS_LINKS', 'CODIFIERS', 'INTERP_METHOD', 'PROPERTY_DATA_TYPE', 'CD_COMBI_ADMIN_PROFILES', 'SERVER_ALLOWED_PROCESS', 'B3_CONFIG', 'BIS_ENTITY_TYPE_SR', 'ENTITY_RATING_SR', 'GROUP_SR', 'LSR_AGG', 'LCR_OUTFLOW_DETAIL', 'COMPANY_PERIMETER')
		and table_name not in ('CHAIN', 'CHECK_ERRORS_COUNTERS', 'IMPORTED_TABLES', 'INPUT_SCRIPT', 'INSTRUMENT', 'PROCESS', 'RELEASE_MAPPING', 'WORKFLOW', 'PROFILE_INFO_CONFIG', 'CONFIG_PARAM_SR', 'CHECK_ERRORS_COUNTERS')
		order by 1)
	loop
		l_query := 'select count(*) from '||rec.table_name||' where rownum < 2 ';

		begin
			execute immediate l_query into l_count;
		exception
		when others then
			dbms_output.put_line(rec.table_name||' got error');
		end;
		
		-- print out only if non-empty
		if l_count>0 then
		  dbms_output.enable(null);
		  dbms_output.put_line(rec.standard_custom||chr(9)||rec.product||chr(9)||rec.table_type||chr(9)||rec.table_name);
		end if;
	end loop;	
end;
/

-- enable context filtering again
call pack_context.context_enabled();

-------------------------------------------
-- print Role
-------------------------------------------
--

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_role_list.log

select priv_id ||chr(9)||  role_name as role_name
from priv_role;

spool off


-------------------------------------------
-- print the Other App
-------------------------------------------
-- TODO: may not be used

set termout off echo off heading off trimspool on
set linesize 200 pagesize 9999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_other_app_list.log

select application || chr(9)|| object_type || chr(9)|| action_type || chr(9)|| action_type_id as uam
from v_access_external
order by application, object_type, action_type;
		
spool off		

-- @-------------------------------------------
-- @ print the Section Space
-- @ version RFo v1.01
-- @-------------------------------------------
set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off
SET SERVEROUTPUT ON

spool uam_dsb_section_space.log

select name || chr(9)||id as list from dsb_section_space order by id;

spool off

-- @-------------------------------------------
-- @ print the Section
-- @ version RFo v1.01
-- @-------------------------------------------
set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off
SET SERVEROUTPUT ON

spool uam_dsb_section.log

select name || chr(9) || id  as list from dsb_section where is_public='Y' order by id;

spool off

-- @-------------------------------------------
-- @ print the Page
-- @ version RFo v1.01
-- @-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off
SET SERVEROUTPUT ON

spool uam_dsb_page.log

select name || chr(9) || id  as list
from dsb_page where is_for_public_using='Y' order by id;

spool off

-------------------------------------------
-- print the Widget
-- @ version RFo v1.01
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_dsb_widget.log

select external_editor_id || chr(9) || name || chr(9) || id  as list
from dsb_widget order by id;

spool off


-------------------------------------------
-- print the qv application
-- @ version RFo v1.01
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_qv_application.log

select description || chr(9) || application_id
from qv_applications order by application_id;

spool off



-------------------------------------------
-- print the qv sheets
-- @ version RFo v1.01
-------------------------------------------

set termout off echo off heading off trimspool on
set linesize 200 pagesize 999 heading OFF
set feedback off echo off termout on timing off time off
SET SERVEROUTPUT ON

spool uam_qv_sheet.log

select description || chr(9) || application_id || chr(9) || sheet_id
from qv_sheets order by application_id, sheet_id;

spool off


exit;


		