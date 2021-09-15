# Simulations used in Mas e Braga et al. (2021) "Nunataks as barriers to ice flow: implications for palaeo ice-sheet reconstructions"

Cheatsheet of the naming of all runs presented in the main text and supplementary material

-Folder `SymIceCap` refers to all irregular mesh simulations
    - subfolder `main` contains experiments presented in the main text
    - subfolder `supplementary` contains experiments presented in the supplementary material
    - subfolder `InputFiles` contains the LR04 curve used to scale the SMB in all experiments. It also contains a scaled version of GRIP and Dome Fuji (DF)
-Folder `RegIceCap` refers to all regular mesh simulations



## Base run codes: format `{AAA}0[xy][*]n`
- `AAA` can either be `spn` (spinup), `dml` (Dronning Maud Land), `tam` (Transantarctic Mountains), or `thw` (Thwaites)
- The letters `[xy]` denote whether the nunatak is elongated along flow (`x`) or transverse to flow (`y`)
- The code `*n` denotes how many nunataks are placed in the domain: 0, 1, or 3. In `0n` runs there is no `0x` or `0y` for obvious reasons

## Three-nunatak runs: `AAA0y3n`
- These runs have `XXkm` added to their naming, where `XX` denotes the spacing between nunataks: 0, 5, 10, or 15 km

## Regular-mesh runs: `{AAA}0[xy][*]n_mshXXkm`
- All regular-mesh runs are grouped in subfolders by their mesh size: `mshXXkm`, where XX denotes the mesh size (5, 10, or 20 km)
- The same convention is followed when identifying their run name (e.g. `thw0y3n05km_msh05km`)
    
## Supplementary material runs
- Runs follow the same format as the `main` runs. Sensitivty tests but have a prefix based on what they test for:    
    - `aXX` stand for the tests where the rheology factor was set to the equivalent of an ice with temperature of -XX degrees Celsius (Fig. S4)
    - `ch` and `cl` stand for "higher sliding coefficient" and "lower sliding coefficient" (Fig. S5)
    - `_vA` stands for experiments where the ice is softer around the nunataks (i.e., the "crevassed" scenario; Figs. S6, S7)
    - `_thk*m` stands for experiments where the minimum ice thickness was set to 0.5 (thk05m) and 5 (thk5m) metres (Fig. S7)
    - `ssmb` and `ssmb2` refer to the SMB runs presented in the supplement (Fig. S8)
    - `ret` stands for experiments using a retrograde bed slope (Fig. S10)    