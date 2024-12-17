"""

  Hua Sun
  8/28/23 v0.3
  4/6/23 v0.2
    
"""


import argparse
import os
import re
import pandas as pd


parser = argparse.ArgumentParser()
parser.add_argument('-d', '--dir', type=str, default='/research/dept/hart/PI_data_distribution/mackgrp/GSF', help='raw data direction')
parser.add_argument('--atac', type=str, default='', help='snATAC batch folder name')
parser.add_argument('--gex', type=str, default='', help='snRNA batch folder name')
parser.add_argument('-o', '--outfile', type=str, default='10xmultiome.rawfq.table', help='out table')
args = parser.parse_args()


def Main():
    print(args.dir)

    gexDir = f'{args.dir}/{args.gex}'
    atacDir = f'{args.dir}/{args.atac}'

    gex_table = MakeRawdataTable(gexDir)
    atac_table = MakeRawdataTable(atacDir)

    multiome_table = pd.concat([gex_table, atac_table], ignore_index=True)
    multiome_table.to_csv(args.outfile, sep='\t', index=False)





def MakeRawdataTable(raw_dir):
    df = pd.DataFrame(columns=['raw_path','raw_folder','datatype','seq_id','target_path','batch_folder','sample'])

    # read folder
    for folder in os.listdir(raw_dir):
        
        path = f'{raw_dir}/{folder}'
        prefix = FindPrefix(path)

        print(prefix)

        seq_id = ''
        datatype = ''
        if prefix != '':
            #if 'redo' in prefix:
            #    seq_id = re.search(r"(\w+)redo", prefix).group(1)
            if '_GenEx' in prefix:
                seq_id = re.search(r"(\w+)_GenEx", prefix).group(1)
                datatype = 'GeneExp'
            elif '_ATAC' in prefix:
                seq_id = re.search(r"(\w+)_ATAC", prefix).group(1)
                datatype = 'ATAC'
            elif '_snATAC' in prefix:
                seq_id = re.search(r"(\w+)_snATAC", prefix).group(1)
                datatype = 'ATAC'
            else:
                seq_id = re.search(r"(\w+)_", prefix).group(1)
                datatype = '.'
                #print('[ERROR] Not find GenEx or ATAC from data. Please change regular expression from script.')
                #exit()

            #r = {'raw_path':raw_dir, 'raw_folder':folder, 'datatype':datatype, 'target_path':'', 'batch_folder':'', 'seq_id':seq_id, 'sample':''}
            r = {'raw_path':raw_dir, 'raw_folder':folder, 'datatype':datatype, 'seq_id':seq_id, 'target_path':'', 'batch_folder':'', 'sample':''}
            df = df.append(r, ignore_index = True)
        else:
            print('[ERROR] Not find matched sample_id from data. Please change regular expression from script.')
            exit()

    # output
    return df.drop_duplicates()




# Detect prefix from target fastq.gz 
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




