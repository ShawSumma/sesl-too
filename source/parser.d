module parser;
import std.stdio;
import std.conv;
import std.algorithm;
import thing;

struct Node {
    union Intern {
        string str;
        Node[] nodes;
        Value value;
        ulong unum;
        Value[string] table;
    }
    enum Type {
        NONE,
        STRING,
        POP,
        POPV,
        PUSH,
        LOAD,
        CALL,
        DOCALL,
        ENTER,
        EXIT,
    }
    Type type;
    Intern value;
    string toString() {
        switch (type) {
        case Type.NONE:
            return "(nil)";
        case Type.STRING:
            return "(str '" ~ value.str ~ "')";
        case Type.LOAD:
            return "(load $" ~ value.str ~ ")";
        case Type.CALL:
            string ret;
            ret ~= "(call ";
            foreach (i, v; value.nodes) {
                if (i != 0) {
                    ret ~= ", ";
                }
                ret ~= v.to!string;
            }
            ret ~= ")";
            return ret;
        case Type.PUSH:
            return "(value " ~ value.value.to!string ~ ")";
        case Type.DOCALL:
            return "(docall " ~ value.unum.to!string ~ ")";
        case Type.ENTER:
            return "(enter)";
        case Type.EXIT:
            return "(exit)";
        default:
            return "(???)";
        }
    }
}

char first(ref string s) {
    if (s.length == 0) {
        return '\0';
    }
    return s[0];
}

void strip(ref string s) {
    while (canFind("\t ", s.first)) {
        s = s[1..$];
    }
}

void strips(ref string s) {
    while (canFind("\r\n\t ", s.first)) {
        s = s[1..$];
    }
}

Node parseWord(ref string s) {
    s.strip;
    if (s.first == '(') {
        s = s[1..$];
        return s.parseCmd!true;
    }
    if (s.first == '{') {
        s = s[1..$];
        Node ret;
        Node[] nodes = s.parseBody;
        ret.type = Node.Type.PUSH;
        ret.value.value = new Value(nodes);
        return ret;
    }
    string str;
    while (!canFind("{}();\n\r\t ", s.first)) {
        if (s.first == '\0') {
            break;
        }
        str ~= s.first;
        s = s[1..$];
    }
    Node ret;
    if (str.first == '$') {
        ret.type = Node.Type.LOAD;
        ret.value.str = str[1..$];
    }
    else {
        ret.type = Node.Type.STRING;
        ret.value.str = str;
    }
    return ret;
}

Node parseCmd(bool subCmd=false)(ref string s) {
    Node[] call;
    s.strip;
    while (!canFind("}\n\r", s.first)) {
        if (s.first == '\0') {
            break;
        }
        static if (subCmd) {
            if (s.first == ')') {
                s = s[1..$];
                break;
            }
        }
        static if (!subCmd) {
            if (s.first == ';') {
                break;
            }
        }
        call ~= s.parseWord;
        s.strip;
    }
    Node ret;
    ret.type = Node.Type.CALL;
    ret.value.nodes = call;
    return ret;
}

Node[] parseBody(ref string s) {
    Node[] ret;
    while (!canFind(")}", s.first)) {
        if (s.first == '\0') {
            break;
        }
        Node cmdNode = s.parseCmd;
        if (cmdNode.value.nodes.length > 0) {
            ret ~= cmdNode;
        }
        s.strips;
    }
    if (s.first != '\0') {
        s = s[1..$];
    }
    return ret;
}
