if ! _has yt-dlp; then
    return 1
fi

# download path prefix
readonly path_prefix='/mnt/d/Other'
# default opts when downloading a video
# download 1440p resolution at most
# remux video to mp4 container; remuxing only changes the container - the codecs are copied as is, so if remuxing is not possible the command will fail
# no need to touch other fields - yt-dlp selects the best possible quality by default
readonly video_default_opts="--format-sort 'res:1440' --remux-video 'mp4'"

# check all the available formats
# to download the specific format, pass the format ID as '-f <id>'
alias yt_dl_info="yt-dlp --quiet --list-formats"

# select and download the specific format
function yt_dl_select() {
    local url="$1"
    if [[ -z "$url" ]]; then
        echo "Please provide a URL"
        return 1
    fi
    local format=$(fzf --tac --print0 <<< $(yt_dl_info "$url") | awk '{print $1}')
    if [[ -z "$format" ]]; then
        return 1
    fi
    yt-dlp -f "$format+bestaudio/$format" -o "$path_prefix/%(title)s.%(ext)s" "$url"
}

# download a video
# $1 - video link
alias yt_dl="yt-dlp "$video_default_opts" -o '$path_prefix/%(title)s.%(ext)s'"
alias yt_dl_music_video="yt-dlp "$video_default_opts" -o '/mnt/d/YandexDisk/Music Videos/%(title)s.%(ext)s'"

# Download YouTube playlist videos in separate directory indexed by video order in a playlist
# $1 - playlist link
#   e.g. https://www.youtube.com/playlist?list=PLwiyx1dc3P2JR9N8gQaQN_BCvlSlap7re
alias yt_dl_playlist="yt-dlp "$video_default_opts" -o '$path_prefix/%(playlist)s/%(title)s.%(ext)s'"
alias yt_dl_playlist_indexed="yt-dlp "$video_default_opts" -o '$path_prefix/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"

# Download all playlists of YouTube channel/user keeping each playlist in separate directory:
# $1 - user's playlists link
#   e.g. https://www.youtube.com/user/TheLinuxFoundation/playlists
alias yt_dl_all_user_playlists="yt-dlp "$video_default_opts" -o '$path_prefix/%(uploader)s/%(playlist)s/%(title)s.%(ext)s'"
alias yt_dl_all_user_playlists_indexed="yt-dlp "$video_default_opts" -o '$path_prefix/%(uploader)s/%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s'"

# download audio only
# selects the best possible quality by default
alias yt_dl_audio_uncompressed="yt-dlp -x --audio-quality 0 --audio-format wav -o '$path_prefix/%(title)s.%(ext)s'"
alias yt_dl_audio="yt-dlp -x --audio-quality 5 --audio-format best -o '$path_prefix/%(title)s.%(ext)s'"

alias yt_dl_update="yt-dlp -U"

