module lib.sys;
import std.process;
import thing;

Value fnSystem(Args args)
{
    string[] cmd;
    foreach (i; args)
    {
        cmd ~= i.get!string;
    }
    return makeThing(execute(cmd).output);
}
