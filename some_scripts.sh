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


# -------------------------------------------------------------------------------------------------------------------------------------------------

# Note: Didn't know this originally --- fa.gz files work with BWA! (Human genome after unzipping it is about 58 GB --- too large for BWA. 

# organism:  human, chimp, gorilla, macaque, or marmoset
organism=$1
file_name=""
possible_organisms=("human" "chimp" "gorilla" "macaque" "marmoset")
failed=0
# make sure it's a valid choice for organism
for org in "${possible_organisms[@]}"; do
	if [ org = "$1" ]; then
		break
	else
		failed=1
	fi
done


if [ $failed = 0 ]; then
	exit
fi

first="$1"
file_path=/nfs/research2/flicek/user/couch/genomes/${first}_genome
# human named differently...
bwa_path=/nfs/research2/flicek/user/couch/bwa/bwa/bwa
if [ "$1" = "human" ]; then
	target_file=Homo_sapiens.GRCh38.dna.primary_assembly.fa.gz
fi
$bwa_path index -a bwtsw $file_path/$target_file

#------------------------------------------------------------------------------------------------------------------------------------------

cd temp_results

# cool trick to use associative array in bash
species_associative_array=("human:homo_sapiens" "chimp:pan_troglodytes" "gorilla:gorilla_gorilla" "macaque:macaca_mulatta" "marmoset:callithrix_jacchus")
# for each .bed file, we map the coordinates
for species in "${species_associative_array[@]}";
do
	common_name=${species%%:*}
	scientific_name=${species#*:}
	if [ "$common_name" != "human" ];
	then
		perl ${scripts_dir}/map_primate_coordinates.pl -quer_name $scientific_name -quer_bed $human_bed/${common_name}_human_experiment_peaks.bed -ref_name homo_sapiens -out ${common_name}_to_human
	fi
	#if [ "$common_name" != "macaque" ];
	#then
	#	perl ${scripts_dir}/map_primate_coordinates.pl -quer_name $scientific_name -quer_bed $macaque_bed/${common_name}_macaque_experiment_peaks.bed -ref_name macaca_mulatta -out ${common_name}_to_macaque
	#fi
done
