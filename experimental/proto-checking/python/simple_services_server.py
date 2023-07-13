import grpc
from concurrent import futures
import simple_services_pb2
import simple_services_pb2_grpc

class SimpleServicesServicer(simple_services_pb2_grpc.SimpleServicesServicer):
    def foo_rpc(self, request, context):
        print("foo_rpc(self={}, request={}, context={})".format(self, request, context))
        return simple_services_pb2.FooOut(foo_int=(42 if request.foo_bool else 0))

    def bar_rpc(self, request, context):
        print("bar_rpc(self={}, request={}, context={})".format(self, request, context))
        return simple_services_pb2.BarOut(bar_str=str(request.bar_int))

    def baz_rpc(self, request, context):
        print("baz_rpc(self={}, request={}, context={})".format(self, request, context))
        return simple_services_pb2.BazOut(baz_bool=(request.baz_int == 42))

    # Experiment with static type checking of combinations.
    #
    # Combinations such as
    #
    # baz(bar(foo(x)))
    #
    # should be correct while combinations such as
    #
    # bar(foo(baz(x)))
    #
    # should not.
    #
    # A static type checker such as pycheck can be used.

    def baz_bar_foo_rpc(self, request, context):
        print("baz_bar_foo_rpc(self={}, request={}, context={})".format(self, request, context))
        # NEXT
        foo_out = self.foo_rpc(request, context);
        print("foo_out = {}".format(foo_out))


def run_server():
    server = grpc.server(futures.ThreadPoolExecutor())
    simple_services_pb2_grpc.add_SimpleServicesServicer_to_server(SimpleServicesServicer(), server)
    server.add_insecure_port('[::]:50051')  # Set the desired port
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    run_server()
