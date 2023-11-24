{{ config(materialized='table') }}

WITH renamed AS ( 

    SELECT
        "Year"::INT                                             AS event_year,
        "Date"::VARCHAR                                         AS event_date,
        "Time"::VARCHAR                                         AS event_time,
        "Round"::VARCHAR                                        AS round,
        "Stadium"::VARCHAR                                      AS stadium,
        "City"::VARCHAR                                         AS city,
        "Country"::VARCHAR                                      AS country,
        "HomeTeam"::VARCHAR                                     AS home_team,
        "HomeGoals"::INT                                        AS home_goals,
        "AwayGoals"::INT                                        AS away_goals,
        "AwayTeam"::VARCHAR                                     AS away_team,
        "Observation"::VARCHAR                                  AS observation

    FROM {{ source('world_cup_sources', 'world_cup_results') }}
),

final AS (

    SELECT
        -- Key
        UUID(
            {{ dbt_utils.surrogate_key(
                [
                    'event_year',
                    'event_date',
                    'event_time',
                    'round',
                    'country',
                    'home_team',
                    'away_team'
                ]
            ) }}
        )                                                       AS uuid,

        -- Attributes
        event_year,
        event_date,
        event_time,
        round,
        stadium,
        city,
        country,
        home_team,
        away_team,
        observation,

        -- Measures
        home_goals,
        away_goals

    FROM renamed
)

SELECT * FROM final
