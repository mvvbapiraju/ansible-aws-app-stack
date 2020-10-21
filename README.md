# AWS App deployment and configuration using Ansible
This project creates a CI/CD pipeline using Ansible Roles to provision an AWS environment and configures a sample voting application.

The Master Ansible playbook will deploy a self contained environment to run a sample **[Voting App](src/README.md)** within a default AZ VPC with a private subnets running on AWS.

This setup deploys a AWS Application Load Balancer (ALB) (as an Elastic Load Balancer using ALB) as in presentation layer, which automatically routes the traffic to 2 instances of EC2 Servers in multi-AZ hosting a web page, each server serving 2 webapps at ports 5000(Voting App) and 5001(Results App).

Sample load balancer web page of Voting App looks like below:

![Alt text](docs/app_run_demo.gif?raw=true "Load Balancer Accessing instances")

## Prerequisites
* IAM User with the required permission.
* Python3 with Boto installed. (Ansible uses Boto Python module to handle AWS dynamic inventory management)
* An SSH Key pair User Home (~/.ssh/id_rsa & ~/.ssh/id_rsa.pub). This will be used by Ansible playbook to dynamically create a provisioned AWS EC2 key pair, Ansible Playbook will create one, if not found.

## Setup
On a new system, we'll need to have git, Python3, pip and other essentials like Ansible installed.

At a terminal, do the following:

```bash
# Clone this project
git clone git@github.com:mvvbapiraju/ansible-aws-app-stack.git

# Make sure awscli and boto are installed
pip install awscli boto boto3

# Configure aws credentials
aws configure

Help with AWS configuration can be found here: http://docs.aws.amazon.com/cli/latest/userguide/cli-chap-getting-started.html
```

Alternative for configuring AWS credentials (but, not advised) before running Ansible Playbook:

```$xslt
export AWS_ACCESS_KEY_ID='<AWS Acess Key ID for your User Account>'
export AWS_SECRET_ACCESS_KEY='<AWS Secret Acess Key for your User Account>'
```

## Usage

To launch AWS infrastructure, use the following command.

```bash
$ ansible-playbook -i inventory/ec2.py -e ansible_python_interpreter=python3 playbooks/deploy_and_configure_aws.yml
```

Or, use below command to execute a bash script file after replacing AWS credentials inside with that of your's (add this file to your .gitignore):

```
./launch_aws.sh
```
```
#!/usr/bin/bash

export AWS_ACCESS_KEY_ID=''
export AWS_SECRET_ACCESS_KEY=''

ansible-playbook -e ansible_python_interpreter=python3 playbooks/deploy_and_configure_aws.yml -vv
```

To cleanup AWS infrastructure, use the following command.

```bash
$ ansible-playbook -e ansible_python_interpreter=python3 playbooks/aws_delete_resources.yml
```

Or, use below command to execute a bash script as below after replacing AWS credentials inside with that of your's (add this file to your .gitignore):

```
./destroy_aws.sh
```
```
#!/usr/bin/env bash

export AWS_ACCESS_KEY_ID=''
export AWS_SECRET_ACCESS_KEY=''

ansible-playbook -e ansible_python_interpreter=python3 playbooks/aws_delete_resources.yml -vv
```

Make sure ansible.cfg file properly configured with below ansible defaults:
```
# Set the default username to use when SSHing in
remote_user = ec2-user

# Set the location of the EC2 Dynamic Inventory Script
roles_path = ./roles
inventory = ./inventory
hostfile = ./inventory/ec2.py

# Don't check for known_hosts when SSHing in
host_key_checking = False
private_key_file = ~/.ssh/id_rsa.pem
```

```
To convert a public key to PEM file: https://serverfault.com/questions/706336/how-to-get-a-pem-file-from-ssh-key-pair

ssh-keygen -f id_rsa.pub -m 'PEM' -e > id_rsa.pem
```

## Environment provision, configuration and cleanup requires below playbooks:
  * deploy_and_configure_aws.yml
    * aws_provision_resources.yml
    * aws_configure_tiers.yml
  * aws_delete_resources.yml

### deploy_and_configure_aws.yml
  * Master playbook hook to execute deploy and configure playbooks.

#### aws_provision_resources.yml
* This playbook uses Ansible AWS EC2 dynamic inventory feature to provision all the resources required for 3 Tier Application
* This playbook executes provision_aws role by taking all its variables from provision_aws/vars/main.yml file.

#### aws_configure_tiers.yml
Deploys and configures the 3 Tier Application.
* This playbook uses Ansible AWS EC2 dynamic inventory feature to configure 3 Tier Application Servers:
  * HAProxy as the frontend server to load balance between application servers.
  * Tomcat as the application servers.
  * PostgreSQL as the database server.

### aws_delete_resources.yml
  * Playbook to cleanup all the AWS resources previously created by aws_provision_resources.yml playbook.

## AWS Infrastructure Provisioning
* Below AWS resources are created as part of Infrastructure provisioning:

   * VPC - 1
   * Subnets - 1 (for app-tier)
   * Router - 1
   * IGW (Internet Gateway) - 1
   * Security Groups - 1 (for app-tier)
   * EC2 Instances - 2 (2 for App Tier)

* Below load balancing resources are now added to replace HAProxy Load Balancer
   * Application Load Balancer - 1
   * Target Group for ALB - 1

Diagram showing AWS Infrastructure:

![Alt text](docs/aws_vpc_architecture.jpg?raw=true "Load Balancer Accessing 1st instance")

# Author Information

Veera Mallipudi

mvvbapiraju@gmail.com | https://www.linkedin.com/in/mvvbapiraju
