#!/usr/bin/perl
### Daniel Couch
### get_highest_scoring.pl
### Script to (1) get IDs of highest (bit)scoring BLAST alignments and
### (2) perform motif analysis on these alignments.
use strict;
use warnings;
use Bio::DB::Fasta;

my $num_args = @ARGV;
my $usage="get_highest_scoring.pl [output from blast] [fasta file] [output file]";
my $blast_output = shift @ARGV;
my $fasta_file = shift @ARGV;
my $output_file = shift @ARGV;

if ($num_args != 3){
        print $num_args . "\n";
        print $usage;
        exit;
}

### Make clusters appear uniquely in file.
my $unique_output = $blast_output . "_unique";
my $unique_command = "sort -uk1,1 $blast_output > $unique_output";
system($unique_command);
### Sort by bitscore (12th column).
my $sort_output = $blast_output . "_sorted";
my $sort_command = "sort -k 12 $unique_output > $sort_output";
system($sort_command);
system("rm $unique_output");

my @fasta_ids = ();
my @column_fields = ();
### Get first 1000 clusters from sorted file.
open(my $fh, "<", $sort_output) or die "Can't open file < $sort_output: $!";
### Column 1 contains FASTA/cluster ID.
my $row = <$fh>;
my $i = 1;
for ($i = 1; $i <= 1000; $i++){
        $row = <$fh>;
        @column_fields = split("\t", $row);
        push @fasta_ids, @column_fields[0] . "\n";
}
close $fh;
my @fasta_sequences = ();
my @fasta_ids_copy = @fasta_ids;
### Extract FASTA sequences
my $db = Bio::DB::Fasta->new($fasta_file);
while(my $current_id=shift(@fasta_ids_copy))
{
        push @fasta_sequences, $db->seq($current_id) . "\n";
}
my $num_sequences = @fasta_sequences;
### Arbitrary...
my $id_out = "a";
my $seq_out = "a";
### Write sequences.
open (my $fho, ">",  $output_file) or die "Could not open $output_file: $!";
$i = 1;
for ($i = 1; $i <= 1000; $i++){
        $id_out = pop @fasta_ids;
        $seq_out = pop @fasta_sequences;
        print $fho $id_out;
        print $fho $seq_out;
}
close $fho;
