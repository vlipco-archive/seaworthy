# requires rainbow.fish
function atn.log.info
  echoyellow "$argv"
end

function atn.log.error
  echored "$argv" 1>&2
end


#  Copyright 2013 Manuel Gutierrez <dhunterkde@gmail.com>
#  https://githuatn.com/xr09/rainbow.fish
#  Bash helper functions to put colors on your scripts
#
#  Usage example:
#  set vargreen (echogreen "Grass is green")
#  echo "Coming next: $vargreen"
#

function _colortext
  echo -e " \e[1;$argv[2]m$argv[1]\e[0m"
end

 
function echogreen
  echo (_colortext "$argv[1]" 32)
end

function echored
  echo (_colortext "$argv[1]" 31)
end

function echoblue
  echo (_colortext "$argv[1]" 34)
end

function echopurple
  echo (_colortext "$argv[1]" 35)
end

function echoyellow
  echo (_colortext "$argv[1]" 33)
end

function echocyan
  echo (_colortext "$argv[1]" 36)
end
