{{ config(materialized='table') }}

WITH world_cup_results AS ( 

    SELECT
        *
    FROM {{ ref('fct_world_cup_results') }}
),


final AS (

    SELECT
        uuid,
        event_year,
        event_datetime,
        round,
        round_number,
        stadium,
        city,
        country,
        home_team                       AS participant_team,
        home_goals                      AS goals_scored,
        away_goals                      AS goals_received,
        CASE WHEN winner_team = home_team
            THEN TRUE
            ELSE FALSE
        END                             AS is_winner

    FROM world_cup_results
    UNION
    SELECT
        uuid,
        event_year,
        event_datetime,
        round,
        round_number,
        stadium,
        city,
        country,
        away_team                       AS participant_team,
        away_goals                      AS goals_scored,
        home_goals                      AS goals_received,
        CASE WHEN winner_team = away_team
            THEN TRUE
            ELSE FALSE
        END                             AS is_winner

    FROM world_cup_results

)

SELECT * FROM final
