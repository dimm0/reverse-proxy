#!/bin/bash
##
## E X P A N S E
##
## ======================================================================
## This is an example batch script which can be submitted as part of a
## reverse proxy jupyter notebook. This batch script creates the jupyter
## notebook on a compute node, while the start notebook script is used to
## submit this batch script. You should never submit this batch script on
## its own, e.g. `sbatch batch_notebook.sh`. Don't do that :). You can
## specify this particluar batch script by using the -b flag, e.g.
## ./start_notebook.sh -b batch/batch_notebook.sh
## ======================================================================

## You can add your own slurm directives here, but they will override
## anything you gave to the start_notebook script like the time, partition, etc
####SBATCH --partition=compute
#SBATCH --partition=shared
#SBATCH --nodes=1
#SBATCH --ntasks-per-node=1
#SBATCH --export=ALL
#SBATCH -t 00:30:00
#SBATCH -A use300

## Environment
module purge
module load sdsc
module load slurm
#module load cpu
#module load gcc/10.2.0

# DO NOT EDIT BELOW THIS LINE
echo "Batch:: config:  $config"
source $start_root/lib/check_available.sh
source $start_root/lib/get_jupyter_port.sh

# Get the comet node's IP (really just the hostname)
###IP="$(hostname -s).local"
#IP="$(hostname -f).expanse.sdsc.edu"
IP="$(hostname -f)"
echo "Batch:: IP= $IP"

check_available jupyter-notebook "Try 'conda install jupyter'" || exit 1
jupyter notebook --ip $IP --config $config --no-browser &

# the jupyter pid is stored in the variable $!
PORT=$(get_jupyter_port $!)

# redeem the api_token given the untaken port
###url='"https://manage.$cluster-user-content.sdsc.edu/redeemtoken.cgi?token=$api_token&port=$PORT"'
url='"https://manage.expanse-user-content.sdsc.edu/redeemtoken.cgi?token=$api_token&port=$PORT"'
echo "Batch:: url:  $url"

# Redeem the api_token
eval curl $url

# try to remove the config file.
rm $config

# waits for all child processes to complete, which means it waits for the jupyter notebook to be terminated
wait