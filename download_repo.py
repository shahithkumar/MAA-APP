import urllib.request
import zipfile
import io
import os

repo_url = 'https://github.com/tatjapan/mariners_coloring_notes/archive/refs/heads/main.zip'
extract_dir = 'c:/Users/shahi/OneDrive/Documents/Mental_Health_App_Backend/mental_health_app_frontend/extracted_repo'

try:
    print("Downloading repo...")
    r = urllib.request.urlopen(repo_url)
    print("Extracting zip...")
    z = zipfile.ZipFile(io.BytesIO(r.read()))
    z.extractall(extract_dir)
    print("Downloaded and extracted successfully!")
except Exception as e:
    print(f"Error downloading: {e}")
    # Try master branch if main fails
    try:
        print("Trying master branch...")
        repo_url = 'https://github.com/tatjapan/mariners_coloring_notes/archive/refs/heads/master.zip'
        r = urllib.request.urlopen(repo_url)
        z = zipfile.ZipFile(io.BytesIO(r.read()))
        z.extractall(extract_dir)
        print("Downloaded master branch successfully!")
    except Exception as e2:
        print(f"Error downloading master: {e2}")
