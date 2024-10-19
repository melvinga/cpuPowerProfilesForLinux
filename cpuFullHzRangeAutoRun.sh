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
#     (4) Most PCs will be responsive in the year 2024 if it has quad-core
#         processors. Any more cores is mostly not a necessity.
#     (5) An asymmetric CPU having 2 power-hungry performance cores (with
#         hyperthreading (HT) disabled to increase responsiveness and reduce
#         power consumption) and 4 efficiency cores (no HT present) would
#         result in a very responsive PC even when the 4 efficiency cores are
#         being utilized more often.
#     (6) The minimum frequency of all cores will be the minimum possible
#         frequency possible for the processor. This will ensure minimum
#         power consumption while the user is reading, listening to music,
#         tiny breaks during programming, etc.
#
#   In powersave mode:
#     The power-hungry performance cores (with HT disabled) will have maximum
#     processor set to the base frequency of efficiency cores.
#       - This would, in theory, make the power-hungry performance cores be
#         as good as efficiency cores in terms of performance and power
#         efficiency.
#     The efficiency cores will have max frequency set to the base
#     frequency of the power-hungry performance cores.
#       - The OS will, in theory, give more of the tasks to the
#         efficiency cores.
#
#   In performance mode:
#     Max frequency of performance cores will be set to twice their base
#     frequency.
#     Max frequency of efficiency cores will be set to their base frequency.
#
# How to setup for auto-run at system bootup:
#   (1) For Ubuntu 18.04 and Ubuntu 20.04:
#       Copy this script into /etc/init.d folder and make it executable.
#       Example case: This file is downloaded into Downloads folder
#         a) Open terminal (Click Ctrl+Alt+T on your keyboard)
#         b) Execute below command to navigate to Downloads folder
#             cd ~/Downloads
#         c) Command to copy to /etc/init.d/ folder
#             sudo cp cpuFullHzRangeAutoRun.sh /etc/init.d/
#         d) Command to make the script get executed at system bootup
#             sudo chmod +x /etc/init.d/cpuFullHzRangeAutoRun.sh
#         e) Configure the script to run at startup:
#             sudo update-rc.d cpuFullHzRangeAutoRun.sh defaults
#
#  Next time you bootup your PC/Laptop, the script will automatically run.
#
# Tested with:
#   - Intel i5 8265U:
#       (1) Ubuntu 18.04.4 LTS, (Dated: 29 Nov 2020)
#           PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=8
#       (2) Ubuntu 20.04.1 LTS, (Dated: 05 Mar 2021)
#           PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=8
#   - Intel i3 1315U:
#       (1) Ubuntu 22.04.5 LTS, (Dated: 18 Oct 2024)
#           PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=9
#           EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=12
#
# License: GNU GPL v3.0
#
# GitHub repo: https://github.com/melvinga/cpuPowerProfilesForLinux
#
# Date created: 06 Dec 2020
# Last updated: 19 Oct 2024
#
###############################################################################

# # TESTED FOR i5-8265U (Base Frequency of CPU is 1.6 GHz)
# GOVERNOR_VALUE=powersave
# MAX_FREQ_MULTIPLIER=16  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# TYP_FREQ_MULTIPLIER=8  # 8 = 0.8 GHz for 2nd core; Typical value.
# MIN_FREQ_MULTIPLIER=1  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).
# # GOVERNOR_VALUE=performance
# # MAX_FREQ_MULTIPLIER=32  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# # TYP_FREQ_MULTIPLIER=16  # 8 = 0.8 GHz for 2nd core; Typical value.
# # MIN_FREQ_MULTIPLIER=1  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).

# TESTED FOR i3-1315U (Base Frequency of CPU is 1.2 GHz)
GOVERNOR_VALUE=powersave
MAX_FREQ_MULTIPLIER=12  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
TYP_FREQ_MULTIPLIER=6  # 8 = 0.8 GHz for 2nd core; Typical value.
MIN_FREQ_MULTIPLIER=1  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).
# GOVERNOR_VALUE=performance
# MAX_FREQ_MULTIPLIER=24  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# TYP_FREQ_MULTIPLIER=12  # 8 = 0.8 GHz for 2nd core; Typical value.
# MIN_FREQ_MULTIPLIER=1  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).

MAX_FREQ_VALUE=$(( $MAX_FREQ_MULTIPLIER * 100000 ))  # 100 * 100 MHz = 10 GHz
TYP_FREQ_VALUE=$(( $TYP_FREQ_MULTIPLIER * 100000 ))  #   6 * 100 MHz = 0.6 GHz
MIN_FREQ_VALUE=$(( $MIN_FREQ_MULTIPLIER * 100000 ))  #   1 * 100 MHz = 0.1 GHz

FILE=/usr/bin/cpufreq-set
if ! [ -f "$FILE" ]; then
  sudo apt update && sudo apt -y install cpufrequtils
fi

if [ -f "$FILE" ]; then
  for ((i=0;i<$(nproc);++i)); do sudo cpufreq-set -c $i -r -g $GOVERNOR_VALUE; done

  for ((i=0;i<2;++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ_VALUE --max $MAX_FREQ_VALUE; done
  for ((i=2;i<4;++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ_VALUE --max $TYP_FREQ_VALUE; done
  for ((i=4;i<$(nproc);++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ_VALUE --max $MIN_FREQ_VALUE; done
fi
