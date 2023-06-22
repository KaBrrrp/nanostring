process COMPUTE_GENE_SCORES {
    label 'process_single'

    conda "r-nacho=2.0.4 r-tidyverse=2.0.0 r-ggplot2=3.4.2 r-rlang=1.1.1 r-tidylog=1.0.2 r-fs=1.6.2 bioconductor-complexheatmap=2.14.0 r-circlize=0.4.15 r-yaml=2.3.7 r-ragg=1.2.5 r-rcolorbrewer=1.1_3 r-pheatmap=1.0.12"
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/mulled-v2-dfd42984f8ba1b1d0d13648f30430581dff51e82:2a27d1707e91426237b882a7ba5adec8724f9069-0' :
        'biocontainers/mulled-v2-dfd42984f8ba1b1d0d13648f30430581dff51e82:2a27d1707e91426237b882a7ba5adec8724f9069-0' }"

    input:
    path counts
    path geneset_yaml

    output:
    path "*.txt", emit: scores_for_mqc
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''

    """
    compute_gene_scores.R $geneset_yaml $counts $params.gene_score_method

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        r-base: \$(echo \$(R --version 2>&1) | sed 's/^.*R version //; s/ .*\$//')
        r-nacho: \$(Rscript -e "library(NACHO); cat(as.character(packageVersion('NACHO')))")
        r-tidyverse: \$(Rscript -e "library(tidyverse); cat(as.character(packageVersion('tidyverse')))")
        r-fs: \$(Rscript -e "library(fs); cat(as.character(packageVersion('fs')))")
    END_VERSIONS
    """
}
