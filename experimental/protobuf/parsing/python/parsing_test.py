import example_pb2

type_names = {
    1 : "Double",   # TYPE_DOUBLE
    2 : "Float",    # TYPE_FLOAT
    3 : "Int64",    # TYPE_INT64
    4 : "UInt64",   # TYPE_UINT64
    5 : "Int32",    # TYPE_INT32
    6 : "Fixed64",  # TYPE_FIXED64
    7 : "Fixed32",  # TYPE_FIXED32
    8 : "Bool",     # TYPE_BOOL
    9 : "String",   # TYPE_STRING
    10: "Group",    # TYPE_GROUP
    11: "Message",  # TYPE_MESSAGE
    12: "Bytes",    # TYPE_BYTES
    13: "UInt32",   # TYPE_UINT32
    14: "Enum",     # TYPE_ENUM
    15: "SFixed32", # TYPE_SFIXED32
    16: "SFixed64", # TYPE_SFIXED64
    17: "SInt32",   # TYPE_SINT32
    18: "SInt64"    # TYPE_SINT64
}

desc = example_pb2.DESCRIPTOR
for msg_name, msg in desc.message_types_by_name.items():
    print("Message[{}]:".format(msg_name))
    for field_num, field in msg.fields_by_number.items():
        print("(: {} {})".format(field.name, type_names[field.type]))
        # help(field)
