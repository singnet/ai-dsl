# Encode message
echo "* Encode the following protobuf message:"
cat test.msg
cat test.msg | protoc --encode=test.Greet test.proto > test.msg.encoded
echo
echo "Encoded message:"
cat test.msg.encoded
echo

# Decode message
echo
echo "* Decode using protobuf spec:"
cat test.msg.encoded | protoc --decode=test.Greet test.proto

# Decode raw message
echo
echo "* Decode without using protobuf spec:"
cat test.msg.encoded | protoc --decode_raw
