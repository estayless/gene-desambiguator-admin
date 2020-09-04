# Script for load the complete Mammalia gene info 
library(mongolite)
library(dplyr)
library(taxize)
source("dbConnection/collectionConnection.R")
source("dictInsert.R")

# Read the file
fileName<-"../../datasets/All_Mammalia.gene_info"
dict<-as_tibble(read.delim(fileName, header = TRUE, sep = "\t", fill = TRUE))

# Select columns to insert
dictClean<- dict %>%
  select(tax_id, dbXrefs, GeneID, Symbol, Synonyms,
         description, Symbol_from_nomenclature_authority,
         Full_name_from_nomenclature_authority,
         Other_designations)

## Begin index creation
# obtain the taxon id
taxons<-dictClean %>%
  select(tax_id)

# chunk the taxons into 3, for add cluster number
# get the list of uniques taxones ID, and assign the number of the cluster
taxon1<-as_tibble(unique(taxons$tax_id[1:1567469]))
taxon1<- taxon1 %>%
  mutate(cluster_N = 1)

taxon2<-as_tibble(unique(taxons$tax_id[1567470:3030405]))
taxon2<- taxon2 %>%
  mutate(cluster_N = 2)

taxon3<-as_tibble(unique(taxons$tax_id[3030406:4487898]))
taxon3<- taxon3 %>%
  mutate(cluster_N = 3)

# bind the taxons id lists
taxons<-bind_rows(taxon1, taxon2, taxon3)
# assign columname 
taxons<-taxons %>% rename(tax_id = value)
# use taxize for obtain the name of the taxon id
taxons<-mutate(taxons, tax_name = (ncbi_get_taxon_summary(id = .data[["tax_id"]]))$name)
## End index creation

# settings for all connections
user<-"<username>"
password<-"<password>"
db<-"DictMammalia-01"

# setting for the collection and cluster for index
collection<-"index"
cluster1<-"dictmammalia-01-fceex.mongodb.net/test"
# insert index into Atlas cluster
dictInsert(user, password, cluster1, db, collection, taxons)

# setting for the collections for dictionaries
collection<-"dict"

# transform the dictionary into a data frame for chunk
dictClean<- as.data.frame(dictClean)

# chunk the dictionary
dict1<-dictClean[1:1567469,]
# settings for the chunk cluster insert
cluster1<-"dictmammalia-01-fceex.mongodb.net/test"
# insert the chunk into the cluster
dictInsert(user, password, cluster1, db, collection, dict1)

dict2<-dictClean[1567470:3030405,]
cluster2<-"dictmammalia-01-qifzg.mongodb.net/test"
dictInsert(user, password, cluster2, db, collection, dict2)
  
dict3<-dictClean[3030406:4487898,]
cluster3<-"dictmammalia-01-gwjzt.mongodb.net/test"
dictInsert(user, password, cluster3, db, collection, dict3)
