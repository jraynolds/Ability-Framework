## Helper class for math operations.
class_name Math

## Rounding behavior from floats to integers.
enum Rounding {
	Floor,
	Nearest,
	Ceiling
}

## Math comparisons.
enum Comparison {
	Equal,
	GreaterThan,
	GreaterThanOrEqual,
	LessThan,
	LessThanOrEqual
}

## Positivity comparisons.
enum Positivity {
	Positive,
	Neutral,
	Negative,
	All
}

## Mathematics operations.
enum Operation {
	Addition,
	Subtraction,
	Multiplication,
	Division,
	Power,
	Set
}


## Performs the given math operation on the first given value, modified by the second.
static func perform_operation(value_modified: float, value_modifier: float, math_operation: Operation) -> float:
	match math_operation:
		Math.Operation.Addition:
			return value_modified + value_modifier
		Math.Operation.Subtraction:
			return value_modified - value_modifier
		Math.Operation.Multiplication:
			return value_modified * value_modifier
		Math.Operation.Division:
			return value_modified / value_modifier
		Math.Operation.Power:
			return pow(value_modified, value_modifier)
		Math.Operation.Power:
			return value_modifier
	assert(false, "How did we get here?")
	return -1
