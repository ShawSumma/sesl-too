module lib.string;
import std.conv;
import std.string;
import thing;

Value fnStrip(Args args) {
    return makeThing(std.string.strip(args[0].get!string));
}

Value fnCat(Args args)
{
    string ret;
    foreach (i; args)
    {
        ret ~= i.to!string;
    }
    return makeThing(ret);
}