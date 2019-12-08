module lib.vector;
import std.conv;
import thing;

Value fnVectorNew(Args args)
{
    return makeThing(args.values[0..args.length].dup);
}

Value fnVectorSet(Args args)
{
    Value ret = args[2];
    args[0].get!(Value[])[args[1].get!Number.to!size_t] = ret;
    return args[0];
}

Value fnVectorIndex(Args args)
{
    Value ret = args[0];
    foreach (i; args[1 .. $])
    {
        ret = ret.get!(Value[])[i.get!Number.to!size_t];
    }
    return ret;
}
