# Directory on Crusher
-/ccs/home/aessiari/proj-shared/crusher
# Warpx Source Code
- Modify GNUmakefile
- USE_OMP   = FALSE   # ?????
- USE_ASCENT_INSITU = TRUE 
# Warpx Build Directory
- /ccs/home/aessiari/proj-shared/crusher/WarpX/build_mpi
# Run "ccmake ." in Warpx Build Directory
- module load rocm/5.2.0.  # This helps with loading the libraries when setting WarpX_COMPUTE to HIP
- module load cmake/3.23.2
# Modify these 
- WarpX_COMPUTE                    HIP
  - AMReX_AMD_ARCH                   gfx90a 
- WarpX_ASCENT                     ON 
   - Ascent_DIR                       /ccs/home/aessiari/proj-shared/crusher/ascent/install/lib/cmake/ascent  
# Notes On CCMake
- Press c to configure after editing entries ...
- / seems to be for searching ...
- e to edit
