module lib.sesl;
import std.conv;
import thing;
import build;

Value fnPass(Args args)
{
    if (args.length == 0)
    {
        return nil;
    }
    return args[$ - 1];
}
