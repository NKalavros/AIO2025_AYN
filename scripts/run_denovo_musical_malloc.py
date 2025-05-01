"""
Musical Cancer Analysis Profiler
================================
This script adds profiling functionality to track execution time, memory usage,
and potential sticking points in the musical cancer analysis code.
"""

import time
import os
import sys
import tracemalloc
import functools
import pandas as pd
import numpy as np
from memory_profiler import profile as memory_profile
import cProfile
import pstats
import io

def timeit(func):
    """Decorator to measure execution time of functions"""
    @functools.wraps(func)
    def wrapper(*args, **kwargs):
        start_time = time.time()
        print(f"Starting {func.__name__}...")
        result = func(*args, **kwargs)
        end_time = time.time()
        print(f"Completed {func.__name__} in {end_time - start_time:.2f} seconds")
        return result
    return wrapper

def profile_musical_analysis(script_path, args_list=None):
    """
    Profile the musical analysis script
    
    Parameters:
    -----------
    script_path : str
        Path to the musical analysis script
    args_list : list
        Command line arguments to pass to the script
    """
    # Start memory tracking
    tracemalloc.start()
    
    # Setup profiler
    profiler = cProfile.Profile()
    profiler.enable()
    
    # Create mock environment for the script
    if args_list is None:
        args_list = ['--project_title', 'profiler_run', '--input_X', 'cesc_X']
    
    # Save original sys.argv
    original_argv = sys.argv.copy()
    
    try:
        # Replace sys.argv with our arguments
        sys.argv = [script_path] + args_list
        
        # Create mock directories and files if they don't exist
        data_dir = "./mock_data"
        results_dir = "./mock_results"
        os.makedirs(data_dir, exist_ok=True)
        os.makedirs(results_dir, exist_ok=True)
        
        # Create a small mock dataset if needed
        input_X = args_list[3] if len(args_list) > 3 else 'cesc_X'
        mock_file = f"{data_dir}/{input_X}_converted.csv"
        
        if not os.path.exists(mock_file):
            # Create a small mock dataset
            mock_data = pd.DataFrame(
                np.random.randint(0, 100, size=(100, 96)),
                columns=[f"Feature_{i}" for i in range(96)]
            )
            mock_data.to_csv(mock_file)
            print(f"Created mock dataset: {mock_file}")
        
        # Create a custom version of the musical module if it's not available
        if 'musical' not in sys.modules:
            print("Musical module not found. Creating mock version...")
            
            class MockDenovoSig:
                def __init__(self, X, **kwargs):
                    self.X = X
                    self.params = kwargs
                    print("Initialized MockDenovoSig with parameters:")
                    for k, v in kwargs.items():
                        print(f"  {k}: {v}")
                
                @timeit
                def fit(self):
                    """Mock fit method with delay to simulate computation"""
                    print("Running mock fitting process...")
                    # Simulate computation time based on data size and parameters
                    n_samples, n_features = self.X.shape
                    max_iter = self.params.get('max_iter', 1000)
                    n_replicates = self.params.get('n_replicates', 1)
                    n_components = self.params.get('max_n_components', 10)
                    
                    # Simulate heavy computation
                    simulation_factor = min(0.001, 10 / (n_samples * n_features))
                    estimated_time = n_samples * n_features * n_components * n_replicates * simulation_factor
                    
                    print(f"Simulating computation for approximately {estimated_time:.2f} seconds")
                    
                    # Progress updates
                    steps = 10
                    for i in range(steps):
                        time.sleep(estimated_time / steps)
                        print(f"Fitting progress: {(i+1)*100/steps:.0f}%")
                    
                    print("Fit complete!")
                    return self
            
            # Create mock musical module
            class MockMusical:
                DenovoSig = MockDenovoSig
            
            # Add to sys.modules
            sys.modules['musical'] = MockMusical
            print("Mock musical module created")
        
        # Prepare environment patch
        env_patch = {
            'data_dir': data_dir,
            'results_dir': results_dir
        }
        
        # Execute the script with profiling
        print(f"Starting profiling of {script_path}")
        print("=" * 50)
        
        # Execute in modified global namespace
        with open(script_path, 'r') as f:
            script_content = f.read()
        
        # Fix indentation in the script content if needed
        # This assumes the indentation issue starts after the line with cancers = ...
        lines = script_content.split('\n')
        fixed_lines = []
        
        in_for_loop = False
        for line in lines:
            if "cancers = " in line:
                fixed_lines.append(line)
                in_for_loop = True
            elif in_for_loop and line.strip() and not line.startswith(" "):
                # Fix indentation for lines in the for loop
                fixed_lines.append("    " + line)
            else:
                fixed_lines.append(line)
        
        fixed_script = '\n'.join(fixed_lines)
        
        # Prepare global namespace
        globals_dict = {
            **globals(),
            **env_patch
        }
        
        # Execute the fixed script
        exec(fixed_script, globals_dict)
        
        print("=" * 50)
        print("Execution completed")
        
    except Exception as e:
        print(f"Error during execution: {e}")
        print("Stack trace:")
        import traceback
        traceback.print_exc()
    
    finally:
        # Restore original sys.argv
        sys.argv = original_argv
        
        # Stop profiling
        profiler.disable()
        
        # Print profiling results
        s = io.StringIO()
        ps = pstats.Stats(profiler, stream=s).sort_stats('cumulative')
        ps.print_stats(20)  # Top 20 functions by cumulative time
        print("Profiling Results:")
        print(s.getvalue())
        
        # Print memory usage
        current, peak = tracemalloc.get_traced_memory()
        print(f"Current memory usage: {current / 10**6:.2f} MB")
        print(f"Peak memory usage: {peak / 10**6:.2f} MB")
        tracemalloc.stop()

if __name__ == "__main__":
    # Check if a script path was provided
    if len(sys.argv) > 1:
        script_path = sys.argv[1]
        args_list = sys.argv[2:] if len(sys.argv) > 2 else None
        profile_musical_analysis(script_path, args_list)
    else:
        print("Usage: python profiler.py <path_to_script> [script_args...]")
        print("Example: python profiler.py musical_analysis.py --project_title test_run --input_X cesc_X")

# Usage instructions:
# 1. Save the original code to a file (e.g., musical_analysis.py)
# 2. Run this profiler with: python profiler.py musical_analysis.py
# 3. Review the output to identify bottlenecks and sticking points