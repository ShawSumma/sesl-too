module lib.funcs;
import std.stdio;
import core.stdc.stdlib;
import thing;
import lib.cmp;
import lib.flow;
import lib.io;
import lib.math;
import lib.meta;
import lib.sesl;
import lib.state;
import lib.string;
import lib.sys;
import lib.table;
import lib.vector;

Value function(Args) byName(string name)
{
    switch (name)
    {
    case "if":
        return &fnIf;
    // case "intern:if":
    //     return &internIf;
    case "while":
        return &fnWhile;
    case "while:iftrue":
        return &helpWhileByIfTrue;
    case "pass":
        return &fnPass;
    case "lambda":
        return &fnLambda;
    case "print":
        return &fnPrint;
    case "write":
        return &fnWrite;
    case "to-json":
        return &fnToJson;
    case "make-world":
        return &fnMakeWorld;
    case "system":
        return &fnSystem;
    case "exec":
        return &fnExec;
    case "save-to":
        return &fnSaveTo;
    case "read-from":
        return &fnReadFrom;
    case "table":
        return &fnTableNew;
    case "table-index":
        return &fnTableIndex;
    case "table-set":
        return &fnTableSet;
    case "list":
        return &fnVectorNew;
    case "list-index":
        return &fnVectorIndex;
    case "list-set":
        return &fnVectorSet;
    case "strip":
        return &fnStrip;
    case "cat":
        return &fnCat;
    case "+":
        return &fnAdd;
    case "-":
        return &fnSub;
    case "*":
        return &fnMul;
    case "/":
        return &fnDiv;
    case "%":
        return &fnMod;
    case "=":
        return &fnEq;
    case "!=":
        return &fnNeq;
    case "<":
        return &fnLt;
    case ">":
        return &fnGt;
    case "<=":
        return &fnLte;
    case ">=":
        return &fnGte;
    case "set":
        return &fnSet;
    case "proc":
        return &fnProc;
    default:
        writeln("no name " ~ name);
        exit(1);
    }
    assert(0);
}
