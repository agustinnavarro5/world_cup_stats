# World Cup Stats

Welcome to the world_cup_stats repository! This repository contains transformations made to a raw dataset of historical FIFA World Cup results available [here](https://public.tableau.com/app/learn/sample-data).

## Setting Up the Database

To set up a PostgreSQL database, a container with its image was created alongside a DockerFile that runs the required models on the database.

### Steps to Start the Project:

1. Install Poetry dependencies and start the shell:
    ```
    poetry install
    poetry shell
    ```

2. Copy the environment file:
    ```
    cp .env-example .env
    ```

3. Fill in the environment variables.

4. To start services, run the command:
    ```
    docker compose up -d
    ```

5. In case the DockerFile doesn't work for running the dbt models, run them manually using Poetry:
    ```
    poetry run dbt deps --project-dir dbt_world_cup --profiles-dir dbt_world_cup
    poetry run dbt build --project-dir dbt_world_cup --profiles-dir dbt_world_cup
    ```

6. Voilà! Check out the results.

## Dbt Project Structure

The project structure follows a Dimensional Kimball modeling strategy with layers representing logic transformations:

- **Staging:** Replicates models in their raw format with defined types.
- **Clean:** Deduplicates information based on a unique key and performs transformations like renaming or computed fields.
- **Marts:** Contains dimensional and fact models, applying business rules and computing aggregated functions for metrics.

## Final Notes

The `data` folder contains the transformed CSV files used for the challenge dashboard.

Explore and enjoy the World Cup statistics!
