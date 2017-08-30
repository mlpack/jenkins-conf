A registry is running on masterblaster at port 5000.

The registry is running inside a container. All the images and containers are stored in the /var/lib/docker on the host system (master). But, we have a symlink which points /var/lib/docker to /home/docker on our host system. 
Inside the container, the repositories are stored in /var/lib/registry.


To add an image to the registry, do the following steps:

1. Tag the image to be pushed to the registry

docker tag image-name:version localhost:5000/image-name:version

2. Push the image to the registry

docker push localhost:5000/image-name:version


To pull an image from the registry, do the following steps:

1. To configure the docker client to use registry, follow the url:

https://docs.docker.com/registry/insecure/#deploy-a-plain-http-registry

2. Once step 1 is complete, pull the image on the client

docker pull localhost:5000/image-name:version
