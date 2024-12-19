dir=''
genome=''

## getOptions
while getopts "d:g:" opt; do
  case $opt in
    d)
      dir=$OPTARG
      ;;
    g)
      genome=$OPTARG
      ;;
    :)
      echo "Option -$OPTARG requires an argument." >&2
      exit 1
      ;;
  esac
done


# make library file for multiple samples
ls $dir | while read x; do python3 ~/scripts/mkLib.py -d $dir/$x -o info; done
ls info/*.csv | while read f; do sample=`echo $f | perl -ne 'print $1 if /libraries.([\w\.\-]+)\.csv/'`; perl -e 'print "'$genome'\t'$sample'\t'`pwd`/$f'\n"'; done > info/mergedLibaryInfo.table
