#!/bin/bash
#SBATCH -A csc340
#SBATCH -J gto_32
#SBATCH -t 02:00:00
#SBATCH --mail-user=aessiari@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -N 32 

set -ex

EXTRA_OPTIONS="--augmentHierarchicalTree --computeVolumeBranchDecomposition"
# executable=/ccs/home/aessiari/proj-shared/gtopo/vtk-m/build/examples/contour_tree_distributed/ContourTree_Distributed 
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm-5.2.0/llvm/lib
executable=/ccs/home/aessiari/proj-shared/hdf5/vtk-m/build-openmp/examples/contour_tree_distributed/ContourTree_Distributed
ls -l ${executable}
output_base_dir=/ccs/home/aessiari/proj-shared/gtopo-testing/results
mkdir -p $output_base_dir
device=Kokkos

x=16
y=16

nRanks=$((x * y))
nNodes=$((nRanks / 8))
dataset=gtopo_full_${x}x${y}
dataset_path=/ccs/home/aessiari/proj-shared/gtopo_data/gtopo/${dataset}/gtopo_full_part_%d_of_${nRanks}.txt

output_dir=${output_base_dir}/${dataset}_${nNodes}_nodes_${nRanks}_ranks_${device}_device_${SLURM_JOB_ID}_jobid
mkdir ${output_dir}
cd ${output_dir}

srun -n ${nRanks} -c 1 --gpus-per-task=1 --gpu-bind=closest ${executable} \
	--vtkm-log-level INFO --vtkm-device ${device} --forwardSummary --preSplitFiles \
       	$EXTRA_OPTIONS --numBlocks=${nRanks} ${dataset_path}
exit 0
