# required dependencies
module load cmake/3.22.2
module load craype-accel-amd-gfx90a
module load rocm/5.1.0
#module load rocm/5.2.0
module load cray-mpich

# we want conduit to use this
module load cray-hdf5-parallel/1.12.1.1

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

hipcc_path=$(which hipcc)
ROCM_PATH=$(dirname $hipcc_path)/..

# compiler environment hints
export CC=$(which cc)
export CXX=$(which CC)
export FC=$(which ftn)
export CFLAGS="-I${ROCM_PATH}/include"
export CXXFLAGS="-I${ROCM_PATH}/include -Wno-pass-failed"
export LDFLAGS="-L${ROCM_PATH}/lib -lamdhip64"


root_dir=$(pwd)


git clone https://github.com/ECP-WarpX/WarpX.git
cd WarpX
rm -rf build

export ASCENT_DIR=${root_dir}/ascent-v0.9.0-pre/install/
export KOKKOS_DIR=${root_dir}/kokkos-3.6.01/install/
cmake -S . -B build -DCMAKE_PREFIX_PATH="${ASCENT_DIR};${KOKKOS_DIR}" -DWarpX_ASCENT=ON -DWarpX_DIMS=3 -DWarpX_COMPUTE=HIP
cmake --build build -j 10





