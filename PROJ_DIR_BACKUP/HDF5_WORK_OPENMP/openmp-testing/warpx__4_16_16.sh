#!/bin/bash
#SBATCH -A csc340
#SBATCH -J warpx__4
#SBATCH -t 00:30:00
#SBATCH --mail-user=aessiari@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -N 4

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
device=Serial
#device=Kokkos
#device=OPENMP

nNodes=4
nThreads=16
nRanks=16
export OMP_NUM_THREADS=16
export OMP_PLACES=cores
export OMP_PROC_BIND=true
blocksPerDim="16,1,1"

output_dir=${output_base_dir}/warpx_data00008000_E_x_6791x371x371_unchunked_${nNodes}_nodes_${nRanks}_ranks_${blocksPerDim}_blocksPerDim_${nThreads}_threadsPerBlock_${device}_device_${SLURM_JOB_ID}_jobid
mkdir -p ${output_dir}
cd ${output_dir}
#srun -n ${nRanks} -c ${nThreads} --cpu_bind=core ${executable} --vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --blocksPerDim=${blocksPerDim} $EXTRA_OPTIONS --dataset=${dataset} ${dataset_path}
${executable} --vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --blocksPerDim=${blocksPerDim} $EXTRA_OPTIONS --dataset=${dataset} ${dataset_path}
exit 0


# Run
nRanks=32
dataset_path=/project/projectdirs/alpine/oruebel/data_hdf/warpx_data00008000_E_x_6791x371x371_unchunked.h5
dataset=data
blocksPerDim="32,1,1"
output_dir=${output_base_dir}/warpx_data00008000_E_x_6791x371x371_unchunked_${nNodes}_nodes_${nRanks}_ranks_${blocksPerDim}_blocksPerDim_${nThreads}_threadsPerBlock_${device}_device_${SLURM_JOB_ID}_jobid
mkdir ${output_dir}
cd ${output_dir}
jobname=warpx__32_4_OPENMP
echo "Running="${jobname}
srun -n ${nRanks} -c ${nThreads} --cpu_bind=cores --job-name=${jobname} ${executable} --vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --blocksPerDim=${blocksPerDim} --dataset=${dataset} ${dataset_path}




export OMP_NUM_THREADS=16
# Place on cores / threads
export OMP_PLACES=cores
# Use lock threads to a core
export OMP_PROC_BIND=true
dataset=data
device=OPENMP
blocksPerDim="16,1,1"
output_dir=${output_base_dir}/warpx_data00008000_E_x_6791x371x371_unchunked_${nNodes}_nodes_${nRanks}_ranks_${blocksPerDim}_blocksPerDim_${nThreads}_threadsPerBlock_${device}_device_${SLURM_JOB_ID}_jobid
mkdir ${output_dir}
cd ${output_dir}
jobname=warpx__16_4_OPENMP
echo "Running="${jobname}
srun -n ${nRanks} -c ${nThreads} --cpu_bind=cores --job-name=${jobname} ${executable} --vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --blocksPerDim=${blocksPerDim} --dataset=${dataset} ${dataset_path}
