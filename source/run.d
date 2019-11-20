import std.stdio;
import std.range;
import std.conv;
import std.container;
import thing;
import parser;
import funcs;

Node[] todo;
Value[] stack;
Value[string][] locals;
 
static this() {
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
    first["stack"] = dFunc("stack");
    first["to-json"] = dFunc("to-json");
    first["exec"] = dFunc("exec");
    first["make-world"] = dFunc("make-world");
    first["save-to"] = dFunc("save-to");
    first["read-from"] = dFunc("read-from");
    first["if"] = dFunc("if");
    first["pass"] = dFunc("pass");
    first["mut"] = dFunc("mut");
    first["set"] = dFunc("set");
    first["proc"] = dFunc("proc");
    first["print"] = dFunc("print");
    first["set-jump"] = dFunc("set-jump");
    first["long-jump"] = dFunc("long-jump");
    locals ~= first;
    Value[string] second;
    locals ~= second;
}

Value getLocal(string s) {
    Value *tops = s in locals[$-1];
    if (tops) {
        return *tops;
    }
    tops = s in locals[0];
    if (tops) {
        return *tops;
    }
    tops = s in locals[1];
    if (tops) {
        return *tops;
    }
    foreach_reverse (i; locals[0..$-1]) {
        tops = s in i;
        if (tops) {
            return *tops;
        }
    }
    throw new Exception("cannot find " ~ s);
}

void run() {
    while (!todo.empty) {
        Node cur = todo[$-1];
        todo.popBack;
        final switch (cur.type) {
        case Node.Type.NONE:
            break;
        case Node.Type.POP:
            stack.popBack;
            break;
        case Node.Type.POPV:
            stack[$-2] = stack[$-1];
            stack.popBack;
            break;
        case Node.Type.STRING:
            stack ~= new Value(cur.value.str);
            break;
        case Node.Type.PUSH:
            stack ~= cur.value.value;
            break;
        case Node.Type.LOAD:
            stack ~= getLocal(cur.value.str);
            break;
        case Node.Type.CALL:
            Node doc;
            doc.type = Node.Type.DOCALL;
            doc.value.unum = cur.value.nodes.length - 1;
            todo ~= doc;
            foreach_reverse (node; cur.value.nodes) {
                todo ~= node;
            }
            break;
        case Node.Type.DOCALL:
            Value[] args = stack[$-cur.value.unum..$].dup;
            stack.popBackN(cur.value.unum);
            Value last = stack[$-1];
            stack.popBack;
            while (true) {
                if (last.type == Value.Type.NODES) {
                    Proc proc = last.value.n;
                    callNodes(proc, args);
                    break;
                }
                else if (last.type == Value.Type.FUNC) {
                    stack ~= byName(last.value.s)(args);
                    break;
                }
                else if (last.type == Value.Type.STRING) {
                    last = getLocal(last.value.s);
                }
                else {
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

void callNodes(bool scoped = true)(Proc proc, Value[] args) {
    Node[] nodes = proc.nodes;
    static if (scoped) {
        Node exNode;
        exNode.type = Node.Type.EXIT;
        todo ~= exNode;
    }
    foreach_reverse (i, node; nodes) {
        todo ~= node;
        if (i != 0) {
            Node popNode;
            popNode.type = Node.Type.POP;
            todo ~= popNode;
        }
    }
    if (nodes.length == 0) {
        Node nn;
        nn.type = Node.Type.PUSH;
        nn.value.value = new Value;
        todo ~= nn;
    }
    static if (scoped) {
        Node enNode;
        enNode.type = Node.Type.ENTER;
        Value[string] argt;
        foreach (i, v; args) {
            argt[proc.args[i]] = v;
        }
        enNode.value.table = argt;
        todo ~= enNode;
    }
}

void runNode(Node n) {
    todo ~= n;
}