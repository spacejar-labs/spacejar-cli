from setuptools import setup, find_packages
from setuptools.command.install import install
import os
import sys
import platform
from pathlib import Path
import requests
import logging
import site
import tarfile
import tempfile
import shutil
import zipfile

logging.basicConfig(level=logging.INFO, format='%(message)s')
logger = logging.getLogger('spacejar-installer')

class PostInstallCommand(install):
    def run(self):
        install.run(self)
        self.install_binary()
    
    def install_binary(self):
        try:
            os_name, arch = self.get_system_info()
            
            # Construct URL for compressed file based on OS
            base_url = "https://github.com/spacejar-labs/spacejar-cli/releases/download/v0.1.0-test"
            binary_name = 'spacejar.exe' if os_name == 'windows' else 'spacejar'
            
            # Use .zip for Windows, .tar.gz for Unix-like systems
            archive_ext = '.zip' if os_name == 'windows' else '.tar.gz'
            archive_name = f"spacejar-{os_name}-{arch}{archive_ext}"
            archive_url = f"{base_url}/{archive_name}"
            
            logger.info(f"Downloading Spacejar archive from {archive_url}")
            
            # Get installation directory
            install_dir = self.get_install_dir()
            binary_path = install_dir / binary_name
            
            # Create a temporary directory for extraction
            with tempfile.TemporaryDirectory() as temp_dir:
                # Download and save the archive
                archive_path = Path(temp_dir) / archive_name
                response = requests.get(archive_url, stream=True)
                response.raise_for_status()
                
                with open(archive_path, 'wb') as f:
                    for chunk in response.iter_content(chunk_size=8192):
                        f.write(chunk)
                
                # Extract based on archive type
                if os_name == 'windows':
                    self.extract_zip(archive_path, temp_dir, binary_name)
                else:
                    self.extract_targz(archive_path, temp_dir, binary_name)
                
                # Find the extracted binary
                extracted_binary = None
                for root, _, files in os.walk(temp_dir):
                    for file in files:
                        if file == binary_name:
                            extracted_binary = Path(root) / file
                            break
                    if extracted_binary:
                        break
                
                if not extracted_binary:
                    raise RuntimeError(f"Binary {binary_name} not found in archive")
                
                # Create installation directory if needed
                install_dir.mkdir(parents=True, exist_ok=True)
                
                # Move binary to final location
                shutil.move(str(extracted_binary), str(binary_path))
            
            # Make executable on Unix-like systems
            if os_name != 'windows':
                binary_path.chmod(binary_path.stat().st_mode | 0o755)
            
            logger.info(f"Binary installed successfully at: {binary_path}")
            
            # Test the binary
            self.test_binary(binary_path)
            
        except Exception as e:
            logger.error(f"Failed to install binary: {e}")
            raise

    def extract_zip(self, archive_path, extract_path, binary_name):
        """Extract binary from ZIP archive."""
        logger.info("Extracting ZIP archive...")
        with zipfile.ZipFile(archive_path, 'r') as zip_ref:
            # Extract only the binary file
            binary_info = next(
                (info for info in zip_ref.infolist() 
                 if info.filename.endswith(binary_name)), None
            )
            if not binary_info:
                raise RuntimeError(f"Binary {binary_name} not found in ZIP archive")
            
            zip_ref.extract(binary_info, extract_path)
    
    def extract_targz(self, archive_path, extract_path, binary_name):
        """Extract binary from tar.gz archive."""
        logger.info("Extracting tar.gz archive...")
        with tarfile.open(archive_path, 'r:gz') as tar:
            # Extract only the binary file
            binary_member = next(
                (m for m in tar.getmembers() 
                 if m.name.endswith(binary_name)), None
            )
            if not binary_member:
                raise RuntimeError(f"Binary {binary_name} not found in tar.gz archive")
            
            tar.extract(binary_member, extract_path)

    def get_system_info(self):
        # OS detection
        if sys.platform.startswith('win'):
            os_name = 'windows'
        elif sys.platform.startswith('darwin'):
            os_name = 'darwin'
        elif sys.platform.startswith('linux'):
            os_name = 'linux'
        else:
            raise RuntimeError(f"Unsupported operating system: {sys.platform}")
        
        # Architecture detection
        machine = platform.machine().lower()
        if machine in ('x86_64', 'amd64'):
            arch = 'x86_64'
        elif machine in ('arm64', 'aarch64'):
            arch = 'aarch64'
        else:
            raise RuntimeError(f"Unsupported architecture: {machine}")
        
        logger.info(f"Detected system: {os_name} ({arch})")
        return os_name, arch

    def get_install_dir(self):
        """Find suitable installation directory in PATH."""
        if sys.platform.startswith('win'):
            # Use %LOCALAPPDATA%\Programs for Windows
            user_bin = Path(os.environ.get('LOCALAPPDATA', '')) / 'Programs' / 'spacejar'
        else:
            # Use ~/.local/bin for Unix-like systems
            user_bin = Path.home() / '.local' / 'bin'
        
        try:
            user_bin.mkdir(parents=True, exist_ok=True)
            logger.info(f"Installing to directory: {user_bin}")
            
            if str(user_bin) not in os.environ.get('PATH', ''):
                if sys.platform.startswith('win'):
                    logger.info(
                        f"\nNOTE: Add the following directory to your PATH:\n"
                        f"{user_bin}\n"
                        f"You can do this through System Properties > Environment Variables\n"
                    )
                else:
                    logger.info(
                        f"\nNOTE: Add the following line to your shell config (~/.bashrc, ~/.zshrc, etc.):\n"
                        f"export PATH=\"{user_bin}:$PATH\"\n"
                        f"Then restart your terminal or run: source ~/.bashrc (or ~/.zshrc)\n"
                    )
            
            return user_bin
            
        except Exception as e:
            logger.warning(f"Could not install to {user_bin}: {e}")
            if hasattr(self, 'install_scripts'):
                script_dir = Path(self.install_scripts)
                logger.info(f"Installing to Python scripts directory: {script_dir}")
                return script_dir
            else:
                raise RuntimeError("Could not find suitable installation directory")

    def test_binary(self, binary_path):
        try:
            import subprocess
            logger.info("Testing binary installation...")
            result = subprocess.run(
                [str(binary_path), '--version'], 
                capture_output=True, 
                text=True
            )
            if result.returncode == 0:
                logger.info("Binary test successful")
            else:
                logger.warning(
                    f"Binary test returned non-zero exit code: {result.returncode}\n"
                    f"stdout: {result.stdout}\n"
                    f"stderr: {result.stderr}"
                )
        except Exception as e:
            logger.warning(f"Binary test failed: {e}")

setup(
    name="spacejar",
    version="0.1.0",
    description="Binary installer for Spacejar CLI",
    packages=[''],
    package_dir={'': 'src'},
    install_requires=['requests'],
    cmdclass={
        'install': PostInstallCommand,
    },
)