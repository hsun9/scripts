"""
  Hua Sun
"""


import argparse
import os
import re
import pandas as pd

# collect input arguments
parser = argparse.ArgumentParser()
parser.add_argument('-l', '--library', type=str, default='', help='cellranger-arc input')
parser.add_argument('-n', '--name', type=str, default='name', help='name for output')
parser.add_argument('-r', '--ref', type=str, default='mm10', help='reference')
parser.add_argument('-t', '--table', type=str, default='', help='data table for run multiple samples')
parser.add_argument('-o', '--outdir', type=str, default='.', help='out dir')

args = parser.parse_args()




def Main():
    pipeline = args.pipeline
    cluster = args.cluster

    pipeline_items = ['arc', 'seurat', 'test']
    if not pipeline in pipeline_items:
        print(f'[ERROR] Please set -p as one of {pipeline_items}')
        exit()

    path = os.path.dirname(__file__)
    fconfig = f'{path}/config.ini'
    fbsub = f'{path}/hpc.bsub.sh'
    fscript = f'{path}/cellrangerARC.count.sh'

    CheckFile('hpc.bsub', fbsub)
    CheckFile('script', fscript)
    CheckFile('config', fconfig)

    if (args.outdir != '') & (args.outdir != '.'):
        if not os.path.isdir(args.outdir):
            os.mkdir(args.outdir)
    
    # cellranger-arc count
    if args.table != '':
        CellrangerARC_Count_Multiple(fbsub, fscript, fconfig, args.table, args.outdir)
    else:
        CellrangerARC_Count(fbsub, fscript, fconfig, args.ref, args.name, args.library, args.outdir)
    
    



"""
    Set Func.
"""

## Check file (absolute path)
def CheckFile(tag, f_path):
    if not os.path.isfile(f_path):
        print(f'[ERROR] The {tag} {f_path} does not exist !')
        exit()



## Cellranger-arc count
def CellrangerARC_Count(fbsub, fscript, fconfig, ref, name, library, outdir):
    if outdir == '':
        outdir = '.'

    #cmd = f'sh {fbsub} 32 8 arc_{name} bash {script} -C {fconfig} -R lsf -G {ref} -L {library} -N {name} -O {outdir}'
    cmd = f'sh {fbsub} 64 16 arc_{name} bash {script} -C {fconfig} -R local -G {ref} -L {library} -N {name} -O {outdir}'
        
    os.system(cmd)



## Cellranger-arc count for multiple samples
def CellrangerARC_Count_Multiple(fbsub, fscript, fconfig, ftable, outdir):
    info = pd.read_csv(ftable, sep='\t', names=['ref', 'name', 'library'])

    for index, row in info.iterrows():
        ref = row['ref']
        name = row['name']
        name = name.replace('.', '_')
        library = row['library']
        
        print(ref, name, library)

        cmd = f'sh {fbsub} 64 16 arc_{name} bash {script} -C {fconfig} -R local -G {ref} -L {library} -N {name} -O {outdir}'
        os.system(cmd)




if __name__ == '__main__':
    Main()



