#!/bin/bash
cd /home/LOFAR_api/UC2_workflow_api/lofar_workflow_api
rm db.sqlite3
rm -rf api/migrations
pipenv run python3 manage.py makemigrations api
pipenv run python3 manage.py migrate
pipenv run python3 manage.py runserver
