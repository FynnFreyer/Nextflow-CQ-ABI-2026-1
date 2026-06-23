include { count_words } from './03_modules_script_modularized'
include { clean_counts as clean_most } from './03_modules_script_modularized'
include { clean_counts as clean_least } from './03_modules_script_modularized'

// input -- path to a dir with .fq.gz sample files
// params.in = null

params {
    in: String = null
}

process most_common_word {
    input:
        path word_counts
    output:
        path "most_common_word.txt"
    script:
        """
        cat "$word_counts" \\
            | tail -1 \\
        > most_common_word.txt
        """
}

process least_common_word {
    input:
        path word_counts
    output:
        path "least_common_word.txt"
    script:
        """
        cat "$word_counts" \\
            | head -1 \\
        > least_common_word.txt
        """
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
