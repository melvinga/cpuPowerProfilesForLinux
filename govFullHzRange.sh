#!/bin/bash
###############################################################################
#
# Authors:
#   Melvin George
#
# Description:
#   Improves battery life in laptops with Intel CPUs with zero compromise on
#   performance. Better than default power profile in Ubuntu.
#
#   The basic idea is:
#     (1) Most applications need high single-core performance and would not
#         utilize multiple cores efficiently.
#     (2) Most applications have one main thread that is CPU intensive, and
#         one or more lightweight threads.
#     (3) The PC will have to execute the active application's thread/threads
#         and several lightweight OS-related threads.
#     (4) A CPU of frequency X-MHz is very efficient in the frequency range
#         0.5 * X to 1.5 * X.
#           (i) For asymmetric cores (like in i3-1315u processor),
#               the CPU frequency is base frequency of performance cores.
#
#   In powersave mode:
#     PGovernor is set to 'powersave'.
#
#   In performance mode:
#     PGovernor is set to 'performance'.
#
# Tested with:
#   - Intel i5 8265U:
#       (1) Ubuntu 18.04.4 LTS, (Dated: 29 Nov 2020)
#       (2) Ubuntu 20.04.1 LTS, (Dated: 05 Mar 2021)
#   - Intel i3 1315U:
#       (1) Ubuntu 22.04.5 LTS, (Dated: 18 Oct 2024)
#
# License: GNU GPL v3.0
#
# GitHub repo: https://github.com/melvinga/cpuPowerProfilesForLinux
#
# Date created: 06 Dec 2020
# Last updated: 206Oct 2024
#
###############################################################################

# # TESTED FOR i5-8265U (Base Frequency of CPU is 1.6 GHz)
# GOVERNOR_VALUE=powersave
# # GOVERNOR_VALUE=performance
# PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=24  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# PERFORMANCE_CORE_FREQ_MULTIPLIER_MIN=8
# EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=24  # 8 = 0.8 GHz for 2nd core; Typical value.
# EFFICIENCY_CORE_FREQ_MULTIPLIER_MIN=8  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).

# TESTED FOR i3-1315U (Base Frequency of CPU is 1.2 GHz)
GOVERNOR_VALUE=powersave
# GOVERNOR_VALUE=performance
PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=18  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
PERFORMANCE_CORE_FREQ_MULTIPLIER_MIN=6
EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=18  # 8 = 0.8 GHz for 2nd core; Typical value.
EFFICIENCY_CORE_FREQ_MULTIPLIER_MIN=6  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).

PERFORMANCE_CORE_FREQ_MAX=$(( $PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX * 100000 ))  # 100 * 100 MHz = 10 GHz
PERFORMANCE_CORE_FREQ_MIN=$(( $PERFORMANCE_CORE_FREQ_MULTIPLIER_MIN * 100000 ))  #   1 * 100 MHz = 0.1 GHz
EFFICIENCY_CORE_FREQ_MAX=$(( $EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX * 100000 ))  #   6 * 100 MHz = 0.6 GHz
EFFICIENCY_CORE_FREQ_MIN=$(( $EFFICIENCY_CORE_FREQ_MULTIPLIER_MIN * 100000 ))  #   6 * 100 MHz = 0.6 GHz

FILE=/usr/bin/cpufreq-set
if ! [ -f "$FILE" ]; then
  sudo apt update && sudo apt -y install cpufrequtils
fi

if [ -f "$FILE" ]; then
  for ((i=0;i<$(nproc);++i)); do sudo cpufreq-set -c $i -r -g $GOVERNOR_VALUE; done

  echo "Governor is set to:"
  cat /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor
  echo ""

  # Performance cores in Intel
  for ((i=0;i<4;++i)); do sudo cpufreq-set -c $i --min $PERFORMANCE_CORE_FREQ_MIN --max $PERFORMANCE_CORE_FREQ_MAX; done

  # Efficiency cores in Intel
  for ((i=4;i<$(nproc);++i)); do sudo cpufreq-set -c $i --min $EFFICIENCY_CORE_FREQ_MIN --max $EFFICIENCY_CORE_FREQ_MAX; done

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
