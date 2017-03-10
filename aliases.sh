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

dcomplete()
{
  _script_commands=$(dirt complete)

  local cur prev
  COMPREPLY=()
  cur="${COMP_WORDS[COMP_CWORD]}"
  COMPREPLY=( $(compgen -W "${_script_commands}" -- ${cur}) )

  return 0
}

complete -o nospace -F dcomplete ddirs

