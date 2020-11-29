#!/bin/bash
###############################################################################
#
# Authors:
#   Melvin George
#
# Description:
#   Improves battery life in laptops with Intel CPUs with zero compromise on
#   performance. Better than default power profile in Ubuntu 18.04.4 LTS
#
# Tested with:
#   Intel i5 8265U (Dated: 29 Nov 2020)
#
# License: GNU GPL v3.0
#
# GitHub repo: https://github.com/melvinga/cpuPowerProfilesForLinux
#
# Date created: 29 Nov 2020
# Last updated: 29 Nov 2020
#
###############################################################################

# TESTED FOR i5-8265U
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

  echo "Governor is set to:"
  cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  echo ""

  for ((i=0;i<$(nproc);++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ_VALUE --max $MAX_FREQ_VALUE; done

  echo "Min freq is set to:"
  cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_min_freq
  echo ""

  echo "Max freq is set to:"
  cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_max_freq
  echo ""

  echo "Press Ctrl+C to exit"
  sleep 1
  watch -n1 "cat /proc/cpuinfo | grep \"^[c]pu MHz\""
  echo ""
fi
