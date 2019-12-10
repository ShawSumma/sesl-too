module vector;
import std.stdio;
import core.memory;

static string growth() {
    return "alloc * 3 + 4";
} 

private static bool isTupleAllOf(T2, T...)()
{
    bool ret = true;
    foreach (TI; T)
    {
        if (!is(T2 == TI))
        {
            ret = false;
        }
    }
    return ret;
}

struct Slice(T, LT = size_t)
{
align(1):
    T* values = void;
    immutable LT length = void;

    this(A...)(A args) if (isTupleAllOf!(T, A))
    {
        length = A.length;
        values = cast(T*) GC.malloc(T.sizeof * A.length);
        static foreach (i, v; args)
        {
            values[i] = v;
        }
    }

    this(T2)(T2 v)
    {
        values = v.values;
        length = cast(LT) v.length;
    }

    this(LT2 = size_t)(T* v, LT2 l)
    {
        values = v;
        length = l;
    }

    Slice!T opSlice(LT2 = size_t, LT3 = size_t)(LT2 s, LT3 e)
    {
        return Slice!T(values + s, e - s);
    }

    LT opDollar(size_t N = 0)()
    {
        return length;
    }

    int opApply(int delegate(T) dg)
    {
        int result = 0;
        for (LT i = 0; i < length; i++)
        {
            result = dg(values[i]);
            if (result)
                break;
        }
        return result;
    }

    int opApply(int delegate(ref LT, T) dg)
    {
        int result = 0;
        for (LT i = 0; i < length; i++)
        {
            result = dg(i, values[i]);
            if (result)
                break;
        }
        return result;
    }

    T opIndex(LT2 = size_t)(LT2 n)
    {
        return values[n];
    }
}

struct Vector(T)
{
    T* values = null;
    size_t alloc = 0;
    size_t length = 0;

    Slice!T opSlice(size_t s, size_t e)
    {
        return Slice!T(values + s, e - s);
    }

    size_t opDollar(size_t s)()
    {
        return length;
    }

    void opOpAssign(string op)(T nv) if (op == "~")
    {
        length++;
        resize;
        values[length - 1] = nv;
    }

    void opOpAssign(string op, T2)(T2 nv) if (op == "~")
    {
        foreach (i; nv) {
            this ~= i;
        }
    }

    void opAssign(void* v)
    {
        if (v == null)
        {
            values = null;
            length = 0;
        }
    }

    int opApply(int delegate(T) dg)
    {
        int result = 0;
        foreach (i; values[0 .. length])
        {
            result = dg(i);
            if (result)
                break;
        }
        return result;
    }

    int opApply(int delegate(ref size_t, T) dg)
    {
        int result = 0;
        foreach (i, v; values[0 .. length])
        {
            result = dg(i, v);
            if (result)
                break;
        }
        return result;
    }

    void resize()
    {
        if (values == null)
        {
            alloc = length + 8;
            values = cast(T*) GC.malloc(T.sizeof * alloc, 0U, typeid(T));
        }
        if (length + 4 > alloc)
        {
            alloc = mixin(growth);
            values = cast(T*) GC.realloc(cast(void*) values, T.sizeof * alloc, 0U, typeid(T));
        }
    }

    void popBack()
    {
        length--;
    }

    ref T opIndex(size_t n)
    {
        return values[n];
    }
}
