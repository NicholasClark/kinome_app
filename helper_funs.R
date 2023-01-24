#### Helper functions


### Get synapse credentials
get_synapse_credentials = function() {
  readLines("synapse_auth")
}

### Download synapse folder
download_synapse_data = function() {
  syn_cred = get_synapse_credentials()
  cmd1 = paste0("cd data; synapse -p ", syn_cred, " get -r syn50909160", sep = "")
  system("pip install synapseclient")
  system(cmd1)
}