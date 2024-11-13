"""

  Hua Sun
  2024-08-30 v0.2

"""


import argparse
import os
import re
import pandas as pd

# collect input arguments
parser = argparse.ArgumentParser()
parser.add_argument('-p', '--pipeline', type=str, default='cr', help='pipeline')

parser.add_argument('-f', '--fdir', type=str, default='', help='10x fastq directory')
parser.add_argument('-n', '--name', type=str, default='name', help='name for output')
parser.add_argument('-r', '--ref', type=str, default='mm10', help='reference')

parser.add_argument('-t', '--table', type=str, default='', help='data table for run multiple samples')

parser.add_argument('-o', '--outdir', type=str, default='.', help='out dir')

args = parser.parse_args()




def Main():
    path = os.path.dirname(__file__)
    f_config = f'{path}/config.ini'
    src = f'{path}/src'
    f_bsub = f'{path}/src/hpc.bsub.sh'

    CheckDir('src', src)
    CheckFile('config', f_config)

    if (args.outdir != '') & (args.outdir != '.'):
        if not os.path.isdir(args.outdir):
            os.mkdir(args.outdir)
    

    # set script
    script = SetScript(args.pipeline, src)
    CheckFile('script', script)

    if args.table != '':
        CallSeqCount_MultipleSamples(f_bsub, args.pipeline, f_config, script, args.table, args.outdir)
    else:
        CallSeqCount_SingleSample(f_bsub, args.pipeline, f_config, script, args.ref, args.name, args.fdir, args.outdir)
    

    



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


## Set script
def SetScript(pipeline, src):
    if pipeline == 'cr':
        script = f'{src}/cellranger.count.sh'
    if pipeline == 'cr.3k':
        script = f'{src}/cellranger.count_3k.sh'
    if pipeline == 'cr.5k':
        script = f'{src}/cellranger.count_5k.sh'
    if pipeline == 'cr.8k':
        script = f'{src}/cellranger.count_8k.sh'
    if pipeline == 'cr.chem':
        script = f'{src}/cellranger.count_chem.sh'

    return script



## CallSeqCount_SingleSample
def CallSeqCount_SingleSample(f_bsub, pipeline, f_config, script, ref, name, fq_dir, outdir):

    if outdir == '':
        outdir = '.'

    cmd = f'sh {f_bsub} 64 16 scrna_{name}_{pipeline} bash {script} -C {f_config} -R local -G {ref} -F {fq_dir} -N {name} -O {outdir}'
    os.system(cmd)




## CallSeqCount_MultipleSamples
def CallSeqCount_MultipleSamples(f_bsub, pipeline, f_config, script, f_table, outdir):

    info = pd.read_csv(f_table, sep='\t', names=['ref', 'name', 'fq_dir'])

    for index, row in info.iterrows():
        ref = row['ref']
        name = row['name']
        name = name.replace('.', '_')
        fq_dir = row['fq_dir']
        
        print(ref, name, fq_dir)

        cmd = f'sh {f_bsub} 64 16 scrna_{name}_{pipeline} bash {script} -C {f_config} -R local -G {ref} -F {fq_dir} -N {name} -O {outdir}'
        os.system(cmd)






if __name__ == '__main__':
    Main()



