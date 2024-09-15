let
  aaronp = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIL0idNvgGiucWgup/mP78zyC23uFjYq0evcWdjGQUaBH";
  users = [ aaronp ];

  nixos = "nixos ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOniU1ApVO3N5b9Hov+6MpPP7nXMZpmpZSQpbd7Iq826";
  systems = [ nixos ];

  yggdrasil = "yggdrasil ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIFrAGLsDAdnZ9tQ2RHlwMxhLQJIUeslHpyN2w4TiKfvv";
  systems = [ yggdrasil ];
in
{
  "openai-key.age".publicKeys = [ aaronp ];
  "cloudflare-tunnel".publicKeys = [ yggdrasil ];
  "odoo-env".publicKeys = [ nixos ];
}
