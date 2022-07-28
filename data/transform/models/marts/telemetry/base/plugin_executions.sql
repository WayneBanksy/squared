SELECT
    unstruct_plugin_executions.unstruct_plugin_exec_pk AS plugin_exec_pk,
    unstruct_plugin_executions.execution_id,
    unstruct_plugin_executions.plugin_started,
    unstruct_plugin_executions.plugin_ended,
    unstruct_plugin_executions.plugin_runtime_ms,
    unstruct_plugin_executions.completion_status,
    1 AS event_count,
    'unstructured' AS event_type,
    unstruct_plugin_executions.cli_command,
    unstruct_plugins.plugin_name,
    unstruct_plugins.parent_name,
    unstruct_plugins.executable,
    unstruct_plugins.namespace,
    unstruct_plugins.pip_url,
    unstruct_plugins.variant_name AS plugin_variant,
    unstruct_plugins.command AS plugin_command,
    unstruct_plugins.plugin_type,
    unstruct_plugins.plugin_category,
    unstruct_plugins.plugin_surrogate_key
FROM {{ ref('unstruct_plugin_executions') }}
LEFT JOIN {{ ref('unstruct_plugins') }}
    ON unstruct_plugin_executions.plugin_surrogate_key = unstruct_plugins.plugin_surrogate_key

UNION ALL

SELECT
    struct_plugin_executions.struct_plugin_exec_pk AS plugin_exec_pk,
    struct_plugin_executions.execution_id,
    NULL AS plugin_started,
    NULL AS plugin_ended,
    NULL AS plugin_runtime_ms,
    'SUCCESS_STRUCT' AS completion_status,
    struct_plugin_executions.event_count,
    'structured' AS event_type,
    struct_plugin_executions.command,
    struct_plugin_executions.plugin_name,
    struct_plugin_executions.parent_name,
    struct_plugin_executions.executable,
    struct_plugin_executions.namespace,
    struct_plugin_executions.pip_url,
    struct_plugin_executions.plugin_variant,
    struct_plugin_executions.plugin_command,
    struct_plugin_executions.plugin_type,
    struct_plugin_executions.plugin_category,
    NULL AS plugin_surrogate_key
FROM {{ ref('struct_plugin_executions') }}
