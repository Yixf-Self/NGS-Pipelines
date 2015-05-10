#!/usr/bin/env perl
use strict;
use warnings;




###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################




########## Help Infromation ##########
my $HELP_g = '
        Welcome to use RASDA (RNA-Seq Analyzer), version 0.1.5, 2015-04-21.    
        RASDA is a Pipeline for Single-end and Paired-end RNA-seq Data Analysis by Integrating Lots of Softwares.

        Step 1: Remove adaptors and PCR primers, trim and filter the reads by using Trimmomatic,  and quality statistics by using FastQC, NGS_QC_Toolkit and FASTX-toolkit.
        Required softwares in this step: Trimmomatic, FastQC, NGS_QC_Toolkit and FASTX-toolkit.
  
        Usage: 
               perl  RASDA-1.pl    [-v]    [-h]    [-s boole]    [-i inputDir]    [-o outDir]  

        For instance: 
                     perl  RASDA-1.pl      -p yes       -i 1-FASTQ          -o 2-Filtered           
                     perl  RASDA-1.pl      --paired yes    --input 1-FASTQ     --output 2-Filtered    
 
        
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------
        Optional arguments:

        -v, --version        Show version number of this program and exit

        -h, --help           Show this help message and exit


        Required arguments:

        -p boole,  --paired boole             All the reads are paired-end (yes) or single-end (no). ("yes" or "no").  
                                              (no default)

        -i inputDir,  --input inputDir        inputDir is the name of input folder that contains your FASTQ files,
                                              the suffix of the FASTQ files must be ".fastq".    (no default)

        -o outDir,  --output outDir           outDir is the name of output folder that contains running 
                                              results (fastq format) of this step.      (no default)
                                              The suffix of two paired-end sequencing files: "XXX_1.fastq"  and   "XXX_2.fastq"                            
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------


        Yong Peng @ He lab, yongpeng@email.com, Academy for Advanced Interdisciplinary Studies 
        and Center for Life Sciences (CLS), Peking University, China.     
  
';

my $version_g = "  RASDA (RNA-Seq Analyzer), version 0.1.5, 2015-04-21";



########## Keys and Values ##########
if ($#ARGV   == -1) { print  "\n$HELP_g\n\n";  exit 0; }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0) { @ARGV = (@ARGV, "-h");           }       ## when the number of command argumants is odd. 
my %args = @ARGV;



########## Initialize  Variables ##########
my $paired_g = 'yes';          ## This is only an initialization  value or suggesting value, not default value. (yes || no)    
my $input_g  = '1-FASTQ';      ## This is only an initialization  value or suggesting value, not default value.
my $output_g = '2-Filtered';   ## This is only an initialization  value or suggesting value, not default value.


########## Available Arguments ##########
my $available = "-v  --version    -h  --help    -p  --paired    -i  --input    -o    --output";
my $boole_g = 0;
while( my ($key, $value) = each %args ) {
    if($available !~ m/$key/) {print  "    Cann't recognize $key\n";  $boole_g = 1; }
}
if($boole_g == 1) {
    print "\n    The Command Line Arguments are wrong!\n";
    print '    Please see help message by using "perl  RASDA-1.pl  -h" ';
    print "\n\n";
    exit 0;
}



########## Get Arguments ##########
if ( ( exists $args{'-v' } )  or  ( exists $args{'--version' } )  )     { print  "\n$version_g\n\n";    exit 0; }
if ( ( exists $args{'-h' } )  or  ( exists $args{'--help'    } )  )     { print  "\n$HELP_g\n\n";       exit 0; }
if ( ( exists $args{'-p' } )  or  ( exists $args{'--paired'  } )  )     { ($paired_g = $args{'-p' })  or  ($paired_g = $args{'--paired'});  }else{print   "\n -p or --paired is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }      
if ( ( exists $args{'-i' } )  or  ( exists $args{'--input'   } )  )     { ($input_g  = $args{'-i' })  or  ($input_g  = $args{'--input' });  }else{print   "\n -i or --input  is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }                                               
if ( ( exists $args{'-o' } )  or  ( exists $args{'--output'  } )  )     { ($output_g = $args{'-o' })  or  ($output_g = $args{'--output'});  }else{print   "\n -o or --output is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }      



########### Conditions #############
$paired_g =~ m/^(yes)|(no)$/  ||  die   "\n$HELP_g\n\n";
$input_g  =~ m/^\S+$/         ||  die   "\n$HELP_g\n\n";
$output_g =~ m/^\S+$/         ||  die   "\n$HELP_g\n\n";



######### Print Command Arguments to Standard Output ###########
print  "\n\n
        ################ Your Arguments ###############################
                Paired-end reads:  $paired_g
                Input  folder:     $input_g
                Output folder:     $output_g
        ###############################################################  
\n\n";


###################################################################################################################################################################################################
###################################################################################################################################################################################################
###################################################################################################################################################################################################










print "\n        Running......\n";

if ( !(-e $output_g) )  { mkdir $output_g || die; }

opendir(my $DH_input, $input_g) || die;      
my @fastqFiles = readdir($DH_input);

if ($paired_g eq "yes") {
    for (my $i=0; $i<=$#fastqFiles; $i++) {
        next unless $fastqFiles[$i] =~ m/\.fastq$/; 
        next unless $fastqFiles[$i] !~ m/^[.]/;
        next unless $fastqFiles[$i] !~ m/[~]$/; 
        print  "$fastqFiles[$i]\n";
        if( $fastqFiles[$i] =~ m/^(\S+)_1.fastq$/ ) {
            my $temp = $1;   
            my $end1 = $temp."_1.fastq";
            my $end2 = $temp."_2.fastq";
            open(tempFH, ">>", "$output_g/paired-end-files.txt")  or  die;
            print  tempFH  "$end1,  $end2\n";
            system("trimmomatic-0.32.jar  PE   -threads 12     $input_g/$end1  $input_g/$end2           $output_g/$end1  $output_g/unpaired-$end1    $output_g/$end2  $output_g/unpaired-$end2        ILLUMINACLIP:0-Other/TruSeqAdapter/PairedEnd.fasta:1:30:10   LEADING:3   TRAILING:3   SLIDINGWINDOW:4:15   MINLEN:25    >>$output_g/$temp.run=trimmomatic.runLog  2>&1");                       
        }
    }
}else{
    $paired_g eq "no"   ||  die;
    for (my $i=0; $i<=$#fastqFiles; $i++) {    
        my $file = $fastqFiles[$i];
        next unless $file =~ m/\.fastq$/;
        next unless $file !~ m/^[.]/;
        next unless $file !~ m/[~]$/;
        my $temp = $file; 
        $temp =~ s/\.fastq$//  ||  die;
        system("trimmomatic-0.32.jar  SE   -threads 12     $input_g/$temp.fastq  $output_g/$temp.fastq    ILLUMINACLIP:0-Other/TruSeqAdapter/SingleEnd.fasta:1:30:10   LEADING:3   TRAILING:3   SLIDINGWINDOW:4:15   MINLEN:25    >>$output_g/$temp.run=trimmomatic.runLog  2>&1");                    
        ##system("rm   $input_g/$temp.fastq");  
    }
}















my $FastQCdir       = "$output_g/FastQC";
my $FastQCdir_10mer = "$output_g/FastQC_10mer";
my $NGSQCToolkit    = "$output_g/NGSQCToolkit";
my $FASTXtoolkit    = "$output_g/FASTXtoolkit";

if ( !( -e $FastQCdir)       )   { mkdir $FastQCdir        ||  die; }
if ( !( -e $FastQCdir_10mer) )   { mkdir $FastQCdir_10mer  ||  die; }
if ( !( -e $NGSQCToolkit)    )   { mkdir $NGSQCToolkit     ||  die; }
if ( !( -e $FASTXtoolkit)    )   { mkdir $FASTXtoolkit     ||  die; }

my $NGSqcperl = "/home/yongp/ProgramFiles/3-NGStools/NGSQCToolkit_v2.3.3/QC/IlluQC.pl";

opendir(my $DH_output, $output_g)  ||  die;  

     
while ( my $file = readdir($DH_output) ) {        
    next unless $file =~ m/\.fastq$/; 
    next unless $file !~ m/^[.]/;
    next unless $file !~ m/[~]$/;
    my $temp = $file; 
    $temp =~ s/\.fastq$//  ||  die;
    system( "fastqc    --outdir $FastQCdir          --threads 10    --kmers 7     $output_g/$temp.fastq       >> $FastQCdir/$temp.run=fastqc.runLog         2>&1" );  
    system( "fastqc    --outdir $FastQCdir_10mer    --threads 10    --kmers 10    $output_g/$temp.fastq       >> $FastQCdir_10mer/$temp.run=fastqc.runLog   2>&1" );  
    if ( !(-e "$NGSQCToolkit/$temp") )   { mkdir  "$NGSQCToolkit/$temp"  ||  die; }
    system( "perl  $NGSqcperl  -se $output_g/$temp.fastq   N  A    -processes 10   -onlyStat    -outputFolder $NGSQCToolkit/$temp         >> $NGSQCToolkit/$temp/$temp.run=IlluQC.runLog   2>&1" );      
    system( "fastx_quality_stats                        -i $output_g/$temp.fastq                    -o $FASTXtoolkit/$temp.txt            >> $FASTXtoolkit/$temp.run=FASTXtoolkit.runLog   2>&1" ); 
    system( "fastq_quality_boxplot_graph.sh             -i $FASTXtoolkit/$temp.txt     -t $temp     -o $FASTXtoolkit/$temp.quality.png    >> $FASTXtoolkit/$temp.run=FASTXtoolkit.runLog   2>&1" ); 
    system( "fastx_nucleotide_distribution_graph.sh     -i $FASTXtoolkit/$temp.txt     -t $temp     -o $FASTXtoolkit/$temp.nucDis.png     >> $FASTXtoolkit/$temp.run=FASTXtoolkit.runLog   2>&1" ); 
}





## for paired-end sequencing:
my @pairedEndFiles = readdir($DH_output);

for (my $i=0; $i<=$#pairedEndFiles; $i++) {
    next unless $pairedEndFiles[$i] =~ m/\.fastq$/; 
    next unless $pairedEndFiles[$i] !~ m/^[.]/;
    next unless $pairedEndFiles[$i] !~ m/[~]$/; 
    print  "$pairedEndFiles[$i]\n";
    if( $pairedEndFiles[$i] =~ m/^(\S+)_1.fastq$/ ) {
        my $temp = $1;   
        my $NGSQCToolkitPaired = "$output_g/NGSQCToolkitPaired";
        if ( !( -e $NGSQCToolkitPaired)    )   { mkdir $NGSQCToolkitPaired     ||  die; }
        open(tempFH, ">>", "$NGSQCToolkitPaired/paired-end-files.txt")  or  die;
        my $end1 = $temp."_1.fastq";
        my $end2 = $temp."_2.fastq";
        print  tempFH  "$end1,  $end2\n";
        if ( !(-e "$NGSQCToolkitPaired/$temp") )   { mkdir  "$NGSQCToolkitPaired/$temp"  ||  die; }
        system( "perl  $NGSqcperl   -pe $output_g/$end1   $output_g/$end2   N  A     -processes 10   -onlyStat    -outputFolder $NGSQCToolkit/$temp    >> $NGSQCToolkit/$temp/$temp.run=IlluQC.runLog  2>&1" ); 
    }
}




print "\n            Done!\n";






