# encoding: UTF-8

class Tree_map < Wx::TreeCtrl
	attr_reader :map, :selection
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	initialize
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def initialize(window, splitter)
		super(splitter, Wx::ID_ANY, Wx::DEFAULT_POSITION, Wx::DEFAULT_SIZE, Wx::TR_HAS_BUTTONS | Wx::TR_SINGLE | Wx::TR_EXTENDED | Wx::TR_EDIT_LABELS)
		@window = window
	
		# Popoup map selection
		popup_dir = Wx::Menu.new
		item_new_map = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Nouvelle carte", "eng" => "New map"}) + "...", String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		item_new_dir = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Nouveau dossier", "eng" => "New directory"}) + "...", String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		item_set_dir_name = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Modifier le nom du dossier", "eng" => "Set directory name"}), String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		item_del_dir = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Effacer le dossier", "eng" => "Delete directory"}), String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		popup_dir.append_item(item_new_map)
		popup_dir.append_item(item_new_dir)
		popup_dir.append_separator()
		popup_dir.append_item(item_set_dir_name)
		popup_dir.append_item(item_del_dir)
		
		# Popoup map selection
		popup_map = Wx::Menu.new
		item_set_map = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Modifier carte", "eng" => "Set map"}) + "...", String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		item_move_map = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Déplacer carte", "eng" => "Move map"}) + "...", String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		item_set_map_name = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Modifier le nom de la carte", "eng" => "Set map name"}), String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		item_del_map = Wx::MenuItem.new(nil,  Wx::ID_ANY, String_lang::get({"fr" => "Effacer la carte", "eng" => "Delete map"}), String_lang::get({"fr" => "Crée un nouveau jeu", "eng" => "Create a new game"}))
		popup_map.append_item(item_set_map)
		popup_map.append_item(item_move_map)
		popup_map.append_separator()
		popup_map.append_item(item_set_map_name)
		popup_map.append_item(item_del_map)
		
		# images
		images = Wx::ImageList.new(16, 16, true)
		images.add(Wx::Bitmap.from_image(Wx::Image.new("Datas/bmp/dir.png")))
		images.add(Wx::Bitmap.from_image(Wx::Image.new("Datas/bmp/map.png")))
		set_image_list(images)
		
		@selection = nil
		
		# set events
		evt_tree_item_activated(self) do |event|
			id = (event.get_item())
			select_item(id)
			set_name()
		end
		
		evt_tree_item_right_click(self) do |event|
			id = (event.get_item())
			select_item(id)
			item_set_dir_name.enable(@main_root != id)
			item_del_dir.enable(@main_root != id)
			if is_a_directory?(id)
				window.popup_menu(popup_dir)
			else
				window.popup_menu(popup_map)
			end
		end
		evt_tree_begin_label_edit(self) {}
		evt_tree_end_label_edit(self) do |event|
			if event.get_item() != get_root_item()
				text = event.get_label()
				id = get_selection()
				text = get_item_text(id) if text == ""
				index = @indent_id.index(id)
				@indent[index][1] = text
				file = File.open($directory + "/Datas/Editor/maph.txt", "w:UTF-8")
				file.puts(@indent.to_s)
				file.close()
			end
		end
		
		evt_tree_sel_changed(self) do |event|
			@selection = (event.get_item())
			map_selection()
		end
		
		evt_tree_key_down(id) do |event|
			if event.get_key_code() == 127
				delete_dir()
			end
		end
		
		window.evt_menu(item_new_dir) {new_dir}
		window.evt_menu(item_set_dir_name) {set_name()}
		window.evt_menu(item_del_dir) {delete_dir()}
		window.evt_menu(item_new_map) {new_map()}
		window.evt_menu(item_set_map) {set_map()}
		window.evt_menu(item_set_map_name) {set_name()}
		window.evt_menu(item_del_map) {delete_map()}
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	init_indent
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def init_indent()
		delete_all_items()
		@main_root = add_root(String_lang::get({"fr" => "Selecteur de carte", "eng" => "Map selector"}))
		set_item_image(@main_root, 0)
		file = File.open($directory + "/Datas/Editor/maph.txt", "r:UTF-8").readlines
		@indent = eval(file[0].chomp)
		@directories = [@main_root]
		@maps = []
		
		root = @main_root
		@indent_id = []
		@indent.each do |line|
			type = line[0]
			name = line[1]
			new_root = line[3]
			root = (new_root == -1) ? @main_root : @indent_id[new_root]
			if type == :directory
				id = append_item(root, name)
				set_item_image(id, 0)
				@directories.push(id)
			else
				id = append_item(root, name)
				set_item_image(id, 1)
				@maps.push(id)
			end
			@indent_id.push(id)
		end
		expand_all()
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	update
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def update(panel)
		@panel_map = panel
		init_indent()
		select_item(@main_root)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	is_a_directory?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def is_a_directory?(id)
		@directories.each do |dir|
			return true if id == dir
		end
		return false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	name_exists?
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def name_exists?(name)
		@indent.each do |dir|
			return true if dir[2] == name
		end
		return false
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	map_selection
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def map_selection()
		id = get_selection()
		index = @indent_id.index(id)
		if index == nil
			@map = @main_root
		else
			@map = @indent[index][2]
		end
		@map = nil if is_a_directory?(id)
		@panel_map.update_map(@map)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	new_dir
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def new_dir()
		begin
			root = get_selection()
			
			for i in 1..@directories.size
				name = String_lang::get({"fr" => "Dossier", "eng" => "Directory"}) + " " + i.to_s
				break if !name_exists?(name)
			end
			dir = append_item(root, name)
			
			index = @indent_id.index(root)
			col = index == nil ? 0 : @indent[index][4]
			index = -1 if index == nil
			
			j = index+1
			for i in (index+1)...@indent.size
				new_col = @indent[i][4]
				if new_col > col
					j += 1
				else
					break
				end
			end
			
			indexes = []
			@indent.each do |arr|
				id = arr[3] == -1 ? @main_root : @indent_id[arr[3]]
				indexes.push(id)
			end

			@indent.insert(j, [:directory, name , name, index, col+1])
			@indent_id.insert(j, dir)
			indexes.insert(j, root)
			
			for i in 0...@indent.size
				id = @indent_id.index(indexes[i])
				id = -1 if id == nil
				@indent[i][3] = id
			end
			
			file = File.open($directory + "/Datas/Editor/maph.txt", "w:UTF-8")
			file.puts(@indent.to_s)
			file.close()
			init_indent()
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete_dir
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_dir()
		alert = AlertYesNo.new(@window, String_lang::get({"fr" => "Voulez vous vraiment effacer ce dossier ?", "eng" => "Do you trully wish to delete this directory ?"}), [300, 100])
		if alert.show_modal == 1000
			begin
				root = get_selection()
				index = @indent_id.index(root)
				col = index == nil ? 0 : @indent[index][4]
				index = -1 if index == nil
				
				j = index+1
				k = 0
				for i in (index+1)...@indent.size
					new_col = @indent[i][4]
					if new_col > col
						k += 1
					else
						break
					end
				end
				
				indexes = []
				@indent.each do |arr|
					id = arr[3] == -1 ? @main_root : @indent_id[arr[3]]
					indexes.push(id)
				end
				
				
				(k+1).times do
					if @indent[j-1][0] == :map
						name = @indent[j-1][2]
						FileUtils.rm_rf($directory + "Events/" + name)
						FileUtils.rm_rf($directory + "Maps/" + name)
					end
					@indent.delete_at(j-1)
					@indent_id.delete_at(j-1)
					indexes.delete_at(j-1)
				end
				
				for i in 0...@indent.size
					id = @indent_id.index(indexes[i])
					id = -1 if id == nil
					@indent[i][3] = id
				end
				
				file = File.open($directory + "/Datas/Editor/maph.txt", "w:UTF-8")
				file.puts(@indent.to_s)
				file.close()
				init_indent()
			rescue Exception => e  
				FrameAlert::message(e)
			end
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_name()
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_name()
		id = get_selection()
		edit_label(id)
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	new_map
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def new_map()
		begin
		for i in 0..@maps.size
			map_name = "MAP" + ("%04d" % (i+1))
			break if !name_exists?(map_name)
		end
			
		game_map = Game_map.new(map_name)
		dialog = Dialog_new_map.new(@window, game_map)
		if (dialog.show_modal() == 1000)
			tab = dialog.get_value()
			name = tab[0]
			tileset = tab[1]
			width = tab[2]
			height = tab[3]
			game_map.set_datas(name, tileset, [width, height])
			Dir.mkdir($directory + "/Maps/" + map_name)
			Dir.mkdir($directory + "/Events/" + map_name)
			Dir.mkdir($directory + "/Maps/" + map_name + "/temporalSave/")
			File.open($directory + "/Maps/" + map_name + "/infos.map", 'w+b') do |f|  
				Marshal.dump(game_map, f)  
			end
			FileUtils.cp("Datas/editor/default_render.png", $directory + "/Maps/" + map_name + "/render.png")
			FileUtils.cp("Datas/editor/default_render.png", $directory + "/Maps/" + map_name + "/render_grid.png")
			
			root = get_selection()
			dir = append_item(root, name)
			index = @indent_id.index(root)
			col = index == nil ? 0 : @indent[index][4]
			index = -1 if index == nil
			
			j = index+1
			for i in (index+1)...@indent.size
				new_col = @indent[i][4]
				if new_col > col
					j += 1
				else
					break
				end
			end
			
			indexes = []
			@indent.each do |arr|
				id = arr[3] == -1 ? @main_root : @indent_id[arr[3]]
				indexes.push(id)
			end
			
			@indent.insert(j, [:map, name , map_name, index, col+1])
			@indent_id.insert(j, dir)
			indexes.insert(j, root)
			
			for i in 0...@indent.size
				id = @indent_id.index(indexes[i])
				id = -1 if id == nil
				@indent[i][3] = id
			end
			
			file = File.open($directory + "/Datas/Editor/maph.txt", "w:UTF-8")
			file.puts(@indent.to_s)
			file.close()
			init_indent()
		end
		rescue Exception => e  
			FrameAlert::message(e)
		end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	set_map
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def set_map()
		begin
		map_name = @indent[@indent_id.index(@selection)][2]
		game_map = Wanok::load_datas($directory + "/Maps/" + map_name + "/infos.map")
		
		dialog = Dialog_new_map.new(@window, game_map)
		if (dialog.show_modal() == 1000)
			tab = dialog.get_value()
			name = tab[0]
			tileset = tab[1]
			width = tab[2]
			height = tab[3]
			game_map.set_datas(name, tileset, [width, height])
			File.open($directory + "/Maps/" + map_name + "/infos.map", 'w+b') do |f|  
				Marshal.dump(game_map, f)  
			end
			set_item_text(@selection,name)
			@indent[@indent_id.index(@selection)][1] = name
			file = File.open($directory + "/Datas/Editor/maph.txt", "w:UTF-8")
			file.puts(@indent.to_s)
			file.close()
			init_indent()
		end
		rescue Exception => e  
				FrameAlert::message(e)
			end
	end
	
	#--------------------------------------------------------------------------------------------------------------------------------
	#	delete_map
	#--------------------------------------------------------------------------------------------------------------------------------
	
	def delete_map()
		alert = AlertYesNo.new(@window, String_lang::get({"fr" => "Voulez vous vraiment effacer cette carte ?", "eng" => "Do you trully wish to delete this map ?"}), [300, 100])
		if alert.show_modal == 1000
			begin
			root = get_selection()
			index = @indent_id.index(root)
			index = -1 if index == nil

			j = index+1

			indexes = []
			@indent.each do |arr|
				id = arr[3] == -1 ? @main_root : @indent_id[arr[3]]
				indexes.push(id)
			end

			name = @indent[j-1][2]
			@indent.delete_at(j-1)
			@indent_id.delete_at(j-1)
			indexes.delete_at(j-1)

			for i in 0...@indent.size
				id = @indent_id.index(indexes[i])
				id = -1 if id == nil
				@indent[i][3] = id
			end
			
			FileUtils.rm_rf($directory + "Events/" + name)
			FileUtils.rm_rf($directory + "Maps/" + name)

			file = File.open($directory + "/Datas/Editor/maph.txt", "w:UTF-8")
			file.puts(@indent.to_s)
			file.close()
			init_indent()
			rescue Exception => e  
			FrameAlert::message(e)
		end
		end
	end
end