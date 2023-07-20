def foo(b):
    return 42 if b else 0

def bar(i):
    return str(i)

def baz(s):
    return s == "42"

def tfoo(b : bool) -> int:
    return 42 if b else 0

def tbar(i : int) -> str:
    return str(i)

def tbaz(s : str) -> bool:
    return s == "42"

if __name__ == '__main__':
    print("=== Valid composition ===")
    print("baz(bar(foo(True)) = {}".format(baz(bar(foo(True)))))
    print("")

    print("=== Invalid composition ===")
    print("baz(foo(bar(42)) = {}".format(baz(foo(bar(42)))))
    print("")

    print("=== Invalid composition (using typed functions) ===")
    print("tbaz(tfoo(tbar(42)) = {}".format(tbaz(tfoo(tbar(42)))))
    print("")
