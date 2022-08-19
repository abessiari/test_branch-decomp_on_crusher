# Directory on Crusher
-/ccs/home/aessiari/proj-shared/crusher
# Warpx Build Directory
- /ccs/home/aessiari/proj-shared/crusher/WarpX/build_mpi
# Run "ccmake ." in Warpx Build Directory
- module load rocm/5.2.0
- module load cmake/3.23.2
AMReX_AMD_ARCH                   gfx90a 
WarpX_ASCENT                     ON 
WarpX_COMPUTE                    HIP
Ascent_DIR                       /ccs/home/aessiari/proj-shared/crusher/ascent/install/lib/cmake/ascent 
# Press c to configure after editing entries ...
# / seems to be for searching ...
# e to edit
