module lib.io;
import std.stdio;
import core.stdc.stdlib;
import std.file;
import std.conv;
import thing;

Value fnPrint(Value[] args)
{
    foreach (i, v; args)
    {
        if (i != 0)
        {
            write(" ");
        }
        write(v);
    }
    writeln;
    return nil;
}

Value fnWrite(Value[] args)
{
    foreach (i, v; args)
    {
        if (i != 0)
        {
            write(" ");
        }
        write(v);
    }
    return nil;
}

Value fnReadFrom(Value[] args)
{
    return makeThing(cast(string) read(args[0].get!string));
}

Value fnSaveTo(Value[] args)
{
    File fout = File(args[0].get!string, "w");
    fout.write(args[1].to!string);
    return nil;
}

Value fnCat(Value[] args)
{
    string ret;
    foreach (i; args)
    {
        ret ~= i.to!string;
    }
    return makeThing(ret);
}
