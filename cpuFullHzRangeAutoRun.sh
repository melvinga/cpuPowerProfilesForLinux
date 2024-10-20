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
#         processors running at their base frequency. Any more cores is
#         mostly not a necessity.
#     (5) An asymmetric CPU having 2 power-hungry performance cores (with
#         hyperthreading (HT) enabled to increase throughput) and 4 efficiency
#         cores (no HT present) would result in a very responsive PC.
#
#   In powersave mode:
#     Performance cores will have max frequency set to their base frequency.
#     Efficiency cores will have max frequency set to their base frequency.
#     Minimum frequency for all cores would be half the frequency of Performance core.
#       - The system would be very responsive for everyday tasks with optimal
#         battery runtime of 6+ hours for a fully-charged ~50 watt-hour battery.
#
#   In performance mode:
#     Performance cores will have max frequency set to thrice their base frequency.
#     Efficiency cores will have max frequency set to twice their base frequency.
#     Minimum frequency for all cores would be base frequency of Performance cores.
#       - The system would be able to avoid CPU throttling for long-running
#         compute-intensive tasks.
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
# Last updated: 20 Oct 2024
#
###############################################################################

# # TESTED FOR i5-8265U (Base Frequency of CPU is 1.6 GHz)
# GOVERNOR_VALUE=powersave
# PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=16  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=16  # 8 = 0.8 GHz for 2nd core; Typical value.
# MIN_FREQ_MULTIPLIER=8  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).
# # GOVERNOR_VALUE=performance
# # PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=16  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# # EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=16  # 8 = 0.8 GHz for 2nd core; Typical value.
# # MIN_FREQ_MULTIPLIER=1  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).

# TESTED FOR i3-1315U (Base Frequency of CPU is 1.2 GHz)
GOVERNOR_VALUE=powersave
PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=12  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=9  # 8 = 0.8 GHz for 2nd core; Typical value.
MIN_FREQ_MULTIPLIER=6  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).
# GOVERNOR_VALUE=performance
# PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX=36  # 100 = 10 GHz for 1st core (or 4.5 GHz if that's the max possible).
# EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX=18  # 8 = 0.8 GHz for 2nd core; Typical value.
# MIN_FREQ_MULTIPLIER=12  # 1 = 0.1 GHz for subsequent cores (or 0.4 GHz if that's the lowest possible).

PERFORMANCE_CORE_FREQ_MAX=$(( $PERFORMANCE_CORE_FREQ_MULTIPLIER_MAX * 100000 ))  # 100 * 100 MHz = 10 GHz
EFFICIENCY_CORE_FREQ_MAX=$(( $EFFICIENCY_CORE_FREQ_MULTIPLIER_MAX * 100000 ))  #   6 * 100 MHz = 0.6 GHz
MIN_FREQ=$(( $MIN_FREQ_MULTIPLIER * 100000 ))  #   1 * 100 MHz = 0.1 GHz

FILE=/usr/bin/cpufreq-set
if ! [ -f "$FILE" ]; then
  sudo apt update && sudo apt -y install cpufrequtils
fi

if [ -f "$FILE" ]; then
  for ((i=0;i<$(nproc);++i)); do sudo cpufreq-set -c $i -r -g $GOVERNOR_VALUE; done

  # Performance cores in Intel
  for ((i=0;i<2;++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ --max $PERFORMANCE_CORE_FREQ_MAX; done

  # Efficiency cores in Intel
  for ((i=2;i<$(nproc);++i)); do sudo cpufreq-set -c $i --min $MIN_FREQ --max $EFFICIENCY_CORE_FREQ_MAX; done
fi
