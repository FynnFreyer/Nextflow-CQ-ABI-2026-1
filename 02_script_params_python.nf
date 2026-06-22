// "/home/fynn/Documents/Arbeit/CQ-Lehrgänge/260622_NGS/code/assets/*.md"

// input -- path to a dir with .fq.gz sample files
params.in = null

// classification -- do a classification step
params.classify = false

process most_common_word {
    input:
        path word_file
    output:
        path "most_common_word.txt"
    script:
        """
        cat "$word_file" \\
            | tr -s ' ' '\\n' \\
            | tr -d '[:punct:]' \\
            | tr '[:upper:]' '[:lower:]' \\
            | sort \\
            | uniq -c \\
            | sort -n \\
            | head -1 \\
            | tr -s ' ' \\
            | cut -d ' ' -f 3 \\
        > most_common_word.txt
        """
}

// we can also run other languages than bash
process python_example {
    input:
        path word_file
    output:
        stdout
    script:
        """
        #!/usr/bin/env python

        print("$word_file")
        """
}

workflow {
    if (params.classify) {
        println("do optional classification")
    }

    channel.fromPath(params.in)
        | most_common_word
        | view
}

// python equivalent
// def count_words(word_file):
//     os.system(f"cat '{{word_file}}' | tr -s ' ' '\n' | tr -d '[:punct:]' | tr '[:upper:]' '[:lower:]' | sort | uniq -c | sort -n | tail -1 | tr -s ' ' | cut -d ' ' -f 3")
//
//
// if __name__ == "__main__":
//     count_words("/home/fynn/Documents/Arbeit/CQ-Lehrgänge/260622_NGS/code/assets/slipsum.md")
