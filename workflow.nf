#!/usr/bin/env nextflow

nextflow.enable.dsl=2

params.reads = "$baseDir/data/*.fastq.gz"
params.trimmed = "$baseDir/trimmed"
params.assembled = "$baseDir/assembled"

process TrimFastQReads {
    tag "Trimming ${sample}"

    input:
    path(reads)

    output:
    path("${reads.baseName}_trimmed.fastq") 

    script:
    """
    trimmomatic SE -phred33 \\
        ${reads} \\
        ${reads.baseName}_trimmed.fastq \\
        ILLUMINACLIP:TruSeq3-SE.fa:2:30:10 LEADING:3 TRAILING:3 SLIDINGWINDOW:4:15 MINLEN:36
    """
}

process AssembleFastA {
    tag "Assembling ${sample}"

    input:
    path(trimmed_reads)

    output:
    path("${trimmed_reads.baseName}_assembled")

    script:
    """
    spades.py -s ${trimmed_reads} -o ${trimmed_reads.baseName}_assembled --phred-offset 33
    """
}

workflow {
    reads_channel = Channel.fromPath(params.reads)
    
    // Define how channels are connected between processes
    trimmed_reads_channel = TrimFastQReads(reads_channel)
    AssembleFastA(trimmed_reads_channel)
}

