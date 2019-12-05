import std.stdio;
import std.range;
import std.conv;
import std.container;
import core.stdc.stdlib;
import lib.funcs;
import thing;
import parser;
import vector;

MiniVector!Node todo;
MiniVector!Value stack;
Value[string][] locals;

static this()
{
    Value[string] first;
    first["+"] = dFunc("+");
    first["-"] = dFunc("-");
    first["*"] = dFunc("*");
    first["/"] = dFunc("/");
    first["="] = dFunc("=");
    first["!="] = dFunc("!=");
    first["<"] = dFunc("<");
    first[">"] = dFunc(">");
    first["<="] = dFunc("<=");
    first[">="] = dFunc(">=");
    first["cat"] = dFunc("cat");
    first["strip"] = dFunc("strip");
    first["to-json"] = dFunc("to-json");
    first["exec"] = dFunc("exec");
    first["system"] = dFunc("system");
    first["make-world"] = dFunc("make-world");
    first["save-to"] = dFunc("save-to");
    first["read-from"] = dFunc("read-from");
    first["if"] = dFunc("if");
    first["while"] = dFunc("while");
    first["pass"] = dFunc("pass");
    first["mut"] = dFunc("mut");
    first["set"] = dFunc("set");
    first["proc"] = dFunc("proc");
    first["print"] = dFunc("print");
    first["write"] = dFunc("write");
    first["table"] = dFunc("table");
    first["table-index"] = dFunc("table-index");
    first["table-set"] = dFunc("table-set");
    first["list"] = dFunc("list");
    first["list-index"] = dFunc("list-index");
    first["list-set"] = dFunc("list-set");
    locals ~= first;
    Value[string] second;
    locals ~= second;
}

Value getLocal(string s)
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
    foreach_reverse (i; locals[0 .. $ - 1])
    {
        tops = s in i;
        if (tops)
        {
            return *tops;
        }
    }
    throw new Exception("cannot find " ~ s);
}

void run()
{
    while (!todo.empty)
    {
        Node cur = todo[todo.length - 1];
        todo.popBack;
        final switch (cur.type)
        {
        case Node.Type.NONE:
            break;
        case Node.Type.POP:
            stack.popBack;
            break;
        case Node.Type.POPV:
            stack[stack.length-2] = stack[stack.length-1];
            stack.popBack;
            break;
        case Node.Type.STRING:
            stack ~= makeThing(cur.value.str);
            break;
        case Node.Type.PUSH:
            stack ~= cur.value.value;
            break;
        case Node.Type.LOAD:
            stack ~= getLocal(cur.value.str);
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
            Value[] args = stack.values[stack.length - cur.value.unum .. stack.length];
            stack.length -= cur.value.unum;
            Value last = stack[stack.length - 1];
            stack.popBack;
            while (true)
            {
                if (last.type == Value.Type.NODES)
                {
                    Proc proc = last.get!Proc;
                    callNodes(proc, args);
                    break;
                }
                else if (last.type == Value.Type.FUNC)
                {
                    stack ~= byName(last.get!string)(args);
                    break;
                }
                else if (last.type == Value.Type.STRING)
                {
                    last = getLocal(last.get!string);
                }
                else
                {
                    writeln("not callable " ~ last.to!string);
                    exit(1);
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

void callNodes(bool scoped = true)(Proc proc, Value[] args)
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
        Value[string] argt;
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
