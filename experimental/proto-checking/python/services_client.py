import grpc
import services_pb2
import services_pb2_grpc

def run_client():
    channel = grpc.insecure_channel('localhost:50051')  # Set the server address and port
    stub = services_pb2_grpc.SimpleServicesStub(channel)

    print("=== Test services independently ===")

    # Test foo
    foo_request = services_pb2.FooIn(foo_bool=True)
    foo_response = stub.foo_rpc(foo_request)
    print("Foo response: {}".format(foo_response.foo_int))

    # Test bar
    bar_request = services_pb2.BarIn(bar_int=42)
    bar_response = stub.bar_rpc(bar_request)
    print("Bar response: \"{}\"".format(bar_response.bar_str))

    # Test baz
    baz_request = services_pb2.BazIn(baz_str="42")
    baz_response = stub.baz_rpc(baz_request)
    print("Baz response:", baz_response.baz_bool)

    # Test baz . bar . foo (well-formed)
    print("=== Test baz . bar . foo (well-formed) ===")
    bazbarfoo_foo_request = services_pb2.FooIn(foo_bool=True)
    print("bazbarfoo_foo_request = {}".format(bazbarfoo_foo_request))
    bazbarfoo_foo_response = stub.foo_rpc(bazbarfoo_foo_request)
    print("bazbarfoo_foo_response = {}".format(bazbarfoo_foo_response))
    # Pass the output of foo directly into the input of bar.
    # Interestingly it seems that the field names do not matter, only
    # their types and places.
    bazbarfoo_bar_response = stub.bar_rpc(bazbarfoo_foo_response)
    print("bazbarfoo_bar_response = {}".format(bazbarfoo_bar_response))
    # Pass the output of bar directly into the input of baz.
    bazbarfoo_baz_response = stub.baz_rpc(bazbarfoo_bar_response)
    print("bazbarfoo_baz_response = {}".format(bazbarfoo_baz_response))

    # Test baz . foo . bar (ill-formed)
    print("=== Test baz . foo . bar (ill-formed, direct) ===")
    bazfoobar_bar_request = services_pb2.BarIn(bar_int=42)
    print("bazfoobar_bar_request = {}".format(bazfoobar_bar_request))
    bazfoobar_bar_response = stub.bar_rpc(bazfoobar_bar_request)
    print("bazfoobar_bar_response = {}".format(bazfoobar_bar_response))
    # Pass the output of bar directly into the input of foo, it should
    # fail.  Instead Python just silently ignore these calls.
    bazfoobar_foo_response = stub.foo_rpc(bazfoobar_bar_response)
    print("bazfoobar_foo_response = {}".format(bazfoobar_foo_response))
    bazfoobar_baz_response = stub.baz_rpc(bazfoobar_foo_response)
    print("bazfoobar_baz_response = {}".format(bazfoobar_baz_response))

    # Test baz . foo . bar (ill-formed)
    print("=== Test baz . foo . bar (ill-formed, indirect) ===")
    indirect_bazfoobar_bar_request = services_pb2.BarIn(bar_int=42)
    print("indirect_bazfoobar_bar_request = {}".format(indirect_bazfoobar_bar_request))
    indirect_bazfoobar_bar_response = stub.bar_rpc(indirect_bazfoobar_bar_request)
    print("indirect_bazfoobar_bar_response = {}".format(indirect_bazfoobar_bar_response))
    # Pass the output of bar indirectly, via re-initialization into
    # the input of foo.  It fails.
    indirect_bazfoobar_foo_request = services_pb2.FooIn(foo_bool=indirect_bazfoobar_bar_response.bar_str)
    indirect_bazfoobar_foo_response = stub.foo_rpc(indirect_bazfoobar_foo_request)
    print("indirect_bazfoobar_foo_response = {}".format(indirect_bazfoobar_foo_response))
    indirect_bazfoobar_baz_request = services_pb2.BazIn(baz_str=indirect_bazfoobar_foo_response.foo_int)
    indirect_bazfoobar_baz_response = stub.baz_rpc(indirect_bazfoobar_baz_request)
    print("indirect_bazfoobar_baz_response = {}".format(indirect_bazfoobar_baz_response))

if __name__ == '__main__':
    run_client()
