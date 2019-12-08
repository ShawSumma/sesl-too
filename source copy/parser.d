module parser;
import std.stdio;
import std.conv;
import std.string;
import std.algorithm;
import intern;
import thing;

version = StringsAsNumbers;

struct Node
{
    union InternalUnion
    {
        string str;
        Node[] nodes;
        Value value;
        size_t unum;
        Intern interned;
        Value[Intern] table;
    }

    enum Type
    {
        NONE,
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
    InternalUnion value;
    string toString()
    {
        switch (type)
        {
        case Type.NONE:
            return "(nil)";
        case Type.LOAD:
            return "(load $" ~ value.unum.to!string ~ ")";
        case Type.CALL:
            string ret;
            ret ~= "(call ";
            foreach (i, v; value.nodes)
            {
                if (i != 0)
                {
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

char first(ref string s)
{
    if (s.length == 0)
    {
        return '\0';
    }
    return s[0];
}

void strip(ref string s)
{
    while (canFind("\t ", s.first))
    {
        s = s[1 .. $];
    }
}

void strips(ref string s)
{
    while (canFind("\r\n;\t ", s.first))
    {
        s = s[1 .. $];
    }
}

Node parseWord(ref string s)
{
    s.strip;
    if (s.first == '(')
    {
        s = s[1 .. $];
        return s.parseCmd!true;
    }
    if (s.first == '{')
    {
        s = s[1 .. $];
        Node ret;
        Node[] nodes = s.parseBody;
        ret.type = Node.Type.PUSH;
        ret.value.value = makeThing(nodes);
        return ret;
    }
    string str;
    while (!canFind("{}();\n\r\t ", s.first))
    {
        if (s.first == '\0')
        {
            break;
        }
        str ~= s.first;
        s = s[1 .. $];
    }
    Node ret;
    if (str.first == '$')
    {
        ret.type = Node.Type.LOAD;
        ret.value.interned = Intern(str[1 .. $]);
    }
    else
    {
        version (StringsAsNumbers)
        {
            if (str.isNumeric)
            {
                ret.type = Node.Type.PUSH;
                ret.value.value = makeThing(str.to!Number);
            }
            else
            {
                ret.type = Node.Type.PUSH;
                ret.value.value = Value(Intern(str));
            }
        }
        else
        {
            ret.type = Node.Type.PUSH;
            ret.value.value = Value(Intern(str));
        }
    }
    return ret;
}

Node parseCmd(bool subCmd = false)(ref string s)
{
    Node[] call;
    s.strip;
    while (!canFind("};", s.first))
    {
        if (s.first == '\0')
        {
            break;
        }
        static if (subCmd)
        {
            if (s.first == ')')
            {
                s = s[1 .. $];
                break;
            }
        }
        static if (!subCmd)
        {
            if (s.first == ';' || s.first == '\n' || s.first == '\r')
            {
                break;
            }
        }
        call ~= s.parseWord;
        if (subCmd)
        {
            s.strips;
        }
        else
        {
            s.strip;
        }
    }
    Node ret;
    ret.type = Node.Type.CALL;
    ret.value.nodes = call;
    return ret;
}

Node[] parseBody(ref string s)
{
    Node[] ret;
    while (!canFind(")}", s.first))
    {
        if (s.first == '\0')
        {
            break;
        }
        Node cmdNode = s.parseCmd;
        if (cmdNode.value.nodes.length > 0)
        {
            ret ~= cmdNode;
        }
        s.strips;
    }
    if (s.first != '\0')
    {
        s = s[1 .. $];
    }
    return ret;
}
