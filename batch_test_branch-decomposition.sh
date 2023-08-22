#!/bin/bash
#SBATCH -A CSC340_crusher
#SBATCH -J branch-test
#SBATCH -o %x-%j.out
#SBATCH -t 00:30:00
#SBATCH -N 16 

export LC_ALL=C
export GTCT_DIR=$HOME/parallel-peak-pruning/ContourTree/SweepAndMergeSerial/out
export DATA_DIR=$HOME/VTKM_DATA

# export PATH=/ccs/home/aessiari/MIN/KOKKOS/build/vtk-m-min/examples/contour_tree_distributed:$PATH
export PATH=/ccs/home/aessiari/MIN/MPI/build/vtk-m-min/examples/contour_tree_distributed:$PATH

if [ ! -d  $DATA_DIR ]; then
    echo "Error: Directory  $DATA_DIR does not exist!"
    exit 1;
fi;

if [ ! -d  $GTCT_DIR ]; then
    echo "Error: Directory  $DATA_DIR does not exist!"
    exit 1;
fi;

source ~/VTKM_AND_KOKKOS/module.sh 

# export DEVICE=Kokkos
export DEVICE=Serial

export NP=$SLURM_NNODES
parts=$(echo "$NP" | awk '{print sqrt($1)}')
time ./testrun_branch_decomposition.sh $parts
echo "Done."
