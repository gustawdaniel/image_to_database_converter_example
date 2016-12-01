#!/usr/bin/env perl
# This script save data to database

use Modern::Perl;       # modern syntax
use File::Basename;     # parsing names of files
use DBI();              # database connection

use strict;             # strict mode
use warnings;
use open ':std', ':encoding(UTF-8)';

#----------------------------------------------------------------------#
#                        Configuration                                 #
#----------------------------------------------------------------------#
my $build = "build/";
my $sql = "sql/main.sql";

my %base = (
    name => "electronic_store",
    user => "root",
    pass => "",
    host => "localhost"
);

#----------------------------------------------------------------------#
#                            Script                                    #
#----------------------------------------------------------------------#

        #--------------------------------------------------------------#
        #  Reset database, put `sudo` before `mysql` if access error   #
        #--------------------------------------------------------------#

    my $passSting = ($base{pass} eq "") ? "" : " -p ".$base{pass};
    system('mysql -h '.$base{host}.' -u '.$base{user}.$passSting.' < '.$sql);

        #--------------------------------------------------------------#
        #                 Connect to the database                      #
        #--------------------------------------------------------------#

    my $dbh = DBI->connect("DBI:mysql:database=".$base{name}.";host=".$base{host},
    $base{user}, $base{pass}, {
        'PrintError'         => 0,
        'RaiseError'         => 1,
        'mysql_enable_utf8'  => 1
    }) or die "Connect to database failed";

        #--------------------------------------------------------------#
        #                     Loop over files                          #
        #--------------------------------------------------------------#

    my @files = <$build*.txt>;
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
        #--------------------------------------------------------------#
        #         Fix file structure broken by OCR inaccuracy          #
        #--------------------------------------------------------------#
            {
                s/mm/ram/g;
                s/\s(\d{3})\s(\d)\s/ $1$2 /g;
                s/\|\s//g;
                s/true/1/g;
                s/false/0/g;
            };

            my @row = split / /;
        #--------------------------------------------------------------#
        #   In first row define statement, in next ones execute them   #
        #--------------------------------------------------------------#
            if(!$index++){
                my $query = "INSERT INTO $name (".join(",",@row).") VALUES (?". ",?"x(@row-1) .")";
                $statement = $dbh->prepare($query);
            } else {
                $statement->execute(@row);
            }

            print "\t" . $_ . "\n";
        }
    }

        #-----------------------------------------------------------#
        #                   Close connection                        #
        #-----------------------------------------------------------#
    $dbh->disconnect();
