WITH retention AS (
    SELECT
        project_id,
        MIN(event_created_at) AS first_event_date,
        MAX(event_created_at) AS last_event_date,
        COALESCE(SUM(
            event_count
        ) = 1 AND MAX(command_category) = 'meltano init',
        FALSE) AS tracking_disabled
    FROM {{ ref('structured_executions') }}
    GROUP BY project_id
)

SELECT
    structured_executions.event_created_date AS event_date,
    structured_executions.event_created_at,
    structured_executions.command_category,
    structured_executions.command,
    structured_executions.project_id,
    retention.tracking_disabled AS is_tracking_disabled,
    structured_executions.event_count,
    event_commands_parsed.is_exec_event,
    event_commands_parsed.is_pipeline_exec_event,
    event_commands_parsed.is_legacy_event,
    -- Plugins
    event_commands_parsed.is_plugin_dbt,
    event_commands_parsed.is_plugin_singer,
    event_commands_parsed.is_plugin_airflow,
    event_commands_parsed.is_plugin_dagster,
    event_commands_parsed.is_plugin_lightdash,
    event_commands_parsed.is_plugin_superset,
    event_commands_parsed.is_plugin_sqlfluff,
    event_commands_parsed.is_plugin_great_ex,
    -- OS Features
    event_commands_parsed.is_os_feature_environments,
    event_commands_parsed.is_os_feature_mappers,
    event_commands_parsed.is_os_feature_test,
    event_commands_parsed.is_os_feature_run,
    COALESCE(NOT(event_commands_parsed.is_plugin_dbt
        OR event_commands_parsed.is_plugin_singer
        OR event_commands_parsed.is_plugin_airflow
        OR event_commands_parsed.is_plugin_dagster
        OR event_commands_parsed.is_plugin_lightdash
        OR event_commands_parsed.is_plugin_superset
        OR event_commands_parsed.is_plugin_sqlfluff
        OR event_commands_parsed.is_plugin_great_ex
    ), FALSE) AS is_plugin_other,
    COALESCE(retention.first_event_date = structured_executions.event_created_at,
        FALSE) AS is_acquired_date,
    COALESCE(retention.last_event_date = structured_executions.event_created_at,
        FALSE) AS is_churned_date,
    COALESCE(structured_executions.event_created_at >= DATEADD(MONTH, 1, DATE_TRUNC(
        'MONTH', retention.first_event_date
            )) AND structured_executions.event_created_at < DATE_TRUNC(
            'MONTH', retention.last_event_date
    ),
    FALSE) AS is_retained_date
FROM {{ ref('structured_executions') }}
LEFT JOIN {{ ref('event_commands_parsed') }}
    ON structured_executions.command = event_commands_parsed.command
LEFT JOIN retention ON structured_executions.project_id = retention.project_id
