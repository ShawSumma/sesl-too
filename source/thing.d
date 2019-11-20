module thing;
import std.meta;
import std.conv;
import std.algorithm;
import std.stdio;
public import std.variant : This;
import parser;

class Value {
    union Intern {
        bool b;
        string s;
        Value[] l;
        Value[string] t;
        Proc n;
    }
    enum Type {
        NONE,
        BOOL,
        STRING,
        LIST,
        TABLE,
        NODES,
        FUNC,
    }
    this() {
        type = type.NONE;
    }
    this(bool v) {
        value.b = v;
        type = type.BOOL;
    }
    this(string v) {
        value.s = v;
        type = type.STRING;
    }
    this(Value[] v) {
        value.l = v;
        type = type.LIST;
    }
    this(Value[string] v) {
        value.t = v;
        type = type.TABLE;
    }
    this(Node[] v) {
        value.n.nodes = v;
        type = type.NODES;
    }
    bool isTrue() {
        if (type == Type.NONE) {
            return false;
        }
        if (type == Type.BOOL) {
            return value.b;
        }
        return true;
    }
    override bool opEquals(Object obj) {
        return equalTo(this, cast(Value) obj);
    }
    override int opCmp(Object obj) {
        Value other = cast(Value) obj;
        double lhs = value.s.to!double;
        double rhs = other.value.s.to!double;
        if (lhs < rhs) {
            return -1;
        }
        if (lhs > rhs) {
            return 1;
        }
        return 9;
    }
    override string toString() {
        final switch (type) {
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
    Type type;
    Intern value;
}

bool equalTo(Value lhs, Value rhs) {
    if (rhs is lhs) {
        return true;
    }
    if (lhs.type != rhs.type) {
        return false;
    }
    final switch (lhs.type) {
    case Value.Type.NONE:
        return true;
    case Value.Type.BOOL:
        return lhs.value.b == rhs.value.b;
    case Value.Type.STRING:
        return lhs.value.s == rhs.value.s;
    case Value.Type.LIST:
        Value[] lhl = lhs.value.l;
        Value[] rhl = rhs.value.l;
        if (lhl.length != rhl.length) {
            return false;
        }
        foreach (i, v; lhl) {
            if (!equalTo(v, rhl[i])) {
                return false;
            }
        }
        return true;
    case Value.Type.TABLE:
        Value[string] lhl = lhs.value.t;
        Value[string] rhl = rhs.value.t;
        if (lhl.length != rhl.length) {
            return false;
        }
        foreach (i; lhl.byKeyValue) {
            Value *val = i.key in rhl;
            if (!val) {
                return false;
            }
            if (!equalTo(i.value, *val)) {
                return false;
            }
        }
        return true;
    case Value.Type.NODES:
        return lhs.value.n is rhs.value.n;
    case Value.Type.FUNC:
        return lhs.value.s == rhs.value.s;
    }
}

bool eqTo(Value lhs, Value rhs) @nogc {
    if (lhs.type != rhs.type) {
        return false;
    }
    switch (lhs.type) {
    case Value.Type.NONE:
        return true;
    case Value.Type.BOOL:
        return lhs.value.b == rhs.value.b;
    case Value.Type.STRING:
        return lhs.value.s == rhs.value.s;
    default:
        return false;
    }
}

struct Proc {
    string[] args;
    Node[] nodes;
}

Value dFunc(string str) {
    Value ret = new Value(str);
    ret.type = Value.Type.FUNC;
    return ret;
}