# docker_azure_function

## docker command

# build and create image

1. docker build -t image_name .

# create and run container

1. docker run --name container_name --volume local_project_path:container_path -d -p 8033:80 image_name
