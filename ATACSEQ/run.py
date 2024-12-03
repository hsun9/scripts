"""
  Hua Sun
  Raw data processing pipelines in hpc-server
"""


import argparse
import pandas as pd
import yaml
import os

def parse_arguments():
    parser = argparse.ArgumentParser()
    parser.add_argument('-i', '--yaml', default='input.yml', help='input yaml')
    parser.add_argument('-m', '--mem', default=64, help='set hpc memory')
    parser.add_argument('-c', '--core', default=1, help='set hpc core')
    parser.add_argument('-t', '--threads', default=15, help='threads for samtools')
    args = parser.parse_args()
    return args


def main():
    args = parse_arguments()

    cpath = os.path.dirname(__file__)
    fconfig = f'{cpath}/config.ini'
    fbsub = f'{cpath}/hpc.bsub.sh'
    fscript = f'{cpath}/atac.fq2peak.sh'

    with open(args.yaml) as f:
        dyaml = yaml.safe_load(f)

    file = dyaml['table']
    ref = dyaml['ref']
    outdir = dyaml['outdir']

    df = pd.read_csv(file, sep='\t', header=None)
    df.columns = ['sample', 'dir_fq']

    for sample, dir_fq in zip(df['sample'], df['dir_fq']):
        print(f'[INFO] {sample}')
        cmd = f'sh {fbsub} {args.mem} {args.core} {sample} bash {fscript} -C {fconfig} -S {sample} -F {dir_fq} -R {ref} -t {args.threads} -O {outdir}'
        os.system(cmd)




if __name__ == '__main__':
    main()




