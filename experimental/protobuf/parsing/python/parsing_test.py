import example_pb2

class ProtobufParser:
    """Protobuf parser"""

    def __init__(self, desc):
        # Set protobuf DESCRIPTOR object
        self.descriptor = desc

        # Protobuf type name indices
        self.TYPE_DOUBLE = 1
        self.TYPE_FLOAT = 2
        self.TYPE_INT64 = 3
        self.TYPE_UINT64 = 4
        self.TYPE_INT32 = 5
        self.TYPE_FIXED64 = 6
        self.TYPE_FIXED32 = 7
        self.TYPE_BOOL = 8
        self.TYPE_STRING = 9
        self.TYPE_GROUP = 10
        self.TYPE_MESSAGE = 11
        self.TYPE_BYTES = 12
        self.TYPE_UINT32 = 13
        self.TYPE_ENUM = 14
        self.TYPE_SFIXED32 = 15
        self.TYPE_SFIXED64 = 16
        self.TYPE_SINT32 = 17
        self.TYPE_SINT64 = 18

        # Map protobuf type indices to MeTTa type names
        self.type_names = {
            self.TYPE_DOUBLE : "Double",
            self.TYPE_FLOAT : "Float",
            self.TYPE_INT64 : "Int64",
            self.TYPE_UINT64 : "UInt64",
            self.TYPE_INT32 : "Int32",
            self.TYPE_FIXED64 : "Fixed64",
            self.TYPE_FIXED32 : "Fixed32",
            self.TYPE_BOOL : "Bool",
            self.TYPE_STRING : "String",
            self.TYPE_GROUP : "Group",
            self.TYPE_MESSAGE : "Message",
            self.TYPE_BYTES : "Bytes",
            self.TYPE_UINT32 : "UInt32",
            self.TYPE_ENUM : "Enum",
            self.TYPE_SFIXED32 : "SFixed32",
            self.TYPE_SFIXED64 : "SFixed64",
            self.TYPE_SINT32 : "SInt32",
            self.TYPE_SINT64 : "SInt64"
        }

    def parse_description(self) -> str:
        """Parse the protobuf description provided in the constructor"""

        # MeTTa file header
        desc_rep : str = ""
        desc_rep += ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n"
        desc_rep += ";; MeTTa representation, autogenerated by parsing_test.py\n"
        desc_rep += ";;\n"
        desc_rep += ";; Protobuf file: {}\n".format(self.descriptor.name)
        desc_rep += ";; Protobuf syntax: {}\n".format(self.descriptor.syntax)
        desc_rep += ";; Protobuf package: {}\n".format(self.descriptor.package)
        desc_rep += ";;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;\n"
        desc_rep += "\n"

        # Parse messages
        for msg_name, msg in desc.message_types_by_name.items():
            msg_name_len = len(msg_name)
            desc_rep += ";;;" + msg_name_len * ";" + ";;;\n"
            desc_rep += ";; {} ;;\n".format(msg_name)
            desc_rep += ";;;" + msg_name_len * ";" + ";;;\n\n"
            desc_rep += self.parse_message(msg)
        return desc_rep

    def parse_field_type(self, field) -> str:
        """Parse a field type, return its representation in MeTTa format."""

        if field.type == self.TYPE_MESSAGE:
            return field.message_type.full_name
        if field.type == self.TYPE_ENUM:
            return field.enum_type.full_name
        return self.type_names[field.type]

    def parse_enum(self, enm) -> str:
        """Parse enum type, output corresponding string MeTTa format.

        Example:

        Assuming a package `example`, then the protobuf enum
        specification

        ```
        enum Week {
          SUN = 0;
          MON = 1;
          TUE = 2;
          WED = 3;
          THU = 4;
          FRI = 5;
          SAT = 6;
        }
        ```

        outputs the following string in MeTTa format

        ```
        ;; Define example.Week type
        (: example.Week Type)

        ;; Define example.Week enum values
        (: example.Week.SUN example.Week)
        (: example.Week.MON example.Week)
        (: example.Week.TUE example.Week)
        (: example.Week.WED example.Week)
        (: example.Week.THU example.Week)
        (: example.Week.FRI example.Week)
        (: example.Week.SAT example.Week)
        ```

        For now enum numbers are discarded from the MeTTa format.

        """

        # Enum string representation in MeTTa format
        enm_rep : str = ""

        # Type declaration
        enm_class_name : str = enm.full_name
        enm_rep += ";; Define {} enum type\n".format(enm_class_name)
        enm_rep += "(: {} Type)\n\n".format(enm_class_name)

        # Enum values
        enm_rep += ";; Define {} enum values\n".format(enm_class_name)
        for enm_name, enm_value in enm.values_by_name.items():
            enm_rep += "(: {0}.{1} {0})\n".format(enm_class_name, enm_name)

        return enm_rep

    def parse_message(self, msg) -> str:

        """Parse message type, output corresponding string in MeTTa format.

        Example:

        Assuming a package `example`, then the protobuf message
        specification

        ```
        message Name {
          string forename = 1;
          string surname = 2;
        }
        ```

        outputs the following string in MeTTa format

        ```
        ;; Define example.Name type
        (: example.Name Type)

        ;; Define example.Name constructor
        (: example.MkName
        (->
         String ; forename
         String ; surname
         example.Name))

        ;; Define example.Name access functions

        ;; Access function of forename
        (: example.Name.forename (-> example.Name String))
        (= (example.Name.forename
             (example.MkName
               $forename
               $surname
             )
           )
           $forename)

        ;; Access function of surname
        (= (example.Name.surname
             (example.MkName
               $forename
               $surname
             )
           )
           $surname)
        ```

        """

        # Message string representation in MeTTa format
        msg_rep : str = ""

        # Type declaration
        class_name : str = msg.full_name
        msg_rep += ";; Define {} type\n".format(class_name)
        msg_rep += "(: {} Type)\n\n".format(class_name)

        # Enum sub-type declarations
        for enum_name, enum_type in msg.enum_types_by_name.items():
            msg_rep += self.parse_enum(enum_type)
            msg_rep += "\n"

        # Type constructor
        ctor_name : str = "{}.Mk{}".format(self.descriptor.package, msg.name)
        msg_rep += ";; Define {} constuctor\n".format(class_name)
        msg_rep += "(: {}\n   (->\n".format(ctor_name)
        for field_num, field in msg.fields_by_number.items():
            type_name : str = self.parse_field_type(field)
            msg_rep += "    {} ; {}\n".format(type_name, field.name)
        msg_rep += "    {}))\n\n".format(class_name)

        # Access functions
        field_names = [field.name for _, field in msg.fields_by_number.items()]
        msg_rep += ";; Define {} access functions\n\n".format(class_name)
        for field_num, field in msg.fields_by_number.items():
            fn_name : str = "{}.{}".format(class_name, field.name)
            type_name : str = self.parse_field_type(field)
            msg_rep += ";; Define {}\n".format(fn_name)
            msg_rep += "(: {} (-> {} {}))\n".format(fn_name, class_name, type_name)
            msg_rep += "(= ({}\n".format(fn_name)
            msg_rep += "    ({}\n".format(ctor_name)
            msg_rep += "\n".join(["     ${}".format(fn) for fn in field_names])
            msg_rep += ")) ${})\n\n".format(field.name)

        return msg_rep


# Test
desc = example_pb2.DESCRIPTOR
parser = ProtobufParser(desc)
parsed_desc = parser.parse_description()
print("{}".format(parsed_desc))