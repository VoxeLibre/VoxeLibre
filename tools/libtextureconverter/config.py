import os
import platform

def get_minetest_directory():
    system = platform.system()

    # Windows
    if system == 'Windows':
        return os.environ.get('MINETEST_USER_PATH', os.path.expandvars('%APPDATA%\\Minetest'))

    # Linux
    elif system == 'Linux':
        return os.environ.get('MINETEST_USER_PATH', os.path.expanduser('~/.minetest'))

    # macOS
    elif system == 'Darwin':  # Darwin is the system name for macOS
        return os.environ.get('MINETEST_USER_PATH', os.path.expanduser('~/Library/Application Support/minetest'))

    # Unsupported system
    else:
        return None

# Constants
SUPPORTED_MINECRAFT_VERSION = "1.20"

# Helper vars
home = os.environ["HOME"]
mineclone2_path = os.path.join(get_minetest_directory(),"games","mineclone2")
working_dir = os.getcwd()
appname = "Texture_Converter.py"
