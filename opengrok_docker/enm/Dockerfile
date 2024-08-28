#CBO Image and Image version
ARG CBO_IMAGE_URL=armdocker.rnd.ericsson.se/proj-ldc/common_base_os_release/sles
ARG CBO_VERSION=6.12.0-13
FROM ${CBO_IMAGE_URL}:${CBO_VERSION}
ARG CBO_VERSION
ARG CBO_REPO=arm.rnd.ki.sw.ericsson.se/artifactory/proj-ldc-repo-rpm-local/common_base_os/sles/

#Installing dependencies
RUN zypper addrepo --gpgcheck-strict -f https://${CBO_REPO}${CBO_VERSION} \
    COMMON_BASE_OS_SLES_REPO \
    && zypper --gpg-auto-import-keys refresh \
    && zypper install -l -y curl \
    && zypper clean --all
RUN zypper install -y python311 java-17-openjdk zip unzip wget python311-pip git-core openssh

#Creating a tmp directory to unzip opengrok files
RUN mkdir /tmp_opengrok
WORKDIR /tmp_opengrok
RUN wget https://github.com/oracle/opengrok/releases/download/1.13.7/opengrok-1.13.7.tar.gz
RUN tar -xvf opengrok-1.13.7.tar.gz \
    && rm opengrok-1.13.7.tar.gz \
    && mkdir tmp_source_war \
    && cp ./opengrok-1.13.7/lib/source.war ./tmp_source_war

#Adding config files and executable permissions
RUN mkdir /opengrok-proj
ADD /config/. /opengrok-proj/config/
RUN chmod -R +x /opengrok-proj/config

#Zip the forbidden, web.xml with war file to lib folder
WORKDIR /tmp_opengrok/tmp_source_war/
RUN unzip source.war \
    #Could possibly write this to the file to start with
    && sed -i -e '/A wicked fast source browser<\/description>/r/opengrok-proj/config/xml/enm_web_xml_update_for_idm' ./WEB-INF/web.xml \
    && zip -u source.war WEB-INF/web.xml \
    && cp /opengrok-proj/config/eforbidden.jsp .
RUN zip -u  source.war eforbidden.jsp \
    && cp source.war ../opengrok-1.13.7/lib/

#Unzip opengrok folders into opengrok directory
WORKDIR /tmp_opengrok
RUN rm -rf tmp_source_war/ \
    && tar -czvf opengrok_enm.tar.gz opengrok-1.13.7/ \
    && mkdir -p /opengrok-proj/opengrok /opengrok-proj/opengrok/etc /opengrok-proj/opengrok/data /opengrok-proj/opengrok/src \
    && tar -zxvf /tmp_opengrok/opengrok_enm.tar.gz -C /opengrok-proj/opengrok --strip-components 1 \
    && python3.11 -m pip install --no-cache-dir /opengrok-proj/opengrok/tools/opengrok-tools.tar.gz \
    && python3.11 -m pip install --no-cache-dir schedule \
    && python3.11 -m pip install --no-cache-dir Flask Flask-HTTPAuth waitress

#git
RUN git config --global --add safe.directory '*'

#ctags
RUN wget https://github.com/universal-ctags/ctags-nightly-build/releases/download/2024.04.08%2B2c1b63c589bbd04f388f054cf22de2ead9f8c9ae/uctags-2024.04.08-1.fc39.x86_64.rpm \
    && rpm -i uctags-2024.04.08-1.fc39.x86_64.rpm

#Tomcat version 10.1.24
RUN wget https://arm1s11-eiffel004.eiffel.gic.ericsson.se:8443/nexus/service/local/repositories/3pptools/content/com/ericsson/3ppinternal/tomcat/10.1.24/tomcat-10.1.24.gz \
    && tar -xvf tomcat-10.1.24.gz --directory /tmp \
    && sed -i -e '/<\/Realm>/r/opengrok-proj/config/xml/tomcat_conf_update' /tmp/apache-tomcat-10.1.24/conf/server.xml \
    && sed -i -e '/maxParameterCount=\"1000\"/r/opengrok-proj/config/xml/tomcat_conf_update_max_header' /tmp/apache-tomcat-10.1.24/conf/server.xml \
    && cp -r /tmp/apache-tomcat-10.1.24 /usr/local/tomcat

#Disable all file logging
COPY /config/logging.properties /usr/local/tomcat/conf/logging.properties

RUN chmod -R 777 /usr/local/tomcat/

#Add our scripts and give permissions (Docker runs scripts from root so that's where ssh keys need to be)
COPY scripts /opengrok-proj/scripts
RUN chmod -R +x /opengrok-proj/scripts

#Run
WORKDIR $CATALINA_HOME
EXPOSE 8080
CMD ["/opengrok-proj/scripts/start.py"]
