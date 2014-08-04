function netlog
  echo "$argv" | nc localhost 9090 ^&-
end

function iso_date
  date --iso-8601=seconds
end