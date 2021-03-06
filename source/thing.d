module thing;
import std.meta;
import std.conv;
import std.algorithm;
import std.stdio;
import std.functional;
import parser;
import intern;
import vector;
import lib.funcs;

alias Number = double;
alias Args = Slice!(Value);

Value nil;
Args noargs;

Value makeThing(T...)(T v)
{
    return Value(v);
}

Value makeThing(Value v)
{
    return v;
}

struct Value
{
    union InternalUnion
    {
        bool b;
        Number d;
        Intern i;
        Value[string] t;
        string* s;
        Vector!Value* l;
        Proc n;
        Func f;
    }

    enum Type : byte
    {
        NONE,
        BOOL,
        NUMBER,
        STRING,
        INTERN,
        LIST,
        TABLE,
        NODES,
        FUNC,
    }

    string get(T)() if (is(T == string))
    {
        return toString;
    }

    Intern get(T)() if (is(T == Intern))
    {
        if (type == Type.INTERN)
        {
            return value.i;
        }
        return Intern(*value.s);
    }

    ref Vector!Value get(T)() if (is(T == Vector!Value))
    {
        return *value.l;
    }

    Value opIndex(size_t n)
    {
        switch (type)
        {
        case Type.TABLE:
            return value.t[n.to!string];
        case Type.LIST:
            return get!(Vector!Value)[n];
        default:
            throw new Exception("index error");
        }
    }

    ref Value[string] get(T)() if (is(T == Value[string]))
    {
        return value.t;
    }

    ref Proc get(T)() if (is(T == Proc))
    {
        return value.n;
    }

    Number get(T)() if (is(T == Number))
    {
        if (type == Type.NUMBER)
        {
            return value.d;
        }
        if (type == Type.INTERN)
        {
            return value.i.val.to!Number;
        }
        return (*value.s).to!Number;
    }

    this(bool v)
    {
        value.b = v;
        type = type.BOOL;
    }

    this(Number d)
    {
        value.d = d;
        type = type.NUMBER;
    }

    this(string v)
    {
        value.s = [v].ptr;
        type = type.STRING;
    }

    this(Vector!Value v)
    {
        value.l = [v].ptr;
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

    this(Intern v)
    {
        value.i = v;
        type = type.INTERN;
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
        Number lhs = get!Number;
        Number rhs = other.get!Number;
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
        case Type.NUMBER:
            return value.d.to!string;
        case Type.STRING:
            return *value.s;
        case Type.INTERN:
            return value.i.val;
        case Type.LIST:
            return "(list)";
        case Type.TABLE:
            return "(table)";
        case Type.NODES:
            return "(nodes)";
        case Type.FUNC:
            return "(func " ~ value.f.name ~ ")";
        }
    }

align(4):

    InternalUnion value = void;
    Type type = Type.NONE;
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
    case Value.Type.NUMBER:
        return lhs.value.d == rhs.value.d;
    case Value.Type.STRING:
        return *lhs.value.s == *rhs.value.s;
    case Value.Type.INTERN:
        return lhs.value.i == rhs.value.i;
    case Value.Type.LIST:
        Vector!Value lhl = lhs.get!(Vector!Value);
        Vector!Value rhl = rhs.get!(Vector!Value);
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
        return lhs.value.f.dfunc == rhs.value.f.dfunc;
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
    case Value.Type.NUMBER:
        return lhs.value.d == rhs.value.d;
    case Value.Type.STRING:
        return lhs.value.s == rhs.value.s;
    case Value.Type.INTERN:
        return lhs.value.i == rhs.value.i;
    default:
        return false;
    }
}

class Proc
{
    Intern[] args;
    Node[] nodes;
    this(Intern[] a, Node[] n)
    {
        args = a;
        nodes = n;
    }
}

class Func
{
    Value function(Args) dfunc;
    string name;
    this(string n)
    {
        name = n;
        dfunc = n.byName;
    }
}

Value dFunc(string str)
{
    Value ret;
    ret.value.f = new Func(str);
    ret.type = Value.Type.FUNC;
    return ret;
}
