#!/usr/bin/env nextflow

params {
    reference
    data
    outdir = "out"
    file_pattern = "*_{,R}{1,2}*.fq.gz"
}

process fetch_reference {
    publishDir "$params.outdir/reference"

    conda "bioconda::entrez-direct=24.0"
    container "https://depot.galaxyproject.org/singularity/entrez-direct:24.0--he881be0_0"

    input:
        val accession
    output:
        path "${accession}.fasta"
    script:
        """
        esearch -db nucleotide -query "$accession" | efetch -format fasta > "${accession}.fasta"
        """
}

process trim {
    publishDir "$params.outdir/trimmed"

    conda "bioconda::fastp=1.0.1"
    container "https://depot.galaxyproject.org/singularity/fastp:1.0.1--heae3180_0"

    input:
        tuple val(sample_id), path(samples)
    output:
        tuple val(sample_id), path("${sample_id}_R{1,2}.trim.fq.gz")
    
    script:
        def args = task.ext.args ?: ""
        def forward = samples[0]
        def reverse = samples[1]
        """
        fastp $args \\
            --in1 "${forward}" \\
            --in2 "${reverse}" \\
            --out1 "${sample_id}_R1.trim.fq.gz" \\
            --out2 "${sample_id}_R2.trim.fq.gz"
        """
}

process mapping {
    conda "bioconda::bwa=0.7.19"
    container "https://depot.galaxyproject.org/singularity/bwa:0.7.19--h577a1d6_1"

    input:
        tuple val(sample_id), path(samples)
        path reference

    output:
        tuple val(sample_id), path("${sample_id}.sam")
    
    script:
        def args = task.ext.args ?: ""
        def forward = samples[0]
        def reverse = samples[1]
        """
        bwa index "$reference"
        bwa mem "$reference" "$forward" "$reverse" > "${sample_id}.sam"
        """
}

process fastqc {
    publishDir "$params.outdir/qc"

    conda "bioconda::fastqc=0.12.1"
    container "https://depot.galaxyproject.org/singularity/fastqc:0.12.1--hdfd78af_0"

    input:
        tuple val(sample_id), path(samples)

    output:
        tuple val(sample_id), path("${sample_id}.qc.tgz")
    
    script:
        def args = task.ext.args ?: ""
        def forward = samples[0]
        def reverse = samples[1]
        """
        mkdir "$sample_id/"
        fastqc $args "$forward" "$reverse" -o "$sample_id/"
        tar czvf "${sample_id}.qc.tgz" "$sample_id/"
        """
}

process index_alns {
    publishDir "$params.outdir/alns"

    conda "bioconda::samtools=1.6"
    container "https://depot.galaxyproject.org/singularity/samtools:1.6--h5fe306e_12"

    input:
        tuple val(sample_id), path(sam)

    output:
        tuple val(sample_id), path("${sample_id}.bam")
        tuple val(sample_id), path("${sample_id}.bai")
    
    script:
        """
        samtools view -h -b "$sam" \\
            | samtools sort -O bam  \\
        > "${sample_id}.bam"

        samtools index -b "${sample_id}.bam" "${sample_id}.bai"
        """
}

workflow {
    def ch_ref = fetch_reference(params.reference)
    def ch_samples = channel.fromFilePairs("$params.data/$params.file_pattern")
    def ch_trim = trim(ch_samples)
    def ch_qc_trim = fastqc(ch_trim)
    def ch_alns = mapping(ch_trim, ch_ref) | index_alns
}
