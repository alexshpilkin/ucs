BEGIN { NAME = "ty"; BITS = 32 }

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
		cat_    = i in cat ? cat[i] : "Cn"
		blank_  = cat_ == "Zs" || i == 9
		graph_  = !(i in space) && cat_ !~ /C[cns]/
		pdigit_ = cat_ == "Nd" && pxdigit[i]
		palnum_ = i in alpha || pdigit_
		ppunct_ = !(i in alpha) && cat_ ~ /^[PS]/
		print_  = (graph_ || blank_) && cat_ != "Cc"
		value_  = cat_ \
		          (i in alnum  ? " | UC_ALNUM"  : "") \
		          (i in alpha  ? " | UC_ALPHA"  : "") \
		          (blank_      ? " | UC_BLANK"  : "") \
		          (i in cased  ? " | UC_CASED"  : "") \
		          (i in delim  ? " | UC_DELIM"  : "") \
		          (graph_      ? " | UC_GRAPH"  : "") \
		          (i in ident  ? " | UC_IDENT"  : "") \
		          (i in ignor  ? " | UC_IGNOR"  : "") \
		          (i in lower  ? " | UC_LOWER"  : "") \
		          (i in nchar  ? " | UC_NCHAR"  : "") \
		          (palnum_     ? " | UC_PALNUM" : "") \
		          (pdigit_     ? " | UC_PDIGIT" : "") \
		          (ppunct_     ? " | UC_PPUNCT" : "") \
		          (print_      ? " | UC_PRINT"  : "") \
		          (i in space  ? " | UC_SPACE"  : "") \
		          (i in start  ? " | UC_START"  : "") \
		          (i in upper  ? " | UC_UPPER"  : "") \
		          (i in xdigit ? sprintf(" | UC_XDIGIT_(0x%X)",
		                                 (i - digit[i]) % 16) \
		                       : "") \
		          ""
		if (value_ != value[""]) value[i] = value_
	}
}
