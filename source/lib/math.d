module lib.math;
import std.conv;
import std.math;
import thing;

Value fnAdd(Args args)
{
    Number ret = 0;
    foreach (i; args)
    {
        ret += i.get!Number;
    }
    return makeThing(ret);
}

Value fnSub(Args args)
{
    Number ret = args[0].get!Number;
    if (args.length == 1)
    {
        return makeThing(0 - ret);
    }
    foreach (i; args[1 .. $])
    {
        ret -= i.get!Number;
    }
    return makeThing(ret);
}

Value fnMul(Args args)
{
    Number ret = 1;
    foreach (i; args)
    {
        ret *= i.get!Number;
    }
    return makeThing(ret);
}

Value fnDiv(Args args)
{
    Number ret = args[0].get!Number;
    if (args.length == 1)
    {
        return makeThing(1 / ret);
    }
    foreach (i; args[1 .. $])
    {
        ret /= i.get!Number;
    }
    return makeThing(ret);
}

Value fnMod(Args args)
{
    Number ret = args[0].get!Number;
    foreach (i; args[1 .. $])
    {
        ret %= i.get!Number;
    }
    return makeThing(ret);
}