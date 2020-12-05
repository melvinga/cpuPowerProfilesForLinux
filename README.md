# cpuPowerProfilesForLinux

Improves battery life in laptops with Intel CPUs with zero compromise on performance. Better than default power profile in Ubuntu 18.04.4 LTS

Tested to be working fine with Intel i5 8265U (Dated: 29 Nov 2020)

# Compatibility:
Ubuntu and other Linux: yes

Windows: No

Mac OS: No

# How to run script in Linux:
1) Download govFullHzRange.sh and open the folder
2) Copy govFullHzRange.sh to a convenient path (example: cp govFullHzRange.sh Desktop/ )
3) Open the folder in which script is put
4) Make script executable:
    chmod +x govFullHzRange.sh
5) Execute script
    ./govFullHzRange.sh
   If this is the first time you are running the script, it will automatically install required packages and may take a minute. Subsequent runs of the script will have no delays.

Note: To stop script, press Ctrl+C on your keyboard.

# How to autorun script at system startup in Linux:
1) Download cpuFullHzRangeAutoRun.sh
2) Copy this script into /etc/init.d folder and make it executable.
   Example case: This file is downloaded into Downloads folder
     a) Open terminal (Click Ctrl+Alt+T on your keyboard)
     b) Execute below command to navigate to Downloads folder
         cd ~/Downloads
     c) Command to copy to /etc/init.d/ folder
         sudo cp cpuFullHzRangeAutoRun.sh /etc/init.d/
     d) Command to make the script get executed at system bootup
         sudo chmod +x /etc/init.d/cpuFullHzRangeAutoRun.sh
   
   Next time you bootup your PC/Laptop, the script will automatically run.
