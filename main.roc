app "some"
    packages {
        pf: "https://github.com/roc-lang/basic-cli/releases/download/0.9.1/y_Ww7a2_ZGjp0ZTt9Y_pNdSqqMRdMLzHMKfdN8LWidk.tar.br",
        weaver: "https://github.com/smores56/weaver/releases/download/0.1.0/MnJi0GTNzOI77qDnH99iuBNsM5ZKnc-gZTLFj7sIdqo.tar.br",
    }
    imports [
        pf.Stdout,
        pf.Stdin,
        pf.Arg,
        pf.Task.{ Task },
        weaver.Cli,
        weaver.Opt,
    ]
    provides [main] to pf

Args : { lineCount: I64 }

cliParser : Cli.CliParser Args
cliParser =
    Cli.weave {
        lineCount: <- Opt.num { short: "n", help: "The number of lines to display" },
    }
    |> Cli.finish {
        name: "some",
        version: "v0.0.1",
        authors: ["Jackson Wambolt <jackson@wambolt.me>"],
        description: "a cool little tool",
    }
    |> Cli.assertValid

## Entry point
main =
    # get cli args
    args <- Arg.list |> Task.await


    when Cli.parseOrDisplayMessage cliParser args is
        Ok data -> run data
        Err message -> Stdout.line message

run : Args -> Task {} a
run = \{ lineCount } ->
    Task.loop {} \_ ->
        input <- Stdin.line |> Task.await
        when input is
            # no more stdin
            End -> Done {} |> Task.ok
            # we got another line
            Input line ->
                Stdout.line line |> Task.map Step

