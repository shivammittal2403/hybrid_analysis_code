#!/bin/bash

# Directory to save the downloaded pages
output_dir="hybrid_analysis_pages"

# Directory to save detailed reports
report_dir="hybrid_analysis_reports"

# Your Hybrid Analysis API key
api_key="YOUR_API_KEY"

# Create the directories if they don't exist
mkdir -p "$output_dir"
mkdir -p "$report_dir"

# Function to fetch detailed report for a given hash
fetch_report() {
    local hash=$1
    local report_file="$report_dir/${hash}.json"

    # Check if the report already exists
    if [[ -f "$report_file" ]]; then
        echo "Report for hash $hash already exists. Skipping download."
        return
    fi

    # Fetch the report using the Hybrid Analysis API
    response=$(curl -s -X POST "https://www.hybrid-analysis.com/api/v2/search/hash" \
        -H "User-Agent: Falcon Sandbox" \
        -H "api-key: $api_key" \
        -H "Content-Type: application/x-www-form-urlencoded" \
        -d "hash=$hash")

    # Check if the response contains a valid report
    if echo "$response" | jq -e '.[0]' > /dev/null; then
        echo "$response" > "$report_file"
        echo "Report for hash $hash saved to $report_file"
    else
        echo "No report found for hash $hash"
    fi
}

# Loop through page numbers 1 to 1657
for page_num in {1..1657}; do
    # Define the URL
    url="https://hybrid-analysis.com/file-collections?page=$page_num"

    # Define the output file name
    output_file="$output_dir/page_$page_num.html"

    # Use curl to download the page and save it to the output file
    curl -s "$url" -o "$output_file"

    # Extract hashes from the downloaded page
    hashes=$(grep -oE '[a-fA-F0-9]{64}' "$output_file")

    # Fetch detailed reports for each hash
    for hash in $hashes; do
        fetch_report "$hash"
    done

    # Optional: Print a message indicating the download status
    echo "Processed $url"
done
