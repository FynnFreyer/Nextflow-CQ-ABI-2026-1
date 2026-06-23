process count_words {
    input:
        path word_file

    output:
        path "word_counts.txt"

    script:
        """
        cat "$word_file" \\
            | tr -s ' ' '\\n' \\
            | tr -d '[:punct:]' \\
            | tr '[:upper:]' '[:lower:]' \\
            | sort \\
            | uniq -c \\
            | sort -n \\
        > word_counts.txt
        """
}

process clean_counts {
    input:
        path word_counts

    output:
        path "clean_words.txt"

    script:
        """
        cat "$word_counts" \\
            | tr -s ' ' \\
            | cut -d ' ' -f 3 \\
        > clean_words.txt
        """
}
