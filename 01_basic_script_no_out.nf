process count_words {
    input:
        path word_file
    script:
        """
        cat "$word_file" \
            | tr -s ' ' '\n' \
            | tr -d '[:punct:]' \
            | tr '[:upper:]' '[:lower:]' \
            | sort \
            | uniq -c \
            | sort -n \
            | tail -1 \
            | tr -s ' ' \
            | cut -d ' ' -f 3
        """
}

workflow {
    channel.fromPath("/home/fynn/Documents/Arbeit/CQ-Lehrgänge/260622_NGS/code/assets/slipsum.md") \
        | count_words
}

// python equivalent
// def count_words(word_file):
//     os.system(f"cat '{{word_file}}' | tr -s ' ' '\n' | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -n | tail -1 | tr -s ' ' | cut -d ' ' -f 3")
//
//
// if __name__ == "__main__":
//     count_words("/home/fynn/Documents/Arbeit/CQ-Lehrgänge/260622_NGS/code/assets/slipsum.md")
