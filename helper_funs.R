#### Helper functions

### Convert uniprot names to symbols ("nice" versions w/ residue numbers)
# input: uniprot_name_nice
# output: symbol_nice
convert_uniprot_to_symbol_nice = function(uniprot) {
	#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	meta$symbol_nice[ match(uniprot, meta$uniprot_name_nice) ]
}

### Get uniprot name from symbol
# input: symbol_nice
# output: uniprot_name_nice
get_uniprot_name_nice_from_symbol = function(symbol) {
	#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	uni = meta$uniprot_name_nice[which(meta$symbol_nice == symbol)]
	return(uni)
}

get_uniprot_id_from_symbol = function(symbol) {
	#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	id = meta$`Uniprot Entry`[which(meta$HGNC_Symbol == symbol)]
	return(id)
}

### look up filename from symbol -- for files from AF2 database
af_db_file_from_symbol = function(symbol) {
	dir = file.path("data", "protein_structures", "AlphaFold", "full_proteins", "v4")
	id = meta$`Uniprot Entry`[which(meta$HGNC_Symbol == symbol)]
	file = paste0("AF-", id, "-F1-model_v4.pdb", sep = "")
	full_file = file.path(dir, file)
	return(full_file)
}

### look up filename from symbol -- for files manually generated from AF2
# input: symbol_nice
# output: pdb file name (manually generated files)
af_manual_file_from_symbol = function(symbol) {
	dir = file.path("data", "protein_structures", "AlphaFold", "kinase_domains")
	uni = get_uniprot_name_nice_from_symbol(symbol)
	file = paste0(uni, ".pdb", sep = "")
	full_file = file.path(dir, file)
	return(full_file)
}

af_file_from_symbol = function(symbol) {
	file_db = af_db_file_from_symbol(symbol)
	file_manual = af_manual_file_from_symbol(symbol)
	if(file.exists(file_db)) {
		return(file_db)
	} else if(file.exists(file_manual)) {
		return(file_manual)
	} else {
		stop("File not found")
	}
}

### read a pdb and trim it to just the kinase domain -- write to new pdb file
### return the filename of the trimmed pdb
read_and_trim_pdb = function(pdb_file, gene1) {
	pdb1 = Rpdb::read.pdb( pdb_file )
	ff1 = file.path(tempdir(), paste0(gene1, ".pdb", sep = ""))
	Rpdb::write.pdb(pdb1, file = ff1)
	dat_file1 = ff1
	### trim the pdb with bio3d
	pdb1 = bio3d::read.pdb( ff1 )
	# get start and stop indices (for structure from database)
	start1 = meta %>% filter(symbol_nice == gene1) %>% extract2("DomainStart")
	end1 = meta %>% filter(symbol_nice == gene1) %>% extract2("DomainEnd")
	
	ff1_sub = file.path(tempdir(), paste0(gene1, "_sub", ".pdb", sep = ""))
	
	### Trim pdb files
	is_gene1_from_db = file.exists(af_db_file_from_symbol(gene1))
	pdb1_sub = pdb1
	if(is_gene1_from_db) {
		domain_annot1_exists = !(is.na(start1) || is.na(end1))
		if(domain_annot1_exists) {
			pdb1_sub = trim.pdb(pdb1, inds = atom.select(pdb1, resno = start1:end1))
		}
	}
	bio3d::write.pdb(pdb1_sub, file = ff1_sub)
	dat_file1 = ff1_sub
	return(dat_file1)
}

### reads in gene2 pdb and rotates it to align the kinase domain with that of gene1
### if trim == TRUE, it trims the pdb to its kinase domain as well
### returns the filename of the rotated pdb for gene2
read_and_rotate_pdb = function(gene1, gene2, trim = FALSE) {
	tmp_df = tm_df %>% filter(kinase1 == gene1, kinase2 == gene2)
	
	pdb2_file = af_file_from_symbol(gene2)
	pdb2 = Rpdb::read.pdb( pdb2_file )
	pdb2_rot = pdb2 %>% 
		Txyz(x = -tmp_df$xt,
			 y = -tmp_df$yt,
			 z = -tmp_df$zt) %>%
		Rx(-tmp_df$x_angle) %>%
		Ry(-tmp_df$y_angle) %>%
		Rz(-tmp_df$z_angle)
	
	### write temporary file
	ff2 = file.path(tempdir(), paste0(gene2, ".pdb", sep = ""))
	Rpdb::write.pdb(pdb2_rot, file = ff2)
	if(trim) {
		ff2 = read_and_trim_pdb(ff2, gene2)
	}
	return(ff2)
}


align_kinases = function(gene1, gene2, color1 = "#00cc96", color2 = "yellow", domain_only = F) {
	### If no second gene, just display the first one
	if(gene1 == "" && gene2 == "") {
		obj = r3dmol()
		return(obj)
	} else if(gene2 == "") {
		if(domain_only) {
			pdb1_file = af_file_from_symbol(gene1)
			dat_file = read_and_trim_pdb(pdb1_file, gene1)
		} else {
			dat_file = af_file_from_symbol(gene1)
		}
		obj = r3dmol() %>%
			m_add_model(data = dat_file) %>%
			m_set_style(style = m_style_cartoon(color = color1)) %>%
			m_zoom_to()
		return(obj)
	} else if(gene1 == ""){
		if(domain_only) {
			pdb_file = af_file_from_symbol(gene2)
			dat_file = read_and_trim_pdb(pdb_file, gene2)
		} else {
			dat_file = af_file_from_symbol(gene2)
		}
		obj = r3dmol() %>%
			m_add_model(data = dat_file) %>%
			m_set_style(style = m_style_cartoon(color = color1)) %>%
			m_zoom_to()
		return(obj)
	} else {
		if(domain_only) {
			pdb1_file = af_file_from_symbol(gene1)
			dat_file1 = read_and_trim_pdb(pdb1_file, gene1)
			
			#pdb2_file = af_file_from_symbol(gene2)
			dat_file2 = read_and_rotate_pdb(gene1, gene2, trim = TRUE)
		} else {
			dat_file1 = af_file_from_symbol(gene1)
			dat_file2 = read_and_rotate_pdb(gene1, gene2, trim = FALSE)
		}
		obj = r3dmol() %>%
			m_add_model(data = dat_file1) %>%
			m_set_style(style = m_style_cartoon(color = color1)) %>%
			m_zoom_to() %>%
			m_add_model(data = dat_file2) %>%
			m_set_style(
				sel = m_sel(model = -1),
				style = m_style_cartoon(color = color2)
			) %>%
 			m_zoom_to()
		return(obj)
 	}
# 	
# 	
# 	tmp_df = tm_df %>% filter(kinase1 == gene1, kinase2 == gene2)
# 	
# 	tm1 = tm_df %>% filter(kinase1 == gene1, kinase2 == gene2) %>% extract2("tm_score")
# 	tm2 = tm_df %>% filter(kinase1 == gene2, kinase2 == gene1) %>% extract2("tm_score")
# 	print(tm1)
# 	print(tm2)
# 
# 	pdb1_file = af_file_from_symbol(gene1)
# 	pdb2_file = af_file_from_symbol(gene2)
# 	
# 	pdb1 = Rpdb::read.pdb( pdb1_file )
# 	pdb2 = Rpdb::read.pdb( pdb2_file )
# 	
# 	### rotate and translate pdb
# 	#pdb1_rot = pdb1 %>% Rz(tmp_df$z_angle) %>%  Ry(tmp_df$y_angle) %>% Rx(tmp_df$x_angle)  %>% Txyz(x = tmp_df$xt, y = tmp_df$yt, z = tmp_df$zt)
# 	pdb2_rot = pdb2 %>%  Txyz(x = -tmp_df$xt, y = -tmp_df$yt, z = -tmp_df$zt) %>% Rx(-tmp_df$x_angle) %>%  Ry(-tmp_df$y_angle) %>% Rz(-tmp_df$z_angle)
# 	
# 	### write temporary file
# 	ff1 = file.path(tempdir(), paste0(gene1, ".pdb", sep = ""))
# 	ff2 = file.path(tempdir(), paste0(gene2, ".pdb", sep = ""))
# 	#Rpdb::write.pdb(pdb1_rot, file = ff1)
# 	Rpdb::write.pdb(pdb1, file = ff1)
# 	Rpdb::write.pdb(pdb2_rot, file = ff2)
# 	
# 	dat_file1 = ff1
# 	dat_file2 = ff2
# 	if(domain_only) {
# 		### trim the pdb with bio3d
# 		pdb1 = bio3d::read.pdb( ff1 )
# 		pdb2 = bio3d::read.pdb( ff2 )
# 		# get start and stop indices (for structure from database)
# 		start1 = meta %>% filter(symbol_nice == gene1) %>% extract2("DomainStart")
# 		end1 = meta %>% filter(symbol_nice == gene1) %>% extract2("DomainEnd")
# 		start2 = meta %>% filter(symbol_nice == gene2) %>% extract2("DomainStart")
# 		end2 = meta %>% filter(symbol_nice == gene2) %>% extract2("DomainEnd")
# 		
# 		ff1_sub = file.path(tempdir(), paste0(gene1, "_sub", ".pdb", sep = ""))
# 		ff2_sub = file.path(tempdir(), paste0(gene2, "_sub", ".pdb", sep = ""))
# 		
# 		### Trim pdb files
# 		is_gene1_from_db = file.exists(af_db_file_from_symbol(gene1))
# 		is_gene2_from_db = file.exists(af_db_file_from_symbol(gene2))
# 		pdb1_sub = pdb1
# 		if(is_gene1_from_db) {
# 			domain_annot1_exists = !(is.na(start1) || is.na(end1))
# 			if(domain_annot1_exists) {
# 				pdb1_sub = trim.pdb(pdb1, inds = atom.select(pdb1, resno = start1:end1))
# 			}
# 		}
# 		pdb2_sub = pdb2
# 		if(is_gene2_from_db) {
# 			domain_annot2_exists = !(is.na(start2) || is.na(end2))
# 			if(domain_annot2_exists) {
# 				pdb2_sub = trim.pdb(pdb2, inds = atom.select(pdb2, resno = start2:end2))
# 			}
# 		}
# 		bio3d::write.pdb(pdb1_sub, file = ff1_sub)
# 		bio3d::write.pdb(pdb2_sub, file = ff2_sub)
# 		dat_file1 = ff1_sub
# 		dat_file2 = ff2_sub
# 	}
# 	r3dmol() %>%
# 		m_add_model(data = dat_file1) %>%
# 		m_set_style(style = m_style_cartoon(color = color1)) %>%
# 		m_zoom_to() %>%
# 		m_add_model(data = dat_file2) %>%
# 		m_set_style(
# 			sel = m_sel(model = -1),
# 			style = m_style_cartoon(color = color2)
# 		) %>%
# 		m_zoom_to()
}
