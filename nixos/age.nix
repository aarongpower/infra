{ config, ... }:

{
  age.rekey = {
    hostPubkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOniU1ApVO3N5b9Hov+6MpPP7nXMZpmpZSQpbd7Iq826";
    masterIdentities = [ ../secrets/agenix_ed25519.pub ];
    storageMode = "local";
    localStorageDir = ./. + "/secrets/rekeyed/${config.networking.hostName}";
  };
}
