# Run UC2 (frontend) from a docker container 

Build and run the Docker image to set up a web service for one click processing of observations from the LOFAR LTA.
So this web service is intended for demonstration purposes and not intended as production level code for PROCESS.

Clone the repository and make sure your Docker daemon is running.

`sudo sytemctl start docker` or something similar for Linux and likewise something different for other operating systems.

`cd lofar-lta-one-click-processing` or whatever name given at cloning.

There are a couple of files (tools, configuration and secrets) which are required in order to successfully build the Docker image. 
First, after downloading ```oracle-instantclient19.8-basic-19.8.0.0.0-1.x86_64.rpm``` from [Oracle](https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html), add it to the lofar-lta-one-click-processing folder.
Then, provide a configuration file for each pipeline to run. Currently, there are only two, `UC2_pipeline` (execution via xenon-flow) and `LOFAR_IEE_pipeline` (execution via IEE). So, provide `config_xe.json` and `config_iee.json` respectively.
For `UC2_pipeline`, one also needs the xenon-flow configuration in `config.yml` and the SSH keys for accessing the computing site to be used (`id_rsa` and `known_hosts`).

 Once all the above is in place, one can build the Docker image by issuying:

`docker build --no-cache -t web_service_image_name .`

This should take a dozen minutes or so.

You can run the docker image, once you got the config.ini (not provided here for security reasons, but I will provide it upon request) and updated db-config.js with your [LOFAR credentials](https://www.astron.nl/lofarwiki/doku.php?id=public:lta_howto):

`docker run -d -p 2015:2015 -v $PWD/config.ini:/home/config/config.ini -v $PWD/db-config.js:/home/ltacat/server/db-config.js web_service_image_id`

You can also forward ports 5000 and 8000/sessions (though [I was not able to forward the latter](https://github.com/process-project/lofar-lta-one-click-processing/issues/1#issue-406329872)).

`docker ps` will show you the id of the container that is running the web service.

You can also do some logging:

`docker logs -f container_id`

Now you can view observations from the [LOFAR LTA](lta.lofar.eu) by entering
```localhost:2015```
in your browser.

Select the calibrator and target observations by checking them in. One row is one observation.

A web form pops up. You can start processing (both initial pre-facet calibration and direction-dependent calibration and imaging) of an observation by clicking on "Submit workflow" at the bottom of the web form. First enter your email adress and a job description. You can proceed processing with default or modified parameters.

Both implemented pipelines include data staging and transfer to the selected compute site using `LOBCDER` data services. `UC2_pipeline` uses directly the said services while `LOFAR_IEE_pipeline` delegates that to `LOBCDER` itself.

