$2 ~ /^DIGIT (ZERO|ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE)$/ ||
$2 ~ /^LATIN (CAPITAL|SMALL) LETTER [ABCDEF]$/ { set(pxdigit) }
END { list(1, pxdigit) }