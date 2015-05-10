########################################################################################################################
## Pipeline for Single-end H2bGFP ChIP-seq Data alalysis.	
##
## Step 2: reads mapping by using Subread.   quality statistics by using FastQC, bamtools and BamUtil.
########################################################################################################################


#!/usr/bin/env perl
use strict;
use warnings;



my $inDir  = "2-Filtered"; 

my $Subread = "3-Subread";
if ( !(-e $Subread)   )   { mkdir $Subread    ||  die; }


my $FastQCdir           = "$Subread/FastQC";
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }

my $Subread_prefix = "/home/yongp/ProgramFiles/4-ReadMapping/subread-1.4.6/bin/mm9";

opendir(my $DH_input, $inDir)  ||  die;       #打开目录句柄。
while ( my $file = readdir($DH_input) ) {     #读取目录里的文件名。读取的仅仅是文件名称，不含路径。
    next unless $file =~ m/\.fastq$/; 
    next unless $file !~ m/^[.]/;
    next unless $file !~ m/[~]$/;
    my $temp = $file; 
    $temp =~ s/\.fastq//  ||  die; 
    system("subread-align    --threads 10     --phred 3      --unique   --hamming     --maxMismatches 3    --BAMoutput     --index $Subread_prefix    --read $inDir/$file    --output $Subread/$temp.bam   >>$Subread/$temp.run=Subread.runLog   2>&1");       
    system("fastqc    --outdir $FastQCdir          --threads 10    --format bam    --kmers 7     $Subread/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
}














                                         
