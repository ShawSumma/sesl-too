module lib.flow;
import std.stdio;
import thing;
import parser;
import run;
import build;

Value fnIf(Value[] args)
{
    if (args[0].isTrue)
    {
        callNodes!false(args[1].get!Proc, null);
    }
    else if (args.length == 3)
    {
        callNodes!false(args[2].get!Proc, null);
    }
    else
    {
        runPushNode(nil);
    }
    runPopNode;
    return nil;
}

Value helpWhileByIfTrue(Value[] args)
{
    if (!args[0].isTrue)
    {
        return nil;
    }
    runDocallNode(3);
    runPushNode(args[2]);
    runPushNode(args[1]);
    callNodes!false(args[1].get!Proc, null);
    runPushNode(dFunc("while:iftrue"));
    runPopNode;
    callNodes!false(args[2].get!Proc, null);
    runPopNode;
    return nil;
}

Value fnWhile(Value[] args)
{
    runDocallNode(3);
    runPushNode(args[1]);
    runPushNode(args[0]);
    callNodes!false(args[0].get!Proc, null);
    return dFunc("while:iftrue");
}
