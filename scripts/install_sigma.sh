
mamba install -c conda-forge git-lfs

git lfs install --local --skip-smudge
git clone https://github.com/parklab/SigMA

cd SigMA
git lfs install
git lfs pull
Rscript install.R

Rscript examples/test.R
