#!/bin/bash

module load git-lfs
module load rocm/5.2.0 
module load cmake

hipcc_path=$(which hipcc)
rocm_path=$(dirname $hipcc_path)/..
echo "************"
echo $hipcc_path
echo $rocm_path
echo "************"

home_dir=${PWD}
vtkm_src_dir=${home_dir}/vtkm/src
vtkm_build_dir=${home_dir}/vtkm/build_mpi
vtkm_install_dir=${home_dir}/vtkm/install

if false; then
if [ ! -d "${vtkm_src_dir}" ]; then
git-lfs clone -b master https://gitlab.kitware.com/vtk/vtk-m.git ${vtkm_src_dir}
fi

# cd ${vtkm_src_dir} && git checkout 7749b86b225f78ea0e95d053c1a8a11cc67be49a && cd ${home_dir}
rm -rf ${vtkm_build_dir}

cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_ENABLE_KOKKOS=OFF \
  -DVTKm_ENABLE_RENDERING=ON \
  -DVTKm_ENABLE_TESTING=ON \
  -DVTKm_ENABLE_BENCHMARKS=OFF \
  -DVTKm_ENABLE_EXAMPLES=ON \
  -DVTKM_EXAMPLE_CONTOURTREE_ENABLE_DEBUG_PRINT=OFF \
  -DVTKm_ENABLE_MPI=ON \
  -DCMAKE_INSTALL_PREFIX=${vtkm_install_dir} \
  -DCMAKE_CXX_COMPILER=${rocm_path}/llvm/bin/clang++ \
  -DCMAKE_C_COMPILER=${rocm_path}/llvm/bin/clang \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_USE_64BIT_IDS=OFF \
  -DVTKm_USE_DOUBLE_PRECISION=ON \
  -DVTKm_USE_DEFAULT_TYPES_FOR_ASCENT=ON \

cmake --build ${vtkm_build_dir} -j10
cmake --install ${vtkm_build_dir}
fi

cd ${home_dir}

hdf5_src_dir=${home_dir}/hdf5-1.8.16
hdf5_build_dir=${home_dir}/hdf5-1.8.16/build_mpi
hdf5_install_dir=${home_dir}/hdf5-1.8.16/install
#
# -DCMAKE_CXX_COMPILER=amdclang++ \
#  -DCMAKE_C_COMPILER=amdclang \

if false; then
if [ ! -d "${hdf5_src_dir}" ]; then
curl https://support.hdfgroup.org/ftp/HDF5/releases/hdf5-1.8/hdf5-1.8.16/src/hdf5-1.8.16.tar.gz > hdf5.tar.gz
tar -xzf hdf5.tar.gz
fi
rm -rf ${hdf5_build_dir}
cmake -S ${hdf5_src_dir} -B ${hdf5_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${hdf5_install_dir} \
  -DCMAKE_CXX_COMPILER=${rocm_path}/llvm/bin/clang++ \
  -DCMAKE_C_COMPILER=${rocm_path}/llvm/bin/clang \
  -DENABLE_MPI=ON

cmake --build ${hdf5_build_dir}
cmake --install ${hdf5_build_dir}
fi

cd ${home_dir}

conduit_src_dir=${home_dir}/conduit/src
conduit_build_dir=${home_dir}/conduit/build_mpi
conduit_install_dir=${home_dir}/conduit/install
# -DCMAKE_HIP_ARCHITECTURES="gfx90a" \

module load cray-mpich/8.1.16
mpi_path=/opt/cray/pe/mpich/8.1.16/ofi/gnu/9.1/bin/

#export MPICH_GPU_SUPPORT_ENABLED=1
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CRAY_MPICH_ROOTDIR}/gtl/lib
#export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/pe/mpich/8.1.16/ofi/gnu/9.1/bin/
#export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
#mpi_path=/opt/cray/pe/mpich/8.1.16/ofi/gnu/9.1/bin/
# -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
# -DMPI_C_COMPILER=${mpi_path}/mpicc \
# -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \

if false; then
if [ ! -d "${conduit_src_dir}" ]; then
git clone --recursive https://github.com/LLNL/conduit.git
fi
rm -rf ${conduit_build_dir}
cmake -S ${conduit_src_dir} -B ${conduit_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${conduit_install_dir} \
  -DENABLE_FORTRAN=OFF \
  -DCRAYPE_LINK_TYPE=dynamic \
  -DENABLE_MPI=ON \
  -DENABLE_PYTHON=OFF \
  -DENABLE_HDF5=ON \
  -DHDF5_DIR=${hdf5_install_dir} \
  -DCMAKE_CXX_COMPILER=${rocm_path}/llvm/bin/clang++ \
  -DCMAKE_C_COMPILER=${rocm_path}/llvm/bin/clang \

cmake --build ${conduit_build_dir}
cmake --install ${conduit_build_dir}
fi

cd ${home_dir}

ascent_src_dir=${home_dir}/ascent/src
ascent_build_dir=${home_dir}/ascent/build_mpi
ascent_install_dir=${home_dir}/ascent/install

# -DCMAKE_CXX_COMPILER=amdclang++ \
# -DCMAKE_C_COMPILER=amdclang \
# -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
#  -DKOKKOS_DIR=${kokkos_install_dir} \
# -DHIP_CLANG_INCLUDE_PATH=/opt/rocm-5.2.0/include \
#  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
# -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
# -DMPI_C_COMPILER=${mpi_path}/mpicc \
# -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \

if false; then
if [ ! -d "${ascent_src_dir}" ]; then
# git clone --recursive https://github.com/Alpine-DAV/ascent.git
git clone --recursive git@github.com:abessiari/ascent.git
fi


rm -rf ${ascent_build_dir}
cmake -S ${ascent_src_dir} -B ${ascent_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${ascent_install_dir} \
  -DCMAKE_CXX_COMPILER=${rocm_path}/llvm/bin/clang++ \
  -DCMAKE_C_COMPILER=${rocm_path}/llvm/bin/clang \
  -DENABLE_MPI=ON \
  -DENABLE_FORTRAN=OFF \
  -DENABLE_VTKH=ON \
  -DENABLE_TESTS=ON \
  -DENABLE_HIP=OFF \
  -DENABLE_PYTHON=OFF \
  -DCONDUIT_DIR=${conduit_install_dir} \
  -DHDF5_DIR=${hdf5_install_dir} \
  -DVTKM_DIR=${vtkm_install_dir} \
  -DVTKH_ENABLE_FILTER_CONTOUR_TREE=ON \
  -DVTKm_ENABLE_MPI=ON \
  -DVTKM_ENABLE_MPI=ON \
  -DENABLE_VTKH=ON \
  -DENABLE_CUDA=OFF
cmake --build ${ascent_build_dir} -j2
cmake --install ${ascent_build_dir}
fi

warpx_src_dir=${home_dir}/WarpX/
warpx_build_dir=${home_dir}/WarpX/build_mpi
warpx_install_dir=${home_dir}/WarpX/install

#  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
#  -DKOKKOS_DIR=${kokkos_install_dir} \
# -DCMAKE_HIP_ARCHITECTURES="gfx90a" \

if true; then
if [ ! -d "${warpx_src_dir}" ]; then
git clone --recursive https://github.com/ECP-WarpX/WarpX.git
fi

rm -rf ${warpx_build_dir}
rm -rf ${warpx_install_dir}
cmake -S ${warpx_src_dir} -B ${warpx_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${warpx_install_dir} \
  -DCMAKE_CXX_COMPILER=amdclang++ \
  -DCMAKE_C_COMPILER=amdclang \
  -DENABLE_MPI=ON \
  -DENABLE_FORTRAN=OFF \
  -DUSE_ASCENT_INSITU=TRUE \
  -DASCENT_DIR=${ascent_install_dir}/lib/cmake/ascent \
  -DENABLE_VTKH=ON \
  -DENABLE_TESTS=ON \
  -DENABLE_HIP=ON \
   -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DHIP_CLANG_INCLUDE_PATH=/opt/rocm-5.2.0/include \
  -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \
  -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
  -DMPI_C_COMPILER=${mpi_path}/mpicc \
  -DCONDUIT_DIR=${conduit_install_dir} \
  -DHDF5_DIR=${hdf5_install_dir} \
  -DVTKM_DIR=${vtkm_install_dir} \

#cmake --build ${warpx_build_dir}
#cmake --install ${warpx_build_dir}
fi

exit 0

