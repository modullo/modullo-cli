## Modullo CLI Setup - Developers Guide

This provides a guide on how to **setup** and **create** software and infrastructure painlessly.

### What is the CLI

.


### How to Install

First ensure the following requirements are present. Also, details on additional options are presented below

#### Requirements & First Steps

<!-- Please ensure the following are installed and running on your local or deployment machine:
- Terraform [Installation / Documentation](https://www.terraform.io/)
- Ansible [Installation / Documentation](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)
- AWS Account & Access Credentials (with sufficient permissions) [IAM Key ID & Secret](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)
- Passlib Python Library


Then create the following (3) **parameter** and **variable** files with exactly the same name your Project ID (e.g. demo):
- Master Parameter File [projects/demo/demo.params](#)
- Terraform Variable File [projects/demo/demo.tfvars](#)
- Ansible Parameter File [ansible/vars/demo.yml](#)

For a full list of  **parameter** and **variable**, [see Installation Parameters below](#installation-parameters) -->

#### Installation

Once the requirements are done, setup can be done with a single command line interface:

```
$ modullo-setup project=demo
```

AND THEN

```
$ modullo-create project=demo
```

#### Installation Parameters (#installation-parameters)

The following are configuration parameters that can be used during deployment:

For the *.params file
- **domain** _specify base domain (or trial domain) (will be used as primary hub url)_
<!-- - **project** _specify Project ID (like a business slug such as clientabc)_
- **trial** _specify if deploying trial mode is true or not (standalone mode) (default is true)_
- **email** _specify default administrative email address to be sent setup confirmation_
- **setup_root** _specify local machine path for deploy code (e.g./Users/ifeoluwa/Downloads/dorcas-setup)_
- **git_user** _specify Github user name to pull base Dorcas Code from repository_
- **git_pass** _specify Github password or token to pull base Dorcas Code from repository_
- **partner_name** _specify a title for the account or partner (100 alphanumeric characters maximum)_
- **partner_slug** _specify a short slug for the account or partner, e.g abc-limited (only alphaumeric and hyphens are allowed)_
- **partner_logo_url** _specify absolute URL for the account logo_
- **use-db-host** _host.mysqlinstance.com (allows specification of existing database host)_
- **provider** _specify which IAAS / PAAS provider to use for deployment (default is aws)_ -->

<!-- For the *.tfvars file:
    - **domain** _specify base domain (or trial domain) (will be used as primary hub url)_
    - **access_key** _specity AWS Access Key ID for resource deployment_
    - **secret_key** _specity AWS Access Key Secret for resource deployment_
    - **region** _specity AWS Region for resource deployment_
    - **route53_zone** _specity AWS Route 53 Zone ID for DNS Management_

For the *.yml file:
    - **php_cgi** _specify PHP CGI Processor for the installed PHP version_
    - **php_ini_path** _specify PHP INI path for the installed PHP version_
    - **php_packages_list** _specify PHP packages/extentions for the installed PHP version_
    - **system_software** _specify Linux (Ubuntu) OS packages to pre-install_ -->


### Support or Contact

Have any queries? Send an email to **support@modullo.io** <!--or [visit the website](https://dorcas.io) and we’ll help you.-->

---
# modullo-cli
