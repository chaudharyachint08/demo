#!/bin/bash

# Succint & Verbose inputs to this script are
# ./work.sh
# ./work.sh -f true -e py3 -g e -d .   -p 8888
# ./work.sh -f true -e py3 -g j -d NSP -p 8008

# Allowing script to detect conda at .bashrc
eval "$(conda shell.bash hook)"

# Assigning command line inputs to appropriate variable
while getopts d:e:f:g:p: flag
do
    case "${flag}" in
        d) directory=${OPTARG};;
        e) env_name=${OPTARG};;
        f) deterministic=${OPTARG};;
        g) gdrive_letter=${OPTARG};;
        p) port=${OPTARG};;
    esac
done

# If deterministic behavior of Python, TF/Keras and CUDA is required
if [ $deterministic ]
then
    echo "Enabling deterministic behavior of TensorFlow framework"
    printf '%.0s\n' {1..2}
    export PYTHONHASHSEED=0
    export TF_DETERMINISTIC_OPS=1
    export TF_CUDNN_DETERMINISTIC=1
fi

# Activating required anaconda environment
if [ $env_name ]
then
    echo "Activating conda environment: $env_name"
    conda activate "$env_name"
    printf '%.0s\n' {1..2}
else
    conda activate py3
fi

# Obtaining correct path for xla_gpu_cuda
if [ $env_name ]
then
    export XLA_FLAGS="--xla_gpu_cuda_data_dir=/home/$USER/anaconda3/envs/$env_name"
else
    export XLA_FLAGS="--xla_gpu_cuda_data_dir=/home/$USER/anaconda3/envs/py3"
fi

# Crafting the required directory based on command line inputs
if [ $gdrive_letter ]
then
    if [ $directory ]
    then
        dir_path="/mnt/$gdrive_letter/My Drive/$directory"
    else
        dir_path="/mnt/$gdrive_letter/My Drive"
    fi
else
    if [ $directory ]
    then
        dir_path="$directory"
    else
        dir_path="$PWD"
    fi
fi
echo "Launching Jupyter at path: $dir_path"
cd "$dir_path"
printf '%.0s\n' {1..2}

# # Available options in Notebook 6.x , shifting to 7.x
# jupyter nbextension enable --py widgetsnbextension
# jupyter serverextension enable --py jupyter_http_over_ws
# python -c "import tensorflow as tf; print(tf.__version__); print(*tf.config.list_physical_devices(None), sep='\n')"

# Launching jupyter if pre-specified port if any
if [ $port ]
then
    echo "Launching Jupyter at port: $port"
    printf '%.0s\n' {1..2}
    jupyter notebook --ServerApp.allow_origin=https://colab.research.google.com --ServerApp.port_retries=0 --no-browser --ServerApp.port="$port"
else
    jupyter notebook --ServerApp.allow_origin=https://colab.research.google.com --ServerApp.port_retries=0 --no-browser
fi

