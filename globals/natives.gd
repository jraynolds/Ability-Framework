## Helper class for native engine operations.
class_name Natives

## Returns the String name in the given enum matching the given value.
static func enum_name(enum_list, value: int) -> String:
	for enum_key : String in enum_list:
		if enum_list[enum_key] == value:
			return enum_key
	return "NULL_ENUM_NAME"
