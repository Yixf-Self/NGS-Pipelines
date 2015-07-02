
    Rules for NGS pipeline:

    1. In one folder, there is only one group input.

    2. File name: 
       Target_Space_Time_Other_RepNum(_[1-2]).xxx, (6 or 7 parts, RepNum means biological replicates, [1-2] is 1 or 2 for paired-end reads).
       For raw compressed fastq files: Target_Space_Time_Other_RepNum(_[1-2])_Lane[1-2].fastq.bz2

       For instance: 
       H3K27ac_CM_Adult_HeLab_Rep1.fastq,   Input_CM_Adult_HeLab_Rep1.fastq,    MethylC_CM_Adult_SRR1040648_Rep1_2.fastq,    RNA_CM_p10_Enhancer_Rep1_Lane1.fastq.bz2
       H3K4me3_CM_adult_SRR1040924_Rep1.sra

    3. The first step of all scripts is checking file name by using regular expression: 
         m/^(\w+)_(\w+)_(\w+)_(\w+)_(Rep[1-9])(_?)([1-2]?)\.(\w+)$/
         m/^(\w+)_(\w+)_(\w+)_(\w+)_(Rep[1-9])(_?)([1-2]?)_Lane[1-2]\.fastq\.bz2$/


    4. Quality statistics: first by FastQC, after it finished, then run other  quality statistic softwares.

    5. For biological replicats, "Target_Space_Time_Other_" are same, only "RepNum" is different.

    6. For Paired end files, only "(_[1-2])" is different.







    Suggesting Names of Folder:
        1-SRA or 1-CompressedFastq, 
        2-FASTQ, 
        3-Filtered, 
        4-Mapping,      (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
        5-SortMapped,   (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2)
        6-FinalBAM,     (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
        7-OtherForamts, (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
        8-GenomeCov,    (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2)
        9-MACS14,       (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
        10-MACS2,       (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
        11-HOMER,       (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
        12-DANPOS,      (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2)  
        13-HTSeq,       (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2)  
        14-PathWayGO,   (subfolder: 1-Subread, 2-BWA-aln, 3-BWA-mem, 4-Bowtie1, 5-Bowtie2) 
 

