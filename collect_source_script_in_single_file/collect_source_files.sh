#!/bin/bash

# ============================================================
# Source / Build File Collector
#
# Generates:
#   header_files.h
#   c_source_file.c
#   cpp_source_file.cpp
#   script_files.sh
#   cmake_files.txt
#   make_files.txt
# ============================================================

set -e

ROOT_DIR="."

HEADER_OUTPUT="header_files.h"
C_OUTPUT="c_source_file.c"
CPP_OUTPUT="cpp_source_file.cpp"
SCRIPT_OUTPUT="script_files.sh"
CMAKE_OUTPUT="cmake_files.txt"
MAKE_OUTPUT="make_files.txt"

SELF_SCRIPT="$(basename "$0")"

# ------------------------------------------------------------
# Remove old generated files
# ------------------------------------------------------------

rm -f \
    "$HEADER_OUTPUT" \
    "$C_OUTPUT" \
    "$CPP_OUTPUT" \
    "$SCRIPT_OUTPUT" \
    "$CMAKE_OUTPUT" \
    "$MAKE_OUTPUT"

# ------------------------------------------------------------
# Check whether a file must be excluded
# ------------------------------------------------------------

is_excluded()
{
    local file="$1"
    local name
    name="$(basename "$file")"

    case "$name" in
        "$HEADER_OUTPUT"|"$C_OUTPUT"|"$CPP_OUTPUT"|"$SCRIPT_OUTPUT"|"$CMAKE_OUTPUT"|"$MAKE_OUTPUT"|"$SELF_SCRIPT")
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

# ------------------------------------------------------------
# Get files for a category
# ------------------------------------------------------------

get_files()
{
    local type="$1"

    case "$type" in
        h)
            find "$ROOT_DIR" -type f -name "*.h"
            ;;
        c)
            find "$ROOT_DIR" -type f -name "*.c"
            ;;
        cpp)
            find "$ROOT_DIR" -type f -name "*.cpp"
            ;;
        sh)
            find "$ROOT_DIR" -type f -name "*.sh"
            ;;
        cmake)
            find "$ROOT_DIR" -type f \
                \( -name "CMakeLists.txt" -o -name "*.cmake" \)
            ;;
        make)
            find "$ROOT_DIR" -type f \
                \( -name "Makefile" -o -name "GNUmakefile" -o -name "makefile" \)
            ;;
    esac |
    while IFS= read -r file
    do
        if ! is_excluded "$file"; then
            printf '%s\n' "$file"
        fi
    done |
    sed 's#^\./##' |
    sort
}

# ------------------------------------------------------------
# Write folder structure into output file
# ------------------------------------------------------------

write_structure()
{
    local type="$1"
    local output="$2"
    local title="$3"

    {
        echo "============================================================"
        echo "$title"
        echo "============================================================"
        echo "."
    } >> "$output"

    # Print paths into the output file only.
    get_files "$type" |
    while IFS= read -r file
    do
        echo "|-- $file"
    done >> "$output"

    {
        echo
        echo "============================================================"
        echo
    } >> "$output"
}

# ------------------------------------------------------------
# Collect file contents
# ------------------------------------------------------------

collect_files()
{
    local type="$1"
    local output="$2"

    get_files "$type" |
    while IFS= read -r file
    do
        if [ -s "$output" ]; then
            printf "\n" >> "$output"
        fi

        printf "Path:%s\n" "$file" >> "$output"
        cat "$file" >> "$output"
        printf "\n" >> "$output"
    done
}

# ------------------------------------------------------------
# Create outputs
# ------------------------------------------------------------

touch \
    "$HEADER_OUTPUT" \
    "$C_OUTPUT" \
    "$CPP_OUTPUT" \
    "$SCRIPT_OUTPUT" \
    "$CMAKE_OUTPUT" \
    "$MAKE_OUTPUT"

# ------------------------------------------------------------
# Header files
# ------------------------------------------------------------

write_structure \
    "h" \
    "$HEADER_OUTPUT" \
    "Header Files (*.h)"

collect_files "h" "$HEADER_OUTPUT"

# ------------------------------------------------------------
# C files
# ------------------------------------------------------------

write_structure \
    "c" \
    "$C_OUTPUT" \
    "C Source Files (*.c)"

collect_files "c" "$C_OUTPUT"

# ------------------------------------------------------------
# C++ files
# ------------------------------------------------------------

write_structure \
    "cpp" \
    "$CPP_OUTPUT" \
    "C++ Source Files (*.cpp)"

collect_files "cpp" "$CPP_OUTPUT"

# ------------------------------------------------------------
# Shell scripts
# ------------------------------------------------------------

write_structure \
    "sh" \
    "$SCRIPT_OUTPUT" \
    "Shell Scripts (*.sh)"

collect_files "sh" "$SCRIPT_OUTPUT"

# ------------------------------------------------------------
# CMake files
# ------------------------------------------------------------

write_structure \
    "cmake" \
    "$CMAKE_OUTPUT" \
    "CMake Files"

collect_files "cmake" "$CMAKE_OUTPUT"

# ------------------------------------------------------------
# Makefiles
# ------------------------------------------------------------

write_structure \
    "make" \
    "$MAKE_OUTPUT" \
    "Make Files"

collect_files "make" "$MAKE_OUTPUT"

# ------------------------------------------------------------
# Summary
# ------------------------------------------------------------

echo
echo "=========================================="
echo " Source/Build collection completed"
echo "=========================================="
echo
echo "Generated:"
echo "  $HEADER_OUTPUT"
echo "  $C_OUTPUT"
echo "  $CPP_OUTPUT"
echo "  $SCRIPT_OUTPUT"
echo "  $CMAKE_OUTPUT"
echo "  $MAKE_OUTPUT"
echo
echo "File counts:"
echo "  Header files : $(grep -c '^Path:' "$HEADER_OUTPUT" 2>/dev/null || true)"
echo "  C files      : $(grep -c '^Path:' "$C_OUTPUT" 2>/dev/null || true)"
echo "  C++ files    : $(grep -c '^Path:' "$CPP_OUTPUT" 2>/dev/null || true)"
echo "  Script files : $(grep -c '^Path:' "$SCRIPT_OUTPUT" 2>/dev/null || true)"
echo "  CMake files  : $(grep -c '^Path:' "$CMAKE_OUTPUT" 2>/dev/null || true)"
echo "  Makefiles    : $(grep -c '^Path:' "$MAKE_OUTPUT" 2>/dev/null || true)"
echo