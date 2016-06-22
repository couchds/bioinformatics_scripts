# to be run with 8 threads!

# $wp --> "workplace"

# script to align reference genome to reads

# one of the primates
species1=$1
# either human or macaque
species2=$2
# (i)nput or (c)EBPA
if [ "$species1" == "human" ]; then
	# didn't rename file containing human genome, so have to use different case.
	ref_genome_path=$wp/genomes/${species1}_genome/Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
else
	ref_genome_path=$wp/genomes/${species1}_genome/${species1}_toplevel.fa.gz
fi
if [ "$species2" == "macaque" ]; then
	prepath="mmul"
else
	prepath="human"
fi
if [ "$3" == "i" ]; then
	postpath="input"
elif [ "$3" == "c" ]; then
	postpath="CEBPA"
else
	echo "ERROR - ARGUMENT 3 MUST BE i OR c"
	exit
fi

# counter used to ID the alignment files.
counter=0
for ChIP_read in ${chip_read_path}/*_CRI01.fq.gz;
do
	$BWA mem -M -t 8 ${ref_genome_path} ${ChIP_read} > ${results_dir}/${1}_${2}_${postpath}_aln${counter}.sam
	counter=$((counter+1))
done
