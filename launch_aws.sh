#!/bin/bash

export AWS_ACCESS_KEY_ID=''
export AWS_SECRET_ACCESS_KEY=''

ansible-playbook -e ansible_python_interpreter=/usr/bin/python3 playbooks/deploy_and_configure_aws.yml -vv
