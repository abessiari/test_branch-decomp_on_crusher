#!/bin/bash

#
# Builds and installs Ascent w/ VTK-m + HIP Support on Crusher
# Uses WarpX Prefered Modules
#


# required dependencies
module load cmake/3.22.2
module load craype-accel-amd-gfx90a
module load rocm/5.1.0
#module load rocm/5.2.0
module load cray-mpich

# we want conduit to use this
module load cray-hdf5-parallel/1.12.1.1

hipcc_path=$(which hipcc)
rocm_path=$(dirname $hipcc_path)/../

# fix system defaults: do not escape $ with a \ on tab completion
shopt -s direxpand

# an alias to request an interactive batch node for one hour
#   for paralle execution, start on the batch node: srun <command>
alias getNode="salloc -A $proj -J warpx -t 01:00:00 -p batch -N 1 --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest"
# an alias to run a command on a batch node for up to 30min
#   usage: runNode <command>
alias runNode="srun -A $proj -J warpx -t 00:30:00 -p batch -N 1 --ntasks-per-node=8 --gpus-per-task=1 --gpu-bind=closest"

# GPU-aware MPI
export MPICH_GPU_SUPPORT_ENABLED=1

# optimize CUDA compilation for MI250X
export AMREX_AMD_ARCH=gfx90a

# compiler environment hints
export CC=$(which cc)
export CXX=$(which CC)
export FC=$(which ftn)
export CFLAGS="-I${ROCM_PATH}/include"
export CXXFLAGS="-I${ROCM_PATH}/include -Wno-pass-failed"
export LDFLAGS="-L${ROCM_PATH}/lib -lamdhip64"


root_dir=$(pwd)

 
# build conduit 0.8.3

conduit_src_dir=${root_dir}/conduit-v0.8.3/src
conduit_build_dir=${root_dir}/conduit-v0.8.3/build
conduit_install_dir=${root_dir}/conduit-v0.8.3/install
# -DHDF5_DIR=${HDF5_INSTALL_DIR} 
# ABDOU 
if true; then
tar -xvf ${root_dir}/tarballs/conduit-v0.8.3-src-with-blt-cray-fix.tar.gz
cmake -S ${conduit_src_dir} -B ${conduit_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${conduit_install_dir} \
  -DENABLE_FORTRAN=OFF \
  -DCRAYPE_LINK_TYPE=dynamic \
  -DENABLE_MPI=ON \
  -DENABLE_FIND_MPI=OFF \
  -DENABLE_PYTHON=OFF \
  -DENABLE_TESTS=OFF \
  -DHDF5_DIR=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0

cmake --build ${conduit_build_dir} -j6
cmake --install ${conduit_build_dir}

fi

# build kokkos 3.6.01
kokkos_src_dir=${root_dir}/kokkos-3.6.01/
kokkos_build_dir=${root_dir}/kokkos-3.6.01/build
kokkos_install_dir=${root_dir}/kokkos-3.6.01/install


if true; then
tar -xvf ${root_dir}/tarballs/kokkos-3.6.01.tar.gz
rm -rf ${kokkos_build_dir}
cmake -S ${kokkos_src_dir} -B ${kokkos_build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DKokkos_ARCH_VEGA90A=ON \
  -DCMAKE_CXX_COMPILER=${rocm_path}/bin/hipcc \
  -DCRAYPE_LINK_TYPE=dynamic \
  -DKokkos_ENABLE_HIP=ON \
  -DKokkos_ENABLE_SERIAL=ON \
  -DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=OFF \
  -DCMAKE_INSTALL_PREFIX=${kokkos_install_dir} \
  -DCMAKE_CXX_FLAGS="--amdgpu-target=gfx90a"

cmake --build ${kokkos_build_dir} -j6
cmake --install ${kokkos_build_dir}
fi 

# build vtk-m (1.8.0)

vtkm_src_dir=${root_dir}/vtk-m-v1.8.0/
vtkm_build_dir=${root_dir}/vtk-m-v1.8.0/build
vtkm_install_dir=${root_dir}/vtk-m-v1.8.0/install

if true; then 
tar -xvf ${root_dir}/tarballs/vtk-m-v1.8.0.tar.gz
cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF\
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_USE_64BIT_IDS=OFF \
  -DVTKm_USE_DOUBLE_PRECISION=ON \
  -DVTKm_USE_DEFAULT_TYPES_FOR_ASCENT=ON \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_MPI=OFF \
  -DVTKm_ENABLE_RENDERING=ON \
  -DVTKm_ENABLE_TESTING=OFF \
  -DBUILD_TESTING=OFF \
  -DVTKm_ENABLE_BENCHMARKS=OFF\
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DCMAKE_INSTALL_PREFIX=${vtkm_install_dir} \
  -DCMAKE_HIP_COMPILER_TOOLKIT_ROOT=${rocm_path}

cmake --build ${vtkm_build_dir} -j6
cmake --install ${vtkm_build_dir}

fi

# build ascent (and vtk-h)

ascent_src_dir=${root_dir}/ascent-v0.9.0-pre/src
ascent_build_dir=${root_dir}/ascent-v0.9.0-pre/build
ascent_install_dir=${root_dir}/ascent-v0.9.0-pre/install

if true; then
tar -xzvf tarballs/ascent-v0.9.0-pre-vtkm-1.8-branch.tar.gz
cmake -S ${ascent_src_dir} -B ${ascent_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${ascent_install_dir} \
  -DENABLE_MPI=ON \
  -DENABLE_FORTRAN=OFF \
  -DENABLE_FIND_MPI=OFF \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DKOKKOS_DIR=${kokkos_install_dir} \
  -DENABLE_TESTS=ON \
  -DENABLE_PYTHON=OFF \
  -DBLT_CXX_STD=c++14 \
  -DHIP_CLANG_INCLUDE_PATH=/opt/rocm-5.1.0/include \
  -DCMAKE_HIP_FLAGS=-I/opt/cray/pe/mpich/default/ofi/rocm-compiler/5.0/include/ \
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DCONDUIT_DIR=${conduit_install_dir} \
  -DVTKM_DIR=${vtkm_install_dir} \
  -DENABLE_VTKH=ON

cmake --build ${ascent_build_dir} -j6
cmake --install ${ascent_build_dir}
fi

