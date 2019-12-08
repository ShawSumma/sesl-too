module lib.string;
import std.string;
import thing;

Value fnStrip(Value[] args) {
    return makeThing(std.string.strip(args[0].get!string));
}