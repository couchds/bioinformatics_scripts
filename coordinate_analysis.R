### Daniel Couch
### Script to analyze difference in genomic coordinates
### (based on very specific file format)


### Name of the file is formatted like this:
###             {non_ref}_to_{ref}.csv
### where {non_ref} is the non-reference genome,
### and {ref} is the reference genome
analyze <- function(non_ref, ref){
  file_name=paste(non_ref, "to", sep="_")
  file_name=paste(file_name, ref, sep="_")
  file_name=paste(file_name, "csv", sep=".")
  file_open=read.table(file_name, header = FALSE)
  diff_count=0
  same_count=0
  
  # convert column from type factor to list of strings
  chrom_column1=as.list(file_open[[1]])
  j <- sapply(chrom_column1, is.factor)
  chrom_column1[j] <- lapply(chrom_column1[j], as.character)
  
  parse_col=as.list(file_open[[4]])
  k <- sapply(parse_col, is.factor)
  parse_col[k] <- lapply(parse_col[k], as.character)
  
  x_coords_projected=as.list(file_open[[2]])
  l <- sapply(x_coords_projected, is.factor)
  x_coords_projected[l] <- lapply(x_coords_projected[k], as.integer)
  
  y_coords_projected=as.list(file_open[[3]])
  m <- sapply(y_coords_projected, is.factor)
  y_coords_projected[m] <- lapply(y_coords_projected[k], as.integer)
  
  total_dist=0
  distances=numeric(0)
  for (i in 1:length(chrom_column1)){
    col_string=as.character(parse_col[i])
    parsed_string1=unlist(strsplit(col_string, ":"))
    # now have vector ("chr#", "start-end") of the row
    chr_number_species=parsed_string1[1]
    projected_chr=chrom_column1[i]
    if (projected_chr == chr_number_species){
      # if the chromosome numbers ARE the same, compute distance between reads.
      parsed_string2=as.integer(unlist(strsplit(parsed_string1[2], "-")))
      projected_coordinates=c(
                              as.integer(x_coords_projected[i]),
                              as.integer(y_coords_projected[i])
                              )
      abs_max=max(sum(parsed_string2), sum(projected_coordinates))
      if (abs_max == sum(projected_coordinates)){
        high_coord=projected_coordinates
        low_coord=parsed_string2
      }
      else{
        high_coord=parsed_string2
        low_coord=projected_coordinates
      }
      distance=abs(high_coord[1]-low_coord[2])
      same_count=same_count+1
      distances=c(distances, distance)
      total_dist=total_dist+distance
    }
    else{
      diff_count=diff_count+1
    }
  }
  density_title=paste(non_ref, "and", sep=" ")
  density_title=paste(density_title, ref, sep=" ")
  d=density(distances)
  plot(d, 
       main=density_title, 
       xlab="Distance (%)", 
       col="black"
       )
  proportion_same_chromosome=same_count/(diff_count+same_count)
  average_dist=total_dist/same_count
  returnlist = list(proportion_same_chromosome, average_dist/1000)
}

analyze_all <- function(ref){
  if (ref != "human" && ref != "macaque"){
    return -1
  }
  primates=c("human", "chimp", "gorilla", "macaque", "marmoset")
  if (ref == "human"){
    evo_distance_times=c(5, 7, 25, 40)
  }
  else{
  # not sure about this
    evo_distance_times=c(25, 25, 40)
  }
  chromosome_counts=numeric(0)
  average_distance=numeric(0)
  for (primate in primates){
    if (primate != ref){
      results=count_diff_chromosomes(primate, ref)
      chromosome_counts=c(chromosome_counts, results[1])
      average_distance=c(average_distance, results[2])
    }
  }
  # Visualization:
  # - how often the coordinates map to the same chromosome
  # - how large the distance is between homochromosomal peaks
  title=paste("Rate of Conversion to Same Chromosome", ref, sep=": ")
  plot(
       x=evo_distance_times, 
       y=chromosome_counts, 
       col="black", 
       xlab="Divergence (MYA)",
       ylab="% Peaks Converted to Same Chromosome", 
       lwd=5, 
       main=title
       )
  title=paste("Average Distance between Coordinates on Same Chromosome", ref, sep=": ")
  plot(
    x=evo_distance_times, 
    y=average_distance, 
    col="black", 
    xlab="Divergence (MYA)",
    ylab="Distance between Coordinates (Kb)", 
    lwd=5, 
    main=title
  )
  return 
}
#analyze_all("human")
