# don't use rargs here, it'll cause a loop
function echo.color -a color
  isatty; and set_color $color
  echo $argv[2..-1]
  isatty; and set_color normal
end
 
# todo convert this to a loop
function echo.red;     echo.color red $argv;      end
function echo.green;   echo.color green $argv;    end
function echo.yellow;  echo.color yellow $argv;   end
function echo.blue;    echo.color blue $argv;     end
function echo.magenta;  echo.color magenta $argv;   end
function echo.cyan;    echo.color cyan $argv;     end

# requires rainbow.fish
function log.info
  echo.yellow "$argv"
end

function log.step
  log.info "  -> $argv"
end

function log.error
  echo.red "$argv" 1>&2
end

function log.debug
  if set -q bundle_debug_messages
  	echo "     Δ: $argv" #1>&2
  end
end

function log.title
	echo
	echo.green "========== $argv"
	echo
end