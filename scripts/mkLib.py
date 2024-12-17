"""

  Hua Sun
  1/3/2023

"""


import argparse
import os
import re

# collect input arguments
parser = argparse.ArgumentParser()

parser.add_argument('-d', '--dir', type=str, required=True, help='data direction')
parser.add_argument('-o', '--outdir', type=str, default='out_lib', help='out dir')

args = parser.parse_args()


def Main():
    s_dir = args.dir
    outdir = args.outdir
    if not os.path.isdir(outdir):
        os.mkdir(outdir)
    
    header = 'fastqs,sample,library_type'
    gex = ''
    atac = ''

    # read folder
    for folder in os.listdir(s_dir):
        if 'gex' in folder:
            path = f'{s_dir}/{folder}'
            prefix = FindPrefix(path)

            if prefix != '':
                gex = f'{args.dir}/{folder},{prefix},Gene Expression'
            else:
                print('[ERROR] Not find matched prefix from gex.* data. Please change regular expression from script.')
                exit()

        if 'atac' in folder:
            path = f'{s_dir}/{folder}'
            prefix = FindPrefix(path)

            if prefix != '':
                atac = f'{args.dir}/{folder},{prefix},Chromatin Accessibility'
            else:
                print('[ERROR] Not find matched prefix from atac.* data. Please change regular expression from script.')
                exit()


    # output
    folder_name = os.path.basename(s_dir)
    with open(os.path.join(outdir, f'libraries.{folder_name}.csv'), 'w') as f:
        f.write(f'{header}\n')
        f.write(f'{gex}\n')
        f.write(f'{atac}\n')



def FindPrefix(path):
    prefix = ''
    for f in os.listdir(path):
        if os.path.isfile(os.path.join(path, f)) and len(re.findall(r"_S\d+_L\d+_I1_\d+.fastq.gz", f)) > 0 :
            prefix = re.search(r"(\w+)_S\d+_L\d+_I1_\d+.fastq.gz", f)

    if prefix:
        return prefix.group(1)
    else:
        return ''
    
    





if __name__ == '__main__':
    Main()



