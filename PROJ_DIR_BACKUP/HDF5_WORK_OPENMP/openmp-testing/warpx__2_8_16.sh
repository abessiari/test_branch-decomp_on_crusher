#!/bin/bash
#SBATCH -A csc340
#SBATCH -J warpx_2
#SBATCH -t 00:30:00
#SBATCH --mail-user=aessiari@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -N 2

set -x
export HDF5_USE_FILE_LOCKING=FALSE
EXTRA_OPTIONS="--augmentHierarchicalTree --computeVolumeBranchDecomposition"
executable=/ccs/home/aessiari/proj-shared/hdf5/vtk-m/build-openmp-debinfo/examples/contour_tree_distributed/ContourTree_Distributed
output_base_dir=/ccs/home/aessiari/proj-shared/hdf5/results-openmp
mkdir -p $output_base_dir
#/opt/rocm-5.2.0/llvm/lib/libomp.so
#/opt/rocm-5.2.0/llvm/lib-debug/libomp.so
# export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm-5.2.0/llvm/lib
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm-5.2.0/llvm/lib-debug

dataset_path=/ccs/home/aessiari/proj-shared/hdf5/warpx_data00008000_E_x_6791x371x371_unchunked.h5
dataset=data
device=OPENMP

nNodes=2
nThreads=16
nRanks=8
export OMP_NUM_THREADS=16
export OMP_PLACES=cores
export OMP_PROC_BIND=true
blocksPerDim="8,1,1"

output_dir=${output_base_dir}/warpx_data00008000_E_x_6791x371x371_unchunked_${nNodes}_nodes_${nRanks}_ranks_${blocksPerDim}_blocksPerDim_${nThreads}_threadsPerBlock_${device}_device_${SLURM_JOB_ID}_jobid
mkdir -p ${output_dir}
cd ${output_dir}
# srun -n ${nRanks} -c ${nThreads} --cpu_bind=core ${executable} --vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --blocksPerDim=${blocksPerDim} $EXTRA_OPTIONS --dataset=${dataset} ${dataset_path}
srun -n ${nRanks} -c 1 --cpu_bind=core ${executable} --vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --blocksPerDim=${blocksPerDim} $EXTRA_OPTIONS --dataset=${dataset} ${dataset_path}
exit 0
