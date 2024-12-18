pub mod config;
use std::{env, fs::File, path::PathBuf, process};
use std::io::Write;

pub fn print_logo() {
    println!(r#"

    ____                        _                      _ _ 
   / ___| _ __   __ _  ___ ___ (_) __ _ _ __       ___| (_)
   \___ \| '_ \ / _` |/ __/ _ \| |/ _` | '__|____ / __| | |
    ___) | |_) | (_| | (_|  __/| | (_| | | |_____| (__| | |
   |____/| .__/ \__,_|\___\___|/ |\__,_|_|        \___|_|_|
         |_|                 |__/                          
   
   "#);
}

pub fn get_os() -> String {
    let os = std::env::consts::OS;
    os.to_string()
}
