module lib.state;
import std.stdio;
import std.conv;
import std.range;
import intern;
import thing;
import run;

Value fnProc(Value[] args)
{
    Value ret = args[$ - 1];
    foreach (i; args[1 .. $ - 1])
    {
        ret.get!Proc.args ~= i.get!Intern;
    }
    locals[locals.length - 1][args[0].get!Intern] = ret;
    return ret;
}

Value fnSet(Value[] args)
{
    if (args.length == 1)
    {
        locals[locals.length - 1][args[0].get!Intern] = nil;
        return nil;
    }
    Value target = args[1];
    switch (args[0].type)
    {
    case Value.Type.STRING:
        locals[locals.length - 1][args[0].get!Intern] = target;
        break;
    case Value.Type.INTERN:
        locals[locals.length - 1][args[0].get!Intern] = target;
        break;
    case Value.Type.NUMBER:
        locals[locals.length - 1][Intern(args[0].get!double.to!string)] = target;
        break;
    case Value.Type.LIST:
        Value[] tl = target.get!(Value[]);
        foreach (i, v; args[0].get!(Value[]))
        {
            fnSet([v, tl[i]]);
        }
        break;
    case Value.Type.TABLE:
        Value[string] tt = target.get!(Value[string]);
        foreach (kv; args[0].get!(Value[string]).byKeyValue)
        {
            fnSet([makeThing(kv.key), tt[kv.key]]);
        }
        break;
    default:
        throw new Exception("cannot set " ~ args[0].to!string);
    }
    return target;
}