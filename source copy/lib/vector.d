module lib.vector;
import std.conv;
import thing;

Value fnVectorNew(Value[] args)
{
    return makeThing(args.dup);
}

Value fnVectorSet(Value[] args)
{
    Value ret = args[2];
    args[0].get!(Value[])[args[1].get!Number.to!size_t] = ret;
    return args[0];
}

Value fnVectorIndex(Value[] args)
{
    Value ret = args[0];
    foreach (i; args[1 .. $])
    {
        ret = ret.get!(Value[])[i.get!Number.to!size_t];
    }
    return ret;
}
