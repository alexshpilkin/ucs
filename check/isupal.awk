$2 ~ /^DIGIT (ZERO|ONE|TWO|THREE|FOUR|FIVE|SIX|SEVEN|EIGHT|NINE)$/ ||
$2 == "Alphabetic" { set(palnum) } END { list(1, palnum) }
