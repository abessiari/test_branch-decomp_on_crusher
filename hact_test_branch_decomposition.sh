#!/bin/sh
np=${NP:-64}
DEVICE=${DEVICE:-Kokkos}

RED=""
GREEN=""
NC=""
if [ -t 1 ]; then
# If stdout is a terminal, color Pass and FAIL green and red, respectively
    RED=$(tput setaf 1)
    GREEN=$(tput setaf 2)
    NC=$(tput sgr0)
fi

echo "Copying target file "$1 "into current directory"
filename=${1##*/}
fileroot=${filename%.txt}

out_dir=out/$DEVICE/$np/$fileroot
rm -rf $out_dir; mkdir -p $out_dir;
cd $out_dir

cp $1 ${filename}

echo "Splitting data into "$2" x "$2" parts"
split_data_2d.py ${filename} $2

echo "Running HACT"
n_parts=$(($2*$2))

#echo srun -n$np -c1 --gpus-per-task=1 --gpu-bind=closest ContourTree_Distributed --vtkm-device $DEVICE --preSplitFiles --saveOutputData --augmentHierarchicalTree --computeVolumeBranchDecomposition --numBlocks=${n_parts} ${fileroot}_part_%d_of_${n_parts}.txt

#srun -n$np -c1 --gpus-per-task=1 --gpu-bind=closest ContourTree_Distributed --vtkm-device $DEVICE --preSplitFiles --saveOutputData --augmentHierarchicalTree --computeVolumeBranchDecomposition --numBlocks=${n_parts} ${fileroot}_part_%d_of_${n_parts}.txt

echo srun -n$np ContourTree_Distributed --vtkm-device $DEVICE --preSplitFiles --saveOutputData --augmentHierarchicalTree --computeVolumeBranchDecomposition --numBlocks=${n_parts} ${fileroot}_part_%d_of_${n_parts}.txt
srun -n$np ContourTree_Distributed --vtkm-device $DEVICE --preSplitFiles --saveOutputData --augmentHierarchicalTree --computeVolumeBranchDecomposition --numBlocks=${n_parts} ${fileroot}_part_%d_of_${n_parts}.txt

mkdir extras
mkdir results

echo "Final Outputs"
sort -u BranchDecomposition_Rank_*.txt > results/this.txt
sort ${GTCT_DIR}/branch_decomposition_volume_hybrid_${fileroot}.txt > results/other.txt
diff results/this.txt results/other.txt > extras/diff.txt

mkdir logs
mv *.log logs/

if test -s extras/diff.txt; then echo "STATUS:${fileroot}:${RED}FAIL${NC}"; else echo "STATUS:${fileroot}:${GREEN}PASS${NC}"; fi;

if test -s extras/diff.txt; then
       	echo "STATUS:${fileroot}:${RED}FAIL${NC}" > extras/status_code.txt; 
else 
	echo "STATUS:${fileroot}:${GREEN}PASS${NC}" > extras/status_code.txt; 
fi;

echo "Intermediate Outputs"
sort -u BranchDecompositionIntermediate_Rank_*.txt | BranchCompiler | sort -u > results/bcompile.txt

diff results/bcompile.txt results/other.txt > extras/bcompile_diff.txt

if test -s extras/bcompile_diff.txt; then echo "COMPILER_STATUS:${fileroot}:${RED}FAIL${NC}"; else echo "COMPILER_STATUS:${fileroot}:${GREEN}PASS${NC}"; fi;

if test -s extras/bcompile_diff.txt; then
       	echo "COMPILER_STATUS:${fileroot}:${RED}FAIL${NC}" >> extras/status_code.txt;
else
	echo "COMPILER_STATUS:${fileroot}:${GREEN}PASS${NC}" >> extras/status_code.txt;
fi;
