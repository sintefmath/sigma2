# Running in Docker	

Make sure you have [Docker](https://docker.com) installed on your system. 

## Building the Dockerfile

Since we have not uploaded the Dockerfile to dockerhub, you have to manually build the dockerfile. From this directory, run

    docker build . -t opm_mpi
    
 ## Running the Docker container
 
 Simply run 
 
     docker run --user $(id -u):$(id -g) -it --rm opm_mpi <number of mpi procs>
     
## Changing compiler or MPI type

### Compiler

Default is clang

    docker build . -t opm_mpi --build-arg CC=<compilername> --build-arg CXX=<compilernamec++>
    
### MPI type

Options: MPICH and OPENMPI (capital)

Default is MPICH

    docker build . -t opm_mpi --build-arg MPI_TYPE=OPENMPI