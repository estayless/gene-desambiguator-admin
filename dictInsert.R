# Insert a collection into a database
#generate the connection with the settings
dictInsert<-function(user, password, cluster, db, collection, dictClean){
  #connection
  collConn<-collectionConnection(user, password, cluster, db, collection)
  #insert
  collConn$insert(dictClean)
  #disconnect 
  collConn$disconnect()
}