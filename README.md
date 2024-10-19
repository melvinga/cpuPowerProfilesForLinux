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

# How to autorun script at system startup in Linux (Ubuntu 18.04 and Ubuntu 20.04):
1) Download cpuFullHzRangeAutoRun.sh
2) Copy this script into /etc/init.d folder and make it executable.

Example case: This file is downloaded into Downloads folder
1) Open terminal (Click Ctrl+Alt+T on your keyboard)
2) Execute below command to navigate to Downloads folder

    cd ~/Downloads

3) Command to copy to /etc/init.d/ folder

    sudo cp cpuFullHzRangeAutoRun.sh /etc/init.d/

4) Command to make the script get executed at system bootup

    sudo chmod +x /etc/init.d/cpuFullHzRangeAutoRun.sh

5) (Optional step) Configure the script to run at startup:

    sudo update-rc.d cpuFullHzRangeAutoRun.sh defaults
    
Next time you bootup your PC/Laptop, the script will automatically run.

# How to autorun script at system startup in Linux (Ubuntu 22.04):
1) Download cpuFullHzRangeAutoRun.sh
2) Copy this script into /etc/init.d folder and make it executable.

Example case: This file is downloaded into Downloads folder
1) Open terminal (Click Ctrl+Alt+T on your keyboard)
2) Execute below command to navigate to Downloads folder

    cd ~/Downloads

3) Command to copy to /etc/init.d/ folder

    sudo cp cpuFullHzRangeAutoRun.sh /etc/init.d/

4) Command to make the script get executed at system bootup

    sudo chmod +x /etc/init.d/cpuFullHzRangeAutoRun.sh

5) Copy the service file to sytemd folder:
    (Reference: https://www.squash.io/executing-bash-script-at-startup-in-ubuntu-linux/)

    sudo cp cpuFullHzRangeAutoRun.service /etc/systemd/system/

6) Reload the systemd daemon to load the new service unit file:

    sudo systemctl daemon-reload

7) Setup the service for automatically running at startup/bootup:

    sudo systemctl enable cpuFullHzRangeAutoRun.service 

8) Start the service for now (before any reboot):

    sudo systemctl start cpuFullHzRangeAutoRun.service 
    
Next time you bootup your PC/Laptop, the script will automatically run.
