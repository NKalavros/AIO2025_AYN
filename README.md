# Assessing mutational signatures in gynecologic cancers

## Gynecologic cancers
* Breast invasive carcinoma (BRCA)
* Cervical squamous cell carcinoma and endocervical adenocarcinoma (CESC)
* Ovarian serous cystadenocarcinoma (OV)
* Uterine corpus endometrial carcinoma (UCEC)

## Signature calling tools
1. SigProfiler (https://github.com/AlexandrovLab/SigProfilerExtractor)
2. MuSiCal (https://github.com/parklab/MuSiCal)
3. SigMA (https://github.com/parklab/SigMA)

## Running MuSiCal
Data prep: [musical_data_prep.ipynb](https://github.com/yumibriones/AIO2025_AYN/blob/main/notebooks/musical_data_prep.ipynb)
1. De novo signature discovery: [run_denovo_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/musical/run_denovo_musical.py)
   * Model saved to `/gpfs/data/courses/aio2025/yb2612/results/musical_models`

2. Assign signatures with 2D threshold grid search: [assign_grid_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/musical/assign_grid_musical.py)
   * Model saved to `/gpfs/data/courses/aio2025/yb2612/results/musical_models`
     * 
   * Signature (W) and exposure (H) matrices with lowest thresholds saved to `/gpfs/data/courses/aio2025/yb2612/results/musical_matrices`
     * Example: `brca_musical_mvnmf_Breast.AdenoCA_W_s_0.0001_0.0001.csv` = sparse signature matrix (W_s) for the BRCA cohort on COSMIC-MuSiCal_v3p2_SBS_WGS restricted to Breast.AdenoCA with matching and refitting thresholds of 0.0001.

3. Select best thresholds: [validate_grid_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/musical/validate_grid_musical.py) (not performed, gets stuck when I run it)
