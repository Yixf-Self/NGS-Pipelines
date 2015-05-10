#!/usr/bin/env perl
use strict;
use warnings;



###################################################################################################################################################################################################
###################################################################################################################################################################################################


########## Help Infromation ##########
my $HELP_g = '
        Welcome to use CISDA (ChIp-Seq Analyzer), version 0.1.5, 2015-04-21.    
        CISDA is a Pipeline for Single-end and Paired-end ChIP-seq Data Analysis by Integrating Lots of Softwares.

        Step 0: Convert SRA format to fastq format,  and quality statistics by using FastQC, NGS_QC_Toolkit and FASTX-toolkit.
        Required softwares in this step: SRAtoolKit, FastQC, NGS_QC_Toolkit and FASTX-toolkit.
  
        Usage: 
               perl  CISDA-0.pl    [-v]    [-h]    [-s boole]    [-i inputDir]    [-o outDir]  

        For instance: 
                     perl  CISDA-0.pl      -s yes       -i 0-SRA          -o 1-FASTQ           
                     perl  CISDA-0.pl      --sra yes    --input 0-SRA     --output 1-FASTQ    
 
        
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------
        Optional arguments:

        -v, --version        Show version number of this program and exit

        -h, --help           Show this help message and exit


        Required arguments:

        -s boole,  --sra boole                Whether need to convert SRA format to fastq fromat. ("yes" or "no").  
                                              (no default)

        -i inputDir,  --input inputDir        inputDir is the name of input folder that contains your SRA files,
                                              the suffix of the SRA files must be ".sra".    (no default)

        -o outDir,  --output outDir           outDir is the name of output folder that contains running 
                                              results (fastq format) of this step.      (no default)
                                              The suffix of two paired-end sequencing files: "XXX_1.fastq"  and   "XXX_2.fastq"                            
        ---------------------------------------------------------------------------------------------------------------------------------------------------------------


        Yong Peng @ He lab, yongpeng@email.com, Academy for Advanced Interdisciplinary Studies 
        and Center for Life Sciences (CLS), Peking University, China.     
  
';

my $version_g = "    CISDA (ChIp-Seq Analyzer), version 0.1.5, 2015-04-21";


########## Keys and Values ##########
if ($#ARGV   == -1) { print  "\n$HELP_g\n\n";  exit 0; }       ## when there are no any command argumants.
if ($#ARGV%2 ==  0) { @ARGV = (@ARGV, "-h");           }       ## when the number of command argumants is odd. 
my %args = @ARGV;


########## Initialize  Variables ##########
my $SRA_g    = 'yes';       ## This is only an initialization  value or suggesting value, not default value. (yes || no)    
my $input_g  = '0-SRA';     ## This is only an initialization  value or suggesting value, not default value.
my $output_g = '1-FASTQ';   ## This is only an initialization  value or suggesting value, not default value.


########## Available Arguments ##########
my $available = "-v  --version    -h  --help    -s  --sra    -i  --input    -o    --output";
my $boole_g = 0;
while( my ($key, $value) = each %args ) {
    if($available !~ m/$key/) {print  "    Cann't recognize $key\n";  $boole_g = 1; }
}
if($boole_g == 1) {
    print "\n    The Command Line Arguments are wrong!\n";
    print '    Please see help message by using "perl  CISDA-0.pl  -h" ';
    print "\n\n";
    exit 0;
}


########## Get Arguments ##########
if ( ( exists $args{'-v' } )  or  ( exists $args{'--version' } )  )     { print  "\n$version_g\n\n";    exit 0; }
if ( ( exists $args{'-h' } )  or  ( exists $args{'--help'    } )  )     { print  "\n$HELP_g\n\n";       exit 0; }
if ( ( exists $args{'-s' } )  or  ( exists $args{'--sra'     } )  )     { ($SRA_g    = $args{'-s' })  or  ($SRA_g    = $args{'--sra'   });  }else{print   "\n -s or --sra    is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }      
if ( ( exists $args{'-i' } )  or  ( exists $args{'--input'   } )  )     { ($input_g  = $args{'-i' })  or  ($input_g  = $args{'--input' });  }else{print   "\n -i or --input  is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }                                               
if ( ( exists $args{'-o' } )  or  ( exists $args{'--output'  } )  )     { ($output_g = $args{'-o' })  or  ($output_g = $args{'--output'});  }else{print   "\n -o or --output is required.\n\n";   print  "\n$HELP_g\n\n";       exit 0; }      


########### Conditions #############
$SRA_g    =~ m/^(yes)|(no)$/  ||  die   "\n$HELP_g\n\n";
$input_g  =~ m/^\S+$/         ||  die   "\n$HELP_g\n\n";
$output_g =~ m/^\S+$/         ||  die   "\n$HELP_g\n\n";



######### Print Command Arguments to Standard Output ###########
print  "\n\n
        ################ Your Arguments ###############################
                Whether need to convert SRA format to fastq:  $SRA_g
                Input  folder:  $input_g
                Output folder:  $output_g
        ###############################################################  
\n\n";

###################################################################################################################################################################################################
###################################################################################################################################################################################################






print   "\n        Running......";



if ( !(-e $output_g) )  { mkdir $output_g  ||  die; }

if ($SRA_g eq "yes") {
    opendir(my $DH_input, $input_g) || die;      
    while ( my $file = readdir($DH_input) ) {     
        next unless $file =~ m/\.sra$/;
        next unless $file !~ m/^[.]/;
        next unless $file !~ m/[~]$/;
        my $temp = $file; 
        $temp =~ s/\.sra//  ||  die;
        system("fastq-dump   --split-3   --dumpbase    $input_g/$temp.sra      --outdir  $output_g      >> $output_g/$temp.run=fastq-dump.runLog  2>&1");
    }
}else{
    $SRA_g eq "no"   ||  die;
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
    $temp =~ s/\.fastq//  ||  die;
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













