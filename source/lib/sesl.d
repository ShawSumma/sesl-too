module lib.sesl;
import thing;

Value fnPass(Args args)
{
    if (args.length == 0)
    {
        return nil;
    }
    return args[$ - 1];
}
