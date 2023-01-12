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

vtkm_src_dir=${home_dir}/vtk-m
vtkm_build_dir=${home_dir}/vtk-m/build-openmp-debinfo
vtkm_install_dir=${home_dir}/vtk-m/install-openmp

module load cray-mpich
module load cray-hdf5-parallel/1.12.1.1

# -DCMAKE_BUILD_TYPE=Release \
if true; then
#rm -rf ${vtkm_build_dir}
cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_BUILD_TYPE=RelWithDebInfo \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_TESTING=OFF \
  -DVTKm_ENABLE_BENCHMARKS=OFF \
  -DCMAKE_HIP_ARCHITECTURES="gfx90a" \
  -DVTKm_ENABLE_MPI=ON \
  -DCMAKE_PREFIX_PATH="${kokkos_install_dir}" \
  -DCMAKE_INSTALL_PREFIX=${vtkm_install_dir} \
  -DCMAKE_CXX_COMPILER=${rocm_path}/llvm/bin/clang++ \
  -DCMAKE_C_COMPILER=${rocm_path}/llvm/bin/clang \
  -DVTKm_ENABLE_RENDERING:BOOL=ON \
  -DVTKm_ENABLE_EXAMPLES=ON \
  -DVTKm_Vectorization:STRING=native \
  -DVTKm_ENABLE_HDF5_IO:BOOL=ON \
  -DHDF5_DIR=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0 \
  -DHDF5_DIFF_EXECUTABLE:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/bin/h5diff \
  -DHDF5_INCLUDE_DIR:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/include \
  -DHDF5_INCLUDE_DIRS:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/include \
  -DHDF5_CXX_INCLUDE_DIR:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/include \
  -DHDF5_C_INCLUDE_DIR:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/include \
  -DHDF5_hdf5_LIBRARY_RELEASE:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/lib/libhdf5.so \
  -DHDF5_hdf5_cpp_LIBRARY_RELEASE:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/lib/libhdf5.so \
  -DHDF5_hdf5_hl_LIBRARY_RELEASE:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/lib/libhdf5.so \
  -DHDF5_hdf5_hl_cpp_LIBRARY_RELEASE:STRING=/opt/cray/pe/hdf5-parallel/1.12.1.1/crayclang/10.0/lib/libhdf5.so \
  -DCMAKE_VERBOSE_MAKEFILE=ON

echo cmake --build ${vtkm_build_dir} -j2
fi
