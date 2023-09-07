from pathlib import Path
import zipfile
import tomllib

FILES_TO_ZIP = ["src/main.lua"]

current_dir = Path(__file__).parent.absolute()
plugin = tomllib.loads((current_dir / "project.toml").read_text(encoding="utf-8"))

build_dir = current_dir / "build"
if not build_dir.exists():
    build_dir.mkdir()
zip_file_name = f"{plugin['build_name']}-{plugin['version']}-{plugin['language']}.ppk"

with zipfile.ZipFile(current_dir/ "build" / zip_file_name, "w", zipfile.ZIP_DEFLATED, compresslevel=9) as zipf:
    for file_to_zip in FILES_TO_ZIP:
        zipf.write(file_to_zip) 
