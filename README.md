# Nvim config

#Installation 
packer https://github.com/wbthomason/packer.nvim (Plugin installer)
Terminal Needs to support termcolors (Kitty, Iterm2, alacritty, etc) to get the theme working 
Need Homebrew for (macos) or can install via `snap` `apt` and I think all linux distros as well 
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
```
:PackerSync
```
This should install all plugins 


To install an lsp for you language just type `:Mason` and should open a window for you to 
pick the correct lsp of if you know the name of the lsp `:MasonInstall <name-of-lsp` ex (`:MasonInstall gopls`)
