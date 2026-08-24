{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./network-power.nix
  ];

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.kernelParams = [
    "pcie_pme=nomsi"
    "acpi_backlight=native"
    "snd_hda_intel.dmic_detect=0"
    "amd_pstate=active"
    "radeon.tearfree=1"
    "amdgpu.tearfree=1"
    "reboot=pci"
    "acpi_osi=Linux"
  ];


  networking.hostName = "vlad";
  networking.networkmanager.enable = true;
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  services.blueman.enable = true;
  services.displayManager.lemurs.enable = true;
  services.displayManager.sessionPackages = [ pkgs.niri ];
  services.flatpak.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    wireplumber.enable = true;
  };

  systemd.user.services.mpris-proxy = {
    description = "Mpris proxy for Bluetooth";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "default.target" ];
    serviceConfig.ExecStart = "${pkgs.bluez}/bin/mpris-proxy";
  };

  nixpkgs.config.allowUnfree = true;
  hardware.enableAllFirmware = true;
  hardware.graphics = {
    enable = true;
    enable32Bit = true; 
  };
  
  boot.initrd.kernelModules = [ "amdgpu" ];
  services.xserver.videoDrivers = [ "amdgpu" ];
  systemd.targets.poweroff.enable = true;  
  services.tlp = {
    enable = true;
    settings = {
      WIFI_PWR_ON_AC = "off";
      WIFI_PWR_ON_BAT = "off";
    };
  };

  time.timeZone = "Europe/Moscow";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS = "ru_RU.UTF-8";
    LC_IDENTIFICATION = "ru_RU.UTF-8";
    LC_MEASUREMENT = "ru_RU.UTF-8";
    LC_MONETARY = "ru_RU.UTF-8";
    LC_NAME = "ru_RU.UTF-8";
    LC_NUMERIC = "ru_RU.UTF-8";
    LC_PAPER = "ru_RU.UTF-8";
    LC_TELEPHONE = "ru_RU.UTF-8";
    LC_TIME = "ru_RU.UTF-8";
  };

  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  security.polkit.enable = true;
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if ((action.id == "org.freedesktop.login1.power-off" ||
           action.id == "org.freedesktop.login1.reboot") &&
          subject.user == "lemurs") {
        return polkit.Result.YES;
      }
    });
  '';

  users.users.vladkaban = {
    isNormalUser = true;
    description = "vladkaban";
    extraGroups = [ "networkmanager" "wheel" "video" "input" "seat" "audio" ];
    shell = pkgs.fish;
  };

  environment.systemPackages = with pkgs; [
	android-tools
	scrcpy
    tmux
    git
    foot
    fuzzel
    waybar
    mako
    awww
    micro
    yazi
    wallust
    pavucontrol
    mpv
    telegram-desktop
    firefox
    brightnessctl
    linux-firmware
    networkmanagerapplet
    blueman
    helix
    flatpak
    wireplumber
    coreutils
    gnused
    gsettings-desktop-schemas    
	amneziawg-tools
	mangohud
	protonup-qt
	xwayland-satellite
  ];

  services.xserver.xkb = {
    layout = "us,ru";
    options = "grp:caps_toggle";
    variant = "";
  };

  nix.settings = {
    substituters = [ "https://nixos.org" ];
    trusted-public-keys = [ "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcdShjY=" ];
  };

  system.stateVersion = "26.05";
  programs.helium.enable = true;
  programs.helium.flags = [ "--ozone-platform=wayland" ];
  programs.xwayland.enable = true;
  programs.gamescope.enable = true;
  programs.gamemode.enable = true;
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true;
    dedicatedServer.openFirewall = true;
    localNetworkGameTransfers.openFirewall = true;
  };
  
  programs.niri.enable = true;
  programs.fish = {
    enable = true;
    shellAliases = {
      rebuild = "sudo nixos-rebuild switch";
      wifi = "sudo nmcli device wifi connect";
    };
  };

  services.actkbd = {
    enable = true;
    bindings = [
      { keys = [ 224 ]; events = [ "key" ]; command = "${pkgs.brightnessctl}/bin/brightnessctl set 10%-"; }
      { keys = [ 225 ]; events = [ "key" ]; command = "${pkgs.brightnessctl}/bin/brightnessctl set +10%"; }
    ];
  };

}
