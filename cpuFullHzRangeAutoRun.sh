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
#         e) (optional) Configure the script to run at startup:
#             sudo update-rc.d cpuFullHzRangeAutoRun.sh defaults
#
#   (2) For Ubuntu 22.04 (using systemd):
#       Copy this script into /etc/init.d folder and make it executable.
#       Example case: This file is downloaded into Downloads folder
#         a) Open terminal (Click Ctrl+Alt+T on your keyboard)
#         b) Execute below command to navigate to Downloads folder
#             cd ~/Downloads
#         c) Command to copy to /etc/init.d/ folder
#             sudo cp cpuFullHzRangeAutoRun.sh /etc/init.d/
#         d) Command to make the script get executed at system bootup
#             sudo chmod +x /etc/init.d/cpuFullHzRangeAutoRun.sh
#         e) Copy the service file to sytemd folder:
#             (Reference: https://www.squash.io/executing-bash-script-at-startup-in-ubuntu-linux/)
#
#             sudo cp cpuFullHzRangeAutoRun.service /etc/systemd/system/
#         f) Reload the systemd daemon to load the new service unit file:
#             sudo systemctl daemon-reload
#         g) Setup the service for automatically running at startup/bootup:
#             sudo systemctl enable cpuFullHzRangeAutoRun.service 
#         h) Start the service for now (before any reboot):
#             sudo systemctl start cpuFullHzRangeAutoRun.service 
#
#   Next time you bootup your PC/Laptop, the script will automatically run.
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

  # Performance cores in Intel
  for ((i=0;i<4;++i)); do sudo cpufreq-set -c $i --min $PERFORMANCE_CORE_FREQ_MIN --max $PERFORMANCE_CORE_FREQ_MAX; done

  # Efficiency cores in Intel
  for ((i=4;i<$(nproc);++i)); do sudo cpufreq-set -c $i --min $EFFICIENCY_CORE_FREQ_MIN --max $EFFICIENCY_CORE_FREQ_MAX; done
fi
