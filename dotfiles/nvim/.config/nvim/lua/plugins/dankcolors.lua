return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#111318',
				base01 = '#191c20',
				base02 = '#1d2024',
				base03 = '#999ea5',
				base0B = '#fff872',
				base04 = '#eff5ff',
				base05 = '#f8fbff',
				base06 = '#f8fbff',
				base07 = '#f8fbff',
				base08 = '#ff9fba',
				base09 = '#ff9fba',
				base0A = '#b3d0ff',
				base0C = '#d6e6ff',
				base0D = '#b3d0ff',
				base0E = '#c0d8ff',
				base0F = '#c0d8ff',
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
