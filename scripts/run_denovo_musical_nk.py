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
import multiprocessing  

ncores = multiprocessing.cpu_count()  # Get the number of available CPU cores

#  arg parsing
parser = argparse.ArgumentParser(description='Run Musical with user-defined parameters.')
parser.add_argument('--project_title', type=str, default="run_musical", help='Project title')
parser.add_argument('--input_X', type=int, default=0, help='Input matrix name')

parser.add_argument('--min_iters', type=int, default=1000, help='Min Iterations')
parser.add_argument('--max_iters', type=int, default=10000, help='Max Iterations')
parser.add_argument('--n_replicates', type=int,default=20, help = 'Number of Replicates')
parser.add_argument('--range_use',type=int,default=2, help = 'How many NMF components to check other than the NMF indicated one for mvNMF')
args = parser.parse_args()


i = int(args.input_X)
min_iters = int(args.min_iters)
max_iters = int(args.max_iters)
n_replicates = int(args.n_replicates)
range_use = int(args.range_use)
# set dirs
data_dir = "/gpfs/data/courses/aio2025/yb2612/data/musical"
results_dir = "/gpfs/data/courses/aio2025/yb2612/data/results/musical_models"

cancers = ["cesc_X", "brca_X", "ucec_X", "ov_X"]
nmf_componnets = [16, 19, 17, 20]


input_X = cancers[i]
use_components = nmf_componnets[i]
X_path = f"{data_dir}/{input_X}_converted.csv"
X = pd.read_csv(X_path, index_col=0)

print("------------------------------------")
print("Project title:", args.project_title)
print(f"Using {input_X} as input matrix.")
print("------------------------------------")

print("Mutation matrix:")
print(X.head())
print("\nRunning Musical...")
if os.path.exists(f"{results_dir}/{input_X}_new_model.pkl"):
    print(f"Model already exists for {input_X}. Skipping...")
else:
    model = musical.DenovoSig(X, 
                        min_n_components=use_components - range_use, # Minimum number of signatures to test
                        max_n_components=use_components + range_use, # Maximum number of signatures to test
                        init='random', # Initialization method
                        method='mvnmf', # mvnmf or nmf
                        n_replicates=n_replicates, # Number of mvnmf/nmf replicates to run per n_components
                        ncpu=ncores, # Number of CPUs to use
                        min_iter=min_iters,  # jin
                        max_iter=max_iters,  # jin
                        conv_test_freq=100,  # jin
                        mvnmf_lambda_tilde_grid=np.array([1e-10, 1e-9, 1e-8, 1e-7, 1e-6, 1e-5, 1e-4, 1e-3, 1e-2,1e-1,1]),  # jin
                        bootstrap=True, # Whether or not to bootstrap X for each run
                        tol=1e-5, # Tolerance for claiming convergence of mvnmf/nmf
                        verbose=1, # Verbosity of output
                        normalize_X=False # Whether or not to L1 normalize each sample in X before mvnmf/nmf
                        )
    model.fit()

    os.makedirs(results_dir, exist_ok=True)

    print("\nSaving model...")
    with open(f'{results_dir}/{input_X}_new_model.pkl', 'wb') as f:
        pickle.dump(model, f)