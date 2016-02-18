# DIRT aliases
#
#  aliases for version 1.6
#	the latest version is at https://github.com/BleuLlama/dirt

dvi(){
    vi `dirt file`
}
ddirs(){
    dirt list $*
}
djump(){
    `dirt jump $*`
    pwd
}
dpush(){
    `dirt push $*`
}
dpop(){
    `dirt pop $*`
    pwd
}
dtop(){
    `dirt top $*`
    pwd
}
dswap(){
    `dirt swap $*`
    pwd
}

