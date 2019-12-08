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
import intern;

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
        ret.value.unum = json.object["argc"].integer.to!size_t;
        break;
    case Node.Type.ENTER:
        Value[Intern] tab;
        foreach (i; json.object["locals"].object.byKeyValue)
        {
            tab[Intern(i.key.decode)] = i.value.jsonToValue(state);
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

    if (json.object["type"].str == "up")
    {
        return state.values[$ - cast(size_t) json.object["up"].integer];
    }
    Value ret = nil;
    state.values ~= ret;
    scope (exit)
    {
        state.values.length--;
    }
    ret.type = json.object["type"].str.toUpper.to!(Value.Type);
    final switch (ret.type)
    {
    case Value.Type.NONE:
        break;
    case Value.Type.BOOL:
        ret.value.b = json.object["bool"].boolean;
        break;
    case Value.Type.NUMBER:
        ret.value.d = json.object["number"].str.decode.to!Number;
        break;
    case Value.Type.STRING:
        ret.value.s = json.object["string"].str.decode;
        break;
    case Value.Type.INTERN:
        string sv = json.object["string"].str.decode;
        ret.value.i = Intern(sv);
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
        Intern[] args;
        Node[] nodes;
        foreach (i; json.object["args"].array)
        {
            args ~= Intern(i.str.decode);
        }
        foreach (i; json.object["nodes"].array)
        {
            nodes ~= i.jsonToNode(state);
        }
        ret.get!Proc.args = args;
        ret.get!Proc.nodes = nodes;
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
        state.nodes.length--;
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
            jss.object[i.key.val.encode] = i.value.fromValue(state);
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
    foreach_reverse (i, v; state.values)
    {
        if (val is v)
        {
            return Json(["type": Json("up"), "up": Json(state.values.length - i)]);
        }
    }
    state.values ~= val;
    scope (exit)
    {
        state.values.length--;
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
    case Value.Type.NUMBER:
        ret.object["number"] = val.get!Number.to!string.encode;
        break;
    case Value.Type.STRING:
        ret.object["string"] = val.get!string.encode;
        break;
    case Value.Type.INTERN:
        ret.object["string"] = val.get!Intern.rep;
        break;
    case Value.Type.LIST:
        Json[] jss;
        foreach (i; val.get!(Value[]))
        {
            jss ~= i.fromValue(state);
        }
        ret.object["list"] = jss;
        break;
    case Value.Type.TABLE:
        Json[string] nobj;
        Json jss = nobj;
        foreach (i; val.get!(Value[string]).byKeyValue)
        {
            jss.object[i.key.encode] = i.value.fromValue(state);
        }
        ret.object["table"] = jss;
        break;
    case Value.Type.NODES:
        Json[] args;
        foreach (i; val.get!Proc.args)
        {
            Json sj = i.val.encode;
            args ~= sj;
        }
        Json[] nodes;
        foreach (i; val.get!Proc.nodes)
        {
            nodes ~= i.fromNode(state);
        }
        ret.object["args"] = args;
        ret.object["nodes"] = nodes;
        break;
    case Value.Type.FUNC:
        ret.object["func"] = val.get!string.encode;
        break;
    }
    return ret;
}

Json makeWorldJson()
{
    Value[] slocals;
    foreach (i; locals)
    {
        Value[string] locs;
        foreach (kv; i.byKeyValue) {
            locs[kv.key.val] = kv.value;
        }
        slocals ~= makeThing(locs);
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
    stack = null;
    foreach (i; js.object["stack"].array)
    {
        stack ~= i.jsonToValue(new JsonState);
    }
    Value[Intern][] nlocals;
    foreach (i; js.object["locals"].array)
    {
        Value[string] got = i.jsonToValue(new JsonState).get!(Value[string]);
        Value[Intern] fin;
        foreach (kv; got.byKeyValue) {
            fin[Intern(kv.key)] = kv.value;
        }
        nlocals ~= fin;
    }
    todo = null;
    foreach (i; js.object["todos"].array)
    {
        todo ~= i.jsonToNode(new JsonState);
    }
    locals.length = 1;
    foreach (i; nlocals) {
        locals ~= i;
    }
}
