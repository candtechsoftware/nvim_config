# Nvim config

#Installation 

```
brew install neovim
```

Clone this repo and move it
```
git clone git@github.com:candtechsoftware/nvim_config.git ~/.config/nvim
```
Once that is done you can now use nvim with the config
but you will run into an error since the plugins aren't install 
to install them while in vim 

# Installation Guide: Language Servers and Tools (macOS & Ubuntu)

1. **Ripgrep** (required for searching)
2. **Node.js** (required for some language servers)
3. **Copilot** 
    the plugin is already going to be installed with this config but you need to func `:Copilot setup` 
    to authenticate with github. 
2. **TypeScript Language Server** (for JavaScript/TypeScript)[docs](https://github.com/typescript-language-server/typescript-language-server)
3. **Rust Analyzer** (for Rust)[docs](https://rust-analyzer.github.io/manual.html#installation)
4. **gopls** (for Go)[docs](https://pkg.go.dev/golang.org/x/tools/gopls)
5. **zls** (for Zig)[docs](https://github.com/zigtools/zls) 


For the language servers we you can remove support for them in `lua/candtech/lazy/lsp.lua` just by
removing those lines. 

---

## 1. Install Ripgrep

Ripgrep is a fast search tool used by many plugins like Telescope for searching file contents.

### macOS:
```bash
brew install ripgrep
```

### Ubuntu:
```bash
sudo apt-get install ripgrep
```



## Plugins 
For plugins I am using lazy.nvim [docs](https://lazy.folke.io/). This makes it super
simple to install plugins the instructions above but it is as easy as going to a plugin github
page and coping the url with out the github.com (ex. "https://github.com/github/copilot.vim" -> "github/copilot.vim")
and then create a file for it in the `lazy` dir and then return it. Some plugins come with options for the config and
that would go here as well and usually they have the instructions on github but you can look at some of the 
plugins in the `lua/candtech/lazy` dir for examples.

```lua 
return {
  "github/copilot.vim",
  config = function() -- optional config
    require("copilot").setup() -- call the setup function is optional for this plugin 
  end,
}
```
