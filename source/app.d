import std.stdio;
import std.file;
import parser;
import thing;
import serial;
import run;
import atext;

void main(string[] rawArgs) {
    string[] args;
    bool[string] things = [
        "repl": false,
    ];
    string file;
    foreach (arg; rawArgs[1..$]) {
        if (arg[0] == '-') {
            if (arg[1] == '-') {
                if (arg[2..6] == "repl") {
                    things["repl"] = true;
                }
                if (arg[2..7] == "file=") {
                    file = arg[7..$];
                }
            }
            else {
                things[arg[1..$]] = false;
            }
        }
        else if (arg[1] == '+') {
            things[arg[1..$]] = true;
        }
        else {
            args ~= arg;
        }
    }
    foreach (arg; args) {
        string code = cast(string) read(arg);
        Node[] nodes = code.parseBody;
        foreach_reverse (node; nodes) {
            Node n;
            n.type = Node.Type.POP;
            runNode(n);
            runNode(node);
        }
        run.run;
    }
    bool testRepl = true;
    if (file && file.exists) {
        loadWorld(cast(string) file.read);
        if (stack.length > 0) {
            testRepl = false;
            stack ~= new Value;
            run.run;
        }
    }
    if (testRepl && (args.length == 0 || things["repl"])) {
        char[][] history = null;
        Reader reader = new Reader(history);
        while(true) {
            try {
                string line = reader.readln(">>> ");
                Node[] nodes = line.parseBody;
                foreach_reverse (node; nodes) {
                    runNode(node);
                }
                run.run;
                foreach (i; stack) {
                    writeln(i);
                }
                stack = null;
            }
            catch (ExitException ex) {
                if (ex.letter == 'c') {
                    continue;
                }
                return;
            }
            if (file) {
                File fout = File(file, "w");
                fout.write(makeWorld);
            }
        }
    }
}
