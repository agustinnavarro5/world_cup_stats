{{ config(materialized='table') }}

WITH world_cup_results AS ( 

    SELECT
        *
    FROM {{ ref('clean_world_cup_results') }}
),

compute_winner_and_loser AS (

    SELECT
        *,
        CASE
            WHEN home_goals > away_goals THEN home_team
            WHEN home_goals < away_goals THEN away_team
            WHEN home_goals_in_penalties > away_goals_in_penalties THEN home_team
            WHEN home_goals_in_penalties < away_goals_in_penalties THEN away_team
            ELSE NULL
        END                                                                         AS winner_team,
        CASE
            WHEN home_goals > away_goals THEN away_team
            WHEN home_goals < away_goals THEN home_team
            WHEN home_goals_in_penalties > away_goals_in_penalties THEN away_team
            WHEN home_goals_in_penalties < away_goals_in_penalties THEN home_team
            ELSE NULL
        END                                                                         AS loser_team

    FROM world_cup_results
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
        winner_team,
        loser_team,

        -- Flags
        penalty_definition,

        -- Measures
        home_goals,
        home_goals_in_penalties,
        away_goals,
        away_goals_in_penalties

    FROM compute_winner_and_loser

)

SELECT * FROM final
