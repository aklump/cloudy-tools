#!/usr/bin/env bash

##
 # @file Define all the variables used by Cloudy Core
 #
 # @export array CLOUDY_FAILURES
 # @global array CLOUDY_SUCCESSES
 # @global int CLOUDY_EXIT_STATUS
 # @global string CLOUDY_INSTALL_TYPE_COMPOSER
 # @global string CLOUDY_INSTALL_TYPE_CORE
 # @global string CLOUDY_INSTALL_TYPE_PM
 # @global string CLOUDY_INSTALL_TYPE_SELF
 # @global string LI
 # @global string LI2
 # @global string LIL
 # @global string LIL2
 ##

CLOUDY_EXIT_STATUS=0
CLOUDY_INSTALL_TYPE_COMPOSER='composer'
CLOUDY_INSTALL_TYPE_CORE='cloudy_core'
CLOUDY_INSTALL_TYPE_PM='cloudy_pm'
CLOUDY_INSTALL_TYPE_SELF='self'
LI2="│   $LI"
LI="├──"
LIL2="│   $LIL"
LIL="└──"
declare -a CLOUDY_FAILURES=()
export CLOUDY_PHP_FAILURES=''
declare -a CLOUDY_SUCCESSES=()
