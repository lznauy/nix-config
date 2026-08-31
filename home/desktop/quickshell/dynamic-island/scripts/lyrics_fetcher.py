#!/usr/bin/env python3
import base64
import fcntl
import hashlib
import html
import json
import os
import re
import sys
import time
import unicodedata
import urllib.parse
import urllib.request
from difflib import SequenceMatcher

HEADERS = {
    "User-Agent": "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36",
}
REQUEST_TIMEOUT = 2
NEGATIVE_CACHE_TTL = 10 * 60
CACHE_VERSION = 4
MAX_CACHE_ENTRIES = 256
MIN_CANDIDATE_SCORE = 75
NO_LYRICS = [{"time": 0, "text": "暂无歌词"}]
TIMESTAMP_PATTERN = re.compile(r"\[(\d{1,3}):(\d{2})[\.:](\d{1,3})\]")
VERSION_MARKERS = (
    "live",
    "现场",
    "remix",
    "伴奏",
    "instrumental",
    "cover",
    "翻唱",
    "acoustic",
    "spedup",
    "slowed",
)
CREDIT_PATTERN = re.compile(
    r"^(?:作?词|作?曲|编曲|制作人|制作统筹|音乐制作|配唱制作人|"
    r"吉他(?:/贝斯)?|贝斯|弦乐(?:录音棚|录音师)?|鼓|和声(?:编写)?|"
    r"人声(?:录音师|录音室|编辑)?|录音(?:师|室|棚)?|混音(?:/母带)?|"
    r"母带|出品人(?:/总监制)?|出品|总监制|监制|发行|op|sp|"
    r"written\s+by|composed\s+by|lyrics\s+by|produced\s+by|arranged\s+by)\s*[:：]",
    re.I,
)


def get_cache_path(cache_dir, title, artist):
    safe_name = f"{CACHE_VERSION}\0{title}\0{artist}".encode(
        "utf-8", errors="ignore"
    )
    hash_str = hashlib.md5(safe_name).hexdigest()
    return os.path.join(cache_dir, f"{hash_str}.json")


def get_default_cache_dir():
    cache_home = os.environ.get("XDG_CACHE_HOME")
    if not cache_home:
        cache_home = os.path.join(os.path.expanduser("~"), ".cache")
    return os.path.join(cache_home, "quickshell", "dynamic-island", "lyrics")


def normalize_match_text(value):
    normalized = unicodedata.normalize("NFKC", html.unescape(str(value or ""))).casefold()
    return re.sub(r"[\W_]+", "", normalized, flags=re.UNICODE)


def normalize_artist_names(value):
    values = value if isinstance(value, (list, tuple)) else [value]
    names = []
    for item in values:
        raw_name = str(item or "").strip()
        if not raw_name:
            continue
        names.append(normalize_match_text(raw_name))
        for part in re.split(
            r"[/、,&;；()（）\[\]【】]|\s+(?:feat|ft)\.?\s+",
            raw_name,
            flags=re.I,
        ):
            normalized = normalize_match_text(part)
            if normalized:
                names.append(normalized)
    return list(dict.fromkeys(names))


def candidate_score(title, artist, candidate_title, candidate_artists):
    requested_title = normalize_match_text(title)
    result_title = normalize_match_text(candidate_title)
    if not requested_title or not result_title:
        return 0

    if requested_title == result_title:
        title_score = 70
    elif (
        min(len(requested_title), len(result_title)) >= 3
        and (requested_title in result_title or result_title in requested_title)
    ):
        title_score = 55
    else:
        title_score = 45 * SequenceMatcher(
            None, requested_title, result_title
        ).ratio()

    requested_artists = normalize_artist_names(artist)
    result_artists = normalize_artist_names(candidate_artists)
    artist_score = 0
    if requested_artists:
        similarities = [
            SequenceMatcher(None, requested, result).ratio()
            for requested in requested_artists
            for result in result_artists
        ]
        if any(
            requested == result
            for requested in requested_artists
            for result in result_artists
        ):
            artist_score = 30
        elif similarities and max(similarities) >= 0.9:
            artist_score = 18
    else:
        artist_score = 20

    requested_versions = {
        marker
        for marker in VERSION_MARKERS
        if normalize_match_text(marker) in requested_title
    }
    result_versions = {
        marker for marker in VERSION_MARKERS if normalize_match_text(marker) in result_title
    }
    version_penalty = 20 if requested_versions != result_versions else 0

    return title_score + artist_score - version_penalty


def select_best_candidate(
    title, artist, candidates, title_getter, artists_getter, quality_getter=None
):
    best_candidate = None
    best_score = 0
    for candidate in candidates:
        score = candidate_score(
            title,
            artist,
            title_getter(candidate),
            artists_getter(candidate),
        )
        if quality_getter is not None:
            score += quality_getter(candidate)
        if score > best_score:
            best_candidate = candidate
            best_score = score
    return best_candidate if best_score >= MIN_CANDIDATE_SCORE else None


def clean_leading_metadata(lyrics, title, artist):
    title_key = normalize_match_text(title)
    artist_keys = normalize_artist_names(artist)
    first_lyric_index = 0

    for line in lyrics:
        text = line.get("text", "")
        text_key = normalize_match_text(text)
        is_title_credit = bool(
            title_key
            and title_key in text_key
            and artist_keys
            and any(artist_key in text_key for artist_key in artist_keys)
        )
        if is_title_credit or CREDIT_PATTERN.match(text):
            first_lyric_index += 1
            continue
        break

    if first_lyric_index >= len(lyrics):
        return lyrics

    cleaned = lyrics[first_lyric_index:]
    if cleaned[0]["time"] > 0.5:
        return [{"time": 0, "text": "♪"}, *cleaned]
    return cleaned


def parse_lrc(lrc_text):
    if not lrc_text:
        return []
    lines = []
    lrc_text = html.unescape(lrc_text)

    for line in lrc_text.split("\n"):
        line = line.strip()
        if not line:
            continue
        timestamps = TIMESTAMP_PATTERN.findall(line)
        text = TIMESTAMP_PATTERN.sub("", line).strip()
        if timestamps and text and not text.lower().startswith(
            ("offset:", "by:", "al:", "ti:", "ar:")
        ):
            for minutes_str, seconds_str, fraction in timestamps:
                minutes = int(minutes_str)
                seconds = int(seconds_str)
                milliseconds = int(fraction.ljust(3, "0")[:3])
                total_seconds = minutes * 60 + seconds + milliseconds / 1000
                lines.append({"time": total_seconds, "text": text})

    lines.sort(key=lambda x: x["time"])
    return lines


def request_url(url, data=None, headers=None):
    if headers is None:
        headers = HEADERS
    try:
        req = urllib.request.Request(url, data=data, headers=headers)
        with urllib.request.urlopen(req, timeout=REQUEST_TIMEOUT) as response:
            return json.loads(response.read().decode("utf-8"))
    except Exception:
        return None


def fetch_qq(track, artist):
    qq_headers = HEADERS.copy()
    qq_headers["Referer"] = "https://y.qq.com/"
    try:
        keyword = f"{track} {artist}"
        search_url = (
            "https://c.y.qq.com/soso/fcgi-bin/client_search_cp"
            f"?w={urllib.parse.quote(keyword)}&format=json&p=1&n=10"
        )
        search_data = request_url(search_url, headers=qq_headers)

        songmid = ""
        if (
            search_data
            and "data" in search_data
            and "song" in search_data["data"]
            and "list" in search_data["data"]["song"]
        ):
            song_list = search_data["data"]["song"]["list"]
            song = select_best_candidate(
                track,
                artist,
                song_list,
                lambda item: item.get("songname", ""),
                lambda item: [singer.get("name", "") for singer in item.get("singer", [])],
                lambda item: 3 if item.get("albumname") else 0,
            )
            if song:
                songmid = song.get("songmid", "")

        if not songmid:
            return []

        lyric_url = f"https://c.y.qq.com/lyric/fcgi-bin/fcg_query_lyric_new.fcg?songmid={songmid}&format=json&nobase64=1"
        lyric_data = request_url(lyric_url, headers=qq_headers)

        if lyric_data and "lyric" in lyric_data:
            raw_lrc = lyric_data["lyric"]
            try:
                decoded_lrc = base64.b64decode(raw_lrc).decode("utf-8")
            except Exception:
                decoded_lrc = raw_lrc
            return clean_leading_metadata(parse_lrc(decoded_lrc), track, artist)
    except Exception:
        pass
    return []


def fetch_netease(track, artist):
    search_url = "https://music.163.com/api/search/get/"
    ne_headers = HEADERS.copy()
    ne_headers["Referer"] = "https://music.163.com/"
    post_data = urllib.parse.urlencode(
        {"s": f"{track} {artist}", "type": 1, "offset": 0, "total": "true", "limit": 10}
    ).encode("utf-8")

    try:
        res = request_url(search_url, data=post_data, headers=ne_headers)
        if (
            res
            and "result" in res
            and "songs" in res["result"]
            and res["result"]["songs"]
        ):
            song = select_best_candidate(
                track,
                artist,
                res["result"]["songs"],
                lambda item: item.get("name", ""),
                lambda item: [
                    result_artist.get("name", "")
                    for result_artist in (item.get("artists") or item.get("ar") or [])
                ],
                lambda item: 3 if item.get("album") else 0,
            )
            if not song:
                return []
            song_id = song["id"]
            lyric_url = f"https://music.163.com/api/song/lyric?os=pc&id={song_id}&lv=-1&kv=-1&tv=-1"
            lrc_data = request_url(lyric_url, headers=ne_headers)
            if lrc_data and "lrc" in lrc_data and "lyric" in lrc_data["lrc"]:
                return clean_leading_metadata(
                    parse_lrc(lrc_data["lrc"]["lyric"]), track, artist
                )
    except Exception:
        pass
    return []


def read_cache(cache_file):
    try:
        with open(cache_file, "r", encoding="utf-8") as file:
            cached_data = json.load(file)
        if not cached_data:
            return None
        if cached_data == NO_LYRICS:
            cache_age = time.time() - os.path.getmtime(cache_file)
            if cache_age > NEGATIVE_CACHE_TTL:
                return None
        return cached_data
    except (OSError, ValueError, TypeError):
        return None


def write_cache(cache_file, lyrics):
    temporary_file = f"{cache_file}.{os.getpid()}.tmp"
    try:
        with open(temporary_file, "w", encoding="utf-8") as file:
            json.dump(lyrics, file, ensure_ascii=False)
        os.replace(temporary_file, cache_file)
    finally:
        try:
            os.unlink(temporary_file)
        except FileNotFoundError:
            pass


def prune_cache(cache_dir, keep_file):
    try:
        entries = [
            os.path.join(cache_dir, name)
            for name in os.listdir(cache_dir)
            if name.endswith(".json")
        ]
        entries.sort(key=os.path.getmtime, reverse=True)
        remaining_slots = MAX_CACHE_ENTRIES - 1
        for entry in entries:
            if entry == keep_file:
                continue
            if remaining_slots > 0:
                remaining_slots -= 1
                continue
            try:
                os.unlink(entry)
            except FileNotFoundError:
                pass
    except OSError:
        pass


def load_lyrics(title, artist, cache_dir):
    os.makedirs(cache_dir, exist_ok=True)
    cache_file = get_cache_path(cache_dir, title, artist)

    with open(os.path.join(cache_dir, "cache.lock"), "w", encoding="utf-8") as lock_file:
        fcntl.flock(lock_file, fcntl.LOCK_EX)

        cached_data = read_cache(cache_file)
        if cached_data is not None:
            prune_cache(cache_dir, cache_file)
            return cached_data

        lyrics = fetch_qq(title, artist) or fetch_netease(title, artist) or NO_LYRICS
        write_cache(cache_file, lyrics)
        prune_cache(cache_dir, cache_file)
        return lyrics


def main():
    if len(sys.argv) < 2:
        print(json.dumps([{"time": 0, "text": "等待播放..."}], ensure_ascii=False))
        return

    title = sys.argv[1]
    artist = sys.argv[2] if len(sys.argv) > 2 else ""
    cache_dir = sys.argv[3] if len(sys.argv) > 3 else get_default_cache_dir()
    lyrics = load_lyrics(title, artist, cache_dir)
    print(json.dumps(lyrics, ensure_ascii=False))


if __name__ == "__main__":
    main()
