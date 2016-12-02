#!/usr/bin/env perl
# This script save data to database

use Modern::Perl;       # modern syntax
use File::Basename;     # parsing names of files
use YAML::Tiny;         # open yml config
use DBI();              # database connection
use Try::Tiny;

#use strict;             # strict mode
use warnings;
use open ':std', ':encoding(UTF-8)';

#----------------------------------------------------------------------#
#                        Configuration                                 #
#----------------------------------------------------------------------#
my $build = "build/";
my $sql = "sql/";
my $parameters = 'config/parameters.yml';


my $yaml = YAML::Tiny->read( $parameters );
my $config = $yaml->[0]->{config};

#--------------------------------------------------------------#
#         Fix file structure broken by OCR inaccuracy          #
#--------------------------------------------------------------#
sub fixStructure
{
    s/mm/ram/g;
    s/\s(\d{3})\s(\d)\s/ $1$2 /g;
    s/\|\s//g;
    s/true/1/g;
    s/false/0/g;

    s/(\w+)\s(\w+)\s(\d{1,2}\/)/$1_$2 $3/g;
    s/North\s(\w+)/North_$1/g;
    s/West Virginia/West_Virginia/g;
    s/South Dakota/South_Dakota/g;
    s/Royal\s(\w+)/Royal_$1/g;
    s/New Jersey/New_Jersey/g;
    s/King George V/King_George_V/g;
    s/Pearl Harbor/Pearl_Harbor/g;
    s/Prince of Wales/Prince_of_Wales/g;
    s/Duke of York/Duke_of_York/g;
    s/Gt. Britain/Gt._Britain/g;
    s/\sStrait/_Strait/g;
};

#----------------------------------------------------------------------#
#                            Script                                    #
#----------------------------------------------------------------------#

        #--------------------------------------------------------------#
        #                      Loop over databases                     #
        #--------------------------------------------------------------#
my $baseNumber = 0;
for my $baseName (@{ $config->{"bases"} })
{
    print $baseNumber."\t".$baseName.".sql"."\n";

    #--------------------------------------------------------------#
    #  Reset database, put `sudo` before `mysql` if access error   #
    #--------------------------------------------------------------#

    my $passSting = ($config->{pass} eq "") ? "" : " -p ".$config->{pass};
    system('mysql -h '.$config->{host}.' -u '.$config->{user}.$passSting.' < '.$sql.$baseName.".sql");


    #--------------------------------------------------------------#
    #                 Connect to the database                      #
    #--------------------------------------------------------------#

    my $dbh = DBI->connect( "DBI:mysql:database=".$baseName.";host=".$config->{host},
        $config->{user}, $config->{pass}, {
            'PrintError'        => 0,
            'RaiseError'        => 1,
            'mysql_enable_utf8' => 1
        } ) or die "Connect to database failed";

            #--------------------------------------------------------------#
            #                     Loop over files                          #
            #--------------------------------------------------------------#

        my @files = <$build$baseNumber"/"*.txt>;
        foreach my $file (@files) {

            my $name = basename($file, ".txt");
            print $file."\t".$name."\n";
            open(my $fh, '<:encoding(UTF-8)', $file)
                or die "Could not open file '$file' $!";


            #--------------------------------------------------------------#
            #               Read all lines of given file                   #
            #--------------------------------------------------------------#

            my $index = 0; my $statement;
            while (<$fh>) {
            #--------------------------------------------------------------#
            #         Skip empty lines and cut new line signs              #
            #--------------------------------------------------------------#
                chomp;
                if(m/^\s*$/) {
                    next;
                }

                &fixStructure;

                my @row = split / /;
            #--------------------------------------------------------------#
            #   In first row define statement, in next ones execute them   #
            #--------------------------------------------------------------#
                if(!$index++){
                    my $query = "INSERT INTO $name (".join(",",@row).") VALUES (?". ",?"x(@row-1) .")";
                    print $query;
                    $statement = $dbh->prepare($query);
                } else {
                    print "@row\n";
                    s/_/ / for @row;
                    $statement->execute(@row);
                }

                print "\t" . $_ . "\n";
            }
        }

    #-----------------------------------------------------------#
    #                   Close connection                        #
    #-----------------------------------------------------------#
    $dbh->disconnect();
    $baseNumber++;
}