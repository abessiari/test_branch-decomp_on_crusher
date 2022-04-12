#!/bin/bash
#SBATCH -A csc340
#SBATCH -J hip-test
#SBATCH -o %x-%j.out
#SBATCH -t 00:30:00
#SBATCH -N 64 

export LC_ALL=C
export DATA_DIR=$PWD/VTKM_DATA
export GTCT_DIR=$PWD/SweepAndMergeSerialOutput
export PATH=$HOME/weber-mpi/vtkm/build/examples/contour_tree_distributed:$PATH

if [ ! -d  $DATA_DIR ]; then
    echo "Error: Directory  $DATA_DIR does not exist!"
    exit 1;
fi;

if [ ! -d  $GTCT_DIR ]; then
    echo "Error: Directory  $DATA_DIR does not exist!"
    exit 1;
fi;

# export DEVICE=Serial
export DEVICE=Kokkos
export NP=$SLURM_NNODES
parts=$(echo "$NP" | awk '{print sqrt($1)}')
time ./testrun_branch_decomposition.sh $parts
echo "Done."
