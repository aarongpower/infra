{ ... }:

{
  imports = [
    ./docker-compose.nix
  ];

    age.secrets.odoo-postgres-pwd = {
    file = ../../../secrets/odoo-postgres-pwd.age;
    # owner = "cloudflared";
    # group = "cloudflared";
  };
}
