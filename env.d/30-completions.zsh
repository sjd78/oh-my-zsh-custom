# Shell completions for developer tools
command -v minikube >/dev/null 2>&1 && source <(minikube completion zsh)
command -v kubectl >/dev/null 2>&1 && source <(kubectl completion zsh)
command -v crc >/dev/null 2>&1 && source <(crc completion zsh)
