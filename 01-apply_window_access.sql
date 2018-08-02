--#######################################################################
-- wijaya.kusumo v2.0
-- Apply WINDOW access matrix from template to database
-- For RFo v1.2
--
-- Revision: 
--    Author            Version     Note
--    ---------------   ---------   ---------------------------
--       wijaya.kusumo    v2.3        Added print to log_table
--        LB              v2.3            test in RFO 2.0
--#######################################################################

set serverout on size unlimited
WHENEVER SQLERROR EXIT SQL.SQLCODE

spool apply_window_access.log

declare
  l_proc        VARCHAR2(60):='uam_apply_window_access';
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
t_tab('w_explore_4eyes_validation','Y','Y','Y','Y','','Y','','','','','',''),
t_tab('w_perfmgr_awr_reports','','','N','N','','N','','','','','',''),
t_tab('w_access_mgt','','','N','RO','','N','','','','','',''),
t_tab('w_archive','','','N','N','','N','','','','','',''),
t_tab('w_edit_audit_trail','','','N','N','','N','','','','','',''),
t_tab('w_rapm_access_mgt','','','N','N','','N','','','','','',''),
t_tab('w_edit_import','','','N','N','','N','','','','','',''),
t_tab('w_build_browser','','','N','N','','N','','','','','',''),
t_tab('w_build_custom_cube','','','N','N','','N','','','','','',''),
t_tab('w_build_custom_dw','','','N','N','','N','','','','','',''),
t_tab('w_build_custom_win','','','N','N','','N','','','','','',''),
t_tab('w_explore_report_table_birt_inst','','','N','N','','N','','','','','',''),
t_tab('w_campaigns','','','N','N','','N','','','','','',''),
t_tab('w_check_errors','','','N','N','','N','','','','','',''),
t_tab('w_comp_management','','','N','N','','N','','','','','',''),
t_tab('w_perfmgr_config','','','N','N','','N','','','','','',''),
t_tab('w_contexts','','','N','N','','N','','','','','',''),
t_tab('w_context_selection','','','N','N','','N','','','','','',''),
t_tab('w_db_files','','','N','N','','N','','','','','',''),
t_tab('w_explore_db_objects','','','N','N','','N','','','','','',''),
t_tab('w_dmm','','','N','N','','N','','','','','',''),
t_tab('w_dw_from_select','','','N','N','','N','','','','','',''),
t_tab('w_export_filtered','','','N','N','','N','','','','','',''),
t_tab('w_datawindow','','','N','N','','N','','','','','',''),
t_tab('w_explore_kpi','','','N','N','','N','','','','','',''),
t_tab('w_explore_report_tables','','','N','N','','N','','','','','',''),
t_tab('w_dmt_export','','','N','N','','N','','','','','',''),
t_tab('w_dmt_import','','','N','N','','N','','','','','',''),
t_tab('w_migration_import_history','','','N','N','','N','','','','','',''),
t_tab('w_log','','','N','N','','N','','','','','',''),
t_tab('w_admin_log','','','N','N','','N','','','','','',''),
t_tab('w_oracle_administration','','','N','N','','N','','','','','',''),
t_tab('w_edit_plsql','','','N','N','','N','','','','','',''),
t_tab('w_server_process','','','N','N','','N','','','','','',''),
t_tab('w_quick_access','','','N','N','','N','','','','','',''),
t_tab('w_quick_edit_view','','','N','N','','N','','','','','',''),
t_tab('w_import_export_tables','','','N','N','','N','','','','','',''),
t_tab('w_edit_rt','','','N','N','','N','','','','','',''),
t_tab('w_runs','','','N','N','','N','','','','','',''),
t_tab('w_scq_reports','','','N','N','','N','','','','','',''),
t_tab('w_server_server','','','N','N','','N','','','','','',''),
t_tab('w_edit_system_administration','','','N','N','','N','','','','','',''),
t_tab('w_server_task','','','N','RO','','N','','','','','',''),
t_tab('w_test_management','','','N','N','','N','','','','','',''),
t_tab('w_test_management_def','','','N','N','','N','','','','','',''),
t_tab('w_test_management_process','','','N','N','','N','','','','','',''),
t_tab('w_translate','','','N','N','','N','','','','','',''),
t_tab('w_prepare_upgrade','','','N','N','','N','','','','','',''),
t_tab('w_window','','','N','N','','N','','','','','',''),
t_tab('w_xmldw','','','N','N','','N','','','','','',''),
t_tab('w_about','','','N','N','','N','','','','','',''),
t_tab('w_about_details','','','N','N','','N','','','','','',''),
t_tab('w_au_flow','','','N','N','','N','','','','','',''),
t_tab('w_bind_variables','','','N','N','','N','','','','','',''),
t_tab('w_border_window','','','N','N','','N','','','','','',''),
t_tab('w_browse_archive','','','N','N','','N','','','','','',''),
t_tab('w_browser_child','','','N','N','','N','','','','','',''),
t_tab('w_browser_palette','','','N','N','','N','','','','','',''),
t_tab('w_bv_wizard_add_filter','','','N','N','','N','','','','','',''),
t_tab('w_change_any_password','','','N','N','','N','','','','','',''),
t_tab('w_change_idm_pwd','','','N','N','','N','','','','','',''),
t_tab('w_change_password','','','N','N','','N','','','','','',''),
t_tab('w_check_errors_detail','','','N','N','','N','','','','','',''),
t_tab('w_col_settings','','','N','N','','N','','','','','',''),
t_tab('w_com_message_from','','','N','N','','N','','','','','',''),
t_tab('w_compare_more_runs','','','N','N','','N','','','','','',''),
t_tab('w_compare_runs','','','N','N','','N','','','','','',''),
t_tab('w_config_cube_export','','','N','N','','N','','','','','',''),
t_tab('w_config_dw_export','','','N','N','','N','','','','','',''),
t_tab('w_config_dw_export_custom','','','N','N','','N','','','','','',''),
t_tab('w_config_dw_update','','','N','N','','N','','','','','',''),
t_tab('w_context_backup','','','N','N','','N','','','','','',''),
t_tab('w_context_connected_users','','','N','N','','N','','','','','',''),
t_tab('w_context_copy','','','N','N','','N','','','','','',''),
t_tab('w_context_create','','','N','N','','N','','','','','',''),
t_tab('w_context_restore','','','N','N','','N','','','','','',''),
t_tab('w_context_tools','','','N','N','','N','','','','','',''),
t_tab('w_context_truncate','','','N','N','','N','','','','','',''),
t_tab('w_copy_dependencies','','','N','N','','N','','','','','',''),
t_tab('w_correct_import_gen_list_page','','','N','N','','N','','','','','',''),
t_tab('w_correct_import_grid','','','N','N','','N','','','','','',''),
t_tab('w_correct_import_list_page','','','N','N','','N','','','','','',''),
t_tab('w_correct_import_table','','','N','N','','N','','','','','',''),
t_tab('w_create_awr','','','N','N','','N','','','','','',''),
t_tab('w_create_scq','','','N','N','','N','','','','','',''),
t_tab('w_create_user','','','N','N','','N','','','','','',''),
t_tab('w_cube_definition','','','N','N','','N','','','','','',''),
t_tab('w_custom_cube','','','N','N','','N','','','','','',''),
t_tab('w_custom_win_builder','','','N','N','','N','','','','','',''),
t_tab('w_data_security','','','N','N','','N','','','','','',''),
t_tab('w_db_files_cube','','','N','N','','N','','','','','',''),
t_tab('w_db_files_father','','','N','N','','N','','','','','',''),
t_tab('w_ddms','','','N','N','','N','','','','','',''),
t_tab('w_depend_audit_trail_row','','','N','N','','N','','','','','',''),
t_tab('w_depend_audit_trail_row_new','','','N','N','','N','','','','','',''),
t_tab('w_depend_block_coop_simu','','','N','N','','N','','','','','',''),
t_tab('w_depend_context_selection','','','N','N','','N','','','','','',''),
t_tab('w_depend_cube_detail','','','N','N','','N','','','','','',''),
t_tab('w_depend_db_files_table','','','N','N','','N','','','','','',''),
t_tab('w_depend_rt_hist_columns','','','N','N','','N','','','','','',''),
t_tab('w_depend_rt_hist_keys','','','N','N','','N','','','','','',''),
t_tab('w_depend_rt_output','','','N','N','','N','','','','','',''),
t_tab('w_depend_rt_reply','','','N','N','','N','','','','','',''),
t_tab('w_depend_rt_xml_in','','','N','N','','N','','','','','',''),
t_tab('w_depend_rt_xml_out','','','N','N','','N','','','','','',''),
t_tab('w_depend_user_roles','','','N','N','','N','','','','','',''),
t_tab('w_disclaimer','','','N','N','','N','','','','','',''),
t_tab('w_display_archive_table','','','N','N','','N','','','','','',''),
t_tab('w_display_coop_simu','','','N','N','','N','','','','','',''),
t_tab('w_display_db_error','','','N','N','','N','','','','','',''),
t_tab('w_display_graph_run','','','N','N','','N','','','','','',''),
t_tab('w_display_select','','','N','N','','N','','','','','',''),
t_tab('w_display_table_access','','','N','N','','N','','','','','',''),
t_tab('w_dw_builder','','','N','N','','N','','','','','',''),
t_tab('w_dw_design','','','N','N','','N','','','','','',''),
t_tab('w_dw_infos','','','N','N','','N','','','','','',''),
t_tab('w_dw_print','','','N','N','','N','','','','','',''),
t_tab('w_dw_sort','','','N','N','','N','','','','','',''),
t_tab('w_edit_column_child','','','N','N','','N','','','','','',''),
t_tab('w_edit_father_new','','','N','N','','N','','','','','',''),
t_tab('w_edit_father_new_child','','','N','N','','N','','','','','',''),
t_tab('w_edit_father_new_response','','','N','N','','N','','','','','',''),
t_tab('w_edit_line_father','','','N','N','','N','','','','','',''),
t_tab('w_edit_line_father_virtual','','','N','N','','N','','','','','',''),
t_tab('w_edit_line_father_virtual_child','','','N','N','','N','','','','','',''),
t_tab('w_edit_line_father_virtual_popup','','','N','N','','N','','','','','',''),
t_tab('w_edit_migration_bind_vars','','','N','N','','N','','','','','',''),
t_tab('w_edit_sql','','','N','N','','N','','','','','',''),
t_tab('w_edit_table','','','N','N','','N','','','','','',''),
t_tab('w_edit_tree_explore_father','','','N','N','','N','','','','','',''),
t_tab('w_editor_color','','','N','N','','N','','','','','',''),
t_tab('w_editor_find','','','N','N','','N','','','','','',''),
t_tab('w_editor_goto','','','N','N','','N','','','','','',''),
t_tab('w_editor_replace','','','N','N','','N','','','','','',''),
t_tab('w_editor_tabwidth','','','N','N','','N','','','','','',''),
t_tab('w_evaluate','','','N','N','','N','','','','','',''),
t_tab('w_explore_father','','','N','N','','N','','','','','',''),
t_tab('w_explore_father_child','','','N','N','','N','','','','','',''),
t_tab('w_explore_father_popup','','','N','N','','N','','','','','',''),
t_tab('w_explore_kpi_dependency','','','N','N','','N','','','','','',''),
t_tab('w_explore_phase','','','N','N','','N','','','','','',''),
t_tab('w_ez_custo','','','N','N','','N','','','','','',''),
t_tab('w_fermat_pb_util','','','N','N','','N','','','','','',''),
t_tab('w_filtered_tasks','','','N','N','','N','','','','','',''),
t_tab('w_for_pb_task','','','N','N','','N','','','','','',''),
t_tab('w_gem_navigator_options','','','N','N','','N','','','','','',''),
t_tab('w_get_db_file','','','N','N','','N','','','','','',''),
t_tab('w_get_file_db_file','','','N','N','','N','','','','','',''),
t_tab('w_graph','','','N','N','','N','','','','','',''),
t_tab('w_graph_child','','','N','N','','N','','','','','',''),
t_tab('w_graph_definition','','','N','N','','N','','','','','',''),
t_tab('w_help_dmm_column_child','','','N','N','','N','','','','','',''),
t_tab('w_idm','','','N','N','','N','','','','','',''),
t_tab('w_input_box','','','N','N','','N','','','','','',''),
t_tab('w_input_box_resizable','','','N','N','','N','','','','','',''),
t_tab('w_load_dump_db_files','','','N','N','','N','','','','','',''),
t_tab('w_login','','','N','N','','N','','','','','',''),
t_tab('w_main','','','N','N','','N','','','','','',''),
t_tab('w_multi_report_father','','','N','N','','N','','','','','',''),
t_tab('w_open_dw','','','N','N','','N','','','','','',''),
t_tab('w_other_sessions','','','N','N','','N','','','','','',''),
t_tab('w_output_debug','','','N','N','','N','','','','','',''),
t_tab('w_register_license','','','N','N','','N','','','','','',''),
t_tab('w_run_files','','','N','N','','N','','','','','',''),
t_tab('w_save_browser','','','N','N','','N','','','','','',''),
t_tab('w_schedule_parameter','','','N','N','','N','','','','','',''),
t_tab('w_search_query_new','','','N','N','','N','','','','','',''),
t_tab('w_search_tree','','','N','N','','N','','','','','',''),
t_tab('w_select_tables','','','N','N','','N','','','','','',''),
t_tab('w_server_launch_task','','','N','N','','N','','','','','',''),
t_tab('w_sparse_group_def','','','N','N','','N','','','','','',''),
t_tab('w_table_columns_audit','','','N','N','','N','','','','','',''),
t_tab('w_task_parameter','','','N','N','','N','','','','','',''),
t_tab('w_test_block_params','','','N','N','','N','','','','','',''),
t_tab('w_test_new_ancestor','','','N','N','','N','','','','','',''),
t_tab('w_tm_flag_as_known_bug','','','N','N','','N','','','','','',''),
t_tab('w_tm_launch','','','N','N','','N','','','','','',''),
t_tab('w_transparent','','','N','N','','N','','','','','',''),
t_tab('w_wait_main','','','N','N','','N','','','','','',''),
t_tab('w_wait_task','','','N','N','','N','','','','','',''),
t_tab('w_waiter_timer','','','N','N','','N','','','','','',''),
t_tab('w_web_window','','','N','N','','N','','','','','',''),
t_tab('w_welcome','','','N','N','','N','','','','','',''),
t_tab('w_win_infos','','','N','N','','N','','','','','',''),
t_tab('w_window_father','','','N','N','','N','','','','','',''),
t_tab('w_window_finder','','','N','N','','N','','','','','',''),
t_tab('w_window_super_father','','','N','N','','N','','','','','',''),
t_tab('w_wizard_father_virtual','','','N','N','','N','','','','','',''),
t_tab('w_wizard_frt_build_bizdim','','','N','N','','N','','','','','',''),
t_tab('w_wizard_frt_new_dimension','','','N','N','','N','','','','','',''),
t_tab('w_wizard_frt_report_table_adddim','','','N','N','','N','','','','','',''),
t_tab('w_wizard_frt_report_table_addhistdim','','','N','N','','N','','','','','',''),
t_tab('w_wizard_frt_report_table_addprop','','','N','N','','N','','','','','',''),
t_tab('w_wizard_select_coop_simu','','','N','N','','N','','','','','',''),
t_tab('w_wizard_select_graph_run','','','N','N','','N','','','','','',''),
t_tab('w_allocation_range','','','N','N','','N','','','','','',''),
t_tab('w_edit_bale2_param','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_parameter','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_sub_perimeter','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_ccf','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_ccf_backtest_run','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_crm_mv','','','N','N','','N','','','','','',''),
t_tab('w_explore_bis_crm_custom','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_crm','','','N','N','','N','','','','','',''),
t_tab('w_explore_cva_supervisor','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_val_chk_param','','','N','N','','N','','','','','',''),
t_tab('w_edit_credit_event','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_ce_backtest_run','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_default_file','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_crm','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_entity_links','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_real_estate','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_entity','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_exposure','','','N','N','','N','','','','','',''),
t_tab('w_retail_handling','','','N','N','','N','','','','','',''),
t_tab('w_explore_ldb','','','N','N','','N','','','','','',''),
t_tab('w_explore_bis_simul_strategy','','','N','N','','N','','','','','',''),
t_tab('w_edit_impairment_param','','','N','N','','N','','','','','',''),
t_tab('w_impairment_parameters','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_le_process','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_lgd','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_lgd_backtest_run','','','N','N','','N','','','','','',''),
t_tab('w_explore_bis_le_supervisor','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_operational_risk_mapping','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_pd','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_operational_risk_parameters','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_parameters','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_retail','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_pre_aggreg_set','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_re_mv','','','N','N','','N','','','','','',''),
t_tab('w_edit_ldb_event','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_val_chk_results','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_dim','','','N','N','','N','','','','','',''),
t_tab('w_edit_retail_exposure','','','N','N','','N','','','','','',''),
t_tab('w_edit_scoring','','','N','N','','N','','','','','',''),
t_tab('w_retail_segmentation','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_strategy','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_simul_ratings','','','N','N','','N','','','','','',''),
t_tab('w_explore_supervisor','','','N','N','','N','','','','','',''),
t_tab('w_depend_bis_dd_guar_rating','','','N','N','','N','','','','','',''),
t_tab('w_depend_display_ldb_contract_crm','','','N','N','','N','','','','','',''),
t_tab('w_depend_display_ldb_contract_real_estate','','','N','N','','N','','','','','',''),
t_tab('w_depend_ldb_contract_crm','','','N','N','','N','','','','','',''),
t_tab('w_depend_ldb_facility_counterparty','','','N','N','','N','','','','','',''),
t_tab('w_depend_ldb_facility_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_ldb_indicator','','','N','N','','N','','','','','',''),
t_tab('w_depend_ldb_mortgage_re_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_ldb_recovery_flow','','','N','N','','N','','','','','',''),
t_tab('w_depend_retail_booked_amounts','','','N','N','','N','','','','','',''),
t_tab('w_depend_retail_provision','','','N','N','','N','','','','','',''),
t_tab('w_depend_securitization_sr','','','N','N','','N','','','','','',''),
t_tab('w_depend_tranche_sr','','','N','N','','N','','','','','',''),
t_tab('w_depend_underlying_pool_sr','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_audit_parameters','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_crm_col_case','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_crm_col_function','','','N','N','','N','','','','','',''),
t_tab('w_edit_bis_val_chk_res_details','','','N','N','','N','','','','','',''),
t_tab('w_edit_disc_items','','','N','N','','N','','','','','',''),
t_tab('w_edit_disc_mapping','','','N','N','','N','','','','','',''),
t_tab('w_edit_disclosure_own_fund','','','N','N','','N','','','','','',''),
t_tab('w_explore_bis_admin','','','N','N','','N','','','','','',''),
t_tab('w_launch_workflow','','','N','N','','N','','','','','',''),
t_tab('w_modal_create_default_file','','','N','N','','N','','','','','',''),
t_tab('w_wizard_fill_ce_default_file','','','N','N','','N','','','','','',''),
t_tab('w_wizard_fill_credit_event','','','N','N','','N','','','','','',''),
t_tab('w_wizard_sa_set_de_link','','','N','N','','N','','','','','',''),
t_tab('w_wizard_sa_set_link','','','N','N','','N','','','','','',''),
t_tab('w_edit_nbi_accounts','','','N','N','','N','','','','','',''),
t_tab('w_edit_audit_perimeter','','','N','N','','N','','','','','',''),
t_tab('w_edit_nbi_reconciliation','','','N','N','','N','','','','','',''),
t_tab('w_fce_param','','','N','N','','N','','','','','',''),
t_tab('w_bis_param','','','N','N','','N','','','','','',''),
t_tab('w_explore_account_chart','','','N','N','','N','','','','','',''),
t_tab('w_explore_client_options','','','N','N','','N','','','','','',''),
t_tab('w_fct_audit_columns','','','N','N','','N','','','','','',''),
t_tab('w_explore_commission_process','','','N','N','','N','','','','','',''),
t_tab('w_explore_commission_def','','','N','N','','N','','','','','',''),
t_tab('w_edit_coop_simu','','','N','N','','N','','','','','',''),
t_tab('w_edit_spread_curve','','','N','N','','N','','','','','',''),
t_tab('w_explore_explode','','','N','N','','N','','','','','',''),
t_tab('w_edit_fx','','','N','N','','N','','','','','',''),
t_tab('w_edit_rate_family_accrual_basis_conversion','','','N','N','','N','','','','','',''),
t_tab('w_edit_indicator_calculation','','','N','N','','N','','','','','',''),
t_tab('w_explore_key_analysis','','','N','N','','N','','','','','',''),
t_tab('w_manual_operation_set','','','N','N','','N','','','','','',''),
t_tab('w_explore_gds_param','','','N','N','','N','','','','','',''),
t_tab('w_explore_financial_data','','','N','N','','N','','','','','',''),
t_tab('w_edit_nbi_operation_valuation','','','N','N','','N','','','','','',''),
t_tab('w_explore_pel','','','N','N','','N','','','','','',''),
t_tab('w_edit_past_volatility','','','N','N','','N','','','','','',''),
t_tab('w_edit_curve_shift','','','N','N','','N','','','','','',''),
t_tab('w_edit_nbi_reconciliation_param','','','N','N','','N','','','','','',''),
t_tab('w_edit_gl_reconciliation','','','N','N','','N','','','','','',''),
t_tab('w_reconciliation_pre_calcul','','','N','N','','N','','','','','',''),
t_tab('w_edit_releasing','','','N','N','','N','','','','','',''),
t_tab('w_edit_vol_corr','','','N','N','','N','','','','','',''),
t_tab('w_edit_stats_run_instrument','','','N','N','','N','','','','','',''),
t_tab('w_edit_season_effect','','','N','N','','N','','','','','',''),
t_tab('w_edit_MR_Strategies','','','N','N','','N','','','','','',''),
t_tab('w_edit_scenario','','','N','N','','N','','','','','',''),
t_tab('w_time_horizon','','','N','N','','N','','','','','',''),
t_tab('w_edit_flow','','','N','N','','N','','','','','',''),
t_tab('w_explore_mc_simulations','','','N','N','','N','','','','','',''),
t_tab('w_edit_config_param_ve','','','N','N','','N','','','','','',''),
t_tab('w_explore_alm_var_simulations','','','N','N','','N','','','','','',''),
t_tab('w_edit_vol_shift','','','N','N','','N','','','','','',''),
t_tab('w_depend_risk_sensitivity_import','','','N','N','','N','','','','','',''),
t_tab('w_depend_smile','','','N','N','','N','','','','','',''),
t_tab('w_edit_config_param_epe','','','N','N','','N','','','','','',''),
t_tab('w_edit_credit_spread','','','N','N','','N','','','','','',''),
t_tab('w_edit_external_pricer','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_dg_cube_result','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_dg_result','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_hist_param','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_histo_result','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_mc_back_test','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_mc_cube_result','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_mc_repartition','','','N','N','','N','','','','','',''),
t_tab('w_edit_var_mc_result','','','N','N','','N','','','','','',''),
t_tab('w_explore_commission','','','N','N','','N','','','','','',''),
t_tab('w_forward_rate_ask','','','N','N','','N','','','','','',''),
t_tab('w_forward_rate_sim_ask','','','N','N','','N','','','','','',''),
t_tab('w_show_alm_subset','','','N','N','','N','','','','','',''),
t_tab('w_show_k_parameters_formulas','','','N','N','','N','','','','','',''),
t_tab('w_edit_other_contracts','','','N','N','','N','','','','','',''),
t_tab('w_edit_aggregated_contracts','','','N','N','','N','','','','','',''),
t_tab('w_explore_aggregate','','','N','N','','N','','','','','',''),
t_tab('w_explore_common_supervisor','','','N','N','','N','','','','','',''),
t_tab('w_gl_display_bs','','','N','N','','N','','','','','',''),
t_tab('w_edit_date_rules','','','N','N','','N','','','','','',''),
t_tab('w_edit_commodity','','','N','N','','N','','','','','',''),
t_tab('w_companies_links','','','N','N','','N','','','','','',''),
t_tab('w_explore_recon_config','','','N','N','','N','','','','','',''),
t_tab('w_edit_contract_types_links','','','N','N','','N','','','','','',''),
t_tab('w_edit_correlation','','','N','N','','N','','','','','',''),
t_tab('w_edit_other_imports','','','N','N','','N','','','','','',''),
t_tab('w_edit_crm_contracts','','','N','N','','N','','','','','',''),
t_tab('w_edit_currency','','','N','N','','N','','','','','',''),
t_tab('w_explore_cursor_extension','','','N','N','','N','','','','','',''),
t_tab('w_edit_curve_def','','','N','N','','N','','','','','',''),
t_tab('w_edit_business_line_data','','','N','N','','N','','','','','',''),
t_tab('w_edit_deal_book_links','','','N','N','','N','','','','','',''),
t_tab('w_explore_dealbag','','','N','N','','N','','','','','',''),
t_tab('w_edit_security_contracts','','','N','N','','N','','','','','',''),
t_tab('w_edit_derivatives','','','N','N','','N','','','','','',''),
t_tab('w_edit_entity2','','','N','N','','N','','','','','',''),
t_tab('w_edit_entity_links','','','N','N','','N','','','','','',''),
t_tab('w_explore_companies','','','N','N','','N','','','','','',''),
t_tab('w_explore_dealbooks','','','N','N','','N','','','','','',''),
t_tab('w_explore_fdw_netting','','','N','N','','N','','','','','',''),
t_tab('w_fee_based_product','','','N','N','','N','','','','','',''),
t_tab('w_pel_forecast','','','N','N','','N','','','','','',''),
t_tab('w_foreign_exchange_position','','','N','N','','N','','','','','',''),
t_tab('w_explore_formula_usrparam','','','N','N','','N','','','','','',''),
t_tab('w_edit_account','','','N','N','','N','','','','','',''),
t_tab('w_gl_and_deal','','','N','N','','N','','','','','',''),
t_tab('w_edit_geographic_area_links','','','N','N','','N','','','','','',''),
t_tab('w_rate_input','','','N','N','','N','','','','','',''),
t_tab('w_edit_index_def','','','N','N','','N','','','','','',''),
t_tab('w_islamic_deal','','','N','N','','N','','','','','',''),
t_tab('w_edit_business_line_links','','','N','N','','N','','','','','',''),
t_tab('w_com_message','','','N','N','','N','','','','','',''),
t_tab('w_edit_lr_national_market','','','N','N','','N','','','','','',''),
t_tab('w_edit_numeric_bucket','','','N','N','','N','','','','','',''),
t_tab('w_edit_other_income','','','N','N','','N','','','','','',''),
t_tab('w_deal_import','','','N','N','','N','','','','','',''),
t_tab('w_pel','','','N','N','','N','','','','','',''),
t_tab('w_edit_business_line_parameters','','','N','N','','N','','','','','',''),
t_tab('w_edit_parameters_links','','','N','N','','N','','','','','',''),
t_tab('w_edit_other_parameters','','','N','N','','N','','','','','',''),
t_tab('w_explore_insurance_pool','','','N','N','','N','','','','','',''),
t_tab('w_edit_provision','','','N','N','','N','','','','','',''),
t_tab('w_purchased_receivable','','','N','N','','N','','','','','',''),
t_tab('w_query_builder','','','N','N','','N','','','','','',''),
t_tab('w_edit_family','','','N','N','','N','','','','','',''),
t_tab('w_edit_rating_parameters','','','N','N','','N','','','','','',''),
t_tab('w_edit_renewal_spread','','','N','N','','N','','','','','',''),
t_tab('w_explore_recon_result','','','N','N','','N','','','','','',''),
t_tab('w_edit_security','','','N','N','','N','','','','','',''),
t_tab('w_securitization_credit_derivative','','','N','N','','N','','','','','',''),
t_tab('w_edit_simulated_contracts','','','N','N','','N','','','','','',''),
t_tab('w_edit_time_band','','','N','N','','N','','','','','',''),
t_tab('w_edit_volatility','','','N','N','','N','','','','','',''),
t_tab('w_all_connected_users','','','N','N','','N','','','','','',''),
t_tab('w_choose_entity','','','N','N','','N','','','','','',''),
t_tab('w_choose_security','','','N','N','','N','','','','','',''),
t_tab('w_com_message_new','','','N','N','','N','','','','','',''),
t_tab('w_depend_booked_amounts','','','N','N','','N','','','','','',''),
t_tab('w_depend_caplet','','','N','N','','N','','','','','',''),
t_tab('w_depend_cash_flow_past','','','N','N','','N','','','','','',''),
t_tab('w_depend_computed_fields','','','N','N','','N','','','','','',''),
t_tab('w_depend_contract_guarantee','','','N','N','','N','','','','','',''),
t_tab('w_depend_contract_guarantying','','','N','N','','N','','','','','',''),
t_tab('w_depend_contract_position','','','N','N','','N','','','','','',''),
t_tab('w_depend_coupon_steps','','','N','N','','N','','','','','',''),
t_tab('w_depend_credit_agreement_cpty','','','N','N','','N','','','','','',''),
t_tab('w_depend_credit_agreement_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_credit_agreement_products','','','N','N','','N','','','','','',''),
t_tab('w_depend_credit_event','','','N','N','','N','','','','','',''),
t_tab('w_depend_credit_rating','','','N','N','','N','','','','','',''),
t_tab('w_depend_deliverable_assets','','','N','N','','N','','','','','',''),
t_tab('w_depend_edit_stages','','','N','N','','N','','','','','',''),
t_tab('w_depend_equity_forecast','','','N','N','','N','','','','','',''),
t_tab('w_depend_exchange_composition','','','N','N','','N','','','','','',''),
t_tab('w_depend_explore_facilities_tree','','','N','N','','N','','','','','',''),
t_tab('w_depend_external_entity_code','','','N','N','','N','','','','','',''),
t_tab('w_depend_external_security_code','','','N','N','','N','','','','','',''),
t_tab('w_depend_facility_counterparty','','','N','N','','N','','','','','',''),
t_tab('w_depend_facility_drawdown_def','','','N','N','','N','','','','','',''),
t_tab('w_depend_facility_drawdown_flow','','','N','N','','N','','','','','',''),
t_tab('w_depend_facility_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_facility_products','','','N','N','','N','','','','','',''),
t_tab('w_depend_fdw_cash_flow','','','N','N','','N','','','','','',''),
t_tab('w_depend_fdw_cash_flow_recovery','','','N','N','','N','','','','','',''),
t_tab('w_depend_fixing_period_data','','','N','N','','N','','','','','',''),
t_tab('w_depend_folder_contract','','','N','N','','N','','','','','',''),
t_tab('w_depend_fund_composition','','','N','N','','N','','','','','',''),
t_tab('w_depend_fund_computed_fields','','','N','N','','N','','','','','',''),
t_tab('w_depend_gross_income','','','N','N','','N','','','','','',''),
t_tab('w_depend_guaranted_agreements','','','N','N','','N','','','','','',''),
t_tab('w_depend_index_composition','','','N','N','','N','','','','','',''),
t_tab('w_depend_issuer_credit_rating','','','N','N','','N','','','','','',''),
t_tab('w_depend_key_analysis_detail_new','','','N','N','','N','','','','','',''),
t_tab('w_depend_mortgage_note_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_netted_entity','','','N','N','','N','','','','','',''),
t_tab('w_depend_option_exercise_date','','','N','N','','N','','','','','',''),
t_tab('w_depend_prov_contract_types','','','N','N','','N','','','','','',''),
t_tab('w_depend_provision','','','N','N','','N','','','','','',''),
t_tab('w_depend_provision_retail','','','N','N','','N','','','','','',''),
t_tab('w_depend_provisioned_contracts','','','N','N','','N','','','','','',''),
t_tab('w_depend_range_accrual_steps','','','N','N','','N','','','','','',''),
t_tab('w_depend_real_estate_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_reference_list','','','N','N','','N','','','','','',''),
t_tab('w_depend_repo_portfolio','','','N','N','','N','','','','','',''),
t_tab('w_depend_secu_cies_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_security_multiple_guarantors','','','N','N','','N','','','','','',''),
t_tab('w_depend_tranche_links','','','N','N','','N','','','','','',''),
t_tab('w_depend_und_pool_link','','','N','N','','N','','','','','',''),
t_tab('w_depend_underlying_asset','','','N','N','','N','','','','','',''),
t_tab('w_depend_underlying_receivables','','','N','N','','N','','','','','',''),
t_tab('w_display_contract','','','N','N','','N','','','','','',''),
t_tab('w_edit_dw_arguments','','','N','N','','N','','','','','',''),
t_tab('w_edit_log_query','','','N','N','','N','','','','','',''),
t_tab('w_entity_group','','','N','N','','N','','','','','',''),
t_tab('w_explore_entity','','','N','N','','N','','','','','',''),
t_tab('w_explore_security','','','N','N','','N','','','','','',''),
t_tab('w_fct_tree_view','','','N','N','','N','','','','','',''),
t_tab('w_filter_clause_for_cmp','','','N','N','','N','','','','','',''),
t_tab('w_launch_blocks','','','N','N','','N','','','','','',''),
t_tab('w_link_table','','','N','N','','N','','','','','',''),
t_tab('w_only_columns_for_cmp_area','','','N','N','','N','','','','','',''),
t_tab('w_report_from_sql','','','N','N','','N','','','','','',''),
t_tab('w_report_window','','','N','N','','N','','','','','',''),
t_tab('w_select_link_table','','','','','','','','','','','',''),
t_tab('w_show_all_check_errors','','','','','','','','','','','',''),
t_tab('w_show_backup_data','','','','','','','','','','','',''),
t_tab('w_test_management_father','','','','','','','','','','','',''),
t_tab('w_wizard_recon_status','','','','','','','','','','','',''),
t_tab('w_explore_additional_infos','','','','','','','','','','','',''),
t_tab('w_edit_reporting_own_fund','','','','','','','','','','','',''),
t_tab('w_explore_rep_reports_sets','','','','','','','','','','','',''),
t_tab('w_explore_audit_set','','','','','','','','','','','',''),
t_tab('w_explore_audit_track_templates','','','','','','','','','','','',''),
t_tab('w_explore_adjustment_and_audit','','','','','','','','','','','',''),
t_tab('w_explore_rep_cpy_set','','','','','','','','','','','',''),
t_tab('w_explore_rep_context_set','','','','','','','','','','','',''),
t_tab('w_explore_rep_agg_param_custom','','','','','','','','','','','',''),
t_tab('w_explore_rep_envelope','','','','','','','','','','','',''),
t_tab('w_edit_rep_extend_input_tables','','','','','','','','','','','',''),
t_tab('w_explore_rep_agg_param','','','','','','','','','','','',''),
t_tab('w_explore_rep_reporting_process','','','','','','','','','','','',''),
t_tab('w_db_rep_files','','','','','','','','','','','',''),
t_tab('w_explore_rep_gen_fields_def','','','','','','','','','','','',''),
t_tab('w_explore_rep_global_variable','','','','','','','','','','','',''),
t_tab('w_explore_imported_reports','','','','','','','','','','','',''),
t_tab('w_import','','','','','','','','','','','',''),
t_tab('w_explore_regulatory_data','','','','','','','','','','','',''),
t_tab('w_explore_rep_fct_mapping_custo','','','','','','','','','','','',''),
t_tab('w_explore_rep_tech_mapping_custo','','','','','','','','','','','',''),
t_tab('w_explore_rep_tech_mapping_fermat','','','','','','','','','','','',''),
t_tab('w_explore_audit_rpt_result','','','','','','','','','','','',''),
t_tab('w_explore_rep_variance_results','','','','','','','','','','','',''),
t_tab('w_edit_reporting_param','','','','','','','','','','','',''),
t_tab('w_explore_rep_loading_process','','','','','','','','','','','',''),
t_tab('w_explore_rep_env_set','','','','','','','','','','','',''),
t_tab('w_edit_rep_simple_input_tables','','','','','','','','','','','',''),
t_tab('w_explore_sub_perimeter','','','','','','','','','','','',''),
t_tab('w_edit_bus_rule_param','','','','','','','','','','','',''),
t_tab('w_edit_bus_rule_results','','','','','','','','','','','',''),
t_tab('w_explore_rep_env_param','','','','','','','','','','','',''),
t_tab('w_audit_import_results','','','','','','','','','','','',''),
t_tab('w_build_excel_rule','','','','','','','','','','','',''),
t_tab('w_build_expression','','','','','','','','','','','',''),
t_tab('w_build_rule','','','','','','','','','','','',''),
t_tab('w_choose_aggregate_functional_dimension','','','','','','','','','','','',''),
t_tab('w_choose_aggregation_set','','','','','','','','','','','',''),
t_tab('w_choose_functional_dimension','','','','','','','','','','','',''),
t_tab('w_cube_audit_reporting','','','','','','','','','','','',''),
t_tab('w_cube_audit_step2_reporting','','','','','','','','','','','',''),
t_tab('w_depend_audit_cube_display','','','','','','','','','','','',''),
t_tab('w_depend_display_query','','','','','','','','','','','',''),
t_tab('w_depend_rep_dimension_formula','','','','','','','','','','','',''),
t_tab('w_depend_rep_fact_formula','','','','','','','','','','','',''),
t_tab('w_depend_rep_full_xbrl_dim','','','','','','','','','','','',''),
t_tab('w_depend_rep_rpt_audit','','','','','','','','','','','',''),
t_tab('w_depend_rep_rpt_audit_import','','','','','','','','','','','',''),
t_tab('w_depend_rep_xbrl_dim','','','','','','','','','','','',''),
t_tab('w_depend_rule','','','','','','','','','','','',''),
t_tab('w_edit_bus_rule_res_details','','','','','','','','','','','',''),
t_tab('w_edit_generated_reports','','','','','','','','','','','',''),
t_tab('w_explore_audit_check_definition','','','','','','','','','','','',''),
t_tab('w_explore_audit_check_results','','','','','','','','','','','',''),
t_tab('w_explore_audit_set_result','','','','','','','','','','','',''),
t_tab('w_explore_envelope','','','','','','','','','','','',''),
t_tab('w_explore_import_results','','','','','','','','','','','',''),
t_tab('w_explore_rep_loading_process_query','','','','','','','','','','','',''),
t_tab('w_explore_reporting','','','','','','','','','','','',''),
t_tab('w_simple_import','','','','','','','','','','','',''),
t_tab('w_explore_sae_access','','','','','','','','','','','',''),
t_tab('w_explore_sae','','','','','','','','','','','','')
   );
 --AUTO:End.  System tag, do not modify this line			

--################################### DO NOT MODIFY ANYTHING BELOW THIS LINE ###################################
begin
  dbms_output.enable(100000);
  pack_context.contextid_open(1);  
  
  pack_log.log_begin('UAM: APPLY WINDOW ACCESS',null,null,'Apply Window UAM'); 
  
  v_group_ids.extend(v_user_group.count);
  
  dbms_output.put_line('Setting WINDOW access matrix...');
  dbms_output.put_line('Check USER GROUP existence...');
  
  pack_log.log_write('I','T',l_proc,l_step,'Setting WINDOW access matrix...',null);
  
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
  delete from priv p where exists (select 1 from priv_win pp where pp.priv_id=p.priv_id);
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
    insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name) 
		values ( seq_priv.nextval, 0, 0, 'N', 99, 'win', v_object_name);
 	 
    dbms_output.put_line('----Object ID:'||v_object_name||' access:N priority:99');
    pack_log.log_write('I','T',l_proc,l_step,'----Object ID:'||v_object_name||' access:N priority:99',null);
   
    -- loop the user group access
    FOR j in v_access.first .. v_access.last-1 LOOP
      v_access_type := v_access(1+j);
      v_group_id := v_group_ids(j);

      -- grant the access 
      IF  v_access_type = 'Y' THEN
      l_step:='022';
        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name) 
					values ( seq_priv.nextval, v_group_id, 0, 'Y', 10, 'win', v_object_name);
        
        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10');
        pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:Y priority:10',null);
      ELSIF  v_access_type = 'RO' THEN
        l_step:='023';
        insert into v_grantee_priv_all (priv_id, grantee_id, distance, grant_access, priority, priv_type, window_name) 
					values ( seq_priv.nextval, v_group_id, 0, 'R', 20, 'win', v_object_name);
        
        dbms_output.put_line('------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:R priority:20');
				pack_log.log_write('I','T',l_proc,l_step,'------v_object_name:'||v_object_name||' v_group_id:'||v_group_id||' access:R priority:20',null);

      END IF;
    END LOOP;
  END LOOP;
  commit;
  
  l_step:='030';
  -- update the statistics
  dbms_output.put_line('Gather table statistics....');
  pack_stats.gather_table_stats('PRIV');
  pack_stats.gather_table_stats('GRANTEE_PRIV');
  pack_stats.gather_table_stats('PRIV_WIN');


  pack_stats.gather_table_stats ('GRANTEE_MEMBER');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('CD_USERS');
  pack_stats.gather_table_stats ('GRANTEES');
  pack_stats.gather_table_stats ('PRIV_ROLE_PRIV');
  pack_stats.gather_table_stats ('PRIV_ROLE');
  pack_stats.gather_table_stats ('PRIV_DW');
  pack_stats.gather_table_stats ('PRIV_NODE');
  pack_stats.gather_table_stats ('PRIV_MENU');
  pack_stats.gather_table_stats ('PRIV_BROWSER');
  pack_stats.gather_table_stats ('PRIV_PROCESS');
  pack_stats.gather_table_stats ('PRIV_ACTION');
  pack_stats.gather_table_stats ('PRIV_COMPANY');
  pack_stats.gather_table_stats ('PRIV_CONTEXT');
  pack_stats.gather_table_stats ('PRIV_TABLE');
  pack_stats.gather_table_stats ('PRIV_TABLE_COLUMN');
  pack_stats.gather_table_stats ('PRIV_OTHER_APP');
  
  dbms_output.put_line('Setting WINDOW access matrix... done.');
  pack_log.log_write('I','T',l_proc,l_step,'Setting WINDOW access matrix... done.',null);
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
