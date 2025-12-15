#!/bin/bash
ansible-playbook pp_front.yml
ansible-playbook pp_back.yml
ansible-playbook pp_DB.yml
#ansible-playbook pp_MLA.yml