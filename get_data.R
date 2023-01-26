### Script for downloading data

### Get synapse credentials -- keep personal token in a text file named "synapse_auth"
get_synapse_credentials = function() {
	readLines("synapse_auth")
}

### Download synapse folder
download_synapse_data = function() {
	syn_cred = get_synapse_credentials()
	if(!file.exists("data")) {
		cmd1 = paste0("mkdir data; cd data; synapse -p ", syn_cred, " get -r syn50909160", sep = "")
		system("pip install synapseclient")
		system(cmd1)
	}
}

download_synapse_data()