def VERSION = '1.0.3' // Version information not provided by tool

process AMPLIFY_PREDICT {
    tag "$meta.id"
    label 'process_low'

    conda (params.enable_conda ? "bioconda::amplify=1.0.3" : null)
    container "${ workflow.containerEngine == 'singularity' && !task.ext.singularity_pull_docker_container ?
        'https://depot.galaxyproject.org/singularity/amplify:1.0.3--py36hdfd78af_0':
        'quay.io/biocontainers/amplify:1.0.3--py36hdfd78af_0' }"

    input:
    tuple val(meta), path(faa)
    path(model_dir)

    output:
    tuple val(meta), path('*.tsv'), emit: tsv
    path "versions.yml"           , emit: versions

    when:
    task.ext.when == null || task.ext.when

    script:
    def args = task.ext.args ?: ''
    def prefix = task.ext.prefix ?: "${meta.id}"
    def custom_model_dir = model_dir ? "-md ${model_dir}" : ""
    """
    AMPlify \\
        $args \\
        ${custom_model_dir} \\
        -s '${faa}'

    #rename output, because tool includes date and time in name
    mv *.tsv ${prefix}.tsv

    cat <<-END_VERSIONS > versions.yml
    "${task.process}":
        AMPlify: $VERSION
    END_VERSIONS
    """
}
