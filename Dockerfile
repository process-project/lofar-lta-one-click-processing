#FROM ubuntu:18.04
FROM phusion/baseimage:0.11
#FROM phusion/baseimage:bionic-1.0.0
#FROM ubuntu:18.04

#Install all necessary global packages

# install python 3.7
#RUN add-apt-repository -y ppa:deadsnakes/ppa && apt-get -y install python3.7

RUN apt-get update && apt-get install -y \
    git\
    software-properties-common \
    python3-pip \
    curl \
&&  curl -sL https://deb.nodesource.com/setup_8.x | bash -   \
&&  apt-get -y install nodejs \
    libaio1 \
    alien \
    net-tools \
    default-jdk
    
#    alien \
#&&  curl https://getcaddy.com | bash -s personal

RUN pip3 install pipenv

#SM install caddy: above command doesn't seem to work
#RUN echo "deb [trusted=yes] https://apt.fury.io/caddy/ /" \
#    | tee -a /etc/apt/sources.list.d/caddy-fury.list \
#    && apt update \
#    && apt install caddy


#SM: above instructions install and start caddy which is not optimal
#RUN curl -OL "https://github.com/caddyserver/caddy/releases/latest/download/#caddy_2.2.1_linux_amd64.tar.gz" && \
#tar -C /usr/bin/ -xf caddy_2.2.1_linux_amd64.tar.gz caddy
#SM: Don't seem to be able to download non latest versions
RUN curl -OL https://github.com/caddyserver/caddy/releases/download/v2.2.0/caddy_2.2.0_linux_amd64.tar.gz && \
tar -C /usr/bin/ -xf caddy_2.2.0_linux_amd64.tar.gz caddy

RUN groupadd --system caddy
RUN useradd --system \
    --gid caddy \
    --create-home \
    --home-dir /var/lib/caddy \
    --shell /usr/sbin/nologin \
    --comment "Caddy web server" \
    caddy

#the oracle db stuff
#copy the  rpm file from host to container
COPY oracle-instantclient19.8-basic-19.8.0.0.0-1.x86_64.rpm .
#install oracle db
RUN alien -i oracle-instantclient19.8-basic-19.8.0.0.0-1.x86_64.rpm
#set search path for  oracledb
ENV LD_LIBRARY_PATH=/usr/lib/oracle/19.8/client64/lib/
#set symlinks for shared objects of oracle stuff
#RUN  cd /usr/lib/oracle/19.8/client64/lib/ && ln -s libclntsh.so.19.8 libclntsh.so && ln -s libocci.so.19.8 libocci.so 

#LOFAR_WORKFLOW_API

#create working directory
WORKDIR /home/LOFAR_api
#set environment variables
ENV LC_ALL=C.UTF-8
ENV LANG=C.UTF-8
#clone lofar_api
#RUN git clone https://github.com/process-project/UC2_workflow_api.git \
#&& cd UC2_workflow_api && rm Pipfile.lock && pipenv --python /usr/bin/python3.6 install
#SM: testing only
ADD UC2_workflow_api /home/LOFAR_api/UC2_workflow_api
RUN cd UC2_workflow_api && rm Pipfile.lock && pipenv --python /usr/bin/python3.6 install
# SM: copy user pipeline config files into the container
COPY config_xe.json /home/LOFAR_api/
COPY config_iee.json /home/LOFAR_api/
RUN cd /home/LOFAR_api/UC2_workflow_api && VENV="$(pipenv --venv)" \
&& cp /home/LOFAR_api/config_xe.json $VENV/lib/python3.6/site-packages/UC2_pipeline/data/config.json \
&& cp /home/LOFAR_api/config_iee.json $VENV/lib/python3.6/site-packages/LOFAR_IEE_pipeline/data/config.json
#LTACAT

WORKDIR ..
#download ltacat 
#RUN git clone https://github.com/process-project/ltacat_UC2.git  
ADD ltacat_UC2 /home/ltacat_UC2
WORKDIR ltacat_UC2/
RUN  npm ci \
&&   npm run webpack

#xenon-flow
WORKDIR ..
RUN git clone https://github.com/xenon-middleware/xenon-flow.git
RUN cd xenon-flow && git checkout throttle-less
COPY application.properties /home/xenon-flow/config
COPY config.yml /home/xenon-flow/config
ADD id_rsa /root/.ssh/id_rsa
RUN chmod 700 /root/.ssh/id_rsa
ADD known_hosts /root/.ssh/known_hosts
RUN chmod 700 /root/.ssh/known_hosts
COPY echo.cwl /home/xenon-flow
COPY uc2.cwl /home/xenon-flow

#SM: define XDG_CONFIG_HOME for storing Caddy assets such as TLS certificates 
ENV XDG_CONFIG_HOME=/home

# Make a folder for the config file.
RUN mkdir /home/config
ENV PICASCONFIGPATH=/home/config
#Scripts to run three independent daemons on the container managed by phusion
#lofar_workflow_api
RUN mkdir -p /etc/service/lofarapi
COPY lofarapi.sh /etc/service/lofarapi/run
RUN chmod +x /etc/service/lofarapi/run
#ltacat
RUN mkdir -p /etc/service/ltcat
COPY ltcat.sh /etc/service/ltcat/run
RUN chmod +x /etc/service/ltcat/run
#caddy
RUN mkdir -p /etc/service/caddy
COPY caddy.sh /etc/service/caddy/run
RUN chmod +x /etc/service/caddy/run
#xenon-flow
RUN mkdir -p /etc/service/xenonflow
COPY xenonflow.sh /etc/service/xenonflow/run
RUN chmod +x /etc/service/xenonflow/run

#expose ports 2015, 5000 and 8000
EXPOSE 2015 5000 8000 8443

CMD ["/sbin/my_init" ]

