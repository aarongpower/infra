{ ... }:

{
  imports = [
    ./docker-compose.nix
  ];

    age.secrets.odoo-env = {
    file = ../../../secrets/odoo-env.age;
    owner = "aaronp";
    group = "aaronp";
  };
}
