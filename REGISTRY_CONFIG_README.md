A registry is running on masterblaster at port 5000.

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
