#  _____ _____                           
# |  ___|  ___| __ ___  _ __   ___  __ _ 
# | |_  | |_ | '_ ` _ \| '_ \ / _ \/ _` |
# |  _| |  _|| | | | | | |_) |  __/ (_| |
# |_|   |_|  |_| |_| |_| .__/ \___|\__, |
#                      |_|         |___/ 
# 

if ! _has ffmpeg; then
    return 1
fi

# Audio codecs rating
# source: https://trac.ffmpeg.org/wiki/Encode/HighQualityAudio#AudioencodersFFmpegcanuse
# libopus > libvorbis >= libfdk_aac > libmp3lame >= eac3/ac3 > aac > libtwolame > vorbis > mp2 > wmav2/wmav1

# ===============
# ALIASES START
# To see the full list of active aliases, run `alias`
# To search for a specific alias, run `alf`
# ===============

alias ffmpeg_info="ffmpeg -i"

# ------------------
# Video manipulation
# ------------------

# Video to video conversion
# -------------------------

# https://trac.ffmpeg.org/wiki/Encode/H.264
# $1 - source video
function ffmpeg_vid2vid_h264() {
    local src="$1"
    local dest_ext="mkv"
    local dest="${src%.*}.${dest_ext}"
    if [[ -f $dest ]]; then
        dest="${src%.*}-copy.${dest_ext}"
    fi
    ffmpeg -v warning -i "$src" -c:v libx264 -crf 23 -preset slow -c:a copy "$dest"
}
alias ffmpeg_vid2vid_avc="ffmpeg_vid2vid_h264"

# https://trac.ffmpeg.org/wiki/Encode/H.265
# $1 - source video
function ffmpeg_vid2vid_h265() {
    local src="$1"
    local dest_ext="mkv"
    local dest="${src%.*}.${dest_ext}"
    if [[ -f $dest ]]; then
        dest="${src%.*}-copy.${dest_ext}"
    fi
    ffmpeg -v warning -i "$src" -c:v libx265 -crf 28 -preset slow -c:a copy "$dest"
}
alias ffmpeg_vid2vid_hevc="ffmpeg_vid2vid_h265"

# mp4 container + h264 codec is the best combination in terms of compatibility
function ffmpeg_vid2vid_compatible() {
    local src="$1"
    local dest_ext="mp4"
    local dest="${src%.*}.${dest_ext}"
    if [[ -f $dest ]]; then
        dest="${src%.*}-copy.${dest_ext}"
    fi
    ffmpeg -v warning -i "$src" -c:v libx264 -crf 23 -preset slow -c:a copy "$dest"
}
function ffmpeg_vid2vid_good() {
    local src="$1"
    local dest_ext="webm"
    local dest="${src%.*}.${dest_ext}"
    if [[ -f $dest ]]; then
        dest="${src%.*}-copy.${dest_ext}"
    fi
    ffmpeg -v warning -i "$src" -c:v libvpx-vp9 -crf 24 -b:v 0 -deadline good -c:a libopus "$dest"
}

# use it only if you need to change the container but not the codec (i.e. remux)
# works very fast as it doesn't need to decode/encode
# note that a video/audio codec, contained in the source container, might be not supported by the target container
# usage:
#   ffmpeg_vid2vid_copy video.mkv mp4
function ffmpeg_vid2vid_copy() {
    local src="$1"
    local dest_ext="${2##.}"
    local dest="${src%.*}.${dest_ext}"
    if [[ -f $dest ]]; then
        dest="${src%.*}-copy.${dest_ext}"
    fi
    ffmpeg -v warning -i "$src" -c:v copy -c:a copy "$dest"
}

# Video cutting
# Read more on seeking - https://trac.ffmpeg.org/wiki/Seeking#Cuttingsmallsections
# -------------

# pass time in seconds
function ffmpeg_vid_cut_from_to() {
    local src="$1"
    local src_ext="${1##*.}"
    local dest="${src%.*}-cut.${src_ext}"
    ffmpeg -v warning -ss $2 -to $3 -i "$src" -c copy -y "$dest"
}

function ffmpeg_vid_cut_from_duration() {
    local src="$1"
    local src_ext="${1##*.}"
    local dest="${src%.*}-cut.${src_ext}"
    ffmpeg -v warning -ss $2  -i "$src" -t $3 -c copy -y "$dest"
}

function ffmpeg_vid_cut_from() {
    local src="$1"
    local src_ext="${1##*.}"
    local dest="${src%.*}-cut.${src_ext}"
    ffmpeg -v warning -ss $2 -i "$src" -c copy -y "$dest"
}

# Video to audio
# --------------

# the best settings for music production
function ffmpeg_vid2aud_uncompressed() {
    local src="$1"
    local dest_ext="wav"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -vn -c:a pcm_s24le -ar 48000 -ac 2 "$dest"
}

# flac is the best lossless codec
function ffmpeg_vid2aud_lossless() {
    local src="$1"
    local dest_ext="flac"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -vn -c:a flac -ar 44100 -ac 2 "$dest"
}

# opus is the best lossy format
function ffmpeg_vid2aud_lossy_best() {
    local src="$1"
    local dest_ext="opus"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -vn -c:a libopus -ar 44100 -ac 2 -ab 192k "$dest"
}
# mp3 is the most compatible format
function ffmpeg_vid2aud_lossy_compatible() {
    local src="$1"
    local dest_ext="mp3"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -vn -c:a libmp3lame -ar 44100 -ac 2 -ab 192k "$dest"
}
# aac is a good trade-off between quality and compatibility
function ffmpeg_vid2aud_lossy() {
    local src="$1"
    local dest_ext="m4a"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -vn -c:a libfdk_aac -ar 44100 -ac 2 -ab 192k "$dest"
}

# Video to gif
# ------------

# create gif
# $1 - mp4/webm source file
function ffmpeg_vid2gif() {
    local src="$1"
    local dest="${src%.*}.gif"

    local palette="/tmp/palette-$(basename "$src").png"
    local filters="fps=15,scale=320:-1:flags=lanczos"

    ffmpeg -v warning -i "$src" -vf "$filters,palettegen" -y "$palette"
    ffmpeg -v warning -i "$src" -i "$palette" -lavfi "$filters [x]; [x][1:v] paletteuse" -y "$dest"
    [[ -f "$palette" ]] && rm "$palette"
}

# Audio to audio
# --------------

# the best settings for music production
function ffmpeg_aud2aud_uncompressed() {
    local src="$1"
    local dest_ext="wav"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -c:a pcm_s24le -ar 48000 -ac 2 "$dest"
}

# flac is the best lossless codec
function ffmpeg_aud2aud_lossless() {
    local src="$1"
    local dest_ext="flac"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -c:a flac -ar 44100 -ac 2 "$dest"
}

# opus is the best lossy format
function ffmpeg_aud2aud_lossy_best() {
    local src="$1"
    local dest_ext="opus"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -c:a libopus -ar 44100 -ac 2 -ab 192k "$dest"
}
# mp3 is the most compatible format
function ffmpeg_aud2aud_lossy_compatible() {
    local src="$1"
    local dest_ext="mp3"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -c:a libmp3lame -ar 44100 -ac 2 -ab 192k "$dest"
}
# aac is a good trade-off between quality and compatibility
function ffmpeg_aud2aud_lossy() {
    local src="$1"
    local dest_ext="m4a"
    local dest="${src%.*}.${dest_ext}"
    ffmpeg -v warning -i "$src" -c:a libfdk_aac -ar 44100 -ac 2 -ab 192k "$dest"
}

# Audio cutting
# Read more on seeking - https://trac.ffmpeg.org/wiki/Seeking#Cuttingsmallsections
# -------------

# pass time in seconds
function ffmpeg_aud_cut_from_to() {
    local src="$1"
    local src_ext="${1##*.}"
    local dest="${src%.*}-cut.${src_ext}"
    ffmpeg -v warning -ss $2 -to $3 -i "$src" -c:a copy -y "$dest"
}

function ffmpeg_aud_cut_from_duration() {
    local src="$1"
    local src_ext="${1##*.}"
    local dest="${src%.*}-cut.${src_ext}"
    ffmpeg -v warning -ss "$2" -t "$3" -i "$src" -c:a copy -y "$dest"
}

function ffmpeg_aud_cut_from() {
    local src="$1"
    local src_ext="${1##*.}"
    local dest="${src%.*}-cut.${src_ext}"
    ffmpeg -v warning -ss $2 -i "$src" -c:a copy -y "$dest"
}


# ------------------
# Image manipulation
# ------------------

function ffmpeg_img2jpg() {
    local src="$1"
    local dest="${src%.*}.jpg"
    ffmpeg -v warning -i "$src" -frames:v 1 -update true -y "$dest"
}
function ffmpeg_img2png() {
    local src="$1"
    local dest="${src%.*}.png"
    ffmpeg -v warning -i "$src" -frames:v 1 -update true -y "$dest"
}

# Resize image
# pass scale in form of "width:height"
# read https://trac.ffmpeg.org/wiki/Scaling#SimpleRescaling
# The scale filter can also automatically calculate a dimension while preserving the aspect ratio
# scale=320:-1 / scale=-1:240
function ffmpeg_img_resize() {
    local src="$1"
    local src_ext="${1##*.}"
    local scale="$2"
    if [[ -z "$scale" ]]; then
        echo "Please provide a scale in form of 'width:height'"
        return 1
    fi
    local width=$(awk -F: '{print $1}' <<< "$scale")
    local height=$(awk -F: '{print $2}' <<< "$scale")
    echo "$width x $height"
    if [[ $width -eq $height ]]; then
        local dest="${src%.*}_"$width".${src_ext}"
    elif [[ $width -eq -1 ]]; then
        local dest="${src%.*}_"$height".${src_ext}"
    elif [[ $height -eq -1 ]]; then
        local dest="${src%.*}_"$width".${src_ext}"
    else
        local dest="${src%.*}_"$width"_"$height".${src_ext}"
    fi
    ffmpeg -v warning -i "$src" -vf scale="$scale" "$dest" -y
}


# ------------------------------------------
# Telegram media manipulation
# ------------------------------------------

# read https://trac.ffmpeg.org/wiki/Encode/VP9#constantq
# use yuva instead of yuv - yuva supports alpha channel (transparency)
TELEGRAM_OUT_OPTS=(-pix_fmt yuva420p -crf 15 -b:v 0 -deadline best -cpu-used 0)

# Stickers
# --------

# $1 - mp4 source file
function ffmpeg_telegram_sticker() {
    local src="$1"
    local dest="${src%.*}.webm"
    ffmpeg -i "$src" -r 24 -t 3 -an -c:v libvpx-vp9 -s 512x512 "${TELEGRAM_OUT_OPTS[@]}" -y "$dest"
}

function ffmpeg_telegram_sticker_speeded_up() {
    local src="$1"
    local dest="${src%.*}.webm"
    local speed="$2"
    if [[ -z "$speed" ]]; then
        speed="1.125"
    fi
    echo "speed: $speed\n"
    ffmpeg -i "$src" -r 24 -t 3 -an -c:v libvpx-vp9 -s 512x512 "${TELEGRAM_OUT_OPTS[@]}" -filter:v "setpts=PTS/$speed" -y "$dest"
}

# Emojis
# ------

# $1 - jpg/png source file
function ffmpeg_telegram_emoji_static() {
    local src="$1"
    local dest="${src%.*}.webm"
    ffmpeg -f image2 -s 100x100 -framerate 25 -i "$src" -c:v libvpx-vp9 -s 100x100 "${TELEGRAM_OUT_OPTS[@]}" -y "$dest"
}

# $1 - mp4 source file
function ffmpeg_telegram_emoji_animated() {
    local src="$1"
    local dest="${src%.*}.webm"
    ffmpeg -i "$src" -r 24 -t 3 -an -c:v libvpx-vp9 -s 100x100 "${TELEGRAM_OUT_OPTS[@]}" -y "$dest"
}

# Gifs
# ----

alias ffmpeg_telegram_gif="ffmpeg_vid2gif"

