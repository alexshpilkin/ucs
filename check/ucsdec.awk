/^@/ { next }

                     { print $3, $3 } # NFD to itself
$2 != $3             { print $2, $3 } # NFC to NFD
$1 != $3 && $1 != $2 { print $1, $3 } # input to NFD
$5 != $3             { print $5, $5 } # NFKD to itself
$5 != $3 && $4 != $5 { print $4, $5 } # NFKC to NFKD
