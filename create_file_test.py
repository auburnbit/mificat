from pathlib import Path
path = str(Path.home()) + "\\AppData\\Roaming\\Godot\\app_userdata\\Quiz Program 2.0\\"
f = Path(path + "success.signal")
print(str(f.is_file()))