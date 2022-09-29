module Debug.NoTrace

-- Workaround to easily disable tracing.

||| Like Debug.Trace.trace but does not trace anything.
public export
trace : Lazy String -> a -> a
trace _ x = x
