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
vtkm_build_dir=${home_dir}/vtkm/build-debug
vtkm_install_dir=${home_dir}/vtkm/install-debug
kokkos_install_dir=${home_dir}/kokkos/install

cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_BUILD_TYPE=Debug \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_RENDERING=OFF \
  -DVTKm_ENABLE_TESTING=OFF \
  -DVTKm_ENABLE_BENCHMARKS=OFF \
  -DVTKm_ENABLE_EXAMPLES=ON \
  -DVTKM_EXAMPLE_CONTOURTREE_ENABLE_DEBUG_PRINT=ON \
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DVTKm_ENABLE_MPI=ON \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DCMAKE_INSTALL_PREFIX=${vtkm_install_dir} \
  -DCMAKE_CXX_COMPILER=${rocm_path}/llvm/bin/clang++ \
  -DCMAKE_C_COMPILER=${rocm_path}/llvm/bin/clang \
  -DCMAKE_VERBOSE_MAKEFILE=ON 

cmake --build ${vtkm_build_dir} -j10
