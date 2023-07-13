import grpc
import simple_services_pb2
import simple_services_pb2_grpc

def run_client():
    channel = grpc.insecure_channel('localhost:50051')  # Set the server address and port
    stub = simple_services_pb2_grpc.SimpleServicesStub(channel)

    # Create a request message
    request = simple_services_pb2.FooIn(foo_bool=True)  # Set the boolean value as needed

    # Call the remote method
    response = stub.foo_rpc(request)

    # Process the response
    print("Received response:", response.foo_int)

if __name__ == '__main__':
    run_client()
