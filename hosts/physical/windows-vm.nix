{ pkgs, ... }:

let
  vmName = "win11-pro";
  driverIso = pkgs.virtio-win.src;
  driverVolume = "virtio-win-${pkgs.virtio-win.version}.iso";
  ovmfCode = "${pkgs.OVMFFull.fd}/FV/OVMF_CODE.ms.fd";
  ovmfVars = "${pkgs.OVMFFull.fd}/FV/OVMF_VARS.ms.fd";

  win11VmCreate = pkgs.writeShellApplication {
    name = "win11-vm-create";
    runtimeInputs = with pkgs; [
      coreutils
      gnugrep
      libvirt
      virt-manager
      virt-viewer
    ];
    text = ''
      export LC_ALL=C

      if [ "$#" -ne 1 ]; then
        echo "Usage: win11-vm-create /absolute/path/to/Win11.iso" >&2
        exit 2
      fi

      iso_path="$(realpath "$1")"
      if [ ! -f "$iso_path" ] || [ ! -r "$iso_path" ]; then
        echo "ISO does not exist or is not readable: $iso_path" >&2
        exit 2
      fi

      connection="qemu:///system"
      virsh_cmd=(virsh --connect "$connection")

      # virt-install 5.1 auto-created this pool when handed a path directly
      # under /nix/store. Enumerating that directory exceeds libvirt's RPC
      # volume limit, so remove only this exact, data-less pool definition.
      if "''${virsh_cmd[@]}" pool-info store >/dev/null 2>&1 \
        && "''${virsh_cmd[@]}" pool-dumpxml store | grep -F '<path>/nix/store</path>' >/dev/null; then
        if "''${virsh_cmd[@]}" pool-info store | grep -E '^State:[[:space:]]+running$' >/dev/null; then
          "''${virsh_cmd[@]}" pool-destroy store
        fi
        "''${virsh_cmd[@]}" pool-undefine store
      fi

      if "''${virsh_cmd[@]}" dominfo ${vmName} >/dev/null 2>&1; then
        echo "VM '${vmName}' already exists; refusing to overwrite it." >&2
        exit 1
      fi

      if ! "''${virsh_cmd[@]}" pool-info default >/dev/null 2>&1; then
        "''${virsh_cmd[@]}" pool-define-as default dir --target /var/lib/libvirt/images
        "''${virsh_cmd[@]}" pool-build default
      fi

      if ! "''${virsh_cmd[@]}" pool-info default | grep -E '^State:[[:space:]]+running$' >/dev/null; then
        "''${virsh_cmd[@]}" pool-start default
      fi
      "''${virsh_cmd[@]}" pool-autostart default

      if ! "''${virsh_cmd[@]}" vol-info --pool default ${driverVolume} >/dev/null 2>&1; then
        driver_size="$(stat --format=%s ${driverIso})"
        echo "Importing VirtIO drivers into the libvirt storage pool (one-time)."
        "''${virsh_cmd[@]}" vol-create-as default ${driverVolume} "$driver_size" --format raw
        if ! "''${virsh_cmd[@]}" vol-upload --pool default ${driverVolume} ${driverIso}; then
          "''${virsh_cmd[@]}" vol-delete --pool default ${driverVolume}
          echo "Failed to import the VirtIO driver ISO." >&2
          exit 1
        fi
      fi

      if ! "''${virsh_cmd[@]}" net-info default >/dev/null 2>&1; then
        echo "The libvirt 'default' NAT network is unavailable." >&2
        echo "Restart libvirtd, then run this command again." >&2
        exit 1
      fi

      if ! "''${virsh_cmd[@]}" net-info default | grep -E '^Active:[[:space:]]+yes$' >/dev/null; then
        "''${virsh_cmd[@]}" net-start default
      fi
      "''${virsh_cmd[@]}" net-autostart default

      if "''${virsh_cmd[@]}" vol-info --pool default ${vmName}.qcow2 >/dev/null 2>&1; then
        echo "Disk '${vmName}.qcow2' already exists; refusing to overwrite it." >&2
        echo "If it is left over from a failed creation, inspect it in virt-manager before deleting it." >&2
        exit 1
      fi

      echo "Creating ${vmName}: 4 vCPU, 6 GiB RAM, 64 GiB sparse disk."
      echo "Windows ISO: $iso_path"
      echo "VirtIO drivers: default/${driverVolume}"

      virt-install \
        --connect "$connection" \
        --name ${vmName} \
        --description "Windows 11 Pro lightweight office VM" \
        --osinfo win11 \
        --machine q35 \
        --memory 6144 \
        --vcpus sockets=1,cores=2,threads=2 \
        --cpu host-passthrough \
        --boot cdrom,hd,loader=${ovmfCode},loader.readonly=yes,loader.type=pflash,nvram.template=${ovmfVars},nvram.templateFormat=raw \
        --features smm=on \
        --tpm backend.type=emulator,backend.version=2.0,model=tpm-crb \
        --rng /dev/urandom \
        --disk pool=default,size=64,format=qcow2,bus=virtio,cache=none,discard=unmap \
        --disk "path=$iso_path,device=cdrom,bus=sata,readonly=on" \
        --disk vol=default/${driverVolume},device=cdrom,bus=sata,readonly=on \
        --network network=default,model=virtio \
        --graphics spice \
        --video virtio \
        --channel spicevmc \
        --sound ich9 \
        --controller usb,model=qemu-xhci \
        --autoconsole graphical
    '';
  };

  win11VmFinishInstall = pkgs.writeShellApplication {
    name = "win11-vm-finish-install";
    runtimeInputs = with pkgs; [
      libvirt
      virt-manager
    ];
    text = ''
      export LC_ALL=C

      connection="qemu:///system"
      virsh_cmd=(virsh --connect "$connection")

      if ! "''${virsh_cmd[@]}" dominfo ${vmName} >/dev/null 2>&1; then
        echo "VM '${vmName}' does not exist." >&2
        exit 1
      fi

      changed=no
      reboot_needed=no

      boot_is_hd_only="$(
        "''${virsh_cmd[@]}" dumpxml ${vmName} --inactive \
          | awk '
              /<os>/ { in_os = 1; next }
              /<\/os>/ { in_os = 0 }
              in_os && /<boot dev=/ {
                boot_count++
                if ($0 ~ /dev=.hd./) hd_count++
              }
              END {
                if (boot_count == 1 && hd_count == 1) print "yes"
                else print "no"
              }
            '
      )"

      if [ "$boot_is_hd_only" != "yes" ]; then
        virt-xml --connect "$connection" ${vmName} --edit --boot hd
        changed=yes
      fi

      has_installer_media() {
        "''${virsh_cmd[@]}" domblklist ${vmName} "$@" --details \
          | awk '$2 == "cdrom" && $3 == "sda" && $4 != "-" { found = 1 } END { exit !found }'
      }

      vm_state="$("''${virsh_cmd[@]}" domstate ${vmName})"
      if [ "$vm_state" = "running" ]; then
        live_has_media=no
        config_has_media=no
        if has_installer_media; then live_has_media=yes; fi
        if has_installer_media --inactive; then config_has_media=yes; fi

        if [ "$live_has_media" = "yes" ] && [ "$config_has_media" = "yes" ]; then
          "''${virsh_cmd[@]}" change-media ${vmName} sda --eject --live --config
          changed=yes
          reboot_needed=yes
        elif [ "$live_has_media" = "yes" ]; then
          "''${virsh_cmd[@]}" change-media ${vmName} sda --eject --live
          changed=yes
          reboot_needed=yes
        elif [ "$config_has_media" = "yes" ]; then
          "''${virsh_cmd[@]}" change-media ${vmName} sda --eject --config
          changed=yes
        fi
      else
        if has_installer_media --inactive; then
          "''${virsh_cmd[@]}" change-media ${vmName} sda --eject --config
          changed=yes
        fi
      fi

      if [ "$reboot_needed" = "yes" ]; then
        "''${virsh_cmd[@]}" reboot ${vmName}
      fi

      if [ "$changed" = "yes" ]; then
        echo "Windows installer ISO ejected; ${vmName} now boots from its virtual disk."
      else
        echo "Nothing to do: ${vmName} already boots from disk and its installer ISO is not mounted."
      fi
    '';
  };
in
{
  programs.virt-manager.enable = true;

  virtualisation.libvirtd = {
    enable = true;
    onBoot = "ignore";
    onShutdown = "shutdown";
    qemu = {
      package = pkgs.qemu_kvm;
      swtpm.enable = true;
    };
  };

  environment.systemPackages = [
    win11VmCreate
    win11VmFinishInstall
    pkgs.virt-viewer
  ];

  users.users.lznauy.extraGroups = [
    "kvm"
    "libvirtd"
  ];
}
