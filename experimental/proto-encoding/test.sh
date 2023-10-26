# Encode message
echo "* Encode the following protobuf message:"
cat test.msg
cat test.msg | protoc --encode=test.Greet test.proto > test.msg.encoded

# Print encoded message
echo
echo "* Encoded message in Wire format:"
cat test.msg.encoded
echo
echo
echo "* Encoded message in Hexadecimal format:"
hexdump test.msg.encoded
echo
echo "* Encoded message in Protoscope format:"
protoscope -explicit-length-prefixes -explicit-wire-types test.msg.encoded

# Decode message
echo
echo "* Decode using protobuf spec:"
cat test.msg.encoded | protoc --decode=test.Greet test.proto

# Decode raw message
echo
echo "* Decode without using protobuf spec:"
cat test.msg.encoded | protoc --decode_raw
