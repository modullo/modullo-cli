## Modullo CLI - Developers Guide

This provides a guide on how to use the **Modullo CLI** tool.

### What is Modullo CLI

Modullo CLI is a swiss-army knife for developers and IT professionals generally. It simplifies code setup, code deployment and general tasks

### How to Install

First ensure the following requirements are present. Also, details on additional options are presented below

#### Requirements & First Steps

Please ensure the following are installed and running on your local or deployment machine:
- Terraform [Installation / Documentation](https://www.terraform.io/)
- Ansible [Installation / Documentation](https://docs.ansible.com/ansible/latest/network/getting_started/first_playbook.html)
- IAAS Platform Credentials (with sufficient permissions) [AWS](https://docs.aws.amazon.com/IAM/latest/UserGuide/id_credentials_access-keys.html)


#### Setup

You can create a project file by simply running:

```
$ make modullo-setup project=demo
```

Then create the following (3) **parameter** and **variable** files with exactly the same name your Project ID (e.g. demo):
- Master Parameter File [projects/demo/demo.params](#)
- Terraform Variable File [projects/demo/demo.tfvars](#)
- Ansible Parameter File [ansible/vars/demo.yml](#)

For a full list of  **parameter** and **variable**, [see Installation Parameters below](#installation-parameters)

#### Installtion

Once the requirements are done, and your setup has generated the required files, creation can be done with a single command line interface:

```
$ make modullo-create project=demo
```

#### Installation Parameters (#installation-parameters)

The following are configuration parameters that can be used during deployment

- **project** _specify Project ID (like a slug such as demo or projectxyz)_
- **email** _specify default administrative email address to be sent setup confirmation_
- **provider** *specify which IAAS / PAAS provider to use for deployment (default is do Digital Ocean)*


### Support or Contact

Have any queries? Send an email to **support@modullo.io** <!--or [visit the website](https://modullo.io) and we’ll help you.-->

---
