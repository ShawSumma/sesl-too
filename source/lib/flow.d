module lib.flow;
import std.stdio;
import std.functional;
import thing;
import parser;
import run;
import build;

// Value fnIf(Args args)
// {
//     return args.at(0).call.iftrue(args.at(1), args.at(2)).ret;
// }

Value fnIf(Args args)
{
    if (args[0].isTrue)
    {
        callNodes!false(args[1].get!Proc, noargs);
    }
    else if (args.length == 3)
    {
        callNodes!false(args[2].get!Proc, noargs);
    }
    else
    {
        runPushNode(nil);
    }
    runPopNode;
    return nil;
}

Value helpWhileByIfTrue(Args args)
{
    if (!args[0].isTrue)
    {
        return nil;
    }
    runDocallNode(3);
    runPushNode(args[2]);
    runPushNode(args[1]);
    callNodes!false(args[1].get!Proc, noargs);
    dFunc("while:iftrue").runPushNode;
    runPopNode;
    callNodes!false(args[2].get!Proc, noargs);
    runPopNode;
    return nil;
}

Value fnWhile(Args args)
{
    runDocallNode(3);
    runPushNode(args[1]);
    runPushNode(args[0]);
    callNodes!false(args[0].get!Proc, noargs);
    return dFunc("while:iftrue");
}
