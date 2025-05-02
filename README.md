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

*See [notebooks/musical_full_pipeline.ipynb](https://github.com/yumibriones/AIO2025_AYN/blob/main/notebooks/musical_full_pipeline.ipynb) for more details on full pipeline and analysis of results.*

0. Prepare input matrices: [musical_data_prep.ipynb](https://github.com/yumibriones/AIO2025_AYN/blob/main/notebooks/musical_data_prep.ipynb)

1. De novo signature discovery: [run_denovo_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/musical/run_denovo_musical.py)

   * Model saved to `/gpfs/data/courses/aio2025/yb2612/results/musical_models`

     * `brca_musical_mvnmf.pkl` = model after running `DenovoSig` for BRCA cohort with `mvnmf`.

3. Assign signatures with 2D threshold grid search: [assign_grid_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/musical/assign_grid_musical.py)

   * Model saved to `/gpfs/data/courses/aio2025/yb2612/results/musical_models`

     * `brca_musical_mvnmf_Breast.AdenoCA_assign_grid.pkl` = model after running `assign_grid` for BRCA cohort on COSMIC-MuSiCal_v3p2_SBS_WGS restricted to Breast.AdenoCA.
     * `brca_musical_mvnmf_assign_grid.pkl` = model after running `assign_grid` for BRCA cohort on entire COSMIC-MuSiCal_v3p2_SBS_WGS with no restriction (can disregard, likely many false positives).

   * Signature (W) and exposure (H) matrices with lowest thresholds saved to `/gpfs/data/courses/aio2025/yb2612/results/musical_matrices`
     * `W`: Signature matrix (features x signatures)
     * `H`: Exposure matrix (signatures x samples)
     * `brca_musical_mvnmf_Breast.AdenoCA_W_s_0.0001_0.0001.csv` = sparse signature matrix (W_s) for the BRCA cohort on COSMIC-MuSiCal_v3p2_SBS_WGS restricted to Breast.AdenoCA with matching and refitting thresholds of 0.0001.
     * The number of signatures seems reasonable when selecting lowest thresholds. However to be sure, we can try the step below.

4. OPTIONAL: Select best thresholds: [validate_grid_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/musical/validate_grid_musical.py)
   
   * Could not perform this step, gets stuck at "Extracting signatures" for 10+ hours.
   * If you want to try this step, run the script using bash as follows:

### CESC
```bash
python -u validate_grid_musical.py --project_title "cesc_musical_mvnmf" --tumor_type 'Cervix.AdenoCA' &
python -u validate_grid_musical.py --project_title "cesc_musical_mvnmf" --tumor_type 'Cervix.SCC'
```

### UCEC
```bash
python -u validate_grid_musical.py --project_title "ucec_musical_mvnmf" --tumor_type 'Uterus.AdenoCA'
```

### OV
```bash
python -u validate_grid_musical.py --project_title "ov_musical_mvnmf" --tumor_type 'Ovary.AdenoCA'
```

### BRCA
```bash
python -u validate_grid_musical.py --project_title "brca_musical_mvnmf" --tumor_type 'Breast.AdenoCA' &
python -u validate_grid_musical.py --project_title "brca_musical_mvnmf" --tumor_type 'Breast.DCIS' &
python -u validate_grid_musical.py --project_title "brca_musical_mvnmf" --tumor_type 'Breast.LobularCA' 
```
  
