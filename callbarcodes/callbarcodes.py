"""

  Hua Sun
  2024-08-30 v1

  Only run in LSF HPC

"""


import argparse
import os
import re
import pandas as pd

# collect input arguments
parser = argparse.ArgumentParser()

parser.add_argument('-f', '--fdir', type=str, default='', help='10x fastq directory')
parser.add_argument('-n', '--name', type=str, default='name', help='name for output')
parser.add_argument('--ncell', type=int, default=5000, help='set total cell numbers')

parser.add_argument('-t', '--table', type=str, default='', help='data table for run multiple samples')

parser.add_argument('-o', '--outdir', type=str, default='out_trackerbarcodes', help='out dir')

args = parser.parse_args()




def Main():

    path = os.path.dirname(__file__)
    f_config = f'{path}/config.ini'
    src = f'{path}/src'
    f_bsub = f'{path}/src/hpc.bsub.sh'
    script = f'{src}/callBarcodes.sh'

    CheckDir('src', src)
    CheckFile('config', f_config)
    CheckFile('script', script)

    if (args.outdir != '') & (args.outdir != '.'):
        if not os.path.isdir(args.outdir):
            os.mkdir(args.outdir)
    
    if args.table != '':
        PreProcessing_MultipleSamples(f_bsub, script, f_config, args.table, args.outdir)
    else:
        PreProcessing_SingleSample(f_bsub, script, f_config, args.name, args.fdir, args.ncell, args.outdir)
    





"""
    Set Func.
"""

## Check file (absolute path)
def CheckFile(tag, f_path):
    if not os.path.isfile(f_path):
        print(f'[ERROR] The {tag} {f_path} does not exist !')
        exit()

## Check dir (absolute path)
def CheckDir(tag, dir_path):
    if not os.path.isdir(dir_path):
        print(f'[ERROR] The {tag} {dir_path} does not exist !')
        exit()



## PreProcessing_SingleSample
def PreProcessing_SingleSample(f_bsub, script, f_config, name, fq_dir, ncell, outdir):

    if outdir == '':
        outdir = '.'

    #cmd = f'bash {script} -C {f_config} -d {fq_dir} -n {ncell} -O {outdir}'
    cmd = f'sh {f_bsub} 64 8 cb_{name} {script} -C {f_config} -d {fq_dir} -n {ncell} -O {outdir}'
        
    os.system(cmd)




## CallSeqCount_MultipleSamples
def PreProcessing_MultipleSamples(f_bsub, script, f_config, f_table, outdir):

    info = pd.read_csv(f_table, sep='\t', names=['name', 'ncell', 'fq_dir'])

    for index, row in info.iterrows():
        name = row['name']
        ncell = row['ncell']
        fq_dir = row['fq_dir']
        
        print(name, fq_dir)

        outdir_sample = f'{outdir}/{name}'
        cmd = f'sh {f_bsub} 64 8 cb_{name} {script} -C {f_config} -D {fq_dir} -N {ncell} -O {outdir_sample}'
        os.system(cmd)






if __name__ == '__main__':
    Main()



