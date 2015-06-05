
    Naming Rules of Files:

    1. In one folder, there is only one group input.

    2. File name: 
       Target_Space_Time_Other_RepNum(_[1-2]).xxx, (6 or 7 parts, RepNum means biological replicates, [1-2] is 1 or 2 for paired-end reads).
       For raw compressed fastq files: Target_Space_Time_Other_RepNum(_[1-2])_Lane[1-2].fastq.bz2

       For instance: 
       H3K27ac_CM_Adult_HeLab_Rep1.fastq,   Input_CM_Adult_HeLab_Rep1.fastq,    MethylC_CM_Adult_SRR1040648_Rep1_2.fastq,    RNA_CM_p10_Enhancer_Rep1_Lane1.fastq.bz2

    3. The first step of all scripts is checking file name by using regular expression: 
         m/^(\w+)_(\w+)_(\w+)_(\w+)_(Rep[1-9])(_?)([1-2]?)\.(\w+)$/
         m/^(\w+)_(\w+)_(\w+)_(\w+)_(Rep[1-9])(_?)([1-2]?)_Lane[1-2]\.fastq\.bz2$/


    4. Quality statistics: first by FastQC, after it finished, then run other  quality statistic softwares.

    5. For biological replicats, "Target_Space_Time_Other_" are same, only "RepNum" is different.

    6. For Paired end files, only "(_[1-2])" is different.





    Names of Folder:
        1-SRA/1-CompressedFastq, 2-FASTQ, 3-Filtered, 4-Mapping, 5-SortMapped, 6-FinalBAM, 7-OtherForamts, 8-MACS14, 9-MACS2, 10-HOMER, 11-



