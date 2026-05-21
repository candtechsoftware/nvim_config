local M = {}

local function project_root(path)
    path = path or vim.fn.getcwd()
    local found = vim.fs.find({ '.git', 'compile_commands.json', 'compile_flags.txt' },
        { upward = true, path = path })[1]
    if found then return vim.fs.dirname(found) end
    return path
end

local function set_c_path(buf)
    local file = vim.api.nvim_buf_get_name(buf)
    local dir = file ~= '' and vim.fs.dirname(file) or vim.fn.getcwd()
    local root = project_root(dir)
    local paths = { '.', dir }
    for _, c in ipairs({ 'inc', 'include', 'src', 'lib' }) do
        local p = root .. '/' .. c
        if vim.uv.fs_stat(p) then table.insert(paths, p) end
    end
    local ext = root .. '/external'
    if vim.uv.fs_stat(ext) then
        for name, ty in vim.fs.dir(ext) do
            if ty == 'directory' then
                for _, sub in ipairs({ 'include', 'src' }) do
                    local p = ext .. '/' .. name .. '/' .. sub
                    if vim.uv.fs_stat(p) then table.insert(paths, p) end
                end
            end
        end
    end
    vim.bo[buf].path = table.concat(paths, ',')
    vim.bo[buf].suffixesadd = '.h,.hpp,.hh,.hxx,.inl'
end

local function gen_tags(root)
    root = root or project_root()
    local cmd = {
        'ctags', '-R',
        '--fields=+iaS', '--extras=+q',
        '--exclude=.git', '--exclude=node_modules', '--exclude=build',
        '--exclude=dist', '--exclude=target', '--exclude=.venv',
        '--exclude=vendor', '--exclude=.cache', '--exclude=local',
        '-f', root .. '/tags', root,
    }
    vim.notify('ctags: indexing ' .. root)
    vim.system(cmd, { text = true }, function(res)
        vim.schedule(function()
            if res.code == 0 then
                vim.notify('ctags: wrote ' .. root .. '/tags')
            else
                vim.notify('ctags failed: ' .. (res.stderr or ''), vim.log.levels.ERROR)
            end
        end)
    end)
end

function M.setup()
    vim.opt.tags = './tags;,tags'

    vim.api.nvim_create_user_command('GenTags', function() gen_tags() end,
        { desc = 'Generate ctags for the project root' })

    vim.api.nvim_create_autocmd('FileType', {
        group = vim.api.nvim_create_augroup('ctags_gd', { clear = true }),
        pattern = { 'c', 'cpp', 'objc', 'objcpp' },
        callback = function(ev)
            vim.keymap.set('n', 'gd', '<C-]>', {
                buffer = ev.buf, silent = true, desc = 'ctags: go to definition',
            })
            vim.keymap.set('n', 'gi', '<C-]>', {
                buffer = ev.buf, silent = true, desc = 'ctags: go to implementation',
            })
            set_c_path(ev.buf)
        end,
    })
end

return M
