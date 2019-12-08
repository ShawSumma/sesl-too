module intern;
import std.stdio;
import std.conv;
import thing;
import run;

version = Interning;

alias InternUInt = size_t;

version (Interning)
{
    private size_t[string] interns;
    private string[] strings;
    struct Intern
    {
        InternUInt rep;
        this(string s)
        {
            size_t ol = interns.length;
            rep = interns.require(s, ol);
            if (rep >= strings.length)
            {
                strings ~= s;
            }
            else
            {
                strings[rep] = s;
            }
        }

        this(Intern o)
        {
            rep = o.rep;
        }

        ref string val()
        {
            return strings[rep];
        }

        size_t toHash() nothrow const
        {
            return rep.hashOf;
        }

        bool opEquals(Intern other) nothrow const @nogc
        {
            return rep == other.rep;
        }

        string toString()
        {
            return "(" ~ rep.to!string ~ ": " ~ val ~ ")";
        }
    }
}
else
{
    struct Intern
    {
        string val;
        this(string s)
        {
            val = s;
        }

        @property ulong rep()
        {
            return 0;
        }
    }
}
