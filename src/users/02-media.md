# Text

The main type of content in Lemmy is text which can be formatted with Markdown. Refer to the table below for supported formatting rules. The Lemmy user interface also provides buttons for formatting, so it's not necessary to remember all of it. You can also follow the interactive [CommonMark tutorial](https://commonmark.org/help/tutorial/) to get started.

| Type                                                                                     | Or                                                                             | … to Get                                                                                             |
| ---------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------- |
| \*Italic\*                                                                               | \_Italic\_                                                                     | _Italic_                                                                                             |
| \*\*Bold\*\*                                                                             | \_\_Bold\_\_                                                                   | **Bold**                                                                                             |
| \# Heading 1                                                                             | Heading 1 <br> =========                                                       | <h4>Heading 1</h4>                                                                                   |
| \## Heading 2                                                                            | Heading 2 <br>---------                                                        | <h5>Heading 2</h5>                                                                                   |
| \[Link\](http://a.com)                                                                   | \[Link\]\[1\]<br>⋮ <br>\[1\]: http://b.org                                     | [Link](https://commonmark.org/)                                                                      |
| !\[Image\](http://url/a.png)                                                             | !\[Image\]\[1\]<br>⋮ <br>\[1\]: http://url/b.jpg                               | ![Markdown](https://commonmark.org/help/images/favicon.png)                                          |
| \> Blockquote                                                                            |                                                                                | <blockquote>Blockquote</blockquote>                                                                  |
| \* List <br>\* List <br>\* List                                                          | \- List <br>\- List <br>\- List <br>                                           | <ul><li>List</li><li>List</li><li>List</li></ul>                                                     |
| 1\. One <br>2\. Two <br>3\. Three                                                        | 1) One<br>2) Two<br>3) Three                                                   | <ol><li>One</li><li>Two</li><li>Three</li></ol>                                                      |
| Horizontal Rule <br>\---                                                                 | Horizontal Rule<br>\*\*\*                                                      | Horizontal Rule <br><hr>                                                                             |
| \`Inline code\` with backticks                                                           |                                                                                | `Inline code` with backticks                                                                         |
| \`\`\`<br>\# code block <br>print '3 backticks or'<br>print 'indent 4 spaces' <br>\`\`\` | ····\# code block<br>····print '3 backticks or'<br>····print 'indent 4 spaces' | <pre><code># code block<br>print '3 backticks or'<br>print 'indent 4 spaces'</code></pre>            |
| ::: spoiler hidden or nsfw stuff<br>_a bunch of spoilers here_<br>:::                    |                                                                                | <details><summary> hidden or nsfw stuff </summary><p><em>a bunch of spoilers here</em></p></details> |
| Some \~subscript\~ text                                                                  |                                                                                | Some <sub>subscript</sub> text                                                                       |
| Some \^superscript\^ text                                                                |                                                                                | Some <sup>superscript</sup> text                                                                     |
| \~\~Strikethrough\~\~                                                                    |                                                                                | Some ~removed~ text                                                                                  |

[CommonMark Tutorial](https://commonmark.org/help/tutorial/)

# Images and Video

Lemmy also allows sharing of images and videos. To upload an image, go to the _Create post_ page and click the little image icon under the _URL_ field. This allows you to select a local image. If you made a mistake, a popup message allows you to delete the image. The same image button also allows uploading of videos in .gif format. Instead of uploading a local file, you can also simply paste the URL of an image or video from another website.

Note that this functionality is not meant to share large images or videos, because that would require too many server resources. Instead, upload them on another platform like [PeerTube](https://joinpeertube.org/) or [Pixelfed](https://pixelfed.org/), and share the link on Lemmy.

# Torrents

Since Lemmy doesn't host large videos or other media, users can share files using [BitTorrent](https://en.wikipedia.org/wiki/BitTorrent) links. In BitTorrent, files are shared not by a single user, but by _many users_ at the same time. This makes file sharing efficient, fast, and reliable, as long as several sources are sharing the files.

Lemmy supports posting torrent magnet links (links that start with `magnet:`) in the post _URL_ field, or as Markdown links within comments.

With this, Lemmy can serve as an alternative to centralized media-centric services like YouTube and Spotify.

## How to Watch Torrents

### Beginner

To easily stream videos and audio on Lemmy, you can use any of the following apps. After clicking on a torrent link in Lemmy, a dialog will pop up asking you to open the link in the app.

- [Stremio](https://www.stremio.com/) (Desktop, Android)
- [WebTorrent Desktop](https://webtorrent.io/desktop/) (Desktop)
- [Popcorn Time](https://github.com/popcorn-official/popcorn-desktop) (Desktop)
- [xTorrent](https://play.google.com/store/apps/details?id=com.gamemalt.streamtorrentvideos) (Android)

### Expert

For those who would like to help share files, you can use any of the following torrent clients.

- [qBittorrent](https://qbittorrent.org/) (Desktop)
- [Deluge](https://www.deluge-torrent.org/) (Desktop)
- [Transmission](https://transmissionbt.com/) (Desktop)
- [LibreTorrent](https://gitlab.com/proninyaroslav/libretorrent) (Android)

If you'd like, you can also set up a media server to view this content on any device. Some good options are:

- [Jellyfin](https://jellyfin.org/) (Movies, TV, Music, Audiobooks)
- [Navidrome](https://www.navidrome.org/) (Music)

## How do I convert a youtube video to a torrent?

There are _many_ possible ways to do this, this is only one example. It requires:

- [yt-dlp](https://github.com/yt-dlp/yt-dlp) (To download the youtube videos locally)
- [transmission-cli](https://transmissionbt.com/) (To create a `.torrent` file from the command line)
- [qbittorrent-cli](https://github.com/ludviglundgren/qbittorrent-cli) (A command line tool to add this torrent to any qbitttorrent server)

You can use the following script below, pasting in a youtube link.

`./my_script "https://youtu.be/VIDEO_URL"`

```
#!/bin/bash
set -e

youtube_url=$1

# Download the video
# The format should be in mkv, not webm, see
# https://github.com/Stremio/stremio-bugs/issues/900
yt-dlp "$1" \
  --remux-video "mkv"

# Create torrents
shopt -s nullglob
for i in *.mp4 *.webm *.mkv; do
  torrent="tmp.torrent"

  # Create it
  transmission-create "$i" -o $torrent \
    -t udp://tracker.coppersurfer.tk:6969/announce \
    -t udp://tracker.internetwarriors.net:1337/announce \
    -t udp://tracker.opentrackr.org:1337/announce

  # Move the video to your download dir
  mv "$i" downloads/

  # Add it to qbittorrent
  qbt torrent add $torrent

  # Print out the magnet link
  echo "Magnet link:"
  transmission-show $torrent -m

  # Remove the tmp torrent
  rm "$torrent"

done
```
