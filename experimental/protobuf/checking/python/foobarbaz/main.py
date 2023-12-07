from foobarbaz import foo, bar, baz

if __name__ == '__main__':
    print("=== Valid composition ===")
    print("baz(bar(foo(True)) = {}".format(baz(bar(foo(True)))))
    print("")

    print("=== Invalid composition ===")
    print("baz(foo(bar(42)) = {}".format(baz(foo(bar(42)))))
    print("")
