module build;
import parser;
import run;
import thing;

Node popNode()
{
    Node ret;
    ret.type = Node.Type.POP;
    return ret;
}

void runPopNode()
{
    popNode.runNode;
}

Node pushNode(Value value)
{
    Node ret;
    ret.type = Node.Type.PUSH;
    ret.value.value = value;
    return ret;
}

void runPushNode(Value value)
{
    pushNode(value).runNode;
}

Node docallNode(ulong unum)
{
    Node ret;
    ret.type = Node.Type.DOCALL;
    ret.value.unum = unum;
    return ret;
}

void runDocallNode(ulong unum) {
    docallNode(unum).runNode;
}