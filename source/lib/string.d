module lib.string;
import std.string;
import thing;

Value fnStrip(Args args) {
    return makeThing(std.string.strip(args[0].get!string));
}