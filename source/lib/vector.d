module lib.vector;
import std.conv;
import thing;
import vector;

Value fnVectorNew(Args args)
{
    Vector!Value vals;
    foreach (i; args) {
        vals ~= i;
    }
    return makeThing(vals);
}

Value fnVectorSet(Args args)
{
    Value ret = args[2];
    args[0].get!(Vector!Value)[args[1].get!Number.to!size_t] = ret;
    return args[0];
}

Value fnVectorIndex(Args args)
{
    Value ret = args[0];
    foreach (i; args[1 .. $])
    {
        ret = ret.get!(Vector!Value)[i.get!Number.to!size_t];
    }
    return ret;
}
