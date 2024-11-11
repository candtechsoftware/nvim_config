
function ColorMyPencils(color)
    color = color or "sonokai"
    vim.cmd.colorscheme(color)

	vim.api.nvim_set_hl(0, "Normal", { bg = "none" })
	vim.api.nvim_set_hl(0, "NormalFloat", { bg = "none" })
    if vim.fn.has('termguicolors') == 1 then
        vim.opt.termguicolors = false
    end

    vim.opt.background = 'dark'

    vim.g.everforest_background = 'hard'
    vim.g.everforest_better_performance = 1

end

ColorMyPencils()
