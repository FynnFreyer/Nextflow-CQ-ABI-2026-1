process count_words {
    input:
        path word_file

    output:
        path "${word_count_file}.txt"

    script:
        word_count_file = "${word_file.getSimpleName()}.counts"
        """
        cat "$word_file" \\
            | tr -s ' ' '\\n' \\
            | tr -d '[:punct:]' \\
            | tr '[:upper:]' '[:lower:]' \\
            | sort \\
            | uniq -c \\
            | sort -n \\
        > "${word_count_file}.txt"
        """
}

process clean_counts {
    input:
        path word_counts

    output:
        path "${clean_count_file}.txt"

    script:
        clean_count_file = "${word_counts.getSimpleName()}.clean"
        """
        cat "$word_counts" \\
            | tr -s ' ' \\
            | cut -d ' ' -f 3 \\
        > "${clean_count_file}.txt"
        """
}
