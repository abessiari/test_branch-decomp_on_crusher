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

kokkos_src_dir=${home_dir}/kokkos/src
kokkos_build_dir=${home_dir}/kokkos/build_mpi
kokkos_install_dir=${home_dir}/kokkos/install

if false; then
if [ ! -d "${kokkos_src_dir}" ]; then
git clone -b master https://github.com/kokkos/kokkos.git ${kokkos_src_dir}
fi
rm -rf ${kokkos_build_dir}
cmake -S ${kokkos_src_dir} -B ${kokkos_build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DKokkos_ARCH_VEGA90A=ON \
  -DCMAKE_CXX_COMPILER=${rocm_path}/bin/hipcc \
  -DCRAYPE_LINK_TYPE=dynamic \
  -DKokkos_ENABLE_HIP=ON \
  -DKokkos_ENABLE_SERIAL=ON \
  -DKokkos_ENABLE_MPI=ON \
  -DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=OFF \
  -DCMAKE_INSTALL_PREFIX=${kokkos_install_dir} \
  -DCMAKE_CXX_FLAGS="--amdgpu-target=gfx90a"
cmake --build ${kokkos_build_dir} 
cmake --install ${kokkos_build_dir}
fi

cd ${home_dir}

vtkm_src_dir=${home_dir}/vtkm/src
vtkm_build_dir=${home_dir}/vtkm/build_mpi
vtkm_install_dir=${home_dir}/vtkm/install

if false; then
if [ ! -d "${vtkm_src_dir}" ]; then
git-lfs clone -b master https://gitlab.kitware.com/vtk/vtk-m.git ${vtkm_src_dir}
fi
cd ${vtkm_src_dir} && git checkout 7749b86b225f78ea0e95d053c1a8a11cc67be49a && cd ${home_dir}
rm -rf ${vtkm_build_dir}
cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=OFF\
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_USE_64BIT_IDS=OFF \
  -DVTKm_USE_DOUBLE_PRECISION=ON \
  -DVTKm_USE_DEFAULT_TYPES_FOR_ASCENT=ON \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_MPI=ON \
  -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
  -DMPI_C_COMPILER=${mpi_path}/mpicc \
  -DVTKm_ENABLE_RENDERING=ON \
  -DVTKm_ENABLE_TESTING=OFF \
  -DBUILD_TESTING=OFF \
  -DVTKm_ENABLE_EXAMPLES=ON \
  -DVTKm_ENABLE_BENCHMARKS=OFF\
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DCMAKE_INSTALL_PREFIX=${vtkm_install_dir} \
  -DCMAKE_HIP_COMPILER_TOOLKIT_ROOT=${rocm_path}\
  -DCMAKE_CXX_COMPILER=amdclang++ \
  -DCMAKE_C_COMPILER=amdclang

cmake --build ${vtkm_build_dir} -j2 
cmake --install ${vtkm_build_dir}
fi

cd ${home_dir}

hdf5_src_dir=${home_dir}/hdf5-1.8.16
hdf5_build_dir=${home_dir}/hdf5-1.8.16/build_mpi
hdf5_install_dir=${home_dir}/hdf5-1.8.16/install

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
  -DCMAKE_CXX_COMPILER=amdclang++ \
  -DCMAKE_C_COMPILER=amdclang \
  -DENABLE_MPI=ON

cmake --build ${hdf5_build_dir}
cmake --install ${hdf5_build_dir}
fi

cd ${home_dir}

conduit_src_dir=${home_dir}/conduit/src
conduit_build_dir=${home_dir}/conduit/build_mpi
conduit_install_dir=${home_dir}/conduit/install

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
  -DENABLE_PYTHON=ON \
  -DENABLE_HDF5=ON \
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \
  -DMPI_CXX_COMPILER=${mpi_path}/mpicxx \
  -DMPI_C_COMPILER=${mpi_path}/mpicc \
  -DHDF5_DIR=${hdf5_install_dir} \
  -DCMAKE_CXX_COMPILER=amdclang++ \
  -DCMAKE_C_COMPILER=amdclang

cmake --build ${conduit_build_dir}
cmake --install ${conduit_build_dir}
fi

cd ${home_dir}

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

cd ${home_dir}

amrwind_src_dir=${home_dir}/amr-wind/
amrwind_build_dir=${home_dir}/amr-wind/build
amrwind_install_dir=${home_dir}/amr-wind/install

if true; then
#git clone --recursive https://github.com/Alpine-DAV/amrwind.git
#rm -rf ${amrwind_build_dir}
cmake -S ${amrwind_src_dir} -B ${amrwind_build_dir} \
  -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON\
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_INSTALL_PREFIX=${amrwind_install_dir} \
  -DCMAKE_CXX_COMPILER=amdclang++ \
  -DCMAKE_C_COMPILER=amdclang \
  -DENABLE_MPI=OFF \
  -DENABLE_FORTRAN=OFF \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DKOKKOS_DIR=${kokkos_install_dir} \
  -DENABLE_TESTS=OFF \
  -DPYTHON_EXECUTABLE=/opt/cray/pe/python/3.9.4.2/bin/python \
  -DCONDUIT_DIR=${conduit_install_dir} \
  -DHDF5_DIR=${hdf5_dir} \
  -DAMR_WIND_ENABLE_TESTS:BOOL=ON  \
  -DAMR_WIND_ENABLE_ASCENT:BOOL=ON \
  -DAscent_DIR:PATH=${ascent_install_dir}/lib/cmake/ascent/ \
  -DConduit_DIR:PATH=${conduit_install_dir}

cmake --build ${amrwind_build_dir}
cmake --install ${amrwind_build_dir}
fi
