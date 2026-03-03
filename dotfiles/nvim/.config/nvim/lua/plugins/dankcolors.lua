return {
	{
		"RRethy/base16-nvim",
		priority = 1000,
		config = function()
			require('base16-colorscheme').setup({

				base00 = '#161217',
				base01 = '#1f1a1f',
				base02 = '#231e23',
				base03 = '#9a909c',
				base0B = '#ffdd72',
				base04 = '#faedfd',
				base05 = '#fdf8ff',
				base06 = '#fdf8ff',
				base07 = '#fdf8ff',
				base08 = '#ff9fac',
				base09 = '#ff9fac',
				base0A = '#f5c9ff',
				base0C = '#f9e2ff',
				base0D = '#f5c9ff',
				base0E = '#f6d3ff',
				base0F = '#f6d3ff',
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
