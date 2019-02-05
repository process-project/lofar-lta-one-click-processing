# LOFAR LTA one click processing

Build and run the Docker image to set up a web service for one click processing of observations from the LOFAR LTA.
Not intended as production level code for PROCESS, but it shows the kind of interface we want for Use  Case 2.
So this web service is intended for demonstration purposes.

Clone the repository and make sure your Docker daemon is running.

`sudo sytemctl start docker` or something similar for Linux and likewise something different for other operating systems.

`cd lofar-lta-one-click-processing`

After downloading ```oracle-instantclient18.3-basic-18.3.0.0.0-1.x86_64.rpm``` from [Oracle](https://www.oracle.com/technetwork/topics/linuxx86-64soft-092277.html) and adding it to the lofar-lta-one-click-processing folder, you can build the Docker image:

`docker build --no-cache -t web_service_image_name .`

This should take ten minutes or so.

You can run the docker image, once you got the config.ini (not provided here for security reasons, but I will provide it upon request) and updated db-config.js with your [LOFAR credentials](https://www.astron.nl/lofarwiki/doku.php?id=public:lta_howto):

`docker run -d -p 2015:2015 -v $PWD/config.ini:/home/config/config.ini -v $PWD/db-config.js:/home/ltacat/server/db-config.js web_service_image_id`

You can also forward ports 5000 and 8000/sessions (though [I was not able to forward the latter](https://github.com/process-project/lofar-lta-one-click-processing/issues/1#issue-406329872)).

`docker ps` will show you the id of the container that is running the web service.

You can also do some logging:

`docker logs -f container_id`

Now you can view observations from the [LOFAR LTA](lta.lofar.eu) by entering
```localhost:2015```
in your browser.

Select an observation by clicking on it. One row is one observation.

A web form pops up. You can start processing (initial calibration) of an observation by clicking on "Submit workflow" at the bottom of the web form. First enter your email adress and a job description. You can proceed processing with default or modified parameters.

Notice that staging of observations is not included here. Therefore, processing (initial calibration) by clicking on "Submit workflow" will time out and nothing will happen unless you have staged the observation. You can stage an observation by visiting the [LOFAR LTA website](https://lta.lofar.eu) or by using a [Python script](https://www.astron.nl/lofarwiki/doku.php?id=public:lta_tricks&s%5B%5D=staging&s%5B%5D=api).
