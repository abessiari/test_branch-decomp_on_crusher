#!/bin/bash

module load git-lfs
module load rocm/5.2.0
module load cmake/3.23.2

hipcc_path=$(which hipcc)
rocm_path=$(dirname $hipcc_path)/../

home_dir=${PWD}

kokkos_src_dir=${home_dir}/kokkos/src
kokkos_build_dir=${home_dir}/kokkos/build
kokkos_install_dir=${home_dir}/kokkos/install

if true; then
if [ ! -d "${kokkos_src_dir}" ]; then
git clone https://github.com/kokkos/kokkos.git ${kokkos_src_dir}
fi
rm -rf ${kokkos_build_dir}

cmake -S ${kokkos_src_dir} -B ${kokkos_build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DKokkos_ARCH_VEGA90A=ON \
  -DCMAKE_CXX_COMPILER=${rocm_path}/bin/hipcc \
  -DKokkos_ENABLE_HIP=ON \
  -DKokkos_ENABLE_SERIAL=ON \
  -DKokkos_ENABLE_HIP_RELOCATABLE_DEVICE_CODE=OFF \
  -DCMAKE_INSTALL_PREFIX=${kokkos_install_dir} \
  -DCRAYPE_LINK_TYPE=dynamic \
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DKokkos_ENABLE_EXAMPLES=OFF \
  -DKokkos_ENABLE_DEBUG=ON \
  -DCMAKE_CXX_FLAGS="--amdgpu-target=gfx90a"

cmake --build ${kokkos_build_dir} -j10
cmake --install ${kokkos_build_dir}
fi
