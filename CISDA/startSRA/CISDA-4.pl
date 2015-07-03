#!/usr/bin/env perl
use strict;
use warnings;






###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################

########## Help Infromation ##########
my $HELP_g = '
        Welcome to use CISDA (ChIp-Seq Data Analyzer), version 0.4.0, 2015-07-02.      
        CISDA is a Pipeline for Single-end and Paired-end ChIP-seq Data Analysis by Integrating Lots of Softwares.

        Step 4: Remove unmapped reads and sort mapped reads.  
                Quality statistics by using FastQC, BamUtil and SAMtools.
                Required softwares in this step:  FastQC, BamUtil and SAMtools.
  
        Usage: 
               perl  CISDA-4.pl    [-v]    [-h]    [-i inputDir]    [-o outDir]  

        For instance: 
                     perl  CISDA-4.pl    -i 4-Mapping          -o 5-SortMapped           
                     perl  CISDA-4.pl    --input 4-Mapping     --output 5-SortMapped    
 
        
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------
        Optional arguments:

        -v, --version        Show version number of this program and exit.

        -h, --help           Show this help message and exit.


        Required arguments:

        -i inputDir,  --input inputDir        inputDir is the name of input folder that contains your SAM files,
                                              the suffix of the SAM files must be ".sam".    (no default)

        -o outDir,  --output outDir           outDir is the name of output folder that contains running 
                                              results (BAM format) of this step.      (no default)
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------


        Yong Peng @ He lab, yongpeng@email.com, Academy for Advanced Interdisciplinary Studies 
        and Center for Life Sciences (CLS), Peking University, China.     
  
';

my $version_g = "  CISDA (ChIP-Seq Data Analyzer), version 0.4.0, 2015-07-02.";


########## Keys and Values ##########
if ($#ARGV   == -1) { print  "\n$HELP_g\n\n";  exit 0; }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0) { @ARGV = (@ARGV, "-h");           }       ## when the number of command argumants is odd. 
my %args = @ARGV;


########## Initialize  Variables ##########
my $input_g  = '4-Mapping';          ## This is only an initialization  value or suggesting value, not default value.
my $output_g = '5-SortMapped';       ## This is only an initialization  value or suggesting value, not default value.


########## Available Arguments ##########
my $available = "  -v  --version    -h  --help    -i  --input    -o    --output  ";
my $boole_g = 0;
while( my ($key, $value) = each %args ) {
    if($available !~ m/\s$key\s/) {print  "    Cann't recognize $key\n";  $boole_g = 1; }
}
if($boole_g == 1) {
    print "\n    The Command Line Arguments are wrong!\n";
    print '    Please see help message by using "perl  CISDA-4.pl  -h" ';
    print "\n\n";
    exit 0;
}


########## Get Arguments ##########
if ( ( exists $args{'-v' } )  or  ( exists $args{'--version' } )  )     { print  "\n$version_g\n\n";    exit 0; }
if ( ( exists $args{'-h' } )  or  ( exists $args{'--help'    } )  )     { print  "\n$HELP_g\n\n";       exit 0; }
if ( ( exists $args{'-i' } )  or  ( exists $args{'--input'   } )  )     { ($input_g  = $args{'-i' })  or  ($input_g  = $args{'--input' });  }else{print   "\n -i or --input  is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }                                               
if ( ( exists $args{'-o' } )  or  ( exists $args{'--output'  } )  )     { ($output_g = $args{'-o' })  or  ($output_g = $args{'--output'});  }else{print   "\n -o or --output is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }      



########### Conditions #############
$input_g  =~ m/^\S+$/   ||  die   "\n$HELP_g\n\n";
$output_g =~ m/^\S+$/   ||  die   "\n$HELP_g\n\n";


######### Print Command Arguments to Standard Output ###########
print  "\n\n
        ################ Your Arguments ###############################
                Input  folder:     $input_g
                Output folder:     $output_g
        ###############################################################  
\n\n";


###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################








print "\n\n        Running......";
my $inputDir1 = "$input_g/1-Subread";
my $inputDir2 = "$input_g/2-BWA-aln";
my $inputDir3 = "$input_g/3-BWA-mem";
my $inputDir4 = "$input_g/4-Bowtie1";
my $inputDir5 = "$input_g/5-Bowtie2";
my $outDir1   = "$output_g/1-Subread";
my $outDir2   = "$output_g/2-BWA-aln";
my $outDir3   = "$output_g/3-BWA-mem";
my $outDir4   = "$output_g/4-Bowtie1";
my $outDir5   = "$output_g/5-Bowtie2";
if ( !(-e $output_g) )  { mkdir $output_g || die; }
if ( !(-e $outDir1)  )  { mkdir $outDir1  || die; }
if ( !(-e $outDir2)  )  { mkdir $outDir2  || die; }
if ( !(-e $outDir3)  )  { mkdir $outDir3  || die; }
if ( !(-e $outDir4)  )  { mkdir $outDir4  || die; }
if ( !(-e $outDir5)  )  { mkdir $outDir5  || die; }





## 1. For Subread mapping results.
if (1==1) {
print "\n\n        Remove unmapped reads, sort, index and quality statistics for Subread mapping results......";
opendir(my $DH_input, $inputDir1) || die;     
my @inputFiles = readdir($DH_input);
my $FastQCdir        = "$outDir1/FastQC";
my $FastQCdir_10mer  = "$outDir1/FastQC_10mer";
my $outDir1QC        = "$outDir1/QCstatistics";
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $outDir1QC)       )   { mkdir $outDir1QC        ||  die; }
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.sam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.sam$//  or  die;
    system(`samtools view -h   $inputDir1/$inputFiles[$i]  |  grep -P  "(chr)|(^@)"   > $outDir1/$temp.sam`);
    system("samtools  sort   -O bam       -o $outDir1/$temp.bam    -T $outDir1/$inputFiles[$i]      $outDir1/$temp.sam     >>$outDir1/$temp.runLog    2>&1");
    system("samtools  index       $outDir1/$temp.bam      >>$outDir1/$temp.runLog 2>&1");
    system("samtools  flagstat    $outDir1/$temp.bam      >>$outDir1QC/$temp.run=samtoolsflagstat.runLog  2>&1");
    system(`samtools  idxstats    $outDir1/$temp.bam      >>$outDir1QC/$temp.run=samtoolsidxstats.runLog  2>&1`);
    system(`bam  validate  --in   $outDir1/$temp.bam      >>$outDir1QC/$temp.run=bamvalidate.runLog       2>&1`);
    system(`bam  stats     --in   $outDir1/$temp.bam  --basic  --qual  --phred    >>$outDir1QC/$temp.run=bamstats.runLog 2>&1`);
    system("fastqc    --outdir $FastQCdir          --threads 12    --format bam    --kmers 7     $outDir1/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
    system("fastqc    --outdir $FastQCdir_10mer    --threads 12    --format bam    --kmers 10    $outDir1/$temp.bam          >>$FastQCdir_10mer/$temp.run=fastqc.runLog  2>&1"); 
    system("rm   $outDir1/$temp.sam");
}
}


















## 2. For BWA-aln mapping results.
if (1==1) {
print "\n\n        Remove unmapped reads, sort, index and quality statistics for BWA-aln mapping results......";
opendir(my $DH_input, $inputDir2) || die;     
my @inputFiles = readdir($DH_input);
my $FastQCdir        = "$outDir2/FastQC";
my $FastQCdir_10mer  = "$outDir2/FastQC_10mer";
my $outDir2QC        = "$outDir2/QCstatistics";
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $outDir2QC)       )   { mkdir $outDir2QC        ||  die; }
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.sam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.sam$//  or  die;
    system("samtools  view   -hb   -q 1   -o $outDir2/$temp.q.bam       $inputDir2/$temp.sam                                 >>$outDir2/$temp.runLog    2>&1");
    system("samtools  sort   -O bam       -o $outDir2/$temp.bam    -T $outDir2/$inputFiles[$i]      $outDir2/$temp.q.bam     >>$outDir2/$temp.runLog    2>&1");
    system("samtools  index       $outDir2/$temp.bam      >>$outDir2/$temp.runLog 2>&1");
    system("samtools  flagstat    $outDir2/$temp.bam      >>$outDir2QC/$temp.run=samtoolsflagstat.runLog  2>&1");
    system(`samtools  idxstats    $outDir2/$temp.bam      >>$outDir2QC/$temp.run=samtoolsidxstats.runLog  2>&1`);
    system(`bam  validate  --in   $outDir2/$temp.bam      >>$outDir2QC/$temp.run=bamvalidate.runLog       2>&1`);
    system(`bam  stats     --in   $outDir2/$temp.bam  --basic  --qual  --phred    >>$outDir2QC/$temp.run=bamstats.runLog 2>&1`);
    system("fastqc    --outdir $FastQCdir          --threads 12    --format bam    --kmers 7     $outDir2/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
    system("fastqc    --outdir $FastQCdir_10mer    --threads 12    --format bam    --kmers 10    $outDir2/$temp.bam          >>$FastQCdir_10mer/$temp.run=fastqc.runLog  2>&1"); 
    system("rm   $outDir2/$temp.q.bam");
}
}














## 3. For BWA-mem mapping results.
if (1==1) {
print "\n\n        Remove unmapped reads, sort, index and quality statistics for BWA-mem mapping results......";
opendir(my $DH_input, $inputDir3) || die;     
my @inputFiles = readdir($DH_input);
my $FastQCdir        = "$outDir3/FastQC";
my $FastQCdir_10mer  = "$outDir3/FastQC_10mer";
my $outDir3QC        = "$outDir3/QCstatistics";
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $outDir3QC)       )   { mkdir $outDir3QC        ||  die; }
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.sam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.sam$//  or  die;
    system("samtools  view   -hb   -q 1   -o $outDir3/$temp.q.bam       $inputDir3/$temp.sam                                 >>$outDir3/$temp.runLog    2>&1");
    system("samtools  sort   -O bam       -o $outDir3/$temp.bam    -T $outDir3/$inputFiles[$i]      $outDir3/$temp.q.bam     >>$outDir3/$temp.runLog    2>&1");
    system("samtools  index       $outDir3/$temp.bam      >>$outDir3/$temp.runLog 2>&1");
    system("samtools  flagstat    $outDir3/$temp.bam      >>$outDir3QC/$temp.run=samtoolsflagstat.runLog  2>&1");
    system(`samtools  idxstats    $outDir3/$temp.bam      >>$outDir3QC/$temp.run=samtoolsidxstats.runLog  2>&1`);
    system(`bam  validate  --in   $outDir3/$temp.bam      >>$outDir3QC/$temp.run=bamvalidate.runLog       2>&1`);
    system(`bam  stats     --in   $outDir3/$temp.bam  --basic  --qual  --phred    >>$outDir3QC/$temp.run=bamstats.runLog 2>&1`);
    system("fastqc    --outdir $FastQCdir          --threads 12    --format bam    --kmers 7     $outDir3/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
    system("fastqc    --outdir $FastQCdir_10mer    --threads 12    --format bam    --kmers 10    $outDir3/$temp.bam          >>$FastQCdir_10mer/$temp.run=fastqc.runLog  2>&1"); 
    system("rm   $outDir3/$temp.q.bam");
}
}

















## 4. For Bowtie1 mapping results.
if (1==1) {
print "\n\n        Remove unmapped reads, sort, index and quality statistics for Bowtie1 mapping results......";
opendir(my $DH_input, $inputDir4) || die;     
my @inputFiles = readdir($DH_input);
my $FastQCdir        = "$outDir4/FastQC";
my $FastQCdir_10mer  = "$outDir4/FastQC_10mer";
my $outDir4QC        = "$outDir4/QCstatistics";
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $outDir4QC)       )   { mkdir $outDir4QC        ||  die; }
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.sam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.sam$//  or  die;
    system("samtools  view   -hb   -q 1   -o $outDir4/$temp.q.bam       $inputDir4/$temp.sam                                 >>$outDir4/$temp.runLog    2>&1");
    system("samtools  sort   -O bam       -o $outDir4/$temp.bam    -T $outDir4/$inputFiles[$i]      $outDir4/$temp.q.bam     >>$outDir4/$temp.runLog    2>&1");
    system("samtools  index       $outDir4/$temp.bam      >>$outDir4/$temp.runLog 2>&1");
    system("samtools  flagstat    $outDir4/$temp.bam      >>$outDir4QC/$temp.run=samtoolsflagstat.runLog  2>&1");
    system(`samtools  idxstats    $outDir4/$temp.bam      >>$outDir4QC/$temp.run=samtoolsidxstats.runLog  2>&1`);
    system(`bam  validate  --in   $outDir4/$temp.bam      >>$outDir4QC/$temp.run=bamvalidate.runLog       2>&1`);
    system(`bam  stats     --in   $outDir4/$temp.bam  --basic  --qual  --phred    >>$outDir4QC/$temp.run=bamstats.runLog 2>&1`);
    system("fastqc    --outdir $FastQCdir          --threads 12    --format bam    --kmers 7     $outDir4/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
    system("fastqc    --outdir $FastQCdir_10mer    --threads 12    --format bam    --kmers 10    $outDir4/$temp.bam          >>$FastQCdir_10mer/$temp.run=fastqc.runLog  2>&1"); 
    system("rm   $outDir4/$temp.q.bam");
}
}

















## 5. For Bowtie2 mapping results.
if (1==1) {
print "\n\n        Remove unmapped reads, sort, index and quality statistics for Bowtie2 mapping results......";
opendir(my $DH_input, $inputDir5) || die;     
my @inputFiles = readdir($DH_input);
my $FastQCdir        = "$outDir5/FastQC";
my $FastQCdir_10mer  = "$outDir5/FastQC_10mer";
my $outDir5QC        = "$outDir5/QCstatistics";
if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $outDir5QC)       )   { mkdir $outDir5QC        ||  die; }
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.sam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.sam$//  or  die;
    system("samtools  view   -hb   -q 1   -o $outDir5/$temp.q.bam       $inputDir5/$temp.sam                                 >>$outDir5/$temp.runLog    2>&1");
    system("samtools  sort   -O bam       -o $outDir5/$temp.bam    -T $outDir5/$inputFiles[$i]      $outDir5/$temp.q.bam     >>$outDir5/$temp.runLog    2>&1");
    system("samtools  index       $outDir5/$temp.bam      >>$outDir5/$temp.runLog 2>&1");
    system("samtools  flagstat    $outDir5/$temp.bam      >>$outDir5QC/$temp.run=samtoolsflagstat.runLog  2>&1");
    system(`samtools  idxstats    $outDir5/$temp.bam      >>$outDir5QC/$temp.run=samtoolsidxstats.runLog  2>&1`);
    system(`bam  validate  --in   $outDir5/$temp.bam      >>$outDir5QC/$temp.run=bamvalidate.runLog       2>&1`);
    system(`bam  stats     --in   $outDir5/$temp.bam  --basic  --qual  --phred    >>$outDir5QC/$temp.run=bamstats.runLog 2>&1`);
    system("fastqc    --outdir $FastQCdir          --threads 12    --format bam    --kmers 7     $outDir5/$temp.bam          >>$FastQCdir/$temp.run=fastqc.runLog        2>&1");  
    system("fastqc    --outdir $FastQCdir_10mer    --threads 12    --format bam    --kmers 10    $outDir5/$temp.bam          >>$FastQCdir_10mer/$temp.run=fastqc.runLog  2>&1"); 
    system("rm   $outDir5/$temp.q.bam");
}
}








print "\n\n        Job Done! Cheers! \n\n";

























