use clap::{Parser, Command};
use spacejar::*;
use std::{env, process};
use config::*;

#[derive(Parser, Debug)]
#[command(author, version, about, long_about = None)]
struct CliArgs {
      #[arg(short, long)]
      logo: bool,

      #[arg(
            short,
            long,
            num_args(0..),
            allow_hyphen_values(true),
            required(true),
            value_name("COMMAND"),
            help = "The command to run, i.e. spacejar --run python my_script.py --my-params",
      )]
      run: Vec<String>,
}

fn main() {
      let args = CliArgs::parse();

      match args.logo {
            true => spacejar::print_logo(),
            false => (),
      }

      if args.run.is_empty() {
            eprintln!("You must specify a command to run. i.e. spacejar --run python my_script.py --my-params");
            process::exit(1);
      }

      // Check if there is a file in the current directory a spacejar_config.yml
      let current_dir = get_current_dir();
      if !config_file_exists(&current_dir) {
            println!("Creating a new config file in {}", current_dir.display());
            match create_default_config() {
                  Ok(_) => println!("Config file created successfully"),
                  Err(e) => {
                        eprintln!("Error creating config file: {}", e);
                        process::exit(1);
                  }
            }
      }
}
