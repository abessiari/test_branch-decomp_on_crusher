# Test Branch Decoposioosition On Crusher

Run BranchDecomposition tests using Kokkos device and test output against SweepAndMergeSerial outputs.

## Requirements
  - git-lfs
  - Build Kokos
  - Build VTKM (Weber for now)
  - see sample build_scripts

## Launch

```
sbatch batch_test_branch-decomposition.sh
```

## Monitor

```
squeue -l -u <user_name>
tail -F hip-*.out
```
## Results

```
ls -l out
```
