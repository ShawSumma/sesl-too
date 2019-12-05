module lib.state;
import thing;
import run;

Value fnProc(Value[] args)
{
    Value ret = args[$ - 1];
    foreach (i; args[1 .. $ - 1])
    {
        ret.get!Proc.args ~= i.get!string;
    }
    locals[$ - 1][args[0].get!string] = ret;
    return ret;
}

Value fnSet(Value[] args)
{
    if (args.length == 1)
    {
        locals[$ - 1][args[0].get!string] = nil;
        return nil;
    }
    else
    {
        locals[$ - 1][args[0].get!string] = args[1];
        return args[1];
    }
}

Value fnMut(Value[] args)
{
    Value val = args[1];
    string key = args[0].get!string;
    Value* tops = key in locals[$ - 1];
    if (tops)
    {
        *tops = val;
        return val;
    }
    tops = key in locals[1];
    if (tops)
    {
        *tops = val;
        return val;
    }
    foreach_reverse (i; locals[1 .. $ - 1])
    {
        tops = key in i;
        if (tops)
        {
            *tops = val;
            return val;
        }
    }
    locals[$ - 1][key] = val;
    return val;
}