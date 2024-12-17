"""
    Hua Sun
    v0.3  8/28/23

"""


import pandas as pd
import sys
import os
import subprocess

inFile = sys.argv[1]

if not os.path.isfile(inFile):
    print(f'[ERROR] The input file {inFile} does not exist!')
    exit()

print(inFile)

data = pd.read_csv(inFile, sep='\t', usecols=[*range(0,7)])
data.columns = ['r_path', 'r_folder', 'dataType', 's_id', 't_path', 'b_folder', 's_name']

log = []

for r_path, r_folder, dataType, s_id, t_path, b_folder, s_name in zip(data.r_path, data.r_folder, data.dataType, data.s_id, data.t_path, data.b_folder, data.s_name):
    r_dir = f'{r_path}/{r_folder}'
    t_batch_dir = f'{t_path}/{b_folder}'
    sample_dir = f'{t_path}/{b_folder}/{s_name}'

    # remove space
    r_dir = r_dir.replace(" ", "")
    t_batch_dir = t_batch_dir.replace(" ", "")
    sample_dir = sample_dir.replace(" ", "")

    print(s_name)

    # raw dir
    if not os.path.isdir(r_dir):
        print(f'[ERROR] The raw data {r_dir} does not exist!')
        exit()

    # target dir
    if not os.path.isdir(t_batch_dir):
        os.mkdir(t_batch_dir)
    if not os.path.isdir(sample_dir):
        os.mkdir(sample_dir)
    
    # set sub target dir
    t_sub = ''
    if dataType == 'GeneExp':
        t_sub = f'{sample_dir}/gex.{r_folder}'
    if dataType == 'ATAC':
        t_sub = f'{sample_dir}/atac.{r_folder}'


    if os.path.isdir(t_sub):
        print(f'[ERROR] The folder data {t_sub} already exist!')
        exit()

    # copy
    print(f'[INFO] Copying {r_folder} ...')
    os.system(f'cp -r {r_dir} {t_sub}')

    # log
    log.append(f'Data: {r_folder}')
    log.append(subprocess.check_output(f'du -sh {r_dir}', shell=True))
    log.append(subprocess.check_output(f'du -sh {t_sub}', shell=True))
    

# write to log
with open(f'{inFile}.copy.log', 'w') as f:
    for l in log:
        s = str(l)
        s = s.replace("b\'", '')
        s = s.replace('\\t', ' ')
        s = s.replace("\\n\'", '')
        
        f.write(f'{s}\n')
        





