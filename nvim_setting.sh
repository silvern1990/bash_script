#!/bin/bash

OS=$(uname -s)





git clone https://github.com/silvern1990/astronvim_for_spring ~/.config/nvim

cd ~/.config/nvim/lua/user
git pull origin mine

