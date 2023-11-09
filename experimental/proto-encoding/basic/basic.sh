#!/bin/bash

# Encode message
echo "* Encode the following protobuf message:"
cat basic.msg
protoc --encode=basic.Greet basic.proto < basic.msg > basic.msg.encoded

# Print encoded message
echo
echo "* Encoded message in Wire format:"
cat basic.msg.encoded
echo
echo
echo "* Encoded message in Hexadecimal format:"
hexdump basic.msg.encoded
echo
echo "* Encoded message in Protoscope format:"
protoscope -explicit-length-prefixes -explicit-wire-types basic.msg.encoded

# Decode raw message
echo
echo "* Decode without using protobuf spec:"
protoc --decode_raw < basic.msg.encoded

# Decode message
echo
echo "* Decode using protobuf spec:"
protoc --decode=basic.Greet basic.proto < basic.msg.encoded
