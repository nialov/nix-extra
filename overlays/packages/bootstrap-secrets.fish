#!/usr/bin/env fish
# Requires ssh access to both the root and specific user (USER)


if test ! (count $argv) -eq 2 || test $argv[1] = --help || test $argv[1] = -h
    echo "Usage:
    
    bootstrap-secrets <HOST> <USER>
    "
    return
end

# Could be setup as command-line arguments
set HOST $argv[1]
and set USER $argv[2]
# Add user key
and ssh $USER@$HOST -- mkdir -p /home/$USER/.config/sops/age
and scp ~/.config/sops/age/keys.txt $USER@$HOST:/home/$USER/.config/sops/age/keys.txt
# Change permissions for user key
and ssh $USER@$HOST -- chmod 600 /home/$USER/.config/sops/age/keys.txt
# Add root key
and ssh root@$HOST -- mkdir -p /var/lib/sops-nix/
and scp ~/.config/sops/age/keys.txt root@$HOST:/var/lib/sops-nix/keys.txt
# Change permissions for root key
and ssh root@$HOST -- chmod 600 /var/lib/sops-nix/keys.txt
# Experimental, do not know if asks for passphrase successfully in ssh or locally
and echo (gpg --export-secret-keys --armor nikolasovaskainen@gmail.com) | ssh -t $USER@$HOST -- gpg --import
