# syntax=docker/dockerfile:1
# Docker image for World Cup project

FROM python:3.9 AS base

USER root

# Set environment variables
ENV PIP_ROOT_USER_ACTION="ignore" \
    PATH="${PATH}:/root/.local/bin" \
    POETRY_VERSION="1.6.1"

WORKDIR /code

# Install system dependencies
RUN apt-get update && \
    apt-get install -yq \
        cmake g++ \
        gfortran libblas-dev liblapack-dev swig

# Install poetry
RUN <<END
    set -e
    pip install -U pip
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=${POETRY_VERSION} python3 -
    poetry config virtualenvs.create false
END

COPY poetry.lock pyproject.toml ./

# Copy the entire dbt project into the Docker image
COPY ./dbt_world_cup/ ./dbt_world_cup/

# Install project dependencies with Poetry
RUN poetry install

# ENV DBT_PROFILES_DIR=/code/dbt_world_cup/
# ENV DBT_PROJECT_DIR=/code/dbt_world_cup/

# default placeholders
ENV POSTGRES_HOST=postgres
ENV POSTGRES_PORT=5432
ENV POSTGRES_USER=world_cup
ENV POSTGRES_PASSWORD=world_cup
ENV POSTGRES_DB=world_cup

WORKDIR /code/dbt_world_cup

RUN bash -c "poetry run dbt deps --project-dir . --profiles-dir ."

CMD ["poetry", "run", "dbt", "seed", "--project-dir", ".", "--profiles-dir", "."]

CMD ["poetry", "run", "dbt", "build", "--project-dir", ".", "--profiles-dir", "."]