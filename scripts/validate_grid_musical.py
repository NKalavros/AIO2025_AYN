print("Importing modules...")
import os
import numpy as np
import scipy.stats as stats
import matplotlib.pyplot as plt
import seaborn as sns
import matplotlib as mpl
import pandas as pd
import time
import scipy as sp
import pickle
import musical
import argparse

#  arg parsing
parser = argparse.ArgumentParser(description='Run Musical refitting with user-defined parameters.')
parser.add_argument('--project_title', type=str, default="validate_grid_musical", help='Project title')
args = parser.parse_args()

# set dirs
data_dir = "/gpfs/data/courses/aio2025/yb2612/data/musical"
results_dir = "/gpfs/data/courses/aio2025/yb2612/results/musical_models"
model_path = f"{results_dir}/{args.project_title}_assign_grid.pkl"

print("------------------------------------")
print("Project title:", args.project_title)
print(f"Using {args.project_title}_assign_grid model.")
print("------------------------------------")

print("Loading model...")
with open(model_path, 'rb') as f:
    model = pickle.load(f)

print("Selecting best grid point...")
model.validate_grid(validate_n_replicates=1, # Number of simulation replicates to perform for each grid point
                    grid_selection_method='pvalue', # Method for selecting the best grid point
                    grid_selection_pvalue_thresh=0.05 # Threshold used for selecting the best grid point
                   )

print("Best grid point:", model.best_grid_point)
print("Thresh_match:", model.thresh_match)
print("Thresh_refit:", model.thresh_refit)

os.makedirs(results_dir, exist_ok=True)

print("\nSaving model...")
with open(f'{results_dir}/{args.project_title}_validate_grid.pkl', 'wb') as f:
    pickle.dump(model, f, pickle.HIGHEST_PROTOCOL)

print(f"Model saved as {results_dir}/{args.project_title}_validate_grid.pkl.")