#!/bin/bash

module load git-lfs
module load cmake

home_dir=${PWD}
vtkm_src_dir=${home_dir}/vtkm/src
vtkm_build_dir=${home_dir}/vtkm/build-gcc-fix
vtkm_install_dir=${home_dir}/vtkm/install-gcc-fix

# -- The C compiler identification is Clang 14.0.0
# -- The CXX compiler identification is Clang 14.0.0
# -- Cray Programming Environment 2.7.15 C
# -- Found MPI_C: /opt/cray/pe/craype/2.7.15/bin/cc (found version "3.1")
# -- Found MPI_CXX: /opt/cray/pe/craype/2.7.15/bin/CC (found version "3.1")
# -- Found MPI: TRUE (found version "3.1")

cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_ENABLE_KOKKOS=OFF \
  -DVTKm_ENABLE_RENDERING=OFF \
  -DVTKm_ENABLE_TESTING=OFF \
  -DVTKm_ENABLE_BENCHMARKS=OFF \
  -DVTKm_ENABLE_EXAMPLES=ON \
  -DVTKM_EXAMPLE_CONTOURTREE_ENABLE_DEBUG_PRINT=OFF \
  -DVTKm_ENABLE_MPI=ON \
  -DCMAKE_INSTALL_PREFIX=${vtkm_install_dir} \
  -DCMAKE_VERBOSE_MAKEFILE=ON 

cmake --build ${vtkm_build_dir} -j10
