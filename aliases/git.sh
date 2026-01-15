#!/bin/bash
# =============================================================================
# Git Aliases
# =============================================================================

alias ga='git add .'
alias gauto='git add . && git commit -m "Backup" && git push origin HEAD'
alias gb='git branch'
alias gc='git commit -m'
alias gph='git push origin'
alias gpl='git pull origin'
alias gs='git status'
alias gsw='git switch'
alias gd='git diff'
alias glog='git log --oneline -n 20'

# =============================================================================
# Help Function
# =============================================================================

alias-git() {
    cat << 'EOF'
Git Aliases
═══════════════════════════════════════════════════════════════════════════════
  ga           git add .                      Stage all changes
  gauto        add + commit + push            Quick backup to remote
  gb           git branch                     List branches
  gc <msg>     git commit -m <msg>            Commit with message
  gd           git diff                       Show unstaged changes
  glog         git log --oneline -n 20        Recent commits (20)
  gph <branch> git push origin <branch>       Push to remote
  gpl <branch> git pull origin <branch>       Pull from remote
  gs           git status                     Working tree status
  gsw <branch> git switch <branch>            Switch branches
═══════════════════════════════════════════════════════════════════════════════
EOF
}
