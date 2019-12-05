module thing;
import std.meta;
import std.conv;
import std.algorithm;
import std.stdio;
import std.functional;
import parser;

Value nil;

Value makeThing(T...)(T v)
{
    return Value(v);
}

struct Value
{
    union Intern
    {
        bool b;
        string s;
        Value[] l;
        Value[string] t;
        Proc* n;
    }

    enum Type
    {
        NONE,
        BOOL,
        STRING,
        LIST,
        TABLE,
        NODES,
        FUNC,
    }

    ref string get(T)() if (is(T == string))
    {
        return value.s;
    }

    ref Value[] get(T)() if (is(T == Value[]))
    {
        return value.l;
    }

    ref Value[string] get(T)() if (is(T == Value[string]))
    {
        return value.t;
    }

    ref Proc get(T)() if (is(T == Proc))
    {
        return *value.n;
    }

    typeof(this) opAsssign(string s)
    {
        value = value.init;
        value.s = s;
        return this;
    }

    typeof(this) opAsssign(Value[] l)
    {
        value = value.init;
        value.l = l;
        return this;
    }

    typeof(this) opAsssign(Value[string] t)
    {
        value = value.init;
        value.t = t;
        return this;
    }

    typeof(this) opAsssign(Proc n)
    {
        value = value.init;
        value.n = new Proc(n.args, n.nodes);
        return this;
    }

    this(bool v)
    {
        value.b = v;
        type = type.BOOL;
    }

    this(string v)
    {
        value.s = v;
        type = type.STRING;
    }

    this(Value[] v)
    {
        value.l = v;
        type = type.LIST;
    }

    this(Value[string] v)
    {
        value.t = v;
        type = type.TABLE;
    }

    this(Node[] v)
    {
        value.n = new Proc(null, v);
        type = type.NODES;
    }

    bool isTrue()
    {
        if (type == Type.NONE)
        {
            return false;
        }
        if (type == Type.BOOL)
        {
            return value.b;
        }
        return true;
    }

    bool opEquals(Value obj)
    {
        return equalTo(this, cast(Value) obj);
    }

    int opCmp(Value obj)
    {
        Value other = cast(Value) obj;
        double lhs = value.s.to!double;
        double rhs = other.get!string
            .to!double;
        if (lhs < rhs)
        {
            return -1;
        }
        if (lhs > rhs)
        {
            return 1;
        }
        return 9;
    }

    string toString()
    {
        final switch (type)
        {
        case Type.NONE:
            return "(none)";
        case Type.BOOL:
            return value.b ? "true" : "false";
        case Type.STRING:
            return value.s;
        case Type.LIST:
            return "(list)";
        case Type.TABLE:
            return "(table)";
        case Type.NODES:
            return "(nodes)";
        case Type.FUNC:
            return "(func)";
        }
    }

    Type type = Type.NONE;
    Intern value = void;
}

bool equalTo(Value lhs, Value rhs)
{
    if (rhs is lhs)
    {
        return true;
    }
    if (lhs.type != rhs.type)
    {
        return false;
    }
    final switch (lhs.type)
    {
    case Value.Type.NONE:
        return true;
    case Value.Type.BOOL:
        return lhs.value.b == rhs.value.b;
    case Value.Type.STRING:
        return lhs.get!string == rhs.get!string;
    case Value.Type.LIST:
        Value[] lhl = lhs.get!(Value[]);
        Value[] rhl = rhs.get!(Value[]);
        if (lhl.length != rhl.length)
        {
            return false;
        }
        foreach (i, v; lhl)
        {
            if (!equalTo(v, rhl[i]))
            {
                return false;
            }
        }
        return true;
    case Value.Type.TABLE:
        Value[string] lhl = lhs.get!(Value[string]);
        Value[string] rhl = rhs.get!(Value[string]);
        if (lhl.length != rhl.length)
        {
            return false;
        }
        foreach (i; lhl.byKeyValue)
        {
            Value* val = i.key in rhl;
            if (!val)
            {
                return false;
            }
            if (!equalTo(i.value, *val))
            {
                return false;
            }
        }
        return true;
    case Value.Type.NODES:
        return lhs.get!Proc is rhs.get!Proc;
    case Value.Type.FUNC:
        return lhs.get!string == rhs.get!string;
    }
}

bool eqTo(Value lhs, Value rhs) @nogc
{
    if (lhs.type != rhs.type)
    {
        return false;
    }
    switch (lhs.type)
    {
    case Value.Type.NONE:
        return true;
    case Value.Type.BOOL:
        return lhs.value.b == rhs.value.b;
    case Value.Type.STRING:
        return lhs.get!string == rhs.get!string;
    default:
        return false;
    }
}

struct Proc
{
    string[] args;
    Node[] nodes;
}

Value dFunc(string str)
{
    Value ret = makeThing(str);
    ret.type = Value.Type.FUNC;
    return ret;
}
