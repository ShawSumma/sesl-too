import std.stdio;
import std.conv;
import std.json;
import std.file;
import std.datetime;
import thing;
import parser;
import serial;
import run;

Value fnPrint(Value[] args) {
    foreach (i, v; args) {
        if (i != 0) {
            write(" ");
        }
        write(v);
    }
    writeln;
    return new Value;
}

Value fnAdd(Value[] args) {
    double ret = 0;
    foreach (i; args) {
        ret += to!double(i.value.s);
    }
    return new Value(to!string(ret));
}

Value fnSub(Value[] args) {
    double ret = to!double(args[0].value.s);
    if (args.length == 1) {
        return new Value(to!string(0-ret));
    }
    foreach (i; args[1..$]) {
        ret -= to!double(i.value.s);
    }
    return new Value(to!string(ret));
}

Value fnMul(Value[] args) {
    double ret = 1;
    foreach (i; args) {
        ret *= to!double(i.value.s);
    }
    return new Value(to!string(ret));
}

Value fnDiv(Value[] args) {
    double ret = to!double(args[0].value.s);
    if (args.length == 1) {
        return new Value(to!string(1/ret));
    }
    foreach (i; args[1..$]) {
        ret /= to!double(i.value.s);
    }
    return new Value(to!string(ret));
}

Value fnSet(Value[] args) {
    if (args.length == 1) {
        locals[$-1][args[0].value.s] = new Value;
        return new Value;
    }
    else {
        locals[$-1][args[0].value.s] = args[1];
        return args[1];
    }
}

Value fnMut(Value[] args) {
    Value val = args[1];
    string key = args[0].value.s;
    Value *tops = key in locals[$-1];
    if (tops) {
        *tops = val;
        return val;
    }
    tops = key in locals[1];
    if (tops) {
        *tops = val;
        return val;
    }
    foreach_reverse (i; locals[1..$-1]) {
        tops = key in i;
        if (tops) {
            *tops = val;
            return val;
        }
    }
    locals[$-1][key] = val;
    return val;
}

Value fnUpto(Value[] args) {
    Value[] vals;
    foreach (i; 0..cast(ulong) to!double(args[0].value.s)) {
        vals ~= new Value(to!string(i));
    }
    return new Value(vals);
}

Value fnProc(Value[] args) {
    Value ret = args[$-1];
    foreach (i; args[1..$-1]) {
        ret.value.n.args ~= i.value.s;
    }
    locals[$-1][args[0].value.s] = ret;
    return ret;
}

Value fnEq(Value[] args) {
    foreach (i, x; args[0..$-1]) {
        foreach (j, y; args[i+1..$]) {
            if (x != y) {
                return new Value(false);
            }
        }
    }
    return new Value(true);
}

Value fnNeq(Value[] args) {
    foreach (i, x; args[0..$-1]) {
        foreach (j, y; args[i+1..$]) {
            if (x == y) {
                return new Value(false);
            }
        }
    }
    return new Value(true);
}

Value fnLt(Value[] args) {
    Value last = args[0];
    foreach (i; args[1..$]) {
        if (!(last < i)) {
            return new Value(false);
        }
        last = i;
    }
    return new Value(true);
}

Value fnGt(Value[] args) {
    Value last = args[0];
    foreach (i; args[1..$]) {
        if (!(last > i)) {
            return new Value(false);
        }
        last = i;
    }
    return new Value(true);
}

Value fnLte(Value[] args) {
    Value last = args[0];
    foreach (i; args[1..$]) {
        if (!(last <= i)) {
            return new Value(false);
        }
        last = i;
    }
    return new Value(true);
}

Value fnGte(Value[] args) {
    Value last = args[0];
    foreach (i; args[1..$]) {
        if (!(last >= i)) {
            return new Value(false);
        }
        last = i;
    }
    return new Value(true);
}

Value fnPass(Value[] args) {
    if (args.length == 0) {
        return new Value;
    }
    return args[$-1];
}

Value fnToJson(Value[] args) {
    return new Value(args[0].fromValue(new JsonState).to!string);
}

Value fnStack(Value[] args) {
    return new Value(stack[0..$-1].dup);
}

Value fnMakeWorld(Value[] args) {
    return new Value(makeWorld);
}

Value fnReadFrom(Value[] args) {
    return new Value(cast(string) read(args[0].value.s));
}

Value fnExec(Value[] args) {
    loadWorld(args[0].value.s);
    return new Value;
}

Value fnSaveTo(Value[] args) {
    File fout = File(args[0].value.s, "w");
    fout.write(args[1].to!string);
    return new Value;
}

Value fnCat(Value[] args) {
    string ret;
    foreach (i; args) {
        ret ~= i.to!string;
    }
    return new Value(ret);
}

Value fnIf(Value[] args) {
    Node n;
    n.type = Node.Type.POPV;
    runNode(n);
    if (args[0].isTrue) {
        callNodes!false(args[1].value.n, null);
    }
    else if (args.length == 3) {
        callNodes!false(args[2].value.n, null);
    }
    else {
        n.type = Node.Type.PUSH;
        n.value.value = new Value;
        todo ~= n;
    }
    return new Value;
}

Value fnSetJump(Value[] args) {
    Value[] ret;
    ret ~= new Value(stack);
    ret ~= new Value(todo);
    return new Value(ret);
}

Value fnLongJump(Value[] args) {
    stack = args[0].value.l[0].value.l;
    todo = args[0].value.l[1].value.n.nodes;
    return args[0];
}

Value function(Value[]) byName(string name) {
    switch (name) {
    case "if":
        return &fnIf;
    case "set-jump":
        return &fnSetJump;
    case "long-jump":
        return &fnLongJump;
    case "pass":
        return &fnPass;
    case "print":
        return &fnPrint;
    case "to-json":
        return &fnToJson;
    case "make-world":
        return &fnMakeWorld;
    case "exec":
        return &fnExec;
    case "save-to":
        return &fnSaveTo;
    case "read-from":
        return &fnReadFrom;
    case "stack":
        return &fnStack;
    case "cat":
        return &fnCat;
    case "+":
        return &fnAdd;
    case "-":
        return &fnSub;
    case "*":
        return &fnMul;
    case "/":
        return &fnDiv;
    case "=":
        return &fnEq;
    case "!=":
        return &fnNeq;
    case "<":
        return &fnLt;
    case ">":
        return &fnGt;
    case "<=":
        return &fnLte;
    case ">=":
        return &fnGte;
    case "set":
        return &fnSet;
    case "mut":
        return &fnMut;
    case "proc":
        return &fnProc;
    default:
        throw new Exception("no name " ~ name);
    }
}