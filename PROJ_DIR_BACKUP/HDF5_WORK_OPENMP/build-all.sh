#!/bin/bash

module load git-lfs
module load rocm/5.2.0
module load cmake/3.23.2
# module load cmake

hipcc_path=$(which hipcc)
rocm_path=$(dirname $hipcc_path)/../

home_dir=${PWD}

kokkos_src_dir=${home_dir}/kokkos/src
kokkos_build_dir=${home_dir}/kokkos/build
kokkos_install_dir=${home_dir}/kokkos/install

if false; then
if [ ! -d "${kokkos_src_dir}" ]; then
git clone https://github.com/kokkos/kokkos.git ${kokkos_src_dir}
fi
rm -rf ${kokkos_build_dir}

#  -DKokkos_ENABLE_DEBUG_BOUNDS_CHECK=ON \
#  -DKokkos_ENABLE_DEBUG_DUALVIEW_MODIFY_CHECK=ON \
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

cd ${home_dir}

hdf5_src_dir=${home_dir}/hdf5-1.8.16
hdf5_build_dir=${home_dir}/hdf5-1.8.16/build_mpi
hdf5_install_dir=${home_dir}/hdf5-1.8.16/install

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
  -DCMAKE_VERBOSE_MAKEFILE=ON \
  -DENABLE_MPI=ON

cmake --build ${hdf5_build_dir}
cmake --install ${hdf5_build_dir}
fi

vtkm_src_dir=${home_dir}/vtk-m
vtkm_build_dir=${home_dir}/vtk-m/build
vtkm_install_dir=${home_dir}/vtk-m/install

#module load rocm/5.1.0
module load cray-mpich
module load cray-hdf5-parallel/1.12.1.1
# module load cray-hdf5-parallel/1.12.0.7
#module load cray-hdf5/1.12.1.3 
#module load hdf5/1.8.22   

# -DHDF5_DIR=${hdf5_install_dir} \
# -DVTKm_ENABLE_HDF5_IO:BOOL=ON \
# -DHDF5_DIR=${hdf5_install_dir} \
# -DVTKM_EXAMPLE_CONTOURTREE_ENABLE_DEBUG_PRINT=OFF \
#-DVTKm_ENABLE_OSMESA:BOOL=OFF \
# -DHDF5_NO_FIND_PACKAGE_CONFIG_FILE=ON \
# -DHDF5_DIR=${hdf5_install_dir} \

#  -DHDF5_CXX_COMPILER_EXECUTABLE:STRING=/opt/cray/pe/craype/2.7.10/bin/CC
#  -DHDF5_C_COMPILER_EXECUTABLE_NO_INTERROGATE:STRING=/opt/cray/pe/craype/2.7.10/bin/cc

if false; then
rm -rf ${vtkm_build_dir}
cmake -S ${vtkm_src_dir} -B ${vtkm_build_dir} \
  -DCMAKE_BUILD_TYPE=Release \
  -DBUILD_SHARED_LIBS=ON\
  -DVTKm_NO_DEPRECATED_VIRTUAL=ON \
  -DVTKm_ENABLE_KOKKOS=ON \
  -DVTKm_ENABLE_TESTING=ON \
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
#cmake --build ${vtkm_build_dir} -j2
#cmake --install ${vtkm_build_dir}
fi
