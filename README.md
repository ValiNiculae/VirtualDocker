# VirtualDocker
A docker development environment setup with virtualbox.

### How to install
`` git clone git@github.com:ValiNiculae/VirtualDocker.git ``

### How to use
1. ``sh vdocker``
2. Select ``create-vm`` and follow the instruction
	* You will be asked for your projects folder path
	* The name you want for your machine
3. Update your ``hosts`` file

*This will create a VirtualBox machine that will run docker with the following containers: nginx, php, mysql, redis.*
*It will also monitor your projects folder and build nginx configs and restart the nginx container*

### Future plans
* improved the scrips
* add more options to the menu
* offer support for Hyper-V