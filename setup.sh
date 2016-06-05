#!/bin/bash

pip install pg8000;

sudo -u postgres psql -f src/psql/developer_utils/RESET_DATABASE_STATE.sql
