--#######################################################################
-- wijaya.kusumo v2.0
-- Apply NODE access matrix from template to database
-- For RFo v1.2
--
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--    wijaya.kusumo       v2.3        Added print to log_table
--        LB              v2.3            test in RFO 2.0
--#######################################################################

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool apply_node_access.log

declare
  l_proc        VARCHAR2(60):='uam_apply_node_access';
  l_step        VARCHAR2(3) := '000';  
  l_start_time	DATE;
  i INTEGER;
  j INTEGER;
  type t_tab is table of varchar2(100);
  type t_list is table of t_tab;
  v_access_type varchar2(100);
  v_group_id varchar2(100);
  v_object_name varchar2(100);
  v_item_type varchar2(100); 
  v_item_sub_type varchar2(100);
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
t_tab('w_explore_4eyes_validation','','','Y','Y','Y','Y','','Y','','','','','',''),
t_tab('w_perfmgr_awr_reports','','','','','H','H','','H','','','','','',''),
t_tab('w_access_mgt','','','','','H','H','','H','','','','','',''),
t_tab('w_archive','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_audit_trail','','','','','H','H','','H','','','','','',''),
t_tab('w_rapm_access_mgt','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_import','','','','','H','H','','H','','','','','',''),
t_tab('w_build_browser','','','','','H','H','','H','','','','','',''),
t_tab('w_build_custom_cube','','','','','H','H','','H','','','','','',''),
t_tab('w_build_custom_dw','','','','','H','H','','H','','','','','',''),
t_tab('w_build_custom_win','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_report_table_birt_inst','','','','','H','H','','H','','','','','',''),
t_tab('w_campaigns','','','','','H','H','','H','','','','','',''),
t_tab('w_check_errors','','','','','H','H','','H','','','','','',''),
t_tab('w_comp_management','','','','','H','H','','H','','','','','',''),
t_tab('w_perfmgr_config','','','','','H','H','','H','','','','','',''),
t_tab('w_contexts','','','','','H','H','','H','','','','','',''),
t_tab('w_context_selection','','','','','H','H','','H','','','','','',''),
t_tab('w_db_files','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_db_objects','','','','','H','H','','H','','','','','',''),
t_tab('w_dmm','','','','','H','H','','H','','','','','',''),
t_tab('w_dw_from_select','','','','','H','H','','H','','','','','',''),
t_tab('w_export_filtered','','','','','H','H','','H','','','','','',''),
t_tab('w_datawindow','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_kpi','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_report_tables','','','','','H','H','','H','','','','','',''),
t_tab('w_dmt_export','','','','','H','H','','H','','','','','',''),
t_tab('w_dmt_import','','','','','H','H','','H','','','','','',''),
t_tab('w_migration_import_history','','','','','H','H','','H','','','','','',''),
t_tab('w_log','','','','','H','H','','H','','','','','',''),
t_tab('w_admin_log','','','','','H','H','','H','','','','','',''),
t_tab('w_oracle_administration','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_plsql','','','','','H','H','','H','','','','','',''),
t_tab('w_server_process','','','','','H','H','','H','','','','','',''),
t_tab('w_quick_access','','','','','H','H','','H','','','','','',''),
t_tab('w_quick_edit_view','','','','','H','H','','H','','','','','',''),
t_tab('w_import_export_tables','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_rt','','','','','H','H','','H','','','','','',''),
t_tab('w_runs','','','','','H','H','','H','','','','','',''),
t_tab('w_scq_reports','','','','','H','H','','H','','','','','',''),
t_tab('w_server_server','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_system_administration','','','','','H','H','','H','','','','','',''),
t_tab('w_server_task','','','','','H','H','','H','','','','','',''),
t_tab('w_test_management','','','','','H','H','','H','','','','','',''),
t_tab('w_test_management_def','','','','','H','H','','H','','','','','',''),
t_tab('w_test_management_process','','','','','H','H','','H','','','','','',''),
t_tab('w_translate','','','','','H','H','','H','','','','','',''),
t_tab('w_prepare_upgrade','','','','','H','H','','H','','','','','',''),
t_tab('w_window','','','','','H','H','','H','','','','','',''),
t_tab('w_xmldw','','','','','H','H','','H','','','','','',''),
t_tab('w_about','','','','','H','H','','H','','','','','',''),
t_tab('w_about_details','','','','','H','H','','H','','','','','',''),
t_tab('w_au_flow','','','','','H','H','','H','','','','','',''),
t_tab('w_bind_variables','','','','','H','H','','H','','','','','',''),
t_tab('w_border_window','','','','','H','H','','H','','','','','',''),
t_tab('w_browse_archive','','','','','H','H','','H','','','','','',''),
t_tab('w_browser_child','','','','','H','H','','H','','','','','',''),
t_tab('w_browser_palette','','','','','H','H','','H','','','','','',''),
t_tab('w_bv_wizard_add_filter','','','','','H','H','','H','','','','','',''),
t_tab('w_change_any_password','','','','','H','H','','H','','','','','',''),
t_tab('w_change_idm_pwd','','','','','H','H','','H','','','','','',''),
t_tab('w_change_password','','','','','H','H','','H','','','','','',''),
t_tab('w_check_errors_detail','','','','','H','H','','H','','','','','',''),
t_tab('w_col_settings','','','','','H','H','','H','','','','','',''),
t_tab('w_com_message_from','','','','','H','H','','H','','','','','',''),
t_tab('w_compare_more_runs','','','','','H','H','','H','','','','','',''),
t_tab('w_compare_runs','','','','','H','H','','H','','','','','',''),
t_tab('w_config_cube_export','','','','','H','H','','H','','','','','',''),
t_tab('w_config_dw_export','','','','','H','H','','H','','','','','',''),
t_tab('w_config_dw_export_custom','','','','','H','H','','H','','','','','',''),
t_tab('w_config_dw_update','','','','','H','H','','H','','','','','',''),
t_tab('w_context_backup','','','','','H','H','','H','','','','','',''),
t_tab('w_context_connected_users','','','','','H','H','','H','','','','','',''),
t_tab('w_context_copy','','','','','H','H','','H','','','','','',''),
t_tab('w_context_create','','','','','H','H','','H','','','','','',''),
t_tab('w_context_restore','','','','','H','H','','H','','','','','',''),
t_tab('w_context_tools','','','','','H','H','','H','','','','','',''),
t_tab('w_context_truncate','','','','','H','H','','H','','','','','',''),
t_tab('w_copy_dependencies','','','','','H','H','','H','','','','','',''),
t_tab('w_correct_import_gen_list_page','','','','','H','H','','H','','','','','',''),
t_tab('w_correct_import_grid','','','','','H','H','','H','','','','','',''),
t_tab('w_correct_import_list_page','','','','','H','H','','H','','','','','',''),
t_tab('w_correct_import_table','','','','','H','H','','H','','','','','',''),
t_tab('w_create_awr','','','','','H','H','','H','','','','','',''),
t_tab('w_create_scq','','','','','H','H','','H','','','','','',''),
t_tab('w_create_user','','','','','H','H','','H','','','','','',''),
t_tab('w_cube_definition','','','','','H','H','','H','','','','','',''),
t_tab('w_custom_cube','','','','','H','H','','H','','','','','',''),
t_tab('w_custom_win_builder','','','','','H','H','','H','','','','','',''),
t_tab('w_data_security','','','','','H','H','','H','','','','','',''),
t_tab('w_db_files_cube','','','','','H','H','','H','','','','','',''),
t_tab('w_db_files_father','','','','','H','H','','H','','','','','',''),
t_tab('w_ddms','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_audit_trail_row','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_audit_trail_row_new','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_block_coop_simu','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_context_selection','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_cube_detail','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_db_files_table','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_rt_hist_columns','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_rt_hist_keys','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_rt_output','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_rt_reply','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_rt_xml_in','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_rt_xml_out','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_user_roles','','','','','H','H','','H','','','','','',''),
t_tab('w_disclaimer','','','','','H','H','','H','','','','','',''),
t_tab('w_display_archive_table','','','','','H','H','','H','','','','','',''),
t_tab('w_display_coop_simu','','','','','H','H','','H','','','','','',''),
t_tab('w_display_db_error','','','','','H','H','','H','','','','','',''),
t_tab('w_display_graph_run','','','','','H','H','','H','','','','','',''),
t_tab('w_display_select','','','','','H','H','','H','','','','','',''),
t_tab('w_display_table_access','','','','','H','H','','H','','','','','',''),
t_tab('w_dw_builder','','','','','H','H','','H','','','','','',''),
t_tab('w_dw_design','','','','','H','H','','H','','','','','',''),
t_tab('w_dw_infos','','','','','H','H','','H','','','','','',''),
t_tab('w_dw_print','','','','','H','H','','H','','','','','',''),
t_tab('w_dw_sort','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_column_child','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_father_new','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_father_new_child','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_father_new_response','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_line_father','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_line_father_virtual','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_line_father_virtual_child','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_line_father_virtual_popup','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_migration_bind_vars','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_sql','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_table','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_tree_explore_father','','','','','H','H','','H','','','','','',''),
t_tab('w_editor_color','','','','','H','H','','H','','','','','',''),
t_tab('w_editor_find','','','','','H','H','','H','','','','','',''),
t_tab('w_editor_goto','','','','','H','H','','H','','','','','',''),
t_tab('w_editor_replace','','','','','H','H','','H','','','','','',''),
t_tab('w_editor_tabwidth','','','','','H','H','','H','','','','','',''),
t_tab('w_evaluate','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_father','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_father_child','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_father_popup','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_kpi_dependency','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_phase','','','','','H','H','','H','','','','','',''),
t_tab('w_ez_custo','','','','','H','H','','H','','','','','',''),
t_tab('w_fermat_pb_util','','','','','H','H','','H','','','','','',''),
t_tab('w_filtered_tasks','','','','','H','H','','H','','','','','',''),
t_tab('w_for_pb_task','','','','','H','H','','H','','','','','',''),
t_tab('w_gem_navigator_options','','','','','H','H','','H','','','','','',''),
t_tab('w_get_db_file','','','','','H','H','','H','','','','','',''),
t_tab('w_get_file_db_file','','','','','H','H','','H','','','','','',''),
t_tab('w_graph','','','','','H','H','','H','','','','','',''),
t_tab('w_graph_child','','','','','H','H','','H','','','','','',''),
t_tab('w_graph_definition','','','','','H','H','','H','','','','','',''),
t_tab('w_help_dmm_column_child','','','','','H','H','','H','','','','','',''),
t_tab('w_idm','','','','','H','H','','H','','','','','',''),
t_tab('w_input_box','','','','','H','H','','H','','','','','',''),
t_tab('w_input_box_resizable','','','','','H','H','','H','','','','','',''),
t_tab('w_load_dump_db_files','','','','','H','H','','H','','','','','',''),
t_tab('w_login','','','','','H','H','','H','','','','','',''),
t_tab('w_main','','','','','H','H','','H','','','','','',''),
t_tab('w_multi_report_father','','','','','H','H','','H','','','','','',''),
t_tab('w_open_dw','','','','','H','H','','H','','','','','',''),
t_tab('w_other_sessions','','','','','H','H','','H','','','','','',''),
t_tab('w_output_debug','','','','','H','H','','H','','','','','',''),
t_tab('w_register_license','','','','','H','H','','H','','','','','',''),
t_tab('w_run_files','','','','','H','H','','H','','','','','',''),
t_tab('w_save_browser','','','','','H','H','','H','','','','','',''),
t_tab('w_schedule_parameter','','','','','H','H','','H','','','','','',''),
t_tab('w_search_query_new','','','','','H','H','','H','','','','','',''),
t_tab('w_search_tree','','','','','H','H','','H','','','','','',''),
t_tab('w_select_context','','','','','H','H','','H','','','','','',''),
t_tab('w_select_tables','','','','','H','H','','H','','','','','',''),
t_tab('w_server_launch_task','','','','','H','H','','H','','','','','',''),
t_tab('w_sparse_group_def','','','','','H','H','','H','','','','','',''),
t_tab('w_table_columns_audit','','','','','H','H','','H','','','','','',''),
t_tab('w_task_parameter','','','','','H','H','','H','','','','','',''),
t_tab('w_test_block_params','','','','','H','H','','H','','','','','',''),
t_tab('w_test_new_ancestor','','','','','H','H','','H','','','','','',''),
t_tab('w_tm_flag_as_known_bug','','','','','H','H','','H','','','','','',''),
t_tab('w_tm_launch','','','','','H','H','','H','','','','','',''),
t_tab('w_transparent','','','','','H','H','','H','','','','','',''),
t_tab('w_wait_main','','','','','H','H','','H','','','','','',''),
t_tab('w_wait_task','','','','','H','H','','H','','','','','',''),
t_tab('w_waiter','','','','','H','H','','H','','','','','',''),
t_tab('w_waiter_timer','','','','','H','H','','H','','','','','',''),
t_tab('w_web_window','','','','','H','H','','H','','','','','',''),
t_tab('w_welcome','','','','','H','H','','H','','','','','',''),
t_tab('w_win_infos','','','','','H','H','','H','','','','','',''),
t_tab('w_window_father','','','','','H','H','','H','','','','','',''),
t_tab('w_window_finder','','','','','H','H','','H','','','','','',''),
t_tab('w_window_super_father','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_father_virtual','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_frt_build_bizdim','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_frt_new_dimension','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_frt_report_table_adddim','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_frt_report_table_addhistdim','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_frt_report_table_addprop','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_select_coop_simu','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_select_graph_run','','','','','H','H','','H','','','','','',''),
t_tab('w_allocation_range','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bale2_param','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_parameter','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_sub_perimeter','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_ccf','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_ccf_backtest_run','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_crm_mv','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_bis_crm_custom','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_crm','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_cva_supervisor','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_val_chk_param','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_credit_event','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_ce_backtest_run','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_default_file','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_crm','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_entity_links','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_real_estate','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_entity','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_exposure','','','','','H','H','','H','','','','','',''),
t_tab('w_retail_handling','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_ldb','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_bis_simul_strategy','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_impairment_param','','','','','H','H','','H','','','','','',''),
t_tab('w_impairment_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_le_process','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_lgd','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_lgd_backtest_run','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_bis_le_supervisor','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_operational_risk_mapping','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_pd','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_operational_risk_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_retail','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_pre_aggreg_set','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_re_mv','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_ldb_event','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_val_chk_results','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_dim','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_retail_exposure','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_scoring','','','','','H','H','','H','','','','','',''),
t_tab('w_retail_segmentation','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_strategy','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_simul_ratings','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_supervisor','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_bis_dd_guar_rating','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_display_ldb_contract_crm','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_display_ldb_contract_real_estate','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_ldb_contract_crm','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_ldb_facility_counterparty','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_ldb_facility_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_ldb_indicator','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_ldb_mortgage_re_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_ldb_recovery_flow','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_retail_booked_amounts','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_retail_provision','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_securitization_sr','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_tranche_sr','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_underlying_pool_sr','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_audit_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_crm_col_case','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_crm_col_function','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_bis_val_chk_res_details','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_disc_items','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_disc_mapping','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_disclosure_own_fund','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_bis_admin','','','','','H','H','','H','','','','','',''),
t_tab('w_launch_workflow','','','','','H','H','','H','','','','','',''),
t_tab('w_modal_create_default_file','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_fill_ce_default_file','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_fill_credit_event','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_sa_set_de_link','','','','','H','H','','H','','','','','',''),
t_tab('w_wizard_sa_set_link','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_nbi_accounts','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_audit_perimeter','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_nbi_reconciliation','','','','','H','H','','H','','','','','',''),
t_tab('w_fce_param','','','','','H','H','','H','','','','','',''),
t_tab('w_bis_param','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_account_chart','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_client_options','','','','','H','H','','H','','','','','',''),
t_tab('w_fct_audit_columns','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_commission_process','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_commission_def','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_coop_simu','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_spread_curve','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_explode','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_fx','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_rate_family_accrual_basis_conversion','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_indicator_calculation','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_key_analysis','','','','','H','H','','H','','','','','',''),
t_tab('w_manual_operation_set','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_gds_param','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_financial_data','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_nbi_operation_valuation','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_pel','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_past_volatility','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_curve_shift','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_nbi_reconciliation_param','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_gl_reconciliation','','','','','H','H','','H','','','','','',''),
t_tab('w_reconciliation_pre_calcul','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_releasing','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_vol_corr','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_stats_run_instrument','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_season_effect','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_MR_Strategies','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_scenario','','','','','H','H','','H','','','','','',''),
t_tab('w_time_horizon','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_flow','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_mc_simulations','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_config_param_ve','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_alm_var_simulations','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_vol_shift','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_risk_sensitivity_import','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_smile','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_config_param_epe','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_credit_spread','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_external_pricer','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_dg_cube_result','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_dg_result','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_hist_param','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_histo_result','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_mc_back_test','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_mc_cube_result','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_mc_repartition','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_var_mc_result','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_commission','','','','','H','H','','H','','','','','',''),
t_tab('w_forward_rate_ask','','','','','H','H','','H','','','','','',''),
t_tab('w_forward_rate_sim_ask','','','','','H','H','','H','','','','','',''),
t_tab('w_show_alm_subset','','','','','H','H','','H','','','','','',''),
t_tab('w_show_k_parameters_formulas','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_other_contracts','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_aggregated_contracts','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_aggregate','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_common_supervisor','','','','','H','H','','H','','','','','',''),
t_tab('w_gl_display_bs','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_date_rules','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_commodity','','','','','H','H','','H','','','','','',''),
t_tab('w_companies_links','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_recon_config','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_contract_types_links','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_correlation','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_other_imports','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_crm_contracts','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_currency','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_cursor_extension','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_curve_def','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_business_line_data','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_deal_book_links','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_dealbag','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_security_contracts','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_derivatives','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_entity2','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_entity_links','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_companies','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_dealbooks','FAMILY','FAMILY','','','RO','N','','N','','','','','',''),
t_tab('w_explore_fdw_netting','','','','','H','H','','H','','','','','',''),
t_tab('w_fee_based_product','','','','','H','H','','H','','','','','',''),
t_tab('w_pel_forecast','','','','','H','H','','H','','','','','',''),
t_tab('w_foreign_exchange_position','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_formula_usrparam','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_account','','','','','H','H','','H','','','','','',''),
t_tab('w_gl_and_deal','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_geographic_area_links','','','','','H','H','','H','','','','','',''),
t_tab('w_rate_input','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_index_def','','','','','H','H','','H','','','','','',''),
t_tab('w_islamic_deal','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_business_line_links','','','','','H','H','','H','','','','','',''),
t_tab('w_com_message','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_lr_national_market','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_numeric_bucket','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_other_income','','','','','H','H','','H','','','','','',''),
t_tab('w_deal_import','','','','','H','H','','H','','','','','',''),
t_tab('w_pel','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_business_line_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_parameters_links','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_other_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_insurance_pool','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_provision','','','','','H','H','','H','','','','','',''),
t_tab('w_purchased_receivable','','','','','H','H','','H','','','','','',''),
t_tab('w_query_builder','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_family','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_rating_parameters','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_renewal_spread','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_recon_result','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_security','','','','','H','H','','H','','','','','',''),
t_tab('w_securitization_credit_derivative','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_simulated_contracts','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_time_band','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_volatility','','','','','H','H','','H','','','','','',''),
t_tab('w_all_connected_users','','','','','H','H','','H','','','','','',''),
t_tab('w_choose_entity','','','','','H','H','','H','','','','','',''),
t_tab('w_choose_security','','','','','H','H','','H','','','','','',''),
t_tab('w_com_message_new','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_booked_amounts','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_caplet','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_cash_flow_past','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_computed_fields','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_contract_guarantee','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_contract_guarantying','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_contract_position','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_coupon_steps','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_credit_agreement_cpty','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_credit_agreement_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_credit_agreement_products','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_credit_event','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_credit_rating','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_deliverable_assets','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_edit_stages','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_equity_forecast','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_exchange_composition','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_explore_facilities_tree','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_external_entity_code','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_external_security_code','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_facility_counterparty','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_facility_drawdown_def','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_facility_drawdown_flow','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_facility_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_facility_products','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_fdw_cash_flow','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_fdw_cash_flow_recovery','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_fixing_period_data','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_folder_contract','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_fund_composition','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_fund_computed_fields','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_gross_income','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_guaranted_agreements','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_index_composition','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_issuer_credit_rating','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_key_analysis_detail_new','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_mortgage_note_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_netted_entity','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_option_exercise_date','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_prov_contract_types','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_provision','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_provision_retail','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_provisioned_contracts','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_range_accrual_steps','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_real_estate_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_reference_list','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_repo_portfolio','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_secu_cies_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_security_multiple_guarantors','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_tranche_links','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_und_pool_link','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_underlying_asset','','','','','H','H','','H','','','','','',''),
t_tab('w_depend_underlying_receivables','','','','','H','H','','H','','','','','',''),
t_tab('w_display_contract','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_dw_arguments','','','','','H','H','','H','','','','','',''),
t_tab('w_edit_log_query','','','','','H','H','','H','','','','','',''),
t_tab('w_entity_group','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_entity','','','','','H','H','','H','','','','','',''),
t_tab('w_explore_security','','','','','H','H','','H','','','','','',''),
t_tab('w_fct_tree_view','','','','','H','H','','H','','','','','',''),
t_tab('w_filter_clause_for_cmp','','','','','H','H','','H','','','','','',''),
t_tab('w_launch_blocks','','','','','H','H','','H','','','','','',''),
t_tab('w_link_table','','','','','H','H','','H','','','','','',''),
t_tab('w_only_columns_for_cmp_area','','','','','H','H','','H','','','','','',''),
t_tab('w_report_from_sql','','','','','H','H','','H','','','','','',''),
t_tab('w_report_window','','','','','H','H','','H','','','','','',''),
t_tab('w_select_link_table','','','','','','','','','','','','','',''),
t_tab('w_show_all_check_errors','','','','','','','','','','','','','',''),
t_tab('w_show_backup_data','','','','','','','','','','','','','',''),
t_tab('w_test_management_father','','','','','','','','','','','','','',''),
t_tab('w_wizard_recon_status','','','','','','','','','','','','','',''),
t_tab('w_explore_additional_infos','','','','','','','','','','','','','',''),
t_tab('w_edit_reporting_own_fund','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_reports_sets','','','','','','','','','','','','','',''),
t_tab('w_explore_audit_set','','','','','','','','','','','','','',''),
t_tab('w_explore_audit_track_templates','','','','','','','','','','','','','',''),
t_tab('w_explore_adjustment_and_audit','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_cpy_set','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_context_set','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_agg_param_custom','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_envelope','','','','','','','','','','','','','',''),
t_tab('w_edit_rep_extend_input_tables','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_agg_param','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_reporting_process','','','','','','','','','','','','','',''),
t_tab('w_db_rep_files','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_gen_fields_def','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_global_variable','','','','','','','','','','','','','',''),
t_tab('w_explore_imported_reports','','','','','','','','','','','','','',''),
t_tab('w_import','','','','','','','','','','','','','',''),
t_tab('w_explore_regulatory_data','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_fct_mapping_custo','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_tech_mapping_custo','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_tech_mapping_fermat','','','','','','','','','','','','','',''),
t_tab('w_explore_audit_rpt_result','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_variance_results','','','','','','','','','','','','','',''),
t_tab('w_edit_reporting_param','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_loading_process','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_env_set','','','','','','','','','','','','','',''),
t_tab('w_edit_rep_simple_input_tables','','','','','','','','','','','','','',''),
t_tab('w_explore_sub_perimeter','','','','','','','','','','','','','',''),
t_tab('w_edit_bus_rule_param','','','','','','','','','','','','','',''),
t_tab('w_edit_bus_rule_results','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_env_param','','','','','','','','','','','','','',''),
t_tab('w_audit_import_results','','','','','','','','','','','','','',''),
t_tab('w_build_excel_rule','','','','','','','','','','','','','',''),
t_tab('w_build_expression','','','','','','','','','','','','','',''),
t_tab('w_build_rule','','','','','','','','','','','','','',''),
t_tab('w_choose_aggregate_functional_dimension','','','','','','','','','','','','','',''),
t_tab('w_choose_aggregation_set','','','','','','','','','','','','','',''),
t_tab('w_choose_functional_dimension','','','','','','','','','','','','','',''),
t_tab('w_cube_audit_reporting','','','','','','','','','','','','','',''),
t_tab('w_cube_audit_step2_reporting','','','','','','','','','','','','','',''),
t_tab('w_depend_audit_cube_display','','','','','','','','','','','','','',''),
t_tab('w_depend_display_query','','','','','','','','','','','','','',''),
t_tab('w_depend_rep_dimension_formula','','','','','','','','','','','','','',''),
t_tab('w_depend_rep_fact_formula','','','','','','','','','','','','','',''),
t_tab('w_depend_rep_full_xbrl_dim','','','','','','','','','','','','','',''),
t_tab('w_depend_rep_rpt_audit','','','','','','','','','','','','','',''),
t_tab('w_depend_rep_rpt_audit_import','','','','','','','','','','','','','',''),
t_tab('w_depend_rep_xbrl_dim','','','','','','','','','','','','','',''),
t_tab('w_depend_rule','','','','','','','','','','','','','',''),
t_tab('w_edit_bus_rule_res_details','','','','','','','','','','','','','',''),
t_tab('w_edit_generated_reports','','','','','','','','','','','','','',''),
t_tab('w_explore_audit_check_definition','','','','','','','','','','','','','',''),
t_tab('w_explore_audit_check_results','','','','','','','','','','','','','',''),
t_tab('w_explore_audit_set_result','','','','','','','','','','','','','',''),
t_tab('w_explore_envelope','','','','','','','','','','','','','',''),
t_tab('w_explore_import_results','','','','','','','','','','','','','',''),
t_tab('w_explore_rep_loading_process_query','','','','','','','','','','','','','',''),
t_tab('w_explore_reporting','','','','','','','','','','','','','',''),
t_tab('w_simple_import','','','','','','','','','','','','','',''),
t_tab('w_explore_sae_access','','','','','','','','','','','','','',''),
t_tab('w_explore_sae','','','','','','','','','','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line			

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(1000000);
  pack_context.contextid_open(1);  
  pack_log.log_begin('UAM: APPLY NODE ACCESS',null,null,'Apply Node UAM'); 
  v_group_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Setting NODE access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  pack_log.log_write('I','T',l_proc,l_step,'Setting NODE access matrix...',null);
  
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
  delete from priv p where exists (select 1 from priv_node pp where pp.priv_id=p.priv_id);
  pack_log.log_write('I','T',l_proc,l_step,sql%rowcount||' row(s) of old UAM entries deleted.',null);
  
  dbms_output.put_line('--Creating new UAM entries...');
  pack_log.log_write('I','T',l_proc,l_step,'--Creating new UAM entries...',null);
  
  l_step:='020';
  -- loop the UAM setting
  FOR i in v_access_list.first.. v_access_list.last LOOP
    v_access := v_access_list(i);
    v_object_name :=v_access(1);
    v_item_sub_type := v_access(3);
    v_item_type := v_access(2);
    
    l_step:='021';
    dbms_output.put_line('----Inserting default UAM entry...');
    pack_log.log_write('I','T',l_proc,l_step,'----Inserting default UAM entry...',null);
    -- insert the DEFAULT access rules: deny all with lowest priority
    IF v_item_type is not null and v_item_sub_type is not null then
	    insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name, item_type, item_sub_type) 
			values ( seq_priv.nextval, 0, 0, 'H', 99, 'node', v_object_name, v_item_type, v_item_sub_type);
 	 	END IF;
    dbms_output.put_line('----Object ID:'||v_object_name||' access:H priority:99');
    pack_log.log_write('I','T',l_proc,l_step,'----Object ID:'||v_object_name||' access:N priority:99',null);
    
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-3 LOOP
      v_access_type := v_access(3+j);
      v_group_id := v_group_ids(j);
		
      -- grant the access only if v_item_type and v_item_sub_type are defined
      IF v_item_type is not null and v_item_sub_type is not null then
	      IF  v_access_type = 'Y' THEN
	        l_step:='022';
	        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name, item_type, item_sub_type) 
						values ( seq_priv.nextval, v_group_id, 0, 'Y', 10, 'node', v_object_name, v_item_type, v_item_sub_type);
	        
	        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10');
	        pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10',null);

	      ELSIF  v_access_type = 'RO' THEN
	        l_step:='023';
	        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name, item_type, item_sub_type) 
						values ( seq_priv.nextval, v_group_id, 0, 'R', 20, 'node', v_object_name, v_item_type, v_item_sub_type);
	        
	        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:R priority:20');
				  pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:R priority:20',null);
	      ELSIF  v_access_type = 'N' THEN
	        l_step:='024';
	        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name, item_type, item_sub_type) 
						values ( seq_priv.nextval, v_group_id, 0, 'N', 30, 'node', v_object_name, v_item_type, v_item_sub_type);
	        
	        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:N priority:30');
					pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:N priority:30',null);
	      END IF;
	    ELSE
	    	dbms_output.put_line('====Skipped: v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:'||v_access_type||' due to no v_item_type and v_item_sub_type');
	      pack_log.log_write('I','T',l_proc,l_step,'====Skipped: v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:'||v_access_type||' due to no v_item_type and v_item_sub_type',null);
	  	END IF;
    END LOOP;
  END LOOP;
  commit;

  l_step:='030';
  -- update the statistics
  dbms_output.put_line('Gather table statistics....');
  pack_stats.gather_table_stats('PRIV');
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  pack_stats.gather_table_stats('PRIV_NODE');

  pack_stats.gather_table_stats('PRIV_WIN');
  pack_stats.gather_table_stats ('GRANTEE_MEMBER');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('CD_USERS');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('PRIV_ROLE_PRIV');
  pack_stats.gather_table_stats ('PRIV_ROLE');
  pack_stats.gather_table_stats ('PRIV_DW');
  pack_stats.gather_table_stats ('PRIV_MENU');
  pack_stats.gather_table_stats ('PRIV_BROWSER');
  pack_stats.gather_table_stats ('PRIV_PROCESS');
  pack_stats.gather_table_stats ('PRIV_ACTION');
  pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_CONTEXT');
  pack_stats.gather_table_stats ('PRIV_TABLE');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');
    
  dbms_output.put_line('Setting NODE access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting NODE access matrix... done.',null);
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
