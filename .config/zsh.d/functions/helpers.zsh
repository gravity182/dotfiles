# Guards
# ------

# OS check
# --------

function _is_osx() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        return 0
    fi
    return 1
}
function _is_linux() {
    if [[ "$OSTYPE" == "linux-gnu"* ]]; then
        return 0
    fi
    return 1
}

# Helper functions
# ----------------

# get a file extension
# if there are multiple extensions, extracts only the last one
# examples:
#   filename.ext1.ext2           ->  ext2
#   filename                     ->  filename
function _file_ext() {
    res="${1##*.}"
}
# get all file extensions (if multiple)
# examples:
#   filename.ext1.ext2           ->  ext1.ext2
#   filename                     ->  filename
function _file_ext_all() {
    res="${1#*.}"
}

# trim a trailing dot at the start of a string
# examples:
#   ext                          ->  ext
#   .ext                         ->  ext
#   ..ext                        ->  .ext
# todo can be better
function _trim_trailing_dot() {
    res="${1##.}"
}

# get a filename (removes all extensions)
# call if after _basename to remove path as well
# examples:
#   filename.ext1.ext2           ->  filename
#   /path/to/filename.ext1.ext2  ->  /path/to/filename
#   filename                     ->  filename
function _filename() {
    res="${1%%.*}"
}

# get a filename without path (preserves file extensions)
# examples:
#   /dir1/dir2/filename.ext      ->  filename.ext
#   dir1/dir2/filename.ext       ->  filename.ext
#   filename.ext                 ->  filename.ext
function _basename() {
    res="$(basename $1)"
}

# get a parent dir
# examples:
#   /dir1/dir2/filename.ext      ->  /dir1/dir2
#   /dir1/dir2/                  ->  /dir1
#   /dir1/dir2                   ->  /dir1
#   /dir1                        ->  /dir1
#   dir1/dir2/filename.ext       ->  dir1/dir2
#   dir1/dir2/                   ->  dir1
#   dir1/dir2                    ->  dir1
#   dir1                         ->  dir1
function _parent_dir() {
    local str="$1"
    str="${str%/}" # trim a trailing / at the back of the str
    local parent_dir="${str%/*}"
    if [[ -z $parent_dir ]]; then
        parent_dir="$str" # covers the case when there's only one directory in the path
    fi
    res="$parent_dir"
}

# check whether the given command is executable or aliased
function _has() {
    return $(which $1 >/dev/null)
}

number_regex='^[0-9]+$'

