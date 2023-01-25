#### Helper functions

meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")

### Convert uniprot names to symbols ("nice" versions w/ residue numbers)
convert_uniprot_to_symbol_nice = function(uniprot) {
	#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	meta$symbol_nice[ match(uniprot, meta$uniprot_name_nice) ]
}


get_uniprot_id_from_symbol = function(symbol) {
	#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	id = meta$`Uniprot Entry`[which(meta$HGNC_Symbol == symbol)]
	return(id)
}
af_file_from_symbol = function(symbol) {
	#meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	id = meta$`Uniprot Entry`[which(meta$HGNC_Symbol == symbol)]
	file = paste0("AF-", id, "-F1-model_v4.pdb", sep = "")
	return(file)
}

align_kinases = function(gene1, gene2, color1 = "#00cc96", color2 = "red") {
	tm_df = read_parquet("data/TM_data_full.parquet")
	meta = read_csv("data/kinase_meta_updated_2023_01_03.csv")
	tmp_df = tm_df %>% filter(kinase1 == gene1, kinase2 == gene2)
	
	tm1 = tm_df %>% filter(kinase1 == gene1, kinase2 == gene2) %>% extract2("tm_score")
	tm2 = tm_df %>% filter(kinase1 == gene2, kinase2 == gene1) %>% extract2("tm_score")
	print(tm1)
	print(tm2)
	#get_uniprot_id_from_symbol("RIOK2") #Q9BVS4
	#get_uniprot_id_from_symbol("RIOK3") #O14730
	
	af_v4_dir = file.path("data", "protein_structures", "AlphaFold", "full_proteins", "v4")
	pdb1_file = file.path(af_v4_dir, af_file_from_symbol(gene1))
	pdb2_file = file.path(af_v4_dir, af_file_from_symbol(gene2))
	
	pdb1 = Rpdb::read.pdb( pdb1_file )
	pdb2 = Rpdb::read.pdb( pdb2_file )
	### rotate and translate pdb
	pdb1_rot = pdb1 %>% Rz(tmp_df$z_angle) %>%  Ry(tmp_df$y_angle) %>% Rx(tmp_df$x_angle)  %>% Txyz(x = tmp_df$xt, y = tmp_df$yt, z = tmp_df$zt)
	### write temporary file
	ff1 = paste0(gene1, ".pdb", sep = "")
	ff2 = paste0(gene2, ".pdb", sep = "")
	Rpdb::write.pdb(pdb1_rot, file = ff1)
	
	### trim the pdb with bio3d
	pdb1 = bio3d::read.pdb( ff1 )
	pdb2 = bio3d::read.pdb( pdb2_file )
	# get start and stop indices (for structure from database)
	start1 = meta %>% filter(symbol_nice == gene1) %>% extract2("DomainStart")
	end1 = meta %>% filter(symbol_nice == gene1) %>% extract2("DomainEnd")
	start2 = meta %>% filter(symbol_nice == gene2) %>% extract2("DomainStart")
	end2 = meta %>% filter(symbol_nice == gene2) %>% extract2("DomainEnd")
	# get start and stop indices (for manually-created AF2 structure)
	####### fill in later
	
	ff1_sub = paste0(gene1, "_sub", ".pdb", sep = "")
	ff2_sub = paste0(gene2, "_sub", ".pdb", sep = "")
	pdb1_sub = trim.pdb(pdb1, inds = atom.select(pdb1, resno = start1:end1))
	pdb2_sub = trim.pdb(pdb2, inds = atom.select(pdb2, resno = start2:end2))
	bio3d::write.pdb(pdb1_sub, file = ff1_sub)
	bio3d::write.pdb(pdb2_sub, file = ff2_sub)
	
	r3dmol() %>%
		m_add_model(data = ff1_sub) %>%
		m_set_style(style = m_style_cartoon(color = color1)) %>%
		m_zoom_to() %>%
		m_add_model(data = ff2_sub) %>%
		m_set_style(
			sel = m_sel(model = -1),
			style = m_style_cartoon(color = color2)
		) %>%
		m_zoom_to()
}
