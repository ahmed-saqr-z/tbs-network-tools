#!/bin/bash

# Network Diagnostics Tool for macOS/Linux
# Performs parallel ping, traceroute, and mtr tests

# Colors for output
CYAN='\033[0;36m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
GRAY='\033[0;90m'
NC='\033[0m' # No Color

# Detect OS
OS_TYPE="$(uname -s)"
case "$OS_TYPE" in
    Linux*)     OS_NAME="Linux";;
    Darwin*)    OS_NAME="macOS";;
    CYGWIN*|MINGW*|MSYS*)
        echo -e "\n${RED}═══════════════════════════════════════════════════════${NC}"
        echo -e "${RED}  Error: This script is for macOS/Linux only!${NC}"
        echo -e "${RED}═══════════════════════════════════════════════════════${NC}"
        echo -e "\n${YELLOW}For Windows, please use:${NC}"
        echo -e "powershell -ExecutionPolicy Bypass -Command \"iex (irm https://raw.githubusercontent.com/ahmed-saqr-z/tbs-network-tools/main/Network-Diagnostics.ps1)\"\n"
        exit 1
        ;;
    *)
        echo -e "\n${RED}Error: Unknown operating system: $OS_TYPE${NC}\n"
        exit 1
        ;;
esac

# Display header
echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
echo -e "${CYAN}  Network Diagnostics Tool${NC}"
echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"
echo -e "  ${GRAY}Operating System: $OS_NAME${NC}\n"

# Prompt for instance name
read -p "Enter instance name: " instance_name

# Validate input
if [ -z "$instance_name" ]; then
    echo -e "\n${RED}Error: Instance name cannot be empty!${NC}\n"
    exit 1
fi

# Construct domain
domain="${instance_name}.aswat.co"
echo -e "\n${GREEN}Target domain: $domain${NC}"

# Check if domain is reachable (quick DNS check)
if ! host "$domain" > /dev/null 2>&1; then
    echo -e "\n${YELLOW}Warning: Unable to resolve $domain${NC}"
    echo -e "${YELLOW}The tests will continue, but may show connection failures.${NC}\n"
    read -p "Press Enter to continue or Ctrl+C to cancel..."
fi

# Create timestamp for file naming
timestamp=$(date +"%Y-%m-%d_%H%M%S")

# Define output file paths
ping_file="${instance_name} ping ${timestamp}.txt"
trace_file="${instance_name} traceroute ${timestamp}.txt"
mtr_file="${instance_name} mtr ${timestamp}.txt"

# Check for required commands
if ! command -v ping &> /dev/null; then
    echo -e "\n${RED}Error: 'ping' command not found!${NC}\n"
    exit 1
fi

if ! command -v traceroute &> /dev/null; then
    echo -e "\n${RED}Error: 'traceroute' command not found!${NC}\n"
    exit 1
fi

# Check for MTR (optional)
run_mtr=true
if ! command -v mtr &> /dev/null; then
    run_mtr=false
    mtr_message="MTR not installed (install with: brew install mtr)"
fi

echo -e "\n${YELLOW}Starting tests...${NC}\n"
sleep 1

# Create temporary files for outputs
ping_tmp=$(mktemp)
trace_tmp=$(mktemp)
mtr_tmp=$(mktemp)
ping_pid_file=$(mktemp)
trace_pid_file=$(mktemp)
mtr_pid_file=$(mktemp)

# Start background jobs
(ping -c 300 "$domain" > "$ping_tmp" 2>&1; echo $? > "$ping_pid_file") &
ping_pid=$!

# Traceroute with max 30 hops and 2 second timeout per hop
(traceroute -m 30 -w 2 "$domain" > "$trace_tmp" 2>&1; echo $? > "$trace_pid_file") &
trace_pid=$!

if [ "$run_mtr" = true ]; then
    # MTR without sudo: 50 cycles, 0.5 second interval (faster)
    (mtr -r -c 50 -i 0.5 "$domain" > "$mtr_tmp" 2>&1; echo $? > "$mtr_pid_file") &
    mtr_pid=$!
fi

# Track start time
start_time=$(date +%s)
ping_duration=300

# Progress display
ping_completed=false
trace_completed=false
mtr_completed=false
ping_saved=false
trace_saved=false
mtr_saved=false
[ "$run_mtr" = false ] && mtr_completed=true

while [ "$ping_completed" = false ] || [ "$trace_completed" = false ] || [ "$mtr_completed" = false ]; do
    # Clear screen
    clear

    # Calculate elapsed time
    current_time=$(date +%s)
    elapsed=$((current_time - start_time))
    elapsed_min=$((elapsed / 60))
    elapsed_sec=$((elapsed % 60))
    elapsed_display=$(printf "%02d:%02d" $elapsed_min $elapsed_sec)

    # Display header
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  Network Diagnostics - $domain${NC}"
    echo -e "${CYAN}  Platform: $OS_NAME${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}\n"

    # Check ping status
    if ! kill -0 $ping_pid 2>/dev/null; then
        if [ "$ping_completed" = false ]; then
            ping_completed=true
            ping_end_time=$(date +%s)
            ping_duration_actual=$((ping_end_time - start_time))
            ping_duration_min=$((ping_duration_actual / 60))
            ping_duration_sec=$((ping_duration_actual % 60))
        fi
        # Save ping output immediately if not already saved
        if [ "$ping_saved" = false ]; then
            ping_exit_code=$(cat "$ping_pid_file" 2>/dev/null || echo "1")
            if [ "$ping_exit_code" -eq 0 ]; then
                cat "$ping_tmp" > "$ping_file"
            else
                echo "Ping test failed. The domain may not be reachable." > "$ping_file"
                cat "$ping_tmp" >> "$ping_file"
            fi
            ping_saved=true
        fi
        ping_duration_display=$(printf "%02d:%02d" $ping_duration_min $ping_duration_sec)
        echo -e "  Ping:       ${GREEN}[Completed]${NC} ($ping_duration_display)"
    else
        ping_remaining=$((ping_duration - elapsed))
        [ $ping_remaining -lt 0 ] && ping_remaining=0
        ping_remaining_min=$((ping_remaining / 60))
        ping_remaining_sec=$((ping_remaining % 60))
        ping_remaining_display=$(printf "%02d:%02d" $ping_remaining_min $ping_remaining_sec)

        # Progress bar
        ping_progress=$((elapsed * 100 / ping_duration))
        [ $ping_progress -gt 100 ] && ping_progress=100
        bar_length=20
        filled=$((bar_length * ping_progress / 100))
        bar=$(printf '%*s' "$filled" | tr ' ' '#')
        empty=$((bar_length - filled))
        bar+=$(printf '%*s' "$empty" | tr ' ' '-')

        echo -e "  Ping:       ${YELLOW}[$bar]${NC} $ping_remaining_display remaining"
    fi

    # Check traceroute status
    if ! kill -0 $trace_pid 2>/dev/null; then
        if [ "$trace_completed" = false ]; then
            trace_completed=true
            trace_end_time=$(date +%s)
            trace_duration=$((trace_end_time - start_time))
            trace_duration_min=$((trace_duration / 60))
            trace_duration_sec=$((trace_duration % 60))
        fi
        # Save traceroute output immediately if not already saved
        if [ "$trace_saved" = false ]; then
            trace_exit_code=$(cat "$trace_pid_file" 2>/dev/null || echo "1")
            if [ "$trace_exit_code" -eq 0 ]; then
                cat "$trace_tmp" > "$trace_file"
            else
                echo "Traceroute test failed. The domain may not be reachable." > "$trace_file"
                cat "$trace_tmp" >> "$trace_file"
            fi
            trace_saved=true
        fi
        trace_duration_display=$(printf "%02d:%02d" $trace_duration_min $trace_duration_sec)
        echo -e "  Traceroute: ${GREEN}[Completed]${NC} ($trace_duration_display)"
    else
        echo -e "  Traceroute: ${YELLOW}[Running...]${NC}"
    fi

    # Check MTR status
    if [ "$run_mtr" = false ]; then
        echo -e "  MTR:        ${GRAY}[Skipped]${NC} ($mtr_message)"
    elif ! kill -0 $mtr_pid 2>/dev/null; then
        if [ "$mtr_completed" = false ]; then
            mtr_completed=true
            mtr_end_time=$(date +%s)
            mtr_duration=$((mtr_end_time - start_time))
            mtr_duration_min=$((mtr_duration / 60))
            mtr_duration_sec=$((mtr_duration % 60))
        fi
        # Save MTR output immediately if not already saved
        if [ "$mtr_saved" = false ]; then
            mtr_exit_code=$(cat "$mtr_pid_file" 2>/dev/null || echo "1")
            if [ "$mtr_exit_code" -eq 0 ]; then
                cat "$mtr_tmp" > "$mtr_file"
            else
                echo "MTR test failed. You may need to run with sudo." > "$mtr_file"
                cat "$mtr_tmp" >> "$mtr_file"
            fi
            mtr_saved=true
        fi
        mtr_duration_display=$(printf "%02d:%02d" $mtr_duration_min $mtr_duration_sec)
        echo -e "  MTR:        ${GREEN}[Completed]${NC} ($mtr_duration_display)"
    else
        mtr_elapsed_display=$(printf "%02d:%02d" $elapsed_min $elapsed_sec)
        echo -e "  MTR:        ${YELLOW}[Running...]${NC} $mtr_elapsed_display elapsed"
    fi

    # Total elapsed time
    echo -e "\n  Total Elapsed: $elapsed_display"
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"

    sleep 1
done

# Wait for all jobs to complete
wait $ping_pid 2>/dev/null
wait $trace_pid 2>/dev/null
[ "$run_mtr" = true ] && wait $mtr_pid 2>/dev/null

# Clean up temporary files
rm -f "$ping_tmp" "$trace_tmp" "$mtr_tmp" "$ping_pid_file" "$trace_pid_file" "$mtr_pid_file"

# Final summary
end_time=$(date +%s)
total_time=$((end_time - start_time))
total_min=$((total_time / 60))
total_sec=$((total_time % 60))
total_display=$(printf "%02d:%02d" $total_min $total_sec)

echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "${GREEN}  Tests Completed!${NC}"
echo -e "${GREEN}═══════════════════════════════════════════════════════${NC}"
echo -e "\n  Results saved to:"
echo -e "    ${CYAN}- $ping_file${NC}"
echo -e "    ${CYAN}- $trace_file${NC}"
if [ "$run_mtr" = true ]; then
    echo -e "    ${CYAN}- $mtr_file${NC}"
else
    echo -e "    ${GRAY}- $mtr_file (skipped - MTR not available)${NC}"
fi
echo -e "\n  Total Duration: $total_display"
echo -e "\n${GREEN}═══════════════════════════════════════════════════════${NC}\n"
