use lexopt::{prelude::*, Parser};
use std::path::PathBuf;

struct Args {
    session: Option<String>,
    cwd: Option<PathBuf>,
}

fn parse_args(mut parser: Parser) -> Result<Args, lexopt::Error> {
    let mut temp = Args { cwd: None, session: None };
    while let Some(arg) = parser.next()? {
        match arg {
            Value(_) => {}
            Short('c') | Long("cwd") => {
                let cwd: String = parser.value()?.parse()?;
                temp.cwd = Option::Some(PathBuf::from(cwd));
            }
            Short('s') | Long("session") => {
                let session: String = parser.value()?.parse()?;
                temp.session = Option::Some(session);
            }
            _ => {}
        }
    }
    Ok(temp)
}

fn main() {
    let args = vec!["--session", "my session", "--cwd", "/tmp/foo bar"];
    let parser = lexopt::Parser::from_args(args);
    let parsed = parse_args(parser).unwrap();
    println!("{:?} {:?}", parsed.session, parsed.cwd);
}
