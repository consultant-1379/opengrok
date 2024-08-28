#!/bin/sh

set_environment_variables()
{
	GERRIT_HOST="gerrit-gamma-read.seli.gic.ericsson.se"
	GERRIT_MIRROR="ssh://gerrit-gamma-read.seli.gic.ericsson.se:29418"
	TODAY_DATE=`date +"%d-%m-%Y"`
}

create_files()
{
    REPOSITORY_NAME_FILE=./$PROJECT/all_repos.txt
}



count_repos_scanned()
{
	TOTAL_REPOS_SCAN_COUNT=`wc -l $REPOSITORY_NAME_FILE | awk -F" " '{print $1}'`
}

#----------------------------------------------------------------------------------------------------------------------------#
#						              MAIN   							     #
#----------------------------------------------------------------------------------------------------------------------------#

echo " "
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                                          Script creates/updates ALL $1 GIT Repositories for OpenGrok                 "
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "

PROJECT=$1
set_environment_variables
create_files
count_repos_scanned
echo "TOTAL REPO COUNT: ${TOTAL_REPOS_SCAN_COUNT}"
COUNT=1
for REPOSITORY in `cat $REPOSITORY_NAME_FILE`
do
	(
		cd $OPENGROK_DOCKER_HOME/$PROJECT/src*
		REPO_DIR=`echo "$REPOSITORY" | awk -F '/' '{print $NF}'`
		if [ ! -d ${REPO_DIR} ]
			then
				echo "($COUNT/$TOTAL_REPOS_SCAN_COUNT): Cloning ${GERRIT_MIRROR}/$REPOSITORY"
				git clone ${GERRIT_MIRROR}/$REPOSITORY || true
		fi
	)
	((COUNT++))
done
