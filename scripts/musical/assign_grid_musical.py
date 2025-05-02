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
parser = argparse.ArgumentParser(description='Assigning signatures with 2D threshold grid search.')
parser.add_argument('--project_title', type=str, default="assign_grid_musical", help='Project title')
parser.add_argument('--tumor_type', type=str, default="", help='Tumor type to restrict the catalog to')
args = parser.parse_args()

# set dirs
data_dir = "/gpfs/data/courses/aio2025/yb2612/data/musical"
results_dir = "/gpfs/data/courses/aio2025/yb2612/results/musical_models"
model_path = f"{results_dir}/{args.project_title}.pkl"

print("------------------------------------")
print("Project title:", args.project_title)
print(f"Using {args.project_title} model with restriction {args.tumor_type}.")
print("------------------------------------")

print("Loading model...")
with open(model_path, 'rb') as f:
    model = pickle.load(f)

# Number of discovered de novo signatures
print("Number of discovered de novo signatures:", model.n_components)

thresh_grid = np.array([
    0.0001, 0.0002, 0.0005,
    0.001, 0.002, 0.005,
    0.01, 0.02, 0.05,
    0.1, 0.2, 0.5,
    1., 2., 5.
])

print("Threshold grid for matching and refitting:", thresh_grid)

catalog = musical.load_catalog('COSMIC-MuSiCal_v3p2_SBS_WGS')
print(f"Restricting catalog to tumor type '{args.tumor_type}'...")
catalog.restrict_catalog(tumor_type=args.tumor_type)
W_catalog = catalog.W
print(W_catalog.shape[1])

print("Assigning grid...")
model.assign_grid(W_catalog, 
                  method_assign='likelihood_bidirectional', # Method for performing matching and refitting
                  thresh_match_grid=thresh_grid, # Grid of threshold for matchinng
                  thresh_refit_grid=thresh_grid, # Grid of threshold for refitting
                  thresh_new_sig=0.0, # De novo signatures with reconstructed cosine similarity below this threshold will be considered novel
                  connected_sigs=False, # Whether or not to force connected signatures to co-occur
                  clean_W_s=True # An optional intermediate step to avoid overfitting to small backgrounds in de novo signatures for 96-channel SBS signatures
                 )

print("Finished assigning grid.")

print("\nSaving model...")
with open(f'{results_dir}/{args.project_title}_{args.tumor_type}_assign_grid.pkl', 'wb') as f:
    pickle.dump(model, f, pickle.HIGHEST_PROTOCOL)

print(f"Model saved as {results_dir}/{args.project_title}_{args.tumor_type}_assign_grid.pkl.")

print("Result with small thresholds:")
print("W:", model.W_s_grid[(0.0001, 0.0001)].shape)
print("H:", model.H_s_grid[(0.0001, 0.0001)].shape)

print("Result with large thresholds:")
print("W:", model.W_s_grid[(1.0, 1.0)].shape)
print("H:", model.H_s_grid[(1.0, 1.0)].shape)