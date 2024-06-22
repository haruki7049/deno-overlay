# Usage

```bash
./fetch-releases.sh sources.json
```
```bash
./fetch-releases.sh | ./filter-download-links.sh
# Get all download links
```
```bash
./fetch-releases.sh | ./filter-download-links.sh | ./filter-x86_64-linux-links.sh
# Get all x86_64-linux download links
```
```bash
./fetch-releases.sh | ./filter-download-links.sh | ./filter-aarch64-linux-links.sh
# Get all aarch64-linux download links
```
