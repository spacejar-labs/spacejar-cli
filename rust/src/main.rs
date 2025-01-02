use clap::{Parser, Subcommand};
use spacejar_config::*;
use std::process;
use anyhow::Result;

#[derive(Parser, Debug)]
#[command(
    name = "spacejar",
    version,
    author = "Spacejar engineers engineers@spacejar.io",
    about = "Run your code from your local setup on our cloud with one command",
    long_about = "Train, fine-tune, and deploy ML models from your local environment on our powerful machines. No setup, no new framework to learn, no code changes."
)]
struct Cli {
    #[command(subcommand)]
    command: Commands,
}

#[derive(Subcommand, Debug)]
enum Commands {
    Run {
        #[arg(allow_hyphen_values(true), num_args(1..), value_name("COMMAND"))]
        args: Vec<String>,
    }
}

fn run(cli: &Cli) -> Result<()> {
    match &cli.command {
        Commands::Run { args } => {
            if args.is_empty() {
                anyhow::bail!("You must specify a command to run. i.e. spacejar run python my_script.py --my-params");
            }

            // Check if config file exists
            let current_dir = get_current_dir()?;
            if !config_file_exists(&current_dir) {
                println!("Creating a new config file in {}", current_dir.display());
                create_default_config(&current_dir)?;
                println!("Config file created successfully");
            }
            println!("Running command: {:?}", args);
            Ok(())
        }
    }
}

fn main() {
    let cli = Cli::parse();
    if let Err(e) = run(&cli) {
        eprintln!("Error: {}", e);
        process::exit(1);
    }
}
