import sys
import json
import exiftool

def print_exif_data(file_path):
    with exiftool.ExifTool() as et:
        metadata_json = et.execute('-j', '-G', '-n', '-sort', file_path)
        metadata = json.loads(metadata_json)
        print(json.dumps(metadata, indent=4))

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print(f"Usage: {sys.argv[0]} <path_to_image_or_video>")
        sys.exit(1)

    file_path = sys.argv[1]
    print_exif_data(file_path)
