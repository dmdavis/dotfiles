# List all manually installed packages
# http://askubuntu.com/questions/2389/generating-list-of-manually-installed-packages-and-querying-individual-packages
function debm {
    comm -23 <(aptitude search '~i !~M' -F '%p' | sed "s/ *$//" | sort -u) <(gzip -dc /var/log/installer/initial-status.gz | sed -n 's/^Package: //p' | sort -u)
}
