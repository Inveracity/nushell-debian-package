use std log

export def main [version: string] {
    let base_dir = $"nushell_($version)"
    let debian_dir = $"nushell_($version)/DEBIAN"
    let outdir = $"($base_dir)/usr/local/bin"
    let archive = $"nu-($version)-x86_64-linux-gnu-full.tar.gz"
    let extracted_folder = $"nu-($version)-x86_64-linux-gnu-full"
    let url = $"https://github.com/nushell/nushell/releases/download/($version)/($archive)"
    let year = date now | date to-record | get year

    log info $"Creating directory ($outdir)"
    if not ($outdir | path exists) {
        mkdir $outdir
    }
    log info $"Creating directory ($debian_dir)"
    if not ($debian_dir | path exists) {
        mkdir $debian_dir
    }

    log info "Rendering templates"
    render_templates --dir $base_dir --version $version --year $year

    log info "downloading"
    let tmpdir = mktemp -d
    let downloaded_archive = download --path $tmpdir $url

    log info "extracting"
    extract --archive $downloaded_archive --tmpdir $tmpdir

    log info "moving files"
    mv $"($tmpdir)/($extracted_folder)/*" $outdir

    log info "cleaning up downloaded archive"
    rm -rf $tmpdir

    log info $"building debian package ($base_dir).deb"
    ^dpkg-deb --build $base_dir

    log info "validating output"
    ^dpkg-deb --info $"($base_dir).deb"
    ^dpkg-deb --contents $"($base_dir).deb"

    log info "cleaning up build files"
    rm --permanent --recursive $base_dir

    log info "done"
}

def extract [--archive: string, --tmpdir: string]: nothing -> nothing {
    ^tar xzf $archive -C $tmpdir
}

# Downloads a file and returns the path where the file was downloaded
def download [url: string, --path: path] {
    # Use the URL to create a filepath to save the downloaded file to
    let filename = $url | split row "/" | last
    let outpath = $path | path join $filename

    http get --max-time 3600 $url | save $outpath

    return $outpath
}

# Render_templates opens the template files and replaces the %YEAR% and %VERSION% strings and saves them
def render_templates [--dir: string, --version: string, --year: int] {
    let chglog = open templates/DEBIAN/changelog
    let control = open templates/DEBIAN/control
    let copyright = open templates/DEBIAN/copyright

    $chglog | str replace "%VERSION%" $version | save -f ($dir | path join "DEBIAN/changelog")
    $control | str replace "%VERSION%" $version | save -f ($dir | path join "DEBIAN/control")
    $copyright | str replace "%YEAR%" $"($year)" | save -f ($dir | path join "DEBIAN/copyright")

    cp templates/DEBIAN/postinst ($dir | path join "DEBIAN/postinst")
    cp templates/DEBIAN/postrm ($dir | path join "DEBIAN/postrm")
}
