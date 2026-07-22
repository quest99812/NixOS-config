# Edit this configuration file to define what should be installed on
# your system.
# Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).
{ config, pkgs, ... }:

let
  # custom sddm astronaut package with a selected theme
  custom-sddm-astronaut = pkgs.sddm-astronaut.override {
    embeddedTheme = "hyprland_kath";
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # nvidia drivers
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia.modesetting.enable = true;
  hardware.nvidia.open = true;
  hardware.nvidia.prime = {
    sync.enable = true;

    # integrated
    amdgpuBusId = "PCI:5:0:0";
    # dedicated
    nvidiaBusId = "PCI:1:0:0";
  };

  # automatic updates
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "daily";
  # automatic cleanup
  nix.gc.automatic = true;
  nix.gc.dates = "daily";
  nix.gc.options = "--delete-older-than 10d";
  nix.settings.auto-optimise-store = true;

  # enable plymouth
  boot.plymouth = {
    enable = true;
    theme = "blahaj";
    themePackages = [ pkgs.plymouth-blahaj-theme ];
  };

  # KMS for nvidia gpu and amdgpu
  boot.initrd.kernelModules = [ "amdgpu" "nvidia" "nvidia_modeset" "nvidia_uvm" "nvidia_drm" ];
  # extra packages on boot
  boot.extraModulePackages = [ config.boot.kernelPackages.nvidia_x11 ];
  # Mandatory kernel parameter to allow the DRM driver to modeset early
  boot.kernelParams = [ "nvidia-drm.modeset=1" ];

  # Bootloader
  boot.loader = {
    limine = {
      enable = true;
      efiSupport = true;
      maxGenerations = 3;
    };
    efi.canTouchEfiVariables = true;
  };

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Define your hostname.
  networking.hostName = "NixOS_MAXXING";

  # Enable networking
  networking.networkmanager.enable = true;
  # firewall config
  networking.firewall = {
    enable = true;
    allowedTCPPorts = [ 53317 ];
    allowedUDPPorts = [ 53317 ];
  };

  # enable flatpak support
  services.flatpak.enable = true;
  # enable fish shell
  programs.fish.enable = true;

  # Enable bluetooth and make it start on boot
  hardware.bluetooth.enable = true;
  hardware.bluetooth.powerOnBoot = true;

  # enable openrazer
  hardware.openrazer.enable = true;
  hardware.openrazer.users = ["tomasz"];
  # enable standard steam
  programs.steam = {
    enable = true;
    gamescopeSession.enable = true;
  };
  programs.gamemode.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Warsaw";

  #firmware updates
  hardware.enableRedistributableFirmware = true;

  # Select internationalisation properties.
  i18n.defaultLocale = "pl_PL.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pl_PL.UTF-8";
    LC_IDENTIFICATION = "pl_PL.UTF-8";
    LC_MEASUREMENT = "pl_PL.UTF-8";
    LC_MONETARY = "pl_PL.UTF-8";
    LC_NAME = "pl_PL.UTF-8";
    LC_NUMERIC = "pl_PL.UTF-8";
    LC_PAPER = "pl_PL.UTF-8";
    LC_TELEPHONE = "pl_PL.UTF-8";
    LC_TIME = "pl_PL.UTF-8";
  };
  services.xserver.enable = true;
  # sddm astronaut
  services.desktopManager.plasma6.enable = true;
  services.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut-theme";
    extraPackages = [ custom-sddm-astronaut ];
  };
  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "pl";
    variant = "";
  };
  # Configure console keymap
  console.keyMap = "pl2";
  # Enable CUPS
  services.printing = {
    enable = true;
    drivers = with pkgs; [ brlaser ];
  };
  # Enable Avahi for network printer auto-discovery over Wi-Fi
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  # enable experimental features
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account.
  users.users."tomasz" = {
    isNormalUser = true;
    description = "tomasz";
    extraGroups = [ "networkmanager" "wheel" "openrazer" "adbusers" ];
    packages = with pkgs; [
      kdePackages.kate
      floorp-bin
      flatpak
      gimp
      bluez
      fish
      fastfetch
      mpv
      signal-desktop
      pywal
      ghostty
      imagemagick
      localsend
      obs-studio
      yt-dlp
      tmux
      wine
      protontricks
      libreoffice-fresh
      github-cli
      kdePackages.kcalc
      kdePackages.kdenlive
      kdePackages.plasma-workspace
      gcc
      handbrake
      unrar
      qbittorrent
      android-tools
      universal-android-debloater
    ];
    shell = pkgs.fish;
  };

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
  environment.systemPackages = with pkgs; [
    vim
    wget
    polychromatic
    git
    mangohud
    protonup-ng
    plymouth
    plymouth-blahaj-theme
    custom-sddm-astronaut
    (pkgs.writeShellScriptBin "btop" ''
      exec env LD_LIBRARY_PATH=/run/opengl-driver/lib:${pkgs.btop}/lib ${pkgs.btop}/bin/btop "$@"
    '') #btop that can read gpu's usage
  ];

  system.stateVersion = "26.05";
}
