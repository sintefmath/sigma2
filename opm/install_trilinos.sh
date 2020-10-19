current_dir=$(pwd)
install_dir=$(pwd)/trilinostestinstall

mkdir -p $install_dir
cd $USERWORK
git clone https://github.com/trilinos/Trilinos.git trilinostest
cd trilinostest
git checkout trilinos-release-13-0-0

mkdir -p build
cd build
cmake \
    -DCMAKE_INSTALL_PREFIX=$install_dir \
    -DTPL_ENABLE_MPI:BOOL=ON \
    -DTrilinos_ENABLE_ALL_PACKAGES:BOOL=OFF \
    -DTrilinos_ENABLE_Zoltan:BOOL=ON \
    -DCMAKE_BUILD_TYPE=Release \
    -Wno-dev \
    .. \
    -DMPI_CXX_COMPILER=mpicxx \
    -DMPI_C_COMPILER=mpicc \
    -DMPI_ASSUME_NO_BUILTIN_MPI=ON  

#sed -i 's/\/cluster\/software\/OpenMPI\/4.0.3-GCC-9.3.0\//\/cluster\/software\/impi\/2019.7.217-iccifort-2020.1.217\/intel64\//g' CMakeCache.txt 
#sed -i 's/MPI_C:UNINITIALIZED/MPI_C:PATH/g' CMakeCache.txt 
#sed -i 's/libmpi.so/release_mt\/libmpi.so/g' CMakeCache.txt
#echo MPI_C_WORKS:BOOL=ON >> CMakeCache.txt 
#    -DCMAKE_PREFIX_PATH="${current_dir}/scotch;/cluster/software/impi/2019.7.217-iccifort-2020.1.217/intel64/;/cluster/software/impi/2019.7.217-iccifort-2020.1.217/intel64/lib/release_mt/" \
#    -DTPL_ENABLE_Scotch:BOOL=ON \
make -j $parallel_build_tasks
make install
cd $current_dir
