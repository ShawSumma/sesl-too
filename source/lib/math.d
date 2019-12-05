module lib.math;
import thing;
import std.conv;

Value fnAdd(Value[] args)
{
    double ret = 0;
    foreach (i; args)
    {
        ret += to!double(i.get!string);
    }
    return makeThing(to!string(ret));
}

Value fnSub(Value[] args)
{
    double ret = to!double(args[0].get!string);
    if (args.length == 1)
    {
        return makeThing(to!string(0 - ret));
    }
    foreach (i; args[1 .. $])
    {
        ret -= to!double(i.get!string);
    }
    return makeThing(to!string(ret));
}

Value fnMul(Value[] args)
{
    double ret = 1;
    foreach (i; args)
    {
        ret *= to!double(i.get!string);
    }
    return makeThing(to!string(ret));
}

Value fnDiv(Value[] args)
{
    double ret = to!double(args[0].get!string);
    if (args.length == 1)
    {
        return makeThing(to!string(1 / ret));
    }
    foreach (i; args[1 .. $])
    {
        ret /= to!double(i.get!string);
    }
    return makeThing(to!string(ret));
}
