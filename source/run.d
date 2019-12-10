import std.stdio;
import std.range;
import std.conv;
import core.stdc.stdlib;
import lib.funcs;
import thing;
import parser;
import vector;
import intern;

Vector!Node todo;
Vector!Value stack;
Vector!(Value[Intern]) locals;

static this()
{
    Value[Intern] base;
    void first(string k, Value v)
    {
        base[Intern(k)] = v;
    }

    first("nil", makeThing());
    first("true", makeThing(true));
    first("false", makeThing(false));
    first("+", dFunc("+"));
    first("-", dFunc("-"));
    first("*", dFunc("*"));
    first("/", dFunc("/"));
    first("%", dFunc("%"));
    first("=", dFunc("="));
    first("!=", dFunc("!="));
    first("<", dFunc("<"));
    first(">", dFunc(">"));
    first("<=", dFunc("<="));
    first(">=", dFunc(">="));
    first("cat", dFunc("cat"));
    first("strip", dFunc("strip"));
    first("to-json", dFunc("to-json"));
    first("exec", dFunc("exec"));
    first("system", dFunc("system"));
    first("make-world", dFunc("make-world"));
    first("save-to", dFunc("save-to"));
    first("read-from", dFunc("read-from"));
    first("if", dFunc("if"));
    first("while", dFunc("while"));
    first("pass", dFunc("pass"));
    first("set", dFunc("set"));
    first("proc", dFunc("proc"));
    first("lambda", dFunc("lambda"));
    first("print", dFunc("print"));
    first("write", dFunc("write"));
    first("table", dFunc("table"));
    first("table-index", dFunc("table-index"));
    first("table-set", dFunc("table-set"));
    first("list", dFunc("list"));
    first("list-index", dFunc("list-index"));
    first("list-set", dFunc("list-set"));
    locals ~= base;
    Value[Intern] second;
    locals ~= second;
}

Value getLocal(Intern s)
{
    Value* tops = s in locals[$ - 1];
    if (tops)
    {
        return *tops;
    }
    tops = s in locals[0];
    if (tops)
    {
        return *tops;
    }
    tops = s in locals[1];
    if (tops)
    {
        return *tops;
    }
    for (size_t i = locals.length; i > 0; i--)
    {
        tops = s in locals[i];
        if (tops)
        {
            return *tops;
        }
    }
    throw new Exception("cannot find " ~ s.val);
}

void run()
{
    runloop: while (todo.length != 0)
    {
        Node cur = todo[$ - 1];
        todo.popBack;
        final switch (cur.type)
        {
        case Node.Type.NONE:
            break;
        case Node.Type.POP:
            stack.popBack;
            break;
        case Node.Type.POPV:
            stack[$ - 2] = stack[$ - 1];
            stack.popBack;
            break;
        case Node.Type.PUSH:
            stack ~= cur.value.value;
            break;
        case Node.Type.LOAD:
            stack ~= getLocal(cur.value.interned);
            break;
        case Node.Type.CALL:
            size_t len = cur.value.nodes.length;
            Node doc;
            doc.type = Node.Type.DOCALL;
            doc.value.unum = len - 1;
            todo ~= doc;
            foreach_reverse (node; cur.value.nodes)
            {
                todo ~= node;
            }
            break;
        case Node.Type.DOCALL:
            Args args = Args(stack[$ - cur.value.unum .. $]);
            stack.length -= cur.value.unum;
            Value last = stack[$ - 1];
            stack.popBack;
            while (true)
            {
                switch (last.type)
                {
                case Value.Type.NODES:
                    Proc proc = last.get!Proc;
                    callNodes(proc, args);
                    continue runloop;
                case Value.Type.FUNC:
                    stack ~= last.value.f.dfunc(args);
                    continue runloop;
                case Value.Type.STRING:
                    last = getLocal(Intern(last.get!string));
                    break;
                case Value.Type.INTERN:
                    last = getLocal(last.get!Intern);
                    break;
                default:
                    throw new Exception("not callable " ~ last.to!string);
                }
            }
            break;
        case Node.Type.ENTER:
            locals ~= cur.value.table;
            break;
        case Node.Type.EXIT:
            locals.popBack;
            break;
        }
    }
}

void callNodes(bool scoped = true)(Proc proc, Args args)
{
    Node[] nodes = proc.nodes;
    static if (scoped)
    {
        Node exNode;
        exNode.type = Node.Type.EXIT;
        todo ~= exNode;
    }
    foreach_reverse (i, node; nodes)
    {
        todo ~= node;
        if (i != 0)
        {
            Node popNode;
            popNode.type = Node.Type.POP;
            todo ~= popNode;
        }
    }
    if (nodes.length == 0)
    {
        Node nn;
        nn.type = Node.Type.PUSH;
        nn.value.value = nil;
        todo ~= nn;
    }
    static if (scoped)
    {
        Node enNode;
        enNode.type = Node.Type.ENTER;
        Value[Intern] argt;
        foreach (i, v; args)
        {
            argt[proc.args[i]] = v;
        }
        enNode.value.table = argt;
        todo ~= enNode;
    }
}

void runNode(Node n)
{
    todo ~= n;
}
