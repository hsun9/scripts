
library(GetoptLong)

func <- ''
rds <- 'sc_celltype_anno.rds'
gene <- ''
fragment <- ''
celltypes <- ''
outdir <- ''

GetoptLong(
    "rds=s",          ".rds file",
    "region=s",       "region",
    "fragment=s",     "fragment file",
    "celltypes=s",    "celltypes",
    "outdir=s",       "output path"
)

path <- dirname(this.path())
source(paste0(path, '/utils.r'))


seu_obj <- readRDS(rds)

if (func == '1'){
    FragmentDensityForGene(seu_obj, fragment, gene, celltypes, outdir)
}





