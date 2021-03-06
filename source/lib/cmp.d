module lib.cmp;
import thing;

Value fnEq(Args args)
{
    foreach (i, x; args[0 .. $ - 1])
    {
        foreach (j, y; args[i + 1 .. $])
        {
            if (x != y)
            {
                return makeThing(false);
            }
        }
    }
    return makeThing(true);
}

Value fnNeq(Args args)
{
    foreach (i, x; args[0 .. $ - 1])
    {
        foreach (j, y; args[i + 1 .. $])
        {
            if (x == y)
            {
                return makeThing(false);
            }
        }
    }
    return makeThing(true);
}

Value fnLt(Args args)
{
    Value last = args[0];
    foreach (i; args[1 .. $])
    {
        if (!(last < i))
        {
            return makeThing(false);
        }
        last = i;
    }
    return makeThing(true);
}

Value fnGt(Args args)
{
    Value last = args[0];
    foreach (i; args[1 .. $])
    {
        if (!(last > i))
        {
            return makeThing(false);
        }
        last = i;
    }
    return makeThing(true);
}

Value fnLte(Args args)
{
    Value last = args[0];
    foreach (i; args[1 .. $])
    {
        if (!(last <= i))
        {
            return makeThing(false);
        }
        last = i;
    }
    return makeThing(true);
}

Value fnGte(Args args)
{
    Value last = args[0];
    foreach (i; args[1 .. $])
    {
        if (!(last >= i))
        {
            return makeThing(false);
        }
        last = i;
    }
    return makeThing(true);
}