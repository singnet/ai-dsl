import grpc
from concurrent import futures
import services_pb2
import services_pb2_grpc

class SimpleServicesServicer(services_pb2_grpc.SimpleServicesServicer):
    def foo_rpc(self, request, context):
        print("foo_rpc(self={}, request={}, context={})".format(self, request, context))
        return services_pb2.FooOut(foo_int=(42 if request.foo_bool else 0))

    def bar_rpc(self, request, context):
        print("bar_rpc(self={}, request={}, context={})".format(self, request, context))
        return services_pb2.BarOut(bar_str=str(request.bar_int))

    def baz_rpc(self, request, context):
        print("baz_rpc(self={}, request={}, context={})".format(self, request, context))
        return services_pb2.BazOut(baz_bool=(request.baz_str == "42"))


# Experiment with static type checking of combinations.
#
# Combinations such as
#
# baz(bar(foo(x)))
#
# should type check while combinations such as
#
# bar(foo(baz(x)))
#
# should not.
#
# A static type checker such as mypy, pysonar, pyflakes, pytype, pyre,
# pyright or pychecker could then be used.
class CompositeServicesServicer(services_pb2_grpc.CompositeServicesServicer):
    def bazbarfoo_rpc(self, request, context):
        print("bazbarfoo_rpc(self={}, request={}, context={})".format(self, request, context))
        # NEXT
        foo_out = self.foo_rpc(request, context);
        print("foo_out = {}".format(foo_out))


def run_server():
    server = grpc.server(futures.ThreadPoolExecutor())
    services_pb2_grpc.add_SimpleServicesServicer_to_server(SimpleServicesServicer(), server)
    server.add_insecure_port('[::]:50051')  # Set the desired port
    server.start()
    server.wait_for_termination()

if __name__ == '__main__':
    run_server()
