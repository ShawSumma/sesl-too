import std.stdio;
import std.json;
import std.ascii;
import std.conv;
import std.uri;
import std.range;
import std.string;
import thing;
import parser;
import run;

alias Json = JSONValue;

class JsonState
{
    Value[] values;
    Node[] nodes;
}

Node jsonToNode(Json json, JsonState state)
{
    Node ret;
    ret.type = json.object["type"].str.toUpper.to!(Node.Type);
    final switch (ret.type)
    {
    case Node.Type.NONE:
        break;
    case Node.Type.POP:
        break;
    case Node.Type.POPV:
        break;
    case Node.Type.STRING:
        ret.value.str = json.object["string"].str.decode;
        break;
    case Node.Type.PUSH:
        ret.value.value = json.object["value"].jsonToValue(state);
        break;
    case Node.Type.LOAD:
        ret.value.str = json.object["load"].str.decode;
        break;
    case Node.Type.CALL:
        Node[] nodes;
        nodes ~= json.object["func"].jsonToNode(state);
        foreach (i; json.object["args"].array)
        {
            nodes ~= i.jsonToNode(state);
        }
        ret.value.nodes = nodes;
        break;
    case Node.Type.DOCALL:
        ret.value.unum = cast(ulong) json.object["argc"].integer;
        break;
    case Node.Type.ENTER:
        Value[string] tab;
        foreach (i; json.object["locals"].object.byKeyValue)
        {
            tab[i.key.decode] = i.value.jsonToValue(state);
        }
        ret.value.table = tab;
        break;
    case Node.Type.EXIT:
        break;
    }
    return ret;
}

Value jsonToValue(Json json, JsonState state)
{
    Value ret = new Value;
    state.values ~= ret;
    scope (exit)
    {
        state.values.popBack;
    }
    ret.type = json.object["type"].str.toUpper.to!(Value.Type);
    final switch (ret.type)
    {
    case Value.Type.NONE:
        break;
    case Value.Type.BOOL:
        ret.value.b = json.object["bool"].boolean;
        break;
    case Value.Type.STRING:
        ret.value.s = json.object["string"].str.decode;
        break;
    case Value.Type.LIST:
        Value[] lis;
        foreach (i; json.object["list"].array)
        {
            lis ~= i.jsonToValue(state);
        }
        ret.value.l = lis;
        break;
    case Value.Type.TABLE:
        Value[string] tab;
        foreach (i; json.object["table"].object.byKeyValue)
        {
            tab[i.key.decode] = i.value.jsonToValue(state);
        }
        ret.value.t = tab;
        break;
    case Value.Type.NODES:
        string[] args;
        Node[] nodes;
        foreach (i; json.object["args"].array)
        {
            args ~= i.str.decode;
        }
        foreach (i; json.object["nodes"].array)
        {
            nodes ~= i.jsonToNode(state);
        }
        ret.value.n.args = args;
        ret.value.n.nodes = nodes;
        break;
    case Value.Type.FUNC:
        ret.value.s = json.object["func"].str.decode;
        break;
    }
    return ret;
}

Json fromNode(Node node, JsonState state)
{
    state.nodes ~= node;
    scope (exit)
    {
        state.nodes.popBack;
    }
    Json[string] obj;
    Json ret = obj;
    ret.object["type"] = node.type.to!string.toLower;
    final switch (node.type)
    {
    case Node.Type.NONE:
        break;
    case Node.Type.POP:
        break;
    case Node.Type.POPV:
        break;
    case Node.Type.STRING:
        ret.object["string"] = node.value.str.encode;
        break;
    case Node.Type.PUSH:
        ret.object["value"] = node.value.value.fromValue(state);
        break;
    case Node.Type.LOAD:
        ret.object["load"] = node.value.str.encode;
        break;
    case Node.Type.CALL:
        Json[] call;
        foreach (i; node.value.nodes)
        {
            call ~= i.fromNode(state);
        }
        ret.object["func"] = call[0];
        ret.object["args"] = call[1 .. $];
        break;
    case Node.Type.DOCALL:
        ret.object["argc"] = node.value.unum;
        break;
    case Node.Type.ENTER:
        Json[string] nobj;
        Json jss = nobj;
        foreach (i; node.value.table.byKeyValue)
        {
            jss.object[i.key.encode] = i.value.fromValue(state);
        }
        ret.object["locals"] = jss;
        break;
    case Node.Type.EXIT:
        break;
    }
    return ret;
}

Json fromValue(Value val, JsonState state)
{
    state.values ~= val;
    scope (exit)
    {
        state.values.popBack;
    }
    Json[string] obj;
    Json ret = obj;
    ret.object["type"] = val.type.to!string.toLower;
    final switch (val.type)
    {
    case Value.Type.NONE:
        break;
    case Value.Type.BOOL:
        ret.object["bool"] = val.value.b;
        break;
    case Value.Type.STRING:
        ret.object["string"] = val.value.s.encode;
        break;
    case Value.Type.LIST:
        Json[] jss;
        foreach (i; val.value.l)
        {
            jss ~= i.fromValue(state);
        }
        ret.object["list"] = jss;
        break;
    case Value.Type.TABLE:
        Json[string] nobj;
        Json jss = nobj;
        foreach (i; val.value.t.byKeyValue)
        {
            jss.object[i.key.encode] = i.value.fromValue(state);
        }
        ret.object["table"] = jss;
        break;
    case Value.Type.NODES:
        Json[] args;
        foreach (i; val.value.n.args)
        {
            Json sj = i.encode;
            args ~= sj;
        }
        Json[] nodes;
        foreach (i; val.value.n.nodes)
        {
            nodes ~= i.fromNode(state);
        }
        ret.object["args"] = args;
        ret.object["nodes"] = nodes;
        break;
    case Value.Type.FUNC:
        ret.object["func"] = val.value.s.encode;
        break;
    }
    return ret;
}

Json makeWorldJson()
{
    Value[] slocals;
    foreach (i; locals)
    {
        slocals ~= new Value(i);
    }
    Json[] jslocals;
    foreach (i; slocals[1 .. $])
    {
        jslocals ~= i.fromValue(new JsonState);
    }
    Json[] jstodos;
    foreach (i; todo)
    {
        jstodos ~= i.fromNode(new JsonState);
    }
    Json[] jsstack;
    foreach (i; stack)
    {
        jsstack ~= i.fromValue(new JsonState);
    }
    Json[string] robj;
    Json ret = robj;
    ret.object["locals"] = jslocals;
    ret.object["todos"] = jstodos;
    ret.object["stack"] = jsstack;
    return ret;
}

string makeWorld()
{
    return makeWorldJson.to!string;
}

void loadWorld(string world)
{
    Json js = world.parseJSON;
    Value[] nstack;
    foreach (i; js.object["stack"].array)
    {
        nstack ~= i.jsonToValue(new JsonState);
    }
    Value[string][] nlocals;
    foreach (i; js.object["locals"].array)
    {
        nlocals ~= i.jsonToValue(new JsonState).value.t;
    }
    Node[] ntodo;
    foreach (i; js.object["todos"].array)
    {
        ntodo ~= i.jsonToNode(new JsonState);
    }
    stack = nstack;
    Value[string] locals0 = locals[0];
    locals.popBackN(locals.length-2);
    locals ~= nlocals;
    todo = ntodo;
}
