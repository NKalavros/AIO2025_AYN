print("Importing modules...")
import argparse
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
import os

#  arg parsing
parser = argparse.ArgumentParser(description='Run Musical with user-defined parameters.')
parser.add_argument('--project_title', type=str, default="run_musical", help='Project title')
parser.add_argument('--input_X', type=str, default="X", help='Input matrix name')
args = parser.parse_args()

# set dirs
data_dir = "/gpfs/home/yb2612/aio2025/yb2612/data/musical"
results_dir = "/gpfs/home/yb2612/aio2025/yb2612/results/musical_models"
X_path = f"{data_dir}/{args.input_X}.csv"
X = pd.read_csv(X_path, index_col=0)

print("------------------------------------")
print("Project title:", args.project_title)
print(f"Using {args.input_X} as input matrix.")
print("------------------------------------")

print("Mutation matrix:")
print(X.head())

print("\nRunning Musical...")
model = musical.DenovoSig(X, 
                          min_n_components=14, # Minimum number of signatures to test
                          max_n_components=18, # Maximum number of signatures to test
                          init='random', # Initialization method
                          method='mvnmf', # mvnmf or nmf
                          n_replicates=20, # Number of mvnmf/nmf replicates to run per n_components
                          ncpu=20, # Number of CPUs to use
                          min_iter=1000,  # jin
                          max_iter=10000,  # jin
                          conv_test_freq=100,  # jin
                          mvnmf_lambda_tilde_grid=np.array([1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2, 1e-1, 1.0]),  # jin
                          bootstrap=True, # Whether or not to bootstrap X for each run
                          tol=1e-5, # Tolerance for claiming convergence of mvnmf/nmf
                          verbose=1, # Verbosity of output
                          normalize_X=False # Whether or not to L1 normalize each sample in X before mvnmf/nmf
                         )
model.fit()

os.makedirs(results_dir, exist_ok=True)

print("\nSaving model...")
with open(f'{results_dir}/{args.project_title}.pkl', 'wb') as f:
    pickle.dump(model, f, pickle.HIGHEST_PROTOCOL)

print(f"Model saved as {results_dir}/{args.project_title}.pkl.")