#!/bin/sh

set_environment_variables()
{
	GERRIT_HOST="gerritmirror-ha.lmera.ericsson.se"
	GERRIT_MIRROR="ssh://gerritmirror-ha.lmera.ericsson.se:29418"
	TODAY_DATE=`date +"%d-%m-%Y"`
	#MAIL_USERS="rahul.chhabra@ericsson.com,sonesh.kumar.malhotra@ericsson.com"
	MAIL_USERS="pdlucturee@pdl.internal.ericsson.com"
}

create_files()
{
	BUILD_MAIL=`pwd`/LITP_Candidate_mail.txt
	REPOSITORY_NAME_FILE=`pwd`/LITP_Repository_Name.txt
	#REPOSITORY_NAME_POC_FILE=/home/esonmal/Git_Push/utils/scripts/Repository_Name_PoC.txt
	REPOSITORY_NAME_POC_FILE=/proj/opengrok/ENM-Repos/scripts/Repository_Name_PoC.txt

	for file_name in $BUILD_MAIL $REPOSITORY_NAME_FILE
	do
		if [ -f $file_name ]
		then
			rm -rf $file_name
			touch $file_name
		else
			touch $file_name
		fi
	done
}

get_repository_name()
{
	echo "Generating list of ALL Projects in Gerrit"
	for REPO_LIST in `ssh -p 29418 $GERRIT_HOST gerrit ls-projects`
	do
		echo $REPO_LIST | egrep "^LITP" >> $REPOSITORY_NAME_FILE
	done
}

remove_duplicate_repos()
{
	sort $REPOSITORY_NAME_FILE | uniq > ${REPOSITORY_NAME_FILE}.tmp
	cp ${REPOSITORY_NAME_FILE}.tmp $REPOSITORY_NAME_FILE
	rm ${REPOSITORY_NAME_FILE}.tmp
}

count_repos_scanned()
{
	TOTAL_REPOS_SCAN_COUNT=`wc -l $REPOSITORY_NAME_FILE | awk -F" " '{print $1}'`
}

create_update_gitRepos()
{
	LITP_CHECK=`echo $REPOSITORY | awk -F"/" '{print $1}'`
	if [ "$LITP_CHECK" == "LITP" ]
	then
		ARTIFACT=`echo $REPOSITORY | awk -F"/" '{print $2}'`
		#continue
	else
		ARTIFACT=`echo $REPOSITORY | awk -F"/" '{print $3}'`
                continue
	fi

        echo "Starting ENM LITP Repos..."

	#cd $WORKSPACE
	cd /proj/opengrok/
	if [ ! -d ENM-LITP-Repos ]
	then
		mkdir -m 775 ENM-LITP-Repos
	fi
	cd ENM-LITP-Repos

	if [ ! -d src ]
	then
		mkdir -m 775 src
	fi
	cd src

	if [ ! -d ${ARTIFACT} ]
	then
		git clone ${GERRIT_MIRROR}/$REPOSITORY 
		#echo "${GERRIT_MIRROR}/$REPOSITORY - Cloned" >> $BUILD_MAIL
	else
		cd ${ARTIFACT}
		git pull ${GERRIT_MIRROR}/$REPOSITORY 
		#echo "${GERRIT_MIRROR}/$REPOSITORY - Pulled" >> $BUILD_MAIL
	fi

	if [ $? -ne 0 ]
	then
		echo "git clone/pull ${GERRIT_MIRROR}/$REPOSITORY - FAILED"
	else
		echo "git clone/pull ${GERRIT_MIRROR}/$REPOSITORY - SUCCESS"
	fi
#cd $WORKSPACE
}

#----------------------------------------------------------------------------------------------------------------------------#
#						              MAIN   							     #
#----------------------------------------------------------------------------------------------------------------------------#

echo " "
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo "                                          Script creates/updates ENM LITP GIT Repositories for OpenGrok                 "
echo "+++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++"
echo " "
echo "WORKSPACE is $WORKSPACE"

cd $WORKSPACE

set_environment_variables
create_files
get_repository_name
remove_duplicate_repos
count_repos_scanned

echo "-------------------------------------------------------------------------------------------------------------------------- " > $BUILD_MAIL
echo "creates/updates ENM LITP GIT Repositories for OpenGrok Jenkins Job has been Executed " >> $BUILD_MAIL
echo "-------------------------------------------------------------------------------------------------------------------------- " >> $BUILD_MAIL
echo " " >> $BUILD_MAIL
echo "Total Number of Repositories created/updated for OpenGrok : $TOTAL_REPOS_SCAN_COUNT" >> $BUILD_MAIL
echo " " >> $BUILD_MAIL

for REPOSITORY in `cat $REPOSITORY_NAME_FILE`
#for REPOSITORY in `cat $REPOSITORY_NAME_POC_FILE`
do
	create_update_gitRepos
done

echo "----------------------Updating the Indexes--------------------------"
export PATH="/proj/opengrok/tools/ctags/ctags-5.8/bin:$PATH"
OPENGROK_WEBAPP_CONTEXT=/enm-litp-opengrok OPENGROK_VERBOSE=true  OPENGROK_WEBAPP_CFGADDR="localhost:2423" OPENGROK_INSTANCE_BASE=/var/litp-opengrok /proj/opengrok/tools/opengrok/opengrok-0.12.1.5/bin/OpenGrok  index /proj/opengrok/ENM-LITP-Repos/src/

echo " " >> $BUILD_MAIL
echo " " >> $BUILD_MAIL
echo "Thanks and Best Regards," >> $BUILD_MAIL
echo "ENM DE Infrastructure Team" >> $BUILD_MAIL

mailx -r "jenkins_monitoring@ericsson.com" -s "ENM LITP GIT Repositories for OpenGrok Analysis has been created/updated and Reindexed- ${TODAY_DATE}" $MAIL_USERS <<-EOF
`cat $BUILD_MAIL`
EOF

