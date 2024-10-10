PS1="%n@%1~ %# "

export JAVA_HOME=/opt/homebrew/Cellar/openjdk@17/17.0.12
export PATH=/opt/homebrew/Cellar/openjdk@17/17.0.12/bin:$PATH
export PATH=$PATH:/Users/silvern1990/Library/Python/3.9/bin
export PATH=$PATH:~/.cargo/bin

alias ls='ls -G'
alias vim='nvim'
alias codegen='./mvnw exec:java -e -D exec.mainClass=com.microsoft.playwright.CLI -D exec.args="codegen --viewport-size 1920,1080  localhost:9999"'

# Created by `pipx` on 2024-06-07 01:35:05
export PATH="$PATH:/Users/silvern1990/.local/bin"

# setting for poetry auto completion
fpath+=~/.zfunc
autoload -Uz compinit && compinit


alias ls='ls-go -n'

alias ssh-git='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_git.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-vm='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_vm.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-nas='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_nas.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-lfs='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_lfs.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-161='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_161.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-ndps='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_ndps.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-hulk='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_hulk.enc) && expect -c $expect_cmd && unset expect_cmd'
alias ssh-69='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/ssh_69.enc) && expect -c $expect_cmd && unset expect_cmd'

alias sftp-ndps='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/sftp_ndps.enc) && expect -c $expect_cmd && unset expect_cmd'
alias sftp-hulk='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/sftp_hulk.enc) && expect -c $expect_cmd && unset expect_cmd'
alias sftp-git='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/sftp_git.enc) && expect -c $expect_cmd && unset expect_cmd'
alias sftp-161='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/sftp_161.enc) && expect -c $expect_cmd && unset expect_cmd'
alias sftp-69='expect_cmd=$(openssl enc -aes-256-cbc -d -in ~/.ssh/exp/sftp_69.enc) && expect -c $expect_cmd && unset expect_cmd'

