# Opengrok Docker
Readme by Dan Simons (EMDANSI)

> Important Links
>
> https://github.com/oracle/opengrok
>
> https://gerrit.ericsson.se/#/admin/projects/OSS/com.ericsson.de/opengrok



## Description
This project is the docker instance of opengrok for both ENM and EIC (With more areas to come)

It uses a docker-compose file for two docker containers, these dockerfiles can be found in each of the project area folders.


## Setup
1. Please ensure you copy the appropriate ssh keys into the .ssh folder within the config folder
2. Please replace {user} with the relevant username in the config file in the .ssh folder (username paired with the ssh keys you just copied)
3. Ensure that executable permissions have been given to the setup.sh script
4. Start docker desktop
5. Run the setup.sh script

## Setup for testing
1. Please ensure you set up some environmental variables such as OPENGROK_DOCKER_HOME which points to this docker projects directory
2. Please ensure you setup the variable SSH_HOME which points to .ssh folder in this directory
3. Please ensure you add the files of 'group' and 'passwd' to config directory, with the passwd file please ensure you add your user's details to the end of the file 
{username}:*:UID:GID:Description:/Home/username:/bin/bash
4. Please ensure that you add your user's ID and group ID to the docker-compose file under user
5. Please ensure you copy the appropriate ssh keys into the .ssh folder within the config folder
6. Please replace {user} with the relevant username in the config file in the .ssh folder (username paired with the ssh keys you just copied)
7. Ensure that executable permissions have been given to the setup.sh script
8. Create a **test-proj** folder for each of the project area folders
9. In the clone_repos.sh script change the file in the create files method to **REPOSITORY_NAME_FILE=./$PROJECT/all_repos_test.txt**
10. In the clone_repos.sh script change the directory in the for-loop to
cd **$PROJECT/test-proj/**
11. The final step is to change the volumes found in the docker-compose.yml file. The ENM volume should be changed **'./enm/test-proj/:/opengrok-proj/opengrok/src/'** The EIC volume should be changed to **'./eic/test-proj/:/opengrok-proj/opengrok/src/'**
12. Start docker desktop
13. Run the setup.sh script

# Project Info
``` bash
├── README.md
├── config
│    ├── .ssh
│    │   └── config
│    ├── eforbidden.jsp
│    ├── logging.properties
│    ├── sync.yml
│    └── xml
│        ├── eic_web_xml_update_for_idm
│        ├── enm_web_xml_update_for_idm
│        ├── tomcat_conf_update
│        └── tomcat_conf_update_max_header
├── docker-compose.yml
├── eic
│   ├── Dockerfile
│   ├── all_repos.txt
│   ├── data
│   ├── etc
│   └── projects
├── enm
│   ├── Dockerfile
│   ├── all_repos.txt
│   ├── data
│   ├── etc
│   └── projects
├── scripts
│   ├── clone_repos.sh
│   ├── periodic_timer.py
│   └── start.py
└── setup.sh
```
<!--
## Sample Folder
> #### Contains
>> Sample
>
>> Sample
>
>> Sample -->

## Environmental variables setup


## Root Directory (opengrok_docker)
> #### Contains
>> **README.md**: A file detailing setup and directions
>
>> ***Config***: More on config folder later
>
>> **docker-compose.yml**: This file contains all the relevant information to start up the opengrok docker instances for each project area.
>>
>> Each docker container runs tomcat on port 8080.
>>
>> Where to **ENM** is on http://localhost:8080/source and
>>
>> **EIC** is on http://localhost:8081/source
>>
>> Each container has 3 volumes, these are the
>> - projects -> opengrok-proj/opengrok/src ***(Where all the git projects for the area go)***
>> - data -> opengrok-proj/opengrok/data ***(Where the index and history is stored)***
>> - etc -> opengrok-proj/opengrok/etc ***(Where the configuration xml is stored)***
>
>> ***proj-area(e.g ENM)***: More on this folder later
>
>> ***scripts***: More on this folder later
>
>> **setup.sh**: This script setups the appropriate folders, permissions for scripts and docker commands for the project.

## Config Folder
> #### Contains
>
>> **/.ssh/config**: This file contains the different available hosts.
It should be noted that upon download the field {user} should be changed to the applicable username for the ssh keys.
>> (The ssh public and private keys should also be copied into the .ssh folder)
>
>> **eforbidden.jsp**: Error page for web application
>
>> **logging.properties**: Contains the logging properties specification for tomcat web app
>
>> **sync.yml**: This file contains the the sync configuration for opengrok. This the default sync configuration with only the opengrok location changed **_/opengrok-proj/opengrok_**. This is the location in the docker container.
>>
>> More information regarding the sync can be found [here](https://github.com/oracle/opengrok/wiki/Repository-synchronization):
>
>> **/xml/*proj-area*_web_xml_update_for_idm**: These files are xml snippets which contain the role contraints needed for each area. These are added into the web.xml file for the webapp. These contraints only allow people with the specified role to access it.
The important fields to note are  \<auth-constraint\> and \<role-name\> which contain the AD value for the role.
>
>> **/xml/tomcat_conf_update**: This file contains the LDAP server information for Ericsson. This allows users to log in with their signum and password. This also allows the verication of the correct roles. This information is added to the server.xml file on the tomcat instance.
>
>> **/xml/tomcat_conf_update_max_header**: This is another xml snippet for the server.xml file. This updates the maxheader size to allow larger requests to be sent.
