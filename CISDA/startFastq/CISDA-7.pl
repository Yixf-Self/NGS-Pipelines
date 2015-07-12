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

        Step 7: Peak calling by using MACS1.4 .  
  
        Usage: 
               perl  CISDA-7.pl    [-v]    [-h]    [-i inputDir]    [-o outDir]  

        For instance: 
                     perl  CISDA-7.pl    -i 6-FinalBAM/1-Subread          -o 8-MACS14/1-Subread           
                     perl  CISDA-7.pl    --input 6-FinalBAM/1-Subread     --output 8-MACS14/1-Subread   
                     perl  CISDA-7.pl    --input 6-FinalBAM/1-Subread     --output 8-MACS14/1-Subread   >>  7-runLog.txt  2>&1   
 
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
my $input_g  = '6-FinalBAM/1-Subread';            ## This is only an initialization  value or suggesting value, not default value.
my $output_g = '8-MACS14/1-Subread';        ## This is only an initialization  value or suggesting value, not default value.


########## Available Arguments ##########
my $available = "  -v  --version    -h  --help    -i  --input    -o    --output  ";
my $boole_g = 0;
while( my ($key, $value) = each %args ) {
    if($available !~ m/\s$key\s/) {print  "    Cann't recognize $key\n";  $boole_g = 1; }
}
if($boole_g == 1) {
    print "\n    The Command Line Arguments are wrong!\n";
    print '    Please see help message by using "perl  CISDA-7.pl  -h" ';
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
if ( !(-e $output_g) )  { system("mkdir  -p  $output_g"); }
my $outputDir1 = "$output_g/run1";
my $outputDir2 = "$output_g/run2";
my $outputDir3 = "$output_g/run3";
my $outputDir4 = "$output_g/run4";
my $outputDir5 = "$output_g/run5";
if (!(-e $outputDir1))   {mkdir $outputDir1    or  die; } 
if (!(-e $outputDir2))   {mkdir $outputDir2    or  die; } 
if (!(-e $outputDir3))   {mkdir $outputDir3    or  die; } 
if (!(-e $outputDir4))   {mkdir $outputDir4    or  die; } 
if (!(-e $outputDir5))   {mkdir $outputDir5    or  die; } 




opendir(my $DH_input, $input_g) || die;     
my @inputFiles = readdir($DH_input);

my $NGSinput = "";
my $bool = 0;
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;    
    if($inputFiles[$i] =~ m/^input_/i) {
        $NGSinput = "$input_g/$inputFiles[$i]";  
        $bool++;
    }  
}
if ($bool != 1) { print  "#$bool#\n";  die;}
open(runFH, ">", "$output_g/runLog.txt")  or die;
print   runFH   "\nNGS input file: $NGSinput\n\n";
print   "        \nNGS input file: $NGSinput\n\n";




print "\n\n        Peak Calling......";
for(my $i=0; $i<=$#inputFiles; $i++) {
    next unless $inputFiles[$i] =~ m/\.bam$/;
    next unless $inputFiles[$i] !~ m/^[.]/;
    next unless $inputFiles[$i] !~ m/[~]$/;
    my $temp = $inputFiles[$i];
    $temp =~ s/\.bam$//  or  die;
    print  runFH  "\n        $temp......\n";
    print         "\n        $temp......\n";
    ## --bw=BW     Band width. This value is only used while building the shifting model.   DEFAULT: 300
    if ( !(-e "$outputDir1/$temp") )   {mkdir   "$outputDir1/$temp"    or  die; } 
    if ( !(-e "$outputDir2/$temp") )   {mkdir   "$outputDir2/$temp"    or  die; } 
    if ( !(-e "$outputDir3/$temp") )   {mkdir   "$outputDir3/$temp"    or  die; } 
    if ( !(-e "$outputDir4/$temp") )   {mkdir   "$outputDir4/$temp"    or  die; } 
    if ( !(-e "$outputDir5/$temp") )   {mkdir   "$outputDir5/$temp"    or  die; } 
    system(`macs14   --treatment=$input_g/$temp.bam   --control=$NGSinput   --name=$outputDir1/$temp/$temp   --format=BAM   --gsize=mm  --bw=300  --pvalue=1e-5   --mfold=10,30    --keep-dup=1   --on-auto                        >> $outputDir1/$temp.runLog.txt   2>&1`);                                                                                                           
    system(`macs14   --treatment=$input_g/$temp.bam   --control=$NGSinput   --name=$outputDir2/$temp/$temp   --format=BAM   --gsize=mm  --bw=300  --pvalue=1e-5   --mfold=10,30    --keep-dup=1   --nomodel   --shiftsize=100      >> $outputDir2/$temp.runLog.txt   2>&1`);                                                                                                           
    system(`macs14   --treatment=$input_g/$temp.bam   --control=$NGSinput   --name=$outputDir3/$temp/$temp   --format=BAM   --gsize=mm  --bw=300  --pvalue=1e-5   --mfold=10,30    --keep-dup=1   --diag      --fe-step=200        >> $outputDir3/$temp.runLog.txt   2>&1`);                                                                                                           
    system(`macs14   --treatment=$input_g/$temp.bam   --control=$NGSinput   --name=$outputDir4/$temp/$temp   --format=BAM   --gsize=mm  --bw=300  --pvalue=1e-5   --mfold=5,100    --keep-dup=1                                    >> $outputDir4/$temp.runLog.txt   2>&1`);     
    system(`macs14   --treatment=$input_g/$temp.bam   --control=$NGSinput   --name=$outputDir5/$temp/$temp   --format=BAM   --gsize=mm  --bw=200  --pvalue=1e-5   --mfold=10,30    --keep-dup=1   --diag      --fe-step=20         >> $outputDir5/$temp.runLog.txt   2>&1`);                                                                                                                                                                                                                 
}






print "\n\n        Job Done! Cheers! \n\n";

























