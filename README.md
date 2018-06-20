# VirtualDocker
A docker development environment setup with VirtualBox. I built a shell script that will have a lot of utility actions so that you don't need to know docker or linux commands.

### How to install
`` git clone git@github.com:ValiNiculae/VirtualDocker.git ``

### How to use
Run the shell script ``sh vdocker`` and select from the menu what you want to do.

### What does this button do?
#### create-vm
1. Create a VM
2. Add 2 shared folders - this repo + projects path
2. Install docker-compose
3. Start the containers (all official images): nginx, php, mysql, redis (for now) 
4. Add a watcher that will monitor your projects path for any changes and will update the NGINX config accordingly.
#### configure-project
1. Change root path of the project
2. Change domain extension of the project

#### change domain extension
1. Change general domain extension. By default we use `.test`. 

#### regenerate configs
1. Regenerate all NGINX configs and ssl certificates 

#### show hosts info
1. It will show a list of configs that need to be added to the windows **hosts** file

### Future plans
* add more options to the menu
* offer support for Hyper-V
* ... 