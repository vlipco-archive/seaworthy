## for the given component install consul
## config file or compile them, enable systemd units
## with the component name or all those in a folder with that name
## finally, trigger the component hook if it exists
function enable_component () {

}

## stop & disable units, remove the links entirely form systemd
## remove consul config files
## trigger component disable hook if present
function disable_component () {
	
}

## for all active components, all source files are
## recopied and all templates are recompiled
## this is equivalent to disable/enable for every component
function refresh_all_components () {
	
}