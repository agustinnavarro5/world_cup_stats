{{ config(materialized='table') }}

WITH world_cup_results AS ( 

    SELECT
        *
        , ROW_NUMBER() OVER (
            PARTITION BY uuid
            ORDER BY (SELECT NULL)
        )                                                                           AS row_number
    FROM {{ ref('historical_world_cup_results') }}
),

deduped_data AS (

    SELECT
        *,
        CASE 
            WHEN SPLIT_PART(event_date, '-', 3)::INT <= ( (EXTRACT(YEAR FROM CURRENT_DATE))::INT % 100 )::INT THEN 
                TO_TIMESTAMP(
                    CONCAT(
                        '20',
                        SPLIT_PART(event_date, '-', 3), '-', 
                        TO_CHAR(TO_DATE(SPLIT_PART(event_date, '-', 2), 'Mon'), 'MM'), '-', 
                        SPLIT_PART(event_date, '-', 1), ' ', 
                        TRIM(event_time)
                    ),
                    'YYYY-MM-DD HH24:MI'
                )
            ELSE 
                TO_TIMESTAMP(
                    CONCAT(
                        '19',
                        SPLIT_PART(event_date, '-', 3), '-', 
                        TO_CHAR(TO_DATE(SPLIT_PART(event_date, '-', 2), 'Mon'), 'MM'), '-', 
                        SPLIT_PART(event_date, '-', 1), ' ', 
                        TRIM(event_time)
                    ),
                    'YYYY-MM-DD HH24:MI'
                )
        END                                                                         AS event_datetime,
        CASE
            WHEN observation LIKE '%penalties%'
            THEN TRUE
            ELSE FALSE
        END                                                                         AS penalty_definition,
        CASE
            WHEN round LIKE '%Final%' THEN 5
            WHEN round LIKE '%Semi%' OR round LIKE '%Third%' THEN 4
            WHEN round LIKE '%Quarter%' THEN 3
            WHEN round LIKE '%16%' THEN 2
            ELSE 1
        END                                                                         AS round_number,
        CASE
            WHEN observation LIKE '%penalties%'
                THEN SPLIT_PART(
                        SUBSTRING(observation FROM '\((.*?)\)') 
                        , '-', 1
                    )::INT
            ELSE NULL
        END                                                                         AS home_goals_in_penalties,
        CASE
            WHEN observation LIKE '%penalties%'
                THEN SPLIT_PART(
                        SUBSTRING(observation FROM '\((.*?)\)') 
                        , '-', 2
                    )::INT
            ELSE NULL
        END                                                                         AS away_goals_in_penalties
    
    FROM world_cup_results
    WHERE row_number = 1
),

final AS (

    SELECT
        -- Key
        uuid,

        -- Attributes
        event_year,
        event_date,
        event_time,
        event_datetime,
        round,
        round_number,
        stadium,
        city,
        country,
        home_team,
        away_team,
        observation,

        -- Flags
        penalty_definition,

        -- Measures
        home_goals,
        home_goals_in_penalties,
        away_goals,
        away_goals_in_penalties

    FROM deduped_data

)

SELECT * FROM final
