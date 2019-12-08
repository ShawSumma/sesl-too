module lib.math;
import thing;
import std.conv;

Value fnAdd(Value[] args)
{
    Number ret = 0;
    foreach (i; args)
    {
        ret += i.get!Number;
    }
    return makeThing(ret);
}

Value fnSub(Value[] args)
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

Value fnMul(Value[] args)
{
    Number ret = 1;
    foreach (i; args)
    {
        ret *= i.get!Number;
    }
    return makeThing(ret);
}

Value fnDiv(Value[] args)
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

Value fnMod(Value[] args)
{
    Number ret = args[0].get!Number;
    foreach (i; args[1 .. $])
    {
        ret %= i.get!Number;
    }
    return makeThing(ret);
}

// Value fnRemander(Value[] args)
// {
//     Number ret = args[0].get!Number;
//     foreach (i; args[1 .. $])
//     {
//         ret = 
//     }
//     return makeThing(ret;)
// }
