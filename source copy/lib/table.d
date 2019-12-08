module lib.table;
import std.conv;
import thing;

Value fnTableSet(Value[] args)
{
    Value ret = args[2];
    args[0].get!(Value[string])[ret.get!string] = ret;
    return args[0];
}

Value fnTableIndex(Value[] args)
{
    Value ret = args[0];
    foreach (i; args[1 .. $])
    {
        ret = ret.get!(Value[string])[i.get!string];
    }
    return ret;
}

Value fnTableNew(Value[] args)
{
    Value[string] ret;
    for (size_t i = 0; i < args.length; i += 2)
    {
        ret[args[i].get!string] = args[i + 1];
    }
    return makeThing(ret);
}