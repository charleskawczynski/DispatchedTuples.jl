using PrettyTables

header = ["Return value" "DispatchedTuple" "DispatchedSet"
    "" "(non-unique keys allowed)" "(unique keys only)"]

col1 = ["Type", "Unregistered key (without default)", "Unregistered key (with default)", "Duplicative key"]

DT = ["Tuple", "()", "(default,)", "all registered values"]

DTS = ["Value", "error", "default", "one value"]

data = hcat(col1, DT, DTS)
pretty_table(
    data,
    header,
    header_crayon = crayon"yellow bold",
    crop = :none,
)

