
library(GetoptLong)
library(this.path)


func <- '1'
rds <- 'sc_celltype_anno.rds'
gene <- ''
fragment <- 'atac_fragments.tsv.gz'
celltypes <- ''

label_id <- ''

outdir <- 'out'

GetoptLong(
    "func=s",         "func",
    "rds=s",          ".rds file",
    "gene=s",         "gene",
    "fragment=s",     "fragment file",
    "celltypes=s",    "celltypes",
    "label_id=s",    "label_id",
    "outdir=s",       "output path"
)

path <- dirname(this.path())
source(paste0(path, '/utils.r'))

dir.create(outdir)

seu_obj <- readRDS(rds)

if (func == '1'){
    FragmentDensityForGene(seu_obj, fragment, gene, celltypes, outdir)
}

if (func == '2'){
    AllMotifs_2D(rds, celltypes, label_id, paste0(outdir, '/allmotif_2d.pdf'))
}



