$3 == "Nd" || $2 == "Hex_Digit" { set(xdigit) } END { list(1, xdigit) }
