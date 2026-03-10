return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#0c160e',
				base01 = '#141e16',
				base02 = '#18221a',
				base03 = '#7d948a',
				base0B = '#ffe700',
				base04 = '#d2efe2',
				base05 = '#f2fff9',
				base06 = '#f2fff9',
				base07 = '#f2fff9',
				base08 = '#ff7a3f',
				base09 = '#ff7a3f',
				base0A = '#25fa99',
				base0C = '#8cffca',
				base0D = '#25fa99',
				base0E = '#4cffad',
				base0F = '#4cffad',
			})

			local current_file_path = vim.fn.stdpath("config") .. "/lua/plugins/dankcolors.lua"
			if not _G._matugen_theme_watcher then
				local uv = vim.uv or vim.loop
				_G._matugen_theme_watcher = uv.new_fs_event()
				_G._matugen_theme_watcher:start(current_file_path, {}, vim.schedule_wrap(function()
					local new_spec = dofile(current_file_path)
					if new_spec and new_spec[1] and new_spec[1].config then
						new_spec[1].config()
						print("Theme reload")
					end
				end))
			end
		end
	}
}
