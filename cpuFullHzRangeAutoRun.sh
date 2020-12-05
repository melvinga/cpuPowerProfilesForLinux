#!/bin/bash
###############################################################################
#
# Authors:
#   Melvin George
#
# Description:
#   Improves battery life in laptops with Intel CPUs with zero compromise on
#   performance. Better than default power profile in Ubuntu 18.04.4 LTS and
#   Ubuntu 20.04.1 LTS.
#
# How to setup for auto-run at system bootup:
#  Copy this script into /etc/init.d folder and make it executable.
#  Example case: This file is downloaded into Downloads folder
#    a) Open terminal (Click Ctrl+Alt+T on your keyboard)
#    b) Execute below command to navigate to Downloads folder
#        cd ~/Downloads
#    c) Command to copy to /etc/init.d/ folder
#        sudo cp cpuFullHzRangeAutoRun.sh /etc/init.d/
#    d) Command to make the script get executed at system bootup
#        sudo chmod +x /etc/init.d/cpuFullHzRangeAutoRun.sh
#
#  Next time you bootup your PC/Laptop, the script will automatically run.
#
# Tested with:
#   Intel i5 8265U (Dated: 06 Dec 2020)
#
# License: GNU GPL v3.0
#
# GitHub repo: https://github.com/melvinga/cpuPowerProfilesForLinux
#
# Date created: 06 Dec 2020
# Last updated: 06 Dec 2020
#
###############################################################################

GOVERNOR_VALUE=powersave
#GOVERNOR_VALUE=performance
MAX_FREQ_VALUE=$(( 100 * 100000 ))
MIN_FREQ_VALUE=$((   1 * 100000 ))

FILE=/usr/bin/cpufreq-set
if ! [ -f "$FILE" ]; then
  sudo apt update && sudo apt -y install cpufrequtils
fi

if [ -f "$FILE" ]; then
  for ((i=0;i<$(nproc);++i)); do sudo cpufreq-set -c $i -r -g $GOVERNOR_VALUE; done

  for ((i=0;i<$(nproc);++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ_VALUE --max $MAX_FREQ_VALUE; done
fi
