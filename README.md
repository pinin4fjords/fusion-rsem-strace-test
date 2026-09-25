# fusion-rsem-strace-test

Throwaway diagnostic pipeline. Runs `rsem-parse-alignments` under `strace -c -f` on a subset
of a real nf-core/rnaseq megatest transcriptome BAM, to compare per-syscall write latency on a
Fusion-mounted (S3-backed FUSE) work directory vs a plain S3-staged (local disk) work directory.

Created to investigate https://github.com/nf-core/rnaseq/issues/1957. Safe to delete once the
investigation concludes.
