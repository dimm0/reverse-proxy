#!/bin/bash
## ======================================================================
## This is an example batch script which can be submitted as part of a
## reverse proxy jupyter notebook. This batch script creates the jupyter
## notebook on a compute node, while the start notebook script is used to
## submit this batch script. You should never submit this batch script on
## its own, e.g. `sbatch slurm/jupyterlab.sh`. Don't do that :). You can
## specify this particluar batch script by using the -b flag, e.g.
## ./start-jupyter -b slurm/jupyterlab.sh
## ======================================================================

## You can add your own slurm directives here, but they will override
## anything you gave to the start-jupyter script like the time, partition, etc
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=24

# DO NOT EDIT BELOW THIS LINE
source $start_root/lib/check_available.sh
source $start_root/lib/get_jupyter_port.sh

# Get the comet node's IP (really just the hostname)
IP=$(hostname -s).local
check_available jupyter-lab "Try 'conda install jupyterlab'" || exit 1
jupyter lab --ip $IP --config $config --no-browser &

# the jupyter pid is stored in the variable $!
PORT=$(get_jupyter_port $!)

# redeem the api_token given the untaken port
url='"https://manage.$endpoint/redeemtoken.cgi?token=$api_token&port=$PORT"'

# Redeem the api_token
eval curl $url

# try to remove the config file.
rm $config

# waits for all child processes to complete, which means it waits for the jupyter notebook to be terminated
wait
