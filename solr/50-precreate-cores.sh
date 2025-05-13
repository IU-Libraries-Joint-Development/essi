#!/bin/bash
#
# docker-entrypoint-initdb file for creating multiple solr cores
set -e

precreate-core hydra-development /myconfig/conf
precreate-core hydra-test /myconfig/conf
