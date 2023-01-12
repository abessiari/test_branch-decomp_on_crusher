#!/bin/bash
#SBATCH -A csc340
#SBATCH -J gto_4
#SBATCH -t 02:00:00
#SBATCH --mail-user=aessiari@lbl.gov
#SBATCH --mail-type=ALL
#SBATCH -N 4 

set -ex

#EXTRA_OPTIONS="--augmentHierarchicalTree --computeVolumeBranchDecomposition"
export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:/opt/rocm-5.2.0/llvm/lib
executable=/ccs/home/aessiari/proj-shared/VTKM_MASTER/vtkm/build/examples/contour_tree_distributed/ContourTree_Distributed
output_base_dir=/ccs/home/aessiari/proj-shared/VTKM_MASTER/results/no-augmentation

ls -l ${executable}
mkdir -p $output_base_dir
device=Serial

x=4
y=8

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
