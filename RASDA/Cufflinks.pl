#!/usr/bin/env perl
use strict;
use warnings;

## http://cole-trapnell-lab.github.io/cufflinks/



my $inDir1 = '3-mapQ10' ;
opendir(my $inHandle1, $inDir1) or die;  #打开目录句柄。
my @inNames1 = readdir($inHandle1);      #读取目录里的文件名。读取的仅仅是文件名称，不含路径。


my $outDir = "5-Cufflinks";
my $outDir1 = "$outDir/1-cufflinks";
my $outDir2 = "$outDir/2-cuffmerge";
my $outDir3 = "$outDir/3-cuffquant";
my $outDir4 = "$outDir/4-cuffdiff";
my $outDir5 = "$outDir/5-CummeRbund";
my $outDir6 = "$outDir/6-cuffnorm";
my $outDir7 = "$outDir/7-cuffcompare";
if ( !(-e $outDir)  )  {mkdir $outDir  or die; }
if ( !(-e $outDir1) )  {mkdir $outDir1 or die; }
if ( !(-e $outDir2) )  {mkdir $outDir2 or die; }
if ( !(-e $outDir3) )  {mkdir $outDir3 or die; }
if ( !(-e $outDir4) )  {mkdir $outDir4 or die; }
if ( !(-e $outDir5) )  {mkdir $outDir5 or die; }
if ( !(-e $outDir6) )  {mkdir $outDir6 or die; }
if ( !(-e $outDir7) )  {mkdir $outDir7 or die; }





if (1==0) {
## step1, cufflinks
open(FH1, ">", "$outDir1/assemblies.txt"    )  or  die; 

for(my $i=0; $i<=$#inNames1; $i++) {
    if($inNames1[$i] =~ m/\.bam$/) {
        my $temp = $inNames1[$i];
        $temp =~ s/\.bam$//  or  die;
        system("cufflinks    --output-dir $outDir1/$temp        --num-threads 6     --GTF       0-Other/mm9/mm9-RefSeqGenes.GTF     --frag-bias-correct 0-Other/mm9/genome.fa     --multi-read-correct    --library-type fr-unstranded          --label $temp     $inDir1/$temp.bam     >>$outDir1/$temp.log.txt      2>&1"   );                                     
        print  FH1    "$outDir1/$temp/transcripts.gtf\n";
    }
}




## step2, cuffmerge
system("cuffmerge      -o  $outDir2       --ref-gtf  0-Other/mm9/mm9-RefSeqGenes.GTF     --ref-sequence 0-Other/mm9/genome.fa     --num-threads 6   $outDir1/assemblies.txt      >>$outDir2/log.txt        2>&1");




## step3,    cuffquant 
for(my $i=0; $i<=$#inNames1; $i++) {   
    next unless $inNames1[$i] =~ m/\.bam$/; 
    next unless $inNames1[$i] !~ m/^[.]/;
    next unless $inNames1[$i] !~ m/[~]$/; 
    my $temp = $inNames1[$i];
    $temp =~ s/\.bam$//  or  die;
    system("cuffquant     --output-dir $outDir3/$temp      --frag-bias-correct 0-Other/mm9/genome.fa      --multi-read-correct    --num-threads 6       --library-type fr-unstranded         $outDir2/merge.gtf    $inDir1/$temp.bam     >>$outDir3/$temp.log.txt      2>&1"); 
}


}



## step4,    cuffdiff 
system("cuffdiff   --output-dir $outDir4/BAM    --labels ctrl,KO     --frag-bias-correct 0-Other/mm9/genome.fa     --multi-read-correct   --num-threads 6         $outDir2/merged.gtf    $inDir1/mRNA_Adult_ctrl1.bam,$inDir1/mRNA_Adult_ctrl2.bam      $inDir1/mRNA_Adult_KO1.bam,$inDir1/mRNA_Adult_KO2.bam          >>$outDir4/BAM-log.txt        2>&1");
system("cuffdiff   --output-dir $outDir4/CXB    --labels ctrl,KO     --frag-bias-correct 0-Other/mm9/genome.fa     --multi-read-correct   --num-threads 6         $outDir2/merged.gtf    $outDir3/mRNA_Adult_ctrl1/abundances.cxb,$outDir3/mRNA_Adult_ctrl2/abundances.cxb      $outDir3/mRNA_Adult_KO1/abundances.cxb,$outDir3/mRNA_Adult_KO2/abundances.cxb      >>$outDir4/CXB-log.txt        2>&1");






## step5,    CummeRbund











## step6,    cuffnorm 
system("cuffnorm   --output-dir $outDir6/BAM    --labels ctrl,KO     --frag-bias-correct 0-Other/mm9/genome.fa     --multi-read-correct   --num-threads 6         $outDir2/merged.gtf    $inDir1/mRNA_Adult_ctrl1.bam,$inDir1/mRNA_Adult_ctrl2.bam      $inDir1/mRNA_Adult_KO1.bam,$inDir1/mRNA_Adult_KO2.bam   >>$outDir6/BAM-log.txt        2>&1");
system("cuffnorm   --output-dir $outDir6/CXB    --labels ctrl,KO     --frag-bias-correct 0-Other/mm9/genome.fa     --multi-read-correct   --num-threads 6         $outDir2/merged.gtf    $outDir3/mRNA_Adult_ctrl1/abundances.cxb,$outDir3/mRNA_Adult_ctrl2/abundances.cxb      $outDir3/mRNA_Adult_KO1/abundances.cxb,$outDir3/mRNA_Adult_KO2/abundances.cxb      >>$outDir6/CXB-log.txt        2>&1");                              







## step7,    cuffcompare 
system("cuffcompare     -r 0-Other/mm9/mm9-RefSeqGenes.GTF     -s 0-Other/mm9/genome.fa       -o $outDir7     -i $outDir1/assemblies.txt   >>$outDir7/log.txt        2>&1");  








