FROM phusion/baseimage:0.11

#Install all necessary global packages

# install python 3.5
RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get -y install python3.5

RUN apt-get update && apt-get install -y \
    git\
    software-properties-common \
    python3-pip \
    curl \
&&  curl -sL https://deb.nodesource.com/setup_8.x | bash -   \
&&  apt-get -y install nodejs \
    libaio1 \
    alien \
&&  curl https://getcaddy.com | bash -s personal
RUN pip3 install pipenv

#the oracle db stuff
#copy the  rpm file from host to container
COPY oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm .
#install oracle db
RUN alien -i oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm 
#set search path for  oracledb
ENV LD_LIBRARY_PATH=/usr/lib/oracle/18.3/client64/lib/
#set symlinks for shared objects of oracle stuff
RUN  cd /usr/lib/oracle/18.3/client64/lib/ && ln -s libclntsh.so.18.1 libclntsh.so && ln -s libocci.so.18.1 libocci.so 

#LOFAR_WORKFLOW_API

#create woring directory
WORKDIR /home/LOFAR_api
#set environment variables
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
#clone lofar_api
RUN git clone https://github.com/process-project/lofar_workflow_api.git \
&& cd lofar_workflow_api && pipenv install

#LTACAT

WORKDIR ..
#download ltacat 
RUN git clone https://github.com/process-project/ltacat.git 
WORKDIR ltacat/
RUN  npm ci \
&&   npm run webpack

#bitbucket stuff. Should be obsolete, because the lofar_workflow_api Pipfile includes this code.
# WORKDIR ..
# RUN git clone https://bitbucket.org/hspreeuw/eoscpfl-lgppp_lrt_2018/src/master/
# WORKDIR master/
# RUN pip3 install .
# ENV LGPPP_ROOT=/home/master/LRT

# Make a folder for the config file.
RUN mkdir /home/config
ENV PICASCONFIGPATH=/home/config
#Scripts to run three independent daemons on the container managed by phusion
#lorar_workflow_api
RUN mkdir /etc/service/lofarapi
COPY lofarapi.sh /etc/service/lofarapi/run
RUN chmod +x /etc/service/lofarapi/run
#ltcat
RUN mkdir /etc/service/ltcat
COPY ltcat.sh /etc/service/ltcat/run
RUN chmod +x /etc/service/ltcat/run
#caddy
RUN mkdir /etc/service/caddy
COPY caddy.sh /etc/service/caddy/run
RUN chmod +x /etc/service/caddy/run

#expose ports 2015, 5000 and 8000
EXPOSE 2015 5000 8000

CMD ["/sbin/my_init" ]
