module vector;
import std.stdio;
import core.memory;

struct MiniVector(T)
{
    T* values = null;
    size_t alloc = 0;
    size_t length = 0;

    void opOpAssign(string op)(T nv) if (op == "~")
    {
        length++;
        resize;
        values[length - 1] = nv;
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
        if (length + 4 > alloc)
        {
            alloc = alloc * 2 + 4;
            values = cast(T*) GC.realloc(cast(void*) values, T.sizeof * alloc);
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
