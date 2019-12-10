module build;
import std.typecons;
import std.meta;
import parser;
import run;
import thing;
import vector;

Node popNode()
{
    Node ret;
    ret.type = Node.Type.POP;
    return ret;
}

void runPopNode()
{
    popNode.runNode;
}

Node pushNode(Value value)
{
    Node ret;
    ret.type = Node.Type.PUSH;
    ret.value.value = value;
    return ret;
}

void runPushNode(Value value)
{
    pushNode(value).runNode;
}

Node docallNode(ulong unum)
{
    Node ret;
    ret.type = Node.Type.DOCALL;
    ret.value.unum = unum;
    return ret;
}

void runDocallNode(ulong unum)
{
    docallNode(unum).runNode;
}

Node call(T...)(Node func, T argt)
{
    Node[] args = [func];
    static foreach (i; argt)
    {
        args ~= Node(i);
    }
    return Node(Node.Type.CALL, Node.InternalUnion(args));
}

Node call(F, T...)(F func, T argt)
{
    Node[] args = [func.pushNode];
    static foreach (i; argt)
    {
        static if (is(typeof(i) == Value))
        {
            args ~= i.pushNode;
        }
        static if (is(typeof(i) == Node))
        {
            args ~= i;
        }
    }
    Node ret;
    ret.type = Node.Type.CALL;
    ret.value.nodes = args;
    return ret;
}

Node call(F, T)(F func, T argt)
{
    Node[] args = [func.pushNode];
    foreach (i; argt)
    {
        args ~= i.pushNode;
    }
    Node ret;
    ret.type = Node.Type.CALL;
    ret.value.nodes = args;
    return ret;
}

static bool isNode(T)()
{
    return is(typeof(ca) == Value) || is(typeof(ca) == Node);
}

Node iftrue(C, T, F)(C ca, T ta, F fa)
{
    static if (is(F == Value))
    {
        Node iff = fa.pushNode;
    }
    static if (is(F == Node))
    {
        Node iff = fa;
    }
    static if (is(T == Value))
    {
        Node ift = ta.pushNode;
    }
    static if (is(T == Node))
    {
        Node ift = ta;
    }
    static if (is(C == Value))
    {
        Node cs = ca.pushNode;
    }
    static if (is(C == Node))
    {
        Node cs = ca;
    }
    return dFunc("if").call(cs, ift, iff);
}

Value nothing()
{
    runPopNode;
    return nil;
}

Value ret(Node n)
{
    n.runNode;
    return nothing;
}

auto at(T)(T a, size_t i)
{
    if (i > a.length)
    {
        throw new Exception("index error");
    }
    return a[i];
}