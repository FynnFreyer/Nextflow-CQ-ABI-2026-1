#!/usr/bin/env nextflow

include { count_words } from './modules/utils.nf'
include { clean_counts as clean_most } from './modules/utils.nf'
include { clean_counts as clean_least } from './modules/utils.nf'

// input -- path to a dir with .fq.gz sample files
params.in = null

process most_common_word {
    input:
        path word_counts
    output:
        path "${most_common_word_file}.txt"
    script:
        most_common_word_file = "${word_counts.name}.most"
        """
        cat "$word_counts" \\
            | tail -1 \\
        > "${most_common_word_file}.txt"
        """
}

process least_common_word {
    input:
        path word_counts
    output:
        path "${least_common_word_file}.txt"
    script:
        least_common_word_file = "${word_counts.name}.least"
        """
        cat "$word_counts" \\
            | head -1 \\
        > "${least_common_word_file}.txt"
        """
}

process do_mapping {
    input:
        path sample
        path reference
    script:
        """
        bwa index "$reference"
        bwa mem "$reference" "$sample" > "${sample.name}.aln.sam"
        """
}

process get_common_word {
    input:
        path word_counts
        val type
    output:
        path "${least_common_word_file}.txt"
    script:
        if (type == "least") {
            least_common_word_file = "${word_counts.name}.least"
            """
            cat "$word_counts" \\
                | head -1 \\
            > "${least_common_word_file}.txt"
            """
        } else {
            most_common_word_file = "${word_counts.name}.most"
            """
            cat "$word_counts" \\
                | head -1 \\
            > "${most_common_word_file}.txt"
            """
        }
}

workflow {
    ch_counts = channel.fromPath(params.in) | count_words
    ch_counts.view()

    ch_least = least_common_word(ch_counts)
    ch_least.view()

    ch_least_cleaned = ch_least | clean_least
    ch_least_cleaned.view()

    ch_most = most_common_word(ch_counts)
    ch_most.view()

    ch_most_cleaned = ch_most | clean_most
    ch_most_cleaned.view()
}
