module lib.sesl;
import thing;

Value fnPass(Value[] args)
{
    if (args.length == 0)
    {
        return nil;
    }
    return args[$ - 1];
}
