cat >> ~/.bash_profile << "EOF"
alias ls='ls --color=auto --time-style=long-iso'
EOF

alias ssh-cmd='$(openssl enc -aes-256-cbc -d -in ~/.ssh/ssh_exp.enc -out /tmp/exp) && expect /tmp/exp'
