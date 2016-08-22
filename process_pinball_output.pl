#!/usr/bin/perl
### Daniel Couch
# process_pinball_output.pl
# Get cluster IDs of given size, then retrieve FASTA sequence of clusters

use strict;
use warnings;
use Bio::DB::Fasta;

my $num_args = @ARGV;

my $usage="process_pinball_output.pl [output from pinball] [cluster fastas] [csize] [name of file to write to]";

my $pinball_output = shift @ARGV;
my $fasta_file = shift @ARGV;
my $csize_filter = shift @ARGV;
my $output_file = shift @ARGV;
if ($num_args != 4){
        print $num_args . "\n";
        print $usage;
        exit;
}
my @fasta_ids = ();
my @column_fields = ();
my $current_size = 0;
my $current_id = "I hope this isn't the ID of a cluster.";
open (my $fh, '<', $pinball_output) or die "Can't open file < $pinball_output: $!";
while (my $row = <$fh>){
        # Cluster size given by entry in second column.
        my @split_row = split("\t", $row);
        my $cluster_id = $split_row[0];
        if ($current_id eq $cluster_id){
                # do nothing if we're on the same cluster.
        }
        else{
                $current_id = $cluster_id;
                my $cluster_size = $split_row[1];
                if ($cluster_size >= $csize_filter){
                        push @fasta_ids, $cluster_id;
                }
        }
}
close $fh;


### Retrieve FASTA sequences from the cluster IDs

# BioPerl database built from FASTA sequences, very fast indexing.
my $db = Bio::DB::Fasta->new($fasta_file);
my @ids = $db->get_all_primary_ids;
open (my $fho, ">",  $output_file) or die "Could not open $output_file: $!";
# Search for 
# Personal note: Could be made more efficient (~O(n)) by first naturally sorting @ids
for my $i (0 .. $#fasta_ids)
{
        my $filtered_id_start = $fasta_ids[$i] . "-";
        #print $filtered_id_start . "\n";
        for my $j (0 .. $#ids)
        {
                if ($ids[$j] =~ /^$filtered_id_start/){
                        my $id = $ids[$j] . "\n";
                        my $seq_out = $db->seq($id) . "\n";
                        my $id_out = ">" . $id;
                        print $fho $id_out;
                        print $fho $seq_out;
                        last;
                }
        }
}
close $fho;
