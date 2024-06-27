use clap::Parser;
use std::io;
use std::process::Command;
use std::process::Stdio;

fn main() {
    let args = CommandLineArgs::parse();
    let command: String = format!("cat {}", args.path);

    let process = match Command::new(command).stdin(Stdio::piped()).spawn() {
        Err(e) => panic!("failed to spawn cat command: {}", e),
        Ok(process) => process,
    };
}

#[derive(Debug, Parser)]
struct CommandLineArgs {
    path: String,
}
