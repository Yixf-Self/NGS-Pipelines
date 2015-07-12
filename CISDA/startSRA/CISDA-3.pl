#!/usr/bin/env perl
use strict;
use warnings;







###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################

########## Help Infromation ##########
my $HELP_g = '
        Welcome to use CISDA (ChIp-Seq Data Analyzer), version 0.4.2, 2015-07-18.      
        CISDA is a Pipeline for Single-end and Paired-end ChIP-seq Data Analysis by Integrating Lots of Softwares.

        Step 3: Mapping the reads to the reference genome by using Subread, BWA, Bowtie1 and Bowtie2.  
                Assess the quality of ChIP-seq reads to identify possible sequencing errors 
                or biases by using FastQC.
  
        Usage: 
               perl  CISDA-3.pl    [-v]    [-h]    [-i inputDir]    [-o outDir]  

        For instance: 
                     perl  CISDA-3.pl    -i 3-Filtered          -o 4-Mapping           
                     perl  CISDA-3.pl    --input 3-Filtered     --output 4-Mapping    
                     perl  CISDA-3.pl    --input 3-Filtered     --output 4-Mapping    >> 3-runLog.txt  2>&1    
 
        
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------
        Optional arguments:

        -v, --version        Show version number of this program and exit.

        -h, --help           Show this help message and exit.


        Required arguments:

        -i inputDir,  --input inputDir        inputDir is the name of your input folder that contains your FASTQ files,
                                              the suffix of the FASTQ files must be ".fastq".    (no default)

        -o outDir,  --output outDir           outDir is the name of your output folder that contains running 
                                              results (SAM format) of this step.      (no default)
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------


        For more details about this pipeline, please see the web site:
        https://github.com/bigdataage/NGS-Pipelines

        Yong Peng @ He lab, yongp@outlook.com, Academy for Advanced Interdisciplinary Studies 
        and Center for Life Sciences (CLS), Peking University, China.     
  
';

my $version_g = "  CISDA (ChIP-Seq Data Analyzer), version 0.4.2, 2015-07-18.";


########## Keys and Values ##########
if ($#ARGV   == -1) { print  "\n$HELP_g\n\n";  exit 0; }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0) { @ARGV = (@ARGV, "-h");           }       ## when the number of command argumants is odd. 
my %args = @ARGV;


########## Initialize  Variables ##########
my $input_g  = '3-Filtered';      ## This is only an initialization  value or suggesting value, not default value.
my $output_g = '4-Mapping';       ## This is only an initialization  value or suggesting value, not default value.


########## Available Arguments ##########
my $available = "  -v  --version    -h  --help    -i  --input    -o    --output  ";
my $boole_g = 0;
while( my ($key, $value) = each %args ) {
    if($available !~ m/\s$key\s/) {print  "    Cann't recognize $key !!\n";  $boole_g = 1; }
}
if($boole_g == 1) {
    print "\n    The Command Line Arguments are wrong!\n";
    print '    Please see help message by using "perl  CISDA-3.pl  -h" ';
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
                Input  folder:  $input_g
                Output folder:  $output_g
        ###############################################################  
\n\n";


###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################












print "\n\n        Running......";
if ( !(-e $output_g) )  { mkdir $output_g || die; }





print "\n\n        Detecting single-end and paired-end FASTQ files in input folder......";
opendir(my $DH_input, $input_g) || die;     
my @inputFiles = readdir($DH_input);
my @singleEnd = ();
my @pairedEnd = ();
open(seqFiles_FH, ">", "$output_g/singleEnd-pairedEnd-Files.txt")  or  die; 
for ( my $i=0; $i<=$#inputFiles; $i++ ) {     
    next unless $inputFiles[$i] =~ m/\.fastq$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    next unless $inputFiles[$i] !~ m/^unpaired/;
    if ($inputFiles[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.fastq$/) {   ## sinlge end sequencing files.
        $inputFiles[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.fastq$/  or  die;  
        $singleEnd[$#singleEnd+1] =  $inputFiles[$i];
        print  "\n\n        Single-end sequencing files: $inputFiles[$i]\n";
        print seqFiles_FH  "Single-end sequencing files: $inputFiles[$i]\n";
    }else{     ## paired end sequencing files.
        $inputFiles[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])_([1-2])\.fastq$/  or  die; 
        if ($inputFiles[$i] =~ m/^(\S+_\S+_\S+_\S+_Rep[1-9])_1\.fastq$/) { ## The two files of one paired sequencing sample are always side by side. 
            my $temp = $1;
            my $end1 = $temp."_1.fastq";
            my $end2 = $temp."_2.fastq";
            (-e  "$input_g/$end1")  or die;  
            (-e  "$input_g/$end2")  or die;
            $pairedEnd[$#pairedEnd+1] =  $end1;
            $pairedEnd[$#pairedEnd+1] =  $end2;
            print  "\n\n        Paired-end sequencing files: $end1,  $end2\n";
            print seqFiles_FH  "Paired-end sequencing files: $end1,  $end2\n";
        }
    }
}
( ($#pairedEnd+1)%2 == 0 )  or die;
print   seqFiles_FH  "\n\n\n\n\n";
print   seqFiles_FH  "All single-end sequencing files:  @singleEnd\n\n\n\n\n\n";
print   seqFiles_FH  "All paired-end sequencing files:  @pairedEnd\n\n\n\n\n\n";
print    "\n\n";
print    "\n\n        All single-end sequencing files:  @singleEnd\n\n";
print    "\n\n        All paired-end sequencing files:  @pairedEnd\n\n";
my $numSingle = $#singleEnd + 1;
my $numPaired = $#pairedEnd + 1;
print  seqFiles_FH   "\nThere are $numSingle single-end sequencing files.\n";
print  seqFiles_FH   "\nThere are $numPaired paired-end sequencing files.\n";
print      "\n\n        There are $numSingle single-end sequencing files.\n";
print      "\n\n        There are $numPaired paired-end sequencing files.\n";

















print "\n\n        Mapping reads by using Subread......";
my $Subread = "$output_g/1-Subread";  
if ( !(-e $Subread) )  { mkdir $Subread || die; }
my $Subread_prefix = "/home/yp/ProgramFiles/1-NGStools/5-Mapping/subread/bin/mm9-genome";

for (my $i=0; $i<=$#pairedEnd; $i=$i+2) {  
        $pairedEnd[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])_1\.fastq$/   or  die;
        $pairedEnd[$i] =~ m/^(\S+)_1.fastq$/ or die;
        my $temp = $1;   
        my $end1 = $temp."_1";
        my $end2 = $temp."_2";
        ("$end2.fastq" eq $pairedEnd[$i+1])  or  die;
        open(tempFH, ">>", "$Subread/paired-end-files.txt")  or  die;
        print  tempFH  "$end1,  $end2\n";
        system("subread-align    --threads 16     --phred 3   --indel 5   --unique   --hamming     --maxMismatches 2        --index $Subread_prefix    --read $input_g/$end1.fastq     --read2 $input_g/$end2.fastq    --output $Subread/$temp.sam   >>$Subread/$temp.runLog   2>&1");       
}

for (my $i=0; $i<=$#singleEnd; $i++) {   
        $singleEnd[$i] =~ m/^(\S+_\S+_\S+_\S+_Rep[1-9])\.fastq$/   or  die; 
        my $temp = $1; 
        system("subread-align    --threads 16     --phred 3  --indel 5    --unique   --hamming     --maxMismatches 2        --index $Subread_prefix    --read $input_g/$temp.fastq    --output $Subread/$temp.sam   >>$Subread/$temp.runLog   2>&1");       
}


{#####

my $FastQC  = "$Subread/FastQC";
my $QCstat  = "$Subread/QCstat";
if ( !( -e $FastQC)  )   { mkdir $FastQC    ||  die; }
if ( !( -e $QCstat)  )   { mkdir $QCstat    ||  die; }
opendir(my $DH_map, $Subread) || die;     
my @mapFiles = readdir($DH_map);  

print   "\n\n        Compute number of reads based on number of lines......";
my @outputFiles_sort = sort(@mapFiles);
open(NumReads_FH,  "<", "$input_g/3-NumberOfReads.xlsx" )  or  die;
my @numreads = <NumReads_FH>;
my $jNum = 0; 
for ( my $i=0; $i<=$#outputFiles_sort; $i++ ) {     
    next unless $outputFiles_sort[$i] =~ m/\.sam$/;
    next unless $outputFiles_sort[$i] !~ m/^[.]/;
    next unless $outputFiles_sort[$i] !~ m/[~]$/;
    $jNum++;
    my $temp = $outputFiles_sort[$i]; 
    $temp =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.sam$/   or  die;
    $temp =~ s/\.sam$//  ||  die;
    open(TEMP_FH, "<",  "$Subread/$outputFiles_sort[$i]")  or  die;
    my @lines = <TEMP_FH>;
    my $numLines = @lines;
    $numreads[$jNum] =~ s/\n$//;
    $numreads[$jNum] = "$numreads[$jNum]\t$temp\t$numLines";
}
open(NumReads_FH,  ">", "$Subread/4-SubRead-NumberOfReads.xlsx" )  or  die;
print  NumReads_FH  "Samples\t#Reads\tSamples\t#Reads\tSamples\t#Reads\n";
for(my $i=1; $i<=$#numreads; $i=$i+1) {
    $numreads[$i] =~ s/\n$//;  
    print  NumReads_FH    "$numreads[$i]\n";
}

print "\n\n        Detecting the quality of sam files by using FastQC......";

for (my $i=0; $i<=$#mapFiles; $i++) {
    next unless $mapFiles[$i] =~ m/\.sam$/;
    next unless $mapFiles[$i] !~ m/^[.]/;
    next unless $mapFiles[$i] !~ m/[~]$/;
    next unless $mapFiles[$i] !~ m/^unpaired/;
    my $temp = $mapFiles[$i]; 
    $temp =~ s/\.sam$//  ||  die; 
    system("fastqc    --outdir $FastQC     --threads 16    --format sam    --kmers 7     $Subread/$temp.sam   >>$FastQC/$temp.runLog        2>&1");  
    system("wc  -l   $Subread/$temp.sam       >>$QCstat/$temp.lineNum.runLog  2>&1"); 
}

}#####




















print "\n\n        Mapping reads by using BWA......";
my $BWAaln = "$output_g/2-BWA-aln";  ## shorter than 70bp
my $BWAmem = "$output_g/3-BWA-mem";  ## longer  than 70bp
if ( !(-e $BWAaln) )  { mkdir $BWAaln || die; }
if ( !(-e $BWAmem) )  { mkdir $BWAmem || die; }
my $bwa_index = "/home/yp/ProgramFiles/1-NGStools/5-Mapping/BWA/mm9-genome";

print "\n\n        Mapping reads by using BWA aln......";

for (my $i=0; $i<=$#pairedEnd; $i=$i+2) {
        $pairedEnd[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])_1\.fastq$/   or  die;
        $pairedEnd[$i] =~ m/^(\S+)_1.fastq$/ or die;
        my $temp = $1;   
        my $end1 = $temp."_1";
        my $end2 = $temp."_2";
        ("$end2.fastq"   eq   $pairedEnd[$i+1])  or  die;
        open(tempFH, ">>", "$BWAaln/paired-end-files.txt")  or  die;
        print  tempFH  "$end1,  $end2\n";
        system("bwa aln    -n 0.04   -t 16   -f $BWAaln/$end1.sai     $bwa_index     $input_g/$end1.fastq    >>$BWAaln/$end1.runLog   2>&1");
        system("bwa aln    -n 0.04   -t 16   -f $BWAaln/$end2.sai     $bwa_index     $input_g/$end2.fastq    >>$BWAaln/$end2.runLog   2>&1");
        system("bwa sampe  -n 3              -f $BWAaln/$temp.sam     $bwa_index     $BWAaln/$end1.sai  $BWAaln/$end2.sai     $input_g/$end1.fastq  $input_g/$end2.fastq    >>$BWAaln/$temp.runLog   2>&1"); 
}

for (my $i=0; $i<=$#singleEnd; $i++) {   
        $singleEnd[$i] =~ m/^(\S+_\S+_\S+_\S+_Rep[1-9])\.fastq$/   or  die; 
        my $temp = $1; 
        system("bwa aln    -n 0.04   -t 16   -f $BWAaln/$temp.sai    $bwa_index                          $input_g/$temp.fastq         >>$BWAaln/$temp.runLog   2>&1");
        system("bwa samse  -n 3              -f $BWAaln/$temp.sam    $bwa_index     $BWAaln/$temp.sai    $input_g/$temp.fastq         >>$BWAaln/$temp.runLog   2>&1"); 
}


{#####

my $FastQC  = "$BWAaln/FastQC";
my $QCstat  = "$BWAaln/QCstat";
if ( !( -e $FastQC)  )   { mkdir $FastQC    ||  die; }
if ( !( -e $QCstat)  )   { mkdir $QCstat    ||  die; }
opendir(my $DH_map, $BWAaln) || die;     
my @mapFiles = readdir($DH_map);

print   "\n\n        Compute number of reads based on number of lines......";
my @outputFiles_sort = sort(@mapFiles);
open(NumReads_FH,  "<", "$input_g/3-NumberOfReads.xlsx" )  or  die;
my @numreads = <NumReads_FH>;
my $jNum = 0; 
for ( my $i=0; $i<=$#outputFiles_sort; $i++ ) {     
    next unless $outputFiles_sort[$i] =~ m/\.sam$/;
    next unless $outputFiles_sort[$i] !~ m/^[.]/;
    next unless $outputFiles_sort[$i] !~ m/[~]$/;
    $jNum++;
    my $temp = $outputFiles_sort[$i]; 
    $temp =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.sam$/   or  die;
    $temp =~ s/\.sam$//  ||  die;
    open(TEMP_FH, "<",  "$BWAaln/$outputFiles_sort[$i]")  or  die;
    my @lines = <TEMP_FH>;
    my $numLines = @lines;
    $numreads[$jNum] =~ s/\n$//;
    $numreads[$jNum] = "$numreads[$jNum]\t$temp\t$numLines";
}
open(NumReads_FH,  ">", "$BWAaln/4-BWAaln-NumberOfReads.xlsx" )  or  die;
print  NumReads_FH  "Samples\t#Reads\tSamples\t#Reads\tSamples\t#Reads\n";
for(my $i=1; $i<=$#numreads; $i=$i+1) {
    $numreads[$i] =~ s/\n$//;  
    print  NumReads_FH    "$numreads[$i]\n";
}

print "\n\n        Detecting the quality of sam files by using FastQC......";

for (my $i=0; $i<=$#mapFiles; $i++) {
    next unless $mapFiles[$i] =~ m/\.sam$/;
    next unless $mapFiles[$i] !~ m/^[.]/;
    next unless $mapFiles[$i] !~ m/[~]$/;
    next unless $mapFiles[$i] !~ m/^unpaired/;
    my $temp = $mapFiles[$i]; 
    $temp =~ s/\.sam$//  ||  die; 
    system("fastqc    --outdir $FastQC     --threads 16    --format sam    --kmers 7     $BWAaln/$temp.sam          >>$FastQC/$temp.runLog        2>&1");  
    system("wc  -l   $BWAaln/$temp.sam       >>$QCstat/$temp.lineNum.runLog  2>&1"); 
}

}#####





print "\n\n        Mapping reads by using BWA mem......\n\n";

for (my $i=0; $i<=$#pairedEnd; $i=$i+2) {
        $pairedEnd[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])_1\.fastq$/   or  die;
        $pairedEnd[$i] =~ m/^(\S+)_1.fastq$/ or die;
        my $temp = $1;   
        my $end1 = $temp."_1";
        my $end2 = $temp."_2";
        ("$end2.fastq"  eq $pairedEnd[$i+1])  or  die;
        open(tempFH, ">>", "$BWAmem/paired-end-files.txt")  or  die;
        print  tempFH  "$end1,  $end2\n";
        system("bwa mem  -t 16   $bwa_index     $input_g/$end1.fastq  $input_g/$end2.fastq    >$BWAmem/$temp.sam"); 
}

for (my $i=0; $i<=$#singleEnd; $i++) {   
        $singleEnd[$i] =~ m/^(\S+_\S+_\S+_\S+_Rep[1-9])\.fastq$/   or  die; 
        my $temp = $1; 
        system("bwa mem  -t 16   $bwa_index     $input_g/$temp.fastq   >$BWAmem/$temp.sam");
}



{#####

my $FastQC  = "$BWAmem/FastQC";
my $QCstat  = "$BWAmem/QCstat";
if ( !( -e $FastQC)  )   { mkdir $FastQC    ||  die; }
if ( !( -e $QCstat)  )   { mkdir $QCstat    ||  die; }
opendir(my $DH_map, $BWAmem) || die;     
my @mapFiles = readdir($DH_map);

print   "\n\n        Compute number of reads based on number of lines......";
my @outputFiles_sort = sort(@mapFiles);
open(NumReads_FH,  "<", "$input_g/3-NumberOfReads.xlsx" )  or  die;
my @numreads = <NumReads_FH>;
my $jNum = 0; 
for ( my $i=0; $i<=$#outputFiles_sort; $i++ ) {     
    next unless $outputFiles_sort[$i] =~ m/\.sam$/;
    next unless $outputFiles_sort[$i] !~ m/^[.]/;
    next unless $outputFiles_sort[$i] !~ m/[~]$/;
    $jNum++;
    my $temp = $outputFiles_sort[$i]; 
    $temp =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.sam$/   or  die;
    $temp =~ s/\.sam$//  ||  die;
    open(TEMP_FH, "<",  "$BWAmem/$outputFiles_sort[$i]")  or  die;
    my @lines = <TEMP_FH>;
    my $numLines = @lines;
    $numreads[$jNum] =~ s/\n$//;
    $numreads[$jNum] = "$numreads[$jNum]\t$temp\t$numLines";
}
open(NumReads_FH,  ">", "$BWAmem/4-BWAmem-NumberOfReads.xlsx" )  or  die;
print  NumReads_FH  "Samples\t#Reads\tSamples\t#Reads\tSamples\t#Reads\n";
for(my $i=1; $i<=$#numreads; $i=$i+1) {
    $numreads[$i] =~ s/\n$//;  
    print  NumReads_FH    "$numreads[$i]\n";
}

print "\n\n        Detecting the quality of sam files by using FastQC......";

for (my $i=0; $i<=$#mapFiles; $i++) {
    next unless $mapFiles[$i] =~ m/\.sam$/;
    next unless $mapFiles[$i] !~ m/^[.]/;
    next unless $mapFiles[$i] !~ m/[~]$/;
    next unless $mapFiles[$i] !~ m/^unpaired/;
    my $temp = $mapFiles[$i]; 
    $temp =~ s/\.sam$//  ||  die; 
    system("fastqc    --outdir $FastQC     --threads 16    --format sam    --kmers 7     $BWAmem/$temp.sam          >>$FastQC/$temp.runLog        2>&1");  
    system("wc  -l   $BWAmem/$temp.sam       >>$QCstat/$temp.lineNum.runLog  2>&1"); 
}

}#####



















print "\n\n        Mapping reads by using Bowtie1......";
my $Bowtie1 = "$output_g/4-Bowtie1";  
if ( !(-e $Bowtie1) )  { mkdir $Bowtie1 || die; }

for (my $i=0; $i<=$#pairedEnd; $i=$i+2) {  
        $pairedEnd[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])_1\.fastq$/   or  die;
        $pairedEnd[$i] =~ m/^(\S+)_1.fastq$/ or die;
        my $temp = $1;   
        my $end1 = $temp."_1";
        my $end2 = $temp."_2";
        ("$end2.fastq"  eq $pairedEnd[$i+1])  or  die;
        open(tempFH, ">>", "$Bowtie1/paired-end-files.txt")  or  die;
        print  tempFH  "$end1,  $end2\n";
        system("bowtie   --threads 16   -q  --chunkmbs 640    --sam -n 2   -e 70   -l 28   -m 1    --phred33-quals   mm9-genome    -1 $input_g/$end1.fastq   -2 $input_g/$end2.fastq     $Bowtie1/$temp.sam   >>$Bowtie1/$temp.runLog   2>&1");       
}

for (my $i=0; $i<=$#singleEnd; $i++) {   
        $singleEnd[$i] =~ m/^(\S+_\S+_\S+_\S+_Rep[1-9])\.fastq$/   or  die; 
        my $temp = $1; 
        system("bowtie   --threads 16   -q  --chunkmbs 640  --sam -n 2   -e 70   -l 28   -m 1    --phred33-quals   mm9-genome     $input_g/$temp.fastq      $Bowtie1/$temp.sam    >>$Bowtie1/$temp.runLog  2>&1");                    
}



{#####

my $FastQC  = "$Bowtie1/FastQC";
my $QCstat  = "$Bowtie1/QCstat";
if ( !( -e $FastQC)  )   { mkdir $FastQC    ||  die; }
if ( !( -e $QCstat)  )   { mkdir $QCstat    ||  die; }
opendir(my $DH_map, $Bowtie1) || die;     
my @mapFiles = readdir($DH_map);


print   "\n\n        Compute number of reads based on number of lines......";
my @outputFiles_sort = sort(@mapFiles);
open(NumReads_FH,  "<", "$input_g/3-NumberOfReads.xlsx" )  or  die;
my @numreads = <NumReads_FH>;
my $jNum = 0; 
for ( my $i=0; $i<=$#outputFiles_sort; $i++ ) {     
    next unless $outputFiles_sort[$i] =~ m/\.sam$/;
    next unless $outputFiles_sort[$i] !~ m/^[.]/;
    next unless $outputFiles_sort[$i] !~ m/[~]$/;
    $jNum++;
    my $temp = $outputFiles_sort[$i]; 
    $temp =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.sam$/   or  die;
    $temp =~ s/\.sam$//  ||  die;
    open(TEMP_FH, "<",  "$Bowtie1/$outputFiles_sort[$i]")  or  die;
    my @lines = <TEMP_FH>;
    my $numLines = @lines;
    $numreads[$jNum] =~ s/\n$//;
    $numreads[$jNum] = "$numreads[$jNum]\t$temp\t$numLines";
}
open(NumReads_FH,  ">", "$Bowtie1/4-Bowtie1-NumberOfReads.xlsx" )  or  die;
print  NumReads_FH  "Samples\t#Reads\tSamples\t#Reads\tSamples\t#Reads\n";
for(my $i=1; $i<=$#numreads; $i=$i+1) {
    $numreads[$i] =~ s/\n$//;  
    print  NumReads_FH    "$numreads[$i]\n";
}

print "\n\n        Detecting the quality of sam files by using FastQC......";

for (my $i=0; $i<=$#mapFiles; $i++) {
    next unless $mapFiles[$i] =~ m/\.sam$/;
    next unless $mapFiles[$i] !~ m/^[.]/;
    next unless $mapFiles[$i] !~ m/[~]$/;
    next unless $mapFiles[$i] !~ m/^unpaired/;
    my $temp = $mapFiles[$i]; 
    $temp =~ s/\.sam$//  ||  die; 
    ##system("fastqc    --outdir $FastQC     --threads 16     --format sam    --kmers 7     $Bowtie1/$temp.sam          >>$FastQC/$temp.runLog        2>&1");  
    system("wc  -l   $Bowtie1/$temp.sam       >>$QCstat/$temp.lineNum.runLog  2>&1"); 
}

}#####
















print "\n\n        Mapping reads by using Bowtie2......";
my $Bowtie2 = "$output_g/5-Bowtie2";  
if ( !(-e $Bowtie2) )  { mkdir $Bowtie2 || die; }

for (my $i=0; $i<=$#pairedEnd; $i=$i+2) {  
        $pairedEnd[$i] =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])_1\.fastq$/   or  die;
        $pairedEnd[$i] =~ m/^(\S+)_1.fastq$/ or die;
        my $temp = $1;   
        my $end1 = $temp."_1";
        my $end2 = $temp."_2";
        ("$end2.fastq" eq $pairedEnd[$i+1])  or  die;
        open(tempFH, ">>", "$Bowtie2/paired-end-files.txt")  or  die;
        print  tempFH  "$end1,  $end2\n";
        system("bowtie2   --threads 16   -q   --phred33   --end-to-end    -x mm9-genome    -1 $input_g/$end1.fastq        -2 $input_g/$end1.fastq     -S $Bowtie2/$temp.sam    >>$Bowtie2/$temp.runLog  2>&1");                    
}

for (my $i=0; $i<=$#singleEnd; $i++) {   
        $singleEnd[$i] =~ m/^(\S+_\S+_\S+_\S+_Rep[1-9])\.fastq$/   or  die; 
        my $temp = $1; 
        system("bowtie2   --threads 16   -q   --phred33   --end-to-end    -x mm9-genome    -U $input_g/$temp.fastq      -S $Bowtie2/$temp.sam    >>$Bowtie2/$temp.runLog  2>&1");                    
}



{#####

my $FastQC  = "$Bowtie2/FastQC";
my $QCstat  = "$Bowtie2/QCstat";
if ( !( -e $FastQC)  )   { mkdir $FastQC    ||  die; }
if ( !( -e $QCstat)  )   { mkdir $QCstat    ||  die; }
opendir(my $DH_map, $Bowtie2) || die;     
my @mapFiles = readdir($DH_map);


print   "\n\n        Compute number of reads based on number of lines......";
my @outputFiles_sort = sort(@mapFiles);
open(NumReads_FH,  "<", "$input_g/3-NumberOfReads.xlsx" )  or  die;
my @numreads = <NumReads_FH>;
my $jNum = 0; 
for ( my $i=0; $i<=$#outputFiles_sort; $i++ ) {     
    next unless $outputFiles_sort[$i] =~ m/\.sam$/;
    next unless $outputFiles_sort[$i] !~ m/^[.]/;
    next unless $outputFiles_sort[$i] !~ m/[~]$/;
    $jNum++;
    my $temp = $outputFiles_sort[$i]; 
    $temp =~ m/^(\S+)_(\S+)_(\S+)_(\S+)_(Rep[1-9])\.sam$/   or  die;
    $temp =~ s/\.sam$//  ||  die;
    open(TEMP_FH, "<",  "$Bowtie2/$outputFiles_sort[$i]")  or  die;
    my @lines = <TEMP_FH>;
    my $numLines = @lines;
    $numreads[$jNum] =~ s/\n$//;
    $numreads[$jNum] = "$numreads[$jNum]\t$temp\t$numLines";
}
open(NumReads_FH,  ">", "$Bowtie2/4-Bowtie2-NumberOfReads.xlsx" )  or  die;
print  NumReads_FH  "Samples\t#Reads\tSamples\t#Reads\tSamples\t#Reads\n";
for(my $i=1; $i<=$#numreads; $i=$i+1) {
    $numreads[$i] =~ s/\n$//;  
    print  NumReads_FH    "$numreads[$i]\n";
}

print "\n\n        Detecting the quality of sam files by using FastQC......";

for (my $i=0; $i<=$#mapFiles; $i++) {
    next unless $mapFiles[$i] =~ m/\.sam$/;
    next unless $mapFiles[$i] !~ m/^[.]/;
    next unless $mapFiles[$i] !~ m/[~]$/;
    next unless $mapFiles[$i] !~ m/^unpaired/;
    my $temp = $mapFiles[$i]; 
    $temp =~ s/\.sam$//  ||  die; 
    system("fastqc    --outdir $FastQC     --threads 16    --format sam    --kmers 7     $Bowtie2/$temp.sam          >>$FastQC/$temp.runLog        2>&1");  
    system("wc  -l   $Bowtie2/$temp.sam       >>$QCstat/$temp.lineNum.runLog  2>&1"); 
}

}#####







print "\n\n        Job Done! Cheers! \n\n";

























