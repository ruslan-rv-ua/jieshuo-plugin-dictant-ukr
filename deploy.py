# This script is for personal use only.
# It copies the plugin's script as Jieshuo function to the Jieshuo's local folder synced with corresponding folder on the phone.

import shutil
import tomllib
from pathlib import Path
from winsound import Beep

DESTINATION_DIR = Path(r'e:\syncthing\unihertz_tank_jieshuo\жести\Персоналізовано')

current_dir = Path(__file__).parent.absolute()
plugin = tomllib.loads((current_dir / "project.toml").read_text(encoding="utf-8"))
source_file = current_dir / "src" / "main.lua"
destination_file = DESTINATION_DIR / plugin['build_name']

shutil.copy(source_file, destination_file)

Beep(333, 333)
