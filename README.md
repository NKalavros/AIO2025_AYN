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
1. De novo signature discovery: [run_denovo_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/run_denovo_musical.py)
2. Assign signatures on 2D threshold grid: [assign_grid_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/assign_grid_musical.py)
3. Select best thresholds: [validate_grid_musical.py](https://github.com/yumibriones/AIO2025_AYN/blob/main/scripts/validate_grid_musical.py)
