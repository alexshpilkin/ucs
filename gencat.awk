BEGIN { NAME = "gc"; BITS = 8; value[""] = "Cn"; CHUNK_BIT = 5; GROUP_BIT = 10 }
$2 != "Cn" && $3 != "Cn" { set(value, $3 ? $3 : $2) }
