# DIRT aliases
#  https://github.com/BleuLlama/dirt
#  v1.6  yorgle@gmail.com
#
#  MIT license or whatever. these are just shell aliases.
#

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

