#!/bin/bash

set -x
set -e -o pipefail

module load craype-accel-amd-gfx90a
module load rocm/5.2.0
module load cmake/3.23.2
module load gcc/11.2.0
module load git/2.31.1
module load git-lfs/2.11.0
module load cray-python/3.9.7.1
module load cray-mpich/8.1.16

export MPICH_GPU_SUPPORT_ENABLED=1
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:${CRAY_MPICH_ROOTDIR}/gtl/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/cray/pe/mpich/8.1.16/ofi/gnu/9.1/bin/
export LD_LIBRARY_PATH=${CRAY_LD_LIBRARY_PATH}:${LD_LIBRARY_PATH}
mpi_path=/opt/cray/pe/mpich/8.1.16/ofi/gnu/9.1/bin/

echo ${LD_LIBRARY_PATH}

hipcc_path=$(which hipcc)
rocm_path=$(dirname $hipcc_path)/../

home_dir=$(pwd)

crusher_install_dir=/sw/summit/ums/ums010/2022_05/crusher

kokkos_src_dir=${crusher_install_dir}/kokkos/src
kokkos_build_dir=${crusher_install_dir}/kokkos/build_mpi
kokkos_install_dir=${crusher_install_dir}/kokkos/install

vtkm_src_dir=${crusher_install_dir}/vtkm/src
vtkm_build_dir=${crusher_install_dir}/vtkm/build_mpi
vtkm_install_dir=${crusher_install_dir}/vtkm/install

hdf5_src_dir=${crusher_install_dir}/hdf5-1.8.16
hdf5_build_dir=${crusher_install_dir}/hdf5-1.8.16/build_mpi
hdf5_install_dir=${crusher_install_dir}/hdf5-1.8.16/install

conduit_src_dir=${crusher_install_dir}/conduit/src
conduit_build_dir=${crusher_install_dir}/conduit/build_mpi
conduit_install_dir=${crusher_install_dir}/conduit/install

ascent_src_dir=${home_dir}/ascent/src
ascent_build_dir=${home_dir}/ascent/build_mpi
ascent_install_dir=${home_dir}/ascent/install

if false; then
if [ ! -d "${ascent_src_dir}" ]; then
git clone --recursive https://github.com/Alpine-DAV/ascent.git
fi
rm -rf ${ascent_build_dir}
cmake -S ${ascent_src_dir} -B ${ascent_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${ascent_install_dir} \
  -DCMAKE_CXX_COMPILER=amdclang++ \
  -DCMAKE_C_COMPILER=amdclang \
  -DENABLE_MPI=ON \
  -DENABLE_FORTRAN=OFF \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DKOKKOS_DIR=${kokkos_install_dir} \
  -DENABLE_VTKH=ON \
  -DENABLE_TESTS=ON \
  -DENABLE_HIP=OFF \
  -DHIP_CLANG_INCLUDE_PATH=/opt/rocm-5.2.0/include \
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \
  -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
  -DMPI_C_COMPILER=${mpi_path}/mpicc \
  -DCONDUIT_DIR=${conduit_install_dir} \
  -DHDF5_DIR=${hdf5_install_dir} \
  -DVTKM_DIR=${vtkm_install_dir} \

cmake --build ${ascent_build_dir}
cmake --install ${ascent_build_dir}
fi


warpx_src_dir=${home_dir}/WarpX/
warpx_build_dir=${home_dir}/WarpX/build_mpi
warpx_install_dir=${home_dir}/WarpX/install

if true; then
if [ ! -d "${warpx_src_dir}" ]; then
git clone --recursive https://github.com/ECP-WarpX/WarpX.git
fi
#rm -rf ${warpx_build_dir}
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
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DKOKKOS_DIR=${kokkos_install_dir} \
  -DENABLE_VTKH=ON \
  -DENABLE_TESTS=ON \
  -DENABLE_HIP=OFF \
  -DHIP_CLANG_INCLUDE_PATH=/opt/rocm-5.2.0/include \
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \
  -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
  -DMPI_C_COMPILER=${mpi_path}/mpicc \
  -DCONDUIT_DIR=${conduit_install_dir} \
  -DHDF5_DIR=${hdf5_install_dir} \
  -DVTKM_DIR=${vtkm_install_dir} \

cmake --build ${warpx_build_dir}
cmake --install ${warpx_build_dir}
fi
