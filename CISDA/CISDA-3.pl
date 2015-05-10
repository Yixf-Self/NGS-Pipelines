########################################################################################################################
## Step 3: convert sam to bam, sort, index and statistical. And select the mapped reads (or with MAPQ>=10).  
##
## quality statistics by using FastQC, SAMtools and BamUtil.
########################################################################################################################




#!/usr/bin/env perl
use strict;
use warnings;


my $outDir = "4-sortBAM";
if (!(-e $outDir)) {mkdir $outDir or die;}


my $Subread         = "$outDir";
my $FastQCdir       = "$Subread/FastQC";
my $FastQCdir_10mer = "$Subread/FastQC_10mer";
my $SubreadQC       = "$Subread/QCstatistics";
if ( !( -e $Subread)         )   { mkdir $Subread          ||  die; }
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $SubreadQC)       )   { mkdir $SubreadQC        ||  die; }


my $dir_name1 = '3-Subread' ;
opendir(my $dir_handle1, $dir_name1) or die;  #打开目录句柄。
my @file_names1 = readdir($dir_handle1);      #读取目录里的文件名。读取的仅仅是文件名称，不含路径。

for(my $i=0; $i<=$#file_names1; $i++) {
    if($file_names1[$i] =~ m/\.bam$/) {
        my $temp = $file_names1[$i];
        $temp =~ s/\.bam//  or  die;
        system(`samtools view -h   $dir_name1/$file_names1[$i]  |  grep -P  "(chr)|(^@)"   > $Subread/$temp.sam`);
        system("samtools  sort   -O bam        -o $Subread/$temp.bam    -T $file_names1[$i]      $Subread/$temp.sam    >>$Subread/$temp.run=samtoolsort.runLog    2>&1");
        system("samtools  index       $Subread/$temp.bam      >>$Subread/$temp.run=samtoolsindex.runLog 2>&1");
        system("samtools  flagstat    $Subread/$temp.bam      >>$SubreadQC/$temp.run=samtoolsflagstat.runLog 2>&1");
        system(`samtools  idxstats    $Subread/$temp.bam      >>$SubreadQC/$temp.run=samtoolsidxstats.runLog  2>&1`);
        system(`bam  validate  --in   $Subread/$temp.bam      >>$SubreadQC/$temp.run=bamvalidate.runLog   2>&1`);
        system(`bam  stats     --in   $Subread/$temp.bam  --basic  --qual  --phred    >>$SubreadQC/$temp.run=bamstats.runLog 2>&1`);
        system("fastqc    --outdir $FastQCdir          --threads 10    --format bam    --kmers 7     $Subread/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
        system("fastqc    --outdir $FastQCdir_10mer    --threads 10    --format bam    --kmers 10    $Subread/$temp.bam          >>$FastQCdir_10mer/$temp.run=fastqc.runLog  2>&1"); 
        system("sleep  2s");
        system("rm   $Subread/$temp.sam");
    }
}













