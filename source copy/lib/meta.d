module lib.meta;
import std.conv;
import thing;
import run;
import serial;
import std.bigint;

Value fnExec(Value[] args)
{
    loadWorld(args[0].get!string);
    return nil;
}

Value fnMakeWorld(Value[] _)
{
    return makeThing(makeWorld);
}

Value fnToJson(Value[] args)
{
    return makeThing(args[0].fromValue(new JsonState).to!string);
}
