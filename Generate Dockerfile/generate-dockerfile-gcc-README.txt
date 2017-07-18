Step 1:
Copy this shell script into a directory.

Step 2:
Run this script with desired versions of armadillo, boost and gcc.

For eg.
./generate-dockerfile-gcc armadillo-x.x.x boost_x_x_x gcc-x.x.x

This will generate a Dockerfile in the directory.

Step 3:
Do a "docker build -t imagetag:version ." and your image will be 
created.