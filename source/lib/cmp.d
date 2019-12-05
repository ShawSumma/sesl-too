module lib.cmp;
import thing;

Value fnEq(Value[] args)
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

Value fnNeq(Value[] args)
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

Value fnLt(Value[] args)
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

Value fnGt(Value[] args)
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

Value fnLte(Value[] args)
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

Value fnGte(Value[] args)
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