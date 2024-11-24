use serde::{Serialize, Deserialize};
use std::fs;
use std::path::PathBuf;
use std::env;
use std::process;
use std::fs::File;

#[derive(Serialize, Deserialize, Debug)]
pub struct Hardware {
    pub parallelism: Parallelism,
    pub cpu: Cpu,
    pub gpu: Gpu,
    pub memory: Memory,
    pub storage: Storage,
    pub os: Os,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Parallelism {
    pub min: u32,
    pub recommended: u32,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Cpu {
    pub min_cores: u32,
    pub min_speed: f32,
    pub recommended_cores: u32,
    pub recommended_speed: f32,
    pub architecture: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Gpu {
    pub required: bool,
    pub min_vram: u32,
    pub recommended_vram: u32,
    pub cuda_cores: u32,
    pub min_compute_capability: f32,
    pub recommended_compute_capability: f32,
    pub recommended_gpu: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Memory {
    pub min_ram: u32,
    pub min_swap: u32,
    pub recommended_swap: u32,
    pub ram_type: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Storage {
    pub min_space: u32,
    pub recommended_space: u32,
    pub r#type: String,
    pub min_iops: u32,
    pub recommended_iops: u32,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct Os {
    pub base_image: String,
    pub label: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct DataSource {
    pub name: String,
    pub r#type: String,
    pub url: String,
    pub format: String,
    pub access: DataAccess,
    pub read_options: Option<ReadOptions>,
    pub write_options: Option<WriteOptions>,
    pub schema: Option<Vec<SchemaField>>,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct DataAccess {
    pub aws_access_key: String,
    pub aws_secret_key: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ReadOptions {
    pub delimeter: String,
    pub header: bool,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct WriteOptions {
    pub delimeter: String,
    pub header: bool,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct SchemaField {
    pub name: String,
    pub r#type: String,
}

#[derive(Serialize, Deserialize, Debug)]
pub struct ConfigManifest {
    pub name: String,
    pub version: String,
    pub description: String,
    pub author: String,
    pub license: String,
    pub tags: Vec<String>,
    // pub code_repository: Vec<Repository>,
    pub hardware: Hardware,
    pub data: Vec<DataSource>,
    // pub training: Training,
    // pub inference: Inference,
    // pub vscode: Vscode,
}

impl ConfigManifest {
    pub fn new_default() -> Self {
        ConfigManifest {
            name: String::from("Default SpaceJar Project"),
            version: String::from("0.1.0"),
            description: String::from("A default SpaceJar project"),
            author: String::from("SpaceJar User"),
            license: String::from("Apache License 2.0"),
            tags: vec![String::from("Machine Learning"), String::from("AI")],
            hardware: Hardware {
                parallelism: Parallelism {
                    min: 1,
                    recommended: 1,
                },
                cpu: Cpu {
                    min_cores: 2,
                    min_speed: 2.0,
                    recommended_cores: 8,
                    recommended_speed: 3.0,
                    architecture: String::from("x86_64"),
                },
                gpu: Gpu {
                    required: false,
                    min_vram: 4,
                    recommended_vram: 24,
                    cuda_cores: 1000,
                    min_compute_capability: 3.5,
                    recommended_compute_capability: 6.0,
                    recommended_gpu: String::from("NVIDIA RTX 3090"),
                },
                memory: Memory {
                    min_ram: 16,
                    min_swap: 4,
                    recommended_swap: 16,
                    ram_type: String::from("DDR4"),
                },
                storage: Storage {
                    min_space: 100,
                    recommended_space: 1000,
                    r#type: String::from("SSD"),
                    min_iops: 1000,
                    recommended_iops: 10000,
                },
                os: Os {
                    base_image: String::from("ubuntu:20.04"),
                    label: String::from("ubuntu 20.04"),
                },
            },
            data: vec![],
        }
    }

    pub fn save_to_file(&self, path: &PathBuf) -> Result<(), Box<dyn std::error::Error>> {
        let yaml = serde_yaml::to_string(&self)?;
        fs::write(path, yaml)?;

        Ok(())
    }
}

pub fn config_file_exists(current_dir: &PathBuf) -> bool {
    current_dir.join("spacejar_config.yml").exists()
}

pub fn get_current_dir() -> PathBuf {
    match env::current_dir() {
        Ok(dir) => dir,
        Err(e) => process::exit(1),
    }
}

pub fn create_default_config() -> Result<(), Box<dyn std::error::Error>> {
    let current_dir = std::env::current_dir()?;
    let config_file = current_dir.join("spacejar_config.yml");

    let config = ConfigManifest::new_default();

    config.save_to_file(&config_file)?;

    Ok(())
}

