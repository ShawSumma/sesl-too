module lib.io;
import std.stdio;
import core.stdc.stdlib;
import std.file;
import std.conv;
import thing;

Value fnPrint(Args args)
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

Value fnWrite(Args args)
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

Value fnReadFrom(Args args)
{
    return makeThing(cast(string) read(args[0].get!string));
}

Value fnSaveTo(Args args)
{
    File fout = File(args[0].get!string, "w");
    fout.write(args[1].to!string);
    return nil;
}
