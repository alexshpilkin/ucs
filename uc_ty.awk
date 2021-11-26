BEGIN { NAME = "ty"; BITS = 32; CHUNK_BIT = 5; GROUP_BIT = 10 }

$2 ~ /^[A-Z][a-z]$/ && $2 != "Cn"       { set(cat, $2) }
$2 == "Alphabetic"                      { set(alnum) set(alpha) }
$2 == "Nd"                              { set(alnum) set(xdigit) }
$2 == "ASCII_Hex_Digit"                 { set(pxdigit) }
$2 == "Hex_Digit"                       { set(xdigit) }
$2 == "Cased"                           { set(cased) }
$2 == "Uppercase"                       { set(upper) }
$2 == "Lowercase"                       { set(lower) }
$2 == "White_Space"                     { set(space) }
$2 == "Default_Ignorable_Code_Point"    { set(ignor) }
$2 == "Noncharacter_Code_Point"         { set(nchar) }
$2 == "XID_Start"                       { set(start) }
$2 == "XID_Continue"                    { set(ident) }
$2 == "Pattern_White_Space"             { set(delim) }
$2 == "Pattern_Syntax"                  { set(sntax) }
$4 ~ /^[0-9]+$/ && NF == 4              { set(digit, $4+0) }

END {
	value[""] = "Cn"
	for (i = 0; i <= n; i++) {
		blank_  = cat[i] == "Zs" || i == 9
		graph_  = !space[i] && cat[i] && cat[i] !~ /C[cs]/
		pdigit_ = cat[i] == "Nd" && pxdigit[i]
		palnum_ = alpha[i] || pdigit_
		ppunct_ = !alpha[i] && cat[i] ~ /^[PS]/
		print_  = (graph_ || blank_) && cat[i] != "Cc"
		value_  = (cat[i] ? cat[i] : "Cn") \
		          (alnum[i]  ? " | UC_ALNUM"  : "") \
		          (alpha[i]  ? " | UC_ALPHA"  : "") \
		          (blank_    ? " | UC_BLANK"  : "") \
		          (cased[i]  ? " | UC_CASED"  : "") \
		          (delim[i]  ? " | UC_DELIM"  : "") \
		          (graph_    ? " | UC_GRAPH"  : "") \
		          (ident[i]  ? " | UC_IDENT"  : "") \
		          (ignor[i]  ? " | UC_IGNOR"  : "") \
		          (lower[i]  ? " | UC_LOWER"  : "") \
		          (nchar[i]  ? " | UC_NCHAR"  : "") \
		          (palnum_   ? " | UC_PALNUM" : "") \
		          (pdigit_   ? " | UC_PDIGIT" : "") \
		          (ppunct_   ? " | UC_PPUNCT" : "") \
		          (print_    ? " | UC_PRINT"  : "") \
		          (space[i]  ? " | UC_SPACE"  : "") \
		          (start[i]  ? " | UC_START"  : "") \
		          (upper[i]  ? " | UC_UPPER"  : "") \
		          (xdigit[i] ? sprintf(" | UC_XDIGIT_(0x%X)",
		                               (i - digit[i]) % 16) \
		                     : "") \
		          ""
		if (value_ != value[""]) value[i] = value_
	}
}
