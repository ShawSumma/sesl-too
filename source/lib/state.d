module lib.state;
import std.stdio;
import std.conv;
import std.range;
import intern;
import thing;
import run;
import vector;

Value fnProc(Args args)
{
    Value ret = args[$ - 1];
    foreach (i; args[1 .. $ - 1])
    {
        ret.get!Proc.args ~= i.get!Intern;
    }
    locals[$ - 1][args[0].get!Intern] = ret;
    return ret;
}

Value fnSet(Args args)
{
    if (args.length == 1)
    {
        locals[$ - 1][args[0].get!Intern] = nil;
        return nil;
    }
    Value target = args[1];
    switch (args[0].type)
    {
    case Value.Type.STRING:
        locals[$ - 1][args[0].get!Intern] = target;
        break;
    case Value.Type.INTERN:
        locals[$ - 1][args[0].get!Intern] = target;
        break;
    case Value.Type.NUMBER:
        locals[$ - 1][Intern(args[0].get!double
                    .to!string)] = target;
        break;
    case Value.Type.LIST:
        Vector!Value tl = target.get!(Vector!Value);
        foreach (i, v; args[0].get!(Vector!Value))
        {
            fnSet(Args(v, tl[i]));
        }
        break;
    case Value.Type.TABLE:
        Value[string] tt = target.get!(Value[string]);
        foreach (kv; args[0].get!(Value[string]).byKeyValue)
        {
            fnSet(Args(makeThing(kv.key), tt[kv.key]));
        }
        break;
    default:
        throw new Exception("cannot set " ~ args[0].to!string);
    }
    return target;
}
