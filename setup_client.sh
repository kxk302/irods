#!/bin/bash

# To allow server to start 
sleep 10

py.test /irods_client_tests.py -v --junitxml="result.xml"

# To prevent container from existing
tail -f /dev/null 
