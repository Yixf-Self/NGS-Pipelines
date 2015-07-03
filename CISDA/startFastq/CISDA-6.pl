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

        Step 6: Convert BAM format into BED format and bigwig by using bedtools and deepTools.  
                Required softwares in this step:  bedtools and deepTools.
  
        Usage: 
               perl  CISDA-6.pl    [-v]    [-h]    [-i inputDir]    [-o outDir]  

        For instance: 
                     perl  CISDA-6.pl    -i 6-FinalBAM          -o 7-otherFormats           
                     perl  CISDA-6.pl    --input 6-FinalBAM     --output 7-otherFormats    
 
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------
        Optional arguments:

        -v, --version        Show version number of this program and exit

        -h, --help           Show this help message and exit


        Required arguments:

        -i inputDir,  --input inputDir        inputDir is the name of input folder that contains your BAM files,
                                              the suffix of the BAM files must be ".bam".    (no default)

        -o outDir,  --output outDir           outDir is the name of output folder that contains running 
                                              results of this step.      (no default)
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
my $input_g  = '6-FinalBAM';            ## This is only an initialization  value or suggesting value, not default value.
my $output_g = '7-otherFormats';        ## This is only an initialization  value or suggesting value, not default value.


########## Available Arguments ##########
my $available = "  -v  --version    -h  --help    -i  --input    -o    --output  ";
my $boole_g = 0;
while( my ($key, $value) = each %args ) {
    if($available !~ m/\s$key\s/) {print  "    Cann't recognize $key\n";  $boole_g = 1; }
}
if($boole_g == 1) {
    print "\n    The Command Line Arguments are wrong!\n";
    print '    Please see help message by using "perl  CISDA-6.pl  -h" ';
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
                Input  folder: $input_g
                Output folder: $output_g
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





my $binLen  = 20;
my $EffectiveGenomeSize = 2150570000;
my $fragLen = 200;
my $norFact = (10**7)*$fragLen; 
my $fragLen1 = 50;  
my $norFact1 = (10**7)*$fragLen1; 
## There are three normalization methods: 10^7, 1X, RPKM.  The second method (1X) is the most reasonable method.





## 1. For Subread mapping results.
if (1==1) {

print "\n\n        For Subread mapping results......";
opendir(my $DH_input, $inputDir1) || die;     
my @inputFiles = readdir($DH_input);

my $BED_dir  = "$outDir1/1-BED";
my $BigWig1  = "$outDir1/2-bigwig-extend-E7";
my $BigWig2  = "$outDir1/3-bigwig-extend-E7";
my $BigWig3  = "$outDir1/4-bigwig-NoExtend-E7";
my $BigWig4  = "$outDir1/5-bigwig-Extend-1X";
my $BigWig5  = "$outDir1/6-bigwig-Extend-RPKM";

if ( !( -e $BED_dir)       )   { mkdir $BED_dir        ||  die; }
if ( !( -e $BigWig1)       )   { mkdir $BigWig1        ||  die; }
if ( !( -e $BigWig2)       )   { mkdir $BigWig2        ||  die; }
if ( !( -e $BigWig3)       )   { mkdir $BigWig3        ||  die; }
if ( !( -e $BigWig4)       )   { mkdir $BigWig4        ||  die; }
if ( !( -e $BigWig5)       )   { mkdir $BigWig5        ||  die; }

for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.bam$//  or  die;

    system("bedtools  bamtobed   -i $inputDir1/$temp.bam     > $BED_dir/$temp.bed");
    sleep(2);  #实际上睡眠的秒数
    open(FILE1, "<", "$BED_dir/$temp.bed") or die "$!";
    my @temp1 = <FILE1>; 
    my $lines1 = @temp1;  
    my $factor1 = (10**7)/$lines1;
    close FILE1;
    print "$temp:  $lines1,   $factor1\n";

    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir1/$temp.bam     --outFileName $BigWig1/$temp.bw     --outFileFormat bigwig       --scaleFactor    $factor1                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                               
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir1/$temp.bam     --outFileName $BigWig2/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir1/$temp.bam     --outFileName $BigWig3/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact1               --fragmentLength $fragLen1     --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir1/$temp.bam     --outFileName $BigWig4/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $EffectiveGenomeSize    --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                    
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir1/$temp.bam     --outFileName $BigWig5/$temp.bw     --outFileFormat bigwig       --normalizeUsingRPKM                     --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                                             
}

}


















## 2. For BWA-aln mapping results.
if (1==1) {

print "\n\n        For BWA-aln mapping results......";
opendir(my $DH_input, $inputDir2) || die; 
my @inputFiles = readdir($DH_input);

my $BED_dir  = "$outDir2/1-BED";
my $BigWig1  = "$outDir2/2-bigwig-extend-E7";
my $BigWig2  = "$outDir2/3-bigwig-extend-E7";
my $BigWig3  = "$outDir2/4-bigwig-NoExtend-E7";
my $BigWig4  = "$outDir2/5-bigwig-Extend-1X";
my $BigWig5  = "$outDir2/6-bigwig-Extend-RPKM";

if ( !( -e $BED_dir)       )   { mkdir $BED_dir        ||  die; }
if ( !( -e $BigWig1)       )   { mkdir $BigWig1        ||  die; }
if ( !( -e $BigWig2)       )   { mkdir $BigWig2        ||  die; }
if ( !( -e $BigWig3)       )   { mkdir $BigWig3        ||  die; }
if ( !( -e $BigWig4)       )   { mkdir $BigWig4        ||  die; }
if ( !( -e $BigWig5)       )   { mkdir $BigWig5        ||  die; }

for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.bam$//  or  die;

    system("bedtools  bamtobed   -i $inputDir2/$temp.bam     > $BED_dir/$temp.bed");
    sleep(2);  #实际上睡眠的秒数
    open(FILE1, "<", "$BED_dir/$temp.bed") or die "$!";
    my @temp1 = <FILE1>; 
    my $lines1 = @temp1;  
    my $factor1 = (10**7)/$lines1;
    close FILE1;
    print "$temp:  $lines1,   $factor1\n";

    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir2/$temp.bam     --outFileName $BigWig1/$temp.bw     --outFileFormat bigwig       --scaleFactor    $factor1                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                               
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir2/$temp.bam     --outFileName $BigWig2/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir2/$temp.bam     --outFileName $BigWig3/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact1               --fragmentLength $fragLen1     --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir2/$temp.bam     --outFileName $BigWig4/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $EffectiveGenomeSize    --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                    
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir2/$temp.bam     --outFileName $BigWig5/$temp.bw     --outFileFormat bigwig       --normalizeUsingRPKM                     --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                                             
}

}














## 3. For BWA-mem mapping results.
if (1==1) {
print "\n\n        For BWA-mem mapping results......";
opendir(my $DH_input, $inputDir3) || die;     
my @inputFiles = readdir($DH_input);


my $BED_dir  = "$outDir3/1-BED";
my $BigWig1  = "$outDir3/2-bigwig-extend-E7";
my $BigWig2  = "$outDir3/3-bigwig-extend-E7";
my $BigWig3  = "$outDir3/4-bigwig-NoExtend-E7";
my $BigWig4  = "$outDir3/5-bigwig-Extend-1X";
my $BigWig5  = "$outDir3/6-bigwig-Extend-RPKM";

if ( !( -e $BED_dir)       )   { mkdir $BED_dir        ||  die; }
if ( !( -e $BigWig1)       )   { mkdir $BigWig1        ||  die; }
if ( !( -e $BigWig2)       )   { mkdir $BigWig2        ||  die; }
if ( !( -e $BigWig3)       )   { mkdir $BigWig3        ||  die; }
if ( !( -e $BigWig4)       )   { mkdir $BigWig4        ||  die; }
if ( !( -e $BigWig5)       )   { mkdir $BigWig5        ||  die; }

for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.bam$//  or  die;

    system("bedtools  bamtobed   -i $inputDir3/$temp.bam     > $BED_dir/$temp.bed");
    sleep(2);  #实际上睡眠的秒数
    open(FILE1, "<", "$BED_dir/$temp.bed") or die "$!";
    my @temp1 = <FILE1>; 
    my $lines1 = @temp1;  
    my $factor1 = (10**7)/$lines1;
    close FILE1;
    print "$temp:  $lines1,   $factor1\n";

    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir3/$temp.bam     --outFileName $BigWig1/$temp.bw     --outFileFormat bigwig       --scaleFactor    $factor1                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                               
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir3/$temp.bam     --outFileName $BigWig2/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir3/$temp.bam     --outFileName $BigWig3/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact1               --fragmentLength $fragLen1     --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir3/$temp.bam     --outFileName $BigWig4/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $EffectiveGenomeSize    --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                    
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir3/$temp.bam     --outFileName $BigWig5/$temp.bw     --outFileFormat bigwig       --normalizeUsingRPKM                     --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                                             
}

}

















## 4. For Bowtie1 mapping results.
if (1==1) {
print "\n\n        For Bowtie1 mapping results......";
opendir(my $DH_input, $inputDir4) || die;     
my @inputFiles = readdir($DH_input);


my $BED_dir  = "$outDir4/1-BED";
my $BigWig1  = "$outDir4/2-bigwig-extend-E7";
my $BigWig2  = "$outDir4/3-bigwig-extend-E7";
my $BigWig3  = "$outDir4/4-bigwig-NoExtend-E7";
my $BigWig4  = "$outDir4/5-bigwig-Extend-1X";
my $BigWig5  = "$outDir4/6-bigwig-Extend-RPKM";

if ( !( -e $BED_dir)       )   { mkdir $BED_dir        ||  die; }
if ( !( -e $BigWig1)       )   { mkdir $BigWig1        ||  die; }
if ( !( -e $BigWig2)       )   { mkdir $BigWig2        ||  die; }
if ( !( -e $BigWig3)       )   { mkdir $BigWig3        ||  die; }
if ( !( -e $BigWig4)       )   { mkdir $BigWig4        ||  die; }
if ( !( -e $BigWig5)       )   { mkdir $BigWig5        ||  die; }

for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.bam$//  or  die;

    system("bedtools  bamtobed   -i $inputDir4/$temp.bam     > $BED_dir/$temp.bed");
    sleep(2);  #实际上睡眠的秒数
    open(FILE1, "<", "$BED_dir/$temp.bed") or die "$!";
    my @temp1 = <FILE1>; 
    my $lines1 = @temp1;  
    my $factor1 = (10**7)/$lines1;
    close FILE1;
    print "$temp:  $lines1,   $factor1\n";

    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir4/$temp.bam     --outFileName $BigWig1/$temp.bw     --outFileFormat bigwig       --scaleFactor    $factor1                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                               
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir4/$temp.bam     --outFileName $BigWig2/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir4/$temp.bam     --outFileName $BigWig3/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact1               --fragmentLength $fragLen1     --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir4/$temp.bam     --outFileName $BigWig4/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $EffectiveGenomeSize    --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                    
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir4/$temp.bam     --outFileName $BigWig5/$temp.bw     --outFileFormat bigwig       --normalizeUsingRPKM                     --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                                             
}

}

















## 5. For Bowtie2 mapping results.
if (1==1) {
print "\n\n        For Bowtie2 mapping results......";
opendir(my $DH_input, $inputDir5) || die;     
my @inputFiles = readdir($DH_input);


my $BED_dir  = "$outDir5/1-BED";
my $BigWig1  = "$outDir5/2-bigwig-extend-E7";
my $BigWig2  = "$outDir5/3-bigwig-extend-E7";
my $BigWig3  = "$outDir5/4-bigwig-NoExtend-E7";
my $BigWig4  = "$outDir5/5-bigwig-Extend-1X";
my $BigWig5  = "$outDir5/6-bigwig-Extend-RPKM";

if ( !( -e $BED_dir)       )   { mkdir $BED_dir        ||  die; }
if ( !( -e $BigWig1)       )   { mkdir $BigWig1        ||  die; }
if ( !( -e $BigWig2)       )   { mkdir $BigWig2        ||  die; }
if ( !( -e $BigWig3)       )   { mkdir $BigWig3        ||  die; }
if ( !( -e $BigWig4)       )   { mkdir $BigWig4        ||  die; }
if ( !( -e $BigWig5)       )   { mkdir $BigWig5        ||  die; }

for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.bam$//  or  die;

    system("bedtools  bamtobed   -i $inputDir5/$temp.bam     > $BED_dir/$temp.bed");
    sleep(2);  #实际上睡眠的秒数
    open(FILE1, "<", "$BED_dir/$temp.bed") or die "$!";
    my @temp1 = <FILE1>; 
    my $lines1 = @temp1;  
    my $factor1 = (10**7)/$lines1;
    close FILE1;
    print "$temp:  $lines1,   $factor1\n";

    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir5/$temp.bam     --outFileName $BigWig1/$temp.bw     --outFileFormat bigwig       --scaleFactor    $factor1                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                               
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir5/$temp.bam     --outFileName $BigWig2/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact                --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir5/$temp.bam     --outFileName $BigWig3/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $norFact1               --fragmentLength $fragLen1     --binSize $binLen      --ignoreDuplicates   ");                
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir5/$temp.bam     --outFileName $BigWig4/$temp.bw     --outFileFormat bigwig       --normalizeTo1x  $EffectiveGenomeSize    --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                    
    system(" bamCoverage   --numberOfProcessors 12    --bam $inputDir5/$temp.bam     --outFileName $BigWig5/$temp.bw     --outFileFormat bigwig       --normalizeUsingRPKM                     --fragmentLength $fragLen      --binSize $binLen      --ignoreDuplicates   ");                                             
}

}








print "\n\n        Job Done! Cheers! \n\n";

























