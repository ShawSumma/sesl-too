module lib.meta;
import std.conv;
import thing;
import run;
import serial;
import std.bigint;

Value fnExec(Args args)
{
    loadWorld(args[0].get!string);
    return nil;
}

Value fnMakeWorld(Args _)
{
    return makeThing(makeWorld);
}

Value fnToJson(Args args)
{
    return makeThing(args[0].fromValue(new JsonState).to!string);
}
