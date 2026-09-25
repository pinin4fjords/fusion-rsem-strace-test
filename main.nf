nextflow.enable.dsl=2

params.outdir = 'results'
params.n_records = 300000

process RSEM_STRACE_TEST {
    container 'community.wave.seqera.io/library/rsem_star:5acb4e8c03239c32'
    publishDir params.outdir, mode: 'copy'
    cpus 2
    memory '8 GB'
    time '30 min'

    output:
    path 'strace_output.txt'
    path 'timing.txt'
    path '.command.trace', optional: true

    script:
    """
    set -euo pipefail
    export DEBIAN_FRONTEND=noninteractive
    apt-get update -qq >/dev/null 2>&1
    apt-get install -y -qq strace >/dev/null 2>&1
    which strace

    BASE="https://nf-core-awsmegatests.s3.eu-west-1.amazonaws.com/work/rnaseq/work-a1fcdddd3b826fe46eb46f0479f2ff8a7815af05"

    echo "Fetching and subsetting input BAM..."
    curl -sL "\$BASE/da/8aeb06b448087b405ccb13e0a36549/K562_REP1.Aligned.toTranscriptome.out.bam" | \\
        samtools view -h - | head -n ${params.n_records} | samtools view -b -o subset.bam -
    ls -la subset.bam

    mkdir -p rsem_index
    for f in genome.grp genome.ti genome.seq genome.chrlist genome.idx.fa genome.n2g.idx.fa genome.transcripts.fa genome.fa; do
        curl -sL "\$BASE/b5/440f6657be677299f0ff67f59fc95d/rsem/\$f" -o "rsem_index/\$f"
    done

    mkdir -p tmp K562_REP1.stat

    echo "n_records: ${params.n_records}" > timing.txt
    echo "n_alignment_records: \$(samtools view -c subset.bam)" >> timing.txt
    echo "subset_bam_bytes: \$(stat -c%s subset.bam)" >> timing.txt
    echo "cwd: \$(pwd)" >> timing.txt
    echo "start_epoch: \$(date +%s.%N)" >> timing.txt

    strace -c -f -o strace_output.txt rsem-parse-alignments rsem_index/genome tmp/K562_REP1 K562_REP1.stat/K562_REP1 subset.bam 3

    echo "end_epoch: \$(date +%s.%N)" >> timing.txt
    df -h . >> timing.txt || true
    mount | grep -i fuse >> timing.txt || true
    """
}

workflow {
    RSEM_STRACE_TEST()
}
