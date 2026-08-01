#!/usr/bin/env bash
set -euo pipefail

unset GH_TOKEN GITHUB_TOKEN GH_ENTERPRISE_TOKEN GITHUB_ENTERPRISE_TOKEN

readonly DOTFILES_REMOTE="https://github.com/ensia96/dotfiles.git"
readonly DOTFILES_BRANCH="main"
readonly BREW_BIN="/opt/homebrew/bin/brew"
readonly GH_BIN="/opt/homebrew/bin/gh"
readonly TAILSCALE_BIN="/opt/homebrew/bin/tailscale"
readonly TAILSCALE_SERVICE="system/homebrew.mxcl.tailscale"
readonly ITERM_PREFERENCES="$HOME/.config/com.googlecode.iterm2.plist"
readonly NVIM_DATA_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/nvim"
readonly PLUG_VIM="$NVIM_DATA_DIR/site/autoload/plug.vim"
readonly COPILOT_PLUGIN="$NVIM_DATA_DIR/plugged/copilot.vim/plugin/copilot.vim"

FONT_NAMES=(
  "MesloLGS NF Regular.ttf"
  "MesloLGS NF Bold.ttf"
  "MesloLGS NF Italic.ttf"
  "MesloLGS NF Bold Italic.ttf"
)
readonly -a FONT_NAMES

TMP_DIR="$(mktemp -d "$HOME/.dotfiles-install.XXXXXX")"
readonly TMP_DIR
TTY_OPEN=0
trap '/bin/rm -R -- "$TMP_DIR" || true' EXIT

log() { printf '\n==> %s\n' "$*"; }
die() { printf '오류: %s\n' "$*" >&2; exit 1; }
download() {
  local url=$1 destination=$2
  curl --fail --silent --show-error --location --retry 3 \
    --output "$destination" "$url"
  [[ -s "$destination" ]] || die "다운로드한 파일이 비어 있습니다: $url"
}
open_tty() {
  [[ "$TTY_OPEN" -eq 1 ]] && return 0
  [[ -r /dev/tty && -w /dev/tty ]] || return 1
  if { exec 3<>/dev/tty; } 2>/dev/null; then
    TTY_OPEN=1
    return 0
  fi
  return 1
}
require_tty() { open_tty || die "$1"; }
ensure_sudo() {
  /usr/bin/sudo -n true 2>/dev/null && return 0
  require_tty "필수 시스템 설정에 sudo 인증이 필요하지만 TTY가 없습니다."
  /usr/bin/sudo -v <&3 >&3 2>&3 || die "sudo 인증에 실패했습니다."
}
normalize_value() {
  local value=$1
  value="${value//$'\r'/}"
  value="${value//$'\n'/}"
  while [[ "$value" == [[:space:]]* ]]; do value="${value#?}"; done
  while [[ "$value" == *[[:space:]] ]]; do value="${value%?}"; done
  printf '%s' "$value"
}
json_field() {
  local value
  value="$(/usr/bin/plutil -extract "$2" raw -o - "$1" 2>/dev/null || true)"
  normalize_value "$value"
}
install_file_atomically() {
  local source=$1 destination=$2 directory staged
  directory="${destination%/*}"
  staged="$(mktemp "$directory/.dotfiles-install.XXXXXX")"
  if ! /usr/bin/install -m 0644 "$source" "$staged"; then
    /bin/rm -f -- "$staged"
    die "파일을 준비하지 못했습니다: $destination"
  fi
  if ! /bin/mv -n -- "$staged" "$destination"; then
    /bin/rm -f -- "$staged"
    die "파일을 설치하지 못했습니다: $destination"
  fi
  if [[ -e "$staged" || -L "$staged" ]]; then
    /bin/rm -f -- "$staged"
    die "기존 파일을 덮어쓰지 않습니다: $destination"
  fi
}
move_staged_directory() {
  local staged=$1 destination=$2
  [[ ! -e "$destination" && ! -L "$destination" ]] \
    || die "기존 경로를 덮어쓰지 않습니다: $destination"
  /bin/mv -n -- "$staged" "$destination" \
    || die "설치 디렉터리를 이동하지 못했습니다: $destination"
  [[ ! -e "$staged" && ! -L "$staged" ]] \
    || die "설치 중 대상 경로가 생겼습니다: $destination"
}
origin_is_expected() {
  local origin=${1%.git}
  [[ "$origin" == "https://github.com/ensia96/dotfiles" ||
     "$origin" == "git@github.com:ensia96/dotfiles" ||
     "$origin" == "ssh://git@github.com/ensia96/dotfiles" ]]
}
check_prerequisites() {
  [[ "$(uname -s)" == "Darwin" ]] || die "macOS에서 실행해야 합니다."
  [[ "$(uname -m)" == "arm64" ]] || die "Apple Silicon arm64에서 실행해야 합니다."
  [[ -x /bin/zsh ]] || die "macOS 기본 /bin/zsh를 찾을 수 없습니다."
  [[ -x /usr/bin/plutil ]] || die "macOS plutil을 찾을 수 없습니다."
  if ! /usr/bin/xcode-select -p >/dev/null 2>&1; then
    /usr/bin/xcode-select --install >/dev/null 2>&1 || true
    die "Command Line Tools 설치를 마친 뒤 다시 실행하세요."
  fi
  command -v git >/dev/null 2>&1 || die "Git을 찾을 수 없습니다."
  command -v curl >/dev/null 2>&1 || die "curl을 찾을 수 없습니다."
}
setup_dotfiles() {
  local root origin git_dir bootstrap_marker
  log "Dotfiles"
  if [[ -e "$HOME/.git" || -L "$HOME/.git" ]]; then
    root="$(git -C "$HOME" rev-parse --show-toplevel 2>/dev/null)" \
      || die "$HOME/.git이 유효한 저장소가 아닙니다."
    [[ "$root" == "$HOME" ]] || die "$HOME이 기존 저장소의 root가 아닙니다: $root"
    git_dir="$(git -C "$HOME" rev-parse --absolute-git-dir 2>/dev/null)" \
      || die "홈 Git metadata 경로를 확인하지 못했습니다."
    bootstrap_marker="$git_dir/dotfiles-bootstrap-in-progress"
    if git -C "$HOME" rev-parse --verify HEAD >/dev/null 2>&1; then
      [[ ! -e "$bootstrap_marker" ]] \
        || die "이전 checkout이 강제 종료된 흔적이 있습니다. 홈 worktree를 확인한 뒤 marker를 직접 정리하세요."
      verify_home_repo
      log "기존 dotfiles 저장소를 그대로 사용합니다"
      return
    fi
    if origin="$(git -C "$HOME" remote get-url origin 2>/dev/null)"; then
      origin_is_expected "$origin" \
        || die "미완성 홈 저장소의 origin이 예상 dotfiles 저장소와 다릅니다."
    else
      git -C "$HOME" remote add origin "$DOTFILES_REMOTE"
    fi
    log "중단된 dotfiles bootstrap을 다시 시도합니다"
  else
    git -C "$HOME" init
    git -C "$HOME" remote add origin "$DOTFILES_REMOTE"
    git_dir="$(git -C "$HOME" rev-parse --absolute-git-dir)"
    bootstrap_marker="$git_dir/dotfiles-bootstrap-in-progress"
  fi
  git -C "$HOME" fetch --no-tags origin \
    "refs/heads/$DOTFILES_BRANCH:refs/remotes/origin/$DOTFILES_BRANCH"
  : >"$bootstrap_marker"
  if git -C "$HOME" show-ref --verify --quiet "refs/heads/$DOTFILES_BRANCH"; then
    git -C "$HOME" checkout --no-overwrite-ignore "$DOTFILES_BRANCH" \
      || die "기존 홈 파일과 충돌했습니다. 파일을 백업·이동한 뒤 다시 실행하세요."
  else
    git -C "$HOME" checkout --no-overwrite-ignore -b "$DOTFILES_BRANCH" \
      --track "origin/$DOTFILES_BRANCH" \
      || die "기존 홈 파일과 충돌했습니다. 파일을 백업·이동한 뒤 다시 실행하세요."
  fi
  /bin/rm -f -- "$bootstrap_marker"
}
setup_homebrew() {
  local installer="$TMP_DIR/homebrew-install.sh"
  local shellenv
  log "Homebrew와 Brewfile"
  if [[ ! -x "$BREW_BIN" ]] || ! "$BREW_BIN" --version >/dev/null 2>&1; then
    require_tty "Homebrew 설치가 필요하지만 TTY가 없습니다."
    download "https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh" "$installer"
    /bin/bash -n "$installer"
    /bin/bash "$installer" <&3 >&3 2>&3
  fi
  [[ -x "$BREW_BIN" ]] && "$BREW_BIN" --version >/dev/null 2>&1 \
    || die "Homebrew 설치를 확인하지 못했습니다."
  shellenv="$("$BREW_BIN" shellenv)" \
    || die "Homebrew shellenv를 생성하지 못했습니다."
  eval "$shellenv"
  [[ -f "$HOME/Brewfile" ]] || die "$HOME/Brewfile을 찾을 수 없습니다."
  "$BREW_BIN" bundle install --no-upgrade --file="$HOME/Brewfile"
}
valid_git_install() {
  local directory=$1 marker=$2 root expected
  [[ ! -L "$directory" && -d "$directory" && -s "$marker" ]] || return 1
  expected="$(cd "$directory" && pwd -P)" || return 1
  root="$(git -C "$directory" rev-parse --show-toplevel 2>/dev/null)" || return 1
  [[ "$root" == "$expected" ]] || return 1
  git -C "$directory" rev-parse --verify HEAD >/dev/null 2>&1
}
install_oh_my_zsh() {
  local destination="$HOME/.oh-my-zsh"
  local staged="$TMP_DIR/oh-my-zsh"
  local installer="$TMP_DIR/oh-my-zsh-install.sh"
  log "Oh My Zsh"
  if [[ -e "$destination" || -L "$destination" ]]; then
    valid_git_install "$destination" "$destination/oh-my-zsh.sh" \
      || die "$destination가 불완전하거나 예상한 설치와 다릅니다. 자동 삭제하지 않습니다."
    return
  fi
  download "https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh" "$installer"
  /bin/sh -n "$installer"
  ZSH="$staged" RUNZSH=no CHSH=no KEEP_ZSHRC=yes /bin/sh "$installer" --unattended
  valid_git_install "$staged" "$staged/oh-my-zsh.sh" \
    || die "Oh My Zsh 설치 결과가 유효하지 않습니다."
  move_staged_directory "$staged" "$destination"
  [[ -s "$destination/oh-my-zsh.sh" ]] || die "Oh My Zsh 최종 marker가 없습니다."
}
install_powerlevel10k() {
  local destination="$HOME/powerlevel10k"
  local staged="$TMP_DIR/powerlevel10k"
  log "Powerlevel10k"
  if [[ -e "$destination" || -L "$destination" ]]; then
    valid_git_install "$destination" "$destination/powerlevel10k.zsh-theme" \
      || die "$destination가 불완전하거나 예상한 설치와 다릅니다. 자동 삭제하지 않습니다."
    return
  fi
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$staged"
  valid_git_install "$staged" "$staged/powerlevel10k.zsh-theme" \
    || die "Powerlevel10k 설치 결과가 유효하지 않습니다."
  move_staged_directory "$staged" "$destination"
  [[ -s "$destination/powerlevel10k.zsh-theme" ]] || die "Powerlevel10k 최종 marker가 없습니다."
}
install_fonts() {
  local directory="$HOME/Library/Fonts"
  local font destination downloaded
  log "Powerlevel10k 공식 MesloLGS NF 폰트"
  [[ ! -L "$directory" ]] || die "$directory가 symbolic link라서 중단합니다."
  [[ ! -e "$directory" || -d "$directory" ]] || die "$directory가 디렉터리가 아닙니다."
  mkdir -p "$directory"
  for font in "${FONT_NAMES[@]}"; do
    destination="$directory/$font"
    if [[ -e "$destination" || -L "$destination" ]]; then
      [[ -f "$destination" && -s "$destination" ]] \
        || die "불완전한 기존 폰트 파일을 자동으로 덮어쓰지 않습니다: $destination"
      continue
    fi
    downloaded="$TMP_DIR/$font"
    download "https://raw.githubusercontent.com/romkatv/powerlevel10k-media/master/${font// /%20}" \
      "$downloaded"
    install_file_atomically "$downloaded" "$destination"
  done
}
install_neovim_plugins() {
  local directory="${PLUG_VIM%/*}"
  local downloaded="$TMP_DIR/plug.vim"
  log "vim-plug와 Neovim 플러그인"
  if [[ -e "$PLUG_VIM" || -L "$PLUG_VIM" ]]; then
    [[ -f "$PLUG_VIM" && -s "$PLUG_VIM" ]] \
      || die "불완전한 vim-plug 파일을 자동으로 덮어쓰지 않습니다: $PLUG_VIM"
  else
    [[ ! -L "$directory" ]] || die "$directory가 symbolic link라서 중단합니다."
    [[ ! -e "$directory" || -d "$directory" ]] || die "$directory가 디렉터리가 아닙니다."
    mkdir -p "$directory"
    download "https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim" "$downloaded"
    install_file_atomically "$downloaded" "$PLUG_VIM"
  fi
  command -v nvim >/dev/null 2>&1 || die "Brewfile 적용 후에도 nvim을 찾을 수 없습니다."
  nvim --headless '+PlugInstall --sync' +qa
  [[ -s "$COPILOT_PLUGIN" ]] || die "Copilot 플러그인 설치를 확인하지 못했습니다."
}
iterm_ready() {
  local folder load
  [[ -s "$ITERM_PREFERENCES" ]] || return 1
  folder="$(/usr/bin/defaults read com.googlecode.iterm2 PrefsCustomFolder 2>/dev/null || true)"
  load="$(/usr/bin/defaults read com.googlecode.iterm2 LoadPrefsFromCustomFolder 2>/dev/null || true)"
  [[ "$folder" == "$HOME/.config" && "$load" == "1" ]]
}
configure_iterm() {
  log "iTerm custom preferences"
  [[ -s "$ITERM_PREFERENCES" ]] || die "$ITERM_PREFERENCES를 찾을 수 없습니다."
  iterm_ready && return
  /usr/bin/pgrep -x iTerm2 >/dev/null 2>&1 \
    && die "iTerm2를 종료한 뒤 다시 실행하세요. 설정 파일은 건드리지 않았습니다."
  /usr/bin/defaults write com.googlecode.iterm2 PrefsCustomFolder -string "$HOME/.config"
  /usr/bin/defaults write com.googlecode.iterm2 LoadPrefsFromCustomFolder -bool true
  iterm_ready || die "iTerm custom preferences 적용을 확인하지 못했습니다."
}
github_authenticated() { "$GH_BIN" auth status --active --hostname github.com >/dev/null 2>&1; }
setup_git_identity() {
  local current_name current_email profile
  local github_name github_login github_email github_id
  current_name="$(normalize_value "$(git config --global --get user.name 2>/dev/null || true)")"
  current_email="$(normalize_value "$(git config --global --get user.email 2>/dev/null || true)")"
  if [[ -n "$current_name" && -n "$current_email" ]]; then
    return
  fi
  profile="$TMP_DIR/github-profile.json"
  "$GH_BIN" api --hostname github.com /user --jq '{name,login,email,id}' \
    >"$profile" 2>/dev/null \
    || die "GitHub 프로필을 조회하지 못했습니다. Git identity를 추측해 저장하지 않습니다."
  github_name="$(json_field "$profile" name)"
  github_login="$(json_field "$profile" login)"
  github_email="$(json_field "$profile" email)"
  github_id="$(json_field "$profile" id)"
  [[ -n "$github_login" && "$github_id" =~ ^[0-9]+$ ]] \
    || die "GitHub 프로필의 필수 필드를 확인하지 못했습니다."
  if [[ -z "$current_name" ]]; then
    git config --global user.name "${github_name:-$github_login}"
  fi
  if [[ -z "$current_email" ]]; then
    git config --global user.email \
      "${github_email:-${github_id}+${github_login}@users.noreply.github.com}"
  fi
}
setup_github() {
  log "GitHub 인증과 Git identity"
  [[ -x "$GH_BIN" ]] || die "Brewfile 적용 후에도 gh를 찾을 수 없습니다."
  if ! github_authenticated; then
    require_tty "GitHub 인증이 필요하지만 TTY가 없습니다."
    "$GH_BIN" auth login --hostname github.com --git-protocol https --web \
      <&3 >&3 2>&3 || die "GitHub 인증에 실패했습니다."
  fi
  github_authenticated || die "지속 가능한 GitHub 인증을 확인하지 못했습니다."
  "$GH_BIN" auth setup-git --hostname github.com >/dev/null 2>&1 \
    || die "GitHub Git credential helper 설정에 실패했습니다."
  git config --global --get-all credential.https://github.com.helper >/dev/null 2>&1 \
    || die "GitHub Git credential helper를 확인하지 못했습니다."
  setup_git_identity
  [[ -n "$(normalize_value "$(git config --global --get user.name 2>/dev/null || true)")" ]] \
    || die "global Git user.name이 비어 있습니다."
  [[ -n "$(normalize_value "$(git config --global --get user.email 2>/dev/null || true)")" ]] \
    || die "global Git user.email이 비어 있습니다."
}
tailscale_state() {
  local state
  state="$(
    /usr/bin/sudo -n "$TAILSCALE_BIN" status --json --peers=false 2>/dev/null |
      /usr/bin/plutil -extract BackendState raw -o - - 2>/dev/null
  )" || state=""
  printf '%s\n' "${state:-NoState}"
}
wait_tailscale_state() {
  local state attempt
  for ((attempt = 0; attempt < 30; attempt += 1)); do
    state="$(tailscale_state)"
    case "$state" in
      Starting|NoState|"") /bin/sleep 1 ;;
      *) printf '%s\n' "$state"; return ;;
    esac
  done
  die "Tailscale daemon이 30초 안에 준비되지 않았습니다."
}
check_tailscale_conflicts() {
  local uid
  uid="$(/usr/bin/id -u)"
  if [[ -e /Applications/Tailscale.app || -L /Applications/Tailscale.app ||
        -e "$HOME/Applications/Tailscale.app" || -L "$HOME/Applications/Tailscale.app" ||
        -e "$HOME/Library/LaunchAgents/homebrew.mxcl.tailscale.plist" ||
        -L "$HOME/Library/LaunchAgents/homebrew.mxcl.tailscale.plist" ]] ||
     /usr/bin/pgrep -x Tailscale >/dev/null 2>&1 ||
     /usr/bin/pgrep -u "$uid" -x tailscaled >/dev/null 2>&1 ||
     /bin/launchctl print "gui/$uid/homebrew.mxcl.tailscale" >/dev/null 2>&1; then
    die "Tailscale GUI 또는 user daemon이 감지되었습니다. root formula service와 함께 사용하지 않습니다."
  fi
}
setup_tailscale() {
  local state attempt
  log "Tailscale root service와 인증"
  [[ -x "$TAILSCALE_BIN" ]] || die "Brewfile 적용 후에도 tailscale을 찾을 수 없습니다."
  check_tailscale_conflicts
  if ! /bin/launchctl print "$TAILSCALE_SERVICE" >/dev/null 2>&1; then
    require_tty "Tailscale root service 시작에 TTY가 필요합니다."
    ensure_sudo
    /usr/bin/sudo -n "$BREW_BIN" services start tailscale <&3 >&3 2>&3 \
      || die "Tailscale root service를 시작하지 못했습니다."
  fi
  ensure_sudo
  for ((attempt = 0; attempt < 2; attempt += 1)); do
    state="$(wait_tailscale_state)"
    case "$state" in
      Running) return ;;
      NeedsLogin|Stopped)
        [[ "$attempt" -eq 0 ]] || die "Tailscale이 인증 후에도 Running 상태가 아닙니다: $state"
        require_tty "Tailscale 인증이 필요하지만 TTY가 없습니다."
        /usr/bin/sudo -n "$TAILSCALE_BIN" up <&3 >&3 2>&3 \
          || die "Tailscale 인증에 실패했습니다."
        ;;
      NeedsMachineAuth)
        die "Tailscale 장치 승인이 필요합니다. 관리자 승인 후 다시 실행하세요."
        ;;
      InUseOtherUser)
        die "Tailscale이 다른 사용자 계정으로 사용 중입니다. 계정을 확인하세요."
        ;;
      *) die "지원하지 않는 Tailscale BackendState입니다: $state" ;;
    esac
  done
}
jump_present() {
  "$BREW_BIN" list --cask jump-desktop-connect >/dev/null 2>&1 ||
    /usr/sbin/pkgutil --pkg-info com.p5sys.jump.connect >/dev/null 2>&1 ||
    [[ -d "/Applications/Jump Desktop Connect.app" ]]
}
install_jump() {
  local answer=""
  log "Jump Desktop Connect"
  if jump_present; then
    log "이미 설치되어 있어 건너뜁니다"
    return
  fi
  if ! open_tty; then
    log "TTY가 없어 선택 설치를 건너뜁니다"
    return
  fi
  printf 'Jump Desktop Connect를 설치할까요? [y/N] ' >&3
  IFS= read -r answer <&3 || answer=""
  case "$answer" in
    [Yy]|[Yy][Ee][Ss]) ;;
    *) log "Jump Desktop Connect 설치를 건너뜁니다"; return ;;
  esac
  "$BREW_BIN" install --cask jump-desktop-connect <&3 >&3 2>&3 \
    || die "Jump Desktop Connect 설치에 실패했습니다."
  jump_present || die "Jump Desktop Connect 설치를 확인하지 못했습니다."
}
configure_macos() {
  log "macOS 기본 설정"
  /usr/bin/defaults write com.apple.dock autohide -bool true
  /usr/bin/defaults write com.apple.dock orientation -string right
  /usr/bin/defaults write com.apple.dock tilesize -int 128
  /usr/bin/defaults write com.apple.dock mineffect -string scale
  /usr/bin/defaults write com.apple.dock show-recents -bool false
  /usr/bin/defaults write com.apple.dock wvous-br-corner -int 1
  /usr/bin/defaults write com.apple.dock wvous-br-modifier -int 0
  /usr/bin/defaults write NSGlobalDomain KeyRepeat -int 2
  /usr/bin/defaults write NSGlobalDomain InitialKeyRepeat -int 15
  /usr/bin/defaults write com.apple.AppleMultitouchTrackpad Clicking -bool true
  /usr/bin/defaults write com.apple.driver.AppleBluetoothMultitouch.trackpad Clicking -bool true
  /usr/bin/defaults write com.apple.finder FXPreferredViewStyle -string Nlsv
  /usr/bin/defaults write com.apple.finder NewWindowTarget -string PfAF
  /usr/bin/defaults write com.apple.finder ShowRecentTags -bool false
  /usr/bin/defaults write com.apple.menuextra.clock ShowDate -int 0
  /usr/bin/defaults write com.apple.menuextra.clock ShowSeconds -bool true
  /usr/bin/defaults write com.apple.controlcenter "NSStatusItem Visible Bluetooth" -bool true
  /usr/bin/defaults write com.apple.controlcenter "NSStatusItem Visible Display" -bool true
  /usr/bin/defaults write com.apple.WindowManager EnableStandardClickToShowDesktop -bool false
  /usr/bin/defaults write com.apple.WindowManager EnableTiledWindowMargins -bool false
  /usr/bin/defaults write com.apple.WindowManager EnableTilingByEdgeDrag -bool false
  /usr/bin/defaults write com.apple.WindowManager EnableTopTilingByEdgeDrag -bool false
  /usr/bin/defaults write com.apple.WindowManager StandardHideDesktopIcons -bool true
  /usr/bin/defaults write com.apple.WindowManager HideDesktop -bool true
  /usr/bin/defaults write com.apple.WindowManager AppWindowGroupingBehavior -int 1
  /usr/bin/defaults write NSGlobalDomain AppleInterfaceStyle -string Dark
}
verify_home_repo() {
  local root origin branch
  root="$(git -C "$HOME" rev-parse --show-toplevel 2>/dev/null)" \
    || die "홈 Git 저장소를 검증하지 못했습니다."
  [[ "$root" == "$HOME" ]] || die "홈 Git repository root가 다릅니다."
  origin="$(git -C "$HOME" remote get-url origin 2>/dev/null)" \
    || die "홈 Git origin을 검증하지 못했습니다."
  origin_is_expected "$origin" || die "홈 Git origin이 예상과 다릅니다."
  git -C "$HOME" rev-parse --verify HEAD >/dev/null 2>&1 \
    || die "홈 Git HEAD가 유효하지 않습니다."
  branch="$(git -C "$HOME" symbolic-ref --quiet --short HEAD)" \
    || die "홈 Git 저장소가 detached HEAD 상태입니다."
  [[ "$branch" == "$DOTFILES_BRANCH" ]] || die "홈 Git branch가 main이 아닙니다."
}
verify_installation() {
  log "설치 상태 검증"
  verify_home_repo
  "$BREW_BIN" bundle check --no-upgrade --file="$HOME/Brewfile" >/dev/null \
    || die "Brewfile 패키지가 모두 설치되지 않았습니다."
  nvim --headless \
    '+if exists("g:plugs") && empty(filter(values(g:plugs), "!isdirectory(v:val.dir)")) | qall | else | cquit | endif' \
    >/dev/null 2>&1 || die "Neovim 플러그인 디렉터리가 모두 준비되지 않았습니다."
}
print_manual_steps() {
  local filevault_status

  printf '\n완료했습니다. 남은 수동 설정:\n'
  printf '%s\n' '- OpenCode 첫 사용 시: opencode auth login'
  printf '%s\n' '- Neovim Copilot: :Copilot setup'
  printf '%s\n' '- Chrome 로그인은 선택'
  if jump_present; then
    printf '%s\n' '- Jump Desktop Connect 로그인과 손쉬운 사용·화면 기록 권한 확인'
  fi
  if /usr/bin/fdesetup isactive >/dev/null 2>&1; then
    filevault_status=0
  else
    filevault_status=$?
  fi
  case "$filevault_status" in
    0) ;;
    1) printf '%s\n' '- FileVault가 꺼져 있습니다. 시스템 설정에서 활성화 여부를 결정하세요.' ;;
    2) printf '%s\n' '- FileVault 작업이 진행 중입니다. 완료 후 상태를 확인하세요.' ;;
    *) printf '%s\n' '- FileVault 상태를 확인하지 못했습니다. 시스템 설정에서 직접 확인하세요.' ;;
  esac
}
main() {
  check_prerequisites
  setup_dotfiles
  setup_homebrew
  install_oh_my_zsh
  install_powerlevel10k
  install_fonts
  install_neovim_plugins
  configure_iterm
  configure_macos
  setup_github
  setup_tailscale
  install_jump
  verify_installation
  print_manual_steps
}
main "$@"
